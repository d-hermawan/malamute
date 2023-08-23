[Mesh]
    type = GeneratedMesh
    dim = 2
    nx = 20
    ny = 20
    xmin = -5
    xmax = 5
    ymin = -5
    ymax = 5
    elem_type = QUAD4
    uniform_refine = 2
[]

[Variables]
    [./w]
    [../]
    [./eta0]
    [../]
    [./eta1]
    [../]
    [./eta2]
    [../]
    [./eta3]
    [../]
    [./liquid]
    [../]
[]

[GlobalParams]
    int_width = 0.1
[]

[AuxVariables]
    [./bnds]
    [../]
    [./T]
        initial_condition = -0.5
    [../]
[]

[AuxKernels]
    [./bnds]
        type = BndsCalcAux
        variable = bnds
        v = 'liquid eta0 eta1 eta2 eta3'
    [../]
[]

[ICs]
    [./eta3]
        type = SmoothCircleIC
        variable = eta3
        x1 = 2.5
        y1 = -2.5
        radius = 0.4
        outvalue = 0.0
        invalue = 1.0
    [../]
    [./eta0]
        type = SmoothCircleIC
        variable = eta0
        x1 = -2.5
        y1 = 2.5
        radius = 0.4
        outvalue = 0.0
        invalue = 1.0
    [../]
    [./eta1]
        type = SmoothCircleIC
        variable = eta1
        x1 = -2.5
        y1 = -2.5
        radius = 0.4
        outvalue = 0.0
        invalue = 1.0
    [../]
    [./eta2]
        type = SmoothCircleIC
        variable = eta2
        x1 = 2.5
        y1 = 2.5
        radius = 0.4
        outvalue = 0.0
        invalue = 1.0
    [../]
    [./liquid]
        type = SpecifiedSmoothCircleIC
        variable = liquid
        x_positions = '-2.5 -2.5 2.5 2.5'
        y_positions = '-2.5 2.5 -2.5 2.5'
        z_positions = '0 0 0 0'
        radii = '0.4 0.4 0.4 0.4'
        outvalue = 1.0
        invalue = 0.0
    [../]
    [./w]
        type = SpecifiedSmoothCircleIC
        variable = w
        x_positions = '-2.5 -2.5 2.5 2.5'
        y_positions = '-2.5 2.5 -2.5 2.5'
        z_positions = '0 0 0 0'
        radii = '0.4 0.4 0.4 0.4'
        outvalue = -4.0
        invalue = 0.0
    [../]
[]

[Materials]
    [./ha]
        type = SwitchingFunctionMultiPhaseMaterial
        h_name = ha
        all_etas = 'liquid eta0 eta1 eta2 eta3'
        phase_etas = 'eta0 eta1 eta2 eta3'
    [../]
    [./hb]
        type = SwitchingFunctionMultiPhaseMaterial
        h_name = hb
        all_etas = 'liquid eta0 eta1 eta2 eta3'
        phase_etas = 'liquid'
    [../]
    [./omegaa]
        type = DerivativeParsedMaterial
        coupled_variables = 'w'
        property_name = omegaa
        material_property_names = 'Vm ka caeq'
        expression = '-0.5*w^2/Vm^2/ka-w/Vm*caeq'
    [../]
    [./omegab]
        type = DerivativeParsedMaterial
        coupled_variables = 'w T'
        property_name = omegab
        material_property_names = 'Vm kb cbeq S Tm'
        expression = '-0.5*w^2/Vm^2/kb-w/Vm*cbeq-S*(T-Tm)'
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
        prop_names =  'L     D    chi  Vm   ka    caeq kb    cbeq  gab mu   S   Tm   kappa0'
        prop_values = '333.33 1.0  0.1  1.0  10.0  0.1  10.0  0.9   4.5 10.0 1.0 5.0 0.1'
    [../]
    [./Mobility]
        type = ParsedMaterial
        property_name = Dchi
        material_property_names = 'D chi'
        expression = 'D*chi'
    [../]
    [./kappa_liquid_eta0]
        type = InterfaceOrientationMultiphaseMaterial
        anisotropy_strength = 0.1
        d2kappadgrad_etaa_name = d2kappadgrad_liquid_eta0
        dkappadgrad_etaa_name = dkappadgrad_liquid_eta0
        etaa = liquid
        etab = eta0
        kappa_bar = 0.05
        kappa_name = kappa_liquid_eta0
        reference_angle = 0
    [../]
    [./kappa_liquid_eta1]
        type = InterfaceOrientationMultiphaseMaterial
        anisotropy_strength = 0.1
        d2kappadgrad_etaa_name = d2kappadgrad_liquid_eta1
        dkappadgrad_etaa_name = dkappadgrad_liquid_eta1
        etaa = liquid
        etab = eta1
        kappa_bar = 0.05
        kappa_name = kappa_liquid_eta1
        reference_angle = 30
    [../]
    [./kappa_liquid_eta2]
        type = InterfaceOrientationMultiphaseMaterial
        anisotropy_strength = 0.1
        d2kappadgrad_etaa_name = d2kappadgrad_liquid_eta2
        dkappadgrad_etaa_name = dkappadgrad_liquid_eta2
        etaa = liquid
        etab = eta2
        kappa_bar = 0.05
        kappa_name = kappa_liquid_eta2
        reference_angle = 45
    [../]
    [./kappa_liquid_eta3]
        type = InterfaceOrientationMultiphaseMaterial
        anisotropy_strength = 0.1
        d2kappadgrad_etaa_name = d2kappadgrad_liquid_eta3
        dkappadgrad_etaa_name = dkappadgrad_liquid_eta3
        etaa = liquid
        etab = eta3
        kappa_bar = 0.05
        kappa_name = kappa_liquid_eta3
        reference_angle = 60
    [../]
    [./kappa_eta0_liquid]
        type = InterfaceOrientationMultiphaseMaterial
        anisotropy_strength = 0.1
        d2kappadgrad_etaa_name = d2kappadgrad_eta0_liquid
        dkappadgrad_etaa_name = dkappadgrad_eta0_liquid
        etaa = eta0
        etab = liquid
        kappa_bar = 0.05
        kappa_name = kappa_eta0_liquid
        reference_angle = 0
    [../]
    [./kappa_eta0_eta1]
        type = InterfaceOrientationMultiphaseMaterial
        anisotropy_strength = 0.1
        d2kappadgrad_etaa_name = d2kappadgrad_eta0_eta1
        dkappadgrad_etaa_name = dkappadgrad_eta0_eta1
        etaa = eta0
        etab = eta1
        kappa_bar = 0.05
        kappa_name = kappa_eta0_eta1
        reference_angle = 0
    [../]
    [./kappa_eta0_eta2]
        type = InterfaceOrientationMultiphaseMaterial
        anisotropy_strength = 0.1
        d2kappadgrad_etaa_name = d2kappadgrad_eta0_eta2
        dkappadgrad_etaa_name = dkappadgrad_eta0_eta2
        etaa = eta0
        etab = eta2
        kappa_bar = 0.05
        kappa_name = kappa_eta0_eta2
        reference_angle = 0
    [../]
    [./kappa_eta0_eta3]
        type = InterfaceOrientationMultiphaseMaterial
        anisotropy_strength = 0.1
        d2kappadgrad_etaa_name = d2kappadgrad_eta0_eta3
        dkappadgrad_etaa_name = dkappadgrad_eta0_eta3
        etaa = eta0
        etab = eta3
        kappa_bar = 0.05
        kappa_name = kappa_eta0_eta3
        reference_angle = 0
    [../]
    [./kappa_eta1_liquid]
        type = InterfaceOrientationMultiphaseMaterial
        anisotropy_strength = 0.1
        d2kappadgrad_etaa_name = d2kappadgrad_eta1_liquid
        dkappadgrad_etaa_name = dkappadgrad_eta1_liquid
        etaa = eta1
        etab = liquid
        kappa_bar = 0.05
        kappa_name = kappa_eta1_liquid
        reference_angle = 30
    [../]
    [./kappa_eta1_eta0]
        type = InterfaceOrientationMultiphaseMaterial
        anisotropy_strength = 0.1
        d2kappadgrad_etaa_name = d2kappadgrad_eta1_eta0
        dkappadgrad_etaa_name = dkappadgrad_eta1_eta0
        etaa = eta1
        etab = eta0
        kappa_bar = 0.05
        kappa_name = kappa_eta1_eta0
        reference_angle = 0
    [../]
    [./kappa_eta1_eta2]
        type = InterfaceOrientationMultiphaseMaterial
        anisotropy_strength = 0.1
        d2kappadgrad_etaa_name = d2kappadgrad_eta1_eta2
        dkappadgrad_etaa_name = dkappadgrad_eta1_eta2
        etaa = eta1
        etab = eta2
        kappa_bar = 0.05
        kappa_name = kappa_eta1_eta2
        reference_angle = 0
    [../]
    [./kappa_eta1_eta3]
        type = InterfaceOrientationMultiphaseMaterial
        anisotropy_strength = 0.1
        d2kappadgrad_etaa_name = d2kappadgrad_eta1_eta3
        dkappadgrad_etaa_name = dkappadgrad_eta1_eta3
        etaa = eta1
        etab = eta3
        kappa_bar = 0.05
        kappa_name = kappa_eta1_eta3
        reference_angle = 0
    [../]
    [./kappa_eta2_liquid]
        type = InterfaceOrientationMultiphaseMaterial
        anisotropy_strength = 0.1
        d2kappadgrad_etaa_name = d2kappadgrad_eta2_liquid
        dkappadgrad_etaa_name = dkappadgrad_eta2_liquid
        etaa = eta2
        etab = liquid
        kappa_bar = 0.05
        kappa_name = kappa_eta2_liquid
        reference_angle = 45
    [../]
    [./kappa_eta2_eta0]
        type = InterfaceOrientationMultiphaseMaterial
        anisotropy_strength = 0.1
        d2kappadgrad_etaa_name = d2kappadgrad_eta2_eta0
        dkappadgrad_etaa_name = dkappadgrad_eta2_eta0
        etaa = eta2
        etab = eta0
        kappa_bar = 0.05
        kappa_name = kappa_eta2_eta0
        reference_angle = 0
    [../]
    [./kappa_eta2_eta1]
        type = InterfaceOrientationMultiphaseMaterial
        anisotropy_strength = 0.1
        d2kappadgrad_etaa_name = d2kappadgrad_eta2_eta1
        dkappadgrad_etaa_name = dkappadgrad_eta2_eta1
        etaa = eta2
        etab = eta1
        kappa_bar = 0.05
        kappa_name = kappa_eta2_eta1
        reference_angle = 0
    [../]
    [./kappa_eta2_eta3]
        type = InterfaceOrientationMultiphaseMaterial
        anisotropy_strength = 0.1
        d2kappadgrad_etaa_name = d2kappadgrad_eta2_eta3
        dkappadgrad_etaa_name = dkappadgrad_eta2_eta3
        etaa = eta2
        etab = eta3
        kappa_bar = 0.05
        kappa_name = kappa_eta2_eta3
        reference_angle = 0
    [../]
    [./kappa_eta3_liquid]
        type = InterfaceOrientationMultiphaseMaterial
        anisotropy_strength = 0.1
        d2kappadgrad_etaa_name = d2kappadgrad_eta3_liquid
        dkappadgrad_etaa_name = dkappadgrad_eta3_liquid
        etaa = eta3
        etab = liquid
        kappa_bar = 0.05
        kappa_name = kappa_eta3_liquid
        reference_angle = 60
    [../]
    [./kappa_eta3_eta0]
        type = InterfaceOrientationMultiphaseMaterial
        anisotropy_strength = 0.1
        d2kappadgrad_etaa_name = d2kappadgrad_eta3_eta0
        dkappadgrad_etaa_name = dkappadgrad_eta3_eta0
        etaa = eta3
        etab = eta0
        kappa_bar = 0.05
        kappa_name = kappa_eta3_eta0
        reference_angle = 0
    [../]
    [./kappa_eta3_eta1]
        type = InterfaceOrientationMultiphaseMaterial
        anisotropy_strength = 0.1
        d2kappadgrad_etaa_name = d2kappadgrad_eta3_eta1
        dkappadgrad_etaa_name = dkappadgrad_eta3_eta1
        etaa = eta3
        etab = eta1
        kappa_bar = 0.05
        kappa_name = kappa_eta3_eta1
        reference_angle = 0
    [../]
    [./kappa_eta3_eta2]
        type = InterfaceOrientationMultiphaseMaterial
        anisotropy_strength = 0.1
        d2kappadgrad_etaa_name = d2kappadgrad_eta3_eta2
        dkappadgrad_etaa_name = dkappadgrad_eta3_eta2
        etaa = eta3
        etab = eta2
        kappa_bar = 0.05
        kappa_name = kappa_eta3_eta2
        reference_angle = 0
    [../]
    [./GP_aniso_interface]
        type = GrandPotentialAnisoInterface
        etas = 'liquid eta0 eta1 eta2 eta3'
        output_properties = 'kappa_op dkappadgrad_etaa'
    [../]
        
[]
[Kernels]
    ### eta0 kernels ###
    [./ACa0_bulk]
        type = ACGrGrMulti
        variable = eta0
        v =           'liquid eta1 eta2 eta3'
        gamma_names = 'gab    gab  gab  gab'
    [../]
    [./ACa0_sw]
        type = ACSwitching
        variable = eta0
        Fj_names  = 'omegaa omegab'
        hj_names  = 'ha     hb'
        coupled_variables = 'liquid w T eta0 eta1 eta2 eta3'
    [../]
    [./ACa0_int1]
        type = ACInterface2DMultiPhase1
        variable = eta0
        etas = 'liquid eta1 eta2 eta3'
        kappa_name = kappa_op
        dkappadgrad_etaa_name = dkappadgrad_etaa
    [../]
    [./ACa0_int2]
        type = ACInterface
        variable = eta0
        kappa_name = kappa_op
        coupled_variables = 'liquid eta1 eta2 eta3'
    [../]
    [./eta0_kappa]
        type = ACKappaFunction
        variable = eta0
        kappa_name = kappa_op
        v = 'liquid eta0 eta1 eta2 eta3'
    [../]
    [./ea0_dot]
        type = TimeDerivative
        variable = eta0
    [../]

    ### eta1 kernels ###
    [./ACa1_bulk]
        type = ACGrGrMulti
        variable = eta1
        v =           'liquid eta0 eta2 eta3'
        gamma_names = 'gab    gab  gab  gab'
    [../]
    [./ACa1_sw]
        type = ACSwitching
        variable = eta1
        Fj_names  = 'omegaa omegab'
        hj_names  = 'ha     hb'
        coupled_variables = 'liquid w T eta0 eta1 eta2 eta3'
    [../]
    [./ACa1_int1]
        type = ACInterface2DMultiPhase1
        variable = eta1
        etas = 'liquid eta0 eta2 eta3'
        kappa_name = kappa_op
        dkappadgrad_etaa_name = dkappadgrad_etaa
    [../]
    [./ACa1_int2]
        type = ACInterface
        variable = eta1
        kappa_name = kappa_op
        coupled_variables = 'liquid eta0 eta2 eta3'
    [../]
    [./eta1_kappa]
        type = ACKappaFunction
        variable = eta1
        kappa_name = kappa_op
        v = 'liquid eta0 eta1 eta2 eta3'
    [../]
    [./ea1_dot]
        type = TimeDerivative
        variable = eta1
    [../]

    ### eta2 kernels ###
    [./ACa2_bulk]
        type = ACGrGrMulti
        variable = eta2
        v =           'liquid eta0 eta1 eta3'
        gamma_names = 'gab    gab  gab  gab'
    [../]
    [./ACa2_sw]
        type = ACSwitching
        variable = eta2
        Fj_names  = 'omegaa omegab'
        hj_names  = 'ha     hb'
        coupled_variables = 'liquid w T eta0 eta1 eta2 eta3'
    [../]
    [./ACa2_int1]
        type = ACInterface2DMultiPhase1
        variable = eta2
        etas = 'liquid eta0 eta1 eta3'
        kappa_name = kappa_op
        dkappadgrad_etaa_name = dkappadgrad_etaa
    [../]
    [./ACa2_int2]
        type = ACInterface
        variable = eta2
        kappa_name = kappa_op
        coupled_variables = 'liquid eta0 eta1 eta3'
    [../]
    [./eta2_kappa]
        type = ACKappaFunction
        variable = eta2
        kappa_name = kappa_op
        v = 'liquid eta0 eta1 eta2 eta3'
    [../]
    [./ea2_dot]
        type = TimeDerivative
        variable = eta2
    [../]

    ### eta3 kernels ###
    [./ACa3_bulk]
        type = ACGrGrMulti
        variable = eta3
        v =           'liquid eta0 eta1 eta2'
        gamma_names = 'gab    gab  gab  gab'
    [../]
    [./ACa3_sw]
        type = ACSwitching
        variable = eta3
        Fj_names  = 'omegaa omegab'
        hj_names  = 'ha     hb'
        coupled_variables = 'liquid w T eta0 eta1 eta2 eta3'
    [../]
    [./ACa3_int1]
        type = ACInterface2DMultiPhase1
        variable = eta3
        etas = 'liquid eta0 eta1 eta2'
        kappa_name = kappa_op
        dkappadgrad_etaa_name = dkappadgrad_etaa
    [../]
    [./ACa3_int2]
        type = ACInterface
        variable = eta3
        kappa_name = kappa_op
        coupled_variables = 'liquid eta0 eta1 eta2'
    [../]
    [./eta3_kappa]
        type = ACKappaFunction
        variable = eta3
        kappa_name = kappa_op
        v = 'liquid eta0 eta1 eta2 eta3'
    [../]
    [./ea3_dot]
        type = TimeDerivative
        variable = eta3
    [../]

    ### liquid kernels ###
    [./ACliq_bulk]
        type = ACGrGrMulti
        variable = liquid
        v =           'eta0 eta1 eta2 eta3'
        gamma_names = 'gab  gab  gab  gab'
    [../]
    [./ACliq_sw]
        type = ACSwitching
        variable = liquid
        Fj_names  = 'omegaa omegab'
        hj_names  = 'ha     hb'
        coupled_variables = 'liquid w T eta0 eta1 eta2 eta3'
    [../]
    [./ACliq_int1]
        type = ACInterface2DMultiPhase1
        variable = liquid
        etas = 'eta0 eta1 eta2 eta3'
        kappa_name = kappa_op
        dkappadgrad_etaa_name = dkappadgrad_etaa
    [../]
    [./ACliq_int2]
        type = ACInterface
        variable = liquid
        kappa_name = kappa_op
        coupled_variables = 'eta0 eta1 eta2 eta3'
    [../]
    [./liquid_kappa]
        type = ACKappaFunction
        variable = liquid
        kappa_name = kappa_op
        v = 'liquid eta0 eta1 eta2 eta3'
    [../]
    [./liq_dot]
        type = TimeDerivative
        variable = liquid
    [../]

    ### chem pot kernels
    [./w_dot]
        type = SusceptibilityTimeDerivative
        variable = w
        f_name = chi
    [../]
    [./Diffusion]
        type = MatDiffusion
        variable = w
        diffusivity = Dchi
    [../]
    [./coupled_eta1dot]
        type = CoupledSwitchingTimeDerivative
        variable = w
        v = eta1
        Fj_names = 'rhoa rhob'
        hj_names = 'ha   hb'
        coupled_variables = 'liquid eta0 eta1 eta2 eta3'
    [../]
    [./coupled_eta2dot]
        type = CoupledSwitchingTimeDerivative
        variable = w
        v = eta2
        Fj_names = 'rhoa rhob'
        hj_names = 'ha   hb'
        coupled_variables = 'liquid eta0 eta1 eta2 eta3'
    [../]
    [./coupled_eta0dot]
        type = CoupledSwitchingTimeDerivative
        variable = w
        v = eta0
        Fj_names = 'rhoa rhob'
        hj_names = 'ha   hb'
        coupled_variables = 'liquid eta0 eta1 eta2 eta3'
    [../]
    [./coupled_eta3dot]
        type = CoupledSwitchingTimeDerivative
        variable = w
        v = eta3
        Fj_names = 'rhoa rhob'
        hj_names = 'ha   hb'
        coupled_variables = 'liquid eta0 eta1 eta2 eta3'
    [../]
    [./coupled_liquiddot]
        type = CoupledSwitchingTimeDerivative
        variable = w
        v = liquid
        Fj_names = 'rhoa rhob'
        hj_names = 'ha   hb'
        coupled_variables = 'liquid eta0 eta1 eta2 eta3'
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
    petsc_options_value = 'hypre    boomeramg      31 nonzero'
    l_tol = 1.0e-3
    l_max_its = 20
    nl_max_its = 20
    nl_rel_tol = 1.0e-8
    nl_abs_tol = 1e-8
    end_time = 20.0
    [./TimeStepper]
        type = IterationAdaptiveDT
        dt = 0.0005
        cutback_factor = 0.8
        growth_factor = 1.1
    [../]
[]
[Adaptivity]
    initial_steps = 5
    max_h_level = 3
    initial_marker = err_liq
    marker = err_bnds
    [./Markers]
        [./err_liq]
            type = ErrorFractionMarker
            coarsen = 0.3
            refine = 0.95
            indicator = ind_liquid
        [../]
        [./err_bnds]
            type = ErrorFractionMarker
            coarsen = 0.3
            refine = 0.95
            indicator = ind_bnds
        [../]
    [../]
    [./Indicators]
        [./ind_liquid]
            type = GradientJumpIndicator
            variable = liquid
        [../]
        [./ind_bnds]
            type = GradientJumpIndicator
            variable = bnds
        [../]
    [../]
[]
[Outputs]
    exodus=true
[]