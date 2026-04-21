/-! # CatalogBuild.Pythagorean.FutureResearch.RankDivisibility

Auto-generated from theorem catalog database.
Domain: Pythagorean/FutureResearch
Declarations: 28
-/

import Mathlib

/-- Tail-recursive Pell P mod m for efficient native_decide -/
def pellPmodIter (m : ℕ) (n : ℕ) : ℕ :=
  let rec go : ℕ → ℕ → ℕ → ℕ
    | 0, _, p_curr => p_curr
    | k+1, p_prev, p_curr => go k p_curr ((2 * p_curr + p_prev) % m)
  match n with
  | 0 => 0
  | _ => go (n - 1) 0 (1 % m)


/-- The norm in ℤ[√2]: N(a+b√2) = a²-2b² -/
def zsqrt2_norm (a b : ℤ) : ℤ := a ^ 2 - 2 * b ^ 2


/-- The norm is multiplicative: N((a+b√2)(c+d√2)) = N(a+b√2)·N(c+d√2) -/
theorem zsqrt2_norm_mul (a b c d : ℤ) :
    zsqrt2_norm (a * c + 2 * b * d) (a * d + b * c) =
    zsqrt2_norm a b * zsqrt2_norm c d := by
  unfold zsqrt2_norm; ring


/-- The norm of (H_n, P_n) equals (-1)^n -/
theorem zsqrt2_norm_pell (n : ℕ) :
    zsqrt2_norm (pellH n) (pellP n) = (-1 : ℤ) ^ n :=
  pell_fundamental n


/-- p=3: T(3)=4, p≡3(8), (2/3)=-1, 4 | p+1=4 ✓ -/
theorem rank_3 : pellPmodIter 3 4 = 0 ∧ (3 + 1) % 4 = 0 := by native_decide


/-- p=5: T(5)=3, p≡5(8), (2/5)=-1, 3 | p+1=6 ✓ -/
theorem rank_5 : pellPmodIter 5 3 = 0 ∧ (5 + 1) % 3 = 0 := by native_decide


/-- p=7: T(7)=6, p≡7(8), (2/7)=1, 6 | p-1=6 ✓ -/
theorem rank_7 : pellPmodIter 7 6 = 0 ∧ (7 - 1) % 6 = 0 := by native_decide


/-- p=11: T(11)=12, p≡3(8), (2/11)=-1, 12 | p+1=12 ✓ -/
theorem rank_11 : pellPmodIter 11 12 = 0 ∧ (11 + 1) % 12 = 0 := by native_decide


/-- p=13: T(13)=7, p≡5(8), (2/13)=-1, 7 | p+1=14 ✓ -/
theorem rank_13 : pellPmodIter 13 7 = 0 ∧ (13 + 1) % 7 = 0 := by native_decide


/-- p=17: T(17)=8, p≡1(8), (2/17)=1, 8 | p-1=16 ✓ -/
theorem rank_17 : pellPmodIter 17 8 = 0 ∧ (17 - 1) % 8 = 0 := by native_decide


/-- p=19: T(19)=20, p≡3(8), (2/19)=-1, 20 | p+1=20 ✓ -/
theorem rank_19 : pellPmodIter 19 20 = 0 ∧ (19 + 1) % 20 = 0 := by native_decide


/-- p=23: T(23)=22, p≡7(8), (2/23)=1, 22 | p-1=22 ✓ -/
theorem rank_23 : pellPmodIter 23 22 = 0 ∧ (23 - 1) % 22 = 0 := by native_decide


/-- p=29: T(29)=5, p≡5(8), (2/29)=-1, 5 | p+1=30 ✓ -/
theorem rank_29 : pellPmodIter 29 5 = 0 ∧ (29 + 1) % 5 = 0 := by native_decide


/-- p=31: T(31)=30, p≡7(8), (2/31)=1, 30 | p-1=30 ✓ -/
theorem rank_31 : pellPmodIter 31 30 = 0 ∧ (31 - 1) % 30 = 0 := by native_decide


/-- p=37: T(37)=19, p≡5(8), (2/37)=-1, 19 | p+1=38 ✓ -/
theorem rank_37 : pellPmodIter 37 19 = 0 ∧ (37 + 1) % 19 = 0 := by native_decide


/-- p=41: T(41)=10, p≡1(8), (2/41)=1, 10 | p-1=40 ✓ -/
theorem rank_41 : pellPmodIter 41 10 = 0 ∧ (41 - 1) % 10 = 0 := by native_decide


/-- (2/p) = -1 cases: P_{p+1} ≡ 0 mod p -/
theorem rank_key_p3  : pellPmodIter 3  (3 + 1) = 0 := by native_decide

theorem rank_key_p5  : pellPmodIter 5  (5 + 1) = 0 := by native_decide

theorem rank_key_p11 : pellPmodIter 11 (11 + 1) = 0 := by native_decide

theorem rank_key_p13 : pellPmodIter 13 (13 + 1) = 0 := by native_decide

theorem rank_key_p19 : pellPmodIter 19 (19 + 1) = 0 := by native_decide

theorem rank_key_p29 : pellPmodIter 29 (29 + 1) = 0 := by native_decide

theorem rank_key_p37 : pellPmodIter 37 (37 + 1) = 0 := by native_decide

-- (2/p) = 1 cases: P_{p-1} ≡ 0 mod p

theorem rank_key_p7  : pellPmodIter 7  (7 - 1) = 0 := by native_decide

theorem rank_key_p17 : pellPmodIter 17 (17 - 1) = 0 := by native_decide

theorem rank_key_p23 : pellPmodIter 23 (23 - 1) = 0 := by native_decide

theorem rank_key_p31 : pellPmodIter 31 (31 - 1) = 0 := by native_decide

theorem rank_key_p41 : pellPmodIter 41 (41 - 1) = 0 := by native_decide

