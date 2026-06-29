# How a Perfect Geometry Beats the Coupon Collector

## The agony of the last sticker

Anyone who has ever tried to complete a sticker album, fill out a set of
trading cards, or collect every prize hidden in cereal boxes knows the
peculiar cruelty of the endgame. At the start, every packet brings something
new. Near the finish, you tear open packet after packet only to find
duplicates of things you already own, waiting forever for that one missing
piece.

Mathematicians have a name for this: the **coupon collector's problem**. If
there are $n$ different coupons and each draw gives you a uniformly random one,
the expected number of draws needed to collect them all is

$$
n \cdot H_n = n\left(1 + \tfrac12 + \tfrac13 + \cdots + \tfrac1n\right).
$$

For $n = 7$ coupons this comes out to exactly $\tfrac{363}{20} = 18.15$ draws
on average. That logarithmic tail — the $H_n$ factor — is precisely the
mathematics of the frustrating endgame.

But what if you didn't draw coupons one at a time? What if every draw handed
you a carefully chosen *bundle* of coupons at once? Then the question becomes
much richer, and surprisingly, it connects the everyday annoyance of sticker
albums to one of the most elegant objects in all of geometry: the **projective
plane**.

## Drawing bundles instead of singles

Let us generalize. Fix a finite set of points — these are our coupons. Instead
of single coupons, fix a family of **blocks**, where each block is a subset of
points. At every step we draw one block uniformly at random, and a point counts
as *covered* the moment any drawn block contains it. The **cover time** is the
first step at which every point has been covered.

The classical coupon collector is the special case where each block is a single
point: there are $n$ singleton blocks, and drawing a block just means drawing a
coupon. With bigger blocks, each draw can cover several points at once, so we
should expect to finish faster. The interesting question is *how the geometry of
the blocks* changes the answer.

There is a beautiful exact formula for the expected cover time. For each point
$p$, let $\tau_p$ be the first step at which a block containing $p$ is drawn.
The cover time is the largest of these, $\max_p \tau_p$, and a classical
identity called inclusion–exclusion turns "the maximum" into a signed sum over
all nonempty subsets $S$ of points:

$$
\mathbb{E}[\text{cover time}]
= \sum_{\emptyset \neq S} (-1)^{|S|+1}\,\frac{|B|}{c(S)},
$$

where $|B|$ is the number of blocks and $c(S)$, the **coverage count** of $S$,
is the number of blocks that intersect $S$. The ratio $c(S)/|B|$ is exactly the
chance that a single random draw covers *some* point of $S$, so $|B|/c(S)$ is
the expected wait until the first point of $S$ appears — and the alternating sum
assembles these waiting times into the expected time to cover everything.

When every block is a singleton, a set $S$ is met by exactly the blocks sitting
on its own points, so $c(S) = |S|$, and the formula collapses back to the
textbook value $n\,H_n$. The general framework contains the classic as a special
case.

## Enter the Fano plane

Now meet the star of the story. The **Fano plane** is the smallest projective
plane: seven points and seven lines, arranged so that

- every line contains exactly **3** points,
- every point lies on exactly **3** lines, and
- every pair of distinct points lies on exactly **1** common line.

That last property — "any two points determine a unique line" — is the same
axiom that governs ordinary geometry, compressed into a finite world of just
seven points. Drawn on paper, the Fano plane is usually shown as a triangle with
its three medians and an inscribed circle; the seven lines are the three sides,
the three medians, and the circle. In symbols, its seven lines on the points
$\{0,1,2,3,4,5,6\}$ can be listed as

$$
\{0,1,2\},\ \{0,3,4\},\ \{0,5,6\},\ \{1,3,5\},\ \{1,4,6\},\ \{2,3,6\},\ \{2,4,5\}.
$$

This is the canonical example of a **balanced incomplete block design**, a
$2\text{-}(7,3,1)$ design: seven points, blocks of size three, every pair
covered exactly once. Such designs are the gold standard of combinatorial
balance, and they appear everywhere from experiment scheduling to
error-correcting codes.

What happens if we run the coupon collector with the seven Fano lines as our
blocks?

## Counting how lines meet sets

To use the cover-time formula we need the coverage counts $c(S)$ for the Fano
lines.

A **single point** is met by exactly the three lines through it, so $c(S) = 3$
whenever $|S| = 1$.

A **pair of distinct points** is met by every line through either point. Each
point sits on three lines, giving $3 + 3 = 6$, but the unique line through
*both* points is counted twice, so we subtract one: $c(S) = 3 + 3 - 1 = 5$
whenever $|S| = 2$. (It is worth flagging that an early guess of $4$ here is
wrong; the correct value is $5$, and getting it right matters for the final
arithmetic.)

For larger sets the coverage count is no longer a function of the size alone.
Three points lying *on a common line* behave differently from three points in
"general position," because the Fano plane's symmetry group is rich enough to
move any pair to any other pair, but not rich enough to ignore the difference
between collinear and non-collinear triples. So the higher coverage counts must
simply be tabulated point set by point set.

## The verdict: geometry wins big

Carrying out the alternating sum over all $127$ nonempty subsets of the seven
points yields a clean rational number:

$$
\mathbb{E}[\text{cover time of the Fano lines}] = \frac{163}{30} \approx 5.43.
$$

Compare this with the classical collector on the same seven points, drawing one
coupon at a time:

$$
7 \cdot H_7 = \frac{363}{20} = 18.15.
$$

The Fano design finishes in well under a third of the time. And the reason is
exactly the geometry: a single Fano line already delivers three of the seven
points in one stroke, and because any two points share a line, the blocks knit
the whole plane together with remarkable efficiency. Where the lone collector
agonizes over the last few stickers, the Fano collector mops up the plane in a
handful of draws.

## A conjecture corrected

This story carries a twist worth telling honestly, because it is part of how
mathematics actually works. The investigation began with the opposite guess:
that the perfectly balanced projective-plane design should be the *slowest*
possible way to cover the points — that its rigid balance would somehow drag out
the collection. Stated precisely, the original claim was that the Fano cover
time should *exceed* $7 \cdot H_7$.

The numbers refute it cleanly. Since $\tfrac{163}{30} \approx 5.43$ is far below
$\tfrac{363}{20} = 18.15$, the design is dramatically *faster*, not slower, than
collecting singletons. The intuition that "more balance means more waiting" is
simply backwards in this comparison: in any model where covering more points can
only help, an efficient covering design can only *lower* the expected time. The
projective plane is extremal — but it is extremal by being maximally
*efficient*, not maximally slow.

This is not a failure; it is a sharpening. The corrected result is both true and
more beautiful: the most balanced geometry on seven points is also the fastest
to sweep them up.

## Why balance still might mean *slower* — against the right opponent

There remains a subtle and genuinely open thread. Comparing the Fano lines
against *singletons* is comparing blocks of size three against blocks of size
one — of course the bigger blocks win. The deeper question fixes the block size
and asks: among all "fair" mechanisms that draw blocks of size $q+1$, with every
point appearing in equally many blocks, is the projective-plane design the
*slowest*?

Here the intuition about balance may finally come into its own. A
$2\text{-}(n,\ell,1)$ design spreads its pairwise overlaps as evenly as humanly
possible — every pair of points is covered by exactly one block. That perfect
low-order balance forces a hidden surplus of *high-order* clumping: the blocks
must agree heavily on larger configurations precisely because they are so
even-handed on pairs. And it is high-order clumping, invisible to the first two
coverage moments, that slows a collector down. The conjecture — still awaiting
proof — is that among all fair, equal-block-size mechanisms, the projective
plane maximizes the expected cover time, with the entire ranking of mechanisms
controlled by a single number: the variance of how often pairs are co-covered.

## The bigger picture

The coupon collector began as a puzzle about cereal boxes, but in its general
form it becomes a lens on the structure of randomness itself. Replace single
coupons with structured bundles and the *shape* of those bundles — their
overlaps, their symmetries, their balance — takes over the story. The Fano
plane, a jewel of finite geometry that also underlies error-correcting codes and
combinatorial designs, turns out to be the most efficient possible way to sweep
up its seven points.

And the corrected conjecture reminds us that mathematics rewards skepticism:
even a beautiful, plausible guess must answer to the arithmetic. When it did, the
truth that emerged was cleaner than the conjecture that preceded it — perfect
geometry, it turns out, doesn't slow the collector down. It sets the collector
free.
