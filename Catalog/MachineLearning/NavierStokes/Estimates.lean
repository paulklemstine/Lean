import Mathlib

/-!
# Navier–Stokes Regularity: Dissipation Budgets and Continuation

This file complements `NavierStokes.Core` by extracting the *integrated* (budget)
form of the a priori estimates via the fundamental theorem of calculus. Whereas
`Core` gives pointwise-in-time bounds, here we bound the **total dissipation**
`∫₀ᵀ (·) dt`. These integral identities are the quantitative heart of the
Leray–Hopf weak-solution theory and of 2D global regularity.

## Mathematical background

Integrating the enstrophy identity `Z'(t) = -2 ν G(t)` (with `G = ‖∇ω‖₂²` the
palinstrophy) over `[0,T]` gives the **enstrophy balance**
`Z(T) - Z(0) = -2 ν ∫₀ᵀ G`, hence the total palinstrophy dissipated is exactly
`∫₀ᵀ G = (Z(0) - Z(T)) / (2 ν) ≤ Z(0) / (2 ν)`. The bound is uniform in `T`, so in
2D the integral `∫₀^∞ G < ∞` converges: the flow has a finite lifetime budget of
enstrophy dissipation. The same computation for the energy identity
`E'(t) = -2 ν F(t)` (`F = ‖∇u‖₂²`) gives `∫₀ᵀ F ≤ E(0)/(2 ν)`.

## Main results

* `enstrophy_balance` — exact enstrophy balance `Z T - Z 0 = -2 ν ∫₀ᵀ G` (FTC).
* `enstrophy_dissipation_budget` — `∫₀ᵀ G ≤ Z 0 / (2 ν)`, uniform in `T` (2D budget).
* `energy_dissipation_budget` — `∫₀ᵀ F ≤ E 0 / (2 ν)`, uniform in `T`.
* `dissipation_integral_bddAbove` — the partial dissipation integrals are bounded above.

-- !-- Lab Notes -- !--
-- Hypothesis H4 (budget): integrate the pointwise dissipation identity. Experiment
--   confirmed `intervalIntegral.integral_eq_sub_of_hasDerivAt` is the right FTC
--   instance; interval-integrability of the (continuous) dissipation is discharged
--   by `Continuous.intervalIntegrable` + `fun_prop`.
-- Insight: the uniform-in-T bound `∫₀ᵀ G ≤ Z 0/(2ν)` is the integral shadow of the
--   pointwise enstrophy monotonicity proved in Core. Notably the budget needs only
--   `Z(T) ≥ 0` (not the full `Z(T) ≤ Z 0`), since `∫₀ᵀ G = (Z 0 - Z T)/(2ν)`.
-- Failure analysis: stating the budget with `Z(T) ≥ 0` is essential — without a
--   lower bound on `Z(T)` the difference `Z 0 - Z T` is not controlled. The natural
--   physical hypothesis `Z ≥ 0` supplies it.
-/

open MeasureTheory intervalIntegral

namespace NavierStokes

/-! ## Enstrophy balance and 2D dissipation budget -/

/-
**Enstrophy balance (FTC).** Integrating `Z'(t) = -2 ν G(t)` over `[0,T]`
gives the exact balance `Z T - Z 0 = -2 ν ∫₀ᵀ G`.
-/
theorem enstrophy_balance
    (Z G : ℝ → ℝ) (ν : ℝ) (hGc : Continuous G)
    (hZ : ∀ t, HasDerivAt Z (-2 * ν * G t) t) (T : ℝ) :
    Z T - Z 0 = -2 * ν * ∫ t in (0:ℝ)..T, G t := by
  rw [ ← intervalIntegral.integral_deriv_eq_sub ];
  · rw [ intervalIntegral.integral_congr fun x hx => HasDerivAt.deriv ( hZ x ), intervalIntegral.integral_const_mul ];
  · exact fun x hx => HasDerivAt.differentiableAt ( hZ x );
  · exact Continuous.intervalIntegrable ( by rw [ show deriv Z = _ from funext fun t => HasDerivAt.deriv ( hZ t ) ] ; continuity ) _ _

/-
**2D enstrophy dissipation budget.** With viscosity `ν > 0` and non-negative
enstrophy `Z ≥ 0`, the total palinstrophy dissipated up to any time `T ≥ 0` is
bounded by `Z 0 / (2 ν)`, uniformly in `T`. This is the finite-dissipation budget
underlying 2D global regularity. (Non-negativity of the palinstrophy `G` is the
physical setting but is not needed for this bound.)
-/
theorem enstrophy_dissipation_budget
    (Z G : ℝ → ℝ) (ν : ℝ) (hν : 0 < ν) (hZnn : ∀ t, 0 ≤ Z t)
    (hGc : Continuous G)
    (hZ : ∀ t, HasDerivAt Z (-2 * ν * G t) t) :
    ∀ T, 0 ≤ T → (∫ t in (0:ℝ)..T, G t) ≤ Z 0 / (2 * ν) := by
  intro T hT;
  rw [ le_div_iff₀ ( by positivity ) ];
  linarith [ enstrophy_balance Z G ν hGc hZ T, hZnn T ]

/-! ## Energy dissipation budget -/

/-
**Energy dissipation budget.** Integrating the energy identity
`E'(t) = -2 ν F(t)` (`F = ‖∇u‖₂² ≥ 0` the enstrophy/gradient term) gives the
uniform bound `∫₀ᵀ F ≤ E 0 / (2 ν)`.
-/
theorem energy_dissipation_budget
    (E F : ℝ → ℝ) (ν : ℝ) (hν : 0 < ν) (hEnn : ∀ t, 0 ≤ E t)
    (hFc : Continuous F)
    (hE : ∀ t, HasDerivAt E (-2 * ν * F t) t) :
    ∀ T, 0 ≤ T → (∫ t in (0:ℝ)..T, F t) ≤ E 0 / (2 * ν) := by
  intro T hT;
  convert enstrophy_dissipation_budget E F ν hν hEnn hFc hE T hT using 1

/-
**Dissipation integrals are bounded above.** The set of partial dissipation
integrals `{∫₀ᵀ G | T ≥ 0}` is bounded above by `Z 0 / (2 ν)`. This packages the
budget as the convergence-enabling hypothesis for `∫₀^∞ G < ∞`.
-/
theorem dissipation_integral_bddAbove
    (Z G : ℝ → ℝ) (ν : ℝ) (hν : 0 < ν) (hZnn : ∀ t, 0 ≤ Z t)
    (hGc : Continuous G)
    (hZ : ∀ t, HasDerivAt Z (-2 * ν * G t) t) :
    BddAbove (Set.range fun T : {T : ℝ // 0 ≤ T} => ∫ t in (0:ℝ)..(T : ℝ), G t) := by
  exact ⟨ Z 0 / ( 2 * ν ), Set.forall_mem_range.2 fun T => by simpa using enstrophy_dissipation_budget Z G ν hν hZnn hGc hZ T.val T.2 ⟩

end NavierStokes