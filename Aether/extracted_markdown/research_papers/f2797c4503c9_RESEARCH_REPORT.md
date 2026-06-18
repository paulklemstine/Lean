# Research Report: Carmichael's Primitive Divisor Theorem for Fibonacci Numbers

## Result

We partially formalize Carmichael's Primitive Divisor Theorem (1913):

> **Theorem.** For every integer n ≥ 13, the Fibonacci number F(n) has a **primitive prime divisor**: a prime p such that p divides F(n) but p does not divide F(k) for any 0 < k < n.

## Formalization Status

### Proved
1. **GCD identity** (`fib_prime_dvd_gcd'`): If p | F(n) and p | F(k), then p | F(gcd(n,k)). This follows directly from the Mathlib identity `Nat.fib_gcd`.

2. **Growth bound** (`fib_gt_one`): F(n) > 1 for n ≥ 3.

3. **Prime factorization** (`fib_has_prime_factor'`): F(n) has a prime factor for n ≥ 3.

4. **Non-primitive reduction** (`non_primitive_to_proper_divisor`): If a prime p divides F(n) and is not primitive, then p divides F(d) for some proper divisor d of n.

5. **Prime index case** (`fib_primitive_divisor_prime_index`): For prime n ≥ 3, every prime factor of F(n) is automatically primitive. This covers infinitely many values of n.

### Remaining Sorry
The **composite case** of Carmichael's theorem remains unproved. When n ≥ 13 is composite, showing that F(n) has a prime factor not dividing F(d) for any proper divisor d | n requires:
- The theory of **Fibonacci entry points** (the smallest m > 0 with p | F(m) for each prime p)
- The **lifting-the-exponent lemma** for Fibonacci numbers
- Bounds on the **primitive part** Ψ_n = ∏_{α(p)=n} p^{v_p(F(n))}

None of this infrastructure currently exists in Mathlib.

## Mathematical Background

### The Entry Point
For any prime p, the **entry point** (or rank of apparition) α(p) is the smallest positive integer m such that p | F(m). Key properties:
- α(p) exists for every prime p (by periodicity of Fibonacci mod p)
- If p | F(n), then α(p) | n (follows from `Nat.fib_gcd`)
- p is a primitive divisor of F(n) if and only if α(p) = n

### Why the Prime Case is Easy
If n is prime, its only positive divisors are 1 and n. Since F(1) = 1, no prime divides F(1). So for any prime p | F(n), we have α(p) | n and α(p) > 1, forcing α(p) = n.

### Known Exceptions
The only values of n for which F(n) has **no** primitive prime divisor are:
- n = 1, 2 (F(n) = 1, no prime factors)
- n = 6 (F(6) = 8 = 2³, and α(2) = 3)
- n = 12 (F(12) = 144 = 2⁴ · 3², and α(2) = 3, α(3) = 4)

## Significance

Carmichael's theorem is a foundational result in the arithmetic of linear recurrence sequences. It implies:
- The Fibonacci sequence generates infinitely many essentially new primes
- For n ≥ 13, F(n) always introduces at least one prime that has never appeared as a factor of any earlier Fibonacci number at a compatible index
- It is a precursor to Zsygmondy's theorem and the broader theory of primitive divisors in algebraic number theory

## References

- Carmichael, R.D. (1913). "On the numerical factors of the arithmetic forms αⁿ ± βⁿ." *Annals of Mathematics*, 15(1), 30-70.
