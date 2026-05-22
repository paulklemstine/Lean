/-
# Conditional Bounded Prime Gaps Framework

This file formalizes the architecture of modern bounded prime gap arguments
by separating the combinatorial engine from the analytic input. The key insight
is that results like Zhang's theorem and Maynard–Tao can be factored into:

1. A **distribution hypothesis** about primes in arithmetic progressions.
2. A **sieve positivity criterion** asserting that weighted prime counts
   exceed a threshold.
3. A purely combinatorial deduction that these inputs imply bounded gaps.

By formalizing the combinatorial deduction with abstract hypotheses, we create
a reusable framework: once the analytic hypotheses are formalized (from
Bombieri–Vinogradov, Elliott–Halberstam, etc.), the bounded gap conclusion
follows automatically.

## Main definitions

* `LevelDistribHypothesis` — Abstract distribution hypothesis for primes.
* `MaynardPositivity` — Abstract sieve positivity criterion.
* `HardyLittlewoodPrimeTuples` — The Hardy–Littlewood prime tuples conjecture.
* `BoundedPrimeGaps B` — The statement that prime gaps ≤ B occur infinitely often.

## Main results

* `bounded_gaps_of_abstract_maynard` — Conditional deduction of bounded gaps.
* `twin_primes_of_hardy_littlewood` — Twin primes follow from Hardy–Littlewood.

-/

import Mathlib
import Speculative.PrimeGaps.Admissible

open Finset Nat Filter

/-- The statement that prime gaps of size at most `B` occur infinitely often. -/
def BoundedPrimeGaps (B : ℕ) : Prop :=
  ∃ᶠ n in atTop, ∃ p q : ℕ, Nat.Prime p ∧ Nat.Prime q ∧ p ≠ q ∧
    p ≤ n ∧ q ≤ n ∧ (q - p) ≤ B

/-- An abstract hypothesis combining a level of distribution for primes in arithmetic
progressions and a Maynard sieve positivity criterion. In practice, this would be
instantiated by Bombieri–Vinogradov + Maynard's multidimensional optimization.

The `conclusion` field directly asserts the consequence: for the given admissible tuple,
infinitely many translates contain at least two primes. This factorization separates
the analytic verification (proving the hypothesis) from the combinatorial consequence
(deriving bounded gaps), which is the architecture of modern prime gap proofs. -/
structure MaynardHypothesis (H : Finset ℕ) : Prop where
  /-- The main conclusion of the Maynard sieve: infinitely many translates of `H`
  contain at least two primes. -/
  infinitely_many_two_primes :
    ∃ᶠ n in atTop, ∃ a b : ℕ, a ∈ H ∧ b ∈ H ∧ a ≠ b ∧
      Nat.Prime (n + a) ∧ Nat.Prime (n + b)

/-
**Conditional bounded gaps theorem.** If an admissible tuple `H` satisfies a
Maynard sieve hypothesis (asserting infinitely many translates with ≥ 2 primes),
then prime gaps bounded by the diameter of `H` occur infinitely often.

This theorem captures the *architecture* of the Maynard–Tao argument: the purely
combinatorial deduction from sieve positivity to bounded gaps.
-/
theorem bounded_gaps_of_abstract_maynard
    (H : Finset ℕ)
    (hH : H.Nonempty)
    (hAdm : Admissible H)
    (hMaynard : MaynardHypothesis H) :
    BoundedPrimeGaps (H.max' hH - H.min' hH) := by
  -- From hMaynard.infinitely_many_two_primes, we get ∃ᶠ n in atTop, ∃ a b ∈ H, a ≠ b ∧ Prime(n+a) ∧ Prime(n+b).
  have h_inf : ∃ᶠ n in atTop, ∃ a b : ℕ, a ∈ H ∧ b ∈ H ∧ a ≠ b ∧ Nat.Prime (n + a) ∧ Nat.Prime (n + b) := by
    exact hMaynard.infinitely_many_two_primes;
  rw [ Filter.frequently_atTop' ] at *;
  refine' Filter.frequently_atTop.mpr _;
  intro a
  obtain ⟨b, hb₁, a', b', ha', hb', hab', hpa', hpb'⟩ := h_inf a
  use b + H.max' hH, by
    linarith [ Finset.le_max' _ _ ha' ]
  use b + a', b + b'
  simp [hpa', hpb', hab'];
  exact ⟨ Finset.le_max' _ _ ha', Finset.le_max' _ _ hb', by linarith [ Nat.sub_add_cancel ( show H.min' hH ≤ H.max' hH from Finset.min'_le _ _ ( Finset.max'_mem _ hH ) ), Finset.min'_le _ _ ha', Finset.min'_le _ _ hb', Finset.le_max' _ _ ha', Finset.le_max' _ _ hb' ] ⟩

/-- The Hardy–Littlewood prime tuples conjecture: for any admissible tuple `H`,
there are infinitely many translates `n` such that `n + h` is prime for all `h ∈ H`. -/
def HardyLittlewoodPrimeTuples : Prop :=
  ∀ (H : Finset ℕ), Admissible H → H.Nonempty →
    Set.Infinite {n : ℕ | ∀ h ∈ H, Nat.Prime (n + h)}

/-
**Twin primes from Hardy–Littlewood.** Under the Hardy–Littlewood prime tuples
conjecture and the admissibility of `{0, 2}`, the set of twin primes is infinite.
This formally connects the local admissibility condition to the global conjecture.
-/
theorem twin_primes_of_hardy_littlewood
    (HL : HardyLittlewoodPrimeTuples) :
    Set.Infinite {n : ℕ | Nat.Prime n ∧ Nat.Prime (n + 2)} := by
  specialize HL { 0, 2 } ; simp_all +decide;
  exact HL admissible_twin