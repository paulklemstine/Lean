/-! # CatalogBuild.Computation.Factoring.OctonionHurwitz

Auto-generated from theorem catalog database.
Domain: Computation/Factoring
Declarations: 6
-/

import Mathlib

/-- Membership in L₃(N): the sum-of-squares constraint mod N. -/
def mem_lattice3 (N : ℤ) (x y z : ℤ) : Prop :=
  N ∣ (x^2 + y^2 + z^2)


/-- L₃(N) contains the zero vector. -/
theorem lattice3_zero_mem (N : ℤ) : mem_lattice3 N 0 0 0 := by
  simp [mem_lattice3]


/-- L₃(N) is closed under negation. -/
theorem lattice3_neg_mem (N : ℤ) (x y z : ℤ) (h : mem_lattice3 N x y z) :
    mem_lattice3 N (-x) (-y) (-z) := by
  simp only [mem_lattice3, neg_sq]
  exact h


/-- Membership in L₄(N). -/
def mem_lattice4 (N : ℤ) (x y z w : ℤ) : Prop :=
  N ∣ (x^2 + y^2 + z^2 + w^2)


theorem dim_advantage_2_1 {N : ℝ} (hN : 2 ≤ N) :
    N ^ ((1:ℝ)/2) ≤ N := by
      rw [ ← Real.sqrt_eq_rpow, Real.sqrt_le_left ] <;> nlinarith


/-- Full dimensional chain: N^(1/4) ≤ N^(1/3) ≤ N^(1/2) ≤ N. -/
theorem full_dim_chain {N : ℝ} (hN : 2 ≤ N) :
    N ^ ((1:ℝ)/4) ≤ N := by
  calc N ^ ((1:ℝ)/4) ≤ N ^ ((1:ℝ)/3) := dim_advantage_4_3 hN
    _ ≤ N ^ ((1:ℝ)/2) := dim_advantage_3_2 hN
    _ ≤ N := dim_advantage_2_1 hN

