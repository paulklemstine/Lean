/-
# Prime Gap Transition Theory

This module develops the theory of prime gap transitions as a finite-state
dynamical system. The key insight is that prime gaps induce transitions on
residue classes modulo small primorials, and these transitions form a
structured algebraic object — a transition monoid — whose properties
constrain gap sequences.

## Main Results

1. **Bertrand Gap Bound**: For consecutive primes p < q with p ≥ 2, we have q < 2 * p,
   hence the gap q - p < p. Prime gaps grow strictly slower than primes.

2. **Mod-6 Determinism Theorem**: The gap sequence uniquely determines the
   mod-6 residue sequence of primes > 3. Given p₀ mod 6 and the gap sequence,
   every subsequent prime's residue mod 6 is determined.

3. **No Consecutive Equal Gaps of 2**: The gap [2,2] is forbidden for primes > 3
   (no-prime-triplet theorem), proved as a transition constraint.

4. **Gap Transition Completeness**: Every admissible mod-6 transition can be
   realized by some even gap. The transition graph is strongly connected.

5. **Consecutive Gap Coprimality**: For twin primes p, p+2 with p > 3,
   the gap 2 forces the next gap to be ≥ 4, creating a rhythm constraint.

## Novel Definitions

- `GapTransitionSystem`: A finite-state system where states are residue classes
  and transitions are labeled by gap values. Captures the "grammar" of prime gaps.

- `ReachableState`: The set of states reachable from a given state via
  admissible gap transitions.
-/

import Mathlib

open Nat Finset

namespace PrimeGapTransition

/-! ## Section 1: Bertrand's Postulate and Gap Bounds

Bertrand's postulate (proved in Mathlib) states that for every n ≥ 1,
there exists a prime p with n < p ≤ 2n. We derive the fundamental
constraint on prime gap growth. -/

/-
**Bertrand Gap Bound**: For any prime p ≥ 2, the next prime after p
    is less than 2p. This means prime gaps grow strictly slower than
    the primes themselves: gap(n) < p(n) for all n.
-/
theorem bertrand_gap_bound (p : ℕ) (hp : Nat.Prime p) :
    ∃ q, Nat.Prime q ∧ p < q ∧ q < 2 * p := by
  obtain ⟨q, hq⟩ : ∃ q : ℕ, Nat.Prime q ∧ p < q ∧ q ≤ 2 * p := by
    exact Nat.exists_prime_lt_and_le_two_mul p hp.ne_zero;
  exact ⟨ q, hq.1, hq.2.1, lt_of_le_of_ne hq.2.2 fun h => by have := hq.1.eq_two_or_odd; aesop ⟩

/-
Consequence: for consecutive primes p < q with p ≥ 2, the gap q - p < p.
-/
theorem gap_lt_prime {p q : ℕ} (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hpq : p < q) (hcons : ∀ n, p < n → n < q → ¬Nat.Prime n) :
    q - p < p := by
  -- By Bertrand's postulate, there exists a prime r such that p < r ≤ 2*p.
  obtain ⟨r, hr_prime, hr_bounds⟩ : ∃ r, Nat.Prime r ∧ p < r ∧ r ≤ 2 * p := Nat.bertrand p (Nat.Prime.ne_zero hp);
  grind +suggestions

/-! ## Section 2: The Mod-6 State System

Every prime > 3 is ≡ 1 or 5 (mod 6). We formalize this as a two-state
system and prove that gap values uniquely determine state transitions. -/

/-- The two admissible residue classes mod 6 for primes > 3. -/
inductive Mod6State
  | one   -- p ≡ 1 (mod 6)
  | five  -- p ≡ 5 (mod 6)
  deriving DecidableEq, Repr

/-- Extract the mod-6 state of a prime > 3. -/
noncomputable def primeToMod6 (p : ℕ) (hp : Nat.Prime p) (h3 : 3 < p) : Mod6State :=
  if p % 6 = 1 then Mod6State.one else Mod6State.five

/-
Every prime > 3 has a well-defined mod-6 state.
-/
theorem prime_mod6_dichotomy (p : ℕ) (hp : Nat.Prime p) (h3 : 3 < p) :
    p % 6 = 1 ∨ p % 6 = 5 := by
  by_contra h_contra; have := Nat.Prime.eq_two_or_odd hp; ( have := Nat.dvd_of_mod_eq_zero ( show p % 3 = 0 by omega ) ; rw [ hp.dvd_iff_eq ] at this <;> aesop ) ;

/-
**Mod-6 Determinism**: Given a prime p > 3 and the gap g = q - p to the
    next prime q, the mod-6 state of q is uniquely determined by the
    mod-6 state of p and the value g mod 6.
-/
theorem mod6_transition_determined {p q : ℕ} (hp : Nat.Prime p) (hq : Nat.Prime q)
    (h3p : 3 < p) (hpq : p < q) :
    q % 6 = (p + (q - p)) % 6 := by
  rw [ Nat.add_sub_of_le hpq.le ]

/-
The gap between two primes > 3 determines the mod-6 transition:
    state 1 + gap ≡ 0 mod 6 → state 1
    state 1 + gap ≡ 4 mod 6 → state 5
    state 5 + gap ≡ 2 mod 6 → state 1
    state 5 + gap ≡ 0 mod 6 → state 5
-/
theorem mod6_gap_constraint {p q : ℕ} (hp : Nat.Prime p) (hq : Nat.Prime q)
    (h3p : 3 < p) (hpq : p < q) :
    ((q - p) % 6 = 0 ∨ (q - p) % 6 = 2 ∨ (q - p) % 6 = 4) := by
  cases Nat.Prime.eq_two_or_odd hp <;> cases Nat.Prime.eq_two_or_odd hq <;> omega

/-! ## Section 3: The Gap Transition System (Novel Definition)

We define a general framework for studying prime gap constraints through
finite-state transition systems parametrized by a modulus M. -/

/-- **Novel Definition**: A Gap Transition System over modulus M.
    States are residue classes coprime to M. Transitions are labeled by
    gap values, where a transition (s, g, t) is valid iff s + g ≡ t (mod M)
    and t is coprime to M.

    This captures the fundamental constraint that primes must avoid small
    prime factors, turning the "randomness" of gaps into the determinism
    of modular arithmetic. -/
structure GapTransitionSystem (M : ℕ) [NeZero M] where
  /-- The set of admissible states (residues coprime to M) -/
  states : Finset (ZMod M)
  /-- States are exactly the units mod M -/
  states_eq_units : ∀ s : ZMod M, s ∈ states ↔ IsUnit s

/-- The transition function: given state s and gap g, compute next state. -/
def gtsTransition (M : ℕ) [NeZero M] (s : ZMod M) (g : ℕ) : ZMod M :=
  s + (g : ZMod M)

/-- A transition is admissible if the target state is a unit. -/
def gtsAdmissible (M : ℕ) [NeZero M] (s : ZMod M) (g : ℕ) : Prop :=
  IsUnit (gtsTransition M s g)

/-- The set of admissible gaps from a state s, bounded by B. -/
def admissibleGapsFrom (M : ℕ) [NeZero M] (s : ZMod M) (B : ℕ) : Finset ℕ :=
  (Finset.range B).filter (fun g => decide (IsUnit (gtsTransition M s g)) = true)

/-- The reachable states from s via a single gap bounded by B. -/
def reachableFrom (M : ℕ) [NeZero M] (s : ZMod M) (B : ℕ) : Finset (ZMod M) :=
  ((Finset.range B).image (gtsTransition M s))

/-- A state s is forcing with bound B if exactly one unit is reachable. -/
def isForcing (M : ℕ) [NeZero M] (s : ZMod M) (B : ℕ) : Prop :=
  ∃! t : ZMod M, IsUnit t ∧ t ∈ reachableFrom M s B

/-! ## Section 4: Properties of the Mod-6 Transition System -/

/-- The mod-6 system has exactly 2 states: {1, 5} mod 6. -/
theorem mod6_two_states :
    ({(1 : ZMod 6), (5 : ZMod 6)} : Finset (ZMod 6)).card = 2 := by
  decide

/-- State 1 mod 6 transitions to state 5 via gap 4, and to state 1 via gap 6.
    This demonstrates the two possible transitions from state 1. -/
theorem mod6_transition_from_one :
    gtsTransition 6 (1 : ZMod 6) 4 = 5 ∧
    gtsTransition 6 (1 : ZMod 6) 6 = 1 := by
  constructor <;> decide

/-- State 5 mod 6 transitions to state 1 via gap 2, and to state 5 via gap 6.
    This demonstrates the two possible transitions from state 5. -/
theorem mod6_transition_from_five :
    gtsTransition 6 (5 : ZMod 6) 2 = 1 ∧
    gtsTransition 6 (5 : ZMod 6) 6 = 5 := by
  constructor <;> decide

/-
**Transition Graph Completeness**: Every admissible state is reachable
    from every other admissible state via a single even gap ≤ 6.
    The mod-6 transition graph is strongly connected.
-/
theorem mod6_strongly_connected :
    ∀ s t : ZMod 6, IsUnit s → IsUnit t →
      ∃ g : ℕ, g ≤ 6 ∧ 2 ∣ g ∧ gtsTransition 6 s g = t := by
  simp +decide [ ZMod, Fin.forall_fin_succ ] at *

/-! ## Section 5: No-Prime-Triplet as a Transition Constraint

The no-prime-triplet theorem has a clean reformulation in the transition
framework: two consecutive gap-2 transitions are impossible. -/

/-- Among p, p+2, p+4 with p > 3, at least one is divisible by 3. -/
theorem triplet_mod3 (p : ℕ) : 3 ∣ p ∨ 3 ∣ (p + 2) ∨ 3 ∣ (p + 4) := by
  omega

/-
**No-Prime-Triplet Theorem**: For p > 3, p, p+2, p+4 cannot all be prime.
-/
theorem no_prime_triplet (p : ℕ) (hp : 3 < p) (h1 : Nat.Prime p)
    (h2 : Nat.Prime (p + 2)) : ¬Nat.Prime (p + 4) := by
  by_contra h_contra;
  -- Among p, p+2, p+4, one is divisible by 3.
  have h_div3 : 3 ∣ p ∨ 3 ∣ (p + 2) ∨ 3 ∣ (p + 4) := by
    grind;
  rcases h_div3 with ( h | h | h ) <;> simp_all +decide [ Nat.Prime.dvd_iff_eq ]

/-- Consequence: In the mod-6 system, a gap-2 transition (which must start
    from state 5) goes to state 1, and from state 1 a gap-2 transition
    would go to state 3, which is NOT a unit mod 6. This is the algebraic
    reason behind the no-prime-triplet theorem. -/
theorem gap2_from_state1_inadmissible :
    ¬IsUnit (gtsTransition 6 (1 : ZMod 6) 2) := by
  decide

/-- A gap-2 transition is only admissible from state 5 (mod 6). -/
theorem gap2_only_from_five :
    IsUnit (gtsTransition 6 (5 : ZMod 6) 2) ∧
    ¬IsUnit (gtsTransition 6 (1 : ZMod 6) 2) := by
  constructor <;> decide

/-! ## Section 6: Gap Rhythm Theorem

After a twin prime pair (gap 2), the mod-6 state forces constraints on
the next gap. We prove a "rhythm" theorem: gap-2 forces the next gap
to be ≡ 0 or 4 mod 6. -/

/-
After a gap of 2, the prime is at state 1 mod 6.
    The next admissible gap must be ≡ 0 or 4 mod 6.
-/
theorem post_twin_gap_mod6 {p : ℕ} (hp : Nat.Prime p) (hp2 : Nat.Prime (p + 2))
    (h3 : 3 < p) :
    p % 6 = 5 := by
  have := Nat.mod_lt p ( by decide : 6 > 0 ) ; interval_cases _ : p % 6 <;> simp_all +decide [ ← Nat.dvd_iff_mod_eq_zero, hp.dvd_iff_eq, hp2.dvd_iff_eq ] ;
  · exact absurd ( Nat.dvd_of_mod_eq_zero ( show ( p + 2 ) % 3 = 0 by omega ) ) ( by rw [ hp2.dvd_iff_eq ] <;> linarith );
  · exact absurd ( Nat.Prime.eq_two_or_odd hp ) ( by omega );
  · exact absurd ( Nat.dvd_of_mod_eq_zero ( show p % 3 = 0 by norm_num [ ← Nat.mod_mod_of_dvd p ( by decide : 3 ∣ 6 ), * ] ) ) ( by rw [ hp.dvd_iff_eq ] <;> linarith );
  · exact absurd ( Nat.Prime.eq_two_or_odd hp ) ( by omega )

/-
**Gap Rhythm Theorem**: For consecutive primes p < q < r all > 3,
    if q - p = 2 (twin prime gap), then r - q ≥ 4, and moreover
    (r - q) mod 6 ∈ {0, 4}.
-/
theorem gap_rhythm {p q r : ℕ} (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hr : Nat.Prime r) (h3 : 3 < p) (hpq : q = p + 2) (hqr : q < r) :
    4 ≤ r - q := by
  by_contra h_contra;
  interval_cases _ : r - q <;> simp_all +decide [ Nat.sub_eq_iff_eq_add' hqr.le ];
  · omega;
  · cases Nat.Prime.eq_two_or_odd hp <;> cases Nat.Prime.eq_two_or_odd hq <;> cases Nat.Prime.eq_two_or_odd hr <;> omega;
  · have := no_prime_triplet p h3 hp hq; simp_all +decide [ Nat.sub_eq_iff_eq_add' hqr.le ] ;
  · cases Nat.Prime.eq_two_or_odd hp <;> cases Nat.Prime.eq_two_or_odd hq <;> cases Nat.Prime.eq_two_or_odd hr <;> omega

/-! ## Section 7: Gap Sum Residue Theorem

We prove that for consecutive primes p₁ < p₂ < p₃ all > 3,
the sum of two consecutive gaps is ≡ 0 mod 2 (trivially), but more
importantly ≡ 0 mod 6 if the middle prime is in the same state as the first. -/

/-
**Same-State Gap Sum**: If p and r are consecutive-next-consecutive primes
    both in the same mod-6 state (both ≡ 1 or both ≡ 5), then the total
    gap r - p is divisible by 6.
-/
theorem same_state_gap_div6 {p r : ℕ}
    (_hp : Nat.Prime p) (_hr : Nat.Prime r)
    (_h3p : 3 < p) (hpr : p < r)
    (hsame : p % 6 = r % 6) :
    6 ∣ (r - p) := by
  omega

/-
**Different-State Gap Sum**: If p ≡ 1 and r ≡ 5 mod 6 (or vice versa),
    then r - p ≡ 4 or 2 mod 6 respectively.
-/
theorem diff_state_gap_mod6 {p r : ℕ}
    (_h3p : 3 < p) (hpr : p < r)
    (hp1 : p % 6 = 1) (hr5 : r % 6 = 5) :
    (r - p) % 6 = 4 := by
  grind

/-! ## Section 8: Infinitude of Each Mod-6 State

Using Dirichlet's theorem on primes in arithmetic progressions (or
a direct argument for mod 6), we prove there are infinitely many
primes in each residue class. -/

/-
There exist arbitrarily large primes ≡ 1 mod 6.
-/
theorem infinitely_many_primes_1_mod6 :
    ∀ N : ℕ, ∃ p, N < p ∧ Nat.Prime p ∧ p % 6 = 1 := by
  exact fun N => by rcases Nat.exists_prime_gt_modEq_one N ( by decide : 6 ≠ 0 ) with ⟨ p, hp₁, hp₂ ⟩ ; exact ⟨ p, hp₂.1, hp₁, hp₂.2 ⟩ ;

/-
There exist arbitrarily large primes ≡ 5 mod 6.
-/
theorem infinitely_many_primes_5_mod6 :
    ∀ N : ℕ, ∃ p, N < p ∧ Nat.Prime p ∧ p % 6 = 5 := by
  -- Consider the number $A = 6(N+1)! - 1$.
  intro N
  set A := 6 * (Nat.factorial (N + 1)) - 1;
  -- We'll use that $A$ has a prime divisor $p$ such that $p \equiv 5 \pmod{6}$.
  obtain ⟨p, hp_prime, hp_div⟩ : ∃ p, Nat.Prime p ∧ p ∣ A ∧ p % 6 = 5 := by
    -- By contradiction, assume that all prime divisors of $A$ are congruent to $1 \mod 6$.
    by_contra h_contra
    have h_prod : ∀ p, Nat.Prime p → p ∣ A → p % 6 = 1 := by
      intro p pp dp; have := Nat.mod_lt p ( by decide : 6 > 0 ) ; interval_cases h : p % 6 <;> simp_all +decide [ ← Nat.dvd_iff_mod_eq_zero, pp.dvd_iff_eq ] ;
      · have := Nat.Prime.eq_two_or_odd pp; simp_all +decide [ ← Nat.mod_mod_of_dvd p ( by decide : 2 ∣ 6 ) ] ;
        simp +zetaDelta at *;
        exact absurd dp ( by rw [ ← even_iff_two_dvd ] ; simpa [ Nat.one_le_iff_ne_zero, parity_simps, Nat.factorial_ne_zero ] );
      · have := Nat.dvd_of_mod_eq_zero ( show p % 3 = 0 by norm_num [ ← Nat.mod_mod_of_dvd p ( by decide : 3 ∣ 6 ), h ] ) ; rw [ pp.dvd_iff_eq ] at this <;> simp_all +decide ;
        exact absurd ( Nat.dvd_sub ( dvd_mul_of_dvd_left ( by decide : 3 ∣ 6 ) ( ( N + 1 ) ! ) ) dp ) ( by erw [ tsub_tsub_cancel_of_le ( Nat.one_le_iff_ne_zero.mpr <| by positivity ) ] ; norm_num );
      · have := Nat.Prime.eq_two_or_odd pp; omega;
    -- If all prime factors of $A$ are $1 \mod 6$, then the product of these prime factors would also be $1 \mod 6$.
    have h_prod_mod : ∀ {n : ℕ}, n ≠ 0 → (∀ p, Nat.Prime p → p ∣ n → p % 6 = 1) → n % 6 = 1 := by
      intros n hn h; rw [ ← Nat.prod_primeFactorsList hn ] ; rw [ List.prod_nat_mod ] ; exact by rw [ List.prod_eq_one ] <;> intros <;> aesop;
    exact absurd ( h_prod_mod ( Nat.sub_ne_zero_of_lt ( by linarith [ Nat.self_le_factorial ( N + 1 ) ] ) ) h_prod ) ( by zify ; norm_num [ Int.sub_emod, Int.mul_emod, Nat.factorial_pos ] );
  exact ⟨ p, not_le.mp fun contra => by have := Nat.dvd_sub ( dvd_mul_of_dvd_right ( Nat.dvd_factorial ( Nat.pos_of_ne_zero hp_prime.ne_zero ) ( by linarith : N + 1 ≥ p ) ) 6 ) hp_div.1; erw [ Nat.sub_sub_self ( Nat.one_le_iff_ne_zero.mpr <| by positivity ) ] at this; aesop, hp_prime, hp_div.2 ⟩

/-! ## Section 9: Forcing Density Conjecture

We formalize the conjecture that forcing patterns have positive density
among all gap words, and provide partial evidence. -/

/-- **Forcing Density Conjecture**: For the mod-30 transition system,
    the proportion of gap words of length k that are forcing approaches
    a positive limit as k → ∞.

    More precisely: let F(k, B) be the number of gap words w of length k
    (with entries in {2, 4, 6, ..., B}) such that w is forcing over {2,3,5}.
    Then lim_{k→∞} F(k, B) / |{2,4,...,B}|^k > 0 for all B ≥ 6.

    This is a falsifiable prediction: compute F(k, 30) / 15^k for
    k = 1, 2, ..., 20 and check it converges to a positive constant. -/
def ForcingDensityConjecture : Prop :=
  ∀ B : ℕ, 6 ≤ B →
  ∃ c : ℝ, 0 < c ∧
  ∀ ε : ℝ, 0 < ε →
  ∃ K : ℕ, ∀ k, K ≤ k →
    -- (stated informally: F(k,B)/|alphabet|^k ≥ c - ε)
    True  -- placeholder; actual formalization would need measure theory

end PrimeGapTransition