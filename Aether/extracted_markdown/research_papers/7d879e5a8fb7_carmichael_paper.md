# Primitive Prime Divisors of Composite-Index Fibonacci Numbers: A Formal Verification

## Abstract

We present a partially formalized proof of Carmichael's theorem for composite-index Fibonacci numbers: for every composite natural number n > 12, the Fibonacci number F_n possesses at least one *primitive prime divisor* — a prime p dividing F_n that does not divide F_k for any 0 < k < n. Our formalization in Lean 4 combines two approaches: (1) a computational verification using `native_decide` that exhaustively checks the primitive-part condition for all composite n in [13, 50000], and (2) a Lifting-the-Exponent Lemma for Fibonacci numbers that provides the algebraic machinery for the theoretical extension. The growth bound for n > 50000 remains as an open formalization challenge requiring the theory of Fibonacci cyclotomic polynomials.

## 1. Introduction

The Fibonacci sequence F_0 = 0, F_1 = 1, F_{n+2} = F_{n+1} + F_n is one of the most studied objects in number theory. A *primitive prime divisor* of F_n is a prime p such that p | F_n but p does not divide F_k for all 0 < k < n. In 1913, R. D. Carmichael proved that F_n has a primitive prime divisor for every n > 12, with the only exceptions being n in {1, 2, 6, 12}.

## 2. Proof Structure

### 2.1 Computational Verification (n <= 50000)

For each composite n, we compute `primPart(n)` by stripping all prime factors shared between F_n and F_d for every proper divisor d | n. If the result exceeds 1, a primitive prime exists. This is verified via `native_decide` in chunks of 10000.

### 2.2 Lifting the Exponent Lemma

For odd prime p != 5 with p | F_m: v_p(F_{mk}) = v_p(F_m) + v_p(k). This is fully proved in Lean 4 and controls how prime valuations grow across Fibonacci multiples.

### 2.3 Growth Bound (n > 50000)

The Fibonacci cyclotomic factor Phi_n approximately equals phi^{phi(n)}, which for composite n > 50000 vastly exceeds n, forcing the existence of primitive primes. This step requires real analysis bounds not yet formalized.

## 3. Discussion

Carmichael's theorem reveals a fundamental self-renewal property of Fibonacci numbers: composite indices always generate genuinely new prime factors. The exceptions at n = 1, 2, 6, 12 arise because F_n is too small to accommodate a new prime beyond those inherited from smaller divisors.

The connection to the golden ratio phi = (1+sqrt(5))/2 is deep: the exponential growth F_n ~ phi^n / sqrt(5) guarantees that for large composite n, the Fibonacci number is simply too large to be built entirely from "inherited" primes.

## 4. Applications

1. **Finiteness of perfect Fibonacci numbers**: Carmichael's theorem constrains the arithmetic structure of Fibonacci numbers, providing evidence that no Fibonacci number beyond F_1 = 1 can be perfect.
2. **Primality testing**: The entry point function alpha(p) provides a Fibonacci-based compositeness test.
3. **Diophantine equations**: Primitive divisors control solutions to F_m = F_n * x^k.
