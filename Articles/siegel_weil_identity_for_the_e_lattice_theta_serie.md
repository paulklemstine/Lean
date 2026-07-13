# Counting in Eight Dimensions: The Secret Arithmetic of a Perfect Lattice

## A shape that shouldn't exist

Imagine packing oranges. In the fruit aisle we stack them the way greengrocers always have, and it turns out that stacking is essentially the best you can do in three dimensions. Now raise the stakes. Go to eight dimensions — a space no one can picture — and ask the same question: what is the densest way to arrange identical spheres so none overlap?

The answer is a single, breathtakingly symmetric object called the **$E_8$ lattice**. It is a grid of points in eight-dimensional space so tightly and so evenly woven that every point looks exactly like every other, and every direction looks like every other. It is the eight-dimensional cousin of the honeycomb, and it is optimal: no arrangement of spheres in eight dimensions packs them more densely.

But $E_8$ hides something even more surprising than its geometry. If you simply *count* how many grid points sit at each distance from the origin, the counts are not random. They are governed by an exact, elegant arithmetic formula — one that ties the geometry of the densest packing in eight dimensions to the humble act of listing the divisors of a whole number. This article is about that formula, and about the hidden clockwork that makes it tick.

## The counting problem

Every point of the $E_8$ lattice can be reached from the origin by an arrow, and each arrow has a length. Because of the way $E_8$ is built, the *squared* length of every arrow is an even whole number: $0, 2, 4, 6, 8, \dots$ There are no half-measures and no odd values. This is what mathematicians mean when they call $E_8$ **even**.

So it makes sense to ask a purely combinatorial question. For each positive integer $n$, let

$$r(n) = \text{the number of lattice points whose squared length is } 2n.$$

The first few values, found by direct enumeration, are

$$r(1) = 240,\quad r(2) = 2160,\quad r(3) = 6720,\quad r(4) = 17520,\quad r(5) = 30240.$$

The number $240$ is famous in its own right: it is the number of *nearest neighbors* of any point in $E_8$, the eight-dimensional analogue of the six neighbors surrounding a point in a flat honeycomb. But what about the rest of the sequence? Is there a pattern?

## The divisor connection

There is, and it is astonishing. Define, for each positive integer $n$, the **sum of cubed divisors**:

$$\sigma_3(n) = \sum_{d \mid n} d^3,$$

that is, add up the cubes of all the whole numbers that divide $n$ evenly. For example, the divisors of $6$ are $1, 2, 3, 6$, so $\sigma_3(6) = 1 + 8 + 27 + 216 = 252$.

The central fact — a special, foundational case of a deep result known as the **Siegel–Weil formula** — is:

$$\boxed{\,r(n) = 240\,\sigma_3(n)\,}$$

Every count of lattice points, in every shell, is exactly $240$ times a sum of cubed divisors. Let us check: $\sigma_3(1) = 1$, so $r(1) = 240$. The divisors of $2$ are $1$ and $2$, giving $\sigma_3(2) = 1 + 8 = 9$ and $r(2) = 2160$. For $n = 4$ the divisors are $1, 2, 4$, so $\sigma_3(4) = 1 + 8 + 64 = 73$ and $r(4) = 17520$. Every value lands perfectly.

This is the miracle at the heart of the story: a question about *geometry* — how many points sit on each sphere around the origin of the densest packing in eight dimensions — is answered by a question about *number theory* — the divisors of an integer. The bridge between the two is the theory of **modular forms**, symmetric functions so rigid that knowing a handful of their values pins them down completely. The lattice's counting function and the divisor sum are, from that lofty viewpoint, literally the same object: the weight-$4$ Eisenstein series. Because there is only one such object, the two sequences must agree.

## Beyond the formula: the fingerprints of a lattice

Knowing that $r(n) = 240\,\sigma_3(n)$ is only the beginning. The real question a working mathematician asks is: *what kind of sequence is this?* Does it have structure beyond the formula? It turns out $240\,\sigma_3$ carries three independent "fingerprints," each revealing that these counts are genuinely arithmetic and not some accident of bookkeeping. We describe all three for the general divisor-power sum

$$\sigma_s(n) = \sum_{d\mid n} d^s,$$

of which $\sigma_3$ is the case relevant to $E_8$.

### Fingerprint 1: a division-free closed form

To understand a multiplicative sequence, look at what it does on prime powers, because those are its atoms. On a prime power $p^r$, the divisors are simply $1, p, p^2, \dots, p^r$, so

$$\sigma_s(p^r) = 1 + p^s + p^{2s} + \cdots + p^{rs},$$

a plain geometric series. Geometric series famously telescope when multiplied by one less than their ratio, giving the clean identity

$$\sigma_s(p^r)\,(p^s - 1) = p^{s(r+1)} - 1.$$

This tidy formula is not just algebraic housekeeping. It is the arithmetic shadow of the way the sequence's generating function factors: it splits into two independent pieces, one for the "trivial" symmetry and one twisted by the exponent $s$. In the language of $L$-functions, this is the statement that the local factor at each prime is $(1 - p^{-w})^{-1}(1 - p^{s-w})^{-1}$ — the signature of an Eisenstein series.

### Fingerprint 2: inverting the count to recover pure powers

Here is a game. The divisor sum builds $\sigma_s(n)$ by *adding up* contributions from all divisors of $n$. Can we run the machine backward — recover the raw power $n^s$ from the divisor sums alone?

Yes, using the **Möbius function** $\mu$, the master tool for inverting divisor sums. The Möbius function assigns to each integer a sign or a zero according to its prime factorization, and it is designed precisely to undo summation over divisors. The result is the **Möbius inversion**:

$$n^s = \sum_{d \cdot e = n} \mu(d)\,\sigma_s(e),$$

where the sum runs over all ways of factoring $n$ as an ordered product $d \cdot e$. Applied to the lattice counts, this says

$$\sum_{d\cdot e = n} \mu(d)\,r(e) = 240\,n^3.$$

In other words, a suitable signed combination of the raw geometric counts $r(e)$ reconstructs the pure cube $240\,n^3$ on the nose. This is the most genuinely deep of the three fingerprints: it relies on the fine structure of how integers factor, not just on algebra. It is the number-theoretic incarnation of *dividing* the lattice's generating function by the simplest possible symmetry.

### Fingerprint 3: the eigenform defect — almost, but not quite, a character

A sequence is called **completely multiplicative** if it splits perfectly across every product: $f(ab) = f(a)f(b)$ for *all* $a$ and $b$. Such sequences are the "characters," the most rigidly structured functions in number theory. Is $\sigma_s$ one of them?

Almost — but tantalizingly, no. On prime squares there is a correction:

$$\sigma_s(p^2) + p^s = \sigma_s(p)^2.$$

If $\sigma_s$ were completely multiplicative we would have $\sigma_s(p^2) = \sigma_s(p)^2$ exactly. Instead there is a leftover term $p^s$, always positive, so

$$\sigma_s(p^2) < \sigma_s(p)^2.$$

That stubborn gap of $p^s$ is not a blemish; it is the **signature of an eigenform**. In the theory of modular forms, the counting function of $E_8$ is an eigenvector of a family of averaging operators (the Hecke operators), and the relation above is exactly the eigenvalue law $T_{p^2} = T_p^2 - p^{k-1}$ for weight $k = s+1$, read off on the level of coefficients. The defect $p^s$ is what makes the $E_8$ counts *genuinely arithmetic* — richly structured, but not trivially factorizable. Transported to the lattice, it reads

$$240\,r(p^2) + 240^2\,p^3 = r(p)^2,$$

so the same defect governs the geometry of the packing.

## Why it matters

The story of $E_8$ is one of the great unifications in mathematics. A single object sits at the crossroads of sphere packing, the symmetries of physics (it appears in string theory and in the classification of continuous symmetry groups), and pure number theory. The counting formula $r(n) = 240\,\sigma_3(n)$ is the thread that ties the geometric strand to the arithmetic one.

What the three fingerprints add is *texture*. They show that the sequence $240\,\sigma_3(n)$ is not merely a formula to be memorized but a living arithmetic object: it has a closed form on prime powers, it can be inverted to recover pure cubes, and it carries a precisely measurable defect that certifies it as an eigenform rather than a mere character. Each fingerprint is an independent confirmation that the geometry of eight-dimensional space and the arithmetic of divisors are, at bottom, the same music played on two instruments.

The densest packing in eight dimensions counts its own points by cubing divisors. That such a sentence is *true* — and provably so — is one of the quiet wonders of modern mathematics.
