# Composite-Index Fibonacci Primitive Divisors via Entry-Point Divisibility

## Abstract

We present a partial formalization in Lean 4 of Carmichael's 1913 theorem on primitive prime divisors of Fibonacci numbers, focusing on the composite-index case. The formalization establishes a computational framework based on the "primitive part" of Fibonacci numbers and verifies the theorem for all composite n ≤ 50,000 using native computation. The entry-point (rank of apparition) theory and the fundamental Fibonacci GCD identity `gcd(F_m, F_n) = F_{gcd(m,n)}` serve as the structural backbone. One sorry remains for the infinite extension beyond the computational range, corresponding to the deep cyclotomic Fibonacci polynomial bound Ψ_n ≥ φ^{φ(n)} − 1 that would complete the formalization.

## 1. Introduction

The Fibonacci sequence F(0) = 0, F(1) = 1, F(n+2) = F(n) + F(n+1) has fascinated mathematicians since antiquity. A fundamental question about its divisibility properties is: when does F(n) have a prime factor that doesn't divide any earlier Fibonacci number?

**Definition.** A prime p is a *primitive prime divisor* of F(n) if p | F(n) but p ∤ F(k) for all 0 < k < n.

In 1913, R. D. Carmichael proved the following remarkable result:

**Theorem (Carmichael, 1913).** For every n > 12, the Fibonacci number F(n) has at least one primitive prime divisor. The only values of n without a primitive prime divisor are n = 1, 2, 6, and 12.

The exceptions are:
- F(1) = F(2) = 1: no prime factors at all
- F(6) = 8 = 2³: the only prime factor 2 has entry point z(2) = 3, a proper divisor of 6
- F(12) = 144 = 2⁴ · 3²: both primes 2 and 3 have entry points z(2) = 3 and z(3) = 4, both proper divisors of 12

## 2. Entry-Point Theory

### 2.1. The Fibonacci GCD Identity

The cornerstone of our approach is the *strong divisibility property* of the Fibonacci sequence:

**Theorem (Fibonacci GCD Identity).** For all m, n ∈ ℕ:
```
gcd(F(m), F(n)) = F(gcd(m, n))
```

This identity, available in Mathlib as `Nat.fib_gcd`, immediately yields:

**Corollary.** If m | n, then F(m) | F(n).

### 2.2. Entry Point (Rank of Apparition)

For a prime p, the *entry point* (or *rank of apparition*) z(p) is the smallest positive integer k such that p | F(k). Every prime has an entry point, and the key property is:

**Theorem.** p | F(n) if and only if z(p) | n.

The forward direction follows from the GCD identity: if p | F(n) and z(p) ∤ n, then p | F(gcd(n, z(p))) with gcd(n, z(p)) < z(p), contradicting minimality.

The reverse direction uses F(z(p)) | F(n) when z(p) | n.

### 2.3. Bridge Lemma

A crucial bridge connects proper-divisor primitivity to full primitivity:

**Lemma (Bridge).** If p | F(n) and p ∤ F(d) for every proper divisor d of n (i.e., d | n with 0 < d < n), then p ∤ F(k) for all 0 < k < n.

*Proof.* If p | F(k) for some 0 < k < n, then p | gcd(F(n), F(k)) = F(gcd(n,k)). Since gcd(n,k) is a proper divisor of n with gcd(n,k) ≤ k < n, this contradicts our hypothesis. □

This lemma reduces the infinite check "p ∤ F(k) for all k < n" to a finite check over divisors of n.

## 3. The Primitive Part

### 3.1. Definition

For composite n, we define the *primitive part* of F(n) as the result of stripping all prime factors shared with F(d) for proper divisors d of n:

```
primPart(n) = F(n) after removing all factors shared with F(d) for d | n, 0 < d < n
```

Formally, this is computed by iteratively dividing by gcd until coprimality is achieved for each proper divisor's Fibonacci value.

### 3.2. Key Properties

1. **Divisibility:** primPart(n) | F(n)
2. **Coprimality:** primPart(n) is coprime to F(d) for every proper divisor d
3. **Primitivity:** If primPart(n) > 1, then its smallest prime factor is a primitive prime divisor of F(n)

Property 3 follows from the Bridge Lemma: the smallest prime factor of primPart(n) divides F(n) but not F(d) for any proper divisor d.

## 4. Formalization Results

### 4.1. What Is Proved

The Lean 4 formalization (`CarmichaelProof.lean`) establishes:

1. **Bridge Lemma** (`bridge_lemma`): Proper-divisor primitivity implies full primitivity
2. **Stripping correctness** (`stripAllAux_dvd`, `stripAllAux_coprime`): The iterative GCD stripping procedure correctly computes the coprime part
3. **Primitive part properties** (`primPart_dvd`, `primPart_coprime_proper_divs`): The primitive part divides F(n) and is coprime to all F(d) for proper d
4. **Primitive part implies existence** (`primPart_implies_primitive`): If primPart(n) > 1, a primitive prime exists
5. **Computational verification** (`primPart_check`): For all n ∈ [13, 50000], either n is prime or primPart(n) > 1 (verified by `native_decide`)
6. **Composite proper divisor bound** (`composite_proper_div_le_half`): Every proper divisor of composite n ≥ 4 is at most n/2
7. **Main theorem** (`fib_carmichael_composite`): For composite n ≥ 13, F(n) has a primitive prime divisor (with one sorry for n > 50000)

The helper file (`CarmichaelHelper.lean`) proves the prime-index case separately using the Fibonacci GCD identity.

### 4.2. The Remaining Sorry

The single remaining sorry is:

```lean
⊢ 1 < primPart n
```

under the hypotheses n > 50000 and n is composite. This corresponds to showing that F(n) has a prime with entry point exactly n for all composite n > 50000.

### 4.3. What Would Be Needed

Closing this sorry requires formalizing the theory of **cyclotomic Fibonacci numbers** (also called primitive parts of the Fibonacci sequence):

**Definition.** The n-th cyclotomic Fibonacci number is:
```
Ψ_n = ∏_{d|n} F(d)^{μ(n/d)}
```
where μ is the Möbius function.

**Key properties needed:**
1. **Product decomposition:** F(n) = ∏_{d|n} Ψ_d
2. **Intrinsic factor theorem:** If p | Ψ_n and p | Ψ_d for d | n with d < n, then p | n
3. **Lower bound:** Ψ_n ≥ φ^{φ(n)} − 1 where φ = (1+√5)/2 is the golden ratio and φ(n) is Euler's totient

From these, for composite n > 12: Ψ_n ≥ φ^4 − 1 > 5 > 1, and the intrinsic factor theorem ensures Ψ_n has a prime not dividing n (since Ψ_n > n for large n), which gives a primitive prime.

This infrastructure would require approximately 400–500 lines of additional Lean code, including:
- Möbius function properties on multiplicative Fibonacci valuations
- Golden ratio algebraic bounds using Mathlib's `Real.GoldenRatio`
- Euler totient lower bounds
- The intrinsic factor theorem via modular arithmetic

## 5. Discussion: Making It Accessible

### The Fingerprint Analogy

Think of each Fibonacci number as having a "fingerprint" — its set of prime factors. The question Carmichael answered is: does each F(n) (for n > 12) have at least one unique ridge in its fingerprint that no earlier Fibonacci number shares?

The answer is yes, and the mechanism is elegant: the "rank of apparition" z(p) acts like a prime's home address in the Fibonacci sequence. A prime p "lives" at position z(p), meaning p first appears in F(z(p)) and then reappears exactly when z(p) divides the index. A primitive prime of F(n) is one whose home address is exactly n — it hasn't appeared before and won't reappear until position 2n.

### Why n = 12 Is the Last Exception

The exceptions n = 1, 2, 6, 12 arise because F(n) is "too small" relative to its index structure. F(12) = 144 = 2⁴ · 3² has only two prime factors, and both have small entry points (z(2) = 3, z(3) = 4) that divide 12. For n > 12, the exponential growth of F(n) ≈ φⁿ/√5 overwhelms the number of "old" primes that can be recycled from proper divisors.

### Connections to Other Mathematics

Carmichael's theorem is a special case of the broader *Zsygmondy theorem* (1892) for sequences aⁿ − bⁿ, since F(n) = (αⁿ − βⁿ)/(α − β) where α, β are roots of x² − x − 1. The result has been generalized to:

- **Lucas sequences** U_n(P, Q) by Bilu, Hanrot, and Voutier (2001)
- **Elliptic divisibility sequences** by Silverman (2005)
- **Higher-order linear recurrences** (partially, ongoing research)

## 6. Applications

### 6.1. Cryptography

Primitive prime divisors of Fibonacci numbers provide a source of primes with specific algebraic structure. The entry point z(p) encodes p's relationship to the golden ratio modulo p, which connects to:
- Fibonacci-based pseudorandom number generators
- Primality testing via Fibonacci pseudoprimes
- The Fibonacci representation system (Zeckendorf's theorem)

### 6.2. Number Theory

The primitive part Ψ_n connects to:
- **Cyclotomic polynomials:** Ψ_n is analogous to the value Φ_n(α/β) of the n-th cyclotomic polynomial
- **Algebraic number theory:** The splitting behavior of primes in ℚ(√5)
- **p-adic analysis:** The Fibonacci p-adic valuation formula v_p(F(n)) = v_p(F(z(p))) + v_p(n/z(p))

### 6.3. Combinatorics

Fibonacci numbers count tilings, compositions, and paths. Primitive divisors have combinatorial meaning: a prime p is primitive for F(n) if and only if the tiling of a 1×n board by 1×1 and 1×2 tiles has a symmetry of exact order p that doesn't arise from tilings of any shorter board.

## 7. Future Directions

1. **Complete formalization:** Formalize the cyclotomic Fibonacci theory to eliminate the remaining sorry
2. **Lucas sequence generalization:** Extend to general Lucas sequences U_n(P, Q)
3. **Effective bounds:** Formalize explicit lower bounds on the largest primitive prime factor
4. **Prime index case connections:** Connect to Fibonacci primes and the Wall–Sun–Sun conjecture

## References

1. R. D. Carmichael, "On the numerical factors of the arithmetic forms αⁿ ± βⁿ," *Annals of Mathematics*, 15 (1913), 30–70.
2. Yu. Bilu, G. Hanrot, P. M. Voutier, "Existence of primitive divisors of Lucas and Lehmer numbers," *J. reine angew. Math.*, 539 (2001), 75–122.
3. J. H. Silverman, "Wieferich's criterion and the abc-conjecture," *J. Number Theory*, 30 (1988), 226–237.
