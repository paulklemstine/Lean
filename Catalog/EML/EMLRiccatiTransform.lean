import Mathlib
import EML.EMLDiffObstruction

/-!
# The Riccati Transform in an Abstract Differential Field

This file develops the *abstract* differential-algebra layer underlying the
concrete Airy/Kovacic obstructions of `EML.EMLDiffObstruction` and
`EML.EMLAiryRiccati`.  Working in an arbitrary differential field `K`
(Mathlib's `Differential` typeclass, with derivation `·′`), we prove the two
structural facts that make the Riccati/Wronskian machinery work:

* the **Riccati transform**: the logarithmic derivative `v = y′/y` of any nonzero
  `y` satisfies `v′ + v² = y″/y`, so a solution of the linear equation
  `y″ = a·y` produces a solution of the Riccati equation `v′ + v² = a`;
* the **Wronskian constancy** (abstract Abel identity): if `y₁, y₂` both satisfy
  `y″ = a·y`, their Wronskian `W = y₁·y₂′ − y₂·y₁′` has zero derivative.

These are the field-theoretic counterparts of the polynomial statements in the
catalog (`EMLDiffObstruction.poly_wronskian_derivative_zero`,
`EMLDiffObstruction.no_poly_solves_riccati_airy`).  Together with the rational
obstruction `EMLAiryRiccati.no_rational_solves_riccati_airy` they assemble the
Kovacic decision step for Airy: *if* `y″ = x·y` had a solution `y` whose
logarithmic derivative were rational, that logarithmic derivative would be a
rational solution of `v′ + v² = x` — which is impossible.

## Main results

* `Differential.logDeriv_riccati` — `(y′/y)′ + (y′/y)² = y″/y` for `y ≠ 0`.
* `Differential.riccati_of_second_order` — `y″ = a·y, y ≠ 0 ⇒ (y′/y)′ + (y′/y)² = a`.
* `Differential.wronskian_deriv_eq_zero` — abstract Abel identity.
* `Differential.riccati_squared_add_deriv` — the Riccati expression rewritten via
  the second derivative, a convenient algebraic normal form.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the entire Airy obstruction should factor through *two*
identities that hold in *any* differential field, independent of `ℝ[X]`: the Riccati
transform `v = y′/y ↦ v′+v² = y″/y`, and Wronskian constancy. If so, the concrete
catalog/rational results are just these identities specialized and combined with a
degree count.

Experiment (Experimenter): both identities reduce to `Derivation.leibniz` /
`Derivation.leibniz_div` followed by `field_simp; ring`. No characteristic or
algebraic-closure hypotheses are needed — only `Field K` and `Differential K`.

Analysis (Analyst): the Riccati transform is *the* reason the second-order linear
problem is governed by a first-order quadratic problem; the `y ≠ 0` hypothesis is
exactly what is needed to form `y′/y`. Wronskian constancy is the abstract source of
the catalog's `poly_wronskian_derivative_zero`, now proved once and for all over any
differential field rather than only in `ℝ[X]`.

Critique (Critic): neither theorem is vacuous or `rfl`: both genuinely use the Leibniz
rule of the derivation and quotient differentiation. The `field_simp`/`ring` core is
insight-bearing (it is where the quadratic `(y′/y)²` cancels against `y″ y − y′ y′`).
The hypothesis `y ≠ 0` is load-bearing (the logarithmic derivative is otherwise undefined).

Synthesis (PI): these abstract identities are the hinge between the polynomial layer
(catalog) and the rational layer (`EMLAiryRiccati`); they show the obstruction is a
property of the differential field, with `ℝ[X] ⊂ ℝ(X)` supplying the degree count that
finishes Airy.
-- !-- Lab Notes -- !--
-/

open scoped Differential

namespace Differential

variable {K : Type*} [Field K] [Differential K]

/-- **Riccati transform (raw form).** For `y ≠ 0`, the logarithmic derivative
`v = y′/y` satisfies `v′ + v² = y″/y`. -/
theorem logDeriv_riccati (y : K) (hy : y ≠ 0) :
    (Differential.logDeriv y)′ + (Differential.logDeriv y) ^ 2 = (y′)′ / y := by
  unfold Differential.logDeriv
  rw [Derivation.leibniz_div]
  simp only [smul_eq_mul]
  field_simp
  ring

/-- **Riccati transform for second-order linear equations.** If `y ≠ 0` solves the
linear equation `y″ = a·y`, then its logarithmic derivative `v = y′/y` solves the
Riccati equation `v′ + v² = a`. This is the substitution at the heart of the
Kovacic algorithm. -/
theorem riccati_of_second_order (y a : K) (hy : y ≠ 0) (h : (y′)′ = a * y) :
    (Differential.logDeriv y)′ + (Differential.logDeriv y) ^ 2 = a := by
  rw [logDeriv_riccati y hy, h]
  field_simp

/-- A convenient algebraic normal form: for any nonzero `y`, multiplying the Riccati
expression by `y` recovers the second derivative `y″`. -/
theorem riccati_squared_add_deriv (y : K) (hy : y ≠ 0) :
    ((Differential.logDeriv y)′ + (Differential.logDeriv y) ^ 2) * y = (y′)′ := by
  rw [logDeriv_riccati y hy]
  field_simp

/-- **Abstract Abel / Wronskian constancy.** If `y₁` and `y₂` both satisfy the
second-order linear equation `y″ = a·y` in a differential field, then their
Wronskian `W = y₁·y₂′ − y₂·y₁′` has zero derivative. This is the differential-field
generalization of `EMLDiffObstruction.poly_wronskian_derivative_zero`. -/
theorem wronskian_deriv_eq_zero (a y₁ y₂ : K)
    (h₁ : (y₁′)′ = a * y₁) (h₂ : (y₂′)′ = a * y₂) :
    (y₁ * y₂′ - y₂ * y₁′)′ = 0 := by
  simp only [map_sub, Derivation.leibniz, smul_eq_mul]
  rw [h₁, h₂]
  ring

end Differential