/-! # CatalogBuild.Speculative.Other.FrontierResearch

Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 24
-/

import Mathlib

/-- The Minkowski metric η = diag(-1, -1, 1) for the (2,1) signature. -/
def η : Matrix (Fin 3) (Fin 3) ℤ := !![-1, 0, 0; 0, -1, 0; 0, 0, 1]




/-- B₁ has determinant 1 (proper Lorentz transformation). -/
theorem B1_det : B₁'.det = 1 := by native_decide




/-- B₂ has determinant -1 (improper Lorentz transformation / reflection). -/
theorem B2_det : B₂'.det = -1 := by native_decide




/-- B₃ has determinant 1 (proper Lorentz transformation). -/
theorem B3_det : B₃'.det = 1 := by native_decide




/-- Every odd prime is either bright or dark. -/
theorem prime_bright_or_dark (p : ℕ) (hp : Nat.Prime p) (hodd : p ≠ 2) :
    isBrightPrime p ∨ isDarkPrime p := by
  unfold isBrightPrime isDarkPrime
  have h2 : 2 ≤ p := hp.two_le
  have hmod : p % 4 = 1 ∨ p % 4 = 3 := by
    have : p % 2 = 1 := by
      have := hp.odd_of_ne_two hodd
      rw [Nat.odd_iff] at this
      exact this
    omega
  tauto




/-- The number 2 is the unique prime that is neither bright nor dark. -/
theorem two_neither_bright_nor_dark : ¬ isBrightPrime 2 ∧ ¬ isDarkPrime 2 := by
  constructor <;> intro ⟨_, h⟩ <;> omega




/-- Bright primes up to 100. Verified count = 11. -/
theorem bright_count_100 :
    (Finset.filter (fun p => Nat.Prime p ∧ p % 4 = 1) (Finset.range 101)).card = 11 := by
  native_decide




/-- Quaternions ARE associative. -/
theorem quaternion_associative (a b c : Quaternion ℝ) :
    a * b * c = a * (b * c) := mul_assoc a b c




/-- The 2×2 Berggren matrices. -/
def M₁' : Matrix (Fin 2) (Fin 2) ℤ := !![2, -1; 1, 0]



/-- [Section: # CatalogBuild.Speculative.Other.FrontierResearch
Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 24] -/
def M₃' : Matrix (Fin 2) (Fin 2) ℤ := !![1, 2; 0, 1]




/-- M₃ = T²: the third Berggren generator is a power of T. -/
theorem M3_eq_T2 : M₃' = modT * modT := by native_decide




/-- M₁ has determinant 1 (in SL(2,ℤ)). -/
theorem M1_det_one : M₁'.det = 1 := by native_decide




/-- M₃ has determinant 1 (in SL(2,ℤ)). -/
theorem M3_det_one : M₃'.det = 1 := by native_decide




/-- S has order 4 in SL(2,ℤ). -/
theorem S_order_4 : modS ^ 4 = 1 := by native_decide




/-- (ST)³ = S² (the modular relation). -/
theorem modular_relation : (modS * modT) ^ 3 = modS ^ 2 := by native_decide




/-- A Pythagorean rotation matrix. -/
def PythRot (a b : ℤ) : Matrix (Fin 2) (Fin 2) ℤ := !![a, -b; b, a]




/-- Pythagorean rotations are closed under multiplication (= Gaussian integer multiplication). -/
theorem PythRot_mul (a b c d : ℤ) :
    PythRot a b * PythRot c d = PythRot (a*c - b*d) (a*d + b*c) := by
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [PythRot, mul_apply, Fin.sum_univ_two] <;> ring




/-- The determinant of a Pythagorean rotation is the Gaussian norm. -/
theorem PythRot_det (a b : ℤ) : (PythRot a b).det = a^2 + b^2 := by
  simp [PythRot, det_fin_two]; ring




/-- Pythagorean rotations commute (abelian gate set). -/
theorem PythRot_comm (a b c d : ℤ) :
    PythRot a b * PythRot c d = PythRot c d * PythRot a b := by
  rw [PythRot_mul, PythRot_mul]; congr 1 <;> ring




/-- The Minkowski form Q(a,b,c) = c² - a² - b². -/
def minkowski_form (v : Fin 3 → ℤ) : ℤ :=
  (v 2)^2 - (v 0)^2 - (v 1)^2




/-- The Berggren tree preserves nullity (if parent is Pythagorean, so is child). -/
theorem B1_preserves_pyth (a b c : ℤ) (h : a^2 + b^2 = c^2) :
    let v := B₁'.mulVec ![a, b, c]
    (v 0)^2 + (v 1)^2 = (v 2)^2 := by
  simp [B₁', mulVec, dotProduct, Fin.sum_univ_three]
  nlinarith [sq_nonneg a, sq_nonneg b, sq_nonneg c, sq_nonneg (a-b), sq_nonneg (a+b)]




/-- The associator of three elements in a ring. -/
def associator_ring {R : Type*} [Ring R] (x y z : R) : R :=
  (x * y) * z - x * (y * z)




/-- In any associative ring, the associator vanishes. -/
theorem associator_zero_of_assoc {R : Type*} [Ring R] (x y z : R) :
    associator_ring x y z = 0 := by
  simp [associator_ring, mul_assoc]




/-- For quaternions, the associator is always zero (they are associative). -/
theorem quaternion_associator_zero (x y z : Quaternion ℝ) :
    associator_ring x y z = 0 := associator_zero_of_assoc x y z



