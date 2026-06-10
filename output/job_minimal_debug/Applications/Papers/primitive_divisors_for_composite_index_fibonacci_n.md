# Carmichael's Theorem on Primitive Divisors of Fibonacci Numbers

## Abstract

We present a formalization effort toward Carmichael's 1913 theorem: for every composite integer n > 12, the Fibonacci number F_n possesses at least one *primitive prime divisor* — a prime that divides F_n but does not divide F_m for any 0 < m < n. We establish the reduction framework using the strong divisibility property of Fibonacci numbers (Nat.fib_gcd in Mathlib) and identify the core algebraic obstacle: proving that the Möbius primitive part Φ_n exceeds rad(n) for all composite n > 12.

## 1. Introduction

The Fibonacci sequence F_0 = 0, F_1 = 1, F_{n+2} = F_n + F_{n+1} has fascinated mathematicians for centuries. One of its most remarkable properties is the *strong divisibility sequence* identity:

**Theorem (Strong Divisibility).** gcd(F_m, F_n) = F_{gcd(m,n)} for all m, n ≥ 0.

This identity, formalized in Mathlib as `Nat.fib_gcd`, implies that the Fibonacci sequence has a rich divisibility structure. In particular, F_m | F_n whenever m | n.

A natural question arises: does F_n have prime factors that are "genuinely new" — primes that don't divide any smaller Fibonacci number? R.D. Carmichael answered this in 1913:

**Theorem (Carmichael, 1913).** For every integer n ≠ 1, 2, 6, 12, the Fibonacci number F_n has at least one *primitive prime divisor* — a prime p such that p | F_n and p ∤ F_m for all 0 < m < n.

## 2. The Entry Point

For a prime p, define the *entry point* (or *rank of apparition*) α(p) as the smallest positive integer k with p | F_k. The entry point always exists (by periodicity of Fibonacci numbers modulo p) and satisfies:

1. **Divisibility:** p | F_n if and only if α(p) | n.
2. **Bound:** α(p) divides p - 1 or p + 1 (depending on p mod 5).

Property (1) follows from the strong divisibility identity: if p | F_n, then p | gcd(F_n, F_{α(p)}) = F_{gcd(n, α(p))}. By minimality of α(p), gcd(n, α(p)) ≥ α(p), which forces α(p) | n.

A prime p is a primitive divisor of F_n if and only if α(p) = n.

## 3. Reduction to Proper Divisors

Our key structural lemma (fully formalized in Lean 4):

**Lemma.** If p is prime, p | F_n, n > 0, and p ∤ F_d for every proper positive divisor d | n with d < n, then p ∤ F_m for all 0 < m < n.

*Proof.* If p | F_m with 0 < m < n, then p | gcd(F_m, F_n) = F_{gcd(m,n)}. Since gcd(m,n) | n and gcd(m,n) ≤ m < n, gcd(m,n) is a proper positive divisor of n, contradicting the hypothesis. □

This reduces Carmichael's theorem to showing: for composite n > 12, there exists a prime p | F_n that doesn't divide F_d for any proper divisor 0 < d | n.

## 4. The Möbius Primitive Part

Define the *Möbius primitive part* of F_n:

Φ_n = ∏_{d | n} F_d^{μ(n/d)}

where μ is the Möbius function. This is always a positive integer for n > 1.

**Key properties:**
- F_n = ∏_{d | n} Φ_d (Möbius inversion)
- Φ_n ≈ φ^{φ(n)} where φ = (1+√5)/2 is the golden ratio and φ(n) is Euler's totient
- For odd prime p with p | Φ_n and p ∤ n: the entry point α(p) = n

The last property is crucial: it says that primes dividing Φ_n but not n are automatically primitive divisors. The "non-primitive" contribution to Φ_n from primes dividing n is bounded by rad(n) ≤ n.

## 5. Why n = 12 Is the Last Exception

For n = 12 = 2² × 3:
- F_12 = 144 = 2⁴ × 3²
- α(2) = 3 ≠ 12, α(3) = 4 ≠ 12
- Φ_12 = F_12 × F_2 / (F_4 × F_6) = 144 × 1 / (3 × 8) = 6 = 2 × 3
- Both prime factors of Φ_12 divide n = 12
- So no primitive divisor exists!

For n = 14 = 2 × 7:
- F_14 = 377 = 13 × 29
- Φ_14 = F_14 × F_1 / (F_2 × F_7) = 377 / 13 = 29
- 29 ∤ 14, so 29 is a primitive divisor ✓

## 6. Applications

### 6.1 Cryptographic Pseudorandom Sequences
The existence of primitive divisors ensures that Fibonacci-based pseudorandom generators have expanding prime support, a key property for security analysis.

### 6.2 Algebraic Number Theory
Carmichael's theorem is a special case of Zsygmondy's theorem for Lucas sequences, which has deep connections to cyclotomic polynomials and algebraic number fields.

### 6.3 Primality Testing
The primitive divisor structure of Fibonacci numbers underpins Lucas-based primality tests (e.g., the Lucas-Lehmer test for Mersenne primes).

## 7. Discussion: Making Deep Mathematics Accessible

Imagine the Fibonacci sequence as a growing tree. Each Fibonacci number F_n is like a branch, and its prime factors are the leaves on that branch. Carmichael's theorem says something remarkable: every branch beyond the 12th (for composite indices) sprouts at least one *entirely new* leaf — a prime number that has never appeared on any previous branch.

This is surprising because Fibonacci numbers have deep internal connections. F_6 = 8 divides F_12 = 144, F_18 = 2584, and indeed every F_{6k}. So you might expect that by the time you reach F_100, all its prime factors would be "recycled" from smaller Fibonacci numbers. But Carmichael proved this never happens (after n = 12).

The proof relies on two beautiful ideas:
1. **Strong divisibility**: The GCD of any two Fibonacci numbers is itself a Fibonacci number. This creates a lattice structure among Fibonacci numbers that mirrors the divisibility of their indices.
2. **Growth vs. structure**: While many primes in F_n come from smaller Fibonacci numbers (via the divisibility lattice), the exponential growth of Fibonacci numbers (~φⁿ) always outpaces the "recycling" capacity of the lattice, forcing new primes to appear.

## References

1. R.D. Carmichael, "On the numerical factors of the arithmetic forms αⁿ ± βⁿ," *Annals of Mathematics*, 15(1), 30–70, 1913.
2. Y. Bilu, G. Hanrot, P.M. Voutier, "Existence of primitive divisors of Lucas and Lehmer numbers," *J. Reine Angew. Math.* 539, 75–122, 2001.
3. M. Ward, "The intrinsic divisors of Lehmer numbers," *Annals of Mathematics*, 62(2), 230–236, 1955.
4. P. Ribenboim, *My Numbers, My Friends*, Springer, 2000.
