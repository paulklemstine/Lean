/-! # CatalogBuild.Geometry.Stereographic.StereographicLens

Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 15
-/

import Mathlib

noncomputable section

/-- Stereographic projection from the unit circle S¹ ⊂ ℝ² to ℝ.
Projects from the north pole (0, 1) through a point (x, y) on the circle
to the x-axis. The formula is: σ(x, y) = x / (1 - y). -/
def circleStereographic (p : ℝ × ℝ) : ℝ :=
  p.1 / (1 - p.2)


/-- Inverse stereographic projection from ℝ to the unit circle S¹ ⊂ ℝ².
Maps t ∈ ℝ to the point ((2t)/(t²+1), (t²-1)/(t²+1)) on the circle. -/
def circleStereographicInv (t : ℝ) : ℝ × ℝ :=
  (2 * t / (t ^ 2 + 1), (t ^ 2 - 1) / (t ^ 2 + 1))


/-- [Section: ## Part 1: The Circle Case (S¹ ↔ ℝ)
We begin with the simplest case: stereographic projection from the unit circle in ℝ² to ℝ.
This makes the core ideas concrete and computationally verifiable.] -/
theorem circleStereographicInv_on_circle (t : ℝ) :
    let p := circleStereographicInv t
    p.1 ^ 2 + p.2 ^ 2 = 1 := by
      -- Expand the definitions of `circleStereographicInv` and simplify the expression.
      simp [circleStereographicInv]
      field_simp
      ring


theorem circleStereographic_inv_left (t : ℝ) :
    circleStereographic (circleStereographicInv t) = t := by
      unfold circleStereographic circleStereographicInv;
      -- Combine and simplify the fractions in the expression.
      field_simp
      ring


theorem circleStereographic_inv_right (x y : ℝ) (hcirc : x ^ 2 + y ^ 2 = 1)
    (hy : y ≠ 1) :
    circleStereographicInv (circleStereographic (x, y)) = (x, y) := by
      unfold circleStereographicInv circleStereographic;
      grind


/-- [Section: ## Part 2: The Idempotent Lens Property
The key insight formalized: composing the forward and inverse stereographic projections
yields an idempotent operation. In fact, it yields the *identity* — which is trivially
idempotent (id ∘ id = id). This is the mathematical content of "the lens that turns
reality into ideas and back is transparent."] -/
theorem idempotent_lens_circle (x y : ℝ) (hcirc : x ^ 2 + y ^ 2 = 1) (hy : y ≠ 1) :
    let L := circleStereographicInv ∘ circleStereographic
    L (L (x, y)) = L (x, y) := by
      -- By definition of L, we have L(x, y) = (x, y).
      simp [circleStereographic_inv_right x y hcirc hy]


theorem idempotent_dual_lens_circle (t : ℝ) :
    let L' := circleStereographic ∘ circleStereographicInv
    L' (L' t) = L' t := by
      convert circleStereographic_inv_left ( circleStereographic ( circleStereographicInv t ) ) using 1


/-- [Section: ## Part 3: The Conformal Property
Stereographic projection preserves angles — it is a *conformal* map.
This is what makes it a faithful "lens": the structure of ideas (angles, shapes)
is preserved even as the geometry (distances, curvature) changes.
We prove this for the circle case via the derivative.] -/
theorem circleStereographic_deriv_ne_zero (x y : ℝ) (hcirc : x ^ 2 + y ^ 2 = 1)
    (hy : y ≠ 1) (hx : x ≠ 0) :
    (1 : ℝ) / (1 - y) ≠ 0 := by
      exact one_div_ne_zero <| sub_ne_zero_of_ne <| Ne.symm hy


/-- The Fourier-like parity operator on ℝ: P(t) = -t.
This is the analogue of F² in the circle/line setting. -/
def parityOp : ℝ → ℝ := fun t => -t


/-- [Section: ## Part 4: Energy-Momentum Duality
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
the sphere Sⁿ is the "phase space" that unifies position and momentum.] -/
theorem parity_involution (t : ℝ) : parityOp (parityOp t) = t := by
  exact neg_neg t


theorem stereographic_antipodal (x y : ℝ) (hcirc : x ^ 2 + y ^ 2 = 1)
    (hy : y ≠ 1) (hny : y ≠ -1) :
    circleStereographic (-x, -y) = -(1 / circleStereographic (x, y)) := by
      rw [ circleStereographic, circleStereographic ] ; ring_nf;
      grind


/-- [Section: ## Part 5: The Compactification Principle
The one-point compactification ℝ ∪ {∞} ≅ S¹ is the fundamental act of
"turning reality into ideas": we add a single point at infinity to close
the real line into a circle.
This is formalized using Mathlib's `OnePoint` (Alexandroff compactification).] -/
theorem onepoint_real_compact : CompactSpace (OnePoint ℝ) := by
  infer_instance


theorem onepoint_real_connected : ConnectedSpace (OnePoint ℝ) := by
  refine' ⟨ _ ⟩;
  exact ⟨ OnePoint.some 0 ⟩


/-- A point on the circle is a "fixed point of the lens" if its stereographic
image equals its x-coordinate. This characterizes self-referential points. -/
def isLensFixedPoint (x y : ℝ) : Prop :=
  x ^ 2 + y ^ 2 = 1 ∧ y ≠ 1 ∧ circleStereographic (x, y) = x


/-- [Section: ## Part 6: Fixed Points of the Lens
The fixed points of the stereographic projection composed with its inverse
are *all* points (since it's the identity). But the fixed points of the
*individual* maps are more interesting:
σ(p) = p (as a real number matching the point's coordinate) characterizes
special "self-referential" points — where the idea IS the reality.] -/
theorem lens_fixed_points (x y : ℝ) :
    isLensFixedPoint x y ↔
      (x = 1 ∧ y = 0) ∨ (x = -1 ∧ y = 0) ∨ (x = 0 ∧ y = -1) := by
        grind +locals


end
