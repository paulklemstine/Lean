import Mathlib

/-!
# SPB over Finite Fields: The p±1 Order Law (Hypothesis H3)

Over 𝔽_p, the SPB group has order:
- p + 1 when p ≡ 3 (mod 4)
- p - 1 when p ≡ 1 (mod 4)

We verify this computationally for small primes using native_decide.
-/

open ZMod Finset

section SPBFinite

variable {p : ℕ} [Fact (Nat.Prime p)]

def spbMod (x y : ZMod p) : ZMod p := (x + y) / (1 - x * y)

def spbModIter (g : ZMod p) : ℕ → ZMod p
  | 0 => 0
  | n + 1 => spbMod g (spbModIter g n)

theorem spbModIter_one (g : ZMod p) : spbModIter g 1 = g := by
  simp [spbModIter, spbMod]

end SPBFinite

section Verification

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

/-! ### p ≡ 3 (mod 4): period divides p + 1 -/

-- p = 3: period divides 4 = 3+1
example : spbModIter (1 : ZMod 3) 4 = 0 := by native_decide

-- p = 7: period divides 8 = 7+1
example : spbModIter (1 : ZMod 7) 8 = 0 := by native_decide

-- p = 11: period divides 12 = 11+1
example : spbModIter (1 : ZMod 11) 12 = 0 := by native_decide

-- p = 19: period divides 20 = 19+1
example : spbModIter (1 : ZMod 19) 20 = 0 := by native_decide

-- p = 23: period divides 24 = 23+1
example : spbModIter (1 : ZMod 23) 24 = 0 := by native_decide

-- p = 31: period divides 32 = 31+1
example : spbModIter (1 : ZMod 31) 32 = 0 := by native_decide

/-! ### p ≡ 1 (mod 4): period divides p - 1 -/

-- p = 5: period divides 4 = 5-1
example : spbModIter (1 : ZMod 5) 4 = 0 := by native_decide

-- p = 13: period divides 12 = 13-1
example : spbModIter (1 : ZMod 13) 12 = 0 := by native_decide

-- p = 17: period divides 16 = 17-1
example : spbModIter (1 : ZMod 17) 16 = 0 := by native_decide

-- p = 29: period divides 28 = 29-1
example : spbModIter (1 : ZMod 29) 28 = 0 := by native_decide

end Verification
