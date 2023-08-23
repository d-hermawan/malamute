//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "GrandPotentialAnisoInterface.h"
#include "Conversion.h"
#include "IndirectSort.h"
#include "libmesh/utility.h"

registerMooseObject("PhaseFieldApp", GrandPotentialAnisoInterface);

InputParameters
GrandPotentialAnisoInterface::validParams()
{
  InputParameters params = Material::validParams();
  params.addClassDescription("Calculate Grand Potential interface parameters for a specified "
                             "interfacial free energy and width");
  params.addRequiredCoupledVar("etas", "Vector of order parameters for the given phase");
  return params;
}

GrandPotentialAnisoInterface::GrandPotentialAnisoInterface(const InputParameters & parameters)
  : DerivativeMaterialInterface<Material>(parameters),
    _num_eta(coupledComponents("etas")),
    _eta(_num_eta),
    _eta_names(_num_eta),
    _kappa(declareProperty<Real>("kappa_op")),
    _sum_val(declareProperty<Real>("sum_val")),
    _dkappadgrad_etaa(declareProperty<RealGradient>("dkappadgrad_etaa")),
    _d2kappadgrad_etaa(declareProperty<RealTensorValue>("d2kappadgrad_etaa")),
    _dkappadeta(_num_eta),
    _d2kappadeta2(_num_eta),
    _d2kappadgrad_etaa_deta(_num_eta),
    _kappa_comp(_num_eta),
    _dkappadgrad_etaa_comp(_num_eta),
    _d2kappadgrad_etaa_comp(_num_eta)
{
  for (unsigned int i = 0; i < _num_eta; ++i)
  {
    _eta[i] = &coupledValue("etas", i);
    _eta_names[i] = getVar("etas", i)->name();

    _dkappadeta[i] = &declarePropertyDerivative<Real>("kappa_op", _eta_names[i]);
    _d2kappadgrad_etaa_deta[i] =
        &declarePropertyDerivative<RealGradient>("dkappadgrad_etaa", _eta_names[i]);

    _d2kappadeta2[i].resize(_num_eta, NULL);
  }

  for (unsigned int i = 0; i < _num_eta; ++i)
    for (unsigned int j = i; j < _num_eta; ++j)
      _d2kappadeta2[i][j] = _d2kappadeta2[j][i] =
          &declarePropertyDerivative<Real>("kappa_op", _eta_names[i], _eta_names[j]);

  for (unsigned int i = 0; i < _num_eta; ++i)
  {
    _kappa_comp[i].resize(_num_eta);
    _dkappadgrad_etaa_comp[i].resize(_num_eta);
    _d2kappadgrad_etaa_comp[i].resize(_num_eta);
    for (unsigned int j = 0; j < _num_eta; ++j)
      if (j != i)
      {
        _kappa_comp[i][j] =
            &getMaterialProperty<Real>("kappa_" + _eta_names[i] + "_" + _eta_names[j]);
        _dkappadgrad_etaa_comp[i][j] = &getMaterialProperty<RealGradient>(
            "dkappadgrad_" + _eta_names[i] + "_" + _eta_names[j]);
        _d2kappadgrad_etaa_comp[i][j] = &getMaterialProperty<RealTensorValue>(
            "d2kappadgrad_" + _eta_names[i] + "_" + _eta_names[j]);
      }
  }
}

void
GrandPotentialAnisoInterface::computeQpProperties()
{
  Real Val = 0.0;
  Real dvaldetam = 0.0;
  Real dvaldetan = 0.0;
  Real sum_val = 0.0;

  std::vector<Real> d2valdeta2(_num_eta);
  std::vector<Real> sum_dvaldeta(_num_eta);
  std::vector<Real> sum_kappa_dvaldeta(_num_eta);
  std::vector<Real> sum_kappa_d2valdetaa2(_num_eta);
  std::vector<RealGradient> sum_dkappadgrad_etaa_dvaldeta(_num_eta);

  Real sum_kappa = 0.0;
  RealGradient sum_dkappadgrad_etaa;
  RealTensorValue sum_d2kappadgrad_etaa;
  std::vector<std::vector<Real>> kappa_d2valdetaadetab(_num_eta);

  for (unsigned int m = 0; m < _num_eta; ++m)
    kappa_d2valdetaadetab[m].resize(_num_eta);

  for (unsigned int m = 0; m < _num_eta - 1; ++m)
    for (unsigned int n = m + 1; n < _num_eta; ++n)
    {
      Val = (1000.0 * (*_eta[m])[_qp] * (*_eta[m])[_qp] + 0.01) *
            (1000.0 * (*_eta[n])[_qp] * (*_eta[n])[_qp] + 0.01);

      dvaldetam = (1000.0 * ((*_eta[n])[_qp]) * ((*_eta[n])[_qp]) + 0.01);
      dvaldetan = (1000.0 * ((*_eta[m])[_qp]) * ((*_eta[m])[_qp]) + 0.01);

      sum_val += 2.0 * Val;
      sum_dvaldeta[m] += 4.0 * 1000.0 * (*_eta[m])[_qp] * dvaldetam;
      sum_dvaldeta[n] += 4.0 * 1000.0 * (*_eta[n])[_qp] * dvaldetan;
      d2valdeta2[m] += 4.0 * 1000.0 * dvaldetam;
      d2valdeta2[n] += 4.0 * 1000.0 * dvaldetan;

      sum_kappa += Val * ((*_kappa_comp[m][n])[_qp] + (*_kappa_comp[n][m])[_qp]);
      sum_kappa_dvaldeta[m] += 2.0 * 1000.0 * (*_eta[m])[_qp] * dvaldetam *
                               ((*_kappa_comp[m][n])[_qp] + (*_kappa_comp[n][m])[_qp]);
      sum_kappa_dvaldeta[n] += 2.0 * 1000.0 * (*_eta[n])[_qp] * dvaldetan *
                               ((*_kappa_comp[m][n])[_qp] + (*_kappa_comp[n][m])[_qp]);

      sum_kappa_d2valdetaa2[m] +=
          2.0 * 1000.0 * dvaldetam * ((*_kappa_comp[m][n])[_qp] + (*_kappa_comp[n][m])[_qp]);
      sum_kappa_d2valdetaa2[n] +=
          2.0 * 1000.0 * dvaldetan * ((*_kappa_comp[m][n])[_qp] + (*_kappa_comp[n][m])[_qp]);

      sum_dkappadgrad_etaa +=
          Val * ((*_dkappadgrad_etaa_comp[m][n])[_qp] + (*_dkappadgrad_etaa_comp[n][m])[_qp]);
      sum_d2kappadgrad_etaa +=
          Val * ((*_d2kappadgrad_etaa_comp[m][n])[_qp] + (*_d2kappadgrad_etaa_comp[n][m])[_qp]);

      sum_dkappadgrad_etaa_dvaldeta[m] +=
          2.0 * 1000.0 * (*_eta[m])[_qp] * dvaldetam *
          ((*_dkappadgrad_etaa_comp[m][n])[_qp] + (*_dkappadgrad_etaa_comp[n][m])[_qp]);
      sum_dkappadgrad_etaa_dvaldeta[n] +=
          2.0 * 1000.0 * (*_eta[n])[_qp] * dvaldetan *
          ((*_dkappadgrad_etaa_comp[m][n])[_qp] + (*_dkappadgrad_etaa_comp[n][m])[_qp]);

      kappa_d2valdetaadetab[m][n] = kappa_d2valdetaadetab[n][m] =
          4.0 * 1000.0 * (*_eta[m])[_qp] * (*_eta[n])[_qp] *
          ((*_kappa_comp[m][n])[_qp] + (*_kappa_comp[n][m])[_qp]);
    }

  _sum_val[_qp] = sum_val;

  // if (sum_val > libMesh::TOLERANCE)
  {
    _kappa[_qp] = sum_kappa / sum_val;
    _dkappadgrad_etaa[_qp] = sum_dkappadgrad_etaa / sum_val;
    // _d2kappadgrad_etaa[_qp] = sum_d2kappadgrad_etaa / sum_val;
  }

  for (unsigned int i = 0; i < _num_eta; ++i)
  {
    (*_dkappadeta[i])[_qp] =
        (sum_kappa_dvaldeta[i] * sum_val - sum_kappa * sum_dvaldeta[i]) / (sum_val * sum_val);

    (*_d2kappadgrad_etaa_deta[i])[_qp] =
        (sum_dkappadgrad_etaa_dvaldeta[i] * sum_val - sum_dkappadgrad_etaa * sum_dvaldeta[i]) /
        (sum_val * sum_val);

    (*_d2kappadeta2[i][i])[_qp] =
        (sum_val * sum_val *
             (sum_kappa_d2valdetaa2[i] * sum_val + sum_kappa_dvaldeta[i] * sum_dvaldeta[i] -
              sum_kappa_dvaldeta[i] * sum_dvaldeta[i] - sum_kappa * d2valdeta2[i]) -
         (sum_kappa_dvaldeta[i] * sum_val - sum_kappa * sum_dvaldeta[i]) * 2.0 * sum_val *
             sum_dvaldeta[i]) /
        (sum_val * sum_val * sum_val * sum_val);

    for (unsigned int j = 0; j < _num_eta; ++j)
      if (j != i)
      {
        (*_d2kappadeta2[i][j])[_qp] =
            (sum_val * sum_val *
                 (kappa_d2valdetaadetab[i][j] * sum_val + sum_kappa_dvaldeta[i] * sum_dvaldeta[j] -
                  sum_kappa_dvaldeta[j] * sum_dvaldeta[i] -
                  sum_kappa * 8.0 * 1000.0 * (*_eta[i])[_qp] * (*_eta[j])[_qp]) -
             (sum_kappa_dvaldeta[i] * sum_val - sum_kappa * sum_dvaldeta[i]) * 2.0 * sum_val * 8.0 *
                 1000.0 * (*_eta[i])[_qp] * (*_eta[j])[_qp]) /
            (sum_val * sum_val * sum_val * sum_val);
      }
  }
}