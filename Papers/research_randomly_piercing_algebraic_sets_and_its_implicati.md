# Finite-State Output Machines: Reachability, Decidability, and the Limits of Automatic Sequences

**Author:** Aristotle
**Date:** 2026-06-20
**Domain:** Computation

## Abstract

We develop a minimal, self-contained theory of *deterministic finite automata
with output* (DFAOs) and the *automatic sequences* they generate, emphasizing
purely finite-state arguments and avoiding any dependence on digit arithmetic,
Christol's theorem, or general computability. A DFAO over alphabet $\mathrm{Fin}\,k$
walks a finite state space $Q$ from an initial state $q_0$ via a transition
$\mathrm{step} : Q \to \mathrm{Fin}\,k \to Q$, and labels each state with an
output in $\alpha$ via $\mathrm{out} : Q \to \alpha$. A function
$f : \mathbb{N} \to \alpha$ is *$k$-automatic* when there is a DFAO and an encoder
$\mathrm{encode} : \mathbb{N} \to \mathrm{List}(\mathrm{Fin}\,k)$ with
$f(n) = \mathrm{eval}(\mathrm{encode}(n))$ for all $n$. We prove four principal
results. (i) **Finite range:** every $k$-automatic sequence takes only finitely
many values (`range_finite`). (ii) **Decidable occurrence:** for a fixed DFAO and
target output $a$, the existence of a word producing $a$ is decidable by a finite
search over reachable states (`decidableOccurs`), underpinned by a provably
terminating breadth-first reachability computation. (iii) **Unary eventual
periodicity:** the output sequence of a one-letter automaton is eventually
periodic (`eventuallyPeriodic`). (iv) **An automaticity obstruction:** any
sequence of infinite range fails to be automatic (`not_of_range_infinite`); in
particular the identity sequence $n \mapsto n$ is not $k$-automatic for any $k$
(`not_isKAutomatic_id`). The reachability layer rests on a pigeonhole bound
(`reach_card_ge`) guaranteeing stabilization within $|Q|$ rounds
(`exists_reach_stable`), yielding a computable fixed point `reachSet`.

## 1. Introduction

Automatic sequences occupy a remarkable middle ground between the trivially
periodic and the genuinely chaotic. They are rich enough to encode famous
nonperiodic objects such as the Thue–Morse and Rudin–Shapiro sequences, yet
structured enough that essentially every natural decision problem about them is
solvable. The classical theory typically routes through base-$k$ digit
representations and deep results (Christol's theorem, the $p$-kernel
characterization). Our aim here is orthogonal and deliberately elementary: to
isolate the *finite-state core* of the subject and show how much follows from it
alone, with the digit-arithmetic layer abstracted into a single opaque encoder.

The payoff of this separation is conceptual clarity. The expressive limits of
automatic sequences, the decidability of occurrence problems, and the eventual
periodicity of unary dynamics are *all* consequences of one fact — finiteness of
the state space — together with standard finite combinatorics (monotone
set growth, pigeonhole, finite orbits). No analytic or number-theoretic input is
required.

## 2. Deterministic finite automata with output

**Definition 1 (DFAO).** Fix $k : \mathbb{N}$, a state type $Q$, and an output
type $\alpha$. A *deterministic finite automaton with output* is a triple
$$M = (q_0,\ \mathrm{step},\ \mathrm{out}), \qquad q_0 \in Q,\quad
\mathrm{step} : Q \to \mathrm{Fin}\,k \to Q,\quad \mathrm{out} : Q \to \alpha.$$
The alphabet is $\mathrm{Fin}\,k = \{0, 1, \dots, k-1\}$; inputs are words
$w \in \mathrm{List}(\mathrm{Fin}\,k)$.

**Definition 2 (Run and evaluation).** The state reached after reading $w$ from
the start is the left fold of $\mathrm{step}$ over $w$:
$$\mathrm{run}(M, w) = \mathrm{foldl}\,\mathrm{step}\ q_0\ w.$$
The *output produced by* $w$ is $\mathrm{eval}(M, w) = \mathrm{out}(\mathrm{run}(M, w))$.

The fold formulation gives two definitional rewrite rules used throughout:
$$\mathrm{run}(M, [\,]) = q_0, \qquad
\mathrm{run}(M, w \mathbin{+\!\!+} [c]) = \mathrm{step}(\mathrm{run}(M, w),\, c).$$
(In the formalization these are `run_nil` and `run_concat`; the latter is the
engine of every induction over words from the right.)

**Definition 3 (Reachability).** The predicate $\mathrm{Reachable}(M, \cdot)$ is
the smallest predicate on $Q$ such that $q_0$ is reachable and, whenever $q$ is
reachable, so is $\mathrm{step}(q, c)$ for every symbol $c$. (Inductively: a
`base` clause for $q_0$ and a `step` clause closing under transitions.)

**Proposition 4 (Reachability = word-image).** For every state $q$,
$$\mathrm{Reachable}(M, q) \iff \exists\, w,\ \mathrm{run}(M, w) = q.$$
*Proof sketch.* ($\Leftarrow$) Induct on $w$ from the right using `run_concat`:
$\mathrm{run}(M, [\,]) = q_0$ is the base clause, and appending $c$ applies the
step clause (`reachable_run`). ($\Rightarrow$) Induct on the reachability
derivation: the base case gives the empty word $[\,]$, and the step case extends
a witness $w$ for $q$ to $w \mathbin{+\!\!+} [c]$ for $\mathrm{step}(q, c)$,
using `run_concat`. $\qquad\blacksquare$

## 3. Computing the reachable states

We now assume $Q$ is a finite type with decidable equality, so finsets of states
are available. The goal is a terminating algorithm that returns *exactly* the
reachable states, certified correct.

**Definition 5 (Expansion and BFS layers).** For a finset $S \subseteq Q$ define
one round of breadth-first expansion
$$\mathrm{expand}(S) = S \cup \bigcup_{q \in S} \{\, \mathrm{step}(q, c) : c \in \mathrm{Fin}\,k \,\},$$
and the layered reachability finsets
$$\mathrm{reach}(0) = \{q_0\}, \qquad \mathrm{reach}(n+1) = \mathrm{expand}(\mathrm{reach}(n)).$$

**Lemma 6 (Expansion basics).** $S \subseteq \mathrm{expand}(S)$
(`subset_expand`), and if $q \in S$ then $\mathrm{step}(q, c) \in \mathrm{expand}(S)$
for every $c$ (`step_mem_expand`).

**Lemma 7 (Monotonicity and soundness).** The layers are monotone,
$m \le n \Rightarrow \mathrm{reach}(m) \subseteq \mathrm{reach}(n)$
(`reach_mono`, by transitivity from $\mathrm{reach}(n) \subseteq \mathrm{reach}(n+1)$),
and sound: $q \in \mathrm{reach}(n) \Rightarrow \mathrm{Reachable}(M, q)$
(`mem_reach_imp_reachable`, by induction on $n$ — the base singleton is $q_0$,
and each new element arises as a $\mathrm{step}$ of an already-reachable state).

**Lemma 8 (Stabilization is permanent).** If $\mathrm{reach}(n+1) = \mathrm{reach}(n)$,
then $\mathrm{reach}(m) = \mathrm{reach}(n)$ for all $m \ge n$ (`reach_stable`).
*Proof sketch.* Induct on $m \ge n$; the inductive step rewrites
$\mathrm{reach}(m+1) = \mathrm{expand}(\mathrm{reach}(m)) = \mathrm{expand}(\mathrm{reach}(n)) = \mathrm{reach}(n+1) = \mathrm{reach}(n)$.
$\qquad\blacksquare$

**Lemma 9 (Pigeonhole growth bound).** If the layers have *not* stabilized in any
of the first $n$ rounds — i.e. $\mathrm{reach}(i+1) \ne \mathrm{reach}(i)$ for all
$i < n$ — then
$$n + 1 \le |\mathrm{reach}(n)|.$$
(`reach_card_ge`.) *Proof sketch.* Induct on $n$. For $n=0$, $|\{q_0\}| = 1$. For
the step, non-stabilization at round $n$ together with monotonicity gives a
*strict* inclusion $\mathrm{reach}(n) \subsetneq \mathrm{reach}(n+1)$, hence
$|\mathrm{reach}(n)| < |\mathrm{reach}(n+1)|$; combined with the inductive
$n+1 \le |\mathrm{reach}(n)|$ this yields $n+2 \le |\mathrm{reach}(n+1)|$.
$\qquad\blacksquare$

**Theorem 10 (Termination within $|Q|$ rounds).**
$$\exists\, n \le \mathrm{card}(Q),\quad \mathrm{reach}(n+1) = \mathrm{reach}(n).$$
(`exists_reach_stable`.) *Proof sketch.* Suppose not; then the hypothesis of
Lemma 9 holds at $n = \mathrm{card}(Q)$, giving
$\mathrm{card}(Q) + 1 \le |\mathrm{reach}(\mathrm{card}(Q))| \le \mathrm{card}(Q)$
(the last bound is `card_le_univ`), a contradiction. $\qquad\blacksquare$

**Definition 11 (Reachable-state finset).** Take the expansion to its guaranteed
fixed point: $\mathrm{reachSet}(M) = \mathrm{reach}(\mathrm{card}(Q))$. By
Theorem 10 and Lemma 8 this is stable, and by Lemma 7 it is sound; one checks
(`reachable_iff_exists_word`) it is also complete, so it equals exactly the set of
reachable states. It is computable by at most $|Q|$ rounds of `expand`.

## 4. Automatic sequences and finite range

**Definition 12 ($k$-automatic sequence).** A function $f : \mathbb{N} \to \alpha$
is *$k$-automatic* if there exist a DFAO $M$ (over $\mathrm{Fin}\,k$, with output
type $\alpha$) and an encoder $\mathrm{encode} : \mathbb{N} \to \mathrm{List}(\mathrm{Fin}\,k)$
such that
$$f(n) = \mathrm{eval}(M, \mathrm{encode}(n)) \quad \text{for all } n \in \mathbb{N}.$$
The canonical encoder is the base-$k$ digit expansion, but no result below uses
that choice; the encoder is kept abstract.

**Theorem 13 (Finite range).** Every $k$-automatic sequence has finite range.
(`range_finite`.) *Proof sketch.* For all $n$, $f(n) = \mathrm{out}(\mathrm{run}(M, \mathrm{encode}(n)))$
lies in the image of $\mathrm{out} : Q \to \alpha$. Since $Q$ is finite, that image
is finite, and the range of $f$ is a subset of it. $\qquad\blacksquare$

This single observation is the crux of the subject's expressive limits: the
machine's only act of output is to read a label of one of finitely many states.

## 5. Decidability of occurrence

**Theorem 14 (Decidable occurrence).** Fix a DFAO $M$ (over a finite, decidable
state type) and a target output $a$ with decidable equality on $\alpha$. Then the
proposition
$$\exists\, w \in \mathrm{List}(\mathrm{Fin}\,k),\quad \mathrm{eval}(M, w) = a$$
is decidable. (`decidableOccurs`.) *Proof sketch.* By Proposition 4 and
Definition 11, $\mathrm{eval}(M, w) = \mathrm{out}(\mathrm{run}(M, w))$ ranges
exactly over $\{\mathrm{out}(q) : q \in \mathrm{reachSet}(M)\}$. Hence a word with
output $a$ exists iff some $q \in \mathrm{reachSet}(M)$ has $\mathrm{out}(q) = a$.
The latter is a decidable finite search over the computable finset
$\mathrm{reachSet}(M)$. $\qquad\blacksquare$

This collapses an a priori infinite search over all words into a finite search
over $\le |Q|$ states — a direct dividend of the terminating reachability
computation of §3.

## 6. Unary automata are eventually periodic

When $k = 1$ the alphabet has a single symbol, so reading a word of length $n$ is
exactly $n$-fold iteration of the unique transition $\mathrm{next} := \mathrm{step}(\cdot, 0)$.
The induced output sequence is $u(n) = \mathrm{out}(\mathrm{next}^{[n]}(q_0))$.

**Theorem 15 (Eventual periodicity).** For a unary automaton, the sequence
$u(n) = \mathrm{out}(\mathrm{next}^{[n]}(q_0))$ is eventually periodic: there exist
a preperiod $n_0$ and a period $p \ge 1$ such that $u(n + p) = u(n)$ for all
$n \ge n_0$. (`eventuallyPeriodic`.) *Proof sketch.* The state orbit
$q_0, \mathrm{next}(q_0), \mathrm{next}^{[2]}(q_0), \dots$ lives in the finite set
$Q$, so by pigeonhole two iterates coincide: $\mathrm{next}^{[i]}(q_0) = \mathrm{next}^{[j]}(q_0)$
for some $i < j$. Determinism then propagates this coincidence forward, so the
state sequence — and hence the output sequence obtained by applying $\mathrm{out}$ —
is periodic with period $p = j - i$ from index $n_0 = i$ onward. $\qquad\blacksquare$

This is the finite-state instance of the general principle that every
deterministic orbit in a finite space is ultimately cyclic.

## 7. The automaticity obstruction

**Corollary 16 (Infinite range obstruction; identity not automatic).** If a
sequence $f : \mathbb{N} \to \alpha$ has infinite range, then $f$ is not
$k$-automatic for any $k$ (`not_of_range_infinite`). In particular the identity
sequence $\mathrm{id} : n \mapsto n$ on $\mathbb{N}$ is not $k$-automatic for any
$k$ (`not_isKAutomatic_id`). *Proof sketch.* The first claim is the
contrapositive of Theorem 13: automaticity forces finite range. For the second,
$\mathrm{id}$ is injective, so its range is all of $\mathbb{N}$, which is infinite;
apply the first claim. $\qquad\blacksquare$

Thus the most elementary unbounded sequence — counting itself — already lies
outside the automatic class, for an entirely structural reason: finite memory is
a finite output vocabulary.

## 8. Discussion

The development draws a sharp methodological line. Everything above is *finite
combinatorics about a finite state space*: monotone set growth and pigeonhole
(§3), the image of a map out of a finite type (§4–5), and finite orbits under
iteration (§6). None of it touches the arithmetic of base-$k$ digits. The encoder
is the sole interface to that arithmetic, and by keeping it abstract we make
visible exactly which theorems are "really" about automata (all of those proved
here) versus which require the digit layer (e.g. closure under arithmetic
subsequences, or Christol-type algebraicity characterizations, which are *not*
claimed here).

Two design choices deserve emphasis. First, reachability is given both an
inductive specification (Definition 3) and an executable computation
(Definition 11), with Proposition 4 and Lemma 7 bridging them; this is what turns
decidability (Theorem 14) from an existence statement into an algorithm. Second,
the termination bound (Theorem 10) is proved by a direct counting argument
(Lemma 9) rather than by appeal to a generic well-founded fixpoint theorem,
keeping the argument self-contained and giving an explicit round bound of $|Q|$.

## 9. Limitations and future work

The results characterize the *finite-state* behavior of DFAOs and the consequent
limits of automatic sequences; they intentionally do not address closure
properties that depend on digit arithmetic, nor quantitative state-complexity
lower bounds. The eventual-periodicity result is stated for unary input; the
general (multi-letter) structure theory is richer and not pursued here.

The Phase A program suggests several concrete extensions, centered on a sibling
line of work on *covering lower bounds via Schwartz–Zippel-type zero counts*:

1. **Discharging the size hypothesis from a formal Schwartz–Zippel bound.** Make a
   covering lower bound *produce* its cross-multiplied size estimate from a
   theorem bounding the zeros of a nonzero degree-$d$ multivariate polynomial over
   a finite field $K$ by $d\,|K|^{\,n-1}$, so the interface between the analytic
   layer and the abstract transducer is a single natural-number inequality.
2. **Weighted and fractional covers.** Assign positive weights to cover members
   and conclude a lower bound on total weight, capturing fractional covering and
   LP-relaxation arguments; the union/subadditivity step is already a weighted
   statement in disguise.
3. **Sharper cancellation under coprimality and rounding.** Replace the lossless
   final cancellation with a ceiling-aware variant recovering integrality gains
   (e.g. $k \ge \lceil q/d \rceil$) when $q, d$ carry arithmetic structure.
4. **The dual packing upper bound.** Run the same subadditivity skeleton in
   reverse for pairwise-disjoint families, where the cardinality *equality* for
   disjoint unions replaces the inequality, unifying packing and covering as two
   faces of one finite-union lemma.

## 10. Conclusion

From one structural fact — a finite machine has a finite output vocabulary — we
derived the finite range of automatic sequences (`range_finite`), the
non-automaticity of any infinite-range sequence including the identity
(`not_of_range_infinite`, `not_isKAutomatic_id`), a terminating and certified
reachability computation (`exists_reach_stable`, `reachSet`) yielding decidability
of occurrence (`decidableOccurs`), and the eventual periodicity of unary dynamics
(`eventuallyPeriodic`). Together they map the precise boundary of what bounded,
deterministic, finite-state computation can and cannot express.
