/-
# Slicing bounds, polar duality and determinant normalization for ellipsoids

This file builds on `Bridges.EllipsoidCentralSections`, where an ellipsoid is defined as
the image `E A = A · B` of the Euclidean unit ball under an invertible matrix, and where
the central section formula

  `vol_{n-1}(E A ∩ u^⊥) = (|det A| / ‖Aᵀ u‖) · vol_{n-1}(B^{n-1})`

was established.  Here we derive its consequences:

* `volume_centralSection_le`, `le_volume_centralSection` : two-sided slicing bounds by the
  extreme eigenvalues of a positive definite generator;
* `volume_centralSection_of_eigenvector` : exact section volume in an eigendirection;
* `volume_centralSection_frame_independent` : the section volume does not depend on the
  chosen orthonormal parametrization of the hyperplane;
* `prod_det_div_eigenvalues` : the product of the `n` principal section ratios is
  `(det A)^(n-1)` — the determinant-normalization identity;
* `polarSet_ellipsoid` and `volume_ellipsoid_mul_volume_polar` : the polar body of an
  ellipsoid is the ellipsoid of the inverse transpose, and the Blaschke–Santaló product
  is exactly the square of the ball volume;
* worked two- and three-dimensional coordinate sections of a diagonal ellipsoid.
-/
import Bridges.EllipsoidCentralSections

namespace Catalog.Bridges.Ellipsoid

open Matrix MeasureTheory Metric Set

noncomputable section

variable {n m : ℕ}

/-! ## Elementary Euclidean norm computations -/

lemma eucNorm_smul (c : ℝ) (v : Fin n → ℝ) : eucNorm (c • v) = |c| * eucNorm v := by
  have h : (c • v) ⬝ᵥ (c • v) = c ^ 2 * (v ⬝ᵥ v) := by
    simp [dotProduct, Finset.mul_sum]
    exact Finset.sum_congr rfl fun i _ => by ring
  rw [eucNorm, eucNorm, h, Real.sqrt_mul (by positivity), Real.sqrt_sq_eq_abs]

lemma eucNorm_mulVec_eq_norm (A : Matrix (Fin m) (Fin n) ℝ) (u : Fin n → ℝ) :
    eucNorm (A *ᵥ u) = ‖Matrix.toEuclideanLin A (WithLp.toLp 2 u)‖ := by
  rw [eucNorm_eq_norm]
  congr 1

/-! ## Slicing bounds through the eigenvalues -/

/-- For a positive definite `A` and a unit vector `u`, `‖Aᵀ u‖` is at least the smallest
eigenvalue of `A`. -/
theorem le_eucNorm_transpose_mulVec {A : Matrix (Fin n) (Fin n) ℝ} (hA : A.PosDef)
    {u : Fin n → ℝ} (hu : u ⬝ᵥ u = 1) {lo : ℝ} (hlo0 : 0 ≤ lo)
    (hlo : ∀ i, lo ≤ hA.isHermitian.eigenvalues i) : lo ≤ eucNorm (Aᵀ *ᵥ u) := by
  have hAT : Aᵀ = A := by
    rw [← Matrix.conjTranspose_eq_transpose_of_trivial]; exact hA.isHermitian
  have hnu : ‖(WithLp.toLp 2 u : EuclideanSpace ℝ (Fin n))‖ = 1 := by
    rw [← eucNorm_eq_norm, eucNorm, hu, Real.sqrt_one]
  rw [hAT, eucNorm_mulVec_eq_norm]
  have h := le_norm_toEuclideanLin_posDef hA hlo0 hlo (WithLp.toLp 2 u)
  rwa [hnu, mul_one] at h

/-- For a positive definite `A` and a unit vector `u`, `‖Aᵀ u‖` is at most the largest
eigenvalue of `A`. -/
theorem eucNorm_transpose_mulVec_le {A : Matrix (Fin n) (Fin n) ℝ} (hA : A.PosDef)
    {u : Fin n → ℝ} (hu : u ⬝ᵥ u = 1) {hi : ℝ} (hhi0 : 0 ≤ hi)
    (hhi : ∀ i, hA.isHermitian.eigenvalues i ≤ hi) : eucNorm (Aᵀ *ᵥ u) ≤ hi := by
  have hAT : Aᵀ = A := by
    rw [← Matrix.conjTranspose_eq_transpose_of_trivial]; exact hA.isHermitian
  have hnu : ‖(WithLp.toLp 2 u : EuclideanSpace ℝ (Fin n))‖ = 1 := by
    rw [← eucNorm_eq_norm, eucNorm, hu, Real.sqrt_one]
  rw [hAT, eucNorm_mulVec_eq_norm]
  have h := norm_toEuclideanLin_posDef_le hA hhi0 hhi (WithLp.toLp 2 u)
  rwa [hnu, mul_one] at h

/-- **Upper slicing bound.** Every central section of a positive definite ellipsoid has
volume at most `det A / λmin` times the volume of the `(n-1)`-ball. -/
theorem volume_centralSection_le {A : Matrix (Fin (m + 1)) (Fin (m + 1)) ℝ}
    {ι : Matrix (Fin (m + 1)) (Fin m) ℝ} {u : Fin (m + 1) → ℝ} (hA : A.PosDef)
    (hu : u ⬝ᵥ u = 1) (hι : ιᵀ * ι = 1) (hι' : ι * ιᵀ = 1 - vecMulVec u u) {lo : ℝ}
    (hlo0 : 0 < lo) (hlo : ∀ i, lo ≤ hA.isHermitian.eigenvalues i) :
    volume (centralSection A ι) ≤
      ENNReal.ofReal (A.det / lo) * volume (closedBall (0 : EuclideanSpace ℝ (Fin m)) 1) := by
  have hunit : IsUnit A.det := hA.det_pos.ne'.isUnit
  have hb := le_eucNorm_transpose_mulVec hA hu hlo0.le hlo
  rw [volume_centralSection hunit hu hι hι']
  have hle : |A.det| / eucNorm (Aᵀ *ᵥ u) ≤ A.det / lo := by
    rw [abs_of_pos hA.det_pos]
    exact div_le_div_of_nonneg_left hA.det_pos.le hlo0 hb
  gcongr

/-- **Lower slicing bound.** Every central section of a positive definite ellipsoid has
volume at least `det A / λmax` times the volume of the `(n-1)`-ball. -/
theorem le_volume_centralSection {A : Matrix (Fin (m + 1)) (Fin (m + 1)) ℝ}
    {ι : Matrix (Fin (m + 1)) (Fin m) ℝ} {u : Fin (m + 1) → ℝ} (hA : A.PosDef)
    (hu : u ⬝ᵥ u = 1) (hι : ιᵀ * ι = 1) (hι' : ι * ιᵀ = 1 - vecMulVec u u) {hi : ℝ}
    (hhi0 : 0 < hi) (hhi : ∀ i, hA.isHermitian.eigenvalues i ≤ hi) :
    ENNReal.ofReal (A.det / hi) * volume (closedBall (0 : EuclideanSpace ℝ (Fin m)) 1) ≤
      volume (centralSection A ι) := by
  have hunit : IsUnit A.det := hA.det_pos.ne'.isUnit
  have hnz : 0 < eucNorm (Aᵀ *ᵥ u) :=
    eucNorm_pos_of_ne_zero (transpose_mulVec_ne_zero hunit hu)
  have hb := eucNorm_transpose_mulVec_le hA hu hhi0.le hhi
  rw [volume_centralSection hunit hu hι hι']
  have hle : A.det / hi ≤ |A.det| / eucNorm (Aᵀ *ᵥ u) := by
    rw [abs_of_pos hA.det_pos]
    exact div_le_div_of_nonneg_left hA.det_pos.le hnz hb
  gcongr

/-- **Exact section in an eigendirection.** If `u` is a unit eigenvector of the positive
definite generator `A` with eigenvalue `lam`, the corresponding central section has volume
`(det A / lam)` times the volume of the `(n-1)`-ball. -/
theorem volume_centralSection_of_eigenvector {A : Matrix (Fin (m + 1)) (Fin (m + 1)) ℝ}
    {ι : Matrix (Fin (m + 1)) (Fin m) ℝ} {u : Fin (m + 1) → ℝ} {lam : ℝ} (hA : A.PosDef)
    (hu : u ⬝ᵥ u = 1) (hι : ιᵀ * ι = 1) (hι' : ι * ιᵀ = 1 - vecMulVec u u)
    (hlam : 0 < lam) (hev : A *ᵥ u = lam • u) :
    volume (centralSection A ι) =
      ENNReal.ofReal (A.det / lam) * volume (closedBall (0 : EuclideanSpace ℝ (Fin m)) 1) := by
  have hunit : IsUnit A.det := hA.det_pos.ne'.isUnit
  have hAT : Aᵀ = A := by
    rw [← Matrix.conjTranspose_eq_transpose_of_trivial]; exact hA.isHermitian
  have hnu : eucNorm u = 1 := by rw [eucNorm, hu, Real.sqrt_one]
  rw [volume_centralSection hunit hu hι hι', hAT, hev, eucNorm_smul, hnu, mul_one,
    abs_of_pos hlam, abs_of_pos hA.det_pos]

/-- The central section volume does not depend on the orthonormal parametrization chosen
for the hyperplane `u^⊥`. -/
theorem volume_centralSection_frame_independent {A : Matrix (Fin (m + 1)) (Fin (m + 1)) ℝ}
    {ι κ : Matrix (Fin (m + 1)) (Fin m) ℝ} {u : Fin (m + 1) → ℝ} (hA : IsUnit A.det)
    (hu : u ⬝ᵥ u = 1) (hι : ιᵀ * ι = 1) (hι' : ι * ιᵀ = 1 - vecMulVec u u)
    (hκ : κᵀ * κ = 1) (hκ' : κ * κᵀ = 1 - vecMulVec u u) :
    volume (centralSection A ι) = volume (centralSection A κ) := by
  rw [volume_centralSection hA hu hι hι', volume_centralSection hA hu hκ hκ']

/-- **Determinant-normalization identity.** The product over an eigenbasis of the section
ratios `det A / λ_i` equals `(det A)^(n-1)`; in particular it is `1` for a unimodular
generator. -/
theorem prod_det_div_eigenvalues {A : Matrix (Fin n) (Fin n) ℝ} (hA : A.PosDef) :
    ∏ i, (A.det / hA.isHermitian.eigenvalues i) = (A.det) ^ (n - 1) := by
  have hdet : A.det = ∏ i, hA.isHermitian.eigenvalues i := by
    simpa using hA.isHermitian.det_eq_prod_eigenvalues
  have hne : A.det ≠ 0 := hA.det_pos.ne'
  rw [Finset.prod_div_distrib, Finset.prod_const, ← hdet, Finset.card_univ, Fintype.card_fin]
  rcases Nat.eq_zero_or_pos n with rfl | hn
  · simp
  · rw [div_eq_iff hne, ← pow_succ]
    congr 1
    omega

/-! ## Polar duality and the Blaschke–Santaló equality for ellipsoids -/

/-- The polar body of a set in Euclidean space. -/
def polarSet (s : Set (EuclideanSpace ℝ (Fin n))) : Set (EuclideanSpace ℝ (Fin n)) :=
  {y | ∀ x ∈ s, inner ℝ y x ≤ 1}

lemma forall_inner_le_one_iff (z : EuclideanSpace ℝ (Fin n)) :
    (∀ x : EuclideanSpace ℝ (Fin n), ‖x‖ ≤ 1 → inner ℝ z x ≤ 1) ↔ ‖z‖ ≤ 1 := by
  constructor
  · intro h
    rcases eq_or_ne z 0 with rfl | hz
    · simp
    · have hx : ‖(‖z‖⁻¹ • z : EuclideanSpace ℝ (Fin n))‖ ≤ 1 := by
        rw [norm_smul]
        simp [inv_mul_cancel₀ (norm_ne_zero_iff.2 hz)]
      have h1 := h _ hx
      rwa [real_inner_smul_right, real_inner_self_eq_norm_sq, inv_mul_eq_div, sq, mul_div_assoc,
        div_self (norm_ne_zero_iff.2 hz), mul_one] at h1
  · intro h x hx
    calc inner ℝ z x ≤ ‖z‖ * ‖x‖ := real_inner_le_norm z x
      _ ≤ 1 * 1 := mul_le_mul h hx (norm_nonneg x) zero_le_one
      _ = 1 := one_mul 1

lemma inner_toEuclideanLin (A : Matrix (Fin n) (Fin n) ℝ) (x y : EuclideanSpace ℝ (Fin n)) :
    inner ℝ y (Matrix.toEuclideanLin A x) = inner ℝ (Matrix.toEuclideanLin Aᵀ y) x := by
  rw [show Aᵀ = Aᴴ from (Matrix.conjTranspose_eq_transpose_of_trivial A).symm,
    Matrix.toEuclideanLin_conjTranspose_eq_adjoint, LinearMap.adjoint_inner_left]

/-- **Polar duality for ellipsoids.** The polar body of the ellipsoid `A · B` is the
ellipsoid generated by the inverse transpose of `A`. -/
theorem polarSet_ellipsoid {A : Matrix (Fin n) (Fin n) ℝ} (hA : IsUnit A.det) :
    polarSet (ellipsoid A) = ellipsoid (Aᵀ)⁻¹ := by
  have hAT : IsUnit (Aᵀ).det := by rwa [Matrix.det_transpose]
  have hinv : IsUnit ((Aᵀ)⁻¹).det := by
    rw [Matrix.det_nonsing_inv, Ring.inverse_eq_inv', isUnit_iff_ne_zero, ne_eq, inv_eq_zero,
      ← ne_eq, ← isUnit_iff_ne_zero]
    exact hAT
  ext y
  rw [mem_ellipsoid_iff_of_isUnit hinv, Matrix.nonsing_inv_nonsing_inv _ hAT, polarSet,
    Set.mem_setOf_eq]
  constructor
  · intro h
    rw [← forall_inner_le_one_iff]
    intro x hx
    rw [← inner_toEuclideanLin]
    exact h _ ⟨x, by simpa using hx, rfl⟩
  · rintro h x ⟨x', hx', rfl⟩
    rw [inner_toEuclideanLin]
    exact (forall_inner_le_one_iff _).2 h x' (by simpa using hx')

/-- **Blaschke–Santaló equality for ellipsoids.** The volume product of an ellipsoid and
its polar is exactly the square of the volume of the unit ball. -/
theorem volume_ellipsoid_mul_volume_polar {A : Matrix (Fin n) (Fin n) ℝ} (hA : IsUnit A.det) :
    volume (ellipsoid A) * volume (polarSet (ellipsoid A)) =
      volume (closedBall (0 : EuclideanSpace ℝ (Fin n)) 1) ^ 2 := by
  have hdetne : A.det ≠ 0 := by rwa [← isUnit_iff_ne_zero]
  rw [polarSet_ellipsoid hA, volume_ellipsoid, volume_ellipsoid, Matrix.det_nonsing_inv,
    Matrix.det_transpose, Ring.inverse_eq_inv']
  rw [show ENNReal.ofReal |A.det| * volume (closedBall (0 : EuclideanSpace ℝ (Fin n)) 1) *
      (ENNReal.ofReal |(A.det)⁻¹| * volume (closedBall (0 : EuclideanSpace ℝ (Fin n)) 1))
      = (ENNReal.ofReal |A.det| * ENNReal.ofReal |(A.det)⁻¹|) *
        volume (closedBall (0 : EuclideanSpace ℝ (Fin n)) 1) ^ 2 by ring]
  rw [← ENNReal.ofReal_mul (abs_nonneg _), ← abs_mul, mul_inv_cancel₀ hdetne]
  simp

/-! ## Worked coordinate sections of diagonal ellipsoids -/

/-- The central section of a two-dimensional ellipse with semiaxes `a, b` by the first
coordinate axis has length `a` times the length of the one-dimensional unit ball. -/
theorem volume_centralSection_ellipse {a b : ℝ} (ha : 0 < a) (hb : 0 < b) :
    volume (centralSection (Matrix.diagonal ![a, b]) (Matrix.of ![![(1 : ℝ)], ![0]])) =
      ENNReal.ofReal a * volume (closedBall (0 : EuclideanSpace ℝ (Fin 1)) 1) := by
  have hA : IsUnit (Matrix.diagonal ![a, b]).det := by
    rw [Matrix.det_diagonal]
    simp only [Fin.prod_univ_two, Matrix.cons_val_zero, Matrix.cons_val_one]
    exact (isUnit_iff_ne_zero).2 (by positivity)
  have hu : (![(0 : ℝ), 1]) ⬝ᵥ (![(0 : ℝ), 1]) = 1 := by
    simp [dotProduct, Fin.sum_univ_two]
  have hι : (Matrix.of ![![(1 : ℝ)], ![0]])ᵀ * (Matrix.of ![![(1 : ℝ)], ![0]]) = 1 := by
    ext i j
    fin_cases i; fin_cases j
    simp [Matrix.mul_apply, Fin.sum_univ_two]
  have hι' : (Matrix.of ![![(1 : ℝ)], ![0]]) * (Matrix.of ![![(1 : ℝ)], ![0]])ᵀ
      = 1 - vecMulVec ![(0 : ℝ), 1] ![(0 : ℝ), 1] := by
    ext i j
    fin_cases i <;> fin_cases j <;>
      simp [Matrix.mul_apply]
  rw [volume_centralSection hA hu hι hι']
  congr 2
  have hnorm : eucNorm ((Matrix.diagonal ![a, b])ᵀ *ᵥ ![(0 : ℝ), 1]) = b := by
    rw [Matrix.diagonal_transpose, eucNorm]
    have h1 : (Matrix.diagonal ![a, b]) *ᵥ ![(0 : ℝ), 1] = ![0, b] := by
      ext i; fin_cases i <;> simp [Matrix.mulVec_diagonal]
    have h2 : (![(0 : ℝ), b]) ⬝ᵥ ![(0 : ℝ), b] = b * b := by
      simp [dotProduct, Fin.sum_univ_two]
    rw [h1, h2, Real.sqrt_mul_self hb.le]
  rw [hnorm, Matrix.det_diagonal]
  have hprod : ∏ i, ![a, b] i = a * b := by simp [Fin.prod_univ_two]
  rw [hprod, abs_of_pos (by positivity), mul_div_assoc, div_self hb.ne', mul_one]

/-- The central section of a three-dimensional ellipsoid with semiaxes `a, b, c` by the
`{x₃ = 0}` plane has area `a * b` times the area of the two-dimensional unit disc. -/
theorem volume_centralSection_ellipsoid3 {a b c : ℝ} (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    volume (centralSection (Matrix.diagonal ![a, b, c])
        (Matrix.of ![![(1 : ℝ), 0], ![0, 1], ![0, 0]])) =
      ENNReal.ofReal (a * b) * volume (closedBall (0 : EuclideanSpace ℝ (Fin 2)) 1) := by
  have hA : IsUnit (Matrix.diagonal ![a, b, c]).det := by
    rw [Matrix.det_diagonal]
    simp only [Fin.prod_univ_three, Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.cons_val_two]
    exact (isUnit_iff_ne_zero).2 (by positivity)
  have hu : (![(0 : ℝ), 0, 1]) ⬝ᵥ (![(0 : ℝ), 0, 1]) = 1 := by
    simp [dotProduct, Fin.sum_univ_three]
  have hι : (Matrix.of ![![(1 : ℝ), 0], ![0, 1], ![0, 0]])ᵀ *
      (Matrix.of ![![(1 : ℝ), 0], ![0, 1], ![0, 0]]) = 1 := by
    ext i j
    fin_cases i <;> fin_cases j <;>
      simp [Matrix.mul_apply, Fin.sum_univ_three]
  have hι' : (Matrix.of ![![(1 : ℝ), 0], ![0, 1], ![0, 0]]) *
      (Matrix.of ![![(1 : ℝ), 0], ![0, 1], ![0, 0]])ᵀ
      = 1 - vecMulVec ![(0 : ℝ), 0, 1] ![(0 : ℝ), 0, 1] := by
    ext i j
    fin_cases i <;> fin_cases j <;>
      simp [Matrix.mul_apply, Fin.sum_univ_two]
  rw [volume_centralSection hA hu hι hι']
  congr 2
  have hnorm : eucNorm ((Matrix.diagonal ![a, b, c])ᵀ *ᵥ ![(0 : ℝ), 0, 1]) = c := by
    rw [Matrix.diagonal_transpose, eucNorm]
    have h1 : (Matrix.diagonal ![a, b, c]) *ᵥ ![(0 : ℝ), 0, 1] = ![0, 0, c] := by
      ext i; fin_cases i <;> simp [Matrix.mulVec_diagonal]
    have h2 : (![(0 : ℝ), 0, c]) ⬝ᵥ ![(0 : ℝ), 0, c] = c * c := by
      simp [dotProduct, Fin.sum_univ_three]
    rw [h1, h2, Real.sqrt_mul_self hc.le]
  rw [hnorm, Matrix.det_diagonal]
  have hprod : ∏ i, ![a, b, c] i = a * b * c := by simp [Fin.prod_univ_three]
  rw [hprod, abs_of_pos (by positivity), mul_div_assoc, div_self hc.ne', mul_one]

end

end Catalog.Bridges.Ellipsoid