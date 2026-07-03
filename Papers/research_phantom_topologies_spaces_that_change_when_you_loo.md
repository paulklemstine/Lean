# The Phantom Number Collapse: Why No Space Ever Needs Three Observers

## Abstract

We develop *phantom topology*, a framework in which the topology of a set is not
absolute but is reconstructed from a family of "observer" topologies. Given a set
$X$ and an index set $\iota$ of observers, a **phantom topology** is a family
$T \colon \iota \to \mathrm{Top}(X)$ assigning to each observer a topology on $X$.
The **consensus** (real) topology is the collection of sets open in *every*
observer's topology; in the complete lattice of topologies on $X$ it is precisely
the supremum $\bigsqcup_i T_i$. A representation is **genuine** when each observer
is *strictly finer* than the consensus. The **phantom number** of a topology is
the least number of observers in a genuine representation of it.

We prove two main results. First, a purely lattice-theoretic **Collapse
Principle**: in any complete lattice, if an element $\tau$ is the join of finitely
many elements each strictly below $\tau$, then $\tau$ is already the join of just
two elements strictly below it. Second, its topological consequence: **no
topology — metrizable or not — ever requires three or more observers.** The
phantom number is a *two-valued invariant*: for any space it is either exactly
$2$ (the space is reconstructible) or no finite genuine representation exists (the
space is join-irreducible). This refutes, in complete generality, the natural
conjecture that non-metrizable spaces demand three or more observers. As a
calibrating instance we show the phantom number of the Euclidean line is exactly
$2$, realized by the lower-limit and upper-limit topologies, and that every one of
its genuine finite representations collapses onto a two-observer pair.

**Keywords:** phantom topology, consensus topology, complete lattice, join,
join-irreducibility, lattice of topologies, lower-limit topology, Sorgenfrey line,
strong induction.

---

## 1. Introduction

The topology of a space is usually treated as an objective given: a fixed
collection of open sets encoding nearness, continuity, and convergence. This
paper explores a deliberately unorthodox alternative in which topology is
**observer-dependent**, and the objective topology emerges only as the *agreement*
of many observers.

The motivating picture is physical: different observers, equipped with different
measuring apparatus, resolve different features of the same underlying set of
points. The "real" world is what they can all agree on. Formalizing this yields a
clean mathematical object — the consensus of a family of topologies — and a
natural quantitative invariant: how many genuinely distinct observers are needed
to reconstruct a given space?

An appealing conjecture guided the initial investigation: that *tame* (metrizable)
spaces might be reconstructible from two observers, while *wild* (non-metrizable)
spaces should require three or more. Intuitively, stranger spaces ought to need
more points of view. We show this intuition is not merely occasionally wrong but
**universally** wrong, and we isolate the exact structural reason: a
lattice-theoretic collapse principle that has nothing to do with topology at all.

### Contributions

- A rigorous framework for phantom topologies, consensus topologies, genuine
  representations, and the phantom number (§3).
- The **Collapse Principle** for complete lattices (§4, Theorem 4.1), proved by
  strong induction on the size of the index set with a genuine descent argument
  and non-trivial base case.
- The topological corollary that **no space requires three observers** and the
  resulting **two-valued dichotomy** for the phantom number (§5).
- The exact determination of the phantom number of the Euclidean line as $2$,
  with the collapse of all its genuine finite representations (§6).
- Algorithms, numerical demonstrations, and a discussion of the reconstruction
  dichotomy and observer spectrum (§7–§9).

---

## 2. Preliminaries: the lattice of topologies

Fix a set $X$. The set $\mathrm{Top}(X)$ of all topologies on $X$ is a **complete
lattice** under the *refinement order*. We adopt the convention that a topology
$t$ is **finer** than a topology $s$ — written $t \le s$ — when every set open in
$s$ is also open in $t$; that is, finer topologies have *more* open sets and lie
*lower* in the order. (This is the standard lattice convention: the discrete
topology, with all sets open, is the bottom; the indiscrete topology is the top.)

In this lattice:

- The **supremum** $\bigsqcup_{i} t_i$ of a family of topologies is the *coarsest*
  topology finer than none of them beyond necessity — concretely, its open sets
  are exactly the sets that are open in **every** $t_i$. (Equivalently, it is the
  intersection of the open-set collections.)
- The **infimum** is the topology *generated* by the union of the open-set
  collections.
- Writing $a \vee b$ for the binary supremum, a set is $a \vee b$-open iff it is
  both $a$-open and $b$-open.

The single fact we use repeatedly is:

> **Fact 2.1 (Consensus = supremum).** A set $U$ is open in $\bigsqcup_i t_i$ if
> and only if $U$ is open in $t_i$ for every $i$.

---

## 3. The phantom-topology framework

**Definition 3.1 (Phantom topology).** Let $X$ be a set and $\iota$ an index set
of *observers*. A **phantom topology** on $X$ is a family
$$T \colon \iota \to \mathrm{Top}(X), \qquad i \mapsto T_i,$$
assigning to each observer $i$ a topology $T_i$ on $X$.

**Definition 3.2 (Consensus topology).** The **consensus** of a phantom topology
$T$ is
$$\mathrm{consensus}(T) \;=\; \bigsqcup_{i \in \iota} T_i,$$
the supremum in $\mathrm{Top}(X)$. By Fact 2.1, a set $U$ is consensus-open iff it
is open in *every* observer's topology. We regard the consensus as the "real"
topology of $X$: reality is what all observers agree is open.

**Observation 3.3 (Measurement coarsens).** For every observer $i$ we have
$T_i \le \mathrm{consensus}(T)$: each individual observer is *finer* than the
consensus. Adding observers can only *coarsen* the agreed topology, never refine
it. This is precisely the property $t_i \le \bigsqcup_j t_j$ of a supremum, read
through the refinement order.

**Definition 3.4 (Genuine representation).** A phantom topology $T$ with consensus
$\tau = \mathrm{consensus}(T)$ is a **genuine representation** of $\tau$ if every
observer is *strictly* finer than the consensus:
$$T_i < \tau \quad \text{for all } i.$$
Strictness excludes the degenerate case where some observer already *is* reality;
in a genuine representation, every observer resolves phantom structure that
reality does not.

**Definition 3.5 (Phantom number).** The **phantom number** of a topology $\tau$
on $X$ is the least cardinality $k$ of an index set admitting a genuine
representation $T \colon \{1,\dots,k\} \to \mathrm{Top}(X)$ with
$\mathrm{consensus}(T) = \tau$, if such a finite representation exists; otherwise
the phantom number is declared *infinite/unattainable*.

Note that a single-observer consensus is that observer itself
($\bigsqcup_{i \in \{*\}} T_i = T_*$), so a genuine *one*-observer representation
is impossible: it would require $T_* < \tau$ and $T_* = \tau$ simultaneously.
Thus the phantom number, when finite, is at least $2$.

---

## 4. The Collapse Principle

The heart of the paper is a statement about arbitrary complete lattices; topology
enters only afterward.

**Theorem 4.1 (Collapse Principle).** *Let $L$ be a complete lattice and
$\tau \in L$. Let $s$ be a finite index set with $|s| \ge 2$ and let
$f \colon s \to L$ satisfy*
$$\bigsqcup_{i \in s} f_i = \tau \qquad\text{and}\qquad f_i < \tau \text{ for all } i \in s.$$
*Then there exist $b, c \in L$ with $b < \tau$, $c < \tau$, and $b \vee c = \tau$.*

In words: if $\tau$ is the join of a finite family of elements each strictly below
it, then $\tau$ is already the join of just **two** elements strictly below it.

**Proof.** We argue by strong induction on $|s|$.

Since $|s| \ge 2$, choose an index $j \in s$ and set
$$c \;=\; \bigsqcup_{i \in s \setminus \{j\}} f_i.$$
Splitting off the index $j$ from the join gives
$$f_j \vee c \;=\; \bigsqcup_{i \in s} f_i \;=\; \tau. \tag{$\ast$}$$
From $(\ast)$ we have $c \le \tau$. Two cases arise.

*Case 1: $c < \tau$.* Then $b = f_j$ and $c$ are the required elements:
$f_j < \tau$ by hypothesis, $c < \tau$ by assumption, and $f_j \vee c = \tau$ by
$(\ast)$. Done.

*Case 2: $c = \tau$.* Then over the strictly smaller index set $s \setminus \{j\}$
we again have $\bigsqcup_{i \in s\setminus\{j\}} f_i = \tau$ with every
$f_i < \tau$. If $|s \setminus \{j\}| \ge 2$, the induction hypothesis applies and
yields $b, c$ directly. If instead $|s \setminus \{j\}| = 1$, say
$s \setminus \{j\} = \{k\}$, then $\bigsqcup_{i \in \{k\}} f_i = f_k = \tau$,
contradicting $f_k < \tau$. This case is therefore impossible.

The recursion strictly decreases $|s|$ and cannot bottom out at a singleton, so it
terminates in Case 1, producing the desired two elements. $\qquad\blacksquare$

**Remark 4.2.** The proof is a genuine descent, not a definitional
manipulation. The load-bearing steps are (i) splitting one index off a finite
join, (ii) the trichotomy $c < \tau$ versus $c = \tau$ under $c \le \tau$, and
(iii) the base-case contradiction that a *single* strict element cannot join to
$\tau$. The last point is what forbids the phantom number from ever being $1$ and
simultaneously what forces the descent to halt at exactly $2$.

**Corollary 4.3 (Two-fold join.)** For a two-element family $g \colon \{0,1\} \to
L$, $\bigsqcup_i g_i = g_0 \vee g_1$. Thus the pair produced by Theorem 4.1 is
literally a two-observer consensus.

---

## 5. No space requires three observers

We now transport the Collapse Principle to $L = \mathrm{Top}(X)$.

**Theorem 5.1 (Collapse to two observers).** *Let $\tau$ be a topology on $X$ and
suppose $T \colon \{1,\dots,k\} \to \mathrm{Top}(X)$ is a genuine $k$-observer
representation of $\tau$ with $k \ge 2$: that is, $\mathrm{consensus}(T) = \tau$
and $T_i < \tau$ for all $i$. Then there is a genuine two-observer representation
$S \colon \{0,1\} \to \mathrm{Top}(X)$ with $\mathrm{consensus}(S) = \tau$ and
$S_i < \tau$ for both $i$.*

**Proof.** Apply Theorem 4.1 in the complete lattice $\mathrm{Top}(X)$ with the
finite family $T$ over the index set $\{1,\dots,k\}$: the hypotheses
$\bigsqcup_i T_i = \tau$ and $T_i < \tau$ hold by assumption. This yields topologies
$b, c < \tau$ with $b \vee c = \tau$. Define $S_0 = b$, $S_1 = c$. By Corollary 4.3,
$\mathrm{consensus}(S) = S_0 \vee S_1 = \tau$, and each $S_i < \tau$. $\blacksquare$

**Theorem 5.2 (No topology requires three).** *No topology requires three or more
observers: if a topology $\tau$ admits any genuine finite representation (with at
least two observers), then it admits a genuine two-observer representation. Its
phantom number, whenever finite, is exactly $2$.*

**Proof.** Immediate from Theorem 5.1: any genuine finite representation has
$k \ge 2$ observers (a genuine one-observer representation is impossible, §3), and
Theorem 5.1 collapses it to two. Since two observers are also necessary (§3), the
phantom number equals $2$. $\blacksquare$

**Theorem 5.3 (Two-valued dichotomy).** *For every topology $\tau$ on a set $X$,
exactly one of the following holds:*

1. *$\tau$ is **reducible**: $\tau = b \vee c$ for some topologies $b, c < \tau$.
   Then $\tau$ has a genuine two-observer representation and its phantom number is
   exactly $2$.*
2. *$\tau$ is **join-irreducible**: $\tau$ cannot be written as $b \vee c$ with
   $b, c < \tau$. Then $\tau$ admits no genuine finite representation at all, and
   its phantom number is infinite/unattainable.*

**Proof.** These are complementary by definition of join-irreducibility. In case
(1), the pair $(b,c)$ is itself a genuine two-observer representation. In case (2),
any genuine finite representation would, by Theorem 5.1, produce a factorization
$\tau = b \vee c$ with $b,c < \tau$, contradicting irreducibility. $\blacksquare$

Theorem 5.3 is the decisive refutation of the original conjecture. Non-metrizability
is irrelevant. Whether a space needs "many observers" is governed by a single
algebraic property of its open-set lattice — reducibility — and the finite part of
the phantom spectrum is always empty or exactly $\{2\}$. The indiscrete two-point
space, a non-metrizable space, is reducible and has phantom number $2$; the
conjecture's premise fails there and, by Theorem 5.3, cannot be salvaged for any
class of spaces.

---

## 6. The Euclidean line has phantom number two

We calibrate the theory on $X = \mathbb{R}$.

**Definition 6.1 (Left- and right-looking observers).**

- The **lower-limit** (right-looking) topology $\mathsf{L}$ on $\mathbb{R}$ is
  generated by the right half-open intervals $[x, b)$. A point is pinned from the
  right.
- The **upper-limit** (left-looking) topology $\mathsf{U}$ on $\mathbb{R}$ is
  generated by the left half-open intervals $(a, x]$. A point is pinned from the
  left.

**Lemma 6.2 (Strictness).** Both $\mathsf{L}$ and $\mathsf{U}$ are strictly finer
than the Euclidean topology $\mathcal{E}$ on $\mathbb{R}$: $\mathsf{L} < \mathcal{E}$
and $\mathsf{U} < \mathcal{E}$.

**Proof.** Each is finer because it contains all Euclidean opens (an open interval
$(a,b) = \bigcup_{x \in (a,b)} [x, b)$ is $\mathsf{L}$-open, etc.). Each is
*strictly* finer via an explicit phantom witness: $[0,1)$ is $\mathsf{L}$-open but
not Euclidean-open (no two-sided neighborhood of $0$ fits inside $[0,1)$), and
symmetrically $(0,1]$ is $\mathsf{U}$-open but not Euclidean-open. $\blacksquare$

**Theorem 6.3 (Two-observer theorem for $\mathbb{R}$).** The Euclidean topology on
$\mathbb{R}$ is the consensus of the lower-limit and upper-limit observers:
$$\mathcal{E} \;=\; \mathsf{L} \vee \mathsf{U}.$$

**Proof.** *($\mathcal{E} \le \mathsf{L}\vee\mathsf{U}$, i.e. consensus is at least
as coarse.)* Every Euclidean-open set is open to each observer (Lemma 6.2), hence
open in both, hence consensus-open.

*(Consensus $\subseteq$ Euclidean.)* Suppose $U$ is open to both observers and let
$x \in U$. Openness for the left-looking observer gives $a < x$ with
$(a, x] \subseteq U$; openness for the right-looking observer gives $b > x$ with
$[x, b) \subseteq U$. Then
$$(a, b) = (a, x] \cup [x, b) \subseteq U,$$
so $U$ contains a two-sided open interval around $x$. As $x \in U$ was arbitrary,
$U$ is Euclidean-open. The two inclusions give $\mathcal{E} = \mathsf{L} \vee
\mathsf{U}$. $\blacksquare$

**Theorem 6.4 (Phantom number of $\mathbb{R}$).** The phantom number of the
Euclidean line is exactly $2$. Moreover every genuine finite representation of
$\mathcal{E}$ collapses onto a two-observer pair.

**Proof.** By Theorem 6.3 and Lemma 6.2, $(\mathsf{L}, \mathsf{U})$ is a genuine
two-observer representation, so the phantom number is at most $2$; it is at least
$2$ since no genuine one-observer representation exists (§3); hence it equals $2$.
The collapse of every genuine finite representation is Theorem 5.1 applied to
$\tau = \mathcal{E}$. $\blacksquare$

---

## 7. Algorithms

We record the algorithmic content implicit in the proofs. Throughout, a topology on
a *finite* set is represented by its family of open sets (a collection of subsets
containing $\varnothing$ and the whole set and closed under unions and
intersections).

### 7.1 Consensus of a family (intersection of open-set collections)

Given observer topologies $t_1, \dots, t_k$ as collections of open sets, the
consensus is the intersection $\bigcap_i \mathcal{O}(t_i)$ of their open-set
collections. Complexity: $O(k \cdot m)$ set-membership checks where $m$ is the size
of the largest collection.

### 7.2 Collapse: from $k$ genuine observers to $2$

This is the constructive engine of Theorem 4.1. Given a genuine family
$f_1, \dots, f_k$ ($k \ge 2$) with join $\tau$ and each $f_i < \tau$, produce a
genuine pair $(b, c)$:

```
peel index j; c := join of the remaining f_i
if c < tau:      return (f_j, c)
else (c = tau):  recurse on the remaining family (size k-1)
```

The recursion strictly shrinks the family and cannot terminate at size $1$; it
therefore returns a valid pair after at most $k-1$ steps. Complexity: $O(k)$
join computations.

### 7.3 Reducibility test

To decide the dichotomy of Theorem 5.3 for a finite topology $\tau$: search for a
pair $(b, c)$ of topologies with $b, c < \tau$ and $b \vee c = \tau$. On a finite
set this is a finite search over sub-collections; a positive answer certifies
reducibility (phantom number $2$), a negative answer certifies
join-irreducibility.

---

## 8. Applications and interpretation

The framework provides a rigorous toy model for three ideas often stated only
informally:

- **Measurement coarsens.** Observation 3.3 makes precise the slogan that the
  shared, objective world is *coarser* than any single sharpened perspective:
  consensus is a supremum, and every observer lies below it.
- **Reality is a two-fold agreement.** Theorem 5.2 says the coarsening is always
  the meet of exactly two sharper views whenever it is finitely achievable —
  there is no genuine need for a larger committee.
- **Rigidity of reconstruction.** Theorem 5.3 replaces a spectrum of possible
  "observer counts" with a stark binary determined by a single lattice property,
  a striking instance of a geometric-sounding question reducing to pure
  order theory.

The Euclidean line (Theorem 6.4) shows the model is non-vacuous and produces the
"expected" answer on the most familiar space, while the indiscrete space shows the
same answer persists into the non-metrizable world, exactly where the original
conjecture predicted it would fail.

---

## 9. Discussion and future directions

The results here settle the *finite* half of the phantom-number question
completely: the finite spectrum of every space is empty or $\{2\}$. Three
directions extend the program.

**The reconstruction dichotomy.** A space is genuinely reconstructible from
finitely many strictly-sharper observers if and only if its open-set lattice is
*reducible* — reality sits strictly above the join of two things strictly below
it. Spaces whose open-set structure is *irreducible* (for instance, the cofinite
topology on an infinite set) can never be reconstructed from any finite number of
genuinely sharper observers. The task is a clean lattice-factorization
characterization.

**The observer spectrum.** Beyond the finite regime, one expects the set of
observer-counts admitting a genuine reconstruction to take one of exactly three
shapes: empty; the value $2$ together with every infinite cardinal up to the
space's weight; or a predictable interval fixed by that weight. The finite part is
always empty or $\{2\}$; the infinite part should be governed by the classical
weight invariant, with the real line supplying rich infinite reconstructions to
calibrate against.

**Duality of agreement and refinement.** Pairing the consensus (coarsest
agreement, a supremum) with its dual (the finest common refinement, an infimum)
should yield a Galois connection whose fixed points isolate the most well-behaved,
distributive spaces, stabilizing after a single round as an idempotent closure.
"Measurement coarsens" and "measurement sharpens" would then be two halves of one
adjunction.

---

## 10. Conclusion

Phantom topology recasts a space as the consensus of many sharper observers. The
central discovery is a rigidity law: whenever a space can be genuinely
reconstructed from finitely many strictly-sharper observers at all, exactly two
always suffice, and no space genuinely needs three. This follows from a
lattice-theoretic Collapse Principle valid in any complete lattice, and it
refutes — in full generality, not by isolated counterexample — the conjecture
that non-metrizable spaces demand more observers. The phantom number is a
two-valued invariant, pinned by a single algebraic property of the open-set
lattice; for the Euclidean line it is exactly two, realized stereoscopically by a
left-looking and a right-looking observer.
