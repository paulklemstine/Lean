# Tropical-Transport Bridge: Formally Verified Connections Between Optimal Transport and Min-Plus Algebra

## Abstract

We establish formally verified connections between discrete optimal transport theory and tropical (min-plus) matrix algebra. Our main results are:
(1) the Wasserstein-1 distance on finite probability vectors is invariant under cost-preserving bijections;
(2) diagonal entries of tropical matrix powers satisfy a subadditive inequality, providing the foundation for tropical spectral theory;
(3) permutation couplings between uniform distributions have assignment costs invariant under conjugation by cost-preserving bijections.
All proofs are fully mechanized in Lean 4 with the Mathlib library, yielding the highest possible confidence in correctness. We develop supporting infrastructure including tropical matrix associativity, power splitting, monotonicity, and scalar shift theorems. These results create a rigorous bridge between transport-theoretic optimization and tropical algebraic structure, with applications to equivariant transport, shortest-path algorithms, and combinatorial optimization.

**Keywords:** optimal transport, Wasserstein distance, tropical algebra, min-plus matrix multiplication, formal verification, subadditivity, equivariance

---

## 1. Introduction

### 1.1 Motivation

Optimal transport theory, initiated by Monge (1781) and Kantorovich (1942), studies the problem of moving mass from one distribution to another at minimum cost. Tropical (min-plus) algebra, with roots in automata theory (Simon, 1978) and algebraic geometry (Viro, 2001), replaces the usual arithmetic operations with (min, +), creating an idempotent semiring structure that naturally encodes optimization.

Despite their independent development, both theories share a fundamental feature: they optimize costs over combinatorial structures (couplings, paths, cycles) and respect symmetries of the underlying cost/weight function. This paper makes this connection rigorous and machine-verified.

### 1.2 Contributions

Our contributions are organized into three interconnected thrusts:

**A. Wasserstein Invariance (Objective A).** We formalize the discrete Wasserstein-1 distance on `Fin n → ℝ` probability vectors and prove its invariance under cost-preserving bijections. The proof constructs an explicit bijection on transport plans via reindexing and shows cost preservation.

**B. Tropical Spectral Foundation (Objective B).** We define min-plus matrix multiplication and tropical powers, prove associativity and power splitting, and establish the subadditivity of diagonal entries: `(A^⊗(m+k+2))_{ii} ≤ (A^⊗(m+1))_{ii} + (A^⊗(k+1))_{ii}`. We also prove monotonicity, symmetry preservation, scalar shift properties, and a minimum-diagonal bound.

**C. Transport-Tropical Bridge (Objective C).** We prove that permutation couplings are valid transport plans between uniform distributions and that their assignment costs are invariant under conjugation by cost-preserving bijections. This connects transport-theoretic symmetry to tropical/combinatorial optimization.

### 1.3 Related Work

Formal verification of optimal transport in proof assistants is extremely rare. To our knowledge, this is the first mechanized proof of Wasserstein invariance under isometries. Previous formalizations of tropical algebra in Lean/Mathlib have focused on the `Tropical` type and basic semiring structure; our work extends this to matrix powers and spectral-theoretic results.

The mathematical content draws on classical results: Wasserstein distances (Villani, 2003, 2009), tropical matrix theory (Butkovič, 2010), assignment problem theory (Kuhn, 1955), and Karp's cycle-mean theorem (Karp, 1978).

---

## 2. Definitions and Notation

### 2.1 Probability Vectors and Transport Plans

**Definition 2.1** (Probability Vector). For n ∈ ℕ, a function μ : Fin n → ℝ is a probability vector if:
- μ(i) ≥ 0 for all i, and
- Σᵢ μ(i) = 1.

```lean
def IsProbVec (μ : Fin n → ℝ) : Prop :=
  (∀ i, 0 ≤ μ i) ∧ (∑ i, μ i = 1)
```

**Definition 2.2** (Transport Plan). A transport plan from μ to ν is a function π : Fin n → Fin n → ℝ satisfying:
- π(i,j) ≥ 0 for all i,j
- Σⱼ π(i,j) = μ(i) for all i (row marginal)
- Σᵢ π(i,j) = ν(j) for all j (column marginal)

```lean
def transportPlans (μ ν : Fin n → ℝ) : Set (Fin n → Fin n → ℝ) :=
  {π | (∀ i j, 0 ≤ π i j) ∧
       (∀ i, ∑ j, π i j = μ i) ∧
       (∀ j, ∑ i, π i j = ν j)}
```

**Definition 2.3** (Wasserstein-1 Distance).
```
W_c(μ, ν) = inf { Σᵢⱼ π(i,j)·c(i,j) : π ∈ Π(μ,ν) }
```

### 2.2 Tropical Matrix Algebra

**Definition 2.4** (Tropical Multiplication).
```
(A ⊗ B)ᵢⱼ = ⨅ₖ (Aᵢₖ + Bₖⱼ)
```

**Definition 2.5** (Tropical Power). We use 0-indexed powers where `tropPow A m` represents A^⊗(m+1):
```
tropPow A 0 = A
tropPow A (m+1) = tropMul (tropPow A m) A
```

This avoids the need for a tropical identity matrix (which requires +∞ off-diagonal entries) while capturing all essential properties.

### 2.3 Pushforward and Reindexing

**Definition 2.6** (Pushforward). For e : Fin n ≃ Fin n:
```
(e_*μ)(i) = μ(e⁻¹(i))
```

**Definition 2.7** (Plan Reindexing).
```
(reindex_e π)(i,j) = π(e⁻¹(i), e⁻¹(j))
```

---

## 3. Main Results

### 3.1 Wasserstein Invariance under Cost-Preserving Bijections

**Theorem 3.1** (Wasserstein Invariance). Let c : Fin n → Fin n → ℝ be a cost function, μ, ν probability vectors, and e : Fin n ≃ Fin n a bijection satisfying c(e(i), e(j)) = c(i,j) for all i,j. Then:
```
W_c(e_*μ, e_*ν) = W_c(μ, ν)
```

*Proof sketch.* The proof proceeds in three steps:

**Step 1: Reindexing preserves admissibility.** We show that if π ∈ Π(μ,ν), then reindex_e(π) ∈ Π(e_*μ, e_*ν). This requires verifying three properties:
- Nonnegativity: reindex_e(π)(i,j) = π(e⁻¹(i), e⁻¹(j)) ≥ 0 since π ≥ 0.
- Row marginals: Σⱼ reindex_e(π)(i,j) = Σⱼ π(e⁻¹(i), e⁻¹(j)) = Σⱼ π(e⁻¹(i), j) = μ(e⁻¹(i)) = (e_*μ)(i), using the bijective change of variables j ↦ e(j).
- Column marginals: analogous.

**Step 2: Reindexing is a bijection.** We show reindex_e is a bijection on transport plans by exhibiting reindex_{e⁻¹} as a two-sided inverse: reindex_{e⁻¹}(reindex_e(π)) = π.

**Step 3: Cost preservation.** For any π ∈ Π(μ,ν):
```
Σᵢⱼ reindex_e(π)(i,j)·c(i,j) = Σᵢⱼ π(e⁻¹(i), e⁻¹(j))·c(i,j)
                                = Σᵢⱼ π(i,j)·c(e(i), e(j))    [change of variables]
                                = Σᵢⱼ π(i,j)·c(i,j)            [cost invariance]
```

Since the image of Π(μ,ν) under reindexing equals Π(e_*μ, e_*ν) (Step 2), and each plan's cost is preserved (Step 3), the infima coincide. □

### 3.2 Tropical Power Diagonal Subadditivity

**Theorem 3.2** (Diagonal Subadditivity). For any A : Matrix (Fin n) (Fin n) ℝ and i : Fin n:
```
(A^⊗(m+k+2))ᵢᵢ ≤ (A^⊗(m+1))ᵢᵢ + (A^⊗(k+1))ᵢᵢ
```

*Proof sketch.* This requires two lemmas:

**Lemma 3.3** (Diagonal Bound). (A ⊗ B)ᵢᵢ ≤ Aᵢᵢ + Bᵢᵢ.
*Proof.* By choosing the witness k = i in the infimum: (A ⊗ B)ᵢᵢ = ⨅ₖ(Aᵢₖ + Bₖᵢ) ≤ Aᵢᵢ + Bᵢᵢ.

**Lemma 3.4** (Power Splitting). A^⊗(m+k+2) = A^⊗(m+1) ⊗ A^⊗(k+1).
*Proof.* By induction on k, using associativity of tropical multiplication.

The main theorem follows: A^⊗(m+k+2)ᵢᵢ = (A^⊗(m+1) ⊗ A^⊗(k+1))ᵢᵢ ≤ A^⊗(m+1)ᵢᵢ + A^⊗(k+1)ᵢᵢ. □

**Theorem 3.5** (Associativity). tropMul (tropMul A B) C = tropMul A (tropMul B C).
*Proof.* Both sides reduce to ⨅ₖ ⨅ₗ (Aᵢₗ + Bₗₖ + Cₖⱼ), using the commutativity of finite infima with addition and with each other.

**Theorem 3.6** (Monotonicity). If A ≤ B entrywise, then A^⊗m ≤ B^⊗m entrywise for all m.
*Proof.* By induction on m, using monotonicity of addition and infimum.

**Theorem 3.7** (Scalar Shift). (A + cJ)^⊗(m+1)ᵢᵢ = A^⊗(m+1)ᵢᵢ + (m+1)c, where J is the all-ones matrix.
*Proof.* By induction on m, pulling the constant out of the infimum at each step.

**Theorem 3.8** (Minimum Diagonal Bound). ⨅ⱼ A^⊗(m+k+2)ⱼⱼ ≤ A^⊗(m+1)ᵢᵢ + A^⊗(k+1)ᵢᵢ for any fixed i.
*Proof.* By the infimum bound ⨅ⱼ f(j) ≤ f(i), composed with Theorem 3.2.

### 3.3 Permutation Couplings and Assignment Invariance

**Theorem 3.9** (Permutation Plans are Transport Plans). For any permutation σ : Fin n ≃ Fin n and n > 0, the permutation plan π_σ(i,j) = n⁻¹ · [σ(i) = j] is a transport plan from the uniform distribution to itself.

*Proof.* Row sums: Σⱼ π_σ(i,j) = Σⱼ n⁻¹·[σ(i)=j] = n⁻¹ (since exactly one j equals σ(i)). Column sums: use the equivalence σ to reindex the sum. □

**Theorem 3.10** (Transport Cost of Permutation Plan). The transport cost of a permutation plan equals the scaled assignment cost:
```
Σᵢⱼ π_σ(i,j)·c(i,j) = n⁻¹ · Σᵢ c(i, σ(i))
```

**Theorem 3.11** (Conjugation Invariance). If c(e(i), e(j)) = c(i,j) for all i,j, then:
```
Σᵢ c(i, (e⁻¹∘σ∘e)(i)) = Σᵢ c(i, σ(i))
```

*Proof.* Change variables i ↦ e⁻¹(i) in the left sum, then apply cost invariance:
```
Σᵢ c(i, (e⁻¹∘σ∘e)(i)) = Σᵢ c(e⁻¹(i), σ(i))    [by change of variables]
                         = Σᵢ c(i, σ(i))           [rearranging via e]
```
The formal proof uses `Equiv.sum_comp` for the reindexing step. □

---

## 4. Algorithms

### 4.1 Wasserstein Distance via Linear Programming

The Wasserstein-1 distance can be computed as a linear program:

```
minimize    c^T · vec(π)
subject to  Σⱼ π(i,j) = μ(i)   for all i
            Σᵢ π(i,j) = ν(j)   for all j
            π(i,j) ≥ 0          for all i,j
```

**Complexity:** O(n³) via the simplex method or interior point methods.

### 4.2 Tropical Eigenvalue via Karp's Algorithm

```
Algorithm: Karp's Minimum Cycle Mean
Input: Weight matrix A ∈ ℝ^{n×n}
Output: Tropical eigenvalue λ*(A)

1. Compute A^⊗k for k = 1, ..., n
2. Return min_{1≤k≤n} min_i (A^⊗k)_{ii} / k
```

**Complexity:** O(n⁴) time, O(n³) space.

### 4.3 Optimal Assignment via Hungarian Algorithm

```
Algorithm: Hungarian Method
Input: Cost matrix c ∈ ℝ^{n×n}
Output: Optimal permutation σ and dual variables (u, v)

1. Initialize u_i = min_j c(i,j), v_j = 0
2. While matching is not perfect:
   a. Find augmenting path in equality graph
   b. Update dual variables along alternating tree
3. Return matching and dual variables
```

**Complexity:** O(n³) time, O(n²) space.

---

## 5. Computational Experiments

### 5.1 Wasserstein Invariance Verification

We verify invariance on Fin 4 with cost matrix:
```
c = [[0, 2, 5, 3],
     [2, 0, 3, 4],
     [5, 3, 0, 1],
     [3, 4, 1, 0]]
```

For μ = (0.4, 0.3, 0.2, 0.1), ν = (0.1, 0.2, 0.3, 0.4), and permutation e = (1,0,3,2):
- W(μ, ν) = 1.200000
- W(e*μ, e*ν) = 1.200000
- Difference: < 10⁻¹⁵

### 5.2 Tropical Subadditivity Verification

For the 3×3 matrix A = [[5,1,8],[3,7,2],[6,4,3]], we compute tropical powers and verify all subadditivity inequalities:

| Power | Diag(0) | Diag(1) | Diag(2) |
|-------|---------|---------|---------|
| 1     | 5       | 7       | 3       |
| 2     | 4       | 4       | 6       |
| 3     | 9       | 9       | 9       |
| 4     | 8       | 8       | 10      |
| 5     | 13      | 13      | 13      |
| 6     | 12      | 12      | 14      |

All 36 applicable subadditivity inequalities are verified. The asymptotic cycle means converge to the tropical eigenvalue λ* = 2.0.

### 5.3 Assignment Cost Conjugation

For the symmetric 3×3 cost c = [[0,1,1],[1,0,1],[1,1,0]] with cyclic rotation e = (1,2,0), the transposition σ = (1,0,2) has assignment cost 2.0. Its conjugate e⁻¹∘σ∘e = (2,1,0) also has cost 2.0, confirming invariance.

---

## 6. Discussion

### 6.1 Significance

The three main theorems create a formal bridge between optimization theories that were historically developed independently:

1. **Transport ↔ Group Actions:** Wasserstein invariance establishes that transport geometry is intrinsic to the cost structure, not the labeling. This is the finite precursor to equivariant transport on homogeneous spaces.

2. **Tropical ↔ Graph Theory:** Diagonal subadditivity encodes the fact that concatenating closed walks produces valid (if possibly suboptimal) closed walks. This is the algebraic shadow of graph-theoretic path composition.

3. **Transport ↔ Tropical:** Permutation couplings connect optimal transport to the assignment problem, which is the tropical permanent/determinant computation. Conjugation invariance shows that both theories respect the same symmetries.

### 6.2 Limitations

Our formalization covers the finite, discrete setting. Extensions to continuous measures, infinite-dimensional spaces, and Wasserstein-p for p > 1 require measure-theoretic foundations beyond the current scope. The tropical theory is restricted to ℝ-valued matrices; extensions to ℝ ∪ {+∞} (the completed tropical semiring) would require handling partial orders with top elements.

### 6.3 Proof Engineering

The formal proofs rely heavily on Mathlib's finite sum reindexing (`Equiv.sum_comp`), infimum manipulation (`ciInf_le`, `le_ciInf`), and function extensionality. Key proof patterns include:
- **Witness selection** for infimum bounds (choosing k = i in the diagonal bound)
- **Change of variables** via Equiv for sum reindexing
- **Structural induction** on power indices for power splitting and subadditivity

---

## 7. Future Work

Five concrete directions are detailed in `FUTURE_DIRECTIONS.md`:

1. **Finite Kantorovich duality** — connecting primal transport to dual potentials
2. **Karp's cycle-mean theorem** — identifying the tropical eigenvalue via Fekete's lemma
3. **Birkhoff–von Neumann decomposition** — every doubly stochastic matrix as a convex combination of permutation matrices
4. **Hungarian algorithm correctness** — verified optimal assignment computation
5. **Wasserstein quotient by finite group actions** — equivariant transport on orbit spaces

---

## 8. References

1. Butkovič, P. *Max-linear Systems: Theory and Algorithms.* Springer, 2010.
2. Kantorovich, L.V. "On the translocation of masses." *Dokl. Akad. Nauk SSSR* 37 (1942), 199–201.
3. Karp, R.M. "A characterization of the minimum cycle mean in a digraph." *Discrete Mathematics* 23 (1978), 309–311.
4. Kuhn, H.W. "The Hungarian method for the assignment problem." *Naval Research Logistics Quarterly* 2 (1955), 83–97.
5. Monge, G. *Mémoire sur la théorie des déblais et des remblais.* Paris, 1781.
6. Simon, I. "Limited subsets of a free monoid." *Proc. 19th FOCS* (1978), 143–150.
7. Villani, C. *Topics in Optimal Transportation.* AMS, 2003.
8. Villani, C. *Optimal Transport: Old and New.* Springer, 2009.
9. Viro, O. "Dequantization of real algebraic geometry on logarithmic paper." *European Congress of Mathematics,* 2001.

---

## Appendix A: Complete Lean 4 File Listing

The formalization consists of the following files:

| File | Lines | Key Results |
|------|-------|-------------|
| `Tropical/Wasserstein.lean` | ~140 | Wasserstein distance, pushforward, invariance theorem |
| `Tropical/Matrix/MinPlus.lean` | ~120 | Tropical multiplication, powers, associativity, subadditivity |
| `Tropical/Matrix/Spectral.lean` | ~110 | Spectral theory: symmetry, monotonicity, power splitting, bounds |
| `Bridges/TransportTropical/PermutationCouplings.lean` | ~100 | Permutation plans, conjugation invariance |
| `Bridges/TransportTropical/TropicalTransportBridge.lean` | ~140 | Bridge theorems: monotonicity, assignment bounds |

Total: ~610 lines of verified Lean 4, zero `sorry` in final proofs.
