# Checkmate in Infinity: How Chess on an Endless Board Reaches Beyond the Numbers

Imagine a chessboard with no edges. It stretches out forever in every
direction, an infinite plain of black and white squares on which kings, rooks,
and bishops roam without ever bumping into a border. This is *infinite chess*,
and it is not merely a novelty. It is a laboratory in which one of the strangest
ideas in mathematics — the *transfinite*, the arithmetic of infinities — comes
to life in the shape of a game that anyone who has played chess can begin to
understand.

On an ordinary $8 \times 8$ board, every phrase a chess coach utters has a
finite number attached to it. "Mate in three." "Mate in seven." The number
counts moves, and it is always an honest whole number. But on the infinite
board something remarkable happens. There are positions from which one
player — call her White — can *force* checkmate no matter how her opponent
struggles, and yet there is **no finite number of moves** in which she can
guarantee it. She will always win; she simply cannot promise to win by move ten,
or move ten thousand, or move ten billion. The best honest statement she can
make is: *"I will mate you — in infinitely many moves."*

How can a guaranteed win take infinitely long? And once we admit that some wins
take "infinitely many" moves, are all such infinities the same size — or are
there positions that take *even longer* than merely infinite? This article is
about the surprising answer: the wins of infinite chess climb through a whole
tower of distinct infinities, and we can build explicit positions that sit on
each rung.

## The first infinity: mate in omega

Let us start with the simplest infinite win. Picture a position in which it is
Black's turn, and Black gets to make one fateful choice. Whatever whole number
$n$ Black picks — $1$, or $17$, or a googol — that choice commits Black to a
losing line in which White then delivers checkmate in exactly $n$ further forced
moves. Black cannot escape; every option leads to defeat. But Black *can* stall.
By choosing a gigantic $n$, Black pushes the checkmate arbitrarily far into the
future.

Now ask: in how many moves can White guarantee mate? Not in $5$, because Black
might have chosen $n = 6$. Not in a million, because Black might have chosen a
million and one. There is no finite bound that works for *all* of Black's
choices. Yet White wins every single game. The length of this win is the
smallest quantity that is bigger than every finite number. Mathematicians have a
name for exactly that quantity: the ordinal $\omega$ (the Greek letter omega),
the first *infinite* ordinal. So we say the position has **game value $\omega$**.

This is the mathematical content of the phrase "mate in omega." White's victory
is certain but unbounded. The value $\omega$ is not a paradox; it is a precise
measurement of a win that outruns every finite promise while still, in the end,
always arriving.

## Measuring wins with ordinals

To go further we need a clean way to *assign a number of moves* to a forced win,
even when that number is infinite. The tool is the **ordinal game value**,
defined by walking the tree of possible continuations:

- A position in which checkmate has just been delivered has value $0$: no moves
  remain.
- At a position where White (the winner) is to move, she plays the *best* line,
  the one that finishes soonest. So the value is the smallest of the values of
  her options, each counted plus one for the move she just made.
- At a position where Black (the loser) is to move, he plays the *most stubborn*
  line, dragging the game out as long as he can. So the value is the *supremum*
  — the least quantity not exceeded by any of his options, each again plus one.

The winner minimises; the loser maximises. The value that emerges is the exact
length of optimal play, and because the loser can sometimes choose among
infinitely many delaying options, that length can be an infinite ordinal.

Ordinals are the natural home for this measurement because they are built
precisely to *keep counting past infinity*. After all the finite numbers
$0, 1, 2, 3, \dots$ comes $\omega$; then counting resumes with
$\omega + 1, \omega + 2, \dots$; then $\omega + \omega = \omega \cdot 2$, and on
through $\omega \cdot 3$, up to $\omega \cdot \omega = \omega^2$, and beyond.
Ordinal arithmetic has a famous quirk: order matters in addition. Doing a
finite task and *then* an $\omega$-task takes $\omega$ time (the finite part is
swallowed), while doing an $\omega$-task and *then* a finite task genuinely
takes longer than $\omega$. This asymmetry is not a bug; it is exactly what we
need to describe games where "first you solve a long puzzle, then a short one"
differs from "first the short one, then the long one."

## Stacking puzzles: how to build a longer win

The single mate-in-$\omega$ trick is the seed. To grow it, we *chain puzzles
together*. Suppose we take a position $A$ and, at every spot where $A$ would end
in checkmate, we secretly splice in a fresh copy of a second position $B$. The
result is a combined game: "first fight your way through $A$; the moment you
would have won, you instead find yourself at the start of $B$; now fight through
$B$ too." Call this operation **grafting**.

Grafting behaves exactly like ordinal addition. If $A$ takes $\alpha$ moves and
$B$ takes $\beta$ moves, the grafted game takes $\beta + \alpha$ moves — the
outer game $A$ landing on the right, faithfully mirroring the order-sensitivity
of ordinal addition. This is the engine of the whole construction: **grafting
adds game values.**

Now iterate. Chain $k$ copies of the mate-in-$\omega$ position one after
another, and the win takes $\omega \cdot k$ moves. But we can do better than any
fixed $k$. Build a position where Black first picks a number $k$, and is then
forced to grind through $k$ consecutive copies of the mate-in-$\omega$ puzzle.
Black can make $k$ as large as he likes, so the win outlasts $\omega \cdot k$
for every $k$ — its value is the supremum of all of them, which is
$\omega \cdot \omega = \omega^2$. We have built a position that takes
$\omega^2$ moves: infinitely many infinities of moves.

## The tower of powers

Nothing stops us now. The position of value $\omega^2$ can itself be used as the
building block. Let Black pick $k$, then force him through $k$ chained copies of
the $\omega^2$ position: the value climbs to $\omega^3$. Repeating the idea, for
**every** natural number $n$ we can construct an explicit position whose game
value is exactly

$$\omega^n = \underbrace{\omega \cdot \omega \cdots \omega}_{n\ \text{times}}.$$

Each rung is genuinely higher than the last. Since $\omega > 1$, raising it to a
larger power gives a strictly larger ordinal, so the values

$$\omega^0 = 1,\quad \omega^1 = \omega,\quad \omega^2,\quad \omega^3,\ \dots$$

form a strictly increasing staircase reaching arbitrarily high through the
countable ordinals. Chess on the infinite board is not limited to "mate in
omega." It realises mate in $\omega^2$, mate in $\omega^{17}$, mate in
$\omega^n$ for any $n$ you name.

## The diagonal leap to omega-to-the-omega

The staircase $\omega, \omega^2, \omega^3, \dots$ is infinite, but every step on
it is a *finite* power of $\omega$. Is there a single position that transcends
the entire staircase at once?

Yes — and it is built by a **diagonal** move. Construct a position in which Black,
on the very first move, chooses a natural number $n$, and thereby commits himself
to playing the entire $\omega^n$ position. He might choose $n = 5$ and face the
$\omega^5$ puzzle, or $n = 500$ and face the $\omega^{500}$ puzzle. Because he
can pick $n$ as large as he pleases, the length of the forced win exceeds every
$\omega^n$. The value is the supremum of the whole staircase:

$$\omega^\omega = \sup\{\,\omega^0,\ \omega^1,\ \omega^2,\ \omega^3,\ \dots\,\}.$$

This position — mate in $\omega^\omega$ — sits strictly above every finite power
$\omega^n$. It cannot be reached by any of the staircase positions, no matter how
high you climb; it genuinely dominates them all. In one elegant stroke, the
diagonal construction vaults over the entire hierarchy it was built from.

## What has actually been proved

Stripping away the pieces and squares, the mathematical heart of the story is a
model of forced-win game trees together with their ordinal values, in which the
following are established rigorously:

- **Additivity of grafting.** Splicing game $B$ into the leaves of game $A$
  produces a game of value $\text{value}(B) + \text{value}(A)$ — sequential
  composition realises ordinal addition, with the correct right-additive order.
- **Mate in omega.** The choose-your-delay position has value exactly $\omega$,
  and this win admits *no* finite bound: White forces mate, but in no finite
  number of moves.
- **The power hierarchy.** For every natural number $n$ there is an explicit
  position of value exactly $\omega^n$, and these values strictly increase with
  $n$.
- **The diagonal position.** There is an explicit position of value exactly
  $\omega^\omega$, and it is strictly greater than the value of every $\omega^n$
  position — a bona fide leap past the whole finite-power tower.

Together these say something clean and startling: the complexity of *winning* in
infinite chess is not measured by ordinary numbers at all. It is measured by
ordinals, and the game values realised by concrete positions sweep upward
through $\omega$, through every $\omega^n$, and past them to $\omega^\omega$.

## Why it matters

There is a deep pleasure in watching an abstract idea from the far reaches of
set theory — the transfinite ordinals, invented in the nineteenth century to
tame different sizes of infinity — reappear, fully embodied, in a *game*. Chess
is the most concrete of pastimes: two players, alternating moves, a board you can
point at. And yet, freed of its edges, it becomes a machine for realising
infinities you cannot count to.

The moral reaches beyond chess. Whenever a process guarantees success but with no
uniform bound — a search that always terminates yet can be delayed arbitrarily, a
protocol that must eventually halt but whose adversary can stall — the honest
measure of its length is an ordinal, not an integer. Infinite chess gives this
abstraction a face. It lets us *see* that "eventually" comes in infinitely many
strengths, that "you will lose" can be true while "you will lose by move $N$" is
false for every $N$, and that even among the infinite delays there is a rich,
strict hierarchy climbing from $\omega$ to $\omega^\omega$ and, in principle,
beyond.

The endless board has no edges — and neither, it turns out, does the arithmetic
of its victories.
