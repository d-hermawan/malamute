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
        v = 'eta0 eta2 eta1 eta3'
    [../]
[]

[ICs]
    [./eta0]
        type = SmoothCircleIC
        variable = eta0
        x1 = 0
        y1 = -2.5
        radius = 2.0
        invalue = 1.0
        outvalue = 0.0
    [../]
    [./eta1]
        type = SmoothCircleIC
        variable = eta1
        x1 = 2.5
        y1 = 2.5
        radius = 2.0
        invalue = 1.0
        outvalue = 0.0
    [../]
    [./eta2]
        type = SmoothCircleIC
        variable = eta2
        x1 = -2.5
        y1 = 2.5
        radius = 2.0
        invalue = 1.0
        outvalue = 0.0
    [../]
    [./eta3]
        type = SpecifiedSmoothCircleIC
        variable = eta3
        x_positions = '-2.5 0.0  2.5'
        y_positions = '2.5  -2.5 2.5'
        z_positions = '0 0 0'
        radii = '2.0 2.0 2.0'
        outvalue = 1.0
        invalue = 0.0
    [../]
    [./w]
        type = SpecifiedSmoothCircleIC
        variable = w
        x_positions = '-2.5 0.0  2.5'
        y_positions = '2.5  -2.5 2.5'
        z_positions = '0 0 0'
        radii = '2.0 2.0 2.0'
        outvalue = -4.0
        invalue = 0.0
    [../]
    [./bndsIC]
        type = BndsCalcIC
        variable = bnds
        v = 'eta0 eta1 eta2 eta3'
    [../]
[]

[Materials]
    [./ha]
        type = SwitchingFunctionMultiPhaseMaterial
        h_name = ha
        all_etas = 'eta0 eta1 eta2 eta3'
        phase_etas = 'eta0 eta1 eta2'
    [../]
    [./hb]
        type = SwitchingFunctionMultiPhaseMaterial
        h_name = hb
        all_etas = 'eta0 eta1 eta2 eta3'
        phase_etas = 'eta3'
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
        prop_names =  'L     D    chi  Vm   ka    caeq kb    cbeq  gab mu   S   Tm   kappa_op'
        prop_values = '333.33 1.0  0.1  1.0  10.0  0.1  10.0  0.9   4.5 10.0 1.0 5.0 0.1'
    [../]
    [./Mobility]
        type = ParsedMaterial
        property_name = Dchi
        material_property_names = 'D chi'
        expression = 'D*chi'
    [../]
[]
[Kernels]
    [./ACa0_bulk]
        type = ACGrGrMulti
        variable = eta0
        v =           'eta2 eta1 eta3'
        gamma_names = 'gab gab gab'
    [../]
    [./ACa0_sw]
        type = ACSwitching
        variable = eta0
        Fj_names  = 'omegaa omegab'
        hj_names  = 'ha     hb'
        coupled_variables = 'eta1 eta2 eta3 w T'
    [../]
    [./eta0_kappa]
        type = ACInterface
        variable = eta0
        kappa_name = kappa_op
        coupled_variables = 'eta1 eta2 eta3'
    [../]
    [./ea0_dot]
        type = TimeDerivative
        variable = eta0
    [../]

    [./ACa1_bulk]
        type = ACGrGrMulti
        variable = eta1
        v =           'eta0 eta2 eta3'
        gamma_names = 'gab gab gab'
    [../]
    [./ACa1_sw]
        type = ACSwitching
        variable = eta1
        Fj_names  = 'omegaa omegab'
        hj_names  = 'ha     hb'
        coupled_variables = 'eta0 eta2 eta3 w T'
    [../]
    [./eta1_kappa]
        type = ACInterface
        variable = eta1
        kappa_name = kappa_op
        coupled_variables = 'eta0 eta2 eta3'
    [../]
    [./ea1_dot]
        type = TimeDerivative
        variable = eta1
    [../]

    [./ACa2_bulk]
        type = ACGrGrMulti
        variable = eta2
        v =           'eta0 eta1 eta3'
        gamma_names = 'gab gab gab'
    [../]
    [./ACa2_sw]
        type = ACSwitching
        variable = eta2
        Fj_names  = 'omegaa omegab'
        hj_names  = 'ha     hb'
        coupled_variables = 'eta0 eta1 eta3 w T'
    [../]
    [./eta2_kappa]
        type = ACInterface
        variable = eta2
        kappa_name = kappa_op
        coupled_variables = 'eta0 eta1 eta3'
    [../]
    [./ea2_dot]
        type = TimeDerivative
        variable = eta2
    [../]

    [./ACa3_bulk]
        type = ACGrGrMulti
        variable = eta3
        v =           'eta0 eta1 eta2'
        gamma_names = 'gab gab gab'
    [../]
    [./ACa3_sw]
        type = ACSwitching
        variable = eta3
        Fj_names  = 'omegaa omegab'
        hj_names  = 'ha     hb'
        args = 'eta1 w T'
    [../]
    [./eta3_kappa]
        type = ACInterface
        variable = eta3
        kappa_name = kappa_op
        coupled_variables = 'eta0 eta1 eta2'
    [../]
    [./ea3_dot]
        type = TimeDerivative
        variable = eta3
    [../]

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
    [./coupled_eta0dot]
        type = CoupledSwitchingTimeDerivative
        variable = w
        v = eta0
        Fj_names = 'rhoa rhob'
        hj_names = 'ha   hb'
        coupled_variables = 'eta0 eta1 eta2 eta3'
    [../]
    [./coupled_eta1dot]
        type = CoupledSwitchingTimeDerivative
        variable = w
        v = eta1
        Fj_names = 'rhoa rhob'
        hj_names = 'ha   hb'
        coupled_variables = 'eta0 eta1 eta2 eta3'
    [../]
    [./coupled_eta12ot]
        type = CoupledSwitchingTimeDerivative
        variable = w
        v = eta2
        Fj_names = 'rhoa rhob'
        hj_names = 'ha   hb'
        coupled_variables = 'eta0 eta1 eta2 eta3'
    [../]
    [./coupled_eta3dot]
        type = CoupledSwitchingTimeDerivative
        variable = w
        v = eta3
        Fj_names = 'rhoa rhob'
        hj_names = 'ha   hb'
        coupled_variables = 'eta0 eta1 eta2 eta3'
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
    l_tol = 1.0e-7
    l_max_its = 20
    nl_max_its = 20
    nl_rel_tol = 1.0e-6
    nl_abs_tol = 1e-6
    end_time = 5.0

    [./TimeStepper]
        type = IterationAdaptiveDT
        dt = 1e-6
        cutback_factor = 0.8
        growth_factor = 1.2
    [../]
[]
[Adaptivity]
    initial_steps = 5
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
    interval=2
[]