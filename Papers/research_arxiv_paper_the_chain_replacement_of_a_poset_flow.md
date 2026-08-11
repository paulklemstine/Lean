# The Chain Replacement of a Poset Flow: Refinement Posets, Cones, and Order-Reflecting Inclusions

**Author:** Aristotle
**Date:** 2026-08-11

---

## Abstract

We develop the combinatorial core of the *chain replacement* of a poset flow. For a
poset $P$ and elements $x \le y$, let $\mathrm{Ch}(x,y)$ denote the set of finite,
totally ordered subsets of the interval $[x,y]$ containing both endpoints, ordered by
refinement (inclusion of carriers). The chain replacement of the poset flow of $P$ is
the flow whose states are the elements of $P$ and whose space of execution paths from
$x$ to $y$ is the simplicial nerve of $\mathrm{Ch}(x,y)$.

We establish four groups of results. First, $\mathrm{Ch}(x,y)$ is a *cone*: the
two-element chain $\{x,y\}$ is its least element, so its nerve is contractible and the
chain replacement is a genuine replacement of the poset flow; we prove the exact
Euler-characteristic form of this statement by an explicit sign-reversing involution
valid for any finite poset possessing an element comparable with all others. Second,
concatenation of chains, given by union of carriers, is associative and monotone in each
variable, making $\mathrm{Ch}$ a semicategory enriched in posets, and it satisfies a
*unique factorisation* property: for all $x,y,z$ the map
$\mathrm{Ch}(x,y) \times \mathrm{Ch}(y,z) \to \{E \in \mathrm{Ch}(x,z) : y \in E\}$
is an isomorphism of posets, with inverse given by cutting a chain at $y$. Third, the
alternating chain count is Philip Hall's theorem,
$\sum_{C : x \to y} (-1)^{|C|} = -\mu(x,y)$, which after deleting endpoints identifies
$-\mu(x,y)$ with the alternating face count of the order complex of the open interval
$(x,y)$ and yields a vanishing criterion: $\mu(x,y) = 0$ whenever $(x,y)$ has a cone
point. Fourth, for an order-reflecting inclusion $f : P \hookrightarrow Q$, transport
along $f$ and the *trace* along $f$ form a Galois coinsertion of refinement posets;
transport is an order embedding whose image is a lower set (a sieve) for refinement,
its complement is an upper set, and $\mathrm{Ch}(f x, f y)$ splits as the disjoint union
of the two. This is the combinatorial form of "pushouts along the chain replacement of an
order-reflecting inclusion preserve spaces of execution paths". We show by an explicit
two-element counterexample that order-reflection cannot be weakened to injective
monotonicity.

**Keywords:** poset flow, chain replacement, refinement poset, order complex, cone point,
Möbius function, Philip Hall's theorem, Galois coinsertion, order-reflecting inclusion,
directed algebraic topology.

---

## 1. Introduction

### 1.1 Flows and directed spaces

Directed algebraic topology studies spaces in which paths cannot be reversed, the
motivating example being the state space of a concurrent program: two independent atomic
actions produce a square of states in which every legal execution moves monotonically
from the initial corner to the final one. A *flow* is one of the standard formalisations.
It consists of a set of states, a topological space $\mathbb{P}_{x,y}$ of execution paths
for each ordered pair $(x,y)$ of states, and associative concatenation maps
$\mathbb{P}_{x,y} \times \mathbb{P}_{y,z} \to \mathbb{P}_{x,z}$. Equivalently, a flow is a
semicategory (a category possibly without identities) enriched in topological spaces.

The simplest flows arise from partial orders. Given a poset $P$, the **poset flow** of
$P$ has state set $P$ and
$$\mathbb{P}_{x,y} = \begin{cases} \ast & x < y \\ \varnothing & \text{otherwise,}\end{cases}$$
with the unique possible composition. All information is carried by the order relation.

Homotopy theory of flows, like homotopy theory anywhere, requires *cofibrant
replacements*: objects that are homotopy equivalent to the given one but assembled by
free attachments, so that constructions such as pushouts compute the homotopically
correct answer. Abstract machinery (small object arguments) produces such replacements
but produces them opaquely. The chain replacement is the opposite: an explicit,
finite, purely combinatorial cofibrant model of a poset flow.

### 1.2 The chain replacement

Fix a poset $P$ and $x \le y$ in $P$. A **chain from $x$ to $y$** is a finite subset
$C \subseteq P$ with $x, y \in C$, with $x \le a \le y$ for every $a \in C$, and with any
two elements of $C$ comparable; equivalently, a strictly increasing sequence
$x = t_0 < t_1 < \cdots < t_n = y$. Chains from $x$ to $y$ form a poset $\mathrm{Ch}(x,y)$
under **refinement**, $C \le D \iff C \subseteq D$. The **chain replacement** of the
poset flow of $P$ is the flow with state set $P$ and
$$\mathbb{P}_{x,y} = \mathrm{N}\big(\mathrm{Ch}(x,y)\big),$$
the simplicial nerve of the refinement poset, with concatenation induced by union of
carriers.

Two features make this work. The nerve of a poset with a least element is contractible,
and $\mathrm{Ch}(x,y)$ has one, so nothing changes up to homotopy. And the refinement
posets and the inclusions between them are combinatorially rigid enough that the
cofibration and gluing properties one wants can be verified by hand rather than invoked.

### 1.3 Contributions

This paper isolates and proves, at the level of the refinement posets that model the path
spaces, the combinatorial statements underlying the chain replacement:

1. **Cone structure and acyclicity** (Section 3): $\{x,y\}$ is the least element of
   $\mathrm{Ch}(x,y)$, and the alternating face count of the order complex of any finite
   poset with a cone point vanishes.
2. **Composition and unique factorisation** (Section 4): concatenation is associative and
   biomonotone, and cutting at an intermediate point is inverse to it, giving an order
   isomorphism onto the sub-poset of chains through that point.
3. **Alternating chain counts** (Section 5): Philip Hall's theorem, the identification of
   $\mu$ with the reduced Euler characteristic of an open interval, and the resulting
   vanishing criterion.
4. **Order-reflecting inclusions** (Section 6): the transport/trace Galois coinsertion,
   the sieve property, the splitting of $\mathrm{Ch}(fx,fy)$, and the necessity of
   order-reflection.

Section 7 gives algorithms and complexity, Section 8 numerical illustrations, and
Sections 9–10 applications, discussion and open problems.

---

## 2. Definitions and conventions

Throughout, $P$, $Q$ denote partially ordered sets; when finiteness is needed it is
stated. We write $[x,y] = \{a : x \le a \le y\}$ and $(x,y) = \{a : x < a < y\}$ for
closed and open intervals, and $|C|$ for the cardinality of a finite set $C$.

**Definition 2.1 (Chain from $x$ to $y$).** For $x, y \in P$, a *chain from $x$ to $y$*
is a finite subset $C \subseteq P$ such that

* $x \in C$ and $y \in C$;
* $x \le a \le y$ for every $a \in C$;
* any two elements of $C$ are comparable.

We write $\mathrm{Ch}(x,y)$ for the set of all chains from $x$ to $y$.

Recording a chain by its underlying set rather than by an increasing sequence is a
deliberate choice: the refinement order becomes literal set inclusion, concatenation
becomes literal union, and the two segments of a chain cut at an interior point become
literal filters. Every statement below is then a statement about finite sets.

**Definition 2.2 (Refinement order).** $\mathrm{Ch}(x,y)$ is partially ordered by
$C \le D \iff C \subseteq D$. Reflexivity, transitivity and antisymmetry are those of
inclusion; note that a chain is determined by its underlying set, so antisymmetry is
genuine equality of chains.

**Remark 2.3.** $\mathrm{Ch}(x,y) \ne \varnothing$ if and only if $x \le y$. Indeed a
chain $C$ from $x$ to $y$ contains $y$, whence $x \le y$ by the boundedness condition;
conversely $\{x,y\}$ is a chain when $x \le y$. If $P$ is finite then each
$\mathrm{Ch}(x,y)$ is finite, being a set of subsets of $P$.

**Definition 2.4 (Order complex).** For a finite poset $R$, the *order complex*
$\Delta(R)$ is the abstract simplicial complex whose faces are the totally ordered
subsets of $R$, the empty set included. Its geometric realisation is the realisation of
the nerve of $R$ viewed as a category, so statements about $\Delta(R)$ are statements
about the nerve.

**Definition 2.5 (Cone point).** An element $z$ of a poset $R$ is a *cone point* if
$z \le a$ or $a \le z$ for every $a \in R$. A least or greatest element is a cone point.

**Definition 2.6 (Möbius function).** For a finite poset $P$, the Möbius function
$\mu : P \times P \to \mathbb{Z}$ of the incidence algebra is determined by
$\mu(x,x) = 1$, $\mu(x,y) = 0$ if $x \not\le y$, and
$$\mu(x,y) = -\sum_{x \le z < y} \mu(x,z) \qquad (x < y).$$

**Definition 2.7 (Order-reflecting inclusion).** A map $f : P \to Q$ is an *order
embedding*, equivalently an *order-reflecting inclusion*, if for all $u, v \in P$,
$$u \le v \iff f(u) \le f(v).$$
Such an $f$ is automatically injective. We write $f : P \hookrightarrow Q$.

---

## 3. The cone structure of the refinement poset

### 3.1 The coarsest chain

**Theorem 3.1 (Cone Theorem).** *Let $x \le y$ in a poset $P$. Then $\{x,y\}$ is a chain
from $x$ to $y$, and it is the least element of $\mathrm{Ch}(x,y)$: $\{x,y\} \subseteq C$
for every $C \in \mathrm{Ch}(x,y)$. Consequently $\mathrm{Ch}(x,y)$ has a bottom element
and its nerve is contractible.*

*Proof.* That $\{x,y\}$ is a chain is immediate: it contains both endpoints; each of its
elements lies in $[x,y]$ because $x \le x \le y$ and $x \le y \le y$; and its two elements
are comparable because $x \le y$. Minimality is the definition of a chain from $x$ to
$y$: every such chain contains $x$ and $y$. Contractibility of the nerve follows because
the nerve of a poset with a least element $\bot$ admits the contraction determined by
$C \mapsto C \cup \{\bot\}$, a natural transformation from the identity functor to the
constant functor at $\bot$. $\square$

The last step is the standard "a category with an initial object has contractible nerve"
argument. Its numerical shadow, which we prove in full and which is the version used in
all computations below, is Theorem 3.2.

### 3.2 Acyclicity of cones

**Theorem 3.2 (Acyclicity of cones).** *Let $R$ be a finite poset possessing a cone point
$z$. Then*
$$\sum_{C \in \Delta(R)} (-1)^{|C|} = 0,$$
*the sum ranging over all faces of the order complex, the empty face included.
Equivalently,*
$$\sum_{\varnothing \ne C \in \Delta(R)} (-1)^{|C|} = -1,$$
*so that, with the dimension convention $\dim C = |C| - 1$, the Euler characteristic of
$\Delta(R)$ is $1$ and its reduced Euler characteristic is $0$.*

*Proof.* Define $\iota(C) = C \mathbin{\triangle} \{z\}$, that is, $\iota(C) = C \setminus \{z\}$
if $z \in C$ and $\iota(C) = C \cup \{z\}$ otherwise. Three observations:

* $\iota$ maps faces to faces. Removing an element from a totally ordered set leaves it
  totally ordered. Adjoining $z$ to a totally ordered $C$ leaves it totally ordered
  precisely because $z$ is comparable with every element of $R$.
* $\iota$ is an involution without fixed points: $z \in C \iff z \notin \iota(C)$, and
  $\iota(\iota(C)) = C$ by inspection of the two cases.
* $\iota$ reverses the sign: $|\iota(C)| = |C| \pm 1$, so
  $(-1)^{|\iota(C)|} = -(-1)^{|C|}$.

A sign-reversing involution without fixed points on a finite index set forces the sum to
vanish. The reduced form follows by isolating the empty face, whose contribution is
$(-1)^0 = 1$. $\square$

**Corollary 3.3.** *For $x \le y$ in a finite poset $P$,*
$$\sum_{\mathcal{C} \in \Delta(\mathrm{Ch}(x,y))} (-1)^{|\mathcal{C}|} = 0,
\qquad \sum_{\varnothing \ne \mathcal{C} \in \Delta(\mathrm{Ch}(x,y))} (-1)^{|\mathcal{C}|} = -1 .$$

*Proof.* Apply Theorem 3.2 to $R = \mathrm{Ch}(x,y)$ with cone point $\{x,y\}$, which is
comparable with everything because it is below everything (Theorem 3.1). $\square$

Corollary 3.3 says that the spaces of execution paths of the chain replacement have the
Euler characteristic of a point: the replacement has not altered the homotopy type of the
poset flow, only its combinatorial presentation. Note the contrast with the hypothesis:
without a cone point the conclusion fails. For the two-element antichain the order complex
consists of $\varnothing$ and two vertices, and the alternating face count is
$1 - 1 - 1 = -1 \ne 0$, correctly recording two contractible components.

---

## 4. Composition and unique factorisation

### 4.1 Concatenation

**Definition 4.1.** For $C \in \mathrm{Ch}(x,y)$ and $D \in \mathrm{Ch}(y,z)$, set
$$C \ast D := C \cup D .$$

**Proposition 4.2.** *$C \ast D \in \mathrm{Ch}(x,z)$, and $y \in C \ast D$.*

*Proof.* $x \in C$ and $z \in D$ give the endpoints. For boundedness: if $a \in C$ then
$x \le a$ and $a \le y \le z$ (using $y \le z$, which holds since $\mathrm{Ch}(y,z)$ is
nonempty); symmetrically for $a \in D$. For total ordering: two elements of $C$, or two of
$D$, are comparable by hypothesis; and if $a \in C$, $b \in D$ then $a \le y \le b$. $\square$

**Theorem 4.3 (Poset-enriched semicategory).** *Concatenation is associative,*
$$(C \ast D) \ast E = C \ast (D \ast E) \qquad
(C \in \mathrm{Ch}(x,y),\; D \in \mathrm{Ch}(y,z),\; E \in \mathrm{Ch}(z,w)),$$
*and monotone in each variable: if $C \le C'$ then $C \ast D \le C' \ast D$, and if
$D \le D'$ then $C \ast D \le C \ast D'$. Hence $\mathrm{Ch}$ is a semicategory enriched
in posets, and after applying the nerve, a flow.*

*Proof.* Associativity is associativity of union. Monotonicity is monotonicity of union
with respect to inclusion in each argument. Bimonotone maps of posets induce simplicial
maps of nerves, so the concatenation is realised as a map
$\mathrm{N}(\mathrm{Ch}(x,y)) \times \mathrm{N}(\mathrm{Ch}(y,z)) \to \mathrm{N}(\mathrm{Ch}(x,z))$
of the corresponding path spaces. $\square$

Also worth recording: $\{x,y\} \ast \{y,z\} = \{x,y,z\}$, so the composite of the two
coarsest chains is not the coarsest chain from $x$ to $z$ but the coarsest one *through*
$y$. This is exactly right for a semicategory model in which composition is not required
to be surjective on path spaces.

### 4.2 Cutting a chain

**Definition 4.4.** For $E \in \mathrm{Ch}(x,z)$ and $y \in E$, define
$$E_{\le y} := \{a \in E : a \le y\}, \qquad E_{\ge y} := \{a \in E : y \le a\}.$$

**Lemma 4.5.** *$E_{\le y} \in \mathrm{Ch}(x,y)$ and $E_{\ge y} \in \mathrm{Ch}(y,z)$, and
both operations are monotone in $E$.*

*Proof.* $x \in E_{\le y}$ because $x \le y$ (as $y \in E \subseteq [x,z]$ gives $x \le y$),
and $y \in E_{\le y}$; boundedness and total ordering are inherited from $E$; likewise on
the other side. Monotonicity: if $E \subseteq E'$ then filtering both by the same predicate
preserves the inclusion. $\square$

**Lemma 4.6 (Cut–glue inverse laws).** *For $E \in \mathrm{Ch}(x,z)$ with $y \in E$,*
$$E_{\le y} \ast E_{\ge y} = E .$$
*Conversely, for $C \in \mathrm{Ch}(x,y)$ and $D \in \mathrm{Ch}(y,z)$,*
$$(C \ast D)_{\le y} = C, \qquad (C \ast D)_{\ge y} = D .$$

*Proof.* The first identity: $\subseteq$ is clear since both pieces are subsets of $E$; for
$\supseteq$, take $a \in E$; since $E$ is totally ordered and $y \in E$, either $a \le y$ or
$y \le a$, so $a$ lies in one of the two pieces. Second identity, the inclusion $\supseteq$:
every $a \in C$ satisfies $a \le y$, so $a \in (C\ast D)_{\le y}$. For $\subseteq$: if
$a \in C \cup D$ and $a \le y$ then either $a \in C$, or $a \in D$ and then $y \le a$, so
$a = y \in C$. The right-hand identity is symmetric. $\square$

**Theorem 4.7 (Unique Factorisation Theorem).** *For $x, y, z$ in a poset $P$, the map*
$$\Phi : \mathrm{Ch}(x,y) \times \mathrm{Ch}(y,z) \longrightarrow
\{E \in \mathrm{Ch}(x,z) : y \in E\}, \qquad \Phi(C,D) = C \ast D,$$
*is an isomorphism of posets, where the left-hand side carries the product order and the
right-hand side the refinement order. Its inverse is $E \mapsto (E_{\le y}, E_{\ge y})$.
Moreover $\Phi$ reflects the order: $C \ast D \subseteq C' \ast D'$ if and only if
$C \subseteq C'$ and $D \subseteq D'$.*

*Proof.* Well-definedness is Proposition 4.2, and the two composites are the identity by
Lemma 4.6. Monotonicity of $\Phi$ is Theorem 4.3; monotonicity of the inverse is Lemma 4.5.
Order reflection then follows formally: if $C \ast D \subseteq C' \ast D'$, apply the
monotone cutting maps and use Lemma 4.6 to get $C \subseteq C'$ and $D \subseteq D'$. $\square$

Under the nerve, Theorem 4.7 states that concatenation identifies
$\mathbb{P}_{x,y} \times \mathbb{P}_{y,z}$ with the full simplicial subset of
$\mathbb{P}_{x,z}$ spanned by the executions that stop at $y$. This is a strictly stronger
statement than the homotopical one, and it is what makes the local analysis of the chain
replacement tractable.

---

## 5. Alternating chain counts, the Möbius function, and Euler characteristics

Throughout this section $P$ is finite (and locally finite intervals are used freely).

**Definition 5.1.** For $x, y \in P$ put
$$\chi(x,y) := \sum_{C \in \mathrm{Ch}(x,y)} (-1)^{|C|} \in \mathbb{Z} .$$

**Lemma 5.2 (Boundary values).** *$\chi(x,x) = -1$, and $\chi(x,y) = 0$ when
$x \not\le y$.*

*Proof.* If $x = y$ then every chain from $x$ to $x$ is contained in $[x,x] = \{x\}$ and
contains $x$, hence equals $\{x\}$; the sum is $(-1)^1 = -1$. If $x \not\le y$ there is no
chain at all (Remark 2.3), so the empty sum is $0$. $\square$

**Lemma 5.3 (Decapitation recursion).** *For $x < y$,*
$$\chi(x,y) = -\sum_{z \in [x,y)} \chi(x,z) .$$

*Proof.* Every nonempty totally ordered finite set has a greatest element; for a chain $C$
from $x$ to $y$ that element is $y$. The assignment $C \mapsto (z, C \setminus \{y\})$,
where $z = \max(C \setminus \{y\})$, is a bijection
$$\mathrm{Ch}(x,y) \;\xrightarrow{\ \sim\ }\; \coprod_{z \in [x,y)} \mathrm{Ch}(x,z),$$
with inverse $(z, C') \mapsto C' \cup \{y\}$. Indeed $C \setminus \{y\}$ is nonempty (it
contains $x$, and $x \ne y$), is totally ordered, is bounded above by its maximum $z < y$,
and contains $x$ and $z$; conversely adjoining $y$ to a chain from $x$ to $z$ with $z < y$
produces a chain from $x$ to $y$ whose second-largest element is $z$. Injectivity uses that
$y \notin C'$ for any chain $C'$ from $x$ to $z$ with $z < y$, and that $z$ is recovered as
the maximum. Since $|C' \cup \{y\}| = |C'| + 1$, the bijection multiplies each sign by
$-1$, which gives the stated identity. $\square$

**Theorem 5.4 (Philip Hall's Theorem).** *For all $x, y$ in a finite poset $P$,*
$$\sum_{C \in \mathrm{Ch}(x,y)} (-1)^{|C|} = -\mu(x,y) .$$

*Proof.* Induction on $y$ with respect to the (well-founded) strict order. If $x = y$,
both sides equal $-1$ by Lemma 5.2 and $\mu(x,x)=1$. If $x \not\le y$, both sides are $0$
(Lemma 5.2 and Definition 2.6; note that $[x,y) = \varnothing$ in that case, so the Möbius
recursion also returns $0$). If $x < y$, Lemma 5.3 and the inductive hypothesis give
$$\chi(x,y) = -\sum_{z \in [x,y)} \chi(x,z) = -\sum_{z \in [x,y)} \big(-\mu(x,z)\big)
= \sum_{z \in [x,y)}\mu(x,z) = -\mu(x,y),$$
the last step being the defining recursion of $\mu$. $\square$

**Corollary 5.5.** *$\mu(x,y) = 0$ whenever $x \not\le y$.* (Immediate from Lemma 5.2 and
Theorem 5.4; it is a pleasant feature of the chain description that this basic fact becomes
a triviality.)

**Theorem 5.6 (Möbius function as reduced Euler characteristic).** *For $x < y$ in a finite
poset $P$,*
$$\sum_{F \in \Delta((x,y))} (-1)^{|F|} = -\mu(x,y),$$
*the sum ranging over the faces of the order complex of the open interval $(x,y)$, the
empty face included. Equivalently, $\mu(x,y) = \tilde{\chi}\big(\Delta((x,y))\big)$ is the
reduced Euler characteristic.*

*Proof.* The map $F \mapsto F \cup \{x,y\}$ is a bijection from the faces of
$\Delta((x,y))$ to $\mathrm{Ch}(x,y)$. It is well defined: adjoining $x$ and $y$ to a
totally ordered subset of $(x,y)$ yields a totally ordered subset of $[x,y]$ containing
both endpoints, since $x$ and $y$ are comparable with every element of $(x,y)$. It is
injective because $x, y \notin (x,y)$, so $F$ is recovered as $C \setminus \{x,y\}$; and
surjective because for $C \in \mathrm{Ch}(x,y)$ the set $C \cap (x,y)$ is a face mapping to
$C$. Since $x \ne y$ and neither lies in $F$, we have $|F \cup \{x,y\}| = |F| + 2$, and
$(-1)^{|F|+2} = (-1)^{|F|}$, so the two alternating sums agree. Conclude with Theorem 5.4.
$\square$

**Theorem 5.7 (Vanishing criterion).** *Let $x < y$ in a finite poset $P$. If the open
interval $(x,y)$ contains an element $z$ comparable with every element of $(x,y)$, then
$\mu(x,y) = 0$.*

*Proof.* By Theorem 3.2 applied to $R = (x,y)$ with cone point $z$, the alternating face
count of $\Delta((x,y))$ vanishes; by Theorem 5.6 that count is $-\mu(x,y)$. $\square$

**Remark 5.8.** The criterion of Theorem 5.7 is sufficient but not necessary: there are
finite posets with $\mu(x,y) = 0$ whose open interval $(x,y)$ has no cone point, since
vanishing reduced Euler characteristic is far weaker than contractibility. Any interval
whose order complex is a homology sphere of odd dimension, or more simply any interval
whose complex has vanishing reduced Euler characteristic for numerical reasons, will do.

**Remark 5.9 (Where this meets the replacement).** Theorem 5.7 applies verbatim to
refinement posets: $\mathrm{Ch}(x,y)$ has the cone point $\{x,y\}$. It is the same
computation as Corollary 3.3, viewed through the incidence algebra rather than through the
order complex, and this coincidence is the precise sense in which the homotopical content
of the chain replacement and the enumerative content of Hall's theorem are one statement.

---

## 6. Order-reflecting inclusions, cofibrations, and gluing

Let $f : P \hookrightarrow Q$ be an order embedding of posets, and fix $x, y \in P$. Write
$\mathrm{Ch}_P$, $\mathrm{Ch}_Q$ for refinement posets computed in $P$ and $Q$.

### 6.1 Transport and trace

**Definition 6.1 (Transport).** For $C \in \mathrm{Ch}_P(x,y)$, set
$f_\ast C := f(C) = \{f(a) : a \in C\}$.

**Proposition 6.2.** *$f_\ast C \in \mathrm{Ch}_Q(fx, fy)$, and $f_\ast$ is monotone.*

*Proof.* $f(x), f(y) \in f(C)$; boundedness and comparability are preserved because $f$ is
order-preserving. Monotonicity is monotonicity of taking images. $\square$

**Definition 6.3 (Trace).** For $E \in \mathrm{Ch}_Q(fx, fy)$, set
$$f^\ast E := f^{-1}(E) = \{a \in P : f(a) \in E\} .$$

**Proposition 6.4.** *$f^\ast E \in \mathrm{Ch}_P(x,y)$, and $f^\ast$ is monotone. This is
the only place where order-reflection is used, and it is indispensable.*

*Proof.* $x \in f^\ast E$ since $f(x) \in E$, similarly $y$. If $a \in f^\ast E$ then
$f(x) \le f(a) \le f(y)$ in $Q$, and order-reflection gives $x \le a \le y$ in $P$. If
$a, b \in f^\ast E$ then $f(a), f(b)$ are comparable in $E$, and order-reflection converts
this into comparability of $a$ and $b$. Monotonicity is monotonicity of preimages. Without
reflection the second and third steps fail: the preimage of a chain can be an antichain
(see Section 6.4). $\square$

**Theorem 6.5 (Galois coinsertion).** *For every $C \in \mathrm{Ch}_P(x,y)$ and
$E \in \mathrm{Ch}_Q(fx,fy)$,*
$$f_\ast C \le E \iff C \le f^\ast E, \qquad\text{and}\qquad f^\ast f_\ast C = C .$$
*Thus $(f_\ast, f^\ast)$ is a monotone Galois connection with $f^\ast f_\ast = \mathrm{id}$,
i.e. a Galois coinsertion.*

*Proof.* Adjointness: $f(C) \subseteq E$ iff every $a \in C$ has $f(a) \in E$, iff
$C \subseteq f^{-1}(E)$. Retraction: $f^{-1}(f(C)) = C$ because $f$ is injective. $\square$

**Corollary 6.6 (Order embedding of refinement posets).** *$f_\ast$ is an order embedding
$\mathrm{Ch}_P(x,y) \hookrightarrow \mathrm{Ch}_Q(fx,fy)$: it is injective, and
$f_\ast C \le f_\ast D$ if and only if $C \le D$.*

*Proof.* Injectivity from $f^\ast f_\ast = \mathrm{id}$. For the equivalence, one direction
is monotonicity; conversely $f_\ast C \le f_\ast D$ gives $C \le f^\ast f_\ast D = D$ by
Theorem 6.5. $\square$

An adjunction between posets induces a homotopy equivalence of nerves — the unit and counit
provide the required homotopies — so Theorem 6.5 is the structural reason why the induced
map of path spaces of the chain replacement is so well behaved.

**Proposition 6.7 (Compatibility with the flow structure).** *For $C \in \mathrm{Ch}_P(x,y)$
and $D \in \mathrm{Ch}_P(y,z)$,*
$$f_\ast(C \ast D) = f_\ast C \ast f_\ast D, \qquad f_\ast\{x,y\} = \{fx, fy\},$$
*and $(g \circ f)_\ast = g_\ast \circ f_\ast$ for a further order embedding
$g : Q \hookrightarrow R$. Hence the chain replacement is functorial and $f_\ast$ is a
morphism of flows.*

*Proof.* Images commute with unions and with the two-element set; functoriality of images.
$\square$

### 6.2 The sieve property

**Definition 6.8.** Call $E \in \mathrm{Ch}_Q(fx,fy)$ *supported on $P$* if
$E \subseteq f(P)$.

**Lemma 6.9 (Recognition).** *$E$ is in the image of $f_\ast$ if and only if $E$ is
supported on $P$, if and only if $f_\ast f^\ast E = E$.*

*Proof.* If $E = f_\ast C$ then $E \subseteq f(P)$. Conversely, if $E \subseteq f(P)$ then
$f(f^{-1}(E)) = E$; and $f^\ast E$ is a chain by Proposition 6.4, so $E$ is in the image.
The last equivalence restates this. $\square$

**Theorem 6.10 (Sieve property / cofibration flavour).** *The set*
$$\mathcal{L} := \{E \in \mathrm{Ch}_Q(fx,fy) : \exists\, C,\ f_\ast C = E\}$$
*is a lower set for refinement: if $E' \le E$ and $E \in \mathcal{L}$ then
$E' \in \mathcal{L}$. Dually, the complement of $\mathcal{L}$ is an upper set.*

*Proof.* Let $E = f_\ast C$ and $E' \subseteq E$. Every element of $E'$ lies in $E \subseteq f(P)$,
so $E'$ is supported on $P$ and Lemma 6.9 applies. The dual statement is the complement of
a lower set. $\square$

Lower sets for the refinement order are precisely the *sieves* — subobjects closed under
coarsening — and it is exactly this closure property that makes the induced inclusion of
nerves a cofibration: the attaching happens along a full, downward-closed sub-poset, so
the cells of the complement are attached freely.

### 6.3 Splitting, and preservation of path spaces under gluing

**Theorem 6.11 (Splitting).** *There is a bijection*
$$\mathrm{Ch}_P(x,y) \;\sqcup\; \{E \in \mathrm{Ch}_Q(fx,fy) : E \notin \mathcal{L}\}
\;\xrightarrow{\ \sim\ }\; \mathrm{Ch}_Q(fx,fy),$$
*given by $f_\ast$ on the first summand and the inclusion on the second, with inverse
$E \mapsto f^\ast E$ when $E \in \mathcal{L}$ and $E \mapsto E$ otherwise. The image of the
first summand is a lower set and the second summand is an upper set for refinement.*

*Proof.* The two summands are complementary by Lemma 6.9, and $f_\ast$ is a bijection onto
$\mathcal{L}$ with inverse $f^\ast$ by Theorem 6.5 and Lemma 6.9. The set-theoretic
verification that the two composites are the identity is immediate. The lower/upper set
statements are Theorem 6.10. $\square$

**Interpretation.** Suppose one attaches new material to the chain replacement of $P$ along
$f$, forming a pushout
$$\begin{array}{ccc}
\mathrm{Ch}(P) & \longrightarrow & X \\
\downarrow & & \downarrow \\
\mathrm{Ch}(Q) & \longrightarrow & X \cup_{\mathrm{Ch}(P)} \mathrm{Ch}(Q).
\end{array}$$
Theorem 6.11 says that as a poset (hence, after taking nerves, as a space), each path space
of $\mathrm{Ch}(Q)$ is the disjoint union of a copy of the corresponding path space of
$\mathrm{Ch}(P)$ — sitting as a downward-closed piece — and an independent remainder. When
$\mathrm{Ch}(P)$ is replaced by $X$, the remainder is carried along untouched and the path
space of the pushout is the pushout of the path spaces. This is the combinatorial content
of the statement that *pushouts along the chain replacement of an order-reflecting
inclusion of finite posets preserve spaces of execution paths*.

### 6.4 Order-reflection is necessary

**Theorem 6.12 (Necessity of order-reflection).** *Let $P$ be the two-element antichain
$\{a,b\}$ (so $u \le v$ iff $u = v$) and $Q$ the two-element chain $\{0 < 1\}$, and let
$g : P \to Q$ be $g(a) = 0$, $g(b) = 1$. Then $g$ is injective and monotone but not
order-reflecting; the chain $\{0,1\} \in \mathrm{Ch}_Q(g a, g b)$ is supported on the image
of $g$; and $\mathrm{Ch}_P(a,b) = \varnothing$. Hence the recognition Lemma 6.9 — and with
it Theorems 6.10 and 6.11 — fails for merely injective monotone maps.*

*Proof.* Monotonicity: $u \le v$ in $P$ means $u = v$, so $g(u) = g(v)$. Injectivity is
clear. Reflection fails since $g(a) = 0 \le 1 = g(b)$ while $a \not\le b$. The set
$\{0,1\}$ is a chain from $0$ to $1$ in $Q$ and both of its elements lie in the image of
$g$. Finally, a chain from $a$ to $b$ in $P$ would force $a \le b$, which is false, so
$\mathrm{Ch}_P(a,b)$ is empty and $\{0,1\}$ cannot be a transport. $\square$

The failure is maximal: not merely does the recognition lemma fail, but the source path
space is empty while the target path space is a point. Any argument that identifies path
spaces across an inclusion must therefore rule this out, and order-reflection is exactly
the hypothesis that does so. Note also that the trace itself breaks: $g^{-1}(\{0,1\}) =
\{a,b\}$ is an antichain, not a chain of $P$.

---

## 7. Algorithms

All of the above is effective. We record the three algorithms that matter, for a finite
poset $P$ presented by its comparability matrix, with $n = |P|$.

### 7.1 Enumeration of chains from $x$ to $y$

Chains from $x$ to $y$ are in bijection with totally ordered subsets of the open interval
$(x,y)$ (proof of Theorem 5.6). Enumerate them by depth-first search on the *last stop*:
starting at $x$, repeatedly extend the current chain by any $t$ with $\text{last} < t \le y$
and $t \le y$, emitting the chain when $t = y$. Each chain is produced exactly once because
the sequence of stops is strictly increasing. The cost is $O(n)$ per emitted chain after
preprocessing the order relation into a matrix, so the total is
$O(n \cdot |\mathrm{Ch}(x,y)|)$ — optimal up to the factor $n$. The count itself can be
obtained in $O(n^3)$ without enumeration, by the recursion
$$N(x,y) = \sum_{x \le t < y} N(x,t), \qquad N(x,x) = 1,$$
which is the unsigned form of Lemma 5.3.

### 7.2 Möbius function by chain counting versus by recursion

Two independent routes to $\mu(x,y)$:

* the classical recursion $\mu(x,y) = -\sum_{x \le z < y}\mu(x,z)$, computable in
  $O(n^3)$ overall for all pairs by processing $y$ in a linear extension;
* the alternating chain count $-\sum_C (-1)^{|C|}$, exponential in general but structurally
  informative.

Theorem 5.4 asserts they agree, and checking the agreement on all pairs of a moderate poset
is a strong consistency test of an implementation of either.

### 7.3 Building the refinement poset and testing the splitting

Given $x \le y$, enumerate $\mathrm{Ch}(x,y)$, order the results by inclusion, and one has
the refinement poset explicitly, with $\{x,y\}$ as bottom. For an order embedding
$f : P \hookrightarrow Q$, classify each $E \in \mathrm{Ch}_Q(fx,fy)$ by the predicate
$E \subseteq f(P)$; Theorem 6.11 predicts that the "yes" class is in bijection with
$\mathrm{Ch}_P(x,y)$ via $f^\ast$ and is closed downwards, while the "no" class is closed
upwards. Both checks are quadratic in the number of chains.

---

## 8. Numerical illustrations

**The chain $\mathbf{0<1<2<3}$.** Chains from $0$ to $3$ are determined by which subset of
$\{1,2\}$ is used as stopovers: there are $4$, of sizes $2,3,3,4$. The alternating sum is
$1 - 1 - 1 + 1 = 0$, and indeed $\mu(0,3) = 0$ for a chain of length $3$. For the covering
pair $0 < 1$ there is a single chain $\{0,1\}$, alternating sum $1$, matching
$-\mu(0,1) = 1$. More generally, in a linear order the chains from $x$ to $y$ correspond to
subsets of the open interval, so the alternating sum is $(-1)^{|[x,y]|}\!\cdot\!$(a binomial
identity) and collapses to $0$ unless $(x,y)$ is empty.

**The Boolean lattice $\mathbf{B_n}$.** A chain from $\varnothing$ to $\{1,\dots,n\}$ is the
same as an ordered partition of $\{1,\dots,n\}$ into nonempty blocks (the successive
increments), so
$$|\mathrm{Ch}(\varnothing, \{1,\dots,n\})| = a(n), \quad a(1),a(2),a(3),a(4) = 1, 3, 13, 75,$$
the ordered Bell (Fubini) numbers. For $n = 3$ the thirteen chains give alternating sum
$1 = -\mu(\varnothing,\{1,2,3\})$, consistent with $\mu_{B_n}(\varnothing,\top) = (-1)^n$.
For the interval $(\varnothing, \{1,2\})$ inside $B_3$, the open interval has two elements
forming an antichain, alternating face count $1 - 1 - 1 = -1 = -\mu$, and $\mu = 1 = (-1)^2$.

**Cone points.** The alternating face count of the order complex is $0$ for the four-element
chain and for $B_2$ (both have least elements) and $-1$ for the two-element antichain (no
cone point) — the sharpness of Theorem 3.2.

**Refinement posets.** For $B_3$ and $x = \varnothing$, $y = \top$: the refinement poset
$\mathrm{Ch}(x,y)$ has $13$ elements, unique bottom $\{\varnothing, \top\}$ and six maximal
elements (the maximal chains, one for each of the $3! = 6$ orderings), and its order complex
has alternating face count $0$ as Corollary 3.3 predicts.

**Splitting.** Take $Q = B_2$ and $P$ the sub-poset $\{\varnothing, \{1\}, \top\}$, a
three-element chain, included order-reflectingly. Then $\mathrm{Ch}_Q(\varnothing,\top)$ has
three elements, of which two — $\{\varnothing,\top\}$ and $\{\varnothing,\{1\},\top\}$ — are
supported on $P$ and form a lower set, matching $|\mathrm{Ch}_P| = 2$; the remaining chain
$\{\varnothing,\{2\},\top\}$ is the upper-set remainder.

---

## 9. Applications and discussion

**Directed topology and concurrency.** The chain replacement gives an explicit cofibrant
model for the flows arising from precedence orders on concurrent systems. Because the model
is finite and combinatorial, questions about the homotopy type of path spaces reduce to
questions about refinement posets, which a computer can enumerate. The splitting theorem
tells the system designer precisely when adding new behaviour along a subsystem cannot
disturb the execution spaces of the ambient system: the subsystem must be embedded
*order-reflectingly*, that is, the ambient system must not create precedence between actions
that the subsystem regards as independent. Theorem 6.12 is the smallest example of what goes
wrong otherwise, and it has an operational reading: if the enclosing system serialises two
actions that the subsystem considers concurrent, the subsystem's execution space is not
recoverable from the ambient one.

**Enumerative combinatorics.** Theorem 5.4 is Philip Hall's classical theorem, here derived
from the same decapitation bijection that structures the refinement poset. Theorem 5.6
places the Möbius function in topology, and Theorem 5.7 yields a criterion that is easy to
apply: intervals with a "universal comparable" element contribute nothing to Möbius
inversion. In lattices this specialises to familiar statements — for instance, an interval
containing an element comparable with all others in the open part has vanishing $\mu$,
which is the mechanism behind many crosscut- and closure-based vanishing theorems.

**Order theory.** The transport/trace pair (Theorem 6.5) is a Galois coinsertion, and the
sieve property (Theorem 6.10) says its image is a lower set. This pair of facts is exactly
what one wants in order to conclude that the induced map of nerves is a cofibration and a
homotopy equivalence onto its image; the general slogan is that adjunctions between posets
are homotopy equivalences of nerves, and that downward-closed embeddings are cofibrations.
The refinement poset thus turns a homotopical question about flows into an order-theoretic
one that is entirely finite.

**Rigidity.** It is worth emphasising how strict the results are. Theorem 4.7 is an
isomorphism of posets, not an equivalence up to homotopy; Theorem 6.11 is a bijection, not a
weak equivalence. The chain replacement achieves the flexibility of a cofibrant replacement
without giving up strictness at the combinatorial level, and that combination is what makes
it a practical tool rather than merely an existence statement.

---

## 10. Future directions

The development above establishes the combinatorial core: the refinement poset, its cone
structure, the concatenation law, the behaviour under order-reflecting inclusions, and the
Euler-characteristic invariants. Three concrete problems stand out.

**Problem 1 (Nerve contractibility upgrade).** *For every finite poset $R$ with a cone
point, the simplicial nerve of $R$ is a contractible simplicial set; consequently, for
$x \le y$ in a finite poset, the nerve of $\mathrm{Ch}(x,y)$ is contractible and the chain
replacement of a poset flow is a genuine cofibrant replacement.* The key insight is that the
involution $C \mapsto C \mathbin{\triangle} \{z\}$ used to prove Theorem 3.2 is the shadow of
an explicit simplicial homotopy $\Delta^1 \times \mathrm{N}(R) \to \mathrm{N}(R)$ contracting
$\mathrm{N}(R)$ onto the cone point; the numerical statement proved here is the Euler
characteristic of a homotopy that can be written down face by face. The statement is
falsifiable: a finite poset with a cone point whose nerve has a nontrivial homotopy group
would refute it.

**Problem 2 (Fibrewise product formula for the trace).** *Let $f : P \hookrightarrow Q$ be
order-reflecting and $x, y \in P$. For every $D \in \mathrm{Ch}_P(x,y)$, the fibre
$\{E \in \mathrm{Ch}_Q(fx,fy) : f^\ast E = D\}$ is isomorphic, as a poset, to the product
over the covering pairs $(u,v)$ of $D$ of the posets of chains from $f(u)$ to $f(v)$ whose
interior misses the image of $P$.* The Galois coinsertion of Theorem 6.5 already splits the
chain poset of $Q$ into a lower set (the image of $P$) and its complement, and the two-step
version of the splitting is exactly the unique factorisation isomorphism of Theorem 4.7; the
general statement should follow by induction on $|D|$ using that isomorphism at each cut
point. The only missing ingredient is an indexing scheme for covering pairs of a finite
chain — routine but not yet in place. A finite order-reflecting inclusion and a chain $D$
whose fibre has cardinality different from the product would refute it.

**Problem 3 (Möbius vanishing from local cones is not exhaustive).** *The cone criterion of
Theorem 5.7 is strictly sufficient: there exist finite posets and pairs $x < y$ with
$\mu(x,y) = 0$ for which the open interval $(x,y)$ has no cone point, and moreover the class
of such "accidentally vanishing" intervals is not captured by any finite list of local
comparability criteria.* The reason to expect this is that $\mu(x,y)$ records only the
reduced Euler characteristic of $\Delta((x,y))$ (Theorem 5.6), whereas a cone point records
contractibility; every complex with vanishing reduced Euler characteristic and nontrivial
homology therefore yields a candidate. Constructing an explicit small example — an interval
whose order complex is, say, a triangulated odd sphere or a homology sphere — would settle
the first half, and would delimit precisely how much of Möbius vanishing the chain
replacement's cone argument can explain.

Beyond these, two directions suggest themselves. One is a *relative* chain replacement: run
the construction on a pair $(Q, P)$ and identify the resulting relative path spaces with the
upper-set remainder of Theorem 6.11 directly, giving a combinatorial model for the cofibre.
The other is quantitative: the refinement posets $\mathrm{Ch}(x,y)$ have well-understood
cardinalities in structured examples (ordered Bell numbers for Boolean lattices, powers of
two for chains), and an asymptotic study of the size of the chain replacement, as a function
of the width and height of the poset, would say how practical the model is for the state
spaces that arise from actual concurrent programs.

---

## 11. Conclusion

The chain replacement of a poset flow rests on a single observation of disarming simplicity:
the chains from $x$ to $y$, ordered by refinement, form a poset with a least element. From
that one fact flow the contractibility of the replaced path spaces, an exact numerical
acyclicity statement provable by a fixed-point-free sign-reversing involution, a strict
unique-factorisation law for concatenation, Philip Hall's theorem and the identification of
the Möbius function with a reduced Euler characteristic, and — for order-reflecting
inclusions — a Galois coinsertion, a sieve property, and a clean splitting of path spaces
that makes gluing behave. The counterexample of the two-element antichain mapping into the
two-element chain shows that order-reflection is not a technical convenience but the exact
hypothesis under which the theory holds.
