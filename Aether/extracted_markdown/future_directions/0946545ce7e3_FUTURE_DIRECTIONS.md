# Future Directions: Proof-File Causality Theory

## Overview

This document outlines five breakthrough-level research directions opened by the formal theory of proof-file dependency extraction. Each direction includes a precise theorem statement, a proposed formalization target, proof strategy bullets, and a cross-domain connection.

---

## Direction 1: Semantic vs. Syntactic Dependency Gap

### The Problem

Our current theory captures *syntactic* dependencies — which theorem names appear in a declaration's dependency set. But the *semantic* dependencies — which constants are actually used in a proof term — may be a strict subset. The gap between these two measures quantifies the "dependency bloat" of a library.

### Precise Theorem Statement

**Conjecture (Dependency Gap Bound).** For any well-formed proof file with unique names, let `syntDeps(t)` be the declared dependency set of theorem `t` and `semDeps(t)` be the set of constants actually referenced in the proof term. Then:

$$\text{semDeps}(t) \subseteq \text{syntDeps}(t)$$

and there exist natural proof files where the inclusion is strict for a positive fraction of declarations.

### Proposed Lean Formalization Target

```lean
structure RichThmDecl where
  name : String
  syntacticDeps : Finset String
  semanticDeps : Finset String
  h_sub : semanticDeps ⊆ syntacticDeps

def DependencyGap (t : RichThmDecl) : Nat :=
  t.syntacticDeps.card - t.semanticDeps.card

theorem semantic_subset_syntactic (t : RichThmDecl) :
    t.semanticDeps ⊆ t.syntacticDeps := t.h_sub

theorem gap_nonneg (t : RichThmDecl) :
    0 ≤ DependencyGap t := by omega
```

### Proof Strategy

- Extract semantic dependencies using `Lean.ConstantInfo.getUsedConstants` in a metaprogramming pass.
- Compare with declared `import` / `open` dependencies to compute the gap.
- Prove the subset relationship as an invariant of the type-checking algorithm: any constant referenced in a proof term must be in scope, hence in the syntactic dependency set.

### Cross-Domain Connection

**Software engineering: dead code elimination.** The dependency gap is the formal-mathematics analogue of dead code — imported but unused dependencies. Quantifying this gap enables automated library pruning, reducing compile times and improving modularity. In large software projects, dead dependency analysis saves 10–30% of build time.

---

## Direction 2: Dependency Entropy and Proof Information

### The Problem

Different theorems have qualitatively different dependency structures: some depend on many shallow lemmas (wide), others on few deep ones (narrow). The Shannon entropy of the dependency distribution provides a single scalar measuring this structural diversity.

### Precise Theorem Statement

**Definition (Dependency Entropy).** For a proof file with declarations `x₁, ..., xₙ`, define the dependency weight of declaration `xᵢ` as `wᵢ = |deps(xᵢ)| / Σⱼ |deps(xⱼ)|`. The *dependency entropy* of the file is:

$$H = -\sum_{i=1}^{n} w_i \log_2 w_i$$

**Conjecture (Entropy-Depth Inequality).** For well-formed files with unique names:

$$H \leq \log_2(D+1) \cdot n / \ln n$$

where `D` is the maximum dependency depth and `n` is the number of declarations.

### Proposed Lean Formalization Target

```lean
noncomputable def dependencyEntropy (xs : List ThmDecl) : ℝ :=
  let totalDeps := (xs.map (fun t => t.deps.card)).sum
  if totalDeps = 0 then 0
  else -∑ t ∈ xs.toFinset,
    let w := (t.deps.card : ℝ) / totalDeps
    w * Real.log w / Real.log 2

theorem entropy_nonneg (xs : List ThmDecl) :
    0 ≤ dependencyEntropy xs := by sorry
```

### Proof Strategy

- Define entropy using Mathlib's `Real.log` and `Finset.sum`.
- Prove non-negativity from the concavity of `x log x` (standard information-theoretic argument).
- For the entropy-depth inequality, use the constraint that well-formedness limits the maximum fan-in at each depth level.

### Cross-Domain Connection

**Information theory: source coding.** Dependency entropy is the proof-architecture analogue of source entropy. Just as Shannon's source coding theorem says data can be compressed to its entropy rate, the dependency entropy might characterize the minimum description length of a proof file's dependency structure. This connects to proof compression and efficient proof representation.

---

## Direction 3: Area-Law Bounds for Theorem Neighborhoods

### The Problem

In physics, the entanglement entropy of a spatial region scales with its boundary area, not its volume (the "area law"). We conjecture an analogous phenomenon for theorem dependencies: the number of direct dependencies (boundary) controls the transitive closure size (bulk) polynomially.

### Precise Theorem Statement

**Conjecture (Area Law for Dependencies).** Let `G` be the dependency graph of a well-formed proof file. For any theorem `t`, let `∂(t) = |deps(t)|` (direct dependencies) and `TC(t) = |transitive_closure(t)|` (transitive dependencies). Then for "natural" proof files satisfying a bounded-branching condition `∀ t, |deps(t)| ≤ B`:

$$TC(t) \leq \partial(t) \cdot D$$

where `D` is the maximum dependency depth.

### Proposed Lean Formalization Target

```lean
def transitiveDeps (xs : List ThmDecl) (name : String) : Finset String :=
  -- Compute transitive closure of dependencies
  sorry

theorem area_law_bound
    (xs : List ThmDecl)
    (hwf : DeclsRespectOrder xs)
    (hu : UniqueNames xs)
    (B D : Nat)
    (hB : ∀ i (hi : i < xs.length), (xs.get ⟨i, hi⟩).deps.card ≤ B)
    (hD : ∀ i (hi : i < xs.length), depthOf xs i ≤ D)
    {i : Nat} (hi : i < xs.length) :
    (transitiveDeps xs (xs.get ⟨i, hi⟩).name).card ≤ B * D := by
  sorry
```

### Proof Strategy

- Define transitive closure recursively using the declaration order (well-founded by Theorem 3.4).
- Prove the bound by induction on depth: at depth 0, TC = 0 ≤ B · 0. At depth d+1, TC(t) ≤ |deps(t)| + Σ_{s ∈ deps(t)} TC(s) ≤ B + B · (B · d) — but this gives exponential growth. The polynomial bound requires a *sharing* argument: the same transitive dependency counted once.
- The key insight is that in a DAG, the total number of distinct reachable nodes from a node at depth d with branching factor B is at most B · d (since each of the d depth levels contributes at most B new nodes through the direct dependencies, though the precise bound depends on the graph structure).

### Cross-Domain Connection

**Quantum physics: holographic principle.** The area law in quantum field theory states that the von Neumann entropy of a spatial region scales with the boundary area. Our area-law conjecture is a discrete, combinatorial analogue: the "information content" of a theorem (its transitive dependency count) is controlled by its "boundary" (direct dependencies). This connection suggests that formal mathematics might exhibit holographic properties, where boundary data suffices to reconstruct the bulk.

---

## Direction 4: Lawvere-Style Fixed-Point Obstructions in Cyclic Systems

### The Problem

Our Theorem 3.3 shows that declaration-order discipline prevents self-dependency. Lawvere's fixed-point theorem shows that in categories with sufficient self-referential structure, every endomorphism has a fixed point (yielding paradoxes). What happens at the boundary — in systems that are "almost" well-ordered but contain controlled cycles?

### Precise Theorem Statement

**Conjecture (Controlled Cycle Theorem).** Let `xs` be a list of declarations where `DeclsRespectOrder` fails at exactly `k` positions. Then the dependency graph contains at most `k` strongly connected components of size > 1, and the quotient DAG (contracting each SCC) satisfies all properties of the well-ordered theory.

### Proposed Lean Formalization Target

```lean
def violationCount (xs : List ThmDecl) : Nat :=
  (List.range xs.length).countP fun i =>
    ¬((xs.get ⟨i, by omega⟩).deps ⊆ priorNames xs i)

def isQuotientAcyclic (xs : List ThmDecl) : Prop :=
  -- The SCC-quotient graph is acyclic
  sorry

theorem controlled_cycles
    (xs : List ThmDecl)
    (hu : UniqueNames xs)
    (hk : violationCount xs = k) :
    -- The number of non-trivial SCCs is at most k
    sorry
```

### Proof Strategy

- Define strongly connected components combinatorially on the finite dependency graph.
- Show that each violation (a forward-pointing edge) can participate in at most one new SCC.
- Prove that the quotient graph (collapsing SCCs to single nodes) inherits a topological ordering from the residual well-ordered structure.
- The key lemma: removing `k` edges from a DAG creates at most `k` cycles.

### Cross-Domain Connection

**Category theory: Lawvere's diagonal argument.** Lawvere showed that self-referential constructions in cartesian closed categories force fixed points. Our declaration-order discipline is precisely the structural condition that prevents the required surjection `A → A^A`. The controlled-cycle theorem would quantify how much self-reference (how many violations) is needed to re-enable Lawvere-style constructions, creating a "distance to paradox" metric.

---

## Direction 5: Categorical Semantics of Proof-File Closure Operators

### The Problem

Our `stepClosure` and `importClosure` operators have the structure of a monad on the category of finite sets: `stepClosure` is inflationary (unit), monotone (functorial), and idempotent on closed sets (multiplication/join). Making this monad structure explicit would connect proof-file architecture to categorical algebra.

### Precise Theorem Statement

**Theorem Target.** The import closure construction defines a monad on the category **FinSet** enriched over the poset of inclusion:
- Unit: `η_S = S ↪ stepClosure G S` (inflationary, our `subset_stepClosure`)
- Multiplication: `μ_S = stepClosure G (stepClosure G S) → stepClosure G S` (from idempotence on closed sets, generalized)
- Associativity and unit laws follow from monotonicity and idempotence.

### Proposed Lean Formalization Target

```lean
-- Using Mathlib's category theory library
instance : Monad (fun S => importClosure G ∞ S) where
  pure := fun S => S
  bind := fun S f => importClosure G ∞ (S.biUnion f)

-- Or more concretely:
theorem stepClosure_inflationary (G : String → Finset String) (S : Finset String) :
    S ⊆ stepClosure G S := subset_stepClosure G S

theorem stepClosure_extensive_monotone (G : String → Finset String) :
    ∀ S T, S ⊆ T → stepClosure G S ⊆ stepClosure G T := fun _ _ h => stepClosure_monotone' G h

theorem closure_operator_laws (G : String → Finset String) :
    -- The triple (stepClosure G, subset_stepClosure, stepClosure_idempotent_of_closed)
    -- forms a closure operator on (Finset String, ⊆)
    (∀ S, S ⊆ stepClosure G S) ∧
    (∀ S T, S ⊆ T → stepClosure G S ⊆ stepClosure G T) ∧
    (∀ S, ImportClosed G S → stepClosure G S = S) := by
  exact ⟨subset_stepClosure G, fun _ _ h => stepClosure_monotone' G h,
         fun _ h => stepClosure_idempotent_of_closed G h⟩
```

### Proof Strategy

- Formalize the notion of a closure operator on a poset using Mathlib's `ClosureOperator` type class.
- Show that `iteratedClosure G` (the fixpoint of `stepClosure`) satisfies the closure operator axioms.
- Connect to Mathlib's `GaloisInsertion` for the adjunction between sets and their closures.
- The monad structure follows from the general result that every idempotent monad is a closure operator.

### Cross-Domain Connection

**Algebraic topology: sheaf theory.** Closure operators on posets are equivalent to Lawvere-Tierney topologies in topos theory, which determine the notion of "sheaf" (local-to-global coherence). Interpreting import closure as a Lawvere-Tierney topology would mean: a "sheaf" on the import graph is a property of modules that is determined by local (import-level) data. This is precisely the holographic principle applied to formal mathematics — global proof structure reconstructed from local dependency data.

---

## Team Directive

Each direction above defines a self-contained research project. Teams should:

1. **Validate the conjecture** computationally on real proof libraries (e.g., run dependency extraction on Mathlib's 100K+ declarations).
2. **Formalize the definitions** in Lean, building on the existing `DependencyExtraction.lean` infrastructure.
3. **Prove the key lemma** identified in each proof strategy, then compose into the main theorem.
4. **Write the cross-domain connection** as a concrete example or application, not just an analogy.
5. **Iterate**: if the conjecture fails, characterize the counterexamples and reformulate.

Priority ordering: Direction 1 (most tractable) → Direction 5 (most foundational) → Direction 3 (most impactful) → Direction 2 (most novel) → Direction 4 (most deep).
