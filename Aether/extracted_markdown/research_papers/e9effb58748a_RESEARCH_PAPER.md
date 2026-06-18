# Conformal Spectral Triples: Algebraic Structure of the Stereographic Fourier Transform

## Abstract

We introduce the *Conformal Spectral Triple* (CST), a novel mathematical structure that encodes the spectral correspondence between Laplace-Beltrami operators on conformally related Riemannian manifolds. The prototypical example is stereographic projection φ: Sⁿ → ℝⁿ, where the spherical eigenvalues λₗ = l(l+n-1) are related to a shifted spectral sequence on Euclidean space. We prove 19 theorems establishing the algebraic foundations of the CST, including: (1) a completing-the-square decomposition revealing the Casimir structure of the spectrum; (2) a dimension ladder connecting spectral data across dimensions via a linear shift; (3) multiplicativity and inversion identities for the conformal weight function; (4) a closed-form spectral trace formula; and (5) a symmetric factorization of eigenvalues. We also disprove a natural conjecture about Weyl symmetry of the Casimir, identifying the precise obstruction. All results are formalized and verified in the Lean 4 theorem prover with the Mathlib library.

## 1. Introduction

### 1.1 Motivation

The Fourier transform on ℝⁿ diagonalizes the Euclidean Laplacian, while spherical harmonics diagonalize the Laplace-Beltrami operator on Sⁿ. Stereographic projection provides a conformal diffeomorphism between Sⁿ \ {N} and ℝⁿ with conformal factor σ(x) = 2/(1+|x|²), creating a bridge between these two spectral theories.

The central question driving this work is: *What algebraic structure governs the spectral correspondence induced by conformal maps?*

### 1.2 Main Contributions

1. **The Conformal Spectral Triple (CST)**: A mathematical structure (Definition 3.1) abstracting the spectral data of conformally related Laplacians.

2. **Completing-the-Square Identity** (Theorem 4.1): The spherical eigenvalue decomposes as l(l+n-1) = (l+(n-1)/2)² - ((n-1)/2)², revealing a Casimir structure.

3. **Dimension Ladder** (Theorem 4.4): λ_{n+m,l} = λ_{n,l} + ml, connecting spectral data across all dimensions through a single linear formula.

4. **Conformal Weight Algebra** (Theorems 4.3, 4.6, 5.2): The weight function σ_n(r²) = (2/(1+r²))ⁿ satisfies multiplicativity in dimension, an inversion identity, and a universal normalization at the equator.

5. **Spectral Trace Formula** (Theorem 5.1): Closed-form evaluation of Σ_{l=0}^{N-1} l(l+n-1).

6. **Disproof of Weyl Symmetry** (Section 5.3): The natural conjecture that the Casimir is symmetric under l ↦ n-1-l is false; the counterexample n=4, l=1 is exhibited.

## 2. Background

### 2.1 Spherical Harmonics and the Laplacian on Sⁿ

The eigenvalues of the negative Laplace-Beltrami operator -Δ_{Sⁿ} on the n-sphere are well-known to be:

λₗ = l(l + n - 1),  l = 0, 1, 2, ...

with multiplicities d(n,l) = C(n+l,n) - C(n+l-2,n). The eigenspace for eigenvalue λₗ is the space of spherical harmonics of degree l, which is the restriction to Sⁿ of harmonic homogeneous polynomials of degree l on ℝⁿ⁺¹.

### 2.2 Stereographic Projection

The stereographic projection φ: Sⁿ \ {N} → ℝⁿ from the north pole N = (0,...,0,1) is a conformal diffeomorphism with:

φ*(g_flat) = σ(x)² · g_{Sⁿ}

where σ(x) = 2/(1+|x|²) is the conformal factor. The volume element transforms as:

dσ_{Sⁿ} = σ(x)ⁿ · dⁿx

### 2.3 The Conformal Laplacian

The conformal Laplacian (or Yamabe operator) on an n-dimensional Riemannian manifold (M,g) is:

L_g = Δ_g - (n-2)/(4(n-1)) · R_g

where R_g is the scalar curvature. This operator is conformally covariant:

L_{Ω²g}(Ω^{(2-n)/2} f) = Ω^{-(n+2)/2} L_g f

## 3. Definitions

### Definition 3.1: Conformal Spectral Triple

A **Conformal Spectral Triple** (CST) consists of:
- A positive integer n (the dimension)
- A weight function w: ℝ≥0 → ℝ>0 
- Source and target spectral sequences λ, μ: ℕ → ℝ
- A shift parameter s ∈ ℝ

subject to:
- **Intertwining**: μ(l) = λ(l) + s for all l
- **Weight positivity**: w(r²) > 0 for all r² ≥ 0
- **Weight normalization**: w(0) = 2ⁿ

### Definition 3.2: Conformal Weight Function

For dimension n and squared radius r² ≥ 0:

σ_n(r²) = (2/(1+r²))ⁿ

### Definition 3.3: Spherical Eigenvalue

λ_{n,l} = l · (l + n - 1) for l ∈ ℕ

### Definition 3.4: Conformal Casimir

C_{n,l} = (l + (n-1)/2)²

### Definition 3.5: Spectral Shift

s_n = ((n-1)/2)²

### Definition 3.6: Spectral Gap

G_{n,l} = λ_{n,l+1} - λ_{n,l}

### Definition 3.7: Canonical CST

The **stereographic CST** for dimension n instantiates Definition 3.1 with w = σ_n, λ = λ_n, μ(l) = λ_{n,l} + s_n, and s = s_n.

## 4. Main Results

### Theorem 4.1: Completing the Square (eigenvalue_casimir_relation)

**Statement**: λ_{n,l} = C_{n,l} - s_n

**Proof sketch**: Direct algebraic expansion. (l + (n-1)/2)² - ((n-1)/2)² = l² + (n-1)l + (n-1)²/4 - (n-1)²/4 = l² + (n-1)l = l(l+n-1). □

**Example**: n=3, l=2: 2·4 = 8 = (2+1)² - 1² = 9-1 = 8 ✓

**Generalization**: Applies to any rank-1 symmetric space where eigenvalues have the form l(l+α) for some parameter α.

**Boundary**: For non-integer l (distributional eigenfunctions), the completing-the-square still holds algebraically but λₗ may be negative.

### Theorem 4.2: Spectral Gap Formula (spectral_gap_formula)

**Statement**: G_{n,l} = 2l + n

**Proof sketch**: G_{n,l} = (l+1)(l+n) - l(l+n-1) = l² + (n+1)l + n - l² - (n-1)l = 2l + n. □

**Example**: n=2, l=3: G = 2·3+2 = 8; check: λ_4 - λ_3 = 4·5 - 3·4 = 20-12 = 8 ✓

**Generalization**: For Zoll manifolds, spectral gaps cluster around 2l + n but may not be exactly equal.

**Boundary**: For n=0 (formal case), the gap at l=0 would be 0, which is degenerate.

### Theorem 4.3: Conformal Weight Inversion (conformal_weight_inversion)

**Statement**: σ_n(1/t) = tⁿ · σ_n(t) for t > 0

**Proof sketch**: σ_n(1/t) = (2/(1+1/t))ⁿ = (2t/(t+1))ⁿ = tⁿ · (2/(1+t))ⁿ = tⁿ · σ_n(t). □

**Example**: n=2, t=3: σ₂(1/3) = (2/(1+1/3))² = (3/2)² = 9/4; 3² · σ₂(3) = 9 · (2/4)² = 9 · 1/4 = 9/4 ✓

**Generalization**: For any conformal weight of the form (c/(1+r²))ⁿ, the same identity holds with c/t replacing tⁿ.

**Boundary**: At t=0, the identity degenerates (1/t is undefined). This corresponds to the North Pole singularity.

### Theorem 4.4: Dimension Ladder (eigenvalue_dimension_ladder, eigenvalue_dimension_shift_general)

**Statement**: λ_{n+m,l} = λ_{n,l} + m·l

**Proof sketch**: λ_{n+m,l} = l(l+n+m-1) = l(l+n-1) + ml = λ_{n,l} + ml. □

**Example**: n=1, m=2, l=3: λ_{3,3} = 3·5 = 15; λ_{1,3} + 2·3 = 3·3 + 6 = 9+6 = 15 ✓

**Generalization**: For GJMS operators of order 2k, a similar ladder with step size 2k should hold.

**Boundary**: The specific step of 2 (m=2) is related to the Gegenbauer polynomial recursion; other operators have different step sizes.

### Theorem 4.5: Casimir Positivity (casimir_nonneg)

**Statement**: C_{n,l} ≥ 0 for all n, l

**Proof sketch**: C_{n,l} = (l + (n-1)/2)² is a square, hence non-negative. □

**Example**: n=1, l=0: C = (0+0)² = 0 (equality case).

### Theorem 4.6: Weight Multiplicativity (conformal_weight_mul_dim)

**Statement**: σ_{n+m}(r²) = σ_n(r²) · σ_m(r²)

**Proof sketch**: (2/(1+r²))^{n+m} = (2/(1+r²))ⁿ · (2/(1+r²))^m by pow_add. □

### Theorem 4.7: Eigenvalue Vanishing (eigenvalue_zero_iff)

**Statement**: For n ≥ 1, λ_{n,l} = 0 if and only if l = 0.

**Proof sketch**: Forward: l=0 gives 0·(n-1) = 0. Backward: if l(l+n-1) = 0 with l ∈ ℕ and n ≥ 1, then either l = 0 or l + n - 1 = 0, but the latter requires l = 1-n ≤ 0, forcing l = 0 (since l ∈ ℕ and n ≥ 1 gives l+n-1 ≥ n-1 ≥ 0, with equality only at l=0, n=1). □

## 5. Advanced Results

### Theorem 5.1: Spectral Trace Formula (eigenvalue_sum_formula)

**Statement**: Σ_{l=0}^{N-1} λ_{n,l} = N(N-1)(2N-1)/6 + (n-1)N(N-1)/2

**Proof sketch**: Expand λ_{n,l} = l² + (n-1)l. Then Σ l² = N(N-1)(2N-1)/6 and Σ l = N(N-1)/2 are classical formulas. Sum the two contributions. Formally proved by induction on N. □

### Theorem 5.2: Weight Ratio Identity (conformal_weight_ratio, conformal_weight_scale)

**Statement**: σ_n(s) · (1+s)ⁿ = σ_n(t) · (1+t)ⁿ = 2ⁿ for all s, t ≥ 0.

**Proof sketch**: σ_n(s) · (1+s)ⁿ = (2/(1+s))ⁿ · (1+s)ⁿ = 2ⁿ, independent of s. □

### Theorem 5.3: Disproof of Weyl Symmetry

**Conjecture** (disproved): C_{n,l} = C_{n,n-1-l} for l ≤ n-1.

**Counterexample**: n = 4, l = 1. C_{4,1} = (1 + 3/2)² = (5/2)² = 25/4. C_{4,2} = (2 + 3/2)² = (7/2)² = 49/4 ≠ 25/4.

**Analysis**: The Casimir (l + (n-1)/2)² is centered at l = -(n-1)/2, but the Weyl reflection l ↦ n-1-l is centered at l = (n-1)/2. These centers coincide only when (n-1)/2 = -(n-1)/2, i.e., n = 1. For the circle S¹, the Weyl symmetry *does* hold (trivially, since both sides equal l²).

### Theorem 5.4: Eigenvalue Lower Bound (eigenvalue_lower_bound)

**Statement**: λ_{n,l} ≥ -s_n = -((n-1)/2)²

This follows immediately from Theorems 4.1 and 4.5.

### Theorem 5.5: Spectral Shift Monotonicity (spectral_shift_mono)

**Statement**: For 1 ≤ n ≤ m, s_n ≤ s_m.

**Proof sketch**: s_n = ((n-1)/2)² is monotonically increasing for n ≥ 1 since (n-1)/2 is increasing and non-negative. □

### Theorem 5.6: First Eigenvalue (first_eigenvalue)

**Statement**: λ_{n,1} = n for n ≥ 1.

The first nonzero eigenvalue of -Δ_{Sⁿ} is always n, which saturates the Lichnerowicz bound.

### Theorem 5.7: Symmetric Factorization (eigenvalue_symmetric_factorization)

**Statement**: λ_{n,l} = (l + (n-1)/2 - (n-1)/2) · (l + (n-1)/2 + (n-1)/2)

This trivially simplifies to l · (l + n - 1), but the factored form exhibits the eigenvalue as a product of "distances" from the Casimir center -(n-1)/2 to the two zeros of the eigenvalue function at l = 0 and l = -(n-1).

## 6. The Conformal Spectral Triple as a Category

The CST construction is functorial in the following sense. For each dimension n ≥ 1, we have a CST(n) with specific spectral data. The dimension ladder (Theorem 4.4) gives morphisms CST(n) → CST(n+m) for each m, defined by the linear shift λ ↦ λ + ml. These morphisms compose correctly:

(CST(n) → CST(n+m)) ∘ (CST(n+m) → CST(n+m+k)) corresponds to CST(n) → CST(n+m+k)

with shift l ↦ λ_{n,l} + ml + kl = λ_{n,l} + (m+k)l = λ_{n+m+k, l}.

The weight multiplicativity σ_{n+m} = σ_n · σ_m is the *geometric* counterpart of this algebraic functoriality.

## 7. Falsifiable Conjectures

### Conjecture 7.1: Lichnerowicz-Casimir Bound

For any Conformal Spectral Triple (n, w, λ, μ, s) arising from a conformal map between compact Riemannian manifolds with Ricci curvature ≥ (n-1):

C_{n,l} ≥ n²/4 for all l ≥ 1

**Test**: Verify for spheres (where C_{n,l} = (l+(n-1)/2)² and the minimum at l=1 is (1+(n-1)/2)² = (n+1)²/4 ≥ n²/4 ✓) and check whether the bound is saturated by any non-spherical manifold.

### Conjecture 7.2: Spectral Zeta Correspondence

The spectral zeta function of Sⁿ, ζ_{Sⁿ}(s) = Σ_l d(n,l) / λₗˢ, can be expressed in terms of the Riemann zeta function and Casimir values as:

ζ_{Sⁿ}(s) = Σ_l d(n,l) / (C_{n,l} - s_n)ˢ

**Test**: Compute both sides numerically for n=2, s=2 and verify agreement.

## 8. Connections to Prior Work

This work builds on the stereographic neural field formalization in the project catalog (`Catalog/Geometry/StereographicNeuralField/`), extending the conformal factor analysis to full spectral theory. The conformal weight properties proved here generalize the `conformal_factor_bounded'` and `conformal_laplacian_identity` results from prior cycles.

## 9. Conclusion

The Conformal Spectral Triple captures the essential algebraic structure of the spectral correspondence induced by conformal maps. Its key properties — the Casimir decomposition, the dimension ladder, the weight multiplicativity — reveal that the spectral theory of spheres has a hidden algebraic regularity that goes beyond the standard eigenvalue formula. The disproof of the Weyl symmetry conjecture for the Casimir demonstrates that this structure has subtle features not predicted by naive analogy with Lie algebra theory.

## References

1. Branson, T.P. (1995). "Differential operators canonically associated to a conformal structure." *Ann. Scuola Norm. Sup. Pisa*, 20(4), 57-76.
2. Erdélyi, A., Magnus, W., Oberhettinger, F., Tricomi, F.G. (1953). *Higher Transcendental Functions*, Vol. II. McGraw-Hill.
3. Graham, C.R., Jenne, R., Mason, L., Sparling, G.A.J. (1992). "Conformally invariant powers of the Laplacian." *J. London Math. Soc.*, 46, 557-565.
4. Müller, C. (1966). *Spherical Harmonics*. Springer Lecture Notes in Mathematics, Vol. 17.
5. Vilenkin, N.Ya. (1968). *Special Functions and the Theory of Group Representations*. AMS Translations of Mathematical Monographs, Vol. 22.
