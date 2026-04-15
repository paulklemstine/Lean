/-! # CatalogBuild.EML.Applications

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 16
-/

import Mathlib

noncomputable section

/-- Einstein's velocity addition formula (with c = 1). -/
def einsteinVelocityAdd (v₁ v₂ : ℝ) : ℝ := (v₁ + v₂) / (1 + v₁ * v₂)


/-- Einstein velocity addition is commutative. -/
theorem einstein_comm (v₁ v₂ : ℝ) :
    einsteinVelocityAdd v₁ v₂ = einsteinVelocityAdd v₂ v₁ := by
  simp [einsteinVelocityAdd, add_comm, mul_comm]


/-- Zero velocity is the identity. -/
theorem einstein_zero (v : ℝ) : einsteinVelocityAdd v 0 = v := by
  simp [einsteinVelocityAdd]


/-- Velocity and its negative cancel. -/
theorem einstein_neg (v : ℝ) : einsteinVelocityAdd v (-v) = 0 := by
  simp [einsteinVelocityAdd]


/-- Einstein velocity addition is associative. -/
theorem einstein_assoc (u v w : ℝ) (h1 : 1 + u * v ≠ 0) (h2 : 1 + v * w ≠ 0)
    (h3 : 1 + einsteinVelocityAdd u v * w ≠ 0)
    (h4 : 1 + u * einsteinVelocityAdd v w ≠ 0) :
    einsteinVelocityAdd (einsteinVelocityAdd u v) w =
    einsteinVelocityAdd u (einsteinVelocityAdd v w) := by
  simp only [einsteinVelocityAdd]
  field_simp
  ring


/-- The speed of light (v = 1) is invariant: 1 ⊕ v = 1 for any v with 1+v ≠ 0. -/
theorem einstein_light_invariance (v : ℝ) (hv : 1 + v ≠ 0) :
    einsteinVelocityAdd 1 v = 1 := by
  simp only [einsteinVelocityAdd]
  have : 1 + 1 * v = 1 + v := by ring
  rw [this]
  exact div_self hv


/-- [Section: ## 1. Relativistic Velocity Addition] -/
theorem einstein_subluminal (v₁ v₂ : ℝ) (h1 : |v₁| < 1) (h2 : |v₂| < 1) :
    |einsteinVelocityAdd v₁ v₂| < 1 := by
  rw [ abs_lt ] at *;
  exact ⟨ by rw [ einsteinVelocityAdd ] ; rw [ lt_div_iff₀ ] <;> nlinarith, by rw [ einsteinVelocityAdd ] ; rw [ div_lt_iff₀ ] <;> nlinarith ⟩


/-- A Möbius transformation of the form (az + b)/(cz + d). -/
def mobiusTransform (a b c d : ℂ) (z : ℂ) : ℂ := (a * z + b) / (c * z + d)


/-- SPB as a Möbius transformation: for fixed y, spb(·, y) is
the Möbius transformation z ↦ (z + y)/(-yz + 1). -/
theorem spb_is_mobius (x y : ℂ) :
    (x + y) / (1 - x * y) = mobiusTransform 1 y (-y) 1 x := by
  simp [mobiusTransform]; ring


/-- The Cayley transform is the Möbius transformation with a=1, b=-i, c=1, d=i. -/
theorem cayley_is_mobius (z : ℂ) :
    (z - I) / (z + I) = mobiusTransform 1 (-I) 1 I z := by
  simp [mobiusTransform]; ring


/-- The cross-ratio of four points, a Möbius-invariant quantity. -/
def crossRatio (z₁ z₂ z₃ z₄ : ℂ) : ℂ :=
  ((z₁ - z₃) * (z₂ - z₄)) / ((z₁ - z₄) * (z₂ - z₃))


/-- [Section: ## 2. Möbius Transformations] -/
theorem crossRatio_mobius_invariant (a b c d : ℂ) (hdet : a * d - b * c ≠ 0)
    (z₁ z₂ z₃ z₄ : ℂ) (h1 : c * z₁ + d ≠ 0) (h2 : c * z₂ + d ≠ 0)
    (h3 : c * z₃ + d ≠ 0) (h4 : c * z₄ + d ≠ 0) :
    crossRatio (mobiusTransform a b c d z₁) (mobiusTransform a b c d z₂)
               (mobiusTransform a b c d z₃) (mobiusTransform a b c d z₄)
    = crossRatio z₁ z₂ z₃ z₄ := by
  unfold crossRatio mobiusTransform;
  field_simp;
  rw [ div_sub', div_sub' ];
  · convert mul_div_mul_right _ _ ( show ( a * d - b * c ) ^ 2 ≠ 0 from pow_ne_zero 2 hdet ) using 1 ; ring;
    field_simp;
    rw [ mul_div_mul_left _ _ ( by contrapose! h1; linear_combination' h1 ) ];
  · rwa [ mul_comm ];
  · rwa [ mul_comm ]


/-- In the Poincaré disk model, "hyperbolic translation" by a real a is Einstein addition. -/
theorem poincare_translation_real (a z : ℝ) :
    einsteinVelocityAdd z a = (z + a) / (1 + a * z) := by
  simp [einsteinVelocityAdd, mul_comm]


/-- n-fold SPB iteration. -/
def spbPow (x : ℝ) : ℕ → ℝ
  | 0 => 0
  | n + 1 => (x + spbPow x n) / (1 - x * spbPow x n)


/-- 1-fold SPB is identity. -/
theorem spbPow_one (x : ℝ) : spbPow x 1 = x := by
  simp [spbPow]


/-- 2-fold SPB is the double-angle formula. -/
theorem spbPow_two (x : ℝ) :
    spbPow x 2 = 2 * x / (1 - x * x) := by
  simp [spbPow]; ring


end
