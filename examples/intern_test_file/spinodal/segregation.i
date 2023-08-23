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
  [./solid1]
  [../]
  [./solid2]
  [../]
  [./w]
    initial_condition = 0.05
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
  [./ICsol1]
    type = BoundingBoxIC
    x1 = -10
    x2 = 0.0
    y1 = -10
    y2 = 10
    inside = 1.0
    outside = 0.0
    variable = solid1
    int_width = 0.1
  [../]
  [./ICsol2]
    type = BoundingBoxIC
    x1 = -10
    x2 = 0.0
    y1 = -10
    y2 = 10
    inside = 0.0
    outside = 1.0
    variable = solid2
    int_width = 0.1
  [../]
  [./ICbnds]
    type = BndsCalcIC
    v = 'solid1 solid2'
    variable = bnds
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
  [./hl]
    type = DerivativeParsedMaterial
    coupled_variables = 'solid1 solid2'
    expression = '(1-solid1-solid2)^2 / (solid1^2 + solid2^2)'
    derivative_order = 2
    property_name = hl
    outputs = 'exodus'
  [../]
  [./const]
    type = GenericConstantMaterial
    prop_names = 'caeq cbeq cleq ka  kb  kl  Vm  kappa_s kappa_l Ll    D   gamma mu Ls  '
    prop_values = '0.1  0.1  0.9 1.0 1.0 1.0 1.0 0.1     0.5     10.0 10.0 1.5   1.0 0.1'
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
    material_property_names = 'Vm rhoa rhob rhol ha hb hl'
    expression = 'Vm * (ha*rhoa + hb*rhob + hl*rhol)'
    property_name = c
    outputs = 'exodus'
  [../]
  [./chi]
    type = DerivativeParsedMaterial
    property_name = chi
    material_property_names = 'Vm ha(solid1) ka hb(solid2) kb kl hl(solid1,solid2)'
    expression = '(ha/ka + hb/kb + hl/kl)/(Vm^2)'
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
    Fj_names = 'omegal omegaa omegab'
    hj_names = 'hl     ha     hb'
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
    Fj_names = 'omegal omegaa omegab'
    hj_names = 'hl     ha     hb'
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
    Fj_names = 'rhoa rhob rhol' 
    hj_names = 'ha   hb   hl'
    coupled_variables = 'solid1 solid2'
  [../]  
  [./coupled_s2]
    type = CoupledSwitchingTimeDerivative
    variable = w
    v = solid2
    Fj_names = 'rhoa rhob rhol' 
    hj_names = 'ha   hb   hl'
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
  end_time = 100
  dtmax = 2.0
  [./TimeStepper]
      type = IterationAdaptiveDT
      dt = 0.0005
      cutback_factor = 0.8
      growth_factor = 1.2
  [../]
[]
[Adaptivity]
  initial_steps = 3
  max_h_level = 3
  initial_marker = err_bnds
  marker = err_bnds
 [./Markers]
    [./err_bnds]
      type = ErrorFractionMarker
      coarsen = 0.3
      refine = 0.95
      indicator = ind_bnds
    [../]
  [../]
  [./Indicators]
     [./ind_bnds]
       type = GradientJumpIndicator
       variable = bnds
    [../]
  [../]
[]
[Outputs]
  exodus=true
  interval = 1
  csv = true
[]


