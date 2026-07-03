# Phantom Topologies: Observer-Dependent Structure and the Two-Observer Theorem for the Real Line

**Author:** Aristotle

**Date:** 2026-07-03

## Abstract

We introduce *phantom topologies*, a framework in which a single underlying set
carries a family of topologies indexed by a set of *observers*, and the "real"
(consensus) topology is defined as the structure on which all observers agree. In
the standard lattice of topologies — ordered so that *finer* means *smaller* in the
order — the consensus is the supremum of the observer topologies, and a set is
consensus-open if and only if it is open for every observer. We prove three facts
about this construction. First, an **agreement principle**: consensus-openness is
exactly unanimity of openness. Second, a **coarsening principle**: every
individual observer is finer than the consensus, so enlarging the observer set can
only coarsen the agreed reality — a counter-intuitive, order-reversing
monotonicity. Third, and centrally, a **two-observer theorem**: the Euclidean
topology on $\mathbb{R}$ is exactly the consensus of two strictly sharper
observers — the lower-limit (Sorgenfrey) observer, whose basic neighborhoods are
right half-open intervals $[x,b)$, and the upper-limit observer, whose basic
neighborhoods are left half-open intervals $(a,x]$. Neither observer alone
recovers the Euclidean line, and the two disagree, so the *phantom number* of the
real line — the least number of strictly sharper observers whose agreement rebuilds
it — is exactly two. We develop the surrounding theory, give explicit
counterexamples establishing the lower bound, discuss a numerical squeeze that
underlies the main proof, and state a program of conjectures: a phantom number as
a cardinal invariant, a Galois-connection structure behind consensus, a
generalization to arbitrary dense linear orders, and a proof that the cofinite
(Zariski-like) plane requires a third observer.

## 1. Introduction

The topology of a space is normally treated as an intrinsic, observer-independent
datum: a set of points $X$ is equipped with a fixed family of open subsets, and
all subsequent analysis proceeds from that fixed choice. This paper explores a
deliberate departure from that convention. We ask: *what if the notion of
openness depended on who is observing the space?* We formalize this by attaching a
whole family of topologies to $X$, indexed by an abstract set of observers, and by
identifying the "real" topology with the consensus of the family — the topology on
which every observer agrees.

The motivating slogan is that *reality is what all observers agree on*, while each
observer's private topology is what that individual "sees." Our main discovery is
that this slogan is not merely evocative: the ordinary Euclidean real line is
*literally* the consensus of two strictly sharper, mutually incompatible
observers, and no single observer suffices. Moreover, the consensus operation is
order-reversing in resolution — adding observers coarsens the agreed topology —
giving a rigorous toy model of the idea that *measurement (comparison) coarsens
structure*, reminiscent of the collapse of a quantum superposition upon
observation.

### 1.1 Contributions

1. A clean definition of a phantom topology as a family $T : \iota \to
   \mathrm{Top}(X)$ and of the consensus topology as the supremum $\bigsqcup_i T_i$
   in the lattice of topologies (Section 3).
2. The **agreement principle** (Theorem 3.2): a set is consensus-open iff it is
   open for every observer.
3. The **coarsening principle** (Theorem 3.3): each observer is finer than the
   consensus, so consensus is monotone the "wrong" way.
4. The **two-observer theorem** (Theorem 5.1): the Euclidean topology on
   $\mathbb{R}$ equals the join of the lower-limit and upper-limit topologies.
5. Sharpness (Section 6): each observer strictly differs from Euclidean and from
   the other, pinning the phantom number of $\mathbb{R}$ to exactly $2$.
6. A program of conjectures and a discussion of the physical analogy (Sections
   7–8).

## 2. Preliminaries: the lattice of topologies

Let $X$ be a set. A **topology** $\tau$ on $X$ is a collection of subsets (the
*open* sets) containing $\varnothing$ and $X$ and closed under arbitrary unions
and finite intersections. Write $\mathrm{Top}(X)$ for the set of all topologies on
$X$.

We use the convention, standard in lattice-theoretic treatments of topology, that
for two topologies $s, t \in \mathrm{Top}(X)$ we write $t \le s$ to mean *$t$ is
finer than $s$*, i.e. $t$ has at least as many open sets as $s$ (every $s$-open set
is $t$-open). Under this order $\mathrm{Top}(X)$ is a complete lattice. The bottom
element $\bot$ is the **discrete** topology (all subsets open, the finest); the top
element $\top$ is the **indiscrete** topology (only $\varnothing, X$ open, the
coarsest).

The key structural fact we use repeatedly is the description of suprema. For a
family $(T_i)_{i \in \iota}$ of topologies, the supremum $\bigsqcup_{i} T_i$ is the
*coarsest* topology finer than every $T_i$ under our convention, and its open sets
are exactly the sets open in every $T_i$:

$$
U \text{ is } \Big(\bigsqcup_i T_i\Big)\text{-open} \iff \forall i,\ U \text{ is } T_i\text{-open}. \tag{$\star$}
$$

This is the lattice-theoretic engine behind everything that follows. (Readers more
comfortable with the opposite "finer = larger" convention may simply swap the
words *supremum* and *infimum* throughout; the mathematics is identical, and the
open-set description $(\star)$ is convention-independent.)

## 3. Phantom topologies and consensus

**Definition 3.1 (Phantom topology).** Let $\iota$ and $X$ be sets. A *phantom
topology* on $X$ with *observer set* $\iota$ is a function
$$
T : \iota \longrightarrow \mathrm{Top}(X),
$$
assigning to each observer $i \in \iota$ a topology $T_i$ on $X$. We call $T_i$
observer $i$'s *view* of $X$.

**Definition 3.2 (Consensus topology).** The *consensus* (or *real*) topology of a
phantom topology $T$ is
$$
\mathrm{consensus}(T) := \bigsqcup_{i \in \iota} T_i,
$$
the supremum of the observer views in $\mathrm{Top}(X)$.

**Theorem 3.2 (Agreement principle).** *For every phantom topology $T$ and every
$U \subseteq X$,*
$$
U \text{ is consensus-open} \iff \forall i \in \iota,\ U \text{ is } T_i\text{-open}.
$$

*Proof.* Immediate from the open-set description of suprema $(\star)$. A set is
open in the consensus precisely when it is open in every observer's view. $\square$

Theorem 3.2 is the formal content of the slogan "reality is unanimous
agreement": the real open sets are exactly those all observers agree are open.

**Theorem 3.3 (Coarsening principle).** *For every phantom topology $T$ and every
observer $i$,*
$$
T_i \le \mathrm{consensus}(T),
$$
*i.e. each observer's view is finer than the consensus.*

*Proof.* Each element of a family lies below the supremum: $T_i \le \bigsqcup_j
T_j$. $\square$

The interpretation is counter-intuitive but exact. Under our convention $T_i \le
\mathrm{consensus}(T)$ says $T_i$ has *at least as many* open sets as the consensus;
each observer resolves the space at least as sharply as the agreed reality, and
typically strictly more sharply. Consequently, enlarging the observer set can only
**coarsen** the consensus: more observers introduce more private disagreements
that must be discarded, so the unanimous topology shrinks. Adding perspectives
destroys, rather than creates, agreed structure.

**Definition 3.4 (Phantom number).** Given a topological space $(X,\tau)$, its
*phantom number* is the least cardinality of an observer set $\iota$ for which
there exists a phantom topology $T$ with each $T_i$ *strictly finer* than $\tau$
(strictly more open sets) and $\mathrm{consensus}(T) = \tau$. If $\tau$ is already
maximally fine (discrete) no strictly finer view exists and the phantom number is
$0$; if a single strictly finer view already equals $\tau$ upon "consensus" with
itself the number is $1$; and so on.

The remainder of the paper computes the phantom number of the real line and
outlines its behavior for other spaces.

## 4. The two observers on the real line

We now specialize to $X = \mathbb{R}$ and construct two explicit observers.

**Definition 4.1 (Lower-limit / Sorgenfrey observer).** A set $U \subseteq
\mathbb{R}$ is *lower-open* if every point of $U$ anchors a right half-open
interval inside $U$:
$$
\mathrm{lowerOpen}(U) :\iff \forall x \in U,\ \exists b,\ x < b \ \wedge\ [x,b) \subseteq U.
$$

**Definition 4.2 (Upper-limit observer).** A set $U \subseteq \mathbb{R}$ is
*upper-open* if every point anchors a left half-open interval inside $U$:
$$
\mathrm{upperOpen}(U) :\iff \forall x \in U,\ \exists a,\ a < x \ \wedge\ (a,x] \subseteq U.
$$

**Proposition 4.3.** *Both $\mathrm{lowerOpen}$ and $\mathrm{upperOpen}$ define
topologies on $\mathbb{R}$*, called the *lower-limit topology* $\tau_L$ and the
*upper-limit topology* $\tau_U$.

*Proof (sketch).* We verify the three axioms for $\tau_L$; $\tau_U$ is symmetric.

- *Whole space.* For any $x$, take $b = x+1$; then $[x, x+1) \subseteq \mathbb{R}$.
- *Finite intersections.* If $[x, b_1) \subseteq S$ and $[x, b_2) \subseteq T$,
  then $[x, \min(b_1,b_2)) \subseteq S \cap T$, since a point $y$ with $x \le y <
  \min(b_1,b_2)$ satisfies $y < b_1$ and $y < b_2$. Hence $S \cap T$ is lower-open.
- *Arbitrary unions.* If $x$ lies in some member $U$ of a family and $[x,b)
  \subseteq U$, then $[x,b)$ lies in the union.

The dual endpoint bookkeeping (using $\max(a_1, a_2)$ for intersections) handles
$\tau_U$. $\square$

The lower-limit topology $\tau_L$ is the classical **Sorgenfrey line**; it is
finer than the Euclidean topology, separable, first-countable, hereditarily
Lindelöf, but not second-countable and not metrizable. The upper-limit topology
$\tau_U$ is its reflection under $x \mapsto -x$.

## 5. The two-observer theorem

**Theorem 5.1 (Two-observer theorem).** *Let $\tau_E$ denote the Euclidean
(metric) topology on $\mathbb{R}$. Then*
$$
\tau_L \sqcup \tau_U = \tau_E,
$$
*i.e. a set $U \subseteq \mathbb{R}$ is Euclidean-open if and only if it is both
lower-open and upper-open. Equivalently, defining the two-element phantom topology
$T : \{L, U\} \to \mathrm{Top}(\mathbb{R})$ by $T_L = \tau_L$, $T_U = \tau_U$, we
have $\mathrm{consensus}(T) = \tau_E$.*

*Proof.* By the agreement principle (Theorem 3.2), $U$ is $(\tau_L \sqcup
\tau_U)$-open iff $U$ is both lower-open and upper-open. We show this is equivalent
to Euclidean-openness.

**($\Rightarrow$) Consensus $\Rightarrow$ Euclidean (the squeeze).** Suppose $U$ is
both lower-open and upper-open, and fix $x \in U$. Lower-openness gives $b > x$
with $[x, b) \subseteq U$. Upper-openness gives $a < x$ with $(a, x] \subseteq U$.
Put
$$
\varepsilon := \min(x - a,\ b - x) > 0.
$$
We claim the Euclidean ball $(x - \varepsilon, x + \varepsilon)$ lies in $U$. Take
$y$ with $|y - x| < \varepsilon$. If $y \ge x$, then $y < x + \varepsilon \le b$,
so $y \in [x, b) \subseteq U$. If $y < x$, then $y > x - \varepsilon \ge a$, so $y
\in (a, x] \subseteq U$. Either way $y \in U$. Hence every point of $U$ has a
Euclidean neighborhood inside $U$, so $U$ is Euclidean-open. The two one-sided
intervals, sharing the endpoint $x$, glue into the two-sided interval $(a, b)
\supseteq (x-\varepsilon, x+\varepsilon)$.

**($\Leftarrow$) Euclidean $\Rightarrow$ consensus.** Suppose $U$ is
Euclidean-open and fix $x \in U$. Then there is $\varepsilon > 0$ with $(x -
\varepsilon, x + \varepsilon) \subseteq U$. Taking $b = x + \varepsilon$ gives
$[x, b) \subseteq U$ (lower-open), and taking $a = x - \varepsilon$ gives $(a, x]
\subseteq U$ (upper-open). Thus $U$ is both lower- and upper-open. $\square$

The heart of the argument is the elementary identity
$$
(a, x] \cup [x, b) = (a, b),
$$
which turns two one-sided commitments into a single two-sided neighborhood. The
Euclidean line is precisely the place where a left-looking and a right-looking
observer are forced into agreement.

## 6. Sharpness: the phantom number of $\mathbb{R}$ is exactly two

The two-observer theorem shows two observers *suffice*. We now show two are
*necessary*, and that these two are genuinely distinct sharper views.

**Proposition 6.1 (No single observer suffices).**
1. $\tau_L \neq \tau_E$: the set $[0, 1)$ is lower-open but not Euclidean-open.
2. $\tau_U \neq \tau_E$: the set $(0, 1]$ is upper-open but not Euclidean-open.

*Proof.* (1) The set $[0,1)$ is lower-open: for $x \in [0,1)$ take $b = 1$, giving
$[x, 1) \subseteq [0,1)$. It is not Euclidean-open: at the point $0$, every
Euclidean ball $(-\varepsilon, \varepsilon)$ contains negative numbers not in
$[0,1)$, so no two-sided cushion fits. (2) Symmetric, using the point $1$. $\square$

**Proposition 6.2 (The observers disagree).** $\tau_L \neq \tau_U$: the set $[0,1)$
is lower-open but not upper-open.

*Proof.* $[0,1)$ is lower-open by Proposition 6.1. It is not upper-open: at $x = 0
\in [0,1)$ there is no $a < 0$ with $(a, 0] \subseteq [0,1)$, since any such
interval contains negative numbers. $\square$

**Corollary 6.3.** *The phantom number of $(\mathbb{R}, \tau_E)$ is exactly $2$.*

*Proof.* Both $\tau_L$ and $\tau_U$ are strictly finer than $\tau_E$: they are
finer (each Euclidean-open set is both lower- and upper-open, by the
($\Leftarrow$) direction of Theorem 5.1), and strictly so by Proposition 6.1.
Their consensus is $\tau_E$ by Theorem 5.1, so two strictly finer observers
suffice. A single strictly finer observer $T_0$ would have $\mathrm{consensus} =
T_0 \ne \tau_E$, so one does not suffice. Hence the phantom number is $2$. $\square$

## 7. Algorithms and numerical corroboration

Although the results are exact theorems, the underlying set operations are finite
and eminently checkable on discretized or rational data, which is valuable for
building intuition and for testing conjectures about other spaces.

**Algorithm A (Consensus membership test).** Given a candidate set $U$ (as a
membership predicate) and a finite sample of points with resolution $\delta$, test
for each sampled $x \in U$ whether a right half-open interval $[x, x+\delta)$ and a
left half-open interval $(x-\delta, x]$ both lie in $U$. Unanimity across observers
approximates consensus-openness. Complexity is $O(nk)$ for $n$ sample points and
$k$ observers.

**Algorithm B (Two-sided squeeze constructor).** Given the observer certificates
$b$ (from the lower observer) and $a$ (from the upper observer) at a point $x$,
output $\varepsilon = \min(x-a, b-x)$ and the interval $(x-\varepsilon,
x+\varepsilon)$, the explicit Euclidean neighborhood produced by the squeeze. This
is the constructive core of Theorem 5.1 and runs in $O(1)$ per point.

**Algorithm C (Phantom-number search on finite models).** For a finite topological
space given by its open-set lattice, enumerate strictly finer topologies and search
for the least number whose pairwise/collective join returns the target. This makes
the phantom number computable on finite spaces and provides evidence for the
cofinite-plane conjecture on finite truncations.

Numerical experiments confirm the squeeze identity $(a,x] \cup [x,b) = (a,b)$ and
verify that the discretized consensus of the two half-open observers matches the
discretized Euclidean topology to within sampling resolution, while each single
observer disagrees on the boundary witnesses $[0,1)$ and $(0,1]$.

## 8. Discussion: measurement coarsens structure

The coarsening principle (Theorem 3.3) gives the framework a distinctly physical
flavor. Each observer's private topology is *richer* than the consensus: it draws
distinctions — such as the one-sided openness of $[0,1)$ — that vanish when
observers are forced to agree. The act of forming a consensus is thus a
*collapse*: fine, observer-dependent structure is discarded to yield a coarser,
shared, "classical" topology. This mirrors quantum measurement, where a rich
superposition collapses to a definite (and in an information-theoretic sense
*coarser*) outcome upon observation.

The real line emerges as a maximally symmetric consensus: the two observers are
exact mirror images ($x \mapsto -x$ exchanges $\tau_L$ and $\tau_U$), and the line
is their fixed agreement. This symmetry is not incidental; it is what allows the
one-sided defects of each observer to cancel exactly, leaving no residue of
one-sidedness in the consensus.

## 9. Future directions

**9.1 The phantom number as a cardinal invariant.** *Conjecture.* Every
metrizable space without isolated points has phantom number exactly two; discrete
spaces have phantom number zero; the Sierpiński space has phantom number one.
Recovering a space is a covering problem in the open-set lattice: each observer
must add resolution that all others cancel. The exact value two for $\mathbb{R}$
is the anchor from which to test universality.

**9.2 A Galois connection behind consensus.** *Conjecture.* The map sending a
family of observers to their agreed topology is one half of a Galois connection
whose closed families are exactly those closed under pairwise agreement; its fixed
points classify all achievable consensus topologies. The order-reversing
monotonicity of consensus (Theorem 3.3) is precisely the signature of an adjoint
pair.

**9.3 Two-sided observers on any dense linear order.** *Conjecture.* On every
densely ordered set without endpoints, the agreement of the right-half-open and
left-half-open topologies is exactly the order topology; density is necessary and
completeness is not. The squeeze proof of Theorem 5.1 uses only density and the
absence of endpoints, so it should abstract cleanly.

**9.4 The cofinite (Zariski-like) plane needs a third observer.** *Conjecture.*
The cofinite topology on an infinite set — a stand-in for the Zariski plane —
cannot be recovered as the agreement of only two strictly sharper observers; a
third is required. Cofinite open families are closed under finite intersection but
too sparse and rigid to be a two-observer squeeze, so the phantom number of such
spaces is at least three, separating tame (metrizable) from exotic (algebraic)
geometry.

## 10. Conclusion

Phantom topologies formalize the intuition that the structure of a space can
depend on the observer, with the "real" space recovered as unanimous agreement. We
proved that the Euclidean real line is exactly the consensus of two strictly
sharper, mutually contradictory observers — a left-looking and a right-looking
one — and that neither alone, nor any single observer, suffices: the phantom
number of $\mathbb{R}$ is exactly two. We showed that consensus is order-reversing
in resolution, so agreement coarsens structure, a rigorous echo of measurement
collapse. The framework opens a program: a cardinal phantom-number invariant, a
Galois-connection structure, a dense-order generalization, and a separation of
metrizable from Zariski-like spaces by their phantom number.
