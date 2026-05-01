# Formalizing Carmichael's Primitive Prime Divisor Theorem for Fibonacci Numbers

## Abstract

We present a formalization in Lean 4 of Carmichael's 1913 theorem: for every integer n ≥ 13, the Fibonacci number F(n) possesses at least one *primitive* prime divisor — a prime p that divides F(n) but does not divide F(k) for any 0 < k < n. Our formalization covers the prime case (via entry point uniqueness), the composite case for n ≤ 10000 (via computational verification with `native_decide`), and establishes the key infrastructure for the infinite tail via the Fibonacci Lifting-the-Exponent Lemma, which gives the exact p-adic valuation formula v_p(F(mk)) = v_p(F(m)) + v_p(k) for odd primes p ≠ 5.

## 1. Introduction

The Fibonacci sequence F(0) = 0, F(1) = 1, F(n+2) = F(n+1) + F(n) is one of the most studied objects in number theory. A fundamental property, discovered by R. D. Carmichael in 1913, states that every Fibonacci number F(n) with n ≥ 13 has at least one prime factor that appears for the *first time* — it divides F(n) but no earlier Fibonacci number.

**Theorem (Carmichael, 1913).** For every n ≥ 13, there exists a prime p such that p | F(n) and p ∤ F(k) for all 0 < k < n.

The exceptions are n ∈ {1, 2, 6, 12}: F(1) = F(2) = 1 (no prime factors), F(6) = 8 = 2³ (only prime 2, with entry point z(2) = 3), and F(12) = 144 = 2⁴·3² (primes 2 and 3, with entry points 3 and 4).

## 2. Mathematical Background

### 2.1 Entry Points

For each prime p, the *entry point* (or *rank of apparition*) z(p) is the smallest positive integer k with p | F(k). Key properties:
- z(p) divides p² − 1 (Wall's theorem)
- p | F(n) if and only if z(p) | n
- gcd(F(m), F(n)) = F(gcd(m, n)) (the Fibonacci GCD identity)

### 2.2 The Lifting-the-Exponent Lemma for Fibonacci

For an odd prime q ≠ 5 with q | F(m) and positive integers m, k:

  v_q(F(mk)) = v_q(F(m)) + v_q(k)

where v_q denotes the q-adic valuation. This is the Fibonacci analogue of the classical Lifting-the-Exponent Lemma and is crucial for understanding the multiplicative structure of Fibonacci numbers.

### 2.3 The Primitive Part

For each n, define the *primitive part* Ψ_n as the product of all prime factors of F(n) whose entry point is exactly n. Carmichael's theorem asserts Ψ_n > 1 for n ≥ 13.

## 3. Formalization Strategy

Our Lean 4 formalization proceeds in three phases:

### Phase 1: The Prime Case
For prime n ≥ 13, every prime factor of F(n) is primitive. This follows because for prime n, the only proper divisors are 1 and n. If q | F(n), then z(q) | n, so z(q) ∈ {1, n}. Since F(1) = 1 has no prime factors, z(q) = n.

This is formalized as `fib_primitive_divisor_prime` in `CarmichaelHelper.lean`.

### Phase 2: Computational Verification (n ≤ 10000)
For composite n with 13 ≤ n ≤ 10000, we define a computable function `primPart n` that strips all factors of F(d) for proper divisors d | n from F(n). If the result exceeds 1, its minimal prime factor is primitive.

The verification `primPart_check` uses `native_decide` to confirm that for all n ∈ [13, 10000], either n is prime or `primPart n > 1`.

### Phase 3: The Infinite Tail (n > 10000)
The Fibonacci LTE (fully proven in the project) provides the key structural tool. For composite n with smallest prime factor p and m = n/p, the quotient Q = F(pm)/F(m) satisfies:
- For odd ℓ ≠ 5 with ℓ | F(m): v_ℓ(Q) = v_ℓ(p), which is 0 for ℓ ≠ p
- This means Q shares very few prime factors with F(m)

Since Q grows exponentially (Q ≈ φ^{m(p-1)} where φ = (1+√5)/2) while the shared factors are bounded polynomially in n, the coprime part of F(n) with respect to all proper-divisor Fibonacci numbers exceeds 1 for n > 10000, yielding a primitive prime divisor.

## 4. Key Lean Definitions

```lean
/-- The primitive part of F(n): F(n) with all factors of F(d) stripped -/
def primPart (n : ℕ) : ℕ :=
  let fn := Nat.fib n
  (propDivs n).foldl (fun r d => stripAllAux r (Nat.fib d) r) fn

/-- Bridge lemma: primitive w.r.t. divisors implies primitive w.r.t. all -/
lemma bridge_lemma (n : ℕ) (hn : 0 < n) (p : ℕ) (hpn : p ∣ Nat.fib n)
    (hdiv : ∀ d, d ∣ n → 0 < d → d < n → ¬(p ∣ Nat.fib d)) :
    ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k)
```

## 5. Discussion: Making a Century-Old Theorem Tangible

### For the General Reader

Imagine the Fibonacci sequence as an ever-growing family tree of numbers: 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, .... Each number is the sum of its two predecessors. When we break these numbers into their prime building blocks, something remarkable happens: starting from the 13th term, every Fibonacci number introduces at least one *brand new* prime factor that has never appeared before.

Think of it like DNA inheritance: while children share most of their genetic material with their parents, every generation introduces at least one novel mutation. Similarly, F(n) shares many prime factors with earlier Fibonacci numbers, but always brings something new to the table (for n ≥ 13).

### Historical Context

Carmichael published this result in 1913, building on earlier work by Fibonacci himself (c. 1202), Lucas (1878), and Zsigmondy (1892). The theorem is a special case of the broader Zsigmondy theorem for Lucas sequences, which itself connects to deep questions about algebraic number fields and cyclotomic polynomials.

## 6. Applications

### 6.1 Primality Testing
The entry point structure of Fibonacci numbers provides a basis for probabilistic primality tests. If n is prime, then z(n) = n (with known exceptions), giving a necessary condition for primality.

### 6.2 Cryptographic Key Generation
Fibonacci-based sequences in finite fields have applications in pseudorandom number generation and certain elliptic curve constructions. Carmichael's theorem guarantees the growth of the prime factor base.

### 6.3 Algebraic Number Theory
The primitive part Ψ_n connects to the evaluation of cyclotomic polynomials at algebraic integers, linking Fibonacci arithmetic to the theory of algebraic number fields.

## 7. Conclusion

Our formalization covers the prime case completely, the composite case up to n = 10000 computationally, and provides the key algebraic infrastructure (the Fibonacci LTE) for the infinite tail. The remaining gap — connecting the LTE to the exact bound on the coprime part for n > 10000 — requires formalizing the growth estimate for the primitive part, which we leave as future work.

## References

1. R. D. Carmichael, "On the numerical factors of the arithmetic forms α^n ± β^n," *Annals of Mathematics*, 1913.
2. K. Zsigmondy, "Zur Theorie der Potenzreste," *Monatshefte für Mathematik*, 1892.
3. The Lean 4 theorem prover, https://leanprover.github.io/
4. Mathlib4, https://github.com/leanprover-community/mathlib4
