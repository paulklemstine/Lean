# Future Directions: Tropical Matrix Algebra

## 1. Tropical Eigenvalue Theory and the Critical Graph

The tropical eigenvalue of a matrix A is defined as λ* = min_σ (1/n) ∑ᵢ A(i, σ(i)) where the minimum is taken over cyclic permutations. Equivalently, it is the minimum mean cycle weight in the associated weighted digraph. The critical graph — the subgraph of edges participating in minimum-mean cycles — determines the structure of tropical eigenvectors.

**Conjecture**: For a generic n×n tropical matrix (entries drawn independently from a continuous distribution), the critical graph is almost surely a union of disjoint cycles covering exactly ⌊n/2⌋ + 1 vertices, and the dimension of the tropical eigenspace equals the number of connected components of the critical graph.

The key insight is that the critical graph's structure is governed by the same combinatorial optimization as `tropDet`, and our submultiplicativity theorem `tropDet_submul` should extend to a spectral radius inequality: the tropical spectral radius of A⊗B is bounded by the sum of the individual spectral radii.

**Why now?** Our formalization of `tropDet` and `permSum` provides the exact infrastructure needed — extending from permutations to cyclic permutations and normalizing by cycle length is a natural next step. The `permSum_tropMatMul_le` lemma's proof technique (reindexing over permutation composition) directly generalizes to cycle decompositions.

## 2. Tropical Rank and the Barvinok Conjecture

The tropical rank of a matrix A is the smallest r such that A can be written as a tropical sum (pointwise min) of r tropical rank-1 matrices, where a tropical rank-1 matrix has the form (i,j) ↦ uᵢ + vⱼ. This is fundamentally different from the Kapranov rank (defined via tropicalization of classical rank).

**Conjecture**: For n×n matrices over WithTop ℕ, the tropical rank r satisfies tropDet(A) ≥ ∑ᵢ min_j A(i,j) with equality if and only if r = 1. More precisely, the gap tropDet(A) - ∑ᵢ min_j A(i,j) (our Hadamard gap) is a monotone function of the tropical rank: it is zero for rank 1 and strictly increases with rank up to a computable bound depending on n.

The key insight is that our `tropDet_hadamard` theorem characterizes exactly when the LP relaxation of the assignment problem is tight, and this tightness condition is equivalent to the tropical matrix having rank 1 — connecting our optimization-theoretic results to algebraic structure.

**Why now?** The Hadamard bound formalized in `tropDet_hadamard` is the starting point. Characterizing when equality holds requires analyzing the structure of optimal permutations, which our `permSum` infrastructure supports directly.

## 3. Tropical Permanent vs. Tropical Determinant: The Sign Problem

In classical linear algebra, det and perm differ by signs. In tropical algebra, there is no subtraction, so the tropical determinant equals the tropical permanent. However, one can define a "signed tropical determinant" using the theory of hyperfields or supertropical algebra, where elements carry a "ghost" sign.

**Conjecture**: Over the supertropical semiring (where each element carries a "ghost" layer recording sign cancellations), the signed tropical determinant satisfies a strict multiplicativity: sdet(A⊗B) = sdet(A) + sdet(B), upgrading our inequality `tropDet_submul` to an equality. This would be the tropical analogue of det(AB) = det(A)·det(B).

The key insight is that the inequality in `tropDet_submul` becomes an equality precisely when the optimal permutations for A and B "compose cleanly" — the supertropical ghost layer tracks exactly when this composition fails, and its vanishing is equivalent to the inequality being strict.

**Why now?** Our proof of `tropDet_submul` explicitly constructs the witness permutations (via `permSum_tropMatMul_le`), making the gap between the two sides computable. Formalizing the supertropical semiring and tracking when equality holds is a direct extension.

## 4. Tropical Convexity and the Assignment Polytope

The classical Birkhoff polytope — the set of doubly stochastic matrices — is intimately connected to the assignment problem. Its tropical analogue, the tropical Birkhoff polytope, should be the set of matrices A with tropDet(A) = 0 and all entries ≥ 0.

**Conjecture**: The tropical Birkhoff polytope (matrices A with entries in WithTop ℕ, tropDet(A) = 0, and A(i,j) ≥ 0) is tropically convex and has exactly n! tropical vertices, one for each permutation matrix. Moreover, the `tropDet_row_col_perm` invariance extends to a full tropical Sₙ × Sₙ symmetry group acting on this polytope.

The key insight is that `tropDet_zero_diag_eq_zero` already shows that matrices with zero diagonal are in this polytope, and `tropDet_row_col_perm` gives the symmetry group action. The tropical convexity (closure under tropical linear combinations) should follow from submultiplicativity.

**Why now?** All the ingredients are formalized: `tropDet`, `tropIdentity`, `tropDet_identity`, and `tropDet_row_col_perm`. Defining tropical convex combinations and proving closure is the natural next step.

## 5. Correspondence Theorem: Tropical Curves and Classical Enumerative Geometry

Mikhalkin's correspondence theorem states that the count of tropical curves through generic points in ℝ² (with appropriate multiplicities) equals the count of classical algebraic curves through corresponding points in ℂ². The multiplicities are computed from the Newton polygon subdivision — dual to the tropical curve's combinatorial type.

**Conjecture**: The tropical determinant `tropDet` of the "evaluation matrix" E(i,j) = (tropical distance from the i-th marked point to the j-th edge of the tropical curve) computes the Mikhalkin multiplicity of the tropical curve. More precisely, for a tropical curve Γ of genus 0 with n marked points, the Mikhalkin multiplicity equals a product of local `tropDet` contributions from each vertex of Γ.

The key insight is that `tropDet` is the optimal assignment value, and Mikhalkin's multiplicity involves a product of absolute values of 2×2 determinants at each vertex — these are exactly `tropDet` applied to the local edge direction matrix at each trivalent vertex.

**Why now?** This directly connects our tropical matrix algebra to the broader tropical enumerative geometry program. With `tropDet` formalized and its properties established, formalizing Mikhalkin's formula becomes tractable — start with the genus-0, degree-d case in ℝ² where the tropical curves are trees and the combinatorics is cleanest.
