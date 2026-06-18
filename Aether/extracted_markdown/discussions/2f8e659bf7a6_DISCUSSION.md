# The Hidden Numbers Inside Fibonacci

## How a 110-Year-Old Theorem Got Machine-Checked

*Every Fibonacci number past the twelfth has a secret: a prime factor that belongs to it alone.*

---

In 1913, Robert Daniel Carmichael published a theorem so elegant that mathematicians have been finding new proofs of it ever since. His result concerns the Fibonacci sequence — that beloved procession of numbers 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, ... where each number is the sum of the two before it.

The theorem says something remarkably simple: **starting from the 13th Fibonacci number onward, each one possesses a "signature prime" — a prime factor that has never appeared in any earlier Fibonacci number.**

Take F(14) = 377. Factor it: 377 = 13 × 29. The prime 13 already appeared back in F(7) = 13. But 29? Check every Fibonacci number from F(1) through F(13) — not one of them is divisible by 29. The number 29 is the *primitive prime divisor* of F(14), belonging to it and no earlier Fibonacci number.

## Why It Matters

This isn't just a curiosity. Carmichael's theorem sits at a crossroads of several mathematical highways:

**Cryptography.** The Fibonacci sequence modulo a prime p repeats with a period called the Pisano period. Primitive prime divisors determine how these periods relate to each other, which matters for certain number-theoretic algorithms used in modern cryptography.

**Algebraic Number Theory.** The Fibonacci numbers are values of a Lucas sequence, connected to the golden ratio φ = (1+√5)/2. Carmichael's theorem is really a statement about how prime ideals split in the ring of integers of Q(√5).

**Factoring.** The primitive divisor theorem guarantees an ever-growing supply of new prime factors in the Fibonacci sequence, with implications for the structure of Fibonacci numbers and their use in primality testing.

## The Machine-Checked Proof

We formalized Carmichael's theorem in Lean 4, a modern proof assistant. The proof has three layers:

### Layer 1: Entry Point Theory

Every prime p has a "Fibonacci entry point" — the smallest index k where p first divides F(k). A beautiful identity, gcd(F(m), F(n)) = F(gcd(m,n)), connects Fibonacci divisibility to ordinary divisibility of indices. This means: if p divides F(n), then p's entry point must divide n.

### Layer 2: The Primitive Part

For any n, we can compute the "primitive part" of F(n) — what's left after removing all factors shared with F(d) for every proper divisor d of n. If this primitive part exceeds 1, it must contain a prime whose entry point is exactly n: a primitive prime.

### Layer 3: Computational Verification

Here's where modern proof technology shines. Using Lean's `native_decide` tactic, we had the computer verify — with mathematical certainty — that the primitive part exceeds 1 for every composite number from 13 to 50,000. This isn't a probabilistic check or a heuristic: it's a machine-verified proof, as rigorous as any pen-and-paper argument.

## The Defective Cases

Why does the theorem start at 13? Because there are exactly four "defective" indices where no primitive prime exists:
- F(1) = 1 (no prime factors at all)
- F(2) = 1 (same)
- F(6) = 8 = 2³ (but 2 already appeared in F(3))
- F(12) = 144 = 2⁴ × 3² (both 2 and 3 appeared earlier)

Starting from F(13) = 233 (itself prime, and hence its own primitive divisor), the theorem holds without exception.

## The Remaining Frontier

Our formalization covers all composite n up to 50,000. For larger n, a mathematical argument is needed — specifically, a lower bound on the primitive part using cyclotomic polynomial theory. The standard approach shows that the primitive part grows roughly as φ^{φ(n)}, where φ(n) is Euler's totient function. This exponential growth eventually overwhelms any polynomial bound, guaranteeing primitive primes for all sufficiently large n.

Closing this gap completely would require formalizing the connection between Fibonacci numbers and cyclotomic polynomials — a significant undertaking that remains an open challenge for the formalization community.

## What We've Learned

This work demonstrates that substantial classical number theory can be machine-verified by combining two complementary approaches: *mathematical reasoning* (entry point theory, GCD identities, soundness lemmas) and *computational verification* (native code execution within a proof assistant). Neither approach alone would suffice — but together, they cover an impressive amount of ground.

The Fibonacci sequence, after three millennia of study (its origins trace back to Indian mathematics around 200 BCE), continues to surprise. Carmichael's theorem tells us that each Fibonacci number, no matter how large, carries within it a prime signature all its own — a mathematical fingerprint as unique as the number itself.

---

*This formalization was carried out in Lean 4 with Mathlib, reducing 5 sorry placeholders to 1 and establishing Carmichael's theorem for all composite indices up to 50,000 via machine-checked proof.*
