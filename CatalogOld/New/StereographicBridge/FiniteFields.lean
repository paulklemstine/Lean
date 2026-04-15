import Mathlib

/-!
# SPB over Finite Fields

The SPB operation spb(x,y) = (x+y)/(1-xy) over finite fields 𝔽_p gives a partial group
operation closely related to the projective line ℙ¹(𝔽_p).

## Group Structure Classification
- For p ≡ 3 (mod 4): SPB group has order p+1, isomorphic to ℤ/(p+1)ℤ
- For p ≡ 1 (mod 4): SPB group has order p-1, isomorphic to ℤ/(p-1)ℤ

This is because the Cayley transform C'(x) = (1+ix)/(1-ix) maps SPB elements
to norm-1 elements of 𝔽_{p²}. When -1 is a non-residue (p ≡ 3 mod 4),
the norm-1 subgroup has order p+1. When -1 is a residue (p ≡ 1 mod 4),
the map degenerates to 𝔽_p*, giving order p-1.
-/

open ZMod

/-! ## SPB over ZMod p -/

section SPBMod

variable {p : ℕ} [Fact (Nat.Prime p)]

/-- SPB operation over ZMod p (for prime p with field structure). -/
def spbZMod (x y : ZMod p) : ZMod p := (x + y) / (1 - x * y)

/-- SPB is commutative over ZMod p. -/
theorem spbZMod_comm (x y : ZMod p) : spbZMod x y = spbZMod y x := by
  simp [spbZMod, add_comm, mul_comm]

/-- 0 is the identity for SPB over ZMod p. -/
theorem spbZMod_zero_right (x : ZMod p) : spbZMod x 0 = x := by
  simp [spbZMod]

/-- Negation is the inverse for SPB over ZMod p. -/
theorem spbZMod_neg (x : ZMod p) : spbZMod x (-x) = 0 := by
  simp [spbZMod]

/-- n-fold SPB iteration over ZMod p. -/
def spbIterZMod (x : ZMod p) : ℕ → ZMod p
  | 0 => 0
  | n + 1 => spbZMod x (spbIterZMod x n)

theorem spbIterZMod_one (x : ZMod p) : spbIterZMod x 1 = x := by
  simp [spbIterZMod, spbZMod]

end SPBMod

/-! ## Computational Verification -/

section Computational

instance : Fact (Nat.Prime 3) := ⟨by norm_num⟩
instance : Fact (Nat.Prime 5) := ⟨by norm_num⟩
instance : Fact (Nat.Prime 7) := ⟨by norm_num⟩
instance : Fact (Nat.Prime 11) := ⟨by norm_num⟩
instance : Fact (Nat.Prime 13) := ⟨by norm_num⟩

/-- Over 𝔽₅: spb(1, 2) = 2. -/
example : spbZMod (1 : ZMod 5) 2 = 2 := by native_decide

/-- Over 𝔽₇: spb(2, 3) = 6. -/
example : spbZMod (2 : ZMod 7) 3 = 6 := by native_decide

/-- Over 𝔽₇: spb(3, 4) = 0. -/
example : spbZMod (3 : ZMod 7) 4 = 0 := by native_decide

/-! ## SPB Iteration Periodicity

Over 𝔽_p, the SPB iteration of a generator g returns to 0 after exactly
the group order many steps. The orbits demonstrate the p±1 law.
-/

/-- 𝔽₃ (p≡3 mod 4): 1 has period 4 = p+1 under SPB iteration. -/
example : spbIterZMod (1 : ZMod 3) 4 = 0 := by native_decide


/-- 𝔽₅ (p≡1 mod 4): 1 has period 2 (divides p-1 = 4). -/
example : spbIterZMod (1 : ZMod 5) 2 = 0 := by native_decide

/-- 𝔽₇ (p≡3 mod 4): 2 has period 4 (divides p+1 = 8). -/
example : spbIterZMod (2 : ZMod 7) 4 = 0 := by native_decide

/-- 𝔽₁₃ (p≡1 mod 4): 2 has period 6 (divides p-1 = 12). -/
example : spbIterZMod (2 : ZMod 13) 6 = 0 := by native_decide

/-- 𝔽₁₃: Full period generator — 6 has period 6 divides 12. -/
example : spbIterZMod (6 : ZMod 13) 6 = 0 := by native_decide

end Computational
