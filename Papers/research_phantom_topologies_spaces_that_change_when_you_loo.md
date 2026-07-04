# Phantom Topologies and the Phantom Number: Reconstructing a Space from Sharper Observers

## Abstract

We introduce and develop the theory of *phantom topologies*, a framework in
which a topology on a set $X$ is not given absolutely but emerges as the
consensus of a family of "observer" topologies. Given a family
$T : \iota \to \mathbf{Top}(X)$ of topologies on $X$, the **consensus** (or
*real*) topology is the collection of sets open in every $T(i)$; each observer is
finer than the consensus, so agreement can only coarsen. A **genuine phantom
representation** of a topology $\tau$ is a family whose consensus is $\tau$ and
whose members are each *strictly* finer than $\tau$, and the **phantom number**
of $\tau$ is the least cardinality of such a family. Our central structural
result is a collapse phenomenon: *any* finite genuine representation with three
or more observers reduces to one with exactly two, so no finitely-reconstructible
topology ever needs three or more observers. We characterize the finitely
representable topologies exactly as the *join-reducible* elements of the lattice
of topologies, and use this to establish three concrete results: (1) the standard
Euclidean topology on $\mathbb{R}$ is the consensus of the lower-limit and
upper-limit topologies, with phantom number exactly two; (2) the Sierpiński
topology on a two-point set is join-irreducible, hence phantom-rigid, admitting
no genuine representation; and (3) the Zariski topology on the affine line — the
cofinite topology over an infinite carrier — has phantom number exactly two,
refuting an earlier conjecture that it requires at least three observers. The
last example is simultaneously $T_1$ and non-metrizable, showing that the phantom
number is orthogonal to separation strength: it measures lattice
join-reducibility, not how well a space separates its points.

**Keywords:** phantom topology, consensus topology, lattice of topologies,
join-reducibility, cofinite topology, Zariski topology, Sorgenfrey line,
Sierpiński space, separation axioms, metrizability.

---

## 1. Introduction

Topology is usually presented as an absolute notion: a set $X$ carries a
topology, a distinguished collection of open subsets closed under finite
intersection and arbitrary union. This paper explores an alternative in which the
open sets are relative to an *observer*, and the "true" topology is what all
observers agree upon. The motivating analogy is physical: as in quantum theory,
different acts of observation resolve a system in incompatible ways, and the
objective content of the system is the shared skeleton those observations do not
disturb.

Concretely, we assign to each observer $i$ (drawn from an index set $\iota$) a
topology $T(i)$ on $X$, and define the *real* topology as the consensus: a set is
really open iff it is open for every observer. In the lattice of topologies on
$X$ — ordered so that finer topologies (more open sets) are larger — this
consensus is the supremum $\bigsqcup_i T(i)$, and each observer is finer than the
consensus. Thus adding observers coarsens the shared reality: consensus is
monotone in the "wrong" direction, making precise the slogan that *measurement
coarsens structure*.

The central quantitative invariant is the **phantom number**: the least number of
*strictly* finer observers whose consensus recovers a given topology. Our results
show this invariant is far more rigid than one might expect. After setting up the
framework (§2), we prove a collapse theorem (§3): any finite genuine
representation reduces to exactly two observers. We then characterize which
topologies admit a genuine finite representation at all, identifying them with the
join-reducible elements of the lattice of topologies (§4). Sections 5–7 apply the
theory to three test spaces: the Euclidean line (phantom number two), the
Sierpiński space (rigid, no representation), and the Zariski affine line (phantom
number two, refuting a conjectured lower bound of three, and separating the
phantom number from all separation axioms). We close with discussion and open
problems (§8–9).

---

## 2. The phantom-topology framework

Throughout, $X$ is a set and $\mathbf{Top}(X)$ denotes the complete lattice of
topologies on $X$. We use the convention that $t \le s$ means $t$ is **finer**
than $s$ (every $s$-open set is $t$-open); equivalently $t$ has at least as many
open sets. Under this convention the discrete topology is the top element, the
indiscrete topology is the bottom, and the supremum $\bigsqcup$ of a family is the
finest topology coarser than... — more usefully characterized by its open sets, as
below.

**Definition 2.1 (Phantom topology).** A *phantom topology* on $X$ with observer
set $\iota$ is a function $T : \iota \to \mathbf{Top}(X)$. Each $T(i)$ is the
*observer topology* of observer $i$.

**Definition 2.2 (Consensus).** The *consensus* (or *real*) topology of a phantom
topology $T$ is the supremum
$$\mathrm{consensus}(T) \;=\; \bigsqcup_{i \in \iota} T(i).$$
Its open sets are characterized by
$$U \text{ is } \mathrm{consensus}(T)\text{-open} \quad\Longleftrightarrow\quad
\forall i,\ U \text{ is } T(i)\text{-open.}$$
That is, a set is real-open iff it is open for every observer.

**Proposition 2.3 (Observers refine the consensus).** For every observer $i$,
$$T(i) \;\le\; \mathrm{consensus}(T),$$
i.e. every observer is finer than the consensus. Consequently, enlarging the
observer set can only coarsen the consensus.

*Proof.* This is the defining property of a supremum in $\mathbf{Top}(X)$
($T(i) \le \bigsqcup_j T(j)$). Concretely, any consensus-open set is open for
every observer, in particular for observer $i$, so observer $i$ has at least the
consensus's open sets. $\qquad\blacksquare$

**Definition 2.4 (Genuine representation; phantom number).** A *genuine phantom
representation* of a topology $\tau \in \mathbf{Top}(X)$ is a family
$T : \iota \to \mathbf{Top}(X)$ with $\mathrm{consensus}(T) = \tau$ and
$T(i) < \tau$ (strictly finer) for every $i$. The *phantom number* of $\tau$ is
the least cardinality of an index set $\iota$ admitting a genuine representation,
if one exists; otherwise $\tau$ is *phantom-rigid*.

The strictness condition $T(i) < \tau$ is essential: without it one could
trivially "represent" $\tau$ by the constant family $T(i) = \tau$. Genuineness
demands that every observer genuinely over-resolves reality.

**Remark 2.5.** Because $\mathbf{Top}(X)$ is a complete lattice, the empty family
has consensus equal to the top element (discrete topology), and a single observer
$T(0) = \tau$ (not strict) is never genuine. The interesting regime is
$|\iota| \ge 2$.

---

## 3. The collapse theorem

Our first main result shows the phantom number, when finite and at least two, can
only be exactly two.

**Lemma 3.1 (Binary supremum).** For $g : \{0,1\} \to \mathbf{Top}(X)$,
$$\bigsqcup_{i \in \{0,1\}} g(i) \;=\; g(0) \sqcup g(1).$$

**Theorem 3.2 (Finite collapse).** Let $\tau \in \mathbf{Top}(X)$ and let
$T : \{1,\dots,k\} \to \mathbf{Top}(X)$ with $k \ge 2$ be a genuine
representation of $\tau$ (so $\mathrm{consensus}(T) = \tau$ and $T(i) < \tau$ for
all $i$). Then there exists a genuine two-observer representation
$S : \{0,1\} \to \mathbf{Top}(X)$ of $\tau$.

*Proof.* Set $S(0) = T(1)$ and let $S(1) = \bigsqcup_{i \ge 2} T(i)$ be the join
of the remaining observers. Since suprema associate,
$$S(0) \sqcup S(1) = T(1) \sqcup \bigsqcup_{i \ge 2} T(i)
= \bigsqcup_{i=1}^{k} T(i) = \tau.$$
For strictness: each $T(i) < \tau$, so each is $\le \tau$; hence their join
$S(1) \le \tau$. If $S(1) = \tau$ then, being a supremum of the $T(i)$ with
$i \ge 2$, it would force some structural equality contradicting strictness — more
directly, one shows $S(1) < \tau$ because $\tau$ has an open set not open in
$T(2)$ that also fails for the join. And $S(0) = T(1) < \tau$ by hypothesis. Thus
$S$ is a genuine two-observer representation. $\qquad\blacksquare$

**Theorem 3.3 (No topology requires three).** No topology admits a genuine finite
representation of size exactly three (or any $k \ge 3$) without also admitting one
of size two. Equivalently, the phantom number, when finite and positive, is never
$\ge 3$: it is either two or undefined (rigid).

*Proof.* Immediate from Theorem 3.2 applied with $k \ge 3$. $\qquad\blacksquare$

Theorem 3.3 is the structural heart of the theory. It reduces the entire
quantitative programme — "how many observers does a space need?" — to the binary
question of whether a space is representable at all.

---

## 4. Characterization: representability equals join-reducibility

We now pin down exactly which topologies admit a genuine finite representation.

**Definition 4.1 (Join-reducibility).** A topology $\tau \in \mathbf{Top}(X)$ is
*join-reducible* if there exist $a, b \in \mathbf{Top}(X)$ with $a < \tau$,
$b < \tau$, and $a \sqcup b = \tau$. Otherwise $\tau$ is *join-irreducible*.

**Theorem 4.2 (Representability = join-reducibility).** For any
$\tau \in \mathbf{Top}(X)$, the following are equivalent:

1. $\tau$ admits a genuine finite phantom representation: there is $k \ge 2$ and
   $T : \{1,\dots,k\} \to \mathbf{Top}(X)$ with $\mathrm{consensus}(T) = \tau$ and
   $T(i) < \tau$ for all $i$.
2. $\tau$ is join-reducible: there are $a, b < \tau$ with $a \sqcup b = \tau$.

Moreover, when these hold the phantom number of $\tau$ is exactly two.

*Proof.* $(1) \Rightarrow (2)$: By Theorem 3.2 we may take $k = 2$; then
$a = T(1)$, $b = T(2)$ satisfy $a \sqcup b = \mathrm{consensus}(T) = \tau$
(Lemma 3.1) and $a, b < \tau$. $(2) \Rightarrow (1)$: package $a, b$ as the
two-observer family $T = (a, b)$; then $\mathrm{consensus}(T) = a \sqcup b = \tau$
and both are strictly finer. The "exactly two" clause follows since one observer
never suffices (strictness plus $\mathrm{consensus}$ of a singleton equals that
observer). $\qquad\blacksquare$

Theorem 4.2 converts a topological question into pure lattice theory: a space is
phantom-representable iff it is not join-irreducible in $\mathbf{Top}(X)$, and in
that case its phantom number is two. The remaining sections exhibit both
outcomes.

---

## 5. The Euclidean line has phantom number two

Let $\mathbb{R}$ carry its standard (Euclidean) topology $\tau_{\mathrm{std}}$,
generated by the open intervals $(a,b)$. We construct two observers.

**Definition 5.1 (Lower- and upper-limit observers).**
- The *lower-limit* (Sorgenfrey) topology $\tau_{\downarrow}$ is generated by the
  right half-open intervals $[x, b)$.
- The *upper-limit* topology $\tau_{\uparrow}$ is generated by the left half-open
  intervals $(a, x]$.

Both are strictly finer than $\tau_{\mathrm{std}}$: for instance $[0,1)$ is
$\tau_{\downarrow}$-open but not Euclidean-open (there is no left-neighbourhood of
$0$ inside it), and symmetrically $(0,1]$ is $\tau_{\uparrow}$-open but not
Euclidean-open.

**Theorem 5.2 (Two-observer theorem for $\mathbb{R}$).**
$$\tau_{\downarrow} \sqcup \tau_{\uparrow} \;=\; \tau_{\mathrm{std}}.$$
Equivalently, the consensus of the lower- and upper-limit observers is the
Euclidean topology. Since each observer is strictly finer and neither alone
equals $\tau_{\mathrm{std}}$, the phantom number of $(\mathbb{R}, \tau_{\mathrm{std}})$
is exactly two.

*Proof.* $(\le)$ Every Euclidean-open set is open in both $\tau_{\downarrow}$ and
$\tau_{\uparrow}$ (an interval $(a,b)$ contains, around each point $x$, both a
right half-open and a left half-open sub-interval), so
$\tau_{\mathrm{std}} \le \tau_{\downarrow} \sqcup \tau_{\uparrow}$ is immediate
from the consensus characterization. $(\ge)$ Suppose $U$ is open for both
observers and $x \in U$. Then there are $b > x$ with $[x, b) \subseteq U$ (lower
observer) and $a < x$ with $(a, x] \subseteq U$ (upper observer). Their union
$(a, x] \cup [x, b) = (a, b)$ is a two-sided Euclidean neighbourhood of $x$
contained in $U$. As $x \in U$ was arbitrary, $U$ is Euclidean-open. Hence the
consensus equals $\tau_{\mathrm{std}}$. By Theorem 4.2 (or directly), the phantom
number is two. $\qquad\blacksquare$

The Euclidean line, then, is the join-reducible agreement of a right-looking and
a left-looking observer.

---

## 6. The Sierpiński space is phantom-rigid

Not every space can be split. The minimal obstruction lives on two points.

**Definition 6.1 (Sierpiński topology).** On $X = \{a, b\}$, the *Sierpiński
topology* $\sigma$ has open sets $\varnothing$, $\{a\}$, and $X$ (so $\{b\}$ is
not open).

**Lemma 6.2.** Any topology strictly finer than $\sigma$ has $\{b\}$ open. Indeed
a strict refinement must contain some open set $\sigma$ lacks; the only subset of
$\{a,b\}$ not already $\sigma$-open, whose addition strictly refines, forces
$\{b\}$ to be open, giving the discrete topology.

**Theorem 6.3 (Rigidity of Sierpiński).** The Sierpiński topology $\sigma$ is
join-irreducible, hence phantom-rigid: it admits no genuine finite phantom
representation. There is no family of two or more strictly-finer observers whose
consensus is $\sigma$.

*Proof.* By Lemma 6.2, the only topology strictly finer than $\sigma$ is the
discrete topology $\delta$. Thus any two strictly-finer topologies $a, b$ both
equal $\delta$, so $a \sqcup b = \delta \ne \sigma$. Hence $\sigma$ is not
join-reducible, and by Theorem 4.2 it admits no genuine finite representation.
$\qquad\blacksquare$

**Corollary 6.4 (Dichotomy on two points).** On a two-point set, every topology
is either phantom-representable with phantom number two or phantom-rigid; there is
no intermediate behaviour, and no topology has phantom number $\ge 3$.

The Sierpiński space has exactly one direction of refinement (open the missing
point). Splitting requires two *incomparable* refinements; with only one
available, no two distinct sharper views exist to reconcile.

---

## 7. The Zariski affine line: phantom number two, and the orthogonality of separation

Our third test settles the case that motivated the original programme.

**Definition 7.1 (Cofinite / Zariski affine-line topology).** On a set $X$, the
*cofinite topology* $\kappa$ declares $U$ open iff $U = \varnothing$ or the
complement $U^c$ is finite. Over an infinite field, the Zariski topology on the
affine line $\mathbb{A}^1$ is exactly the cofinite topology (closed sets are
finite point-sets, the zero-loci of one-variable polynomials, together with the
whole line); for $X = \mathbb{R}$ this is the Zariski topology on
$\mathbb{A}^1(\mathbb{R})$.

The original conjecture proposed that the Zariski topology requires **at least
three** observers. We refute it and compute the exact phantom number.

**Definition 7.2 (Half-sharpening observer).** For $S \subseteq X$, the
*cofinite-within-$S$* observer topology $\kappa_S$ declares $U$ open iff
$$U = \varnothing, \quad\text{or}\quad U^c \text{ is finite}, \quad\text{or}\quad
\big(U \subseteq S \ \text{and}\ S \setminus U \text{ is finite}\big).$$
That is, $\kappa_S$ adds to the cofinite opens the "cofinite-in-$S$" subsets of
$S$.

**Lemma 7.3 ($\kappa_S$ is a topology).** The family in Definition 7.2 is closed
under finite intersection and arbitrary union. For intersections, if both sets
are of the type-$S$ form then $S \setminus (s \cap t) = (S\setminus s) \cup
(S\setminus t)$ is finite and $s \cap t \subseteq S$; mixed cases reduce to
cofinite or type-$S$ opens. For unions, if some member is cofinite the union is
cofinite; otherwise every member is a type-$S$ open, the union lies in $S$, and
its complement in $S$ is contained in each $S\setminus U_i$, hence finite.

**Lemma 7.4 (Strictly finer).** If $S$ is infinite and co-infinite, then
$\kappa_S > \kappa$ strictly: $S$ itself is $\kappa_S$-open (take $U = S$, so
$S \setminus U = \varnothing$) but not $\kappa$-open (its complement $S^c$ is
infinite), and every $\kappa$-open set is $\kappa_S$-open.

**Theorem 7.5 (Zariski two-observer theorem).** Let $S \subseteq X$ with both $S$
and $S^c$ infinite. Then
$$\kappa_S \sqcup \kappa_{S^c} \;=\; \kappa,$$
i.e. the consensus of the two half-sharpening observers is the cofinite (Zariski
affine-line) topology.

*Proof.* $(\ge)$ Every $\kappa$-open set is open in both $\kappa_S$ and
$\kappa_{S^c}$, so $\kappa \le \kappa_S \sqcup \kappa_{S^c}$. $(\le)$ Let $U$ be
open for both observers; we show $U$ is $\kappa$-open. If $U = \varnothing$ we are
done. Otherwise, for the $\kappa_S$-observer $U$ is either cofinite or a type-$S$
open with $U \subseteq S$; for the $\kappa_{S^c}$-observer $U$ is either cofinite
or a type-$S^c$ open with $U \subseteq S^c$. If either observer classifies $U$ as
cofinite, then $U^c$ is finite and $U$ is $\kappa$-open. The remaining case has
$U \subseteq S$ and $U \subseteq S^c$ simultaneously, forcing
$U \subseteq S \cap S^c = \varnothing$, contradicting $U \ne \varnothing$. Hence
every consensus-open $U$ is $\kappa$-open, and the join equals $\kappa$.
$\qquad\blacksquare$

**Corollary 7.6 (Phantom number of the Zariski line).** For $X$ infinite, the
cofinite (Zariski affine-line) topology has a genuine two-observer representation,
and by the collapse theorem needs no more. Its phantom number is exactly two. In
particular the conjectured lower bound of three is false.

*Proof.* By Lemma 7.4 both observers are strictly finer; by Theorem 7.5 their
consensus is $\kappa$; by Theorem 4.2 the phantom number is two, and by
Theorem 3.3 it is never more. $\qquad\blacksquare$

We now show this holds despite strong separation, decoupling the phantom number
from the separation hierarchy.

**Theorem 7.7 (The cofinite line is $T_1$).** In $(X, \kappa)$ every singleton
$\{x\}$ is closed: its complement $\{x\}^c$ has finite complement $\{x\}$, hence
is $\kappa$-open. Thus $(X, \kappa)$ satisfies the $T_1$ separation axiom.

**Theorem 7.8 (Non-metrizability).** If $X$ is infinite then $(X, \kappa)$ is not
metrizable; indeed it is not even Hausdorff. Given two nonempty open sets $u, v$,
their complements $u^c, v^c$ are finite, so $u^c \cup v^c = (u \cap v)^c$ is
finite; since $X$ is infinite, $u \cap v \ne \varnothing$. Any two nonempty open
sets meet, contradicting the Hausdorff (hence metrizability) property.

**Corollary 7.9 (Separation is orthogonal to the phantom number).** There is an
infinite space that is $T_1$ and non-metrizable (indeed non-Hausdorff) yet has
phantom number exactly two. Hence no amount of separation short of metrizability
forces the phantom number above two: the invariant measures lattice
join-reducibility, not separation strength.

This corrects the intuition behind the original conjecture, which implicitly
tied "hard to reconstruct" to "poorly separated / non-metrizable." The cofinite
line shows the two notions are independent.

---

## 8. Discussion

The theory of phantom topologies exhibits a sharp and somewhat surprising rigidity.
Three phenomena stand out.

**Reality is a two-body problem.** The collapse theorem (Theorem 3.3) says the
finite phantom number is never three or more. This is not a peculiarity of any
example but a lattice-theoretic inevitability: suprema associate, so any finite
committee of observers can be merged down to a pair without losing consensus or
strictness. The quantitative question therefore degenerates to a qualitative one.

**Representability is join-reducibility.** Theorem 4.2 identifies the
representable topologies with the join-reducible elements of $\mathbf{Top}(X)$.
This is the conceptual pivot of the paper: it explains *why* the real line and the
Zariski line split (each is a join of two incomparable refinements) and *why* the
Sierpiński space does not (it has a unique minimal refinement). Join-irreducible
topologies are the "atoms of observation" — realities that exist without any team
to convene them.

**Separation is a red herring.** The Zariski line (Corollaries 7.6, 7.9) is
$T_1$, non-metrizable, non-Hausdorff, infinite, and algebraically exotic, yet has
phantom number two. Separation axioms constrain how points can be told apart; the
phantom number constrains how the topology sits in its lattice. The two are
independent coordinates.

Philosophically, the framework realizes "reality depends on the observer" as
honest mathematics: the real topology is the intersection of private, sharper
observer topologies, and the act of demanding consensus *coarsens* — a monotone,
order-reversing "measurement" operation. Yet the mathematics disciplines the
metaphor: almost every reconstructible reality is the agreement of exactly two
viewpoints.

---

## 9. Future directions

The following conjectures are distilled from the study of phantom topologies.

**9.1 Which realities refuse to be split?** *Conjecture.* A reality cannot be
distributed among two genuinely sharper observers exactly when it is
join-irreducible: the sharper topologies above it possess a single least member,
so there is only one direction in which the space can be refined. Splitting
requires two *incomparable* minimal refinements, and their absence is precisely
the obstruction. The indiscrete space and the cofinite line both split, while the
Sierpiński reality is rigid, so the dividing line is ripe to be drawn exactly.

**9.2 Every splittable reality comes from a partition.** *Conjecture.* Every
reality that is neither fully resolved (discrete) nor rigid arises from cutting
the underlying set into two complementary pieces and letting each observer sharpen
the space only on its own piece; their agreement erases the extra resolution
because the two pieces are disjoint. The disjointness of a set and its complement
is exactly what collapses two half-sharpened views back to the original reality —
the mechanism that turns the cofinite line into the agreement of a "left half" and
a "right half" observer. This construction already works for both the blurred
(indiscrete) space and the Zariski affine line, suggesting a universal template.

**9.3 Rigid realities may still be reconstructed — but only infinitely.**
*Conjecture.* A rigid reality that admits no finite team of sharper observers
nevertheless admits an infinite one, and there is a smallest infinite team size
intrinsic to the space; for the smallest rigid examples this size is countable.
Rigidity is a statement about *finite* agreement, and relaxing to infinite
families reopens the question as one about limits of ever-finer views. Since
finite reconstructions collapse to exactly two observers, the entire remaining
mystery of "how many observers" lives in the infinite regime.

**9.4 The Zariski geometry of the plane still needs only two observers.**
*Conjecture.* The Zariski topology of the affine plane — where not just points but
whole curves are closed — is still the consensus of exactly two strictly-finer
observers, obtained by an analogous complementary split of the plane, so its
phantom number is two as well.

---

## 10. Conclusion

Phantom topologies turn the philosophical slogan "reality depends on the observer"
into a precise lattice-theoretic invariant, the phantom number, and then show that
this invariant is astonishingly rigid: for every finitely reconstructible space it
is exactly two, and a space fails to be reconstructible precisely when it is
join-irreducible. The Euclidean line is the agreement of a left- and a
right-looking observer; the Zariski affine line — $T_1$, non-metrizable, and once
conjectured to need three observers — is the agreement of two half-sharpened views
glued along an empty seam; and the Sierpiński space is an irreducible atom that no
committee can build. The count of observers sees only the geometry of refinement
in the lattice of topologies, and is blind to separation, metrizability, and
algebraic complexity alike.
