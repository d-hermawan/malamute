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
    [./liquid]
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
  []
  
  [AuxKernels]
    [./bndscalc]
      type = BndsCalcAux
      variable = bnds
      execute_on = TIMESTEP_BEGIN
      v = 'solid1 solid2 liquid'
    [../]
  []

  [Functions]
    [./mu_init]
      type = ParsedFunction
      expression = '-9.07277160e-24 * x^8 + 6.54829086e-20 * x^7 -1.75990977e-16 * x^6 + 1.78776216e-13 * x^5 + 8.25534452e-11 * x^4 -3.79889026e-07 * x^3 + 3.77395516e-04 * x^2 -1.71115386e-01 * x + 3.19768681e1'
    [../]
  []
  
  [ICs]
    [./ICmu]
      type = CoupledValueFunctionIC
      variable = w
      v = 'T'
      function = mu_init
    [../]
    [./ICs2]
      type = RandomIC
      variable = solid2
      min = 0.0
      max = 1e-3
      seed = 0
    [../]
    [./ICl]
      type = RandomIC
      variable = liquid
      min = 0.0
      max = 1e-3
      seed = 0
    [../]
    [./ICs1]
      type = RandomIC
      variable = solid1
      min = 0.999
      max = 1.0
      seed = 0
    [../]
    [./IC_T]
      type = RampIC
      value_left = 301
      value_right = 1749
      variable = T
    [../]
  []
  [Materials]
    [./ha]
      type = SwitchingFunctionMultiPhaseMaterial
      all_etas = 'solid1 solid2 liquid'
      phase_etas = solid1
      h_name = ha
    [../]
    [./hl]
      type = SwitchingFunctionMultiPhaseMaterial
      all_etas = 'solid1 solid2 liquid'
      phase_etas = liquid
      h_name = hl
    [../]
    [./hb]
      type = SwitchingFunctionMultiPhaseMaterial
      all_etas = 'solid1 solid2 liquid'
      phase_etas = solid2
      h_name = hb
    [../]
    [./const]
      type = GenericConstantMaterial
      prop_names = 'Vm         kappa_s  gamma mu   Ls  f0          S     Tm'
      prop_values = '1.1798e-2 3e-3      1.5  0.6  1.0 1.41044e-2 1.9e2  1660'
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
      expression = 'flmin-0.5*(w)^2/(Vm^2 * kl) - (w)*cleq/Vm - S*(T-Tm)/Tm'
      outputs = 'exodus'
      derivative_order = 2
    [../]
    [./omegaa]
      type = DerivativeParsedMaterial
      coupled_variables = 'w'
      property_name = omegaa
      material_property_names = 'Vm ka caeq fa'
      expression = 'fa-0.5*(w)^2/(Vm^2 * ka) - (w)*caeq/Vm'
      derivative_order = 2
      outputs = 'exodus'
    [../]
    [./omegab]
      type = DerivativeParsedMaterial
      coupled_variables = 'w'
      property_name = omegab
      material_property_names = 'Vm kb cbeq fb'
      expression = 'fb-0.5*(w)^2/(Vm^2 * kb) - (w)*cbeq/Vm'
      derivative_order = 2
    [../]
    [./rhoa]
      type = DerivativeParsedMaterial
      coupled_variables = 'w'
      property_name = rhoa
      material_property_names = 'Vm ka caeq'
      expression = '(w)/Vm^2/ka + caeq/Vm'
      derivative_order = 2
    [../]
    [./rhob]
      type = DerivativeParsedMaterial
      coupled_variables = 'w'
      property_name = rhob
      material_property_names = 'Vm kb cbeq'
      expression = '(w)/Vm^2/kb + cbeq/Vm'
      derivative_order = 2
    [../]
    [./rhol]
      type = DerivativeParsedMaterial
      coupled_variables = 'w'
      property_name = rhol
      material_property_names = 'Vm kl cleq'
      expression = 'w/Vm^2/kl + cleq/Vm'
    [../]
    [./c]
      type = ParsedMaterial
      material_property_names = 'Vm rhoa rhob ha hb hl rhol'
      expression = 'Vm * (ha*rhoa + hb*rhob + hl*rhol)'
      property_name = c
      outputs = 'exodus'
    [../]
    [./chi]
      type = DerivativeParsedMaterial
      property_name = chi
      material_property_names = 'Vm ha(solid1,solid2,liquid) ka hb(solid1,solid2,liquid) kb hl(solid1,solid2,liquid) kl'
      expression = '(ha/ka + hb/kb + hl/kl)/(Vm^2)'
      coupled_variables = 'solid1 solid2 liquid'
      derivative_order = 2
    [../]
    [./Mobility]
      type = DerivativeParsedMaterial
      property_name = Dchi
      material_property_names = 'D chi'
      expression = 'D*chi'
      derivative_order = 2
    [../]
    [./Diffusivity]
      type = DerivativeParsedMaterial
      property_name = D
      coupled_variables = 'T'
      constant_names = 'R Q D0'
      constant_expressions = '8.314 2540 3.73e0'
      expression = 'D0'
      outputs = 'exodus'
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
      v =           'solid2 liquid'
      gamma_names = 'gamma  gamma'
      mob_name = Ls
    [../]
    [./sw_s1]
      type = ACSwitching
      variable = solid1
      Fj_names = 'omegaa omegab omegal'
      hj_names = 'ha    hb      hl'
      coupled_variables = 'w solid2 liquid'
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
      v =           'solid1 liquid'
      gamma_names = 'gamma  gamma'
      mob_name = Ls
    [../]
    [./sw_s2]
      type = ACSwitching
      variable = solid2
      Fj_names = 'omegaa omegab omegal'
      hj_names = 'ha    hb      hl'
      coupled_variables = 'w solid1 liquid'
      mob_name = Ls
    [../]
    [./int_s2]
      type = ACInterface
      variable = solid2
      kappa_name = kappa_s
      mob_name = Ls
    [../]

    # liquid
    [./dt_l]
      type = TimeDerivative
      variable = liquid
    [../]
    [./bulk_l]
      type = ACGrGrMulti
      variable = liquid
      v =           'solid1 solid2'
      gamma_names = 'gamma gamma'
      mob_name = Ls
    [../]
    [./sw_l]
      type = ACSwitching
      variable = liquid
      Fj_names = 'omegaa omegab omegal'
      hj_names = 'ha    hb      hl'
      coupled_variables = 'w solid1 solid2'
      mob_name = Ls
    [../]
    [./int_l]
      type = ACInterface
      variable = liquid
      kappa_name = kappa_s
      mob_name = Ls
    [../]

    # chempot
    [./w_dot]
      type = SusceptibilityTimeDerivative
      variable = w
      f_name = chi
      coupled_variables = 'solid1 solid2 liquid'
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
      coupled_variables = 'solid1 solid2 liquid'
    [../]  
    [./coupled_s2]
      type = CoupledSwitchingTimeDerivative
      variable = w
      v = solid2
      Fj_names = 'rhoa rhob rhol'
      hj_names = 'ha   hb   hl'
      coupled_variables = 'solid1 solid2 liquid'
    [../]
    [./coupled_l]
      type = CoupledSwitchingTimeDerivative
      variable = w
      v = liquid
      Fj_names = 'rhoa rhob rhol'
      hj_names = 'ha   hb   hl'
      coupled_variables = 'solid1 solid2 liquid'
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
    end_time = 100.0
    dtmax = 5.0
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

  []

  