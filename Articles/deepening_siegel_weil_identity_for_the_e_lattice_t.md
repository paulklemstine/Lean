# The Perfect Crystal and the Hidden Arithmetic of Cubes

There is a lattice in eight-dimensional space so symmetric, so improbably
efficient, that mathematicians have spent more than a century marveling at it.
It is called $E_8$. Slice it the right way and it gives the densest possible
packing of spheres in eight dimensions. It is the shape that governs certain
exotic phase transitions in physics, the skeleton of one of the largest
exceptional structures in all of algebra, and — the subject of this article —
a machine for turning geometry into pure number theory.

Our story is about a single, startling sentence:

> The number of ways to reach a point at squared distance $2n$ from the origin
> in the $E_8$ lattice is exactly $240 \cdot \sigma_3(n)$,

where $\sigma_3(n)$ is the sum of the *cubes* of the divisors of $n$. Counting
lattice points — a geometric act — turns out to be governed by the divisors of
an integer and their cubes. That two such distant worlds should coincide is the
kind of coincidence that, in mathematics, is never a coincidence at all.

## What is a lattice, and what makes $E_8$ special?

A lattice is a perfectly regular grid of points. The simplest example is the
integer lattice $\mathbb{Z}^2$ in the plane: all points with whole-number
coordinates. You can walk from any point to any other by taking integer steps
along the axes, and the whole pattern looks identical from every one of its
points.

Higher-dimensional lattices can be far richer. The $E_8$ lattice lives in
$\mathbb{R}^8$ and can be described concretely: take all points whose eight
coordinates are *either all integers or all half-integers* (like
$\tfrac12, \tfrac12, \dots$), subject to the single rule that the coordinates
sum to an even integer. This tidy description hides staggering structure. The
shortest nonzero vectors all have squared length $2$, and there are exactly
$240$ of them — the famous "roots" of $E_8$. Those $240$ directions, arranged
with breathtaking symmetry, are the seeds from which the entire lattice grows.

A natural question to ask of any lattice is its *counting function*: for each
value $N$, how many lattice points sit at squared distance exactly $N$ from the
origin? For $E_8$ the answer is zero whenever $N$ is odd, and for even
$N = 2n$ it is a specific positive integer we will call $r(n)$. The first few
values are
$$
r(1) = 240,\quad r(2) = 2160,\quad r(3) = 6720,\quad r(4) = 17520,\ \dots
$$
Where do these numbers come from?

## Divisors, and the sum of their cubes

Take any positive integer $n$ and list its divisors — the numbers that divide
it evenly. Now cube each divisor and add the results. That sum is
$$
\sigma_3(n) \;=\; \sum_{d \mid n} d^3.
$$
For example, $6$ has divisors $1, 2, 3, 6$, so
$\sigma_3(6) = 1 + 8 + 27 + 216 = 252$. Multiply by $240$ and you get $60480$,
which is precisely the number of $E_8$ points at squared distance $12$. The
correspondence is exact, and it holds for *every* $n$:
$$
r(n) \;=\; 240 \cdot \sigma_3(n).
$$

Why cubes? Why $240$? The answer comes from a bridge between two great themes
of mathematics: the geometry of lattices and the theory of *modular forms* —
functions with an almost magical degree of symmetry. When you encode the
counting numbers $r(n)$ into a single generating function (the lattice's "theta
series"), the result is so symmetric that it is forced to equal one specific,
canonical object: the weight-$4$ *Eisenstein series* $E_4$. And the
coefficients of $E_4$ are, famously, $240 \cdot \sigma_3(n)$. The rigidity of
the symmetry leaves no room for anything else. This is the simplest instance of
a profound principle, the *Siegel–Weil identity*, which equates an average over
geometric objects with an explicit analytic formula.

## The arithmetic backbone

At the heart of why $E_4$ — and hence $240\,\sigma_3$ — is so special lies an
identity that looks, at first glance, like an accident of arithmetic. For any
two positive integers $m$ and $n$,
$$
\sigma_3(m)\,\sigma_3(n) \;=\; \sum_{d \,\mid\, \gcd(m,n)} d^3\,\sigma_3\!\left(\frac{mn}{d^2}\right).
$$
Read it slowly. On the left, two divisor-cube sums are simply multiplied. On
the right, a single sum runs over the common divisors of $m$ and $n$, weighting
a *reshuffled* argument $mn/d^2$ by $d^3$. The two sides are always equal.

When $m$ and $n$ share no common factor, the sum on the right has just one
term ($d = 1$), and the identity reduces to the familiar statement that
$\sigma_3$ is *multiplicative*: $\sigma_3(mn) = \sigma_3(m)\,\sigma_3(n)$. But
when $m$ and $n$ share factors, the extra terms encode a much deeper rigidity.
This convolution law is the fingerprint of a *Hecke eigenform* — a function so
structurally constrained that its values at every integer are determined by its
values at the primes. It is exactly this rigidity that pins the $E_8$ theta
series to $E_4$ and forces the clean formula $r(n) = 240\,\sigma_3(n)$.

## Going deeper: cubes were never the point

Here is where the plot thickens. The number $3$ — the exponent in "sum of
cubes" — seemed woven into the geometry of eight-dimensional space. But it is
not special at all. Replace the cube by *any* power $s$, define
$$
\sigma_s(n) \;=\; \sum_{d \mid n} d^s,
$$
and the *same* convolution law holds verbatim:
$$
\sigma_s(m)\,\sigma_s(n) \;=\; \sum_{d \,\mid\, \gcd(m,n)} d^s\,\sigma_s\!\left(\frac{mn}{d^2}\right),
\qquad\text{for every exponent } s.
$$
The $E_8$ identity is simply the case $s = 3$. What looked like a fact about a
particular crystal in a particular dimension is really a universal law about
divisor sums — a whole infinite family of Hecke eigenform identities, one for
each weight, with the geometry of $E_8$ occupying a single distinguished slot.

The proof of this universal law is a beautiful piece of reduction. Everything
funnels down to a single, self-contained fact about geometric progressions. If
you multiply two finite geometric sums, you can always regroup the product:
$$
\Bigl(\sum_{i=0}^{a} q^{\,i}\Bigr)\Bigl(\sum_{j=0}^{b} q^{\,j}\Bigr)
   \;=\; \sum_{i=0}^{\min(a,b)} q^{\,i}\,\Bigl(\sum_{\ell=0}^{a+b-2i} q^{\,\ell}\Bigr).
$$
Set $q = p^s$ for a prime $p$. Because $\sigma_s$ evaluated at a prime power
$p^r$ is itself a geometric sum, $\sigma_s(p^r) = 1 + p^s + p^{2s} + \cdots +
p^{rs}$, this innocent regrouping *is* the convolution law for prime powers.
Multiplicativity then bootstraps it to all integers: any $m$ and $n$ factor
into prime powers, the identity holds on each prime independently, and the
pieces reassemble. The whole edifice rests on the geometry of a geometric
series.

## The Hecke operator, made completely explicit

The convolution identity has a striking consequence that holds for *every*
integer $n$, not merely for prime powers. For any prime $p$,
$$
\sigma_s(p)\,\sigma_s(n) \;=\; \sigma_s(pn) \;+\; [\,p \mid n\,]\cdot p^s\,\sigma_s(n/p),
$$
where the bracket $[\,p\mid n\,]$ equals $1$ if $p$ divides $n$ and $0$
otherwise. This is the *Hecke operator eigenvalue relation* in its most concrete
form. It says that $\sigma_s$ is a simultaneous eigenfunction of every
Hecke operator $T_p$, with eigenvalue $\sigma_s(p) = 1 + p^s$. Multiplying by
$240$ transports it directly to the $E_8$ counts: the representation numbers
themselves obey
$$
r(p)\,r(n) \;=\; 240\,\Bigl(r(pn) \;+\; [\,p\mid n\,]\cdot p^3\, r(n/p)\Bigr).
$$
The lattice's point-counts satisfy a recurrence dictated entirely by the
primes.

There is also a humble but useful consequence. Among the divisors of $n$ is $n$
itself, contributing $n^s$ to the sum, so trivially
$$
n^s \le \sigma_s(n).
$$
For the $E_8$ counts this becomes a clean geometric lower bound: the number of
lattice vectors at squared distance $2n$ is at least $240\,n^3$. The crystal is
guaranteed to be *at least* cubically crowded.

## Why any of this matters

The number $240$ is not an accident, and neither is the cube. They are shadows
cast by symmetry so complete that it dictates arithmetic. The same
$E_8$ lattice that governs sphere packing and appears in the mathematics of
certain two-dimensional critical phenomena is, viewed through the lens of its
theta series, nothing but a beautiful accounting of divisors and their cubes.

And the deeper lesson is that the accounting was never about cubes, or about
eight dimensions, or about any single crystal. It is a universal law of
divisor-power sums — an infinite ladder of identities in which $E_8$ occupies
one rung. Climb up or down the ladder by changing a single exponent, and the
music stays the same. That is the quiet thrill of this corner of mathematics:
you reach for a fact about one perfect object and find, in your hand, a truth
about all the integers at once.
