[Mesh]
    # generate a 2D, 1 mum x 1 mum mesh
    type = GeneratedMesh
    dim = 2
    nx = 50
    ny = 50
    # nx = 25
    # ny = 25
    xmax = 5  # 0.1 mum
    ymax = 5  # 0.1 mum
    # uniform_refine = 2
[]
  
[Variables]
    # difference in the volume fractions of the 2 phases
    [./c]
        order = FIRST
        family = LAGRANGE
        [./InitialCondition]
            type = RandomIC
            seed = 123
            min = -0.1
            max =  0.1
        [../]
    [../]
    # Chemical potential (J/mol)
    [./w]
        order = FIRST
        family = LAGRANGE
    [../]
[]

[Functions]
    # A ParsedFunction to define time dependent Mobility
    [./mobility_func]
        type = ParsedFunction
        # symbol_names = 'M0'
        # symbol_values = '1e-02'
        expression = 'exp(-0.12 * t)'
    [../]
[]

  
[AuxVariables]
    # polymer volume fraction
    [./pvf]
        # order = FIRST
        # family = LAGRANGE
    [../]
    # used to describe the exponential func to be used in ParsedMaterial
    [./mobility_temp]
    [../]
    # Local free energy density (J/mol)
    [./f_density]
        order = CONSTANT
        family = MONOMIAL
    [../]
[]
  
[Kernels]
    [./w_dot]
        type = CoupledTimeDerivative
        variable = w
        v = c
    [../]
    [./coupled_res]
        type = SplitCHWRes
        variable = w
        mob_name = M
    [../]
    [./coupled_parsed]
        type = SplitCHParsed
        variable = c
        f_name = f_loc
        kappa_name = kappa_c
        w = w
    [../]
[]
  
[AuxKernels]
    # calculate polymer volume fraction from difference in volume fractions
    [./pvf]
        type = ParsedAux
        variable = pvf
        coupled_variables = 'c'
        expression = '(c+1)/2'
    [../]
    # calculate M
    [./mobility]
        type = FunctionAux
        variable = mobility_temp
        function = 'mobility_func'
        execute_on = timestep_begin
    [../]
    # calculate energy density from local and gradient energies (J/mol/mum^2)
    [./f_density]
        type = TotalFreeEnergy
        variable = f_density
        f_name = 'f_loc'
        kappa_names = 'kappa_c'
        interfacial_vars = c
    [../]
[]
  
[BCs]
    [./Periodic]
        [./all]
        auto_direction = 'x y'
        [../]
    [../]
[]
  
[Materials]
    # Units of kappa_c are J m^2 / mol
    # consider adding a scaling factor in the future
    [./kappa]
        type = GenericConstantMaterial
        prop_names  = 'kappa_c'
        prop_values = '5e-03'  # kappa_c*eV_J*mu_m^2
    [../]
    # # Units of M are m^2 mol / (J s)
    [./mobility]
        type = ParsedMaterial
        property_name  = M
        coupled_variables = mobility_temp
        constant_names = 'M0'
        constant_expressions = '1e-02'
        expression = 'M0 * mobility_temp'  # M*mum_m^2/eV_J
    [../]
    # free energy density function (J/mol/mum^2)
    # same as in CHMath
    [./local_energy]
        type = DerivativeParsedMaterial
        property_name = f_loc
        coupled_variables = c
        constant_names = 'W1    W2'
        constant_expressions = '1/4 1/2'
        expression = 'W1*c^4 - W2*c^2'
        derivative_order = 2
    [../]
[]

[Postprocessors]
    # Calculate total free energy at each timestep
    [./total_energy]
        type = ElementIntegralVariablePostprocessor
        variable = f_density
        execute_on = 'initial timestep_end'
    [../]
[]

[Executioner]
    type = Transient
    solve_type = 'NEWTON'
    scheme = bdf2
  
    # Preconditioning using the additive Schwartz method and LU decomposition
    petsc_options_iname = '-pc_type -sub_ksp_type -sub_pc_type'
    petsc_options_value = 'asm      preonly       lu          '
  
    # # Alternative preconditioning options using Hypre (algebraic multi-grid)
    # petsc_options_iname = '-pc_type -pc_hypre_type'
    # petsc_options_value = 'hypre    boomeramg'
  
    l_tol = 1e-4
    l_max_its = 30
    nl_max_its = 30
    nl_abs_tol = 1e-9
    
    [./TimeStepper]
        # Turn on time stepping
        type = IterationAdaptiveDT
        dt = 2.0
        cutback_factor = 0.8
        growth_factor = 1.5
        optimal_iterations = 7
    [../]
  
    end_time = 200.0 # seconds

    # # Automatic scaling for c and w
    # automatic_scaling = true
    # scaling_group_variables = 'c w'
  
    [./Adaptivity]
      coarsen_fraction = 0.1
      refine_fraction = 0.7
      max_h_level = 2
    [../]
[]
  
[Outputs]
    [5_50_ad]
        type = Exodus
    []
    [5_50_ad_e]
        type = CSV
    []
[]

# [Debug]
#     show_var_residual_norms = true
# []
  