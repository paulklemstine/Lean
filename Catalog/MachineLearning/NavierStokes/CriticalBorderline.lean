import Mathlib

/-!
# Navier–Stokes Regularity: The Logarithmic Critical Borderline

`NavierStokes.Core` exhibits the dichotomy between the *linear/2D* regime
`Z' ≤ -aZ` (global decay) and the *supercritical/3D* regime `Z' ≤ C Z³`
(finite-time blow-up). This file resolves the **critical borderline** that sits
between them — the logarithmically-corrected inequality

`Z'(t) ≤ C · Z(t) · log(e + Z(t))`,

which is the scalar shadow of the logarithmic Beale–Kato–Majda continuation
criterion. The headline result is that this borderline is *globally regular*:
the enstrophy can grow at most **double-exponentially** and never blows up in
finite time. The proof linearises the inequality via the substitution
`v = log(e + Z)` to `v' ≤ C v`, then runs the exponential integrating factor
`v(t) e^{-C t}` (the same device as `Core.energy_exponential_decay`).

## Mathematical background

With `v(t) = log(e + Z(t))` (so `v ≥ 1`), the chain rule gives
`v'(t) = Z'(t)/(e + Z(t))`. Using `Z'(t) ≤ C Z(t) log(e+Z(t))` and
`Z/(e+Z) ≤ 1` together with `log(e+Z) ≥ 0` yields the *linear* differential
inequality `v'(t) ≤ C v(t)`. The exponential comparison
(`Core.energy_exponential_decay` with rate `c = -C`) then gives
`v(t) ≤ v(0) e^{C t}`, i.e.

`log(e + Z(t)) ≤ log(e + Z₀) · e^{C t}`,

so `Z(t) ≤ exp(log(e + Z₀) · e^{C t}) - e`: finite for every finite `t`, hence
**no finite-time blow-up** — global regularity at the borderline.

## Main results

* `log_enstrophy_linear_bound` — `log(e + Z(t)) ≤ log(e + Z₀) · e^{C t}`.
* `log_critical_no_blowup` — the explicit double-exponential a priori bound
  `Z(t) ≤ exp(log(e + Z₀) · e^{C t}) - e`, witnessing global regularity.

-- !-- Lab Notes -- !--
-- Hypothesis H7 (borderline): the logarithmic correction is *exactly* critical —
--   the substitution `v = log(e+Z)` should linearise `Z' ≤ C Z log(e+Z)` to
--   `v' ≤ C v`, putting it on the regular side of the dichotomy. Experiment
--   confirmed `v' = Z'/(e+Z) ≤ C log(e+Z) = C v` needs only `Z ≥ 0` (so that
--   `Z/(e+Z) ≤ 1` and `log(e+Z) ≥ log e = 1 ≥ 0`) and `C ≥ 0`.
-- Insight: the linear bound `v' ≤ C v` is the *growth* mirror of the 2D decay
--   lemma `Core.energy_exponential_decay` (rate `c = -C`) — the same integrating
--   factor governs both 2D dissipation and the borderline; only the sign flips.
-- Insight: the resulting growth is double-exponential `exp(c₀ e^{Ct})`; any stronger
--   correction (e.g. `Z log²(e+Z)` or the bare `Z³`) breaks the linearisation and
--   restores finite-time blow-up — pinpointing `Z log(e+Z)` as the sharp threshold.
-- Failure analysis: attempting `v = log Z` (without the `+e` shift) fails because
--   `log Z` is unbounded below and `Z' /Z ≤ C log Z` can have negative RHS; the
--   shift `e + Z` keeps `v ≥ 1 > 0` and the inequality one-signed.
-/

open scoped Topology
open Filter

namespace NavierStokes

/-! ## Linearised borderline inequality for `v = log(e + Z)` -/

/-
**Logarithmic enstrophy bound.** Under the critical inequality
`Z'(t) ≤ C · Z(t) · log(e + Z(t))` with `C ≥ 0` and `Z ≥ 0`, the logarithmic
observable `v = log(e + Z)` grows at most exponentially:
`log(e + Z(t)) ≤ log(e + Z₀) · e^{C t}` for all `t ≥ 0`.
-/
theorem log_enstrophy_linear_bound
    (Z D : ℝ → ℝ) (C : ℝ) (hC : 0 ≤ C)
    (hZnn : ∀ t, 0 ≤ Z t)
    (hZ : ∀ t, HasDerivAt Z (D t) t)
    (hineq : ∀ t, D t ≤ C * Z t * Real.log (Real.exp 1 + Z t)) :
    ∀ t, 0 ≤ t →
      Real.log (Real.exp 1 + Z t) ≤ Real.log (Real.exp 1 + Z 0) * Real.exp (C * t) := by
  -- Define `g t = v t * Real.exp (-C * t)` and show that its derivative is non-positive by calculating it directly.
  have hg_deriv : ∀ t, HasDerivAt (fun t => Real.log (Real.exp 1 + Z t) * Real.exp (-C * t)) ((D t * (Real.exp 1 + Z t)⁻¹ - C * Real.log (Real.exp 1 + Z t)) * Real.exp (-C * t)) t := by
    intro t; convert HasDerivAt.mul ( HasDerivAt.log ( HasDerivAt.add ( hasDerivAt_const _ _ ) ( hZ t ) ) _ ) ( HasDerivAt.exp ( HasDerivAt.const_mul ( -C ) ( hasDerivAt_id t ) ) ) using 1 <;> ring ;
    · norm_num ; ring!;
    · exact ne_of_gt ( add_pos_of_pos_of_nonneg ( Real.exp_pos _ ) ( hZnn _ ) );
  -- By definition of $g$, we know that $g'(t) \leq 0$.
  have hg_deriv_nonpos : ∀ t, deriv (fun t => Real.log (Real.exp 1 + Z t) * Real.exp (-C * t)) t ≤ 0 := by
    intro t; rw [ hg_deriv t |> HasDerivAt.deriv ] ; refine' mul_nonpos_of_nonpos_of_nonneg _ ( Real.exp_nonneg _ ) ;
    field_simp;
    rw [ sub_nonpos, div_le_iff₀ ] <;> nlinarith [ hZnn t, hineq t, Real.exp_pos 1, Real.log_nonneg ( show 1 ≤ Real.exp 1 + Z t by linarith [ Real.add_one_le_exp 1, hZnn t ] ), mul_nonneg hC ( Real.log_nonneg ( show 1 ≤ Real.exp 1 + Z t by linarith [ Real.add_one_le_exp 1, hZnn t ] ) ) ];
  -- Since $g'(t) \leq 0$, $g(t)$ is non-increasing.
  have hg_noninc : Antitone (fun t => Real.log (Real.exp 1 + Z t) * Real.exp (-C * t)) := by
    apply_rules [ antitone_of_deriv_nonpos ];
    exact fun t => ( hg_deriv t |> HasDerivAt.differentiableAt );
  intro t ht; specialize hg_noninc ht; simp_all +decide [ Real.exp_neg, mul_comm ] ;
  rwa [ inv_mul_le_iff₀ ( Real.exp_pos _ ) ] at hg_noninc

/-! ## Global regularity: the double-exponential a priori bound -/

/-
**No finite-time blow-up at the borderline.** The critical inequality forces the
explicit double-exponential a priori bound
`Z(t) ≤ exp(log(e + Z₀) · e^{C t}) - e` for all `t ≥ 0`. The right-hand side is
finite for every finite `t`, so the enstrophy never blows up in finite time:
global regularity holds at the logarithmic borderline.
-/
theorem log_critical_no_blowup
    (Z D : ℝ → ℝ) (C : ℝ) (hC : 0 ≤ C)
    (hZnn : ∀ t, 0 ≤ Z t)
    (hZ : ∀ t, HasDerivAt Z (D t) t)
    (hineq : ∀ t, D t ≤ C * Z t * Real.log (Real.exp 1 + Z t)) :
    ∀ t, 0 ≤ t →
      Z t ≤ Real.exp (Real.log (Real.exp 1 + Z 0) * Real.exp (C * t)) - Real.exp 1 := by
  intro t ht;
  have := log_enstrophy_linear_bound Z D C hC hZnn hZ hineq t ht;
  linarith [ Real.exp_log ( show 0 < Real.exp 1 + Z t by linarith [ Real.exp_pos 1, hZnn t ] ), Real.exp_le_exp.mpr this ]

end NavierStokes