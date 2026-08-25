/-
# Uniqueness of the extremal slicing directions of an ellipsoid

`Bridges.EllipsoidSlicingBounds` proves the two-sided slicing bounds

  `det A / λmax ≤ vol_{n-1}(E A ∩ u^⊥) / vol(B^{n-1}) ≤ det A / λmin`

for a positive definite generator `A`, and shows that both bounds are attained in the
directions of the corresponding eigenvectors.  This file closes the converse — the
*equality case* — which was left as the first open direction of the previous cycle:

* `eucNorm_transpose_mulVec_eq_max_iff` : for a unit vector `u`, `‖Aᵀ u‖` equals an upper
  bound `hi` for the spectrum of `A` **iff** `u` is an eigenvector of `A` for the
  eigenvalue `hi`;
* `eucNorm_transpose_mulVec_eq_min_iff` : the same statement for a lower bound `lo`;
* `volume_centralSection_eq_max_iff`, `volume_centralSection_eq_min_iff` : consequently the
  central sections of extreme volume are **exactly** those orthogonal to an extreme
  eigenvector.

The analytic core is the equality case of a weighted average: writing `u` in an
orthonormal eigenbasis with coordinates `c`, one has `‖A u‖² = ∑ λᵢ² cᵢ²` and `∑ cᵢ² = 1`,
so `‖A u‖² = hi²` forces `cᵢ = 0` for every `i` with `λᵢ < hi`.
-/
import Bridges.EllipsoidSlicingBounds

namespace Catalog.Bridges.Ellipsoid

open Matrix MeasureTheory Metric Set

noncomputable section

variable {n m : ℕ}

/-! ## The equality case of a weighted average -/

/-- If a convex combination `∑ λᵢ² cᵢ²` of squares bounded by `hi²` attains the value
`hi²`, then every coordinate `cᵢ` with `λᵢ ≠ hi` vanishes; equivalently `λ` acts on `c`
as multiplication by `hi`. -/
lemma mul_eq_of_weighted_sq_eq_max {ι : Type*} [Fintype ι] {lam c : ι → ℝ} {hi : ℝ}
    (hc : ∑ i, c i ^ 2 = 1) (hpos : ∀ i, 0 < lam i) (hle : ∀ i, lam i ≤ hi)
    (hsum : ∑ i, lam i ^ 2 * c i ^ 2 = hi ^ 2) (i : ι) : lam i * c i = hi * c i := by
  have hnn : ∀ j ∈ (Finset.univ : Finset ι), 0 ≤ (hi ^ 2 - lam j ^ 2) * c j ^ 2 := by
    intro j _
    have h1 : lam j ^ 2 ≤ hi ^ 2 := by nlinarith [hpos j, hle j]
    have := sq_nonneg (c j)
    nlinarith
  have h1 : ∑ j, (hi ^ 2 - lam j ^ 2) * c j ^ 2 = 0 := by
    have e : ∀ j : ι, (hi ^ 2 - lam j ^ 2) * c j ^ 2
        = hi ^ 2 * c j ^ 2 - lam j ^ 2 * c j ^ 2 := fun j => by ring
    rw [Finset.sum_congr rfl fun j _ => e j, Finset.sum_sub_distrib, ← Finset.mul_sum, hc, hsum]
    ring
  have h2 := (Finset.sum_eq_zero_iff_of_nonneg hnn).mp h1 i (Finset.mem_univ i)
  rcases mul_eq_zero.mp h2 with h3 | h3
  · have h4 : lam i = hi := by nlinarith [hpos i, hle i]
    rw [h4]
  · have : c i = 0 := by nlinarith
    rw [this, mul_zero, mul_zero]

/-- The minimal counterpart of `mul_eq_of_weighted_sq_eq_max`. -/
lemma mul_eq_of_weighted_sq_eq_min {ι : Type*} [Fintype ι] {lam c : ι → ℝ} {lo : ℝ}
    (hc : ∑ i, c i ^ 2 = 1) (hlo : 0 ≤ lo) (hge : ∀ i, lo ≤ lam i)
    (hsum : ∑ i, lam i ^ 2 * c i ^ 2 = lo ^ 2) (i : ι) : lam i * c i = lo * c i := by
  have hnn : ∀ j ∈ (Finset.univ : Finset ι), 0 ≤ (lam j ^ 2 - lo ^ 2) * c j ^ 2 := by
    intro j _
    have h1 : lo ^ 2 ≤ lam j ^ 2 := by nlinarith [hge j]
    have := sq_nonneg (c j)
    nlinarith
  have h1 : ∑ j, (lam j ^ 2 - lo ^ 2) * c j ^ 2 = 0 := by
    have e : ∀ j : ι, (lam j ^ 2 - lo ^ 2) * c j ^ 2
        = lam j ^ 2 * c j ^ 2 - lo ^ 2 * c j ^ 2 := fun j => by ring
    rw [Finset.sum_congr rfl fun j _ => e j, Finset.sum_sub_distrib, ← Finset.mul_sum, hc, hsum]
    ring
  have h2 := (Finset.sum_eq_zero_iff_of_nonneg hnn).mp h1 i (Finset.mem_univ i)
  rcases mul_eq_zero.mp h2 with h3 | h3
  · have h4 : lam i = lo := by nlinarith [hge i]
    rw [h4]
  · have : c i = 0 := by nlinarith
    rw [this, mul_zero, mul_zero]

/-! ## Spectral coordinates -/

/-- An orthogonal matrix preserves the Euclidean norm of a plain vector. -/
lemma eucNorm_mulVec_orthogonal {U : Matrix (Fin n) (Fin n) ℝ} (hU : Uᵀ * U = 1)
    (v : Fin n → ℝ) : eucNorm (U *ᵥ v) = eucNorm v := by
  rw [eucNorm_mulVec_eq_norm, norm_toEuclideanLin_of_orthogonal hU, eucNorm_eq_norm]

/-- The squared Euclidean norm of a diagonal action, expanded as a weighted sum. -/
lemma eucNorm_diagonal_mulVec_sq (d c : Fin n → ℝ) :
    eucNorm (Matrix.diagonal d *ᵥ c) ^ 2 = ∑ i, d i ^ 2 * c i ^ 2 := by
  rw [eucNorm_sq]
  simp only [Matrix.mulVec_diagonal, dotProduct]
  exact Finset.sum_congr rfl fun i _ => by ring

section Spectral

variable {A : Matrix (Fin n) (Fin n) ℝ}

/-- The spectral coordinates of a vector: its components in the eigenbasis of `A`. -/
def specCoord (hA : A.PosDef) (u : Fin n → ℝ) : Fin n → ℝ :=
  (hA.isHermitian.eigenvectorUnitary : Matrix (Fin n) (Fin n) ℝ)ᵀ *ᵥ u

lemma sum_sq_specCoord (hA : A.PosDef) {u : Fin n → ℝ} (hu : u ⬝ᵥ u = 1) :
    ∑ i, specCoord hA u i ^ 2 = 1 := by
  have h : eucNorm (specCoord hA u) = eucNorm u := by
    refine eucNorm_mulVec_orthogonal ?_ u
    rw [Matrix.transpose_transpose]
    exact eigenvectorUnitary_mul_transpose hA
  have h2 : eucNorm (specCoord hA u) ^ 2 = eucNorm u ^ 2 := by rw [h]
  rw [eucNorm_sq, eucNorm_sq, hu] at h2
  simpa [dotProduct, sq] using h2

/-- `A u` in spectral coordinates: the eigenvalues act diagonally. -/
lemma mulVec_eq_spectral (hA : A.PosDef) (u : Fin n → ℝ) :
    A *ᵥ u = (hA.isHermitian.eigenvectorUnitary : Matrix (Fin n) (Fin n) ℝ) *ᵥ
      (Matrix.diagonal hA.isHermitian.eigenvalues *ᵥ specCoord hA u) := by
  conv_lhs => rw [posDef_eq_spectral hA]
  simp [specCoord, Matrix.mulVec_mulVec, Matrix.mul_assoc]

lemma eucNorm_mulVec_sq_eq_sum (hA : A.PosDef) (u : Fin n → ℝ) :
    eucNorm (A *ᵥ u) ^ 2 =
      ∑ i, hA.isHermitian.eigenvalues i ^ 2 * specCoord hA u i ^ 2 := by
  rw [mulVec_eq_spectral hA u,
    eucNorm_mulVec_orthogonal (transpose_mul_eigenvectorUnitary hA),
    eucNorm_diagonal_mulVec_sq]

/-- Recovering a vector from its spectral coordinates. -/
lemma eigenvectorUnitary_mulVec_specCoord (hA : A.PosDef) (u : Fin n → ℝ) :
    (hA.isHermitian.eigenvectorUnitary : Matrix (Fin n) (Fin n) ℝ) *ᵥ specCoord hA u = u := by
  rw [specCoord, Matrix.mulVec_mulVec, eigenvectorUnitary_mul_transpose hA, Matrix.one_mulVec]

/-! ## Equality case of the operator bounds -/

/-- **Rigidity of the upper operator bound.** If the spectrum of the positive definite
matrix `A` is bounded above by `hi` and a unit vector `u` satisfies `‖Aᵀ u‖ = hi`, then `u`
is an eigenvector of `A` for the eigenvalue `hi`. -/
theorem eigenvector_of_eucNorm_transpose_mulVec_eq_max (hA : A.PosDef) {u : Fin n → ℝ}
    (hu : u ⬝ᵥ u = 1) {hi : ℝ} (hhi : ∀ i, hA.isHermitian.eigenvalues i ≤ hi)
    (heq : eucNorm (Aᵀ *ᵥ u) = hi) : A *ᵥ u = hi • u := by
  have hAT : Aᵀ = A := by
    rw [← Matrix.conjTranspose_eq_transpose_of_trivial]; exact hA.isHermitian
  rw [hAT] at heq
  have hsum : ∑ i, hA.isHermitian.eigenvalues i ^ 2 * specCoord hA u i ^ 2 = hi ^ 2 := by
    rw [← eucNorm_mulVec_sq_eq_sum hA u, heq]
  have hdiag : Matrix.diagonal hA.isHermitian.eigenvalues *ᵥ specCoord hA u
      = hi • specCoord hA u := by
    funext i
    simpa [Matrix.mulVec_diagonal] using
      mul_eq_of_weighted_sq_eq_max (sum_sq_specCoord hA hu) hA.eigenvalues_pos hhi hsum i
  rw [mulVec_eq_spectral hA u, hdiag, Matrix.mulVec_smul,
    eigenvectorUnitary_mulVec_specCoord hA u]

/-- **Rigidity of the lower operator bound.** If the spectrum of the positive definite
matrix `A` is bounded below by `lo ≥ 0` and a unit vector `u` satisfies `‖Aᵀ u‖ = lo`, then
`u` is an eigenvector of `A` for the eigenvalue `lo`. -/
theorem eigenvector_of_eucNorm_transpose_mulVec_eq_min (hA : A.PosDef) {u : Fin n → ℝ}
    (hu : u ⬝ᵥ u = 1) {lo : ℝ} (hlo0 : 0 ≤ lo) (hlo : ∀ i, lo ≤ hA.isHermitian.eigenvalues i)
    (heq : eucNorm (Aᵀ *ᵥ u) = lo) : A *ᵥ u = lo • u := by
  have hAT : Aᵀ = A := by
    rw [← Matrix.conjTranspose_eq_transpose_of_trivial]; exact hA.isHermitian
  rw [hAT] at heq
  have hsum : ∑ i, hA.isHermitian.eigenvalues i ^ 2 * specCoord hA u i ^ 2 = lo ^ 2 := by
    rw [← eucNorm_mulVec_sq_eq_sum hA u, heq]
  have hdiag : Matrix.diagonal hA.isHermitian.eigenvalues *ᵥ specCoord hA u
      = lo • specCoord hA u := by
    funext i
    simpa [Matrix.mulVec_diagonal] using
      mul_eq_of_weighted_sq_eq_min (sum_sq_specCoord hA hu) hlo0 hlo hsum i
  rw [mulVec_eq_spectral hA u, hdiag, Matrix.mulVec_smul,
    eigenvectorUnitary_mulVec_specCoord hA u]

/-- The section factor of a unit eigenvector is its eigenvalue. -/
theorem eucNorm_transpose_mulVec_of_eigenvector (hA : A.PosDef) {u : Fin n → ℝ}
    (hu : u ⬝ᵥ u = 1) {lam : ℝ} (hlam : 0 ≤ lam) (hev : A *ᵥ u = lam • u) :
    eucNorm (Aᵀ *ᵥ u) = lam := by
  have hAT : Aᵀ = A := by
    rw [← Matrix.conjTranspose_eq_transpose_of_trivial]; exact hA.isHermitian
  rw [hAT, hev, eucNorm_smul, eucNorm, hu, Real.sqrt_one, mul_one, abs_of_nonneg hlam]

/-- **Uniqueness of the maximizing direction.** For a unit vector `u` and an upper bound
`hi` for the spectrum of `A`, the section factor `‖Aᵀ u‖` equals `hi` exactly when `u` is an
`hi`-eigenvector of `A`. -/
theorem eucNorm_transpose_mulVec_eq_max_iff (hA : A.PosDef) {u : Fin n → ℝ}
    (hu : u ⬝ᵥ u = 1) {hi : ℝ} (hhi0 : 0 ≤ hi) (hhi : ∀ i, hA.isHermitian.eigenvalues i ≤ hi) :
    eucNorm (Aᵀ *ᵥ u) = hi ↔ A *ᵥ u = hi • u :=
  ⟨eigenvector_of_eucNorm_transpose_mulVec_eq_max hA hu hhi,
    eucNorm_transpose_mulVec_of_eigenvector hA hu hhi0⟩

/-- **Uniqueness of the minimizing direction.** -/
theorem eucNorm_transpose_mulVec_eq_min_iff (hA : A.PosDef) {u : Fin n → ℝ}
    (hu : u ⬝ᵥ u = 1) {lo : ℝ} (hlo0 : 0 ≤ lo) (hlo : ∀ i, lo ≤ hA.isHermitian.eigenvalues i) :
    eucNorm (Aᵀ *ᵥ u) = lo ↔ A *ᵥ u = lo • u :=
  ⟨eigenvector_of_eucNorm_transpose_mulVec_eq_min hA hu hlo0 hlo,
    eucNorm_transpose_mulVec_of_eigenvector hA hu hlo0⟩

end Spectral

/-! ## Equality case of the slicing bounds -/

lemma volume_closedBall_ne_zero (k : ℕ) :
    volume (closedBall (0 : EuclideanSpace ℝ (Fin k)) 1) ≠ 0 :=
  (measure_closedBall_pos volume _ one_pos).ne'

lemma volume_closedBall_ne_top (k : ℕ) :
    volume (closedBall (0 : EuclideanSpace ℝ (Fin k)) 1) ≠ ⊤ :=
  (measure_closedBall_lt_top).ne

/-- Cancellation of the (positive, finite) volume of the unit ball. -/
lemma ofReal_eq_of_mul_volume_closedBall_eq {a b : ℝ} {k : ℕ} (ha : 0 ≤ a) (hb : 0 ≤ b)
    (h : ENNReal.ofReal a * volume (closedBall (0 : EuclideanSpace ℝ (Fin k)) 1)
      = ENNReal.ofReal b * volume (closedBall (0 : EuclideanSpace ℝ (Fin k)) 1)) :
    a = b := by
  have h2 : ENNReal.ofReal a = ENNReal.ofReal b :=
    (ENNReal.mul_left_inj (volume_closedBall_ne_zero k) (volume_closedBall_ne_top k)).mp h
  rwa [ENNReal.ofReal_eq_ofReal_iff ha hb] at h2

/-- **The maximal central sections are exactly the ones orthogonal to a minimal
eigenvector.** For a positive definite `A` with spectrum bounded below by `lo > 0`, the
central section in the direction `u` has the maximal possible volume `det A / lo` times the
volume of the `(n-1)`-ball if and only if `u` is a `lo`-eigenvector of `A`. -/
theorem volume_centralSection_eq_max_iff {A : Matrix (Fin (m + 1)) (Fin (m + 1)) ℝ}
    {ι : Matrix (Fin (m + 1)) (Fin m) ℝ} {u : Fin (m + 1) → ℝ} (hA : A.PosDef)
    (hu : u ⬝ᵥ u = 1) (hι : ιᵀ * ι = 1) (hι' : ι * ιᵀ = 1 - vecMulVec u u) {lo : ℝ}
    (hlo0 : 0 < lo) (hlo : ∀ i, lo ≤ hA.isHermitian.eigenvalues i) :
    volume (centralSection A ι)
        = ENNReal.ofReal (A.det / lo) * volume (closedBall (0 : EuclideanSpace ℝ (Fin m)) 1)
      ↔ A *ᵥ u = lo • u := by
  have hunit : IsUnit A.det := hA.det_pos.ne'.isUnit
  have hnzpos : 0 < eucNorm (Aᵀ *ᵥ u) :=
    eucNorm_pos_of_ne_zero (transpose_mulVec_ne_zero hunit hu)
  rw [volume_centralSection hunit hu hι hι', abs_of_pos hA.det_pos]
  constructor
  · intro h
    have hdiv : A.det / eucNorm (Aᵀ *ᵥ u) = A.det / lo :=
      ofReal_eq_of_mul_volume_closedBall_eq (div_nonneg hA.det_pos.le hnzpos.le)
        (div_nonneg hA.det_pos.le hlo0.le) h
    have hnorm : eucNorm (Aᵀ *ᵥ u) = lo := by
      have h1 := (div_eq_div_iff hnzpos.ne' hlo0.ne').mp hdiv
      exact (mul_left_cancel₀ hA.det_pos.ne' h1).symm
    exact (eucNorm_transpose_mulVec_eq_min_iff hA hu hlo0.le hlo).mp hnorm
  · intro h
    rw [eucNorm_transpose_mulVec_of_eigenvector hA hu hlo0.le h]

/-- **The minimal central sections are exactly the ones orthogonal to a maximal
eigenvector.** -/
theorem volume_centralSection_eq_min_iff {A : Matrix (Fin (m + 1)) (Fin (m + 1)) ℝ}
    {ι : Matrix (Fin (m + 1)) (Fin m) ℝ} {u : Fin (m + 1) → ℝ} (hA : A.PosDef)
    (hu : u ⬝ᵥ u = 1) (hι : ιᵀ * ι = 1) (hι' : ι * ιᵀ = 1 - vecMulVec u u) {hi : ℝ}
    (hhi0 : 0 < hi) (hhi : ∀ i, hA.isHermitian.eigenvalues i ≤ hi) :
    volume (centralSection A ι)
        = ENNReal.ofReal (A.det / hi) * volume (closedBall (0 : EuclideanSpace ℝ (Fin m)) 1)
      ↔ A *ᵥ u = hi • u := by
  have hunit : IsUnit A.det := hA.det_pos.ne'.isUnit
  have hnzpos : 0 < eucNorm (Aᵀ *ᵥ u) :=
    eucNorm_pos_of_ne_zero (transpose_mulVec_ne_zero hunit hu)
  rw [volume_centralSection hunit hu hι hι', abs_of_pos hA.det_pos]
  constructor
  · intro h
    have hdiv : A.det / eucNorm (Aᵀ *ᵥ u) = A.det / hi :=
      ofReal_eq_of_mul_volume_closedBall_eq (div_nonneg hA.det_pos.le hnzpos.le)
        (div_nonneg hA.det_pos.le hhi0.le) h
    have hnorm : eucNorm (Aᵀ *ᵥ u) = hi := by
      have h1 := (div_eq_div_iff hnzpos.ne' hhi0.ne').mp hdiv
      exact (mul_left_cancel₀ hA.det_pos.ne' h1).symm
    exact (eucNorm_transpose_mulVec_eq_max_iff hA hu hhi0.le hhi).mp hnorm
  · intro h
    rw [eucNorm_transpose_mulVec_of_eigenvector hA hu hhi0.le h]

end

end Catalog.Bridges.Ellipsoid