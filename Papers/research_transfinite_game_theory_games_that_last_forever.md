# Determinacy of Well-Founded Transfinite Games

## Abstract

We develop a self-contained theory of two-player, perfect-information games whose
positions are ordered by a **well-founded** move relation, and we prove that
every such game is determined. Well-foundedness — the nonexistence of any
infinite descending chain of legal moves — is a strictly weaker hypothesis than
finiteness: it permits game trees of arbitrary transfinite ordinal rank
($\omega$, $\omega^2$, and beyond) while still forbidding any single play from
lasting forever. We define the **value** $W(p)$ of a position by well-founded
recursion, establish the **Zermelo fixed-point equation**
$W(p) \iff \exists q\, (p \to q \wedge \neg W(q))$, and show that the canonical
greedy strategy derived from $W$ forces a win from every winning position against
every legal opponent. The central result is a transfinite form of **Zermelo's
theorem**: the player to move can force a win at $p$ if and only if $W(p)$ holds,
so every well-founded game is determined and $W$ computes its outcome. We
illustrate the theory with the countdown game on $\mathbb{N}$, whose value
function we compute in closed form, and we situate the result within the broader
determinacy hierarchy that connects to large cardinal axioms.

**Keywords:** transfinite game, well-founded relation, determinacy, Zermelo's
theorem, Sprague–Grundy value, ordinal rank, winning strategy, normal play.

---

## 1. Introduction

A two-player game of perfect information is, at its combinatorial core, a set of
*positions* together with a *move relation* specifying which positions can be
reached from which in one turn. Under the **normal-play convention**, the two
players alternate moves and a player who cannot move loses; equivalently, the
last player to move wins. The foundational question is whether the game is
**determined**: whether one of the two players necessarily possesses a strategy
guaranteeing a win.

Zermelo's theorem (1913) answers this affirmatively for *finite* games. The
purpose of this paper is to identify the exact structural hypothesis under which
Zermelo's conclusion survives into the infinite, and to prove it in that
generality. That hypothesis is **well-foundedness** of the move relation.

The distinction between "finite" and "well-founded" is the conceptual pivot of
the paper and deserves emphasis. Finiteness bounds the length of every play by a
single fixed number. Well-foundedness makes no such bound: it merely forbids an
infinite descending chain

$$p_0 \to p_1 \to p_2 \to \cdots.$$

A game may therefore admit plays of unbounded finite length — indeed of any
transfinite ordinal rank — while still guaranteeing that *each individual play
terminates*. This is precisely the regime of genuine transfinite games, and it is
where the theory below lives. A position from which countably many moves lead to
subgames of unbounded finite depth already has rank $\omega$; iterating the
construction yields rank $\omega^2$, $\omega^\omega$, and so on.

Our contributions are:

1. A definition of the value function $W$ by well-founded recursion, valid for
   arbitrary well-founded move relations (Section 3).
2. The Zermelo fixed-point equation and its immediate structural corollaries
   (Section 3).
3. A canonical optimal strategy, a proof that every play under it terminates, and
   an alternation invariant controlling the parity of winning positions
   (Section 4).
4. The determinacy theorem: $F(p) \iff W(p)$ (Section 5).
5. A fully worked transfinite instance, the countdown game, with its value
   computed in closed form (Section 6).

Section 7 discusses the frontier beyond well-foundedness — Gale–Stewart, Borel
determinacy, and the large-cardinal connection — and lists directions for
extension.

---

## 2. Setup and conventions

Throughout, fix a type (set) of positions $P$ and a binary **move relation**
$\mathrm{mv} \subseteq P \times P$. We write $p \to q$ for $\mathrm{mv}(p, q)$,
read "there is a legal move from $p$ to $q$."

**Definition 2.1 (Well-founded game).** The move relation is *well-founded* if the
inverse relation is well-founded in the usual order-theoretic sense: there is no
infinite sequence $(p_n)_{n \in \mathbb{N}}$ with $p_n \to p_{n+1}$ for all $n$.
Equivalently, every nonempty set of positions has an element from which no move
leads back into the set (a minimal element for the "is reachable from" order).

**Definition 2.2 (Terminal position).** A position $p$ is *terminal* if the player
to move has no legal move: $\neg\,\exists q.\ p \to q$.

**Normal-play convention.** Players alternate. The player who faces a terminal
position — i.e. cannot move — loses. The last player to have moved wins. Draws are
impossible in this convention.

**Remark 2.3 (Generality of the impartial model).** The setup is stated
impartially: the moves available from $p$ do not visibly depend on which player is
to move. This is no loss of generality. A *partisan* game, in which the two
players have different move options, is modelled by encoding the identity of the
player-to-move into the position itself — a position becomes a pair (board state,
side to move), and each move flips the side. The impartial-looking theory below
therefore captures all alternating two-player perfect-information games.

---

## 3. The value function and the Zermelo fixed point

The value function assigns to each position a Boolean indicating whether the
player to move there has a winning strategy.

**Definition 3.1 (Value).** Define $W : P \to \{\text{true}, \text{false}\}$ by
well-founded recursion on the move relation:

$$W(p) \;:=\; \exists q.\ \big(p \to q\big) \wedge \neg\, W(q).$$

Because the recursion refers only to values $W(q)$ at successor positions $q$ with
$p \to q$, and because the move relation is well-founded, this definition is
legitimate and determines $W$ uniquely. Well-foundedness is exactly the condition
that licenses the recursion: every position is founded on the terminal positions
below it through a well-ordered (though possibly transfinitely tall) tower of
dependencies.

**Theorem 3.2 (Zermelo fixed-point equation).** For every position $p$,

$$W(p) \iff \exists q.\ (p \to q) \wedge \neg\, W(q).$$

*Proof.* Immediate by unfolding the well-founded recursion at $p$ (the fixed-point
unrolling of the recursor). The equation says that a position is winning exactly
when some legal move leads to a position that is losing for the opponent. $\square$

The fixed-point equation packages the entire local strategic logic, and every
structural fact we need is a one-line consequence.

**Corollary 3.3 (Winning positions have a good move).** If $W(p)$, then there
exists $q$ with $p \to q$ and $\neg W(q)$.

*Proof.* The forward direction of Theorem 3.2. $\square$

**Corollary 3.4 (Winners are never stuck).** If $W(p)$, then $p$ is not terminal.

*Proof.* By Corollary 3.3 there is a move $p \to q$, so $p$ has a legal move.
$\square$

**Corollary 3.5 (Terminal positions are losing).** If $p$ is terminal, then
$\neg W(p)$.

*Proof.* Contrapositive of Corollary 3.4. $\square$

**Corollary 3.6 (From a loss, every move gives the opponent a win).** If
$\neg W(p)$, then for every $q$ with $p \to q$ we have $W(q)$.

*Proof.* Suppose $p \to q$ and, for contradiction, $\neg W(q)$. Then
$\exists q.\ (p\to q)\wedge\neg W(q)$, so by the reverse direction of
Theorem 3.2 we would have $W(p)$, contradicting the hypothesis. $\square$

Corollaries 3.3 and 3.6 together are the strategic dichotomy: at a winning
position the mover *can* choose a move preserving the advantage; at a losing
position *every* move surrenders the advantage.

---

## 4. Strategies, termination, and alternation

We now convert the static value into a dynamic strategy and analyse the resulting
plays.

**Definition 4.1 (Legal strategy).** A function $o : P \to P$ is a *legal
strategy* if it produces a legal move from every non-terminal position:
$\forall x.\ \neg\,\mathrm{Terminal}(x) \Rightarrow x \to o(x)$.

**Proposition 4.2 (Legal strategies exist).** There is a legal strategy.

*Proof.* At each non-terminal $x$, select some witness $q$ with $x \to q$ (using
choice); at terminal positions set $o(x) = x$. This $o$ is legal by construction.
$\square$

**Definition 4.3 (Canonical optimal move).** Define $\mathrm{opt} : P \to P$ by:
if $W(x)$, let $\mathrm{opt}(x)$ be a witness $q$ from Corollary 3.3 (a legal move
to a losing position); otherwise $\mathrm{opt}(x) = x$.

**Proposition 4.4.** If $W(x)$ then $x \to \mathrm{opt}(x)$ and
$\neg W(\mathrm{opt}(x))$.

*Proof.* By the definition of $\mathrm{opt}$ and Corollary 3.3. $\square$

We analyse a game in which one distinguished player (the "mover" we are studying)
uses the canonical strategy while the other plays an arbitrary legal strategy $o$.

**Definition 4.5 (One step).** Given a legal opponent strategy $o$, define the
step map

$$\mathrm{step}(x) := \begin{cases} \mathrm{opt}(x) & \text{if } W(x), \\ o(x) & \text{if } \neg W(x). \end{cases}$$

At a winning position the analysed player moves (optimally); at a losing position
the opponent moves.

**Definition 4.6 (Trajectory).** The *trajectory* from $p$ is the sequence
$t : \mathbb{N} \to P$ defined by $t(0) = p$ and $t(n+1) = \mathrm{step}(t(n))$.

**Lemma 4.7 (Step behaviour).**
(a) If $W(x)$ then $x \to \mathrm{step}(x)$ and $\neg W(\mathrm{step}(x))$.
(b) If $\neg W(x)$, $x$ is non-terminal, and $o$ is legal, then
$x \to \mathrm{step}(x)$ and $W(\mathrm{step}(x))$.

*Proof.* (a) is Proposition 4.4 unfolded through Definition 4.5. For (b),
$\mathrm{step}(x) = o(x)$; legality gives $x \to o(x)$, and Corollary 3.6 gives
$W(o(x))$. $\square$

**Theorem 4.8 (Every play terminates).** Let $o$ be a legal strategy and $p$ any
position. Then there exists $n \in \mathbb{N}$ with $\mathrm{Terminal}(t(n))$.

*Proof.* Suppose not: $t(n)$ is non-terminal for all $n$. Then Lemma 4.7 (using
(a) when $W(t(n))$ and (b) otherwise) yields $t(n) \to t(n+1)$ for every $n$, an
infinite descending chain of moves. This contradicts well-foundedness — formally,
the nonempty set $\{t(n) : n \in \mathbb{N}\}$ would have no minimal element, since
for any $t(i)$ in it the element $t(i+1)$ is also in it and satisfies
$t(i) \to t(i+1)$. $\square$

Theorem 4.8 is the load-bearing use of well-foundedness on the *dynamic* side: the
same hypothesis that made the definition of $W$ legitimate also forces every
concrete play to halt, without any finite bound on its length.

**Theorem 4.9 (Alternation invariant).** Let $o$ be legal and $p$ any position.
For every $n$, if no terminal position occurs strictly before turn $n$ (i.e.
$t(k)$ is non-terminal for all $k < n$), then

$$W(t(n)) \iff \big(\,\mathrm{Even}(n) \iff W(p)\,\big).$$

In particular, from a winning start $p$ (so $W(p)$ true), the winning positions
along the play are exactly those at even turns.

*Proof.* Induction on $n$. For $n = 0$: $t(0) = p$, and $\mathrm{Even}(0)$ is
true, so the claim reduces to $W(p) \iff W(p)$. For the step, assume the invariant
at $n$ and that no terminal position occurs before turn $n+1$; in particular
$t(n)$ is non-terminal. Two cases via Lemma 4.7:

- If $W(t(n))$, then $\neg W(t(n+1))$ by (a). The inductive hypothesis gives
  $\mathrm{Even}(n) \iff W(p)$. Since $\mathrm{Even}(n+1) \iff \neg\mathrm{Even}(n)$,
  a truth-table check yields $\neg W(t(n+1)) \iff (\mathrm{Even}(n+1) \iff W(p))$.
- If $\neg W(t(n))$, then $W(t(n+1))$ by (b). The inductive hypothesis gives
  $\neg(\mathrm{Even}(n) \iff W(p))$, and again the parity flip yields the claim.

$\square$

---

## 5. Determinacy

We formalise "the mover can force a win" and prove it coincides with $W$.

**Definition 5.1 (Mover can force a win).** Say $F(p)$ holds if,
against every legal opponent strategy $o$, the play first reaches a terminal
position on an **odd** turn:

$$\forall o \text{ legal},\ \exists n.\ \mathrm{Odd}(n) \wedge \mathrm{Terminal}(t(n)) \wedge \big(\forall k < n.\ \neg\mathrm{Terminal}(t(k))\big).$$

The odd-turn condition encodes exactly "the opponent is the one who gets stuck":
turns $0, 2, 4, \dots$ are the analysed player's, so a terminal position first
appearing on an odd turn means the opponent, on the move, cannot move and loses.

**Theorem 5.2 (Determinacy of well-founded games — Zermelo, transfinite form).**
For every position $p$,

$$F(p) \iff W(p).$$

Consequently every well-founded game is determined: exactly one player has a
winning strategy, and $W(p)$ decides which.

*Proof.*
($\Rightarrow$) Suppose $F(p)$ but, for contradiction,
$\neg W(p)$. Fix any legal $o$ (Proposition 4.2) and take the first terminal turn
$n$, which is odd with no earlier terminal. The alternation invariant
(Theorem 4.9) applies at $n$ and gives
$W(t(n)) \iff (\mathrm{Even}(n) \iff W(p))$. Since $n$ is odd, $\mathrm{Even}(n)$
is false; since $\neg W(p)$, the right-hand biconditional
$(\mathrm{Even}(n) \iff W(p))$ is true, so $W(t(n))$ holds. But $t(n)$ is
terminal, so $\neg W(t(n))$ by Corollary 3.5 — a contradiction.

($\Leftarrow$) Suppose $W(p)$, and let $o$ be any legal strategy. By Theorem 4.8
there is a first terminal turn; let $n$ be the least such (so no earlier turn is
terminal). By Corollary 3.5, $\neg W(t(n))$. The alternation invariant gives
$W(t(n)) \iff (\mathrm{Even}(n) \iff W(p))$; since $\neg W(t(n))$, the right side
is false, i.e. $\neg(\mathrm{Even}(n) \iff W(p))$. Because $W(p)$ is true, this
forces $\mathrm{Even}(n)$ false, i.e. $n$ is odd. Thus for every legal $o$ the
first terminal turn is odd, which is precisely $F(p)$. $\square$

**Corollary 5.3 (Winning strategy realisation).** If $W(p)$, then the canonical
strategy is a winning strategy: against every legal opponent it forces the game to
end on the opponent's turn.

*Proof.* The reverse direction of Theorem 5.2. $\square$

**Remark 5.4.** Determinacy here is constructive in the sense that the winning
strategy is explicit — the greedy "move to a losing position" rule of
Definition 4.3 — rather than merely existential. The value $W$ both decides the
outcome and prescribes the play.

---

## 6. A worked transfinite instance: the countdown game

We instantiate the theory on a concrete game of ordinal rank $\omega$.

**Definition 6.1 (Countdown game).** Positions are the natural numbers
$\mathbb{N}$. The move relation is $a \to b \iff b < a$: from $a$ one may move to
any strictly smaller number.

**Proposition 6.2 (Well-foundedness).** The countdown move relation is
well-founded.

*Proof.* The inverse relation is the strict order $<$ on $\mathbb{N}$, which is
well-founded. There is no infinite strictly decreasing sequence of natural
numbers. $\square$

The rank of the countdown tree rooted at $n$ is exactly $n$. Ranging over all
starting positions, the family realises plays of every finite length, so the
game as a whole has ordinal rank $\omega$ — it is genuinely transfinite, not
bounded by any single finite number, yet every play terminates.

**Proposition 6.3 (Terminal positions).** In the countdown game, $n$ is terminal
$\iff n = 0$.

*Proof.* If $n > 0$ then $0 < n$ is a legal move, so $n$ is non-terminal. If
$n = 0$ then no $b < 0$ exists in $\mathbb{N}$, so $0$ is terminal. $\square$

**Theorem 6.4 (Value of the countdown game).** For every $n \in \mathbb{N}$,

$$W(n) \iff n \neq 0.$$

*Proof.* If $W(n)$, then by the fixed-point equation (Theorem 3.2) there is a move
$n \to q$, i.e. some $q < n$; hence $n \neq 0$. Conversely, if $n \neq 0$, then
$0 < n$ is a legal move to the position $0$; and $W(0)$ is false because $0$ is
terminal (Corollary 3.5 with Proposition 6.3). Thus $n \to 0$ with $\neg W(0)$,
so $W(n)$ by the fixed-point equation. $\square$

The optimal play is transparent: from any positive $n$, move directly to $0$,
leaving the opponent with no move. By Theorem 5.2 the player to move wins from
every $n \neq 0$, and loses from $0$.

---

## 7. Discussion and future directions

### 7.1 What well-foundedness buys, and where it stops

The entire development rests on a single hypothesis — well-foundedness — used
twice: once to legitimise the recursive definition of $W$ (Section 3), and once to
guarantee that every concrete play halts (Theorem 4.8). This is the exact frontier
of the "greedy value function" method. The instant we permit plays of length
exactly $\omega$ — infinite games in which the winner is decided by a property of
the *entire* infinite play rather than by who gets stuck — there is no descending
chain to exploit, no terminal position to serve as a base case, and the method
collapses. A fundamentally different, strategy-tree argument is required.

### 7.2 The determinacy hierarchy and large cardinals

For infinite-length games on sequence spaces, determinacy becomes a graded
phenomenon indexed by the topological complexity of the winning set:

- **Gale–Stewart:** open and closed games are determined (in ZFC).
- **Borel determinacy (Martin):** every game whose winning set is Borel is
  determined; this already requires substantial ZFC machinery.
- **Analytic determinacy:** follows from the existence of a measurable cardinal.
- **The Axiom of Determinacy (AD):** the assertion that *all* games on the reals
  are determined; it contradicts the Axiom of Choice but holds in canonical inner
  models and is equiconsistent with large-cardinal hypotheses (e.g. infinitely
  many Woodin cardinals).

The theorem of this paper is the well-founded, base-of-the-hierarchy case: it is
Zermelo's theorem, sharpened to arbitrary transfinite rank. It provides the secure
foundation on which the taller and far more delicate theory is built.

### 7.3 Future directions

1. **Ordinal rank and play-length bounds.** Attach to each position its
   well-founded rank as an ordinal and prove that the length of optimal play is
   controlled by the rank, making the "transfinite length" quantitative and
   connecting it to ordinal arithmetic ($\omega$, $\omega^2$, $\dots$).

2. **Sprague–Grundy theory.** Refine the Boolean value $W$ to a Grundy value in
   $\mathbb{N}$ (or the ordinals) via the minimal-excludant ($\mathrm{mex}$) of
   successors, and prove the sum-of-games theorem for well-founded impartial
   games.

3. **Partisan games and surreal numbers.** Specialise the position-encoded-turn
   model to Conway's partisan games and relate the value here to game values in
   the theory of surreal numbers.

4. **Beyond well-foundedness: topological determinacy.** Prove the Gale–Stewart
   theorem for open and closed games on Baire space — the next milestone, which
   requires plays of length exactly $\omega$ and a genuinely different argument.

5. **The determinacy hierarchy and large cardinals.** Borel determinacy
   (Martin's theorem), analytic determinacy from a measurable cardinal, and the
   equivalence of AD with inner-model and large-cardinal hypotheses.

6. **Concrete transfinite instances.** Work out the lexicographic game on
   $\mathbb{N} \times \mathbb{N}$ (rank $\omega^2$) and ordinal-indexed countdown
   games as further examples, computing their value functions explicitly.

---

## 8. Conclusion

We have shown that a single structural hypothesis — well-foundedness of the move
relation — is exactly what is needed to extend Zermelo's determinacy theorem from
finite games to games of arbitrary transfinite rank. The value function $W$,
defined by well-founded recursion and characterised by the Zermelo fixed-point
equation, both decides the winner and prescribes an explicit greedy winning
strategy. Every play under that strategy terminates in finitely many moves, and an
alternation invariant pins down the parity of the decisive turn, yielding the
determinacy theorem $F(p) \iff W(p)$. The countdown game
illustrates the theory on an object of rank $\omega$. Beyond this well-founded
frontier lies the deep and beautiful theory of infinite-length games, whose
determinacy is woven into the fabric of large-cardinal set theory.
