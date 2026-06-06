# Spectral Pairing Algebra: Shape-Color Duality in the GL₁ Langlands Correspondence

## Abstract

We introduce the **Spectral Pairing**, a novel algebraic structure axiomatizing the essential properties of the Jacobi symbol as a bilinear map equipped with a reciprocity operator. A Spectral Pairing consists of an evaluation map ℤ → ℕ → ℤ that is multiplicative in both arguments, takes values in {−1, 0, 1}, and satisfies a reciprocity law governing argument exchange. We construct the canonical instance — the Jacobi symbol with the quadratic reciprocity sign — and prove that it satisfies all axioms. We then develop the **kernel theory** of spectral pairings (proving the kernel is a submonoid), establish **square triviality** (perfect squares are spectrally invisible), prove the **reciprocity involution** (the correction sign squares to 1), and demonstrate **character sum vanishing** for the quadratic character. These results are fully formalized in Lean 4 with the Mathlib library, providing machine-verified proofs of fundamental number-theoretic facts recast in the spectral pairing framework.

**Keywords**: Langlands program, quadratic reciprocity, Jacobi symbol, spectral pairing, formal verification, Dirichlet characters

## 1. Introduction

### 1.1 Motivation

The Langlands program, initiated by Robert Langlands in 1967 [1], proposes a deep correspondence between Galois representations ("shapes") and automorphic forms ("colors"). In its simplest incarnation — the GL₁ case over ℚ — this correspondence reduces to class field theory: abelian extensions of ℚ correspond bijectively to Dirichlet characters, and the local correspondence at each prime is mediated by the Legendre/Jacobi symbol.

While the GL₁ Langlands correspondence is well-understood, its algebraic structure has not been previously axiomatized as an independent mathematical object. We fill this gap by defining the **Spectral Pairing** — a structure that captures the interplay of bilinearity, trichotomy, and reciprocity that characterizes the Jacobi symbol.

### 1.2 Main Contributions

1. **Definition of SpectralPairing** (§2): A new algebraic structure axiomatizing bilinear symbols with reciprocity operators.

2. **Canonical instance** (§3): Construction of the Jacobi symbol as a SpectralPairing, with the quadratic reciprocity sign as reciprocity operator.

3. **Kernel theory** (§4): The first kernel of a spectral pairing is closed under multiplication and contains 1 for non-degenerate pairings.

4. **Square triviality** (§5): J(d², p) = 1 for primes p ∤ d, giving the spectral characterization of quadratic residuacity.

5. **Reciprocity involution** (§6): The reciprocity operator satisfies R² = 1, establishing the ℤ/2ℤ-valued bilinear form structure.

6. **Character sum vanishing** (§7): ∑_{a ∈ (ℤ/pℤ)} χ(a) = 0 for the quadratic character of an odd prime.

7. **Frobenius detectors** (§8): J(−1, p) = 1 ⟺ p ≡ 1 (mod 4), and J(2, p) = 1 ⟺ p ≡ ±1 (mod 8).

8. **Matrix transposition** (§9): Quadratic reciprocity as near-symmetry of the splitting matrix.

All results are formalized in Lean 4 with Mathlib, totaling approximately 280 lines of verified code.

## 2. The Spectral Pairing Structure

### 2.1 Definition

**Definition 2.1** (SpectralPairing). A *spectral pairing* is a tuple (f, R) where:
- f : ℤ → ℕ → ℤ is the **evaluation map**
- R : ℕ → ℕ → ℤ is the **reciprocity operator**

satisfying the following axioms:

1. *Left multiplicativity*: f(a₁a₂, b) = f(a₁, b) · f(a₂, b) for all a₁, a₂ ∈ ℤ, b ∈ ℕ.
2. *Right multiplicativity*: f(a, b₁b₂) = f(a, b₁) · f(a, b₂) for all a ∈ ℤ, b₁, b₂ ∈ ℕ with b₁, b₂ ≠ 0.
3. *Trichotomy*: f(a, b) ∈ {−1, 0, 1} for all a, b.
4. *Reciprocity law*: f(a, b) = R(a, b) · f(b, a) for all odd a, b ∈ ℕ.
5. *Reciprocity symmetry*: R(a, b) = R(b, a) for all odd a, b.

### 2.2 Derived Properties

From the axioms, we can derive:
- f(1, b) = 1 for non-degenerate pairings (Theorem 4.2)
- The set {a : f(a, b) = 1} is a submonoid of ℤ (Theorem 4.1)
- R(a, b)² = 1 for odd a, b (Theorem 6.1)

### 2.3 Comparison with BilinearSymbol

The SpectralPairing extends the BilinearSymbol structure (previously defined in the Catalog) by incorporating the reciprocity operator as first-class structural data. While a BilinearSymbol captures bilinearity and trichotomy, a SpectralPairing additionally captures the *duality law* governing argument exchange.

## 3. The Canonical Instance: Jacobi Symbol

### 3.1 Construction

**Theorem 3.1** (jacobiSpectralPairing). The Jacobi symbol J(a, b) together with the quadratic reciprocity sign qrSign(a, b) = (−1)^(⌊a/2⌋·⌊b/2⌋) forms a SpectralPairing.

*Proof sketch*. Left multiplicativity is `jacobiSym.mul_left`. Right multiplicativity follows from `jacobiSym.mul_right` with NeZero instances. Trichotomy follows from the Jacobi symbol being a product of Legendre symbols, each in {−1, 0, 1}. The reciprocity law is `jacobiSym.quadratic_reciprocity'` composed with `qrSign.symm`. Reciprocity symmetry is `qrSign.symm`. □

### 3.2 Examples

Concrete evaluations of the canonical instance:
- J(−1, 3) = −1, J(−1, 5) = +1 (detecting p mod 4)
- J(2, 3) = −1, J(2, 7) = +1 (detecting p mod 8)
- J(3, 5) · J(5, 3) = qrSign(3, 5) = 1 (reciprocity verified)
- J(3, 7) · J(7, 3) = qrSign(3, 7) = −1 (reciprocity with correction)

## 4. Kernel Theory

### 4.1 Multiplicative Closure

**Theorem 4.1** (spectral_kernel_mul_closed). For any spectral pairing σ and natural number b, the first kernel K_b = {a ∈ ℤ : σ(a, b) = 1} is closed under multiplication.

*Proof*. If σ(a₁, b) = 1 and σ(a₂, b) = 1, then σ(a₁a₂, b) = σ(a₁, b) · σ(a₂, b) = 1 · 1 = 1 by left multiplicativity. □

### 4.2 Non-degenerate Kernel Contains 1

**Theorem 4.2** (spectral_kernel_one). If there exists a ∈ ℤ with σ(a, b) ≠ 0, then σ(1, b) = 1.

*Proof*. From σ(1, b) = σ(1 · 1, b) = σ(1, b)², we get σ(1, b)² = σ(1, b). In {−1, 0, 1}, the only solutions are 0 and 1. If σ(1, b) = 0, then σ(a, b) = σ(a · 1, b) = σ(a, b) · 0 = 0 for all a, contradicting non-degeneracy. □

### 4.3 PEGB Analysis

**Example**: K₅ for the Jacobi pairing consists of {a : J(a, 5) = 1} = {1, 4} mod 5 — the quadratic residues mod 5.

**Generalization**: The kernel K_p for prime p has index exactly 2 in (ℤ/pℤ)×, consisting of the quadratic residues. This generalizes to: for any spectral pairing with non-degenerate evaluation at a prime, the kernel has index at most 2.

**Boundary**: At b = 0, the kernel is all of ℤ (since J(a, 0) = 1 for all a by convention). The non-degeneracy hypothesis is essential: the zero pairing has kernel = ∅.

## 5. Square Triviality

**Theorem 5.1** (spectral_square_trivial). For the Jacobi symbol, J(d², p) = 1 for any prime p not dividing d.

*Proof*. J(d², p) = J(d, p)² by left multiplicativity. Since p is prime and p ∤ d, we have gcd(d, p) = 1, so J(d, p) ∈ {−1, 1}. In either case, J(d, p)² = 1. □

**PEGB**:
- *Example*: J(4, 3) = J(2², 3) = 1, even though J(2, 3) = −1.
- *Generalization*: For any spectral pairing, σ(d², b) = 1 whenever σ(d, b) ≠ 0.
- *Boundary*: When p | d, J(d², p) = 0, not 1. The coprimality condition is sharp.

## 6. Reciprocity Involution

**Theorem 6.1** (spectral_reciprocity_involutive). For odd a, b: qrSign(a, b)² = 1.

*Proof*. qrSign(a, b) = (−1)^(⌊a/2⌋·⌊b/2⌋), so qrSign(a, b)² = (−1)^(2·⌊a/2⌋·⌊b/2⌋) = 1. □

This establishes that the reciprocity operator is a ℤ/2ℤ-valued bilinear form. Combined with its multiplicativity in both arguments (`qrSign.mul_left`, `qrSign.mul_right`), it forms a *quadratic form on the group of odd integers modulo squares*.

**PEGB**:
- *Example*: qrSign(3, 7) = (−1)^(1·3) = −1, and (−1)² = 1. ✓
- *Generalization*: For any spectral pairing, if the reciprocity operator satisfies R(a,b) ∈ {−1, 1} for odd a, b, then R² = 1 automatically.
- *Boundary*: For even arguments, qrSign is not well-defined as a ±1-valued function (it can be 0).

## 7. Character Sum Vanishing

**Theorem 7.1** (quadratic_char_sum_vanishing). For any odd prime p:
$$\sum_{a \in \mathbb{Z}/p\mathbb{Z}} \chi_p(a) = 0$$
where χ_p is the quadratic character mod p.

*Proof*. This follows from `quadraticChar_sum_zero` in Mathlib, after verifying that the ring characteristic of ℤ/pℤ equals p ≠ 2. □

**PEGB**:
- *Example*: For p = 5, the values are χ(0) = 0, χ(1) = 1, χ(2) = −1, χ(3) = −1, χ(4) = 1. Sum = 0. ✓
- *Generalization*: Any non-trivial multiplicative character of a finite abelian group sums to 0 (character orthogonality).
- *Boundary*: The trivial character sums to p−1 (the number of units), not 0. The non-triviality of the quadratic character (p ≠ 2) is essential.

## 8. Frobenius Detectors

### 8.1 The Shape −1

**Theorem 8.1** (frobenius_neg_one_detector). For an odd prime p:
J(−1, p) = 1 ⟺ p ≡ 1 (mod 4)

*Proof*. By `jacobiSym.at_neg_one`, J(−1, p) = χ₄(p) for odd p. The character χ₄ maps p to 1 iff p ≡ 1 (mod 4). □

### 8.2 The Shape 2

**Theorem 8.2** (frobenius_two_detector). For an odd prime p:
J(2, p) = 1 ⟺ p ≡ ±1 (mod 8)

*Proof*. By `jacobiSym.at_two`, J(2, p) = χ₈(p) for odd p. The character χ₈ maps p to 1 iff p ≡ 1 or 7 (mod 8). □

These theorems show that the shape −1 classifies primes mod 4, and the shape 2 classifies primes mod 8. Together, they detect the residue class of p modulo 8, which determines the splitting behavior of all quadratic extensions of ℚ with discriminant dividing 8.

## 9. Matrix Transposition (Quadratic Reciprocity)

**Theorem 9.1** (splitting_matrix_transposition). For coprime odd p, q:
J(p, q) · J(q, p) = qrSign(p, q)

*Proof*. By quadratic reciprocity, J(p, q) = qrSign(q, p) · J(q, p). Multiplying both sides by J(q, p) and using coprimality to ensure J(q, p)² = 1 (via `jacobiSym.sq_one`), we get J(p, q) · J(q, p) = qrSign(q, p) = qrSign(p, q) (by symmetry). □

**PEGB**:
- *Example*: J(3, 7) · J(7, 3) = (−1) · 1 = −1 = qrSign(3, 7). ✓
- *Generalization*: Higher reciprocity laws (cubic, quartic) have analogous product formulas, but with correction signs valued in roots of unity rather than {±1}.
- *Boundary*: When gcd(p, q) > 1, the product J(p, q) · J(q, p) can be 0, violating the formula. Coprimality is essential.

## 10. The Spectrum Bundle: Finite Fragments

We define the **SpectrumBundle** — a finite fragment of the Langlands correspondence that packages a list of discriminants (shapes) and primes (color basis) together with their splitting matrix. This provides a computational handle on the correspondence:

```
SpectrumBundle := { shapes : List ℤ, primes : List ℕ, ... }
```

The splitting matrix M[i,j] = J(d_i, p_j) is the finite-dimensional shadow of the full Langlands dictionary.

## 11. Algorithms

### 11.1 Splitting Matrix Computation
Given n discriminants and m primes, the splitting matrix is computable in O(nm · log(max)) time using the standard Jacobi symbol algorithm.

### 11.2 Reciprocity Verification
For all pairs from a set of k primes, reciprocity can be verified in O(k² · log) time.

### 11.3 Frobenius Classification
A prime p can be fully classified by its Frobenius data for fundamental discriminants (−1, 2, −3, 5, ...) in O(k · log p) time, where k is the number of fundamental discriminants.

## 12. Conjectures and Future Work

**Conjecture 12.1** (Spectral Rigidity). A SpectralPairing that agrees with the Jacobi symbol on all primes p ≤ N and all discriminants |d| ≤ N is equal to the Jacobi symbol on all inputs. The minimal sufficient N is conjectured to be small (≤ 100).

**Conjecture 12.2** (Higher Spectral Pairings). There exist SpectralPairing-like structures axiomatizing cubic and quartic reciprocity, where the reciprocity operator takes values in 3rd and 4th roots of unity respectively, and the evaluation map takes values in {0, 1, ω, ω²} or {0, ±1, ±i}.

**Future Direction**: Extend the SpectralPairing framework to GL₂, where the "evaluation map" should be a trace function on 2-dimensional Galois representations, and the "reciprocity operator" should encode the Langlands functoriality.

## 13. Connection to Existing Catalog

This work builds on and extends:
- **BilinearSymbol** from `Catalog/Cryptography/GL1LanglandsBilinear.lean`: We extend the BilinearSymbol structure with a reciprocity operator.
- **berggren_quadratic_form_invariant** from `Cryptography/DiophantineCryptoCore.lean`: The quadratic form invariant of Berggren matrices is related to the bilinearity of the Jacobi symbol.
- **galois_expressivity_degree_bound** from `Bridges/GaloisNeuralCorrespondence.lean`: Connects Galois-theoretic data to expressivity bounds.

## References

[1] R. P. Langlands, "Letter to André Weil," 1967.

[2] C. F. Gauss, *Disquisitiones Arithmeticae*, 1801.

[3] J.-P. Serre, *A Course in Arithmetic*, Springer, 1973.

[4] A. Wiles, "Modular elliptic curves and Fermat's Last Theorem," *Annals of Mathematics* 141(3), 1995.

[5] K. Ireland and M. Rosen, *A Classical Introduction to Modern Number Theory*, Springer, 1990.
