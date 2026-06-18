# Covering Systems and Sierpiński Numbers: A Formal Treatment

## Abstract

We present a formal development of the theory of covering systems and their application to proving that 78557 is a Sierpiński number. A Sierpiński number is an odd positive integer k such that k · 2^n + 1 is composite for every positive integer n. We formalize the key definitions (covering systems, Sierpiński certificates, congruence compatibility), prove the main soundness theorem connecting certificates to the Sierpiński property, establish structural properties of covering systems (LCM periodicity, uniform covering bounds, parity composition), and demonstrate the Chinese Remainder Theorem connection. The covering system for 78557 uses seven primes {3, 5, 7, 13, 19, 37, 73} with moduli {2, 4, 3, 12, 18, 36, 9}. We state the open conjecture that 78557 is the smallest Sierpiński number and identify the five remaining candidates that must be eliminated.

## 1. Introduction

In 1960, Wacław Sierpiński proved that there exist infinitely many odd positive integers k such that k · 2^n + 1 is composite for every n ≥ 1. These are now called *Sierpiński numbers*. The proof is non-constructive, but explicit examples were soon found using the method of *covering systems*.

A covering system is a finite collection of congruences {n ≡ aᵢ (mod mᵢ)}ᵢ₌₁ᵏ such that every integer n satisfies at least one congruence. The key observation is that if we can find primes p₁, ..., pₖ such that:

1. The congruences {n ≡ aᵢ (mod ordₚᵢ(2))} form a covering system, and
2. pᵢ divides k · 2^aᵢ + 1 for each i,

then k is a Sierpiński number, because for any n, some pᵢ divides k · 2^n + 1.

John Selfridge conjectured in 1962 that 78557 is the smallest Sierpiński number. This remains open; five candidates below 78557 have not yet been eliminated.

## 2. Definitions

### 2.1 Congruence Classes

A **congruence class** (r, m) represents the set {n ∈ ℕ : n ≡ r (mod m)} where 0 ≤ r < m and m > 0.

### 2.2 Covering Systems

A **covering system** is a finite list of congruence classes [(r₁, m₁), ..., (rₖ, mₖ)] such that for every n ∈ ℕ, there exists i with n ≡ rᵢ (mod mᵢ).

### 2.3 Sierpiński Certificates

A **Sierpiński certificate** for k consists of:
- A covering system C = [(r₁, m₁), ..., (rₖ, mₖ)]
- A list of primes [p₁, ..., pₖ] such that:
  - pᵢ | (k · 2^rᵢ + 1) for each i
  - 2^mᵢ ≡ 1 (mod pᵢ) for each i (i.e., ordₚᵢ(2) | mᵢ)

### 2.4 Sierpiński Numbers

A number k is a **Sierpiński number** if k is odd, positive, and k · 2^n + 1 is composite for every n ≥ 1.

### 2.5 Congruence Compatibility (Novel Definition)

Two congruence classes (r₁, m₁) and (r₂, m₂) are **compatible** if their intersection is nonempty: ∃ n, n ≡ r₁ (mod m₁) ∧ n ≡ r₂ (mod m₂). By the Chinese Remainder Theorem, coprime classes are always compatible.

## 3. Main Results

### 3.1 Power Modular Congruence

**Theorem (pow_mod_congr).** If 2^m ≡ 1 (mod p) and n ≡ a (mod m), then 2^n ≡ 2^a (mod p).

*Proof sketch.* Write n = a + m·q for q = n div m. Then 2^n = 2^a · (2^m)^q ≡ 2^a · 1^q = 2^a (mod p). □

### 3.2 Divisibility Transfer

**Theorem (divisor_transfers).** If p | (k · 2^a + 1) and 2^n ≡ 2^a (mod p), then p | (k · 2^n + 1).

*Proof sketch.* Since 2^n ≡ 2^a (mod p), we have k · 2^n + 1 ≡ k · 2^a + 1 ≡ 0 (mod p). □

### 3.3 Certificate Soundness

**Theorem (certificate_gives_divisor).** If cert is a valid Sierpiński certificate for k, then for every n, there exists p in cert.primes with p | (k · 2^n + 1).

*Proof sketch.* By the covering property, n falls in some class (rᵢ, mᵢ). By pow_mod_congr with the order condition, 2^n ≡ 2^rᵢ (mod pᵢ). By divisor_transfers with the divisibility condition, pᵢ | (k · 2^n + 1). □

### 3.4 LCM Periodicity

**Theorem (covering_system_lcm_period).** For any covering system with classes C, and any n, we have n ≡ n + L (mod mᵢ) for all moduli mᵢ, where L = lcm(m₁, ..., mₖ).

*Proof sketch.* Each mᵢ divides L, so L ≡ 0 (mod mᵢ), hence n and n + L have the same residue mod mᵢ. □

### 3.5 Finite Verification

**Theorem (covering_finite_verification).** A covering system covers all naturals if and only if it covers {0, 1, ..., L-1} where L = lcm of all moduli.

This reduces infinite verification to finite checking.

### 3.6 CRT Compatibility

**Theorem (crt_compatible).** If gcd(m₁, m₂) = 1, then any two congruence classes with moduli m₁, m₂ are compatible.

*Proof sketch.* Direct application of the Chinese Remainder Theorem. □

### 3.7 Uniform Covering Bound

**Theorem (uniform_covering_card).** If all moduli in a covering system equal m, then the system has at least m classes.

*Proof sketch.* Each class covers exactly one residue mod m. By pigeonhole, we need at least m classes to cover all m residues. □

### 3.8 Parity Composition

**Theorem (covering_by_parity).** If one set of classes covers all even numbers and another covers all odd numbers, their union covers all numbers.

## 4. The Certificate for 78557

The covering system for 78557 is:

| i | rᵢ | mᵢ | pᵢ | ordₚᵢ(2) | Check: pᵢ \| 78557·2^rᵢ + 1 |
|---|-----|-----|------|-----------|-------------------------------|
| 1 | 0 | 2 | 3 | 2 | 78558 = 3 · 26186 ✓ |
| 2 | 1 | 4 | 5 | 4 | 157115 = 5 · 31423 ✓ |
| 3 | 1 | 3 | 7 | 3 | 157115 = 7 · 22445 ✓ |
| 4 | 11 | 12 | 13 | 12 | 13 \| (78557·2¹¹ + 1) ✓ |
| 5 | 15 | 18 | 19 | 18 | 19 \| (78557·2¹⁵ + 1) ✓ |
| 6 | 27 | 36 | 37 | 36 | 37 \| (78557·2²⁷ + 1) ✓ |
| 7 | 3 | 9 | 73 | 9 | 73 \| (78557·2³ + 1) ✓ |

The LCM of {2, 4, 3, 12, 18, 36, 9} is 36. Verification of the covering property requires checking n = 0, 1, ..., 35, each of which falls into at least one class.

The density sum is 1/2 + 1/4 + 1/3 + 1/12 + 1/18 + 1/36 + 1/9 = 49/36 ≈ 1.361.

## 5. Algorithms

### 5.1 Certificate Verification

Given (k, classes, primes), verification proceeds in three steps:
1. **Coverage check**: Verify that every n in {0, ..., lcm-1} is covered. Time: O(L · |classes|).
2. **Divisibility check**: For each i, verify pᵢ | (k · 2^rᵢ + 1). Time: O(|classes| · log rᵢ).
3. **Order check**: For each i, verify 2^mᵢ ≡ 1 (mod pᵢ). Time: O(|classes| · log mᵢ).

### 5.2 Greedy Certificate Construction

Given k and a set of candidate primes:
1. For each prime p coprime to k, compute ord_p(2) and find residues r where p | k·2^r + 1.
2. Build a pool of available (r, ord, p) triples.
3. Greedily select classes that maximize coverage of uncovered residues.

This is a set cover problem (NP-hard in general), but the instances arising in practice are small.

## 6. The Sierpiński Problem

### 6.1 Status

Selfridge's conjecture that 78557 is the smallest Sierpiński number requires eliminating all odd k < 78557. As of 2025, five candidates remain:

| k | Status | Search bound |
|---|--------|-------------|
| 21181 | Open | n > 30,000,000 |
| 22699 | Open | n > 30,000,000 |
| 24737 | Open | n > 30,000,000 |
| 55459 | Open | n > 30,000,000 |
| 67607 | Open | n > 30,000,000 |

### 6.2 Testable Prediction

If the Sierpiński problem has a positive answer, then for each remaining k, there exists n such that k · 2^n + 1 is prime. For k = 21181, this means:

**Prediction**: There exists n such that 21181 · 2^n + 1 is prime.

This is computationally testable: each additional value of n checked either confirms (by finding a prime) or provides evidence against. The current search frontier is approximately n = 30,000,000 for each candidate.

## 7. Discussion

### 7.1 Covering System Constraints

The density condition Σ(1/mᵢ) ≥ 1 provides a necessary condition for covering systems. This constrains which primes can participate: we need primes with small multiplicative orders of 2, since these correspond to small moduli. The primes 3, 5, 7 have orders 2, 4, 3 respectively, contributing density 1/2 + 1/4 + 1/3 = 13/12 > 1 — already sufficient for a covering. However, we also need these primes to divide k · 2^r + 1 for appropriate r, which constrains k.

### 7.2 Connection to Chinese Remainder Theorem

The CRT plays two roles:
1. **Compatibility**: Ensures that congruence classes with coprime moduli always intersect, preventing "gaps" in coverage from incompatible classes.
2. **Periodicity**: The LCM of moduli gives the period after which the coverage pattern repeats, enabling finite verification.

### 7.3 Formal Verification

All nine main theorems in this work have been verified in Lean 4 with Mathlib, providing machine-checked certainty of correctness. The formalization required careful treatment of natural number arithmetic, modular congruences, and list operations.

## 8. Future Work

1. **Formal construction of the 78557 certificate**: Complete the formal proof that sierpinski78557_classes forms a covering system and verify all divisibility conditions, yielding a fully verified proof that 78557 is a Sierpiński number.

2. **Density lower bound**: Prove formally that Σ(1/mᵢ) ≥ 1 for any covering system, connecting to measure-theoretic arguments.

3. **Riesel number analogue**: Extend the formalization to Riesel numbers (k · 2^n − 1 always composite).

4. **Heuristic analysis of remaining candidates**: Develop heuristic models for the expected location of the first prime k · 2^n + 1 for the remaining candidates, based on prime density estimates.

## References

1. Sierpiński, W. (1960). "Sur un problème concernant les nombres k · 2^n + 1." *Elem. Math.* 15: 73–74.

2. Selfridge, J. L. (1962). Unpublished result establishing the covering system for 78557.

3. Izotov, A. S. (1995). "A note on Sierpiński numbers." *Fibonacci Quarterly* 33(3): 206–207.

4. Filaseta, M., Finch, C., & Kozek, M. (2008). "On powers associated with Sierpiński numbers, Riesel numbers and Polignac's conjecture." *J. Number Theory* 128(7): 1916–1940.

5. Helm, L., & Norris, D. (2002). "Seventeen or Bust: A distributed attack on the Sierpiński problem." Distributed computing project.
