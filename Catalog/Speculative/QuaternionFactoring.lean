/-! # CatalogBuild.Speculative.QuaternionFactoring

Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 9
-/

import Mathlib

/-- Alternative form of the Euler identity (different sign convention). -/
theorem euler_four_square_identity_alt (a₁ a₂ a₃ a₄ b₁ b₂ b₃ b₄ : ℤ) :
    (a₁^2 + a₂^2 + a₃^2 + a₄^2) * (b₁^2 + b₂^2 + b₃^2 + b₄^2) =
    (a₁*b₁ + a₂*b₂ + a₃*b₃ + a₄*b₄)^2 +
    (a₁*b₂ - a₂*b₁ + a₃*b₄ - a₄*b₃)^2 +
    (a₁*b₃ - a₂*b₄ - a₃*b₁ + a₄*b₂)^2 +
    (a₁*b₄ + a₂*b₃ - a₃*b₂ - a₄*b₁)^2 := by ring




/-- Define the quaternion norm as sum of four squares. -/
def quat_norm (a b c d : ℤ) : ℤ := a^2 + b^2 + c^2 + d^2




/-- Quaternion norm is always nonneg. -/
theorem quat_norm_nonneg (a b c d : ℤ) : 0 ≤ quat_norm a b c d := by
  unfold quat_norm; positivity




/-- Quaternion norm is multiplicative under Hamilton product. -/
theorem quat_norm_mul (a₁ a₂ a₃ a₄ b₁ b₂ b₃ b₄ : ℤ) :
    quat_norm (a₁*b₁ - a₂*b₂ - a₃*b₃ - a₄*b₄)
              (a₁*b₂ + a₂*b₁ + a₃*b₄ - a₄*b₃)
              (a₁*b₃ - a₂*b₄ + a₃*b₁ + a₄*b₂)
              (a₁*b₄ + a₂*b₃ - a₃*b₂ + a₄*b₁) =
    quat_norm a₁ a₂ a₃ a₄ * quat_norm b₁ b₂ b₃ b₄ := by
  unfold quat_norm; ring




/-- [Section: # CatalogBuild.Speculative.QuaternionFactoring
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 9] -/
theorem four_square_hamilton_product (a₁ a₂ a₃ a₄ b₁ b₂ b₃ b₄ : ℤ)
    (h : a₁^2 + a₂^2 + a₃^2 + a₄^2 = b₁^2 + b₂^2 + b₃^2 + b₄^2) :
    (a₁^2 + a₂^2 + a₃^2 + a₄^2)^2 =
    (a₁*b₁ + a₂*b₂ + a₃*b₃ + a₄*b₄)^2 +
    (a₁*b₂ - a₂*b₁ - a₃*b₄ + a₄*b₃)^2 +
    (a₁*b₃ + a₂*b₄ - a₃*b₁ - a₄*b₂)^2 +
    (a₁*b₄ - a₂*b₃ + a₃*b₂ - a₄*b₁)^2 := by
  grind




/-- [Section: # CatalogBuild.Speculative.QuaternionFactoring
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 9] -/
theorem four_squares_zero (a b c d : ℤ)
    (h : a^2 + b^2 + c^2 + d^2 = 0) : a = 0 ∧ b = 0 ∧ c = 0 ∧ d = 0 := by
  exact ⟨ by nlinarith, by nlinarith, by nlinarith, by nlinarith ⟩




theorem quaternion_factor_criterion (N g : ℕ) (hN : 1 < N)
    (hg_dvd : g ∣ N) (hg_gt : 1 < g) (hg_lt : g < N) :
    ∃ k : ℕ, N = g * k ∧ 1 < k ∧ k < N := by
  exact Exists.elim hg_dvd fun k hk => ⟨ k, hk, by nlinarith, by nlinarith ⟩




theorem four_square_multiple_reps (N : ℕ) (hN : 5 ≤ N) :
    ∃ a₁ a₂ a₃ a₄ b₁ b₂ b₃ b₄ : ℕ,
      a₁^2 + a₂^2 + a₃^2 + a₄^2 = N ∧
      b₁^2 + b₂^2 + b₃^2 + b₄^2 = N ∧
      (a₁, a₂, a₃, a₄) ≠ (b₁, b₂, b₃, b₄) := by
  -- By Lagrange's four-square theorem, there exist integers $a₁$, $a₂$, $a₃$, and $a₄$ such that $N = a₁^2 + a₂^2 + a₃^2 + a₄^2$.
  obtain ⟨a₁, a₂, a₃, a₄, ha⟩ : ∃ a₁ a₂ a₃ a₄ : ℕ, N = a₁^2 + a₂^2 + a₃^2 + a₄^2 := by
    have := Nat.sum_four_squares N; tauto;
  by_contra h_contra;
  simp +zetaDelta at *;
  have := h_contra a₁ a₂ a₃ a₄ ha.symm a₂ a₁ a₃ a₄ ?_ <;> try linarith;
  have := h_contra a₁ a₂ a₃ a₄ ha.symm a₄ a₃ a₂ a₁ ?_ <;> try linarith;
  norm_num [ show a₁ = a₂ by linarith, show a₂ = a₃ by linarith, show a₃ = a₄ by linarith ] at *;
  have := h_contra a₄ a₄ a₄ a₄ ( by linarith ) 0 0 0 ( 2 * a₄ ) ( by linarith ) ; norm_num at this ; linarith [ show a₄ > 0 from Nat.pos_of_ne_zero ( by rintro rfl; linarith ) ] ;




/-- Euler's identity gives two different 4-square decompositions of a product. -/
theorem euler_two_decompositions (a₁ a₂ a₃ a₄ b₁ b₂ b₃ b₄ : ℤ) :
    (a₁^2 + a₂^2 + a₃^2 + a₄^2) * (b₁^2 + b₂^2 + b₃^2 + b₄^2) =
    (a₁*b₁ - a₂*b₂ - a₃*b₃ - a₄*b₄)^2 +
    (a₁*b₂ + a₂*b₁ + a₃*b₄ - a₄*b₃)^2 +
    (a₁*b₃ - a₂*b₄ + a₃*b₁ + a₄*b₂)^2 +
    (a₁*b₄ + a₂*b₃ - a₃*b₂ + a₄*b₁)^2 ∧
    (a₁^2 + a₂^2 + a₃^2 + a₄^2) * (b₁^2 + b₂^2 + b₃^2 + b₄^2) =
    (a₁*b₁ + a₂*b₂ + a₃*b₃ + a₄*b₄)^2 +
    (a₁*b₂ - a₂*b₁ + a₃*b₄ - a₄*b₃)^2 +
    (a₁*b₃ - a₂*b₄ - a₃*b₁ + a₄*b₂)^2 +
    (a₁*b₄ + a₂*b₃ - a₃*b₂ - a₄*b₁)^2 := by
  exact ⟨by ring, by ring⟩


