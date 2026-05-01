/-! # CatalogBuild.Tropical.TropicalSemiring

Auto-generated from theorem catalog database.
Domain: Tropical
Declarations: 10
-/

import Mathlib

noncomputable section

/-- Tropical addition selects the smaller element:
`a ⊕ b = a` iff `a ≤ b` in the underlying order. -/
theorem tropical_add_eq_left_iff {R : Type*} [LinearOrder R]
    (a b : Tropical R) :
    a + b = a ↔ Tropical.untrop a ≤ Tropical.untrop b := by
  rw [Tropical.trop_add_def]
  constructor
  · intro h
    have h2 := congr_arg Tropical.untrop h
    simp only [Tropical.untrop_trop] at h2
    exact min_eq_left_iff.mp h2
  · intro h; rw [min_eq_left h, Tropical.trop_untrop]


/-- Powers in the tropical semiring correspond to scalar multiplication:
`trop(a)^n = trop(n • a)`. -/
theorem tropical_pow_nsmul {R : Type*} [AddMonoid R]
    (a : R) (n : ℕ) :
    (Tropical.trop a) ^ n = Tropical.trop (n • a) :=
  (Tropical.trop_nsmul a n).symm


/-- [Section: ## Section 1: Idempotent Semiring Structure] -/
theorem tropical_add_pow_distrib {R : Type*} [LinearOrder R] [AddMonoid R]
    [CovariantClass R R (· + ·) (· ≤ ·)]
    [CovariantClass R R (Function.swap (· + ·)) (· ≤ ·)]
    (a b : Tropical R) (n : ℕ) :
    (a + b) ^ n = a ^ n + b ^ n := by
      exact?


/-- Tropical multiplication distributes over tropical addition. -/
theorem tropical_mul_add_distrib {R : Type*} [LinearOrder R] [Add R]
    [CovariantClass R R (· + ·) (· ≤ ·)]
    [CovariantClass R R (Function.swap (· + ·)) (· ≤ ·)]
    (a b c : Tropical R) :
    a * (b + c) = a * b + a * c := by
  simp only [Tropical.trop_mul_def, Tropical.trop_add_def, Tropical.untrop_trop]
  congr 1
  exact (min_add_add_left (Tropical.untrop a) (Tropical.untrop b) (Tropical.untrop c)).symm


/-- Zero in the tropical semiring is ⊤ (infinity). -/
theorem tropical_zero_eq_top :
    (0 : Tropical (WithTop ℕ)) = Tropical.trop ⊤ := by rfl


/-- One in the tropical semiring is 0. -/
theorem tropical_one_eq_zero :
    (1 : Tropical (WithTop ℕ)) = Tropical.trop 0 := by rfl


/-- A tropical linear combination equals the minimum of shifted values. -/
theorem tropical_lin_comb {R : Type*} [LinearOrder R] [AddCommMonoid R]
    [CovariantClass R R (· + ·) (· ≤ ·)]
    [CovariantClass R R (Function.swap (· + ·)) (· ≤ ·)]
    (c₁ c₂ a b : R) :
    Tropical.untrop (Tropical.trop c₁ * Tropical.trop a +
                     Tropical.trop c₂ * Tropical.trop b) =
    min (c₁ + a) (c₂ + b) := by
  simp only [Tropical.trop_mul_def, Tropical.trop_add_def,
             Tropical.untrop_trop]


/-- The tropical determinant of a 2×2 matrix: min(a+d, b+c). -/
noncomputable def tropDet2 {R : Type*} [LinearOrder R] [Add R]
    (a b c d : R) : R :=
  min (a + d) (b + c)


/-- The tropical determinant is invariant under transposition. -/
theorem tropDet2_transpose {R : Type*} [LinearOrder R] [AddCommMonoid R]
    (a b c d : R) :
    tropDet2 a b c d = tropDet2 a c b d := by
  simp [tropDet2, add_comm b c]


/-- For a 2×2 diagonal tropical matrix over WithTop,
the determinant equals the sum of diagonal entries. -/
theorem tropDet2_diagonal_top (a d : WithTop ℕ) :
    tropDet2 a ⊤ ⊤ d = a + d := by
  unfold tropDet2
  simp


end
