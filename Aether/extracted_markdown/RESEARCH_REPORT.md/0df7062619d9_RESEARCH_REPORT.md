# Research Report: Carmichael's Primitive Divisor Theorem for Fibonacci Numbers

## Result

We provide a partial formal proof of **Carmichael's Primitive Divisor Theorem** (1913):

> **Theorem** (`fib_primitive_divisor`). For every n ≥ 13, the Fibonacci number F(n) has a *primitive prime divisor*: a prime p such that p | F(n) but p ∤ F(k) for all 0 < k < n.

## What is proved

The formalization in `Speculative/CarmichaelPrimitiveDivisor.lean` establishes:

### Fully proved results

1. **`fib_prime_dvd_gcd'`**: If p | F(n) and p | F(k), then p | F(gcd(n,k)).
   This follows from the Fibonacci GCD identity gcd(F(m), F(n)) = F(gcd(m,n)).

2. **`fib_gt_one`**: F(n) > 1 for n ≥ 3.

3. **`fib_has_prime_factor'`**: F(n) has a prime factor for n ≥ 3.

4. **`non_primitive_to_proper_divisor`**: If a prime p divides both F(n) and F(k) with 0 < k < n, then p divides F(d) for some proper divisor d of n.

5. **`fib_primitive_divisor_prime`**: For **prime** n ≥ 13, every prime factor of F(n) is primitive. This is because for prime n and 0 < k < n, gcd(n,k) = 1, so any common prime divisor of F(n) and F(k) would divide F(1) = 1, which is impossible.

6. **`gcd_fib_lucas_dvd_two`**: The GCD of F(n) and the Lucas companion L(n) = 2·F(n+1) - F(n) divides 2. This is a key structural result connecting the Fibonacci and Lucas sequences.

7. **Computational verification** (`primPart_check`): For all composite n in [13, 10000], the "primitive part" of F(n) is > 1, verified by `native_decide`. This uses a computational procedure that strips away all factors shared with F(d) for proper divisors d of n.

8. **`primPart_implies_primitive`**: If the primitive part of F(n) is > 1, then F(n) has a primitive prime divisor.

### Remaining sorry

The proof has one remaining `sorry` for **composite n > 10000**. This is the deep content of Carmichael's theorem, requiring either:

- The **cyclotomic Fibonacci polynomial** theory: F(n) = ∏_{d|n} Ψ_d where Ψ_n = ∏_{gcd(j,n)=1} (α - ζ_n^j · β), and showing |Ψ_n| > 1 for n ≥ 3 with α,β = (1±√5)/2.

- The **Lifting-the-Exponent Lemma** for Lucas sequences: v_p(F(mn)) = v_p(F(m)) + v_p(n) for primes p with entry point m, combined with Möbius inversion to show the primitive part captures exactly the primes with entry point n.

Neither of these tools is currently available in Mathlib.

## Mathematical significance

Carmichael's theorem is a foundational result in the arithmetic of linear recurrence sequences. It has applications in:

- **Cryptography**: The Pisano period π(m) = lcm of entry points of prime factors of m.
- **Primality testing**: Fibonacci pseudoprimes and Lucas probable primes.
- **Algebraic number theory**: The factorization structure of norms in Z[(1+√5)/2].
- **Tropical geometry**: The valuative structure of Fibonacci sequences connects to tropical curves.

## Proof architecture

```
fib_primitive_divisor
├── [Prime n]: fib_primitive_divisor_prime
│   ├── fib_has_prime_factor' (existence of prime factor)
│   ├── fib_prime_dvd_gcd' (GCD divisibility)
│   └── Nat.Prime.eq_one_or_self_of_dvd (prime divisor structure)
├── [Composite n ≤ 10000]: primPart_implies_primitive + primPart_check
│   ├── primPart_dvd (primitive part divides F(n))
│   ├── primPart_coprime_proper_divs (coprimality with proper divisors)
│   └── native_decide (computational verification)
└── [Composite n > 10000]: sorry
    └── Requires: cyclotomic Fibonacci theory OR LTE for Lucas sequences
```

## Relation to existing work

The project's `Shared/CarmichaelProof.lean` contains related infrastructure including:
- `bridge_lemma`: Reducing primitivity check to proper divisors
- `fib_carmichael_composite`: Composite case with computational verification (also with sorry for n > 10000)

## Future directions

1. **Formalize the Lifting-the-Exponent Lemma** for Fibonacci numbers in Mathlib.
2. **Develop cyclotomic polynomial theory** for Lucas sequences.
3. **Extend computational verification** to larger ranges using parallel native_decide checks.
4. **Connect to tropical geometry** via the valuative interpretation of Fibonacci entry points.
