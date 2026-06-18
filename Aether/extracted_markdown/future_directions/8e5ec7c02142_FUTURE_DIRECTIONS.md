# Future Directions: Hodge Structure Theory in Lean 4

## 1. Hodge Filtration and Degeneration of the Hodge-to-de Rham Spectral Sequence

The Hodge filtration F^p on the complexification of a pure Hodge structure is the decreasing filtration defined by F^p = ⊕_{i≥p} H^{i,k-i}. A natural next step is to formalize the Hodge filtration as a `Submodule` tower and prove that the filtration determines the decomposition when the "opposition" condition F^p ⊕ F̄^{k-p+1} = V_ℂ holds. This would give the first formalized proof that the Hodge filtration is a complete invariant of a pure Hodge structure.

The key insight is that the Hodge filtration and its conjugate together reconstruct the bigrading — this is the essence of the "opposition" or "Hodge symmetry" condition, and formalizing it would connect the linear-algebraic theory to the geometric fact that the Hodge-to-de Rham spectral sequence degenerates at E₁ for compact Kähler manifolds.

Why now? The `HodgeDiamond` structure and `PureHodgeStructure` definitions are in place, and Mathlib's lattice theory on `Submodule` provides all the infrastructure needed for decreasing filtrations. The main challenge is managing the interplay between ℂ-subspaces and complex conjugation, which can be modeled via an involution on the ambient module.

## 2. Künneth Formula for Hodge Diamonds and Product Stability of the Hodge Conjecture

For compact Kähler manifolds X and Y, the Hodge numbers of the product satisfy h^{p,q}(X × Y) = Σ_{a+c=p, b+d=q} h^{a,b}(X) · h^{c,d}(Y). This "convolution" formula on Hodge diamonds should be formalizable as an operation `HodgeDiamond n → HodgeDiamond m → HodgeDiamond (n + m)` with a proof that the product Hodge diamond satisfies Hodge symmetry and Serre duality.

The key insight is that the product formula, combined with our existing `DirectSumHodgeData`, would give a complete proof that if the Hodge conjecture holds for X and Y separately, then it holds for product-type classes on X × Y. This is the content of the "Künneth component" of the Hodge conjecture, which reduces the general case to "primitive" classes.

Why now? The `HodgeDiamond` and `DirectSumHodgeData` structures are defined and the projective space example provides a test case: ℙⁿ × ℙᵐ should give the Segre variety's Hodge diamond, which can be verified computationally.

## 3. Lefschetz (1,1) Theorem: From Abstract to Geometric

Our `hodgeClasses_eq_top_of_vanishing` proves the Hodge conjecture when H^{2,0} = 0. The natural strengthening is the full Lefschetz (1,1) theorem: every rational (1,1)-class on a smooth projective variety is algebraic. This requires connecting the abstract Hodge structure framework to the Chern class map c₁ : Pic(X) → H²(X, ℤ) ∩ H^{1,1}(X).

The key insight is that the proof reduces to the exponential exact sequence 0 → ℤ → 𝒪 → 𝒪* → 0 and the vanishing of H²(X, 𝒪) → H²(X, ℤ) for (1,1)-classes. Formalizing this requires sheaf cohomology on a site, which Mathlib is beginning to support via `CategoryTheory.Sheaf`.

Why now? Mathlib's category theory library now has sites, sheaves, and derived functors in a usable state. The exponential sequence is a short exact sequence of sheaves, and the connecting homomorphism gives the Chern class. This would be the first formalized proof of Lefschetz (1,1) in any proof assistant.

## 4. Hodge Index Theorem for Surfaces and Signature of the Intersection Form

For a compact complex surface, the Hodge index theorem states that the intersection form on H^{1,1}(X, ℝ) has signature (1, h^{1,1} - 1) — exactly one positive eigenvalue, given by the Kähler class. Our `PolarizedHodgeStructure` already carries a nondegenerate bilinear form Q; the next step is to formalize the signature constraint.

The key insight is that the Hodge index theorem is equivalent to the Cauchy-Schwarz inequality for the intersection form restricted to H^{1,1} ∩ H²(X, ℝ). This can be formalized as: the quadratic form Q restricted to the orthogonal complement of the Kähler class is negative definite.

Why now? Mathlib has `LinearMap.BilinForm`, `Finrank`, and the spectral theory infrastructure for proving signature results via Sylvester's law of inertia. The `hodgeClasses_isCompl_orthogonal` theorem already proves the algebraic-transcendental decomposition, providing the starting point for a signature analysis.

## 5. Mumford-Tate Groups and the Hodge Conjecture for Abelian Varieties

The Mumford-Tate group of a Hodge structure is the smallest algebraic subgroup of GL(V) whose real points contain the image of the Hodge circle homomorphism. For abelian varieties, the Hodge conjecture is equivalent to the statement that the Mumford-Tate group determines all Hodge classes (via the Tannakian formalism). Formalizing Mumford-Tate groups would open the path to the known cases of the Hodge conjecture: CM abelian varieties, abelian varieties of dimension ≤ 3, and products of elliptic curves.

The key insight is that the Mumford-Tate group can be defined purely algebraically from the Hodge structure, without reference to the underlying geometry, as the stabilizer of all Hodge tensors in the tensor algebra of V. This makes it amenable to formalization using Mathlib's algebraic group and representation theory.

Why now? The weight-2 Hodge structure and polarization infrastructure are in place. Mathlib's `AlgebraicGroup` and `RepresentationTheory` modules provide the substrate. The CM case is particularly tractable because the Mumford-Tate group is a torus, reducing the Hodge conjecture to a computation with characters.
