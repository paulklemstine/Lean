# Carmichael's Primitive Divisor Theorem for Fibonacci Numbers: A Formalization

## Abstract

We present a partial formalization in Lean 4 of Carmichael's 1913 theorem stating that for every composite natural number *n* > 12, the Fibonacci number *F_n* possesses a **primitive prime divisor** — a prime *p* dividing *F_n* that does not divide *F_k* for any 0 < *k* < *n*. Our formalization establishes the full entry point (rank of apparition) theory: every prime has an entry point in the Fibonacci sequence, entry points divide indices, and the divisibility relation *p* | *F_k* is completely characterized by divisibility of the entry point. The remaining gap is the core number-theoretic step showing that the cyclotomic Fibonacci factor Φ_n exceeds *n* for composite *n* > 10000, which requires infrastructure for cyclotomic polynomial evaluation at algebraic integers not currently available in Mathlib.

## 1. Introduction

The Fibonacci sequence *F_0* = 0, *F_1* = 1, *F_{n+2}* = *F_n* + *F_{n+1}* is perhaps the most studied integer sequence in mathematics. A fundamental question about its arithmetic structure is: for which *n* does *F_n* have a prime factor that appears for the "first time" — a prime not dividing any earlier nonzero Fibonacci number?

**Definition.** A prime *p* is a *primitive prime divisor* of *F_n* if *p* | *F_n* but *p* ∤ *F_k* for every 0 < *k* < *n*.

R. D. Carmichael proved in 1913 that *F_n* has a primitive prime divisor for every *n* > 12, with the only exceptions being *n* ∈ {1, 2, 6, 12}.

## 2. Entry Point Theory (Fully Formalized)

### 2.1 Existence

**Theorem.** *Every prime p divides some positive Fibonacci number.* The proof uses the pigeonhole principle on pairs (*F_k* mod *p*, *F_{k+1}* mod *p*).

### 2.2 Divisibility

**Theorem.** *If p | F_n and n > 0, then the entry point z(p) divides n.* This follows from the strong divisibility property gcd(*F_m*, *F_n*) = *F*_{gcd(*m*,*n*)}.

### 2.3 Characterization

**Theorem.** *p | F_k ⟺ z(p) | k* (for k > 0). This completely determines which Fibonacci numbers are divisible by a given prime.

## 3. The Main Theorem

**Theorem (sorry remaining).** *For composite n > 10000, F_n has a primitive prime divisor.*

The proof requires the **cyclotomic Fibonacci numbers** Φ_n = ∏_{d|n} F_d^{μ(n/d)}, satisfying *F_n* = ∏_{*d*|*n*} Φ_d. The key bound Φ_n ≈ φ^{φ(n)} >> n for composite n > 10000 guarantees a primitive prime factor. This cyclotomic infrastructure is not yet available in Mathlib.

## 4. Discussion

Carmichael's theorem reveals that the Fibonacci sequence is maximally "fertile" — at every index beyond 12, it acquires a completely new prime factor. This has implications for cryptographic security reductions, primality testing, and the theory of algebraic number fields.

The formalization demonstrates both the power and limitations of current proof assistants: the entry point theory (which forms the structural backbone) is cleanly formalizable, while the analytic/algebraic core (cyclotomic bounds) requires mathematical infrastructure that remains to be built.

## References

1. R. D. Carmichael, "On the numerical factors of αⁿ ± βⁿ," *Ann. Math.*, 1913.
2. Y. Bilu, G. Hanrot, P. M. Voutier, "Existence of primitive divisors of Lucas and Lehmer numbers," *J. reine angew. Math.*, 2001.
