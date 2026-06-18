# Future Directions: Certified Algebraic Coding Theory

## Overview

This document outlines specific, actionable research directions opened by the formal verification of Reed-Solomon distance, BCH bounds, and syndrome decoding infrastructure. Each direction includes exact theorem targets, proof strategies, estimated difficulty, and cross-domain connections.

---

## Direction 1: Berlekamp-Massey Correctness via Loop Invariant

### Status: Partially formalized (algorithm implemented, proof incomplete)

### Target Theorems

```
theorem bm_satisfies {K : Type*} [Field K] [DecidableEq K]
    (s : ℕ → K) (N : ℕ) :
    satisfiesOn (berlekampMassey' s N) s N

theorem bm_minimal {K : Type*} [Field K] [DecidableEq K]
    (s : ℕ → K) (N : ℕ) :
    ∀ C' : LinRec K, satisfiesOn C' s N →
      (berlekampMassey' s N).len ≤ C'.len
```

### Proof Strategy

1. Define the BM loop invariant precisely:
   - After step m, the current polynomial C annihilates s[0..m-1]
   - L is the minimum recurrence length for s[0..m-1]
   - B records the state at the last length increase
   - The "shift bound": L + L_prev ≥ m + 1 at every step

2. Prove invariant preservation for each case:
   - Discrepancy = 0: trivial preservation
   - Discrepancy ≠ 0, 2L ≤ m: length update case
   - Discrepancy ≠ 0, 2L > m: coefficient update only

3. Key lemma: the "unique minimal polynomial" theorem — for sequences of length 2L, the minimal recurrence of length L is unique up to scalar.

### Estimated Difficulty: High (requires careful invariant tracking across multiple cases)

### Cross-Domain Impact
- Cryptography: Certified LFSR synthesis for formal cryptanalysis
- Signal processing: Verified Prony's method for spectral estimation
- Control theory: Certified system identification

---

## Direction 2: Guruswami-Sudan List Decoding

### Status: Not started

### Target Theorem

```
theorem guruswami_sudan_list_decode
    {K : Type*} [Field K] [DecidableEq K] [Fintype K]
    {n k : ℕ} (α : Fin n → K) (hα : Function.Injective α)
    (r : Fin n → K) (t : ℕ) (ht : t > n - Nat.sqrt (n * (k - 1))) :
    ∃ L : Finset (K[X]),
      (∀ p ∈ L, p.natDegree < k ∧ hammingD r (RSEncode α p) ≤ t) ∧
      L.card ≤ Nat.sqrt (n / (k - 1))
```

### Proof Strategy

1. **Interpolation step:** Construct a bivariate polynomial Q(X, Y) of bounded (1, k-1)-weighted degree that vanishes at all points (αᵢ, rᵢ) with multiplicity ≥ m.
2. **Factorization step:** Show that any polynomial p with deg p < k and d(r, ev(p)) ≤ t must divide Q(X, p(X)).
3. **Root bound:** The number of such factors is bounded by the Y-degree of Q.

### Key Prerequisites
- Bivariate polynomial rings (partially in Mathlib as `MvPolynomial`)
- Multiplicity of vanishing at a point
- Hasse derivative formulation
- Factorization of bivariate polynomials

### Estimated Difficulty: Very High (novel formalization territory)

### Cross-Domain Impact
- Complexity theory: Connections to locally decodable codes
- Algebraic geometry: Curve-line intersection theory
- Combinatorics: Polynomial method applications

---

## Direction 3: Welch-Berlekamp Key Equation Solver

### Status: Not started

### Target Theorem

```
theorem welch_berlekamp_correct
    {K : Type*} [Field K] [DecidableEq K]
    {n k t : ℕ} (α : Fin n → K) (hα : Function.Injective α)
    (r : Fin n → K)
    (c : Fin n → K) (hc : c ∈ RSCode n α k)
    (he : hammingD r c ≤ t) (ht : 2 * t < n - k + 1) :
    ∃! (E N : K[X]),
      E.natDegree = t ∧ E.Monic ∧
      (∀ i, r i * E.eval (α i) = N.eval (α i)) ∧
      (∀ i, c i = N.eval (α i) / E.eval (α i))
```

### Proof Strategy

1. Set up the key equation: find E(X) (error-locator) and N(X) (error-evaluator) such that r(αᵢ)·E(αᵢ) = N(αᵢ) for all i.
2. This is a system of n linear equations in the coefficients of E and N.
3. Prove the system has a unique solution when the number of errors ≤ t < (n-k+1)/2.

### Estimated Difficulty: Medium-High

---

## Direction 4: MacWilliams Identities for Weight Enumerators

### Status: Not started

### Target Theorem

```
theorem macwilliams_identity
    {n : ℕ} {K : Type*} [Field K] [Fintype K] [DecidableEq K]
    (C : Submodule K (Fin n → K)) :
    weightEnumerator (dualCode C) =
      (1 / Fintype.card K ^ C.finrank) •
      macwilliamsTransform (weightEnumerator C)
```

### Proof Strategy

1. Define weight enumerator W_C(x, y) = ∑_{c ∈ C} x^(n - wt(c)) · y^(wt(c))
2. Define dual code C⊥ and MacWilliams transform
3. Prove using character sum techniques over finite fields
4. Key ingredient: orthogonality of characters of (K^n, +)

### Key Prerequisites
- Dual codes as submodules
- Character theory of finite abelian groups (in Mathlib)
- Generating functions / formal power series

### Estimated Difficulty: Medium

### Cross-Domain Impact
- Combinatorics: Connections to Krawtchouk polynomials
- Physics: Partition functions in statistical mechanics
- Number theory: Theta functions of lattices

---

## Direction 5: Finite-Field Linear Complexity Profile

### Status: Partially formalized (BM infrastructure exists)

### Target Theorems

```
theorem linear_complexity_profile_subadditive
    {K : Type*} [Field K] [DecidableEq K]
    (s : ℕ → K) (m n : ℕ) :
    linearComplexity s (m + n) ≤ linearComplexity s m + linearComplexity s n

theorem linear_complexity_random_expected
    {p : ℕ} [Fact (Nat.Prime p)] (n : ℕ) :
    expectedLinearComplexity (ZMod p) n = n / 2 + (2 + δ) / 36
    -- where δ depends on parity of n
```

### Proof Strategy

1. Define L(s, n) = minimal recurrence length for prefix of length n
2. Prove subadditivity from BM algorithm properties
3. For the expected value, use the BM algorithm's deterministic behavior to compute exact probabilities over uniform random sequences

### Estimated Difficulty: Medium

### Cross-Domain Impact
- Cryptography: Stream cipher security analysis
- Information theory: Kolmogorov complexity connections
- Automata theory: Minimal state machines

---

## Direction 6: Algebraic Geometry Codes (Goppa Codes)

### Status: Not started (requires substantial Mathlib infrastructure)

### Target Theorem

```
theorem goppa_code_distance_bound
    {K : Type*} [Field K] [Fintype K]
    (C : ProjectiveCurve K) (D G : Divisor C)
    (hG : G.degree < D.degree) :
    codeMinWeight (goppaCode C D G) ≥ D.degree - G.degree
```

### Prerequisites
- Algebraic curves over finite fields
- Divisors and Riemann-Roch theorem
- Evaluation maps on function spaces

### Estimated Difficulty: Very High (requires algebraic geometry infrastructure)

### Cross-Domain Impact
- Number theory: Connections to zeta functions of curves
- Asymptotic coding theory: Tsfasman-Vlăduț-Zink bound exceeding Gilbert-Varshamov

---

## Direction 7: Sparse Fourier Decoding over Finite Fields

### Status: Not started

### Target Theorem

```
theorem sparse_fourier_recovery
    {p n : ℕ} [Fact (Nat.Prime p)]
    (f : ZMod n → ZMod p) (k : ℕ)
    (hk : card (support (fourierTransform f)) ≤ k) :
    ∃ alg : SparseFourierAlgorithm,
      alg.query_complexity = O(k * log n) ∧
      alg.recovers f
```

### Proof Strategy

1. Formalize finite-field Fourier transform as evaluation at characters
2. Connect to BCH syndrome computation
3. Apply BM-based recovery

### Cross-Domain Impact
- Signal processing: Sub-Nyquist sampling
- Compressed sensing: Sparse recovery algorithms
- Computational complexity: Sublinear algorithms

---

## Direction 8: Quantum Error-Correcting Codes (CSS Construction)

### Status: Not started (requires quantum information infrastructure)

### Target Theorem

```
theorem css_code_distance
    {n : ℕ} (C₁ C₂ : LinearCode (ZMod 2) n)
    (h : C₂ ≤ C₁) :
    quantumDistance (cssCode C₁ C₂) =
      min (codeMinWeight (C₁ \ C₂)) (codeMinWeight (dualCode C₂ \ dualCode C₁))
```

### Prerequisites
- Linear codes over GF(2)
- Dual codes
- Basic quantum information definitions

### Estimated Difficulty: High

### Cross-Domain Impact
- Quantum computing: Fault-tolerant quantum computation
- Topology: Connections to topological codes (toric codes)

---

## Priority Ordering

1. **BM correctness** (Direction 1) — Closes the main remaining gap
2. **Welch-Berlekamp** (Direction 3) — Practical decoding algorithm verification
3. **MacWilliams identities** (Direction 4) — Beautiful structural theorem
4. **Linear complexity profile** (Direction 5) — Extends BM infrastructure
5. **List decoding** (Direction 2) — Major theoretical advance
6. **Sparse Fourier** (Direction 7) — Cross-domain breakthrough
7. **AG codes** (Direction 6) — Deep algebraic geometry
8. **Quantum codes** (Direction 8) — Emerging applications

## Estimated Timeline

- Directions 1, 3: 2-4 weeks each
- Directions 4, 5: 3-6 weeks each
- Directions 2, 7: 2-4 months each
- Directions 6, 8: 4-8 months each (significant infrastructure needed)
