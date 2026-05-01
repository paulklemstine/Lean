import Mathlib

/-! # CatalogBuild.Tropical.Core.TropicalAlphabetAdvanced

Auto-generated from theorem catalog database.
Domain: Tropical/Core
Declarations: 15
-/

noncomputable section

/-- exp is a homomorphism: it maps tropical multiplication (classical +)
to classical multiplication. -/
theorem exp_trop_mul_hom (a b : ℝ) :
    Real.exp (a + b) = Real.exp a * Real.exp b :=
  Real.exp_add a b

/-- exp maps tropical additive identity (0 in max-plus) to classical 1 -/
theorem exp_trop_one : Real.exp 0 = 1 :=
  Real.exp_zero

/-- Right distributivity: min(b, c) + a = min(b + a, c + a) -/
theorem trop_distrib_right (a b c : ℝ) :
    min b c + a = min (b + a) (c + a) := by
  simp [min_def]; split_ifs <;> linarith

/-- Tropical multiplication preserves the tropical order (≤ is ≥ classically) -/
theorem trop_mul_mono_left {a b : ℝ} (hab : a ≤ b) (c : ℝ) :
    a + c ≤ b + c := by linarith

/-- The tropical "distance" satisfies the tropical triangle inequality -/
theorem trop_triangle (a b c : ℝ) :
    (a - c) ≤ (a - b) + (b - c) := by ring_nf; linarith

/-- Tropical division is the additive inverse of tropical multiplication -/
theorem trop_div_cancel (a b : ℝ) : (a + b) - b = a := by ring

/-- The tropical semiring satisfies all semiring axioms except additive cancellation -/
theorem trop_semiring_comm : ∀ a b : ℝ, min a b = min b a := min_comm

/-- [Section: # CatalogBuild.Tropical.Core.TropicalAlphabetAdvanced
Auto-generated from theorem catalog database.
Domain: Tropical/Core
Declarations: 15] -/
theorem trop_semiring_assoc : ∀ a b c : ℝ, min (min a b) c = min a (min b c) :=
  fun a b c => min_assoc a b c

/-- [Section: # CatalogBuild.Tropical.Core.TropicalAlphabetAdvanced
Auto-generated from theorem catalog database.
Domain: Tropical/Core
Declarations: 15] -/
theorem trop_semiring_idem : ∀ a : ℝ, min a a = a := min_self

theorem trop_semiring_distrib : ∀ a b c : ℝ, a + min b c = min (a + b) (a + c) :=
  fun a b c => by simp [min_def]; split_ifs <;> linarith

/-- For 2 terms, LogSumExp lower bound -/
theorem lse_ge_max' (a b : ℝ) :
    max a b ≤ Real.log (Real.exp a + Real.exp b) := by
  rcases le_total a b with hab | hab
  · rw [max_eq_right hab]
    calc b = Real.log (Real.exp b) := (Real.log_exp b).symm
      _ ≤ Real.log (Real.exp a + Real.exp b) := by
          apply Real.log_le_log (Real.exp_pos b)
          linarith [Real.exp_nonneg a]
  · rw [max_eq_left hab]
    calc a = Real.log (Real.exp a) := (Real.log_exp a).symm
      _ ≤ Real.log (Real.exp a + Real.exp b) := by
          apply Real.log_le_log (Real.exp_pos a)
          linarith [Real.exp_nonneg b]

/-- Tropical scaling by a positive integer is classical multiplication -/
theorem trop_nsmul_eq_mul (n : ℕ) (a : ℝ) : n • a = (n : ℝ) * a := by
  simp [nsmul_eq_mul]

/-- The tropical semiring is zerosumfree: a + b = 0 implies a = 0 and b = 0
(using 0 as tropical multiplicative identity) when a, b ≥ 0 -/
theorem trop_zerosumfree {a b : ℝ} (ha : 0 ≤ a) (hb : 0 ≤ b)
    (hab : a + b = 0) : a = 0 ∧ b = 0 := by
  constructor <;> linarith

theorem min3_concave (a₁ b₁ a₂ b₂ a₃ b₃ : ℝ) (t : ℝ)
    (ht0 : 0 ≤ t) (ht1 : t ≤ 1) (x y : ℝ) :
    min (min (a₁ + b₁ * (t * x + (1 - t) * y)) (a₂ + b₂ * (t * x + (1 - t) * y)))
        (a₃ + b₃ * (t * x + (1 - t) * y)) ≥
    t * min (min (a₁ + b₁ * x) (a₂ + b₂ * x)) (a₃ + b₃ * x) +
    (1 - t) * min (min (a₁ + b₁ * y) (a₂ + b₂ * y)) (a₃ + b₃ * y) := by
  simp +decide [ min_def ] at *;
  split_ifs <;> nlinarith

theorem trop_matmul_assoc_2x2
    (a₁₁ a₁₂ a₂₁ a₂₂ b₁₁ b₁₂ b₂₁ b₂₂ c₁₁ c₁₂ c₂₁ c₂₂ : ℝ) :
    -- ((A⊗B)⊗C)₁₁ = (A⊗(B⊗C))₁₁
    min (min (a₁₁ + b₁₁) (a₁₂ + b₂₁) + c₁₁)
        (min (a₁₁ + b₁₂) (a₁₂ + b₂₂) + c₂₁) =
    min (a₁₁ + min (b₁₁ + c₁₁) (b₁₂ + c₂₁))
        (a₁₂ + min (b₂₁ + c₁₁) (b₂₂ + c₂₁)) := by
  grind +splitIndPred

end