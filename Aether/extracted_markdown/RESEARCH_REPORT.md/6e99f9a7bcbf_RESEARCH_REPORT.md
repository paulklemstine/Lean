# Research Report: P-adic Valuation Structure of Integer Factoring

## Summary

We formalize and prove a collection of theorems connecting **p-adic valuations** with **integer factoring algorithms**, centered on the **P-adic Order Lifting Theorem**.

## Main Result: The P-adic Order Lifting Theorem

**Theorem** (`padicVal_order_lift`). Let p be an odd prime, a > 1 an integer with p ∤ a, and d > 0 with p | (aᵈ − 1). Then for all j ≥ 0:

$$v_p(a^{d \cdot p^j} - 1) = v_p(a^d - 1) + j$$

where $v_p$ denotes the p-adic valuation.

### Significance

This theorem is the **algebraic engine** behind order lifting in prime-power moduli — a fundamental mechanism in:

1. **Shor's Algorithm**: The period r found by quantum period-finding satisfies $a^r \equiv 1 \pmod{N}$. The order lifting theorem determines how this period behaves modulo prime powers $p^k \mid N$, controlling whether the GCD step extracts a nontrivial factor.

2. **Hensel's Lemma for Orders**: The multiplicative order of a modulo $p^k$ is precisely $\text{ord}_p(a) \cdot p^{\max(0, k - v_p(a^{\text{ord}_p(a)} - 1))}$, which follows directly from our theorem.

3. **Pollard's p−1 Method**: The smoothness of $\text{ord}_{p^k}(a)$ depends on the p-adic valuation structure, which our theorem makes explicit.

### Proof Strategy

The proof proceeds by induction on j, with the base case being trivial and the inductive step using the **Lifting the Exponent Lemma** (LTE):

$$v_p(x^n - y^n) = v_p(x - y) + v_p(n) \quad \text{when } p \mid (x-y), \; p \nmid x$$

Setting $x = a^{d \cdot p^j}$, $y = 1$, $n = p$, the LTE gives exactly one additional unit of p-adic valuation per p-th power.

## Additional Results

### P-adic Difference of Squares (Section 1)
- `padicVal_diff_sq`: $v_p(x^2 - y^2) = v_p(x-y) + v_p(x+y)$ — the p-adic formulation of the factoring identity
- `padicVal_diff_sq_lte`: LTE-based refinement for odd primes

### Smooth Numbers via P-adic Valuations (Section 3)
- `smooth_iff_padicVal_zero`: n is B-smooth ⟺ $v_p(n) = 0$ for all primes p > B
- `smooth_mul`: Product of smooth numbers is smooth
- `smooth_pow_of_smooth`: Powers of smooth numbers are smooth

### Factoring Criteria (Section 4)
- `padic_factoring_criterion`: GCD-based factor extraction from congruences of squares
- `totient_semiprime`: $\varphi(pq) = (p-1)(q-1)$ for distinct primes

### Shor's Algorithm (Section 5)
- `shor_padic_identity`: $a^{2k} - 1 = (a^k - 1)(a^k + 1)$
- `shor_factor_extraction`: Non-trivial zero divisors from ambiguous square roots

### Valuation Tower (Section 6)
- `padicVal_monotone_dvd`: Monotonicity of valuations under divisibility
- `padicVal_ge_of_pow_dvd`: Lower bound from prime power divisibility
- `padicVal_prime_pow`: $v_p(p^k) = k$
- `padic_determines_eq`: Positive integers are determined by their p-adic valuations (FTA consequence)

## Verification

All 16 theorems are fully proved in Lean 4 with Mathlib, with no `sorry` statements. The proofs use only standard axioms (propext, Classical.choice, Quot.sound).

## File Location

`Algebra/PadicFactoring.lean`
