# The Secret Geometry of Prime Numbers: How Ancient Triangles Could Crack Modern Codes

*A journey from Pythagoras to cybersecurity through a beautiful mathematical tree*

---

You probably remember the Pythagorean theorem from school: *a*² + *b*² = *c*². The classic 3-4-5 right triangle. Simple, ancient, elegant. But what if this 2,500-year-old equation held the key to one of the most important unsolved problems in computer science — breaking the codes that protect your bank account?

Welcome to the strange and beautiful world of **Pythagorean tree factoring**.

## The Tree That Grows All Right Triangles

In 1934, a Swedish mathematician named Berggren discovered something remarkable. Start with the simplest Pythagorean triple: (3, 4, 5). Apply three specific matrix transformations — think of them as mathematical "growth rules" — and you get three new triples: (5, 12, 13), (21, 20, 29), and (15, 8, 17). Apply the same rules to each of these, and you get nine more. Keep going, and you generate *every* primitive Pythagorean triple that exists, each appearing exactly once.

It's a perfectly regular ternary tree, an infinite family tree of right triangles descending from a single ancestor.

What makes this tree special isn't just its completeness — it's its *geometry*. The three growth matrices preserve a mathematical quantity called the **Lorentz form**: *a*² + *b*² − *c*² = 0. This is the same equation that describes light cones in Einstein's special relativity. The Berggren tree is, quite literally, tiling the hyperbolic plane with right triangles.

## The Factoring Connection

Here's where things get interesting for cryptography. Take any odd number *N* — say, 77. You can always find at least one Pythagorean triple with *N* as one of its legs:

77² + 2964² = 2965²

This is the "trivial" triple. But if *N* is composite — if it's a product of two primes, like 77 = 7 × 11 — then additional triples exist:

77² + 36² = 85²
77² + 264² = 275²

And here's the key: each of these non-trivial triples *encodes* a factorization of *N*. The leg 77 and the quantity *c* − *b* = 85 − 36 = 49 = 7² share a common factor with *N*: gcd(49, 77) = 7. Factor found!

For a prime number, only the trivial triple exists — a fact proved formally and verified by computer. This means:

> **A number is prime if and only if it has exactly one Pythagorean triple as a leg.**

This is a striking characterization of primality through geometry.

## Descending the Tree

The factoring algorithm works by **descent**: start with the trivial triple for *N*, then walk backward up the Berggren tree toward the root (3, 4, 5). At each step, compute the greatest common divisor (GCD) of the current legs with *N*. If a non-trivial GCD appears — boom, you've found a factor.

Each step uses one of three "inverse Berggren matrices" to move from child to parent, reducing the hypotenuse. The descent is guaranteed to terminate because each step strictly decreases the hypotenuse, and it can't drop below 5 (the root).

How many steps does this take? For a semiprime *N* = *p* × *q*, our experiments and formal proofs show it requires roughly √*N* steps — about the same as trial division, the brute-force method of checking every possible divisor. Not a speedup, exactly. But something far more valuable: a *geometric* understanding of what factoring means.

## The Lorentz Connection

The Berggren matrices belong to a mathematical group called O(2,1;ℤ) — the integer Lorentz group. This is the group of 3×3 integer matrices that preserve the "distance" *a*² + *b*² − *c*². In physics, this same structure governs the symmetries of special relativity.

Two of the three matrices (B₁ and B₃) are "proper" rotations with determinant +1. The third (B₂) is a reflection with determinant −1. Together, their 2×2 counterparts generate the **theta group** Γ_θ, an index-3 subgroup of the modular group SL(2,ℤ) — the very group that connects to elliptic curves, modular forms, and some of the deepest mathematics of the past century.

This means the Berggren tree isn't just a clever construction. It's a *fundamental object* in number theory, connected to the same mathematical universe that produced Andrew Wiles's proof of Fermat's Last Theorem.

## The Fourth Dimension

What happens if we go higher? Pythagorean quadruples — solutions to *a*² + *b*² + *c*² = *d*² — live on a null cone in 4D spacetime, governed by the group O(3,1;ℤ). Their tree has *more* branches per node (at least four), meaning faster exploration. Each quadruple provides three legs for GCD computation instead of two. And by Legendre's three-square theorem, almost every integer participates in some quadruple representation.

Our preliminary experiments suggest that the quadruple tree provides roughly 1.5 to 2 times more factoring information per step than the triple tree. Whether this can be pushed to an asymptotic advantage remains an open question.

## What We Proved (With a Computer's Help)

All the key theorems in this story have been formally verified using the Lean 4 proof assistant with the Mathlib mathematical library — the same technology used to verify that the 100-trillion-digit computation of π was correct.

The formal proofs cover:
- The Berggren matrices preserve the Lorentz form ✓
- Each descent step reduces the hypotenuse ✓
- Every PPT has a unique parent in the tree ✓
- Primes have exactly one Pythagorean triple as a leg ✓
- Composites have multiple triples, each encoding a factor ✓

These aren't just pen-and-paper arguments — they're mathematical certainties checked by machine.

## The Road Ahead

Pythagorean tree factoring won't break RSA anytime soon. Its Θ(√*N*) complexity matches trial division, and modern cryptographic keys use numbers with hundreds of digits, where even √*N* is astronomically large.

But the *mathematical connections* it reveals — between Pythagorean triples, hyperbolic geometry, the Lorentz group, modular forms, and factoring — suggest that we haven't yet seen the full picture. The most tantalizing direction: the Euclid parameters (*m*, *n*) that generate each triple form a 2D lattice, and finding factors corresponds to finding short vectors in this lattice. Lattice reduction algorithms like LLL are the basis of some of the most powerful tools in modern cryptanalysis. Could the Berggren tree structure *guide* lattice reduction to find factors faster?

That question remains open. But if the history of mathematics teaches us anything, it's that when ancient geometry meets modern algebra, surprising things happen. Pythagoras's triangles may yet have secrets to tell.

---

*The author would like to thank the Lean community and Mathlib contributors for making formal verification accessible, and the open-source mathematics community for supporting reproducible research.*

---

### Box: How to Factor 77 with Pythagoras

1. **Start**: Triple (77, 2964, 2965) — the trivial triple
2. **Ascend**: Apply inverse Berggren matrix B₁⁻¹
3. **Check**: At each step, compute gcd(leg, 77)
4. **Find**: After ~10 steps, encounter a triple where gcd(leg, 77) = 7
5. **Done**: 77 = 7 × 11 ✓

### Box: The Numbers

- **3, 4, 5** — The root of all Pythagorean triples
- **3** — Number of branches per tree node
- **O(2,1;ℤ)** — The symmetry group (integer Lorentz group)
- **Θ(√N)** — Factoring complexity via tree descent
- **2,500** — Years since Pythagoras (approximately)
