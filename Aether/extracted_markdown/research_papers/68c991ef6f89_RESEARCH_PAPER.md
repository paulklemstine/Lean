# Formalizing the GL₁ Langlands Correspondence: Quadratic Characters as a Shape-Color Dictionary

## Abstract

We present a formalization in Lean 4 of the GL₁ Langlands correspondence for quadratic extensions, centering on the structural interpretation of the Jacobi symbol as a "shape-color dictionary" connecting quadratic field discriminants to Dirichlet characters. Our formalization introduces the novel structure `QuadraticShapeColorDict` encoding the correspondence for individual fundamental discriminants, defines `IsFundDiscriminant` capturing the classification of discriminants of quadratic number fields, and proves several key theorems: character sum vanishing (color orthogonality), the Gauss sum bridge (g(χ)² = χ(-1)·|F|), Euler's criterion as the computational engine of the correspondence, quadratic reciprocity as self-duality of the bilinear pairing, and the full bilinear expansion of the Jacobi symbol. We verify the injectivity of the shape-color map on concrete examples and state the GL₁ completeness conjecture.

**Keywords**: Langlands correspondence, quadratic characters, Jacobi symbol, Gauss sum, formal verification, class field theory

## 1. Introduction

The Langlands program, initiated by Robert Langlands in 1967 [1], proposes a profound correspondence between automorphic forms and Galois representations. In its simplest instance — the GL₁ case — this reduces to class field theory: the correspondence between abelian extensions of ℚ and Dirichlet characters.

The quadratic case is the most accessible entry point. Each quadratic extension ℚ(√d) for squarefree d ≠ 0,1 has an associated fundamental discriminant D, and the Jacobi symbol J(D, ·) defines a quadratic Dirichlet character χ_D. The GL₁ Langlands correspondence asserts that this map D ↦ χ_D is a bijection between fundamental discriminants and primitive quadratic Dirichlet characters.

### 1.1 Shape-Color Metaphor

We organize the formalization around a "shape-color" metaphor:
- **Shapes** are fundamental discriminants D, encoding quadratic number fields
- **Colors** are quadratic Dirichlet characters χ_D, encoding multiplicative functions
- **The dictionary** is the map D ↦ J(D, ·)
- **The bridge** is the Gauss sum, connecting additive (shape) and multiplicative (color) structures
- **Self-duality** is quadratic reciprocity: the dictionary reads the same in both directions

### 1.2 Contributions

1. **Novel definitions**: `IsFundDiscriminant` (Definition 2.1) and `QuadraticShapeColorDict` (Definition 6.1), not present in Mathlib or the existing Catalog
2. **Structural theorems**: Character sum vanishing, Gauss sum squared, Euler's criterion, bilinear expansion, and quadratic reciprocity, organized as components of the shape-color dictionary
3. **Concrete verification**: Four dictionary instances (D = -4, 5, 8, -3) with six computed character values and three injectivity witnesses
4. **Testable conjecture**: GL₁ shape-color injectivity with explicit computational prediction

## 2. Fundamental Discriminants

**Definition 2.1** (Fundamental Discriminant). An integer D is a *fundamental discriminant* if either:
- D ≡ 1 (mod 4) and D is squarefree, or
- D = 4m where m is squarefree, m ≢ 1 (mod 4), and m ≠ 0.

This definition captures exactly the discriminants of quadratic number fields ℚ(√d):
- If d ≡ 1 (mod 4), the discriminant is D = d
- If d ≡ 2 or 3 (mod 4), the discriminant is D = 4d

**Theorem 2.2** (Concrete Examples). The following are fundamental discriminants:
- D = -4 (for ℚ(i), the Gaussian integers)
- D = 8 (for ℚ(√2))
- D = 5 (for ℚ(√5), the golden ratio field)
- D = -3 (for ℚ(√(-3)), the Eisenstein integers)

*Proof sketch.* Each requires verifying squarefreeness of the relevant integer and the appropriate congruence condition. □

## 3. Color Orthogonality

**Theorem 3.1** (Character Sum Vanishing). Let F be a finite commutative monoid, R an integral domain, and χ: F → R a non-trivial multiplicative character. Then
$$\sum_{a \in F} \chi(a) = 0$$

*Proof.* This is `MulChar.sum_eq_zero_of_ne_one` in Mathlib. The key idea: if χ(b) ≠ 1 for some b, then multiplication by b permutes F, so the sum equals χ(b) · (sum), forcing (1 - χ(b)) · (sum) = 0. Since χ(b) ≠ 1 and R is a domain, the sum is 0. □

**Corollary 3.2** (Quadratic Color Orthogonality). For a finite field F of odd characteristic, the sum of the quadratic character over all elements of F is zero:
$$\sum_{a \in F} \chi_{\text{quad}}(a) = 0$$

This means the quadratic residues and non-residues are in perfect balance.

## 4. The Gauss Sum Bridge

**Theorem 4.1** (Gauss Sum Squared). Let χ be a non-trivial quadratic character of a finite field F, and ψ a primitive additive character. Then
$$g(\chi)^2 = \chi(-1) \cdot |F|$$

where g(χ) = Σ_a χ(a)ψ(a) is the Gauss sum.

*Proof.* This is `gaussSum_sq` in Mathlib. The proof uses the identity g(χ)·g(χ⁻¹) = |F| (valid for any non-trivial character) combined with χ⁻¹ = χ (since χ is quadratic) and the formula g(χ⁻¹) = χ(-1)·g(χ). □

**Interpretation.** The Gauss sum is the "bridge" between addition (encoded by ψ) and multiplication (encoded by χ). Its square lands back in the multiplicative world, with the sign χ(-1) measuring the "twist" between the two structures.

## 5. Euler's Criterion

**Theorem 5.1** (Euler's Criterion). For an odd prime p and a ∈ (ℤ/pℤ)× with a ≠ 0,
$$\chi_{\text{quad}}(a) = a^{(p-1)/2} \pmod{p}$$

*Proof.* Uses `quadraticChar_eq_pow_of_char_ne_two` from Mathlib, combined with the observation that (p-1)/2 = p/2 for odd p. □

**Significance.** This gives an explicit, computable formula for the "color" of any element, reducing character evaluation to exponentiation.

## 6. The Shape-Color Dictionary

**Definition 6.1** (QuadraticShapeColorDict). A quadratic shape-color dictionary consists of:
- A discriminant D ∈ ℤ
- A proof that D is a fundamental discriminant
- The character function colorFun(n) = J(D, n)

**Theorem 6.2** (Multiplicativity). For any dictionary D and nonzero b₁, b₂ ∈ ℕ,
$$\text{colorFun}(b_1 \cdot b_2) = \text{colorFun}(b_1) \cdot \text{colorFun}(b_2)$$

*Proof.* Direct from `jacobiSym.mul_right`. □

We construct four concrete dictionaries:
- `gaussianDict`: D = -4 (Gaussian integers)
- `sqrt2Dict`: D = 8 (field ℚ(√2))
- `goldenDict`: D = 5 (golden ratio field)
- `eisensteinDict`: D = -3 (Eisenstein integers)

## 7. Self-Duality

**Theorem 7.1** (Shape-Color Duality = Quadratic Reciprocity). For distinct odd primes p, q,
$$\left(\frac{p}{q}\right) \cdot \left(\frac{q}{p}\right) = (-1)^{\lfloor p/2 \rfloor \cdot \lfloor q/2 \rfloor}$$

*Proof.* This is `legendreSym.quadratic_reciprocity` in Mathlib. □

**Interpretation.** The dictionary is self-dual: the color of p in shape q times the color of q in shape p equals a simple sign. This sign is +1 unless both primes are ≡ 3 mod 4.

## 8. Injectivity

**Theorem 8.1** (Concrete Injectivity). Any two of the four dictionaries (gaussianDict, sqrt2Dict, goldenDict, eisensteinDict) produce distinct character functions. Specifically:
- gaussianDict and sqrt2Dict differ at p = 5: J(-4, 5) = 1 ≠ -1 = J(8, 5)
- goldenDict and eisensteinDict differ at p = 7: J(5, 7) = -1 ≠ 1 = J(-3, 7)
- gaussianDict and goldenDict differ at p = 11: J(-4, 11) = -1 ≠ 1 = J(5, 11)

*Proof.* Each is verified by direct computation of the Jacobi symbol. □

## 9. Bilinear Structure

**Theorem 9.1** (Full Bilinear Expansion). For a₁, a₂ ∈ ℤ and nonzero b₁, b₂ ∈ ℕ,
$$J(a_1 a_2, b_1 b_2) = J(a_1, b_1) \cdot J(a_1, b_2) \cdot J(a_2, b_1) \cdot J(a_2, b_2)$$

*Proof.* Apply `jacobiSym.mul_left` to separate a₁ and a₂, then apply `jacobiSym.mul_right` to each factor. □

## 10. Character Classification

**Theorem 10.1** (Trichotomy). For any element a of a finite field F,
$$\chi_{\text{quad}}(a) \in \{-1, 0, 1\}$$

**Theorem 10.2** (Unit Dichotomy). If a ≠ 0, then χ_quad(a) ∈ {-1, 1}.

## 11. Conjecture

**Conjecture 11.1** (GL₁ Shape-Color Injectivity). If D₁ and D₂ are fundamental discriminants such that J(D₁, p) = J(D₂, p) for every prime p, then D₁ = D₂.

**Testable prediction.** For all pairs of fundamental discriminants D₁ ≠ D₂ with |D₁|, |D₂| ≤ 1000, there exists a prime p ≤ |D₁| · |D₂| such that J(D₁, p) ≠ J(D₂, p).

This conjecture follows from the Chebotarev density theorem and the theory of L-functions, but a direct elementary proof remains interesting.

## 12. Specific Character Values

We compute six character values verifying the dictionary:

| Discriminant D | Prime p | J(D, p) | Interpretation |
|---|---|---|---|
| -4 | 3 | -1 | 3 is inert in ℚ(i) |
| -4 | 5 | +1 | 5 splits in ℚ(i) |
| 8 | 3 | -1 | 3 is inert in ℚ(√2) |
| 8 | 7 | +1 | 7 splits in ℚ(√2) |
| 5 | 3 | -1 | 3 is inert in ℚ(√5) |
| -3 | 5 | -1 | 5 is inert in ℚ(√(-3)) |

## 13. Discussion

### 13.1 Relation to the Full Langlands Program

Our formalization covers the simplest case: GL₁ with quadratic characters. The full Langlands program extends this to:
- **GL₁ with all characters**: class field theory (Artin reciprocity)
- **GL₂**: Wiles's modularity theorem (Taniyama-Shimura conjecture)
- **GL_n**: the general Langlands correspondence

Each step up in dimension introduces fundamentally new phenomena: L-functions replace characters, automorphic forms replace multiplicative functions, and the bilinear structure becomes a more complex spectral correspondence.

### 13.2 The Bilinear Paradigm

A key insight of this work is that the Jacobi symbol's bilinear structure (Theorem 9.1) is the algebraic foundation of the correspondence. The bilinear expansion shows that the Jacobi symbol is determined by its values on prime inputs — this is why the correspondence is an injection on fundamental discriminants.

### 13.3 The Gauss Sum as Fourier Transform

The Gauss sum g(χ) = Σ χ(a)ψ(a) is essentially the Fourier transform of the character χ. Theorem 4.1 (g(χ)² = χ(-1)·p) is the analogue of Plancherel's theorem. This Fourier-analytic viewpoint extends to the higher-rank Langlands correspondence, where the bridge becomes the *trace formula*.

## 14. Future Work

1. Formalize the surjectivity of the shape-color map (every primitive quadratic character arises from a fundamental discriminant)
2. Extend to cubic and higher-degree characters (GL₁ with non-quadratic characters)
3. Connect to the formalization of modular forms for the GL₂ case
4. Prove the GL₁ completeness conjecture directly (without Chebotarev)

## References

[1] R.P. Langlands, "Problems in the Theory of Automorphic Forms," *Lectures in Modern Analysis and Applications III*, Lecture Notes in Math. 170, Springer, 1970, pp. 18–61.

[2] J.-P. Serre, *A Course in Arithmetic*, Graduate Texts in Mathematics 7, Springer, 1973.

[3] H. Iwaniec and E. Kowalski, *Analytic Number Theory*, AMS Colloquium Publications 53, 2004.

[4] D. Bump, *Automorphic Forms and Representations*, Cambridge Studies in Advanced Mathematics 55, 1997.
