# A Contrarian Fixed-Point Analysis of Causal Loops and the Novikov Self-Consistency Principle

## Abstract

We develop a compact mathematical theory of closed timelike curves in which a causal
loop is modelled by its one-traversal evolution map $\mathrm{evolve} : X \to X$ on a
space $X$ of world-states, and the Novikov self-consistency principle is identified
with the existence of a fixed point. Under this dictionary a *consistent history* is
a solution of $\mathrm{evolve}(x) = x$, and the *consistency count* is the number of
such solutions. Rather than only establishing existence of consistent histories, we
take a deliberately contrarian stance and test a battery of natural structural
hypotheses that appear to force self-consistency. We prove that three of them fail —
reversibility (bijectivity), descent along repetition, and closure under composition
— by exhibiting explicit minimal counterexamples. We then isolate the hypotheses
that genuinely compel consistency: consistency ascends under repetition; a
contracting loop on a complete state space has a *unique* consistent history (via the
Banach fixed-point theorem); an involutive loop on a finite state space satisfies the
parity congruence $(\text{consistency count}) \equiv |X| \pmod 2$, whence odd-sized
worlds always admit an odd (hence positive) number of consistent histories; and any
loop on a finite non-empty world becomes consistent after some positive number of
repetitions. We close with concrete counts and a program of extensions to prime-order
loops, topological and probabilistic settings, and interacting loops.

**Keywords:** Novikov self-consistency principle, closed timelike curve, fixed point,
Banach contraction, involution, parity, pigeonhole, causal loop, grandfather paradox.

## 1. Introduction

The grandfather paradox is the canonical objection to backward time travel: an agent
travels to the past and prevents its own existence, generating a contradiction. The
**Novikov self-consistency principle** resolves the objection not by forbidding time
travel but by forbidding *inconsistent* time travel: the only physically realizable
histories along a closed timelike curve are those that are globally self-consistent.
Informally, the universe admits only those scripts that close up on themselves.

Our aim is to give this principle a spare, exact mathematical formulation and then to
interrogate it. The formulation is elementary: a causal loop is a self-map
$\mathrm{evolve} : X \to X$ of the space $X$ of complete world-states, and a
self-consistent history is a fixed point. What makes the subject rich is not this
translation but the *contrarian* questions it invites. Existence theorems are only
half of the story; the sharper question is which structural features of a loop
*force* consistency and which merely appear to. We assemble a list of plausible
"forcing" hypotheses, and for each we either supply a proof or destroy it with an
explicit counterexample. The resulting map of the territory is asymmetric and, we
think, genuinely surprising.

### Contributions

1. A minimal model of causal loops as self-maps, with self-consistency as the
   existence of a fixed point and a consistency count equal to the number of fixed
   points (Section 2).
2. Three disproofs, with explicit minimal witnesses: reversibility does not force
   consistency; consistency does not descend along repetition; consistency is not
   compositional (Section 3).
3. Four positive results: consistency ascends under repetition; a contracting loop
   has a unique consistent history; an involutive loop satisfies a parity congruence
   for its consistency count, with an odd-world corollary; and every finite loop is
   eventually consistent (Section 4).
4. Concrete consistency counts for the grandfather and identity loops, and a research
   program of extensions (Sections 5–6).

## 2. The model

Throughout, $X$ denotes a set (the *state space*), whose elements are complete
world-states.

**Definition 2.1 (Causal loop).** A *causal loop* on $X$ is a function
$\mathrm{evolve} : X \to X$. The value $\mathrm{evolve}(x)$ is the world-state
produced by feeding the state $x$ once around the loop.

**Definition 2.2 (Self-consistency / Novikov principle).** A causal loop
$\mathrm{evolve}$ is *self-consistent* if it possesses a fixed point:

$$\exists\, x \in X, \quad \mathrm{evolve}(x) = x.$$

Such an $x$ is a *consistent history*: the state the world is in when the loop closes
coincides with the state it started from, so no contradiction arises.

**Definition 2.3 (Consistency count).** If $X$ is finite, the *consistency count* of
$\mathrm{evolve}$ is the number of consistent histories,

$$c(\mathrm{evolve}) := \bigl|\{\, x \in X : \mathrm{evolve}(x) = x \,\}\bigr|.$$

**Proposition 2.4 (Count detects consistency).** If $c(\mathrm{evolve}) > 0$ then
$\mathrm{evolve}$ is self-consistent.

*Proof.* A non-empty finite set of fixed points contains an element, which is by
definition a consistent history. $\qquad\blacksquare$

The whole development rests on the identification "self-consistent history = fixed
point." Every subsequent theorem is a statement about when self-maps have fixed
points, and how many.

**Running examples.** Two loops recur throughout.

- *The grandfather loop.* Take $X = \{\mathsf{T}, \mathsf{F}\}$ (a two-state world,
  read as "the traveller exists / does not exist") and
  $\mathrm{evolve}(x) = \lnot x$. This is the logical negation: it swaps the two
  states.
- *The identity loop.* Take any $X$ and $\mathrm{evolve}(x) = x$. Every state is a
  consistent history.

## 3. Disproofs: hypotheses that do not force consistency

We now refute three natural conjectures. Each is a statement of the form "structural
property $P$ of a loop forces self-consistency," and each is destroyed by a small
explicit witness. The value of these results is cautionary: they show that broad,
physically appealing regularity conditions are insufficient, so that the positive
theorems of Section 4 are doing real work.

### 3.1 Reversibility does not force consistency

A loop is *reversible* if its evolution map is a bijection — an information-preserving
one-to-one correspondence of states with itself. Reversibility is the hallmark of
well-behaved, time-symmetric dynamics, so one might expect it to guarantee a
consistent history.

**Theorem 3.1 (Reversibility is insufficient).** It is not the case that every causal
loop on a finite non-empty state space whose evolution map is a bijection is
self-consistent.

*Proof.* The grandfather loop $\mathrm{evolve}(x) = \lnot x$ on
$X = \{\mathsf{T},\mathsf{F}\}$ is a bijection: it is its own inverse, permuting the
two states. But $\lnot\mathsf{T} = \mathsf{F} \ne \mathsf{T}$ and
$\lnot\mathsf{F} = \mathsf{T} \ne \mathsf{F}$, so it has no fixed point. Reversibility
holds; self-consistency fails. $\qquad\blacksquare$

### 3.2 Consistency does not descend along repetition

Write $\mathrm{evolve}^{[k]}$ for the loop traversed $k$ times (the $k$-fold
composition of $\mathrm{evolve}$ with itself). One might hope that if the *double*
loop $\mathrm{evolve}^{[2]}$ is consistent, then the single loop must be as well.

**Theorem 3.2 (Consistency does not descend).** There is a causal loop
$\mathrm{evolve}$ such that $\mathrm{evolve}^{[2]}$ is self-consistent but
$\mathrm{evolve}$ is not.

*Proof.* Take again the grandfather loop on $\{\mathsf{T},\mathsf{F}\}$. Its double
traversal is $\lnot\lnot x = x$, the identity, which is consistent at every state. Yet
$\mathrm{evolve}$ itself has no fixed point, as computed above. $\qquad\blacksquare$

### 3.3 Consistency is not compositional

If two loops share a state space and each is self-consistent, is their composite (run
one, then the other) self-consistent?

**Theorem 3.3 (Consistency is not compositional).** There exist self-consistent
causal loops $f, g$ on a common finite state space whose composite $f \circ g$ is not
self-consistent.

*Proof.* Let $X = \{0,1,2\}$. Let $f$ be the transposition swapping $0$ and $1$ and
fixing $2$; then $f(2) = 2$, so $f$ is self-consistent. Let $g$ be the transposition
swapping $1$ and $2$ and fixing $0$; then $g(0) = 0$, so $g$ is self-consistent.
Compute the composite $f \circ g$ (apply $g$, then $f$):

$$0 \xmapsto{g} 0 \xmapsto{f} 1, \qquad 1 \xmapsto{g} 2 \xmapsto{f} 2, \qquad 2 \xmapsto{g} 1 \xmapsto{f} 0.$$

Thus $f \circ g$ is the $3$-cycle $0 \to 1 \to 2 \to 0$, which fixes no point. Two
consistent loops compose to a paradoxical one. $\qquad\blacksquare$

## 4. Proofs: hypotheses that do force consistency

We now turn to the structural hypotheses that genuinely compel self-consistency.

### 4.1 Consistency ascends along repetition

**Theorem 4.1 (Consistency ascends).** If a causal loop $\mathrm{evolve}$ is
self-consistent, then for every $k \in \mathbb{N}$ the repeated loop
$\mathrm{evolve}^{[k]}$ is self-consistent.

*Proof.* Let $x$ be a consistent history, so $\mathrm{evolve}(x) = x$. By induction on
$k$, applying $\mathrm{evolve}$ to a fixed point returns it unchanged, so
$\mathrm{evolve}^{[k]}(x) = x$ for all $k$. Hence $x$ is a consistent history of
$\mathrm{evolve}^{[k]}$. $\qquad\blacksquare$

Together with Theorem 3.2 this pins down the exact asymmetry: consistency propagates
from a loop to all of its repetitions, but not back from a repetition to the loop.

### 4.2 Deterministic time travel: contraction yields a unique history

We now equip $X$ with a metric and ask for a *quantitative* regularity condition.
Recall that $\mathrm{evolve}$ is a *contraction with constant* $K \in [0,1)$ if

$$d(\mathrm{evolve}(x), \mathrm{evolve}(y)) \le K\, d(x, y) \quad \text{for all } x, y \in X.$$

**Theorem 4.2 (Deterministic time travel).** Let $X$ be a non-empty complete metric
space and let $\mathrm{evolve} : X \to X$ be a contraction with constant $K < 1$. Then
$\mathrm{evolve}$ has a unique consistent history: there is exactly one $x$ with
$\mathrm{evolve}(x) = x$.

*Proof.* This is the Banach fixed-point theorem. Existence: pick any $x_0$ and iterate
$x_{n+1} = \mathrm{evolve}(x_n)$. The contraction bound gives
$d(x_{n+1}, x_n) \le K^n d(x_1, x_0)$, so $(x_n)$ is Cauchy; by completeness it
converges to some $x^\star$, and continuity of $\mathrm{evolve}$ forces
$\mathrm{evolve}(x^\star) = x^\star$. Uniqueness: if $\mathrm{evolve}(x) = x$ and
$\mathrm{evolve}(y) = y$ then $d(x,y) = d(\mathrm{evolve}(x), \mathrm{evolve}(y)) \le
K\, d(x,y)$, and since $K < 1$ this forces $d(x,y) = 0$, i.e. $x = y$.
$\qquad\blacksquare$

Interpretively, this is the *deterministic* regime of time travel: the past does not
merely admit a consistent continuation, it pins the entire history down uniquely, and
the unique history is the limit of iterating the loop from any starting guess.

### 4.3 Quantitative Novikov for involutive loops

A loop is *involutive* if traversing it twice restores every state:
$\mathrm{evolve}(\mathrm{evolve}(x)) = x$ for all $x$. Involutive loops are the
"reversible-by-symmetry" loops; the grandfather loop is the smallest paradoxical
example.

**Theorem 4.3 (Parity congruence).** Let $X$ be finite and let $\mathrm{evolve}$ be
involutive. Then the consistency count satisfies

$$c(\mathrm{evolve}) \equiv |X| \pmod 2.$$

*Proof.* An involution is a permutation of order dividing $2$; as such it decomposes
$X$ into fixed points and $2$-cycles (transposed pairs). Concretely, partition $X$
into the set $\mathrm{Fix} = \{x : \mathrm{evolve}(x) = x\}$ and its complement
$\mathrm{Mov} = \{x : \mathrm{evolve}(x) \ne x\}$. On $\mathrm{Mov}$ the map
$\mathrm{evolve}$ is a fixed-point-free involution, so it pairs each moved state with
a distinct partner; consequently $|\mathrm{Mov}|$ is even. (Equivalently, the support
of a permutation equal to its own inverse and of order $2$ has even cardinality.)
Therefore

$$|X| = |\mathrm{Fix}| + |\mathrm{Mov}| = c(\mathrm{evolve}) + (\text{even}),$$

so $c(\mathrm{evolve})$ and $|X|$ have the same parity. $\qquad\blacksquare$

This is a *quantitative* Novikov principle: it constrains not only whether consistent
histories exist but how many there can be, modulo $2$.

**Corollary 4.4 (Odd worlds are always consistent).** If $X$ is finite of odd
cardinality and $\mathrm{evolve}$ is involutive, then $c(\mathrm{evolve})$ is odd; in
particular $c(\mathrm{evolve}) \ge 1$, so $\mathrm{evolve}$ is self-consistent.

*Proof.* By Theorem 4.3, $c(\mathrm{evolve}) \equiv |X| \equiv 1 \pmod 2$, so the
count is odd and hence positive. $\qquad\blacksquare$

The grandfather loop evades this corollary only because its world has even size $2$;
enlarging the world to an odd number of states makes an involutive paradox
impossible.

### 4.4 Eventual consistency on finite worlds

Finally, the most general guarantee, requiring no structure on the loop beyond a
finite non-empty state space.

**Theorem 4.5 (Eventual consistency).** Let $X$ be finite and non-empty and let
$\mathrm{evolve} : X \to X$ be any causal loop. Then there exists $k \ge 1$ such that
the repeated loop $\mathrm{evolve}^{[k]}$ is self-consistent.

*Proof.* Fix any $x_0 \in X$ and consider the orbit $x_0, \mathrm{evolve}(x_0),
\mathrm{evolve}^{[2]}(x_0), \dots$. Since $X$ is finite, by the pigeonhole principle
there are indices $i < j$ with $\mathrm{evolve}^{[i]}(x_0) =
\mathrm{evolve}^{[j]}(x_0)$. Set $y = \mathrm{evolve}^{[i]}(x_0)$ and $k = j - i \ge
1$. Applying $\mathrm{evolve}^{[i]}$ to both sides and using that iterates commute,
$\mathrm{evolve}^{[k]}(y) = y$. Thus $y$ is a consistent history of
$\mathrm{evolve}^{[k]}$. $\qquad\blacksquare$

Paradoxes may obstruct a single traversal, but never every repetition: on a finite
world, consistency is eventually inevitable.

## 5. Concrete counts

The two running examples make the counts fully explicit.

**Proposition 5.1 (Grandfather count).** For the grandfather loop
$\mathrm{evolve}(x) = \lnot x$ on $\{\mathsf{T},\mathsf{F}\}$, the consistency count is
$c(\mathrm{evolve}) = 0$.

*Proof.* Neither state is fixed, so the fixed-point set is empty. $\qquad\blacksquare$

**Proposition 5.2 (Identity count).** For the identity loop on a two-state world, the
consistency count is $2$.

*Proof.* Every state is fixed, and there are two states. $\qquad\blacksquare$

Note the consistency with Theorem 4.3: the grandfather loop is involutive on a
two-state (even) world, and indeed $0 \equiv 2 \equiv 0 \pmod 2$; the identity loop is
also involutive, and $2 \equiv 2 \pmod 2$.

## 6. Discussion and future work

The results assemble into a clean picture. Self-consistency of a causal loop is a
fixed-point property, and the character of the loop determines how strongly it is
compelled:

- *Weak, appealing hypotheses are insufficient.* Reversibility (§3.1), descent along
  repetition (§3.2), and closure under composition (§3.3) all fail to force
  consistency.
- *Specific structure suffices.* Ascent along repetition (§4.1), metric contraction
  (§4.2), and involutivity on a finite world (§4.3–4.4) each force consistency, the
  last two even quantitatively; and finiteness alone forces *eventual* consistency
  (§4.5).

Several directions extend this program.

**Sharper congruences.** The parity law $c(\mathrm{evolve}) \equiv |X| \pmod 2$ for
involutions is the order-$2$ case of a general orbit-counting phenomenon. For a loop
of prime order $p$ (that is, $\mathrm{evolve}^{[p]} = \mathrm{id}$) one expects
$c(\mathrm{evolve}) \equiv |X| \pmod p$, a Cauchy–Frobenius-style congruence yielding
mod-$p$ obstructions to consistency.

**Compositional repair.** Theorem 3.3 shows consistency is not compositional. What
minimal extra hypothesis repairs it? A natural conjecture: if two self-consistent
loops *commute*, their composite is self-consistent, because their fixed-point sets
interact controllably.

**Continuous / topological Novikov.** Replace finiteness by a compact convex state
space and continuous causal steps, deriving existence of a consistent history from the
Brouwer or Schauder fixed-point theorem rather than from pigeonhole.

**Probabilistic self-consistency.** Let each causal step be a Markov kernel; a
consistent history becomes a stationary distribution of the round-trip kernel. The
Novikov principle then holds automatically on finite state spaces (stationary
distributions always exist), and one can quantify "how paradoxical" a loop is by the
entropy of that distribution.

**Counting generic loops.** Compute the expected number of consistent histories of a
random loop via fixed-point statistics of random self-maps, and characterize which
loop lengths force consistency.

**Interacting loops.** Model several causal loops sharing state and study joint
consistency as a simultaneous fixed-point problem, connecting to Nash-style existence
theorems.

## 7. Conclusion

By identifying self-consistent histories with fixed points, the Novikov principle
becomes an ordinary — and richly structured — question in fixed-point theory. Our
contrarian survey shows that several intuitively "obvious" forcing hypotheses fail,
while a precise trio (ascent under repetition, contraction, and finite-world
involutivity) succeeds, the latter two carrying quantitative content. The grandfather
paradox, reframed, is simply the statement that a particular self-map has no fixed
point — and the mathematics of when self-maps *must* have fixed points turns the
century-old puzzle into a tractable and generative research program.
