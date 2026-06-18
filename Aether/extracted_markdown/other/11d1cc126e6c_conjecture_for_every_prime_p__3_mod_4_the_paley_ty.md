# The Matrix That Builds Itself: How a 19th-Century Number Trick Became an Infinite Engine of Perfect Balance

## A Grid of Surprises

Imagine you are an agricultural scientist in the 1930s, trying to figure out which of seven fertilizer blends works best on wheat. You could test them one at a time, but seasons are short and fields are expensive. What you really need is a way to run all seven experiments simultaneously, in a pattern so cleverly interlocked that every comparison is equally reliable—no blend gets an unfair advantage from better soil or sunnier weather.

The mathematical object that solves this problem is called a **Hadamard matrix**: a square grid of plus-ones and minus-ones whose rows are perfectly orthogonal. Think of each row as a recipe for mixing signals together. Because the rows point in completely independent directions, you can untangle any combination of results with perfect precision. No information is lost. No noise is amplified.

The catch is that these perfect grids are maddeningly hard to find. For a century, mathematicians have hunted for them at every size that the theory says they could exist—every multiple of four. Some sizes yield to simple tricks. Others resist every known technique. The oldest open question in combinatorics asks whether a Hadamard matrix exists at *every* multiple of four. Nobody knows.

But there is one family of Hadamard matrices that has been known since 1933, when the English mathematician Raymond Paley discovered a construction that works for infinitely many sizes at once—not by guessing and checking, but by reaching deep into the arithmetic of prime numbers. His idea connects patterns that seem to belong to entirely different branches of mathematics, and the result is an infinite engine that manufactures perfect balance from pure number theory.

## The Secret Life of Squares

The story begins with one of the oldest questions in arithmetic: which numbers are *perfect squares* modulo a prime?

Pick a prime number—say, 7. The squares modulo 7 are 0² = 0, 1² = 1, 2² = 4, 3² = 2 (since 9 = 7 + 2). So the nonzero squares are {1, 2, 4}, and the nonsquares are {3, 5, 6}. The **quadratic character** χ labels every number: χ(a) = +1 if a is a nonzero square, χ(a) = −1 if a is a nonsquare, and χ(0) = 0.

Now here is the surprise. Compute the sum

$$\sum_{t=0}^{6} \chi(t) \cdot \chi(t + a)$$

for each possible shift *a*. When *a* = 0, you are summing χ(t)², which is 1 for every nonzero *t*, giving 6. But for *every* nonzero shift—a = 1, 2, 3, 4, 5, or 6—the sum is exactly **−1**.

This is not a coincidence specific to 7. It happens for every prime p ≡ 3 (mod 4). The correlation of the quadratic character with any nontrivial shift of itself is always −1. The diagonal case gives p − 1 and every off-diagonal case gives −1, as predictable as a clock.

This identity—the **quadratic character correlation theorem**—is the engine behind the entire construction.

## From Correlation to Orthogonality

Paley's insight was to package the character into a matrix. Define the **Jacobsthal matrix** Q, a p × p grid where the entry in row *a*, column *b* is simply χ(a − b). Because the character depends only on the difference, Q is a circulant matrix: every row is a shifted copy of the first.

The correlation identity translates directly into a matrix equation. When you multiply Q by its transpose, the (a, b) entry is exactly the correlation sum for shift a − b. So:

$$Q \cdot Q^\top = p \cdot I - J$$

where I is the identity matrix and J is the all-ones matrix. In words: the diagonal entries are p − 1, and every off-diagonal entry is −1.

This is already remarkable. But Paley went further. He embedded Q into a larger matrix by adding a border:

$$H = \begin{pmatrix} 1 & \mathbf{1}^\top \\ -\mathbf{1} & Q + I \end{pmatrix}$$

The border row is all ones; the border column is all negative ones (except the corner). The interior is Q shifted up by the identity, turning the diagonal zeros into ones.

A short calculation—using the Jacobsthal identity and the fact that the row sums of Q are zero (another consequence of the character sum)—shows that this (p+1) × (p+1) matrix satisfies

$$H \cdot H^\top = (p+1) \cdot I.$$

Every entry of H is ±1. The rows are perfectly orthogonal. **H is a Hadamard matrix.**

## An Infinite Supply

What makes Paley's construction extraordinary is its scope. There are infinitely many primes p ≡ 3 (mod 4)—the sequence begins 3, 7, 11, 19, 23, 31, 43, 47, 59, 67, 71, … and never ends (a consequence of Dirichlet's theorem on primes in arithmetic progressions). Each such prime produces a Hadamard matrix of order p + 1. So the Paley construction certifies Hadamard matrices of orders 4, 8, 12, 20, 24, 32, 44, 48, 60, 68, 72, 80, 84, and on without limit.

These are not just abstract existence claims. The construction is completely explicit: given a prime, you can write down the matrix, entry by entry, using nothing more than modular exponentiation. And the proof that it works reduces entirely to that single correlation identity—a fact about how quadratic residues distribute among the integers.

## The Bridge to Design Theory

The applications begin the moment the matrix is constructed. One of the most powerful is a bridge between linear algebra and combinatorial design.

Take any Hadamard matrix H of order 4n and normalize it so that the first row and column are all ones. Now strip away that first row and column, and transform the remaining (4n−1) × (4n−1) matrix by replacing each +1 with 1 and each −1 with 0. Call the result A.

A is the incidence matrix of a **balanced incomplete block design** (BIBD)—a combinatorial structure where v objects are arranged into blocks of size k such that every pair of objects appears together in exactly λ blocks. The parameters are locked to the Hadamard order:

$$v = 4n - 1, \quad k = 2n - 1, \quad \lambda = n - 1.$$

For the Paley matrix with p = 7 (order 8, so n = 2), this produces a BIBD(7, 3, 1): seven objects arranged into seven blocks of three, with every pair appearing in exactly one block. This is the **Fano plane**, the smallest finite projective plane—one of the most celebrated objects in all of discrete mathematics.

For p = 23 (order 24, n = 6), you get a BIBD(23, 11, 5). For p = 47 (order 48, n = 12), a BIBD(47, 23, 11). Each prime delivers a new, provably optimal experimental design.

## Why Perfect Balance Matters

These matrices and designs are not mathematical curiosities. They are engineering tools.

**In telecommunications**, Hadamard matrices define the spreading codes used in CDMA (Code Division Multiple Access), the technology behind 3G cellular networks. Each user's signal is multiplied by a row of the Hadamard matrix, spreading it across the entire bandwidth. Because the rows are orthogonal, the signals can be perfectly separated at the receiver—even when dozens of users share the same frequency band.

**In medical imaging**, Hadamard-based measurement patterns are used in spectroscopy and MRI to acquire data more efficiently. Instead of measuring one frequency or one voxel at a time, you measure clever combinations and reconstruct the individual signals mathematically. The orthogonality of the Hadamard rows guarantees that the reconstruction is exact and noise-optimal.

**In statistical design of experiments**, BIBDs are the gold standard for fairness. When a pharmaceutical company tests seven drug formulations but can only include three in each trial site, a BIBD ensures that every pair of formulations is directly compared the same number of times. No formulation is disadvantaged by site effects.

**In quantum information**, Hadamard-like matrices describe the symmetries of certain quantum states and measurements. Mutually unbiased bases—the quantum analogue of perfectly orthogonal measurement frames—are intimately connected to Hadamard matrices, and constructions from finite fields play a central role.

## The Multiplication Machine

There is one more trick that turns a finite list of Hadamard matrices into an avalanche. If H₁ is a Hadamard matrix of order m and H₂ is a Hadamard matrix of order n, then their Kronecker product H₁ ⊗ H₂ is a Hadamard matrix of order mn.

This means the Paley matrices combine with each other and with the simple 2 × 2 Sylvester matrix to generate certified Hadamard orders at every product of their individual sizes. Starting from just the Paley Type I family and powers of two, the Kronecker closure covers a substantial fraction of all multiples of four.

How substantial? Among all multiples of four up to 1,000, the Sylvester–Paley–Kronecker pipeline certifies over 70% of them. The uncovered orders—668, 716, 892, and a handful of others—are the frontier where new construction methods are still needed.

## The Ancient Question

The Hadamard conjecture, posed in 1893, asks whether a Hadamard matrix exists for every order that is a multiple of four. After more than 130 years, it remains open. The smallest undecided case is order 668.

Paley's construction, despite being 90 years old, remains one of the most powerful tools in the attack on this conjecture. It is clean, explicit, and grounded in deep number theory. The character correlation identity—the fact that the quadratic residues of a prime are distributed with exactly the right correlations to produce orthogonality—is a bridge between the arithmetic of prime numbers and the geometry of perpendicular directions in high-dimensional space.

That bridge is not an accident. It reflects a profound connection between **harmonic analysis on finite fields** and **the geometry of sign patterns**. The quadratic character is the simplest multiplicative character, and its correlation properties are a shadow of the general theory of Gauss and Jacobi sums. Extending Paley's construction to prime powers, to higher-order characters, and to non-abelian groups is an active research program that connects number theory, algebraic geometry, and combinatorics.

## A Living Blueprint

What makes this story worth telling today is not just the beauty of the mathematics, but its productivity. The Paley construction is not a one-off result. It is a template—a design pattern that converts arithmetic identities into geometric objects. Every time mathematicians discover a new family of "flat-spectrum" functions on a finite group (functions whose correlations are constant off-origin), the Paley machinery converts them into new Hadamard matrices, new block designs, new error-correcting codes, and new sensing matrices.

The quadratic residues of a single prime contain, in compressed form, the instructions for building a perfectly balanced experiment, a perfectly orthogonal signal basis, and a perfectly equitable tournament. The fact that this works is not magic—it is the consequence of a precise identity about how squares distribute among the integers. But the range of structures that identity generates, across fields from agriculture to quantum physics, is as close to magic as mathematics gets.

The search for Hadamard matrices continues. Every new family narrows the gap in the conjecture. Every new construction opens new applications. And at the foundation of it all, in the arithmetic of primes and the correlations of quadratic residues, the engine that Paley built in 1933 is still running.
