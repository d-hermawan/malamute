[Mesh]
  type = GeneratedMesh
  dim = 2
  xmin = 0
  xmax = 20
  ymin = -10
  ymax = 10
  nx = 40
  ny = 40
  elem_type = QUAD4
[]
[GlobalParams]
  int_width = 0.125
  op_num = 2
  var_name_base = gr
[]
[Variables]
  [./PolycrystalVariables]
  [../]
  [./w]
  [../]
  [./liquid]
  [../]
[]
[UserObjects]
  [./voronoi]
      type = PolycrystalVoronoi
      grain_num = 2
      rand_seed = 227
      coloring_algorithm = bt # We must use bt to force the UserObject to assign one grain to each op
  [../]
  [rosenthal]
      type = RosenthalTemperature
      thermal_conductivity = 3e-5
      specific_heat = 650
      density = 8e-9
      melting_temp = 1700
      ambient_temp = 300
      maximum_temp = 1750
      velocity = 1
      x0 = 10
      y0 = 0
      power = 1.5
  []
[]
[ICs]
  [./bubble_IC]
      variable = liquid
      invalue = 1.0
      outvalue = 0.0
      type = RosenthalPolycrystalIC
      structure_type = voids
      rosenthal_temperature_uo = rosenthal
      polycrystal_ic_uo = voronoi
  [../]
  [./c_IC]
      variable = w
      invalue = 0.0
      outvalue = 0
      type = RosenthalPolycrystalIC
      structure_type = voids
      rosenthal_temperature_uo = rosenthal
      polycrystal_ic_uo = voronoi
  [../]
  [./PolycrystalICs]
      [./RosenthalPolycrystalIC]
          structure_type = grains
          polycrystal_ic_uo = voronoi
          rosenthal_temperature_uo = rosenthal
      [../]
  [../]
  [./bnds]
      type = BndsCalcIC # IC is created for activating the initial adaptivity
      variable = bnds
  [../]
[]
[AuxVariables]
  [./bnds]
      order = FIRST
      family = LAGRANGE
  [../]
  [./T]
      order = FIRST
      family = LAGRANGE
  [../]
  [./dTdt]
      order = CONSTANT
      family = MONOMIAL
  [../]
[]
[AuxKernels]
  [./bnds_aux]
      type = BndsCalcAux
      variable = bnds
      execute_on = TIMESTEP_BEGIN
      v = 'liquid gr0 gr1'
  [../]
  [./temp_src]
      type = SpatialUserObjectAux
      variable = T
      user_object = rosenthal
  [../]
  [./temp_deriv]
      type = TimeDerivativeAux
      variable = dTdt
      functor = T
  [../]
[]
[Materials]
  [./hl]
      type = DerivativeParsedMaterial
      coupled_variables = 'liquid gr0 gr1'
      property_name = hl
      expression = '(liquid^3 * (20 - 45*liquid + 36*liquid^2 - 10*liquid^3)) / ((liquid^3 * (20 - 45*liquid + 36*liquid^2 - 10*liquid^3))+(gr0^3 * (20 - 45*gr0 + 36*gr0^2 - 10*gr0^3))+(gr1^3 * (20 - 45*gr1 + 36*gr1^2 - 10*gr1^3)))'
  [../]
  [./h0]
      type = DerivativeParsedMaterial
      coupled_variables = 'liquid gr0 gr1'
      property_name = h0
      expression = '(gr0^3 * (20 - 45*gr0 + 36*gr0^2 - 10*gr0^3)) / ((liquid^3 * (20 - 45*liquid + 36*liquid^2 - 10*liquid^3))+(gr0^3 * (20 - 45*gr0 + 36*gr0^2 - 10*gr0^3))+(gr1^3 * (20 - 45*gr1 + 36*gr1^2 - 10*gr1^3)))'
  [../]
  [./h1]
      type = DerivativeParsedMaterial
      coupled_variables = 'liquid gr0 gr1'
      property_name = h1
      expression = '(gr1^3 * (20 - 45*gr1 + 36*gr1^2 - 10*gr1^3)) / ((liquid^3 * (20 - 45*liquid + 36*liquid^2 - 10*liquid^3))+(gr0^3 * (20 - 45*gr0 + 36*gr0^2 - 10*gr0^3)) + (gr1^3 * (20 - 45*gr1 + 36*gr1^2 - 10*gr1^3)))'
  [../]
  [./omegal]
      type = DerivativeParsedMaterial
      coupled_variables = 'w T'
      property_name = omegal
      material_property_names = 'Vm kl cleq S Tm'
      expression = '(-0.5*w^2/Vm^2/kl)-w/Vm*cleq - S*(T-Tm)/Tm'
  [../]
  [./omegaa]
      type = DerivativeParsedMaterial
      coupled_variables = 'w T'
      property_name = omegaa
      material_property_names = 'Vm ks_a cseq_a'
      expression = '(-0.5*w^2/Vm^2/ks_a-w/Vm*cseq_a)'
  [../]
  [./rhol]
      type = DerivativeParsedMaterial
      coupled_variables = 'w'
      property_name = rhol
      material_property_names = 'Vm kl cleq'
      expression = 'w/Vm^2/kl + cleq/Vm'
  [../]
  [./rhoa]
      type = DerivativeParsedMaterial
      coupled_variables = 'w'
      property_name = rhoa
      material_property_names = 'Vm ks_a cseq_a'
      expression = 'w/Vm^2/ks_a + cseq_a/Vm'
  [../]
  [./const]
      type = GenericConstantMaterial
      prop_names =  'Vm         gab mu    S         Tm   kappa  Ll    Ls   D   ks_a kl   cleq cseq_a'
      prop_values = '1.1798e-2  1.5 1.0   0.15833e3 1660 0.125  15.35 0.15 1.0 10.0 10.0 1.0  0.0'
  [../]
  [./Mobility]
      type = ParsedMaterial
      property_name = Dchi
      material_property_names = 'D chi'
      expression = 'D*chi'
  [../]
  [./chi]
      type = DerivativeParsedMaterial
      property_name = chi
      material_property_names = 'Vm hl(liquid,gr0,gr1) kl h0(liquid,gr0,gr1) ks_a h1(liquid,gr0,gr1)'
      expression = '(h0/ks_a + h1/ks_a + hl/kl)/(Vm^2)'
      coupled_variables = 'liquid gr0 gr1'
      derivative_order = 2
  [../]
  [mobility]
      type = ParsedMaterial
      property_name = L
      material_property_names = 'Ls Ll temp_change'
      coupled_variables = 'liquid gr0 gr1'
      expression = 'Ls*(1- (0.5*tanh(20*((1-(gr0+gr1))-0.1)) + 0.5)) + Ll*(0.5*tanh(20*((1-(gr0+gr1))-0.1)) + 0.5)*temp_change'
  []
  [tempchange]
      type = DerivativeParsedMaterial
      property_name = temp_change
      coupled_variables = 'dTdt'
      expression = '0.5*tanh(10*dTdt)+1.5'
      derivative_order = 1
  []
  [./conc]
      type = ParsedMaterial
      material_property_names = 'hl h0 cleq cseq_a kl ks_a Vm h1'
      coupled_variables = 'w'
      expression = 'hl*(w/Vm/kl + cleq) + h0*(w/Vm/ks_a + cseq_a)+ h1*(w/Vm/ks_a + cseq_a)'
      property_name = c
  [../]
[]

[Kernels]
  # solid0
  [./dt_gr0]
      type = TimeDerivative
      variable = gr0
  [../]
  [./bulk_gr0]
      type = ACGrGrMulti
      variable = gr0
      v =           'liquid gr1'
      gamma_names = 'gab    gab'
      mob_name = L
  [../]
  [./sw_gr0]
      type = ACSwitching
      variable = gr0
      Fj_names = 'omegal omegaa omegaa'
      hj_names = 'hl     h0     h1'
      coupled_variables = 'w liquid gr1'
      mob_name = L
  [../]
  [./int_gr0]
      type = ACInterface
      variable = gr0
      kappa_name = kappa
      mob_name = L
  [../]
  # solid1
  [./dt_gr1]
      type = TimeDerivative
      variable = gr1
  [../]
  [./bulk_gr1]
      type = ACGrGrMulti
      variable = gr1
      v =           'liquid gr0'
      gamma_names = 'gab    gab'
      mob_name = L
  [../]
  [./sw_gr1]
      type = ACSwitching
      variable = gr1
      Fj_names = 'omegal omegaa omegaa'
      hj_names = 'hl     h0     h1'
      coupled_variables = 'w liquid gr0'
      mob_name = L
  [../]
  [./int_gr1]
      type = ACInterface
      variable = gr1
      kappa_name = kappa
      mob_name = L
  [../]

  # liquid
  [./dt_liq]
      type = TimeDerivative
      variable = liquid
  [../]
  [./bulk_liq]
      type = ACGrGrMulti
      variable = liquid
      v =           'gr1 gr0'
      gamma_names = 'gab gab'
      mob_name = L
  [../]
  [./sw_liq]
      type = ACSwitching
      variable = liquid
      Fj_names = 'omegal omegaa omegaa'
      hj_names = 'hl     h0     h1'
      coupled_variables = 'w gr1 gr0'
      mob_name = L
  [../]
  [./int_liq]
      type = ACInterface
      variable = liquid
      kappa_name = kappa
      mob_name = Ll
  [../]

  # chempot
  [./w_dot]
      type = SusceptibilityTimeDerivative
      variable = w
      f_name = chi
      coupled_variables = 'liquid gr0 gr1'
  [../]
  [./Diffusion]
      type = MatDiffusion
      variable = w
      diffusivity = Dchi
  [../]
  [./coupled_gr0]
      type = CoupledSwitchingTimeDerivative
      variable = w
      v = gr0
      Fj_names = 'rhol rhoa'
      hj_names = 'hl   hs  '
      coupled_variables = 'liquid gr0 gr1'
  [../]  
  [./coupled_gr1]
      type = CoupledSwitchingTimeDerivative
      variable = w
      v = gr1
      Fj_names = 'rhol rhoa rhoa'
      hj_names = 'hl   h0   h1'
      coupled_variables = 'liquid gr0 gr1'
  [../]
  [./coupled_liquid]
      type = CoupledSwitchingTimeDerivative
      variable = w
      v = liquid
      Fj_names = 'rhol rhoa rhoa'
      hj_names = 'hl   h0   h1'
      coupled_variables = 'liquid gr0 gr1'
  [../]
[]

[Preconditioning]
  [./SMP]
      type = SMP
      full = true
  [../]
[]

[Debug]
  show_var_residual_norms = true
[]

[Executioner]
  type = Transient
  scheme = bdf2
  solve_type = PJFNK
  petsc_options_iname = '-pc_type -pc_hypre_type -ksp_gmres_restart -pc_factor_shift_type'
  petsc_options_value = 'hypre    boomeramg      31                  nonzero'
  l_tol = 1.0e-7
  l_max_its = 20
  nl_max_its = 20
  nl_rel_tol = 1.0e-6
  nl_abs_tol = 1e-6
  end_time = 1.0
  [./TimeStepper]
      type = IterationAdaptiveDT
      dt = 5e-6
      cutback_factor = 0.5
      growth_factor = 2.0
      optimal_iterations = 8
      iteration_window = 2
  [../]
[]
[Adaptivity]
initial_steps = 4
max_h_level = 4
marker = err_bnds
[./Markers]
  [./err_bnds]
    type = ErrorFractionMarker
    coarsen = 0.2
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
  interval=5
[]