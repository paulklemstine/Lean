import Mathlib

/-!
# Möbius Covariance

The modular group PSL(2,ℤ) acts on the upper half-plane and on ℝ∪{∞}
via Möbius transformations. Key relations:

- S² = -I
- (ST)³ = -I

## Main Results

- `mobius_identity`: The identity Möbius transformation is the identity function.
- `mobius_inversion_involution`: Inversion is an involution on nonzero elements.
- `modular_S_squared`: S² = -I in Mat(2,ℤ).
- `modular_ST_cubed`: (ST)³ = -I in Mat(2,ℤ).
- `sin_int_mul_pi`: sin(nπ) = 0 for integer n (crystallization).
-/

open Matrix Real

section MobiusTransformations

/-- The Möbius transformation f(x) = (ax+b)/(cx+d). -/
noncomputable def mobiusTransform (a b c d x : ℝ) : ℝ := (a * x + b) / (c * x + d)

/-- The identity Möbius transformation sends x to x. -/
theorem mobius_identity (x : ℝ) : mobiusTransform 1 0 0 1 x = x := by
  simp [mobiusTransform]

/-
PROBLEM
Inversion is an involution: 1/(1/x) = x for x ≠ 0.

PROVIDED SOLUTION
Unfold mobiusTransform. The inner application gives (0*x+1)/(1*x+0) = 1/x. The outer gives (0*(1/x)+1)/(1*(1/x)+0) = 1/(1/x) = x. Use field_simp and the hypothesis hx.
-/
theorem mobius_inversion_involution (x : ℝ) (hx : x ≠ 0) :
    mobiusTransform 0 1 1 0 (mobiusTransform 0 1 1 0 x) = x := by
      unfold mobiusTransform; aesop;

end MobiusTransformations

section ModularGroup

/-- The S matrix of the modular group. -/
def modS : Matrix (Fin 2) (Fin 2) ℤ := !![0, -1; 1, 0]

/-- The T matrix of the modular group. -/
def modT : Matrix (Fin 2) (Fin 2) ℤ := !![1, 1; 0, 1]

/-
PROBLEM
S² = -I in the modular group.

PROVIDED SOLUTION
ext i j; fin_cases i <;> fin_cases j <;> simp [modS, Matrix.mul_apply, Fin.sum_univ_two]
-/
theorem modular_S_squared : modS * modS = -1 := by
  native_decide +revert

/-
PROBLEM
(ST)³ = -I in the modular group.

PROVIDED SOLUTION
ext i j; fin_cases i <;> fin_cases j <;> simp [modS, modT, Matrix.mul_apply, Fin.sum_univ_two] <;> ring
-/
theorem modular_ST_cubed : (modS * modT) * (modS * modT) * (modS * modT) = -1 := by
  native_decide +revert

end ModularGroup

section Crystallization

/-
PROBLEM
sin(nπ) = 0 for all integers n — the "crystallization" at integer points.

PROVIDED SOLUTION
Use Int.sin_natCast_mul_pi or similar. Try: rw [mul_comm]; exact Real.sin_int_mul_pi n. Or use Int.cast and sin_int_mul_pi from Mathlib.
-/
theorem sin_int_mul_pi (n : ℤ) : Real.sin (n * Real.pi) = 0 := by
  exact Real.sin_int_mul_pi n

end Crystallization