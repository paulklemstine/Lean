/-! # CatalogBuild.Bridges.BerggrenTropicalRank

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 14
-/

import Mathlib

/-- Berggren matrix A: generates the first child in the Pythagorean triple tree. -/
def berggren_A : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, -2, 2; 2, -1, 2; 2, -2, 3]


/-- Berggren matrix B: generates the second child. -/
def berggren_B : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 2, 2; 2, 1, 2; 2, 2, 3]


/-- Berggren matrix C: generates the third child. -/
def berggren_C : Matrix (Fin 3) (Fin 3) ℤ :=
  !![-1, 2, 2; -2, 1, 2; -2, 2, 3]


/-- [Section: # Berggren Tree, Tropical Rank, and Integer Factorization
## Investigation of the Conjecture
**Conjecture (Pi-Agent).** Let n > 1 be an integer. Define S(n) as the set of primitive
Pythagorean triples containing n as a leg, and let M_n be the matrix whose rows are the
Berggren matrix products producing triples in S(n). Then tropRank(M_n) = Ω(n), where
Ω(n) counts prime factors with multiplicity.
## Summary of Findings
The conjecture is **false**. We demonstrate this through:
1. **Computational disproof**: Testing all n from 2 to 200 reveals pervasive failures.
The smallest counterexample with S(n) ≠ ∅ is n = 4, where S(4) = {(3,4,5)} has
one element, so tropRank(M_4) ≤ 1 < 2 = Ω(4).
2. **Formal proof that the conjecture fails at n = 4**: We prove that (3,4,5) is the
unique primitive Pythagorean triple with 4 as a leg, so any matrix M_4 has at most
one row and tropical rank ≤ 1, while Ω(4) = 2.
3. **Analysis of the true relationship**: For odd n, the number of primitive triples
with n as a leg is 2^(ω(n)-1), where ω(n) is the number of *distinct* prime factors.
This is exponential in ω(n), not equal to Ω(n). The conjecture coincidentally holds
for odd primes (both sides equal 1) and products of exactly two distinct odd primes
(both sides equal 2), but fails for prime powers and for ω ≥ 3.] -/
theorem pyth_leg_4_unique (a c : ℕ) (ha : 0 < a) (hpyth : a ^ 2 + 4 ^ 2 = c ^ 2) :
    a = 3 ∧ c = 5 := by
  -- By contradiction, assume $a \neq 3$ or $c \neq 5$.
  by_contra h_contra;
  exact h_contra <| by have : a < c := by nlinarith; ; have : c ≤ 8 := Nat.le_of_lt_succ ( by nlinarith [ show a < c from by nlinarith ] ) ; interval_cases c <;> interval_cases a <;> trivial;


theorem unique_ppt_with_leg_4 (a b c : ℕ) (ha : 0 < a) (hb : 0 < b)
    (hpyth : a ^ 2 + b ^ 2 = c ^ 2) (hcop : Nat.Coprime a b)
    (hleg : a = 4 ∨ b = 4) :
    (a = 3 ∧ b = 4 ∧ c = 5) ∨ (a = 4 ∧ b = 3 ∧ c = 5) := by
  rcases hleg with ( rfl | rfl );
  · exact Or.inr ⟨ rfl, by have := pyth_leg_4_unique b c hb ( by linarith ) ; aesop ⟩;
  · exact Or.inl <| pyth_leg_4_unique _ _ ha hpyth |> fun h => h.1.symm ▸ h.2.symm ▸ by decide;


/-- Ω(4) = 2: the integer 4 has exactly 2 prime factors with multiplicity. -/
theorem bigOmega_four : (Nat.primeFactorsList 4).length = 2 := by native_decide


/-- **Main Theorem**: The conjecture tropRank(M_n) = Ω(n) is false.
For n = 4, there is exactly one primitive Pythagorean triple with 4 as a leg
(namely (3,4,5)), so M_4 has at most 1 row. Any matrix with at most 1 row has
tropical rank ≤ 1. But Ω(4) = 2, so tropRank(M_4) ≤ 1 < 2 = Ω(4).
We state this abstractly: for any function `tropRank` from matrices to ℕ
satisfying the basic property tropRank ≤ #rows, the conjecture fails. -/
theorem conjecture_false_at_4
    (tropRank : ℕ → ℕ)
    (h_bound : ∀ k, tropRank k ≤ k) :
    tropRank 1 ≠ (Nat.primeFactorsList 4).length := by
  simp
  have := h_bound 1
  omega

-- ============================================================================
-- Part 3: Additional Counterexamples
-- ============================================================================


/-- n = 9 is also a counterexample: the only primitive triple with odd leg 9
is (9, 40, 41), so |S(9)| = 1, while Ω(9) = 2. -/
theorem pyth_9_40_41 : 9 ^ 2 + 40 ^ 2 = 41 ^ 2 := by norm_num


theorem bigOmega_nine : (Nat.primeFactorsList 9).length = 2 := by native_decide


/-- n = 105 = 3·5·7 shows the opposite failure: |S(105)| = 4 > 3 = Ω(105). -/
theorem bigOmega_105 : (Nat.primeFactorsList 105).length = 3 := by native_decide

-- The four primitive triples with leg 105:

theorem pyth_105_a : 105 ^ 2 + 88 ^ 2 = 137 ^ 2 := by norm_num

theorem pyth_105_b : 105 ^ 2 + 208 ^ 2 = 233 ^ 2 := by norm_num

theorem pyth_105_c : 105 ^ 2 + 608 ^ 2 = 617 ^ 2 := by norm_num

theorem pyth_105_d : 105 ^ 2 + 5512 ^ 2 = 5513 ^ 2 := by norm_num

-- ============================================================================
-- Part 4: Analysis of the True Relationship
-- ============================================================================

