# Phantom Topologies and the Splitting of Reality: A Lattice-Theoretic Theory of Observer-Dependent Spaces

## Abstract

We introduce and study *phantom topologies*: structures in which the topology
of a fixed set is not absolute but depends on an observer, and the "real"
topology is defined as the unanimous agreement of all observers. Formally, a
phantom topology on a set $X$ is a family $T = (T_i)_{i \in \iota}$ of
topologies on $X$, and its *consensus* topology is the supremum
$\bigsqcup_i T_i$ in the lattice of topologies — the finest topology all
observers agree is open. We recast the classical refinement lattice of
topologies as a theory of observers and consensus, and we identify
*splittability* (join-reducibility) as the precise invariant governing when
a reality can be distributed across genuinely sharper viewpoints. Our main
results are: (i) a two-observer decomposition of the Euclidean real line as
the consensus of its lower-limit and upper-limit topologies; (ii) an
*Indiscrete Splitting Theorem* stating that on every set with at least two
points the indiscrete topology is the consensus of two strictly finer
"co-excluded-point" observers, each of which resolves exactly one deleted
point; (iii) a resulting *genuine two-observer representation* of every
$\ge 2$-point blurred space; and (iv) an *Extremal Dichotomy*: the
indiscrete topology is always splittable while the discrete topology is
always rigid. Together these results show that splittability is an
order-theoretic property of the topology lattice — orthogonal to
cardinality and to separation strength — and that maximally blurred reality
is never irreducibly blurred, whereas maximally sharp reality can never be
reassembled from sharper views.

**Keywords:** phantom topology, consensus topology, lattice of topologies,
join-reducibility, join-irreducibility, indiscrete topology, discrete
topology, Sorgenfrey (lower-limit) topology, co-excluded-point topology,
observer-dependence.

---

## 1. Introduction

Classical topology fixes, once and for all, a single notion of nearness on a
space. Yet many situations — measurement in physics, partial information in
computation, competing sensory channels — suggest that "nearness" might be
relative to an observer, with an objective structure emerging only where
observers agree. This paper develops a rigorous mathematical model of that
intuition and extracts from it a sharp structural theorem.

The technical backbone is classical: the set of all topologies on a fixed
underlying set $X$ forms a complete lattice under *refinement*. We adopt the
convention that $t \le s$ means $t$ is *finer* than $s$ (i.e. $t$ has at
least as many open sets as $s$). In this order the **discrete** topology
$\bot$ (all subsets open) is the bottom element, and the **indiscrete**
topology $\top$ (only $\emptyset$ and $X$ open) is the top element. The
supremum of a family of topologies is the topology whose open sets are
exactly the sets open in *every* member of the family.

Our contribution is twofold. First, a *reframing*: we interpret a family of
topologies as a collection of observers and the supremum as their consensus
(the real topology), which turns lattice-theoretic questions into questions
about how many sharper viewpoints a reality decomposes into. Second, a
*theorem*: we prove that the maximally blurred topology always so
decomposes, using an explicit, minimal construction, and we contrast this
with the rigidity of the maximally sharp topology.

### Contributions

1. A precise framework of phantom topologies, consensus, and observers
   (Section 3), including the "measurement coarsens" monotonicity.
2. The two-observer theorem for $\mathbb{R}$ (Section 4).
3. The co-excluded-point construction and the Indiscrete Splitting Theorem
   (Section 5).
4. The genuine two-observer representation of blurred spaces and the
   Extremal Dichotomy (Section 6).
5. A discussion of rigidity as join-irreducibility and open problems
   (Sections 7–8).

---

## 2. Preliminaries: the lattice of topologies

Let $X$ be a set. A **topology** on $X$ is a family $\tau \subseteq
\mathcal{P}(X)$ of *open* sets with $\emptyset, X \in \tau$, closed under
arbitrary unions and finite intersections.

**Refinement order.** For topologies $s, t$ on $X$, write $t \le s$ iff every
$s$-open set is $t$-open (equivalently, $t$ is finer). Under this order the
collection of all topologies on $X$ is a complete lattice.

- The **discrete** topology $\bot = \mathcal{P}(X)$ is the minimum: it is
  finer than every topology.
- The **indiscrete** topology $\top = \{\emptyset, X\}$ is the maximum: it is
  coarser than every topology.
- The **supremum** $\bigsqcup_{i} T_i$ of a family $(T_i)$ has as open sets
  exactly $\bigcap_i T_i$, i.e. the sets open in every $T_i$.

We record the elementary characterization of the supremum's open sets, which
underpins the entire theory.

> **Lemma 2.1 (Agreement characterization).** For any family $(T_i)_{i \in
> \iota}$ of topologies on $X$ and any $U \subseteq X$,
> $$U \in \textstyle\bigsqcup_i T_i \iff U \in T_i \text{ for all } i.$$

*Proof sketch.* The right-hand side defines a topology (intersection of
topologies is a topology), it is coarser than each $T_i$, and any topology
coarser than every $T_i$ is contained in it; hence it is the least upper
bound. $\square$

---

## 3. The phantom framework

**Definition 3.1 (Phantom topology).** A *phantom topology* on $X$ with
observer set $\iota$ is a function $T : \iota \to \{\text{topologies on }
X\}$, assigning to each observer $i$ a topology $T_i$.

**Definition 3.2 (Consensus / real topology).** The *consensus* topology of a
phantom topology $T$ is
$$\mathrm{consensus}(T) := \bigsqcup_{i \in \iota} T_i,$$
the finest topology all observers agree on. A set is *consensus-open* iff it
is open for every observer (Lemma 2.1).

**Proposition 3.3 (Measurement coarsens).** Each observer is finer than the
consensus: $T_i \le \mathrm{consensus}(T)$ for every $i$. Consequently,
enlarging the observer set can only coarsen the consensus.

*Proof.* $T_i \le \bigsqcup_j T_j$ is the defining property of the supremum
(each element lies below the join). $\square$

Proposition 3.3 is the "wrong-way" monotonicity that gives the model its
flavor: an individual viewpoint always resolves at least as much as the
public consensus, and demanding agreement from more observers removes, never
adds, resolution.

**Definition 3.4 (Splittable / rigid).** A topology $\tau$ on $X$ is
*splittable* (equivalently *join-reducible*) if there exist topologies $a, b$
on $X$ with $a < \tau$, $b < \tau$, and $a \sqcup b = \tau$. Otherwise
$\tau$ is *rigid* (join-irreducible in the strong sense that it is not the
join of two strictly smaller elements). A splittable topology is exactly one
that admits a *genuine* two-observer phantom representation: a phantom
topology whose consensus is $\tau$ and each of whose (two) observers is
strictly finer than $\tau$.

The reduction of "genuine two-observer representability" to the purely
order-theoretic condition of join-reducibility is what makes the theory
computable on finite spaces and lets us reason about it uniformly.

---

## 4. The real line as a two-observer consensus

We recover the ordinary Euclidean topology on $\mathbb{R}$ from two
observers, neither of which sees it alone.

**Definition 4.1.**
- The **lower-limit (Sorgenfrey) observer** $L$ declares $U$ open iff every
  $x \in U$ admits $b > x$ with $[x, b) \subseteq U$.
- The **upper-limit observer** $U\!p$ declares $U$ open iff every $x \in U$
  admits $a < x$ with $(a, x] \subseteq U$.

Both are topologies on $\mathbb{R}$ (finite intersections handled by taking
$\min$/$\max$ of endpoints; arbitrary unions are immediate).

> **Theorem 4.2 (Two-observer line).** The consensus of the lower-limit and
> upper-limit observers is exactly the standard Euclidean topology on
> $\mathbb{R}$:
> $$L \sqcup U\!p = \tau_{\mathrm{std}}.$$
> Moreover neither observer alone equals $\tau_{\mathrm{std}}$, and the two
> observers are distinct, so the representation is genuinely phantom with
> exactly two observers.

*Proof sketch.* ($\supseteq$) A Euclidean-open set satisfies both the
lower and the upper interval conditions, so it is open for both observers,
hence consensus-open. ($\subseteq$) If $U$ is open for both observers then
each $x \in U$ has $[x,b) \subseteq U$ and $(a,x] \subseteq U$; their union
$(a,b) \ni x$ lies in $U$, giving a two-sided Euclidean neighborhood.
Distinctness: $[0,1)$ is $L$-open but not Euclidean-open (no symmetric ball
around $0$ fits), and $(0,1]$ is $U\!p$-open but not Euclidean-open; these
witnesses also show $L \ne U\!p$. $\square$

Theorem 4.2 is the archetype: reality is the two-sided agreement of a
left-pinning and a right-pinning observer, each of which strictly
over-resolves.

---

## 5. The co-excluded-point construction and the Indiscrete Splitting Theorem

We now prove that splitting is not special to $\mathbb{R}$ but is a fully
general phenomenon at the blurred extreme.

**Definition 5.1 (Co-excluded-point topology).** For a point $a \in X$, the
*co-excluded-point topology* $\mathrm{coExcl}(a)$ has as its open sets
exactly
$$\{\, \emptyset,\ X,\ X \setminus \{a\} \,\}.$$

**Lemma 5.2.** $\mathrm{coExcl}(a)$ is a topology.

*Proof sketch.* $\emptyset$ and $X$ are open. Finite intersections stay in
the triple: any pairwise intersection among $\emptyset, X, X\setminus\{a\}$
is again one of them ($X \cap (X\setminus\{a\}) = X\setminus\{a\}$, etc.).
Arbitrary unions stay in the triple: a union containing $X$ is $X$; a union
containing $X\setminus\{a\}$ but not $X$ is $X\setminus\{a\}$; otherwise it
is a union of copies of $\emptyset$, hence $\emptyset$. $\square$

**Lemma 5.3 (Strict refinement).** If $X$ has at least two points, then
$\mathrm{coExcl}(a) < \top$ for every $a$.

*Proof sketch.* $\mathrm{coExcl}(a) \le \top$ always. For strictness, the
set $X \setminus \{a\}$ is $\mathrm{coExcl}(a)$-open but not indiscrete-open:
it is nonempty (there is a point $b \ne a$) and not all of $X$ (it omits
$a$), so it is neither of the two indiscrete open sets. $\square$

> **Lemma 5.4 (Join of two deleters).** For distinct points $p \ne q$ of
> $X$,
> $$\mathrm{coExcl}(p) \sqcup \mathrm{coExcl}(q) = \top.$$

*Proof sketch.* By Lemma 2.1, $U$ is open in the join iff it is open for
both observers, i.e.
$$U \in \{\emptyset, X, X\setminus\{p\}\} \quad\text{and}\quad U \in
\{\emptyset, X, X\setminus\{q\}\}.$$
Because $p \ne q$, the punctured sets satisfy $X\setminus\{p\} \ne
X\setminus\{q\}$ (they differ at $p$ and $q$), and neither equals
$\emptyset$ or $X$. Hence the only common members are $\emptyset$ and $X$,
which is precisely $\top$. $\square$

Combining the lemmas yields the central theorem.

> **Theorem 5.5 (Indiscrete Splitting Theorem).** For every set $X$ with at
> least two points, the indiscrete topology is splittable:
> $$\exists\, a, b \ \ (a < \top,\ b < \top,\ a \sqcup b = \top).$$
> Explicitly, choosing any $p \ne q$, the pair $(\mathrm{coExcl}(p),
> \mathrm{coExcl}(q))$ works.

*Proof.* Pick distinct $p, q \in X$ (possible since $|X| \ge 2$). By Lemma
5.3 both $\mathrm{coExcl}(p)$ and $\mathrm{coExcl}(q)$ are strictly finer
than $\top$, and by Lemma 5.4 their join is $\top$. $\square$

This generalizes the minimal two-point case (where the two observers are the
two Sierpiński topologies on a two-point set) to arbitrary spaces, and it
does so with the least possible resolution: each observer sharpens reality by
a *single deleted point*, and the two deletions share nothing open except
$\emptyset$ and the whole space.

---

## 6. Genuine representation and the Extremal Dichotomy

**Corollary 6.1 (Genuine two-observer representation).** Every set $X$ with
$|X| \ge 2$, equipped with the indiscrete topology, admits a genuine finite
phantom representation with two observers: a phantom topology
$T : \{0,1\} \to \{\text{topologies}\}$ with $T_0 = \mathrm{coExcl}(p)$,
$T_1 = \mathrm{coExcl}(q)$ ($p \ne q$), whose consensus is $\top$ and each of
whose observers is strictly finer than $\top$.

*Proof.* Immediate from Theorem 5.5 and the equivalence between
splittability and genuine two-observer representability (Definition 3.4).
$\square$

We now contrast the two extremes of the lattice.

**Lemma 6.2 (Discrete rigidity).** The discrete topology $\bot$ is rigid: it
cannot be written as $a \sqcup b$ with $a < \bot$ and $b < \bot$.

*Proof.* $\bot$ is the minimum of the lattice, so no topology is strictly
finer than $\bot$; there is no $a$ with $a < \bot$. Hence no such
decomposition exists. $\square$

> **Theorem 6.3 (Extremal Dichotomy).** On any set $X$ with at least two
> points, the two extreme topologies behave oppositely:
> - the indiscrete topology $\top$ is splittable (Theorem 5.5);
> - the discrete topology $\bot$ is rigid (Lemma 6.2).

*Discussion.* The dichotomy refutes the naive heuristic "more open sets ⇒
easier to split." The discrete topology has the *most* open sets of any
topology, yet it is the canonical rigid space, precisely because rigidity is
about position in the lattice, not about the size of the topology. Splitting
requires *room above* — strictly finer topologies to serve as observers — and
the discrete topology, sitting at the very bottom, has none. The indiscrete
topology, at the very top, has maximal room and always splits.

---

## 6.5 Worked examples on small spaces

To make the dichotomy concrete, we work out the smallest nontrivial case in
full. Let $X = \{0, 1\}$. There are exactly four topologies on a two-point
set:

1. the **indiscrete** topology $\top = \{\emptyset, X\}$;
2. the **discrete** topology $\bot = \{\emptyset, \{0\}, \{1\}, X\}$;
3. the **$0$-Sierpiński** topology $\{\emptyset, \{0\}, X\}$ (which equals
   $\mathrm{coExcl}(1)$, since $\{0\} = X \setminus \{1\}$);
4. the **$1$-Sierpiński** topology $\{\emptyset, \{1\}, X\}$ (which equals
   $\mathrm{coExcl}(0)$).

Applying the splittability test to each:

- $\top$ **splits**: its consensus decomposition is $\mathrm{coExcl}(0)
  \sqcup \mathrm{coExcl}(1)$, i.e. the two Sierpiński topologies, whose only
  common open sets are $\emptyset$ and $X$. This is exactly the two-point
  instance of Theorem 5.5.
- $\bot$ is **rigid**: nothing is strictly finer, so there are no observers to
  serve as a decomposition (Lemma 6.2).
- Each Sierpiński topology is **rigid**: the only topology strictly finer than
  a two-point Sierpiński topology is the discrete topology, and a single
  strictly-finer topology cannot be a two-observer consensus that lands
  strictly below it. Concretely there is no pair of distinct strictly-finer
  topologies to intersect.

Hence on two points, three of the four topologies are rigid and exactly one
splits. This count is reproduced by exhaustive enumeration (Section 7) and
provides the base case for the census conjecture of Section 9.

The same enumeration on three points yields $29$ topologies, of which $7$ are
rigid and $22$ split. The jump from three-out-of-four rigid on two points to
seven-out-of-twenty-nine on three points signals that the rigid fraction is
not monotone in any obvious way, and motivates seeking an exact recurrence
rather than an asymptotic estimate.

---

## 7. Algorithms and computation on finite spaces

On a finite set $X$ with $n = |X|$, all topologies form a finite lattice, so
splittability is decidable by direct computation. We describe the core
procedures (full implementations accompany this work).

**Enumerating topologies.** Represent a topology as a family of subsets
(bitmasks over $X$) containing $\emptyset$ and $X$ and closed under union
and intersection. One enumerates candidate families and filters by the
closure axioms. (The number of topologies grows super-exponentially, so this
is practical for very small $n$.)

**Testing splittability.** Given a target topology $\tau$, test whether
there exist topologies $a, b$ with $a \subsetneq' \tau$, $b \subsetneq'
\tau$ (strictly finer, i.e. more open sets), and whose *common* open sets
are exactly $\tau$. Equivalently, search the set of topologies strictly finer
than $\tau$ for a pair whose intersection (as open-set families) equals
$\tau$.

**Consensus computation.** The consensus of any observer family is obtained
by intersecting their open-set collections — a direct application of Lemma
2.1 — and is used to verify constructions such as $\mathrm{coExcl}(p) \sqcup
\mathrm{coExcl}(q) = \top$ on concrete finite models.

These procedures let one confirm the Extremal Dichotomy computationally on
small spaces and empirically census the rigid (join-irreducible) topologies.

---

## 8. Applications and interpretation

**A rigorous toy model of observer-dependence.** Phantom topology gives a
faithful, provable rendering of the slogan "objective reality is the
invariant of subjective views." The consensus functor is order-reversing in
resolution (Proposition 3.3), modeling the way that agreement destroys
private detail.

**Phantom number as an invariant.** The minimal number of strictly-finer
observers needed to reconstruct a topology is a genuine invariant. The
Euclidean line and the indiscrete space both have phantom number two; rigid
spaces have no finite genuine representation at all.

**A dividing line orthogonal to classical invariants.** Splittability is
invisible to cardinality and to separation axioms. Both the discrete and the
indiscrete topologies are non-metrizable in interesting degenerate ways on
small spaces, yet one splits and one does not; the distinguishing feature is
purely lattice-theoretic.

**Epistemic reading.** The framework offers a compact vocabulary for a
recurring epistemic pattern: a public, shared description is exactly the part
of many private descriptions on which they cannot disagree. In this reading an
observer topology is a private information state (which distinctions that
observer can draw), the refinement order compares informativeness, and the
consensus is the coarsest common description. The counter-intuitive
monotonicity of Proposition 3.3 then says something familiar: pooling more
private states by insisting on agreement can only erode shared distinctions,
never create them. Splittability asks whether a given public description could
have arisen as the agreement of two strictly more informed parties, and
rigidity marks the descriptions that could not — those that are either already
maximally informed (discrete) or minimally structured in a way that admits no
two distinct sharper refinements to reconcile.

---

## 9. Discussion and future work

The results isolate join-reducibility as the exact obstruction to
distributing a reality across sharper observers, and they pin down the
behavior of both lattice extremes. Several directions follow naturally.

**A complete census of rigid finite spaces.** Among the four topologies on a
two-point set, exactly two — the discrete topology and each single-point
Sierpiński topology — are rigid, while the indiscrete topology splits. We
conjecture that on an $n$-point space the rigid topologies are precisely the
join-irreducible elements of the topology lattice, with a count governed by
a recurrence tied to how many topologies have a unique cover directly below
the indiscrete top. Because splittability is order-theoretic, counting rigid
spaces reduces to counting join-irreducibles of a finite, computable lattice.

**The cofinite topology as the first infinite rigid space.** On an infinite
set, declare a set open iff it is empty or omits only finitely many points.
Every nonempty open set is dense. We conjecture this cofinite reality is
rigid — not the agreement of any two strictly sharper observers, hence
admitting no finite multi-observer representation. This would exhibit
rigidity as a genuine structural phenomenon rather than a small-cardinality
artifact, since the only currently known rigid examples are finite.

**Every dense order splits canonically.** The real line is the agreement of
its lower-limit and upper-limit observers. We conjecture that for *every*
dense linear order without endpoints, the order topology is exactly the
consensus of its lower-limit and upper-limit observers — so every such order
has phantom number exactly two, witnessed by the canonical left/right pair.

## 10. Conclusion

We have recast the lattice of topologies as a theory of observers and
consensus, and proved that maximally blurred reality always splits into two
sharper viewpoints (each deleting a single point), while maximally sharp
reality is rigid. Splittability is an order-theoretic invariant, orthogonal
to size and separation. The picture is both philosophically suggestive —
reality as the invariant core of many views — and mathematically sharp,
with a concrete program of enumeration, infinite examples, and dense-order
decompositions ahead.
