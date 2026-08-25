/-
# Existence of slicing frames and extremal sections of unimodular ellipsoids

All the central-section results of `Bridges.EllipsoidCentralSections` and
`Bridges.EllipsoidSlicingBounds` are stated for a *given* orthonormal parametrization `ι`
of the hyperplane `u^⊥`, i.e. a matrix with `ιᵀ ι = 1` and `ι ιᵀ = 1 - u uᵀ`.  This file
shows that such a frame always exists, which makes those results unconditional, and then
uses the eigenvalue product identity `∏ λᵢ = det A` to locate directions in which the
section of a unimodular ellipsoid is at least, respectively at most, as large as the
section of the unit ball.

Main results:

* `exists_orthonormal_frame`      : every unit vector `u` admits an orthonormal frame of
  `u^⊥`;
* `exists_volume_centralSection`  : hence the section formula holds unconditionally;
* `exists_eigenvalue_le_one_of_det_eq_one`, `exists_one_le_eigenvalue_of_det_eq_one` :
  a unimodular positive definite matrix has an eigenvalue `≤ 1` and one `≥ 1`;
* `exists_centralSection_ge_ball`, `exists_centralSection_le_ball` : **extremal sections of
  a unimodular ellipsoid** — there is a direction whose central section is at least as
  large as the unit `(n-1)`-ball, and one whose central section is at most that large.
-/
import Bridges.EllipsoidIntersectionBody

namespace Catalog.Bridges.Ellipsoid

open Matrix MeasureTheory Metric Set

noncomputable section

variable {n m : ℕ}

/-! ## Inner products and dot products -/

lemma real_inner_eq_dotProduct (x y : EuclideanSpace ℝ (Fin n)) :
    inner ℝ x y = x.ofLp ⬝ᵥ y.ofLp := by
  rw [PiLp.inner_apply]
  simp only [RCLike.inner_apply, conj_trivial, dotProduct]
  exact Finset.sum_congr rfl fun i _ => mul_comm _ _

/-! ## Existence of an orthonormal frame of a hyperplane -/

/-- **Existence of slicing frames.** Every unit vector `u` in `ℝ^{m+1}` is the normal of a
hyperplane admitting an orthonormal parametrization `ι : ℝ^m → ℝ^{m+1}`, characterized by
`ιᵀ ι = 1` and `ι ιᵀ = 1 - u uᵀ`. -/
theorem exists_orthonormal_frame (u : Fin (m + 1) → ℝ) (hu : u ⬝ᵥ u = 1) :
    ∃ ι : Matrix (Fin (m + 1)) (Fin m) ℝ,
      ιᵀ * ι = 1 ∧ ι * ιᵀ = 1 - vecMulVec u u := by
  set U : EuclideanSpace ℝ (Fin (m + 1)) := WithLp.toLp 2 u with hU
  have hUnorm : ‖U‖ = 1 := by
    rw [← eucNorm_eq_norm, eucNorm, hu, Real.sqrt_one]
  -- extend `u` to an orthonormal basis whose last vector is `u`
  have horth : Orthonormal ℝ (Set.restrict {Fin.last m} (fun _ : Fin (m + 1) => U)) := by
    constructor
    · intro i; simpa using hUnorm
    · intro i j hij
      exact absurd (Subtype.ext (i.2.trans j.2.symm)) hij
  obtain ⟨b, hb⟩ :=
    horth.exists_orthonormalBasis_extension_of_card_eq
      (by simp [finrank_euclideanSpace])
  have hblast : b (Fin.last m) = U := hb _ rfl
  set M : Matrix (Fin (m + 1)) (Fin (m + 1)) ℝ :=
    Matrix.of (fun i j => (b j).ofLp i) with hM
  have hMTM : Mᵀ * M = 1 := by
    ext j k
    have hjk : (Mᵀ * M) j k = inner ℝ (b j) (b k) := by
      rw [real_inner_eq_dotProduct]
      simp [hM, Matrix.mul_apply, dotProduct]
    rw [hjk, orthonormal_iff_ite.mp b.orthonormal j k, Matrix.one_apply]
  have hMMT : M * Mᵀ = 1 := mul_eq_one_comm.mp hMTM
  have hMlast : ∀ i, M i (Fin.last m) = u i := by
    intro i
    simp [hM, hblast, hU]
  refine ⟨M.submatrix id Fin.castSucc, ?_, ?_⟩
  · ext j k
    have h1 : ((M.submatrix id Fin.castSucc)ᵀ * (M.submatrix id Fin.castSucc)) j k
        = (Mᵀ * M) (Fin.castSucc j) (Fin.castSucc k) := by
      simp [Matrix.mul_apply, Matrix.transpose_apply]
    rw [h1, hMTM, Matrix.one_apply, Matrix.one_apply]
    simp [Fin.castSucc_inj]
  · ext i k
    have h1 : ((M.submatrix id Fin.castSucc) * (M.submatrix id Fin.castSucc)ᵀ) i k
        = ∑ j : Fin m, M i (Fin.castSucc j) * M k (Fin.castSucc j) := by
      simp [Matrix.mul_apply, Matrix.transpose_apply]
    have h2 : (M * Mᵀ) i k = ∑ j : Fin (m + 1), M i j * M k j := by
      simp [Matrix.mul_apply, Matrix.transpose_apply]
    have h3 : ∑ j : Fin (m + 1), M i j * M k j
        = (∑ j : Fin m, M i (Fin.castSucc j) * M k (Fin.castSucc j)) + u i * u k := by
      rw [Fin.sum_univ_castSucc, hMlast, hMlast]
    rw [h1]
    have h4 : (1 : Matrix (Fin (m + 1)) (Fin (m + 1)) ℝ) i k
        = (∑ j : Fin m, M i (Fin.castSucc j) * M k (Fin.castSucc j)) + u i * u k := by
      rw [← hMMT, h2, h3]
    have h5 : (∑ j : Fin m, M i (Fin.castSucc j) * M k (Fin.castSucc j))
        = (1 : Matrix (Fin (m + 1)) (Fin (m + 1)) ℝ) i k - u i * u k := by
      linarith [h4]
    rw [h5]
    simp [Matrix.sub_apply, Matrix.vecMulVec_apply]

/-- **Unconditional central-section formula.** For every invertible `A` and every unit
direction `u` there is an orthonormal frame of `u^⊥` whose section has volume
`(|det A| / ‖Aᵀ u‖) · vol(B^{n-1})`. -/
theorem exists_volume_centralSection {A : Matrix (Fin (m + 1)) (Fin (m + 1)) ℝ}
    (hA : IsUnit A.det) {u : Fin (m + 1) → ℝ} (hu : u ⬝ᵥ u = 1) :
    ∃ ι : Matrix (Fin (m + 1)) (Fin m) ℝ, ιᵀ * ι = 1 ∧ ι * ιᵀ = 1 - vecMulVec u u ∧
      volume (centralSection A ι) =
        ENNReal.ofReal (|A.det| / eucNorm (Aᵀ *ᵥ u)) *
          volume (closedBall (0 : EuclideanSpace ℝ (Fin m)) 1) := by
  obtain ⟨ι, hι, hι'⟩ := exists_orthonormal_frame u hu
  exact ⟨ι, hι, hι', volume_centralSection hA hu hι hι'⟩

/-! ## Eigenvalues of a unimodular positive definite matrix -/

lemma prod_eigenvalues {A : Matrix (Fin n) (Fin n) ℝ} (hA : A.IsHermitian) :
    ∏ i, hA.eigenvalues i = A.det := by
  simpa using hA.det_eq_prod_eigenvalues.symm

/-- A unimodular positive definite matrix has an eigenvalue `≤ 1`. -/
theorem exists_eigenvalue_le_one_of_det_eq_one {A : Matrix (Fin (m + 1)) (Fin (m + 1)) ℝ}
    (hA : A.PosDef) (hdet : A.det = 1) : ∃ i, hA.isHermitian.eigenvalues i ≤ 1 := by
  by_contra h
  push_neg at h
  have hlt : (∏ _i : Fin (m + 1), (1 : ℝ)) < ∏ i, hA.isHermitian.eigenvalues i :=
    Finset.prod_lt_prod_of_nonempty (fun i _ => zero_lt_one)
      (fun i _ => h i) Finset.univ_nonempty
  rw [Finset.prod_const_one, prod_eigenvalues, hdet] at hlt
  exact lt_irrefl 1 hlt

/-- A unimodular positive definite matrix has an eigenvalue `≥ 1`. -/
theorem exists_one_le_eigenvalue_of_det_eq_one {A : Matrix (Fin (m + 1)) (Fin (m + 1)) ℝ}
    (hA : A.PosDef) (hdet : A.det = 1) : ∃ i, 1 ≤ hA.isHermitian.eigenvalues i := by
  by_contra h
  push_neg at h
  have hlt : (∏ i, hA.isHermitian.eigenvalues i) < ∏ _i : Fin (m + 1), (1 : ℝ) :=
    Finset.prod_lt_prod_of_nonempty (fun i _ => hA.eigenvalues_pos i)
      (fun i _ => h i) Finset.univ_nonempty
  rw [Finset.prod_const_one, prod_eigenvalues, hdet] at hlt
  exact lt_irrefl 1 hlt

/-! ## Extremal sections of a unimodular ellipsoid -/

/-- The normalized eigenvector of a Hermitian matrix is a unit vector for the dot
product. -/
lemma eigenvectorBasis_dotProduct_self {A : Matrix (Fin n) (Fin n) ℝ} (hA : A.IsHermitian)
    (i : Fin n) :
    (hA.eigenvectorBasis i).ofLp ⬝ᵥ (hA.eigenvectorBasis i).ofLp = 1 := by
  have h := hA.eigenvectorBasis.orthonormal.1 i
  rw [← norm_sq_eq_dotProduct, h, one_pow]

/-- **A unimodular ellipsoid has a central section at least as large as the unit ball
section.** The direction realizing it is an eigenvector for an eigenvalue `≤ 1`. -/
theorem exists_centralSection_ge_ball {A : Matrix (Fin (m + 1)) (Fin (m + 1)) ℝ}
    (hA : A.PosDef) (hdet : A.det = 1) :
    ∃ (u : Fin (m + 1) → ℝ) (ι : Matrix (Fin (m + 1)) (Fin m) ℝ),
      u ⬝ᵥ u = 1 ∧ ιᵀ * ι = 1 ∧ ι * ιᵀ = 1 - vecMulVec u u ∧
        volume (closedBall (0 : EuclideanSpace ℝ (Fin m)) 1) ≤
          volume (centralSection A ι) := by
  obtain ⟨i, hi⟩ := exists_eigenvalue_le_one_of_det_eq_one hA hdet
  set u : Fin (m + 1) → ℝ := (hA.isHermitian.eigenvectorBasis i).ofLp
  have hu : u ⬝ᵥ u = 1 := eigenvectorBasis_dotProduct_self hA.isHermitian i
  have hev : A *ᵥ u = hA.isHermitian.eigenvalues i • u :=
    hA.isHermitian.mulVec_eigenvectorBasis i
  obtain ⟨ι, hι, hι'⟩ := exists_orthonormal_frame u hu
  refine ⟨u, ι, hu, hι, hι', ?_⟩
  rw [volume_centralSection_of_eigenvector hA hu hι hι' (hA.eigenvalues_pos i) hev, hdet]
  have h1 : (1 : ENNReal) ≤ ENNReal.ofReal (1 / hA.isHermitian.eigenvalues i) := by
    rw [show (1 : ENNReal) = ENNReal.ofReal 1 by simp]
    exact ENNReal.ofReal_le_ofReal (by
      rw [le_div_iff₀ (hA.eigenvalues_pos i), one_mul]; exact hi)
  calc volume (closedBall (0 : EuclideanSpace ℝ (Fin m)) 1)
      = 1 * volume (closedBall (0 : EuclideanSpace ℝ (Fin m)) 1) := (one_mul _).symm
    _ ≤ ENNReal.ofReal (1 / hA.isHermitian.eigenvalues i) *
          volume (closedBall (0 : EuclideanSpace ℝ (Fin m)) 1) := by gcongr

/-- **A unimodular ellipsoid has a central section at most as large as the unit ball
section.** The direction realizing it is an eigenvector for an eigenvalue `≥ 1`. -/
theorem exists_centralSection_le_ball {A : Matrix (Fin (m + 1)) (Fin (m + 1)) ℝ}
    (hA : A.PosDef) (hdet : A.det = 1) :
    ∃ (u : Fin (m + 1) → ℝ) (ι : Matrix (Fin (m + 1)) (Fin m) ℝ),
      u ⬝ᵥ u = 1 ∧ ιᵀ * ι = 1 ∧ ι * ιᵀ = 1 - vecMulVec u u ∧
        volume (centralSection A ι) ≤
          volume (closedBall (0 : EuclideanSpace ℝ (Fin m)) 1) := by
  obtain ⟨i, hi⟩ := exists_one_le_eigenvalue_of_det_eq_one hA hdet
  set u : Fin (m + 1) → ℝ := (hA.isHermitian.eigenvectorBasis i).ofLp
  have hu : u ⬝ᵥ u = 1 := eigenvectorBasis_dotProduct_self hA.isHermitian i
  have hev : A *ᵥ u = hA.isHermitian.eigenvalues i • u :=
    hA.isHermitian.mulVec_eigenvectorBasis i
  obtain ⟨ι, hι, hι'⟩ := exists_orthonormal_frame u hu
  refine ⟨u, ι, hu, hι, hι', ?_⟩
  rw [volume_centralSection_of_eigenvector hA hu hι hι' (hA.eigenvalues_pos i) hev, hdet]
  have h1 : ENNReal.ofReal (1 / hA.isHermitian.eigenvalues i) ≤ (1 : ENNReal) := by
    rw [show (1 : ENNReal) = ENNReal.ofReal 1 by simp]
    exact ENNReal.ofReal_le_ofReal (by
      rw [div_le_iff₀ (hA.eigenvalues_pos i), one_mul]; exact hi)
  calc ENNReal.ofReal (1 / hA.isHermitian.eigenvalues i) *
        volume (closedBall (0 : EuclideanSpace ℝ (Fin m)) 1)
      ≤ 1 * volume (closedBall (0 : EuclideanSpace ℝ (Fin m)) 1) := by gcongr
    _ = volume (closedBall (0 : EuclideanSpace ℝ (Fin m)) 1) := one_mul _

end

end Catalog.Bridges.Ellipsoid