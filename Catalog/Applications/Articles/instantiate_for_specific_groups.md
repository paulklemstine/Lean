# When Ancient Triangles Generate Modern Randomness

## The Oldest Equation Hides a Secret

The equation *a² + b² = c²* is perhaps the most famous in all of mathematics. Every schoolchild learns about the 3-4-5 right triangle. Mathematicians have studied Pythagorean triples for at least 4,000 years — clay tablets from ancient Babylon list them in careful columns.

But here is something almost nobody knows: buried inside this ancient equation is a machine that generates randomness. Not the kind of randomness you get from rolling dice or flipping coins, but something more subtle and more powerful — a deterministic process that *looks* random to any observer using reasonable mathematical tests. And this has profound implications for the future of computing.

## Three Mirrors and a Tree

In 1934, a Swedish mathematician named Berggren discovered something remarkable about Pythagorean triples. He found three simple operations — think of them as three "mirrors" — that, starting from the humble triple (3, 4, 5), generate every primitive Pythagorean triple exactly once. Not approximately. Not most of them. *Every single one.*

These three operations form what mathematicians call a *semigroup*: you can compose them in any order, applying mirror after mirror, and each sequence of operations produces a different Pythagorean triple. The result is an infinite ternary tree, branching three ways at each node, with every primitive Pythagorean triple sitting at exactly one leaf.

Now here's where it gets interesting. What happens when you play this game not with actual integers, but with *modular arithmetic* — where numbers wrap around at some fixed value, like hours on a clock?

## The Orbit That Mixes

Pick a prime number, say *q* = 13. Now reduce the Berggren tree modulo 13 — every triple gets mapped to a triple of remainders after dividing by 13. The infinite tree collapses onto a finite set: the "orbit" of (3, 4, 5) under the three Berggren mirrors, working modulo 13.

For *q* = 13, this orbit turns out to have exactly 84 states. And here is the phenomenon that changes everything: if you walk randomly through this orbit — picking one of the three mirrors at each step — you mix *exponentially fast*. After just a handful of steps, no matter where you started, you are essentially uniformly distributed across all 84 states.

How fast? The rate of mixing is governed by a single number called the *spectral radius*, denoted ρ. For the Berggren walk, ρ ≈ 0.577 — remarkably close to 1/√3. After *n* steps, any deviation from uniformity shrinks by a factor of (0.577)^*n*. After 10 steps, you're already within 0.3% of perfectly uniform. After 30 steps, the deviation is less than one part in a billion.

## What "Fooling" Really Means

But mixing is only the beginning. The deeper question is: *who* is fooled?

Imagine an adversary who can apply any polynomial test to your position — squaring coordinates, multiplying them together, forming quadratic expressions like *a² + b² - c²*. These tests can be quite sophisticated; they capture the computational power of algebraic circuits, which are the fundamental building blocks of modern computation.

The theorem we have proved says something stunning: **no polynomial test, of any degree, can distinguish the output of the Berggren walk from true randomness**, once the walk has run long enough. The error decays exponentially at rate ρ^*n*, regardless of the test's complexity.

This is not just a statement about averages or expectations. It says that the *maximum* deviation, over all possible states, between what the walk produces and what a truly random source would produce, is exponentially small. The Berggren mirrors — a construction from 1934, rooted in 4,000-year-old number theory — produce a pseudorandom generator that defeats all polynomial-time algebraic tests.

## The Spectral Gap: Nature's Mixing Switch

What makes the Berggren walk mix so fast? The answer lies in a concept called the *spectral gap*.

Every linear transformation on a finite space can be decomposed into a sum of simpler components, each corresponding to a "frequency" — just as a musical chord can be decomposed into individual notes. The spectral gap measures how quickly the non-constant frequencies decay. A large spectral gap means fast mixing; a small one means slow mixing; zero means the system has trapped invariant pieces that never mix at all.

For the Berggren semigroup on orbits modulo primes, the spectral gap is strikingly large — about 0.42 for most primes tested. This is comparable to the best-known expander graphs in theoretical computer science, but it arises from pure number theory rather than from combinatorial constructions.

The key insight of our work is that **spectral gap alone is sufficient to guarantee fooling.** The proof is elegant: take any test function *f*. Decompose it into its average value (a constant) and its fluctuations around the average (the "centered" part). The constant is fixed by the walk — it never changes. The fluctuations contract by a factor of ρ at each step. After *n* steps, the fluctuations have shrunk to ρ^*n* times their original size. That's the entire argument.

## From Triangles to Computers

Why should computer scientists care about Pythagorean triples?

One of the central open problems in theoretical computer science is *derandomization*: can every randomized algorithm be replaced by a deterministic one that runs almost as fast? Many of the best algorithms in practice — for testing whether a polynomial is identically zero, for checking matrix identities, for verifying proofs — rely on random choices. If we could replace these random bits with deterministic pseudorandom bits, we would fundamentally change our understanding of computational efficiency.

The standard approach to derandomization uses *pseudorandom generators* (PRGs): deterministic functions that stretch a short random seed into a long sequence that "looks random" to bounded computations. Constructing PRGs has been one of the grand challenges of complexity theory for decades.

Our theorem opens a new avenue: **arithmetic PRGs from number theory.** Instead of building pseudorandom generators from Boolean circuits and hash functions — the traditional approach — we derive them from arithmetic semigroups acting on finite number-theoretic state spaces. The Berggren walk is a concrete example: it takes a single starting triple and a sequence of three-way choices, and produces an output that fools all polynomial-time algebraic tests.

The connection to polynomial identity testing (PIT) is direct. A core problem in algebraic complexity asks: given an arithmetic circuit that computes a polynomial, is the polynomial identically zero? The Schwartz-Zippel lemma says that evaluating at random points works with high probability. Our theorem says that the Berggren walk generates points that work just as well — and the walk is completely deterministic once you fix the starting state and the sequence of mirrors.

## A Bridge Across Mathematics

What makes this result especially exciting is that it connects mathematical worlds that rarely speak to each other.

On one side: **spectral theory and automorphic forms**, the deep machinery of modern number theory developed by Selberg, Langlands, and their school. The spectral gap of the Berggren semigroup modulo primes is ultimately a statement about representations of arithmetic groups — the same kind of analysis that powers the Langlands program, one of mathematics' most ambitious research agendas.

On the other side: **complexity theory and pseudorandomness**, the theoretical foundation of computer science. Fooling polynomial tests, derandomizing algorithms, understanding the power of random bits — these are the core questions driving the field.

Our theorem bridges these worlds with a single inequality: TestError ≤ C · ρ^*n*. On the left, a computational quantity — how well can a polynomial test distinguish the walk from randomness? On the right, a number-theoretic quantity — how fast does the arithmetic semigroup mix? The inequality says that spectral properties of arithmetic groups directly control computational pseudorandomness.

## Beyond Berggren

The Berggren semigroup is just the beginning. The same framework applies to any arithmetic semigroup with a spectral gap:

- **The Apollonian group**, which generates all Apollonian circle packings through reflections preserving a quadratic form. These fractal-like packings arise in physics, chemistry, and materials science.

- **The Markov group**, acting on solutions to *x² + y² + z² = 3xyz* — an equation connected to hyperbolic geometry, cluster algebras, and quantum topology.

- **SL(2,ℤ) and its subgroups**, the modular group that governs elliptic curves, modular forms, and the deep structure of number theory.

Each of these groups, reduced modulo primes, produces a finite dynamical system. If that system has a spectral gap — and in many cases, deep results in automorphic forms guarantee it does — then our theorem immediately produces a pseudorandom generator.

The vision is a new class of PRGs derived not from ad hoc combinatorial constructions, but from the rich structure of arithmetic dynamics. Each one comes with a provable guarantee, rooted in theorems that mathematicians have been building toward for over a century.

## A Machine-Verified Certainty

There is one more aspect of this work that deserves emphasis. The central theorem — that spectral gap implies fooling for all polynomial tests — has been proved with complete mathematical rigor, verified line by line by a computer proof checker. Every step of the argument, from the definition of the averaging operator to the final inequality, has been formally verified.

This matters because the theorem sits at the intersection of multiple mathematical fields, where errors in reasoning are notoriously easy to make and hard to catch. The formal verification provides absolute certainty that the bridge between spectral theory and pseudorandomness holds. It is not just a theorem; it is a certified fact.

## The View from Here

Four thousand years ago, Babylonian scribes carved lists of Pythagorean triples into clay tablets. They probably thought they were cataloguing a curiosity of arithmetic — special right triangles with integer sides.

They could not have imagined that those same triples, reduced modulo primes and shuffled by three simple operations discovered in 1934, would produce a machine for generating pseudorandomness powerful enough to fool the most sophisticated polynomial tests that modern computer science can devise.

Mathematics has a way of connecting the ancient to the cutting edge, the concrete to the abstract, the computational to the structural. The theorem proved here — that spectral expansion in arithmetic quotients implies pseudorandomness against algebraic tests — is one more thread in that tapestry. But it may also be the beginning of something new: a systematic program to derive the pseudorandom generators of the future from the number theory of the past.
