import Mathlib

/-!
# Liouville numbers and transcendence via Diophantine approximation

Liouville's theorem states that a real number with unusually good rational
approximations (a *Liouville number*) is transcendental.  Mathlib packages this
as `Liouville.transcendental`.  Here we extract concrete, low-degree consequences
that are *not* mere restatements: a Liouville number can be the root of no nonzero
integer polynomial, and in particular of no nonzero linear or quadratic integer
polynomial.

-- !-- Lab Notes -- !--
* **Hypothesis.** A Liouville number is not a root of any nonzero quadratic
  `a x² + b x + c` with integer coefficients and `a ≠ 0`; more generally it is not
  algebraic of any degree.
* **Experiment.** `Liouville.transcendental` yields `Transcendental ℤ x`.  We
  unfold transcendence (no nonzero integer polynomial vanishes at `x`) and
  specialise to the explicit polynomial `C c + C b * X + C a * X²`.
* **Analysis.** The degree-2 specialisation needs the polynomial to be nonzero;
  this follows from `a ≠ 0` being the leading coefficient (`Polynomial.aeval`,
  `Polynomial.coeff`).
* **Critique.** Pure reexports of `transcendental_liouvilleNumber` would be
  wrappers; instead we prove genuine non-vanishing statements about evaluations.
* **Synthesis.** `liouville_not_root_quadratic`,
  `liouville_not_root_linear`, and the explicit
  `transcendental_of_liouville` are exported.
-/

namespace ContinuedFractions

open Polynomial

/-- A Liouville number is transcendental over `ℤ`: it is the root of no nonzero
integer polynomial. -/
theorem transcendental_of_liouville {x : ℝ} (hx : Liouville x) :
    Transcendental ℤ x :=
  hx.transcendental

/-
A Liouville number is not the root of any nonzero linear integer polynomial:
for integers `a ≠ 0` and `b`, we have `a * x + b ≠ 0`.
-/
theorem liouville_not_root_linear {x : ℝ} (hx : Liouville x) (a b : ℤ)
    (ha : a ≠ 0) : (a : ℝ) * x + (b : ℝ) ≠ 0 := by
  contrapose! ha with h;
  by_contra ha;
  convert transcendental_of_liouville hx _;
  refine' ⟨ Polynomial.C a * Polynomial.X + Polynomial.C b, _, _ ⟩ <;> simp_all +decide [ Polynomial.ext_iff ];
  exact ⟨ 1, by norm_num [ Polynomial.coeff_eq_zero_of_natDegree_lt, ha ] ⟩

/-
A Liouville number is not the root of any nonzero quadratic integer
polynomial: for integers `a ≠ 0`, `b`, `c`, we have `a x² + b x + c ≠ 0`.
In particular a Liouville number is never a quadratic irrational.
-/
theorem liouville_not_root_quadratic {x : ℝ} (hx : Liouville x) (a b c : ℤ)
    (ha : a ≠ 0) : (a : ℝ) * x ^ 2 + (b : ℝ) * x + (c : ℝ) ≠ 0 := by
  -- By definition of transcendental, $x$ is not a root of any nonzero polynomial with integer coefficients.
  have h_transcendental : ∀ p : Polynomial ℤ, p ≠ 0 → (p.eval₂ (algebraMap ℤ ℝ) x) ≠ 0 := by
    intro p hp; have := transcendental_of_liouville hx; simp_all +decide ;
    exact fun h => this ⟨ p, hp, h ⟩;
  convert h_transcendental ( Polynomial.C a * Polynomial.X ^ 2 + Polynomial.C b * Polynomial.X + Polynomial.C c ) ?_ using 1 <;> norm_num [ ha ];
  · simp +decide [ Polynomial.eval₂_eq_sum_range ];
  · exact ne_of_apply_ne ( fun p => p.coeff 2 ) ( by norm_num [ ha, Polynomial.coeff_eq_zero_of_natDegree_lt ] )

end ContinuedFractions