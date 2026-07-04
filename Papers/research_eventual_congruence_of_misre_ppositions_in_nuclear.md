# Eventual Congruence of Misère P-Positions in Escalation Ladders

## Abstract

We study the *single-theater escalation game*: a one-pile combinatorial game
parameterized by an *escalation granularity* $m \ge 1$, in which a position is a
number $r$ of remaining rungs on a ladder and a move descends by between $1$ and
$m$ rungs, with the terminal position $0$ reached when no move remains. Under the
**misère** convention — the player forced to complete the final descent loses — we
determine the losing positions exactly. We prove that for every $m \ge 1$ and every
position $r$, the player to move loses if and only if $r \equiv 1 \pmod{m+1}$. This
is a clean *shift by one* of the normal-play losing class $r \equiv 0 \pmod{m+1}$,
which we also establish. The result strengthens a natural "eventual congruence"
conjecture in two ways: it corrects the residue class (the misère answer is $1$, not
$0$) and it shows the pattern is *exact*, valid for every ladder length with zero
transient. The technical core is a single modular-arithmetic equivalence about the
predecessors of a position, from which both the misère and normal-play
characterizations follow by strong induction on $r$. We also record that the
literal form of the conjecture (misère losing positions $\equiv 0$) is provably
false. We discuss the connection to classical subtraction-game theory, give
algorithms and numerical demonstrations, and outline directions toward the misère
theory of several simultaneous ladders.

---

## 1. Introduction

Combinatorial game theory analyzes two-player games of perfect information with no
chance and no hidden state, in which the players alternate moves and the outcome is
decided by who can and cannot move. The classical **normal-play** convention
declares that the player unable to move *loses*; the **misère** convention reverses
this, declaring that the player unable to move *wins*.

The single-theater escalation game is a metaphor for graduated conflict. Two rivals
share a ladder of tension. A move is a de-escalation: the player to move steps down
the ladder by between $1$ and $m$ rungs. Reaching the bottom, position $0$, means
the previous player was forced to complete the final, irreversible escalation. Under
the misère convention that models this scenario, being unable to move (i.e. arriving
at $0$ with it being your turn) is a *win*, because it is your opponent who took the
last catastrophic step.

Games of this form belong to the well-studied family of **subtraction games**. For
a subtraction set $S = \{1, 2, \ldots, m\}$, the normal-play losing positions form
the arithmetic progression $r \equiv 0 \pmod{m+1}$, a fact traceable to the
foundational Sprague–Grundy theory. Our contribution is the exact misère analysis
and a clarification of a conjecture about it.

### 1.1 The conjecture and its correction

A natural conjecture — the starting point of this work — proposed that the misère
losing positions of the escalation game *eventually* satisfy the same congruence as
normal play: that there is a threshold $T(m)$ such that for all ladder lengths
$N \ge T(m)$ and all $0 \le r \le N$, position $r$ is a misère losing position if
and only if $r \equiv 0 \pmod{m+1}$.

We show this is false in its stated residue class but true, and in fact stronger,
after a correction:

1. The correct misère losing class is $r \equiv 1 \pmod{m+1}$, not $r \equiv 0$.
2. The characterization holds for **every** $r$, not merely eventually; the
   threshold is $T(m) = 0$.
3. The residue $0$ is precisely the *normal-play* answer, so the original
   conjecture conflated the two conventions.

---

## 2. Definitions

Throughout, fix an escalation granularity $m \ge 1$. Positions are natural numbers.

**Definition 1 (Single-theater escalation game).**
A position is $r \in \mathbb{N}$, the number of remaining rungs. From position $r$,
the legal moves are to $r - s$ for each step size $s$ with
$1 \le s \le \min(m, r)$. Position $0$ is terminal (no moves available).

**Definition 2 (Misère outcome).**
Define $W_m : \mathbb{N} \to \{\text{true}, \text{false}\}$ by $W_m(r) = \text{true}$
iff the player to move at $r$ has a winning strategy under misère play. The recursion
encoding this is
$$
W_m(0) = \text{true}, \qquad
W_m(r) = \bigvee_{s=1}^{\min(m,r)} \neg\, W_m(r - s) \quad (r \ge 1).
$$
The base case $W_m(0) = \text{true}$ is the misère rule: the player at the terminal
position wins, because the opponent made the final escalation. The recursive case is
the standard game-theoretic principle that a position is a win iff some move leads to
a position that is a loss *for the opponent* (i.e. some successor $r - s$ has
$W_m(r-s) = \text{false}$).

**Definition 3 (P-position).**
A position $r$ is a **P-position** (previous-player win; the player to move loses)
under misère play iff $W_m(r) = \text{false}$. Otherwise it is an **N-position**
(next-player win).

**Definition 4 (Normal outcome).**
Define $W^{\mathrm N}_m : \mathbb{N} \to \{\text{true}, \text{false}\}$ identically
to $W_m$ except for the base case:
$$
W^{\mathrm N}_m(0) = \text{false}, \qquad
W^{\mathrm N}_m(r) = \bigvee_{s=1}^{\min(m,r)} \neg\, W^{\mathrm N}_m(r - s)
\quad (r \ge 1).
$$
Here $W^{\mathrm N}_m(0) = \text{false}$ is the normal rule: the player unable to
move loses.

---

## 3. Main results

### 3.1 The move-unfolding lemma

The recursion in Definitions 2 and 4 is repackaged into a usable existential form.

**Lemma 1 (Move unfolding).**
For all $m$ and $r$,
$$
W_m(r+1) = \text{true}
\iff
\exists\, s,\ 1 \le s \le m,\ s \le r+1,\ \text{and}\ W_m(r+1-s) = \text{false}.
$$
The same equivalence holds with $W_m$ replaced by $W^{\mathrm N}_m$.

*Proof sketch.* Immediate from the definition: $W_m(r+1)$ is a disjunction over
step sizes $s \in \{1, \ldots, \min(m, r+1)\}$ of the negated outcome
$\neg W_m(r+1-s)$. The disjunction is true iff at least one disjunct is, which is
exactly the stated existential. The bound $s \le \min(m, r+1)$ splits into the two
constraints $s \le m$ and $s \le r+1$. $\square$

### 3.2 The modular crux

The entire analysis rests on one arithmetic equivalence.

**Lemma 2 (Predecessor Lemma).**
Let $q \ge 2$, let the target residue satisfy $t \le 1$ (so $t \in \{0, 1\}$), and
let $\text{pos} \ge 1$. Then
$$
\Big(\forall s,\ 1 \le s \le q-1,\ s \le \text{pos}\ \Rightarrow\
(\text{pos} - s) \bmod q \neq t\Big)
\quad\iff\quad
\text{pos} \bmod q = t.
$$
In words: none of the legal predecessors $\text{pos}-1, \ldots, \text{pos}-(q-1)$
(capped at $0$) is congruent to $t$ modulo $q$ if and only if $\text{pos}$ itself is
congruent to $t$ modulo $q$.

*Proof sketch.*
($\Leftarrow$) Suppose $\text{pos} \equiv t \pmod q$. For any $s$ with
$1 \le s \le q-1$, subtracting $s$ changes the residue: since $0 < s < q$, we have
$(\text{pos} - s) \bmod q \neq \text{pos} \bmod q = t$. (When $s > \text{pos}$ the
predecessor is out of range and imposes no constraint; the hypothesis $s \le
\text{pos}$ handles this.) Hence no in-range predecessor hits $t$.

($\Rightarrow$) Contrapositive: suppose $\text{pos} \not\equiv t \pmod q$. We
exhibit a predecessor landing on residue $t$. Write $a = \text{pos} \bmod q$. If
$t = 0$ and $a \neq 0$, take $s = a$ (then $1 \le s \le q-1$ and $s \le \text{pos}$,
and $(\text{pos}-s) \equiv 0$). If $t = 1$, take $s = a - 1$ when $a \ge 1$ (giving
residue $1$), and $s = q - 1$ when $a = 0$ (since $\text{pos} \ge 1$ and
$\text{pos} \equiv 0$ force $\text{pos} \ge q$, so $s = q-1 \le \text{pos}$ is legal
and $(\text{pos} - (q-1)) \equiv 1$). In every case a legal $s$ with
$1 \le s \le q-1$, $s \le \text{pos}$, and $(\text{pos}-s) \bmod q = t$ exists,
contradicting the left-hand side. $\square$

The lemma is stated for general $t \le 1$ precisely because we apply it twice: with
$t = 1$ for misère play and $t = 0$ for normal play.

### 3.3 The characterizations

**Theorem 1 (Misère P-positions).**
For every $m \ge 1$ and every $r \in \mathbb{N}$,
$$
W_m(r) = \text{false} \iff r \equiv 1 \pmod{m+1}.
$$
Equivalently, the misère P-positions are exactly the arithmetic progression
$1, m+2, 2m+3, \ldots$

*Proof sketch.* Set $q = m + 1 \ge 2$ and $t = 1$. Proceed by strong induction on
$r$.

- Base $r = 0$: $W_m(0) = \text{true}$, i.e. $0$ is not a P-position, and indeed
  $0 \not\equiv 1 \pmod q$. Consistent.
- Step $r + 1$: By Lemma 1, $W_m(r+1) = \text{true}$ iff some legal step $s$
  ($1 \le s \le m$, $s \le r+1$) reaches $W_m(r+1-s) = \text{false}$. By the
  induction hypothesis, $W_m(r+1-s) = \text{false}$ iff $(r+1-s) \equiv 1 \pmod q$.
  So $W_m(r+1) = \text{false}$ (a P-position) iff *no* legal step reaches residue
  $1$, i.e. iff for all $s$ with $1 \le s \le q-1$ and $s \le r+1$ we have
  $(r+1-s) \bmod q \neq 1$. By Lemma 2 with $t = 1$ and $\text{pos} = r+1$, this is
  equivalent to $(r+1) \equiv 1 \pmod q$. (The step range $1 \le s \le m$ coincides
  with $1 \le s \le q - 1$.) This closes the induction. $\square$

**Theorem 2 (Eventual congruence, corrected and exact).**
For every $m \ge 1$ there is a threshold $T(m)$ such that for all ladder lengths
$N \ge T(m)$ and all $0 \le r \le N$, position $r$ is a misère P-position iff
$r \equiv 1 \pmod{m+1}$; moreover $T(m) = 0$ works, so the congruence holds for
every ladder length with no transient.

*Proof sketch.* Immediate from Theorem 1, which is uniform in $r$ and independent of
any ladder-length parameter $N$. Taking $T(m) = 0$ makes the "eventual" statement
hold vacuously as a universal one. $\square$

**Theorem 3 (Normal-play P-positions).**
For every $m \ge 1$ and every $r \in \mathbb{N}$,
$$
W^{\mathrm N}_m(r) = \text{false} \iff r \equiv 0 \pmod{m+1}.
$$
These are the Sprague–Grundy zero positions of the subtraction game
$\{1, \ldots, m\}$.

*Proof sketch.* Identical to Theorem 1 with base case $W^{\mathrm N}_m(0) =
\text{false}$ (so $0$ *is* a P-position, matching $0 \equiv 0$) and target residue
$t = 0$ in Lemma 2. $\square$

**Theorem 4 (The literal conjecture is false).**
The statement "for all $m \ge 1$ and all $r$, $r$ is a misère P-position iff
$r \equiv 0 \pmod{m+1}$" is false.

*Proof sketch.* By Theorem 1 the misère P-positions are the class $r \equiv 1$. The
two classes $r \equiv 0$ and $r \equiv 1 \pmod{m+1}$ are disjoint (since
$m + 1 \ge 2$), so they cannot coincide. Concretely, for $m = 1$: $r = 1$ is a
misère P-position but $1 \not\equiv 0 \pmod 2$; and $r = 0$ satisfies
$0 \equiv 0 \pmod 2$ but is *not* a misère P-position (the player to move at $0$
wins). $\square$

---

## 4. Worked examples

The following table lists the misère P-positions (losing-to-move positions) up to
$r = 12$ for small granularities, alongside the normal-play P-positions.

| $m$ | $m+1$ | Misère P-positions ($r \equiv 1$) | Normal P-positions ($r \equiv 0$) |
|----:|------:|:----------------------------------|:----------------------------------|
| 1   | 2     | 1, 3, 5, 7, 9, 11                  | 0, 2, 4, 6, 8, 10, 12             |
| 2   | 3     | 1, 4, 7, 10                       | 0, 3, 6, 9, 12                    |
| 3   | 4     | 1, 5, 9                           | 0, 4, 8, 12                       |
| 4   | 5     | 1, 6, 11                         | 0, 5, 10                          |

In each row the two progressions are parallel: the misère class is the normal class
shifted up by exactly one rung.

**A sample winning line ($m = 2$).** Suppose the ladder has $r = 8$ rungs. Since
$8 \equiv 2 \pmod 3$, this is an N-position: the player to move wins. The winning
move is to descend to the nearest lower misère P-position, $7$ (a step of $s = 1$).
Whatever the opponent does from $7$ — descend to $6$ or to $5$ — the first player
restores a P-position ($6 \to 4$, $5 \to 4$), keeping the opponent perpetually on
residue $1$ and eventually handing them position $1$, from which every move loses.

---

## 5. Algorithms

### 5.1 Exact solver by dynamic programming

The outcomes $W_m(0), W_m(1), \ldots, W_m(R)$ are computed in $O(Rm)$ time and
$O(R)$ space by filling a Boolean table left to right, applying the recursion of
Definition 2. This is the ground-truth oracle against which the closed form is
verified. The same routine with base case $\text{false}$ computes normal play.

### 5.2 Closed-form classifier

Given the theorems, membership in the P-position set is a single modular test:
$r$ is a misère P-position iff $r \bmod (m+1) = 1$, and a normal P-position iff
$r \bmod (m+1) = 0$. This is $O(1)$ per query.

### 5.3 Optimal-move oracle

From an N-position $r$, an optimal move is any step $s \in \{1, \ldots, m\}$ with
$(r - s) \equiv 1 \pmod{m+1}$ (misère) or $(r - s) \equiv 0$ (normal). The
Predecessor Lemma guarantees such an $s$ exists whenever $r$ is not itself a
P-position, and the smallest such $s$ is $s = ((r - t) \bmod (m+1))$ with the
appropriate target residue $t$.

---

## 6. Discussion

The single-theater escalation game is the subtraction game with subtraction set
$\{1, \ldots, m\}$. Its normal-play theory is classical: the losing positions are
the multiples of $m+1$, equivalently the Grundy-value-zero positions. The
contribution here is the exact misère analysis and the clarification that flipping
the endgame convention does not scramble the structure — it *translates* it by one
residue.

The philosophical takeaway is worth stating plainly. Misère play is notoriously more
subtle than normal play: the elegant additive theory that combines independent games
by a single number and an exclusive-or rule does not survive the switch to misère.
Yet for a *single* subtraction pile the misère answer remains an exact arithmetic
progression, differing from normal play only by the unit shift forced at the
terminal position. This makes the escalation game a clean pedagogical bridge between
the two conventions.

A subtle point deserves emphasis. The original conjecture's caution — that the
congruence holds only *eventually* — turned out to be unnecessary. There is no
transient. The clean progression is present from the first rung, so the correct
threshold is $T(m) = 0$. What looked like it might be an asymptotic phenomenon is in
fact exact.

---

## 7. Future directions

**Parallel escalation and the misère quotient.** When several ladders are contested
at once — each turn a player de-escalates one chosen ladder by between one and $m$
rungs, and whoever completes the last escalation across all theaters loses — the
combined outcome is *not* the exclusive-or of the individual misère outcomes.
Instead there should be a finite algebraic gadget, a small commutative monoid
attached to the subtraction set $\{1, \ldots, m\}$, whose element for a whole
position decides the winner, and this monoid should be finite for every $m$. Misère
addition is governed not by a single number (as normal play is, via the
exclusive-or of Grundy values) but by a richer bookkeeping object that remembers
just enough about each summand; for bounded-step escalation this object should stay
finite, making the multi-theater game solvable. The exact single-ladder progression
$r \equiv 1 \pmod{m+1}$ supplies the first generator of that monoid explicitly,
turning the search for the full structure into a finite closure computation seeded
by a known value.

**Escalation with drifting granularity.** If the number of rungs a player may
descend depends on the current position — a fixed, repeating schedule of step-limits
along the ladder — then the pattern of losing positions should remain ultimately
periodic, settling after an explicit initial transient into a pure repeating block
whose length divides a quantity read off from one period of the schedule.
Periodicity of the *rules* forces periodicity of the *outcome*, with the eventual
period controlled by the largest step allowed within one cycle plus one; only a
bounded prefix can misbehave. The constant-granularity case has zero transient and
period exactly $m+1$, pinning down the base case and isolating the transient as the
single new feature.

**Coordinated de-escalation and hidden golden structure.** In a two-ladder game
where a player may either step down one ladder by up to $m$ rungs or step down both
ladders together by the same amount, the safe (losing-to-move) positions should lie
along two interleaving arithmetic-like sequences whose density ratio is fixed by $m$,
echoing the complementary sequences that govern the classical two-pile take-away
game — with the misère version deviating from this only on a thin, explicitly
listable set hugging the diagonal. Allowing a synchronized move on two ladders
reproduces the mechanism behind complementary Beatty-type sequences.

---

## 8. Conclusion

For the single-theater escalation game with granularity $m$, the misère P-positions
are exactly the residue class $r \equiv 1 \pmod{m+1}$ — an exact congruence valid at
every ladder length, and a clean unit shift of the normal-play class
$r \equiv 0 \pmod{m+1}$. The literal conjecture placing the misère losing positions
at residue $0$ is false; residue $0$ is the normal-play answer. A single
modular-arithmetic equivalence about a position's predecessors, applied with target
residue $1$ or $0$, drives both characterizations through a strong induction on the
ladder length.
