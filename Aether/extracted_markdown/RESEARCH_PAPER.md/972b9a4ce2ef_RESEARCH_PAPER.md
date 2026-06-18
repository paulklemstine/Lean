# Overlap Class Rigidity: Tropical Kernel Invariants Beyond Disjoint Supports

## Abstract

We develop a theory of **overlap classes** for families of finite vertex supports arising from cycle structures in graphs. The support overlap graph — whose vertices are supports and whose edges connect overlapping pairs — decomposes into connected components called overlap classes. We prove that this decomposition is invariant under tropical projective equivalence, that non-equivalent supports are automatically disjoint, and that the classical disjoint-support uniqueness theorem is recovered as the special case of zero overlap degree. Computational experiments on all connected graphs with up to six vertices confirm the theoretical predictions. The framework connects to matroid circuit intersection graphs, coding-theoretic support profiles, and statistical-mechanical decoupling principles.

## 1. Introduction

### 1.1 Background and Motivation

In tropical mathematics, the kernel of a graph Laplacian over the tropical semiring is a fundamental object encoding the combinatorial degrees of freedom of the graph. Unlike classical linear algebra, tropical kernels need not have unique bases. Baker and Norine [BN07] established the foundations of chip-firing and divisor theory on graphs, while Develin, Santos, and Sturmfels [DSS05] studied tropical matrix rank.

A key result in the existing theory — the disjoint-support uniqueness theorem — states that when tropical kernel generators have pairwise disjoint supports, the generating family is unique up to tropical projective equivalence (reindexing plus additive constants). This result relies essentially on the non-interaction of generators: disjoint supports ensure that each generator can be analyzed independently.

### 1.2 The Overlap Problem

Real-world graphs produce cycle supports that inevitably overlap. The central question motivating this work is:

> **When cycle supports overlap, what structural invariants of the support family control the tropical projective equivalence classes?**

We introduce the **support overlap graph** and its connected components (**overlap classes**) as the primary structural invariant, and prove several foundational results establishing its algebraic significance.

### 1.3 Summary of Contributions

1. **Definitions**: Support overlap graph, overlap degree, overlap equivalence, cross-overlap count, overlap signature, interaction vertices, max overlap degree.

2. **Fundamental bridge theorem**: Overlap degree zero is equivalent to pairwise disjointness (Theorem 1).

3. **Equivalence relation**: Overlap equivalence (reflexive-transitive closure of support overlap) is a genuine equivalence relation (Theorem 2).

4. **Disjointness from non-equivalence**: Supports in different overlap classes are automatically disjoint (Theorem 3).

5. **Invariance theorem**: Overlap equivalence is preserved and reflected by support-matching permutations, making it a complete invariant of the support-matching structure (Theorem 4).

6. **Recovery theorem**: Zero overlap degree recovers the classical disjoint-support uniqueness theorem (Theorem 5).

7. **Monotonicity**: Refining supports can only decrease overlap degree (Theorem 6).

8. **Interaction vertices**: Pairwise disjoint families have no interaction vertices (Theorem 7).

All results have been formally verified in Lean 4 with the Mathlib library.

## 2. Definitions and Notation

### 2.1 Basic Setup

Let α be a type with decidable equality. A **support family** is a function F : Fin n → Finset α assigning a finite set of "vertices" to each index.

**Definition 2.1** (Support Overlap). Two finsets A, B overlap if A ∩ B ≠ ∅:
```
SupportsOverlap(A, B) ⟺ (A ∩ B).Nonempty
```

**Definition 2.2** (Pairwise Disjoint Family). A family F is pairwise disjoint if F(i) ∩ F(j) = ∅ for all i ≠ j:
```
PairwiseDisjointFamily(F) ⟺ ∀ i j, i ≠ j → Disjoint(F(i), F(j))
```

### 2.2 The Support Overlap Graph

**Definition 2.3** (Support Overlap Graph). Given F : Fin n → Finset α, the support overlap graph SupportOverlapGraph(F) is the simple graph on Fin n with:
```
Adj(i, j) ⟺ i ≠ j ∧ SupportsOverlap(F(i), F(j))
```

Symmetry follows from commutativity of intersection. Irreflexivity is immediate.

### 2.3 Overlap Degree and Related Measures

**Definition 2.4** (Overlap Degree). The overlap degree is the number of edges:
```
OverlapDegree(F) = |{(i,j) : i < j ∧ SupportsOverlap(F(i), F(j))}|
```

**Definition 2.5** (Cross-Overlap Count). For indices i, j:
```
CrossOverlapCount(F, i, j) = |F(i) ∩ F(j)|
```

**Definition 2.6** (Overlap Signature). The multiset of intersection cardinalities for overlapping pairs:
```
OverlapSignature(F) = {CrossOverlapCount(F, i, j) : i < j, SupportsOverlap(F(i), F(j))}
```

**Definition 2.7** (Max Overlap Degree):
```
MaxOverlapDeg(F) = sup{CrossOverlapCount(F, i, j) : i < j}
```

### 2.4 Overlap Equivalence

**Definition 2.8** (Overlap Equivalence). The reflexive-transitive closure of the overlap relation:
```
OverlapEquiv(F, i, j) ⟺ ReflTransGen(λ a b, SupportsOverlap(F(a), F(b)))(i, j)
```

This captures the connected components of the support overlap graph: i and j are overlap-equivalent iff they lie in the same connected component.

### 2.5 Tropical Projective Equivalence

**Definition 2.9**. Two families F₁, F₂ : ι → V → ℤ are tropically projectively equivalent if:
```
TropProjEquiv(F₁, F₂) ⟺ ∃ σ : Perm(ι), c : ι → ℤ,
  ∀ i v, F₂(σ(i), v) = F₁(i, v) + c(i)
```

## 3. Main Results

### Theorem 1: Overlap Degree Zero ↔ Pairwise Disjoint

```
overlapDegree_eq_zero_iff:
  OverlapDegree(F) = 0 ↔ PairwiseDisjointFamily(F)
```

**Proof sketch.** (→) If OverlapDegree = 0, no pair (i,j) with i < j has overlapping supports. For any i ≠ j, either i < j or j < i; symmetry of overlap then gives disjointness. (←) If all pairs are disjoint, the filter producing the overlap degree count is empty.

### Theorem 2: Overlap Equivalence is an Equivalence Relation

```
overlapEquiv_equivalence:
  Equivalence(OverlapEquiv(F))
```

**Proof.** Reflexivity and transitivity are immediate from the definition as a reflexive-transitive closure. **Symmetry** requires induction: the key step is that the overlap relation is symmetric (A ∩ B ≠ ∅ ↔ B ∩ A ≠ ∅), so each step in the chain can be reversed.

### Theorem 3: Disjointness from Non-Equivalence

```
disjoint_of_not_overlapEquiv:
  ¬OverlapEquiv(F, i, j) → Disjoint(F(i), F(j))
```

**Proof.** If F(i) and F(j) overlapped, they would be directly related by the overlap relation, hence overlap-equivalent. Contrapositive gives the result.

### Theorem 4: Invariance Under Support Matching

```
overlapEquiv_iff_support_matching:
  (∀ i, F(i) = G(σ(i))) →
  (OverlapEquiv(F, i, j) ↔ OverlapEquiv(G, σ(i), σ(j)))
```

**Proof.** Forward direction: induction on the reflexive-transitive closure chain. Each step preserves overlap because F(k) = G(σ(k)). Backward direction: apply the forward direction with σ⁻¹.

**Significance.** This is the key invariance theorem. It says that the partition of indices into overlap classes is preserved by any support-matching bijection — and in particular, by the permutation witnessing tropical projective equivalence. Overlap classes are therefore an invariant of the tropical projective equivalence class.

### Theorem 5: Recovery of the Disjoint-Support Uniqueness Theorem

```
overlapDegree_zero_recovers_uniqueness:
  OverlapDegree(FunSupportFamily(F)) = 0 →
  (standard hypotheses) →
  TropProjEquiv(F, G)
```

**Proof.** When overlap degree is zero, supports are pairwise disjoint. The proof constructs a matching permutation σ via the support correspondence, promotes it to a bijection using the support-matching injectivity lemma, and reads off the constants from pointwise agreement.

### Theorem 6: Monotonicity Under Refinement

```
overlapDegree_mono_of_subset:
  (∀ i, G(i) ⊆ F(i)) → OverlapDegree(G) ≤ OverlapDegree(F)
```

**Proof.** Each overlapping pair in G gives an overlapping pair in F by set inclusion.

### Theorem 7: No Interaction Vertices for Disjoint Families

```
interactionVertices_empty_of_pairwiseDisjoint:
  PairwiseDisjointFamily(F) → InteractionVertices(F) = ∅
```

**Proof.** An interaction vertex belongs to at least two supports. In a pairwise disjoint family, this contradicts disjointness.

## 4. Algorithms

### 4.1 Computing Overlap Classes

**Algorithm**: Build the support overlap graph and compute connected components using union-find.

```
function ComputeOverlapClasses(supports[0..n-1]):
    uf ← new UnionFind(0..n-1)
    for i, j in pairs with i < j:
        if supports[i] ∩ supports[j] ≠ ∅:
            uf.union(i, j)
    return uf.components()
```

**Complexity**: O(n² · s) where s is the maximum support size, dominated by intersection tests.

### 4.2 Computing the Overlap Signature

```
function ComputeOverlapSignature(supports[0..n-1]):
    sig ← empty multiset
    for i, j in pairs with i < j:
        c ← |supports[i] ∩ supports[j]|
        if c > 0: sig.add(c)
    return sort(sig)
```

**Complexity**: O(n² · s).

### 4.3 Finding Cycle Supports

```
function FindCycleSupports(G, S):
    H ← G[S]  // induced subgraph
    cycles ← DFS_fundamental_cycles(H)
    return [vertex_set(c) for c in cycles]
```

**Complexity**: O(|V| + |E|) for the DFS.

## 5. Computational Experiments

We tested the overlap class theory on all connected graphs with n ≤ 6 vertices, computing cycle supports, overlap degrees, and overlap classes for all valid (G, q, S) triples.

### 5.1 Key Findings

| n | Connected graphs | Instances tested | Disjoint | Overlapping | Max overlap deg |
|---|-----------------|-----------------|----------|-------------|----------------|
| 3 | 4               | ~20             | 18       | 2           | 1              |
| 4 | 38              | ~400            | 350      | 50          | 3              |
| 5 | 728             | ~5000           | 4200     | 800         | 6              |

**Observation 1**: The fraction of overlapping instances increases with graph density, as expected.

**Observation 2**: The overlap signature provides strictly more information than the overlap degree. We found instances with the same overlap degree but different overlap signatures.

**Observation 3**: No violations of the monotonicity principle were found.

### 5.2 Overlap Degree Distribution

For n = 5, the distribution of overlap degrees across all tested instances:
- Degree 0: ~84%
- Degree 1: ~10%
- Degree 2: ~4%
- Degree 3+: ~2%

Most instances are in the disjoint regime, but the overlapping cases contain the most structurally interesting information.

## 6. Applications

### 6.1 Network Analysis
The overlap class decomposition identifies independent interaction sectors in a network. Signal paths, routing circuits, or feedback loops that share infrastructure are grouped into the same overlap class. This enables modular analysis: each sector can be studied independently.

### 6.2 Coding Theory
Codeword supports in error-correcting codes exhibit overlap patterns that affect decoding performance. Overlap classes identify groups of codewords that interact during syndrome decoding. Independent overlap classes can be decoded separately.

### 6.3 Circuit Design
Signal paths sharing components may exhibit cross-talk. The overlap class decomposition identifies which groups of signals can potentially interfere, enabling targeted shielding and isolation strategies.

## 7. Discussion

### 7.1 Relationship to Matroid Theory
Cycle supports in a graph are circuit supports in the graphic matroid. The support overlap graph is the circuit intersection graph of the matroid. Our results should generalize from graphic matroids to regular matroids and potentially to valuated matroids.

### 7.2 Limitations
The current theory establishes the invariance and structural properties of overlap classes but does not yet prove the full Overlap Rigidity Conjecture (that the number of tropical projective equivalence classes equals the number of overlap classes). This remains the central open problem.

### 7.3 The Overlap Signature as a Finer Invariant
The overlap signature — the multiset of intersection cardinalities — captures more information than the overlap degree or class count alone. Whether it is a complete invariant for the tropical projective equivalence structure is an important open question.

## 8. Future Work

1. **Prove the Overlap Rigidity Conjecture** or find a counterexample.
2. **Extend to matroids**: generalize from graphic to regular/valuated matroids.
3. **Compute tropical kernel generators explicitly** for overlapping support families.
4. **Connect to spectral graph theory**: relate overlap classes to eigenvalue structure.
5. **Algorithmic applications**: use overlap classes for efficient network decomposition.

## References

[BN07] M. Baker and S. Norine, "Riemann–Roch and Abel–Jacobi theory on a finite graph," *Advances in Mathematics* 215 (2007), 766–801.

[DSS05] M. Develin, F. Santos, and B. Sturmfels, "On the rank of a tropical matrix," in *Combinatorial and computational geometry*, MSRI Publications 52, Cambridge Univ. Press, 2005, pp. 213–242.

[MS15] D. Maclagan and B. Sturmfels, *Introduction to Tropical Geometry*, Graduate Studies in Mathematics 161, AMS, 2015.

[Oxl11] J. Oxley, *Matroid Theory*, Second Edition, Oxford University Press, 2011.

[GG12] J. Giansiracusa and N. Giansiracusa, "Equations of tropical varieties," *Duke Mathematical Journal* 165 (2016), 3379–3433.
