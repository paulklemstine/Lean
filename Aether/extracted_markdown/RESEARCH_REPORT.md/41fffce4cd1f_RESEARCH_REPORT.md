# Carmichael's Theorem: Primitive Prime Divisors for Fibonacci Numbers

## Abstract

We present a partial formalization of Carmichael's theorem (1913) in Lean 4: for every
n ≥ 13, the Fibonacci number F(n) possesses a *primitive prime divisor* — a prime p
dividing F(n) but dividing no earlier Fibonacci number F(k) for 0 < k < n. Our
formalization covers the prime-index case completely and the composite-index case
computationally verified up to n = 75,000, reducing the remaining gap to a single
sorry requiring Wall's Lifting-the-Exponent lemma for Fibonacci sequences.

## 1. Introduction

The Fibonacci sequence 0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, ...
satisfies the recurrence F(n+2) = F(n+1) + F(n). A deep property of this sequence,
discovered by R.D. Carmichael in 1913, concerns its divisibility structure.

**Definition.** A prime p is a *primitive prime divisor* of F(n) if p | F(n) but
p ∤ F(k) for all 0 < k < n.

**Theorem (Carmichael, 1913).** For n ≠ 1, 2, 6, 12, the Fibonacci number F(n)
has at least one primitive prime divisor.

Equivalently, for n ≥ 13, F(n) always has a primitive prime divisor. The four
exceptions are:
- F(1) = F(2) = 1 (no prime factors at all)
- F(6) = 8 = 2³ (only factor 2 with entry point 3)
- F(12) = 144 = 2⁴ · 3² (factors 2, 3 with entry points 3, 4)

## 2. Key Mathematical Concepts

### 2.1 Entry Points (Rank of Apparition)

For each prime p, the *entry point* (or rank of apparition) α(p) is the smallest
positive integer k such that p | F(k). Key properties:

1. **Existence**: Every prime p has an entry point (the Pisano period ensures
   F(k) ≡ 0 mod p for some k > 0).
2. **Divisibility**: p | F(n) if and only if α(p) | n.
3. **GCD Identity**: gcd(F(m), F(n)) = F(gcd(m, n)).

Property 3, the GCD identity, is the cornerstone. It implies property 2 and connects
the divisibility structure of Fibonacci numbers to the divisibility of indices.

### 2.2 The Prime Case

When n is prime and n ≥ 13, every prime factor of F(n) is automatically primitive.
This follows immediately from the GCD identity: if p | F(n) and p | F(k) for
some 0 < k < n, then p | F(gcd(n, k)) = F(1) = 1, a contradiction since p ≥ 2.

### 2.3 The Composite Case

The composite case is substantially harder. When n is composite, F(n) can have prime
factors with entry points strictly dividing n. The challenge is to show that not ALL
prime factors have this property — at least one must have entry point exactly n.

## 3. Our Formalization

### 3.1 Architecture

The formalization is organized across several files:

- **`Shared/CarmichaelHelper.lean`**: The prime case (`fib_primitive_divisor_prime`)
- **`Shared/CarmichaelProof.lean`**: The composite case infrastructure including:
  - Bridge lemma (reducing "all k" to "all divisors d")
  - Computational stripping algorithm (`primPart`)
  - Correctness proofs (`primPart_implies_primitive`)
  - Computational verification up to 75,000
- **`Shared/FibLTE.lean`**: Helper lemmas:
  - `fib_mul_le`: F(a+b) ≥ F(a)·F(b)
  - `proper_divisor_le_div_minFac`: proper divisors bounded by n/p
  - `gcd_lucas_fib_dvd_two`: gcd(L(m), F(m)) | 2
- **`Speculative/AutoResearch/`**: Unified versions routing through the main proof

### 3.2 The Prime Case (Fully Proved)

```lean
theorem fib_primitive_divisor_prime (n : ℕ) (hn : 13 ≤ n) (hnp : Nat.Prime n) :
    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧
      ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k)
```

The proof is elegant: for prime n, gcd(n, k) = 1 for 0 < k < n, so by the GCD
identity, any prime dividing both F(n) and F(k) would divide F(1) = 1.

### 3.3 The Composite Case (Verified to 75,000)

```lean
theorem fib_carmichael_composite (n : ℕ) (hn : 13 ≤ n) (hnp : ¬Nat.Prime n) :
    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧
      ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k)
```

For n ≤ 75,000, we use `native_decide` to verify that the "primitive part" of F(n)
(obtained by stripping all factors shared with F(d) for proper divisors d | n) is
greater than 1. This primitive part having a prime factor immediately yields a
primitive prime divisor by the bridge lemma.

### 3.4 The Remaining Gap

For composite n > 75,000, the proof requires showing that the primitive part
Φ_n = ∏_{d|n} F(d)^{μ(n/d)} exceeds 1. This involves:

1. **Wall's Theorem**: For prime q | F(m) with entry point α(q) | m,
   v_q(F(km)) = v_q(F(m)) + v_q(k). This controls p-adic valuations.

2. **Cyclotomic Bounds**: The primitive part Φ_n relates to cyclotomic polynomials
   evaluated at the golden ratio, yielding |Φ_n| ≥ 2 for n > 12.

Neither of these deep results is currently available in Mathlib.

## 4. Discussion: Why This Matters

### For the General Reader

Imagine the Fibonacci sequence as a family tree of numbers, where each generation
carries DNA from its ancestors. Carmichael's theorem says something remarkable: in
every generation past the 12th, there is a "new gene" — a prime factor that has
never appeared before. No matter how far you go in the sequence, novelty never runs
out.

This is far from obvious. The Fibonacci numbers grow exponentially (roughly as
φⁿ/√5 where φ = (1+√5)/2 ≈ 1.618), and their prime factorizations become
increasingly complex. Yet the theorem guarantees that this complexity always
includes at least one genuinely new prime.

### Connections to Other Mathematics

Carmichael's theorem is the Fibonacci case of the **Zsygmondy-Birkhoff-Vandiver
theorem**, which applies to general Lucas sequences and, more broadly, to sequences
of the form aⁿ - bⁿ (the classical Zsygmondy theorem). These results play key
roles in:

- **Group theory**: Establishing the existence of elements of specific orders
- **Algebraic number theory**: Studying the splitting of primes in number fields
- **Cryptography**: Analyzing the security of Fibonacci-based pseudorandom generators
- **Diophantine equations**: Bounding solutions via primitive divisor arguments

### The Formalization Challenge

Our work highlights an interesting gap in mathematical formalization: results that
are "well-known" and used routinely in number theory research (like Wall's theorem
or the properties of cyclotomic polynomials in algebraic integers) often lack formal
proofs. The computational verification to 75,000 demonstrates that the result is
true in this range, but bridging to infinity requires formalizing the algebraic
machinery of entry points and p-adic valuations for linear recurrence sequences.

## 5. Technical Details

### 5.1 The Stripping Algorithm

The `primPart` function computes the primitive part by iteratively removing shared
factors:

```
primPart(n) = stripAll(stripAll(···stripAll(F(n), F(d₁))···, F(d_{k-1})), F(d_k))
```

where d₁, ..., d_k are the proper divisors of n. The `stripAll` operation repeatedly
divides by gcd until coprimality is achieved.

### 5.2 Correctness

The key correctness lemma is `primPart_coprime_proper_divs`: for any proper divisor
d of n, the minimum factor of primPart(n) does not divide F(d). Combined with the
bridge lemma, this extends coprimality from proper divisors to all k < n.

### 5.3 Computational Performance

The native_decide verification for [13, 75000] involves computing F(n) for n up to
75,000 (numbers with ~15,600 digits), computing GCDs of these large numbers, and
checking primality. This completes in reasonable time within Lean's native code
compilation framework.

## 6. Conclusion

We have formalized Carmichael's theorem with:
- Complete proof for prime indices (all n)
- Computational verification for composite indices up to 75,000
- A single remaining sorry for composite n > 75,000

The remaining gap is a genuine open formalization challenge requiring Wall's theorem
(Lifting the Exponent for Fibonacci), which is not yet in Mathlib. We provide
extensive helper infrastructure that would facilitate closing this gap once the
requisite algebraic machinery is available.

## References

1. R.D. Carmichael, "On the numerical factors of the arithmetic forms αⁿ ± βⁿ,"
   *Annals of Mathematics*, 1913.
2. K. Zsygmondy, "Zur Theorie der Potenzreste," *Monatshefte für Mathematik*, 1892.
3. D.D. Wall, "Fibonacci series modulo m," *American Mathematical Monthly*, 1960.
