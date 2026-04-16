/-! # CatalogBuild.Logic.SpectralDescent

Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 10
-/

import Mathlib

/-- In the monster tower, curves at level k are classified as R, V, or T. -/
inductive RVT where
  | R : RVT  -- Regular
  | V : RVT  -- Vertical
  | T : RVT  -- Tangent
deriving DecidableEq, Repr



/-- Assign an RVT class to a Gaussian integer based on its norm mod 4. -/
def gaussianRVT (a b : ℤ) : RVT :=
  let n := (a^2 + b^2) % 4
  if n = 1 then RVT.R
  else if n = 0 then RVT.V
  else RVT.T



/-- [Section: # CatalogBuild.Logic.SpectralDescent
Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 10] -/
theorem gauss_norm_mod_four (a b : ℤ) :
    (a^2 + b^2) % 4 = 0 ∨ (a^2 + b^2) % 4 = 1 ∨ (a^2 + b^2) % 4 = 2 := by
  rcases Int.even_or_odd' a with ⟨ a, rfl | rfl ⟩ <;> rcases Int.even_or_odd' b with ⟨ b, rfl | rfl ⟩ <;> ring_nf <;> norm_num



/-- **Theorem**: The conformal factor is always positive -/
theorem conformal_pos (t : ℝ) : conformalFactor t > 0 := by
  unfold conformalFactor; positivity



theorem conformal_max (t : ℝ) : conformalFactor t ≤ 4 := by
  exact div_le_self ( by norm_num ) ( by nlinarith )



/-- **Theorem**: κ(t) · (1+t²)² = 4. The conformal factor and its denominator cancel. -/
theorem conformal_integral_is_area :
    ∀ (t : ℝ), conformalFactor t * (1 + t^2)^2 = 4 := by
  intro t; unfold conformalFactor
  field_simp



/-- **Theorem**: The identity (1,0) is a Gaussian integer on S¹. -/
theorem unit_gaussian_on_circle : (1 : ℤ)^2 + (0 : ℤ)^2 = 1 := by norm_num



/-- **Theorem**: (0,1) is a Gaussian integer on S¹. -/
theorem imag_unit_on_circle : (0 : ℤ)^2 + (1 : ℤ)^2 = 1 := by norm_num



/-- An oracle at each level of the descent, projecting Fin (k+2) → Fin (k+1). -/
def descentOracle (k : ℕ) : (Fin (k+2) → ℝ) → (Fin (k+1) → ℝ) :=
  fun v => fun i => v ⟨i.val, by omega⟩



/-- **Theorem**: Composing descent oracles gives the full projection. -/
theorem descent_composition (k : ℕ) (v : Fin (k+3) → ℝ) :
    descentOracle k (descentOracle (k+1) v) = fun i => v ⟨i.val, by omega⟩ := by
  ext i; simp [descentOracle]

