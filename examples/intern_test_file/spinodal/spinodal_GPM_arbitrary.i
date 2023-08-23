[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 80
  ny = 80
  xmin = -5
  xmax = 5
  ymin = -5
  ymax = 5
  elem_type = QUAD4
[]

[Variables]
  [./liquid]
  [../]
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
  [./conc]
    family = MONOMIAL
    order = CONSTANT
  [../]
[]

[GlobalParams]
  int_width = 1.0
[]

[AuxKernels]
  [./bndscalc]
    type = BndsCalcAux
    variable = bnds
    execute_on = TIMESTEP_BEGIN
    v = 'solid1 solid2 liquid'
  [../]
  [./concaux]
    type = MaterialRealAux
    variable = conc
    property = c
    execute_on = 'LINEAR TIMESTEP_END'
  [../]
[]

[ICs]
  [./ICsol]
    type = SmoothCircleIC
    variable = solid1
    x1 = 0
    y1 = 0
    radius = 10.0
    invalue = 1.0
    outvalue = 0.0
  [../]
  [./ICmu]
    type = RandomIC
    variable = w
    min = 0.4
    max = 0.6
    seed = 0
  [../]
[]

[Materials]
  [./hl]
    type = SwitchingFunctionMultiPhaseMaterial
    all_etas = 'liquid solid1 solid2'
    phase_etas = liquid
    h_name = hl
  [../]
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
  [./hs]
    type = SwitchingFunctionMultiPhaseMaterial
    all_etas = 'liquid solid1 solid2'
    phase_etas = 'solid1 solid2'
    h_name = hs
  [../]
  [./hsa]
    type = DerivativeParsedMaterial
    coupled_variables = 'liquid solid1 solid2'
    material_property_names = 'ha hs'
    expression = 'hs*ha'
    property_name = hsa
  [../]
  [./hsb]
    type = DerivativeParsedMaterial
    coupled_variables = 'liquid solid1 solid2'
    material_property_names = 'hb hs'
    expression = 'hs*hb'
    property_name = hsb
  [../]
  [./const]
    type = GenericConstantMaterial
    prop_names = 'caeq cbeq cleq ka  kb  kl  Vm  kappa_s kappa_l Ll    D   gamma mu Ls'
    prop_values = '0.1  0.9  0.5 1.0 1.0 5.0 1.0 1.0     0.5     10.0 1.0 1.5   1.0 1.0'
  [../]
  [./omegaa]
    type = DerivativeParsedMaterial
    coupled_variables = 'w'
    property_name = omegaa
    material_property_names = 'Vm ka caeq'
    expression = '-0.5*w^2/(Vm^2 * ka) - w*caeq/Vm'
    derivative_order = 2
  [../]
  [./omegab]
    type = DerivativeParsedMaterial
    coupled_variables = 'w'
    property_name = omegab
    material_property_names = 'Vm kb cbeq'
    expression = '-0.5*w^2/(Vm^2 * kb) - w*cbeq/Vm'
    derivative_order = 2
  [../]
  [./omegal]
    type = DerivativeParsedMaterial
    coupled_variables = 'w'
    property_name = omegal
    material_property_names = 'Vm kl cleq'
    expression = '-0.5*w^2/(Vm^2 * kl) - w*cleq/Vm'
    derivative_order = 2
  [../]
  [./rhoa]
    type = DerivativeParsedMaterial
    coupled_variables = 'w'
    property_name = rhoa
    material_property_names = 'Vm ka caeq'
    expression = 'w/Vm^2/ka + caeq/Vm'
    derivative_order = 2
  [../]
  [./rhob]
    type = DerivativeParsedMaterial
    coupled_variables = 'w'
    property_name = rhob
    material_property_names = 'Vm kb cbeq'
    expression = 'w/Vm^2/kb + cbeq/Vm'
    derivative_order = 2
  [../]
  [./rhol]
    type = DerivativeParsedMaterial
    coupled_variables = 'w'
    property_name = rhol
    material_property_names = 'Vm kl cleq'
    expression = 'w/Vm^2/kl + cleq/Vm'
    derivative_order = 2
  [../]
  [./c]
    type = ParsedMaterial
    material_property_names = 'Vm rhoa rhob rhol hsa hsb hl'
    expression = 'Vm * (hsa*rhoa + hsb*rhob + hl*rhol)'
    property_name = c
  [../]
  [./chi]
    type = DerivativeParsedMaterial
    property_name = chi
    material_property_names = 'Vm hsa(liquid,solid1,solid2) ka hsb(liquid,solid1,solid2) kb hl(liquid,solid1,solid2) kl'
    expression = '(hsa/ka + hsb/kb + hl/kl)/(Vm^2)'
    coupled_variables = 'liquid solid1 solid2'
    derivative_order = 2
  [../]
  [./Mobility]
    type = DerivativeParsedMaterial
    property_name = Dchi
    material_property_names = 'D chi'
    expression = 'D*chi'
    derivative_order = 2
  [../]
  [./doublewell]
    
  [../]
[]

[Kernels]
  # liquid
  [./dt_liq]
    type = TimeDerivative
    variable = liquid
  [../]
  [./bulk_liq]
    type = ACGrGrMulti
    variable = liquid
    v =           'solid1 solid2'
    gamma_names = 'gamma  gamma'
    mob_name = Ll
  [../]
  [./sw_liq]
    type = ACSwitching
    variable = liquid
    Fj_names = 'omegal omegaa omegab'
    hj_names = 'hl     hsa    hsb'
    coupled_variables = 'w solid1 solid2'
    mob_name = Ll
  [../]
  [./int_liq]
    type = ACInterface
    variable = liquid
    kappa_name = kappa_l
    mob_name = Ll
  [../]

  # solid1
  [./dt_s1]
    type = TimeDerivative
    variable = solid1
  [../]
  [./bulk_s1]
    type = ACGrGrMulti
    variable = solid1
    v =           'liquid solid2'
    gamma_names = 'gamma  gamma'
    mob_name = Ls
  [../]
  [./sw_s1]
    type = ACSwitching
    variable = solid1
    Fj_names = 'omegal omegaa omegab'
    hj_names = 'hl     hsa    hsb'
    coupled_variables = 'w liquid solid2'
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
    v =           'liquid solid1'
    gamma_names = 'gamma  gamma'
    mob_name = Ls
  [../]
  [./sw_s2]
    type = ACSwitching
    variable = solid2
    Fj_names = 'omegal omegaa omegab'
    hj_names = 'hl     hsa    hsb'
    coupled_variables = 'w liquid solid1'
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
    coupled_variables = 'liquid solid1 solid2'
  [../]
  [./Diffusion]
    type = MatDiffusion
    variable = w
    diffusivity = Dchi
  [../]
  [./coupled_liq]
    type = CoupledSwitchingTimeDerivative
    variable = w
    v = liquid
    Fj_names = 'rhoa rhob rhol'
    hj_names = 'hsa   hsb   hl'
    coupled_variables = 'solid1 solid2 liquid'
  [../]
  [./coupled_s1]
    type = CoupledSwitchingTimeDerivative
    variable = w
    v = solid1
    Fj_names = 'rhoa rhob rhol'
    hj_names = 'hsa   hsb   hl'
    coupled_variables = 'solid1 solid2 liquid'
  [../]  
  [./coupled_s2]
    type = CoupledSwitchingTimeDerivative
    variable = w
    v = solid2
    Fj_names = 'rhoa rhob rhol'
    hj_names = 'hsa   hsb   hl'
    coupled_variables = 'solid1 solid2 liquid'
  [../]
[]

[Postprocessors]
  [./conc]
    type = ElementIntegralVariablePostprocessor
    variable = conc
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


