import Mathlib

/-!
# Elementary rules of the prime-gap crossword

This file formalizes the deterministic arithmetic core of the prime-gap analogy.
It does **not** assert the Hardy--Littlewood asymptotic or positive-density claims,
which are beyond currently proved prime-gap theory.
-/

namespace PrimeGapCrossword

/-- `p` and `q` are consecutive primes: both endpoints are prime and there is no
prime strictly between them. -/
def ConsecutivePrimes (p q : ℕ) : Prop :=
  p.Prime ∧ q.Prime ∧ p < q ∧ ∀ n, p < n → n < q → ¬n.Prime

/-
The endpoints in a consecutive-prime pair really are ordered primes.
-/
theorem consecutive_endpoints {p q : ℕ} (h : ConsecutivePrimes p q) :
    p.Prime ∧ q.Prime ∧ p < q := by
  exact ⟨ h.1, h.2.1, h.2.2.1 ⟩

/-
Every integer strictly inside a consecutive-prime interval is nonprime.
-/
theorem consecutive_interior_nonprime {p q n : ℕ} (h : ConsecutivePrimes p q)
    (hpn : p < n) (hnq : n < q) : ¬n.Prime := by
  exact h.2.2.2 n hpn hnq

/-
Exact offset form of the crossword rule: a gap `g` occurs after `p` exactly
when both endpoints are prime and every positive smaller offset is nonprime.
-/
theorem gap_rule_iff (p g : ℕ) :
    ConsecutivePrimes p (p + g) ↔
      p.Prime ∧ (p + g).Prime ∧ 0 < g ∧
        ∀ k, 0 < k → k < g → ¬(p + k).Prime := by
  constructor <;> intro H;
  · exact ⟨ H.1, H.2.1, by linarith [ H.2.2.1 ], fun k hk₁ hk₂ => consecutive_interior_nonprime H ( by linarith ) ( by linarith ) ⟩;
  · exact ⟨ H.1, H.2.1, by linarith, fun n hn₁ hn₂ => H.2.2.2 ( n - p ) ( Nat.sub_pos_of_lt hn₁ ) ( Nat.lt_of_not_ge fun h => by linarith [ Nat.sub_add_cancel hn₁.le ] ) |> fun h => by rwa [ add_tsub_cancel_of_le hn₁.le ] at h ⟩

/-
The exceptional consecutive-prime pair beginning at `2` is forced to end at
`3`; hence its gap is exactly one.
-/
theorem first_gap_unique {q : ℕ} (h : ConsecutivePrimes 2 q) :
    q = 3 ∧ q - 2 = 1 := by
  rcases h with ⟨ h₁, h₂, h₃, h₄ ⟩;
  exact ⟨ le_antisymm ( not_lt.mp fun contra => h₄ 3 ( by decide ) contra ( by decide ) ) h₃, Nat.sub_eq_of_eq_add ( by linarith [ le_antisymm ( not_lt.mp fun contra => h₄ 3 ( by decide ) contra ( by decide ) ) h₃ ] ) ⟩

/-
Complete parity classification of consecutive prime gaps: either the pair is
`2,3`, or its gap is even.
-/
theorem prime_gap_exception_or_even {p q : ℕ} (h : ConsecutivePrimes p q) :
    (p = 2 ∧ q = 3) ∨ Even (q - p) := by
  by_cases hp : p = 2;
  · exact Or.inl ⟨ hp, by have := first_gap_unique ( by aesop : ConsecutivePrimes 2 q ) ; aesop ⟩;
  · cases h ; simp_all +decide;
    cases Nat.Prime.eq_two_or_odd ‹Nat.Prime p› <;> cases Nat.Prime.eq_two_or_odd ( by tauto : Nat.Prime q ) <;> simp_all +decide [ Nat.even_sub ( by linarith : p ≤ q ) ];
    · linarith [ Nat.Prime.two_le ‹_› ];
    · simp_all +decide [ Nat.even_iff ]

/-
In particular, every consecutive prime gap beginning at `3` or later is even.
-/
theorem later_prime_gap_even {p q : ℕ} (h : ConsecutivePrimes p q) (hp3 : 3 ≤ p) :
    Even (q - p) := by
  grind +suggestions

/-
Combined crossword constraint for a later gap: its length is even, and every
strictly interior offset lands on a nonprime.
-/
theorem later_gap_constraints {p q k : ℕ} (h : ConsecutivePrimes p q)
    (hp3 : 3 ≤ p) (hk0 : 0 < k) (hk : k < q - p) :
    Even (q - p) ∧ ¬(p + k).Prime := by
  exact ⟨ later_prime_gap_even h hp3, consecutive_interior_nonprime h ( by omega ) ( by omega ) ⟩

/-
Consequently, after the exceptional first pair, a consecutive-prime gap can
never have length one.
-/
theorem later_gap_ne_one {p q : ℕ} (h : ConsecutivePrimes p q) (hp3 : 3 ≤ p) :
    q - p ≠ 1 := by
  exact fun h' => by have := later_prime_gap_even h hp3; simp_all +decide

/-
A certified counterexample to the proposed forcing example: the consecutive
prime gaps beginning at `5431` are `6,4,2,6,22`, not `6,4,2,6,4`.
-/
theorem gap_pattern_6_4_2_6_does_not_force_4 :
    ConsecutivePrimes 5431 5437 ∧
    ConsecutivePrimes 5437 5441 ∧
    ConsecutivePrimes 5441 5443 ∧
    ConsecutivePrimes 5443 5449 ∧
    ConsecutivePrimes 5449 5471 := by
  refine' ⟨ _, _, _, _, _ ⟩;
  · exact ⟨ by norm_num, by norm_num, by norm_num, fun n hn₁ hn₂ => by interval_cases n <;> norm_num ⟩;
  · exact ⟨ by norm_num, by norm_num, by norm_num, fun n hn₁ hn₂ => by interval_cases n <;> norm_num ⟩;
  · exact ⟨ by norm_num, by norm_num, by norm_num, fun n hn₁ hn₂ => by interval_cases n ; norm_num ⟩;
  · exact ⟨ by norm_num, by norm_num, by norm_num, fun n hn₁ hn₂ => by interval_cases n <;> norm_num at hn₁ hn₂ ⊢ ⟩;
  · exact ⟨ by norm_num, by norm_num, by norm_num, fun n hn₁ hn₂ => by interval_cases n <;> norm_num ⟩

end PrimeGapCrossword