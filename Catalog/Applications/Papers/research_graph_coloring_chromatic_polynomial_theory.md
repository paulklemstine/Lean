# Certified Chromatic Polynomials: A Machine-Verified Foundation for Graph Coloring Theory

## Abstract

We present a comprehensive machine-verified formalization of chromatic polynomial theory for finite simple graphs. Working in Lean 4 with the Mathlib library, we define the chromatic polynomial via the Whitney rank formula (inclusion-exclusion over edge subsets), prove the fundamental evaluation theorem establishing that the polynomial counts proper colorings, and derive structural properties including monicity, degree characterization, and closed-form formulas for complete graphs and edgeless graphs. We additionally formalize equivalences between standard graph colorability and polynomial positivity formulations relevant to the Four Color Theorem. All proofs are fully verified with no remaining sorry obligations in the core theory (25+ theorems across 5 files). This development provides reusable infrastructure for future formalization of the Tutte polynomial, Potts model partition functions, and certified graph coloring algorithms.

## 1. Introduction

### 1.1 Motivation

The chromatic polynomial χ_G(k) of a finite graph G counts the number of proper k-colorings — assignments of k colors to vertices such that adjacent vertices receive distinct colors. Introduced by Birkhoff [1] in 1912 as an approach to the Four Color Conjecture, the chromatic polynomial has become a central object connecting structural graph theory, algebraic combinatorics, and statistical physics.

Despite its fundamental importance, the chromatic polynomial has received limited attention in formal mathematics. The Mathlib library for Lean 4 contains definitions for graph colorings (`SimpleGraph.Coloring`) and chromatic number (`SimpleGraph.chromaticNumber`), but no chromatic polynomial definition or associated theory existed prior to this work.

### 1.2 Contributions

We provide:

1. **Core definitions** (§3): Proper coloring predicate, coloring count function, chromatic polynomial via Whitney rank formula, and spanning subgraph construction.

2. **Fundamental evaluation theorem** (§4): A full proof that evaluating the chromatic polynomial at any natural number k yields the number of proper k-colorings. This required decomposing the inclusion-exclusion principle into five independently verified lemmas.

3. **Structural properties** (§5): Proofs that the chromatic polynomial has degree |V|, is monic, and that these follow from connected component counting arguments.

4. **Closed-form formulas** (§6): Verified formulas for complete graphs (falling factorial), K₂, and edgeless graphs.

5. **Four-color equivalences** (§7): Formal proof that graph k-colorability is equivalent to positivity of proper coloring count, establishing the bridge between combinatorial and polynomial formulations.

6. **Computational implementations** (§8): Python implementations of the Whitney formula and deletion-contraction algorithms, verified against brute-force enumeration.

### 1.3 Related Work

Prior formalizations of graph theory in interactive theorem provers include work on Euler's formula (in Isabelle/HOL), graph planarity (in Coq), and the formalization of the Four Color Theorem itself (in Coq, by Gonthier [6]). However, chromatic polynomial theory has not previously been formalized. Our work fills this gap and creates infrastructure for future formalizations of the Tutte polynomial and related invariants.

## 2. Mathematical Background

### 2.1 The Whitney Rank Formula

For a simple graph G = (V, E) on n vertices, the chromatic polynomial is:

$$\chi_G(k) = \sum_{A \subseteq E} (-1)^{|A|} k^{c(A)}$$

where c(A) denotes the number of connected components of the spanning subgraph (V, A).

This formula follows from the principle of inclusion-exclusion applied to "monochromatic edge" events: for each edge e = {u,v}, let B_e be the set of colorings where u and v receive the same color. Then proper colorings are precisely those in the complement of all B_e, and inclusion-exclusion gives:

$$|\bigcap_e B_e^c| = \sum_{A \subseteq E} (-1)^{|A|} |\bigcap_{e \in A} B_e|$$

The key insight is that |∩_{e∈A} B_e| — the number of colorings agreeing on all edges in A — equals k^{c(A)}, since such a coloring must be constant on each connected component of (V, A).

### 2.2 Properties

From the Whitney formula, one can derive:

- **Degree**: deg(χ_G) = |V|, since the term A = ∅ contributes k^n and all other terms have lower degree.
- **Monicity**: The leading coefficient is 1 (from A = ∅ alone).
- **Second coefficient**: The coefficient of k^{n-1} is −|E|.
- **Evaluation at 0**: χ_G(0) = 0 for any graph with at least one vertex.

### 2.3 Complete Graphs

For the complete graph K_n, χ_{K_n}(k) = k(k-1)(k-2)⋯(k-n+1) = k^{(n)}, the falling factorial. This follows because a proper coloring of K_n is an injective function from n vertices to k colors.

### 2.4 Connection to Statistical Physics

The chromatic polynomial equals the zero-temperature antiferromagnetic q-state Potts model partition function:

$$Z_{Potts}(G, q, \beta \to \infty) = \chi_G(q)$$

This connects graph coloring to equilibrium statistical mechanics and has implications for understanding phase transitions in spin systems.

## 3. Core Definitions

### 3.1 Proper Colorings

We define proper colorings as a predicate on functions:

```lean
def SimpleGraph.IsProperColoring (G : SimpleGraph V) (c : V → α) : Prop :=
  ∀ ⦃u v : V⦄, G.Adj u v → c u ≠ c v
```

This is equivalent to Mathlib's existing `SimpleGraph.Coloring` type (a graph homomorphism to the complete graph), which we prove via an explicit equivalence:

```lean
noncomputable def properColoringEquivColoring (G : SimpleGraph V)
    [DecidableRel G.Adj] (α : Type*) [DecidableEq α] :
    { c : V → α // G.IsProperColoring c } ≃ G.Coloring α
```

### 3.2 Coloring Count

```lean
noncomputable def numColorings (G : SimpleGraph V) [DecidableRel G.Adj] (k : ℕ) : ℕ :=
  Fintype.card { c : V → Fin k // G.IsProperColoring c }
```

### 3.3 Spanning Subgraph Construction

For the Whitney formula, we need to construct spanning subgraphs from edge subsets:

```lean
def spanningSubgraphOfEdges (edges : Finset (Sym2 V)) : SimpleGraph V where
  Adj u v := s(u, v) ∈ edges ∧ u ≠ v
```

### 3.4 Chromatic Polynomial

```lean
noncomputable def chromaticPolynomial (G : SimpleGraph V)
    [DecidableRel G.Adj] : Polynomial ℤ :=
  ∑ A ∈ G.edgeFinset.powerset,
    ((-1 : ℤ) ^ A.card) • (X : Polynomial ℤ) ^ numComponentsOfEdges A
```

where `numComponentsOfEdges A = Fintype.card (spanningSubgraphOfEdges A).ConnectedComponent`.

## 4. The Evaluation Theorem

The central correctness result establishes that the polynomial definition agrees with the counting function:

```lean
theorem eval_chromaticPolynomial' (G : SimpleGraph V)
    [DecidableRel G.Adj] (k : ℕ) :
    Polynomial.eval (k : ℤ) G.chromaticPolynomial = ↑(G.numColorings k)
```

### 4.1 Proof Decomposition

The proof is decomposed into five independently verified lemmas:

**Lemma 1** (Evaluation simplification): Evaluating the polynomial at k gives the algebraic sum.
```lean
theorem eval_chromaticPolynomial_eq_sum
```

**Lemma 2** (Component-constant bijection): Functions constant on connected components of H biject with functions from components to the codomain.
```lean
noncomputable def constOnComponentsEquiv (H : SimpleGraph V) (α : Type*) :
    { f : V → α // ∀ u v, H.Reachable u v → f u = f v } ≃
    (H.ConnectedComponent → α)
```

**Lemma 3** (Agreement-component equivalence): A function agrees on an edge set A iff it is constant on connected components of (V, A).
```lean
theorem agreesOnEdges_iff_constOnComponents
```

**Lemma 4** (Edge agreement counting): The number of functions agreeing on edge set A equals k^{c(A)}.
```lean
theorem card_agreesOnEdges
```

**Lemma 5** (Inclusion-exclusion identity): The alternating sum over edge subsets equals the proper coloring count.
```lean
theorem numColorings_eq_incl_excl
```

### 4.2 Proof of Inclusion-Exclusion (Lemma 5)

The most technically challenging step is Lemma 5. The proof proceeds by:

1. For each function f : V → Fin k, computing the contribution to the alternating sum as ∑_{A ⊆ S(f)} (-1)^|A|, where S(f) = {e ∈ E | f agrees on e}.

2. Showing that this inner sum equals 1 if S(f) = ∅ (f is proper) and 0 otherwise (by the identity ∑_{A ⊆ S} (-1)^|A| = 0 for nonempty S, which follows from the binomial theorem).

3. Swapping the order of summation via Fubini's theorem for finite sums.

## 5. Structural Properties

### 5.1 Connected Component Bounds

```lean
theorem numComponentsOfEdges_empty :
    numComponentsOfEdges (∅ : Finset (Sym2 V)) = Fintype.card V

theorem numComponentsOfEdges_lt_of_nonempty {A : Finset (Sym2 V)}
    (hA : A.Nonempty) (hA_edges : ∀ e ∈ A, ¬ Sym2.IsDiag e) :
    numComponentsOfEdges A < Fintype.card V

theorem numComponentsOfEdges_le (A : Finset (Sym2 V)) :
    numComponentsOfEdges A ≤ Fintype.card V
```

The first follows from the fact that the empty edge set makes every vertex its own component. The second uses the pigeonhole principle: if edge {u,v} exists, then u and v are in the same component, so the component map is not injective.

### 5.2 Degree and Monicity

```lean
theorem natDegree_chromaticPolynomial (G : SimpleGraph V)
    [DecidableRel G.Adj] [Nonempty V] :
    G.chromaticPolynomial.natDegree = Fintype.card V

theorem monic_chromaticPolynomial (G : SimpleGraph V)
    [DecidableRel G.Adj] [Nonempty V] :
    G.chromaticPolynomial.Monic
```

**Proof sketch**: The A = ∅ term contributes X^n with coefficient 1 at degree n. All other terms have degree strictly less than n (by `numComponentsOfEdges_lt_of_nonempty`). Therefore the leading coefficient is 1 and the degree is n.

## 6. Closed-Form Formulas

### 6.1 Complete Graphs

```lean
theorem numColorings_completeGraph (n k : ℕ) :
    (⊤ : SimpleGraph (Fin n)).numColorings k = Nat.descFactorial k n

theorem chromaticPolynomial_completeGraph (n : ℕ) :
    (⊤ : SimpleGraph (Fin n)).chromaticPolynomial =
      ∏ i ∈ Finset.range n, (X - C (i : ℤ))
```

**Proof of counting result**: A proper coloring of K_n is an injective function Fin n → Fin k. The number of such functions equals the descending factorial, proved via an equivalence between `IsProperColoring` and `Function.Injective` for complete graphs.

**Proof of polynomial identity**: Both polynomials agree on infinitely many rational points (every sufficiently large natural number), hence they must be equal. The agreement follows from the evaluation theorem and the counting result.

### 6.2 Edgeless Graphs

```lean
theorem chromaticPolynomial_bot :
    (⊥ : SimpleGraph V).chromaticPolynomial = X ^ Fintype.card V
```

For the edgeless graph, E = ∅, so the powerset sum has only one term (A = ∅), giving X^n.

## 7. Four-Color Equivalences

We prove several equivalence results connecting different formulations of graph colorability:

```lean
theorem colorable_iff_exists_properColoring (G : SimpleGraph V)
    [DecidableRel G.Adj] (k : ℕ) :
    G.Colorable k ↔ Nonempty { c : V → Fin k // G.IsProperColoring c }

theorem colorable_iff_numColorings_pos (G : SimpleGraph V)
    [DecidableRel G.Adj] (k : ℕ) :
    G.Colorable k ↔ 0 < G.numColorings k
```

These establish that graph k-colorability (existence of a proper coloring) is equivalent to the chromatic polynomial being positive at k. This reformulation is precisely what connects the Four Color Theorem to polynomial positivity.

## 8. Computational Implementation

### 8.1 Algorithms

We implement three algorithms for computing chromatic polynomials in Python:

| Algorithm | Time Complexity | Space | Correctness |
|-----------|----------------|-------|-------------|
| Whitney formula | O(2^m · (n+m)) | O(n+m) | Theorem 4.1 |
| Deletion-contraction | O(2^m) | O(m·n) | Recursion |
| Brute force count | O(k^n · m) | O(n) | Definition |

### 8.2 Verification

All three algorithms agree on all tested instances (11 graph families, k from 0 to 5). The closed-form formulas for complete graphs K_1 through K_5, paths P_2 through P_6, and cycles C_3 through C_7 were verified to match deletion-contraction output.

### 8.3 Benchmarks

| Graph | |V| | |E| | Whitney (s) | Del-Con (s) |
|-------|-----|-----|-------------|-------------|
| K_4 | 4 | 6 | <0.01 | <0.01 |
| Petersen | 10 | 15 | 0.8 | <0.01 |
| K_5 | 5 | 10 | 0.02 | <0.01 |

Deletion-contraction with memoization significantly outperforms the Whitney formula for dense graphs due to subgraph sharing.

## 9. Discussion

### 9.1 Formalization Challenges

The main technical challenges were:

1. **Connected component counting**: Lean's `ConnectedComponent` type is defined as `Quot G.Reachable`, requiring careful handling of quotient types for the bijection with component-indexed functions.

2. **Edge contraction**: Simple graphs in Lean are parameterized by vertex type. Edge contraction changes the vertex type (via quotient), making deletion-contraction statements require polymorphism over the polynomial output type. Our Whitney formula approach avoids this entirely.

3. **Inclusion-exclusion**: The alternating sum identity ∑_{A ⊆ S} (−1)^|A| = 0 for nonempty S, while elementary, required careful manipulation of finite sums in Lean's formalism.

4. **Type coercions**: The polynomial is over ℤ while coloring counts are in ℕ, requiring explicit cast management throughout.

### 9.2 Limitations

- The chromatic polynomial is defined noncomputably (using `Fintype.card` on connected components). An extracted certified algorithm would require a computable contraction operation.
- We do not prove deletion-contraction as a theorem about the polynomial directly (this would require formalizing graph contraction as a type-changing operation).
- The evaluation theorem proof via inclusion-exclusion is self-contained but long (~100 lines across 5 lemmas). A shorter proof might be possible via Möbius inversion on the partition lattice.

### 9.3 Design Decisions

We chose the Whitney rank formula over deletion-contraction induction for the definition because:
1. It avoids the vertex-type-changing contraction operation.
2. It gives a closed-form definition amenable to coefficient extraction.
3. The evaluation theorem proof via inclusion-exclusion is more algebraically natural.

## 10. Future Work

See FUTURE_DIRECTIONS.md for detailed next steps. The most impactful immediate targets are:

1. **Acyclic orientation reciprocity**: |χ_G(−1)| = number of acyclic orientations
2. **Tutte polynomial specialization**: χ_G(q) = (−1)^{r(G)} q^{k(G)} T_G(1−q, 0)
3. **Certified coloring counter**: Extract executable from the formalization
4. **Deletion-contraction theorem**: Formalize graph contraction and prove χ_G = χ_{G\e} − χ_{G/e}

## References

[1] G.D. Birkhoff, "A determinant formula for the number of ways of coloring a map," Ann. Math. 14 (1912), 42–46.

[2] H. Whitney, "The coloring of graphs," Ann. Math. 33 (1932), 688–718.

[3] W.T. Tutte, "A contribution to the theory of chromatic polynomials," Canadian J. Math. 6 (1954), 80–91.

[4] R.P. Stanley, "Acyclic orientations of graphs," Discrete Math. 5 (1973), 171–178.

[5] R.B. Potts, "Some generalized order-disorder transformations," Proc. Cambridge Phil. Soc. 48 (1952), 106–109.

[6] G. Gonthier, "Formal proof — the Four Color Theorem," Notices AMS 55 (2008), 1382–1393.

[7] K. Appel and W. Haken, "Every planar map is four colorable," Bull. AMS 82 (1976), 711–712.

[8] Mathlib Community, "Mathlib4: The Lean 4 Mathematical Library," https://github.com/leanprover-community/mathlib4.
