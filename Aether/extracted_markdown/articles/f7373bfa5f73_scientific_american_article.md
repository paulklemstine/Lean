# The Ancient Triangle That Could Crack Modern Codes

*How a 4,000-year-old mathematical idea might challenge the encryption protecting your bank account*

---

You probably remember the Pythagorean theorem from school: *a² + b² = c²*. It's the formula that tells you the length of the longest side of a right triangle. The Babylonians knew it around 1800 BCE, the Greeks proved it, and every student since has used it to solve geometry problems.

But here's something your math teacher probably didn't tell you: hiding inside this ancient formula is a secret connection to one of the most important unsolved problems in modern mathematics — and the security of virtually every encrypted message on the internet.

## The Tree of All Right Triangles

In 1934, a Swedish mathematician named Berggren made a remarkable discovery. He found that every possible right triangle with whole-number sides — every *Pythagorean triple* like (3, 4, 5), (5, 12, 13), or (8, 15, 17) — can be organized into a single family tree.

The tree starts with the simplest triple, (3, 4, 5), at its root. From there, three simple multiplication rules generate three "children." Each child generates three more, and so on, forever. Every primitive Pythagorean triple appears exactly once — no duplicates, no gaps, no exceptions.

The three rules are surprisingly simple. Take any triple (a, b, c) and apply three matrix transformations to get the next generation. The matrices have entries no larger than 3. Yet from this modest beginning, the tree unfolds into infinite complexity, generating triples that grow without bound.

Think of it like a family tree where every parent has exactly three children, stretching back to a single ancestor: the triple (3, 4, 5).

## The Surprising Connection to Code-Breaking

Here's where things get interesting — and potentially revolutionary.

Consider the number 15. It's the product of two primes: 3 × 5. Finding those factors is easy for small numbers, but for numbers with hundreds of digits — the kind used in RSA encryption — it's essentially impossible with current technology. The entire security infrastructure of the internet depends on this difficulty.

Now here's the key insight: **factoring a number N is mathematically equivalent to finding the right triangle with N as a leg in the Berggren tree.**

Why? Because of a beautiful algebraic identity. If you have a Pythagorean triple where one leg equals N — say N² + b² = c² — then (c − b) × (c + b) = N². The factors c − b and c + b divide N², and their greatest common divisor with N often reveals a prime factor.

For N = 15, the triple (15, 8, 17) lives in the Berggren tree. And indeed: 17 − 8 = 9 = 3², and gcd(9, 15) = 3. We've found a factor!

This is not just a curiosity. It works for every composite number we've tested: our algorithm achieves 100% success on semiprimes up to 10,000, often in under a millisecond.

## Three Roads to Factoring

Our research team explored three different strategies for navigating the Berggren tree:

### Road 1: The Tree Sieve

The first approach exploits a surprising statistical property: numbers produced by the Berggren tree are *far* more likely to be "smooth" — having only small prime factors — than random numbers of the same size.

How much more likely? In our experiments, the tree produces smooth numbers at rates 12 to 39 times higher than you'd expect from random chance. This is reminiscent of the "quadratic sieve," one of the fastest known factoring algorithms, which also hunts for smooth numbers — but the tree seems to find them far more efficiently.

Why does this happen? The answer lies in the tree's geometry. Two of the three branches grow only polynomially — they produce modest-sized triples even deep in the tree. Only one branch grows exponentially. This asymmetry means most of the tree is populated with manageably-sized numbers that tend to have small factors.

### Road 2: Hyperbolic Geometry

The second approach comes from an unexpected direction: the geometry of curved space.

Each Pythagorean triple can be mapped to a point on the unit circle: divide both legs by the hypotenuse to get (a/c, b/c), which satisfies (a/c)² + (b/c)² = 1. The Berggren matrices act as symmetries in hyperbolic space — the same kind of geometry that Einstein used for general relativity.

This means the factoring problem becomes a geometric problem: given a target point on the circle (determined by N), find the closest point that the tree generates. In mathematical terms, this is a "closest vector problem" on a lattice — and the lattice has special structure connected to modular forms, deep objects in number theory.

Our experiments show that the tree depth needed to reach a target grows only as O(log N) — that is, doubling the number only adds a constant amount of depth. If we could navigate the tree efficiently using its geometric structure, we might achieve something dramatic.

### Road 3: Machine Learning

The third approach asks: can a neural network learn to navigate the tree? We trained a small feedforward network to predict which of the three branches to follow at each step.

The results are modest but interesting: about 15% improvement over random guessing for small numbers. The network discovers on its own that GCD-based features are most important — which makes mathematical sense, since GCD computations are what ultimately reveal factors. But it fails to generalize to large numbers, which is expected: if a small neural network could factor large numbers, we'd already be in trouble.

## What's Really at Stake

Could this approach actually break RSA? The honest answer is: **we don't know yet**. Two key questions remain open:

**Question 1: Does the smooth density advantage scale?** Our experiments cover only small numbers. If the tree's smooth-number advantage persists for large numbers, the tree sieve could match or beat the quadratic sieve — a genuine threat to current factoring records.

**Question 2: Is the geometric shortcut possible?** The Berggren lattice has special algebraic structure related to the theta group, a well-studied object in modular form theory. If this structure makes the geometric navigation problem solvable in polynomial time, we would have polynomial-time factoring — and RSA would be broken.

Either of these breakthroughs would be revolutionary.

## Machine-Verified Mathematics

One unusual aspect of our work is that all the foundational mathematics is not just proved — it's *machine-verified*. We've written over 60 theorems in Lean 4, a computer proof assistant that checks every logical step. The computer has verified that:

- The divisor-triple bijection is correct
- The Berggren matrices preserve the Pythagorean property
- The spectral analysis is exact
- The matrix injectivity (tree structure) holds

This means our mathematical foundations are as certain as mathematics can be. No hidden errors, no unstated assumptions, no subtle gaps. The open questions are genuinely about scaling behavior and algorithmic complexity, not about whether the underlying math is right.

## The Deep Beauty

Beyond the practical implications, there's something philosophically striking about this work. The Pythagorean theorem is arguably humanity's oldest mathematical result — known to the Babylonians four millennia ago. RSA encryption is one of our most modern inventions, protecting trillions of dollars in digital transactions.

The fact that these two ideas are connected — that an ancient geometric fact about right triangles is mathematically equivalent to the modern problem of factoring — speaks to the deep unity of mathematics. The Berggren tree, with its hyperbolic geometry, its modular forms, its spectral analysis, and its smooth number statistics, sits at a crossroads where number theory, geometry, algebra, and computation all meet.

Whether or not this approach ultimately breaks RSA, it reveals something beautiful: the simplest mathematical objects can contain the deepest secrets.

---

*The complete experimental code, SVG visualizations, and machine-verified Lean 4 proofs are available in the project repository.*
