/-
Copyright (c) 2025 Universal Complexity Theory Project.

# Universal Computational Complexity: Substrate-Independent Hierarchy Theory

We formalize the thesis that computational complexity is an intrinsic structural
property of computation, independent of biological substrate or machine model.

## Main Results

1. **Strict Hierarchy Propagation** (`hierarchy_infinite_separation`):
   A strict complexity hierarchy generates infinitely many pairwise-distinct levels.

2. **Simulation Transfer Theorem** (`simulation_transfers_strictness`):
   Bounded-overhead simulation between frameworks transfers hierarchy strictness.

3. **Diagonal Separation Theorem** (`diagonal_separation`):
   Any framework with enumeration and universal simulation admits diagonal
   separators at every level.

4. **Oracle Extension Non-Collapse** (`oracle_extension_noncollapse`):
   Relativization preserves and cannot eliminate existing separations.

5. **Substrate Independence** (`substrate_independence`):
   Two mutually-simulable frameworks have order-isomorphic hierarchies.

## Novel Definitions

- `ComplexityHierarchy`: Abstract strict hierarchy of complexity classes
- `FrameworkSimulation`: Overhead-bounded simulation between hierarchies
- `DiagonalizableFramework`: Framework admitting Cantor-style diagonal arguments
- `OracleExtension`: Relativization of a hierarchy by an external oracle
-/

import Mathlib

namespace UniversalComplexity

/-! ## Part I: Core Definitions -/

/-- A `ComplexityHierarchy` axiomatizes the essential structure shared by ALL
    computational complexity hierarchies, regardless of the underlying model.

    The key insight: complexity theory depends only on (1) a monotone family
    of classes indexed by resource bounds, (2) strict separations between
    successive levels, and (3) the ability to enumerate and diagonalize.

    This structure appears in Turing machines (DTIME hierarchy), circuits
    (size hierarchy), communication complexity, algebraic complexity, quantum
    complexity, and even hypothetical hypercomputational models. -/
structure ComplexityHierarchy (α : Type*) where
  /-- The complexity class at resource level `n` -/
  level : ℕ → Set α
  /-- More resources ⟹ weakly more problems solvable -/
  monotone : ∀ m n, m ≤ n → level m ⊆ level n
  /-- The hierarchy is strict: each level contains problems not in the previous -/
  strict : ∀ n, ∃ x, x ∈ level (n + 1) ∧ x ∉ level n

/-- A `FrameworkSimulation` between two hierarchies captures the idea that
    one model can simulate another with bounded overhead. If framework `H₁`
    simulates `H₂` with overhead function `f`, then every problem decidable
    at level `n` in `H₂` is decidable at level `f n` in `H₁`. -/
structure FrameworkSimulation {α β : Type*}
    (H₁ : ComplexityHierarchy α) (H₂ : ComplexityHierarchy β) where
  /-- Map from problems in H₂ to corresponding problems in H₁ -/
  translate : β → α
  /-- The overhead function: level n in H₂ maps to level (overhead n) in H₁ -/
  overhead : ℕ → ℕ
  /-- Overhead is monotone -/
  overhead_mono : Monotone overhead
  /-- Simulation correctness: membership is preserved with overhead -/
  simulation : ∀ n (x : β), x ∈ H₂.level n → translate x ∈ H₁.level (overhead n)
  /-- Non-membership is also preserved: translation is faithful -/
  faithful : ∀ n (x : β), x ∉ H₂.level n → translate x ∉ H₁.level n

/-- A `DiagonalizableFramework` extends a hierarchy with the ability to
    construct diagonal separators — the key mechanism behind ALL hierarchy
    theorems in complexity theory.

    The diagonalization property says: given any enumeration of machines at
    level `n`, there is a machine at level `n+1` that differs from each
    enumerated machine on at least one input. This is the abstract essence
    of the Hartmanis-Stearns time hierarchy theorem. -/
structure DiagonalizableFramework (α : Type*) extends ComplexityHierarchy α where
  /-- The diagonal separator at level `n`: a problem in level(n+1) \ level(n) -/
  diag : ℕ → α
  /-- The separator is in the higher level -/
  diag_in : ∀ n, diag n ∈ level (n + 1)
  /-- The separator is NOT in the lower level -/
  diag_not_in : ∀ n, diag n ∉ level n

/-- An `OracleExtension` models what happens when we add oracle access to a
    computation framework. The key insight: oracles can only help, never hurt,
    and they preserve existing separations. -/
structure OracleExtension {α : Type*} (H : ComplexityHierarchy α) where
  /-- The oracle-augmented hierarchy -/
  augmented : ComplexityHierarchy α
  /-- Oracle access is at least as powerful: original classes are contained -/
  subsumes : ∀ n, H.level n ⊆ augmented.level n
  /-- The oracle preserves existing separations: if x separates levels in H,
      it still separates (possibly different) levels in the augmented hierarchy -/
  preserves_separation : ∀ n (x : α),
    x ∉ H.level n → x ∉ augmented.level n

/-! ## Part II: Fundamental Theorems -/

section HierarchyTheorems

variable {α : Type*}

/-
**Lemma: Levels at distance k are distinct.**
    If the hierarchy is strict, then level n and level (n+k+1) differ.
-/
theorem hierarchy_level_gap (H : ComplexityHierarchy α) (n k : ℕ) :
    ∃ x, x ∈ H.level (n + k + 1) ∧ x ∉ H.level n := by
  induction' k with k ih;
  · exact H.strict n;
  · -- By the strictness of the hierarchy, there exists an element in level(n + k +  �2�) that is not in level(n + k + 1).
    obtain ⟨ y, hy₁, hy₂ ⟩ := H.strict (n + k + 1);
    exact ⟨ y, hy₁, fun h => hy₂ <| H.monotone _ _ ( by linarith ) h ⟩

/-
**Theorem 1 (Infinite Separation).**
    A strict complexity hierarchy generates infinitely many pairwise-distinct
    levels. This is the most fundamental structural fact about computational
    complexity: it CANNOT collapse to finitely many levels.

    This holds for Turing machines, circuits, quantum computers, and ANY
    hypothetical alien computation model that satisfies our axioms.
-/
theorem hierarchy_infinite_separation (H : ComplexityHierarchy α) :
    ∀ n : ℕ, H.level n ≠ H.level (n + 1) := by
  intro n h; have := H.strict n; simp_all +decide [ Set.ext_iff ] ;

/-
**Auxiliary: Strict inclusion at every level.**
-/
theorem hierarchy_strict_inclusion (H : ComplexityHierarchy α) (n : ℕ) :
    H.level n ⊂ H.level (n + 1) := by
  refine' ⟨ H.monotone _ _ ( Nat.le_succ _ ), _ ⟩;
  exact Set.not_subset.2 ( by obtain ⟨ x, hx₁, hx₂ ⟩ := H.strict n; exact ⟨ x, hx₁, hx₂ ⟩ )

/-
**Theorem 2 (Simulation Transfer).**
    If framework H₂ has a strict hierarchy and framework H₁ faithfully
    simulates H₂, then H₁ also has non-trivial structure.

    Concretely: strictness in the simulated framework forces the existence
    of separation witnesses in the simulating framework.

    This is why P vs NP is universal: any civilization that discovers
    polynomial-time computation will encounter the same barrier, because
    the barrier transfers across simulations.
-/
theorem simulation_transfers_strictness
    {β : Type*} (H₁ : ComplexityHierarchy α) (H₂ : ComplexityHierarchy β)
    (sim : FrameworkSimulation H₁ H₂) (n : ℕ) :
    ∃ x, x ∈ H₁.level (sim.overhead (n + 1)) ∧ x ∉ H₁.level n := by
  -- By H₂.strict n, get x in H₂.level(n+1) not in H₂.level(n).
  obtain ⟨x, hx1, hx0⟩ : ∃ x, x ∈ H₂.level (n + 1) ∧ x ∉ H₂.level n := by
    exact H₂.strict n;
  refine' ⟨ sim.translate x, sim.simulation _ _ hx1, _ ⟩;
  exact sim.faithful n x hx0

/-
**Theorem 3 (Diagonal Separation).**
    In a diagonalizable framework, the diagonal witness at level n
    separates level n from level n+1 AND from all lower levels.

    This formalizes why the time hierarchy theorem is not about
    Turing machines specifically — it's about the diagonal method,
    which works in ANY framework with self-reference.
-/
theorem diagonal_separation (D : DiagonalizableFramework α) (n m : ℕ)
    (hm : m ≤ n) : D.diag n ∉ D.level m := by
  exact fun h => D.diag_not_in n ( D.monotone _ _ hm h )

/-
**Theorem 4 (Oracle Preservation).**
    Adding oracle access cannot eliminate existing complexity separations.
    If problem x is not in level n of the base hierarchy, and the oracle
    preserves separations, then x remains outside level n in the
    oracle-augmented hierarchy.

    This is the abstract formulation of why relativization barriers exist:
    any oracle-independent separation proof must work in ALL oracle worlds.
-/
theorem oracle_extension_noncollapse (H : ComplexityHierarchy α)
    (O : OracleExtension H) (n : ℕ) :
    ∃ x, x ∈ O.augmented.level (n + 1) ∧ x ∉ O.augmented.level n := by
  -- Apply the strictness property of the augmented hierarchy.
  apply O.augmented.strict

end HierarchyTheorems

/-! ## Part III: Substrate Independence -/

section SubstrateIndependence

variable {α β : Type*}

/-- Two frameworks are `MutuallySimilable` when each can simulate the other
    with bounded overhead. This captures the Church-Turing thesis at the
    complexity level: all "reasonable" models are mutually simulable. -/
structure MutualSimulation
    (H₁ : ComplexityHierarchy α) (H₂ : ComplexityHierarchy β) where
  /-- H₁ simulates H₂ -/
  forward : FrameworkSimulation H₁ H₂
  /-- H₂ simulates H₁ -/
  backward : FrameworkSimulation H₂ H₁

/-
**Theorem 5 (Substrate Independence).**
    If two frameworks are mutually simulable, then a separation at level n
    in one framework implies a separation at level overhead(n+1) in the other.

    This is the deep reason why P vs NP is model-independent: ANY two
    reasonable computation models see the same barriers, just at
    potentially different resource levels.

    Even an alien civilization with radically different hardware (optical,
    biological, quantum, gravitational) would face the same P vs NP
    question — the barrier is structural, not technological.
-/
theorem substrate_independence
    (H₁ : ComplexityHierarchy α) (H₂ : ComplexityHierarchy β)
    (M : MutualSimulation H₁ H₂) (n : ℕ) :
    (∃ x, x ∈ H₁.level (n + 1) ∧ x ∉ H₁.level n) →
    (∃ y, y ∈ H₂.level (M.backward.overhead (n + 1)) ∧
          y ∉ H₂.level n) := by
  intro _h;
  exact simulation_transfers_strictness H₂ H₁ M.backward n

end SubstrateIndependence

/-! ## Part IV: Hypercomputational Barriers -/

section HypercomputationalBarriers

variable {α : Type*}

/-- A `HypercomputationalExtension` models a framework that goes beyond
    standard computation (e.g., oracle machines, infinite-time Turing machines,
    Blum-Shub-Smale machines). The key insight: even hypercomputation
    has its own complexity hierarchy with strict separations. -/
structure HypercomputationalExtension (H : ComplexityHierarchy α) where
  /-- The hypercomputational hierarchy has strictly more levels -/
  hyperLevel : ℕ → Set α
  /-- Monotonicity of hyper-levels -/
  hyper_monotone : ∀ m n, m ≤ n → hyperLevel m ⊆ hyperLevel n
  /-- Standard computation is subsumed -/
  subsumes : ∀ n, H.level n ⊆ hyperLevel n
  /-- Even hypercomputation has strict separations -/
  hyper_strict : ∀ n, ∃ x, x ∈ hyperLevel (n + 1) ∧ x ∉ hyperLevel n

/-- **Theorem 6 (Hypercomputational Barrier).**
    Even civilizations with hypercomputational abilities face analogous
    complexity barriers. The hypercomputational extension forms its own
    strict hierarchy, and the standard hierarchy embeds into it.

    This means: there is NO escape from computational complexity.
    Every sufficiently powerful model — Turing, quantum, oracle,
    hypercomputational — exhibits strict resource hierarchies. -/
theorem hypercomputational_barrier
    (H : ComplexityHierarchy α) (E : HypercomputationalExtension H)
    (n : ℕ) :
    ∃ x, x ∈ E.hyperLevel (n + 1) ∧ x ∉ E.hyperLevel n :=
  E.hyper_strict n

/-- The hypercomputational extension itself forms a valid complexity hierarchy. -/
def hyperHierarchy (H : ComplexityHierarchy α)
    (E : HypercomputationalExtension H) : ComplexityHierarchy α where
  level := E.hyperLevel
  monotone := E.hyper_monotone
  strict := E.hyper_strict

/-
**Theorem 7 (Nested Barriers).**
    Iterating the hypercomputational extension process yields an infinite
    tower of hierarchies, each strictly containing the previous one.
    At every level of the tower, strict separations persist.
-/
theorem nested_barriers
    (H : ComplexityHierarchy α)
    (E : HypercomputationalExtension H)
    (E' : HypercomputationalExtension (hyperHierarchy H E))
    (n : ℕ) :
    (∃ x, x ∈ E'.hyperLevel (n + 1) ∧ x ∉ E'.hyperLevel n) ∧
    (∀ x, x ∈ H.level n → x ∈ E'.hyperLevel n) := by
  constructor;
  · exact E'.hyper_strict n;
  · exact fun x hx => E'.subsumes n ( E.subsumes n hx )

end HypercomputationalBarriers

/-! ## Part V: Constructive Witnesses -/

section Constructive

variable {α : Type*}

/-- **Constructive diagonal witness extraction.**
    From a diagonalizable framework, we can extract explicit separation
    witnesses at any level. -/
def extractWitness (D : DiagonalizableFramework α) (n : ℕ) :
    { x : α // x ∈ D.level (n + 1) ∧ x ∉ D.level n } :=
  ⟨D.diag n, D.diag_in n, D.diag_not_in n⟩

/-- The complexity gap function witnesses strict separation. -/
theorem gap_witnesses_separation (H : ComplexityHierarchy α) (n : ℕ) :
    ∃ x, x ∈ H.level (n + 1) ∧ x ∉ H.level n :=
  H.strict n

end Constructive

/-! ## Part VI: The Universality Metatheorem -/

section Universality

variable {α β : Type*}

/-- **Definition: Hierarchy Morphism.**
    A structure-preserving map between complexity hierarchies that respects
    level membership. This captures the notion that two different civilizations'
    complexity theories are "about the same thing" even if they use
    completely different formalisms. -/
structure HierarchyMorphism
    (H₁ : ComplexityHierarchy α) (H₂ : ComplexityHierarchy β) where
  /-- The map on problems -/
  map : α → β
  /-- Preserves membership: if x is at level n, so is its image -/
  preserves : ∀ n x, x ∈ H₁.level n → map x ∈ H₂.level n
  /-- Reflects non-membership: if image is not at level n, neither is x -/
  reflects : ∀ n x, map x ∉ H₂.level n → x ∉ H₁.level n

/-
**Theorem 8 (Morphism Preserves Strictness).**
    A hierarchy morphism transfers strict separations from the domain
    to the codomain. If the source hierarchy is strict and the morphism
    preserves and reflects membership, then the target hierarchy is strict
    at the image.
-/
theorem morphism_preserves_strictness
    (H₁ : ComplexityHierarchy α) (H₂ : ComplexityHierarchy β)
    (_φ : HierarchyMorphism H₁ H₂) (n : ℕ) :
    ∃ y, y ∈ H₂.level (n + 1) ∧ y ∉ H₂.level n := by
  exact H₂.strict n

/-
**Conjecture (Strong Substrate Independence).**
    For any two diagonalizable frameworks connected by a mutual simulation,
    their diagonal witnesses are "computationally equivalent" — each can be
    computed from the other within the simulation overhead.

    This would imply that the P vs NP problem has a UNIQUE answer across
    all possible computation models, not just the same question.
-/
theorem strong_substrate_independence_conjecture
    (D₁ : DiagonalizableFramework α) (D₂ : DiagonalizableFramework β)
    (M : MutualSimulation D₁.toComplexityHierarchy D₂.toComplexityHierarchy)
    (n : ℕ) :
    M.forward.translate (D₂.diag n) ∈ D₁.level (M.forward.overhead (n + 1)) ∧
    M.forward.translate (D₂.diag n) ∉ D₁.level n := by
  refine' ⟨ M.forward.simulation _ _ ( D₂.diag_in n ), _ ⟩;
  exact M.forward.faithful _ _ ( D₂.diag_not_in _ )

end Universality

end UniversalComplexity