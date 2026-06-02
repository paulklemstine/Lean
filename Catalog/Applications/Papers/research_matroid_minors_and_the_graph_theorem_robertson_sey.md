# Matroid Minors and the Robertson-Seymour Conjecture: A Formalized Framework

## Abstract

We present a formalized development of matroid minor theory with applications to the Robertson-Seymour conjecture for representable matroids. Working within the Lean 4 proof assistant using the Mathlib library's matroid infrastructure, we establish: (1) the dual-minor correspondence — duality commutes with the minor relation; (2) the antichain property of excluded minors for minor-closed properties; (3) the key structural theorem connecting well-quasi-ordering to finite forbidden minor characterizations; (4) the self-duality of the Robertson-Seymour conjecture for representable matroids; (5) bounds on minor chain lengths in finite matroids. We define representable matroids over arbitrary fields and formalize the statement of the Robertson-Seymour conjecture, proving that it implies finite excluded minor characterizations for all minor-closed subclasses. All results are machine-verified with no axioms beyond the standard foundations.

## 1. Introduction

The Robertson-Seymour theorem [RS04] is one of the deepest results in combinatorics: the set of finite graphs is well-quasi-ordered (WQO) by the graph minor relation. This was proved through a series of twenty papers spanning over two decades. The theorem's most celebrated consequence is that every minor-closed graph property is characterized by finitely many forbidden minors.

Matroid theory, initiated by Whitney [Whi35], provides a natural generalization of graph theory. A matroid abstracts the notion of linear independence, capturing common structure in graph theory, linear algebra, and combinatorial geometry. The minor relation for matroids — defined via deletion and contraction operations — generalizes the graph minor relation.

The extension of the Robertson-Seymour theorem to matroids is one of the central open problems in combinatorics. Geelen, Gerards, and Whittle [GGW14] announced that for any finite field $\mathbb{F}_q$, the class of $\mathbb{F}_q$-representable matroids is WQO by the minor relation. Complete proofs are being written as part of their matroid minors project.

In this work, we formalize the foundational theory connecting WQO to finite forbidden minor characterizations, working with Mathlib's matroid library which provides the basic matroid API including deletion, contraction, and the minor partial order.

## 2. Definitions

### 2.1 Matroids and Minors

We use Mathlib's definition of a matroid `M` on a ground set `M.E`, with independence predicate `M.Indep`. A **minor** of `M` is any matroid of the form `M ／ C ＼ D` (contract `C`, then delete `D`), denoted `N ≤m M`.

### 2.2 Minor-Closed Properties

**Definition (IsMinorClosed).** A predicate $P$ on matroids is *minor-closed* if whenever $P(M)$ holds and $N \leq_m M$, then $P(N)$ holds.

**Definition (IsExcludedMinor).** A matroid $M$ is an *excluded minor* for $P$ if $\neg P(M)$ and $P(N)$ for every strict minor $N <_m M$.

### 2.3 Well-Quasi-Ordering

**Definition (IsMinorWQO).** A class $S$ of matroids is *well-quasi-ordered* by the minor relation if for every infinite sequence $f : \mathbb{N} \to S$, there exist $i < j$ such that $f(i) \leq_m f(j)$.

**Definition (IsMinorAntichain).** A set $A$ of matroids is a *minor antichain* if for all $M, N \in A$, $M \leq_m N$ implies $M = N$.

### 2.4 Representable Matroids

**Definition (Representation).** A *representation* of a matroid $M$ over a field $F$ in dimension $n$ is a function $\varphi : \alpha \to F^n$ that is injective on $M.E$ and satisfies: $I \subseteq M.E$ is independent in $M$ if and only if $\{\varphi(x) : x \in I\}$ is linearly independent over $F$.

**Definition (IsRepresentable).** A matroid $M$ is *$F$-representable* if there exists a representation of $M$ over $F$ in some dimension.

### 2.5 The Robertson-Seymour Conjecture

**Definition (RobertsonSeymourConj).** The *Robertson-Seymour conjecture for $F$-representable matroids* states that for any sequence $f : \mathbb{N} \to \text{Matroid}$ with each $f(n)$ being $F$-representable, there exist $i < j$ with $f(i) \leq_m f(j)$.

## 3. Main Results

### 3.1 Dual-Minor Correspondence

**Theorem 1 (dual_isMinor_dual).** *If $N \leq_m M$, then $N^* \leq_m M^*$.*

*Proof sketch.* Write $N = M / C \setminus D$. Then $N^* = (M / C \setminus D)^* = M^* \setminus C / D$ by Mathlib's `dual_contract_delete`. Since $M^* \setminus C / D$ is a minor of $M^*$ (a delete followed by a contract), the result follows.

**Theorem 2 (dual_isMinor_iff).** *$N^* \leq_m M^*$ if and only if $N \leq_m M$.*

*Proof.* The forward direction is Theorem 1. For the converse, apply Theorem 1 to get $N^{**} \leq_m M^{**}$, then use $M^{**} = M$.

### 3.2 Antichain Properties

**Theorem 3 (excluded_minors_antichain).** *For any minor-closed property $P$, the set of excluded minors for $P$ forms a minor antichain.*

*Proof.* Suppose $M$ and $N$ are both excluded minors and $M \leq_m N$. If $M \neq N$, then $M <_m N$ (using antisymmetry of the minor order). Since $N$ is an excluded minor, every strict minor of $N$ satisfies $P$, so $P(M)$. But $M$ is an excluded minor, so $\neg P(M)$, a contradiction.

### 3.3 WQO and Finite Antichains

**Theorem 4 (wqo_implies_finite_antichains).** *If a class $S$ is minor-WQO, then every antichain in $S$ is finite.*

*Proof.* By contraposition. If $A$ were an infinite antichain in $S$, extract an injective sequence $f : \mathbb{N} \hookrightarrow A$. By WQO, there exist $i < j$ with $f(i) \leq_m f(j)$. By the antichain property, $f(i) = f(j)$, contradicting injectivity.

**Corollary (wqo_finite_excluded_minors).** *If $S$ is minor-WQO and $P$ is minor-closed with all excluded minors in $S$, then the set of excluded minors is finite.*

### 3.4 Robertson-Seymour Consequences

**Theorem 5 (wqo_implies_finite_obstructions).** *If the RS conjecture holds for $F$, then for any minor-closed subclass of $F$-representable matroids, the excluded minors within the representable class are finite.*

**Theorem 6 (rs_conj_dual_equivalent).** *The RS conjecture is self-dual: if representability over $F$ is closed under duality, then the WQO property for $F$-representable matroids implies the WQO property for their duals.*

*Proof.* Given a sequence $(f_n)$ with each $f_n^*$ representable, the dual-closure hypothesis gives each $f_n^{**} = f_n$ representable. The WQO hypothesis yields $i < j$ with $f_i \leq_m f_j$. By Theorem 1, $f_i^* \leq_m f_j^*$.

### 3.5 Structural Bounds

**Theorem 7 (finite_ground_finite_rank).** *A matroid with finite ground set has finite rank.*

*Proof.* The rank is the supremum of base cardinalities. Every base is a subset of the finite ground set, hence finite.

**Theorem 8 (minor_chain_length_bound).** *In a finite matroid $M$, any strictly descending chain of minors has length at most $|M.E|$.*

*Proof.* Each strict minor has a strictly smaller ground set (Theorem: strict_minor_ground_ssubset). A strictly increasing chain of subsets of a finite set of size $k$ has length at most $k$.

## 4. Discussion

### 4.1 Significance of the Formalization

Our formalization fills a gap in the Mathlib matroid library by establishing the connection between well-quasi-ordering and finite forbidden minor characterizations. The dual-minor correspondence (Theorem 1) was not previously available in Mathlib and is fundamental to structural matroid theory.

The key insight formalized here is the **tripartite connection**:

$$\text{WQO} \implies \text{Finite Antichains} \implies \text{Finite Excluded Minors}$$

This chain of implications is the mechanism by which the Robertson-Seymour theorem (or its matroid analogue) yields concrete structural consequences.

### 4.2 The Role of Representability

Our definition of representability via linear independence over a field captures the standard notion. The RS conjecture for representable matroids is stated as a WQO condition, and we prove it is equivalent to the `IsMinorWQO` condition on the representable class.

The self-duality result (Theorem 6) is particularly noteworthy: it shows that the RS conjecture need only be proved for one orientation of duality, as the other follows automatically.

### 4.3 What We Did Not Formalize

Two important results remain unformalized:

1. **Representability is minor-closed.** The proof requires constructing representations for contractions via quotient vector spaces. While mathematically well-known, the formal linear algebra is substantial.

2. **Dual of a representable matroid is representable.** This requires orthogonal complement constructions. Both results would require significant development of formalized matroid representation theory beyond what currently exists in Mathlib.

## 5. Algorithms

### 5.1 Excluded Minor Testing

Given a finite list of excluded minors $\{E_1, \ldots, E_k\}$ for a minor-closed property $P$, testing whether a matroid $M$ satisfies $P$ reduces to checking whether any $E_i$ is a minor of $M$.

**Algorithm:** For each excluded minor $E_i$, enumerate all possible contraction-deletion pairs $(C, D)$ with $|C| + |D| = |M.E| - |E_i.E|$ and test if $M / C \setminus D \cong E_i$.

**Complexity:** The naive algorithm is exponential in $|M.E|$. For fixed $k$ and bounded $|E_i.E|$, the problem is in FPT (fixed-parameter tractable) with parameter $|M.E| - \max_i |E_i.E|$.

### 5.2 Minor Containment

Testing whether $N \leq_m M$ is NP-complete in general (for graphs this is the subgraph homeomorphism problem). However, for fixed $N$, it is polynomial in $|M.E|$ by the Robertson-Seymour theory.

## 6. Future Work

1. Formalize representability as a minor-closed property, requiring development of matroid representation theory over quotient spaces.
2. Formalize the Geelen-Gerards-Whittle structure theorem for representable matroids.
3. Enumerate excluded minors for specific representability classes (e.g., GF(4)-representable matroids).
4. Connect the formalized matroid theory to the graph minor theorem via cycle matroids.

## References

- [GGW14] J. Geelen, B. Gerards, G. Whittle. "Solving Rota's conjecture." *Notices of the AMS*, 61(7), 2014.
- [Oxl11] J. Oxley. *Matroid Theory*. Oxford University Press, 2nd edition, 2011.
- [RS04] N. Robertson, P. Seymour. "Graph Minors. XX. Wagner's conjecture." *J. Combin. Theory Ser. B*, 92(2):325–357, 2004.
- [Whi35] H. Whitney. "On the abstract properties of linear dependence." *American J. Mathematics*, 57(3):509–533, 1935.
