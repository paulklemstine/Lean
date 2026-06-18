# Research Report: Fibonacci Growth Bounds and Carmichael's Primitive Divisor Theorem

## Summary

This project investigates Carmichael's theorem on primitive prime divisors of Fibonacci numbers. The central question is: for composite n ≥ 13, does F(n) have a "primitive" prime divisor — a prime p dividing F(n) that does not divide F(k) for any 0 < k < n?

### Key Finding: The Growth Bound Conjecture is FALSE

The proposed theorem that for composite n ≥ 13:
```
F(n) > ∏_{d | n, 0 < d < n} F(d)
```
is **false**. A counterexample is n = 24:
- Proper divisors of 24: {1, 2, 3, 4, 6, 8, 12}
- Product: F(1)·F(2)·F(3)·F(4)·F(6)·F(8)·F(12) = 1·1·2·3·8·21·144 = **145,152**
- F(24) = **46,368** < 145,152

Additional counterexamples include n = 30, 36, 40, and many other highly composite numbers. The product over all proper divisors grows faster than F(n) when n has many divisors.

### What IS True: Carmichael's Theorem

Despite the growth bound being false, **Carmichael's theorem is true**: for every n ≥ 13, F(n) has a primitive prime divisor. The correct approach uses the *primitive part* (Möbius product):

Ψ(n) = ∏_{d|n} F(d)^{μ(n/d)}

which satisfies Ψ(n) > 1 for all n ∉ {1, 2, 6, 12}. Any prime factor of Ψ(n) with entry point n is a primitive prime divisor.

## Formal Results

### Proved Theorems

1. **Counterexample** (`growth_bound_counterexample`): F(24) < F(1)·F(2)·F(3)·F(4)·F(6)·F(8)·F(12), disproving the growth bound conjecture.

2. **Fibonacci submultiplicativity** (`fib_submultiplicative`): F(a+b) ≥ F(a)·F(b) for a, b ≥ 1.

3. **Power bound** (`fib_power_bound`): F(k·m) ≥ F(m)^k for m, k ≥ 1.

4. **Double squaring** (`fib_double_gt_sq`): F(2m) > F(m)² for m ≥ 2.

5. **Lucas-Fibonacci identity** (`fib_double_eq_mul_lucas`): F(2m) = F(m) · L(m) where L(m) = F(m-1) + F(m+1).

6. **GCD property** (`gcd_lucas_fib_dvd_two`): gcd(L(m), F(m)) | 2.

7. **Lucas odd parity** (`lucas_odd_of_not_three_dvd`): L(m) is odd when 3 ∤ m.

8. **Carmichael for n = 2q** (`carmichael_double_prime`): For q prime ≥ 7, F(2q) has a primitive prime divisor. Proof: L(q) is odd and ≥ 3, so it has an odd prime factor r coprime to F(q). Since F(2q) = F(q)·L(q), r | F(2q). The entry point of r must be 2q (the only possibility among divisors of 2q).

9. **Prime case** (`fib_primitive_divisor_prime`, from existing code): For n prime ≥ 13, F(n) has a primitive prime divisor.

### Open Sorry: General Composite Case

The full composite case of Carmichael's theorem — for **arbitrary** composite n ≥ 13 — remains an open formalization challenge. The standard proof requires:
- Lifting-the-exponent lemma for Fibonacci numbers
- Properties of cyclotomic polynomials evaluated at the golden ratio
- Careful analysis of the Möbius product Ψ(n)

## Mathematical Background

### Entry Point Theory

For a prime p, the *entry point* (or *rank of apparition*) α(p) is the smallest positive k with p | F(k). Key properties:
- p | F(n) if and only if α(p) | n
- If p | F(n) and p | F(m), then p | F(gcd(m,n))
- p is a primitive prime divisor of F(n) iff α(p) = n

### Why the Growth Bound Fails

For n with many proper divisors, the product ∏ F(d) can exceed F(n). The issue is that divisors contribute multiplicatively while F(n) grows only exponentially in n. For highly composite n (like n = 24 with 7 proper divisors), the product of F(d) values dominates.

However, this does NOT prevent Carmichael's theorem from being true. The LCM (rather than product) of F(d) values is much smaller, and the primitive part Ψ(n) captures the ratio F(n) / (contribution from non-primitive primes), which is > 1.

## Files

- `Shared/FibGrowth.lean`: Counterexample and correct growth lemmas
- `Shared/CarmichaelCompositeHelper.lean`: Lucas number theory and n=2q case
- `Shared/CarmichaelComposite.lean`: Framework for Carmichael's theorem (composite case sorry)
- `Shared/CarmichaelHelper.lean`: Prime case of Carmichael's theorem
- `Shared/Fib_gcd_identity.lean`: GCD identities for Fibonacci numbers

## References

- Carmichael, R.D. (1913). "On the numerical factors of the arithmetic forms αⁿ ± βⁿ"
- Yabuta, M. (2001). "A simple proof of Carmichael's theorem on primitive divisors"
- Bilu, Hanrot, Voutier (2001). "Existence of primitive divisors of Lucas and Lehmer numbers"
