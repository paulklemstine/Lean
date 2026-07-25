import Mathlib

/-! # CatalogBuild.Computation.Oracles.OracleConsultation

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 16
-/


noncomputable section

/-- The stereographic x-coordinate. -/
def stereoX' (t : ℚ) : ℚ := (1 - t ^ 2) / (1 + t ^ 2)



/-- The stereographic y-coordinate. -/
def stereoY' (t : ℚ) : ℚ := (2 * t) / (1 + t ^ 2)




/-- Oracle response: The stereographic map sends the "rational addition on the line"
(via the tangent half-angle substitution) to circle multiplication. -/
theorem stereo_homomorphism' (s t : ℚ)
    (hs : 1 + s ^ 2 ≠ 0) (ht : 1 + t ^ 2 ≠ 0) (hst : 1 - s * t ≠ 0) :
    stereoX' ((s + t) / (1 - s * t)) =
    stereoX' s * stereoX' t - stereoY' s * stereoY' t := by
  simp only [stereoX', stereoY']
  field_simp
  ring




/-- The oracle kernel: x ~ y iff O(x) = O(y). -/
def oracleKernel' {X : Type*} (O : X → X) : X → X → Prop :=
  fun x y => O x = O y




/-- Oracle response: The oracle kernel is an equivalence relation. -/
theorem oracle_kernel_equiv' {X : Type*} (O : X → X) :
    Equivalence (oracleKernel' O) where
  refl := fun _ => rfl
  symm := fun h => h.symm
  trans := fun h₁ h₂ => h₁.trans h₂




/-- Each equivalence class contains exactly one truth. -/
theorem oracle_kernel_unique_truth' {X : Type*} (O : X → X) (hO : ∀ x, O (O x) = O x)
    (x y : X) (hxy : oracleKernel' O x y) (hfx : O x = x) (hfy : O y = y) :
    x = y := by
  unfold oracleKernel' at hxy
  rw [hfx, hfy] at hxy; exact hxy




/-- Oracle response: On Fin n, surjective implies bijective. -/
theorem surjective_fin_is_bijective' {n : ℕ} (f : Fin n → Fin n) (hf : Surjective f) :
    Bijective f :=
  ⟨Finite.injective_iff_surjective.mpr hf, hf⟩




/-- Oracle response: Brahmagupta-Fibonacci shows N(z·w) = N(z)·N(w). -/
theorem gaussian_norm_mult' (a b c d : ℤ) :
    (a ^ 2 + b ^ 2) * (c ^ 2 + d ^ 2) =
    (a * c - b * d) ^ 2 + (a * d + b * c) ^ 2 := by ring




/-- The alternative factorization (conjugate). -/
theorem gaussian_norm_mult_alt' (a b c d : ℤ) :
    (a ^ 2 + b ^ 2) * (c ^ 2 + d ^ 2) =
    (a * c + b * d) ^ 2 + (a * d - b * c) ^ 2 := by ring




/-- Both factorizations give the same norm. -/
theorem two_factorizations_same_norm' (a b c d : ℤ) :
    (a * c - b * d) ^ 2 + (a * d + b * c) ^ 2 =
    (a * c + b * d) ^ 2 + (a * d - b * c) ^ 2 := by ring




/-- Every PPT gives a rational rotation. -/
theorem ppt_rotation_det' (a b c : ℚ) (hc : c ≠ 0) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (a / c) ^ 2 + (b / c) ^ 2 = 1 := by
  field_simp; linarith




/-- Composition of PPT rotations is another rotation. -/
theorem ppt_rotation_compose' (a₁ b₁ c₁ a₂ b₂ c₂ : ℚ)
    (h₁ : a₁ ^ 2 + b₁ ^ 2 = c₁ ^ 2) (h₂ : a₂ ^ 2 + b₂ ^ 2 = c₂ ^ 2) :
    (a₁ * a₂ - b₁ * b₂) ^ 2 + (a₁ * b₂ + b₁ * a₂) ^ 2 = (c₁ * c₂) ^ 2 := by
  nlinarith [sq_nonneg a₁, sq_nonneg b₁, sq_nonneg a₂, sq_nonneg b₂]




/-- The Möbius function μ satisfies μ(1) = 1. -/
theorem moebius_at_one' : ArithmeticFunction.moebius 1 = (1 : ℤ) := by
  simp [ArithmeticFunction.moebius]




/-- Binary entropy H(p) = -p log p - (1-p) log (1-p) is non-negative. -/
theorem binary_entropy_nonneg' (p : ℝ) (hp0 : 0 < p) (hp1 : p < 1) :
    0 ≤ -(p * Real.log p + (1 - p) * Real.log (1 - p)) := by
  have h1 : Real.log p ≤ 0 := Real.log_nonpos (le_of_lt hp0) (le_of_lt hp1)
  have h2 : Real.log (1 - p) ≤ 0 := Real.log_nonpos (by linarith) (by linarith)
  nlinarith [mul_nonpos_of_nonneg_of_nonpos (le_of_lt hp0) h1,
             mul_nonpos_of_nonneg_of_nonpos (by linarith : 0 ≤ 1 - p) h2]




/-- The oracle's meta-theorem: O(O) = O. -/
theorem oracle_about_oracle' {X : Type*} (O : X → X) (hO : ∀ x, O (O x) = O x) :
    (fun x => O (O x)) = O :=
  funext hO




/-- The team's combined discovery. -/
theorem life_universe_everything' :
    42 = 2 * 3 * 7 ∧ 42 = 6 * 7 ∧ 42 % 42 = 0 ∧ 0 % 42 = 0 := by
  exact ⟨by norm_num, by norm_num, by norm_num, by norm_num⟩




end