/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Soft ECOC Decoding Robustness

This file proves the main robustness theorems for soft-decoding ECOC classifiers
built from tropical Satake score gaps. The central results are:

1. **Decomposition theorem** (`softScore_diff_eq_sum_disagree`): The pairwise soft-score
   difference decomposes exactly over the disagreeing bits of the code matrix.

2. **Score-gap robustness** (`soft_ecoc_robust_of_score_gap`): If the pairwise score
   difference at x exceeds the perturbation budget, then the decoder output is invariant
   on the entire ball.

3. **Margin robustness with sign condition** (`soft_ecoc_robust_of_margin`): Under the
   natural sign-correctness condition `(C ystar j) * g j x ≥ 0` on disagreeing bits,
   the margin-based criterion yields certified robustness.

4. **Uniform margin corollary** (`soft_ecoc_robust_of_uniform_margin`): Under a uniform
   per-bit margin condition γ > L*r and sign correctness, robustness follows.

5. **Certified radius** (`robust_of_radius_lt_min_ratio`): An explicit radius lower bound
   from weighted code-distance.

These results show that tropical Hecke score certificates are compositional: per-bit
certified margins aggregate through an ECOC decoder according to weighted Hamming separation.
-/
import Bridges.ECOCDefs
open scoped BigOperators
open Finset

set_option linter.unusedSectionVars false

variable {α : Type*} [PseudoMetricSpace α]

/-! ## Theorem 1: Pairwise soft-score comparison decomposes over disagreeing bits -/

/-- The pairwise soft-score difference decomposes exactly as a sum over
the disagreeing bits, with each disagreeing bit contributing `2 * (C y j) * g j x`. -/
theorem softScore_diff_eq_sum_disagree
    {n m : ℕ}
    (C : CodeMatrix n m)
    (hC : ValidCodeMatrix C)
    (g : Fin m → α → ℝ)
    (y z : Fin n) (x : α) :
    softScore C g y x - softScore C g z x
      = (disagreeBits C y z).sum (fun j => (2 * (C y j : ℝ)) * g j x) := by
  unfold softScore
  rw [← Finset.sum_sub_distrib]
  rw [← Finset.sum_subset (Finset.subset_univ (disagreeBits C y z))]
  · exact Finset.sum_congr rfl fun j hj =>
      signedBitScore_diff_disagree C hC g y z j x (Finset.mem_filter.mp hj |>.2)
  · simp +contextual [SignedBitScore, disagreeBits]

/-! ## Margin lower bound variant -/

/-- Under a sign-correctness condition on disagreeing bits, the soft-score
difference is bounded below by the sum of doubled certified margins. -/
theorem softScore_diff_lower_bound_by_margins
    {n m : ℕ}
    (C : CodeMatrix n m)
    (hC : ValidCodeMatrix C)
    (g : Fin m → α → ℝ)
    (y z : Fin n) (x : α)
    (hpos : ∀ j ∈ disagreeBits C y z, 0 ≤ (C y j : ℝ) * g j x) :
    0 ≤ (disagreeBits C y z).sum (fun j => (2 : ℝ) * |g j x|) ∧
    (disagreeBits C y z).sum (fun j => (2 : ℝ) * |g j x|)
      ≤ softScore C g y x - softScore C g z x := by
  refine' ⟨Finset.sum_nonneg fun j hj => mul_nonneg zero_le_two (abs_nonneg _), _⟩
  rw [softScore_diff_eq_sum_disagree C hC g y z x]
  refine' Finset.sum_le_sum fun j hj => _
  cases hC y j <;> simp_all +decide
  · rw [abs_of_nonneg]; specialize hpos j hj; aesop
  · cases abs_cases (g j x) <;>
      nlinarith [hpos j hj, show (C y j : ℝ) = -1 by exact_mod_cast ‹C y j = -1›]

/-! ## Perturbation helpers -/

/-
Per-bit perturbation bound: each signed bit score changes by at most L*r.
-/
lemma per_bit_perturbation
    {n m : ℕ} {α : Type*} [PseudoMetricSpace α]
    (C : CodeMatrix n m) (hC : ValidCodeMatrix C)
    (g : Fin m → α → ℝ) (L : ℝ) (hL : BitGapLipschitzOn g L)
    (hL0 : 0 ≤ L) (y : Fin n) (j : Fin m) (x x' : α) (r : ℝ) (hr : dist x x' ≤ r) :
    |(C y j : ℝ) * g j x' - (C y j : ℝ) * g j x| ≤ L * r := by
  have h_bound : |(C y j : ℝ) * g j x' - (C y j : ℝ) * g j x| ≤ |g j x' - g j x| := by
    cases hC y j <;> simp +decide [ * ];
    rw [ neg_add_eq_sub, abs_sub_comm ];
  exact h_bound.trans ( by simpa [ abs_sub_comm ] using hL j x x' |> le_trans <| mul_le_mul_of_nonneg_left hr hL0 )

/-
The softScore difference of two classes at x' differs from that at x by at most
2*L*r per disagreeing bit. Requires L ≥ 0.
-/
theorem softScore_diff_perturbation_bound
    {n m : ℕ}
    (C : CodeMatrix n m)
    (hC : ValidCodeMatrix C)
    (g : Fin m → α → ℝ)
    (L r : ℝ)
    (hL : BitGapLipschitzOn g L)
    (hL0 : 0 ≤ L)
    (y z : Fin n) (x x' : α)
    (hx' : dist x x' ≤ r) :
    |(softScore C g y x' - softScore C g z x')
      - (softScore C g y x - softScore C g z x)|
      ≤ (disagreeBits C y z).sum (fun _ => (2 : ℝ) * L * r) := by
  rw [ softScore_diff_eq_sum_disagree C hC g y z x', softScore_diff_eq_sum_disagree C hC g y z x ];
  rw [ ← Finset.sum_sub_distrib ];
  refine' le_trans ( Finset.abs_sum_le_sum_abs _ _ ) ( Finset.sum_le_sum fun j hj => _ );
  have := per_bit_perturbation C hC g L hL hL0 y j x x' r hx';
  exact abs_le.mpr ⟨ by linarith [ abs_le.mp this ], by linarith [ abs_le.mp this ] ⟩

/-! ## Theorem 2: Score-gap robustness (the fundamental version) -/

/-- **Score-gap robustness.** If the pairwise soft-score difference at x exceeds
the total perturbation budget on disagreeing bits, then the winner is stable on the ball.
This is the most general form of soft ECOC robustness, with no sign conditions needed. -/
theorem soft_ecoc_robust_of_score_gap
    {n m : ℕ}
    (C : CodeMatrix n m)
    (hC : ValidCodeMatrix C)
    (g : Fin m → α → ℝ)
    (L r : ℝ)
    (hL : BitGapLipschitzOn g L)
    (hL0 : 0 ≤ L)
    (ystar : Fin n) (x : α)
    (hsep :
      ∀ z, z ≠ ystar →
        (disagreeBits C ystar z).sum (fun _ => (2 : ℝ) * L * r)
          < softScore C g ystar x - softScore C g z x) :
    ∀ x', dist x x' ≤ r →
      ∀ z, z ≠ ystar → softScore C g ystar x' > softScore C g z x' := by
  intro x' hx' z hz
  have h_diff := softScore_diff_perturbation_bound C hC g L r hL hL0 ystar z x x' hx'
  linarith [abs_le.mp h_diff, hsep z hz]

/-! ## Theorem 3: Margin robustness with sign condition -/

/-
**Margin robustness with sign condition.** Under the natural sign-correctness
condition — that `(C ystar j) * g j x ≥ 0` on all disagreeing bits for each competitor —
the sum of doubled certified margins provides a lower bound on the score gap,
and margin dominance over perturbation budget yields certified robustness.
-/
theorem soft_ecoc_robust_of_margin
    {n m : ℕ}
    (C : CodeMatrix n m)
    (hC : ValidCodeMatrix C)
    (g : Fin m → α → ℝ)
    (L r : ℝ)
    (hL : BitGapLipschitzOn g L)
    (hL0 : 0 ≤ L)
    (ystar : Fin n) (x : α)
    (hsign : ∀ z, z ≠ ystar →
      ∀ j ∈ disagreeBits C ystar z, 0 ≤ (C ystar j : ℝ) * g j x)
    (hsep :
      ∀ z, z ≠ ystar →
        (disagreeBits C ystar z).sum (fun _ => (2 : ℝ) * L * r)
          < (disagreeBits C ystar z).sum (fun j => (2 : ℝ) * |g j x|)) :
    ∀ x', dist x x' ≤ r →
      ∀ z, z ≠ ystar → softScore C g ystar x' > softScore C g z x' := by
  -- By combining the results from the previous theorems, we can conclude the proof.
  intros x' hx' z hz
  apply soft_ecoc_robust_of_score_gap C hC g L r hL hL0 ystar x (fun z hz => by
    exact lt_of_lt_of_le ( hsep z hz ) ( softScore_diff_lower_bound_by_margins C hC g ystar z x ( hsign z hz ) |>.2 )) x' hx' z hz

/-! ## Theorem 4: Uniform margin corollary -/

/-
If every bit has margin at least γ > Lr and the sign condition holds, then
every competitor loses to ystar on the entire ball.
Requires code injectivity to ensure disagreeing bit sets are nonempty.
-/
theorem soft_ecoc_robust_of_uniform_margin
    {n m : ℕ}
    (C : CodeMatrix n m)
    (hC : ValidCodeMatrix C)
    (hinj : CodeInjective C)
    (g : Fin m → α → ℝ)
    (L r gam : ℝ)
    (hL : BitGapLipschitzOn g L)
    (hL0 : 0 ≤ L)
    (ystar : Fin n) (x : α)
    (hsign : ∀ z, z ≠ ystar →
      ∀ j ∈ disagreeBits C ystar z, 0 ≤ (C ystar j : ℝ) * g j x)
    (hgam : ∀ j, gam ≤ |g j x|)
    (hstrict : L * r < gam) :
    ∀ x', dist x x' ≤ r →
      ∀ z, z ≠ ystar → softScore C g ystar x' > softScore C g z x' := by
  -- Apply the soft_ecoc_robust_of_margin theorem with the given hypotheses.
  apply soft_ecoc_robust_of_margin C hC g L r hL hL0 ystar x hsign;
  exact fun z hz => Finset.sum_lt_sum_of_nonempty ( disagreeBits_nonempty_of_ne C hinj ystar z hz.symm ) fun j hj => by nlinarith [ hgam j ] ;

/-! ## Theorem 5: Certified radius from weighted code-distance -/

/-
Robustness when the total perturbation budget per competitor, weighted by the
number of disagreeing bits, is smaller than the pairwise advantage.
-/
theorem robust_of_radius_lt_min_ratio
    {n m : ℕ}
    (C : CodeMatrix n m)
    (hC : ValidCodeMatrix C)
    (g : Fin m → α → ℝ)
    (L r : ℝ)
    (hL : BitGapLipschitzOn g L)
    (hL0 : 0 ≤ L)
    (ystar : Fin n) (x : α)
    (hsign : ∀ z, z ≠ ystar →
      ∀ j ∈ disagreeBits C ystar z, 0 ≤ (C ystar j : ℝ) * g j x)
    (hbound :
      ∀ z, z ≠ ystar →
        2 * L * r * (pairDisagreeCount C ystar z : ℝ)
          < pairAdvantage C g ystar z x) :
    ∀ x', dist x x' ≤ r →
      ∀ z, z ≠ ystar → softScore C g ystar x' > softScore C g z x' := by
  -- Apply the results from the previous theorems to conclude the proof.
  apply soft_ecoc_robust_of_margin C hC g L r hL hL0 ystar x hsign;
  simp_all +decide [mul_comm, mul_left_comm, pairDisagreeCount, pairAdvantage]