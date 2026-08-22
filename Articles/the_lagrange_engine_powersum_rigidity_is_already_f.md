# The Price of Being Invisible

## A story about ghosts, moments, and how cheaply a signal can hide

Imagine a measuring instrument so crude that it can report only a handful of
numbers about whatever you place in front of it. Not the shape of the object,
not its colour — just a short list of averages. It tells you the total amount
of stuff, then the average position of that stuff, then the average of the
squares of the positions, then the cubes, and so on, but only up to some
fixed order. After that, its arithmetic runs out.

This is not a contrived device. It is essentially every instrument. A camera
integrates light against a finite set of sensor responses. A digital filter
sees a signal only through the frequencies it passes. A numerical quadrature
rule evaluates an integral by matching polynomials up to a fixed degree. A
tomograph, a spectrometer, a low-order Taylor model, a moment-matching
compression scheme: each of them reduces a rich object to a truncated list of
*moments*.

And every such instrument has ghosts.

A **ghost** is a nonzero configuration that the instrument reports as
absolutely nothing. Formally, put integer weights $e_0, e_1, \dots, e_N$ at
the positions $0, 1, \dots, N$ — think of $e_j$ as "how much stuff sits at
position $j$", allowed to be negative (a deficit) as well as positive. The
instrument reports the moments

$$m_k(e) \;=\; \sum_{j=0}^{N} e_j \, j^k, \qquad k = 0, 1, 2, \dots, K-1,$$

with the usual convention $0^0 = 1$, so that $m_0$ is simply the total weight.
Call $e$ **invisible to the window $K$** if all of these vanish:
$m_0 = m_1 = \dots = m_{K-1} = 0$. The instrument sees a perfectly empty
scene, yet something is there.

Ghosts always exist. The classical one is the alternating binomial stencil,
the $K$-th finite difference,

$$e_j = (-1)^{K-j}\binom{K}{j}, \qquad j = 0, 1, \dots, K,$$

whose moments vanish for every $k < K$ — this is the calculus fact that the
$K$-th difference annihilates polynomials of degree below $K$. So invisibility
is easy. The interesting question is **how much it costs.**

## Measuring the cost

The natural price tag is the total amount of material used:

$$\operatorname{mass}(e) \;=\; \sum_{j=0}^N |e_j|.$$

The binomial ghost is expensive. Its mass is $\sum_j \binom{K}{j} = 2^K$: to
hide from a window of size $30$ you would need over a billion units of stuff.
If that were the truth, ghosts would be a curiosity, not a threat — no real
signal, no real error, no real adversary could afford them.

But is it the truth? Can a ghost be cheap?

Write $\operatorname{minMass}(K)$ for the smallest possible mass of a nonzero
integer weight vector invisible to the window $K$. The question is the growth
of this single sequence. Three answers, one sharp and two approximate, are
what this article is about:

- **A hard floor.** Invisibility of order $K$ always costs at least $2K$ units
  of mass. Never less.
- **The floor is real.** For every window size up to $10$, and for $12$, the
  floor is attained exactly: there really are ghosts of mass exactly $2K$, and
  we can write them down.
- **A ceiling that collapses.** For *every* $K$, ghosts of mass at most
  $24^{\lceil K/12 \rceil}$ exist. That is a growth rate of
  $24^{1/12} \approx 1.3032$ per unit of window — a dramatic improvement on
  the binomial rate $2$, and the exponent gap widens without limit.

Between the floor $2K$ and the ceiling $1.3032^{K}$ lies the whole open
problem. Let us see where each of the three comes from.

## The floor: why $2K$, and not $K$

Split the ghost into its positive and negative halves. Let $s$ be the multiset
containing each position $j$ repeated $e_j$ times when $e_j > 0$, and let $t$
be the multiset containing each $j$ repeated $-e_j$ times when $e_j < 0$. Then
the mass of $e$ is exactly the total number of elements in $s$ and $t$
combined, and invisibility says something beautifully symmetric:

> The two multisets $s$ and $t$ have **identical power sums**
> $$\sum_{a \in s} a^k \;=\; \sum_{b \in t} b^k \qquad \text{for } k = 0, 1, \dots, K-1.$$

The case $k = 0$ says the two sides have the same number of elements, call it
$n$; then the mass is $2n$, and we must prove $n \ge K$.

Here is where an old identity does the work. Newton's identities express the
*elementary symmetric functions* of a collection of numbers — the coefficients
of the polynomial whose roots they are — recursively in terms of the power
sums. Matching power sums up to order $K-1$ therefore forces the elementary
symmetric functions to match up to the same order. In other words, the two
monic polynomials

$$F(X) = \prod_{a \in s}(X - a), \qquad G(X) = \prod_{b \in t}(X - b)$$

agree in their top $K$ coefficients.

Now suppose $n < K$. Both polynomials have degree $n$, and "agreeing in the
top $K$ coefficients" then means agreeing in *all* of them: $F = G$. Two monic
polynomials that are equal have the same roots with the same multiplicities,
so $s = t$ — and then $e$ is the zero vector, not a ghost. Contradiction.
Hence $n \ge K$ and

$$\boxed{\operatorname{mass}(e) \;\ge\; 2K}$$

for every nonzero ghost of window $K$. Half of the mass sits on each side, and
each side needs at least $K$ points, because $K$ points is exactly the amount
of freedom you need to fake $K$ moments.

The argument is worth pausing over. Earlier attempts to bound the cost of
invisibility counted *distinct positions*, which can never see the difference
between a weight of $1$ and a weight of $100$ at the same place. Switching
from sets of positions to multisets of "units of stuff" — and from moments to
symmetric functions — is what turns a weak count into the exact law.

## Attaining the floor: two teams with identical statistics

Can a ghost be as cheap as $2K$? It can, precisely when a very classical
object exists. A ghost of mass exactly $2K$ must consist of $K$ positions
carrying $+1$ and $K$ different positions carrying $-1$, and the invisibility
condition then reads: two disjoint sets of $K$ whole numbers,

$$A = \{a_1, \dots, a_K\}, \qquad B = \{b_1, \dots, b_K\},$$

with

$$a_1^k + \dots + a_K^k \;=\; b_1^k + \dots + b_K^k \qquad \text{for all } k = 1, \dots, K-1.$$

Two teams of $K$ players whose totals, sums of squares, sums of cubes, ...
agree all the way up to the $(K-1)$-st power, and only diverge at the $K$-th.
These are the **ideal Prouhet–Tarry–Escott configurations**, hunted since the
nineteenth century.

They are astonishing objects. Here is the one of size $6$:

$$\{0,5,6,16,17,22\} \quad\text{versus}\quad \{1,2,10,12,20,21\},$$

whose sums, sums of squares, cubes, fourth and fifth powers all coincide (at
$66$, $1090$, $19\,998$, $385\,234$, $7\,632\,966$) and whose sixth powers
finally differ ($154\,356\,970$ against $153\,752\,170$). And here is the one of size $12$, the largest known:

$$\{0, 11, 24, 65, 90, 129, 173, 212, 237, 278, 291, 302\}$$
$$\text{versus}\quad \{3, 5, 30, 57, 104, 116, 186, 198, 245, 272, 297, 299\},$$

twelve numbers against twelve numbers, agreeing in eleven successive power
sums — a coincidence of eleven simultaneous equations that no amount of
casual searching would produce.

Such a configuration is exactly a ghost of minimal mass. Consequently:

> **Attainment theorem.** $\operatorname{minMass}(K) = 2K$ if and only if an
> ideal Prouhet–Tarry–Escott configuration of size $K$ exists.

Explicit configurations are known for $K = 1, 2, \dots, 10$ and for $K = 12$,
so the minimal mass is *exactly* $2K$ at each of those windows. At $K = 11$ —
and this is not an accident of effort, it is a genuine century-old gap — no
configuration is known. But the two bounds pin it down almost completely: the
floor gives at least $22$, the size-$12$ configuration (restricted to a
smaller window) gives at most $24$, and a parity argument rules out $23$. So

$$\operatorname{minMass}(11) \in \{22, 24\},$$

and it equals $22$ exactly when an ideal size-$11$ configuration exists. A
famous open problem has become a two-valued question about a single explicit
integer.

There is also a rigidity phenomenon lurking. If a ghost achieves the minimum
mass, its two sides cannot overlap at all: no position may carry both a
positive and a negative contribution, no padding, no slack. The reason is
pretty: at minimal size the two root polynomials $F$ and $G$ differ by a
nonzero constant, so they can have no common root — and a shared position
would be exactly that.

## The ceiling: ghosts multiply

The floor $2K$ is linear. The binomial ceiling $2^K$ is exponential. Which is
closer to the truth? To push the ceiling down we need a way to manufacture
ghosts for large windows out of ghosts for small ones, and there is a perfect
tool: **convolution.**

Encode a weight vector as a polynomial, $P_e(X) = \sum_j e_j X^j$. Two facts
then become transparent.

First, invisibility is divisibility:

> A weight vector is invisible to the window $K$ exactly when $(X-1)^K$
> divides its polynomial.

(Differentiating $P_e$ and setting $X = 1$ recovers the moments, up to
invertible triangular bookkeeping.) Second, the mass of $e$ is the sum of
absolute values of the coefficients of $P_e$, and the coefficient sum of a
product is at most the product of the coefficient sums. Multiplying
polynomials therefore **adds windows and at worst multiplies masses**:

$$\operatorname{minMass}(K_1 + K_2) \;\le\; \operatorname{minMass}(K_1)\cdot \operatorname{minMass}(K_2).$$

(One must check the product is nonzero — over the integers it always is, but
the formal argument tracks the *first surviving moment* of each factor, which
multiplies to a nonzero top moment of the product.)

Iterating a single ghost — a **seed** of window $K_0$ and mass $L$ — gives, at
window $K_0 n$, a ghost of mass at most $L^n$. The growth base is
$L^{1/K_0}$: the mass per unit of window.

Now the arithmetic becomes a competition between seeds. The binomial stencil
is the seed $(K_0, L) = (1, 2)$: base $2$. A previously used seed, the size-3
configuration $\{1,5,6\}$ against $\{2,3,7\}$, has $(K_0, L) = (3, 6)$: base
$6^{1/3} \approx 1.8171$. But the size-12 configuration is a far cheaper seed,
$(K_0, L) = (12, 24)$, giving

$$24^{1/12} \;\approx\; 1.3032 .$$

Concretely, at the shared window $12n$ the older construction guaranteed mass
$6^{4n} = 1296^n$, and the new one guarantees $24^n$ — smaller by exactly
$54^n$. At window $36$, that is $7\,308$ actual units of mass against a
previous guarantee of over two billion. (The construction even outperforms its
own certificate: at window $24$ the guarantee is $576$ but the actual mass of
the doubled seed, after cancellation between colliding terms, is $512$.)

Rounding up to a multiple of $12$ gives a bound for every window at once, and
so the sequence is bracketed:

$$2K \;\le\; \operatorname{minMass}(K) \;\le\; 24^{\lceil K/12 \rceil}.$$

Honesty requires a caveat that the mathematics itself supplies: the
exponential ceiling only *improves* on the naive $2^K$ from $K = 13$ onwards.
Below that, the explicit configurations are enormously better. The value of
the ceiling is that it is uniform and unconditional, and that it improves
automatically whenever anyone finds a better seed.

## What the shape of the answer tells us

Step back and look at the two ends of the bracket. The lower bound is linear.
The upper bound is exponential with base $1.3032$. The gap is not a small
technical annoyance; it is the whole question, and the machinery above tells
us precisely what would close it.

Every ideal configuration of size $n_0$ is a seed with mass $2n_0$, hence a
growth base of $(2n_0)^{1/n_0}$. That quantity marches towards $1$:

| size $n_0$ | seed mass | base $(2n_0)^{1/n_0}$ |
|---:|---:|---:|
| 3 | 6 | 1.8171 |
| 12 | 24 | 1.3032 |
| 30 | 60 | 1.1462 |
| 120 | 240 | 1.0467 |
| 1000 | 2000 | 1.0076 |

So the conjecture that invisibility is *cheap* — that $\operatorname{minMass}(K)$
grows only polynomially, indeed that it equals $2K$ for every $K$ — is
*equivalent*, for this method, to the existence of ideal configurations of
unbounded size. That is the central open problem of a subject over a century
old. The composition machinery converts it into a pure existence question
about integer polynomials: is there, for each $K$, a nonzero polynomial with
integer coefficients divisible by $(X-1)^K$ whose coefficients sum (in
absolute value) to only $2K$?

That reformulation is itself a gift. The polynomial version needs no mention
of power sums or moments at all:

> **Polynomial mass theorem.** If $P$ is a nonzero polynomial with integer
> coefficients divisible by $(X-1)^K$, then the sum of the absolute values of
> its coefficients is at least $2K$; and $2K$ is attained for every
> $K \le 10$ and for $K = 12$.

And it suggests where to look. Convolution of ghosts is multiplication of
polynomials, and the cheapest known high-order zeros come from sparse products
such as $\prod_{i}(X^{a_i} - 1)$: each factor vanishes at $X = 1$, so $K$
factors give a $K$-fold zero, and the only question is how much cancellation
the exponents $a_i$ can be made to produce. With the lazy choice
$a_i = 1, 2, \dots, K$ the mass at $K = 12$ is $72$ — already far below the
binomial $4096$, though still triple the ideal $24$. Squeezing that gap is a
question about coefficient cancellation in products of binomials, a subject
with its own long history.

## Why any of this matters outside number theory

The window $K$ is a budget of moments, and every experiment has one. The
theorem $\operatorname{mass} \ge 2K$ says: to fool a $K$-moment instrument you
must expend at least $2K$ units of signal, split evenly between what you add
and what you remove. That is a genuine, unconditional security guarantee for
moment-based measurement — small perturbations cannot be invisible, and a
budget of moments buys a proportional guarantee against ghosts.

But the companion theorem is the warning: the guarantee is only *linear*.
Ghosts of mass $1.3032^K$ exist for every $K$ — and are far cheaper than the
$2^K$ that a naive analysis based on finite-difference stencils would suggest.
Whether the true cost of hiding is linear, exponential, or somewhere between
is undecided, and the undecided part is precisely a very old and very concrete
question about whole numbers: *how many teams of players can share all their
low-order statistics?*

There is something appealing in that. A question about the robustness of
measurement, stripped to its skeleton, turns out to be the Prouhet–Tarry–Escott
problem in disguise. And the mathematics is arranged so that the moment anyone
exhibits a set of thirteen numbers matching another thirteen in twelve power
sums, the entire theory improves by itself — a new seed drops in, the base
falls, and every bound downstream tightens without a line of argument being
rewritten.

Until then, the ledger reads:

$$2K \;\le\; \operatorname{minMass}(K) \;\le\; 24^{\lceil K/12\rceil},$$

with exact equality at the bottom for eleven of the first twelve windows, and
a single stubborn integer — $\operatorname{minMass}(11)$, either $22$ or $24$ —
standing between us and knowing the rest.
