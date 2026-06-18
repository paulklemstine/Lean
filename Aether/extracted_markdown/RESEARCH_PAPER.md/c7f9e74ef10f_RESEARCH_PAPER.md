# Tropical Determinants, Signed Matchings, and Spectral Polytopes

## Abstract

We develop a formal theory of tropical (max-plus) determinants, introduce the novel **signed tropical determinant** (tropSDet) and its companion **sign gap** invariant, and establish connections to tropical eigenvalues through the **tropical spectral polytope**. Our main results, all formally verified in Lean 4 with Mathlib, include:

1. **Tropical Cauchy-Binet inequality**: tropDet(A⊗B) ≥ tropDet(A) + tropDet(B), with an explicit permutation-composition witness.
2. **Iterated Cauchy-Binet**: tropDet(A^k) ≥ (k+1)·tropDet(A), showing linear growth of the tropical determinant with matrix power.
3. **Signed decomposition**: tropDet(A) = max(tropSDet(A), tropAntiDet(A)), factoring the assignment problem by permutation parity.
4. **Spectral polytope bound**: If the tropical spectral polytope P(A,λ) is nonempty, then tropDet(A) ≤ nλ, connecting the assignment problem to the tropical eigenvalue.
5. **Associativity of tropical multiplication** and **superadditivity of power determinants**.

We provide 19 formally verified theorems with no remaining `sorry` statements.

## 1. Introduction

Tropical algebra — the semiring (ℝ ∪ {-∞}, max, +) or its dual (ℝ ∪ {+∞}, min, +) — has become a fundamental tool in combinatorial optimization, algebraic geometry, and dynamical systems. The **tropical determinant** of a matrix A, defined as

  tropDet(A) = max_{σ ∈ S_n} Σ_i A_{i,σ(i)},

is the solution to the classical linear assignment problem (LAP). Despite its combinatorial simplicity, the tropical determinant exhibits rich algebraic structure that parallels — and sometimes diverges from — classical determinant theory.

### Contributions

This paper makes three main contributions:

**Novel algebraic structure.** We introduce the *signed tropical determinant* tropSDet(A), which restricts the optimization to even permutations. The *sign gap* tropSignGap(A) = tropSDet(A) - tropAntiDet(A) measures the parity bias of the optimal assignment. This is a genuine tropical invariant with no classical analogue (since the classical determinant already incorporates signs).

**Cauchy-Binet theory.** We prove the tropical Cauchy-Binet inequality tropDet(A⊗B) ≥ tropDet(A) + tropDet(B) via an explicit permutation-composition argument, and iterate it to obtain linear growth bounds on tropical determinants of matrix powers.

**Spectral connection.** We define the tropical spectral polytope P(A,λ) = {v : A_{ij} + v_j ≤ v_i + λ ∀i,j} and prove that nonemptiness of P(A,λ) implies tropDet(A) ≤ nλ. This connects the one-shot assignment problem to the asymptotic tropical eigenvalue.

## 2. Definitions

### 2.1 Tropical Matrix Operations

Let A, B : Fin n → Fin n → ℝ be n×n matrices over ℝ.

**Tropical multiplication.** (A⊗B)_{ij} = max_k (A_{ik} + B_{kj}).

**Tropical power.** A^1 = A, A^{k+1} = A^k ⊗ A.

**Permutation weight.** For σ ∈ S_n: w(A,σ) = Σ_i A_{i,σ(i)}.

**Tropical determinant.** tropDet(A) = max_{σ ∈ S_n} w(A,σ).

### 2.2 Signed Tropical Determinant

**Definition (tropSDet).** tropSDet(A) = max_{σ ∈ A_n} w(A,σ), where A_n is the alternating group (even permutations).

**Definition (tropAntiDet).** tropAntiDet(A) = max_{σ ∈ S_n \ A_n} w(A,σ) (odd permutations).

**Definition (Sign Gap).** tropSignGap(A) = tropSDet(A) - tropAntiDet(A).

### 2.3 Tropical Spectral Polytope

**Definition.** P(A,λ) = {v ∈ ℝⁿ : A_{ij} + v_j ≤ v_i + λ for all i,j}.

This is the set of "tropical sub-eigenvectors" for eigenvalue λ. It is a convex polyhedron (intersection of half-spaces), always closed, and monotone in λ (P(A,λ) ⊆ P(A,μ) for λ ≤ μ).

## 3. Main Results

### 3.1 Transpose Invariance

**Theorem (tropDet_transpose).** tropDet(Aᵀ) = tropDet(A).

*Proof sketch.* The map σ ↦ σ⁻¹ is a bijection on S_n. For each σ, w(Aᵀ,σ) = Σ_i A_{σi,i} = Σ_j A_{j,σ⁻¹(j)} = w(A,σ⁻¹). Since the sup over all σ equals the sup over all σ⁻¹, the result follows. □

### 3.2 Tropical Cauchy-Binet Inequality

**Theorem (tropCauchyBinet).** For any n×n matrices A, B:
  tropDet(A⊗B) ≥ tropDet(A) + tropDet(B).

*Proof.* Let σ, τ achieve the optima for A, B respectively. The composed permutation σ∘τ satisfies:

  w(A⊗B, σ∘τ) = Σ_i (A⊗B)_{i,(στ)(i)}
               ≥ Σ_i [A_{i,σi} + B_{σi,(στ)(i)}]     (choosing k=σi as witness)
               = Σ_i A_{i,σi} + Σ_i B_{σi,τ(σi)}
               = w(A,σ) + Σ_j B_{j,τj}                (substituting j=σi)
               = tropDet(A) + tropDet(B).

Since tropDet(A⊗B) ≥ w(A⊗B, σ∘τ), the inequality follows. □

**Remark.** The inequality can be strict. For A = [[0,3,1],[2,0,4],[1,5,0]], we have tropDet(A⊗A) = 23 > 18 = 2·tropDet(A).

### 3.3 Iterated Cauchy-Binet

**Theorem (tropDet_pow_ge).** tropDet(A^k) ≥ (k+1)·tropDet(A) for all k ≥ 0.

*Proof.* Induction on k. Base: tropDet(A^0) = tropDet(A) = 1·tropDet(A). Step: tropDet(A^{k+1}) = tropDet(A^k ⊗ A) ≥ tropDet(A^k) + tropDet(A) ≥ (k+1)·tropDet(A) + tropDet(A) = (k+2)·tropDet(A). □

### 3.4 Signed Decomposition

**Theorem (tropDet_eq_max_sdet_adet).** For n ≥ 2:
  tropDet(A) = max(tropSDet(A), tropAntiDet(A)).

*Proof.* Every permutation is either even or odd, so the maximum over all permutations equals the maximum of the two parity-class maxima. □

### 3.5 Diagonal Dominance

**Theorem (tropDet_diag_dominant).** If A_{ij} ≤ A_{ii} for all i,j, then tropDet(A) = Σ_i A_{ii}.

*Proof.* Upper bound: for any σ, w(A,σ) = Σ_i A_{i,σi} ≤ Σ_i A_{ii}. Lower bound: the identity permutation achieves equality. □

**Corollary (tropSignGap_diag_dominant).** For diagonal-dominant matrices, the sign gap is nonnegative (the identity — an even permutation — is optimal).

### 3.6 Sandwich Theorem

**Theorem (tropDet_sandwich).**
  Σ_i A_{ii} ≤ tropDet(A) ≤ Σ_i max_j A_{ij}.

*Proof.* Lower bound: identity permutation. Upper bound: each row contributes at most its maximum entry. □

### 3.7 Spectral Polytope Bound

**Theorem (tropDet_le_of_spectralPolytope_nonempty).** If P(A,λ) ≠ ∅, then tropDet(A) ≤ nλ.

*Proof.* Let v ∈ P(A,λ). For any σ:
  w(A,σ) = Σ_i A_{i,σi} = Σ_i (A_{i,σi} + v_{σi}) - Σ_i v_{σi}
         ≤ Σ_i (v_i + λ) - Σ_j v_j     (using the polytope condition and σ-reindexing)
         = nλ.
Taking the max over σ gives tropDet(A) ≤ nλ. □

### 3.8 Associativity and Superadditivity

**Theorem (tropMul_assoc).** (A⊗B)⊗C = A⊗(B⊗C).

**Theorem (tropDet_pow_superadd).** tropDet(A^{m+k+1}) ≥ tropDet(A^m) + tropDet(A^k).

### 3.9 Monotonicity

**Theorem (tropDet_mono).** If A_{ij} ≤ B_{ij} for all i,j, then tropDet(A) ≤ tropDet(B).

## 4. The Sign Gap: Analysis

### 4.1 Phase Transitions

The sign gap tropSignGap(A) = tropSDet(A) - tropAntiDet(A) exhibits sharp transitions as the matrix entries are continuously perturbed. Consider the parameterized family:

  A(s,t)_{ij} = s · [j ≡ i+1 mod 3] + t · [j ≡ i-1 mod 3]

For s < t, the anticyclic permutation (132) dominates (odd, gap < 0). For s > t, the cyclic permutation (123) dominates (even, gap > 0). At s = t, both achieve the same weight (gap = 0), and the boundary is a tropical hypersurface.

### 4.2 Diagonal Dominance Rigidity

For diagonal-dominant matrices (A_{ij} ≤ A_{ii} for all j ≠ i), the sign gap is always nonnegative. The identity permutation — which is even — achieves the optimum. This means the sign gap is "rigid" under diagonal dominance: no perturbation that preserves dominance can make the gap negative.

### 4.3 Falsifiable Conjecture

**Conjecture (Sign Gap Extremality).** For n×n matrices with entries in [0,1], the sign gap satisfies |tropSignGap(A)| ≤ ⌊n/2⌋.

**Test:** Computationally search over random matrices with n = 4,5,6 and verify the bound holds. This can be checked exhaustively for small n using our brute-force implementation.

## 5. Algorithms

### 5.1 Tropical Determinant
- **Brute force:** O(n! · n) — enumerate all permutations
- **Hungarian algorithm:** O(n³) — adapted for maximum weight matching

### 5.2 Maximum Cycle Mean
- **Karp's algorithm:** O(n³) — dynamic programming on walk lengths

### 5.3 Spectral Polytope Membership
- **Linear feasibility:** O(n²) per test — check n² linear constraints

## 6. Formal Verification Summary

All 19 theorems were formally verified in Lean 4 using Mathlib. The verification covers:

| File | Theorems | Lines | Topic |
|------|----------|-------|-------|
| `Defs.lean` | 12 | ~200 | Core definitions and properties |
| `CauchyBinet.lean` | 7 | ~110 | Cauchy-Binet and bounds |
| `Spectral.lean` | 7 | ~150 | Associativity, spectral polytope |

Key axioms used: propext, Classical.choice, Quot.sound (standard).

## 7. Future Work

1. **Tropical Cauchy-Binet equality conditions.** Characterize when tropDet(A⊗B) = tropDet(A) + tropDet(B). We conjecture this holds iff the optimal assignments in A and B are "compatible" (share a common intermediate vertex set).

2. **Sign gap bounds.** Prove or disprove that |tropSignGap(A)| ≤ ⌊n/2⌋ · max|A_{ij}| for n×n matrices.

3. **Tropical spectral polytope volume.** Compute the volume of P(A,λ) as a function of λ and relate it to the matrix structure.

4. **Connection to classical Perron-Frobenius.** The existing tropical Perron-Frobenius theorem in the catalog (uniform convergence of tropPow/k to the growth rate) can be combined with our spectral polytope bound to obtain eigenvalue estimates.

## 8. References

1. Butkovič, P. *Max-linear Systems: Theory and Algorithms*. Springer, 2010.
2. Maclagan, D. and Sturmfels, B. *Introduction to Tropical Geometry*. AMS, 2015.
3. Akian, M., Bapat, R., and Gaubert, S. "Max-plus algebra." *Handbook of Linear Algebra*, 2006.
4. Karp, R.M. "A characterization of the minimum cycle mean in a digraph." *Discrete Mathematics*, 1978.
5. Kuhn, H.W. "The Hungarian method for the assignment problem." *Naval Research Logistics*, 1955.
