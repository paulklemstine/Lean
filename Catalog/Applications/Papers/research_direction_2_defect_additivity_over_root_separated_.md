# Defect Additivity over Root-Separated Pieces: A Mayer–Vietoris Principle for Rooted Graph Defect

## Abstract

We establish a decomposition law for the structural defect of rooted graph divisors. Given a connected simple graph G with a distinguished root vertex q, and a vertex subset S that decomposes as S = S₁ ∪ S₂ with S₁ and S₂ lying in distinct connected components of G − {q}, the structural defect satisfies δ(G,q,S₁ ∪ S₂) = δ(G,q,S₁) + δ(G,q,S₂) + 1. The correction term +1 is universal, independent of the internal structure of S₁ and S₂. We prove this through five independent additivity lemmas for the constituent invariants (edge count, component count, cycle rank, root component count), building an explicit equivalence between connected component types. The result generalizes to k pairwise root-separated pieces with correction term k−1. All proofs are machine-verified.

**Keywords:** graph defect, root separation, Mayer–Vietoris, chip-firing, tropical geometry, cycle rank, connected components

## 1. Introduction

### 1.1 Motivation

The structural defect δ(G,q,S) = β₁(G[S]) + κ(G,q,S) − 1 measures the gap between the tropical Laplacian rank and the Baker–Norine chip-firing rank of rooted subset divisors on finite graphs [1,2]. Prior work established nonnegativity (δ ≥ 0) and zero-defect rigidity (δ = 0 iff β₁ = 0 and κ = 1). The natural next question is: how does defect behave under subset decomposition?

### 1.2 Main Results

**Theorem A (Defect Decomposition Law).** Let G be a connected simple graph, q a root vertex, and S₁, S₂ root-separated pieces (Definition 2.1). Then:

$$\delta(G,q, S_1 \cup S_2) = \delta(G,q,S_1) + \delta(G,q,S_2) + 1$$

**Theorem B (Finite Additivity).** For k pairwise root-separated pieces S₁,...,Sₖ:

$$\delta(G,q, \bigcup_i S_i) = \sum_i \delta(G,q,S_i) + (k-1)$$

**Theorem C (Interaction Universality).** The defect interaction I_q(S₁,S₂) := δ(S₁∪S₂) − δ(S₁) − δ(S₂) = 1 for all root-separated pairs, independent of internal structure.

### 1.3 Relationship to Prior Work

The result builds on Baker–Norine [1] for the divisor theory framework, and on prior catalog results for nonnegativity, zero-defect rigidity, and the higher defect spectrum [3]. The decomposition law is new and has no precedent in the chip-firing literature.

## 2. Definitions and Notation

### 2.1 Root-Separated Pieces

**Definition 2.1.** Given a simple graph G = (V,E), root vertex q ∈ V, and subsets S₁, S₂ ⊆ V, we say (S₁, S₂) are **root-separated pieces** w.r.t. q if:
1. S₁ ∩ S₂ = ∅ (disjoint),
2. q ∉ S₁ and q ∉ S₂,
3. No vertex of S₁ is reachable from any vertex of S₂ in G − {q}.

Condition 3 is equivalent to: S₁ and S₂ lie in distinct connected components of G − {q}.

### 2.2 Graph Invariants

- **Induced edge count:** |E(G[S])| = number of edges with both endpoints in S.
- **Induced component count:** c(G[S]) = number of connected components of G[S].
- **Cycle rank (first Betti number):** β₁(G[S]) = |E(G[S])| + c(G[S]) − |S|.
- **Root component count:** κ(G,q,S) = number of components of G−{q} meeting S.
- **Structural defect:** δ(G,q,S) = β₁(G[S]) + κ(G,q,S) − 1.

### 2.3 Auxiliary Definitions

- **Rooted Euler defect:** χ_q(G,S) = 1 − δ(G,q,S).
- **Defect interaction:** I_q(S₁,S₂) = δ(S₁∪S₂) − δ(S₁) − δ(S₂).

## 3. Main Results

### 3.1 No Cross-Edges (Lemma 1)

**Lemma 3.1.** If S₁, S₂ are root-separated w.r.t. q, then G has no edge connecting a vertex of S₁ to a vertex of S₂.

*Proof sketch.* An edge u-v with u ∈ S₁, v ∈ S₂ would create an adjacency in G−{q} (since u,v ≠ q), contradicting unreachability. □

### 3.2 Edge Count Additivity (Lemma 2)

**Lemma 3.2.** |E(G[S₁ ∪ S₂])| = |E(G[S₁])| + |E(G[S₂])|.

*Proof sketch.* Every edge in G[S₁ ∪ S₂] has both endpoints in S₁ or both in S₂ (by Lemma 3.1). The edge sets partition cleanly. □

### 3.3 Component Count Additivity (Lemma 3)

**Lemma 3.3.** c(G[S₁ ∪ S₂]) = c(G[S₁]) + c(G[S₂]).

*Proof sketch.* This is the most technically demanding lemma. We construct an explicit bijection between connected components of G[S₁ ∪ S₂] and the disjoint sum of components of G[S₁] and G[S₂].

**Key sub-lemma:** If u, v ∈ S₁ ∪ S₂ are reachable in G[S₁ ∪ S₂] and u ∈ S₁, then v ∈ S₁. (Every walk starting in S₁ stays in S₁, because no edge crosses to S₂.)

**Forward map:** Classify each connected component by whether its vertices lie in S₁ or S₂.

**Reachability transfer:** If u and v are reachable in G[S₁ ∪ S₂] and both lie in S₁, then they are reachable in G[S₁] (the walk stays in S₁ by the sub-lemma, so it's a valid walk in G[S₁]).

**Bijectivity:** Injectivity from reachability transfer; surjectivity from inclusion. □

### 3.4 Cycle Rank Additivity (Theorem 1)

**Theorem 3.4.** β₁(G[S₁ ∪ S₂]) = β₁(G[S₁]) + β₁(G[S₂]).

*Proof.* From Lemmas 3.2, 3.3, and disjointness:
$$\beta_1(G[S_1 \cup S_2]) = |E_{1\cup 2}| + c_{1\cup 2} - |S_1 \cup S_2|$$
$$= (|E_1| + |E_2|) + (c_1 + c_2) - (|S_1| + |S_2|) = \beta_1(G[S_1]) + \beta_1(G[S_2])$$

(Uses |S₁ ∪ S₂| = |S₁| + |S₂| from disjointness, and requires |S_i| ≤ |E_i| + c_i for natural number subtraction.) □

### 3.5 Root Component Count Additivity (Theorem 2)

**Theorem 3.5.** κ(G,q,S₁ ∪ S₂) = κ(G,q,S₁) + κ(G,q,S₂).

*Proof sketch.* The components of G−{q} meeting S₁ ∪ S₂ biject with the disjoint union of components meeting S₁ and those meeting S₂. Injectivity: components meeting S₁ and those meeting S₂ are distinct (by root-separation). Surjectivity: every component meeting S₁ ∪ S₂ meets at least one of S₁, S₂. □

### 3.6 Defect Decomposition Law (Main Theorem)

**Theorem 3.6.** δ(G,q,S₁ ∪ S₂) = δ(G,q,S₁) + δ(G,q,S₂) + 1.

*Proof.* Expand:
$$\delta(S_1 \cup S_2) = \beta_1(S_1 \cup S_2) + \kappa(S_1 \cup S_2) - 1$$
$$= (\beta_1(S_1) + \beta_1(S_2)) + (\kappa(S_1) + \kappa(S_2)) - 1$$
$$= (\beta_1(S_1) + \kappa(S_1) - 1) + (\beta_1(S_2) + \kappa(S_2) - 1) + 1$$
$$= \delta(S_1) + \delta(S_2) + 1 \qquad\square$$

### 3.7 Corollaries

**Corollary 3.7 (Interaction universality).** I_q(S₁,S₂) = 1 for all root-separated pairs.

**Corollary 3.8 (Euler defect).** χ_q(S₁ ∪ S₂) = χ_q(S₁) + χ_q(S₂) − 2.

**Corollary 3.9 (k-piece formula).** δ(⋃ᵢ Sᵢ) = Σᵢ δ(Sᵢ) + (k−1).

## 4. Algorithms

### 4.1 Sector Decomposition

```
Algorithm: DECOMPOSE(G, q, S)
Input: Graph G, root q, subset S ⊆ V \ {q}
Output: List of root-separated sectors

1. Compute connected components C₁,...,Cₘ of G − {q}
2. For each Cᵢ, let Sᵢ = S ∩ Cᵢ
3. Return {Sᵢ : Sᵢ ≠ ∅}

Time: O(|V| + |E|)
Space: O(|V|)
```

### 4.2 Defect via Decomposition

```
Algorithm: DECOMPOSED_DEFECT(G, q, S)
Input: Graph G, root q, subset S
Output: δ(G, q, S)

1. sectors ← DECOMPOSE(G, q, S)
2. k ← |sectors|
3. Return Σᵢ δ(G, q, sectorsᵢ) + (k − 1)

Time: O(|V| + |E| + Σᵢ |Sᵢ|²)
```

When the root has high degree and splits S into many small sectors, this achieves significant speedup over computing δ directly on S.

## 5. Computational Experiments

### 5.1 Exhaustive Verification

We verified the decomposition law on all connected graphs with n ≤ 5 vertices:

| n | Connected graphs | Root-separated pairs | Confirmations | Counterexamples |
|---|-----------------|---------------------|---------------|-----------------|
| 3 | 4 | 6 | 6 | 0 |
| 4 | 38 | 264 | 264 | 0 |
| 5 | 728 | 13,400 | 13,400 | 0 |

Total: 13,670 tests, 0 counterexamples.

### 5.2 Interaction Energy Distribution

For non-separated pairs on graphs with n ≤ 5, the interaction energy I_q(S₁,S₂) takes values in {−1, 0, 1, 2, 3}. For root-separated pairs, I = 1 universally.

### 5.3 k-piece Additivity

Tested 830 families of pairwise root-separated pieces on graphs with n ≤ 5. All confirmed the k-piece formula.

## 6. Discussion

### 6.1 The +1 Correction

The correction term +1 arises algebraically from the −1 in the defect definition. When assembling k pieces, each with its own −1 baseline, the k individual baselines contribute −k, but the combined defect has only −1, yielding a correction of k − 1.

Topologically, this mirrors the Euler characteristic of a wedge sum: χ(X ∨ Y) = χ(X) + χ(Y) − 1, where the gluing point contributes −1.

### 6.2 Cross-Domain Significance

- **Mayer–Vietoris analogy:** The decomposition mirrors the Mayer–Vietoris sequence for reduced homology of wedge sums.
- **Statistical mechanics:** Root-separated pieces behave like non-interacting subsystems with universal interaction energy.
- **Tropical geometry:** The law enables sector-wise computation of tropical divisor invariants.

### 6.3 Limitations

The decomposition requires strict root-separation. For non-separated subsets, the interaction can be negative, zero, or positive, and no universal formula holds.

## 7. Future Work

1. Characterize the interaction I_q(S₁,S₂) for non-separated pairs.
2. Extend to weighted graphs and metric graphs.
3. Develop a full Mayer–Vietoris exact sequence for graph defect.
4. Apply to network resilience algorithms.

## References

1. Baker, M. and Norine, S. "Riemann–Roch and Abel–Jacobi theory on a finite graph." *Advances in Mathematics* 215 (2007), 766–801.
2. Develin, M., Santos, F., and Sturmfels, B. "On the rank of a tropical matrix." *Combinatorial and Computational Geometry*, MSRI Publ. 52 (2005), 213–242.
3. Catalog: TropicalBridge/DefectTheory.lean, TropicalBridge/HigherDefectTheory.lean.
