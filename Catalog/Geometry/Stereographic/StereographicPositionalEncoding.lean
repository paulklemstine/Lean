import Mathlib

/-! # CatalogBuild.Geometry.Stereographic.StereographicPositionalEncoding

Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 12
-/


noncomputable section

/-- A spiral curve on S² parameterized by position index. -/
def spiralPos (freq : ℝ) (pos : ℕ) : Fin 3 → ℝ := fun i =>
  let t := (pos : ℝ) * freq
  match i with
  | ⟨0, _⟩ => Real.sin t * Real.cos (t / 3)
  | ⟨1, _⟩ => Real.sin t * Real.sin (t / 3)
  | ⟨2, _⟩ => Real.cos t




/-- [Section: # CatalogBuild.Geometry.Stereographic.StereographicPositionalEncoding
Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 12] -/
theorem spiralPos_on_sphere (freq : ℝ) (pos : ℕ) :
    (spiralPos freq pos 0) ^ 2 + (spiralPos freq pos 1) ^ 2 +
    (spiralPos freq pos 2) ^ 2 = 1 := by
      unfold spiralPos; ring_nf; norm_num [ Real.sin_sq, Real.cos_sq ] ; ring;




/-- Sum form of the on-sphere property. -/
theorem spiralPos_on_sphere_sum (freq : ℝ) (pos : ℕ) :
    ∑ i : Fin 3, (spiralPos freq pos i) ^ 2 = 1 := by
  simp [Fin.sum_univ_three]
  exact spiralPos_on_sphere freq pos




/-- [Section: # CatalogBuild.Geometry.Stereographic.StereographicPositionalEncoding
Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 12] -/
def sphereInnerProd (p q : Fin 3 → ℝ) : ℝ :=
  ∑ i, p i * q i




theorem geodesicDist_le_pi (p q : Fin 3 → ℝ) :
    geodesicDist p q ≤ Real.pi := by
  unfold geodesicDist
  exact Real.arccos_le_pi _




def stereoPosEnc (freq : ℝ) (pos1 pos2 : ℕ) : ℝ :=
  sphereInnerProd (spiralPos freq pos1) (spiralPos freq pos2)




theorem stereoPosEnc_symm (freq : ℝ) (pos1 pos2 : ℕ) :
    stereoPosEnc freq pos1 pos2 = stereoPosEnc freq pos2 pos1 := by
  unfold stereoPosEnc sphereInnerProd
  exact Finset.sum_congr rfl fun i _ => mul_comm _ _




theorem stereoPosEnc_self (freq : ℝ) (pos : ℕ) :
    stereoPosEnc freq pos pos = 1 := by
  unfold stereoPosEnc sphereInnerProd
  simp only [← sq]
  exact spiralPos_on_sphere_sum freq pos




def relativePosBias (freq decay : ℝ) (pos1 pos2 : ℕ) : ℝ :=
  Real.exp (-decay * geodesicDist (spiralPos freq pos1) (spiralPos freq pos2))




theorem relativePosBias_pos (freq decay : ℝ) (pos1 pos2 : ℕ) :
    0 < relativePosBias freq decay pos1 pos2 := by
  unfold relativePosBias; exact exp_pos _




theorem relativePosBias_le_one (freq decay : ℝ) (pos1 pos2 : ℕ)
    (hdecay : 0 ≤ decay) :
    relativePosBias freq decay pos1 pos2 ≤ 1 := by
  unfold relativePosBias
  apply Real.exp_le_one_iff.mpr
  linarith [mul_nonneg hdecay (geodesicDist_nonneg (spiralPos freq pos1) (spiralPos freq pos2))]




theorem relativePosBias_self (freq decay : ℝ) (pos : ℕ) :
    relativePosBias freq decay pos pos = 1 := by
  unfold relativePosBias geodesicDist
  have : sphereInnerProd (spiralPos freq pos) (spiralPos freq pos) = 1 := by
    unfold sphereInnerProd; simp only [← sq]; exact spiralPos_on_sphere_sum freq pos
  simp [this, Real.arccos_one]




end
