/-
# Polar duality, linear covariance and volume products

`Bridges.EllipsoidSlicingBounds` established that the polar body of an ellipsoid is again
an ellipsoid, `(E A)° = E ((Aᵀ)⁻¹)`, and that the Blaschke–Santaló product of an ellipsoid
with its polar is exactly `vol(B)²`.  This file develops the surrounding duality toolkit
and turns the ellipsoid identity into estimates for arbitrary bodies:

* `polarSet_antitone`, `polarSet_union`, `polarSet_closedBall_one` : the basic calculus of
  polar sets;
* `polarSet_image` : full linear covariance, `(A · s)° = (Aᵀ)⁻¹ · s°`, for any set `s` and
  any invertible `A`;
* `volume_mul_volume_polarSet_image` : the volume product is a linear invariant — the
  determinant factors cancel exactly;
* `polarSet_polarSet_ellipsoid` : the bipolar theorem for ellipsoids;
* `volume_mul_volume_polarSet_le` : if a body is squeezed between two ellipsoids, its
  volume product is bounded by the ratio of the two determinants times `vol(B)²`, a
  quantitative Santaló-type estimate for ellipsoidally approximable bodies.
-/
import Bridges.EllipsoidSlicingBounds

namespace Catalog.Bridges.Ellipsoid

open Matrix MeasureTheory Metric Set

noncomputable section

variable {n : ℕ}

/-! ## Basic calculus of polar sets -/

/-- Polarity reverses inclusions. -/
theorem polarSet_antitone {s t : Set (EuclideanSpace ℝ (Fin n))} (h : s ⊆ t) :
    polarSet t ⊆ polarSet s := fun _ hy x hx => hy x (h hx)

/-- The Euclidean unit ball is self-polar. -/
theorem polarSet_closedBall_one :
    polarSet (closedBall (0 : EuclideanSpace ℝ (Fin n)) 1)
      = closedBall (0 : EuclideanSpace ℝ (Fin n)) 1 := by
  ext y
  simp only [polarSet, Set.mem_setOf_eq, mem_closedBall, dist_zero_right]
  rw [← forall_inner_le_one_iff]

/-- Polarity turns unions into intersections. -/
theorem polarSet_union (s t : Set (EuclideanSpace ℝ (Fin n))) :
    polarSet (s ∪ t) = polarSet s ∩ polarSet t := by
  ext y
  simp only [polarSet, Set.mem_setOf_eq, Set.mem_inter_iff, Set.mem_union]
  exact ⟨fun h => ⟨fun x hx => h x (Or.inl hx), fun x hx => h x (Or.inr hx)⟩,
    fun h x hx => hx.elim (h.1 x) (h.2 x)⟩

/-! ## Linear covariance of polarity -/

/-- **Linear covariance.** The polar of a linear image is the image of the polar under the
inverse transpose. -/
theorem polarSet_image {A : Matrix (Fin n) (Fin n) ℝ} (hA : IsUnit A.det)
    (s : Set (EuclideanSpace ℝ (Fin n))) :
    polarSet (Matrix.toEuclideanLin A '' s) = Matrix.toEuclideanLin (Aᵀ)⁻¹ '' polarSet s := by
  have hAT : IsUnit (Aᵀ).det := by rwa [Matrix.det_transpose]
  ext y
  simp only [polarSet, Set.mem_setOf_eq, Set.mem_image]
  constructor
  · intro h
    refine ⟨Matrix.toEuclideanLin Aᵀ y, fun x hx => ?_, toEuclideanLin_inv_apply hAT y⟩
    rw [← inner_toEuclideanLin]
    exact h _ ⟨x, hx, rfl⟩
  · rintro ⟨z, hz, rfl⟩ x ⟨x', hx', rfl⟩
    rw [inner_toEuclideanLin, toEuclideanLin_apply_inv hAT]
    exact hz x' hx'

/-- **The volume product is a linear invariant.** Applying an invertible linear map
multiplies the volume of a set by `|det|` and the volume of its polar by `|det|⁻¹`, so the
product is unchanged. -/
theorem volume_mul_volume_polarSet_image {A : Matrix (Fin n) (Fin n) ℝ} (hA : IsUnit A.det)
    (s : Set (EuclideanSpace ℝ (Fin n))) :
    volume (Matrix.toEuclideanLin A '' s) * volume (polarSet (Matrix.toEuclideanLin A '' s))
      = volume s * volume (polarSet s) := by
  have hdetne : A.det ≠ 0 := by rwa [← isUnit_iff_ne_zero]
  rw [polarSet_image hA, Measure.addHaar_image_linearMap, Measure.addHaar_image_linearMap,
    det_toEuclideanLin, det_toEuclideanLin, Matrix.det_nonsing_inv, Matrix.det_transpose,
    Ring.inverse_eq_inv', abs_inv]
  rw [show ENNReal.ofReal |A.det| * volume s * (ENNReal.ofReal |A.det|⁻¹ * volume (polarSet s))
      = (ENNReal.ofReal |A.det| * ENNReal.ofReal |A.det|⁻¹) * (volume s * volume (polarSet s)) by
    ring]
  rw [← ENNReal.ofReal_mul (abs_nonneg _), mul_inv_cancel₀ (abs_ne_zero.2 hdetne)]
  simp

/-! ## Bipolar theorem and volume of a polar ellipsoid -/

/-- **Bipolar theorem for ellipsoids.** An ellipsoid is its own bipolar. -/
theorem polarSet_polarSet_ellipsoid {A : Matrix (Fin n) (Fin n) ℝ} (hA : IsUnit A.det) :
    polarSet (polarSet (ellipsoid A)) = ellipsoid A := by
  have hAT : IsUnit (Aᵀ).det := by rwa [Matrix.det_transpose]
  have hinv : IsUnit ((Aᵀ)⁻¹).det := by
    rw [Matrix.det_nonsing_inv, Ring.inverse_eq_inv', isUnit_iff_ne_zero, ne_eq, inv_eq_zero,
      ← ne_eq, ← isUnit_iff_ne_zero]
    exact hAT
  rw [polarSet_ellipsoid hA, polarSet_ellipsoid hinv, Matrix.transpose_nonsing_inv,
    Matrix.nonsing_inv_nonsing_inv _ (by rwa [Matrix.det_transpose] at hAT),
    Matrix.transpose_transpose]

/-- The volume of the polar of an ellipsoid is `|det A|⁻¹` times the volume of the ball. -/
theorem volume_polarSet_ellipsoid {A : Matrix (Fin n) (Fin n) ℝ} (hA : IsUnit A.det) :
    volume (polarSet (ellipsoid A)) =
      ENNReal.ofReal |A.det|⁻¹ * volume (closedBall (0 : EuclideanSpace ℝ (Fin n)) 1) := by
  rw [polarSet_ellipsoid hA, volume_ellipsoid, Matrix.det_nonsing_inv, Matrix.det_transpose,
    Ring.inverse_eq_inv', abs_inv]

/-! ## A Santaló-type estimate for ellipsoidally approximable bodies -/

/-- **Volume product of a body squeezed between two ellipsoids.** If `E A ⊆ s ⊆ E B` then
the volume product of `s` is at most `(|det B| / |det A|) · vol(B_n)²`.  Taking `A = B`
recovers the exact Blaschke–Santaló equality for ellipsoids. -/
theorem volume_mul_volume_polarSet_le {A B : Matrix (Fin n) (Fin n) ℝ}
    {s : Set (EuclideanSpace ℝ (Fin n))} (hA : IsUnit A.det)
    (h1 : ellipsoid A ⊆ s) (h2 : s ⊆ ellipsoid B) :
    volume s * volume (polarSet s) ≤
      ENNReal.ofReal (|B.det| * |A.det|⁻¹) *
        volume (closedBall (0 : EuclideanSpace ℝ (Fin n)) 1) ^ 2 := by
  have hs : volume s ≤ ENNReal.ofReal |B.det| *
      volume (closedBall (0 : EuclideanSpace ℝ (Fin n)) 1) := by
    rw [← volume_ellipsoid]; exact measure_mono h2
  have hp : volume (polarSet s) ≤ ENNReal.ofReal |A.det|⁻¹ *
      volume (closedBall (0 : EuclideanSpace ℝ (Fin n)) 1) := by
    rw [← volume_polarSet_ellipsoid hA]; exact measure_mono (polarSet_antitone h1)
  calc volume s * volume (polarSet s)
      ≤ (ENNReal.ofReal |B.det| * volume (closedBall (0 : EuclideanSpace ℝ (Fin n)) 1)) *
          (ENNReal.ofReal |A.det|⁻¹ *
            volume (closedBall (0 : EuclideanSpace ℝ (Fin n)) 1)) := mul_le_mul' hs hp
    _ = ENNReal.ofReal (|B.det| * |A.det|⁻¹) *
          volume (closedBall (0 : EuclideanSpace ℝ (Fin n)) 1) ^ 2 := by
        rw [ENNReal.ofReal_mul (abs_nonneg _)]; ring

end

end Catalog.Bridges.Ellipsoid