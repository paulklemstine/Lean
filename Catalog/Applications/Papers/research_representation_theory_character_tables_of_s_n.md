# An Explicit Bijection Between Partitions of $n$ and Conjugacy Classes of the Symmetric Group $S_n$

**Author:** Aristotle
**Date:** 2026-06-26

## Abstract

We present a fully formalized, constructive proof that for every natural number $n$ the partitions of $n$ are in explicit one-to-one correspondence with the conjugacy classes of the symmetric group $S_n = \operatorname{Sym}(\{1,\dots,n\})$. The bijection is given concretely: a partition $p$ of $n$ is sent to the conjugacy class of a standard permutation $\pi_p$ whose disjoint-cycle lengths realize the parts of $p$ (parts equal to $1$ becoming fixed points), and a conjugacy class is sent to the cycle-length partition of any of its representatives. The construction is delicate because the standard *cycle type* of a permutation records only cycles of length $\geq 2$, suppressing fixed points; the central lemma reconstructs the full partition by restoring exactly the right number of unit parts. Combining injectivity and surjectivity yields the equivalence
$$\operatorname{Par}(n) \;\simeq\; \operatorname{Conj}(S_n),$$
and as an immediate corollary the number of conjugacy classes of $S_n$ equals the partition number $p(n)$, with $p(3)=3$, $p(4)=5$, $p(5)=7$. Because the number of irreducible complex characters of a finite group equals its number of conjugacy classes, this fixes the side length of the (square) character table of $S_n$ at $p(n)$. We discuss the role of this counting result as the structural prerequisite for computing character tables of symmetric groups, and list testable conjectures for follow-up work.

---

## 1. Introduction

The symmetric group $S_n$ is the group of all bijections of an $n$-element set under composition; it has order $n!$. Two of its most basic invariants are intertwined in a particularly clean way:

1. the **conjugacy classes** of $S_n$, the orbits under the action $\tau \mapsto \rho\,\tau\,\rho^{-1}$; and
2. the **partitions** of $n$, the multisets of positive integers summing to $n$.

The classical theorem connecting them states that two permutations are conjugate in $S_n$ if and only if they have the same multiset of cycle lengths, and that every multiset of cycle lengths summing to $n$ is realized. Consequently conjugacy classes of $S_n$ are indexed by partitions of $n$. This fact is the gateway to the representation theory of $S_n$: by Frobenius, the irreducible complex representations of $S_n$ are themselves indexed by partitions of $n$ (Specht modules), so the character table of $S_n$ is a square matrix of side $p(n)$ whose rows and columns are both naturally labeled by $\operatorname{Par}(n)$.

This paper records a from-scratch, machine-verified construction of the indexing bijection itself — not merely a cardinality equality, but an explicit equivalence of sets with an inverse, together with the supporting lemmas. The work is self-contained: it depends only on the standard library facts that (i) every admissible multiset is a cycle type and (ii) conjugacy of permutations is detected by equality of partitions.

### 1.1 Notation and conventions

- $\operatorname{Par}(n)$ denotes the set of partitions of $n$, i.e. finite multisets of positive integers with sum $n$.
- For a permutation $\sigma$, the **cycle type** $\operatorname{cycleType}(\sigma)$ is the multiset of lengths of the disjoint cycles of $\sigma$ that have length $\geq 2$. Fixed points (length-$1$ cycles) are **not** recorded.
- The **partition of a permutation** $\operatorname{part}(\sigma)$ is the full partition of $n$ obtained from $\operatorname{cycleType}(\sigma)$ by appending $n - |\operatorname{cycleType}(\sigma)|$ parts equal to $1$, where $|\cdot|$ denotes the multiset sum. Thus $\operatorname{part}(\sigma)$ records all cycle lengths, including fixed points, and its parts sum to $n$.
- $\operatorname{Conj}(S_n)$ denotes the set of conjugacy classes of $S_n$.
- $\operatorname{IsConj}(\sigma,\tau)$ means $\sigma$ and $\tau$ are conjugate.

We realize $S_n$ concretely as $\operatorname{Perm}(\operatorname{Fin} n)$, the permutations of the standard $n$-element type.

---

## 2. Background lemmas (imported, stated for completeness)

The construction rests on two standard structural facts, which we use as black boxes.

**Fact A (Existence of permutations with prescribed cycle type).**
A multiset $m$ of positive integers is the cycle type of some permutation of an $n$-element set if and only if every element of $m$ is $\geq 2$ and the sum of $m$ is at most $n$.

**Fact B (Conjugacy detects the partition).**
For $\sigma,\tau \in S_n$,
$$\operatorname{IsConj}(\sigma,\tau) \iff \operatorname{part}(\sigma) = \operatorname{part}(\tau).$$

Both facts are classical and available in the formalization's ambient library; the contribution of this paper is to leverage them into an explicit, invertible indexing of conjugacy classes by partitions.

---

## 3. The forward construction: from partitions to permutations

### 3.1 Realizing the larger parts as a cycle type

**Lemma 4 (`exists_perm_cycleType`).** *For every partition $p \in \operatorname{Par}(n)$ there exists $g \in S_n$ with*
$$\operatorname{cycleType}(g) = \{\, a \in p \;:\; a \geq 2 \,\}$$
*(the sub-multiset of parts of $p$ that are at least $2$).*

*Proof sketch.* Let $m = \{a \in p : a \geq 2\}$. Every element of $m$ is $\geq 2$ by construction, and $|m| \leq |p| = n$ because $m$ is a sub-multiset of $p$ and $p$ sums to $n$. By Fact A, $m$ is the cycle type of some permutation. $\qquad\blacksquare$

**Definition 3 (`permOfPartition`).** For $p \in \operatorname{Par}(n)$, let $\pi_p := \operatorname{permOfPartition}(p)$ be a chosen permutation provided by Lemma 4, so that by definition
$$\operatorname{cycleType}(\pi_p) = \{\, a \in p : a \geq 2 \,\}. \tag{`permOfPartition_cycleType`}$$

Geometrically, $\pi_p$ arranges $\{1,\dots,n\}$ into disjoint blocks whose sizes are the parts of $p$ and turns each block of size $\geq 2$ into a single cycle, leaving the size-$1$ blocks as fixed points.

### 3.2 Restoring the fixed points: the key lemma

The cycle type forgets fixed points, so to recover the original partition we must show that re-appending the suppressed $1$'s reproduces $p$ exactly.

**Lemma 6 (`permOfPartition_partition_parts`).** *For every $p \in \operatorname{Par}(n)$,*
$$\operatorname{part}(\pi_p) = p \quad\text{(equality of partitions; equivalently, equality of their parts as multisets).}$$

*Proof sketch.* By definition of $\operatorname{part}$ and Lemma 5,
$$\operatorname{part}(\pi_p) = \operatorname{cycleType}(\pi_p) \,\uplus\, \operatorname{replicate}\big(n - |\operatorname{cycleType}(\pi_p)|,\ 1\big) = \{a \in p : a \geq 2\} \,\uplus\, \operatorname{replicate}(k, 1),$$
where $k = n - \sum_{a \in p,\, a\geq 2} a$. We compare this against the decomposition of $p$ itself into large and small parts,
$$p = \{a \in p : a \geq 2\} \,\uplus\, \{a \in p : a < 2\}.$$
Since every part of a partition is positive, each element of $\{a \in p : a < 2\}$ equals $1$; hence $\{a \in p : a < 2\} = \operatorname{replicate}(\ell, 1)$ where $\ell$ is the number of unit parts. Summing $p$ gives $\sum_{a\geq 2} a + \ell\cdot 1 = n$, so $\ell = n - \sum_{a\geq 2} a = k$. Therefore the two small-part blocks coincide, and adding the (shared) large-part block yields $\operatorname{part}(\pi_p) = p$. $\qquad\blacksquare$

This lemma is the technical crux: it certifies that the map $p \mapsto \pi_p$ does not lose information through the fixed-point suppression built into the cycle-type convention.

---

## 4. The backward construction: from permutations to partitions

**Definition 7 (`permPartition`).** For $\sigma \in S_n$, define $\operatorname{permPartition}(\sigma) \in \operatorname{Par}(n)$ to be $\operatorname{part}(\sigma)$, viewed as a partition of the number $n$. A re-indexing is required because $\operatorname{part}(\sigma)$ is, a priori, a partition of $\operatorname{card}(\operatorname{Fin} n)$; the canonical identification $\operatorname{card}(\operatorname{Fin} n) = n$ supplies it.

**Lemma 9 (`parts_cast`).** *Transporting a partition along an equality of its underlying integer leaves its multiset of parts unchanged.*

**Lemma 8 (`permPartition_parts`).** *For every $\sigma$, $\operatorname{permPartition}(\sigma)$ has the same parts as $\operatorname{part}(\sigma)$.* (Immediate from Lemma 9.)

**Lemma 13 (`isConj_permOfPartition`).** *If $\sigma \in S_n$ satisfies $\operatorname{part}(\sigma) = p$ (as multisets of parts), then $\operatorname{IsConj}(\pi_p, \sigma)$.*

*Proof sketch.* By Fact B it suffices to show $\operatorname{part}(\pi_p) = \operatorname{part}(\sigma)$. By Lemma 6, $\operatorname{part}(\pi_p) = p = \operatorname{part}(\sigma)$. $\qquad\blacksquare$

---

## 5. The bijection

**Definition 10 (`toConjClass`).** $\Phi : \operatorname{Par}(n) \to \operatorname{Conj}(S_n)$, $\Phi(p) := [\pi_p]$, the conjugacy class of $\pi_p$.

**Definition 11 (`ofConjClass`).** $\Psi : \operatorname{Conj}(S_n) \to \operatorname{Par}(n)$, $\Psi(c) := \operatorname{permPartition}(\sigma)$ for any representative $\sigma \in c$. This is well defined: if $\sigma,\sigma'$ are conjugate then by Fact B they have equal partitions, so $\operatorname{permPartition}(\sigma) = \operatorname{permPartition}(\sigma')$. (Lemma 12, `ofConjClass_mk`, records $\Psi([\sigma]) = \operatorname{permPartition}(\sigma)$.)

**Lemma 14 (`toConjClass_injective`).** *$\Phi$ is injective.*

*Proof sketch.* Suppose $\Phi(p) = \Phi(q)$, i.e. $[\pi_p] = [\pi_q]$, so $\operatorname{IsConj}(\pi_p,\pi_q)$. By Fact B, $\operatorname{part}(\pi_p) = \operatorname{part}(\pi_q)$. By Lemma 6 these equal $p$ and $q$ respectively, hence $p = q$. $\qquad\blacksquare$

**Lemma 15 (`toConjClass_surjective`).** *$\Phi$ is surjective.*

*Proof sketch.* Let $c \in \operatorname{Conj}(S_n)$ and choose a representative $\sigma \in c$. Put $p := \operatorname{permPartition}(\sigma)$. By Lemma 13 (with $\operatorname{part}(\sigma) = p$ via Lemma 8), $\operatorname{IsConj}(\pi_p, \sigma)$, so $[\pi_p] = [\sigma] = c$. Thus $\Phi(p) = c$. $\qquad\blacksquare$

**Theorem 1 (Main, `partitionEquivConjClasses`).** *For every $n \in \mathbb{N}$, the maps $\Phi$ and $\Psi$ are mutually inverse, giving an explicit equivalence*
$$\operatorname{Par}(n) \;\simeq\; \operatorname{Conj}(S_n).$$

*Proof sketch.* $\Phi$ is a bijection by Lemmas 14 and 15. We verify the inverse is $\Psi$ directly.
- $\Psi(\Phi(p)) = \Psi([\pi_p]) = \operatorname{permPartition}(\pi_p)$, whose parts equal $\operatorname{part}(\pi_p) = p$ by Lemmas 8 and 6; hence $\Psi(\Phi(p)) = p$.
- $\Phi(\Psi(c))$: pick $\sigma \in c$; then $\Psi(c) = \operatorname{permPartition}(\sigma) =: p$ and, as in Lemma 15, $\Phi(p) = [\pi_p] = [\sigma] = c$.
Thus $\Psi = \Phi^{-1}$. $\qquad\blacksquare$

**Corollary 2 (Counting).** *The number of conjugacy classes of $S_n$ equals the partition number $p(n)$:*
$$|\operatorname{Conj}(S_n)| = p(n).$$
*In particular $|\operatorname{Conj}(S_3)| = 3$, $|\operatorname{Conj}(S_4)| = 5$, $|\operatorname{Conj}(S_5)| = 7$.*

*Proof.* A bijection of finite sets preserves cardinality; apply Theorem 1 and recall $|\operatorname{Par}(n)| = p(n)$. $\qquad\blacksquare$

---

## 6. Consequence for character tables

For any finite group $G$, the number of irreducible complex characters equals the number of conjugacy classes; hence the character table is a square matrix. Specializing to $G = S_n$ and invoking Corollary 2:

**Proposition 3.** *The character table of $S_n$ is a square matrix of side $p(n)$.* For $n = 3, 4, 5$ the tables are $3\times 3$, $5\times 5$, and $7\times 7$ respectively.

This is precisely the "column count" needed before any explicit character table of $S_n$ can be assembled: it tells us how many irreducible representations to find (the rows) and how many conjugacy classes to evaluate them on (the columns), and that the two counts agree. The Frobenius indexing of both rows and columns by $\operatorname{Par}(n)$ then makes the table a square matrix naturally addressed by pairs of partitions.

---

## 7. Algorithmic content

The proof is constructive and yields directly executable procedures:

1. **Enumerate $\operatorname{Par}(n)$** by the standard recursion on largest-part-bounded partitions; the count is $p(n)$.
2. **Realize a partition as a permutation** via `permOfPartition`: lay out $\{1,\dots,n\}$ into consecutive blocks of the prescribed sizes and cycle each block.
3. **Classify a permutation** via `permPartition`: compute the disjoint-cycle decomposition and read off the sorted multiset of cycle lengths (including fixed points).
4. **Conjugacy test**: two permutations are conjugate iff steps (3) produce equal partitions (Fact B), so conjugacy is decided in linear time after cycle decomposition.

These four primitives let one compute the full conjugacy-class census of $S_n$ — together with class sizes via the centralizer-order formula $|Z(\sigma)| = \prod_i i^{m_i}\, m_i!$ (where $m_i$ is the number of parts equal to $i$) and class size $n!/|Z(\sigma)|$ — and verify $\sum_{\text{classes}} (\text{class size}) = n!$ as a built-in consistency check. The accompanying demonstration code performs exactly this verification for $n \leq 6$.

---

## 8. Discussion and related structure

The result sits at the confluence of three classical themes:

- **Combinatorics.** The partition function $p(n)$, with Hardy–Ramanujan asymptotics $p(n) \sim \frac{1}{4n\sqrt 3}\, e^{\pi\sqrt{2n/3}}$, now also counts conjugacy classes of $S_n$.
- **Group theory.** Conjugacy in $S_n$ is governed entirely by cycle structure, an unusually transparent situation among finite groups.
- **Representation theory.** The squareness of the character table and the partition-indexing of both axes (Specht modules for rows, cycle types for columns) are the launching point for the Murnaghan–Nakayama rule, hook-length formula, and the rich combinatorics of symmetric functions.

The formalization's care around the cycle-type convention — that fixed points are suppressed and must be explicitly restored (Lemma 6) — is exactly the kind of detail that informal treatments gloss over but that a fully verified proof must confront.

---

## 9. Future directions

The following are stated so each can be turned directly into a formal `theorem ... := sorry` skeleton.

**C1. Conjugacy-class size formula (Cauchy / centralizer order).** For $\sigma \in S_n$ with $m_i$ parts equal to $i$, the centralizer has order $\prod_i i^{m_i}\, m_i!$ and the class has size $n! / \prod_i i^{m_i}\, m_i!$. Testable form: the sum over conjugacy classes of these class sizes equals $n!$.

**C2. Classes splitting in $A_n$.** A conjugacy class of $S_n$ contained in $A_n$ splits into two $A_n$-classes iff its cycle type consists of distinct odd parts. Conjecture (testable per $n$): $|\operatorname{Conj}(A_n)| = \#\{p : p \text{ even}\} + \#\{p : \text{distinct odd parts}\}$.

**C3. Counting permutations by number of cycles (Stirling numbers).** The number of $\sigma \in S_n$ with exactly $k$ cycles (counting fixed points) is the unsigned Stirling number of the first kind $c(n,k)$; $\sum_k c(n,k)x^k = x(x+1)\cdots(x+n-1)$ and $\sum_k c(n,k) = n!$.

**C4. Self-conjugate partitions.** The number of self-conjugate partitions of $n$ equals the number of partitions into distinct odd parts, with a bridge to symmetry of the character table.

**C5. Column sums of the character table.** For any finite group, the sum of a fixed column (indexed by $g$) equals the number of square roots of $g$, $\#\{x : x^2 = g\}$. For $S_n$: $\sum_\chi \chi(\sigma) = \#\{\tau : \tau^2 = \sigma\}$, testable per $n$ by decision procedures for small $n$.

---

## 10. Conclusion

We have given a complete, constructive, machine-checked bijection between partitions of $n$ and conjugacy classes of $S_n$, with an explicit inverse and full supporting lemmas. The central difficulty — reconstructing a permutation's partition from its fixed-point-suppressed cycle type — is resolved by Lemma 6. The immediate corollary fixes the side length of the symmetric group's character table at $p(n)$, providing the indispensable first ingredient for any explicit character-table computation for $S_3$, $S_4$, $S_5$, and beyond.
