# Answers to Open Questions — Version 7

## Questions Answered in v7

### Q1: Is σ₁ evaluation computationally equivalent to factoring?
**Answer: YES** ✓ (Formally proved)

We proved the complete reduction chain:
- **Forward**: σ₁(pq) = 1 + p + q + pq uniquely determines {p,q} (sigma1_determines_factors)
- **Reverse**: Given factors, σ₁ is trivially computable via multiplicativity
- **Approximation**: Even knowing p + q = σ₁(N) - N - 1 suffices (sigma1_gap_reveals_sum)

The reduction runs in O(1) arithmetic operations, making σ₁-EVAL polynomially equivalent to FACTORING.

### Q2: Does F(p)² ≡ 1 (mod p) for all odd primes p ≠ 5?
**Answer: YES** ✓ (Formally proved)

Theorem `fib_sq_mod_prime` proves this using:
- Roots of x² - x - 1 in the algebraic closure of 𝔽_p
- The Binet formula in characteristic p
- Frobenius endomorphism: (a+b)^p = a^p + b^p
- Fermat's little theorem in 𝔽_p*

This gives a Fibonacci compositeness test: if F(n)² mod n ≠ 1, then n is composite.

### Q3: Does the Pisano period satisfy a CRT-like property?
**Answer: YES** ✓ (Formally proved)

For coprime m₁, m₂: the Pisano period of m₁·m₂ divides lcm(π(m₁), π(m₂)).
Proved via induction on the period and the Chinese Remainder Theorem.

### Q4: Is the discrete Laplacian nonneg at divisors of N?
**Answer: YES** ✓ (Formally proved)

At any divisor d > 1 of N, E(d) = 0, so the Laplacian E(d+1) + E(d-1) - 2E(d) = E(d+1) + E(d-1) ≥ 0. This confirms that divisors are genuine local minima in the Morse-theoretic sense.

### Q5: What are the key steps in Euler's direction for perfect numbers?
**Answer: Three formal steps proved** ✓

1. **Key equation**: (2^(k+1) - 1) · σ₁(m) = 2^(k+1) · m
2. **Divisibility**: (2^(k+1) - 1) | m (by coprimality and Gauss's lemma)
3. **Primality**: If m = 2^(k+1) - 1, then σ₁(m) = m + 1 implies m is prime

### Q6: Can the Fibonacci GCD identity be used for factoring?
**Answer: PARTIALLY** ✓

The identity gcd(F(m), F(n)) = F(gcd(m,n)) combined with the Pisano period gives:
- For N = pq, compute π(N) and its divisors d
- Check gcd(F(d), N) for each d | π(N)
- Nontrivial GCDs yield factors

Computational demo successfully factors many semiprimes.

### Q7: Does σ₁ extend to products of 3 or more primes?
**Answer: YES** ✓ (Formally proved)

σ₁(pqr) = 1 + p + q + r + pq + pr + qr + pqr for distinct primes p, q, r.
More generally, σ₁(p^k) = Σᵢ₌₀ᵏ pⁱ and σ₁ is multiplicative for coprime arguments.

### Q8: Is π(p) bounded by p² - 1 for primes?
**Answer: YES** ✓ (Formally proved)

For prime p ≠ 5: π(p) | p² - 1. Proved using the algebraic closure of 𝔽_p and the Frobenius endomorphism showing α^(p²) = α for roots of x² - x - 1.

---

## Questions Partially Answered

### Q9: Can the Euler direction for even perfects be completed?
**Status**: Three of four key steps proved. Remaining: show m = 2^(k+1) - 1 from the key equation without assuming it.

### Q10: What is the density of Fibonacci pseudoprimes?
**Status**: The compositeness test is formalized, but density bounds require Carmichael's primitive divisor theorem (stated but not proved).

---

## Questions Remaining Open

### Q11: Do odd perfect numbers exist?
Verified: no odd perfect number exists below 100 (formally). The general question remains the oldest open problem in mathematics.

### Q12: Can Hurwitz quaternion factoring be made polynomial-time?
Foundation established (norm multiplicativity, Euclidean division), but the descent algorithm and complexity analysis remain.

### Q13: Can persistent homology detect factors from the energy landscape?
Sublevel filtration now fully formalized, but computing actual persistence diagrams in Lean requires additional TDA infrastructure.

### Q14: Is there a sharp phase transition in the energy landscape partition function?
Conjectured β_c = 2/ln(N), but formal proof requires advanced statistical mechanics.

### Q15: Can quantum algorithms exploit quaternion representations?
A Grover-like search over 4-square representations could give √r₄(N) speedup, but formalization of quantum circuits in Lean is not yet mature.
