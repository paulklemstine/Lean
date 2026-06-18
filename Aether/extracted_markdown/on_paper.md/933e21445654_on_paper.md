# Research Report: Formalizing Carmichael's Theorem for Fibonacci Primitive Divisors

## Overview

This report documents the formalization of Carmichael's theorem (1913) on primitive prime divisors of Fibonacci numbers in Lean 4 with Mathlib. The theorem states that for every integer n ≥ 13, the Fibonacci number F(n) possesses at least one **primitive prime divisor** — a prime p that divides F(n) but does not divide F(k) for any positive k < n.

## Results

### Theorem Statement
```lean
theorem fib_carmichael (n : ℕ) (hn : 13 ≤ n) :
    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧
      ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k)
```

### What Was Proved

1. **Prime case (complete)**: When n is prime and n ≥ 13, every prime factor of F(n) is primitive. This follows from the GCD identity gcd(F(m), F(n)) = F(gcd(m,n)) and the fact that for prime n, gcd(n,k) = 1 for 0 < k < n.

2. **Composite case for n ≤ 10,000 (complete)**: Verified computationally using `native_decide` with a novel "coprime part" extraction algorithm. For each composite n in [14, 10000], we compute `fibCoprimePart n` — the result of removing all prime factors shared with F(d) for proper divisors d | n — and verify it exceeds 1.

3. **Correctness of the coprime part approach (complete)**: Four key lemmas establishing that `fibCoprimePart n > 1` implies existence of a primitive prime divisor:
   - `removePrimesOf_dvd`: the coprime extraction divides the original
   - `removePrimesOf_coprime`: the result is coprime to the removed factors
   - `primitive_of_not_dvd_proper_divisors`: a prime not dividing F(d) for proper d | n is primitive
   - `primitive_of_fibCoprimePart_pos`: connects the computational check to the existential statement

4. **Composite case for n > 10,000 (open)**: This remains as a single `sorry`. The proof requires either:
   - The Lifting-the-Exponent Lemma (LTE) for Fibonacci sequences
   - The cyclotomic factorization of Fibonacci numbers
   - Both of which constitute substantial formalization efforts not currently in Mathlib

### Sorry Count Reduction

| File | Before | After |
|------|--------|-------|
| `Shared/CarmichaelComposite.lean` | 1 sorry | 1 sorry (refined to n > 10000 only) |
| `Shared/CarmichaelComputational.lean` | 1 sorry | 0 sorries |
| `Shared/Fib_gcd_identity.lean` | 1 sorry | 0 sorries |
| `Speculative/AutoResearch/CarmichaelComposite.lean` | 1 sorry | 0 sorries |
| **Total** | **4 sorries** | **1 sorry** |

## Technical Approach

### Entry Point Theory

The **entry point** (or rank of apparition) α(p) of a prime p is the smallest positive integer k such that p | F(k). Key properties formalized:

- **Divisibility**: If p | F(n) with n > 0, then α(p) | n (`fibEntryPt_dvd_of_fib_dvd`)
- **Primitivity**: If α(p) = n, then p is primitive for F(n) (`primitive_of_entryPt_eq`)

### Coprime Part Computation

The novel computational approach defines:

```lean
def removePrimesOf (a b : ℕ) : ℕ :=
  -- Iteratively remove all prime factors of b from a via gcd
  
def fibCoprimePart (n : ℕ) : ℕ :=
  -- Remove from F(n) all primes appearing in F(d) for proper d | n
```

If `fibCoprimePart n > 1`, then F(n) has a prime factor coprime to all F(d) for proper divisors d, which by entry point theory must be primitive.

### Bridging Lemma

The key bridging lemma connects "not dividing proper divisors' Fibonacci values" to "primitive for all k":

```lean
lemma primitive_of_not_dvd_proper_divisors (p n : ℕ) (hp : Nat.Prime p)
    (hn : 0 < n) (hpn : p ∣ Nat.fib n)
    (hnd : ∀ d, d ∣ n → 0 < d → d < n → ¬(p ∣ Nat.fib d)) :
    ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k)
```

**Proof idea**: If p | F(k), then α(p) | gcd(n,k) < n, making α(p) a proper divisor of n with p | F(α(p)), contradicting the hypothesis.

## What Remains

The single remaining `sorry` (`fib_carmichael_large`) requires showing that for composite n > 10000, the primitive part of F(n) is nontrivial. Classical proofs use:

1. **Cyclotomic factorization**: F(n) = ∏_{d|n} Ψ_d where Ψ_n > 1 for n > 12
2. **LTE for Fibonacci**: v_p(F(mn)) = v_p(F(m)) + v_p(n) under appropriate conditions

Both require substantial infrastructure not yet available in Mathlib. The computational verification confirms the result holds for all composite n ≤ 10,000 (and has been tested up to 500,000 with `#eval`).

## Significance

This formalization demonstrates that:
1. Carmichael's 1913 theorem is amenable to machine verification
2. Hybrid computational-mathematical approaches can close significant gaps
3. The entry point theory for Fibonacci sequences can be cleanly formalized
4. The remaining gap (n > 10000) is a specific, well-defined formalization challenge
