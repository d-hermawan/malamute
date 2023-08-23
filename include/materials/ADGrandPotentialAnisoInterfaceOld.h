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
#include "DerivativeMaterialPropertyNameInterface.h"

/**
 * Calculate Grand Potential interface parameters for a specified interfacial free energy and width.
 */
class ADGrandPotentialAnisoInterfaceOld : public ADMaterial,
                                          public DerivativeMaterialPropertyNameInterface
{
public:
  static InputParameters validParams();

  ADGrandPotentialAnisoInterfaceOld(const InputParameters & parameters);

protected:
  virtual void computeQpProperties();

private:
  /// gamma material property names
  // std::vector<MaterialPropertyName> _kappaa_names;
  // // std::vector<MaterialPropertyName> _kappab_names;
  // std::vector<MaterialPropertyName> _dkappadgrad_etaa_names;
  // // std::vector<MaterialPropertyName> _dkappadgrad_etab_names;
  // std::vector<MaterialPropertyName> _d2kappadgrad_etaa_names;
  // std::vector<MaterialPropertyName> _d2kappadgrad_etab_names;
  unsigned int _num_eta;
  std::vector<const ADVariableValue *> _eta;
  std::vector<NonlinearVariableName> _eta_names;
  // unsigned int _num_etaa;
  // std::vector<const VariableValue *> _etaa;
  // std::vector<NonlinearVariableName> _etaa_names;
  // unsigned int _num_etab;
  // std::vector<const VariableValue *> _etab;
  // std::vector<NonlinearVariableName> _etab_names;

  ADMaterialProperty<Real> & _kappa;
  ADMaterialProperty<Real> & _kappa2;
  ADMaterialProperty<Real> & _sum_val;
  ADMaterialProperty<Real> & _sum_val2;
  ADMaterialProperty<RealGradient> & _dkappadgrad_etaa;
  // MaterialProperty<RealTensorValue> & _d2kappadgrad_etaa;
  std::vector<ADMaterialProperty<Real> *> _dkappadeta;
  std::vector<ADMaterialProperty<Real> *> _dkappadeta2;
  // std::vector<std::vector<MaterialProperty<Real> *>> _d2kappadeta2;
  // std::vector<MaterialProperty<RealGradient> *> _d2kappadgrad_etaa_deta;

  ///@{ Material properties for all interface pairs
  std::vector<std::vector<const ADMaterialProperty<Real> *>> _kappa_comp;
  std::vector<std::vector<const ADMaterialProperty<RealGradient> *>> _dkappadgrad_etaa_comp;
  // std::vector<std::vector<const MaterialProperty<RealTensorValue> *>> _d2kappadgrad_etaa_comp;

  // MaterialProperty<Real> & _kappa_prop;
  // MaterialProperty<Real> & _mu_prop;
  ////@}
};