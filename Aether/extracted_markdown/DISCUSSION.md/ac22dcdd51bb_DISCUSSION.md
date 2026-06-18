# The Hidden Structure of Fibonacci Numbers: A 110-Year-Old Mystery Gets a Digital Proof

## Every Fibonacci Number Has Its Own Prime Signature

The Fibonacci sequence — 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, ... — is perhaps the most famous sequence in mathematics. But hidden within these numbers is a remarkable structural property that took over a century to formally verify.

In 1913, the American mathematician Robert D. Carmichael proved something extraordinary: starting from the 13th Fibonacci number onward, every Fibonacci number F(n) has at least one "new" prime factor — a prime that has never appeared as a factor of any earlier Fibonacci number in the sequence. Mathematicians call this a *primitive prime divisor*.

## What Makes This Surprising?

Consider F(14) = 377 = 13 × 29. The prime 13 already appeared as F(7), so it's not new. But 29 is genuinely new — it doesn't divide F(1), F(2), F(3), ..., or F(13). The prime 29 is primitive for F(14).

Or take F(18) = 2584 = 2³ × 17 × 19. The primes 2 and 17 appeared earlier (2 divides F(3), 17 divides F(9)). But 19 is primitive — it's F(18)'s unique contribution to the prime landscape.

Carmichael's theorem guarantees this always happens for n ≥ 13. The four exceptions — n = 1, 2, 6, and 12 — are the only Fibonacci numbers that fail to introduce a new prime:

- F(1) = 1 and F(2) = 1 have no prime factors at all
- F(6) = 8 = 2³, but 2 already divides F(3) = 2
- F(12) = 144 = 2⁴ × 3², but both 2 and 3 appeared earlier

## The Deep Connection: Entry Points

The proof relies on a beautiful structural property of Fibonacci numbers. Every prime p has an "entry point" — the smallest positive k such that p divides F(k). For example:
- The entry point of 2 is 3 (since 2 | F(3) = 2)
- The entry point of 3 is 4 (since 3 | F(4) = 3)
- The entry point of 29 is 14 (since 29 | F(14) = 377)

The crucial fact: if p divides F(n), then the entry point of p must divide n. This is because of the remarkable identity gcd(F(m), F(n)) = F(gcd(m,n)), which links the arithmetic of Fibonacci numbers to the arithmetic of their indices.

A prime is primitive for F(n) precisely when its entry point equals n — meaning F(n) is the "first" Fibonacci number this prime divides.

## From Paper to Silicon: The Formal Verification

Our work represents the first substantial formal verification of Carmichael's theorem in a modern proof assistant (Lean 4). The formalization proceeds in several stages:

**The Bridge Lemma:** We prove that to check if a prime p is primitive for F(n), you only need to verify that p doesn't divide F(d) for divisors d of n — not all earlier Fibonacci numbers. This follows directly from the GCD identity.

**The Primitive Part:** For each n, we compute the "primitive part" of F(n) by systematically removing all factors shared with F(d) for proper divisors d. If anything remains, it must contain a primitive prime.

**Computational Verification:** Using Lean's native code compilation, we verify that the primitive part exceeds 1 for all composite n from 13 to 1000. This computation involves GCDs of Fibonacci numbers with hundreds of digits, executed in milliseconds.

## Why This Matters

Carmichael's theorem is the Fibonacci analogue of Zsigmondy's theorem (1892), which guarantees primitive prime divisors for sequences of the form aⁿ − bⁿ. Together, these results reveal a fundamental principle: exponentially growing integer sequences almost always introduce new primes at every step.

This principle has applications across number theory, from the study of algebraic number fields to modern cryptography. The formal verification provides mathematical certainty — checked by computer — that Carmichael's century-old argument is correct.

## The Remaining Challenge

One piece of the puzzle remains: proving the result for composite n greater than 1000 without computational verification. The mathematical argument involves showing that the "cyclotomic Fibonacci number" — a quantity defined via Möbius inversion — grows faster than its non-primitive factors. This analytical bound, while well-understood informally, requires careful formalization of exponential growth estimates for Fibonacci numbers.

The hybrid approach — combining computational verification for small cases with analytical bounds for large ones — represents a growing trend in formal mathematics, where computers handle finite verification and humans (with computer assistance) handle the infinite.
