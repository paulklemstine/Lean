# Master Theorem Catalog

A comprehensive catalog of all Lean 4 formalizations in this project,
organized by mathematical domain. Duplicates have been identified and removed.
All files have been copied into the `Catalog/` directory with a clean 2-level hierarchy,
imports updated to use `Catalog.*` module paths, and the Catalog registered as a build target.

## Project Statistics

| Metric | Count |
|--------|-------|
| Total Lean files | 1075 |
| Unique files (after dedup) | 1024 |
| Duplicate file groups | 33 |
| Duplicate files removed | 51 |
| Total declarations | 24509 |
| Theorems & lemmas | 18705 |
| Definitions | 4957 |
| Structures/classes/inductives | 843 |
| Total lines of Lean code | 212,535 |
| Remaining `sorry` count | 49 |
| Consolidated categories | 75 |

## Table of Contents

- [Algebra/Advanced](#algebraadvanced) — 3 files, 78 declarations
- [Algebra/DivisionAlgebras](#algebradivisionalgebras) — 11 files, 374 declarations
- [Algebra/Foundations](#algebrafoundations) — 8 files, 101 declarations
- [Algebra/LinearAlgebra](#algebralinearalgebra) — 3 files, 44 declarations
- [Algebra/RepresentationTheory](#algebrarepresentationtheory) — 4 files, 42 declarations
- [Analysis](#analysis) — 12 files, 105 declarations
- [Best](#best) — 13 files, 334 declarations
- [Bridges](#bridges) — 33 files, 876 declarations
- [CategoryTheory](#categorytheory) — 8 files, 94 declarations
- [Combinatorics](#combinatorics) — 8 files, 76 declarations
- [ComplexityTheory](#complexitytheory) — 8 files, 175 declarations
- [Computation/Factoring](#computationfactoring) — 32 files, 805 declarations
- [Computation/Fibonacci](#computationfibonacci) — 3 files, 53 declarations
- [Computation/OctonionGates](#computationoctoniongates) — 2 files, 66 declarations
- [Computation/Oracles](#computationoracles) — 81 files, 1985 declarations
- [Cryptography/Core](#cryptographycore) — 1 files, 44 declarations
- [Cryptography/Ethereum](#cryptographyethereum) — 13 files, 171 declarations
- [Cryptography/Factoring](#cryptographyfactoring) — 7 files, 85 declarations
- [Cryptography/QuantumSecurity](#cryptographyquantumsecurity) — 11 files, 373 declarations
- [Cryptography/ZeroKnowledge](#cryptographyzeroknowledge) — 3 files, 47 declarations
- [EML](#eml) — 59 files, 1353 declarations
- [FutureResearch](#futureresearch) — 48 files, 839 declarations
- [Geometry/PAdic](#geometrypadic) — 1 files, 38 declarations
- [Geometry/SphericalUniverse](#geometrysphericaluniverse) — 5 files, 121 declarations
- [Geometry/Stereographic](#geometrystereographic) — 37 files, 808 declarations
- [InformationTheory](#informationtheory) — 15 files, 283 declarations
- [Logic](#logic) — 66 files, 1341 declarations
- [MachineLearning/Consciousness](#machinelearningconsciousness) — 6 files, 60 declarations
- [MachineLearning/Neural](#machinelearningneural) — 8 files, 261 declarations
- [MachineLearning/Prediction](#machinelearningprediction) — 21 files, 269 declarations
- [MachineLearning/QuantumTransformer](#machinelearningquantumtransformer) — 10 files, 145 declarations
- [MachineLearning/ShefferFunction](#machinelearningshefferfunction) — 5 files, 66 declarations
- [NeuralCompilation](#neuralcompilation) — 4 files, 77 declarations
- [NumberTheory/Core](#numbertheorycore) — 18 files, 229 declarations
- [NumberTheory/Diophantine](#numbertheorydiophantine) — 3 files, 35 declarations
- [NumberTheory/Factoring](#numbertheoryfactoring) — 4 files, 55 declarations
- [NumberTheory/IntegerEnergy](#numbertheoryintegerenergy) — 1 files, 37 declarations
- [NumberTheory/RiemannHypothesis](#numbertheoryriemannhypothesis) — 1 files, 14 declarations
- [Physics/AlgebraicPhysics](#physicsalgebraicphysics) — 11 files, 275 declarations
- [Physics/ArchitectureOfReality](#physicsarchitectureofreality) — 5 files, 84 declarations
- [Physics/ArithmeticPhotons](#physicsarithmeticphotons) — 19 files, 670 declarations
- [Physics/Classical](#physicsclassical) — 20 files, 683 declarations
- [Physics/Quantum](#physicsquantum) — 33 files, 1067 declarations
- [Physics/Spacetime](#physicsspacetime) — 3 files, 61 declarations
- [Physics/TheoryOfEverything](#physicstheoryofeverything) — 1 files, 52 declarations
- [Probability](#probability) — 7 files, 53 declarations
- [Pythagorean/Agents](#pythagoreanagents) — 4 files, 100 declarations
- [Pythagorean/Applications](#pythagoreanapplications) — 4 files, 174 declarations
- [Pythagorean/Core](#pythagoreancore) — 34 files, 1020 declarations
- [Pythagorean/Frameworks](#pythagoreanframeworks) — 2 files, 90 declarations
- [Pythagorean/GravitationalFactoring](#pythagoreangravitationalfactoring) — 5 files, 115 declarations
- [Pythagorean/HyperbolicFactoring](#pythagoreanhyperbolicfactoring) — 3 files, 135 declarations
- [Pythagorean/InverseTree](#pythagoreaninversetree) — 4 files, 122 declarations
- [Pythagorean/LatticeTree](#pythagoreanlatticetree) — 9 files, 152 declarations
- [Pythagorean/ModularForms](#pythagoreanmodularforms) — 6 files, 474 declarations
- [Pythagorean/QDF](#pythagoreanqdf) — 6 files, 220 declarations
- [Pythagorean/Quadruples](#pythagoreanquadruples) — 13 files, 347 declarations
- [Pythagorean/Research](#pythagoreanresearch) — 15 files, 287 declarations
- [Pythagorean/ThreeRoads](#pythagoreanthreeroads) — 5 files, 144 declarations
- [Pythagorean/TreeFactoring](#pythagoreantreefactoring) — 11 files, 409 declarations
- [ShefferAI](#shefferai) — 5 files, 79 declarations
- [Speculative/ArithmeticUniverse](#speculativearithmeticuniverse) — 5 files, 36 declarations
- [Speculative/Consciousness](#speculativeconsciousness) — 7 files, 122 declarations
- [Speculative/Forbidden](#speculativeforbidden) — 11 files, 95 declarations
- [Speculative/IdempotentCollapse](#speculativeidempotentcollapse) — 14 files, 187 declarations
- [Speculative/Millennium](#speculativemillennium) — 6 files, 87 declarations
- [Speculative/Other](#speculativeother) — 76 files, 1949 declarations
- [Speculative/RosettaStone](#speculativerosettastone) — 15 files, 244 declarations
- [Speculative/RudyRucker](#speculativerudyrucker) — 5 files, 40 declarations
- [Speculative/SciFi](#speculativescifi) — 21 files, 121 declarations
- [Topology](#topology) — 11 files, 121 declarations
- [Tropical/Core](#tropicalcore) — 24 files, 824 declarations
- [Tropical/Cryptography](#tropicalcryptography) — 5 files, 176 declarations
- [Tropical/Langlands](#tropicallanglands) — 17 files, 409 declarations
- [Tropical/NeuralNetworks](#tropicalneuralnetworks) — 6 files, 335 declarations

---

## Duplicate Files Report

Found **33 groups** of exact-duplicate files (51 redundant copies removed).
For each group, the first file listed is the canonical copy retained in `Catalog/`.

**Group** (3 copies):
  - `Best/09_CayleyDicksonHierarchy.lean` ✓ (canonical)
  - `Algebra/DivisionAlgebras/CayleyDickson.lean` ✗ (duplicate)
  - `Books/TRIANGLESWALLOWEDUNIVERSE/lean/09_CayleyDicksonHierarchy.lean` ✗ (duplicate)

**Group** (3 copies):
  - `Pythagorean/Core/CoreFormalization.lean` ✓ (canonical)
  - `Best/01_BerggrenLorentzCorrespondence.lean` ✗ (duplicate)
  - `Books/TRIANGLESWALLOWEDUNIVERSE/lean/01_BerggrenLorentzCorrespondence.lean` ✗ (duplicate)

**Group** (3 copies):
  - `Best/02_LatticeTreeCorrespondence.lean` ✓ (canonical)
  - `Pythagorean/LatticeTree/CoreTheorems.lean` ✗ (duplicate)
  - `Books/TRIANGLESWALLOWEDUNIVERSE/lean/02_LatticeTreeCorrespondence.lean` ✗ (duplicate)

**Group** (3 copies):
  - `Best/03_HyperbolicShortcutsFactoring.lean` ✓ (canonical)
  - `Pythagorean/HyperbolicFactoring/HyperbolicFactoring.lean` ✗ (duplicate)
  - `Books/TRIANGLESWALLOWEDUNIVERSE/lean/03_HyperbolicShortcutsFactoring.lean` ✗ (duplicate)

**Group** (3 copies):
  - `Best/04_ThreeRoadsFromPythagoras.lean` ✓ (canonical)
  - `Pythagorean/ThreeRoads/Foundations.lean` ✗ (duplicate)
  - `Books/TRIANGLESWALLOWEDUNIVERSE/lean/04_ThreeRoadsFromPythagoras.lean` ✗ (duplicate)

**Group** (3 copies):
  - `Best/05_BerggrenLorentzPaperProofs.lean` ✓ (canonical)
  - `Pythagorean/Berggren/BerggrenLorentzPaper.lean` ✗ (duplicate)
  - `Books/TRIANGLESWALLOWEDUNIVERSE/lean/05_BerggrenLorentzPaperProofs.lean` ✗ (duplicate)

**Group** (3 copies):
  - `Best/06_HigherKTupleFactoring.lean` ✓ (canonical)
  - `Pythagorean/Quadruples/HigherKTupleFactoring.lean` ✗ (duplicate)
  - `Books/TRIANGLESWALLOWEDUNIVERSE/lean/06_HigherKTupleFactoring.lean` ✗ (duplicate)

**Group** (3 copies):
  - `Best/07_QuantumGroverTreeFactoring.lean` ✓ (canonical)
  - `Pythagorean/InverseTree/QuantumGrover.lean` ✗ (duplicate)
  - `Books/TRIANGLESWALLOWEDUNIVERSE/lean/07_QuantumGroverTreeFactoring.lean` ✗ (duplicate)

**Group** (3 copies):
  - `Best/08_ComplexityBoundsProven.lean` ✓ (canonical)
  - `Pythagorean/LatticeTree/ComplexityBounds.lean` ✗ (duplicate)
  - `Books/TRIANGLESWALLOWEDUNIVERSE/lean/08_ComplexityBoundsProven.lean` ✗ (duplicate)

**Group** (3 copies):
  - `Best/10_FermatLastTheorem.lean` ✓ (canonical)
  - `NumberTheory/Core/FermatLastTheorem.lean` ✗ (duplicate)
  - `Books/TRIANGLESWALLOWEDUNIVERSE/lean/10_FermatLastTheorem.lean` ✗ (duplicate)

**Group** (3 copies):
  - `Best/11_CongruenceOfSquaresFactoring.lean` ✓ (canonical)
  - `Cryptography/Factoring/CongruenceOfSquares.lean` ✗ (duplicate)
  - `Books/TRIANGLESWALLOWEDUNIVERSE/lean/11_CongruenceOfSquaresFactoring.lean` ✗ (duplicate)

**Group** (3 copies):
  - `Best/12_QuadrupleFactorTheory.lean` ✓ (canonical)
  - `Pythagorean/Quadruples/QuadrupleFactorTheory.lean` ✗ (duplicate)
  - `Books/TRIANGLESWALLOWEDUNIVERSE/lean/12_QuadrupleFactorTheory.lean` ✗ (duplicate)

**Group** (3 copies):
  - `Best/13_GCDCascadeFactorExtraction.lean` ✓ (canonical)
  - `Pythagorean/SharedFactor/GCDCascade.lean` ✗ (duplicate)
  - `Books/TRIANGLESWALLOWEDUNIVERSE/lean/13_GCDCascadeFactorExtraction.lean` ✗ (duplicate)

**Group** (3 copies):
  - `Pythagorean/TreeFactoring/Core.lean` ✓ (canonical)
  - `Best/14_PythagoreanTreeFactoringCore.lean` ✗ (duplicate)
  - `Books/TRIANGLESWALLOWEDUNIVERSE/lean/14_PythagoreanTreeFactoringCore.lean` ✗ (duplicate)

**Group** (3 copies):
  - `Tropical/Core/TropicalGeometry.lean` ✓ (canonical)
  - `Best/15_TropicalGeometryFoundations.lean` ✗ (duplicate)
  - `Books/TRIANGLESWALLOWEDUNIVERSE/lean/15_TropicalGeometryFoundations.lean` ✗ (duplicate)

**Group** (3 copies):
  - `Best/16_LorentzGroupStructure.lean` ✓ (canonical)
  - `Pythagorean/Core/LorentzBerggren.lean` ✗ (duplicate)
  - `Books/TRIANGLESWALLOWEDUNIVERSE/lean/16_LorentzGroupStructure.lean` ✗ (duplicate)

**Group** (4 copies):
  - `Speculative/Other/Main.lean` ✓ (canonical)
  - `Computation/Factoring/AStar/Main.lean` ✗ (duplicate)
  - `HigherDimensionalQuadrupleDivisionFactoring/Main.lean` ✗ (duplicate)
  - `Pythagorean/Frameworks/PythagoreanQuadrupleFactoringFramework/Main.lean` ✗ (duplicate)

**Group** (2 copies):
  - `Logic/Foundations/Core/Basic.lean` ✓ (canonical)
  - `Computation/Oracles/Applications/OracleSpectralFrontier.lean` ✗ (duplicate)

**Group** (2 copies):
  - `Speculative/RudyRucker/CantorsParadise.lean` ✓ (canonical)
  - `Logic/Foundations/Rucker/CantorsParadise.lean` ✗ (duplicate)

**Group** (2 copies):
  - `Speculative/RudyRucker/ComputationalUniverse.lean` ✓ (canonical)
  - `Logic/Foundations/Rucker/ComputationalUniverse.lean` ✗ (duplicate)

**Group** (2 copies):
  - `Speculative/RudyRucker/DiagonalArguments.lean` ✓ (canonical)
  - `Logic/Foundations/Rucker/DiagonalArguments.lean` ✗ (duplicate)

**Group** (2 copies):
  - `Speculative/RudyRucker/MindAndMathematics.lean` ✓ (canonical)
  - `Logic/Foundations/Rucker/MindAndMathematics.lean` ✗ (duplicate)

**Group** (2 copies):
  - `Speculative/Exploration/IntegerEnergy.lean` ✓ (canonical)
  - `NumberTheory/IntegerEnergy/IntegerEnergy.lean` ✗ (duplicate)

**Group** (2 copies):
  - `Speculative/IdempotentCollapse/CategoryCollapse.lean` ✓ (canonical)
  - `Speculative/IdempotentCollapse/V2/CategoryCollapse.lean` ✗ (duplicate)

**Group** (2 copies):
  - `Speculative/IdempotentCollapse/ClosureCollapse.lean` ✓ (canonical)
  - `Speculative/IdempotentCollapse/V2/ClosureCollapse.lean` ✗ (duplicate)

**Group** (2 copies):
  - `Speculative/IdempotentCollapse/ComputationalCollapse.lean` ✓ (canonical)
  - `Speculative/IdempotentCollapse/V2/ComputationalCollapse.lean` ✗ (duplicate)

**Group** (2 copies):
  - `Speculative/IdempotentCollapse/Core.lean` ✓ (canonical)
  - `Speculative/IdempotentCollapse/V2/Core.lean` ✗ (duplicate)

**Group** (2 copies):
  - `Speculative/IdempotentCollapse/FixedPointCollapse.lean` ✓ (canonical)
  - `Speculative/IdempotentCollapse/V2/FixedPointCollapse.lean` ✗ (duplicate)

**Group** (2 copies):
  - `Speculative/IdempotentCollapse/InformationCollapse.lean` ✓ (canonical)
  - `Speculative/IdempotentCollapse/V2/InformationCollapse.lean` ✗ (duplicate)

**Group** (2 copies):
  - `Speculative/IdempotentCollapse/NeuralCollapse.lean` ✓ (canonical)
  - `Speculative/IdempotentCollapse/V2/NeuralCollapse.lean` ✗ (duplicate)

**Group** (2 copies):
  - `Speculative/IdempotentCollapse/OptimalCollapse.lean` ✓ (canonical)
  - `Speculative/IdempotentCollapse/V2/OptimalCollapse.lean` ✗ (duplicate)

**Group** (2 copies):
  - `Speculative/IdempotentCollapse/QuantumCollapse.lean` ✓ (canonical)
  - `Speculative/IdempotentCollapse/V2/QuantumCollapse.lean` ✗ (duplicate)

**Group** (2 copies):
  - `Speculative/IdempotentCollapse/TopologicalCollapse.lean` ✓ (canonical)
  - `Speculative/IdempotentCollapse/V2/TopologicalCollapse.lean` ✗ (duplicate)

---

## Detailed Catalog by Category

### Algebra/Advanced

*3 files, 78 declarations, 368 lines*

#### `GaloisTheory.lean` (42 lines)
*Source: `Algebra/Other/GaloisTheory.lean`*

- **theorem**: `gf2_card`, `gf3_card`, `frobenius_endomorphism`, `cyclotomic_degree`, `cyclotomic_monic`, `prod_cyclotomic`, `tower_degree`, `complex_over_real_degree`

#### `LieAlgebras.lean` (59 lines)
*Source: `Algebra/Other/LieAlgebras.lean`*

- **def**: `lieBracket2`, `sl2_e`, `sl2_f`, `sl2_h`
- **theorem**: `lie_antisymm`, `lie_self_zero`, `jacobi_identity`, `trace_lie_zero`, `sl2_ef`, `sl2_he`, ... +3 more

#### `MoonshineCodingTheory.lean` (267 lines)
*Source: `Moonshine/MoonshineCodingTheory.lean`*

- **theorem**: `e8_type_a_count`, `e8_type_b_count`, `e8_root_count`, `e8_root_norm_sq`, `e8_unimodular_det`, `e8_self_dual_code_dim`, ... +51 more

### Algebra/DivisionAlgebras

*11 files, 374 declarations, 3,052 lines*

#### `Channel5Sedenions.lean` (536 lines)
*Source: `Algebra/DivisionAlgebras/Channel5Sedenions.lean`*

- **inductive**: `LightChannel`
- **def**: `sigma7`, `eisenstein_r16`, `cusp_correction`, `stokes_constraint`, `jones_intensity`, `horizontal_pol`, ... +3 more
- **theorem**: `cayley_dickson_dim`, `channel_dimensions`, `hurwitz_dimensions`, `sixteen_not_hurwitz`, `two_square_identity`, `four_square_identity`, ... +35 more

#### `Channel6Research.lean` (516 lines)
*Source: `Algebra/DivisionAlgebras/Channel6Research.lean`*

- **structure**: `Sed`, `Tri`, `TwoPhotonStokes`, `ChannelSpectrum`
- **def**: `Sed`, `Tri`, `sedenion_zd_left`, `sedenion_zd_right`, `cuspDim`, `singlePhotonMinkowski`, ... +15 more
- **theorem**: `cayley_dickson_dim_general`, `channel6_dim`, `six_channel_dimensions`, `thirtytwo_not_hurwitz`, `total_channel_dimensions`, `total_dim_is_mersenne`, ... +60 more

#### `DivisionAlgebras.lean` (144 lines)
*Source: `Algebra/DivisionAlgebras/DivisionAlgebras.lean`*

- **structure**: `CayleyDickson`
- **def**: `embed`, `im`, `algAssociator`, `algCommutator`
- **theorem**: `algAssociator_eq_zero`, `algCommutator_eq_zero`, `quaternion_norm_mul`, `rationals_dense_in_reals`

#### `ExoticAlgebras.lean` (142 lines)
*Source: `Algebra/DivisionAlgebras/ExoticAlgebras.lean`*

- **def**: `postFixedPoints`
- **noncomp. def**: `oracleIter`
- **theorem**: `add_idempotent`, `add_comm`, `add_assoc`, `left_distrib`, `right_distrib`, `mul_zero_identity`, ... +9 more

#### `GeometricAlgebra.lean` (91 lines)
*Source: `Algebra/DivisionAlgebras/GeometricAlgebra.lean`*

- **theorem**: `dist_symm_real`, `triangle_ineq_R2`, `rotation_det_one`, `rotation_compose`, `isometry_preserves_dist`, `isometry_comp`

#### `OctonionQubit.lean` (143 lines)
*Source: `Algebra/DivisionAlgebras/OctonionQubit.lean`*

- **def**: `UnitSphere`, `RationalSphere`, `innerProduct`, `sqNorm`, `fanoTriples`
- **noncomp. def**: `bornProbability`, `stereoProj`
- **theorem**: `unit_sphere_norm_one`, `born_probability_nonneg`, `born_probability_le_one`, `stereoProj_on_sphere`, `stereoProj_rational`, `fano_card`

#### `CayleyDicksonHierarchy.lean` (380 lines)
*Source: `CayleyDicksonHierarchy/CayleyDicksonHierarchy.lean`*

- **structure**: `CayleyDicksonLevel`
- **def**: `ringCommutator`, `sigma_k`, `hurwitzDims`, `cdDim`, `cuspSpaceDim`, `cdLevel`, ... +3 more
- **theorem**: `two_square_composition`, `four_square_composition`, `eight_square_composition`, `quaternion_noncommutative`, `assoc_zero_in_ring`, `ringCommutator_zero_comm`, ... +47 more

#### `Main.lean` (2 lines)
*Source: `DivisionAlgebraNorms/Main.lean`*


#### `NormHierarchy.lean` (492 lines)
*Source: `DivisionAlgebraNorms/NormHierarchy.lean`*

- **theorem**: `brahmagupta_fibonacci_identity`, `brahmagupta_fibonacci_identity`, `two_composition_equality`, `euler_four_square_identity`, `quaternion_norm_mul`, `degen_eight_square_identity`, ... +36 more

#### `QuantumE8ModularForms.lean` (281 lines)
*Source: `DivisionAlgebraNorms/QuantumE8ModularForms.lean`*

- **def**: `e8_kissing_number`, `e8_weyl_group_order`, `total_channels`, `is_hurwitz_dimension`
- **noncomp. def**: `divisor_sum`
- **theorem**: `grover_speedup_structure`, `quantum_birthday_bound`, `bht_cube_root_bound`, `e8_weyl_factorization`, `collision_channels_dim2`, `collision_channels_dim4`, ... +25 more

#### `ResearchQuestions.lean` (325 lines)
*Source: `DivisionAlgebraNorms/ResearchQuestions.lean`*

- **def**: `e8_degree`
- **noncomp. def**: `σ`
- **theorem**: `prime_divisor_count`, `sigma_multiplicative_coprime`, `semiprime_divisor_count`, `coprime_factor_combine`, `distinct_rep_nonzero_cross`, `e8_walk_degree_advantage`, ... +38 more

### Algebra/Foundations

*8 files, 101 declarations, 893 lines*

#### `Algebra.lean` (75 lines)
*Source: `Algebra/Core/Algebra.lean`*

- **theorem**: `lagrange_theorem`, `prime_order_cyclic`, `irreducible_is_prime_in_pid`, `crt_coprime`, `x_sq_plus_one_irreducible`

#### `AlgebraicStructures.lean` (97 lines)
*Source: `Algebra/Core/AlgebraicStructures.lean`*

- **def**: `sl2_e`, `sl2_f`, `sl2_h`
- **theorem**: `gaussian_norm_mul`, `zsqrt_neg5_norms`, `factor_diff_squares`, `factor_cube_minus_one`, `factor_fourth_power`, `cyclotomic_6_divides`, ... +9 more

#### `AlgebraicTheoryOfAlgebra.lean` (232 lines)
*Source: `Algebra/Core/AlgebraicTheoryOfAlgebra.lean`*

- **structure**: `AlgSignature`, `SigAlgebra`, `EquationalTheory`, `Variety`
- **inductive**: `AlgTerm`
- **def**: `trivialTheory`, `discreteTheory`, `theoryMeet`, `totalVariety`, `trivialVariety`, `varietyMeet`, ... +4 more
- **theorem**: `theoryMeet_le_left`, `theoryMeet_le_right`, `le_theoryMeet`, `varietyMeet_le_left`, `varietyMeet_le_right`, `le_varietyMeet`, ... +9 more

#### `BrahmaguptaFibonacci.lean` (64 lines)
*Source: `Algebra/Core/BrahmaguptaFibonacci.lean`*

- **theorem**: `brahmagupta_fibonacci`, `brahmagupta_fibonacci`, `gaussian_product_preserves_sum_of_squares`, `gaussian_norm_multiplicative`

#### `CommutativeAlgebra.lean` (38 lines)
*Source: `Algebra/Core/CommutativeAlgebra.lean`*

- **theorem**: `ideal_mul_le_inf`, `maximal_is_prime`, `int_noetherian`, `quotient_noetherian`, `polynomial_noetherian`, `crt_coprime`, `finite_domain_is_field`

#### `GroupTheoryExploration.lean` (149 lines)
*Source: `Algebra/Core/GroupTheoryExploration.lean`*

- **theorem**: `prime_order_generates`, `order_dvd_card`, `pow_card_eq_one_gen`, `sq_prime_is_comm`, `perm_prod_transpositions`, `sign_swap_neg`, ... +5 more

#### `PolynomialTheory.lean` (124 lines)
*Source: `Algebra/Core/PolynomialTheory.lean`*

- **theorem**: `diff_of_squares_poly`, `x2_plus_1_no_root`, `geom_series_poly`, `int_domain`, `int_pid`, `field_unit`, ... +7 more

#### `QuadraticForms.lean` (114 lines)
*Source: `Algebra/Core/QuadraticForms.lean`*

- **def**: `form_discriminant`
- **theorem**: `sum_two_sq_disc`, `eisenstein_form_disc`, `class_number_neg4`, `brahmagupta_fibonacci`, `brahmagupta_fibonacci`, `sum_sq_mul_sum_sq`, ... +6 more

### Algebra/LinearAlgebra

*3 files, 44 declarations, 316 lines*

#### `LinearAlgebra.lean` (71 lines)
*Source: `Algebra/LinearAlgebra/LinearAlgebra.lean`*

- **theorem**: `det_mul_eq`, `det_one_pf`, `det_transpose_pf`, `skew_symmetric_trace_zero`, `orthogonal_det`

#### `LinearAlgebraAdvanced.lean` (58 lines)
*Source: `Algebra/LinearAlgebra/LinearAlgebraAdvanced.lean`*

- **def**: `nilpotent_2x2`, `proj_2x2`
- **theorem**: `det_mul_2x2`, `det_transpose_2x2`, `trace_add_2x2`, `rotation_det_345`, `rotation_preserves_norm_345`, `nilpotent_squared`, ... +4 more

#### `LinearAlgebraExploration.lean` (187 lines)
*Source: `Algebra/LinearAlgebra/LinearAlgebraExploration.lean`*

- **def**: `nilpotent_2x2`, `rotation_90`, `proj_2x2`
- **theorem**: `det_mul_comm`, `det_transpose`, `det_smul`, `det_one`, `det_2x2`, `det_diag_2x2`, ... +18 more

### Algebra/RepresentationTheory

*4 files, 42 declarations, 307 lines*

#### `CategoryRepresentation.lean` (130 lines)
*Source: `Algebra/RepresentationTheory/CategoryRepresentation.lean`*

- **theorem**: `id_functor_comp`, `functor_comp_assoc`, `iso_has_inverse`, `comp_id_left`, `comp_id_right`, `free_module_dim`, ... +6 more

#### `RepTheoryDeep.lean` (27 lines)
*Source: `Algebra/RepresentationTheory/RepTheoryDeep.lean`*

- **theorem**: `dim_sq_sum`, `abelian_irreps_dim`, `pq_gt_one`, `dft_size`, `peter_weyl`

#### `RepresentationTheory.lean` (30 lines)
*Source: `Algebra/RepresentationTheory/RepresentationTheory.lean`*

- **theorem**: `sign_rep_identity`, `sign_swap`, `regular_rep_dim`, `sym2_dim`, `symn_dim`, `moonshine_dimension`, `mckay_first`, `mckay_second`

#### `SL2Theory.lean` (120 lines)
*Source: `Algebra/RepresentationTheory/SL2Theory.lean`*

- **def**: `M1_SL2`, `M3_SL2`, `GammaTheta`
- **noncomp. def**: `j_from_lambda`
- **theorem**: `berggren_eq_theta`, `SL2_F2_card`, `SL2_F3_card`, `SL2_F5_card`, `SL2_F7_card`, `SL2_F11_card`, ... +7 more

### Analysis

*12 files, 105 declarations, 1,010 lines*

#### `Analysis.lean` (129 lines)
*Source: `Analysis/Core/Analysis.lean`*

- **theorem**: `convergent_is_cauchy`, `contraction_has_fixed_point`, `mean_value_theorem`, `ftc_eval`, `exponential_decay_tendsto`, `geometric_series_sum`, `am_gm_two`, `cauchy_schwarz_finset`

#### `AnalysisExploration.lean` (123 lines)
*Source: `Analysis/Core/AnalysisExploration.lean`*

- **theorem**: `am_gm_two`, `cauchy_schwarz_finset`, `power_mean_two`, `inv_n_tendsto`, `geometric_sum_formula`, `basel_partial_sums_bounded`, ... +8 more

#### `AnalysisInequalities.lean` (131 lines)
*Source: `Analysis/Core/AnalysisInequalities.lean`*

- **theorem**: `am_gm_two`, `four_ab_le_sq_sum`, `sq_sum_ge_two_prod`, `cauchy_schwarz_fin`, `bernoulli_ineq`, `abs_triangle`, ... +9 more

#### `Convergence.lean` (182 lines)
*Source: `Analysis/Core/Convergence.lean`*

- **def**: `Beliefs`, `beliefDistance`, `bayesEvidence`, `bayesUpdate`
- **theorem**: `dead_hypothesis_stays_dead`, `zero_likelihood_eliminates`, `beliefDistance_nonneg`, `beliefDistance_symm`, `beliefDistance_triangle`, `beliefDistance_eq_zero_iff`, ... +4 more

#### `DifferentialEquations.lean` (61 lines)
*Source: `Analysis/Core/DifferentialEquations.lean`*

- **theorem**: `fixed_point_stability`, `discrete_gronwall`, `logistic_fixed_point`, `geometric_sum_formula`, `fib_bound`, `euler_total_steps`

#### `FunctionalAnalysis.lean` (94 lines)
*Source: `Analysis/Core/FunctionalAnalysis.lean`*

- **theorem**: `norm_triangle`, `norm_reverse_triangle`, `norm_smul_eq`, `opnorm_comp_le`, `id_opnorm_le_one`, `cauchy_schwarz_inner`, ... +3 more

#### `HarmonicAnalysis.lean` (32 lines)
*Source: `Analysis/Core/HarmonicAnalysis.lean`*

- **noncomp. def**: `discreteConv`
- **theorem**: `conv_delta`, `trivial_char_sum`, `sum_sq_nonneg`, `energy_decomposition`

#### `NumericalAnalysis.lean` (19 lines)
*Source: `Analysis/Core/NumericalAnalysis.lean`*

- **theorem**: `newton_qc`, `simpson_cubic`, `euler_stab`

#### `OperatorAlgebras.lean` (32 lines)
*Source: `Analysis/Core/OperatorAlgebras.lean`*

- **theorem**: `trace_eigenvalue_sum`, `det_eigenvalue_prod`, `trace_cyclic`, `trace_positive`, `bott_periodicity`, `su2_dimension`, `su3_dimension`, `instanton_charge_integer`

#### `OptimizationConvexity.lean` (92 lines)
*Source: `Analysis/Core/OptimizationConvexity.lean`*

- **theorem**: `convex_inter_sets`, `convex_Icc_interval`, `convexOn_max_fn`, `linear_is_convex`, `linear_is_concave`, `sq_strict_convex`, ... +4 more

#### `OptimizationTheory.lean` (56 lines)
*Source: `Analysis/Core/OptimizationTheory.lean`*

- **theorem**: `sq_convex`, `jensen_sq`, `gate_count_lower_bound`, `trace_linear_2x2`, `gd_quadratic_one_step`

#### `SpectralTheory.lean` (59 lines)
*Source: `Analysis/Core/SpectralTheory.lean`*

- **theorem**: `M₁_det_mod`, `M₃_det_mod`, `M₁_ne_inv`, `M₃_ne_inv`, `ramanujan_bound_lt_degree`, `ramanujan_gap_pos`, `M₃_squared`, `M₁_squared`

### Best

*13 files, 334 declarations, 2,922 lines*

#### `02_LatticeTreeCorrespondence.lean` (131 lines)
*Source: `Best/02_LatticeTreeCorrespondence.lean`*

- **def**: `berggren_M₁`, `berggren_M₃`, `berggren_M₁_inv`, `berggren_M₃_inv`, `euclidStep`, `quotientMatrix`, `quadrupleLatticeCondition`
- **theorem**: `berggren_M₁_det`, `berggren_M₃_det`, `berggren_M₁_mul_inv`, `berggren_M₃_mul_inv`, `quotientMatrix_det`, `M₃_inv_is_cf_step`, ... +8 more

#### `03_HyperbolicShortcutsFactoring.lean` (352 lines)
*Source: `Best/03_HyperbolicShortcutsFactoring.lean`*

- **inductive**: `Dir`
- **def**: `B₁`, `B₂`, `B₃`, `Q`, `dirMat`, `pathMat`, ... +6 more
- **theorem**: `diff_of_squares_from_pyth`, `diff_of_squares_sym`, `hyp_gt_leg`, `factors_pos`, `B₁_lorentz`, `B₂_lorentz`, ... +49 more

#### `04_ThreeRoadsFromPythagoras.lean` (180 lines)
*Source: `Best/04_ThreeRoadsFromPythagoras.lean`*

- **def**: `lorentz_form`
- **theorem**: `brahmagupta_fibonacci`, `brahmagupta_fibonacci`, `pythagorean_composition`, `pythagorean_composition`, `euler_factoring_identity`, `two_representations_give_four`, ... +12 more

#### `05_BerggrenLorentzPaperProofs.lean` (236 lines) ⚠️ 2 sorry
*Source: `Best/05_BerggrenLorentzPaperProofs.lean`*

- **inductive**: `BerggrenPath`
- **def**: `BA`, `BB`, `BC`, `QLorentz`, `tripleAt`, `pellHyp`, ... +3 more
- **theorem**: `BA_preserves_lorentz`, `BB_preserves_lorentz`, `BC_preserves_lorentz`, `det_BA`, `det_BB`, `det_BC`, ... +16 more

#### `06_HigherKTupleFactoring.lean` (588 lines) ⚠️ 1 sorry
*Source: `Best/06_HigherKTupleFactoring.lean`*

- **structure**: `PythQuintuplet`, `PythSextuplet`, `PythOctuplet`
- **def**: `lorentzFormGen`, `isNullGen`, `quint_1_1_1_1`, `quint_1_2_2_4`, `quint_1_4_4_4`, `sext_1_1_1_2_3`, ... +6 more
- **theorem**: `null_iff_sum_eq`, `ktuple_diff_of_squares_3`, `ktuple_diff_of_squares_4`, `ktuple_diff_of_squares_5`, `multichannel_factor_extraction`, `channel_duality`, ... +38 more

#### `07_QuantumGroverTreeFactoring.lean` (105 lines)
*Source: `Best/07_QuantumGroverTreeFactoring.lean`*

- **def**: `allPositive`, `qInvB1`, `qInvB2`, `qInvB3`
- **theorem**: `grover_query_bound`, `quantum_balanced_complexity`, `branches_12_exclusive`, `branches_13_exclusive`, `branches_23_exclusive`, `descent_is_deterministic`

#### `08_ComplexityBoundsProven.lean` (63 lines)
*Source: `Best/08_ComplexityBoundsProven.lean`*

- **theorem**: `cf_length_bound`, `balanced_bound`, `euclid_param_bound`, `depth_bound_balanced`, `gcd_cost_bound`, `pythagorean_tree_complexity`, ... +4 more

#### `09_CayleyDicksonHierarchy.lean` (154 lines)
*Source: `Best/09_CayleyDicksonHierarchy.lean`*

- **def**: `jacobi`
- **theorem**: `complex_norm_sq_mul`, `quaternion_not_commutative`, `brahmagupta_fibonacci`, `euler_four_square`, `channel_1_to_2`, `channel_2_to_3`, ... +5 more

#### `10_FermatLastTheorem.lean` (226 lines) ⚠️ 2 sorry
*Source: `Best/10_FermatLastTheorem.lean`*

- **def**: `FermatLastTheorem`
- **theorem**: `flt_multiple_of_exp`, `fermat_n4`, `fermat_n4_strong`, `fermat_n3`, `fermat_last_theorem_full`, `requires`

#### `11_CongruenceOfSquaresFactoring.lean` (160 lines)
*Source: `Best/11_CongruenceOfSquaresFactoring.lean`*

- **def**: `isSmooth`, `factorBase`
- **theorem**: `congruence_of_squares_factoring`, `congruence_of_squares_cofactor`, `gcd_sub_dvd_n`, `gcd_product_bound`, `isSmooth_one`, `isSmooth_mul`, ... +6 more

#### `12_QuadrupleFactorTheory.lean` (231 lines)
*Source: `Best/12_QuadrupleFactorTheory.lean`*

- **structure**: `PythagoreanQuadruple`
- **def**: `pq_1223`, `pq_2367`, `pq_1489`, `pq_4479`, `quadFromParams`, `PythagoreanQuadruple`, `gaussianNormSq`
- **theorem**: `quad_difference_of_squares`, `quad_sum_pos`, `quad_diff_nonneg`, `param_produces_quadruple`, `param_d_decomposition`, `param_ab_factorization`, ... +11 more

#### `13_GCDCascadeFactorExtraction.lean` (397 lines)
*Source: `Best/13_GCDCascadeFactorExtraction.lean`*

- **def**: `repDist`
- **theorem**: `channel_diff_sq_a`, `channel_diff_sq_b`, `channel_diff_sq_c`, `channel_sum`, `cross_channel_gcd`, `triple_channel_gcd`, ... +41 more

#### `16_LorentzGroupStructure.lean` (99 lines)
*Source: `Best/16_LorentzGroupStructure.lean`*

- **def**: `lorentz_form`
- **theorem**: `pyth_on_null_cone`, `berggren_A_preserves`, `berggren_B_preserves`, `berggren_C_preserves`, `berggren_all_preserve_lorentz`, `berggren_A_inv_consecutive`, `depth_factor_prime_formula`, `semiprime_four_triples`

### Bridges

*33 files, 876 declarations, 6,180 lines*

#### `BerggrenLanglandsBridge.lean` (163 lines)
*Source: `Bridges/BerggrenLanglandsBridge.lean`*

- **def**: `B₁`, `B₂`, `B₃`, `lorentzQ`, `M₁`, `M₂`, ... +5 more
- **theorem**: `M1_in_SL2`, `M2_det`, `M3_in_SL2`, `M3_unipotent`, `M1_squared`, `euclid_is_pythagorean`, ... +12 more

#### `BreakthroughDirections.lean` (317 lines)
*Source: `Bridges/NewDirections/BreakthroughDirections.lean`*

- **structure**: `PersistenceInterval`
- **def**: `relu`, `lse2`, `softmax_prob`, `PersistenceInterval`, `tropicalPersistenceDist`, `diagonalDist`
- **theorem**: `relu_idempotent`, `relu_nonneg`, `tropical_max_idempotent`, `single_relu_regions`, `layer_region_count`, `tropical_rank_expressiveness`, ... +35 more

#### `CodingTheoryBridge.lean` (150 lines)
*Source: `Bridges/NewDirections/CodingTheoryBridge.lean`*

- **def**: `hammingVolume`, `gaussianNorm`, `eisensteinNorm`, `cayleyDicksonDimensions`, `codeRate`
- **theorem**: `binary_hamming_volume_1`, `singleton_bound`, `two_square_identity`, `four_square_special_case`, `fermat_sum_two_squares_5`, `fermat_sum_two_squares_13`, ... +18 more

#### `E8LatticeSurgery.lean` (472 lines) ⚠️ 1 sorry
*Source: `Bridges/NewDirections/E8LatticeSurgery/E8LatticeSurgery.lean`*

- **theorem**: `e8_dimension`, `e8_root_count`, `e8_even_property`, `e8_unimodular`, `e8_kissing_number`, `e8_weyl_group_order`, ... +68 more

#### `EntropyTropicalDuality.lean` (209 lines)
*Source: `Bridges/NewDirections/EntropyTropicalDuality.lean`*

- **def**: `lse2`, `softmax2_fst`, `softmax2_snd`, `negXLogX`, `TropicallyConvex`, `lse2_temp`, `gibbsFreeEnergy`
- **theorem**: `lse2_comm`, `lse2_assoc`, `lse2_ge_max`, `lse2_le_max_add_log2`, `lse2_tropical_error`, `softmax2_fst_nonneg`, ... +19 more

#### `FiveFrontiers.lean` (358 lines) ⚠️ 1 sorry
*Source: `Bridges/NewDirections/FiveFrontiers.lean`*

- **def**: `log_cooling`
- **theorem**: `toeplitz_tropical_rank_bound`, `conv1d_region_bound`, `attention_tropical_bound`, `multihead_expressiveness`, `depthwise_separable_rank`, `residual_rank_lower_bound`, ... +57 more

#### `PersistentTropicalBridge.lean` (182 lines)
*Source: `Bridges/NewDirections/PersistentTropicalBridge.lean`*

- **structure**: `PersistenceInterval`, `TropicalMonomial`
- **def**: `PersistenceInterval`, `bottleneckPointDist`, `tropicalEval`, `diagonalDist`, `diagonalProjection`, `significance`
- **theorem**: `PersistenceInterval`, `PersistenceInterval`, `bottleneckPointDist_comm`, `bottleneckPointDist_nonneg`, `bottleneckPointDist_eq_zero_iff`, `bottleneckPointDist_triangle`, ... +10 more

#### `QuantumTropicalComputation.lean` (181 lines)
*Source: `Bridges/NewDirections/QuantumTropicalComputation.lean`*

- **structure**: `Qubit`
- **def**: `qubit0`, `qubit1`, `probZero`, `probOne`, `hadamardCoeff`, `tropicalInnerProduct2`, ... +4 more
- **theorem**: `bool_or_idempotent`, `bool_and_distrib_or`, `born_probabilities_sum`, `born_prob_nonneg`, `qubit0_deterministic`, `qubit1_opposite`, ... +13 more

#### `SpectralIdempotentBridge.lean` (189 lines)
*Source: `Bridges/NewDirections/SpectralIdempotentBridge.lean`*

- **structure**: `StochasticVec2`
- **def**: `IsIdempotentElem`, `uniformVec2`, `tropicalEigenvalue2`
- **theorem**: `idempotent_trace_in_set`, `idempotent_det_squared`, `idempotent_trace_values`, `contraction_decay`, `contraction_powers_vanish`, `idempotent_instant_convergence`, ... +14 more

#### `ThreeNewFrontiers.lean` (354 lines) ⚠️ 1 sorry
*Source: `Bridges/NewDirections/ThreeNewFrontiers.lean`*

- **theorem**: `qubo_coefficient_count`, `dwave_pegasus_embedding`, `chain_strength_bound`, `schedule_discretization_error`, `trotter_error_bound`, `trotter_gate_count`, ... +53 more

#### `TropicalDeepLearningTheory.lean` (411 lines) ⚠️ 1 sorry
*Source: `Bridges/NewDirections/TropicalDeepLearningTheory.lean`*

- **def**: `LSE_two`, `logCooling`, `tropicalNASScore`
- **theorem**: `trop_add_comm`, `trop_add_assoc`, `trop_add_idem`, `trop_distrib`, `trop_mul_zero`, `trop_add_bot`, ... +56 more

#### `SPBAdvanced.lean` (143 lines)
*Source: `Bridges/StereographicProjectionBridge/SPBAdvanced.lean`*

- **def**: `spb_mobius_matrix`, `spb_iter`
- **theorem**: `spb_mobius_det`, `spb_mobius_mul`, `spb_iter_zero`, `spb_iter_one`, `spb_strict_mono_right`, `spb_pos`, ... +4 more

#### `SPBCore.lean` (249 lines)
*Source: `Bridges/StereographicProjectionBridge/SPBCore.lean`*

- **def**: `spb`, `cayley`, `spbH`, `spbF`
- **theorem**: `spb_comm`, `spb_zero_right`, `spb_zero_left`, `spb_neg_self`, `spb_self`, `spb_assoc`, ... +17 more

#### `TropicalNeuralBridge.lean` (151 lines)
*Source: `Bridges/TropicalNeuralBridge.lean`*

- **structure**: `PiecewiseLinear`
- **def**: `numRegions`, `tropicalAdd`, `tropicalMul`, `reluNeuron`, `softmax2`, `TropicallyConvex`
- **theorem**: `max_breakpoints_bound`, `single_neuron_regions`, `layer_max_regions`, `depth_width_bound`, `tropicalAdd_comm`, `tropicalAdd_assoc`, ... +11 more

#### `UnifiedFramework.lean` (302 lines)
*Source: `Bridges/UnifiedFramework.lean`*

- **def**: `relu`, `maslovAdd`, `berggrenM₁`, `berggrenM₃`, `pythagQ`, `stereo1D`, `idempotentCount`
- **theorem**: `relu_idempotent`, `relu_monotone`, `relu_nonneg`, `relu_fixed_iff`, `maslov_comm`, `logsumexp_ge_max`, ... +23 more

#### `BerggrenStructure.lean` (184 lines)
*Source: `CrossCutting/Core/BerggrenStructure.lean`*

- **def**: `berggrenM1`, `berggrenM2`, `berggrenM3`
- **theorem**: `berggren_M1_preserves_pyth`, `berggren_M2_preserves_pyth`, `berggren_M3_preserves_pyth`, `berggren_M1_quad_form`, `berggren_M2_quad_form`, `berggren_M3_quad_form`, ... +11 more

#### `Connections.lean` (137 lines)
*Source: `CrossCutting/Core/Connections.lean`*

- **def**: `relu`
- **theorem**: `retraction_yields_idempotent`, `idempotent_surj_range`, `idempotent_counting`, `tropical_zero_identity`, `tropical_one_identity`, `relu_idempotent`, ... +10 more

#### `IdempotentCollapse.lean` (163 lines)
*Source: `CrossCutting/Core/IdempotentCollapse.lean`*

- **theorem**: `idempotent_image_eq_fixedPoints`, `idempotent_fixes_range`, `idempotent_iterate`, `commuting_idempotents_compose`, `id_idempotent`, `const_idempotent`, ... +10 more

#### `IdempotentConvergence.lean` (132 lines)
*Source: `CrossCutting/Core/IdempotentConvergence.lean`*

- **theorem**: `idempotent_annihilating_poly`, `idempotent_complement`, `idempotent_ker_eq_range_complement`, `idempotent_range_eq_ker_complement`, `idempotent_one_step`, `idempotent_iterate_succ`, ... +6 more

#### `QuantumBerggrenGates.lean` (106 lines)
*Source: `CrossCutting/Core/QuantumBerggrenGates.lean`*

- **def**: `berggrenMat1`, `berggrenMat2`, `berggrenMat3`, `sigMat`, `rootVec`
- **theorem**: `berggrenMat1_preserves_sig`, `berggrenMat2_preserves_sig`, `berggrenMat3_preserves_sig`, `berggrenMat1_det`, `berggrenMat2_det`, `berggrenMat3_det`, ... +22 more

#### `SauerShelah.lean` (104 lines)
*Source: `CrossCutting/Core/SauerShelah.lean`*

- **def**: `restrictFamily`, `Shatters`, `binomialSum`
- **theorem**: `restrictFamily_idempotent`, `restrictFamily_card_le_pow`, `restrict_empty`, `shatters_mono`, `shatters_empty`, `binomialSum_zero`, ... +3 more

#### `TropicalLanglands.lean` (101 lines)
*Source: `CrossCutting/Core/TropicalLanglands.lean`*

- **inductive**: `BerggrenMove`
- **def**: `applyMove`, `applyPath`
- **theorem**: `applyMove_quad_form`, `applyMove_preserves_pyth`, `applyPath_nil`, `applyPath_append`, `move_M_hyp_increase`, `root_child_L`, ... +5 more

#### `TropicalQuantumBridge.lean` (161 lines)
*Source: `CrossCutting/Core/TropicalQuantumBridge.lean`*

- **def**: `logsumexp`, `softmax2_fst`, `softmax2_snd`
- **theorem**: `logsumexp_symmetric`, `logsumexp_diagonal`, `logsumexp_ge_max`, `logsumexp_le_max_add`, `tropical_add_comm`, `tropical_add_assoc`, ... +8 more

#### `AutomorphicOracles.lean` (136 lines)
*Source: `LanglandsBridges/AutomorphicOracles.lean`*

- **structure**: `ModularFormData`, `CuspFormData`, `HeckeEigenform`, `EllipticCurveData`, `ModularityCorrespondence`, `HeckeEigenvalueSystem`, `LanglandsOracle`
- **def**: `satisfiesRamanujanBound`, `modularLFunction`, `modularEulerFactor`, `satisfiesHasseBound`, `strongMultiplicityOne`, `isExactOracle`, `oracleError`, `oracleAccuracy`
- **theorem**: `ramanujan_weight2`, `exact_oracle_zero_error`, `perfect_accuracy`

#### `CategoricalBridges.lean` (137 lines)
*Source: `LanglandsBridges/CategoricalBridges.lean`*

- **structure**: `LFunctionData`, `FunctionalEquation`
- **inductive**: `BridgeLevel`
- **def**: `bridge_composition`, `BridgeLevel`, `riemannSum`, `FunctionalEquation`
- **theorem**: `hott_subsumes_all`, `analysis_bridge_unique_limit`, `riemann_sum_converges`, `lfunc_equiv_refl`, `root_number_unit`

#### `ChipFiring.lean` (134 lines)
*Source: `LanglandsBridges/ChipFiring.lean`*

- **structure**: `GraphLapl`, `LanglandsAnalogy`
- **def**: `divisorDeg`, `IsPrincipal`, `GraphLinEquiv`, `chipFire`, `graphGenus`, `vertexDegree`, `canonicalDivisor`, `jacobianAnalogy`
- **theorem**: `lin_equiv_refl`, `lin_equiv_symm`, `lin_equiv_trans`, `lin_equiv_is_equivalence`, `principal_divisor_degree_zero`, `lin_equiv_preserves_degree`, `chip_fire_preserves_class`, `canonical_divisor_degree`

#### `HigherCategoricalBridges.lean` (140 lines)
*Source: `LanglandsBridges/HigherCategoricalBridges.lean`*

- **structure**: `SimplicialType`, `SimplicialMap`, `LanglandsBridge`, `TriangulatedData`, `DerivedFunctor`
- **def**: `adjunction_compose`, `bridge_monad`, `bridge_comonad`, `SimplicialMap`, `SimplicialMap`, `bridgeStrength`, ... +3 more
- **theorem**: `triangle_identity_left`, `triangle_identity_right`

#### `HilbertPolyaOperator.lean` (154 lines)
*Source: `LanglandsBridges/HilbertPolyaOperator.lean`*

- **structure**: `SelfAdjointMatrix`, `OrientedEdge`
- **def**: `hashimotoMatrix`, `hilbertPolyaOperator`, `heatTrace`, `spectralZeta`
- **theorem**: `laplacian_is_selfadjoint`, `laplacian_psd`, `laplacian_zero_eigenvalue`, `ihara_det_simplification`, `ramanujan_critical_line`, `vieta_sum_of_roots`, ... +3 more

#### `IdempotentTheory.lean` (80 lines)
*Source: `LanglandsBridges/IdempotentTheory.lean`*

- **structure**: `OrthogonalIdempotentSystem`
- **theorem**: `idempotent_complement`, `idempotent_orthogonal_right`, `idempotent_orthogonal_left`, `isIdempotentElem_complement`, `diagonal_01_idempotent`, `diagonal_01_trace_nonneg`, ... +4 more

#### `IharaZeta.lean` (99 lines)
*Source: `LanglandsBridges/IharaZeta.lean`*

- **structure**: `IharaGraph`, `RegularIharaGraph`
- **def**: `IharaGraph`, `IharaGraph`, `IharaGraph`, `IharaGraph`, `onesVec`, `IsRamanujan`
- **theorem**: `regular_degree_matrix_eq`, `ihara_matrix_regular_simplification`, `laplacian_ones_eq_zero`, `regular_degree_sum`, `regular_total_adjacency`, `ramanujan_spectral_gap`, `trace_adj_zero`

#### `QuantumIdempotent.lean` (133 lines)
*Source: `LanglandsBridges/QuantumIdempotent.lean`*

- **structure**: `DensityMatrix`, `PureState`, `SpectralDecomposition`, `QuantumChannel`, `UnitalChannel`
- **def**: `isMixedState`, `purity`, `SpectralDecomposition`, `vonNeumannEntropy`, `marchenkoPasturSupport`
- **theorem**: `pure_state_trace_sq`, `purity_of_pure`, `spectral_trace_one`, `purity_lower_bound_from_spectrum`, `pure_state_zero_entropy`, `mp_support_width`, `unital_preserves_idempotent_trace`

#### `SpectralReciprocity.lean` (73 lines)
*Source: `LanglandsBridges/SpectralReciprocity.lean`*

- **structure**: `HeckeOperator`, `SpectralArithmeticBridge`, `SelbergIharaBridge`
- **def**: `partialEulerProduct`, `selbergIharaInstances`
- **theorem**: `trace_adj_diagonal`, `trace_sq_eq_sum`, `euler_product_trivial_char`, `ramanujan_gap_explicit`, `ramanujan_gap_nonneg`

#### `TropicalLanglandsVarieties.lean` (175 lines)
*Source: `LanglandsBridges/TropicalLanglandsVarieties.lean`*

- **structure**: `TropicalValuation`, `TropicalizationData`, `PolyhedralComplex`, `TropicalDivisorPC`, `MetricGraph`, `CurveTropicalization`, `MetricGraphMorphism`, `TropicalJacobian`
- **def**: `tropAdd`, `tropMul`, `TropicalVariety`, `TropicalDivisorPC`, `MetricGraph`, `MetricGraph`, ... +4 more
- **theorem**: `tropAdd_comm`, `tropAdd_assoc`, `tropAdd_top`, `tropMul_comm`, `metric_graph_canonical_degree`, `tropicalization_genus_invariance`, `tropicalization_functorial`, `MetricGraphMorphism`

### CategoryTheory

*8 files, 94 declarations, 632 lines*

#### `AlgebraicKTheory.lean` (27 lines)
*Source: `CategoryTheory/Core/AlgebraicKTheory.lean`*

- **theorem**: `z_units`, `steinberg_neg1`, `index_euler`, `ns_energy_bound`, `ns_scaling`, `ns_2d_regularity`

#### `CategoryTheory.lean` (66 lines)
*Source: `CategoryTheory/Core/CategoryTheory.lean`*

- **theorem**: `functor_preserves_iso`, `id_functor_map`, `functor_comp_assoc`, `functor_comp_id`

#### `CategoryTheoryDeep.lean` (32 lines)
*Source: `CategoryTheory/Core/CategoryTheoryDeep.lean`*

- **theorem**: `equivalence_is_adjunction`, `nat_trans_assoc`, `adjunction_gives_monad`, `function_comp_assoc`

#### `CategoryTheoryExploration.lean` (38 lines)
*Source: `CategoryTheory/Core/CategoryTheoryExploration.lean`*

- **theorem**: `functor_preserves_id`, `functor_preserves_comp`, `finset_product_card`, `finset_sum_card`, `type_assoc_card`, `exponential_card`

#### `HomologicalAlgebra.lean` (72 lines)
*Source: `CategoryTheory/Core/HomologicalAlgebra.lean`*

- **theorem**: `d_squared_zero`, `euler_char_two`, `euler_char_three`, `torus_euler_char`, `sphere_euler_char`, `genus_euler_char`, `rp2_euler_char`, `ses_rank_nullity`

#### `Foundations.lean` (191 lines)
*Source: `CategoryTheory/LanglandsProgram/Foundations.lean`*

- **structure**: `DirichletCharData`, `GL1LanglandsData`, `ModularFormData`, `EllipticCurveData`
- **inductive**: `LanglandsDualPair`, `FunctorialityInstance`
- **def**: `IsMultiplicativeArithFn`, `IsCompletelyMultiplicative`, `trivialChar`, `partialDirichletSum`, `riemannZetaPartial`, `eulerFactor`, ... +7 more
- **theorem**: `complMult_implies_mult`, `trivialChar_one`, `zetaPartial_eq_dirichletSum`, `zeta_euler_factor`, `legendre_mul`, `GL_is_self_dual`, ... +7 more

#### `LFunctions.lean` (101 lines)
*Source: `CategoryTheory/LanglandsProgram/LFunctions.lean`*

- **structure**: `SelbergClassAxioms`, `BSDData`
- **inductive**: `SymmetricPowerStatus`
- **def**: `zetaPartialSum`, `basel_problem_statement`, `zeta_pole_statement`, `dirichletL`, `ecLFactor`, `rankinSelbergPartial`, `symmetricPowerResults`, `ec_32_ap`
- **theorem**: `trivial_char_gives_zeta`, `sym2_is_proved`, `sym3_is_proved`, `ap_matching_is_exact`

#### `Reciprocity.lean` (105 lines)
*Source: `CategoryTheory/LanglandsProgram/Reciprocity.lean`*

- **inductive**: `SplittingType`
- **def**: `gaussSumPartial`, `dirichletLPartial`, `splittingFromLegendre`, `artinMap`, `ellipticCurveLFactor`, `gammaFactor`, `completedLPartial`
- **theorem**: `quadratic_reciprocity_langlands`, `legendre_mul_recip`, `artinMap_mul`, `ec_minus_x_a3`, `ec_minus_x_a5`, `ec_minus_x_a7`, ... +5 more

### Combinatorics

*8 files, 76 declarations, 768 lines*

#### `Combinatorics.lean` (171 lines)
*Source: `Combinatorics/Core/Combinatorics.lean`*

- **def**: `shatters`
- **theorem**: `generalized_pigeonhole`, `pigeonhole_not_injective`, `double_counting`, `sum_binomial`, `partial_binomial_sum_le`, `sperner_bound`, ... +3 more

#### `ExtremalGraphTheory.lean` (33 lines)
*Source: `Combinatorics/Core/ExtremalGraphTheory.lean`*

- **def**: `tower`
- **theorem**: `turan_3_2`, `turan_4_2`, `turan_6_2`, `windmill_center_degree`, `ramsey_3_4_lower`, `ramsey_4_4_value`, ... +6 more

#### `GameTheory.lean` (49 lines)
*Source: `Combinatorics/Core/GameTheory.lean`*

- **inductive**: `PDAction`
- **def**: `pd_payoff`, `mp_payoff`
- **theorem**: `defect_dominant_p1`, `defect_dominant_p2`, `matching_pennies_no_pure_ne`, `second_price_truthful`, `shapley_efficiency_2player`, `finite_strategies`

#### `GraphTheoryExploration.lean` (49 lines)
*Source: `Combinatorics/Core/GraphTheoryExploration.lean`*

- **theorem**: `complete_graph_edges_3`, `complete_graph_edges_4`, `complete_graph_edges_5`, `euler_tetrahedron`, `euler_cube`, `euler_octahedron`, ... +6 more

#### `MatroidTheory.lean` (42 lines)
*Source: `Combinatorics/Core/MatroidTheory.lean`*

- **structure**: `RankFunction`
- **theorem**: `rank_empty`, `rank_le_ground`, `rank_unit_increase`, `greedy_comparison`

#### `RamseyTheory.lean` (113 lines)
*Source: `Combinatorics/Core/RamseyTheory.lean`*

- **theorem**: `ramsey_3_3_upper`, `ramsey_3_3_lower`, `schur_two_colors`, `pigeonhole_mod`, `five_ints_mod4`, `combinatorial_line_exists`

#### `SauerShelah.lean` (283 lines)
*Source: `Combinatorics/Core/SauerShelah.lean`*

- **def**: `Shatters`, `proj`, `embed`
- **theorem**: `sauer_shelah`
- **lemma**: `last_not_mem_embed`, `proj_embed`, `proj_embed_union_last`, `embed_card`, `embed_union_last_card`, `embed_inter_eq`, ... +7 more

#### `SpectralGraphTheory.lean` (28 lines)
*Source: `Combinatorics/Core/SpectralGraphTheory.lean`*

- **theorem**: `petersen_eig`, `path_ac`, `bin_tree`, `tern_tree`

### ComplexityTheory

*8 files, 175 declarations, 1,422 lines*

#### `BooleanFunctions.lean` (240 lines)
*Source: `ComplexityTheory/BooleanFunctions.lean`*

- **def**: `hammingWeight`, `hammingDist`, `flipBit`, `sensitivityAt`, `IsCertificate`, `IsMonotone`, `IsSunflower`, `parity`
- **noncomp. def**: `sensitivity`, `influence`, `totalInfluence`
- **theorem**: `hammingDist_comm`, `hammingDist_eq_zero`, `flipBit_flipBit`, `flipBit_support`, `sensitivityAt_le`, `sensitivity_le`, ... +14 more

#### `CoherenceStratified.lean` (191 lines)
*Source: `ComplexityTheory/CoherenceStratified.lean`*

- **structure**: `CommComplexity`, `CircuitDepth`, `Defect`
- **inductive**: `CoherenceTier`
- **def**: `CoherenceTier`, `isConstantComm`, `isLogComm`, `isPolyComm`, `isConstantDepth`, `isLogDepth`, ... +4 more
- **noncomp. def**: `approxRatio`
- **theorem**: `tier0_le`, `tier_total`, `le_tier3`, `log_implies_poly`, `binomial_sum`, `info_lower_bound`, ... +5 more

#### `CombinatorialBounds.lean` (154 lines)
*Source: `ComplexityTheory/CombinatorialBounds.lean`*

- **def**: `binomialPartialSum`
- **theorem**: `decision_tree_depth_bound`, `binomialPartialSum_le_pow`, `choose_zero`, `choose_self`, `choose_one`, `binomialPartialSum_zero`, ... +10 more

#### `Foundations.lean` (175 lines)
*Source: `ComplexityTheory/Foundations.lean`*

- **def**: `hammingWeight`, `hammingDist`, `flipBit`, `sensitivity`, `IsCertificate`, `boolLE`, ... +3 more
- **theorem**: `hammingWeight_le`, `hammingDist_comm`, `hammingDist_triangle`, `hammingDist_eq_zero_iff`, `sensitivity_le`, `empty_certificate_of_const`, ... +8 more

#### `IdempotentProofComplexity.lean` (184 lines)
*Source: `ComplexityTheory/IdempotentProofComplexity.lean`*

- **structure**: `ProofSystem`
- **def**: `IsIdempotentOp`, `ProofSystem`, `clauseWidth`, `resolve`, `IsIdempotentUnary`, `IsAbsorbing`
- **noncomp. def**: `interpolate`
- **theorem**: `min_idempotent`, `max_idempotent`, `gcd_idempotent`, `lcm_idempotent`, `and_idempotent`, `or_idempotent`, ... +10 more

#### `ParameterizedStereographic.lean` (183 lines)
*Source: `ComplexityTheory/ParameterizedStereographic.lean`*

- **structure**: `ParamInstance`, `Kernel`
- **inductive**: `Compactified`
- **def**: `embed`, `extendFn`, `Kernel`, `Kernel`, `IsFPT`
- **noncomp. def**: `stereoProject`, `stereoInverse`, `coveringNumber`, `stereoDistance`
- **theorem**: `extendFn_finite`, `extendFn_infinity`, `stereoInverse_on_circle`, `linear_implies_poly`, `covering_number_pos`, `const_param_in_P`, ... +4 more

#### `SpectralCollapse.lean` (164 lines)
*Source: `ComplexityTheory/SpectralCollapse.lean`*

- **structure**: `SATInstance`, `SpectralCollapseThreshold`, `LovaszTheta`
- **def**: `AdjacencyMatrix`, `clauseDegree`, `varDegree`
- **noncomp. def**: `chiChar`, `boolToReal`, `spectralEnergy`, `totalSpectralEnergy`, `SATInstance`, `spectralGap`
- **theorem**: `chiChar_sq`, `chiChar_mul_disjoint`, `spectralEnergy_nonneg`, `spectralEnergy_sum`, `spectralGap_nonneg`, `sat_threshold_lower_bound`, `lovasz_sandwich`

#### `TropicalCircuits.lean` (131 lines)
*Source: `ComplexityTheory/TropicalCircuits.lean`*

- **structure**: `TropicalMonomial`, `TropicalCircuit`
- **inductive**: `TropGate`
- **def**: `TropicalMonomial`, `TropicalMonomial`, `TropicalCircuit`
- **noncomp. def**: `minPlusMul`
- **theorem**: `tropical_add_idem`, `trop_add_eq_min`, `trop_mul_eq_add`, `minPlusMul_assoc`, `tropical_circuit_monomial_bound`, `tropical_no_counting`

### Computation/Factoring

*32 files, 805 declarations, 7,896 lines*

#### `GaussianBridge.lean` (186 lines)
*Source: `Computation/Factoring/AStar/GaussianBridge.lean`*

- **def**: `euclid_triple`
- **theorem**: `brahmagupta_fibonacci_Z`, `brahmagupta_fibonacci_alt`, `brahmagupta_fibonacci_N`, `sum_two_squares_mul`, `pythagorean_composition`, `euler_two_squares_factor`, ... +10 more

#### `IOFCore.lean` (164 lines)
*Source: `Computation/Factoring/InsideOut/IOFCore.lean`*

- **def**: `a`, `b`, `c`, `energy`
- **theorem**: `pythagorean_invariant`, `energy_nonneg`, `energy_strict_decrease`, `a_at_factor_step`, `b_divisible_at_factor_step`, `initial_a`, ... +3 more

#### `IOFDynamical.lean` (148 lines)
*Source: `Computation/Factoring/InsideOut/IOFDynamical.lean`*

- **structure**: `IOFState`
- **def**: `state`, `velocity`
- **theorem**: `same_factor_same_step`, `energy_at_factor`, `velocity_positive`, `constant_deceleration`, `multi_stride_gcd`, `at_least_one_step`

#### `IOFExplorations.lean` (166 lines)
*Source: `Computation/Factoring/InsideOut/IOFExplorations.lean`*

- **theorem**: `totient_sum_divisors`, `totient_prime`, `pyth_variety_scale`, `circle_param`, `euler_char`, `char_mult`, ... +22 more

#### `IOFSpeedup.lean` (133 lines)
*Source: `Computation/Factoring/InsideOut/IOFSpeedup.lean`*

- **def**: `leg_product`, `bleg_product`, `energy_at`
- **theorem**: `factor_in_product`, `factor_step_divides_bleg`, `energy_monotone_decreasing`, `factor_in_unique_interval`, `energy_drop_formula`, `cumulative_energy_drop`, `factor_square_condition`

#### `InsideOutFactor.lean` (326 lines)
*Source: `Computation/Factoring/InsideOut/InsideOutFactor.lean`*

- **def**: `applyInvBG1`, `applyInvBG2`, `applyInvBG3`, `findBerggrenParent`, `insideOutFactor`, `insideOutFactorAll`, ... +3 more
- **theorem**: `euclid_triple_valid`, `euclid_odd_leg`, `invB1_preserves_form`, `invB2_preserves_form`, `invB3_preserves_form`, `gcd_reveals_factor`, `parent_hyp_decreases`, `hyp_decrease_exact`

#### `InsideOutResearch.lean` (198 lines)
*Source: `Computation/Factoring/InsideOut/InsideOutResearch.lean`*

- **def**: `insideOutFactorV2`, `multiPolySieve`
- **theorem**: `euclid_thin_triple`, `factor_condition`, `four_k_sq_minus_one`, `factor_at_half_p`, `no_factor_before_half`, `invB1_preserves_pyth`, ... +10 more

#### `AlgebraicQuaternion.lean` (201 lines)
*Source: `Computation/Factoring/Other/AlgebraicQuaternion.lean`*

- **theorem**: `quaternion_norm_sq_mul`, `quaternion_normSq_nonneg`, `euler_four_square_identity`, `sum_of_squares_mul_four`, `brahmagupta_fibonacci`, `gaussian_norm_mul`, ... +18 more

#### `ChimeraFactoring.lean` (466 lines)
*Source: `Computation/Factoring/Other/ChimeraFactoring.lean`*

- **def**: `IsSmooth`
- **theorem**: `sq_sub_sq_factor`, `congruence_of_squares_zmod`, `factor_from_square_congruence_int`, `square_root_ambiguity`, `square_root_trichotomy`, `shor_algebraic_core`, ... +40 more

#### `ECDLP.lean` (451 lines)
*Source: `Computation/Factoring/Other/ECDLP.lean`*

- **inductive**: `ECPoint`
- **def**: `secp256k1_p`, `secp256k1_n`, `secp256k1_a`, `secp256k1_b`, `secp256k1_Gx`, `secp256k1_Gy`, ... +14 more
- **theorem**: `secp256k1_p_gt_two`, `secp256k1_p_odd`, `secp256k1_p_mod_4`, `secp256k1_p_bit_length`, `secp256k1_n_bit_length`, `secp256k1_n_lt_p`, ... +35 more

#### `FermatFactor.lean` (321 lines)
*Source: `Computation/Factoring/Other/FermatFactor.lean`*

- **def**: `fermatSearch`, `searchBerggrenTree`, `berggrenFermatFactor`
- **theorem**: `fermat_identity`, `odd_composite_fermat_rep`, `fermat_factorization_correct`, `fermat_nontrivial_factors`, `pyth_triple_diff_squares`, `pyth_triple_gives_factorization`, ... +7 more

#### `HarmonicResidueFactor.lean` (143 lines)
*Source: `Computation/Factoring/Other/HarmonicResidueFactor.lean`*

- **theorem**: `diff_sq_eq_factor`, `fermat_factor_nontrivial`, `fermat_factor_divides`, `odd_composite_diff_sq`, `diff_sq_construction`, `residue_sieve_filter`, ... +5 more

#### `IntegerDecoder.lean` (222 lines)
*Source: `Computation/Factoring/Other/IntegerDecoder.lean`*

- **structure**: `FourChannelSig`
- **def**: `d₁`, `d₃`, `jacobi_sum`, `fourChannelSig`
- **noncomp. def**: `r₂`, `r₄`
- **theorem**: `lagrange_four_squares`, `gaussian_norm_multiplicative`, `sum_two_squares_mul`, `channel_2_implies_4`, `fermat_sum_two_squares`, `euler_four_square_identity`, ... +3 more

#### `IntegerDiffraction.lean` (492 lines)
*Source: `Computation/Factoring/Other/IntegerDiffraction.lean`*

- **structure**: `at`
- **def**: `diffractionAmplitude`, `diffractionIntensity`, `autocorrelation`, `IsSidonSet`, `IsHomometric`, `translateSet`, ... +6 more
- **theorem**: `amplitude_singleton`, `intensity_singleton`, `amplitude_pair`, `intensity_nonneg`, `intensity_at_zero`, `intensity_empty`, ... +20 more

#### `HurwitzQuaternions.lean` (189 lines)
*Source: `Computation/Factoring/Quaternion/HurwitzQuaternions.lean`*

- **def**: `InSumSqLattice`, `InSumSqLattice4`, `IsPrimitiveQuadruple`
- **theorem**: `lattice_zero_mem`, `lattice_neg_mem`, `lattice_scale_mem`, `lattice4_zero_mem`, `lattice4_neg_mem`, `lattice4_scale_mem`, ... +20 more

#### `OctonionHurwitz.lean` (116 lines)
*Source: `Computation/Factoring/Quaternion/OctonionHurwitz.lean`*

- **def**: `mem_lattice3`, `mem_lattice4`
- **theorem**: `lattice3_zero_mem`, `lattice3_neg_mem`, `lattice_scale_mem`, `lattice4_zero_mem`, `lattice4_scale_mem`, `dim_advantage_4_3`, ... +9 more

#### `OctonionNorm.lean` (138 lines)
*Source: `Computation/Factoring/Quaternion/OctonionNorm.lean`*

- **def**: `quatNorm`
- **theorem**: `euler_four_square_identity`, `quadruple_from_params_valid`, `pell_obstacle`, `pell_obstacle_lambda`, `pell_obstacle_n1`, `pell_n2_fundamental`, ... +8 more

#### `OctonionQuaternion.lean` (137 lines)
*Source: `Computation/Factoring/Quaternion/OctonionQuaternion.lean`*

- **structure**: `IntQuaternion`
- **def**: `norm`, `mul`, `conj`, `sl2z_S`, `sl2z_T`
- **theorem**: `norm_mul`, `norm_eq_zero_iff`, `mul_conj_im_i`, `mul_conj_im_j`, `mul_conj_im_k`, `mul_conj_re`, ... +6 more

#### `QuaternionFactoring.lean` (135 lines)
*Source: `Computation/Factoring/Quaternion/QuaternionFactoring.lean`*

- **structure**: `IntQuaternion`
- **def**: `norm`, `mul`, `conj`
- **theorem**: `norm_mul`, `norm_nonneg`, `norm_eq_zero_iff`, `mul_conj`, `sl2z_S_preserves_norm`, `sl2z_T_quadruple`, `sum_four_squares_statement`, `gcd_extraction_nontrivial`

#### `QuaternionFactoringResearch.lean` (197 lines)
*Source: `Computation/Factoring/Quaternion/QuaternionFactoringResearch.lean`*

- **theorem**: `quaternion_norm_mul`, `quaternion_norm_nonneg`, `quaternion_norm_eq_zero`, `euler_four_square_identity`, `gaussian_norm_conj_product`, `gaussian_norm_divides`, ... +10 more

#### `QuaternionNorm.lean` (171 lines)
*Source: `Computation/Factoring/Quaternion/QuaternionNorm.lean`*

- **def**: `IsPythQuadruple`, `quatNorm`, `inQuadLattice`
- **theorem**: `euler_four_square_identity`, `quadruple_from_params_valid`, `quadruple_hypotenuse_nonneg`, `pell_obstacle`, `pell_obstacle_lambda`, `quatNorm_nonneg`, ... +7 more

#### `AdvancedTheorems.lean` (196 lines)
*Source: `MetaFactoring/AdvancedTheorems.lean`*

- **theorem**: `euler_criterion_neg_one`, `fibonacci_period_mod2`, `fibonacci_period_mod3`, `fib_entry_point_divides`, `fib_gcd_identity`, `fib_dvd_of_dvd`, ... +21 more

#### `BridgeTheorems.lean` (131 lines)
*Source: `MetaFactoring/BridgeTheorems.lean`*

- **theorem**: `cassini_identity`, `fib_addition`, `totient_multiplicative`, `totient_prime`, `units_card_prime`, `orbit_size_bound`, ... +7 more

#### `Core.lean` (257 lines)
*Source: `MetaFactoring/Core.lean`*

- **noncomp. def**: `sqMap`
- **theorem**: `fibonacci_search_reduction`, `fib_carry_rule`, `fib_adjacency_rule`, `hyperbola_gives_divisor`, `factor_bounded`, `sq_iter_eq_pow`, ... +19 more

#### `FutureDirections.lean` (435 lines)
*Source: `MetaFactoring/FutureDirections.lean`*

- **theorem**: `multi_lens_advantage`, `advantage_unbounded`, `information_bound`, `seven_lens_factor`, `pisano_period_exists`, `fib_sq_sum`, ... +27 more

#### `FutureExploration.lean` (310 lines)
*Source: `MetaFactoring/FutureExploration.lean`*

- **def**: `IsSmooth`, `lucas`, `tribonacci`
- **theorem**: `smooth_one`, `smooth_number_closure`, `smooth_number_divisor`, `smooth_number_gcd`, `smooth_all_below_base`, `smooth_monotone`, ... +35 more

#### `FutureResearchTheorems.lean` (448 lines)
*Source: `MetaFactoring/FutureResearchTheorems.lean`*

- **theorem**: `padic_val_additive`, `tropical_min_associative`, `tropical_min_commutative`, `tropical_factorization_constraint`, `tropical_distributivity`, `padic_val_prime_pow`, ... +43 more

#### `NewTheorems.lean` (217 lines)
*Source: `MetaFactoring/NewTheorems.lean`*

- **theorem**: `two_square_identity`, `four_square_identity`, `eight_square_identity`, `dimension_hierarchy`, `fib_mod_periodic`, `fib_doubling`, ... +15 more

#### `OpenQuestions.lean` (286 lines)
*Source: `MetaFactoring/OpenQuestions.lean`*

- **theorem**: `generalized_lens_advantage`, `lens_monotonicity`, `lens_composition_commutes`, `crt_exact_reduction`, `pisano_period_divides_p_sq_sub_one`, `pisano_period_composes`, ... +18 more

#### `OpenQuestionsResearch.lean` (348 lines)
*Source: `MetaFactoring/OpenQuestionsResearch.lean`*

- **def**: `IsSmooth`, `lucas`, `tribonacci`
- **theorem**: `smooth_one`, `smooth_submonoid_closure`, `smooth_filtration`, `smooth_divisor_closed`, `smooth_gcd_closed`, `smooth_below_base`, ... +31 more

#### `PhaseII.lean` (327 lines)
*Source: `MetaFactoring/PhaseII.lean`*

- **theorem**: `padic_val_additive`, `tropical_factorization_constraint`, `tropical_independence`, `tropical_val_zero_of_coprime`, `semiprime_valuation`, `tropical_distributivity`, ... +45 more

#### `PhaseIIFormal.lean` (241 lines)
*Source: `MetaFactoring/PhaseIIFormal.lean`*

- **def**: `IsSmooth`, `mlcReduction`, `tribonacci`
- **noncomp. def**: `dickmanOnePiece`, `Lnotation`
- **theorem**: `isSmooth_one`, `isSmooth_mul`, `isSmooth_mono`, `isSmooth_of_dvd`, `prime_isSmooth_self`, `dickman_one`, ... +16 more

### Computation/Fibonacci

*3 files, 53 declarations, 608 lines*

#### `FibonacciArithmetic.lean` (143 lines)
*Source: `Computation/Fibonacci/FibonacciArithmetic.lean`*

- **theorem**: `fibonacci_carry_rule`, `fibonacci_double_carry`, `fibonacci_gcd_identity`, `fib_dvd_of_dvd`, `euclid_pythagorean`, `fib_mod_periodic`, ... +4 more

#### `Basic.lean` (340 lines)
*Source: `FibonacciFactoring/Basic.lean`*

- **def**: `IsValidZeckendorf`, `zeckendorfValue`, `noAdjacentOnes`
- **theorem**: `fib_adjacency_rule`, `fib_carry_rule`, `fib_pos`, `fib_strict_mono`, `fib_ge_half`, `noAdjacentOnes_eq_fib`, ... +20 more

#### `ResearchFormalization.lean` (125 lines)
*Source: `FibonacciFactoring/ResearchFormalization.lean`*

- **def**: `ValidZeckendorfBits`
- **theorem**: `search_space_ratio`, `search_space_shrinks`, `fib_gcd_identity`, `fib_divides_multiples`, `prime_fib_divisibility`, `fib_coprime_adjacent`, ... +7 more

### Computation/OctonionGates

*2 files, 66 declarations, 524 lines*

#### `Foundations.lean` (318 lines)
*Source: `Computation/OctonionGates/Foundations.lean`*

- **structure**: `OctGate`, `OctGate`, `unique`
- **inductive**: `TrialityRep`
- **def**: `conj`, `re`, `basis`, `idGate`, `comp`, `permGate`, ... +6 more
- **noncomp. def**: `normSq`, `givensRotation`
- **theorem**: `ext`, `normSq_nonneg`, `conj_conj`, `re_conj`, `eight_square_identity`, `comp_assoc`, ... +17 more

#### `Gates.lean` (206 lines)
*Source: `Computation/OctonionGates/Gates.lean`*

- **def**: `IsOrthogonal`, `IsSpecialOrthogonal`, `fanoLines`, `g2_lie_algebra_dim`
- **noncomp. def**: `givensMatrix`
- **theorem**: `identity_in_SO8`, `so8_dimension`, `g2_dimension`, `g2_dim_formula`, `givens_orthogonal`, `max_givens_for_SO8`, ... +14 more

### Computation/Oracles

*81 files, 1985 declarations, 18,272 lines*

#### `ArithmeticIdentities.lean` (126 lines)
*Source: `Computation/OracleCouncil/ArithmeticIdentities.lean`*

- **theorem**: `gauss_sum`, `sum_squares`, `nicomachus`, `sum_fourth_powers`, `alternating_sum_squares`, `sum_consecutive_products`, `power_sum_telescope`

#### `CombinatorialBridges.lean` (131 lines)
*Source: `Computation/OracleCouncil/CombinatorialBridges.lean`*

- **theorem**: `triangular_eq_choose`, `hockey_stick`, `pascal_row_sum`, `alternating_row_sum`, `consecutive_product_div_factorial`, `binomial_symmetry`, `sum_binomial_squares`

#### `DivisibilityPatterns.lean` (128 lines)
*Source: `Computation/OracleCouncil/DivisibilityPatterns.lean`*

- **theorem**: `two_consecutive_even`, `three_consecutive_div_six`, `sum_sq_divisibility`, `fifth_power_minus_self`, `square_mod_four`, `square_mod_eight`, ... +3 more

#### `SymmetryPrinciples.lean` (113 lines)
*Source: `Computation/OracleCouncil/SymmetryPrinciples.lean`*

- **theorem**: `am_gm_two_nat`, `cauchy_schwarz_discrete`, `am_ge_gm`, `schur_ineq`, `sum_degrees_even`, `pigeonhole_simple`

#### `UnifyingBridges.lean` (135 lines)
*Source: `Computation/OracleCouncil/UnifyingBridges.lean`*

- **theorem**: `bridge_arith_comb`, `number_as_choose`, `choose_factorial_identity`, `fermat_little`, `binomial_row_sum_bridge`, `euler_totient_sum`, `geometric_series_int`

#### `AutomatedTheoryOracle.lean` (280 lines) ⚠️ 1 sorry
*Source: `Computation/Oracles/Applications/AutomatedTheoryOracle.lean`*

- **structure**: `FormalSystem`, `TheoryOracle`
- **def**: `FormalSystem`, `TheoryOracle`, `TheoryOracle`, `cantorPair`, `cantorUnpair`, `composeOracles`, ... +4 more
- **theorem**: `sound_complete_oracle_exists`, `cantor_pair_diagonal`, `dovetail_pairs_at_depth`, `dovetail_coverage`, `oracle_hierarchy_strict`, `compose_range_contains_left`, ... +11 more

#### `BootstrapDynamics.lean` (263 lines)
*Source: `Computation/Oracles/Applications/BootstrapDynamics.lean`*

- **def**: `bootstrapT`, `lyapunovV`, `IsIdempotent`, `cosineSim`
- **theorem**: `bootstrapT_one`, `bootstrapT_fixed_zero`, `bootstrapT_fixed_one`, `bootstrapT_critical_point`, `bootstrapT_fixed_points`, `bootstrapT_improves_above_critical`, ... +17 more

#### `FiveDreams.lean` (385 lines)
*Source: `Computation/Oracles/Applications/FiveDreams.lean`*

- **structure**: `DepthStratifiedSystem`, `ValuedOracle`, `MathOracle`, `DiscoveryProcess`
- **def**: `IsWellOrdered`, `combinedTruths`, `IncomparableOracles`, `MathOracle`, `DiscoveryProcess`
- **noncomp. def**: `discoveryTime`
- **theorem**: `density_decay_law`, `density_exponential_bound`, `compression_principle_ordered`, `well_ordered_max`, `compression_advantage`, `hierarchy_cannot_collapse`, ... +14 more

#### `Main.lean` (248 lines)
*Source: `Computation/Oracles/Applications/Main.lean`*

- **def**: `IsNPotent`, `bootstrapMap`, `bootstrapFamily`, `tripotentPlus`, `tripotentMinus`
- **theorem**: `isNPotent_two_iff_idempotent`, `npotent_spectrum`, `oracle_spectrum_binary`, `tripotent_spectrum`, `npotent_hierarchy`, `idempotent_is_npotent`, ... +11 more

#### `MetaOracleFiveQuestions.lean` (178 lines)
*Source: `Computation/Oracles/Applications/MetaOracleFiveQuestions.lean`*

- **structure**: `ConjectureSystem`, `QualityOracleSystem`, `ContractionMap`
- **def**: `ConjectureSystem`
- **theorem**: `ConjectureSystem`, `ConjectureSystem`, `theorem_discovery`, `quality_mono_iter`, `quality_bounded_by_capacity`, `ContractionMap`, ... +5 more

#### `NumberLineOracle.lean` (303 lines)
*Source: `Computation/Oracles/Applications/NumberLineOracle.lean`*

- **structure**: `FormalSystem`, `GodelEncoding`, `ChaitinOmega`, `NumberLineOracle`, `ProblemSpace`, `OracleApprox`
- **def**: `FormalSystem`, `truthSet`, `oracleReal`, `NumberLineOracle`, `NumberLineOracle`, `NumberLineOracle`, ... +5 more
- **theorem**: `oracleReal_nonneg`, `omega_monotone`, `agree_refl`, `agree_symm`, `agree_trans`, `and_trueSet`, ... +18 more

#### `OracleApplicationsFrontier.lean` (356 lines) ⚠️ 1 sorry
*Source: `Computation/Oracles/Applications/OracleApplicationsFrontier.lean`*

- **structure**: `QuantumChannel`, `ConsciousnessModel`
- **def**: `IsOracle`, `TruthSet`, `boolClauseVal`, `relu`, `neuron`, `IsQuantumOracle`, ... +6 more
- **theorem**: `oracle_range_eq_truth`, `oracle_iterate_collapse`, `sat_clause_satisfied`, `tropical_and_bound`, `tropical_sat_soundness`, `relu_idempotent`, ... +25 more

#### `OracleBootstrapGPT2.lean` (237 lines)
*Source: `Computation/Oracles/Applications/OracleBootstrapGPT2.lean`*

- **structure**: `GPT2Config`
- **def**: `IsOracleGPT`, `threshold`, `gpt2Small`, `paramsPerLayer`, `embeddingParams`, `totalGPT2Params`, ... +7 more
- **theorem**: `threshold_is_oracle`, `gpt2_param_count_approx`, `gpt2_4bit_size`, `bootstrap_fixed_zero`, `bootstrap_fixed_one`, `bootstrap_fixed_half`, ... +11 more

#### `OracleMillennium.lean` (116 lines)
*Source: `Computation/Oracles/Applications/OracleMillennium.lean`*

- **structure**: `RatPoint`
- **def**: `isSatisfiable`, `genus_plane_curve`, `euler_char_surface`
- **theorem**: `brute_force_sat`, `sat_fraction_bound`, `cook_levin_bound`, `zeta_2_prefactor`, `pnt_10`, `pnt_100`, ... +19 more

#### `OracleMoonshots.lean` (108 lines)
*Source: `Computation/Oracles/Applications/OracleMoonshots.lean`*

- **def**: `OraclesAgreeV2`, `OraclesStronglyAgreeV2`, `relu`
- **theorem**: `fermat_sum_two_sq_5`, `fermat_sum_two_sq_13`, `fermat_sum_two_sq_17`, `fermat_sum_two_sq_29`, `fermat_sum_two_sq_37`, `gaussian_factoring_info`, ... +9 more

#### `OracleNewHypotheses.lean` (183 lines)
*Source: `Computation/Oracles/Applications/OracleNewHypotheses.lean`*

- **def**: `oracleBootstrap`, `oracleBootstrap_deriv`, `IsNPotent`, `nPotentSet`
- **theorem**: `oracleBootstrap_fixed_zero`, `oracleBootstrap_fixed_one`, `oracleBootstrap_fixed_half`, `oracleBootstrap_deriv_zero`, `oracleBootstrap_deriv_one`, `oracleBootstrap_deriv_half`, ... +8 more

#### `ThreeDreams.lean` (367 lines)
*Source: `Computation/Oracles/Applications/ThreeDreams.lean`*

- **structure**: `DeductiveSystem`, `InterferenceSystem`, `FiniteTheoryPair`, `MathCorpus`, `ExplorationSystem`, `InterferenceDepthConnection`
- **def**: `emergentContent`, `exhibitsInterference`, `interferenceRatio`, `theoremValue`, `optimalDepth`, `balancedSystem`, `specializationIndex`, `generalizationIndex`
- **theorem**: `emergent_subset_combined`, `emergent_empty_of_subset`, `combined_contains_parts`, `interference_unbounded`, `interferenceRatio_nonneg`, `value_zero_at_origin`, ... +11 more

#### `UniversalOracleTeam.lean` (522 lines)
*Source: `Computation/Oracles/Applications/UniversalOracleTeam.lean`*

- **structure**: `UniversalOracle`, `OracleProblem`, `OracleReduction`, `OracleThermodynamics`, `AgentAlpha`, `AgentBeta`, ... +5 more
- **inductive**: `OracleOutput`
- **def**: `UniversalOracle`, `tropAdd`, `tropMul`, `gravPotential`, `gravProjection`, `shannonEntropy`, ... +13 more
- **theorem**: `tropAdd_comm`, `tropAdd_assoc`, `tropMul_comm`, `tropMul_assoc`, `tropMul_tropAdd`, `tropAdd_idem`, ... +18 more

#### `AlgorithmicUniversalOracle.lean` (246 lines)
*Source: `Computation/Oracles/Core/AlgorithmicUniversalOracle.lean`*

- **structure**: `with`, `StrangeLoop`
- **def**: `IsOracle`, `FixedPointSet`, `relu`, `IsIdempotentMod`, `IsProjectionMatrix`
- **theorem**: `oracle_image_sub_fixed`, `oracle_fixed_sub_image`, `oracle_master_equation`, `oracle_rank_eq`, `relu_idempotent`, `relu_nonneg`, ... +18 more

#### `GoodhartsRepulsor.lean` (117 lines)
*Source: `Computation/Oracles/Core/GoodhartsRepulsor.lean`*

- **structure**: `GoodhartSystem`, `SelfOptimizingOracle`
- **def**: `IsRepulsor`, `IsAttractor`, `nearOptimalSet`, `alignmentDecay`
- **theorem**: `goodhart_divergence_exists`, `not_attractor_and_repulsor`, `self_optimizing_bounded_convergence`, `multi_proxy_contained`, `alignment_monotone_decay`, `alignment_tendsto_zero`

#### `IdempotentCategory.lean` (104 lines)
*Source: `Computation/Oracles/Core/IdempotentCategory.lean`*

- **structure**: `RetrPair`
- **def**: `IsIdem`, `RetrPair`, `IdemRefines`
- **theorem**: `isIdem_id`, `retrPair_idempotent`, `functor_preserves_idem`, `idemRefines_refl`, `idemRefines_id`, `idemRefines_trans`

#### `InverseOracle.lean` (193 lines)
*Source: `Computation/Oracles/Core/InverseOracle.lean`*

- **structure**: `InverseOracle`, `OracleEncoding`
- **def**: `canonical`, `compose`, `identity`, `pullback`, `pushforward`, `natOracle`, `fromEncodable`, `primeOracle`
- **theorem**: `bijective_singleton`, `compose_identity`, `mem_pullback`, `mem_pushforward`, `pullback_id`, `pullback_comp`, ... +6 more

#### `NeuralCollapse.lean` (101 lines)
*Source: `Computation/Oracles/Core/NeuralCollapse.lean`*

- **def**: `simplexETFGram`, `frameOperator`, `IsTightFrame`
- **theorem**: `simplexETFGram_diag`, `simplexETFGram_off_diag`, `simplexETFGram_symmetric`, `frameOperator_symmetric`, `simplex_etf_max_margin`, `orthogonal_projection_idempotent`, ... +3 more

#### `NoisyOracle.lean` (63 lines)
*Source: `Computation/Oracles/Core/NoisyOracle.lean`*

- **noncomp. def**: `Oracle`
- **theorem**: `carrier_union_anti_carrier`, `carrier_disjoint_anti`, `anti_total_disagreement`, `anti_toFinset`, `oracle_card_add_anti_card`

#### `OAMFoundations.lean` (343 lines)
*Source: `Computation/Oracles/Core/OAMFoundations.lean`*

- **structure**: `StokesVector`, `BSMatrix`, `Qubit`
- **def**: `shannonCapacity`, `totalCapacity`, `totalCharge`, `horizontal`, `vertical`, `rightCircular`, ... +10 more
- **theorem**: `fourier_mode_integral_zero`, `fourier_mode_integral_id`, `oam_orthogonality`, `shannonCapacity_nonneg`, `capacity_doubles_with_modes`, `capacity_additive`, ... +13 more

#### `OracleAboutOracle.lean` (200 lines)
*Source: `Computation/Oracles/Core/OracleAboutOracle.lean`*

- **def**: `IsOracle`, `TruthSet`, `oracleIter`, `MetaOracle`, `OracleRefines`, `oracleEntropyLoss`
- **theorem**: `oracle_output_is_truth`, `oracle_on_truth_is_id`, `oracle_range_eq_truth`, `oracle_compose_idem`, `oracle_converges_in_one_step`, `truth_set_invariant`, ... +10 more

#### `OracleAlgebra.lean` (207 lines)
*Source: `Computation/Oracles/Core/OracleAlgebra.lean`*

- **def**: `OracleKernel`
- **theorem**: `idempotent_pow_eq`, `commuting_idempotents_product`, `idempotent_mul_comm`, `oracle_comp_self`, `id_is_oracle`, `const_is_oracle`, ... +13 more

#### `OracleAnalysis.lean` (226 lines)
*Source: `Computation/Oracles/Core/OracleAnalysis.lean`*

- **theorem**: `oracle_partial_correctness`, `search_space_size`, `search_space_exponential_growth`, `composite_has_small_factor`, `trial_division_correct`, `bit_flip_change`, ... +6 more

#### `OracleBootstrap.lean` (175 lines)
*Source: `Computation/Oracles/Core/OracleBootstrap.lean`*

- **def**: `IsOracle`, `oracleBootstrapScalar`
- **theorem**: `oracle_image_eq_fixedPoints`, `oracle_retraction`, `oracle_comp_self`, `oracle_spectrum`, `bootstrap_fixed_zero`, `bootstrap_fixed_one`, ... +9 more

#### `OracleComplexity.lean` (113 lines)
*Source: `Computation/Oracles/Core/OracleComplexity.lean`*

- **structure**: `QueryStrategy`
- **def**: `OracleReducesTo`, `OracleEquiv`, `OracleComp`, `OracleIdentity`
- **theorem**: `oracle_reduces_refl`, `oracle_reduces_trans`, `oracle_equiv_refl`, `oracle_equiv_symm`, `oracle_equiv_trans`, `query_bound_card`, ... +6 more

#### `OracleCompression.lean` (89 lines)
*Source: `Computation/Oracles/Core/OracleCompression.lean`*

- **def**: `IsRetractionV2`, `distToTruthV2`
- **theorem**: `retraction_is_oracle_v2`, `retraction_range_v2`, `fundamental_pythagorean_v2`, `gcd_oracle_factors_v2`, `gcd_nontrivial_v2`, `factoring_via_gcd_v2`, ... +6 more

#### `OracleConsultation.lean` (153 lines)
*Source: `Computation/Oracles/Core/OracleConsultation.lean`*

- **def**: `stereoX`, `stereoY`, `oracleKernel`, `relu`
- **theorem**: `stereo_homomorphism`, `oracle_kernel_equiv`, `oracle_kernel_unique_truth`, `surjective_fin_is_bijective`, `gaussian_norm_mult`, `gaussian_norm_mult_alt`, ... +9 more

#### `OracleCouncil.lean` (287 lines)
*Source: `Computation/Oracles/Core/OracleCouncil.lean`*

- **structure**: `LocalGlobalPrinciple`
- **def**: `stereoForward`, `stereoInverse`, `poincare_local_global`
- **theorem**: `one_plus_sq_pos`, `one_plus_sq_ne_zero`, `stereo_inverse_on_circle`, `stereo_roundtrip`, `inverse_stereo_roundtrip`, `stereo_conformal_factor_pos`, ... +6 more

#### `OracleDimensionReduction.lean` (384 lines)
*Source: `Computation/Oracles/Core/OracleDimensionReduction.lean`*

- **structure**: `OracleSection`
- **def**: `canonical_section`, `collapse_to_one`, `embed_from_one`, `oracle_projection`, `oracle_refines`, `oracle_kernel`, `oracle_lift`, `oracle_dimension`
- **theorem**: `constant_is_oracle`, `constant_oracle_fixedPoints`, `constant_range_singleton`, `constant_oracle_card`, `canonical_section_embedding`, `round_trip`, ... +34 more

#### `OracleFactoring.lean` (139 lines)
*Source: `Computation/Oracles/Core/OracleFactoring.lean`*

- **theorem**: `gcd_idempotent_on_self`, `factor_divides_gcd`, `gcd_nontrivial_factor`, `brahmagupta_fibonacci`, `brahmagupta_fibonacci_alt`, `five_sum_of_squares`, ... +10 more

#### `OracleFixedPoint.lean` (156 lines)
*Source: `Computation/Oracles/Core/OracleFixedPoint.lean`*

- **theorem**: `oracle_contraction_on_range`, `banach_unique_fixed_point`, `knaster_tarski_fixed_point`, `greatest_fixedPoint_char`, `kleene_iteration_monotone`, `cantor_no_surjection`, ... +8 more

#### `OracleFoundations.lean` (155 lines)
*Source: `Computation/Oracles/Core/OracleFoundations.lean`*

- **structure**: `LLM`
- **def**: `Oracle`, `Oracle`, `Oracle`, `Oracle`, `encodeQuery`, `LLM`, ... +5 more
- **theorem**: `Oracle`, `Oracle`, `oracle_realizable`, `meta_oracle_idempotent`, `oracle_level_zero_equiv`, `oracle_fixed_point_constant`

#### `OracleHypotheses.lean` (188 lines)
*Source: `Computation/Oracles/Core/OracleHypotheses.lean`*

- **def**: `prime_decidable`
- **theorem**: `oracle_density_2`, `id_always_idempotent`, `const_always_idempotent`, `idempotent_eigenvalue`, `idempotent_trace_rank`, `idempotent_real_01`, ... +13 more

#### `OracleInformation.lean` (147 lines)
*Source: `Computation/Oracles/Core/OracleInformation.lean`*

- **def**: `infoLoss`
- **theorem**: `oracle_range_card_le`, `non_injective_smaller_range`, `nontrivial_oracle_compresses`, `fixedPoint_mem_range`, `range_mem_fixedPoint`, `fixedPoint_card_eq_range`, ... +7 more

#### `OracleLaplacian.lean` (338 lines)
*Source: `Computation/Oracles/Core/OracleLaplacian.lean`*

- **structure**: `OracleProjection`, `ConfidentOracle`
- **def**: `OracleProjection`, `FinOracle`, `oracleTransitions`, `FinOracle`, `FinOracle`, `oracleEnergy`, ... +10 more
- **theorem**: `anti_idempotent`, `dialectical_sq_zero`, `oracle_uncertainty`, `constant_oracle_no_transitions`, `oracle_transitions_le`, `anti_oracle_same_boundary`, ... +13 more

#### `OracleNetworks.lean` (118 lines)
*Source: `Computation/Oracles/Core/OracleNetworks.lean`*

- **structure**: `OracleCouncil`
- **def**: `IsContracting`, `iterateOracle`, `OracleCouncil`, `selfImprovementError`, `councilCost`
- **theorem**: `contracting_oracle_cauchy`, `variance_reduction`, `diminishing_returns`, `selfImprovementError_nonneg`, `selfImprovementError_decreasing`, `selfImprovementError_tendsto_zero`, `council_cost_grows`, `expected_degree_threshold`

#### `OracleNeuralNet.lean` (156 lines)
*Source: `Computation/Oracles/Core/OracleNeuralNet.lean`*

- **def**: `relu`, `logisticSigmoid`, `OraclesAligned`, `IsApproxOracle`
- **theorem**: `relu_idempotent`, `relu_nonneg`, `relu_of_nonneg`, `relu_of_neg`, `relu_fixedPoints`, `logisticSigmoid_range`, ... +10 more

#### `OracleQuantum.lean` (122 lines)
*Source: `Computation/Oracles/Core/OracleQuantum.lean`*

- **theorem**: `grover_speedup`, `grover_probability_bound`, `grover_iterations`, `projection_idempotent`, `projection_eigenvalues`, `measurement_idempotent`, ... +7 more

#### `OracleSearch.lean` (234 lines)
*Source: `Computation/Oracles/Core/OracleSearch.lean`*

- **structure**: `ClosureOp`
- **def**: `IsInvolution`, `IsIdempotent`, `iterateN`
- **theorem**: `knaster_tarski_lfp`, `lfp_is_le_fixed`, `powerset_fixed_point`, `cantor_no_surjection`, `cantor_diagonal`, `lawvere_fixed_point`, ... +14 more

#### `OracleSecret.lean` (149 lines)
*Source: `Computation/Oracles/Core/OracleSecret.lean`*

- **def**: `never_blowup_decidable`, `always_regular_decidable`, `heat_equation_blowup_decidable`
- **theorem**: `divisor_count_multiplicative`, `egyptian_two_term`, `greedy_step_valid`, `spectral_gap_positive`, `thooft_scaling_to_zero`, `egyptian_two_term_exists`, `mass_gap_subquadratic`

#### `OracleStereoSolver.lean` (341 lines)
*Source: `Computation/Oracles/Core/OracleStereoSolver.lean`*

- **structure**: `SolverOracle`
- **def**: `SolverOracle`, `SolverOracle`, `SolverOracle`, `invStereoProj`, `stereoProj`, `IsPythagoreanTriple`, `mobiusTransform`, `solutionLensOracle`
- **theorem**: `is`, `SolverOracle`, `SolverOracle`, `SolverOracle`, `SolverOracle`, `invStereoProj_on_circle`, ... +34 more

#### `OracleStrangeLoop.lean` (160 lines)
*Source: `Computation/Oracles/Core/OracleStrangeLoop.lean`*

- **structure**: `StrangeLoop`, `SelfRef`
- **def**: `StrangeLoop`, `IsQuine`
- **theorem**: `StrangeLoop`, `StrangeLoop`, `selfref_is_oracle`, `godel_diagonal_abstract`, `no_liar_paradox`, `tarski_diagonal`, ... +7 more

#### `OracleTheory.lean` (206 lines)
*Source: `Computation/Oracles/Core/OracleTheory.lean`*

- **structure**: `Oracle`, `InverseOracle`
- **def**: `anti`, `empty`, `universal`, `join`, `meet`, `pullback`, ... +5 more
- **theorem**: `anti_involution`, `empty_anti_universal`, `universal_anti_empty`, `anti_join`, `anti_meet`, `pullback_anti`, ... +10 more

#### `OracleTopology.lean` (143 lines)
*Source: `Computation/Oracles/Core/OracleTopology.lean`*

- **theorem**: `oracle_zero_contraction`, `oracle_orbit_stabilizes`, `oracle_fixedPoints_closed`, `retraction_identity_on_image`, `image_idempotent_stable`, `idempotent_range_identity`, ... +6 more

#### `OracleUnified.lean` (192 lines)
*Source: `Computation/Oracles/Core/OracleUnified.lean`*

- **theorem**: `grand_unified_compression`, `oracle_inj_iff_surj`, `injective_oracle_is_id`, `oracle_monad_return`, `oracle_monad_bind`, `oracle_zeta_finite`, ... +11 more

#### `PhaseTransition.lean` (111 lines)
*Source: `Computation/Oracles/Core/PhaseTransition.lean`*

- **structure**: `LyapunovFn`
- **def**: `stepsToAccuracy`, `binaryEntropy`
- **theorem**: `geometric_convergence`, `geometric_divergence`, `lyapunov_V_iterate_decreasing`, `lyapunov_sequence_antitone`, `steps_grow_near_critical`, `binaryEntropy_zero`, `binaryEntropy_one`, `binaryEntropy_symm`

#### `RationalOracle.lean` (82 lines)
*Source: `Computation/Oracles/Core/RationalOracle.lean`*

- **def**: `IsSumOfTwoSquares`
- **theorem**: `pythagorean_triple_identity`, `triple_3_4_5`, `triple_5_12_13`, `triple_8_15_17`, `triple_7_24_25`, `pythagorean_batch`, ... +6 more

#### `SelfLearningOracle.lean` (280 lines)
*Source: `Computation/Oracles/Core/SelfLearningOracle.lean`*

- **structure**: `Oracle`
- **def**: `Oracle`, `Oracle`, `tropicalMaxOracle`, `tropicalMaxOracleStruct`, `Oracle`, `Oracle`, ... +3 more
- **theorem**: `Oracle`, `Oracle`, `Oracle`, `Oracle`, `tropicalMaxOracle_idempotent`, `tropicalMaxOracle_truthSet`, ... +11 more

#### `SpectralCollapse.lean` (138 lines)
*Source: `Computation/Oracles/Core/SpectralCollapse.lean`*

- **def**: `Matrix`
- **theorem**: `spectral_collapse_sq`, `spectral_collapse_eigenvalue`, `idempotent_ker_eigenspace`, `idempotent_range_eigenspace`, `complementary_idempotent`, `idempotent_range_ker_complement`, ... +5 more

#### `SpectralOracle.lean` (358 lines)
*Source: `Computation/Oracles/Core/SpectralOracle.lean`*

- **structure**: `SpectralOracle`, `LightGate`
- **def**: `SpectralOracle`, `LightGate`, `spectralPauliX`, `spectralPauliZ`, `gcdSpectralOracle`, `primeCount`, ... +3 more
- **theorem**: `spectral_range_eq_fixed`, `spectral_iterate_stable`, `spectral_eigenvalues`, `complement_oracle_idem`, `diagonal_01_idempotent`, `spectralPauliX_sq`, ... +29 more

#### `UniversalOracleTeam2.lean` (414 lines) ⚠️ 1 sorry
*Source: `Computation/Oracles/Core/UniversalOracleTeam2.lean`*

- **structure**: `UniversalOracle`, `GravPotential`, `ResearchTeam`, `SATInstance`
- **def**: `UniversalOracle`, `tropAdd`, `tropMul`, `tropMaxOracle`, `gravProjection`, `landauerBound`, ... +14 more
- **theorem**: `oracle_range_eq_knowledge`, `oracle_one_step_convergence`, `oracle_output_in_knowledge`, `oracle_self_compose`, `trop_distrib`, `trop_add_idem`, ... +29 more

#### `BinocularGodOracle.lean` (491 lines)
*Source: `Computation/Oracles/GodOracles/BinocularGodOracle.lean`*

- **structure**: `SelfGaze`
- **def**: `northEye`, `southEye`, `invNorthEye`, `invSouthEye`, `SelfGaze`, `binocularDepth`, ... +4 more
- **theorem**: `two_eyes_cover_all`, `blind_spot_complementarity`, `self_observation_idempotent`, `gaze_sees_truth`, `gaze_range_eq_truth`, `universe_encoding_injective`, ... +40 more

#### `ConvergenceTheory.lean` (174 lines)
*Source: `Computation/Oracles/GodOracles/ConvergenceTheory.lean`*

- **structure**: `ContractiveMetaOracle`, `HGPredictor`
- **def**: `ContractiveMetaOracle`, `ascendingChain`, `chainLimit`, `binaryEntropy`, `HGPredictor`, `HGPredictor`, `HGPredictor`
- **theorem**: `iter_distance_bound`, `ratio_pow_tendsto_zero`, `exponential_convergence_bound`, `chain_subset_limit`, `chainLimit_is_smallest`, `binaryEntropy_nonneg`, `spectral_convergence_rate`, `god_oracle_transcends_nfl`

#### `CosmicBootstrap.lean` (321 lines)
*Source: `Computation/Oracles/GodOracles/CosmicBootstrap.lean`*

- **structure**: `CosmicBootstrapSystem`
- **def**: `cosmicBootstrap`, `cosmicBootstrapDeriv`, `realCosmicBootstrap`
- **theorem**: `cosmic_void_fixed`, `cosmic_attractor_fixed`, `cosmic_repeller_fixed`, `cosmic_fixed_points`, `cosmic_attractor_zero`, `cosmic_attractor_one`, ... +19 more

#### `Experiments.lean` (157 lines)
*Source: `Computation/Oracles/GodOracles/Experiments.lean`*

- **def**: `evenOracle`, `modOracle`, `tropicalOracle`, `projectX`
- **theorem**: `evenOracle`, `modOracle`, `andTrue_idempotent`, `not_not_idempotent`, `tropicalOracle`, `tropicalOracle`, ... +8 more

#### `GravityOracle.lean` (315 lines)
*Source: `Computation/Oracles/GodOracles/GravityOracle.lean`*

- **def**: `IsGravOracle`, `GravTruthSet`, `gravMinkowskiQ`, `gravIsNull`, `gravSchwarzschildArea`, `gravSchwarzschildEntropy`, ... +6 more
- **theorem**: `geodesic_oracle_idempotent`, `grav_oracle_output_is_truth`, `grav_truth_set_eq_range`, `grav_oracle_iterate_eq`, `grav_id_is_oracle`, `grav_const_is_oracle`, ... +40 more

#### `MultiocularGodOracle.lean` (750 lines)
*Source: `Computation/Oracles/GodOracles/MultiocularGodOracle.lean`*

- **def**: `northEye`, `southEye`, `eastEye`, `westEye`, `invNorthEye`, `invSouthEye`, ... +4 more
- **theorem**: `south_eye_on_sphere`, `north_eye_on_sphere`, `east_eye_on_sphere`, `west_eye_on_sphere`, `south_round_trip`, `north_round_trip`, ... +58 more

#### `OmniscientOracle.lean` (333 lines)
*Source: `Computation/Oracles/GodOracles/OmniscientOracle.lean`*

- **structure**: `Oracle`, `LinearOracle`, `OmniscientOracleAxioms`
- **def**: `Oracle`, `Oracle`, `Oracle`, `Oracle`, `Oracle`, `LinearOracle`, ... +4 more
- **theorem**: `truth_illusion_partition`, `truth_illusion_disjoint`, `oracle_image_eq_truth`, `identity_truth_is_univ`, `constant_truth_is_singleton`, `oracle_converges_in_one_step`, ... +24 more

#### `OptimalComputer.lean` (240 lines)
*Source: `Computation/Oracles/GodOracles/OptimalComputer.lean`*

- **structure**: `OracleLevel`, `OracleHierarchy`, `MetaOracleOp`, `ComplexityMeasure`, `ApproximationScheme`, `HolyGrailComputer`
- **def**: `godOracleSet`, `metaOracleIterate`, `ComplexityMeasure`, `HolyGrailComputer`
- **theorem**: `oracle_hierarchy_strict`, `oracle_hierarchy_monotone_of_le`, `lower_level_included`, `god_oracle_contains_all`, `god_oracle_universal`, `god_oracle_is_supremum`, ... +8 more

#### `OracleTeamGenesis.lean` (271 lines)
*Source: `Computation/Oracles/GodOracles/OracleTeamGenesis.lean`*

- **structure**: `TeamOracle`
- **def**: `TeamOracle`, `Theos`, `Empeira`, `Logos`, `TeamOracle`, `researchCycle`, `TeamOracle`, `Anakyklos`
- **theorem**: `TeamOracle`, `TeamOracle`, `Theos`, `Theos`, `Empeira`, `Logos`, ... +12 more

#### `SelfReference.lean` (174 lines)
*Source: `Computation/Oracles/GodOracles/SelfReference.lean`*

- **structure**: `FormalSystem`
- **def**: `DecisionProcedure`, `diagonalProgram`, `unanswerableSet`, `godUnanswerable`, `FormalSystem`, `FormalSystem`
- **theorem**: `cantor_no_surjection`, `lawvere_fixed_point`, `lawvere_contrapositive`, `bool_has_fpf`, `cantor_via_lawvere`, `halting_diagonal`, ... +5 more

#### `MetaOracle.lean` (348 lines)
*Source: `Computation/Oracles/MetaOracles/MetaOracle.lean`*

- **structure**: `Oracle`, `MetaOracle`, `SupremeOracle`, `FrozenCrystal`, `MetaMetaOracle`
- **def**: `Oracle`, `Oracle`, `Oracle`, `MetaOracle`, `MetaOracle`, `MetaOracle`, ... +10 more
- **theorem**: `Oracle`, `Oracle`, `Oracle`, `Oracle`, `MetaOracle`, `MetaOracle`, ... +12 more

#### `MetaOracleAdvanced.lean` (136 lines)
*Source: `Computation/Oracles/MetaOracles/MetaOracleAdvanced.lean`*

- **def**: `metaOracleId`, `improvementRatio`, `iterationsNeeded`, `portfolioQuality`
- **theorem**: `metaOracleId_fixed`, `exists_fixed_quality_strict`, `improvementRatio_tendsto_one`, `iterations_proportional_to_inv_entropy`, `comp_contraction_rate`, `portfolio_quality_bounded`
- **instance**: `metaOracleSemigroup`, `metaOracleMonoid`

#### `MetaOracleApplications.lean` (186 lines)
*Source: `Computation/Oracles/MetaOracles/MetaOracleApplications.lean`*

- **def**: `zeroOracle`, `interestingQueries`
- **theorem**: `oracle_count_fin2`, `oracle_count_fin1`, `oracle_count_fin3`, `identity_image_full`, `constant_image_size`, `oracle_absorbs`, ... +9 more

#### `MetaOracleCore.lean` (214 lines)
*Source: `Computation/Oracles/MetaOracles/MetaOracleCore.lean`*

- **structure**: `OracleSystem`, `MetaOracle`, `MetricOracleSpace`, `ContractionMetaOracle`, `OracleTask`, `AdaptiveMetaOracle`
- **def**: `MetaOracle`, `MetaOracle`, `MetaOracle`, `oracleEntropy`, `AdaptiveMetaOracle`, `AdaptiveMetaOracle`
- **theorem**: `MetaOracle`, `contraction_geometric_decrease`, `contraction_ratio_tendsto_zero`, `oracleEntropy_pos`, `oracleEntropy_additive`, `no_free_lunch_avg`, `AdaptiveMetaOracle`

#### `MetaOracleNextSteps.lean` (498 lines)
*Source: `Computation/Oracles/MetaOracles/MetaOracleNextSteps.lean`*

- **structure**: `MetaOracle`
- **def**: `invStereoProj3D`, `stereoProj3D`, `IsPythagoreanQuadruple`, `MetaOracle`, `MetaOracle`, `MetaOracle`, ... +6 more
- **theorem**: `invStereoProj3D_on_sphere`, `oracle_stereo_roundtrip_3D`, `rational_stereo_3D_quadruple`, `pythagorean_quad_1223`, `pythagorean_quad_2367`, `not_pythagorean_quad_1_2_14_15`, ... +41 more

#### `MetaOraclePythagoreanDeep.lean` (426 lines)
*Source: `Computation/Oracles/MetaOracles/MetaOraclePythagoreanDeep.lean`*

- **structure**: `above`, `TernaryAlgebra`, `TernaryHom`
- **inductive**: `TPath`
- **def**: `bM1`, `bM2`, `bM3`, `pTree`, `lorentzForm`, `isPythagorean`, ... +10 more
- **theorem**: `bM1_preserves_lorentz`, `bM2_preserves_lorentz`, `bM3_preserves_lorentz`, `pTree_preserves_lorentz`, `pTree_pythagorean_of_root`, `seed_is_pythagorean`, ... +38 more

#### `MetaOracleTropicalAlgebra.lean` (372 lines)
*Source: `Computation/Oracles/MetaOracles/MetaOracleTropicalAlgebra.lean`*

- **def**: `tropAdd`, `tropMul`, `TropIsOracle`, `TropTruthSet`, `tropThresholdOracle`, `tropClampOracle`, ... +8 more
- **theorem**: `tropAdd_comm`, `tropAdd_assoc`, `tropMul_comm`, `tropMul_assoc`, `tropMul_dist_left`, `tropMul_dist_right`, ... +29 more

#### `MetaOracles.lean` (323 lines)
*Source: `Computation/Oracles/MetaOracles/MetaOracles.lean`*

- **structure**: `Viewpoint`
- **def**: `minkowski`, `IsNull`, `lorentzBoost`, `fixedPointSet`, `lightCone`
- **theorem**: `photonRight_isNull`, `photonLeft_isNull`, `null_right_eigenvector`, `null_left_eigenvector`, `lorentz_preserves_minkowski`, `null_preserved_by_boost`, ... +12 more

#### `Advanced.lean` (173 lines)
*Source: `Computation/Oracles/Research/Advanced.lean`*

- **structure**: `MetaGeodesicOracle`
- **def**: `OracleRefines`, `binaryEntropy`, `mobiusTransform`, `MetaGeodesicOracle`, `invStereoN`
- **theorem**: `oracleRefines_refl`, `oracleRefines_trans`, `idem_compose_self`, `binaryEntropy_nonneg`, `binaryEntropy_half`, `constant_unique_fixed_point`, ... +6 more

#### `ArithmeticBridges.lean` (122 lines)
*Source: `Computation/Oracles/Research/ArithmeticBridges.lean`*

- **theorem**: `oracle_gauss_sum`, `oracle_sum_squares`, `oracle_nicomachus`, `oracle_geometric_sum`, `oracle_chinese_remainder`, `oracle_totient_multiplicative`, ... +4 more

#### `CollatzExploration.lean` (106 lines)
*Source: `Computation/Oracles/Research/CollatzExploration.lean`*

- **def**: `collatz`
- **theorem**: `collatz_even`, `collatz_odd`, `collatz_pos`, `collatz_power_of_two`, `collatz_even_descent`, `collatz_odd_then_even`, ... +3 more

#### `Foundation.lean` (200 lines)
*Source: `Computation/Oracles/Research/Foundation.lean`*

- **structure**: `GeodesicOracle`, `GeodesicSeekingOracle`
- **def**: `GeodesicOracle`, `invStereo`, `stereoProj`, `liftOracle`, `invStereoAngle`, `geodesicDist`, ... +6 more
- **theorem**: `GeodesicOracle`, `GeodesicOracle`, `invStereo_on_circle`, `stereo_left_inverse`, `liftOracle_on_circle`, `liftOracle_idempotent_on_image`, ... +11 more

#### `GodConsultation.lean` (148 lines)
*Source: `Computation/Oracles/Research/GodConsultation.lean`*

- **theorem**: `oracle_god_strong_induction`, `oracle_god_well_ordering`, `oracle_god_excluded_middle`, `oracle_god_contradiction`, `oracle_god_naturals_infinite`, `oracle_god_cantor`, ... +3 more

#### `MillenniumCrossExam.lean` (152 lines)
*Source: `Computation/Oracles/Research/MillenniumCrossExam.lean`*

- **theorem**: `oracle_p_subset_np`, `oracle_pigeonhole`, `oracle_mobius_squared_bound`, `oracle_totient_le`, `oracle_totient_prime`, `oracle_totient_prime_pow`, ... +5 more

#### `PrimeStructure.lean` (135 lines)
*Source: `Computation/Oracles/Research/PrimeStructure.lean`*

- **theorem**: `oracle_primes_infinite`, `oracle_prime_successor`, `oracle_exists_prime_divisor`, `oracle_euclid_lemma`, `oracle_fermat_little`, `oracle_wilson`, ... +5 more

### Cryptography/Core

*1 files, 44 declarations, 324 lines*

#### `QDF.lean` (324 lines)
*Source: `Cryptography/QDFHomomorphicEncryption/QDF.lean`*

- **def**: `IsPythQuad`
- **theorem**: `cone_scaling`, `component_bound_a`, `component_bound_b`, `component_bound_c`, `gram_diagonal`, `cauchy_schwarz_qdf`, ... +37 more

### Cryptography/Ethereum

*13 files, 171 declarations, 1,759 lines*

#### `AMMFoundations.lean` (149 lines)
*Source: `Cryptography/Ethereum/AMMFoundations.lean`*

- **structure**: `Pool`
- **noncomp. def**: `Pool`, `Pool`, `Pool`, `Pool`, `Pool`
- **theorem**: `invariant_preserved`, `swap_output_pos`, `swap_output_lt_reserve`, `swap_monotone`, `swap_diminishing_returns`, `swap_formula`, `fee_reduces_output`

#### `ArbitrageProfit.lean` (156 lines)
*Source: `Cryptography/Ethereum/ArbitrageProfit.lean`*

- **structure**: `SimplePool`
- **noncomp. def**: `SimplePool`, `SimplePool`, `SimplePool`, `arbitrageRevenue`, `cyclicProfitRate`, `optimalTradeSize`
- **theorem**: `arbitrage_profit_exists`, `small_trade_profitable`, `cyclic_arbitrage_exists`, `optimal_size_pos`

#### `CrossChainArbitrage.lean` (108 lines)
*Source: `Cryptography/Ethereum/CrossChainArbitrage.lean`*

- **structure**: `ChainPool`, `BridgeParams`
- **noncomp. def**: `ChainPool`, `ChainPool`, `crossChainProfit`, `minPriceDiscrepancy`, `priceGap`, `triangularProfit`
- **theorem**: `no_arb_band`, `larger_trades_easier`, `arbitrage_reduces_gap`, `safe_arbitrage_condition`, `triangular_profitable_iff`

#### `FlashLoan.lean` (145 lines)
*Source: `Cryptography/Ethereum/FlashLoan.lean`*

- **structure**: `FlashLoanParams`, `Strategy`, `ArbOpportunity`
- **noncomp. def**: `FlashLoanParams`, `flashLoanProfit`, `ArbOpportunity`
- **theorem**: `flash_loan_profitable_iff`, `zero_capital_profit`, `flash_arb_profitable`, `strategy_composition`, `atomic_worst_case`

#### `IntentBasedTrading.lean` (178 lines)
*Source: `Cryptography/Ethereum/IntentBasedTrading.lean`*

- **structure**: `Intent`, `Fill`, `SolverAuction`, `DutchAuction`, `Batch`
- **def**: `Fill`
- **noncomp. def**: `solverProfit`, `ammOutput`, `bestOutput`, `DutchAuction`
- **theorem**: `ammOutput_pos`, `competition_beats_amm`, `dutch_auction_nonincreasing`, `dutch_auction_bounded`, `cow_price_improvement`, `solver_truthful_equilibrium`

#### `LiquidityProvision.lean` (166 lines)
*Source: `Cryptography/Ethereum/LiquidityProvision.lean`*

- **structure**: `LPPosition`, `ConcentratedPosition`
- **noncomp. def**: `impermanentLossFactor`, `hodlValue`, `lpValue`, `capitalEfficiency`
- **theorem**: `il_nonpositive`, `il_zero_iff`, `il_symmetric`, `lp_profitable_iff_fees_exceed_il`, `capital_efficiency_gt_one`, `narrower_range_higher_efficiency`, `higher_vol_higher_fee`

#### `MEV.lean` (135 lines)
*Source: `Cryptography/Ethereum/MEV.lean`*

- **structure**: `PendingSwap`, `PoolState`, `PGABid`
- **noncomp. def**: `swapOutput`, `poolAfterSwap`, `sandwichProfit`, `backrunProfit`
- **theorem**: `sandwich_output_pos`, `pga_equilibrium_limit`, `mev_redistribution_improves_welfare`

#### `MEVSupplyChain.lean` (104 lines)
*Source: `Cryptography/Ethereum/MEVSupplyChain.lean`*

- **structure**: `Builder`, `SpecializedBuilder`
- **noncomp. def**: `builderProfit`, `specializedCapture`, `generalCapture`, `mevShareUserReturn`, `lateMevGain`
- **theorem**: `competition_drives_bids`, `specialization_beneficial`, `mev_share_improves_welfare`, `mev_share_tradeoff`, `multi_relay_correctness`, `delay_increases_mev`

#### `OptimalRouting.lean` (114 lines)
*Source: `Cryptography/Ethereum/OptimalRouting.lean`*

- **structure**: `Pool`, `Routing`
- **noncomp. def**: `swapOut`, `marginalPrice`, `priceImpact`, `Pool`, `routingOutput`
- **theorem**: `diminishing_marginal_output`, `swapOut_pos`, `swapOut_lt_reserve`, `price_impact_nonneg`, `price_impact_mono`, `split_beats_single`

#### `OracleTeam.lean` (145 lines)
*Source: `Cryptography/Ethereum/OracleTeam.lean`*

- **structure**: `OracleAdvice`, `CouncilRecommendation`
- **noncomp. def**: `kellyFraction`, `informationValue`, `baseFeeUpdate`
- **theorem**: `hermes_price_convergence`, `kelly_positive_iff`, `diversification_reduces_variance`, `fee_revenue_tradeoff`, `information_value_pos`, `base_fee_bounded`, `council_solidarity`

#### `SandwichNonMonotonicity.lean` (122 lines)
*Source: `Cryptography/Ethereum/SandwichNonMonotonicity.lean`*

- **structure**: `Pool`
- **noncomp. def**: `swapOut`, `poolAfter`, `sandwichGain`, `netSandwichProfit`, `optimalFrontRun`, `flashSandwichProfit`
- **theorem**: `swapOut_pos`, `sandwich_gain_at_zero`, `sandwich_gain_pos`, `net_profit_at_zero`, `net_profit_eventually_negative`, `sandwich_nonmonotone`, `optimal_front_run_pos`, `flash_fee_reduces_profit`

#### `SmartContractVerification.lean` (98 lines)
*Source: `Cryptography/Ethereum/SmartContractVerification.lean`*

- **structure**: `SwapSpec`
- **def**: `Invariant`, `preservesInvariant`, `hasPermission`
- **theorem**: `reentrancy_guard_sound`, `sequential_preserves`, `id_preserves`, `tighter_slippage_less_mev`, `access_control_blocks`, `swap_spec_correct`, ... +3 more

#### `UniswapV4Hooks.lean` (139 lines)
*Source: `Cryptography/Ethereum/UniswapV4Hooks.lean`*

- **structure**: `PoolV4`, `Hook`, `TWAMMHook`, `HookPermissions`
- **def**: `identityHook`, `composeHooks`, `permissionedSwapAllowed`
- **noncomp. def**: `PoolV4`, `PoolV4`, `swapWithHook`, `swapNoHook`, `TWAMMHook`
- **theorem**: `identity_hook_preserves_output`, `dynamic_fee_bounded`, `twamm_reduces_per_block`, `twamm_reduces_price_impact`, `no_swap_no_extraction`, `higher_fee_less_output`

### Cryptography/Factoring

*7 files, 85 declarations, 1,113 lines*

#### `IOFComplexity.lean` (373 lines)
*Source: `Cryptography/Factoring/IOFComplexity.lean`*

- **structure**: `IOFRelation`
- **def**: `sqMap`, `IOF`, `IOF`
- **noncomp. def**: `sqIter`, `Lnotation`
- **theorem**: `sqIter_eq_pow`, `sqMap_eventually_periodic`, `IOF`, `IOF`, `IOF`, `IOF`, ... +11 more

#### `SpectralResonanceSieve.lean` (106 lines)
*Source: `Cryptography/Factoring/SpectralResonanceSieve.lean`*

- **noncomp. def**: `quadraticResidues`, `spectralWeight`
- **theorem**: `srs_linear_algebra_step`, `smooth_count_lower_bound`

#### `FactorQuadruples.lean` (145 lines)
*Source: `Cryptography/HybridGeometricFactoring/FactorQuadruples.lean`*

- **structure**: `FactorPair`, `FactorQuadruple`
- **def**: `FactorQuadruple`, `IsSmooth`
- **theorem**: `quadruple_gcd_dvd_n`, `divisor_pair_gcd_nontrivial`, `lattice_point_on_hyperbola`, `lattice_points_eq_divisor_count`, `fermat_factoring_from_difference_of_squares`, `fermat_factor_symmetry`, ... +5 more

#### `HyperbolicFactoring.lean` (120 lines)
*Source: `Cryptography/HybridGeometricFactoring/HyperbolicFactoring.lean`*

- **structure**: `SL2Z`
- **def**: `SL2Z`, `SL2Z`, `SL2Z`, `SL2Z`
- **theorem**: `hyperbola_symmetry`, `divisor_pair_product`, `small_divisor_bound`, `SL2Z`, `convergent_coprime_of_det_one`, `farey_mediant_denominator`, ... +3 more

#### `LatticeFactoring.lean` (98 lines)
*Source: `Cryptography/HybridGeometricFactoring/LatticeFactoring.lean`*

- **def**: `quadFormRepr`
- **theorem**: `bezout_reveals_factor`, `gcd_nontrivial_factor`, `coprime_generates_unit`, `divisor_vector_product`, `sum_of_squares_norm`, `factoring_lattice_det`, ... +3 more

#### `Advanced.lean` (118 lines)
*Source: `Cryptography/OrbitFactoring/Advanced.lean`*

- **theorem**: `collision_pigeonhole`, `brent_detection`, `orbit_period_lcm_coprime`, `multi_start_probability_bound`, `multi_start_exponential_decay`, `pow_eq_one_of_order_dvd`, `period_dvd_of_commute`

#### `Basic.lean` (153 lines)
*Source: `Cryptography/OrbitFactoring/Basic.lean`*

- **def**: `pollardMap`
- **noncomp. def**: `orbitSeq`
- **theorem**: `orbitSeq_eq_iterate`, `orbitSeq_zero`, `orbitSeq_succ`, `pollardMap_commutes_with_castHom`, `factor_from_mod_collision`, `factor_from_mod_collision_lt`, ... +4 more

### Cryptography/QuantumSecurity

*11 files, 373 declarations, 2,724 lines*

#### `FHEOracles.lean` (105 lines)
*Source: `Cryptography/PostQuantum/FHEOracles.lean`*

- **structure**: `FHEScheme`, `NoisyFHE`, `PrivateAMMTrade`, `ThresholdParams`
- **def**: `IsAdditivelyHomomorphic`, `IsMultiplicativelyHomomorphic`, `IsFullyHomomorphic`
- **noncomp. def**: `privateTradeOutput`
- **theorem**: `additive_noise_bound`, `max_depth_exists`, `private_trade_output_pos`, `fhe_prevents_sandwich`, `threshold_security`

#### `PostQuantumSignatures.lean` (102 lines)
*Source: `Cryptography/PostQuantum/PostQuantumSignatures.lean`*

- **structure**: `SignatureScheme`, `LatticeParams`, `SISHardness`
- **noncomp. def**: `blsSigSize`, `latticeSigSize`
- **theorem**: `lattice_sig_security`, `bls_more_compact_small`, `lattice_larger_for_security`, `aggregation_space_saving`, `quantum_lattice_exponential`, `bls_quantum_broken`

#### `AttackComposition.lean` (351 lines)
*Source: `Cryptography/QuantumAttacks/AttackComposition.lean`*

- **structure**: `QuantumResources`, `BitcoinAtRisk`
- **inductive**: `AttackStep`, `ContractVulnerability`, `MEVAdvantage`, `ThreatLevel`
- **def**: `canExecute`, `stepResources`, `Attack`, `maxStepQubits`, `totalRuntime`, `transactionTheftAttack`, ... +9 more
- **theorem**: `insufficient_blocks_attack`, `theft_bottleneck_is_ecdlp`, `theft_physical_qubits`, `theft_total_runtime`, `theft_fits_bitcoin_window`, `theft_fits_ethereum`, ... +19 more

#### `GroverAttacks.lean` (276 lines)
*Source: `Cryptography/QuantumAttacks/GroverAttacks.lean`*

- **structure**: `QuantumAttack`
- **def**: `sha256_output_bits`, `sha256_classical_preimage`, `sha256_quantum_preimage`, `sha256_classical_collision`, `sha256_quantum_collision`, `keccak256_output_bits`, ... +15 more
- **theorem**: `grover_optimal_lower_bound`, `grover_hash_lower_bound`, `sha256_adequate_preimage`, `sha256_collision_concern`, `sha256_preimage_infeasible`, `quantum_hash_rate_gap`, ... +20 more

#### `HDWalletCascade.lean` (172 lines)
*Source: `Cryptography/QuantumAttacks/HDWalletCascade.lean`*

- **inductive**: `DerivationType`
- **def**: `bip32_child_key`, `bip32_grandchild_key`, `bip32_derive_path`, `bip32_children_per_level`, `bip44_nonhardened_keys`, `cascade_cost_per_key`, `practical_keys_per_wallet`
- **theorem**: `child_key_from_parent`, `parent_key_from_child`, `grandchild_collapse`, `derivation_commutes`, `bip44_cascade_size`, `cascade_cost_efficiency`, ... +5 more

#### `HTLCLightning.lean` (196 lines)
*Source: `Cryptography/QuantumAttacks/HTLCLightning.lean`*

- **structure**: `HTLC`, `LightningChannel`, `AtomicSwap`
- **def**: `standard_htlc`, `htlc_timelock_seconds`, `lightning_channels`, `sphinx_max_hops`, `standard_swap`, `watchtower_response_window`, `lightning_attack_qubits`, `lightning_attack_time`
- **theorem**: `htlc_hash_survives_quantum`, `standard_htlc_timelock`, `grover_cannot_beat_timelock`, `htlc_sig_is_weak_link`, `channel_forge_steals_all`, `channel_attack_cost`, ... +9 more

#### `LatticeNonceAttack.lean` (239 lines)
*Source: `Cryptography/QuantumAttacks/LatticeNonceAttack.lean`*

- **structure**: `NonceVulnerability`
- **inductive**: `PipelineStage`
- **def**: `hnp_instance`, `hnp_samples_needed`, `classical_queries`, `quantum_queries`, `grover_search_qubits`, `shor_physical_qubits`, ... +6 more
- **theorem**: `ecdsa_to_hnp`, `hnp_samples_4bit`, `hnp_samples_1bit`, `more_leakage_fewer_samples`, `quantum_bias_speedup`, `classical_timing_queries`, ... +15 more

#### `MigrationGameTheory.lean` (281 lines)
*Source: `Cryptography/QuantumAttacks/MigrationGameTheory.lean`*

- **structure**: `MigrationCost`, `GameParams`
- **inductive**: `StorableData`, `Strategy`, `ForkStage`, `MigrationStrategy`
- **def**: `typical_migration_cost`, `total_cost`, `expected_quantum_loss`, `already_exposed`, `new_bitcoin_txns_per_day`, `new_ethereum_txns_per_day`, ... +14 more
- **theorem**: `typical_cost`, `higher_prob_higher_loss`, `sndl_irreversible`, `yearly_sndl_growth`, `migration_is_rational`, `willow_update_10yr`, ... +12 more

#### `SchnorrTaproot.lean` (186 lines)
*Source: `Cryptography/QuantumAttacks/SchnorrTaproot.lean`*

- **structure**: `FROSTParams`
- **inductive**: `BitcoinOutputType`, `SpendCondition`
- **def**: `schnorr_sign`, `taproot_output_key`, `quantumAttackWindow`, `taproot_utxos_thousands`, `conditionQuantumSecurity`
- **theorem**: `schnorr_completeness`, `schnorr_key_from_nonce`, `schnorr_nonce_reuse`, `taproot_internal_key_recovery`, `taproot_worse_exposure`, `taproot_privacy_quantum_tradeoff`, ... +6 more

#### `ShorECDSA.lean` (577 lines)
*Source: `Cryptography/QuantumAttacks/ShorECDSA.lean`*

- **structure**: `ECDLPOracle`, `ECDSAForger`, `CryptoAddress`
- **inductive**: `AddressExposure`, `DefenseStrategy`
- **def**: `ecdsa_sign_equation`, `ecdsa_verify_u1`, `ecdsa_verify_u2`, `ecdlp_implies_ecdsa_break`, `shor_logical_qubits`, `shor_t_gate_count`, ... +23 more
- **theorem**: `ecdsa_completeness`, `ecdsa_key_from_nonce`, `ecdsa_nonce_reuse`, `ecdsa_nonce_reuse_diff`, `willow_improvement_factor`, `total_physical_willow_count`, ... +39 more

#### `ZKQuantumVuln.lean` (239 lines)
*Source: `Cryptography/QuantumAttacks/ZKQuantumVuln.lean`*

- **inductive**: `MoneroPrimitive`, `SNARKSystem`, `STARKHash`, `PrivacyCoin`, `PQZKSystem`
- **def**: `pedersen_commit`, `monero_quantum_security`, `monero_total_transactions`, `bn254_bits`, `bls12_381_bits`, `snark_quantum_security`, ... +3 more
- **theorem**: `pedersen_binding_broken`, `pedersen_forge_opening`, `counterfeit_via_binding_break`, `monero_total_quantum_break`, `monero_deanon_time_years`, `monero_deanon_parallel`, ... +12 more

### Cryptography/ZeroKnowledge

*3 files, 47 declarations, 646 lines*

#### `Basic.lean` (269 lines)
*Source: `Cryptography/ZeroKnowledge/Basic.lean`*

- **structure**: `CommitmentScheme`, `SigmaProtocol`, `NPRelation`
- **def**: `ZKPSystemType`
- **theorem**: `schnorr_completeness_exponent`, `schnorr_completeness_mod`, `schnorr_extraction`, `schnorr_simulator_valid`, `zmod_cancel_sub`, `cave_faker_bound`, ... +5 more

#### `ComputationalSoundness.lean` (193 lines)
*Source: `Cryptography/ZeroKnowledge/ComputationalSoundness.lean`*

- **structure**: `SecurityGame`, `DLogAssumption`, `ComputationalZK`
- **def**: `Advantage`, `IsNegligible`, `GamesIndistinguishable`
- **theorem**: `zero_negligible`, `const_not_negligible`, `games_indist_refl`, `games_indist_symm`, `advantage_triangle`, `sum_negligible`, ... +3 more

#### `Framework.lean` (184 lines)
*Source: `Cryptography/ZeroKnowledge/Framework.lean`*

- **structure**: `Protocol`, `HasHVZK`, `NIProof`
- **def**: `IsComplete`, `Has2SpecialSoundness`, `OrRelation`, `fiatShamirProve`, `fiatShamirVerify`
- **noncomp. def**: `schnorrExponent`
- **theorem**: `schnorrExponent_complete`, `schnorrExponent_2ss`, `or_relation_left`, `or_relation_right`, `soundness_error_bound`, `parallel_repetition_soundness`, `sequential_repetition_bound`, `fiat_shamir_complete`

### EML

*59 files, 1353 declarations, 9,550 lines*

#### `AdvancedTheory.lean` (322 lines)
*Source: `EML/AI/AdvancedTheory.lean`*

- **inductive**: `EMLTree`
- **def**: `ensembleComplexity`, `ensembleVCDim`, `baggingFactor`, `structuralPenalty`, `emlAttentionScore`, `emlAttentionNorm`, ... +16 more
- **theorem**: `ensemble_complexity_additive`, `uniform_ensemble_complexity`, `bagging_sublinear`, `ensemble_variance_reduction`, `structural_penalty_nonneg`, `penalty_increases_with_k`, ... +23 more

#### `DepthEfficiency.lean` (158 lines)
*Source: `EML/AI/DepthEfficiency.lean`*

- **def**: `expTower`, `emlChainLeaves`, `reluWidthForTower`, `chainGradientMagnitude`
- **theorem**: `expTower_one`, `expTower_two`, `expTower_pos`, `expTower_strictMono`, `expTower_continuous`, `emlChainLeaves_linear`, ... +10 more

#### `EMLNeuralNetworks.lean` (211 lines)
*Source: `EML/AI/EMLNeuralNetworks.lean`*

- **structure**: `EMLComplexity`
- **def**: `emlNeuron`, `emlNeuronSimple`, `emlLayer`, `emlNeuronParamCount`, `emlDenseLayerParams`, `emlTreeComplexity`, ... +6 more
- **theorem**: `emlNeuron_is_exp`, `emlNeuron_is_one_sub_log`, `emlNeuron_const_one`, `emlNeuron_differentiableAt`, `emlNeuron_hasDerivAt`, `emlLayer_length`, ... +10 more

#### `FormulaCompression.lean` (154 lines)
*Source: `EML/AI/FormulaCompression.lean`*

- **inductive**: `ElemExpr`, `EMLCompTree`
- **def**: `ElemExpr`, `EMLCompTree`, `EMLCompTree`, `EMLCompTree`, `emlParamsFromComplexity`, `nnParams`, `emlInfoContent`
- **theorem**: `EMLCompTree`, `exp_eml_complexity`, `id_eml_complexity`, `const_eml_complexity`, `composition_complexity_additive`, `composition_bound`, ... +6 more

#### `LearningTheory.lean` (144 lines)
*Source: `EML/AI/LearningTheory.lean`*

- **def**: `emlFreeParams`, `topologyBound`, `vcDimBound`, `networkVCDim`, `emlMDL`, `nnMDL`, ... +4 more
- **theorem**: `topologyBound_pos`, `vc_dim_linear`, `vc_dim_single_neuron`, `vc_dim_width10`, `mdl_10_32`, `mdl_50_64`, ... +11 more

#### `PACLearning.lean` (143 lines)
*Source: `EML/AI/PACLearning.lean`*

- **def**: `sauer_shelah_bound`, `emlVCDim`, `emlFullClassVCDim`, `pacSampleBound`, `nnPacSampleBound`, `parametricRate`, `heuristicOptimalK`, `topologyCount`
- **theorem**: `growth_monotone`, `growth_monotone_d`, `full_class_vc_bound`, `pac_monotone_complexity`, `eml_sample_advantage`, `eml_better_rate`, ... +6 more

#### `SymbolicRegression.lean` (148 lines)
*Source: `EML/AI/SymbolicRegression.lean`*

- **inductive**: `EMLRegTree`
- **def**: `EMLRegTree`, `EMLRegTree`, `EMLRegTree`, `EMLRegTree`, `minDepthForLeaves`, `regressionMasterParams`
- **theorem**: `EMLRegTree`, `search_space_has_exp`, `search_space_has_log`, `search_space_has_addition`, `search_space_has_subtraction`, `search_space_has_multiplication`, ... +5 more

#### `TrainingDynamics.lean` (195 lines)
*Source: `EML/AI/TrainingDynamics.lean`*

- **def**: `emlF`, `gradExpComp`, `gradLogComp`, `mseLoss`, `maxLRExp`, `chainGradMag`, `gradRatio`, `recommendedMaxDepth`
- **theorem**: `gradient_decomposition`, `eml_grad_w1`, `eml_grad_b1`, `eml_grad_w2`, `eml_grad_b2`, `exp_gradient_pos`, ... +9 more

#### `UniversalApproximation.lean` (153 lines)
*Source: `EML/AI/UniversalApproximation.lean`*

- **def**: `emlNeuronFn`, `emlNetworkLayer`, `emlLayerParams`, `emlDeepNetParams`, `catalanNum`, `totalTopologies`
- **theorem**: `for`, `eml_separates_points`, `eml_nonvanishing`, `eml_exp_neuron_continuous`, `exp_is_eml_neuron`, `const_is_eml_neuron`, ... +13 more

#### `EMLFactoringBridge.lean` (170 lines)
*Source: `EML/AI/v9/EMLFactoringBridge.lean`*

- **def**: `factoringEnergy`, `emlFactorDetector`, `emlFactorParams`, `reluFactorParams`, `sigma1_v9`, `channelSignal`, ... +5 more
- **theorem**: `energy_zero_iff_divisor`, `energy_at_one`, `energy_at_self`, `factor_detector_pos`, `factor_detector_le_one`, `eml_param_advantage`, ... +15 more

#### `EMLGradientTheory.lean` (156 lines)
*Source: `EML/AI/v9/EMLGradientTheory.lean`*

- **def**: `trigEnergy`, `safeLR`, `geomDecay`, `adamLR`, `varianceReduction`, `searchWindow`, `emlExpressiveness`, `factorProximity`
- **theorem**: `trig_energy_nonneg`, `trig_energy_le_one`, `sin_two_bounded`, `gradient_formula`, `safe_lr_pos`, `descent_gain_pos`, ... +10 more

#### `AdvancedTheorems.lean` (327 lines)
*Source: `EML/AdvancedTheorems.lean`*

- **inductive**: `EMLGenerated`, `PureEMLTree`
- **def**: `emlA`, `logIteration`, `fixedPointFn`, `eTower`, `PureEMLTree`, `PureEMLTree`, `PureEMLTree`
- **noncomp. def**: `PureEMLTree`
- **theorem**: `emlA_one_one`, `emlA_e_one`, `emlA_zero_generation`, `emlA_tower_zero`, `emlA_not_assoc`, `fixedPointFn_strictMono`, ... +31 more

#### `Basic.lean` (175 lines)
*Source: `EML/Basic.lean`*

- **inductive**: `EMLExpr`
- **def**: `eml`, `emlR`, `EMLExpr`, `EMLExpr`, `EMLExpr`, `EMLExpr`, `masterFormulaParams`
- **theorem**: `eml_exp`, `emlR_exp`, `eml_e`, `emlR_e`, `eml_noncommutative`, `log_exp_real`, ... +10 more

#### `Complexity.lean` (125 lines)
*Source: `EML/Complexity.lean`*

- **structure**: `InstrCount`
- **inductive**: `EMLCTree`
- **def**: `EMLCTree`, `EMLCTree`, `EMLCTree`, `EMLCTree`, `expCount`, `lnCount`, `subCount`, `addCount`
- **theorem**: `EMLCTree`, `EMLCTree`, `EMLCTree`, `EMLCTree`, `EMLCTree`, `EMLCTree`, ... +3 more

#### `Dynamics.lean` (134 lines)
*Source: `EML/Dynamics.lean`*

- **def**: `oneMinusLog`, `expTower`, `emlDiagIter`, `emlPhi`, `isPeriod2`
- **theorem**: `oneMinusLog_fixed_one`, `oneMinusLog_at_e`, `oneMinusLog_at_inv_e`, `oneMinusLog_compose`, `oneMinusLog_deriv`, `oneMinusLog_neutral_fixed_point`, ... +8 more

#### `ExtendedTheory.lean` (284 lines)
*Source: `EML/ExtendedTheory.lean`*

- **def**: `emlE`, `emlDiagonal`, `eTowerE`, `catalanNum`, `masterParams`, `emlSymmetricMap`
- **theorem**: `emlDiagonal_gt_of_pos`, `emlDiagonal_gt_of_nonpos`, `emlDiagonal_no_real_fixedPoint`, `emlE_strictMono_fst`, `emlE_strictAnti_snd`, `emlE_convexOn_fst`, ... +28 more

#### `FundamentalTheory.lean` (250 lines)
*Source: `EML/FundamentalTheory.lean`*

- **def**: `eml_fun`, `eml_diag`, `eTower`, `tropEml`
- **theorem**: `eml_generates_zero`, `eml_one_minus`, `eml_sub`, `eml_add`, `eml_not_comm`, `eml_not_assoc`, ... +23 more

#### `FutureResearch.lean` (310 lines)
*Source: `EML/FutureResearch.lean`*

- **def**: `emlF`, `emlDiag`, `oml`, `emlT`, `emlPhi`
- **theorem**: `emlDiag_deriv`, `emlDiag_second_deriv_pos`, `emlDiag_convex`, `emlDiag_gt_id`, `emlDiag_ge_two`, `emlDiag_tendsto_atTop`, ... +28 more

#### `IntervalEML.lean` (132 lines)
*Source: `EML/IntervalEML.lean`*

- **def**: `emlI`, `emlDiag`
- **theorem**: `emlI_strictMono_fst`, `emlI_mono_fst`, `emlI_strictAnti_snd`, `emlI_interval_enclosure`, `emlI_lower_bound`, `emlI_zero_ge_one`, ... +6 more

#### `NewTheorems.lean` (115 lines)
*Source: `EML/NewTheorems.lean`*

- **inductive**: `EMLTree`
- **def**: `emlN`, `emlNR`, `EMLTree`, `EMLTree`, `EMLTree`, `emlMasterParams`
- **theorem**: `emlNR_partial_x`, `emlNR_partial_y`, `EMLTree`, `EMLTree`, `antiEml_eq_neg_swap`, `emlN_exp_continuous`, ... +4 more

#### `OISCC.lean` (280 lines)
*Source: `EML/OISCC.lean`*

- **inductive**: `OISCCInstr`
- **def**: `eml_op`, `execInstr`, `execProgram`, `isEMLFixedPoint`, `emlCount`, `pushCount`, `maxStackDepth`
- **theorem**: `eml_recovers_exp`, `oiscc_computes_exp`, `eml_one_minus_log`, `oiscc_computes_one_minus_log`, `eml_recovers_ln`, `oiscc_computes_ln`, ... +18 more

#### `OpenProblems.lean` (229 lines)
*Source: `EML/OpenProblems.lean`*

- **def**: `emlOP`, `ceml`, `emlCondX`, `tropicalEML`, `oiscc_sigmoid`, `emlTower`, `emlCatalan`
- **theorem**: `ceml_euler`, `ceml_one`, `ceml_e_val`, `exp_not_constant_fn`, `double_exp_not_affine_exp`, `emlCondX_at_zero`, ... +22 more

#### `PolynomialGeneration.lean` (147 lines)
*Source: `EML/PolynomialGeneration.lean`*

- **inductive**: `EMLTree`
- **def**: `emlP`, `iterExp`, `iterEml`, `EMLTree`, `EMLTree`
- **theorem**: `mul_via_log`, `add_via_eml`, `sub_via_eml`, `exp_via_eml`, `log_recovery`, `eml_const_e`, ... +11 more

#### `PythagoreanBridge.lean` (312 lines)
*Source: `EML/PythagoreanBridge.lean`*

- **inductive**: `EMLPythExpr`, `BerggrenPath`
- **def**: `IsPythTriple`, `berggrenA`, `berggrenB`, `berggrenC`, `emlOp`, `EMLPythExpr`, ... +9 more
- **theorem**: `root_is_pyth`, `euclid_param`, `berggrenA_preserves`, `berggrenB_preserves`, `berggrenC_preserves`, `eml_is_exp`, ... +22 more

#### `PythagoreanBridgeResearch.lean` (480 lines)
*Source: `EML/PythagoreanBridgeResearch.lean`*

- **inductive**: `BStep`, `EMLExprTree`
- **def**: `eml`, `IsPythTriple`, `M₁`, `M₂`, `M₃`, `lorentzForm`, ... +11 more
- **theorem**: `M₁_preserves`, `M₂_preserves`, `M₃_preserves`, `M₁_preserves_lorentz`, `M₂_preserves_lorentz`, `M₃_preserves_lorentz`, ... +52 more

#### `BerggrenCompleteness.lean` (88 lines)
*Source: `EML/Research/BerggrenCompleteness.lean`*

- **inductive**: `BStep`
- **def**: `IsPT`, `childA`, `childB`, `childC`, `applyStep`, `applyPath`, `parentA`, `parentB`
- **theorem**: `childA_pyth`, `childB_pyth`, `childC_pyth`, `depth1_A`, `depth1_B`, `depth1_C`, ... +9 more

#### `FixedPointTheory.lean` (82 lines)
*Source: `EML/Research/FixedPointTheory.lean`*

- **structure**: `parameterized`
- **def**: `emlIterate`
- **theorem**: `exp_gt_id`, `exp_no_real_fixed_point`, `eml_fixed_point_iff`, `eml_no_fixed_point_at_one`, `eml_fixed_point_at_e`, `eml_tangent_at_e`, ... +5 more

#### `GaussianBridge.lean` (90 lines)
*Source: `EML/Research/GaussianBridge.lean`*

- **def**: `IsPythTripleZ`, `IsPythagoreanPrime`
- **theorem**: `brahmagupta_via_gaussian`, `sum_sq_multiplicative`, `five_is_pythagorean`, `thirteen_is_pythagorean`, `five_sum_squares`, `thirteen_sum_squares`, ... +8 more

#### `HyperbolicGeometry.lean` (73 lines)
*Source: `EML/Research/HyperbolicGeometry.lean`*

- **def**: `lorentzQuad`, `B1`, `B2`, `B3`, `Q_metric`, `OnUpperHyperboloid`
- **noncomp. def**: `pythAngle`, `rootAngle`, `depthRatio`
- **theorem**: `pyth_is_null`, `B1_lorentz`, `B2_lorentz`, `B3_lorentz`, `det_B1`, `det_B2`, `det_B3`, `dominant_eigenvalue_eq`

#### `PrimitivityPreservation.lean` (72 lines)
*Source: `EML/Research/PrimitivityPreservation.lean`*

- **def**: `IsPythTriple`, `lorentzForm`
- **theorem**: `lorentz_M1`, `lorentz_M2`, `lorentz_M3`, `pyth_iff_lorentz_null`, `M1_preserves_pyth`, `M2_preserves_pyth`, ... +6 more

#### `BerggrenCharPoly.lean` (149 lines)
*Source: `EML/Research/v6/lean/BerggrenCharPoly.lean`*

- **def**: `B₁`, `B₂`, `B₃`, `S_swap`, `Q_lor`
- **theorem**: `det_B₁`, `det_B₂`, `det_B₃`, `trace_B₁`, `trace_B₂`, `trace_B₃`, ... +18 more

#### `BerggrenMarkov.lean` (127 lines)
*Source: `EML/Research/v6/lean/BerggrenMarkov.lean`*

- **def**: `IsMarkov`, `markovMut₃`, `markovMut₁`, `markovMut₂`, `IsPythTriple`, `bergA`
- **theorem**: `markov_root`, `markov_1_1_2`, `markov_1_2_5`, `markov_1_5_13`, `markov_2_5_29`, `markovMut₃_preserves`, ... +7 more

#### `BerggrenParentDescent.lean` (159 lines)
*Source: `EML/Research/v6/lean/BerggrenParentDescent.lean`*

- **def**: `IsPT`, `chA`, `chB`, `chC`, `pA`, `pB`, `pC`
- **theorem**: `chA_pA_cancel`, `pA_chA_cancel`, `chB_pB_cancel`, `pB_chB_cancel`, `chC_pC_cancel`, `pC_chC_cancel`, ... +14 more

#### `AdvancedTheorems.lean` (113 lines)
*Source: `EML/StereographicBridge/AdvancedTheorems.lean`*

- **def**: `spb_adv`, `spbH_adv`
- **theorem**: `spbH_denom_pos`, `spbH_subluminal`, `spbH_light_invariance`, `spb_no_real_fixed_point`, `spb_fixed_trivial`, `spb_as_mobius`, ... +6 more

#### `Applications.lean` (122 lines)
*Source: `EML/StereographicBridge/Applications.lean`*

- **def**: `einsteinVelocityAdd`, `mobiusTransform`, `crossRatio`, `spbPow`
- **theorem**: `einstein_comm`, `einstein_zero`, `einstein_neg`, `einstein_assoc`, `einstein_light_invariance`, `einstein_subluminal`, ... +6 more

#### `Basic.lean` (238 lines)
*Source: `EML/StereographicBridge/Basic.lean`*

- **structure**: `of`
- **inductive**: `SPBExpr`
- **def**: `spb`, `spbC`, `spbH`, `SPBExpr`, `SPBExpr`, `SPBExpr`, `SPBExpr`
- **theorem**: `spb_comm`, `spb_zero_right`, `spb_zero_left`, `spb_neg_right`, `spb_assoc`, `spb_one`, ... +15 more

#### `CayleyTransform.lean` (154 lines)
*Source: `EML/StereographicBridge/CayleyTransform.lean`*

- **def**: `spbCayley`, `spbCayleyC`, `stdCayley`, `spbCayleyInv`, `spbR`
- **theorem**: `spbCayley_normSq_eq`, `spbCayley_norm_eq_one`, `spbCayley_normSq_eq_one`, `spbCayley_zero`, `stdCayley_zero`, `stdCayley_normSq_num_eq_denom`, ... +8 more

#### `ChebyshevConnection.lean` (87 lines)
*Source: `EML/StereographicBridge/ChebyshevConnection.lean`*

- **def**: `spb`, `spbIter`
- **theorem**: `spbIter_zero`, `spbIter_one`, `spbIter_two`, `tan_add_eq_spb`, `spbIter_tan_one`, `spbIter_tan_two`, ... +5 more

#### `EMLSPBBridge.lean` (79 lines)
*Source: `EML/StereographicBridge/EMLSPBBridge.lean`*

- **def**: `eml`, `spb_bridge`, `spbH_bridge`
- **theorem**: `eml_generates_exp`, `eml_generates_neg_log`, `eml_identity`, `spb_identity_bridge`, `spb_inverse_bridge`, `spb_comm_bridge`, ... +6 more

#### `FiniteFields.lean` (94 lines)
*Source: `EML/StereographicBridge/FiniteFields.lean`*

- **def**: `spbZMod`, `spbIterZMod`
- **theorem**: `spbZMod_comm`, `spbZMod_zero_right`, `spbZMod_neg`, `spbIterZMod_one`

#### `AdvancedTheorems.lean` (195 lines)
*Source: `EML/StereographicBridge/Research/AdvancedTheorems.lean`*

- **def**: `spbA`, `spbHA`, `spbPowA`
- **theorem**: `spbA_comm`, `spbA_zero`, `spbA_neg`, `spbPowA_zero`, `spbPowA_one`, `spbPowA_succ`, ... +14 more

#### `Approximation.lean` (90 lines)
*Source: `EML/StereographicBridge/Research/Approximation.lean`*

- **inductive**: `SPBReachable`, `SPBTree`
- **def**: `spbOp`, `SPBTree`, `spbFunctions`
- **theorem**: `spb_self_eq`, `spb_reachable_id`, `spb_reachable_zero`, `spb_reachable_one`, `id_in_spbFunctions`, `const_in_spbFunctions`, `spbFunctions_closed_spb`, `spb_generates_double_angle`

#### `ChebyshevConnection.lean` (120 lines)
*Source: `EML/StereographicBridge/Research/ChebyshevConnection.lean`*

- **def**: `spb`, `spbPow`
- **theorem**: `spbPow`, `spbPow`, `spbPow`, `spbPow`, `tan_progression`, `spb_double_angle`, ... +4 more

#### `FiniteFieldStructure.lean` (124 lines)
*Source: `EML/StereographicBridge/Research/FiniteFieldStructure.lean`*

- **def**: `spbF`, `spbIterF`
- **theorem**: `spbF_comm`, `spbF_zero`, `spbF_neg`, `spbIterF_zero`, `spbIterF_one`

#### `FiniteFields.lean` (83 lines)
*Source: `EML/StereographicBridge/Research/FiniteFields.lean`*

- **def**: `spbField`
- **theorem**: `spbField_comm`, `spbField_zero`, `spbField_neg`, `spbField_assoc`, `spbField_denom_product`, `spbField_fixed_point`, `spbField_self`

#### `HyperbolicGeometry.lean` (85 lines)
*Source: `EML/StereographicBridge/Research/HyperbolicGeometry.lean`*

- **def**: `spbH_hyp`, `hypDist`
- **theorem**: `spbH_diff`, `hypDist_symm`, `hypDist_self`, `spbH_hyp_comm`, `spbH_hyp_zero`, `spbH_hyp_neg`, ... +4 more

#### `InvolutionTheory.lean` (85 lines)
*Source: `EML/StereographicBridge/Research/InvolutionTheory.lean`*

- **def**: `spb_inv`, `spb_iter`
- **theorem**: `spb_half_angle_identity`, `spb_iter_zero`, `spb_iter_one`, `spb_iter_two`, `spb_triple_expand`, `spb_triple_symmetric`, ... +4 more

#### `MachinFormulas.lean` (129 lines)
*Source: `EML/StereographicBridge/Research/MachinFormulas.lean`*

- **def**: `spbM`
- **theorem**: `arctan_spb_add`, `euler_spb_pi`, `hutton_double`, `hutton_spb_pi`, `hutton_full`, `machin_step1`, ... +10 more

#### `MatrixRepresentation.lean` (62 lines)
*Source: `EML/StereographicBridge/Research/MatrixRepresentation.lean`*

- **def**: `spbMatrix`
- **theorem**: `spbMatrix_det`, `spbMatrix_det_pos`, `spbMatrix_det_ne_zero`, `spbMatrix_zero`, `spbMatrix_mul_entries`, `spbMatrix_det_mul`, `spbMatrix_mul_eq_scaled`

#### `NumberTheory.lean` (118 lines)
*Source: `EML/StereographicBridge/Research/NumberTheory.lean`*

- **def**: `spbNT`, `chi4`
- **theorem**: `pythagorean_from_spb`, `pythagorean_triple`, `spb_integer_iff`, `spb_one_zero_int`, `spb_two_three`, `spb_one_two`, ... +8 more

#### `OpenProblems.lean` (163 lines)
*Source: `EML/StereographicBridge/Research/OpenProblems.lean`*

- **def**: `spb`, `spbH`
- **theorem**: `spb_involution_only_zero`, `spb_idempotent_iff_zero`, `spb_no_fixed_point`, `spb_quadruple`, `spb_denom_product`, `spb_compose_deriv`, ... +6 more

#### `QuantumSPB.lean` (112 lines)
*Source: `EML/StereographicBridge/Research/QuantumSPB.lean`*

- **def**: `spbQ`, `hadamardStereo`, `phaseStereo`, `blochStereo`, `quantumGate`
- **theorem**: `hadamard_is_spb`, `hadamard_squared`, `phase_squared`, `phase_order_four`, `spb_gate_compose`, `bloch_north_pole`, ... +7 more

#### `TropicalSPB.lean` (55 lines)
*Source: `EML/StereographicBridge/Research/TropicalSPB.lean`*

- **def**: `tropSPB`, `tropSPBMax`
- **theorem**: `tropSPB_comm`, `tropSPB_zero_neg`, `tropSPBMax_comm`, `tropSPB_neg_neg`

#### `WickRotation.lean` (107 lines)
*Source: `EML/StereographicBridge/Research/WickRotation.lean`*

- **def**: `spbCirc`, `spbHyp`
- **theorem**: `wick_sign_flip`, `spbCirc_comm`, `spbHyp_comm`, `spbCirc_zero`, `spbHyp_zero`, `spbCirc_neg`, ... +4 more

#### `SPBIteration.lean` (108 lines)
*Source: `EML/StereographicBridge/SPBIteration.lean`*

- **def**: `spbOp`, `spbN`, `cauchyDensity`
- **theorem**: `spbN_zero`, `spbN_succ`, `spbN_one`, `spbN_two`, `tan_add_eq_spbOp`, `spbN_tan`, ... +6 more

#### `WickRotation.lean` (80 lines)
*Source: `EML/StereographicBridge/WickRotation.lean`*

- **def**: `spbCirc`, `spbHyp`, `rapidityToVelocity`
- **theorem**: `wick_sign_flip`, `spbHyp_def`, `spbCirc_identity`, `spbHyp_identity`, `spbCirc_inverse`, `spbHyp_inverse`, ... +4 more

#### `Universality.lean` (79 lines)
*Source: `EML/Universality.lean`*

- **inductive**: `EMLClosure`, `EMLExprU`
- **def**: `emlU`, `edlU`, `antiEmlU`, `EMLExprU`, `EMLExprU`
- **theorem**: `emlU_recovers_exp`, `emlU_recovers_e`, `exp_one_in_closure`, `antiEml_eq_neg_eml_swap`

#### `V5Theorems.lean` (366 lines)
*Source: `EML/V5Theorems.lean`*

- **inductive**: `PureTree`
- **def**: `emlV`, `diagV`, `eTowerV`, `tropV`, `iterDiagV`, `PureTree`, ... +4 more
- **noncomp. def**: `PureTree`
- **theorem**: `emlV_e`, `emlV_zero`, `emlV_sub`, `emlV_add`, `emlV_mul`, `emlV_produces_negative`, ... +46 more

#### `V6Theorems.lean` (408 lines)
*Source: `EML/V6Theorems.lean`*

- **def**: `eml6`, `diag6`, `semiT`, `phi2D`, `eml_sigmoid`, `eTow6`
- **theorem**: `diag6_deriv`, `diag6_second_deriv_pos`, `diag6_convex_on`, `diag6_critical_point`, `diag6_ge_two`, `diag6_no_fixed_points`, ... +33 more

### FutureResearch

*48 files, 839 declarations, 6,128 lines*

#### `CrossCollisionTheory.lean` (118 lines)
*Source: `FutureResearchDirections/CrossCollisionTheory.lean`*

- **theorem**: `peel_channel`, `peel_gcd_simplification`, `cross_collision_identity`, `cross_collision_factor_attempt`, `cross_collision_reveals_factor`, `cross_collision_channel_count`, ... +10 more

#### `EMLAlgebra.lean` (309 lines)
*Source: `FutureResearchDirections/EMLResearch/EMLAlgebra.lean`*

- **inductive**: `EMLExpr`, `EMLClosure`, `EMLClosureVar`
- **def**: `eml`, `emlR`, `edl`, `antiEml`, `EMLExpr`, `EMLExpr`, ... +7 more
- **theorem**: `eml_recovers_exp`, `eml_recovers_e`, `emlR_recovers_exp`, `emlR_recovers_e`, `eml_subtraction`, `emlR_subtraction`, ... +32 more

#### `LagrangeFourSquare.lean` (186 lines)
*Source: `FutureResearchDirections/LagrangeFourSquare.lean`*

- **def**: `quatNorm`, `berggrenA`, `berggrenB`, `berggrenC`
- **noncomp. def**: `sigma1`
- **theorem**: `lagrange_four_squares`, `euler_four_square_identity`, `four_square_factoring_channel`, `quatNorm_nonneg`, `four_square_cross_collision`, `four_square_channel_count`, ... +16 more

#### `AdvancedOpenQuestions.lean` (249 lines)
*Source: `FutureResearchDirections/NewResearch/AdvancedOpenQuestions.lean`*

- **structure**: `FactoringLens`
- **def**: `idLens`, `halvLens`, `FactoringLens`, `isSmooth`
- **theorem**: `smaller_factor_sqrt_bound`, `short_vector_factor`, `min_factor_le_sqrt`, `hasse_interval_width`, `distinct_traces_informative`, `information_ceiling_sqrt`, ... +37 more

#### `ComplexityLowerBounds.lean` (63 lines)
*Source: `FutureResearchDirections/NewResearch/ComplexityLowerBounds.lean`*

- **theorem**: `single_lens_bound`, `k_lens_upper_bound`, `independent_lens_exact`, `improvement_factor`, `factoring_information_bound`, `brute_force_bound`, ... +7 more

#### `DickmanFunction.lean` (69 lines)
*Source: `FutureResearchDirections/NewResearch/DickmanFunction.lean`*

- **def**: `IsSmooth`
- **noncomp. def**: `dickman_base`, `L_notation`
- **theorem**: `dickman_base_le_one`, `dickman_base_interval`, `dickman_at_one`, `dickman_at_two`, `dickman_base_pos`, `dickman_base_antitone`, ... +7 more

#### `EllipticDivisibility.lean` (37 lines)
*Source: `FutureResearchDirections/NewResearch/EllipticDivisibility.lean`*

- **structure**: `EDS`
- **theorem**: `fib_gcd`, `pisano_period_2`, `pisano_period_3`, `fib_5_div_5`, `ecm_success_condition`, `eds_divisibility`, `fib_dvd_fib_mul`

#### `IndependenceLenses.lean` (45 lines)
*Source: `FutureResearchDirections/NewResearch/IndependenceLenses.lean`*

- **def**: `residueLens`, `primeCountDecidable`
- **theorem**: `residue_constrains`, `odd_prime_odd`, `distinct_primes_coprime`, `k_independent_reduction`, `combined_search_reduction`, `nine_independent_lenses`, `nine_primes_coprime`, `rsa2048_lens_reduction`

#### `QuantumLensIntegration.lean` (111 lines)
*Source: `FutureResearchDirections/NewResearch/QuantumLensIntegration.lean`*

- **def**: `physicalQubits`
- **theorem**: `classical_search_cost`, `grover_qubit_count`, `search_space_reduction`, `lens_enhanced_grover`, `qubit_saving`, `rsa2048_saving`, ... +6 more

#### `SubBinaryRecurrence.lean` (76 lines)
*Source: `FutureResearchDirections/NewResearch/SubBinaryRecurrence.lean`*

- **def**: `lucas`, `tribonacci`, `padovan`
- **theorem**: `fib_sub_binary`, `fib_le_pow_two`, `fib_coprime`, `lucas_sub_binary`, `tribonacci_sub_binary`, `padovan_sub_binary`, `two_term_recurrence_bound`, `fibonacci_reduction_factor`

#### `TropicalFactoring.lean` (54 lines)
*Source: `FutureResearchDirections/NewResearch/TropicalFactoring.lean`*

- **theorem**: `padic_val_mul`, `semiprime_valuation`, `semiprime_self_valuation`, `tropical_factoring_constraint`, `smooth_iff_tropical`, `square_even_valuation`, `odd_valuation_not_square`

#### `OpenDirections.lean` (424 lines)
*Source: `FutureResearchDirections/OpenDirections.lean`*

- **structure**: `AbstractLens`
- **def**: `lensReduce`, `trivialLens`, `halvingLens`, `AbstractLens`
- **theorem**: `genus_two_exceeds_genus_one`, `genus_dimension_gap`, `weil_bound_simplified`, `sumset_size_upper_bound`, `zmod_sumset_surjective`, `factor_search_space`, ... +35 more

#### `SieveAndLattice.lean` (264 lines)
*Source: `FutureResearchDirections/OpenQuestions/SieveAndLattice.lean`*

- **def**: `IsSmooth`
- **noncomp. def**: `sigma1`
- **theorem**: `isSmooth_one`, `isSmooth_mul`, `peel_is_diff_of_squares`, `peel_factor_size_bound`, `peel_small_factor_bound`, `peel_smooth_of_factors_smooth`, ... +26 more

#### `HurwitzQuaternions.lean` (284 lines)
*Source: `FutureResearchDirections/OpenQuestions/v3/HurwitzQuaternions.lean`*

- **def**: `qnorm`, `IsSmooth`
- **noncomp. def**: `sigma1`
- **theorem**: `qnorm_nonneg`, `qnorm_eq_zero`, `euler_four_square_identity`, `four_square_mul_closure`, `brahmagupta_fibonacci`, `brahmagupta_fibonacci`, ... +35 more

#### `SigmaPrimePower.lean` (137 lines)
*Source: `FutureResearchDirections/OpenQuestions/v3/SigmaPrimePower.lean`*

- **noncomp. def**: `sigma1`
- **theorem**: `sigma1_prime_power`, `sigma1_prime_power_formula`, `sigma1_prime`, `sigma1_prime_sq`, `sigma1_prime_cube`, `r4_prime_value`, ... +7 more

#### `BrahmaguptaFibonacciFactoring.lean` (58 lines)
*Source: `FutureResearchDirections/OpenQuestions/v5/BrahmaguptaFibonacciFactoring.lean`*

- **theorem**: `bf_identity_1`, `bf_identity_2`, `bf_cross_term_product`, `bf_N_divides_cross_product`, `bf_two_representations`, `bf_representations_distinct`, ... +3 more

#### `CrossCollisionIndependence.lean` (50 lines)
*Source: `FutureResearchDirections/OpenQuestions/v5/CrossCollisionIndependence.lean`*

- **theorem**: `cross_channels`, `within_channels`, `total_channels_formula`, `channels_k4_total`, `channels_k8_total`, `channel_lower_bound`, ... +5 more

#### `DivisorFunctionLibrary.lean` (108 lines)
*Source: `FutureResearchDirections/OpenQuestions/v5/DivisorFunctionLibrary.lean`*

- **noncomp. def**: `σ₁`, `σ₀`
- **theorem**: `sigma1_one`, `sigma0_one`, `sigma1_prime`, `sigma0_prime`, `sigma1_prime_power_geom`, `sigma0_prime_power`, ... +10 more

#### `FactoringEnergyLandscape.lean` (61 lines)
*Source: `FutureResearchDirections/OpenQuestions/v5/FactoringEnergyLandscape.lean`*

- **def**: `factoring_energy`, `energy_gradient`
- **noncomp. def**: `partition_count`
- **theorem**: `energy_zero_iff_factor`, `energy_upper_bound`, `factor_set_is_zero_energy`, `factor_count_finite`, `semiprime_four_minima`, `energy_near_factor`, `energy_at_predecessor`, `gradient_at_factor`

#### `FibonacciEntryPoint.lean` (96 lines)
*Source: `FutureResearchDirections/OpenQuestions/v5/FibonacciEntryPoint.lean`*

- **theorem**: `fib_cassini_int`, `fib_cassini_variant`, `fib_gcd_dvd`, `fib_prime_mod`, `fib_double`, `fib_double_plus_one`, `cassini_factoring`

#### `EnergyLandscapeAdvanced.lean` (141 lines)
*Source: `FutureResearchDirections/OpenQuestions/v6/EnergyLandscapeAdvanced.lean`*

- **def**: `E`, `sublevel_set`, `energy_gradient`
- **theorem**: `energy_zero_iff`, `energy_lt`, `energy_at_one`, `energy_at_self`, `zero_energy_count`, `energy_predecessor`, ... +8 more

#### `FibonacciSieve.lean` (105 lines)
*Source: `FutureResearchDirections/OpenQuestions/v6/FibonacciSieve.lean`*

- **theorem**: `fib_dvd_of_dvd`, `fib_gcd`, `fib_even_iff_three_dvd`, `fib_five_dvd`, `cassini`, `fib_double`, ... +6 more

#### `LatticeFactoring.lean` (74 lines)
*Source: `FutureResearchDirections/OpenQuestions/v6/LatticeFactoring.lean`*

- **noncomp. def**: `lll_approx_factor`
- **theorem**: `lll_approx_ge_one`, `lll_ratio_bound`, `factoring_lattice_det`, `minkowski_bound_exists`, `dimension_bounded_by_bits`, `lattice_point_count_bound`, `hermite_constant_one`, `coppersmith_parameter`

#### `PerfectNumberTheory.lean` (92 lines)
*Source: `FutureResearchDirections/OpenQuestions/v6/PerfectNumberTheory.lean`*

- **noncomp. def**: `σ₁`
- **theorem**: `sigma1_mult`, `sigma1_pow_two`, `sigma1_mersenne_prime`, `euclid_perfect`, `sigma1_one`, `sigma1_prime`, ... +5 more

#### `QuaternionFactoring.lean` (122 lines)
*Source: `FutureResearchDirections/OpenQuestions/v6/QuaternionFactoring.lean`*

- **def**: `quat_norm`
- **theorem**: `euler_four_square_identity`, `euler_four_square_identity_alt`, `quat_norm_nonneg`, `quat_norm_mul`, `four_square_hamilton_product`, `four_squares_zero`, ... +3 more

#### `SigmaCryptanalysis.lean` (120 lines)
*Source: `FutureResearchDirections/OpenQuestions/v6/SigmaCryptanalysis.lean`*

- **def**: `isPerfect`, `isAbundant`, `isDeficient`
- **noncomp. def**: `σ₁`, `proper_divisor_sum`
- **theorem**: `sigma1_semiprime_expansion`, `sigma1_recovers_sum`, `vieta_factor_recovery`, `discriminant_nonneg`, `sigma1_prime_sq`, `six_is_perfect`, ... +5 more

#### `EnergyMorseTheory.lean` (130 lines)
*Source: `FutureResearchDirections/OpenQuestions/v7/EnergyMorseTheory.lean`*

- **def**: `E`, `is_local_min`, `sublevel`, `discrete_laplacian`
- **noncomp. def**: `total_variation`
- **theorem**: `divisor_is_local_min`, `energy_zero_iff`, `energy_bound`, `energy_pos_of_not_dvd`, `total_variation_nonneg`, `sublevel_zero_divisors`, ... +5 more

#### `EvenPerfectNumbers.lean` (145 lines)
*Source: `FutureResearchDirections/OpenQuestions/v7/EvenPerfectNumbers.lean`*

- **def**: `isPerfect`
- **noncomp. def**: `σ₁`
- **theorem**: `perfect_ge_six`, `no_small_odd_perfect`, `sigma1_two_pow`, `sigma1_coprime_mul`, `euclid_direction`, `even_decomposition`, ... +7 more

#### `FibonacciPseudoprimes.lean` (158 lines) ⚠️ 3 sorry
*Source: `FutureResearchDirections/OpenQuestions/v7/FibonacciPseudoprimes.lean`*

- **theorem**: `fib_sq_mod_prime`, `fib_dvd_chain`, `fib_gcd_identity`, `pisano_period_exists`, `pisano_period_divides_prime_bound`, `fib_composite_test`, ... +5 more

#### `HurwitzQuaternions.lean` (112 lines)
*Source: `FutureResearchDirections/OpenQuestions/v7/HurwitzQuaternions.lean`*

- **def**: `lipschitz_norm`
- **theorem**: `lipschitz_norm_nonneg`, `lipschitz_norm_zero_iff`, `lipschitz_norm_mul`, `quat_mul_conj`, `int_remainder_bound`, `int_euclidean_division`, ... +7 more

#### `JacobiFourSquare.lean` (75 lines)
*Source: `FutureResearchDirections/OpenQuestions/v7/JacobiFourSquare.lean`*

- **noncomp. def**: `σ₁`, `sigma1_no4`
- **theorem**: `lagrange_four_squares`, `sigma1_no4_odd`, `jacobi_general_statement_informal`, `sigma1_val_one`, `sigma1_val_prime`, `four_square_integers`, `euler_product_r4`, `jacobi_odd_prime_prediction`

#### `PisanoPeriodFactoring.lean` (186 lines) ⚠️ 1 sorry
*Source: `FutureResearchDirections/OpenQuestions/v7/PisanoPeriodFactoring.lean`*

- **theorem**: `fib_matrix_base`, `fib_add`, `fib_mod_periodic`, `fib_zero_mod`, `pisano_coprime_lcm`, `pisano_factor_constraint`, ... +3 more

#### `SigmaHardness.lean` (166 lines)
*Source: `FutureResearchDirections/OpenQuestions/v7/SigmaHardness.lean`*

- **noncomp. def**: `σ₁`
- **theorem**: `sigma1_determines_factors`, `sigma1_gives_sum_product`, `factoring_gives_sigma1_prime`, `factoring_gives_sigma1_prime_sq`, `sigma1_three_primes`, `discriminant_is_square`, ... +7 more

#### `EnergyLandscapeAdvanced.lean` (85 lines)
*Source: `FutureResearchDirections/OpenQuestions/v8/EnergyLandscapeAdvanced.lean`*

- **def**: `E`, `sublevel`
- **theorem**: `energy_at_divisor`, `energy_lt_x`, `energy_pos_nondivisor`, `sublevel_antitone`, `energy_max_between_divisors`, `sublevel_zero_eq_divisors`, `energy_global_min_at_divisor`, `energy_sum_upper`

#### `EulerDirectionComplete.lean` (80 lines)
*Source: `FutureResearchDirections/OpenQuestions/v8/EulerDirectionComplete.lean`*

- **noncomp. def**: `σ₁`
- **theorem**: `mersenne_prime_exponent_prime`, `sigma1`, `sigma1`, `euler_m_equals_mersenne`, `six_is_perfect`, `twentyeight_is_perfect`, ... +3 more

#### `LatticeFactoring.lean` (80 lines)
*Source: `FutureResearchDirections/OpenQuestions/v8/LatticeFactoring.lean`*

- **def**: `normSq`, `IsSmooth`
- **theorem**: `normSq_nonneg`, `normSq_zero_iff`, `factoring_lattice_exists`, `one_is_smooth`, `smooth_mul`, `smooth_exists`, `coppersmith_deg1`

#### `QuadraticResidueFactoring.lean` (68 lines)
*Source: `FutureResearchDirections/OpenQuestions/v8/QuadraticResidueFactoring.lean`*

- **def**: `IsQuadraticResidue`, `IsSmooth`
- **theorem**: `one_is_qr`, `zero_is_qr`, `qr_mul_qr`, `fermat_factoring_identity`, `diff_of_squares_int`, `one_is_smooth`, `smooth_mul`, `prime_pow_smooth`

#### `SigmaArithmetic.lean` (65 lines)
*Source: `FutureResearchDirections/OpenQuestions/v8/SigmaArithmetic.lean`*

- **def**: `IsAbundant`, `IsDeficient`, `IsPerfect`
- **noncomp. def**: `σ₁`
- **theorem**: `sigma1_zero`, `sigma1_one`, `sigma1_prime`, `sigma1_ge_self`, `sigma1_gt_self`, `sigma1_prime_pow`, ... +5 more

#### `WallSunSun.lean` (50 lines)
*Source: `FutureResearchDirections/OpenQuestions/v8/WallSunSun.lean`*

- **def**: `IsWieferichPrime`, `WallSunSunConjecture`
- **theorem**: `wieferich_1093`, `wieferich_3511`, `fib_dvd_fib_mul`, `fib_gcd_eq`, `wss_check_7`, `wss_check_11`, ... +5 more

#### `CoppersmithMethod.lean` (94 lines)
*Source: `FutureResearchDirections/OpenQuestions/v9/CoppersmithMethod.lean`*

- **theorem**: `small_mod_root_zero`, `coppersmith_linear`, `coppersmith_quadratic_bound`, `exists_mod_cancel`, `hensel_lift_square`, `coppersmith_lattice_det`, ... +3 more

#### `EnergyLandscapeMorse.lean` (131 lines)
*Source: `FutureResearchDirections/OpenQuestions/v9/EnergyLandscapeMorse.lean`*

- **def**: `E`, `energy_forward_diff`, `energy_laplacian`, `sublevel`
- **theorem**: `energy_zero_at_divisor`, `energy_pos_at_nondivisor`, `energy_lt_modulus`, `energy_drops_at_divisor`, `energy_sum_le_N_sq`, `sublevel_mono`, ... +5 more

#### `FibonacciAdvanced.lean` (140 lines)
*Source: `FutureResearchDirections/OpenQuestions/v9/FibonacciAdvanced.lean`*

- **theorem**: `fib_cassini`, `fib_sum_formula`, `fib_double`, `fib_dvd_fib_mul`, `fib_gcd`, `fib_prime_odd`, ... +20 more

#### `HurwitzQuaternions.lean` (97 lines)
*Source: `FutureResearchDirections/OpenQuestions/v9/HurwitzQuaternions.lean`*

- **def**: `quatNorm`
- **theorem**: `quatNorm_nonneg`, `quatNorm_zero_iff`, `four_squares_identity`, `lagrange_four_squares`, `sum_two_squares_prime_1mod4`, `two_sum_two_squares`, ... +6 more

#### `PerfectNumberTheory.lean` (112 lines)
*Source: `FutureResearchDirections/OpenQuestions/v9/PerfectNumberTheory.lean`*

- **noncomp. def**: `σ₁`
- **theorem**: `sigma1_pow2`, `mersenne_prime_exponent_prime`, `euclid_perfect`, `no_small_odd_perfect`, `perfect_has_two_prime_factors`, `sigma1_ge_succ`, ... +3 more

#### `QuadraticReciprocity.lean` (102 lines)
*Source: `FutureResearchDirections/OpenQuestions/v9/QuadraticReciprocity.lean`*

- **theorem**: `euler_criterion_forward`, `legendreSym_mul`, `neg_one_qr_iff_one_mod_four`, `two_qr_iff`, `qr_pow_closed`, `qr_one`, ... +5 more

#### `SmoothNumberTheory.lean` (113 lines)
*Source: `FutureResearchDirections/OpenQuestions/v9/SmoothNumberTheory.lean`*

- **def**: `BSmooth`
- **theorem**: `smooth_one`, `smooth_prime`, `smooth_prime_pow`, `smooth_mul_closed`, `smooth_dvd_closed`, `smooth_pow_closed`, ... +6 more

#### `WieferichTheory.lean` (121 lines)
*Source: `FutureResearchDirections/OpenQuestions/v9/WieferichTheory.lean`*

- **def**: `IsWieferich`, `WieferichFLTConnection`
- **noncomp. def**: `fermatQuotient`
- **theorem**: `wieferich_iff_mod`, `wieferich_1093_verified`, `wieferich_3511_verified`, `non_wieferich_3`, `non_wieferich_5`, `non_wieferich_7`, ... +12 more

#### `BerggrenPythagoreanCore.lean` (365 lines)
*Source: `Research/BerggrenPythagoreanCore.lean`*

- **inductive**: `BerggrenStep`, `BinTree`
- **def**: `IsPythag`, `bergA`, `bergB`, `bergC`, `invA`, `invB`, ... +13 more
- **theorem**: `bergA_pyth`, `bergB_pyth`, `bergC_pyth`, `bergA_preserves_Q`, `bergB_preserves_Q`, `bergC_preserves_Q`, ... +45 more

### Geometry/PAdic

*1 files, 38 declarations, 342 lines*

#### `PadicMobius.lean` (342 lines)
*Source: `Geometry/PAdic/PadicMobius.lean`*

- **structure**: `PadicMobius`, `BTVertex`
- **def**: `IsFixedPoint`, `isParabolic`, `padicDisk`, `BTAdjacent`
- **noncomp. def**: `det`, `apply`, `id`, `comp`, `inv`, `translation`, ... +8 more
- **theorem**: `det_id`, `det_comp`, `det_inv`, `apply_id`, `apply_translation`, `apply_scaling`, ... +12 more

### Geometry/SphericalUniverse

*5 files, 121 declarations, 1,069 lines*

#### `Foundations.lean` (340 lines)
*Source: `Geometry/SphericalUniverse/Foundations.lean`*

- **def**: `invStereo`, `stereoForward`, `conformalFactor`
- **theorem**: `sphere_compact_euclidean`, `sphere_closed`, `sphere_bounded`, `sphere_nonempty`, `invStereo_on_circle`, `invStereo_injective`, ... +15 more
- **lemma**: `one_plus_sq_pos`, `one_plus_sq_ne_zero`

#### `GravitationalWaves.lean` (245 lines)
*Source: `Geometry/SphericalUniverse/GravitationalWaves.lean`*

- **def**: `circumferenceS3`, `echoTimeDelay`, `nthEchoDelay`, `allowedWavelength`, `allowedFrequency`, `fundamentalFrequency`, ... +8 more
- **theorem**: `circumference_pos`, `echo_delay_pos`, `echo_delay_arithmetic`, `frequency_harmonic`, `fundamental_eq_first`, `dispersion_large_ell_bound`, ... +8 more

#### `HopfFibration.lean` (183 lines)
*Source: `Geometry/SphericalUniverse/HopfFibration.lean`*

- **def**: `hopfMap`, `u1Action`, `quaternionMul`, `quaternionConj`, `monopoleFlux`, `firstChernNumber`, `hopfInvariant`, `linkingNumberHopfFibers`
- **theorem**: `hopf_map_norm_identity`, `hopf_maps_sphere_to_sphere`, `u1_action_preserves_norm`, `hopf_map_u1_invariant`, `quaternion_norm_mul`, `quaternion_one_left`, ... +7 more

#### `QuotientSpaces.lean` (155 lines)
*Source: `Geometry/SphericalUniverse/QuotientSpaces.lean`*

- **def**: `volumeQuotient`, `lensSpaceOrder`, `volumeLensSpace`, `lensSpaceDegeneracy`, `binaryIcosahedralOrder`, `volumePDS`, ... +6 more
- **theorem**: `volume_quotient_pos`, `volume_quotient_lt`, `lens_space_trivial_volume`, `lens_space_degeneracy_p1`, `rp3_is_lens_space`, `pds_volume_fraction`, ... +8 more

#### `SpectralAnalysis.lean` (146 lines)
*Source: `Geometry/SphericalUniverse/SpectralAnalysis.lean`*

- **def**: `eigenvalueS3`, `degeneracyS3`, `totalModes`, `cmbPowerCoeff`
- **theorem**: `eigenvalue_nonneg`, `eigenvalue_strict_mono`, `eigenvalue_zero`, `eigenvalue_one`, `eigenvalue_two`, `degeneracy_pos`, ... +10 more

### Geometry/Stereographic

*37 files, 808 declarations, 7,683 lines*

#### `AntipodalChart.lean` (149 lines)
*Source: `Geometry/Stereographic/Core/AntipodalChart.lean`*

- **def**: `inverseStereoNullAntipodal`
- **theorem**: `inverseStereoNullAntipodal_is_null`, `inverseStereoNullAntipodal_future`, `inverseStereoNullAntipodal_in_future_cone`, `full_surjectivity`, `chart_transition_coords`, `photon_universe_encoding_complete`
- **lemma**: `inverseStereoNullAntipodal_surj`, `future_null_chart_dichotomy`

#### `AntipodalChart2.lean` (171 lines)
*Source: `Geometry/Stereographic/Core/AntipodalChart2.lean`*

- **def**: `stereoNullAnti`
- **theorem**: `stereoNull_isNull`, `stereoNullAnti_future`, `stereoNullAnti_in_future_cone`, `chart_coverage`, `complete_surjectivity`, `full_encoding_theorem`, `chart_transition_inversion`
- **lemma**: `stereoNullAnti_surj`, `future_null_k0_minus_k3_nonneg`

#### `OmegaPoint.lean` (259 lines)
*Source: `Geometry/Stereographic/Core/OmegaPoint.lean`*

- **def**: `invStereoX`, `invStereoY`, `omegaPoint`, `invStereo`, `omegaPointOnePoint`, `finiteOracle`, `oracleOnSphere`
- **theorem**: `denom_pos`, `denom_ne_zero`, `inv_stereo_on_circle`, `omega_point_on_circle`, `omega_x_tendsto_atTop`, `omega_x_tendsto_atBot`, ... +8 more

#### `SphericalCombination.lean` (95 lines)
*Source: `Geometry/Stereographic/Core/SphericalCombination.lean`*

- **theorem**: `cos_sq_add_sin_sq_eq_one`, `spherical_combination_norm_sq`, `spherical_combination_expanded`, `gram_schmidt_orthogonality`, `gram_schmidt_inner_product_zero`

#### `StereographicBridge.lean` (112 lines)
*Source: `Geometry/Stereographic/Core/StereographicBridge.lean`*

- **def**: `stereoX`, `stereoY`
- **theorem**: `stereo_inv_on_circle`, `stereo_round_trip`, `stereo_y_upper_bound`, `stereo_y_lower_bound`, `stereo_at_zero`, `stereo_at_one`, `stereo_frozen_crystal`
- **lemma**: `one_plus_sq_pos`, `one_plus_sq_ne_zero`

#### `StereographicDecoder.lean` (167 lines)
*Source: `Geometry/Stereographic/Core/StereographicDecoder.lean`*

- **noncomp. def**: `stereo_proj`, `inv_stereo_proj`
- **theorem**: `one_square_identity`, `two_square_identity`, `four_square_identity`, `eight_square_identity`, `inv_stereo_on_circle`, `rational_stereo_gives_pyth`

#### `StereographicExploration.lean` (201 lines)
*Source: `Geometry/Stereographic/Core/StereographicExploration.lean`*

- **def**: `pythTriple`, `pythQuadruple`, `tropAdd`, `tropMul`
- **noncomp. def**: `invStereo2D`, `invStereo3D`, `stereoOracle`
- **theorem**: `invStereo2D_on_circle`, `invStereo3D_on_sphere`, `invStereo2D_zero`, `invStereo2D_one`, `invStereo2D_neg_one`, `pyth_triple_identity`, ... +23 more

#### `StereographicLens.lean` (268 lines)
*Source: `Geometry/Stereographic/Core/StereographicLens.lean`*

- **def**: `circleStereographic`, `circleStereographicInv`, `parityOp`, `isLensFixedPoint`
- **theorem**: `circleStereographicInv_on_circle`, `circleStereographic_inv_left`, `circleStereographic_inv_right`, `idempotent_lens_circle`, `idempotent_dual_lens_circle`, `circleStereographic_deriv_ne_zero`, ... +5 more

#### `StereographicProjection.lean` (109 lines)
*Source: `Geometry/Stereographic/Core/StereographicProjection.lean`*

- **theorem**: `stereo_proj_2d_unit_norm`, `stereo_identity`, `inverse_stereo_first_component`, `inverse_stereo_second_component`, `stereo_proj_unit_norm_general`

#### `StereographicRationals.lean` (240 lines)
*Source: `Geometry/Stereographic/Core/StereographicRationals.lean`*

- **def**: `pythagorean_from_params`, `mediant`, `gaussNorm`
- **noncomp. def**: `stereoX`, `stereoY`, `stereoInv`, `circleAdd`, `ratRotation`
- **theorem**: `stereo_on_circle`, `stereo_injective`, `stereo_inv_left`, `pythagorean_triple_parametric`, `circle_add_stereo_x`, `circle_add_stereo_y`, ... +4 more
- **lemma**: `one_plus_sq_pos`, `one_plus_sq_ne_zero`

#### `InverseStereoResearch.lean` (403 lines)
*Source: `Geometry/Stereographic/InverseStereo/InverseStereoResearch.lean`*

- **def**: `invStereo`
- **theorem**: `inv_stereo_on_circle`, `inv_stereo_denom_pos`, `inv_stereo_at_zero`, `inv_stereo_at_one`, `inv_stereo_at_neg_one`, `inv_stereo_symmetry`, ... +42 more

#### `InverseStereoSecp256k1.lean` (199 lines)
*Source: `Geometry/Stereographic/InverseStereo/InverseStereoSecp256k1.lean`*

- **def**: `inverseStereoSK`, `stereoForwardSK`, `ecDouble_x_sk`, `ecTangentSlope_sk`, `mobiusAddSK`, `circleMultiplySK`
- **theorem**: `one_plus_sq_pos_sk`, `one_plus_sq_ne_zero_sk`, `inverseStereoSK_on_circle`, `stereo_left_inverse_sk`, `inverseStereoSK_injective`, `inverseStereoSK_zero`, ... +12 more

#### `InverseStereoUniverse.lean` (328 lines)
*Source: `Geometry/Stereographic/InverseStereo/InverseStereoUniverse.lean`*

- **structure**: `PrismGaussian`
- **inductive**: `PrismPhotonChannel`
- **def**: `invStereoCircle`, `stereoForwardCircle`, `invStereoSphere`, `invStereoHyper`, `stereoDenom`, `PrismGaussian`, ... +5 more
- **theorem**: `inv_stereo_denom_pos`, `inv_stereo_on_circle`, `inv_stereo_injective`, `stereo_round_trip`, `inv_stereo_conformal_factor`, `inv_stereo_on_sphere`, ... +27 more

#### `IntegerPoleCharts.lean` (228 lines)
*Source: `Geometry/Stereographic/Mobius/IntegerPoleCharts.lean`*

- **def**: `intPoleChart`, `intPoleChartInv`, `chartTransition`, `poleChangeMap`, `crystalPoint`, `effectiveDenom`, `transitionScale`, `transitionShift`
- **theorem**: `intPoleChart_south`, `intPoleChart_equator`, `intPoleChart_det_ne_zero`, `intPoleChart_inv_left`, `intPoleChart_inv_right`, `transition_is_affine`, ... +12 more

#### `InverseStereoMobius.lean` (295 lines)
*Source: `Geometry/Stereographic/Mobius/InverseStereoMobius.lean`*

- **def**: `poleMap`, `twoPoleMap`
- **theorem**: `one_plus_sq_pos`, `pole_map_at_zero`, `pole_map_involution`, `pole_map_antipodal`, `two_pole_same_is_id`, `two_pole_det_identity`, ... +35 more

#### `InverseStereoMobiusNext.lean` (292 lines)
*Source: `Geometry/Stereographic/Mobius/InverseStereoMobiusNext.lean`*

- **def**: `twoPole_den`, `twoPole_num`, `twoPole_det`, `mobiusMatrix`
- **theorem**: `complete_criterion_forward`, `complete_criterion_backward`, `den_num_linear_relation`, `divisor_bound`, `den_injective`, `integer_inputs_finite_set`, ... +23 more

#### `MobiusCovariance.lean` (87 lines)
*Source: `Geometry/Stereographic/Mobius/MobiusCovariance.lean`*

- **def**: `modS`, `modT`
- **noncomp. def**: `mobiusTransform`
- **theorem**: `mobius_identity`, `mobius_inversion_involution`, `modular_S_squared`, `modular_ST_cubed`, `sin_int_mul_pi`

#### `InverseStereoLandscapes.lean` (263 lines)
*Source: `Geometry/Stereographic/NDimensional/InverseStereoLandscapes.lean`*

- **theorem**: `conformal_area_element`, `conformal_factor_at_origin`, `conformal_factor_bounded`, `conformal_factor_product`, `stereo_arc_length_integrand`, `unit_inversion_involutive`, ... +26 more

#### `InverseStereoLandscapes2.lean` (202 lines)
*Source: `Geometry/Stereographic/NDimensional/InverseStereoLandscapes2.lean`*

- **theorem**: `stereo_radial_map`, `radial_fixed_point_one`, `radial_map_positive`, `radial_iterate_contraction`, `radial_iterate_expansion`, `radial_fixed_point_zero`, ... +20 more

#### `NDimStereographic.lean` (254 lines)
*Source: `Geometry/Stereographic/NDimensional/NDimStereographic.lean`*

- **def**: `invStereo1`, `invStereo2`, `hopfMap`
- **theorem**: `stereo_identity_general`, `stereo_denom_pos`, `conformal_factor_positive`, `invStereo1_on_circle`, `invStereo2_on_sphere`, `pythagorean_nd_identity_2d`, ... +25 more

#### `AdvancedTheory.lean` (242 lines)
*Source: `Geometry/Stereographic/Research/AdvancedTheory.lean`*

- **def**: `invStereoN`, `conformalFactorN`, `descartesForm`, `apollonianReflect`
- **theorem**: `invStereoN_on_sphere`, `invStereoN_injective`, `conformal_factor_1d`, `sphere_is_quadric`, `conic_stereo_parametrization`, `schottky_loxodromic_growth`, ... +7 more

#### `ConformalStructure.lean` (314 lines)
*Source: `Geometry/Stereographic/Research/ConformalStructure.lean`*

- **def**: `stereoConformalFactor`, `crossRatio`, `isDescartes`
- **theorem**: `stereoConformalFactor_pos`, `stereoConformalFactor_le_two`, `stereoConformalFactor_origin`, `conformal_factor_sq`, `conformal_factor_antipodal_sum`, `great_circle_maps_to_line`, ... +17 more

#### `BenchmarkTheory.lean` (137 lines)
*Source: `Geometry/Stereographic/Research/NeuralArchitectures/BenchmarkTheory.lean`*

- **def**: `stereoEffDim`, `parameterRatio`, `gradientVarianceBound`, `logSumExp`, `depthGradientProduct`, `warmupCosineLR`, `stereoAttentionFLOPs`, `stereoMemory`
- **theorem**: `stereo_expressiveness_lower_bound`, `parameterRatio_pos`, `parameterRatio_le_two`, `gradient_variance_bound`, `logSumExp_ge`, `depth_gradient_product_pos`, ... +5 more

#### `ConformalBackprop.lean` (117 lines)
*Source: `Geometry/Stereographic/Research/NeuralArchitectures/ConformalBackprop.lean`*

- **def**: `conformalGradScale`, `stereoLambda`, `composedGradScale`
- **theorem**: `stereoLambda_bounded`, `stereo_gradient_bounded`, `stereo_gradient_nonvanishing`, `composedGradScale_pos`, `composedGradScale_bounded`, `attention_grad_bound`, `stereo_vs_standard_gradient`

#### `ConformalEquivariance.lean` (160 lines)
*Source: `Geometry/Stereographic/Research/NeuralArchitectures/ConformalEquivariance.lean`*

- **def**: `rotationAction`, `dilationAction`, `inversionAction`, `vecSqNorm`, `stereoKernel`, `conformalEquivariantLayer`, `composedEquivariantLayers`
- **theorem**: `rotation_preserves_sqnorm`, `rotation_preserves_inner`, `rotationKernel_invariant`, `dilation_sqnorm`, `dilation_inner`, `conformalWeight_pos`, ... +4 more

#### `GaugeInvariantLoss.lean` (139 lines)
*Source: `Geometry/Stereographic/Research/NeuralArchitectures/GaugeInvariantLoss.lean`*

- **def**: `geodesicLoss`, `confFactor`, `conformalWeightedLoss`, `gaugeInvariantCE`, `sphericalVariance`, `conformalDistance`
- **theorem**: `geodesicLoss_nonneg`, `geodesicLoss_symmetric`, `geodesicLoss_zero_self`, `confFactor_pos`, `conformalWeightedLoss_nonneg`, `gaugeInvariantCE_nonneg`, ... +4 more

#### `GaugeTheory.lean` (140 lines)
*Source: `Geometry/Stereographic/Research/NeuralArchitectures/GaugeTheory.lean`*

- **def**: `gaugeField`, `gaugeInvariantKernel`, `gaugeConnection`, `gaugeCurvatureComponent`, `gaugeCovariantGrad`, `gaugeAction`, `effectiveMass`
- **theorem**: `gaugeField_positive`, `gaugeField_le_two`, `gaugeField_sq`, `gaugeInvariantKernel_symm`, `gaugeConnection_parity`, `gaugeConnection_zero`, ... +7 more

#### `HolderMoebiusFlows.lean` (157 lines)
*Source: `Geometry/Stereographic/Research/NeuralArchitectures/HolderMoebiusFlows.lean`*

- **structure**: `MoebiusFlowParam`
- **def**: `moebiusFlowAt`, `moebiusFlowConformalFactor`, `holderExponent`, `holderBound`, `flowVelocity`, `pairSqNorm`, `flowVelocitySqNorm`, `flowGradientStep`
- **theorem**: `moebiusFlowParam_at_zero`, `moebiusFlowParam_at_one`, `moebiusFlowConformalFactor_pos`, `moebiusFlowConformalFactor_bounded`, `holderExponent_valid`, `holderBound_nonneg`, ... +5 more

#### `MoebiusTransforms.lean` (121 lines)
*Source: `Geometry/Stereographic/Research/NeuralArchitectures/MoebiusTransforms.lean`*

- **structure**: `MoebiusParams`
- **def**: `moebiusDet`, `moebiusDetSqNorm`, `applyMoebius`, `composeMoebius`, `idMoebius`, `moebiusConfFactor`, `moebiusAttentionHead`, `learnableMoebiusParams`
- **theorem**: `moebiusDet_composition`, `idMoebius_det`, `moebiusConfFactor_nonneg`, `moebius_param_dim`, `moebius_param_efficiency`

#### `MultiHeadStereographic.lean` (126 lines)
*Source: `Geometry/Stereographic/Research/NeuralArchitectures/MultiHeadStereographic.lean`*

- **def**: `generalStereoDenom`, `generalInvStereo`, `headKernel`, `rotatedInput`, `multiHeadKernel`, `headSoftmaxWeight`, `multiHeadStereoAttention`, `headConformalFactor`
- **theorem**: `generalStereoDenom_pos`, `generalInvStereo_on_sphere`, `headKernel_symmetric`, `multiHeadKernel_symmetric`, `headSoftmaxWeight_pos`, `multihead_weight_sum_pos`, `headConformalFactor_bounded`, `multihead_gradient_bounded`

#### `NonAbelianGauge.lean` (190 lines)
*Source: `Geometry/Stereographic/Research/NeuralArchitectures/NonAbelianGauge.lean`*

- **structure**: `Mat2x2`
- **def**: `Mat2x2`, `Mat2x2`, `Mat2x2`, `Mat2x2`, `Mat2x2`, `Mat2x2`, ... +8 more
- **theorem**: `su2Generator_trace_zero_X`, `su2Generator_trace_zero_Z`, `su2Generator_hermitian_X`, `su2Generator_hermitian_Z`, `mat2x2Id_trace`, `nonAbelianGaugeField_trace`, ... +5 more

#### `SphericalNormalization.lean` (111 lines)
*Source: `Geometry/Stereographic/Research/NeuralArchitectures/SphericalNormalization.lean`*

- **def**: `vecSqNorm`, `sphericalNorm`, `stereoSphericalNorm`, `expMapNorm`
- **theorem**: `stereo_denom_pos`, `stereo_spherical_norm_unit`, `stereo_norm_zero_is_south_pole`, `stereo_norm_last_coord_bound`, `expMapNorm_unit`

#### `StereographicAttention.lean` (230 lines)
*Source: `Geometry/Stereographic/Research/NeuralArchitectures/StereographicAttention.lean`*

- **def**: `stereoConfFactor`, `invStereo`, `stereoKernel`, `innerProd`, `sqNorm`, `stereoDenom`, ... +3 more
- **theorem**: `stereoDenom_pos`, `stereoDenom_ne_zero`, `stereoKernel_rational`, `stereo_kernel_symmetric`, `conformal_factor_product`, `stereoSoftmaxWeight_pos`, ... +6 more

#### `StereographicPositionalEncoding.lean` (111 lines)
*Source: `Geometry/Stereographic/Research/NeuralArchitectures/StereographicPositionalEncoding.lean`*

- **def**: `spiralPos`, `sphereInnerProd`, `geodesicDist`, `stereoPosEnc`, `relativePosBias`
- **theorem**: `spiralPos_on_sphere`, `spiralPos_on_sphere_sum`, `geodesicDist_symm`, `geodesicDist_nonneg`, `geodesicDist_le_pi`, `stereoPosEnc_symm`, ... +4 more

#### `TrainingTheory.lean` (90 lines)
*Source: `Geometry/Stereographic/Research/NeuralArchitectures/TrainingTheory.lean`*

- **def**: `stereoConfFactor`, `stereoLearningRate`, `stereoEffectiveDim`, `standardGradMagnitude`, `stereoGradMagnitude`, `sphericalRegularizer`
- **theorem**: `stereoLearningRate_pos`, `stereoLearningRate_decreasing`, `stereoEffectiveDim_gt`, `stereo_capacity_lower_bound`, `stereo_gradient_advantage`, `standard_gradient_unbounded`, `sphericalRegularizer_nonneg`

#### `UnifiedLightTheory.lean` (545 lines)
*Source: `Geometry/Stereographic/UnifiedTheory/UnifiedLightTheory.lean`*

- **def**: `conformalFactor1D`, `antipodalMap`, `cayleyTransform`, `cayleyInverse`, `stereoAdd`, `stereoInvMap`, `stereoFwdMap`
- **theorem**: `weierstrass_sin`, `weierstrass_cos`, `weierstrass_differential`, `one_plus_tan_sq`, `conformalFactor1D_pos`, `conformalFactor1D_at_zero`, ... +30 more

#### `UnifiedTheory.lean` (431 lines)
*Source: `Geometry/Stereographic/UnifiedTheory/UnifiedTheory.lean`*

- **def**: `poleM`, `mirror`, `moebiusF`, `moebius`, `sigmaInv`, `sigma`, `moebiusDiscriminant`, `crossRatio`
- **theorem**: `mirror_involution`, `mirror_no_zero`, `mirror_no_real_fixed_point`, `pole_map_is_involution`, `pole_map_fixed_point_equation`, `pole_map_fixed_points`, ... +29 more
- **lemma**: `denom_pos`, `denom_ne_zero`

### InformationTheory

*15 files, 283 declarations, 3,051 lines*

#### `ChannelEntropy.lean` (185 lines)
*Source: `InformationTheory/Core/ChannelEntropy.lean`*

- **theorem**: `r4_odd_prime`, `r8_odd_prime`, `channel_ratio_identity`, `channel_ratio_pos`, `r2_prime_1mod4`, `r2_prime_3mod4`, `r4_pos`, `r8_gt_r4`
- **lemma**: `sum_divisors_not_div4_prime`, `sum_cubed_divisors_prime`, `chi4_one`, `chi4_prime_1mod4`, `chi4_prime_3mod4`

#### `CodingTheory.lean` (150 lines)
*Source: `InformationTheory/Core/CodingTheory.lean`*

- **def**: `hammingDist`
- **noncomp. def**: `hammingBallVolume`
- **theorem**: `singleton_bound_abstract`, `hammingDist`, `hammingDist`, `hammingDist`, `hammingDist`, `hammingBallVolume_pos`, ... +3 more

#### `Compression.lean` (132 lines)
*Source: `InformationTheory/Core/Compression.lean`*

- **structure**: `Codebook`
- **def**: `Codebook`
- **noncomp. def**: `Codebook`, `shannonEntropy`
- **theorem**: `no_injective_compression`, `no_universal_compression`, `incompressible_strings_lower_bound`, `incompressible_fraction_bound`, `Codebook`, `codebook_exists_of_card_le`, `kraft_inequality_nat`, `shannonEntropy_nonneg`
- **lemma**: `card_binary_strings`, `card_shorter_strings`

#### `CompressionExtensions.lean` (213 lines)
*Source: `InformationTheory/Core/CompressionExtensions.lean`*

- **theorem**: `generalized_pigeonhole`, `double_counting_card`, `no_embed_larger_vector_space`, `subspace_vs_total`, `random_incompressible_bound`, `total_shorter_strings`, ... +12 more

#### `CompressionTheory.lean` (253 lines)
*Source: `InformationTheory/Core/CompressionTheory.lean`*

- **theorem**: `no_injection_larger_to_smaller`, `universal_compression_impossible`, `no_compress_all_strings`, `pigeonhole_collision_count`, `incompressible_strings_lower_bound`, `incompressible_fraction`, ... +18 more

#### `CryptographyApplications.lean` (100 lines)
*Source: `InformationTheory/Core/CryptographyApplications.lean`*

- **def**: `hammingDistance`
- **theorem**: `rsa_key_ex1`, `rsa_correct_15`, `rsa_key_ex2`, `euler_thm_15`, `dh_correct`, `primitive_root_3_7`, ... +7 more

#### `CryptographyFoundations.lean` (65 lines)
*Source: `InformationTheory/Core/CryptographyFoundations.lean`*

- **theorem**: `dlog_example_1`, `primitive_root_3_7`, `primitive_root_2_5`, `rsa_small_keygen`, `rsa_roundtrip`, `ecc_point_on_curve`, ... +4 more

#### `Entropy.lean` (199 lines) ⚠️ 1 sorry
*Source: `InformationTheory/Core/Entropy.lean`*

- **noncomp. def**: `shannonEntropy`, `jointEntropy`, `conditionalEntropy`, `mutualInformation`, `klDivergence`
- **theorem**: `entropy_deterministic`, `gibbs_inequality`, `entropy_le_log_card`, `source_coding_lower_bound`, `data_processing_card`
- **lemma**: `logb_div_ge`, `kl_term_bound`

#### `InfiniteCompression.lean` (374 lines)
*Source: `InformationTheory/Core/InfiniteCompression.lean`*

- **theorem**: `stereo_denom_pos`, `stereo_denom_ne_zero`, `inverse_stereo_on_sphere`, `stereo_1d_denom_pos`, `stereo_1d_denom_ne_zero`, `inverse_stereo_on_circle`, ... +17 more

#### `InformationEntropy.lean` (227 lines)
*Source: `InformationTheory/Core/InformationEntropy.lean`*

- **structure**: `ProbDist`, `MaxwellDemon`
- **def**: `shannonInfo`, `boltzmannEntropy`, `gibbsEntropy`, `landauerLimit`, `IsErasure`, `demonInfoGain`, ... +4 more
- **theorem**: `shannonInfo_nonneg`, `shannonInfo_max_uniform`, `gibbs_shannon_bridge`, `landauer_principle`, `demon_resolution`, `info_entropy_roundtrip`, ... +3 more

#### `InformationGeometry.lean` (25 lines)
*Source: `InformationTheory/Core/InformationGeometry.lean`*

- **theorem**: `bernoulli_fisher`, `fisher_additive_n`, `cramer_rao_bound`, `uniform_entropy_pos`, `iof_info`

#### `NumberLineEncoding.lean` (340 lines)
*Source: `InformationTheory/Core/NumberLineEncoding.lean`*

- **structure**: `FiniteGraph`, `LabeledPhotonGraph`
- **def**: `cantorPair`, `zigzagEncode`, `encodeGaussian`, `encodeGraph`, `encodeLabeledPhotonGraph`, `PhotonHistory`, `PhotonHistory`
- **noncomp. def**: `encodeHistory`
- **theorem**: `cantorPair_injective`, `zigzagEncode_injective`, `encodeGaussian_injective`, `encodeGaussian_surjective`, `encodeGraph_injective`, `encodeHistory_nonneg`, ... +4 more

#### `SearchInfoIsomorphism.lean` (400 lines)
*Source: `InformationTheory/Core/SearchInfoIsomorphism.lean`*

- **structure**: `CollapseOperator`, `MeasurementScenario`, `SearchMeasurementInfo`, `PhotonObservation`, `GrandSynthesis`
- **def**: `uniformEntropy`, `informationGain`, `searchWork`, `CollapseOperator`, `CollapseOperator`, `CollapseOperator`, ... +10 more
- **theorem**: `search_info_isomorphism`, `entropy_one`, `entropy_two`, `entropy_doubling`, `entropy_monotone`, `entropy_nonneg`, ... +36 more

#### `SearchInformationDuality.lean` (132 lines)
*Source: `InformationTheory/Core/SearchInformationDuality.lean`*

- **structure**: `IsProbDist`
- **def**: `shannonEntropy`, `uniformDist`, `pointMass`
- **theorem**: `uniformDist_isProbDist`, `entropy_uniform`, `pointMass_isProbDist`, `entropy_collapse`, `information_gain_equals_search_space`, `binary_search_depth_pow2`, `search_information_duality`

#### `SearchTheory.lean` (256 lines)
*Source: `InformationTheory/Core/SearchTheory.lean`*

- **structure**: `Attractor`, `Repulsor`
- **def**: `SearchStrategy`, `searchImage`
- **theorem**: `attractor_identity_surjective`, `infinite_set_searchable`, `attractor_exists_for_infinite`, `finite_evasion`, `evasion_bound`, `evasion_pigeonhole`, ... +14 more

### Logic

*66 files, 1341 declarations, 14,132 lines*

#### `BootstrapChain.lean` (131 lines)
*Source: `Logic/Bootstrapping/BootstrapChain.lean`*

- **theorem**: `vacuous_bootstrap`, `something_from_nothing`, `nat_bootstrap`, `int_from_nat_pair`, `int_bootstrap_inverse`, `rat_from_int_pair`, ... +7 more

#### `FixedPointFoundations.lean` (136 lines)
*Source: `Logic/Bootstrapping/FixedPointFoundations.lean`*

- **def**: `preFixedPoints`, `postFixedPoints`, `IsContraction`
- **noncomp. def**: `fixedPointCombinator`
- **theorem**: `bootstrap_lemma`, `knaster_tarski_lfp`, `knaster_tarski_gfp`, `lfp_is_least`, `iterateBot_le_succ`, `contraction_unique_fixed_point`, `fixedPointCombinator_is_fixed`

#### `HigherBootstrap.lean` (159 lines)
*Source: `Logic/Bootstrapping/HigherBootstrap.lean`*

- **inductive**: `PropForm`
- **def**: `ackermann`, `PropValuation`, `PropForm`, `PropForm`, `PropForm`
- **theorem**: `ordinal_le_of_forall_lt`, `transfinite_bootstrap`, `universe_lift_exists`, `powerset_strictly_larger`, `ackermann_growth`, `ackermann_lt_succ`, ... +3 more

#### `SelfReference.lean` (110 lines)
*Source: `Logic/Bootstrapping/SelfReference.lean`*

- **structure**: `FormalSystem`, `ComputationModel`
- **class**: `Diagonalizable`
- **theorem**: `lawvere_fixed_point`, `cantor_no_surjection`, `goedel_abstract`, `no_universal_membership`, `quine_existence_with_selfapp`

#### `Complexity.lean` (110 lines)
*Source: `Logic/Core/Complexity.lean`*

- **theorem**: `no_free_lunch_counting`, `count_boolean_functions`, `circuit_counting_bound`, `no_injection_functions_to_circuits`, `most_functions_complex`, `cantor_diagonal`, ... +3 more

#### `ComputabilityTheory.lean` (15 lines)
*Source: `Logic/Core/ComputabilityTheory.lean`*

- **theorem**: `cantor_diag`, `incompressible`, `iof_step`

#### `DescriptiveSetTheory.lean` (48 lines)
*Source: `Logic/Core/DescriptiveSetTheory.lean`*

- **theorem**: `open_is_borel`, `closed_is_borel`, `countable_union_measurable`, `countable_inter_measurable`, `cantor_compact`, `cantor_totally_disconnected`, ... +3 more

#### `ModelTheory.lean` (81 lines)
*Source: `Logic/Core/ModelTheory.lean`*

- **theorem**: `addgroup_theory_consistent`, `field_theory_consistent`, `acf0_consistent`, `rat_dense`, `powerset_card`, `lagrange_divides`, ... +4 more

#### `OrderTheory.lean` (36 lines)
*Source: `Logic/Core/OrderTheory.lean`*

- **theorem**: `distrib_lattice_meet_sup`, `modular_law`, `complement_unique`, `double_complement`, `demorgan_inf`, `demorgan_sup`, ... +3 more

#### `PvsNP.lean` (176 lines)
*Source: `Logic/Core/PvsNP.lean`*

- **def**: `SubsetSum`, `verifySubsetSum`
- **theorem**: `subsetSum_iff_exists_certificate`, `num_subsets`, `exponential_exceeds_linear`, `berggren_nodes_at_depth`, `berggren_superpolynomial`, `subset_enumeration_exponential`, ... +3 more
- **instance**: `SubsetSum`

#### `SetTheory.lean` (101 lines)
*Source: `Logic/Core/SetTheory.lean`*

- **theorem**: `cantor_no_surjection`, `nat_int_equipollent`, `nat_countable`, `real_uncountable`, `nat_well_ordered`, `strong_induction`, `de_morgan_union`, `de_morgan_inter`

#### `SetTheoryLogic.lean` (196 lines)
*Source: `Logic/Core/SetTheoryLogic.lean`*

- **theorem**: `de_morgan_union`, `de_morgan_inter`, `set_distrib_left`, `set_distrib_right`, `compl_compl`, `absorption_union`, ... +15 more

#### `CantorDiagonal.lean` (163 lines)
*Source: `Logic/Formalization/CantorDiagonal.lean`*

- **theorem**: `cantor_no_surjection`, `cantor_diagonal_not_in_range`, `cantor_no_injection_powerset`, `lawvere_fixed_point`, `cantor_via_lawvere`, `russell_paradox`, `no_universal_decider`, `reals_uncountable`

#### `HaltingProblem.lean` (139 lines)
*Source: `Logic/Formalization/HaltingProblem.lean`*

- **def**: `productive_witness`
- **theorem**: `no_universal_decision`, `anti_diagonal_escapes`, `turing_diagonal`, `predicates_not_enumerable`, `no_universal_dominator`, `productive_witness_not_in_range`

#### `Incompleteness.lean` (180 lines)
*Source: `Logic/Formalization/Incompleteness.lean`*

- **structure**: `FormalSystem`
- **def**: `FormalSystem`, `FormalSystem`, `HasDiagonalProperty`, `AssertsOwnConsistency`
- **theorem**: `godel_first_incompleteness`, `godel_sentence_true_but_unprovable`, `tarski_undefinability`, `lob_theorem`, `godel_second_incompleteness`

#### `SelfReference.lean` (182 lines)
*Source: `Logic/Formalization/SelfReference.lean`*

- **noncomp. def**: `iterate_from_bot`
- **theorem**: `knaster_tarski_lfp`, `knaster_tarski_gfp`, `iterate_from_bot_mono`, `semantic_quine`, `y_combinator_principle`, `curry_paradox`, `no_liar_sentence`

#### `Advanced.lean` (264 lines)
*Source: `Logic/Foundations/Advanced/Advanced.lean`*

- **def**: `litCircuit`, `minterm2`, `constTrue2`, `dnfCircuit2`, `MachZehnder`, `CircuitEquiv`
- **theorem**: `notCircuit_size`, `andCircuit_size`, `orCircuit_size`, `NandCircuit`, `input_size`, `single_nand_size`, ... +22 more

#### `AdvancedTheorems.lean` (273 lines)
*Source: `Logic/Foundations/Advanced/AdvancedTheorems.lean`*

- **structure**: `SciTheory`, `OracleQuery`
- **def**: `BState`, `BState`, `bDist`, `bEvidence`, `bUpdate`, `bPure`, `bEntropy`, `SciTheory`
- **theorem**: `uniform_likelihood_identity`, `support_preservation`, `evidence_pos_of_support`, `pure_fixed_point`, `dominant_weight_nondecreasing`, `entropy_pure_zero`, ... +10 more

#### `Applications.lean` (135 lines)
*Source: `Logic/Foundations/Advanced/Applications.lean`*

- **structure**: `Codebook`, `Run`
- **inductive**: `DNABase`
- **def**: `dnaCodebook`, `decodeRuns`
- **noncomp. def**: `binaryCodebook`
- **theorem**: `Codebook`, `binaryCodebook_injective`, `dnaCodebook_injective`, `dna_needs_two_bits`, `two_symbol_optimal`, `decodeRuns_singleton_length`, ... +4 more

#### `Chronos.lean` (567 lines)
*Source: `Logic/Foundations/Advanced/Chronos.lean`*

- **structure**: `SumOfSquaresWitness`, `ResearchOracle`
- **def**: `isLightPrime`, `isDarkPrime`, `isTwilightPrime`, `lightPrimeCount`, `darkPrimeCount`, `photon_5`, ... +12 more
- **theorem**: `five_is_light`, `thirteen_is_light`, `three_is_dark`, `seven_is_dark`, `eleven_is_dark`, `two_is_twilight`, ... +44 more

#### `DecoderApplications.lean` (123 lines)
*Source: `Logic/Foundations/Advanced/DecoderApplications.lean`*

- **theorem**: `gaussian_norm_submult`, `gaussian_lattice_neighbors`, `hex_lattice_neighbors`, `two_pow_sum_four_sq`, `root_of_unity_sum`, `torus_parametrization`, ... +7 more

#### `DynamicalSystems.lean` (54 lines)
*Source: `Logic/Foundations/Advanced/DynamicalSystems.lean`*

- **def**: `collatz_step`, `rule110`
- **theorem**: `involution_period`, `neg_involution`, `zero_fixed_point_div2`, `collatz_reaches_1_from_6`, `collatz_reaches_1_from_7`, `collatz_reaches_1_from_27`, ... +5 more

#### `Engine.lean` (142 lines)
*Source: `Logic/Foundations/Advanced/Engine.lean`*

- **structure**: `RiskParams`, `TradeAction`, `EngineOutput`
- **noncomp. def**: `computePriceRelatives`, `ema`, `optimalEta`, `clamp`, `projectToConstrainedSimplex`, `computeTrades`, `turnover`
- **theorem**: `optimalEta_pos`, `clamp_le_hi`, `lo_le_clamp`, `turnover_nonneg`, `turnover_le_two`

#### `EntanglementDifficulty.lean` (202 lines)
*Source: `Logic/Foundations/Advanced/EntanglementDifficulty.lean`*

- **structure**: `ProofSearch`
- **def**: `numComponents`, `maxCliqueBound`, `chainDependency`, `completeDependency`
- **noncomp. def**: `searchSpaceSize`, `logDifficulty`, `edgeDensity`
- **theorem**: `zero_edges_zero_density`, `density_le_one`, `independent_search_additive`, `entangled_harder_than_independent`, `tree_entanglement_bound`, `chain_edge_count`, `complete_edge_count`, `decomposition_speedup`

#### `ExoticComputation.lean` (143 lines)
*Source: `Logic/Foundations/Advanced/ExoticComputation.lean`*

- **structure**: `YangBaxterOperator`, `GraphState`
- **def**: `braidRepDim`, `completeGraphState`
- **theorem**: `braidRepDim_pos`, `complete_graph_has_neighbors`, `postselection_bounded`, `quantum_search_bound`, `period_finding_qubits`, `crystallizer_topological_bound`, ... +3 more

#### `Extensions.lean` (69 lines)
*Source: `Logic/Foundations/Advanced/Extensions.lean`*

- **theorem**: `trace_B₁`, `trace_B₂`, `trace_B₃`, `ppt_c_odd`, `det_B₁_eq_one`, `det_B₂_eq_neg_one`, ... +4 more

#### `FormalTime.lean` (525 lines)
*Source: `Logic/Foundations/Advanced/FormalTime.lean`*

- **structure**: `Clock`, `IdealClock`, `Event1`, `Event`, `ArrowOfTime`, `StrictArrow`, `DiscreteTimeDynamics`, `FormalProof`
- **class**: `TemporalOrder`
- **def**: `duration`, `IdealClock`, `IdealClock`, `IdealClock`, `minkowskiInterval1`, `minkowskiInterval`, ... +16 more
- **theorem**: `rational_moment_between`, `duration_symm`, `duration_nonneg`, `duration_eq_zero_iff`, `duration_triangle`, `duration_additive`, ... +20 more

#### `HarmonicNetworkAdvanced.lean` (287 lines)
*Source: `Logic/Foundations/Advanced/HarmonicNetworkAdvanced.lean`*

- **theorem**: `relu_rational`, `relu_nonneg`, `relu_idempotent`, `stereo_first_component_bounded`, `stereo_second_component_bounded`, `stereo_neg_both`, ... +20 more

#### `HyperAgentTheory.lean` (402 lines)
*Source: `Logic/Foundations/Advanced/HyperAgentTheory.lean`*

- **structure**: `AgentOracle`, `Archive`, `DomainTransfer`
- **def**: `AgentOracle`, `IsStrangeLoop`, `Archive`, `DomainTransfer`, `MetaOracle`, `stableStrategies`, `DiverseArchive`
- **noncomp. def**: `improvement_at_k`
- **theorem**: `AgentOracle`, `AgentOracle`, `AgentOracle`, `oracle_is_strange_loop`, `monotone_bounded_convergence`, `lawvere_agent_fixpoint`, ... +14 more

#### `Hypotheses.lean` (207 lines)
*Source: `Logic/Foundations/Advanced/Hypotheses.lean`*

- **def**: `twoPole`
- **theorem**: `pythagorean_from_stereo`, `twoPole_0b_at_0`, `twoPole_transitivity`, `matrix_product_identity`, `matrix_product_identity`, `gaussian_norm`, `gaussian_product_norm`

#### `LightFromNumberLine.lean` (213 lines)
*Source: `Logic/Foundations/Advanced/LightFromNumberLine.lean`*

- **def**: `gaussianNorm`
- **theorem**: `pythagorean_parametrization`, `brahmagupta_fibonacci`, `brahmagupta_fibonacci`, `unit_circle_rational_point`, `gaussian_norm_multiplicative`, `fermat_two_square_easy_direction`, ... +19 more

#### `O1Impossibility.lean` (168 lines)
*Source: `Logic/Foundations/Advanced/O1Impossibility.lean`*

- **noncomp. def**: `closedFormStep`
- **theorem**: `k_from_p`, `p_from_k`, `k_p_equivalence`, `roundtrip_k`, `roundtrip_p`, `factor_condition`, ... +6 more

#### `OmegaMetaOracle.lean` (227 lines)
*Source: `Logic/Foundations/Advanced/OmegaMetaOracle.lean`*

- **structure**: `MetaOracleSystem`
- **def**: `MetaOracleSystem`
- **theorem**: `compact_onePoint`, `continuous_achieves_sup_on_compact`, `lift_solve_project`, `finite_ne_omega`, `onePoint_isOpenEmbedding`, `meta_oracle_has_unique_fixed_point`, ... +12 more

#### `OneGateAgent.lean` (299 lines)
*Source: `Logic/Foundations/Advanced/OneGateAgent.lean`*

- **structure**: `QuantumOracle`
- **def**: `hadamard`, `I₂`, `Qubit`, `ket0`, `ket1`, `ketPlus`, ... +12 more
- **theorem**: `sqrt_two_ne_zero`, `inv_sqrt_two_sq`, `hadamard_self_inverse`, `hadamard_ket0`, `hadamard_ket1`, `constant_or_balanced`, ... +6 more

#### `UniversalDecoder.lean` (262 lines)
*Source: `Logic/Foundations/Advanced/UniversalDecoder.lean`*

- **structure**: `SL2Z`
- **def**: `SimpleCF`, `evalCF`, `SL2Z`, `SL2Z`, `SL2Z`, `SL2Z`, `triangleArea`
- **noncomp. def**: `moebius`
- **theorem**: `rational_density_quantitative`, `rat_has_cf`, `SL2Z_S_sq`, `SL2Z_ST_order`, `moebius_sum_eq_indicator`, `euler_product_finite_sq`, `stereo_triangle_area`

#### `UniversalSATSolver.lean` (371 lines)
*Source: `Logic/Foundations/Advanced/UniversalSATSolver.lean`*

- **structure**: `SATLiteral`
- **def**: `factoringAction`, `SATLiteral`, `clauseSatisfied`, `satCost`, `IsOracleIdempotent`, `OracleFixedPoints`, ... +3 more
- **theorem**: `factoring_action_zero_iff`, `factoring_verification_correct`, `factor_symmetry`, `nontrivial_factor_bound`, `factoring_action_triangle`, `sat_cost_zero_iff`, ... +18 more

#### `UniversalSolver.lean` (360 lines)
*Source: `Logic/Foundations/Advanced/UniversalSolver.lean`*

- **structure**: `Problem`, `Reducer`, `ProjectionReducer`, `LinearOracle`, `SolverOracle`, `MetaSolver`, `FrozenCrystalSolver`
- **def**: `stereoFromNorth`, `stereoFromSouth`, `invStereoNorth`, `invStereoSouth`, `dualProjection`, `mirrorDualProjection`, ... +7 more
- **theorem**: `one_plus_sq_pos`, `invStereoSouth`, `invStereoNorth`, `invStereoSouth`, `invStereoNorth`, `dualProjection`, ... +11 more

#### `Basic.lean` (354 lines)
*Source: `Logic/Foundations/Core/Basic.lean`*

- **structure**: `QuantumOracleState`
- **def**: `FinOracle`, `oracleTrueCount`, `oracleFalseCount`, `oracleAgreements`, `oracleTransitions`, `oracleAdjWeight`, ... +10 more
- **theorem**: `oracle_partition`, `agreements_plus_transitions`, `oracle_euler_characteristic_path`, `trace_oracle_laplacian`, `general_energy_symmetry`, `constant_energy_zero`, ... +10 more

#### `CoherenceBasics.lean` (106 lines)
*Source: `Logic/Foundations/Core/CoherenceBasics.lean`*

- **def**: `shannonEntropy`, `landscapeEntropy`, `coherenceMeasure`
- **theorem**: `coherence_add_landscape_eq_one`, `shannonEntropy_nonneg`, `shannonEntropy_le_log`, `coherence_nonneg`, `coherence_le_one`

#### `CoherenceStratification.lean` (266 lines)
*Source: `Logic/Foundations/Core/CoherenceStratification.lean`*

- **def**: `CoherenceVal`, `LandscapeVal`, `InCoherenceClass`, `quantumCoherence_l1`
- **theorem**: `coherence_duality`, `coherence_nonneg`, `coherence_le_one`, `coherence_bounded`, `coherence_restriction_monotone`, `coherence_class_nested`, ... +15 more

#### `Computations.lean` (93 lines)
*Source: `Logic/Foundations/Core/Computations.lean`*

- **def**: `countDivisorsMod4`, `complexSignal`, `jacobiSumC`, `octonionicSignal`, `signatureStr`, `predicted_r₂`, `predicted_r₄`, `predicted_r₈`

#### `Core.lean` (315 lines)
*Source: `Logic/Foundations/Core/Core.lean`*

- **structure**: `PhysicalConstants`
- **def**: `planckLength`, `planckMass`, `planckEnergy`, `schwarzschildRadiusEnergy`, `schwarzschildRadius`, `horizonArea`, ... +8 more
- **theorem**: `schwarzschild_linear`, `schwarzschild_monotone`, `planck_crossing`, `bekenstein_hawking_simplified`, `entropy_quadratic`, `information_content_formula`, ... +11 more

#### `Defs.lean` (85 lines)
*Source: `Logic/Foundations/Core/Defs.lean`*

- **structure**: `IntSignature`, `NormSignature`
- **def**: `chi4`, `r2`, `r4`, `r8`, `signature`, `sigDistSq`, `normSignature`

#### `DimensionalProjection.lean` (334 lines)
*Source: `Logic/Foundations/Core/DimensionalProjection.lean`*

- **def**: `stereoForward1`, `invStereo1`, `stereoForward2`, `invStereo2`, `invStereo3`, `liftRtoS2`
- **theorem**: `inv_stereo_1d_on_circle`, `stereo_round_trip_from_R`, `stereo_round_trip_from_S1_fst`, `stereo_round_trip_from_S1_snd`, `inv_stereo_2d_on_sphere`, `stereo_2d_round_trip_fst`, ... +19 more

#### `Foundations.lean` (358 lines)
*Source: `Logic/Foundations/Core/Foundations.lean`*

- **structure**: `HypothesisSpace`, `Experiment`, `ScientificTheory`
- **def**: `BeliefState`, `BeliefState`, `Likelihood`, `Likelihood`, `evidence`, `bayesianUpdate`, ... +8 more
- **theorem**: `about`, `posterior_nonneg`, `posterior_normalized`, `bayesian_update_valid`, `entropy_nonneg`, `entropy_le_log_card`, ... +5 more

#### `GenesisProjection.lean` (212 lines)
*Source: `Logic/Foundations/Core/GenesisProjection.lean`*

- **def**: `invStereo1`, `invStereo2`, `conformalFactor`, `sphereVolume`
- **theorem**: `invStereo1_on_circle`, `invStereo1_zero`, `invStereo1_limit_north`, `invStereo2_on_sphere`, `conformalFactor_pos`, `conformalFactor_zero`, ... +8 more

#### `HigherDimensional.lean` (166 lines)
*Source: `Logic/Foundations/Core/HigherDimensional.lean`*

- **structure**: `MoebiusTransform`
- **def**: `MoebiusTransform`, `MoebiusTransform`, `MoebiusTransform`
- **theorem**: `stereographic_round_trip`, `stereographic_dual_round_trip`, `stereo_denom_pos`, `conformal_factor_pos`, `conformal_factor_south_pole`, `conformal_factor_equator`, `MoebiusTransform`

#### `LightNumberLine.lean` (382 lines) ⚠️ 1 sorry
*Source: `Logic/Foundations/Core/LightNumberLine.lean`*

- **noncomp. def**: `chi4`
- **theorem**: `pythagorean_param`, `pythagorean_param_alt`, `brahmagupta_fibonacci_identity`, `brahmagupta_fibonacci_alt`, `unit_circle_from_pythagorean`, `lightlike_null`, ... +66 more

#### `UniversalPhotonMap.lean` (211 lines)
*Source: `Logic/Foundations/Core/UniversalPhotonMap.lean`*

- **structure**: `PhotonVertex`, `PhotonArc`, `PhotonGraph`, `UndirectedPhotonGraph`, `PhotonGraphMorphism`
- **inductive**: `PhotonPath`, `UndirectedReachable`
- **def**: `PhotonArc`, `PhotonGraph`, `PhotonGraph`, `photonsAdjacent`, `PhotonGraph`, `PhotonGraph`, ... +3 more
- **noncomp. def**: `PhotonGraph`, `PhotonGraph`
- **theorem**: `PhotonPath`, `photon_graph_acyclic`, `photon_graph_is_map`, `photonsAdjacent_symm`, `UndirectedReachable`, `universe_connectivity_principle`, `equilibrium_refl`, `propagator_idempotent_at_equilibrium`

#### `UniverseIdempotent.lean` (278 lines)
*Source: `Logic/Foundations/Core/UniverseIdempotent.lean`*

- **def**: `unitCircle`, `realLine`, `invStereo`, `fwdStereo`, `IsIdempotentFn`, `conformalFactor`, `universeMap`
- **theorem**: `coexistence_ambient`, `coexistence_intersection_nonempty`, `invStereo_on_circle`, `stereo_round_trip_idempotent`, `idempotent_image_eq_fixedPoints`, `meta_oracle_is_oracle`, ... +15 more
- **lemma**: `invStereo_denom_pos`

#### `CantorParadise.lean` (179 lines)
*Source: `Logic/Foundations/Rucker/CantorParadise.lean`*

- **def**: `diagonalSet`
- **theorem**: `cantor_no_surjection`, `power_set_strictly_larger`, `diagonal_not_in_range`, `aleph0_eq_nat_card`, `aleph_strictMono`, `no_largest_cardinal`, ... +8 more

#### `ComputationAndMind.lean` (134 lines)
*Source: `Logic/Foundations/Rucker/ComputationAndMind.lean`*

- **theorem**: `most_sets_uncomputable`, `lfp_is_fixed`, `finite_pigeonhole`, `nat_prod_countable`, `rationals_dense`, `hilbert_hotel`, `evens_equinumerous`, `int_equinumerous_nat`

#### `GodelianSelfReference.lean` (168 lines)
*Source: `Logic/Foundations/Rucker/GodelianSelfReference.lean`*

- **theorem**: `lawvere_fixed_point`, `cantor_via_lawvere`, `cantor_via_bool`, `knaster_tarski_lfp`, `knaster_tarski_gfp`, `no_self_deciding_predicate`, `infinitely_many_primes`, `no_enumeration_of_subsets`

#### `InfinityLevels.lean` (174 lines)
*Source: `Logic/Foundations/Rucker/InfinityLevels.lean`*

- **theorem**: `aleph0_infinite`, `aleph_one_gt_aleph_zero`, `aleph_lt_of_lt`, `every_infinite_cardinal_is_aleph`, `beth_zero`, `beth_one`, ... +11 more

#### `TransfiniteOrdinals.lean` (183 lines)
*Source: `Logic/Foundations/Rucker/TransfiniteOrdinals.lean`*

- **noncomp. def**: `omegaTower`
- **theorem**: `one_add_omega`, `omega_add_one_gt`, `ordinal_add_not_comm`, `two_mul_omega`, `omega_mul_two_gt`, `ordinal_mul_not_comm`, ... +9 more

#### `CantorDiagonal.lean` (356 lines)
*Source: `Logic/Foundations/Spectral/CantorDiagonal.lean`*

- **def**: `ContinuumHypothesis`
- **theorem**: `cantor_antidiagonal_not_in_range`, `cantor_no_surjection`, `cantor_no_injection_powerset_to_base`, `binary_sequences_uncountable`, `reals_uncountable`, `unit_interval_uncountable`, ... +11 more

#### `EntanglementNetwork.lean` (241 lines) ⚠️ 1 sorry
*Source: `Logic/Foundations/Spectral/EntanglementNetwork.lean`*

- **structure**: `EntanglementMatching`, `MeasurementSetup`, `LocalModel`, `EntanglementGraph`, `GaussInt`, `GaussianEntangledPair`
- **def**: `MeasurementOutcome`, `isKColorable`, `GaussInt`, `GaussInt`, `encodeGI`, `zigzagDecode`, `cantorUnpair`
- **noncomp. def**: `localCorrelation`, `chshQuantity`, `entangledPartnerCode`
- **theorem**: `entanglement_requires_even`, `partner_bijective`, `bell_chsh_bound`, `GaussInt`, `GaussInt`, `GaussInt`, `GaussianEntangledPair`

#### `HarmonicNetwork.lean` (313 lines)
*Source: `Logic/Foundations/Spectral/HarmonicNetwork.lean`*

- **noncomp. def**: `stereo2D`
- **theorem**: `pythagorean_identity`, `generalized_pythagorean_identity`, `generalized_pythagorean_identity_rat`, `generalized_pythagorean_identity_real`, `stereo2D_unit_norm`, `projection_numerator_eq_sq`, ... +15 more

#### `HolographicProofs.lean` (173 lines)
*Source: `Logic/Foundations/Spectral/HolographicProofs.lean`*

- **structure**: `ModularProof`, `ProofTranslation`
- **def**: `isHolographic`, `ProofTranslation`, `ProofTranslation`, `hasWedgeReconstruction`
- **noncomp. def**: `holographicRatio`
- **theorem**: `area_law_proof`, `area_law_square`, `area_law_compression`, `bulk_boundary_decomposition`, `modular_interface_bound`, `holographic_compression_bound`, `compressing_compose`, `monotone_wedge_reconstruction`

#### `HolographicSearch.lean` (209 lines)
*Source: `Logic/Foundations/Spectral/HolographicSearch.lean`*

- **structure**: `BulkBoundaryProof`, `PartitionedProof`, `BoundarySearch`, `BulkSearch`, `EntanglementWedge`
- **def**: `isHolographicProof`, `isResilient`, `isStrongResilient`
- **noncomp. def**: `compressionRatio`, `cutSize`, `regionSize`
- **theorem**: `boundary_faster_than_bulk`, `wedge_monotone`, `full_boundary_full_wedge`, `zero_resilient`, `resilience_bound`

#### `ProofEntanglement.lean` (191 lines)
*Source: `Logic/Foundations/Spectral/ProofEntanglement.lean`*

- **structure**: `ProofGraph`
- **def**: `ProofGraph`, `ProofGraph`, `ProofGraph`, `ProofGraph`
- **noncomp. def**: `shannonEntropy`, `dependencyWeight`, `proofEntanglement`
- **theorem**: `entropy_uniform`, `entropy_point_mass`, `entropy_nonneg`, `independent_zero_entanglement`, `max_entanglement_is_log`, `shannonEntropy_nonneg_of_sum_one`, `independent_description_additive`, `compression_lower_bound`

#### `QueryComplexity.lean` (430 lines)
*Source: `Logic/Foundations/Spectral/QueryComplexity.lean`*

- **structure**: `NoisyOracle`, `BeliefState`
- **inductive**: `QueryTree`
- **def**: `IsOracle`, `BinaryOracle`, `QueryTree`, `QueryTree`, `majorityVote`, `NoisyOracle`, ... +8 more
- **theorem**: `leaf_depth_zero`, `single_query_depth`, `query_tree_distinguishing_power`, `binary_tree_leaves_bound`, `NoisyOracle`, `NoisyOracle`, ... +20 more

#### `SpectralCollapse.lean` (410 lines)
*Source: `Logic/Foundations/Spectral/SpectralCollapse.lean`*

- **structure**: `Literal`
- **def**: `IsOracle`, `FixedPoints`, `ImageSet`, `oracle_rank`, `eval_literal`, `eval_clause`, ... +5 more
- **noncomp. def**: `relu`, `tropical_add`, `compression_ratio`
- **theorem**: `oracle_image_subset_fixed`, `oracle_fixed_eq_image`, `oracle_power_collapse`, `oracle_self_compose`, `oracle_rank_eq_fixed`, `oracle_fixed_card_eq_image_card`, ... +36 more

#### `SpectralDescent.lean` (88 lines)
*Source: `Logic/Foundations/Spectral/SpectralDescent.lean`*

- **inductive**: `RVT`
- **def**: `gaussianRVT`, `descentOracle`
- **noncomp. def**: `conformalFactor`
- **theorem**: `gauss_norm_mod_four`, `conformal_pos`, `conformal_max`, `conformal_integral_is_area`, `unit_gaussian_on_circle`, `imag_unit_on_circle`, `descent_composition`

#### `TheorySpaceGeodesics.lean` (251 lines)
*Source: `Logic/Foundations/Spectral/TheorySpaceGeodesics.lean`*

- **structure**: `TheoryInterpolation`, `PhysicalTheory`
- **class**: `ExtendedTheorySpace`
- **def**: `TheoryPath`, `isGeodesic`, `isMetricMidpoint`, `isUniquelyGeodesic`
- **noncomp. def**: `geodesicEndpoints`, `interpolationLength`, `metricTriangleDefect`, `theoryDist`, `GR`, `QFT`, `QuantumGravity`
- **theorem**: `midpoint_half_dist`, `midpoint_no_detour`, `interpolation_length_bound`, `metricTriangleDefect_nonneg`, `zero_defect_on_geodesic`, `theoryDist_nonneg`, ... +4 more

#### `TheorySpaceMetric.lean` (216 lines)
*Source: `Logic/Foundations/Spectral/TheorySpaceMetric.lean`*

- **class**: `TheorySpace`
- **def**: `isDual`, `isMidpoint`
- **noncomp. def**: `triangleDefect`
- **theorem**: `simCost_is_pseudometric`, `isDual_refl`, `isDual_symm`, `isDual_trans`, `isDual_equivalence`, `midpoint_optimal`, ... +5 more

### MachineLearning/Consciousness

*6 files, 60 declarations, 701 lines*

#### `Autopoiesis.lean` (128 lines)
*Source: `MachineLearning/Consciousness/Autopoiesis.lean`*

- **structure**: `ProductionNetwork`, `AutopoieticSystem`, `StructuralCoupling`, `AutopoieticFixedPoint`, `Enactivism`
- **def**: `operationallyClosed`
- **theorem**: `autopoietic_self_producing`, `autopoietic_implies_closed`, `structural_coupling_preserves`, `organization_invariant`, `enactive_codetermination`

#### `Emergence.lean` (138 lines)
*Source: `MachineLearning/Consciousness/Emergence.lean`*

- **structure**: `MicroMacroSystem`, `DownwardCausation`, `EmergenceLevel`, `EmergentConsciousness`
- **def**: `WeaklyEmergent`, `StronglyEmergent`, `Supervenes`
- **theorem**: `weakly_emergent_commutes`, `strong_emergence_means_novelty`, `supervenience_of_well_defined`, `downward_causation_preserves`, `top_level_exists`, `consciousness_requires_whole`

#### `GlobalWorkspace.lean` (78 lines)
*Source: `MachineLearning/Consciousness/GlobalWorkspace.lean`*

- **structure**: `GWProcessor`, `Coalition`, `GlobalWorkspace`, `Ignition`, `Spotlight`
- **theorem**: `broadcasting_theorem`, `spotlight_always_on`

#### `IntegratedInformation.lean` (127 lines)
*Source: `MachineLearning/Consciousness/IntegratedInformation.lean`*

- **structure**: `InfoSystem`, `BiPartition`, `ConsciousSystem`
- **def**: `isDecomposable`
- **noncomp. def**: `earthMoverDistance`, `disconnectedTransition`, `informationLoss`
- **theorem**: `earthMoverDistance_nonneg`, `informationLoss_nonneg`, `decomposable_iff_independent`, `conscious_not_decomposable`

#### `SelfReference.lean` (118 lines)
*Source: `MachineLearning/Consciousness/SelfReference.lean`*

- **structure**: `ReflexiveDomain`, `TheorySpace`, `SelfModelingSystem`
- **theorem**: `reflexive_domain_fixed_point`, `uncreated_theory_exists`, `self_model_fixed_point`, `idempotent_self_reference`, `retraction_has_fixed_points`, `quine_exists_in_reflexive_domain`

#### `StrangeLoops.lean` (112 lines)
*Source: `MachineLearning/Consciousness/StrangeLoops.lean`*

- **structure**: `HierarchicalSystem`, `StrangeLoop`, `TangledHierarchy`, `SelfModel`, `SelfAsFixedPoint`, `GoedelLoop`
- **def**: `StrangeLoopIso`
- **theorem**: `self_model_is_strange_loop`, `unique_self_from_contraction`

### MachineLearning/Neural

*8 files, 261 declarations, 2,391 lines*

#### `CompilationCompression.lean` (324 lines)
*Source: `MachineLearning/Neural/CompilationCompression.lean`*

- **structure**: `NNLayer`, `CompilationScheme`
- **def**: `compilationError`, `KoopmanOp`, `IsEquivariant`, `NNLayer`, `NNLayer`, `CompilationScheme`, ... +3 more
- **theorem**: `compilationError_nonneg`, `compilationError_zero_of_eq`, `compilationError_triangle`, `adaptive_switching_correct`, `polynomial_degree_exponential`, `polynomial_degree_strict_growth`, ... +35 more

#### `LLMSingleMatMul.lean` (252 lines)
*Source: `MachineLearning/Neural/LLMSingleMatMul.lean`*

- **structure**: `PiecewiseAffineDecomp`
- **theorem**: `linear_collapse_two`, `linear_collapse_chain`, `linear_map_is_linear`, `linear_rep_implies_additive`, `relu_not_linear`, `finite_domain_is_matmul`, ... +11 more

#### `NNCompilationExtended.lean` (263 lines)
*Source: `MachineLearning/Neural/NNCompilationExtended.lean`*

- **def**: `tropMul`, `tropAdd`, `koopmanOp`
- **theorem**: `activation_not_affine`, `trop_distrib`, `trop_mul_zero`, `trop_mul_comm`, `trop_mul_assoc`, `trop_add_idem`, ... +27 more

#### `NNCompilationTheory.lean` (297 lines)
*Source: `MachineLearning/Neural/NNCompilationTheory.lean`*

- **structure**: `CompilationScheme`
- **def**: `tropical_mul`, `tropical_add`, `koopman_operator`, `is_exact`, `is_compact`
- **noncomp. def**: `relu`, `mobius`
- **theorem**: `relu_nonneg`, `relu_neg`, `relu_not_additive`, `relu_not_affine`, `relu_is_tropical_add`, `tropical_mul_comm`, ... +25 more

#### `NeuralCompilationTeams.lean` (500 lines)
*Source: `MachineLearning/Neural/NeuralCompilationTeams.lean`*

- **def**: `tropAdd`, `tropMul`
- **noncomp. def**: `relu`, `koopmanLinearMap`, `tropMatVec`
- **theorem**: `alpha_relu_not_linear`, `alpha_relu_no_exact_linear_approx`, `alpha_linear_determined_by_one`, `alpha_relu_vec_not_linear`, `alpha_linear_composition_is_linear`, `beta_koopman_finite_lift`, ... +23 more

#### `NeuralCrystallizerFrontier.lean` (321 lines)
*Source: `MachineLearning/Neural/NeuralCrystallizerFrontier.lean`*

- **theorem**: `crystallization_gradient_zero_at_int`, `crystallization_gradient_zero_at_half_int`, `crystallization_max_at_half_int`, `crystallization_double_angle`, `crystallization_pendulum_potential`, `gaussian_norm_multiplicative_real`, ... +29 more

#### `NeuralFactorSearch.lean` (161 lines)
*Source: `MachineLearning/Neural/NeuralFactorSearch.lean`*

- **theorem**: `four_k_sq_sub_one_eq`, `iof_soundness`, `iof_factor_exists`, `iof_gcd_nontrivial`, `residues_2k_minus_one`, `residues_2k_plus_one`, `iof_hit_count_mod_p`, `iof_loss_independent_of_factors`

#### `TropicalDeepLearningFoundations.lean` (273 lines)
*Source: `MachineLearning/Neural/TropicalDeepLearningFoundations.lean`*

- **def**: `tropAdd`, `tropMul`, `relu₀`, `zaslavsky_1d`, `max_regions_1d`, `lookup_table_size`, ... +5 more
- **theorem**: `tropAdd_comm`, `tropAdd_assoc`, `tropAdd_idem`, `tropMul_comm`, `tropMul_assoc`, `tropMul_zero_right`, ... +22 more

### MachineLearning/Prediction

*21 files, 269 declarations, 2,873 lines*

#### `AdversarialPrediction.lean` (121 lines)
*Source: `MachineLearning/Prediction/AdversarialPrediction.lean`*

- **structure**: `PredictionGame`, `AdversaryBudget`
- **def**: `isRobust`
- **noncomp. def**: `minimaxValue`, `maximinValue`, `cumulativeRegret`
- **theorem**: `weak_duality`, `expert_regret_bound_nonneg`, `average_regret_vanishes`, `lipschitz_is_robust`, `robustness_accuracy_tradeoff`, `bounded_adversary_bounded_error`, `corruption_error_bound`, `breakdown_point_principle`

#### `Applications.lean` (240 lines)
*Source: `MachineLearning/Prediction/Applications.lean`*

- **def**: `ppi_estimator`
- **theorem**: `market_prices_probability`, `lmsr_loss_bound`, `epidemic_prediction_equilibrium`, `kelly_criterion_optimal`, `kelly_fraction_bounded`, `ppi_unbiased`, ... +5 more

#### `BayesOptimal.lean` (130 lines)
*Source: `MachineLearning/Prediction/BayesOptimal.lean`*

- **def**: `isNoRegret`
- **noncomp. def**: `brierScore`, `bayesUpdate`, `ensemblePrediction`, `cumulativeLoss`, `regret`
- **theorem**: `brierScore_nonneg`, `brierScore_eq_zero_iff`, `bayes_theorem`, `bayes_update_nonneg`, `brier_optimal_prediction`, `expected_brier_at_optimum`, ... +5 more

#### `CategoryTheory.lean` (131 lines)
*Source: `MachineLearning/Prediction/CategoryTheory.lean`*

- **structure**: `PredictionMorphism`, `BayesianDist`, `ModelUpdate`
- **def**: `PredictionMorphism`, `BayesianDist`, `BayesianDist`
- **noncomp. def**: `PredictionMorphism`
- **theorem**: `composition_quality_bound`, `identity_left_unit`, `identity_right_unit`, `bayesian_monad_left_unit`, `bayesian_monad_right_unit`, `update_composition_sum`, `kan_extension_approximation`, `prediction_compositionality`

#### `CausalPrediction.lean` (138 lines)
*Source: `MachineLearning/Prediction/CausalPrediction.lean`*

- **structure**: `CausalModel`, `InstrumentalVariable`
- **noncomp. def**: `ivEstimator`
- **theorem**: `causal_observational_gap`, `no_confounding_identification`, `backdoor_adjustment`, `adjustment_bounded`, `weak_instrument_problem`, `causal_effect_bounds`, ... +3 more

#### `ComplexityClasses.lean` (118 lines)
*Source: `MachineLearning/Prediction/ComplexityClasses.lean`*

- **structure**: `PredictionProblem`
- **inductive**: `PredComplexity`
- **def**: `complexityOrder`, `PredReducible`
- **noncomp. def**: `sampleComplexity`
- **theorem**: `vc_sample_complexity`, `complexity_hierarchy_strict`, `pred_reducible_refl`, `pred_reducible_trans`, `fano_lower_bound`, `le_cam_two_point`, `computation_data_tradeoff`, `sq_model_bound`

#### `ContinuousTime.lean` (114 lines)
*Source: `MachineLearning/Prediction/ContinuousTime.lean`*

- **structure**: `DiffusionModel`
- **noncomp. def**: `riccatiODE`, `steadyStateVariance`
- **theorem**: `steady_state_is_equilibrium`, `innovation_orthogonality`, `stable_prediction_bounded`, `unstable_prediction_grows`, `estimation_error_ordering`, `prediction_filter_ratio`, `multiscale_error_decomposition`, `slow_better_predicted`

#### `Convergence.lean` (157 lines)
*Source: `MachineLearning/Prediction/Convergence.lean`*

- **theorem**: `iterative_prediction_convergence`, `iterative_prediction_vanishes`, `mwu_regret_bound_structure`, `optimal_mwu_rate`, `brier_score_decomposition`, `discrete_opinion_merging`, ... +3 more

#### `DiminishingReturns.lean` (110 lines)
*Source: `MachineLearning/Prediction/DiminishingReturns.lean`*

- **noncomp. def**: `ensembleVariance`, `marginalImprovement`, `totalCost`
- **theorem**: `ensemble_variance_limit`, `marginal_improvement_formula`, `marginal_improvement_decreasing`, `marginal_improvement_bound`, `optimal_ensemble_size_bound`, `correlated_ensemble_floor`, `total_improvement_bounded`

#### `Foundation.lean` (144 lines)
*Source: `MachineLearning/Prediction/Foundation.lean`*

- **def**: `avgIndividualError`, `ensemblePred`, `diversity`
- **theorem**: `bayes_theorem`, `bayes_preserves_total`, `ambiguity_decomposition`, `diversity_theorem`, `self_consistent_prediction_unique`, `prediction_pythagorean`, `tower_property_finite`

#### `Impossibility.lean` (156 lines)
*Source: `MachineLearning/Prediction/Impossibility.lean`*

- **def**: `SocialPredictionFn`, `unanimous`, `dictatorial`
- **theorem**: `no_free_lunch_finite`, `cantor_diagonal_prediction`, `prediction_uncertainty_principle`, `goedel_prediction_diagonal`, `prediction_liar_paradox`, `prediction_conservation`, `two_oracle_mixed_implies_dictatorial`

#### `InformationPrediction.lean` (74 lines)
*Source: `MachineLearning/Prediction/InformationPrediction.lean`*

- **noncomp. def**: `mutualInformation`, `rateDistortion`
- **theorem**: `mutual_information_nonneg`, `mutual_information_le_entropy`, `data_processing_inequality`, `prediction_compression_duality`, `lossless_prediction_cost`, `more_distortion_less_cost`, `free_prediction_high_distortion`

#### `KalmanFilter.lean` (86 lines)
*Source: `MachineLearning/Prediction/KalmanFilter.lean`*

- **structure**: `KalmanState`, `SystemModel`
- **noncomp. def**: `predict`, `kalmanGain`, `riccatiStep`, `steadyStateGain`
- **theorem**: `kalman_gain_nonneg`, `riccati_nonneg`, `no_observation_variance_grows`, `kalman_unbiased`

#### `MartingalePrediction.lean` (110 lines)
*Source: `MachineLearning/Prediction/MartingalePrediction.lean`*

- **structure**: `PredictionMarket`, `DoobDecomposition`
- **def**: `isSupermartingale`, `isSubmartingale`, `isMartingale`, `MarketHistory`, `isEfficient`, `hasBoundedIncrements`, `predictionsConverge`
- **noncomp. def**: `doobDecompose`, `exponentialSmoothing`
- **theorem**: `martingale_is_super_and_sub`, `martingale_constant_value`, `supermartingale_value_decreases`, `efficient_market_constant`, `bounded_increments_total_bound`, `exponentialSmoothing_convex`

#### `MetaPrediction.lean` (132 lines)
*Source: `MachineLearning/Prediction/MetaPrediction.lean`*

- **structure**: `MetaPredictor`
- **def**: `isCalibrated`, `predictionHierarchy`, `isSelfAware`
- **theorem**: `perfect_calibration_accuracy`, `meta_prediction_incompleteness`, `quality_estimation_limit`, `brier_decomposition`, `overconfidence_penalty`, `hierarchy_converges`, `hierarchy_total_bounded`, `calibration_fixed_point`

#### `OnlineLearning.lean` (111 lines)
*Source: `MachineLearning/Prediction/OnlineLearning.lean`*

- **def**: `FTL_consistent`
- **noncomp. def**: `expertWeight`, `potential`
- **theorem**: `expert_weight_pos`, `better_expert_higher_weight`, `multiplicative_weights_regret`, `optimal_learning_rate`, `ftl_stable_regret`, `online_to_batch`, ... +3 more

#### `OracleTeam.lean` (77 lines)
*Source: `MachineLearning/Prediction/OracleTeam.lean`*

- **structure**: `ConfidentOracle`, `OracleCouncil`
- **noncomp. def**: `OracleCouncil`, `hedge`
- **theorem**: `unanimous_council`, `ensemble_no_worse_than_best`, `hedge_interpolates`

#### `PredictionGeometry.lean` (356 lines)
*Source: `MachineLearning/Prediction/PredictionGeometry.lean`*

- **structure**: `PredictionOracle`, `PredictionHorizon`, `ContractiveOracle`
- **def**: `PredictionOracle`, `PredictionOracle`, `PredictionOracle`, `PredictionOracle`, `PredictionOracle`
- **noncomp. def**: `PredictionHorizon`, `shannonEntropy`, `predictability`, `majorityErrorBound`
- **theorem**: `PredictionOracle`, `PredictionOracle`, `PredictionHorizon`, `PredictionHorizon`, `horizon_decreases_with_chaos`, `max_entropy_uniform`, ... +9 more

#### `PredictionLimits.lean` (141 lines)
*Source: `MachineLearning/Prediction/PredictionLimits.lean`*

- **structure**: `ChaoticSystem`, `PredictionAggregator`
- **inductive**: `OracleLevel`
- **def**: `Predictor`, `isPredictable`, `isUnanimous`, `isMonotone`, `canSolve`
- **noncomp. def**: `weightedAverage`
- **theorem**: `exists_unpredictable_sequence`, `no_free_lunch_binary`, `chaos_prediction_error_grows`, `fano_inequality_simplified`, `weightedAverage_unanimous`, `weightedAverage_monotone`, `god_subsumes_mortal`, `hierarchy_strict`

#### `TemporalSheaves.lean` (107 lines)
*Source: `MachineLearning/Prediction/TemporalSheaves.lean`*

- **structure**: `TimeInterval`, `Ensemble`, `PredictionSequence`
- **inductive**: `PredictionClass`
- **def**: `TimeInterval`
- **noncomp. def**: `Ensemble`, `mspe`, `horizonByClass`
- **theorem**: `Ensemble`, `mspe_nonneg`, `deterministic_infinite_horizon`, `incomputable_zero_horizon`

#### `UncertaintyPrinciple.lean` (120 lines)
*Source: `MachineLearning/Prediction/UncertaintyPrinciple.lean`*

- **structure**: `PredictionInterval`
- **noncomp. def**: `entropyPower`
- **theorem**: `prediction_information_bound`, `prediction_floor`, `information_efficiency_bound`, `cramer_rao_bound`, `cramer_rao_scaling`, `gaussian_achieves_cramer_rao`, ... +5 more

### MachineLearning/QuantumTransformer

*10 files, 145 declarations, 1,289 lines*

#### `Architecture.lean` (109 lines)
*Source: `MachineLearning/QuantumTransformer/Architecture.lean`*

- **structure**: `DensityMatrix`, `QuantumChannel`, `UnitaryGate`, `QuantumTokenEmbedding`, `QuantumAttention`, `QuantumTransformerLayer`, `QuantumTransformer`
- **theorem**: `quantum_attention_params_exceed_classical`, `quantum_transformer_function_count`, `classical_attention_embeds_in_quantum`

#### `BiologicalCrystallization.lean` (104 lines)
*Source: `MachineLearning/QuantumTransformer/BiologicalCrystallization.lean`*

- **def**: `is_one_hot`, `is_k_sparse`, `order_parameter`
- **theorem**: `one_hot_sum_one`, `one_hot_binary`, `one_hot_crystal_loss_zero`, `one_hot_is_1_sparse`, `zero_is_0_sparse`, `sparse_monotone`, ... +4 more

#### `CrystallizationTheory.lean` (228 lines)
*Source: `MachineLearning/QuantumTransformer/CrystallizationTheory.lean`*

- **def**: `crystal_loss`
- **theorem**: `crystal_loss_nonneg`, `crystal_loss_eq_zero_iff`, `crystal_loss_max`, `crystal_loss_at_half`, `perm_comp_is_perm`, `perm_id_exists`, ... +18 more

#### `CrystallizationTraining.lean` (119 lines)
*Source: `MachineLearning/QuantumTransformer/CrystallizationTraining.lean`*

- **def**: `entry_crystal_loss`, `row_crystal_loss`, `geometric_anneal`, `combined_loss`
- **theorem**: `crystal_regularizer_nonneg`, `entry_loss_bounded`, `crystal_regularizer_zero_iff_binary`, `anneal_pos`, `anneal_decreasing`, `anneal_converges`, ... +3 more

#### `Foundations.lean` (205 lines)
*Source: `MachineLearning/QuantumTransformer/Foundations.lean`*

- **theorem**: `hilbert_space_dim_exponential`, `pure_state_params_exponential`, `quantum_vs_classical_params`, `max_entropy_linear_bound`, `maximally_mixed_entropy`, `holevo_classical_capacity`, ... +7 more

#### `Moonshots.lean` (100 lines)
*Source: `MachineLearning/QuantumTransformer/Moonshots.lean`*

- **def**: `crystallize_step`
- **theorem**: `compression_benefit`, `finite_crystallized_models`, `quantum_exploration_space`, `hybrid_advantage`, `measurement_collapse`, `crystallize_pushes_apart`, ... +5 more

#### `QualityBounds.lean` (108 lines)
*Source: `MachineLearning/QuantumTransformer/QualityBounds.lean`*

- **def**: `total_variation`
- **theorem**: `tv_nonneg`, `tv_symm`, `total_variation_triangle`, `tv_le_one`, `crystal_loss_bounds_tv_sq`, `pinsker_via_crystal_loss`, ... +3 more

#### `QuantumCompilation.lean` (135 lines)
*Source: `MachineLearning/QuantumTransformer/QuantumCompilation.lean`*

- **theorem**: `swap_order_two`, `swap_involutive`, `bubble_sort_swaps_bound`, `parallel_depth`, `quantum_speedup`, `qubit_space_dimension`, ... +10 more

#### `QuantumErrorCorrection.lean` (72 lines)
*Source: `MachineLearning/QuantumTransformer/QuantumErrorCorrection.lean`*

- **def**: `logical_qubits`
- **theorem**: `swap_involution`, `swap_self_inverse`, `swap_symmetric`, `steane_code_params`, `surface_code_overhead`, `swap_circuit_overhead`, ... +5 more

#### `TropicalFFN.lean` (109 lines)
*Source: `MachineLearning/QuantumTransformer/TropicalFFN.lean`*

- **def**: `relu_crystal_loss`, `is_tropical_monomial`
- **theorem**: `tropical_add_comm`, `tropical_add_assoc`, `tropical_mul_comm`, `tropical_distrib`, `tropical_add_identity`, `tropical_mul_identity`, ... +13 more

### MachineLearning/ShefferFunction

*5 files, 66 declarations, 574 lines*

#### `Algebra.lean` (98 lines)
*Source: `MachineLearning/ShefferFunction/Algebra.lean`*

- **inductive**: `Expr`
- **def**: `Expr`, `Expr`, `Expr`, `Expr`
- **noncomp. def**: `softplus`, `Expr`, `Expr`
- **theorem**: `softplus_differentiable`, `Expr`, `Expr`, `Expr`, `Expr`, `Expr`, `Expr`, `Expr`

#### `Basic.lean` (236 lines)
*Source: `MachineLearning/ShefferFunction/Basic.lean`*

- **inductive**: `ShefferExpr`
- **noncomp. def**: `softplus`, `ShefferExpr`
- **theorem**: `Polynomial`, `Polynomial`, `poly_activation_stays_poly`, `one_plus_exp_pos`, `softplus_pos`, `softplus_strictMono`, ... +11 more

#### `Convexity.lean` (96 lines)
*Source: `MachineLearning/ShefferFunction/Convexity.lean`*

- **noncomp. def**: `softplus`, `logisticSigmoid`
- **theorem**: `one_plus_exp_pos`, `logisticSigmoid_pos`, `logisticSigmoid_lt_one`, `logisticSigmoid_nonneg`, `logisticSigmoid_le_one`, `logisticSigmoid_complement`, ... +8 more

#### `IdentityExtraction.lean` (65 lines)
*Source: `MachineLearning/ShefferFunction/IdentityExtraction.lean`*

- **noncomp. def**: `softplus`
- **theorem**: `one_plus_exp_pos`, `softplus_identity_extraction`, `softplus_reflection`, `softplus_sum_formula`, `softplus_zero`, `softplus_zero_double`, `softplus_scaled_identity`

#### `ReLUApproximation.lean` (79 lines)
*Source: `MachineLearning/ShefferFunction/ReLUApproximation.lean`*

- **noncomp. def**: `softplus`
- **theorem**: `softplus_ge_relu`, `softplus_div_tendsto_relu_pos`, `softplus_div_tendsto_relu_neg`, `softplus_le_add_log2`, `softplus_sub_id_tendsto`

### NeuralCompilation

*4 files, 77 declarations, 557 lines*

#### `Crystallization.lean` (152 lines)
*Source: `NeuralCompilation/Crystallization.lean`*

- **def**: `crystalLoss`, `gaussNormC`
- **theorem**: `crystal_error_bound`, `crystal_exact_int`, `total_crystal_error`, `int_weight_add`, `int_weight_mul`, `int_weight_neg`, ... +13 more

#### `KoopmanDimension.lean` (140 lines)
*Source: `NeuralCompilation/KoopmanDimension.lean`*

- **def**: `KoopmanLift`, `IsEquivKoop`
- **theorem**: `KoopmanLift`, `KoopmanLift`, `KoopmanLift`, `KoopmanLift`, `minimal_lifting_dimension`, `lifting_dim_linear`, ... +12 more

#### `QuantumCompilation.lean` (153 lines)
*Source: `NeuralCompilation/QuantumCompilation.lean`*

- **def**: `QGaussNorm`, `QQuatNorm`
- **theorem**: `QGaussNorm_mul`, `pauli_x_norm_sum`, `pauli_y_norm_sum`, `hadamard_scaled_norm_sum`, `QQuatNorm_nonneg`, `QQuatNorm_zero_iff`, ... +12 more

#### `TensorRankBounds.lean` (112 lines)
*Source: `NeuralCompilation/TensorRankBounds.lean`*

- **theorem**: `kronecker_rank_multiplicative`, `composed_rank_bound`, `composed_rank_exponential_growth`, `attention_head_rank_bound`, `transformer_layer_rank`, `degree_composition`, ... +10 more

### NumberTheory/Core

*18 files, 229 declarations, 2,481 lines*

#### `AdditiveCombinatorics.lean` (67 lines)
*Source: `NumberTheory/Core/AdditiveCombinatorics.lean`*

- **def**: `sumset`
- **theorem**: `schur_two_colors`, `singleton_ap_free`, `sum_binomial`, `gcd_divides_N`, `factor_divides`, `pigeonhole_intersection`

#### `AlgebraicNumberTheory.lean` (33 lines)
*Source: `NumberTheory/Core/AlgebraicNumberTheory.lean`*

- **theorem**: `bf_identity1`, `bf_identity2`, `qr_neg1_5`, `qr_neg1_3`, `qr_2_7`, `qr_2_5`, ... +4 more

#### `ArithmeticCombinatorics.lean` (29 lines)
*Source: `NumberTheory/Core/ArithmeticCombinatorics.lean`*

- **def**: `sumset`
- **theorem**: `sumset_card_le_mul`, `ap_compression_ratio`, `compression_pigeonhole`

#### `ArithmeticDarkMatter.lean` (335 lines) ⚠️ 1 sorry
*Source: `NumberTheory/Core/ArithmeticDarkMatter.lean`*

- **structure**: `ArithParticle`
- **inductive**: `DarkPath`
- **def**: `Q_form`, `ArithParticle`, `ArithParticle`, `ArithParticle`, `ArithParticle`, `massIsRealized`, ... +9 more
- **theorem**: `every_nonneg_mass_realized`, `B1_preserves_Q`, `B2_preserves_Q`, `B3_preserves_Q`, `dark_mass_conservation`, `universal_branching`, `dark_has_more_states`

#### `ArithmeticDerivative.lean` (56 lines)
*Source: `NumberTheory/Core/ArithmeticDerivative.lean`*

- **def**: `arithmeticDerivative`
- **theorem**: `arithmeticDerivative_prime`, `ppow_self_div_mul_exp`, `primeFactors_prime_pow_self`, `arithmeticDerivative_ppow_eq_self`

#### `ArithmeticGeometry.lean` (78 lines)
*Source: `NumberTheory/Core/ArithmeticGeometry.lean`*

- **def**: `IsCongruent`
- **theorem**: `six_is_congruent`, `two10_is_congruent`, `thirty_is_congruent`, `En_curve_eq`, `En_nonsingular`, `ppt_point_on_curve_scaled`, ... +3 more

#### `CongruentNumber.lean` (79 lines)
*Source: `NumberTheory/Core/CongruentNumber.lean`*

- **theorem**: `congruent_map_identity`, `pyth_quartic_identity`, `congruent_curve_factored`, `two_torsion_points`, `pyth_a_ne_b`

#### `DiophantineApproximation.lean` (26 lines)
*Source: `NumberTheory/Core/DiophantineApproximation.lean`*

- **theorem**: `pell_c0`, `pell_c1`, `pell_c2`, `pell_c3`, `pell_c4`, `cassini_ex`, `liouville_ex`, `z_r_close`

#### `FLT4.lean` (52 lines)
*Source: `NumberTheory/Core/FLT4.lean`*

- **theorem**: `flt4_strong`, `flt4`, `no_square_legs_pyth`

#### `GaussianIntegers.lean` (95 lines)
*Source: `NumberTheory/Core/GaussianIntegers.lean`*

- **theorem**: `gaussian_norm_eq`, `gaussian_norm_pyth`, `sum_two_sq_factored`, `gaussian_norm_mul`, `gaussian_square_parametrization`, `gaussian_square_norm`, ... +5 more

#### `LightDarkPrimes.lean` (326 lines)
*Source: `NumberTheory/Core/LightDarkPrimes.lean`*

- **def**: `hammingWt`, `bitLen`, `IsLightPrime`, `IsDarkPrime`, `lightDarkOracle`, `IsMersennePrime`, ... +4 more
- **theorem**: `light_dark_classification`, `light_dark_exclusive`, `three_is_light`, `five_is_light`, `seven_is_light`, `thirtyone_is_light`, ... +15 more

#### `MontgomeryPairCorrelation.lean` (550 lines)
*Source: `NumberTheory/Core/MontgomeryPairCorrelation.lean`*

- **def**: `differenceSet`, `nonzeroDifferenceSet`, `autocorrelationEnergy`, `additiveQuadruples`, `sidonDefect`, `sidonDefectCompute`, ... +6 more
- **theorem**: `zero_mem_differenceSet`, `nonzero_diff_card_le`, `sidon_diff_card`, `autocorrelation_total_sum`, `sidon_iff_defect_zero`, `pairCorr_eq_autocorr`, ... +16 more

#### `Moonshine.lean` (122 lines)
*Source: `NumberTheory/Core/Moonshine.lean`*

- **def**: `berggren_M1`, `berggren_M3`, `GammaTheta`
- **noncomp. def**: `j_from_lambda`
- **theorem**: `berggren_eq_theta`, `SL2_F3_card`, `SL2_F5_card`, `SL2_F7_card`, `SL2_order_formula`, `SL2_F11_card`, ... +5 more

#### `Multiplicativity.lean` (95 lines)
*Source: `NumberTheory/Core/Multiplicativity.lean`*

- **noncomp. def**: `sigma1_star`, `sigma3_pm`
- **theorem**: `r4_eq_8_sigma1_star`, `r8_eq_16_sigma3_pm`
- **lemma**: `sigma1_star_one`, `sigma1_star_odd_prime`, `sigma3_pm_one`, `sigma3_pm_odd_prime`

#### `NumberTheory.lean` (171 lines)
*Source: `NumberTheory/Core/NumberTheory.lean`*

- **theorem**: `exists_prime_factor`, `prime_dvd_mul`, `semiprime_divisor_count`, `fermat_little`, `wilson`, `euler_theorem`, ... +5 more

#### `NumberTheoryAdvanced.lean` (98 lines)
*Source: `NumberTheory/Core/NumberTheoryAdvanced.lean`*

- **theorem**: `legendre_mul`, `totient_mul_coprime`, `totient_prime`, `sum_divisors_6`, `sum_divisors_28`, `six_is_perfect`, ... +11 more

#### `NumberTheoryDeep.lean` (175 lines)
*Source: `NumberTheory/Core/NumberTheoryDeep.lean`*

- **theorem**: `neg_one_qr_mod5`, `neg_one_not_qr_mod3`, `neg_one_qr_mod13`, `neg_one_not_qr_mod7`, `two_qr_mod7`, `two_not_qr_mod5`, ... +16 more

#### `PrimeSignatures.lean` (94 lines)
*Source: `NumberTheory/Core/PrimeSignatures.lean`*

- **theorem**: `r4_prime_uniform`, `signature_gap_constant`, `channel_ratio_is_twice_eisenstein_norm`, `sum_of_cubes_factor`

### NumberTheory/Diophantine

*3 files, 35 declarations, 385 lines*

#### `LinearDiophantine.lean` (113 lines)
*Source: `NumberTheory/Diophantine/LinearDiophantine.lean`*

- **theorem**: `bezout_identity_explicit`, `linear_diophantine_solvable_iff`, `linear_diophantine_family`, `linear_diophantine_homogeneous`, `linear_diophantine_difference`, `linear_diophantine_coprime`, `linear_diophantine_zero`

#### `Pipeline.lean` (164 lines)
*Source: `NumberTheory/Diophantine/Pipeline.lean`*

- **structure**: `VerifiedSolution`
- **def**: `DiophantineSolution`, `IsIdempotent`, `berggrenA`, `berggrenB`, `berggrenC`, `pythagorean_3_4`, `pythagorean_5_12`
- **theorem**: `id_is_idempotent`, `const_is_idempotent`, `idempotent_composition`, `idempotent_fixed_point_iff`, `stereographic_on_circle`, `base_triple_pythagorean`, ... +4 more
- **instance**: `diophantine_verification_decidable`

#### `QuadraticDiophantine.lean` (108 lines)
*Source: `NumberTheory/Diophantine/QuadraticDiophantine.lean`*

- **def**: `IsPythagoreanTriple`, `IsPrimitivePythagoreanTriple`
- **theorem**: `no_integer_sqrt2`, `parametric_is_pythagorean`, `not_sum_two_squares_of_three_mod_four`, `flt4_diophantine`, `pell_sqrt2_base_solution`, `pell_sqrt2_recurrence`, `pell_composition`

### NumberTheory/Factoring

*4 files, 55 declarations, 685 lines*

#### `HyperbolicFactoring.lean` (135 lines)
*Source: `NumberTheory/Factoring/HyperbolicFactoring.lean`*

- **def**: `OnHyperbola`
- **noncomp. def**: `hyperbolaPoints`
- **theorem**: `divisor_gives_lattice_point`, `lattice_point_gives_divisor`, `divisor_iff_lattice_point`, `hyperbola_symm`, `lattice_point_count_eq_num_divisors`, `n210_factorization`, ... +8 more

#### `Core.lean` (293 lines)
*Source: `NumberTheory/Factoring/IOF/Core.lean`*

- **def**: `IsSmooth`, `factorBase`
- **noncomp. def**: `sqMap`, `sqIter`, `castToFactor`, `Lnotation`
- **theorem**: `sqMap_eventually_periodic`, `sqIter_eq_pow`, `orbit_CRT_decomposition`, `orbit_period_divides_lcm`, `isSmooth_one`, `isSmooth_mul`, ... +10 more

#### `Advanced.lean` (87 lines)
*Source: `NumberTheory/Factoring/IntegerOrbitFactoring/Advanced.lean`*

- **theorem**: `collision_pigeonhole`, `brent_detection`, `multi_start_probability_bound`, `pow_eq_one_of_order_dvd`

#### `Basic.lean` (170 lines)
*Source: `NumberTheory/Factoring/IntegerOrbitFactoring/Basic.lean`*

- **def**: `IsCollision`, `pollardMap`
- **noncomp. def**: `orbitSeq`, `reductionMap`
- **theorem**: `orbitSeq_succ`, `orbitSeq_eq_iterate`, `factor_from_mod_collision`, `orbit_eventually_periodic`, `collision_within_card`, `pollardMap_commutes_with_reduction`, ... +3 more

### NumberTheory/IntegerEnergy

*1 files, 37 declarations, 223 lines*

#### `RiemannConnection.lean` (223 lines)
*Source: `NumberTheory/IntegerEnergy/RiemannConnection.lean`*

- **def**: `RobinInequality`, `robinRatio`, `abundanceRatio`, `IsHighlyComposite`, `IsSuperabundant`
- **theorem**: `sigma_5040`, `divisors_5040`, `five040_eq_factorial`, `five040_factorization`, `hcn_exponents_5040`, `sigma_10080`, ... +26 more

### NumberTheory/RiemannHypothesis

*1 files, 14 declarations, 184 lines*

#### `RiemannHypothesis.lean` (184 lines)
*Source: `NumberTheory/RiemannHypothesis/RiemannHypothesis.lean`*

- **theorem**: `hermitian_eigenvalues_real`, `infinitely_many_primes`, `bertrand_postulate`, `prime_ge_three_odd`, `vonMangoldt_at_prime`, `vandermonde_vanishes_at_collision`, ... +8 more

### Physics/AlgebraicPhysics

*11 files, 275 declarations, 2,378 lines*

#### `AlgebraicElectricity.lean` (236 lines)
*Source: `Physics/AlgebraicPhysics/AlgebraicElectricity.lean`*

- **structure**: `OnePort`
- **def**: `ohmsLaw`, `powerDissipation`, `bettiOne`
- **noncomp. def**: `parallelImpedance`, `cubeRootOfUnity`, `OnePort`
- **theorem**: `parallelImpedance_comm`, `parallelImpedance_eq_inv_sum_inv`, `series_identity`, `parallel_zero`, `parallel_self`, `cube_root_cubed`, ... +8 more

#### `AlgebraicMagnetism.lean` (166 lines)
*Source: `Physics/AlgebraicPhysics/AlgebraicMagnetism.lean`*

- **theorem**: `multipole_decomposition_dim`, `multipole_channels`, `exchange_tensor_decomposition`, `antisymmetric_dim`, `clebsch_gordan_equal`, `casimir_monotone`, ... +3 more

#### `AlgebraicMirror.lean` (220 lines)
*Source: `Physics/AlgebraicPhysics/AlgebraicMirror.lean`*

- **structure**: `AlgebraicMirror`
- **def**: `SelfAware`, `maxMirror`, `AlgebraicMirror`, `reluMirror`
- **theorem**: `mem_selfAware_iff`, `reflect_is_selfAware`, `selfAware_stable`, `reflect_on_selfAware_eq_id`, `range_reflect_eq_selfAware`, `max_idempotent`, ... +15 more

#### `AlgebraicPhysics.lean` (182 lines)
*Source: `Physics/AlgebraicPhysics/AlgebraicPhysics.lean`*

- **theorem**: `lie_bracket_antisymm`, `lie_bracket_jacobi`, `lie_bracket_self_zero`, `star_add_distrib`, `star_star_eq_self`, `star_mul_reverse`, ... +11 more

#### `AlgebraicReality.lean` (286 lines)
*Source: `Physics/AlgebraicPhysics/AlgebraicReality.lean`*

- **structure**: `CayleyDicksonPair`
- **noncomp. def**: `quaternion_norm_sq`
- **theorem**: `complex_commutative`, `complex_norm_sq_multiplicative`, `quaternion_noncommutative`, `quaternion_ij_eq_k`, `quaternion_ji_eq_neg_k`, `brahmagupta_fibonacci_identity`, ... +28 more

#### `AlgebraicSpaceTheory.lean` (204 lines)
*Source: `Physics/AlgebraicPhysics/AlgebraicSpaceTheory.lean`*

- **theorem**: `spec_contravariant`, `spec_field_unique`, `zeroLocus_antitone`, `zeroLocus_top`, `krull_dim_field`, `krull_dim_pid`, ... +6 more

#### `AlgebraicSpacetime.lean` (308 lines)
*Source: `Physics/AlgebraicPhysics/AlgebraicSpacetime.lean`*

- **structure**: `EMField`
- **def**: `minkowskiQ`, `minkowski4Q`, `isNull`, `isTimelike`, `isSpacelike`, `minkowskiB`, ... +9 more
- **theorem**: `minkowskiB_self`, `minkowskiB_comm`, `null_iff_pythagorean`, `null_scale`, `causal_trichotomy`, `lorentz_boost_preserves_Q`, ... +26 more

#### `Foundations.lean` (203 lines)
*Source: `Physics/AlgebraicPhysics/Foundations.lean`*

- **structure**: `TemporalFlow`, `EntropyFunctional`, `ReversibleFlow`
- **def**: `IsEquilibrium`
- **noncomp. def**: `linearFlow`
- **theorem**: `arrow_of_time`, `temporal_duality_order_reversal`, `temporal_duality_involution`, `flow_identity`, `flow_composition`, `flow_triple_composition`, ... +5 more

#### `MirrorFixedPoints.lean` (127 lines)
*Source: `Physics/AlgebraicPhysics/MirrorFixedPoints.lean`*

- **structure**: `MirrorMap`
- **def**: `fixedPoints`, `tropicalMaxMirror`, `MirrorMap`, `MirrorMap`
- **theorem**: `image_eq_fixedPoints`, `image_subset_fixedPoints`, `retraction`, `mem_fixedPoints_iff`, `tropicalMaxMirror_fixedPoints`, `MirrorMap`, ... +4 more

#### `MirrorGodel.lean` (118 lines)
*Source: `Physics/AlgebraicPhysics/MirrorGodel.lean`*

- **theorem**: `real_add_left_cancel`, `max_not_left_cancel`, `selective_idempotent_not_cancellative`, `tropical_self_ref_has_fixpoint`, `tropical_self_ref_fixpoints`, `classical_self_ref_unique`, ... +6 more

#### `NuclearAlgebra.lean` (328 lines)
*Source: `Physics/AlgebraicPhysics/NuclearAlgebra.lean`*

- **def**: `casimir_U5`, `casimir_SU3`, `casimir_O6`, `casimir_O5`, `casimir_O3`, `shell_degeneracy`, ... +5 more
- **theorem**: `nuclear_algebra_generators`, `u5_generators`, `su3_generators`, `o6_generators`, `o5_generators`, `o3_generators`, ... +46 more

### Physics/ArchitectureOfReality

*5 files, 84 declarations, 567 lines*

#### `GodConsultation.lean` (95 lines)
*Source: `Physics/ArchitectureOfReality/GodConsultation.lean`*

- **theorem**: `gods_gift_induction`, `gods_gift_choice`, `gods_gift_lem`, `we_can_prove_master`, `we_can_prove_tropical`, `we_can_prove_counting`, ... +3 more

#### `IdempotentCounting.lean` (130 lines)
*Source: `Physics/ArchitectureOfReality/IdempotentCounting.lean`*

- **def**: `IsIdem`, `idemSet`, `idemCount`, `gaussBinom`, `totalProjections`
- **theorem**: `idem_count_1`, `idem_count_2`, `idem_count_3`, `idem_count_4`, `idem_count_5`, `idem_count_6`, ... +19 more

#### `KauffmanBracket.lean` (81 lines)
*Source: `Physics/ArchitectureOfReality/KauffmanBracket.lean`*

- **inductive**: `Smoothing`
- **def**: `KnotState`, `stateSigma`, `writhe`, `IsTLIdempotent`, `rootOfUnity`, `braidingEigenvalues`
- **theorem**: `smoothing_count_sum`, `trefoil_writhe`, `unknot_writhe`, `TL_at_delta_one`, `smoothing_card`, `state_count`

#### `TropicalLanglands.lean` (100 lines)
*Source: `Physics/ArchitectureOfReality/TropicalLanglands.lean`*

- **structure**: `TropHeckeOp`
- **def**: `IsTropChar`, `tropFourier`, `tropConv`, `IsTropEigenform`
- **theorem**: `trop_char_trivial`, `trop_char_inv`, `trop_char_pow`, `trop_char_finite_trivial`, `trop_char_add`, `trop_char_scale`, `tropical_universal_idempotent`, `tropical_distrib`

#### `UnificationGraph.lean` (161 lines)
*Source: `Physics/ArchitectureOfReality/UnificationGraph.lean`*

- **structure**: `Bridge`, `BridgeTransformation`
- **inductive**: `MathDomain`
- **def**: `establishedBridges`, `newBridges`, `maxEdges`, `hasIdempotentStructure`, `allBridges`, `connected`, `stone_gelfand_transformation`
- **theorem**: `domain_count`, `established_bridge_count`, `new_bridge_count`, `max_edges_12`, `total_bridges`, `density_exceeds_twenty_pct`, ... +3 more

### Physics/ArithmeticPhotons

*19 files, 670 declarations, 6,176 lines*

#### `Advanced.lean` (283 lines)
*Source: `Physics/ArithmeticPhotons/Advanced.lean`*

- **def**: `minkowskiInner`, `toVec`, `IsNull`, `quatNormSq`, `quatMul`, `photonEnergy`, ... +4 more
- **noncomp. def**: `r₃`, `hopfMap`
- **theorem**: `lorentzQ_eq_minkowski_self`, `minkowskiInner_comm`, `minkowskiInner_add_left`, `minkowskiInner_smul_left`, `zero_is_null`, `null_smul`, ... +15 more

#### `Basic.lean` (284 lines)
*Source: `Physics/ArithmeticPhotons/Basic.lean`*

- **inductive**: `CausalClass`
- **def**: `lorentzQ`, `IsPythQuad`, `classify`, `quadParam`, `minkowskiMetric`, `IsLorentzMatrix`, `IsSumThreeSquares`, `PhotonConnected`
- **noncomp. def**: `invStereo2`
- **theorem**: `pythQuad_iff_null`, `null_classifies_null`, `quadParam_valid`, `quad_1_2_2_3`, `quad_2_3_6_7`, `quad_1_4_8_9`, ... +28 more

#### `HopfBridge.lean` (136 lines)
*Source: `Physics/ArithmeticPhotons/HopfBridge.lean`*

- **structure**: `IntQuaternion`
- **def**: `sqNorm`, `mul`, `conj`, `zero`, `hopfMap`, `sameDirection`, `IsPrimitive`, `pureQuatNorm`
- **theorem**: `sqNorm_mul`, `sqNorm_conj`, `sqNorm_nonneg`, `sqNorm_eq_zero`, `hopfMap_is_null`, `hopfMap_d_eq_sqNorm`, ... +6 more

#### `Langlands.lean` (188 lines)
*Source: `Physics/ArithmeticPhotons/Langlands.lean`*

- **structure**: `ThetaCubeData`, `ShimuraLiftData`, `ArithmeticPhotonLanglandsBridge`, `HeckeEigenvalueData`
- **inductive**: `PhotonLanglandsCorrespondence`
- **def**: `sumThreeSquaresReps`, `photonCount`, `thetaPartial`, `shimuraLift_3_2`, `chi_neg4`, `mkLanglandsBridge`, `fermatTwoSquares`
- **theorem**: `chi_neg4_at_1`, `chi_neg4_at_3`, `chi_neg4_at_5`, `chi_neg4_at_2`, `sq_not_7_mod_8`, `lorentz_form_represents_zero`, `lorentz_form_many_zeros`, `six_axis_representations`

#### `OpenQuestions.lean` (268 lines) ⚠️ 2 sorry
*Source: `Physics/ArithmeticPhotons/OpenQuestions.lean`*

- **def**: `photonBasis`, `lorentzForm1`, `lorentzForm2`, `lorentzForm3`
- **theorem**: `photon_parity_constraint`, `unit_x_is_photonic`, `unit_y_is_photonic`, `unit_z_is_photonic`, `photon_sublattice_even`, `quadruple_generators_check`, ... +23 more

#### `QuantumInformation.lean` (425 lines)
*Source: `Physics/ArithmeticPhotons/QuantumInformation.lean`*

- **structure**: `RatSpherePoint`
- **def**: `quadToBloch`, `ratInvStereo`, `pauliI`, `pauliX`, `pauliZ`, `blochUp`, ... +13 more
- **theorem**: `stereo_to_quad`, `pauliX_sq`, `pauliZ_sq`, `pauliXZ_anticommute`, `hadamard_involution`, `sGate_order_four`, ... +11 more

#### `PhotonChannels.lean` (368 lines)
*Source: `Physics/Photon/PhotonChannels.lean`*

- **inductive**: `PhotonChannel`, `HilbertDimType`, `ConjugatePair`, `SymmetryOrigin`
- **def**: `hilbertDimType`, `ConjugatePair`, `ConjugatePair`, `hasClassicalAnalogue`, `isBounded`, `symmetryOrigin`, `practicalDim`, `hyperEntanglementDim`
- **noncomp. def**: `channelInfoCapacity`, `totalInfoCapacity`, `uncertaintyBound`, `zeroPointEnergy`, `shannonCapacity`
- **theorem**: `PhotonChannel`, `polarization_unique_finite`, `ConjugatePair`, `totalInfoCapacity_eq`, `photonNumber_unique_nonclassical`, `polarization_unique_bounded`, ... +9 more

#### `PhotonEpistemicBridge.lean` (584 lines) ⚠️ 1 sorry
*Source: `Physics/Photon/PhotonEpistemicBridge.lean`*

- **structure**: `ProbDist`, `MutualInfo`, `SpacetimeEvent`, `KnowledgeRelation`, `LKT_Framework`
- **def**: `binaryEntropy`, `vonNeumannEntropy2`, `MutualInfo`, `malusLaw`, `chsh_classical`, `quantum_correlation`, ... +3 more
- **theorem**: `binaryEntropy_nonneg`, `binaryEntropy_le_log2`, `binaryEntropy_max_at_half`, `holevo_single_qubit_bound`, `mutual_info_nonneg`, `mutual_info_le_source`, ... +22 more

#### `PhotonEventGraph.lean` (237 lines)
*Source: `Physics/Photon/PhotonEventGraph.lean`*

- **structure**: `SpacetimeEvent`, `PhotonEdge`, `PhotonEventGraph`, `EntangledPair`
- **inductive**: `PhotonEventGraph`
- **def**: `minkowskiInterval`, `nullSeparated`, `causalFuture`, `PhotonEdge`, `PhotonEdge`, `PhotonEventGraph`, ... +3 more
- **noncomp. def**: `PhotonEventGraph`, `PhotonEventGraph`
- **theorem**: `null_iff_pythagorean`, `PhotonEdge`, `PhotonEdge`, `PhotonEventGraph`, `PhotonEventGraph`, `PhotonEventGraph`, `PhotonEventGraph`, `EntangledPair`

#### `PhotonIsUniverse.lean` (329 lines)
*Source: `Physics/Photon/PhotonIsUniverse.lean`*

- **structure**: `GaussInt`
- **inductive**: `MetaOracle`
- **def**: `invStereo₁`, `stereoFwd₁`, `invStereo_conformal_factor`, `minkInner`, `isNull`, `isFuture`, ... +9 more
- **theorem**: `invStereo_on_sphere`, `invStereo_injective`, `stereo_invStereo_roundtrip`, `invStereo_avoids_south_pole`, `invStereo_surjective`, `invStereo_conformal_factor_pos`, ... +20 more
- **lemma**: `null_rearranged`

#### `PhotonNetworks.lean` (260 lines)
*Source: `Physics/Photon/PhotonNetworks.lean`*

- **def**: `IsSumOfTwoSquares`, `IsDark`, `IsPythTriple`, `gaussianProd`, `PhotonStates`, `gridAdj`
- **theorem**: `brahmagupta_fibonacci`, `sum_two_sq_mul_closed`, `every_nat_sum_two_sq`, `three_is_dark`, `seven_is_dark`, `five_is_bright`, ... +16 more

#### `PhotonParity.lean` (66 lines)
*Source: `Physics/Photon/PhotonParity.lean`*

- **theorem**: `pyth_not_both_odd`, `pyth_hypotenuse_odd`, `pyth_one_leg_even`, `pyth_parametrization`

#### `PhotonResearchRound2.lean` (443 lines)
*Source: `Physics/Photon/PhotonResearchRound2.lean`*

- **def**: `minkQ`, `IsPythTriple`, `IsNull`, `minkInner`, `gaussProd`
- **theorem**: `gaussian_product_triple`, `null_gaussian_product`, `conjugate_photon`, `conjugate_photon`, `antipodal_photon`, `gaussProd_comm`, ... +19 more

#### `PhotonResearchRound3.lean` (539 lines)
*Source: `Physics/Photon/PhotonResearchRound3.lean`*

- **structure**: `PhotonState`
- **def**: `IsPythTriple`, `gaussianProd`, `vacuum_photon`, `photon_345`, `photon_51213`, `PhotonState`, `PhotonState`
- **theorem**: `two_square_identity`, `four_square_identity`, `eight_square_identity`, `sedenion_zero_divisor_witness`, `photon_monoid_closure`, `gaussianProd_comm`, ... +34 more

#### `PhotonResearchRound4.lean` (353 lines)
*Source: `Physics/Photon/PhotonResearchRound4.lean`*

- **structure**: `PhotonState`
- **def**: `IsPythTriple`, `berggrenA`, `berggrenB`, `berggrenC`, `gaussianProd`, `isBrightPrime`, ... +10 more
- **theorem**: `berggrenA_preserves_pyth`, `berggrenB_preserves_pyth`, `berggrenC_preserves_pyth`, `base_triple_pyth`, `berggrenA_base`, `berggrenB_base`, ... +39 more

#### `PhotonResearchRound5.lean` (293 lines)
*Source: `Physics/Photon/PhotonResearchRound5.lean`*

- **structure**: `Oct`
- **def**: `Oct`, `Oct`, `Oct`, `Oct`, `Oct`, `Oct`, ... +9 more
- **theorem**: `Oct`, `oct_not_commutative`, `oct_not_associative`, `oct_norm_multiplicative`, `oct_e1_norm`, `oct_e2_norm`, ... +30 more

#### `PhotonUniverseEncoding.lean` (437 lines)
*Source: `Physics/Photon/PhotonUniverseEncoding.lean`*

- **structure**: `Twistor`
- **def**: `minkowskiInner`, `IsNull`, `NullCone`, `IsFutureDirected`, `FutureNullCone`, `inverseStereoNull`, ... +10 more
- **theorem**: `inverseStereoNull_is_null`, `inverseStereoNull_future`, `inverseStereoNull_in_future_cone`, `inverseStereo_on_sphere`, `celestialDirection_on_sphere`, `celestialDirection_is_normalized_null`, ... +9 more
- **lemma**: `future_null_k0_plus_k3_nonneg`, `null_condition_rearranged`, `future_null_south_pole`, `inverseStereoNull_surj_standard`

#### `PhotonicFrontier.lean` (428 lines) ⚠️ 1 sorry
*Source: `Physics/Photon/PhotonicFrontier.lean`*

- **def**: `Q`, `eta`, `IsNull`, `IsTimelike`, `IsSpacelike`, `spatialRotation`, ... +4 more
- **theorem**: `hyperboloid_origin`, `boost_preserves_Q`, `boost_preserves_hyperboloid_Q`, `boosted_origin_on_hyperboloid`, `hyperboloid_inside_light_cone`, `hyperbolic_distance_base`, ... +47 more

#### `PhotonicInverseStereo.lean` (255 lines)
*Source: `Physics/Photon/PhotonicInverseStereo.lean`*

- **structure**: `PISPDPhoton`
- **def**: `invStereo2D`, `fwdStereo2D`, `conformalFactor`, `chordalDistSq`, `photonConformalEnergy`
- **theorem**: `invStereo_on_sphere`, `stereo_roundtrip`, `conformal_factor_positive`, `conformal_factor_at_origin`, `conformal_factor_at_unit_circle`, `conformal_factor_le_four`, ... +5 more

### Physics/Classical

*20 files, 683 declarations, 6,132 lines*

#### `CMBLandscape.lean` (196 lines)
*Source: `Physics/Classical/CMBLandscape.lean`*

- **noncomp. def**: `pythagorean_energy_density`, `inverse_stereo`, `inverse_stereo_1d`, `pythagorean_rational_point`, `energy_euclid`, `energy_ratio`, `silver_ratio`, `optimal_ratio`
- **theorem**: `pythagorean_energy_density_bound`, `energy_density_345`, `pythagorean_696_697_985`, `most_energy_rich_comparison`, `inverse_stereo_on_sphere`, `inverse_stereo_origin`, ... +4 more

#### `DriftFreeIMU.lean` (41 lines)
*Source: `Physics/Classical/DriftFreeIMU.lean`*

- **theorem**: `group_reversal_identity`, `trace_identity_eq`, `imu_checksum`

#### `GEMEquations.lean` (186 lines)
*Source: `Physics/Classical/GEMEquations.lean`*

- **theorem**: `gravity_em_ratio_bound`, `casimir_energy_monotone`, `casimir_energy_negative`, `warp_shaping_bounded`, `warp_energy_scaling`, `gravitomagnetic_field_scaling`, ... +5 more

#### `GenesisOracle.lean` (207 lines)
*Source: `Physics/Classical/GenesisOracle.lean`*

- **structure**: `GenesisOracle`, `OracleTeam`
- **def**: `GenesisOracle`, `GenesisOracle`, `GenesisOracle`, `GenesisOracle`, `GenesisOracle`, `OracleTeam`, `genesisProjection`, `discreteTime`
- **theorem**: `GenesisOracle`, `GenesisOracle`, `GenesisOracle`, `GenesisOracle`, `GenesisOracle`, `GenesisOracle`, ... +10 more

#### `GeometricRepulsor.lean` (238 lines)
*Source: `Physics/Classical/GeometricRepulsor.lean`*

- **def**: `fermatSearchSieved`, `fermatFactorSieved`
- **theorem**: `fermat_diff_sq`, `fermat_factor_correct`, `odd_fermat_rep`, `fermat_nontrivial`, `sq_mod_eq`, `quad_residues_mod_64`, ... +7 more

#### `GravitomagneticFrontiers.lean` (290 lines)
*Source: `Physics/Classical/GravitomagneticFrontiers.lean`*

- **structure**: `GEMField`, `PythTriple`, `SpectralGap`
- **def**: `GEMField`, `GEMField`, `PythTriple`, `PythTriple`, `resonantField`, `lorentzianResponse`, ... +8 more
- **theorem**: `pythagorean_gem_unit`, `pythagorean_q_factor_pos`, `resonance_amplification`, `resonance_preserves_sign`, `lorentzian_positive`, `lorentzian_at_resonance`, ... +18 more

#### `GravitomagneticStereo.lean` (310 lines)
*Source: `Physics/Classical/GravitomagneticStereo.lean`*

- **structure**: `GEMField`, `GEMPythTriple`, `GEMOracle`
- **def**: `GEMField`, `GEMField`, `gravitomagneticForce`, `lenseThirringRate`, `stereoConfFactor`, `kelvinInv`, ... +10 more
- **theorem**: `gem_duality_preserves_norm`, `gem_dual_dual`, `gravitomagnetic_force_antisymmetric`, `gravitomagnetic_force_stationary`, `lense_thirring_positive`, `lense_thirring_monotone`, ... +20 more

#### `GravityAI.lean` (573 lines)
*Source: `Physics/Classical/GravityAI.lean`*

- **structure**: `Oracle`, `MinkowskiEvent`, `BlackHole`, `TwoLayerNet`, `WeightedGraph`
- **def**: `Oracle`, `MinkowskiEvent`, `MinkowskiEvent`, `minkowskiInner`, `BlackHole`, `BlackHole`, ... +15 more
- **theorem**: `Oracle`, `Oracle`, `Oracle`, `Oracle`, `Oracle`, `identity_no_compression`, ... +57 more

#### `GravityAITeam.lean` (325 lines)
*Source: `Physics/Classical/GravityAITeam.lean`*

- **structure**: `of`, `GravParticle`
- **def**: `gravWeight`, `gravAttraction`, `gravPotential`, `isGravEquilibrium`, `GravParticle`, `totalMass`, ... +10 more
- **theorem**: `gravWeight_one`, `gravWeight_two`, `gravWeight_12_gt_7`, `gravWeight_6`, `gravWeight_prime`, `gravAttraction_symm`, ... +32 more

#### `HelicityBound.lean` (58 lines)
*Source: `Physics/Classical/HelicityBound.lean`*

- **theorem**: `two_abs_mul_le_sq_add_sq`, `helicity_bound`, `helicity_bound_tight`, `helicity_bound_nat`

#### `HomingMissile.lean` (463 lines)
*Source: `Physics/Classical/HomingMissile.lean`*

- **structure**: `RatCirclePoint`, `EuclidParams`
- **inductive**: `BerggrenOrigin`
- **def**: `angularCross`, `angularDot`, `angularDistSq`, `euclidToTriple`, `berggren_M2`, `berggren_M3`, ... +6 more
- **theorem**: `angularCross_antisymm`, `angularDot_symm`, `angular_pythagorean`, `angularDistSq_zero_iff`, `angularDistSq_symm`, `euclid_is_pythagorean`, ... +16 more

#### `LightCone.lean` (104 lines)
*Source: `Physics/Classical/LightCone.lean`*

- **structure**: `PhotonState`
- **def**: `PhotonState`, `PhotonState`
- **theorem**: `PhotonState`, `PhotonState`, `PhotonState`, `light_cone_triangulation`

#### `LightConeTheory.lean` (367 lines)
*Source: `Physics/Classical/LightConeTheory.lean`*

- **def**: `minkowskiForm`, `isLightLike`, `isTimeLike`, `isSpaceLike`, `minkowskiInner`, `lorentzBoostX`, `celestialStereo`, `invCelestialStereo`
- **theorem**: `light_like_iff_pythagorean`, `light_cone_is_cone`, `light_like_self_orthogonal`, `pyth_triple_is_light_like`, `origin_is_light_like`, `triple_345_light_like`, ... +35 more

#### `MassEnergyDuality.lean` (186 lines)
*Source: `Physics/Classical/MassEnergyDuality.lean`*

- **structure**: `PhysicalState`
- **def**: `stereoNorth`, `stereoSouth`, `invStereoNorth`, `invStereoSouth`, `massEnergyTransition`, `PhysicalState`, `PhysicalState`
- **theorem**: `invStereoNorth_on_circle`, `invStereoSouth_on_circle`, `transition_map_is_inversion`, `mass_energy_bijection`, `mass_energy_involutive`, `mass_times_energy_eq_one`, ... +4 more

#### `NullConeArithmetic.lean` (114 lines)
*Source: `Physics/Classical/NullConeArithmetic.lean`*

- **structure**: `ArithTwistor`
- **def**: `quatNorm`, `ArithTwistor`
- **noncomp. def**: `hopfMap`
- **theorem**: `euler_four_square`, `quatNorm_nonneg`, `descent_on_circle`, `two_squares_identity`, `four_squares_identity`, `twistor_on_null_cone`, `hopf_norm_sq`, `hopf_sphere_to_sphere`

#### `PhysicalPhenomena.lean` (182 lines)
*Source: `Physics/Classical/PhysicalPhenomena.lean`*

- **structure**: `QuantumState`
- **def**: `holographicBound`, `sphereSurfaceArea`, `sphereVolume`, `bornProb`, `schwarzschildRadius`, `blackHoleEntropy`, ... +3 more
- **theorem**: `holographic_subvolumetric`, `born_prob_sum_one`, `born_prob_nonneg`, `measurement_is_oracle_query`, `bh_entropy_quadratic`, `lloyd_nonneg`, `universal_bound_nonneg`

#### `RepulsorTheory.lean` (590 lines)
*Source: `Physics/Classical/RepulsorTheory.lean`*

- **def**: `diagonal_evader`, `iterated_evader`, `evading_set`, `remaining_positions`, `evades_at_level`
- **theorem**: `diagonal_evasion`, `diagonal_evader_evades`, `iterated_evaders_all_distinct`, `cantor_evasion`, `evading_set_evades`, `remaining_positions_card`, ... +23 more

#### `RepulsorTheoryExtended.lean` (473 lines)
*Source: `Physics/Classical/RepulsorTheoryExtended.lean`*

- **def**: `IsRepulsor`, `diagEvader`, `diagTower`, `IsFixedPointFree`, `IsOracle`, `IsRepulsorPt`, ... +10 more
- **theorem**: `repulsor_exists_diagonal`, `repulsor_family`, `repulsor_family_injective`, `repulsor_abundance`, `diagTower_gt_base`, `diagTower_strict_mono`, ... +49 more

#### `TimelineGravity.lean` (565 lines)
*Source: `Physics/Classical/TimelineGravity.lean`*

- **structure**: `SumOfSquaresWitness`, `ResearchOracle`
- **def**: `isLightPrime`, `isDarkPrime`, `isTwilightPrime`, `lightPrimeCount`, `darkPrimeCount`, `photon_5`, ... +12 more
- **theorem**: `five_is_light`, `thirteen_is_light`, `three_is_dark`, `seven_is_dark`, `eleven_is_dark`, `two_is_twilight`, ... +44 more

#### `TimelineGravityCycles.lean` (664 lines)
*Source: `Physics/Classical/TimelineGravityCycles.lean`*

- **structure**: `GaussianSplit`, `SelfComputingUniverse`
- **def**: `isLightPrime`, `isDarkPrime`, `lightPrimeCount`, `darkPrimeCount`, `gaussianNormSq`, `split_5`, ... +10 more
- **theorem**: `prime_div_sq_add_one_mod_four`, `infinitely_many_dark_primes`, `infinitely_many_light_primes`, `light_dark_count_100`, `light_dark_count_200`, `light_prime_is_sum_of_squares`, ... +36 more

### Physics/Quantum

*33 files, 1067 declarations, 8,526 lines*

#### `QuantumBerggren.lean` (309 lines)
*Source: `Physics/Quantum/Berggren/QuantumBerggren.lean`*

- **def**: `BG₁`, `BG₂`, `BG₃`, `BG₁_inv`, `BG₂_inv`, `BG₃_inv`, ... +7 more
- **theorem**: `BG₁_mul_inv`, `BG₂_mul_inv`, `BG₃_mul_inv`, `BG₁_inv_mul`, `BG₂_inv_mul`, `BG₃_inv_mul`, ... +41 more

#### `QuantumBerggrenGates.lean` (345 lines) ⚠️ 1 sorry
*Source: `Physics/Quantum/Berggren/QuantumBerggrenGates.lean`*

- **structure**: `BerggrenGate`
- **def**: `pythRotation`, `BerggrenGate`, `rootGate`, `gate_5_12_13`, `gate_8_15_17`, `gate_7_24_25`, ... +15 more
- **theorem**: `det_pythRotation`, `det_pythRotation_pyth`, `pythRotation_transpose`, `pythRotation_mul`, `brahmagupta_fibonacci`, `pythRotation_product_pyth`, ... +22 more

#### `QuantumBerggrenResearch.lean` (377 lines)
*Source: `Physics/Quantum/Berggren/QuantumBerggrenResearch.lean`*

- **structure**: `BerggrenGate`, `PythQuadruple`
- **def**: `pythRot`, `BerggrenGate`, `rootGate`, `gate_5_12_13`, `gate_21_20_29`, `gate_15_8_17`, ... +21 more
- **theorem**: `det_pythRot`, `pythRot_mul`, `pythRot_one`, `brahmagupta_fibonacci`, `pythRot_conformal`, `pythRot_transpose`, ... +47 more

#### `QuantumFoundations.lean` (86 lines)
*Source: `Physics/Quantum/Core/QuantumFoundations.lean`*

- **theorem**: `norm_triangle_pf`, `inner_mul_le_norm_pf`, `unitary_mul_unitary`, `unitary_inv_eq_star`, `tensor_normalized`, `pauli_x_squared`

#### `QuantumStructures.lean` (149 lines)
*Source: `Physics/Quantum/Core/QuantumStructures.lean`*

- **def**: `pauliX`, `pauliZ`, `gaussianBinomial`
- **theorem**: `qubit_hilbert_dim`, `pauliX_sq`, `pauliZ_sq`, `pauliXZ_anticommute`, `pauliX_trace`, `pauliZ_trace`, ... +6 more

#### `QuantumTypeTheory.lean` (196 lines)
*Source: `Physics/Quantum/Core/QuantumTypeTheory.lean`*

- **structure**: `DensityMatrix`, `QuantumChannel`
- **def**: `QState`, `IsUnitaryGate`, `BipartiteState`, `isSeparable`, `isEntangled`, `isCloningMap`, `isLinearClone`
- **theorem**: `identity_gate_unitary`, `unitary_mul_unitary`, `unitary_conjTranspose`, `tensorProduct_separable`, `bell_state_entangled`, `no_cloning_simplified`, `id_channel_trace_preserving`, `compose_trace_preserving`

#### `QuantumCircuits.lean` (317 lines)
*Source: `Physics/Quantum/Gates/QuantumCircuits.lean`*

- **structure**: `QuantumCircuit`
- **def**: `pauli_X`, `pauli_Z`, `pauli_XZ`, `hadamard_scaled`, `CNOT`, `Toffoli`, ... +6 more
- **theorem**: `pauli_X_squared`, `pauli_Z_squared`, `pauli_XZ_squared`, `pauli_anticommute`, `pauli_X_mul_Z`, `det_pauli_X`, ... +26 more

#### `QuantumGateAlgebra.lean` (372 lines)
*Source: `Physics/Quantum/Gates/QuantumGateAlgebra.lean`*

- **structure**: `QuantumWalk`, `SignedPauli`, `HamiltonianTerm`, `QHamiltonian`, `CSSCode`
- **inductive**: `PauliType`
- **def**: `I₂`, `σX`, `σZ`, `σXZ`, `kron2`, `X_tensor_I`, ... +25 more
- **theorem**: `sigma_X_mul_Z`, `sigma_Z_mul_X`, `pauli_commutator_XZ`, `pauli_anticommutator_XZ`, `sigma_XZ_sq`, `sigma_XZ_fourth`, ... +41 more

#### `QuantumGateSynthesis.lean` (365 lines)
*Source: `Physics/Quantum/Gates/QuantumGateSynthesis.lean`*

- **structure**: `FactoringResult`
- **inductive**: `ThetaGate`, `BerggrenStep`
- **def**: `ThetaCircuit`, `ThetaGate`, `eval_circuit`, `S_matrix`, `T_sq_matrix`, `apply_circuit`, ... +8 more
- **theorem**: `det_gate`, `eval_circuit_determinant`, `M₁_mul_M₁_inv`, `M₁_inv_mul_M₁`, `M₃_mul_M₃_inv`, `M₃_inv_mul_M₃`, ... +14 more

#### `QuantumGates.lean` (114 lines)
*Source: `Physics/Quantum/Gates/QuantumGates.lean`*

- **def**: `phase_gate`, `gaussian_units`
- **theorem**: `phase_gate_involutive`, `gaussian_unit_norm`, `quaternion_norm_sq_mul`, `cayley_dickson_dimensions`

#### `MoonshotQuantum.lean` (785 lines)
*Source: `Physics/Quantum/Moonshots/MoonshotQuantum.lean`*

- **def**: `time_reverse_matrix`, `pauli_I`, `sd_X`, `sd_Z`, `sd_XZ`, `symplectic_inner`, ... +3 more
- **theorem**: `no_cloning_core_real`, `no_cloning_core_complex`, `no_cloning_core_int`, `idempotent_function_binary`, `time_reverse_mul`, `time_reverse_det_one`, ... +47 more

#### `QuantumAIMadScience.lean` (506 lines)
*Source: `Physics/Quantum/Moonshots/QuantumAIMadScience.lean`*

- **theorem**: `no_cloning_1d`, `cloning_gap_explicit`, `cloning_cross_terms`, `no_cloning_complex`, `no_cloning_matrix`, `classical_search_lower_bound`, ... +27 more

#### `QuantumMoonshots.lean` (152 lines)
*Source: `Physics/Quantum/Moonshots/QuantumMoonshots.lean`*

- **structure**: `MoonshotAssessment`
- **inductive**: `TRL`
- **def**: `teleportation_network_ebits`, `star_network_ebits`, `black_hole_qubits`, `chemistry_qubits`, `co2_qubits_accurate`, `protein_interactions`, ... +9 more
- **theorem**: `star_more_efficient`, `baby_black_hole_feasible`, `stellar_black_hole_impossible`, `CHSH_classical_bound`, `quantum_exceeds_classical`, `quantum_money_security`, ... +11 more

#### `MirrorQuantum.lean` (508 lines)
*Source: `Physics/Quantum/Neural/MirrorQuantum.lean`*

- **structure**: `Mirror`, `MirrorChain`, `BeamSplitter`, `ErrorCorrectionCode`, `CompressionOracle`, `ShorMirrorChain`
- **def**: `MirrorChain`, `MirrorChain`, `MirrorChain`, `BeamSplitter`, `omegaN`, `primalityMirror`, ... +8 more
- **theorem**: `MirrorChain`, `MirrorChain`, `grover_quadratic_advantage`, `sqrt_sublinear`, `grover_gap_grows`, `grover_perfect_square_speedup`, ... +45 more

#### `OctonionComputation.lean` (65 lines)
*Source: `Physics/Quantum/Neural/OctonionComputation.lean`*

- **def**: `octonionAssociator`, `octonionCatalan`, `IsMoufangLoop`
- **theorem**: `octonionAssociator_zero_iff`, `octonionAssociator_alt_left`, `octonionAssociator_alt_right`, `octonionCatalan_zero`, `octonionCatalan_one`, `octonionCatalan_two`, ... +8 more

#### `QuantumBackpropagation.lean` (67 lines)
*Source: `Physics/Quantum/Neural/QuantumBackpropagation.lean`*

- **def**: `qbSinCost`
- **theorem**: `qb_parameter_shift_rule`, `qb_sinCost_deriv`, `qb_gradient_eval_count`, `qb_gradient_cost`, `qb_cramer_rao_bound`, `qb_heisenberg_vs_shot_noise`, ... +5 more

#### `QuantumErrorCorrection.lean` (93 lines)
*Source: `Physics/Quantum/Neural/QuantumErrorCorrection.lean`*

- **def**: `IsPythTriple`, `qecLorentzForm`
- **theorem**: `pauli_group_order_one`, `pauli_group_order`, `stabilizer_code_constraint`, `code_rate_bound`, `quantum_singleton_bound`, `base_triple`, ... +10 more

#### `QuantumMirrorComposability.lean` (417 lines)
*Source: `Physics/Quantum/Neural/QuantumMirrorComposability.lean`*

- **structure**: `IdemMirror`, `InvolMirror`, `MirrorChainComp`, `MatMirror`
- **def**: `idIdemMirror`, `idInvolMirror`, `mirrorFixed`, `constIdemMirror`, `MirrorChainComp`, `MirrorChainComp`, ... +5 more
- **theorem**: `InvolMirror`, `InvolMirror`, `InvolMirror`, `id_unique_both`, `idem_range_eq_fixed`, `constMirror_range`, ... +18 more

#### `QuantumMirrorComputation.lean` (188 lines)
*Source: `Physics/Quantum/Neural/QuantumMirrorComputation.lean`*

- **structure**: `QuantumMirror`, `QuantumMirrorChain`
- **def**: `identityMirror`, `zeroMirror`, `complementMirror_qm`, `QuantumMirrorChain`, `QuantumMirrorChain`
- **theorem**: `mirror_complement_idem_qm`, `mirror_complement_selfAdj_qm`, `mirror_complement_orthogonal_qm`, `mirror_partition_qm`, `empty_chain_is_identity_qm`, `commuting_mirrors_compose_qm`, ... +6 more

#### `QuantumNeuralArchitecture.lean` (120 lines)
*Source: `Physics/Quantum/Neural/QuantumNeuralArchitecture.lean`*

- **theorem**: `mera_depth_logarithmic`, `mera_sites_halve`, `mera_gate_count`, `transformer_params`, `attention_temperature_pos`, `softmax_sums_to_one`, ... +9 more

#### `QuantumNeuralBridge.lean` (354 lines)
*Source: `Physics/Quantum/Neural/QuantumNeuralBridge.lean`*

- **def**: `relu`, `logisticSigmoid`
- **theorem**: `relu_idempotent`, `relu_nonneg`, `relu_of_nonneg`, `relu_of_neg`, `relu_fixed_points`, `projection_eigenvalues`, ... +18 more

#### `QuantumTropicalFunctor.lean` (97 lines)
*Source: `Physics/Quantum/Neural/QuantumTropicalFunctor.lean`*

- **def**: `qtMaslovAdd`, `qtSoftmaxKernel`
- **theorem**: `qt_logsumexp_ge_max`, `qt_logsumexp_le_max_log2`, `qt_exp_sum_pos`, `qtMaslovAdd_comm`, `qt_tropical_idempotent`, `qt_tropical_mul_identity`, ... +6 more

#### `SolovayKitaev.lean` (68 lines)
*Source: `Physics/Quantum/Neural/SolovayKitaev.lean`*

- **def**: `skCommutator`, `skCayleyBall`
- **theorem**: `sk_recursion_convergence`, `sk_precision_pos`, `sk_gate_count_bound`, `sk_exponent_bound`, `sk_improved_bound`, `skCommutator_one_left`, ... +7 more

#### `QuantumCompression.lean` (242 lines)
*Source: `Physics/Quantum/Simulation/QuantumCompression.lean`*

- **structure**: `Codebook`
- **def**: `trivial_codebook`, `Codebook`, `circuit_length`, `is_circuit_optimization`
- **noncomp. def**: `description_length`
- **theorem**: `no_injection_to_smaller`, `no_universal_compressor`, `compression_must_expand_something`, `short_strings_count`, `incompressible_strings_lower_bound`, `incompressible_fraction`, ... +9 more

#### `QuantumLLMCompilation.lean` (135 lines)
*Source: `Physics/Quantum/Simulation/QuantumLLMCompilation.lean`*

- **theorem**: `linear_composition_is_linear`, `linear_composition_chain`, `region_count_exponential_bound`, `linearization_dimension_lower_bound`, `qubit_dimension`, `exponential_compression`, ... +9 more

#### `QuantumMathSimulation.lean` (332 lines)
*Source: `Physics/Quantum/Simulation/QuantumMathSimulation.lean`*

- **def**: `IsQuantumState`, `IsUnitaryGate`, `QSeparable`, `QEntangled`, `pauliX`, `pauliZ`
- **noncomp. def**: `bellState`, `applyGate`, `applyCircuit`, `circuitUnitary`, `hadamardGate`
- **theorem**: `identity_is_unitary`, `unitary_comp`, `unitary_adjoint`, `born_rule_valid`, `born_probability_nonneg`, `born_probability_le_one`, ... +13 more

#### `QuantumMetaPhysics.lean` (287 lines)
*Source: `Physics/Quantum/Simulation/QuantumMetaPhysics.lean`*

- **structure**: `CompLevel`
- **def**: `CompLevel`
- **noncomp. def**: `maxOperations`, `CompLevel`, `holographicBound`, `fubiniStudyDist`
- **theorem**: `energy_time_positive`, `energy_time_scaling`, `energy_time_additive`, `maxOperations_pos`, `maxOperations_double_energy`, `maxOperations_mono_energy`, ... +11 more

#### `QuantumOracleChain.lean` (375 lines)
*Source: `Physics/Quantum/Simulation/QuantumOracleChain.lean`*

- **structure**: `OracleChain`, `QState`, `QGate`, `StabilizerCode`, `QAlgorithm`, `ShorChain`
- **inductive**: `QInstruction`
- **def**: `OracleChain`, `OracleChain`, `OracleChain`, `OracleChain`, `measureProb`, `QGate`, ... +12 more
- **theorem**: `OracleChain`, `OracleChain`, `OracleChain`, `OracleChain`, `measureProb_nonneg`, `measureProb_sum`, ... +23 more

#### `QuantumProofMetric.lean` (220 lines)
*Source: `Physics/Quantum/Simulation/QuantumProofMetric.lean`*

- **structure**: `ProofRefactoring`
- **def**: `ProofVector`, `isNormalized`, `areOrthogonal`
- **noncomp. def**: `proofInnerProduct`, `proofNormSq`, `proofFidelity`, `fubiniStudyDist`, `proofSuperposition`
- **theorem**: `fidelity_nonneg`, `self_fidelity_normalized`, `fubiniStudy_self`, `fubiniStudy_symm`, `fubiniStudy_nonneg`, `orthogonal_zero_fidelity`, ... +4 more

#### `QuantumProofSearch.lean` (180 lines)
*Source: `Physics/Quantum/Simulation/QuantumProofSearch.lean`*

- **structure**: `ClassicalSearch`, `QuantumOracle`
- **def**: `isCloningMap`, `isUnitary`, `hasAlgebraicStructure`
- **noncomp. def**: `groverComplexity`
- **theorem**: `classical_lower_bound`, `grover_quadratic_speedup`, `grover_sqrt_bound`, `no_cloning`, `structured_quantum_advantage`, `quantum_lower_bound`, `classical_quantum_gap`, `more_solutions_easier`

#### `QuantumSimulation.lean` (107 lines)
*Source: `Physics/Quantum/Simulation/QuantumSimulation.lean`*

- **structure**: `VariationalAnsatz`
- **def**: `sl2_e`, `sl2_f`, `sl2_h`, `sl2_casimir_scaled`, `is_symmetry`, `jw_two_body_gates`, `bk_two_body_gates`, `cluster_state_gates`
- **theorem**: `sl2_commutator_ef`, `sl2_commutator_he`, `sl2_commutator_hf`, `sl2_casimir_value`, `casimir_commutes`, `identity_is_symmetry`, ... +12 more

#### `QuantumTropicalComputing.lean` (353 lines)
*Source: `Physics/Quantum/Simulation/QuantumTropicalComputing.lean`*

- **def**: `tropAdd`, `tropMul`, `tropPow`, `tropHadamard`, `tropCNOT`, `tropPhase`, ... +9 more
- **theorem**: `tropAdd_comm`, `tropAdd_assoc`, `tropAdd_idem`, `tropMul_comm`, `tropMul_assoc`, `tropMul_zero_right`, ... +30 more

#### `QuantumUniverseSimulation.lean` (245 lines)
*Source: `Physics/Quantum/Simulation/QuantumUniverseSimulation.lean`*

- **structure**: `QubitState`
- **def**: `ket0`, `ket1`, `pauli_X`, `pauli_Z`, `pauli_Y`, `is_separable_2qubit`, `gate_complexity_lower_bound`
- **noncomp. def**: `maximally_mixed_qubit`, `binary_entropy`
- **theorem**: `qubit_dimension_doubling`, `universe_state_space_lower_bound`, `maximally_mixed_trace`, `no_cloning_inner_product_constraint`, `pauli_X_squared`, `pauli_Z_squared`, ... +20 more

### Physics/Spacetime

*3 files, 61 declarations, 341 lines*

#### `FluidGravity.lean` (108 lines)
*Source: `Physics/Spacetime/FluidGravity.lean`*

- **def**: `reynoldsNumber`, `pageEntropy`, `blackeningFactor`
- **theorem**: `kinetic_energy_nonneg`, `viscous_dissipation_negative`, `kolmogorov_decay`, `kss_bound_positive`, `diffusion_positive`, `dominant_energy`, ... +12 more

#### `LorentzCausalStructure.lean` (137 lines)
*Source: `Physics/Spacetime/LorentzCausalStructure.lean`*

- **def**: `minkowskiInner`, `isTimelike`, `isSpacelike`, `isNull`, `lorentzBoostX`
- **theorem**: `minkowski_symmetric`, `causal_trichotomy`, `temporal_is_timelike`, `lorentz_boost_preserves_inner`, `lorentz_preserves_timelike`, `lorentz_preserves_null`, ... +12 more

#### `QuantumGravityErrorCorrection.lean` (96 lines)
*Source: `Physics/Spacetime/QuantumGravityErrorCorrection.lean`*

- **structure**: `QECCode`, `PerfectTensor`
- **def**: `QECCode`, `correctableErrors`, `PerfectTensor`, `allowedWavenumber`
- **theorem**: `code_rate_bounded`, `more_distance_more_correction`, `perfect_tensor_entropy_pos`, `jlms_formula`, `er_epr_mutual_info`, `wormhole_growth`, ... +5 more

### Physics/TheoryOfEverything

*1 files, 52 declarations, 292 lines*

#### `MagicSquare.lean` (292 lines)
*Source: `Physics/TheoryOfEverything/MagicSquare.lean`*

- **def**: `divisionAlgebraDims`, `derDim`, `imDim`, `magicSquareDim`, `exceptionalDim`, `exceptionalRank`, ... +3 more
- **theorem**: `divisionAlgDim_isPowerOfTwo`, `divisionAlgDim_sum`, `cayleyDickson_doubling`, `magicSquare_symmetric`, `magicSquare_diagonal`, `magicSquare_monotone_row`, ... +37 more

### Probability

*7 files, 53 declarations, 636 lines*

#### `EigenvalueRepulsion.lean` (120 lines)
*Source: `Probability/Core/EigenvalueRepulsion.lean`*

- **theorem**: `vandermonde_det_eq_prod_diff`, `vandermonde_det_zero_iff`, `vandermonde_det_sq`, `vandermonde_det_sq_nonneg`, `vandermonde_det_pos_of_strictMono`, `log_abs_vandermonde_eq_sum`, ... +3 more

#### `ErgodicTheory.lean` (48 lines)
*Source: `Probability/Core/ErgodicTheory.lean`*

- **noncomp. def**: `timeAverage`
- **theorem**: `comp_measure_preserving`, `id_measure_preserving`, `timeAverage_const`, `timeAverage_add`, `orbit_finite`, `bijection_preserves_card`

#### `MeasureTheory.lean` (55 lines)
*Source: `Probability/Core/MeasureTheory.lean`*

- **theorem**: `lebesgue_interval_measure`, `measure_mono_example`, `measure_empty_eq_zero`, `prob_measure_total`, `prob_complement`, `qubit_normalization`, `cantor_dim_bounds`

#### `Probability.lean` (56 lines)
*Source: `Probability/Core/Probability.lean`*

- **noncomp. def**: `binaryEntropy`
- **theorem**: `markov_inequality_nat`, `log_monotone_on`, `binary_entropy_symmetric`

#### `ProbabilityExploration.lean` (63 lines)
*Source: `Probability/Core/ProbabilityExploration.lean`*

- **theorem**: `dice_complement_1`, `dice_complement_2`, `birthday_approx`, `fair_die_ev`, `linearity_expect`, `data_proc`, `harmonic_vals`

#### `StochasticProcesses.lean` (27 lines)
*Source: `Probability/Core/StochasticProcesses.lean`*

- **theorem**: `stoch_rows`, `uniform_stat`, `gamblers_ruin_prob`, `put_call`, `pollard_iof`

#### `EigenvalueRepulsion.lean` (267 lines)
*Source: `Probability/RandomMatrix/EigenvalueRepulsion.lean`*

- **inductive**: `DysonIndex`
- **def**: `repulsionFactor`, `coulombEnergy`, `confiningEnergy`, `totalEnergy`, `DysonIndex`
- **theorem**: `repulsion_at_coincidence`, `vandermonde_nonzero_iff_distinct`, `repulsion_eq_exp_neg_coulomb`, `repulsionFactor_nonneg`, `vandermonde_det_sq`, `two_point_repulsion`, `coulomb_energy_pair`, `DysonIndex`

### Pythagorean/Agents

*4 files, 100 declarations, 747 lines*

#### `AgentAlpha_Invariants.lean` (228 lines)
*Source: `Pythagorean/Agents/AgentAlpha_Invariants.lean`*

- **def**: `euclidTriple`
- **theorem**: `euclid_is_pythagorean`, `euclid_inradius_num`, `euclid_perimeter`, `euclid_twice_area`, `euclid_twice_area_factored`, `pyth_inradius_identity`, ... +23 more

#### `AgentBeta_TreeDynamics.lean` (217 lines)
*Source: `Pythagorean/Agents/AgentBeta_TreeDynamics.lean`*

- **inductive**: `TreePath`
- **def**: `berggrenTripleAux`, `pathsAtDepth`, `m2_branch`, `m2_perimeter`
- **theorem**: `berggren_M1_hyp_increase`, `berggren_M2_hyp_increase`, `berggren_M3_hyp_increase`, `berggren_M2_pos_a`, `berggren_M2_pos_b`, `berggren_M2_pos_c`, ... +12 more

#### `AgentEpsilon_Synthesis.lean` (207 lines)
*Source: `Pythagorean/Agents/AgentEpsilon_Synthesis.lean`*

- **theorem**: `gaussian_norm_multiplicative`, `brahmagupta_fibonacci`, `brahmagupta_fibonacci`, `rational_circle_point`, `stereographic_parametrization`, `stereographic_euclid`, ... +22 more

#### `AgentResearch.lean` (95 lines)
*Source: `Pythagorean/Agents/AgentResearch.lean`*

- **structure**: `ApproxOracleV2`
- **def**: `idempotentCount_v2`, `collatz_v2`, `goldbachCheck_v2`
- **theorem**: `expected_fixed_points_v2`, `idempotent_count_0_v2`, `idempotent_count_1_v2`, `idempotent_count_2_v2`, `idempotent_count_3_v2`, `oracle_density_3_v2`, ... +9 more

### Pythagorean/Applications

*4 files, 174 declarations, 1,510 lines*

#### `PythagoreanNeuralArch.lean` (356 lines)
*Source: `Pythagorean/Applications/PythagoreanNeuralArch.lean`*

- **theorem**: `pythagorean_unit_circle`, `pythagorean_unit_circle_real`, `pythagorean_weight_norm_sq`, `pythagorean_weight_component_bound`, `brahmagupta_fibonacci`, `gaussian_composition_preserves_pyth`, ... +20 more

#### `PythagoreanPhotonics.lean` (465 lines)
*Source: `Pythagorean/Applications/PythagoreanPhotonics.lean`*

- **def**: `IsLatticeNull`, `minkowski3`, `IsPythQuadruple`
- **theorem**: `lattice_null_minkowski_zero`, `lattice_null_neg`, `lattice_null_swap`, `lattice_null_scale`, `euclid_is_lattice_null`, `euclid_hypotenuse_pos`, ... +26 more

#### `QuantumGateOpenQuestions.lean` (395 lines)
*Source: `Pythagorean/Applications/QuantumGateOpenQuestions.lean`*

- **structure**: `TargetPoint`, `LatticeApprox`, `GateSynthesis`, `DescentStep`, `AncillaCircuit`, `RUSProtocol`, ... +4 more
- **def**: `iqNorm`, `iqMul`, `iqConj`, `iqOne`, `iqT`, `iqV`, ... +16 more
- **theorem**: `iqNorm_mul`, `iqNorm_conj`, `iqNorm_one`, `iqNorm_T`, `iqNorm_V`, `approx_error_density_bound`, ... +27 more

#### `QuantumGateOptimization.lean` (294 lines)
*Source: `Pythagorean/Applications/QuantumGateOptimization.lean`*

- **structure**: `IntSU2`, `GateSet`
- **def**: `isCliffordT_norm`, `isCliffordV_norm`, `isPrimeGateSet_norm`, `sigma_gate`, `gateCount`, `r4_count`, ... +11 more
- **theorem**: `cliffordT_is_prime2`, `cliffordV_is_prime5`, `sigma_gate_norm`, `gateCount_log`, `cliffordT_gateCount`, `r4_one`, ... +23 more

### Pythagorean/Core

*34 files, 1020 declarations, 8,971 lines*

#### `Berggren.lean` (148 lines)
*Source: `Pythagorean/Berggren/Berggren.lean`*

- **def**: `B₁`, `B₂`, `B₃`, `M₁`, `M₂`, `M₃`, ... +3 more
- **theorem**: `det_M₁`, `det_M₂`, `det_M₃`, `B₁_preserves_lorentz`, `B₂_preserves_lorentz`, `B₃_preserves_lorentz`, ... +9 more

#### `BerggrenDescent.lean` (392 lines)
*Source: `Pythagorean/Berggren/BerggrenDescent.lean`*

- **def**: `IsPythTriple`, `invBerggren1`, `invBerggren2`, `invBerggren3`, `fwdBerggren1`, `fwdBerggren2`, ... +4 more
- **theorem**: `root_is_pyth`, `triple_5_12_13`, `triple_8_15_17`, `euclid_parametrization`, `invBerggren1_preserves`, `invBerggren2_preserves`, ... +41 more

#### `BerggrenGPS.lean` (177 lines)
*Source: `Pythagorean/Berggren/BerggrenGPS.lean`*

- **def**: `zoneA_inv`, `zoneB_inv`, `zoneC_inv`, `M_A`, `M_B`, `M_C`
- **noncomp. def**: `berggrenGauss`
- **theorem**: `zoneA_valid`, `zoneB_valid`, `zoneC_valid`, `zoneA_hyp_decreases`, `zoneB_hyp_decreases`, `zoneC_hyp_decreases`, ... +10 more

#### `BerggrenGenesis.lean` (249 lines)
*Source: `Pythagorean/Berggren/BerggrenGenesis.lean`*

- **def**: `berg_A`, `berg_B`, `berg_C`, `berg_S`, `vacuum`, `light`, ... +3 more
- **theorem**: `vacuum_pythagorean`, `light_pythagorean`, `vacuum_fixed_by_A`, `light_fixed_by_C`, `creation_B_vacuum`, `creation_B_light`, ... +31 more

#### `BerggrenQuadruples.lean` (258 lines)
*Source: `Pythagorean/Berggren/BerggrenQuadruples.lean`*

- **def**: `Q_triple`, `Q_quad`, `IsPythTriple`, `IsPythQuad`, `B₁`, `B₂`, ... +8 more
- **theorem**: `B₁_preserves_lorentz`, `B₂_preserves_lorentz`, `B₃_preserves_lorentz`, `root_is_pyth`, `B₁_child`, `B₂_child`, ... +20 more

#### `BerggrenRamanujan.lean` (417 lines) ⚠️ 1 sorry
*Source: `Pythagorean/Berggren/BerggrenRamanujan.lean`*

- **inductive**: `BDir`
- **def**: `berggrenStep`, `berggrenAt`, `berggrenB₁`, `berggrenB₂`, `berggrenB₃`, `berggren_Q`, `berggrenAdj`
- **noncomp. def**: `ramanujanBound`, `spectralGap3`, `spectralGap4`, `berggrenMixingTime`, `cheegerBound3`
- **theorem**: `berggrenStep_preserves_pyth`, `berggrenAt_pyth`, `det_berggrenB₁`, `det_berggrenB₂`, `det_berggrenB₃`, `berggrenB₁_invertible`, ... +39 more

#### `BerggrenTree.lean` (191 lines)
*Source: `Pythagorean/Berggren/BerggrenTree.lean`*

- **structure**: `PythTriple`
- **inductive**: `TreePath`
- **def**: `rootTriple`, `TreePath`, `berggrenTripleAux`, `berggrenA`, `berggrenB`, `berggrenC`, `treeTriplesAtDepth`
- **theorem**: `berggren_A_pyth_eq`, `berggren_B_pyth_eq`, `berggren_C_pyth_eq`, `berggrenTripleAux_pyth`, `berggren_A_iff`, `berggren_B_iff`, `berggren_C_iff`, `hypotenuse_growth`

#### `AdvancedFactoringResearch.lean` (338 lines)
*Source: `Pythagorean/Core/AdvancedFactoringResearch.lean`*

- **def**: `liftAndReflect`, `berggrenParent`, `fwdB1`, `fwdB2`, `fwdB3`
- **theorem**: `cascade_channel_d`, `cascade_channel_c`, `cascade_channel_b`, `cascade_channel_a`, `pairwise_ab`, `pairwise_cd`, ... +28 more

#### `BerggrenLorentzComplexity.lean` (256 lines)
*Source: `Pythagorean/Core/BerggrenLorentzComplexity.lean`*

- **structure**: `PPT`
- **def**: `ppt_root`, `parent_hyp`, `lorentzForm`
- **theorem**: `trivial_triple_identity`, `parent_hyp_strictly_less`, `parent_hyp_pos`, `diff_of_squares_int`, `diff_of_squares_nat`, `B_eigenvalue_product`, ... +13 more

#### `CoreFormalization.lean` (278 lines)
*Source: `Pythagorean/Core/CoreFormalization.lean`*

- **inductive**: `BPath`
- **def**: `lorentzQ`, `berggrenA_matrix`, `berggrenB_matrix`, `berggrenC_matrix`, `lorentzMetric`, `BPath`, ... +3 more
- **theorem**: `pyth_null_cone`, `berggrenA_lorentz`, `berggrenB_lorentz`, `berggrenC_lorentz`, `berggrenA_preserves_form`, `berggrenB_preserves_form`, ... +16 more

#### `DescentTheory.lean` (150 lines)
*Source: `Pythagorean/Core/DescentTheory.lean`*

- **structure**: `DescentDatum`, `DescentChain`, `QDim`
- **def**: `isCrystalline`
- **noncomp. def**: `matrixRank`
- **theorem**: `ascend_descend_le`, `descend_ascend_ge`, `descent_idempotent`, `ascent_idempotent`, `two_crystalline`, `twentyfour_crystalline`, ... +5 more

#### `FiveDirections.lean` (381 lines)
*Source: `Pythagorean/Core/FiveDirections.lean`*

- **def**: `Q21d`, `BB1d`, `BB2d`, `BB3d`, `IsPythQuad`, `chi4`, ... +6 more
- **theorem**: `BB1d_preserves`, `BB2d_preserves`, `BB3d_preserves`, `det_BB1d`, `det_BB2d`, `det_BB3d`, ... +88 more

#### `GaussianConnections.lean` (233 lines)
*Source: `Pythagorean/Core/GaussianConnections.lean`*

- **def**: `gaussNorm`, `paramMatrix`, `tripleFromParams`, `S_mat`, `T_mat`, `B₁`, ... +3 more
- **theorem**: `pyth_iff_gaussNorm_sq`, `gaussNorm_mul`, `gauss_conj_product`, `brahmagupta_fibonacci`, `gaussNorm_nonneg`, `factor_from_leg_b`, ... +31 more

#### `HigherDimDescent.lean` (250 lines)
*Source: `Pythagorean/Core/HigherDimDescent.lean`*

- **def**: `Q5`, `minkowski_inner_5`, `alt_reflect_5`, `eta5`, `listPrimQuints`
- **theorem**: `quad_parity_sum`, `quint_parity_sum`, `sext_parity_sum`, `quintuple_1_1_1_1_2`, `quintuple_null`, `eta_ss_5`, ... +19 more

#### `HigherDimQuadruples.lean` (325 lines)
*Source: `Pythagorean/Core/HigherDimQuadruples.lean`*

- **def**: `IsPythagorean5Tuple`, `IsPythagoreanQuadruple`, `IsPythagoreanTriple`, `IsPythagoreanKTuple`
- **theorem**: `five_tuple_factor_identity`, `five_tuple_factor_peel_third`, `five_tuple_factor_extraction`, `quadruple_lift_to_5tuple`, `quadruple_to_5tuple_via_leg`, `five_tuple_shared_hypotenuse`, ... +24 more

#### `InsideOutFactoring.lean` (208 lines)
*Source: `Pythagorean/Core/InsideOutFactoring.lean`*

- **def**: `invB1`, `invB2`, `invB3`, `grandparent_B2B2`
- **theorem**: `invB1_preserves_pyth`, `invB2_preserves_pyth`, `invB3_preserves_pyth`, `parent_hypotenuse_universal`, `parent_hypotenuse_decrease`, `parent2_components`, ... +11 more

#### `IntegerChains.lean` (331 lines)
*Source: `Pythagorean/Core/IntegerChains.lean`*

- **def**: `twoPole`
- **theorem**: `chain_01_complete`, `chain_1_neg1_complete`, `twoPole_02_at_0`, `twoPole_02_at_1`, `twoPole_02_at_neg2`, `twoPole_02_at_3`, ... +11 more

#### `Mediant.lean` (57 lines)
*Source: `Pythagorean/Core/Mediant.lean`*

- **noncomp. def**: `mediant`
- **theorem**: `mediant_between`, `exists_rat_between`, `rat_dense_in_real`, `rat_approx`

#### `NewHypotheses.lean` (158 lines) ⚠️ 1 sorry
*Source: `Pythagorean/Core/NewHypotheses.lean`*

- **def**: `lorentzQ4`, `pellNum`, `pellComp`, `BA`, `BA`, `QLorentz`
- **theorem**: `quadruple_null_cone`, `fundamental_quadruple`, `quadruple_scaling`, `pellNum_0`, `pellNum_1`, `pellNum_2`, ... +14 more

#### `O31_Generators.lean` (284 lines)
*Source: `Pythagorean/Core/O31_Generators.lean`*

- **def**: `lorentz_metric`, `lorentz_inner`, `lorentz_norm`, `is_pythagorean_quad`, `allones_reflection`, `R₁`, ... +12 more
- **theorem**: `lorentz_norm_eq_inner`, `pythagorean_iff_null`, `R1_involution`, `R1_preserves_metric`, `R1_det`, `P01_involution`, ... +18 more

#### `OrderClassification.lean` (338 lines)
*Source: `Pythagorean/Core/OrderClassification.lean`*

- **def**: `twoPole`, `twoPole_trace`, `twoPole_det`
- **theorem**: `brahmagupta_fibonacci_1`, `order2_trace_zero`, `order2_integer_solutions`, `twoPole_1_neg1`, `twoPole_1_neg1_order2`, `order4_condition`, ... +5 more

#### `ParentDescent.lean` (345 lines)
*Source: `Pythagorean/Core/ParentDescent.lean`*

- **structure**: `through`
- **def**: `B₁_inv`, `B₂_inv`, `B₃_inv`, `applyInvB1`, `applyInvB2`, `applyInvB3`, ... +7 more
- **theorem**: `invB1_comp_B1`, `invB2_comp_B2`, `invB3_comp_B3`, `B₁_inv_mul_B₁`, `B₂_inv_mul_B₂`, `B₃_inv_mul_B₃`, ... +17 more

#### `ParentFactoringExperiments.lean` (121 lines)
*Source: `Pythagorean/Core/ParentFactoringExperiments.lean`*

- **def**: `trivialTriple`, `universalParent`, `tryFactor`, `factorByParentDescent`, `stepsToFactor`, `euclidParams`

#### `PrimitiveDivisibility.lean` (95 lines)
*Source: `Pythagorean/Core/PrimitiveDivisibility.lean`*

- **theorem**: `sq_mod5`, `pyth_div5`, `pyth_div3`, `pyth_div2`, `pyth_60_div_abc`

#### `PythagoreanDensity.lean` (310 lines) ⚠️ 1 sorry
*Source: `Pythagorean/Core/PythagoreanDensity.lean`*

- **structure**: `of`
- **def**: `IsPythagoreanTriple`, `pythagoreanParam`, `lorentzQ`, `berggrenA`, `berggrenB`, `berggrenC`, `IsSumTwoSquares`, `berggrenParent`
- **theorem**: `param_is_pythagorean`, `pyth_not_both_odd`, `pyth_scale`, `pyth_3_4_5`, `pyth_5_12_13`, `pyth_8_15_17`, ... +22 more

#### `PythagoreanFactoring.lean` (306 lines)
*Source: `Pythagorean/Core/PythagoreanFactoring.lean`*

- **structure**: `PythTriple`, `DivisorPair`
- **noncomp. def**: `divisorPairToTriple`, `tripleToDivisorPair`
- **theorem**: `diff_of_squares_pyth`, `divisor_pair_gives_triple`, `gcd_factor_of_n`, `semiprime_factor_triple`, `prime_unique_triple`, `composite_multiple_triples`, ... +3 more

#### `PythagoreanLight.lean` (202 lines)
*Source: `Pythagorean/Core/PythagoreanLight.lean`*

- **theorem**: `pythagorean_parametrization`, `brahmagupta_fibonacci`, `unit_circle_rational_point`, `gaussian_norm_multiplicative`, `fermat_two_square_easy_direction`, `lightlike_direction`, ... +5 more

#### `PythagoreanPairing.lean` (384 lines)
*Source: `Pythagorean/Core/PythagoreanPairing.lean`*

- **structure**: `SumOfSquaresRep`
- **def**: `SumOfSquaresRep`, `findReps`, `findPairedTriples`
- **noncomp. def**: `pairingFactor`
- **theorem**: `brahmagupta_fibonacci`, `brahmagupta_fibonacci_alt`, `brahmagupta_two_reps`, `two_reps_product_identity`, `two_reps_divisibility`, `cross_product_identity`, ... +13 more

#### `PythagoreanTriples.lean` (187 lines)
*Source: `Pythagorean/Core/PythagoreanTriples.lean`*

- **def**: `IsPythagoreanTriple`
- **theorem**: `pythagorean_3_4_5`, `pythagorean_5_12_13`, `pythagorean_8_15_17`, `pythagorean_scale`, `pythagorean_swap`, `euclid_formula`, ... +8 more

#### `SpacetimeLattice.lean` (405 lines)
*Source: `Pythagorean/Core/SpacetimeLattice.lean`*

- **inductive**: `InBerggrenTree`
- **def**: `IntLattice2`, `IsDiscreteSet`, `IsPythTriple`, `IsPrimitivePythTriple`, `berggrenA`, `berggrenB`, ... +7 more
- **theorem**: `intLattice2_discrete`, `triple_3_4_5`, `triple_5_12_13`, `triple_8_15_17`, `euclid_pythagorean`, `berggren_A_preserves`, ... +16 more

#### `SumOfSquares.lean` (161 lines)
*Source: `Pythagorean/Core/SumOfSquares.lean`*

- **def**: `NatSumTwoSq`
- **theorem**: `natS2S_zero`, `natS2S_one`, `natS2S_two`, `natS2S_five`, `sq_is_natS2S`, `not_natS2S_three`, ... +16 more

#### `SumOfSquaresFilter.lean` (104 lines)
*Source: `Pythagorean/Core/SumOfSquaresFilter.lean`*

- **def**: `IsSumTwoSquares`
- **theorem**: `fermat_two_squares`, `two_is_sum_two_squares`, `prime_3mod4_not_sum_two_squares`, `sum_two_squares_mul`, `square_is_sum_two_squares`

#### `TeamResearch.lean` (360 lines)
*Source: `Pythagorean/Core/TeamResearch.lean`*

- **theorem**: `brahmagupta_fibonacci`, `brahmagupta_fibonacci`, `sum_two_sq_mul_sum_two_sq`, `gaussian_norm_multiplicative`, `pyth_diff_sq`, `pyth_hyp_product`, ... +30 more

#### `UniversalParent.lean` (572 lines)
*Source: `Pythagorean/Core/UniversalParent.lean`*

- **structure**: `PythTriple`
- **def**: `berggren_B1`, `berggren_B2`, `berggren_B3`, `berggren_B1_inv`, `berggren_B2_inv`, `berggren_B3_inv`, ... +21 more
- **theorem**: `parent_hypotenuse_universal`, `universalParent_preserves_pyth`, `universalParent_hyp_decreases`, `universalParent_hyp_pos`, `invB1_lorentz_invariant`, `invB2_lorentz_invariant`, ... +20 more

### Pythagorean/Frameworks

*2 files, 90 declarations, 545 lines*

#### `Foundations.lean` (265 lines) ⚠️ 1 sorry
*Source: `Pythagorean/Frameworks/PythagoreanQuadrupleFactoringFramework/Pythagorean/Foundations.lean`*

- **def**: `IsPythagoreanQuadruple`, `kineticEnergy`, `gravPotential`, `gravPotentialSq`
- **theorem**: `peel_channel_a`, `peel_channel_b`, `peel_channel_c`, `three_independent_gcds`, `collision_advantage_ratio`, `single_quadruple_channels`, ... +32 more

#### `Foundations.lean` (280 lines)
*Source: `Pythagorean/Frameworks/QuadrupleGravityEnergy/Foundations.lean`*

- **structure**: `PythQuadruple`
- **def**: `gravitational_potential`, `kinetic_energy`, `is_smooth`, `lebesgue_param`, `embed_quad_in_8d`, `quad_example_1`, ... +3 more
- **theorem**: `energy_conservation`, `peel_channel_a`, `peel_channel_b`, `peel_channel_c`, `triple_peel_advantage`, `cross_channel_ab`, ... +32 more

### Pythagorean/GravitationalFactoring

*5 files, 115 declarations, 859 lines*

#### `CoreTheorems.lean` (249 lines)
*Source: `GravitationalFactoringResearch/CoreTheorems.lean`*

- **def**: `totalChannels`, `berggrenA`, `berggrenB`, `berggrenC`, `factoringEnergy`
- **noncomp. def**: `sigma1`
- **theorem**: `channel_quadratic_growth`, `channel_hierarchy_concrete`, `channels_strictly_increasing`, `peel_identity`, `peel_product_is_complement`, `peel_product_factors_N`, ... +22 more

#### `CrossCollisionProbability.lean` (101 lines)
*Source: `GravitationalFactoringResearch/CrossCollisionProbability.lean`*

- **def**: `crossCollisionPairs`, `totalUniqueChannels`
- **theorem**: `collision_gives_gcd_candidate`, `cross_collision_pair_count`, `shared_hypotenuse_sum_eq`, `shared_peel_equality`, `cross_collision_diff_sq`, `factor_divides_gcd`, ... +6 more

#### `SieveComplexity.lean` (80 lines)
*Source: `GravitationalFactoringResearch/SieveComplexity.lean`*

- **def**: `isSmooth`, `peelProduct`, `factorBase`
- **theorem**: `one_smooth`, `smooth_mul`, `peelProduct_eq`, `relation_count_needed`, `balanced_semiprime_bound`, `balanced_density`, ... +3 more

#### `Foundations.lean` (272 lines)
*Source: `Pythagorean/GravitationalFactoring/Foundations.lean`*

- **structure**: `PythKTuple`
- **def**: `pythagoreanEnergy`, `ktupleEnergy`, `quaternionNorm`, `crossCollisionPairs`, `totalFactoringChannels`, `rootQuadruple`, ... +4 more
- **theorem**: `energy_zero_iff_quadruple`, `root_energy_zero`, `ktuple_energy_zero_iff`, `ktuple_peel_channel`, `peel_channel_count`, `shared_hypotenuse_collision`, ... +17 more

#### `HigherDimensions.lean` (157 lines)
*Source: `Pythagorean/GravitationalFactoring/HigherDimensions.lean`*

- **def**: `factoringChannels`, `cayleyDicksonDims`
- **theorem**: `two_square_identity`, `two_square_identity_alt`, `two_square_dual_decomposition`, `channel_hierarchy`, `channels_triangular_formula`, `gaussian_norm_multiplicative`, ... +13 more

### Pythagorean/HyperbolicFactoring

*3 files, 135 declarations, 796 lines*

#### `HyperbolicShortcuts.lean` (193 lines)
*Source: `Pythagorean/HyperbolicFactoring/HyperbolicShortcuts.lean`*

- **structure**: `reveals`
- **inductive**: `BDir`
- **def**: `B₁`, `B₂`, `B₃`, `Q`, `dirMatrix`, `pathMatrix`, ... +4 more
- **theorem**: `B₁_preserves_Q`, `B₂_preserves_Q`, `B₃_preserves_Q`, `det_B₁`, `det_B₂`, `det_B₃`, ... +21 more

#### `HyperbolicSkipAheadFactoring.lean` (265 lines)
*Source: `Pythagorean/HyperbolicFactoring/HyperbolicSkipAheadFactoring.lean`*

- **inductive**: `Branch`
- **def**: `B₁`, `B₂`, `B₃`, `Q`, `is_on_light_cone`, `branchMatrix`, `pathMatrix`
- **theorem**: `trivial_triple_pyth`, `trivial_triple_diff_sq_eq_one`, `trivial_triple_even`, `nontrivial_factor_from_gcd`, `diff_of_squares_factor`, `factor_from_scaled_triple`, ... +12 more

#### `NewTheorems.lean` (338 lines)
*Source: `Pythagorean/HyperbolicFactoring/NewTheorems.lean`*

- **inductive**: `BDir`
- **def**: `B₁`, `B₂`, `B₃`, `Q`, `dirMatrix`, `pathMatrix`, ... +12 more
- **theorem**: `dir_preserves_Q`, `pathMatrix_preserves_Q`, `pathMatrix_append`, `dir_det_abs`, `pathMatrix_det_abs`, `parallel_independence`, ... +45 more

### Pythagorean/InverseTree

*4 files, 122 declarations, 882 lines*

#### `ChainFactoring.lean` (379 lines)
*Source: `Pythagorean/InverseTree/ChainFactoring.lean`*

- **def**: `invB1`, `invB2`, `invB3`, `fwdB1`, `fwdB2`, `fwdB3`, ... +6 more
- **theorem**: `invB1_preserves_pyth`, `invB2_preserves_pyth`, `invB3_preserves_pyth`, `fwdB1_invB1`, `fwdB2_invB2`, `fwdB3_invB3`, ... +32 more

#### `ContinuedFractions.lean` (170 lines)
*Source: `Pythagorean/InverseTree/ContinuedFractions.lean`*

- **def**: `cfM₁`, `cfM₂`, `cfM₃`, `cfT`, `cfS`, `cfM₁_inv`, `cfM₃_inv`
- **theorem**: `cfM1_det`, `cfM2_det`, `cfM3_det`, `cfT_det`, `cfS_det`, `M3_is_T_squared`, ... +10 more

#### `JumpAhead.lean` (176 lines)
*Source: `Pythagorean/InverseTree/JumpAhead.lean`*

- **inductive**: `BerggrenBranch`
- **def**: `invB1`, `invB2`, `invB3`, `applyInvBranch`, `descentChain`, `isPythagorean`, `parentHyp`, `lorentzForm`
- **theorem**: `descent_composition`, `invBranch_preserves_pyth`, `descentChain_preserves_pyth`, `all_branches_same_hyp`, `parent_hyp_strictly_less`, `parent_hyp_pos`, ... +7 more

#### `LorentzConnections.lean` (157 lines)
*Source: `Pythagorean/InverseTree/LorentzConnections.lean`*

- **def**: `LQ`, `LB₁`, `LB₂`, `LB₃`, `LBinv₁`, `lorentzBilinear`
- **theorem**: `LB1_preserves_lorentz`, `LB2_preserves_lorentz`, `LB3_preserves_lorentz`, `LBinv1_preserves_lorentz`, `LBinv1_is_inverse`, `Q_squared_is_identity`, ... +15 more

### Pythagorean/LatticeTree

*9 files, 152 declarations, 1,043 lines*

#### `DimensionalHierarchy.lean` (201 lines)
*Source: `Pythagorean/LatticeTree/DimensionalHierarchy.lean`*

- **theorem**: `exponent_strictly_decreases`, `power_strict_increase`, `hermite_bound_ordering`, `lattice_det_bound`, `quad_lattice_add_identity`, `quad_lattice_neg_closed`, ... +20 more

#### `ExtendedResults.lean` (186 lines)
*Source: `Pythagorean/LatticeTree/ExtendedResults.lean`*

- **theorem**: `enhanced_extraction_add`, `enhanced_extraction_sub`, `gcd_count_3d`, `gcd_count_4d`, `gcd_count_5d`, `gcd_count_6d`, ... +19 more

#### `FactorExtraction.lean` (81 lines)
*Source: `Pythagorean/LatticeTree/FactorExtraction.lean`*

- **def**: `extractionCandidates`
- **theorem**: `gcd_factor_extraction`, `cascade_factor_extraction`, `candidates_divide_N`, `brahmagupta_fibonacci`, `three_square_cauchy_schwarz`, `dim_advantage_exponent`, ... +3 more

#### `Foundations.lean` (113 lines)
*Source: `Pythagorean/LatticeTree/Foundations.lean`*

- **def**: `factorCong`, `sqNorm`
- **theorem**: `factorCong_refl`, `factorCong_zero`, `factorCong_diff_of_squares`, `factorCong_gcd_factor`, `sqNorm_nonneg`, `sqNorm_add_le`, ... +10 more

#### `GaussReduction.lean` (70 lines)
*Source: `Pythagorean/LatticeTree/GaussReduction.lean`*

- **def**: `dot2`
- **theorem**: `cf_quotient_eq`, `M1_inv_action`, `M3_inv_action`, `M1_inv_cf_step`, `berggren_is_gauss`, `berggren_2d_optimal`, ... +3 more

#### `LorentzGenerators.lean` (152 lines)
*Source: `Pythagorean/LatticeTree/LorentzGenerators.lean`*

- **def**: `IsPythQuad`, `InQuadLat`
- **theorem**: `quad_example_1`, `quad_example_2`, `quad_example_3`, `quad_example_4`, `quad_example_5`, `perm_12`, ... +18 more

#### `MinkowskiBound.lean` (83 lines)
*Source: `Pythagorean/LatticeTree/MinkowskiBound.lean`*

- **theorem**: `lattice_det_pos`, `minkowski_exponent_decreases`, `power_monotone`, `cube_root_le_sqrt`, `hermite_2_lt_3`, `lll_factor_grows`, ... +6 more

#### `QuadrupleEscape.lean` (85 lines)
*Source: `Pythagorean/LatticeTree/QuadrupleEscape.lean`*

- **def**: `IsThreeSquareRep`, `InQuadLattice`, `lorentzEta`, `IsLorentzInt`, `extractFactor`
- **theorem**: `three_square_one`, `three_square_two`, `three_square_three`, `three_square_five`, `three_square_six`, `zero_in_quad_lattice`, ... +5 more

#### `ShortVectors.lean` (72 lines)
*Source: `Pythagorean/LatticeTree/ShortVectors.lean`*

- **def**: `quadLattice`
- **theorem**: `short_vector_nontrivial_factor_int`, `short_vector_gives_dvd_int`, `short_pair_identity`, `gaussStep_det`, `cf_step_transform`, `combined_approach_potential`, `effective_complexity_balanced`, `effective_complexity_unbalanced`

### Pythagorean/ModularForms

*6 files, 474 declarations, 2,686 lines*

#### `ModularForms.lean` (495 lines)
*Source: `Pythagorean/Modular/ModularForms.lean`*

- **structure**: `of`
- **def**: `T_mat`, `T_sq`, `S_gen`, `BM₁`, `BM₂`, `BM₃`, ... +14 more
- **noncomp. def**: `r₂`, `crossRatio`
- **theorem**: `BM₃_eq_T_sq`, `T_sq_eq_T_mul_T`, `BM₃_inv_mul_BM₁_eq_S`, `BM₁_eq_BM₃_mul_S`, `S_gen_sq_eq_neg_one`, `S_gen_pow_four`, ... +59 more

#### `ModularFormsAdvanced.lean` (208 lines)
*Source: `Pythagorean/Modular/ModularFormsAdvanced.lean`*

- **def**: `IsPythQuadruple`, `Q31`, `Q21`, `BB₁_adv`, `chi_neg4`, `BM₁_adv`, ... +5 more
- **theorem**: `fundamental_quadruple`, `quadruple_2_3_6_7`, `det_Q31`, `det_Q21`, `BB₁_adv_preserves_Q21`, `quadruple_parametrization`, ... +45 more

#### `RamanujanFrontiers.lean` (492 lines)
*Source: `Pythagorean/Ramanujan/RamanujanFrontiers.lean`*

- **def**: `rfB₁`, `rfB₂`, `rfB₃`, `rfQ`, `matMod`, `groverCoin3x`, ... +6 more
- **noncomp. def**: `spectralGap6`, `cheegerBound6`, `quantumSpectralGap`, `spectralGap8`, `relativeGap3`, `relativeGap6`, `relativeGap8`
- **theorem**: `rfB₁_lorentz_mod5`, `rfB₂_lorentz_mod5`, `rfB₃_lorentz_mod5`, `rfB₁_lorentz_mod7`, `rfB₂_lorentz_mod7`, `rfB₃_lorentz_mod7`, ... +54 more

#### `RamanujanFrontiers2.lean` (474 lines)
*Source: `Pythagorean/Ramanujan/RamanujanFrontiers2.lean`*

- **def**: `rfB₁`, `rfB₂`, `rfB₃`, `rfQ`, `matMod`, `rfQ5`, ... +11 more
- **theorem**: `rfB₁`, `rfB₂`, `rfB₃`, `trace_rfB₁`, `trace_rfB₂`, `trace_rfB₃`, ... +73 more

#### `RamanujanFrontiers3.lean` (484 lines)
*Source: `Pythagorean/Ramanujan/RamanujanFrontiers3.lean`*

- **def**: `rf3B₁`, `rf3B₂`, `rf3B₃`, `rf3Q`, `rf3matMod`, `rf3Q5`, ... +6 more
- **theorem**: `rf3_lorentz_mod5_all`, `rf3_lorentz_mod7_all`, `rf3_lorentz_mod11_all`, `ramanujan_bound_6reg_bounds`, `rf3B₂_has_eigenvalue_neg1`, `rf3B₂_cayley_hamilton`, ... +50 more

#### `RamanujanOpenProblems.lean` (533 lines)
*Source: `Pythagorean/Ramanujan/RamanujanOpenProblems.lean`*

- **def**: `ropB₁`, `ropB₂`, `ropB₃`, `ropQ`, `ropMatMod`, `ropB₁B₂`, ... +9 more
- **theorem**: `rop_lorentz_mod13`, `rop_lorentz_mod17`, `rop_lorentz_mod19`, `rop_lorentz_mod23`, `rop_lorentz_mod29`, `rop_lorentz_mod31`, ... +60 more

### Pythagorean/QDF

*6 files, 220 declarations, 1,751 lines*

#### `QDF_ArithGeomQuantum.lean` (341 lines)
*Source: `Pythagorean/QDF/QDF_ArithGeomQuantum.lean`*

- **theorem**: `radical_decomposition_full`, `abc_triple_sum`, `perfect_square_dc`, `double_perfect_square`, `thin_quadruple_sum`, `fat_quadruple`, ... +39 more

#### `QDF_FiveDirections.lean` (359 lines)
*Source: `Pythagorean/QDF/QDF_FiveDirections.lean`*

- **theorem**: `qdf_lattice_scaling`, `lattice_component_bound`, `lattice_shortest_vector_gap`, `qdf_gram_diagonal`, `qdf_lattice_inner_bound`, `qdf_lattice_reduction`, ... +40 more

#### `QDF_HE_Frontiers.lean` (357 lines)
*Source: `Pythagorean/QDF/QDF_HE_Frontiers.lean`*

- **theorem**: `qdf_lorentz_signature`, `qdf_sum_norm`, `qdf_z4_inner_product`, `qdf_double`, `qdf_even_sublattice`, `qdf_minkowski_norm_bound`, ... +41 more

#### `QDF_NewDirections.lean` (235 lines)
*Source: `Pythagorean/QDF/QDF_NewDirections.lean`*

- **theorem**: `radical_bound_basic`, `thin_quadruple_pell`, `abc_quality_bound`, `parity_propagation`, `three_odd_forces_odd_d`, `even_d_parity_constraint`, ... +25 more

#### `QDF_OpenQuestions.lean` (215 lines)
*Source: `Pythagorean/QDF/QDF_OpenQuestions.lean`*

- **theorem**: `quadruple_exists_trivial`, `trivial_gcd_coprime`, `trivial_gcd_implies_coprime_sum`, `shared_component_factor`, `param_deformation_bound`, `navigation_target`, ... +21 more

#### `QuadDivisionFactoring.lean` (244 lines)
*Source: `Pythagorean/QDF/QuadDivisionFactoring.lean`*

- **def**: `berggrenM1`, `berggrenM2`, `berggrenM3`
- **theorem**: `odd_trivial_triple`, `even_trivial_triple`, `quad_factor_identity`, `triple_lift_to_quadruple`, `gcd_dc_divides_sum_sq`, `factor_extraction_product`, ... +15 more

### Pythagorean/Quadruples

*13 files, 347 declarations, 3,038 lines*

#### `DivisionAlgebras.lean` (82 lines)
*Source: `HigherDimensionalQuadrupleDivisionFactoring/DivisionAlgebras.lean`*

- **theorem**: `brahmagupta_fibonacci`, `brahmagupta_fibonacci_alt`, `euler_four_square`, `degen_eight_square`, `triple_composition`, `quadruple_composition`, `parametric_quadruple`

#### `FiveTuples.lean` (135 lines)
*Source: `HigherDimensionalQuadrupleDivisionFactoring/FiveTuples.lean`*

- **def**: `IsPythagorean5Tuple`
- **theorem**: `five_tuple_peel_first`, `five_tuple_peel_second`, `five_tuple_peel_third`, `five_tuple_peel_fourth`, `five_tuple_multi_channel`, `five_tuple_factor_extraction`, ... +9 more

#### `KTuples.lean` (108 lines)
*Source: `HigherDimensionalQuadrupleDivisionFactoring/KTuples.lean`*

- **def**: `IsPythagoreanKTuple`
- **theorem**: `ktuple_factor_identity`, `ktuple_gcd_extraction`, `ktuple_shared_hypotenuse`, `ktuple_lift`, `dimension_channel_growth`, `cross_collision_count`, ... +3 more

#### `NormHierarchy.lean` (148 lines)
*Source: `HigherDimensionalQuadrupleDivisionFactoring/NormFactoring/NormHierarchy.lean`*

- **def**: `qnorm`, `berggren_A`, `berggren_B`, `berggren_C`, `divAlgDims`
- **theorem**: `peel_identity_dim2`, `factor_channel_dim2`, `peel_identity_dim4`, `collision_identity`, `collision_product`, `norm_mult_dim2`, ... +15 more

#### `QuantumE8Modular.lean` (189 lines) ⚠️ 1 sorry
*Source: `HigherDimensionalQuadrupleDivisionFactoring/NormFactoring/QuantumE8Modular.lean`*

- **def**: `e8_kissing_number`, `onorm`
- **noncomp. def**: `sigma_k`, `count_divisors_mod`
- **theorem**: `cross_collision_count`, `quantum_quadratic_speedup`, `total_factoring_equations`, `sigma_k_pos`, `onorm_nonneg`, `dim8_cross_collisions`, ... +16 more

#### `Basic.lean` (251 lines)
*Source: `Pythagorean/Quadruples/Basic.lean`*

- **def**: `sumSqCong`, `SumSqCongSet`, `quadResLattice`, `sumThreeSqLattice`, `lattice3D_basis`
- **theorem**: `zero_mem_sumSqCongSet`, `mul_N_mem`, `sumSqCongSet_not_closed_add`, `quadResLattice_add_closed`, `quadResLattice_zero`, `quadResLattice_neg`, ... +11 more

#### `FactoringTheory.lean` (100 lines)
*Source: `Pythagorean/Quadruples/FactoringTheory.lean`*

- **theorem**: `coprime_quotient_useless`, `factoring_works_iff`, `minkowski_worse_than_sqrt`, `optimal_dimension_is_two`, `quad_param_valid`, `quad_param_in_L4`, `coprime_lattice_intersection`, `quad_unit_sphere`

#### `Foundations.lean` (353 lines)
*Source: `Pythagorean/Quadruples/Foundations.lean`*

- **def**: `Q4`, `IsNullQ4`, `eta4`, `IsLorentz4`, `R1111`, `perm01`, ... +10 more
- **theorem**: `quad_eq_null`, `R1111_isLorentz`, `R1111_involution`, `perm01_isLorentz`, `perm12_isLorentz`, `signFlip0_isLorentz`, ... +15 more

#### `OpenQuestions.lean` (376 lines)
*Source: `Pythagorean/Quadruples/OpenQuestions.lean`*

- **structure**: `LipschitzInt`
- **def**: `sqNorm`, `mul`, `conj`, `add`, `sub`, `zero`, ... +12 more
- **theorem**: `LipschitzInt`, `LipschitzInt`, `LipschitzInt`, `sigmaQuat_sqNorm`, `eulerMap_pyth`, `sigma_equiv_same_hyp_mod`, ... +28 more

#### `OracleCouncil.lean` (236 lines)
*Source: `Pythagorean/Quadruples/OracleCouncil.lean`*

- **def**: `IsPythQuadruple`, `IntSphere`
- **theorem**: `parametric_quadruple`, `quadruple_perm_abc`, `quadruple_perm_acb`, `quadruple_neg_a`, `quadruple_scale`, `quad_1_2_2_3`, ... +21 more

#### `PythagoreanQuadruples.lean` (416 lines)
*Source: `Pythagorean/Quadruples/PythagoreanQuadruples.lean`*

- **structure**: `of`, `PythQuad`
- **inductive**: `CausalType`
- **def**: `lorentzForm4`, `isNull4`, `isTimelike4`, `isSpacelike4`, `Q_lor4`, `quad_1_2_2_3`, ... +18 more
- **theorem**: `quad_iff_null`, `quad_1_2_2_3_null`, `quadParam_is_pyth`, `tripleToQuad_null`, `scaling_family`, `degenerate_family`, ... +13 more

#### `QuaternionDescent.lean` (292 lines)
*Source: `Pythagorean/Quadruples/QuaternionDescent.lean`*

- **structure**: `IntQuat`
- **def**: `sqNorm`, `conj`, `qmul`, `qadd`, `qneg`, `eulerFromQuat`, ... +4 more
- **theorem**: `IntQuat`, `IntQuat`, `IntQuat`, `eulerFromQuat_is_pyth`, `euler_hyp_eq_sqNorm`, `sigma_sqNorm`, ... +16 more

#### `SingleTree.lean` (352 lines)
*Source: `Pythagorean/Quadruples/SingleTree.lean`*

- **def**: `QF_eta4`, `QF_R1111`, `QF_perm01`, `QF_perm12`, `QF_signFlip0`, `QF_descentStep`, ... +3 more
- **theorem**: `QF_R1111_isLorentz`, `QF_R1111_sq_eq_one`, `QF_descent_preserves_pyth`, `QF_sum_exceeds_hyp`, `QF_sum_below_twice_hyp`, `QF_descent_decreases`, ... +19 more

### Pythagorean/Research

*15 files, 287 declarations, 2,248 lines*

#### `DegenEightSquare.lean` (143 lines)
*Source: `Pythagorean/FutureResearch/DegenEightSquare.lean`*

- **structure**: `Octo`
- **def**: `octonionNorm`
- **theorem**: `degen_eight_square_identity`, `degen_eight_square_reverse`, `octonion_norm_multiplicative`, `eight_square_product_closure`, `octo_peel_channel`, `octo_gcd_divides`, `thirty_six_channels`, `dual_octonionic_decomposition`

#### `FactoringHypersurface.lean` (102 lines)
*Source: `Pythagorean/FutureResearch/FactoringHypersurface.lean`*

- **def**: `revealsFactorVia`
- **theorem**: `factoring_set_is_AP`, `semiprime_factoring_channels`, `exists_revealing_value`, `gcd_divides_N`, `prime_divides_gcd`, `single_gcd_suffices`, `remaining_sum_after_peel`, `more_channels_more_chances`

#### `HurwitzQuaternions.lean` (156 lines)
*Source: `Pythagorean/FutureResearch/HurwitzQuaternions.lean`*

- **def**: `lipschitzNorm`
- **theorem**: `lipschitzNorm_nonneg`, `lipschitzNorm_eq_zero`, `euler_four_sq_identity`, `four_square_product_closure`, `lipschitz_unit_norms`, `norm_factorization_principle`, ... +6 more

#### `InformationTheory.lean` (122 lines)
*Source: `Pythagorean/FutureResearch/InformationTheory.lean`*

- **def**: `totalChannels`
- **theorem**: `gcd_symm`, `two_channels_different_gcds`, `cross_collision_equation`, `channel_counts`, `octonionic_advantage_ratio`, `sedenionic_channels`, ... +4 more

#### `OpenQuestions.lean` (278 lines)
*Source: `Pythagorean/FutureResearch/OpenQuestions.lean`*

- **def**: `gaussianNorm`, `isSmooth`
- **theorem**: `brahmagupta_fibonacci`, `brahmagupta_fibonacci_alt`, `two_square_dual_decomposition`, `two_square_product_closure`, `inclusion_exclusion_count`, `density_lower_bound_nat`, ... +26 more

#### `ParityObstructions.lean` (91 lines)
*Source: `Pythagorean/FutureResearch/ParityObstructions.lean`*

- **theorem**: `parity_constraint_odd_N`, `even_peel_div_four`, `three_mod_four_not_sum_two_sq`, `seven_mod_eight_not_sum_three_sq`, `semiprime_peel_compatible`, `even_leg_channel_works`, `odd_peel_factor_is_odd`, `triple_parity`

#### `ComplexityBounds.lean` (105 lines)
*Source: `Pythagorean/OpenQuestions/ComplexityBounds.lean`*

- **theorem**: `descent_reduces_hyp_by_2`, `descent_hyp_lt`, `descent_hyp_pos`, `balanced_descent_ratio`, `trivial_triple_depth_prime`, `trivial_depth_linear`, ... +9 more

#### `HigherDimensional.lean` (86 lines)
*Source: `Pythagorean/OpenQuestions/HigherDimensional.lean`*

- **structure**: `PythQuadruple`
- **def**: `trivialQuadruple`, `Q4`, `tripleToQuadruple`, `eta4`
- **theorem**: `quad_null_cone`, `quad_diff_squares`, `quad_double_factor`, `quad_projects`, `eta4_squared`, `trivial_decomp`, ... +4 more

#### `LorentzStructure.lean` (94 lines)
*Source: `Pythagorean/OpenQuestions/LorentzStructure.lean`*

- **def**: `Q_form`, `η_mat`, `B1_mat`, `B2_mat`, `B3_mat`, `M1_2x2`, `M2_2x2`, `M3_2x2`
- **theorem**: `η_squared`, `B1_lorentz`, `B2_lorentz`, `B3_lorentz`, `B1_3x3_det`, `B2_3x3_det`, ... +12 more

#### `DensityAndChannels.lean` (253 lines) ⚠️ 1 sorry
*Source: `Pythagorean/OpenQuestions/NewResearch/DensityAndChannels.lean`*

- **theorem**: `brahmagupta_fibonacci`, `brahmagupta_fibonacci_alt`, `two_square_dual_decomposition`, `peel_product_eq`, `peel_identity_sum`, `inclusion_exclusion_count`, ... +20 more

#### `NewResults.lean` (210 lines) ⚠️ 1 sorry
*Source: `Pythagorean/OpenQuestions/NewResults.lean`*

- **def**: `oq_lorentzForm31`, `oq_lorentzQ`
- **theorem**: `oq_descent_step_decrease`, `oq_descent_always_decreases`, `oq_parent_hyp_positive`, `oq_trivial_depth_quadratic`, `oq_euclid_parametrization`, `oq_euclid_triple_gap`, ... +24 more

#### `NontrivialShortcuts.lean` (68 lines)
*Source: `Pythagorean/OpenQuestions/NontrivialShortcuts.lean`*

- **theorem**: `divisor_pair_triple`, `gcd_divides`, `semiprime_shortcut`, `nontrivial_pair_implies_factor`, `factor_gives_pair`, `fermat_two_square_triple`, `four_pairs_semiprimes`, `optimal_start_params`

#### `OpenQuestions.lean` (237 lines)
*Source: `Pythagorean/OpenQuestions/OpenQuestions.lean`*

- **def**: `Q6`, `eta5_form`, `s5_a`, `s5_b`, `listPrimSextuples`, `descentStep6`, `verifyDescent6`
- **theorem**: `null_cone_eta_even`, `descent_identity_k6`, `descent_strict_k6`, `root_sextuple`, `descent_terminates_k6`, `k5_uniform_reflection_fails`, ... +17 more

#### `ParallelDescent.lean` (59 lines)
*Source: `Pythagorean/OpenQuestions/ParallelDescent.lean`*

- **theorem**: `B1_B2_distinct_hyp`, `B1_B3_distinct_hyp`, `B2_B3_distinct_hyp`, `unique_parent`, `inv_first_comp_exclusive`, `tree_branching`, ... +5 more

#### `Synthesis.lean` (244 lines)
*Source: `Pythagorean/OpenQuestions/Synthesis.lean`*

- **def**: `OQ_Q4_form`, `OQ_η4`, `OQ_η`, `OQ_B1`, `OQ_B2`, `OQ_B3`, `OQ_B1_inv`, `OQ_B2_inv`
- **theorem**: `OQ_systems_at_depth`, `OQ_root_eq_degree_two`, `OQ_total_candidates`, `OQ_descent_step_decrease`, `OQ_descent_max_steps`, `OQ_exponential_vs_linear`, ... +25 more

### Pythagorean/ThreeRoads

*5 files, 144 declarations, 1,206 lines*

#### `AdvancedTheorems.lean` (315 lines)
*Source: `Pythagorean/ThreeRoads/AdvancedTheorems.lean`*

- **theorem**: `divisor_pair_to_triple`, `triple_to_divisor_pair`, `divisor_triple_roundtrip`, `canonical_prime_triple`, `trivial_factorization_triple`, `B1_preserves_pythagorean`, ... +22 more

#### `DeepOpenProblems.lean` (196 lines)
*Source: `Pythagorean/ThreeRoads/DeepOpenProblems.lean`*

- **theorem**: `smooth_density_gap_square`, `smooth_density_min_gap`, `B1_leg_sum`, `B2_leg_sum`, `B3_leg_sum`, `B2_leg_product_expanded`, ... +30 more

#### `NewTheorems.lean` (283 lines)
*Source: `Pythagorean/ThreeRoads/NewTheorems.lean`*

- **theorem**: `coprime_preserved_B1`, `coprime_preserved_B2`, `coprime_preserved_B3`, `pythagorean_parity`, `B1_preserves_odd_first_leg`, `hypotenuse_strict_increase_B1`, ... +12 more

#### `OpenProblems.lean` (210 lines)
*Source: `Pythagorean/ThreeRoads/OpenProblems.lean`*

- **theorem**: `leg_product_strict_bound`, `leg_product_integer_bound`, `B2_product_growth`, `B2_hypotenuse_sq`, `B1_hyp_increase`, `euclid_sum_bounds_product`, ... +15 more

#### `ScalingTheorems.lean` (202 lines)
*Source: `Pythagorean/ThreeRoads/ScalingTheorems.lean`*

- **theorem**: `B3_preserves_pyth`, `B1_lorentz_form`, `B2_lorentz_form`, `B3_lorentz_form`, `B1_sieve_diff`, `B2_sieve_diff`, ... +35 more

### Pythagorean/TreeFactoring

*11 files, 409 declarations, 3,213 lines*

#### `Advanced.lean` (362 lines)
*Source: `Pythagorean/SharedFactor/Advanced.lean`*

- **theorem**: `triple_channel_product`, `channel_product_sum`, `cascade_opportunities`, `cross_rep_channel_gcd`, `three_way_cascade`, `three_way_cascade_sums`, ... +36 more

#### `NewTheorems.lean` (420 lines)
*Source: `Pythagorean/SharedFactor/NewTheorems.lean`*

- **structure**: `PythagoreanQuintuple`
- **def**: `quadNorm`, `repInnerProduct`
- **theorem**: `triple_channel_left_product`, `triple_channel_right_product`, `full_channel_product`, `channel_sum_eq_2d_sq`, `channel_determined`, `cross_channel_gcd_prime`, ... +35 more

#### `SharedFactorGeometry.lean` (234 lines)
*Source: `Pythagorean/SharedFactor/SharedFactorGeometry.lean`*

- **def**: `quaternionNorm`, `lorentzFormQ`
- **theorem**: `euler_four_square_identity`, `brahmagupta_fibonacci`, `brahmagupta_fibonacci_alt`, `two_reps_identity`, `sphere_point_pairing`, `sphere_cross_identity`, ... +21 more

#### `Core.lean` (179 lines)
*Source: `Pythagorean/TreeFactoring/Core.lean`*

- **def**: `findParent`, `factorDescent`
- **theorem**: `trivial_triple_is_pyth`, `diff_of_squares`, `divisor_pair_to_triple`, `inv_B1_preserves`, `inv_B2_preserves`, `inv_B3_preserves`, ... +12 more

#### `GeometricNavigation.lean` (195 lines)
*Source: `Pythagorean/TreeFactoring/GeometricNavigation.lean`*

- **def**: `zoneA`, `zoneB`, `zoneC`, `S_gen`, `T_gen`, `M₁_berg`, `M₃_berg`, `M₃_inv_berg`
- **theorem**: `zoneA_valid`, `zoneB_valid`, `zoneC_valid`, `zoneA_energy_decreases`, `zoneB_energy_decreases`, `zoneC_energy_decreases`, ... +16 more

#### `InversePythagoreanTree.lean` (372 lines)
*Source: `Pythagorean/TreeFactoring/InversePythagoreanTree.lean`*

- **structure**: `MinkowskiNullVector`
- **def**: `berggrenA`, `berggrenB`, `berggrenC`, `invBerggrenA`, `invBerggrenB`, `invBerggrenC`, ... +9 more
- **theorem**: `berggrenA`, `berggrenB`, `berggrenC`, `fundamental_triple`, `invA_after_A`, `invB_after_B`, ... +25 more

#### `LatticeTreeCorrespondence.lean` (364 lines)
*Source: `Pythagorean/TreeFactoring/LatticeTreeCorrespondence.lean`*

- **structure**: `PythTripleN`, `DivisorPairN`
- **def**: `berggren_M₁`, `berggren_M₃`, `berggren_M₁_inv`, `berggren_M₃_inv`, `FactorCongruence`, `InQuadLattice`, ... +4 more
- **theorem**: `berggren_M₁`, `berggren_M₃`, `berggren_M₁`, `berggren_M₃`, `lattice_tree_correspondence_M₃`, `lattice_tree_correspondence_M₁`, ... +34 more

#### `LatticeTreeDuality.lean` (340 lines)
*Source: `Pythagorean/TreeFactoring/LatticeTreeDuality.lean`*

- **def**: `berggrenM₁`, `berggrenM₃`, `berggrenM₁_inv`, `berggrenM₃_inv`, `normSq`, `dot2`, ... +3 more
- **theorem**: `berggrenM₁_det_one`, `berggrenM₃_det_one`, `berggrenM₁_right_inv`, `berggrenM₃_right_inv`, `berggrenM₁_left_inv`, `berggrenM₃_left_inv`, ... +33 more

#### `QuaternaryPythagoreanTree.lean` (365 lines)
*Source: `Pythagorean/TreeFactoring/QuaternaryPythagoreanTree.lean`*

- **structure**: `ArithPhoton`, `EmissionEvent`, `AbsorptionEvent`
- **inductive**: `QPath`
- **def**: `B₁`, `B₂`, `B₃`, `B₁`, `B₂`, `B₃`, ... +13 more
- **theorem**: `B₁`, `B₁`, `B₂`, `B₂`, `B₃`, `B₃`, ... +25 more

#### `SmoothDensity.lean` (163 lines)
*Source: `Pythagorean/TreeFactoring/SmoothDensity.lean`*

- **def**: `M₁_mat`, `M₂_mat`, `M₃_mat`, `IsSmooth`
- **theorem**: `tree_total_nodes`, `det_M₁_mat`, `det_M₂_mat`, `det_M₃_mat`, `M₁_trace`, `M₂_trace`, ... +14 more

#### `TetrabranchTree.lean` (219 lines)
*Source: `Pythagorean/TreeFactoring/TetrabranchTree.lean`*

- **inductive**: `TetraPath`
- **def**: `minkowskiQ`, `isNull`, `berggrenM₁`, `berggrenM₂`, `berggrenM₃`, `berggrenParent`, `tetraEval`
- **theorem**: `M₁_preserves_null`, `M₂_preserves_null`, `M₃_preserves_null`, `parent_preserves_null`, `all_branches_preserve_minkowski`, `parent_inverse_M₂`, ... +5 more

### ShefferAI

*5 files, 79 declarations, 729 lines*

#### `AdvancedTheorems.lean` (245 lines)
*Source: `ShefferAI/Lean/AdvancedTheorems.lean`*

- **def**: `softplus_iter`
- **theorem**: `softplus_iter_pos`, `softplus_iter_strictMono`, `softplus_iter_mem_sheffer`, `logisticSigmoid_differentiable`, `sigmoid_deriv_eq`, `softplus_subadditive_nonneg`, ... +15 more

#### `FutureTheorems.lean` (172 lines)
*Source: `ShefferAI/Lean/FutureTheorems.lean`*

- **def**: `softplus_temp`
- **theorem**: `sheffer_depth_comp_le`, `sheffer_composition_depth_bound`, `softplus_tendsto_zero_atBot`, `softplus_not_polynomial`, `softplus_lipschitz`, `sigmoid_complement`, ... +13 more

#### `ShefferAlgebra.lean` (111 lines)
*Source: `ShefferAI/Lean/ShefferAlgebra.lean`*

- **inductive**: `ShefferExpr`
- **def**: `ShefferExpr`, `ShefferExpr`, `ShefferExpr`, `ShefferAlgebra`
- **noncomp. def**: `shefferDegree`
- **theorem**: `softplus_mem_sheffer`, `sheffer_affine_pre_closed`, `sheffer_affine_comb_closed`, `sheffer_comp_closed`, `const_mem_sheffer`, `id_mem_sheffer`

#### `SoftplusBasic.lean` (149 lines)
*Source: `ShefferAI/Lean/SoftplusBasic.lean`*

- **def**: `softplus`, `logisticSigmoid`
- **theorem**: `softplus_pos`, `softplus_strictMono`, `softplus_mono`, `softplus_gt_id`, `softplus_differentiable`, `softplus_deriv`, ... +6 more
- **lemma**: `one_plus_exp_pos`, `one_plus_exp_gt_one`, `logisticSigmoid_pos`, `logisticSigmoid_lt_one`, `logisticSigmoid_mem_Ioo`

#### `UniversalApproximation.lean` (52 lines)
*Source: `ShefferAI/Lean/UniversalApproximation.lean`*

- **structure**: `Depth1ShefferExpr`
- **def**: `Depth1ShefferExpr`
- **theorem**: `softplus_separates_points`, `softplus_nonvanishing`, `softplus_continuous`, `softplus_family_continuous`

### Speculative/ArithmeticUniverse

*5 files, 36 declarations, 428 lines*

#### `Assembly.lean` (47 lines)
*Source: `Speculative/ArithmeticUniverse/Assembly.lean`*

- **def**: `assembleOracleOfDivisibility`, `assembleOracleOfSums`
- **noncomp. def**: `assembleOracleOfPrimes`, `assembleOracleOfCongruences`, `assembleOracleOfDiophantine`, `theOracleCouncil`

#### `DeepStructure.lean` (126 lines)
*Source: `Speculative/ArithmeticUniverse/DeepStructure.lean`*

- **theorem**: `oracle_wilson`, `oracle_divisor_count_multiplicative`, `oracle_totient_multiplicative`, `oracle_totient_sum`, `oracle_euler_theorem`, `oracle_primes_3_mod_4`, `oracle_mobius_sum`

#### `FibonacciArithmetic.lean` (85 lines)
*Source: `Speculative/ArithmeticUniverse/FibonacciArithmetic.lean`*

- **theorem**: `fib_mono`, `fib_recurrence`, `fib_dvd_of_dvd`, `fib_gcd`, `euclid_pythagorean`, `mediant_between`, ... +3 more

#### `Foundations.lean` (97 lines)
*Source: `Speculative/ArithmeticUniverse/Foundations.lean`*

- **theorem**: `oracle_primes_infinite`, `oracle_primes_irreducible`, `oracle_sums_gauss`, `oracle_congruences_fermat`, `oracle_divisibility_bezout`, `oracle_sums_squares`, `oracle_gcd_divides`, `oracle_exists_prime_divisor`

#### `OracleCouncil.lean` (73 lines)
*Source: `Speculative/ArithmeticUniverse/OracleCouncil.lean`*

- **structure**: `OracleOfPrimes`, `OracleOfDivisibility`, `OracleOfCongruences`, `OracleOfSums`, `OracleOfDiophantine`, `OracleCouncil`

### Speculative/Consciousness

*7 files, 122 declarations, 913 lines*

#### `CayleyDicksonLadder.lean` (140 lines)
*Source: `Speculative/Consciousness/CayleyDicksonLadder.lean`*

- **structure**: `ConsciousnessLevel`, `AwarenessEmbedding`
- **inductive**: `AlgebraicProperty`
- **def**: `cayleyDicksonDim`, `propertiesAtLevel`, `phaseAwareness`, `awarenessRefl`, `awarenessComp`
- **theorem**: `dim_doubles`, `dim_exponential`, `properties_decrease_0`, `properties_decrease_1`, `properties_decrease_2`, `properties_decrease_3`, ... +6 more

#### `FixedPointTheory.lean` (173 lines)
*Source: `Speculative/Consciousness/FixedPointTheory.lean`*

- **structure**: `SelfModelingSystem`, `BoundedDepthSystem`, `ConsciousnessHierarchy`
- **def**: `SelfModelingSystem`, `SelfModelingSystem`, `leastConsciousState`, `iterReflect`
- **theorem**: `consciousness_fixed_point_lawvere`, `consciousness_exists_from_surjection`, `consciousness_lattice_fixed_point`, `least_conscious_is_fixed`, `least_conscious_is_least`, `no_perfect_self_model`, ... +5 more

#### `InformationTheoreticDepth.lean` (147 lines)
*Source: `Speculative/Consciousness/InformationTheoreticDepth.lean`*

- **structure**: `SystemPartition`, `SelfRefInfo`, `ConsciousnessThreshold`
- **def**: `shannonEntropy`, `integratedInformation`, `SelfRefInfo`, `isConscious`, `selfRefTower`
- **theorem**: `pigeonhole_description`, `shannonEntropy_nonneg`, `phi_nonneg`, `SelfRefInfo`, `SelfRefInfo`, `combined_conscious`, `selfRefTower_unbounded`, `selfRefTower_bounded_stabilizes`

#### `MobiusSelfObservation.lean` (91 lines)
*Source: `Speculative/Consciousness/MobiusSelfObservation.lean`*

- **structure**: `MobiusTrans`, `BinocularSelfObserver`
- **def**: `MobiusTrans`, `MobiusTrans`, `MobiusTrans`, `MobiusTrans`, `crossRatio`, `BinocularSelfObserver`, ... +3 more
- **theorem**: `mobius_fixed_point_equation`, `depth_zero_when_identical`, `id_preserves_awareness`

#### `SelfReferentialTheories.lean` (133 lines)
*Source: `Speculative/Consciousness/SelfReferentialTheories.lean`*

- **structure**: `QuineSystem`, `SelfJustifyingSystem`, `AutopoieticSystem`, `BootstrapLoop`, `SelfReferentialConsciousness`
- **def**: `QuineSystem`, `SelfJustifyingSystem`, `AutopoieticSystem`, `SelfReferentialConsciousness`, `liarsStaircase`
- **theorem**: `quine_fixed_point`, `autopoietic_fixed_point`, `bootstrap_periodic`, `conscious_states_justified`, `liars_staircase_alternates`, `liars_staircase_even`, `liars_staircase_odd`

#### `StrangeLoopAlgebra.lean` (125 lines)
*Source: `Speculative/Consciousness/StrangeLoopAlgebra.lean`*

- **structure**: `StrangeLoop`, `TangledHierarchy`, `SelfRef`, `GodelHofstadterLoop`, `CategoricalConsciousness`, `CategoricalStrangeLoop`
- **def**: `StrangeLoop`, `StrangeLoop`, `strangeLoopPerm`, `TangledHierarchy`, `addLayer`, `GodelHofstadterLoop`
- **theorem**: `StrangeLoop`, `StrangeLoop`, `addLayer_depth_increases`, `strange_loop_composition_fixed_point`, `godel_unprovable`

#### `TropicalConsciousness.lean` (104 lines)
*Source: `Speculative/Consciousness/TropicalConsciousness.lean`*

- **structure**: `TropicalReflector`
- **def**: `tropAdd`, `tropMul`, `tropZero`, `tropOne`, `TropicalMatrix`, `tropMatVecMul`, ... +5 more
- **theorem**: `tropAdd_comm`, `tropAdd_assoc`, `tropMul_comm`, `tropAdd_zero`, `tropMul_one`, `subset_tropConvexHull`, `tropicalDist_symm`, `tropicalDist_self`

### Speculative/Forbidden

*11 files, 95 declarations, 1,943 lines*

#### `AlgorithmicEvil.lean` (216 lines)
*Source: `Speculative/Forbidden/AlgorithmicEvil.lean`*

- **def**: `ackermann`
- **theorem**: `ackermann_strict_mono_right`, `ackermann_gt_right`, `ackermann_zero`, `ackermann_one`, `pigeonhole_evil`, `birthday_collision`, `infinite_pigeonhole`, `involution_odd_fixed_point`

#### `Area51.lean` (168 lines)
*Source: `Speculative/Forbidden/Area51.lean`*

- **theorem**: `euclid_infinitude`, `prime_gap_arbitrarily_large`, `wilson_forward`, `fermat_little`, `div3_digit_sum`, `div9_digit_sum`, ... +3 more

#### `BrokenMirror.lean` (186 lines)
*Source: `Speculative/Forbidden/BrokenMirror.lean`*

- **structure**: `Mirror`
- **def**: `Mirror`, `Mirror`
- **theorem**: `broken_mirror_odd_fixed_point`, `mirror_shattered_even`, `cantor_broken_mirror`, `diagonal_shattering`, `discrete_ivt`, `no_perfect_self_mirror`, `involution_parity_fixed`

#### `CantorsDiabolicalDiagonal.lean` (150 lines)
*Source: `Speculative/Forbidden/CantorsDiabolicalDiagonal.lean`*

- **def**: `antiDiagonal`
- **theorem**: `cantor_no_surjection`, `antiDiagonal_not_in_range`, `naturals_inject_but_cannot_surject`, `injection_to_powerset`, `powerset_strictly_dominates`, `diagonal_defeats_enumeration`

#### `ForbiddenConvergence.lean` (152 lines)
*Source: `Speculative/Forbidden/ForbiddenConvergence.lean`*

- **theorem**: `geometric_series_rational`, `grandi_partial_sums`, `telescoping_sum`, `partial_fractions_sum`, `harmonic_lower_bound`, `sum_first_n`, ... +3 more

#### `SelfDefeatingOracle.lean` (149 lines)
*Source: `Speculative/Forbidden/SelfDefeatingOracle.lean`*

- **theorem**: `no_complete_oracle_catalog`, `diagonal_adversary_defeats_all`, `lawvere_fixed_point`, `no_surjection_to_arrow_prop`, `halting_diagonal_surjection`, `constructive_fixed_point`

#### `StrangeLoops.lean` (146 lines)
*Source: `Speculative/Forbidden/StrangeLoops.lean`*

- **def**: `IsIdempotent`
- **theorem**: `finite_function_has_cycle`, `finite_periodic_point`, `min_period_divides`, `descending_chain_fixed_point`, `contraction_converges`, `idempotent_image_eq_fixed`, ... +4 more

#### `TheForbiddenTheorem.lean` (188 lines)
*Source: `Speculative/Forbidden/TheForbiddenTheorem.lean`*

- **theorem**: `russells_catastrophe`, `russell_diagonal_contradiction`, `compression_must_fail`, `incompressible_strings_exist`, `the_forbidden_theorem`, `evil_is_constructive`, `liar_cannot_exist`, `tarski_undefinability`

#### `TheMatrix.lean` (174 lines)
*Source: `Speculative/Forbidden/TheMatrix.lean`*

- **theorem**: `matrix_reality_criterion`, `trace_sq_symmetric`, `commutator_traceless`, `cayley_hamilton_1x1`, `det_composition`, `idempotent_trace_eq_rank_nat`, `det_transpose_eq`, `trace_additive`

#### `TwilightZone.lean` (182 lines)
*Source: `Speculative/Forbidden/TwilightZone.lean`*

- **theorem**: `hilbert_hotel`, `cantor_twilight`, `power_set_strictly_larger`, `choice_gives_sections`, `no_liar`, `rationals_dense`, ... +4 more

#### `TwistedMathematics.lean` (232 lines)
*Source: `Speculative/Forbidden/TwistedMathematics.lean`*

- **noncomp. def**: `evil_well_order`
- **theorem**: `well_ordering_exists`, `drinkers_paradox`, `schroder_bernstein`, `not_all_sets_measurable`, `hilbert_hotel_one_guest`, `hilbert_hotel_countable`, `nat_self_similar`

### Speculative/IdempotentCollapse

*14 files, 187 declarations, 1,885 lines*

#### `CategoryCollapse.lean` (69 lines)
*Source: `Speculative/IdempotentCollapse/CategoryCollapse.lean`*

- **structure**: `KaroubiElement`
- **def**: `KaroubiElement`
- **theorem**: `idempotent_comp_closed`, `idempotent_sq`, `idempotent_pow`, `karoubi_compose`, `idempotent_decomp`

#### `ClosureCollapse.lean` (139 lines)
*Source: `Speculative/IdempotentCollapse/ClosureCollapse.lean`*

- **structure**: `ClosureOp`
- **def**: `ClosureOp`
- **theorem**: `topological_closure_idempotent`, `interior_idempotent`, `convex_hull_idempotent`, `span_idempotent`, `ClosureOp`, `ClosureOp`, ... +4 more

#### `ComputationalCollapse.lean` (150 lines)
*Source: `Speculative/IdempotentCollapse/ComputationalCollapse.lean`*

- **structure**: `MemoTable`, `Normalizer`
- **def**: `Normalizer`
- **theorem**: `sort_idempotent`, `abs_idempotent`, `min_self_idempotent`, `memo_lookup_idempotent`, `normalizer_equiv_refl`, `normalizer_equiv_symm`, ... +8 more

#### `Core.lean` (175 lines)
*Source: `Speculative/IdempotentCollapse/Core.lean`*

- **def**: `Idempotent`, `IsOracle`
- **theorem**: `idempotent_image_eq_fixed`, `idempotent_fixes_image`, `idempotent_iterate_eq`, `idempotent_comp_comm`, `idempotent_id`, `idempotent_const`, ... +11 more

#### `FixedPointCollapse.lean` (142 lines)
*Source: `Speculative/IdempotentCollapse/FixedPointCollapse.lean`*

- **theorem**: `limit_of_iteration_idempotent`, `monotone_idempotent_determined_by_fixed`, `monotone_iterate_stabilizes`, `kleene_fixed_point_exists`, `contraction_total_collapse`, `idempotent_instant_convergence`

#### `InformationCollapse.lean` (130 lines)
*Source: `Speculative/IdempotentCollapse/InformationCollapse.lean`*

- **def**: `quantize`
- **theorem**: `int_floor_idempotent`, `floor_idempotent`, `ceil_idempotent`, `quantize_on_grid`, `idempotent_image_card_le`, `idempotent_full_image_is_id`, ... +3 more

#### `MasterEquationComputation.lean` (167 lines)
*Source: `Speculative/IdempotentCollapse/MasterEquationComputation.lean`*

- **theorem**: `list_dedup_idempotent`, `multiset_dedup_idempotent`, `closure_operator_idempotent`, `topological_closure_idempotent`, `orthogonal_projection_idempotent`, `normalization_idempotent_iff`, ... +10 more

#### `NeuralCollapse.lean` (95 lines)
*Source: `Speculative/IdempotentCollapse/NeuralCollapse.lean`*

- **def**: `collapseMap`
- **theorem**: `centroid_projection_idempotent`, `etf_angle_negative`, `full_collapse_zero_variance`, `collapse_map_stable`, `collapse_degree_bounds`

#### `NewHypotheses.lean` (180 lines)
*Source: `Speculative/IdempotentCollapse/NewHypotheses.lean`*

- **def**: `idempotentCount`, `IsIdempotent`, `relu`, `tropAdd`, `gaussBinom`
- **theorem**: `idem_count_2`, `idem_count_3`, `idem_count_6`, `idem_count_30`, `idem_count_210`, `maslov_lower`, ... +13 more

#### `OptimalCollapse.lean` (63 lines)
*Source: `Speculative/IdempotentCollapse/OptimalCollapse.lean`*

- **def**: `collapseDisplacement`
- **theorem**: `zero_displacement_is_id`, `collapse_transport_bound`, `idempotent_range_inclusion`

#### `QuantumCollapse.lean` (121 lines)
*Source: `Speculative/IdempotentCollapse/QuantumCollapse.lean`*

- **structure**: `QProjection`, `PVM`
- **theorem**: `complementary_is_idempotent`, `image_eq_fixed`, `norm_le`, `pythagorean`, `post_measurement_stable`, `iterate_eq_self`, `born_probabilities_sum`, `decoherence_is_idempotent`

#### `SpaceAlgebraRosetta.lean` (164 lines)
*Source: `Speculative/IdempotentCollapse/SpaceAlgebraRosetta.lean`*

- **theorem**: `rosetta_row1_point_is_prime_ideal`, `rosetta_row2_element_gives_open`, `rosetta_row2_basic_opens_are_basis`, `rosetta_row3_ring_hom_gives_continuous_map`, `rosetta_row4_ideal_gives_closed`, `rosetta_row5_krull_dim_eq_spec_dim`, ... +11 more

#### `TheoreticalExtensions.lean` (228 lines)
*Source: `Speculative/IdempotentCollapse/TheoreticalExtensions.lean`*

- **structure**: `CollapseFunction`, `RGFlow`, `MassGap`
- **def**: `IsIdempotent`, `FixedPointSet`, `idCollapse`, `constCollapse`, `criticalLineProjection`, `zetaReflection`, `RGFixedPoint`, `BoolGateIdempotent`
- **theorem**: `idem_image_eq_fixed`, `idem_iterate`, `collapse_image_eq_fixed`, `criticalLineProjection_idempotent`, `criticalLine_fixed_points`, `RH_via_fixed_points`, ... +14 more

#### `TopologicalCollapse.lean` (62 lines)
*Source: `Speculative/IdempotentCollapse/TopologicalCollapse.lean`*

- **structure**: `Retraction`
- **def**: `retraction_fiber`
- **theorem**: `retraction_idempotent`, `retraction_range`, `idempotent_almost_identity`, `collapse_is_id_on_image`, `fiber_partition`, `fixed_point_in_fiber`

### Speculative/Millennium

*6 files, 87 declarations, 971 lines*

#### `Foundations.lean` (261 lines)
*Source: `MillenniumResearch/Foundations.lean`*

- **structure**: `surrounding`
- **def**: `collatz`, `collatzIter`, `isBrocardSolution`, `isErdosStrausDecomp`
- **theorem**: `critical_line_implies_unit_disk`, `li_positivity_from_critical_line`, `trace_eq_sum_diagonal`, `real_symmetric_eigenvalue_real`, `cantor_diagonal_bool`, `padding_time_reduction`, ... +20 more

#### `EllipticCurves.lean` (144 lines)
*Source: `Speculative/Millennium/EllipticCurves.lean`*

- **def**: `countSolutionsMod`, `ellipticDiscriminant`, `isEllipticCurve`
- **theorem**: `curve_minus_x_is_elliptic`, `curve_minus_one_is_elliptic`, `trivial_point_bound`, `harmonic_partial_sum_bound`, `rank_nonneg`, `fg_subgroup_of_fg`

#### `MillenniumFrontier.lean` (270 lines)
*Source: `Speculative/Millennium/MillenniumFrontier.lean`*

- **def**: `collatz`
- **theorem**: `goldbach_small`, `prime_between_2_4`, `legendre_n1`, `legendre_n2`, `legendre_n3`, `collatz_one`, ... +16 more

#### `NavierStokes.lean` (93 lines)
*Source: `Speculative/Millennium/NavierStokes.lean`*

- **theorem**: `young_inequality`, `energy_nonneg`, `cauchy_schwarz_fin`, `vorticity_linfty_bound_2d`, `gronwall_bound`, `scaling_exponent_3d`, `scaling_exponent_2d`, `bkm_simplified`

#### `PvsNP.lean` (82 lines)
*Source: `Speculative/Millennium/PvsNP.lean`*

- **structure**: `WitnessProblem`, `NPProblem`
- **def**: `DecisionProblem`
- **theorem**: `witness_enumeration_finite`, `binary_strings_count`, `poly_compose`, `brute_force_decides`

#### `Topology.lean` (121 lines)
*Source: `Speculative/Millennium/Topology.lean`*

- **theorem**: `real_simply_connected`, `simply_connected_of_trivial_pi1`, `euler_char_sphere`, `euler_char_torus`, `euler_char_from_betti_sphere`, `euler_char_k3`, ... +3 more

### Speculative/Other

*76 files, 1949 declarations, 16,917 lines*

#### `QuantumPhaseLattice.lean` (216 lines)
*Source: `ECSTASIS/QuantumPhaseLattice.lean`*

- **theorem**: `quantum_phase_lattice_is_complete_lattice`, `superposition_norm_bound`, `superposition_norm_bound_finset`, `born_rule_nonneg`, `born_rule_cauchy_schwarz`, `born_probability_le_one`, ... +13 more

#### `QuantumPhaseLatticeExtended.lean` (288 lines)
*Source: `ECSTASIS/QuantumPhaseLatticeExtended.lean`*

- **theorem**: `orthogonal_complement_antimono`, `double_orthogonal_eq`, `orthogonal_complement_spans_top`, `orthogonal_complement_disjoint`, `orthomodular_law`, `orthogonal_complement_sup`, ... +14 more

#### `GeodesicLLM.lean` (137 lines)
*Source: `GeodesicIntelligence/GeodesicLLM.lean`*

- **theorem**: `cramer_rao_motivation`, `geodesic_speedup`, `tropical_is_zero_temp_limit`, `conformal_factor_upper`, `conformal_factor_pos`, `spherical_compression_ratio`, ... +8 more

#### `Bridges.lean` (237 lines)
*Source: `Speculative/CrossDomain/Bridges.lean`*

- **structure**: `MathBridge`, `TropicalLFunction`
- **def**: `IsIdempotent`, `relu`, `repulsionProduct`, `coulombEnergyFinite`, `confiningEnergyFinite`, `composeBridges`, ... +4 more
- **theorem**: `master_equation_general`, `idempotent_mul_comm`, `idempotent_join_comm`, `idempotent_complement`, `peirce_decomp`, `tropical_add_idempotent`, ... +12 more

#### `CategoricalBridges.lean` (188 lines)
*Source: `Speculative/CrossDomain/CategoricalBridges.lean`*

- **structure**: `MathBridge`, `BridgeInvariant`, `AnalysisBridge`, `AutomorphicOracle`
- **inductive**: `BridgeLevel`
- **def**: `identityBridge`, `composeBridges`, `isBridgeEquivalence`, `bridgeSubsumes`
- **theorem**: `hott_subsumes_all`, `analysis_bridge_unique`, `riemann_sum_bridge`, `langlands_bridge_preserves_L`, `type_prop_bridge`

#### `ChipFiringJacobian.lean` (138 lines)
*Source: `Speculative/CrossDomain/ChipFiringJacobian.lean`*

- **def**: `divisorDegree`, `isPrincipal`, `linearEquiv`, `chipFire`, `canonicalDivisor`, `graphGenus`
- **theorem**: `linearEquiv_refl`, `linearEquiv_symm`, `linearEquiv_trans`, `principal_degree_zero`, `chipFire_equiv`, `canonical_degree`, `kirchhoff_cofactor_independence`, `harmonic_jacobian_correspondence`

#### `IharaZeta.lean` (149 lines)
*Source: `Speculative/CrossDomain/IharaZeta.lean`*

- **structure**: `IharaGraph`
- **def**: `IharaGraph`, `IharaGraph`, `IharaGraph`, `IharaGraph`, `iharaMatrix`, `IharaGraph`, ... +3 more
- **theorem**: `IharaGraph`, `ihara_matrix_regular`, `regular_graph_eigenvalue_bound`, `regular_graph_edges`, `laplacian_zero_eigenvalue`

#### `KaroubiIdempotent.lean` (170 lines)
*Source: `Speculative/CrossDomain/KaroubiIdempotent.lean`*

- **structure**: `HeckeElement`
- **def**: `AreOrthogonalIdempotents`, `IsCompleteIdempotentSystem`, `isHeckeIdempotent`
- **theorem**: `idem_complement`, `orthogonal_complement`, `trivial_complete_system`, `diagonal_01_idempotent`, `heckeIdentity_idempotent`, `tl_delta2_idempotent`, ... +4 more

#### `NewTheorems.lean` (312 lines)
*Source: `Speculative/CrossDomain/NewTheorems.lean`*

- **structure**: `CompleteOrthogonalSystem`, `MathBridge`, `KaroubiObj`, `KaroubiHom`
- **def**: `idempotentCount`, `IsIdem`, `trivialSystem`, `reluFn`, `vandermondeProd`, `gueJointDensity`, ... +8 more
- **theorem**: `idempotent_count_2`, `idempotent_count_3`, `idempotent_count_4`, `idempotent_count_5`, `idempotent_count_6`, `idempotent_count_10`, ... +35 more

#### `CrossDomainSynthesis.lean` (333 lines)
*Source: `Speculative/Exploration/CrossDomainSynthesis.lean`*

- **def**: `minkQ`, `isNull`, `signOracle`, `causalOracle`, `tropAdd`, `tropGCDOracle`, ... +4 more
- **theorem**: `null_scale`, `zero_is_null`, `minkQ_homogeneous`, `causal_trichotomy`, `signOracle_values`, `tropAdd_idem`, ... +29 more

#### `CrystallizerFormalization.lean` (222 lines)
*Source: `Speculative/Exploration/CrystallizerFormalization.lean`*

- **def**: `crystallizationLoss`, `inner2`, `normSq2`, `gramSchmidtProj`
- **theorem**: `stereo_fundamental_identity`, `stereo_proj_nd_unit_norm`, `stereo_denom_nonneg`, `stereo_denom_pos_of_nonzero`, `crystallization_nonneg`, `crystallization_bounded`, ... +11 more

#### `CrystallizerFrontier.lean` (506 lines)
*Source: `Speculative/Exploration/CrystallizerFrontier.lean`*

- **def**: `pythag_form`
- **noncomp. def**: `inv_stereo`
- **theorem**: `weierstrass_cos`, `weierstrass_sin`, `stereo_inv_stereo_fst`, `stereo_inv_stereo_snd`, `berggren_A_preserves_form`, `berggren_B_preserves_form`, ... +29 more

#### `CrystallizerMath.lean` (226 lines)
*Source: `Speculative/Exploration/CrystallizerMath.lean`*

- **noncomp. def**: `stereo_proj`
- **theorem**: `pythagorean_trig_identity`, `pythagorean_trig_identity`, `stereo_proj_on_circle`, `gram_schmidt_orthogonal_inner`, `tri_resonant_norm_sq`, `sin_pi_int`, ... +12 more

#### `DeepConnections.lean` (268 lines)
*Source: `Speculative/Exploration/DeepConnections.lean`*

- **structure**: `PellSolution`
- **def**: `PellSolution`, `PellSolution`
- **noncomp. def**: `chebyT`
- **theorem**: `chebyT_zero`, `chebyT_one`, `chebyT_degree`, `chebyT_comp`, `pell_compose_assoc`, `pell_compose_trivial_left`, ... +4 more

#### `DeepResults.lean` (218 lines)
*Source: `Speculative/Exploration/DeepResults.lean`*

- **def**: `eulerCharSfc`
- **theorem**: `totient_sum`, `totient_mul_coprime`, `totient_prime`, `totient_prime_sq`, `mobius_1`, `mobius_2`, ... +49 more

#### `DickianMath.lean` (233 lines)
*Source: `Speculative/Exploration/DickianMath.lean`*

- **theorem**: `dickian_fixed_point_exists`, `black_iron_prison_unique`, `ubik_collapse_time_formula`, `ubik_stabilizer_formula`, `connected_image_connected`, `no_retraction_to_disconnected`, ... +5 more

#### `EnergyDescentResearch.lean` (497 lines)
*Source: `Speculative/Exploration/EnergyDescentResearch.lean`*

- **noncomp. def**: `iofEnergy`
- **theorem**: `iofEnergy_nonneg`, `iofEnergy_zero`, `iofEnergy_strict_decrease`, `iofEnergy_drop`, `iofEnergy_drop_pos`, `iofEnergy_closed_form`, ... +40 more

#### `Experiments.lean` (155 lines)
*Source: `Speculative/Exploration/Experiments.lean`*


#### `Experiments2.lean` (183 lines)
*Source: `Speculative/Exploration/Experiments2.lean`*

- **def**: `fib`, `ilog2`, `isPrime`, `hasBadFactor`

#### `FrontierResearch.lean` (219 lines)
*Source: `Speculative/Exploration/FrontierResearch.lean`*

- **def**: `η`, `B₁`, `B₂`, `B₃`, `isBrightPrime`, `isDarkPrime`, ... +7 more
- **theorem**: `B1_lorentz`, `B2_lorentz`, `B3_lorentz`, `B1_det`, `B2_det`, `B3_det`, ... +26 more

#### `FrontierTheorems.lean` (295 lines)
*Source: `Speculative/Exploration/FrontierTheorems.lean`*

- **def**: `leg_swap`
- **theorem**: `fibonacci_pythagorean_345`, `fibonacci_pythagorean_51213`, `fibonacci_pythagorean_general`, `pyth_3_dvd_ab`, `pyth_2_dvd_ab`, `pyth_6_dvd_ab`, ... +34 more

#### `FutureResearch.lean` (658 lines)
*Source: `Speculative/Exploration/FutureResearch.lean`*

- **def**: `B₁`, `B₂`, `B₃`, `Q_lor`
- **theorem**: `fibonacci_pythagorean_identity`, `fib_square_recurrence`, `berggren_M1_fibonacci_action`, `fibonacci_double_square`, `trace_B₁`, `trace_B₂`, ... +42 more

#### `GapMatterResearch.lean` (554 lines)
*Source: `Speculative/Exploration/GapMatterResearch.lean`*

- **def**: `stokesMinkowskiForm`, `isNull`, `isTimelike`, `degreeOfPolarization`
- **theorem**: `photon_addresses_measure_zero`, `gaps_have_full_measure`, `gap_contains_no_photon`, `gap_is_uncountable`, `mixing_creates_mass`, `null_sphere_has_measure_zero`, ... +26 more

#### `IntegerEnergy.lean` (241 lines)
*Source: `Speculative/Exploration/IntegerEnergy.lean`*

- **def**: `abundanceRatio`, `IsHighlyComposite`, `iofEnergyZ`, `arithmeticDerivative`, `IsSuperabundant`
- **theorem**: `sigma_one_prime`, `abundanceRatio_prime`, `prime_divisor_count`, `abundanceRatio_ge_one`, `divisors_six`, `divisors_twelve`, ... +29 more

#### `LKTExperiments.lean` (248 lines)
*Source: `Speculative/Exploration/LKTExperiments.lean`*

- **structure**: `BlochVector`, `LKTState`
- **def**: `vonNeumannEntropy2`, `BlochVector`, `knowledgeContent`, `qubitTableSize`, `measurementInfoGain`, `totalTableInfo`, ... +7 more
- **theorem**: `BlochVector`, `BlochVector`, `tomographic_lower_bound`, `cramer_rao_tomography`, `mutualInfoDecay_nonneg`, `mutualInfoDecay_mono`, ... +10 more

#### `LandscapeTheory.lean` (277 lines)
*Source: `Speculative/Exploration/LandscapeTheory.lean`*

- **def**: `allRightTriple`, `allRightPredicted`, `allRightOddLeg`
- **noncomp. def**: `conformalFactor`, `stereoParam`, `invStereoX`, `invStereoY`
- **theorem**: `allRightPredicted_pyth`, `allRightOddLeg_factors`, `allRight_base`, `allRight_depth1`, `allRight_depth2`, `pyth_fermat_factorization`, ... +31 more

#### `MathBiology.lean` (35 lines)
*Source: `Speculative/Exploration/MathBiology.lean`*

- **theorem**: `logistic_fp`, `logistic_stab`, `lv_fp`, `sir_cons`, `herd_imm`, `hd_ess`

#### `MathExplorations.lean` (262 lines)
*Source: `Speculative/Exploration/MathExplorations.lean`*

- **def**: `lorentz_inner`
- **theorem**: `prime_mod_four`, `wilson_theorem`, `pell_equation_small`, `pell_equation_next`, `pell_recurrence`, `pell_matrix_det`, ... +41 more

#### `MetaOracleHypotheses.lean` (239 lines)
*Source: `Speculative/Exploration/MetaOracleHypotheses.lean`*

- **def**: `isErdosStrausDecomp`, `constellationRigidity`
- **noncomp. def**: `goldbachRepCount`, `fracDist`, `lonelyRunnerBound`, `primeCount`
- **theorem**: `lonely_runner_two`, `erdos_straus_three`, `erdos_straus_five`, `erdos_straus_seven`, `erdos_straus_even`, `primeCount_le`, ... +7 more

#### `MillenniumConnections.lean` (144 lines)
*Source: `Speculative/Exploration/MillenniumConnections.lean`*

- **theorem**: `elliptic_discriminant_En`, `En_2_torsion`, `ppt_to_En_point`, `nagell_lutz_discriminant`, `sum_two_squares_mod4`, `hypotenuse_prime_iff_1mod4`, ... +7 more

#### `MillenniumDeep.lean` (30 lines)
*Source: `Speculative/Exploration/MillenniumDeep.lean`*

- **theorem**: `prime_count_100`, `prime_count_1000`, `factoring_in_np`, `clebsch_gordan_dims`, `serrin_exponents`, `ricci_fixed_point_s2`, `iof_millennium_connections`

#### `MillenniumProblems.lean` (77 lines)
*Source: `Speculative/Exploration/MillenniumProblems.lean`*

- **def**: `sat_formula`, `prime_count`, `genus_plane_curve`, `euler_char_surface`
- **theorem**: `sat_formula_satisfiable`, `sat_assignments`, `euler_product_first_factor`, `euler_product_second_factor`, `euler_product_third_factor`, `prime_count_10`, ... +16 more

#### `MoonshotExplorations.lean` (607 lines) ⚠️ 1 sorry
*Source: `Speculative/Exploration/MoonshotExplorations.lean`*

- **def**: `isSumTwoSquares`, `S_mat`, `T_mat`, `pythMap`, `frobenius_sq`
- **theorem**: `five_sum_two_squares`, `thirteen_sum_two_squares`, `fermat_christmas_instances`, `norm_multiplicative`, `sum_two_sq_mul_closed`, `sixty_five_sum_two_squares`, ... +72 more

#### `MoonshotResearch.lean` (333 lines)
*Source: `Speculative/Exploration/MoonshotResearch.lean`*

- **def**: `harmonicQ`, `parityB`, `isCongrWitness`, `casimirVal`, `bettiP`, `hK3`, ... +15 more
- **theorem**: `harmonicQ`, `harmonicQ`, `harmonicQ`, `euler_zeta2_partial`, `pi_bound`, `pi_100`, ... +78 more

#### `NewDirections.lean` (187 lines)
*Source: `Speculative/Exploration/NewDirections.lean`*

- **def**: `fib_local`, `IsSumTwoSq`, `cf_step_mat`, `norm_sqrt2`
- **theorem**: `cassini_identity`, `brahmagupta_fibonacci_id`, `sum_two_sq_mul`, `three_not_sum_two_sq`, `euler_four_square`, `wilson_5`, ... +21 more

#### `NewExperiments.lean` (169 lines)
*Source: `Speculative/Exploration/NewExperiments.lean`*

- **def**: `countSumTwoSq`, `zeroOracle`, `idOracle`, `mod2Oracle4`, `subsetOracle`
- **theorem**: `count_sum_two_sq_0`, `count_sum_two_sq_1`, `count_sum_two_sq_2`, `count_sum_two_sq_5`, `count_sum_two_sq_25`, `count_sum_two_sq_3`, ... +20 more

#### `NewExplorations.lean` (270 lines)
*Source: `Speculative/Exploration/NewExplorations.lean`*

- **def**: `eisensteinNorm`
- **theorem**: `mediant_between`, `stern_brocot_det`, `cf_bezout`, `quad_residues_mod5`, `quad_residues_mod7`, `sum_two_sq_5`, ... +46 more

#### `NewHypotheses.lean` (126 lines)
*Source: `Speculative/Exploration/NewHypotheses.lean`*

- **theorem**: `critical_line_connection`, `oracle_composition_closure`, `oracle_composition_fixed_points`, `stereo_rationality`, `stereo_inv_rationality`, `oracle_fixed_point_intersection`, ... +4 more

#### `NewHypothesesResearch.lean` (247 lines)
*Source: `Speculative/Exploration/NewHypothesesResearch.lean`*

- **def**: `idemCount`, `idempotent_entropy`
- **theorem**: `idem_meet_idempotent`, `idem_meet_fixed`, `tropical_universal_idempotent`, `tropical_no_cancellation`, `tropical_zero_test`, `tropical_peirce`, ... +16 more

#### `NewTheorems.lean` (192 lines)
*Source: `Speculative/Exploration/NewTheorems.lean`*

- **theorem**: `ppt_sum_of_sides`, `ppt_c_gt_a`, `ppt_c_gt_b`, `pyth_product_even`, `sum_of_legs_sq`, `diff_of_legs_sq`, ... +13 more

#### `QuantumECCGateInversion.lean` (166 lines)
*Source: `Speculative/Exploration/QuantumECCGateInversion.lean`*

- **def**: `PauliX`, `PauliZ`, `PauliXZ`, `secp256k1_a_param`, `secp256k1_b_param`, `secp256k1_order`, ... +4 more
- **theorem**: `pauliX_sq`, `pauliZ_sq`, `pauli_XZ_anticommute`, `pauli_XZ_ZX_id`, `involution_product_invertible`, `secp256k1_no_linear_term`, ... +14 more

#### `RealWorldApplications.lean` (107 lines)
*Source: `Speculative/Exploration/RealWorldApplications.lean`*

- **theorem**: `dft2_squared`, `poly_mul_comm_int`, `parseval_ex`, `nyquist_dim`, `nilpotent_stable`, `gd_key_ineq`, ... +8 more

#### `ResearchFindings.lean` (164 lines)
*Source: `Speculative/Exploration/ResearchFindings.lean`*

- **theorem**: `trace_sum_eq_11`, `trace_B₁_B₂`, `trace_B₁_B₃`, `trace_B₂_B₃`, `trace_B₁_sq`, `trace_B₂_sq`, ... +32 more

#### `RosettaStone.lean` (171 lines)
*Source: `Speculative/Exploration/RosettaStone.lean`*

- **noncomp. def**: `cayley_real_part`, `cayley_imag_part`, `cross_ratio`
- **theorem**: `cayley_on_circle`, `rotation_preserves_circle`, `rotation_inverse`, `fermat_christmas_5`, `fermat_christmas_13`, `fermat_christmas_17`, ... +17 more

#### `SciFiMathematics.lean` (224 lines)
*Source: `Speculative/Exploration/SciFiMathematics.lean`*

- **theorem**: `koch_dimension_equation`, `log_three_pos`, `log_four_pos`, `koch_dimension_irrational`, `hyperbolic_area_lower_bound`, `cosh_ge_one`, ... +6 more

#### `Session2Theorems.lean` (336 lines)
*Source: `Speculative/Exploration/Session2Theorems.lean`*

- **theorem**: `sigma1_star_pow2`, `r4_pow2`, `chi4_sum_pow2`, `sum_cubes_factor`, `diff_cubes_factor`, `eisenstein_norm_nonneg`, ... +16 more

#### `StrangeLight.lean` (246 lines)
*Source: `Speculative/Exploration/StrangeLight.lean`*

- **def**: `stokesMinkowski`, `stokesInner`, `degree_of_pol`, `right_circular_stokes`, `left_circular_stokes`, `photon_worldline`
- **theorem**: `fully_polarized_is_null`, `partially_polarized_is_timelike`, `unpolarized_maximum_mass`, `collinear_photons_null`, `antiparallel_photons_massive`, `combined_photon_mass`, ... +21 more

#### `StrangeLoops.lean` (114 lines)
*Source: `Speculative/Exploration/StrangeLoops.lean`*

- **structure**: `GodelSentenceV2`
- **theorem**: `lawvere_fp`, `godel_incompleteness_v2`, `pow2_not_div3`, `double_preserves_mod3`, `sub3_preserves_mod3`, `no_self_negating_prop`, ... +6 more

#### `TurboQuantAnalysis.lean` (250 lines)
*Source: `Speculative/Exploration/TurboQuantAnalysis.lean`*

- **def**: `turboQuantGapFactor`, `turboQuantMSEUpperBound`, `infoTheoreticMSELowerBound`, `qjlVarianceFactor`, `innerProdLowerBound`, `turboQuantInnerProdUpperBound`
- **theorem**: `finite_codebook_bound`, `codeword_count_bound`, `four_pow_pos`, `mse_lower_bound_decreasing`, `turboQuantGapFactor_pos`, `turboquant_gap_is_constant`, ... +13 more

#### `TwilightZone.lean` (3 lines)
*Source: `Speculative/Exploration/TwilightZone.lean`*


#### `TwoEyesNextSteps.lean` (375 lines)
*Source: `Speculative/Exploration/TwoEyesNextSteps.lean`*

- **def**: `invStereoS`, `antipodalMap`, `crossRatio`, `IsHarmonic`, `cayleyTransform`, `invCayleyTransform`, ... +7 more
- **theorem**: `invStereoS_on_sphere`, `antipodal_involution`, `antipodal_reverses_x`, `antipodal_reverses_y`, `antipodal_no_fixed_points`, `antipodal_max_distance`, ... +45 more

#### `UnifyingTheory.lean` (251 lines)
*Source: `Speculative/Exploration/UnifyingTheory.lean`*

- **structure**: `UniversalOracle`, `UnifyingStrangeLoop`, `GrandUnification`
- **def**: `identityOracle`, `constantOracle`, `Q_unif`, `UnifyingStrangeLoop`, `hurwitzDimensions`, `GrandUnification`
- **theorem**: `oracle_truth_eq_range`, `oracle_compose_commuting`, `pythagorean_is_light_cone`, `stereo_on_circle`, `brahmagupta_fibonacci_unifying`, `pythagorean_parametrization_unifying`, ... +21 more

#### `UnityIsomorphism.lean` (193 lines)
*Source: `Speculative/Exploration/UnityIsomorphism.lean`*

- **structure**: `MathPrediction`, `NoetherCorrespondence`, `PredictionRecord`
- **def**: `time_energy_noether`, `historical_predictions`, `open_predictions`, `mean_prediction_gap`
- **theorem**: `terminal_objects_isomorphic`, `one_mul_identity`, `mul_one_identity`, `identity_unique`, `log_unity_zero`, `logb_unity_zero`, `map_to_unit_unique`, `unity_isomorphism_principle`

#### `Applications.lean` (103 lines)
*Source: `Speculative/Other/Applications.lean`*

- **theorem**: `binaural_beat_bound`, `nyquist_bound`, `stereoscopic_disparity_decreasing`, `sigmoid_range_bounded`, `autoheal_defect_convergence`, `verified_repair_correct`, `wavefront_coherence_bound`, `phase_deformation_monotone`

#### `Basic.lean` (157 lines)
*Source: `Speculative/Other/Basic.lean`*

- **def**: `omegaTower`
- **noncomp. def**: `epsilon0`
- **theorem**: `omegaTower_one`, `omegaTower_two`, `omega0_opow_isNormal`, `omega0_opow_strictMono`, `omegaTower_pos`, `one_le_omegaTower`, ... +9 more

#### `Core.lean` (115 lines)
*Source: `Speculative/Other/Core.lean`*

- **theorem**: `adaptive_feedback_convergence`, `transport_composition_lipschitz`, `self_repair_fixed_point`, `shannon_entropy_term_nonneg`, `iterative_refinement_geometric_convergence`, `collaborative_convex_combination`

#### `CrossDomainBridges.lean` (204 lines)
*Source: `Speculative/Other/CrossDomainBridges.lean`*

- **def**: `IsOracle`, `FixSet`, `relu`, `minkowskiQ`, `invStereo`
- **theorem**: `master_equation`, `relu_is_oracle`, `relu_is_tropical_add`, `relu_not_additive`, `pythagorean_is_null`, `null_scale_int`, ... +12 more

#### `Duality.lean` (99 lines)
*Source: `Speculative/Other/Duality.lean`*

- **structure**: `SearchObj`, `ObservationData`, `RepulsionData`, `QuantumSearchState`, `OneWayFunction`, `ZKSearchProof`
- **def**: `observationRepulsionPairing`, `searchInfo`, `evasionInfo`, `owfSearchProblem`
- **theorem**: `observation_repulsion_complementarity`, `search_info_conservation`, `grover_speedup`, `owf_unique_preimage`

#### `Evasion.lean` (87 lines)
*Source: `Speculative/Other/Evasion.lean`*

- **structure**: `EvasionStrategy`, `TransfiniteEvasion`, `BoundedEvasionStrategy`
- **def**: `EvasionStrategy`, `EvasionStrategy`, `EvasionStrategy`, `AdaptiveSearch`, `catches`
- **theorem**: `exhaustive_search_catches`, `evasion_lower_bound`, `transfinite_evasion_finite_bound`

#### `FiveFrontiers.lean` (308 lines)
*Source: `Speculative/Other/FiveFrontiers.lean`*

- **structure**: `Oracle`
- **def**: `tadd`, `tmul`, `relu`, `Oracle`, `Oracle`, `Oracle`, `Oracle`, `reluOracle`
- **theorem**: `relu_is_tropical_add_zero`, `tadd_comm`, `tadd_assoc`, `tadd_idem`, `tmul_comm`, `tmul_assoc`, ... +32 more

#### `FrontierSynthesis.lean` (166 lines)
*Source: `Speculative/Other/FrontierSynthesis.lean`*

- **def**: `lorentzForm`, `IsNull`, `IsTimelike`, `IsSpacelike`, `IsLightPrime_mod4`, `IsDarkPrime_mod4`, `lorentzForm4`
- **theorem**: `triple_trichotomy`, `null_not_timelike`, `null_not_spacelike`, `root_is_null`, `two_is_twilight`, `odd_prime_light_or_dark`, ... +12 more

#### `GazingPool.lean` (403 lines)
*Source: `Speculative/Other/GazingPool.lean`*

- **structure**: `GazingPool`, `StrangeLoop`, `ObserverHierarchy`, `ContractiveGazingPool`, `CategoricalGazingPool`, `QuantumGazingPool`
- **def**: `gaze`, `IsConscious`, `shadowSelf`, `ShadowEquiv`, `gazeIter`
- **noncomp. def**: `gazingMonad`
- **theorem**: `shadowEquiv_equiv`, `conscious_stable`, `retraction_idempotent`, `shadow_incompleteness`, `shadow_idempotent`, `lawvere_fixed_point`, ... +17 more

#### `GazingPoolOpenQuestions.lean` (352 lines)
*Source: `Speculative/Other/GazingPoolOpenQuestions.lean`*

- **structure**: `GazingPool`, `StochMatrix`, `ProbDist`
- **def**: `gaze`, `IsConscious`, `retract`, `IsConsciousAdmitting`, `StochMatrix`, `IsStationary`, `uniformDist`, `consciousFinset`
- **theorem**: `spectrum_characterization`, `id_conscious_admitting`, `symmetric_conscious_admitting`, `knaster_tarski_consciousness`, `knaster_tarski_lfp`, `knaster_tarski_gfp`, ... +9 more

#### `InformationBounds.lean` (125 lines)
*Source: `Speculative/Other/InformationBounds.lean`*

- **structure**: `ProbDist`
- **def**: `binaryEntropy`, `ProbDist`, `uniformDist`, `klDivergence`
- **theorem**: `binaryEntropy_nonneg`, `binaryEntropy_max`, `uniform_max_entropy`, `minimax_detection_value`, `kl_divergence_nonneg`, `infinite_horizon_optimal`, `search_info_isomorphism`

#### `KolmogorovComplexity.lean` (107 lines)
*Source: `Speculative/Other/KolmogorovComplexity.lean`*

- **def**: `DescriptionMethod`, `validPrograms`, `IsUniversal`, `IsOptimal`, `Incompressible`
- **noncomp. def**: `complexity`
- **theorem**: `universal_is_optimal`, `complexity_le_length`, `incompressible_exist`

#### `LYMInequality.lean` (124 lines)
*Source: `Speculative/Other/LYMInequality.lean`*

- **def**: `IsAntichain`
- **theorem**: `lym_inequality`, `sperner_bound`

#### `Main.lean` (25 lines)
*Source: `Speculative/Other/Main.lean`*


#### `OctonionicQuantumSolver.lean` (203 lines)
*Source: `Speculative/Other/OctonionicQuantumSolver.lean`*

- **structure**: `OctSolver`, `OctOracle`, `Problem`, `LLMLayer`
- **def**: `octNormSq`, `octNorm`, `isNormPreserving`, `isIdempotent`, `fixedPoints`, `identitySolver`, ... +8 more
- **theorem**: `oct_add_comm`, `octNormSq_nonneg`, `octNorm_nonneg`, `octNormSq_zero`, `octNormSq_smul`, `solver_produces_solution`, ... +6 more

#### `OctonionicTropicalApplications.lean` (194 lines)
*Source: `Speculative/Other/OctonionicTropicalApplications.lean`*

- **def**: `associator`, `unitSphere`, `realHopfMap`, `fanoLines`
- **theorem**: `real_associator_zero`, `tropical_associator_zero`, `error_detection_principle`, `hopf_bounded`, `hopf_nonconstant`, `fano_line_count`, ... +8 more

#### `OptimalPlanning.lean` (288 lines)
*Source: `Speculative/Other/OptimalPlanning.lean`*

- **structure**: `MDP`, `PlanningProblem`
- **def**: `ValueFn`, `Policy`, `bellmanOp`, `greedyPolicy`, `valueIteration`, `supDist`, ... +3 more
- **theorem**: `supDist_nonneg`, `pointwise_le_supDist`, `bellman_monotone`, `bellman_contraction`, `bellman_fixedPoint_unique`, `bellman_idempotent_at_fixedPoint`, ... +4 more

#### `OrbitalGoalDynamics.lean` (254 lines)
*Source: `Speculative/Other/OrbitalGoalDynamics.lean`*

- **structure**: `OGDGoal`, `GoalCoupling`
- **def**: `singleGoalHamiltonian`, `kineticEnergy`, `targetPotential`, `distanceToTarget`, `PlanningOperator`, `isFixedPoint`, ... +3 more
- **theorem**: `kineticEnergy_nonneg`, `targetPotential_nonneg`, `hamiltonian_split`, `hamiltonian_nonneg`, `hamiltonian_zero_at_target`, `distanceToTarget_nonneg`, ... +6 more

#### `Repulsors.lean` (104 lines)
*Source: `Speculative/Other/Repulsors.lean`*

- **structure**: `DiscreteDynSystem`, `BijectiveDynSystem`, `ProbRepulsor`
- **def**: `DiscreteDynSystem`, `DiscreteDynSystem`, `IsDiscreteAttractor`, `IsDiscreteRepulsor`, `discreteBasinOfAttraction`, `discreteBasinOfRepulsion`, `BijectiveDynSystem`, `repulsorSpectrum`
- **theorem**: `DiscreteDynSystem`, `DiscreteDynSystem`, `DiscreteDynSystem`, `repulsor_reverse_attractor`, `repulsorSpectrum_nonempty_of_repulsor`

#### `RoadAhead.lean` (135 lines)
*Source: `Speculative/Other/RoadAhead.lean`*

- **theorem**: `diff_sq_factor`, `congruence_of_squares_factor`, `product_div_neither_factor`, `brahmagupta_fibonacci_road`, `pyth_composition`, `B1_pyth`, ... +7 more

#### `SearchTheoryCore.lean` (51 lines)
*Source: `Speculative/Other/SearchTheoryCore.lean`*

- **structure**: `SearchStrategy`
- **def**: `SearchStrategy`, `SearchStrategy`
- **theorem**: `SearchStrategy`, `SearchStrategy`, `detectionProbability_mono`

#### `SternBrocot.lean` (83 lines)
*Source: `Speculative/Other/SternBrocot.lean`*

- **inductive**: `Dir`
- **def**: `navigate`, `fromPath`, `navigateBounds`
- **theorem**: `mediant_adjacency_left`, `mediant_adjacency_right`, `adjacency_invariant`, `standard_adjacency`, `fromPath_den_pos`

#### `UniversalTranslator.lean` (544 lines) ⚠️ 1 sorry
*Source: `Speculative/Other/UniversalTranslator.lean`*

- **def**: `kahler_differentials_module`, `universal_derivation`, `gelfand_duality`
- **theorem**: `point_is_prime_ideal`, `point_in_zeroLocus_iff_ideal_contained`, `maximal_ideal_is_closed_point`, `basic_open_is_complement_of_vanishing`, `basic_opens_form_basis`, `basic_open_mul`, ... +23 more

### Speculative/RosettaStone

*15 files, 244 declarations, 1,652 lines*

#### `Applications.lean` (84 lines)
*Source: `Speculative/RosettaStone/Applications.lean`*

- **structure**: `QECC`
- **def**: `is_tree_metric`
- **noncomp. def**: `code_dimension`
- **theorem**: `tropical_path_idempotent`, `min_idempotent`, `complement_code`, `orthogonal_codes_sum`, `relu_idempotent_nonneg`, `pca_projection_property`, `crt_shares_sum_to_one`, `zmod6_idem_count`

#### `Bridge10_Research.lean` (397 lines)
*Source: `Speculative/RosettaStone/Bridge10_Research.lean`*

- **structure**: `CSOI`, `ClosureOp`, `InteriorOp`
- **def**: `csoi_trivial`, `csoi_from_idempotent`, `idemCount`, `IsIdem`
- **noncomp. def**: `topological_closure`, `topological_interior`, `idemEntropy`
- **theorem**: `prod_idempotent_iff`, `field_idempotent_iff`, `prime_two_idempotents_2`, `prime_two_idempotents_3`, `prime_two_idempotents_5`, `prime_two_idempotents_7`, ... +54 more

#### `Bridge1_Classical.lean` (70 lines)
*Source: `Speculative/RosettaStone/Bridge1_Classical.lean`*

- **theorem**: `complement_idempotent`, `idempotent_orthogonal`, `idempotent_orthogonal`, `idempotent_double_complement`, `idempotent_pow`, `idempotent_ideal`, `zmod2_idempotents`, `zmod6_idempotent_count`

#### `Bridge2_Stone.lean` (67 lines)
*Source: `Speculative/RosettaStone/Bridge2_Stone.lean`*

- **theorem**: `boolean_inf_idempotent`, `boolean_sup_idempotent`, `boolean_compl_compl`, `boolean_de_morgan_inf`, `boolean_de_morgan_sup`, `boolean_sup_compl_top`, ... +8 more

#### `Bridge3_Gelfand.lean` (48 lines)
*Source: `Speculative/RosettaStone/Bridge3_Gelfand.lean`*

- **structure**: `Projection`
- **def**: `Projection`, `evalHomomorphism`
- **theorem**: `projection_orthogonal`, `projection_sum_one`

#### `Bridge4_Pointfree.lean` (82 lines)
*Source: `Speculative/RosettaStone/Bridge4_Pointfree.lean`*

- **theorem**: `inf_idempotent`, `sup_idempotent`, `absorption_inf_sup`, `absorption_sup_inf`, `frame_distrib`, `complemented_decomposition`, ... +8 more

#### `Bridge5_Noncommutative.lean` (57 lines)
*Source: `Speculative/RosettaStone/Bridge5_Noncommutative.lean`*

- **def**: `commutator`
- **theorem**: `commutator_antisymm`, `commutator_self`, `diagonal_commute`, `commuting_projections_product`, `diagonal_mul_comm`, `trace_commutator_zero`

#### `Bridge6_Derived.lean` (65 lines)
*Source: `Speculative/RosettaStone/Bridge6_Derived.lean`*

- **theorem**: `idempotent_range_ker_sup`, `idempotent_range_ker_inf`, `idempotent_restrict_range`, `trace_cyclic`

#### `Bridge7_Tropical.lean` (59 lines)
*Source: `Speculative/RosettaStone/Bridge7_Tropical.lean`*

- **def**: `tropical_det_2x2`
- **theorem**: `tropical_add_idempotent`, `tropical_add_comm`, `tropical_add_assoc`, `tropical_distrib`, `tropical_zero_property`, `tropical_one`, ... +6 more

#### `Bridge8_Quantum.lean` (76 lines)
*Source: `Speculative/RosettaStone/Bridge8_Quantum.lean`*

- **def**: `IsProjection`, `diagonalProjection`
- **theorem**: `zero_is_projection`, `one_is_projection`, `complement_projection`, `projection_orthogonal_complement`, `complement_projection_orthogonal`, `measurement_stability`, ... +3 more

#### `Bridge9_Motivic.lean` (159 lines)
*Source: `Speculative/RosettaStone/Bridge9_Motivic.lean`*

- **structure**: `IdempotentCorrespondence`, `MotivicWeight`, `KunnethSystem`
- **class**: `CorrespondenceAlgebra`
- **def**: `diagonal_correspondence`, `zero_correspondence`, `tate_weight`
- **noncomp. def**: `curve_motivic_density`
- **theorem**: `complement_idem_corr`, `tate_slope`, `kunneth_determined`, `kunneth_zero_product`, `classical_to_motivic`, `motivic_to_derived`, ... +4 more

#### `Categorification.lean` (101 lines)
*Source: `Speculative/RosettaStone/Categorification.lean`*

- **structure**: `CategoricalIdempotent`
- **def**: `id_idempotent`, `zero_idempotent`, `is_idempotent_element`, `is_idempotent_morphism`, `is_full_idempotent`
- **theorem**: `karoubi_embedding`, `karoubi_splits_idempotent`, `peirce_decomposition`, `peirce_corner_identity`, `level0_embeds_level1`, `k0_idempotent_correspondence`

#### `CrossBridge_IdempotentThread.lean` (66 lines)
*Source: `Speculative/RosettaStone/CrossBridge_IdempotentThread.lean`*

- **theorem**: `tropical_universal_idempotent`, `lattice_inf_idempotent`, `ring_idempotent_complement`, `tropical_is_lattice_idempotent`, `boolean_to_projection`, `commutative_projections_commute`, ... +6 more

#### `MasterFormula.lean` (123 lines)
*Source: `Speculative/RosettaStone/MasterFormula.lean`*

- **def**: `idempotent_count`, `gaussian_binomial`, `total_projections`
- **theorem**: `density_2`, `density_3`, `density_6`, `density_30`, `gaussian_binomial_q1`, `total_projections_q1`, ... +8 more

#### `NewDiscoveries.lean` (198 lines)
*Source: `Speculative/RosettaStone/NewDiscoveries.lean`*

- **theorem**: `idempotent_count_2`, `idempotent_count_3`, `idempotent_count_4`, `idempotent_count_5`, `idempotent_count_6`, `idempotent_count_8`, ... +22 more

### Speculative/RudyRucker

*5 files, 40 declarations, 516 lines*

#### `CantorsParadise.lean` (113 lines)
*Source: `Speculative/RudyRucker/CantorsParadise.lean`*

- **def**: `cantor_diagonal`
- **theorem**: `cantor_no_surjection`, `cantor_diagonal_not_in_range`, `nat_is_aleph_zero`, `power_set_nat_gt_nat`, `cardinal_lt_power`, `schroder_bernstein`, ... +3 more

#### `ComputationalUniverse.lean` (98 lines)
*Source: `Speculative/RudyRucker/ComputationalUniverse.lean`*

- **def**: `CAConfig`, `CArule`, `evolve`, `evolve_n`, `shift`, `is_garden_of_eden`, `is_reversible`
- **theorem**: `evolve_deterministic`, `evolve_n_succ`, `evolve_shift_commute`, `reversible_no_garden_of_eden`

#### `DiagonalArguments.lean` (99 lines)
*Source: `Speculative/RudyRucker/DiagonalArguments.lean`*

- **theorem**: `lawvere_fixed_point`, `cantor_no_surjection_bool`, `russell_diagonal`, `konig_cardinal`, `knaster_tarski`

#### `MindAndMathematics.lean` (93 lines)
*Source: `Speculative/RudyRucker/MindAndMathematics.lean`*

- **theorem**: `brouwer_1d`, `exists_boundary_of_infinite_coinfinite`, `powerset_monotone`, `no_largest_cardinal`, `zorns_lemma_variant`

#### `TransfiniteOrdinals.lean` (113 lines)
*Source: `Speculative/RudyRucker/TransfiniteOrdinals.lean`*

- **theorem**: `ordinal_trichotomy`, `one_add_omega`, `omega_add_one_ne_omega`, `omega_lt_omega_add_one`, `transfinite_induction`, `omega_is_limit`, ... +3 more

### Speculative/SciFi

*21 files, 121 declarations, 1,544 lines*

#### `AlienLife.lean` (59 lines)
*Source: `Speculative/SciFi/AlienLife.lean`*

- **def**: `poissonNearestCDF`
- **theorem**: `no_match_prob_tendsto_zero`, `trial_prob_lt_one`, `trial_prob_nonneg`, `poissonNearestCDF_zero`, `poissonNearestCDF_tendsto_one`

#### `Computability.lean` (53 lines)
*Source: `Speculative/SciFi/Computability.lean`*

- **theorem**: `no_surjection_to_powerset`, `rice_abstract`, `abstract_incompleteness`

#### `AlienLife.lean` (69 lines)
*Source: `Speculative/SciFi/Extended/AlienLife.lean`*

- **theorem**: `miss_probability_decreases`, `miss_probability_vanishes`, `hit_probability_approaches_one`, `poisson_void_probability`, `poisson_detection_limit`, `arrangements_grow`, `factorial_beats_exponential`

#### `Computability.lean` (64 lines)
*Source: `Speculative/SciFi/Extended/Computability.lean`*

- **theorem**: `diagonal_nonsurjective`, `cantor_nat_bool`, `no_complete_enumeration`, `self_reference_constraint`

#### `FermiParadox.lean` (86 lines)
*Source: `Speculative/SciFi/Extended/FermiParadox.lean`*

- **theorem**: `exponential_unbounded`, `exponential_strictly_monotone`, `drake_linear_in_factor`, `bayes_theorem`, `posterior_sums_to_one`, `detection_probability_monotone`, `detection_limit`

#### `Hyperspace.lean` (90 lines)
*Source: `Speculative/SciFi/Extended/Hyperspace.lean`*

- **theorem**: `triangle_inequality_bound`, `quotient_shortens_distance`, `sphere_chord_le_diameter`, `pi_gt_two`, `hyperspace_saving`, `lorentz_factor_requires_subluminal`, `at_light_speed_gamma_diverges`

#### `Information.lean` (87 lines)
*Source: `Speculative/SciFi/Extended/Information.lean`*

- **theorem**: `deterministic_zero_entropy`, `log_one_eq_zero`, `noiseless_binary_capacity`, `pigeonhole_compression`, `inverse_square_law`, `double_distance_quarter_power`, `mutual_info_nonneg`

#### `Paradoxes.lean` (62 lines)
*Source: `Speculative/SciFi/Extended/Paradoxes.lean`*

- **theorem**: `cantor_no_surjection`, `diagonal_not_in_range`, `no_enumeration_of_functions`, `negation_no_fixed_point`, `grandfather_paradox`

#### `Relativity.lean` (103 lines)
*Source: `Speculative/SciFi/Extended/Relativity.lean`*

- **theorem**: `lorentz_denominator_pos`, `lorentz_denominator_le_one`, `no_dilation_at_rest`, `lorentz_at_light_speed`, `time_dilation_factor_bound`, `no_time_dilation_at_rest`, ... +3 more

#### `TemporalLogic.lean` (98 lines)
*Source: `Speculative/SciFi/Extended/TemporalLogic.lean`*

- **def**: `parallel_timelines`
- **theorem**: `no_cycles_in_partial_order`, `no_self_causation`, `timeline_total`, `past_is_linear`, `causal_diamond_between`, `parallel_symmetric`, `no_parallel_in_linear_order`

#### `TimeTravel.lean` (108 lines)
*Source: `Speculative/SciFi/Extended/TimeTravel.lean`*

- **theorem**: `contraction_has_fixed_point`, `contraction_fixed_point_unique`, `monotone_has_fixed_point`, `iterate_at_fixed_point`, `bootstrap_self_consistent`

#### `Topology.lean` (75 lines)
*Source: `Speculative/SciFi/Extended/Topology.lean`*

- **theorem**: `euler_cube`, `euler_tetrahedron`, `euler_octahedron`, `euler_dodecahedron`, `euler_icosahedron`, `euler_torus_example`, `sphere_ne_torus`, `euler_char_sphere_nonzero`

#### `FermiParadox.lean` (70 lines)
*Source: `Speculative/SciFi/FermiParadox.lean`*

- **theorem**: `exp_growth_increasing`, `exp_growth_unbounded`, `drake_linear_in_L`, `bayes_theorem`, `great_filter_bayesian`

#### `Hyperspace.lean` (40 lines)
*Source: `Speculative/SciFi/Hyperspace.lean`*

- **theorem**: `chord_distance_le_two`, `triangle_inequality_metric`, `dist_nonneg`, `dist_symm`

#### `Information.lean` (102 lines)
*Source: `Speculative/SciFi/Information.lean`*

- **def**: `shannonEntropy`, `gaussianCapacity`
- **theorem**: `shannonEntropy_nonneg`, `shannonEntropy_le_log`, `gaussianCapacity_nonneg`, `gaussianCapacity_mono_SNR`, `kolmogorov_invariance`

#### `KardashevScale.lean` (51 lines)
*Source: `Speculative/SciFi/KardashevScale.lean`*

- **def**: `kardashevNumber`
- **theorem**: `kardashev_mono`, `kardashev_typeI`, `power_density_inverse_square`

#### `Paradoxes.lean` (63 lines)
*Source: `Speculative/SciFi/Paradoxes.lean`*

- **theorem**: `cantor_diagonal`, `cantor_diagonal_witness`, `russell_style`, `lawvere_fixedpoint`, `lawvere_contrapositive`

#### `Relativity.lean` (80 lines)
*Source: `Speculative/SciFi/Relativity.lean`*

- **def**: `lorentzFactor`, `rocketVelocity`
- **theorem**: `lorentz_ge_one`, `lorentz_strictMono_on`, `time_dilation_range`, `rocket_below_lightspeed`, `rocket_velocity_increasing`

#### `TemporalLogic.lean` (54 lines)
*Source: `Speculative/SciFi/TemporalLogic.lean`*

- **theorem**: `partial_order_cycle`, `no_time_travel_strict_order`, `past_is_linear`, `past_glb_exists`, `preorder_allows_loops`

#### `TimeTravel.lean` (82 lines)
*Source: `Speculative/SciFi/TimeTravel.lean`*

- **theorem**: `contraction_has_fixedPoint`, `contraction_fixedPoint_unique`, `monotone_has_lfp`, `interval_fixedPoint`

#### `Topology.lean` (48 lines)
*Source: `Speculative/SciFi/Topology.lean`*

- **theorem**: `euler_formula_planar`, `torus_euler`, `torus_triangulation`, `orientation_reversal_implies_nonorientable`

### Topology

*11 files, 121 declarations, 794 lines*

#### `AlgebraicTopology.lean` (23 lines)
*Source: `Topology/Core/AlgebraicTopology.lean`*

- **theorem**: `real_sc`, `rn_sc`, `chi_S2`, `chi_T2`, `chi_genus2`, `chi_KB`, ... +4 more

#### `ConvexGeometry.lean` (37 lines)
*Source: `Topology/Core/ConvexGeometry.lean`*

- **theorem**: `convex_inter`, `convex_hull_minimal`, `subset_convex_hull`, `jensen_two_point`, `sq_convex`, `lp_weak_duality`

#### `DifferentialGeometry.lean` (53 lines)
*Source: `Topology/Core/DifferentialGeometry.lean`*

- **def**: `so2_generator`
- **theorem**: `gauss_bonnet_sphere`, `gauss_bonnet_torus`, `gauss_bonnet_genus`, `so2_antisymmetric`, `so2_generator_squared`, `z2_action_period`, `harmonic_path`, `chern_number_quantized`

#### `GeometricGroupTheory.lean` (55 lines)
*Source: `Topology/Core/GeometricGroupTheory.lean`*

- **theorem**: `z_growth`, `z2_growth`, `free_group_growth`, `zn_polynomial_growth`, `z_r_quasi_isometric`, `cayley_zn_diameter`, ... +4 more

#### `HodgeTheory.lean` (43 lines)
*Source: `Topology/Core/HodgeTheory.lean`*

- **theorem**: `curve_hodge`, `k3_euler`, `cy3_euler`, `elliptic_discriminant`, `ec_example_disc`, `ec_points`, ... +5 more

#### `KnotTheory.lean` (41 lines)
*Source: `Topology/Core/KnotTheory.lean`*

- **theorem**: `unknot_crossing_number`, `trefoil_crossing_number`, `figure_eight_crossing`, `jones_unknot`, `jones_trefoil_det`, `det_figure_eight`, ... +9 more

#### `MetricGeometry.lean` (44 lines)
*Source: `Topology/Core/MetricGeometry.lean`*

- **theorem**: `isometry_dist`, `isometry_comp`, `completion_complete`, `hausdorff_dist_comm`, `euclidean_dist_eq_norm`, `euclidean_triangle`, `nearest_neighbor_exists`

#### `SymplecticGeometry.lean` (54 lines)
*Source: `Topology/Core/SymplecticGeometry.lean`*

- **def**: `symp_J`, `mod_S`, `mod_T`
- **theorem**: `symp_J_sq`, `symp_J_det`, `symp_product`, `mod_S_det`, `mod_T_det`, `mod_S_sq`, ... +6 more

#### `Topology.lean` (125 lines)
*Source: `Topology/Core/Topology.lean`*

- **theorem**: `unit_interval_compact`, `compact_image_continuous`, `compact_attains_max`, `ivt`, `real_connected`, `brouwer_1d`, `compact_metric_complete`, `compact_metric_totally_bounded`

#### `TopologyDynamics.lean` (165 lines)
*Source: `Topology/Core/TopologyDynamics.lean`*

- **theorem**: `metric_hausdorff`, `ball_open`, `empty_open`, `univ_open`, `inter_open`, `union_of_open`, ... +14 more

#### `TopologyExploration.lean` (154 lines)
*Source: `Topology/Core/TopologyExploration.lean`*

- **theorem**: `discrete_metric_triangle`, `unit_interval_compact`, `closed_subset_compact`, `Icc_connected`, `connected_image`, `brouwer_1d`, ... +4 more

### Tropical/Core

*24 files, 824 declarations, 6,992 lines*

#### `TropicalAgentAlpha.lean` (87 lines)
*Source: `Tropical/Agents/TropicalAgentAlpha.lean`*

- **def**: `tropPow`, `IsTropicalContraction`
- **theorem**: `tropPow_zero`, `tropPow_one`, `tropPow_succ`, `exp_tropPow`, `softmax_ge_max`, `softmax_le_max_add_log2`, ... +6 more

#### `TropicalAgentBeta.lean` (95 lines)
*Source: `Tropical/Agents/TropicalAgentBeta.lean`*

- **noncomp. def**: `softAttention`, `layerMean`, `layerVar`, `perplexity`, `gradStep`
- **theorem**: `softAttention_zero`, `centered_mean_zero`, `layerVar_nonneg`, `residual_recovers`, `multihead_split`, `trop_dominant_term`, ... +5 more

#### `TropicalAgentDelta.lean` (117 lines)
*Source: `Tropical/Agents/TropicalAgentDelta.lean`*

- **def**: `IsLogConcave`
- **noncomp. def**: `fisherBernoulli`
- **theorem**: `boolean_function_count`, `tropZeta_nonpos`, `dirichlet_term_exp`, `lax_oleinik_monotone`, `tropical_gauge_abelian`, `tropical_yang_mills_linear`, ... +5 more

#### `TropicalAgentEpsilon.lean` (147 lines)
*Source: `Tropical/Agents/TropicalAgentEpsilon.lean`*

- **def**: `tropHamming`
- **noncomp. def**: `tropContract`, `tropEntropy`
- **theorem**: `translation_preserves_max`, `nonneg_scale_preserves_max`, `partition_function_bound`, `successive_updates`, `learning_rate_sum_pos`, `max_preserves_convexity`, ... +7 more

#### `TropicalAgentGamma.lean` (67 lines)
*Source: `Tropical/Agents/TropicalAgentGamma.lean`*

- **def**: `isTropRankOne`
- **theorem**: `tropical_circuit_leaves`, `rate_distortion_levels`, `log_preserves_order`, `factoring_tropical`, `gcd_lcm_identity`, `zero_trop_rank_one`, ... +4 more

#### `TropicalAdvancedTheory.lean` (241 lines)
*Source: `Tropical/Core/TropicalAdvancedTheory.lean`*

- **def**: `IsTropicallyConvex`, `IsTropConvexFn`, `tropKoopman`
- **noncomp. def**: `deformedAdd`, `entropy`, `hardAttentionSimple`
- **theorem**: `deformedAdd_one`, `lse2_ge_max`, `lse2_le_max_log2`, `univ_tropically_convex`, `id_trop_convex`, `const_trop_convex`, ... +19 more

#### `TropicalAlphabet.lean` (263 lines)
*Source: `Tropical/Core/TropicalAlphabet.lean`*

- **def**: `tropAdd`, `tropMul`, `tropPow`, `tropInv`, `tropDiv`, `tropAbs`, ... +7 more
- **theorem**: `tropAdd_idempotent`, `tropAdd_comm`, `tropAdd_assoc`, `tropMul_comm`, `tropMul_assoc`, `tropMul_tropAdd_distrib`, ... +23 more

#### `TropicalAlphabetAdvanced.lean` (137 lines)
*Source: `Tropical/Core/TropicalAlphabetAdvanced.lean`*

- **theorem**: `exp_trop_mul_hom`, `exp_trop_one`, `trop_distrib_right`, `trop_mul_mono_left`, `trop_triangle`, `trop_div_cancel`, ... +9 more

#### `TropicalAlphabetFoundations.lean` (176 lines)
*Source: `Tropical/Core/TropicalAlphabetFoundations.lean`*

- **def**: `bool_to_trop`
- **theorem**: `trop_add_idempotent`, `trop_distrib`, `trop_add_comm`, `trop_add_assoc`, `trop_mul_comm`, `trop_mul_assoc`, ... +13 more

#### `TropicalGeometry.lean` (41 lines)
*Source: `Tropical/Core/TropicalGeometry.lean`*

- **theorem**: `tropical_add_comm`, `tropical_add_assoc`, `tropical_zero`, `tropical_distrib`, `tropical_triangle`, `newton_polygon_slope`, `tropical_convex_hull`, `bellman_equation`

#### `TropicalSemiring.lean` (297 lines)
*Source: `Tropical/Core/TropicalSemiring.lean`*

- **def**: `relu`, `logSumExp`, `softmax_component`
- **theorem**: `relu_eq_max`, `relu_of_nonneg`, `relu_of_nonpos`, `relu_relu`, `relu_nonneg`, `relu_monotone`, ... +15 more

#### `TropicalOracle.lean` (287 lines)
*Source: `Tropical/Oracle/TropicalOracle.lean`*

- **def**: `IsOracle`, `truthSet`
- **noncomp. def**: `tropicalGate`, `geodesicStep`
- **theorem**: `truthSet_eq_fixedPoints`, `oracle_range_eq_truthSet`, `oracle_on_truthSet`, `oracle_compose_self`, `tropicalGate_eq_neg_relu_neg`, `tropicalGate_idempotent`, ... +12 more

#### `TropicalOracleFormalization.lean` (353 lines)
*Source: `Tropical/Oracle/TropicalOracleFormalization.lean`*

- **def**: `IsIdempotent`, `TruthSet`
- **noncomp. def**: `tropicalGate`
- **theorem**: `truthSet_eq_range`, `range_subset_fixedPoints`, `fixedPoints_subset_range`, `idempotent_one_step_convergence`, `idempotent_retraction`, `tropicalGate_eq_neg_relu_neg`, ... +20 more

#### `TropicalOracleResearch.lean` (578 lines) ⚠️ 1 sorry
*Source: `Tropical/Oracle/TropicalOracleResearch.lean`*

- **def**: `tropDet`, `tropInnerProd`, `tropTrace`, `tropMaxDiag`, `tropCorrelation`, `tropProjection`
- **theorem**: `trop_add_def`, `trop_mul_def`, `tropical_convex_halfline`, `tropical_convex_inter`, `relu_preserves_tropical_max`, `relu_epigraph`, ... +56 more

#### `FutureDirectionsV2.lean` (404 lines)
*Source: `Tropical/Research/FutureDirectionsV2.lean`*

- **structure**: `TropCircuit`, `TropicalValuation`, `TropicalCharacter`
- **inductive**: `TropGate`
- **def**: `hardAttention`, `attentionScore`, `softmax`, `tropicalPosEncoding`, `TropCircuit`, `TropCircuit`, ... +11 more
- **theorem**: `softmax_nonneg`, `softmax_sum_one`, `max_score_ge_avg`, `hard_attention_any_target`, `tropicalPosEncoding_injective`, `tropicalPosEncoding_strictMono`, ... +21 more

#### `NewResearch.lean` (212 lines)
*Source: `Tropical/Research/NewResearch.lean`*

- **def**: `tropPow`, `tropPolyEval`, `tropMatMul`, `tropMatLE`, `relu`, `tropDet`, ... +5 more
- **theorem**: `tropPow_zero`, `tropPow_one`, `tropPow_succ`, `tropPow_add`, `trop_add_idem`, `no_max_absorbing`, ... +16 more

#### `TropicalDeepResearch.lean` (479 lines)
*Source: `Tropical/Research/TropicalDeepResearch.lean`*

- **def**: `tropDynamicsStep`, `tropicalLyapunov`, `gumbelCDF`, `tropicalDistance`, `tropicalHaarScaling`, `tropicalHaarDetail`
- **theorem**: `max_affine_dominates`, `tropical_gradient_selection`, `tropical_jensen`, `tropical_spectral_bound`, `tropical_contraction_principle`, `gumbelCDF_pos`, ... +46 more

#### `TropicalFactoring.lean` (411 lines)
*Source: `Tropical/Research/TropicalFactoring.lean`*

- **def**: `IsTropicalFactoring`, `IsSmooth`, `tropicalNorm`, `totalTropicalWeight`, `pollardRhoStep`
- **theorem**: `padic_val_mul_eq_add`, `padic_val_one`, `padic_val_self`, `padic_val_prime_pow`, `tropical_fundamental_theorem_of_arithmetic`, `padic_val_gcd`, ... +25 more

#### `TropicalFrontierResearch.lean` (535 lines)
*Source: `Tropical/Research/TropicalFrontierResearch.lean`*

- **def**: `tropMatVec`, `IsTropicalEigen`, `tropMonomial`, `tropicalEntropy`, `tropAutomatonRun`, `scaledSoftmax`, `logSumExp`, `tropBellman`
- **noncomp. def**: `reluDeriv`
- **theorem**: `trop_eigen_1x1`, `tropMatVec_mono`, `tropMatVec_shift`, `relu_is_tropPoly`, `deep_relu_tropical_terms`, `tropical_degree_composition`, ... +47 more

#### `TropicalFrontiers.lean` (232 lines)
*Source: `Tropical/Research/TropicalFrontiers.lean`*

- **def**: `tropAdd`, `tropMul`, `relu`
- **theorem**: `tropAdd_idempotent`, `tropAdd_comm`, `tropAdd_assoc`, `tropMul_comm`, `tropMul_assoc`, `tropMul_distrib`, ... +22 more

#### `TropicalFutureDirections.lean` (640 lines) ⚠️ 1 sorry
*Source: `Tropical/Research/TropicalFutureDirections.lean`*

- **def**: `tropGrad_left`, `tropGrad_right`, `tropMV`, `tropMM`, `tropMatPow`, `tropRNNState`, ... +9 more
- **theorem**: `tropGrad_partition`, `tropGrad_left_selects`, `tropGrad_right_selects`, `tropGrad_left_binary`, `tropGrad_right_binary`, `tropMV_mono_input`, ... +36 more

#### `TropicalInformationRichness.lean` (384 lines)
*Source: `Tropical/Research/TropicalInformationRichness.lean`*

- **def**: `tetration`
- **theorem**: `exp_tropical_scalar`, `square_doubles_tropical`, `cube_triples_tropical`, `factoring_space_grows_with_product`, `divisor_count_multiplicative`, `exp_information_density`, ... +48 more

#### `TropicalMoonshots.lean` (532 lines)
*Source: `Tropical/Research/TropicalMoonshots.lean`*

- **def**: `scaledLSE`, `softMin`, `heaviside`, `tropicalMatVec2`, `tropicalScalarMul`, `tropicalMatAdd`, ... +10 more
- **theorem**: `scaledLSE_one`, `softMin_dual`, `max_pow_le_sum_pow`, `sum_pow_le_two_max_pow`, `heaviside_pos`, `heaviside_nonpos`, ... +57 more

#### `TropicalQuantumBrain.lean` (277 lines)
*Source: `Tropical/Research/TropicalQuantumBrain.lean`*

- **def**: `tropAdd`, `tropMul`, `relu`, `tropicalHadamard`, `tropicalCNOT`, `tropicalPhase`, ... +3 more
- **theorem**: `tropAdd`, `tropAdd`, `tropAdd`, `tropMul`, `tropMul`, `relu`, ... +21 more

### Tropical/Cryptography

*5 files, 176 declarations, 1,804 lines*

#### `HashInversion.lean` (484 lines)
*Source: `Tropical/Cryptography/HashInversion.lean`*

- **def**: `tropicalMatMul`, `tropicalIdentity`, `tropicalPermMatrix`
- **theorem**: `hash_not_injective`, `sha256_domain_exceeds_range`, `information_loss`, `tropicalMatMul_assoc`, `tropicalMatMul_identity_right`, `tropicalMatMul_identity_left`, ... +17 more
- **lemma**: `finset_inf_add_right`, `finset_inf_add_left`, `finset_inf_inf_eq_inf_prod`

#### `TropicalSelfReasoning.lean` (459 lines)
*Source: `Tropical/Cryptography/TropicalSelfReasoning.lean`*

- **structure**: `TropicalLayer`, `TropicalNet`, `SelfReasoningNet`, `TropicalGodel`
- **def**: `tropAdd`, `tropMul`, `tropZero`, `tropOne`, `TropicalLayer`, `TropicalNet`, ... +10 more
- **theorem**: `tropAdd_comm`, `tropAdd_assoc`, `tropAdd_idem`, `tropMul_distrib`, `tropMul_comm`, `tropMul_assoc`, ... +14 more

#### `TropicalTrapdoor.lean` (322 lines)
*Source: `Tropical/Cryptography/TropicalTrapdoor.lean`*

- **structure**: `TropInstruction`, `TropCircuit`, `TropTrapdoorFn`, `ReversalWitness`
- **inductive**: `TropGate`
- **def**: `evalGate`, `minGatePreimage`, `maxGatePreimage`, `addGatePreimage`, `RegFile`, `execInstr`, ... +10 more
- **theorem**: `evalGate_min`, `evalGate_max`, `evalGate_add`, `gate_min_comm`, `gate_max_comm`, `gate_add_comm`, ... +28 more

#### `TropicalTrapdoorResearch.lean` (309 lines) ⚠️ 1 sorry
*Source: `Tropical/Cryptography/TropicalTrapdoorResearch.lean`*

- **structure**: `InversionExperiment`
- **def**: `tropMaxMatVec`, `reluAsTropical`, `validExperiment`, `consistencyRatio`
- **theorem**: `tropical_distributive`, `tropical_distributive_dual`, `tropical_absorption_min_max`, `tropical_absorption_max_min`, `relu_idempotent`, `relu_nonneg`, ... +12 more

#### `TropicalTrapdoorReversal.lean` (230 lines)
*Source: `Tropical/Cryptography/TropicalTrapdoorReversal.lean`*

- **inductive**: `TropConstraint`, `LinearizedGate`
- **def**: `satisfiesConstraint`, `feasibleSet`, `evalLinearized`, `minSelectionConsistent`, `maxSelectionConsistent`
- **theorem**: `min_preimage_char`, `max_preimage_char`, `add_preimage_char`, `add_no_info_loss`, `feasible_empty`, `feasible_mono`, ... +16 more

### Tropical/Langlands

*17 files, 409 declarations, 2,908 lines*

#### `AdvancedTheory.lean` (268 lines)
*Source: `Tropical/Langlands/AdvancedTheory.lean`*

- **structure**: `TropicalLHomomorphism`, `MetricGraph`, `TropicalRepresentation`, `TropicalLineBundle`
- **def**: `tropTrace`, `tropOrbitalIntegral`, `tropSpectralSide`, `tropGeometricSide`, `tropSymPower`, `MetricGraph`, ... +7 more
- **theorem**: `tropOrbitalIntegral_simp`, `tropTraceFormula_GL1`, `tropSymPower_ordered`, `tropEquiv_same_degree`, `kantorovich_weak_duality`, `tropNormMap_additive`, ... +4 more

#### `Algorithmic.lean` (141 lines)
*Source: `Tropical/Langlands/Algorithmic.lean`*

- **structure**: `WeightedGraph`, `YoungDiagram`
- **def**: `isSorted`, `tropicalDet`, `minPlusConv`, `graphLFunction`, `YoungDiagram`, `emptyYoung`, ... +6 more
- **theorem**: `const_sorted`, `monotone_sorted`, `tropicalDet_zero`, `tropicalDet_le_identity`, `minPlusConv_comm`, `graphLFunction_linear`, ... +9 more

#### `ArthurSelbergGL2.lean` (180 lines)
*Source: `Tropical/Langlands/ArthurSelbergGL2.lean`*

- **structure**: `TropicalTestFn`, `TropicalHeckeEigenvalue`, `TropicalMaassForm`
- **def**: `sphericalFn`, `pointEvalFn`, `GL2OrbitalIntegral`, `centralContribution`, `regularContribution`, `spectralEval`, ... +7 more
- **theorem**: `trace_formula_symmetric`, `tropical_trace_formula_GL2`, `weylDiscriminant_symm`, `weylDiscriminant_nonneg`, `weylDiscriminant_zero_iff`, `weightedOrbital_symm`, ... +7 more

#### `AutomorphicBuildings.lean` (161 lines)
*Source: `Tropical/Langlands/AutomorphicBuildings.lean`*

- **structure**: `BuildingVertex`, `Apartment`
- **def**: `buildingDistance`, `standardApartment`, `apartmentPoint`, `tropicalLaplacian`, `tropicalSpherical`, `iwahoriGenerator`, `vertexDepth`, `isSpecialVertex`
- **theorem**: `buildingDistance_nonneg`, `buildingDistance_symm`, `buildingDistance_self`, `standardApartment_origin`, `const_harmonic`, `spherical_zero`, ... +7 more

#### `ExceptionalGroups.lean` (190 lines)
*Source: `Tropical/Langlands/ExceptionalGroups.lean`*

- **structure**: `TropicalRootSystem`, `TropicalSatakeParam`
- **inductive**: `LanglandsDualType`
- **def**: `dominantChamber`, `E6_rank`, `E6_num_roots`, `E6_num_positive_roots`, `E6_coxeter_number`, `E6_weyl_order`, ... +17 more
- **theorem**: `root_count_even`, `dominantChamber_convex`, `origin_in_dominantChamber`, `E6_dimension`, `E6_positive_roots_count`, `E6_weyl_factorization`, ... +15 more

#### `Foundations.lean` (408 lines)
*Source: `Tropical/Langlands/Foundations.lean`*

- **structure**: `TropicalCharacter`, `TropicalValuation`, `TropicalSatakeParam`, `TropicalAutomorphicDatum`, `TropicalGaloisDatum`
- **def**: `tropMatMul`, `tropDet`, `tropInvertible`, `trivialValuation`, `tropicalLFunction`, `tropConvolution`, ... +5 more
- **theorem**: `trop_add_comm`, `trop_add_assoc`, `trop_add_zero`, `trop_distrib`, `tropMatMul_assoc`, `tropChar_determined_by_one`, ... +9 more

#### `FunctionField.lean` (119 lines)
*Source: `Tropical/Langlands/FunctionField.lean`*

- **structure**: `TropicalHeckeEigensheaf`
- **def**: `TropicalJacobian`, `abelJacobi`, `linearEigensheaf`, `tropGeometricLanglands_GL1`, `tropHitchinBase`, `tropFunctionFieldDuality`, `tropicalDegree`
- **theorem**: `abelJacobi_linear`, `tropGeoLanglands_injective`, `tropHitchin_fiber_convex`, `tropFunctionFieldDuality_invol`, `tropicalDegree_add`, `tropicalDegree_zero`

#### `FundamentalLemma.lean` (208 lines)
*Source: `Tropical/Langlands/FundamentalLemma.lean`*

- **structure**: `TropicalConjClass`, `EndoscopicDatum`
- **def**: `tropicalOrbitalIntegral`, `tropicalStableOrbitalIntegral`, `tropicalTransferFactor`, `GL1ConjClass`, `GL2ConjClass`, `trivialEndoscopy`, ... +4 more
- **theorem**: `transferFactor_antisymm`, `transferFactor_self`, `GL1_orbital_integral`, `GL1_fundamental_lemma`, `GL2_orbital_integral`, `GL2_fundamental_lemma`, ... +8 more

#### `GraphAutomorphic.lean` (120 lines)
*Source: `Tropical/Langlands/GraphAutomorphic.lean`*

- **def**: `vertexDegree`, `graphLaplacian`, `isHarmonic`, `classicalHeckeOperator`, `GraphDivisor`, `divisorDegree`, ... +4 more
- **theorem**: `graphLaplacian_symmetric`, `hecke_selfadjoint`, `canonical_degree_regular`, `energy_nonneg`, `energy_zero_constant`, `ramanujan_spectral_gap`

#### `HigherRank.lean` (127 lines)
*Source: `Tropical/Langlands/HigherRank.lean`*

- **structure**: `TropicalRootSystem`, `TropicalDoubleCoset`, `TropicalHeckeElement`
- **def**: `positiveRoots`, `dominantChamber`, `isDominantTypeA`, `TropicalSatakeSpace`, `tropLanglandsDualTypeA`, `tropLanglandsDualTypeBC`, `tropParabolicInduction`
- **theorem**: `dominantChamber_convex`, `invariant_factors_sum_eq_tropDet`, `hecke_factors_through_sorted`, `tropLanglandsDual_involution`, `tropLanglandsDual_BC_scaling`, `tropL_parabolic_additive`

#### `LocalLanglands.lean` (172 lines)
*Source: `Tropical/Langlands/LocalLanglands.lean`*

- **structure**: `TropicalWDRep`, `TropicalSmoothRep`
- **def**: `tropicalLLC`, `tropicalLocalL`, `tropicalEpsilon`, `newtonPolygonPoint`, `isUnramified`, `unramifiedWDRep`, `globalToLocal`
- **theorem**: `LLC_preserves_parameters`, `LLC_preserves_sorting`, `localL_zero`, `localL_linear`, `LLC_preserves_L`, `local_functional_equation`, ... +7 more

#### `MachineLearning.lean` (130 lines)
*Source: `Tropical/Langlands/MachineLearning.lean`*

- **def**: `relu`, `tropicalLayer`, `maxPlusLayer`, `dualLayer`, `tropicalLoss`, `tropPolynomial`, `tropicalAttention`
- **theorem**: `relu_convex`, `dualLayer_involution`, `dual_preserves_tropDet`, `tropicalLoss_nonneg`, `tropicalLoss_zero_iff`, `tropicalLoss_triangle`, `tropPolynomial_convex`, `relu_difference_is_pl`

#### `PAdicTropical.lean` (109 lines)
*Source: `Tropical/Langlands/PAdicTropical.lean`*

- **structure**: `NewtonPolygon`, `TropicalPhiModule`, `TropicalFilteredModule`
- **def**: `NewtonPolygon`, `newtonPolygonDistance`, `isWeaklyAdmissible`
- **theorem**: `newtonPolygon_triangle`, `newtonPolygon_dist_symm`, `newtonPolygon_dist_zero`, `trivial_weakly_admissible`, `weaklyAdmissible_directSum`, `constant_slope_monotone`

#### `PeriodsMotives.lean` (160 lines)
*Source: `Tropical/Langlands/PeriodsMotives.lean`*

- **structure**: `TropicalMotive`, `TropicalHodgeStructure`
- **def**: `totalWeight`, `tropicalPeriod`, `motivicLFunction`, `galoisAction`, `hodgeDimension`, `weight1Hodge`, ... +4 more
- **theorem**: `totalWeight_nonneg`, `period_add_cycle`, `period_add_form`, `period_zero_cycle`, `period_zero_form`, `motivicLFunction_eq`, ... +12 more

#### `QuantumTropical.lean` (137 lines)
*Source: `Tropical/Langlands/QuantumTropical.lean`*

- **structure**: `TropicalCrystal`, `LittelmannPath`
- **def**: `crystalDim`, `tropicalRMatrix`, `pathEndpoint`, `straightPath`, `tropicalTensorProduct`, `crystalCharacter`, ... +4 more
- **theorem**: `rMatrix_sorts`, `rMatrix_preserves_sum`, `rMatrix_idempotent`, `sort_preserves_sum`, `straightPath_endpoint`, `tensorProduct_sum`, ... +7 more

#### `ShimuraVarieties.lean` (151 lines)
*Source: `Tropical/Langlands/ShimuraVarieties.lean`*

- **structure**: `TropicalEllipticCurve`, `TropicalAbelianVariety`, `TropicalModularForm`, `TropicalCMPoint`
- **def**: `tropicalJInvariant`, `polarizationDegree`, `TropicalSiegel`, `tropicalEisensteinSeries`, `moduliDimension`, `tropicalHeckeOperator`, `tropicalTateModule`
- **theorem**: `tropical_ec_iso_iff`, `jInvariant_pos`, `polarization_pos`, `siegel_nonempty`, `siegel_convex`, `eisenstein_zero`, ... +5 more

#### `ThetaCorrespondence.lean` (127 lines)
*Source: `Tropical/Langlands/ThetaCorrespondence.lean`*

- **structure**: `LParam`, `TropicalDualPair`, `SeeSaw`
- **def**: `tropicalQuadraticForm`, `tropicalSymplecticForm`, `tropicalThetaKernel`, `tropicalThetaLift`, `tropicalLValue`, `TropicalDualPair`, `TropicalDualPair`, `tropicalWeilAction`
- **theorem**: `symplecticForm_antisymm`, `symplecticForm_self`, `quadraticForm_nonneg`, `quadraticForm_eq_zero_iff`, `thetaKernel_product`, `thetaKernel_add_left`, ... +8 more

### Tropical/NeuralNetworks

*6 files, 335 declarations, 2,903 lines*

#### `TropicalGeneralNetworks.lean` (279 lines)
*Source: `Tropical/Neural/TropicalGeneralNetworks.lean`*

- **def**: `linearLayer`, `relu`, `tAdd`, `tMul`, `residualBlock`, `tropicalRank`, `leakyRelu`, `hardTanh`
- **noncomp. def**: `neuralLayer`, `reluLayer`, `tropInner`, `tropMatVec`, `tropMatMul`, `scaledSoftmax`, ... +4 more
- **theorem**: `reluLayer_eq`, `linear_compose_linear`, `transplant_exact_general`, `residual_tropical_compat`, `residual_recovers_input`, `scaledSoftmax_nonneg`, ... +20 more

#### `TropicalLLMConversion.lean` (404 lines) ⚠️ 1 sorry
*Source: `Tropical/Neural/TropicalLLMConversion.lean`*

- **def**: `tAdd`, `tMul`, `relu`, `linearLayer`, `residualConn`, `causalMask`, ... +7 more
- **noncomp. def**: `softmax`, `scaledSoftmax`, `logSumExp`, `attentionScore`, `layerNormMean`, `geluApprox`, `shannonEntropy`, `tropMatMul`
- **theorem**: `tAdd_comm`, `tAdd_assoc`, `tAdd_idem`, `tMul_comm`, `tMul_assoc`, `tMul_zero_right`, ... +58 more

#### `TropicalNNCompilation.lean` (244 lines) ⚠️ 1 sorry
*Source: `Tropical/Neural/TropicalNNCompilation.lean`*

- **def**: `tadd`, `tmul`, `relu`, `gpt2_vocab`, `gpt2_context`, `gpt2_layers`, `gpt2_tropical_dim`, `koopmanOp`
- **noncomp. def**: `tropMatMul`, `softmax`
- **theorem**: `tadd_comm`, `tadd_assoc`, `tadd_idem`, `tmul_comm`, `tmul_assoc`, `tmul_zero_right`, ... +26 more

#### `TropicalNNFrontier.lean` (1270 lines)
*Source: `Tropical/Neural/TropicalNNFrontier.lean`*

- **def**: `relu`, `softmax_beta`, `logSumExp`, `binaryEntropy`, `tropicalMonomial`, `tropicalPoly`, `tropicalDot`
- **theorem**: `tropical_add_comm`, `tropical_add_assoc`, `tropical_distrib`, `tropical_distrib_right`, `tropical_add_zero_nonneg`, `tropical_distrib_sum`, ... +80 more

#### `TropicalNetworkTheory.lean` (428 lines)
*Source: `Tropical/Neural/TropicalNetworkTheory.lean`*

- **def**: `tAdd`, `tMul`, `tropMatVec`, `tropMatMul`, `IsTropConvex`, `tropClassify`, ... +7 more
- **theorem**: `tAdd_comm`, `tAdd_assoc`, `tMul_comm`, `tMul_assoc`, `tMul_zero_right`, `tMul_zero_left`, ... +27 more

#### `TropicalViTFormalization.lean` (278 lines)
*Source: `Tropical/Neural/TropicalViTFormalization.lean`*

- **def**: `tAdd`, `tMul`, `tropMatVecCoord`, `projNormalize`, `tropMatMul`
- **theorem**: `tAdd_idempotent`, `tMul_distributes`, `logsumexp_ge_max`, `logsumexp_le_max_plus_log`, `projNormalize_max_eq_zero`, `projNormalize_idempotent`, ... +14 more
