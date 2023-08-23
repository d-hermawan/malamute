//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "ADGrandPotentialAnisoInterfaceOld.h"
// #include "Conversion.h"
// #include "IndirectSort.h"
// #include "libmesh/utility.h"

registerMooseObject("PhaseFieldApp", ADGrandPotentialAnisoInterfaceOld);

InputParameters
ADGrandPotentialAnisoInterfaceOld::validParams()
{
  InputParameters params = ADMaterial::validParams();
  params.addClassDescription("Calculate Grand Potential interface parameters for a specified "
                             "interfacial free energy and width");
  params.addRequiredCoupledVar("etas", "Vector of order parameters for the given phase");
  // params.addParam<bool>("use_tolerance", true, "Average value of the interface parameter kappa");
  // params.addParam<>("tolerance_type", true, "Average value of the interface parameter kappa");

  return params;
}

ADGrandPotentialAnisoInterfaceOld::ADGrandPotentialAnisoInterfaceOld(
    const InputParameters & parameters)
  : ADMaterial(parameters),
    DerivativeMaterialPropertyNameInterface(),
    _num_eta(coupledComponents("etas")),
    _eta(_num_eta),
    _eta_names(_num_eta),
    _kappa(declareADProperty<Real>("kappa_op")),
    _kappa2(declareADProperty<Real>("kappa_op2")),
    _sum_val(declareADProperty<Real>("sum_val")),
    _sum_val2(declareADProperty<Real>("sum_val2")),
    _dkappadgrad_etaa(declareADProperty<RealGradient>("dkappadgrad_etaa")),
    _dkappadeta(_num_eta),
    _dkappadeta2(_num_eta),
    _kappa_comp(_num_eta),
    _dkappadgrad_etaa_comp(_num_eta)
{
  for (unsigned int i = 0; i < _num_eta; ++i)
  {
    _eta[i] = &adCoupledValue("etas", i);
    _eta_names[i] = getVar("etas", i)->name();

    _dkappadeta[i] =
        &declareADProperty<Real>(derivativePropertyNameFirst("kappa_op", _eta_names[i]));

    _dkappadeta2[i] =
        &declareADProperty<Real>(derivativePropertyNameFirst("kappa_op2", _eta_names[i]));
  }

  for (unsigned int i = 0; i < _num_eta; ++i)
  {
    _kappa_comp[i].resize(_num_eta);
    _dkappadgrad_etaa_comp[i].resize(_num_eta);
    for (unsigned int j = 0; j < _num_eta; ++j)
      if (j != i)
      {
        _kappa_comp[i][j] =
            &getADMaterialProperty<Real>("kappa_" + _eta_names[i] + "_" + _eta_names[j]);
        _dkappadgrad_etaa_comp[i][j] = &getADMaterialProperty<RealGradient>(
            "dkappadgrad_" + _eta_names[i] + "_" + _eta_names[j]);
      }
  }
}

void
ADGrandPotentialAnisoInterfaceOld::computeQpProperties()
{
  ADReal Val = 0.0;
  ADReal dvaldetam = 0.0;
  ADReal dvaldetan = 0.0;
  ADReal sum_val = 0.0;

  std::vector<ADReal> sum_dvaldeta(_num_eta);
  std::vector<ADReal> sum_kappa_dvaldeta(_num_eta);

  ADReal sum_kappa = 0.0;
  ADRealGradient sum_dkappadgrad_etaa;

  ADReal Val2 = 0.0;
  ADReal dvaldetam2 = 0.0;
  ADReal dvaldetan2 = 0.0;
  ADReal sum_val2 = 0.0;
  ADReal sum_kappa2 = 0.0;

  std::vector<ADReal> sum_dvaldeta2(_num_eta);
  std::vector<ADReal> sum_kappa_dvaldeta2(_num_eta);

  for (unsigned int m = 0; m < _num_eta - 1; ++m)
    for (unsigned int n = m + 1; n < _num_eta; ++n)
    {
      Val2 = (10000.0 * (*_eta[m])[_qp] * (*_eta[m])[_qp] + 0.01) *
             (10000.0 * (*_eta[n])[_qp] * (*_eta[n])[_qp] + 0.01);
      // Val = (1000.0 * (*_eta[m])[_qp] * (*_eta[m])[_qp] + libMesh::TOLERANCE) *
      //       (1000.0 * (*_eta[n])[_qp] * (*_eta[n])[_qp] + libMesh::TOLERANCE);

      dvaldetam2 = (10000.0 * ((*_eta[n])[_qp]) * ((*_eta[n])[_qp]) + 0.01);
      dvaldetan2 = (10000.0 * ((*_eta[m])[_qp]) * ((*_eta[m])[_qp]) + 0.01);
      // dvaldeta = (1000.0 * ((*_eta[n])[_qp]) * ((*_eta[n])[_qp]) + libMesh::TOLERANCE);

      sum_val2 += 2.0 * Val2;
      sum_dvaldeta2[m] += 4.0 * 10000.0 * (*_eta[m])[_qp] * dvaldetam2;
      sum_dvaldeta2[n] += 4.0 * 10000.0 * (*_eta[n])[_qp] * dvaldetan2;

      sum_kappa2 += Val2 * ((*_kappa_comp[m][n])[_qp] + (*_kappa_comp[n][m])[_qp]);
      sum_kappa_dvaldeta2[m] += 2.0 * 10000.0 * (*_eta[m])[_qp] * dvaldetam *
                                ((*_kappa_comp[m][n])[_qp] + (*_kappa_comp[n][m])[_qp]);
      sum_kappa_dvaldeta2[n] += 2.0 * 10000.0 * (*_eta[n])[_qp] * dvaldetan *
                                ((*_kappa_comp[m][n])[_qp] + (*_kappa_comp[n][m])[_qp]);

      // sum_dkappadgrad_etaa +=
      //     Val * ((*_dkappadgrad_etaa_comp[m][n])[_qp] + (*_dkappadgrad_etaa_comp[n][m])[_qp]);
    }

  for (unsigned int m = 0; m < _num_eta; ++m)
    for (unsigned int n = 0; n < _num_eta; ++n)
      if (m != n)
      {
        Val = (10000.0 * (*_eta[m])[_qp] * (*_eta[m])[_qp] + 0.01) *
              (10000.0 * (*_eta[n])[_qp] * (*_eta[n])[_qp] + 0.01);
        // Val = (1000.0 * (*_eta[m])[_qp] * (*_eta[m])[_qp] + libMesh::TOLERANCE) *
        //       (1000.0 * (*_eta[n])[_qp] * (*_eta[n])[_qp] + libMesh::TOLERANCE);

        // dvaldetam = (1000.0 * ((*_eta[n])[_qp]) * ((*_eta[n])[_qp]) + 0.01);
        // dvaldetan = (1000.0 * ((*_eta[m])[_qp]) * ((*_eta[m])[_qp]) + 0.01);
        // dvaldeta = (1000.0 * ((*_eta[n])[_qp]) * ((*_eta[n])[_qp]) + libMesh::TOLERANCE);

        sum_val += Val;
        // sum_dvaldeta[m] += 4.0 * 1000.0 * (*_eta[m])[_qp] * dvaldetam;
        // sum_dvaldeta[n] += 4.0 * 1000.0 * (*_eta[n])[_qp] * dvaldetan;

        sum_kappa += Val * (*_kappa_comp[m][n])[_qp];
        // sum_kappa_dvaldeta[m] += 2.0 * 1000.0 * (*_eta[m])[_qp] * dvaldetam *
        // ((*_kappa_comp[m][n])[_qp] + (*_kappa_comp[n][m])[_qp]);
        // sum_kappa_dvaldeta[n] += 2.0 * 1000.0 * (*_eta[n])[_qp] * dvaldetan *
        // ((*_kappa_comp[m][n])[_qp] + (*_kappa_comp[n][m])[_qp]);

        sum_dkappadgrad_etaa += Val * (*_dkappadgrad_etaa_comp[m][n])[_qp];

        // Val = (1000.0 * (*_eta[m])[_qp] * (*_eta[m])[_qp] + 0.01) *
        //       (1000.0 * (*_eta[n])[_qp] * (*_eta[n])[_qp] + 0.01);
        // Val = (1000.0 * (*_eta[m])[_qp] * (*_eta[m])[_qp] + libMesh::TOLERANCE) *
        //       (1000.0 * (*_eta[n])[_qp] * (*_eta[n])[_qp] + libMesh::TOLERANCE);

        dvaldetam = 2.0 * 10000.0 * (*_eta[m])[_qp] * (*_eta[m])[_qp] *
                    (10000.0 * (*_eta[n])[_qp] * (*_eta[n])[_qp] * (*_eta[n])[_qp] + 0.01);
        // dvaldetan = (1000.0 * ((*_eta[m])[_qp]) * ((*_eta[m])[_qp]) + 0.01);
        // dvaldeta = (1000.0 * ((*_eta[n])[_qp]) * ((*_eta[n])[_qp]) + libMesh::TOLERANCE);

        // sum_val += 2.0 * Val;
        sum_dvaldeta[m] += 2.0 * dvaldetam;
        // sum_dvaldeta[n] += 4.0 * 1000.0 * (*_eta[n])[_qp] * dvaldetan;

        // sum_kappa += Val * ((*_kappa_comp[m][n])[_qp] + (*_kappa_comp[n][m])[_qp]);
        sum_kappa_dvaldeta[m] +=
            dvaldetam * ((*_kappa_comp[m][n])[_qp] + (*_kappa_comp[n][m])[_qp]);
        // sum_kappa_dvaldeta[n] += 2.0 * 1000.0 * (*_eta[n])[_qp] * dvaldetan *
        //                          ((*_kappa_comp[m][n])[_qp] + (*_kappa_comp[n][m])[_qp]);

        // sum_dkappadgrad_etaa +=
        //     Val * ((*_dkappadgrad_etaa_comp[m][n])[_qp] + (*_dkappadgrad_etaa_comp[n][m])[_qp]);
      }
  // if (sum_val > libMesh::TOLERANCE)
  {
    _sum_val[_qp] = sum_val;
    _sum_val2[_qp] = sum_val2;
    _kappa[_qp] = sum_kappa / sum_val;
    _kappa2[_qp] = sum_kappa2 / sum_val2;
    _dkappadgrad_etaa[_qp] = sum_dkappadgrad_etaa / sum_val;
  }

  for (unsigned int i = 0; i < _num_eta; ++i)
  {
    (*_dkappadeta[i])[_qp] =
        (sum_kappa_dvaldeta[i] * sum_val - sum_kappa * sum_dvaldeta[i]) / (sum_val * sum_val);
    (*_dkappadeta2[i])[_qp] =
        (sum_kappa_dvaldeta2[i] * sum_val2 - sum_kappa2 * sum_dvaldeta2[i]) / (sum_val2 * sum_val2);
  }
}