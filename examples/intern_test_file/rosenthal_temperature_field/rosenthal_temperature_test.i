[Mesh]
    type = GeneratedMesh
    dim = 2
    xmin = 0
    xmax = 100
    ymin = 0
    ymax = 100
    nx = 80
    ny = 80
    elem_type = QUAD4
[]
[Variables]
    [./w]
    [../]
[]
[UserObjects]
    [rosenthal]
        type = RosenthalTemperature
        thermal_conductivity = 3e-5
        specific_heat = 650
        density = 8e-9
        melting_temp = 1700
        ambient_temp = 300
        maximum_temp = 1750
        velocity_x = 10
        x0 = 0
        y0 = 50
        power = 7.5
    []
[]
[AuxVariables]
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
    [./temp_src]
        type = SpatialUserObjectAux
        variable = T
        user_object = rosenthal
    [../]
[]
[Kernels]
    [./w_dot]
        type = TimeDerivative
        variable = w
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
    end_time = 16.0
    dt = 0.1
[]
[Outputs]
    exodus=true
[]

