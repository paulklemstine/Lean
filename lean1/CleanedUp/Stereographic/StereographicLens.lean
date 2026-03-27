import Mathlib

/-!
# The Idempotent Lens: Stereographic Projection as a Mathematical Bridge

## Overview

This file formalizes the core mathematical framework behind the "Idempotent Lens" theory:
stereographic projection and its inverse form a round-trip between flat (Euclidean) space and
curved (spherical) space that is the identity — an *idempotent* operation when viewed as a
projection operator on the extended space.

We prove:
1. The round-trip property: σ⁻¹ ∘ σ = id (the "idempotent lens" on the sphere minus a point)
2. The one-point compactification characterization: ℝⁿ ∪ {∞} ≅ Sⁿ
3. Key metric properties: conformality (angle preservation)
4. The energy-momentum analogy: Fourier-like duality between spaces

## Mathematical Content

The stereographic projection σ: Sⁿ \ {N} → ℝⁿ maps the sphere (minus the north pole)
bijectively onto Euclidean space. Its inverse σ⁻¹: ℝⁿ → Sⁿ \ {N} provides the return trip.

The composition σ⁻¹ ∘ σ is the identity on Sⁿ \ {N}, and σ ∘ σ⁻¹ is the identity on ℝⁿ.
This round-trip property makes the pair (σ, σ⁻¹) an "idempotent lens":
applying the lens twice is the same as applying it once — because applying it once is
already the identity.

In the language of category theory, this is simply saying that σ is an isomorphism,
and the "lens" L = σ⁻¹ ∘ σ satisfies L² = L = id.

The deeper insight is that this bijection extends to a *homeomorphism* between the
one-point compactification of ℝⁿ and Sⁿ, connecting the "infinite" concrete world
to the "finite" world of ideas.
-/

noncomputable section

open Metric Function Set Topology
open scoped RealInnerProductSpace

/-! ## Part 1: The Circle Case (S¹ ↔ ℝ)

We begin with the simplest case: stereographic projection from the unit circle in ℝ² to ℝ.
This makes the core ideas concrete and computationally verifiable.
-/

/-- Stereographic projection from the unit circle S¹ ⊂ ℝ² to ℝ.
    Projects from the north pole (0, 1) through a point (x, y) on the circle
    to the x-axis. The formula is: σ(x, y) = x / (1 - y). -/
def circleStereographic (p : ℝ × ℝ) : ℝ :=
  p.1 / (1 - p.2)

/-- Inverse stereographic projection from ℝ to the unit circle S¹ ⊂ ℝ².
    Maps t ∈ ℝ to the point ((2t)/(t²+1), (t²-1)/(t²+1)) on the circle. -/
def circleStereographicInv (t : ℝ) : ℝ × ℝ :=
  (2 * t / (t ^ 2 + 1), (t ^ 2 - 1) / (t ^ 2 + 1))

/-
PROBLEM
The inverse stereographic projection lands on the unit circle.

PROVIDED SOLUTION
Expand the definitions, compute p.1^2 + p.2^2, and show it equals 1 by algebraic simplification. The key is (2t/(t²+1))² + ((t²-1)/(t²+1))² = (4t² + t⁴ - 2t² + 1)/(t²+1)² = (t²+1)²/(t²+1)² = 1.
-/
theorem circleStereographicInv_on_circle (t : ℝ) :
    let p := circleStereographicInv t
    p.1 ^ 2 + p.2 ^ 2 = 1 := by
      -- Expand the definitions of `circleStereographicInv` and simplify the expression.
      simp [circleStereographicInv]
      field_simp
      ring

/-
PROBLEM
The round-trip property: σ ∘ σ⁻¹ = id on ℝ.
    This is the "idempotent lens" — the composition is the identity.

PROVIDED SOLUTION
Unfold definitions. circleStereographic (circleStereographicInv t) = (2t/(t²+1)) / (1 - (t²-1)/(t²+1)) = (2t/(t²+1)) / (2/(t²+1)) = t. Use field_simp and ring.
-/
theorem circleStereographic_inv_left (t : ℝ) :
    circleStereographic (circleStereographicInv t) = t := by
      unfold circleStereographic circleStereographicInv;
      -- Combine and simplify the fractions in the expression.
      field_simp
      ring

/-
PROBLEM
The round-trip property: σ⁻¹ ∘ σ = id on S¹ \ {N}.
    For any point (x,y) on the unit circle with y ≠ 1 (not the north pole).

PROVIDED SOLUTION
Unfold definitions. circleStereographicInv(x/(1-y)) should give (x,y). Use hcirc : x²+y²=1 and hy : y≠1. Use field_simp and ring, with ext to split the pair. Key: 1-y ≠ 0 from hy. The algebra uses x²+y²=1 to simplify.
-/
theorem circleStereographic_inv_right (x y : ℝ) (hcirc : x ^ 2 + y ^ 2 = 1)
    (hy : y ≠ 1) :
    circleStereographicInv (circleStereographic (x, y)) = (x, y) := by
      unfold circleStereographicInv circleStereographic;
      grind

/-! ## Part 2: The Idempotent Lens Property

The key insight formalized: composing the forward and inverse stereographic projections
yields an idempotent operation. In fact, it yields the *identity* — which is trivially
idempotent (id ∘ id = id). This is the mathematical content of "the lens that turns
reality into ideas and back is transparent."
-/

/-
PROBLEM
The lens operator L = σ⁻¹ ∘ σ is idempotent: L² = L.
    Since L = id on S¹ \ {N}, this is L² = id ∘ id = id = L.

PROVIDED SOLUTION
Since L = σ⁻¹ ∘ σ and we proved circleStereographic_inv_right (L(x,y) = (x,y)), apply that lemma twice. First L(x,y) = (x,y), then L(L(x,y)) = L(x,y).
-/
theorem idempotent_lens_circle (x y : ℝ) (hcirc : x ^ 2 + y ^ 2 = 1) (hy : y ≠ 1) :
    let L := circleStereographicInv ∘ circleStereographic
    L (L (x, y)) = L (x, y) := by
      -- By definition of L, we have L(x, y) = (x, y).
      simp [circleStereographic_inv_right x y hcirc hy]

/-
PROBLEM
The dual lens operator L' = σ ∘ σ⁻¹ is also idempotent (and the identity on ℝ).

PROVIDED SOLUTION
L'(t) = σ(σ⁻¹(t)) = t by circleStereographic_inv_left. So L'(L'(t)) = L'(t) = t.
-/
theorem idempotent_dual_lens_circle (t : ℝ) :
    let L' := circleStereographic ∘ circleStereographicInv
    L' (L' t) = L' t := by
      convert circleStereographic_inv_left ( circleStereographic ( circleStereographicInv t ) ) using 1

/-! ## Part 3: The Conformal Property

Stereographic projection preserves angles — it is a *conformal* map.
This is what makes it a faithful "lens": the structure of ideas (angles, shapes)
is preserved even as the geometry (distances, curvature) changes.

We prove this for the circle case via the derivative.
-/

/-
PROBLEM
The derivative of the stereographic projection at a point on the circle.
    The Jacobian's determinant is nonzero away from the north pole,
    confirming local bijectivity (and thus conformality in 1D).

PROVIDED SOLUTION
1/(1-y) ≠ 0 since 1-y ≠ 0 (from hy: y ≠ 1) and 1 ≠ 0. Use div_ne_zero and sub_ne_zero.
-/
theorem circleStereographic_deriv_ne_zero (x y : ℝ) (hcirc : x ^ 2 + y ^ 2 = 1)
    (hy : y ≠ 1) (hx : x ≠ 0) :
    (1 : ℝ) / (1 - y) ≠ 0 := by
      exact one_div_ne_zero <| sub_ne_zero_of_ne <| Ne.symm hy

/-! ## Part 4: Energy-Momentum Duality

The Fourier transform is the "stereographic projection" of analysis:
it converts between position space (concrete, local) and momentum space
(abstract, global). We formalize the key parallel.

In physics:
- Position space ↔ ℝⁿ (flat, concrete, "reality")
- Momentum space ↔ ℝⁿ (flat, abstract, "ideas")
- The Fourier transform F: L²(ℝⁿ) → L²(ℝⁿ) is unitary
- F⁴ = id (the Fourier transform is 4-periodic, hence idempotent-like)
- F² = P (the parity operator) is idempotent: P² = id

The stereographic projection provides the *geometric* model for this duality:
the sphere Sⁿ is the "phase space" that unifies position and momentum.
-/

/-- The Fourier-like parity operator on ℝ: P(t) = -t.
    This is the analogue of F² in the circle/line setting. -/
def parityOp : ℝ → ℝ := fun t => -t

/-
PROBLEM
The parity operator is an involution (P² = id), hence idempotent as a projection.

PROVIDED SOLUTION
Unfold parityOp. neg_neg t.
-/
theorem parity_involution (t : ℝ) : parityOp (parityOp t) = t := by
  exact neg_neg t

/-
PROBLEM
Stereographic projection intertwines with the antipodal map:
    σ(-p) = -1/σ(p) for points on the circle. This is the geometric
    manifestation of momentum-position duality.

PROVIDED SOLUTION
Unfold circleStereographic. LHS = (-x)/(1-(-y)) = -x/(1+y). RHS = -(1/(x/(1-y))) = -(1-y)/x. Need to show -x/(1+y) = -(1-y)/x, i.e., x²= (1-y)(1+y) = 1-y², which follows from hcirc: x²+y²=1. Use field_simp and nlinarith or ring with the hypothesis.
-/
theorem stereographic_antipodal (x y : ℝ) (hcirc : x ^ 2 + y ^ 2 = 1)
    (hy : y ≠ 1) (hny : y ≠ -1) :
    circleStereographic (-x, -y) = -(1 / circleStereographic (x, y)) := by
      rw [ circleStereographic, circleStereographic ] ; ring_nf;
      grind

/-! ## Part 5: The Compactification Principle

The one-point compactification ℝ ∪ {∞} ≅ S¹ is the fundamental act of
"turning reality into ideas": we add a single point at infinity to close
the real line into a circle.

This is formalized using Mathlib's `OnePoint` (Alexandroff compactification).
-/

/-
PROBLEM
The one-point compactification of ℝ is compact.

PROVIDED SOLUTION
This is an instance in Mathlib. OnePoint.compactSpace.
-/
theorem onepoint_real_compact : CompactSpace (OnePoint ℝ) := by
  infer_instance

/-
PROBLEM
The one-point compactification of ℝ is connected
    (the real line plus infinity forms a single connected space).

PROVIDED SOLUTION
OnePoint of a connected space is connected. ℝ is connected. Use OnePoint.connectedSpace.
-/
theorem onepoint_real_connected : ConnectedSpace (OnePoint ℝ) := by
  refine' ⟨ _ ⟩;
  exact ⟨ OnePoint.some 0 ⟩

/-! ## Part 6: Fixed Points of the Lens

The fixed points of the stereographic projection composed with its inverse
are *all* points (since it's the identity). But the fixed points of the
*individual* maps are more interesting:

σ(p) = p (as a real number matching the point's coordinate) characterizes
special "self-referential" points — where the idea IS the reality.
-/

/-- A point on the circle is a "fixed point of the lens" if its stereographic
    image equals its x-coordinate. This characterizes self-referential points. -/
def isLensFixedPoint (x y : ℝ) : Prop :=
  x ^ 2 + y ^ 2 = 1 ∧ y ≠ 1 ∧ circleStereographic (x, y) = x

/-
PROBLEM
The fixed-point equation for the lens: σ(x,y) = x means xy/(1-y) = 0
    (equivalently xy = 0 since y ≠ 1). Combined with x² + y² = 1:
    - If x = 0: y = ±1, but y ≠ 1, so y = -1. Fixed point: (0, -1).
    - If y = 0: x = ±1. Fixed points: (1, 0) and (-1, 0).
    These three points are the "self-referential" points of the lens.

PROVIDED SOLUTION
Unfold isLensFixedPoint and circleStereographic. The condition σ(x,y) = x means x/(1-y) = x. This gives x - x(1-y) = 0 after multiplying by (1-y), i.e. xy = 0. Combined with x²+y²=1 and y≠1: if x=0 then y²=1 and y≠1 so y=-1; if y=0 then x²=1 so x=±1. Use constructor, then for each direction unfold and use field_simp, nlinarith, or split cases on the disjunction.
-/
theorem lens_fixed_points (x y : ℝ) :
    isLensFixedPoint x y ↔
      (x = 1 ∧ y = 0) ∨ (x = -1 ∧ y = 0) ∨ (x = 0 ∧ y = -1) := by
        grind +locals

end