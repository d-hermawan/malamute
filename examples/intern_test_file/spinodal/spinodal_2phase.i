[Mesh]
    type = GeneratedMesh
    dim = 2
    nx = 120
    ny = 120
    xmin = -5
    xmax = 5
    ymin = -5
    ymax = 5
    elem_type = QUAD4
  []
  
  [Variables]
    [./solid1]
    [../]
    [./solid2]
    [../]
    [./w]
    [../]
  []
  
  [AuxVariables]
    [./bnds]
      order = FIRST
      family = LAGRANGE
    [../]
  []
  
  [AuxKernels]
    [./bndscalc]
      type = BndsCalcAux
      variable = bnds
      execute_on = TIMESTEP_BEGIN
      v = 'solid1 solid2'
    [../]
  []
  
  [ICs]
    [./ICmu]
      type = RandomIC
      variable = w
      min = 560
      max = 575
      seed = 0
    [../]
    [./ICs2]
      type = RandomIC
      variable = solid2
      min = 0.0
      max = 0.01
      seed = 0
    [../]
    [./ICs1]
      type = RandomIC
      variable = solid1
      min = 0.99
      max = 1.0
      seed = 0
    [../]
  []
  [Materials]
    [./ha]
      type = SwitchingFunctionMultiPhaseMaterial
      all_etas = 'solid1 solid2'
      phase_etas = solid1
      h_name = ha
    [../]
    [./hb]
      type = SwitchingFunctionMultiPhaseMaterial
      all_etas = 'solid1 solid2'
      phase_etas = solid2
      h_name = hb
    [../]
    [./const]
      type = GenericConstantMaterial
      prop_names = 'caeq cbeq     kb        ka         Vm         kappa_s D    gamma mu   Ls  fa       fb         mu0'
      prop_values = '0.01 0.86399 10437.8   8795.238  1.1798e-2  3e-3    1.0e3 1.5  0.6 1.0  2428.464 1715.139  552.88856'
    [../]
    [./omegaa]
      type = DerivativeParsedMaterial
      coupled_variables = 'w'
      property_name = omegaa
      material_property_names = 'Vm ka caeq fa mu0'
      expression = '-0.5*(w-mu0)^2/(Vm^2 * ka) - (w-mu0)*caeq/Vm - fa'
      derivative_order = 2
    [../]
    [./omegab]
      type = DerivativeParsedMaterial
      coupled_variables = 'w'
      property_name = omegab
      material_property_names = 'Vm kb cbeq fb mu0'
      expression = '-0.5*(w-mu0)^2/(Vm^2 * kb) - (w-mu0)*cbeq/Vm - fb'
      derivative_order = 2
    [../]
    [./rhoa]
      type = DerivativeParsedMaterial
      coupled_variables = 'w'
      property_name = rhoa
      material_property_names = 'Vm ka caeq mu0'
      expression = '(w-mu0)/Vm^2/ka + caeq/Vm'
      derivative_order = 2
    [../]
    [./rhob]
      type = DerivativeParsedMaterial
      coupled_variables = 'w'
      property_name = rhob
      material_property_names = 'Vm kb cbeq mu0'
      expression = '(w-mu0)/Vm^2/kb + cbeq/Vm'
      derivative_order = 2
    [../]
    [./c]
      type = ParsedMaterial
      material_property_names = 'Vm rhoa rhob ha hb'
      expression = 'Vm * (ha*rhoa + hb*rhob)'
      property_name = c
      outputs = 'exodus'
    [../]
    [./chi]
      type = DerivativeParsedMaterial
      property_name = chi
      material_property_names = 'Vm ha(solid1,solid2) ka hb(solid1,solid2) kb'
      expression = '(ha/ka + hb/kb)/(Vm^2)'
      coupled_variables = 'solid1 solid2'
      derivative_order = 2
    [../]
    [./Mobility]
      type = DerivativeParsedMaterial
      property_name = Dchi
      material_property_names = 'D chi'
      expression = 'D*chi'
      derivative_order = 2
    [../]
  []
  
[Kernels]
    # solid1
    [./dt_s1]
      type = TimeDerivative
      variable = solid1
    [../]
    [./bulk_s1]
      type = ACGrGrMulti
      variable = solid1
      v =           'solid2'
      gamma_names = 'gamma'
      mob_name = Ls
    [../]
    [./sw_s1]
      type = ACSwitching
      variable = solid1
      Fj_names = 'omegaa omegab'
      hj_names = 'ha    hb'
      coupled_variables = 'w solid2'
      mob_name = Ls
    [../]
    [./int_s1]
      type = ACInterface
      variable = solid1
      kappa_name = kappa_s
      mob_name = Ls
    [../]
  
    # solid2
    [./dt_s2]
      type = TimeDerivative
      variable = solid2
    [../]
    [./bulk_s2]
      type = ACGrGrMulti
      variable = solid2
      v =           'solid1'
      gamma_names = 'gamma'
      mob_name = Ls
    [../]
    [./sw_s2]
      type = ACSwitching
      variable = solid2
      Fj_names = 'omegaa omegab'
      hj_names = 'ha    hb'
      coupled_variables = 'w solid1'
      mob_name = Ls
    [../]
    [./int_s2]
      type = ACInterface
      variable = solid2
      kappa_name = kappa_s
      mob_name = Ls
    [../]

    # chempot
    [./w_dot]
      type = SusceptibilityTimeDerivative
      variable = w
      f_name = chi
      coupled_variables = 'solid1 solid2'
    [../]
    [./Diffusion]
      type = MatDiffusion
      variable = w
      diffusivity = Dchi
    [../]
    [./coupled_s1]
      type = CoupledSwitchingTimeDerivative
      variable = w
      v = solid1
      Fj_names = 'rhoa rhob'
      hj_names = 'ha   hb'
      coupled_variables = 'solid1 solid2'
    [../]  
    [./coupled_s2]
      type = CoupledSwitchingTimeDerivative
      variable = w
      v = solid2
      Fj_names = 'rhoa rhob'
      hj_names = 'ha   hb'
      coupled_variables = 'solid1 solid2'
    [../]
  []
  [Postprocessors]
    [./conc]
      type = ElementIntegralMaterialProperty
      mat_prop = c
      outputs = csv
    [../]
  []
  
  [Preconditioning]
    [./SMP]
      type = SMP
      full = true
    [../]
  []
  
  [Executioner]
    type = Transient
    scheme = bdf2
    solve_type = PJFNK
    petsc_options_iname = '-pc_type -pc_hypre_type -ksp_gmres_restart -pc_factor_shift_type'
    petsc_options_value = 'hypre    boomeramg      31                  nonzero'
    l_tol = 1.0e-8
    l_max_its = 20
    nl_max_its = 20
    nl_rel_tol = 1.0e-7
    nl_abs_tol = 1.0e-7
    end_time = 1000000
    dtmax = 10.0
    [./TimeStepper]
        type = IterationAdaptiveDT
        dt = 0.0005
        cutback_factor = 0.8
        growth_factor = 1.2
    [../]
  []
  [Outputs]
    exodus=true
    interval = 5
    csv = true
  []
  