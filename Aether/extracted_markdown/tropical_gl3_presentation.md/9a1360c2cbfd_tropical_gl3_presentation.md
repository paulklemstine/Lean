# Finite Presentation of the GL₃ Tropical Satake Image via Simple-Coroot Edge Valuations and Fundamental Pieri Generators

## Abstract

We establish a finite-determinacy and finite-presentation theorem for the tropical spherical Hecke algebra of GL₃. Working in the combinatorial model where dominant coweights are pairs (a, b) ∈ ℕ × ℕ representing partitions (a+b, b, 0), we show that any function with bounded support is uniquely determined by its ω₂-Pieri convolution profile. This yields an explicit bijection between bounded-support tropical Hecke functions and "compatible observable packages" — finite data sets satisfying local tropical relations. The key structural insight is that the Pieri rule for the second fundamental representation ∧²V of GL₃ has exactly one predecessor per dominant coweight, reducing the convolution to a shift operator. All results are formally verified in Lean 4 with Mathlib.

## 1. Introduction

### 1.1 The Tropical Satake Correspondence

The classical Satake isomorphism identifies the spherical Hecke algebra of a reductive group G over a non-archimedean local field with the representation ring of the Langlands dual group. For G = GL_n, this becomes an isomorphism between the algebra of GL_n(O)-bi-invariant functions on GL_n(F) and the ring of symmetric polynomials in n variables.

In the *tropical limit* — obtained by replacing ordinary arithmetic with min-plus operations — the Satake isomorphism persists as a correspondence between:
- Functions on dominant coweights (the "tropical Hecke algebra"), and
- Tropical symmetric polynomials (the "tropical representation ring").

This tropical correspondence has gained importance through connections to:
- Tropical geometry and Newton polytopes
- Crystal bases and Littelmann paths in representation theory
- Optimization and tropical linear algebra
- Neural network expressivity via tropical polynomial representations

### 1.2 The Finite Presentation Problem

A fundamental question in tropical Hecke theory is:

> **Given finitely many "observable" quantities extracted from a tropical Hecke function f, can we uniquely reconstruct f? If so, what are the necessary and sufficient conditions on the observables?**

This is the **finite presentation problem**: can we describe the tropical Hecke algebra (restricted to bounded support) as a finitely presented algebraic object — specified by finitely many generators and finitely many explicit relations?

### 1.3 Main Results

For GL₃, we answer this question completely. Let DomWeightGL₃ = ℕ × ℕ be the dominant coweight lattice, where (a,b) represents the partition (a+b, b, 0).

**Theorem 1 (Finite Determinacy).** Let f, g : ℕ × ℕ → ℝ have bounded support (HasBoxSupport N). If f and g have the same edge restrictions (edge1, edge2) and the same Pieri convolution profiles (pieriObs1, pieriObs2), then f = g.

In fact, we prove the stronger result:

**Theorem 2 (ω₂-Determinacy).** If pieriObs2(f) = pieriObs2(g), then f = g, without any support assumption.

**Theorem 3 (Realization).** Every compatible observable package can be realized by a bounded-support function.

**Theorem 4 (Finite Presentation).** The observable image equals the set of compatible packages:
$$\text{ObservableImage}(N) = \{O \mid \text{Compatible}(N, O)\}$$

**Theorem 5 (Equivalence).** There exists an explicit bijection between bounded-support functions and compatible observable packages that preserves edge data.

### 1.4 Formal Verification

All theorems are formally verified in Lean 4 using the Mathlib library. The formalization is approximately 480 lines and uses only the standard axioms (propext, Classical.choice, Quot.sound). No sorry statements remain in the final code.

## 2. The GL₃ Pieri Rule

### 2.1 Representation-Theoretic Background

For GL₃, the dominant representations are indexed by partitions λ = (λ₁ ≥ λ₂ ≥ λ₃ ≥ 0). In our coordinates, (a,b) ∈ ℕ × ℕ corresponds to λ = (a+b, b, 0), or equivalently a·ω₁ + b·ω₂ in fundamental weights.

The **Pieri rule** describes the tensor product of a dominant representation V(μ) with a fundamental representation:

**For ω₁ (standard representation V):** V(μ) ⊗ V(ω₁) decomposes as ⊕ V(ν) where ν ranges over partitions obtained from μ by adding one box to the Young diagram, maintaining dominance. For GL₃, adding one box to μ = (a+b, b, 0) gives:
- (a+b+1, b, 0) = (a+1, b): add to row 1 (always valid)
- (a+b, b+1, 0) = (a-1, b+1): add to row 2 (requires a ≥ 1)

**For ω₂ (exterior square ∧²V):** V(μ) ⊗ V(ω₂) adds a vertical strip of size 2 — one box to each of exactly two rows. For GL₃ with μ₃ = 0, the only valid option is:
- (a+b+1, b+1, 0) = (a, b+1): add to rows 1 and 2 (always valid)

### 2.2 The Key Observation

The crucial structural fact is:

> **For GL₃, the ω₂-Pieri rule has exactly one predecessor per dominant coweight.**

This means the "Pieri predecessor" of (a,b) for ω₂ is simply (a, b-1) (when b ≥ 1). In the tropical convolution:

$$(\text{pieriObs2}\, f)(a, b+1) = f(a, b)$$

The ω₂-Pieri operator is a **simple shift** — it moves the function down by one step in the second coordinate.

This is a phenomenon specific to rank 2. For GL_n with n ≥ 4, intermediate fundamental representations (like ∧²V for GL₅) have multiple Pieri predecessors, and the corresponding tropical convolution involves a genuine tropical minimum over multiple terms. In those cases, the recovery problem becomes substantially harder.

### 2.3 The ω₁-Pieri Operator

The ω₁-Pieri operator has a more complex structure:

$$(\text{pieriObs1}\, f)(a+1, b+1) = \min(f(a, b+1),\, f(a+2, b))$$

This is a tropical minimum over two predecessors at the same height (a + b + 1 = a + b + 1), which does NOT determine f values uniquely. The minimum operation loses information: knowing min(x, y) does not determine x and y individually.

The interplay between the simple ω₂-Pieri (which determines everything) and the complex ω₁-Pieri (which provides consistency conditions) is the mathematical heart of our finite presentation result.

## 3. Observable Packages and Compatibility

### 3.1 The Observable Map

Given a function f : ℕ × ℕ → ℝ with HasBoxSupport N, we extract the **observable package**:

```
ObsMap(f) = (edge1(f), edge2(f), pieriObs1(f), pieriObs2(f))
```

where:
- edge1(f)(n) = f(n, 0): restriction to the ω₁-axis
- edge2(f)(n) = f(0, n): restriction to the ω₂-axis
- pieriObs1(f): the ω₁-Pieri convolution profile
- pieriObs2(f): the ω₂-Pieri convolution profile (= shift of f)

### 3.2 Compatibility Conditions

An observable package O = (e₁, e₂, c₁, c₂) is **compatible** if:

1. **Boundary consistency:** c₂(a, 1) = e₁(a) and c₂(0, b+1) = e₂(b)
2. **Base vanishing:** c₂(a, 0) = 0
3. **ω₁-Pieri consistency at (0,0):** c₁(0, 0) = 0
4. **ω₁-Pieri consistency at edges:** c₁(a+1, 0) = c₂(a, 1) and c₁(0, b+1) = c₂(1, b+1)
5. **Tropical rhombus relation:** c₁(a+1, b+1) = min(c₂(a, b+2), c₂(a+2, b+1))
6. **Support:** c₂(a, b) = 0 when a + b > N + 1

Condition 5 is the most interesting: it is the **tropical rhombus inequality**, which constrains the ω₁-Pieri profile to be consistent with the reconstructed function. This is the tropical analogue of the classical identity relating the Hecke eigenvalue at an interior point to neighboring values.

### 3.3 Reconstruction

The reconstruction is explicit:

$$f(a, b) = c_2(a, b+1)$$

This formula directly inverts the shift: if c₂ is the ω₂-Pieri profile of some function, then c₂(a, b+1) = f(a, b). The compatibility conditions ensure that the edge data (e₁, e₂) and the ω₁-Pieri profile (c₁) are consistent with this reconstructed function.

## 4. The Abstract Framework

### 4.1 Triangular Recovery

We also prove an abstract version of the determinacy theorem that applies to any pair of operators satisfying the **triangular recovery property**:

> **Definition.** Operators F₁, F₂ satisfy TriangularRecovery if, for any interior point (a, b) with a > 0 and b > 0, knowing F₁ and F₂ at nearby points (height ≤ a+b+1) together with all function values at strictly lower height determines f(a, b).

**Theorem (Abstract Determinacy).** If (F₁, F₂) satisfies TriangularRecovery, and f and g agree on edges and have the same F₁ and F₂ profiles, then f = g.

The proof uses **strong induction on height** a + b:
- **Base (a = 0 or b = 0):** Use edge data equality.
- **Step (a > 0, b > 0):** Apply the recovery property with the induction hypothesis.

This framework is designed for higher-rank generalizations where the recovery genuinely requires induction.

### 4.2 GL₃ Satisfies Triangular Recovery

The GL₃ Pieri operators satisfy TriangularRecovery via a simple argument: the ω₂-Pieri value at (a, b+1) — which has height a + b + 1, within the allowed range — directly gives f(a, b). Neither the ω₁-Pieri nor the lower-height induction hypothesis is needed.

## 5. Proof of the Finite Presentation Theorem

### 5.1 Injectivity (Image ⊆ Compatible)

Given a function f realizing an observable package O, each compatibility condition follows directly from the definitions:

- **Boundary consistency:** c₂(a, 1) = pieriObs2 f (a, 1) = f(a, 0) = edge1 f (a) = e₁(a).
- **Tropical rhombus:** c₁(a+1, b+1) = pieriObs1 f (a+1, b+1) = min(f(a, b+1), f(a+2, b)) = min(c₂(a, b+2), c₂(a+2, b+1)).

### 5.2 Surjectivity (Compatible ⊆ Image)

Given a compatible package O, define f(a, b) = c₂(a, b+1). Then:

- HasBoxSupport N: f(a, b) = c₂(a, b+1) = 0 when a + (b+1) > N+1, i.e., a + b > N.
- edge1 f (a) = f(a, 0) = c₂(a, 1) = e₁(a) by boundary1.
- edge2 f (b) = f(0, b) = c₂(0, b+1) = e₂(b) by boundary2.
- pieriObs1 f = c₁: by cases on (a, b), using the consistency conditions.
- pieriObs2 f = c₂: pieriObs2 f (a, b+1) = f(a, b) = c₂(a, b+1), and pieriObs2 f (a, 0) = 0 = c₂(a, 0) by c2_base.

### 5.3 The Bijection

Combining injectivity and surjectivity, we obtain:

$$\{f \mid \text{HasBoxSupport}(N, f)\} \xrightarrow{\sim} \{O \mid \text{Compatible}(N, O)\}$$

This bijection preserves edge data: the edge components of the observable package equal the edge restrictions of the function.

## 6. Discussion

### 6.1 For a General Audience: What Does This Mean?

Imagine you have a mysterious function defined on a triangular grid of points. You can't see the function directly, but you CAN see two types of "shadows":

1. **Edge shadows**: The function values along the two boundary edges of the triangle.
2. **Shift shadow**: What the function looks like when you slide the grid one step down.

Our theorem says: **these shadows completely determine the original function.** There's no ambiguity — given the shadows, there's exactly one function that could have cast them.

Moreover, not every collection of "shadow data" comes from a real function. The shadows must satisfy specific **consistency conditions** — like a jigsaw puzzle where the pieces must fit together. We identify exactly what these conditions are.

This is analogous to how a CT scan works: from finitely many X-ray projections, you can reconstruct a 3D image, but only if the projections are consistent with an actual 3D object.

### 6.2 The Rank-2 Simplification

Our result exploits a special feature of GL₃ (rank 2): the second fundamental representation ∧²V has a particularly simple combinatorial structure. Its Pieri rule — which describes how tensor products decompose — has exactly one "predecessor" for each point in the lattice.

For higher-rank groups (GL₄, GL₅, ...), the intermediate fundamental representations have *multiple* predecessors, and the corresponding "shift shadow" becomes a "minimum shadow" — you see the minimum of several values instead of a single value. Recovering the original function from a minimum shadow is much harder, because the minimum operation loses information.

This is why our abstract framework (the "triangular recovery" property) uses induction on height: for higher rank, you need to build up the function layer by layer, using previously recovered values to disentangle the minima.

### 6.3 Connections to Existing Work

**Tropical Geometry:** Our finite presentation is a combinatorial avatar of the classical Satake isomorphism. The compatible observable packages form a tropical cone, and the compatibility conditions are the defining inequalities of this cone.

**Crystal Bases:** The Pieri predecessors correspond to crystal operators (Kashiwara's lowering operators) on highest-weight crystals. The single-predecessor property for ω₂ in GL₃ reflects the fact that the crystal graph of the second fundamental representation has a particularly simple structure.

**Neural Networks:** Tropical polynomials appear naturally as the functions computed by ReLU neural networks. Our finite presentation result implies that certain neural network architectures (those computing functions on the GL₃ weight lattice) can be parameterized by finitely many "observable features" subject to local consistency conditions.

### 6.4 Future Directions

1. **Higher Rank (GL_n, n ≥ 4):** The main challenge is proving TriangularRecovery when both fundamental convolutions involve tropical minima over multiple predecessors. The abstract framework is ready; the hard work is verifying the recovery property.

2. **Other Root Systems:** For non-type-A groups (B_n, C_n, D_n, exceptional types), the Pieri rules have different combinatorics. The single-predecessor property may not hold for any fundamental representation, requiring new proof strategies.

3. **Tropical Hecke Algebra Structure:** Our finite presentation gives a "generators and relations" description. Can we use this to compute the tropical Hecke algebra multiplication table efficiently? This would have applications to p-adic representation theory.

4. **q-Deformation:** Our results are in the tropical limit (q → 0 or q → ∞). Can we lift the finite presentation to the q-deformed setting, obtaining a finite presentation of the classical Hecke algebra?

5. **Algorithmic Applications:** The explicit reconstruction formula f(a,b) = c₂(a, b+1) is computationally trivial. For higher rank, the recovery algorithm would be more complex — essentially solving a tropical optimization problem on antidiagonals.

## 7. Formal Verification Details

The Lean 4 formalization is in `Tropical/GL3Presentation/Basic.lean` and consists of approximately 480 lines. Key design decisions:

- **Noncomputable section**: All definitions are marked noncomputable since ℝ in Mathlib is defined via Cauchy sequences and doesn't have decidable operations.
- **Top-level pattern matching**: The Pieri operators use top-level `match` patterns, which allows `rfl` proofs for the reduction lemmas.
- **Structure for compatibility**: The `Compatible` structure has 8 fields, each corresponding to a specific local condition. This makes the realization proof modular.
- **Abstract framework**: The `TriangularRecovery` predicate is parameterized by arbitrary operators, making it reusable for higher-rank generalizations.

The proof of the main equivalence theorem uses `Equiv.ofBijective`, constructing the bijection from the injective-surjective factorization.

## 8. Applications

### 8.1 Tropical Optimization

The finite presentation gives a way to check feasibility of tropical linear programs on the GL₃ weight lattice: instead of optimizing over all functions, one can optimize over compatible observable packages, which live in a finite-dimensional space with explicit linear constraints.

### 8.2 Representation-Theoretic Computations

The observable package provides a compressed representation of tropical Hecke functions. For support level N, a function has (N+1)(N+2)/2 values, which is also the dimension of the compatible package space. The compatibility conditions provide a "checksum" that can be used to verify the correctness of computations.

### 8.3 Tropical Curve Counting

In tropical enumerative geometry, counts of tropical curves passing through given conditions are expressed as evaluations of tropical Hecke operators. Our finite presentation implies that these counts are determined by finitely many "edge evaluations" and can be checked for consistency using the tropical rhombus relations.

## References

1. D. Maclagan and B. Sturmfels, *Introduction to Tropical Geometry*, Graduate Studies in Mathematics, vol. 161, AMS, 2015.
2. M. Gross, *Tropical geometry and mirror symmetry*, CBMS Regional Conference Series in Mathematics, vol. 114, AMS, 2011.
3. M. Joswig, *Essentials of Tropical Combinatorics*, Graduate Studies in Mathematics, vol. 219, AMS, 2022.
4. The Mathlib Community, *Mathlib4: The Lean 4 mathematics library*, 2024. https://github.com/leanprover-community/mathlib4
