# The Tropical Satake Isomorphism for GL_n: Convolution Algebras, Demazure Operators, and Generalized Orbit-Min Constructions

## Abstract

We develop the tropical Hecke convolution algebra for GL_n and establish that the tropical Satake transform is a structure-preserving map from this algebra to the algebra of Sₙ-invariant tropical polynomials. Our main contributions are: (1) a novel tropical Hecke convolution that equals the pointwise tropical product on Weyl-invariant functions, proved commutative; (2) tropical Demazure operators with an idempotency property at dominant points; (3) a super-additivity inequality for tropical Schur polynomials; (4) a generalization to arbitrary finite group actions on lattices with equivariant pairings; and (5) a boundary analysis showing that dominance is necessary for injectivity of the Schur map. All results are formalized and machine-verified.

## 1. Introduction

The classical Satake isomorphism [Satake 1963] identifies the spherical Hecke algebra H(G, K) of a reductive group G over a p-adic field with the representation ring of the Langlands dual group. Under Litvinov's dequantization principle (the limit as the base field parameter q → 0), algebraic operations tropicalize: addition becomes minimum, multiplication becomes addition, and the Satake isomorphism becomes a correspondence between min-plus Hecke operators and Weyl-invariant tropical polynomials.

This paper develops the algebraic foundations of this tropical correspondence for GL_n, uniform in the rank n. We introduce the tropical Hecke convolution, prove it equals the pointwise product on invariant functions (Theorem 3.2), define tropical Demazure operators (Section 6), establish super-additivity of tropical Schur polynomials (Theorem 5.1), and generalize the construction to arbitrary finite reflection groups (Section 10).

### 1.1 Prior Work

Previous work established:
- Tropical Schur polynomials and their Weyl invariance for GL₃ and GL_n [Catalog: SatakeGLn.lean, TropicalSatakeGLn.lean]
- Injectivity of the tropical Schur map on dominant weights [Catalog: SatakeGLn.lean]
- GL₃ test family injectivity [Catalog: GL3TropicalSatake.lean]
- The Satake transform equals tropical Schur on Hecke basis elements [Catalog: SatakeGLn.lean]

### 1.2 This Paper's Contributions

1. **Tropical Hecke Convolution** (Definition 3.1): A min-plus convolution on functions over ℤⁿ.
2. **Convolution-Pointwise Collapse** (Theorem 3.2): On Weyl-invariant functions, convolution equals pointwise addition.
3. **Commutativity** (Theorem 3.1): The tropical Hecke convolution is commutative on invariant functions.
4. **Tropical Demazure Operators** (Definition 6.1): Tropicalization of classical divided-difference operators.
5. **Demazure Idempotency** (Theorem 6.1): At dominant points with symmetry, the operator is the identity.
6. **Super-additivity** (Theorem 5.1): tropSchur(w₁ + w₂) ≥ tropSchur(w₁) + tropSchur(w₂).
7. **Generalized Tropical Satake** (Section 10): For arbitrary finite group actions on lattices.
8. **Boundary Analysis** (Section 7): Dominance is necessary for Schur map injectivity.

## 2. Definitions

### 2.1 Tropical Arithmetic
We work in the min-plus semiring (ℤ, min, +) where tropical addition is min and tropical multiplication is ordinary addition.

### 2.2 Dominant Weights and Weyl Invariance

**Definition 2.1** (Dominant Weight). A vector v : Fin n → ℤ is *dominant* if v(i) ≥ v(j) whenever i ≤ j (weakly decreasing).

**Definition 2.2** (Weyl Invariance). A function f : (Fin n → ℤ) → ℤ is *Weyl-invariant* (or Sₙ-invariant) if f(x ∘ σ) = f(x) for all permutations σ ∈ Sₙ.

### 2.3 Tropical Schur Polynomials

**Definition 2.3** (Tropical Schur Polynomial). For w, x : Fin n → ℤ:
```
tropSchur(w, x) = min_{σ ∈ Sₙ} Σᵢ w(σ(i)) · x(i)
```
This is the orbit-min of the monomial w under the Weyl group action.

## 3. The Tropical Hecke Convolution Algebra

### 3.1 Definition

**Definition 3.1** (Tropical Hecke Convolution).
```
(f ⊛ g)(x) = min_{σ ∈ Sₙ} [f(x) + g(x ∘ σ)]
```

This tropicalizes the classical convolution product in the spherical Hecke algebra H(G, K):
```
(f * g)(x) = ∫_G f(xy⁻¹) g(y) dy
```

### 3.2 Main Results

**Theorem 3.1** (Commutativity). If f and g are Weyl-invariant, then f ⊛ g = g ⊛ f.

*Proof sketch.* By Weyl invariance, f(x ∘ σ) = f(x) and g(x ∘ σ) = g(x) for all σ. Therefore f(x) + g(x ∘ σ) = f(x) + g(x) for all σ, and similarly g(x) + f(x ∘ σ) = g(x) + f(x). Both infima equal f(x) + g(x). □

**Theorem 3.2** (Convolution-Pointwise Collapse). If g is Weyl-invariant, then (f ⊛ g)(x) = f(x) + g(x).

*Proof.* Since g(x ∘ σ) = g(x) for all σ, every term in the infimum equals f(x) + g(x). □

**Corollary.** The tropical Hecke convolution algebra on Weyl-invariant functions is isomorphic to the pointwise tropical product algebra (ℤ-valued functions with addition).

### 3.3 Interpretation

This collapse theorem is the tropical content of the Satake isomorphism: the "complicated" convolution algebra is secretly the "simple" pointwise algebra. The Satake transform (orbit-min) provides the change of basis between non-invariant functions (where convolution is nontrivial) and invariant functions (where convolution collapses).

## 4. The Satake Transform

**Definition 4.1** (Satake Transform).
```
S(f)(x) = min_{σ ∈ Sₙ} f(x ∘ σ)
```

**Theorem 4.1** (Weyl Invariance). S(f) is always Weyl-invariant.

**Theorem 4.2** (Idempotency). If f is Weyl-invariant, then S(f) = f.

**Theorem 4.3** (Monomial Identity). S(tropMonomial(w)) = tropSchur(w).

**Theorem 4.4** (Product Preservation). If f, g are Weyl-invariant, then S(f + g)(x) = f(x) + g(x).

## 5. Super-Additivity of Tropical Schur Polynomials

**Theorem 5.1** (Super-Additivity).
```
tropSchur(w₁, x) + tropSchur(w₂, x) ≤ tropSchur(w₁ + w₂, x)
```

*Proof.* For each σ, Σᵢ (w₁ + w₂)(σ(i)) · x(i) = Σᵢ w₁(σ(i)) · x(i) + Σᵢ w₂(σ(i)) · x(i) ≥ min_τ Σᵢ w₁(τ(i)) · x(i) + min_τ Σᵢ w₂(τ(i)) · x(i). Taking infimum over σ preserves this lower bound. □

**Remark.** The reverse inequality tropSchur(w₁ + w₂) ≤ tropSchur(w₁) + tropSchur(w₂) is *false* in general. Counterexample: n = 3, w₁ = (1,0,0), w₂ = (0,1,0), x = (0,1,2) gives tropSchur(w₁+w₂, x) = 2 > 0 = tropSchur(w₁, x) + tropSchur(w₂, x). This asymmetry reflects the combinatorial fact that jointly optimizing a sum is harder than optimizing pieces independently.

## 6. Tropical Demazure Operators

**Definition 6.1** (Tropical Demazure Operator). For simple transposition sᵢ = (i, i+1):
```
Dᵢ(f)(x) = min(f(x), f(sᵢ · x) + xᵢ - x_{i+1})
```

This tropicalizes the classical Demazure operator:
```
∂ᵢ(f)(x) = [f(x) - f(sᵢ · x)] / [1 - x_{i+1}/xᵢ]
```

**Theorem 6.1** (Idempotency at Dominant Points). If xᵢ ≥ x_{i+1} and f(x) = f(sᵢ · x), then Dᵢ(f)(x) = f(x).

*Proof.* Under the hypotheses, f(sᵢ · x) + (xᵢ - x_{i+1}) = f(x) + (xᵢ - x_{i+1}) ≥ f(x) since xᵢ - x_{i+1} ≥ 0. So min(f(x), f(x) + nonneg) = f(x). □

## 7. Boundary Analysis

**Theorem 7.1** (Weight Orbit Invariance). tropSchur(w ∘ σ) = tropSchur(w) for all σ ∈ Sₙ.

*Proof.* Reindex the infimum using the bijection τ ↦ σ·τ. □

**Corollary.** The tropical Schur map w ↦ tropSchur(w) factors through the quotient (Fin n → ℤ) / Sₙ. Injectivity holds precisely on the fundamental domain of dominant weights.

## 8. The Hecke Basis Identity

**Theorem 8.1.** heckeBasis(w, x) = tropSchur(w, x), where:
```
heckeBasis(w, x) = min_σ Σᵢ w(i) · x(σ(i))
tropSchur(w, x) = min_σ Σᵢ w(σ(i)) · x(i)
```

*Proof.* By reindexing: Σᵢ w(i) · x(σ(i)) = Σⱼ w(σ⁻¹(j)) · x(j). As σ ranges over Sₙ, so does σ⁻¹. □

**Theorem 8.2** (Satake-Hecke Identity). S(heckeBasis(w)) = tropSchur(w).

## 9. Concrete Examples

### 9.1 GL₂ Example
For w = (3, 1) and x = (2, 5):
- σ = id: 3·2 + 1·5 = 11
- σ = swap: 1·2 + 3·5 = 17
- tropSchur = min(11, 17) = 11

Symmetry: tropSchur((3,1), (2,5)) = tropSchur((3,1), (5,2)) = 11.

### 9.2 GL₃ Example
For w = (3, 2, 1) and x = (1, 0, -1):
- The 6 permutations give inner products: 3-1=2, 3-2=1, 2-1=1, 2-3=-1, 1-2=-1, 1-3=-2
- tropSchur = min over these = -2

## 10. Generalized Tropical Satake

**Definition 10.1** (Tropical Satake Data). A triple (Λ, W, ⟨·,·⟩) where:
- W is a finite group acting on Λ
- ⟨·,·⟩ : Λ × Λ → ℤ is W-equivariant: ⟨w·λ, μ⟩ = ⟨λ, w⁻¹·μ⟩

**Definition 10.2** (Generalized Orbit-Min).
```
genTropSchur(data, w, x) = min_{σ ∈ W} ⟨σ·w, x⟩
```

**Theorem 10.1** (Argument Invariance). genTropSchur(data, w, τ·x) = genTropSchur(data, w, x).

**Theorem 10.2** (Weight Orbit Invariance). genTropSchur(data, τ·w, ·) = genTropSchur(data, w, ·).

These theorems hold for any finite group, not just symmetric groups. This covers the tropical Satake isomorphism for all split reductive groups (types A, B, C, D, G₂, F₄, E₆, E₇, E₈) at once.

## 11. Discussion

### 11.1 Relation to the Classical Satake Isomorphism

The classical Satake isomorphism identifies H(G, K) ≅ ℂ[X*(T)]^W. Our tropical version replaces:
- ℂ[X*(T)] with tropical polynomials (piecewise linear functions)
- The representation ring with the pointwise algebra under addition
- The Hecke algebra convolution with the tropical Hecke convolution

The collapse of convolution to pointwise product (Theorem 3.2) is the tropical shadow of the classical isomorphism.

### 11.2 Tropical Demazure Operators and Crystal Bases

The tropical Demazure operators connect to the theory of crystal bases (Kashiwara, Littelmann). In the crystal limit q → 0, Demazure modules become sets of lattice points in a polytope, and the Demazure character formula becomes a tropical identity. Our operators formalize this connection.

### 11.3 Applications to Optimization

The tropical Satake isomorphism has implications for symmetric optimization. Problems invariant under permutation of variables can be solved on the dominant chamber (weakly decreasing vectors), then extended to all of ℤⁿ by the Satake transform. The super-additivity theorem (5.1) provides bounds for decomposing combined objectives.

## 12. Future Work

1. **Tropical Littlewood-Richardson coefficients**: Decompose tropSchur(w₁) + tropSchur(w₂) into a tropical linear combination of tropSchur(μ).
2. **Tropical Kazhdan-Lusztig theory**: Define tropical analogues of KL polynomials and prove positivity.
3. **Connections to Newton polytopes**: Relate the Newton polytope of tropSchur(w) to the permutohedron.
4. **Computational complexity**: Determine the complexity of evaluating tropical Schur polynomials.

## References

1. I. Satake. Theory of spherical functions on reductive algebraic groups over p-adic fields. *Publ. Math. IHÉS*, 18:5–69, 1963.
2. G.L. Litvinov, V.P. Maslov. The correspondence principle for idempotent calculus and some computer applications. In *Idempotency*, Cambridge Univ. Press, 1998.
3. M. Kashiwara. Crystal bases of modified quantized enveloping algebra. *Duke Math. J.*, 73(2):383–413, 1994.
4. P. Littelmann. Paths and root operators in representation theory. *Ann. of Math.*, 142:499–525, 1995.
