# The Ghost in the Lattice: How a Number from the Eighth Dimension Hides Inside Divisor Sums

## A perfect packing, and the arithmetic it leaves behind

In eight dimensions there lives a crystal of almost unreasonable beauty. It is called the $E_8$ lattice, and it is the densest way to pack identical spheres in eight-dimensional space — a fact only settled, after more than a century of effort, in the last decade. But long before anyone could prove it was the champion packer, mathematicians already knew that $E_8$ was special for a very different reason: the way it counts its own points is dictated, exactly and without slack, by the humblest objects in number theory — the divisors of an integer.

This article is about that dictation, and about a subtle arithmetic echo it produces when you look at $E_8$ paired with itself. The echo is a congruence — a statement that two apparently different sequences of numbers agree "on the nose" modulo a fixed number. That fixed number turns out to be $120$, and, remarkably, $120$ is exactly the right size: not one unit larger will do.

## Counting points in a crystal

A *lattice* is a perfectly regular grid of points in space, like the corners of a stack of identical boxes, though the boxes need not be cubes. Given a lattice $L$, one of the most natural questions you can ask is: how many lattice points sit at each distance from the origin? Group the points by their *squared length* (this keeps everything an integer) and you get a sequence of counts. Packaged together as coefficients of a power series, these counts form the lattice's **theta series**:
$$\theta_L(q) = \sum_{v \in L} q^{\langle v, v\rangle} = \sum_{m \ge 0} N(m)\, q^{m},$$
where $N(m)$ is the number of lattice vectors of squared length $m$.

The lattice $E_8$ is *even* (every vector has even squared length), *unimodular* (it has covolume $1$ and equals its own dual), and has rank $8$. These three adjectives are extraordinarily restrictive. In fact, up to rotation, $E_8$ is the **only** even unimodular lattice in dimension $8$. And that uniqueness has a spectacular payoff.

## When geometry is forced to equal arithmetic

There is a parallel world to lattices: the world of **modular forms**. These are functions on the upper half-plane with a staggering degree of symmetry, and they organize themselves into finite-dimensional vector spaces graded by an integer called the *weight*. The theta series of a rank-$8$ even unimodular lattice is a modular form of weight $4$. But the space of such forms is one-dimensional. There is essentially only one candidate, the **weight-$4$ Eisenstein series**
$$E_4(q) = 1 + 240 \sum_{n \ge 1} \sigma_3(n)\, q^{n}, \qquad \sigma_3(n) = \sum_{d \mid n} d^3,$$
where the sum $\sigma_3(n)$ runs over the positive divisors $d$ of $n$, each cubed. Since $\theta_{E_8}$ and $E_4$ live in a one-dimensional space and both start with the constant term $1$, they must be *equal*:
$$\theta_{E_8} = E_4.$$
Comparing coefficients gives a clean, astonishing formula. If we write $r(n)$ for the number of $E_8$ vectors of squared length $2n$, then
$$r(n) = 240\,\sigma_3(n) \qquad \text{for every } n \ge 1.$$
The number of ways the crystal reaches a given shell is $240$ times a sum of cubes of divisors. Geometry has been *forced* to equal arithmetic. This is the foundational case of the classical **Siegel–Weil formula**, which in general equates an average of lattice theta series (over a genus) with an Eisenstein series.

The number $240$ is not a coincidence, either: it is the number of *roots* of $E_8$ — the $240$ shortest nonzero vectors, sitting at squared length $2$ — since $r(1) = 240\,\sigma_3(1) = 240$.

## Squaring the crystal

Now play the game one dimension up. Stack two copies of $E_8$ side by side to form the rank-$16$ lattice $E_8 \oplus E_8$. Its theta series is just the product $\theta_{E_8}^2 = E_4^2$, and $E_4^2$ is the weight-$8$ Eisenstein series, whose coefficients involve the *seventh*-power divisor sum
$$\sigma_7(n) = \sum_{d \mid n} d^7.$$
Multiplying the two Eisenstein series and comparing coefficients yields the classical **convolution identity**
$$\sigma_7(n) = \sigma_3(n) + 120 \sum_{i=1}^{n-1} \sigma_3(i)\,\sigma_3(n-i).$$
This is a genuinely surprising relation between sums of cubes and sums of seventh powers, tied together by a self-convolution and the mysterious constant $120$.

Stare at that formula. The seventh-power divisor sum $\sigma_7(n)$ equals the cube divisor sum $\sigma_3(n)$ **plus** a correction term — and the correction term is $120$ times a whole number. So the correction is *invisible* if we only look modulo $120$. That is the ghost this article is about.

## The congruence, and why $120$ is exactly right

Here is the clean arithmetic fact hiding inside the geometry:

> **The $E_4^2 = E_8$ Congruence.** For every positive integer $n$,
> $$\sigma_7(n) \equiv \sigma_3(n) \pmod{120}.$$

In words: the seventh-power divisor sums and the cube divisor sums — the coefficient systems of the weight-$8$ and weight-$4$ Eisenstein series — are indistinguishable modulo $120$. And the modulus is **sharp**: the congruence *fails* modulo $240$. At $n = 2$ we have $\sigma_7(2) = 1 + 128 = 129$ and $\sigma_3(2) = 1 + 8 = 9$, so the difference is exactly
$$\sigma_7(2) - \sigma_3(2) = 129 - 9 = 120,$$
which is divisible by $120$ but not by $240$. So $120$ is the precise arithmetic weight of the $E_4^2 = E_8$ correction term — the exact size of the ghost.

## Why the congruence is true: a tale of three primes

Everything follows from a single pointwise fact about *individual* divisors, before we ever sum them up:
$$d^7 \equiv d^3 \pmod{120} \qquad \text{for every integer } d.$$
If each divisor $d$ satisfies $d^7 \equiv d^3$, then adding these up over all divisors of $n$ immediately gives $\sigma_7(n) \equiv \sigma_3(n)$. So the whole theorem reduces to this one power congruence. And that congruence, in turn, factors along the prime-power pieces of $120 = 8 \times 3 \times 5$, three building blocks that share no common factor.

- **Modulo $8$.** If $d$ is even, then $d^3$ is already divisible by $8$, and so is $d^7$; both are $0$. If $d$ is odd, a classical fact says $d^2 \equiv 1 \pmod 8$, hence $d^4 = (d^2)^2 \equiv 1$, and therefore $d^7 = d^3 \cdot d^4 \equiv d^3$. Either way, $d^7 \equiv d^3 \pmod 8$.
- **Modulo $3$.** Fermat's little theorem gives $d^2 \equiv 1 \pmod 3$ whenever $3 \nmid d$, so $d^4 \equiv 1$ and $d^7 = d^3 \cdot d^4 \equiv d^3$. If $3 \mid d$, both sides vanish. Either way, $d^7 \equiv d^3 \pmod 3$.
- **Modulo $5$.** Fermat's little theorem gives $d^4 \equiv 1 \pmod 5$ whenever $5 \nmid d$, so again $d^7 = d^3 \cdot d^4 \equiv d^3$; and if $5 \mid d$ both sides vanish. Either way, $d^7 \equiv d^3 \pmod 5$.

Because $8$, $3$, and $5$ are pairwise coprime and multiply to $120$, the **Chinese Remainder Theorem** glues these three local statements into the single global one: $d^7 \equiv d^3 \pmod{120}$. Summing over the divisors of $n$ finishes the proof of the congruence.

The same reasoning, run in reverse, explains the sharpness. The correction term carries the *literal* factor $120$, so doubling the modulus to $240$ asks the correction to be divisible by $240$ — and at $n = 2$ the correction is exactly $120$, which is not. The congruence is as strong as it can possibly be.

## From divisor sums back to the crystal

The arithmetic statement can be carried straight back into the language of lattices. Recall $r(n) = 240\,\sigma_3(n)$ counts $E_8$ vectors of squared length $2n$. Define its weight-$8$ companion $s(n) = 240\,\sigma_7(n)$, the coefficient system attached to $E_8$'s square. Multiplying the divisor-sum congruence by the normalizing factor $240$ shows that these two lattice-flavored counts differ by a multiple of
$$240 \times 120 = 28800.$$
That is, $s(n) \equiv r(n) \pmod{28800}$ for every $n$. The vector count of the rank-$16$ genus and the (scaled) vector count of $E_8$ agree modulo $28800$ — a geometric congruence that falls out of nothing more than elementary residues of powers.

## Why any of this matters

The philosophy on display is one of the most productive in modern mathematics: **rigid geometric objects secretly obey arithmetic laws**. Here a sphere-packing champion in dimension eight is shackled to the divisors of the integers, and the shackling is exact. The Siegel–Weil formula is the grand version of this principle; the little congruence $\sigma_7 \equiv \sigma_3 \pmod{120}$ is a fingerprint it leaves behind, small enough to verify by hand yet pointing directly at the deep structure above it.

There is also a lesson about *constants*. The number $120$ is not arbitrary. It is dictated by the denominators of the Bernoulli numbers that normalize the Eisenstein series, and its factorization $8 \times 3 \times 5$ is precisely why the proof splits into three tidy pieces. Change the weight and the modulus changes with it, in a pattern governed by those same Bernoulli denominators. What looks like a numerical curiosity is a window onto an entire hierarchy of congruences, one for each even weight, each with its own sharp modulus.

The next time you meet the number $240$ — the kissing number of the $E_8$ lattice, the count of its roots — remember that it is the visible face of a much larger arithmetic machine. And the number $120$, its half, is the exact measure of the shadow that machine casts when the crystal is squared.
