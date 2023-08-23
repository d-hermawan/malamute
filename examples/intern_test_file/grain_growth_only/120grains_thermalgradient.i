[Mesh]
    type = GeneratedMesh
    dim = 2
    xmin = 0
    xmax = 50
    ymin = 0
    ymax = 30
    nx = 75
    ny = 45
    elem_type = QUAD4
[]
[GlobalParams]
    int_width = 0.25
    op_num = 10
    var_name_base = gr
[]
[Variables]
    [./PolycrystalVariables]
    [../]
    [./liquid]
    [../]
[]
[UserObjects]
    [./voronoi]
        type = PolycrystalVoronoi
        grain_num = 90
        rand_seed = 5410
        coloring_algorithm = jp # We must use bt to force the UserObject to assign one grain to each op
    [../]
    [rosenthal]
        type = RosenthalTemperature
        thermal_conductivity = 2.7e-5
        specific_heat = 650
        density = 8e-10
        melting_temp = 1700
        ambient_temp = 300
        maximum_temp = 2100
        velocity_x = 10
        x0 = 20
        y0 = 15
        power = 3.0
    []
    [grain_tracker]
        type = GrainTracker
        threshold = 0.2
        connecting_threshold = 0.08
        compute_halo_maps = true
        remap_grains = true
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
    [./PolycrystalICs]
        [./RosenthalPolycrystalIC]
            structure_type = grains
            polycrystal_ic_uo = voronoi
            rosenthal_temperature_uo = rosenthal
        [../]
    [../]
    [./ICT]
        variable = T
        type = RosenthalPolycrystalIC
        structure_type = temperature
        rosenthal_temperature_uo = rosenthal
        polycrystal_ic_uo = voronoi
    [../]
    [./bnds]
        type = BndsCalcIC # IC is created for activating the initial adaptivity
        variable = bnds
        v = 'gr0 gr1 gr2 gr3 gr4 gr5 gr6 gr7 gr8 gr9'
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
    [unique_grains]
        order = CONSTANT
        family = MONOMIAL
    []
    [var_indices]
        order = CONSTANT
        family = MONOMIAL
    []
    [ghost_regions]
        order = CONSTANT
        family = MONOMIAL
    []
    [halos]
        order = CONSTANT
        family = MONOMIAL
    []
[]
[AuxKernels]
    [./bnds_aux]
        type = BndsCalcAux
        variable = bnds
        execute_on = TIMESTEP_BEGIN
        v = 'liquid gr0 gr1 gr2 gr3 gr4 gr5 gr6 gr7 gr8 gr9'
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
        type = SwitchingFunctionMultiPhaseMaterial
        all_etas = 'liquid gr0 gr1 gr2 gr3 gr4 gr5 gr6 gr7 gr8 gr9'
        phase_etas = liquid
        h_name = hl
    [../]
    [./hs]
        type = SwitchingFunctionMultiPhaseMaterial
        all_etas = 'liquid gr0 gr1 gr2 gr3 gr4 gr5 gr6 gr7 gr8 gr9'
        phase_etas = 'gr0 gr1 gr2 gr3 gr4 gr5 gr6 gr7 gr8 gr9'
        h_name = hs
    [../]
    [./omegal]
        type = DerivativeParsedMaterial
        coupled_variables = 'T'
        property_name = omegal
        material_property_names = 'S Tm'
        expression = '- S*(T-Tm)/Tm'
    [../]
    [./const]
        type = GenericConstantMaterial
        prop_names =  'gab mu   S     Tm   kappa Ll   Ls'
        prop_values = '1.5 12.0 1.9e3 1700 1.5   25.0 0.01'
    [../]
    [mobility]
        type = ParsedMaterial
        property_name = L
        material_property_names = 'Ls Ll'
        coupled_variables = 'liquid gr0 gr1 gr2 gr3 gr4 gr5 gr6 gr7 gr8 gr9'
        expression = 'Ls*(1- (0.5*tanh(20*((1-(gr0+gr1+gr2+gr3+gr4+gr5+gr6+gr7+gr8+gr9))-0.1)) + 0.5)) + Ll*(0.5*tanh(20*((1-(gr0+gr1+gr2+gr3+gr4+gr5+gr6+gr7+gr8+gr9))-0.1)) + 0.5)'
        outputs = 'exodus'
    []
[]
[Kernels]
    [./DT_liquid]
        type = TimeDerivative
        variable = liquid
    [../]
    [./ACInt_liquid]
        type = ACInterface
        coupled_variables = 'gr0 gr1 gr2 gr3 gr4 gr5 gr6 gr7 gr8 gr9'
        kappa_name = kappa
        mob_name = Ll
        variable = liquid
    [../]
    [./ACSwitch_liquid]
        type = ACSwitching
        Fj_names = 'omegal'
        coupled_variables = 'liquid gr0 gr1 gr2 gr3 gr4 gr5 gr6 gr7 gr8 gr9'
        hj_names = 'hl'
        mob_name = Ll
        variable = liquid
    [../]
    [./AcGrGr_liquid]
        type = ACGrGrMulti
        gamma_names = 'gab gab gab gab gab gab gab gab gab gab'
        mob_name = Ll
        v = 'gr0 gr1 gr2 gr3 gr4 gr5 gr6 gr7 gr8 gr9'
        variable = liquid
    [../]
    [./DT_gr0]
        type = TimeDerivative
        variable = gr0
    [../]
    [./ACInt_gr0]
        type = ACInterface
        coupled_variables = 'liquid gr1 gr2 gr3 gr4 gr5 gr6 gr7 gr8 gr9'
        kappa_name = kappa
        mob_name = L
        variable = gr0
    [../]
    [./ACSwitch_gr0]
        type = ACSwitching
        Fj_names = 'omegal'
        coupled_variables = 'liquid gr0 gr1 gr2 gr3 gr4 gr5 gr6 gr7 gr8 gr9'
        hj_names = 'hl'
        mob_name = L
        variable = gr0
    [../]
    [./AcGrGr_gr0]
        type = ACGrGrMulti
        gamma_names = 'gab gab gab gab gab gab gab gab gab gab'
        mob_name = L
        v = 'liquid gr1 gr2 gr3 gr4 gr5 gr6 gr7 gr8 gr9'
        variable = gr0
    [../]
    [./DT_gr1]
        type = TimeDerivative
        variable = gr1
    [../]
    [./ACInt_gr1]
        type = ACInterface
        coupled_variables = 'liquid gr0 gr2 gr3 gr4 gr5 gr6 gr7 gr8 gr9'
        kappa_name = kappa
        mob_name = L
        variable = gr1
    [../]
    [./ACSwitch_gr1]
        type = ACSwitching
        Fj_names = 'omegal'
        coupled_variables = 'liquid gr0 gr1 gr2 gr3 gr4 gr5 gr6 gr7 gr8 gr9'
        hj_names = 'hl'
        mob_name = L
        variable = gr1
    [../]
    [./AcGrGr_gr1]
        type = ACGrGrMulti
        gamma_names = 'gab gab gab gab gab gab gab gab gab gab'
        mob_name = L
        v = 'liquid gr0 gr2 gr3 gr4 gr5 gr6 gr7 gr8 gr9'
        variable = gr1
    [../]
    [./DT_gr2]
        type = TimeDerivative
        variable = gr2
    [../]
    [./ACInt_gr2]
        type = ACInterface
        coupled_variables = 'liquid gr0 gr1 gr3 gr4 gr5 gr6 gr7 gr8 gr9'
        kappa_name = kappa
        mob_name = L
        variable = gr2
    [../]
    [./ACSwitch_gr2]
        type = ACSwitching
        Fj_names = 'omegal'
        coupled_variables = 'liquid gr0 gr1 gr2 gr3 gr4 gr5 gr6 gr7 gr8 gr9'
        hj_names = 'hl'
        mob_name = L
        variable = gr2
    [../]
    [./AcGrGr_gr2]
        type = ACGrGrMulti
        gamma_names = 'gab gab gab gab gab gab gab gab gab gab'
        mob_name = L
        v = 'liquid gr0 gr1 gr3 gr4 gr5 gr6 gr7 gr8 gr9'
        variable = gr2
    [../]
    [./DT_gr3]
        type = TimeDerivative
        variable = gr3
    [../]
    [./ACInt_gr3]
        type = ACInterface
        coupled_variables = 'liquid gr0 gr1 gr2 gr4 gr5 gr6 gr7 gr8 gr9'
        kappa_name = kappa
        mob_name = L
        variable = gr3
    [../]
    [./ACSwitch_gr3]
        type = ACSwitching
        Fj_names = 'omegal'
        coupled_variables = 'liquid gr0 gr1 gr2 gr3 gr4 gr5 gr6 gr7 gr8 gr9'
        hj_names = 'hl'
        mob_name = L
        variable = gr3
    [../]
    [./AcGrGr_gr3]
        type = ACGrGrMulti
        gamma_names = 'gab gab gab gab gab gab gab gab gab gab'
        mob_name = L
        v = 'liquid gr0 gr1 gr2 gr4 gr5 gr6 gr7 gr8 gr9'
        variable = gr3
    [../]
    [./DT_gr4]
        type = TimeDerivative
        variable = gr4
    [../]
    [./ACInt_gr4]
        type = ACInterface
        coupled_variables = 'liquid gr0 gr1 gr2 gr3 gr5 gr6 gr7 gr8 gr9'
        kappa_name = kappa
        mob_name = L
        variable = gr4
    [../]
    [./ACSwitch_gr4]
        type = ACSwitching
        Fj_names = 'omegal'
        coupled_variables = 'liquid gr0 gr1 gr2 gr3 gr4 gr5 gr6 gr7 gr8 gr9'
        hj_names = 'hl'
        mob_name = L
        variable = gr4
    [../]
    [./AcGrGr_gr4]
        type = ACGrGrMulti
        gamma_names = 'gab gab gab gab gab gab gab gab gab gab'
        mob_name = L
        v = 'liquid gr0 gr1 gr2 gr3 gr5 gr6 gr7 gr8 gr9'
        variable = gr4
    [../]
    [./DT_gr5]
        type = TimeDerivative
        variable = gr5
    [../]
    [./ACInt_gr5]
        type = ACInterface
        coupled_variables = 'liquid gr0 gr1 gr2 gr3 gr4 gr6 gr7 gr8 gr9'
        kappa_name = kappa
        mob_name = L
        variable = gr5
    [../]
    [./ACSwitch_gr5]
        type = ACSwitching
        Fj_names = 'omegal'
        coupled_variables = 'liquid gr0 gr1 gr2 gr3 gr4 gr5 gr6 gr7 gr8 gr9'
        hj_names = 'hl'
        mob_name = L
        variable = gr5
    [../]
    [./AcGrGr_gr5]
        type = ACGrGrMulti
        gamma_names = 'gab gab gab gab gab gab gab gab gab gab'
        mob_name = L
        v = 'liquid gr0 gr1 gr2 gr3 gr4 gr6 gr7 gr8 gr9'
        variable = gr5
    [../]
    [./DT_gr6]
        type = TimeDerivative
        variable = gr6
    [../]
    [./ACInt_gr6]
        type = ACInterface
        coupled_variables = 'liquid gr0 gr1 gr2 gr3 gr4 gr5 gr7 gr8 gr9'
        kappa_name = kappa
        mob_name = L
        variable = gr6
    [../]
    [./ACSwitch_gr6]
        type = ACSwitching
        Fj_names = 'omegal'
        coupled_variables = 'liquid gr0 gr1 gr2 gr3 gr4 gr5 gr6 gr7 gr8 gr9'
        hj_names = 'hl'
        mob_name = L
        variable = gr6
    [../]
    [./AcGrGr_gr6]
        type = ACGrGrMulti
        gamma_names = 'gab gab gab gab gab gab gab gab gab gab'
        mob_name = L
        v = 'liquid gr0 gr1 gr2 gr3 gr4 gr5 gr7 gr8 gr9'
        variable = gr6
    [../]
    [./DT_gr7]
        type = TimeDerivative
        variable = gr7
    [../]
    [./ACInt_gr7]
        type = ACInterface
        coupled_variables = 'liquid gr0 gr1 gr2 gr3 gr4 gr5 gr6 gr8 gr9'
        kappa_name = kappa
        mob_name = L
        variable = gr7
    [../]
    [./ACSwitch_gr7]
        type = ACSwitching
        Fj_names = 'omegal'
        coupled_variables = 'liquid gr0 gr1 gr2 gr3 gr4 gr5 gr6 gr7 gr8 gr9'
        hj_names = 'hl'
        mob_name = L
        variable = gr7
    [../]
    [./AcGrGr_gr7]
        type = ACGrGrMulti
        gamma_names = 'gab gab gab gab gab gab gab gab gab gab'
        mob_name = L
        v = 'liquid gr0 gr1 gr2 gr3 gr4 gr5 gr6 gr8 gr9'
        variable = gr7
    [../]
    [./DT_gr8]
        type = TimeDerivative
        variable = gr8
    [../]
    [./ACInt_gr8]
        type = ACInterface
        coupled_variables = 'liquid gr0 gr1 gr2 gr3 gr4 gr5 gr6 gr7 gr9'
        kappa_name = kappa
        mob_name = L
        variable = gr8
    [../]
    [./ACSwitch_gr8]
        type = ACSwitching
        Fj_names = 'omegal'
        coupled_variables = 'liquid gr0 gr1 gr2 gr3 gr4 gr5 gr6 gr7 gr8 gr9'
        hj_names = 'hl'
        mob_name = L
        variable = gr8
    [../]
    [./AcGrGr_gr8]
        type = ACGrGrMulti
        gamma_names = 'gab gab gab gab gab gab gab gab gab gab'
        mob_name = L
        v = 'liquid gr0 gr1 gr2 gr3 gr4 gr5 gr6 gr7 gr9'
        variable = gr8
    [../]
    [./DT_gr9]
        type = TimeDerivative
        variable = gr9
    [../]
    [./ACInt_gr9]
        type = ACInterface
        coupled_variables = 'liquid gr0 gr1 gr2 gr3 gr4 gr5 gr6 gr7 gr8'
        kappa_name = kappa
        mob_name = L
        variable = gr9
    [../]
    [./ACSwitch_gr9]
        type = ACSwitching
        Fj_names = 'omegal'
        coupled_variables = 'liquid gr0 gr1 gr2 gr3 gr4 gr5 gr6 gr7 gr8 gr9'
        hj_names = 'hl'
        mob_name = L
        variable = gr9
    [../]
    [./AcGrGr_gr9]
        type = ACGrGrMulti
        gamma_names = 'gab gab gab gab gab gab gab gab gab gab'
        mob_name = L
        v = 'liquid gr0 gr1 gr2 gr3 gr4 gr5 gr6 gr7 gr8'
        variable = gr9
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
    l_tol = 1.0e-7
    l_max_its = 20
    nl_max_its = 20
    nl_rel_tol = 1.0e-6
    nl_abs_tol = 1e-6
    end_time = 2.25
    dtmin = 2e-9
    [./TimeStepper]
        type = IterationAdaptiveDT
        dt = 1e-6
        cutback_factor = 0.5
        growth_factor = 2.0
        optimal_iterations = 8
        iteration_window = 2
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
      coarsen = 0.2
      refine = 0.9
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
    interval=10
[]


