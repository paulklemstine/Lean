# Categorical Theory of Compression Closures as Idempotent Monads

## Abstract

We develop a categorical foundation for compression-closure duality by establishing a structural equivalence between idempotent monads, reflective subcategories of incompressible objects, and Kleisli categories of compression-aware morphisms. Our main results are: (A) the full subcategory of fixed objects of an idempotent monad is reflective; (B) the Kleisli category of an idempotent monad is equivalent to this fixed subcategory; (C) monad morphisms induce MDL (Minimum Description Length) inequalities; and (D) tropical normalization on ℝⁿ is the unique translation-invariant compression operator preserving tropical projective classes. All results are formalized with machine-verified proofs.

## 1. Introduction

### 1.1 Motivation

The Minimum Description Length (MDL) principle, originating in the work of Rissanen, identifies the best model for data as the one achieving maximal compression. Closure operators in order theory provide canonical representatives by mapping each element to a fixed point. Tropical normalization in min-plus algebra selects canonical class representatives by subtracting coordinate minima.

Despite their diverse origins, these operations share common mathematical structure: all are idempotent (applying twice equals applying once), all produce "canonical" or "incompressible" outputs, and all satisfy universal approximation properties. This paper identifies their common categorical essence.

### 1.2 Contributions

1. **Reflective Fixed Subcategory (Theorem A)**: For any idempotent monad T on a category C, the full subcategory of T-fixed objects (those where the unit η_X is an isomorphism) is reflective in C. The reflector is given by the monad's functor.

2. **Kleisli Equivalence (Theorem B)**: The Kleisli category of an idempotent monad is equivalent to the full subcategory of fixed objects. This establishes that compression-aware computations are exactly morphisms between canonical objects.

3. **MDL Monotonicity (Theorem C)**: If one compression monad dominates another objectwise, the corresponding MDL values are ordered.

4. **Tropical Initiality (Theorem D)**: Tropical normalization N(x)_i = x_i - min_j(x_j) is the unique operator on ℝⁿ satisfying idempotence, translation invariance, nonnegativity, zero minimum, and tropical class preservation.

5. **Closure Bridge**: The categorical MDL framework recovers classical closure-based MDL bounds as a special case.

## 2. Definitions and Notation

### 2.1 Idempotent Monads

A monad T = (T, η, μ) on a category C is **idempotent** if μ_X : T(T(X)) → T(X) is an isomorphism for every object X.

An object X is **T-fixed** if η_X : X → T(X) is an isomorphism. We write FixedBy(T) for the full subcategory of T-fixed objects.

### 2.2 Tropical Normalization

For n > 0, define:
- TropVec(n) = Fin(n) → ℝ
- tropMin(x) = inf{x_i : i ∈ Fin(n)}
- tropNormalize(x)_i = x_i - tropMin(x)

### 2.3 Translation-Invariant Compression

A **TranslationInvariantCompression** on ℝⁿ is an operator T : TropVec(n) → TropVec(n) satisfying:
1. Idempotence: T(T(x)) = T(x)
2. Translation invariance: T(x + c·1) = T(x) for all c ∈ ℝ
3. Nonnegativity: T(x)_i ≥ 0 for all i
4. Zero minimum: ∃i, T(x)_i = 0
5. Same class: ∃c, ∀i, T(x)_i = x_i + c

## 3. Main Results

### 3.1 Theorem A: Reflective Fixed Subcategory

**Theorem.** Let C be a category and T an idempotent monad on C. Then the inclusion ι : FixedBy(T) → C has a left adjoint L, making FixedBy(T) a reflective subcategory.

**Proof sketch.** The reflector L sends X to T(X), which is T-fixed because η_{TX} is an isomorphism (proved from the left unit law η_{TX} ∘ μ_X = id and the assumption that μ_X is iso). The adjunction L ⊣ ι is established via the hom-set equivalence:

Hom(T(X), Y) ≃ Hom(X, Y) for Y ∈ FixedBy(T)

where the forward map is precomposition with η_X and the inverse is T(-) ∘ inv(η_Y). The naturality conditions and triangle identities are verified using the monad laws.

**Key lemma.** For an idempotent monad: if μ_X is iso for all X, then both η_{TX} and T(η_X) are isomorphisms. This follows because both are sections of the iso μ_X (by the left and right unit laws respectively).

### 3.2 Theorem B: Kleisli Equivalence

**Theorem.** The functor K : Kleisli(T) → FixedBy(T) defined by K(X) = T(X) on objects and K(f) = T(f) ∘ μ_Y on morphisms f : X → T(Y) is an equivalence of categories.

**Proof sketch.** We verify that K is:
- **Faithful**: If T(f) ∘ μ_Y = T(g) ∘ μ_Y, cancel the iso μ_Y, then use naturality of η and the fact that η_{TY} is iso to deduce f = g.
- **Full**: Given h : T(X) → T(Y) in FixedBy(T), the preimage is f = η_X ∘ h. Verification uses T(η_X) = inv(μ_X) = η_{TX} and the left unit law.
- **Essentially surjective**: For any fixed object Y, take X = Y.obj. Then K(X) = T(Y.obj) ≅ Y via inv(η_Y).

### 3.3 Theorem C: MDL Monotonicity

**Theorem.** Given compression monads T₁, T₂ on C with a length functional, if length(T₂(X)) ≤ length(T₁(X)) for all X, then MDL(T₂, X) ≤ MDL(T₁, X) for all X.

This follows directly from the definition MDL(T, X) = length(T(X)).

**Corollary.** For T-fixed objects X, MDL(T, X) = length(X) when length is invariant under isomorphisms.

### 3.4 Theorem D: Tropical Initiality

**Theorem.** For n > 0, tropical normalization is the unique TranslationInvariantCompression on ℝⁿ.

**Proof.** Let T be any such operator and x ∈ ℝⁿ. By the same-class axiom, T(x)_i = x_i + c for some constant c. By the zero-minimum axiom, there exists j with x_j + c = 0, so c = -x_j. By nonnegativity, x_i + c ≥ 0 for all i, meaning x_i ≥ x_j for all i, so x_j = min(x) = tropMin(x). Therefore c = -tropMin(x) and T(x)_i = x_i - tropMin(x) = tropNormalize(x)_i. □

### 3.5 Closure Bridge

**Theorem.** For any closure operator c on a preorder α and monotone length functional L:
∀x, ∃y, c(y) = y ∧ x ≤ y ∧ L(y) ≤ L(c(x))

**Proof.** Take y = c(x). Then c(y) = c(c(x)) = c(x) = y by idempotence, x ≤ c(x) = y by extensiveness, and L(y) = L(c(x)) ≤ L(c(x)) trivially. □

## 4. Algorithms

### 4.1 Tropical Normalization

```
Algorithm: TropicalNormalize(x ∈ ℝⁿ)
Input: Vector x = (x₁, ..., xₙ)
Output: Normalized vector N(x)

1. m ← min(x₁, ..., xₙ)          // O(n)
2. For i = 1 to n:                  // O(n)
     N(x)ᵢ ← xᵢ - m
3. Return N(x)

Time: O(n), Space: O(n)
```

### 4.2 Compression Monad Verification

```
Algorithm: VerifyCompression(T, n, k)
Input: Operator T, dimension n, test count k
Output: Boolean (all axioms satisfied)

1. For j = 1 to k:
     x ← random vector in ℝⁿ
     Check T(T(x)) = T(x)           // Idempotence
     Check T(x + c·1) = T(x)        // Translation invariance
     Check all T(x)ᵢ ≥ 0            // Nonnegativity
     Check min T(x) = 0             // Zero minimum
     Check T(x) - x is constant     // Same class
2. Return conjunction of all checks

Time: O(kn · T_eval), Space: O(n)
```

## 5. Applications

### 5.1 Data Normalization in Machine Learning

Tropical normalization provides a mathematically principled alternative to standard normalization techniques (z-score, min-max). Its idempotence guarantees stability under reapplication, and its translation invariance ensures robustness to global shifts — both desirable properties for feature preprocessing.

### 5.2 Compiler Optimization

The Kleisli equivalence (Theorem B) provides categorical semantics for compiler normalization passes. Programs modulo normalization form a category equivalent to programs between normal forms. This justifies multi-pass optimization: the Kleisli composition ensures soundness.

### 5.3 Tropical Geometry

Theorem D identifies tropical normalization as the canonical map to tropical projective space TP^{n-1}. This has implications for tropical intersection theory and the study of tropical varieties, where choosing canonical representatives is a fundamental operation.

## 6. Computational Experiments

We implemented all algorithms in Python and verified:

| Property | Tropical Normalize | Tested on |
|----------|-------------------|-----------|
| Idempotence | ✓ (100/100) | Random ℝ⁵ vectors |
| Translation invariance | ✓ (100/100) | Random shifts |
| Nonnegativity | ✓ (100/100) | - |
| Zero minimum | ✓ (100/100) | - |
| Same class | ✓ (100/100) | - |
| = tropNormalize | ✓ (100/100) | - |

MDL compression gains scale linearly with dimension, as expected from the theory (the constant offset min(x) is subtracted from each of n coordinates).

## 7. Discussion

### 7.1 Relationship to Prior Work

The equivalence between idempotent monads and reflective subcategories is classical in category theory (see Borceux, *Handbook of Categorical Algebra*). Our contribution is threefold: (a) providing complete machine-verified proofs of the key theorems, (b) connecting this theory to compression and MDL, and (c) proving the tropical initiality theorem as a universal property.

### 7.2 Limitations

The current framework treats compression as an exact, deterministic operation. Extensions to lossy compression (where T(x) ≈ x rather than T(x) ~ x) and probabilistic compression (where T acts on distributions) are natural next steps but require additional mathematical machinery.

### 7.3 Open Questions

1. Can the framework be extended to *lax* idempotent monads, capturing approximate compression?
2. Is there a meaningful *comonadic* theory of decompression dual to our monadic compression?
3. Can the tropical initiality theorem be generalized to other semiring normalizations?

## 8. Future Work

See FUTURE_DIRECTIONS.md for detailed research roadmap.

## 9. References

1. Rissanen, J. "Modeling by shortest data description." *Automatica* 14.5 (1978): 465-471.
2. Borceux, F. *Handbook of Categorical Algebra*. Cambridge University Press, 1994.
3. Mac Lane, S. *Categories for the Working Mathematician*. Springer, 1971.
4. Maclagan, D. and Sturmfels, B. *Introduction to Tropical Geometry*. AMS, 2015.
5. Moggi, E. "Notions of computation and monads." *Information and Computation* 93.1 (1991): 55-92.
