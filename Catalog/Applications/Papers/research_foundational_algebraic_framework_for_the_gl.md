# Bilinear Structure of the GL₁ Langlands Correspondence

## Abstract

We formalize the algebraic framework underlying the GL₁ Langlands correspondence by introducing the notion of a *bilinear symbol* — a pairing σ : ℤ → ℕ → ℤ that is simultaneously multiplicative in both arguments and takes values in {−1, 0, 1}. We prove that the Jacobi symbol is a bilinear symbol and reformulate quadratic reciprocity as a self-duality theorem for this pairing. We introduce the *ShapeColorPairing* structure that formalizes the dictionary between quadratic field discriminants ("shapes") and Dirichlet characters ("colors"). We establish that the kernel of a bilinear symbol in its first argument is multiplicatively closed — the algebraic origin of the quadratic residue subgroup — and prove that the characters χ₄ and χ₈ are the canonical "shape detectors" at −1 and 2 respectively. All results are machine-verified in Lean 4 with Mathlib.

**Keywords**: Jacobi symbol, quadratic reciprocity, bilinear forms, Langlands correspondence, Dirichlet characters, formal verification

---

## 1. Introduction

The Langlands program posits deep connections between automorphic forms and Galois representations. At the GL₁ level, this reduces to the correspondence between quadratic Dirichlet characters and quadratic extensions of ℚ, mediated by the Jacobi symbol. While the individual components — multiplicativity, reciprocity, character detection — are classical, their unification through a single algebraic structure has not been previously formalized.

Our contribution is threefold:

1. **Definition of BilinearSymbol**: We axiomatize the structure common to the Jacobi symbol and its generalizations, identifying the minimal axioms needed for the GL₁ correspondence.

2. **Reciprocity as Self-Duality**: We reformulate quadratic reciprocity not as a computational identity but as a structural theorem: the Jacobi pairing is self-dual with a computable correction sign ε(a,b) = (−1)^{(a/2)(b/2)}.

3. **Kernel Theory**: We prove that the kernel of any bilinear symbol is multiplicatively closed, providing the abstract foundation for the theory of quadratic residues.

## 2. Definitions

### 2.1 Bilinear Symbol

**Definition 2.1** (BilinearSymbol). A *bilinear symbol* is a function σ : ℤ → ℕ → ℤ satisfying:
- (Left multiplicativity) σ(a₁a₂, b) = σ(a₁, b) · σ(a₂, b) for all a₁, a₂ ∈ ℤ, b ∈ ℕ
- (Right multiplicativity) σ(a, b₁b₂) = σ(a, b₁) · σ(a, b₂) for all a ∈ ℤ, b₁, b₂ ∈ ℕ with b₁, b₂ ≠ 0
- (Value constraint) σ(a, b) ∈ {−1, 0, 1} for all a ∈ ℤ, b ∈ ℕ

### 2.2 Reciprocity Data

**Definition 2.2** (ReciprocityData). A *reciprocity data* for a bilinear symbol σ consists of a correction sign ε : ℕ → ℕ → ℤ such that:
- ε(a, b) ∈ {−1, 1} for all a, b
- ε(a, b) = ε(b, a) (symmetry)
- σ(a, b) = ε(a, b) · σ(b, a) for odd a, b (the reciprocity law)

### 2.3 Shape-Color Pairing

**Definition 2.3** (ShapeColorPairing). A *shape-color pairing* consists of:
- A bilinear symbol σ
- A discriminant d ∈ ℤ (the "shape")
- A character evaluator: n ↦ σ(n, |d|) (the "color" function)
- A splitting detector: (d, p) ↦ σ(d, p) (detecting splitting behavior)

## 3. Main Results

### 3.1 The Jacobi Symbol is Bilinear

**Theorem 3.1** (jacobiSym_bilinear). The Jacobi symbol J : ℤ → ℕ → ℤ satisfies all BilinearSymbol axioms.

*Proof sketch*. Left multiplicativity follows from the definition of J as a product of Legendre symbols. Right multiplicativity uses the factorization J(a, b₁b₂) = J(a, b₁)J(a, b₂) for nonzero b₁, b₂. The value constraint follows from each Legendre symbol being in {−1, 0, 1} and the product of such values remaining in {−1, 0, 1}. □

### 3.2 Quadratic Reciprocity as Self-Duality

**Theorem 3.2** (reciprocity_as_duality). For odd natural numbers a, b:
$$J(a, b) = (-1)^{\lfloor a/2 \rfloor \cdot \lfloor b/2 \rfloor} \cdot J(b, a)$$

The correction sign ε(a,b) = (−1)^{(a/2)(b/2)} forms valid ReciprocityData: it is ±1-valued and symmetric.

*Proof sketch*. This is a direct reformulation of the classical quadratic reciprocity theorem (Gauss, 1796). The symmetry of the correction sign follows from the commutativity of multiplication: (a/2)(b/2) = (b/2)(a/2). □

### 3.3 The Fundamental Bilinearity Equation

**Theorem 3.3** (jacobi_full_bilinearity). For b₁, b₂ ≠ 0:
$$J(a_1 a_2, b_1 b_2) = J(a_1, b_1) \cdot J(a_1, b_2) \cdot J(a_2, b_1) \cdot J(a_2, b_2)$$

*Proof sketch*. Apply left multiplicativity to split a₁a₂, then right multiplicativity to each factor. The result follows by associativity of multiplication. □

### 3.4 Kernel Closure

**Theorem 3.4** (bilinear_symbol_kernel_mul_closed). For any bilinear symbol σ and any b ∈ ℕ, the set {a ∈ ℤ | σ(a, b) = 1} is closed under multiplication.

*Proof sketch*. If σ(a₁, b) = 1 and σ(a₂, b) = 1, then σ(a₁a₂, b) = σ(a₁, b) · σ(a₂, b) = 1 · 1 = 1 by left multiplicativity. □

**Theorem 3.5** (bilinear_symbol_kernel_one). For a non-degenerate bilinear symbol σ (one where σ(a, b) ≠ 0 for some a), 1 ∈ ker(σ, b).

*Proof sketch*. By left multiplicativity, σ(1, b) = σ(1·1, b) = σ(1, b)². Since σ(1, b) ∈ {−1, 0, 1}, the equation x² = x forces x = 0 or x = 1. Non-degeneracy eliminates x = 0: if σ(1, b) = 0, then σ(a, b) = σ(1·a, b) = 0 for all a, contradicting the existence of a nonzero value. □

### 3.5 Character Detection

**Theorem 3.6** (jacobi_neg_one_eq_chi4). For odd b: J(−1, b) = χ₄(b).

**Theorem 3.7** (jacobi_two_eq_chi8). For odd b: J(2, b) = χ₈(b).

These identities connect the Jacobi symbol at the "generators" −1 and 2 to the primitive Dirichlet characters modulo 4 and 8.

### 3.6 The Shape Detector

**Theorem 3.8** (neg_one_shape_detector). For an odd prime p:
$$J(-1, p) = 1 \iff p \equiv 1 \pmod{4}$$

This is the simplest instance of the shape-color correspondence: the "shape" of −1 (i.e., whether −1 is a quadratic residue) classifies primes by their residue class mod 4.

### 3.7 Periodicity

**Theorem 3.9** (jacobi_periodic). For b ≠ 0: J(a, b) = J(a mod b, b).

This establishes that a ↦ J(a, b) descends to a well-defined function on ℤ/bℤ.

## 4. The Shape-Color Dictionary

The results above assemble into the GL₁ Langlands dictionary:

| Shape (Galois side) | Color (Automorphic side) | Mediator |
|---|---|---|
| ℚ(√d), discriminant D | χ_D : (ℤ/Dℤ)× → {±1} | J(D, ·) |
| Splitting of p in ℚ(√d) | χ_D(p) | J(D, p) |
| Self-duality of ℚ(√d)/ℚ | Quadratic reciprocity | ε(a,b) = (−1)^{(a/2)(b/2)} |
| Ramification at p | p | D | J(D, p) = 0 |

The bilinear symbol axioms capture exactly the properties needed for this dictionary to be functorial: left multiplicativity ensures the character is multiplicative, right multiplicativity ensures it respects prime factorization, and the value constraint ensures the correspondence is with *quadratic* characters.

## 5. Algorithms

### 5.1 Bilinear Symbol Evaluation

Given the bilinearity, J(a, b) for arbitrary a, b can be computed by:
1. Reduce a modulo b (periodicity)
2. Factor b = p₁^{e₁} ··· pₖ^{eₖ} (right multiplicativity)
3. Evaluate J(a, pᵢ) for each prime factor (Legendre symbol computation)
4. Multiply results

### 5.2 Shape-Color Pairing Construction

Given a square-free integer d:
1. Compute the discriminant D = d (if d ≡ 1 mod 4) or D = 4d (otherwise)
2. The character χ_D is given by p ↦ J(D, p)
3. The splitting behavior in ℚ(√d) is detected by this character

## 6. Conjecture

**Conjecture** (Bilinear Symbol Classification). Every bilinear symbol σ : ℤ → ℕ → ℤ that satisfies periodicity (σ(a, b) = σ(a mod b, b)) and a reciprocity law (σ(a, b) = ε(a,b) · σ(b, a) for odd a, b with some correction ε) is a product of the "generating" characters χ₄, χ₈, and the Legendre symbols (·/p) for odd primes p.

**Test**: Verify computationally that any such symbol agreeing with J on primes ≤ 100 must agree with J everywhere on those primes — this follows trivially from multiplicativity but tests the completeness of the generating set.

## 7. Discussion

The bilinear symbol framework reveals that the GL₁ Langlands correspondence is, at its core, a statement about bilinear pairings. The Jacobi symbol is not merely a computational device but a *canonical bilinear form* on ℤ × ℕ, and quadratic reciprocity is its self-duality theorem.

This perspective suggests natural generalizations:
- **Higher-order symbols**: Replace {−1, 0, 1} with n-th roots of unity for the GL₁ correspondence over cyclotomic fields
- **Matrix-valued symbols**: Replace ℤ-valued pairings with matrix-valued ones for GL₂ and beyond
- **Motivic interpretation**: The bilinear structure should have a natural interpretation in terms of motivic cohomology

## 8. Future Work

The most promising extensions are:
1. Formalizing the connection between bilinear symbols and the Berggren quadratic form invariant (existing in the Catalog)
2. Extending to cubic and quartic reciprocity via higher-order bilinear symbols
3. Connecting the kernel theory to explicit class field theory computations

## References

1. C.F. Gauss, *Disquisitiones Arithmeticae*, 1801.
2. C.G.J. Jacobi, "Über die Kreistheilung und ihre Anwendung auf die Zahlentheorie," *J. Reine Angew. Math.* 30, 1846.
3. R.P. Langlands, "Problems in the theory of automorphic forms," *Lectures in Modern Analysis and Applications III*, Springer, 1970.
4. J.-P. Serre, *A Course in Arithmetic*, Springer GTM 7, 1973.
5. K. Ireland and M. Rosen, *A Classical Introduction to Modern Number Theory*, Springer GTM 84, 1990.
