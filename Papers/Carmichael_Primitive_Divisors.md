# Toward a Complete Formalization of Carmichael's Primitive Divisor Theorem for Fibonacci Numbers

## Abstract

We report on the formal verification in Lean 4 of Carmichael's 1913 theorem: for every integer n > 12, the Fibonacci number F(n) possesses a *primitive prime divisor* — a prime p that divides F(n) but does not divide F(k) for any 0 < k < n. Our formalization covers the prime case completely and verifies the composite case computationally for all n ≤ 50,000 using `native_decide`. The remaining asymptotic case (composite n > 50,000) is reduced to a single growth bound on cyclotomic Fibonacci polynomials, connecting the project's verified Lifting-the-Exponent Lemma for Fibonacci sequences with classical bounds on Lucas sequence cyclotomy.

## 1. Introduction

The Fibonacci sequence F(0) = 0, F(1) = 1, F(n+2) = F(n) + F(n+1) satisfies a remarkable divisibility property: gcd(F(m), F(n)) = F(gcd(m,n)) for all m, n ≥ 0. This *strong divisibility* property, formalized in Mathlib as `Nat.fib_gcd`, makes the Fibonacci sequence a prototypical example of a *divisibility sequence* in algebraic number theory.

Carmichael (1913) proved that this structure forces every sufficiently large Fibonacci number to introduce at least one "new" prime factor:

**Theorem (Carmichael).** For every n > 12, there exists a prime p such that p | F(n) and p ∤ F(k) for all 0 < k < n. Such a prime p is called a *primitive prime divisor* of F(n).

The bound n > 12 is sharp: F(12) = 144 = 2⁴ · 3² has no primitive divisor, since 2 | F(3) and 3 | F(4).

This result is a cornerstone of the arithmetic of linear recurrences and a precursor to Zsygmondy-type theorems for Lucas and Lehmer sequences. It has applications in cryptography (Fibonacci-based pseudorandom generators), coding theory (Zeckendorf representations), and the study of algebraic number fields (cyclotomic factors of Lucas polynomials).

## 2. Formalization Strategy

### 2.1 Entry Point Theory

For any prime p, the *entry point* (or *rank of apparition*) α(p) is the smallest positive integer k such that p | F(k). By the strong divisibility property:

- p | F(n) if and only if α(p) | n
- If p | F(n) and p | F(k), then p | F(gcd(n,k))

These facts reduce the primitivity check from "p ∤ F(k) for all 0 < k < n" to "p ∤ F(d) for all proper divisors d of n" — a finite verification. This reduction is formalized in `bridge_lemma`.

### 2.2 The Prime Case

When n itself is prime, the only proper divisors of n are 1 and n. Since F(1) = 1 has no prime factors, every prime factor of F(n) is automatically primitive. This elegant argument is formalized in `fib_primitive_divisor_prime` (in `CarmichaelHelper.lean`).

### 2.3 The Composite Case

For composite n ≥ 13, the proof is substantially more involved. Our approach uses:

1. **Computational verification** via `native_decide`: A function `primPart(n)` iteratively strips all common factors between F(n) and F(d) for each proper divisor d | n. If `primPart(n) > 1`, its smallest prime factor is primitive. We verify `primPart(n) > 1` for all composite n ∈ [13, 50000].

2. **Algebraic infrastructure**: The project includes a complete formal proof of the Lifting-the-Exponent Lemma for Fibonacci numbers:
   - For odd prime p ≠ 5 with p | F(m): v_p(F(mk)) = v_p(F(m)) + v_p(k)
   
   This is proved via a careful mod-p² analysis of the quotient F(mk)/F(m).

3. **Cyclotomic growth bound** (remaining step): For composite n > 50,000, the cyclotomic Fibonacci number Ψ_n = ∏_{d|n} F(d)^{μ(n/d)} satisfies Ψ_n ≥ φ^{φ(n)} - 1 > rad(n), where φ = (1+√5)/2 is the golden ratio, φ(n) is Euler's totient, and rad(n) is the radical of n. Since any prime dividing Ψ_n that is coprime to n must have entry point exactly n, this bound guarantees a primitive prime.

## 3. The Lifting-the-Exponent Lemma

The project's formalization of the Fibonacci LTE (approximately 280 lines of Lean 4) is a highlight. The key steps are:

1. **Congruence**: For p | F(m), the quotient Q(m,k) = F(mk)/F(m) satisfies Q(m,k) ≡ k · F(m-1)^{k-1} (mod p).

2. **Prime step**: v_p(Q(m,p)) = 1, proved by showing Q(m,p) ≡ p · F(m-1)^{p-1} (mod p²) and using F(m-1) ⊥ p.

3. **Coprime step**: When p ∤ k, the quotient Q(m,k) is coprime to p, so v_p(F(mk)) = v_p(F(m)).

4. **Induction**: Combining these via the factorization k = p^t · v with p ∤ v yields the full formula.

## 4. Computational Verification

The `primPart` function and its correctness proof are the computational backbone:

```lean
def primPart (n : ℕ) : ℕ :=
  let fn := Nat.fib n
  (propDivs n).foldl (fun r d => stripAllAux r (Nat.fib d) r) fn
```

We prove:
- `primPart_dvd`: primPart(n) | F(n)
- `primPart_coprime_proper_divs`: if primPart(n) > 1, its smallest prime factor is coprime to F(d) for every proper divisor d
- `primPart_implies_primitive`: primPart(n) > 1 implies F(n) has a primitive prime divisor

The verification `primPart_check` confirms primPart(n) > 1 for all composite n ∈ [13, 50000] via `native_decide`.

## 5. The Remaining Step

The single remaining sorry in the formalization is:

> For composite n > 50,000, prove `1 < primPart n`.

This reduces to showing that the cyclotomic Fibonacci number Ψ_n > rad(n) for composite n > 12. The standard proof uses:

1. The product formula Ψ_n = ∏_{gcd(j,n)=1} (φ - ζ_n^j · ψ) where ζ_n = e^{2πi/n}
2. The bound |φ - ψ · e^{iθ}| = √(3 + 2cos θ) ≥ 1
3. The totient inequality φ(n) ≥ √(n/2) for n > 6
4. Combining: |Ψ_n| ≥ φ^{φ(n)} - 1 > n ≥ rad(n)

Formalizing this requires approximately 500 lines of infrastructure: Möbius inversion for Fibonacci p-adic valuations, bounds on the golden ratio raised to Euler's totient, and the inequality φ^6 > 17 > rad(n)/n for the critical base cases.

## 6. Discussion: Making Deep Number Theory Accessible

### The Beauty of Primitive Divisors

Imagine the Fibonacci sequence as an infinite family tree. Each generation F(n) introduces new members — prime factors that belong exclusively to that generation. Carmichael's theorem says this "fresh blood" never stops flowing: from generation 13 onward, every Fibonacci number brings at least one entirely new prime to the table.

This is surprising because Fibonacci numbers are built entirely from their predecessors. F(100) = F(99) + F(98), so you might expect all its prime factors to come from earlier terms. The strong divisibility property gcd(F(m), F(n)) = F(gcd(m,n)) creates an intricate web of shared factors. Yet despite this sharing, new primes always emerge.

### Historical Context

Carmichael's 1913 paper appeared in the *Annals of Mathematics*, during a golden age of number theory that also saw Ramanujan's work on partition functions and Hardy-Littlewood's circle method. The result was later generalized by Zsygmondy (for a^n - b^n), Birkhoff-Vandiver, and Bilu-Hanrot-Voutier (for Lucas and Lehmer sequences).

### Connections to Modern Mathematics

The theorem connects to:
- **Cyclotomic fields**: Ψ_n is the norm of φ^n - 1 in Q(ζ_n, √5)
- **Algebraic K-theory**: Primitive divisors appear in the study of torsion in K-groups
- **Dynamics**: Entry points correspond to periodic orbits of the Fibonacci map mod p
- **Coding theory**: Fibonacci codes with primitive-divisor-guaranteed error detection

## 7. Future Directions

1. **Complete the cyclotomic bound**: Formalize Ψ_n ≥ φ^{φ(n)} - 1 using Mathlib's cyclotomic polynomial infrastructure
2. **Extend to Lucas sequences**: Generalize to U_n(P,Q) for arbitrary parameters
3. **Effective bounds**: Formalize the Bilu-Hanrot-Voutier classification of all Lucas/Lehmer numbers without primitive divisors

## References

1. R.D. Carmichael, "On the numerical factors of the arithmetic forms α^n ± β^n," *Annals of Mathematics*, 15 (1913), pp. 30–70.
2. K. Zsygmondy, "Zur Theorie der Potenzreste," *Monatshefte für Mathematik*, 3 (1892), pp. 265–284.
3. Yu. Bilu, G. Hanrot, P.M. Voutier, "Existence of primitive divisors of Lucas and Lehmer numbers," *Journal für die reine und angewandte Mathematik*, 539 (2001), pp. 75–122.
4. Mathlib Contributors, "Mathlib: the math library for Lean 4," https://github.com/leanprover-community/mathlib4
