# Future Directions: Curriculum Complexity of Mathematics

## Overview

This document outlines five concrete research directions opened by the formal theory of curriculum complexity. Each direction includes specific theorem targets, proof strategies, and connections to other mathematical domains. The goal is that any of these directions can be picked up immediately as a research program.

---

## Direction 1: Infinite Curricula via Ordinal-Valued Ranks

### Vision
Extend the finite curriculum existence theorem to countably infinite and uncountable well-founded dependency systems using ordinal-valued level functions.

### Specific Theorem Targets

**Theorem (Ordinal Curriculum Existence).** For any well-founded dependency system `(T, DependsOn)` (not necessarily finite), there exists an ordinal-valued level function `level : T → Ordinal` such that:
1. `DependsOn a b → level b < level a`
2. `level t < Ordinal.type (WellOrder on T)` (bounded by the order type)

**Theorem (Countable Curriculum).** If T is countable and DependsOn is well-founded, then levels can be taken in ℕ ∪ {ω} (at most ω).

**Theorem (Hartogs Bound).** The supremum of levels in any dependency system is bounded by the Hartogs number of T.

### Proof Strategy
- Use transfinite induction on the well-founded relation.
- Define `level(t) = sup{level(s) + 1 | DependsOn t s}` as an ordinal.
- For the countable case, use the fact that countable well-orders embed into ω.
- Connect to Mathlib's `Ordinal` and `WellOrder` APIs.

### Cross-Domain Connections
- Set theory: ordinal arithmetic, Hartogs numbers
- Proof theory: ordinal analysis of formal systems (proof-theoretic ordinals as "curriculum complexity" of theories)
- Well-quasi-order theory: Kruskal's theorem, Nash-Williams theory

### Formalization Notes
```lean
-- Target statement
theorem exists_ordinal_curriculum {T : Type*} (R : T → T → Prop) (wf : WellFounded R) :
    ∃ f : T → Ordinal, ∀ a b, R a b → f b < f a
```

---

## Direction 2: Category of Curriculum Systems

### Vision
Define morphisms between curriculum systems and prove that curriculum depth is functorial — it behaves well under theory translations that preserve dependency structure.

### Specific Theorem Targets

**Definition (Curriculum Morphism).** A morphism `φ : (T₁, R₁) → (T₂, R₂)` is a function `φ : T₁ → T₂` such that `R₁ a b → R₂ (φ a) (φ b)`.

**Theorem (Level Monotonicity under Morphisms).** If `φ` is a curriculum morphism, then `level₂(φ(t)) ≤ level₁(t)` for all t.

**Theorem (Level Preservation for Embeddings).** If φ is injective and reflects dependencies (`R₂ (φ a) (φ b) → R₁ a b`), then `level₂(φ(t)) = level₁(t)`.

**Theorem (Pullback Curriculum).** Given a curriculum morphism and a curriculum for the target system, the pullback defines a valid curriculum for the source system.

**Theorem (Category Structure).** Curriculum systems with morphisms form a category. The level function defines a functor to (ℕ, ≤).

### Proof Strategy
- Define `CurriculumMorphism` as a structure with the function and dependency-preservation proof.
- Level monotonicity follows from the definition: if all deps of t map to deps of φ(t), then any chain in T₁ maps to a chain in T₂.
- For embeddings, the converse uses reflection of dependencies.
- Category structure is straightforward (composition of morphisms, identity).

### Cross-Domain Connections
- Category theory: functors, natural transformations, limits
- Logic: interpretations between theories, conservative extensions
- Type theory: universe polymorphism, embedding theorems

---

## Direction 3: Parallel Research Complexity and Antichain Width

### Vision
Characterize the gap between sequential depth (minimum cycles) and parallel width (maximum number of independent theorems provable simultaneously). This connects curriculum complexity to Dilworth's theorem and scheduling theory.

### Specific Theorem Targets

**Definition (Width).** The width of a dependency system at level n is the number of theorems at exactly level n: `width(n) = |{t | level(t) = n}|`.

**Theorem (Dilworth Correspondence).** The maximum antichain size in the dependency order equals the minimum number of chains needed to cover all theorems.

**Theorem (Parallel Speedup Bound).** If the system has N theorems and depth D, then the maximum parallel speedup over sequential execution is N/D (achieved by the level-based schedule).

**Theorem (Width-Depth Product Bound).** `max_width × (depth + 1) ≥ |T|`, with equality iff all levels have the same width.

**Theorem (Amdahl's Law for Curricula).** If the critical path has length D and there are P parallel processors, the minimum completion time is max(D, ⌈N/P⌉).

### Proof Strategy
- Width is computed directly from the level function.
- Dilworth's theorem for finite partial orders is in Mathlib or can be proved by Hall's theorem.
- The speedup bound follows from: sequential time = N, parallel time = D+1.
- Width-depth product: pigeonhole on levels.

### Cross-Domain Connections
- Scheduling theory: critical path method, parallel task scheduling
- Complexity theory: circuit depth vs. size, NC hierarchy
- Combinatorics: Dilworth's theorem, antichain decomposition
- Parallel computing: Amdahl's law, work-span model

---

## Direction 4: Entropy and Complexity of Mathematical Theories

### Vision
Define information-theoretic invariants of dependency systems that measure the "complexity" of a mathematical theory beyond just depth. Curriculum entropy captures how constrained the learning order is.

### Specific Theorem Targets

**Definition (Curriculum Entropy).** For a dependency system (T, R), the curriculum entropy is:
```
H(T, R) = log₂(number of valid topological orderings)
```

**Theorem (Entropy Bounds).** 
- `0 ≤ H(T, R) ≤ log₂(|T|!)`
- `H(T, R) = 0` iff the dependency order is a total order
- `H(T, R) = log₂(|T|!)` iff R is empty (no dependencies)

**Theorem (Entropy and Width).** `H(T, R) ≥ Σₙ log₂(width(n)!)` (the entropy is at least the sum of log-factorials of level widths, since theorems within each level can be permuted).

**Definition (Dependency Density).** `ρ(T, R) = |edges| / (|T| × (|T|-1)/2)`, the fraction of possible dependencies that are present.

**Theorem (Density-Depth Relationship).** For random DAGs with n nodes and edge probability p, the expected depth is Θ(n) for constant p and Θ(log n) for p = c/n.

### Proof Strategy
- Counting topological orderings is #P-complete in general, but bounds can be proved combinatorially.
- The entropy lower bound follows from independence of permutations within levels.
- Density-depth for random DAGs uses probabilistic analysis of longest paths.

### Cross-Domain Connections
- Information theory: Shannon entropy, Kolmogorov complexity
- Computational complexity: #P-completeness, counting problems
- Random graph theory: random DAGs, longest path in random graphs
- Learning theory: sample complexity, curriculum learning efficiency

---

## Direction 5: Automated Curriculum Extraction from Proof Libraries

### Vision
Given a real proof library (e.g., a collection of formal proofs with explicit dependency data), automatically synthesize an optimal curriculum and certify its optimality bounds.

### Specific Theorem Targets

**Algorithm (Curriculum Extraction).** Given a dependency graph extracted from a proof library:
1. Compute all theorem levels in O(|T| + |E|) time.
2. Generate the optimal parallel schedule (grouping by level).
3. Produce a certified curriculum ranking.
4. Compute frontier depths for user-specified target theorems.

**Theorem (Certified Optimality).** The extracted curriculum is provably optimal: its depth equals the minimum number of sequential research cycles, and this is certified by a machine-checked proof.

**Theorem (Incremental Update).** When a new theorem is added to the library with dependencies on existing theorems, the curriculum can be updated in O(|affected chain|) time without recomputing from scratch.

### Implementation Plan
1. **Dependency extraction**: Parse proof files to extract `import` and `theorem`-level dependencies.
2. **Level computation**: Apply the longest-path algorithm from `algorithms.py`.
3. **Certificate generation**: Produce a Lean proof that the computed ranking satisfies `IsCurriculum`.
4. **Incremental updates**: When a new theorem is added, only recompute levels along the affected dependency chain.

### Cross-Domain Connections
- Software engineering: build systems, dependency resolution (npm, cargo)
- Formal methods: certified compilation, proof-carrying code
- Education technology: adaptive learning systems, prerequisite graphs
- Knowledge management: ontology design, skill trees in games

---

## Implementation Priority

1. **Direction 3 (Parallel Complexity)** — Most accessible, builds directly on the existing theory, and has immediate practical applications for proof automation.

2. **Direction 1 (Infinite Curricula)** — Mathematically deepest, connects to ordinal analysis and proof theory. Good target for a research paper.

3. **Direction 5 (Automated Extraction)** — Most practical impact. Could be integrated into existing proof assistants as a library analysis tool.

4. **Direction 2 (Category Theory)** — Elegant mathematical framework. Important for understanding how curriculum complexity behaves under theory morphisms.

5. **Direction 4 (Entropy)** — Most speculative but potentially most impactful. Opens connections to information theory and computational complexity.

---

## Cross-Cutting Theme: The Universal Depth Principle

All five directions share a common theme: **depth measures in partially ordered structures control the sequential complexity of traversal.** This principle appears in:

- Krull dimension in commutative algebra
- Circuit depth in complexity theory
- Critical path length in scheduling
- Proof-theoretic ordinals in logic
- Operadic depth in algebra

The curriculum complexity framework provides a unifying mathematical language for this phenomenon. Future work should make these connections precise through formal theorems relating different depth notions via functorial mappings between the relevant categories.
