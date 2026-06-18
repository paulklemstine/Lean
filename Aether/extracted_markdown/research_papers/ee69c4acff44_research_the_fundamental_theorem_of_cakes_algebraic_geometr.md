# The Fundamental Theorem of Cakes: Stratified Moduli Theory for Layered Geometric Objects

## Abstract

We formalize a theory of "cakes" — combinatorial objects encoding the topology of compact orientable surfaces with boundary, marked points, and layer stratifications. We prove that every such object is determined by its genus *g*, boundary count *b*, cherry count *n*, and layer structure *L*. The central results include: (1) an Euler characteristic additivity formula under surface gluing, (2) the classical 6g − 6 + 2n dimension formula for moduli spaces of marked surfaces with a proof of its evenness and its relationship to complex moduli dimension 3g − 3 + n, (3) a sharp bound on stratification length in terms of ambient dimension, (4) monotonicity of moduli dimension under a natural categorical ordering on cakes, and (5) a superadditivity result showing that gluing cakes creates 6 additional moduli parameters. All results are machine-verified.

**Keywords**: moduli spaces, stratified spaces, Euler characteristic, surface classification, Teichmüller theory, categorical structures

---

## 1. Introduction

The classification of compact surfaces is one of the oldest and most elegant results in topology. Every compact orientable surface is determined, up to homeomorphism, by its genus *g* (number of handles) and number of boundary components *b*. The Euler characteristic χ = 2 − 2g − b provides a coarse but powerful topological invariant.

When surfaces carry additional structure — marked points, conformal structures, line bundles on their boundary — the classification problem becomes richer. The moduli space M_{g,n} of genus-*g* surfaces with *n* marked points has dimension 6g − 6 + 2n (as a real manifold), a formula that underlies vast areas of algebraic geometry, string theory, and mathematical physics.

In this paper, we introduce "cake data" as a combinatorial encoding of these structures, adding a layer stratification to capture the flag structure of embedded subvarieties. We prove fundamental properties of these objects and establish their categorical structure.

## 2. Definitions

### 2.1 Cake Data

**Definition 1** (CakeData). A *cake datum* is a quadruple C = (g, b, n, k) where:
- g ∈ ℕ is the **genus** (number of handles of the base surface)
- b ∈ ℕ is the **boundary count** (number of boundary components / frosting edges)
- n ∈ ℕ is the **cherry count** (number of marked points)
- k ∈ ℕ is the **layer count** (depth of the stratification)

**Definition 2** (Euler Characteristic). The Euler characteristic of a cake C = (g, b, n, k) is:
$$\chi(C) = 2 - 2g - b$$

**Definition 3** (Moduli Dimension). The real moduli dimension is:
$$\dim_{\mathbb{R}} \mathcal{M}(C) = 6g - 6 + 2n$$

The complex moduli dimension is:
$$\dim_{\mathbb{C}} \mathcal{M}(C) = 3g - 3 + n$$

### 2.2 Layer Stratification

**Definition 4** (LayerStratification). A *layer stratification* of depth *d* is a list of natural numbers (d₀, d₁, ..., dₖ) satisfying:
- d₀ = d (starts at ambient dimension)
- dₖ = 0 (ends at a point)
- dᵢ > dᵢ₊₁ for all i (strictly decreasing)

A stratification is **complete** if its length is d + 1, meaning every codimension from 0 to d is represented.

### 2.3 Frosting Sheaf

**Definition 5** (FrostingSheaf). A *frosting sheaf* on a cake with *b* boundary components is a function δ : {1, ..., b} → ℤ assigning a degree to each boundary component. The total degree is Σᵢ δ(i). The sheaf is **uniform** if all degrees are equal.

### 2.4 Full Cake

**Definition 6** (Cake). A *cake* is a triple (C, F, L) where C is cake data, F is a frosting sheaf with numComponents = b, and L is a layer stratification of depth k.

## 3. Main Results

### 3.1 Euler Characteristic Under Gluing

**Theorem 1** (Euler Characteristic Additivity). Let C₁ = (g₁, b₁, n₁, k₁) and C₂ = (g₂, b₂, n₂, k₂) be cake data with b₁ ≥ 1 and b₂ ≥ 1. Define the glued cake:
$$C_{glued} = (g₁ + g₂, b₁ + b₂ - 2, n₁ + n₂, k₁ + k₂)$$

Then χ(C_{glued}) = χ(C₁) + χ(C₂).

*Proof sketch.* Direct computation: 2 − 2(g₁ + g₂) − (b₁ + b₂ − 2) = (2 − 2g₁ − b₁) + (2 − 2g₂ − b₂). The key insight is that gluing along a circle (χ = 0) preserves the additive structure of the Euler characteristic.

### 3.2 Moduli Dimension Properties

**Theorem 2** (Evenness). The real moduli dimension 6g − 6 + 2n is always even.

*Proof.* Write 6g − 6 + 2n = 2(3g − 3 + n). ∎

**Theorem 3** (Complex-Real Relationship). 2 · dim_ℂ = dim_ℝ.

*Proof.* Direct algebraic identity: 2(3g − 3 + n) = 6g − 6 + 2n. ∎

**Theorem 4** (Rigidity Threshold). For g ≥ 2, the moduli dimension satisfies dim_ℝ ≥ 6, regardless of the number of marked points.

*Proof.* When g ≥ 2 and n ≥ 0: 6g − 6 + 2n ≥ 12 − 6 + 0 = 6. ∎

**Theorem 5** (Genus-0 Cherry Minimum). For genus 0, non-negative moduli dimension requires n ≥ 3.

*Proof.* If g = 0: 6(0) − 6 + 2n ≥ 0 implies 2n ≥ 6, hence n ≥ 3. ∎

### 3.3 Stratification Bounds

**Theorem 6** (Stratification Length Bound). Any layer stratification of depth *d* has at most *d* + 1 elements.

*Proof.* The elements form a strictly decreasing sequence of natural numbers with maximum value *d* (the head) and minimum value 0 (the last). Strict decrease implies all elements are distinct. Since they lie in {0, 1, ..., d}, which has d + 1 elements, the length is at most d + 1. ∎

**Theorem 7** (Canonical Flag Completeness). The canonical flag (d, d−1, ..., 1, 0) achieves the bound with exactly d + 1 elements.

### 3.4 Gluing Superadditivity

**Theorem 8** (Moduli Superadditivity). When two cakes are glued:
$$\dim \mathcal{M}(C_{glued}) = \dim \mathcal{M}(C₁) + \dim \mathcal{M}(C₂) + 6$$

*Proof.* The glued cake has genus g₁ + g₂ and cherry count n₁ + n₂:
6(g₁ + g₂) − 6 + 2(n₁ + n₂) = (6g₁ − 6 + 2n₁) + (6g₂ − 6 + 2n₂) + 6. ∎

The +6 represents the moduli contribution of the new handle created by the gluing.

### 3.5 Monotonicity and Genus Increments

**Theorem 9** (Genus Increment). Adding one handle increases moduli dimension by exactly 6.

**Theorem 10** (Cherry Increment). Adding one marked point increases moduli dimension by exactly 2.

### 3.6 Categorical Structure

**Theorem 11** (Moduli Monotonicity). If there exists a cake morphism C → D (i.e., g(C) ≤ g(D), b(C) ≤ b(D), n(C) ≤ n(D)), then dim M(C) ≤ dim M(D).

**Theorem 12** (Transitivity). Composition of cake morphisms preserves moduli monotonicity.

### 3.7 Frosting Sheaf Properties

**Theorem 13** (Uniform Frosting). For a uniform frosting sheaf with all degrees equal to δ:
$$\deg_{total}(F) = b \cdot \delta$$

### 3.8 Surface Classification

**Theorem 14** (Euler + Boundary Determines Genus). If two cakes have equal Euler characteristics and equal boundary counts, they have equal genera.

*Proof.* From χ = 2 − 2g − b, if χ₁ = χ₂ and b₁ = b₂, then 2g₁ = 2g₂, hence g₁ = g₂. ∎

## 4. The 3g − 3 Formula and Computational Verification

For genus g ≥ 2 with no marked points, the complex moduli dimension specializes to 3g − 3. We verify computationally:

| Genus g | Complex Dim (3g-3) | Real Dim (6g-6) |
|---------|-------------------|-----------------|
| 2       | 3                 | 6               |
| 3       | 6                 | 12              |
| 4       | 9                 | 18              |
| 5       | 12                | 24              |

This matches the classical dimension of the moduli space M_g of smooth curves of genus g.

## 5. Conjectures and Future Directions

**Conjecture 1** (Cherry-Boundary Duality). For cakes with b boundary components and n cherries, there exists a natural duality M_{g,b,n} ≅ M_{g,n,b} when certain compatibility conditions are met. This would connect the moduli of surfaces-with-boundary to the moduli of surfaces-with-marked-points.

**Test**: Compute dimensions of both sides for small g, b, n and verify they agree. The dimension formula 6g − 6 + 2n + b should equal 6g − 6 + 2b + n only when n = b, suggesting the duality is restricted.

**Conjecture 2** (Stratification Rigidity). A complete flag stratification of a smooth projective variety of dimension d is unique up to the action of the automorphism group.

## 6. Algorithms

### 6.1 Cake Enumeration

Given bounds on genus, boundary, and cherry count, enumerate all valid cakes and compute their moduli dimensions. This is a simple combinatorial enumeration with O(G × B × N) complexity.

### 6.2 Moduli Dimension Computation

For any cake datum, compute the moduli dimension in O(1) time using the closed-form formula.

## 7. Conclusion

We have established a rigorous combinatorial framework for studying "cakes" as stratified surfaces with boundary, marked points, and layer decompositions. The key mathematical content — Euler characteristic formulas, moduli dimension computations, stratification bounds, and categorical monotonicity — connects to fundamental results in algebraic geometry and topology. All results have been machine-verified, ensuring correctness of the mathematical arguments.

## References

1. Riemann, B. (1857). Theorie der Abel'schen Functionen. *Journal für die reine und angewandte Mathematik*, 54, 115-155.
2. Teichmüller, O. (1939). Extremale quasikonforme Abbildungen und quadratische Differentiale. *Abh. Preuss. Akad. Wiss., Math.-Naturw. Kl.*, 22, 1-197.
3. Mumford, D. (1965). *Geometric Invariant Theory*. Springer-Verlag.
4. Harris, J., & Morrison, I. (1998). *Moduli of Curves*. Springer-Verlag.
5. Farb, B., & Margalit, D. (2012). *A Primer on Mapping Class Groups*. Princeton University Press.
