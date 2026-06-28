# Counting With a Dial: The Shifted Eulerian Numbers

## A triangle hidden inside permutations

Shuffle a deck of cards and read it from top to bottom. Every so often a card is
*smaller* than the one just above it — the sequence "goes down." Mathematicians
call each such drop a **descent**. The arrangement $2, 5, 3, 1, 4$ has descents
between $5$ and $3$, and between $3$ and $1$: two descents in all.

A natural question follows immediately: among all the ways to arrange the numbers
$1, 2, \dots, n$, how many have exactly $k$ descents? The answer is a single
integer, written $\langle n, k\rangle$ and called an **Eulerian number**, after
Leonhard Euler, who stumbled on them in the 1750s while summing powers of
integers. Arrange these counts in rows, one row for each $n$, and a beautiful
triangle emerges:

$$
\begin{array}{ccccccc}
n=1: & 1 \\
n=2: & 1 & 1 \\
n=3: & 1 & 4 & 1 \\
n=4: & 1 & 11 & 11 & 1 \\
n=5: & 1 & 26 & 66 & 26 & 1 \\
n=6: & 1 & 57 & 302 & 302 & 57 & 1
\end{array}
$$

Each row is symmetric — reading it backward gives the same numbers, because
reversing a permutation turns descents into ascents and vice versa. Each row also
sums to a factorial: $1+4+1 = 6 = 3!$, because *every* arrangement of three items
has *some* number of descents, and there are $3! = 6$ arrangements in total. And
like Pascal's famous triangle of binomial coefficients, every entry can be built
from the two entries above it through a simple rule.

This article is about what happens when you take that triangle and give it a
**dial** — a single continuous knob, a real number $s$, that you can turn to slide
the whole structure smoothly off its integer moorings. The result is a family of
**extended Eulerian numbers** $A(n, k, s)$. Turn the dial to $s = 0$ and you
recover Euler's classical triangle exactly. Turn it anywhere else and you get a
new, perfectly well-behaved table of numbers that obeys almost the same laws. The
surprise is that the most important law of all — the building rule of the triangle
— survives the deformation essentially intact.

## From counting to a formula

The building rule is easiest to see if we first write Eulerian numbers not as a
count but as a **formula**. There is a classical closed form, due to Worpitzky,
that produces $\langle n, k\rangle$ directly:

$$
\langle n, k\rangle = \sum_{i=0}^{k} (-1)^i \binom{n+1}{i}\,(k+1-i)^{\,n}.
$$

Here $\binom{n+1}{i}$ is the usual binomial coefficient ("$n+1$ choose $i$"), and
the alternating signs $(-1)^i$ make the sum telescope down to a single clean
integer. For instance, with $n = 3$ and $k = 1$:

$$
\langle 3, 1\rangle = \binom{4}{0}\,2^3 - \binom{4}{1}\,1^3 = 8 - 4 = 4,
$$

matching the $4$ sitting in the middle of row three.

Now install the dial. Wherever the formula contains the quantity $k+1-i$, simply
subtract our continuous parameter $s$:

$$
\boxed{\,A(n, k, s) = \sum_{i=0}^{k} (-1)^i \binom{n+1}{i}\,(k+1-i-s)^{\,n}.\,}
$$

That single subtraction is the whole idea. When $s = 0$, the boxed formula *is*
Worpitzky's formula, so $A(n, k, 0) = \langle n, k\rangle$ and we are back to
counting descents. When $s$ is any other real number — a half, a third, $0.7$,
$\sqrt{2}$ — the powers $(k+1-i-s)^n$ become ordinary real numbers, the alternating
sum still collapses, and $A(n, k, s)$ is a perfectly definite real value. The
integer triangle has become a continuous *surface*.

## The law that survives

What makes the classical Eulerian triangle so useful is its **recurrence**: a rule
that grows each row from the one above it. In words, a new entry is a blend of the
entry directly above it and the entry above-and-to-the-left, with weights that
depend on the position. For the shifted numbers the rule reads:

$$
A(n+1, k+1, s) = (k + 2 - s)\,A(n, k+1, s) + (n - k + s)\,A(n, k, s).
$$

This is the **main result**. Set $s = 0$ and it becomes the textbook Eulerian
recurrence $\langle n+1, k+1\rangle = (k+2)\langle n, k+1\rangle + (n-k)\langle n,
k\rangle$. For any other $s$, the two weights have simply absorbed the dial: one
gains a $-s$, the other gains a $+s$. Crucially, **the two weights always add up to
$n + 2$, no matter where you set the dial**, because the $-s$ and the $+s$ cancel.
That cancellation is the secret behind why turning the knob does not break the
machine — and, as we will see, it is also why every row keeps summing to a
factorial.

It is worth pausing on what kind of statement this is. We did **not** define
$A(n, k, s)$ by the recurrence and then check it counts something. We defined it by
the explicit boxed formula — a finite alternating sum of binomial coefficients —
and then *proved* that this formula satisfies the growth rule. There is no
circular reasoning: the recurrence is a genuine theorem about the formula, derived
from two of the oldest facts in combinatorics.

## Two ancient bricks

The entire proof rests on two elementary identities about binomial coefficients,
both known for centuries.

The first is **Pascal's rule**, the rule that builds Pascal's triangle itself:

$$
\binom{n+2}{j+1} = \binom{n+1}{j} + \binom{n+1}{j+1}.
$$

Every entry is the sum of the two above it. The second is the **absorption
identity**, a slightly less famous but equally elementary fact that lets you trade
a stray multiplicative factor for a shift in the indices:

$$
(j+1)\binom{n+1}{j+1} = (n+1)\binom{n}{j}.
$$

From these two bricks, the proof builds three intermediate tools, each a statement
about *alternating binomial sums* of the very shape that appears in our formula.
The first tool **splits** a sum over $\binom{n+2}{i}$ into two sums over
$\binom{n+1}{\cdot}$, by applying Pascal's rule term by term. The second tool
**absorbs** a linear factor of $i$ out of such a sum, using the absorption
identity to lower the top index from $n+1$ to $n$. The third tool **recombines**
two $\binom{n}{\cdot}$ sums back into a single $\binom{n+1}{\cdot}$ sum, again via
Pascal's rule but run in reverse.

Chain split, then absorb, then recombine, and the closed form for
$A(n+1, k+1, s)$ rearranges itself — through pure algebra, with the dial $s$ riding
along passively — into exactly $(k+2-s)A(n, k+1, s) + (n-k+s)A(n, k, s)$. The
parameter $s$ never interferes with the binomial machinery; it simply travels
through the calculation and lands in the final coefficients.

## The edges of the surface

A growth rule needs a place to start. The shifted triangle has three boundary
facts, all read straight off the formula.

At the very top, **$A(0, 0, s) = 1$** for every $s$: the empty sum has a single
term equal to one, no matter how the dial is set. The apex of the triangle is
nailed down.

Along the top row, **$A(0, k+1, s) = 0$** for every $k$: past the first column,
the zeroth row vanishes identically. The triangle really is a triangle — there is
nothing to the right of its diagonal.

Down the left wall, something more interesting happens. The classical Eulerian
triangle has a column of pure $1$'s on its left edge: there is exactly one
permutation with zero descents (the sorted one). Turn the dial, and that column of
ones bends into a column of **powers**:

$$
A(n, 0, s) = (1 - s)^{\,n}.
$$

At $s = 0$ this is $1^n = 1$, the familiar left edge. But for, say, $s = \tfrac37$,
the left edge becomes $1, \tfrac47, \tfrac{16}{49}, \tfrac{64}{343}, \dots$ — the
powers of $1 - s$. The dial has lifted the rigid integer edge into a smooth
geometric curve. This single boundary value, incidentally, is exactly the piece of
data that pins down the parameter $s$ uniquely: it is the "initial condition" that
distinguishes one setting of the dial from another.

## Why the rows still add up to factorials

Here is a small miracle you can check by hand. Take the shifted triangle at *any*
dial setting and add up a row. You always get $n!$ — the same factorial as the
classical triangle, completely independent of $s$:

$$
\sum_{k=0}^{n} A(n, k, s) = n!.
$$

For $n = 3$ and $s = \tfrac25$, the four entries are messy-looking rational
numbers, yet they sum cleanly to $6 = 3!$. Why? Because of the cancellation we
noticed earlier. When you sum the recurrence across an entire row, each old entry
$A(n, k, s)$ gets multiplied once by a weight $(k+2-s)$ and once, in the next term,
by a weight $(n-k+s)$. Those two weights add to $n+2$, and the $s$'s annihilate.
So summing one row and stepping to the next simply multiplies the total by a fixed
factor — and starting from $A(0,0,s)=1$, the totals march up the factorials
$1, 1, 2, 6, 24, \dots$, with the dial leaving no trace. The conserved quantity
survives the deformation precisely because $s$ was injected antisymmetrically into
the two weights.

## A worked turn of the dial

Let us watch the machine run once. Start with row $n = 2$ at the half-turn
$s = \tfrac12$. The formula gives the three entries

$$
A(2, 0, \tfrac12) = (1-\tfrac12)^2 = \tfrac14, \qquad
A(2, 1, \tfrac12) = \tfrac32, \qquad
A(2, 2, \tfrac12) = \tfrac14,
$$

which already sum to $2 = 2!$ and are symmetric, a faint echo of the classical
row $1, 1$. Now grow the entry $A(3, 1, \tfrac12)$ using the recurrence with
$n = 2$, $k = 0$:

$$
A(3, 1, \tfrac12) = (0 + 2 - \tfrac12)\,A(2,1,\tfrac12) + (2 - 0 + \tfrac12)\,A(2,0,\tfrac12)
= \tfrac32\cdot\tfrac32 + \tfrac52\cdot\tfrac14 = \tfrac94 + \tfrac58 = \tfrac{23}{8}.
$$

Computing $A(3, 1, \tfrac12)$ directly from the boxed closed form gives
$\tfrac{23}{8}$ as well. The two roads meet, exactly as the theorem promises — and
they meet not just here but at every entry, for every real setting of the dial, a
fact confirmed across thousands of cases in the accompanying numerical
demonstrations.

## Why deform a perfectly good triangle?

Adding a continuous parameter to a discrete object is one of the oldest moves in
mathematics, and it pays off in two ways. First, it reveals which properties are
*rigid* and which are *flexible*. We have seen that the factorial row-sum is rigid
(it ignores the dial entirely), while the left edge is flexible (it bends from
$1$'s into powers of $1-s$). Knowing which is which tells you what the original
integers were "really" measuring.

Second, a dial connects neighbouring theories. The classical Eulerian numbers sit
at the crossroads of permutation statistics, the summation of powers, the geometry
of slicing a cube into simplices, and the spline functions used in computer
graphics and numerical analysis. A one-parameter family threads through all of
these at once. The boundary value $A(n,0,s) = (1-s)^n$, for example, is exactly the
kind of geometric weighting that appears when one evaluates piecewise-polynomial
splines at a shifted knot — hinting that the dial $s$ has a life beyond pure
combinatorics.

The promising leads are concrete. The shifted formula suggests a **Worpitzky-type
expansion** writing $(x-s)^n$ as a combination of the $A(n,k,s)$ against shifted
binomial polynomials, generalizing the classical identity that first led Euler to
these numbers. It suggests a deformed **generating function**, a one-parameter
bending of the classical $(t-1)/(t - e^{(t-1)x})$, with the dial entering only
through the initial edge $A(n,0,s) = (1-s)^n$ we computed. And it raises the
question of whether each row, viewed as a sequence in $k$, remains **log-concave**
— a smooth, single-humped shape — as the dial turns through the interval from $0$
to $1$.

Every claim in this article — the closed-form definition, the three boundary
values, and above all the master recurrence with its perfectly balanced weights —
has been verified to the standard of a formal mathematical proof, built up from
nothing but Pascal's rule and the absorption identity. The dial turns, the triangle
flexes, and the law that grows it holds firm. Euler's eighteenth-century counting
problem, it turns out, was just one frame of a continuous film.
