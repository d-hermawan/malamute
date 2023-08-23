[Mesh]
    type = GeneratedMesh
    dim = 2
    xmin = 0
    xmax = 20
    ymin = -10
    ymax = 10
    nx = 60
    ny = 60
    elem_type = QUAD4
[]
[GlobalParams]
    int_width = 0.5
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
    [./alphaP]
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
        ambient_temp = 301
        maximum_temp = 1749
        velocity = 1
        x0 = 16.5
        y0 = 0
        power = 1.25
    []
[]
[Functions]
    [./mu_init]
        type = ParsedFunction
        expression = '((1-y)^2 / ((1-y)^2+y^2))*(-5.46824437e-23 * x^8 + 3.97937242e-19 * x^7 -1.04529669e-15 * x^6 + 8.77608544e-13 * x^5 + 1.14536368e-09 * x^4 -3.29493919e-06* x^3 + 3.10402981e-03 * x^2 -1.38894100 * x + 2.60099280e2) + (y^2 / ((1-y)^2+y^2))*(2.03970141e-20* x^6 + 1.14681635e-16 * x^5 -1.02557016e-12 * x^4 + 1.49736487e-09 * x^3 + 8.56011467e-07 * x^2 -6.21570376e-03 * x -1.27632598)'
    [../]
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
    [./ICs2]
        type = RandomIC
        variable = alphaP
        min = 0.0
        max = 1e-3
        seed = 227
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
    [../]
    [./ICmu]
        type = CoupledValueFunctionIC
        variable = w
        v = 'T liquid'
        function = mu_init
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
        v = 'liquid gr0 gr1 alphaP'
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
        all_etas = 'liquid gr0 gr1 alphaP'
        phase_etas = liquid
        h_name = hl
    [../]
    [./hs]
        type = SwitchingFunctionMultiPhaseMaterial
        all_etas = 'liquid gr0 gr1 alphaP'
        phase_etas = 'gr0 gr1'
        h_name = hs
    [../]
    [./hb]
        type = SwitchingFunctionMultiPhaseMaterial
        all_etas = 'liquid gr0 gr1 alphaP'
        phase_etas = 'alphaP'
        h_name = hb
    [../]
    [./fb]
        type = DerivativeParsedMaterial
        coupled_variables = 'T'
        property_name = fb
        material_property_names = 'f0'
        expression = 'f0*(3.7764e-18 * T^8 - 2.96356e-14 * T^7 + 9.749787e-11 * T^6 - 1.742299e-7 * T^5 + 1.83132e-4 * T^4 - 1.14643e-1 * T^3 + 41.4747 * T^2 - 7.962166e3 * T + 6.22088e5)'
        derivative_order = 2
    [../]
    [./fa]
        type = DerivativeParsedMaterial
        coupled_variables = 'T'
        property_name = fa
        material_property_names = 'f0'
        expression = 'f0*(-2.415701e-2 * T^2 - 28.6509 * T + 3039.1823)'
    [../]
    [./cleq]
        type = DerivativeParsedMaterial
        coupled_variables = 'T'
        expression = '-1.10536e-14 * T^4 + 6.422986e-11 * T^3 - 1.3224e-7 * T^2 + 1.1140698e-4 * T + 2.207596e-1'
        property_name = cleq
    [../]
    [./kl]
        type = DerivativeParsedMaterial
        coupled_variables = 'T'
        property_name = kl
        material_property_names = 'f0'
        expression = 'f0*(1.732598e-10 * T^2 + 33.341399*T + 2.04982e4)'
    [../]
    [./flmin]
        type = DerivativeParsedMaterial
        coupled_variables = 'T'
        property_name = flmin
        material_property_names = 'f0'
        expression = 'f0*(-1.9051889e-2 * T^2 - 4.9181521e1 * T + 2.346546e4)'
        [../]
    [./kb]
        type = DerivativeParsedMaterial
        coupled_variables = 'T'
        property_name = kb
        material_property_names = 'f0'
        expression = 'f0*(-5.46144e-19 * T^8 + 4.3007e-15 * T^7 -1.421366e-11 * T^6 + 2.55611e-8 * T^5 -2.711836e-5 * T^4 + 1.72276e-2 * T^3 -6.388146 * T^2 + 1.305527e3 * T - 4.801219e4)'
    [../]
    [./cbeq]
        type = DerivativeParsedMaterial
        coupled_variables = 'T'
        property_name = cbeq
        expression = '(5.517e-24 * T^8 -4.285e-20 * T^7 + 1.39198e-16 * T^6 - 2.4488e-13 * T^5 + 2.5248e-10 * T^4 -1.54588e-7 * T^3 + 5.49038e-5 * T^2 -1.09283e-2 * T + 1.933744)'
    [../]
    [./caeq]
        type = DerivativeParsedMaterial
        coupled_variables = 'T'
        property_name = caeq
        expression = '(-4.36830167e-24 * T^8 + 3.68478740e-20 * T^7 -1.31266627e-16 * T^6 + 2.56267661e-13 * T^5 -2.97162093e-10 * T^4 + 2.06861234e-07 * T^3 -8.29441699e-05 * T^2 +1.73856876e-02 * T -1.46210058)'
    [../]
    [./ka]
        type = DerivativeParsedMaterial
        coupled_variables = 'T'
        property_name = ka
        material_property_names = 'f0'
        expression = 'f0*(-3.05400443e-18 * T^8 + 2.51841355e-14 * T^7 -8.71341849e-11 * T^6 + 1.63580318e-07 * T^5 - 1.79412118e-04 * T^4 + 1.14421308e-01 * T^3 -3.88928915e1*T^2 + 5238.70125*T + 1.4803932e5)'
    [../]
    [./omegal]
        type = DerivativeParsedMaterial
        coupled_variables = 'w T'
        property_name = omegal
        material_property_names = 'Vm kl cleq S Tm flmin'
        expression = '(-0.5*w^2/Vm^2/kl)-w/Vm*cleq - S*(T-Tm)/Tm + flmin'
    [../]
    [./omegaa]
        type = DerivativeParsedMaterial
        coupled_variables = 'w T'
        property_name = omegaa
        material_property_names = 'Vm ka caeq fa'
        expression = '(-0.5*w^2/Vm^2/ka-w/Vm*caeq + fa)'
    [../]
    [./omegab]
        type = DerivativeParsedMaterial
        coupled_variables = 'w T'
        property_name = omegab
        material_property_names = 'Vm kb cbeq fb'
        expression = '(-0.5*w^2/Vm^2/kb-w/Vm*cbeq + fb)'
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
        material_property_names = 'Vm ka caeq'
        expression = 'w/Vm^2/ka + caeq/Vm'
    [../]
    [./rhob]
        type = DerivativeParsedMaterial
        coupled_variables = 'w'
        property_name = rhob
        material_property_names = 'Vm kb cbeq'
        expression = 'w/Vm^2/kb + cbeq/Vm'
    [../]
    [./const]
        type = GenericConstantMaterial
        prop_names =  'Vm         gab mu   S     Tm   kappa Ll     Ls   f0          kppa_cr  Lcr  '
        prop_values = '1.1798e-2  1.5 12.0 1.9e3 1660 1.5   25.3   0.01 1.41044e-1  3.85e-5 0.01 '
    [../]
    [./Mobility]
        type = ParsedMaterial
        property_name = Dchi
        material_property_names = 'D chi'
        expression = 'D*chi'
    [../]
    [./solid_diffusivity]
        type = DerivativeParsedMaterial
        property_name = Ds
        coupled_variables = 'T'
        constant_names = 'R Q D0'
        constant_expressions = '8.314 210000 3.73e5'
        expression = 'D0*exp(-Q/(R*T))'
    [../]
    [./diffusivity]
        type = ParsedMaterial
        property_name = D
        coupled_variables = 'T liquid gr0 gr1 alphaP'
        material_property_names = 'Ds'
        expression = 'Ds*(1- (0.5*tanh(20*((1-(gr0+gr1+alphaP))-0.1)) + 0.5)) + 1000*Ds*(0.5*tanh(20*((1-(gr0+gr1+alphaP))-0.1)) + 0.5)'
    [../]
    [./chi]
        type = DerivativeParsedMaterial
        property_name = chi
        material_property_names = 'Vm hl(liquid,gr0,gr1,alphaP) kl hs(liquid,gr0,gr1,alphaP) ka kb hb(liquid,gr0,gr1,alphaP)'
        expression = '(hs/ka + hb/kb + hl/kl)/(Vm^2)'
        coupled_variables = 'liquid gr0 gr1 alphaP'
        derivative_order = 2
    [../]
    [mobility]
        type = ParsedMaterial
        property_name = L
        material_property_names = 'Ls Ll temp_change'
        coupled_variables = 'liquid gr0 gr1 alphaP'
        expression = 'Ls*(1- (0.5*tanh(20*((1-(gr0+gr1+alphaP))-0.1)) + 0.5)) + Ll*(0.5*tanh(20*((1-(gr0+gr1+alphaP))-0.1)) + 0.5)*temp_change'
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
        material_property_names = 'hl hs cleq caeq kl ka Vm kb hb cbeq'
        coupled_variables = 'w'
        expression = 'hl*(w/Vm/kl + cleq) + hs*(w/Vm/ka + caeq) + hb*(w/Vm/kb + cbeq)'
        outputs = 'exodus'
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
        v =           'liquid gr1 alphaP'
        gamma_names = 'gab    gab gab'
        mob_name = L
    [../]
    [./sw_gr0]
        type = ACSwitching
        variable = gr0
        Fj_names = 'omegal omegaa omegab'
        hj_names = 'hl     hs     hb'
        coupled_variables = 'w liquid gr1 alphaP'
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
        v =           'liquid gr0 alphaP'
        gamma_names = 'gab    gab gab'
        mob_name = L
    [../]
    [./sw_gr1]
        type = ACSwitching
        variable = gr1
        Fj_names = 'omegal omegaa omegab'
        hj_names = 'hl     hs     hb'
        coupled_variables = 'w liquid gr0 alphaP'
        mob_name = L
    [../]
    [./int_gr1]
        type = ACInterface
        variable = gr1
        kappa_name = kappa
        mob_name = L
    [../]
    # alphaP
    [./dt_aP]
        type = TimeDerivative
        variable = alphaP
    [../]
    [./bulk_aP]
        type = ACGrGrMulti
        variable = alphaP
        v =           'liquid gr0 gr1'
        gamma_names = 'gab    gab gab'
        mob_name = Lcr
        
    [../]
    [./sw_aP]
        type = ACSwitching
        variable = alphaP
        Fj_names = 'omegal omegaa omegab'
        hj_names = 'hl     hs     hb'
        coupled_variables = 'w liquid gr0 gr1'
        mob_name = Lcr
    [../]
    [./int_aP]
        type = ACInterface
        variable = alphaP
        kappa_name = kappa
        mob_name = Lcr
    [../]

    # liquid
    [./dt_liq]
        type = TimeDerivative
        variable = liquid
    [../]
    [./bulk_liq]
        type = ACGrGrMulti
        variable = liquid
        v =           'gr1 gr0 alphaP'
        gamma_names = 'gab gab gab'
        mob_name = Ll
    [../]
    [./sw_liq]
        type = ACSwitching
        variable = liquid
        Fj_names = 'omegal omegaa omegab'
        hj_names = 'hl     hs     hb'
        coupled_variables = 'w gr1 gr0 alphaP'
        mob_name = Ll
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
        coupled_variables = 'liquid gr0 gr1 alphaP'
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
        Fj_names = 'rhol rhoa rhob'
        hj_names = 'hl   hs   hb'
        coupled_variables = 'liquid gr0 gr1 alphaP'
    [../]  
    [./coupled_gr1]
        type = CoupledSwitchingTimeDerivative
        variable = w
        v = gr1
        Fj_names = 'rhol rhoa rhob'
        hj_names = 'hl   hs   hb'
        coupled_variables = 'liquid gr0 gr1 alphaP'
    [../]
    [./coupled_liquid]
        type = CoupledSwitchingTimeDerivative
        variable = w
        v = liquid
        Fj_names = 'rhol rhoa rhob'
        hj_names = 'hl   hs   hb'
        coupled_variables = 'liquid gr0 gr1 alphaP'
    [../]
    [./coupled_alphaP]
        type = CoupledSwitchingTimeDerivative
        variable = w
        v = alphaP
        Fj_names = 'rhol rhoa rhob'
        hj_names = 'hl   hs   hb'
        coupled_variables = 'liquid gr0 gr1 alphaP'
    [../]
[]

[BCs]
    [./Periodic]
        [./all]
            variable = 'gr0 gr1 liquid'
            auto_direction = 'x'
        [../]
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
    end_time = 10.0
    [./TimeStepper]
        type = IterationAdaptiveDT
        dt = 5e-6
        cutback_factor = 0.5
        growth_factor = 1.41
        optimal_iterations = 8
        iteration_window = 2
    [../]
[]
[Adaptivity]
  initial_steps = 2
  max_h_level = 2
  marker = err_bnds
 [./Markers]
    [./err_bnds]
      type = ErrorFractionMarker
      coarsen = 0.15
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
    interval=10
[]

