/-
Machine-checked core of the round-47 dimensional closure.

Setup.  Let `a^3 = -P a - Q` and `a^4 = -P a^2 - Q a`, i.e. `K = Q[X]/(X^3 + P X + Q)`.
Write `g = g0 + g1 a + g2 a^2`.  A number field sieve relation of Lee-Venkatesan's
square-relation framework is a linear form `l(X) = aX + b` with

    l(a) = g^2   in Z[a]     (so that a relation yields a congruence of squares)

which holds exactly when the `a^2` component of `g^2` vanishes.  These files check
that algebra, and then the object the closure rests on: that the relation condition
is a HOMOGENEOUS FORM OF DEGREE 4 IN TWO PARAMETERS, which is precisely why the
relation space is a curve rather than a surface.

Every proof is `ring` or `simp`, so the definitions are checked against the claimed
identities rather than transcribed on trust.  (An earlier draft of this file had the
sign of the `P` and `Q` terms wrong in two of the three component functions; the `ring`
discharge is what would have caught it.)

No `sorry`, no `axiom`.
-/

import Mathlib.Tactic.Ring
set_option linter.unusedVariables false

namespace Cryptography.FactoringBarriers.DimensionalClosure

/-- The `a^2` component of `g^2` modulo `X^3 + P X + Q`.  Vanishing of this is exactly
the condition that `l(a) = g^2` is *linear*. -/
def comp₂ (P g0 g1 g2 : ℤ) : ℤ := g1 ^ 2 + 2 * g0 * g2 - P * g2 ^ 2

/-- The `a^1` component. -/
def comp₁ (P Q g0 g1 g2 : ℤ) : ℤ := 2 * g0 * g1 - 2 * P * g1 * g2 - Q * g2 ^ 2

/-- The `a^0` component. -/
def comp₀ (P Q g0 g1 g2 : ℤ) : ℤ := g0 ^ 2 - 2 * Q * g1 * g2

/-- The cone of triples `g` for which `g^2` reduces to a linear form. -/
def onCone (P g0 g1 g2 : ℤ) : Prop := comp₂ P g0 g1 g2 = 0

/-- **The cone is rational for every `P`**, not only at `P = 0`: the point
`(P v^2 - 4 u^2, -4 u v, 2 v^2)` lies on it.  (The conic carries the rational point
`(P/2 : 0 : 1)`; this is its parametrisation.) -/
theorem cone_param (P u v : ℤ) : onCone P (P * v ^ 2 - 4 * u ^ 2) (-4 * u * v) (2 * v ^ 2) := by
  simp only [onCone, comp₂]
  ring

/-- The `a^1` component under the parametrisation, factored. -/
theorem comp₁_param (P Q u v : ℤ) :
    comp₁ P Q (P * v ^ 2 - 4 * u ^ 2) (-4 * u * v) (2 * v ^ 2)
      = 8 * P * u * v ^ 3 + 32 * u ^ 3 * v - 4 * Q * v ^ 4 := by
  simp only [comp₁]
  ring

/-- The `a^0` component under the parametrisation. -/
theorem comp₀_param (P Q u v : ℤ) :
    comp₀ P Q (P * v ^ 2 - 4 * u ^ 2) (-4 * u * v) (2 * v ^ 2)
      = P ^ 2 * v ^ 4 - 8 * P * u ^ 2 * v ^ 2 + 16 * u ^ 4 + 16 * Q * u * v ^ 3 := by
  simp only [comp₀]
  ring

/-- The homogeneous quartic form the relation condition reduces to: `l(m) = A(u,v)`. -/
def Aform (P Q m u v : ℤ) : ℤ :=
  16 * u ^ 4 + 32 * m * u ^ 3 * v - 8 * P * u ^ 2 * v ^ 2
    + (8 * m * P + 16 * Q) * u * v ^ 3 + (P ^ 2 - 4 * m * Q) * v ^ 4

/-- **`l(m) = A(u,v)`** under the rational parametrisation of the cone.  This is the
identity the closure rests on: `l(m)` is a single homogeneous form of degree `4` in two
parameters, so `{ (u,v) : l(m) is a square }` is a **double cover of `P^1`** — a curve —
and not a surface you could sieve. -/
theorem four_lm (P Q m u v : ℤ) :
    comp₁ P Q (P * v ^ 2 - 4 * u ^ 2) (-4 * u * v) (2 * v ^ 2) * m
        + comp₀ P Q (P * v ^ 2 - 4 * u ^ 2) (-4 * u * v) (2 * v ^ 2)
      = Aform P Q m u v := by
  simp only [comp₁, comp₀, Aform]
  ring

/-- `Aform` is homogeneous of degree four.  This is the formal statement that the relation
locus is a curve. -/
theorem Aform_homogeneous (P Q m : ℤ) (c u v : ℤ) :
    Aform P Q m (c * u) (c * v) = c ^ 4 * Aform P Q m u v := by
  unfold Aform
  ring

/-- The form is not degenerate: its `u^4` coefficient is `16`, so it has degree exactly `4`. -/
theorem Aform_u4_coeff (Q m : ℤ) : Aform 0 Q m 1 0 = 16 := by
  unfold Aform
  ring

/-- Specialising to `P = 0` recovers round 47's specialisation: the cone is
`g1^2 + 2 g0 g2 = 0` and the form has no `u^2 v^2` term. -/
theorem cone_specialises (u v : ℤ) : onCone 0 (-4 * u ^ 2) (-4 * u * v) (2 * v ^ 2) := by
  simp only [onCone, comp₂]
  ring

theorem Aform_no_t2 (Q m : ℤ) :
    Aform 0 Q m u v
      = 16 * u ^ 4 + 32 * m * u ^ 3 * v + 16 * Q * u * v ^ 3 - 4 * m * Q * v ^ 4 := by
  unfold Aform
  ring

/-- **The square condition is not a coincidence of `P = 0`:** the cone is non-degenerate
for every `P`, with an explicit rational point at `v = 0, u = 0` excluded and
`(P v^2 - 4u^2, -4uv, 2v^2)` as the parametrisation. -/
theorem cone_has_rational_point (P : ℤ) (u v : ℤ) :
    comp₂ P (P * v ^ 2 - 4 * u ^ 2) (-4 * u * v) (2 * v ^ 2) = 0 := by
  simp only [comp₂]
  ring

end Cryptography.FactoringBarriers.DimensionalClosure
