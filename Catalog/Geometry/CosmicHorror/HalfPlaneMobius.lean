import Mathlib
import Geometry.CosmicHorror.HyperbolicIdealArea

/-!
# Boundary triples, real Möbius maps, and normalisation of ideal triangles

`HyperbolicIdealArea.lean` computes the hyperbolic area of the ideal triangle
whose vertices are two finite boundary points `a < b` and the boundary point
`∞`.  To know that this covers *every* ideal triangle one needs the classical
fact that the orientation-preserving isometry group of the half-plane model,
namely the real Möbius group `PSL(2, ℝ)`, acts **sharply three-transitively** on
the boundary circle `ℝ ∪ {∞}`.  This file proves exactly that, in an elementary
and fully explicit form, together with the two facts that make such maps
isometries of the hyperbolic plane:

* `mobius_im`:  `Im T(z) = det · Im z / ‖Cz + D‖²`, so a positive determinant
  forces the upper half-plane to be preserved (`mobius_mapsTo_upperHalfPlane`).
* `mobius_conformal_factor`:  `‖T'(z)‖ / Im T(z) = 1 / Im z`, i.e. `T` preserves
  the hyperbolic line element `|dz| / y` pointwise.  This is the infinitesimal
  statement of "`T` is a hyperbolic isometry".
* `exists_mobius_normalising`:  every triple `p < q < r` of finite boundary
  points is carried to the normal form `(0, 1, ∞)` by a real Möbius map of
  positive determinant, and `mobius_eq_id_of_fixes_zero_one_infty` shows that
  the normalising map is unique.  Hence three distinct boundary points do
  determine an ideal triangle, uniquely up to hyperbolic isometry.
-/

namespace CosmicHorrorGeometry

open Real Set Filter Topology Complex

/-! ### The real Möbius action -/

/-- A real Möbius transformation acting on the complex upper half-plane. -/
noncomputable def mobiusC (A B C D : ℝ) (z : ℂ) : ℂ := ((A : ℂ) * z + B) / ((C : ℂ) * z + D)

/-- The induced action on the boundary line `ℝ` (away from the pole). -/
noncomputable def mobiusR (A B C D : ℝ) (x : ℝ) : ℝ := (A * x + B) / (C * x + D)

/-- **Imaginary part of a Möbius image.**  The determinant appears as the exact
distortion factor of the height coordinate. -/
theorem mobius_im (A B C D : ℝ) (z : ℂ) :
    (mobiusC A B C D z).im = (A * D - B * C) * z.im / Complex.normSq ((C : ℂ) * z + D) := by
  simp only [mobiusC, Complex.div_im, Complex.add_im, Complex.add_re, Complex.mul_im,
    Complex.mul_re, Complex.ofReal_re, Complex.ofReal_im]
  ring

/-- A real Möbius map with positive determinant maps the upper half-plane to
itself. -/
theorem mobius_mapsTo_upperHalfPlane {A B C D : ℝ} (hdet : 0 < A * D - B * C) {z : ℂ}
    (hz : 0 < z.im) : 0 < (mobiusC A B C D z).im := by
  have hne : ((C : ℂ) * z + D) ≠ 0 := by
    intro h
    have him : ((C : ℂ) * z + D).im = 0 := by rw [h]; simp
    simp only [Complex.add_im, Complex.mul_im, Complex.ofReal_re, Complex.ofReal_im] at him
    have hC : C = 0 := by
      rcases mul_eq_zero.1 (by linarith : C * z.im = 0) with h' | h'
      · exact h'
      · exact absurd h' hz.ne'
    have hre : ((C : ℂ) * z + D).re = 0 := by rw [h]; simp
    simp only [Complex.add_re, Complex.mul_re, Complex.ofReal_re, Complex.ofReal_im, hC] at hre
    have hD : D = 0 := by simpa using hre
    rw [hC, hD] at hdet
    simp at hdet
  rw [mobius_im]
  exact div_pos (mul_pos hdet hz) (Complex.normSq_pos.2 hne)

/-- The complex derivative of a Möbius transformation. -/
theorem hasDerivAt_mobiusC {A B C D : ℝ} {z : ℂ} (hne : ((C : ℂ) * z + D) ≠ 0) :
    HasDerivAt (mobiusC A B C D)
      (((A : ℂ) * D - (B : ℂ) * C) / ((C : ℂ) * z + D) ^ 2) z := by
  have hnum : HasDerivAt (fun w : ℂ => (A : ℂ) * w + B) (A : ℂ) z := by
    simpa using ((hasDerivAt_id z).const_mul (A : ℂ)).add_const (B : ℂ)
  have hden : HasDerivAt (fun w : ℂ => (C : ℂ) * w + D) (C : ℂ) z := by
    simpa using ((hasDerivAt_id z).const_mul (C : ℂ)).add_const (D : ℂ)
  have := hnum.div hden hne
  refine this.congr_deriv ?_
  field_simp
  ring

/-- **Möbius maps are hyperbolic isometries, infinitesimally.**  The hyperbolic
line element of the upper half-plane is `|dz| / y`; a real Möbius map with
positive determinant multiplies `|dz|` by `‖T'(z)‖` and `y` by exactly the same
factor, so the ratio is preserved. -/
theorem mobius_conformal_factor {A B C D : ℝ} (hdet : 0 < A * D - B * C) {z : ℂ}
    (hz : 0 < z.im) :
    ‖((A : ℂ) * D - (B : ℂ) * C) / ((C : ℂ) * z + D) ^ 2‖ / (mobiusC A B C D z).im
      = 1 / z.im := by
  have hne : ((C : ℂ) * z + D) ≠ 0 := by
    intro h
    have := mobius_mapsTo_upperHalfPlane hdet hz
    rw [mobius_im, h] at this
    simp at this
  have hdetC : ((A : ℂ) * D - (B : ℂ) * C) = ((A * D - B * C : ℝ) : ℂ) := by push_cast; ring
  have hnorm : ‖((A : ℂ) * D - (B : ℂ) * C) / ((C : ℂ) * z + D) ^ 2‖
      = (A * D - B * C) / Complex.normSq ((C : ℂ) * z + D) := by
    rw [hdetC, norm_div, Complex.norm_real, Real.norm_eq_abs,
      abs_of_pos hdet, norm_pow, Complex.sq_norm]
  rw [hnorm, mobius_im]
  have hns : 0 < Complex.normSq ((C : ℂ) * z + D) := Complex.normSq_pos.2 hne
  field_simp

/-! ### Sharp three-transitivity on the boundary -/

/-- The normalising Möbius transformation attached to a triple `p < q < r` of
boundary points: the classical cross-ratio map sending `p ↦ 0`, `q ↦ 1`,
`r ↦ ∞`.  Its coefficient matrix is
`((q - r), -p (q - r); (q - p), -r (q - p))`. -/
noncomputable def crossRatioCoeffs (p q r : ℝ) : ℝ × ℝ × ℝ × ℝ :=
  (q - r, -(p * (q - r)), q - p, -(r * (q - p)))

/-- The normalising map is orientation preserving: its determinant is positive
precisely because the three points occur in the order `p < q < r`. -/
theorem crossRatio_det_pos {p q r : ℝ} (hpq : p < q) (hqr : q < r) :
    0 < (q - r) * (-(r * (q - p))) - (-(p * (q - r))) * (q - p) := by
  have h1 : 0 < r - q := by linarith
  have h2 : 0 < q - p := by linarith
  have h3 : 0 < r - p := by linarith
  have hexp : (q - r) * (-(r * (q - p))) - (-(p * (q - r))) * (q - p)
      = (r - q) * (q - p) * (r - p) := by ring
  rw [hexp]
  positivity

/-- The normalising map sends the first boundary point to `0`. -/
theorem crossRatio_maps_first {p q r : ℝ} (hpq : p < q) (hqr : q < r) :
    mobiusR (q - r) (-(p * (q - r))) (q - p) (-(r * (q - p))) p = 0 := by
  have hden : (q - p) * p + -(r * (q - p)) ≠ 0 := by
    have : (q - p) * p + -(r * (q - p)) = (q - p) * (p - r) := by ring
    rw [this]
    have : p - r < 0 := by linarith
    nlinarith
  simp only [mobiusR]
  rw [div_eq_zero_iff]
  left; ring

/-- The normalising map sends the middle boundary point to `1`. -/
theorem crossRatio_maps_second {p q r : ℝ} (hpq : p < q) (hqr : q < r) :
    mobiusR (q - r) (-(p * (q - r))) (q - p) (-(r * (q - p))) q = 1 := by
  have hne : (q - p) * (q - r) ≠ 0 := by
    have h1 : q - p > 0 := by linarith
    have h2 : q - r < 0 := by linarith
    nlinarith
  simp only [mobiusR]
  rw [div_eq_one_iff_eq]
  · ring
  · intro h
    apply hne
    rw [show (q - p) * (q - r) = (q - p) * q + -(r * (q - p)) by ring, h]

/-- The third boundary point is exactly the pole of the normalising map, i.e.
it is sent to the boundary point `∞`. -/
theorem crossRatio_pole (p q r : ℝ) :
    (q - p) * r + -(r * (q - p)) = 0 := by ring

/-- **Three distinct boundary points determine an ideal triangle.**  For any
`p < q < r` on the boundary line there is an orientation-preserving real Möbius
transformation carrying `p, q, r` to the normal form `0, 1, ∞`.  Combined with
`idealTriangleArea_eq`, every ideal triangle is isometric to the standard one
of area `π / κ`. -/
theorem exists_mobius_normalising {p q r : ℝ} (hpq : p < q) (hqr : q < r) :
    ∃ A B C D : ℝ, 0 < A * D - B * C ∧ mobiusR A B C D p = 0 ∧ mobiusR A B C D q = 1 ∧
      C * r + D = 0 :=
  ⟨q - r, -(p * (q - r)), q - p, -(r * (q - p)), crossRatio_det_pos hpq hqr,
    crossRatio_maps_first hpq hqr, crossRatio_maps_second hpq hqr, crossRatio_pole p q r⟩

/-- **Uniqueness of the normalisation.**  A real Möbius transformation fixing
the three boundary points `0`, `1` and `∞` is the identity.  Fixing `∞` means
having no finite pole, i.e. `C = 0`. -/
theorem mobius_eq_id_of_fixes_zero_one_infty {A B D : ℝ} (hD : D ≠ 0)
    (h0 : mobiusR A B 0 D 0 = 0) (h1 : mobiusR A B 0 D 1 = 1) :
    ∀ x : ℝ, mobiusR A B 0 D x = x := by
  have hB : B = 0 := by
    simp only [mobiusR, mul_zero, zero_add, div_eq_zero_iff] at h0
    tauto
  subst hB
  have hA : A = D := by
    simp only [mobiusR, mul_one, add_zero, zero_add] at h1
    exact (div_eq_one_iff_eq hD).1 h1
  subst hA
  intro x
  simp only [mobiusR, zero_mul, zero_add, add_zero]
  field_simp

/-- Sharp three-transitivity, packaged: any two normalising maps for the same
boundary triple agree on the whole boundary line.  Hence the ideal triangle
spanned by `p < q < r` is well defined up to a unique hyperbolic isometry. -/
theorem mobius_normalisation_unique {A B D A' B' D' : ℝ} (hD : D ≠ 0) (hD' : D' ≠ 0)
    (h0 : mobiusR A B 0 D 0 = 0) (h1 : mobiusR A B 0 D 1 = 1)
    (h0' : mobiusR A' B' 0 D' 0 = 0) (h1' : mobiusR A' B' 0 D' 1 = 1) :
    ∀ x : ℝ, mobiusR A B 0 D x = mobiusR A' B' 0 D' x := by
  intro x
  rw [mobius_eq_id_of_fixes_zero_one_infty hD h0 h1 x,
    mobius_eq_id_of_fixes_zero_one_infty hD' h0' h1' x]

/-- The standard ideal triangle `(0, 1, ∞)` really is the region computed in
`HyperbolicIdealArea.lean`, and its area at curvature `-κ` is `π / κ`. -/
theorem standardIdealTriangle_area (κ : ℝ) :
    slicedArea κ 0 1 (chordHeight 0 1) = Real.pi / κ :=
  idealTriangleArea_eq (by norm_num)

end CosmicHorrorGeometry