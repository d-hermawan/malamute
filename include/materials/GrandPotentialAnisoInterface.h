//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

#include "Material.h"
#include "DerivativeMaterialInterface.h"

/**
 * Calculate Grand Potential interface parameters for a specified interfacial free energy and width.
 */
class GrandPotentialAnisoInterface : public DerivativeMaterialInterface<Material>
{
public:
  static InputParameters validParams();

  GrandPotentialAnisoInterface(const InputParameters & parameters);

protected:
  virtual void computeQpProperties();

private:
  unsigned int _num_eta;
  std::vector<const VariableValue *> _eta;
  std::vector<NonlinearVariableName> _eta_names;

  MaterialProperty<Real> & _kappa;
  MaterialProperty<Real> & _sum_val;
  MaterialProperty<RealGradient> & _dkappadgrad_etaa;
  MaterialProperty<RealTensorValue> & _d2kappadgrad_etaa;
  std::vector<MaterialProperty<Real> *> _dkappadeta;
  std::vector<std::vector<MaterialProperty<Real> *>> _d2kappadeta2;
  std::vector<MaterialProperty<RealGradient> *> _d2kappadgrad_etaa_deta;

  ///@{ Material properties for all interface pairs
  std::vector<std::vector<const MaterialProperty<Real> *>> _kappa_comp;
  std::vector<std::vector<const MaterialProperty<RealGradient> *>> _dkappadgrad_etaa_comp;
  std::vector<std::vector<const MaterialProperty<RealTensorValue> *>> _d2kappadgrad_etaa_comp;
};