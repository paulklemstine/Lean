/-
# Central sections of ellipsoids of arbitrary codimension

`Bridges.EllipsoidCentralSections` computes the volume of a *hyperplane* section of an
ellipsoid `E A = A · B`.  Here we push the Gram-determinant machinery to sections by
subspaces of arbitrary dimension `m ≤ n`:

* `volume_centralSection_gram` : the `m`-volume of `E A ∩ ran ι` equals
  `(√ det ((A⁻¹ ι)ᵀ (A⁻¹ ι)))⁻¹ · vol(B^m)` for any orthonormal frame `ι` of the
  slicing subspace;
* `det_le_pow_of_quadratic_le` / `pow_le_det_of_le_quadratic` : determinant bounds for a
  positive definite matrix from two-sided bounds on its quadratic form, proved through
  the spectral decomposition;
* `volume_centralSection_sandwich` : an ellipsoid whose generator has eigenvalues in
  `[lo, hi]` has every `m`-dimensional central section squeezed between `lo^m · vol(B^m)`
  and `hi^m · vol(B^m)`;
* `volume_centralSection_coordFrame_diagonal` : the coordinate section of a diagonal
  ellipsoid selected by an injective index map `f` has volume `∏ⱼ |d (f j)| · vol(B^m)`,
  the exact `m`-dimensional analogue of the classical semiaxis product.
-/
import Bridges.EllipsoidCentralSections

namespace Catalog.Bridges.Ellipsoid

open Matrix MeasureTheory Metric Set

noncomputable section

variable {n m : ℕ}

/-! ## The general Gram-determinant section formula -/

/-- If `ι` has orthonormal columns and `A` is invertible, then `A⁻¹ * ι` is injective. -/
lemma mulVec_eq_zero_of_frame {A : Matrix (Fin n) (Fin n) ℝ} {ι : Matrix (Fin n) (Fin m) ℝ}
    (hA : IsUnit A.det) (hι : ιᵀ * ι = 1) (y : Fin m → ℝ) (hy : (A⁻¹ * ι) *ᵥ y = 0) :
    y = 0 := by
  rw [← Matrix.mulVec_mulVec] at hy
  have h1 : ι *ᵥ y = 0 := by
    have h := congrArg (fun x => A *ᵥ x) hy
    simp only [Matrix.mulVec_mulVec, Matrix.mulVec_zero] at h
    rwa [← Matrix.mul_assoc, Matrix.mul_nonsing_inv _ hA, Matrix.one_mul] at h
  have h2 : ιᵀ *ᵥ (ι *ᵥ y) = y := by rw [Matrix.mulVec_mulVec, hι, Matrix.one_mulVec]
  rw [h1] at h2
  simpa using h2.symm

/-- The Gram matrix of the pulled-back frame is positive definite. -/
lemma posDef_gram_of_frame {A : Matrix (Fin n) (Fin n) ℝ} {ι : Matrix (Fin n) (Fin m) ℝ}
    (hA : IsUnit A.det) (hι : ιᵀ * ι = 1) : ((A⁻¹ * ι)ᵀ * (A⁻¹ * ι)).PosDef :=
  posDef_transpose_mul_self (mulVec_eq_zero_of_frame hA hι)

/-- **General central-section volume.** For any orthonormal frame `ι` of an
`m`-dimensional subspace, the `m`-volume of the corresponding central section of the
ellipsoid `E A` is `(√ det ((A⁻¹ ι)ᵀ (A⁻¹ ι)))⁻¹` times the volume of the unit
`m`-ball. -/
theorem volume_centralSection_gram {A : Matrix (Fin n) (Fin n) ℝ}
    {ι : Matrix (Fin n) (Fin m) ℝ} (hA : IsUnit A.det) (hι : ιᵀ * ι = 1) :
    volume (centralSection A ι) =
      ENNReal.ofReal (Real.sqrt ((A⁻¹ * ι)ᵀ * (A⁻¹ * ι)).det)⁻¹ *
        volume (closedBall (0 : EuclideanSpace ℝ (Fin m)) 1) := by
  rw [centralSection_eq hA ι, volume_preimage_closedBall (posDef_gram_of_frame hA hι)]

/-! ## Determinant bounds from quadratic-form bounds -/

lemma dotProduct_gram_mulVec (T : Matrix (Fin n) (Fin m) ℝ) (y : Fin m → ℝ) :
    y ⬝ᵥ ((Tᵀ * T) *ᵥ y) = (T *ᵥ y) ⬝ᵥ (T *ᵥ y) := by
  rw [← Matrix.mulVec_mulVec, Matrix.dotProduct_mulVec]
  simp [Matrix.vecMul_transpose]

/-- An eigenvalue of a Hermitian real matrix is the value of its quadratic form on the
corresponding unit eigenvector. -/
lemma eigenvalue_eq_quadratic {G : Matrix (Fin m) (Fin m) ℝ} (hG : G.IsHermitian) (j : Fin m) :
    hG.eigenvalues j =
      (hG.eigenvectorBasis j).ofLp ⬝ᵥ (G *ᵥ (hG.eigenvectorBasis j).ofLp) := by
  have hnorm : (hG.eigenvectorBasis j).ofLp ⬝ᵥ (hG.eigenvectorBasis j).ofLp = 1 := by
    rw [← norm_sq_eq_dotProduct, hG.eigenvectorBasis.orthonormal.1 j, one_pow]
  rw [hG.mulVec_eigenvectorBasis, dotProduct_smul, smul_eq_mul, hnorm, mul_one]

/-- If the quadratic form of a positive definite matrix is bounded above by `c ‖y‖²`,
its determinant is at most `c ^ m`. -/
theorem det_le_pow_of_quadratic_le {G : Matrix (Fin m) (Fin m) ℝ} (hG : G.PosDef) {c : ℝ}
    (h : ∀ y : Fin m → ℝ, y ⬝ᵥ (G *ᵥ y) ≤ c * (y ⬝ᵥ y)) : G.det ≤ c ^ m := by
  have hdet : G.det = ∏ i, hG.isHermitian.eigenvalues i := by
    simpa using hG.isHermitian.det_eq_prod_eigenvalues
  have hle : ∀ j, hG.isHermitian.eigenvalues j ≤ c := by
    intro j
    have hnorm :
        (hG.isHermitian.eigenvectorBasis j).ofLp ⬝ᵥ
          (hG.isHermitian.eigenvectorBasis j).ofLp = 1 := by
      rw [← norm_sq_eq_dotProduct, hG.isHermitian.eigenvectorBasis.orthonormal.1 j, one_pow]
    have := h (hG.isHermitian.eigenvectorBasis j).ofLp
    rw [hnorm, mul_one, ← eigenvalue_eq_quadratic] at this
    exact this
  calc G.det = ∏ i, hG.isHermitian.eigenvalues i := hdet
    _ ≤ ∏ _i : Fin m, c :=
        Finset.prod_le_prod (fun i _ => (hG.eigenvalues_pos i).le) (fun i _ => hle i)
    _ = c ^ m := by simp

/-- If the quadratic form of a positive definite matrix is bounded below by `c ‖y‖²` with
`c ≥ 0`, its determinant is at least `c ^ m`. -/
theorem pow_le_det_of_le_quadratic {G : Matrix (Fin m) (Fin m) ℝ} (hG : G.PosDef) {c : ℝ}
    (hc : 0 ≤ c) (h : ∀ y : Fin m → ℝ, c * (y ⬝ᵥ y) ≤ y ⬝ᵥ (G *ᵥ y)) : c ^ m ≤ G.det := by
  have hdet : G.det = ∏ i, hG.isHermitian.eigenvalues i := by
    simpa using hG.isHermitian.det_eq_prod_eigenvalues
  have hle : ∀ j, c ≤ hG.isHermitian.eigenvalues j := by
    intro j
    have hnorm :
        (hG.isHermitian.eigenvectorBasis j).ofLp ⬝ᵥ
          (hG.isHermitian.eigenvectorBasis j).ofLp = 1 := by
      rw [← norm_sq_eq_dotProduct, hG.isHermitian.eigenvectorBasis.orthonormal.1 j, one_pow]
    have := h (hG.isHermitian.eigenvectorBasis j).ofLp
    rw [hnorm, mul_one, ← eigenvalue_eq_quadratic] at this
    exact this
  calc c ^ m = ∏ _i : Fin m, c := by simp
    _ ≤ ∏ i, hG.isHermitian.eigenvalues i :=
        Finset.prod_le_prod (fun _ _ => hc) (fun i _ => hle i)
    _ = G.det := hdet.symm

/-! ## The codimension-free eigenvalue sandwich -/

/-- The quadratic form of a Gram matrix is the squared Euclidean norm of the image. -/
lemma quadratic_gram {p : ℕ} (T : Matrix (Fin p) (Fin m) ℝ) (y : Fin m → ℝ) :
    y ⬝ᵥ ((Tᵀ * T) *ᵥ y) = ‖Matrix.toEuclideanLin T (WithLp.toLp 2 y)‖ ^ 2 := by
  rw [norm_toEuclideanLin_sq]

/-- Composition of Euclidean linear maps given by rectangular matrices. -/
lemma toEuclideanLin_mul_apply' {p q : ℕ} (T : Matrix (Fin p) (Fin q) ℝ)
    (S : Matrix (Fin q) (Fin m) ℝ) (y : EuclideanSpace ℝ (Fin m)) :
    Matrix.toEuclideanLin (T * S) y
      = Matrix.toEuclideanLin T (Matrix.toEuclideanLin S y) := by
  simp [Matrix.toLpLin_apply, Matrix.mulVec_mulVec]

/-- A matrix with orthonormal columns acts isometrically. -/
lemma norm_toEuclideanLin_of_orthonormal_cols {ι : Matrix (Fin n) (Fin m) ℝ}
    (hι : ιᵀ * ι = 1) (y : EuclideanSpace ℝ (Fin m)) :
    ‖Matrix.toEuclideanLin ι y‖ = ‖y‖ := by
  have h := norm_toEuclideanLin_sq ι y
  rw [hι, Matrix.one_mulVec, ← norm_sq_eq_dotProduct] at h
  nlinarith [norm_nonneg (Matrix.toEuclideanLin ι y), norm_nonneg y]

/-- **Codimension-free slicing sandwich.** If the positive definite generator `A` has all
eigenvalues in `[lo, hi]` with `lo > 0`, then every `m`-dimensional central section of the
ellipsoid `E A` has volume between `lo^m` and `hi^m` times the volume of the unit
`m`-ball. -/
theorem volume_centralSection_sandwich {A : Matrix (Fin n) (Fin n) ℝ}
    {ι : Matrix (Fin n) (Fin m) ℝ} (hA : A.PosDef) (hι : ιᵀ * ι = 1) {lo hi : ℝ}
    (hlo0 : 0 < lo) (hlohi : lo ≤ hi) (hlo : ∀ i, lo ≤ hA.isHermitian.eigenvalues i)
    (hhi : ∀ i, hA.isHermitian.eigenvalues i ≤ hi) :
    ENNReal.ofReal (lo ^ m) * volume (closedBall (0 : EuclideanSpace ℝ (Fin m)) 1) ≤
        volume (centralSection A ι) ∧
      volume (centralSection A ι) ≤
        ENNReal.ofReal (hi ^ m) * volume (closedBall (0 : EuclideanSpace ℝ (Fin m)) 1) := by
  have hunit : IsUnit A.det := hA.det_pos.ne'.isUnit
  have hhi0 : 0 < hi := lt_of_lt_of_le hlo0 hlohi
  set G := (A⁻¹ * ι)ᵀ * (A⁻¹ * ι) with hGdef
  have hGpd : G.PosDef := posDef_gram_of_frame hunit hι
  -- two-sided bounds on the quadratic form of the section Gram matrix
  have key : ∀ y : Fin m → ℝ,
      (1 / hi ^ 2) * (y ⬝ᵥ y) ≤ y ⬝ᵥ (G *ᵥ y) ∧
        y ⬝ᵥ (G *ᵥ y) ≤ (1 / lo ^ 2) * (y ⬝ᵥ y) := by
    intro y
    set Y : EuclideanSpace ℝ (Fin m) := WithLp.toLp 2 y with hY
    set z : EuclideanSpace ℝ (Fin n) := Matrix.toEuclideanLin ι Y with hz
    set w : EuclideanSpace ℝ (Fin n) := Matrix.toEuclideanLin A⁻¹ z with hw
    have hq : y ⬝ᵥ (G *ᵥ y) = ‖w‖ ^ 2 := by
      rw [hGdef, quadratic_gram, toEuclideanLin_mul_apply']
    have hzY : ‖z‖ = ‖Y‖ := norm_toEuclideanLin_of_orthonormal_cols hι Y
    have hYy : ‖Y‖ ^ 2 = y ⬝ᵥ y := norm_sq_eq_dotProduct Y
    have hAw : Matrix.toEuclideanLin A w = z := toEuclideanLin_apply_inv hunit z
    have h1 : lo * ‖w‖ ≤ ‖z‖ := by
      rw [← hAw]; exact le_norm_toEuclideanLin_posDef hA hlo0.le hlo w
    have h2 : ‖z‖ ≤ hi * ‖w‖ := by
      rw [← hAw]; exact norm_toEuclideanLin_posDef_le hA hhi0.le hhi w
    have hwnn : 0 ≤ ‖w‖ := norm_nonneg w
    have hznn : 0 ≤ ‖z‖ := norm_nonneg z
    have hz2 : ‖z‖ ^ 2 = y ⬝ᵥ y := by rw [hzY, hYy]
    constructor
    · rw [hq, div_mul_eq_mul_div, one_mul, div_le_iff₀ (by positivity), ← hz2]
      nlinarith
    · rw [hq, div_mul_eq_mul_div, one_mul, le_div_iff₀ (by positivity), ← hz2]
      nlinarith [mul_nonneg hlo0.le hwnn, sub_nonneg.2 h1,
        mul_nonneg (sub_nonneg.2 h1) (add_nonneg hznn (mul_nonneg hlo0.le hwnn))]
  have hdet_le : G.det ≤ (1 / lo ^ 2) ^ m :=
    det_le_pow_of_quadratic_le hGpd fun y => (key y).2
  have hdet_ge : (1 / hi ^ 2) ^ m ≤ G.det :=
    pow_le_det_of_le_quadratic hGpd (by positivity) fun y => (key y).1
  have hsq : ∀ t : ℝ, 0 < t → Real.sqrt ((1 / t ^ 2) ^ m) = (1 / t) ^ m := by
    intro t ht
    have h1 : (1 : ℝ) / t ^ 2 = (1 / t) ^ 2 := by rw [div_pow, one_pow]
    have h2 : ((1 : ℝ) / t ^ 2) ^ m = ((1 / t) ^ m) ^ 2 := by
      rw [h1, ← pow_mul, mul_comm 2 m, pow_mul]
    rw [h2, Real.sqrt_sq (by positivity)]
  have hGpos : 0 < G.det := hGpd.det_pos
  have hsqrtpos : 0 < Real.sqrt G.det := Real.sqrt_pos.2 hGpos
  have hub : Real.sqrt G.det ≤ (1 / lo) ^ m := by
    rw [← hsq lo hlo0]; exact Real.sqrt_le_sqrt hdet_le
  have hlb : (1 / hi) ^ m ≤ Real.sqrt G.det := by
    rw [← hsq hi hhi0]; exact Real.sqrt_le_sqrt hdet_ge
  have hinvlo : lo ^ m ≤ (Real.sqrt G.det)⁻¹ := by
    have := inv_anti₀ hsqrtpos hub
    rwa [one_div, inv_pow, inv_inv] at this
  have hinvhi : (Real.sqrt G.det)⁻¹ ≤ hi ^ m := by
    have := inv_anti₀ (by positivity : (0:ℝ) < (1 / hi) ^ m) hlb
    rwa [one_div, inv_pow, inv_inv] at this
  rw [volume_centralSection_gram hunit hι]
  exact ⟨by gcongr, by gcongr⟩

/-! ## Coordinate sections of a diagonal ellipsoid -/

/-- The orthonormal frame selecting the coordinates indexed by `f`. -/
def coordFrame (f : Fin m → Fin n) : Matrix (Fin n) (Fin m) ℝ :=
  Matrix.of fun i j => if i = f j then 1 else 0

lemma coordFrame_transpose_mul_self {f : Fin m → Fin n} (hf : Function.Injective f) :
    (coordFrame f)ᵀ * coordFrame f = 1 := by
  ext j k
  rw [Matrix.mul_apply]
  simp only [Matrix.transpose_apply, coordFrame, Matrix.of_apply, Matrix.one_apply]
  rw [Finset.sum_eq_single (f j)]
  · by_cases h : j = k
    · subst h; simp
    · have hfk : f j ≠ f k := fun hh => h (hf hh)
      simp [hfk, h]
  · intro b _ hb
    simp [hb]
  · simp

lemma inv_diagonal_of_ne_zero {d : Fin n → ℝ} (hd : ∀ i, d i ≠ 0) :
    (Matrix.diagonal d)⁻¹ = Matrix.diagonal (fun i => (d i)⁻¹) := by
  refine Matrix.inv_eq_right_inv ?_
  rw [Matrix.diagonal_mul_diagonal,
    show (fun i => d i * (d i)⁻¹) = (1 : Fin n → ℝ) from funext fun i => mul_inv_cancel₀ (hd i)]
  exact Matrix.diagonal_one

/-- Selecting `m` coordinates of a diagonal matrix produces a diagonal Gram matrix. -/
lemma gram_diagonal_coordFrame {d : Fin n → ℝ} {f : Fin m → Fin n} (hf : Function.Injective f) :
    ((Matrix.diagonal d * coordFrame f)ᵀ * (Matrix.diagonal d * coordFrame f))
      = Matrix.diagonal (fun j => (d (f j)) ^ 2) := by
  have hDi : ∀ i j, (Matrix.diagonal d * coordFrame f) i j = if i = f j then d i else 0 := by
    intro i j
    simp [Matrix.mul_apply, Matrix.diagonal_apply, coordFrame]
  ext j k
  rw [Matrix.mul_apply, Matrix.diagonal_apply]
  simp only [Matrix.transpose_apply, hDi]
  rw [Finset.sum_eq_single (f j)]
  · by_cases h : j = k
    · subst h; simp [sq]
    · have hfk : f j ≠ f k := fun hh => h (hf hh)
      simp [hfk, h]
  · intro b _ hb; simp [hb]
  · simp

/-- **Coordinate sections of a diagonal ellipsoid.** Slicing the ellipsoid with semiaxes
`|dᵢ|` by the coordinate subspace spanned by the directions `f 0, …, f (m-1)` yields an
`m`-dimensional ellipsoid of volume `∏ⱼ |d (f j)|` times the volume of the unit `m`-ball. -/
theorem volume_centralSection_coordFrame_diagonal {d : Fin n → ℝ} {f : Fin m → Fin n}
    (hd : ∀ i, d i ≠ 0) (hf : Function.Injective f) :
    volume (centralSection (Matrix.diagonal d) (coordFrame f)) =
      ENNReal.ofReal (∏ j, |d (f j)|) *
        volume (closedBall (0 : EuclideanSpace ℝ (Fin m)) 1) := by
  have hA : IsUnit (Matrix.diagonal d).det := by
    rw [Matrix.det_diagonal]
    exact isUnit_iff_ne_zero.2 (Finset.prod_ne_zero_iff.2 fun i _ => hd i)
  rw [volume_centralSection_gram hA (coordFrame_transpose_mul_self hf),
    inv_diagonal_of_ne_zero hd, gram_diagonal_coordFrame hf, Matrix.det_diagonal]
  congr 2
  set P := ∏ j, |d (f j)| with hP
  have hPpos : 0 < P := Finset.prod_pos fun j _ => abs_pos.2 (hd (f j))
  have hdet : ∏ j, ((d (f j))⁻¹) ^ 2 = (P⁻¹) ^ 2 := by
    rw [hP, ← Finset.prod_inv_distrib, ← Finset.prod_pow]
    exact Finset.prod_congr rfl fun j _ => by rw [inv_pow, inv_pow, sq_abs]
  rw [hdet, Real.sqrt_sq (by positivity), inv_inv]

end

end Catalog.Bridges.Ellipsoid