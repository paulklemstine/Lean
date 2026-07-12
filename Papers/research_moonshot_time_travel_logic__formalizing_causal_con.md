# Time-Travel Logic: A Fixed-Point Theory of Causal Consistency

## Abstract

We give a self-contained mathematical theory of closed timelike curves (CTCs)
and time-travel paradoxes, organized around a single object: the **loop map**
$f \colon S \to S$, which records the net effect on the state of the world of one
traversal of a closed timelike curve. We identify the *Novikov self-consistency
principle* with the existence of a fixed point of $f$, and prove this abstract
condition equivalent to the existence of a concrete **closed timelike history** of
the discrete loop. We then formalize the **grandfather paradox** as a
fixed-point-free ("paradoxical") loop and prove it genuinely inconsistent. Three
positive consistency guarantees follow from classical fixed-point theorems:
monotone loops on a complete lattice are self-consistent (Knaster–Tarski);
continuous loops on the phase interval $[0,1]$ are self-consistent (the
one-dimensional Brouwer property, via the intermediate value theorem), a toy
model of the conjecture that every CTC in the Gödel universe is self-consistent;
and involutive loops on a state space of odd cardinality are self-consistent (a
parity argument). Finally, we develop the **many-worlds** resolution: a branching
evolution on $S \times \mathbb{N}$ in which the traveler is always sent to a fresh
branch. We prove that branching never repeats a state, and that *every*
paradoxical action nonetheless admits a fully consistent branching history. The
grandfather action, impossible in a single timeline, becomes consistent in the
multiverse. The results form a single deductive chain from the definitions to the
branching resolution.

**Keywords:** closed timelike curve, self-consistency, fixed point,
Knaster–Tarski theorem, Brouwer fixed point, intermediate value theorem,
involution, parity, many-worlds, branching timelines.

---

## 1. Introduction

Time travel into the past raises the possibility of *causal loops*: sequences of
events $e_1 \to e_2 \to \dots \to e_n \to e_1$ in which each event causes the
next and the last causes the first. Such a loop, a **closed timelike curve**
(CTC), is not forbidden by the field equations of general relativity — explicit
solutions such as the Gödel universe contain them — and it forces a foundational
question: which causal loops describe a coherent history, and which collapse into
paradox?

The physics literature answers with the **Novikov self-consistency principle**:
the only processes that can occur around a CTC are those globally consistent with
themselves. The grandfather paradox — a traveler who prevents their own
existence — is then excluded not by fiat but because no self-consistent history
realizes it. This paper renders that informal principle as mathematics.

Our organizing abstraction is deliberately minimal. Whatever the underlying
spacetime, the *net effect* of traversing a CTC once is a function
$f \colon S \to S$ on the space $S$ of world-states. We call $f$ the **loop map**.
The self-consistency principle then reads: *the loop admits a consistent history
if and only if $f$ has a fixed point.* This reframing converts a philosophical
debate into a question in fixed-point theory, where a rich classical toolkit
applies.

The paper proceeds as a single chain. Section 2 sets up the loop map and the
fixed-point criterion. Section 3 introduces discrete loops and closed timelike
histories and proves their equivalence with the fixed-point criterion. Section 4
formalizes and refutes the grandfather paradox. Section 5 gives three positive
consistency guarantees from order theory, topology, and parity. Section 6
develops the branching (many-worlds) resolution. Section 7 discusses
applications and Section 8 lists future directions.

---

## 2. The loop map and the self-consistency principle

Fix a type $S$ of **world-states** — an exhaustive description of everything the
loop can affect.

**Definition 2.1 (causal loop).** A *causal loop* (closed timelike curve) on $S$
is a function $f \colon S \to S$, called the **loop map** or **evolution**. The
value $f(s)$ is the world-state produced by feeding $s$ once around the loop.

**Definition 2.2 (self-consistency).** A causal loop $f$ is **self-consistent**
if there exists a world-state reproduced by one traversal:
$$\exists\, s \in S, \quad f(s) = s.$$
Such an $s$ is a *fixed point* of $f$; it is a history compatible with itself.

Definition 2.2 *is* the Novikov principle in fixed-point form. We record the
tautological but conceptually central restatement.

**Theorem 2.3 (fixed-point criterion).** A causal loop $f$ is self-consistent if
and only if $f$ has a fixed point. $\qquad\blacksquare$

The content of the theory is not this restatement but what fixed-point theory
then tells us: which loops must have fixed points, and which cannot.

---

## 3. Discrete loops and closed timelike histories

A CTC is physically a chain of causal steps, not a single jump. We model a loop
of length $n$ by a sequence of step maps $\text{steps} \colon \mathbb{N} \to (S
\to S)$, where $\text{steps}(k)$ maps the state at event $e_{k+1}$ to the state at
event $e_{k+2}$.

**Definition 3.1 (traversal).** The *partial traversal* is defined by recursion:
$$\operatorname{tr}(0, s) = s, \qquad
  \operatorname{tr}(k+1, s) = \text{steps}(k)\big(\operatorname{tr}(k, s)\big).$$
Thus $\operatorname{tr}(k, s)$ is the state after applying the first $k$ steps
from $s$, and the full length-$n$ loop map is $s \mapsto \operatorname{tr}(n, s)$.

**Definition 3.2 (closed timelike history).** A *closed timelike history* of the
length-$n$ loop is a labeling $h \colon \mathbb{N} \to S$ of events by
world-states such that
$$\text{(steps realized)}\quad h(k+1) = \text{steps}(k)\big(h(k)\big) \text{ for
all } k < n, \qquad \text{(loop closes)}\quad h(n) = h(0).$$
It is the "diary" of a self-consistent journey: every effect is produced by its
cause, and the loop returns to its start.

**Lemma 3.3 (traversal recovers a history).** If $h$ is a closed timelike history
of the length-$n$ loop, then for all $k \le n$,
$\operatorname{tr}(k, h(0)) = h(k)$.

*Proof.* Induction on $k$. The base case is $\operatorname{tr}(0, h(0)) = h(0)$.
For the step, assume $\operatorname{tr}(k, h(0)) = h(k)$ with $k < n$. Then
$\operatorname{tr}(k+1, h(0)) = \text{steps}(k)(\operatorname{tr}(k, h(0))) =
\text{steps}(k)(h(k)) = h(k+1)$, using the induction hypothesis and the
step-realized condition. $\qquad\blacksquare$

**Theorem 3.4 (Novikov equivalence).** The length-$n$ loop is self-consistent —
its loop map $s \mapsto \operatorname{tr}(n, s)$ has a fixed point — if and only
if it admits a closed timelike history:
$$\big(\exists\, s,\ \operatorname{tr}(n, s) = s\big) \iff \big(\exists\, h,\
\text{$h$ is a closed timelike history of length } n\big).$$

*Proof.* ($\Rightarrow$) Given a fixed point $s$ with $\operatorname{tr}(n,s)=s$,
define $h(k) = \operatorname{tr}(k, s)$. The step-realized condition holds by
Definition 3.1, and $h(n) = \operatorname{tr}(n, s) = s = h(0)$, so the loop
closes.

($\Leftarrow$) Given a closed timelike history $h$, take $s = h(0)$. By Lemma 3.3
with $k = n$, $\operatorname{tr}(n, h(0)) = h(n) = h(0)$, so $h(0)$ is a fixed
point of the length-$n$ loop map. $\qquad\blacksquare$

Theorem 3.4 justifies passing freely between the abstract fixed-point view and
the concrete event-by-event view: global self-consistency is equivalent to
step-local consistency that closes.

---

## 4. The grandfather paradox

**Definition 4.1 (paradoxical loop).** A loop map $f \colon S \to S$ is
**paradoxical** if no world-state is left unchanged by a traversal:
$$\forall\, s \in S, \quad f(s) \neq s.$$

**Theorem 4.2 (paradoxical loops are inconsistent).** A paradoxical loop map has
no fixed point, hence is not self-consistent.

*Proof.* Immediate: a fixed point $s$ would satisfy $f(s) = s$, contradicting
$f(s) \neq s$. $\qquad\blacksquare$

We now instantiate this with the grandfather action. Reduce the ancestor's fate
to a single bit, $S = \{\text{alive}, \text{dead}\}$, identified with the boolean
values. The traveler's action, carried around the loop, flips the bit: the loop
map is boolean negation $\lnot$, sending alive to dead and dead to alive.

**Proposition 4.3 (the grandfather loop is paradoxical).** Boolean negation
$\lnot$ is paradoxical: $\lnot s \neq s$ for both values of $s$.

*Proof.* Check the two cases: $\lnot\,\text{true} = \text{false} \neq
\text{true}$ and $\lnot\,\text{false} = \text{true} \neq \text{false}$.
$\qquad\blacksquare$

**Theorem 4.4 (the grandfather paradox is impossible).** The grandfather loop
$\lnot$ admits no self-consistent history.

*Proof.* Combine Proposition 4.3 with Theorem 4.2. $\qquad\blacksquare$

Theorem 4.4 is the precise sense in which the grandfather paradox cannot occur:
not merely that it is counterintuitive, but that there is provably no assignment
of world-states closing the loop. Under the self-consistency principle,
nature excludes it.

---

## 5. Positive consistency guarantees

Impossibility results have counterparts: broad classes of loops that are
*guaranteed* self-consistent. Each of the following draws on a classical
fixed-point theorem.

### 5.1 Order: monotone loops (Knaster–Tarski)

**Theorem 5.1 (monotone loops are self-consistent).** Let $S$ be a complete
lattice and $f \colon S \to S$ monotone (order-preserving:
$x \le y \Rightarrow f(x) \le f(y)$). Then $f$ is self-consistent; indeed its
least fixed point
$$\operatorname{lfp}(f) = \bigsqcap \{\, x : f(x) \le x \,\}$$
satisfies $f(\operatorname{lfp}(f)) = \operatorname{lfp}(f)$.

*Proof.* This is the Knaster–Tarski theorem. Let $P = \{x : f(x) \le x\}$ be the
set of prefixed points and $m = \bigsqcap P$. For any $x \in P$, monotonicity
gives $f(m) \le f(x) \le x$; taking the infimum over $x \in P$ yields
$f(m) \le m$, so $m \in P$. Applying $f$ and using monotonicity,
$f(f(m)) \le f(m)$, so $f(m) \in P$ and hence $m \le f(m)$. Therefore
$f(m) = m$. $\qquad\blacksquare$

The fixed point is *canonical*: the least self-consistent world the loop can
settle into. Ordered, gap-free state spaces with order-preserving dynamics can
never be paradoxical.

### 5.2 Topology: continuous loops on a phase interval

**Theorem 5.2 (continuous loops are self-consistent).** Let $f \colon [0,1] \to
[0,1]$ be continuous (as a self-map of the phase interval). Then $f$ has a fixed
point: there exists $s \in [0,1]$ with $f(s) = s$.

*Proof.* This is the one-dimensional Brouwer fixed-point property, via the
intermediate value theorem. Put $g(x) = f(x) - x$, continuous on $[0,1]$. Since
$f$ maps into $[0,1]$, we have $g(0) = f(0) - 0 \ge 0$ and $g(1) = f(1) - 1 \le
0$. A continuous function that is nonnegative at $0$ and nonpositive at $1$ takes
the value $0$ at some $s \in [0,1]$; there $f(s) = s$. $\qquad\blacksquare$

This is a toy model of the conjecture that **every closed timelike curve in the
Gödel universe is self-consistent.** When the CTC phase space is a continuous,
self-contained region and the loop map is continuous, a fixed point is forced.
The natural strengthening to a continuous self-map of a nonempty compact convex
subset of $\mathbb{R}^n$ (full Brouwer) is discussed in Section 8.

### 5.3 Parity: involutive loops on odd state spaces

**Theorem 5.3 (odd involutive loops are self-consistent).** Let $S$ be finite of
odd cardinality and let $f \colon S \to S$ be an involution ($f(f(s)) = s$ for
all $s$; going around the loop twice restores the state). Then $f$ has a fixed
point.

*Proof.* A parity/orbit count. As an involution, $f$ is a bijection whose square
is the identity, so it is a permutation all of whose cycles have length $1$ or
$2$. The length-$2$ cycles partition the non-fixed states into disjoint pairs
$\{s, f(s)\}$, accounting for an even number of states. If $S$ has odd
cardinality, the number of non-fixed states cannot be even unless it is strictly
less than $|S|$; equivalently, since $|S|$ is odd it is not divisible by $2$, and
a fixed-point-free permutation of order dividing $2$ would pair all elements,
forcing $|S|$ even. Hence at least one state is fixed. $\qquad\blacksquare$

Odd symmetry leaves no room for a paradox: at least one world is always left
invariant.

---

## 6. Branching (many-worlds) time travel

The results above concern a *single* timeline that must close on itself. The
many-worlds interpretation offers a different resolution: rather than forcing the
loop to close, the traveler is sent to a **fresh branch** of reality. We model
the multiverse state as a pair $(s, b) \in S \times \mathbb{N}$ — a world-state
together with a branch index — and define branching evolution to apply the
action and advance the branch.

**Definition 6.1 (branching evolution).** For an action $a \colon S \to S$, the
*branching evolution* is
$$\operatorname{branch}_a \colon S \times \mathbb{N} \to S \times \mathbb{N},
\qquad \operatorname{branch}_a(s, b) = (a(s),\, b + 1).$$

**Theorem 6.2 (a fresh branch every time).** For any action $a$, the branching
evolution $\operatorname{branch}_a$ is paradoxical as an ordinary loop map on
$S \times \mathbb{N}$: it has no fixed point, because the branch index strictly
increases at each step.

*Proof.* A fixed point $(s,b)$ would satisfy $(a(s), b+1) = (s,b)$, forcing
$b + 1 = b$, which is impossible in $\mathbb{N}$. $\qquad\blacksquare$

Thus branching never returns to a multiverse-state already visited: the history
of a branching traveler never loops. Crucially, this non-closure is exactly what
*permits* consistency, because it dissolves the demand for a fixed point.

**Theorem 6.3 (branching history exists).** For any action $a$ and any initial
world-state $s_0$, there is a history $H \colon \mathbb{N} \to S \times
\mathbb{N}$ with
$$H(0) = (s_0, 0), \qquad H(k+1) = \operatorname{branch}_a\big(H(k)\big) \text{
for all } k.$$

*Proof.* Define $H$ by recursion: $H(0) = (s_0, 0)$ and $H(k+1) =
\operatorname{branch}_a(H(k))$. This is a valid definition by recursion on
$\mathbb{N}$ and satisfies both requirements by construction. $\qquad\blacksquare$

**Theorem 6.4 (branching resolves every paradox).** Let $a \colon S \to S$ be
*any* paradoxical action (so it has no single-timeline fixed point). Then both:

1. the single-timeline loop is inconsistent — there is no $s$ with $a(s) = s$; and
2. the branching model nonetheless admits a fully consistent branching history:
   there exists $H$ with $H(0) = (s_0, 0)$ and $H(k+1) =
   \operatorname{branch}_a(H(k))$ for all $k$.

*Proof.* Part 1 is the definition of paradoxical together with Theorem 4.2. Part
2 is Theorem 6.3, which places no hypothesis on $a$. $\qquad\blacksquare$

**Corollary 6.5 (grandfather in the multiverse).** The grandfather action
$\lnot$ on $S = \{\text{alive}, \text{dead}\}$ has no single-timeline fixed point,
yet admits a consistent branching history starting from any $s_0$: the traveler
kills the ancestor in a new branch and lives on there.

*Proof.* Apply Theorem 6.4 with $a = \lnot$, paradoxical by Proposition 4.3.
$\qquad\blacksquare$

The single-timeline obstruction — a loop map with no fixed point — is precisely
what branching sidesteps, because branching never asks the map to fix anything.

---

## 7. Applications and interpretation

**A unifying diagnostic.** The theory yields a simple decision procedure for the
consistency of any modeled loop: form the loop map $f$ and ask whether it has a
fixed point. Impossibility comes from fixed-point-free structure (flips,
negations, strictly advancing counters); guaranteed consistency comes from order
(monotonicity on a complete lattice), topology (continuity on a compact interval,
and its higher-dimensional analogues), or parity (odd involutions).

**Beyond time machines.** The loop map is ubiquitous. Self-referential
equilibria (expectations that determine the prices that determine the
expectations), population recurrences, fixed-point iterations in numerical
analysis, and feedback in control and programming semantics are all instances of
"find a state reproduced by the dynamics." The consistency dichotomy developed
here — guaranteed fixed points versus provable fixed-point freeness, with
branching as a universal escape — transfers directly to these settings. In
particular, the Knaster–Tarski instance underlies denotational semantics of
recursion, and the interval instance is the workhorse existence theorem behind
one-dimensional equilibrium models.

**Interpretational payoff.** The results sharpen the standard philosophical
positions. The self-consistency principle is *not* an extra postulate once one
accepts a single timeline: it is equivalent to the demand for a fixed point, and
that demand is met or refuted by the structure of the loop map alone. The
many-worlds position is likewise made precise: branching is consistent for
*every* action, including the paradoxical ones, because the branch index breaks
every cycle.

---

## 8. Future directions

- **Full Brouwer in higher dimensions.** Replace the one-dimensional interval
  model of Theorem 5.2 by a continuous self-map of a nonempty compact convex
  subset of $\mathbb{R}^n$ (or a simplex), giving self-consistency for
  higher-dimensional CTC phase spaces. This requires Brouwer's fixed-point
  theorem at the appropriate level of generality.

- **The Gödel universe, honestly.** Formalize the Gödel metric and its timelike
  geodesics, define a CTC intrinsically, and derive the loop map from the
  geometry so that the continuous-consistency theorem (or its $\mathbb{R}^n$
  upgrade) applies. The conjecture "every CTC in a Gödel universe is
  self-consistent" would then become a corollary rather than a modeled instance.

- **Quantitative Novikov / measure of consistent histories.** Put a probability
  measure on $S$ and study the measure of the fixed-point set, formalizing the
  folklore that "consistent histories have probability 1." For contractions this
  connects to Banach fixed points (uniqueness); for measure-preserving loops, to
  Poincaré recurrence.

- **Branching as a category / tree.** Model the multiverse as a rooted tree of
  branches and show the branching evolution is an injective, acyclic dynamical
  system with no cycle across branches, formalizing in full generality why
  many-worlds time travel cannot produce paradoxes.

- **A fixed-point-free / inconsistency spectrum.** Classify which loop maps on a
  finite $S$ are self-consistent purely in terms of their cycle structure,
  yielding a complete combinatorial dichotomy between consistent and paradoxical
  finite loops.

---

## 9. Conclusion

Modeling a closed timelike curve by its loop map $f \colon S \to S$ turns the
Novikov self-consistency principle into the existence of a fixed point, and
equates it with the existence of a closed timelike history of the discrete loop.
Within this frame the grandfather paradox is provably impossible, three classical
fixed-point theorems supply broad guarantees of consistency, and a branching
multiverse resolves *every* paradoxical action by refusing to close the loop. The
logic of time travel is, in the end, the logic of fixed points.
