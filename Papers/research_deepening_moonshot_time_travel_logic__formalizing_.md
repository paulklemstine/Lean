# A Fixed-Point Theory of Causal Consistency in Time Loops

## Abstract

We give a self-contained, purely combinatorial-dynamical theory of time-travel
causal loops and the Novikov self-consistency principle. A **causal loop** is a
finite cyclic chain of events in which the state of each event causally
determines the state of the next; a **consistent history** is a state assignment
respecting all causal transitions and closing up into a genuine cycle. Our
central result is a *structure theorem*: for every causal loop, the consistent
histories stand in a canonical bijection with the fixed points of the loop's
**round-trip map** — the composite of all its transition functions taken once
around. As an immediate corollary we obtain a precise form of the **Novikov
self-consistency principle**: a loop admits a consistent history if and only if
its round-trip map has a fixed point, and the number of consistent histories
equals the number of fixed points. We show that the classical grandfather
paradox is the one-event loop whose transition is logical negation, and prove it
has no consistent history because negation has no fixed point. We then analyze
repeated traversal: going around a loop $k$ times realizes the $k$-th iterate of
the round-trip map, and on any finite non-empty state space a pigeonhole argument
guarantees that some positive number of repetitions is always consistent — even
for loops (like the grandfather) that are inconsistent on a single lap. The
theory reduces the entire logic of time-travel paradoxes to the existence and
counting of fixed points.

**Keywords:** Novikov self-consistency principle, causal loop, fixed point,
round-trip map, grandfather paradox, periodic point, pigeonhole principle,
discrete dynamical systems.

---

## 1. Introduction

The grandfather paradox — travel to the past, prevent your own existence, thereby
undoing the trip that made the prevention possible — has long served as the
canonical argument against time travel into the past. Igor Novikov's
*self-consistency principle* offers an alternative to outright prohibition: time
travel may be geometrically permitted, but the only histories that physically
occur are those free of internal contradiction. Whatever happens must be globally
consistent with itself.

This paper asks a mathematical rather than a physical question: **given a
formalization of what a "time loop" and a "consistent history" are, exactly when
does a consistent history exist, and how many are there?** We answer this
completely. The answer is governed by a single classical notion — the fixed point
of a self-map — and the entire theory follows from elementary induction and the
pigeonhole principle. No topology, measure theory, or physics is required; the
development is finite and combinatorial.

### Contributions

1. A minimal, general definition of a **causal loop** and of a **consistent
   history** (Section 2).
2. The **Structure Theorem** (Section 3): consistent histories are in canonical
   bijection with fixed points of the round-trip map, together with the resulting
   **cardinality identity**.
3. The **Novikov Fixed-Point Criterion** (Section 3): self-consistency is
   equivalent to the existence of a round-trip fixed point.
4. A rigorous treatment of the **grandfather paradox** as the negation loop, and
   a proof of its inconsistency (Section 4).
5. An analysis of **repeated traversal** (Section 5): the iterate identity, and
   the theorem that on finite non-empty state spaces some repetition is always
   consistent.

---

## 2. Definitions

Throughout, $X$ denotes an arbitrary non-empty set of **states**. We write
$k \bmod n$ for the least non-negative residue of $k$ modulo $n$.

### 2.1 Causal loops

**Definition 2.1 (Causal loop).** A *causal loop* on state set $X$ consists of:

- a positive integer $n$, the **length** (the number of events), with $n > 0$;
- a family of **transition maps** $\text{step}_i : X \to X$ for $i \in
  \mathbb{N}$, where $\text{step}_i$ transports the state of event $i$ to the
  state of event $i+1$.

Indices are read cyclically: the causal link out of event $k$ is governed by
$\text{step}_{\,k \bmod n}$, so the arrow out of the last event $e_{n-1}$ returns
to $e_0$. We denote a loop by $L = (n, \text{step})$.

**Definition 2.2 (Trajectory).** For a loop $L$ and a starting state $x \in X$,
the *trajectory* $T_x : \mathbb{N} \to X$ is defined by recursion:
$$T_x(0) = x, \qquad T_x(k+1) = \text{step}_{\,k \bmod n}\bigl(T_x(k)\bigr).$$
Thus $T_x(k)$ is the state produced after following $k$ causal arrows starting
from state $x$ at event $0$.

**Definition 2.3 (Round-trip map).** The *round-trip map* of $L$ is
$$R \colon X \to X, \qquad R(x) = T_x(n),$$
the state that event $0$ returns to after the trajectory traverses the loop once.
Explicitly,
$$R(x) = \text{step}_{n-1}\bigl(\text{step}_{n-2}(\cdots \text{step}_0(x)\cdots)\bigr).$$

### 2.2 Consistent histories and self-consistency

**Definition 2.4 (Consistent history).** A function $h : \mathbb{N} \to X$ is a
*consistent history* for $L$ if:

1. **(Causality)** $h(k+1) = \text{step}_{\,k \bmod n}\bigl(h(k)\bigr)$ for all
   $k \in \mathbb{N}$; and
2. **(Closure / periodicity)** $h(k + n) = h(k)$ for all $k \in \mathbb{N}$,
   i.e. $h$ is periodic with period $n$.

**Definition 2.5 (Self-consistency).** The loop $L$ is *self-consistent* if it
admits at least one consistent history. The **Novikov self-consistency
principle**, as a mathematical statement about a given loop, is exactly the
assertion that $L$ is self-consistent.

The causality condition says the history obeys every causal arrow; the closure
condition says the history genuinely lives on the cycle (event $n$ *is* event
$0$). A consistent history is thus a global, contradiction-free solution to the
loop.

---

## 3. The Structure Theorem and the Novikov criterion

We first record two elementary lemmas about trajectories.

**Lemma 3.1 (Histories are trajectories).** If $h$ satisfies the causality
condition of Definition 2.4, then $T_{h(0)}(k) = h(k)$ for all $k$.

*Proof.* Induction on $k$. For $k = 0$, $T_{h(0)}(0) = h(0)$ by definition. For
the step, $T_{h(0)}(k+1) = \text{step}_{\,k \bmod n}(T_{h(0)}(k)) =
\text{step}_{\,k \bmod n}(h(k)) = h(k+1)$, using the induction hypothesis and the
causality condition. $\qquad\blacksquare$

Lemma 3.1 shows a consistent history carries *no* information beyond its value at
event $0$: the causal arrows determine everything downstream.

**Lemma 3.2 (Fixed points unroll to periodic trajectories).** If $R(x) = x$, then
$T_x$ is periodic with period $n$: $T_x(k + n) = T_x(k)$ for all $k$.

*Proof.* Induction on $k$. For $k = 0$, $T_x(n) = R(x) = x = T_x(0)$. For the
step, write $k + 1 + n = (k + n) + 1$; then
$$T_x(k+1+n) = \text{step}_{\,(k+n) \bmod n}\bigl(T_x(k+n)\bigr)
            = \text{step}_{\,k \bmod n}\bigl(T_x(k)\bigr) = T_x(k+1),$$
using $(k+n) \bmod n = k \bmod n$ and the induction hypothesis. $\qquad\blacksquare$

**Theorem 3.3 (Structure Theorem).** For every causal loop $L$ there is a
canonical bijection
$$\{\, h : \mathbb{N} \to X \mid h \text{ is a consistent history} \,\}
\;\xrightarrow{\ \sim\ }\;
\{\, x \in X \mid R(x) = x \,\}$$
sending a history $h$ to its initial value $h(0)$, with inverse sending a fixed
point $x$ to its trajectory $T_x$.

*Proof.* We define the two maps and check they are mutually inverse.

*Forward map.* Let $h$ be a consistent history. Its value $h(0)$ is a fixed point
of $R$: by closure, $h(n) = h(0)$; by Lemma 3.1, $T_{h(0)}(n) = h(n)$; and by
definition $R(h(0)) = T_{h(0)}(n)$. Hence $R(h(0)) = h(n) = h(0)$. So $h \mapsto
h(0)$ lands in the fixed-point set.

*Backward map.* Let $x$ be a fixed point of $R$. Define $h = T_x$. It satisfies
causality by Definition 2.2, and periodicity by Lemma 3.2; hence $T_x$ is a
consistent history.

*Mutual inversion.* Starting from a history $h$: the backward map produces
$T_{h(0)}$, which equals $h$ pointwise by Lemma 3.1. Starting from a fixed point
$x$: the forward map reads off $T_x(0) = x$. Both round-trips are the identity, so
the maps are inverse bijections. $\qquad\blacksquare$

**Corollary 3.4 (Novikov Fixed-Point Criterion).** A causal loop $L$ is
self-consistent if and only if its round-trip map $R$ has a fixed point:
$$L \text{ self-consistent} \iff \exists\, x \in X,\; R(x) = x.$$

*Proof.* Immediate from Theorem 3.3: the two sets are in bijection, so one is
non-empty iff the other is. $\qquad\blacksquare$

**Corollary 3.5 (Cardinality identity).** The number of consistent histories of
$L$ equals the number of fixed points of $R$:
$$\#\{\, h \mid h \text{ consistent} \,\} = \#\{\, x \mid R(x) = x \,\}.$$

*Proof.* A bijection preserves cardinality (finite or infinite). $\qquad\blacksquare$

Corollary 3.5 turns the metaphysical question "how many ways could this loop have
resolved?" into an exact count of fixed points.

---

## 4. The grandfather paradox

We now formalize the grandfather paradox and prove its inconsistency.

**Definition 4.1 (Grandfather loop).** Let $X = \{\text{true}, \text{false}\}$ be
the two-element set of truth values (interpret $\text{true}$ as "the traveler is
born"). The *grandfather loop* $G$ has length $n = 1$ and single transition map
$$\text{step}(b) = \lnot\, b,$$
logical negation. (Being born causes the intervention that prevents birth; not
being born removes the intervention, causing birth.)

**Lemma 4.2.** The round-trip map of $G$ is negation: $R_G(b) = \lnot b$.

*Proof.* Since $n = 1$, $R_G(b) = T_b(1) = \text{step}_{\,0 \bmod 1}(b) =
\lnot b$. $\qquad\blacksquare$

**Theorem 4.3 (Grandfather paradox).** The grandfather loop $G$ admits no
consistent history; it is not self-consistent.

*Proof.* By Corollary 3.4, $G$ is self-consistent iff $R_G$ has a fixed point,
i.e. iff there is $b$ with $\lnot b = b$. Checking the two truth values:
$\lnot\,\text{true} = \text{false} \ne \text{true}$ and
$\lnot\,\text{false} = \text{true} \ne \text{false}$. There is no such $b$, so
$R_G$ has no fixed point and $G$ is inconsistent. $\qquad\blacksquare$

The paradox is thus not a vague contradiction but a precise impossibility: it
demands a fixed point of negation, and negation has none. This is the sharpest
possible statement of *why* the grandfather scenario cannot consistently occur.

By contrast, a loop whose transition is the identity has every state as a fixed
point (maximally consistent), and a loop with a constant transition $x \mapsto c$
has the unique fixed point $c$ (deterministic consistency). These exhaust the
qualitative behaviors on the one-event bit space: no fixed point (negation), one
fixed point (constant), or all (identity).

---

## 5. Repeated traversal

What happens if a traveler goes around an inconsistent loop more than once? We
formalize repeated traversal and show that inconsistency at one scale can become
consistency at another.

**Lemma 5.1 (Shift identity).** For all $x \in X$ and $m \in \mathbb{N}$,
$$T_x(n + m) = T_{R(x)}(m).$$

*Proof.* Induction on $m$. For $m = 0$, $T_x(n) = R(x) = T_{R(x)}(0)$. For the
step, $T_x(n + m + 1) = \text{step}_{\,(n+m) \bmod n}(T_x(n+m)) =
\text{step}_{\,m \bmod n}(T_{R(x)}(m)) = T_{R(x)}(m+1)$, using
$(n+m)\bmod n = m \bmod n$ and the induction hypothesis. $\qquad\blacksquare$

**Theorem 5.2 (Iterate identity).** For all $x$ and $k$,
$$R^{k}(x) = T_x(k\,n),$$
where $R^{k}$ denotes the $k$-fold composition of $R$ with itself.

*Proof.* Induction on $k$. For $k = 0$, $R^0(x) = x = T_x(0)$. For the step,
$R^{k+1}(x) = R^{k}(R(x)) = T_{R(x)}(k n) = T_x(n + kn) = T_x((k+1)n)$, using the
induction hypothesis and Lemma 5.1. $\qquad\blacksquare$

**Definition 5.3 ($k$-fold loop).** For $k > 0$, the *$k$-fold loop* $L^{k}$ has
length $kn$ and transition maps $\text{step}^{(k)}_i = \text{step}_{\,i \bmod n}$
(the original transitions repeated cyclically). It represents traversing $L$ a
total of $k$ times before closing.

**Lemma 5.4.** The trajectory of $L^{k}$ agrees with that of $L$, and its
round-trip map is the $k$-th iterate of $R$:
$$T^{(k)}_x = T_x, \qquad R_{L^{k}}(x) = R^{k}(x).$$

*Proof.* The trajectory agreement is an induction using
$(j \bmod kn) \bmod n = j \bmod n$ (valid because $n \mid kn$). Then
$R_{L^{k}}(x) = T^{(k)}_x(kn) = T_x(kn) = R^{k}(x)$ by Theorem 5.2.
$\qquad\blacksquare$

Thus **going around the loop $k$ times realizes the $k$-th iterate of the
round-trip map**, and by Corollary 3.4 the $k$-fold loop is consistent iff $R^{k}$
has a fixed point — i.e. iff $R$ has a *periodic point* of period (dividing) $k$.

**Lemma 5.5 (Periodic points on finite spaces).** If $X$ is finite and
non-empty, then every self-map $g : X \to X$ has a periodic point: there exist
$k > 0$ and $x \in X$ with $g^{k}(x) = x$.

*Proof.* Fix any $x_0 \in X$ and consider the sequence $x_0, g(x_0), g^2(x_0),
\ldots$. Since $X$ is finite, the map $m \mapsto g^{m}(x_0)$ cannot be injective on
the infinite index set $\mathbb{N}$; by pigeonhole there are indices $i < j$ with
$g^{i}(x_0) = g^{j}(x_0)$. Set $x = g^{i}(x_0)$ and $k = j - i > 0$. Then
$g^{k}(x) = g^{j-i}(g^{i}(x_0)) = g^{j}(x_0) = g^{i}(x_0) = x$. $\qquad\blacksquare$

**Theorem 5.6 (Consistency in the limit).** Let $X$ be finite and non-empty. For
*every* causal loop $L$ on $X$ there exists $k > 0$ such that the $k$-fold loop
$L^{k}$ is self-consistent.

*Proof.* Apply Lemma 5.5 to $g = R$: obtain $k > 0$ and $x$ with $R^{k}(x) = x$.
By Lemma 5.4, $R_{L^{k}}(x) = R^{k}(x) = x$, so $x$ is a fixed point of the
$k$-fold loop's round-trip map. By Corollary 3.4, $L^{k}$ is self-consistent.
$\qquad\blacksquare$

**Example 5.7 (Grandfather revisited).** For the grandfather loop $G$, $R_G$ is
negation, which has no fixed point (Theorem 4.3) but satisfies $R_G^2 = \text{id}$,
so $R_G^2$ fixes *every* state. Hence $G^2$ — going around twice — has two
consistent histories: the oscillations $(\text{true}, \text{false}, \text{true},
\ldots)$ and $(\text{false}, \text{true}, \text{false}, \ldots)$. A single-lap
paradox becomes a two-lap consistent oscillation. This is Theorem 5.6 in its
smallest instance.

---

## 6. Algorithms

The theory is entirely constructive on finite state spaces. We highlight three
procedures, developed in full (with pseudocode and code) in the accompanying
material.

- **Round-trip computation.** Given a loop and a starting state, compose the
  transitions once around to obtain $R(x)$; cost $O(n)$ evaluations.
- **Consistency decision and history enumeration.** Compute $R(x)$ for each of
  the $|X|$ states, collect the fixed points; by Corollary 3.5 these count and
  (via trajectories) reconstruct all consistent histories. Cost $O(|X|\cdot n)$.
- **Minimal consistent repetition.** Iterate $R$ from any seed until a value
  recurs (Lemma 5.5); the cycle length divides a $k$ for which $L^k$ is
  consistent. Cost $O(|X|\cdot n)$ by Floyd/Brent cycle detection or direct
  orbit tracking.

---

## 7. Applications and interpretation

The framework offers a common language for the standard time-travel puzzles:

- **Grandfather paradox:** negation loop; no fixed point; inconsistent.
- **Self-fulfilling (predestination) loop:** any transition with a fixed point;
  the timeline you create is the one you came from.
- **Bootstrap paradox:** information with no origin is a nontrivial fixed point of
  an information-carrying transition; consistency is fixedness, and the "origin"
  question is dissolved — the fixed point *is* the whole loop.
- **Multi-valued outcomes:** the number of possible resolutions is the number of
  fixed points (Corollary 3.5), giving a quantitative notion of how
  under-determined a loop is.

The repeated-traversal results (Section 5) formalize a subtle point: whether a
loop is "paradoxical" can depend on the scale at which it closes. A process
inconsistent over one period may be perfectly consistent over a longer period.

---

## 8. Discussion and future work

The theory here is deliberately elementary — finite, combinatorial, and
measure-free — which is exactly what makes the Novikov principle provable rather
than merely postulated. Several natural extensions suggest themselves.

1. **Continuous / topological Novikov.** Replace finiteness by a compact convex
   state space and continuous transitions, deriving existence of a consistent
   history from the Brouwer or Schauder fixed-point theorem instead of
   pigeonhole.

2. **Probabilistic self-consistency.** Let each transition be a Markov kernel; a
   consistent history becomes a stationary distribution of the round-trip kernel.
   Stationary distributions always exist on finite state spaces, so the Novikov
   principle holds automatically, and one can quantify "how paradoxical" a loop is
   by the entropy of that distribution.

3. **Counting and generic loops.** Compute the expected number of consistent
   histories of a random loop via fixed-point statistics of random self-maps, and
   characterize which loop lengths force consistency.

4. **Uniqueness / determinism.** Give conditions (e.g. each transition a
   contraction, or the round trip having a unique fixed point) under which the
   consistent history is unique — the "deterministic time travel" regime.

5. **Interacting loops.** Model several causal loops sharing state and study joint
   consistency as a simultaneous fixed-point problem, connecting to Nash-style
   existence results.

---

## 9. Conclusion

We have reduced the logic of time-travel causal loops to the theory of fixed
points. A consistent history is exactly a fixed point of the round-trip map
(Structure Theorem); the Novikov self-consistency principle is exactly the
existence of such a fixed point (Novikov criterion); the grandfather paradox is
exactly the fixed-point-free negation loop; and on finite state spaces, repeated
traversal always restores consistency by the pigeonhole principle. The mystery of
time-travel paradoxes, on this account, is the ancient and well-understood
mystery of whether a map fixes a point.
