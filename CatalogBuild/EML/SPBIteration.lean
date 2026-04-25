/-! # CatalogBuild.EML.SPBIteration

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 14
-/

import Mathlib

noncomputable section

/-- n-fold SPB iteration: spbN(x, 0) = 0, spbN(x, n+1) = spb(x, spbN(x, n)). -/
def spbN (x : ℝ) : ℕ → ℝ
  | 0 => 0
  | n + 1 => spbOp x (spbN x n)


/-- [Section: # CatalogBuild.EML.SPBIteration
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 14] -/
theorem spbN_zero (x : ℝ) : spbN x 0 = 0 := rfl


/-- [Section: # CatalogBuild.EML.SPBIteration
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 14] -/
theorem spbN_succ (x : ℝ) (n : ℕ) : spbN x (n + 1) = spbOp x (spbN x n) := rfl


/-- [Section: # CatalogBuild.EML.SPBIteration
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 14] -/
theorem spbN_one (x : ℝ) : spbN x 1 = x := by simp [spbN, spbOp]


theorem spbN_two (x : ℝ) : spbN x 2 = 2 * x / (1 - x ^ 2) := by
  simp [spbN, spbOp]; ring


/-- The tangent addition law as SPB. -/
theorem tan_add_eq_spbOp (α β : ℝ) (hα : cos α ≠ 0) (hβ : cos β ≠ 0) :
    tan (α + β) = spbOp (tan α) (tan β) := by
  rw [spbOp, tan_eq_sin_div_cos, sin_add, cos_add,
      tan_eq_sin_div_cos, tan_eq_sin_div_cos]
  field_simp


theorem spbN_tan (θ : ℝ) (n : ℕ) (hcos : ∀ k : ℕ, k ≤ n → cos (k * θ) ≠ 0) :
    spbN (tan θ) n = tan (n * θ) := by
  induction' n with n ih;
  · aesop;
  · rw [ Nat.cast_succ, add_mul, one_mul, tan_add_eq_spbOp, spbN_succ ];
    · rw [ ih fun k hk => hcos k ( by linarith ), spbOp ];
      unfold spbOp; ring;
    · exact hcos n n.le_succ;
    · simpa using hcos 1 ( by norm_num )


/-- SPB iteration of 0 is always 0. -/
theorem spbN_zero_fixed (n : ℕ) : spbN 0 n = 0 := by
  induction n with
  | zero => rfl
  | succ n ih => simp [spbN, spbOp, ih]


/-- The double angle via SPB: spbOp(tan θ, tan θ) = tan(2θ). -/
theorem spbOp_tan_double (θ : ℝ) (hc : cos θ ≠ 0) :
    spbOp (tan θ) (tan θ) = tan (2 * θ) := by
  rw [show (2 : ℝ) * θ = θ + θ from by ring]
  exact (tan_add_eq_spbOp θ θ hc hc).symm


/-- The triple angle via SPB. -/
theorem spbOp_tan_triple (θ : ℝ) (hc : cos θ ≠ 0) (hc2 : cos (2 * θ) ≠ 0) :
    spbOp (tan θ) (spbOp (tan θ) (tan θ)) = tan (3 * θ) := by
  rw [spbOp_tan_double θ hc]
  rw [show (3 : ℝ) * θ = θ + 2 * θ from by ring]
  exact (tan_add_eq_spbOp θ (2 * θ) hc hc2).symm


theorem spbN_tan_add (θ : ℝ) (m n : ℕ)
    (hcos : ∀ k : ℕ, k ≤ m + n → cos (k * θ) ≠ 0) :
    spbN (tan θ) (m + n) = spbOp (spbN (tan θ) m) (spbN (tan θ) n) := by
  rw [spbN_tan, spbN_tan, spbN_tan];
  · rw [ ← tan_add_eq_spbOp ] <;> norm_num [ add_mul ];
    · exact hcos m ( Nat.le_add_right _ _ );
    · exact hcos n ( Nat.le_add_left _ _ );
  · exact fun k hk => hcos k <| le_trans hk <| Nat.le_add_left _ _;
  · exact fun k hk => hcos k <| le_trans hk <| Nat.le_add_right _ _;
  · assumption


/-- The Cauchy density function: f(x) = 1/(π(1+x²)). -/
def cauchyDensity (x : ℝ) : ℝ := 1 / (Real.pi * (1 + x ^ 2))


theorem cauchyDensity_pos (x : ℝ) : cauchyDensity x > 0 := by
  exact one_div_pos.mpr ( mul_pos Real.pi_pos ( by positivity ) )


/-- The Cauchy density is symmetric. -/
theorem cauchyDensity_symm (x : ℝ) : cauchyDensity x = cauchyDensity (-x) := by
  simp [cauchyDensity]


end
