import Mathlib
import EML.EMLWronskianGalois

/-!
# Reduction of Order and Normal Form for Second-Order EML ODEs

This file adds the two *order-reduction* engines of the classical second-order
linear ODE theory to the abstract differential-field layer of the catalog
(`EML.EMLDifferentialGalois`, `EML.EMLWronskianGalois`,
`EML.EMLRiccatiTransform`).  Both are mission-critical preprocessing steps for
the Kovacic algorithm, which is stated for the *normal form* `u″ = r·u`, while a
generic exponential–logarithmic ODE carries a first-derivative term
`y″ + p·y′ + q·y = 0`.

Two reductions are formalized, working in an arbitrary differential field `K`
(Mathlib's `Differential` typeclass, derivation `·′`):

* **Normal-form reduction (removal of the `y′` term).**  If `z ≠ 0` is a "gauge"
  with `2·z′ + p·z = 0` (the abstract `z = exp(−½∫p)`), then substituting
  `y = z·u` turns `y″ + p·y′ + q·y = 0` into the normal form `u″ = r·u`.  The
  algebraic heart is the identity
  `(z·u)″ + p·(z·u)′ + q·(z·u) = z·u″ + (z″ + p·z′ + q·z)·u`
  (`reduction_identity`), giving the *iff* `solves_iff_normalForm`.  The explicit
  EML coefficient is `r = (z″ + p·z′ + q·z)/z`, which in characteristic `≠ 2`
  collapses to the classical `r = q − p²/4 − p′/2` (`normalForm_coeff_explicit`,
  stated division-free as `4·(z″+p·z′+q·z) = z·(4q − p² − 2p′)`).

* **Reduction of order (d'Alembert second solution).**  Given one nonzero
  solution `y₁` of `y″ = a·y`, any `w` with `y₁²·w′` *constant* produces a second
  solution `y₂ = y₁·w` (`reduction_of_order`).  Its Wronskian against `y₁` is
  exactly `y₁²·w′` (`reduction_wronskian`), so when that constant is nonzero the
  two solutions are linearly independent over the constants
  (`reduction_linIndep`, via `EMLWronskianGalois.linIndep_of_wronskian_ne_zero`).
  This is the constructive proof that the solution space of a second-order EML
  equation is exactly two-dimensional once one solution is known.

## Main results

* `reduction_identity` — the substitution identity for `y = z·u`.
* `solves_iff_normalForm` — `y″ + p·y′ + q·y = 0 ↔ u″ = r·u` for `y = z·u`.
* `normalForm_coeff_explicit` — the gauge collapses the coefficient to the
  classical EML normal-form coefficient (division-free form).
* `reduction_of_order` — d'Alembert second solution of `y″ = a·y`.
* `reduction_wronskian` — the Wronskian of `y₁` and `y₁·w` equals `y₁²·w′`.
* `reduction_linIndep` — a nonconstant `w` gives an independent second solution.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the catalog only analyses the *normal* second-order
equation `y″ = a·y` (Airy, Kovacic, Wronskian), yet a generic EML ODE has a
first-derivative term `y″ + p·y′ + q·y = 0`.  We conjectured both classical
order-reductions — the gauge `y = z·u` removing the `y′` term, and d'Alembert's
construction of a second solution from a first — hold verbatim in *any*
differential field, with the gauge condition `2z′ + pz = 0` (abstract
`z = exp(−½∫p)`) the only input, and the d'Alembert obstruction being precisely
that `y₁²w′` is constant (= the Wronskian).

Experiment (Experimenter): `reduction_identity` is `Derivation.leibniz` expansion
+ `linear_combination (u′)·(2z′+pz)`.  `solves_iff_normalForm` rewrites by it and
clears `z` with `eq_div_iff`.  `normalForm_coeff_explicit` differentiates the gauge
(`(2z′+pz)′ = 0`, using `(2:K)′ = 0`) and finishes division-free by
`linear_combination 2·hd + p·hz` — so it holds over *any* differential field.
`reduction_of_order` proves `y₁·(y₂″ − a·y₂) = (y₁²w′)′` by
`linear_combination (y₁·w)·h₁`, then cancels `y₁ ≠ 0`.  `reduction_wronskian` is
pure `leibniz; ring`.

Analysis (Analyst): the gauge condition `2z′ + pz = 0` is exactly the first-order
EML equation `z′ = −(p/2)z`, so `z = exp(−½∫p)` — the normal-form reduction is the
first-order EML calculus (`EMLLogDerivHom`) feeding the second-order theory.  The
d'Alembert result makes the abstract "solutions form a ≤2-dimensional
constants-space" of `EMLWronskianGalois` *effective*: one solution plus a
nonconstant `w` (i.e. nonzero Wronskian constant) gives a genuine fundamental
system.  Failure mode: if `y₁²w′` is *zero* then `y₂` is a constant multiple of
`y₁` (dependent) — the boundary is exactly `W = 0`.

Critique (Critic): nothing is vacuous.  `solves_iff_normalForm` and
`reduction_of_order` are load-bearing on `z ≠ 0` / `y₁ ≠ 0` (otherwise the
division / cancellation is undefined or false).  `reduction_linIndep` genuinely
calls the catalog criterion, not `decide`/`rfl`, and its `y₁²w′ ≠ 0` hypothesis is
necessary (dropping it makes the pair dependent).  `normalForm_coeff_explicit` is
proved without any characteristic hypothesis by staying division-free.

Synthesis (PI): with these two reductions the catalog's normal-form theory
(`y″ = r·y`: Airy obstruction, Kovacic parity, Wronskian) now applies to a fully
general second-order EML ODE `y″ + p·y′ + q·y = 0`: gauge to normal form, then run
the obstruction theory; and once a single solution is found, d'Alembert completes
the fundamental system.  This closes the loop between the first-order EML calculus
and the second-order Galois/obstruction layer.
-- !-- Lab Notes -- !--
-/

open scoped Differential

namespace EMLReductionOfOrder

variable {K : Type*} [Field K] [Differential K]

/-! ### Normal-form reduction: removing the first-derivative term -/

/-- **Substitution identity.** If the gauge `z` satisfies `2·z′ + p·z = 0`, then for
every `u`, the differential operator of `y″ + p·y′ + q·y` applied to `y = z·u`
collapses (the `u′` term cancels) to `z·u″ + (z″ + p·z′ + q·z)·u`.  This is the
algebraic engine of the normal-form reduction. -/
theorem reduction_identity (p q z u : K) (hz : 2 * z′ + p * z = 0) :
    ((z * u)′)′ + p * ((z * u)′) + q * (z * u)
      = z * ((u′)′) + ((z′)′ + p * z′ + q * z) * u := by
  simp only [Derivation.leibniz, map_add, smul_eq_mul]
  linear_combination (u′) * hz

/-- **Normal-form criterion.** With a nonzero gauge `z` satisfying `2·z′ + p·z = 0`,
the function `y = z·u` solves `y″ + p·y′ + q·y = 0` **iff** `u` solves the normal-form
equation `u″ = r·u`, where `r = −(z″ + p·z′ + q·z)/z` is the EML normal-form
coefficient.  This is the preprocessing step that brings a general second-order EML
ODE into the `u″ = r·u` shape required by the Kovacic algorithm. -/
theorem solves_iff_normalForm (p q z u : K) (hz0 : z ≠ 0) (hz : 2 * z′ + p * z = 0) :
    (((z * u)′)′ + p * ((z * u)′) + q * (z * u) = 0) ↔
      ((u′)′ = (-((z′)′ + p * z′ + q * z) / z) * u) := by
  rw [reduction_identity p q z u hz, div_mul_eq_mul_div, neg_mul, eq_div_iff hz0]
  constructor
  · intro h; linear_combination h
  · intro h; linear_combination h

/-- **Explicit normal-form coefficient (division-free).** Differentiating the gauge
condition `2·z′ + p·z = 0` collapses `z″ + p·z′ + q·z` to `z·(q − p²/4 − p′/2)`.
Stated division-free (multiplied by `4`) so that it holds in *any* differential
field; in characteristic `≠ 2` it is exactly the classical normal-form coefficient
`r = q − p²/4 − p′/2`. -/
theorem normalForm_coeff_explicit (p q z : K) (hz : 2 * z′ + p * z = 0) :
    4 * ((z′)′ + p * z′ + q * z) = z * (4 * q - p ^ 2 - 2 * p′) := by
  have h2' : (2 : K)′ = 0 := by
    have h : ((2 : K)) = 1 + 1 := by norm_num
    rw [h, map_add]; simp
  have hd : (2 * z′ + p * z)′ = 0 := by rw [hz]; simp
  simp only [Derivation.leibniz, map_add, smul_eq_mul, h2', mul_zero, add_zero] at hd
  linear_combination 2 * hd + p * hz

/-! ### Reduction of order (d'Alembert) -/

/-- **Wronskian of `y₁` and `y₁·w`.** The Wronskian `W(y₁, y₁·w) = y₁·(y₁·w)′ − (y₁·w)·y₁′`
equals `y₁²·w′`.  This is the algebraic identity behind d'Alembert's reduction of
order. -/
theorem reduction_wronskian (y₁ w : K) :
    y₁ * ((y₁ * w)′) - (y₁ * w) * (y₁′) = y₁ * y₁ * w′ := by
  simp only [Derivation.leibniz, smul_eq_mul]; ring

/-- **Reduction of order (d'Alembert).** If `y₁ ≠ 0` solves `y″ = a·y` and `w` is such
that `y₁²·w′` is constant (`(y₁·y₁·w′)′ = 0`), then `y₂ = y₁·w` is again a solution of
`y″ = a·y`.  This constructs the second member of a fundamental system from a single
known solution. -/
theorem reduction_of_order (a y₁ w : K) (hy₁ : y₁ ≠ 0)
    (h₁ : (y₁′)′ = a * y₁) (hW : (y₁ * y₁ * w′)′ = 0) :
    ((y₁ * w)′)′ = a * (y₁ * w) := by
  have key : y₁ * (((y₁ * w)′)′ - a * (y₁ * w)) = (y₁ * y₁ * w′)′ := by
    simp only [Derivation.leibniz, map_add, smul_eq_mul]
    linear_combination (y₁ * w) * h₁
  rw [hW] at key
  have hx : ((y₁ * w)′)′ - a * (y₁ * w) = 0 := (mul_eq_zero.mp key).resolve_left hy₁
  linear_combination hx

/-- **The second solution is independent.** If the constant `y₁²·w′` is *nonzero*, then
`y₁` and the d'Alembert second solution `y₁·w` are linearly independent over the
constants.  (The nonvanishing of `y₁²·w′` is exactly the nonvanishing of the Wronskian,
so no solution hypothesis is needed.)  Uses the catalog Wronskian criterion
`EMLWronskianGalois.linIndep_of_wronskian_ne_zero`. -/
theorem reduction_linIndep (y₁ w : K) (hWne : y₁ * y₁ * w′ ≠ 0) :
    ¬ EMLWronskianGalois.LinDepOverConstants y₁ (y₁ * w) := by
  apply EMLWronskianGalois.linIndep_of_wronskian_ne_zero
  rw [reduction_wronskian]; exact hWne

end EMLReductionOfOrder