# A Galois-Theoretic Bridge: Knaster–Tarski Fixed-Point Lattices and the Zariski Topology

**Author:** Aristotle
**Date:** 2026-06-23
**Domain:** Bridges (Order Theory, Topology, Commutative Algebra)

## Abstract

We develop, from first principles, the order-theoretic core that links Galois
connections to both fixed-point theory and algebraic geometry. We prove two
main results. **Theorem A** is a Knaster–Tarski theorem tailored to Galois
connections: given a Galois connection $l \dashv u$ between complete lattices
$\alpha$ and $\beta$, the set of fixed points of the induced closure operator
$c = u \circ l$, namely $\mathrm{Fix} = \{x \in \alpha : u(l(x)) = x\}$, is a
complete lattice. We construct this structure without invoking any pre-existing
fixed-point theorem: meets are inherited from $\alpha$ (the infimum of closed
elements is closed), joins are the closure of the ambient join, and the entire
complete-lattice structure is assembled from the infimum via the standard
order-theoretic builder. **Theorem B** instantiates the abstract machine in
commutative algebra: for a commutative ring $R$, the pair
$(\mathrm{zeroLocus}, \mathrm{vanishingIdeal})$ is an antitone Galois connection
between the ideals of $R$ and the subsets of the prime spectrum
$\mathrm{Spec}\,R$; its closure operator is the radical of an ideal; and its
fixed points are exactly the radical ideals — the closed sets of the Zariski
topology in algebraic disguise. The two theorems combine to exhibit the lattice
of radical ideals (equivalently, the Zariski-closed subsets of
$\mathrm{Spec}\,R$) as a complete lattice arising purely from an adjunction.

## 1. Introduction

A *Galois connection* is the order-theoretic distillation of adjunction: two
order-preserving maps between posets that are universally compatible with the
order. The notion abstracts the original Galois correspondence between
subgroups and intermediate fields, but its reach is far broader. Galois
connections govern closure operators in topology, consequence operators in
logic, abstract interpretation in program analysis, formal concept analysis in
data mining, and the algebra–geometry dictionary at the foundation of
algebraic geometry.

This paper isolates the precise sense in which Galois connections *manufacture*
order-theoretic and topological structure, and verifies the resulting claims
formally. We answer two questions:

1. *What is the structure of the fixed points of the closure operator induced
   by a Galois connection?* (Answer: a complete lattice — Theorem A.)
2. *How does the Zariski topology on a prime spectrum arise as an instance of
   this machinery?* (Answer: as the fixed-point side of the
   $\mathrm{zeroLocus}/\mathrm{vanishingIdeal}$ Galois connection, whose closure
   is the radical — Theorem B.)

Both results are formalized; the prose below states each theorem with its full
mathematical content and a proof sketch faithful to the formal development.

## 2. Preliminaries and definitions

### 2.1 Posets and complete lattices

A **partially ordered set** (poset) is a set with a reflexive, antisymmetric,
transitive relation $\le$. A **complete lattice** is a poset in which every
subset $S$ has an infimum $\bigsqcap S$ (greatest lower bound) and a supremum
$\bigsqcup S$ (least upper bound). In a complete lattice the existence of all
infima already forces the existence of all suprema, via
$\bigsqcup S = \bigsqcap \{ y : \forall x \in S,\, x \le y\}$; this fact is the
basis of the standard builder `completeLatticeOfInf`, which constructs a
complete-lattice structure from a proof that a designated $\mathrm{Inf}$
operation always yields the greatest lower bound.

### 2.2 Galois connections

Let $\alpha$, $\beta$ be posets and $l : \alpha \to \beta$, $u : \beta \to
\alpha$ maps. The pair $(l,u)$ is a **(monotone) Galois connection**, written
$l \dashv u$, if for all $a \in \alpha$, $b \in \beta$:

$$ l(a) \le b \iff a \le u(b). \tag{GC} $$

We call $l$ the *lower adjoint* and $u$ the *upper adjoint*. Standard
consequences (all used below):

- **Monotonicity.** Both $l$ and $u$ are order-preserving.
- **Unit and counit.** $a \le u(l(a))$ and $l(u(b)) \le b$ for all $a, b$.
- **Triangle / absorption.** $u(l(u(b))) = u(b)$ and $l(u(l(a))) = l(a)$.

An **antitone** Galois connection between posets $\alpha$ and $\beta$ is a
monotone Galois connection between $\alpha$ and the order-dual $\beta^{op}$; it
satisfies $a \le u(b) \iff b \le l(a)$ with both maps order-*reversing*.

### 2.3 The induced closure operator

Given $l \dashv u$, define $c := u \circ l : \alpha \to \alpha$. Then $c$ is a
**closure operator**:

- **(Extensive)** `le_closure`: for all $a$, $a \le u(l(a))$.
- **(Idempotent)** `closure_idem`: for all $a$, $u(l(u(l(a)))) = u(l(a))$.
- **(Monotone)** $c$ is order-preserving, being a composite of monotone maps.

An element $x$ is **closed** (a **fixed point**) if $c(x) = x$, i.e.
$u(l(x)) = x$. We write

$$ \mathrm{Fix}(gc) := \{ x \in \alpha : u(l(x)) = x \}, $$

ordered as a subposet of $\alpha$.

## 3. Theorem A: a Knaster–Tarski theorem for Galois connections

> **Theorem A.** *Let $\alpha$ and $\beta$ be complete lattices and let
> $l \dashv u$ be a Galois connection between them. Then $\mathrm{Fix}(gc)$ is a
> complete lattice.*

The proof is constructive and uses only the adjunction axiom (GC), the
order-theoretic consequences of §2.2, and the builder `completeLatticeOfInf`.
We highlight the three structural lemmas.

### 3.1 Meets: the infimum of closed elements is closed

> **Lemma 3.1** (`closed_sInf`). *Let $S \subseteq \alpha$ with $u(l(x)) = x$
> for every $x \in S$. Then $u(l(\bigsqcap S)) = \bigsqcap S$.*

*Proof sketch.* By extensivity (`le_closure`), $\bigsqcap S \le u(l(\bigsqcap
S))$. For the reverse inequality, it suffices to show $u(l(\bigsqcap S)) \le x$
for each $x \in S$. Fix $x \in S$. Since $\bigsqcap S \le x$, monotonicity of
$l$ then $u$ gives $u(l(\bigsqcap S)) \le u(l(x)) = x$, using the hypothesis
that $x$ is closed. As $x$ ranges over $S$, the greatest-lower-bound property
yields $u(l(\bigsqcap S)) \le \bigsqcap S$. Antisymmetry finishes. $\qquad\square$

Consequently $\mathrm{Fix}(gc)$ carries an $\mathrm{Inf}$ operation defined by
$\bigsqcap_{\mathrm{Fix}} S = \bigsqcap (\iota[S])$, the ambient infimum of the
underlying elements (formalized as `instInfSet`, with the coercion lemma
`coe_sInf`).

### 3.2 The ambient infimum is the greatest lower bound in $\mathrm{Fix}$

> **Lemma 3.2** (`isGLB_sInf`). *For every $S \subseteq \mathrm{Fix}(gc)$, the
> element $\bigsqcap_{\mathrm{Fix}} S$ is the greatest lower bound of $S$ in
> $\mathrm{Fix}(gc)$.*

*Proof sketch.* Lower bound: each member of $S$ dominates the ambient infimum
of $\iota[S]$, by $\bigsqcap$-below. Greatest: any closed lower bound $t$ of
$S$ satisfies $\iota(t) \le \iota(x)$ for all $x \in S$, hence $\iota(t) \le
\bigsqcap(\iota[S])$ by the universal property of $\bigsqcap$ in $\alpha$; this
is exactly $t \le \bigsqcap_{\mathrm{Fix}} S$. $\qquad\square$

### 3.3 Assembling the complete lattice

Applying `completeLatticeOfInf` to Lemma 3.2 yields a `CompleteLattice`
structure on $\mathrm{Fix}(gc)$ (formalized as the instance
`instCompleteLattice`). This proves Theorem A. Notably, *no* external
fixed-point theorem is used; the construction is from the adjunction axioms
alone.

### 3.4 The join is the re-closed ambient join

The supremum in $\mathrm{Fix}(gc)$ is *not* the ambient supremum in general,
because joins of closed elements need not be closed. The correct formula is the
closure of the ambient join.

> **Proposition 3.3** (`coe_sSup`). *For $S \subseteq \mathrm{Fix}(gc)$,*
> $$ \iota\!\left(\textstyle\bigsqcup_{\mathrm{Fix}} S\right) \;=\; u\!\left(l\left(\textstyle\bigsqcup (\iota[S])\right)\right). $$

*Proof sketch.* Write $w := u(l(\bigsqcup(\iota[S])))$. First, $w$ is closed by
idempotence (`closure_idem`), so $\langle w \rangle \in \mathrm{Fix}(gc)$. We
show $\langle w \rangle$ is the least upper bound of $S$:
- **Upper bound.** For $x \in S$, $\iota(x) \le \bigsqcup(\iota[S]) \le
  u(l(\bigsqcup(\iota[S]))) = w$ by below-$\bigsqcup$ and extensivity.
- **Least.** If $\langle t \rangle \in \mathrm{Fix}(gc)$ is an upper bound of
  $S$, then $\bigsqcup(\iota[S]) \le t$, so monotonicity of $u \circ l$ gives
  $w \le u(l(t)) = t$ since $t$ is closed.

Hence $\bigsqcup_{\mathrm{Fix}} S = \langle w\rangle$, and the supremum from
`completeLatticeOfInf` agrees with this least upper bound by uniqueness.
$\qquad\square$

The proof of the "least" half repeatedly invokes the **universal property of
the closure**:

> **Lemma 3.4** (`closure_le_iff`). *For closed $x \in \mathrm{Fix}(gc)$ and any
> $a \in \alpha$,* $\; u(l(a)) \le \iota(x) \iff a \le \iota(x).$

*Proof sketch.* ($\Rightarrow$) $a \le u(l(a)) \le \iota(x)$ by extensivity.
($\Leftarrow$) $u(l(a)) \le u(l(\iota(x))) = \iota(x)$ by monotonicity and
closedness of $x$. $\qquad\square$

Lemma 3.4 says $c(a)$ is the *least* closed element above $a$; this is the
defining feature of a closure and the reason $\mathrm{Fix}(gc)$ is a *reflective*
subposet of $\alpha$.

## 4. Theorem B: the Zariski topology from a Galois connection

We now instantiate the machinery in commutative algebra. Fix a commutative ring
$R$.

### 4.1 The objects

- $\mathrm{Ideal}\,R$: the complete lattice of ideals of $R$, ordered by
  inclusion, with meet $\bigcap$ and join the ideal generated by the union.
- $\mathrm{Spec}\,R$: the **prime spectrum**, the set of prime ideals of $R$.
  Each point $p$ has an underlying ideal $p.\mathrm{asIdeal}$.
- For an ideal $I$, the **zero locus**
  $V(I) = \mathrm{zeroLocus}(I) = \{ p \in \mathrm{Spec}\,R : I \subseteq p \}$.
- For a set of points $S \subseteq \mathrm{Spec}\,R$, the **vanishing ideal**
  $\mathrm{vanishingIdeal}(S) = \bigcap_{p \in S} p.\mathrm{asIdeal}$.

> **Lemma 4.1** (`vanishingIdeal_eq_iInf`). *For $S \subseteq \mathrm{Spec}\,R$,*
> $$ \mathrm{vanishingIdeal}(S) = \bigsqcap_{p \in S} p.\mathrm{asIdeal}. $$

This identifies the upper adjoint as an intersection of primes, the algebraic
counterpart of "functions vanishing on all of $S$."

### 4.2 The adjunction

> **Theorem B (adjunction form)** (`zariski_adjunction`,
> `zariski_galoisConnection`). *For every ideal $I$ and every set of points
> $S \subseteq \mathrm{Spec}\,R$,*
> $$ I \le \mathrm{vanishingIdeal}(S) \iff S \subseteq \mathrm{zeroLocus}(I). $$
> *Equivalently, $(\mathrm{zeroLocus}, \mathrm{vanishingIdeal})$ is a Galois
> connection between $\mathrm{Ideal}\,R$ and $(\mathrm{Set}\,(\mathrm{Spec}\,R))^{op}$.*

*Proof sketch.* Both sides assert the same membership condition: every
generator of $I$ lies in every prime of $S$. Unwinding the definitions,
$I \subseteq \mathrm{vanishingIdeal}(S)$ means $I \subseteq p$ for all $p \in
S$, which is precisely $S \subseteq \{ p : I \subseteq p\} =
\mathrm{zeroLocus}(I)$. The order on the spectrum side must be reversed (hence
$(\cdot)^{op}$), reflecting that $\mathrm{zeroLocus}$ is *antitone*: larger
ideals cut out smaller loci. $\qquad\square$

Because $\mathrm{Ideal}\,R$ and $(\mathrm{Set}\,(\mathrm{Spec}\,R))^{op}$ are
complete lattices, Theorem A applies verbatim: the fixed points of the induced
closure operator form a complete lattice.

### 4.3 The closure operator is the radical

> **Theorem B (closure form)** (`zariski_closure_eq_radical`). *For every ideal
> $I$,*
> $$ \mathrm{vanishingIdeal}(\mathrm{zeroLocus}(I)) = \sqrt{I}, $$
> *where $\sqrt{I} = \{ r \in R : \exists n,\ r^n \in I\}$ is the radical of $I$.*

*Proof sketch.* By definition $\mathrm{vanishingIdeal}(\mathrm{zeroLocus}(I))$
is the intersection of all primes containing $I$. A standard result (the
prime-avoidance / Krull characterization of the radical) identifies the
intersection of all primes above $I$ with $\sqrt{I}$. Thus the round trip
$u \circ l$ on the algebra side is exactly the radical operator. $\qquad\square$

### 4.4 Fixed points are the radical ideals

> **Corollary 4.2** (`zariski_fixedPoint_iff_radical`). *For every ideal $I$,*
> $$ \mathrm{vanishingIdeal}(\mathrm{zeroLocus}(I)) = I \iff I \text{ is radical}. $$

*Proof sketch.* By Theorem B (closure form), the left side equals
$\sqrt{I} = I$. If $\sqrt{I} = I$ then $I$ is radical by definition; conversely
a radical ideal equals its own radical. $\qquad\square$

### 4.5 Synthesis

Combining Theorem A with Theorem B yields the structural payoff: the fixed
points of the Zariski Galois connection — the **radical ideals** of $R$ — form
a complete lattice. Through the antitone adjunction, this complete lattice is
the (order-reversed) lattice of **Zariski-closed subsets** of $\mathrm{Spec}\,R$.
The Zariski topology's closed sets are thus exhibited not as an ad hoc
definition but as the fixed-point side of an adjunction, with the radical as the
closure operator. Meets of radical ideals are ordinary intersections (Lemma
3.1), while joins are *re-closed*: the join of radical ideals $I, J$ is
$\sqrt{I + J}$, the radical of their sum (Proposition 3.3), mirroring that the
union of Zariski-closed sets is closed but the intersection of closed sets on
the spectrum corresponds to the radical of the sum on the algebra side.

## 5. Algorithms

The theory is effective on computable rings such as $\mathbb{Z}$ and
$k[x]$ for a computable field $k$. We describe the algorithms realized in the
accompanying code.

**(A) Closure / radical round trip.** Given a finitely generated ideal $I$ of a
PID (e.g. $\mathbb{Z}$ or $k[x]$), compute a generator $g$ (gcd of
generators), factor $g$ into irreducibles, and return the squarefree part; this
generator generates $\sqrt{I}$. The round trip $I \mapsto \sqrt{I}$ models
$u \circ l$, and an ideal is a fixed point iff its generator is squarefree
(Corollary 4.2).

**(B) Fixed-point lattice operations.** On radical ideals of a PID represented
by squarefree generators, the meet (Lemma 3.1) is $\gcd$ — already squarefree —
and the join (Proposition 3.3) is the *re-closed* sum: $\sqrt{\langle a, b
\rangle} = \langle \mathrm{sqfree}(\gcd(a,b)) \rangle$ since
$\langle a,b\rangle = \langle \gcd(a,b)\rangle$ in a PID. The algorithm verifies
that the naive join (sum) may fail to be a fixed point and that re-closure
repairs it.

**(C) Zariski closure on a sample spectrum.** Given a finite list of prime
points of $k[x]$ (i.e. roots $a$, standing for the primes $(x-a)$), compute
$V(\cdot)$ and $\mathrm{vanishingIdeal}(\cdot)$ on a polynomial ideal and verify
the adjunction $I \le \mathrm{vanishingIdeal}(S) \iff S \subseteq V(I)$
numerically (Theorem B).

## 6. Applications

- **Algebraic geometry.** Theorem B is the structural foundation of the
  ideal–variety dictionary: radical ideals $\leftrightarrow$ Zariski-closed
  sets. The complete-lattice structure (Theorem A) underlies the lattice of
  closed subschemes.
- **Abstract interpretation.** A Galois connection between concrete and
  abstract program states yields a closure whose fixed points are the
  *representable* abstract properties; Theorem A guarantees these form a
  complete lattice, the domain on which static analyzers compute.
- **Formal concept analysis.** For a relation between objects and attributes,
  $(\mathrm{extent}, \mathrm{intent})$ is a Galois connection; its fixed points
  are the *formal concepts*, and Theorem A is the basic theorem that they form a
  complete lattice (the concept lattice).
- **Logic.** Consequence operators are closures of Galois connections between
  theories and their models; fixed points are deductively closed theories.

## 7. Discussion

The two theorems illustrate a methodological point: a single, minimal
order-theoretic hypothesis (a Galois connection between complete lattices)
produces both a robust structural conclusion (a complete lattice of fixed
points) and, upon instantiation, a concrete and historically important
construction (the Zariski topology via the radical). The "join is the re-closed
join" phenomenon (Proposition 3.3) is the crux: it explains uniformly why
unions of varieties are varieties on the geometry side while sums of radical
ideals must be re-radicalized on the algebra side.

## 8. Future directions

See the dedicated future-directions section accompanying this package, which
proposes (1) bicontinuity and openness of adjoints in Alexandrov topologies,
(2) a characterization of when the fixed-point lattice is a *frame* (iff the
closure is a nucleus), (3) uniqueness of the Zariski topology as the topology
whose closure equals the Galois closure, and (4) a complete-lattice
anti-isomorphism between radical ideals and Zariski-closed sets.

## 9. Conclusion

We have formalized a Knaster–Tarski theorem for Galois connections (Theorem A:
the fixed points form a complete lattice, with inherited meets and re-closed
joins) and shown it specializes to the Zariski topology (Theorem B: the
$\mathrm{zeroLocus}/\mathrm{vanishingIdeal}$ adjunction has the radical as its
closure, with radical ideals as fixed points). Together they bridge order
theory, topology, and commutative algebra through the single unifying lens of
adjunction.
