# The Vanishing Pentagon: How Five Roots That Sum to Zero Tame an Infinite Optimization

## A puzzle hiding in a regular pentagon

Draw a regular pentagon on the complex plane, centered at the origin, with one
corner sitting at the number $1$. Its five corners are the five *fifth roots of
unity*: the complex numbers that, when raised to the fifth power, come back to
$1$. Write $\zeta = e^{2\pi i/5}$ for the corner one fifth of the way around the
circle. Then the five corners are

$$1,\ \zeta,\ \zeta^2,\ \zeta^3,\ \zeta^4,$$

each a unit vector pointing to a vertex of the pentagon, spaced exactly
$72^\circ$ apart.

Now play a game. You are handed a budget of $n$ arrows. Each arrow must point to
one of the five pentagon vertices — you may reuse a direction as often as you
like. You lay the arrows tip to tail and ask: **how close to the origin can the
final tip land?** In symbols, you are choosing exponents $c_1, c_2, \dots, c_n$
(each in $\{0,1,2,3,4\}$) and forming the sum

$$S = \zeta^{c_1} + \zeta^{c_2} + \cdots + \zeta^{c_n},$$

and you want to make $|S|$ — the distance from the origin — as small as possible.
Call that smallest achievable distance $\sigma_5(n)$.

With one arrow ($n=1$) you can do no better than land at distance $1$: a single
unit vector has length $1$, so $\sigma_5(1) = 1$. With two arrows you can do
much better. Point one arrow at $1$ and the other at $\zeta^2$; because those two
vertices subtend an angle of $144^\circ$, their sum has length only
$2\cos(72^\circ) = \tfrac{\sqrt5 - 1}{2} \approx 0.618$, the reciprocal of the
golden ratio. So $\sigma_5(2) = \varphi^{-1}$, where
$\varphi = \tfrac{1+\sqrt5}{2}$ is the golden ratio itself. The pentagon and the
golden ratio are old friends, and here they meet again.

This little game turns out to conceal a clean and surprising piece of structure.
The purpose of this article is to explain one crisp fact about it — a
monotonicity law — and the single elegant idea that makes it true.

## The one identity that runs the whole show

Here is the fact that powers everything below. **The five pentagon vertices sum
to zero:**

$$1 + \zeta + \zeta^2 + \zeta^3 + \zeta^4 = 0.$$

Geometrically this is almost obvious: five equal-length arrows pointing to the
five vertices of a regular pentagon are perfectly balanced, so laid tip to tail
they close up into a pentagon and return exactly to where they started.
Algebraically it is the statement that $x^5 - 1 = (x-1)(x^4 + x^3 + x^2 + x + 1)$
and $\zeta \neq 1$ is a root of the second factor.

This balanced bundle of five arrows — one in each direction — is a *free move*.
If you already have some configuration of arrows summing to $S$, you can toss in
all five directions at once and the tip does not budge: you have spent five extra
arrows but the sum is still $S$. That single observation is the engine of the
entire result.

## Residue classes: five interleaved sequences

Because adding five arrows is free, the natural way to organize the numbers
$\sigma_5(0), \sigma_5(1), \sigma_5(2), \dots$ is to split them into five
separate threads according to the remainder of $n$ upon division by $5$. Write
any budget as $n = 5k + r$, where $r \in \{0,1,2,3,4\}$ is the *residue class*
and $k$ counts how many complete bundles of five you can afford. The five
threads are

$$
r=0:\quad \sigma_5(0),\ \sigma_5(5),\ \sigma_5(10),\ \dots
$$
$$
r=1:\quad \sigma_5(1),\ \sigma_5(6),\ \sigma_5(11),\ \dots
$$

and so on for $r = 2, 3, 4$. Within each thread, moving one step to the right
means increasing your budget by exactly five arrows — precisely one free bundle.

## The main theorem: each thread only ever goes down

> **Monotonicity Theorem.** For every residue $r \in \{0,1,2,3,4\}$, the
> sequence $k \mapsto \sigma_5(5k + r)$ is non-increasing. That is, for all
> $k$,
> $$\sigma_5\bigl(5(k+1) + r\bigr) \le \sigma_5(5k + r).$$

In words: **spending more arrows never hurts, as long as you spend them a full
bundle at a time.** More budget within a residue class can only bring you closer
to the origin, never push you farther away.

The proof is the free-move idea made precise, and it is worth savoring because it
is so short.

Suppose that with a budget of $n$ arrows you can reach some sum $S$ with
$|S| = d$. Take that exact configuration and add one balanced bundle — the five
arrows pointing to $1, \zeta, \zeta^2, \zeta^3, \zeta^4$. The new configuration
uses $n + 5$ arrows, and its sum is

$$S + \bigl(1 + \zeta + \zeta^2 + \zeta^3 + \zeta^4\bigr) = S + 0 = S,$$

still landing at distance $d$. So *every* distance achievable with $n$ arrows is
also achievable with $n+5$ arrows. The set of achievable distances only grows as
we move up a thread, and the smallest element of a larger set can only be smaller
(or equal). Taking $n = 5k + r$ and noting $5(k+1) + r = n + 5$ finishes the
proof. There is nothing special about the number $5$ here beyond the fact that
the complete bundle of roots sums to zero — a point we return to at the end.

## What the numbers actually look like

Monotonicity is a qualitative statement, but the threads are concrete and can be
computed. Here are the first few values, laid out by residue class, with each row
a single thread reading left to right in steps of five:

| $r$ | $\sigma_5(r)$ | $\sigma_5(5+r)$ | $\sigma_5(10+r)$ | $\sigma_5(15+r)$ |
|----|----|----|----|----|
| $0$ | $0$ | $0$ | $0$ | $0$ |
| $1$ | $1$ | $0.381966$ | $0.145898$ | — |
| $2$ | $0.618034$ | $0.236068$ | $0.236068$ | — |
| $3$ | $0.618034$ | $0.236068$ | $0.236068$ | — |
| $4$ | $0.381966$ | $0.381966$ | $0.145898$ | — |

Every row marches downward (or holds steady) — exactly as the theorem promises.
And the numbers themselves are beautiful. The residue-$0$ thread is identically
zero: with a multiple of five arrows you can simply lay down whole balanced
bundles and land perfectly on the origin. The nonzero values are not random
decimals; they are algebraic numbers living in the *golden field* $\mathbb{Q}(\sqrt5)$:

$$
\varphi^{-1} = \tfrac{\sqrt5 - 1}{2} \approx 0.618034,\qquad
\varphi^{-2} = \tfrac{3 - \sqrt5}{2} \approx 0.381966,
$$
$$
\sqrt5 - 2 \approx 0.236068,\qquad
\varphi^{-4} \approx 0.145898.
$$

The golden ratio, the pentagon's signature constant, governs how close you can
crowd toward the center.

## Why the values level off

Look again at the $r = 2$ and $r = 3$ threads. They drop from $0.618$ to
$0.236$ and then stop dropping — $\sigma_5(7) = \sigma_5(12) = 0.236068$. This is
not a coincidence, and it hints at a second layer of structure. Because
balanced bundles are free, any configuration can be stripped down to a *reduced*
core in which not all five directions appear at once: whenever every direction is
present, you can remove a whole bundle without changing the sum. There are only
finitely many essentially different reduced cores compatible with a given
residue, so as the budget grows you eventually have enough room to build the very
best reduced core, and after that extra arrows cannot help. Each thread therefore
decreases for a while and then plateaus at a fixed limiting value — a specific
number in the golden field $\mathbb{Q}(\sqrt5)$. The table already shows the
plateaus setting in.

## A geometric way to see it: nearest lattice points

There is a lovely reinterpretation that connects this puzzle to a corner of
geometry. The integer combinations of $1, \zeta, \zeta^2, \zeta^3, \zeta^4$ form
a discrete grid of points in the plane — a *lattice*. Fixing the total number of
arrows and its residue class carves out a slice of that lattice, and $\sigma_5(n)$
is nothing other than the distance from the origin to the nearest reachable point
in the slice. As you raise the budget, the box of allowed coefficients grows, the
reachable slice thickens, and the nearest point can only creep closer to the
origin. Monotonicity becomes the intuitive statement that *the closest point in a
larger haystack is at least as close.* This "closest vector" viewpoint is exactly
the language of lattice geometry, and it suggests that the fast algorithms of that
field could compute $\sigma_5(n)$ far more efficiently than the brute-force search
over all arrow arrangements.

## Why any of this matters

At first glance this is a recreational puzzle about pentagons and arrows. But sums
of roots of unity are a load-bearing wall of modern mathematics. They are the
*characters* of cyclic symmetry, the building blocks of the discrete Fourier
transform that underlies signal processing, and the raw material of Gauss sums in
number theory. Questions about how small such sums can be — how much cancellation
symmetry permits — reappear across coding theory, the study of equidistribution,
and the design of low-correlation sequences used in radar and communications.

The result here isolates the cleanest possible instance of that phenomenon. It
says that the *complete* cancellation encoded in $1 + \zeta + \zeta^2 + \zeta^3 +
\zeta^4 = 0$ has a monotone shadow: feed the system symmetry in whole units and it
relaxes, monotonically, toward the center. And the argument used nothing about the
number five except that the full set of roots sums to zero. The identical reasoning
applies to the $m$-th roots of unity for *any* $m \ge 2$: split budgets by
residue modulo $m$, use the free bundle of all $m$ roots, and conclude that the
minimal modulus is non-increasing along every residue class. What began as a game
with a pentagon turns out to be a general law about cyclic symmetry — one whose
whole force flows from a single vanishing sum.

## The takeaway

Five arrows in perfect balance sum to nothing. That one fact — a pentagon closing
up on itself — is enough to prove that giving yourself more arrows, five at a
time, can only help you approach the center. The golden ratio supervises the exact
distances; the residue classes organize the bookkeeping; and lattice geometry
waits in the wings to compute the answers. It is a small theorem with a large
pedigree, and a reminder that in mathematics the deepest leverage often comes from
the simplest identity.
