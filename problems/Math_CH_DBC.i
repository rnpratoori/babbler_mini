[Mesh]
  type = GeneratedMesh
  dim = 2
  # nx = 100
  # ny = 100
  nx = 25
  ny = 25
  xmax = 10  # mum
  ymax = 10  # mum
  uniform_refine = 2
[]

[Variables]
  [./c]
    order = THIRD
    family = HERMITE
    [./InitialCondition]
      type = RandomIC
      seed = 123
      min = -0.1
      max =  0.1
    [../]
  [../]
[]

[AuxVariables]
  [./pvf]
    order = FIRST
    family = LAGRANGE
  [../]
[]

[Kernels]
  [./c_dot]
    type = TimeDerivative
    variable = c
  [../]
  [./CHbulk]
    type = CHMath
    variable = c
  [../]
  [./CHint]
    type = CHInterface
    variable = c
    mob_name = M
    kappa_name = kappa_c
  [../]
[]

[AuxKernels]
  [./pvf]
    type = CHEAux
    variable = pvf
    coupled = c
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
  [./mat]
    # Units of M are m^2 mol / (J s)
    # Units of kappa_c are J m^2 / mol
    type = GenericConstantMaterial
    prop_names  = 'M   kappa_c'
    prop_values = '1e-01
                   5e-02'
                  # M*mum_m^2/eV_J
                  # kappa_c*eV_J*mu_m^2
  [../]
[]

# [Postprocessors]
#   [./top]
#     type = SideIntegralVariablePostprocessor
#     variable = c
#     boundary = top
#   [../]
# []

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

  end_time = 80.0 # seconds

  [./Adaptivity]
    coarsen_fraction = 0.1
    refine_fraction = 0.7
    max_h_level = 2
  [../]
[]

[Outputs]
  exodus = true
[]
