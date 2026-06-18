# Certified Bounded Divisor Search: From Computational Conjecture to Formally Verified Arithmetic Structure

## Abstract

We present a suite of formally verified theorems establishing that compositeness detection can be reduced to a certified finite search over the interval [2, √N]. Starting from the classical observation that the smaller factor in any factorization N = p × q satisfies p ≤ √N, we build a complete theorem stack: (1) any nontrivial divisor of N ≥ 2 determines a complementary factor, with the smaller of the pair bounded by √N; (2) every composite N ≥ 2 has a nontrivial divisor at most √N; (3) compositeness of N ≥ 2 is equivalent to the existence of a divisor in [2, √N]; and (4) this equivalence holds over the computationally actionable finite set `Finset.Icc 2 (Nat.sqrt N)`. All proofs are machine-verified with no axioms beyond the standard foundations. We discuss the cross-domain significance of this bounded-witness paradigm, connecting arithmetic search truncation to bounded feasibility in information theory and contraction-driven convergence in dynamical systems. Python experiments validate the theorems computationally for N up to 100,000 and demonstrate the practical search space reduction.

## 1. Introduction

### 1.1 Motivation

A recurring theme in mathematics is the reduction of infinite or unbounded search to certified finite regions. In number theory, the foundational instance of this theme is the square root barrier for trial division: to determine whether N is prime, one need only test divisors up to √N. While this fact is well-known and elementary, its formal certification and its connection to broader bounded-witness principles across mathematics have not been systematically developed.

This work addresses three goals:

1. **Formal verification**: Produce machine-checked proofs of the complete theorem stack from basic divisibility to the Finset-based compositeness criterion.
2. **Computational validation**: Use Python experiments to generate conjectures, verify patterns, and quantify the search space reduction.
3. **Cross-domain connection**: Identify the bounded-witness paradigm as a structural pattern shared with information-theoretic feasibility and dynamical contraction.

### 1.2 Related Work

The square root bound for factors is classical, appearing implicitly in Euclid and explicitly in trial division algorithms since antiquity. Formal proofs of related results exist in the Mathlib library for Lean 4, including `Nat.minFac_prime` and the `Nat.Prime` API. Our contribution is to organize these into a coherent, application-oriented theorem stack and to identify the cross-domain significance.

The bounded-witness paradigm has been studied in complexity theory through witness theorems (e.g., NP-witness compactness), but the connection to arithmetic search truncation and information-theoretic feasibility has not been made explicit in the formal verification literature.

## 2. Definitions and Notation

We work over the natural numbers ℕ = {0, 1, 2, ...} and use the standard definitions:

- **Divisibility**: `p ∣ N` iff ∃ q, N = p * q.
- **Primality**: `Nat.Prime N` iff N ≥ 2 and N's only divisors are 1 and N.
- **Integer square root**: `Nat.sqrt N` is the largest m with m² ≤ N.
- **Finite interval**: `Finset.Icc a b` is the finite set {a, a+1, ..., b}.

Key property of `Nat.sqrt`:
```
Nat.le_sqrt : n ≤ Nat.sqrt m ↔ n * n ≤ m
```

## 3. Main Results

### 3.1 Theorem 1: Smaller Factor Bound (smaller_factor_sqrt_bound')

**Statement**: For natural numbers N, p, q with N = p × q and p ≤ q, we have p ≤ √N.

**Proof sketch**: From p ≤ q, we derive p² ≤ p × q = N, hence p ≤ √N by the characterization of `Nat.sqrt`.

This is the arithmetic engine: it normalizes any factor pair so the smaller element is bounded.

### 3.2 Theorem 2: Factor Pair with Bounded Element (exists_factor_le_sqrt_of_dvd)

**Statement**: For N ≥ 2, p ≥ 2, p | N, there exists q such that N = p × q, q ≥ 1, and:
- if p ≤ q then p ≤ √N
- if q ≤ p then q ≤ √N

**Proof sketch**: Take q = N/p. Then q ≥ 1 since N ≥ 2 and p ≥ 2 implies N/p ≥ 1. The two implications follow from `smaller_factor_sqrt_bound'` applied to the appropriate ordering.

### 3.3 Theorem 3: Composite Has Nontrivial Divisor (composite_has_nontrivial_divisor)

**Statement**: If N ≥ 2 and N is not prime, then ∃ d with 2 ≤ d, d | N, d < N.

**Proof sketch**: Uses `Nat.exists_dvd_of_not_prime2` from Mathlib, which provides a divisor d with 2 ≤ d and d < N for any non-prime N ≥ 2.

### 3.4 Theorem 4: Small Factor of Composite (exists_small_factor_of_composite)

**Statement**: If N ≥ 2 and N is not prime, then ∃ d with 2 ≤ d, d | N, d ≤ √N.

**Proof sketch**: From Theorem 3, obtain d with 2 ≤ d, d | N, d < N. Write N = d × q. By `le_total`, either d ≤ q or q < d. In the first case, d ≤ √N by Theorem 1. In the second case, q ≤ √N by Theorem 1 (with roles swapped), and q ≥ 2 since d < N implies q = N/d ≥ 2. In either case, we produce a divisor ≤ √N.

### 3.5 Theorem 5: Compositeness Iff Criterion (composite_iff_exists_divisor_le_sqrt)

**Statement**: For N ≥ 2:
```
¬ Nat.Prime N ↔ ∃ d, 2 ≤ d ∧ d ≤ √N ∧ d | N
```

**Proof sketch**:
- (→): Immediate from Theorem 4.
- (←): Given d with 2 ≤ d ≤ √N and d | N, we need d < N (to show N is not prime via nontrivial factorization). Since d ≤ √N ≤ N and N ≥ 2, if d = N then √N ≥ N, which contradicts N ≥ 2. More precisely, using `Nat.Prime.dvd_iff_eq`, a prime p is only divisible by 1 and itself, but d ≤ √N < N for N ≥ 4, giving a contradiction.

### 3.6 Theorem 6: Compositeness on Finset (composite_detection_complete_on_Icc)

**Statement**: For N ≥ 2:
```
¬ Nat.Prime N ↔ ∃ d ∈ Finset.Icc 2 (√N), d | N
```

**Proof sketch**: Direct reformulation of Theorem 5 using the equivalence between `d ∈ Finset.Icc a b` and `a ≤ d ∧ d ≤ b`.

### 3.7 Theorem 7: GCD of Factor Pair (gcd_of_factor_pair)

**Statement**: For N = p × q, we have gcd(p, q) | N.

**Proof sketch**: gcd(p, q) | p (standard), hence gcd(p, q) | p × q = N.

## 4. Algorithms

### 4.1 Trial Division with Certified Cutoff

```
function TrialDivisionBounded(N):
    Input: N ≥ 2
    Output: smallest prime factor of N, or "prime"

    for d = 2 to ⌊√N⌋:
        if d | N:
            return d
    return "prime"
```

**Correctness**: By Theorem 5, this returns "prime" iff N is prime.

**Complexity**: O(√N) divisions. Space O(1).

### 4.2 Complete Factorization

```
function CompleteFactorization(N):
    factors ← empty list
    while N > 1:
        d ← TrialDivisionBounded(N)
        if d = "prime":
            append N to factors; break
        append d to factors
        N ← N / d
    return factors
```

**Correctness**: Each extracted factor d is the smallest prime factor of the current N (by minimality of the search). The recursion terminates since N strictly decreases.

**Complexity**: O(√N) per factor, O(log N) factors, so O(√N · log N) total.

### 4.3 Sieve of Eratosthenes (Certified Bound)

```
function SieveCertified(limit):
    is_prime[0..limit] ← all true
    is_prime[0] ← false; is_prime[1] ← false
    for p = 2 to ⌊√limit⌋:    // certified by Theorem 5
        if is_prime[p]:
            mark p², p²+p, p²+2p, ... as composite
    return {i : is_prime[i] = true}
```

**Correctness**: By Theorem 5, any composite n ≤ limit has a prime factor p ≤ √n ≤ √limit, so it will be sieved.

**Complexity**: O(n log log n) time, O(n) space.

## 5. Computational Experiments

### 5.1 Exhaustive Validation

We tested all composite numbers N ∈ [4, 100000] and verified that each has a nontrivial divisor d ≤ √N. All 90,407 composite numbers satisfy the bound.

### 5.2 Search Space Reduction

| N | Naive search |[2, N-1]| | Bounded search |[2, √N]| | Speedup |
|---|---|---|---|
| 10² | 98 | 9 | 11× |
| 10⁴ | 9,998 | 99 | 101× |
| 10⁶ | 999,998 | 999 | 1,001× |
| 10⁹ | 999,999,998 | 31,621 | 31,625× |
| 10¹² | 999,999,999,998 | 999,999 | 1,000,001× |

The speedup factor scales as √N, confirming the theoretical prediction.

### 5.3 Factor Pair Distribution

For composite N, the smallest nontrivial divisor d satisfies d ≤ √N with equality only when N is a perfect square of a prime (e.g., 4 = 2², 9 = 3², 25 = 5²). The scatter plot of (N, d) for N ∈ [4, 2000] shows all points lying below the √N curve, confirming the theorem visually.

## 6. Cross-Domain Connections

### 6.1 Information-Theoretic Bounded Feasibility

The catalog theorem `feasibleChannelSet_bounded` states that the set of channels achieving a given rate-distortion pair is bounded. Our arithmetic theorem is a number-theoretic analogue: the "feasible set" of compositeness witnesses is bounded by [2, √N].

Both theorems share the structure:
> **Global constraint ↔ Witness in bounded feasible region**

In information theory, the constraint is a rate-distortion bound; in arithmetic, it is compositeness. In both cases, the witness set is certified to be finite and bounded, enabling exhaustive search.

### 6.2 Dynamical Contraction

The catalog theorem `iterate_contraction_bound` shows that under a contraction mapping C with factor q < 1, we have d(Cⁿx, Cⁿy) ≤ qⁿ · d(x, y). The arithmetic analogue is the "contraction" from the naive search space [2, N-1] (size N-2) to the bounded space [2, √N] (size √N - 1). This is a one-step "square root contraction" with ratio √N / N = 1/√N, which vanishes as N grows.

### 6.3 Dimension-Bounded Complexity

The catalog theorem `krull_height_key_dimension_bound` suggests that algebraic complexity is governed by dimension-like invariants. In our setting, the "dimension" is 1 (we search a one-dimensional interval), and the complexity bound is √N — the square root plays the role of a one-dimensional complexity measure, analogous to how Krull height governs chain length in commutative algebra.

## 7. Discussion

### 7.1 Significance of Formal Verification

All theorems are machine-verified, ensuring correctness with certainty beyond human review. The proofs use only standard axioms (propext, Classical.choice, Quot.sound) and do not rely on `sorry` or unverified assumptions. This level of certainty is essential for the theorem to serve as a trust anchor in certified computation.

### 7.2 The Bounded Witness Paradigm

The key conceptual contribution is the identification of a cross-domain paradigm: **a global property is equivalent to the existence of a witness in a certified finite region**. This paradigm appears in:
- Number theory (compositeness ↔ divisor in [2, √N])
- Information theory (rate-distortion achievability ↔ channel in bounded set)
- Dynamical systems (convergence ↔ orbit in contraction neighborhood)
- Algebraic geometry (structural complexity ↔ invariant below dimension bound)

Formalizing this paradigm as a reusable proof architecture is a direction for future work.

### 7.3 Limitations

The square root barrier applies to trial division, which has exponential complexity in the bit-length of N. Modern factoring algorithms (number field sieve, elliptic curve method) exploit deeper arithmetic structure to achieve sub-exponential complexity. Our work does not address these methods, but the bounded-witness paradigm may extend to their analysis.

## 8. Future Work

See `FUTURE_DIRECTIONS.md` for a detailed roadmap. Key directions include:
1. Abstract bounded-witness typeclass for reusable formalization
2. Certified complexity bounds (search uses ≤ √N - 1 tests)
3. Generalization to B-smooth number detection
4. Bridge to finite feasibility in information theory
5. Fibonacci/Lucas recurrence analogues

## 9. References

1. Hardy, G.H., and Wright, E.M. *An Introduction to the Theory of Numbers*, 6th ed. Oxford University Press, 2008.
2. The Mathlib Community. *Mathlib: a unified library of mathematics formalized*, 2024. https://leanprover-community.github.io/mathlib4_docs/
3. Crandall, R., and Pomerance, C. *Prime Numbers: A Computational Perspective*, 2nd ed. Springer, 2005.
4. Cover, T.M., and Thomas, J.A. *Elements of Information Theory*, 2nd ed. Wiley, 2006.
