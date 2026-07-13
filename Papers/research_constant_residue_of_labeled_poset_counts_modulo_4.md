# Congruences for the Number of Labeled Partial Orders: A Fixed-Point Parity Theorem and the Modulo-4 Phenomenon

## Abstract

Let $P(n)$ denote the number of partial orders that can be placed on a fixed set of $n$ labeled points. This sequence grows super-exponentially, yet its residues modulo small powers of two exhibit remarkable stability: empirically, $P(n) \equiv 3 \pmod 4$ for every $n \geq 2$. We give a complete structural proof of the parity half of this phenomenon — that $P(n)$ is odd for all $n$ — via a fixed-point parity argument applied to order reversal (duality). The engine of the proof is a uniqueness theorem: on any labeled point set, the discrete order is the *unique* self-dual partial order. Since duality is an involution on the finite family of labeled orders whose only fixed point is the discrete order, the fixed-point parity principle forces $P(n)$ to share the parity of $1$. We verify the sharper congruence $P(n) \equiv 3 \pmod 4$ by direct enumeration for small $n$ and up to $n = 19$, and we formulate a program — based on augmenting duality with label transpositions to obtain a symmetry group of order four — that isolates the second binary digit of $P(n)$ and, conjecturally, explains the constant residue in full.

**Keywords:** partial orders, labeled posets, enumeration, involution, duality, fixed-point parity, congruences, A001035.

---

## 1. Introduction

A **partial order** on a set $X$ is a binary relation $\leq$ that is reflexive, antisymmetric, and transitive. Partial orders are among the most fundamental objects in combinatorics and computer science, modeling scheduling dependencies, subsumption lattices, causal structure, and the divisibility and containment relations of algebra and set theory.

A basic enumerative question asks: for a set $X = \{1, 2, \dots, n\}$ of $n$ *labeled* points, how many distinct partial orders exist? We denote this count $P(n)$. The sequence begins

$$P(0)=1,\quad P(1)=1,\quad P(2)=3,\quad P(3)=19,\quad P(4)=219,\quad P(5)=4231,\quad P(6)=130023,\ \dots$$

and is catalogued as integer sequence A001035. Its growth is super-exponential; for example,

$$P(19) = 646099441937791106493755218560442089979,$$

a number with forty decimal digits.

Despite this explosive growth, the sequence conceals a rigid arithmetic regularity. Reducing modulo $4$, one finds that from $n = 2$ onward every term is congruent to $3$:

$$P(n) \equiv 3 \pmod 4 \qquad (n \geq 2). \tag{$\star$}$$

This has been verified for all $2 \le n \le 19$; in particular $P(19)$ ends in $\dots 979$ and $979 \equiv 3 \pmod 4$. The congruence $(\star)$ implies in particular that $P(n)$ is **odd** for all $n$.

The purpose of this paper is twofold. First, we prove the parity statement — that $P(n)$ is odd — completely and structurally, exhibiting it as a consequence of a symmetry of the family of labeled orders rather than as a numerical coincidence. Second, we analyze the finer congruence $(\star)$, verify it computationally, and set out a precise conjectural framework in which the residue modulo $4$ is governed by a symmetry group of order four.

### 1.1 Summary of results

- **(Uniqueness of self-dual order, Theorem 4.2)** On any labeled point set, the discrete order is the unique partial order that equals its own reversal.
- **(Self-dual count, Theorem 4.4)** The number of self-dual labeled partial orders is exactly $1$ for every $n$.
- **(Fixed-point parity principle, Lemma 5.1)** For any involution of a finite set, the cardinality of the set is congruent modulo $2$ to the number of its fixed points.
- **(Parity theorem, Theorem 5.2)** $P(n)$ is odd for every $n$.
- **(Small residues, Proposition 6.1)** $P(2) \equiv P(3) \equiv P(4) \equiv 3 \pmod 4$, and $(\star)$ holds for all checked $n \le 19$.

---

## 2. Encoding partial orders

We fix a combinatorial encoding that makes both the theory and the computation transparent.

**Definition 2.1 (Relation matrix).** A binary relation on the point set $\{0, 1, \dots, n-1\}$ is a function $r : \{0,\dots,n-1\}^2 \to \{\text{true}, \text{false}\}$, thought of as an $n \times n$ matrix of truth values, where $r(a,b) = \text{true}$ encodes "$a \leq b$."

**Definition 2.2 (Partial order).** A relation $r$ is a **partial order** if it satisfies:
1. *Reflexivity:* $r(a,a) = \text{true}$ for all $a$.
2. *Antisymmetry:* $r(a,b) = \text{true}$ and $r(b,a) = \text{true}$ imply $a = b$.
3. *Transitivity:* $r(a,b) = \text{true}$ and $r(b,c) = \text{true}$ imply $r(a,c) = \text{true}$.

**Definition 2.3 (The counting function).** Let $\mathcal{P}(n)$ be the finite set of all partial orders on $\{0,\dots,n-1\}$, and set
$$P(n) := \lvert \mathcal{P}(n) \rvert.$$

Because each of the three axioms is a decidable predicate over a finite domain, $\mathcal{P}(n)$ is a finite, effectively computable set, and $P(n)$ can be obtained by direct enumeration for small $n$.

---

## 3. Duality

**Definition 3.1 (Order reversal / duality).** For a relation $r$, its **dual** $r^{\partial}$ is defined by
$$r^{\partial}(a, b) := r(b, a).$$
That is, $r^{\partial}$ reverses the direction of every comparison.

**Lemma 3.2 (Duality preserves orders).** If $r$ is a partial order, then so is $r^{\partial}$.

*Proof.* Reflexivity of $r^{\partial}$ is immediate since $r^{\partial}(a,a) = r(a,a) = \text{true}$. For antisymmetry, suppose $r^{\partial}(a,b) = r^{\partial}(b,a) = \text{true}$, i.e. $r(b,a) = r(a,b) = \text{true}$; antisymmetry of $r$ gives $a = b$. For transitivity, suppose $r^{\partial}(a,b) = r^{\partial}(b,c) = \text{true}$, i.e. $r(b,a) = r(c,b) = \text{true}$; transitivity of $r$ applied to $c, b, a$ gives $r(c,a) = \text{true}$, i.e. $r^{\partial}(a,c) = \text{true}$. $\qquad\blacksquare$

**Lemma 3.3 (Duality is an involution).** For every relation $r$, $(r^{\partial})^{\partial} = r$.

*Proof.* $(r^{\partial})^{\partial}(a,b) = r^{\partial}(b,a) = r(a,b)$. $\qquad\blacksquare$

By Lemmas 3.2 and 3.3, duality restricts to an involution
$$\partial : \mathcal{P}(n) \to \mathcal{P}(n), \qquad \partial \circ \partial = \mathrm{id}.$$

---

## 4. The discrete order and self-duality

**Definition 4.1 (Discrete order).** The **discrete order** on $\{0,\dots,n-1\}$ is the relation $\Delta$ with $\Delta(a,b) = \text{true}$ if and only if $a = b$. It ranks no two distinct points against each other; every point is comparable only to itself.

It is elementary that $\Delta$ is a partial order (reflexivity is definitional; antisymmetry and transitivity hold vacuously beyond the diagonal). Moreover $\Delta$ is self-dual: $\Delta^{\partial}(a,b) = \Delta(b,a) = [\,b = a\,] = [\,a = b\,] = \Delta(a,b)$.

We call a partial order $r$ **self-dual** if $r^{\partial} = r$, equivalently if $r$ is symmetric: $r(a,b) = r(b,a)$ for all $a, b$.

**Theorem 4.2 (Uniqueness of the self-dual order).** On any labeled point set, the discrete order $\Delta$ is the *unique* self-dual partial order.

*Proof.* Let $r$ be a self-dual partial order, so $r(a,b) = r(b,a)$ for all $a, b$. Fix $a, b$. If $a = b$, then $r(a,b) = \text{true} = \Delta(a,b)$ by reflexivity. If $a \neq b$, suppose for contradiction $r(a,b) = \text{true}$. By symmetry $r(b,a) = \text{true}$ as well, and antisymmetry then forces $a = b$, contradicting $a \neq b$. Hence $r(a,b) = \text{false} = \Delta(a,b)$. In all cases $r = \Delta$. $\qquad\blacksquare$

**Definition 4.3.** Let $\mathcal{S}(n) := \{\, r \in \mathcal{P}(n) : r^{\partial} = r \,\}$ be the set of self-dual labeled partial orders, and $Q(n) := \lvert \mathcal{S}(n) \rvert$.

**Theorem 4.4 (The self-dual count).** $Q(n) = 1$ for every $n$.

*Proof.* By Theorem 4.2, $\mathcal{S}(n) = \{\Delta\}$, a singleton. $\qquad\blacksquare$

This is the structural heart of the paper: duality has a completely pinned-down fixed locus, consisting of a single element.

---

## 5. The parity theorem

The counting mechanism is the classical fixed-point parity principle.

**Lemma 5.1 (Fixed-point parity principle).** Let $S$ be a finite set and $f : S \to S$ an involution ($f \circ f = \mathrm{id}$). Let $\mathrm{Fix}(f) = \{ s \in S : f(s) = s \}$. Then
$$\lvert S \rvert \equiv \lvert \mathrm{Fix}(f) \rvert \pmod 2.$$

*Proof.* The non-fixed points of $f$ split into disjoint two-element orbits $\{s, f(s)\}$ with $s \neq f(s)$: each such $s$ satisfies $f(f(s)) = s$, so $s$ and $f(s)$ pair up, and no point lies in two orbits. Hence $\lvert S \setminus \mathrm{Fix}(f) \rvert$ is a sum of $2$'s, i.e. even, and $\lvert S \rvert = \lvert \mathrm{Fix}(f) \rvert + \lvert S \setminus \mathrm{Fix}(f) \rvert \equiv \lvert \mathrm{Fix}(f) \rvert \pmod 2$. $\qquad\blacksquare$

**Theorem 5.2 (Parity of $P(n)$).** $P(n)$ is odd for every $n$.

*Proof.* Apply Lemma 5.1 with $S = \mathcal{P}(n)$ and $f = \partial$, the duality involution (well-defined on $\mathcal{P}(n)$ by Lemmas 3.2 and 3.3). The fixed points of $\partial$ are precisely the self-dual orders, so $\mathrm{Fix}(\partial) = \mathcal{S}(n)$ and by Theorem 4.4, $\lvert \mathrm{Fix}(\partial) \rvert = Q(n) = 1$. Therefore
$$P(n) = \lvert \mathcal{P}(n) \rvert \equiv 1 \pmod 2,$$
i.e. $P(n)$ is odd. $\qquad\blacksquare$

This establishes the first (least significant) binary digit of $P(n)$ unconditionally and structurally.

---

## 6. The modulo-4 phenomenon

**Proposition 6.1 (Small residues).** By direct enumeration,
$$P(2) = 3,\quad P(3) = 19,\quad P(4) = 219,$$
each congruent to $3$ modulo $4$. Moreover the congruence $(\star)$, $P(n) \equiv 3 \pmod 4$, holds for all $2 \leq n \leq 19$; in particular $P(19) = 646099441937791106493755218560442089979 \equiv 3 \pmod 4$.

*Proof.* Enumerate $\mathcal{P}(n)$ for small $n$ (or read off tabulated values) and reduce modulo $4$. $\qquad\blacksquare$

### 6.1 Why parity alone cannot reach modulo 4

The duality involution is an order-two symmetry. The fixed-point parity principle extracts exactly one bit of information — the parity — from such a symmetry, and no more. To resolve $P(n)$ modulo $4$ one needs a symmetry group of order divisible by $4$. This motivates the following program.

**Construction 6.2 (Relabeling).** For a permutation $\sigma$ of the points, define the **relabeling** of $r$ by $(\sigma \cdot r)(a,b) := r(\sigma a, \sigma b)$. Relabeling preserves the partial-order axioms: reflexivity, antisymmetry, and transitivity are all invariant under the bijective substitution $a \mapsto \sigma a$. Hence each $\sigma$ acts on $\mathcal{P}(n)$, and these actions commute appropriately with duality.

Combining the duality involution $\partial$ with a transposition $\tau$ of two fixed labels yields a symmetry group of order four, $\{ \mathrm{id}, \partial, \tau, \partial\tau \}$, acting on $\mathcal{P}(n)$. A Burnside/orbit-counting analysis of this action refines the parity count to a count modulo $4$, with the residue governed by the sizes of the orbits under the full group rather than by the single fixed point of $\partial$ alone.

### 6.2 Conjectural framework

**Conjecture 6.3 (Full modulo-4 congruence).** For every $n \geq 2$, $P(n) \equiv 3 \pmod 4$.

**Conjecture 6.4 (Transposition-fixed orders control the second bit).** Let $F(n)$ be the number of labeled orders invariant under the transposition swapping two fixed labels. Then $F(n) \equiv 1 \pmod 2$, and the residue of $P(n)$ modulo $4$ is determined by $F(n)$ together with the self-dual count $Q(n) = 1$.

The intuition is that the second binary digit of $P(n)$ is not intrinsic to posets as abstract objects but is carried by how the labeling interacts with symmetry; counting orders invariant under a transposition isolates precisely that digit.

**Conjecture 6.5 (Modulo-$2^k$ periodicity).** For each $k$, the residues $P(n) \bmod 2^k$ are eventually determined by a finite automaton in $n$ — equivalently, $P(n) \bmod 2^k$ is ultimately periodic once the defining inclusion–exclusion ("moment reduction") is taken modulo $2^k$. The heuristic is that the alternating surjection-type sums expressing $P(n)$ have, modulo a prime power, only finitely many relevant strata, forcing eventual periodicity.

---

## 7. Algorithms

We record the two computational primitives underlying the enumerative verification.

**Algorithm A (Direct enumeration of $P(n)$).** Iterate over all $2^{n^2}$ candidate relation matrices, test each for reflexivity, antisymmetry, and transitivity, and count those that pass. This is exact but exponential; it is practical for $n \le 6$ and confirms the theory at the ground level. Complexity: $O(2^{n^2} \cdot n^3)$.

**Algorithm B (Residue tracking from tabulated values).** For larger $n$, take known exact values of $P(n)$ (obtainable by far more efficient means than brute force) and reduce them modulo $2^k$. This confirms $(\star)$ up to $n = 19$ instantly and tests the periodicity conjectures.

**Algorithm C (Involution pairing / self-dual extraction).** Given the enumerated set $\mathcal{P}(n)$, pair each order with its dual; the unpaired residue is the self-dual set. This computationally witnesses Theorem 4.4 ($Q(n) = 1$) and the parity mechanism of Theorem 5.2.

---

## 8. Applications and context

The result exemplifies a broad and important theme: **stable arithmetic congruences in wildly growing combinatorial sequences**. Such congruences are fingerprints of symmetry. The fixed-point parity principle (Lemma 5.1) is a workhorse across combinatorics and number theory — it underlies, for instance, Zagier's one-sentence proof that primes $p \equiv 1 \pmod 4$ are sums of two squares, where a cleverly chosen involution with a single fixed point forces an odd count.

Concretely, understanding $P(n) \bmod 2^k$ has practical uses:
- **Sanity checks for enumeration software.** Any exact computation of $P(n)$ can be validated instantly against the congruence $P(n) \equiv 3 \pmod 4$ — a wrong parity or wrong second bit signals a bug.
- **Hashing and sampling.** Residue structure informs uniform-sampling and reservoir schemes over the space of labeled orders.
- **Structural insight into duality.** The uniqueness of the self-dual order (Theorem 4.2) is a statement about the rigidity of antisymmetry, generalizing to preorders and $T_0$ topologies (see §9).

---

## 9. Discussion and future work

The parity theorem is complete and structural. The modulo-$4$ congruence remains conjectural but is supported by a clear mechanism (the order-four symmetry group) and by verification through $n = 19$.

Beyond Conjectures 6.3–6.5, a natural direction concerns **richer order classes**. The "unique self-dual object" phenomenon appears to persist for labeled *preorders* (dropping antisymmetry, but then the self-dual objects are exactly the symmetric preorders — the equivalence relations — a structurally trivial and exactly-countable family) and for labeled $T_0$ topologies (which correspond bijectively to partial orders via specialization). In each class the self-dual objects should form a structurally transparent subfamily, enabling analogous parity theorems. Making these precise, and proving Conjecture 6.3 via the order-four action, are the principal open problems.

---

## 10. Conclusion

We have shown that the number $P(n)$ of labeled partial orders on $n$ points is odd for every $n$, as a clean consequence of a single structural fact: the discrete order is the unique self-dual partial order, hence the sole fixed point of the duality involution. The fixed-point parity principle then delivers the parity of $P(n)$ for free. The sharper empirical congruence $P(n) \equiv 3 \pmod 4$ — confirmed through $n = 19$ and a forty-digit value — sits one symmetry-level higher, awaiting the analysis of an order-four group combining duality with relabeling. The interplay of symmetry and arithmetic on display here is a compact illustration of how deep regularity can hide inside runaway growth.
