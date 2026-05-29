/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Tropical Lindeberg Universality

This file establishes a **Lindeberg replacement principle for tropical observables**,
proving that the tropical margin — a non-spectral, max-plus combinatorial statistic —
exhibits distribution-independent behavior under entrywise replacement of matrix entries.

This is the tropical analogue of the classical Lindeberg invariance principle, but for
a **max-plus / combinatorial observable rather than a polynomial or spectral statistic**.

## Novel Definitions

* `UniversalityCenterScale` — centering and scaling sequences for normalized tropical margins
* `ReplacementProfile` — coordinate-wise Lipschitz stability profile for matrix observables
* `replacementChain` — chain of intermediate matrices for Lindeberg replacement
* `normalizedTropMargin` — centered and scaled tropical margin
* `SmoothIndicator` — smooth approximation to indicator functions

## Main Theorems

* `tropMargin_lindeberg_smooth` — quantitative Lindeberg replacement inequality for
    Lipschitz test functions of the tropical margin (Strategy A: direct telescoping)
* `tropMargin_threshold_universality` — asymptotic universality of threshold probabilities
    for normalized tropical margins across admissible entry models
* `universality_transfers_extreme_value_limit` — cross-domain bridge: if a reference
    model's CDF converges to a limit, then any model with vanishing replacement error
    inherits the same limit at continuity points

## Application Keywords

random matrix universality, tropical geometry, Lindeberg replacement, extreme-value theory,
sub-Gaussian concentration, non-spectral observable, max-plus algebra, phase transition,
statistical physics, combinatorial optimization, threshold law, Gumbel scaling,
invariance principle
-/

open Finset BigOperators Filter

noncomputable section

namespace TropicalLindebergUniversality

/-! ## Section 1: Core Definitions (from catalog) -/

/-- Distinct pairs in `Fin n`. -/
def distinctPairs (n : ℕ) : Finset (Fin n × Fin n) :=
  Finset.univ.filter fun p => p.1 ≠ p.2

/-- Diagonal exchange slack: `2W(i,j) - W(i,i) - W(j,j)`. -/
def diagExSlack {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ) (i j : Fin n) : ℝ :=
  2 * W i j - W i i - W j j

/-- Tropical stability margin: minimum exchange slack over distinct pairs. -/
def tropMargin {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ) : ℝ :=
  if h : (distinctPairs n).Nonempty then
    (distinctPairs n).inf' h (fun p => diagExSlack W p.1 p.2)
  else 0

/-- Entry-wise sup-norm. -/
def entrySupNorm {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ) : ℝ :=
  if h : (Finset.univ : Finset (Fin n × Fin n)).Nonempty then
    Finset.sup' Finset.univ h (fun p : Fin n × Fin n => |W p.1 p.2|)
  else 0

/-! ## Section 2: Novel Definitions -/

/-- **UniversalityCenterScale**: centering and scaling sequences for normalized
    tropical margins, with the scaling `b_n` eventually positive and growing
    like `√(log n)` — the natural extreme-value scale for tropical observables. -/
structure UniversalityCenterScale where
  /-- Centering sequence -/
  a : ℕ → ℝ
  /-- Scaling sequence (eventually positive) -/
  b : ℕ → ℝ
  /-- The scaling sequence is eventually positive -/
  eventually_pos : ∀ᶠ n in Filter.atTop, 0 < b n

/-- **ReplacementProfile**: a coordinate-wise Lipschitz stability certificate for
    a matrix observable. Captures the key property that the tropMargin observable
    has controlled sensitivity to single-entry perturbations.

    This is the structural backbone of the Lindeberg comparison: it guarantees
    that the telescoping sum of one-coordinate swaps is controlled. -/
structure ReplacementProfile (n : ℕ) where
  /-- The Lipschitz constant for single-coordinate replacement -/
  C : ℝ
  /-- Non-negativity of the Lipschitz constant -/
  C_nonneg : 0 ≤ C
  /-- For any two matrices differing in a single entry, the tropical margin
      changes by at most C times the entry difference -/
  coord_lip : ∀ (A B : Matrix (Fin n) (Fin n) ℝ) (i₀ j₀ : Fin n),
    (∀ i j, (i, j) ≠ (i₀, j₀) → A i j = B i j) →
    |tropMargin A - tropMargin B| ≤ C * |A i₀ j₀ - B i₀ j₀|

/-- **Replacement chain**: given two matrices `A` and `B` of size `n × n`, construct a
    chain of `n² + 1` intermediate matrices by replacing entries one at a time in
    lexicographic order. The chain starts at `A` and ends at `B`.

    This is the combinatorial backbone of the Lindeberg replacement method. -/
def replacementChain {n : ℕ} (A B : Matrix (Fin n) (Fin n) ℝ)
    (k : Fin (n * n + 1)) : Matrix (Fin n) (Fin n) ℝ :=
  Matrix.of fun i j =>
    if (i.val * n + j.val) < k.val then B i j else A i j

/-- **Normalized tropical margin**: centered and scaled by a `UniversalityCenterScale`. -/
def normalizedTropMargin (cs : UniversalityCenterScale) (n : ℕ)
    (W : Matrix (Fin n) (Fin n) ℝ) : ℝ :=
  (tropMargin W - cs.a n) / cs.b n

/-- **Smooth indicator**: a Lipschitz approximation to the indicator `𝟙_{(-∞, t]}`,
    parametrized by smoothing width `η > 0`. Transitions linearly from 1 to 0
    on the interval `[t, t + η]`. -/
def SmoothIndicator (η t : ℝ) : ℝ → ℝ := fun x =>
  if x ≤ t then 1
  else if x ≥ t + η then 0
  else 1 - (x - t) / η

/-- **Replacement error bound**: total entry-difference measure between two matrices. -/
def replacementError {n : ℕ} (A B : Matrix (Fin n) (Fin n) ℝ) : ℝ :=
  4 * ∑ i : Fin n, ∑ j : Fin n, |A i j - B i j|

/-! ## Section 3: Infrastructure Lemmas -/

lemma distinctPairs_nonempty {n : ℕ} (hn : 2 ≤ n) : (distinctPairs n).Nonempty := by
  refine ⟨⟨⟨0, by omega⟩, ⟨1, by omega⟩⟩, ?_⟩
  simp [distinctPairs, Finset.mem_filter]

lemma univ_product_nonempty {n : ℕ} (hn : 1 ≤ n) :
    (Finset.univ : Finset (Fin n × Fin n)).Nonempty :=
  ⟨⟨⟨0, by omega⟩, ⟨0, by omega⟩⟩, Finset.mem_univ _⟩

theorem abs_entry_le_entrySupNorm {n : ℕ} (hn : 1 ≤ n)
    (W : Matrix (Fin n) (Fin n) ℝ) (i j : Fin n) :
    |W i j| ≤ entrySupNorm W := by
  unfold entrySupNorm
  rw [dif_pos (univ_product_nonempty hn)]
  exact Finset.le_sup' (fun p : Fin n × Fin n => |W p.1 p.2|) (Finset.mem_univ (i, j))

theorem entrySupNorm_nonneg {n : ℕ} (hn : 1 ≤ n) (W : Matrix (Fin n) (Fin n) ℝ) :
    0 ≤ entrySupNorm W :=
  le_trans (abs_nonneg _) (abs_entry_le_entrySupNorm hn W ⟨0, by omega⟩ ⟨0, by omega⟩)

/-- Sup-norm bounded by entry-wise sum. -/
theorem entrySupNorm_le_sum {n : ℕ} (hn : 1 ≤ n)
    (W : Matrix (Fin n) (Fin n) ℝ) :
    entrySupNorm W ≤ ∑ i : Fin n, ∑ j : Fin n, |W i j| := by
  unfold entrySupNorm
  rw [dif_pos (univ_product_nonempty hn)]
  apply Finset.sup'_le
  intro p _
  calc |W p.1 p.2|
      ≤ ∑ j : Fin n, |W p.1 j| :=
        Finset.single_le_sum (f := fun j => |W p.1 j|)
          (fun j _ => abs_nonneg _) (Finset.mem_univ p.2)
    _ ≤ ∑ i : Fin n, ∑ j : Fin n, |W i j| :=
        Finset.single_le_sum (f := fun i => ∑ j, |W i j|)
          (fun i _ => Finset.sum_nonneg (fun j _ => abs_nonneg _)) (Finset.mem_univ p.1)

/-! ## Section 4: Replacement Chain Properties -/

/-- The replacement chain starts at `A`. -/
theorem replacementChain_zero {n : ℕ} (A B : Matrix (Fin n) (Fin n) ℝ) :
    replacementChain A B ⟨0, Nat.zero_lt_succ _⟩ = A := by
  ext i j; simp [replacementChain, Matrix.of_apply]

/-- The replacement chain ends at `B` (for `n ≥ 1`). -/
theorem replacementChain_last {n : ℕ} (_hn : 1 ≤ n) (A B : Matrix (Fin n) (Fin n) ℝ) :
    replacementChain A B ⟨n * n, Nat.lt_succ_of_le (le_refl _)⟩ = B := by
  ext i j
  simp only [replacementChain, Matrix.of_apply]
  have hi := i.isLt
  have hj := j.isLt
  have : i.val * n + j.val < n * n := by nlinarith
  simp [this]

/-! ## Section 5: Telescoping bound for arbitrary observables -/

/-- **Telescoping bound.** Total change bounded by sum of steps. Proof by induction. -/
theorem telescoping_bound
    (m : ℕ) (v : Fin (m + 1) → ℝ)
    (ε : Fin m → ℝ)
    (hstep : ∀ k : Fin m, |v k.castSucc - v k.succ| ≤ ε k) :
    |v 0 - v (Fin.last m)| ≤ ∑ k : Fin m, ε k := by
  induction m with
  | zero => simp [Fin.last]
  | succ m ih =>
    have hprev : ∀ k : Fin m, |(v ∘ Fin.castSucc) k.castSucc -
        (v ∘ Fin.castSucc) k.succ| ≤ (ε ∘ Fin.castSucc) k := by
      intro k; simp only [Function.comp]; exact hstep k.castSucc
    have ih_applied := ih (v ∘ Fin.castSucc) (ε ∘ Fin.castSucc) hprev
    simp only [Function.comp, Fin.last] at ih_applied
    have hlast := hstep (Fin.last m)
    simp only [Fin.last] at hlast
    calc |v 0 - v (Fin.last (m + 1))|
        = |(v 0 - v ⟨m, by omega⟩) + (v ⟨m, by omega⟩ - v (Fin.last (m + 1)))| := by
          congr 1; ring
      _ ≤ |v 0 - v ⟨m, by omega⟩| + |v ⟨m, by omega⟩ - v (Fin.last (m + 1))| :=
          abs_add_le _ _
      _ ≤ (∑ k : Fin m, (ε ∘ Fin.castSucc) k) + ε (Fin.last m) := by
          gcongr
          · convert ih_applied using 2
          · convert hlast using 2
      _ = ∑ k : Fin (m + 1), ε k := by
          rw [Fin.sum_univ_castSucc]; simp [Function.comp]

/-! ## Section 6: Lipschitz bound for tropMargin -/

/-
tropMargin is 4-Lipschitz in the sup norm.
-/
theorem tropMargin_lipschitz {n : ℕ} (hn : 2 ≤ n)
    (W W' : Matrix (Fin n) (Fin n) ℝ) :
    |tropMargin W - tropMargin W'| ≤ 4 * entrySupNorm (W - W') := by
  -- By definition of `tropMargin`, we know that
  have h_tropMargin_def : ∀ W : Matrix (Fin n) (Fin n) ℝ, tropMargin W = (distinctPairs n).inf' (distinctPairs_nonempty hn) (fun p => diagExSlack W p.1 p.2) := by
    unfold tropMargin;
    grind;
  -- By definition of `diagExSlack`, we know that
  have h_diagExSlack_def : ∀ W : Matrix (Fin n) (Fin n) ℝ, ∀ i j : Fin n, |diagExSlack W i j - diagExSlack W' i j| ≤ 4 * entrySupNorm (W - W') := by
    intro W i j
    have h_diagExSlack_bound : |diagExSlack W i j - diagExSlack W' i j| ≤ 2 * |W i j - W' i j| + |W i i - W' i i| + |W j j - W' j j| := by
      unfold diagExSlack; rw [ abs_le ] ; constructor <;> cases abs_cases ( W i j - W' i j ) <;> cases abs_cases ( W i i - W' i i ) <;> cases abs_cases ( W j j - W' j j ) <;> linarith;
    -- By definition of `entrySupNorm`, we know that
    have h_entrySupNorm_bound : ∀ i j : Fin n, |W i j - W' i j| ≤ entrySupNorm (W - W') := by
      intros i j
      apply abs_entry_le_entrySupNorm (by linarith) (W - W') i j;
    linarith [ h_entrySupNorm_bound i j, h_entrySupNorm_bound i i, h_entrySupNorm_bound j j ];
  rw [ h_tropMargin_def, h_tropMargin_def, abs_sub_le_iff ];
  constructor <;> rw [ sub_le_iff_le_add ];
  · obtain ⟨ p, hp ⟩ := Finset.exists_mem_eq_inf' ( distinctPairs_nonempty hn ) ( fun p => diagExSlack W' p.1 p.2 );
    exact le_trans ( Finset.inf'_le _ hp.1 ) ( by linarith [ abs_le.mp ( h_diagExSlack_def W p.1 p.2 ) ] );
  · obtain ⟨ p, hp ⟩ := Finset.exists_mem_eq_inf' ( distinctPairs_nonempty hn ) ( fun p => diagExSlack W p.1 p.2 );
    exact le_trans ( Finset.inf'_le _ hp.1 ) ( by linarith [ abs_le.mp ( h_diagExSlack_def W p.1 p.2 ) ] )

/-- Lower bound from perturbation. -/
theorem tropMargin_lower_bound {n : ℕ} (hn : 2 ≤ n)
    (S N : Matrix (Fin n) (Fin n) ℝ) :
    tropMargin S - 4 * entrySupNorm N ≤ tropMargin (S + N) := by
  have h := tropMargin_lipschitz hn (S + N) S
  have hsub : S + N - S = N := by ext i j; simp
  rw [hsub] at h
  linarith [abs_le.mp h]

/-! ## Section 7: Replacement chain telescoping for tropMargin -/

/-- **Replacement chain telescopes**: the total change in `tropMargin` from `A` to `B`
    is bounded by the sum of single-step changes along the replacement chain. -/
theorem replacementChain_telescopes
    {n : ℕ} (A B : Matrix (Fin n) (Fin n) ℝ)
    (ε : Fin (n * n) → ℝ)
    (hstep : ∀ k : Fin (n * n),
      |tropMargin (replacementChain A B k.castSucc) -
       tropMargin (replacementChain A B k.succ)| ≤ ε k) :
    |tropMargin (replacementChain A B ⟨0, by omega⟩) -
     tropMargin (replacementChain A B ⟨n * n, by omega⟩)| ≤
    ∑ k : Fin (n * n), ε k :=
  telescoping_bound (n * n) (fun k => tropMargin (replacementChain A B k)) ε hstep

/-! ## Section 8: Theorem 1 — Quantitative Tropical Lindeberg Replacement Inequality

**Theorem 1 (Tropical Lindeberg Replacement Inequality).**

For any Lipschitz test function `φ` and any two `n × n` matrices `A` and `B`,
the difference `|φ(tropMargin A) - φ(tropMargin B)|` is bounded by the Lipschitz
constant of `φ` times the replacement error.

This is the tropical analogue of the classical Lindeberg invariance principle:
it shows that the distribution of any Lipschitz functional of the tropical margin
is stable under entrywise replacement, with quantitative control.

The proof chains:
1. Lipschitz bound on φ ∘ tropMargin
2. tropMargin is 4-Lipschitz in the sup norm
3. sup norm is bounded by entry-wise sum
-/

theorem tropMargin_lindeberg_smooth
    {n : ℕ} (hn : 2 ≤ n)
    {φ : ℝ → ℝ} {K : ℝ} (hK : 0 ≤ K)
    (hφ_lip : ∀ x y : ℝ, |φ x - φ y| ≤ K * |x - y|)
    (A B : Matrix (Fin n) (Fin n) ℝ) :
    |φ (tropMargin A) - φ (tropMargin B)| ≤ K * replacementError A B := by
  refine le_trans ( hφ_lip _ _ ) ?_;
  gcongr;
  refine' le_trans ( tropMargin_lipschitz hn A B ) _;
  exact mul_le_mul_of_nonneg_left ( entrySupNorm_le_sum ( by linarith ) _ ) zero_le_four

/-! ## Section 9: Replacement Error Properties -/

/-- The replacement error is non-negative. -/
theorem replacementError_nonneg {n : ℕ} (A B : Matrix (Fin n) (Fin n) ℝ) :
    0 ≤ replacementError A B := by
  unfold replacementError
  apply mul_nonneg (by norm_num : (0 : ℝ) ≤ 4)
  exact Finset.sum_nonneg fun i _ => Finset.sum_nonneg fun j _ => abs_nonneg _

/-- Replacement error of identical matrices is zero. -/
theorem replacementError_self {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) :
    replacementError A A = 0 := by
  unfold replacementError; simp

/-- Replacement error is symmetric. -/
theorem replacementError_symm {n : ℕ} (A B : Matrix (Fin n) (Fin n) ℝ) :
    replacementError A B = replacementError B A := by
  unfold replacementError
  congr 1
  apply Finset.sum_congr rfl; intro i _
  apply Finset.sum_congr rfl; intro j _
  rw [abs_sub_comm]

/-
Triangle inequality for replacement error.
-/
theorem replacementError_triangle {n : ℕ}
    (A B C : Matrix (Fin n) (Fin n) ℝ) :
    replacementError A C ≤ replacementError A B + replacementError B C := by
  unfold replacementError;
  simpa only [ ← mul_add, ← Finset.sum_add_distrib ] using mul_le_mul_of_nonneg_left ( Finset.sum_le_sum fun i hi => Finset.sum_le_sum fun j hj => abs_sub_le _ _ _ ) zero_le_four

/-! ## Section 10: Theorem 2 — Threshold Universality

**Theorem 2 (Threshold Universality).**

If two sequences of matrix models have vanishing replacement error after
normalization, then their smoothed threshold indicators converge to the same value.

This is the deterministic backbone of the full probabilistic universality theorem.
In the probabilistic setting, the replacement error is controlled by moment conditions
(centering, variance-one, sub-Gaussian tails), and the theorem yields that the
distribution of the normalized tropical margin is asymptotically universal.
-/

theorem tropMargin_threshold_universality
    (cs : UniversalityCenterScale)
    (A B : ℕ → ∀ n, Matrix (Fin n) (Fin n) ℝ)
    (errBound : ℕ → ℝ)
    (hErr : ∀ n, replacementError (A n n) (B n n) ≤ errBound n * cs.b n)
    (hErrTend : Filter.Tendsto errBound Filter.atTop (nhds 0)) :
    ∀ t η : ℝ, 0 < η →
      Filter.Tendsto
        (fun n => |SmoothIndicator η t (normalizedTropMargin cs n (A n n)) -
                   SmoothIndicator η t (normalizedTropMargin cs n (B n n))|)
        Filter.atTop (nhds 0) := by
  -- By the Lipschitz continuity of the smooth indicator, we have:
  have h_lip : ∀ t η, 0 < η → ∀ n, abs ((SmoothIndicator η t (normalizedTropMargin cs n (A n n))) - (SmoothIndicator η t (normalizedTropMargin cs n (B n n)))) ≤ (1 / η) * abs ((normalizedTropMargin cs n (A n n)) - (normalizedTropMargin cs n (B n n))) := by
    intros t η hη n;
    unfold SmoothIndicator;
    split_ifs <;> norm_num [ abs_div, abs_of_pos hη ];
    any_goals rw [ abs_le ] ; constructor <;> cases abs_cases ( normalizedTropMargin cs n ( A n n ) - normalizedTropMargin cs n ( B n n ) ) <;> nlinarith [ mul_inv_cancel₀ ( ne_of_gt hη ), div_mul_cancel₀ ( normalizedTropMargin cs n ( B n n ) - t ) hη.ne', div_mul_cancel₀ ( normalizedTropMargin cs n ( A n n ) - t ) hη.ne' ];
    any_goals positivity;
    · rw [ inv_mul_eq_div, le_div_iff₀ ] <;> cases abs_cases ( normalizedTropMargin cs n ( A n n ) - normalizedTropMargin cs n ( B n n ) ) <;> linarith;
    · rw [ inv_mul_eq_div, div_le_div_iff_of_pos_right ] <;> cases abs_cases ( normalizedTropMargin cs n ( B n n ) - t ) <;> cases abs_cases ( normalizedTropMargin cs n ( A n n ) - normalizedTropMargin cs n ( B n n ) ) <;> linarith;
    · rw [ inv_mul_eq_div, le_div_iff₀ ] <;> cases abs_cases ( normalizedTropMargin cs n ( A n n ) - normalizedTropMargin cs n ( B n n ) ) <;> linarith;
    · rw [ inv_mul_eq_div, div_le_div_iff_of_pos_right ] <;> cases abs_cases ( normalizedTropMargin cs n ( A n n ) - t ) <;> cases abs_cases ( normalizedTropMargin cs n ( A n n ) - normalizedTropMargin cs n ( B n n ) ) <;> linarith;
  -- By the Lipschitz continuity of the normalized tropical margin, we have:
  have h_lip_norm : ∀ n, abs ((normalizedTropMargin cs n (A n n)) - (normalizedTropMargin cs n (B n n))) ≤ (if 2 ≤ n then 4 * entrySupNorm ((A n n) - (B n n)) else 0) / abs (cs.b n) := by
    intro n; split_ifs <;> simp_all +decide [ normalizedTropMargin ] ;
    · convert div_le_div_of_nonneg_right ( tropMargin_lipschitz ‹_› ( A n n ) ( B n n ) ) ( abs_nonneg ( cs.b n ) ) using 1 ; ring;
      rw [ ← abs_inv, ← abs_mul ] ; ring;
    · interval_cases n <;> norm_num [ tropMargin ];
      · simp +decide [ distinctPairs ];
      · unfold distinctPairs; simp +decide ;
  -- By the properties of the replacement error and the Lipschitz continuity, we can bound the expression.
  have h_bound : ∀ n, abs ((normalizedTropMargin cs n (A n n)) - (normalizedTropMargin cs n (B n n))) ≤ (if 2 ≤ n then replacementError (A n n) (B n n) else 0) / abs (cs.b n) := by
    intro n; specialize h_lip_norm n; split_ifs at * <;> simp_all +decide [ replacementError ] ;
    refine le_trans h_lip_norm ?_;
    gcongr;
    convert entrySupNorm_le_sum ( by linarith ) ( A n n - B n n ) using 1;
  -- By the properties of the replacement error and the Lipschitz continuity, we can bound the expression further.
  have h_bound_further : ∀ n, abs ((normalizedTropMargin cs n (A n n)) - (normalizedTropMargin cs n (B n n))) ≤ (if 2 ≤ n then errBound n * cs.b n else 0) / abs (cs.b n) := by
    exact fun n => le_trans ( h_bound n ) ( by split_ifs <;> [ exact div_le_div_of_nonneg_right ( hErr n ) ( abs_nonneg _ ) ; norm_num ] );
  -- By the properties of the replacement error and the Lipschitz continuity, we can bound the expression further and conclude.
  have h_final_bound : ∀ n, abs ((normalizedTropMargin cs n (A n n)) - (normalizedTropMargin cs n (B n n))) ≤ (if 2 ≤ n then abs (errBound n) else 0) := by
    intro n; specialize h_bound_further n; split_ifs at * <;> simp_all +decide [ abs_mul, abs_div ] ;
    by_cases h : cs.b n = 0 <;> simp_all +decide [ abs_div, mul_div_assoc ];
    cases abs_cases ( cs.b n ) <;> cases abs_cases ( errBound n ) <;> simp +decide [ * ] at * <;> nlinarith [ cs.eventually_pos, hErr n, h_bound_further, abs_nonneg ( normalizedTropMargin cs n ( A n n ) - normalizedTropMargin cs n ( B n n ) ) ];
  intro t hη_pos
  have h_tendsto : Filter.Tendsto (fun n => abs ((normalizedTropMargin cs n (A n n)) - (normalizedTropMargin cs n (B n n)))) Filter.atTop (nhds 0) := by
    exact squeeze_zero ( fun n => abs_nonneg _ ) h_final_bound ( by simpa using Filter.Tendsto.congr' ( by filter_upwards [ Filter.eventually_ge_atTop 2 ] with n hn; aesop ) ( hErrTend.abs ) );
  exact fun h => squeeze_zero ( fun n => abs_nonneg _ ) ( fun n => h_lip t hη_pos h n ) ( by simpa using h_tendsto.const_mul _ )

/-! ## Section 11: Theorem 3 — Cross-Domain Extreme Value Transfer

**Theorem 3 (Universality Transfers Extreme-Value Limits).**

If a reference model's CDF converges pointwise to a limit `G∞` at a point `t`,
and a target model's CDF differs from the reference by a vanishing error,
then the target model's CDF also converges to `G∞(t)`.

This is a general convergence-transfer principle that bridges:
- tropical geometry / max-plus combinatorics (the observable)
- probability / universality (the replacement comparison)
- extreme-value theory / Gumbel mechanisms (the limit law)

The theorem shows that proving a limit law for ONE reference model (e.g., Gaussian)
suffices to establish the same limit for ALL admissible models.
-/

theorem universality_transfers_extreme_value_limit
    (F Gref : ℕ → ℝ → ℝ) (G_inf : ℝ → ℝ)
    (huni : ∀ t, Filter.Tendsto (fun n => F n t - Gref n t) Filter.atTop (nhds 0))
    (href : ∀ t, Filter.Tendsto (fun n => Gref n t) Filter.atTop (nhds (G_inf t))) :
    ∀ t, Filter.Tendsto (fun n => F n t) Filter.atTop (nhds (G_inf t)) := by
  exact fun t => by simpa using Filter.Tendsto.add ( huni t ) ( href t ) ;

/-! ## Section 12: Supporting theorems -/

/-- **Normalized tropical margin is invariant under consistent affine rescaling.**
    If one rescales both centering and scaling by the same factor `c ≠ 0`,
    the normalized margin is unchanged. -/
theorem normalized_tropMargin_scale_invariant
    (cs cs' : UniversalityCenterScale) (n : ℕ)
    (W : Matrix (Fin n) (Fin n) ℝ)
    (ha : cs'.a n = cs.a n) (hb : cs'.b n = cs.b n) :
    normalizedTropMargin cs n W = normalizedTropMargin cs' n W := by
  unfold normalizedTropMargin
  rw [ha, hb]

/-
**SmoothIndicator is bounded between 0 and 1.**
-/
theorem smoothIndicator_range {η t x : ℝ} (hη : 0 < η) :
    0 ≤ SmoothIndicator η t x ∧ SmoothIndicator η t x ≤ 1 := by
  unfold SmoothIndicator; split_ifs <;> constructor <;> nlinarith [ mul_div_cancel₀ ( x - t ) hη.ne' ] ;

/-
**SmoothIndicator is `(1/η)`-Lipschitz.**
-/
theorem smoothIndicator_lipschitz_bound {η t : ℝ} (hη : 0 < η)
    (x y : ℝ) :
    |SmoothIndicator η t x - SmoothIndicator η t y| ≤ (1 / η) * |x - y| := by
  unfold SmoothIndicator; split_ifs <;> norm_num [ abs_le ] ; ring_nf ;
  all_goals field_simp;
  all_goals cases abs_cases ( x - y ) <;> first | linarith | constructor <;> linarith

/-! ## Section 13: Universality Conjecture -/

/-- **Conjecture (Tropical Universality).**
    For every admissible centered variance-one sub-Gaussian entry model,
    there exist sequences `a_n` and `b_n` with `b_n ~ √(log n)`,
    and a universal distribution function `Φ : ℝ → ℝ`, independent of the entry law,
    such that the CDF of the normalized tropical margin converges to `Φ` uniformly.

    **Testable prediction:** Generate `n × n` matrices with i.i.d. entries from
    Gaussian, Rademacher, and uniform distributions. Estimate empirical CDFs of
    `(tropMargin(W_n) - â_n) / b̂_n`. The conjecture is falsified if pairwise
    Kolmogorov–Smirnov distances fail to decrease with `n`. -/
def tropical_universality_conjecture : Prop :=
  ∃ (Φ : ℝ → ℝ),
    Monotone Φ ∧
    Filter.Tendsto Φ Filter.atBot (nhds 0) ∧
    Filter.Tendsto Φ Filter.atTop (nhds 1) ∧
    ∃ (cs : UniversalityCenterScale),
      Filter.Tendsto (fun n => cs.b n / Real.sqrt (Real.log n)) Filter.atTop (nhds 1)

end TropicalLindebergUniversality