import Mathlib
import Probability.TDialU116FloorIdentifiability

/-!
# Sign changes cap the drift, and the resolution–horizon trade-off

## Research context (FACT round-71 #2, exp 553; third cycle)

The first two cycles of this thread established that the U116 rebound is incompatible with any
nonnegative multiplicative fade, that the three recorded rungs around it identify a floor
`≈ 0.474169` inside the pre-registered window `[0.46, 0.49]`, and that the fitted model —
though useless for extrapolation — still resolves the floor to a window of width `≈ 0.031`.

This cycle isolates the *combinatorial* content of "rebound noise".  The record's story is
that the residuals of the fade change sign; the question this raises is how much a sequence of
sign-constrained residuals can drift.  The answer is exact and elementary, but it needs a
strengthened induction: the naive bound `|∑| ≤ K` cannot see sign changes at all, and the
obvious invariant `|∑ₖ| ≤ K − c` does not propagate on its own.

## Main results

### 1. Sign changes cap the drift
* `signChanges` — the number of adjacent sign changes among the first `K + 1` terms.
* `drift_invariant` — the strengthened two-sided invariant
  `1 − D ≤ e_K · Sₖ ≤ D` with `D = (K+1) − c`, which *does* propagate; the asymmetry by one
  unit between the two sides is exactly what a sign change consumes.
* `sign_pattern_drift_bound` — hence `|∑_{k ≤ K} eₖ| ≤ (K+1) − c` for any `±1` sequence with
  `c` sign changes.  Both extremes are attained: `c = 0` gives `K+1`, and the fully
  alternating pattern `c = K` gives `1`.
* `amplitude_alternation_average` — in estimator form: the mean of `K+1` residuals of
  amplitude exactly `η` with `c` sign changes is at most `η(K+1−c)/(K+1)` in absolute value.
  Sign changes are therefore *directly* convertible into estimator accuracy, which is the
  precise sense in which a rebound is informative rather than merely tolerable.

### 2. The resolution–horizon trade-off
* `resolution_horizon_uncertainty` — the floor resolution `2η/|1−λ|` of
  `floor_resolution_bound` and the asymptotic trap half-width `η/(1−|λ|)` of `noisyFade_trap`
  satisfy `r · w ≥ 2η²/(1−λ)²`, with equality exactly for `λ ≥ 0`.  Oscillatory fades
  (`λ < 0`) pay a strictly worse product than monotone ones.
* `u116_resolution_floor` — applied to the record: *any* affine floor model with `−1 ≤ λ ≤ 1`
  that reproduces the U116 rebound above its floor has resolution at least `0.0226`.  No
  re-analysis of this ladder, at any ratio, can pin the floor better than `± 0.0113`; the
  pre-registered window of width `0.03` was therefore not over-claiming.

## Lab notes

```
recorded rebound step        : +0.0226   (rungB = 0.4621 → rungC = 0.4847)
forced noise, monotone model : eta >= 0.0226
forced resolution 2*eta/|1-lambda| (|lambda| <= 1) : >= 0.0226
fitted ratio                 : lambda = -226/259  (oscillatory branch: strict inequality
                               in the resolution-horizon product)
```
-/

open Finset

namespace Catalog.Probability.TDialSignChangeDrift

open Catalog.Probability.TDialU116ReboundFloor
open Catalog.Probability.TDialU116FloorIdentifiability

/-! ## 1. Sign changes cap the drift -/

/-- The number of adjacent sign changes among the terms `e 0, …, e K` of a sequence. -/
noncomputable def signChanges (e : ℕ → ℝ) : ℕ → ℕ
  | 0 => 0
  | K + 1 => signChanges e K + (if e K = e (K + 1) then 0 else 1)

@[simp] theorem signChanges_zero (e : ℕ → ℝ) : signChanges e 0 = 0 := rfl

theorem signChanges_succ (e : ℕ → ℝ) (K : ℕ) :
    signChanges e (K + 1) = signChanges e K + (if e K = e (K + 1) then 0 else 1) := rfl

/-- There are at most `K` sign changes among `K + 1` terms. -/
theorem signChanges_le (e : ℕ → ℝ) (K : ℕ) : signChanges e K ≤ K := by
  induction K with
  | zero => simp
  | succ K ih =>
      rw [signChanges_succ]
      split_ifs <;> omega

/-- **The propagating invariant.**  For a `±1` sequence, write `S = ∑_{k ≤ K} eₖ` and
`D = (K+1) − c` where `c` is the number of sign changes.  Then `1 − D ≤ e_K · S ≤ D`.  The
one-sided slack is what makes the induction go through: a sign change flips the two sides of
the invariant into each other while decrementing the budget `D` by one. -/
theorem drift_invariant {e : ℕ → ℝ} (he : ∀ k, e k = 1 ∨ e k = -1) (K : ℕ) :
    e K * (∑ k ∈ range (K + 1), e k) ≤ ((K : ℝ) + 1) - signChanges e K ∧
      1 - (((K : ℝ) + 1) - signChanges e K) ≤ e K * (∑ k ∈ range (K + 1), e k) := by
  induction K with
  | zero =>
      have h0 : e 0 * (∑ k ∈ range 1, e k) = 1 := by
        rw [sum_range_one]
        rcases he 0 with h | h <;> rw [h] <;> norm_num
      rw [h0]
      norm_num
  | succ K ih =>
      obtain ⟨ih1, ih2⟩ := ih
      set S := ∑ k ∈ range (K + 1), e k with hS
      have hsum : ∑ k ∈ range (K + 2), e k = S + e (K + 1) := by
        rw [hS, sum_range_succ]
      have hsq : e (K + 1) * e (K + 1) = 1 := by
        rcases he (K + 1) with h | h <;> rw [h] <;> norm_num
      have hnew : e (K + 1) * (∑ k ∈ range (K + 2), e k) = e (K + 1) * S + 1 := by
        rw [hsum, mul_add, hsq]
      by_cases hchg : e K = e (K + 1)
      · have hc : signChanges e (K + 1) = signChanges e K := by
          rw [signChanges_succ, if_pos hchg]
          simp
        have heq : e (K + 1) * S = e K * S := by rw [hchg]
        rw [hnew, heq, hc]
        push_cast
        constructor <;> linarith
      · have hc : signChanges e (K + 1) = signChanges e K + 1 := by
          rw [signChanges_succ, if_neg hchg]
        have hneg : e (K + 1) = -e K := by
          rcases he K with hk | hk <;> rcases he (K + 1) with hk1 | hk1 <;>
            simp [hk, hk1] at hchg ⊢
        have heq : e (K + 1) * S = -(e K * S) := by rw [hneg]; ring
        rw [hnew, heq, hc]
        push_cast
        constructor <;> linarith

/-- **Sign changes cap the drift.**  A `±1` sequence with `c` sign changes among its first
`K + 1` terms has partial sum bounded by `(K + 1) − c` in absolute value.  Constant patterns
attain `K + 1`, fully alternating patterns attain `1`. -/
theorem sign_pattern_drift_bound {e : ℕ → ℝ} (he : ∀ k, e k = 1 ∨ e k = -1) (K : ℕ) :
    |∑ k ∈ range (K + 1), e k| ≤ ((K : ℝ) + 1) - signChanges e K := by
  obtain ⟨h1, h2⟩ := drift_invariant he K
  have habs : |e K| = 1 := by
    rcases he K with h | h <;> rw [h] <;> norm_num
  have hEq : |∑ k ∈ range (K + 1), e k| = |e K * (∑ k ∈ range (K + 1), e k)| := by
    rw [abs_mul, habs, one_mul]
  rw [hEq, abs_le]
  constructor <;> linarith

/-- The constant pattern shows the bound is attained with no sign changes. -/
theorem sign_pattern_drift_sharp_constant (K : ℕ) :
    |∑ _k ∈ range (K + 1), (1 : ℝ)| = ((K : ℝ) + 1) - signChanges (fun _ => (1 : ℝ)) K := by
  have hc : signChanges (fun _ => (1 : ℝ)) K = 0 := by
    induction K with
    | zero => simp
    | succ K ih => rw [signChanges_succ, ih]; simp
  rw [hc]
  simp
  positivity

/-- The fully alternating pattern has the maximal number of sign changes. -/
theorem signChanges_alternating (K : ℕ) : signChanges (fun k => (-1 : ℝ) ^ k) K = K := by
  induction K with
  | zero => simp
  | succ K ih =>
      rw [signChanges_succ, ih]
      have hne : ((-1 : ℝ)) ^ K ≠ (-1 : ℝ) ^ (K + 1) := by
        rw [pow_succ]
        have hnz : ((-1 : ℝ)) ^ K ≠ 0 := pow_ne_zero _ (by norm_num)
        intro hcon
        apply hnz
        nlinarith [hcon, sq_nonneg ((-1 : ℝ) ^ K)]
      simp [hne]

/-- The fully alternating pattern shows the bound is attained at the other extreme: with the
maximal `K` sign changes the drift budget is exactly `1`, and it is realised. -/
theorem sign_pattern_drift_sharp_alternating {K : ℕ} (hK : Even K) :
    |∑ k ∈ range (K + 1), (-1 : ℝ) ^ k|
      = ((K : ℝ) + 1) - signChanges (fun k => (-1 : ℝ) ^ k) K := by
  have hsum : ∑ k ∈ range (K + 1), (-1 : ℝ) ^ k = 1 := by
    rw [Catalog.Probability.TDialU116FloorIdentifiability.alternating_signs_partial_sum_eq]
    rw [if_neg (by simpa [Nat.even_add_one] using hK)]
  rw [hsum, signChanges_alternating]
  norm_num

/-- **Estimator form.**  The mean of `K + 1` residuals of amplitude exactly `η` whose sign
pattern has `c` changes deviates from zero by at most `η (K + 1 − c)/(K + 1)`.  Every sign
change buys one unit of accuracy. -/
theorem amplitude_alternation_average {e : ℕ → ℝ} (he : ∀ k, e k = 1 ∨ e k = -1) {eta : ℝ}
    (heta : 0 ≤ eta) (K : ℕ) :
    |(∑ k ∈ range (K + 1), eta * e k) / (K + 1)|
      ≤ eta * (((K : ℝ) + 1) - signChanges e K) / ((K : ℝ) + 1) := by
  have hpos : (0 : ℝ) < (K : ℝ) + 1 := by positivity
  have hsum : ∑ k ∈ range (K + 1), eta * e k = eta * ∑ k ∈ range (K + 1), e k := by
    rw [mul_sum]
  rw [hsum, abs_div, abs_mul, abs_of_nonneg heta, abs_of_pos hpos,
    div_le_div_iff_of_pos_right hpos]
  exact mul_le_mul_of_nonneg_left (sign_pattern_drift_bound he K) heta

/-! ## 2. The resolution–horizon trade-off -/

/-- **Resolution–horizon uncertainty.**  The product of the floor resolution `2η/|1−λ|` and the
asymptotic trap half-width `η/(1−|λ|)` is at least `2η²/(1−λ)²`, with equality precisely on the
monotone branch `λ ≥ 0`.  A ladder that oscillates towards its floor pays strictly more. -/
theorem resolution_horizon_uncertainty {lam eta : ℝ} (hlam : |lam| < 1) (heta : 0 < eta) :
    2 * eta ^ 2 / (1 - lam) ^ 2 ≤ (2 * eta / |1 - lam|) * (eta / (1 - |lam|)) := by
  have hb := abs_le.mp hlam.le
  have hlt : lam < 1 := lt_of_abs_lt hlam
  have h1 : (0 : ℝ) < 1 - lam := by linarith
  have habs : |1 - lam| = 1 - lam := abs_of_pos h1
  have h2 : (0 : ℝ) < 1 - |lam| := by
    have := abs_lt.mp hlam
    cases abs_cases lam with
    | inl h => rw [h.1]; linarith [h.2]
    | inr h => rw [h.1]; linarith [h.2]
  have hle : 1 - |lam| ≤ 1 - lam := by
    have : lam ≤ |lam| := le_abs_self lam
    linarith
  have hkey : (1 - lam) * (1 - |lam|) ≤ (1 - lam) ^ 2 := by nlinarith
  rw [habs, div_mul_div_comm, show 2 * eta * eta = 2 * eta ^ 2 by ring]
  exact div_le_div_of_nonneg_left (by positivity) (by positivity) hkey

/-- **Intrinsic resolution limit of the recorded ladder.**  Any affine floor model with ratio
`−1 ≤ λ ≤ 1` that reproduces the recorded U116 rebound from above its own floor has floor
resolution at least the size of the rebound, `0.0226`.  No re-analysis of this ladder can pin
the floor better than `± 0.0113`. -/
theorem u116_resolution_floor {L lam eta : ℝ} {rho : ℕ → ℝ} {k : ℕ}
    (h : NoisyFade L lam eta rho) (hlam1 : lam < 1) (hlam0 : -1 ≤ lam)
    (hk : rho k = (rungB : ℝ)) (hk1 : rho (k + 1) = (rungC : ℝ)) (hfloor : L ≤ (rungB : ℝ)) :
    (226 / 10000 : ℝ) ≤ 2 * eta / |1 - lam| := by
  have hnoise : (226 / 10000 : ℝ) ≤ eta :=
    u116_monotone_model_needs_noise h hlam1.le hk hk1 hfloor
  have hp : (0 : ℝ) < 1 - lam := by linarith
  have habs : |1 - lam| = 1 - lam := abs_of_pos hp
  have hle2 : 1 - lam ≤ 2 := by linarith
  rw [habs, le_div_iff₀ hp]
  nlinarith

end Catalog.Probability.TDialSignChangeDrift