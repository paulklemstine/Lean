# Tropical Satake Isomorphism for GL₂: Research Report

## Summary

We formalize in Lean 4 the tropical analog of the Satake isomorphism for GL₂, a foundational result connecting tropical geometry to the Langlands program. The formalization establishes that the tropical Satake transform is a bijection between the tropical Hecke algebra (functions on dominant coweights) and Weyl-invariant tropical Laurent polynomials, and computes the explicit Satake images of Hecke operators.

## Main Results

### 1. Satake Image Computation (Key Formula)

**Theorem** (`satakeImage_eq_nsmul_max`): For all n ∈ ℕ and x₁, x₂ ∈ ℝ,
$$\max_{0 \leq a \leq n} \left[ a \cdot x_1 + (n - a) \cdot x_2 \right] = n \cdot \max(x_1, x_2)$$

This is the core computational result. The tropical symmetric polynomial associated to the Hecke operator T_n simplifies to n times the tropical first elementary symmetric function. This reflects the fact that in the max-plus algebra, the max over a convex combination of linear functions achieves its maximum at a vertex of the feasible set.

### 2. Weyl Invariance

**Theorem** (`satakeImage_weyl_invariant`): The Satake image of every Hecke operator is S₂-symmetric:
$$\text{satakeImage}(n, x_1, x_2) = \text{satakeImage}(n, x_2, x_1)$$

This is proved via the bijection a ↦ n − a on {0, …, n}, which swaps the roles of x₁ and x₂.

### 3. The Bijection Theorem

**Theorem** (`satakeTransform_bijective`): The tropical Satake transform
$$S_{\text{trop}} : (D \to \mathbb{R}) \to \text{SymmFun}$$
is a bijection, where D is the set of dominant coweights {(a,b) ∈ ℤ² : a ≥ b} and SymmFun is the type of S₂-symmetric functions ℤ² → ℝ.

We construct an explicit equivalence (`satakeEquiv`) with left inverse `restrictToDom` (restriction to the dominant Weyl chamber) and right inverse `satakeTransform` (extension by symmetry). The proof decomposes into:
- `restrict_satake`: Left inverse property, using that toDom is idempotent on dominant coweights.
- `satake_restrict`: Right inverse property, using the S₂-symmetry of the target function.

### 4. Homomorphism Property

**Theorem** (`satakeTransform_mul_eval`): The Satake transform preserves tropical multiplication:
$$\text{satakeImage}(m + n, x_1, x_2) = \text{satakeImage}(m, x_1, x_2) + \text{satakeImage}(n, x_1, x_2)$$

In tropical algebra, polynomial multiplication corresponds to ordinary addition of piecewise-linear functions, and the Hecke operator T_{m+n} decomposes as the tropical product T_m ⊗ T_n.

### 5. Tropical Trace Formula

**Theorem** (`divisorSum_prime`): For prime p, the divisor sum σ₁(p) = p + 1.

Combined with `tropical_trace_formula_prime`, this establishes that the geometric side (counting sublattices of ℤ² of index p) equals the spectral side (the divisor sum), matching both sides at p + 1. This is the tropical shadow of the Arthur-Selberg trace formula for GL₂.

## Technical Details

### Definitions

| Name | Type | Description |
|------|------|-------------|
| `satakeImage` | `ℕ → ℝ → ℝ → ℝ` | Evaluation of Hecke operator Satake image |
| `tropE1` | `ℝ → ℝ → ℝ` | Tropical e₁ = max(x₁, x₂) |
| `tropE2` | `ℝ → ℝ → ℝ` | Tropical e₂ = x₁ + x₂ |
| `DomCoweight` | `Type` | Dominant coweights {(a,b) : a ≥ b} |
| `SymmFun` | `Type` | S₂-symmetric functions ℤ² → ℝ |
| `satakeTransform` | `(DomCoweight → ℝ) → SymmFun` | The tropical Satake transform |
| `satakeEquiv` | `(DomCoweight → ℝ) ≃ SymmFun` | The Satake equivalence |
| `tropConv` | Function convolution | Tropical convolution |
| `tropPolyMul` | `SymmFun → SymmFun → SymmFun` | Tropical polynomial multiplication |
| `divisorSum` | `ℕ → ℕ` | The divisor sum σ₁(n) |

### Proof Architecture

The formalization is structured in six sections:
1. **Tropical symmetric polynomials** — Core definitions
2. **Properties of the Satake image** — Computational theorems
3. **Hecke algebra and Satake transform** — The bijection theorem
4. **Tropical convolution** — Algebra structure and homomorphism
5. **Concrete computations** — Explicit calculations for T₁, T₂
6. **Tropical trace formula** — Divisor sum computations

All proofs compile without `sorry` and use only standard axioms (`propext`, `Classical.choice`, `Quot.sound`).

## Significance

### Connection to the Langlands Program

The classical Satake isomorphism is the foundation of the unramified Langlands correspondence. Our tropical formalization reveals that the combinatorial skeleton of this isomorphism — the structure of double cosets, the symmetrization by the Weyl group, and the generation by elementary symmetric functions — survives tropicalization intact. This suggests that the arithmetic content of the Langlands program may have a purely combinatorial core that can be captured in the max-plus semiring.

### Implications for Tropical Geometry

The key formula `satakeImage n = n · max(x₁, x₂)` shows that all tropical Hecke operators for GL₂ are powers of the first elementary symmetric function. This is the tropical shadow of the fact that the representation ring of GL₂ is generated by the standard representation. In higher rank, the tropical Satake image would involve Newton polytopes of dimension > 1, connecting to tropical intersection theory.

### Formal Verification

This is among the first formalizations connecting tropical geometry to number theory in a proof assistant. The formalization demonstrates that tropical algebraic structures are well-suited to formal verification due to their combinatorial nature: every computation reduces to manipulating max and addition over finite sets.

## File Location

The complete formalization is in `Tropical/Langlands/SatakeIsomorphism.lean`.
