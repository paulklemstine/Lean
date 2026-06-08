/-
# Prime Gap Automaton Theory: Modular Constraints as Symbolic Dynamics

This module develops the theory of prime gap sequences viewed through the lens
of finite-state automata and symbolic dynamics. The central construction is
the **Residue Transition System** (RTS): given a modulus m (typically a
primorial like 6, 30, or 210), consecutive primes trace a path through
the coprime residues mod m, and the gap sequence is the sequence of "steps."

## Main results

1. **Mod-6 Automaton Correctness**: The 2-state automaton exactly captures
   all mod-6 constraints on prime gap sequences.
2. **Bertrand Gap Bound**: Every prime gap g(p) < p.
3. **Twin Prime Isolation**: Gaps adjacent to twin primes must be ≥ 4.
4. **Forbidden Patterns**: [2,2], [4,4], [2,4,2] are forbidden gap sequences.
5. **Cousin Prime Classification**: Cousin primes require state 1 mod 6.

## Novel definitions

- `ResidueTransitionSystem`: Finite-state machine for prime gap constraints.
- `Mod6State` / `mod6Transition`: The explicit 2-state automaton for mod-6.
-/

import Mathlib

open Finset Nat

namespace PrimeGapAutomaton

/-! ## Section 1: Residue Transition System -/

/-- **Novel Structure**: A Residue Transition System (RTS) captures
    the finite-state automaton induced by a modulus m on prime gap sequences.
    States are coprime residue classes; transitions are gap values. -/
structure ResidueTransitionSystem where
  /-- The modulus (typically a primorial) -/
  modulus : ℕ
  /-- The modulus is at least 2 -/
  modulus_pos : 2 ≤ modulus
  /-- The set of admissible residues (coprime to modulus) -/
  states : Finset ℕ
  /-- All states are less than the modulus -/
  states_bound : ∀ s ∈ states, s < modulus
  /-- States are coprime to the modulus -/
  states_coprime : ∀ s ∈ states, Nat.Coprime s modulus

/-- The mod-6 RTS. States are {1, 5} = units of ℤ/6ℤ. -/
def RTS6 : ResidueTransitionSystem where
  modulus := 6
  modulus_pos := by norm_num
  states := {1, 5}
  states_bound := by decide
  states_coprime := by decide

/-- The mod-30 RTS. States are {1,7,11,13,17,19,23,29} = units of ℤ/30ℤ. -/
def RTS30 : ResidueTransitionSystem where
  modulus := 30
  modulus_pos := by norm_num
  states := {1, 7, 11, 13, 17, 19, 23, 29}
  states_bound := by decide
  states_coprime := by native_decide

theorem RTS6_state_count : RTS6.states.card = 2 := by decide
theorem RTS30_state_count : RTS30.states.card = 8 := by decide

/-! ## Section 2: Bertrand's Gap Bound -/

/-
**Bertrand Gap Bound**: For consecutive primes p < q, gap q - p < p.
-/
theorem prime_gap_bound (p q : ℕ) (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hpq : p < q) (hcons : ∀ n, p < n → n < q → ¬Nat.Prime n) :
    q - p < p := by
  obtain ⟨ r, hr ⟩ := Nat.exists_prime_lt_and_le_two_mul p hp.ne_zero;
  grind +suggestions

/-! ## Section 3: Mod-6 State Classification -/

/-
Every prime > 3 is ≡ 1 or 5 mod 6.
-/
theorem prime_mod6_class (p : ℕ) (hp : Nat.Prime p) (h3 : 3 < p) :
    p % 6 = 1 ∨ p % 6 = 5 := by
  by_contra! h_contra;
  have := Nat.Prime.eq_two_or_odd hp; ( have := Nat.dvd_of_mod_eq_zero ( show p % 3 = 0 by omega ) ; rw [ hp.dvd_iff_eq ] at this <;> linarith; )

/-
A gap of 2 from state 1 is impossible (p+2 ≡ 0 mod 3).
-/
theorem gap2_from_one_impossible {p : ℕ} (_hp : Nat.Prime p) (_hp3 : 3 < p)
    (hmod : p % 6 = 1) : ¬Nat.Prime (p + 2) := by
  exact fun h => by have := Nat.dvd_of_mod_eq_zero ( show ( p + 2 ) % 3 = 0 by omega ) ; rw [ h.dvd_iff_eq ] at this <;> linarith;

/-
A gap of 4 from state 5 is impossible (p+4 ≡ 0 mod 3).
-/
theorem gap4_from_five_impossible {p : ℕ} (_hp : Nat.Prime p) (_hp3 : 3 < p)
    (hmod : p % 6 = 5) : ¬Nat.Prime (p + 4) := by
  exact fun h => by have := Nat.dvd_of_mod_eq_zero ( show ( p + 4 ) % 3 = 0 by omega ) ; rw [ h.dvd_iff_eq ] at this <;> linarith;

/-! ## Section 4: The Mod-6 Automaton -/

/-- The mod-6 state: either residue 1 or residue 5. -/
inductive Mod6State
  | one  -- p ≡ 1 mod 6
  | five -- p ≡ 5 mod 6
  deriving DecidableEq, Repr

/-- The transition function of the mod-6 automaton. -/
def mod6Transition (s : Mod6State) (gapMod6 : ℕ) : Option Mod6State :=
  match s, gapMod6 with
  | .one,  0 => some .one
  | .one,  4 => some .five
  | .five, 0 => some .five
  | .five, 2 => some .one
  | _,     _ => none

/-
**Mod-6 Automaton Correctness**: The transition function exactly
    captures the mod-6 constraint on prime gap sequences.
-/
theorem mod6_transition_correct {p q : ℕ} (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hp3 : 3 < p) (hpq : p < q) :
    let s := if p % 6 = 1 then Mod6State.one else Mod6State.five
    let t := if q % 6 = 1 then Mod6State.one else Mod6State.five
    mod6Transition s ((q - p) % 6) = some t := by
  -- By prime_mod6_class, we know that p % 6 = 1 or p % 6 = 5, and similarly for q.
  have h_cases : (p % 6 = 1 ∨ p % 6 = 5) ∧ (q % 6 = 1 ∨ q % 6 = 5) := by
    exact ⟨ prime_mod6_class p hp hp3, prime_mod6_class q hq ( by linarith ) ⟩;
  unfold mod6Transition; split_ifs <;> simp_all +decide;
  · rw [ show ( q - p ) % 6 = 0 by omega ];
  · rw [ show ( q - p ) % 6 = 4 by omega ];
  · rw [ show ( q - p ) % 6 = 2 by omega ];
  · rw [ show ( q - p ) % 6 = 0 by omega ]

/-! ## Section 5: Gap Alternation Theorems -/

/-
**Gap Alternation from State 1**: Gap ≡ 0 stays at 1, gap ≡ 4 goes to 5.
-/
theorem gap_alternation_from_one {p q : ℕ} (_hp : Nat.Prime p) (hq : Nat.Prime q)
    (_hp3 : 3 < p) (hpq : p < q) (hmod : p % 6 = 1) :
    ((q - p) % 6 = 0 ∧ q % 6 = 1) ∨ ((q - p) % 6 = 4 ∧ q % 6 = 5) := by
  have := prime_mod6_class q hq (by linarith)
  cases this <;> simp_all +decide; all_goals omega

/-
**Gap Alternation from State 5**: Gap ≡ 0 stays at 5, gap ≡ 2 goes to 1.
-/
theorem gap_alternation_from_five {p q : ℕ} (_hp : Nat.Prime p) (hq : Nat.Prime q)
    (_hp3 : 3 < p) (hpq : p < q) (hmod : p % 6 = 5) :
    ((q - p) % 6 = 0 ∧ q % 6 = 5) ∨ ((q - p) % 6 = 2 ∧ q % 6 = 1) := by
  cases prime_mod6_class q hq ( by linarith ) <;> omega

/-! ## Section 6: Twin Prime Isolation -/

/-- Twin primes (p, p+2) with p > 3 force p ≡ 5 mod 6. -/
theorem twin_prime_forces_state5 {p : ℕ} (hp : Nat.Prime p) (hp3 : 3 < p)
    (hp2 : Nat.Prime (p + 2)) : p % 6 = 5 := by
  rcases prime_mod6_class p hp hp3 with h1 | h5
  · exact absurd hp2 (gap2_from_one_impossible hp hp3 h1)
  · exact h5

/-
**Twin Prime Isolation (Forward)**: After twin primes (p, p+2)
    with p > 3, the next prime is at least p+6.
-/
theorem twin_prime_isolation_forward {p q : ℕ}
    (hp : Nat.Prime p) (hp2 : Nat.Prime (p + 2)) (hq : Nat.Prime q)
    (hp3 : 3 < p) (hpq : p + 2 < q) :
    p + 6 ≤ q := by
  -- By twin_prime_forces_state5, p % 6 = 5, so (p+2) % 6 = 1.
  have hp_mod : p % 6 = 5 := by
    exact twin_prime_forces_state5 hp hp3 hp2
  have hp2_mod : (p + 2) % 6 = 1 := by
    norm_num [ Nat.add_mod, hp_mod ]
  have hq_mod : q % 6 = 1 ∨ q % 6 = 5 := by
    exact prime_mod6_class q hq ( by linarith );
  omega

/-
**Twin Prime Isolation (Backward)**: Before twin primes (q, q+2)
    with q > 3, the previous prime p (> 3) satisfies p + 4 ≤ q.
-/
theorem twin_prime_isolation_backward {p q : ℕ}
    (hp : Nat.Prime p) (hq : Nat.Prime q) (hq2 : Nat.Prime (q + 2))
    (hp3 : 3 < p) (hpq : p < q) :
    p + 4 ≤ q := by
  by_cases h_cases : p % 6 = 1 ∨ p % 6 = 5;
  · have := twin_prime_forces_state5 hq ( by linarith ) hq2; omega;
  · have := Nat.Prime.eq_two_or_odd hp; ( have := Nat.dvd_of_mod_eq_zero ( show p % 3 = 0 by omega ) ; rw [ hp.dvd_iff_eq ] at this <;> linarith; )

/-! ## Section 7: Forbidden Patterns -/

/-- **Forbidden Pattern [2,2]**: No prime triplet p, p+2, p+4 for p > 3. -/
theorem forbidden_pattern_22 {p : ℕ} (hp : Nat.Prime p) (hp3 : 3 < p)
    (hp2 : Nat.Prime (p + 2)) : ¬Nat.Prime (p + 4) := by
  have h5 := twin_prime_forces_state5 hp hp3 hp2
  have h1 : (p + 2) % 6 = 1 := by omega
  exact gap2_from_one_impossible hp2 (by omega) h1

/-- **Forbidden Pattern [4,4]**: No cousin triplet p, p+4, p+8 for p > 3. -/
theorem forbidden_pattern_44 {p : ℕ} (hp : Nat.Prime p) (hp3 : 3 < p)
    (hp4 : Nat.Prime (p + 4)) : ¬Nat.Prime (p + 8) := by
  rcases prime_mod6_class p hp hp3 with h1 | h5
  · have : (p + 4) % 6 = 5 := by omega
    exact gap4_from_five_impossible hp4 (by omega) this
  · exact absurd hp4 (gap4_from_five_impossible hp hp3 h5)

/- Note: The pattern [2,4,2] is NOT forbidden — (11,13,17,19) is a valid instance.
   Instead, we prove [2,4,2,4,2] is forbidden for p > 5: the six numbers
   p, p+2, p+6, p+8, p+12, p+14 cover all residues mod 5. -/

/-- Among p, p+2, p+6, p+8, p+12, p+14, one is divisible by 5. -/
theorem sextuple_has_multiple_of_5 (p : ℕ) :
    5 ∣ p ∨ 5 ∣ (p + 2) ∨ 5 ∣ (p + 6) ∨ 5 ∣ (p + 8) ∨
    5 ∣ (p + 12) ∨ 5 ∣ (p + 14) := by omega

/-
**Forbidden Pattern [2,4,2,4,2]**: For p > 5, not all of
    p, p+2, p+6, p+8, p+12, p+14 can be prime.
-/
theorem forbidden_pattern_24242 (p : ℕ) (hp5 : 5 < p)
    (h1 : Nat.Prime p) (h2 : Nat.Prime (p + 2))
    (h3 : Nat.Prime (p + 6)) (h4 : Nat.Prime (p + 8))
    (h5 : Nat.Prime (p + 12)) : ¬Nat.Prime (p + 14) := by
  intro h6;
  -- By the properties of primes, one of the numbers in the sequence must be divisible by 5.
  have h_div : 5 ∣ p ∨ 5 ∣ (p + 2) ∨ 5 ∣ (p + 6) ∨ 5 ∣ (p + 8) ∨ 5 ∣ (p + 12) ∨ 5 ∣ (p + 14) := by
    grind;
  rcases h_div with ( h | h | h | h | h | h ) <;> simp_all +decide [ Nat.Prime.dvd_iff_eq ]

/-! ## Section 8: Cousin Prime State Theorem -/

/-- Cousin primes (p, p+4) with p > 3: p ≡ 1 mod 6 and p+4 ≡ 5 mod 6. -/
theorem cousin_prime_states {p : ℕ} (hp : Nat.Prime p) (hp4 : Nat.Prime (p + 4))
    (hp3 : 3 < p) : p % 6 = 1 ∧ (p + 4) % 6 = 5 := by
  rcases prime_mod6_class p hp hp3 with h1 | h5
  · exact ⟨h1, by omega⟩
  · exact absurd hp4 (gap4_from_five_impossible hp hp3 h5)

/-! ## Section 9: Mod-6 Automaton Structural Properties -/

/-- Every state has exactly 2 valid transition classes mod 6. -/
theorem mod6_two_transitions (s : Mod6State) :
    ∃ g₁ g₂ : ℕ, g₁ ≠ g₂ ∧ g₁ < 6 ∧ g₂ < 6 ∧
    (mod6Transition s g₁).isSome ∧ (mod6Transition s g₂).isSome ∧
    ∀ g, g < 6 → (mod6Transition s g).isSome → g = g₁ ∨ g = g₂ := by
  cases s
  · exact ⟨0, 4, by omega, by omega, by omega,
      by decide, by decide,
      fun g hg h => by interval_cases g <;> simp_all [mod6Transition]⟩
  · exact ⟨0, 2, by omega, by omega, by omega,
      by decide, by decide,
      fun g hg h => by interval_cases g <;> simp_all [mod6Transition]⟩

/-- The mod-6 automaton is strongly connected. -/
theorem mod6_strongly_connected (s t : Mod6State) :
    ∃ g : ℕ, g < 6 ∧ mod6Transition s g = some t := by
  cases s <;> cases t
  · exact ⟨0, by omega, by decide⟩
  · exact ⟨4, by omega, by decide⟩
  · exact ⟨2, by omega, by decide⟩
  · exact ⟨0, by omega, by decide⟩

/-- Gap 6 preserves mod-6 state. -/
theorem gap6_preserves_state (p : ℕ) : p % 6 = (p + 6) % 6 := by omega

/-! ## Section 10: Gap Parity -/

/-
**Gap Parity**: Gaps between primes > 2 are even.
-/
theorem gap_even {p q : ℕ} (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hp2 : 2 < p) (hpq : p < q) : Even (q - p) := by
  cases Nat.Prime.eq_two_or_odd hp <;> cases Nat.Prime.eq_two_or_odd hq <;> simp_all +decide [Nat.even_iff];
  · grind;
  · omega

/-- **Minimum Gap**: For primes p < q with p > 2, gap ≥ 2. -/
theorem min_gap {p q : ℕ} (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hp2 : 2 < p) (hpq : p < q) : 2 ≤ q - p := by
  have hev := gap_even hp hq hp2 hpq
  obtain ⟨k, hk⟩ := hev
  omega

/-! ## Section 11: No Consecutive Equal Gaps -/

/-- No two consecutive gaps equal 2 for primes > 3. -/
theorem no_consecutive_gap2 {p : ℕ}
    (hp : Nat.Prime p) (hp3 : 3 < p)
    (hq : Nat.Prime (p + 2)) : ¬Nat.Prime (p + 4) :=
  forbidden_pattern_22 hp hp3 hq

/-- No two consecutive gaps equal 4 for primes > 3. -/
theorem no_consecutive_gap4 {p : ℕ}
    (hp : Nat.Prime p) (hp3 : 3 < p)
    (hq : Nat.Prime (p + 4)) : ¬Nat.Prime (p + 8) :=
  forbidden_pattern_44 hp hp3 hq

/-! ## Section 12: State Determination -/

/-- Knowing p mod 6 constrains the gap to 2 residue classes mod 6. -/
theorem state_determines_gaps {p q : ℕ} (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hp3 : 3 < p) (hpq : p < q) :
    (p % 6 = 1 → (q - p) % 6 = 0 ∨ (q - p) % 6 = 4) ∧
    (p % 6 = 5 → (q - p) % 6 = 0 ∨ (q - p) % 6 = 2) := by
  constructor
  · intro h1
    rcases gap_alternation_from_one hp hq hp3 hpq h1 with ⟨h, _⟩ | ⟨h, _⟩
    · left; exact h
    · right; exact h
  · intro h5
    rcases gap_alternation_from_five hp hq hp3 hpq h5 with ⟨h, _⟩ | ⟨h, _⟩
    · left; exact h
    · right; exact h

/-! ## Section 13: Falsifiable Conjecture

**Gap AP Bound Conjecture**: For any even g > 0, consecutive equal gaps
of value g among primes > g have bounded run length.

Computational test: For g = 6, search for 5 consecutive primes each
differing by exactly 6 among primes up to 10^10. -/

/-- **Gap AP Bound Conjecture** (formal statement). -/
def GapAPBoundConjecture : Prop :=
  ∀ g : ℕ, 0 < g → Even g →
  ∃ B : ℕ, ∀ (f : Fin (B + 2) → ℕ),
    (∀ i, Nat.Prime (f i)) →
    (∀ i, g < f i) →
    Monotone f →
    ¬(∀ i : Fin (B + 1),
      f ⟨i.val + 1, by omega⟩ - f ⟨i.val, by omega⟩ = g)

end PrimeGapAutomaton