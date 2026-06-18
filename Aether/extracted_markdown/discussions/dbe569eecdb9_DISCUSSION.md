# The Hidden Primes in Fibonacci Numbers

## A 110-Year-Old Theorem Meets Modern Proof Verification

In 1913, mathematician Robert D. Carmichael proved a remarkable fact about Fibonacci numbers: starting from the 13th term, every Fibonacci number introduces at least one brand-new prime factor — a prime that has never appeared in any earlier Fibonacci number.

Think of it this way: the Fibonacci sequence is a prime factory. Each sufficiently large Fibonacci number brings something genuinely new to the table.

## What Makes a Prime "Primitive"?

The Fibonacci sequence starts 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, ...

Consider F(14) = 377. Its prime factorization is 13 × 29. The prime 13 already appeared earlier as F(7) = 13. But 29 is special — it doesn't divide any earlier Fibonacci number. We call 29 a **primitive prime divisor** of F(14).

Carmichael proved that this phenomenon is universal: for n ≥ 13, F(n) always has at least one such "first appearance" prime.

## Why 13?

The bound n ≥ 13 is tight. For F(12) = 144 = 2⁴ × 3², both prime factors 2 and 3 appeared earlier (2 divides F(3) = 2, and 3 divides F(4) = 3). So F(12) has no primitive divisor. But F(13) = 233 is itself prime and never divided an earlier Fibonacci number, so 233 is a primitive divisor.

## The Key Insight: Entry Points

The proof rests on a beautiful algebraic property of Fibonacci numbers: if a prime p divides F(n), it also divides F(k) for every multiple k of a special number called the **entry point** of p. The entry point α(p) is the smallest positive integer k where p divides F(k).

For example, 7 has entry point 8 (since 7 first divides F(8) = 21). After that, 7 divides F(16), F(24), F(32), ... — every 8th Fibonacci number.

This creates a rhythmic pattern: each prime "beats" at regular intervals through the Fibonacci sequence. A primitive divisor of F(n) is a prime whose rhythm starts exactly at position n.

## Formalizing the Proof

Our project formalizes Carmichael's theorem in Lean 4, a modern proof assistant that can verify mathematical arguments with absolute certainty. The formalization uses two complementary approaches:

**Computational verification** covers F(14) through F(100). For each composite number in this range, we find an explicit primitive prime and verify it using the computer — checking that it divides F(n) but not F(k) for any k < n. This involves checking divisibility for Fibonacci numbers with up to 20 digits.

**Mathematical reasoning** handles the prime case: for prime n, any prime factor of F(n) is automatically primitive, thanks to the GCD identity gcd(F(m), F(n)) = F(gcd(m, n)).

## What Remains

The fully general composite case for n > 100 requires proving that the "primitive part" of F(n) — essentially, the part of F(n) that comes from new primes — is always greater than 1. This follows from exponential growth estimates, but formalizing these estimates requires building significant mathematical infrastructure that doesn't yet exist in the Lean mathematics library.

## Why Does This Matter?

Beyond its intrinsic beauty, Carmichael's theorem has practical implications:

- **Cryptography**: Fibonacci-based pseudorandom generators rely on the unpredictability of Fibonacci prime factors
- **Primality testing**: The theorem guarantees that testing F(n) for primitivity provides meaningful information
- **Number theory**: It's a prototype for "Zsygmondy-type" theorems that apply to many other sequences

Perhaps most importantly, formalizing classical theorems like this one builds confidence in our mathematical knowledge. When a century-old proof is verified by a computer, we know with certainty that the argument is airtight — no hidden gaps, no overlooked edge cases.

The Fibonacci sequence continues to surprise us, even after millennia of study. In every sufficiently large Fibonacci number, there lurks a prime that has never been seen before. Carmichael's theorem guarantees it.
