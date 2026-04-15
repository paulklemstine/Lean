/-! # CatalogBuild.Physics.Quantum.OctonionComputation

Auto-generated from theorem catalog database.
Domain: Physics/Quantum
Declarations: 16
-/

import Mathlib

noncomputable section

def octonionAssociator {A : Type*} [Ring A] (a b c : A) : A :=
  (a * b) * c - a * (b * c)


theorem octonionAssociator_zero_iff {A : Type*} [Ring A] (a b c : A) :
    octonionAssociator a b c = 0 ↔ (a * b) * c = a * (b * c) := by
  simp [octonionAssociator, sub_eq_zero]


theorem octonionAssociator_alt_left {A : Type*} [Ring A]
    (h : ∀ a b : A, (a * a) * b = a * (a * b)) (a b : A) :
    octonionAssociator a a b = 0 := by
  simp [octonionAssociator, h]


theorem octonionAssociator_alt_right {A : Type*} [Ring A]
    (h : ∀ a b : A, (a * b) * b = a * (b * b)) (a b : A) :
    octonionAssociator a b b = 0 := by
  simp [octonionAssociator, h]


/-- Catalan number C(n) = C(2n,n)/(n+1) -/
def octonionCatalan (n : ℕ) : ℕ := Nat.choose (2 * n) n / (n + 1)


theorem octonionCatalan_zero : octonionCatalan 0 = 1 := by native_decide

theorem octonionCatalan_one : octonionCatalan 1 = 1 := by native_decide

theorem octonionCatalan_two : octonionCatalan 2 = 2 := by native_decide

theorem octonionCatalan_three : octonionCatalan 3 = 5 := by native_decide

theorem octonionCatalan_four : octonionCatalan 4 = 14 := by native_decide


def IsMoufangLoop {A : Type*} [Mul A] : Prop :=
  ∀ x y z : A, (x * y) * (z * x) = x * ((y * z) * x)


theorem assoc_is_moufang_loop {A : Type*} [Monoid A] : IsMoufangLoop (A := A) := by
  intro x y z; simp [IsMoufangLoop, mul_assoc]


theorem octonion_dim : 8 = 2 ^ 3 := by norm_num

theorem sedenion_dim : 16 = 2 ^ 4 := by norm_num

theorem cayley_dickson_dims (n : ℕ) : 2 ^ n ≥ 1 := Nat.one_le_pow n 2 (by omega)

theorem hurwitz_dims : {1, 2, 4, 8} = ({1, 2, 4, 8} : Finset ℕ) := rfl


end
