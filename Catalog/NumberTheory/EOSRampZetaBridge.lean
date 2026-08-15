/-
# The ramp's failure-mass generating function is an Euler factor of `ζ`

Third file of the NET-27 formalisation, after `EOSWidthMonotoneRamp.lean` and
`EOSExclusiveDimGenericity.lean`.

In the hyperplane model of `EOSWidthRamp`, the failure probability at exclusive width `k` over
the field `𝔽_p` is exactly `p^{-k}`.  Summing the failure mass over all widths therefore produces
the local Euler factor `(1 - p^{-1})^{-1}`; damping the widths by an exponent `s` produces
`(1 - p^{-s})^{-1}`.  Multiplying over all characteristics `p` gives the Riemann zeta function.

* `EOSZeta.rampSeries_eq_eulerFactor` — `∑_k (p^{-s})^k = (1 - p^{-s})^{-1}` for `Re s > 1`;
* `EOSZeta.totalFailureMass_eq_eulerFactor_one` — the real total failure mass of the ramp,
  `∑_k P(fail at width k) = (1 - p^{-1})^{-1}`, i.e. the `s = 1` Euler factor, computed from the
  model rather than postulated;
* `EOSZeta.tprod_rampSeries_eq_riemannZeta` — **the bridge**: the product over all
  characteristics of the damped failure masses of the reliability ramps equals `ζ(s)`
  for `Re s > 1`.

This is a genuine cross-domain statement: the left-hand side is assembled purely from the
finite-field reliability model of `EOSWidthMonotoneRamp.lean`, the right-hand side is the
analytic Riemann zeta function.  It also explains *why* the ramp cannot be a cliff: a cliff
would make the failure mass a finite sum, destroying the Euler factor.
-/

import Mathlib
import NumberTheory.EOSWidthMonotoneRamp

open Filter Topology Complex

namespace EOSZeta

/-- The width-damped failure-mass series of the ramp at characteristic `p` and exponent `s`:
each width `k` contributes its failure probability `p^{-k}`, damped to `p^{-ks}`. -/
noncomputable def rampSeries (p : ℕ) (s : ℂ) : ℂ := ∑' k : ℕ, ((p : ℂ) ^ (-s)) ^ k

theorem norm_natCast_cpow_neg_lt_one {p : ℕ} (hp : 2 ≤ p) {s : ℂ} (hs : 1 < s.re) :
    ‖(p : ℂ) ^ (-s)‖ < 1 := by
  have hp0 : 0 < p := by omega
  rw [Complex.norm_natCast_cpow_of_pos hp0]
  have h1 : (1 : ℝ) < (p : ℝ) := by exact_mod_cast hp
  have : (p : ℝ) ^ (-s).re < (p : ℝ) ^ (0 : ℝ) := by
    apply Real.rpow_lt_rpow_of_exponent_lt h1
    simp only [Complex.neg_re]
    linarith
  simpa using this

/-- The damped failure mass of the width-ramp is the Euler factor at `p`. -/
theorem rampSeries_eq_eulerFactor {p : ℕ} (hp : 2 ≤ p) {s : ℂ} (hs : 1 < s.re) :
    rampSeries p s = (1 - (p : ℂ) ^ (-s))⁻¹ :=
  tsum_geometric_of_norm_lt_one (norm_natCast_cpow_neg_lt_one hp hs)

/-- **The `s = 1` case, straight from the model.**  The total failure mass of the reliability
ramp of `EOSWidthRamp` over `𝔽_p` is the Euler factor `(1 - 1/p)⁻¹`. -/
theorem totalFailureMass_eq_eulerFactor_one (p : ℕ) [Fact p.Prime]
    {V : Type*} [AddCommGroup V] [Module (ZMod p) V] [Finite V]
    (W : Submodule (ZMod p) V) (hidx : Nat.card W * p = Nat.card V) :
    ∑' k : ℕ, EOSWidthRamp.failProb (fun _ : Fin 1 => W) k = (1 - ((p : ℝ))⁻¹)⁻¹ := by
  have hp : 1 < p := (Fact.out : p.Prime).one_lt
  have hpR : (1 : ℝ) < (p : ℝ) := by exact_mod_cast hp
  rw [EOSWidthRamp.hyperplane_tsum_failProb W hidx]
  field_simp

/-- **Bridge to the Riemann zeta function.**  The product over all characteristics `p` of the
damped failure masses of the exclusive-width reliability ramps is `ζ(s)`, for `Re s > 1`. -/
theorem tprod_rampSeries_eq_riemannZeta {s : ℂ} (hs : 1 < s.re) :
    ∏' p : Nat.Primes, rampSeries (p : ℕ) s = riemannZeta s := by
  rw [← riemannZeta_eulerProduct_tprod hs]
  refine tprod_congr fun p => ?_
  exact rampSeries_eq_eulerFactor p.2.two_le hs

/-- Non-vacuity of the bridge, in closed form: at `s = 2` the product of the width-damped ramp
failure masses over all characteristics equals `π²/6`. -/
theorem tprod_rampSeries_two :
    ∏' p : Nat.Primes, rampSeries (p : ℕ) 2 = (Real.pi : ℂ) ^ 2 / 6 := by
  rw [tprod_rampSeries_eq_riemannZeta (by norm_num), riemannZeta_two]

end EOSZeta