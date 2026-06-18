# Future Directions: Tropical Synthetic Homotopy

## Overview

The tropical univalence framework established in this project opens a new field at the intersection of type theory, combinatorial optimization, and tropical geometry. Below are five concrete breakthrough-level research directions, each specified with precise theorem targets, proof strategies, and cross-domain connections.

---

## Direction 1: Tropical Truncation Levels

### Vision
In HoTT, types are classified by their *truncation level*: (-2)-truncated types are contractible, (-1)-truncated types are mere propositions, 0-truncated types are sets, 1-truncated types are groupoids, and so on. We propose a tropical analogue based on the structure of the automorphism group.

### Precise Theorem Targets

```
Definition: A tropical space D is n-truncated if the automorphism tower
  Aut(D) → Aut(Aut(D)) → ···
stabilizes at the (n+2)-th level.

Theorem (Tropical (-1)-Truncation):
  The (-1)-truncation of a collection of tropical spaces is the
  proposition "there exists a space with this canonical code."
  Formally: Trunc_{-1}(TropicalSpace n) ≃ Finset(CanonicalCode n)

Theorem (Tropical 0-Truncation):
  The 0-truncation classifies spaces up to isometry.
  Trunc_0 ≃ orbit partition under Perm(n) action.

Theorem (Tropical 1-Truncation):
  The 1-truncation retains the automorphism group.
  (D, E, σ₁, σ₂) are identified iff σ₁⁻¹ · σ₂ ∈ Aut(D).
```

### Proof Strategy
1. Define `automorphismGroup(D)` as the stabilizer of D under the Perm(n) action.
2. Prove the orbit-stabilizer theorem: |Aut(D)| × |Orbit(D)| = n!
3. Define truncation levels via iterated automorphism computation.
4. Prove equivalence with the abstract HoTT definition for finite discrete types.

### Cross-Domain Connections
- **Polya enumeration theory**: counting weighted graphs up to symmetry
- **Chemical graph theory**: molecular symmetry classification
- **Coding theory**: equivalence classes of error-correcting codes

---

## Direction 2: Tropical Fundamental Groupoid

### Vision
The fundamental groupoid of a topological space has objects as points and morphisms as homotopy classes of paths. The tropical shadow replaces this with a *distance-labeled groupoid*: objects are weighted spaces, morphisms are tropical isometries, and composition is permutation multiplication.

### Precise Theorem Targets

```
Definition: The tropical groupoid TropGroupoid(n, w) has:
  - Objects: n×n distance matrices with entries in [0, w]
  - Morphisms D → E: permutations σ with E(σi, σj) = D(i,j)
  - Composition: permutation multiplication
  - Identity: identity permutation
  - Inverse: permutation inverse

Theorem (Category Laws):
  TropGroupoid is a well-defined groupoid (all morphisms invertible).

Theorem (π₁ as Automorphism Group):
  The endomorphism group Hom(D, D) in TropGroupoid equals Aut(D),
  the tropical analogue of the fundamental group.

Theorem (Tropical Van Kampen):
  For a glued space G = D ∪_a E, the automorphism group Aut(G)
  is determined by Aut(D), Aut(E), and their interaction at the
  attachment point, analogous to the Seifert-van Kampen theorem.
```

### Proof Strategy
1. Formalize the groupoid structure in Lean using Mathlib's `CategoryTheory.Groupoid`.
2. Prove the functor from TropGroupoid to the groupoid of finite types and bijections.
3. For the Van Kampen analogue, analyze how automorphisms of the glued space restrict to automorphisms of the components.

### Cross-Domain Connections
- **Network analysis**: symmetry detection in weighted networks
- **Robotics**: configuration space symmetries for motion planning
- **Crystallography**: space group computation

---

## Direction 3: Efficient Canonical Labeling for Tropical Spaces

### Vision
The current decidability proof uses exhaustive search over n! permutations. For practical application, we need polynomial-time (or quasipolynomial-time) algorithms. This connects directly to the graph isomorphism problem and the celebrated work of Babai (2016).

### Precise Theorem Targets

```
Theorem (Polynomial-Time Profile Invariant):
  The sorted multiset of row profiles is computable in O(n² log n)
  and provides a necessary condition for tropical equivalence.

Theorem (Refinement Procedure):
  Iterative color refinement (1-WL) adapted to weighted matrices
  decides tropical equivalence for almost all random matrices
  in polynomial time.

Conjecture (Quasipolynomial Canonical Code):
  There exists an algorithm computing canonicalCode(D) in
  time n^{O(log n)} for all n×n ℕ-matrices D, extending
  Babai's result to the weighted setting.

Theorem (Tree Metrics in Polynomial Time):
  For distance matrices arising from weighted trees,
  tropical equivalence is decidable in O(n² log n) time.
```

### Proof Strategy
1. Implement color refinement for weighted matrices, tracking weight multiplicities.
2. Prove correctness: if refinement distinguishes all vertices, it produces a canonical labeling.
3. For tree metrics: use the four-point condition (d(a,b) + d(c,d) ≤ max(d(a,c)+d(b,d), d(a,d)+d(b,c))) to recognize and canonically label tree structures.
4. For the general quasipolynomial result: adapt Babai's structure theory (Johnson graphs, coherent configurations) to the weighted setting.

### Cross-Domain Connections
- **Practical graph isomorphism**: nauty, bliss, Traces software
- **Machine learning**: graph neural networks and Weisfeiler-Leman hierarchy
- **Database theory**: query equivalence under isomorphism

---

## Direction 4: Tropical Sheaves and Local-to-Global Identity

### Vision
Sheaf theory captures the idea that global data can be reconstructed from compatible local data. A tropical sheaf would assign identity data (canonical codes) to subspaces and provide conditions under which local codes determine the global code.

### Precise Theorem Targets

```
Definition: A tropical presheaf on a weighted space D assigns to each
  subset S ⊆ Fin(n) the canonical code of the restriction D|_S.

Theorem (Restriction Functoriality):
  If S ⊆ T, then canonicalCode(D|_S) is determined by canonicalCode(D|_T).

Theorem (Gluing Axiom for Separated Spaces):
  If D is separated and {S_i} covers Fin(n) with sufficient overlaps,
  then canonicalCode(D) is determined by {canonicalCode(D|_{S_i})} and
  the restriction maps.

Theorem (Descent for Tropical Equivalence):
  If D and E agree on all local patches (canonicalCode(D|_S) =
  canonicalCode(E|_S) for all S of size ≤ k), then for sufficiently
  large k (depending on n), D ≃ E.
```

### Proof Strategy
1. Define the restriction functor: send a subset S to the principal submatrix D|_S.
2. Prove that canonical codes are preserved under restriction when the restricted permutation exists.
3. For the descent theorem: use a dimension-counting argument. The k-local codes determine O(n^k) constraints, which for k ≥ 3 typically suffice to determine the full matrix up to isometry.
4. Formalize using Mathlib's sheaf infrastructure or a custom presheaf category.

### Cross-Domain Connections
- **Persistent homology**: Vietoris-Rips filtrations from distance matrices
- **Topological data analysis**: local-to-global shape reconstruction
- **Distributed computing**: consensus and agreement protocols

---

## Direction 5: Tropical Type Theory for Weighted Transition Systems

### Vision
Weighted transition systems (automata with costs) are ubiquitous in program verification, game theory, and control theory. Tropical univalence provides a decidable criterion for *behavioral equivalence* of such systems: two systems are interchangeable iff their cost matrices are tropically equivalent. This direction formalizes the connection and develops a type-theoretic language for reasoning about weighted systems.

### Precise Theorem Targets

```
Definition: A weighted transition system (S, δ, c) has states S,
  transitions δ ⊆ S × S, and costs c : δ → ℕ.
  Its distance matrix D(i,j) = shortest-path cost from i to j.

Theorem (Bisimulation ↔ Tropical Equivalence):
  For deterministic weighted systems, weighted bisimulation
  is equivalent to tropical indiscernibility on the cost matrix.

Theorem (Compositional Equivalence):
  If systems A₁ ≃ A₂ and B₁ ≃ B₂ (tropically equivalent),
  then their serial composition A₁;B₁ ≃ A₂;B₂ and parallel
  composition A₁ ∥ B₁ ≃ A₂ ∥ B₂ are also tropically equivalent.

Theorem (Minimization via Indiscernibility):
  The quotient of a weighted transition system by tropical
  indiscernibility is the minimal system with the same
  cost-to-go function from every state.

Theorem (Decidable Module Replacement):
  Given a system S containing module M, and a candidate
  replacement M', it is decidable whether replacing M with M'
  preserves all cost-sensitive behavioral properties.
```

### Proof Strategy
1. Define weighted transition systems as directed weighted graphs.
2. Compute the shortest-path distance matrix using Floyd-Warshall.
3. Prove that standard weighted bisimulation coincides with profile equality on the distance matrix.
4. For compositionality: show that serial composition corresponds to tropical matrix multiplication (min-plus), and parallel composition to block-diagonal structure.
5. For minimization: prove that the quotient by indiscernibility preserves the distance matrix structure (using the separation axiom on the quotient).

### Cross-Domain Connections
- **Model checking**: equivalence checking for probabilistic/weighted models
- **Game theory**: equivalence of position values in combinatorial games
- **Quantum computing**: cost-optimal circuit equivalence
- **Compiler optimization**: program transformation correctness

---

## Team Structure for Continued Research

### Definitions Team
- Formalize tropical truncation levels, groupoid structure, sheaf presheaves
- Design efficient data structures for canonical codes
- Explore connections to matroid theory and combinatorial optimization

### Proof Team
- Prove orbit-stabilizer theorem in the tropical setting
- Formalize the Van Kampen analogue for glued spaces
- Develop the descent theorem for local-to-global codes

### Algorithm Team
- Implement weighted color refinement
- Adapt Babai's graph isomorphism algorithm to weighted matrices
- Benchmark on phylogenetic datasets and network datasets

### Bridge Team
- Apply tropical equivalence to real phylogenetic tree datasets
- Build a module equivalence checker for simple imperative programs
- Connect to persistent homology computations

### Lean Engineering Team
- Optimize Lean formalization for performance on large matrices
- Build tactic automation for tropical proofs
- Integrate with Mathlib's category theory and group theory libraries

---

## Timeline

| Quarter | Milestone |
|---|---|
| Q1 | Automorphism groups and orbit-stabilizer theorem |
| Q2 | Tropical groupoid formalization and Van Kampen analogue |
| Q3 | Efficient canonical labeling (polynomial for trees) |
| Q4 | Tropical sheaf theory and descent theorem |
| Q5 | Weighted transition system equivalence |
| Q6 | Full integration and publication |

---

## Success Metrics

1. **Formal verification**: All five direction theorems fully proved in Lean 4, zero sorry.
2. **Computational**: Canonical labeling running on matrices up to n = 100 in under 1 second.
3. **Applications**: At least one published case study applying tropical equivalence to real data (phylogenetics or network analysis).
4. **Community**: Public Lean library for tropical type theory, integrated with Mathlib.
