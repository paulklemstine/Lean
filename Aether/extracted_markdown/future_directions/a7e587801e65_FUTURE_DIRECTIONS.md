# Future Research Directions

## Overview

This document outlines breakthrough research opportunities opened by the formal verification of Euler's shape theorem for odd perfect numbers and the Euclid-Euler classification of even perfect numbers.

---

## Direction 1: Formal Lower Bounds on Odd Perfect Numbers

### Hypothesis
Any odd perfect number n must satisfy n > 10^36.

### Proof Strategy
1. **Extend Euler's theorem**: By our formalization, n = q^(4k+1) · m² with q ≡ 1 (mod 4).
2. **Bound the special prime**: Show q ≥ 5 (since q ≡ 1 mod 4 and q is prime).
3. **Bound the number of prime factors**: Use the constraint σ₁(n)/n = 2 to derive that n must have many distinct prime factors (at least 9).
4. **Combine bounds**: Each odd prime factor ≥ 3, and we need enough factors to make σ₁(n)/n = 2.

### Lean Theorem Statement
```lean
theorem odd_perfect_lower_bound {n : ℕ} (hperf : Nat.Perfect n) (hodd : Odd n) :
    n > 10^36 := by sorry
```

### Cross-Domain Connection
Connect to computational number theory — the bounds inform search algorithms.

### Priority: HIGH

---

## Direction 2: Multiperfect Number Structure

### Hypothesis
k-perfect numbers (σ₁(n) = kn) for k ≥ 3 admit structural constraints analogous to Euler's theorem.

### Proof Strategy
1. Extend the 2-adic valuation analysis to v₂(kn) for general k.
2. For k = 3 (triperfect): σ₁(n) = 3n requires v₂(σ₁(n)) = v₂(3n), yielding different mod-4 constraints.
3. Classify which primes can appear with odd exponent based on k.

### Lean Theorem Statement
```lean
def Nat.Multiperfect (n k : ℕ) : Prop :=
  (ArithmeticFunction.sigma 1) n = k * n ∧ 0 < n

theorem multiperfect_structure {n k : ℕ} (h : Nat.Multiperfect n k) (hodd : Odd n) (hk : 2 < k) :
    ∃ S : Finset ℕ, (∀ q ∈ S, q.Prime ∧ Odd (n.factorization q)) ∧
      ∀ p : ℕ, p.Prime → p ∉ S → Even (n.factorization p) := by sorry
```

### Cross-Domain Connection
Multiperfect numbers appear in combinatorial design theory and coding theory.

### Priority: MEDIUM

---

## Direction 3: Non-Divisibility by Small Primes

### Hypothesis
No odd perfect number is divisible by 3 and 5 simultaneously (i.e., 15 ∤ n).

### Proof Strategy
1. Assume n = 3^a · 5^b · ... is an odd perfect number with 3 | n and 5 | n.
2. Use multiplicativity: σ₁(n)/n = ∏ σ₁(p^{v_p(n)}) / p^{v_p(n)}.
3. The contribution from 3^a and 5^b already forces σ₁(n)/n > 2 for large enough exponents, or creates contradictions via congruence conditions.
4. Build on the Euler form: if q = 5 and 3 | m, or q ≠ 3,5, analyze both cases.

### Lean Theorem Statement
```lean
theorem odd_perfect_not_div_fifteen {n : ℕ}
    (hperf : Nat.Perfect n) (hodd : Odd n) : ¬ (15 ∣ n) := by sorry
```

### Cross-Domain Connection
Connects to abundance analysis (σ₁(n)/n) and Mertens' theorem.

### Priority: MEDIUM

---

## Direction 4: Carmichael Composite and Korselt's Criterion

### Hypothesis
Formalize and prove Korselt's criterion: n is a Carmichael number iff n is square-free, composite, and for every prime p | n, (p-1) | (n-1).

### Proof Strategy
1. Define Carmichael numbers: composite n such that a^n ≡ a (mod n) for all a.
2. Prove Korselt's criterion using Fermat's little theorem and Chinese Remainder Theorem.
3. Verify for small examples: 561 = 3 × 11 × 17.

### Lean Theorem Statement
```lean
def IsCarmichael (n : ℕ) : Prop :=
  1 < n ∧ ¬n.Prime ∧ ∀ a : ZMod n, a ^ n = a

theorem korselt_criterion {n : ℕ} (hn : 1 < n) (hc : ¬n.Prime) :
    IsCarmichael n ↔ Squarefree n ∧ ∀ p : ℕ, p.Prime → p ∣ n → (p - 1) ∣ (n - 1) := by sorry
```

### Cross-Domain Connection
Direct application to primality testing and cryptographic protocols.

### Priority: HIGH

---

## Direction 5: Fibonacci-GCD Identity

### Hypothesis
gcd(F_m, F_n) = F_{gcd(m,n)} for all natural numbers m, n.

### Proof Strategy
1. Use the existing `fib_coprime` theorem (gcd(F_n, F_{n+1}) = 1) as a base case.
2. Prove the key lemma: F_{m+n} = F_m · F_{n+1} + F_{m-1} · F_n.
3. Use this to show F_{gcd(m,n)} | gcd(F_m, F_n) by the Euclidean algorithm.
4. Prove the reverse divisibility.

### Lean Theorem Statement
```lean
theorem fib_gcd_identity (m n : ℕ) :
    Nat.gcd (Nat.fib m) (Nat.fib n) = Nat.fib (Nat.gcd m n) := by sorry
```

### Cross-Domain Connection
Used in efficient Fibonacci computation, Lucas sequences, and algebraic number theory.

### Priority: HIGH

---

## Direction 6: Abundance Ratio Analysis

### Hypothesis
The abundance ratio σ₁(n)/n determines deep structural properties. For perfect numbers, this ratio is exactly 2.

### Proof Strategy
1. Define abundance: a(n) = σ₁(n) - 2n (deficiency if negative, abundance if positive).
2. Prove that multiperfect numbers minimize/maximize certain functionals.
3. Use the Euler form to analyze σ₁(n)/n for candidate odd perfect numbers.
4. Show that for numbers of Euler's form with bounded prime factors, the ratio cannot equal 2.

### Lean Theorem Statement
```lean
noncomputable def abundance_ratio (n : ℕ) : ℚ :=
  if n = 0 then 0 else (ArithmeticFunction.sigma 1 n : ℚ) / n

theorem abundance_multiplicative {m n : ℕ} (hmn : Nat.Coprime m n) (hm : m ≠ 0) (hn : n ≠ 0) :
    abundance_ratio (m * n) = abundance_ratio m * abundance_ratio n := by sorry
```

### Priority: MEDIUM

---

## Direction 7: Unitary Perfect Numbers

### Hypothesis
All unitary perfect numbers are even (a stronger claim than for ordinary perfect numbers).

### Proof Strategy
1. Define σ*(n) = sum of unitary divisors (d | n with gcd(d, n/d) = 1).
2. σ* is multiplicative with σ*(p^a) = 1 + p^a.
3. If n = ∏ p_i^{a_i} is odd and σ*(n) = 2n, then ∏(1 + p_i^{a_i}) = 2·∏ p_i^{a_i}.
4. This is much more constrained than the ordinary case — use descent or bounding arguments.

### Lean Theorem Statement
```lean
def unitary_sigma (n : ℕ) : ℕ :=
  ∑ d ∈ n.divisors, if Nat.Coprime d (n / d) then d else 0

theorem odd_unitary_perfect_impossible {n : ℕ}
    (h : unitary_sigma n = 2 * n) (hn : 0 < n) (hodd : Odd n) : False := by sorry
```

### Cross-Domain Connection
Unitary divisors connect to Möbius function theory and multiplicative number theory.

### Priority: MEDIUM

---

## Direction 8: Connection to Modular Forms

### Hypothesis
The divisor sum σ_k(n) for k ≥ 1 generates Eisenstein series, connecting perfect numbers to modular forms.

### Proof Strategy
1. Formalize the Eisenstein series G_k(τ) = Σ_{(c,d)≠(0,0)} (cτ+d)^{-k}.
2. Show the Fourier expansion involves σ_{k-1}(n).
3. Perfect numbers correspond to special values of σ₁, linking to L-function evaluations.

### Priority: LOW (requires significant modular forms infrastructure)

---

## Recommended Execution Order

1. **Fibonacci-GCD Identity** (Direction 5) — builds on existing `fib_coprime`, high impact
2. **Carmichael Composites** (Direction 4) — connects to cryptography catalog
3. **Non-divisibility by 15** (Direction 3) — extends Euler form results
4. **Formal Lower Bounds** (Direction 1) — deepens the current work
5. **Multiperfect Structure** (Direction 2) — natural generalization
6. **Abundance Analysis** (Direction 6) — theoretical framework
7. **Unitary Perfect Numbers** (Direction 7) — parallel theory
8. **Modular Forms Connection** (Direction 8) — long-term vision

## Cross-Domain Bridge Theorems

The following bridge theorems connect perfect number theory to other mathematical domains:

### Bridge to Cryptography
- Mersenne primes ↔ even perfect numbers ↔ pseudorandom generators
- Carmichael numbers ↔ primality testing failures

### Bridge to Algebraic Number Theory
- Euler's shape theorem ↔ quadratic residue theory (q ≡ 1 mod 4)
- Fibonacci-GCD ↔ Lucas sequences ↔ algebraic integers in ℤ[φ]

### Bridge to Analytic Number Theory
- σ₁(n)/n distribution ↔ Mertens' theorem ↔ Riemann hypothesis
- Euler products for σ-functions ↔ L-series
