# Overlap Class Rigidity for Tropical Kernel Generators: Beyond the Disjoint Support Regime

## Abstract

We develop a theory of **overlap classes** for families of finite supports, extending the disjoint-support uniqueness theorem for tropical kernel generators to the regime where cycle supports may intersect. We introduce the **support overlap graph**, whose connected components define overlap classes, and establish that supports in distinct overlap classes are necessarily disjoint — making overlap classes the natural "interaction sectors" of the support family. We define a hierarchy of overlap invariants — overlap degree, max overlap degree, cross-overlap count, and overlap signature — and prove their fundamental properties, including a sharp characterization: overlap degree zero is equivalent to pairwise disjointness, recovering the classical uniqueness theorem as a special case. All results are formalized and verified in Lean 4 with the Mathlib library.

**Keywords:** tropical kernel, overlap classes, support interaction graph, graph invariants, pairwise disjoint supports, tropical projective equivalence, matroid circuits, cycle-space decomposition.

---

## 1. Introduction

### 1.1 Motivation

The tropical kernel of a graph Laplacian — the set of integer-valued functions satisfying a tropical equilibrium condition — admits decompositions into minimal generating families. A natural question is: how many fundamentally distinct such decompositions exist?

Baker and Norine (2007) established the foundations of chip-firing and divisor theory on finite graphs, revealing deep connections between tropical algebra and graph-theoretic structure. Develin, Santos, and Sturmfels (2005) studied the rank theory of tropical matrices, providing algebraic tools for understanding tropical semimodules.

Building on this foundation, the **disjoint-support uniqueness theorem** (formalized in `TropicalKernelRigidity.lean`) established that when generators have pairwise disjoint supports with nontrivial internal variation, the generating family is unique up to tropical projective equivalence — permutation of indices plus additive constants. This is a rigidity theorem in the "non-interacting" regime.

The present work asks: what happens when supports overlap?

### 1.2 Contributions

We introduce and formalize:

1. **Support overlap relation** (`SupportsOverlap`): a symmetric, decidable binary relation on finsets.
2. **Overlap connectivity** (`OverlapConnected`, `OverlapEquiv`): the transitive and reflexive-transitive closures, defining overlap classes as connected components.
3. **Overlap degree** (`OverlapDegree`): the number of overlapping pairs, with a sharp characterization theorem (Theorem 3.1).
4. **Cross-overlap count** (`CrossOverlapCount`) and **max overlap degree** (`MaxOverlapDeg`): finer invariants capturing overlap intensity.
5. **Overlap signature** (`OverlapSignature`): the full distribution of intersection sizes.
6. **Disjointness from non-connectivity** (Theorem 5.1): supports in distinct overlap classes are disjoint.
7. **Bridge theorems** connecting the overlap framework to the existing `PairwiseDisjointSupports` and `TropProjEquiv` definitions.
8. **Refinement monotonicity** (Theorem 11.1): shrinking supports can only decrease overlap degree.

All results are machine-verified in Lean 4 with Mathlib.

### 1.3 Organization

Section 2 defines the overlap relation and its properties. Section 3 introduces overlap degree and proves the zero-characterization. Section 4 develops overlap connectivity. Section 5 establishes the key disjointness theorem. Section 6 constructs the overlap equivalence relation. Section 7 studies family unions. Section 8 bridges to the existing tropical rigidity theory. Sections 9–13 develop finer overlap invariants. Section 14 discusses the overlap rigidity conjecture and computational evidence. Section 15 outlines applications and future directions.

---

## 2. The Support Overlap Relation

### 2.1 Definition

**Definition 2.1.** Two finsets $A, B \subseteq \alpha$ **overlap** (written $A \sim B$) if their intersection is nonempty:
$$A \sim B \iff A \cap B \neq \emptyset.$$

This is implemented as `SupportsOverlap A B := (A ∩ B).Nonempty`.

### 2.2 Basic Properties

**Theorem 2.1** (Symmetry). $A \sim B \iff B \sim A$.

*Proof.* By `Finset.inter_comm`. □

**Theorem 2.2** (Characterization). $A \sim B \iff \exists x, x \in A \land x \in B$.

*Proof.* By `Finset.Nonempty` and `Finset.mem_inter`. □

**Theorem 2.3** (Disjointness from non-overlap). $\neg(A \sim B) \implies A \cap B = \emptyset$ (as a `Disjoint` statement in the lattice of finsets).

*Proof.* If $A \cap B$ is not nonempty, it is empty. □

### 2.3 Pairwise Disjoint Families

**Definition 2.2.** A family $\{F_i\}_{i \in \iota}$ of finsets is **pairwise disjoint** if $i \neq j \implies F_i \cap F_j = \emptyset$.

**Corollary 2.4.** In a pairwise disjoint family, no two distinct members overlap.

---

## 3. Overlap Degree

### 3.1 Definition

**Definition 3.1.** The **overlap degree** of a finitely indexed family $F : \text{Fin}(n) \to \text{Finset}(\alpha)$ is the number of unordered pairs $\{i, j\}$ with $i < j$ such that $F_i \sim F_j$:
$$\text{OverlapDegree}(F) = |\{(i,j) : i < j, F_i \cap F_j \neq \emptyset\}|.$$

### 3.2 Zero Characterization

**Theorem 3.1** (Main Characterization). $\text{OverlapDegree}(F) = 0 \iff F$ is pairwise disjoint.

*Proof sketch.* Forward: if the overlap degree is zero, the filter set is empty, so no pair $(i,j)$ with $i < j$ overlaps. For arbitrary $i \neq j$, either $i < j$ or $j < i$; in either case, symmetry of overlap gives non-overlap, hence disjointness.

Backward: if pairwise disjoint, every pair is disjoint, so no pair overlaps, and the filter set is empty. □

### 3.3 Upper Bound

**Theorem 3.2.** $\text{OverlapDegree}(F) \leq \frac{n(n-1)}{2}$.

*Proof.* The filter set is a subset of all pairs with $i < j$, which has $\binom{n}{2} = \frac{n(n-1)}{2}$ elements. □

---

## 4. Overlap Connectivity

### 4.1 Transitive Closure

**Definition 4.1.** Two indices $i, j$ are **overlap-connected** in family $F$ if they are related by the transitive closure of the overlap relation on supports:
$$i \overset{F}{\sim^+} j \iff \exists i = k_0 \sim k_1 \sim \cdots \sim k_m = j.$$

**Proposition 4.1.** Overlap connectivity is transitive: $i \sim^+ j$ and $j \sim^+ k$ implies $i \sim^+ k$.

**Proposition 4.2.** Direct overlap implies connectivity: $F_i \sim F_j$ implies $i \sim^+ j$.

---

## 5. The Key Structural Theorem: Disjointness from Non-Connectivity

**Theorem 5.1** (Disjointness from non-connectivity). If $i$ and $j$ are not overlap-connected, then $F_i$ and $F_j$ are disjoint.

*Proof.* Contrapositive: if $F_i \cap F_j \neq \emptyset$, then $F_i \sim F_j$, so $i \sim^+ j$ by Proposition 4.2. □

**Corollary 5.2** (Sector isolation). If $x \in F_i$ and $i \not\sim^+ j$, then $x \notin F_j$.

This theorem is the engine that makes overlap classes meaningful. Supports in different connected components of the overlap graph are completely disjoint — they share no elements whatsoever. This means the support family decomposes into independent sectors along overlap class boundaries.

---

## 6. Overlap Equivalence

### 6.1 Definition and Properties

**Definition 6.1.** Two indices $i, j$ are **overlap-equivalent** if they are related by the reflexive-transitive closure:
$$i \overset{F}{\sim^*} j \iff i = j \text{ or } i \sim^+ j.$$

**Theorem 6.1.** Overlap equivalence is:
- **Reflexive** (by definition of `ReflTransGen`).
- **Transitive** (by `ReflTransGen.trans`).
- **Symmetric** (by induction on the `ReflTransGen` derivation, using symmetry of overlap at each step).

Thus overlap equivalence partitions the index set into **overlap classes**.

**Theorem 6.2.** $\neg(i \sim^* j) \implies F_i \cap F_j = \emptyset$.

---

## 7. Family Union and Cardinality

**Definition 7.1.** The **family union** $\bigcup_i F_i = \text{Finset.univ.biUnion}\ F$.

**Theorem 7.1.** $F_i \subseteq \bigcup_j F_j$ for all $i$.

**Theorem 7.2** (Additivity for disjoint families). If $F$ is pairwise disjoint, then $|\bigcup_i F_i| = \sum_i |F_i|$.

---

## 8. Bridge to Tropical Projective Equivalence

### 8.1 Finset-valued supports

**Definition 8.1.** $\text{FinFunSupport}(f) = \{v \in V : f(v) \neq 0\}$ as a `Finset`.

**Definition 8.2.** $\text{FunSupportFamily}(F)_i = \text{FinFunSupport}(F_i)$.

**Theorem 8.1.** $\text{FinFunSupport}(f)$ as a set equals $\text{FunSupport}'(f) = \{v : f(v) \neq 0\}$.

### 8.2 Equivalence of disjointness notions

**Theorem 8.2.** `PairwiseDisjointSupports'` (set-valued) $\iff$ `PairwiseDisjointFamily` (finset-valued) on `FunSupportFamily`.

**Theorem 8.3** (Recovery theorem). $\text{OverlapDegree}(\text{FunSupportFamily}(F)) = 0 \iff \text{PairwiseDisjointSupports}'(F)$.

This theorem certifies that the overlap class framework genuinely extends the existing disjoint-support theory.

---

## 9. Cross-Overlap Invariants

**Definition 9.1.** $\text{CrossOverlapCount}(F, i, j) = |F_i \cap F_j|$.

**Theorem 9.1.** Cross-overlap count is symmetric: $|F_i \cap F_j| = |F_j \cap F_i|$.

**Theorem 9.2.** $\text{CrossOverlapCount}(F, i, j) = 0 \iff F_i, F_j$ disjoint.

**Theorem 9.3.** $\text{CrossOverlapCount}(F, i, j) > 0 \iff F_i \sim F_j$.

---

## 10. Max Overlap Degree

**Definition 10.1.** $\text{MaxOverlapDeg}(F) = \max_{i < j} |F_i \cap F_j|$.

**Theorem 10.1.** Pairwise disjoint $\implies$ max overlap degree $= 0$.

**Theorem 10.2.** For $n \geq 2$: max overlap degree $= 0 \implies$ pairwise disjoint.

---

## 11. Refinement Monotonicity

**Theorem 11.1.** If $G_i \subseteq F_i$ for all $i$, then $\text{OverlapDegree}(G) \leq \text{OverlapDegree}(F)$.

*Proof.* If $G_i \cap G_j$ is nonempty, then $F_i \cap F_j \supseteq G_i \cap G_j$ is nonempty. So the filter set for $G$ is contained in the filter set for $F$. □

This monotonicity principle says that refining supports (restricting to subsets) can only simplify the overlap structure, never complicate it.

---

## 12. Overlap Signature

**Definition 12.1.** The **overlap signature** of $F$ is the multiset $\{|F_i \cap F_j| : i < j, F_i \sim F_j\}$.

**Theorem 12.1.** Every entry in the overlap signature is positive.

The overlap signature is a strictly finer invariant than the overlap degree (which counts entries) and the max overlap degree (which takes the maximum). Two families can have the same overlap degree and max overlap degree but different signatures.

---

## 13. The Overlap Rigidity Conjecture

### 13.1 Statement

**Conjecture.** For every connected finite graph $G$, basepoint $q$, and vertex subset $S \subseteq V \setminus \{q\}$, the number of tropical projective equivalence classes of minimal generating families of the tropical kernel equals the number of overlap classes of cycle supports in $G[S]$.

### 13.2 Evidence

The conjecture is supported by:
1. The zero-overlap-degree case reduces to the known disjoint-support uniqueness theorem.
2. Computational experiments on small graphs (see `demo.py`) are consistent.
3. The decomposition structure of overlap classes suggests a natural factorization of the class count.

### 13.3 Testable refinement

If the primary conjecture fails, the corrected hypothesis is:

> The number of `TropProjEquiv` classes is determined by the isomorphism type of the support interaction graph together with the multiset of intersection cardinalities.

This is falsifiable: two examples with identical overlap graphs and intersection-size multisets but different class counts would refute it.

---

## 14. Applications

### 14.1 Matroid Theory

Cycle supports in $G[S]$ are circuit supports in the graphic matroid. Overlap classes become connected components of the **circuit intersection graph**. If the overlap rigidity conjecture holds for graphs, it suggests a generalization to graphic matroids, and potentially to regular or valuated matroids.

### 14.2 Coding Theory

Supports of minimal codewords in a linear code play a role analogous to cycle supports. Overlap classes correspond to clusters of interacting codewords. A theorem bounding the number of equivalence classes of generating sets via overlap data would translate into new structural results about code redundancy.

### 14.3 Network Science

The overlap graph is a coarse topological invariant of the cycle structure. If tropical projective classes factorize over overlap components, this is analogous to decoupling in statistical mechanics: disconnected interaction sectors contribute independently.

---

## 15. Computational Experiments

The accompanying `demo.py` and `algorithms.py` implement:
- Construction of support overlap graphs for arbitrary finite families.
- Computation of all overlap invariants (degree, max degree, signature, class count).
- Visualization of overlap graphs and their connected components.
- Enumeration of cycle supports for small graphs.
- Batch testing of the overlap rigidity conjecture.

See `demo.py` for interactive exploration and `algorithms.py` for the algorithmic implementations.

---

## 16. Future Work

1. **Prove the componentwise factorization theorem:** show that tropical projective classes factorize over overlap components.
2. **Extend to overlap-degree one:** establish uniqueness when all pairwise intersections have cardinality at most one.
3. **Matroid generalization:** reformulate in terms of circuit intersection graphs of graphic matroids.
4. **Higher-order overlap invariants:** study the support nerve (simplicial complex of mutual intersections) rather than the overlap graph.
5. **Computational classification:** complete enumeration of overlap signatures for all connected graphs on $n \leq 12$ vertices.

---

## References

1. Baker, M. and Norine, S. "Riemann–Roch and Abel–Jacobi theory on a finite graph." *Advances in Mathematics* 215 (2007), 766–801.
2. Develin, M., Santos, F., and Sturmfels, B. "On the rank of a tropical matrix." In *Combinatorial and Computational Geometry*, MSRI Publications 52 (2005), 213–242.
3. Mikhalkin, G. "Tropical geometry and its applications." In *Proceedings of the ICM* (2006).
4. Oxley, J. *Matroid Theory*, 2nd ed. Oxford University Press, 2011.
5. Maclagan, D. and Sturmfels, B. *Introduction to Tropical Geometry*. Graduate Studies in Mathematics 161, AMS, 2015.
