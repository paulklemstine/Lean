# When Fibonacci Meets the Fifth Root of Unity

## A tiny question with a surprising answer

Draw a regular pentagon and label its five corners with the complex numbers
$1, \zeta, \zeta^2, \zeta^3, \zeta^4$, where $\zeta = e^{2\pi i/5}$ is a
*primitive fifth root of unity*. These are the five solutions of the equation
$z^5 = 1$, spaced evenly around the unit circle. They have one magical property
that will drive our entire story: they add up to nothing. Place all five arrows
tip-to-tail and you return exactly to where you started,
$$1 + \zeta + \zeta^2 + \zeta^3 + \zeta^4 = 0.$$

Now play a game. Pick a whole number $n$ and add up $n$ of these five arrows,
repeats allowed. For instance, with $n = 3$ you might choose $\zeta + \zeta + \zeta^3$,
or $1 + \zeta^2 + \zeta^4$, and so on. Each choice lands you at some point in the
plane, at some distance from the origin. Among **all** the ways to make such a sum
with exactly $n$ arrows, how close to the origin can you get *without landing
exactly on it*?

That "without landing exactly on it" is the whole point. Because the five arrows
cancel, it is often easy to hit the origin dead-on — but a bullseye is boring.
The interesting question is: what is the smallest *nonzero* distance you can
achieve? Call this number $\sigma_5(n)$. In symbols,
$$\sigma_5(n) = \min\Bigl\{\, \Bigl|\, \textstyle\sum_{j<n} \zeta^{c_j}\,\Bigr| \;:\; \text{the sum is not } 0 \,\Bigr\}.$$

It sounds like a curiosity. It turns out to be a doorway to the golden ratio,
the Fibonacci numbers, and their close cousins the Lucas numbers.

## The staircase of minimal distances

Let us compute the first few values by brute force — literally trying every
possible combination of arrows:

| $n$ | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| $\sigma_5(n)$ | $1.000$ | $0.618$ | $0.618$ | $0.382$ | $0.727$ | $0.382$ | $0.236$ | $0.236$ | $0.382$ | $0.449$ | $0.146$ |

At first glance the numbers jump around unpredictably. But two familiar constants
are hiding in plain sight. The value $0.618$ is $\varphi^{-1}$, the reciprocal of
the golden ratio $\varphi = \tfrac{1+\sqrt5}{2}$; and $0.382$ is $\varphi^{-2}$.
The distances cluster on powers of the golden ratio, holding steady for a while
and then abruptly dropping. It is a descending staircase — but where, exactly,
are the steps?

The key to taming the chaos is to stop reading the table left-to-right and start
reading it **five columns at a time**. Sort the values of $n$ by their remainder
when divided by $5$:

- remainder $1$: $\;\sigma_5(1), \sigma_5(6), \sigma_5(11), \sigma_5(16) = 1.000,\ 0.382,\ 0.146,\ 0.146$
- remainder $2$: $\;\sigma_5(2), \sigma_5(7), \sigma_5(12) = 0.618,\ 0.236,\ 0.236$
- remainder $0$: $\;\sigma_5(5), \sigma_5(10), \sigma_5(15) = 0.727,\ 0.449,\ 0.278$

Along each of these threads the numbers **never increase**. Every step of five
either keeps the distance the same or shrinks it. The staircase only ever goes
down.

## Why five arrows can never hurt you

The reason for this tidy monotonicity is beautiful and simple. Suppose you have
found a great combination of $n$ arrows landing very close to the origin without
hitting it. Now take one full set of all five arrows, $1 + \zeta + \zeta^2 + \zeta^3 + \zeta^4$,
and toss it into your sum. Because that full set adds to zero, your landing point
does not move at all — and in particular it is still not the origin. But you have
used $n + 5$ arrows now instead of $n$.

**This is the whole secret of monotonicity.** Anything you can achieve with $n$
arrows, you can achieve with $n + 5$ arrows, by padding with an invisible,
weightless block of five. So the best you can do with $n+5$ arrows is at least as
good as the best you can do with $n$:
$$\sigma_5(n+5) \le \sigma_5(n).$$
The minimal distance can only stay level or improve as you add complete blocks of
five. That is the entire proof, and it is airtight.

## Where the steps fall

Monotonicity tells us the staircase only descends. The deeper question is:
*when does it actually take a step down?* When is $\sigma_5(n)$ strictly larger
than $\sigma_5(n+5)$, rather than merely equal?

Here is where the golden ratio's fingerprints become unmistakable. The Fibonacci
numbers are the famous sequence $F_1 = 1,\, F_2 = 1,\, F_3 = 2,\, F_4 = 3,\,
F_5 = 5,\, F_6 = 8, \dots$, each the sum of the two before it. Their less-famous
siblings, the **Lucas numbers**, obey the same rule but start differently:
$L_0 = 2,\, L_1 = 1,\, L_2 = 3,\, L_3 = 4,\, L_4 = 7,\, L_5 = 11,\, L_6 = 18, \dots$
Both sequences march toward the golden ratio: the ratio of consecutive terms
tends to $\varphi$.

The central discovery is this: **the staircase takes a genuine step down at
position $N = n+5$ precisely when $N$ is one of the numbers**
$$5F_m, \qquad L_m, \qquad \text{or}\qquad 2L_m \quad (m \ge 1).$$

Let us test it against the data. The strict drops we observed happen at
$N = 6, 7, 8, 10, 11, 14, 15, 18, 22, \dots$. And indeed:
$6 = 2L_2$, $7 = L_4$, $8 = 2L_3$, $10 = 5F_3$, $11 = L_5$, $14 = 2L_4$,
$15 = 5F_4$, $18 = L_6$, $22 = 2L_5$. Every single jump is a Fibonacci multiple
or a Lucas number (possibly doubled). The three families — the "Fibonacci type"
$5F_m$, and the two "Lucas types" $L_m$ and $2L_m$ — account for every step in
the staircase, and nothing else does.

## The arithmetic that keeps the families apart

A skeptic might worry that these three families overlap in confusing ways, or
step on each other's toes. In fact they organize themselves with remarkable
discipline according to a single question: *is the position a multiple of five?*

The Fibonacci-type positions $5F_m$ are, by construction, always multiples of
five. The claim is that the Lucas-type positions are *never* multiples of five —
and this is a clean, checkable fact of pure arithmetic:

> **No Lucas number is ever divisible by $5$.**

Why? Look at the Lucas numbers one place at a time, keeping only their remainders
after division by five: $2, 1, 3, 4, 2, 1, 3, 4, \dots$. The pattern repeats with
period four, forever cycling through $2, 1, 3, 4$ — and $0$ never appears. This is
guaranteed by the recurrence itself: since each term is the sum of the previous
two, once the pattern of remainders repeats a pair it must repeat forever, and a
short check confirms it locks into that four-beat cycle. Doubling a Lucas number
cannot rescue it either: $5$ is coprime to $2$, so if $5$ divided $2L_m$ it would
have to divide $L_m$, which we have just ruled out.

The consequence is a clean **structure theorem**:

> **Every jump position that is a multiple of five belongs to the Fibonacci
> family** — it must be of the form $5F_m$.

So the residue of a position modulo five instantly tells you which family it can
possibly come from. The multiples of five are exactly $\{5F_m\}$; everything else
is Lucas territory. The data agrees on the nose: the only multiples of five among
the jump positions we found are $10, 15, 25, 40$, which are precisely
$5F_3, 5F_4, 5F_5, 5F_6$.

## A bridge between the two sequences

Underneath all of this lies an elegant identity connecting the Fibonacci and
Lucas worlds:
$$L_{n+1} = F_n + F_{n+2}.$$
In words: each Lucas number is the sum of the Fibonacci number two places back and
the one just ahead. This little bridge is what allows facts about one sequence to
be translated into facts about the other, and it is the algebraic engine behind
the classical "doubling" identities that make the golden ratio recurrence tick. It
is why a single geometric question about pentagon arrows ends up governed by two
intertwined sequences at once.

## The size of the first jump

The story would be incomplete without pinning down the *size* of a step, not just
its location. Consider the very first Lucas-type jump, at $N = 6 = 2L_2$. Using
six arrows we can build the arrangement $1 + 2\zeta + 2\zeta^3 + \zeta^4$. Because
the five roots sum to zero, this simplifies dramatically to
$$\zeta - \zeta^2 + \zeta^3 = \zeta\,(1 - \zeta + \zeta^2).$$
A short computation with the quantity $w = \zeta + \zeta^4 = 2\cos(72^\circ)$ —
which famously equals $\varphi^{-1} = \tfrac{\sqrt5 - 1}{2} \approx 0.618$ — shows
that the squared length of this arrow is $2 - 3w$. Since $w$ sits comfortably
between $\tfrac13$ and $\tfrac23$, the value $2 - 3w$ is a positive number smaller
than one. Working it out exactly gives
$$\sigma_5(6) = \sqrt{\tfrac{7 - 3\sqrt5}{2}} = \varphi^{-2} \approx 0.382.$$
Compare this with $\sigma_5(1) = 1$: adding one weightless block of five arrows to
a single arrow slashes the best achievable nonzero distance from $1$ all the way
down to $\varphi^{-2}$. The staircase has taken its first real step, and it has
landed squarely on a power of the golden ratio.

## Why it matters

What began as a doodle — pentagon corners and arrows — has revealed a hidden
architecture. The minimal nonzero distances form a staircase that only descends;
the descent is organized cleanly by remainders modulo five; the steps fall exactly
at Fibonacci multiples and Lucas numbers; and those families are held apart by the
simple fact that no Lucas number is divisible by five. The golden ratio presides
over the whole structure, both in the *positions* of the steps and in their
*heights*.

Questions of this kind — how small can a sum of roots of unity be without
vanishing? — are not idle. They sit at the crossroads of number theory, signal
processing, and the geometry of numbers, where "how close to zero can a structured
sum get" controls the stability of algorithms and the sharpness of Diophantine
estimates. The pentagon is the smallest arena in which the answer is nontrivial,
and it rewards the visit by handing us Fibonacci, Lucas, and the golden ratio all
at once. Larger primes promise their own hidden sequences, each tied to the
continued fraction of its own cyclotomic cosine — but that is a staircase for
another day.
