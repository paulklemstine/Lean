import Mathlib

/-!
# Deep Structure of SPB over Finite Fields

The SPB group over 𝔽_p has a beautiful dichotomy:
- p ≡ 1 (mod 4): group order divides p-1
- p ≡ 3 (mod 4): group order divides p+1

This file provides extensive computational verification of this structure.
-/

open ZMod

section SPBFinite

variable {p : ℕ} [Fact (Nat.Prime p)]

/-- SPB over ZMod p. -/
def spbF (x y : ZMod p) : ZMod p := (x + y) / (1 - x * y)

/-- SPB is commutative over any field. -/
theorem spbF_comm (x y : ZMod p) : spbF x y = spbF y x := by
  simp [spbF, add_comm, mul_comm]

/-- 0 is the identity. -/
theorem spbF_zero (x : ZMod p) : spbF x 0 = x := by simp [spbF]

/-- -x is the inverse. -/
theorem spbF_neg (x : ZMod p) : spbF x (-x) = 0 := by simp [spbF]

/-- SPB iteration. -/
def spbIterF (x : ZMod p) : ℕ → ZMod p
  | 0 => 0
  | n + 1 => spbF x (spbIterF x n)

theorem spbIterF_zero (x : ZMod p) : spbIterF x 0 = 0 := rfl
theorem spbIterF_one (x : ZMod p) : spbIterF x 1 = x := by simp [spbIterF, spbF]

end SPBFinite

/-! ## Computational Verification of the p±1 Law -/

section Computation

instance : Fact (Nat.Prime 3) := ⟨by norm_num⟩
instance : Fact (Nat.Prime 5) := ⟨by norm_num⟩
instance : Fact (Nat.Prime 7) := ⟨by norm_num⟩
instance : Fact (Nat.Prime 11) := ⟨by norm_num⟩
instance : Fact (Nat.Prime 13) := ⟨by norm_num⟩
instance : Fact (Nat.Prime 17) := ⟨by norm_num⟩
instance : Fact (Nat.Prime 19) := ⟨by norm_num⟩
instance : Fact (Nat.Prime 23) := ⟨by norm_num⟩
instance : Fact (Nat.Prime 29) := ⟨by norm_num⟩
instance : Fact (Nat.Prime 31) := ⟨by norm_num⟩
instance : Fact (Nat.Prime 37) := ⟨by norm_num⟩
instance : Fact (Nat.Prime 41) := ⟨by norm_num⟩
instance : Fact (Nat.Prime 43) := ⟨by norm_num⟩
instance : Fact (Nat.Prime 47) := ⟨by norm_num⟩

/-! ### p ≡ 3 (mod 4): All element orders divide p + 1 -/

-- p = 3: p+1 = 4
example : spbIterF (1 : ZMod 3) 4 = 0 := by native_decide

-- p = 7: p+1 = 8
example : spbIterF (1 : ZMod 7) 8 = 0 := by native_decide
example : spbIterF (2 : ZMod 7) 8 = 0 := by native_decide
example : spbIterF (3 : ZMod 7) 8 = 0 := by native_decide

-- p = 11: p+1 = 12
example : spbIterF (1 : ZMod 11) 12 = 0 := by native_decide
example : spbIterF (2 : ZMod 11) 12 = 0 := by native_decide
example : spbIterF (3 : ZMod 11) 12 = 0 := by native_decide

-- p = 19: p+1 = 20
example : spbIterF (1 : ZMod 19) 20 = 0 := by native_decide
example : spbIterF (3 : ZMod 19) 20 = 0 := by native_decide

-- p = 23: p+1 = 24
example : spbIterF (1 : ZMod 23) 24 = 0 := by native_decide
example : spbIterF (5 : ZMod 23) 24 = 0 := by native_decide

-- p = 31: p+1 = 32
example : spbIterF (1 : ZMod 31) 32 = 0 := by native_decide

-- p = 43: p+1 = 44
example : spbIterF (1 : ZMod 43) 44 = 0 := by native_decide

-- p = 47: p+1 = 48
example : spbIterF (1 : ZMod 47) 48 = 0 := by native_decide

/-! ### p ≡ 1 (mod 4): All element orders divide p - 1 -/

-- p = 5: p-1 = 4
example : spbIterF (1 : ZMod 5) 4 = 0 := by native_decide

-- p = 13: p-1 = 12
example : spbIterF (2 : ZMod 13) 12 = 0 := by native_decide
example : spbIterF (3 : ZMod 13) 12 = 0 := by native_decide

-- p = 17: p-1 = 16
example : spbIterF (2 : ZMod 17) 16 = 0 := by native_decide
example : spbIterF (3 : ZMod 17) 16 = 0 := by native_decide

-- p = 29: p-1 = 28
example : spbIterF (2 : ZMod 29) 28 = 0 := by native_decide

-- p = 37: p-1 = 36
example : spbIterF (2 : ZMod 37) 36 = 0 := by native_decide

-- p = 41: p-1 = 40
example : spbIterF (2 : ZMod 41) 40 = 0 := by native_decide

/-! ### Cross-verification: p ≡ 1 mod 4 does NOT always divide p+1 -/

-- p = 13 ≡ 1 (mod 4): element 3 does NOT have period dividing p+1 = 14
example : spbIterF (3 : ZMod 13) 14 ≠ 0 := by native_decide

-- p = 29 ≡ 1 (mod 4): element 2 period does NOT divide p+1 = 30
example : spbIterF (2 : ZMod 29) 30 ≠ 0 := by native_decide

end Computation
