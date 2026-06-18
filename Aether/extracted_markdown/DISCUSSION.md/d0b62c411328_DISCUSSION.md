# The Hidden Geometry of Right Triangles

*How a 4,000-year-old equation connects to the deepest unsolved problems in mathematics*

---

Everyone learns the Pythagorean theorem in school: a² + b² = c². It's the equation that tells you the length of the longest side of a right triangle. Simple enough that Babylonian scribes carved solutions into clay tablets around 1800 BCE. But behind this elementary equation lies a mathematical universe so rich that it connects to some of the most profound and difficult questions mathematicians grapple with today.

## The Infinite Tree

In 1934, a mathematician named Berggren discovered something remarkable: every primitive Pythagorean triple — solutions like (3, 4, 5) and (5, 12, 13) where the three numbers share no common factor — can be generated from the single "root" triple (3, 4, 5) by repeatedly applying three specific transformations. These transformations are represented by 3×3 matrices, and together they create an infinite ternary tree that contains every primitive solution exactly once.

Think of it as a family tree for right triangles. The triple (3, 4, 5) is the primordial ancestor, and from it spring three children: (5, 12, 13), (21, 20, 29), and (15, 8, 17). Each of these produces three more children, and so on forever.

What makes this tree special is its hidden symmetry. The three Berggren matrices preserve something called the *Lorentz form* — the same mathematical structure that Einstein used to describe spacetime in special relativity. The equation a² + b² - c² = 0 for a Pythagorean triple looks suspiciously like x² + y² - t² = 0 from relativity. This isn't a coincidence. The Berggren tree lives inside a discrete version of the Lorentz group — the same symmetry group that governs the laws of physics.

## Tropical Mathematics: When Addition Becomes Maximum

Now imagine a world where the rules of arithmetic are different. Instead of addition, you use the maximum operation. Instead of multiplication, you use addition. This isn't science fiction — it's called *tropical mathematics*, and it has become one of the most active areas of modern mathematical research.

In tropical arithmetic, 3 "plus" 5 equals 5 (the maximum), and 3 "times" 5 equals 8 (the sum). This might sound bizarre, but it captures something important: the behavior of valuations, which measure how divisible a number is by a prime.

When you look at the Berggren tree through the lens of tropical mathematics, something interesting happens. For each prime p, you can create a matrix of p-adic valuations — recording how many times p divides each number in each triple along a path from the root. This "tropical valuation matrix" encodes arithmetic information about the path in a compact, algebraic form.

A natural conjecture arose: perhaps the tropical rank of this matrix (a measure of its complexity in the max-plus world) equals the number of distinct prime factors of the target number. If true, this would create a beautiful bridge between tropical geometry and number theory.

Our research rigorously *disproved* this conjecture with machine-verified counterexamples. For the number 25 = 5², the tropical rank is at least 2, but it has only one prime factor. The proof is completely computational and was verified by the Lean 4 theorem prover — there's no room for error.

## The Langlands Program: Mathematics' Grand Unified Theory

At the other end of the mathematical spectrum sits the Langlands program, often called the "grand unified theory of mathematics." Proposed by Robert Langlands in 1967, it predicts deep and unexpected connections between number theory (the study of integers) and representation theory (the study of symmetry).

For the group GL₂ — the group of 2×2 invertible matrices — the Langlands program makes precise predictions. The *Hecke algebra* captures the local structure of the group at each prime, and the *Satake isomorphism* identifies this algebra with a ring of polynomials. The *trace formula*, developed by Selberg and Arthur, provides a powerful equality between spectral data (eigenvalues of operators) and geometric data (orbital integrals).

## Where the Threads Meet

The remarkable discovery at the heart of this research is that the Berggren tree naturally connects these two worlds. The Berggren matrices, reduced modulo a prime p, generate finite groups that act on the Lorentz form over the finite field 𝔽ₚ. These finite groups are precisely the kind of objects that appear in the local Langlands correspondence for GL₂.

The spectral gap of the resulting Cayley graphs — measured as 6 - 2√5 for the 6-regular case — determines how well the finite quotients approximate the infinite tree. Graphs achieving the optimal bound (the Alon-Boppana bound of 2√(d-1)) are called *Ramanujan graphs*, connecting to the Ramanujan conjecture about automorphic forms.

## Carmichael's Theorem: A Deep Number Theory Challenge

Alongside the tropical-Langlands investigation, we tackled a classical result from 1913: Carmichael's theorem on primitive prime divisors of Fibonacci numbers. The theorem states that for every n ≥ 13, the Fibonacci number F(n) has at least one prime factor that doesn't divide any earlier Fibonacci number F(k) for 0 < k < n.

The prime case is elegant: if n is prime, then any prime factor p of F(n) must be primitive, because the "entry point" of p (the smallest positive k with p | F(k)) must divide n, and since n is prime, the entry point is either 1 or n. Since F(1) = 1, no prime divides F(1), so the entry point must be n.

The composite case is significantly harder and remains one of the open challenges in formal verification. Our project verifies the composite case computationally for all n up to 10,000 using the "coprime part" method — systematically removing all prime factors shared with F(d) for proper divisors d of n and checking that what remains is greater than 1.

## Machine-Verified Mathematics

What makes this research distinctive is its use of *formal verification*. Every theorem in the project has been checked by the Lean 4 proof assistant, which means the logical arguments have been verified down to the axioms of mathematics. A computer doesn't just check that an answer looks right — it verifies every logical step of the proof.

This approach caught several errors that might have slipped past human review. The original tropical rank conjecture appeared plausible, but the formal counterexamples left no doubt about its falsity. Similarly, an early claim about p-adic factoring (that every n > 1 can be non-trivially factored) was correctly identified as false — primes are counterexamples! — and replaced with the correct statement requiring n to be composite.

## Looking Forward

The connections between tropical geometry, the Langlands program, and Pythagorean arithmetic are still being explored. Key open questions include:

- Can the tropical Satake isomorphism be made precise for GL₂?
- Does the Berggren tree encode automorphic data through its branching structure?
- Can Carmichael's theorem be fully formalized for the composite case?

What began with a 4,000-year-old equation about right triangles has led us to the frontier of modern mathematics — a place where ancient geometry, tropical algebra, and the deepest conjectures about the nature of numbers all come together.
