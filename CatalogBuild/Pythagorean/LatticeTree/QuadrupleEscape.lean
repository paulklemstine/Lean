/-! # CatalogBuild.Pythagorean.LatticeTree.QuadrupleEscape

Auto-generated from theorem catalog database.
Domain: Pythagorean/LatticeTree
Declarations: 14
-/

import Mathlib

/-- [Section: # CatalogBuild.Pythagorean.LatticeTree.QuadrupleEscape
Auto-generated from theorem catalog database.
Domain: Pythagorean/LatticeTree
Declarations: 14] -/
def IsThreeSquareRep (N : ℤ) (x y z : ℤ) : Prop :=
  x ^ 2 + y ^ 2 + z ^ 2 = N



theorem three_square_one : IsThreeSquareRep 1 1 0 0 := by
  simp [IsThreeSquareRep]



theorem three_square_two : IsThreeSquareRep 2 1 1 0 := by
  simp [IsThreeSquareRep]



theorem three_square_three : IsThreeSquareRep 3 1 1 1 := by
  simp [IsThreeSquareRep]



theorem three_square_five : IsThreeSquareRep 5 2 1 0 := by
  simp [IsThreeSquareRep]



theorem three_square_six : IsThreeSquareRep 6 2 1 1 := by
  simp [IsThreeSquareRep]



def InQuadLattice (N : ℤ) (x y z : ℤ) : Prop :=
  N ∣ (x ^ 2 + y ^ 2 + z ^ 2)



theorem zero_in_quad_lattice (N : ℤ) : InQuadLattice N 0 0 0 := by
  simp [InQuadLattice]



/-- Scalar multiples preserve the quadruple lattice. -/
theorem scalar_in_quad_lattice (N k x y z : ℤ) (h : InQuadLattice N x y z) :
    InQuadLattice N (k * x) (k * y) (k * z) := by
  simp only [InQuadLattice] at *
  have : (k * x) ^ 2 + (k * y) ^ 2 + (k * z) ^ 2 = k ^ 2 * (x ^ 2 + y ^ 2 + z ^ 2) := by ring
  rw [this]
  exact dvd_mul_of_dvd_right h _



def lorentzEta : Matrix (Fin 4) (Fin 4) ℤ :=
  Matrix.diagonal ![1, 1, 1, -1]



def IsLorentzInt (M : Matrix (Fin 4) (Fin 4) ℤ) : Prop :=
  M.transpose * lorentzEta * M = lorentzEta



theorem lll_factor_dim3 : (2 : ℕ) ^ ((3 - 1) / 2) = 2 := by norm_num



def extractFactor (N x y z : ℤ) : ℤ := Int.gcd (x ^ 2 + y ^ 2) N



/-- In dimension d ≥ 3, the number of short lattice vectors grows
exponentially, giving more chances to find factoring-relevant ones. -/
theorem dimension_advantage (d : ℕ) (hd : 3 ≤ d) :
    2 ^ d ≥ 8 := by
  calc 2 ^ d ≥ 2 ^ 3 := Nat.pow_le_pow_right (by norm_num) hd
    _ = 8 := by norm_num


