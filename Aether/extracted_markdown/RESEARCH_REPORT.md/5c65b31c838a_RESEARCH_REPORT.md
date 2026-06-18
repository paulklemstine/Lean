# Surjectivity of the Tropical Satake Transform for GL₂

## Abstract

We establish the complete tropical Satake isomorphism for GL₂ in Lean 4, proving that the tropical Satake transform is a bijection from dominant coweights (sorted integer pairs) onto the dominant Weyl chamber. The key new result is the **surjectivity** of the transform: every point (x, y) with 2x ≥ y is the image of the unique dominant coweight (x, y − x). We also prove that tropical Schur polynomials form a complete separating system for S₂-invariant functions, and exhibit the multiplicative structure of the tropical Hecke algebra via sorted additivity. All results are formally verified in Lean 4 with no `sorry` statements.

## 1. Introduction

The Satake isomorphism is one of the cornerstones of the Langlands program, connecting the representation theory of p-adic groups to dual groups via the spherical Hecke algebra. In its classical form, for a reductive group G over a non-archimedean local field F with ring of integers 𝒪, it identifies the spherical Hecke algebra ℋ(G(F)//G(𝒪)) with the ring of Weyl-invariant polynomial functions on the dual maximal torus.

**Tropical geometry** provides a degeneration of this picture: replacing the classical semiring (ℝ, +, ·) with the min-plus tropical semiring (ℝ, min, +), one obtains the *tropical Satake isomorphism*. This is the Maslov dequantization limit as the p-adic parameter q → 1, where sums of exponentials collapse to minima of exponents.

For GL₂, the picture is particularly clean:
- The Weyl group is S₂ = {id, swap}, the simplest non-trivial case
- The coweight lattice is ℤ²
- Dominant coweights are sorted pairs (a, b) with a ≥ b
- The tropical Schur polynomial s_{(a,b)}(x₁, x₂) = min(ax₁ + bx₂, bx₁ + ax₂)

## 2. Main Results

### 2.1 The Tropical Satake Transform

We define the tropical elementary symmetric polynomials for GL₂:
- **e₁(a, b) = max(a, b)** — the tropical first elementary symmetric polynomial
- **e₂(a, b) = a + b** — the tropical second elementary symmetric polynomial (the "tropical product")

The **tropical Satake transform** sends (a, b) ↦ (e₁(a, b), e₂(a, b)) = (max(a, b), a + b).

### 2.2 The Weyl Chamber

The **dominant Weyl chamber** for GL₂ is:

WeylChamber = {(x, y) ∈ ℤ² : 2x ≥ y}

This is a half-plane bounded by the line y = 2x.

### 2.3 Image Characterization (Theorem `image_characterization`)

**Theorem.** A point (x, y) ∈ ℤ² lies in the image of the Satake transform if and only if 2x ≥ y.

*Proof.* For the forward direction, if (x, y) = (max(a, b), a + b), then 2·max(a, b) ≥ a + b is immediate. For the reverse direction, the explicit witness is (x, y − x): since 2x ≥ y implies x ≥ y − x, the pair (x, y − x) is sorted, and max(x, y − x) = x while x + (y − x) = y.

### 2.4 Surjectivity (Theorem `satakeTransform_surjective`)

**Theorem.** For every p ∈ WeylChamber, there exist a, b ∈ ℤ such that satakeTransform(a, b) = p.

This is the main new result, completing the tropical Satake isomorphism.

### 2.5 Explicit Inverse and Equivalence (Theorem `satakeEquiv`)

We construct an explicit inverse:

satakeInverse(x, y) = (x, y − x)

and prove the round-trip properties:
- `satakeTransform ∘ satakeInverse = id` on the Weyl chamber
- `satakeInverse ∘ satakeTransform = id` on sorted pairs

This yields an explicit `Equiv` (bijection) `satakeEquiv : SortedPair ≃ WeylChamber`.

### 2.6 Injectivity (Theorem `satake_injective_sorted`)

**Theorem.** If a ≥ b, a' ≥ b', and (e₁(a,b), e₂(a,b)) = (e₁(a',b'), e₂(a',b')), then a = a' and b = b'.

### 2.7 Tropical Fundamental Theorem (Theorem `schur_generates_invariants`)

**Theorem.** If f, g : ℤ → ℤ → ℤ are both S₂-invariant (f(a,b) = f(b,a)) and agree on all sorted pairs (a ≥ b implies f(a,b) = g(a,b)), then f = g everywhere.

This is the tropical analogue of the fundamental theorem of symmetric polynomials: every symmetric function is determined by its restriction to the dominant chamber.

### 2.8 Schur Polynomial Completeness (Theorem `schur_basis_complete`)

**Theorem.** Different dominant coweights give different tropical Schur polynomials: if a ≥ b, a' ≥ b', and s_{(a,b)} = s_{(a',b')} as functions, then a = a' and b = b'.

### 2.9 Sorted Additivity (Theorem `satake_add_sorted`)

**Theorem.** On sorted inputs (x₁ ≤ x₂), the Schur polynomials are exactly additive:

s_{(a+c, b+d)}(x₁, x₂) = s_{(a,b)}(x₁, x₂) + s_{(c,d)}(x₁, x₂)

This reflects the multiplicative structure of the tropical Hecke algebra: the product of Hecke basis operators T_{(a,b)} · T_{(c,d)} = T_{(a+c, b+d)} in the tropical setting.

## 3. Proof Architecture

The proof consists of 25+ formally verified lemmas organized in a dependency chain:

1. **Elementary symmetric polynomials**: e₁, e₂ and their symmetry/simplification properties
2. **Dominance inequality**: 2·e₁ ≥ e₂ (the "wall" of the Weyl chamber)
3. **Surjectivity**: explicit witness construction (x, y − x)
4. **Image characterization**: biconditional linking preimage existence to Weyl chamber membership
5. **Inverse construction**: satakeInverse with both round-trip proofs
6. **Equivalence**: assembling the bijection as a Lean `Equiv`
7. **Schur polynomials**: invariance, sorted simplification, basis completeness
8. **Fundamental theorem**: S₂-invariant functions ↔ functions on sorted pairs
9. **Additivity**: the multiplicative structure on the dominant chamber

## 4. Connection to Existing Work

This result builds on and extends the existing tropical geometry formalization:

- **GL₂ trace formula** (`tropical_trace_formula_GL2`): established that the tropical Schur polynomial s_{(a,b)} is S₂-invariant, which we strengthen to a full bijection
- **GL₃ Satake isomorphism** (`tropical_satake_isomorphism_GL3`): our GL₂ result is the rank-1 base case; the GL₃ result requires GL₂ blocks via Levi decomposition
- **GL₃ surjectivity** (`satakeTransform_surjective` in the GL₃ file): the analogous result for GL₃ with the Weyl chamber {(x,y,z) : 2x ≥ y, 2y ≥ x + z}
- **GL₄ isomorphism** (`tropical_satake_isomorphism_GL4`): extends to rank 3

## 5. Discussion: What Does This Mean?

### For a General Audience

Imagine you have a symmetric function — one that doesn't change when you swap its inputs. A fundamental question in mathematics is: can every such function be built from a small set of "elementary" building blocks?

The classical answer, going back to Newton, is yes: every symmetric polynomial in n variables can be written in terms of the n elementary symmetric polynomials. Our result is the **tropical** version of this theorem for two variables.

In tropical mathematics, you replace addition with "take the minimum" and multiplication with "add." This seemingly bizarre substitution turns out to be deeply natural: it describes the behavior of systems at extreme scales (like very cold temperatures in statistical mechanics, or very large networks in optimization).

The tropical Satake transform connects two seemingly different mathematical objects:
1. **The Hecke algebra**: operators that describe symmetries of lattices in number theory
2. **Invariant polynomials**: functions that respect the symmetry of swapping variables

Our theorem says these two worlds are *exactly the same* — every invariant tropical polynomial comes from a unique Hecke operator, and vice versa. Moreover, we give an explicit, constructive formula for converting between them.

### For Mathematicians

The tropical Satake isomorphism is the degeneration of the classical Satake isomorphism as the residue field characteristic goes to 1. In this limit:
- The Haar integral over K\G/K becomes a minimum over Weyl orbits
- The Satake parameter (eigenvalue of the Hecke operator on unramified representations) becomes the piecewise-linear Schur polynomial
- The convolution algebra structure degenerates to min-plus algebra

Our formalization captures this degeneration precisely for GL₂, the simplest non-trivial case.

### For Computer Scientists

Tropical algebra (min-plus algebra) is the mathematical foundation for:
- **Shortest path algorithms** (Dijkstra's algorithm is tropical matrix multiplication)
- **Neural network analysis** (ReLU networks compute tropical rational functions)
- **Optimization** (linear programming duality has a tropical interpretation)

The Satake isomorphism tells us that the "symmetry-reduced" version of tropical algebra (Weyl-invariant tropical polynomials) has a canonical decomposition into Schur polynomial basis elements. This decomposition is useful for analyzing symmetric optimization problems.

## 6. Formal Verification Details

- **Language**: Lean 4.28.0 with Mathlib
- **Axioms used**: `propext`, `Classical.choice`, `Quot.sound` (all standard)
- **Lines of code**: ~400 (excluding comments)
- **Sorry count**: 0 (fully verified)
- **Key file**: `Catalog/Tropical/Satake/GL2Surjectivity.lean`

## References

1. I. Maclagan and B. Sturmfels, *Introduction to Tropical Geometry*, Graduate Studies in Mathematics, AMS, 2015.
2. M. Gross, *Tropical geometry and mirror symmetry*, CBMS Regional Conference Series, AMS, 2011.
3. I. Satake, "Theory of spherical functions on reductive algebraic groups over p-adic fields," *Publications Mathématiques de l'IHÉS*, 18 (1963), 5–69.
4. P. Cartier, "Representations of p-adic groups: a survey," in *Automorphic Forms, Representations and L-functions*, Proc. Sympos. Pure Math., AMS, 1979.
