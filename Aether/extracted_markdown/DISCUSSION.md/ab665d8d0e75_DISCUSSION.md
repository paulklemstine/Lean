# The Hidden Architecture of Fibonacci Numbers

## How a 1913 Theorem About Prime Factors Is Being Verified by Machine

In 1913, Robert D. Carmichael published a remarkable theorem about the Fibonacci sequence — that infinite parade of numbers where each is the sum of the two before it: 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, ...

His theorem says something profound about the prime factors hiding inside these numbers. Starting from F(13) = 233, every Fibonacci number contains at least one "primitive" prime divisor — a prime that divides that particular Fibonacci number but has never appeared as a factor of any earlier one.

It's as if each sufficiently large Fibonacci number carries a unique fingerprint: a prime that belongs to it and no other.

## The Exceptions Tell a Story

The theorem doesn't work for *all* Fibonacci numbers. There are exactly four exceptions:
- F(1) = 1 (no prime factors at all)
- F(2) = 1 (same)
- F(6) = 8 = 2³ (2 already divides F(3) = 2)
- F(12) = 144 = 2⁴ × 3² (both 2 and 3 appeared earlier)

After n = 12, the pattern holds without exception. F(13) = 233 is itself prime — a primitive divisor in the purest sense. F(14) = 377 = 13 × 29, and while 13 appeared as F(7), the prime 29 is new. F(15) = 610 = 2 × 5 × 61, with 61 making its first appearance.

## The Entry Point: A Prime's Fibonacci Address

The proof revolves around a beautiful concept called the **entry point** or "rank of apparition" of a prime. Every prime p has a Fibonacci address — the smallest Fibonacci number it divides. For example:
- The entry point of 2 is 3 (since F(3) = 2)
- The entry point of 3 is 4 (since F(4) = 3)
- The entry point of 5 is 5 (since F(5) = 5)
- The entry point of 7 is 8 (since F(8) = 21 = 3 × 7)

A remarkable identity connects everything: gcd(F(m), F(n)) = F(gcd(m,n)). This means the Fibonacci sequence's divisibility structure perfectly mirrors the divisibility of the indices. If you know which Fibonacci numbers a prime divides, you know it divides exactly those F(n) where n is a multiple of the entry point.

## Why the Prime Case Is Easy

When n itself is prime, the proof is elegant. Every prime factor p of F(n) has an entry point that divides n. Since n is prime, the entry point must be either 1 or n. But F(1) = 1, which no prime divides. So the entry point must be n, meaning p is primitive.

## The Composite Challenge

The composite case — when n is not prime — is far harder. If n = 14, for instance, a prime factor of F(14) could have entry point 1, 2, 7, or 14. Only entry point 14 makes it primitive. The question becomes: must at least one prime factor have entry point exactly n?

This is where Carmichael's deep insight comes in. If every prime factor of F(n) had entry point strictly less than n, each would divide F(d) for some proper divisor d of n. The "primitive part" of F(n) — what remains after removing all such recycled prime contributions — would be trivial. But the exponential growth of Fibonacci numbers makes this impossible for n > 12.

## Machines Enter the Arena

Our formalization in the Lean 4 theorem prover takes a hybrid approach. We developed a computational algorithm that extracts the "coprime part" of F(n) — the portion with no prime factors in common with any F(d) for proper divisors d. This coprime part is computed efficiently using repeated GCD operations.

For composite n from 14 to 10,000, we computationally verified that this coprime part always exceeds 1, guaranteeing a primitive divisor exists. The computation was verified by Lean's `native_decide` tactic, which compiles the check to native machine code and runs it at compile time.

The beautiful thing is that this computation handles numbers with thousands of digits — F(10000) has over 2,000 digits — yet the GCD-based algorithm runs efficiently even at this scale.

## What Remains

For n beyond 10,000, a mathematical argument is needed. The classical proof uses either the "Lifting the Exponent Lemma" for Fibonacci sequences or the cyclotomic factorization of Fibonacci numbers — both substantial pieces of number-theoretic machinery not yet formalized in the Mathlib library.

This gap represents a precise, well-defined challenge for the formalization community. The entry point theory is proved, the computational framework is verified, and the correctness of the approach is established. What remains is formalizing the growth bounds that guarantee the primitive part is nontrivial for all sufficiently large composite n.

## A Window into Number Theory

Carmichael's theorem reveals something deep about the structure of numbers. The Fibonacci sequence, born from the simplest of recurrences, generates an intricate web of divisibility that ensures a steady supply of "new" primes. Each Fibonacci number beyond the twelfth carries within it at least one prime that has never appeared before in the sequence — a mathematical guarantee that the sequence never runs out of novelty.

The ongoing formalization effort transforms this century-old insight from a result we trust to one we can verify, line by line, in a language that leaves no room for ambiguity. In doing so, it illuminates not just the theorem itself, but the infrastructure of ideas — entry points, coprimality, growth bounds — that make number theory so rich and so challenging to pin down with complete rigor.
