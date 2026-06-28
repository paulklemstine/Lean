# The Sum of All Primes: A Tale of Two Infinities

## A number that shouldn't exist

There is a famous, almost scandalous, equation that circulates in physics
classrooms and popular-science videos:

$$1 + 2 + 3 + 4 + \cdots = -\tfrac{1}{12}.$$

Taken literally, it is nonsense. Add positive whole numbers forever and you do
not drift toward a small negative fraction; you race off to infinity. And yet
this equation appears, with the right interpretation, in real physics — in the
computation of the Casimir force between metal plates, and in the counting of
vibrational modes of a string. The trick is that the left-hand side is not a sum
at all. It is a *regularized* value: a finite fingerprint left behind by an
infinite process, extracted through a procedure called **analytic continuation**.

This article is about a natural and seductive sequel to that story. If the sum of
all the positive integers can be tamed into $-\tfrac{1}{12}$, what about the sum
of all the **prime numbers**?

$$2 + 3 + 5 + 7 + 11 + 13 + \cdots = \; ?$$

Primes are the atoms of arithmetic — the indivisible building blocks from which
every whole number is assembled by multiplication. A "regularized sum of all
primes" would be a single number that somehow distills the entire prime sequence.
It is the kind of object that sounds like it *should* exist, by analogy with the
$-\tfrac{1}{12}$ story.

The surprising, rigorous answer is this: the most direct route to such a number
is **provably blocked**. And understanding exactly *why* it is blocked — and why
the integers escape the same trap — turns out to be a small, beautiful lesson in
where the magic of regularization really comes from.

## The machine that turns sums into functions

To make sense of "infinite sums that aren't really sums," mathematicians use a
device called a **Dirichlet series**. Instead of adding numbers directly, you add
them after raising each to a *negative power* controlled by a knob $s$:

$$\zeta(s) = \frac{1}{1^s} + \frac{1}{2^s} + \frac{1}{3^s} + \cdots = \sum_{n=1}^{\infty} n^{-s}.$$

This is the celebrated **Riemann zeta function**. The knob $s$ is the secret to
everything. When $s$ is large, the terms shrink fast and the sum settles down to
a finite number. For example, a classical result of Euler gives
$\zeta(2) = 1 + \tfrac14 + \tfrac19 + \cdots = \pi^2/6 \approx 1.6449$.

But here is the key idea. Once you have a *function* $\zeta(s)$ defined for the
values of $s$ where the sum converges, you can ask whether that function extends
smoothly — analytically — to other values of $s$ where the original sum makes no
sense at all. This extension is unique when it exists, and it is the heart of
analytic continuation. Riemann showed that $\zeta(s)$ extends to (almost) the
entire complex plane. And when you feed the extended function the value
$s = -1$, you get

$$\zeta(-1) = -\tfrac{1}{12}.$$

Formally, plugging $s = -1$ into the *series* would read
$\sum n^{-(-1)} = \sum n = 1 + 2 + 3 + \cdots$ — the runaway sum of the integers.
The series diverges; the function does not. That gap between "the series" and
"the function" is exactly where $-\tfrac{1}{12}$ lives. In our formal
development this value is established precisely — call it the theorem
$\zeta(-1) = -\tfrac{1}{12}$ — derived from the classical Bernoulli-number
formula for $\zeta$ at negative integers.

## The prime version of the machine

Now restrict the same construction to primes only. Define the **prime zeta
function** by summing over the primes $p = 2, 3, 5, 7, \ldots$:

$$P(s) = \frac{1}{2^s} + \frac{1}{3^s} + \frac{1}{5^s} + \frac{1}{7^s} + \cdots = \sum_{p \text{ prime}} p^{-s}.$$

The "sum of all primes" we are chasing is the value we would *want* to assign at
$s = -1$, since there $p^{-(-1)} = p^1 = p$, giving $2 + 3 + 5 + 7 + \cdots$.

The first question any honest mathematician asks is: for which settings of the
knob $s$ does this series actually converge? The answer is sharp and clean, and
it is the central result of this work.

> **Main theorem (abscissa of convergence).** The prime zeta series
> $P(s) = \sum_p p^{-s}$ converges if and only if $s > 1$.

There is no ambiguity and no boundary case that sneaks through. The number $1$ is
a wall, called the **abscissa of convergence**. To the right of it, at $s > 1$,
the terms shrink fast enough and the sum is a finite positive number. At the wall
and to its left, at every $s \le 1$, the series diverges.

A concrete example makes the wall vivid. Take $s = 1$ itself. The series becomes

$$P(1) = \frac{1}{2} + \frac{1}{3} + \frac{1}{5} + \frac{1}{7} + \frac{1}{11} + \cdots,$$

the sum of the reciprocals of the primes. Euler proved, already in 1737, that
this diverges — it crawls to infinity, but only *just*: its partial sums grow
like $\log \log n$, one of the slowest divergences in all of mathematics. The sum
of the first million prime reciprocals is still only about $3.3$. Yet it never
stops growing. Our formal account recovers exactly this fact as the boundary case
of the main theorem: the series at $s = 1$ is **not** summable.

Push the knob all the way to $s = -1$ and the situation is far worse. The terms
$p^{-(-1)} = p$ do not shrink at all; they grow without bound. The series
$2 + 3 + 5 + 7 + \cdots$ obviously diverges, and we prove it does so as a direct
consequence of the main theorem (since $-1 \le 1$).

This is the honest obstruction, stated plainly:

> **The "sum of all primes" point.** At $s = -1$, the defining series
> $\sum_p p$ diverges. Therefore any regularized value, if one exists, can
> *never* be the value of the series itself — it would have to come from a
> genuine analytic continuation.

## Two series, one wall

Here the story takes its most elegant turn. We just saw that the prime zeta
series hits its wall at $s = 1$. But where is the wall for the *full* zeta series
$\sum_n n^{-s}$, the one that famously yields $-\tfrac{1}{12}$?

It is in *exactly the same place*. Our work proves a clean equivalence:

> **Same abscissa.** For every real $s$, the prime series $\sum_p p^{-s}$
> converges if and only if the full series $\sum_n n^{-s}$ converges. Both have
> abscissa of convergence exactly $1$.

This is striking. As bare series — as naive infinite sums — the integers and the
primes are governed by the same threshold. Neither one converges at $s = -1$.
Neither one converges at $s = 1$. From the point of view of raw convergence, they
are twins.

And yet only one of them, the full zeta function, can be continued to $s = -1$ to
produce $-\tfrac{1}{12}$. The prime zeta function cannot. The two series sit on
opposite sides of an invisible fence even though they share the same convergence
wall. So what is the difference? If the wall is in the same place, why does one
escape and the other stay trapped?

## The secret ingredient: multiplication

The answer is that primes carry *multiplicative* information, and that
information behaves very differently from additive information when you try to
continue past the wall.

The bridge between the two worlds is one of the most beautiful identities in
mathematics, **Euler's product formula**:

$$\zeta(s) = \prod_{p \text{ prime}} \frac{1}{1 - p^{-s}}.$$

It says the additive object $\zeta(s) = \sum_n n^{-s}$ is secretly a *product*
over primes — a direct consequence of the fact that every integer factors
uniquely into primes. Take the logarithm of both sides and expand, and the prime
zeta function $P(s)$ emerges as the leading piece:

$$\log \zeta(s) = P(s) + \tfrac{1}{2}P(2s) + \tfrac{1}{3}P(3s) + \cdots.$$

This is the formula that tells you the prime zeta function is the logarithmic
shadow of the full zeta function. And logarithms are dangerous things to
continue. The full zeta function $\zeta(s)$ extends to a smooth (meromorphic)
function on the entire complex plane, with a single pole at $s = 1$. But
$\log \zeta(s)$ inherits a logarithmic singularity wherever $\zeta$ has a zero or
a pole — and to build $P(s)$ from $\log \zeta$ you must stitch together
infinitely many copies $\log \zeta(s), \log \zeta(2s), \log \zeta(3s), \ldots$,
rescaled toward the imaginary axis. Their singularities pile up and crowd
together along the line $\mathrm{Re}\,s = 0$.

The result, long known to analysts, is that the prime zeta function has a
**natural boundary** at $\mathrm{Re}\,s = 0$: a barrier through which it simply
cannot be analytically continued, no matter how clever you are. There is no
$P(-1)$ on the far side, because there is no far side. The integers' series leads
to a function defined everywhere; the primes' series leads to a function trapped
inside a half-plane.

So the famous $-\tfrac{1}{12}$ is a statement about the *completed*, additive
object — the full Riemann zeta function. It is never a statement about the prime
series. The "sum of all primes," approached this way, is not merely hard to
compute: it is mathematically out of reach.

## Primes that huddle together

There is a final twist that connects this circle of ideas to the frontier of
modern number theory. One might hope that some special *structure* in the primes
could rescue the sum — perhaps if the primes clustered tightly enough, their
series would behave better.

The deepest recent result about prime clustering is the **bounded gaps theorem**
of Zhang, Maynard, and Tao (2013–2014): there are infinitely many pairs of primes
that differ by at most a fixed constant. Maynard and Tao sharpened the constant to
$246$, meaning infinitely often two primes sit within $246$ of each other, no
matter how far out you go among the giants. In the language of consecutive prime
gaps $g_n = p_{n+1} - p_n$, this says

$$\liminf_{n \to \infty} g_n \le 246.$$

We prove, as a cross-domain corollary, that this spectacular clustering changes
*nothing* about our story:

> **Bounded gaps do not regularize the prime sum.** Even granting the bounded-gaps
> hypothesis — infinitely many primes within $246$ of a neighbor — the prime zeta
> series still diverges at $s = -1$. The abscissa of convergence stays pinned at
> $1$.

The reason is conceptual. The abscissa of convergence is a *density* invariant.
It depends on the overall thinning of the primes (there are about $n/\log n$
primes up to $n$), not on whether some of them occasionally bunch up. Local
clustering is invisible to the threshold. You cannot regularize your way to a sum
of all primes by appealing to twin-prime-style structure.

## What we actually proved, and what remains open

Stripped to its essentials, the rigorous core of this work is a single sharp
dichotomy:

- The bare series of the **integers** and of the **primes** share the same wall:
  both converge exactly when $s > 1$, and both diverge at $s = -1$.
- The **integers** escape through analytic continuation to give
  $\zeta(-1) = -\tfrac{1}{12}$.
- The **primes** cannot escape: their function is born inside a half-plane with a
  natural boundary it can never cross.
- Even extreme prime clustering (bounded gaps) leaves this verdict untouched.

What remains is genuinely open and inviting. One can conjecture that $P(s)$
*does* continue holomorphically into the critical strip $0 < \mathrm{Re}\,s \le 1$
via the Möbius-inverted formula
$P(s) = \sum_{n \ge 1} \tfrac{\mu(n)}{n} \log \zeta(ns)$, blowing up to $+\infty$
as $s \to 1^+$. One can conjecture that the line $\mathrm{Re}\,s = 0$ is a true
natural boundary, with singularities of $\log\zeta(ns)$ accumulating densely. And
one can conjecture that, among all reasonable summation methods, the
zeta-regularized value at $s = -1$ is the *only* consistent value for the
integers — while *no* consistent finite value can ever be assigned to the primes.

The "sum of all primes" turns out to be the perfect cautionary tale. Two infinite
sums can look identical — same terms shrinking at the same rate, same wall of
convergence — and still have utterly different fates. One leaves a finite
fingerprint; the other vanishes behind a barrier. The difference is not in how
fast the numbers grow, but in the hidden multiplicative architecture of the
primes themselves. The atoms of arithmetic guard their total jealously, and the
mathematics tells us exactly why.
