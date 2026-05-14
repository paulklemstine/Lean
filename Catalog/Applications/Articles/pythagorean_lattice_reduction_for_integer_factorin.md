# The Ancient Triangles That Could Break Modern Encryption

## A 4,000-year-old pattern in right triangles reveals an unexpected bridge to the hardest problem in computer security

---

There is a clay tablet in the British Museum, cracked and weathered, that has puzzled mathematicians for over a century. Known as Plimpton 322, it was pressed into wet clay by a Babylonian scribe around 1800 BCE — roughly the same era as the Code of Hammurabi. On it are columns of numbers. Not inventory counts or tax records, but something far stranger: a systematic list of right triangles whose sides are all whole numbers.

The numbers 3, 4, 5. Then 5, 12, 13. Then 8, 15, 17. The Babylonians had discovered what we now call Pythagorean triples — sets of three integers where the squares of the two shorter sides add up to the square of the longest. Three squared plus four squared equals five squared: 9 + 16 = 25.

These triples have been a source of fascination ever since. Euclid catalogued them. Fermat used them as launchpads for his deepest conjectures. And now, in a development that would have astonished every mathematician in this long chain, researchers have uncovered a precise mathematical connection between these ancient number patterns and the problem that guards nearly every secret on the internet: breaking large numbers into their prime factors.

## The Factoring Problem: A Trillion-Dollar Lock

Every time you type a credit card number into a website, every time a government sends a classified communication, every time a cryptocurrency transaction is verified, the security depends on one mathematical bet: that it is extraordinarily difficult to factor large numbers.

Take the number 15. It factors as 3 × 5 — trivial. Now take a number with 600 digits, the product of two 300-digit primes. In principle, you could find those primes by trying every possibility. In practice, the sun would burn out first. The best classical algorithms for factoring, run on the fastest supercomputers, would take longer than the age of the universe for numbers of this size.

This asymmetry — easy to multiply, seemingly impossible to reverse — is the bedrock of RSA encryption, the most widely deployed public-key cryptosystem in history. If someone found a fundamentally faster way to factor, the consequences would cascade through every layer of digital infrastructure.

So mathematicians and computer scientists have been probing this problem from every conceivable angle for decades. What makes factoring hard? Could there be a hidden geometric structure that, once revealed, would make the problem easy?

## The Berggren Tree: An Infinite Family Portrait

In 1934, a Swedish mathematician named Berggren made a beautiful observation that went largely unnoticed outside specialist circles. He discovered that every Pythagorean triple with no common factors — the "primitive" triples like (3, 4, 5) and (5, 12, 13) but not (6, 8, 10), which is just (3, 4, 5) doubled — can be generated from a single seed using exactly three transformations.

Start with (3, 4, 5). Apply one transformation, and you get (5, 12, 13). Apply another, and you get (21, 20, 29). Apply the third, and you get (15, 8, 17). Now apply the same three transformations to each of these new triples, and you get nine more. Continue indefinitely, and you generate every primitive Pythagorean triple exactly once.

The result is a ternary tree — an infinite family tree where (3, 4, 5) is the ancestor of all primitive Pythagorean triples. Each triple has exactly three children, and no triple appears twice. The whole infinite family is organized with perfect mathematical efficiency.

What makes this tree remarkable is that the three transformations are simple matrix multiplications — the same kind of linear algebra used in computer graphics, quantum mechanics, and machine learning. Each transformation is a 3×3 grid of small integers that, when applied to any Pythagorean triple, produces another one. And every one of these matrices has determinant ±1, meaning the transformation preserves a certain geometric volume — a hallmark of deep structural symmetry.

## The Bridge: From Right Triangles to Secret Codes

The connection between Pythagorean triples and factoring runs through a classical idea in number theory: the method of *congruence of squares*.

Here is the key insight, known since at least the 17th century: if you can find two numbers *x* and *y* such that *x*² and *y*² leave the same remainder when divided by the number *n* you want to factor, but *x* and *y* themselves are not simply equal or opposite modulo *n*, then you can extract a factor. Specifically, the greatest common divisor of (*x* − *y*) and *n* will be a nontrivial factor — not 1 and not *n* itself.

This is the engine inside the quadratic sieve, the number field sieve, and conceptually even Shor's quantum factoring algorithm. Finding these "square collisions" is the hard part; once you have one, extracting the factor is just high-school arithmetic.

Now look at a Pythagorean triple: *a*² + *b*² = *c*². Rearrange: *c*² − *a*² = *b*². In other words, *c*² and *a*² differ by a perfect square. Reduce this equation modulo *n*, and you have exactly the kind of square collision that cracks factoring — provided the collision is nontrivial, meaning *n* doesn't simply divide both (*c* − *a*) and (*c* + *a*).

This observation transforms the factoring problem into a geometric one: can you find a Pythagorean triple whose entries interact with *n* in the right way?

## The Lattice: Geometry Meets Arithmetic

To make this precise, the researchers constructed what they call a *congruence lattice* — a grid-like structure in two-dimensional space whose points encode exactly the square collisions modulo *n*.

Imagine a sheet of graph paper, but instead of the usual square grid, the points are tilted and spaced according to the number you want to factor. Every point on this lattice represents a pair of numbers (*x*, *y*) with the property that *x*² ≡ *y*² modulo *n*. Finding a point on this lattice that isn't trivially at the origin or along an axis is equivalent to factoring *n*.

The lattice has a natural notion of "short vectors" — points close to the origin. Short vectors correspond to small square collisions, which are the most useful for extracting factors. The problem of finding the shortest nonzero vector in a lattice — known as the Shortest Vector Problem, or SVP — is one of the central challenges in computational geometry and the foundation of an entirely separate branch of cryptography called lattice-based cryptography.

So factoring, which guards RSA, reduces to a lattice problem, which is the foundation of post-quantum cryptography. Two pillars of modern security, connected through the geometry of an ancient number pattern.

## What Was Proved — And What Was Disproved

The mathematical results that emerged from this investigation are notable for their precision. Several key theorems were established with complete, machine-checked proofs:

**The Square Collision Theorem**: If *x*² ≡ *y*² (mod *n*) with *n* dividing neither (*x* − *y*) nor (*x* + *y*), then gcd(*x* − *y*, *n*) is a nontrivial factor of *n*. This is the core arithmetic engine, now certified beyond any possibility of error.

**The Congruence Lattice Theorem**: For any composite *n* = *p* × *q* where both *p* and *q* are odd primes (both at least 3), there exists a congruence lattice whose vectors automatically produce square collisions modulo *n*, and any nontrivial such vector yields a factor.

**The Berggren Preservation Theorem**: All three Berggren generators preserve the Pythagorean property — they map every Pythagorean triple to another Pythagorean triple — and they do so with determinant ±1, ensuring the transformation is invertible over the integers.

But the investigation also produced a crucial negative result — a formal counterexample that prevented a seductive but false generalization:

**The n = 6 Counterexample**: For *n* = 6 = 2 × 3, there is no nontrivial square root of 1 modulo 6. The only values *r* with *r*² ≡ 1 (mod 6) are 1 and 5 ≡ −1, both trivial. This means the congruence lattice approach requires both factors to be odd — a necessary condition that had been overlooked in earlier informal descriptions of the method.

This counterexample, far from being a disappointment, sharpened the theory considerably. It drew a precise boundary around the method's applicability: the reduction works for products of two odd coprime factors (which covers the cryptographically relevant case of RSA moduli, since RSA uses two large odd primes), but fails for even composites. The corrected theorem is both more honest and more useful than the over-general version it replaced.

## Why This Matters Beyond Cryptography

The lattice encoding of factoring through Pythagorean arithmetic opens doors in several directions.

First, it connects two seemingly separate worlds of computational hardness. Factoring (the basis of RSA) and shortest-vector problems (the basis of lattice-based cryptography) have been studied largely independently. A concrete lattice that encodes factoring instances shows that these worlds are not separate at all — information about one can, in principle, flow to the other.

Second, the Berggren tree provides a rich combinatorial structure — a perfect ternary tree over the integers — that has barely been exploited algorithmically. Each node is a Pythagorean triple, each edge is an invertible integer matrix, and the whole tree covers every primitive triple exactly once. This is a combinatorial object of remarkable regularity, and its algorithmic potential is largely untapped.

Third, the interplay between linear algebra (lattice structure, matrix multiplication) and nonlinear arithmetic (square congruences, quadratic forms) is exactly the kind of mathematics that emerging computational paradigms — particularly quantum computing — are designed to exploit. Shor's algorithm factors integers by detecting hidden periodicity. The Berggren tree has its own periodicity-like structure. Whether these can be connected is an open question of considerable importance.

## The Deeper Pattern

There is something philosophically striking about this work. A pattern noticed by Babylonian scribes — right triangles with integer sides — turns out to encode information about the deepest problems in modern computer science. The connection runs through layers of abstraction: from triangles to matrices, from matrices to lattices, from lattices to computational hardness, from hardness to the security of global communications.

Mathematics has a long history of such unexpected connections. Euler's study of the bridges of Königsberg gave birth to graph theory, which now underlies every social network. Riemann's abstract geometry became the language of Einstein's general relativity. The theory of elliptic curves, developed for pure aesthetic reasons, became the basis of the cryptography that secures most of the world's internet traffic.

The Pythagorean lattice reduction sits in this tradition. It takes one of the oldest objects in mathematics — the right triangle with integer sides — and shows that it is still hiding secrets relevant to the most urgent problems of the digital age. The Babylonian scribe who pressed those numbers into clay 4,000 years ago could not have imagined where they would lead. But the numbers knew.

---

*The results described in this article have been established through rigorous mathematical proof, with complete machine verification of all claimed theorems. The counterexample to the over-general form of the reduction was discovered during the verification process and led to the corrected, sharper theorem presented here.*
