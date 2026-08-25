/-
# Existence of a maximal-volume inscribed ellipsoid (the John ellipsoid)

Given a closed bounded set `K` in `EuclideanSpace ℝ (Fin n)` that contains at least one
nondegenerate ellipsoid, we show that among all ellipsoids `E A ⊆ K` there is one of
maximal volume.  Since `vol (E A) = |det A| · vol (B)` by `volume_ellipsoid`, maximizing
the volume is the same as maximizing `det A`, so the statement is a compactness argument
about the set of *inscribed generators*

  `inscribedGens K = {A | A is positive semidefinite and E A ⊆ K}`.

Main results:

* `isClosed_inscribedGens`   : the set of inscribed generators is closed;
* `isCompact_inscribedGens`  : it is compact when `K` is bounded;
* `exists_maxDet_inscribedGen`, `exists_maxVolume_inscribed_ellipsoid` : existence of a
  maximizer, which is automatically positive definite as soon as `K` contains one
  nondegenerate ellipsoid.

Degenerate (positive semidefinite, singular) generators are deliberately allowed in the
constraint set: they are exactly what makes it closed, and the maximizer is nevertheless
positive definite because its determinant is bounded below by that of the given
nondegenerate competitor.
-/
import Bridges.EllipsoidCentralSections

namespace Catalog.Bridges.Ellipsoid

open Matrix MeasureTheory Metric Set

noncomputable section

variable {n : ℕ}

/-! ## Coordinate estimates -/

/-- Each coordinate of a vector is dominated by its Euclidean norm. -/
lemma abs_le_eucNorm (v : Fin n → ℝ) (i : Fin n) : |v i| ≤ eucNorm v := by
  have hsq : v i ^ 2 ≤ eucNorm v ^ 2 := by
    rw [eucNorm_sq]
    have : ∀ j ∈ (Finset.univ : Finset (Fin n)), 0 ≤ v j * v j := fun j _ => mul_self_nonneg _
    simpa [dotProduct, sq] using
      Finset.single_le_sum (f := fun j => v j * v j) this (Finset.mem_univ i)
  have h := abs_nonneg (v i)
  nlinarith [eucNorm_nonneg v, sq_abs (v i)]

/-- The `j`-th standard basis vector, as a plain vector. -/
def stdUnit (j : Fin n) : Fin n → ℝ := Pi.single j 1

lemma eucNorm_stdUnit (j : Fin n) : eucNorm (stdUnit j) = 1 := by
  have : (stdUnit j) ⬝ᵥ (stdUnit j) = 1 := by
    simp [stdUnit, dotProduct, Pi.single_apply, Finset.sum_ite_eq']
  rw [eucNorm, this, Real.sqrt_one]

lemma mulVec_stdUnit (A : Matrix (Fin n) (Fin n) ℝ) (j : Fin n) :
    A *ᵥ stdUnit j = fun i => A i j := by
  funext i
  simp [stdUnit, Matrix.mulVec, dotProduct, Pi.single_apply, Finset.sum_ite_eq']

/-- Every column of a generator of an ellipsoid inscribed in a ball of radius `R` has
entries bounded by `R`. -/
lemma abs_entry_le_of_ellipsoid_subset {A : Matrix (Fin n) (Fin n) ℝ} {R : ℝ}
    (h : ellipsoid A ⊆ closedBall (0 : EuclideanSpace ℝ (Fin n)) R) (i j : Fin n) :
    |A i j| ≤ R := by
  have hmem : Matrix.toEuclideanLin A (WithLp.toLp 2 (stdUnit j)) ∈ ellipsoid A := by
    refine ⟨WithLp.toLp 2 (stdUnit j), ?_, rfl⟩
    simp only [mem_closedBall, dist_zero_right]
    rw [← eucNorm_eq_norm, eucNorm_stdUnit]
  have hR := h hmem
  simp only [mem_closedBall, dist_zero_right] at hR
  have hnorm : ‖Matrix.toEuclideanLin A (WithLp.toLp 2 (stdUnit j))‖ = eucNorm (A *ᵥ stdUnit j) := by
    rw [eucNorm_eq_norm]
    congr 1
  rw [hnorm, mulVec_stdUnit] at hR
  exact le_trans (abs_le_eucNorm (fun i => A i j) i) hR

/-! ## The set of inscribed generators -/

/-- Positive semidefinite generators whose ellipsoid is contained in `K`. -/
def inscribedGens (K : Set (EuclideanSpace ℝ (Fin n))) : Set (Matrix (Fin n) (Fin n) ℝ) :=
  {A | A.PosSemidef ∧ ellipsoid A ⊆ K}

lemma isClosed_posSemidef :
    IsClosed {A : Matrix (Fin n) (Fin n) ℝ | A.PosSemidef} := by
  have hset : {A : Matrix (Fin n) (Fin n) ℝ | A.PosSemidef}
      = {A : Matrix (Fin n) (Fin n) ℝ | Aᵀ = A} ∩
        ⋂ x : Fin n → ℝ, {A : Matrix (Fin n) (Fin n) ℝ | 0 ≤ x ⬝ᵥ (A *ᵥ x)} := by
    ext A
    simp only [Set.mem_setOf_eq, Set.mem_inter_iff, Set.mem_iInter]
    rw [Matrix.posSemidef_iff_dotProduct_mulVec]
    constructor
    · rintro ⟨h1, h2⟩
      refine ⟨?_, fun x => by simpa using h2 x⟩
      simpa [Matrix.IsHermitian, Matrix.conjTranspose_eq_transpose_of_trivial] using h1
    · rintro ⟨h1, h2⟩
      refine ⟨?_, fun x => by simpa using h2 x⟩
      simpa [Matrix.IsHermitian, Matrix.conjTranspose_eq_transpose_of_trivial] using h1
  rw [hset]
  refine IsClosed.inter ?_ (isClosed_iInter fun x => ?_)
  · exact isClosed_eq (continuous_id.matrix_transpose) continuous_id
  · exact isClosed_le continuous_const (continuous_const.dotProduct
      (continuous_id.matrix_mulVec continuous_const))

lemma isClosed_ellipsoid_subset {K : Set (EuclideanSpace ℝ (Fin n))} (hK : IsClosed K) :
    IsClosed {A : Matrix (Fin n) (Fin n) ℝ | ellipsoid A ⊆ K} := by
  have hset : {A : Matrix (Fin n) (Fin n) ℝ | ellipsoid A ⊆ K}
      = ⋂ y ∈ closedBall (0 : EuclideanSpace ℝ (Fin n)) 1,
          {A : Matrix (Fin n) (Fin n) ℝ | Matrix.toEuclideanLin A y ∈ K} := by
    ext A
    simp only [Set.mem_setOf_eq, Set.mem_iInter]
    constructor
    · intro h y hy
      exact h ⟨y, hy, rfl⟩
    · rintro h x ⟨y, hy, rfl⟩
      exact h y hy
  rw [hset]
  refine isClosed_biInter fun y _ => ?_
  refine IsClosed.preimage ?_ hK
  have hcont : Continuous fun A : Matrix (Fin n) (Fin n) ℝ =>
      (EuclideanSpace.equiv (Fin n) ℝ).symm (A *ᵥ (WithLp.ofLp y)) :=
    (EuclideanSpace.equiv (Fin n) ℝ).symm.continuous.comp
      (continuous_id.matrix_mulVec continuous_const)
  exact hcont

lemma isClosed_inscribedGens {K : Set (EuclideanSpace ℝ (Fin n))} (hK : IsClosed K) :
    IsClosed (inscribedGens K) :=
  isClosed_posSemidef.inter (isClosed_ellipsoid_subset hK)

/-- A box of matrices, i.e. the set of matrices all of whose entries lie in `[-R, R]`,
is compact. -/
lemma isCompact_matrix_box (R : ℝ) :
    IsCompact ((Set.univ.pi fun _ : Fin n => Set.univ.pi fun _ : Fin n => Icc (-R) R) :
      Set (Matrix (Fin n) (Fin n) ℝ)) :=
  isCompact_univ_pi fun _ => isCompact_univ_pi fun _ => isCompact_Icc

lemma isCompact_inscribedGens {K : Set (EuclideanSpace ℝ (Fin n))} (hK : IsClosed K) {R : ℝ}
    (hKR : K ⊆ closedBall (0 : EuclideanSpace ℝ (Fin n)) R) :
    IsCompact (inscribedGens K) := by
  refine (isCompact_matrix_box R).of_isClosed_subset (isClosed_inscribedGens hK) ?_
  rintro A ⟨-, hAK⟩ i - j -
  have h := abs_entry_le_of_ellipsoid_subset (hAK.trans hKR) i j
  exact ⟨neg_le_of_abs_le h, le_of_abs_le h⟩

/-! ## Existence of the maximizer -/

/-- **Existence of a determinant-maximizing inscribed generator.** If `K` is closed and
bounded and contains the ellipsoid of some positive definite `A₀`, then there is a positive
definite `A` with `E A ⊆ K` whose determinant dominates that of every inscribed
(possibly degenerate) generator. -/
theorem exists_maxDet_inscribedGen {K : Set (EuclideanSpace ℝ (Fin n))} (hK : IsClosed K) {R : ℝ}
    (hKR : K ⊆ closedBall (0 : EuclideanSpace ℝ (Fin n)) R)
    {A₀ : Matrix (Fin n) (Fin n) ℝ} (hA₀ : A₀.PosDef) (hA₀K : ellipsoid A₀ ⊆ K) :
    ∃ A : Matrix (Fin n) (Fin n) ℝ, A.PosDef ∧ ellipsoid A ⊆ K ∧
      ∀ B : Matrix (Fin n) (Fin n) ℝ, B.PosSemidef → ellipsoid B ⊆ K → B.det ≤ A.det := by
  have hne : (inscribedGens K).Nonempty := ⟨A₀, hA₀.posSemidef, hA₀K⟩
  have hcomp := isCompact_inscribedGens hK hKR
  obtain ⟨A, hA, hmax⟩ :=
    hcomp.exists_isMaxOn hne (Continuous.continuousOn (continuous_id.matrix_det))
  have hmax' : ∀ B : Matrix (Fin n) (Fin n) ℝ, B.PosSemidef → ellipsoid B ⊆ K → B.det ≤ A.det :=
    fun B hB hBK => hmax ⟨hB, hBK⟩
  have hdet : 0 < A.det := lt_of_lt_of_le hA₀.det_pos (hmax' A₀ hA₀.posSemidef hA₀K)
  refine ⟨A, ?_, hA.2, hmax'⟩
  refine (hA.1.posDef_iff_isUnit).mpr ?_
  rw [Matrix.isUnit_iff_isUnit_det]
  exact hdet.ne'.isUnit

/-- **Existence of a maximal-volume inscribed ellipsoid.** Under the same hypotheses, the
maximizer of the determinant maximizes the volume among all inscribed ellipsoids. -/
theorem exists_maxVolume_inscribed_ellipsoid {K : Set (EuclideanSpace ℝ (Fin n))}
    (hK : IsClosed K) {R : ℝ} (hKR : K ⊆ closedBall (0 : EuclideanSpace ℝ (Fin n)) R)
    {A₀ : Matrix (Fin n) (Fin n) ℝ} (hA₀ : A₀.PosDef) (hA₀K : ellipsoid A₀ ⊆ K) :
    ∃ A : Matrix (Fin n) (Fin n) ℝ, A.PosDef ∧ ellipsoid A ⊆ K ∧
      ∀ B : Matrix (Fin n) (Fin n) ℝ, B.PosSemidef → ellipsoid B ⊆ K →
        volume (ellipsoid B) ≤ volume (ellipsoid A) := by
  obtain ⟨A, hApd, hAK, hmax⟩ := exists_maxDet_inscribedGen hK hKR hA₀ hA₀K
  refine ⟨A, hApd, hAK, fun B hB hBK => ?_⟩
  rw [volume_ellipsoid, volume_ellipsoid]
  have hle : |B.det| ≤ |A.det| := by
    rw [abs_of_nonneg hB.det_nonneg, abs_of_pos hApd.det_pos]
    exact hmax B hB hBK
  gcongr

/-! ## A nondegenerate instance -/

/-- The ellipsoid of the identity matrix is the unit ball. -/
lemma ellipsoid_one : ellipsoid (1 : Matrix (Fin n) (Fin n) ℝ)
    = closedBall (0 : EuclideanSpace ℝ (Fin n)) 1 := by
  unfold ellipsoid
  have hid : ∀ y : EuclideanSpace ℝ (Fin n),
      Matrix.toEuclideanLin (1 : Matrix (Fin n) (Fin n) ℝ) y = y := by
    intro y
    simp
  rw [Set.image_congr' hid, Set.image_id']

/-- The hypotheses of `exists_maxVolume_inscribed_ellipsoid` are satisfiable: taking `K` to
be the unit ball, the maximal inscribed ellipsoid exists (and is the ball itself, since
`det ≤ 1` for every inscribed generator). -/
theorem exists_maxVolume_inscribed_ellipsoid_closedBall (n : ℕ) :
    ∃ A : Matrix (Fin n) (Fin n) ℝ, A.PosDef ∧
      ellipsoid A ⊆ closedBall (0 : EuclideanSpace ℝ (Fin n)) 1 ∧
      ∀ B : Matrix (Fin n) (Fin n) ℝ, B.PosSemidef →
        ellipsoid B ⊆ closedBall (0 : EuclideanSpace ℝ (Fin n)) 1 →
        volume (ellipsoid B) ≤ volume (ellipsoid A) := by
  refine exists_maxVolume_inscribed_ellipsoid isClosed_closedBall (subset_refl _)
    (Matrix.PosDef.one) ?_
  rw [ellipsoid_one]

end

end Catalog.Bridges.Ellipsoid