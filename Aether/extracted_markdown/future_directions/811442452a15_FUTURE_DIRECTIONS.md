# Future Directions

## Direction 1: Formal Hilbert Series of Polynomial Rings

### Theorem Statement
```lean
theorem hilbert_series_mvPolynomial (n : ℕ) :
    (∑ m in Finset.range N, (finrank K (homogeneousComponent' K (Fin n) m)) * X^m : PowerSeries K) 
    = ... -- truncation of 1/(1-X)^n
```

More precisely, formalize that the Hilbert function H(m) = C(m+n-1, n-1) satisfies the generating function identity ∑ H(m) t^m = 1/(1-t)^n as formal power series.

### Why It Matters
The Hilbert series is the fundamental invariant of graded algebras. For polynomial rings it has the closed form 1/(1-t)^n, and for quotient rings by homogeneous ideals it becomes a rational function whose numerator encodes deep geometric information (the h-vector). Formalizing the polynomial ring case is the essential first step toward formalized Hilbert polynomial theory, which is the backbone of algebraic geometry's dimension theory.

### Dependencies
- `finrank_homogeneousComponent` (proved in this work)
- Mathlib's `PowerSeries` or `RatFunc` framework
- Binomial series identity for (1-t)^{-n}

### Estimated Difficulty
**Medium.** The individual Hilbert function values are already formalized. The main challenge is connecting to formal power series and proving the closed-form identity.

---

## Direction 2: Dimension of Quotients by Monomial Ideals

### Theorem Statement
```lean
theorem finrank_quotient_monomial_ideal
    (I : Ideal (MvPolynomial σ K)) (hI : I.IsMonomial) (d : ℕ) :
    finrank K (boundedTotalDegreeSubmodule K σ d ⧸ (I.comap (Submodule.subtype _))) 
    = Fintype.card {s : σ →₀ ℕ // degree s < d ∧ monomial s 1 ∉ I}
```

### Why It Matters  
The "standard monomials" — those not in a monomial ideal — form a basis for the quotient. This is the foundation of:
- **Gröbner basis theory**: computing with polynomial ideals
- **Hilbert function computation**: the Hilbert function of R/I counts standard monomials by degree
- **Combinatorial commutative algebra**: Stanley-Reisner rings, face rings, and their algebraic topology

### Dependencies
- Monomial basis (proved in this work)
- Mathlib's ideal quotient infrastructure
- Definition of monomial ideals and the standard monomial set

### Estimated Difficulty
**Medium-Hard.** The key challenge is formalizing the quotient basis theorem: that standard monomials form a basis for R/I when I is a monomial ideal. This requires careful handling of the quotient module structure.

---

## Direction 3: Reed-Muller Code Rate and Distance Theorem

### Theorem Statement
```lean
theorem reed_muller_dimension (q r m : ℕ) (hq : q.Prime) :
    finrank (ZMod q) (boundedTotalDegreeSubmodule (ZMod q) (Fin m) (r + 1)) 
    = Nat.choose (m + r) m

theorem reed_muller_minimum_distance (r m : ℕ) :
    minimum_distance (reed_muller_code r m) = (q - 1)^(m - r) * q^(⌊(m-r-1)/(q-1)⌋)
```

### Why It Matters
Reed-Muller codes are among the most important families of error-correcting codes, used in space communications (Mariner 9), 5G wireless standards, and theoretical computer science (PCP theorem, hardness amplification). Formalizing their parameters would:
- Provide the first formally verified code dimension theorem for a major code family
- Connect algebraic geometry (evaluation codes) with information theory
- Enable formal verification of coding-theoretic security proofs

### Dependencies
- Bounded-degree dimension formula (proved in this work, specialization to finite fields)
- Evaluation map: MvPolynomial σ F_q → (σ → F_q) → F_q
- Schwartz-Zippel lemma (for minimum distance)

### Estimated Difficulty
**Hard.** The dimension part follows from this work. The minimum distance requires the Schwartz-Zippel lemma or a direct combinatorial argument, which is significantly more involved.

---

## Direction 4: Multivariate Interpolation Theorem

### Theorem Statement
```lean
theorem multivariate_interpolation 
    (K : Type*) [Field K] (σ : Type*) [Fintype σ] [DecidableEq σ] (d : ℕ)
    (points : Fin N → (σ → K)) (values : Fin N → K)
    (hN : N = Fintype.card (boundedMonomialExponents σ d))
    (h_general : GeneralPosition points) :
    ∃! p : MvPolynomial σ K, p ∈ boundedTotalDegreeSubmodule K σ d ∧ 
      ∀ i, MvPolynomial.eval (points i) p = values i
```

### Why It Matters
This theorem — that N = C(d+n-1, n) points in "general position" determine a unique polynomial of degree < d — is the multivariate generalization of Lagrange interpolation. It has applications in:
- **Cryptography**: secret sharing (Shamir's scheme generalizations)
- **Numerical analysis**: multivariate quadrature rules
- **Algebraic complexity**: interpolation-based lower bounds

### Dependencies
- Monomial basis (proved in this work)
- Evaluation map as a linear map
- Vandermonde-type determinant non-vanishing for points in general position
- Definition of "general position" for multivariate points

### Estimated Difficulty
**Hard.** The key challenge is formalizing "general position" and proving the Vandermonde determinant is nonzero. The univariate case (Lagrange interpolation) is likely a prerequisite.

---

## Direction 5: Graded Noether Normalization and Hilbert Polynomial

### Theorem Statement
```lean
theorem hilbert_polynomial_exists
    (R : Type*) [CommRing R] [GradedAlgebra R] [IsNoetherian R] :
    ∃ (P : Polynomial ℚ) (m₀ : ℕ), ∀ m ≥ m₀, 
      hilbert_function R m = P.eval (m : ℚ)
```

### Why It Matters
The Hilbert polynomial is arguably the most important invariant in algebraic geometry. It encodes:
- The **dimension** of a projective variety (as the degree of the polynomial)
- The **degree** of the variety (as the leading coefficient times d!)
- The **arithmetic genus** and other numerical invariants

Formalizing even a toy version (e.g., for polynomial rings modulo homogeneous ideals generated by a regular sequence) would be a major milestone for formalized algebraic geometry.

### Dependencies
- Hilbert series formalization (Direction 1)
- Partial fraction decomposition of rational functions
- Noether normalization lemma (at least a special case)
- Connection between pole order and polynomial degree

### Estimated Difficulty
**Very Hard.** This requires substantial development of graded algebra infrastructure. A realistic first target would be the special case of polynomial rings, where the Hilbert polynomial is just the polynomial whose values are C(m+n-1, n-1).

---

## Cross-Cutting Research Program

These five directions form a coherent research program connecting:

```
Direction 1 (Hilbert Series)
    ↓
Direction 5 (Hilbert Polynomial) ← Direction 2 (Monomial Ideals)
    ↓
Direction 4 (Interpolation) ← Direction 3 (Reed-Muller)
```

The bounded-degree dimension formula proved in this work is the foundation for all five directions. Directions 1 and 2 are natural next steps building directly on this infrastructure. Direction 3 connects to coding theory. Direction 4 connects to numerical analysis and cryptography. Direction 5 is the ultimate goal connecting to algebraic geometry.

**Recommended execution order**: 1 → 2 → 3 → 4 → 5, with 3 and 4 partially parallelizable.
