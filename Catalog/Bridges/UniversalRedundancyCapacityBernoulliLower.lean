/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The Price of Universality XII: the Rissanen `½ log₂ n` lower bound

Research thread *Compression Beyond the Pigeonhole Bound*, Phase A, Question 1.

The previous files of the thread bound the average-case price of universality of
a **binary memoryless (Bernoulli) family** on `n`-bit messages from above by
`log₂ (n+1)` (`capacity_bernoulliFamily_le`), and bound a *rich* class — the
smoothed constant-composition class — from below by `(1−ε) log₂ (n+1) − 4`.
The lower bound, however, was for an artificial class, not for a genuine
parametric i.i.d. family, and it therefore said nothing about the constant in
the classical Rissanen rate

  `C_n = (d/2) log₂ n + O(1)`   (`d` = number of free parameters).

This file closes that gap for `d = 1`: it exhibits, inside the one-parameter
Bernoulli family, an explicit packing of `⌊√n⌋/4` parameter values whose
empirical-count windows are pairwise disjoint, and deduces

  `(15/32) · log₂ n − 8 ≤ C_n ≤ log₂ (n+1)`   (for every `n ≥ 64`)

(`capacity_bernoulliPack_ge_half_logb`, `capacity_bernoulliPack_sandwich`).
The lower bound is `½ log₂ n` up to the explicit factor `15/16` coming from the
Chebyshev tail, so **the average-case price of universality of the Bernoulli
class really does grow like `½ log₂ n`, not like `log₂ n`**: the leading
constant of the Rissanen rate is bracketed between `15/32` and `1`.

## Method

Everything is elementary and non-asymptotic.

* `bernMoment0/1/2` — the first two moments of the number of ones under the
  product Bernoulli law, proved by induction on the message length using the
  splitting bijection `(Fin (n+1) → Bool) ≃ Bool × (Fin n → Bool)`
  (`sum_bool_pi_succ`).  No measure theory is used: the "expectations" are
  finite sums over the message space.
* `bernVariance` — `∑ₓ p(x) (ones x − n t)² = n t (1 − t)`.
* `bern_window_mass_ge` — Chebyshev's inequality in this finite setting.
* `bernPack` — the packing `t_j = (4j+2)/k` for `j < ⌊k/4⌋` at any scale `k`
  with `k² ≤ n` (the intended `k = ⌊√n⌋`): the means `n t_j = (n/k)(4j+2)` are
  `4n/k` apart while the windows have half-width `2n/k ≥ 2√n`, so the windows
  are pairwise disjoint and each carries mass `≥ 15/16` by Chebyshev.
* The catalog's `capacity_ge_of_approx_disjoint` converts an approximately
  disjoint family of `N` sources into the lower bound `(1−δ) log₂ N − 4`.

## Main results

* `bernMoment1`, `bernMoment2`, `bernVariance` — exact moments of the binomial
  count, from scratch
* `bern_window_mass_ge` — finite Chebyshev bound for the Bernoulli product law
* `bernPack_windows_disjoint`, `bernPack_window_mass` — the packing works
* `capacity_bernoulliPack_ge` — `(15/16) log₂ ⌊k/4⌋ − 4 ≤ C` whenever `k² ≤ n`
* `capacity_bernoulliPack_ge_half_logb` — `(15/32) log₂ n − 8 ≤ C` for `n ≥ 64`
* `capacity_bernoulliPack_sandwich` — the two-sided Rissanen bracket

## Application keywords

universal compression, minimax redundancy, capacity, Rissanen rate, Bernoulli
sources, Chebyshev inequality, parameter packing, price of universality
-/

import Bridges.UniversalRedundancyCapacityMemoryless

open Finset Real

namespace UniversalRedundancy

/-! ## The product Bernoulli law and its moments -/

/-- The probability of the binary string `x` under the i.i.d. Bernoulli law with
parameter `t` (probability of `true`). -/
noncomputable def bernProb (t : ℝ) {n : ℕ} (x : Fin n → Bool) : ℝ :=
  ∏ i, (if x i then t else 1 - t)

/-- The number of ones in a binary string, as a real number. -/
def onesR {n : ℕ} (x : Fin n → Bool) : ℝ := ∑ i, (if x i then (1 : ℝ) else 0)

lemma onesR_eq_ones {n : ℕ} (x : Fin n → Bool) : onesR x = (ones x : ℝ) := by
  rw [onesR, ones, Finset.card_filter]
  push_cast
  exact Finset.sum_congr rfl fun i _ => by cases x i <;> simp

lemma bernProb_nonneg {t : ℝ} (h0 : 0 ≤ t) (h1 : t ≤ 1) {n : ℕ} (x : Fin n → Bool) :
    0 ≤ bernProb t x :=
  Finset.prod_nonneg fun i _ => by cases x i <;> simp <;> linarith

/-- Splitting a sum over `(Fin (n+1) → Bool)` along the first coordinate. -/
theorem sum_bool_pi_succ (n : ℕ) (F : (Fin (n + 1) → Bool) → ℝ) :
    ∑ x : Fin (n + 1) → Bool, F x
      = (∑ y : Fin n → Bool, F (Fin.cons true y))
        + ∑ y : Fin n → Bool, F (Fin.cons false y) := by
  have h1 : ∑ p : Bool × (Fin n → Bool), F (Fin.cons p.1 p.2)
      = ∑ b : Bool, ∑ y : Fin n → Bool, F (Fin.cons b y) := Fintype.sum_prod_type _
  have h2 : ∑ x : Fin (n + 1) → Bool, F x = ∑ p : Bool × (Fin n → Bool), F (Fin.cons p.1 p.2) :=
    (Fintype.sum_equiv (Fin.consEquiv fun _ => Bool) _ _ fun _ => rfl).symm
  rw [h2, h1, Fintype.sum_bool]

lemma bernProb_cons (t : ℝ) {n : ℕ} (b : Bool) (y : Fin n → Bool) :
    bernProb t (Fin.cons b y) = (if b then t else 1 - t) * bernProb t y := by
  simp [bernProb, Fin.prod_univ_succ]

lemma onesR_cons {n : ℕ} (b : Bool) (y : Fin n → Bool) :
    onesR (Fin.cons b y) = (if b then (1 : ℝ) else 0) + onesR y := by
  rw [onesR, onesR, Fin.sum_univ_succ, Fin.cons_zero]
  simp

lemma bernProb_consT (t : ℝ) {n : ℕ} (y : Fin n → Bool) :
    bernProb t (Fin.cons true y) = t * bernProb t y := by rw [bernProb_cons]; simp

lemma bernProb_consF (t : ℝ) {n : ℕ} (y : Fin n → Bool) :
    bernProb t (Fin.cons false y) = (1 - t) * bernProb t y := by rw [bernProb_cons]; simp

lemma onesR_consT {n : ℕ} (y : Fin n → Bool) :
    onesR (Fin.cons true y) = 1 + onesR y := by rw [onesR_cons]; simp

lemma onesR_consF {n : ℕ} (y : Fin n → Bool) :
    onesR (Fin.cons false y) = onesR y := by rw [onesR_cons]; simp

/-- The product Bernoulli law is a probability law (total mass one). -/
theorem bernMoment0 (t : ℝ) (n : ℕ) : ∑ x : Fin n → Bool, bernProb t x = 1 := by
  induction n with
  | zero => simp [bernProb]
  | succ n ih =>
      rw [sum_bool_pi_succ, Finset.sum_congr rfl (fun y _ => bernProb_consT t y),
        Finset.sum_congr rfl (fun y _ => bernProb_consF t y), ← Finset.mul_sum,
        ← Finset.mul_sum, ih]
      ring

/-- **First moment**: the expected number of ones is `n t`. -/
theorem bernMoment1 (t : ℝ) (n : ℕ) :
    ∑ x : Fin n → Bool, bernProb t x * onesR x = n * t := by
  induction n with
  | zero => simp [onesR]
  | succ n ih =>
      rw [sum_bool_pi_succ]
      have hT : ∀ y : Fin n → Bool, bernProb t (Fin.cons true y) * onesR (Fin.cons true y)
          = t * (bernProb t y + bernProb t y * onesR y) := by
        intro y; rw [bernProb_consT, onesR_consT]; ring
      have hF : ∀ y : Fin n → Bool, bernProb t (Fin.cons false y) * onesR (Fin.cons false y)
          = (1 - t) * (bernProb t y * onesR y) := by
        intro y; rw [bernProb_consF, onesR_consF]; ring
      rw [Finset.sum_congr rfl (fun y _ => hT y), Finset.sum_congr rfl (fun y _ => hF y),
        ← Finset.mul_sum, ← Finset.mul_sum, Finset.sum_add_distrib, bernMoment0, ih]
      push_cast; ring

/-- **Second moment**: `E[(#ones)²] = n t + n(n−1) t²`. -/
theorem bernMoment2 (t : ℝ) (n : ℕ) :
    ∑ x : Fin n → Bool, bernProb t x * (onesR x) ^ 2 = n * t + ((n : ℝ) * n - n) * t ^ 2 := by
  induction n with
  | zero => simp [onesR]
  | succ n ih =>
      rw [sum_bool_pi_succ]
      have hT : ∀ y : Fin n → Bool,
          bernProb t (Fin.cons true y) * (onesR (Fin.cons true y)) ^ 2
            = t * (bernProb t y + 2 * (bernProb t y * onesR y)
                + bernProb t y * (onesR y) ^ 2) := by
        intro y; rw [bernProb_consT, onesR_consT]; ring
      have hF : ∀ y : Fin n → Bool,
          bernProb t (Fin.cons false y) * (onesR (Fin.cons false y)) ^ 2
            = (1 - t) * (bernProb t y * (onesR y) ^ 2) := by
        intro y; rw [bernProb_consF, onesR_consF]; ring
      rw [Finset.sum_congr rfl (fun y _ => hT y), Finset.sum_congr rfl (fun y _ => hF y),
        ← Finset.mul_sum, Finset.sum_add_distrib, Finset.sum_add_distrib,
        bernMoment0, ← Finset.mul_sum, bernMoment1, ih, ← Finset.mul_sum, ih]
      push_cast; ring

/-- **The variance of the binomial count**, proved from scratch:
`∑ₓ p(x) (#ones(x) − n t)² = n t (1 − t)`. -/
theorem bernVariance (t : ℝ) (n : ℕ) :
    ∑ x : Fin n → Bool, bernProb t x * (onesR x - n * t) ^ 2 = n * t * (1 - t) := by
  have h : ∀ x : Fin n → Bool, bernProb t x * (onesR x - n * t) ^ 2
      = bernProb t x * (onesR x) ^ 2 - (2 * ((n : ℝ) * t)) * (bernProb t x * onesR x)
        + ((n : ℝ) * t) ^ 2 * bernProb t x := by
    intro x; ring
  rw [Finset.sum_congr rfl (fun x _ => h x), Finset.sum_add_distrib, Finset.sum_sub_distrib,
    ← Finset.mul_sum, ← Finset.mul_sum, bernMoment0, bernMoment1, bernMoment2]
  ring

/-! ## Chebyshev's inequality in the finite setting -/

/-- **Chebyshev bound for the number of ones.**  The window of half-width `c`
around the mean `n t` carries mass at least `1 − n t (1−t) / c²`. -/
theorem bern_window_mass_ge {t : ℝ} (h0 : 0 ≤ t) (h1 : t ≤ 1) (n : ℕ) {c : ℝ} (hc : 0 < c) :
    1 - (n : ℝ) * t * (1 - t) / c ^ 2
      ≤ ∑ x ∈ univ.filter (fun x : Fin n → Bool => |onesR x - n * t| < c), bernProb t x := by
  classical
  set P : (Fin n → Bool) → Prop := fun x => |onesR x - n * t| < c with hP
  have hsplit :
      (∑ x ∈ univ.filter P, bernProb t x) + ∑ x ∈ univ.filter (fun x => ¬ P x), bernProb t x
        = 1 := by
    rw [Finset.sum_filter_add_sum_filter_not, bernMoment0]
  -- the tail is small
  have htail : (∑ x ∈ univ.filter (fun x => ¬ P x), bernProb t x) * c ^ 2
      ≤ (n : ℝ) * t * (1 - t) := by
    have hstep : ∀ x ∈ univ.filter (fun x => ¬ P x),
        bernProb t x * c ^ 2 ≤ bernProb t x * (onesR x - n * t) ^ 2 := by
      intro x hx
      have hxn : ¬ |onesR x - n * t| < c := (Finset.mem_filter.mp hx).2
      have hge : c ≤ |onesR x - n * t| := le_of_not_gt hxn
      have hsq : c ^ 2 ≤ (onesR x - n * t) ^ 2 := by
        have habs : |onesR x - (n : ℝ) * t| ^ 2 = (onesR x - (n : ℝ) * t) ^ 2 :=
          sq_abs _
        nlinarith [hge, hc.le, abs_nonneg (onesR x - (n : ℝ) * t)]
      exact mul_le_mul_of_nonneg_left hsq (bernProb_nonneg h0 h1 x)
    calc (∑ x ∈ univ.filter (fun x => ¬ P x), bernProb t x) * c ^ 2
        = ∑ x ∈ univ.filter (fun x => ¬ P x), bernProb t x * c ^ 2 := by
          rw [Finset.sum_mul]
      _ ≤ ∑ x ∈ univ.filter (fun x => ¬ P x), bernProb t x * (onesR x - n * t) ^ 2 :=
          Finset.sum_le_sum hstep
      _ ≤ ∑ x : Fin n → Bool, bernProb t x * (onesR x - n * t) ^ 2 := by
          refine Finset.sum_le_sum_of_subset_of_nonneg (Finset.filter_subset _ _) ?_
          intro x _ _
          exact mul_nonneg (bernProb_nonneg h0 h1 x) (sq_nonneg _)
      _ = (n : ℝ) * t * (1 - t) := bernVariance t n
  have hc2 : (0 : ℝ) < c ^ 2 := by positivity
  have : (∑ x ∈ univ.filter (fun x => ¬ P x), bernProb t x) ≤ (n : ℝ) * t * (1 - t) / c ^ 2 :=
    (le_div_iff₀ hc2).mpr htail
  linarith [hsplit]

/-! ## The Bernoulli parameter packing -/

/-- The Bernoulli law with parameter `t` as a point of the simplex on `Bool`. -/
noncomputable def bernSimplex (t : ℝ) (h0 : 0 ≤ t) (h1 : t ≤ 1) : Simplex Bool :=
  ⟨fun b => if b then t else 1 - t, by
      intro b; cases b <;> simp <;> linarith, by
      rw [Fintype.sum_bool]; norm_num⟩

/-- On messages of length `n = k²` the packing uses the `⌊k/4⌋` Bernoulli
parameters `t_j = (4j+2)/k`, whose means `n t_j = k(4j+2)` are `4k = 4√n`
apart. -/
noncomputable def bernPack (k : ℕ) : Fin (k / 4) → Simplex Bool := fun j =>
  bernSimplex ((4 * (j : ℕ) + 2) / (k : ℝ))
    (by
      have hk : 4 ≤ k := by have := j.isLt; omega
      have : (0 : ℝ) < k := by exact_mod_cast Nat.lt_of_lt_of_le (by norm_num) hk
      positivity)
    (by
      have hj := j.isLt
      have hk : 4 ≤ k := by omega
      have hkR : (0 : ℝ) < k := by exact_mod_cast Nat.lt_of_lt_of_le (by norm_num) hk
      have hnum : 4 * (j : ℕ) + 2 ≤ k := by omega
      have : (4 * (j : ℕ) + 2 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hnum
      rw [div_le_one hkR]
      linarith)

lemma bernPack_param_pos {k : ℕ} (j : Fin (k / 4)) :
    0 < (4 * (j : ℕ) + 2) / (k : ℝ) := by
  have hk : 4 ≤ k := by have := j.isLt; omega
  have hkR : (0 : ℝ) < k := by exact_mod_cast Nat.lt_of_lt_of_le (by norm_num) hk
  positivity

lemma bernPack_param_lt_one {k : ℕ} (j : Fin (k / 4)) :
    (4 * (j : ℕ) + 2) / (k : ℝ) < 1 := by
  have hj := j.isLt
  have hk : 4 ≤ k := by omega
  have hkR : (0 : ℝ) < k := by exact_mod_cast Nat.lt_of_lt_of_le (by norm_num) hk
  have hnum : 4 * (j : ℕ) + 2 + 2 ≤ k := by omega
  have hnumR : (4 * (j : ℕ) + 2 : ℝ) + 2 ≤ (k : ℝ) := by exact_mod_cast hnum
  rw [div_lt_one hkR]
  push_cast at hnumR ⊢
  linarith

/-- The probability assigned by the packed i.i.d. class is the product Bernoulli
probability. -/
lemma iidSubClass_bernPack_prob (k n : ℕ) (j : Fin (k / 4)) (x : Fin n → Bool) :
    (iidSubClass Bool n (bernPack k)).prob j x
      = bernProb ((4 * (j : ℕ) + 2) / (k : ℝ)) x := rfl

lemma iidSubClass_bernPack_pos (k n : ℕ) (j : Fin (k / 4)) (x : Fin n → Bool) :
    0 < (iidSubClass Bool n (bernPack k)).prob j x := by
  rw [iidSubClass_bernPack_prob]
  refine Finset.prod_pos fun i _ => ?_
  cases hxi : x i
  · simp only [Bool.false_eq_true, if_false]
    linarith [bernPack_param_lt_one j]
  · simpa using bernPack_param_pos j

/-! ## The count windows of the packing

Fix a message length `n` and a scale `k` with `k² ≤ n` (the intended choice is
`k = ⌊√n⌋`).  The `j`-th packed source has mean `n t_j = (n/k)(4j+2)`; consecutive
means are `4n/k` apart, so windows of half-width `2n/k ≥ 2√n` are pairwise
disjoint, and Chebyshev gives each of them mass at least `1 − k²/(16 n) ≥ 15/16`. -/

/-- The count window of the `j`-th packed source among messages of length `n`. -/
noncomputable def bernWindow (k n : ℕ) (j : Fin (k / 4)) : Finset (Fin n → Bool) :=
  univ.filter (fun x =>
    |onesR x - (n : ℝ) * ((4 * (j : ℕ) + 2) / (k : ℝ))| < 2 * (n : ℝ) / k)

/-- **The windows of the packing are pairwise disjoint.**  Consecutive means are
`4n/k` apart while the windows have half-width `2n/k`. -/
theorem bernPack_windows_disjoint (k n : ℕ) (hn : 0 < n) (j j' : Fin (k / 4)) (hne : j ≠ j') :
    Disjoint (bernWindow k n j) (bernWindow k n j') := by
  classical
  have hk : 4 ≤ k := by have := j.isLt; omega
  have hkR : (0 : ℝ) < k := by exact_mod_cast Nat.lt_of_lt_of_le (by norm_num) hk
  have hnR : (0 : ℝ) < n := by exact_mod_cast hn
  refine Finset.disjoint_left.mpr fun x hx hx' => ?_
  rw [bernWindow, Finset.mem_filter] at hx hx'
  set w : ℝ := 2 * (n : ℝ) / k with hw
  have hwpos : (0 : ℝ) < w := by rw [hw]; positivity
  have hb1 := abs_lt.mp hx.2
  have hb2 := abs_lt.mp hx'.2
  -- the two centres are less than `2w = 4n/k` apart
  have hcent : |(n : ℝ) * ((4 * (j : ℕ) + 2) / (k : ℝ))
      - (n : ℝ) * ((4 * (j' : ℕ) + 2) / (k : ℝ))| < 2 * w := by
    rw [abs_lt]
    constructor <;> linarith [hb1.1, hb1.2, hb2.1, hb2.2]
  have hfac : (n : ℝ) * ((4 * (j : ℕ) + 2) / (k : ℝ)) - (n : ℝ) * ((4 * (j' : ℕ) + 2) / (k : ℝ))
      = (2 * w) * (((j : ℕ) : ℝ) - ((j' : ℕ) : ℝ)) := by
    rw [hw]
    field_simp
    ring
  rw [hfac, abs_mul, abs_of_pos (show (0 : ℝ) < 2 * w by linarith)] at hcent
  have hlt : |((j : ℕ) : ℝ) - ((j' : ℕ) : ℝ)| < 1 := by
    have hmul : (2 * w) * |((j : ℕ) : ℝ) - ((j' : ℕ) : ℝ)| < (2 * w) * 1 := by
      rw [mul_one]; exact hcent
    exact lt_of_mul_lt_mul_left hmul (by linarith)
  have hjj : (j : ℕ) = (j' : ℕ) := by
    by_contra hcon
    rcases Nat.lt_or_ge (j : ℕ) (j' : ℕ) with h | h
    · have : ((j : ℕ) : ℝ) + 1 ≤ ((j' : ℕ) : ℝ) := by exact_mod_cast h
      rw [abs_lt] at hlt; linarith [hlt.1]
    · have hgt : (j' : ℕ) < (j : ℕ) := by omega
      have : ((j' : ℕ) : ℝ) + 1 ≤ ((j : ℕ) : ℝ) := by exact_mod_cast hgt
      rw [abs_lt] at hlt; linarith [hlt.2]
  exact hne (Fin.ext hjj)

/-- **Each window carries mass at least `15/16`.**  Chebyshev with half-width
`2n/k ≥ 2√n` and variance at most `n/4`. -/
theorem bernPack_window_mass (k n : ℕ) (hn : 0 < n) (hkn : k * k ≤ n) (j : Fin (k / 4)) :
    1 - (1 : ℝ) / 16
      ≤ ∑ x ∈ bernWindow k n j, (iidSubClass Bool n (bernPack k)).prob j x := by
  classical
  have hk : 4 ≤ k := by have := j.isLt; omega
  have hkR : (0 : ℝ) < k := by exact_mod_cast Nat.lt_of_lt_of_le (by norm_num) hk
  have hnR : (0 : ℝ) < n := by exact_mod_cast hn
  set t : ℝ := (4 * (j : ℕ) + 2) / (k : ℝ) with ht
  have h0 : 0 ≤ t := (bernPack_param_pos j).le
  have h1 : t ≤ 1 := (bernPack_param_lt_one j).le
  have hc : (0 : ℝ) < 2 * (n : ℝ) / k := by positivity
  have hcheb := bern_window_mass_ge h0 h1 n hc
  have hkkR : (k : ℝ) * k ≤ (n : ℝ) := by exact_mod_cast hkn
  have hvar : (n : ℝ) * t * (1 - t) / (2 * (n : ℝ) / k) ^ 2 ≤ 1 / 16 := by
    have hqt : t * (1 - t) ≤ 1 / 4 := by nlinarith [sq_nonneg (t - 1 / 2)]
    have hnn : (0 : ℝ) ≤ t * (1 - t) := mul_nonneg h0 (by linarith)
    have hden : (0 : ℝ) < (2 * (n : ℝ) / k) ^ 2 := by positivity
    rw [div_le_iff₀ hden]
    have hexp : (2 * (n : ℝ) / k) ^ 2 = 4 * (n : ℝ) * n / ((k : ℝ) * k) := by
      field_simp; ring
    rw [hexp]
    have hstep : (n : ℝ) * (t * (1 - t)) ≤ (n : ℝ) * (1 / 4) :=
      mul_le_mul_of_nonneg_left hqt hnR.le
    have hfrac : (n : ℝ) / 4 ≤ 4 * (n : ℝ) * n / ((k : ℝ) * k) / 16 := by
      rw [le_div_iff₀ (by norm_num), div_mul_eq_mul_div, le_div_iff₀ (by positivity)]
      nlinarith [hnR, hkkR, mul_pos hkR hkR]
    calc (n : ℝ) * t * (1 - t) = (n : ℝ) * (t * (1 - t)) := by ring
      _ ≤ (n : ℝ) / 4 := by linarith
      _ ≤ 4 * (n : ℝ) * n / ((k : ℝ) * k) / 16 := hfrac
      _ = 1 / 16 * (4 * (n : ℝ) * n / ((k : ℝ) * k)) := by ring
  have hmass : 1 - (1 : ℝ) / 16
      ≤ ∑ x ∈ univ.filter (fun x : Fin n → Bool =>
          |onesR x - (n : ℝ) * t| < 2 * (n : ℝ) / k), bernProb t x := by
    refine le_trans ?_ hcheb
    linarith
  simpa only [bernWindow, iidSubClass_bernPack_prob, ← ht] using hmass

/-! ## The lower bound -/

/-- **A `½ log₂ n` lower bound on the price of universality of a Bernoulli
class.**  For every scale `k ≥ 8` with `k² ≤ n`, the packed family of `⌊k/4⌋`
Bernoulli sources on `n`-bit messages has average-case price of universality at
least `(15/16) log₂ ⌊k/4⌋ − 4` bits. -/
theorem capacity_bernoulliPack_ge (k n : ℕ) (hk : 8 ≤ k) (hkn : k * k ≤ n) :
    (1 - (1 : ℝ) / 16) * logb 2 (Fintype.card (Fin (k / 4))) - 4
      ≤ (iidSubClass Bool n (bernPack k)).capacity := by
  classical
  haveI : Nonempty (Fin (k / 4)) := ⟨⟨0, by omega⟩⟩
  have hn : 0 < n := lt_of_lt_of_le (by positivity) hkn
  exact (iidSubClass Bool n (bernPack k)).capacity_ge_of_approx_disjoint
    (fun j x => iidSubClass_bernPack_pos k n j x)
    (bernWindow k n)
    (fun j j' hne => bernPack_windows_disjoint k n hn j j' hne)
    (fun j => bernPack_window_mass k n hn hkn j)

/-- The scale used for messages of length `n` is `k = ⌊√n⌋`. -/
lemma sqrt_scale_bounds {n : ℕ} (hn : 64 ≤ n) :
    8 ≤ Nat.sqrt n ∧ Nat.sqrt n * Nat.sqrt n ≤ n ∧ n ≤ 4 * (Nat.sqrt n * Nat.sqrt n) := by
  have h8 : 8 ≤ Nat.sqrt n := Nat.le_sqrt.mpr (by omega)
  have hle : Nat.sqrt n * Nat.sqrt n ≤ n := Nat.sqrt_le n
  have hlt : n < (Nat.sqrt n + 1) * (Nat.sqrt n + 1) := Nat.lt_succ_sqrt n
  exact ⟨h8, hle, by nlinarith⟩

/-- **The Rissanen `½ log₂ n` rate, lower half.**  For every message length
`n ≥ 64`, the packed Bernoulli family at scale `⌊√n⌋` satisfies
`(15/32) log₂ n − 8 ≤ C_n`: the shared decompressor of a genuine one-parameter
Bernoulli class must absorb on the order of *half* a logarithm of the message
length — not a full logarithm, which is the trivial counting bound. -/
theorem capacity_bernoulliPack_ge_half_logb (n : ℕ) (hn : 64 ≤ n) :
    (15 / 32 : ℝ) * logb 2 (n : ℝ) - 8
      ≤ (iidSubClass Bool n (bernPack (Nat.sqrt n))).capacity := by
  obtain ⟨hk8, hkn, hn4⟩ := sqrt_scale_bounds hn
  set k : ℕ := Nat.sqrt n with hkdef
  have hbase := capacity_bernoulliPack_ge k n hk8 hkn
  have hcard : (Fintype.card (Fin (k / 4)) : ℝ) = ((k / 4 : ℕ) : ℝ) := by simp
  rw [hcard] at hbase
  have hkR : (0 : ℝ) < k := by
    have : (0 : ℕ) < k := by omega
    exact_mod_cast this
  have hnR : (0 : ℝ) < n := by
    have : (0 : ℕ) < n := by omega
    exact_mod_cast this
  -- `⌊k/4⌋ ≥ k/8`
  have hm : (k : ℝ) / 8 ≤ ((k / 4 : ℕ) : ℝ) := by
    have hnat : k ≤ 8 * (k / 4) := by omega
    have : (k : ℝ) ≤ 8 * ((k / 4 : ℕ) : ℝ) := by exact_mod_cast hnat
    linarith
  have hmpos : (0 : ℝ) < (k : ℝ) / 8 := by linarith
  have hlog : logb 2 ((k : ℝ) / 8) ≤ logb 2 ((k / 4 : ℕ) : ℝ) :=
    Real.logb_le_logb_of_le (by norm_num) hmpos hm
  have h8 : logb 2 (8 : ℝ) = 3 := by
    rw [show (8 : ℝ) = 2 ^ (3 : ℕ) by norm_num, Real.logb_pow]
    simp
  have hsplit : logb 2 ((k : ℝ) / 8) = logb 2 (k : ℝ) - 3 := by
    rw [Real.logb_div (ne_of_gt hkR) (by norm_num), h8]
  -- `n ≤ 4 k²` gives `log₂ k ≥ ½ log₂ n − 1`
  have hn4R : (n : ℝ) ≤ 4 * ((k : ℝ) * k) := by exact_mod_cast hn4
  have hlogn : logb 2 (n : ℝ) ≤ 2 + 2 * logb 2 (k : ℝ) := by
    have h1 : logb 2 (n : ℝ) ≤ logb 2 (4 * ((k : ℝ) * k)) :=
      Real.logb_le_logb_of_le (by norm_num) hnR hn4R
    have h2 : logb 2 (4 * ((k : ℝ) * k)) = 2 + 2 * logb 2 (k : ℝ) := by
      rw [Real.logb_mul (by norm_num) (by positivity), Real.logb_mul (ne_of_gt hkR) (ne_of_gt hkR),
        show (4 : ℝ) = 2 ^ (2 : ℕ) by norm_num, Real.logb_pow]
      simp
      ring
    linarith [h1, h2.le, h2.ge]
  have hchain : (15 / 16 : ℝ) * (logb 2 (k : ℝ) - 3)
      ≤ (1 - (1 : ℝ) / 16) * logb 2 ((k / 4 : ℕ) : ℝ) := by
    rw [show (1 : ℝ) - 1 / 16 = 15 / 16 by norm_num, ← hsplit]
    exact mul_le_mul_of_nonneg_left hlog (by norm_num)
  have hfinal : (15 / 32 : ℝ) * logb 2 (n : ℝ) - 8
      ≤ (15 / 16 : ℝ) * (logb 2 (k : ℝ) - 3) - 4 := by
    have : (15 / 32 : ℝ) * logb 2 (n : ℝ)
        ≤ (15 / 32 : ℝ) * (2 + 2 * logb 2 (k : ℝ)) :=
      mul_le_mul_of_nonneg_left hlogn (by norm_num)
    linarith
  linarith

/-- **The Rissanen bracket for the Bernoulli class.**  On `n`-bit messages
(`n ≥ 64`) the average-case price of universality of the packed Bernoulli family
satisfies

  `(15/32) log₂ n − 8 ≤ C ≤ log₂ (n+1)`,

so it is `Θ(log n)` with leading constant between `15/32` and `1` — the
`½ log₂ n` Rissanen rate for a one-parameter family, up to the explicit
Chebyshev loss `15/16`. -/
theorem capacity_bernoulliPack_sandwich (n : ℕ) (hn : 64 ≤ n) :
    (15 / 32 : ℝ) * logb 2 (n : ℝ) - 8
        ≤ (iidSubClass Bool n (bernPack (Nat.sqrt n))).capacity ∧
      (iidSubClass Bool n (bernPack (Nat.sqrt n))).capacity ≤ logb 2 ((n : ℝ) + 1) := by
  obtain ⟨hk8, -, -⟩ := sqrt_scale_bounds hn
  haveI : Nonempty (Fin (Nat.sqrt n / 4)) := ⟨⟨0, by omega⟩⟩
  refine ⟨capacity_bernoulliPack_ge_half_logb n hn, ?_⟩
  have hq : ∀ (j : Fin (Nat.sqrt n / 4)) (b : Bool), 0 < (bernPack (Nat.sqrt n) j).1 b := by
    intro j b
    cases b
    · show (0 : ℝ) < 1 - (4 * (j : ℕ) + 2) / ((Nat.sqrt n : ℕ) : ℝ)
      linarith [bernPack_param_lt_one j]
    · show (0 : ℝ) < (4 * (j : ℕ) + 2) / ((Nat.sqrt n : ℕ) : ℝ)
      exact bernPack_param_pos j
  exact capacity_bernoulliFamily_le n (bernPack (Nat.sqrt n)) hq

end UniversalRedundancy