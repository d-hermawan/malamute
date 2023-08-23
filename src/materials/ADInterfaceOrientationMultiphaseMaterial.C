
 

//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "ADInterfaceOrientationMultiphaseMaterial.h"
#include "MooseMesh.h"
#include "MathUtils.h"

registerMooseObject("PhaseFieldApp", ADInterfaceOrientationMultiphaseMaterial);

InputParameters
ADInterfaceOrientationMultiphaseMaterial::validParams()
{
  InputParameters params = Material::validParams();
  params.addClassDescription(
      "This Material accounts for the the orientation dependence "
      "of interfacial energy for multi-phase multi-order parameter phase-field model.");
  params.addRequiredParam<MaterialPropertyName>("kappa_name",
                                                "Name of the kappa for the given phase");
  params.addRequiredParam<MaterialPropertyName>(
      "dkappadgrad_etaa_name", "Name of the derivative of kappa w.r.t. the gradient of eta");
  params.addParam<Real>(
      "anisotropy_strength", 0.04, "Strength of the anisotropy (typically < 0.05)");
  params.addParam<unsigned int>("mode_number", 4, "Mode number for anisotropy");
  params.addParam<Real>(
      "reference_angle", 90, "Reference angle for defining anisotropy in degrees");
  params.addParam<Real>("kappa_bar", 0.1125, "Average value of the interface parameter kappa");
  params.addParam<bool>("use_tolerance", false, "Average value of the interface parameter kappa");
  params.addRequiredCoupledVar("etaa", "Order parameter for the current phase alpha");
  params.addRequiredCoupledVar("etab", "Order parameter for the neighboring phase beta");
  return params;
}

ADInterfaceOrientationMultiphaseMaterial::ADInterfaceOrientationMultiphaseMaterial(
    const InputParameters & parameters)
  : ADMaterial(parameters),
    _kappa_name(getParam<MaterialPropertyName>("kappa_name")),
    _dkappadgrad_etaa_name(getParam<MaterialPropertyName>("dkappadgrad_etaa_name")),
    _delta(getParam<Real>("anisotropy_strength")),
    _j(getParam<unsigned int>("mode_number")),
    _theta0(getParam<Real>("reference_angle")),
    _kappa_bar(getParam<Real>("kappa_bar")),
    _use_tolerance(getParam<bool>("use_tolerance")),
    _etaa_name(getVar("etaa", 0)->name()),
    _etaa(adCoupledValue("etaa")),
    _grad_etaa(adCoupledGradient("etaa")),
    _etab_name(getVar("etab", 0)->name()),
    _etab(adCoupledValue("etab")),
    _grad_etab(adCoupledGradient("etab")),
    _kappa(declareADProperty<Real>(_kappa_name + "_" + _etaa_name + "_" + _etab_name)),
    _dkappadgrad_etaa(declareADProperty<RealGradient>(_dkappadgrad_etaa_name + "_" + _etaa_name +
                                                      "_" + _etab_name))
{
  // this currently only works in 2D simulations
  if (_mesh.dimension() != 2)
    mooseError("ADInterfaceOrientationMultiphaseMaterial requires a two-dimensional mesh.");
}

void
ADInterfaceOrientationMultiphaseMaterial::computeQpProperties()
{
  const Real tol = libMesh::TOLERANCE;
  // const Real tol = 1e-5;
  const Real cutoff = 1.0 - tol;
  ADRealGradient grada = _grad_etaa[_qp];
  ADRealGradient gradb = _grad_etab[_qp];
  if (_use_tolerance)
  {
    grada += RealVectorValue(tol);
    gradb += RealVectorValue(tol);
  }

  // Normal direction of the interface
  ADReal n = 0.0;
  ADRealGradient nd;
  if (grada.norm() > tol && gradb.norm() > tol)
    nd = _grad_etaa[_qp] - _grad_etab[_qp];

  const ADReal nx = nd(0);
  const ADReal ny = nd(1);
  ADReal nsq;
  if (_use_tolerance)
    nsq = (nd + RealVectorValue(tol)).norm_sq();
  else
    nsq = nd.norm_sq();

  // if (nsq > tol)
  //   n = std::max(-cutoff, std::min(nx / std::sqrt(nsq), cutoff));

  if (nsq > tol)
    n = nx / std::sqrt(nsq);

  if (n > cutoff)
    n = cutoff;

  if (n < -cutoff)
    n = -cutoff;

  // Calculate the orientation angle
  const ADReal angle = std::acos(n) * MathUtils::sign(ny);
  // const ADReal angle = std::acos(n) * ny / std::abs(ny);
  // Compute derivatives of the angle wrt n
  const ADReal dangledn = -MathUtils::sign(ny) / std::sqrt(1.0 - n * n);
  // const ADReal dangledn = -ny / std::abs(ny) / std::sqrt(1.0 - n * n);

  // Compute derivative of n wrt grad_eta
  ADRealGradient dndgrad_etaa;
  if (nsq > tol)
  {
    dndgrad_etaa(0) = ny * ny;
    dndgrad_etaa(1) = -nx * ny;
    dndgrad_etaa /= nsq * std::sqrt(nsq);
  }

  // Calculate interfacial coefficient kappa and its derivatives wrt the angle
  const ADReal anglediff = _j * (angle - _theta0 * libMesh::pi / 180.0);

  _kappa[_qp] =
      _kappa_bar * (1.0 + _delta * std::cos(anglediff)) * (1.0 + _delta * std::cos(anglediff));

  const ADReal dkappadangle =
      -2.0 * _kappa_bar * _delta * _j * (1.0 + _delta * std::cos(anglediff)) * std::sin(anglediff);

  // Compute derivatives of kappa wrt grad_eta
  if (grada.norm() > tol && gradb.norm() > tol)
    _dkappadgrad_etaa[_qp] = dkappadangle * dangledn * dndgrad_etaa;
}