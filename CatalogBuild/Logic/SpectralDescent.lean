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

/-
PROBLEM
n = 2 or n = 3

**Theorem (Spectral Gap)**: Gaussian norms are never ≡ 3 (mod 4).
    Proof: a² ≡ 0 or 1 (mod 4), so a² + b² ∈ {0, 1, 2} (mod 4).

PROVIDED SOLUTION
Case split on a % 2 and b % 2 (4 cases). In each case, substitute a = 2k or a = 2k+1 (similarly for b), expand, and show the result mod 4. Use have ha := Int.emod_two_eq_zero_or_one a, etc. Or use ZMod or Int.emod_emod_of_dvd.
-/

theorem gauss_norm_mod_four (a b : ℤ) :
    (a^2 + b^2) % 4 = 0 ∨ (a^2 + b^2) % 4 = 1 ∨ (a^2 + b^2) % 4 = 2 := by
  rcases Int.even_or_odd' a with ⟨ a, rfl | rfl ⟩ <;> rcases Int.even_or_odd' b with ⟨ b, rfl | rfl ⟩ <;> ring_nf <;> norm_num

/-! ## The Conformal Factor -/

/-- The conformal factor of stereographic projection: κ(t) = 4/(1+t²)² -/

theorem conformal_pos (t : ℝ) : conformalFactor t > 0 := by
  unfold conformalFactor; positivity

/-
PROBLEM
**Theorem**: The conformal factor is maximized at t = 0. κ(t) ≤ 4 for all t.

PROVIDED SOLUTION
4/(1+t²)² ≤ 4 iff 1 ≤ (1+t²)². Since t² ≥ 0, 1+t² ≥ 1, so (1+t²)² ≥ 1. Use div_le_iff with positivity for denominator, then nlinarith.
-/

theorem conformal_max (t : ℝ) : conformalFactor t ≤ 4 := by
  exact div_le_self ( by norm_num ) ( by nlinarith )

/-- **Theorem**: κ(t) · (1+t²)² = 4. The conformal factor and its denominator cancel. -/

theorem conformal_integral_is_area :
    ∀ (t : ℝ), conformalFactor t * (1 + t^2)^2 = 4 := by
  intro t; unfold conformalFactor
  field_simp

/-! ## Roots of Unity and the Descent -/

/-- **Theorem**: The identity (1,0) is a Gaussian integer on S¹. -/

theorem unit_gaussian_on_circle : (1 : ℤ)^2 + (0 : ℤ)^2 = 1 := by norm_num

/-- **Theorem**: (0,1) is a Gaussian integer on S¹. -/

theorem imag_unit_on_circle : (0 : ℤ)^2 + (1 : ℤ)^2 = 1 := by norm_num

/-! ## Oracle Structure of the Descent -/

/-- An oracle at each level of the descent, projecting Fin (k+2) → Fin (k+1). -/

def descentOracle (k : ℕ) : (Fin (k+2) → ℝ) → (Fin (k+1) → ℝ) :=
  fun v => fun i => v ⟨i.val, by omega⟩

/-- **Theorem**: Composing descent oracles gives the full projection. -/

theorem descent_composition (k : ℕ) (v : Fin (k+3) → ℝ) :
    descentOracle k (descentOracle (k+1) v) = fun i => v ⟨i.val, by omega⟩ := by
  ext i; simp [descentOracle]
