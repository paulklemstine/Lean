# Phantom Topologies and the Phantom Number: Reality as the Consensus of Observers

## Abstract

We introduce and study *phantom topologies*: a framework in which a single set
carries a family of topologies indexed by "observers," and the *real* topology is
defined to be the topology on which all observers unanimously agree. Formally, a
phantom topology on a set $X$ with observer set $\mathcal{O}$ is a map
$T:\mathcal{O}\to\{\text{topologies on }X\}$, and its *consensus* topology is the
supremum $\bigsqcup_{o} T(o)$ in the lattice of topologies — the topology whose
open sets are exactly the sets open in every $T(o)$. Each observer is finer than
the consensus, so the consensus operation is order-reversing in resolution:
enlarging the observer set can only coarsen the shared reality. We call a
representation *genuinely phantom* when each observer is strictly finer than the
consensus, and we define the *phantom number* of a topological space as the least
number of such strictly-finer observers whose consensus reproduces it.

Our two principal results are:

1. **Two-observer theorem for the real line.** The standard Euclidean topology on
   $\mathbb{R}$ is exactly the consensus of the lower-limit (Sorgenfrey) and
   upper-limit topologies, each of which is strictly finer than the Euclidean
   topology; since a single observer's consensus is itself, the phantom number of
   $\mathbb{R}$ is exactly two.

2. **Refutation of the metrizability barrier.** We refute the conjecture that
   every non-metrizable space requires at least three observers. The two-point
   indiscrete space is non-metrizable (indeed not even $T_0$) yet is the consensus
   of exactly two strictly-finer Sierpiński observers; its phantom number is two.

The refutation isolates the conceptual point: separation strength (metrizability,
$T_0$, $T_1$, Hausdorff) and phantom number are *independent* invariants. Phantom
number is an order-theoretic measure of meet-reducibility in the lattice of
topologies, whereas metrizability is a geometric, distance-derived separation
property; neither controls the other.

**Keywords:** topology lattice, consensus topology, Sorgenfrey line, Sierpiński
space, indiscrete topology, metrizability, separation axioms, meet-reducibility.

---

## 1. Introduction

The physics of measurement suggests a provocative geometric question: what if the
topology of a space depended on the observer? This paper answers it rigorously.
We treat "reality" not as a single privileged topology but as the *agreement* of
many observer-relative topologies. The mathematical content lies in the interplay
between two very different measurements of a space:

- **Separation** — how well the topology distinguishes points, governed by the
  separation axioms and, at the strong end, by metrizability; and
- **Phantom number** — how many strictly-finer topologies must be intersected to
  recover the space, a purely order-theoretic (lattice) quantity.

A natural conjecture links them: since metrizable spaces are highly separated and
the Euclidean line reconstructs from two observers, perhaps *less* separated
(non-metrizable) spaces require *more* observers. We prove this conjecture false
with a minimal counterexample and, in doing so, argue that the two invariants are
orthogonal.

### Conventions on the lattice of topologies

Throughout, topologies on a fixed set $X$ are ordered by *fineness*: we write
$s \le t$ to mean $s$ is **finer** than $t$, i.e. every $t$-open set is $s$-open.
Under this convention the finest (discrete) topology is the bottom element and the
coarsest (indiscrete) topology is the top element $\top$. The set of topologies on
$X$ forms a complete lattice. For a family $(t_i)_{i\in I}$, the supremum
$\bigsqcup_i t_i$ has as its open sets exactly those sets open in *every* $t_i$:
$$U \text{ is } \Big(\textstyle\bigsqcup_i t_i\Big)\text{-open} \iff \forall i,\ U \text{ is } t_i\text{-open}.$$
It is worth stressing the direction: the supremum in the fineness order is the
*coarsest* topology all $t_i$ refine, and its opens are the *intersection* of the
open-set families. This is the technical device that models "consensus."

---

## 2. The phantom-topology framework

**Definition 2.1 (Phantom topology).** A *phantom topology* on a set $X$ with
observer set $\mathcal{O}$ is a function $T:\mathcal{O}\to\{\text{topologies on }X\}$
assigning to each observer $o$ a topology $T(o)$ on $X$.

**Definition 2.2 (Consensus / real topology).** The *consensus* topology of $T$ is
$$\operatorname{consensus}(T) \;=\; \bigsqcup_{o\in\mathcal{O}} T(o),$$
the supremum in the lattice of topologies.

**Proposition 2.3 (Agreement).** For every subset $U\subseteq X$,
$$U \text{ is } \operatorname{consensus}(T)\text{-open} \iff U \text{ is } T(o)\text{-open for every observer } o.$$

*Proof.* Immediate from the description of the supremum of topologies: the open
sets of $\bigsqcup_o T(o)$ are exactly those open in every $T(o)$. $\qquad\blacksquare$

**Proposition 2.4 (Measurement coarsens).** For every observer $o$,
$$T(o) \le \operatorname{consensus}(T),$$
i.e. each observer is finer than the consensus. Consequently, if $\mathcal{O}'
\supseteq \mathcal{O}$ are observer sets for compatible families, the larger family
has a coarser (or equal) consensus: adding observers never sharpens reality.

*Proof.* $T(o)$ is a lower bound term of the supremum, so $T(o)\le\bigsqcup_{o'}T(o')$
by the universal property of the supremum. Enlarging the index set adds terms to
the supremum, which can only move it up in the order (coarser). $\qquad\blacksquare$

**Definition 2.5 (Genuinely phantom representation).** A phantom topology $T$ is a
*genuinely phantom representation* of a topology $\tau$ if
$\operatorname{consensus}(T)=\tau$ and $T(o) < \tau$ (strictly finer) for every
observer $o$. The strictness means each observer resolves *phantom* open sets —
sets open to that observer but not in reality.

**Definition 2.6 (Phantom number).** The *phantom number* of a topological space
$(X,\tau)$ is the least cardinality of an observer set $\mathcal{O}$ admitting a
genuinely phantom representation $T$ of $\tau$. (If no observer is strictly finer
than $\tau$, e.g. when $\tau$ is discrete, the phantom number is undefined /
infinite; we focus on spaces where it is finite.)

**Remark 2.7 (One observer is never phantom).** For a single-observer family
$T:\{*\}\to\{\text{topologies}\}$, $\operatorname{consensus}(T)=T(*)$, because the
supremum of a one-element family is that element. Hence a one-observer
representation of $\tau$ forces $T(*)=\tau$, which is *not* strictly finer. Thus a
genuinely phantom representation needs at least two observers, and the phantom
number — when finite — is at least $2$.

---

## 3. The real line as a two-observer consensus

We construct two one-sided observers on $\mathbb{R}$ and prove their consensus is
the Euclidean topology.

**Definition 3.1 (Lower- and upper-limit observers).**

- The **lower-limit (Sorgenfrey) observer** $L$ declares $U\subseteq\mathbb{R}$
  open iff every $x\in U$ has some $b>x$ with $[x,b)\subseteq U$. Its basic open
  sets are the right half-open intervals $[x,b)$.
- The **upper-limit observer** $R$ declares $U$ open iff every $x\in U$ has some
  $a<x$ with $(a,x]\subseteq U$. Its basic open sets are the left half-open
  intervals $(a,x]$.

That these two prescriptions define topologies is routine: the whole line is open
(step by $\pm 1$); finite intersections work by taking the minimum (resp. maximum)
of the interval endpoints; arbitrary unions are immediate.

**Lemma 3.2 (Phantom witnesses).** The interval $[0,1)$ is $L$-open but not
Euclidean-open, and $(0,1]$ is $R$-open but not Euclidean-open.

*Proof.* From any $x\in[0,1)$ the interval $[x,1)$ witnesses $L$-openness. But
$[0,1)$ is not Euclidean-open: any ball around $0$ contains points $<0$ outside
$[0,1)$. Symmetrically for $(0,1]$ under $R$. $\qquad\blacksquare$

**Theorem 3.3 (Two-observer theorem for $\mathbb{R}$).** A subset
$U\subseteq\mathbb{R}$ is Euclidean-open if and only if it is open for both $L$ and
$R$. Equivalently,
$$L \sqcup R \;=\; \tau_{\mathrm{Euclid}}, \qquad\text{i.e.}\qquad \operatorname{consensus}(L,R)=\tau_{\mathrm{Euclid}}.$$

*Proof.* ($\Leftarrow$, two-sided squeeze) Suppose $U$ is both $L$-open and
$R$-open, and fix $x\in U$. $L$-openness gives $b>x$ with $[x,b)\subseteq U$;
$R$-openness gives $a<x$ with $(a,x]\subseteq U$. Set
$\varepsilon=\min(x-a,\,b-x)>0$. For any $y$ with $|y-x|<\varepsilon$: if $y\ge x$
then $y\in[x,b)\subseteq U$; if $y<x$ then $y\in(a,x]\subseteq U$. So the ball
$B(x,\varepsilon)\subseteq U$, proving $U$ is Euclidean-open.

($\Rightarrow$) If $U$ is Euclidean-open and $x\in U$, take $\varepsilon>0$ with
$B(x,\varepsilon)\subseteq U$. Then $[x,x+\varepsilon)\subseteq U$ witnesses
$L$-openness and $(x-\varepsilon,x]\subseteq U$ witnesses $R$-openness. Hence $U$
is open for both observers. $\qquad\blacksquare$

**Corollary 3.4 (Phantom number of $\mathbb{R}$ is two).** Both observers are
strictly finer than the Euclidean topology ($L<\tau_{\mathrm{Euclid}}$ and
$R<\tau_{\mathrm{Euclid}}$), because $[0,1)$ and $(0,1]$ are phantom witnesses
(Lemma 3.2), while $L\le\tau_{\mathrm{Euclid}}$ and $R\le\tau_{\mathrm{Euclid}}$
by Proposition 2.4. So $(L,R)$ is a genuinely phantom two-observer representation,
giving phantom number $\le 2$; and by Remark 2.7 it is $\ge 2$. Therefore the
phantom number of $\mathbb{R}$ is exactly $2$.

Note also $L\neq R$: $[0,1)$ is $L$-open but not $R$-open (an $R$-witness at $0$
would require some $(a,0]\subseteq[0,1)$, impossible since $(a,0]$ contains points
$<0$). The two observers genuinely disagree.

---

## 4. Refuting the metrizability barrier

We now address the conjecture that non-metrizability forces at least three
observers. We recall the relevant separation notion.

**Definition 4.1 ($T_0$ / Kolmogorov).** A space is $T_0$ if for any two distinct
points at least one lies in an open set not containing the other.

**Fact 4.2.** Every metrizable space is $T_0$ (indeed Hausdorff): distinct points
$p\neq q$ have $d(p,q)>0$, so $B(p,d(p,q))$ separates them. Contrapositively, a
space that is not $T_0$ is not metrizable.

**Definition 4.3 (Indiscrete two-point space).** Let $X=\{\mathsf{true},
\mathsf{false}\}$ with the indiscrete topology $\top$, whose only open sets are
$\varnothing$ and $X$.

**Proposition 4.4 (Non-metrizability).** The indiscrete two-point space is not
metrizable.

*Proof.* It is not $T_0$: the only nonempty open set is $X$ itself, so no open set
separates $\mathsf{true}$ from $\mathsf{false}$. By Fact 4.2 it is not metrizable.
$\qquad\blacksquare$

**Definition 4.5 (Sierpiński observers).** Define two topologies on
$X=\{\mathsf{true},\mathsf{false}\}$ via implication predicates:

- $S_{\mathsf{true}}$: a set $U$ is open iff ($\mathsf{false}\in U \Rightarrow
  \mathsf{true}\in U$). Its open sets are exactly
  $\{\varnothing,\ \{\mathsf{true}\},\ X\}$.
- $S_{\mathsf{false}}$: a set $U$ is open iff ($\mathsf{true}\in U \Rightarrow
  \mathsf{false}\in U$). Its open sets are exactly
  $\{\varnothing,\ \{\mathsf{false}\},\ X\}$.

Each is a valid topology: the whole set and empty set satisfy the implication
vacuously/trivially, and the implication is preserved under intersection and
union. Each is a copy of the two-point Sierpiński space.

**Lemma 4.6 (Phantom singletons).** $\{\mathsf{true}\}$ is $S_{\mathsf{true}}$-open
(the hypothesis $\mathsf{false}\in\{\mathsf{true}\}$ is false, so the implication
holds vacuously), and $\{\mathsf{false}\}$ is $S_{\mathsf{false}}$-open. Neither
singleton is open in the indiscrete topology.

**Theorem 4.7 (Two-observer consensus for the indiscrete space).**
$$S_{\mathsf{true}} \sqcup S_{\mathsf{false}} \;=\; \top,$$
i.e. the consensus of the two Sierpiński observers is the indiscrete topology.

*Proof.* By Proposition 2.3, $U$ is consensus-open iff it is open for both
observers, i.e.
$$(\mathsf{false}\in U \Rightarrow \mathsf{true}\in U)\ \wedge\ (\mathsf{true}\in U \Rightarrow \mathsf{false}\in U).$$
This double implication is equivalent to $\mathsf{true}\in U \Leftrightarrow
\mathsf{false}\in U$: the set contains both points or neither. Hence
$U\in\{\varnothing,X\}$, which is exactly the indiscrete topology $\top$.
$\qquad\blacksquare$

**Corollary 4.8 (Strict refinement).** Both observers are strictly finer than the
consensus: $S_{\mathsf{true}}<\top$ and $S_{\mathsf{false}}<\top$, since each
resolves a phantom singleton (Lemma 4.6) that $\top$ does not. Thus
$(S_{\mathsf{true}}, S_{\mathsf{false}})$ is a genuinely phantom two-observer
representation of the indiscrete two-point space.

**Theorem 4.9 (Refutation).** The indiscrete two-point space is non-metrizable
(Proposition 4.4) yet has phantom number $2$ (Corollary 4.8 and Remark 2.7).
Therefore the conjecture "every non-metrizable space requires at least three
observers" is **false**.

---

## 5. Discussion: separation and phantom number are orthogonal

Theorems 3.3 and 4.7 place two spaces at opposite extremes of geometric structure
— the exquisitely separated Euclidean line and the maximally unseparated
indiscrete pair — and assign both the *same* phantom number, $2$. This is the
crux.

The failed conjecture rests on conflating two independent axes:

- **Separation** measures how well points can be told apart (the $T_0$–$T_1$–$T_2$
  hierarchy, culminating in metrizability). It is intrinsically geometric and
  distance-flavored.
- **Phantom number** measures *meet-reducibility in the lattice of topologies*:
  how many strictly-finer topologies must be intersected (via supremum in the
  fineness order) to recover $\tau$. It is intrinsically order-theoretic.

The indiscrete counterexample shows a space can be maximally *non*-separated and
still be the meet of exactly two strictly-finer topologies. The mechanism is
transparent: each Sierpiński observer contributes exactly one phantom singleton,
and the two phantoms are *complementary* — their defining implications compose to
a biconditional that forces triviality in consensus. Non-metrizability lives on
the separation axis; low phantom number lives on the reducibility axis; the
example decouples them.

This reframes "reality as consensus" as a genuinely lattice-theoretic principle:
the object of interest is how a topology sits as a supremum of strictly-finer
topologies, not how its points are separated by opens.

---

## 6. Algorithms

Although the theorems are about infinite spaces (the real line), the *finite*
consensus phenomena are directly computable. We record the core routines used in
the accompanying numerical demonstrations.

**Algorithm A — Finite consensus (open-set intersection).** Given finitely many
topologies on a finite set, each represented as its family of open sets, the
consensus topology's open sets are the intersection of the families. Verifying it
is a valid topology (closed under intersection and union, containing $\varnothing$
and the whole set) is a finite check.

**Algorithm B — One-sided open verification on a grid.** Approximate the
lower-limit / upper-limit / Euclidean open predicates on a finite grid of $\mathbb{R}$
by testing, for each point of a candidate set, the existence of a right-, left-, or
two-sided witness interval. This lets one exhibit the squeeze of Theorem 3.3 and
the phantom witnesses of Lemma 3.2 numerically.

**Algorithm C — Separation-axiom checker.** Given a finite topology as its open-set
family, test $T_0$ by checking that every pair of distinct points is separated by
some open set; this certifies non-metrizability of the indiscrete example (a
finite non-$T_0$ space cannot be metrizable).

---

## 7. Applications and interpretation

- **A rigorous model of observer-relative structure.** The framework makes precise
  the slogan "reality depends on the observer": each observer's topology is a
  legitimate structure, and objective reality is the provable consensus. The
  order-reversing law (Proposition 2.4) — more observers, coarser reality —
  formalizes measurement as a coarsening act, a topological echo of the
  information/disturbance trade-off in quantum measurement.

- **A diagnostic against invariant conflation.** The refutation is a clean case
  study in *disentangling invariants*: a plausible link between two properties is
  broken by a single minimal example, redirecting attention to the true governing
  invariant (lattice reducibility rather than separation).

- **Toward a factorization theory of topologies.** Phantom number invites viewing
  every topology through its decompositions as suprema of strictly-finer
  topologies, analogous to factorization of integers or meet-decomposition in
  lattice theory.

---

## 8. Future directions

The following research directions arise from this cycle's central finding that the
real line and the two-point indiscrete space are *both* two-observer consensuses
despite occupying opposite ends of the separation spectrum.

**1. The phantom number is a lattice invariant, not a geometric one.** *Conjecture.*
The minimum number of sharper observers whose shared open sets reconstruct a space
equals the depth to which that space's topology can be split into strictly finer
topologies that intersect back to it; it is finite exactly when the topology is not
irreducible under such splitting. The key insight is that "how many observers
reconstruct reality" is a purely order-theoretic quantity — the reducibility of a
topology as a meet of strictly larger topologies — with nothing to do with
distances or curvature. We now have exact values (2 for the Euclidean line, 2 for
the indiscrete pair) for spaces at opposite extremes of geometric structure, so the
common thread must be lattice-theoretic.

**2. Separation and phantom number are independent.** *Conjecture.* For every
target phantom number $k\ge 2$ and every separation strength (from indistinguishable
points up to full metrizability), there is a space realizing exactly that
combination; the two invariants can be dialed independently. The key insight is
that separation axioms measure how well points can be told apart, whereas the
phantom number measures how reality factors through sharper observers; the
indiscrete counterexample shows neither controls the other. The refutation already
punctures the assumed link; the natural next step is to prove every combination is
achievable.

**3. Adding observers can only blur, never sharpen.** *Conjecture.* The consensus
operation on a diagram of observers is order-reversing and meet-continuous:
enlarging the observer set can only coarsen the agreed topology, and the agreed
topology over a union of observer groups is the common refinement of the group
consensuses. The key insight is that agreement is an intersection of viewpoints, so
more viewpoints can only shrink what everyone accepts as open — measurement is a
strictly coarsening act. Promoting the observed two-observer monotonicity to
arbitrary observer diagrams would turn "reality as consensus" into a genuine
functorial principle with predictive force about many-observer systems.

**4. Every second-countable space is a two-observer consensus.** *Conjecture.* Any
space with a countable base that is not irreducible under splitting can be
reconstructed by exactly two sharper observers, built by adjoining one-sided
half-neighborhoods to each basic open on the left and on the right. The key insight
generalizes the real-line construction: one-sided refinements of a countable base
provide two complementary observers whose consensus is the original topology.

---

## 9. Conclusion

We formalized observer-relative geometry through phantom topologies, defined the
consensus (real) topology as the supremum in the lattice of topologies, and
introduced the phantom number as the least number of strictly-finer observers whose
consensus recovers a space. We proved the Euclidean line has phantom number two —
the consensus of the lower- and upper-limit observers — and refuted the conjectured
metrizability barrier by exhibiting the non-metrizable indiscrete two-point space
as the consensus of two Sierpiński observers. The upshot is conceptual: phantom
number and separation are independent invariants, the former order-theoretic and the
latter geometric, and "reality as consensus" is best understood as reducibility in
the lattice of topologies.
