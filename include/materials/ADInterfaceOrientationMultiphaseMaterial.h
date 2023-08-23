//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

#include "ADMaterial.h"

// Forward Declarations

/**
 * Material to compute the angular orientation of order parameter interfaces.
 */
class ADInterfaceOrientationMultiphaseMaterial : public ADMaterial
{
public:
  static InputParameters validParams();

  ADInterfaceOrientationMultiphaseMaterial(const InputParameters & parameters);

protected:
  virtual void computeQpProperties();

private:
  MaterialPropertyName _kappa_name;
  MaterialPropertyName _dkappadgrad_etaa_name;
  MaterialPropertyName _d2kappadgrad_etaa_name;
  const Real _delta;
  const unsigned int _j;
  const Real _theta0;
  const Real _kappa_bar;
  bool _use_tolerance;

  VariableName _etaa_name;
  const ADVariableValue & _etaa;
  const ADVariableGradient & _grad_etaa;

  VariableName _etab_name;
  const ADVariableValue & _etab;
  const ADVariableGradient & _grad_etab;

  ADMaterialProperty<Real> & _kappa;
  ADMaterialProperty<RealGradient> & _dkappadgrad_etaa;
};