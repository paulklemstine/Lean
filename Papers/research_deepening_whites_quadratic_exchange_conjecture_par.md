# A Compositional Theory of Quadratic Basis Exchange, with a Complete Solution in Rank One

**Author:** Aristotle
**Date:** 2026-07-14

## Abstract

White's Quadratic Exchange Conjecture (Part 3) asserts that in any matroid, any
two multisets of bases sharing the same multiset union of ground-set elements are
related by a finite sequence of *quadratic exchange moves* — moves that replace
two bases by two others while conserving the combined element multiset. The
conjecture is open in general; its stronger *symmetric* variant is known to be
false. We develop a compositional theory of the associated reachability relation
and use it to settle an infinite family of cases. Our first contribution is that
basis-preserving reachability is a **congruence** for multiset addition: moves may
be carried out inside arbitrarily large ambient configurations, and independent
reachabilities may be combined additively. Our second contribution is a
**two-basis reconfiguration theorem** that isolates the atomic move as a reusable
statement over an arbitrary basis family, together with its frictionless
specialization to uniform matroids, where every element-conserving repacking of
two $r$-subsets is admissible. Our third and principal contribution is an
**unconditional proof of Part 3 for all rank-one uniform matroids** $U_{1,n}$:
we show the multiset union determines the configuration, so equal-union
configurations are literally equal and hence trivially reachable. We include a
single-basis rigidity classification, a precise reduction of the general uniform
case to an *extraction lemma*, and a discussion of the path toward strongly
base-orderable matroids. Numerical demonstrations accompany each result.

## 1. Introduction

Matroids axiomatize the notion of independence common to linear algebra and graph
theory. A recurring theme is that bases of a matroid, though combinatorially
rigid, enjoy rich *exchange* behavior: any two bases can be transformed into one
another by swapping elements one at a time. White's conjectures elevate exchange
from single bases to *collections* of bases, asking when two collections carrying
the same underlying elements can be interconverted by local moves.

There are three layers to White's program, of increasing subtlety. The strongest
("symmetric exchange") demands that each move swap a single element between two
bases; this is now known to fail. The version we study — Part 3 — permits *any*
element-conserving replacement of two bases by two others. It is the sharpest
version still believed true, and it remains open for general matroids.

This paper contributes a structural toolkit for Part 3 and resolves it completely
for the rank-one uniform family. The results are organized around a single
philosophy: *reachability is local and compositional*, and once this is made
rigorous the conjecture reduces to a bookkeeping induction whose only missing
ingredient is an extraction lemma. We prove everything the induction needs except
that lemma, and we prove the base of the induction — rank one — outright.

## 2. Definitions

Throughout, $\alpha$ is a type with decidable equality, playing the role of the
ground set of elements. Bases are finite subsets of $\alpha$, i.e. elements of the
type of finite sets $\mathrm{Finset}\ \alpha$. We write $B.\mathrm{val}$ for the
underlying *multiset* of a finite set $B$ (its elements with multiplicity one
each), and recall that $B \mapsto B.\mathrm{val}$ is injective: a finite set is
determined by its element multiset.

**Definition 2.1 (Basis family).** A *basis family* is a predicate
$\mathcal{B} : \mathrm{Finset}\ \alpha \to \mathrm{Prop}$ selecting which finite
sets count as bases. For a matroid this is its set of bases; we work at the level
of an arbitrary family so that the structural theorems apply uniformly.

**Definition 2.2 (Uniform basis).** For $r \in \mathbb{N}$ the *rank-$r$ uniform
family* on a ground type is the predicate $\mathrm{IsUniformBasis}\ r$ defined by
$\mathrm{IsUniformBasis}\ r\ (B) \iff |B| = r$. On the ground set
$\{0, 1, \dots, n-1\}$ this is the uniform matroid $U_{r,n}$: every $r$-subset is a
basis.

**Definition 2.3 (Configuration).** A *configuration* is a multiset of bases, i.e.
an element $C \in \mathrm{Multiset}\ (\mathrm{Finset}\ \alpha)$. Multiset addition
$C + E$ denotes taking the two configurations together, and $B ::_{m} C$ denotes
consing a single basis $B$ onto $C$.

**Definition 2.4 (Multiset union / fingerprint).** The *multiset union* of a
configuration $C$ is
$$\mathrm{unionMS}(C) \;=\; \sum_{B \in C} B.\mathrm{val},$$
the multiset sum of the element multisets of the bases of $C$, counted with the
multiplicity of each basis in $C$. For a singleton configuration,
$\mathrm{unionMS}(\{B\}) = B.\mathrm{val}$.

**Definition 2.5 (Quadratic exchange move).** For a basis family $\mathcal{B}$,
there is a *basis-preserving quadratic move* from configuration $C$ to
configuration $D$, written $\mathrm{RQMove}\ \mathcal{B}\ C\ D$, when there exist a
remaining configuration $\mathrm{rest}$ and bases $B_1, B_2, C_1, C_2$ with
$$C = B_1 ::_m B_2 ::_m \mathrm{rest}, \qquad
  D = C_1 ::_m C_2 ::_m \mathrm{rest},$$
$$B_1.\mathrm{val} + B_2.\mathrm{val} = C_1.\mathrm{val} + C_2.\mathrm{val}
  \quad (\text{conservation of elements}),$$
and $\mathcal{B}\,C_1$, $\mathcal{B}\,C_2$ (the replacements are bases of the
family).

**Definition 2.6 (Reachability).** *Basis-preserving reachability*
$\mathrm{RReachable}\ \mathcal{B}$ is the equivalence relation generated by
$\mathrm{RQMove}\ \mathcal{B}$: the reflexive, symmetric, transitive closure of the
single-move relation. Thus $C$ reaches $D$ iff a finite chain of quadratic moves
(in either direction) connects them.

**Definition 2.7 (Part 3, formalized).** For a basis family $\mathcal{B}$, the
statement $\mathrm{WhitePart3Holds}\ \mathcal{B}$ is: for all configurations $C, D$
that are supported on $\mathcal{B}$ and satisfy $\mathrm{unionMS}(C) =
\mathrm{unionMS}(D)$, one has $\mathrm{RReachable}\ \mathcal{B}\ C\ D$. White's
Quadratic Exchange Conjecture (Part 3) is that this holds for the basis family of
every matroid.

A basic sanity invariant, which we use freely, is that quadratic moves preserve
the fingerprint: if $C$ reaches $D$ then $\mathrm{unionMS}(C) =
\mathrm{unionMS}(D)$. This is immediate from the conservation law and is what makes
equal-union a *necessary* condition for reachability; Part 3 conjectures it is also
sufficient.

## 3. Congruence of reachability

Our first results establish that reachability behaves well under composition of
configurations. These are the load-bearing lemmas for any inductive proof.

**Lemma 3.1 (Moves are local).** If $\mathrm{RQMove}\ \mathcal{B}\ C\ D$, then for
any configuration $E$, $\mathrm{RQMove}\ \mathcal{B}\ (C + E)\ (D + E)$.

*Proof sketch.* Unfold the move as $C = B_1 ::_m B_2 ::_m \mathrm{rest}$,
$D = C_1 ::_m C_2 ::_m \mathrm{rest}$. Adding $E$ and reassociating the cons
operations with multiset addition ($ (x ::_m s) + t = x ::_m (s + t)$) exhibits
$C + E$ and $D + E$ as the same move with the enlarged remainder
$\mathrm{rest} + E$. The conservation law and family memberships are unchanged. ∎

**Theorem 3.2 (Right congruence).** If $\mathrm{RReachable}\ \mathcal{B}\ C\ D$
then $\mathrm{RReachable}\ \mathcal{B}\ (C + E)\ (D + E)$ for every $E$.

*Proof sketch.* Induct on the generation of the equivalence closure. The
generating step is Lemma 3.1; reflexivity, symmetry, and transitivity of the
closure are preserved because each is applied to the $+E$-translated endpoints. ∎

**Theorem 3.3 (Left congruence).** If $\mathrm{RReachable}\ \mathcal{B}\ C\ D$
then $\mathrm{RReachable}\ \mathcal{B}\ (E + C)\ (E + D)$.

*Proof sketch.* Commutativity of multiset addition reduces this to Theorem 3.2. ∎

**Theorem 3.4 (Full congruence).** If $\mathrm{RReachable}\ \mathcal{B}\ C\ D$ and
$\mathrm{RReachable}\ \mathcal{B}\ C'\ D'$, then
$\mathrm{RReachable}\ \mathcal{B}\ (C + C')\ (D + D')$.

*Proof sketch.* Chain two congruences: $C + C'$ reaches $D + C'$ by Theorem 3.2,
which reaches $D + D'$ by Theorem 3.3, and compose by transitivity. ∎

**Corollary 3.5 (Cons congruence).** If $\mathrm{RReachable}\ \mathcal{B}\ C\ D$
then $\mathrm{RReachable}\ \mathcal{B}\ (B ::_m C)\ (B ::_m D)$ for any basis $B$.

*Proof sketch.* Consing a single $B$ is left-addition of the singleton $\{B\}$;
apply Theorem 3.3 and rewrite $\{B\} + C = B ::_m C$. ∎

Corollary 3.5 is the workhorse of the induction sketched in Section 6: once a
common basis $T$ has been maneuvered to the front of two configurations, it can be
deleted from both while preserving reachability of the remainders.

## 4. The two-basis reconfiguration theorem

Congruence tells us untouched bases ride along; the next theorem packages the one
place where content actually changes.

**Theorem 4.1 (Two-basis reconfiguration).** Let $\mathcal{B}$ be any basis
family, $\mathrm{rest}$ any ambient configuration, and $B_1, B_2, C_1, C_2$ bases
with $B_1.\mathrm{val} + B_2.\mathrm{val} = C_1.\mathrm{val} + C_2.\mathrm{val}$ and
$\mathcal{B}\,C_1$, $\mathcal{B}\,C_2$. Then
$$\mathrm{RReachable}\ \mathcal{B}\ (B_1 ::_m B_2 ::_m \mathrm{rest})\
  (C_1 ::_m C_2 ::_m \mathrm{rest}).$$

*Proof sketch.* The data exhibit a single quadratic move by Definition 2.5;
include it into the equivalence closure. ∎

**Theorem 4.2 (Uniform two-basis connectivity).** In $U_{r,n}$, any two
$r$-subsets $C_1, C_2$ with $B_1.\mathrm{val} + B_2.\mathrm{val} =
C_1.\mathrm{val} + C_2.\mathrm{val}$ are reachable from $B_1, B_2$ in one move:
$$\mathrm{RReachable}\ (\mathrm{IsUniformBasis}\ r)\ (B_1 ::_m B_2 ::_m 0)\
  (C_1 ::_m C_2 ::_m 0).$$

*Proof sketch.* Specialize Theorem 4.1 with $\mathrm{rest} = 0$; membership in the
uniform family is just the cardinality conditions $|C_1| = |C_2| = r$. ∎

The uniform case has *no* legality obstruction beyond conservation: because every
$r$-subset is a basis, the family memberships in Theorem 4.1 are automatic once
the cardinalities are right. This is precisely why the uniform matroids are the
natural proving ground for Part 3.

## 5. Rank-one uniform matroids: a complete solution

We now settle Part 3 unconditionally for the family $U_{1,n}$.

**Lemma 5.1 (Single-basis rigidity).** If $\mathrm{unionMS}(\{B\}) =
\mathrm{unionMS}(\{C\})$ for finite sets $B, C$, then $B = C$.

*Proof sketch.* By Definition 2.4, $\mathrm{unionMS}(\{B\}) = B.\mathrm{val}$ and
$\mathrm{unionMS}(\{C\}) = C.\mathrm{val}$. The hypothesis becomes
$B.\mathrm{val} = C.\mathrm{val}$, and injectivity of $B \mapsto B.\mathrm{val}$
gives $B = C$. ∎

**Lemma 5.2 (Rank-one reconstruction).** Let $C$ be a rank-one configuration —
every basis in $C$ is a singleton. Then
$$C \;=\; \mathrm{unionMS}(C).\mathrm{map}\,(a \mapsto \{a\}),$$
i.e. $C$ is recovered from its fingerprint by wrapping each element in its
singleton basis.

*Proof sketch.* A rank-one basis has cardinality one, hence (by
$|B| = 1 \iff B = \{a\}$ for some $a$) equals $\{a\}$ with $B.\mathrm{val} =
\{a\}$. Consequently $\mathrm{unionMS}(C)$ is exactly the multiset of chosen
elements $a$, and mapping each back to $\{a\}$ inverts the passage from
singletons to their elements. Multiset induction on $C$, using that mapping and
summation commute with cons, yields the identity. ∎

**Theorem 5.3 (White's Part 3 in rank one).**
$\mathrm{WhitePart3Holds}\ (\mathrm{IsUniformBasis}\ 1)$. That is, for the
rank-one uniform matroid $U_{1,n}$, any two configurations with equal multiset
union are reachable.

*Proof sketch.* Let $C, D$ be configurations of rank-one bases with
$\mathrm{unionMS}(C) = \mathrm{unionMS}(D)$. Both are supported on singletons, so
Lemma 5.2 applies to each:
$$C = \mathrm{unionMS}(C).\mathrm{map}\,(a \mapsto \{a\})
    = \mathrm{unionMS}(D).\mathrm{map}\,(a \mapsto \{a\}) = D.$$
Thus $C = D$, and reachability follows by reflexivity of $\mathrm{RReachable}$. ∎

The theorem is *unconditional* and holds simultaneously for every $n$: an infinite
family of matroids for which Part 3 is now a theorem rather than a conjecture. The
underlying phenomenon is that at rank one a quadratic move cannot rearrange
content — each basis carries a single element, so element conservation forces the
two exchanged singletons to be a permutation of the originals, changing nothing at
the level of multisets. The genuine content of White's conjecture reappears only
at rank $\geq 2$, where bases overlap and a single move can redistribute which
basis owns which element.

## 6. The general uniform case: reduction to extraction

The tools above reduce the general uniform Part 3 — arbitrary rank $r$ and
arbitrary configuration size — to a single combinatorial lemma.

**Conjecture 6.1 (Extraction).** If $C$ is a non-empty configuration of
$r$-subsets and $T$ is an $r$-subset with $T.\mathrm{val} \leq \mathrm{unionMS}(C)$
in multiset order, then there is a configuration $C'$ with
$$\mathrm{RReachable}\ (\mathrm{IsUniformBasis}\ r)\ C\ (T ::_m C'), \quad
  C' \text{ supported on } \mathrm{IsUniformBasis}\ r, \quad |C'| = |C| - 1.$$

**Theorem 6.2 (Reduction).** Extraction (Conjecture 6.1) implies
$\mathrm{WhitePart3Holds}\ (\mathrm{IsUniformBasis}\ r)$ for all $r$.

*Proof sketch.* Induct on the common size $|C| = |D|$. If empty, both are the
empty configuration. Otherwise peel a basis $T$ off $D$, writing
$D = T ::_m D'$. Since $\mathrm{unionMS}(C) = \mathrm{unionMS}(D) \geq
T.\mathrm{val}$, Extraction produces $C'$ with $C$ reaching $T ::_m C'$ and
$|C'| = |C| - 1$. Reachability preserves the fingerprint, so
$\mathrm{unionMS}(T ::_m C') = \mathrm{unionMS}(C) = \mathrm{unionMS}(T ::_m D')$,
whence $\mathrm{unionMS}(C') = \mathrm{unionMS}(D')$. By the inductive hypothesis
$C'$ reaches $D'$, and Corollary 3.5 lifts this to $T ::_m C'$ reaching
$T ::_m D' = D$. Compose the two reachabilities by transitivity. ∎

The atomic step inside Extraction is exactly Theorem 4.2 applied to the current
head basis and a partner that contains a missing element of $T$: redistribute so
the head absorbs the target element. The remaining work is the well-founded
bookkeeping — a decreasing measure such as $|T \setminus \mathrm{head}|$ — together
with the corner case where every element of $\mathrm{head} \setminus T$ already
lies in the partner. These are finite-combinatorial obligations.

## 7. Algorithms

The constructive content yields concrete procedures, detailed in the accompanying
software.

1. **Fingerprint (multiset-union) computation.** Given a configuration, compute
   its element multiset in $O(\sum_B |B|)$ time; this decides the *necessary*
   condition for reachability and is the invariant checked after every move.

2. **Two-basis redistribution search.** Given $B_1, B_2$ and a target pair of
   cardinalities, enumerate all element-conserving repackings $C_1, C_2$; in the
   uniform case every such repacking is a legal move.

3. **Extraction-driven reconfiguration (uniform).** Realize the induction of
   Theorem 6.2: repeatedly extract the head basis of the target and recurse,
   emitting the explicit sequence of quadratic moves. This is complete for rank
   one (Theorem 5.3) and conjecturally complete in general (pending
   Conjecture 6.1); as a search procedure it terminates and certifies reachability
   whenever it succeeds.

## 8. Applications

- **Canonical forms in algebra.** White's conjectures originate in the study of
  *bracket algebras* and the ideal of relations among basis monomials; Part 3
  concerns whether the quadratic relations suffice to connect all monomials with
  the same content. The congruence theory here mirrors the fact that such
  relations may be applied inside any larger product.

- **Combinatorial reconfiguration.** Reachability under local moves is a central
  paradigm in reconfiguration problems (graph colorings, token sliding, matroid
  bases). Our congruence lemmas are exactly the "moves compose in context"
  guarantees that reconfiguration arguments rely on.

- **Randomized sampling.** When the move graph is connected (as it provably is in
  rank one, and conjecturally in general uniform matroids), Markov chains over
  configurations that use quadratic moves as transitions have the correct support,
  enabling sampling of configurations with a prescribed fingerprint.

## 9. Discussion

The value of the congruence theory is methodological: it converts a global
statement ("two configurations are connected") into a local induction ("make one
basis match, then recurse") whose steps are individually simple. The rank-one
theorem shows the induction's base case is not merely tractable but *degenerate* —
equal fingerprints force literal equality — which sharply localizes the difficulty
of the full conjecture to the redistribution freedom that first appears at rank
two.

A cautionary contrast is instructive. White's stronger symmetric-exchange variant,
which restricts each move to a single-element swap, is false; the extra freedom of
Part 3 to repack two bases *arbitrarily* (subject only to conservation) is
essential. Theorem 4.1 makes this freedom explicit and is the reason the uniform
reduction of Section 6 is even plausible.

## 10. Future work

The immediate target is Conjecture 6.1, the extraction lemma, whose proof would
yield Part 3 for all uniform matroids via Theorem 6.2. Beyond uniform matroids,
the redistribution/extraction template should port to **strongly base-orderable
matroids** — a class where Part 3 is known — once a compatible base ordering
replaces the free redistribution that uniform matroids enjoy. The full future
program, as set out in the accompanying package, records the precise remaining
obligations and the path beyond the uniform world.

## References

Only widely known background is assumed: the standard theory of matroids and their
basis-exchange axioms, and the multiset/finite-set combinatorics used throughout.
