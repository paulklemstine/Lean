/-
# Tropical Shtarkov Sums: the abstract layer

## Bridge: max-plus (tropical) algebra ↔ universal source coding ↔ counting

The *Shtarkov sum* (a.k.a. the normalizing constant of the normalized maximum
likelihood distribution) of a model class `{P i}` on a finite sample space `X` is

  `S(P) = ∑_{x ∈ X} sup_i P i x`.

The inner `sup` is exactly a **tropical (max-plus) sum** of the log-likelihoods:
`log sup_i P i x = ⊕_i log P i x`, so `S(P)` is the classical mass of the
tropicalisation of the class, and `log S(P)` is the minimax pointwise regret of
the class.  This file develops the two structural tools used throughout:

* `shtarkovSum_ge_packing` — a *packing* lower bound: any collection of
  (sample, model) pairs contributes to `S`;
* `shtarkovSum_le_card_image` — a *sufficient statistic* upper bound: if the
  pointwise supremum is dominated by a sub-probability measure depending on `x`
  only through a statistic `T`, then `S ≤ |image T|`.

Together with the one-dimensional maximum-likelihood inequality
`bernoulli_ml_le` these give matching upper/lower bounds for finite-state
classes in `Catalog/Tropical/Shtarkov/FiniteState.lean`.
-/

import Mathlib

open Finset

namespace TropicalShtarkov

/-! ## The Shtarkov sum -/

variable {X ι : Type*} [Fintype X]

/-- The Shtarkov sum (NML normalizer) of a family of densities `P : ι → X → ℝ`
on a finite sample space `X`.  Its logarithm is the minimax pointwise regret. -/
noncomputable def shtarkovSum (P : ι → X → ℝ) : ℝ := ∑ x : X, ⨆ i, P i x

omit [Fintype X] in
/-- Under a uniform upper bound the pointwise supremum is `BddAbove`. -/
theorem bddAbove_of_le_one {P : ι → X → ℝ} (hbd : ∀ i x, P i x ≤ 1) (x : X) :
    BddAbove (Set.range fun i => P i x) := by
  refine ⟨1, ?_⟩
  rintro _ ⟨i, rfl⟩
  exact hbd i x

/-- **Packing lower bound.**  Choosing, for every sample `a` in a finite set `A`,
a model `f a`, the total likelihood collected is a lower bound for the Shtarkov
sum.  This is the standard device for lower-bounding minimax regret. -/
theorem shtarkovSum_ge_packing [Nonempty ι] (P : ι → X → ℝ)
    (hnn : ∀ i x, 0 ≤ P i x) (hbd : ∀ i x, P i x ≤ 1)
    (A : Finset X) (f : X → ι) :
    ∑ a ∈ A, P (f a) a ≤ shtarkovSum P := by
  have hb : ∀ x : X, BddAbove (Set.range fun i => P i x) := bddAbove_of_le_one hbd
  have h1 : ∀ x : X, 0 ≤ ⨆ i, P i x := fun x =>
    le_ciSup_of_le (hb x) (Classical.arbitrary ι) (hnn _ _)
  calc ∑ a ∈ A, P (f a) a
      ≤ ∑ a ∈ A, ⨆ i, P i a := Finset.sum_le_sum fun a _ => le_ciSup (hb a) (f a)
    _ ≤ ∑ x : X, ⨆ i, P i x :=
        Finset.sum_le_sum_of_subset_of_nonneg (subset_univ A) fun x _ _ => h1 x

/-- **Sufficient-statistic upper bound.**  If the likelihood of every model at
`x` is dominated by `q (T x) x` for a family `q` of sub-probability measures
indexed by the values of a statistic `T`, then the Shtarkov sum is at most the
number of values the statistic takes.  This is the counting mechanism behind all
`(dimension/2)·log n` regret bounds. -/
theorem shtarkovSum_le_card_image {Y : Type*} [DecidableEq Y] [Nonempty ι]
    (P : ι → X → ℝ) (T : X → Y) (q : Y → X → ℝ)
    (hdom : ∀ i x, P i x ≤ q (T x) x)
    (hqnn : ∀ y x, 0 ≤ q y x)
    (hqsum : ∀ y, ∑ x : X, q y x ≤ 1) :
    shtarkovSum P ≤ (((univ : Finset X).image T).card : ℝ) := by
  have step1 : shtarkovSum P ≤ ∑ x : X, q (T x) x :=
    Finset.sum_le_sum fun x _ => ciSup_le fun i => hdom i x
  have step2 : ∑ x : X, q (T x) x
      = ∑ y ∈ univ.image T, ∑ x ∈ univ with T x = y, q (T x) x :=
    (Finset.sum_fiberwise_of_maps_to (fun x _ => mem_image_of_mem T (mem_univ x)) _).symm
  have step3 : ∀ y ∈ univ.image T, (∑ x ∈ univ with T x = y, q (T x) x) ≤ 1 := by
    intro y _
    have : (∑ x ∈ univ with T x = y, q (T x) x) = ∑ x ∈ univ with T x = y, q y x := by
      refine Finset.sum_congr rfl fun x hx => ?_
      rw [(mem_filter.mp hx).2]
    rw [this]
    exact le_trans (Finset.sum_le_sum_of_subset_of_nonneg (filter_subset _ _)
      fun x _ _ => hqnn y x) (hqsum y)
  calc shtarkovSum P ≤ ∑ x : X, q (T x) x := step1
    _ = ∑ y ∈ univ.image T, ∑ x ∈ univ with T x = y, q (T x) x := step2
    _ ≤ ∑ _y ∈ univ.image T, (1 : ℝ) := Finset.sum_le_sum step3
    _ = (((univ : Finset X).image T).card : ℝ) := by simp

/-- Version of `shtarkovSum_le_card_image` with the crude bound
`|image T| ≤ |Y|`. -/
theorem shtarkovSum_le_card_type {Y : Type*} [DecidableEq Y] [Fintype Y] [Nonempty ι]
    (P : ι → X → ℝ) (T : X → Y) (q : Y → X → ℝ)
    (hdom : ∀ i x, P i x ≤ q (T x) x)
    (hqnn : ∀ y x, 0 ≤ q y x)
    (hqsum : ∀ y, ∑ x : X, q y x ≤ 1) :
    shtarkovSum P ≤ (Fintype.card Y : ℝ) := by
  refine le_trans (shtarkovSum_le_card_image P T q hdom hqnn hqsum) ?_
  exact_mod_cast Finset.card_le_card (subset_univ _)

/-- The trivial upper bound: a class of sub-probability measures has Shtarkov
sum at most `|X|`. -/
theorem shtarkovSum_le_card [Nonempty ι] (P : ι → X → ℝ) (hbd : ∀ i x, P i x ≤ 1) :
    shtarkovSum P ≤ (Fintype.card X : ℝ) := by
  refine le_trans (Finset.sum_le_sum (fun x _ => ciSup_le fun i => hbd i x)) ?_
  rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul, mul_one]

/-! ## The one-dimensional maximum-likelihood inequality

For a Bernoulli source observed `a` times as `true` and `b` times as `false`,
the likelihood `θ^a (1-θ)^b` is maximised at the empirical frequency
`a / (a+b)`.  This is the analytic core of the finite-state upper bound; the
proof is the Gibbs/`log x ≤ x - 1` argument. -/

/-- The maximum-likelihood Bernoulli parameter for `a` successes and `b`
failures (with the convention `0` for the empty sample). -/
noncomputable def mlParam (a b : ℕ) : ℝ := if a + b = 0 then 0 else (a : ℝ) / (a + b)

theorem mlParam_nonneg (a b : ℕ) : 0 ≤ mlParam a b := by
  unfold mlParam
  split
  · exact le_refl 0
  · positivity

/-- Positivity of the denominator in a nonempty sample. -/
theorem cast_add_pos {a b : ℕ} (h : ¬ a + b = 0) : (0 : ℝ) < (a : ℝ) + b := by
  have : 0 < a + b := Nat.pos_of_ne_zero h
  exact_mod_cast this

theorem mlParam_le_one (a b : ℕ) : mlParam a b ≤ 1 := by
  unfold mlParam
  split
  · norm_num
  · rename_i h
    rw [div_le_one (cast_add_pos h)]
    have : (0 : ℝ) ≤ b := Nat.cast_nonneg b
    linarith

/-- **Bernoulli maximum-likelihood inequality.** -/
theorem bernoulli_ml_le (a b : ℕ) {θ : ℝ} (h0 : 0 ≤ θ) (h1 : θ ≤ 1) :
    θ ^ a * (1 - θ) ^ b ≤ mlParam a b ^ a * (1 - mlParam a b) ^ b := by
  have hθ1 : (0:ℝ) ≤ 1 - θ := by linarith
  rcases Nat.eq_zero_or_pos a with ha | ha
  · subst ha
    have hm : mlParam 0 b = 0 := by unfold mlParam; split <;> simp
    rw [hm]
    simp only [pow_zero, one_mul, sub_zero, one_pow, mul_one]
    exact pow_le_one₀ hθ1 (by linarith)
  rcases Nat.eq_zero_or_pos b with hb | hb
  · subst hb
    have hm : mlParam a 0 = 1 := by
      unfold mlParam
      rw [if_neg (by omega)]
      have h : (0:ℝ) < a := by exact_mod_cast ha
      rw [Nat.cast_zero, add_zero, div_self (ne_of_gt h)]
    rw [hm]
    simp only [pow_zero, mul_one, one_pow, sub_self]
    exact pow_le_one₀ h0 h1
  have hab : ¬ a + b = 0 := by omega
  set t := mlParam a b with ht
  have hA : (0:ℝ) < a := by exact_mod_cast ha
  have hB : (0:ℝ) < b := by exact_mod_cast hb
  have hsum : (0:ℝ) < (a:ℝ) + b := by linarith
  have htv : t = (a:ℝ) / ((a:ℝ) + b) := by rw [ht]; unfold mlParam; rw [if_neg hab]
  have ht0 : 0 < t := by rw [htv]; positivity
  have ht1 : t < 1 := by rw [htv, div_lt_one hsum]; linarith
  have h1t : 1 - t = (b:ℝ) / ((a:ℝ) + b) := by rw [htv]; field_simp; ring
  have hRHS : 0 < t ^ a * (1 - t) ^ b := mul_pos (pow_pos ht0 a) (pow_pos (by linarith) b)
  rcases eq_or_lt_of_le h0 with h | hθ0
  · have hz : θ ^ a = 0 := by rw [← h]; exact zero_pow (by omega)
    rw [hz, zero_mul]; exact hRHS.le
  rcases eq_or_lt_of_le h1 with h | hθlt
  · have hz : (1 - θ) ^ b = 0 := by
      rw [h, sub_self]; exact zero_pow (by omega)
    rw [hz, mul_zero]; exact hRHS.le
  have hLHS : 0 < θ ^ a * (1 - θ) ^ b :=
    mul_pos (pow_pos hθ0 a) (pow_pos (by linarith) b)
  rw [← Real.log_le_log_iff hLHS hRHS,
    Real.log_mul (ne_of_gt (pow_pos hθ0 a)) (ne_of_gt (pow_pos (by linarith) b)),
    Real.log_mul (ne_of_gt (pow_pos ht0 a)) (ne_of_gt (pow_pos (by linarith : (0:ℝ) < 1 - t) b)),
    Real.log_pow, Real.log_pow, Real.log_pow, Real.log_pow]
  have k1 : Real.log θ - Real.log t ≤ θ / t - 1 := by
    rw [← Real.log_div (ne_of_gt hθ0) (ne_of_gt ht0)]
    exact Real.log_le_sub_one_of_pos (div_pos hθ0 ht0)
  have k2 : Real.log (1 - θ) - Real.log (1 - t) ≤ (1 - θ) / (1 - t) - 1 := by
    rw [← Real.log_div (by linarith) (by linarith)]
    exact Real.log_le_sub_one_of_pos (div_pos (by linarith) (by linarith))
  have hzero : (a:ℝ) * (θ / t - 1) + (b:ℝ) * ((1 - θ) / (1 - t) - 1) = 0 := by
    have d1 : θ / t = θ * ((a:ℝ) + b) / a := by rw [htv]; field_simp
    have d2 : (1 - θ) / (1 - t) = (1 - θ) * ((a:ℝ) + b) / b := by rw [h1t]; field_simp
    rw [d1, d2]
    field_simp
    ring
  have step1 := mul_le_mul_of_nonneg_left k1 hA.le
  have step2 := mul_le_mul_of_nonneg_left k2 hB.le
  nlinarith [step1, step2, hzero]

end TropicalShtarkov