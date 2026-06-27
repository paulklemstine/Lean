# The Secret Arithmetic of Magic Squares

## When a single number decides everything

Magic squares are one of humanity's oldest mathematical toys. A child can
grasp the rules in seconds: fill a grid with numbers so that every row, every
column, and the two long diagonals all add up to the same total. Yet behind
this innocent puzzle hides a surprisingly deep question — one that, in its most
demanding form, turns out to be governed by a single arithmetic fact about the
size of the grid.

The most beautiful and most punishing version of the puzzle is the
**panmagic** (or *pandiagonal*) square. Here you demand far more than the
ordinary diagonals. You insist that *every* broken diagonal works too. Imagine
wrapping the grid around a doughnut, so the right edge meets the left and the
top meets the bottom. Now slide a diagonal line across this doughnut at any
starting point, in either of the two slanted directions; it wraps around and
hits exactly one cell in each row and each column. A panmagic square demands
that *all* of these wrapped diagonals — there are $2n$ of them on an
$n \times n$ board — sum to the magic constant. They are the squares that stay
magic no matter how you cut the doughnut.

These objects are gorgeous, but they are also rare and fussy. Try to build one
by hand and you quickly feel that something about certain board sizes simply
*resists* you. A $4 \times 4$ panmagic square exists. A $5 \times 5$ exists.
A $6 \times 6$? No matter how you try, it cannot be done. There is a wall, and
the wall is built out of arithmetic. The purpose of this article is to explain
exactly where that wall comes from, using one of the cleanest ideas in all of
combinatorics: the **affine permutation**.

## Turning a grid into a formula

To tame an infinite zoo of possible squares, mathematicians look for squares
with structure — squares you can describe by a formula instead of a table. The
simplest interesting recipe is the **affine** one. Work on the clock with $n$
hours, the set of remainders $\{0, 1, 2, \dots, n-1\}$, which mathematicians
write as $\mathbb{Z}/n\mathbb{Z}$ (or $\mathbb{Z}_n$). Pick two numbers $a$ and
$b$ on this clock, and define the map

$$\sigma(x) = a x + b \pmod{n}.$$

This little function shuffles the clock positions around. It is the engine that
generates a structured square: row by row, you shift the pattern by an amount
governed by $a$ and $b$. The whole question of whether the resulting square is
magic — and panmagic — collapses into questions about this one formula.

The first thing to ask is: when does $\sigma$ even *shuffle* the clock at all,
rather than collapsing different positions onto the same one? You want a genuine
rearrangement, a permutation, where every output is hit exactly once. The answer
is a classical pearl:

> **The shuffle works exactly when $a$ is a *unit* on the clock.**

A unit is a number $a$ that has a multiplicative partner $a^{-1}$ with
$a \cdot a^{-1} = 1 \pmod n$ — a number you are allowed to "divide by." On the
12-hour clock, $5$ is a unit (because $5 \times 5 = 25 = 1 \pmod{12}$), but
$6$ is not (no multiple of $6$ ever lands on $1$). The reason units are exactly
the right condition is satisfying in both directions. If $a$ is a unit, then the
inverse map $y \mapsto a^{-1}(y - b)$ undoes $\sigma$ perfectly, so nothing is
lost. And if $a$ is *not* a unit, then multiplication by $a$ genuinely crushes
distinct inputs together, and the map fails to be a shuffle. This equivalence
holds not just on clocks but in any commutative ring whatsoever — a fact we will
lean on repeatedly.

## The three guardians of "panmagic"

Now comes the heart of the story. Being a permutation makes the rows and columns
behave. But the panmagic property is about the *diagonals* — both families of
wrapped diagonals — and those impose two extra demands. Each demand turns out to
be a clone of the first one, just with the multiplier shifted.

Consider the first diagonal family. Walking along one of these diagonals
corresponds to looking at the quantity $\sigma(x) - x$. For the diagonals to
behave like proper transversals (hitting every symbol exactly once), this new
map must *also* be a shuffle. But watch what happens when you simplify:

$$\sigma(x) - x = (a x + b) - x = (a - 1)x + b.$$

It is the very same affine shape! It is a shuffle exactly when its multiplier,
$a - 1$, is a unit. A permutation with this property has a classical name: an
**orthomorphism**.

The second diagonal family, slanting the other way, corresponds to
$\sigma(x) + x$. The same algebra applies:

$$\sigma(x) + x = (a x + b) + x = (a + 1)x + b,$$

a shuffle exactly when $a + 1$ is a unit. A permutation of this kind is called a
**complete mapping**.

So the entire, intimidating panmagic property — every row, every column, and
both full families of wrapped diagonals simultaneously perfect — distills into a
single, crystalline statement about three consecutive numbers:

> **Master Theorem.** The affine map $\sigma(x) = a x + b$ produces a panmagic
> square on the $n$-clock if and only if all three of
> $$a, \quad a - 1, \quad a + 1$$
> are units modulo $n$.

The shift $b$ plays no role in whether the square is panmagic; it only slides
the pattern around. Everything rides on the multiplier $a$ and its two
neighbors. Three consecutive integers, each required to be invertible on the
clock. That is the whole secret.

## Why six is the magic wall

Once you see the Master Theorem, the existence question almost answers itself.
We are hunting for *some* multiplier $a$ such that $a-1$, $a$, and $a+1$ are all
units at once. When is that possible? The obstructions come from the smallest
primes.

**The obstruction at 2.** Suppose $n$ is even, so the prime $2$ divides $n$.
Among any two consecutive numbers, one is even and one is odd; an even number is
never a unit on an even clock (it shares the factor $2$). Look at $a$ and
$a - 1$: they are consecutive, so one of them is even, hence not a unit. The
panmagic conditions cannot all hold. A direct check confirms it on the smallest
even clock: on $\mathbb{Z}_2$ there is simply *no* value of $a$ for which both
$a$ and $a - 1$ are units. Even boards are doomed before they start.

**The obstruction at 3.** Suppose instead $3$ divides $n$. Now look at the three
numbers $a - 1$, $a$, $a + 1$ — three *consecutive* values. Modulo $3$ they are
forced to cover all three residues $0, 1, 2$ in some order, so one of them is
divisible by $3$, hence not a unit. Again the panmagic conditions collapse. The
smallest case $\mathbb{Z}_3$ confirms it: no value of $a$ makes all of $a-1$,
$a$, $a+1$ units.

Put these together and you learn that a panmagic affine square is *impossible*
whenever the board size is divisible by $2$ or by $3$. That single observation
already topples $n = 6$ — divisible by both — and explains the wall every
puzzle-builder runs into.

What is remarkable is that these are the *only* obstructions. If $n$ avoids both
$2$ and $3$ — that is, if $n$ is **coprime to $6$** — then a panmagic square
always exists, and you do not even need a clever construction. Just take
$a = 2$. Then the three numbers you need to be units are
$$a - 1 = 1, \qquad a = 2, \qquad a + 1 = 3.$$
On a clock whose size shares no factor with $6$, the numbers $1$, $2$, and $3$
are automatically all units. A single, universal recipe works for every
admissible board. We arrive at the punchline:

> **Existence Theorem.** A panmagic affine permutation of the $n$-clock exists
> if and only if $n$ is coprime to $6$ — that is, if and only if $n$ is
> divisible by neither $2$ nor $3$.

So the boards that admit these maximally symmetric squares are exactly
$$1, 5, 7, 11, 13, 17, 19, 23, 25, \dots$$
and the forbidden boards are exactly the multiples of $2$ or $3$:
$$2, 3, 4, 6, 8, 9, 10, 12, \dots$$
The mystery of which magic squares exist dissolves into a child's divisibility
rule.

## How many are there?

Knowing that panmagic affine squares exist is one thing; counting them is
another, and here the structure pays off again. For each fixed admissible board,
every valid multiplier $a$ can be paired with any shift $b$ — and there are $n$
choices of shift. So the number of panmagic affine permutations is exactly $n$
times the number of "good" multipliers, where a multiplier is good when $a$,
$a-1$, and $a+1$ are all units.

Counting the good multipliers has a beautiful answer that respects the prime
factorization of $n$. Because the clock $\mathbb{Z}_n$ splits, via the Chinese
Remainder Theorem, into independent smaller clocks for each prime power dividing
$n$, the count is *multiplicative*: solve it one prime power at a time and
multiply. For a single prime power $p^k$ with $p \geq 5$, the number of good
multipliers is
$$p^{k-1}(p - 3),$$
because you must avoid the three "bad" residues $0$, $1$, and $-1$ that would
make $a$, $a-1$, or $a+1$ vanish. For the forbidden primes $p \in \{2, 3\}$ the
count is zero, recovering the existence wall. The total count of good multipliers
is therefore the tidy product
$$P(n) = \prod_{p^k \,\|\, n} p^{k-1}(p - 3),$$
and the number of panmagic affine permutations is $n \cdot P(n)$. On a
$5 \times 5$ board, for instance, $P(5) = 5^0(5 - 3) = 2$, giving $5 \times 2 =
10$ panmagic affine permutations — a number you can verify by brute force in
seconds. The arithmetic of three consecutive units controls not just whether
these objects exist, but precisely how abundant they are.

## A wider horizon

The story does not stop at diagonals one step apart. Demand that
$\sigma(x) + j x$ be a shuffle for every shift $j$ from $-r$ to $r$, and you get
an "$r$-panmagic" square, sensitive to ever-wider families of slanted lines.
The same logic predicts that such a square exists exactly when every prime
factor of $n$ exceeds $2r + 1$ — the wall simply marches outward as you grow
more demanding, and the witness $a = r + 1$ keeps working. Replace addition by
two different multipliers and you recover the classical notion of *orthogonal*
Latin squares, the combinatorial structures behind error-correcting codes and
statistical experiment design; affine maps $\sigma_{a,b}$ and $\tau_{c,d}$ turn
out to be orthogonal exactly when $a - c$ is a unit. And one can leave the clock
entirely, replacing single numbers by matrices acting on higher-dimensional
grids, where "unit" becomes "invertible matrix" and the three guardians become
$A$, $A - I$, and $A + I$.

What began as a parlor puzzle — arrange the numbers so the lines add up — has
become a clean theorem about the multiplicative life of three consecutive
integers. The deep symmetry of a perfect panmagic square, magic in every
direction across the doughnut, lives or dies on whether $a - 1$, $a$, and
$a + 1$ can all be inverted at once. And that, in the end, depends on a single
question you could ask a schoolchild: *is your number divisible by two or by
three?* If not, magic in every direction is yours for the taking.
