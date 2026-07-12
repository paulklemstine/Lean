# When Light Ties Itself in Knots — and Number Theory Reads the Knot

## A beam of light that spirals into a knot

Shine an ordinary laser at a wall and you get a bright dot. But light can be
sculpted. With the right holograms and phase plates, physicists can twist a beam
so that its wavefront corkscrews around the axis of propagation, like the threads
of a screw. Such a beam carries **orbital angular momentum** (OAM): it doesn't
just travel forward, it *swirls*.

Push the sculpting further and something remarkable happens. The places where the
light's phase is undefined — the dark filaments threading through the bright
regions, called **phase singularities** or optical vortices — can be arranged so
that they don't just run in a straight line. They can loop, link, and even tie
themselves into genuine mathematical knots. This is **knotted light**: a laser
beam whose zero-intensity core traces out a trefoil, a figure-eight, or a more
elaborate knot as the beam propagates.

Once a knot appears, an old and beautiful branch of mathematics wakes up. Every
knot $K$ has a fingerprint called its **Alexander polynomial** $\Delta_K$, a
polynomial in a variable $X$ that stays the same no matter how you wiggle the knot
without cutting it. And here is the striking physical conjecture at the heart of
this story: the *quantized OAM values* a knotted-light beam can carry are governed
by the **roots** of the Alexander polynomial of the knot its darkness traces.

If that is true, then a purely optical question — *which swirl-values can this
knotted beam carry?* — has a purely algebraic answer. This article is about
exactly how clean that answer turns out to be for an infinite family of knots.

## The simplest interesting knots: the $T(2,n)$ family

Among all knots, the friendliest live on the surface of a doughnut. A **torus
knot** $T(2,n)$ is what you get by winding a loop around a torus, going twice one
way and $n$ times the other. When $n = 3$ you get the famous **trefoil**; when
$n = 5$ you get the **cinquefoil** (Solomon's seal knot); and in general, for each
odd $n$, you get a distinct knot with $n$ crossings.

For this family the Alexander polynomial takes a wonderfully simple shape — an
**alternating geometric sum**:
$$
A_n(X) \;=\; 1 - X + X^2 - X^3 + \cdots + X^{\,n-1}
\;=\; \sum_{k=0}^{n-1} (-1)^k X^k .
$$
For the trefoil ($n=3$) this is $A_3(X) = 1 - X + X^2$; for the cinquefoil
($n=5$) it is $A_5(X) = 1 - X + X^2 - X^3 + X^4$.

There is one algebraic fact about this sum that unlocks everything. Multiply it by
$X+1$ and almost everything cancels telescopically, leaving
$$
A_n(X)\,(X+1) \;=\; X^n + 1 .
$$
This tiny identity is the seed from which the whole structure grows.

## Roots on a circle: the geometry of the OAM spectrum

If the OAM values live at the roots of $A_n$, where are those roots? From
$A_n(X)(X+1) = X^n + 1$ we see that every root of $A_n$ is a solution of
$X^n = -1$ **other than** $X = -1$ itself. The solutions of $X^n = -1$ are
perfectly evenly spaced points on the unit circle in the complex plane — they are
$2n$-th roots of unity that are not $n$-th roots of unity. So the OAM spectrum of
a $T(2,n)$ beam is a constellation of points sitting *exactly* on the unit circle,
at angles that are odd multiples of $\pi/n$.

This already tells us the total number of channels. The polynomial $A_n$ has
degree $n-1$, so a $T(2,n)$ beam carries exactly $n-1$ OAM channels. Nothing
mysterious remains about *how many* there are.

The deep question is about **structure**. Are these $n-1$ points just an
undifferentiated cloud, or do they organize themselves into meaningful groups?

## The hidden layering: cyclotomic polynomials

To see the structure we need the number theorist's favorite building blocks, the
**cyclotomic polynomials**. The $m$-th cyclotomic polynomial $\Phi_m(X)$ is the
unique polynomial whose roots are exactly the **primitive** $m$-th roots of unity
— the points on the unit circle that spin all the way around to $1$ after exactly
$m$ steps and not before. These are the atoms of the roots of unity: every
equation $X^m = 1$ factors into cyclotomic pieces,
$$
X^m - 1 \;=\; \prod_{d \,\mid\, m} \Phi_d(X),
$$
one factor for each divisor $d$ of $m$. Each cyclotomic polynomial is
*irreducible* over the rationals; it cannot be broken into smaller polynomials
with whole-number coefficients. It is a single indivisible orbit under the
symmetries (the Galois group) of the roots of unity.

The earlier chapter of this story showed that when $n = p$ is an **odd prime**,
the Alexander polynomial is a *single* cyclotomic polynomial:
$$
A_p(X) \;=\; \Phi_{2p}(X).
$$
The trefoil gives $A_3 = \Phi_6 = X^2 - X + 1$; the cinquefoil gives
$A_5 = \Phi_{10} = X^4 - X^3 + X^2 - X + 1$. For a prime torus knot the OAM
spectrum is one clean, irreducible orbit of primitive $2p$-th roots of unity.

But primes are special. What happens for composite $n$ — say $n = 9$, or
$n = 15$? Does the neat cyclotomic picture survive?

## The main result: the spectrum stratifies by divisors

It does — and it does so in the most structured way imaginable. The central
theorem of this work removes the primality assumption entirely and reveals the
general law.

> **Divisor Factorization Theorem.** For every odd $n \ge 1$, the $T(2,n)$
> Alexander polynomial factors as the product of cyclotomic polynomials indexed by
> the *nontrivial* divisors of $n$:
> $$
> A_n(X) \;=\; \prod_{\substack{d \mid n \\ d > 1}} \Phi_{2d}(X).
> $$

In words: the OAM spectrum of a $T(2,n)$ knotted-light beam is not one cloud but a
**disjoint union of layers** — one layer for each divisor $d > 1$ of $n$,
consisting precisely of the primitive $2d$-th roots of unity. The divisor lattice
of the number $n$ is written directly into the geometry of the beam.

The engine behind this is a clean **master identity** proved along the way. For
odd $n$, the divisors of $2n$ split perfectly into the odd divisors (which are
exactly the divisors of $n$) and their doubles $2d$; these two sets never overlap
because $n$ is odd. Running the factorization $X^{2n}-1 = \prod_{e \mid 2n}\Phi_e$
through this split and cancelling $X^n - 1$ yields
$$
\prod_{d \,\mid\, n} \Phi_{2d}(X) \;=\; X^n + 1 \qquad (n \text{ odd}).
$$
Pulling out the single $d=1$ term, which is $\Phi_2 = X+1$, and comparing with
$A_n(X)(X+1) = X^n+1$ gives the Divisor Factorization Theorem instantly.

## Reading the number theory off the light

Once you know the spectrum is layered by divisors, a cascade of consequences
follows, each with a crisp physical meaning.

**Counting the layers.** The number of primitive-root layers equals the number of
nontrivial divisors of $n$ — that is, $\tau(n) - 1$, where $\tau(n)$ counts all
divisors. A beam whose knot is $T(2,15)$ has divisors $1, 3, 5, 15$, hence
$4 - 1 = 3$ layers: the primitive $6$-th, $10$-th, and $30$-th roots of unity,
neatly interleaved on the circle.

**A primality detector made of light.** A $T(2,n)$ beam (with $n \ge 2$) has
**exactly one** OAM layer if and only if $n$ is **prime**. Composite $n$ always
shatters the spectrum into several divisor-indexed pieces. In principle, one could
determine whether a number is prime by inspecting whether the corresponding
knotted beam's spectrum is a single irreducible orbit — number theory, read off an
optics bench.

**Nested towers for prime powers.** When $n = p^k$ is a power of an odd prime, the
divisors form a chain $1 \mid p \mid p^2 \mid \cdots \mid p^k$, so the spectrum
stratifies into $k$ **nested** layers,
$$
A_{p^k}(X) \;=\; \Phi_{2p}(X)\,\Phi_{2p^2}(X)\cdots\Phi_{2p^k}(X).
$$
Each step out to a higher power adds a single fresh outer ring of roots, and the
angular rescaling $\zeta \mapsto \zeta^p$ carries each ring onto the one inside it.
The beam is, in a precise sense, **self-similar** under a $p$-fold zoom.

**The channel count is conserved.** Because degree adds under multiplication, the
total number of OAM channels — the degree $n-1$ of $A_n$ — must equal the sum of
the layer sizes:
$$
\sum_{\substack{d \mid n \\ d > 1}} \varphi(2d) \;=\; n - 1,
$$
where $\varphi$ is Euler's totient. The layers repackage the $n-1$ channels
without ever losing or duplicating one.

## Why this is beautiful

Three worlds meet on a single circle. **Knot theory** supplies the Alexander
polynomial of a torus knot. **Optics** proposes that its roots are the allowed
swirl-values of a knotted beam. And **number theory** — through cyclotomic
polynomials and the humble arithmetic of divisors — dictates exactly how those
values arrange themselves into irreducible layers.

The punchline is that the arithmetic of a single integer $n$ is *legible in the
light itself*. Factor $n$, and you have named the layers. Ask whether $n$ is
prime, and you are asking whether the beam's darkness carries one Galois orbit or
many. A knot tied in a shaft of light turns out to be a page from a number theory
textbook — and it reads perfectly.
