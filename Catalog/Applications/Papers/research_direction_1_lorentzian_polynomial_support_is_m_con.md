# Lorentzian Polynomial Supports and M-Convex Exchange: A Formal Development

## Abstract

We present a partial formalization in Lean 4 of the Brändén–Huh theorem connecting Lorentzian polynomials to M-convex sets. We introduce formal definitions of Newton supports, Lorentzian quadratic forms (via spectral decomposition), and the M-convex exchange property for integer-valued finitely supported functions. We establish the complete algebraic infrastructure for the quadratic base case, proving: (1) a coefficient formula for partial derivatives of multivariate polynomials, (2) the Cauchy-Schwarz inequality for PSD matrices, (3) a key 3×3 determinant lemma showing that PSD constraints force entry values, and (4) a core exchange lemma proving that the Lorentzian decomposition H = vvᵀ - B (B PSD) forces support exchange connectivity. We also provide computational demonstrations in Python verifying the theorem for small instances.

## 1. Introduction

### 1.1 Background

The theory of Lorentzian polynomials, introduced by Brändén and Huh [BH20], provides a unified framework connecting algebraic geometry, combinatorics, and optimization. A central result is that the Newton support of a Lorentzian polynomial satisfies the symmetric exchange property — making it an M-convex set in the sense of Murota's discrete convex analysis [Mur03].

This theorem bridges:
- **Continuous geometry**: Hessian curvature conditions (at most one positive eigenvalue)
- **Discrete combinatorics**: The exchange axiom for matroid-like structures

### 1.2 Contributions

Our formalization introduces:

1. **Novel definitions** for Lorentzian quadratics via spectral decomposition (H = vvᵀ - B with v ≥ 0, B PSD), Newton supports as sets of Finsupp elements, and M-convex exchange on natural-number-valued finitely supported functions.

2. **17 formally verified lemmas and theorems** including:
   - Coefficient formula for partial derivatives (`coeff_pderiv_eq`)
   - Support characterization of derivatives (`newtonSupport_pderiv_eq`)
   - Cauchy-Schwarz for PSD bilinear forms (`psd_cauchy_schwarz`)
   - Key 3×3 determinant constraint (`psd_triple_determines_entry`)
   - Core exchange lemma from spectral decomposition (`exchange_from_decomp`)

3. **Python computational verification** for small-degree, small-variable instances.

## 2. Definitions and Notation

### 2.1 Newton Support

For a multivariate polynomial f ∈ ℝ[x₁,...,xₙ], the **Newton support** is:

```
NewtonSupport(f) = {m ∈ (Fin n →₀ ℕ) | coeff(m, f) ≠ 0}
```

This is formalized as a `Set (σ →₀ ℕ)` in Lean.

### 2.2 Homogeneity

A polynomial f is **homogeneous of degree d** if every monomial with nonzero coefficient has total degree d:

```
IsHomogeneousDeg d f ⟺ ∀ m, coeff(m, f) ≠ 0 → Σᵢ m(i) = d
```

### 2.3 M-Convex Exchange

A set S ⊆ (σ →₀ ℕ) satisfies the **M-convex exchange property** if:

```
∀ α ∈ S, ∀ β ∈ S, ∀ i with α(i) > β(i),
  ∃ j with α(j) < β(j) and α - eᵢ + eⱼ ∈ S
```

### 2.4 Lorentzian Quadratic

A degree-2 homogeneous polynomial f is **Lorentzian quadratic** if:
1. All coefficients are nonnegative
2. The Hessian matrix H (where H(i,j) = ∂²f/∂xᵢ∂xⱼ evaluated at 0) admits a decomposition:

```
H(i,j) = v(i)·v(j) - B(i,j)
```

where v : Fin n → ℝ has v(i) ≥ 0 for all i, and B is a positive semidefinite symmetric matrix.

This is equivalent to H having at most one positive eigenvalue, by spectral decomposition and the Perron-Frobenius theorem for nonneg matrices.

### 2.5 PSD Matrices

A matrix B : Fin n → Fin n → ℝ is **positive semidefinite** if:

```
∀ u : Fin n → ℝ, Σᵢ Σⱼ B(i,j)·u(i)·u(j) ≥ 0
```

## 3. Main Results

### 3.1 Derivative Support Theorem

**Theorem** (coeff_pderiv_eq). For f ∈ ℝ[x₁,...,xₙ], i ∈ Fin n, m : Fin n →₀ ℕ:

```
coeff(m, ∂f/∂xᵢ) = (m(i) + 1) · coeff(m + eᵢ, f)
```

This is proved by induction on f using `MvPolynomial.induction_on'`, reducing to the monomial case via `MvPolynomial.pderiv_monomial`.

**Corollary** (newtonSupport_pderiv_eq).

```
NewtonSupport(∂f/∂xᵢ) = {m | m + eᵢ ∈ NewtonSupport(f)}
```

### 3.2 Cauchy-Schwarz for PSD Matrices

**Theorem** (psd_cauchy_schwarz). If B is PSD and symmetric, then for all i, j:

```
B(i,j)² ≤ B(i,i) · B(j,j)
```

Proof: Specialize the PSD condition with u = t·eᵢ + s·eⱼ to obtain a nonneg quadratic in t, s. The discriminant condition gives the result.

### 3.3 The 3×3 Determinant Lemma

**Theorem** (psd_triple_determines_entry). If B is PSD symmetric with:
- B(b,b) = vb², B(c,c) = vc², B(d,d) = vd²
- B(b,c) = vb·vc, B(b,d) = vb·vd
- vb > 0

Then B(c,d) = vc·vd.

*Proof sketch*: Substitute u(b) = -(vc·s + vd)/vb, u(c) = s, u(d) = 1, u(k) = 0 otherwise into the PSD condition. After algebraic simplification, the sum reduces to 2s·(B(c,d) - vc·vd) ≥ 0 for all s ∈ ℝ. This forces B(c,d) = vc·vd.

This is the key algebraic insight: once enough entries of B are "saturated" (equal to the outer product v⊗v), the remaining entries are forced to be saturated too. Geometrically, the PSD constraint on B propagates equality through the matrix.

### 3.4 Core Exchange Lemma

**Theorem** (exchange_from_decomp). Let v ≥ 0, B PSD symmetric, with v(k)·v(l) ≥ B(k,l) for all k, l. If v(a)·v(b) > B(a,b) and v(c)·v(d) > B(c,d) with all four indices distinct, then:

```
v(b)·v(c) > B(b,c)  ∨  v(b)·v(d) > B(b,d)
```

*Proof*: By contradiction. If both fail, then B(b,c) = v(b)·v(c) and B(b,d) = v(b)·v(d). From the strict inequality, v(b) > 0, v(c) > 0, v(d) > 0. By `psd_equality_forces_diagonal`: B(b,b) = v(b)², B(c,c) = v(c)², B(d,d) = v(d)². By `psd_triple_determines_entry`: B(c,d) = v(c)·v(d). But then v(c)·v(d) > B(c,d) = v(c)·v(d), contradiction.

### 3.5 Hessian-Coefficient Relationship

**Theorem** (hessianCoeff_eq_coeff_off_diag). For i ≠ j:
```
HessianCoeff(f, i, j) = coeff(eᵢ + eⱼ, f)
```

**Theorem** (hessianCoeff_eq_coeff_diag). For all i:
```
HessianCoeff(f, i, i) = 2 · coeff(2eᵢ, f)
```

### 3.6 Degree-2 Classification

**Theorem** (degree2_finsupp_classification). If m : Fin n →₀ ℕ has total degree 2, then either:
- m = single(a, 2) for some a (squared variable), or
- m = single(a, 1) + single(b, 1) for some a ≠ b (product of two variables)

## 4. Proof Architecture for the Full Theorem

The quadratic exchange theorem follows from the lemmas above via case analysis:

1. Classify α, β ∈ NewtonSupport(f) using degree-2 classification
2. For overlapping indices: the exchange element is often β itself
3. For disjoint indices: apply `exchange_from_decomp` with the Hessian decomposition
4. For mixed cases (squared vs. product): use the spectral positivity argument

The full case analysis involves ~8 sub-cases but is mathematically routine once the core exchange lemma is established.

For the inductive step (degree d > 2):
1. Show partial derivatives preserve the Lorentzian property
2. Apply the exchange theorem to each derivative
3. Lift M-convexity from derivative supports to the original support

## 5. Computational Experiments

### 5.1 Verification for n=3, d≤4

We implemented a Python verification (see `demo.py`) that:
1. Enumerates all degree-d homogeneous supports in 3 variables
2. Tests the Lorentzian condition via eigenvalue computation
3. Verifies M-convex exchange for each Lorentzian support

**Result**: No counterexamples found for n=3, d≤4 with coefficients in {0, 1, 2}.

### 5.2 Algorithm Complexity

The Lorentzian test requires O(n^(d-2) · n²) time for degree d in n variables (iterating over derivative directions and computing 2×2 Hessian minors). The M-convex exchange test requires O(|S|² · n²) time for support set S.

## 6. Applications

### 6.1 Matroid Theory
The bases of a matroid, encoded as indicator vectors, form an M-convex set. The Lorentzian theory provides a new proof: the basis generating polynomial is Lorentzian, so its support is M-convex.

### 6.2 Log-Concavity
If f is Lorentzian and homogeneous, then for any linear specialization, the resulting univariate polynomial has a log-concave coefficient sequence. This follows from M-convexity of the support.

### 6.3 Negative Dependence
Strongly Rayleigh probability measures have Lorentzian generating polynomials. The support theorem implies that the possible outcomes form an M-convex set, enabling efficient sampling algorithms.

## 7. Discussion and Future Work

Our formalization establishes the complete algebraic infrastructure for the Brändén-Huh support theorem in the quadratic case. The remaining gap is the combinatorial case analysis connecting the abstract exchange lemma to the concrete Finsupp manipulation in Lean 4.

Key directions for future work:
1. Complete the quadratic case by automating the Finsupp case analysis
2. Formalize the derivative closure property (Lorentzianity preserved under differentiation)
3. Prove the inductive lifting theorem (M-convexity of derivative supports implies M-convexity of original support)
4. Extend to the valuated setting (M-convex valuations)

## References

- [BH20] P. Brändén and J. Huh, "Lorentzian polynomials," *Annals of Mathematics*, 192(3):821–891, 2020.
- [Mur03] K. Murota, *Discrete Convex Analysis*, SIAM, 2003.
- [Pos09] A. Postnikov, "Permutohedra, associahedra, and beyond," *IMRN*, 2009.
- [Huh22] J. Huh, "Combinatorics and Hodge theory," *Proceedings of the ICM*, 2022.
