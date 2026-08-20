/-
# How rare is a knee?  The exact census count and its vanishing density

Cycle 4 of the NET-47 thread.  Cycle 2 counted the grid-admissible staircase numbers inside one
dyadic octave (`n - g` of them).  Summing over octaves gives a *global* count, and the global
count is what turns the structural findings into a quantitative statement about how constrained a
knee reading is.

* `KneeStaircase.staircaseCount_succ` — each octave contributes exactly one more candidate than
  the previous one: `A(n+1) = A(n) + (n+1)`.
* `KneeStaircase.staircaseCount_formula` — hence the closed form
  `2·A(n) = n(n+1) + 2`, i.e. `A(n) = n(n+1)/2 + 1` staircase numbers in `[1, 2^n]`
  (a triangular number plus one).
* `KneeStaircase.net47_staircaseCount` — at the NET-47 scale, `A(7) = 29`: only 29 of the 128
  possible knee values below the product point are staircase numbers at all, and only three of
  them survive the `16`-grid (cycle 2).
* `KneeStaircase.staircase_density_tendsto_zero` — the bridge to analysis: the density
  `A(n)/2^n` of staircase numbers tends to `0`.  Knee candidates are *asymptotically negligible*:
  the probability that a uniformly random value below the product point has staircase form
  vanishes as the context grows, so the empirical fact that every measured knee has this form is
  a strong structural constraint, not a coincidence of small numbers.
-/

import Mathlib
import Catalog.NumberTheory.KneeStaircaseArithmetic
import Catalog.NumberTheory.KneeStaircaseOctaveCensus

namespace KneeStaircase

open Filter

open scoped Classical in
/-- The number of staircase numbers in `[1, 2 ^ n]`. -/
noncomputable def staircaseCount (n : ℕ) : ℕ :=
  ((Finset.Icc 1 (2 ^ n)).filter IsStaircase).card

theorem staircaseCount_zero : staircaseCount 0 = 1 := by
  classical
  have h : (Finset.Icc 1 (2 ^ 0) : Finset ℕ) = {1} := by decide
  have h1 : IsStaircase 1 := ⟨0, 1, le_refl 1, by norm_num [stair]⟩
  rw [staircaseCount, h, Finset.filter_singleton, if_pos h1, Finset.card_singleton]

open scoped Classical in
/-- The octave `(2^n, 2^(n+1)]` contributes exactly `n + 1` staircase numbers. -/
theorem octave_count (n : ℕ) :
    ((Finset.Ioc (2 ^ n) (2 ^ (n + 1))).filter IsStaircase).card = n + 1 := by
  classical
  have hcand : octaveCandidates (n + 1) 0
      = (Finset.Ioc (2 ^ n) (2 ^ (n + 1))).filter IsStaircase := by
    rw [octaveCandidates]
    simp only [Nat.add_sub_cancel, pow_zero]
    apply Finset.filter_congr
    intro x _
    simp
  have := octave_census_card (n := n + 1) (g := 0) (by omega) (by omega)
  rw [hcand] at this
  simpa using this

theorem staircaseCount_succ (n : ℕ) : staircaseCount (n + 1) = staircaseCount n + (n + 1) := by
  classical
  have hsplit : (Finset.Icc 1 (2 ^ n) : Finset ℕ) ∪ Finset.Ioc (2 ^ n) (2 ^ (n + 1))
      = Finset.Icc 1 (2 ^ (n + 1)) := by
    have h1 : (1:ℕ) ≤ 2 ^ n := one_le_two_pow n
    have h2 : (2:ℕ) ^ n ≤ 2 ^ (n + 1) := Nat.pow_le_pow_right (by norm_num) (by omega)
    ext x
    simp only [Finset.mem_union, Finset.mem_Icc, Finset.mem_Ioc]
    omega
  have hdisj : Disjoint (Finset.Icc 1 (2 ^ n) : Finset ℕ) (Finset.Ioc (2 ^ n) (2 ^ (n + 1))) := by
    rw [Finset.disjoint_left]
    intro x hx hx2
    simp only [Finset.mem_Icc, Finset.mem_Ioc] at hx hx2
    omega
  rw [staircaseCount, ← hsplit, Finset.filter_union,
    Finset.card_union_of_disjoint (Finset.disjoint_filter_filter hdisj), ← staircaseCount,
    octave_count]

/-- **Closed form of the census count.**  There are exactly `n(n+1)/2 + 1` staircase numbers in
`[1, 2^n]` — a triangular number of candidate knees below the product point. -/
theorem staircaseCount_formula (n : ℕ) : 2 * staircaseCount n = n * (n + 1) + 2 := by
  induction n with
  | zero => rw [staircaseCount_zero]
  | succ k ih =>
      rw [staircaseCount_succ, Nat.mul_add, ih]
      ring

/-- At the NET-47 scale (`product point 128 = 2^7`) there are `29` staircase numbers in all —
of which cycle 2 shows exactly three survive the `16`-grid of the sweep. -/
theorem net47_staircaseCount : staircaseCount 7 = 29 := by
  have := staircaseCount_formula 7
  omega

/-- **Vanishing density.**  The proportion of staircase numbers below `2^n` tends to zero: knee
candidates thin out exponentially, so landing on one is an increasingly strong constraint. -/
theorem staircase_density_tendsto_zero :
    Tendsto (fun n : ℕ => (staircaseCount n : ℝ) / 2 ^ n) atTop (nhds 0) := by
  have hcast : ∀ n : ℕ, (staircaseCount n : ℝ) = ((n : ℝ) ^ 2 + n + 2) / 2 := by
    intro n
    have h : (2 * staircaseCount n : ℕ) = n * (n + 1) + 2 := staircaseCount_formula n
    have h' : ((2 * staircaseCount n : ℕ) : ℝ) = ((n * (n + 1) + 2 : ℕ) : ℝ) := by exact_mod_cast h
    push_cast at h'
    linarith
  have hfun : ∀ n : ℕ, (staircaseCount n : ℝ) / 2 ^ n
      = (1 / 2) * ((n : ℝ) ^ 2 * (1 / 2) ^ n) + (1 / 2) * ((n : ℝ) * (1 / 2) ^ n)
        + ((1 : ℝ) / 2) ^ n := by
    intro n
    rw [hcast n, div_pow, one_pow]
    have h2 : ((2:ℝ) ^ n) ≠ 0 := by positivity
    field_simp
  have h1 : Tendsto (fun n : ℕ => (n : ℝ) ^ 2 * (1 / 2 : ℝ) ^ n) atTop (nhds 0) :=
    tendsto_pow_const_mul_const_pow_of_lt_one 2 (by norm_num) (by norm_num)
  have h2 : Tendsto (fun n : ℕ => (n : ℝ) * (1 / 2 : ℝ) ^ n) atTop (nhds 0) :=
    tendsto_self_mul_const_pow_of_lt_one (by norm_num) (by norm_num)
  have h3 : Tendsto (fun n : ℕ => ((1 : ℝ) / 2) ^ n) atTop (nhds 0) :=
    tendsto_pow_atTop_nhds_zero_of_lt_one (by norm_num) (by norm_num)
  have hsum : Tendsto
      (fun n : ℕ => (1 / 2) * ((n : ℝ) ^ 2 * (1 / 2) ^ n) + (1 / 2) * ((n : ℝ) * (1 / 2) ^ n)
        + ((1 : ℝ) / 2) ^ n) atTop (nhds ((1 / 2) * 0 + (1 / 2) * 0 + 0)) :=
    ((h1.const_mul (1 / 2)).add (h2.const_mul (1 / 2))).add h3
  simp only [mul_zero, add_zero] at hsum
  exact hsum.congr (fun n => (hfun n).symm)

end KneeStaircase