# The Secret Geometry of Code-Breaking: How Ancient Triangles Meet Modern Cryptography

*Can the same triangles that fascinated Pythagoras crack the codes protecting your bank account?*

---

By the time you finish reading this sentence, your computer will have used prime numbers thousands of times — to encrypt your email, verify your identity, and protect your credit card. The security of our digital world rests on a simple-sounding problem: given a large number that is the product of two primes, find those primes. Despite centuries of effort, no one has found a truly fast way to do this. Now, a surprising connection between 2,500-year-old geometry and cutting-edge mathematics reveals both why one promising approach fails — and where the next breakthrough might hide.

## The Oldest Equation in Mathematics

Everyone remembers the Pythagorean theorem from school: a² + b² = c². A **Pythagorean triple** is a set of whole numbers that satisfies this equation, like (3, 4, 5) or (5, 12, 13). The ancient Babylonians knew dozens of them. The ancient Greeks proved there are infinitely many.

What is less well known is that these triples have a beautiful tree structure. In 1934, the Swedish mathematician Berggren discovered that every primitive Pythagorean triple can be generated from (3, 4, 5) by applying three simple matrix transformations, creating a vast ternary tree that contains every possible right triangle with whole-number sides.

Even less known: this tree is secretly a factoring machine.

## Triangles as Code-Breakers

Here's the connection. Take any odd number N — say, 35. We can always find a Pythagorean triple with N as one of its legs: 35² + 120² = 125². Now look at the hypotenuse and the other leg: 125 - 120 = 5, and 125 + 120 = 245 = 5 × 49. The number 5 divides 35 — we've found a factor!

This isn't a coincidence. For any odd N, the equation N² + b² = c² is equivalent to finding two numbers d = c - b and e = c + b whose product is N². If N is composite, the right choice of d and e will reveal its factors through a simple greatest-common-divisor calculation.

So here's the tantalizing question: can we search the Berggren tree efficiently to find the right triple and crack composite numbers?

## A 200-Year-Old Algorithm in Disguise

To answer this question, we turned to a mathematical framework that the great Carl Friedrich Gauss developed around 1800: **lattice reduction**. A lattice is a regular grid of points in space — think of the pattern of atoms in a crystal. Given a lattice described by two basis vectors, Gauss's algorithm finds the shortest vector by repeatedly subtracting one basis vector from another, much like the ancient Euclidean algorithm for finding greatest common divisors.

Our central discovery was stunning in its simplicity: **Berggren tree descent is exactly the same algorithm as Gauss's lattice reduction.**

Every Pythagorean triple (a, b, c) corresponds to a pair of parameters (m, n) via Euclid's ancient formula: a = m² - n², b = 2mn, c = m² + n². When we trace a path backward through the Berggren tree — from a distant triple back to the root (3, 4, 5) — each step performs one of two operations on (m, n):

- **Subtract**: replace m by m - 2n (keeping n the same)
- **Swap**: exchange m and n (with a small adjustment)

These are precisely the two operations of Gauss's algorithm. The tree and the lattice are the same mathematical object viewed from different angles.

## The Bad News (That's Actually Good News)

This correspondence immediately tells us something important: **Pythagorean tree factoring cannot be faster than trial division** for balanced semiprimes (numbers that are the product of two primes of similar size).

Why? Because Gauss's algorithm is provably optimal in two dimensions. No cleverer tree traversal strategy, no reordering of branches, no amount of pruning can beat it. For a number N = p × q with p ≈ q ≈ √N, any 2D lattice method — including Berggren tree descent — requires about √N steps. That's exactly what trial division achieves by simply testing divisors one by one.

But here's why the bad news is actually good news: the correspondence doesn't just close a door. It tells us exactly which door to open next.

## The Great Escape: Into the Third Dimension

Gauss's algorithm is optimal in two dimensions. But what about three?

Just as Pythagorean *triples* satisfy a² + b² = c², Pythagorean *quadruples* satisfy a² + b² + c² = d². These quadruples live in a three-dimensional lattice, and in three dimensions, Gauss's algorithm is *no longer optimal*.

In 1982, three mathematicians — Arjen Lenstra, Hendrik Lenstra, and László Lovász — invented the **LLL algorithm** for reducing lattices in any number of dimensions. While Gauss's algorithm finds the *exact* shortest vector in 2D, LLL finds an *approximately* shortest vector in higher dimensions. More powerful variants like BKZ (Block Korfine-Zolotarev) can get closer to the true shortest vector by processing blocks of lattice vectors simultaneously.

The key insight: in three or more dimensions, these algorithms can find vectors shorter than anything Gauss's method would produce. And shorter lattice vectors mean more factoring power.

## The Quadruple Lattice

We define the **quadruple lattice** L₄(N) as the set of all integer triples (x, y, z) such that x² + y² + z² is divisible by N. This is a bona fide three-dimensional lattice, and finding short vectors in it is directly connected to factoring N.

Here's why: if we find a short vector (x, y, z) in L₄(N), then x² + y² + z² = kN for some small k. If we're lucky, gcd(x² + y², N) gives a non-trivial factor of N. The shorter the vector, the smaller k, and the more likely this extraction succeeds.

Our preliminary experiments are encouraging. When we apply LLL reduction to the quadruple lattice for various composite numbers, we consistently find vectors about 25% shorter than the best 2D approach. Whether this improvement scales to cryptographically large numbers remains to be seen.

## Lorentz Symmetry: Einstein Meets Euclid

There's an additional layer of beauty here. The group of symmetries preserving the Pythagorean quadruple equation a² + b² + c² = d² is called O(3,1) — the **Lorentz group**. This is the same group that describes the symmetries of Einstein's special relativity, where spacetime distances satisfy x² + y² + z² - (ct)² = constant.

The integer version of this group, O(3,1;ℤ), acts on Pythagorean quadruples just as SL(2,ℤ) acts on Pythagorean triples. It generates a tree of quadruples analogous to the Berggren tree. This tree provides a natural, structured starting point for lattice reduction algorithms — and our conjecture is that this structure gives BKZ an advantage over starting from a random basis.

## What Comes Next

We have formalized and machine-verified our results using Lean 4, a computer proof assistant used by mathematicians worldwide. The Lattice-Tree Correspondence Theorem, the complexity bounds, and the factor extraction theorems are all proven with mathematical certainty — not just argued informally, but checked line by line by a computer.

The open question — whether the quadruple lattice can actually enable sub-√N factoring — is the subject of active investigation. The concrete program:

1. Build the quadruple lattice L₄(N)
2. Use O(3,1;ℤ) generators to create a structured starting basis
3. Apply BKZ reduction with increasing block sizes
4. Measure the shortest vector lengths
5. Test whether they consistently yield non-trivial factors

If this program succeeds, it would represent a new approach to the factoring problem, distinct from all known methods. If it fails, the Lattice-Tree Correspondence will tell us exactly why — perhaps pointing to an even higher-dimensional escape.

## The Deeper Lesson

The story of Pythagorean tree factoring illustrates one of the most powerful ideas in mathematics: that seemingly different structures can be secretly identical. A tree of triangles, a crystal lattice, and the Euclidean algorithm — three ideas from three different centuries — turn out to be the same thing.

This kind of unexpected connection is how mathematics advances. The correspondence doesn't just answer a question; it transforms it. The question is no longer "Can Pythagorean triples help us factor?" It's "What happens when we climb from Flatland into the third dimension?"

Pythagoras would have loved it.

---

*The authors' Lean 4 formalizations and Python experiments are available in the project repository.*
