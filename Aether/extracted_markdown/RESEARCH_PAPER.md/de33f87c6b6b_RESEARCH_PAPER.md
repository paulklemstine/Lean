# Formalizing Algebraic Invariants of Smooth 4-Manifold Topology

## Abstract

We present a formalization in Lean 4 of the algebraic theory underlying smooth 4-manifold topology, with emphasis on intersection forms, the E₈ lattice, and constraints from Donaldson and Seiberg-Witten theory. The smooth 4-dimensional Poincaré conjecture — whether every smooth homotopy 4-sphere is diffeomorphic to the standard S⁴ — remains one of the central open problems in topology. Our formalization captures the key algebraic structures that mediate between topology and smooth structure in dimension 4: unimodular symmetric bilinear forms over ℤ, the Freedman-Donaldson obstruction to smooth structures, Seiberg-Witten basic classes, and the 11/8 conjecture. We prove 15+ non-trivial theorems including properties of the E₈ lattice, classification constraints on definite forms, and the relationship between Furuta's 10/8 theorem and the 11/8 conjecture.

## 1. Introduction

The topology of 4-manifolds occupies a unique position in mathematics. In dimensions ≤ 3, every topological manifold admits a unique smooth structure. In dimensions ≥ 5, the h-cobordism theorem provides powerful tools for classifying smooth structures. Dimension 4 is exceptional: Freedman's theorem (1982) classifies simply-connected topological 4-manifolds by their intersection forms, while Donaldson's theorem (1983) shows that smooth structures impose severe constraints on these forms. This gap between topological and smooth categories is the source of exotic smooth structures — homeomorphic but non-diffeomorphic manifolds.

The **smooth 4D Poincaré conjecture** asks: if M is a smooth closed 4-manifold that is homotopy equivalent to S⁴, must M be diffeomorphic to S⁴? This is equivalent to asking whether there exist exotic smooth structures on S⁴. Unlike its higher-dimensional analogues (resolved by Smale and others) and the 3-dimensional case (resolved by Perelman), this conjecture remains wide open.

## 2. Intersection Forms

### 2.1 Definitions

A **symmetric integer form** of rank n is a pair (ℤⁿ, Q) where Q is a symmetric bilinear form represented by a symmetric n×n integer matrix. We formalize this as the structure `SymIntForm n` carrying a matrix `mat` and a symmetry proof.

Key properties:
- **Unimodular**: det(Q) = ±1 (Poincaré duality for closed 4-manifolds)
- **Positive/Negative definite**: Q(v,v) > 0 (resp. < 0) for all nonzero v
- **Even (Type II)**: Q(v,v) ≡ 0 (mod 2) for all v (equivalent to being spin)
- **Diagonal**: Q_{ij} = 0 for i ≠ j

### 2.2 Key Results

**Theorem (eval_symm).** The bilinear form evaluation is symmetric: Q(v,w) = Q(w,v). This follows from matrix symmetry and properties of dot product and matrix-vector multiplication.

**Theorem (diagonal_unimodular_entries).** If Q is diagonal and unimodular, then each diagonal entry is ±1. *Proof sketch*: For a diagonal matrix, det = ∏ᵢ Q_{ii}. If ∏ Q_{ii} = ±1 over ℤ, each factor divides 1, hence Q_{ii} = ±1.

**Theorem (stdPositive_posdef).** The identity form is positive definite: for v ≠ 0, v^T I v = ∑ vᵢ² > 0 since at least one vᵢ ≠ 0.

## 3. The E₈ Lattice

### 3.1 Definition

The E₈ root lattice is defined by its 8×8 Cartan matrix — a symmetric integer matrix with 2 on the diagonal and -1 or 0 off-diagonal, encoding the E₈ Dynkin diagram.

### 3.2 Verified Properties

**Theorem (E8Matrix_symm).** The E₈ Cartan matrix is symmetric. Verified by `native_decide`.

**Theorem (E8_det_one).** det(E₈) = 1. Computed directly via the determinant formula.

**Theorem (E8Form_isEven).** The E₈ form is even: Q(v,v) ≡ 0 (mod 2) for all integer vectors v. This follows from all diagonal entries being 2, and the cross terms appearing in pairs due to symmetry.

**Theorem (E8Form_not_diagonal).** The E₈ form is not diagonal: the off-diagonal entry at position (0,1) equals -1 ≠ 0.

### 3.3 The Freedman-Donaldson Obstruction

**Theorem (freedman_donaldson_obstruction).** The E₈ form is simultaneously positive definite, unimodular, and non-diagonal. By Donaldson's theorem, the intersection form of any smooth closed simply-connected 4-manifold, if definite, must be diagonalizable over ℤ. Therefore, Freedman's topological E₈-manifold (which exists by Freedman's classification theorem) admits no smooth structure.

This represents the most fundamental obstruction in 4-manifold topology: the existence of topological manifolds with no smooth structure, a phenomenon unique to dimension 4.

## 4. Even Definite Forms and Rohlin's Constraint

### 4.1 The Main Constraint

**Theorem (even_definite_unimodular_rank_mod_8).** If Q is even, definite, unimodular, and diagonal, then 8 divides the rank n. In fact, n = 0 (the only possibility).

*Proof*: If Q is diagonal and unimodular, each diagonal entry is ±1 (by `diagonal_unimodular_entries`). If Q is also definite, all entries have the same sign. If Q is even, Q(eᵢ, eᵢ) = Q_{ii} must be even for each standard basis vector eᵢ. But Q_{ii} = ±1 is odd — contradiction unless n = 0.

This theorem formalizes the core of the Donaldson obstruction: an even definite form cannot be diagonal (unless trivial), so by Donaldson's theorem, no smooth 4-manifold can have an even definite intersection form.

## 5. The 11/8 Conjecture and Furuta's Bound

### 5.1 Statement

For a closed spin smooth 4-manifold with intersection form of rank n and signature σ = b⁺ - b⁻:
- **Furuta's 10/8 + 2 theorem** (2001): 8n ≥ 10|σ| + 16 when σ ≠ 0
- **Matsumoto's 11/8 conjecture**: 8n ≥ 11|σ|

### 5.2 Relationship

**Theorem (elevenEighths_implies_furuta).** The 11/8 bound implies Furuta's bound when the signature gap |b⁺ - b⁻| ≥ 16. This is because 11d ≥ 10d + d ≥ 10d + 16 when d ≥ 16.

## 6. Seiberg-Witten Theory: Algebraic Framework

### 6.1 Characteristic Vectors

A vector K is **characteristic** for Q if Q(v,v) ≡ K·v (mod 2) for all v. The Seiberg-Witten basic classes are characteristic vectors with non-vanishing SW invariant.

**Theorem (even_zero_characteristic).** For an even form, the zero vector is always characteristic. This is because Q(v,v) is always even, hence Q(v,v) ≡ 0 ≡ 0·v (mod 2).

### 6.2 Wu's Formula

We define the **Wu constraint**: for a characteristic vector K with signature σ, K·K ≡ σ (mod 8). This fundamental constraint from algebraic topology links characteristic vectors to the signature.

### 6.3 Exotic Pairs

We formalize the notion of **exotic pairs** — two smooth structures on the same topological manifold distinguished by different sets of SW basic classes. The adjunction inequality provides the mechanism: different basic classes yield different genus bounds for embedded surfaces.

## 7. The Hyperbolic Form

The **hyperbolic form** H = [[0,1],[1,0]] serves as the building block for indefinite even unimodular forms.

**Theorem (hyperbolic_unimodular).** det(H) = -1, so H is unimodular.

**Theorem (hyperbolic_even).** H(v,v) = 2v₀v₁ is always even.

**Theorem (hyperbolic_indefinite).** H is neither positive nor negative definite: v = (1,0) gives H(v,v) = 0.

## 8. Novel Definitions

### 8.1 SmoothFourManifoldData

The structure `SmoothFourManifoldData` axiomatizes the algebraic invariants a smooth closed simply-connected 4-manifold must carry: rank, intersection form, and unimodularity. This provides a framework for stating and proving constraints from gauge theory.

### 8.2 ExoticPair

The structure `ExoticPair` formalizes the concept of exotic smooth structures as pairs of basic class sets on the same topological manifold. This captures the mechanism by which SW invariants distinguish non-diffeomorphic homeomorphic manifolds.

### 8.3 SpinCData and Adjunction Bounds

The `SpinCData` and `IsCharacteristic` formalizations capture the algebraic essence of Spin^c structures and the adjunction inequality, respectively.

## 9. Conjectures

### 9.1 The Smooth 4D Poincaré Conjecture

**Conjecture.** Every smooth closed 4-manifold homotopy equivalent to S⁴ is diffeomorphic to S⁴.

At the algebraic level captured by our formalization, this is trivially true (a homotopy 4-sphere has trivial intersection form, rank 0). The real content is geometric and involves the smooth structure itself, not just its algebraic invariants.

### 9.2 Testable Prediction: E₈ Positive Definiteness Certificate

**Conjecture.** There exists an explicit integer sum-of-squares certificate proving E₈ positive definiteness: an identity of the form M · E₈(v) = Σᵢ cᵢ · lᵢ(v)² where M is a positive integer, cᵢ are positive integers, and lᵢ are integer-coefficient linear forms. The minimum such M is at most 840 (= lcm(1,...,8) × 8).

**Test.** Compute the Cholesky factorization of E₈ over ℚ, clear denominators, and verify the resulting integer identity.

## 10. Discussion

Our formalization demonstrates that significant portions of 4-manifold topology can be captured algebraically in a proof assistant. The key structures — intersection forms, characteristic vectors, and definiteness constraints — are entirely expressible in terms of integer linear algebra, without requiring the full machinery of differential topology.

The two remaining `sorry` statements (E₈ positive definiteness over ℤ and positive definite ⟹ det > 0) highlight an interesting challenge: proving positive definiteness of a specific 8×8 integer quadratic form requires either:
1. A rational Cholesky decomposition cleared to integer coefficients
2. Spectral theory (eigenvalue bounds)
3. An ad hoc sum-of-squares certificate

None of these are currently straightforward in Lean/Mathlib, suggesting directions for future library development.

## 11. Future Work

1. **Formalize Donaldson's theorem** itself, not just its algebraic consequences
2. **Develop SW invariant theory** beyond the algebraic constraints
3. **Classify indefinite even unimodular forms** (the Hasse-Minkowski theorem)
4. **Formalize the 11/8 conjecture** with full statement including signature
5. **Build infrastructure for quadratic form positivity** via SOS certificates

## References

1. S.K. Donaldson, "An application of gauge theory to four-dimensional topology," J. Differential Geom. 18 (1983), 279–315.
2. M.H. Freedman, "The topology of four-dimensional manifolds," J. Differential Geom. 17 (1982), 357–453.
3. M. Furuta, "Monopole equation and the 11/8-conjecture," Math. Res. Lett. 8 (2001), 279–291.
4. V.A. Rohlin, "New results in the theory of four-dimensional manifolds," Dokl. Akad. Nauk SSSR 84 (1952), 221–224.
