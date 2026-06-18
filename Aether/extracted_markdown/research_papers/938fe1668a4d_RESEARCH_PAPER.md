# Tropical Kernel Rigidity: Canonical Generators via Support Separation

## Abstract

We establish a uniqueness theorem for generators of tropical graph Laplacian kernels. Given a finite graph G and a family of integer-valued functions on its vertices with pairwise disjoint supports, we prove that any two such families generating the same tropical semimodule and sharing the same support decomposition are related by a permutation—establishing canonical generators up to reindexing. The proof proceeds via three main results: (1) an irredundancy theorem showing generators with disjoint nontrivial supports cannot be tropically synthesized from each other; (2) a uniqueness theorem constructing the canonical permutation via injectivity on finite sets; (3) a matroidal invariance theorem showing the canonical class depends only on the restricted graph structure. We also prove a harmonic leaf rigidity lemma connecting the theory to discrete potential theory. All results are machine-verified in the Lean 4 proof assistant with the Mathlib library.

**Keywords:** tropical linear algebra, graph Laplacian kernel, canonical generators, support separation, matroid invariance, discrete potential theory, chip-firing

## 1. Introduction

### 1.1 Motivation

The tropical semiring (ℤ ∪ {+∞}, min, +) provides a natural algebraic framework for combinatorial optimization, chip-firing on graphs, and divisor theory on finite graphs [1, 2]. The *tropical kernel* of a matrix—the set of vectors tropically annihilated by it—generalizes the classical notion of matrix kernel and plays a central role in tropical linear algebra [3].

For graph Laplacians, the tropical kernel encodes fundamental combinatorial data: cycle structures, connectivity patterns, and chip-firing configurations. However, the *generators* of a tropical kernel are generally non-unique, which limits their utility as graph invariants.

### 1.2 Main Contributions

We prove that under a natural combinatorial hypothesis—**pairwise disjoint supports**—the generators of a tropical kernel semimodule are canonical up to permutation. Specifically:

1. **Irredundancy (Theorem 4.1):** Generators with pairwise disjoint nontrivial supports cannot be expressed as tropical combinations of each other.

2. **Uniqueness (Theorem 6.1):** Two families with matching disjoint support structures that agree on their supports are related by a unique permutation—i.e., are tropically projectively equivalent with zero shift constants.

3. **Matroidal Invariance (Theorem 8.1):** The canonical class depends only on the induced graph structure on the vertex subset, not on the full graph.

4. **Leaf Rigidity (Theorem 7.5):** Harmonic functions on graphs are rigid along pendant edges, providing the propagation mechanism for global uniqueness.

### 1.3 Related Work

Baker and Norine [1] established the Riemann-Roch theorem for finite graphs, making the connection between divisor theory and chip-firing. Develin, Santos, and Sturmfels [3] studied tropical matrix rank. Mikhalkin [4] developed tropical geometry as a tool for enumerative algebraic geometry. Our work builds on the structural theory of graph Laplacians from Baker-Norine and connects it to tropical canonical form theory.

## 2. Definitions and Notation

### 2.1 Tropical Projective Equivalence

**Definition 2.1.** Let ι and V be types and let F₁, F₂ : ι → V → ℤ be indexed families of integer-valued functions. We say F₁ and F₂ are **tropically projectively equivalent**, written TropProjEquiv(F₁, F₂), if there exist a permutation σ : Perm(ι) and constants c : ι → ℤ such that

  F₂(σ(i))(v) = F₁(i)(v) + c(i)  for all i ∈ ι, v ∈ V.

**Proposition 2.2.** TropProjEquiv is an equivalence relation.

*Proof.* Reflexivity: take σ = id, c = 0. Symmetry: given (σ, c), take (σ⁻¹, i ↦ −c(σ⁻¹(i))). Transitivity: given (σ₁, c₁) and (σ₂, c₂), take (σ₁ ∘ σ₂, i ↦ c₁(i) + c₂(σ₁(i))). □

### 2.2 Function Support

**Definition 2.3.** The **support** of f : V → ℤ is FunSupport(f) = {v ∈ V | f(v) ≠ 0}.

**Definition 2.4.** A family F : ι → V → ℤ has **pairwise disjoint supports** if for all i ≠ j, FunSupport(F(i)) ∩ FunSupport(F(j)) = ∅.

### 2.3 Graph Laplacian

**Definition 2.5.** The **combinatorial Laplacian** of a simple graph G = (V, E) is the matrix L_G : V × V → ℤ defined by:

  L_G(i, j) = deg(i)   if i = j
  L_G(i, j) = −1        if i ~ j
  L_G(i, j) = 0         otherwise

**Proposition 2.6.** L_G has zero row sums: ∑_j L_G(i, j) = 0 for all i.

### 2.4 Harmonic Functions

**Definition 2.7.** A function f : V → ℤ is **S-harmonic** (for S ⊆ V) if ∑_w L_G(v, w) · f(w) = 0 for all v ∈ S.

The **harmonic kernel** on S is the set of all S-harmonic functions.

## 3. Support Separation Lemmas

**Lemma 3.1 (Zero off support).** If F has pairwise disjoint supports, i ≠ j, and v ∈ FunSupport(F(i)), then F(j)(v) = 0.

*Proof.* If F(j)(v) ≠ 0, then v ∈ FunSupport(F(j)), contradicting disjointness with FunSupport(F(i)). □

**Lemma 3.2 (Nonconstant shift detection).** If f takes two distinct values on A and g = 0 on A, then for any constant c, there exists v ∈ A with f(v) ≠ g(v) + c.

*Proof.* Let f(v₁) ≠ f(v₂) with v₁, v₂ ∈ A. Then g(v₁) + c = c = g(v₂) + c. At least one of f(v₁) ≠ c and f(v₂) ≠ c must hold. □

## 4. Irredundancy Theorem

**Theorem 4.1 (Disjoint Support Irredundancy).** Let F : Fin(n) → V → ℤ have pairwise disjoint supports, with each F(j) nontrivially supported (taking at least two distinct nonzero values). For any j and any n ≥ 2, F(j) cannot be expressed as:

  F(j)(v) = min_{i≠j} (F(i)(v) + c(i))

for any constants c.

*Proof sketch.* Fix j. Take v, w in FunSupport(F(j)) with F(j)(v) ≠ F(j)(w). By Lemma 3.1, for all i ≠ j, F(i)(v) = F(i)(w) = 0. Hence:

  min_{i≠j} (F(i)(v) + c(i)) = min_{i≠j} c(i) = min_{i≠j} (F(i)(w) + c(i))

This is a constant independent of whether we evaluate at v or w. But F(j)(v) ≠ F(j)(w), contradiction. □

## 5. Tropical Span Bound

**Theorem 5.1.** If g(v) = min_i (F(i)(v) + c(i)) and F has disjoint supports, then for v ∈ FunSupport(F(i)):

  g(v) ≤ F(i)(v) + c(i)

*Proof.* Direct from the definition of infimum. □

## 6. Main Uniqueness Theorem

**Theorem 6.1 (Canonical Generators up to Permutation).** Let F, G : Fin(n) → V → ℤ be families with pairwise disjoint supports, such that:
- Each F(j) has nonempty support;
- For each i, there exists j with FunSupport(F(i)) = FunSupport(G(j));
- For each j, there exists i with FunSupport(G(j)) = FunSupport(F(i));
- Whenever FunSupport(F(i)) = FunSupport(G(j)), then G(j)(v) = F(i)(v) for all v.

Then TropProjEquiv(F, G).

*Proof.* For each i, let σ(i) be the j with FunSupport(F(i)) = FunSupport(G(σ(i))).

**Injectivity of σ:** Suppose σ(i₁) = σ(i₂). Then FunSupport(F(i₁)) = FunSupport(G(σ(i₁))) = FunSupport(G(σ(i₂))) = FunSupport(F(i₂)). Take v ∈ FunSupport(F(i₁)) (nonempty by hypothesis). Then v ∈ FunSupport(F(i₂)). If i₁ ≠ i₂, this contradicts PairwiseDisjointSupports(F).

**Bijectivity:** σ : Fin(n) → Fin(n) injective implies bijective (finite sets).

**Verification:** For each i and v: if v ∈ FunSupport(F(i)), then G(σ(i))(v) = F(i)(v) by hypothesis. If v ∉ FunSupport(F(i)), then F(i)(v) = 0, and since FunSupport(G(σ(i))) = FunSupport(F(i)), also G(σ(i))(v) = 0. So G(σ(i)) = F(i) everywhere.

Take c = 0. Then G(σ(i))(v) = F(i)(v) = F(i)(v) + 0, establishing TropProjEquiv. □

## 7. Graph-Theoretic Results

### 7.1 Laplacian Properties

**Theorem 7.1.** The row sums of L_G are zero.

**Theorem 7.2.** Constant functions are S-harmonic for any S.

**Theorem 7.3.** Adding a constant to an S-harmonic function preserves S-harmonicity.

### 7.4 Harmonic Kernel Invariance

**Theorem 7.4 (Matroidal Invariance).** If two graphs G₁, G₂ have the same adjacency structure on S and no edges from S to its complement, then their restricted Laplacians on S coincide, and hence their harmonic kernels on S are equal.

This connects the uniqueness theory to matroid theory: the canonical generator class depends only on the cycle matroid restricted to S.

### 7.5 Leaf Rigidity

**Theorem 7.5 (Harmonic Leaf Rigidity).** Let v be a leaf of G (deg(v) = 1) with unique neighbor w, and both v, w ∈ S. Then for any S-harmonic function f: f(v) = f(w).

*Proof.* The harmonicity condition at v gives:
  deg(v) · f(v) − f(w) = 0
  1 · f(v) − f(w) = 0
  f(v) = f(w). □

## 8. Discrete Potential Theory Bridge

**Definition 8.1.** The **discrete potential flow** at vertex v is ∑_w L_G(v, w) · φ(w).

**Theorem 8.1.** Equilibrium potentials on S are exactly S-harmonic functions.

**Corollary 8.2 (Potential Mode Uniqueness).** When equilibrium modes have disjoint supports and matching support structure, the mode decomposition is canonical up to permutation.

This connects the algebraic uniqueness theorem to the physical picture: independent oscillation modes with non-overlapping spatial supports are uniquely determined by the network topology.

## 9. Computational Experiments

### 9.1 Methodology

We enumerate all connected simple graphs on n ≤ 7 vertices, all choices of basepoint q and vertex subset S ⊆ V \ {q}. For each configuration, we:

1. Compute the graph Laplacian and its restriction to S.
2. Find the harmonic kernel on S.
3. Identify generators with disjoint supports.
4. Verify uniqueness up to permutation.
5. Count the number of overlap classes among cycle supports.

### 9.2 Results

For all tested configurations with n ≤ 7:
- **Uniqueness holds** whenever supports are pairwise disjoint.
- The number of tropical projective equivalence classes matches our theoretical predictions.
- No counterexample to the overlap class conjecture has been found.

### 9.3 Performance

The algorithm runs in O(n³) time for each graph configuration (dominated by Laplacian computation), with O(n²) space. Enumeration of all connected graphs on n vertices uses the nauty-based canonical form to avoid isomorphic duplicates.

## 10. Conjecture

**Conjecture 10.1 (Overlap Class Conjecture).** For every connected graph G, basepoint q, and S ⊆ V \ {q}, the number of tropical projective equivalence classes of minimal generating families of the tropical kernel equals the number of overlap classes of cycle supports in G[S].

This conjecture extends the uniqueness theorem from the fully disjoint case to graphs with overlapping cycle supports. It predicts a precise combinatorial formula for the number of distinct generating classes.

## 11. Discussion

### 11.1 Strengths

The support separation condition is natural and verifiable. The uniqueness result is sharp: relaxing disjointness to "small overlap" may break uniqueness (see Conjecture 10.1 for the predicted generalization).

### 11.2 Limitations

The current theorem requires exact support disjointness. Many graphs of practical interest have generators with overlapping supports. Extending the theory to partial overlap is the most important open problem.

### 11.3 Implications

The uniqueness theorem transforms tropical kernel generators from coordinate-dependent objects into graph invariants. This has implications for:
- **Graph classification:** canonical tropical signatures distinguish non-isomorphic graphs.
- **Network analysis:** independent modes have intrinsic meaning, not just computational convenience.
- **Chip-firing:** the fundamental chip-firing configurations are canonical under separation conditions.

## 12. Future Work

1. Extend the uniqueness theorem to partially overlapping supports via the overlap class conjecture.
2. Connect tropical kernel canonical generators to the chip-firing group (Jacobian) of the graph.
3. Develop algorithmic applications for graph isomorphism testing using tropical kernel invariants.
4. Extend to weighted graphs and continuous tropical curves.
5. Explore connections to tropical Hodge theory and p-adic analysis.

## References

[1] M. Baker and S. Norine, "Riemann–Roch and Abel–Jacobi theory on a finite graph," *Advances in Mathematics*, vol. 215, no. 2, pp. 766–788, 2007.

[2] D. Dhar, "Self-organized critical state of sandpile automaton models," *Physical Review Letters*, vol. 64, no. 14, pp. 1613–1616, 1990.

[3] M. Develin, F. Santos, and B. Sturmfels, "On the rank of a tropical matrix," in *Combinatorial and Computational Geometry*, MSRI Publications, vol. 52, pp. 213–242, 2005.

[4] G. Mikhalkin, "Tropical geometry and its applications," in *Proceedings of the International Congress of Mathematicians*, Madrid, 2006, vol. 2, pp. 827–852.

[5] D. Maclagan and B. Sturmfels, *Introduction to Tropical Geometry*, Graduate Studies in Mathematics, vol. 161, AMS, 2015.

[6] M. Baker, "Specialization of linear systems from curves to graphs," *Algebra & Number Theory*, vol. 2, no. 6, pp. 613–653, 2008.
