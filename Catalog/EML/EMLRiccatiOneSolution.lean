import Mathlib
import EML.EMLLogDerivHom
import EML.EMLFirstOrderGroup
import EML.EMLRiccatiMobius

/-!
# One Known Solution Linearizes the Riccati Equation (EML Integrability)

The catalog proves the *negative* differential-Galois fact for Airy: its associated
Riccati equation `v′ + v² = x` has **no** rational solution
(`EML.EMLAiryRiccati`, `EML.EMLKovacicSharp`).  This file proves the matching
*positive* structural fact: **as soon as one solution `v₀` of a Riccati equation is
known, the equation linearizes** — the substitution `v = v₀ + 1/u` turns the nonlinear
Riccati equation `v′ + v² + p·v + q = 0` into the *first-order linear* (affine) equation

    u′ = (2·v₀ + p)·u + 1,

which is EML-solvable by the first-order calculus of `EML.EMLLogDerivHom` /
`EML.EMLFirstOrderGroup`.  This is the differential-Galois reason a Riccati equation
with a known solution is "integrable by quadratures": its Galois group drops from
`PGL₂(constants)` (the projective action of `EML.EMLRiccatiMobius`) to an affine
subgroup.

Everything is in an arbitrary differential field `K` (Mathlib's `Differential`
typeclass, derivation `·′`).

## Main results

* `riccati_oneSolution_identity` — the cleared algebraic identity
  `(v₀ + u⁻¹ Riccati expression)·u² = (2·v₀ + p)·u + 1 − u′`, valid whenever `v₀` is a
  solution and `u ≠ 0`.
* `riccati_solvable_iff_linear` — **the linearization**: with `v₀` a solution and
  `u ≠ 0`, `v = v₀ + 1/u` solves the Riccati equation **iff** `u` solves the affine
  linear equation `u′ = (2·v₀ + p)·u + 1`.
* `riccati_solution_gives_linear` — **converse extraction**: any *other* solution `v`
  yields a solution `u = 1/(v − v₀)` of the linear equation; together with the forward
  map this is a bijection between Riccati solutions `≠ v₀` and solutions of the linear
  equation.
* `riccati_secondSolution_diff_logDeriv` — the companion *homogeneous* Bernoulli fact:
  the difference `v − v₀` of two solutions has logarithmic derivative
  `−(v + v₀ + p)` (a first-order EML solution, reusing `EML.EMLRiccatiMobius`).

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the catalog's Riccati theory is either abstract-projective
(`EMLRiccatiMobius`, `PGL₂`) or negative (Airy unsolvable).  We conjectured the decisive
*positive* integrability fact: a single known solution `v₀` collapses the Riccati
equation to a first-order linear (affine) equation via `v = v₀ + 1/u`, with explicit
coefficient `u′ = (2v₀ + p)u + 1`.  Prediction: this is an *iff* (a bijection between
the two solution sets), proved division-free after clearing `u²`.

Experiment (Experimenter): compute `(v₀ + u⁻¹ Riccati)·u²`.  Using
`(u⁻¹)′ = −(u⁻¹)² u′` (`Derivation.leibniz_inv`) the `v₀`-part is killed by the
solution hypothesis `h0` and the rest telescopes to `(2v₀+p)u + 1 − u′`; `field_simp`
then `linear_combination (… )·h0` closes it.  The iff is `mul_eq_zero`/`resolve_right`
on `u² ≠ 0`.  The converse takes `u = (v − v₀)⁻¹`: `inv_inv` turns `v₀ + u⁻¹` back into
`v`, so the forward iff applies verbatim.  The Bernoulli companion is a direct call to
the catalog `EMLRiccatiMobius.riccati_diff_logDeriv`.

Analysis (Analyst): the affine equation `u′ = (2v₀+p)u + 1` is exactly first-order
linear inhomogeneous — its *homogeneous* part `u′ = (2v₀+p)u` is an `EMLFirstOrderGroup`
equation (Galois group `Gₘ(constants)`), so the inhomogeneous one is solvable by
variation of constants over the constants.  Hence the Riccati Galois group, restricted
to fixing `v₀`, is the *affine* group `Gₐ ⋊ Gₘ` — a solvable EML group — explaining
"one solution ⇒ integrable by quadratures".  The `2v₀` in the coefficient is the
linearization (Jacobian `∂(−v²−pv−q)/∂v = −2v − p`) of the Riccati right-hand side at
`v₀`, evaluated with the catalog sign conventions.

Critique (Critic): non-vacuous and load-bearing.  `riccati_solvable_iff_linear` needs
`u ≠ 0` (else `1/u` undefined) and genuinely uses the solution hypothesis `h0` (drop it
and the `v₀`-terms survive, breaking the identity).  `riccati_solution_gives_linear`
needs `v ≠ v₀` (else `u` is undefined / zero).  The proofs use real
`field_simp`/`linear_combination`/`mul_eq_zero` reasoning, never `rfl`/`decide`.

Synthesis (PI): the catalog now has the full Riccati Galois trichotomy: projective
`PGL₂(constants)` action in general (`EMLRiccatiMobius`), *affine* collapse once one
solution is known (this file), and the *negative* boundary that Airy admits no rational
solution to even begin the collapse (`EMLAiryRiccati`).  One known solution is exactly
the hinge between "EML-unsolvable" and "EML-integrable".
-- !-- Lab Notes -- !--
-/

open scoped Differential

namespace EMLRiccatiOneSolution

variable {K : Type*} [Field K] [Differential K]

/-! ### The cleared linearization identity -/

/-- **Cleared linearization identity.** If `v₀` solves the Riccati equation
`v′ + v² + p·v + q = 0` and `u ≠ 0`, then the Riccati expression evaluated at
`v = v₀ + 1/u`, multiplied by `u²`, equals `(2·v₀ + p)·u + 1 − u′`.  This is the
algebraic engine of the linearization. -/
theorem riccati_oneSolution_identity (p q v₀ u : K) (hu : u ≠ 0)
    (h0 : v₀′ + v₀ ^ 2 + p * v₀ + q = 0) :
    ((v₀ + u⁻¹)′ + (v₀ + u⁻¹) ^ 2 + p * (v₀ + u⁻¹) + q) * u ^ 2
      = (2 * v₀ + p) * u + 1 - u′ := by
  have hinv : (u⁻¹)′ = -(u⁻¹) ^ 2 * u′ := by
    rw [Derivation.leibniz_inv]; simp [smul_eq_mul]
  rw [map_add, hinv]
  field_simp
  linear_combination u ^ 2 * h0

/-! ### The linearization (iff) -/

/-- **One known solution linearizes the Riccati equation.** With `v₀` a solution and
`u ≠ 0`, the function `v = v₀ + 1/u` solves the Riccati equation
`v′ + v² + p·v + q = 0` **iff** `u` solves the first-order *linear* (affine) equation
`u′ = (2·v₀ + p)·u + 1`.  This drops the Riccati Galois group to a solvable affine
subgroup — the differential-Galois statement of "integrability by quadratures once one
solution is known". -/
theorem riccati_solvable_iff_linear (p q v₀ u : K) (hu : u ≠ 0)
    (h0 : v₀′ + v₀ ^ 2 + p * v₀ + q = 0) :
    ((v₀ + u⁻¹)′ + (v₀ + u⁻¹) ^ 2 + p * (v₀ + u⁻¹) + q = 0) ↔
      (u′ = (2 * v₀ + p) * u + 1) := by
  have hu2 : u ^ 2 ≠ 0 := pow_ne_zero 2 hu
  have hid := riccati_oneSolution_identity p q v₀ u hu h0
  constructor
  · intro h
    have hz : (2 * v₀ + p) * u + 1 - u′ = 0 := by rw [← hid, h, zero_mul]
    linear_combination -hz
  · intro h
    have h2 : ((v₀ + u⁻¹)′ + (v₀ + u⁻¹) ^ 2 + p * (v₀ + u⁻¹) + q) * u ^ 2 = 0 := by
      rw [hid]; linear_combination -h
    exact (mul_eq_zero.mp h2).resolve_right hu2

/-! ### Converse: any other solution yields a linear solution -/

/-- **Converse extraction.** If `v₀` and `v` both solve the Riccati equation and
`v ≠ v₀`, then `u = 1/(v − v₀)` solves the linear equation
`u′ = (2·v₀ + p)·u + 1`.  Together with `riccati_solvable_iff_linear` this is a
bijection between Riccati solutions distinct from `v₀` and solutions of the linear
equation. -/
theorem riccati_solution_gives_linear (p q v₀ v : K) (hv : v ≠ v₀)
    (h0 : v₀′ + v₀ ^ 2 + p * v₀ + q = 0)
    (hv_eq : v′ + v ^ 2 + p * v + q = 0) :
    ((v - v₀)⁻¹)′ = (2 * v₀ + p) * (v - v₀)⁻¹ + 1 := by
  have hd : v - v₀ ≠ 0 := sub_ne_zero.mpr hv
  have hu : (v - v₀)⁻¹ ≠ 0 := inv_ne_zero hd
  have hsub : v₀ + ((v - v₀)⁻¹)⁻¹ = v := by rw [inv_inv]; ring
  exact (riccati_solvable_iff_linear p q v₀ ((v - v₀)⁻¹) hu h0).mp (by rw [hsub]; exact hv_eq)

/-! ### Bernoulli companion: difference logarithmic derivative -/

/-- **Bernoulli companion.** The difference `v − v₀` of two Riccati solutions is a
first-order EML solution with logarithmic derivative `−(v + v₀ + p)` (the homogeneous
part of the affine linearization).  This is the catalog
`EMLRiccatiMobius.riccati_diff_logDeriv` specialized to the known-solution setting. -/
theorem riccati_secondSolution_diff_logDeriv (p q v₀ v : K)
    (h0 : v₀′ + v₀ ^ 2 + p * v₀ + q = 0)
    (hv_eq : v′ + v ^ 2 + p * v + q = 0) (hv : v ≠ v₀) :
    (v - v₀)′ / (v - v₀) = -(v + v₀ + p) :=
  EMLRiccatiMobius.riccati_diff_logDeriv p q v v₀ hv_eq h0 hv

end EMLRiccatiOneSolution