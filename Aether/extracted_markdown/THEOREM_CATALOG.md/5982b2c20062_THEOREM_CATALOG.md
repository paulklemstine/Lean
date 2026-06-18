# Grand Unification Theorem Catalog

## Complete Inventory of Machine-Verified Mathematical Results

**Project**: Pythagorean Harmonic Number Theory\n**Formalization**: Lean 4 / Mathlib\n**Total Theorems/Lemmas**: 4937\n**Total Definitions**: 960\n**Total Structures/Classes**: 94\n
---

## Table of Contents

1. [Algebra](#algebra) (19 files, 176 declarations)
2. [Analysis](#analysis) (9 files, 77 declarations)
3. [Applications](#applications) (18 files, 257 declarations)
4. [Combinatorics](#combinatorics) (11 files, 97 declarations)
5. [Core](#core) (24 files, 351 declarations)
6. [DivisionAlgebras](#divisionalgebras) (6 files, 195 declarations)
7. [Dynamics](#dynamics) (3 files, 26 declarations)
8. [Factoring](#factoring) (10 files, 211 declarations)
9. [Geometry](#geometry) (8 files, 73 declarations)
10. [HarmonicNetworks](#harmonicnetworks) (10 files, 286 declarations)
11. [Meta](#meta) (24 files, 790 declarations)
12. [NumberTheory](#numbertheory) (6 files, 83 declarations)
13. [PhotonNetworks](#photonnetworks) (12 files, 413 declarations)
14. [Probability](#probability) (4 files, 28 declarations)
15. [Quantum](#quantum) (21 files, 713 declarations)
16. [Research](#research) (42 files, 1113 declarations)
17. [Stereographic](#stereographic) (9 files, 212 declarations)
18. [Topology](#topology) (6 files, 72 declarations)
19. [Tropical](#tropical) (20 files, 806 declarations)
20. [Uncategorized](#uncategorized) (2 files, 24 declarations)

---

## Algebra

### 📄 Algebra.lean

| Line | Kind | Name |
|------|------|------|
| 19 | 🔵 theorem | `lagrange_theorem` |
| 32 | 🔵 theorem | `prime_order_cyclic` |
| 45 | 🔵 theorem | `irreducible_is_prime_in_pid` |
| 56 | 🔵 theorem | `crt_coprime` |
| 69 | 🔵 theorem | `x_sq_plus_one_irreducible` |

### 📄 AlgebraicKTheory.lean

| Line | Kind | Name |
|------|------|------|
| 7 | 🔵 theorem | `z_units'` |
| 11 | 🔵 theorem | `steinberg_neg1` |
| 14 | 🔵 theorem | `index_euler'` |
| 19 | 🔵 theorem | `ns_energy_bound'` |
| 23 | 🔵 theorem | `ns_scaling'` |
| 26 | 🔵 theorem | `ns_2d_regularity'` |

### 📄 AlgebraicStructures.lean

| Line | Kind | Name |
|------|------|------|
| 14 | 🔵 theorem | `gaussian_norm_mul'` |
| 18 | 🔵 theorem | `zsqrt_neg5_norms` |
| 28 | 🔵 theorem | `factor_diff_squares` |
| 32 | 🔵 theorem | `factor_cube_minus_one` |
| 36 | 🔵 theorem | `factor_fourth_power` |
| 40 | 🔵 theorem | `cyclotomic_6_divides` |
| 46 | 🔵 theorem | `sqrt2_irrational'` |
| 56 | 🔵 theorem | `sqrt3_irrational` |
| 62 | 🔵 theorem | `quaternion_norm_mul'` |
| 69 | 🟡 def | `sl2_e'` |
| 70 | 🟡 def | `sl2_f'` |
| 71 | 🟡 def | `sl2_h'` |
| 74 | 🔵 theorem | `sl2_bracket_ef'` |
| 79 | 🔵 theorem | `sl2_bracket_he'` |
| 84 | 🔵 theorem | `sl2_bracket_hf'` |
| 90 | 🔵 theorem | `sl2_trace_e'` |
| 93 | 🔵 theorem | `sl2_trace_f'` |
| 96 | 🔵 theorem | `sl2_trace_h'` |

### 📄 CategoryRepresentation.lean

| Line | Kind | Name |
|------|------|------|
| 21 | 🔵 theorem | `id_functor_comp` |
| 30 | 🔵 theorem | `functor_comp_assoc` |
| 38 | 🔵 theorem | `iso_has_inverse` |
| 45 | 🔵 theorem | `comp_id_left` |
| 49 | 🔵 theorem | `comp_id_right` |
| 63 | 🔵 theorem | `free_module_dim` |
| 70 | 🔵 theorem | `submodule_finite_dim` |
| 78 | 🔵 theorem | `submodule_dim_le` |
| 86 | 🔵 theorem | `rank_nullity` |
| 103 | 🔵 theorem | `char_at_identity` |
| 112 | 🔵 theorem | `det_one_by_one` |
| 125 | 🔵 theorem | `quotient_dim` |

### 📄 CategoryTheory.lean

| Line | Kind | Name |
|------|------|------|
| 20 | 🔵 theorem | `functor_preserves_iso` |
| 38 | 🔵 theorem | `id_functor_map` |
| 51 | 🔵 theorem | `functor_comp_assoc` |
| 64 | 🔵 theorem | `functor_comp_id` |

### 📄 CategoryTheoryDeep.lean

| Line | Kind | Name |
|------|------|------|
| 9 | 🔵 theorem | `equivalence_is_adjunction` |
| 14 | 🔵 theorem | `nat_trans_assoc` |
| 20 | 🔵 theorem | `adjunction_gives_monad` |
| 29 | 🔵 theorem | `function_comp_assoc` |

### 📄 CategoryTheoryExploration.lean

| Line | Kind | Name |
|------|------|------|
| 10 | 🔵 theorem | `functor_preserves_id` |
| 13 | 🔵 theorem | `functor_preserves_comp` |
| 19 | 🔵 theorem | `finset_product_card` |
| 23 | 🔵 theorem | `finset_sum_card'` |
| 29 | 🔵 theorem | `type_assoc_card` |
| 35 | 🔵 theorem | `exponential_card` |

### 📄 CommutativeAlgebra.lean

| Line | Kind | Name |
|------|------|------|
| 11 | 🔵 theorem | `ideal_mul_le_inf'` |
| 14 | 🔵 theorem | `maximal_is_prime'` |
| 19 | 🔵 theorem | `int_noetherian'` |
| 21 | 🔵 theorem | `quotient_noetherian'` |
| 24 | 🔵 theorem | `polynomial_noetherian'` |
| 29 | 🔵 theorem | `crt_coprime'` |
| 35 | 🔵 theorem | `finite_domain_is_field'` |

### 📄 GaloisTheory.lean

| Line | Kind | Name |
|------|------|------|
| 11 | 🔵 theorem | `gf2_card` |
| 12 | 🔵 theorem | `gf3_card` |
| 14 | 🔵 theorem | `frobenius_endomorphism'` |
| 19 | 🔵 theorem | `cyclotomic_degree'` |
| 23 | 🔵 theorem | `cyclotomic_monic'` |
| 26 | 🔵 theorem | `prod_cyclotomic'` |
| 32 | 🔵 theorem | `tower_degree'` |
| 40 | 🔵 theorem | `complex_over_real_degree'` |

### 📄 GeometricAlgebra.lean

| Line | Kind | Name |
|------|------|------|
| 26 | 🔵 theorem | `dist_symm_real` |
| 36 | 🔵 theorem | `triangle_ineq_R2` |
| 49 | 🔵 theorem | `rotation_det_one` |
| 61 | 🔵 theorem | `rotation_compose` |
| 76 | 🔵 theorem | `isometry_preserves_dist` |
| 88 | 🔵 theorem | `isometry_comp` |

### 📄 HomologicalAlgebra.lean

| Line | Kind | Name |
|------|------|------|
| 16 | 🔵 theorem | `d_squared_zero'` |
| 30 | 🔵 theorem | `euler_char_two'` |
| 34 | 🔵 theorem | `euler_char_three'` |
| 40 | 🔵 theorem | `torus_euler_char'` |
| 43 | 🔵 theorem | `sphere_euler_char'` |
| 46 | 🔵 theorem | `genus_euler_char` |
| 49 | 🔵 theorem | `rp2_euler_char'` |
| 62 | 🔵 theorem | `ses_rank_nullity'` |

### 📄 LieAlgebras.lean

| Line | Kind | Name |
|------|------|------|
| 9 | 🟡 def | `lieBracket2` |
| 13 | 🔵 theorem | `lie_antisymm'` |
| 18 | 🔵 theorem | `lie_self_zero'` |
| 23 | 🔵 theorem | `jacobi_identity'` |
| 30 | 🔵 theorem | `trace_lie_zero'` |
| 35 | 🟡 def | `sl2_e'` |
| 36 | 🟡 def | `sl2_f'` |
| 37 | 🟡 def | `sl2_h'` |
| 39 | 🔵 theorem | `sl2_ef'` |
| 43 | 🔵 theorem | `sl2_he'` |
| 47 | 🔵 theorem | `sl2_traceless'` |
| 51 | 🔵 theorem | `upper_triangular_nilpotent'` |
| 55 | 🔵 theorem | `sl2_not_abelian'` |

### 📄 LinearAlgebra.lean

| Line | Kind | Name |
|------|------|------|
| 18 | 🔵 theorem | `det_mul_eq` |
| 30 | 🔵 theorem | `det_one_pf` |
| 41 | 🔵 theorem | `det_transpose_pf` |
| 55 | 🔵 theorem | `skew_symmetric_trace_zero` |
| 68 | 🔵 theorem | `orthogonal_det` |

### 📄 LinearAlgebraAdvanced.lean

| Line | Kind | Name |
|------|------|------|
| 10 | 🔵 theorem | `det_mul_2x2` |
| 14 | 🔵 theorem | `det_transpose_2x2` |
| 20 | 🔵 theorem | `trace_add_2x2` |
| 26 | 🔵 theorem | `rotation_det_345` |
| 30 | 🔵 theorem | `rotation_preserves_norm_345` |
| 35 | 🟡 def | `nilpotent_2x2` |
| 37 | 🔵 theorem | `nilpotent_squared` |
| 41 | 🟡 def | `proj_2x2` |
| 43 | 🔵 theorem | `proj_idempotent` |
| 49 | 🔵 theorem | `berggren_M1_eigenvalue'` |
| 50 | 🔵 theorem | `rotation_char_poly_eval` |
| 54 | 🔵 theorem | `pauli_x_self_inverse` |

### 📄 LinearAlgebraExploration.lean

| Line | Kind | Name |
|------|------|------|
| 22 | 🔵 theorem | `det_mul_comm` |
| 29 | 🔵 theorem | `det_transpose'` |
| 36 | 🔵 theorem | `det_smul'` |
| 43 | 🔵 theorem | `det_one'` |
| 49 | 🔵 theorem | `det_2x2` |
| 56 | 🔵 theorem | `det_diag_2x2` |
| 67 | 🔵 theorem | `trace_add'` |
| 74 | 🔵 theorem | `trace_smul'` |
| 81 | 🔵 theorem | `trace_mul_comm'` |
| 88 | 🔵 theorem | `trace_one'` |
| 97 | 🟡 def | `nilpotent_2x2` |
| 99 | 🔵 theorem | `nilpotent_2x2_sq` |
| 103 | 🔵 theorem | `nilpotent_2x2_trace` |
| 107 | 🔵 theorem | `nilpotent_2x2_det` |
| 112 | 🟡 def | `rotation_90` |
| 114 | 🔵 theorem | `rotation_90_det` |
| 118 | 🔵 theorem | `rotation_90_sq` |
| 122 | 🔵 theorem | `rotation_90_fourth` |
| 127 | 🟡 def | `proj_2x2` |
| 129 | 🔵 theorem | `proj_idempotent` |
| 133 | 🔵 theorem | `proj_trace` |
| 137 | 🔵 theorem | `proj_det` |
| 147 | 🔵 theorem | `cayley_hamilton_2x2'` |
| 155 | 🔵 theorem | `involution_det` |
| 162 | 🔵 theorem | `complex_structure_det` |
| 175 | 🔵 theorem | `kronecker_diag` |
| 182 | 🔵 theorem | `kronecker_off_diag` |

### 📄 OrderTheory.lean

| Line | Kind | Name |
|------|------|------|
| 7 | 🔵 theorem | `distrib_lattice_meet_sup'` |
| 10 | 🔵 theorem | `modular_law'` |
| 14 | 🔵 theorem | `complement_unique'` |
| 17 | 🔵 theorem | `double_complement'` |
| 20 | 🔵 theorem | `demorgan_inf'` |
| 23 | 🔵 theorem | `demorgan_sup'` |
| 26 | 🔵 theorem | `knaster_tarski_lfp'` |
| 30 | 🔵 theorem | `knaster_tarski_gfp'` |
| 34 | 🔵 theorem | `nat_well_order'` |

### 📄 PolynomialTheory.lean

| Line | Kind | Name |
|------|------|------|
| 20 | 🔵 theorem | `diff_of_squares_poly` |
| 27 | 🔵 theorem | `x2_plus_1_no_root` |
| 33 | 🔵 theorem | `geom_series_poly` |
| 42 | 🔵 theorem | `int_domain` |
| 45 | 🔵 theorem | `int_pid` |
| 50 | 🔵 theorem | `field_unit` |
| 57 | 🔵 theorem | `zmod_field` |
| 64 | 🔵 theorem | `finite_domain_field` |
| 75 | 🔵 theorem | `gf_card_eq` |
| 81 | 🔵 theorem | `fermat_gf_p` |
| 88 | 🔵 theorem | `gf_mult_cyclic` |
| 99 | 🔵 theorem | `x2_minus_2_irred` |
| 121 | 🔵 theorem | `sqrt2_irrat` |

### 📄 RepTheoryDeep.lean

| Line | Kind | Name |
|------|------|------|
| 9 | 🔵 theorem | `dim_sq_sum` |
| 12 | 🔵 theorem | `abelian_irreps_dim` |
| 15 | 🔵 theorem | `pq_gt_one` |
| 22 | 🔵 theorem | `dft_size` |
| 25 | 🔵 theorem | `peter_weyl` |

### 📄 RepresentationTheory.lean

| Line | Kind | Name |
|------|------|------|
| 10 | 🔵 theorem | `sign_rep_identity` |
| 12 | 🔵 theorem | `sign_swap'` |
| 16 | 🔵 theorem | `regular_rep_dim` |
| 21 | 🔵 theorem | `sym2_dim'` |
| 23 | 🔵 theorem | `symn_dim'` |
| 27 | 🔵 theorem | `moonshine_dimension'` |
| 28 | 🔵 theorem | `mckay_first'` |
| 29 | 🔵 theorem | `mckay_second'` |

---

## Analysis

### 📄 Analysis.lean

| Line | Kind | Name |
|------|------|------|
| 24 | 🔵 theorem | `convergent_is_cauchy` |
| 37 | 🔵 theorem | `contraction_has_fixed_point` |
| 61 | 🔵 theorem | `mean_value_theorem` |
| 75 | 🔵 theorem | `ftc_eval` |
| 92 | 🔵 theorem | `exponential_decay_tendsto` |
| 103 | 🔵 theorem | `geometric_series_sum` |
| 116 | 🔵 theorem | `am_gm_two` |
| 127 | 🔵 theorem | `cauchy_schwarz_finset` |

### 📄 AnalysisExploration.lean

| Line | Kind | Name |
|------|------|------|
| 20 | 🔵 theorem | `am_gm_two` |
| 31 | 🔵 theorem | `cauchy_schwarz_finset'` |
| 42 | 🔵 theorem | `power_mean_two` |
| 55 | 🔵 theorem | `inv_n_tendsto` |
| 65 | 🔵 theorem | `geometric_sum_formula` |
| 78 | 🔵 theorem | `basel_partial_sums_bounded` |
| 85 | 🔵 theorem | `exp_pos_everywhere` |
| 88 | 🔵 theorem | `exp_zero_eq_one` |
| 97 | 🔵 theorem | `log_mul_eq` |
| 110 | 🔵 theorem | `binary_entropy_half` |
| 117 | 🔵 theorem | `vieta_example` |
| 121 | 🔵 theorem | `bits_needed_8` |
| 122 | 🔵 theorem | `bits_needed_16` |
| 123 | 🔵 theorem | `bits_needed_1024` |

### 📄 AnalysisInequalities.lean

| Line | Kind | Name |
|------|------|------|
| 22 | 🔵 theorem | `am_gm_two` |
| 29 | 🔵 theorem | `four_ab_le_sq_sum` |
| 35 | 🔵 theorem | `sq_sum_ge_two_prod` |
| 41 | 🔵 theorem | `cauchy_schwarz_fin` |
| 48 | 🔵 theorem | `bernoulli_ineq` |
| 55 | 🔵 theorem | `abs_triangle` |
| 61 | 🔵 theorem | `abs_reverse_triangle` |
| 67 | 🔵 theorem | `young_ineq_sq` |
| 78 | 🔵 theorem | `arithmetic_sum` |
| 85 | 🔵 theorem | `geometric_sum` |
| 96 | 🔵 theorem | `sq_convex_on` |
| 102 | 🔵 theorem | `midpoint_sq` |
| 113 | 🔵 theorem | `dist_zero_iff` |
| 120 | 🔵 theorem | `metric_triangle_ineq` |
| 127 | 🔵 theorem | `dist_symmetric` |

### 📄 FunctionalAnalysis.lean

| Line | Kind | Name |
|------|------|------|
| 18 | 🔵 theorem | `norm_triangle'` |
| 22 | 🔵 theorem | `norm_reverse_triangle'` |
| 26 | 🔵 theorem | `norm_smul_eq'` |
| 33 | 🔵 theorem | `opnorm_comp_le'` |
| 40 | 🔵 theorem | `id_opnorm_le_one'` |
| 47 | 🔵 theorem | `cauchy_schwarz_inner'` |
| 55 | 🔵 theorem | `real_complete'` |
| 58 | 🔵 theorem | `euclidean_complete'` |
| 70 | 🔵 theorem | `banach_fixed_point'` |

### 📄 HarmonicAnalysis.lean

| Line | Kind | Name |
|------|------|------|
| 9 | 🟠 noncomputable def | `discreteConv'` |
| 12 | 🔵 theorem | `conv_delta'` |
| 20 | 🔵 theorem | `trivial_char_sum'` |
| 24 | 🔵 theorem | `sum_sq_nonneg'` |
| 28 | 🔵 theorem | `energy_decomposition'` |

### 📄 MeasureTheory.lean

| Line | Kind | Name |
|------|------|------|
| 13 | 🔵 theorem | `lebesgue_interval_measure` |
| 18 | 🔵 theorem | `measure_mono_example` |
| 24 | 🔵 theorem | `measure_empty_eq_zero'` |
| 31 | 🔵 theorem | `prob_measure_total` |
| 42 | 🔵 theorem | `prob_complement'` |
| 50 | 🔵 theorem | `qubit_normalization` |
| 55 | 🔵 theorem | `cantor_dim_bounds` |

### 📄 NumericalAnalysis.lean

| Line | Kind | Name |
|------|------|------|
| 7 | 🔵 theorem | `newton_qc` |
| 11 | 🔵 theorem | `simpson_cubic` |
| 15 | 🔵 theorem | `euler_stab` |

### 📄 OperatorAlgebras.lean

| Line | Kind | Name |
|------|------|------|
| 7 | 🔵 theorem | `trace_eigenvalue_sum` |
| 11 | 🔵 theorem | `det_eigenvalue_prod` |
| 15 | 🔵 theorem | `trace_cyclic'` |
| 18 | 🔵 theorem | `trace_positive'` |
| 21 | 🔵 theorem | `bott_periodicity'` |
| 24 | 🔵 theorem | `su2_dimension` |
| 27 | 🔵 theorem | `su3_dimension` |
| 30 | 🔵 theorem | `instanton_charge_integer` |

### 📄 SpectralTheory.lean

| Line | Kind | Name |
|------|------|------|
| 14 | 🔵 theorem | `M₁_det_mod` |
| 20 | 🔵 theorem | `M₃_det_mod` |
| 27 | 🔵 theorem | `M₁_ne_inv` |
| 30 | 🔵 theorem | `M₃_ne_inv` |
| 42 | 🔵 theorem | `ramanujan_bound_lt_degree` |
| 46 | 🔵 theorem | `ramanujan_gap_pos` |
| 51 | 🔵 theorem | `M₃_squared` |
| 56 | 🔵 theorem | `M₁_squared` |

---

## Applications

### 📄 Applications.lean

| Line | Kind | Name |
|------|------|------|
| 19 | 🔴 structure | `Codebook'` |
| 25 | 🔵 theorem | `Codebook'.encode_injective` |
| 32 | 🟠 noncomputable def | `binaryCodebook` |
| 39 | 🔵 theorem | `binaryCodebook_injective` |
| 50 | 🟡 def | `dnaCodebook` |
| 66 | 🔵 theorem | `dnaCodebook_injective` |
| 70 | 🔵 theorem | `dna_needs_two_bits` |
| 80 | 🔵 theorem | `two_symbol_optimal` |
| 88 | 🔴 structure | `Run` |
| 94 | 🟡 def | `decodeRuns` |
| 99 | 🔵 theorem | `decodeRuns_singleton_length` |
| 104 | 🔵 theorem | `decodeRuns_append` |
| 114 | 🔵 theorem | `column_encoding_exists` |
| 126 | 🔵 theorem | `identity_always_works` |
| 132 | 🔵 theorem | `compression_ratio_one` |

### 📄 Complexity.lean

| Line | Kind | Name |
|------|------|------|
| 20 | 🔵 theorem | `no_free_lunch_counting` |
| 28 | 🔵 theorem | `count_boolean_functions` |
| 34 | 🔵 theorem | `circuit_counting_bound` |
| 42 | 🔵 theorem | `no_injection_functions_to_circuits` |
| 54 | 🔵 theorem | `most_functions_complex'` |
| 62 | 🔵 theorem | `cantor_diagonal` |
| 71 | 🔵 theorem | `cantor_finite` |
| 85 | 🔵 theorem | `natural_proofs_counting` |
| 102 | 🔵 theorem | `description_complexity_comparison` |

### 📄 Compression.lean

| Line | Kind | Name |
|------|------|------|
| 22 | 🟢 lemma | `card_binary_strings` |
| 30 | 🔵 theorem | `no_injective_compression` |
| 39 | 🔵 theorem | `no_universal_compression` |
| 46 | 🟢 lemma | `card_shorter_strings` |
| 52 | 🔵 theorem | `incompressible_strings_lower_bound` |
| 58 | 🔵 theorem | `incompressible_fraction_bound` |
| 66 | 🔴 structure | `Codebook` |
| 72 | 🔵 theorem | `Codebook.encode_injective` |
| 77 | 🟡 def | `Codebook.identity` |
| 83 | 🟠 noncomputable def | `Codebook.ofEquiv` |
| 91 | 🔵 theorem | `codebook_exists_of_card_le` |
| 104 | 🔵 theorem | `kraft_inequality_nat` |
| 121 | 🟠 noncomputable def | `shannonEntropy` |
| 125 | 🔵 theorem | `shannonEntropy_nonneg` |

### 📄 CompressionExtensions.lean

| Line | Kind | Name |
|------|------|------|
| 32 | 🔵 theorem | `generalized_pigeonhole` |
| 39 | 🔵 theorem | `double_counting_card` |
| 48 | 🔵 theorem | `no_embed_larger_vector_space` |
| 53 | 🔵 theorem | `subspace_vs_total` |
| 60 | 🔵 theorem | `random_incompressible_bound` |
| 66 | 🔵 theorem | `total_shorter_strings` |
| 79 | 🔵 theorem | `covering_lower_bound` |
| 86 | 🔵 theorem | `metric_entropy_monotone` |
| 97 | 🔵 theorem | `kolmogorov_counting` |
| 102 | 🔵 theorem | `kolmogorov_typical` |
| 113 | 🔵 theorem | `prg_not_surjective` |
| 123 | 🔵 theorem | `prg_range_bound` |
| 135 | 🔵 theorem | `finite_invariance_of_domain` |
| 147 | 🔵 theorem | `digit_bound` |
| 152 | 🔵 theorem | `numbers_needing_k_digits` |
| 178 | 🔵 theorem | `prime_encoding_bound` |
| 190 | 🔵 theorem | `singleton_bound` |
| 197 | 🔵 theorem | `plotkin_consequence` |

### 📄 CompressionTheory.lean

| Line | Kind | Name |
|------|------|------|
| 33 | 🔵 theorem | `no_injection_larger_to_smaller` |
| 41 | 🔵 theorem | `universal_compression_impossible` |
| 48 | 🔵 theorem | `no_compress_all_strings` |
| 63 | 🔵 theorem | `pigeonhole_collision_count` |
| 75 | 🔵 theorem | `incompressible_strings_lower_bound` |
| 88 | 🔵 theorem | `incompressible_fraction` |
| 94 | 🔵 theorem | `incompressible_8bit_to_1bit` |
| 101 | 🔵 theorem | `max_compressible_count` |
| 112 | 🔵 theorem | `codebook_exists` |
| 119 | 🔵 theorem | `codebook_bijection` |
| 124 | 🔵 theorem | `source_encoding_sufficient` |
| 134 | 🔵 theorem | `prefix_free_min_length` |
| 145 | 🔵 theorem | `data_processing_inequality` |
| 151 | 🔵 theorem | `data_processing_composition` |
| 159 | 🔵 theorem | `injective_preserves_card` |
| 170 | 🔵 theorem | `source_coding_achievability` |
| 177 | 🔵 theorem | `source_coding_converse` |
| 184 | 🔵 theorem | `function_count` |
| 190 | 🔵 theorem | `no_compress_4_to_3` |
| 195 | 🔵 theorem | `no_compress_8_to_7` |
| 200 | 🔵 theorem | `no_compress_16_to_15` |
| 208 | 🔵 theorem | `lossless_requires_injective` |
| 217 | 🔵 theorem | `lossless_compression_limit` |
| 230 | 🔵 theorem | `recompression_futile` |

### 📄 ComputabilityTheory.lean

| Line | Kind | Name |
|------|------|------|
| 7 | 🔵 theorem | `cantor_diag` |
| 11 | 🔵 theorem | `incompressible` |
| 14 | 🔵 theorem | `iof_step` |

### 📄 CryptographyApplications.lean

| Line | Kind | Name |
|------|------|------|
| 17 | 🔵 theorem | `rsa_key_ex1` |
| 18 | 🔵 theorem | `rsa_correct_15` |
| 19 | 🔵 theorem | `rsa_key_ex2` |
| 20 | 🔵 theorem | `euler_thm_15` |
| 29 | 🔵 theorem | `dh_correct` |
| 36 | 🔵 theorem | `primitive_root_3_7` |
| 49 | 🟡 def | `hammingDistance` |
| 52 | 🔵 theorem | `hamming_self_zero` |
| 57 | 🔵 theorem | `hamming_symmetric` |
| 68 | 🔵 theorem | `hamming_tri` |
| 76 | 🔵 theorem | `rep_code_distance` |
| 84 | 🔵 theorem | `std_lattice_det_eq` |
| 93 | 🔵 theorem | `birthday_bound_val` |
| 95 | 🔵 theorem | `iter_inj` |

### 📄 CryptographyFoundations.lean

| Line | Kind | Name |
|------|------|------|
| 13 | 🔵 theorem | `dlog_example_1` |
| 16 | 🔵 theorem | `primitive_root_3_7` |
| 24 | 🔵 theorem | `primitive_root_2_5` |
| 33 | 🔵 theorem | `rsa_small_keygen` |
| 37 | 🔵 theorem | `rsa_roundtrip` |
| 42 | 🔵 theorem | `ecc_point_on_curve` |
| 48 | 🔵 theorem | `hash_collisions_exist` |
| 53 | 🔵 theorem | `birthday_bound_squared` |
| 58 | 🔵 theorem | `minkowski_example` |
| 63 | 🔵 theorem | `rsa_2048_size` |

### 📄 DriftFreeIMU.lean

| Line | Kind | Name |
|------|------|------|
| 25 | 🔵 theorem | `group_reversal_identity` |
| 30 | 🔵 theorem | `trace_identity_eq` |
| 37 | 🔵 theorem | `imu_checksum` |

### 📄 ECDLP.lean

| Line | Kind | Name |
|------|------|------|
| 37 | 🟡 def | `secp256k1_p` |
| 42 | 🟡 def | `secp256k1_n` |
| 46 | 🟡 def | `secp256k1_a` |
| 50 | 🟡 def | `secp256k1_b` |
| 53 | 🟡 def | `secp256k1_Gx` |
| 57 | 🟡 def | `secp256k1_Gy` |
| 61 | 🟡 def | `secp256k1_h` |
| 66 | 🔵 theorem | `secp256k1_p_gt_two` |
| 70 | 🔵 theorem | `secp256k1_p_odd` |
| 74 | 🔵 theorem | `secp256k1_p_mod_4` |
| 78 | 🔵 theorem | `secp256k1_p_bit_length` |
| 82 | 🔵 theorem | `secp256k1_n_bit_length` |
| 86 | 🔵 theorem | `secp256k1_n_lt_p` |
| 92 | 🔵 theorem | `secp256k1_hasse_bound_squared` |
| 97 | 🔵 theorem | `secp256k1_generator_on_curve` |
| 102 | 🔵 theorem | `secp256k1_n_odd` |
| 106 | 🔵 theorem | `secp256k1_cofactor_one` |
| 119 | 🔵 theorem | `classical_security_128_bits` |
| 124 | 🔵 theorem | `private_key_space` |
| 147 | 🟡 def | `shor_ecdlp_logical_qubits` |
| 150 | 🔵 theorem | `shor_secp256k1_logical_qubits` |
| 156 | 🟡 def | `physical_qubits_per_logical` |
| 160 | 🔵 theorem | `total_physical_qubits_secp256k1` |
| 166 | 🟡 def | `current_max_qubits_2024` |
| 170 | 🔵 theorem | `quantum_gap_factor` |
| 174 | 🔵 theorem | `logical_qubits_exceed_current` |
| 186 | 🟡 def | `qft_gate_count` |
| 189 | 🔵 theorem | `qft_256` |
| 193 | 🟡 def | `mod_mult_gates` |
| 196 | 🟡 def | `point_add_gates` |
| 199 | 🟡 def | `point_mult_gates` |
| 203 | 🟡 def | `shor_ecdlp_total_gates` |
| 207 | 🔵 theorem | `shor_secp256k1_gate_count` |
| 213 | 🔵 theorem | `shor_runtime_seconds` |
| 232 | 🟡 def | `ecdlp_extract` |
| 236 | 🔵 theorem | `extraction_classical_complexity` |
| 247 | 🔵 theorem | `insufficient_qubits_theorem` |
| 259 | 🔵 theorem | `quantum_volume_cubic` |
| 271 | 🔵 theorem | `doubling_key_size_effect` |
| 288 | 🟡 def | `lattice_security_dimension` |
| 292 | 🔵 theorem | `lattice_classical_hardness` |
| 299 | 🔵 theorem | `lattice_quantum_still_hard` |
| 311 | 🔵 theorem | `fermat_little_mod7` |
| 316 | 🔵 theorem | `fermat_inverse_mod7` |
| 320 | 🔵 theorem | `wilson_5` |
| 321 | 🔵 theorem | `wilson_7` |
| 322 | 🔵 theorem | `wilson_11` |
| 337 | 🟡 def | `on_curve` |
| 341 | 🟡 def | `on_secp256k1_curve` |
| 346 | 🔵 theorem | `secp256k1_discriminant_nonzero` |
| 351 | 🔵 theorem | `secp256k1_j_invariant_zero` |
| 362 | 🔵 theorem | `quantum_speedup_factor` |
| 369 | 🔵 theorem | `grover_vs_shor` |
| 374 | 🔵 theorem | `shor_exponential_advantage` |
| 384 | 🟡 def | `years_to_target` |
| 388 | 🔵 theorem | `years_to_break_secp256k1` |
| 392 | 🔵 theorem | `qubit_ratio` |
| 395 | 🔵 theorem | `doublings_needed` |
| 399 | 🔵 theorem | `minimum_timeline` |
| 408 | 🔵 theorem | `quantum_security_bits` |
| 413 | 🔵 theorem | `qubit_bottleneck` |

### 📄 MathBiology.lean

| Line | Kind | Name |
|------|------|------|
| 7 | 🔵 theorem | `logistic_fp` |
| 12 | 🔵 theorem | `logistic_stab` |
| 16 | 🔵 theorem | `lv_fp` |
| 21 | 🔵 theorem | `sir_cons` |
| 26 | 🔵 theorem | `herd_imm` |
| 32 | 🔵 theorem | `hd_ess` |

### 📄 ModelTheory.lean

| Line | Kind | Name |
|------|------|------|
| 13 | 🔵 theorem | `addgroup_theory_consistent` |
| 17 | 🔵 theorem | `field_theory_consistent` |
| 21 | 🔵 theorem | `acf0_consistent` |
| 27 | 🔵 theorem | `rat_dense` |
| 33 | 🔵 theorem | `powerset_card` |
| 40 | 🔵 theorem | `lagrange_divides` |
| 46 | 🔵 theorem | `order_divides_card` |
| 53 | 🔵 theorem | `countable_field_exists` |
| 57 | 🔵 theorem | `countable_infinite_domain` |
| 64 | 🔵 theorem | `composite_iff` |

### 📄 OptimizationConvexity.lean

| Line | Kind | Name |
|------|------|------|
| 19 | 🔵 theorem | `convex_inter_sets` |
| 27 | 🔵 theorem | `convex_Icc_interval` |
| 37 | 🔵 theorem | `convexOn_max_fn` |
| 45 | 🔵 theorem | `linear_is_convex` |
| 53 | 🔵 theorem | `linear_is_concave` |
| 59 | 🔵 theorem | `sq_strict_convex` |
| 68 | 🔵 theorem | `zero_sum` |
| 72 | 🔵 theorem | `prisoners_dilemma` |
| 76 | 🔵 theorem | `minimax_ex` |
| 88 | 🔵 theorem | `finite_argmax_exists` |

### 📄 OptimizationTheory.lean

| Line | Kind | Name |
|------|------|------|
| 20 | 🔵 theorem | `sq_convex` |
| 31 | 🔵 theorem | `jensen_sq` |
| 42 | 🔵 theorem | `gate_count_lower_bound` |
| 48 | 🔵 theorem | `trace_linear_2x2` |
| 55 | 🔵 theorem | `gd_quadratic_one_step` |

### 📄 PvsNP.lean

| Line | Kind | Name |
|------|------|------|
| 49 | 🟡 def | `SubsetSum` |
| 53 | ⚪ instance | `SubsetSum.instDecidable` |
| 72 | 🟡 def | `verifySubsetSum` |
| 77 | 🔵 theorem | `subsetSum_iff_exists_certificate` |
| 85 | 🔵 theorem | `num_subsets` |
| 89 | 🔵 theorem | `exponential_exceeds_linear` |
| 98 | 🔵 theorem | `berggren_nodes_at_depth` |
| 108 | 🔵 theorem | `berggren_superpolynomial` |
| 124 | 🔵 theorem | `subset_enumeration_exponential` |
| 137 | 🔵 theorem | `no_poly_covering` |
| 154 | 🔵 theorem | `empty_subset_sum` |
| 158 | 🔵 theorem | `full_subset_sum` |

### 📄 RealWorldApplications.lean

| Line | Kind | Name |
|------|------|------|
| 22 | 🔵 theorem | `dft2_squared` |
| 29 | 🔵 theorem | `poly_mul_comm_int` |
| 33 | 🔵 theorem | `parseval_ex` |
| 36 | 🔵 theorem | `nyquist_dim` |
| 45 | 🔵 theorem | `nilpotent_stable` |
| 56 | 🔵 theorem | `gd_key_ineq` |
| 61 | 🔵 theorem | `softmax_ex` |
| 68 | 🔵 theorem | `energy_cons` |
| 74 | 🔵 theorem | `comm_mat_zero` |
| 79 | 🔵 theorem | `energy_additive` |
| 87 | 🔵 theorem | `arrow_ord` |
| 92 | 🔵 theorem | `econ_argmax` |
| 101 | 🔵 theorem | `sort_lower` |
| 104 | 🔵 theorem | `gcd_step` |

### 📄 SetTheory.lean

| Line | Kind | Name |
|------|------|------|
| 23 | 🔵 theorem | `cantor_no_surjection` |
| 35 | 🔵 theorem | `nat_int_equipollent` |
| 45 | 🔵 theorem | `nat_countable` |
| 55 | 🔵 theorem | `real_uncountable` |
| 67 | 🔵 theorem | `nat_well_ordered` |
| 78 | 🔵 theorem | `strong_induction` |
| 91 | 🔵 theorem | `de_morgan_union` |
| 99 | 🔵 theorem | `de_morgan_inter` |

### 📄 SetTheoryLogic.lean

| Line | Kind | Name |
|------|------|------|
| 25 | 🔵 theorem | `de_morgan_union` |
| 36 | 🔵 theorem | `de_morgan_inter` |
| 47 | 🔵 theorem | `set_distrib_left` |
| 58 | 🔵 theorem | `set_distrib_right` |
| 65 | 🔵 theorem | `compl_compl'` |
| 71 | 🔵 theorem | `absorption_union` |
| 78 | 🔵 theorem | `absorption_inter` |
| 93 | 🔵 theorem | `cantor_no_surjection` |
| 101 | 🔵 theorem | `nat_countable` |
| 107 | 🔵 theorem | `int_countable` |
| 113 | 🔵 theorem | `rat_countable` |
| 119 | 🔵 theorem | `real_uncountable` |
| 125 | 🔵 theorem | `finite_is_countable` |
| 131 | 🔵 theorem | `card_fin'` |
| 137 | 🔵 theorem | `card_bool` |
| 143 | 🔵 theorem | `card_fin_to_bool` |
| 153 | 🔵 theorem | `nat_well_ordered` |
| 164 | 🔵 theorem | `strong_induction` |
| 176 | 🔵 theorem | `injective_comp'` |
| 184 | 🔵 theorem | `surjective_comp'` |
| 192 | 🔵 theorem | `bijective_has_inverse` |

---

## Combinatorics

### 📄 AdditiveCombinatorics.lean

| Line | Kind | Name |
|------|------|------|
| 15 | 🟡 def | `sumset'` |
| 22 | 🔵 theorem | `schur_two_colors` |
| 31 | 🔵 theorem | `singleton_ap_free` |
| 41 | 🔵 theorem | `sum_binomial` |
| 48 | 🔵 theorem | `gcd_divides_N` |
| 52 | 🔵 theorem | `factor_divides` |
| 57 | 🔵 theorem | `pigeonhole_intersection` |

### 📄 ArithmeticCombinatorics.lean

| Line | Kind | Name |
|------|------|------|
| 11 | 🟡 def | `sumset'` |
| 14 | 🔵 theorem | `sumset_card_le_mul'` |
| 20 | 🔵 theorem | `ap_compression_ratio'` |
| 23 | 🔵 theorem | `compression_pigeonhole'` |

### 📄 CodingTheory.lean

| Line | Kind | Name |
|------|------|------|
| 19 | 🔵 theorem | `singleton_bound_abstract` |
| 27 | 🟡 def | `hammingDist'` |
| 31 | 🔵 theorem | `hammingDist'_comm` |
| 36 | 🔵 theorem | `hammingDist'_eq_zero` |
| 42 | 🔵 theorem | `hammingDist'_le` |
| 48 | 🔵 theorem | `hammingDist'_triangle` |
| 62 | 🟠 noncomputable def | `hammingBallVolume` |
| 66 | 🔵 theorem | `hammingBallVolume_pos` |
| 76 | 🔵 theorem | `hamming_bound_abstract` |
| 107 | 🔵 theorem | `plotkin_bound` |
| 149 | 🔵 theorem | `compression_correction_tradeoff` |

### 📄 Combinatorics.lean

| Line | Kind | Name |
|------|------|------|
| 22 | 🔵 theorem | `generalized_pigeonhole` |
| 41 | 🔵 theorem | `pigeonhole_not_injective` |
| 50 | 🔵 theorem | `double_counting` |
| 59 | 🔵 theorem | `sum_binomial'` |
| 64 | 🔵 theorem | `partial_binomial_sum_le` |
| 78 | 🔵 theorem | `sperner_bound` |
| 101 | 🟡 def | `shatters'` |
| 110 | 🔵 theorem | `sauer_shelah'` |
| 145 | 🔵 theorem | `lym_inequality` |
| 167 | 🔵 theorem | `compression_from_pigeonhole` |

### 📄 ExtremalGraphTheory.lean

| Line | Kind | Name |
|------|------|------|
| 9 | 🔵 theorem | `turan_3_2` |
| 10 | 🔵 theorem | `turan_4_2` |
| 11 | 🔵 theorem | `turan_6_2` |
| 14 | 🔵 theorem | `windmill_center_degree` |
| 17 | 🔵 theorem | `ramsey_3_4_lower` |
| 18 | 🔵 theorem | `ramsey_4_4_value` |
| 21 | 🟡 def | `tower` |
| 25 | 🔵 theorem | `tower_0` |
| 26 | 🔵 theorem | `tower_1` |
| 27 | 🔵 theorem | `tower_2` |
| 28 | 🔵 theorem | `tower_3` |
| 29 | 🔵 theorem | `tower_4` |
| 31 | 🔵 theorem | `tower_monotone` |

### 📄 GameTheory.lean

| Line | Kind | Name |
|------|------|------|
| 11 | 🟡 def | `pd_payoff'` |
| 17 | 🔵 theorem | `defect_dominant_p1'` |
| 21 | 🔵 theorem | `defect_dominant_p2'` |
| 25 | 🟡 def | `mp_payoff'` |
| 32 | 🔵 theorem | `matching_pennies_no_pure_ne'` |
| 37 | 🔵 theorem | `second_price_truthful'` |
| 42 | 🔵 theorem | `shapley_efficiency_2player'` |
| 47 | 🔵 theorem | `finite_strategies'` |

### 📄 GraphTheoryExploration.lean

| Line | Kind | Name |
|------|------|------|
| 10 | 🔵 theorem | `complete_graph_edges_3` |
| 14 | 🔵 theorem | `complete_graph_edges_4` |
| 18 | 🔵 theorem | `complete_graph_edges_5` |
| 24 | 🔵 theorem | `euler_tetrahedron` |
| 25 | 🔵 theorem | `euler_cube` |
| 26 | 🔵 theorem | `euler_octahedron` |
| 27 | 🔵 theorem | `euler_dodecahedron` |
| 28 | 🔵 theorem | `euler_icosahedron` |
| 31 | 🔵 theorem | `platonic_solids_count` |
| 40 | 🔵 theorem | `schur_2'` |
| 47 | 🔵 theorem | `k23_vertices` |
| 48 | 🔵 theorem | `k23_edges` |

### 📄 MatroidTheory.lean

| Line | Kind | Name |
|------|------|------|
| 9 | 🔴 structure | `RankFunction` |
| 15 | 🔵 theorem | `rank_empty'` |
| 19 | 🔵 theorem | `rank_le_ground'` |
| 27 | 🔵 theorem | `rank_unit_increase'` |
| 39 | 🔵 theorem | `greedy_comparison'` |

### 📄 RamseyTheory.lean

| Line | Kind | Name |
|------|------|------|
| 26 | 🔵 theorem | `ramsey_3_3_upper` |
| 51 | 🔵 theorem | `ramsey_3_3_lower` |
| 71 | 🔵 theorem | `schur_two_colors` |
| 86 | 🔵 theorem | `pigeonhole_mod` |
| 92 | 🔵 theorem | `five_ints_mod4` |
| 106 | 🔵 theorem | `combinatorial_line_exists` |

### 📄 SauerShelah.lean

| Line | Kind | Name |
|------|------|------|
| 9 | 🟡 def | `Shatters` |
| 13 | 🟡 def | `proj` |
| 17 | 🟡 def | `embed` |
| 31 | 🟢 lemma | `last_not_mem_embed` |
| 39 | 🟢 lemma | `proj_embed` |
| 47 | 🟢 lemma | `proj_embed_union_last` |
| 55 | 🟢 lemma | `embed_card` |
| 62 | 🟢 lemma | `embed_union_last_card` |
| 70 | 🟢 lemma | `embed_inter_eq` |
| 84 | 🟢 lemma | `eq_embed_proj_of_last_not_mem` |
| 94 | 🟢 lemma | `eq_embed_proj_union_last` |
| 120 | 🟢 lemma | `shatters_embed_of_union` |
| 151 | 🟢 lemma | `shatters_embed_union_last_of_inter` |
| 203 | 🟢 lemma | `card_split` |
| 228 | 🟢 lemma | `binomial_pascal_sum` |
| 240 | 🟢 lemma | `card_le_one_of_vc_zero` |
| 256 | 🔵 theorem | `sauer_shelah` |

### 📄 SpectralGraphTheory.lean

| Line | Kind | Name |
|------|------|------|
| 7 | 🔵 theorem | `petersen_eig` |
| 10 | 🔵 theorem | `path_ac` |
| 13 | 🔵 theorem | `bin_tree` |
| 21 | 🔵 theorem | `tern_tree` |

---

## Core

### 📄 AgentAlpha_Invariants.lean

| Line | Kind | Name |
|------|------|------|
| 28 | 🟡 def | `euclidTriple` |
| 32 | 🔵 theorem | `euclid_is_pythagorean` |
| 39 | 🔵 theorem | `euclid_inradius_num` |
| 45 | 🔵 theorem | `euclid_perimeter` |
| 51 | 🔵 theorem | `euclid_twice_area` |
| 57 | 🔵 theorem | `euclid_twice_area_factored` |
| 71 | 🔵 theorem | `pyth_inradius_identity` |
| 75 | 🔵 theorem | `pyth_sum_minus_hyp_nonneg` |
| 80 | 🔵 theorem | `pyth_triangle_strict` |
| 92 | 🔵 theorem | `pyth_inradius_even` |
| 105 | 🔵 theorem | `consecutive_even` |
| 116 | 🔵 theorem | `euclid_leg_product_div4` |
| 128 | 🔵 theorem | `berggren_M1_perimeter` |
| 132 | 🔵 theorem | `berggren_M2_perimeter` |
| 136 | 🔵 theorem | `berggren_M3_perimeter` |
| 140 | 🔵 theorem | `berggren_M1_inradius_num` |
| 145 | 🔵 theorem | `berggren_M2_inradius_num` |
| 149 | 🔵 theorem | `berggren_M3_inradius_num` |
| 155 | 🔵 theorem | `inradius_num_product` |
| 160 | 🔵 theorem | `children_inradius_sum` |
| 171 | 🔵 theorem | `children_inradius_product` |
| 178 | 🔵 theorem | `euclid_defect1` |
| 182 | 🔵 theorem | `euclid_defect2` |
| 187 | 🔵 theorem | `defect_product_eq_twice_inradius_sq` |
| 192 | 🔵 theorem | `defect_product_general` |
| 204 | 🔵 theorem | `consecutive_leg_a` |
| 208 | 🔵 theorem | `consecutive_hyp_minus_leg` |
| 212 | 🔵 theorem | `consecutive_hyp` |
| 216 | 🔵 theorem | `consecutive_inradius_num` |
| 227 | 🔵 theorem | `five_reps` |

### 📄 AgentBeta_TreeDynamics.lean

| Line | Kind | Name |
|------|------|------|
| 33 | 🔵 theorem | `berggren_M1_hyp_increase` |
| 39 | 🔵 theorem | `berggren_M2_hyp_increase` |
| 49 | 🔵 theorem | `berggren_M3_hyp_increase` |
| 59 | 🔵 theorem | `berggren_M2_pos_a` |
| 62 | 🔵 theorem | `berggren_M2_pos_b` |
| 65 | 🔵 theorem | `berggren_M2_pos_c` |
| 70 | 🔵 theorem | `berggren_M1_pos_a` |
| 75 | 🔵 theorem | `berggren_M1_pos_b` |
| 80 | 🔵 theorem | `berggren_M3_pos_a` |
| 85 | 🔵 theorem | `berggren_M3_pos_b` |
| 95 | 🟡 def | `pathsAtDepth` |
| 106 | 🔵 theorem | `pathsAtDepth_length` |
| 114 | 🟡 def | `m2_branch` |
| 129 | 🔵 theorem | `m2_branch_pyth` |
| 139 | 🔵 theorem | `children_hyp_sum` |
| 144 | 🔵 theorem | `children_leg_a_sum` |
| 148 | 🔵 theorem | `children_leg_b_sum` |
| 152 | 🔵 theorem | `children_perimeter_sum` |
| 172 | 🔵 theorem | `m2_hyp_recurrence` |
| 183 | 🟡 def | `m2_perimeter` |
| 200 | 🔵 theorem | `min_hyp_growth` |

### 📄 AgentEpsilon_Synthesis.lean

| Line | Kind | Name |
|------|------|------|
| 35 | 🔵 theorem | `gaussian_norm_multiplicative` |
| 41 | 🔵 theorem | `brahmagupta_fibonacci` |
| 46 | 🔵 theorem | `brahmagupta_fibonacci'` |
| 53 | 🔵 theorem | `rational_circle_point` |
| 60 | 🔵 theorem | `stereographic_parametrization` |
| 74 | 🔵 theorem | `stereographic_euclid` |
| 90 | 🔵 theorem | `berggren_M1_lorentz_full` |
| 95 | 🔵 theorem | `berggren_M2_lorentz_full` |
| 100 | 🔵 theorem | `berggren_M3_lorentz_full` |
| 107 | 🔵 theorem | `neg_one_qr_mod5` |
| 110 | 🔵 theorem | `neg_one_qr_mod13` |
| 113 | 🔵 theorem | `neg_one_qr_mod17` |
| 116 | 🔵 theorem | `neg_one_qr_mod29` |
| 119 | 🔵 theorem | `neg_one_nqr_mod3` |
| 122 | 🔵 theorem | `neg_one_nqr_mod7` |
| 125 | 🔵 theorem | `neg_one_nqr_mod11` |
| 128 | 🔵 theorem | `neg_one_nqr_mod19` |
| 140 | 🔵 theorem | `euler_four_sq` |
| 153 | 🔵 theorem | `pythagorean_triangle_ineq` |
| 158 | 🔵 theorem | `pythagorean_hyp_largest_a` |
| 162 | 🔵 theorem | `pythagorean_hyp_largest_b` |
| 173 | 🔵 theorem | `two_representations` |
| 191 | 🔵 theorem | `hyp_5_mod4` |
| 192 | 🔵 theorem | `hyp_13_mod4` |
| 193 | 🔵 theorem | `hyp_17_mod4` |
| 194 | 🔵 theorem | `hyp_29_mod4` |
| 195 | 🔵 theorem | `hyp_25_mod4` |
| 196 | 🔵 theorem | `hyp_37_mod4` |

### 📄 AgentResearch.lean

| Line | Kind | Name |
|------|------|------|
| 25 | 🔵 theorem | `expected_fixed_points_v2` |
| 28 | 🟡 def | `idempotentCount_v2` |
| 31 | 🔵 theorem | `idempotent_count_0_v2` |
| 32 | 🔵 theorem | `idempotent_count_1_v2` |
| 33 | 🔵 theorem | `idempotent_count_2_v2` |
| 34 | 🔵 theorem | `idempotent_count_3_v2` |
| 36 | 🔵 theorem | `oracle_density_3_v2` |
| 40 | 🔵 theorem | `contraction_rate_v2` |
| 46 | 🔵 theorem | `prime_count_bound_v2` |
| 50 | 🔵 theorem | `pi_10_v2` |
| 51 | 🔵 theorem | `pi_100_v2` |
| 55 | 🔵 theorem | `grover_speedup_v2` |
| 60 | 🔴 structure | `ApproxOracleV2` |
| 70 | 🟡 def | `collatz_v2` |
| 76 | 🔵 theorem | `bertrand_postulate_v2` |
| 80 | 🟡 def | `goldbachCheck_v2` |
| 83 | 🔵 theorem | `goldbach_verified_v2` |
| 88 | 🔵 theorem | `truth_oracle_is_em_v2` |
| 90 | 🔵 theorem | `strange_loop_of_truth_v2` |

### 📄 Basic.lean

| Line | Kind | Name |
|------|------|------|
| 15 | 🔴 structure | `PythTriple where` |
| 25 | 🔴 structure | `PPT extends PythTriple where` |
| 39 | 🔵 theorem | `euclid_parametrization` |
| 51 | 🔵 theorem | `pyth_identity_int` |
| 67 | 🔵 theorem | `quartic_from_pyth` |
| 81 | 🔵 theorem | `pyth_diff_sq` |
| 89 | 🔵 theorem | `pyth_diff_sq'` |
| 113 | 🔵 theorem | `congruent_number_scaled` |
| 120 | 🔵 theorem | `triple_345` |
| 123 | 🔵 theorem | `triple_5_12_13` |
| 126 | 🔵 theorem | `triple_8_15_17` |
| 129 | 🔵 theorem | `triple_7_24_25` |

### 📄 Berggren.lean

| Line | Kind | Name |
|------|------|------|
| 17 | 🟡 def | `B₁` |
| 21 | 🟡 def | `B₂` |
| 25 | 🟡 def | `B₃` |
| 31 | 🟡 def | `M₁` |
| 35 | 🟡 def | `M₂` |
| 39 | 🟡 def | `M₃` |
| 45 | 🔵 theorem | `det_M₁` |
| 49 | 🔵 theorem | `det_M₂` |
| 53 | 🔵 theorem | `det_M₃` |
| 61 | 🟡 def | `Q_lorentz` |
| 65 | 🔵 theorem | `B₁_preserves_lorentz` |
| 69 | 🔵 theorem | `B₂_preserves_lorentz` |
| 73 | 🔵 theorem | `B₃_preserves_lorentz` |
| 87 | 🔵 theorem | `B₁_preserves_pyth` |
| 98 | 🔵 theorem | `B₂_preserves_pyth` |
| 109 | 🔵 theorem | `B₃_preserves_pyth` |
| 116 | 🟡 def | `S_mat` |
| 120 | 🔵 theorem | `det_B₁` |
| 123 | 🔵 theorem | `det_B₂` |
| 126 | 🔵 theorem | `det_B₃` |
| 131 | 🟡 def | `M₃_inv` |
| 135 | 🔵 theorem | `M₃_inv_mul_M₃` |
| 140 | 🔵 theorem | `M₃_mul_M₃_inv` |
| 145 | 🔵 theorem | `M₃_inv_M₁_eq_S` |

### 📄 BerggrenTree.lean

| Line | Kind | Name |
|------|------|------|
| 23 | 🔴 structure | `PythTriple where` |
| 29 | ⚪ instance | `: Repr PythTriple where` |
| 33 | 🔵 theorem | `berggren_A_pyth_eq` |
| 39 | 🔵 theorem | `berggren_B_pyth_eq` |
| 45 | 🔵 theorem | `berggren_C_pyth_eq` |
| 51 | 🟡 def | `rootTriple` |
| 66 | 🟡 def | `TreePath.depth` |
| 74 | 🟡 def | `berggrenTripleAux` |
| 87 | 🟡 def | `berggrenA` |
| 90 | 🟡 def | `berggrenB` |
| 93 | 🟡 def | `berggrenC` |
| 105 | 🔵 theorem | `berggrenTripleAux_pyth` |
| 118 | 🟡 def | `treeTriplesAtDepth` |
| 141 | 🔵 theorem | `berggren_A_iff` |
| 154 | 🔵 theorem | `berggren_B_iff` |
| 167 | 🔵 theorem | `berggren_C_iff` |
| 188 | 🔵 theorem | `hypotenuse_growth` |

### 📄 BrahmaguptaFibonacci.lean

| Line | Kind | Name |
|------|------|------|
| 24 | 🔵 theorem | `brahmagupta_fibonacci` |
| 36 | 🔵 theorem | `brahmagupta_fibonacci'` |
| 48 | 🔵 theorem | `gaussian_product_preserves_sum_of_squares` |
| 62 | 🔵 theorem | `gaussian_norm_multiplicative` |

### 📄 Computations.lean

| Line | Kind | Name |
|------|------|------|
| 15 | 🟡 def | `countDivisorsMod4` |
| 19 | 🟡 def | `complexSignal` |
| 23 | 🟡 def | `jacobiSumC` |
| 27 | 🟡 def | `octonionicSignal` |
| 32 | 🟡 def | `signatureStr` |
| 40 | 🟡 def | `predicted_r₂` |
| 43 | 🟡 def | `predicted_r₄` |
| 46 | 🟡 def | `predicted_r₈` |

### 📄 CongruentNumber.lean

| Line | Kind | Name |
|------|------|------|
| 29 | 🔵 theorem | `congruent_map_identity` |
| 41 | 🔵 theorem | `pyth_quartic_identity` |
| 49 | 🔵 theorem | `congruent_curve_factored` |
| 54 | 🔵 theorem | `two_torsion_points` |
| 73 | 🔵 theorem | `pyth_a_ne_b` |

### 📄 Defs.lean

| Line | Kind | Name |
|------|------|------|
| 21 | 🟡 def | `chi4` |
| 28 | 🟡 def | `r2` |
| 35 | 🟡 def | `r4` |
| 42 | 🟡 def | `r8` |
| 48 | 🔴 structure | `IntSignature where` |
| 56 | 🟡 def | `signature` |
| 65 | 🟡 def | `sigDistSq` |
| 71 | 🔴 structure | `NormSignature where` |
| 79 | 🟡 def | `normSignature` |

### 📄 DescentTheory.lean

| Line | Kind | Name |
|------|------|------|
| 24 | 🔴 structure | `DescentDatum` |
| 34 | 🔵 theorem | `ascend_descend_le` |
| 38 | 🔵 theorem | `descend_ascend_ge` |
| 42 | 🔵 theorem | `descent_idempotent` |
| 49 | 🔵 theorem | `ascent_idempotent` |
| 61 | 🟠 noncomputable def | `matrixRank` |
| 68 | 🔴 structure | `DescentChain` |
| 76 | 🔴 structure | `QDim where` |
| 82 | 🟡 def | `isCrystalline` |
| 86 | 🔵 theorem | `two_crystalline` |
| 90 | 🔵 theorem | `twentyfour_crystalline` |
| 94 | 🔵 theorem | `five_not_crystalline` |
| 104 | 🔵 theorem | `crystalline_sparse` |
| 115 | 🔵 theorem | `descent_rank_bound` |
| 136 | 🔵 theorem | `quantum_descent_pow_dvd` |
| 148 | 🔵 theorem | `descent_dim_dvd` |

### 📄 Extensions.lean

| Line | Kind | Name |
|------|------|------|
| 20 | 🔵 theorem | `trace_B₁` |
| 24 | 🔵 theorem | `trace_B₂` |
| 28 | 🔵 theorem | `trace_B₃` |
| 35 | 🔵 theorem | `ppt_c_odd` |
| 44 | 🔵 theorem | `det_B₁_eq_one` |
| 47 | 🔵 theorem | `det_B₂_eq_neg_one` |
| 50 | 🔵 theorem | `det_B₃_eq_one` |
| 55 | 🔵 theorem | `qr_from_pyth` |
| 61 | 🔵 theorem | `pyth_factored` |
| 66 | 🔵 theorem | `B₂_on_345` |

### 📄 FLT4.lean

| Line | Kind | Name |
|------|------|------|
| 29 | 🔵 theorem | `flt4_strong` |
| 37 | 🔵 theorem | `flt4` |
| 45 | 🔵 theorem | `no_square_legs_pyth` |

### 📄 GaussianIntegers.lean

| Line | Kind | Name |
|------|------|------|
| 29 | 🔵 theorem | `gaussian_norm_eq` |
| 34 | 🔵 theorem | `gaussian_norm_pyth` |
| 39 | 🔵 theorem | `sum_two_sq_factored` |
| 44 | 🔵 theorem | `gaussian_norm_mul` |
| 52 | 🔵 theorem | `gaussian_square_parametrization` |
| 57 | 🔵 theorem | `gaussian_square_norm` |
| 63 | 🔵 theorem | `euclid_from_gaussian` |
| 69 | 🔵 theorem | `r2_five` |
| 75 | 🔵 theorem | `no_sum_two_sq_3mod4` |
| 89 | 🔵 theorem | `three_not_sum_two_sq` |
| 93 | 🔵 theorem | `seven_not_sum_two_sq` |

### 📄 Mediant.lean

| Line | Kind | Name |
|------|------|------|
| 16 | 🟠 noncomputable def | `mediant` |
| 26 | 🔵 theorem | `mediant_between` |
| 40 | 🔵 theorem | `exists_rat_between` |
| 45 | 🔵 theorem | `rat_dense_in_real` |
| 55 | 🔵 theorem | `rat_approx` |

### 📄 Multiplicativity.lean

| Line | Kind | Name |
|------|------|------|
| 24 | 🟠 noncomputable def | `sigma1_star` |
| 28 | 🟢 lemma | `sigma1_star_one` |
| 40 | 🟢 lemma | `sigma1_star_odd_prime` |
| 53 | 🟠 noncomputable def | `sigma3_pm` |
| 63 | 🟢 lemma | `sigma3_pm_one` |
| 73 | 🟢 lemma | `sigma3_pm_odd_prime` |
| 88 | 🔵 theorem | `r4_eq_8_sigma1_star` |
| 93 | 🔵 theorem | `r8_eq_16_sigma3_pm` |

### 📄 ParentDescent.lean

| Line | Kind | Name |
|------|------|------|
| 18 | 🔴 structure | `through GCD extraction at each level.` |
| 42 | 🟡 def | `B₁_inv` |
| 46 | 🟡 def | `B₂_inv` |
| 50 | 🟡 def | `B₃_inv` |
| 56 | 🟡 def | `applyInvB1` |
| 60 | 🟡 def | `applyInvB2` |
| 64 | 🟡 def | `applyInvB3` |
| 70 | 🔵 theorem | `invB1_comp_B1` |
| 75 | 🔵 theorem | `invB2_comp_B2` |
| 80 | 🔵 theorem | `invB3_comp_B3` |
| 87 | 🔵 theorem | `B₁_inv_mul_B₁` |
| 91 | 🔵 theorem | `B₂_inv_mul_B₂` |
| 95 | 🔵 theorem | `B₃_inv_mul_B₃` |
| 101 | 🔵 theorem | `invB1_pyth` |
| 106 | 🔵 theorem | `invB2_pyth` |
| 111 | 🔵 theorem | `invB3_pyth` |
| 128 | 🔵 theorem | `parent_hypotenuse_lt` |
| 136 | 🔵 theorem | `parent_hypotenuse_pos` |
| 143 | 🔵 theorem | `descent_step_bound` |
| 157 | 🔵 theorem | `invB1_invB2_exclusive` |
| 162 | 🔵 theorem | `invB12_invB3_exclusive` |
| 168 | 🔵 theorem | `at_most_one_positive_inverse` |
| 174 | 🟡 def | `findParentBranch` |
| 184 | 🟡 def | `descentPath` |
| 193 | 🟡 def | `descentDepth` |
| 223 | 🟡 def | `extractFactors` |
| 231 | 🟡 def | `factorByDescent` |
| 264 | 🔵 theorem | `invB1_lorentz` |
| 269 | 🔵 theorem | `invB2_lorentz` |
| 274 | 🔵 theorem | `invB3_lorentz` |
| 281 | 🔵 theorem | `leg_factorization` |
| 285 | 🔵 theorem | `B1_leg_relation` |
| 289 | 🔵 theorem | `B3_leg_relation` |
| 295 | 🟡 def | `pathEncoding` |
| 313 | 🟡 def | `factorizationComplexity` |
| 339 | 🔵 theorem | `descent_decreases_at_least_2` |
| 343 | 🔵 theorem | `descent_hyp_diff` |

### 📄 PrimeSignatures.lean

| Line | Kind | Name |
|------|------|------|
| 34 | 🔵 theorem | `r4_prime_uniform` |
| 51 | 🔵 theorem | `signature_gap_constant` |
| 69 | 🔵 theorem | `channel_ratio_is_twice_eisenstein_norm` |
| 74 | 🔵 theorem | `sum_of_cubes_factor` |

### 📄 PythagoreanLight.lean

| Line | Kind | Name |
|------|------|------|
| 33 | 🔵 theorem | `pythagorean_parametrization` |
| 46 | 🔵 theorem | `brahmagupta_fibonacci` |
| 59 | 🔵 theorem | `unit_circle_rational_point` |
| 80 | 🔵 theorem | `gaussian_norm_multiplicative` |
| 101 | 🔵 theorem | `fermat_two_square_easy_direction` |
| 131 | 🔵 theorem | `lightlike_direction` |
| 143 | 🔵 theorem | `lightlike_scaling` |
| 165 | 🔵 theorem | `triple_3_4_5` |
| 175 | 🔵 theorem | `triple_5_12_13` |
| 185 | 🔵 theorem | `triple_8_15_17` |
| 197 | 🔵 theorem | `infinitely_many_pythagorean_triples` |

### 📄 PythagoreanPairing.lean

| Line | Kind | Name |
|------|------|------|
| 44 | 🔵 theorem | `brahmagupta_fibonacci` |
| 50 | 🔵 theorem | `brahmagupta_fibonacci_alt` |
| 56 | 🔵 theorem | `brahmagupta_two_reps` |
| 72 | 🔵 theorem | `two_reps_product_identity` |
| 78 | 🔵 theorem | `two_reps_divisibility` |
| 83 | 🔵 theorem | `cross_product_identity` |
| 89 | 🔵 theorem | `N_divides_cross` |
| 103 | 🔴 structure | `SumOfSquaresRep` |
| 109 | 🟡 def | `SumOfSquaresRep.distinct` |
| 114 | 🔵 theorem | `euclid_from_rep` |
| 120 | 🔵 theorem | `paired_triples_share_hypotenuse` |
| 129 | 🔵 theorem | `paired_triple_factor_divides` |
| 144 | 🔵 theorem | `paired_triple_cross_divides` |
| 157 | 🟠 noncomputable def | `pairingFactor` |
| 161 | 🔵 theorem | `pairing_factor_divides` |
| 176 | 🔵 theorem | `product_has_two_reps` |
| 185 | 🔵 theorem | `bf_two_reps` |
| 205 | 🔵 theorem | `conversion_formula` |
| 266 | 🔵 theorem | `gaussian_norm_pair` |
| 273 | 🔵 theorem | `gaussian_product_norm` |
| 298 | 🟡 def | `findReps` |
| 311 | 🟡 def | `findPairedTriples` |
| 358 | 🔵 theorem | `fermat_sum_two_squares_1mod4` |
| 366 | 🔵 theorem | `two_primes_two_reps` |

### 📄 PythagoreanTriples.lean

| Line | Kind | Name |
|------|------|------|
| 19 | 🟡 def | `IsPythagoreanTriple` |
| 28 | 🔵 theorem | `pythagorean_3_4_5` |
| 38 | 🔵 theorem | `pythagorean_5_12_13` |
| 48 | 🔵 theorem | `pythagorean_8_15_17` |
| 58 | 🔵 theorem | `pythagorean_scale` |
| 69 | 🔵 theorem | `pythagorean_swap` |
| 80 | 🔵 theorem | `euclid_formula` |
| 99 | 🔵 theorem | `berggren_A_preserves` |
| 110 | 🔵 theorem | `berggren_B_preserves` |
| 121 | 🔵 theorem | `berggren_C_preserves` |
| 134 | 🔵 theorem | `pythagorean_even_leg` |
| 146 | 🔵 theorem | `fermat_n4_no_solution` |
| 168 | 🔵 theorem | `sum_two_squares_5` |
| 175 | 🔵 theorem | `sum_two_squares_13` |
| 185 | 🔵 theorem | `no_sum_two_squares_mod4` |

### 📄 QuadraticForms.lean

| Line | Kind | Name |
|------|------|------|
| 22 | 🟡 def | `form_discriminant` |
| 25 | 🔵 theorem | `sum_two_sq_disc` |
| 29 | 🔵 theorem | `eisenstein_form_disc` |
| 40 | 🔵 theorem | `class_number_neg4` |
| 52 | 🔵 theorem | `brahmagupta_fibonacci` |
| 57 | 🔵 theorem | `brahmagupta_fibonacci'` |
| 62 | 🔵 theorem | `sum_sq_mul_sum_sq` |
| 73 | 🔵 theorem | `vieta_descent` |
| 79 | 🔵 theorem | `berggren_quadric` |
| 83 | 🔵 theorem | `berggren_form_signature` |
| 90 | 🔵 theorem | `three_sq_obstruction_7` |
| 99 | 🔵 theorem | `three_sq_obstruction_15` |
| 108 | 🔵 theorem | `three_sq_obstruction_23` |

### 📄 SL2Theory.lean

| Line | Kind | Name |
|------|------|------|
| 22 | 🟡 def | `M1_SL2` |
| 26 | 🟡 def | `M3_SL2` |
| 30 | 🟡 def | `GammaTheta` |
| 36 | 🔵 theorem | `berggren_eq_theta` |
| 72 | 🔵 theorem | `SL2_F2_card` |
| 75 | 🔵 theorem | `SL2_F3_card` |
| 78 | 🔵 theorem | `SL2_F5_card` |
| 81 | 🔵 theorem | `SL2_F7_card` |
| 84 | 🔵 theorem | `SL2_F11_card` |
| 88 | 🔵 theorem | `SL2_order_formula_p3` |
| 91 | 🔵 theorem | `SL2_order_formula_p5` |
| 98 | 🔵 theorem | `PSL2_F11_order` |
| 99 | 🔵 theorem | `M11_order` |
| 100 | 🔵 theorem | `PSL2_divides_M11` |
| 109 | 🟠 noncomputable def | `j_from_lambda` |
| 113 | 🔵 theorem | `j_at_half` |
| 117 | 🔵 theorem | `j_1728_eq` |

---

## DivisionAlgebras

### 📄 CayleyDickson.lean

| Line | Kind | Name |
|------|------|------|
| 29 | 🔵 theorem | `complex_norm_sq_mul` |
| 43 | 🔵 theorem | `quaternion_not_commutative` |
| 54 | 🔵 theorem | `brahmagupta_fibonacci` |
| 60 | 🔵 theorem | `euler_four_square` |
| 77 | 🔵 theorem | `channel_1_to_2` |
| 88 | 🔵 theorem | `channel_2_to_3` |
| 99 | 🔵 theorem | `channel_3_to_4` |
| 115 | 🔵 theorem | `hurwitz_dimensions` |
| 119 | 🔵 theorem | `sum_hurwitz_dims` |
| 122 | 🔵 theorem | `prod_hurwitz_dims` |
| 134 | 🔵 theorem | `channel_1_bounded` |
| 144 | 🟡 def | `jacobi'` |

### 📄 Channel5Sedenions.lean

| Line | Kind | Name |
|------|------|------|
| 50 | 🔵 theorem | `cayley_dickson_dim` |
| 54 | 🔵 theorem | `channel_dimensions` |
| 70 | 🔵 theorem | `hurwitz_dimensions` |
| 73 | 🔵 theorem | `sixteen_not_hurwitz` |
| 76 | 🔵 theorem | `two_square_identity` |
| 80 | 🔵 theorem | `four_square_identity` |
| 89 | 🔵 theorem | `eight_square_identity` |
| 117 | 🟡 def | `sigma7` |
| 120 | 🔵 theorem | `sigma7_one` |
| 124 | 🔵 theorem | `sigma7_prime` |
| 132 | 🟡 def | `eisenstein_r16` |
| 137 | 🟡 def | `cusp_correction` |
| 147 | 🔵 theorem | `r16_one_value` |
| 150 | 🔵 theorem | `r16_two_value` |
| 166 | 🔵 theorem | `sigma1_multiplicative_example` |
| 172 | 🔵 theorem | `sigma3_multiplicative_example` |
| 176 | 🔵 theorem | `sigma7_multiplicative_example` |
| 188 | 🔵 theorem | `r2_prime_bounded` |
| 192 | 🔵 theorem | `r4_growth` |
| 195 | 🔵 theorem | `r8_growth` |
| 200 | 🔵 theorem | `r16_eisenstein_growth` |
| 206 | 🔵 theorem | `channel_4_over_3` |
| 210 | 🔵 theorem | `channel_5_over_4_growth` |
| 232 | 🔵 theorem | `complex_no_zero_divisors` |
| 246 | 🔵 theorem | `sedenion_beyond_hurwitz` |
| 269 | 🟡 def | `stokes_constraint` |
| 274 | 🔵 theorem | `stokes_is_null` |
| 281 | 🟡 def | `jones_intensity` |
| 285 | 🔵 theorem | `jones_intensity_nonneg` |
| 291 | 🟡 def | `horizontal_pol` |
| 294 | 🟡 def | `vertical_pol` |
| 297 | 🔵 theorem | `h_v_equal_intensity` |
| 320 | 🔵 theorem | `five_light_channels` |
| 323 | 🟡 def | `channel_dimension` |
| 331 | 🔵 theorem | `channel_doubling` |
| 352 | 🟡 def | `modular_weight` |
| 361 | 🔵 theorem | `channels_1_to_4_no_cusps` |
| 367 | 🔵 theorem | `channel_5_cusp_weight` |
| 385 | 🔵 theorem | `eisenstein_prediction_2` |
| 392 | 🔵 theorem | `r16_actual_2` |
| 396 | 🔵 theorem | `r16_vs_eisenstein_1` |
| 423 | 🔵 theorem | `poincare_sphere_is_light_cone` |
| 429 | 🔵 theorem | `partial_pol_is_timelike` |
| 435 | 🔵 theorem | `unpolarized_is_pure_timelike` |
| 451 | 🔵 theorem | `bott_period_dimensions` |
| 457 | 🔵 theorem | `eight_equals_two_cubed` |
| 483 | 🔵 theorem | `channel_5_no_dark_matter` |
| 493 | 🔵 theorem | `channel_hierarchy_prime_5` |
| 512 | 🔵 theorem | `fock_dim_two_modes` |
| 517 | 🔵 theorem | `fock_dim_four_modes_example` |

### 📄 Channel6Research.lean

| Line | Kind | Name |
|------|------|------|
| 65 | 🔵 theorem | `cayley_dickson_dim_general` |
| 68 | 🔵 theorem | `channel6_dim` |
| 71 | 🔵 theorem | `six_channel_dimensions` |
| 75 | 🔵 theorem | `thirtytwo_not_hurwitz` |
| 78 | 🔵 theorem | `total_channel_dimensions` |
| 82 | 🔵 theorem | `total_dim_is_mersenne` |
| 85 | 🔵 theorem | `channel6_dominates` |
| 91 | 🔴 structure | `Sed where` |
| 96 | 🟡 def | `Sed.normSq` |
| 99 | 🔴 structure | `Tri where` |
| 105 | 🟡 def | `Tri.normSq` |
| 108 | 🔵 theorem | `tri_normSq_is_sum_32` |
| 115 | 🟡 def | `sedenion_zd_left` |
| 119 | 🟡 def | `sedenion_zd_right` |
| 123 | 🔵 theorem | `sed_zd_left_nonzero` |
| 126 | 🔵 theorem | `sed_zd_right_nonzero` |
| 130 | 🔵 theorem | `sed_zd_left_norm` |
| 132 | 🔵 theorem | `sed_zd_right_norm` |
| 144 | 🟡 def | `cuspDim` |
| 152 | 🔵 theorem | `channel5_single_cusp` |
| 155 | 🔵 theorem | `channel6_cusp_explosion` |
| 158 | 🔵 theorem | `cusp_explosion_factor` |
| 161 | 🔵 theorem | `cusp_dominates_eisenstein_ch6` |
| 166 | 🔴 structure | `TwoPhotonStokes where` |
| 172 | 🔵 theorem | `two_photon_param_count` |
| 175 | 🟡 def | `singlePhotonMinkowski` |
| 179 | 🔵 theorem | `single_photon_null` |
| 187 | 🟡 def | `bellBound` |
| 190 | 🟡 def | `tsirelsonBound` |
| 193 | 🔵 theorem | `tsirelson_exceeds_bell` |
| 201 | 🔵 theorem | `bell_violation_ratio` |
| 206 | 🟡 def | `chsh_value` |
| 210 | 🔵 theorem | `local_correlation_bound` |
| 217 | 🟡 def | `ramanujanPetterssonExponent` |
| 220 | 🔵 theorem | `rp_exponent_weight16` |
| 224 | 🔵 theorem | `rp_exponent_weight8` |
| 228 | 🔵 theorem | `rp_exponent_growth` |
| 235 | 🔵 theorem | `total_dim_through_channel` |
| 247 | 🟡 def | `tensorMinkowski` |
| 251 | 🔵 theorem | `null_pair_tensor_zero` |
| 259 | 🟡 def | `pythagoreanConcurrence` |
| 263 | 🔵 theorem | `concurrence_parallel` |
| 268 | 🔵 theorem | `concurrence_antisymmetric` |
| 274 | 🔵 theorem | `concurrence_345_51213` |
| 279 | 🔵 theorem | `concurrence_345_81517` |
| 286 | 🟡 def | `photonInfoDim` |
| 296 | 🔵 theorem | `channel_dim_pattern` |
| 310 | 🟡 def | `algebraicProperties` |
| 319 | 🔵 theorem | `only_power_assoc_survives` |
| 322 | 🔵 theorem | `channel6_still_power_assoc` |
| 327 | 🟡 def | `r2_count` |
| 332 | 🔵 theorem | `r2_of_5_nonneg` |
| 335 | 🔵 theorem | `r2_of_2_nonneg` |
| 338 | 🔵 theorem | `three_dark_ch2` |
| 344 | 🟡 def | `entanglementDim` |
| 350 | 🔵 theorem | `entanglement_phase_transition` |
| 355 | 🔵 theorem | `channel6_entanglement` |
| 360 | 🔵 theorem | `thirtyone_prime` |
| 363 | 🔵 theorem | `thirtyone_mersenne` |
| 366 | 🔵 theorem | `mersenne_channel_monster` |
| 369 | 🔵 theorem | `channel6_extends_mersenne` |
| 372 | 🔵 theorem | `sixtythree_mersenne` |
| 375 | 🔵 theorem | `sixtythree_factorization` |
| 380 | 🔴 structure | `ChannelSpectrum where` |
| 389 | 🟡 def | `ChannelSpectrum.totalInfo` |
| 394 | 🟡 def | `isClassical` |
| 397 | 🟡 def | `isQuantum` |
| 400 | 🔵 theorem | `classical_not_quantum` |
| 407 | 🟡 def | `catastropheCount` |
| 412 | 🔵 theorem | `catastrophe_monotone_0` |
| 413 | 🔵 theorem | `catastrophe_monotone_1` |
| 414 | 🔵 theorem | `catastrophe_monotone_2` |
| 415 | 🔵 theorem | `catastrophe_monotone_3` |
| 416 | 🔵 theorem | `catastrophe_monotone_4` |
| 419 | 🔵 theorem | `catastrophe_eq_0` |
| 420 | 🔵 theorem | `catastrophe_eq_1` |
| 421 | 🔵 theorem | `catastrophe_eq_2` |
| 422 | 🔵 theorem | `catastrophe_eq_3` |
| 423 | 🔵 theorem | `catastrophe_eq_4` |
| 424 | 🔵 theorem | `catastrophe_eq_5` |
| 435 | 🟡 def | `sqConcurrence` |
| 439 | 🔵 theorem | `sq_concurrence_nonneg` |
| 444 | 🔵 theorem | `sq_concurrence_zero_iff_parallel` |
| 452 | 🔵 theorem | `self_concurrence_zero` |
| 465 | 🔵 theorem | `hurwitz_set` |
| 468 | 🔵 theorem | `four_clean_channels` |
| 471 | 🔵 theorem | `beyond_ch4_has_cusps` |
| 504 | 🔵 theorem | `channel7_dim` |
| 507 | 🔵 theorem | `channel8_dim` |
| 510 | 🔵 theorem | `total_dim_through_ch8` |
| 513 | 🔵 theorem | `total_dim_ch8_mersenne` |

### 📄 ChannelEntropy.lean

| Line | Kind | Name |
|------|------|------|
| 27 | 🟢 lemma | `sum_divisors_not_div4_prime` |
| 41 | 🔵 theorem | `r4_odd_prime` |
| 56 | 🟢 lemma | `sum_cubed_divisors_prime` |
| 68 | 🔵 theorem | `r8_odd_prime` |
| 82 | 🔵 theorem | `channel_ratio_identity` |
| 93 | 🔵 theorem | `channel_ratio_pos` |
| 106 | 🟢 lemma | `chi4_one` |
| 116 | 🟢 lemma | `chi4_prime_1mod4` |
| 127 | 🟢 lemma | `chi4_prime_3mod4` |
| 139 | 🔵 theorem | `r2_prime_1mod4` |
| 153 | 🔵 theorem | `r2_prime_3mod4` |
| 172 | 🔵 theorem | `r4_pos` |
| 183 | 🔵 theorem | `r8_gt_r4` |

### 📄 DivisionAlgebras.lean

| Line | Kind | Name |
|------|------|------|
| 27 | 🔴 structure | `CayleyDickson` |
| 37 | ⚪ instance | `[Add α]` |
| 41 | ⚪ instance | `[Neg α]` |
| 45 | ⚪ instance | `[Zero α]` |
| 50 | ⚪ instance | `[Ring α]` |
| 56 | ⚪ instance | `[Star α]` |
| 60 | ⚪ instance | `[One α]` |
| 64 | 🟡 def | `embed` |
| 67 | 🟡 def | `im` |
| 88 | 🟡 def | `algAssociator` |
| 98 | 🔵 theorem | `algAssociator_eq_zero` |
| 103 | 🟡 def | `algCommutator` |
| 113 | 🔵 theorem | `algCommutator_eq_zero` |
| 129 | 🔵 theorem | `quaternion_norm_mul` |
| 140 | ⚪ instance | `: Countable ℚ` |
| 143 | 🔵 theorem | `rationals_dense_in_reals` |

### 📄 OctonionQubit.lean

| Line | Kind | Name |
|------|------|------|
| 22 | 🟡 def | `UnitSphere` |
| 31 | 🟡 def | `RationalSphere` |
| 35 | 🟡 def | `innerProduct` |
| 39 | 🟡 def | `sqNorm` |
| 43 | 🔵 theorem | `unit_sphere_norm_one` |
| 48 | 🟠 noncomputable def | `bornProbability` |
| 58 | 🔵 theorem | `born_probability_nonneg` |
| 69 | 🔵 theorem | `born_probability_le_one` |
| 86 | 🟠 noncomputable def | `stereoProj` |
| 101 | 🔵 theorem | `stereoProj_on_sphere` |
| 114 | 🔵 theorem | `stereoProj_rational` |
| 133 | 🟡 def | `fanoTriples` |
| 143 | 🔵 theorem | `fano_card` |

---

## Dynamics

### 📄 DifferentialEquations.lean

| Line | Kind | Name |
|------|------|------|
| 9 | 🔵 theorem | `fixed_point_stability'` |
| 26 | 🔵 theorem | `discrete_gronwall'` |
| 37 | 🔵 theorem | `logistic_fixed_point'` |
| 41 | 🔵 theorem | `geometric_sum_formula'` |
| 47 | 🔵 theorem | `fib_bound'` |
| 60 | 🔵 theorem | `euler_total_steps'` |

### 📄 DynamicalSystems.lean

| Line | Kind | Name |
|------|------|------|
| 10 | 🔵 theorem | `involution_period` |
| 13 | 🔵 theorem | `neg_involution'` |
| 14 | 🔵 theorem | `zero_fixed_point_div2` |
| 18 | 🟡 def | `collatz_step` |
| 21 | 🔵 theorem | `collatz_reaches_1_from_6` |
| 22 | 🔵 theorem | `collatz_reaches_1_from_7` |
| 23 | 🔵 theorem | `collatz_reaches_1_from_27` |
| 27 | 🔵 theorem | `logistic_fixed_point_r2` |
| 28 | 🔵 theorem | `logistic_fixed_point_r3` |
| 32 | 🟡 def | `rule110` |
| 43 | 🔵 theorem | `rule110_check` |
| 48 | 🔵 theorem | `tent_period2` |
| 53 | 🔵 theorem | `berggren_M1_fixed_eigenvalue'` |

### 📄 ErgodicTheory.lean

| Line | Kind | Name |
|------|------|------|
| 11 | 🔵 theorem | `comp_measure_preserving'` |
| 18 | 🔵 theorem | `id_measure_preserving'` |
| 23 | 🟠 noncomputable def | `timeAverage'` |
| 26 | 🔵 theorem | `timeAverage_const'` |
| 31 | 🔵 theorem | `timeAverage_add'` |
| 38 | 🔵 theorem | `orbit_finite'` |
| 44 | 🔵 theorem | `bijection_preserves_card'` |

---

## Factoring

### 📄 ChimeraFactoring.lean

| Line | Kind | Name |
|------|------|------|
| 43 | 🔵 theorem | `sq_sub_sq_factor` |
| 48 | 🔵 theorem | `congruence_of_squares_zmod` |
| 54 | 🔵 theorem | `factor_from_square_congruence_int` |
| 63 | 🔵 theorem | `square_root_ambiguity` |
| 72 | 🔵 theorem | `square_root_trichotomy` |
| 93 | 🔵 theorem | `shor_algebraic_core` |
| 100 | 🔵 theorem | `shor_zmod_factoring` |
| 108 | 🔵 theorem | `shor_totient` |
| 116 | 🔵 theorem | `fermat_little_zmod` |
| 132 | 🔵 theorem | `difference_of_cubes` |
| 136 | 🔵 theorem | `sum_of_cubes` |
| 140 | 🔵 theorem | `difference_of_fourth_powers` |
| 144 | 🔵 theorem | `difference_of_fifth_powers` |
| 149 | 🔵 theorem | `difference_of_sixth_powers` |
| 155 | 🔵 theorem | `sophie_germain_identity` |
| 162 | 🔵 theorem | `brahmagupta_fibonacci_identity` |
| 167 | 🔵 theorem | `brahmagupta_fibonacci_alt` |
| 183 | 🔵 theorem | `birthday_pigeonhole` |
| 194 | 🔵 theorem | `pollard_rho_cycle` |
| 210 | 🔵 theorem | `prime_factor_le` |
| 222 | 🟡 def | `IsSmooth` |
| 226 | 🔵 theorem | `one_isSmooth` |
| 232 | 🔵 theorem | `prime_isSmooth` |
| 241 | 🔵 theorem | `smooth_mul` |
| 249 | 🔵 theorem | `smooth_pow` |
| 256 | 🔵 theorem | `factor_base_size_bound` |
| 263 | 🔵 theorem | `sieve_threshold` |
| 275 | 🔵 theorem | `hasse_interval_width` |
| 285 | 🔵 theorem | `ecm_advantage` |
| 291 | 🔵 theorem | `ecm_multiple_curves` |
| 303 | 🔵 theorem | `minkowski_1d` |
| 308 | 🔵 theorem | `det_two_by_two` |
| 313 | 🔵 theorem | `coppersmith_linear` |
| 325 | 🔵 theorem | `trace_identity_matrix` |
| 331 | 🔵 theorem | `trace_outer_product` |
| 392 | 🔵 theorem | `composite_has_small_factor` |
| 400 | 🔵 theorem | `factor_size_bound` |
| 412 | 🔵 theorem | `semiprime_unique_factorization` |
| 433 | 🔵 theorem | `euler_totient_semiprime` |
| 441 | 🔵 theorem | `carmichael_divides_totient` |
| 454 | 🔵 theorem | `cyclotomic_2` |
| 455 | 🔵 theorem | `cyclotomic_3` |
| 456 | 🔵 theorem | `cyclotomic_4` |
| 457 | 🔵 theorem | `cyclotomic_5` |
| 459 | 🔵 theorem | `cyclotomic_6` |
| 462 | 🔵 theorem | `sum_factoring_3` |
| 463 | 🔵 theorem | `sum_factoring_5` |

### 📄 EnergyDescentResearch.lean

| Line | Kind | Name |
|------|------|------|
| 32 | 🟠 noncomputable def | `iofEnergy` |
| 35 | 🔵 theorem | `iofEnergy_nonneg` |
| 39 | 🔵 theorem | `iofEnergy_zero` |
| 43 | 🔵 theorem | `iofEnergy_strict_decrease` |
| 48 | 🔵 theorem | `iofEnergy_drop` |
| 53 | 🔵 theorem | `iofEnergy_drop_pos` |
| 61 | 🔵 theorem | `iofEnergy_closed_form` |
| 65 | 🔵 theorem | `iofEnergy_ratio` |
| 72 | 🔵 theorem | `iofEnergy_at_factor_step` |
| 79 | 🔵 theorem | `iofEnergy_at_factor_product` |
| 99 | 🔵 theorem | `iofEnergy_factor_bound` |
| 105 | 🔵 theorem | `iofEnergy_monotone_decreasing` |
| 118 | 🔵 theorem | `iofEnergy_min_drop` |
| 123 | 🔵 theorem | `iofEnergy_max_drop` |
| 137 | 🔵 theorem | `iofEnergy_zero_iff` |
| 145 | 🔵 theorem | `iofEnergy_lyapunov` |
| 162 | 🔵 theorem | `iofEnergy_telescope` |
| 167 | 🔵 theorem | `iofEnergy_total_drop` |
| 172 | 🔵 theorem | `iofEnergy_total_drop_at_factor` |
| 187 | 🔵 theorem | `gaussian_norm_mult` |
| 192 | 🔵 theorem | `brahmagupta_fibonacci` |
| 210 | 🔵 theorem | `factor_step_periodic` |
| 216 | 🔵 theorem | `factor_step_symmetric` |
| 229 | 🔵 theorem | `iofEnergy_drop_linear` |
| 234 | 🔵 theorem | `iofEnergy_two_step_drop` |
| 249 | 🔵 theorem | `lorentz_form_preserved` |
| 254 | 🔵 theorem | `on_light_cone_preserved` |
| 268 | 🔵 theorem | `energy_at_detection_bound` |
| 282 | 🔵 theorem | `descent_preserves_parity` |
| 286 | 🔵 theorem | `odd_leg_positive` |
| 300 | 🔵 theorem | `descent_terminates` |
| 318 | 🔵 theorem | `step_count_bound` |
| 334 | 🔵 theorem | `sieve_poly2` |
| 337 | 🔵 theorem | `sieve_poly3` |
| 340 | 🔵 theorem | `sieve_poly2_factor` |
| 362 | 🔵 theorem | `crystallizer_iof_bridge` |
| 366 | 🔵 theorem | `iof_is_cleared_crystallizer` |
| 382 | 🔵 theorem | `forward_B1_increases_hyp` |
| 387 | 🔵 theorem | `forward_B2_increases_hyp` |
| 398 | 🔵 theorem | `quadratic_discriminant` |
| 404 | 🔵 theorem | `iof_discriminant` |
| 408 | 🔵 theorem | `discriminant_is_square` |
| 423 | 🔵 theorem | `energy_gradient_linear` |
| 429 | 🔵 theorem | `energy_second_difference_constant` |
| 446 | 🔵 theorem | `energy_encodes_factor` |
| 451 | 🔵 theorem | `energy_determines_factors` |
| 462 | 🔵 theorem | `energy_ratio_identity` |

### 📄 FermatFactor.lean

| Line | Kind | Name |
|------|------|------|
| 39 | 🔵 theorem | `fermat_identity` |
| 43 | 🔵 theorem | `odd_composite_fermat_rep` |
| 50 | 🔵 theorem | `fermat_factorization_correct` |
| 55 | 🔵 theorem | `fermat_nontrivial_factors` |
| 77 | 🔵 theorem | `pyth_triple_diff_squares` |
| 82 | 🔵 theorem | `pyth_triple_gives_factorization` |
| 87 | 🔵 theorem | `pyth_triple_gives_factorization'` |
| 99 | 🔵 theorem | `parametric_pyth_triple` |
| 104 | 🔵 theorem | `parametric_fermat` |
| 110 | 🔵 theorem | `pyth_param_factors_N` |
| 142 | 🟡 def | `fermatSearch` |
| 157 | 🟡 def | `searchBerggrenTree` |
| 183 | 🟡 def | `berggrenFermatFactor` |
| 216 | 🔵 theorem | `exists_fermat_factorization` |
| 252 | 🔵 theorem | `berggren_depth_covers` |
| 308 | 🔵 theorem | `berggren_fermat_guaranteed` |

### 📄 IOFCore.lean

| Line | Kind | Name |
|------|------|------|
| 29 | 🟡 def | `a` |
| 32 | 🟡 def | `b` |
| 35 | 🟡 def | `c` |
| 38 | 🟡 def | `energy` |
| 52 | 🔵 theorem | `pythagorean_invariant` |
| 66 | 🔵 theorem | `energy_nonneg` |
| 76 | 🔵 theorem | `energy_strict_decrease` |
| 90 | 🔵 theorem | `a_at_factor_step` |
| 106 | 🔵 theorem | `b_divisible_at_factor_step` |
| 129 | 🔵 theorem | `initial_a` |
| 136 | 🔵 theorem | `initial_b` |
| 143 | 🔵 theorem | `initial_c` |
| 159 | 🔵 theorem | `lyapunov_termination` |

### 📄 IOFDynamical.lean

| Line | Kind | Name |
|------|------|------|
| 26 | 🔴 structure | `IOFState where` |
| 32 | 🟡 def | `state` |
| 50 | 🔵 theorem | `same_factor_same_step` |
| 70 | 🔵 theorem | `energy_at_factor` |
| 81 | 🟡 def | `velocity` |
| 90 | 🔵 theorem | `velocity_positive` |
| 101 | 🔵 theorem | `constant_deceleration` |
| 120 | 🔵 theorem | `multi_stride_gcd` |
| 143 | 🔵 theorem | `at_least_one_step` |

### 📄 IOFExplorations.lean

| Line | Kind | Name |
|------|------|------|
| 14 | 🔵 theorem | `totient_sum_divisors'` |
| 18 | 🔵 theorem | `totient_prime'` |
| 23 | 🔵 theorem | `pyth_variety_scale'` |
| 26 | 🔵 theorem | `circle_param` |
| 32 | 🔵 theorem | `euler_char'` |
| 36 | 🔵 theorem | `char_mult` |
| 41 | 🔵 theorem | `measure_mono_iof` |
| 47 | 🔵 theorem | `norm_triangle_iof` |
| 50 | 🔵 theorem | `cauchy_schwarz_iof` |
| 61 | 🔵 theorem | `zero_sum_game'` |
| 65 | 🔵 theorem | `contraction_pow` |
| 70 | 🔵 theorem | `fermat_little'` |
| 75 | 🔵 theorem | `hamming_symm_iof` |
| 82 | 🔵 theorem | `graph_pigeonhole` |
| 93 | 🔵 theorem | `sq_convex_iof` |
| 100 | 🔵 theorem | `union_bound_iof` |
| 106 | 🔵 theorem | `exp_basic` |
| 111 | 🔵 theorem | `product_card'` |
| 117 | 🔵 theorem | `pid_principal'` |
| 124 | 🔵 theorem | `jacobi'` |
| 130 | 🔵 theorem | `norm_sq_nonneg_iof` |
| 135 | 🔵 theorem | `log_one_iof` |
| 137 | 🔵 theorem | `log_mul_iof` |
| 142 | 🔵 theorem | `iof_gcd_detection` |
| 152 | 🔵 theorem | `invB1_form` |
| 156 | 🔵 theorem | `invB2_form` |
| 160 | 🔵 theorem | `invB3_form` |
| 164 | 🔵 theorem | `euclid_pyth` |

### 📄 IOFSpeedup.lean

| Line | Kind | Name |
|------|------|------|
| 34 | 🟡 def | `leg_product` |
| 39 | 🔵 theorem | `factor_in_product` |
| 47 | 🟡 def | `bleg_product` |
| 60 | 🔵 theorem | `factor_step_divides_bleg` |
| 73 | 🟡 def | `energy_at` |
| 78 | 🔵 theorem | `energy_monotone_decreasing` |
| 89 | 🔵 theorem | `factor_in_unique_interval` |
| 99 | 🔵 theorem | `energy_drop_formula` |
| 104 | 🔵 theorem | `cumulative_energy_drop` |
| 119 | 🔵 theorem | `factor_square_condition` |

### 📄 InsideOutFactor.lean

| Line | Kind | Name |
|------|------|------|
| 43 | 🟡 def | `applyInvBG1` |
| 50 | 🟡 def | `applyInvBG2` |
| 57 | 🟡 def | `applyInvBG3` |
| 68 | 🟡 def | `findBerggrenParent` |
| 86 | 🟡 def | `insideOutFactor` |
| 107 | 🟡 def | `insideOutFactorAll` |
| 165 | 🟡 def | `sumOfTwoSquaresReps` |
| 177 | 🟡 def | `factorViaSumOfSquares` |
| 203 | 🟡 def | `factorViaAuxiliary` |
| 224 | 🔵 theorem | `euclid_triple_valid` |
| 231 | 🔵 theorem | `euclid_odd_leg` |
| 242 | 🔵 theorem | `invB1_preserves_form` |
| 246 | 🔵 theorem | `invB2_preserves_form` |
| 250 | 🔵 theorem | `invB3_preserves_form` |
| 255 | 🔵 theorem | `gcd_reveals_factor` |
| 279 | 🔵 theorem | `parent_hyp_decreases` |
| 285 | 🔵 theorem | `hyp_decrease_exact` |

### 📄 InsideOutResearch.lean

| Line | Kind | Name |
|------|------|------|
| 40 | 🔵 theorem | `euclid_thin_triple` |
| 53 | 🔵 theorem | `factor_condition` |
| 59 | 🔵 theorem | `four_k_sq_minus_one` |
| 62 | 🔵 theorem | `factor_at_half_p` |
| 79 | 🔵 theorem | `no_factor_before_half` |
| 90 | 🔵 theorem | `invB1_preserves_pyth` |
| 95 | 🔵 theorem | `invB2_preserves_pyth` |
| 100 | 🔵 theorem | `invB3_preserves_pyth` |
| 106 | 🔵 theorem | `lorentz_invariant_B1` |
| 110 | 🔵 theorem | `lorentz_invariant_B2` |
| 114 | 🔵 theorem | `lorentz_invariant_B3` |
| 121 | 🔵 theorem | `hyp_strictly_decreases` |
| 129 | 🔵 theorem | `gcd_factor_detection` |
| 140 | 🔵 theorem | `semiprime_divisor` |
| 150 | 🔵 theorem | `euclid_odd_leg_is_N` |
| 157 | 🔵 theorem | `euclid_triple_pyth` |
| 166 | 🟡 def | `insideOutFactorV2` |
| 177 | 🟡 def | `multiPolySieve` |

### 📄 SumOfSquaresFilter.lean

| Line | Kind | Name |
|------|------|------|
| 25 | 🟡 def | `IsSumTwoSquares` |
| 35 | 🔵 theorem | `fermat_two_squares` |
| 43 | 🔵 theorem | `two_is_sum_two_squares` |
| 53 | 🔵 theorem | `prime_3mod4_not_sum_two_squares` |
| 66 | 🔵 theorem | `sum_two_squares_mul` |
| 103 | 🔵 theorem | `square_is_sum_two_squares` |

---

## Geometry

### 📄 ArithmeticGeometry.lean

| Line | Kind | Name |
|------|------|------|
| 21 | 🟡 def | `IsCongruent` |
| 26 | 🔵 theorem | `six_is_congruent` |
| 30 | 🔵 theorem | `two10_is_congruent` |
| 34 | 🔵 theorem | `thirty_is_congruent` |
| 40 | 🔵 theorem | `En_curve_eq` |
| 45 | 🔵 theorem | `En_nonsingular` |
| 50 | 🔵 theorem | `ppt_point_on_curve_scaled` |
| 60 | 🔵 theorem | `En_2_torsion_on_curve` |
| 70 | 🔵 theorem | `selmer_rank_bound` |
| 76 | 🔵 theorem | `root_number_congruent` |

### 📄 ConvexGeometry.lean

| Line | Kind | Name |
|------|------|------|
| 9 | 🔵 theorem | `convex_inter'` |
| 13 | 🔵 theorem | `convex_hull_minimal'` |
| 17 | 🔵 theorem | `subset_convex_hull'` |
| 20 | 🔵 theorem | `jensen_two_point'` |
| 25 | 🔵 theorem | `sq_convex'` |
| 33 | 🔵 theorem | `lp_weak_duality'` |

### 📄 DifferentialGeometry.lean

| Line | Kind | Name |
|------|------|------|
| 13 | 🔵 theorem | `gauss_bonnet_sphere` |
| 16 | 🔵 theorem | `gauss_bonnet_torus` |
| 19 | 🔵 theorem | `gauss_bonnet_genus` |
| 25 | 🟡 def | `so2_generator` |
| 28 | 🔵 theorem | `so2_antisymmetric` |
| 33 | 🔵 theorem | `so2_generator_squared` |
| 41 | 🔵 theorem | `z2_action_period` |
| 47 | 🔵 theorem | `harmonic_path` |
| 52 | 🔵 theorem | `chern_number_quantized` |

### 📄 GeometricGroupTheory.lean

| Line | Kind | Name |
|------|------|------|
| 9 | 🔵 theorem | `z_growth'` |
| 12 | 🔵 theorem | `z2_growth'` |
| 15 | 🔵 theorem | `free_group_growth'` |
| 23 | 🔵 theorem | `zn_polynomial_growth'` |
| 27 | 🔵 theorem | `z_r_quasi_isometric'` |
| 32 | 🔵 theorem | `cayley_zn_diameter'` |
| 36 | 🔵 theorem | `finite_amenable'` |
| 41 | 🔵 theorem | `sl2z_amalgam'` |
| 44 | 🔵 theorem | `ricci_flow_sphere'` |
| 48 | 🔵 theorem | `berggren_growth'` |

### 📄 HodgeTheory.lean

| Line | Kind | Name |
|------|------|------|
| 7 | 🔵 theorem | `curve_hodge'` |
| 11 | 🔵 theorem | `k3_euler'` |
| 14 | 🔵 theorem | `cy3_euler'` |
| 18 | 🔵 theorem | `elliptic_discriminant'` |
| 21 | 🔵 theorem | `ec_example_disc'` |
| 24 | 🔵 theorem | `ec_points'` |
| 31 | 🔵 theorem | `five_congruent'` |
| 32 | 🔵 theorem | `six_congruent'` |
| 35 | 🔵 theorem | `hasse_bound_5'` |
| 38 | 🔵 theorem | `ec_conductor_example'` |
| 41 | 🔵 theorem | `ap_from_counting'` |

### 📄 InformationGeometry.lean

| Line | Kind | Name |
|------|------|------|
| 7 | 🔵 theorem | `bernoulli_fisher'` |
| 12 | 🔵 theorem | `fisher_additive_n` |
| 16 | 🔵 theorem | `cramer_rao_bound` |
| 20 | 🔵 theorem | `uniform_entropy_pos` |
| 23 | 🔵 theorem | `iof_info` |

### 📄 MetricGeometry.lean

| Line | Kind | Name |
|------|------|------|
| 11 | 🔵 theorem | `isometry_dist'` |
| 15 | 🔵 theorem | `isometry_comp'` |
| 21 | 🔵 theorem | `completion_complete'` |
| 26 | 🔵 theorem | `hausdorff_dist_comm'` |
| 32 | 🔵 theorem | `euclidean_dist_eq_norm` |
| 35 | 🔵 theorem | `euclidean_triangle'` |
| 40 | 🔵 theorem | `nearest_neighbor_exists'` |

### 📄 SymplecticGeometry.lean

| Line | Kind | Name |
|------|------|------|
| 8 | 🟡 def | `symp_J` |
| 10 | 🔵 theorem | `symp_J_sq` |
| 13 | 🔵 theorem | `symp_J_det` |
| 15 | 🔵 theorem | `symp_product` |
| 19 | 🟡 def | `mod_S` |
| 20 | 🟡 def | `mod_T` |
| 22 | 🔵 theorem | `mod_S_det` |
| 23 | 🔵 theorem | `mod_T_det` |
| 25 | 🔵 theorem | `mod_S_sq` |
| 28 | 🔵 theorem | `mod_S_ord4` |
| 32 | 🔵 theorem | `mod_ST_cubed` |
| 39 | 🔵 theorem | `liouville_2d_thm` |
| 43 | 🔵 theorem | `berg_B1` |
| 47 | 🔵 theorem | `berg_B2` |
| 51 | 🔵 theorem | `berg_B3` |

---

## HarmonicNetworks

### 📄 HarmonicNetwork.lean

| Line | Kind | Name |
|------|------|------|
| 33 | 🔵 theorem | `pythagorean_identity` |
| 43 | 🔵 theorem | `generalized_pythagorean_identity` |
| 48 | 🔵 theorem | `generalized_pythagorean_identity_rat` |
| 53 | 🔵 theorem | `generalized_pythagorean_identity_real` |
| 64 | 🟠 noncomputable def | `stereo2D` |
| 70 | 🔵 theorem | `stereo2D_unit_norm` |
| 103 | 🔵 theorem | `projection_numerator_eq_sq` |
| 116 | 🔵 theorem | `sum_sq_proj_eq` |
| 126 | 🔵 theorem | `unit_norm_2d_div` |
| 138 | 🔵 theorem | `generates_pythagorean_triple` |
| 143 | 🔵 theorem | `pythagorean_triple_nonneg` |
| 154 | 🔵 theorem | `projection_rational` |
| 167 | 🔵 theorem | `projection_idempotent_2d` |
| 186 | 🔵 theorem | `rational_circle_param` |
| 204 | 🔵 theorem | `snap_exact_unit_norm` |
| 218 | 🔵 theorem | `pythagorean_identity_ring` |
| 223 | 🔵 theorem | `generalized_identity_ring` |
| 234 | 🔵 theorem | `unit_product_norm` |
| 247 | 🔵 theorem | `stereo_preserves_orthogonality` |
| 272 | 🔵 theorem | `stereo_param_lipschitz` |
| 289 | 🔵 theorem | `brahmagupta_fibonacci` |
| 310 | 🔵 theorem | `rational_point_from_param` |

### 📄 HarmonicNetworkAdvanced.lean

| Line | Kind | Name |
|------|------|------|
| 24 | 🔵 theorem | `relu_rational` |
| 27 | 🔵 theorem | `relu_nonneg` |
| 30 | 🔵 theorem | `relu_idempotent` |
| 44 | 🔵 theorem | `stereo_first_component_bounded` |
| 55 | 🔵 theorem | `stereo_second_component_bounded` |
| 64 | 🔵 theorem | `stereo_neg_both` |
| 69 | 🔵 theorem | `stereo_neg_first` |
| 74 | 🔵 theorem | `stereo_swap_second` |
| 83 | 🔵 theorem | `sum_sq_nonneg_list` |
| 97 | 🔵 theorem | `sum_sq_eq_zero_iff` |
| 110 | 🔵 theorem | `rational_dot_product` |
| 114 | 🔵 theorem | `relu_pointwise_rational` |
| 130 | 🔵 theorem | `stereo_second_lipschitz` |
| 155 | 🔵 theorem | `rational_approx_error` |
| 169 | 🔵 theorem | `stereo_scale_invariant` |
| 178 | 🔵 theorem | `stereo_scale_invariant_second` |
| 193 | 🔵 theorem | `euler_four_square` |
| 207 | 🔵 theorem | `stereo_closure_under_multiplication` |
| 224 | 🔵 theorem | `stereo_calibration_zero` |
| 227 | 🔵 theorem | `stereo_calibration_one` |
| 230 | 🔵 theorem | `stereo_first_odd` |
| 234 | 🔵 theorem | `stereo_second_even` |
| 243 | 🔵 theorem | `cayley_dickson_norm` |
| 254 | 🔵 theorem | `unit_complex_mul_norm` |
| 266 | 🔵 theorem | `stereo_cross_ratio` |
| 279 | 🔵 theorem | `projection_numerator_fin` |

### 📄 HelicityBound.lean

| Line | Kind | Name |
|------|------|------|
| 23 | 🔵 theorem | `two_abs_mul_le_sq_add_sq` |
| 34 | 🔵 theorem | `helicity_bound` |
| 45 | 🔵 theorem | `helicity_bound_tight` |
| 56 | 🔵 theorem | `helicity_bound_nat` |

### 📄 LightCone.lean

| Line | Kind | Name |
|------|------|------|
| 16 | 🔴 structure | `PhotonState where` |
| 30 | 🟡 def | `PhotonState.fuse` |
| 45 | 🔵 theorem | `PhotonState.fuse_comm` |
| 58 | 🔵 theorem | `PhotonState.fuse_assoc` |
| 69 | 🟡 def | `PhotonState.identity` |
| 83 | 🔵 theorem | `PhotonState.identity_fuse` |
| 99 | 🔵 theorem | `light_cone_triangulation` |

### 📄 LightConeTheory.lean

| Line | Kind | Name |
|------|------|------|
| 66 | 🟡 def | `minkowskiForm` |
| 69 | 🟡 def | `isLightLike` |
| 72 | 🟡 def | `isTimeLike` |
| 75 | 🟡 def | `isSpaceLike` |
| 78 | 🔵 theorem | `light_like_iff_pythagorean` |
| 83 | 🔵 theorem | `light_cone_is_cone` |
| 88 | 🔵 theorem | `light_like_self_orthogonal` |
| 93 | 🔵 theorem | `pyth_triple_is_light_like` |
| 98 | 🔵 theorem | `origin_is_light_like` |
| 102 | 🔵 theorem | `triple_345_light_like` |
| 106 | 🔵 theorem | `triple_51213_light_like` |
| 110 | 🔵 theorem | `causal_classification` |
| 119 | 🔵 theorem | `not_timelike_and_lightlike` |
| 124 | 🔵 theorem | `not_timelike_and_spacelike` |
| 129 | 🔵 theorem | `not_lightlike_and_spacelike` |
| 136 | 🟡 def | `minkowskiInner` |
| 140 | 🔵 theorem | `minkowski_form_eq_inner` |
| 145 | 🔵 theorem | `light_like_orthogonal_iff` |
| 152 | 🟡 def | `lorentzBoostX` |
| 157 | 🔵 theorem | `lorentz_boost_preserves_form` |
| 165 | 🔵 theorem | `lorentz_boost_preserves_light_like` |
| 173 | 🔵 theorem | `berggren_A_maps_light_to_light` |
| 178 | 🔵 theorem | `berggren_B_maps_light_to_light` |
| 183 | 🔵 theorem | `berggren_C_maps_light_to_light` |
| 188 | 🔵 theorem | `rapidity_composition` |
| 199 | 🔵 theorem | `celestial_sphere_is_circle` |
| 205 | 🔵 theorem | `circle_on_light_cone` |
| 210 | 🔵 theorem | `celestial_sphere_at_height` |
| 215 | 🟡 def | `celestialStereo` |
| 218 | 🟡 def | `invCelestialStereo` |
| 222 | 🔵 theorem | `inv_celestial_stereo_is_light_like` |
| 231 | 🔵 theorem | `conformal_factor_positive` |
| 238 | 🔵 theorem | `crystallized_weight_on_light_cone` |
| 244 | 🔵 theorem | `photon_energy_momentum` |
| 249 | 🔵 theorem | `doppler_shift_formula` |
| 255 | 🔵 theorem | `doppler_factor_pure_x` |
| 261 | 🔵 theorem | `doppler_is_exponential` |
| 266 | 🔵 theorem | `doppler_factor_positive` |
| 274 | 🔵 theorem | `minkowski_polarization` |
| 281 | 🔵 theorem | `sum_light_like_iff_orthogonal` |
| 291 | 🔵 theorem | `null_inner_from_sum` |
| 300 | 🔵 theorem | `null_coordinates` |
| 305 | 🔵 theorem | `light_like_null_coords` |
| 310 | 🔵 theorem | `light_cone_b_zero` |
| 320 | 🔵 theorem | `photon_pair_to_timelike` |
| 327 | 🔵 theorem | `photon_pair_invariant_mass` |
| 339 | 🔵 theorem | `crystallizer_to_celestial` |
| 353 | 🔵 theorem | `crystallizer_loss_measures_photon_deviation` |
| 359 | 🔵 theorem | `finite_photons_bounded_energy` |

### 📄 LightFromNumberLine.lean

| Line | Kind | Name |
|------|------|------|
| 10 | 🔵 theorem | `pythagorean_parametrization` |
| 17 | 🔵 theorem | `brahmagupta_fibonacci` |
| 23 | 🔵 theorem | `brahmagupta_fibonacci'` |
| 37 | 🔵 theorem | `unit_circle_rational_point` |
| 45 | 🔵 theorem | `gaussian_norm_multiplicative` |
| 58 | 🔵 theorem | `fermat_two_square_easy_direction` |
| 75 | 🔵 theorem | `infinitely_many_pythagorean_triples` |
| 84 | 🔵 theorem | `lightlike_direction` |
| 89 | 🔵 theorem | `lightlike_scaling` |
| 96 | 🔵 theorem | `pythagorean_superposition` |
| 105 | 🔵 theorem | `two_is_sum_of_squares` |
| 109 | 🔵 theorem | `five_splits` |
| 113 | 🔵 theorem | `thirteen_splits` |
| 119 | 🔵 theorem | `interference_25` |
| 124 | 🔵 theorem | `multiple_representations_50` |
| 137 | 🔵 theorem | `sum_two_squares_mod4` |
| 143 | 🔵 theorem | `triple_3_4_5` |
| 146 | 🔵 theorem | `triple_5_12_13` |
| 149 | 🔵 theorem | `triple_8_15_17` |
| 152 | 🔵 theorem | `triple_7_24_25` |
| 165 | 🔵 theorem | `polarization_density` |
| 174 | 🟡 def | `gaussianNorm` |
| 177 | 🔵 theorem | `gaussianNorm_nonneg` |
| 182 | 🔵 theorem | `gaussianNorm_mul` |
| 194 | 🔵 theorem | `gaussianNorm_eq_zero` |
| 211 | 🔵 theorem | `wave_particle_complementarity` |

### 📄 LightNumberLine.lean

| Line | Kind | Name |
|------|------|------|
| 26 | 🔵 theorem | `pythagorean_param` |
| 30 | 🔵 theorem | `pythagorean_param_alt` |
| 35 | 🔵 theorem | `brahmagupta_fibonacci_identity` |
| 40 | 🔵 theorem | `brahmagupta_fibonacci_alt` |
| 46 | 🔵 theorem | `unit_circle_from_pythagorean` |
| 54 | 🔵 theorem | `lightlike_null` |
| 58 | 🔵 theorem | `lightlike_scale` |
| 62 | 🔵 theorem | `lightlike_compose` |
| 68 | 🔵 theorem | `pythagorean_gaussian_rotate` |
| 76 | 🔵 theorem | `gaussian_norm_mult` |
| 81 | 🔵 theorem | `gaussian_conj_norm` |
| 85 | 🔵 theorem | `gaussian_unit_i_norm` |
| 88 | 🔵 theorem | `gaussian_norm_one_plus_i` |
| 91 | 🔵 theorem | `prime_5_splits` |
| 92 | 🔵 theorem | `prime_13_splits` |
| 93 | 🔵 theorem | `prime_17_splits` |
| 94 | 🔵 theorem | `prime_29_splits` |
| 95 | 🔵 theorem | `prime_37_splits` |
| 98 | 🔵 theorem | `triple_beam_split` |
| 108 | 🔵 theorem | `fermat_easy` |
| 121 | 🔵 theorem | `no_sum_two_squares_3_mod_4` |
| 131 | 🔵 theorem | `triple_3_4_5'` |
| 132 | 🔵 theorem | `triple_5_12_13'` |
| 133 | 🔵 theorem | `triple_8_15_17'` |
| 134 | 🔵 theorem | `triple_7_24_25` |
| 135 | 🔵 theorem | `triple_20_21_29` |
| 136 | 🔵 theorem | `triple_9_40_41` |
| 137 | 🔵 theorem | `triple_12_35_37` |
| 138 | 🔵 theorem | `triple_11_60_61` |
| 139 | 🔵 theorem | `triple_28_45_53` |
| 140 | 🔵 theorem | `triple_33_56_65` |
| 143 | 🔵 theorem | `multi_representation_65_a` |
| 144 | 🔵 theorem | `multi_representation_65_b` |
| 147 | 🔵 theorem | `interference_25_a` |
| 148 | 🔵 theorem | `interference_25_b` |
| 153 | 🔵 theorem | `infinitely_many_triples` |
| 159 | 🔵 theorem | `family_m_squared` |
| 164 | 🔵 theorem | `family_consecutive` |
| 170 | 🔵 theorem | `euler_four_square_identity` |
| 178 | 🔵 theorem | `square_is_four_squares` |
| 183 | 🔵 theorem | `two_squares_to_four` |
| 190 | 🔵 theorem | `r2_multiplicative_structure` |
| 197 | 🔵 theorem | `pythagorean_compression` |
| 204 | 🔵 theorem | `composition_preserves_compression` |
| 220 | 🔵 theorem | `sum_squares_mod_4` |
| 225 | 🔵 theorem | `pythagorean_mod` |
| 232 | 🔵 theorem | `l2_norm_decomposition` |
| 236 | 🔵 theorem | `polarization_identity` |
| 240 | 🔵 theorem | `lattice_triangle_sq` |
| 248 | 🔵 theorem | `sophie_germain` |
| 253 | 🔵 theorem | `lebesgue_identity` |
| 257 | 🔵 theorem | `fourth_power_decomp` |
| 261 | 🔵 theorem | `vieta_jump` |
| 265 | 🔵 theorem | `hypotenuse_difference` |
| 273 | 🔵 theorem | `gaussian_product_encode` |
| 278 | 🔵 theorem | `angle_addition` |
| 288 | 🔵 theorem | `pythagorean_quadruple_1` |
| 289 | 🔵 theorem | `pythagorean_quadruple_2` |
| 292 | 🔵 theorem | `quaternion_norm_mult` |
| 304 | 🔵 theorem | `r2_zero` |
| 311 | 🔵 theorem | `r2_identity_at_1` |
| 321 | 🔵 theorem | `trig_pythagorean` |
| 326 | 🔵 theorem | `cos_addition` |
| 331 | 🔵 theorem | `interference_amplitude` |
| 338 | 🟠 noncomputable def | `chi4` |
| 343 | 🔵 theorem | `chi4_at_1` |
| 344 | 🔵 theorem | `chi4_at_3` |
| 345 | 🔵 theorem | `chi4_at_5` |
| 346 | 🔵 theorem | `chi4_at_7` |
| 355 | 🔵 theorem | `leibniz_partial` |
| 362 | 🔵 theorem | `massless_dispersion` |
| 366 | 🔵 theorem | `momentum_conservation` |
| 374 | 🔵 theorem | `grand_unification` |

### 📄 NumberLineEncoding.lean

| Line | Kind | Name |
|------|------|------|
| 71 | 🟡 def | `cantorPair` |
| 74 | 🔵 theorem | `cantorPair_injective` |
| 85 | 🟡 def | `zigzagEncode` |
| 90 | 🔵 theorem | `zigzagEncode_injective` |
| 97 | 🟡 def | `encodeGaussian` |
| 101 | 🔵 theorem | `encodeGaussian_injective` |
| 115 | 🔵 theorem | `encodeGaussian_surjective` |
| 143 | 🔴 structure | `FiniteGraph` |
| 147 | 🟡 def | `encodeGraph` |
| 152 | 🔵 theorem | `encodeGraph_injective` |
| 200 | 🔴 structure | `LabeledPhotonGraph` |
| 206 | 🟡 def | `encodeLabeledPhotonGraph` |
| 218 | 🟡 def | `PhotonHistory` |
| 221 | 🟠 noncomputable def | `encodeHistory` |
| 225 | 🔵 theorem | `encodeHistory_nonneg` |
| 229 | 🔵 theorem | `encodeHistory_le_one` |
| 252 | 🟡 def | `PhotonHistory.nonDegenerate` |
| 265 | 🔵 theorem | `encodeHistory_injective_nonDegenerate` |
| 329 | 🔵 theorem | `photon_codes_surjective` |
| 338 | 🔵 theorem | `photon_encoding_bijective` |

### 📄 PythagoreanNeuralArch.lean

| Line | Kind | Name |
|------|------|------|
| 42 | 🔵 theorem | `pythagorean_unit_circle` |
| 49 | 🔵 theorem | `pythagorean_unit_circle_real` |
| 61 | 🔵 theorem | `pythagorean_weight_norm_sq` |
| 66 | 🔵 theorem | `pythagorean_weight_component_bound` |
| 84 | 🔵 theorem | `brahmagupta_fibonacci` |
| 90 | 🔵 theorem | `gaussian_composition_preserves_pyth` |
| 103 | 🔵 theorem | `gaussian_composition_unit_circle` |
| 122 | 🔵 theorem | `pythagorean_layer_lipschitz` |
| 130 | 🔵 theorem | `deep_network_lipschitz` |
| 145 | 🔵 theorem | `berggren_M1_unit_circle` |
| 153 | 🔵 theorem | `berggren_M2_unit_circle` |
| 161 | 🔵 theorem | `berggren_M3_unit_circle` |
| 170 | 🔵 theorem | `berggren_hypotenuse_grows` |
| 185 | 🔵 theorem | `stereographic_unit_circle` |
| 192 | 🔵 theorem | `stereographic_unit_circle_rat` |
| 205 | 🔵 theorem | `berggren_tree_count` |
| 209 | 🔵 theorem | `berggren_tree_exponential_growth` |
| 228 | 🔵 theorem | `clamp_lipschitz` |
| 239 | 🔵 theorem | `hypotenuse_upper_bound_crude` |
| 248 | 🔵 theorem | `leg_le_hypotenuse` |
| 262 | 🔵 theorem | `gaussian_norm_multiplicative` |
| 268 | 🔵 theorem | `gaussian_norm_identity` |
| 273 | 🔵 theorem | `gaussian_composition_comm` |
| 280 | 🔵 theorem | `gaussian_norm_assoc` |
| 291 | 🔵 theorem | `pythagorean_row_norm` |
| 334 | 🔵 theorem | `angle_resolution_bound` |

### 📄 StrangeLight.lean

| Line | Kind | Name |
|------|------|------|
| 37 | 🟡 def | `stokesMinkowski` |
| 41 | 🔵 theorem | `fully_polarized_is_null` |
| 47 | 🔵 theorem | `partially_polarized_is_timelike` |
| 53 | 🔵 theorem | `unpolarized_maximum_mass` |
| 60 | 🔵 theorem | `collinear_photons_null` |
| 69 | 🔵 theorem | `antiparallel_photons_massive` |
| 77 | 🔵 theorem | `combined_photon_mass` |
| 89 | 🟡 def | `stokesInner` |
| 95 | 🔵 theorem | `h_v_stokes_inner` |
| 100 | 🔵 theorem | `stokes_inner_product_formula` |
| 106 | 🔵 theorem | `malus_connection` |
| 115 | 🟡 def | `degree_of_pol` |
| 119 | 🔵 theorem | `unpol_degree_zero` |
| 126 | 🟡 def | `right_circular_stokes` |
| 129 | 🟡 def | `left_circular_stokes` |
| 132 | 🔵 theorem | `rcp_fully_polarized` |
| 137 | 🔵 theorem | `lcp_fully_polarized` |
| 143 | 🔵 theorem | `rcp_lcp_inner` |
| 148 | 🔵 theorem | `rcp_lcp_antipodal` |
| 157 | 🔵 theorem | `pyth_to_linear_pol` |
| 164 | 🔵 theorem | `triple_345_pol` |
| 169 | 🔵 theorem | `triple_51213_pol` |
| 176 | 🔵 theorem | `duality_rotation_preserves_norm` |
| 182 | 🟡 def | `photon_worldline` |
| 186 | 🔵 theorem | `origin_on_worldline` |
| 190 | 🔵 theorem | `worldline_scaling` |
| 195 | 🔵 theorem | `speed_of_light_one` |
| 204 | 🔵 theorem | `poincare_sphere_euler` |
| 207 | 🔵 theorem | `berry_phase_great_circle` |
| 210 | 🔵 theorem | `berry_phase_small_circle` |
| 232 | 🔵 theorem | `poincare_sphere_is_light_cone` |
| 237 | 🔵 theorem | `partial_pol_is_timelike` |
| 242 | 🔵 theorem | `unpolarized_is_pure_timelike` |

---

## Meta

### 📄 DecoderApplications.lean

| Line | Kind | Name |
|------|------|------|
| 18 | 🔵 theorem | `gaussian_norm_submult` |
| 24 | 🔵 theorem | `gaussian_lattice_neighbors` |
| 51 | 🔵 theorem | `hex_lattice_neighbors` |
| 61 | 🔵 theorem | `two_pow_sum_four_sq` |
| 76 | 🔵 theorem | `root_of_unity_sum` |
| 85 | 🔵 theorem | `torus_parametrization` |
| 95 | 🔵 theorem | `pythagorean_comma` |
| 99 | 🔵 theorem | `syntonic_comma` |
| 104 | 🔵 theorem | `timelike_positive` |
| 107 | 🔵 theorem | `lightlike_zero` |
| 112 | 🔵 theorem | `quantum_dim_recursion` |
| 117 | 🔵 theorem | `ads_conformal_factor` |
| 122 | 🔵 theorem | `legendre_P1_identity` |

### 📄 DeepConnections.lean

| Line | Kind | Name |
|------|------|------|
| 30 | 🟠 noncomputable def | `chebyT` |
| 36 | 🔵 theorem | `chebyT_zero` |
| 39 | 🔵 theorem | `chebyT_one` |
| 48 | 🔵 theorem | `chebyT_degree` |
| 67 | 🔵 theorem | `chebyT_comp` |
| 110 | 🔴 structure | `PellSolution` |
| 116 | 🟡 def | `PellSolution.trivial` |
| 119 | 🟡 def | `PellSolution.compose` |
| 134 | 🔵 theorem | `pell_compose_assoc` |
| 148 | 🔵 theorem | `pell_compose_trivial_left` |
| 173 | 🔵 theorem | `sum_two_sq_mod` |
| 208 | 🔵 theorem | `minkowski_1d` |
| 230 | 🔵 theorem | `padic_val_add_ge_min` |
| 266 | 🔵 theorem | `geometric_sum_formula` |

### 📄 DeepResults.lean

| Line | Kind | Name |
|------|------|------|
| 16 | 🔵 theorem | `totient_sum` |
| 21 | 🔵 theorem | `totient_mul_coprime` |
| 26 | 🔵 theorem | `totient_prime` |
| 30 | 🔵 theorem | `totient_prime_sq` |
| 36 | 🔵 theorem | `mobius_1` |
| 37 | 🔵 theorem | `mobius_2` |
| 38 | 🔵 theorem | `mobius_4` |
| 39 | 🔵 theorem | `mobius_6` |
| 40 | 🔵 theorem | `mobius_30` |
| 45 | 🔵 theorem | `cyclotomic_1` |
| 49 | 🔵 theorem | `cyclotomic_2` |
| 55 | 🔵 theorem | `handshaking` |
| 59 | 🔵 theorem | `turan_triangle_free` |
| 62 | 🔵 theorem | `friendship_universal` |
| 67 | 🔵 theorem | `trace_sq` |
| 72 | 🔵 theorem | `eigenvalue_eq` |
| 79 | 🔵 theorem | `markov_alg` |
| 82 | 🔵 theorem | `chebyshev_bound` |
| 86 | 🔵 theorem | `total_exp` |
| 91 | 🔵 theorem | `lagrange_idx` |
| 95 | 🔵 theorem | `cauchy_s3` |
| 98 | 🔵 theorem | `class_eq_s3` |
| 103 | 🟡 def | `eulerCharSfc` |
| 105 | 🔵 theorem | `euler_sphere` |
| 106 | 🔵 theorem | `euler_torus` |
| 107 | 🔵 theorem | `euler_genus2` |
| 110 | 🔵 theorem | `euler_tetra` |
| 111 | 🔵 theorem | `euler_cube` |
| 112 | 🔵 theorem | `euler_octa` |
| 113 | 🔵 theorem | `euler_dodeca` |
| 114 | 🔵 theorem | `euler_icosa` |
| 117 | 🔵 theorem | `gauss_bonnet_sp` |
| 122 | 🔵 theorem | `sqrt2_a1` |
| 123 | 🔵 theorem | `sqrt2_a2` |
| 124 | 🔵 theorem | `sqrt2_a3` |
| 125 | 🔵 theorem | `sqrt2_a4` |
| 126 | 🔵 theorem | `sqrt2_a5` |
| 129 | 🔵 theorem | `pell_preserve` |
| 133 | 🔵 theorem | `pell_negate` |
| 140 | 🔵 theorem | `pick_square` |
| 143 | 🔵 theorem | `minkowski_2d` |
| 146 | 🔵 theorem | `isoperim_sq` |
| 151 | 🔵 theorem | `am_gm_sq` |
| 154 | 🔵 theorem | `power_mean_12` |
| 158 | 🔵 theorem | `jensen_sq` |
| 165 | 🔵 theorem | `cauchy_schwarz_2` |
| 171 | 🔵 theorem | `triangle_ineq_alg` |
| 190 | 🔵 theorem | `schur_degree1` |
| 198 | 🔵 theorem | `vandermonde_22` |
| 202 | 🔵 theorem | `hockey_stick_small` |
| 207 | 🔵 theorem | `lucas_small` |
| 210 | 🔵 theorem | `korselt_561` |
| 215 | 🔵 theorem | `wilson_5` |
| 216 | 🔵 theorem | `wilson_7` |
| 217 | 🔵 theorem | `wilson_11` |
| 218 | 🔵 theorem | `wilson_13` |

### 📄 Experiments2.lean

| Line | Kind | Name |
|------|------|------|
| 76 | 🟡 def | `fib` |
| 95 | 🟡 def | `ilog2` |
| 140 | 🟡 def | `isPrime` |
| 151 | 🟡 def | `hasBadFactor` |

### 📄 FrontierResearch.lean

| Line | Kind | Name |
|------|------|------|
| 22 | 🟡 def | `η` |
| 25 | 🟡 def | `B₁'` |
| 28 | 🟡 def | `B₂'` |
| 31 | 🟡 def | `B₃'` |
| 34 | 🔵 theorem | `B1_lorentz` |
| 37 | 🔵 theorem | `B2_lorentz` |
| 40 | 🔵 theorem | `B3_lorentz` |
| 43 | 🔵 theorem | `B1_det` |
| 46 | 🔵 theorem | `B2_det` |
| 49 | 🔵 theorem | `B3_det` |
| 54 | 🟡 def | `isBrightPrime` |
| 57 | 🟡 def | `isDarkPrime` |
| 60 | 🔵 theorem | `prime_bright_or_dark` |
| 73 | 🔵 theorem | `two_neither_bright_nor_dark` |
| 77 | 🔵 theorem | `bright_count_100` |
| 82 | 🔵 theorem | `dark_count_100` |
| 87 | 🔵 theorem | `chebyshev_bias_100` |
| 93 | 🔵 theorem | `chebyshev_bias_1000` |
| 101 | 🔵 theorem | `quaternion_noncommutative` |
| 108 | 🔵 theorem | `quaternion_associative` |
| 114 | 🔵 theorem | `two_square_identity` |
| 118 | 🔵 theorem | `four_square_identity` |
| 126 | 🔵 theorem | `pythagorean_parametrization` |
| 132 | 🟡 def | `modT` |
| 133 | 🟡 def | `modS` |
| 136 | 🟡 def | `M₁'` |
| 137 | 🟡 def | `M₃'` |
| 140 | 🔵 theorem | `M1_eq_T2S` |
| 143 | 🔵 theorem | `M3_eq_T2` |
| 146 | 🔵 theorem | `M1_det_one` |
| 149 | 🔵 theorem | `M3_det_one` |
| 152 | 🔵 theorem | `S_order_4` |
| 155 | 🔵 theorem | `modular_relation` |
| 160 | 🟡 def | `PythRot` |
| 163 | 🔵 theorem | `PythRot_mul` |
| 169 | 🔵 theorem | `PythRot_det` |
| 173 | 🔵 theorem | `PythRot_comm` |
| 180 | 🟡 def | `minkowski_form` |
| 184 | 🔵 theorem | `pyth_triple_null` |
| 189 | 🔵 theorem | `B1_preserves_pyth` |
| 198 | 🟡 def | `associator_ring` |
| 202 | 🔵 theorem | `associator_zero_of_assoc` |
| 207 | 🔵 theorem | `quaternion_associator_zero` |
| 213 | 🔵 theorem | `complex_commutative` |
| 216 | 🔵 theorem | `complex_norm_multiplicative` |

### 📄 FrontierTheorems.lean

| Line | Kind | Name |
|------|------|------|
| 35 | 🔵 theorem | `fibonacci_pythagorean_345` |
| 39 | 🔵 theorem | `fibonacci_pythagorean_51213` |
| 45 | 🔵 theorem | `fibonacci_pythagorean_general` |
| 62 | 🔵 theorem | `pyth_3_dvd_ab` |
| 73 | 🔵 theorem | `pyth_2_dvd_ab` |
| 85 | 🔵 theorem | `pyth_6_dvd_ab` |
| 100 | 🔵 theorem | `berggren_trace_sum` |
| 113 | 🔵 theorem | `berggren_det_product` |
| 133 | 🔵 theorem | `B1_preserves_pyth_def` |
| 145 | 🔵 theorem | `hyp_5_mod4` |
| 148 | 🔵 theorem | `hyp_13_mod4` |
| 151 | 🔵 theorem | `hyp_17_mod4` |
| 154 | 🔵 theorem | `hyp_29_mod4` |
| 157 | 🔵 theorem | `hyp_37_mod4` |
| 160 | 🔵 theorem | `sum_two_sq_5` |
| 161 | 🔵 theorem | `sum_two_sq_13` |
| 162 | 🔵 theorem | `sum_two_sq_17` |
| 163 | 🔵 theorem | `sum_two_sq_29` |
| 164 | 🔵 theorem | `sum_two_sq_37` |
| 178 | 🔵 theorem | `iof_energy_decreasing` |
| 183 | 🔵 theorem | `iof_energy_nonneg` |
| 191 | 🔵 theorem | `brahmagupta_fibonacci` |
| 196 | 🔵 theorem | `hypotenuse_product_sum_sq` |
| 208 | 🔵 theorem | `congruent_6` |
| 211 | 🔵 theorem | `congruent_30` |
| 214 | 🔵 theorem | `congruent_210` |
| 218 | 🔵 theorem | `bsd_curve_6` |
| 222 | 🔵 theorem | `congruent_210_factored` |
| 230 | 🟡 def | `leg_swap` |
| 239 | 🔵 theorem | `leg_swap_involution` |
| 249 | 🔵 theorem | `leg_swap_det` |
| 259 | 🔵 theorem | `sum_two_sq_5'` |
| 260 | 🔵 theorem | `sum_two_sq_13'` |
| 261 | 🔵 theorem | `sum_two_sq_17'` |
| 262 | 🔵 theorem | `sum_two_sq_29'` |
| 263 | 🔵 theorem | `sum_two_sq_37'` |
| 275 | 🔵 theorem | `M1_cayley_hamilton` |
| 282 | 🔵 theorem | `M1_char_poly_discriminant` |
| 287 | 🔵 theorem | `pell_3_base_solution` |
| 290 | 🔵 theorem | `pell_3_next_solution` |
| 294 | 🔵 theorem | `pell_3_composition` |

### 📄 FutureResearch.lean

| Line | Kind | Name |
|------|------|------|
| 45 | 🔵 theorem | `fibonacci_pythagorean_identity` |
| 59 | 🔵 theorem | `fib_square_recurrence` |
| 72 | 🔵 theorem | `berggren_M1_fibonacci_action` |
| 84 | 🔵 theorem | `fibonacci_double_square` |
| 96 | 🟡 def | `B₁'` |
| 99 | 🟡 def | `B₂'` |
| 102 | 🟡 def | `B₃'` |
| 111 | 🔵 theorem | `trace_B₁` |
| 121 | 🔵 theorem | `trace_B₂` |
| 131 | 🔵 theorem | `trace_B₃` |
| 143 | 🔵 theorem | `berggren_trace_sum` |
| 154 | 🔵 theorem | `trace_B₁_mul_B₂` |
| 164 | 🔵 theorem | `trace_B₁_sq` |
| 176 | 🟡 def | `Q_lor` |
| 185 | 🔵 theorem | `B₁_in_SO21` |
| 195 | 🔵 theorem | `B₂_in_O21_not_SO21` |
| 205 | 🔵 theorem | `B₃_in_SO21` |
| 215 | 🔵 theorem | `det_B₁_mul_B₃` |
| 225 | 🔵 theorem | `det_triple_product` |
| 243 | 🔵 theorem | `pyth_prod_even` |
| 256 | 🔵 theorem | `pyth_prod_div3` |
| 268 | 🔵 theorem | `pyth_prod_div6` |
| 279 | 🔵 theorem | `area_345` |
| 289 | 🔵 theorem | `area_5_12_13` |
| 306 | 🔵 theorem | `quadratic_descent_positive` |
| 317 | 🔵 theorem | `linear_descent_bound` |
| 328 | 🔵 theorem | `pythagorean_triangle_ineq` |
| 340 | 🔵 theorem | `elliptic_positivity` |
| 357 | 🔵 theorem | `M₁_cayley_hamilton` |
| 370 | 🔵 theorem | `M₂_cayley_hamilton` |
| 383 | 🔵 theorem | `M₃_unipotent` |
| 397 | 🔵 theorem | `M₂_expanding` |
| 410 | 🔵 theorem | `M₁_trace_powers` |
| 431 | 🔵 theorem | `tropical_add_comm` |
| 441 | 🔵 theorem | `tropical_add_assoc` |
| 452 | 🔵 theorem | `tropical_distrib` |
| 463 | 🔵 theorem | `tropical_det_M₁` |
| 480 | 🔵 theorem | `pyth_mod_any` |
| 491 | 🔵 theorem | `pyth_mod4_parity` |
| 502 | 🔵 theorem | `sq_mod3` |
| 512 | 🔵 theorem | `sq_mod5` |
| 524 | 🔵 theorem | `sum_sq_mod3` |
| 542 | 🔵 theorem | `brahmagupta_fibonacci` |
| 553 | 🔵 theorem | `brahmagupta_fibonacci_alt` |
| 566 | 🔵 theorem | `pythagorean_composition` |
| 578 | 🔵 theorem | `pythagorean_unit` |
| 589 | 🔵 theorem | `pythagorean_unit_compose` |
| 601 | 🔵 theorem | `norm_mul_assoc` |
| 624 | 🔵 theorem | `berggren_345_child` |
| 631 | 🔵 theorem | `berggren_child_area_div6` |
| 643 | 🔵 theorem | `trace_det_duality_B₁` |
| 656 | 🔵 theorem | `master_identity` |

### 📄 Hypotheses.lean

| Line | Kind | Name |
|------|------|------|
| 39 | 🔵 theorem | `pythagorean_from_stereo` |
| 56 | 🔵 theorem | `twoPole_0b_at_0` |
| 85 | 🔵 theorem | `twoPole_transitivity` |
| 104 | 🔵 theorem | `matrix_product_identity` |
| 112 | 🔵 theorem | `matrix_product_identity'` |
| 164 | 🔵 theorem | `gaussian_norm` |
| 174 | 🔵 theorem | `gaussian_product_norm` |

### 📄 IntegerChains.lean

| Line | Kind | Name |
|------|------|------|
| 38 | 🔵 theorem | `chain_01_complete` |
| 80 | 🔵 theorem | `chain_1_neg1_complete` |
| 110 | 🔵 theorem | `twoPole_02_at_0` |
| 120 | 🔵 theorem | `twoPole_02_at_1` |
| 130 | 🔵 theorem | `twoPole_02_at_neg2` |
| 140 | 🔵 theorem | `twoPole_02_at_3` |
| 172 | 🔵 theorem | `twoPole_03_at_0` |
| 182 | 🔵 theorem | `twoPole_03_at_2` |
| 192 | 🔵 theorem | `twoPole_03_at_neg3` |
| 202 | 🔵 theorem | `twoPole_03_at_1` |
| 233 | 🔵 theorem | `twoPole_12_at_2` |
| 244 | 🔵 theorem | `twoPole_12_at_4` |
| 255 | 🔵 theorem | `twoPole_12_at_neg2` |
| 265 | 🔵 theorem | `twoPole_12_at_5` |
| 275 | 🔵 theorem | `twoPole_12_at_neg7` |
| 285 | 🔵 theorem | `twoPole_12_at_8` |
| 295 | 🔵 theorem | `twoPole_12_at_13` |

### 📄 IntegerDecoder.lean

| Line | Kind | Name |
|------|------|------|
| 21 | 🟠 noncomputable def | `r₂` |
| 26 | 🟠 noncomputable def | `r₄` |
| 38 | 🟡 def | `d₁` |
| 42 | 🟡 def | `d₃` |
| 46 | 🟡 def | `jacobi_sum` |
| 51 | 🔴 structure | `FourChannelSig where` |
| 63 | 🟡 def | `fourChannelSig` |
| 81 | 🔵 theorem | `lagrange_four_squares` |
| 93 | 🔵 theorem | `gaussian_norm_multiplicative` |
| 106 | 🔵 theorem | `sum_two_squares_mul` |
| 120 | 🔵 theorem | `channel_2_implies_4` |
| 133 | 🔵 theorem | `fermat_sum_two_squares` |
| 145 | 🔵 theorem | `euler_four_square_identity` |
| 161 | 🔵 theorem | `eight_square_identity_exists` |
| 191 | 🔵 theorem | `jacobi_sum_pos` |
| 202 | 🔵 theorem | `d₁_multiplicative` |

### 📄 MathExplorations.lean

| Line | Kind | Name |
|------|------|------|
| 15 | 🔵 theorem | `prime_mod_four` |
| 21 | 🔵 theorem | `wilson_theorem'` |
| 28 | 🔵 theorem | `pell_equation_small` |
| 29 | 🔵 theorem | `pell_equation_next` |
| 32 | 🔵 theorem | `pell_recurrence` |
| 35 | 🔵 theorem | `pell_matrix_det` |
| 39 | 🔵 theorem | `five_is_sum_of_squares` |
| 40 | 🔵 theorem | `thirteen_is_sum_of_squares` |
| 41 | 🔵 theorem | `seventeen_is_sum_of_squares` |
| 44 | 🔵 theorem | `gaussian_norm_mul` |
| 48 | 🔵 theorem | `brahmagupta_fibonacci` |
| 55 | 🔵 theorem | `bertrand_postulate'` |
| 60 | 🔵 theorem | `primes_infinite'` |
| 65 | 🔵 theorem | `markov_111` |
| 68 | 🔵 theorem | `markov_generate` |
| 71 | 🔵 theorem | `markov_112` |
| 72 | 🔵 theorem | `markov_125` |
| 76 | 🔵 theorem | `lagrange_four_sq_1` |
| 78 | 🔵 theorem | `lagrange_four_sq_7` |
| 80 | 🔵 theorem | `lagrange_four_sq_23` |
| 82 | 🔵 theorem | `lagrange_four_sq_15` |
| 87 | 🔵 theorem | `binary_tree_nodes` |
| 90 | 🔵 theorem | `ternary_tree_sum` |
| 102 | 🔵 theorem | `binary_entropy_bound` |
| 106 | 🔵 theorem | `factor_info_content` |
| 112 | 🔵 theorem | `contracting_terminates` |
| 125 | 🔵 theorem | `parent_hyp_less` |
| 131 | 🔵 theorem | `legendre_formula_example` |
| 133 | 🔵 theorem | `padic_val_mul'` |
| 140 | 🔵 theorem | `congruent_5` |
| 144 | 🔵 theorem | `congruent_6` |
| 161 | 🔵 theorem | `smallest_factor_le_sqrt` |
| 171 | 🔵 theorem | `sumset_singleton_card` |
| 177 | 🟡 def | `lorentz_inner` |
| 181 | 🔵 theorem | `pyth_on_lightcone` |
| 186 | 🔵 theorem | `lorentz_add_left` |
| 192 | 🔵 theorem | `euler_char_genus` |
| 197 | 🔵 theorem | `cayley_hamilton_2x2_identity` |
| 207 | 🔵 theorem | `Fp_card` |
| 210 | 🔵 theorem | `fermat_little` |
| 213 | 🔵 theorem | `Fp_star_cyclic` |
| 219 | 🔵 theorem | `ramsey_lower` |
| 231 | 🔵 theorem | `trop_add_comm` |
| 232 | 🔵 theorem | `trop_add_assoc` |
| 234 | 🔵 theorem | `trop_distrib` |
| 238 | ⚪ instance | `: DecidablePred` |
| 241 | 🔵 theorem | `pyth_triples_finite` |
| 251 | 🔵 theorem | `error_nonneg_over_Z` |
| 261 | 🔵 theorem | `multi_form_total_work` |

### 📄 MillenniumConnections.lean

| Line | Kind | Name |
|------|------|------|
| 39 | 🔵 theorem | `elliptic_discriminant_En` |
| 43 | 🔵 theorem | `En_2_torsion` |
| 50 | 🔵 theorem | `ppt_to_En_point` |
| 58 | 🔵 theorem | `nagell_lutz_discriminant` |
| 71 | 🔵 theorem | `sum_two_squares_mod4` |
| 88 | 🔵 theorem | `hypotenuse_prime_iff_1mod4` |
| 110 | 🔵 theorem | `lorentz_form_preserved_B1` |
| 115 | 🔵 theorem | `lorentz_form_preserved_B2` |
| 120 | 🔵 theorem | `lorentz_form_preserved_B3` |
| 127 | 🔵 theorem | `moonshine_numerology` |
| 130 | 🔵 theorem | `moonshine_second` |
| 133 | 🔵 theorem | `monster_order` |
| 140 | 🔵 theorem | `berggren_cayley_vertices` |

### 📄 MillenniumDeep.lean

| Line | Kind | Name |
|------|------|------|
| 7 | 🔵 theorem | `prime_count_100'` |
| 10 | 🔵 theorem | `prime_count_1000'` |
| 14 | 🔵 theorem | `factoring_in_np'` |
| 18 | 🔵 theorem | `clebsch_gordan_dims'` |
| 22 | 🔵 theorem | `serrin_exponents'` |
| 25 | 🔵 theorem | `ricci_fixed_point_s2'` |
| 29 | 🔵 theorem | `iof_millennium_connections'` |

### 📄 MillenniumProblems.lean

| Line | Kind | Name |
|------|------|------|
| 10 | 🟡 def | `sat_formula` |
| 13 | 🔵 theorem | `sat_formula_satisfiable` |
| 16 | 🔵 theorem | `sat_assignments` |
| 21 | 🔵 theorem | `euler_product_first_factor` |
| 22 | 🔵 theorem | `euler_product_second_factor` |
| 23 | 🔵 theorem | `euler_product_third_factor` |
| 26 | 🟡 def | `prime_count` |
| 28 | 🔵 theorem | `prime_count_10` |
| 29 | 🔵 theorem | `prime_count_20` |
| 30 | 🔵 theorem | `prime_count_100` |
| 34 | 🔵 theorem | `E_neg1_torsion` |
| 40 | 🔵 theorem | `nagell_lutz_discriminant'` |
| 45 | 🔵 theorem | `identity_eigenvalue` |
| 53 | 🔵 theorem | `sobolev_critical_3d'` |
| 57 | 🟡 def | `genus_plane_curve` |
| 59 | 🔵 theorem | `genus_line` |
| 60 | 🔵 theorem | `genus_conic` |
| 61 | 🔵 theorem | `genus_cubic` |
| 62 | 🔵 theorem | `genus_quartic` |
| 63 | 🔵 theorem | `genus_quintic` |
| 65 | 🔵 theorem | `riemann_hurwitz_example` |
| 69 | 🟡 def | `euler_char_surface` |
| 71 | 🔵 theorem | `euler_char_sphere` |
| 72 | 🔵 theorem | `euler_char_torus` |
| 73 | 🔵 theorem | `euler_char_genus2` |
| 75 | 🔵 theorem | `surface_classification` |

### 📄 MoonshotExplorations.lean

| Line | Kind | Name |
|------|------|------|
| 47 | 🟡 def | `isSumTwoSquares` |
| 50 | 🔵 theorem | `five_sum_two_squares` |
| 54 | 🔵 theorem | `thirteen_sum_two_squares` |
| 58 | 🔵 theorem | `fermat_christmas_instances` |
| 63 | 🔵 theorem | `norm_multiplicative` |
| 68 | 🔵 theorem | `sum_two_sq_mul_closed` |
| 75 | 🔵 theorem | `sixty_five_sum_two_squares` |
| 79 | 🔵 theorem | `sixty_five_alt` |
| 91 | 🔵 theorem | `stereographic_circle` |
| 98 | 🔵 theorem | `euclid_param` |
| 103 | 🔵 theorem | `rational_point_345` |
| 107 | 🔵 theorem | `rational_point_51213` |
| 112 | 🔵 theorem | `circle_group_law` |
| 125 | 🟡 def | `S_mat` |
| 126 | 🟡 def | `T_mat` |
| 129 | 🔵 theorem | `S_order_four` |
| 133 | 🔵 theorem | `S_squared` |
| 137 | 🔵 theorem | `det_S` |
| 141 | 🔵 theorem | `det_T` |
| 145 | 🔵 theorem | `T_unipotent` |
| 149 | 🔵 theorem | `ST_commutator` |
| 163 | 🔵 theorem | `curvature_identity` |
| 168 | 🔵 theorem | `arc_length_element` |
| 175 | 🔵 theorem | `right_triangle_angle_sum` |
| 186 | 🔵 theorem | `berggren_tree_growth` |
| 189 | 🔵 theorem | `berggren_tree_total` |
| 199 | 🔵 theorem | `berggren_root_345` |
| 202 | 🔵 theorem | `children_345_are_ppts` |
| 215 | 🔵 theorem | `gauss_circle_count_R1` |
| 221 | 🔵 theorem | `gauss_circle_count_R2` |
| 234 | 🔵 theorem | `rsa_two_ways` |
| 241 | 🔵 theorem | `fermat_little_instance` |
| 244 | 🔵 theorem | `wilson_instance` |
| 254 | 🔵 theorem | `qubit_normalized` |
| 258 | 🔵 theorem | `schmidt_pythagorean` |
| 262 | 🔵 theorem | `bloch_sphere_pure_state` |
| 273 | 🔵 theorem | `parseval_identity_2` |
| 277 | 🔵 theorem | `plancherel_345` |
| 280 | 🔵 theorem | `convolution_norm` |
| 292 | 🔵 theorem | `ternary_walk_depth` |
| 296 | 🔵 theorem | `hypotenuse_growth` |
| 299 | 🔵 theorem | `uniform_branch_prob` |
| 308 | ⚪ instance | `: DecidablePred` |
| 312 | 🔵 theorem | `check_345` |
| 315 | 🔵 theorem | `small_ppt_exists` |
| 326 | 🟡 def | `pythMap` |
| 329 | 🔵 theorem | `pythMap_zero` |
| 332 | 🔵 theorem | `pythMap_fiber` |
| 336 | 🔵 theorem | `norm_exact_sequence` |
| 347 | 🔵 theorem | `small_hypotenuses` |
| 354 | 🔵 theorem | `ppt_count_lower` |
| 365 | 🔵 theorem | `grundy_root_nonzero` |
| 368 | 🔵 theorem | `grundy_bound` |
| 372 | 🔵 theorem | `nim_xor_zero` |
| 383 | 🔵 theorem | `min_distance_pyth` |
| 387 | 🔵 theorem | `code_rate_identity` |
| 391 | 🔵 theorem | `singleton_instance` |
| 401 | 🔵 theorem | `ST_cubed` |
| 406 | 🔵 theorem | `trace_ST_squared` |
| 411 | 🔵 theorem | `braid_relation_check` |
| 423 | 🔵 theorem | `light_cone_345` |
| 426 | 🔵 theorem | `minkowski_inner_ppt` |
| 431 | 🔵 theorem | `boost_hyperbolic` |
| 435 | 🔵 theorem | `lorentz_invariance_345` |
| 448 | 🟡 def | `frobenius_sq` |
| 452 | 🔵 theorem | `frobenius_B1` |
| 456 | 🔵 theorem | `frobenius_B2` |
| 460 | 🔵 theorem | `frobenius_equal` |
| 466 | 🔵 theorem | `trace_frobenius_B1` |
| 478 | 🔵 theorem | `B1_K1_class` |
| 482 | 🔵 theorem | `B2_K1_class` |
| 486 | 🔵 theorem | `B1B3_K1_class` |
| 513 | 🔵 theorem | `six_is_congruent` |
| 518 | 🔵 theorem | `E6_rational_point` |
| 523 | 🔵 theorem | `five_congruent` |
| 528 | 🔵 theorem | `sum_two_sq_primes` |
| 536 | 🔵 theorem | `three_not_sum_two_sq` |
| 540 | 🔵 theorem | `pyth_check_poly_time` |
| 546 | 🔵 theorem | `discrete_yang_mills` |
| 555 | 🔵 theorem | `incompressible_unit_speed` |
| 567 | 🔵 theorem | `berggren_bsd_bridge` |
| 575 | 🔵 theorem | `spectral_combinatorial` |
| 586 | 🔵 theorem | `berggren_nonabelian` |
| 602 | 🔵 theorem | `master_unification` |

### 📄 MoonshotResearch.lean

| Line | Kind | Name |
|------|------|------|
| 23 | 🟡 def | `harmonicQ'` |
| 25 | 🔵 theorem | `harmonicQ'_zero` |
| 26 | 🔵 theorem | `harmonicQ'_one` |
| 28 | 🔵 theorem | `harmonicQ'_pos` |
| 35 | 🔵 theorem | `euler_zeta2_partial` |
| 38 | 🔵 theorem | `pi_bound` |
| 45 | 🔵 theorem | `pi_100` |
| 48 | 🔵 theorem | `pi_1000` |
| 51 | 🔵 theorem | `avg_gap_100` |
| 54 | 🔵 theorem | `mertens_small` |
| 59 | 🟡 def | `parityB` |
| 62 | 🔵 theorem | `parity_false` |
| 65 | 🔵 theorem | `bool_fn_count` |
| 69 | 🔵 theorem | `shannon_count` |
| 74 | 🔵 theorem | `demorgan_and` |
| 75 | 🔵 theorem | `demorgan_or` |
| 78 | 🔵 theorem | `not_via_nand` |
| 83 | 🟡 def | `isCongrWitness` |
| 87 | 🔵 theorem | `congr_6` |
| 91 | 🔵 theorem | `congr_5` |
| 95 | 🔵 theorem | `congr_7` |
| 99 | 🔵 theorem | `mordell_pt` |
| 102 | 🔵 theorem | `E5_pt` |
| 105 | 🔵 theorem | `E6_pt` |
| 108 | 🔵 theorem | `disc_En` |
| 111 | 🔵 theorem | `En_tors` |
| 116 | 🔵 theorem | `nagell_lutz_d` |
| 121 | 🔵 theorem | `kinetic_nonneg` |
| 125 | 🔵 theorem | `enstrophy_nn` |
| 131 | 🔵 theorem | `ns_scale` |
| 134 | 🔵 theorem | `serrin_46` |
| 135 | 🔵 theorem | `serrin_84` |
| 138 | 🔵 theorem | `sobolev_3d` |
| 141 | 🔵 theorem | `dissipation_nn` |
| 145 | 🔵 theorem | `ladyzhenskaya_pos` |
| 150 | 🔵 theorem | `adj_su` |
| 153 | 🔵 theorem | `adj_su2` |
| 154 | 🔵 theorem | `adj_su3` |
| 157 | 🟡 def | `casimirVal` |
| 159 | 🔵 theorem | `casimir_1_2` |
| 160 | 🔵 theorem | `casimir_1` |
| 161 | 🔵 theorem | `casimir_3_2` |
| 164 | 🔵 theorem | `sm_dim` |
| 167 | 🔵 theorem | `anomaly_c` |
| 170 | 🔵 theorem | `dynkin_su3` |
| 171 | 🔵 theorem | `dynkin_su2` |
| 176 | 🟡 def | `bettiP` |
| 178 | 🔵 theorem | `betti_p1` |
| 179 | 🔵 theorem | `betti_p2` |
| 182 | 🟡 def | `hK3` |
| 190 | 🔵 theorem | `k3_chi` |
| 193 | 🔵 theorem | `noether_k3` |
| 196 | 🟡 def | `gDeg` |
| 197 | 🔵 theorem | `gDeg_3` |
| 198 | 🔵 theorem | `gDeg_4` |
| 199 | 🔵 theorem | `gDeg_6` |
| 202 | 🔵 theorem | `hodge_sym_k3` |
| 205 | 🔵 theorem | `quintic_chi` |
| 210 | 🔵 theorem | `spectral_gap` |
| 213 | 🔵 theorem | `fib_prime_bd` |
| 220 | 🟡 def | `goldbachOK` |
| 223 | 🔵 theorem | `goldbach_verified` |
| 227 | 🟡 def | `fourSqOK` |
| 231 | 🔵 theorem | `lagrange_verified` |
| 234 | 🟡 def | `bertrandOK` |
| 237 | 🔵 theorem | `bertrand_verified` |
| 240 | 🔵 theorem | `irrat_identity` |
| 244 | 🟡 def | `collatzS` |
| 246 | 🟡 def | `collatzR1` |
| 251 | 🔵 theorem | `collatz_27` |
| 256 | 🟡 def | `B₁r` |
| 257 | 🟡 def | `B₂r` |
| 258 | 🟡 def | `B₃r` |
| 260 | 🔵 theorem | `B1_det` |
| 261 | 🔵 theorem | `B2_det` |
| 262 | 🔵 theorem | `B3_det` |
| 265 | 🟡 def | `lorentzQ` |
| 268 | 🔵 theorem | `null_345` |
| 271 | 🔵 theorem | `ppt_count_d` |
| 276 | 🟡 def | `twinPrimeN` |
| 279 | 🔵 theorem | `twin_100` |
| 282 | 🟡 def | `sigD` |
| 284 | 🔵 theorem | `sig_6` |
| 285 | 🔵 theorem | `sig_28` |
| 288 | 🔵 theorem | `perf_6` |
| 289 | 🔵 theorem | `perf_28` |
| 290 | 🔵 theorem | `perf_496` |
| 293 | 🔵 theorem | `abundancy_perf` |
| 299 | 🟡 def | `catN` |
| 301 | 🔵 theorem | `cat_0` |
| 302 | 🔵 theorem | `cat_1` |
| 303 | 🔵 theorem | `cat_2` |
| 304 | 🔵 theorem | `cat_3` |
| 305 | 🔵 theorem | `cat_4` |
| 306 | 🔵 theorem | `cat_5` |
| 309 | 🟡 def | `stirl` |
| 315 | 🔵 theorem | `stirl_32` |
| 316 | 🔵 theorem | `stirl_42` |
| 319 | 🟡 def | `bellN` |
| 321 | 🔵 theorem | `bell0` |
| 322 | 🔵 theorem | `bell1` |
| 323 | 🔵 theorem | `bell2` |
| 324 | 🔵 theorem | `bell3` |
| 329 | 🔵 theorem | `kraft_ex` |
| 332 | 🔵 theorem | `source_binary` |

### 📄 NewDirections.lean

| Line | Kind | Name |
|------|------|------|
| 13 | 🟡 def | `fib_local` |
| 25 | 🔵 theorem | `cassini_identity` |
| 35 | 🟡 def | `IsSumTwoSq` |
| 38 | 🔵 theorem | `brahmagupta_fibonacci_id` |
| 42 | 🔵 theorem | `sum_two_sq_mul` |
| 55 | 🔵 theorem | `three_not_sum_two_sq` |
| 60 | 🔵 theorem | `euler_four_square` |
| 69 | 🔵 theorem | `wilson_5'` |
| 70 | 🔵 theorem | `wilson_7'` |
| 71 | 🔵 theorem | `wilson_11'` |
| 74 | 🔵 theorem | `qr_mod5'` |
| 77 | 🔵 theorem | `qr_mod7'` |
| 82 | 🔵 theorem | `sum_cubes_eq_sq_sum` |
| 89 | 🔵 theorem | `sum_odd_eq_sq` |
| 96 | 🔵 theorem | `sum_first_n` |
| 105 | 🔵 theorem | `trace_cyclic_2x2` |
| 117 | 🔵 theorem | `cayley_hamilton_2x2` |
| 130 | 🟡 def | `cf_step_mat` |
| 133 | 🔵 theorem | `det_cf_step_mat` |
| 137 | 🔵 theorem | `det_two_cf_steps'` |
| 142 | 🔵 theorem | `cf_two_terms` |
| 150 | 🔵 theorem | `regular_graph_handshake` |
| 159 | 🔵 theorem | `four_regular_edges'` |
| 164 | 🔵 theorem | `totient_prime_val` |
| 168 | 🔵 theorem | `fermat_little_3` |
| 169 | 🔵 theorem | `fermat_little_5` |
| 170 | 🔵 theorem | `fermat_little_7` |
| 175 | 🟡 def | `norm_sqrt2` |
| 178 | 🔵 theorem | `norm_sqrt2_mul` |
| 184 | 🔵 theorem | `pell_sqrt2_fundamental` |
| 187 | 🔵 theorem | `pell_sqrt2_second` |

### 📄 NewExplorations.lean

| Line | Kind | Name |
|------|------|------|
| 15 | 🔵 theorem | `mediant_between` |
| 20 | 🔵 theorem | `stern_brocot_det'` |
| 24 | 🔵 theorem | `cf_bezout` |
| 30 | 🔵 theorem | `quad_residues_mod5` |
| 34 | 🔵 theorem | `quad_residues_mod7` |
| 38 | 🔵 theorem | `sum_two_sq_5'` |
| 39 | 🔵 theorem | `sum_two_sq_13'` |
| 40 | 🔵 theorem | `sum_two_sq_17'` |
| 41 | 🔵 theorem | `sum_two_sq_29'` |
| 42 | 🔵 theorem | `sum_two_sq_37'` |
| 43 | 🔵 theorem | `sum_two_sq_41'` |
| 46 | 🔵 theorem | `wilson_7'` |
| 47 | 🔵 theorem | `wilson_11'` |
| 48 | 🔵 theorem | `wilson_13'` |
| 53 | 🔵 theorem | `bertrand_postulate_ex'` |
| 58 | 🔵 theorem | `pi_10'` |
| 61 | 🔵 theorem | `pi_100'` |
| 64 | 🔵 theorem | `infinite_primes'` |
| 69 | 🔵 theorem | `prime_reciprocal_lower'` |
| 75 | 🔵 theorem | `brahmagupta_fibonacci'` |
| 80 | 🟡 def | `eisensteinNorm'` |
| 83 | 🔵 theorem | `eisenstein_norm_nonneg'` |
| 87 | 🔵 theorem | `eisenstein_norm_mul'` |
| 95 | 🔵 theorem | `bij_comp'` |
| 108 | 🔵 theorem | `finite_recurrence'` |
| 121 | 🔵 theorem | `involution_period2'` |
| 127 | 🔵 theorem | `ap_hits_mod'` |
| 135 | 🔵 theorem | `submodular_ineq'` |
| 141 | 🔵 theorem | `trop_distrib'` |
| 145 | 🔵 theorem | `trop_pythagorean'` |
| 151 | 🔵 theorem | `cayley_hamilton_disc'` |
| 155 | 🔵 theorem | `berggren_B1_trace'` |
| 160 | 🔵 theorem | `symplectic_antisymm'` |
| 164 | 🔵 theorem | `area_preserving'` |
| 175 | 🔵 theorem | `Z_is_PID''` |
| 178 | 🔵 theorem | `det_neg_one_exists'` |
| 185 | 🔵 theorem | `kraft_example'` |
| 188 | 🔵 theorem | `data_processing''` |
| 194 | 🔵 theorem | `pythagorean_cone'` |
| 200 | 🔵 theorem | `time_hierarchy'` |
| 203 | 🔵 theorem | `space_hierarchy'` |
| 206 | 🔵 theorem | `factorial_lower_5'` |
| 207 | 🔵 theorem | `factorial_lower_10'` |
| 212 | 🔵 theorem | `braid_relation'` |
| 219 | 🔵 theorem | `schur_2'` |
| 227 | 🔵 theorem | `detection_monotone'` |
| 234 | 🔵 theorem | `four_square_identity'` |
| 242 | 🔵 theorem | `four_squares_7'` |
| 244 | 🔵 theorem | `four_squares_15'` |
| 246 | 🔵 theorem | `four_squares_23'` |
| 252 | 🔵 theorem | `frobenius_submult'` |
| 261 | 🔵 theorem | `symmetric_real_eigenvalues'` |
| 265 | 🔵 theorem | `neumann_series_partial'` |

### 📄 NewTheorems.lean

| Line | Kind | Name |
|------|------|------|
| 46 | 🔵 theorem | `ppt_sum_of_sides` |
| 51 | 🔵 theorem | `ppt_c_gt_a` |
| 55 | 🔵 theorem | `ppt_c_gt_b` |
| 66 | 🔵 theorem | `pyth_product_even` |
| 73 | 🔵 theorem | `sum_of_legs_sq` |
| 77 | 🔵 theorem | `diff_of_legs_sq` |
| 82 | 🔵 theorem | `pythagorean_incircle` |
| 87 | 🔵 theorem | `infinite_pythagorean_triples` |
| 100 | 🔵 theorem | `pyth_mod8_structure` |
| 112 | 🔵 theorem | `pyth_mod3_divides` |
| 124 | 🔵 theorem | `pyth_mod5_divides` |
| 131 | 🔵 theorem | `pell_from_pyth` |
| 136 | 🔵 theorem | `pell_composition` |
| 143 | 🔵 theorem | `gaussian_norm_nonneg` |
| 146 | 🔵 theorem | `gaussian_norm_eq_zero` |
| 163 | 🔵 theorem | `ppt_hypotenuse_lower_bound` |
| 169 | 🔵 theorem | `vieta_pythagorean` |
| 182 | 🔵 theorem | `berggren_tree_total` |
| 191 | 🔵 theorem | `consecutive_leg_hyp` |

### 📄 ResearchFindings.lean

| Line | Kind | Name |
|------|------|------|
| 28 | 🔵 theorem | `trace_sum_eq_11` |
| 31 | 🔵 theorem | `trace_B₁_B₂` |
| 32 | 🔵 theorem | `trace_B₁_B₃` |
| 33 | 🔵 theorem | `trace_B₂_B₃` |
| 35 | 🔵 theorem | `trace_B₁_sq` |
| 36 | 🔵 theorem | `trace_B₂_sq` |
| 37 | 🔵 theorem | `trace_B₃_sq` |
| 40 | 🔵 theorem | `trace_sq_sum` |
| 44 | 🔵 theorem | `forty_one_sum_sq` |
| 47 | 🔵 theorem | `trace_holonomy` |
| 50 | 🔵 theorem | `factor_65` |
| 53 | 🔵 theorem | `trace_cube_sum` |
| 57 | 🔵 theorem | `trace_fourth_sum` |
| 62 | 🔵 theorem | `trace_B1_eq_B3_powers` |
| 70 | 🔵 theorem | `congruent_from_345` |
| 71 | 🔵 theorem | `congruent_from_5_12_13` |
| 72 | 🔵 theorem | `congruent_from_8_15_17` |
| 73 | 🔵 theorem | `congruent_from_7_24_25` |
| 76 | 🔵 theorem | `E6_point` |
| 77 | 🔵 theorem | `E5_point` |
| 80 | 🔵 theorem | `distinct_congruent_numbers` |
| 86 | 🔵 theorem | `area_growth` |
| 91 | 🔵 theorem | `primes_1mod4_count` |
| 95 | 🔵 theorem | `primes_3mod4_count` |
| 100 | 🔵 theorem | `chebyshev_bias` |
| 102 | 🔵 theorem | `sum_two_sq_count_25` |
| 116 | 🔵 theorem | `six_divides_abc` |
| 126 | 🔵 theorem | `unique_ppt_5` |
| 135 | 🔵 theorem | `berggren_nonabelian_12` |
| 136 | 🔵 theorem | `berggren_nonabelian_13` |
| 137 | 🔵 theorem | `berggren_nonabelian_23` |
| 140 | 🔵 theorem | `field_strength_12` |
| 145 | 🔵 theorem | `field_strength_traceless` |
| 149 | 🔵 theorem | `B1_unipotent` |
| 152 | 🔵 theorem | `B3_unipotent` |
| 155 | 🔵 theorem | `B2_not_unipotent` |
| 158 | 🔵 theorem | `B1_mod2` |
| 163 | 🔵 theorem | `experiment_verdicts` |

### 📄 RosettaStone.lean

| Line | Kind | Name |
|------|------|------|
| 17 | 🟠 noncomputable def | `cayley_real_part` |
| 18 | 🟠 noncomputable def | `cayley_imag_part` |
| 21 | 🔵 theorem | `cayley_on_circle` |
| 31 | 🔵 theorem | `rotation_preserves_circle` |
| 38 | 🔵 theorem | `rotation_inverse` |
| 44 | 🔵 theorem | `fermat_christmas_5` |
| 45 | 🔵 theorem | `fermat_christmas_13` |
| 46 | 🔵 theorem | `fermat_christmas_17` |
| 47 | 🔵 theorem | `fermat_christmas_29` |
| 48 | 🔵 theorem | `fermat_christmas_37` |
| 49 | 🔵 theorem | `fermat_christmas_41` |
| 54 | 🔵 theorem | `vieta_jump` |
| 60 | 🔵 theorem | `pell_product` |
| 69 | 🟠 noncomputable def | `cross_ratio` |
| 79 | 🔵 theorem | `cross_ratio_moebius_invariant` |
| 98 | 🔵 theorem | `stereo_double_angle` |
| 108 | 🔵 theorem | `golden_ratio_property` |
| 111 | 🔵 theorem | `golden_ratio_fibonacci_connection` |
| 117 | 🔵 theorem | `hopf_on_sphere` |
| 126 | 🔵 theorem | `algebraic_sum_of_squares` |
| 133 | 🔵 theorem | `lorentz_form_pyth` |
| 137 | 🔵 theorem | `lorentz_boost_composition` |
| 145 | 🔵 theorem | `decoder_count_multiplicative` |
| 151 | 🔵 theorem | `leibniz_partial_4` |
| 154 | 🔵 theorem | `leibniz_partial_6` |
| 163 | 🔵 theorem | `ford_circle_tangency` |

### 📄 Session2Theorems.lean

| Line | Kind | Name |
|------|------|------|
| 40 | 🔵 theorem | `sigma1_star_pow2` |
| 53 | 🔵 theorem | `r4_pow2` |
| 68 | 🔵 theorem | `chi4_sum_pow2` |
| 84 | 🔵 theorem | `sum_cubes_factor` |
| 95 | 🔵 theorem | `diff_cubes_factor` |
| 107 | 🔵 theorem | `eisenstein_norm_nonneg` |
| 118 | 🔵 theorem | `eisenstein_norm_nonneg'` |
| 130 | 🔵 theorem | `channel_ratio_eisenstein` |
| 148 | 🔵 theorem | `geometric_sum_identity` |
| 159 | 🔵 theorem | `geom_sum_formula` |
| 175 | 🔵 theorem | `eisenstein_lower_bound` |
| 187 | 🔵 theorem | `channel4_dominates_channel3` |
| 199 | 🔵 theorem | `channel_ratio_monotone` |
| 218 | 🔵 theorem | `euler_four_square_identity` |
| 233 | 🔵 theorem | `sum_four_sq_mul` |
| 253 | 🔵 theorem | `two_sq_closure` |
| 269 | 🔵 theorem | `r4_div_8` |
| 280 | 🔵 theorem | `r8_div_16` |
| 291 | 🔵 theorem | `r2_div_4` |
| 310 | 🔵 theorem | `chi4_sum_prime_1mod4` |
| 323 | 🔵 theorem | `chi4_sum_prime_3mod4` |
| 335 | 🔵 theorem | `constant_gap_8` |

### 📄 TeamResearch.lean

| Line | Kind | Name |
|------|------|------|
| 50 | 🔵 theorem | `brahmagupta_fibonacci` |
| 55 | 🔵 theorem | `brahmagupta_fibonacci'` |
| 61 | 🔵 theorem | `sum_two_sq_mul_sum_two_sq` |
| 68 | 🔵 theorem | `gaussian_norm_multiplicative` |
| 79 | 🔵 theorem | `pyth_diff_sq` |
| 85 | 🔵 theorem | `pyth_hyp_product` |
| 101 | 🔵 theorem | `stereo_at_zero` |
| 106 | 🔵 theorem | `stereo_at_one` |
| 111 | 🔵 theorem | `stereo_at_neg_one` |
| 117 | 🔵 theorem | `stereo_y_even` |
| 121 | 🔵 theorem | `stereo_x_odd` |
| 126 | 🔵 theorem | `stereo_conformal_factor_pos` |
| 136 | 🔵 theorem | `mobius_compose_det` |
| 142 | 🔵 theorem | `sl2_det_mul` |
| 158 | 🔵 theorem | `pauli_x_squared` |
| 163 | 🔵 theorem | `pauli_z_squared` |
| 169 | 🔵 theorem | `pauli_xz_anticommute` |
| 177 | 🔵 theorem | `pauli_x_trace` |
| 182 | 🔵 theorem | `pauli_z_trace` |
| 194 | 🔵 theorem | `bloch_density_trace_one` |
| 199 | 🔵 theorem | `bloch_purity` |
| 215 | 🔵 theorem | `crystal_period_one` |
| 224 | 🔵 theorem | `crystal_reflection_symmetry` |
| 237 | 🔵 theorem | `crystal_max_value` |
| 244 | 🔵 theorem | `crystal_gradient_zero_at_int` |
| 252 | 🔵 theorem | `stereo_energy_zero_at_origin` |
| 268 | 🔵 theorem | `euler_four_squares_team` |
| 277 | 🔵 theorem | `sum_four_sq_mul` |
| 289 | 🔵 theorem | `degen_eight_squares` |
| 309 | 🔵 theorem | `hurwitz_dim1` |
| 313 | 🔵 theorem | `hurwitz_dim2` |
| 325 | 🔵 theorem | `hopf_preserves_sphere` |
| 335 | 🔵 theorem | `hopf_fiber_south_pole` |
| 347 | 🔵 theorem | `conformal_factor_1d` |
| 351 | 🔵 theorem | `conformal_factor_2d` |
| 356 | 🔵 theorem | `conformal_chain` |

### 📄 UniversalDecoder.lean

| Line | Kind | Name |
|------|------|------|
| 42 | 🔵 theorem | `rational_density_quantitative` |
| 67 | 🟡 def | `SimpleCF` |
| 70 | 🟡 def | `evalCF` |
| 82 | 🔵 theorem | `rat_has_cf` |
| 117 | 🔴 structure | `SL2Z where` |
| 125 | 🟡 def | `SL2Z.one` |
| 128 | 🟡 def | `SL2Z.S` |
| 131 | 🟡 def | `SL2Z.T` |
| 134 | 🟡 def | `SL2Z.mul` |
| 148 | 🔵 theorem | `SL2Z_S_sq` |
| 159 | 🔵 theorem | `SL2Z_ST_order` |
| 177 | 🟠 noncomputable def | `moebius` |
| 192 | 🔵 theorem | `moebius_sum_eq_indicator` |
| 223 | 🔵 theorem | `euler_product_finite_sq` |
| 241 | 🟡 def | `triangleArea` |
| 252 | 🔵 theorem | `stereo_triangle_area` |

---

## NumberTheory

### 📄 AlgebraicNumberTheory.lean

| Line | Kind | Name |
|------|------|------|
| 7 | 🔵 theorem | `bf_identity1` |
| 11 | 🔵 theorem | `bf_identity2` |
| 16 | 🔵 theorem | `qr_neg1_5` |
| 17 | 🔵 theorem | `qr_neg1_3` |
| 19 | 🔵 theorem | `qr_2_7` |
| 20 | 🔵 theorem | `qr_2_5` |
| 24 | 🔵 theorem | `pell1` |
| 25 | 🔵 theorem | `pell_r` |
| 27 | 🔵 theorem | `neg_pell1` |
| 30 | 🔵 theorem | `roth_b` |

### 📄 DiophantineApproximation.lean

| Line | Kind | Name |
|------|------|------|
| 7 | 🔵 theorem | `pell_c0` |
| 8 | 🔵 theorem | `pell_c1` |
| 9 | 🔵 theorem | `pell_c2` |
| 10 | 🔵 theorem | `pell_c3` |
| 11 | 🔵 theorem | `pell_c4` |
| 14 | 🔵 theorem | `cassini_ex` |
| 19 | 🔵 theorem | `liouville_ex` |
| 24 | 🔵 theorem | `z_r_close` |

### 📄 Moonshine.lean

| Line | Kind | Name |
|------|------|------|
| 24 | 🟡 def | `berggren_M1` |
| 28 | 🟡 def | `berggren_M3` |
| 32 | 🟡 def | `GammaTheta` |
| 37 | 🔵 theorem | `berggren_eq_theta` |
| 66 | 🔵 theorem | `SL2_F3_card` |
| 71 | 🔵 theorem | `SL2_F5_card` |
| 76 | 🔵 theorem | `SL2_F7_card` |
| 81 | 🔵 theorem | `SL2_order_formula` |
| 88 | 🔵 theorem | `SL2_F11_card` |
| 93 | 🔵 theorem | `PSL2_divides_M11` |
| 96 | 🔵 theorem | `M11_order` |
| 102 | 🔵 theorem | `dedekind_expansion` |
| 112 | 🟠 noncomputable def | `j_from_lambda` |
| 117 | 🔵 theorem | `j_at_half` |
| 121 | 🔵 theorem | `j_value_cube` |

### 📄 NumberTheory.lean

| Line | Kind | Name |
|------|------|------|
| 25 | 🔵 theorem | `exists_prime_factor` |
| 37 | 🔵 theorem | `prime_dvd_mul` |
| 48 | 🔵 theorem | `semiprime_divisor_count` |
| 71 | 🔵 theorem | `fermat_little` |
| 82 | 🔵 theorem | `wilson` |
| 94 | 🔵 theorem | `euler_theorem` |
| 111 | 🔵 theorem | `factor_from_sum_diff` |
| 122 | 🔵 theorem | `infinitely_many_primes` |
| 132 | 🔵 theorem | `prime_gaps_unbounded` |
| 150 | 🔵 theorem | `neg_one_qr_iff` |
| 167 | 🔵 theorem | `two_qr_iff` |

### 📄 NumberTheoryAdvanced.lean

| Line | Kind | Name |
|------|------|------|
| 14 | 🔵 theorem | `legendre_mul'` |
| 25 | 🔵 theorem | `totient_mul_coprime'` |
| 33 | 🔵 theorem | `totient_prime'` |
| 37 | 🔵 theorem | `sum_divisors_6` |
| 38 | 🔵 theorem | `sum_divisors_28` |
| 39 | 🔵 theorem | `six_is_perfect` |
| 40 | 🔵 theorem | `twentyeight_is_perfect` |
| 44 | 🔵 theorem | `pell_convergent_3_2'` |
| 45 | 🔵 theorem | `pell_convergent_7_5'` |
| 46 | 🔵 theorem | `pell_convergent_17_12'` |
| 47 | 🔵 theorem | `pell_convergent_41_29'` |
| 55 | 🔵 theorem | `exists_prime_factor` |
| 64 | 🔵 theorem | `goldbach_small` |
| 83 | 🔵 theorem | `fermat_little_general'` |
| 87 | 🔵 theorem | `crt_cardinality_check'` |
| 93 | 🔵 theorem | `six_congruent` |
| 96 | 🔵 theorem | `five_congruent` |

### 📄 NumberTheoryDeep.lean

| Line | Kind | Name |
|------|------|------|
| 22 | 🔵 theorem | `neg_one_qr_mod5` |
| 28 | 🔵 theorem | `neg_one_not_qr_mod3` |
| 34 | 🔵 theorem | `neg_one_qr_mod13` |
| 40 | 🔵 theorem | `neg_one_not_qr_mod7` |
| 46 | 🔵 theorem | `two_qr_mod7` |
| 52 | 🔵 theorem | `two_not_qr_mod5` |
| 62 | 🔵 theorem | `totient_mul_of_coprime` |
| 69 | 🔵 theorem | `totient_prime_eq` |
| 76 | 🔵 theorem | `totient_prime_sq'` |
| 83 | 🔵 theorem | `sum_totient_divisors` |
| 92 | 🔵 theorem | `crt_example_5` |
| 95 | 🔵 theorem | `crt_example_23` |
| 104 | 🔵 theorem | `padic_val_prime` |
| 111 | 🔵 theorem | `padic_val_pow` |
| 118 | 🔵 theorem | `padic_val_mul_eq` |
| 129 | 🔵 theorem | `primes_infinite` |
| 135 | 🔵 theorem | `bertrand` |
| 142 | 🔵 theorem | `prime_mod6` |
| 154 | 🔵 theorem | `consecutive_prod_even` |
| 160 | 🔵 theorem | `three_consec_div6` |
| 166 | 🔵 theorem | `cube_minus_self_div6` |
| 172 | 🔵 theorem | `fifth_pow_minus` |

---

## PhotonNetworks

### 📄 EntanglementDifficulty.lean

| Line | Kind | Name |
|------|------|------|
| 33 | 🔴 structure | `ProofSearch` |
| 40 | 🟠 noncomputable def | `searchSpaceSize` |
| 44 | 🟠 noncomputable def | `logDifficulty` |
| 52 | 🟠 noncomputable def | `edgeDensity` |
| 62 | 🔵 theorem | `zero_edges_zero_density` |
| 73 | 🔵 theorem | `density_le_one` |
| 88 | 🟡 def | `numComponents` |
| 95 | 🔵 theorem | `independent_search_additive` |
| 108 | 🔵 theorem | `entangled_harder_than_independent` |
| 121 | 🟡 def | `maxCliqueBound` |
| 125 | 🔵 theorem | `tree_entanglement_bound` |
| 135 | 🟡 def | `chainDependency` |
| 145 | 🔵 theorem | `chain_edge_count` |
| 160 | 🟡 def | `completeDependency` |
| 170 | 🔵 theorem | `complete_edge_count` |
| 195 | 🔵 theorem | `decomposition_speedup` |

### 📄 EntanglementNetwork.lean

| Line | Kind | Name |
|------|------|------|
| 32 | 🔴 structure | `EntanglementMatching` |
| 47 | 🔵 theorem | `entanglement_requires_even` |
| 76 | 🔵 theorem | `partner_bijective` |
| 83 | 🔴 structure | `MeasurementSetup` |
| 88 | 🟡 def | `MeasurementOutcome` |
| 92 | 🔴 structure | `LocalModel` |
| 107 | 🟠 noncomputable def | `localCorrelation` |
| 116 | 🟠 noncomputable def | `chshQuantity` |
| 129 | 🔵 theorem | `bell_chsh_bound` |
| 144 | 🔴 structure | `EntanglementGraph` |
| 152 | 🟡 def | `isKColorable` |
| 164 | 🔴 structure | `GaussInt where` |
| 170 | 🟡 def | `GaussInt.norm` |
| 174 | 🟡 def | `GaussInt.conj` |
| 179 | 🔵 theorem | `GaussInt.mul_conj_eq_norm` |
| 185 | 🔵 theorem | `GaussInt.conj_involution` |
| 189 | 🔵 theorem | `GaussInt.conj_norm` |
| 194 | 🔴 structure | `GaussianEntangledPair where` |
| 201 | 🔵 theorem | `GaussianEntangledPair.equal_energy` |
| 213 | 🟡 def | `encodeGI` |
| 228 | 🟡 def | `zigzagDecode` |
| 232 | 🟡 def | `cantorUnpair` |
| 237 | 🟠 noncomputable def | `entangledPartnerCode` |

### 📄 GapMatterResearch.lean

| Line | Kind | Name |
|------|------|------|
| 86 | 🔵 theorem | `photon_addresses_measure_zero` |
| 97 | 🔵 theorem | `gaps_have_full_measure` |
| 103 | 🔵 theorem | `gap_contains_no_photon` |
| 118 | 🔵 theorem | `gap_is_uncountable` |
| 134 | 🟡 def | `stokesMinkowskiForm` |
| 138 | 🟡 def | `isNull` |
| 142 | 🟡 def | `isTimelike` |
| 158 | 🔵 theorem | `mixing_creates_mass` |
| 179 | 🔵 theorem | `null_sphere_has_measure_zero` |
| 195 | 🔵 theorem | `timelike_ball_positive_measure` |
| 225 | 🔵 theorem | `gap_interpolation_massive` |
| 250 | 🔵 theorem | `midpoint_maximum_mass` |
| 271 | 🔵 theorem | `parabolic_mass_profile` |
| 292 | 🔵 theorem | `experiment_H_null` |
| 296 | 🔵 theorem | `experiment_V_null` |
| 300 | 🔵 theorem | `experiment_HV_mix_timelike` |
| 304 | 🔵 theorem | `experiment_HV_mass` |
| 308 | 🔵 theorem | `experiment_interpolation_quarter` |
| 314 | 🔵 theorem | `experiment_HV_parabola` |
| 319 | 🔵 theorem | `experiment_HV_max` |
| 332 | 🟡 def | `degreeOfPolarization` |
| 337 | 🔵 theorem | `mass_from_depolarization` |
| 347 | 🔵 theorem | `fully_polarized_zero_mass` |
| 353 | 🔵 theorem | `unpolarized_max_mass` |
| 369 | 🔵 theorem | `two_photon_mass_formula` |
| 380 | 🔵 theorem | `orthogonal_photons_max_mass` |
| 389 | 🔵 theorem | `parallel_photons_zero_mass` |
| 417 | 🔵 theorem | `massive_dispersion_relation` |
| 423 | 🔵 theorem | `stokes_mass_nonneg` |
| 429 | 🔵 theorem | `mass_zero_iff_fully_polarized` |
| 449 | 🔵 theorem | `gaps_uncountable` |
| 455 | 🔵 theorem | `addresses_countable` |
| 494 | 🔵 theorem | `entropy_mass_connection` |
| 500 | 🔵 theorem | `decoherence_trajectory` |
| 505 | 🔵 theorem | `max_decoherence_at_midpoint` |
| 511 | 🔵 theorem | `decoherence_zero_at_endpoints` |

### 📄 PhotonChannels.lean

| Line | Kind | Name |
|------|------|------|
| 41 | 🔵 theorem | `PhotonChannel.card` |
| 61 | 🟡 def | `hilbertDimType` |
| 77 | 🔵 theorem | `polarization_unique_finite` |
| 96 | 🔵 theorem | `ConjugatePair.card` |
| 100 | 🟡 def | `ConjugatePair.primaryChannel` |
| 107 | 🟡 def | `ConjugatePair.secondaryChannel` |
| 119 | 🟠 noncomputable def | `channelInfoCapacity` |
| 129 | 🟠 noncomputable def | `totalInfoCapacity` |
| 139 | 🔵 theorem | `totalInfoCapacity_eq` |
| 144 | 🟡 def | `hasClassicalAnalogue` |
| 162 | 🔵 theorem | `photonNumber_unique_nonclassical` |
| 167 | 🟡 def | `isBounded` |
| 180 | 🔵 theorem | `polarization_unique_bounded` |
| 198 | 🟡 def | `symmetryOrigin` |
| 214 | 🟠 noncomputable def | `uncertaintyBound` |
| 229 | 🔵 theorem | `uncertaintyBound_pos` |
| 240 | 🟡 def | `practicalDim` |
| 258 | 🔵 theorem | `practicalDim_pos` |
| 262 | 🟡 def | `hyperEntanglementDim` |
| 272 | 🔵 theorem | `hyperEntanglementDim_pos` |
| 290 | 🔵 theorem | `massless_polarization_states` |
| 305 | 🟠 noncomputable def | `zeroPointEnergy` |
| 314 | 🔵 theorem | `zeroPointEnergy_pos` |
| 324 | 🔵 theorem | `zeroPointEnergy_mono` |
| 335 | 🟠 noncomputable def | `shannonCapacity` |
| 344 | 🔵 theorem | `shannonCapacity_nonneg` |
| 354 | 🔵 theorem | `shannonCapacity_mono` |
| 367 | 🔵 theorem | `shannonCapacity_polarization` |

### 📄 PhotonEventGraph.lean

| Line | Kind | Name |
|------|------|------|
| 31 | 🔴 structure | `SpacetimeEvent where` |
| 38 | 🟡 def | `minkowskiInterval` |
| 42 | 🟡 def | `nullSeparated` |
| 46 | 🟡 def | `causalFuture` |
| 51 | 🔵 theorem | `null_iff_pythagorean` |
| 61 | 🔴 structure | `PhotonEdge where` |
| 68 | 🟡 def | `PhotonEdge.momentum` |
| 72 | 🟡 def | `PhotonEdge.energy` |
| 76 | 🔵 theorem | `PhotonEdge.energy_pos` |
| 82 | 🔵 theorem | `PhotonEdge.on_shell` |
| 92 | 🔴 structure | `PhotonEventGraph where` |
| 102 | 🟡 def | `PhotonEventGraph.photonCount` |
| 105 | 🟡 def | `PhotonEventGraph.eventCount` |
| 108 | 🟡 def | `PhotonEventGraph.isEmitter` |
| 112 | 🟡 def | `PhotonEventGraph.isAbsorber` |
| 128 | 🔵 theorem | `PhotonEventGraph.causallyConnected_trans` |
| 145 | 🔵 theorem | `PhotonEventGraph.time_monotone` |
| 167 | 🔵 theorem | `PhotonEventGraph.no_causal_loop` |
| 188 | 🟠 noncomputable def | `PhotonEventGraph.emissionDegree` |
| 192 | 🟠 noncomputable def | `PhotonEventGraph.absorptionDegree` |
| 202 | 🔵 theorem | `PhotonEventGraph.total_emission_count` |
| 213 | 🔴 structure | `EntangledPair where` |
| 228 | 🔵 theorem | `EntangledPair.equal_energy` |

### 📄 PhotonNetworks.lean

| Line | Kind | Name |
|------|------|------|
| 42 | 🟡 def | `IsSumOfTwoSquares` |
| 47 | 🟡 def | `IsDark` |
| 50 | 🟡 def | `IsPythTriple` |
| 53 | 🟡 def | `gaussianProd` |
| 59 | 🔵 theorem | `brahmagupta_fibonacci` |
| 64 | 🔵 theorem | `sum_two_sq_mul_closed` |
| 74 | 🟡 def | `PhotonStates` |
| 78 | 🔵 theorem | `every_nat_sum_two_sq` |
| 90 | 🔵 theorem | `three_is_dark` |
| 100 | 🔵 theorem | `seven_is_dark` |
| 104 | 🔵 theorem | `five_is_bright` |
| 108 | 🔵 theorem | `thirteen_is_bright` |
| 112 | 🔵 theorem | `n1105_is_bright` |
| 116 | 🔵 theorem | `n1105_four_reps` |
| 125 | 🔵 theorem | `gaussian_product_triple` |
| 132 | 🔵 theorem | `gaussian_prod_comm` |
| 137 | 🔵 theorem | `gaussian_prod_one` |
| 142 | 🔵 theorem | `conjugate_same_norm` |
| 154 | 🟡 def | `gridAdj` |
| 168 | 🔵 theorem | `sum_sq_mod4_obstruction` |
| 189 | 🔵 theorem | `prime_3mod4_dark` |
| 209 | 🔵 theorem | `network_5` |
| 213 | 🔵 theorem | `network_25` |
| 219 | 🔵 theorem | `network_65` |
| 227 | 🔵 theorem | `network_1105_cube` |
| 236 | 🔵 theorem | `gaussian_norm_mul` |
| 242 | 🔵 theorem | `gaussian_prod_assoc` |
| 258 | 🔵 theorem | `pyth_not_both_odd'` |

### 📄 PhotonParity.lean

| Line | Kind | Name |
|------|------|------|
| 24 | 🔵 theorem | `pyth_not_both_odd` |
| 36 | 🔵 theorem | `pyth_hypotenuse_odd` |
| 50 | 🔵 theorem | `pyth_one_leg_even` |
| 64 | 🔵 theorem | `pyth_parametrization` |

### 📄 PhotonResearchRound2.lean

| Line | Kind | Name |
|------|------|------|
| 54 | 🟡 def | `minkQ` |
| 57 | 🟡 def | `IsPythTriple` |
| 60 | 🟡 def | `IsNull` |
| 63 | 🟡 def | `minkInner` |
| 85 | 🔵 theorem | `gaussian_product_triple` |
| 97 | 🔵 theorem | `null_gaussian_product` |
| 117 | 🔵 theorem | `conjugate_photon` |
| 128 | 🔵 theorem | `conjugate_photon'` |
| 139 | 🔵 theorem | `antipodal_photon` |
| 149 | 🟡 def | `gaussProd` |
| 161 | 🔵 theorem | `gaussProd_comm` |
| 172 | 🔵 theorem | `gaussProd_assoc` |
| 183 | 🔵 theorem | `gaussProd_identity` |
| 195 | 🔵 theorem | `identity_is_triple` |
| 212 | 🔵 theorem | `brahmagupta_fibonacci` |
| 224 | 🔵 theorem | `brahmagupta_fibonacci_alt` |
| 242 | 🔵 theorem | `photon_squared` |
| 260 | 🔵 theorem | `null_inner_vanishes_product` |
| 279 | 🔵 theorem | `light_cone_intersection` |
| 300 | 🔵 theorem | `photon_345_squared` |
| 313 | 🔵 theorem | `photon_345_squared_is_triple` |
| 324 | 🔵 theorem | `photon_product_345_51213` |
| 335 | 🔵 theorem | `photon_product_is_triple` |
| 353 | 🔵 theorem | `primitive_triple_odd_hypotenuse` |
| 366 | 🔵 theorem | `identity_preserves_minkQ` |
| 376 | 🔵 theorem | `comp_preserves_minkQ` |
| 399 | 🔵 theorem | `null_basis_vectors` |
| 408 | 🔵 theorem | `null_basis_inner` |
| 419 | 🔵 theorem | `spacelike_basis` |
| 437 | 🔵 theorem | `photon_helicity_bound` |

### 📄 PhotonResearchRound3.lean

| Line | Kind | Name |
|------|------|------|
| 66 | 🔵 theorem | `two_square_identity` |
| 75 | 🔵 theorem | `four_square_identity` |
| 86 | 🔵 theorem | `eight_square_identity` |
| 117 | 🔵 theorem | `sedenion_zero_divisor_witness` |
| 130 | 🟡 def | `IsPythTriple'` |
| 134 | 🟡 def | `gaussianProd` |
| 140 | 🔵 theorem | `photon_monoid_closure` |
| 147 | 🔵 theorem | `gaussianProd_comm` |
| 152 | 🔵 theorem | `gaussianProd_one` |
| 157 | 🔵 theorem | `photon_conjugate` |
| 163 | 🔵 theorem | `photon_annihilation` |
| 168 | 🔵 theorem | `annihilation_is_triple` |
| 189 | 🔵 theorem | `fermat_two_square_photon` |
| 195 | 🔵 theorem | `prime_2_photon` |
| 205 | 🔵 theorem | `dark_prime_no_photon` |
| 216 | 🔵 theorem | `photon_energy_positive` |
| 223 | 🔵 theorem | `photon_energy_scaling` |
| 234 | 🔵 theorem | `direction_invariant_under_scaling` |
| 242 | 🔵 theorem | `direction_composition` |
| 258 | 🔵 theorem | `quaternion_norm_multiplicative` |
| 263 | 🔵 theorem | `quaternion_star_involutive` |
| 267 | 🔵 theorem | `unit_quaternion_product` |
| 296 | 🔵 theorem | `octonion_channel_example` |
| 302 | 🔵 theorem | `octonionic_energy` |
| 311 | 🔴 structure | `PhotonState where` |
| 318 | 🟡 def | `vacuum_photon` |
| 321 | 🟡 def | `photon_345` |
| 324 | 🟡 def | `photon_51213` |
| 328 | 🟡 def | `PhotonState.fuse` |
| 336 | 🔵 theorem | `PhotonState.fuse_comm` |
| 343 | 🟡 def | `PhotonState.conjugate` |
| 350 | 🔵 theorem | `PhotonState.fuse_conjugate_py` |
| 355 | 🔵 theorem | `PhotonState.fuse_conjugate_energy` |
| 367 | 🔵 theorem | `null_sum_null_iff_orthogonal` |
| 385 | 🔵 theorem | `photon_parity_conservation` |
| 392 | 🔵 theorem | `parametrization_works` |
| 402 | 🔵 theorem | `parametrization_legs_distinct` |
| 417 | 🔵 theorem | `triple_345_parametrization` |
| 421 | 🔵 theorem | `triple_51213_parametrization` |
| 425 | 🔵 theorem | `triple_81517_parametrization` |
| 436 | 🔵 theorem | `gaussian_norm_is_sum_sq` |
| 441 | 🔵 theorem | `gaussian_norm_multiplicative` |
| 453 | 🔵 theorem | `quaternion_noncommutative` |
| 468 | 🔵 theorem | `complex_not_ordered_field` |
| 494 | 🔵 theorem | `first_primitive_triples` |
| 501 | 🔵 theorem | `fusion_345_51213` |
| 509 | 🔵 theorem | `self_fusion_345` |
| 517 | 🔵 theorem | `triple_fusion_345` |

### 📄 PhotonResearchRound4.lean

| Line | Kind | Name |
|------|------|------|
| 20 | 🟡 def | `IsPythTriple'` |
| 23 | 🟡 def | `berggrenA` |
| 27 | 🟡 def | `berggrenB` |
| 31 | 🟡 def | `berggrenC` |
| 35 | 🔵 theorem | `berggrenA_preserves_pyth` |
| 41 | 🔵 theorem | `berggrenB_preserves_pyth` |
| 47 | 🔵 theorem | `berggrenC_preserves_pyth` |
| 53 | 🔵 theorem | `base_triple_pyth` |
| 57 | 🔵 theorem | `berggrenA_base` |
| 60 | 🔵 theorem | `berggrenB_base` |
| 63 | 🔵 theorem | `berggrenC_base` |
| 66 | 🔵 theorem | `berggrenA_hypotenuse_grows` |
| 72 | 🔵 theorem | `berggrenB_hypotenuse_grows` |
| 79 | 🔵 theorem | `berggren_preserves_minkowski_form` |
| 90 | 🔵 theorem | `berggrenA_depth2` |
| 93 | 🔵 theorem | `triple_7_24_25` |
| 96 | 🔵 theorem | `berggrenB_of_A` |
| 99 | 🔵 theorem | `triple_55_48_73` |
| 104 | 🟡 def | `gaussianProd'` |
| 108 | 🔵 theorem | `gaussianProd'_preserves_pyth` |
| 117 | 🔵 theorem | `gaussianProd'_assoc` |
| 126 | 🔵 theorem | `gaussianProd'_comm` |
| 131 | 🔵 theorem | `direction_ratio_scaling` |
| 135 | 🔵 theorem | `gaussian_slope_composition` |
| 147 | 🟡 def | `isBrightPrime` |
| 150 | 🟡 def | `isDarkPrime` |
| 153 | 🔵 theorem | `two_is_diagonal` |
| 157 | 🔵 theorem | `five_is_bright` |
| 160 | 🔵 theorem | `three_is_dark` |
| 163 | 🔵 theorem | `bright_primes_small` |
| 168 | 🔵 theorem | `pyth_legs_bounded` |
| 173 | 🔵 theorem | `hypotenuse_ge_legs` |
| 180 | 🔴 structure | `PhotonState' where` |
| 187 | 🟡 def | `PhotonState'.fuse` |
| 197 | 🟡 def | `vacuumPhoton` |
| 200 | 🔵 theorem | `fuse_vacuum_left` |
| 207 | 🔵 theorem | `fuse_vacuum_right` |
| 214 | 🟡 def | `PhotonState'.conjugate` |
| 221 | 🔵 theorem | `fuse_conjugate_py` |
| 226 | 🔵 theorem | `fuse_conjugate_energy` |
| 231 | 🔵 theorem | `fuse_comm` |
| 238 | 🔵 theorem | `fuse_assoc` |
| 247 | 🔵 theorem | `berggren_depth1_valid` |
| 252 | 🟡 def | `photon345` |
| 255 | 🔵 theorem | `self_fuse_345` |
| 262 | 🟡 def | `photon51213` |
| 265 | 🔵 theorem | `fuse_345_51213` |
| 274 | 🔵 theorem | `photon_norm_is_energy_sq` |
| 278 | 🔵 theorem | `conjugate_energy` |
| 282 | 🔵 theorem | `double_conjugate` |
| 291 | 🟡 def | `PhotonState'.isPureReal` |
| 294 | 🔵 theorem | `fuse_conjugate_is_pure_real` |
| 299 | 🔵 theorem | `opposite_photon_fuse` |
| 307 | 🟡 def | `photonQuadrant` |
| 312 | 🔵 theorem | `first_quadrant_345` |
| 316 | 🟡 def | `angularMomentumProxy` |
| 319 | 🔵 theorem | `angular_momentum_345` |
| 323 | 🔵 theorem | `angular_momentum_fuse` |
| 331 | 🟡 def | `PhotonState'.scale` |
| 338 | 🔵 theorem | `scale_preserves_direction` |
| 343 | 🔵 theorem | `scale_one` |
| 348 | 🔵 theorem | `scale_compose` |

### 📄 PhotonResearchRound5.lean

| Line | Kind | Name |
|------|------|------|
| 20 | 🔴 structure | `Oct where` |
| 32 | 🔵 theorem | `Oct.ext'` |
| 38 | 🟡 def | `Oct.normSq` |
| 42 | 🟡 def | `Oct.mul` |
| 53 | 🟡 def | `Oct.one` |
| 54 | 🟡 def | `Oct.e1` |
| 55 | 🟡 def | `Oct.e2` |
| 56 | 🟡 def | `Oct.e3` |
| 57 | 🟡 def | `Oct.e4` |
| 58 | 🟡 def | `Oct.e5` |
| 59 | 🟡 def | `Oct.e6` |
| 60 | 🟡 def | `Oct.e7` |
| 63 | 🔵 theorem | `oct_not_commutative` |
| 67 | 🔵 theorem | `oct_not_associative` |
| 72 | 🔵 theorem | `oct_norm_multiplicative` |
| 77 | 🔵 theorem | `oct_e1_norm` |
| 78 | 🔵 theorem | `oct_e2_norm` |
| 81 | 🔵 theorem | `oct_one_mul` |
| 85 | 🔵 theorem | `oct_mul_one` |
| 89 | 🔵 theorem | `oct_e1_sq` |
| 92 | 🟡 def | `Oct.conj` |
| 96 | 🔵 theorem | `oct_mul_conj_real_part` |
| 101 | 🔵 theorem | `oct_mul_conj_imag_zero` |
| 115 | 🟡 def | `octGate` |
| 119 | 🔵 theorem | `oct_gates_not_composable` |
| 127 | 🔵 theorem | `quat_subalgebra_associative` |
| 134 | 🟡 def | `minkForm` |
| 137 | 🔵 theorem | `null_mink_form` |
| 142 | 🔵 theorem | `null_sum_null_orthogonal` |
| 149 | 🔵 theorem | `leg_swap_preserves` |
| 153 | 🔵 theorem | `neg_leg_preserves` |
| 157 | 🔵 theorem | `sign_change_preserves` |
| 164 | 🔵 theorem | `hurwitz_are_powers_of_two` |
| 174 | 🔵 theorem | `hurwitz_sum` |
| 177 | 🔵 theorem | `hurwitz_product` |
| 180 | 🔵 theorem | `hurwitz_sum_sq` |
| 183 | 🔵 theorem | `hurwitz_divisibility` |
| 189 | 🟡 def | `photonChirality` |
| 195 | 🔵 theorem | `chirality_values` |
| 201 | 🔵 theorem | `chirality_conjugate` |
| 209 | 🔵 theorem | `triple_345_primitive` |
| 212 | 🔵 theorem | `triple_6810_not_primitive` |
| 216 | 🔵 theorem | `fano_e1e2` |
| 217 | 🔵 theorem | `fano_e2e4` |
| 218 | 🔵 theorem | `fano_e1e4` |
| 221 | 🔵 theorem | `fano_e4e1` |
| 224 | 🔵 theorem | `oct_all_sq_minus_one` |
| 237 | 🔵 theorem | `moufang_identity_example` |
| 248 | 🟡 def | `Oct.associator` |
| 259 | 🔵 theorem | `associator_zero_quat` |
| 263 | 🔵 theorem | `associator_nonzero_oct` |
| 267 | 🔵 theorem | `associator_alternating_12` |

### 📄 PhotonicFrontier.lean

| Line | Kind | Name |
|------|------|------|
| 49 | 🟡 def | `Q` |
| 52 | 🟡 def | `eta` |
| 55 | 🟡 def | `IsNull` |
| 58 | 🟡 def | `IsTimelike` |
| 61 | 🟡 def | `IsSpacelike` |
| 64 | 🟡 def | `spatialRotation` |
| 68 | 🟡 def | `boost` |
| 83 | 🟡 def | `OnHyperboloid` |
| 87 | 🔵 theorem | `hyperboloid_origin` |
| 91 | 🔵 theorem | `boost_preserves_Q` |
| 99 | 🔵 theorem | `boost_preserves_hyperboloid_Q` |
| 105 | 🔵 theorem | `boosted_origin_on_hyperboloid` |
| 114 | 🔵 theorem | `hyperboloid_inside_light_cone` |
| 121 | 🔵 theorem | `hyperbolic_distance_base` |
| 127 | 🔵 theorem | `hyperboloid_self_inner` |
| 132 | 🔵 theorem | `hyperboloid_c_ge_one` |
| 148 | 🟡 def | `mobius` |
| 150 | 🔵 theorem | `mobius_composition` |
| 161 | 🔵 theorem | `boost_is_dilation_on_celestial` |
| 166 | 🟡 def | `crossRatio` |
| 169 | 🔵 theorem | `cross_ratio_dilation_invariant` |
| 177 | 🔵 theorem | `mobius_identity` |
| 181 | 🔵 theorem | `mobius_translation` |
| 190 | 🔵 theorem | `rotation_preserves_Q` |
| 199 | 🔵 theorem | `rotation_preserves_null` |
| 205 | 🔵 theorem | `rotation_preserves_energy` |
| 210 | 🔵 theorem | `rotation_preserves_spatial_momentum` |
| 219 | 🔵 theorem | `rotation_full_circle` |
| 224 | 🔵 theorem | `rotation_zero` |
| 229 | 🔵 theorem | `rotation_composition` |
| 236 | 🔵 theorem | `boost_rotation_preserves_Q` |
| 247 | 🔵 theorem | `gaussian_norm_multiplicative` |
| 253 | 🔵 theorem | `photon_gaussian_composition` |
| 260 | 🔵 theorem | `euclid_spatial_momentum` |
| 265 | 🔵 theorem | `five_is_sum_of_squares` |
| 268 | 🔵 theorem | `thirteen_is_sum_of_squares` |
| 271 | 🔵 theorem | `gaussian_product_example` |
| 275 | 🔵 theorem | `composed_photon_is_null` |
| 284 | 🔵 theorem | `dilation_scales_Q` |
| 289 | 🔵 theorem | `dilation_preserves_null` |
| 294 | 🔵 theorem | `dilation_preserves_timelike` |
| 300 | 🔵 theorem | `kelvin_inversion_form` |
| 305 | 🔵 theorem | `translation_Q` |
| 310 | 🔵 theorem | `null_translation_simplified` |
| 325 | 🔵 theorem | `primitive_345` |
| 328 | 🔵 theorem | `energy_dominates_momentum` |
| 333 | 🔵 theorem | `smallest_primitive_energy` |
| 336 | 🔵 theorem | `photon_energy_sum_bound` |
| 354 | 🔵 theorem | `iwasawa_preserves_Q` |
| 361 | 🔵 theorem | `general_lorentz_transform` |
| 368 | 🔵 theorem | `eta_self_eq_Q` |
| 373 | 🔵 theorem | `celestial_angle_null` |
| 377 | 🔵 theorem | `photon_orbit_radius` |
| 382 | 🔵 theorem | `aberration_energy` |
| 387 | 🔵 theorem | `forward_blueshift` |
| 391 | 🔵 theorem | `backward_redshift` |
| 395 | 🔵 theorem | `two_photon_invariant_mass` |
| 400 | 🔵 theorem | `head_on_collision_mass` |
| 405 | 🔵 theorem | `crystallizer_gaussian_photon` |
| 409 | 🔵 theorem | `null_direction_right` |
| 413 | 🔵 theorem | `null_direction_left` |
| 416 | 🔵 theorem | `null_b_zero_classification` |
| 421 | 🔵 theorem | `wigner_rotation_structure` |

---

## Probability

### 📄 Entropy.lean

| Line | Kind | Name |
|------|------|------|
| 20 | 🟠 noncomputable def | `shannonEntropy'` |
| 24 | 🟠 noncomputable def | `jointEntropy` |
| 29 | 🟠 noncomputable def | `conditionalEntropy` |
| 34 | 🟠 noncomputable def | `mutualInformation` |
| 39 | 🟠 noncomputable def | `klDivergence` |
| 45 | 🔵 theorem | `entropy_deterministic` |
| 58 | 🟢 lemma | `logb_div_ge` |
| 70 | 🟢 lemma | `kl_term_bound` |
| 84 | 🔵 theorem | `gibbs_inequality` |
| 110 | 🔵 theorem | `entropy_le_log_card` |
| 146 | 🔵 theorem | `source_coding_lower_bound` |
| 192 | 🔵 theorem | `data_processing_card` |

### 📄 Probability.lean

| Line | Kind | Name |
|------|------|------|
| 25 | 🔵 theorem | `markov_inequality_nat` |
| 42 | 🔵 theorem | `log_monotone_on` |
| 47 | 🟠 noncomputable def | `binaryEntropy` |
| 54 | 🔵 theorem | `binary_entropy_symmetric` |

### 📄 ProbabilityExploration.lean

| Line | Kind | Name |
|------|------|------|
| 16 | 🔵 theorem | `dice_complement_1` |
| 17 | 🔵 theorem | `dice_complement_2` |
| 20 | 🔵 theorem | `birthday_approx` |
| 29 | 🔵 theorem | `fair_die_ev` |
| 36 | 🔵 theorem | `linearity_expect` |
| 47 | 🔵 theorem | `data_proc` |
| 57 | 🔵 theorem | `harmonic_vals` |

### 📄 StochasticProcesses.lean

| Line | Kind | Name |
|------|------|------|
| 7 | 🔵 theorem | `stoch_rows` |
| 13 | 🔵 theorem | `uniform_stat` |
| 17 | 🔵 theorem | `gamblers_ruin_prob` |
| 22 | 🔵 theorem | `put_call` |
| 26 | 🔵 theorem | `pollard_iof` |

---

## Quantum

### 📄 MoonshotQuantum.lean

| Line | Kind | Name |
|------|------|------|
| 59 | 🔵 theorem | `no_cloning_core_real` |
| 70 | 🔵 theorem | `no_cloning_core_complex` |
| 81 | 🔵 theorem | `no_cloning_core_int` |
| 87 | 🔵 theorem | `idempotent_function_binary` |
| 116 | 🟡 def | `time_reverse_matrix` |
| 126 | 🔵 theorem | `time_reverse_mul` |
| 137 | 🔵 theorem | `time_reverse_det_one` |
| 148 | 🔵 theorem | `time_reverse_det_neg_one` |
| 160 | 🔵 theorem | `double_time_reverse` |
| 166 | 🔵 theorem | `pauli_X_adjugate` |
| 177 | 🔵 theorem | `pauli_Z_self_adjoint` |
| 189 | 🔵 theorem | `time_reverse_antimorphism` |
| 214 | 🟡 def | `pauli_I` |
| 217 | 🟡 def | `sd_X` |
| 220 | 🟡 def | `sd_Z` |
| 223 | 🟡 def | `sd_XZ` |
| 228 | 🔵 theorem | `trace_orth_I_X` |
| 231 | 🔵 theorem | `trace_orth_I_Z` |
| 234 | 🔵 theorem | `trace_orth_I_XZ` |
| 237 | 🔵 theorem | `trace_orth_X_Z` |
| 240 | 🔵 theorem | `trace_orth_X_XZ` |
| 243 | 🔵 theorem | `trace_orth_Z_XZ` |
| 247 | 🔵 theorem | `trace_norm_I` |
| 248 | 🔵 theorem | `trace_norm_X` |
| 249 | 🔵 theorem | `trace_norm_Z` |
| 250 | 🔵 theorem | `trace_norm_XZ` |
| 255 | 🔵 theorem | `superdense_capacity` |
| 259 | 🔵 theorem | `pauli_group_closure_X_sq` |
| 260 | 🔵 theorem | `pauli_group_closure_Z_sq` |
| 261 | 🔵 theorem | `pauli_group_closure_XZ_sq` |
| 288 | 🔵 theorem | `classical_CHSH_bound` |
| 301 | 🔵 theorem | `classical_CHSH_bound_abs` |
| 315 | 🔵 theorem | `quantum_exceeds_classical` |
| 325 | 🔵 theorem | `tsirelson_bound_sq` |
| 348 | 🟡 def | `symplectic_inner` |
| 358 | 🔵 theorem | `perfect_code_singleton` |
| 361 | 🔵 theorem | `steane_code_singleton` |
| 365 | 🔵 theorem | `quantum_hamming_bound_5_1_3` |
| 369 | 🔵 theorem | `steane_code_rate` |
| 387 | 🔵 theorem | `gate_counting_lower_bound` |
| 399 | 🔵 theorem | `depth_log_bound` |
| 413 | 🔵 theorem | `exponential_beats_polynomial` |
| 425 | 🔵 theorem | `knill_lower_bound_base` |
| 448 | 🔵 theorem | `bloch_sphere_constraint` |
| 461 | 🔵 theorem | `purity_bound_bloch` |
| 467 | 🔵 theorem | `max_entropy_qubit` |
| 495 | 🟡 def | `is_elliptic` |
| 499 | 🟡 def | `is_parabolic` |
| 503 | 🟡 def | `is_hyperbolic` |
| 513 | 🔵 theorem | `sl2_trichotomy` |
| 524 | 🔵 theorem | `S_is_elliptic` |
| 534 | 🔵 theorem | `T_sq_is_parabolic` |
| 547 | 🔵 theorem | `M1_is_parabolic` |
| 564 | 🔵 theorem | `sl2_preserves_pythagorean_structure` |
| 600 | 🔵 theorem | `no_signaling_trace` |
| 629 | 🔵 theorem | `grover_speedup` |
| 642 | 🔵 theorem | `quantum_parallelism` |
| 663 | 🔵 theorem | `simon_gap` |
| 693 | 🔵 theorem | `quantum_supremacy_base` |
| 708 | 🔵 theorem | `entanglement_monogamy_base` |
| 725 | 🔵 theorem | `decoherence_decay` |
| 739 | 🔵 theorem | `born_rule_normalization` |

### 📄 QuantumAIMadScience.lean

| Line | Kind | Name |
|------|------|------|
| 49 | 🔵 theorem | `no_cloning_1d` |
| 60 | 🔵 theorem | `cloning_gap_explicit` |
| 72 | 🔵 theorem | `cloning_cross_terms` |
| 84 | 🔵 theorem | `no_cloning_complex` |
| 98 | 🔵 theorem | `no_cloning_matrix` |
| 127 | 🔵 theorem | `classical_search_lower_bound` |
| 138 | 🔵 theorem | `grover_fewer_than_classical` |
| 149 | 🔵 theorem | `quantum_quadratic_speedup` |
| 160 | 🔵 theorem | `grover_significant_speedup` |
| 185 | 🔵 theorem | `relu_two_regions` |
| 196 | 🔵 theorem | `relu_piecewise_linear` |
| 208 | 🔵 theorem | `relu_regions_1d` |
| 218 | 🔵 theorem | `width_capacity_monotone` |
| 229 | 🔵 theorem | `depth_multiplies_regions` |
| 252 | 🔵 theorem | `function_count` |
| 264 | 🔵 theorem | `nfl_twin_count` |
| 275 | 🔵 theorem | `random_guess_imperfect` |
| 287 | 🔵 theorem | `structured_beats_random` |
| 311 | 🔵 theorem | `quantum_singleton_bound` |
| 322 | 🔵 theorem | `quantum_tax` |
| 332 | 🔵 theorem | `perfect_five_qubit_code` |
| 342 | 🔵 theorem | `steane_code_valid` |
| 352 | 🔵 theorem | `surface_code_valid` |
| 376 | 🔵 theorem | `correlation_budget` |
| 388 | 🔵 theorem | `maximal_entanglement_exclusive` |
| 400 | 🔵 theorem | `entanglement_conservation` |
| 423 | 🔵 theorem | `parameter_capacity` |
| 433 | 🔵 theorem | `generalization_bound` |
| 445 | 🔵 theorem | `sauer_shelah_core` |
| 457 | 🔵 theorem | `overparameterized_underdetermined` |
| 481 | 🔵 theorem | `quantum_advantage_real` |
| 492 | 🔵 theorem | `quantum_gap_grows` |
| 504 | 🔵 theorem | `circuit_space_exponential` |

### 📄 QuantumBerggren.lean

| Line | Kind | Name |
|------|------|------|
| 38 | 🟡 def | `BG₁` |
| 42 | 🟡 def | `BG₂` |
| 46 | 🟡 def | `BG₃` |
| 50 | 🟡 def | `BG₁_inv` |
| 54 | 🟡 def | `BG₂_inv` |
| 58 | 🟡 def | `BG₃_inv` |
| 63 | 🔵 theorem | `BG₁_mul_inv` |
| 64 | 🔵 theorem | `BG₂_mul_inv` |
| 65 | 🔵 theorem | `BG₃_mul_inv` |
| 66 | 🔵 theorem | `BG₁_inv_mul` |
| 67 | 🔵 theorem | `BG₂_inv_mul` |
| 68 | 🔵 theorem | `BG₃_inv_mul` |
| 78 | 🟡 def | `QLor` |
| 82 | 🔵 theorem | `BG₁_unitary` |
| 85 | 🔵 theorem | `BG₂_unitary` |
| 88 | 🔵 theorem | `BG₃_unitary` |
| 91 | 🔵 theorem | `BG₁_inv_unitary` |
| 94 | 🔵 theorem | `BG₂_inv_unitary` |
| 97 | 🔵 theorem | `BG₃_inv_unitary` |
| 115 | 🟡 def | `R₁₂` |
| 118 | 🟡 def | `R₁₃` |
| 121 | 🟡 def | `R₂₃` |
| 124 | 🔵 theorem | `gate_swap_12` |
| 127 | 🔵 theorem | `gate_swap_13` |
| 130 | 🔵 theorem | `gate_swap_23` |
| 133 | 🔵 theorem | `R₁₂_involution` |
| 136 | 🔵 theorem | `R₁₃_involution` |
| 139 | 🔵 theorem | `R₂₃_involution` |
| 142 | 🔵 theorem | `R₁₂_unitary` |
| 143 | 🔵 theorem | `R₁₃_unitary` |
| 144 | 🔵 theorem | `R₂₃_unitary` |
| 147 | 🔵 theorem | `det_R₁₂` |
| 150 | 🔵 theorem | `det_R₁₃` |
| 153 | 🔵 theorem | `det_R₂₃` |
| 166 | 🔵 theorem | `simplify_121_to_2` |
| 171 | 🔵 theorem | `simplify_pre_121_to_2` |
| 176 | 🔵 theorem | `circuit_cancel_12` |
| 180 | 🔵 theorem | `circuit_cancel_13` |
| 184 | 🔵 theorem | `circuit_cancel_23` |
| 193 | 🔵 theorem | `inv_gate_swap_12` |
| 194 | 🔵 theorem | `inv_gate_swap_13` |
| 195 | 🔵 theorem | `inv_gate_swap_23` |
| 203 | 🔵 theorem | `BG₁_BG₂_ne_BG₂_BG₁` |
| 204 | 🔵 theorem | `BG₁_BG₃_ne_BG₃_BG₁` |
| 205 | 🔵 theorem | `BG₂_BG₃_ne_BG₃_BG₂` |
| 208 | 🔵 theorem | `commutator_13_nontrivial` |
| 217 | 🔵 theorem | `det_BG₁` |
| 218 | 🔵 theorem | `det_BG₂` |
| 219 | 🔵 theorem | `det_BG₃` |
| 222 | 🔵 theorem | `det_BG₁_BG₂` |
| 225 | 🔵 theorem | `det_BG₁_BG₂_BG₁_BG₂` |
| 234 | 🟡 def | `MG₁` |
| 237 | 🟡 def | `MG₂` |
| 240 | 🟡 def | `MG₃` |
| 243 | 🔵 theorem | `det_MG₁` |
| 246 | 🔵 theorem | `det_MG₃` |
| 258 | 🔵 theorem | `hyp_growth_B2` |
| 280 | 🔵 theorem | `berggren_preserves_pyth_form` |
| 284 | 🔵 theorem | `berggren_B2_preserves_form` |
| 288 | 🔵 theorem | `berggren_B3_preserves_form` |

### 📄 QuantumBerggrenGates.lean

| Line | Kind | Name |
|------|------|------|
| 31 | 🟡 def | `pythRotation` |
| 35 | 🔵 theorem | `det_pythRotation` |
| 40 | 🔵 theorem | `det_pythRotation_pyth` |
| 45 | 🔵 theorem | `pythRotation_transpose` |
| 55 | 🔵 theorem | `pythRotation_mul` |
| 61 | 🔵 theorem | `brahmagupta_fibonacci` |
| 65 | 🔵 theorem | `pythRotation_product_pyth` |
| 72 | 🔵 theorem | `pythRotation_one` |
| 76 | 🔵 theorem | `pythRotation_inv` |
| 85 | 🔴 structure | `BerggrenGate where` |
| 93 | 🟡 def | `BerggrenGate.toMatrix` |
| 97 | 🔵 theorem | `BerggrenGate.det_eq` |
| 102 | 🟡 def | `rootGate` |
| 105 | 🟡 def | `gate_5_12_13` |
| 108 | 🟡 def | `gate_8_15_17` |
| 111 | 🟡 def | `gate_7_24_25` |
| 115 | 🟡 def | `R_345` |
| 118 | 🔵 theorem | `R345_squared` |
| 123 | 🔵 theorem | `R345_squared_pyth` |
| 126 | 🔵 theorem | `R345_cubed` |
| 131 | 🔵 theorem | `R345_cubed_norm` |
| 134 | 🔵 theorem | `compose_345_51213` |
| 139 | 🔵 theorem | `compose_345_51213_pyth` |
| 144 | 🟡 def | `onLightCone` |
| 147 | 🔵 theorem | `root_on_light_cone` |
| 151 | 🔵 theorem | `berggren_M1_preserves_cone` |
| 156 | 🔵 theorem | `berggren_M2_preserves_cone` |
| 161 | 🔵 theorem | `berggren_M3_preserves_cone` |
| 168 | 🟡 def | `pauli_X'` |
| 171 | 🟡 def | `pauli_Z'` |
| 174 | 🔵 theorem | `pauliX_conjugate_pythRot` |
| 180 | 🔵 theorem | `pauliZ_conjugate_pythRot` |
| 186 | 🔵 theorem | `pauli_conjugation_inverts` |
| 194 | 🔵 theorem | `trace_pythRotation` |
| 199 | 🔵 theorem | `trace_composition` |
| 207 | 🟡 def | `gaussNormSq` |
| 210 | 🔵 theorem | `gaussNormSq_mul` |
| 218 | 🟡 def | `evalBerggrenCircuit1` |
| 223 | 🔵 theorem | `det_evalBerggrenCircuit1` |
| 231 | 🔵 theorem | `circuit_composition_formula` |
| 239 | 🟡 def | `controlledBerggrenGate` |
| 246 | 🔵 theorem | `det_controlledBerggrenGate` |
| 259 | 🟡 def | `pythRotation_mod` |
| 266 | 🟡 def | `berggren_rot_M1` |
| 270 | 🟡 def | `berggren_rot_M2` |
| 274 | 🟡 def | `berggren_rot_M3` |
| 278 | 🟡 def | `berggrenRotations` |
| 288 | 🟡 def | `rotationPowers` |
| 305 | 🟡 def | `cayleyParam` |
| 313 | 🟡 def | `matrixOrder` |

### 📄 QuantumBerggrenResearch.lean

| Line | Kind | Name |
|------|------|------|
| 30 | 🟡 def | `pythRot` |
| 34 | 🔵 theorem | `det_pythRot` |
| 38 | 🔵 theorem | `pythRot_mul` |
| 44 | 🔵 theorem | `pythRot_one` |
| 48 | 🔵 theorem | `brahmagupta_fibonacci` |
| 52 | 🔵 theorem | `pythRot_conformal` |
| 59 | 🔵 theorem | `pythRot_transpose` |
| 64 | 🔵 theorem | `trace_pythRot` |
| 68 | 🔵 theorem | `pythRot_comm` |
| 75 | 🔴 structure | `BerggrenGate where` |
| 82 | 🟡 def | `BerggrenGate.toMatrix` |
| 85 | 🔵 theorem | `BerggrenGate.det_eq` |
| 89 | 🔵 theorem | `BerggrenGate.compose_det` |
| 93 | 🟡 def | `rootGate'` |
| 94 | 🟡 def | `gate_5_12_13'` |
| 95 | 🟡 def | `gate_21_20_29'` |
| 96 | 🟡 def | `gate_15_8_17'` |
| 100 | 🟡 def | `B₁'` |
| 101 | 🟡 def | `B₂'` |
| 102 | 🟡 def | `B₃'` |
| 103 | 🟡 def | `lorentzMetric'` |
| 105 | 🟡 def | `onLightCone'` |
| 108 | 🔵 theorem | `B1_preserves_lorentz'` |
| 113 | 🔵 theorem | `B2_preserves_lorentz'` |
| 118 | 🔵 theorem | `B3_preserves_lorentz'` |
| 123 | 🔵 theorem | `det_B1'` |
| 126 | 🔵 theorem | `det_B2'` |
| 129 | 🔵 theorem | `det_B3'` |
| 132 | 🔵 theorem | `B1_preserves_cone'` |
| 137 | 🔵 theorem | `B2_preserves_cone'` |
| 142 | 🔵 theorem | `B3_preserves_cone'` |
| 148 | 🟡 def | `S_SL2'` |
| 149 | 🟡 def | `T_SL2'` |
| 150 | 🟡 def | `M₁_2x2'` |
| 151 | 🟡 def | `M₂_2x2'` |
| 152 | 🟡 def | `M₃_2x2'` |
| 155 | 🔵 theorem | `M1_eq_T_sq_S'` |
| 158 | 🔵 theorem | `M3_eq_T_sq'` |
| 161 | 🔵 theorem | `S_from_berggren'` |
| 165 | 🔵 theorem | `det_M1'` |
| 168 | 🔵 theorem | `det_M2'` |
| 171 | 🔵 theorem | `det_M3'` |
| 174 | 🔵 theorem | `S_squared'` |
| 177 | 🔵 theorem | `S_order_4'` |
| 182 | 🟡 def | `pauliX'` |
| 183 | 🟡 def | `pauliZ'` |
| 186 | 🔵 theorem | `pauliX_conjugation'` |
| 192 | 🔵 theorem | `pauliZ_conjugation'` |
| 198 | 🔵 theorem | `pauli_duality'` |
| 202 | 🔵 theorem | `pauliX_squared'` |
| 203 | 🔵 theorem | `pauliZ_squared'` |
| 206 | 🔵 theorem | `pauliXZ_anticommute'` |
| 211 | 🟡 def | `evalCircuit'` |
| 215 | 🔵 theorem | `det_evalCircuit'` |
| 222 | 🔵 theorem | `circuit_two_gates'` |
| 229 | 🔵 theorem | `R345_squared'` |
| 233 | 🔵 theorem | `triple_7_24_25'` |
| 235 | 🔵 theorem | `compose_345_51213'` |
| 239 | 🔵 theorem | `triple_33_56_65'` |
| 244 | 🔴 structure | `PythQuadruple where` |
| 253 | 🟡 def | `PythQuadruple.toMatrix` |
| 259 | 🟡 def | `rootQuad'` |
| 260 | 🟡 def | `quad_2_3_6_7'` |
| 261 | 🟡 def | `quad_4_4_7_9'` |
| 264 | 🔵 theorem | `rootQuad_conformal'` |
| 269 | 🔵 theorem | `pythQuad_norm_eq_2d_sq'` |
| 275 | 🟡 def | `gaussNorm'` |
| 277 | 🔵 theorem | `gaussNorm_mul'` |
| 282 | 🔵 theorem | `gaussNorm_pyth_preserved'` |
| 289 | 🔵 theorem | `trace_composition'` |
| 293 | 🔵 theorem | `trace_pauli_conjugation'` |
| 298 | 🔵 theorem | `pythRot_char_eq'` |
| 306 | 🟡 def | `pythRotMod'` |
| 310 | 🔵 theorem | `det_pythRotMod'` |
| 316 | 🔵 theorem | `pythRot_sq'` |
| 320 | 🔵 theorem | `det_pythRot_sq'` |
| 326 | 🟡 def | `controlledPythRot'` |
| 336 | 🔵 theorem | `det_controlledPythRot'` |
| 342 | 🔵 theorem | `det_controlledPythRot_pyth'` |
| 348 | 🟡 def | `J_SO2'` |
| 351 | 🔵 theorem | `J_sq'` |
| 356 | 🔵 theorem | `pythRot_commutes_J'` |

### 📄 QuantumCircuits.lean

| Line | Kind | Name |
|------|------|------|
| 33 | 🟡 def | `pauli_X` |
| 36 | 🟡 def | `pauli_Z` |
| 39 | 🟡 def | `pauli_XZ` |
| 42 | 🔵 theorem | `pauli_X_squared` |
| 47 | 🔵 theorem | `pauli_Z_squared` |
| 52 | 🔵 theorem | `pauli_XZ_squared` |
| 57 | 🔵 theorem | `pauli_anticommute` |
| 62 | 🔵 theorem | `pauli_X_mul_Z` |
| 67 | 🔵 theorem | `det_pauli_X` |
| 71 | 🔵 theorem | `det_pauli_Z` |
| 75 | 🔵 theorem | `det_pauli_XZ` |
| 84 | 🟡 def | `hadamard_scaled` |
| 87 | 🔵 theorem | `hadamard_scaled_squared` |
| 93 | 🔵 theorem | `det_hadamard_scaled` |
| 97 | 🔵 theorem | `hadamard_conjugates_X_to_Z` |
| 104 | 🔵 theorem | `hadamard_conjugates_Z_to_X` |
| 117 | 🔵 theorem | `S_gate_relation` |
| 125 | 🟡 def | `CNOT` |
| 132 | 🔵 theorem | `CNOT_squared` |
| 135 | 🔵 theorem | `det_CNOT` |
| 143 | 🟡 def | `Toffoli` |
| 154 | 🔵 theorem | `Toffoli_squared` |
| 159 | 🔵 theorem | `det_Toffoli` |
| 169 | 🟡 def | `SWAP_gate` |
| 176 | 🔵 theorem | `SWAP_squared` |
| 179 | 🔵 theorem | `det_SWAP` |
| 184 | 🟡 def | `CZ_gate` |
| 191 | 🔵 theorem | `CZ_squared` |
| 194 | 🔵 theorem | `det_CZ` |
| 197 | 🔵 theorem | `CZ_symmetric` |
| 205 | 🔵 theorem | `CNOT_self_commute` |
| 209 | 🔵 theorem | `real_pauli_group_relations` |
| 222 | 🟡 def | `hamming_parity` |
| 228 | 🔵 theorem | `hamming_columns_nonzero` |
| 232 | 🔵 theorem | `hamming_columns_distinct` |
| 241 | 🔴 structure | `QuantumCircuit` |
| 245 | 🟡 def | `QuantumCircuit.depth` |
| 249 | 🟡 def | `QuantumCircuit.seq` |
| 254 | 🔵 theorem | `QuantumCircuit.depth_seq` |
| 260 | 🟡 def | `QuantumCircuit.identity` |
| 263 | 🔵 theorem | `QuantumCircuit.depth_identity` |
| 275 | 🔵 theorem | `universal_gate_set_growth` |
| 279 | 🔵 theorem | `circuits_of_exact_depth` |
| 289 | 🔵 theorem | `theta_circuits_at_depth` |
| 293 | 🔵 theorem | `berggren_leaves_at_depth` |

### 📄 QuantumCompression.lean

| Line | Kind | Name |
|------|------|------|
| 49 | 🔵 theorem | `no_injection_to_smaller` |
| 56 | 🔵 theorem | `no_universal_compressor` |
| 64 | 🔵 theorem | `compression_must_expand_something` |
| 75 | 🔵 theorem | `short_strings_count` |
| 81 | 🔵 theorem | `incompressible_strings_lower_bound` |
| 88 | 🔵 theorem | `incompressible_fraction` |
| 100 | 🔵 theorem | `entropy_upper_bound_log` |
| 106 | 🔵 theorem | `binary_entropy_le_one` |
| 115 | 🔴 structure | `Codebook` |
| 121 | 🔵 theorem | `codebook_encode_is_O1` |
| 125 | 🟡 def | `trivial_codebook` |
| 131 | 🟡 def | `Codebook.comp` |
| 148 | 🟡 def | `circuit_length` |
| 151 | 🟡 def | `is_circuit_optimization` |
| 156 | 🔵 theorem | `identity_circuit_length` |
| 160 | 🔵 theorem | `concat_circuit_length` |
| 176 | 🟠 noncomputable def | `description_length` |
| 186 | 🔵 theorem | `complexity_invariance_structure` |
| 191 | 🔵 theorem | `trivial_upper_bound` |
| 202 | 🔵 theorem | `berggren_depth_eq_circuit_length` |
| 206 | 🔵 theorem | `circuits_at_depth` |

### 📄 QuantumFoundations.lean

| Line | Kind | Name |
|------|------|------|
| 18 | 🔵 theorem | `norm_triangle_pf` |
| 29 | 🔵 theorem | `inner_mul_le_norm_pf` |
| 42 | 🔵 theorem | `unitary_mul_unitary` |
| 55 | 🔵 theorem | `unitary_inv_eq_star` |
| 69 | 🔵 theorem | `tensor_normalized` |
| 83 | 🔵 theorem | `pauli_x_squared` |

### 📄 QuantumGateAlgebra.lean

| Line | Kind | Name |
|------|------|------|
| 26 | 🟡 def | `I₂` |
| 29 | 🟡 def | `σX` |
| 31 | 🟡 def | `σZ` |
| 33 | 🟡 def | `σXZ` |
| 36 | 🔵 theorem | `sigma_X_mul_Z` |
| 40 | 🔵 theorem | `sigma_Z_mul_X` |
| 45 | 🔵 theorem | `pauli_commutator_XZ` |
| 51 | 🔵 theorem | `pauli_anticommutator_XZ` |
| 56 | 🔵 theorem | `sigma_XZ_sq` |
| 60 | 🔵 theorem | `sigma_XZ_fourth` |
| 65 | 🔵 theorem | `trace_sigma_X` |
| 66 | 🔵 theorem | `trace_sigma_Z` |
| 67 | 🔵 theorem | `trace_sigma_XZ` |
| 70 | 🔵 theorem | `paulis_traceless` |
| 76 | 🟡 def | `kron2` |
| 81 | 🟡 def | `X_tensor_I` |
| 82 | 🟡 def | `I_tensor_X` |
| 83 | 🟡 def | `X_tensor_X` |
| 85 | 🔵 theorem | `X_tensor_I_squared` |
| 86 | 🔵 theorem | `I_tensor_X_squared` |
| 89 | 🔵 theorem | `tensor_X_commute` |
| 91 | 🔵 theorem | `X_tensor_X_squared` |
| 92 | 🔵 theorem | `det_X_tensor_I` |
| 93 | 🔵 theorem | `det_X_tensor_X` |
| 97 | 🟡 def | `CNOT₂` |
| 100 | 🟡 def | `CNOT_rev` |
| 103 | 🔵 theorem | `CNOT_ne_rev` |
| 106 | 🔵 theorem | `CNOT_propagates_X` |
| 109 | 🔵 theorem | `CNOT_preserves_target_X` |
| 111 | 🟡 def | `Z_tensor_I` |
| 112 | 🟡 def | `I_tensor_Z` |
| 115 | 🔵 theorem | `CNOT_propagates_Z_backward` |
| 118 | 🔵 theorem | `CNOT_preserves_control_Z` |
| 123 | 🟡 def | `mat_commutator` |
| 127 | 🔵 theorem | `commutator_antisymmetric` |
| 132 | 🔵 theorem | `commutator_self` |
| 137 | 🔵 theorem | `jacobi_identity` |
| 144 | 🔵 theorem | `trotter_error_pauli` |
| 148 | 🔵 theorem | `commuting_operators_exact_trotter` |
| 154 | 🔵 theorem | `commutator_zero_iff_commute` |
| 163 | 🟡 def | `T_count` |
| 166 | 🔵 theorem | `T_count_append` |
| 170 | 🔵 theorem | `T_count_nil` |
| 174 | 🔴 structure | `QuantumWalk where` |
| 180 | 🟡 def | `grover_coin_scaled` |
| 183 | 🔵 theorem | `grover_coin_sq` |
| 193 | 🟡 def | `PauliType.toMatrix` |
| 199 | 🔴 structure | `SignedPauli where` |
| 204 | 🟡 def | `SignedPauli.toMatrix` |
| 208 | 🟡 def | `PauliType.mul` |
| 221 | 🔵 theorem | `pauli_mul_XX` |
| 222 | 🔵 theorem | `pauli_mul_ZZ` |
| 223 | 🔵 theorem | `pauli_mul_XZ` |
| 224 | 🔵 theorem | `pauli_mul_ZX` |
| 229 | 🟡 def | `hadamard_conjugate` |
| 235 | 🔵 theorem | `hadamard_conjugate_involutive` |
| 239 | 🟡 def | `S_conjugate` |
| 245 | 🔵 theorem | `S_conjugate_order` |
| 251 | 🔴 structure | `HamiltonianTerm` |
| 255 | 🔴 structure | `QHamiltonian` |
| 258 | 🟡 def | `QHamiltonian.termCount` |
| 260 | 🟡 def | `simulation_gate_cost` |
| 262 | 🔵 theorem | `simulation_cost_linear` |
| 268 | 🔵 theorem | `CHSH_classical_bound` |
| 276 | 🔵 theorem | `quantum_exceeds_classical_CHSH` |
| 281 | 🟡 def | `SWAP_from_CNOT` |
| 283 | 🔵 theorem | `SWAP_decomposition` |
| 286 | 🟡 def | `CZ₂` |
| 289 | 🟡 def | `Z_tensor_Z` |
| 291 | 🔵 theorem | `Z_tensor_Z_squared` |
| 296 | 🟡 def | `matrix_pow_2k` |
| 301 | 🔵 theorem | `det_matrix_pow_2k` |
| 309 | 🔵 theorem | `hilbert_space_dimension` |
| 313 | 🔵 theorem | `quantum_parallelism_advantage` |
| 326 | 🔴 structure | `CSSCode where` |
| 332 | 🟡 def | `CSSCode.logicalQubits` |
| 334 | 🟡 def | `steane_code` |
| 337 | 🔵 theorem | `steane_logical` |
| 340 | 🟡 def | `reed_muller_15` |
| 343 | 🔵 theorem | `reed_muller_logical` |
| 346 | 🟡 def | `golay_code` |
| 349 | 🔵 theorem | `golay_logical` |
| 352 | 🟡 def | `surface_code` |

### 📄 QuantumGateSynthesis.lean

| Line | Kind | Name |
|------|------|------|
| 55 | 🟡 def | `ThetaCircuit` |
| 57 | ⚪ instance | `: Repr ThetaCircuit` |
| 60 | 🟡 def | `ThetaGate.toMatrix` |
| 67 | 🟡 def | `eval_circuit` |
| 73 | 🔵 theorem | `det_gate` |
| 76 | 🔵 theorem | `eval_circuit_determinant` |
| 84 | 🔵 theorem | `M₁_mul_M₁_inv` |
| 88 | 🔵 theorem | `M₁_inv_mul_M₁` |
| 92 | 🔵 theorem | `M₃_mul_M₃_inv` |
| 96 | 🔵 theorem | `M₃_inv_mul_M₃` |
| 106 | 🟡 def | `S_matrix` |
| 109 | 🟡 def | `T_sq_matrix` |
| 111 | 🔵 theorem | `S_eq_M₃_inv_M₁` |
| 115 | 🔵 theorem | `T_sq_eq_M₃` |
| 132 | 🔵 theorem | `factoring_from_parameters` |
| 136 | 🔵 theorem | `factors_correct` |
| 140 | 🔴 structure | `FactoringResult where` |
| 154 | 🟡 def | `apply_circuit` |
| 158 | 🟡 def | `root_params` |
| 161 | 🔵 theorem | `root_params_diff_sq` |
| 178 | 🟡 def | `BerggrenPath` |
| 181 | 🟡 def | `BerggrenPath.toCircuit` |
| 189 | 🔵 theorem | `circuit_eval_is_matrix_product` |
| 212 | 🔵 theorem | `circuit_gives_factorization` |
| 241 | 🟡 def | `extract_factors` |
| 246 | 🔵 theorem | `extract_factors_correct` |
| 261 | 🟡 def | `extraction_ops` |
| 265 | 🟡 def | `matvec_ops` |
| 268 | 🟡 def | `total_extraction_ops` |
| 271 | 🔵 theorem | `extraction_is_O1` |
| 285 | 🟡 def | `euclidean_step` |
| 289 | 🔵 theorem | `det_euclidean_step` |
| 294 | 🔵 theorem | `det_two_steps` |
| 310 | 🔵 theorem | `factor_15_example` |
| 319 | 🔵 theorem | `factor_5_example` |
| 328 | 🔵 theorem | `factor_45_example` |

### 📄 QuantumGates.lean

| Line | Kind | Name |
|------|------|------|
| 24 | 🟡 def | `phase_gate` |
| 31 | 🔵 theorem | `phase_gate_involutive` |
| 44 | 🟡 def | `gaussian_units` |
| 54 | 🔵 theorem | `gaussian_unit_norm` |
| 75 | 🔵 theorem | `quaternion_norm_sq_mul` |
| 112 | 🔵 theorem | `cayley_dickson_dimensions` |

### 📄 QuantumLLMCompilation.lean

| Line | Kind | Name |
|------|------|------|
| 24 | 🔵 theorem | `linear_composition_is_linear` |
| 32 | 🔵 theorem | `linear_composition_chain` |
| 45 | 🔵 theorem | `region_count_exponential_bound` |
| 50 | 🔵 theorem | `linearization_dimension_lower_bound` |
| 56 | 🔵 theorem | `qubit_dimension` |
| 65 | 🔵 theorem | `exponential_compression` |
| 75 | 🔵 theorem | `qubit_count_exists` |
| 82 | 🔵 theorem | `full_tensor_size` |
| 87 | 🔵 theorem | `compression_grows_with_context` |
| 93 | 🔵 theorem | `tensor_rank_bound` |
| 100 | 🔵 theorem | `doubly_exponential_growth` |
| 110 | 🔵 theorem | `classical_vs_quantum_storage` |
| 114 | 🔵 theorem | `quantum_exponential_compression` |
| 122 | 🔵 theorem | `finite_function_matrix_representation` |
| 132 | 🔵 theorem | `parameter_ratio_vanishes` |

### 📄 QuantumMathSimulation.lean

| Line | Kind | Name |
|------|------|------|
| 36 | 🟡 def | `IsQuantumState` |
| 41 | 🟡 def | `IsUnitaryGate` |
| 53 | 🔵 theorem | `identity_is_unitary` |
| 64 | 🔵 theorem | `unitary_comp` |
| 78 | 🔵 theorem | `unitary_adjoint` |
| 86 | 🔵 theorem | `born_rule_valid` |
| 96 | 🔵 theorem | `born_probability_nonneg` |
| 107 | 🔵 theorem | `born_probability_le_one` |
| 118 | 🟡 def | `QSeparable` |
| 122 | 🟡 def | `QEntangled` |
| 126 | 🟠 noncomputable def | `bellState` |
| 137 | 🔵 theorem | `bell_state_entangled` |
| 144 | 🟠 noncomputable def | `applyGate` |
| 149 | 🟠 noncomputable def | `applyCircuit` |
| 158 | 🟠 noncomputable def | `circuitUnitary` |
| 169 | 🔵 theorem | `circuit_composition` |
| 192 | 🔵 theorem | `state_space_exponential` |
| 203 | 🔵 theorem | `qubit_doubles_space` |
| 214 | 🔵 theorem | `simulation_dimension` |
| 221 | 🟠 noncomputable def | `hadamardGate` |
| 225 | 🟡 def | `pauliX` |
| 228 | 🟡 def | `pauliZ` |
| 237 | 🔵 theorem | `pauliX_unitary` |
| 247 | 🔵 theorem | `pauliZ_unitary` |
| 258 | 🔵 theorem | `pauliX_involution` |
| 268 | 🔵 theorem | `pauliZ_involution` |
| 280 | 🔵 theorem | `hadamard_unitary` |
| 291 | 🔵 theorem | `hadamard_conjugation` |
| 311 | 🔵 theorem | `no_cloning_inner_product` |
| 327 | 🔵 theorem | `quantum_is_linear_algebra` |

### 📄 QuantumMetaPhysics.lean

| Line | Kind | Name |
|------|------|------|
| 39 | 🔵 theorem | `energy_time_positive` |
| 49 | 🔵 theorem | `energy_time_scaling` |
| 60 | 🔵 theorem | `energy_time_additive` |
| 66 | 🟠 noncomputable def | `maxOperations` |
| 75 | 🔵 theorem | `maxOperations_pos` |
| 86 | 🔵 theorem | `maxOperations_double_energy` |
| 97 | 🔵 theorem | `maxOperations_mono_energy` |
| 112 | 🔴 structure | `CompLevel where` |
| 119 | 🟡 def | `CompLevel.bounded_by` |
| 123 | 🟠 noncomputable def | `CompLevel.capacity` |
| 133 | 🔵 theorem | `capacity_monotone` |
| 145 | 🔵 theorem | `hierarchy_transitive` |
| 157 | 🔵 theorem | `verifier_bounded_by_universe` |
| 170 | 🟠 noncomputable def | `holographicBound` |
| 180 | 🔵 theorem | `holographic_mono` |
| 194 | 🔵 theorem | `lloyd_bound_structure` |
| 206 | 🟠 noncomputable def | `fubiniStudyDist` |
| 216 | 🔵 theorem | `orthogonal_max_distance` |
| 228 | 🔵 theorem | `fubiniStudy_nonneg` |
| 239 | 🔵 theorem | `fubiniStudy_le_pi_half` |
| 260 | 🔵 theorem | `verification_capacity_decay` |
| 272 | 🔵 theorem | `total_hierarchy_capacity_bound` |
| 284 | 🔵 theorem | `hierarchy_finite_capacity` |

### 📄 QuantumMoonshots.lean

| Line | Kind | Name |
|------|------|------|
| 14 | 🟡 def | `teleportation_network_ebits` |
| 15 | 🟡 def | `star_network_ebits` |
| 17 | 🔵 theorem | `star_more_efficient` |
| 27 | 🟡 def | `black_hole_qubits` |
| 29 | 🔵 theorem | `baby_black_hole_feasible` |
| 31 | 🔵 theorem | `stellar_black_hole_impossible` |
| 36 | 🔵 theorem | `CHSH_classical_bound` |
| 43 | 🔵 theorem | `quantum_exceeds_classical` |
| 47 | 🔵 theorem | `quantum_money_security` |
| 52 | 🟡 def | `chemistry_qubits` |
| 53 | 🟡 def | `co2_qubits_accurate` |
| 55 | 🔵 theorem | `terraforming_qubits` |
| 58 | 🔵 theorem | `classical_chemistry_intractable` |
| 62 | 🔵 theorem | `quantum_kernel_advantage` |
| 66 | 🟡 def | `protein_interactions` |
| 67 | 🟡 def | `protein_folding_qubits` |
| 69 | 🔵 theorem | `small_protein_feasible` |
| 72 | 🔵 theorem | `levinthal_paradox` |
| 78 | 🟡 def | `dyson_configs` |
| 80 | 🔵 theorem | `dyson_20_configs` |
| 81 | 🔵 theorem | `dyson_quantum_tractable` |
| 85 | 🟡 def | `concatenated_qubits` |
| 87 | 🔵 theorem | `concat_distance7_level3` |
| 90 | 🔵 theorem | `concat_distance7_level5` |
| 93 | 🟡 def | `surface_code_qubits` |
| 95 | 🔵 theorem | `surface_code_d21` |
| 98 | 🔵 theorem | `million_qubit_logical` |
| 106 | 🔴 structure | `MoonshotAssessment where` |
| 112 | 🟡 def | `teleportation_assessment` |
| 116 | 🟡 def | `gravity_sim_assessment` |
| 120 | 🟡 def | `quantum_money_assessment` |
| 124 | 🟡 def | `protein_assessment` |
| 128 | 🟡 def | `quantum_ml_assessment` |

### 📄 QuantumProofMetric.lean

| Line | Kind | Name |
|------|------|------|
| 36 | 🟡 def | `ProofVector` |
| 39 | 🟠 noncomputable def | `proofInnerProduct` |
| 43 | 🟠 noncomputable def | `proofNormSq` |
| 47 | 🟡 def | `isNormalized` |
| 59 | 🟠 noncomputable def | `proofFidelity` |
| 63 | 🟠 noncomputable def | `fubiniStudyDist` |
| 69 | 🔵 theorem | `fidelity_nonneg` |
| 80 | 🔵 theorem | `self_fidelity_normalized` |
| 95 | 🔵 theorem | `fubiniStudy_self` |
| 106 | 🔵 theorem | `fubiniStudy_symm` |
| 121 | 🔵 theorem | `fubiniStudy_nonneg` |
| 133 | 🟡 def | `areOrthogonal` |
| 143 | 🔵 theorem | `orthogonal_zero_fidelity` |
| 154 | 🔵 theorem | `orthogonal_max_distance` |
| 166 | 🔴 structure | `ProofRefactoring` |
| 178 | 🔵 theorem | `refactoring_preserves_fidelity` |
| 190 | 🔵 theorem | `refactoring_preserves_distance` |
| 202 | 🟠 noncomputable def | `proofSuperposition` |
| 213 | 🔵 theorem | `superposition_norm` |

### 📄 QuantumProofSearch.lean

| Line | Kind | Name |
|------|------|------|
| 32 | 🔴 structure | `ClassicalSearch where` |
| 43 | 🔵 theorem | `classical_lower_bound` |
| 52 | 🟠 noncomputable def | `groverComplexity` |
| 62 | 🔵 theorem | `grover_quadratic_speedup` |
| 74 | 🔵 theorem | `grover_sqrt_bound` |
| 84 | 🟡 def | `isCloningMap` |
| 88 | 🟡 def | `isUnitary` |
| 104 | 🔵 theorem | `no_cloning` |
| 119 | 🟡 def | `hasAlgebraicStructure` |
| 130 | 🔵 theorem | `structured_quantum_advantage` |
| 141 | 🔵 theorem | `quantum_lower_bound` |
| 152 | 🔵 theorem | `classical_quantum_gap` |
| 163 | 🔴 structure | `QuantumOracle` |
| 176 | 🔵 theorem | `more_solutions_easier` |

### 📄 QuantumSimulation.lean

| Line | Kind | Name |
|------|------|------|
| 13 | 🟡 def | `sl2_e` |
| 14 | 🟡 def | `sl2_f` |
| 15 | 🟡 def | `sl2_h` |
| 18 | 🔵 theorem | `sl2_commutator_ef` |
| 23 | 🔵 theorem | `sl2_commutator_he` |
| 28 | 🔵 theorem | `sl2_commutator_hf` |
| 33 | 🟡 def | `sl2_casimir_scaled` |
| 37 | 🔵 theorem | `sl2_casimir_value` |
| 40 | 🔵 theorem | `casimir_commutes` |
| 46 | 🟡 def | `is_symmetry` |
| 48 | 🔵 theorem | `identity_is_symmetry` |
| 51 | 🔵 theorem | `symmetry_mul` |
| 63 | 🟡 def | `jw_two_body_gates` |
| 65 | 🔵 theorem | `jw_worst_case` |
| 68 | 🟡 def | `bk_two_body_gates` |
| 70 | 🔵 theorem | `bk_better_than_jw_8` |
| 73 | 🔵 theorem | `bk_better_than_jw_16` |
| 78 | 🔴 structure | `VariationalAnsatz where` |
| 83 | 🟡 def | `cluster_state_gates` |
| 85 | 🔵 theorem | `cluster_square_gates` |
| 93 | 🔵 theorem | `grover_advantage` |
| 97 | 🔵 theorem | `quantum_parallelism` |
| 100 | 🔵 theorem | `simon_gap_6` |
| 101 | 🔵 theorem | `simon_gap_8` |
| 102 | 🔵 theorem | `simon_gap_16` |
| 103 | 🔵 theorem | `simon_gap_32` |
| 105 | 🔵 theorem | `counting_advantage` |

### 📄 QuantumStructures.lean

| Line | Kind | Name |
|------|------|------|
| 20 | 🔵 theorem | `qubit_hilbert_dim` |
| 26 | 🟡 def | `pauliX` |
| 30 | 🟡 def | `pauliZ` |
| 40 | 🔵 theorem | `pauliX_sq` |
| 50 | 🔵 theorem | `pauliZ_sq` |
| 60 | 🔵 theorem | `pauliXZ_anticommute` |
| 72 | 🔵 theorem | `pauliX_trace` |
| 78 | 🔵 theorem | `pauliZ_trace` |
| 84 | 🔵 theorem | `pauliX_det` |
| 96 | 🔵 theorem | `kronecker_id_2` |
| 106 | 🟡 def | `gaussianBinomial` |
| 118 | 🔵 theorem | `gaussianBinomial_zero` |
| 128 | 🔵 theorem | `gaussianBinomial_gt` |
| 140 | 🔵 theorem | `crystallizer_lattice_bound` |
| 147 | 🔵 theorem | `separable_partial_trace_rank` |

### 📄 QuantumTypeTheory.lean

| Line | Kind | Name |
|------|------|------|
| 31 | 🟡 def | `QState` |
| 37 | 🟡 def | `IsUnitaryGate` |
| 51 | 🔵 theorem | `identity_gate_unitary` |
| 61 | 🔵 theorem | `unitary_mul_unitary` |
| 75 | 🔵 theorem | `unitary_conjTranspose` |
| 86 | 🟡 def | `BipartiteState` |
| 89 | 🟡 def | `isSeparable` |
| 93 | 🟡 def | `isEntangled` |
| 103 | 🔵 theorem | `tensorProduct_separable` |
| 115 | 🔵 theorem | `bell_state_entangled` |
| 129 | 🟡 def | `isCloningMap` |
| 133 | 🟡 def | `isLinearClone` |
| 145 | 🔵 theorem | `no_cloning_simplified` |
| 158 | 🔴 structure | `DensityMatrix` |
| 164 | 🔴 structure | `QuantumChannel` |
| 179 | 🔵 theorem | `id_channel_trace_preserving` |
| 190 | 🔵 theorem | `compose_trace_preserving` |

### 📄 QuantumUniverseSimulation.lean

| Line | Kind | Name |
|------|------|------|
| 21 | 🔴 structure | `QubitState where` |
| 27 | 🟡 def | `ket0` |
| 30 | 🟡 def | `ket1` |
| 33 | 🔵 theorem | `qubit_dimension_doubling` |
| 37 | 🔵 theorem | `universe_state_space_lower_bound` |
| 44 | 🟠 noncomputable def | `maximally_mixed_qubit` |
| 47 | 🔵 theorem | `maximally_mixed_trace` |
| 64 | 🔵 theorem | `no_cloning_inner_product_constraint` |
| 70 | 🟡 def | `pauli_X` |
| 71 | 🟡 def | `pauli_Z` |
| 72 | 🟡 def | `pauli_Y` |
| 75 | 🔵 theorem | `pauli_X_squared` |
| 80 | 🔵 theorem | `pauli_Z_squared` |
| 85 | 🔵 theorem | `pauli_Y_squared` |
| 90 | 🔵 theorem | `pauli_XZ_anticommute` |
| 96 | 🔵 theorem | `pauli_XYZ` |
| 105 | 🟡 def | `is_separable_2qubit` |
| 115 | 🔵 theorem | `bell_state_entangled` |
| 122 | 🔵 theorem | `unitary_parameter_count` |
| 127 | 🔵 theorem | `circuit_depth_bound` |
| 137 | 🔵 theorem | `k_local_terms_bound` |
| 144 | 🔵 theorem | `quantum_singleton_bound` |
| 149 | 🔵 theorem | `holographic_entropy_bound` |
| 154 | 🔵 theorem | `simulation_gate_count` |
| 159 | 🟠 noncomputable def | `binary_entropy` |
| 170 | 🔵 theorem | `binary_entropy_half` |
| 178 | 🟡 def | `gate_complexity_lower_bound` |
| 180 | 🔵 theorem | `generic_complexity_bound` |
| 187 | 🔵 theorem | `mutual_information_nonneg` |
| 191 | 🔵 theorem | `strong_subadditivity_consequence` |
| 197 | 🔵 theorem | `universal_decomposition_bound` |
| 201 | 🔵 theorem | `margolus_levitin_discrete` |
| 207 | 🔵 theorem | `quantum_simulation_feasibility` |
| 213 | 🔵 theorem | `tensor_normalized` |
| 228 | 🔵 theorem | `unitary_preserves_trace` |
| 241 | 🔵 theorem | `unitary_mul_unitary` |

---

## Research

### 📄 CrystallizerFormalization.lean

| Line | Kind | Name |
|------|------|------|
| 55 | 🔵 theorem | `stereo_fundamental_identity` |
| 69 | 🔵 theorem | `stereo_proj_nd_unit_norm` |
| 74 | 🔵 theorem | `stereo_denom_nonneg` |
| 78 | 🔵 theorem | `stereo_denom_pos_of_nonzero` |
| 84 | 🟡 def | `crystallizationLoss` |
| 87 | 🔵 theorem | `crystallization_nonneg` |
| 91 | 🔵 theorem | `crystallization_bounded` |
| 96 | 🔵 theorem | `crystallization_vanishes_at_integers` |
| 102 | 🔵 theorem | `total_crystallization_bound` |
| 115 | 🔵 theorem | `crystallization_zero_iff_integer` |
| 124 | 🟡 def | `inner2` |
| 127 | 🟡 def | `normSq2` |
| 130 | 🟡 def | `gramSchmidtProj` |
| 141 | 🔵 theorem | `gram_schmidt_orthogonal` |
| 157 | 🔵 theorem | `spherical_interp_unit` |
| 173 | 🔵 theorem | `tri_resonant_unit` |
| 188 | 🔵 theorem | `crystallized_stereo_rational` |
| 196 | 🔵 theorem | `euclid_parametrization` |
| 204 | 🔵 theorem | `scale_direction_decomposition` |
| 212 | 🔵 theorem | `crystallization_gradient_zero_at_integers` |
| 220 | 🔵 theorem | `stereo_smooth_denominator` |

### 📄 CrystallizerFrontier.lean

| Line | Kind | Name |
|------|------|------|
| 42 | 🔵 theorem | `weierstrass_cos` |
| 57 | 🔵 theorem | `weierstrass_sin` |
| 74 | 🟠 noncomputable def | `inv_stereo` |
| 84 | 🔵 theorem | `stereo_inv_stereo_fst` |
| 98 | 🔵 theorem | `stereo_inv_stereo_snd` |
| 117 | 🟡 def | `pythag_form` |
| 121 | 🔵 theorem | `berggren_A_preserves_form` |
| 126 | 🔵 theorem | `berggren_B_preserves_form` |
| 131 | 🔵 theorem | `berggren_C_preserves_form` |
| 151 | 🔵 theorem | `periodic_loss_max_at_half_int` |
| 164 | 🔵 theorem | `periodic_loss_deriv` |
| 181 | 🔵 theorem | `periodic_loss_grad_zero_half_int` |
| 201 | 🔵 theorem | `rotation_orthogonal` |
| 213 | 🔵 theorem | `rotation_compose` |
| 227 | 🔵 theorem | `rotation_inverse` |
| 252 | 🔵 theorem | `stereo_approx_sin` |
| 297 | 🔵 theorem | `gram_schmidt_idempotent` |
| 316 | 🔵 theorem | `berggren_A_trace` |
| 321 | 🔵 theorem | `berggren_B_trace` |
| 326 | 🔵 theorem | `berggren_C_trace` |
| 332 | 🔵 theorem | `berggren_AB_det` |
| 338 | 🔵 theorem | `berggren_AC_det` |
| 359 | 🔵 theorem | `cos_double_angle` |
| 369 | 🔵 theorem | `sin_double_angle` |
| 379 | 🔵 theorem | `cos_triple_angle` |
| 390 | 🔵 theorem | `chebyshev_recurrence_3` |
| 411 | 🔵 theorem | `stereo_int_rational` |
| 417 | 🔵 theorem | `sum_periodic_loss_nonneg` |
| 431 | 🔵 theorem | `total_periodic_loss_zero_iff` |
| 450 | 🔵 theorem | `berggren_A_applies` |
| 456 | 🔵 theorem | `triple_5_12_13` |
| 459 | 🔵 theorem | `berggren_B_applies` |
| 465 | 🔵 theorem | `triple_21_20_29` |
| 468 | 🔵 theorem | `berggren_C_applies` |
| 474 | 🔵 theorem | `triple_15_8_17` |
| 491 | 🔵 theorem | `periodic_loss_integer_shift` |
| 503 | 🔵 theorem | `periodic_loss_reflection` |

### 📄 CrystallizerMath.lean

| Line | Kind | Name |
|------|------|------|
| 41 | 🔵 theorem | `pythagorean_trig_identity` |
| 45 | 🔵 theorem | `pythagorean_trig_identity'` |
| 62 | 🟠 noncomputable def | `stereo_proj` |
| 66 | 🔵 theorem | `stereo_proj_on_circle` |
| 83 | 🔵 theorem | `gram_schmidt_orthogonal_inner` |
| 101 | 🔵 theorem | `tri_resonant_norm_sq` |
| 123 | 🔵 theorem | `sin_pi_int` |
| 127 | 🔵 theorem | `periodic_loss_nonneg` |
| 132 | 🔵 theorem | `periodic_loss_zero_iff_int` |
| 146 | 🔵 theorem | `norm_sq_scale` |
| 160 | 🔵 theorem | `euclid_from_stereo` |
| 164 | 🔵 theorem | `stereo_rational_on_circle` |
| 177 | 🔵 theorem | `periodic_loss_bounded` |
| 186 | 🔵 theorem | `crystallizer_continuous` |
| 193 | 🔵 theorem | `rotation_det_one` |
| 201 | 🔵 theorem | `stereo_rational_formula` |
| 213 | 🔵 theorem | `berggren_A_det` |
| 218 | 🔵 theorem | `berggren_B_det` |
| 223 | 🔵 theorem | `berggren_C_det` |

### 📄 ExoticComputation.lean

| Line | Kind | Name |
|------|------|------|
| 20 | 🔴 structure | `YangBaxterOperator` |
| 25 | 🟡 def | `braidRepDim` |
| 34 | 🔵 theorem | `braidRepDim_pos` |
| 40 | 🔴 structure | `GraphState` |
| 46 | 🟡 def | `completeGraphState` |
| 59 | 🔵 theorem | `complete_graph_has_neighbors` |
| 75 | 🔵 theorem | `postselection_bounded` |
| 85 | 🔵 theorem | `quantum_search_bound` |
| 92 | 🔵 theorem | `period_finding_qubits` |
| 103 | 🔵 theorem | `crystallizer_topological_bound` |
| 114 | 🔵 theorem | `mbqc_edge_upper_bound` |
| 127 | 🔵 theorem | `descent_error_bound` |
| 139 | 🔵 theorem | `descent_error_monotone` |

### 📄 GravityAI.lean

| Line | Kind | Name |
|------|------|------|
| 30 | 🔴 structure | `Oracle` |
| 35 | 🟡 def | `Oracle.truthSet` |
| 38 | 🔵 theorem | `Oracle.output_is_truth` |
| 41 | 🔵 theorem | `Oracle.is_retraction` |
| 45 | 🔵 theorem | `Oracle.truthSet_eq_range` |
| 51 | 🔵 theorem | `Oracle.iterate_eq` |
| 61 | 🔵 theorem | `Oracle.one_query` |
| 73 | 🔵 theorem | `identity_no_compression` |
| 77 | 🔵 theorem | `constant_oracle_singleton` |
| 81 | 🔵 theorem | `Oracle.truth_set_le_input` |
| 94 | 🔴 structure | `MinkowskiEvent where` |
| 99 | 🟡 def | `MinkowskiEvent.quadForm` |
| 102 | 🟡 def | `MinkowskiEvent.isNull` |
| 104 | 🔵 theorem | `null_iff_pythagorean` |
| 109 | 🔵 theorem | `light_cone_scaling` |
| 114 | 🔵 theorem | `origin_is_null` |
| 117 | 🔵 theorem | `photon_345` |
| 120 | 🔵 theorem | `photon_51213` |
| 123 | 🔵 theorem | `parametric_photon` |
| 127 | 🟡 def | `minkowskiInner` |
| 130 | 🔵 theorem | `null_self_orthogonal` |
| 135 | 🔵 theorem | `sum_null_iff_orthogonal` |
| 150 | 🔴 structure | `BlackHole where` |
| 154 | 🟡 def | `BlackHole.horizonArea` |
| 155 | 🟡 def | `BlackHole.entropy` |
| 156 | 🟡 def | `BlackHole.temperature` |
| 162 | 🔵 theorem | `BlackHole.horizonArea_pos` |
| 170 | 🔵 theorem | `BlackHole.entropy_pos` |
| 178 | 🔵 theorem | `BlackHole.temperature_pos` |
| 182 | 🔵 theorem | `BlackHole.entropy_eq_area_div_4` |
| 190 | 🔵 theorem | `BlackHole.second_law` |
| 200 | 🔵 theorem | `BlackHole.smaller_is_hotter` |
| 209 | 🔵 theorem | `BlackHole.larger_more_entropy` |
| 214 | 🔵 theorem | `redshift_positive` |
| 226 | 🟡 def | `Oracle.commutes` |
| 233 | 🔵 theorem | `Oracle.comp_of_commuting` |
| 240 | 🟡 def | `Oracle.setoid` |
| 244 | 🟡 def | `OracleEquiv` |
| 255 | 🟡 def | `vanillaStep` |
| 256 | 🟡 def | `naturalStep` |
| 260 | 🔵 theorem | `natural_gradient_invariant` |
| 266 | 🔵 theorem | `geodesic_oracle_at_critical` |
| 278 | 🔴 structure | `TwoLayerNet` |
| 282 | 🟡 def | `TwoLayerNet.forward` |
| 289 | 🔵 theorem | `bottleneck_compression` |
| 304 | 🔵 theorem | `numbers_to_light` |
| 308 | 🔵 theorem | `numbers_to_gravity` |
| 311 | 🔵 theorem | `photon_multiplication` |
| 315 | 🔵 theorem | `light_cone_closed_mul` |
| 328 | 🟡 def | `bekensteinBound` |
| 330 | 🔵 theorem | `bekenstein_nonneg` |
| 334 | 🔵 theorem | `bekenstein_radius_scaling` |
| 338 | 🟡 def | `holographicBound` |
| 340 | 🔵 theorem | `holographic_sphere` |
| 348 | 🔵 theorem | `holographic_beats_volume` |
| 360 | 🔵 theorem | `universe_fixed_point` |
| 363 | 🔵 theorem | `strange_loop` |
| 366 | 🔵 theorem | `oracle_determined_by_truth` |
| 373 | 🟡 def | `oracleLE` |
| 376 | 🔵 theorem | `identity_oracle_top` |
| 380 | 🔵 theorem | `double_oracle_same_truth` |
| 404 | 🟡 def | `isSumOfTwoSquares` |
| 406 | 🔵 theorem | `zero_sos` |
| 407 | 🔵 theorem | `one_sos` |
| 408 | 🔵 theorem | `two_sos` |
| 409 | 🔵 theorem | `five_sos` |
| 410 | 🔵 theorem | `twentyfive_sos` |
| 416 | 🔵 theorem | `sos_mul` |
| 424 | 🔵 theorem | `square_sos` |
| 426 | 🔵 theorem | `degenerate_light_cone` |
| 438 | 🔴 structure | `WeightedGraph` |
| 443 | 🟡 def | `WeightedGraph.degree` |
| 446 | 🔵 theorem | `WeightedGraph.degree_nonneg` |
| 450 | 🔵 theorem | `WeightedGraph.totalWeight_eq_sum_degree` |
| 462 | 🟡 def | `compressionDistortion` |
| 465 | 🔵 theorem | `zero_distortion_on_truth` |
| 470 | 🔵 theorem | `identity_zero_distortion` |
| 483 | 🟡 def | `deflectionAngle` |
| 485 | 🔵 theorem | `deflection_pos` |
| 488 | 🟡 def | `einsteinRingRadius` |
| 490 | 🔵 theorem | `einstein_ring_monotone` |
| 506 | 🔵 theorem | `idempotent_eigenvalue` |
| 519 | 🔵 theorem | `idempotent_kernel_part` |
| 525 | 🔵 theorem | `idempotent_image_fixed` |
| 530 | 🔵 theorem | `measurement_binary` |
| 547 | 🔵 theorem | `meta_oracle_stable` |
| 551 | 🔵 theorem | `research_converges` |
| 554 | 🔵 theorem | `gravity_ai_axiom` |
| 564 | 🔵 theorem | `grand_unification` |

### 📄 GravityAITeam.lean

| Line | Kind | Name |
|------|------|------|
| 8 | 🔴 structure | `of the number line itself — the distribution of primes, sum-of-squares` |
| 37 | 🟡 def | `gravWeight` |
| 40 | 🔵 theorem | `gravWeight_one` |
| 43 | 🔵 theorem | `gravWeight_two` |
| 46 | 🔵 theorem | `gravWeight_12_gt_7` |
| 49 | 🔵 theorem | `gravWeight_6` |
| 58 | 🔵 theorem | `gravWeight_prime` |
| 64 | 🟡 def | `gravAttraction` |
| 68 | 🔵 theorem | `gravAttraction_symm` |
| 74 | 🟡 def | `gravPotential` |
| 77 | 🔵 theorem | `gravPotential_six` |
| 80 | 🟡 def | `isGravEquilibrium` |
| 83 | 🔵 theorem | `six_is_equilibrium` |
| 86 | 🔵 theorem | `twentyeight_is_equilibrium` |
| 90 | 🔵 theorem | `four96_is_equilibrium` |
| 103 | 🔴 structure | `GravParticle where` |
| 108 | 🟡 def | `GravParticle.mass` |
| 114 | 🟡 def | `totalMass` |
| 119 | 🟡 def | `gravProject` |
| 123 | 🔵 theorem | `gravProject_of_mul_six` |
| 128 | 🔵 theorem | `gravProject_idempotent_on_image` |
| 133 | 🔵 theorem | `gravProject_zero` |
| 136 | 🔵 theorem | `gravProject_six` |
| 139 | 🔵 theorem | `gravProject_twelve` |
| 152 | 🟡 def | `isGravAttractor` |
| 156 | 🔵 theorem | `attractor_2` |
| 161 | 🔵 theorem | `attractor_4` |
| 166 | 🔵 theorem | `attractor_6` |
| 171 | 🔵 theorem | `attractor_12` |
| 178 | 🟡 def | `isDivisorStable` |
| 180 | 🔵 theorem | `divisor_stable_1` |
| 181 | 🔵 theorem | `divisor_stable_2` |
| 182 | 🔵 theorem | `divisor_stable_6` |
| 183 | 🔵 theorem | `divisor_stable_12` |
| 188 | 🔵 theorem | `gravWeight_multiplicative` |
| 199 | 🟡 def | `gravEnergy` |
| 203 | 🔵 theorem | `gravEnergy_nonpos` |
| 213 | 🟡 def | `godelEncode` |
| 218 | 🔵 theorem | `godelEncode_pos` |
| 223 | 🟡 def | `encodeUniverse` |
| 227 | 🔵 theorem | `encodeUniverse_pos` |
| 231 | 🟡 def | `universeSelfWeight` |
| 235 | 🔵 theorem | `universeSelfWeight_pos` |
| 245 | 🟡 def | `masterOracle` |
| 248 | 🟡 def | `masterOrbit` |
| 253 | 🔵 theorem | `masterOrbit_two` |
| 259 | 🔵 theorem | `masterOracle_fixed_two` |
| 262 | 🔵 theorem | `masterOracle_three` |
| 265 | 🔵 theorem | `masterOracle_attracts_to_two` |
| 275 | 🔵 theorem | `gravWeight_gravWeight_le` |
| 286 | 🔵 theorem | `euler_product_connection` |
| 292 | 🔵 theorem | `oracle_compose_commuting` |
| 303 | 🔵 theorem | `strange_loop` |
| 308 | 🔵 theorem | `every_orbit_cycles` |
| 314 | 🟡 def | `zetaPartialSum` |
| 318 | 🔵 theorem | `zetaPartialSum_nonneg` |

### 📄 GravityOracle.lean

| Line | Kind | Name |
|------|------|------|
| 26 | 🟡 def | `IsGravOracle` |
| 30 | 🟡 def | `GravTruthSet` |
| 34 | 🔵 theorem | `geodesic_oracle_idempotent` |
| 38 | 🔵 theorem | `grav_oracle_output_is_truth` |
| 43 | 🔵 theorem | `grav_truth_set_eq_range` |
| 56 | 🔵 theorem | `grav_oracle_iterate_eq` |
| 62 | 🔵 theorem | `grav_id_is_oracle` |
| 66 | 🔵 theorem | `grav_const_is_oracle` |
| 70 | 🔵 theorem | `universe_is_grav_fixed_point` |
| 76 | 🟡 def | `gravMinkowskiQ` |
| 79 | 🟡 def | `gravIsNull` |
| 82 | 🔵 theorem | `grav_null_iff_pythagorean` |
| 87 | 🔵 theorem | `grav_light_cone_scaling` |
| 92 | 🔵 theorem | `grav_holographic_entropy_nonneg` |
| 96 | 🔵 theorem | `grav_bekenstein_entropy_monotone` |
| 106 | 🔵 theorem | `grav_area_beats_volume` |
| 111 | 🟡 def | `gravSchwarzschildArea` |
| 114 | 🔵 theorem | `grav_schwarzschild_area_nonneg` |
| 120 | 🟡 def | `gravSchwarzschildEntropy` |
| 129 | 🔵 theorem | `grav_black_hole_entropy_monotone` |
| 134 | 🔵 theorem | `grav_redshift_factor_positive` |
| 139 | 🔵 theorem | `grav_redshift_at_horizon` |
| 147 | 🟡 def | `gravMinkowskiInner` |
| 151 | 🔵 theorem | `grav_null_self_orthogonal` |
| 156 | 🔵 theorem | `grav_sum_null_iff_orthogonal` |
| 164 | 🟡 def | `gravLensingDeflection` |
| 167 | 🔵 theorem | `grav_lensing_deflection_pos` |
| 172 | 🔵 theorem | `grav_lensing_monotone_mass` |
| 178 | 🟡 def | `gravEinsteinRingRadius` |
| 181 | 🔵 theorem | `grav_einstein_ring_nonneg` |
| 187 | 🔵 theorem | `grav_pythagorean_is_null` |
| 192 | 🔵 theorem | `grav_parametric_pythagorean` |
| 196 | 🟡 def | `gravDeformedQ` |
| 200 | 🔵 theorem | `grav_flat_spacetime_reduces` |
| 205 | 🔵 theorem | `grav_brahmagupta_fibonacci` |
| 212 | 🔵 theorem | `grav_ricci_flow_converges` |
| 218 | 🔵 theorem | `grav_kss_bound` |
| 221 | 🔵 theorem | `grav_holographic_dim_reduction` |
| 227 | 🔵 theorem | `grav_oracle_preserves_truth` |
| 235 | 🔵 theorem | `grav_bekenstein_bound` |
| 240 | 🔵 theorem | `grav_weak_cosmic_censorship` |
| 244 | 🔵 theorem | `grav_penrose_bound` |
| 248 | 🔵 theorem | `grav_natural_gradient` |
| 251 | 🔵 theorem | `grav_antiparallel_mass` |
| 254 | 🔵 theorem | `grav_bh_compression` |
| 257 | 🟡 def | `gravHawkingTemp` |
| 260 | 🔵 theorem | `grav_hawking_temp_pos` |
| 270 | 🔵 theorem | `grav_smaller_bh_hotter` |
| 281 | 🔵 theorem | `grav_area_monotone` |
| 286 | 🔵 theorem | `grav_one_step_convergence` |
| 290 | 🟡 def | `GravOracleEquiv` |
| 293 | 🔵 theorem | `grav_equiv_refl` |
| 294 | 🔵 theorem | `grav_equiv_symm` |
| 296 | 🔵 theorem | `grav_equiv_trans` |
| 301 | 🔵 theorem | `grav_oracle_density_fin3` |
| 304 | 🔵 theorem | `grav_fundamental_photon` |
| 308 | 🔵 theorem | `grav_photon_5_12_13` |
| 312 | 🔵 theorem | `grav_photon_8_15_17` |

### 📄 HolographicProofs.lean

| Line | Kind | Name |
|------|------|------|
| 28 | 🔴 structure | `ModularProof where` |
| 35 | 🟠 noncomputable def | `holographicRatio` |
| 39 | 🟡 def | `isHolographic` |
| 56 | 🔵 theorem | `area_law_proof` |
| 67 | 🔵 theorem | `area_law_square` |
| 77 | 🔵 theorem | `area_law_compression` |
| 87 | 🔵 theorem | `bulk_boundary_decomposition` |
| 93 | 🔵 theorem | `modular_interface_bound` |
| 106 | 🔵 theorem | `holographic_compression_bound` |
| 119 | 🔴 structure | `ProofTranslation where` |
| 128 | 🟡 def | `ProofTranslation.isCompressing` |
| 132 | 🟡 def | `ProofTranslation.isHolographicCompression` |
| 142 | 🔵 theorem | `compressing_compose` |
| 156 | 🟡 def | `hasWedgeReconstruction` |
| 169 | 🔵 theorem | `monotone_wedge_reconstruction` |

### 📄 HolographicSearch.lean

| Line | Kind | Name |
|------|------|------|
| 35 | 🔴 structure | `BulkBoundaryProof where` |
| 46 | 🟠 noncomputable def | `compressionRatio` |
| 50 | 🟡 def | `isHolographicProof` |
| 62 | 🔴 structure | `PartitionedProof` |
| 71 | 🟠 noncomputable def | `cutSize` |
| 77 | 🟠 noncomputable def | `regionSize` |
| 86 | 🔴 structure | `BoundarySearch where` |
| 95 | 🔴 structure | `BulkSearch where` |
| 108 | 🔵 theorem | `boundary_faster_than_bulk` |
| 123 | 🔴 structure | `EntanglementWedge` |
| 136 | 🔵 theorem | `wedge_monotone` |
| 150 | 🔵 theorem | `full_boundary_full_wedge` |
| 164 | 🟡 def | `isResilient` |
| 176 | 🔵 theorem | `zero_resilient` |
| 183 | 🟡 def | `isStrongResilient` |
| 196 | 🔵 theorem | `resilience_bound` |

### 📄 HomingMissile.lean

| Line | Kind | Name |
|------|------|------|
| 26 | 🔴 structure | `RatCirclePoint where` |
| 34 | 🟡 def | `angularCross` |
| 38 | 🟡 def | `angularDot` |
| 42 | 🔵 theorem | `angularCross_antisymm` |
| 47 | 🔵 theorem | `angularDot_symm` |
| 53 | 🔵 theorem | `angular_pythagorean` |
| 60 | 🟡 def | `angularDistSq` |
| 64 | 🔵 theorem | `angularDistSq_zero_iff` |
| 71 | 🔵 theorem | `angularDistSq_symm` |
| 78 | 🔴 structure | `EuclidParams where` |
| 86 | 🟡 def | `euclidToTriple` |
| 90 | 🔵 theorem | `euclid_is_pythagorean` |
| 96 | 🟡 def | `berggren_M2` |
| 104 | 🟡 def | `berggren_M3` |
| 114 | 🟡 def | `hypot` |
| 117 | 🔵 theorem | `hypot_M2_gt` |
| 123 | 🔵 theorem | `hypot_M3_gt` |
| 131 | 🟡 def | `compassReading` |
| 135 | 🔵 theorem | `compass_root` |
| 149 | 🟡 def | `berggrenParent` |
| 309 | 🟡 def | `gaussNorm` |
| 312 | 🟡 def | `gaussMul` |
| 315 | 🔵 theorem | `gaussNorm_mul` |
| 321 | 🟡 def | `targetAcquired` |
| 335 | 🔵 theorem | `compass_M3_lt_M2` |
| 352 | 🔵 theorem | `compass_M3_decreases` |
| 367 | 🔵 theorem | `compass_in_unit_interval` |
| 372 | 🔵 theorem | `gate_composition_norm` |
| 378 | 🔵 theorem | `M2_hypot_formula` |
| 383 | 🔵 theorem | `M3_hypot_formula` |
| 394 | 🔵 theorem | `compass_M2_lt_one` |
| 409 | 🔵 theorem | `compass_M2_bounded` |
| 415 | 🔵 theorem | `compass_M2_value` |
| 420 | 🔵 theorem | `compass_M3_value` |
| 425 | 🔵 theorem | `compass_M3_bracket` |
| 438 | 🔵 theorem | `factor_from_pyth_triple` |

### 📄 LLMSingleMatMul.lean

| Line | Kind | Name |
|------|------|------|
| 30 | 🔵 theorem | `linear_collapse_two` |
| 40 | 🔵 theorem | `linear_collapse_chain` |
| 58 | 🔵 theorem | `linear_map_is_linear` |
| 65 | 🔵 theorem | `linear_rep_implies_additive` |
| 79 | 🔵 theorem | `relu_not_linear` |
| 93 | 🔵 theorem | `finite_domain_is_matmul` |
| 107 | 🔵 theorem | `onehot_matmul_lookup` |
| 120 | 🔵 theorem | `function_space_cardinality` |
| 133 | 🔴 structure | `PiecewiseAffineDecomp` |
| 151 | 🔵 theorem | `relu_region_upper_bound` |
| 163 | 🔵 theorem | `compiled_degree` |
| 168 | 🔵 theorem | `monomial_count` |
| 180 | 🔵 theorem | `tensor_contraction_order` |
| 197 | 🔵 theorem | `compilation_trilemma_linear_case` |
| 223 | 🔵 theorem | `information_preservation` |
| 229 | 🔵 theorem | `gpt2_info_lower_bound` |
| 242 | 🔵 theorem | `lifted_linear_compilation` |
| 250 | 🔵 theorem | `fin_lifted_compilation` |

### 📄 LandscapeTheory.lean

| Line | Kind | Name |
|------|------|------|
| 35 | 🟡 def | `allRightTriple` |
| 42 | 🟡 def | `allRightPredicted` |
| 46 | 🟡 def | `allRightOddLeg` |
| 49 | 🔵 theorem | `allRightPredicted_pyth` |
| 55 | 🔵 theorem | `allRightOddLeg_factors` |
| 60 | 🔵 theorem | `allRight_base` |
| 64 | 🔵 theorem | `allRight_depth1` |
| 68 | 🔵 theorem | `allRight_depth2` |
| 75 | 🔵 theorem | `pyth_fermat_factorization` |
| 79 | 🔵 theorem | `euclid_odd_leg_factors` |
| 84 | 🔵 theorem | `pyth_leg_factor` |
| 92 | 🟠 noncomputable def | `conformalFactor` |
| 95 | 🔵 theorem | `conformalFactor_pos` |
| 99 | 🔵 theorem | `conformalFactor_le_two` |
| 106 | 🔵 theorem | `conformalFactor_at_zero` |
| 110 | 🔵 theorem | `conformalFactor_symm` |
| 115 | 🔵 theorem | `conformalFactor_antitone` |
| 124 | 🟠 noncomputable def | `stereoParam` |
| 127 | 🔵 theorem | `stereoParam_root` |
| 132 | 🟠 noncomputable def | `invStereoX` |
| 136 | 🟠 noncomputable def | `invStereoY` |
| 139 | 🔵 theorem | `invStereo_on_circle` |
| 148 | 🔵 theorem | `berggren_M1_param` |
| 152 | 🔵 theorem | `berggren_M2_param` |
| 156 | 🔵 theorem | `berggren_M3_param` |
| 162 | 🔵 theorem | `allRight_odd_leg_formula` |
| 167 | 🔵 theorem | `allRight_pyth_formula` |
| 173 | 🔵 theorem | `allRight_divisibility_left` |
| 179 | 🔵 theorem | `allRight_divisibility_right` |
| 187 | 🔵 theorem | `pell_identity` |
| 193 | 🔵 theorem | `pell_recurrence` |
| 198 | 🔵 theorem | `pell_double_step` |
| 205 | 🔵 theorem | `convergent_factor_info` |
| 209 | 🔵 theorem | `convergent_quality` |
| 215 | 🔵 theorem | `brahmagupta_fibonacci_landscape` |
| 220 | 🔵 theorem | `brahmagupta_fibonacci_alt` |
| 227 | 🔵 theorem | `fermat_identity_landscape` |
| 237 | 🔵 theorem | `fermat_from_factors` |
| 244 | 🔵 theorem | `pyth_is_fermat` |
| 257 | 🔵 theorem | `M2_det_is_neg_one` |
| 261 | 🔵 theorem | `silver_ratio_sq_identity` |
| 267 | 🔵 theorem | `lorentz_preservation_M1` |
| 271 | 🔵 theorem | `lorentz_preservation_M2` |
| 275 | 🔵 theorem | `lorentz_preservation_M3` |

### 📄 NNCompilationExtended.lean

| Line | Kind | Name |
|------|------|------|
| 26 | 🔵 theorem | `activation_not_affine` |
| 41 | 🟡 def | `tropMul` |
| 44 | 🟡 def | `tropAdd` |
| 48 | 🔵 theorem | `trop_distrib` |
| 53 | 🔵 theorem | `trop_mul_zero` |
| 57 | 🔵 theorem | `trop_mul_comm` |
| 61 | 🔵 theorem | `trop_mul_assoc` |
| 66 | 🔵 theorem | `trop_add_idem` |
| 70 | 🔵 theorem | `trop_add_comm` |
| 74 | 🔵 theorem | `trop_add_assoc` |
| 80 | 🔵 theorem | `relu_is_trop_add` |
| 87 | 🔵 theorem | `koopman_error_bound` |
| 93 | 🔵 theorem | `koopman_error_unit_norm` |
| 97 | 🟡 def | `koopmanOp` |
| 100 | 🔵 theorem | `koopman_linear_add` |
| 105 | 🔵 theorem | `koopman_linear_smul` |
| 110 | 🔵 theorem | `koopman_compose` |
| 117 | 🔵 theorem | `lookup_exceeds_params` |
| 122 | 🔵 theorem | `gpt2_vocab_squared` |
| 125 | 🔵 theorem | `gpt2_input_space_huge` |
| 130 | 🔵 theorem | `trilemma_no_linear_relu` |
| 139 | 🔵 theorem | `exact_general_achievable` |
| 146 | 🔵 theorem | `gpt2_tt_size` |
| 150 | 🔵 theorem | `tt_exponential_dominates` |
| 157 | 🔵 theorem | `total_activation_patterns` |
| 162 | 🔵 theorem | `region_bound` |
| 169 | 🔵 theorem | `shannon_bits` |
| 173 | 🔵 theorem | `gpt2_bits_per_token` |
| 176 | 🔵 theorem | `gpt2_info_content` |
| 181 | 🔵 theorem | `exp_injective_prop` |
| 184 | 🔵 theorem | `exp_at_zero` |
| 187 | 🔵 theorem | `exp_pos_always` |
| 190 | 🔵 theorem | `exp_not_affine'` |
| 203 | 🔵 theorem | `softmax_sums_one'` |
| 212 | 🔵 theorem | `compiled_poly_degree` |
| 216 | 🔵 theorem | `doubly_exp_growth` |

### 📄 NNCompilationTheory.lean

| Line | Kind | Name |
|------|------|------|
| 29 | 🟠 noncomputable def | `relu` |
| 32 | 🔵 theorem | `relu_nonneg` |
| 36 | 🔵 theorem | `relu_neg` |
| 41 | 🔵 theorem | `relu_not_additive` |
| 49 | 🔵 theorem | `relu_not_affine` |
| 59 | 🔵 theorem | `relu_is_tropical_add` |
| 62 | 🟡 def | `tropical_mul` |
| 65 | 🟡 def | `tropical_add` |
| 68 | 🔵 theorem | `tropical_mul_comm` |
| 72 | 🔵 theorem | `tropical_mul_assoc` |
| 77 | 🔵 theorem | `tropical_add_comm` |
| 81 | 🔵 theorem | `tropical_add_assoc` |
| 88 | 🔵 theorem | `tropical_distrib` |
| 95 | 🔵 theorem | `tropical_mul_zero` |
| 103 | 🔵 theorem | `exp_not_affine` |
| 121 | 🔵 theorem | `softmax_sums_to_one` |
| 134 | 🟡 def | `koopman_operator` |
| 138 | 🔵 theorem | `koopman_additive` |
| 143 | 🔵 theorem | `koopman_smul` |
| 148 | 🔵 theorem | `koopman_is_linear` |
| 157 | 🔵 theorem | `koopman_compose` |
| 163 | 🔵 theorem | `koopman_identity` |
| 174 | 🟠 noncomputable def | `mobius` |
| 185 | 🔵 theorem | `mobius_compose` |
| 200 | 🔴 structure | `CompilationScheme` |
| 207 | 🟡 def | `is_exact` |
| 211 | 🟡 def | `is_compact` |
| 216 | 🔵 theorem | `trilemma_relu_component` |
| 227 | 🔵 theorem | `exact_general_possible` |
| 236 | 🔵 theorem | `region_count_bound` |
| 244 | 🔵 theorem | `tensor_contraction_order'` |
| 249 | 🔵 theorem | `transformer_tensor_order` |
| 254 | 🔵 theorem | `tt_parameter_count` |
| 262 | 🔵 theorem | `gpt2_parameter_info` |
| 266 | 🔵 theorem | `gpt2_lookup_impractical` |
| 273 | 🔵 theorem | `composed_polynomial_degree` |
| 278 | 🔵 theorem | `polynomial_feature_dim` |
| 282 | 🔵 theorem | `koopman_error_linear_accumulation` |
| 290 | 🔵 theorem | `nonlinearity_barrier_core` |

### 📄 NeuralCompilationTeams.lean

| Line | Kind | Name |
|------|------|------|
| 28 | 🟠 noncomputable def | `relu` |
| 38 | 🔵 theorem | `alpha_relu_not_linear` |
| 52 | 🔵 theorem | `alpha_relu_no_exact_linear_approx` |
| 68 | 🔵 theorem | `alpha_linear_determined_by_one` |
| 80 | 🔵 theorem | `alpha_relu_vec_not_linear` |
| 99 | 🔵 theorem | `alpha_linear_composition_is_linear` |
| 115 | 🟠 noncomputable def | `koopmanLinearMap` |
| 146 | 🔵 theorem | `beta_koopman_finite_lift` |
| 165 | 🔵 theorem | `beta_koopman_matrix` |
| 180 | 🔵 theorem | `beta_lifting_dimension_bound` |
| 192 | 🔵 theorem | `beta_quadratic_lifting_dim` |
| 206 | 🟡 def | `tropAdd` |
| 209 | 🟡 def | `tropMul` |
| 218 | 🔵 theorem | `gamma_trop_add_comm` |
| 228 | 🔵 theorem | `gamma_trop_add_assoc` |
| 239 | 🔵 theorem | `gamma_trop_mul_comm` |
| 249 | 🔵 theorem | `gamma_trop_mul_assoc` |
| 261 | 🔵 theorem | `gamma_trop_distrib` |
| 276 | 🔵 theorem | `gamma_relu_is_tropical_add` |
| 282 | 🟠 noncomputable def | `tropMatVec` |
| 294 | 🔵 theorem | `gamma_relu_layer_is_tropical` |
| 308 | 🔵 theorem | `gamma_two_layer_relu` |
| 334 | 🔵 theorem | `delta_exact_compact_not_general` |
| 349 | 🔵 theorem | `delta_exact_general_not_compact` |
| 364 | 🔵 theorem | `delta_compact_general_not_exact` |
| 378 | 🔵 theorem | `delta_trilemma_three_points` |
| 396 | 🔵 theorem | `epsilon_any_function_is_matrix` |
| 408 | 🔵 theorem | `epsilon_onehot_selects_column` |
| 420 | 🔵 theorem | `epsilon_vocabulary_explosion` |
| 431 | 🔵 theorem | `epsilon_modest_explosion` |
| 443 | 🔵 theorem | `epsilon_function_count` |
| 471 | 🔵 theorem | `synthesis_compilation_landscape` |
| 484 | 🔵 theorem | `synthesis_tropical_bridge` |
| 496 | 🔵 theorem | `synthesis_info_bound` |

### 📄 NeuralCrystallizerFrontier.lean

| Line | Kind | Name |
|------|------|------|
| 35 | 🔵 theorem | `crystallization_gradient_zero_at_int` |
| 47 | 🔵 theorem | `crystallization_gradient_zero_at_half_int` |
| 58 | 🔵 theorem | `crystallization_max_at_half_int` |
| 64 | 🔵 theorem | `crystallization_double_angle` |
| 69 | 🔵 theorem | `crystallization_pendulum_potential` |
| 78 | 🔵 theorem | `gaussian_norm_multiplicative_real` |
| 83 | 🔵 theorem | `gaussian_composition_unit` |
| 89 | 🔵 theorem | `triple_gaussian_composition_unit` |
| 98 | 🔵 theorem | `gaussian_composition_assoc` |
| 110 | 🔵 theorem | `rotation_det_is_one` |
| 115 | 🔵 theorem | `rotation_char_poly_discriminant` |
| 128 | 🔵 theorem | `integer_points_in_range` |
| 136 | 🔵 theorem | `inv_stereo_zero` |
| 140 | 🔵 theorem | `inv_stereo_one` |
| 150 | 🔵 theorem | `stereo_round_trip_fst` |
| 161 | 🔵 theorem | `stereo_round_trip_snd` |
| 168 | 🔵 theorem | `euler_four_squares_identity` |
| 176 | 🔵 theorem | `hopf_map_sphere` |
| 183 | 🔵 theorem | `quaternion_composition_sphere` |
| 195 | 🔵 theorem | `unit_vector_bounded_output` |
| 201 | 🔵 theorem | `crystallized_layer_lipschitz` |
| 207 | 🔵 theorem | `deep_lipschitz_bound` |
| 220 | 🔵 theorem | `crystallization_periodic` |
| 228 | 🔵 theorem | `total_crystallization_nonneg` |
| 232 | 🔵 theorem | `total_crystallization_bounded` |
| 242 | 🔵 theorem | `stereo_on_circle` |
| 248 | 🔵 theorem | `stereo_general_unit` |
| 256 | 🔵 theorem | `quantization_error_bound` |
| 261 | 🔵 theorem | `crystallization_at_integer` |
| 272 | 🔵 theorem | `stereo_injective_on_int` |
| 285 | 🔵 theorem | `hopf_fiber_south_pole` |
| 293 | 🔵 theorem | `hopf_fiber_north_pole` |
| 303 | 🔵 theorem | `lyapunov_nonneg` |
| 312 | 🔵 theorem | `lyapunov_zero_iff_equilibrium` |
| 317 | 🔵 theorem | `lyapunov_sum_nonneg` |

### 📄 NeuralFactorSearch.lean

| Line | Kind | Name |
|------|------|------|
| 24 | 🔵 theorem | `four_k_sq_sub_one_eq` |
| 36 | 🔵 theorem | `iof_soundness` |
| 50 | 🔵 theorem | `iof_factor_exists` |
| 65 | 🔵 theorem | `iof_gcd_nontrivial` |
| 80 | 🔵 theorem | `residues_2k_minus_one` |
| 94 | 🔵 theorem | `residues_2k_plus_one` |
| 112 | 🔵 theorem | `iof_hit_count_mod_p` |
| 138 | 🔵 theorem | `iof_loss_independent_of_factors` |

### 📄 OracleAboutOracle.lean

| Line | Kind | Name |
|------|------|------|
| 47 | 🟡 def | `IsOracle` |
| 50 | 🟡 def | `TruthSet` |
| 53 | 🔵 theorem | `oracle_output_is_truth` |
| 58 | 🔵 theorem | `oracle_on_truth_is_id` |
| 63 | 🔵 theorem | `oracle_range_eq_truth` |
| 72 | 🔵 theorem | `oracle_compose_idem` |
| 83 | 🟡 def | `oracleIter` |
| 88 | 🔵 theorem | `oracle_converges_in_one_step` |
| 99 | 🔵 theorem | `truth_set_invariant` |
| 110 | 🔵 theorem | `oracle_compresses` |
| 119 | 🟡 def | `MetaOracle` |
| 123 | 🔵 theorem | `meta_oracle_strange_loop` |
| 132 | 🔵 theorem | `oracle_fixed_point_exists` |
| 141 | 🔵 theorem | `no_universal_truth_oracle` |
| 152 | 🔵 theorem | `godel_diagonal` |
| 162 | 🟡 def | `OracleRefines` |
| 166 | 🔵 theorem | `oracle_refines_refl` |
| 171 | 🔵 theorem | `oracle_refines_trans` |
| 177 | 🔵 theorem | `id_is_weakest_oracle` |
| 182 | 🔵 theorem | `const_is_strong_oracle` |
| 190 | 🟡 def | `oracleEntropyLoss` |
| 194 | 🔵 theorem | `entropy_loss_nonneg` |

### 📄 OracleAlgebra.lean

| Line | Kind | Name |
|------|------|------|
| 32 | 🔵 theorem | `idempotent_pow_eq` |
| 43 | 🔵 theorem | `commuting_idempotents_product` |
| 55 | 🔵 theorem | `idempotent_mul_comm` |
| 69 | 🔵 theorem | `oracle_comp_self` |
| 76 | 🔵 theorem | `id_is_oracle` |
| 82 | 🔵 theorem | `const_is_oracle` |
| 92 | 🔵 theorem | `comp_commuting_oracles` |
| 102 | 🟡 def | `OracleKernel` |
| 108 | 🔵 theorem | `oracle_kernel_refl` |
| 114 | 🔵 theorem | `oracle_kernel_symm` |
| 120 | 🔵 theorem | `oracle_kernel_trans` |
| 128 | 🔵 theorem | `oracle_kernel_equiv` |
| 139 | 🔵 theorem | `fixedPoints_eq_range` |
| 146 | 🔵 theorem | `range_subset_fixedPoints` |
| 153 | 🔵 theorem | `idempotent_injective_iff_surjective` |
| 163 | 🔵 theorem | `oracle_lattice_inf_le` |
| 170 | 🔵 theorem | `oracle_knaster_tarski` |
| 191 | 🔵 theorem | `rectangular_band_prop` |
| 198 | 🔵 theorem | `idempotent_count_base` |
| 204 | 🔵 theorem | `idempotent_count_three` |

### 📄 OracleCompression.lean

| Line | Kind | Name |
|------|------|------|
| 23 | 🟡 def | `IsRetractionV2` |
| 26 | 🔵 theorem | `retraction_is_oracle_v2` |
| 30 | 🔵 theorem | `retraction_range_v2` |
| 38 | 🔵 theorem | `fundamental_pythagorean_v2` |
| 40 | 🔵 theorem | `gcd_oracle_factors_v2` |
| 43 | 🔵 theorem | `gcd_nontrivial_v2` |
| 50 | 🔵 theorem | `factoring_via_gcd_v2` |
| 55 | 🟡 def | `distToTruthV2` |
| 58 | 🔵 theorem | `oracle_reaches_min_v2` |
| 62 | 🔵 theorem | `oracle_reduces_v2` |
| 68 | 🔵 theorem | `contraction_conv_v2` |
| 72 | 🔵 theorem | `contraction_nonneg_v2` |
| 77 | 🔵 theorem | `truth_count_bound_v2` |
| 82 | 🔵 theorem | `compression_triangle_v2` |

### 📄 OracleDimensionReduction.lean

| Line | Kind | Name |
|------|------|------|
| 61 | 🔵 theorem | `constant_is_oracle` |
| 66 | 🔵 theorem | `constant_oracle_fixedPoints` |
| 71 | 🔵 theorem | `constant_range_singleton` |
| 76 | 🔵 theorem | `constant_oracle_card` |
| 83 | 🔴 structure | `OracleSection` |
| 88 | 🟡 def | `canonical_section` |
| 93 | 🔵 theorem | `canonical_section_embedding` |
| 98 | 🔵 theorem | `round_trip` |
| 104 | 🟡 def | `collapse_to_one` |
| 107 | 🔵 theorem | `fin_one_unique` |
| 110 | 🟡 def | `embed_from_one` |
| 114 | 🔵 theorem | `collapse_embed_is_oracle` |
| 121 | 🔵 theorem | `embed_collapse_oracle` |
| 129 | 🟡 def | `oracle_projection` |
| 134 | 🔵 theorem | `oracle_projection_surjective` |
| 139 | 🔵 theorem | `oracle_inclusion_injective` |
| 144 | 🔵 theorem | `oracle_factorization` |
| 151 | 🟡 def | `oracle_refines` |
| 154 | 🔵 theorem | `oracle_refines_refl` |
| 157 | 🔵 theorem | `oracle_refines_trans` |
| 163 | 🔵 theorem | `id_refined_by_all` |
| 169 | 🔵 theorem | `experiment_fin2_one_fixpoint` |
| 175 | 🔵 theorem | `experiment_fin2_two_fixpoints` |
| 181 | 🔵 theorem | `experiment_fin3_one_fixpoint` |
| 187 | 🔵 theorem | `experiment_fin3_two_fixpoints` |
| 193 | 🔵 theorem | `experiment_fin3_three_fixpoints` |
| 200 | 🔵 theorem | `oracle_count_fin3_sum` |
| 203 | 🔵 theorem | `oracle_formula_check_3_1` |
| 204 | 🔵 theorem | `oracle_formula_check_3_2` |
| 205 | 🔵 theorem | `oracle_formula_check_3_3` |
| 216 | 🔵 theorem | `oracle_strict_dimension_reduction` |
| 228 | 🔵 theorem | `one_fixpoint_is_constant` |
| 243 | 🟡 def | `oracle_kernel` |
| 247 | 🔵 theorem | `oracle_kernel_equiv` |
| 253 | 🔵 theorem | `kernel_class_has_unique_fixpoint` |
| 264 | 🔵 theorem | `kernel_classes_eq_fixpoints` |
| 271 | 🟡 def | `oracle_lift` |
| 276 | 🔵 theorem | `lift_right_inverse` |
| 281 | 🔵 theorem | `lift_compose_oracle` |
| 288 | 🔵 theorem | `compatible_oracle_compose` |
| 296 | 🔵 theorem | `minimal_oracle_unique` |
| 304 | 🔵 theorem | `oracle_count_formula_n0` |
| 306 | 🔵 theorem | `oracle_count_formula_n1` |
| 308 | 🔵 theorem | `oracle_count_formula_n2` |
| 310 | 🔵 theorem | `oracle_count_formula_n3` |
| 316 | 🟡 def | `oracle_dimension` |
| 320 | 🔵 theorem | `oracle_dimension_bounds` |
| 336 | 🔵 theorem | `id_oracle_dimension` |
| 341 | 🔵 theorem | `constant_oracle_dimension` |

### 📄 OracleFactoring.lean

| Line | Kind | Name |
|------|------|------|
| 27 | 🔵 theorem | `gcd_idempotent_on_self` |
| 33 | 🔵 theorem | `factor_divides_gcd` |
| 40 | 🔵 theorem | `gcd_nontrivial_factor` |
| 50 | 🔵 theorem | `brahmagupta_fibonacci` |
| 57 | 🔵 theorem | `brahmagupta_fibonacci_alt` |
| 64 | 🔵 theorem | `five_sum_of_squares` |
| 70 | 🔵 theorem | `thirteen_sum_of_squares` |
| 76 | 🔵 theorem | `sixty_five_two_reps` |
| 85 | 🔵 theorem | `fermat_factoring` |
| 92 | 🔵 theorem | `fermat_gives_factors` |
| 101 | 🔵 theorem | `pythagorean_parametrize` |
| 108 | 🔵 theorem | `triple_3_4_5` |
| 114 | 🔵 theorem | `triple_5_12_13` |
| 122 | 🔵 theorem | `composite_has_factor` |
| 129 | 🔵 theorem | `trial_division_bound` |
| 136 | 🔵 theorem | `prime_count_bound` |

### 📄 OracleFixedPoint.lean

| Line | Kind | Name |
|------|------|------|
| 27 | 🔵 theorem | `oracle_contraction_on_range` |
| 35 | 🔵 theorem | `banach_unique_fixed_point` |
| 50 | 🔵 theorem | `knaster_tarski_fixed_point` |
| 65 | 🔵 theorem | `greatest_fixedPoint_char` |
| 74 | 🔵 theorem | `kleene_iteration_monotone` |
| 87 | 🔵 theorem | `cantor_no_surjection` |
| 95 | 🔵 theorem | `diagonal_no_fixpoint` |
| 102 | 🔵 theorem | `russell_paradox_analog` |
| 110 | 🔵 theorem | `y_combinator_prop` |
| 117 | 🔵 theorem | `idempotent_gives_fixedpoint` |
| 124 | 🔵 theorem | `fixedPoints_nonempty_iff` |
| 136 | 🔵 theorem | `idempotent_iterate` |
| 143 | 🔵 theorem | `idempotent_orbit_small` |
| 151 | 🔵 theorem | `idempotent_fixedpoint_count` |

### 📄 OracleHypotheses.lean

| Line | Kind | Name |
|------|------|------|
| 32 | 🔵 theorem | `oracle_density_2` |
| 39 | 🔵 theorem | `id_always_idempotent` |
| 45 | 🔵 theorem | `const_always_idempotent` |
| 54 | 🔵 theorem | `idempotent_eigenvalue` |
| 60 | 🔵 theorem | `idempotent_trace_rank` |
| 68 | 🔵 theorem | `idempotent_real_01` |
| 76 | 🔵 theorem | `mod_idempotent` |
| 82 | 🔵 theorem | `mod_fixedpoints` |
| 89 | 🔵 theorem | `mod_compresses` |
| 95 | 🟡 def | `prime_decidable'` |
| 100 | 🔵 theorem | `wilson_theorem` |
| 108 | 🔵 theorem | `exists_prime_factor` |
| 117 | 🔵 theorem | `coloring_bound` |
| 123 | 🔵 theorem | `complete_graph_colorings` |
| 132 | 🔵 theorem | `entropy_nonneg` |
| 139 | 🔵 theorem | `binary_entropy_bound` |
| 152 | 🔵 theorem | `halting_diagonal` |
| 159 | 🔵 theorem | `cantor_functions` |
| 174 | 🔵 theorem | `finite_dynamics_repeat` |
| 184 | 🔵 theorem | `idempotent_instant_cycle` |

### 📄 OracleInformation.lean

| Line | Kind | Name |
|------|------|------|
| 27 | 🔵 theorem | `oracle_range_card_le` |
| 34 | 🔵 theorem | `non_injective_smaller_range` |
| 46 | 🔵 theorem | `nontrivial_oracle_compresses` |
| 57 | 🔵 theorem | `fixedPoint_mem_range` |
| 64 | 🔵 theorem | `range_mem_fixedPoint` |
| 75 | 🔵 theorem | `fixedPoint_card_eq_range` |
| 84 | 🟡 def | `infoLoss` |
| 94 | 🔵 theorem | `oracle_accounting` |
| 105 | 🔵 theorem | `id_zero_loss` |
| 113 | 🔵 theorem | `oracle_image_nonempty` |
| 120 | 🔵 theorem | `constant_oracle_range` |
| 129 | 🔵 theorem | `semantic_compression_bound` |
| 136 | 🔵 theorem | `log_compression` |
| 143 | 🔵 theorem | `compression_ratio_le_one` |

### 📄 OracleMillennium.lean

| Line | Kind | Name |
|------|------|------|
| 36 | 🟡 def | `isSatisfiable'` |
| 39 | 🔵 theorem | `brute_force_sat'` |
| 42 | 🔵 theorem | `sat_fraction_bound'` |
| 45 | 🔵 theorem | `cook_levin_bound'` |
| 49 | 🔵 theorem | `zeta_2_prefactor` |
| 51 | 🔵 theorem | `pnt_10'` |
| 52 | 🔵 theorem | `pnt_100'` |
| 53 | 🔵 theorem | `pnt_1000'` |
| 55 | 🔵 theorem | `euler_product_check` |
| 56 | 🔵 theorem | `euler_product_check2` |
| 57 | 🔵 theorem | `euler_product_check3` |
| 61 | 🔵 theorem | `sobolev_critical_3d'` |
| 63 | 🔵 theorem | `serrin_condition'` |
| 65 | 🔵 theorem | `energy_dissipation` |
| 73 | 🔵 theorem | `su2_casimir'` |
| 75 | 🔵 theorem | `sun_dim_v2` |
| 81 | 🔴 structure | `RatPoint'` |
| 86 | 🔵 theorem | `five_is_congruent'` |
| 90 | 🔵 theorem | `six_is_congruent'` |
| 96 | 🟡 def | `genus_plane_curve'` |
| 98 | 🔵 theorem | `genus_line'` |
| 99 | 🔵 theorem | `genus_conic'` |
| 100 | 🔵 theorem | `genus_cubic'` |
| 101 | 🔵 theorem | `genus_quartic'` |
| 105 | 🔵 theorem | `s3_euler_char'` |
| 107 | 🟡 def | `euler_char_surface'` |
| 109 | 🔵 theorem | `euler_sphere'` |
| 110 | 🔵 theorem | `euler_torus'` |
| 112 | 🔵 theorem | `bishop_gromov'` |

### 📄 OracleMoonshots.lean

| Line | Kind | Name |
|------|------|------|
| 26 | 🔵 theorem | `fermat_sum_two_sq_5'` |
| 27 | 🔵 theorem | `fermat_sum_two_sq_13'` |
| 28 | 🔵 theorem | `fermat_sum_two_sq_17'` |
| 29 | 🔵 theorem | `fermat_sum_two_sq_29'` |
| 30 | 🔵 theorem | `fermat_sum_two_sq_37'` |
| 32 | 🔵 theorem | `gaussian_factoring_info'` |
| 35 | 🔵 theorem | `brahmagupta_fibonacci_v2` |
| 38 | 🔵 theorem | `brahmagupta_fibonacci_alt` |
| 43 | 🔵 theorem | `proof_compression_ratio'` |
| 52 | 🟡 def | `OraclesAgreeV2` |
| 55 | 🟡 def | `OraclesStronglyAgreeV2` |
| 58 | 🔵 theorem | `strong_agreement_compose'` |
| 68 | 🔵 theorem | `truth_aware_compression'` |
| 73 | 🟡 def | `relu'` |
| 75 | 🔵 theorem | `relu_idem` |
| 79 | 🔵 theorem | `sigmoid_positive` |
| 84 | 🔵 theorem | `nat_self_consistent'` |
| 98 | 🔵 theorem | `grand_unified_oracle'` |

### 📄 OracleNeuralNet.lean

| Line | Kind | Name |
|------|------|------|
| 28 | 🟡 def | `relu` |
| 33 | 🔵 theorem | `relu_idempotent` |
| 39 | 🔵 theorem | `relu_nonneg` |
| 45 | 🔵 theorem | `relu_of_nonneg` |
| 51 | 🔵 theorem | `relu_of_neg` |
| 57 | 🔵 theorem | `relu_fixedPoints` |
| 63 | 🟡 def | `logisticSigmoid` |
| 68 | 🔵 theorem | `logisticSigmoid_range` |
| 74 | 🔵 theorem | `logisticSigmoid_not_idempotent` |
| 83 | 🟡 def | `OraclesAligned` |
| 89 | 🔵 theorem | `alignment_refl` |
| 95 | 🔵 theorem | `alignment_symm` |
| 102 | 🔵 theorem | `alignment_trans` |
| 109 | 🔵 theorem | `id_self_aligned` |
| 115 | 🟡 def | `IsApproxOracle` |
| 121 | 🔵 theorem | `exact_is_approx` |
| 130 | 🔵 theorem | `lipschitz_approx_error` |
| 140 | 🔵 theorem | `relu_n_layers` |
| 147 | 🔵 theorem | `two_layer_relu` |
| 153 | 🔵 theorem | `floor_idempotent` |

### 📄 OracleQuantum.lean

| Line | Kind | Name |
|------|------|------|
| 27 | 🔵 theorem | `grover_speedup` |
| 33 | 🔵 theorem | `grover_probability_bound` |
| 40 | 🔵 theorem | `grover_iterations` |
| 49 | 🔵 theorem | `projection_idempotent` |
| 57 | 🔵 theorem | `projection_eigenvalues` |
| 63 | 🔵 theorem | `measurement_idempotent` |
| 72 | 🔵 theorem | `zeno_effect` |
| 79 | 🔵 theorem | `repeated_projection_converges` |
| 89 | 🔵 theorem | `classical_search_lower_bound` |
| 96 | 🔵 theorem | `quantum_advantage` |
| 103 | 🔵 theorem | `bqp_in_pspace_bound` |
| 111 | 🔵 theorem | `bell_classical_bound` |
| 119 | 🔵 theorem | `tsirelson_bound_approx` |

### 📄 OracleSearch.lean

| Line | Kind | Name |
|------|------|------|
| 38 | 🔵 theorem | `knaster_tarski_lfp` |
| 52 | 🔵 theorem | `lfp_is_le_fixed` |
| 56 | 🔵 theorem | `powerset_fixed_point` |
| 73 | 🔵 theorem | `cantor_no_surjection` |
| 77 | 🔵 theorem | `cantor_diagonal` |
| 83 | 🔵 theorem | `lawvere_fixed_point` |
| 88 | 🔵 theorem | `not_has_no_fixed_point` |
| 99 | 🟡 def | `IsInvolution` |
| 101 | 🔵 theorem | `involution_dichotomy` |
| 105 | 🔵 theorem | `involution_fixed_iff` |
| 109 | 🔵 theorem | `involution_bijective` |
| 113 | 🔵 theorem | `double_negation_involution` |
| 127 | 🔵 theorem | `iteration_fixed_point` |
| 132 | 🟡 def | `IsIdempotent` |
| 134 | 🔵 theorem | `idempotent_range_fixed` |
| 138 | 🔵 theorem | `idempotent_retraction` |
| 149 | 🔵 theorem | `no_self_aware_predicate` |
| 156 | 🔵 theorem | `knowledge_fixed_point` |
| 167 | 🔴 structure | `ClosureOp` |
| 173 | 🔵 theorem | `closure_fixed_iff` |
| 181 | 🔵 theorem | `galois_connection_closure` |
| 186 | 🔵 theorem | `galois_idempotent` |
| 191 | 🔵 theorem | `schroder_bernstein_structure` |
| 212 | 🟡 def | `iterateN` |

### 📄 OracleStrangeLoop.lean

| Line | Kind | Name |
|------|------|------|
| 32 | 🔴 structure | `StrangeLoop` |
| 38 | 🟡 def | `StrangeLoop.meaningSet` |
| 44 | 🔵 theorem | `StrangeLoop.output_in_meaning` |
| 51 | 🔵 theorem | `StrangeLoop.meaning_nonempty` |
| 58 | 🔴 structure | `SelfRef` |
| 67 | 🔵 theorem | `selfref_is_oracle` |
| 77 | 🔵 theorem | `godel_diagonal_abstract` |
| 84 | 🔵 theorem | `no_liar_paradox` |
| 95 | 🔵 theorem | `tarski_diagonal` |
| 105 | 🔵 theorem | `mu_invariant` |
| 111 | 🔵 theorem | `mu_double_preserves` |
| 117 | 🔵 theorem | `mu_subtract_preserves` |
| 124 | 🟡 def | `IsQuine` |
| 129 | 🔵 theorem | `idempotent_produces_quines` |
| 136 | 🔵 theorem | `quines_eq_range` |
| 145 | 🔵 theorem | `tangled_hierarchy_collapse` |
| 155 | 🔵 theorem | `consciousness_fixpoint` |

### 📄 OracleTopology.lean

| Line | Kind | Name |
|------|------|------|
| 34 | 🔵 theorem | `oracle_zero_contraction` |
| 46 | 🔵 theorem | `oracle_orbit_stabilizes` |
| 58 | 🔵 theorem | `oracle_fixedPoints_closed` |
| 68 | 🔵 theorem | `retraction_identity_on_image` |
| 75 | 🔵 theorem | `image_idempotent_stable` |
| 82 | 🔵 theorem | `idempotent_range_identity` |
| 91 | 🔵 theorem | `oracle_sequence_eventually_const` |
| 99 | 🔵 theorem | `oracle_preimage_contains_fixedpoint` |
| 108 | 🔵 theorem | `oracle_fixedPoints_compact` |
| 116 | 🔵 theorem | `oracle_range_compact` |
| 125 | 🔵 theorem | `endo_idempotent_square` |
| 138 | 🔵 theorem | `oracle_comp_assoc` |

### 📄 OracleUnified.lean

| Line | Kind | Name |
|------|------|------|
| 40 | 🔵 theorem | `grand_unified_compression` |
| 49 | 🔵 theorem | `oracle_inj_iff_surj` |
| 60 | 🔵 theorem | `injective_oracle_is_id` |
| 69 | 🔵 theorem | `oracle_monad_return` |
| 75 | 🔵 theorem | `oracle_monad_bind` |
| 88 | 🔵 theorem | `oracle_zeta_finite` |
| 95 | 🔵 theorem | `mobius_inversion_nat` |
| 105 | 🔵 theorem | `oracle_cat_id` |
| 111 | 🔵 theorem | `oracle_cat_comp` |
| 123 | 🔵 theorem | `kl_divergence_nonneg` |
| 131 | 🔵 theorem | `oracle_dimension_reduction` |
| 148 | 🔵 theorem | `math_oracle_em` |
| 154 | 🔵 theorem | `math_oracle_dne` |
| 160 | 🔵 theorem | `prop_oracle_hierarchy` |
| 171 | 🔵 theorem | `three_faces` |
| 181 | 🔵 theorem | `oracle_is_fixpoint_theorem` |
| 188 | 🔵 theorem | `fundamental_oracle_theorem` |

### 📄 OrderClassification.lean

| Line | Kind | Name |
|------|------|------|
| 44 | 🔵 theorem | `order2_trace_zero` |
| 55 | 🔵 theorem | `order2_integer_solutions` |
| 66 | 🔵 theorem | `twoPole_1_neg1` |
| 77 | 🔵 theorem | `twoPole_1_neg1_order2` |
| 138 | 🔵 theorem | `order4_condition` |
| 153 | 🔵 theorem | `order4_case2_solutions` |
| 167 | 🔵 theorem | `order4_case1_solutions` |
| 205 | 🔵 theorem | `no_order3` |
| 241 | 🔵 theorem | `no_order6` |
| 301 | 🔵 theorem | `rotation_angle_rational` |

### 📄 ProofEntanglement.lean

| Line | Kind | Name |
|------|------|------|
| 32 | 🔴 structure | `ProofGraph` |
| 41 | 🟡 def | `ProofGraph.inDegree` |
| 46 | 🟡 def | `ProofGraph.outDegree` |
| 51 | 🟡 def | `ProofGraph.isIndependent` |
| 55 | 🟡 def | `ProofGraph.isLinear` |
| 65 | 🟠 noncomputable def | `shannonEntropy` |
| 75 | 🔵 theorem | `entropy_uniform` |
| 87 | 🔵 theorem | `entropy_point_mass` |
| 98 | 🔵 theorem | `entropy_nonneg` |
| 109 | 🟠 noncomputable def | `dependencyWeight` |
| 115 | 🟠 noncomputable def | `proofEntanglement` |
| 129 | 🔵 theorem | `independent_zero_entanglement` |
| 141 | 🔵 theorem | `max_entanglement_is_log` |
| 154 | 🔵 theorem | `shannonEntropy_nonneg_of_sum_one` |
| 175 | 🔵 theorem | `independent_description_additive` |
| 187 | 🔵 theorem | `compression_lower_bound` |

### 📄 RepulsorTheory.lean

| Line | Kind | Name |
|------|------|------|
| 60 | 🔵 theorem | `diagonal_evasion` |
| 67 | 🟡 def | `diagonal_evader` |
| 74 | 🔵 theorem | `diagonal_evader_evades` |
| 82 | 🟡 def | `iterated_evader` |
| 95 | 🔵 theorem | `iterated_evaders_all_distinct` |
| 119 | 🔵 theorem | `cantor_evasion` |
| 124 | 🟡 def | `evading_set` |
| 131 | 🔵 theorem | `evading_set_evades` |
| 145 | 🟡 def | `remaining_positions` |
| 159 | 🔵 theorem | `remaining_positions_card` |
| 178 | 🔵 theorem | `evader_survives_linear` |
| 203 | 🔵 theorem | `countable_search_misses_almost_all` |
| 218 | 🔵 theorem | `baire_evasion` |
| 239 | 🔵 theorem | `generic_evasion` |
| 264 | 🔵 theorem | `remaining_uncertainty_lower_bound` |
| 278 | 🔵 theorem | `pigeonhole_evasion` |
| 294 | 🔵 theorem | `adaptive_evader_wins` |
| 319 | 🔵 theorem | `existence_of_total_avoider` |
| 333 | 🔵 theorem | `no_universal_enumeration` |
| 347 | 🔵 theorem | `evasion_set_nonempty` |
| 359 | 🔵 theorem | `infinite_evasion_finite_range` |
| 367 | 🔵 theorem | `(repulsor existence) in a complementary structure.` |
| 380 | 🔵 theorem | `finite_repulsor` |
| 394 | 🔵 theorem | `antitone_fixed_point_unique` |
| 416 | 🔵 theorem | `displacement_repulsor` |
| 446 | 🔵 theorem | `search_asymmetry` |
| 460 | 🟡 def | `evades_at_level` |
| 467 | 🔵 theorem | `level_k_evader_exists` |
| 475 | 🔵 theorem | `level_hierarchy_strict` |
| 489 | 🔵 theorem | `infinite_repulsor_exists` |
| 526 | 🔵 theorem | `prob_evasion_bound` |
| 540 | 🔵 theorem | `repulsor_completion` |
| 558 | 🔵 theorem | `negation_is_repulsor` |
| 570 | 🔵 theorem | `successor_is_repulsor` |
| 584 | 🔵 theorem | `mutual_repulsion_exists` |

### 📄 RepulsorTheoryExtended.lean

| Line | Kind | Name |
|------|------|------|
| 29 | 🟡 def | `IsRepulsor'` |
| 33 | 🔵 theorem | `repulsor_exists_diagonal'` |
| 38 | 🔵 theorem | `repulsor_family'` |
| 43 | 🔵 theorem | `repulsor_family_injective'` |
| 49 | 🔵 theorem | `repulsor_abundance'` |
| 59 | 🟡 def | `diagEvader` |
| 62 | 🟡 def | `diagTower` |
| 67 | 🔵 theorem | `diagTower_gt_base` |
| 74 | 🔵 theorem | `diagTower_strict_mono` |
| 86 | 🔵 theorem | `diagTower_injective` |
| 95 | 🔵 theorem | `diagTower_evades` |
| 102 | 🟡 def | `IsFixedPointFree'` |
| 105 | 🔵 theorem | `fpf_composition_increasing` |
| 111 | 🔵 theorem | `succ_iter_eq` |
| 117 | 🔵 theorem | `succ_iterate_fpf'` |
| 122 | 🔵 theorem | `shift_closure` |
| 129 | 🟡 def | `IsOracle'` |
| 132 | 🟡 def | `IsRepulsorPt'` |
| 135 | 🔵 theorem | `oracle_repulsor_partition'` |
| 140 | 🔵 theorem | `oracle_repulsor_complement'` |
| 147 | 🟡 def | `mixedOracleRepulsor` |
| 150 | 🔵 theorem | `mixed_oracle_even` |
| 154 | 🔵 theorem | `mixed_repulsor_odd` |
| 161 | 🟡 def | `evasionSet` |
| 165 | 🔵 theorem | `total_repulsor_evasion` |
| 172 | 🟡 def | `remainingPositions` |
| 175 | 🔵 theorem | `searcher_deficit'` |
| 180 | 🔵 theorem | `query_monotone'` |
| 185 | 🔵 theorem | `last_query_essential'` |
| 199 | 🟡 def | `IsWandering'` |
| 203 | 🔵 theorem | `succ_wandering'` |
| 207 | 🔵 theorem | `shift_iterate` |
| 213 | 🔵 theorem | `shift_wandering'` |
| 218 | 🔵 theorem | `fixed_iterate'` |
| 225 | 🔵 theorem | `fixed_not_wandering'` |
| 231 | 🔵 theorem | `doubling_iterate'` |
| 243 | 🔵 theorem | `doubling_wandering'` |
| 257 | 🔵 theorem | `monotone_orbit_dichotomy'` |
| 274 | 🔵 theorem | `cantor_diagonal'` |
| 279 | 🔵 theorem | `cantor_repulsor'` |
| 285 | 🔵 theorem | `zoo_successor` |
| 288 | 🔵 theorem | `zoo_squaring` |
| 294 | 🔵 theorem | `zoo_fib_shift` |
| 297 | 🔵 theorem | `zoo_polynomial` |
| 302 | 🔵 theorem | `product_repulsor'` |
| 311 | 🟡 def | `levelRepulsor` |
| 314 | 🔵 theorem | `levelRepulsor_fpf` |
| 318 | 🔵 theorem | `levelRepulsor_increasing` |
| 323 | 🔵 theorem | `levelRepulsor_strict` |
| 330 | 🔵 theorem | `repulsor_extension'` |
| 341 | 🔵 theorem | `total_repulsor_exists'` |
| 348 | 🔵 theorem | `grand_evasion_principle'` |
| 355 | 🔵 theorem | `negation_repulsor'` |
| 358 | 🔵 theorem | `derangement_total` |
| 370 | 🔵 theorem | `monotone_fin_fixed_point'` |
| 387 | 🟡 def | `displacement` |
| 390 | 🔵 theorem | `positive_displacement_fpf` |
| 395 | 🔵 theorem | `negative_displacement_fpf` |
| 400 | 🟡 def | `totalDisplacement` |
| 404 | 🔵 theorem | `succ_total_displacement'` |
| 409 | 🔵 theorem | `shift_total_displacement'` |
| 416 | 🔵 theorem | `infinite_evades_finite` |
| 421 | 🔵 theorem | `two_evade_finite` |
| 431 | 🟡 def | `evasionDepth` |
| 436 | 🔵 theorem | `evasionDepth_mono` |
| 441 | 🔵 theorem | `diagEvader_infinite_depth` |
| 450 | 🟡 def | `minDisplacement` |
| 455 | 🟡 def | `StrongerRepulsor` |
| 459 | 🔵 theorem | `strongerRepulsor_refl` |
| 463 | 🔵 theorem | `strongerRepulsor_trans` |
| 469 | 🔵 theorem | `levelRepulsor_stronger` |

### 📄 SciFiMathematics.lean

| Line | Kind | Name |
|------|------|------|
| 38 | 🔵 theorem | `koch_dimension_equation` |
| 49 | 🔵 theorem | `log_three_pos` |
| 59 | 🔵 theorem | `log_four_pos` |
| 71 | 🔵 theorem | `koch_dimension_irrational` |
| 103 | 🔵 theorem | `hyperbolic_area_lower_bound` |
| 120 | 🔵 theorem | `cosh_ge_one` |
| 138 | 🔵 theorem | `quaternion_norm_mul` |
| 160 | 🔵 theorem | `marchenko_pastur_edge` |
| 181 | 🔵 theorem | `det_mul_transpose_sq` |
| 198 | 🔵 theorem | `koch_self_similarities` |
| 209 | 🔵 theorem | `koch_piece_length` |
| 222 | 🔵 theorem | `koch_length_diverges` |

### 📄 SearchTheory.lean

| Line | Kind | Name |
|------|------|------|
| 38 | 🟡 def | `SearchStrategy` |
| 42 | 🟡 def | `searchImage` |
| 47 | 🔴 structure | `Attractor` |
| 54 | 🔴 structure | `Repulsor` |
| 64 | 🔵 theorem | `attractor_identity_surjective` |
| 69 | 🔵 theorem | `infinite_set_searchable` |
| 75 | 🔵 theorem | `attractor_exists_for_infinite` |
| 88 | 🔵 theorem | `finite_evasion` |
| 95 | 🔵 theorem | `evasion_bound` |
| 104 | 🔵 theorem | `evasion_pigeonhole` |
| 121 | 🔵 theorem | `diagonal_avoidance` |
| 129 | 🔵 theorem | `cantor_repulsor` |
| 143 | 🔵 theorem | `evasion_game_round` |
| 150 | 🔵 theorem | `search_monotone` |
| 156 | 🔵 theorem | `evasion_set_nonempty` |
| 166 | 🔵 theorem | `no_fixed_repulsor` |
| 175 | 🔵 theorem | `repulsor_requires_adaptation` |
| 182 | 🔵 theorem | `complement_evasion` |
| 192 | 🔵 theorem | `safe_positions_count` |
| 200 | 🔵 theorem | `evasion_ratio` |
| 206 | 🔵 theorem | `evasion_ratio_decreasing` |
| 221 | 🔵 theorem | `search_duality` |
| 233 | 🔵 theorem | `meta_evasion` |
| 247 | 🔵 theorem | `repulsor_exists_bool_functions` |

### 📄 StrangeLoops.lean

| Line | Kind | Name |
|------|------|------|
| 26 | 🔵 theorem | `lawvere_fp` |
| 37 | 🔴 structure | `GodelSentenceV2` |
| 43 | 🔵 theorem | `godel_incompleteness_v2` |
| 52 | 🔵 theorem | `pow2_not_div3'` |
| 57 | 🔵 theorem | `double_preserves_mod3'` |
| 59 | 🔵 theorem | `sub3_preserves_mod3'` |
| 64 | 🔵 theorem | `no_self_negating_prop'` |
| 68 | 🔵 theorem | `grelling_paradox_v2` |
| 75 | 🔵 theorem | `strange_loop_compose_v2` |
| 79 | 🔵 theorem | `observer_stabilizes` |
| 84 | 🔵 theorem | `observer_convergence'` |
| 97 | 🔵 theorem | `tarski_undefinability'` |
| 108 | 🔵 theorem | `self_application_surj` |

### 📄 TheorySpaceGeodesics.lean

| Line | Kind | Name |
|------|------|------|
| 35 | 🟣 class | `ExtendedTheorySpace` |
| 48 | 🟡 def | `TheoryPath` |
| 52 | 🟡 def | `isGeodesic` |
| 58 | 🟠 noncomputable def | `geodesicEndpoints` |
| 64 | 🟡 def | `isMetricMidpoint` |
| 74 | 🔵 theorem | `midpoint_half_dist` |
| 86 | 🔵 theorem | `midpoint_no_detour` |
| 92 | 🟡 def | `isUniquelyGeodesic` |
| 103 | 🔴 structure | `TheoryInterpolation` |
| 115 | 🟠 noncomputable def | `interpolationLength` |
| 126 | 🔵 theorem | `interpolation_length_bound` |
| 137 | 🟠 noncomputable def | `metricTriangleDefect` |
| 147 | 🔵 theorem | `metricTriangleDefect_nonneg` |
| 158 | 🔵 theorem | `zero_defect_on_geodesic` |
| 170 | 🔴 structure | `PhysicalTheory where` |
| 180 | 🟠 noncomputable def | `theoryDist` |
| 185 | 🔵 theorem | `theoryDist_nonneg` |
| 195 | 🔵 theorem | `theoryDist_self` |
| 205 | 🔵 theorem | `theoryDist_symm` |
| 209 | 🟠 noncomputable def | `GR` |
| 216 | 🟠 noncomputable def | `QFT` |
| 223 | 🟠 noncomputable def | `QuantumGravity` |
| 236 | 🔵 theorem | `GR_QFT_distance` |
| 247 | 🔵 theorem | `QG_equidistant` |

### 📄 TheorySpaceMetric.lean

| Line | Kind | Name |
|------|------|------|
| 28 | 🟣 class | `TheorySpace` |
| 45 | 🔵 theorem | `simCost_is_pseudometric` |
| 58 | 🟡 def | `isDual` |
| 68 | 🔵 theorem | `isDual_refl` |
| 78 | 🔵 theorem | `isDual_symm` |
| 88 | 🔵 theorem | `isDual_trans` |
| 104 | 🔵 theorem | `isDual_equivalence` |
| 122 | 🟡 def | `isMidpoint` |
| 133 | 🔵 theorem | `midpoint_optimal` |
| 146 | 🔵 theorem | `midpoint_half_distance` |
| 165 | 🔵 theorem | `simulation_cost_from_expressiveness` |
| 178 | 🔵 theorem | `expressiveness_gap_nonneg` |
| 192 | 🟠 noncomputable def | `triangleDefect` |
| 202 | 🔵 theorem | `triangleDefect_nonneg` |
| 213 | 🔵 theorem | `zero_defect_geodesic` |

---

## Stereographic

### 📄 CMBLandscape.lean

| Line | Kind | Name |
|------|------|------|
| 27 | 🟠 noncomputable def | `pythagorean_energy_density` |
| 39 | 🔵 theorem | `pythagorean_energy_density_bound` |
| 51 | 🔵 theorem | `energy_density_345` |
| 62 | 🔵 theorem | `pythagorean_696_697_985` |
| 73 | 🔵 theorem | `most_energy_rich_comparison` |
| 81 | 🟠 noncomputable def | `inverse_stereo` |
| 94 | 🔵 theorem | `inverse_stereo_on_sphere` |
| 109 | 🔵 theorem | `inverse_stereo_origin` |
| 116 | 🟠 noncomputable def | `inverse_stereo_1d` |
| 121 | 🟠 noncomputable def | `pythagorean_rational_point` |
| 136 | 🔵 theorem | `stereo_pyth_correspondence` |
| 146 | 🟠 noncomputable def | `energy_euclid` |
| 151 | 🟠 noncomputable def | `energy_ratio` |
| 161 | 🔵 theorem | `energy_euclid_eq_ratio` |
| 176 | 🔵 theorem | `two_mul_le_sq_add_sq` |
| 182 | 🟠 noncomputable def | `silver_ratio` |
| 185 | 🟠 noncomputable def | `optimal_ratio` |
| 194 | 🔵 theorem | `optimal_ratio_eq_inv_silver` |

### 📄 DimensionalProjection.lean

| Line | Kind | Name |
|------|------|------|
| 58 | 🟡 def | `stereoForward1` |
| 61 | 🟡 def | `invStereo1` |
| 65 | 🔵 theorem | `inv_stereo_1d_on_circle` |
| 72 | 🔵 theorem | `stereo_round_trip_from_R` |
| 85 | 🔵 theorem | `stereo_round_trip_from_S1_fst` |
| 97 | 🔵 theorem | `stereo_round_trip_from_S1_snd` |
| 107 | 🟡 def | `stereoForward2` |
| 113 | 🟡 def | `invStereo2` |
| 118 | 🔵 theorem | `inv_stereo_2d_on_sphere` |
| 126 | 🔵 theorem | `stereo_2d_round_trip_fst` |
| 133 | 🔵 theorem | `stereo_2d_round_trip_snd` |
| 143 | 🟡 def | `invStereo3` |
| 152 | 🔵 theorem | `inv_stereo_3d_on_sphere` |
| 163 | 🔵 theorem | `stereo_general_unit_norm` |
| 175 | 🟡 def | `liftRtoS2` |
| 181 | 🔵 theorem | `lift_R_to_S2_on_sphere` |
| 190 | 🔵 theorem | `rational_stereo_rational_circle` |
| 198 | 🔵 theorem | `rational_circle_pythagorean` |
| 206 | 🔵 theorem | `two_squares_identity` |
| 210 | 🔵 theorem | `three_squares_from_pythagorean` |
| 216 | 🔵 theorem | `four_squares_identity` |
| 238 | 🔵 theorem | `hopf_map_on_sphere` |
| 244 | 🔵 theorem | `hopf_fiber_south_pole` |
| 255 | 🔵 theorem | `stereo_2d_jacobian_positive` |
| 261 | 🔵 theorem | `stereo_conformal_factor_positive` |
| 267 | 🔵 theorem | `north_pole_not_in_image` |
| 283 | 🔵 theorem | `every_non_north_pole_in_image` |
| 292 | 🔵 theorem | `iterated_stereo_image` |
| 300 | 🔵 theorem | `stereo_rotation_at_east` |
| 311 | 🔵 theorem | `inv_stereo_1d_injective` |
| 324 | 🔵 theorem | `inv_stereo_2d_injective` |

### 📄 InverseStereoMobius.lean

| Line | Kind | Name |
|------|------|------|
| 31 | 🟡 def | `poleMap` |
| 34 | 🔵 theorem | `one_plus_sq_pos'` |
| 37 | 🔵 theorem | `pole_map_at_zero` |
| 48 | 🔵 theorem | `pole_map_involution` |
| 63 | 🔵 theorem | `pole_map_antipodal` |
| 71 | 🟡 def | `twoPoleMap` |
| 81 | 🔵 theorem | `two_pole_same_is_id` |
| 87 | 🔵 theorem | `two_pole_det_identity` |
| 93 | 🔵 theorem | `two_pole_det_factored` |
| 103 | 🔵 theorem | `two_pole_reverse_inverse` |
| 111 | 🔵 theorem | `two_pole_south_east` |
| 116 | 🔵 theorem | `two_pole_01_at_zero` |
| 121 | 🔵 theorem | `two_pole_01_at_neg_one` |
| 126 | 🔵 theorem | `two_pole_01_at_two` |
| 131 | 🔵 theorem | `two_pole_01_at_three` |
| 143 | 🔵 theorem | `two_pole_composition_formula` |
| 161 | 🔵 theorem | `integer_map_necessary` |
| 174 | 🔵 theorem | `integer_map_weak_criterion` |
| 184 | 🔵 theorem | `two_pole_det_identity_int` |
| 190 | 🔵 theorem | `two_pole_det_factored_int` |
| 194 | 🔵 theorem | `det_south_east` |
| 197 | 🔵 theorem | `det_one_two` |
| 200 | 🔵 theorem | `det_two_three` |
| 203 | 🔵 theorem | `one_plus_sq_pos_int` |
| 208 | 🔵 theorem | `chain_01_2_num` |
| 209 | 🔵 theorem | `chain_01_2_den` |
| 210 | 🔵 theorem | `chain_01_2` |
| 213 | 🔵 theorem | `chain_01_3_num` |
| 214 | 🔵 theorem | `chain_01_3_den` |
| 215 | 🔵 theorem | `chain_01_3` |
| 218 | 🔵 theorem | `chain_12_1` |
| 222 | 🔵 theorem | `chain_12_2` |
| 226 | 🔵 theorem | `chain_13_1` |
| 230 | 🔵 theorem | `chain_13_3` |
| 234 | 🔵 theorem | `chain_13_neg3` |
| 241 | 🔵 theorem | `gaussian_norm_connection` |
| 245 | 🔵 theorem | `brahmagupta_from_poles` |
| 251 | 🔵 theorem | `all_integer_poles_elliptic` |
| 262 | 🔵 theorem | `two_pole_01_order_four` |
| 274 | 🔵 theorem | `two_pole_01_squared` |
| 281 | 🔵 theorem | `eigenvalue_gaussian_factorization` |
| 286 | 🔵 theorem | `pythagorean_from_poles_1_2` |
| 292 | 🔵 theorem | `south_east_elliptic` |

### 📄 InverseStereoMobiusNext.lean

| Line | Kind | Name |
|------|------|------|
| 32 | 🟡 def | `twoPole_den` |
| 35 | 🟡 def | `twoPole_num` |
| 38 | 🟡 def | `twoPole_det` |
| 42 | 🔵 theorem | `complete_criterion_forward` |
| 55 | 🔵 theorem | `complete_criterion_backward` |
| 66 | 🔵 theorem | `den_num_linear_relation` |
| 73 | 🔵 theorem | `divisor_bound` |
| 89 | 🔵 theorem | `den_injective` |
| 102 | 🔵 theorem | `integer_inputs_finite_set` |
| 115 | 🟡 def | `mobiusMatrix` |
| 125 | 🔵 theorem | `mobius_matrix_det` |
| 137 | 🔵 theorem | `mobius_matrix_trace` |
| 148 | 🔵 theorem | `mobius_elliptic` |
| 163 | 🔵 theorem | `orbit_pairing` |
| 182 | 🔵 theorem | `no_integer_fixed_points` |
| 195 | 🔵 theorem | `gaussian_norm_multiplicative` |
| 200 | 🔵 theorem | `gaussian_norm_multiplicative_alt` |
| 205 | 🔵 theorem | `det_two_representations` |
| 211 | 🔵 theorem | `det_pos` |
| 221 | 🔵 theorem | `det_eq_two` |
| 233 | 🔵 theorem | `F01_at_0` |
| 236 | 🔵 theorem | `F01_at_neg1` |
| 239 | 🔵 theorem | `F01_at_2` |
| 243 | 🔵 theorem | `F10_at_neg3` |
| 247 | 🔵 theorem | `F01_orbit_2_neg3` |
| 253 | 🔵 theorem | `F01_orbit_0_1` |
| 262 | 🔵 theorem | `pythagorean_from_poles` |
| 266 | 🔵 theorem | `poles_1_2_sum_of_squares` |
| 270 | 🔵 theorem | `poles_1_3_sum_of_squares` |
| 274 | 🔵 theorem | `poles_2_3_sum_of_squares` |
| 278 | 🔵 theorem | `poles_0_k_trivial` |
| 284 | 🔵 theorem | `factor_50_recovery` |
| 288 | 🔵 theorem | `fifty_two_reps` |

### 📄 InverseStereoResearch.lean

| Line | Kind | Name |
|------|------|------|
| 60 | 🟡 def | `invStereo` |
| 65 | 🔵 theorem | `inv_stereo_on_circle` |
| 74 | 🔵 theorem | `inv_stereo_denom_pos` |
| 77 | 🔵 theorem | `inv_stereo_at_zero` |
| 81 | 🔵 theorem | `inv_stereo_at_one` |
| 85 | 🔵 theorem | `inv_stereo_at_neg_one` |
| 90 | 🔵 theorem | `inv_stereo_symmetry` |
| 98 | 🔵 theorem | `inv_stereo_double_angle_identity` |
| 109 | 🔵 theorem | `inv_stereo_injective` |
| 126 | 🔵 theorem | `stereo_denominator_sum_squares` |
| 132 | 🔵 theorem | `stereo_rational_first_coord` |
| 141 | 🔵 theorem | `stereo_rational_second_coord` |
| 150 | 🔵 theorem | `euclid_pythagorean_from_stereo` |
| 156 | 🔵 theorem | `stereo_gcd_factor_extraction` |
| 169 | 🔵 theorem | `brahmagupta_fibonacci_identity` |
| 175 | 🔵 theorem | `brahmagupta_fibonacci_alt` |
| 183 | 🔵 theorem | `bloch_stereo_norm` |
| 189 | 🔵 theorem | `pauli_x_squared` |
| 194 | 🔵 theorem | `pauli_z_squared` |
| 201 | 🔵 theorem | `gaussian_det` |
| 207 | 🔵 theorem | `gaussian_matrix_compose` |
| 214 | 🔵 theorem | `gaussian_det_multiplicative` |
| 221 | 🔵 theorem | `rotation_trace_formula` |
| 228 | 🔵 theorem | `stereo_no_compression` |
| 232 | 🔵 theorem | `crystallization_loss_nonneg` |
| 235 | 🔵 theorem | `crystallization_loss_bounded` |
| 240 | 🔵 theorem | `crystallization_at_integers` |
| 248 | 🔵 theorem | `crystallized_weight_pythagorean` |
| 254 | 🔵 theorem | `universal_compression_impossible'` |
| 264 | 🔵 theorem | `total_crystallization_bounded` |
| 274 | 🔵 theorem | `stereo_lightlike` |
| 279 | 🔵 theorem | `mobius_det_condition` |
| 285 | 🔵 theorem | `mobius_compose_det` |
| 293 | 🔵 theorem | `berggren_A_lorentz_explicit` |
| 301 | 🔵 theorem | `berggren_B_lorentz_explicit` |
| 309 | 🔵 theorem | `berggren_C_lorentz_explicit` |
| 320 | 🔵 theorem | `critical_strip_reflection` |
| 325 | 🔵 theorem | `stereo_critical_line` |
| 330 | 🔵 theorem | `prime_count_100_research` |
| 336 | 🔵 theorem | `sum_two_sq_primes_count` |
| 343 | 🔵 theorem | `sum_two_sq_primes_mod4_count` |
| 348 | 🔵 theorem | `factor_verification` |
| 357 | 🔵 theorem | `inverse_stereo_rosetta_stone` |
| 369 | 🔵 theorem | `euler_product_partial` |
| 374 | 🔵 theorem | `euler_product_partial_reciprocal` |
| 381 | 🔵 theorem | `modular_S_squared` |
| 386 | 🔵 theorem | `modular_T_det` |
| 391 | 🔵 theorem | `modular_ST_product` |
| 396 | 🔵 theorem | `modular_ST_cubed` |

### 📄 SphericalCombination.lean

| Line | Kind | Name |
|------|------|------|
| 30 | 🔵 theorem | `cos_sq_add_sin_sq_eq_one'` |
| 50 | 🔵 theorem | `spherical_combination_norm_sq` |
| 62 | 🔵 theorem | `spherical_combination_expanded` |
| 82 | 🔵 theorem | `gram_schmidt_orthogonality` |
| 93 | 🔵 theorem | `gram_schmidt_inner_product_zero` |

### 📄 StereographicDecoder.lean

| Line | Kind | Name |
|------|------|------|
| 45 | 🔵 theorem | `one_square_identity` |
| 58 | 🔵 theorem | `two_square_identity` |
| 73 | 🔵 theorem | `four_square_identity` |
| 92 | 🔵 theorem | `eight_square_identity` |
| 132 | 🟠 noncomputable def | `stereo_proj` |
| 137 | 🟠 noncomputable def | `inv_stereo_proj` |
| 147 | 🔵 theorem | `inv_stereo_on_circle` |
| 165 | 🔵 theorem | `rational_stereo_gives_pyth` |

### 📄 StereographicProjection.lean

| Line | Kind | Name |
|------|------|------|
| 43 | 🔵 theorem | `stereo_proj_2d_unit_norm` |
| 57 | 🔵 theorem | `stereo_identity` |
| 70 | 🔵 theorem | `inverse_stereo_first_component` |
| 84 | 🔵 theorem | `inverse_stereo_second_component` |
| 106 | 🔵 theorem | `stereo_proj_unit_norm_general` |

### 📄 StereographicRationals.lean

| Line | Kind | Name |
|------|------|------|
| 28 | 🟠 noncomputable def | `stereoX` |
| 31 | 🟠 noncomputable def | `stereoY` |
| 34 | 🟢 lemma | `one_plus_sq_pos` |
| 38 | 🟢 lemma | `one_plus_sq_ne_zero` |
| 49 | 🔵 theorem | `stereo_on_circle` |
| 63 | 🔵 theorem | `stereo_injective` |
| 68 | 🟠 noncomputable def | `stereoInv` |
| 77 | 🔵 theorem | `stereo_inv_left` |
| 92 | 🟡 def | `pythagorean_from_params` |
| 102 | 🔵 theorem | `pythagorean_triple_parametric` |
| 116 | 🟠 noncomputable def | `circleAdd` |
| 127 | 🔵 theorem | `circle_add_stereo_x` |
| 139 | 🔵 theorem | `circle_add_stereo_y` |
| 158 | 🟠 noncomputable def | `ratRotation` |
| 168 | 🔵 theorem | `ratRotation_det_one` |
| 184 | 🟡 def | `mediant` |
| 196 | 🔵 theorem | `farey_neighbor_det` |
| 213 | 🟡 def | `gaussNorm` |
| 224 | 🔵 theorem | `brahmagupta_fibonacci` |
| 237 | 🔵 theorem | `brahmagupta_fibonacci'` |

---

## Topology

### 📄 AlgebraicTopology.lean

| Line | Kind | Name |
|------|------|------|
| 7 | 🔵 theorem | `real_sc` |
| 8 | 🔵 theorem | `rn_sc` |
| 11 | 🔵 theorem | `chi_S2` |
| 12 | 🔵 theorem | `chi_T2` |
| 13 | 🔵 theorem | `chi_genus2` |
| 14 | 🔵 theorem | `chi_KB` |
| 15 | 🔵 theorem | `chi_RP2` |
| 18 | 🔵 theorem | `abs_nonneg_z` |
| 20 | 🔵 theorem | `q8_order` |
| 22 | 🔵 theorem | `gauss_bonnet_S2` |

### 📄 DescriptiveSetTheory.lean

| Line | Kind | Name |
|------|------|------|
| 11 | 🔵 theorem | `open_is_borel'` |
| 15 | 🔵 theorem | `closed_is_borel'` |
| 19 | 🔵 theorem | `countable_union_measurable'` |
| 24 | 🔵 theorem | `countable_inter_measurable'` |
| 30 | 🔵 theorem | `cantor_compact'` |
| 31 | 🔵 theorem | `cantor_totally_disconnected'` |
| 37 | 🔵 theorem | `complement_measurable'` |
| 41 | 🔵 theorem | `countable_measure_zero'` |
| 45 | 🔵 theorem | `finite_measurable'` |

### 📄 KnotTheory.lean

| Line | Kind | Name |
|------|------|------|
| 7 | 🔵 theorem | `unknot_crossing_number` |
| 8 | 🔵 theorem | `trefoil_crossing_number` |
| 9 | 🔵 theorem | `figure_eight_crossing` |
| 12 | 🔵 theorem | `jones_unknot` |
| 13 | 🔵 theorem | `jones_trefoil_det` |
| 14 | 🔵 theorem | `det_figure_eight` |
| 17 | 🔵 theorem | `trefoil_bridge` |
| 20 | 🔵 theorem | `alexander_at_one` |
| 21 | 🔵 theorem | `alexander_trefoil_minus_one` |
| 25 | 🔵 theorem | `hopf_linking` |
| 26 | 🔵 theorem | `whitehead_linking` |
| 29 | 🔵 theorem | `temperley_lieb_golden_ratio` |
| 34 | 🔵 theorem | `kauffman_circles` |
| 37 | 🔵 theorem | `seifert_genus_bound` |
| 40 | 🔵 theorem | `trefoil_genus` |

### 📄 Topology.lean

| Line | Kind | Name |
|------|------|------|
| 26 | 🔵 theorem | `unit_interval_compact` |
| 36 | 🔵 theorem | `compact_image_continuous` |
| 48 | 🔵 theorem | `compact_attains_max` |
| 63 | 🔵 theorem | `ivt` |
| 77 | 🔵 theorem | `real_connected` |
| 90 | 🔵 theorem | `brouwer_1d` |
| 112 | 🔵 theorem | `compact_metric_complete` |
| 123 | 🔵 theorem | `compact_metric_totally_bounded` |

### 📄 TopologyDynamics.lean

| Line | Kind | Name |
|------|------|------|
| 21 | 🔵 theorem | `metric_hausdorff` |
| 27 | 🔵 theorem | `ball_open` |
| 34 | 🔵 theorem | `empty_open` |
| 41 | 🔵 theorem | `univ_open` |
| 48 | 🔵 theorem | `inter_open` |
| 56 | 🔵 theorem | `union_of_open` |
| 68 | 🔵 theorem | `closed_compact` |
| 75 | 🔵 theorem | `real_noncompact` |
| 81 | 🔵 theorem | `icc_compact` |
| 91 | 🔵 theorem | `real_conn` |
| 97 | 🔵 theorem | `int_totally_disc` |
| 112 | 🔵 theorem | `contraction_unique` |
| 125 | 🔵 theorem | `fixed_iterate` |
| 133 | 🔵 theorem | `period2_iterate` |
| 146 | 🔵 theorem | `euler_tetra` |
| 147 | 🔵 theorem | `euler_cub` |
| 148 | 🔵 theorem | `euler_oct` |
| 149 | 🔵 theorem | `euler_dodec` |
| 150 | 🔵 theorem | `euler_icos` |
| 159 | 🔵 theorem | `platonic_five` |

### 📄 TopologyExploration.lean

| Line | Kind | Name |
|------|------|------|
| 20 | 🔵 theorem | `discrete_metric_triangle` |
| 34 | 🔵 theorem | `unit_interval_compact` |
| 44 | 🔵 theorem | `closed_subset_compact'` |
| 61 | 🔵 theorem | `Icc_connected'` |
| 71 | 🔵 theorem | `connected_image'` |
| 85 | 🔵 theorem | `brouwer_1d` |
| 104 | 🔵 theorem | `integers_closed'` |
| 129 | 🔵 theorem | `rationals_dense'` |
| 136 | 🔵 theorem | `product_compact'` |
| 148 | 🔵 theorem | `cantor_diagonal'` |

---

## Tropical

### 📄 TropicalAdvancedTheory.lean

| Line | Kind | Name |
|------|------|------|
| 36 | 🟠 noncomputable def | `deformedAdd` |
| 40 | 🔵 theorem | `deformedAdd_one` |
| 45 | 🔵 theorem | `lse2_ge_max` |
| 62 | 🔵 theorem | `lse2_le_max_log2` |
| 70 | 🟡 def | `IsTropicallyConvex` |
| 75 | 🔵 theorem | `univ_tropically_convex` |
| 79 | 🟡 def | `IsTropConvexFn` |
| 83 | 🔵 theorem | `id_trop_convex` |
| 87 | 🔵 theorem | `const_trop_convex` |
| 91 | 🔵 theorem | `trop_convex_comp` |
| 101 | 🟠 noncomputable def | `entropy` |
| 105 | 🔵 theorem | `entropy_nonneg_of_prob` |
| 119 | 🔵 theorem | `one_hot_entropy_zero` |
| 126 | 🔵 theorem | `boolean_function_count` |
| 131 | 🔵 theorem | `pl_complexity_compose` |
| 137 | 🔵 theorem | `weight_sharing_reduction` |
| 144 | 🔵 theorem | `tropical_zeta_s1` |
| 152 | 🟡 def | `tropKoopman` |
| 155 | 🔵 theorem | `tropKoopman_mul` |
| 159 | 🔵 theorem | `tropKoopman_one` |
| 163 | 🔵 theorem | `tropKoopman_alg_hom` |
| 172 | 🔵 theorem | `factoring_is_tropical` |
| 180 | 🔵 theorem | `energy_has_tropical_limit` |
| 191 | 🔵 theorem | `hopf_cole_algebraic` |
| 196 | 🔵 theorem | `hopf_cole_inverse` |
| 202 | 🔵 theorem | `classical_limit_principle` |
| 209 | 🔵 theorem | `zero_weight_no_contribution` |
| 215 | 🔵 theorem | `relu_gradient` |
| 223 | 🟠 noncomputable def | `hardAttentionSimple` |
| 227 | 🔵 theorem | `hardAttention_bound` |
| 239 | 🔵 theorem | `advanced_theorem_count` |

### 📄 TropicalAgentAlpha.lean

| Line | Kind | Name |
|------|------|------|
| 13 | 🟡 def | `tropPow` |
| 15 | 🔵 theorem | `tropPow_zero` |
| 16 | 🔵 theorem | `tropPow_one` |
| 17 | 🔵 theorem | `tropPow_succ` |
| 20 | 🔵 theorem | `exp_tropPow` |
| 29 | 🔵 theorem | `softmax_ge_max` |
| 37 | 🔵 theorem | `softmax_le_max_add_log2` |
| 46 | 🟡 def | `IsTropicalContraction` |
| 49 | 🔵 theorem | `tropical_contraction_unique` |
| 58 | 🔵 theorem | `exp_sum_sandwich` |
| 67 | 🔵 theorem | `exp_sum_upper` |
| 75 | 🔵 theorem | `relu_two_regions` |
| 79 | 🔵 theorem | `expressivity_gap` |
| 84 | 🔵 theorem | `log_le_sub_one` |

### 📄 TropicalAgentBeta.lean

| Line | Kind | Name |
|------|------|------|
| 13 | 🟠 noncomputable def | `softAttention` |
| 21 | 🔵 theorem | `softAttention_zero` |
| 28 | 🟠 noncomputable def | `layerMean` |
| 35 | 🔵 theorem | `centered_mean_zero` |
| 40 | 🟠 noncomputable def | `layerVar` |
| 43 | 🔵 theorem | `layerVar_nonneg` |
| 49 | 🔵 theorem | `residual_recovers` |
| 52 | 🔵 theorem | `multihead_split` |
| 58 | 🔵 theorem | `trop_dominant_term` |
| 65 | 🟠 noncomputable def | `perplexity` |
| 72 | 🔵 theorem | `perplexity_mono` |
| 79 | 🔵 theorem | `relu_subgrad_pos` |
| 82 | 🔵 theorem | `relu_subgrad_neg` |
| 87 | 🟠 noncomputable def | `gradStep` |
| 89 | 🔵 theorem | `grad_descent_reduces` |
| 92 | 🔵 theorem | `grad_fixed_point` |

### 📄 TropicalAgentDelta.lean

| Line | Kind | Name |
|------|------|------|
| 13 | 🔵 theorem | `boolean_function_count` |
| 18 | 🔵 theorem | `tropZeta_nonpos` |
| 26 | 🔵 theorem | `dirichlet_term_exp` |
| 36 | 🔵 theorem | `lax_oleinik_monotone` |
| 48 | 🔵 theorem | `tropical_gauge_abelian` |
| 50 | 🔵 theorem | `tropical_yang_mills_linear` |
| 55 | 🟡 def | `IsLogConcave` |
| 58 | 🔵 theorem | `const_log_concave` |
| 62 | 🔵 theorem | `geometric_log_concave` |
| 71 | 🟠 noncomputable def | `fisherBernoulli` |
| 73 | 🔵 theorem | `fisher_bernoulli_pos` |
| 81 | 🔵 theorem | `l_inf_triangle` |
| 90 | 🔵 theorem | `factorial_superpolynomial` |

### 📄 TropicalAgentEpsilon.lean

| Line | Kind | Name |
|------|------|------|
| 13 | 🔵 theorem | `translation_preserves_max` |
| 17 | 🔵 theorem | `nonneg_scale_preserves_max` |
| 29 | 🔵 theorem | `partition_function_bound` |
| 42 | 🔵 theorem | `successive_updates` |
| 48 | 🔵 theorem | `learning_rate_sum_pos` |
| 58 | 🔵 theorem | `max_preserves_convexity` |
| 74 | 🔵 theorem | `affine_convex` |
| 82 | 🟠 noncomputable def | `tropContract` |
| 91 | 🔵 theorem | `tropContract_mono` |
| 102 | 🟡 def | `tropHamming` |
| 105 | 🔵 theorem | `tropHamming_symm` |
| 109 | 🔵 theorem | `tropHamming_nonneg` |
| 116 | 🔵 theorem | `tropHamming_eq_zero` |
| 124 | 🟠 noncomputable def | `tropEntropy` |
| 131 | 🔵 theorem | `tropEntropy_nonneg` |
| 141 | 🔵 theorem | `tropEntropy_const` |

### 📄 TropicalAgentGamma.lean

| Line | Kind | Name |
|------|------|------|
| 13 | 🔵 theorem | `tropical_circuit_leaves` |
| 18 | 🔵 theorem | `rate_distortion_levels` |
| 21 | 🔵 theorem | `log_preserves_order` |
| 27 | 🔵 theorem | `factoring_tropical` |
| 31 | 🔵 theorem | `gcd_lcm_identity` |
| 37 | 🟡 def | `isTropRankOne` |
| 40 | 🔵 theorem | `zero_trop_rank_one` |
| 44 | 🔵 theorem | `const_trop_rank_one` |
| 50 | 🔵 theorem | `source_coding_bound` |
| 55 | 🔵 theorem | `tropical_separation` |
| 62 | 🔵 theorem | `pruning_preserves_max` |

### 📄 TropicalDeepResearch.lean

| Line | Kind | Name |
|------|------|------|
| 28 | 🔵 theorem | `max_affine_dominates` |
| 32 | 🔵 theorem | `tropical_gradient_selection` |
| 42 | 🔵 theorem | `tropical_jensen` |
| 52 | 🟡 def | `tropDynamicsStep` |
| 57 | 🟡 def | `tropicalLyapunov` |
| 67 | 🔵 theorem | `tropical_spectral_bound` |
| 82 | 🔵 theorem | `tropical_contraction_principle` |
| 93 | 🟡 def | `gumbelCDF` |
| 103 | 🔵 theorem | `gumbelCDF_pos` |
| 114 | 🔵 theorem | `gumbelCDF_le_one` |
| 119 | 🔵 theorem | `gumbel_softmax_deterministic` |
| 123 | 🔵 theorem | `tropical_clt_growth_bound` |
| 131 | 🟡 def | `tropicalDistance` |
| 141 | 🔵 theorem | `tropicalDistance_nonneg` |
| 153 | 🔵 theorem | `tropicalDistance_symm` |
| 165 | 🔵 theorem | `tropicalDistance_triangle` |
| 175 | 🔵 theorem | `tropical_identity_cost` |
| 178 | 🔵 theorem | `tropical_yoneda_preservation` |
| 189 | 🔵 theorem | `tropical_depth_lower_bound` |
| 196 | 🔵 theorem | `depth_width_tradeoff` |
| 201 | 🔵 theorem | `skip_connection_rank_bound` |
| 215 | 🔵 theorem | `kl_ge_tropical_divergence` |
| 220 | 🔵 theorem | `tropical_fisher_info` |
| 228 | 🟡 def | `tropicalHaarScaling` |
| 232 | 🟡 def | `tropicalHaarDetail` |
| 236 | 🔵 theorem | `tropicalHaar_bound` |
| 242 | 🔵 theorem | `tropicalHaar_reconstruction` |
| 250 | 🔵 theorem | `tropical_euler_characteristic` |
| 254 | 🔵 theorem | `tropical_persistence_interval` |
| 268 | 🔵 theorem | `maslov_approximation` |
| 279 | 🔵 theorem | `maslov_error_bound` |
| 300 | 🔵 theorem | `tropical_bellman_contraction` |
| 305 | 🔵 theorem | `value_iteration_convergence` |
| 314 | 🔵 theorem | `tropical_mirror_duality` |
| 317 | 🔵 theorem | `tropical_gw_count_nonneg` |
| 324 | 🔵 theorem | `tropical_rank_bound` |
| 339 | 🔵 theorem | `tropical_compression_bound` |
| 354 | 🔵 theorem | `tropical_zeta_positive` |
| 359 | 🔵 theorem | `tropical_functional_equation_symmetry` |
| 363 | 🔵 theorem | `log_gamma_convexity_helper` |
| 373 | 🔵 theorem | `hopf_cole_bridge` |
| 383 | 🔵 theorem | `burgers_tropical_limit` |
| 392 | 🔵 theorem | `turing_simulation_width_bound` |
| 396 | 🔵 theorem | `codon_redundancy` |
| 397 | 🔵 theorem | `amino_acid_redundancy` |
| 400 | 🔵 theorem | `market_clearing_tropical` |
| 410 | 🔵 theorem | `piecewise_quadratic_loss` |
| 415 | 🔵 theorem | `loss_gradient_classical` |
| 426 | 🔵 theorem | `tropical_interior_convex` |
| 435 | 🔵 theorem | `max_aggregation_tropical` |
| 439 | 🔵 theorem | `wl_tropical_hash` |
| 443 | 🔵 theorem | `gnn_expressivity_bound` |
| 450 | 🔵 theorem | `attention_score_tropical_limit` |
| 454 | 🔵 theorem | `multi_head_tropical` |
| 459 | 🔵 theorem | `layer_norm_scaling` |
| 468 | 🔵 theorem | `score_tropical_gradient` |
| 472 | 🔵 theorem | `ddpm_loss_nonneg` |
| 476 | 🔵 theorem | `cfg_interpolation` |

### 📄 TropicalFactoring.lean

| Line | Kind | Name |
|------|------|------|
| 37 | 🔵 theorem | `padic_val_mul_eq_add` |
| 45 | 🔵 theorem | `padic_val_one` |
| 51 | 🔵 theorem | `padic_val_self` |
| 62 | 🔵 theorem | `padic_val_prime_pow` |
| 75 | 🔵 theorem | `tropical_fundamental_theorem_of_arithmetic` |
| 89 | 🔵 theorem | `padic_val_gcd` |
| 105 | 🔵 theorem | `padic_val_lcm` |
| 118 | 🔵 theorem | `tropical_gcd_lcm_identity` |
| 136 | 🔵 theorem | `dvd_iff_padic_le` |
| 151 | 🟡 def | `IsTropicalFactoring` |
| 162 | 🔵 theorem | `tropical_factoring_decomposition` |
| 174 | 🔵 theorem | `coprime_tropical_disjoint` |
| 186 | 🟡 def | `IsSmooth` |
| 192 | 🔵 theorem | `one_isSmooth` |
| 202 | 🔵 theorem | `smooth_mul` |
| 214 | 🔵 theorem | `prime_pow_smooth` |
| 224 | 🟡 def | `tropicalNorm` |
| 228 | 🟡 def | `totalTropicalWeight` |
| 238 | 🔵 theorem | `totalTropicalWeight_mul` |
| 248 | 🔵 theorem | `bigOmega_eq_tropical_weight` |
| 263 | 🔵 theorem | `trial_division_clears_coordinate` |
| 273 | 🔵 theorem | `full_division_zeros_coordinate` |
| 286 | 🔵 theorem | `fermat_factoring_identity` |
| 291 | 🔵 theorem | `sum_of_squares_tropical` |
| 300 | 🟡 def | `pollardRhoStep` |
| 303 | 🔵 theorem | `pollardRho_bounded` |
| 307 | 🔵 theorem | `birthday_bound_sqrt` |
| 319 | 🔵 theorem | `tropical_lattice_min_max` |
| 326 | 🔵 theorem | `tropical_absorption_min_max` |
| 333 | 🔵 theorem | `tropical_absorption_max_min` |
| 345 | 🔵 theorem | `even_valuations_implies_square` |
| 353 | 🔵 theorem | `tropical_gf2_combination` |
| 364 | 🔵 theorem | `period_divides_order` |
| 377 | 🔵 theorem | `shor_factoring_step` |
| 398 | 🔵 theorem | `factoring_tropical_hyperplane` |
| 407 | 🔵 theorem | `factoring_count_bound` |

### 📄 TropicalFrontierResearch.lean

| Line | Kind | Name |
|------|------|------|
| 33 | 🟡 def | `tropMatVec` |
| 38 | 🟡 def | `IsTropicalEigen` |
| 43 | 🔵 theorem | `trop_eigen_1x1` |
| 54 | 🔵 theorem | `tropMatVec_mono` |
| 72 | 🔵 theorem | `tropMatVec_shift` |
| 85 | 🟡 def | `tropMonomial` |
| 89 | 🔵 theorem | `relu_is_tropPoly` |
| 93 | 🔵 theorem | `deep_relu_tropical_terms` |
| 97 | 🔵 theorem | `tropical_degree_composition` |
| 111 | 🔵 theorem | `tropMatVec_nonexpansion` |
| 127 | 🔵 theorem | `tropical_young_ineq` |
| 131 | 🔵 theorem | `legendre_quadratic_identity` |
| 139 | 🟠 noncomputable def | `reluDeriv` |
| 142 | 🔵 theorem | `reluDeriv_binary` |
| 146 | 🔵 theorem | `tropical_gradient_selector` |
| 153 | 🔵 theorem | `backprop_relu_gate` |
| 158 | 🔵 theorem | `tropical_chain_rule` |
| 162 | 🔵 theorem | `selector_product_binary` |
| 174 | 🔵 theorem | `gradient_path_binary` |
| 185 | 🟡 def | `tropicalEntropy` |
| 189 | 🔵 theorem | `tropicalEntropy_nonneg` |
| 198 | 🔵 theorem | `temperature_scaling` |
| 208 | 🔵 theorem | `shannon_ge_minEntropy` |
| 223 | 🔵 theorem | `relu_two_regions` |
| 228 | 🔵 theorem | `region_count_lower` |
| 238 | 🔵 theorem | `compression_ratio_bound` |
| 250 | 🔵 theorem | `negation_max_to_min` |
| 257 | 🔵 theorem | `negation_min_to_max` |
| 264 | 🔵 theorem | `tropical_fourier_inversion` |
| 267 | 🔵 theorem | `negation_preserves_add` |
| 270 | 🔵 theorem | `dual_relu` |
| 276 | 🔵 theorem | `minAdd_assoc` |
| 279 | 🔵 theorem | `minAdd_idem` |
| 286 | 🔵 theorem | `padic_tropical_mul` |
| 298 | 🔵 theorem | `tropical_fundamental_arithmetic` |
| 306 | 🔵 theorem | `padic_val_nonneg` |
| 313 | 🟡 def | `tropAutomatonRun` |
| 319 | 🔵 theorem | `tropAutomaton_zero` |
| 323 | 🔵 theorem | `tropAutomaton_mono` |
| 335 | 🟡 def | `scaledSoftmax` |
| 339 | 🔵 theorem | `scaledSoftmax_pos` |
| 344 | 🔵 theorem | `scaledSoftmax_sum` |
| 356 | 🔵 theorem | `scaledSoftmax_le_one` |
| 361 | 🟡 def | `logSumExp` |
| 371 | 🔵 theorem | `lse_ge_component` |
| 383 | 🔵 theorem | `lse_le_max_log` |
| 401 | 🟡 def | `tropBellman` |
| 412 | 🔵 theorem | `tropBellman_mono` |
| 424 | 🔵 theorem | `tropical_zeta_term` |
| 428 | 🔵 theorem | `tropical_product_to_sum` |
| 433 | 🔵 theorem | `hopf_cole_bridge` |
| 436 | 🔵 theorem | `exp_preserves_mul` |
| 444 | 🔵 theorem | `stationary_phase` |
| 449 | 🔵 theorem | `classical_tropical_limit` |
| 457 | 🔵 theorem | `residual_recovers_input` |
| 462 | 🔵 theorem | `layernorm_is_affine` |
| 476 | 🔵 theorem | `pruning_error_bound` |
| 482 | 🔵 theorem | `exponential_regions` |
| 486 | 🔵 theorem | `compilation_error_vanishes` |
| 501 | 🔵 theorem | `relu_not_polynomial` |
| 524 | 🔵 theorem | `exp_not_affine` |
| 533 | 🔵 theorem | `frontier_theorem_count` |

### 📄 TropicalGeneralNetworks.lean

| Line | Kind | Name |
|------|------|------|
| 25 | 🟠 noncomputable def | `neuralLayer` |
| 30 | 🟡 def | `linearLayer` |
| 35 | 🟡 def | `relu` |
| 38 | 🟠 noncomputable def | `reluLayer` |
| 43 | 🔵 theorem | `reluLayer_eq` |
| 50 | 🟡 def | `tAdd` |
| 53 | 🟡 def | `tMul` |
| 56 | 🟠 noncomputable def | `tropInner` |
| 60 | 🟠 noncomputable def | `tropMatVec` |
| 65 | 🟠 noncomputable def | `tropMatMul` |
| 72 | 🔵 theorem | `linear_compose_linear` |
| 79 | 🔵 theorem | `transplant_exact_general` |
| 86 | 🟡 def | `residualBlock` |
| 90 | 🔵 theorem | `residual_tropical_compat` |
| 95 | 🔵 theorem | `residual_recovers_input` |
| 103 | 🟠 noncomputable def | `scaledSoftmax` |
| 107 | 🔵 theorem | `scaledSoftmax_nonneg` |
| 112 | 🔵 theorem | `scaledSoftmax_sum_one` |
| 119 | 🟠 noncomputable def | `softmax` |
| 122 | 🔵 theorem | `softmax_eq_scaled_one` |
| 127 | 🔵 theorem | `softmax_shift_invariant` |
| 134 | 🔵 theorem | `softmax_preserves_order` |
| 144 | 🟠 noncomputable def | `logSumExp` |
| 148 | 🔵 theorem | `logSumExp_ge` |
| 160 | 🔵 theorem | `attention_linear_in_query` |
| 167 | 🔵 theorem | `general_region_bound` |
| 172 | 🔵 theorem | `deep_network_exponential` |
| 177 | 🟡 def | `tropicalRank` |
| 189 | 🔵 theorem | `relu_tropical_rank_le2` |
| 197 | 🔵 theorem | `scaledSoftmax_le_one` |
| 206 | 🟡 def | `leakyRelu` |
| 209 | 🔵 theorem | `leakyRelu_tropical` |
| 213 | 🔵 theorem | `leakyRelu_zero_is_relu` |
| 218 | 🟡 def | `hardTanh` |
| 221 | 🔵 theorem | `hardTanh_bounded` |
| 230 | 🔵 theorem | `width_increases_regions` |
| 235 | 🔵 theorem | `depth_exponential_regions` |
| 242 | 🟠 noncomputable def | `batchNormInference` |
| 247 | 🔵 theorem | `batchNorm_affine` |
| 254 | 🔵 theorem | `batchNorm_transplant_exact` |
| 261 | 🟠 noncomputable def | `tropDet` |
| 266 | 🔵 theorem | `weight_sharing_reduction` |
| 273 | 🔵 theorem | `zero_weight_no_contribution` |
| 277 | 🔵 theorem | `theorem_count_positive` |

### 📄 TropicalGeometry.lean

| Line | Kind | Name |
|------|------|------|
| 6 | 🔵 theorem | `tropical_add_comm` |
| 9 | 🔵 theorem | `tropical_add_assoc` |
| 13 | 🔵 theorem | `tropical_zero` |
| 16 | 🔵 theorem | `tropical_distrib` |
| 20 | 🔵 theorem | `tropical_triangle` |
| 26 | 🔵 theorem | `newton_polygon_slope` |
| 32 | 🔵 theorem | `tropical_convex_hull` |
| 37 | 🔵 theorem | `bellman_equation` |

### 📄 TropicalInformationRichness.lean

| Line | Kind | Name |
|------|------|------|
| 43 | 🔵 theorem | `exp_tropical_scalar` |
| 49 | 🔵 theorem | `square_doubles_tropical` |
| 54 | 🔵 theorem | `cube_triples_tropical` |
| 64 | 🔵 theorem | `factoring_space_grows_with_product` |
| 68 | 🔵 theorem | `divisor_count_multiplicative` |
| 75 | 🔵 theorem | `exp_information_density` |
| 79 | 🔵 theorem | `square_minimal_doubling` |
| 87 | 🔵 theorem | `uniform_entropy_bound` |
| 92 | 🔵 theorem | `add_range_bound` |
| 96 | 🔵 theorem | `mul_range_bound` |
| 100 | 🔵 theorem | `exp_range_bound` |
| 104 | 🔵 theorem | `mul_vs_add_output_space` |
| 114 | 🔵 theorem | `photon_energy_tropical` |
| 118 | 🔵 theorem | `superposition_tropical` |
| 127 | 🔵 theorem | `photon_number_energy` |
| 131 | 🔵 theorem | `squeeze_information` |
| 140 | 🔵 theorem | `square_two_to_one` |
| 143 | 🔵 theorem | `square_easy_forward` |
| 146 | 🔵 theorem | `jacobi_multiplicativity` |
| 150 | 🔵 theorem | `quadratic_residue_count` |
| 154 | 🔵 theorem | `square_mod_four` |
| 161 | 🔵 theorem | `square_mod_three` |
| 172 | 🔵 theorem | `discrete_exp_mod_bound` |
| 182 | 🔵 theorem | `fermat_little_period` |
| 187 | 🔵 theorem | `rsa_encryption_bound` |
| 191 | 🔵 theorem | `diffie_hellman_commutativity` |
| 199 | 🔵 theorem | `addition_linear_growth` |
| 202 | 🔵 theorem | `multiplication_quadratic_growth` |
| 205 | 🔵 theorem | `exponentiation_exponential_growth` |
| 214 | 🟡 def | `tetration` |
| 218 | 🔵 theorem | `tetration_dominates_exp` |
| 231 | 🔵 theorem | `relu_is_tropical_add_zero` |
| 236 | 🔵 theorem | `network_tropical_degree` |
| 241 | 🔵 theorem | `depth_efficiency` |
| 260 | 🔵 theorem | `linear_regions_bound` |
| 276 | 🔵 theorem | `mul_bit_complexity_bound` |
| 280 | 🔵 theorem | `square_bit_complexity` |
| 287 | 🔵 theorem | `bose_einstein_tropical_limit` |
| 292 | 🔵 theorem | `partition_function_tropical` |
| 297 | 🔵 theorem | `coherent_state_mean_photon` |
| 301 | 🔵 theorem | `hom_interference` |
| 309 | 🔵 theorem | `tropical_simplicity_of_mul` |
| 314 | 🔵 theorem | `tropical_simplicity_of_exp` |
| 319 | 🔵 theorem | `information_asymmetry_mul` |
| 323 | 🔵 theorem | `information_richness_hierarchy` |
| 327 | 🔵 theorem | `squaring_minimal_trapdoor` |
| 336 | 🔵 theorem | `inverse_square_law` |
| 340 | 🔵 theorem | `stefan_boltzmann_positivity` |
| 344 | 🔵 theorem | `wien_displacement` |
| 348 | 🔵 theorem | `born_rule_nonneg` |
| 351 | 🔵 theorem | `classical_limit_tropical` |
| 361 | 🔵 theorem | `information_operation_physics_triangle` |
| 369 | 🔵 theorem | `quadratic_activation_bound` |
| 373 | 🔵 theorem | `optimal_depth_bound` |
| 380 | 🔵 theorem | `tropical_compression_advantage` |

### 📄 TropicalLLMConversion.lean

| Line | Kind | Name |
|------|------|------|
| 25 | 🟡 def | `tAdd` |
| 28 | 🟡 def | `tMul` |
| 30 | 🔵 theorem | `tAdd_comm` |
| 31 | 🔵 theorem | `tAdd_assoc` |
| 32 | 🔵 theorem | `tAdd_idem` |
| 33 | 🔵 theorem | `tMul_comm` |
| 34 | 🔵 theorem | `tMul_assoc` |
| 36 | 🔵 theorem | `tMul_zero_right` |
| 37 | 🔵 theorem | `tMul_zero_left` |
| 40 | 🔵 theorem | `tMul_tAdd_left` |
| 45 | 🔵 theorem | `tMul_tAdd_right` |
| 52 | 🟡 def | `relu` |
| 55 | 🔵 theorem | `relu_is_tropical` |
| 57 | 🔵 theorem | `relu_nonneg` |
| 59 | 🔵 theorem | `relu_mono` |
| 63 | 🔵 theorem | `relu_idempotent` |
| 67 | 🔵 theorem | `relu_piecewise` |
| 73 | 🔵 theorem | `relu_not_linear` |
| 80 | 🔵 theorem | `relu_not_affine` |
| 94 | 🔵 theorem | `exp_tMul` |
| 98 | 🔵 theorem | `exp_tropical_one` |
| 101 | 🔵 theorem | `exp_mono_iff` |
| 104 | 🔵 theorem | `exp_strict_mono_iff'` |
| 107 | 🔵 theorem | `log_recovers_tMul` |
| 114 | 🟠 noncomputable def | `softmax` |
| 118 | 🔵 theorem | `sum_exp_pos'` |
| 123 | 🔵 theorem | `softmax_nonneg` |
| 128 | 🔵 theorem | `softmax_sum_one` |
| 134 | 🔵 theorem | `softmax_shift` |
| 141 | 🔵 theorem | `softmax_preserves_order` |
| 146 | 🔵 theorem | `softmax_le_one` |
| 152 | 🟠 noncomputable def | `scaledSoftmax` |
| 156 | 🔵 theorem | `scaledSoftmax_one` |
| 160 | 🔵 theorem | `scaledSoftmax_nonneg` |
| 165 | 🔵 theorem | `scaledSoftmax_sum_one` |
| 173 | 🟠 noncomputable def | `logSumExp` |
| 177 | 🔵 theorem | `sum_exp_pos` |
| 182 | 🔵 theorem | `logSumExp_ge` |
| 196 | 🔵 theorem | `logSumExp_le` |
| 210 | 🟠 noncomputable def | `attentionScore` |
| 214 | 🔵 theorem | `attentionScore_scale` |
| 221 | 🟡 def | `linearLayer` |
| 225 | 🔵 theorem | `transplant_exact` |
| 230 | 🔵 theorem | `compose_linear` |
| 239 | 🟡 def | `residualConn` |
| 242 | 🔵 theorem | `residual_sub` |
| 246 | 🟠 noncomputable def | `layerNormMean` |
| 249 | 🔵 theorem | `layerNormMean_const` |
| 257 | 🟡 def | `causalMask` |
| 259 | 🔵 theorem | `causalMask_refl` |
| 260 | 🔵 theorem | `causalMask_trans` |
| 264 | 🔵 theorem | `causal_attention_count` |
| 270 | 🟡 def | `gpt2_n_layer` |
| 271 | 🟡 def | `gpt2_n_head` |
| 272 | 🟡 def | `gpt2_n_embd` |
| 273 | 🟡 def | `gpt2_head_dim` |
| 275 | 🔵 theorem | `gpt2_head_dim_val` |
| 276 | 🔵 theorem | `gpt2_heads_divide` |
| 277 | 🔵 theorem | `gpt2_each_head` |
| 279 | 🔵 theorem | `gpt2_attn_params` |
| 281 | 🔵 theorem | `gpt2_mlp_params` |
| 283 | 🔵 theorem | `gpt2_layer_params` |
| 287 | 🔵 theorem | `multihead_dim_split` |
| 294 | 🟠 noncomputable def | `geluApprox` |
| 297 | 🔵 theorem | `geluApprox_zero` |
| 299 | 🔵 theorem | `sigmoid_pos` |
| 302 | 🔵 theorem | `geluApprox_pos` |
| 308 | 🟡 def | `TropicallyConvex` |
| 312 | 🔵 theorem | `monotone_tropically_convex` |
| 319 | 🔵 theorem | `relu_tropically_convex` |
| 325 | 🟠 noncomputable def | `shannonEntropy` |
| 329 | 🔵 theorem | `one_hot_zero_entropy` |
| 336 | 🔵 theorem | `add_max_distrib` |
| 340 | 🔵 theorem | `max_mul_nonneg` |
| 349 | 🟠 noncomputable def | `tropMatMul` |
| 356 | 🟡 def | `koopmanOp` |
| 358 | 🔵 theorem | `koopman_linear_add` |
| 361 | 🔵 theorem | `koopman_linear_smul` |
| 364 | 🔵 theorem | `koopman_comp` |
| 370 | 🔵 theorem | `relu_region_bound` |
| 374 | 🟡 def | `gpt2_vocab` |
| 377 | 🔵 theorem | `gpt2_lookup_huge` |
| 388 | 🔵 theorem | `exp_not_affine` |
| 396 | 🔵 theorem | `relu_two_pieces` |
| 400 | 🔵 theorem | `relu_compose_pieces` |

### 📄 TropicalMoonshots.lean

| Line | Kind | Name |
|------|------|------|
| 39 | 🟡 def | `scaledLSE` |
| 43 | 🔵 theorem | `scaledLSE_one` |
| 48 | 🟡 def | `softMin` |
| 52 | 🔵 theorem | `softMin_dual` |
| 56 | 🔵 theorem | `max_pow_le_sum_pow` |
| 65 | 🔵 theorem | `sum_pow_le_two_max_pow` |
| 78 | 🟡 def | `heaviside` |
| 81 | 🔵 theorem | `heaviside_pos` |
| 84 | 🔵 theorem | `heaviside_nonpos` |
| 87 | 🔵 theorem | `heaviside_range` |
| 91 | 🔵 theorem | `relu_eq_mul_heaviside` |
| 98 | 🔵 theorem | `relu_chain_pos` |
| 102 | 🔵 theorem | `max_subgradient_at_tie` |
| 108 | 🟡 def | `tropicalMatVec2` |
| 112 | 🔵 theorem | `tropicalMatVec2_ge_fst` |
| 116 | 🔵 theorem | `tropicalMatVec2_ge_snd` |
| 120 | 🟡 def | `tropicalScalarMul` |
| 124 | 🟡 def | `tropicalMatAdd` |
| 136 | 🔵 theorem | `regularization_gap_nonneg` |
| 147 | 🔵 theorem | `regularization_gap_le_log2` |
| 159 | 🔵 theorem | `max_entropy_is_uniform` |
| 177 | 🟡 def | `hilbertDist` |
| 181 | 🔵 theorem | `hilbertDist_nonneg` |
| 186 | 🔵 theorem | `hilbertDist_zero_of_eq` |
| 196 | 🔵 theorem | `hilbertDist_symm` |
| 201 | 🔵 theorem | `hilbertDist_translate` |
| 206 | 🔵 theorem | `hilbertDist_tropical_scale` |
| 213 | 🔵 theorem | `maxPlusConv_comm_simple` |
| 217 | 🔵 theorem | `tropical_young_conv` |
| 231 | 🔵 theorem | `galois_max_le_lse` |
| 242 | 🔵 theorem | `galois_gap_le_log2` |
| 247 | 🔵 theorem | `iterated_max_assoc` |
| 251 | 🔵 theorem | `exp_tropical_product` |
| 255 | 🔵 theorem | `log_classical_product` |
| 261 | 🟡 def | `tropSign` |
| 263 | 🔵 theorem | `tropSign_pos` |
| 264 | 🔵 theorem | `tropSign_neg` |
| 266 | 🔵 theorem | `tropSign_zero` |
| 269 | 🔵 theorem | `abs_eq_mul_tropSign` |
| 275 | 🔵 theorem | `relu_network_gradient` |
| 282 | 🟡 def | `tropicalOuter` |
| 286 | 🔵 theorem | `tropical_rank1_minor` |
| 290 | 🟡 def | `tropicalPerm2` |
| 293 | 🔵 theorem | `tropicalPerm2_symm` |
| 300 | 🔵 theorem | `relu_partition` |
| 307 | 🔵 theorem | `width_regions_1d` |
| 310 | 🔵 theorem | `depth_width_regions` |
| 315 | 🟡 def | `bellmanOp` |
| 318 | 🔵 theorem | `bellmanOp_monotone` |
| 325 | 🔵 theorem | `bellmanOp_nonneg` |
| 334 | 🔵 theorem | `bellman_contraction` |
| 345 | 🔵 theorem | `quadratic_self_dual` |
| 349 | 🔵 theorem | `young_ineq_squares` |
| 353 | 🔵 theorem | `conjugate_exp_bound` |
| 360 | 🔵 theorem | `multihead_independent` |
| 373 | 🔵 theorem | `attention_convex_bound` |
| 388 | 🔵 theorem | `attention_lower_bound` |
| 399 | 🟡 def | `klBernoulli` |
| 403 | 🔵 theorem | `klBernoulli_self` |
| 414 | 🔵 theorem | `softmax_jacobian_diag` |
| 424 | 🟡 def | `tropicalLinear` |
| 427 | 🔵 theorem | `tropical_interp_two` |
| 432 | 🔵 theorem | `tropical_max_linear_bend` |
| 440 | 🔵 theorem | `tropical_poly_eval_pwl` |
| 448 | 🔵 theorem | `network_pieces_bound` |
| 451 | 🔵 theorem | `pwl_approx_doubling` |
| 454 | 🔵 theorem | `pwl_approx_lipschitz` |
| 460 | 🔵 theorem | `affine_preserves_max` |
| 469 | 🔵 theorem | `tropical_hom_comp` |
| 476 | 🔵 theorem | `lipschitz_bound` |
| 483 | 🟡 def | `tropicalExpectation` |
| 487 | 🟡 def | `tropicalSpread` |
| 490 | 🔵 theorem | `tropicalSpread_nonneg` |
| 493 | 🔵 theorem | `tropical_exp_le_max` |
| 503 | 🟡 def | `ActivationPattern` |
| 506 | 🔵 theorem | `same_pattern_nonneg` |
| 511 | 🔵 theorem | `activation_pattern_count` |
| 514 | 🔵 theorem | `neuron_boundary_codim1` |
| 528 | 🔵 theorem | `binary_entropy_nonneg` |

### 📄 TropicalNNCompilation.lean

| Line | Kind | Name |
|------|------|------|
| 22 | 🟡 def | `tadd` |
| 25 | 🟡 def | `tmul` |
| 28 | 🔵 theorem | `tadd_comm` |
| 32 | 🔵 theorem | `tadd_assoc` |
| 36 | 🔵 theorem | `tadd_idem` |
| 40 | 🔵 theorem | `tmul_comm` |
| 44 | 🔵 theorem | `tmul_assoc` |
| 48 | 🔵 theorem | `tmul_zero_right` |
| 52 | 🔵 theorem | `tmul_zero_left` |
| 56 | 🔵 theorem | `tmul_tadd_distrib` |
| 62 | 🔵 theorem | `tadd_tmul_distrib` |
| 70 | 🟡 def | `relu` |
| 74 | 🔵 theorem | `relu_eq_tadd_zero` |
| 77 | 🔵 theorem | `relu_nonneg` |
| 81 | 🔵 theorem | `relu_of_nonneg` |
| 85 | 🔵 theorem | `relu_of_nonpos` |
| 89 | 🔵 theorem | `relu_mono` |
| 99 | 🔵 theorem | `relu_not_linear_map` |
| 107 | 🔵 theorem | `relu_not_affine` |
| 115 | 🔵 theorem | `exp_not_affine` |
| 126 | 🟠 noncomputable def | `tropMatMul` |
| 133 | 🔵 theorem | `tropMatMul_assoc` |
| 147 | 🟡 def | `gpt2_vocab` |
| 149 | 🟡 def | `gpt2_context` |
| 151 | 🟡 def | `gpt2_layers` |
| 154 | 🔵 theorem | `gpt2_lookup_size_huge` |
| 158 | 🟡 def | `gpt2_tropical_dim` |
| 161 | 🔵 theorem | `gpt2_tropical_dim_bound` |
| 166 | 🔵 theorem | `gpt2_tropical_k4` |
| 170 | 🔵 theorem | `gpt2_tropical_tractable` |
| 176 | 🟠 noncomputable def | `softmax` |
| 180 | 🔵 theorem | `softmax_nonneg` |
| 185 | 🔵 theorem | `softmax_sum_one` |
| 194 | 🔵 theorem | `exactness_barrier` |
| 198 | 🔵 theorem | `finite_exact_compilation` |
| 205 | 🔵 theorem | `pwl_as_relu_sum` |
| 210 | 🔵 theorem | `relu_is_pwl` |
| 219 | 🟡 def | `koopmanOp` |
| 222 | 🔵 theorem | `koopman_add` |
| 227 | 🔵 theorem | `koopman_smul` |
| 232 | 🔵 theorem | `koopman_comp` |
| 239 | 🔵 theorem | `relu_region_bound` |

### 📄 TropicalNNFrontier.lean

| Line | Kind | Name |
|------|------|------|
| 45 | 🔵 theorem | `tropical_add_comm` |
| 55 | 🔵 theorem | `tropical_add_assoc` |
| 65 | 🔵 theorem | `tropical_distrib` |
| 76 | 🔵 theorem | `tropical_distrib_right` |
| 87 | 🔵 theorem | `tropical_add_zero_nonneg` |
| 97 | 🔵 theorem | `tropical_distrib_sum` |
| 113 | 🟡 def | `relu` |
| 123 | 🔵 theorem | `relu_compose_represents_max3` |
| 135 | 🔵 theorem | `relu_affine_as_tropical` |
| 146 | 🔵 theorem | `leaky_relu_from_relu` |
| 157 | 🔵 theorem | `abs_as_tropical` |
| 167 | 🔵 theorem | `abs_relu_decomp` |
| 177 | 🔵 theorem | `clamp_as_relu` |
| 188 | 🔵 theorem | `min_from_max` |
| 198 | 🔵 theorem | `min_relu_computable` |
| 208 | 🟡 def | `softmax_beta` |
| 218 | 🔵 theorem | `softmax_beta_zero` |
| 229 | 🔵 theorem | `softmax_beta_nonneg` |
| 240 | 🔵 theorem | `softmax_beta_sum_one` |
| 252 | 🔵 theorem | `softmax_beta_le_one` |
| 263 | 🔵 theorem | `softmax_beta_one_eq` |
| 274 | 🔵 theorem | `softmax_beta_shift` |
| 286 | 🟡 def | `logSumExp'` |
| 296 | 🔵 theorem | `logSumExp_shift` |
| 312 | 🔵 theorem | `logSumExp_two_bound` |
| 327 | 🔵 theorem | `logSumExp_const` |
| 339 | 🔵 theorem | `tropicality_gap_nonneg` |
| 359 | 🔵 theorem | `exp_ge_one_plus` |
| 369 | 🔵 theorem | `exp_strict_convex` |
| 380 | 🔵 theorem | `lse_stability_trick` |
| 394 | 🔵 theorem | `exp_log_id` |
| 404 | 🔵 theorem | `log_exp_id` |
| 414 | 🔵 theorem | `exp_tropical_hom_max` |
| 426 | 🔵 theorem | `exp_injective` |
| 436 | 🟡 def | `binaryEntropy` |
| 445 | 🔵 theorem | `binaryEntropy_zero` |
| 455 | 🔵 theorem | `binaryEntropy_one` |
| 467 | 🔵 theorem | `kl_self_zero` |
| 480 | 🔵 theorem | `gibbs_inequality_finite` |
| 501 | 🔵 theorem | `jensen_log_finite` |
| 521 | 🔵 theorem | `uniform_entropy` |
| 542 | 🔵 theorem | `pwl_parameter_bound` |
| 554 | 🔵 theorem | `relu_regions_base` |
| 567 | 🔵 theorem | `linear_regions_width_bound` |
| 579 | 🔵 theorem | `compression_gap_bound` |
| 600 | 🔵 theorem | `log_le_sub_one` |
| 612 | 🔵 theorem | `tropical_young_inequality` |
| 629 | 🔵 theorem | `softmax_achieves_lse` |
| 644 | 🟡 def | `tropicalMonomial` |
| 647 | 🟡 def | `tropicalPoly` |
| 657 | 🔵 theorem | `tropicalPoly_pwl` |
| 669 | 🔵 theorem | `tropical_poly_add_is_max` |
| 680 | 🔵 theorem | `tropical_monomial_mul` |
| 703 | 🔵 theorem | `softmax_diff_bounded` |
| 722 | 🔵 theorem | `exp_lipschitz_local` |
| 749 | 🔵 theorem | `tropical_matmul_2x2` |
| 763 | 🔵 theorem | `tropical_det_2x2` |
| 775 | 🔵 theorem | `tropical_or_monotone` |
| 786 | 🔵 theorem | `tropical_and_distributes` |
| 805 | 🔵 theorem | `hopf_cole_algebraic` |
| 818 | 🔵 theorem | `inviscid_min_connection` |
| 830 | 🔵 theorem | `heat_kernel_exponent_nonpos` |
| 850 | 🔵 theorem | `lcm_gcd_product` |
| 862 | 🔵 theorem | `padic_val_mul` |
| 874 | 🔵 theorem | `padic_val_lcm` |
| 891 | 🔵 theorem | `padic_val_gcd` |
| 907 | 🔵 theorem | `prime_val_independent` |
| 924 | 🔵 theorem | `relu_abs_identity` |
| 934 | 🔵 theorem | `relu_signed_decomp` |
| 948 | 🔵 theorem | `pos_neg_decomposition` |
| 959 | 🔵 theorem | `relu_subadditive` |
| 969 | 🔵 theorem | `relu_pos_homogeneous` |
| 981 | 🔵 theorem | `relu_product_nonneg` |
| 994 | 🔵 theorem | `relu_squared_bound` |
| 1004 | 🟡 def | `tropicalDot` |
| 1016 | 🔵 theorem | `tropicalDot_comm` |
| 1028 | 🔵 theorem | `tropicalDot_zero_left` |
| 1053 | 🔵 theorem | `linear_interp_bound` |
| 1065 | 🔵 theorem | `relu_layer_pieces` |
| 1082 | 🔵 theorem | `two_piece_relu_continuous` |
| 1102 | 🔵 theorem | `tropical_line_vertex` |
| 1113 | 🔵 theorem | `tropical_quad_bend_left` |
| 1116 | 🔵 theorem | `tropical_quad_bend_right` |
| 1129 | 🔵 theorem | `tropical_root_degree1` |
| 1146 | 🔵 theorem | `strictMono_preserves_max` |
| 1157 | 🔵 theorem | `monotone_sum_bound` |
| 1168 | 🔵 theorem | `monotone_comp` |
| 1179 | 🔵 theorem | `strictMono_comp` |
| 1198 | 🔵 theorem | `one_hot_selects` |
| 1209 | 🔵 theorem | `uniform_attention_mean` |
| 1221 | 🔵 theorem | `attention_in_range` |
| 1251 | 🔵 theorem | `neg_log_one_minus_bound` |
| 1264 | 🔵 theorem | `tropical_conv_identity` |

### 📄 TropicalOracle.lean

| Line | Kind | Name |
|------|------|------|
| 37 | 🟡 def | `IsOracle` |
| 41 | 🟡 def | `truthSet` |
| 51 | 🔵 theorem | `truthSet_eq_fixedPoints` |
| 62 | 🔵 theorem | `oracle_range_eq_truthSet` |
| 73 | 🔵 theorem | `oracle_on_truthSet` |
| 84 | 🔵 theorem | `oracle_compose_self` |
| 94 | 🟠 noncomputable def | `tropicalGate` |
| 103 | 🔵 theorem | `tropicalGate_eq_neg_relu_neg` |
| 114 | 🔵 theorem | `tropicalGate_idempotent` |
| 124 | 🔵 theorem | `tropicalGate_truthSet` |
| 136 | 🔵 theorem | `tropicalGate_monotone` |
| 146 | 🔵 theorem | `tropicalGate_le_zero` |
| 156 | 🔵 theorem | `tropicalGate_le_self` |
| 171 | 🔵 theorem | `oracle_compression` |
| 187 | 🟠 noncomputable def | `geodesicStep` |
| 197 | 🔵 theorem | `geodesicStep_zero_grad` |
| 209 | 🔵 theorem | `geodesicStep_descent` |
| 226 | 🔵 theorem | `strange_loop_convergence` |
| 239 | 🔵 theorem | `meta_oracle_stable` |
| 257 | 🔵 theorem | `holographic_bottleneck_retraction` |
| 274 | 🔵 theorem | `oracle_output_is_truth` |
| 285 | 🔵 theorem | `oracle_range_subset_fixed` |

### 📄 TropicalOracleFormalization.lean

| Line | Kind | Name |
|------|------|------|
| 21 | 🟡 def | `IsIdempotent` |
| 24 | 🟡 def | `TruthSet` |
| 33 | 🔵 theorem | `truthSet_eq_range` |
| 48 | 🔵 theorem | `range_subset_fixedPoints` |
| 59 | 🔵 theorem | `fixedPoints_subset_range` |
| 70 | 🔵 theorem | `idempotent_one_step_convergence` |
| 81 | 🔵 theorem | `idempotent_retraction` |
| 88 | 🟠 noncomputable def | `tropicalGate` |
| 97 | 🔵 theorem | `tropicalGate_eq_neg_relu_neg` |
| 108 | 🔵 theorem | `tropicalGate_idempotent` |
| 120 | 🔵 theorem | `tropicalGate_nonpos` |
| 130 | 🔵 theorem | `tropicalGate_of_nonpos` |
| 140 | 🔵 theorem | `tropicalGate_of_pos` |
| 150 | 🔵 theorem | `tropicalGate_truthSet` |
| 164 | 🔵 theorem | `compression_of_noninjective` |
| 183 | 🔵 theorem | `idempotent_injective_iff_id` |
| 195 | 🔵 theorem | `idempotent_surjective_iff_id` |
| 214 | 🔵 theorem | `idempotent_comp_comm` |
| 229 | 🔵 theorem | `truthSet_comp_supset` |
| 240 | 🔵 theorem | `idempotent_self_comp` |
| 253 | 🔵 theorem | `fisher_metric_nonneg` |
| 264 | 🔵 theorem | `geodesic_step_welldefined` |
| 275 | 🔵 theorem | `effective_lr_bounded` |
| 290 | 🔵 theorem | `rank_composition_bound` |
| 304 | 🔵 theorem | `idempotent_iterate` |
| 317 | 🔵 theorem | `idempotent_id` |
| 327 | 🔵 theorem | `idempotent_const` |
| 341 | 🔵 theorem | `tropical_add_idempotent` |
| 351 | 🔵 theorem | `tropical_distrib` |

### 📄 TropicalOracleResearch.lean

| Line | Kind | Name |
|------|------|------|
| 44 | 🔵 theorem | `trop_add_def` |
| 47 | 🔵 theorem | `trop_mul_def` |
| 51 | 🔵 theorem | `tropical_convex_halfline` |
| 55 | 🔵 theorem | `tropical_convex_inter` |
| 61 | 🔵 theorem | `relu_preserves_tropical_max` |
| 66 | 🔵 theorem | `relu_epigraph` |
| 74 | 🔵 theorem | `lse2_ge_left` |
| 81 | 🔵 theorem | `lse2_ge_right` |
| 95 | 🔵 theorem | `lse2_le_max_log2` |
| 106 | 🔵 theorem | `max_le_lse2` |
| 117 | 🔵 theorem | `exp_max_le_sum_exp` |
| 128 | 🔵 theorem | `quantum_correction_bounded` |
| 139 | 🔵 theorem | `quantum_correction_upper` |
| 149 | 🟡 def | `tropDet` |
| 155 | 🔵 theorem | `tropDet_1x1` |
| 166 | 🔵 theorem | `tropDet_mono` |
| 183 | 🔵 theorem | `tropDet_le_sum_max` |
| 196 | 🔵 theorem | `depth_width_pieces` |
| 206 | 🔵 theorem | `depth_advantage` |
| 212 | 🔵 theorem | `width_one_is_affine` |
| 215 | 🔵 theorem | `layer_doubles_regions` |
| 222 | 🟡 def | `tropInnerProd` |
| 226 | 🔵 theorem | `tropInnerProd_comm` |
| 237 | 🔵 theorem | `tropInnerProd_mono_left` |
| 248 | 🔵 theorem | `tropInnerProd_zero_right` |
| 259 | 🔵 theorem | `tropInnerProd_const` |
| 277 | 🔵 theorem | `relu_lipschitz` |
| 288 | 🔵 theorem | `max_lipschitz_left` |
| 293 | 🔵 theorem | `lipschitz_composition` |
| 307 | 🔵 theorem | `hard_attention_selects_max` |
| 322 | 🔵 theorem | `softmax_bounded` |
| 334 | 🔵 theorem | `neg_entropy_term_nonneg` |
| 340 | 🔵 theorem | `attention_effective_rank_bound` |
| 348 | 🟡 def | `tropTrace` |
| 352 | 🟡 def | `tropMaxDiag` |
| 356 | 🔵 theorem | `tropMaxDiag_eigenvalue_bound` |
| 366 | 🟡 def | `tropCorrelation` |
| 370 | 🔵 theorem | `tropCorrelation_comm` |
| 375 | 🔵 theorem | `tropCorrelation_eq_innerProd` |
| 385 | 🔵 theorem | `tropCorrelation_shift` |
| 404 | 🔵 theorem | `max_subset_le_max` |
| 411 | 🔵 theorem | `relu_information_loss` |
| 415 | 🔵 theorem | `skip_preserves_info` |
| 423 | 🔵 theorem | `tropical_power` |
| 426 | 🔵 theorem | `tropical_geometric_neg` |
| 431 | 🔵 theorem | `tropical_contraction` |
| 439 | 🔵 theorem | `ultrametric_ineq` |
| 443 | 🔵 theorem | `padic_val_pow` |
| 453 | 🔵 theorem | `entropy_nonneg` |
| 457 | 🔵 theorem | `max_entropy_bound` |
| 462 | 🔵 theorem | `quantization_bound` |
| 477 | 🔵 theorem | `bellman_contraction_step` |
| 483 | 🔵 theorem | `bellman_convergence_rate` |
| 493 | 🔵 theorem | `discount_vanishes` |
| 503 | 🔵 theorem | `pwl_breakpoints` |
| 507 | 🔵 theorem | `pruning_locality` |
| 512 | 🟡 def | `tropProjection` |
| 522 | 🔵 theorem | `tropProjection_shift` |
| 528 | 🔵 theorem | `depth_resolution` |
| 537 | 🔵 theorem | `tropical_gap_bound` |
| 542 | 🔵 theorem | `gradient_sparsity_bound` |
| 546 | 🔵 theorem | `optimal_temperature_scaling` |
| 554 | 🔵 theorem | `grand_unification` |
| 564 | 🔵 theorem | `tropical_idempotent` |
| 568 | 🔵 theorem | `selection_principle` |
| 571 | 🔵 theorem | `relu_selection` |
| 573 | 🔵 theorem | `relu_deselection` |
| 576 | 🔵 theorem | `oracle_theorem_count` |

### 📄 TropicalSemiring.lean

| Line | Kind | Name |
|------|------|------|
| 24 | 🟡 def | `relu` |
| 27 | 🔵 theorem | `relu_eq_max` |
| 36 | 🔵 theorem | `relu_of_nonneg` |
| 46 | 🔵 theorem | `relu_of_nonpos` |
| 56 | 🔵 theorem | `relu_relu` |
| 66 | 🔵 theorem | `relu_nonneg` |
| 76 | 🔵 theorem | `relu_monotone` |
| 86 | 🔵 theorem | `relu_not_affine` |
| 101 | 🟡 def | `logSumExp` |
| 111 | 🔵 theorem | `le_logSumExp` |
| 122 | 🔵 theorem | `logSumExp_le_sup_add_log` |
| 141 | 🟡 def | `softmax_component` |
| 151 | 🔵 theorem | `softmax_nonneg` |
| 162 | 🔵 theorem | `softmax_sum_eq_one` |
| 173 | 🔵 theorem | `softmax_shift_invariant` |
| 188 | 🔵 theorem | `exp_add_eq_mul` |
| 199 | 🔵 theorem | `exp_max_eq_max` |
| 206 | 🔵 theorem | `exp_strictMono` |
| 210 | 🔵 theorem | `exp_pos_forall` |
| 229 | 🔵 theorem | `max_affine_is_relu_computable` |
| 244 | 🔵 theorem | `relu_as_max_affine` |
| 261 | 🔵 theorem | `one_hot_entropy_zero` |
| 273 | 🔵 theorem | `exp_not_affine` |
| 293 | 🔵 theorem | `monotone_preserves_max` |

---

## Uncategorized

### 📄 GroupTheoryExploration.lean

| Line | Kind | Name |
|------|------|------|
| 19 | 🔵 theorem | `prime_order_generates` |
| 30 | 🔵 theorem | `order_dvd_card` |
| 37 | 🔵 theorem | `pow_card_eq_one_gen` |
| 44 | 🔵 theorem | `sq_prime_is_comm` |
| 94 | 🔵 theorem | `perm_prod_transpositions` |
| 103 | 🔵 theorem | `sign_swap_neg` |
| 110 | 🔵 theorem | `sign_one_perm` |
| 117 | 🔵 theorem | `sign_mul_perm` |
| 128 | 🔵 theorem | `zmod_card_eq` |
| 138 | 🔵 theorem | `order_prod_lcm` |
| 145 | 🔵 theorem | `card_prod_eq` |

### 📄 O1Impossibility.lean

| Line | Kind | Name |
|------|------|------|
| 57 | 🔵 theorem | `k_from_p` |
| 61 | 🔵 theorem | `p_from_k` |
| 65 | 🔵 theorem | `k_p_equivalence` |
| 70 | 🔵 theorem | `roundtrip_k` |
| 73 | 🔵 theorem | `roundtrip_p` |
| 79 | 🔵 theorem | `factor_condition'` |
| 87 | 🔵 theorem | `four_k_sq_factored` |
| 98 | 🔵 theorem | `no_shortcut_before_p` |
| 111 | 🔵 theorem | `factor_found_at_half_p` |
| 123 | 🔵 theorem | `min_steps_is_half_p` |
| 133 | 🟠 noncomputable def | `closedFormStep` |
| 141 | 🔵 theorem | `closedForm_is_pythagorean` |
| 158 | 🔵 theorem | `o1_factoring_impossible_summary` |

---

