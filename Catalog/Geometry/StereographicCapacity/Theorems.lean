import Mathlib

/-!
# Stereographic Capacity Theory: the algebraic & order-theoretic backbone

This file develops the *group-theoretic* and *order-theoretic* backbone behind the
inverse stereographic projection studied in
`Catalog/Geometry/InverseStereoResearch.lean`.

The chart `invStereo t = (2t/(1+t²), (1-t²)/(1+t²))` parametrizes the unit circle by a
single real coordinate `t` (the tangent of the half-angle).  The central discovery of
this cycle is that the seemingly geometric operation "rotate a point of `S¹`" becomes,
in the stereographic coordinate, a single rational binary operation

    stereoAdd t s = (t + s) / (1 - t·s)

— the *tangent half-angle addition law*, a.k.a. the formal group law of `arctan`.  We
prove that this operation:

* turns rotation into an explicit algebraic identity (`stereo_addition_law`);
* is realized by honest `2×2` real matrix multiplication (`stereoRot_mul`), connecting
  to the Gaussian/rotation matrices of the catalog (`gaussian_matrix_compose`,
  `gaussian_det_multiplicative`);
* is associative (`stereoAdd_assoc`) and commutative (`stereoAdd_comm`) with identity `0`
  (`stereoAdd_zero`) — i.e. a *partial abelian group* on `ℝ`;
* is intertwined with ordinary angle addition by the order embedding
  `stereoAngle t = 2·arctan t` (`stereoAngle_stereoAdd`, `stereoAngle_strictMono`).

We then isolate the *capacity* coordinate `2t/(1+t²)` and prove its extremal
characterization (`stereo_capacity_le_one`, `stereo_capacity_eq_one_iff`): the circle's
horizontal extent is maximized exactly at `t = 1`, the `(3,4,5)`-adjacent point.

## Catalog synthesis

* Extends `inv_stereo_on_circle`, `inv_stereo_injective`, `stereo_critical_line` from
  `InverseStereoResearch.lean` from *pointwise* facts to a *group law*.
* `stereoRot_mul` is the real-analytic shadow of `gaussian_matrix_compose` and
  `gaussian_det_multiplicative`: rotation composition = norm-`1` complex multiplication.
* `stereoAngle_strictMono` supplies the order-theoretic backbone hinted at by the
  `StereographicSheaf` transition theory.
-/

noncomputable section

open Real

/-- Inverse stereographic projection of the line onto the unit circle `S¹`,
parametrized by the tangent of the half-angle. -/
noncomputable def invStereo (t : ℝ) : ℝ × ℝ := (2 * t / (1 + t ^ 2), (1 - t ^ 2) / (1 + t ^ 2))

/-- The **stereographic addition law** `(t + s)/(1 - t·s)`: the tangent half-angle
addition formula, i.e. the partial group law that linearizes circle rotation. -/
noncomputable def stereoAdd (t s : ℝ) : ℝ := (t + s) / (1 - t * s)

/-- The **stereographic angle** `2·arctan t`: the order embedding of the stereographic
coordinate into the open arc `(-π, π)`. -/
noncomputable def stereoAngle (t : ℝ) : ℝ := 2 * Real.arctan t

/-- The `2×2` rotation matrix attached to a stereographic coordinate, with columns the
stereographic point and its quarter-turn. -/
noncomputable def stereoRot (t : ℝ) : Matrix (Fin 2) (Fin 2) ℝ :=
  !![(invStereo t).2, -(invStereo t).1; (invStereo t).1, (invStereo t).2]

/-- Sanity lemma: the chart lands on the unit circle (re-established locally). -/
theorem invStereo_on_circle (t : ℝ) : (invStereo t).1 ^ 2 + (invStereo t).2 ^ 2 = 1 := by
  have h : (1 : ℝ) + t ^ 2 ≠ 0 := by positivity
  simp only [invStereo]
  field_simp
  ring

-- !-- comment -- !--
-- stereo_addition_law: unfold invStereo/stereoAdd; the common denominator
-- (1-ts)² + (t+s)² collapses to (1+t²)(1+s²), so field_simp + ring closes both
-- coordinates. This is the sin/cos angle-addition law written rationally.
-- !-- comment -- !--

-- !-- Lab Notebook: stereo_addition_law -- !--
-- !-- Hypothesis: Circle rotation, opaque in (x,y) coordinates, should become a single
--     rational identity in the stereographic coordinate t = tan(θ/2). -- !--
-- !-- Result: Proved. invStereo(stereoAdd t s) equals the rotation of invStereo t by the
--     angle of s, expressed as (x₁y₂+y₁x₂, y₁y₂-x₁x₂) — exactly sin/cos addition. -- !--
-- !-- Insight: The denominator (1-ts)²+(t+s)² factors as (1+t²)(1+s²); this single
--     algebraic miracle is *why* the half-angle substitution rationalizes trigonometry. -- !--
-- !-- Failure analysis: A coordinate-free `Prod.ext` attempt stalled; splitting into the
--     two scalar coordinates and clearing all three denominators at once was decisive. -- !--
-- !-- End Lab Notebook -- !--

/-- **Main theorem (algebraic backbone).** In stereographic coordinates, rotation is the
rational addition law: `invStereo (stereoAdd t s)` is the rotation of `invStereo t` by the
angle of `s`, i.e. the sine/cosine angle-addition formula written rationally. -/
theorem stereo_addition_law (t s : ℝ) (h : 1 - t * s ≠ 0) :
    invStereo (stereoAdd t s) =
      ((invStereo t).1 * (invStereo s).2 + (invStereo t).2 * (invStereo s).1,
       (invStereo t).2 * (invStereo s).2 - (invStereo t).1 * (invStereo s).1) := by
  have h1 : (1 : ℝ) + t ^ 2 ≠ 0 := by positivity
  have h2 : (1 : ℝ) + s ^ 2 ≠ 0 := by positivity
  simp only [invStereo, stereoAdd, Prod.mk.injEq]
  constructor <;> field_simp <;> ring

-- !-- comment -- !--
-- stereoRot_mul: expand the 2×2 product entrywise (Fin.sum_univ_two), then each entry is
-- the same rational identity as stereo_addition_law; field_simp + ring per entry.
-- !-- comment -- !--

-- !-- Lab Notebook: stereoRot_mul -- !--
-- !-- Hypothesis: The addition law should be matrix multiplication of honest rotation
--     matrices, mirroring the catalog's gaussian_matrix_compose over ℤ. -- !--
-- !-- Result: Proved. stereoRot t * stereoRot s = stereoRot (stereoAdd t s). -- !--
-- !-- Insight: This is the real-analytic image of complex multiplication of unit-modulus
--     numbers; det stereoRot = x²+y² = 1 ties it to gaussian_det_multiplicative. -- !--
-- !-- Failure analysis: None substantive; the entrywise field_simp;ring pattern that
--     proved stereo_addition_law transferred directly to the matrix entries. -- !--
-- !-- End Lab Notebook -- !--

/-- **Matrix form (cross-domain bridge).** The stereographic addition law is realized by
multiplication of `2×2` rotation matrices, the real-analytic shadow of the catalog's
`gaussian_matrix_compose` / `gaussian_det_multiplicative`. -/
theorem stereoRot_mul (t s : ℝ) (h : 1 - t * s ≠ 0) :
    stereoRot t * stereoRot s = stereoRot (stereoAdd t s) := by
  have h1 : (1 : ℝ) + t ^ 2 ≠ 0 := by positivity
  have h2 : (1 : ℝ) + s ^ 2 ≠ 0 := by positivity
  simp only [stereoRot, invStereo, stereoAdd]
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [Matrix.mul_apply, Fin.sum_univ_two] <;> field_simp <;> ring

/-- The stereographic rotation matrix lies in `SO(2)`: its determinant is `1`. -/
theorem stereoRot_det_one (t : ℝ) : (stereoRot t).det = 1 := by
  have := invStereo_on_circle t
  simp only [stereoRot, Matrix.det_fin_two_of]
  nlinarith [this]

-- !-- comment -- !--
-- stereoAdd_assoc: clear denominators with field_simp using h1,h2 then ring_nf; the outer
-- non-vanishing hypotheses turn out unnecessary because the cleared identity is polynomial.
-- !-- comment -- !--

-- !-- Lab Notebook: stereoAdd_assoc -- !--
-- !-- Hypothesis: stereoAdd is associative (a true partial abelian group law). -- !--
-- !-- Result: Proved, and SURPRISINGLY needs only the two *inner* denominators nonzero;
--     the two outer non-vanishing conditions were redundant. -- !--
-- !-- Insight: After clearing the inner denominators the associativity identity is a
--     polynomial identity, so ring_nf alone finishes — a formal-group-law phenomenon. -- !--
-- !-- Failure analysis: An over-specified version with four hypotheses compiled but flagged
--     two as unused; we removed them, yielding a cleaner, more general statement. -- !--
-- !-- End Lab Notebook -- !--

/-- **Associativity of the stereographic addition law.** Together with `stereoAdd_comm`
and `stereoAdd_zero` this exhibits `(ℝ, stereoAdd)` as a *partial abelian group*. -/
theorem stereoAdd_assoc (t s u : ℝ) (h1 : 1 - t * s ≠ 0) (h2 : 1 - s * u ≠ 0) :
    stereoAdd (stereoAdd t s) u = stereoAdd t (stereoAdd s u) := by
  simp only [stereoAdd] at *
  field_simp
  ring_nf

/-- Commutativity of the stereographic addition law. -/
theorem stereoAdd_comm (t s : ℝ) : stereoAdd t s = stereoAdd s t := by
  simp only [stereoAdd]; rw [add_comm, mul_comm]

/-- `0` is the identity of the stereographic addition law. -/
theorem stereoAdd_zero (t : ℝ) : stereoAdd t 0 = t := by
  simp [stereoAdd]

-- !-- comment -- !--
-- stereoAngle_stereoAdd: stereoAngle = 2·arctan, and Real.arctan_add (valid when t·s<1)
-- says arctan t + arctan s = arctan((t+s)/(1-ts)); scale by 2 and finish with linarith.
-- !-- comment -- !--

-- !-- Lab Notebook: stereoAngle_stereoAdd -- !--
-- !-- Hypothesis: The order embedding 2·arctan should turn stereoAdd into ordinary +. -- !--
-- !-- Result: Proved for t·s < 1 via Real.arctan_add. -- !--
-- !-- Insight: stereoAngle is a (partial) group isomorphism (ℝ,stereoAdd) → ((-π,π),+);
--     the constraint t·s<1 is exactly the branch where no ±π wraparound occurs. -- !--
-- !-- Failure analysis: A direct `rw [arctan_add]` missed the pattern because of the
--     leading factor 2; passing the equation to linarith sidestepped the rewrite. -- !--
-- !-- End Lab Notebook -- !--

/-- **Order/analysis backbone.** The angle embedding intertwines `stereoAdd` with ordinary
addition on the branch `t·s < 1`: `stereoAngle` is a partial group homomorphism. -/
theorem stereoAngle_stereoAdd (t s : ℝ) (h : t * s < 1) :
    stereoAngle (stereoAdd t s) = stereoAngle t + stereoAngle s := by
  simp only [stereoAngle, stereoAdd]
  have := Real.arctan_add h
  linarith

-- !-- Lab Notebook: stereoAngle_strictMono -- !--
-- !-- Hypothesis: stereoAngle is a strictly monotone order embedding of ℝ into (-π,π). -- !--
-- !-- Result: Proved from Real.arctan_strictMono. -- !--
-- !-- Insight: This is the order-theoretic backbone: the stereographic coordinate is an
--     order-isomorphism onto an arc, so all order facts about the circle pull back. -- !--
-- !-- Failure analysis: None; one application of the Mathlib monotonicity lemma. -- !--
-- !-- End Lab Notebook -- !--

/-- **Order-theoretic backbone.** The stereographic angle is strictly monotone, hence an
order embedding of `ℝ` into the arc `(-π, π)`. -/
theorem stereoAngle_strictMono : StrictMono stereoAngle := by
  intro a b hab
  simp only [stereoAngle]
  have := Real.arctan_strictMono hab
  linarith

-- !-- comment -- !--
-- stereo_capacity_le_one / _eq_one_iff: 2t/(1+t²) ≤ 1 ⟺ 0 ≤ (t-1)², with equality iff
-- t = 1. Clear the positive denominator and apply the perfect-square (AM-GM) bound.
-- !-- comment -- !--

-- !-- Lab Notebook: stereo_capacity_eq_one_iff -- !--
-- !-- Hypothesis: The horizontal "capacity" 2t/(1+t²) of the chart is ≤ 1 with a unique
--     maximizer. -- !--
-- !-- Result: Proved bound and the equality characterization t = 1. -- !--
-- !-- Insight: The maximizer t = 1 is precisely the half-angle whose chart image (1,0) is
--     the east point; the bound is the AM-GM inequality 2t ≤ 1 + t² in disguise. -- !--
-- !-- Failure analysis: None; nlinarith with the hint sq_nonneg (t-1) is immediate. -- !--
-- !-- End Lab Notebook -- !--

/-- **Capacity bound (extremal).** The horizontal capacity of the stereographic chart is
at most `1`. -/
theorem stereo_capacity_le_one (t : ℝ) : 2 * t / (1 + t ^ 2) ≤ 1 := by
  have h1 : (0 : ℝ) < 1 + t ^ 2 := by positivity
  rw [div_le_one h1]
  nlinarith [sq_nonneg (t - 1)]

/-- **Extremal characterization.** The capacity attains its maximum `1` exactly at the
half-angle `t = 1` (the east point `(1,0)`). -/
theorem stereo_capacity_eq_one_iff (t : ℝ) : 2 * t / (1 + t ^ 2) = 1 ↔ t = 1 := by
  have h1 : (1 : ℝ) + t ^ 2 ≠ 0 := by positivity
  rw [div_eq_one_iff_eq h1]
  constructor
  · intro hh; nlinarith [sq_nonneg (t - 1)]
  · intro hh; rw [hh]; ring

/-! ## Generalization frontier (convexity backbone)

The best theorem of this cycle is `stereo_addition_law` / its matrix form `stereoRot_mul`.
A natural generalization (Step 7) is to ask which *concavity / order* structure the angle
embedding carries.  We upgrade the order backbone to a convexity backbone. -/

-- !-- comment -- !--
-- stereoAngle_concaveOn_Ici: 2·arctan is concave on [0,∞) because its second derivative
-- -4t/(1+t²)² ≤ 0 there. Discharged via `concaveOn_of_deriv2_nonpos` on the convex set
-- `Set.Ici 0`, with continuity/differentiability of arctan and `positivity` on the sign.
-- !-- comment -- !--

-- !-- Lab Notebook: stereoAngle_concaveOn_Ici -- !--
-- !-- Hypothesis: stereoAngle is concave on [0,∞), upgrading the order backbone to a
--     convexity backbone (Jensen-type capacity inequalities for averaged coordinates). -- !--
-- !-- Result: Proved via the second-derivative criterion concaveOn_of_deriv2_nonpos. -- !--
-- !-- Insight: Concavity holds only on a half-line: 2·arctan has an inflection at 0, so the
--     global statement is FALSE (it is convex on (-∞,0]); the boundary t=0 is essential. -- !--
-- !-- Failure analysis: A global ConcaveOn over ℝ would fail at the inflection point t=0;
--     restricting to Set.Ici 0 (a convex set) is exactly what makes deriv2 ≤ 0 hold. -- !--
-- !-- End Lab Notebook -- !--

/-- **Convexity backbone.** The stereographic angle is concave on `[0, ∞)`, upgrading the
order backbone (`stereoAngle_strictMono`) to a convexity backbone that yields Jensen-type
capacity inequalities for averaged stereographic coordinates. (It is *not* concave on all
of `ℝ`: `t = 0` is an inflection point, so the half-line restriction is essential.) -/
theorem stereoAngle_concaveOn_Ici : ConcaveOn ℝ (Set.Ici (0 : ℝ)) stereoAngle := by
  apply_rules [ concaveOn_of_deriv2_nonpos, convex_Ici ];
  · exact Continuous.continuousOn ( by unfold stereoAngle; continuity );
  · exact Differentiable.differentiableOn ( by unfold stereoAngle; norm_num [ Real.differentiable_arctan ] );
  · unfold stereoAngle;
    norm_num [ mul_comm ];
    exact DifferentiableOn.mul ( DifferentiableOn.inv ( differentiableOn_const _ |> DifferentiableOn.add <| differentiableOn_pow 2 ) fun x hx => by positivity ) ( differentiableOn_const _ );
  · unfold stereoAngle; norm_num [ Real.differentiableAt_arctan ] ; ring_nf;
    exact fun x hx => by norm_num [ show 1 + x ^ 2 ≠ 0 by positivity ] ; ring_nf; norm_num; positivity;

end