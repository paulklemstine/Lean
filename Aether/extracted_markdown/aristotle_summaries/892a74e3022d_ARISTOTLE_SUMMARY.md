# Summary of changes for run 03f6a953-81fb-4610-8bd7-eb5ad2508a44
# Carmichael's Theorem: Primitive Prime Divisors of Composite-Index Fibonacci Numbers

## What was accomplished

I formalized a substantial portion of Carmichael's 1913 theorem in Lean 4, establishing that every Fibonacci number with composite index n > 12 has a primitive prime divisor (a prime p dividing F(n) that doesn't divide F(k) for any 0 < k < n).

### Lean Formalization (`Shared/CarmichaelComposite.lean`)

**Fully proved results:**
- **Bridge Lemma**: Reduces primitivity checking from all k ∈ (0,n) to only proper divisors of n, using Mathlib's `Nat.fib_gcd` (the strong divisibility property gcd(F(m),F(n)) = F(gcd(m,n)))
- **GCD-stripping infrastructure**: `stripFactors` removes shared prime factors; `primResidual` computes the "primitive residual" of F(n) by iteratively stripping factors shared with F(d) for proper divisors d | n
- **Correctness proofs**: `stripFactors_dvd`, `stripFactors_coprime`, `primResidual_dvd`, and the coprimality of the residual with each F(d)
- **Soundness theorem** (`primResidual_sound`): If `primResidual n > 1`, then F(n) has a primitive prime divisor
- **Computational verification** (`finite_check`): Verified via `native_decide` that `primResidual n > 1` for ALL composite n ∈ [13, 100000]
- **Main theorem structure**: The theorem `carmichael_composite_primitive_prime_divisor` splits into the finite case (fully proved) and the tail case

### Entry Point Theory (`Shared/CarmichaelTail.lean`)

**Fully proved results:**
- `prime_dvd_some_fib`: Every prime divides some positive-index Fibonacci number (via Pisano periodicity / pigeonhole)
- `entry_point_dvd`: The entry point (rank of apparition) of a prime divides n whenever p | F(n)
- `fib_two_mul_eq`: The identity F(2m) = F(m) · (F(m-1) + F(m+1))
- `gcd_fib_lucas_dvd_two`: gcd(F(m), F(m-1) + F(m+1)) divides 2

### Remaining sorry

One sorry remains in `carmichael_tail` (the asymptotic case for composite n > 100000). This requires either:
1. The Lifting-the-Exponent Lemma for Fibonacci sequences, or
2. The cyclotomic Fibonacci decomposition F(n) = ∏_{d|n} Ψ(d) with the growth bound Ψ(n) > n

Both involve substantial mathematical infrastructure not currently in Mathlib. The computational verification covers [13, 100000], so only the infinite tail remains.

### Other Deliverables

- **Python demo** (`demos/carmichael_demo.py`): Interactive demonstrations showing primitive primes, entry points, growth bounds, and applications
- **Research paper** (`demos/PAPER.md`): Full mathematical paper with a Scientific American-style discussion section explaining the result's significance, historical context, and future directions

### File structure
```
Shared/
├── CarmichaelComposite.lean  # Main theorem + computational verification
└── CarmichaelTail.lean       # Entry point theory + tail case (1 sorry)
demos/
├── carmichael_demo.py        # Python demonstrations
└── PAPER.md                  # Research paper
```