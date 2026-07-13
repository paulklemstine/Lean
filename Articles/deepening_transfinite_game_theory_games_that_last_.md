# Games That Can Almost Last Forever

## A puzzle with no clock

Imagine a game between two players that never repeats a position and, more
strikingly, has no upper bound on how long it might run. Not "a very long time" —
genuinely unbounded, in a sense that ordinary counting cannot capture. And yet, no
matter how the two players move, the game is guaranteed to *end*. Someone always
gets stuck with no legal move, and that person loses.

This sounds paradoxical. If a game can go on arbitrarily long, how can we be sure
it ever stops? The resolution is one of the quiet triumphs of modern mathematics:
the notion of a **well-founded** relation. A game is well-founded when there is no
infinite descending sequence of moves — no play $p_0 \to p_1 \to p_2 \to \cdots$
that continues forever. Crucially, this does *not* mean the game is short. It can
have positions from which the longest possible play is astronomically, even
*transfinitely*, long. The length of play can be indexed by ordinal numbers that
soar past every finite bound. But every actual play, once started, terminates.

These are the games that "can almost last forever." This article is about their
hidden algebra — what happens when you play several such games at once — and about
a single elegant theorem that governs symmetry across all of them, from the
simplest countdown to games of unbounded transfinite depth.

## The value of a position: who is winning?

The foundational question in any two-player game of this kind is deceptively
simple: *from a given position, does the player about to move have a winning
strategy?* Call such positions **winning** (a win for the mover) and all others
**losing**. There is a beautiful self-referential rule that pins down exactly which
positions are which:

> A position is **winning** if and only if there exists a legal move to a **losing**
> position.

Equivalently, a position is **losing** exactly when *every* legal move leads to a
winning position — you are doomed to hand your opponent a win no matter what you do.
The base case is a position with no moves at all: the player to move is stuck, so a
**terminal** position is losing.

Why does this rule actually define a coherent notion of value, rather than chasing
its own tail forever? Because the game is well-founded. Every move strictly
decreases along a relation with no infinite descent, so the recursion always
bottoms out. This is the transfinite version of an argument that goes back to
Ernst Zermelo in 1913: in any such game, one of the players has a winning strategy.
There are no genuinely undetermined positions. We will call this fact
**determinacy**, and we return to it below.

## Adding games together

The real depth appears when we stop playing one game and start playing several at
once. This is the central construction of *combinatorial game theory*, and it is
called the **disjunctive sum**. Suppose you have two games sitting side by side, in
positions $a$ and $b$. A single move in the combined game $a + b$ consists of
choosing *one* of the two components and making a legal move there, leaving the
other component untouched. Play continues until neither component offers any move —
that is, until both are terminal — at which point the player to move loses.

The disjunctive sum is how real games decompose. A late-stage position in Go, Nim,
Domineering, or a dozen other games is really a sum of small independent regions;
understanding the whole means understanding how the values of the parts combine.
Our first structural result guarantees the construction is even legitimate in the
transfinite setting:

> **Sums stay finite-in-play.** If a game is well-founded, then its disjunctive sum
> with itself is also well-founded. No infinite play appears when you combine two
> terminating games, even though the combined game may have far greater transfinite
> depth.

So the value function is well-defined on sums, and we can ask how it behaves.

## The neutral element, and commutativity

Two facts feel intuitively obvious and turn out to be true — though "obvious" is a
dangerous word in game theory, as we will see.

> **The empty game is neutral.** If one component is terminal (it offers no moves at
> all), then adjoining it changes nothing: the combined position $a + b$ is winning
> exactly when $a$ alone is winning. The empty game is a genuine "zero."

> **Order doesn't matter.** The value of $a + b$ equals the value of $b + a$. Which
> board you imagine on the left is irrelevant.

Both are proved by induction along the well-founded move relation — the transfinite
generalization of ordinary mathematical induction, valid precisely because there is
no infinite descent to derail it.

## The flagship: doubling always loses

Here is the theorem at the heart of the story, and it is genuinely surprising the
first time you meet it.

> **A game plus a copy of itself is always a loss for the player to move.** For
> every well-founded game position $a$, the symmetric sum $a + a$ is a losing
> position: the player who must move first cannot win.

Read that again. It does not matter whether $a$ by itself is a winning position, a
losing position, a simple countdown, or a monstrous game of transfinite rank. As
soon as you set two identical copies side by side, the *second* player — the one
who responds — holds a winning strategy. And the strategy is astonishingly simple:

> **Mirror your opponent.** Whatever move the first player makes in one copy, the
> second player makes the *identical* move in the other copy.

After each such pair of moves, the two components are once again identical — the
position is symmetric again. The second player can always mirror, because the move
the first player just demonstrated is legal in the (previously identical) other
copy. So the symmetric player never runs out of responses first. And because the
game is well-founded, the back-and-forth cannot continue forever; someone must
eventually be stuck, and by the symmetry it is never the mirrorer. The first player
loses.

This is a transfinite incarnation of the famous **strategy-stealing** and
**mirroring** arguments. What makes it remarkable is its *total generality*: it
holds at every ordinal rank, for every well-founded game whatsoever, with a single
uniform strategy. Doubling is defeat.

Combined with determinacy — the guarantee that one side always has a winning
strategy — the flagship theorem sharpens to a strategic statement: in $a + a$, it is
specifically the *opponent* (the responder) who can force the win, by mirroring.

## The traps: when intuition fails

Good mathematics is as much about what is *false* as what is true, and the algebra
of games is a minefield of plausible-sounding falsehoods. Two conjectures in
particular look reasonable and are simply wrong. We can nail them down concretely
using the simplest interesting example: the **countdown game**.

In countdown, a position is a natural number $n$, and a legal move replaces $n$ by
any strictly smaller natural number. The only terminal position is $0$. It is easy
to check that $n$ is a winning position exactly when $n \neq 0$: from any positive
number you simply move straight to $0$ and hand your opponent the dead position.

Now consider the disjunctive sum of two countdown heaps — this is precisely
**two-heap Nim**.

> **Myth 1: "The sum of two winning positions is winning."** Surely if I can win
> game $A$ and I can win game $B$, I can win $A + B$? **False.** The position $1$ is a
> win (move to $0$). But $1 + 1$ is a *loss*: whatever you do in one heap, your
> opponent mirrors in the other, and you are the one left facing $0 + 0$. Two wins
> combine into a loss.

> **Myth 2: "A losing component can be dropped without changing the winner."** If a
> component is a losing position, surely it is dead weight that cannot help anyone?
> **False.** The position $0$ is a loss, and $1$ is a win, yet $0 + 1$ is a *win* for
> the mover — not because $0$ is neutral, but because you simply ignore the dead
> heap and play the live one. Only the truly *empty* game is neutral; a losing
> position is not an absorbing "zero."

Both traps dissolve into a single, sharp, and beautiful law once we look at
two-heap Nim in full generality.

## The two-heap law

> **Two-heap countdown is a win for the mover exactly when the heaps are unequal.**
> The sum of countdown heaps $m$ and $n$ is a winning position if and only if
> $m \neq n$.

This one equivalence contains everything. When $m = n$, the position is symmetric —
$a + a$ — and the flagship mirroring theorem says the mover loses. When $m \neq n$,
the mover has a decisive move: shave the larger heap down until it equals the
smaller one, handing the opponent a symmetric (hence losing) position. Both myths
above are now instant special cases: $1 + 1$ has equal heaps (a loss), while
$0 + 1$ has unequal heaps (a win). One clean law, two exploded intuitions.

## Why this matters

At first glance this is recreational mathematics — clever facts about toy games.
But the ideas run deep and wide.

The mirroring theorem is the same conceptual engine behind strategy-stealing
proofs that show the first player in games like Hex or Chomp *cannot lose with best
play*, even when we cannot exhibit their winning strategy explicitly. The
disjunctive sum and its value theory are the backbone of the celebrated theory of
combinatorial games that assigns "numbers" and "nimbers" to positions and lets
experts evaluate enormously complex endgames by adding up small local values.

The transfinite dimension connects to something grander still. Well-founded games
of unbounded ordinal rank are the finite-length cousins of the infinite games
studied in the theory of **determinacy**, where whether *every* game of a given
complexity has a winning strategy turns out to be intertwined with the deepest
axioms of set theory — the existence of very large infinite cardinals. Our
guarantee that every well-founded game is determined is the ground floor of that
towering edifice: the case where, however long the ladder, every climb is
guaranteed to end.

And there is a lesson that travels far beyond games. Symmetry is powerful, but it
does not compose the way we expect. Two winning situations can cancel into a loss;
a dead component can still be decisive; only genuine emptiness is truly neutral.
Whenever a system is built by combining independent parts — logic circuits,
concurrent processes, resource-allocation problems — the arithmetic of who-wins
rarely respects our first guesses. The disjunctive sum teaches us to compute, not
to assume.

## The horizon

Two natural next steps beckon. The first is to replace the crude
winning/losing label with a full **ordinal-valued grade** for each position — a
transfinite version of the Sprague–Grundy value — measuring not just whether you
win but *how*. The second is the corresponding **addition law**, expressing the
grade of a sum as a special "exclusive-or" of the grades of its parts. For
countdown, that law is exactly the two-heap rule we proved; in full transfinite
generality it remains a tantalizing open problem.

Until then, one crisp truth stands: in any game that can almost last forever,
playing against a perfect copy of yourself is a game you were always going to lose.
