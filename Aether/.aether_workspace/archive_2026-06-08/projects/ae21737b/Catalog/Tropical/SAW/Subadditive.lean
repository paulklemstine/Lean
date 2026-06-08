/-
Copyright (c) 2024 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Subadditive Sequences and Fekete's Lemma

This file formalizes the theory of subadditive sequences and proves
key results used in the theory of self-avoiding walks to establish
the existence of the connective constant.

## Main results

* `subadditive_mul_bound` — a(kn) ≤ k·a(n) for subadditive sequences
* `subadditive_nonneg_ratio_bdd_below` — a(n)/n is bounded below when a ≥ 0
* `submultiplicative_log_subadditive` — log of submultiplicative is subadditive
* `fekete_key_inequality` — the division bound underlying Fekete's lemma
-/

import Mathlib

open Real

namespace SAW

/-! ## Subadditive sequences -/

/-- A sequence `a : ℕ → ℝ` is subadditive if `a(m + n) ≤ a(m) + a(n)` for all `m, n`. -/
def IsSubadditive (a : ℕ → ℝ) : Prop :=
  ∀ m n : ℕ, a (m + n) ≤ a m + a n

/-- A sequence `a : ℕ → ℝ` is supermultiplicative if `a(m) * a(n) ≤ a(m + n)` for all `m, n`. -/
def IsSupermultiplicative (a : ℕ → ℝ) : Prop :=
  ∀ m n : ℕ, a m * a n ≤ a (m + n)

/-- A sequence `a : ℕ → ℝ` is submultiplicative if `a(m + n) ≤ a(m) * a(n)` for all `m, n`. -/
def IsSubmultiplicative (a : ℕ → ℝ) : Prop :=
  ∀ m n : ℕ, a (m + n) ≤ a m * a n

/-- If `a` is subadditive, then for any positive `k` and `n`, we have `a(k*n) ≤ k * a(n)`. -/
theorem subadditive_mul_bound {a : ℕ → ℝ} (h : IsSubadditive a) :
    ∀ k n : ℕ, 0 < k → a (k * n) ≤ k * a n := by
  intro k n hk; induction hk <;> simp_all +decide [ Nat.succ_mul ] ;
  linarith [ h ( ‹_› * n ) n ]

/-
**Fekete's key inequality**: For a non-negative subadditive sequence,
    writing n = q*k + r (Euclidean division), we get
    a(n) ≤ q * a(k) + a(r).
    When dividing by n, this gives a(n)/n ≤ a(k)/k + a(r)/n
    (using q ≤ n/k).
-/
theorem fekete_key_inequality {a : ℕ → ℝ} (h : IsSubadditive a)
    (ha_nn : ∀ n, 0 ≤ a n)
    (k : ℕ) (hk : 0 < k) (n : ℕ) (hn : 0 < n) :
    a n ≤ (n / k) * a k + a (n % k) := by
      -- Write n = (n/k)*k + (n%k) where n/k is natural division.
      obtain ⟨q, r, hq, hr⟩ : ∃ q r : ℕ, n = q * k + r ∧ r < k := by
        exact ⟨ n / k, n % k, by rw [ Nat.div_add_mod' ], Nat.mod_lt _ hk ⟩;
      by_cases hq0 : q = 0 <;> simp_all +decide [ Nat.mod_eq_of_lt ];
      -- By subadditivity, we have $a(q*k + r) \leq a(q*k) + a(r)$.
      have h_subadd : a (q * k + r) ≤ a (q * k) + a r := by
        exact h _ _;
      -- By subadditivity, we have $a(q*k) \leq q*a(k)$.
      have h_subadd_q : a (q * k) ≤ q * a k := by
        convert subadditive_mul_bound h q k ( Nat.pos_of_ne_zero hq0 ) using 1;
      rw [ div_mul_eq_mul_div, div_add', le_div_iff₀ ] <;> first | positivity | nlinarith [ ha_nn k, ha_nn r ] ;

/-
For non-negative subadditive sequences, the ratios a(n)/n are bounded below by 0.
-/
theorem subadditive_nonneg_ratio_bdd_below {a : ℕ → ℝ} (_h : IsSubadditive a)
    (ha_nn : ∀ n, 0 ≤ a n) :
    BddBelow (Set.range (fun n : ℕ+ => a n / (n : ℝ))) := by
      exact ⟨ 0, Set.forall_mem_range.mpr fun n => div_nonneg ( ha_nn _ ) ( Nat.cast_nonneg _ ) ⟩

/-
**Fekete's Lemma (non-negative version)**: For a non-negative subadditive
    sequence, the infimum of a(n)/n over n > 0 is a lower bound for the
    eventual behavior of a(n)/n.
-/
theorem fekete_inf_le {a : ℕ → ℝ} (_h : IsSubadditive a) (ha_nn : ∀ n, 0 ≤ a n)
    (k : ℕ+) : iInf (fun n : ℕ+ => a n / (n : ℝ)) ≤ a k / (k : ℝ) := by
      refine' csInf_le _ _;
      · exact ⟨ 0, Set.forall_mem_range.2 fun n => div_nonneg ( ha_nn _ ) ( Nat.cast_nonneg _ ) ⟩;
      · exact ⟨ k, rfl ⟩

/-- If `a` is submultiplicative and positive, then `log ∘ a` is subadditive. -/
theorem submultiplicative_log_subadditive {a : ℕ → ℝ} (h : IsSubmultiplicative a)
    (hpos : ∀ n, 0 < a n) :
    IsSubadditive (fun n => Real.log (a n)) := by
  exact fun m n => by simpa [ Real.log_mul ( ne_of_gt ( hpos m ) ) ( ne_of_gt ( hpos n ) ) ] using Real.log_le_log ( hpos _ ) ( h m n ) ;

/-
A subadditive sequence with a(0) = 0 satisfies a(n) ≤ n * a(1).
-/
theorem subadditive_linear_bound {a : ℕ → ℝ} (h : IsSubadditive a)
    (h0 : a 0 = 0) (n : ℕ) : a n ≤ n * a 1 := by
      by_cases hn : n = 0;
      · aesop;
      · simpa using subadditive_mul_bound h n 1 ( Nat.pos_of_ne_zero hn )

/-
For a subadditive sequence, a(0) ≥ 0.
-/
theorem subadditive_zero_nonneg {a : ℕ → ℝ} (h : IsSubadditive a) : 0 ≤ a 0 := by
  linarith [ h 0 0 ]

end SAW