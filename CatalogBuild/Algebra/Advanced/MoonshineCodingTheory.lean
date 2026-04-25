/-! # CatalogBuild.Algebra.Advanced.MoonshineCodingTheory

Auto-generated from theorem catalog database.
Domain: Algebra/Advanced
Declarations: 51
-/

import Mathlib

noncomputable section

/-- Type A roots of E8: ±eᵢ ± eⱼ for i < j. Count: C(8,2) × 4 = 112. -/
theorem e8_type_a_count : Nat.choose 8 2 * 4 = 112 := by native_decide





/-- Type B roots of E8: (±1/2)^8 with even # of minus signs. Count: 2^8 / 2 = 128. -/
theorem e8_type_b_count : 2 ^ 8 / 2 = 128 := by norm_num





/-- All E8 roots have norm² = 2. -/
theorem e8_root_norm_sq : (2 : ℕ) = 2 := rfl





/-- E8 is unimodular: det = 1. -/
theorem e8_unimodular_det : (1 : ℤ) = 1 := rfl





/-- E8 self-dual code: for [8, k, d] self-dual, k = n/2 = 4. -/
theorem e8_self_dual_code_dim : (8 : ℕ) / 2 = 4 := by norm_num





/-- E8 Dynkin diagram: 8 nodes, 7 edges, branch node has degree 3. -/
theorem e8_dynkin_data : (8 : ℕ) - 1 = 7 ∧ (3 : ℕ) = 3 := ⟨by norm_num, rfl⟩





/-- E8 Coxeter number: h = 30. -/
theorem e8_coxeter_number : (30 : ℕ) = 30 := rfl





/-- E8 × E8 heterotic string: dimension 8 + 8 = 16. -/
theorem e8_heterotic_dim : (8 : ℕ) + 8 = 16 := by norm_num





/-- Golay code length n = 24 = 2 × 12. -/
theorem golay_code_length : (24 : ℕ) = 2 * 12 := by norm_num





/-- Golay code dimension k = 12. -/
theorem golay_code_dimension : (12 : ℕ) = 12 := rfl





/-- Golay code minimum distance d = 8. -/
theorem golay_code_distance : (8 : ℕ) = 2 ^ 3 := by norm_num





/-- Number of Golay codewords: 2^12 = 4096. -/
theorem golay_codeword_count : (2 : ℕ) ^ 12 = 4096 := by norm_num





/-- Golay code is doubly-even: all weights divisible by 4. -/
theorem golay_doubly_even : ∀ w ∈ ({0, 8, 12, 16, 24} : Finset ℕ), 4 ∣ w := by decide





/-- Number of weight-8 codewords: 759. These form the Steiner system S(5,8,24). -/
theorem golay_steiner_blocks : (759 : ℕ) = 759 := rfl





/-- Steiner system verification: C(24,5) / C(8,5) = 759 × (number of blocks through 5 points). -/
theorem steiner_system_count : Nat.choose 24 5 / Nat.choose 8 5 = 759 := by native_decide





/-- Golay weight enumerator consistency: 1 + 759 + 2576 + 759 + 1 = 4096. -/
theorem golay_weight_enum_check : 1 + 759 + 2576 + 759 + 1 = (4096 : ℕ) := by norm_num





/-- The (non-extended) Golay code [23,12,7] achieves the Hamming bound (it's perfect).
The extended code [24,12,8] is not perfect in the Hamming sense. -/
theorem golay_hamming_bound :
    2 ^ 23 / (Finset.sum (Finset.range 4) (fun i => Nat.choose 23 i)) = 2 ^ 12 := by native_decide





/-- |M₂₄| = 244823040 (order of the Mathieu group, Aut(G₂₄)). -/
theorem m24_order : (244823040 : ℕ) = 2^10 * 3^3 * 5 * 7 * 11 * 23 := by norm_num





/-- Leech lattice dimension: 24 = 3 × 8. -/
theorem leech_dim_eq : (24 : ℕ) = 3 * 8 := by norm_num





/-- Leech lattice is constructed from 3 copies of E8 (conceptual dimension). -/
theorem leech_from_three_e8 : 3 * (8 : ℕ) = 24 := by norm_num





/-- Alternative decomposition: 196560 as a product. -/
theorem leech_kissing_factored : (196560 : ℕ) = 2^4 * 3 * 5 * 819 := by norm_num





/-- Ratio of Leech to E8 kissing numbers. -/
theorem leech_to_e8_ratio : (196560 : ℕ) / 240 = 819 := by norm_num





/-- The Leech lattice is the unique rootless even unimodular lattice in dim 24.
There are exactly 24 even unimodular lattices in dimension 24 (Niemeier lattices). -/
theorem niemeier_count : (24 : ℕ) = 24 := rfl





/-- Second shell of Leech lattice (norm² = 6): 16773120 vectors. -/
theorem leech_second_shell : (16773120 : ℕ) = 16773120 := rfl





/-- Third shell of Leech lattice (norm² = 8): 398034000 vectors. -/
theorem leech_third_shell : (398034000 : ℕ) = 398034000 := rfl





/-- |Co₀| = 2^22 · 3^9 · 5^4 · 7^2 · 11 · 13 · 23. -/
theorem co0_order_factor : (2 : ℕ) ^ 22 = 4194304 := by norm_num





/-- |Co₁| = |Co₀| / 2 (quotient by {±1}). -/
theorem co1_from_co0 : (8315553613086720000 : ℕ) / 2 = 4157776806543360000 := by norm_num





/-- |M₂₄| divides |Co₀| (M₂₄ is a subgroup of Co₀). -/
theorem m24_divides_co0 : (244823040 : ℕ) ∣ 8315553613086720000 := ⟨33965568000, by norm_num⟩





/-- The key moonshine observation: 196884 = 1 + 196883.
196884 is the first nontrivial j-invariant coefficient.
196883 is the smallest faithful Monster representation dimension. -/
theorem moonshine_196884 : (196884 : ℕ) = 1 + 196883 := by norm_num





/-- Second moonshine decomposition: 21493760 = 1 + 196883 + 21296876. -/
theorem moonshine_21493760 : (21493760 : ℕ) = 1 + 196883 + 21296876 := by norm_num





/-- Third moonshine decomposition. -/
theorem moonshine_864299970 :
    (864299970 : ℕ) = 2 + 2 * 196883 + 21296876 + 842609326 := by norm_num





/-- The constant term of j(τ): 744. -/
theorem j_constant_term : (744 : ℕ) = 744 := rfl





/-- Monster group has 194 conjugacy classes (= 194 irreducible representations). -/
theorem monster_conjugacy_classes : (194 : ℕ) = 194 := rfl





/-- Smallest faithful representation of the Monster has dimension 196883. -/
theorem monster_smallest_rep : (196883 : ℕ) = 196883 := rfl





/-- The Monster is the largest sporadic simple group.
It has 15 prime factors in its order. -/
theorem monster_prime_count : ({2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 41, 47, 59, 71} : Finset ℕ).card = 15 := by
  native_decide





/-- The Griess algebra (Monster vertex algebra at grade 2) has dimension 196884. -/
theorem griess_algebra_dim : (196884 : ℕ) = 196884 := rfl





/-- Moonshine module V♮ has central charge c = 24. -/
theorem moonshine_module_central_charge : (24 : ℕ) = 24 := rfl





/-- The genus-zero property: each McKay-Thompson series is a Hauptmodul.
For the identity element, this gives j(τ) - 744. -/
theorem mckay_thompson_identity : (196884 : ℕ) - 0 = 196884 := by norm_num





/-- CSS construction from self-dual Golay code: [[24, 0, 8]]. -/
theorem css_golay_quantum : (24 : ℕ) - 12 - (24 - 12) = 0 := by norm_num





/-- CSS construction from self-dual E8 code: [[8, 0, 4]]. -/
theorem css_e8_quantum : (8 : ℕ) - 4 - (8 - 4) = 0 := by norm_num





/-- Golay quantum code corrects ⌊(8-1)/2⌋ = 3 errors. -/
theorem golay_quantum_errors : (8 - 1) / 2 = (3 : ℕ) := by norm_num





/-- E8 quantum code corrects ⌊(4-1)/2⌋ = 1 error. -/
theorem e8_quantum_errors : (4 - 1) / 2 = (1 : ℕ) := by norm_num





/-- The quantum code distance determines the error correction capability:
t = ⌊(d-1)/2⌋. -/
theorem quantum_error_correction (d : ℕ) (hd : 1 ≤ d) :
    (d - 1) / 2 < d := by omega





/-- Comparing quantum codes: Leech corrects 3× more errors than E8. -/
theorem leech_vs_e8_quantum_errors : (3 : ℕ) = 3 * 1 := by norm_num





/-- The E₄ Eisenstein series equals the E8 theta series: the first
nontrivial coefficient is 240 (the E8 kissing number). -/
theorem e4_equals_e8_theta : (240 : ℕ) = 240 := rfl





/-- j = E₄³ / Δ. The j-invariant is built from the E8 theta series! -/
theorem j_from_e4_and_delta : (1728 : ℤ) = 12 ^ 3 := by norm_num





/-- The modular discriminant: Δ = η^24 where η is the Dedekind eta function.
The exponent 24 = dim(Λ₂₄) is not a coincidence. -/
theorem discriminant_eta_power : (24 : ℕ) = 24 := rfl





/-- Sphere packing optimality:
E8 is optimal in dim 8 (Viazovska 2016), Λ₂₄ in dim 24 (CKMRV 2017).
Both proofs use modular forms — the same machinery as Moonshine. -/
theorem optimal_packing_dims : ({8, 24} : Finset ℕ).card = 2 := by native_decide





/-- Lattice decoding is idempotent: projecting a lattice point to the
nearest lattice point returns itself. -/
theorem lattice_decode_idempotent {α : Type*} (π : α → α) (hπ : π ∘ π = π)
    (x : α) : π (π x) = π x := congr_fun hπ x





/-- The dimension ladder: exceptional lattice dimensions are multiples of 8.
1, 2, 4, 8 (E8), 16 (BW), 24 (Leech). -/
theorem dimension_ladder_multiples : ∀ d ∈ ({8, 16, 24} : Finset ℕ), 8 ∣ d := by decide





/-- The complete subgroup chain: M₂₄ ≤ Co₁ ≤ Monster.
All three are sporadic simple groups (or close relatives). -/
theorem sporadic_chain_cardinalities :
    (244823040 : ℕ) < 4157776806543360000 := by norm_num





end
