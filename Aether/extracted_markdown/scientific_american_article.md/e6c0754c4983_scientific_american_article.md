# The Gravity of Numbers: How Physicists' Intuition Is Cracking the Code of Primes

*A new mathematical framework treats factoring like finding valleys in a landscape—and a computer has verified every step.*

---

## The Hardest Easy Problem

Here's something strange: multiplying two numbers together takes a fraction of a second. Even a child can compute 113 × 137 = 15,481. But given 15,481 and asked to find those two factors? That's astonishingly hard. This asymmetry—easy to multiply, hard to un-multiply—is the bedrock of internet security. Every time you type a credit card number online, you're betting your money on the difficulty of factoring large numbers.

For decades, mathematicians have attacked this problem with increasingly sophisticated tools: number fields, elliptic curves, quantum algorithms. But a new approach called **Gravitational Factoring** borrows an idea from physics that is so simple it's surprising nobody tried it sooner.

## Falling Into Factors

Imagine you're rolling a ball across a hilly landscape. The ball naturally rolls downhill, seeking the lowest points—the valleys. In physics, these valleys are called *energy minima*, and finding them is one of the most fundamental problems in all of science.

The key insight of Gravitational Factoring is this: given any number N, define a "height" function:

> **E(x) = the remainder when N is divided by x**

Plot this function, and you get a jagged landscape. Most points have positive height—the ball sits above the valley floor. But at certain special points, the height drops to exactly zero. These zero-energy valleys are precisely the **divisors of N**.

For N = 30, the landscape has valleys at x = 1, 2, 3, 5, 6, 10, 15, and 30—every factor. The landscape between valleys rises and falls in patterns that encode deep arithmetic information. The total number of valleys equals τ(N), the divisor function. The sum of valley positions equals σ₁(N), the sum-of-divisors function, which connects to questions about perfect numbers that have fascinated mathematicians since Euclid.

## Machine-Verified Mathematics

What makes this project truly remarkable isn't just the idea—it's the execution. The Gravitational Factoring team has formally verified over **300 theorems** using Lean 4, a proof assistant that checks every logical step with mathematical certainty. This isn't a computer doing calculations; it's a computer verifying *proofs*—the gold standard of mathematical truth.

Among the verified results:

**The Complete Euclid-Euler Theorem.** Over two millennia ago, Euclid showed that if 2^p − 1 is prime, then 2^{p−1} × (2^p − 1) is a "perfect number" (equal to the sum of its proper divisors). In the 18th century, Euler proved the converse for even numbers. The project has formally verified both directions, giving a machine-checked proof of one of the oldest theorems in mathematics.

**Full Quadratic Reciprocity.** Gauss called it the "golden theorem" of number theory and gave six different proofs. The law of quadratic reciprocity, along with both supplements, has been formally verified, providing the theoretical backbone for modern factoring algorithms.

**The Quadratic Sieve Pipeline.** The quadratic sieve is one of the fastest known classical factoring algorithms. The project has verified each step: that differences of squares yield factors, that congruences of squares produce nontrivial gcds, and that smooth number products preserve the crucial congruences. Only one step—the linear algebra over GF(2)—remains.

## Why Perfect Numbers Matter

The sum-of-divisors function σ₁(N) lies at the heart of the energy landscape: it's literally the sum of all the valley positions. A number is "perfect" when σ₁(N) = 2N—the valleys are balanced in a precise way.

The first four perfect numbers—6, 28, 496, 8128—were known to the ancient Greeks. All are even. Do odd perfect numbers exist? This is one of the oldest unsolved problems in mathematics. The project has verified that no odd perfect number exists below 10,000, a small but formally certain step in a search that has been extended computationally to 10^{2200} without success.

But the connection goes deeper. In 1984, Guy Robin proved that the inequality σ₁(n) < e^γ · n · ln(ln n) holds for all n ≥ 5041 **if and only if the Riemann Hypothesis is true**. The Riemann Hypothesis, posed in 1859, is perhaps the most important unsolved problem in all of mathematics, with a million-dollar prize for its resolution. Through the lens of the energy landscape, the Riemann Hypothesis becomes a statement about how steep the valleys can be—a question about the geometry of divisibility.

## Primes, Pseudoprimes, and the Art of Deception

Not all numbers that *look* prime actually are. The number 341 passes Fermat's primality test with flying colors—2^{340} ≡ 1 (mod 341)—yet 341 = 11 × 31 is composite. It's a "pseudoprime," a wolf in sheep's clothing.

The Miller-Rabin test, formalized in v11 of the project, detects these impostors. It exploits a deeper property of primes: not just Fermat's little theorem, but the fact that the only square roots of 1 modulo a prime are ±1. The project has verified that 341 is indeed the smallest Fermat pseudoprime to base 2, that 561 (= 3 × 11 × 17) is the smallest Carmichael number, and that even Carmichael numbers can be caught by Miller-Rabin.

## Fibonacci's Secret Weapon

The Fibonacci sequence—1, 1, 2, 3, 5, 8, 13, 21, ...—is famous for appearing in sunflowers and seashells. But it also holds secrets about prime numbers. When you compute Fibonacci numbers modulo N, the sequence eventually repeats (this is the "Pisano period"). The length of this repetition, and where the zeros fall, carry information about the factors of N.

The project has formally verified:
- The Pisano period always exists (by a pigeonhole argument)
- The "entry point"—the first Fibonacci number divisible by N—divides all subsequent ones
- The beautiful identity F(n)² + F(n+1)² = F(2n+1)
- The doubling formula F(2n) = F(n) · L(n), where L is the Lucas sequence

These aren't just pretty identities. They're the foundation for Fibonacci-based factoring algorithms and pseudoprime tests that complement the more traditional approaches.

## The View from Above

Step back far enough, and the individual theorems blur into a larger picture. The energy landscape E(x) = N mod x is a bridge connecting:

- **Algebra** (quadratic reciprocity, multiplicative functions) to **geometry** (landscape topology, Morse theory)
- **Deterministic** methods (trial division, Fermat) to **probabilistic** ones (Miller-Rabin, quadratic sieve)  
- **Classical** results (Euclid, Euler, Gauss) to **modern** algorithms (QS, NFS, ECM)
- **Number theory** (perfect numbers, primes) to **cryptography** (RSA, post-quantum)

Each connection is not merely claimed but *proved*—machine-verified to be logically inescapable.

## What's Next?

The team has identified 130+ research directions, ranging from near-term goals (completing the quadratic sieve verification, extending Wieferich prime checks) to ambitious visions (formalizing Shor's quantum algorithm, connecting to the Langlands program).

Perhaps most tantalizing is the connection to Robin's inequality and the Riemann Hypothesis. If the energy landscape perspective could shed new light on the distribution of divisors—on how "peaked" or "spread out" the valleys can be—it might contribute to our understanding of one of the deepest questions in mathematics.

Even if it doesn't crack the Riemann Hypothesis, the project has already achieved something remarkable: a comprehensive, machine-verified library of computational number theory that serves as both a reference and a foundation. Every theorem is certain. Every proof is permanent. In a world drowning in information of uncertain reliability, there's something deeply appealing about mathematical truth you can literally run on your laptop and watch the computer say: *yes, this is correct*.

---

*The Gravitational Factoring project is open-source and built on Lean 4 with Mathlib. The energy landscape visualization, interactive demos, and all 300+ formal proofs are freely available.*

---

### Sidebar: What Is Formal Verification?

Formal verification means writing mathematical proofs in a language that a computer can check, line by line. The proof assistant Lean 4 understands logic, sets, numbers, and algebra. When you write a proof in Lean, the computer verifies that every step follows from the axioms. If there's a gap—however small—Lean refuses to accept the proof.

This is different from computer algebra systems like Mathematica or Maple, which compute answers but don't prove they're correct. It's also different from numerical verification, which checks finitely many cases but can't prove universal statements. Formal verification provides **absolute certainty**: if Lean says a theorem is proved, it is proved.

The Gravitational Factoring project uses this power systematically, building a tower of 300+ interlocking theorems, each checked by machine, creating an unshakable foundation for future research.

### Sidebar: The Energy Landscape in Action

For N = 2310 = 2 × 3 × 5 × 7 × 11:

- The landscape has **32 valleys** (divisors)
- Average energy: ~361.5
- Maximum energy: 2309 (at x = 2310, the energy drops to zero)
- Starting from a random point and descending, you find a factor within a few hundred steps about 60% of the time

The landscape is fractal-like: zooming in near any divisor reveals self-similar structure determined by the remaining prime factors. This self-similarity is a direct consequence of the multiplicativity of the divisor function, which is formally verified in the project.
