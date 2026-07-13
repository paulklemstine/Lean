# The Disjunctive Sum of Well-Founded Games: Mirroring, Neutrality, and a Two-Heap Nim Law

## Abstract

We develop the algebra of the **disjunctive sum** for two-player *well-founded*
(transfinite) games — games whose move relation admits no infinite descending play,
yet whose plays may have arbitrary ordinal rank. Building on the Zermelo value
function $W$, which declares a position winning for the player to move precisely
when some move leads to a losing position, we establish that the disjunctive sum of
a well-founded game with itself is again well-founded, so that $W$ is defined on
sums. We prove three structural laws: the empty (terminal) game is a neutral
element, the value of a sum is commutative, and — our flagship result — the
symmetric sum $a + a$ is *always* a loss for the player to move, via a uniform
transfinite mirroring strategy. We complement these with Zermelo's determinacy
theorem for well-founded games and its strategic corollary that in $a + a$ the
opponent holds the winning strategy. We then isolate two plausible but false
conjectures — that the sum of two winning positions is winning, and that a losing
component can be discarded without changing the winner — and refute both concretely
in the countdown game. Finally we prove a sharp two-heap Nim identity: the sum of
countdown heaps $m$ and $n$ is winning for the mover if and only if $m \neq n$,
subsuming both counterexamples under a single equivalence. We close with the
Sprague–Grundy program for transfinite games as the principal open direction.

**Keywords:** combinatorial game theory, well-founded relations, transfinite games,
disjunctive sum, Zermelo determinacy, strategy stealing, Nim, Sprague–Grundy.

---

## 1. Introduction

Combinatorial game theory studies two-player games of perfect information with no
chance and no draws, under the *normal play convention*: the player who cannot move
loses. Its central operation is the **disjunctive sum**, in which several games are
played side by side and a move consists of playing in exactly one component. The
sum is what makes the theory *algebraic*: complicated positions decompose into sums
of simple ones, and the value of the whole is meant to be computable from the
values of the parts.

Most of the classical theory is developed for games whose play is finite in the
ordinary sense — the game tree has finite height, or at least the position set is
finite. Here we work in the more general and more subtle world of **well-founded
games**. A game is given by a set of positions $P$ and a *move relation*
$\mathrm{mv} \subseteq P \times P$, where $\mathrm{mv}(p, q)$ means "from $p$ one may
legally move to $q$." The game is **well-founded** when the reverse relation
$q \mathrel{R} p \iff \mathrm{mv}(p, q)$ is well-founded, i.e. there is no infinite
sequence $p_0, p_1, p_2, \dots$ with $\mathrm{mv}(p_i, p_{i+1})$ for all $i$.

Well-foundedness is exactly the statement that *no play lasts forever*. It is
strictly weaker than finiteness of play length: a well-founded game may have
positions of arbitrary transfinite rank, so that the ordinal measuring the longest
possible continuation exceeds every finite bound and indeed every countable bound
one likes. These are, informally, games that can *almost* last forever — unbounded
in potential length, yet terminating in every actual play. This is the natural
arena in which to ask whether the algebra of disjunctive sums survives into the
transfinite.

Our contributions are:

1. **Legitimacy of the sum (Theorem 3.2).** The disjunctive sum of a well-founded
   game with itself is well-founded, realized as the *game addition* (lexicographic
   product-style) of the reverse move relation with itself. Hence the value
   function extends to sums.
2. **Neutrality and commutativity (Theorems 4.1, 4.2, 4.3).** A terminal component
   is a neutral element, and the value of a sum is commutative.
3. **The mirroring theorem (Theorem 5.1).** For every well-founded game, $a + a$ is
   a loss for the player to move.
4. **Determinacy (Theorem 6.2) and its strategic corollary (Theorem 6.3).** The
   player to move can force a win iff the position is winning; consequently in
   $a + a$ the opponent forces the win.
5. **Two contrarian refutations (Theorems 7.2, 7.3)** and a **sharp two-heap Nim
   law (Theorem 7.4)** unifying them.

Throughout, "winning" and "losing" are always from the perspective of the player
*about to move*, and we use the normal-play convention.

---

## 2. The value function of a well-founded game

Fix a set of positions $P$ and a move relation $\mathrm{mv}$, and assume the reverse
relation $R$ defined by $q \mathrel{R} p \iff \mathrm{mv}(p, q)$ is well-founded.

**Definition 2.1 (Value / winning position).** The **value** $W(p)$ is defined by
well-founded recursion on $R$:
$$
W(p) \;\iff\; \exists\, q,\ \mathrm{mv}(p, q) \ \wedge\ \neg\, W(q).
$$
We say $p$ is a **winning position** (for the player to move) when $W(p)$ holds, and
a **losing position** otherwise.

The recursion is legitimate precisely because $R$ is well-founded: the truth value
of $W(p)$ is expressed in terms of $W(q)$ for positions $q$ strictly below $p$, and
there is no infinite descent, so the definition bottoms out. This is the Zermelo /
Sprague–Grundy fixed point specialized to the two-valued (win/lose) grading.

**Theorem 2.2 (Zermelo fixed-point equation).** For all $p$,
$$
W(p) \;\iff\; \exists\, q,\ \mathrm{mv}(p, q) \wedge \neg\, W(q).
$$
*Proof.* Immediate from unfolding the well-founded recursion in Definition 2.1. ∎

**Definition 2.3 (Terminal position).** A position $p$ is **terminal** if it has no
legal move: $\neg\, \exists q,\ \mathrm{mv}(p, q)$.

The fixed-point equation yields three basic facts used repeatedly.

**Lemma 2.4 (Characterization of losing positions).**
$\neg\, W(p) \iff \forall q,\ \mathrm{mv}(p, q) \rightarrow W(q)$. A position is
losing exactly when every move leads to a winning position.
*Proof.* Negate Theorem 2.2 and push the negation through the existential. ∎

**Lemma 2.5 (Winning positions have a good move).** If $W(p)$ then there exists $q$
with $\mathrm{mv}(p, q)$ and $\neg\, W(q)$.
*Proof.* Forward direction of Theorem 2.2. ∎

**Lemma 2.6 (Terminal positions are losing).** If $p$ is terminal then $\neg\,W(p)$.
*Proof.* If $W(p)$, Theorem 2.2 supplies a move from $p$, contradicting
terminality. ∎

---

## 3. The disjunctive sum and its well-foundedness

We now combine two copies of the game. Positions of the sum are pairs
$(a_1, a_2) \in P \times P$.

**Definition 3.1 (Disjunctive sum move relation).** For $a = (a_1, a_2)$ and
$b = (b_1, b_2)$, define
$$
\mathrm{sumMv}(a, b) \;\iff\; \big(\mathrm{mv}(a_1, b_1) \wedge a_2 = b_2\big)
\ \vee\ \big(a_1 = b_1 \wedge \mathrm{mv}(a_2, b_2)\big).
$$
A move in the sum makes a legal move in exactly one component and leaves the other
fixed.

**Theorem 3.2 (Well-foundedness of the sum).** If $R$ is well-founded, then the
reverse of $\mathrm{sumMv}$ is well-founded.
*Proof.* The **game addition** $\mathrm{GameAdd}(R, R)$ of a well-founded relation
with itself is well-founded (the standard result that the componentwise "move in one
coordinate, decreasing" relation on a product of well-founded relations is
well-founded). One checks directly that the reverse of $\mathrm{sumMv}$ is a
subrelation of $\mathrm{GameAdd}(R, R)$: a $\mathrm{sumMv}$ step decreases exactly
one coordinate along $R$ and fixes the other, which is precisely a game-addition
step. A subrelation of a well-founded relation is well-founded. ∎

Consequently the value function of the sum,
$$
W_{+}(r) := W_{\mathrm{sumMv}}(r),
$$
is well-defined and satisfies its own fixed-point equation
$$
W_{+}(r) \iff \exists\, s,\ \mathrm{sumMv}(r, s) \wedge \neg\, W_{+}(s),
$$
together with the losing-position characterization
$\neg\, W_{+}(r) \iff \forall s,\ \mathrm{sumMv}(r, s) \rightarrow W_{+}(s)$.

---

## 4. Neutrality and commutativity

**Theorem 4.1 (Right neutrality of the empty game).** If $b$ is terminal, then for
all $a$,
$$
W_{+}(a, b) \iff W(a).
$$
*Proof.* By well-founded induction on $a$. Because $b$ is terminal, every legal
move from $(a, b)$ must act in the first component: it has the form
$(a, b) \to (a', b)$ with $\mathrm{mv}(a, a')$. Thus the move structure of $(a, b)$
is a faithful copy of the move structure of $a$. Unfolding both fixed-point
equations (Theorem 2.2 for $W$ and its analogue for $W_{+}$) and applying the
induction hypothesis at each child $a'$ gives the equivalence. ∎

**Theorem 4.2 (Commutativity).** For all $a, b$,
$W_{+}(a, b) \iff W_{+}(b, a)$.
*Proof.* By well-founded induction on the pair $(a, b)$ along $\mathrm{sumMv}$. Swap
is a bijection between the legal moves of $(a, b)$ and those of $(b, a)$ that maps
each child to its swap; the child is strictly below $(a,b)$, so the induction
hypothesis applies. Unfolding the fixed-point equation on both sides and matching
moves through the swap yields the equivalence. ∎

**Theorem 4.3 (Left neutrality).** If $a$ is terminal, then for all $b$,
$W_{+}(a, b) \iff W(b)$.
*Proof.* Combine Theorem 4.2 (commutativity) with Theorem 4.1. ∎

Neutrality and commutativity say that, at the level of *values*, terminal games
behave as the additive identity and the sum is symmetric — the first algebraic
signs that $W_{+}$ deserves to be called a "sum."

---

## 5. The mirroring theorem

**Theorem 5.1 (Mirroring / $a + a$ is a second-player win).** For every position
$a$,
$$
\neg\, W_{+}(a, a).
$$
The symmetric sum of a well-founded game with itself is always a loss for the
player to move.

*Proof.* By well-founded induction on $a$. By Lemma 2.4 (applied to the sum), it
suffices to show that *every* move from $(a, a)$ leads to a winning position for the
player who then moves. A legal move from $(a, a)$ changes one component, so it has
one of the two forms
$$
(a, a) \to (x, a) \quad\text{with } \mathrm{mv}(a, x),
\qquad\text{or}\qquad
(a, a) \to (a, y) \quad\text{with } \mathrm{mv}(a, y).
$$
Consider the first form; the second is symmetric. From $(x, a)$ the responder makes
the *same* move in the other component, $(x, a) \to (x, x)$, which is legal because
$\mathrm{mv}(a, x)$ holds. The resulting position $(x, x)$ is symmetric with
$x$ strictly below $a$, so by the induction hypothesis $\neg\, W_{+}(x, x)$: the
mirrored position is a loss for the player to move there. Hence $(x, a)$ has a move
to a losing position, i.e. $W_{+}(x, a)$ holds. Every child of $(a, a)$ is therefore
winning, so by Lemma 2.4 the position $(a, a)$ is losing. ∎

The strategy laid bare by the proof is the **mirroring strategy**: whatever the
first player does in one copy, the second player replicates in the other, restoring
symmetry. Symmetry is an invariant the responder can always maintain, and
well-foundedness forbids the mirroring dance from continuing forever, so the first
player is the one eventually stuck. This is the transfinite generalization of the
classical strategy-stealing and Tweedledum–Tweedledee arguments, and it holds
uniformly at every ordinal rank.

---

## 6. Determinacy and the strategic reading

The value function is a *static* predicate. We now connect it to *dynamic* play,
recovering Zermelo's theorem in the well-founded setting. Model a play as follows:
the analysed player follows a fixed optimal strategy at winning positions, while the
opponent follows an arbitrary **legal** strategy.

**Definition 6.1 (Legal strategy).** A function $o : P \to P$ is a **legal
strategy** if $\mathrm{mv}(x, o(x))$ whenever $x$ is not terminal. (Legal strategies
exist by choosing, at each non-terminal position, some legal move.)

Given a legal opponent $o$, define a one-step map: at a winning position use a fixed
optimal move (a move to a losing position, which exists by Lemma 2.5); at a losing
position defer to $o$. Iterating from a start position $p$ produces a **trajectory**
$t_0 = p,\ t_{n+1} = \mathrm{step}(t_n)$. Two facts drive the analysis:

- **Termination.** The trajectory reaches a terminal position after finitely many
  steps — otherwise the trajectory would be an infinite descending play,
  contradicting well-foundedness.
- **Alternation invariant.** As long as no terminal position has yet been reached,
  the parity of the value alternates:
  $W(t_n) \iff \big(n \text{ even} \iff W(p)\big)$. Each step flips both the value
  and the parity in lockstep.

**Definition 6.1′ (Mover forces a win).** The player to move at $p$ **forces a win**
if, against *every* legal opponent strategy, the first terminal position along the
trajectory is reached on an *odd* step (an opponent's turn), so the opponent, not
the analysed player, is the one left with no move.

**Theorem 6.2 (Determinacy / Zermelo).** The player to move at $p$ can force a win
if and only if $W(p)$.
*Proof.* ($\Leftarrow$) If $W(p)$, the trajectory reaches a terminal — hence
losing — position at some step $n$. By the alternation invariant, a losing position
at step $n$ forces $n$ odd (since $W(p)$ holds and terminal positions are losing by
Lemma 2.6). This holds against every legal opponent, so the mover forces a win.
($\Rightarrow$) Conversely, if $p$ were losing, pick any legal opponent; when the
trajectory first reaches a terminal position at step $n$, the alternation invariant
forces $n$ even, so the analysed player is the one stuck — contradicting the
forcing hypothesis. ∎

**Theorem 6.3 (Strategic reading of mirroring).** In the symmetric sum, the player
to move *cannot* force a win: $\neg\,(\text{mover forces a win at } (a, a))$.
*Proof.* Immediate from Theorem 6.2 and Theorem 5.1: mover-forces-a-win is
equivalent to $W_{+}(a, a)$, which is false. By determinacy the opponent forces the
win, and the witnessing strategy is exactly the mirroring strategy of Section 5. ∎

---

## 7. The countdown game: two false conjectures and a sharp law

We instantiate the theory in the simplest game with unbounded (rank-$\omega$) play.

**Definition 7.1 (Countdown).** Positions are natural numbers; the move relation is
$\mathrm{cmv}(a, b) \iff b < a$. From $a$ one may move to any strictly smaller
number. The relation is well-founded (the usual order on $\mathbb{N}$), and the only
terminal position is $0$.

**Value of countdown.** $W(n) \iff n \neq 0$. Indeed if $n > 0$ one moves directly
to $0$, a terminal (hence losing) position, so $n$ is winning; and $0$ is terminal,
hence losing. The disjunctive sum of two countdown heaps is precisely **two-heap
Nim**.

We can now expose two intuitions that fail.

**Theorem 7.2 (The sum of two wins can be a loss).** In countdown, $1$ is a winning
position, yet $1 + 1$ is a loss for the player to move:
$$
W(1) \wedge W(1) \wedge \neg\, W_{+}(1, 1).
$$
*Proof.* $W(1)$ holds since $1 \neq 0$. The claim $\neg\, W_{+}(1, 1)$ is the
mirroring theorem (Theorem 5.1) at $a = 1$. ∎

Thus "winning + winning = winning" is false: two winning positions can combine into
a loss.

**Theorem 7.3 (A losing component is not droppable).** In countdown, $0$ is a losing
position and $1$ is a winning position, yet $0 + 1$ is a *win* for the player to
move:
$$
\neg\, W(0) \wedge W(1) \wedge W_{+}(0, 1).
$$
*Proof.* $0$ is terminal, hence losing (Lemma 2.6). $W(1)$ holds. Since $0$ is
terminal, left neutrality (Theorem 4.3) gives $W_{+}(0, 1) \iff W(1)$, and $W(1)$
holds. ∎

Thus a losing (P-)position is **not** an absorbing element: only the genuinely empty
game is neutral (Theorems 4.1/4.3), not an arbitrary losing position. Both
counterexamples are special cases of a single equivalence.

**Theorem 7.4 (Two-heap Nim law).** For all $m, n \in \mathbb{N}$,
$$
W_{+}(m, n) \iff m \neq n.
$$
*Proof.* ($\Rightarrow$) If $m = n$, then $(m, n) = (m, m)$ is a loss by mirroring
(Theorem 5.1), contradicting $W_{+}(m, n)$; hence $m \neq n$.
($\Leftarrow$) Suppose $m \neq n$. If $n > m$, the move $(m, n) \to (m, m)$ is legal
(it decreases the second heap) and lands on the symmetric position $(m, m)$, which is
losing by Theorem 5.1; so $(m, n)$ has a move to a losing position and is winning.
The case $m > n$ is symmetric, moving the first heap down to $n$. ∎

The law is the classical P-position characterization of two-heap Nim, now proved for
the countdown instance from the general mirroring theorem: the losing positions are
exactly the diagonal $m = n$, and the winning move is always to equalize the heaps.
Theorem 7.2 is the case $m = n = 1$; Theorem 7.3 is the case $(m, n) = (0, 1)$.

---

## 8. Algorithms

The theory is fully constructive on decidable, locally finite games (finitely many
moves from each position), yielding simple recursive evaluators.

**Algorithm A (Value by well-founded recursion).** To compute $W(p)$: enumerate the
legal moves $q$ of $p$; $W(p)$ is true iff some child $q$ has $W(q)$ false. The
recursion terminates by well-foundedness. With memoization over the reachable
position set of size $N$ and out-degree $\le d$, the cost is $O(N d)$.

**Algorithm B (Optimal move).** If $W(p)$ is true, return any child $q$ with $W(q)$
false; such a child exists by Lemma 2.5. This realizes the winning strategy.

**Algorithm C (Sum evaluation and mirroring).** To evaluate $W_{+}(a, b)$, apply
Algorithm A to the sum move relation of Definition 3.1. For symmetric sums the
mirroring strategy of Section 5 gives an $O(1)$-per-move responder strategy that
provably wins without any search: reply to a move in one component by copying it in
the other. For countdown, Theorem 7.4 collapses the evaluation to the constant-time
test $m \neq n$, with the equalizing move as the winning reply.

---

## 9. Applications and connections

**Strategy stealing.** The mirroring theorem is the mechanism behind
non-constructive first-player-cannot-lose results (Hex, Chomp): a hypothetical
opponent strategy can be "stolen" or neutralized by symmetry. Our version isolates
the purely order-theoretic content — well-foundedness plus symmetry — from any
particular board.

**Combinatorial game theory.** The disjunctive sum and its value theory are the
foundation of the numbers-and-nimbers calculus used to evaluate endgames that
decompose into independent regions. Neutrality of the empty game and commutativity
are the first two axioms of that additive structure.

**Determinacy hierarchy.** Well-founded games are the terminating (rank-bounded but
transfinite) stratum beneath the infinite games of descriptive set theory, where
determinacy of increasingly complex payoff sets is calibrated by large-cardinal
strength. Theorem 6.2 is the base case: *every* well-founded game is determined,
outright and without extra set-theoretic hypotheses.

**Design lesson.** In any modular system assembled from independent terminating
components, the mirroring and two-heap phenomena warn that the "winner" of the whole
is not a naive function of the winners of the parts. Correct composition requires
computing the combined value, not assuming it.

---

## 10. Discussion and future directions

We have shown that the core algebra of disjunctive sums survives intact into the
transfinite, well-founded setting: sums stay terminating, the empty game is neutral,
values commute, symmetric sums always lose, and — via determinacy — the responder in
a symmetric sum wins by mirroring. The countdown instance gives a sharp two-heap
law that unifies two natural but false conjectures.

The principal open directions extend the two-valued grading to a full ordinal grade:

1. **Sprague–Grundy for transfinite games.** Define an ordinal-valued Grundy
   function $g(p) = \operatorname{mex}\{ g(q) : \mathrm{mv}(p, q) \}$, the least
   ordinal not among the grades of the children, and prove $W(p) \iff g(p) \neq 0$.
   This refines the win/lose dichotomy and would let one evaluate arbitrary sums,
   not only symmetric ones.

2. **Nim-addition theorem.** With $g$ in hand, prove
   $g(a + b) = g(a) \oplus g(b)$, the ordinal Nim-sum. The countdown special case is
   exactly the two-heap law $W_{+}(m, n) \iff m \neq n$ proved here; the general
   ordinal statement remains open.

3. **General $P + P = P$.** Prove that the disjunctive sum of two losing positions is
   losing. This resists a naive single induction — the induction measure is not
   controlled by either component alone — and appears to require the full Grundy
   machinery of direction 1.

These would complete the passage from a two-valued theory to a genuinely
arithmetic one for games that can almost last forever.

---

## References (standard background)

- E. Zermelo, *Über eine Anwendung der Mengenlehre auf die Theorie des
  Schachspiels* (1913).
- E. R. Berlekamp, J. H. Conway, R. K. Guy, *Winning Ways for Your Mathematical
  Plays*.
- J. H. Conway, *On Numbers and Games*.
- A. S. Kechris, *Classical Descriptive Set Theory* (for the determinacy hierarchy).
