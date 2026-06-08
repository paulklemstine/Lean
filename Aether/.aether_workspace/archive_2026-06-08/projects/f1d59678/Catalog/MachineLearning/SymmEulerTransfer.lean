/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Coefficient Growth Rate Under Iterated Symmetric Power Transfer

This file formalizes nontrivial coefficient-growth bounds for the local Euler factor
of the symmetric n-th power transfer of an unramified GL₂ parameter (α, β).

The local Euler factor is:
  P_n(T; α, β) = ∏_{j=0}^{n} (1 - α^{n-j} β^j T) = ∑_{k=0}^{n+1} c_{n,k}(α,β) T^k

## Main Results

* `transferExponent` — the exponent profile E(n,k) = kn - k(k-1)/2
* `transferExponent_concave` — discrete concavity of the exponent profile
* `symmEulerCoeff` — the coefficient c_{n,k} as a signed elementary symmetric polynomial
* `symmEuler_coeff_bound` — ‖c_{n,k}‖ ≤ C(n+1,k) · M^{kn} for M = max(‖α‖, ‖β‖)
* `symmEuler_coeff_bound_sharp` — ‖c_{n,k}‖ ≤ C(n+1,k) · M^{E(n,k)} when min(‖α‖,‖β‖) ≤ 1

## References

The polynomial P_n arises as the local factor at an unramified place of the symmetric
n-th power L-function attached to a GL₂ automorphic representation with Satake
parameters α, β.
-/

import Mathlib

open Complex Finset BigOperators

namespace SymmEuler

/-! ## Transfer Exponent Profile -/

/-- The transfer exponent `E(n,k) = k*n - k*(k-1)/2`, representing the maximal
weight sum obtainable by choosing `k` elements from `{n, n-1, ..., 1, 0}`,
or equivalently the support function of the k-th weight polytope slice. -/
def transferExponent (n k : ℕ) : ℕ :=
  k * n - k * (k - 1) / 2

/-
The transfer exponent at full rank: E(n, n+1) = n*(n+1)/2.
-/
theorem transferExponent_full (n : ℕ) :
    transferExponent n (n + 1) = n * (n + 1) / 2 := by
  exact Nat.sub_eq_of_eq_add <| by norm_num; linarith [ Nat.div_mul_cancel ( show 2 ∣ ( n + 1 ) * n from Nat.dvd_of_mod_eq_zero <| by norm_num [ Nat.add_mod, Nat.mod_two_of_bodd ] ), Nat.div_mul_cancel ( show 2 ∣ n * ( n + 1 ) from Nat.dvd_of_mod_eq_zero <| by norm_num [ Nat.add_mod, Nat.mod_two_of_bodd ] ) ] ;

/-
Increment formula: E(n, k+1) = E(n, k) + (n - k) when k ≤ n.
This shows the first difference of the exponent profile is n - k, which is
non-negative and strictly decreasing.
-/
theorem transferExponent_succ (n k : ℕ) (hk : k ≤ n) :
    transferExponent n (k + 1) = transferExponent n k + (n - k) := by
  unfold transferExponent;
  rcases k with ( _ | k ) <;> norm_num [ Nat.mul_succ, Nat.add_mul_div_left ];
  rw [ tsub_add_tsub_comm ];
  · lia;
  · exact Nat.div_le_of_le_mul <| by nlinarith;
  · linarith

/-
Discrete concavity of the transfer exponent profile:
E(n,k) + E(n,k+2) ≤ 2·E(n,k+1). In fact the deficit is exactly 1.
-/
theorem transferExponent_concave (n : ℕ) {k : ℕ} (hk : k + 2 ≤ n + 1) :
    transferExponent n k + transferExponent n (k + 2)
      ≤ 2 * transferExponent n (k + 1) := by
  simp +arith +decide [ transferExponent, mul_add ];
  rw [ tsub_add_tsub_comm ];
  · rw [ Nat.mul_sub_left_distrib ];
    grind;
  · exact Nat.div_le_of_le_mul <| by nlinarith [ Nat.sub_le k 1 ] ;
  · exact Nat.div_lt_of_lt_mul <| by nlinarith

/-
The transfer exponent is maximized at k = n+1 (or k = n, where the value is the same).
-/
theorem transferExponent_mono (n k : ℕ) (hk : k ≤ n + 1) :
    transferExponent n k ≤ transferExponent n (n + 1) := by
  -- By definition of $transferExponent$, we know that $transferExponent n k ≤ transferExponent n (n + 1)$ for all $k \leq n + 1$.
  unfold transferExponent;
  rcases hk with ( _ | hk ) <;> norm_num at *;
  rcases k with ( _ | k ) <;> norm_num at *;
  nlinarith [ Nat.div_mul_le_self ( ( n + 1 ) * n ) 2, Nat.div_add_mod ( ( k + 1 ) * k ) 2, Nat.mod_lt ( ( k + 1 ) * k ) two_pos, Nat.sub_add_cancel ( show ( n + 1 ) * n / 2 ≤ ( n + 1 ) * n from Nat.div_le_self _ _ ) ]

/-! ## Combinatorial Bounds on Subset Sums -/

/-
The minimum sum of a k-element subset of {0, ..., n} is k*(k-1)/2.
This is achieved by choosing {0, 1, ..., k-1}.
-/
theorem subset_sum_lower_bound {n k : ℕ} (S : Finset ℕ)
    (hS : S ⊆ Finset.range (n + 1)) (hcard : S.card = k) :
    k * (k - 1) / 2 ≤ S.sum id := by
  -- Since $S$ is a subset of $\{0, 1, ..., n\}$ with $k$ elements, we can order its elements as $a_1 < a_2 < ... < a_k$.
  have h_order : ∃ a : Fin k → ℕ, StrictMono a ∧ S = Finset.image a Finset.univ := by
    use fun i => S.orderEmbOfFin ( by aesop ) i;
    simp +decide [ StrictMono ];
    rw [ Finset.eq_of_subset_of_card_le ( Finset.image_subset_iff.mpr fun i _ => Finset.orderEmbOfFin_mem _ _ _ ) ( by rw [ Finset.card_image_of_injective ] <;> aesop_cat ) ];
  -- Since $a$ is strictly monotone, we have $a i ≥ i$ for all $i$.
  obtain ⟨a, ha_mono, ha_image⟩ := h_order
  have ha_ge_id : ∀ i : Fin k, a i ≥ i := by
    intro ⟨ i, hi ⟩ ; induction' i with i ih;
    · exact Nat.zero_le _;
    · exact Nat.succ_le_of_lt ( lt_of_le_of_lt ( ih ( Nat.lt_of_succ_lt hi ) ) ( ha_mono ( Nat.lt_succ_self _ ) ) );
  rw [ ha_image, Finset.sum_image <| by intros i hi j hj hij; exact ha_mono.injective hij ];
  exact le_trans ( by rw [ ← Finset.sum_range_id ] ; rw [ Finset.sum_range ] ) ( Finset.sum_le_sum fun i _ => ha_ge_id i )

/-
The maximum sum of a k-element subset of {0, ..., n} is k*n - k*(k-1)/2.
This is achieved by choosing {n-k+1, ..., n}.
-/
theorem subset_sum_upper_bound {n k : ℕ} (S : Finset ℕ)
    (hS : S ⊆ Finset.range (n + 1)) (hcard : S.card = k)
    (hk : k ≤ n + 1) :
    S.sum id ≤ k * n - k * (k - 1) / 2 := by
  refine' Nat.le_sub_of_add_le _;
  have h_max_sum : ∀ (S : Finset ℕ), S ⊆ Finset.range (n + 1) → S.card = k → S.sum id + k * (k - 1) / 2 ≤ k * n := by
    intro S hS hcard
    have h_sorted : ∃ f : Fin k → ℕ, StrictAnti f ∧ ∀ i, f i ∈ S ∧ f i ≤ n := by
      exact ⟨ fun i => S.orderEmbOfFin ( by aesop ) ( Fin.rev i ), by aesop_cat, fun i => ⟨ by aesop, by linarith [ Finset.mem_range.mp ( hS ( by aesop : S.orderEmbOfFin ( by aesop ) ( Fin.rev i ) ∈ S ) ) ] ⟩ ⟩
    obtain ⟨f, hf_anti, hf_mem⟩ := h_sorted
    have h_sum_le : ∑ i ∈ Finset.univ.image f, i + k * (k - 1) / 2 ≤ k * n := by
      have h_sum_le : ∑ i ∈ Finset.univ.image f, i + ∑ i ∈ Finset.range k, i ≤ k * n := by
        have h_sum_le : ∀ i : Fin k, f i + i ≤ n := by
          intro i
          induction' i with i ih;
          induction' i with i ih;
          · simpa using hf_mem _ |>.2;
          · exact Nat.le_of_lt_succ ( by linarith! [ hf_anti ( show ⟨ i, by linarith ⟩ < ⟨ i + 1, by linarith ⟩ from Nat.lt_succ_self _ ), ‹∀ ( ih : i < k ), f ⟨ i, ih ⟩ + i ≤ n› ( by linarith ) ] );
        rw [ Finset.sum_image <| by intros i hi j hj hij; exact hf_anti.injective hij ];
        simpa [ Finset.sum_add_distrib, Finset.sum_range ] using Finset.sum_le_sum fun i ( hi : i ∈ Finset.univ ) => h_sum_le i;
      convert h_sum_le using 2;
      rw [ Finset.sum_range_id ];
    rwa [ Finset.eq_of_subset_of_card_le ( Finset.image_subset_iff.mpr fun i _ => hf_mem i |>.1 ) ( by rw [ Finset.card_image_of_injective _ hf_anti.injective, Finset.card_fin, hcard ] ) ] at h_sum_le;
  exact h_max_sum S hS hcard

/-! ## Symmetric Power Euler Factor Coefficients -/

/-- The k-th coefficient of the symmetric n-th power Euler factor
`∏_{j=0}^{n} (1 - α^{n-j} β^j T)`, expressed as the signed k-th elementary
symmetric polynomial of the root multiset `{α^n, α^{n-1}β, ..., β^n}`. -/
noncomputable def symmEulerCoeff (α β : ℂ) (n k : ℕ) : ℂ :=
  (-1 : ℂ) ^ k * ∑ S ∈ (Finset.range (n + 1)).powersetCard k,
    ∏ j ∈ S, (α ^ (n - j) * β ^ j)

/-! ## Norm Bounds on Individual Roots and Products -/

/-
Each Satake root α^{n-j} β^j has norm at most M^n where M = max(‖α‖, ‖β‖).
-/
lemma root_norm_le (α β : ℂ) (n j : ℕ) (hj : j ≤ n) :
    ‖α ^ (n - j) * β ^ j‖ ≤ (max ‖α‖ ‖β‖) ^ n := by
  cases max_cases ‖α‖ ‖β‖ <;> refine' le_trans ( norm_mul_le _ _ ) _ <;> simp_all +decide [ pow_add, pow_mul ];
  · exact le_trans ( mul_le_mul_of_nonneg_left ( pow_le_pow_left₀ ( norm_nonneg _ ) ‹_› _ ) ( pow_nonneg ( norm_nonneg _ ) _ ) ) ( by rw [ ← pow_add, Nat.sub_add_cancel hj ] );
  · exact le_trans ( mul_le_mul_of_nonneg_right ( pow_le_pow_left₀ ( norm_nonneg _ ) ( by linarith ) _ ) ( pow_nonneg ( norm_nonneg _ ) _ ) ) ( by rw [ ← pow_add, Nat.sub_add_cancel hj ] )

/-
The norm of a product of roots over a subset S ⊆ {0,...,n} is at most M^{|S|·n}.
-/
lemma root_prod_norm_le (α β : ℂ) (n : ℕ) (S : Finset ℕ)
    (hS : S ⊆ Finset.range (n + 1)) :
    ‖∏ j ∈ S, (α ^ (n - j) * β ^ j)‖ ≤ (max ‖α‖ ‖β‖) ^ (S.card * n) := by
  convert Finset.prod_le_prod ?_ fun x hx => root_norm_le α β n x ?_ using 1;
  convert norm_prod _ _;
  · infer_instance;
  · infer_instance;
  · rw [ Finset.prod_const, pow_mul' ];
  · exact fun _ _ => norm_nonneg _;
  · grind

/-! ## Main Coefficient Growth Bound -/

/-
**Theorem 1 (Coefficient Growth Bound)**: For complex Satake parameters α, β
with M = max(‖α‖, ‖β‖), the k-th coefficient of the symmetric n-th power
Euler factor satisfies: ‖c_{n,k}‖ ≤ C(n+1, k) · M^{kn}.

This follows from the triangle inequality applied to the elementary symmetric
polynomial expansion, bounding each of the C(n+1,k) summands by M^{kn}.
-/
theorem symmEuler_coeff_bound (α β : ℂ) (n k : ℕ) (_hk : k ≤ n + 1) :
    ‖symmEulerCoeff α β n k‖
      ≤ (Nat.choose (n + 1) k : ℝ) * (max ‖α‖ ‖β‖) ^ (k * n) := by
  unfold symmEulerCoeff;
  nontriviality;
  simp +zetaDelta at *;
  refine' le_trans ( norm_sum_le _ _ ) _;
  refine' le_trans ( Finset.sum_le_sum fun x hx => root_prod_norm_le α β n x _ ) _;
  · exact Finset.mem_powersetCard.mp hx |>.1;
  · rw [ Finset.sum_congr rfl fun x hx => by rw [ Finset.mem_powersetCard.mp hx |>.2 ] ] ; norm_num

/-! ## Sharp Bound Under Unitarity -/

/-
When min(‖α‖, ‖β‖) ≤ 1 and ‖α‖ ≥ ‖β‖, each root has norm at most M^{n-j}.
-/
lemma root_norm_le_sharp_case1 (α β : ℂ) (n j : ℕ) (_hj : j ≤ n)
    (hβ : ‖β‖ ≤ 1) :
    ‖α ^ (n - j) * β ^ j‖ ≤ ‖α‖ ^ (n - j) := by
  -- By the properties of norms, we can split the norm of the product into the product of the norms.
  simp [norm_mul];
  exact mul_le_of_le_one_right ( by positivity ) ( pow_le_one₀ ( by positivity ) hβ )

/-
When min(‖α‖, ‖β‖) ≤ 1 and ‖β‖ ≥ ‖α‖, each root has norm at most M^j.
-/
lemma root_norm_le_sharp_case2 (α β : ℂ) (n j : ℕ) (_hj : j ≤ n)
    (hα : ‖α‖ ≤ 1) :
    ‖α ^ (n - j) * β ^ j‖ ≤ ‖β‖ ^ j := by
  simpa [ norm_mul ] using mul_le_mul ( pow_le_one₀ ( norm_nonneg α ) hα ) le_rfl ( by positivity ) ( by positivity )

/-
**Theorem 2 (Sharp Coefficient Bound Under Unitarity)**:
When min(‖α‖, ‖β‖) ≤ 1 (as is the case for unitarily normalized Satake parameters
where |αβ| = 1), the k-th coefficient satisfies the sharper bound:
  ‖c_{n,k}‖ ≤ C(n+1, k) · M^{E(n,k)}
where E(n,k) = kn - k(k-1)/2 is the transfer exponent.

The exponent E(n,k) is the maximal weight sum obtained by choosing k roots from the
weight multiset {n, n-1, ..., 0}, and this bound is tight.
-/
theorem symmEuler_coeff_bound_sharp (α β : ℂ) (n k : ℕ) (hk : k ≤ n + 1)
    (hm : min ‖α‖ ‖β‖ ≤ 1) (hM : 1 ≤ max ‖α‖ ‖β‖) :
    ‖symmEulerCoeff α β n k‖
      ≤ (Nat.choose (n + 1) k : ℝ) *
        (max ‖α‖ ‖β‖) ^ (transferExponent n k) := by
  -- Let's unfold the definition of `symmEulerCoeff`.
  unfold symmEulerCoeff;
  -- By the properties of norms, we can factor out the constant term and apply the triangle inequality to the sum.
  suffices h_norm : ∀ S ∈ Finset.powersetCard k (Finset.range (n + 1)), ‖∏ j ∈ S, α ^ (n - j) * β ^ j‖ ≤ (max ‖α‖ ‖β‖) ^ (transferExponent n k) by
    simpa [ norm_mul, Finset.card_univ ] using le_trans ( norm_sum_le _ _ ) ( Finset.sum_le_sum h_norm );
  intro S hS;
  cases le_total ‖α‖ ‖β‖ <;> simp_all +decide [ transferExponent ];
  · -- Since ‖α‖ ≤ 1, we have ‖α‖^(n-j) ≤ 1 for all j. Therefore, the product of the norms of the terms in S is at most ‖β‖^(sum of j over S).
    have h_prod_le_beta_sum : ∏ j ∈ S, ‖α‖ ^ (n - j) * ‖β‖ ^ j ≤ ‖β‖ ^ (∑ j ∈ S, j) := by
      rw [ Finset.prod_mul_distrib, Finset.prod_pow_eq_pow_sum ];
      exact le_trans ( mul_le_of_le_one_left ( Finset.prod_nonneg fun _ _ => by positivity ) ( pow_le_one₀ ( by positivity ) hm ) ) ( by rw [ Finset.prod_pow_eq_pow_sum ] );
    exact h_prod_le_beta_sum.trans ( pow_le_pow_right₀ hM <| by simpa [ hS.2 ] using subset_sum_upper_bound S hS.1 hS.2 hk );
  · -- Since ‖β‖ ≤ 1, we have ‖β‖^x ≤ 1 for all x.
    have h_beta_le_one : ∏ x ∈ S, ‖β‖ ^ x ≤ 1 := by
      exact Finset.prod_le_one ( fun _ _ => by positivity ) fun _ _ => pow_le_one₀ ( by positivity ) hm;
    simp_all +decide [ Finset.prod_mul_distrib, Finset.prod_pow_eq_pow_sum ];
    refine' le_trans ( mul_le_mul_of_nonneg_left h_beta_le_one <| by positivity ) _;
    have h_sum_bound : ∑ i ∈ S, (n - i) ≤ k * n - k * (k - 1) / 2 := by
      have h_sum_bound : ∑ i ∈ S, (n - i) = k * n - ∑ i ∈ S, i := by
        exact eq_tsub_of_add_eq ( by rw [ ← hS.2, ← Finset.sum_add_distrib ] ; rw [ Finset.sum_congr rfl fun x hx => tsub_add_cancel_of_le <| Finset.mem_range_succ_iff.mp <| hS.1 hx ] ; simp +decide );
      exact h_sum_bound ▸ Nat.sub_le_sub_left ( by simpa [ hS.2 ] using subset_sum_lower_bound S hS.1 hS.2 ) _;
    simpa using pow_le_pow_right₀ hM h_sum_bound

/-! ## Maximum Coefficient Norm -/

/-- The maximum coefficient norm of the symmetric n-th power Euler factor.
Defined as the supremum of ‖c_{n,k}‖ over k ∈ {0, ..., n+1}. -/
noncomputable def maxCoeffNorm (α β : ℂ) (n : ℕ) : ℝ :=
  Finset.sup' (Finset.range (n + 2)) (by simp) (fun k => ‖symmEulerCoeff α β n k‖)

/-
**Theorem 3 (Maximum Coefficient Bound)**: The maximum coefficient norm satisfies:
  maxCoeffNorm(α,β,n) ≤ C(n+1, ⌊(n+1)/2⌋) · M^{n(n+1)/2}
when min(‖α‖,‖β‖) ≤ 1 and M = max(‖α‖,‖β‖) ≥ 1.
-/
theorem symmEuler_maxCoeff_bound (α β : ℂ) (n : ℕ)
    (hm : min ‖α‖ ‖β‖ ≤ 1) (hM : 1 ≤ max ‖α‖ ‖β‖) :
    maxCoeffNorm α β n
      ≤ (Nat.choose (n + 1) ((n + 1) / 2) : ℝ) *
        (max ‖α‖ ‖β‖) ^ (n * (n + 1) / 2) := by
  refine' Finset.sup'_le _ _ _;
  intro k hk
  have h_coeff_bound : ‖symmEulerCoeff α β n k‖ ≤ (Nat.choose (n + 1) k : ℝ) * (max ‖α‖ ‖β‖) ^ (transferExponent n k) := by
    apply symmEuler_coeff_bound_sharp α β n k (by linarith [Finset.mem_range.mp hk]) hm hM;
  -- Since $k \leq n+1$, we have $C(n+1, k) \leq C(n+1, (n+1)/2)$.
  have h_binom_bound : (Nat.choose (n + 1) k : ℝ) ≤ (Nat.choose (n + 1) ((n + 1) / 2) : ℝ) := by
    exact_mod_cast Nat.choose_le_middle k _;
  refine le_trans h_coeff_bound <| mul_le_mul ?_ ?_ ?_ ?_;
  · convert h_binom_bound using 1;
  · exact pow_le_pow_right₀ hM ( transferExponent_mono n k ( Finset.mem_range_succ_iff.mp hk ) |> le_trans <| by rw [ transferExponent_full ] );
  · finiteness;
  · positivity

/-! ## Tropical Transfer Envelope -/

/-- The tropical transfer envelope: the logarithmic upper bound for the
coefficient growth, defined as log C(n+1,k) + E(n,k) · log M.
This packages the coefficient-growth problem as a tropical support-function estimate. -/
noncomputable def tropicalTransferEnvelope (M : ℝ) (n k : ℕ) : ℝ :=
  Real.log (Nat.choose (n + 1) k) + (transferExponent n k : ℝ) * Real.log M

/-
**Theorem 4 (Tropical Coefficient Envelope)**: When min(‖α‖,‖β‖) ≤ 1,
M = max(‖α‖,‖β‖) > 1, and the coefficient is nonzero:
  log ‖c_{n,k}‖ ≤ tropicalTransferEnvelope M n k
-/
theorem logCoeff_bound_tropical (α β : ℂ) (n k : ℕ)
    (hk : k ≤ n + 1)
    (hm : min ‖α‖ ‖β‖ ≤ 1) (hM : 1 < max ‖α‖ ‖β‖)
    (hne : symmEulerCoeff α β n k ≠ 0) :
    Real.log ‖symmEulerCoeff α β n k‖
      ≤ tropicalTransferEnvelope (max ‖α‖ ‖β‖) n k := by
  convert Real.log_le_log ?_ ( symmEuler_coeff_bound_sharp α β n k hk ( by simpa using hm ) hM.le ) using 1;
  · rw [ Real.log_mul ( Nat.cast_ne_zero.mpr <| Nat.ne_of_gt <| Nat.choose_pos hk ) ( pow_ne_zero _ <| by positivity ), Real.log_pow ] ; norm_cast;
  · exact norm_pos_iff.mpr hne

end SymmEuler