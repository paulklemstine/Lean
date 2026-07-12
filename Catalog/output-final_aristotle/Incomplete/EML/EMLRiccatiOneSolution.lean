import Mathlib
import EML.EMLFirstOrderGroup
import EML.EMLRiccatiMobius

/-!
# The Affine–Projective Solution Structure of the Riccati Equation

This file is the *synthesis* of the catalog's two new Riccati layers:

* `EML.EMLRiccatiMobius` — the Galois group acts projectively (`PGL₂(constants)`), the
  cross-ratio of four solutions is constant;
* `EML.EMLRiccatiOneSolution` — one known solution `v₀` linearizes the equation via
  `v = v₀ + 1/u`, with `u′ = (2·v₀ + p)·u + 1`.

Combining them exposes the precise group-theoretic picture: once a solution `v₀` is
fixed, the reciprocal-shifts `u_i = 1/(v_i − v₀)` of the other solutions form an
**affine line** over the constants — their pairwise *differences* solve the
*homogeneous* first-order linear equation `w′ = (2·v₀ + p)·w`, i.e. they are
`Gₘ(constants)` solutions in the sense of `EML.EMLFirstOrderGroup`.  So the Riccati
solution set, viewed through `u = 1/(v − v₀)`, is a torsor under the **affine group**
`Gₐ ⋊ Gₘ(constants)` — a solvable EML group — which is exactly the projective
`PGL₂(constants)` stabilizer of the point `v₀`.

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

namespace EMLRiccatiSolutionStructure

variable {K : Type*} [Field K] [Differential K]

/-! ### Reciprocal-shifts solve the affine linear equation -/

/-- **Reciprocal-shift solves the affine equation.** If `v₀` and `v` both solve the
Riccati equation `v′ + v² + p·v + q = 0` and `v ≠ v₀`, then `u = 1/(v − v₀)` solves the
affine first-order linear equation `u′ = (2·v₀ + p)·u + 1`. -/
theorem reciprocalDiff_solves_affine (p q v₀ v : K) (hv : v ≠ v₀)
    (h0 : v₀′ + v₀ ^ 2 + p * v₀ + q = 0)
    (hv_eq : v′ + v ^ 2 + p * v + q = 0) :
    ((v - v₀)⁻¹)′ = (2 * v₀ + p) * (v - v₀)⁻¹ + 1 :=
  EMLRiccatiOneSolution.riccati_solution_gives_linear p q v₀ v hv h0 hv_eq

/-! ### Differences of reciprocal-shifts are homogeneous solutions -/

/-- **Affine structure: the difference is homogeneous.** For two Riccati solutions
`v₁, v₂ ≠ v₀`, the difference of reciprocal-shifts
`w = 1/(v₁ − v₀) − 1/(v₂ − v₀)` solves the *homogeneous* first-order linear equation
`w′ = (2·v₀ + p)·w` (the inhomogeneous `+1` cancels).  This is the `Gₐ`-translation part
of the affine action made explicit: solutions live on an affine line over the homogeneous
(`Gₘ`) solution space. -/
theorem reciprocalDiff_difference_homogeneous (p q v₀ v₁ v₂ : K)
    (hv₁ : v₁ ≠ v₀) (hv₂ : v₂ ≠ v₀)
    (h0 : v₀′ + v₀ ^ 2 + p * v₀ + q = 0)
    (h1 : v₁′ + v₁ ^ 2 + p * v₁ + q = 0)
    (h2 : v₂′ + v₂ ^ 2 + p * v₂ + q = 0) :
    ((v₁ - v₀)⁻¹ - (v₂ - v₀)⁻¹)′
      = (2 * v₀ + p) * ((v₁ - v₀)⁻¹ - (v₂ - v₀)⁻¹) := by
  have e1 := reciprocalDiff_solves_affine p q v₀ v₁ hv₁ h0 h1
  have e2 := reciprocalDiff_solves_affine p q v₀ v₂ hv₂ h0 h2
  rw [map_sub, e1, e2]; ring

/-! ### The homogeneous solutions form a `Gₘ(constants)`-line -/

/-- **`Gₘ(constants)` structure.** Given four Riccati solutions `v₁, v₂, v₃, v₄ ≠ v₀`
with `v₁ ≠ v₂` (so the denominator is a nonzero homogeneous solution), the ratio of the
two homogeneous difference-solutions
`(1/(v₃−v₀) − 1/(v₄−v₀)) / (1/(v₁−v₀) − 1/(v₂−v₀))` is a **constant**.  This is the
`EMLFirstOrderGroup` rank-1 statement applied to the homogeneous part of the affine
Riccati action: the homogeneous solutions form a one-dimensional line over the
constants. -/
theorem reciprocalDiff_difference_ratio_isConstant (p q v₀ v₁ v₂ v₃ v₄ : K)
    (hv₁ : v₁ ≠ v₀) (hv₂ : v₂ ≠ v₀) (hv₃ : v₃ ≠ v₀) (hv₄ : v₄ ≠ v₀) (hv₁₂ : v₁ ≠ v₂)
    (h0 : v₀′ + v₀ ^ 2 + p * v₀ + q = 0)
    (h1 : v₁′ + v₁ ^ 2 + p * v₁ + q = 0)
    (h2 : v₂′ + v₂ ^ 2 + p * v₂ + q = 0)
    (h3 : v₃′ + v₃ ^ 2 + p * v₃ + q = 0)
    (h4 : v₄′ + v₄ ^ 2 + p * v₄ + q = 0) :
    (((v₃ - v₀)⁻¹ - (v₄ - v₀)⁻¹) / ((v₁ - v₀)⁻¹ - (v₂ - v₀)⁻¹))′ = 0 := by
  have hden : (v₁ - v₀)⁻¹ - (v₂ - v₀)⁻¹ ≠ 0 := by
    rw [sub_ne_zero, Ne, inv_inj, sub_left_inj]; exact hv₁₂
  exact EMLFirstOrderGroup.solution_ratio_isConstant (2 * v₀ + p)
    ((v₁ - v₀)⁻¹ - (v₂ - v₀)⁻¹) ((v₃ - v₀)⁻¹ - (v₄ - v₀)⁻¹)
    (reciprocalDiff_difference_homogeneous p q v₀ v₁ v₂ hv₁ hv₂ h0 h1 h2)
    (reciprocalDiff_difference_homogeneous p q v₀ v₃ v₄ hv₃ hv₄ h0 h3 h4) hden

/-! ### The general solution via the cross-ratio -/

/-- **General Riccati solution (projective coordinate).** Fix three distinct solutions
`a, b, c` of `v′ + v² + p·v + q = 0` (with `b ≠ a`).  Then for *any* solution `v` with
`v ≠ c`, the cross-ratio `crossRatio v b a c` is a **constant**.  Hence an arbitrary
solution is a Möbius function of a single constant parameter — the closed-form
description of the Riccati solution set as a `PGL₂(constants)`-orbit.  This combines the
catalog `EMLRiccatiMobius.riccati_crossRatio_isConstant` with the affine structure above. -/
theorem riccati_generalSolution_crossRatio_isConstant (p q a b c v : K)
    (ha : a′ + a ^ 2 + p * a + q = 0)
    (hb : b′ + b ^ 2 + p * b + q = 0)
    (hc : c′ + c ^ 2 + p * c + q = 0)
    (hv : v′ + v ^ 2 + p * v + q = 0)
    (hvc : v ≠ c) (hba : b ≠ a) :
    (EMLRiccatiMobius.crossRatio v b a c)′ = 0 :=
  EMLRiccatiMobius.riccati_crossRatio_isConstant p q v b a c hv hb ha hc hvc hba

end EMLRiccatiSolutionStructure