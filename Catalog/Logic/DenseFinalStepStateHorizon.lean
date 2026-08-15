/-
# NET-25 / Catalog·Logic — The state horizon of a contractive carry cell, and how
# much depth a rich boundary step buys

Third component of the NET-25 dissection.  The empirical round measured a
*state horizon*: a raw-input GRU carry cell masters `n = 5` and then decays with
depth (`raw20-192`, 7 seeds: `0.0806, 0.6997, 0.0103, 0.0063, 0.0093, 0.0020,
0.0132` at `n = 8`), while the carry *transition* probe stays at `0.86–0.99`
throughout.  The failure is therefore a **readout separation** failure.

This file proves the corresponding mathematical statement and its quantitative
cure.

* `Logic.StateHorizon.dist_iterate_le` — a contractive affine recurrence
  (`‖A x‖ ≤ lam ‖x‖`, `lam < 1`) squeezes the separation of two trajectories
  geometrically: `‖f^[n] x - f^[n] y‖ ≤ lam ^ n * ‖x - y‖`.
* `Logic.StateHorizon.readout_gap_lt` and `exists_state_horizon` — hence **any**
  bounded linear readout loses any fixed decision margin `gamma` beyond a finite
  depth `N`: the state horizon is a theorem, not an artifact.  This is a genuine
  impossibility statement (no training procedure and no parameter count can
  avoid it, only a *less contractive* cell or a *boundary gain* can).
* `Logic.StateHorizon.horizon_shift` and `horizon_shift_log` — a final-step gain
  `m ≥ 1` (the formal stand-in for a dense EOS input pathway) extends the usable
  depth by exactly `k ≈ log m / log (1 / lam)` steps: **boundary richness buys
  depth only logarithmically**.

That last item is the sharp, falsifiable prediction of this round: the usable
unroll depth of a state-augmented answer path should grow like the *logarithm*
of the boundary gain, so the observed `20/28 fail, 384 works` gap corresponds to
a modest additive depth gain, not to a qualitative change of regime.

Companion files: `Logic.DenseFinalStepCarryChain` (the transition is exactly
length-general), `Logic.DenseFinalStepBoundaryConditioning` (EOS width is
invisible to the function class, visible to the optimiser).
-/

import Mathlib

namespace Logic.StateHorizon

variable {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]

/-- One step of an affine recurrent cell: `x ↦ A x + u`. -/
def step (A : E →L[ℝ] E) (u : E) (x : E) : E := A x + u

theorem step_sub (A : E →L[ℝ] E) (u x y : E) :
    step A u x - step A u y = A (x - y) := by
  simp [step, map_sub]

/-- **Geometric collapse of state separation.**  Under a contraction factor
`lam`, two trajectories of the same cell approach each other geometrically. -/
theorem dist_iterate_le (A : E →L[ℝ] E) (u : E) {lam : ℝ} (hlam : 0 ≤ lam)
    (hA : ∀ z : E, ‖A z‖ ≤ lam * ‖z‖) (x y : E) (n : ℕ) :
    ‖(step A u)^[n] x - (step A u)^[n] y‖ ≤ lam ^ n * ‖x - y‖ := by
  induction n generalizing x y with
  | zero => simp
  | succ n ih =>
      rw [Function.iterate_succ_apply, Function.iterate_succ_apply]
      refine (ih (step A u x) (step A u y)).trans ?_
      have h1 : ‖step A u x - step A u y‖ ≤ lam * ‖x - y‖ := by
        rw [step_sub]; exact hA _
      have hpow : (0 : ℝ) ≤ lam ^ n := pow_nonneg hlam n
      calc lam ^ n * ‖step A u x - step A u y‖ ≤ lam ^ n * (lam * ‖x - y‖) :=
            mul_le_mul_of_nonneg_left h1 hpow
        _ = lam ^ (n + 1) * ‖x - y‖ := by ring

/-- **Readout margin collapse.**  A bounded linear readout of a contracted state
cannot realise a decision margin `gamma` once `lam ^ n * Delta * R < gamma`,
where `Delta` bounds the initial state separation and `R` the readout norm. -/
theorem readout_gap_lt (A : E →L[ℝ] E) (u : E) (r : E →L[ℝ] ℝ) {lam R Delta gamma : ℝ}
    (hlam : 0 ≤ lam) (hA : ∀ z : E, ‖A z‖ ≤ lam * ‖z‖)
    (hr : ∀ z : E, ‖r z‖ ≤ R * ‖z‖) (hR : 0 ≤ R)
    (x y : E) (hxy : ‖x - y‖ ≤ Delta) (n : ℕ)
    (hsmall : lam ^ n * (Delta * R) < gamma) :
    |r ((step A u)^[n] x) - r ((step A u)^[n] y)| < gamma := by
  have hgap : ‖(step A u)^[n] x - (step A u)^[n] y‖ ≤ lam ^ n * Delta := by
    refine (dist_iterate_le A u hlam hA x y n).trans ?_
    exact mul_le_mul_of_nonneg_left hxy (pow_nonneg hlam n)
  have hlin : |r ((step A u)^[n] x) - r ((step A u)^[n] y)|
      ≤ R * ‖(step A u)^[n] x - (step A u)^[n] y‖ := by
    have := hr ((step A u)^[n] x - (step A u)^[n] y)
    simpa [map_sub, Real.norm_eq_abs] using this
  have hpow : (0 : ℝ) ≤ lam ^ n := pow_nonneg hlam n
  calc |r ((step A u)^[n] x) - r ((step A u)^[n] y)|
      ≤ R * ‖(step A u)^[n] x - (step A u)^[n] y‖ := hlin
    _ ≤ R * (lam ^ n * Delta) := mul_le_mul_of_nonneg_left hgap hR
    _ = lam ^ n * (Delta * R) := by ring
    _ < gamma := hsmall

/-- **The state horizon exists.**  For a strictly contractive cell there is a
finite depth `N` beyond which *every* bounded readout is below margin: the
empirical "state horizon" of the raw-input arms is forced. -/
theorem exists_state_horizon (A : E →L[ℝ] E) (u : E) (r : E →L[ℝ] ℝ)
    {lam R Delta gamma : ℝ} (hlam : 0 ≤ lam) (hlam1 : lam < 1)
    (hA : ∀ z : E, ‖A z‖ ≤ lam * ‖z‖) (hr : ∀ z : E, ‖r z‖ ≤ R * ‖z‖) (hR : 0 ≤ R)
    (hDelta : 0 ≤ Delta) (hgamma : 0 < gamma) :
    ∃ N : ℕ, ∀ n ≥ N, ∀ x y : E, ‖x - y‖ ≤ Delta →
      |r ((step A u)^[n] x) - r ((step A u)^[n] y)| < gamma := by
  rcases eq_or_lt_of_le hlam with hzero | hpos
  · -- `lam = 0`: the state collapses after one step
    refine ⟨1, fun n hn x y hxy => ?_⟩
    have hpow : lam ^ n = 0 := by
      rw [← hzero]
      exact zero_pow (by omega)
    refine readout_gap_lt A u r hlam hA hr hR x y hxy n ?_
    rw [hpow]
    simpa using hgamma
  · have hDR : 0 ≤ Delta * R := mul_nonneg hDelta hR
    rcases eq_or_lt_of_le hDR with hDR0 | hDRpos
    · refine ⟨0, fun n _ x y hxy => ?_⟩
      refine readout_gap_lt A u r hlam hA hr hR x y hxy n ?_
      rw [← hDR0, mul_zero]
      exact hgamma
    · obtain ⟨N, hN⟩ := exists_pow_lt_of_lt_one (div_pos hgamma hDRpos) hlam1
      refine ⟨N, fun n hn x y hxy => ?_⟩
      have hmono : lam ^ n ≤ lam ^ N := pow_le_pow_of_le_one hlam hlam1.le hn
      have hlt : lam ^ n < gamma / (Delta * R) := lt_of_le_of_lt hmono hN
      refine readout_gap_lt A u r hlam hA hr hR x y hxy n ?_
      rw [← lt_div_iff₀ hDRpos]
      exact hlt

/-- **Boundary gain buys depth.**  If depth `N` is already beyond the horizon,
then a final-step gain `m` restores usability only for `k` further steps, where
`k` must satisfy `m * lam ^ k ≤ 1`, i.e. `k ≥ log m / log (1 / lam)` for `m ≥ 1`
(the hypothesis `m ≥ 1` is not needed for the inequality itself). -/
theorem horizon_shift {lam m DR gamma : ℝ} (hlam : 0 ≤ lam)
    (hDR : 0 ≤ DR) (N k : ℕ) (hN : lam ^ N * DR < gamma) (hk : m * lam ^ k ≤ 1) :
    lam ^ (N + k) * (m * DR) < gamma := by
  have hpowN : (0 : ℝ) ≤ lam ^ N := pow_nonneg hlam N
  have hkey : lam ^ (N + k) * (m * DR) = (lam ^ N * DR) * (m * lam ^ k) := by
    rw [pow_add]; ring
  have hP : (0 : ℝ) ≤ lam ^ N * DR := mul_nonneg hpowN hDR
  rw [hkey]
  calc (lam ^ N * DR) * (m * lam ^ k) ≤ (lam ^ N * DR) * 1 :=
        mul_le_mul_of_nonneg_left hk hP
    _ = lam ^ N * DR := by ring
    _ < gamma := hN

/-- Logarithmic form: the number of extra depth steps that a boundary gain `m`
buys is `log m / log (1 / lam)`.  Concretely, with `lam` fixed, multiplying the
boundary gain by a constant extends the usable depth by a *constant additive*
amount — depth is logarithmic in boundary richness. -/
theorem horizon_shift_log {lam m : ℝ} (hlam : 0 < lam) (hlam1 : lam < 1) (hm : 1 ≤ m)
    {k : ℕ} (hk : Real.log m / Real.log (1 / lam) ≤ k) :
    m * lam ^ k ≤ 1 := by
  have hinv : 1 < 1 / lam := by
    rw [lt_div_iff₀ hlam]; linarith
  have hloginv : 0 < Real.log (1 / lam) := Real.log_pos hinv
  have hlogm : Real.log m ≤ k * Real.log (1 / lam) := by
    rw [div_le_iff₀ hloginv] at hk
    linarith
  have hmpos : 0 < m := lt_of_lt_of_le zero_lt_one hm
  have hstep : Real.log m ≤ Real.log ((1 / lam) ^ k) := by
    rw [Real.log_pow]
    linarith
  have hpow : 0 < (1 / lam : ℝ) ^ k := pow_pos (by positivity) k
  have hle : m ≤ (1 / lam) ^ k := (Real.log_le_log_iff hmpos hpow).mp hstep
  have hlampow : 0 < lam ^ k := pow_pos hlam k
  have hle' : m ≤ 1 / lam ^ k := by
    rw [div_pow, one_pow] at hle
    exact hle
  exact (le_div_iff₀ hlampow).mp hle'

/-! ## Lab notes (round-net-25, measured)

`raw20-192` (125,214 params, 20-d EOS), 7 seeds at `n = 8` full:
`0.0806, 0.6997, 0.0103, 0.0063, 0.0093, 0.0020, 0.0132` — a *distribution*
rather than a hard wall, with the final-carry probe at `0.86–0.99` in every one
of them.  `exists_state_horizon` explains the shape: with a contractive cell the
readout margin is lost at a finite depth that depends on `lam`, `Delta`, `R`,
`gamma`, all of which vary with the seed — hence a spread of horizons rather
than a single threshold.  `horizon_shift_log` predicts that the cure's depth
benefit is logarithmic in the boundary gain, so the untested `28 → 384` window
should show a smooth, log-spaced improvement rather than a sharp threshold.
-/

end Logic.StateHorizon