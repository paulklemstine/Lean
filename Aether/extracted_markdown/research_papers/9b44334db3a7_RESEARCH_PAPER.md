# Hereditary Minor Systems: An Abstract Framework for Robertson-Seymour Theory

## Abstract

We introduce **Hereditary Minor Systems (HMS)**, an abstract algebraic framework that unifies graph minor theory and matroid minor theory under a single set of axioms. An HMS consists of a universe of combinatorial objects equipped with a minor relation (a preorder), a rank function, and finiteness conditions. Within this framework, we define the **Exclusion Spectrum** — a rank-by-rank count of excluded minors for a minor-closed property — and prove nine theorems, including the abstract Robertson-Seymour finite obstruction theorem: if the universe of an HMS is well-quasi-ordered, then every minor-closed property has finitely many proper excluded minors. We also establish dual pairing results for excluded minors in HMS equipped with duality involutions, showing that non-self-dual excluded minors come in pairs. All results are formalized and machine-verified in Lean 4 with Mathlib, using only standard axioms (propext, Classical.choice, Quot.sound).

**Keywords**: well-quasi-ordering, matroid minor, Robertson-Seymour theorem, excluded minors, hereditary minor system, formal verification

## 1. Introduction

The Robertson-Seymour theorem [RS04] is one of the landmark results of combinatorics: the class of finite graphs is well-quasi-ordered (WQO) under the graph minor relation. A consequence of profound importance is that any minor-closed graph property — such as planarity, embeddability on a fixed surface, or bounded treewidth — can be characterized by a *finite* set of excluded (forbidden) minors.

In parallel, matroid theory has developed its own minor theory. Matroids, introduced by Whitney [Wh35], abstract the notion of linear independence. The matroid minor operation (deletion and contraction) generalizes graph minor operations. A major open conjecture in matroid theory, due to Geelen, Gerards, and Whittle [GGW14], asserts that for any fixed finite field 𝔽_q, the class of 𝔽_q-representable matroids is WQO under the matroid minor relation.

The structural similarity between these two theories — both involving minor relations, WQO, and finite excluded minor characterizations — suggests the existence of a unifying framework. This paper provides such a framework.

### 1.1 Contributions

1. **Hereditary Minor System (HMS)**: A new abstract structure (Definition 2.1) capturing the axioms common to graph and matroid minor theory.

2. **Exclusion Spectrum**: A refinement of the classical "finite excluded minors" result that tracks excluded minors rank-by-rank (Definition 2.5).

3. **Nine Theorems**: Including the abstract Robertson-Seymour theorem (Theorem 4.3), dual pairing (Theorem 3.2), fixed-point-free involution on non-self-dual excluded minors (Theorem 3.3), and the complete lattice structure of minor-closed properties (Theorems 2.3–2.4).

4. **Machine Verification**: All results formalized in Lean 4 with Mathlib.

## 2. Definitions and Basic Properties

### 2.1 Hereditary Minor System

**Definition 2.1 (HMS).** A *Hereditary Minor System* is a tuple H = (Obj, ≤, ρ) where:
- Obj is a type of combinatorial objects
- ≤ is a preorder on Obj (the minor relation): reflexive and transitive
- ρ : Obj → ℕ is a rank function satisfying:
  - **Monotonicity**: M ≤ N implies ρ(M) ≤ ρ(N)
  - **Rank finiteness**: For each k ∈ ℕ, the set {M ∈ Obj | ρ(M) = k} is finite

### 2.2 Minor-Closed Properties

**Definition 2.2.** A property P : Obj → Prop is *minor-closed* if P(N) and M ≤ N imply P(M).

**Theorem 2.3.** The conjunction of two minor-closed properties is minor-closed.

*Proof.* If P(N) ∧ Q(N) and M ≤ N, then P(M) (by P minor-closed) and Q(M) (by Q minor-closed). □

**Theorem 2.4.** Arbitrary intersections of minor-closed properties are minor-closed.

*Proof.* If (∀i, Pᵢ(N)) and M ≤ N, then for each i, Pᵢ(M) by Pᵢ minor-closed. □

These results show that minor-closed properties form a complete lattice under inclusion.

### 2.5 Excluded Minors

**Definition 2.5 (Excluded Minor, rank-based).** An object M is an *excluded minor* for a minor-closed property P if:
- ¬P(M), and
- For all N with N ≤ M and ρ(N) < ρ(M), P(N).

**Definition 2.6 (Proper Excluded Minor).** An object M is a *proper excluded minor* for P if:
- ¬P(M), and
- For all N with N ≤ M and N ≠ M, P(N).

**Definition 2.7 (Exclusion Spectrum).** The exclusion spectrum of P at rank k is:
exclSpec(P, k) = |{M | M is an excluded minor for P and ρ(M) = k}|

**Theorem 2.8.** For any property P and rank k, exclSpec(P, k) is finite (bounded by the number of objects of rank k).

*Proof.* The set of excluded minors at rank k is a subset of {M | ρ(M) = k}, which is finite by the rank finiteness axiom. □

### 2.9 Excluded Minors as Antichains

**Theorem 2.9 (Strict Antichain).** If P is minor-closed and M, N are both excluded minors for P with M ≤ N and ρ(M) < ρ(N), then M = N (contradiction — so no such pair exists).

*Proof.* Since N is an excluded minor and M ≤ N with ρ(M) < ρ(N), we have P(M). But M is an excluded minor, so ¬P(M). Contradiction. □

**Theorem 2.10 (Proper Antichain).** Proper excluded minors form a true antichain: if M ≠ N are both proper excluded minors for P, then ¬(M ≤ N).

*Proof.* If M ≤ N and M ≠ N, then P(M) by N being a proper excluded minor. But ¬P(M) by M being an excluded minor. Contradiction. □

### 2.11 Refinement

**Theorem 2.11.** If P ⊆ Q are both minor-closed (i.e., P(M) implies Q(M) for all M), then every excluded minor for Q satisfies ¬P.

*Proof.* If M is excluded for Q, then ¬Q(M). If P(M), then Q(M) by P ⊆ Q. Contradiction. □

## 3. Duality Theory

### 3.1 Dual HMS

**Definition 3.1 (DualHMS).** A *Dual HMS* extends an HMS with a duality involution d : Obj → Obj such that:
- d(d(M)) = M for all M (involution)
- ρ(d(M)) = ρ(M) for all M (rank-preserving)

**Definition 3.2.** A property P is *self-dual* if P(M) ↔ P(d(M)) for all M.

### 3.2 Dual Pairing Theorem

**Theorem 3.2 (Dual Excluded Minor).** In a Dual HMS, if P is minor-closed and self-dual, and the minor relation commutes with duality (M ≤ N ↔ d(M) ≤ d(N)), then the dual of an excluded minor is an excluded minor.

*Proof sketch.* Let M be excluded for P. Then ¬P(M), so ¬P(d(M)) by self-duality. For any N ≤ d(M) with ρ(N) < ρ(d(M)) = ρ(M), we have d(N) ≤ d(d(M)) = M with ρ(d(N)) = ρ(N) < ρ(M). By M excluded, P(d(N)). By self-duality, P(N). □

### 3.3 Fixed-Point-Free Involution

**Theorem 3.3.** Under the hypotheses of Theorem 3.2, the dual operation restricted to non-self-dual excluded minors is a fixed-point-free involution: it maps each non-self-dual excluded minor to a distinct non-self-dual excluded minor, with d(M) ≠ M.

*Proof.* The dual of a non-self-dual excluded minor is an excluded minor (Theorem 3.2). It is non-self-dual: if d(d(M)) = d(M), then M = d(M) (since d(d(M)) = M), contradicting non-self-duality. Finally, d(M) ≠ M by definition of non-self-dual. □

**Corollary 3.4.** If the set of excluded minors is finite, the number of non-self-dual excluded minors is even.

## 4. Well-Quasi-Ordering and Finite Obstruction

### 4.1 Well-Quasi-Ordering

**Definition 4.1 (WQO).** A set S in an HMS is *well-quasi-ordered* if for every sequence f : ℕ → S, there exist i < j with f(i) ≤ f(j).

### 4.2 No Infinite Antichains

**Theorem 4.2.** In a WQO set S, there is no injective sequence that forms an antichain.

*Proof.* Suppose f : ℕ → S is injective with f(i) and f(j) incomparable for all i ≠ j. By WQO, there exist i < j with f(i) ≤ f(j). Since i ≠ j and f is injective, f(i) ≠ f(j). But f(i) ≤ f(j) contradicts incomparability. □

### 4.3 Main Theorem: Finite Proper Excluded Minors

**Theorem 4.3 (Abstract Robertson-Seymour).** If the universe Obj of an HMS is WQO, then for any minor-closed property P, the set of proper excluded minors is finite.

*Proof.* Proper excluded minors form an antichain (Theorem 2.10). If this antichain were infinite, there would exist an injective sequence into Obj that is an antichain in the WQO set Obj. This contradicts Theorem 4.2. □

### 4.4 Discussion

The elegance of the proof obscures a crucial asymmetry: establishing WQO is the hard part. The Robertson-Seymour theorem for graphs required 23 papers to prove that graphs are WQO under minors. The Geelen-Gerards-Whittle conjecture for 𝔽_q-representable matroids remains open for q ≥ 3.

Our framework separates the "easy" implication (WQO → finite excluded minors) from the "hard" content (proving WQO). This separation clarifies the mathematical landscape and provides a clean target for future work.

## 5. Examples and Applications

### 5.1 Graphs

The cycle matroid of a graph gives an HMS where Obj = finite graphs (up to isomorphism), ≤ = graph minor, ρ = number of edges. The Robertson-Seymour theorem says this HMS is WQO, so every minor-closed graph property has finitely many excluded minors.

**Example**: Planarity has excluded minors {K₅, K₃,₃} (Kuratowski/Wagner).

### 5.2 Matroids

For 𝔽_q-representable matroids, we can define an HMS with ρ = rank of the matroid. The Geelen-Gerards-Whittle conjecture is that this HMS is WQO for each fixed q.

**Known excluded minors for 𝔽₃-representability**: F₇ (Fano matroid), F₇* (dual Fano), and the non-Pappus matroid.

### 5.3 Boundary: General Matroids

For the class of all matroids (not restricted to a finite field), WQO fails. There exist infinite antichains of matroids — families where no matroid is a minor of another. This shows the finite-field restriction is essential.

## 6. Conjectures and Future Directions

**Conjecture 6.1 (Ternary WQO).** The class of 𝔽₃-representable matroids is WQO under the matroid minor relation.

**Conjecture 6.2 (Exclusion Spectrum Monotonicity).** For the HMS of graphs, the exclusion spectrum of minor-closed properties with at most n excluded minors is concentrated at ranks ≤ f(n) for some computable function f.

**Conjecture 6.3 (Dual Pairing Count).** For self-dual minor-closed properties of matroids, the proportion of self-dual excluded minors approaches 0 as the total number of excluded minors grows.

## 7. Related Work

- **Robertson-Seymour** [RS83–RS04]: Graph minor theorem, 23 papers.
- **Geelen-Gerards-Whittle** [GGW14]: Structure theory for 𝔽_q-representable matroids.
- **Nash-Williams** [NW63]: WQO of forests under topological containment.
- **Higman** [Hi52]: WQO of finite sequences under subsequence embedding.
- **Kruskal** [Kr60]: WQO of finite trees under homeomorphic embedding.

## 8. Conclusion

The Hereditary Minor System provides a clean, general, and machine-verified foundation for Robertson-Seymour-type theorems. By abstracting the common structure of graph and matroid minor theory, we reveal the essential ingredients needed for finite excluded minor characterizations: a WQO universe, a minor relation forming a preorder, and a rank function with finiteness properties. The framework is ready to absorb future WQO results — including, we hope, the resolution of the Geelen-Gerards-Whittle conjecture for ternary matroids.

## References

- [GGW14] J. Geelen, B. Gerards, G. Whittle. "Solving Rota's conjecture." *Notices AMS* 61 (2014), 736–743.
- [Hi52] G. Higman. "Ordering by divisibility in abstract algebras." *Proc. London Math. Soc.* 2 (1952), 326–336.
- [Kr60] J. B. Kruskal. "Well-quasi-ordering, the Tree Theorem, and Vazsonyi's conjecture." *Trans. AMS* 95 (1960), 210–225.
- [NW63] C. St.J.A. Nash-Williams. "On well-quasi-ordering finite trees." *Proc. Cambridge Phil. Soc.* 59 (1963), 833–835.
- [RS83] N. Robertson, P. D. Seymour. "Graph minors. I." *JCTB* 35 (1983), 39–61.
- [RS04] N. Robertson, P. D. Seymour. "Graph minors. XX. Wagner's conjecture." *JCTB* 92 (2004), 325–357.
- [Wh35] H. Whitney. "On the abstract properties of linear dependence." *Amer. J. Math.* 57 (1935), 509–533.
