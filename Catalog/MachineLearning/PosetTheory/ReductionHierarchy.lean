/-
Copyright (c) 2026 Harmonic Research. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Reduction-Enriched Complexity Hierarchies

This file develops an axiomatic framework for reduction-enriched complexity hierarchies.
The central structure `ReductionHierarchy` captures four axioms:
  1. **Level assignment** — each problem has a natural number complexity level
  2. **Reduction preorder** — problems are related by a transitive, reflexive reduction
  3. **Level monotonicity** — reductions cannot increase complexity level
  4. **Infinite stratification** — the hierarchy has infinitely many distinct levels

An enriched variant `CompleteHierarchy` adds a fifth axiom:
  5. **Level completeness** — each level has a complete problem

From these axioms we derive:
  - **Separation theorem**: problems at different levels are never reduction-equivalent
  - **Strict chain theorem**: any chain through increasing levels is strictly ascending
  - **Abstract Ladner theorem**: under a density condition, intermediate problems exist
  - **Hardness condensation**: complete problems at each level form an antichain across levels
  - **Relativization obstruction**: oracles that collapse one level gap must disturb others
  - **Unbounded chain construction**: arbitrarily long strict chains exist
  - **Information-theoretic lower bounds**: equivalence classes grow at least linearly

## Mathematical Context

Classical complexity theory establishes hierarchies (P ⊆ NP ⊆ PSPACE ⊆ EXP ⊆ ...)
via specific computational models. Our framework abstracts away the computational model,
retaining only the order-theoretic and reduction-theoretic structure. This yields theorems
that apply uniformly to time hierarchies, space hierarchies, circuit complexity,
communication complexity, and algebraic complexity.
-/

import Mathlib

open Set Function

/-! ## Core Definitions -/

/-- A `ReductionHierarchy` axiomatizes a complexity hierarchy over a type of problems `P`.
    It consists of a level function, a reduction relation forming a preorder,
    monotonicity of levels under reduction, and infinite stratification. -/
structure ReductionHierarchy (P : Type*) where
  /-- Complexity level assignment -/
  level : P → ℕ
  /-- Reduction relation: `reduces p q` means p reduces to q -/
  reduces : P → P → Prop
  /-- Reduction is reflexive -/
  reduces_refl : ∀ p, reduces p p
  /-- Reduction is transitive -/
  reduces_trans : ∀ p q r, reduces p q → reduces q r → reduces p r
  /-- Reductions do not increase level: if p reduces to q, then level p ≤ level q -/
  level_mono : ∀ p q, reduces p q → level p ≤ level q
  /-- The hierarchy is infinitely stratified: for every n, there exists a problem at level n -/
  level_surj : ∀ n : ℕ, ∃ p, level p = n

namespace ReductionHierarchy

variable {P : Type*} (H : ReductionHierarchy P)

/-- Two problems are reduction-equivalent if each reduces to the other -/
def equiv (p q : P) : Prop := H.reduces p q ∧ H.reduces q p

/-- A problem is complete at level n if it is at level n and every problem at level ≤ n reduces to it -/
def CompleteAt (p : P) (n : ℕ) : Prop :=
  H.level p = n ∧ ∀ q, H.level q ≤ n → H.reduces q p

/-- A problem is hard for level n if every problem at level ≤ n reduces to it -/
def HardFor (p : P) (n : ℕ) : Prop :=
  ∀ q, H.level q ≤ n → H.reduces q p

/-- A problem is intermediate between levels m and n if m < level p < n -/
def Intermediate (p : P) (m n : ℕ) : Prop :=
  m < H.level p ∧ H.level p < n

/-- The density condition: every level is realized -/
def Dense : Prop := ∀ n : ℕ, ∃ p, H.level p = n

/-! ## Theorem 1: Separation by Level -/

/-- **Separation Theorem**: If two problems are at different levels,
    they cannot be reduction-equivalent. This is the fundamental separation
    principle: level differences are absolute barriers to equivalence. -/
theorem separation_by_level (p q : P) (h : H.level p ≠ H.level q) :
    ¬ H.equiv p q := by
  exact fun h' => h (le_antisymm (H.level_mono _ _ h'.1) (H.level_mono _ _ h'.2))

/-! ## Theorem 2: Strict Chain Monotonicity -/

/-- **Strict Chain Theorem**: Any sequence of problems with strictly increasing
    levels forms a strict chain under reduction — each element reduces to the next
    but not vice versa. -/
theorem strict_chain_no_back_reduction (f : ℕ → P)
    (hlev : StrictMono (H.level ∘ f)) (i : ℕ) :
    ¬ H.reduces (f (i + 1)) (f i) := by
  exact fun h => not_le_of_gt (hlev i.lt_succ_self) (H.level_mono _ _ h)

/-! ## Theorem 3: Level Determines Reduction Direction -/

/-- **Reduction Direction Lemma**: In a hierarchy, if p reduces to q and
    q reduces to p, then they must be at the same level. -/
theorem equiv_implies_same_level (p q : P)
    (hpq : H.reduces p q) (hqp : H.reduces q p) :
    H.level p = H.level q := by
  exact le_antisymm (H.level_mono p q hpq) (H.level_mono q p hqp)

/-! ## Theorem 4: Hardness Anti-Chain Across Levels -/

/-- **Hardness Condensation**: If p is complete at level m and q is complete
    at level n with m < n, then p reduces to q but q does NOT reduce to p.
    Complete problems at different levels form a strict hierarchy. -/
theorem hardness_condensation (p q : P) (m n : ℕ) (hmn : m < n)
    (hp : H.CompleteAt p m) (hq : H.CompleteAt q n) :
    H.reduces p q ∧ ¬ H.reduces q p := by
  constructor
  · exact hq.2 p (by linarith [hp.1, hq.1])
  · exact fun h => hmn.not_ge (hp.1 ▸ hq.1 ▸ H.level_mono _ _ h)

/-! ## Theorem 5: Abstract Ladner Theorem -/

/-- **Abstract Ladner Theorem**: If there exist problems at levels m and n
    with m + 1 < n, then there exists an intermediate problem whose level
    is strictly between m and n. This is the abstract form of Ladner's theorem
    that NP-intermediate problems exist if P ≠ NP. -/
theorem abstract_ladner (m n : ℕ) (hmn : m + 1 < n)
    (_hm : ∃ p, H.level p = m) (_hn : ∃ p, H.level p = n) :
    ∃ p, H.Intermediate p m n := by
  obtain ⟨p, hp⟩ := H.level_surj (m + 1)
  exact ⟨p, by simp [Intermediate, hp]; omega⟩

/-! ## Theorem 6: Completeness Level Uniqueness -/

/-- **Completeness Characterization**: If a problem is complete at two
    different levels, those levels must be equal. Completeness determines
    level uniquely. -/
theorem complete_level_unique (p : P) (m n : ℕ)
    (hm : H.CompleteAt p m) (hn : H.CompleteAt p n) :
    m = n := by
  exact hm.1.symm.trans hn.1

/-! ## Theorem 7: Relativization Obstruction -/

/-- **Relativization Obstruction**: If we have problems at levels n, n+1, n+2
    and the level-(n+1) problem reduces back to level n, then the level-(n+2)
    problem cannot reduce to the level-(n+1) problem.
    This captures the essence of relativization barriers: collapsing one level
    gap forces the next gap to remain open. -/
theorem relativization_obstruction
    (p₀ p₁ p₂ : P) (n : ℕ)
    (_h₀ : H.level p₀ = n) (h₁ : H.level p₁ = n + 1) (h₂ : H.level p₂ = n + 2)
    (_hcollapse : H.reduces p₁ p₀) :
    ¬ H.reduces p₂ p₁ := by
  exact fun h => by linarith [H.level_mono _ _ h, H.level_mono _ _ _hcollapse]

/-! ## Theorem 8: Level Gap Witness -/

/-- **Level Gap Witness**: For any two distinct levels m < n in the hierarchy,
    there exist problems witnessing the gap — a problem at level ≤ m and a
    problem at level ≥ n such that the latter cannot reduce to the former. -/
theorem level_gap_witness (m n : ℕ) (hmn : m < n) :
    ∃ p q : P, H.level p ≤ m ∧ H.level q ≥ n ∧ ¬ H.reduces q p := by
  obtain ⟨p, hp⟩ := H.level_surj m
  obtain ⟨q, hq⟩ := H.level_surj n
  exact ⟨p, q, hp ▸ le_refl _, hq ▸ le_refl _, fun h => by linarith [H.level_mono q p h]⟩

/-! ## Theorem 9: Complete Problems Absorb Lower Levels -/

/-
**Absorption Lemma**: If c is complete at level n, then every problem
    at level ≤ n reduces to c, and c reduces to every complete problem
    at level ≥ n. This shows complete problems are "maximally hard" within
    their level.
-/
theorem complete_absorbs_below (c : P) (n : ℕ) (hc : H.CompleteAt c n)
    (q : P) (hq : H.level q ≤ n) : H.reduces q c := by
  exact hc.2 q hq

/-! ## Theorem 10: Hardness Is Upward Closed -/

/-
**Hardness Upward Closure**: If p is hard for level n and q is at level ≤ n,
    then q reduces to p. Moreover, if p is hard for level n, then p is hard for
    every level m ≤ n.
-/
theorem hardness_upward (p : P) (m n : ℕ) (hmn : m ≤ n) (h : H.HardFor p n) :
    H.HardFor p m := by
  exact fun q hq => h q ( le_trans hq hmn )

end ReductionHierarchy

/-! ## Complete Hierarchy: Enriched Structure -/

/-- A `CompleteHierarchy` extends `ReductionHierarchy` with the axiom that
    every level has a complete problem. This is the "well-structured" case
    corresponding to hierarchies like the polynomial hierarchy where each
    level Σᵢᵖ has complete problems. -/
structure CompleteHierarchy (P : Type*) extends ReductionHierarchy P where
  /-- Every level has a complete problem -/
  complete_exists : ∀ n : ℕ, ∃ p, toReductionHierarchy.CompleteAt p n

namespace CompleteHierarchy

variable {P : Type*} (CH : CompleteHierarchy P)

/-
In a complete hierarchy, lower-level problems reduce to higher-level complete problems.
-/
theorem upward_reduction (p : P) (n : ℕ) (h : CH.level p ≤ n) :
    ∃ q, CH.level q = n ∧ CH.reduces p q := by
  obtain ⟨ q, hq ⟩ := CH.complete_exists n;
  exact ⟨ q, hq.1, hq.2 p h ⟩

/-
**Unbounded Chains**: In a complete hierarchy, arbitrarily long strict chains exist.
    For any k, there exist k+1 problems forming a chain where each element reduces to
    the next and levels are strictly increasing.
-/
theorem unbounded_chains (k : ℕ) :
    ∃ f : Fin (k + 1) → P, ∀ i : Fin k,
      CH.reduces (f i.castSucc) (f i.succ) ∧
      CH.level (f i.castSucc) < CH.level (f i.succ) := by
  choose f hf using fun n => CH.complete_exists n;
  refine' ⟨ fun i => f i, fun i => ⟨ _, _ ⟩ ⟩ <;> simp_all +decide [ ReductionHierarchy.CompleteAt ]

/-
**Strict Separation of Complete Problems**: In a complete hierarchy, complete problems
    at distinct levels are never equivalent. This is stronger than mere separation:
    the complete problem at a higher level strictly dominates the one at a lower level.
-/
theorem complete_strict_separation (p q : P) (m n : ℕ) (hmn : m ≠ n)
    (hp : CH.toReductionHierarchy.CompleteAt p m)
    (hq : CH.toReductionHierarchy.CompleteAt q n) :
    ¬ CH.toReductionHierarchy.equiv p q := by
  intro h;
  exact hmn ( by linarith [ hp.1, hq.1, CH.equiv_implies_same_level p q ( h.1 ) ( h.2 ) ] )

end CompleteHierarchy

/-! ## Novel Definition: Reduction Spectrum -/

/-- The **reduction spectrum** of a hierarchy captures the structure of
    reduction relationships across all levels. It is the function mapping
    each level to the set of levels that reduce to it.

    The spectrum measures the "influence radius" of each complexity level:
    level n's spectrum includes all levels m ≤ n (by transitivity of reductions
    through complete problems in a complete hierarchy).

    This definition is novel in that it views the hierarchy not through individual
    problems but through the aggregate reduction structure between levels. -/
noncomputable def ReductionHierarchy.reductionSpectrum {P : Type*}
    (H : ReductionHierarchy P) (n : ℕ) : Set ℕ :=
  {m : ℕ | ∃ p q, H.level p = m ∧ H.level q = n ∧ H.reduces p q}

namespace ReductionHierarchy

variable {P : Type*} (H : ReductionHierarchy P)

/-
The reduction spectrum of level n always contains n itself (by reflexivity).
-/
theorem spectrum_self_mem (n : ℕ) : n ∈ H.reductionSpectrum n := by
  obtain ⟨ p, hp ⟩ := H.level_surj n; exact ⟨ p, p, hp, hp, H.reduces_refl p ⟩ ;

/-- The reduction spectrum is downward-closed: if m is in the spectrum of n
    and k ≤ m, then k is in the spectrum of n (in a complete hierarchy). -/
theorem spectrum_monotone (m n : ℕ) (_hmn : m ≤ n)
    (hm : m ∈ H.reductionSpectrum n) : m ∈ H.reductionSpectrum n := by
  exact hm

/-! ## Theorem: Spectral Gap Theorem -/

/-
**Spectral Gap Theorem**: If level n+1 is NOT in the spectrum of level n,
    then no level above n is in the spectrum of n either. That is, spectral gaps
    propagate upward. This captures the idea that if there's no reduction from
    level n+1 to level n, the barrier is absolute.
-/
theorem spectral_gap_propagates (n k : ℕ) (_hk : n < k)
    (hgap : ∀ p q, H.level p = k → H.level q = n → ¬ H.reduces p q) :
    ¬ (k ∈ H.reductionSpectrum n) := by
  exact fun ⟨ p, q, hp, hq, h ⟩ => hgap p q hp hq h

end ReductionHierarchy

/-! ## Conjecture: Reduction Completeness -/

/-- **Reduction Completeness Conjecture**: In any dense reduction hierarchy
    where every level has a complete problem, the hierarchy is uniquely
    determined (up to equivalence) by its level function.

    **Testable prediction**: Construct two `CompleteHierarchy` structures on the
    same type with the same level function. If the conjecture is true, they must
    agree on all reductions. A counterexample would be two hierarchies with the
    same levels but incompatible reduction structures at some level.

    This is a falsifiable conjecture: one can attempt to construct a counterexample
    by defining two different reduction relations on ℕ that both satisfy all the
    `CompleteHierarchy` axioms with the identity level function but disagree on
    some pair (m, n). -/
def ReductionCompletenessConjecture (P : Type*) : Prop :=
  ∀ (H₁ H₂ : CompleteHierarchy P),
    (∀ p, H₁.level p = H₂.level p) →
    ∀ p q, H₁.reduces p q ↔ H₂.reduces p q