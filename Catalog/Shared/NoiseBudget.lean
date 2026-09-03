import Shared.QuantizationCeiling

/-!
# Cycle 3: the noise budget of the starved regime (T-DIAL-56)

Cycles 1 and 2 proved that *no* tie-based mechanism can drive `Spearman(T, rate)`
below the band `[0.55, 0.85]` at the observed starvation level.  The remaining
candidate is the one that leaves no ties at all: **estimator noise**.  At a
`0.89 %` smooth rate the measured rate for each modulus is a Monte-Carlo estimate,
so the *measured* rank vector is a displaced copy of the *true* rank vector.

This file quantifies exactly how much displacement is required.

* `mean_sub`, `cov_sub_right` — covariance is additive in its second slot.
* `cov_diff_sq_le` — **the perturbation bound**: `(Cov(X,Y) - Cov(X,Z))² ≤
  Var X · Var(Y - Z)`.  Changing the response by `Y - Z` cannot change the
  covariance by more than the energy of the change.
* `rank_displacement_energy_ge` — **the noise budget**: if a dial achieves
  correlation at least `a` against the *true* rate ranks but only `b ≤ a` against
  the *measured* ranks, then the rank displacement satisfies
  `Var(measured - true) ≥ (a - b)² · (n³ - n)/12`.
* `exp511_displacement_energy_ge` — the recorded instance: to explain the drop
  from the band edge `0.55` to the observed `0.405` at `n = 1200`, the rate
  estimator must displace the ranking with energy at least `3 · 10⁶`, i.e. a
  root-mean-square displacement of about `50` rank positions out of `1200`.

That is a falsifiable prediction about the *rate estimator*, not about the dial —
which is the substantive content of "the bit-length stability has a practical
floor".  The floor is where the Monte-Carlo error of the rate measurement, in rank
units, reaches roughly `4 %` of the sample size.
-/

namespace TieCeiling

open Finset

variable {ι : Type*} [Fintype ι]

/-! ## Bilinearity -/

lemma mean_sub (Y Z : ι → ℝ) : mean (fun i => Y i - Z i) = mean Y - mean Z := by
  rw [mean, mean, mean, Finset.sum_sub_distrib, sub_div]

/-- Covariance is additive in the second argument. -/
lemma cov_sub_right (X Y Z : ι → ℝ) :
    cov X (fun i => Y i - Z i) = cov X Y - cov X Z := by
  rw [cov, cov, cov, mean_sub, ← Finset.sum_sub_distrib]
  exact Finset.sum_congr rfl fun i _ => by ring

/-! ## The perturbation bound -/

/-- **Perturbing the response perturbs the covariance by at most the energy of the
perturbation.**  This is the quantitative statement that correlation is stable,
and read backwards it is a *lower bound on the noise* needed to destroy a
correlation. -/
theorem cov_diff_sq_le (X Y Z : ι → ℝ) :
    (cov X Y - cov X Z) ^ 2 ≤ varOf X * varOf (fun i => Y i - Z i) := by
  rw [← cov_sub_right X Y Z]
  exact cov_sq_le X (fun i => Y i - Z i)

/-! ## The noise budget for rank data -/

/-- **The noise budget.**  Let `X` be a dial's rank vector on `n` points, `Z` the
rank vector of the *true* response and `Y` that of the *measured* response.  If
the dial correlates at level `a` with the truth but only at level `b ≤ a` with the
measurement, then the measurement must have displaced the ranking with energy at
least `(a - b)² (n³ - n)/12`.

No tie hypothesis is used: this is the mechanism that operates *after* the tie
ceilings of cycles 1 and 2 have been shown not to bind. -/
theorem rank_displacement_energy_ge {n : ℕ} (σ τ υ : Equiv.Perm (Fin n)) (a b : ℝ)
    (hZ : a * varOf (rankVec σ) ≤ cov (rankVec σ) (rankVec τ))
    (hY : cov (rankVec σ) (rankVec υ) ≤ b * varOf (rankVec σ))
    (hab : b ≤ a) :
    (a - b) ^ 2 * (((n : ℝ) ^ 3 - n) / 12)
      ≤ varOf (fun i => rankVec υ i - rankVec τ i) := by
  set V : ℝ := ((n : ℝ) ^ 3 - n) / 12 with hV
  have hVX : varOf (rankVec σ) = V := varOf_rankVec σ
  have hV0 : 0 ≤ V := by rw [← hVX]; exact varOf_nonneg _
  set W : ℝ := varOf (fun i => rankVec υ i - rankVec τ i) with hW
  have hW0 : 0 ≤ W := varOf_nonneg _
  have hgap : (a - b) * V ≤ cov (rankVec σ) (rankVec τ) - cov (rankVec σ) (rankVec υ) := by
    rw [hVX] at hZ hY; linarith
  have hmain : (cov (rankVec σ) (rankVec υ) - cov (rankVec σ) (rankVec τ)) ^ 2 ≤ V * W := by
    have := cov_diff_sq_le (rankVec σ) (rankVec υ) (rankVec τ)
    rwa [hVX] at this
  have hsq : ((a - b) * V) ^ 2 ≤ V * W := by
    have h1 : 0 ≤ (a - b) * V := mul_nonneg (by linarith) hV0
    nlinarith [hmain, hgap, h1]
  rcases eq_or_lt_of_le hV0 with h | h
  · rw [← h]; simpa using hW0
  · nlinarith [hsq, h]

/-- **The recorded instance (exp 511, bit length 56, `n = 1200`).**  Suppose the
dial `T` would score at the band edge `0.55` against the *true* smooth rates but
scores the observed `0.405` against the *measured* rates.  Then the measurement
noise must carry a rank-displacement energy of at least `3 · 10⁶`, i.e. an RMS
displacement of about `50` positions out of `1200`.  This is the falsifiable
prediction that replaces the (disproved) tie explanation. -/
theorem exp511_displacement_energy_ge (σ τ υ : Equiv.Perm (Fin 1200))
    (hZ : 0.55 * varOf (rankVec σ) ≤ cov (rankVec σ) (rankVec τ))
    (hY : cov (rankVec σ) (rankVec υ) ≤ 0.405 * varOf (rankVec σ)) :
    (3000000 : ℝ) ≤ varOf (fun i => rankVec υ i - rankVec τ i) := by
  have h := rank_displacement_energy_ge σ τ υ 0.55 0.405 hZ hY (by norm_num)
  refine le_trans ?_ h
  norm_num

end TieCeiling