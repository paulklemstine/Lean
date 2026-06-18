# Tropical Linear Algebra: Eigenvalues, Determinants, and the Assignment Problem

## Abstract

We develop a formal theory of tropical (max-plus) linear algebra over the real numbers, establishing rigorously the fundamental algebraic and spectral properties of tropical matrices. Our main contributions are:

1. **Tropical determinant-permanent identity**: We prove that the tropical determinant and tropical permanent coincide — a uniquely tropical phenomenon arising from the absence of additive inverses in the tropical semiring.

2. **Super-multiplicativity**: We establish that `tropDet(A ⊗ B) ≥ tropDet(A) + tropDet(B)` with an explicit witness construction, and show this inequality can be strict — contrasting with the classical equality `det(AB) = det(A)·det(B)`.

3. **Spectral theory**: We prove the superadditivity of diagonal entries of tropical matrix powers, the connection between cycle means and the tropical trace, and the translation invariance of the tropical cycle mean.

4. **Tropical distributivity**: We establish that max-plus matrix multiplication distributes over entrywise maximum, providing the algebraic foundation for dynamic programming algorithms.

All results are formalized in Lean 4 with complete machine-verified proofs, building on and extending the catalog of tropical algebraic results.

## 1. Introduction

The **tropical semiring** (ℝ ∪ {-∞}, max, +) replaces classical addition with maximum and classical multiplication with addition. This change of arithmetic, while seemingly simple, has profound consequences for linear algebra, combinatorial optimization, and algebraic geometry.

Tropical matrix algebra arises naturally in:
- **Shortest path algorithms** (min-plus convention) and scheduling
- **Discrete event systems** and Petri nets
- **Algebraic geometry** via tropicalization of varieties
- **Control theory** and max-plus linear dynamical systems

Since we work over ℝ (without -∞), our matrices represent **complete weighted directed graphs** where every edge has a finite weight. This avoids the technical complications of the extended real line while capturing the essential algebraic structure.

### 1.1 Conventions

We use the **max-plus** convention throughout:
- Tropical addition: a ⊕ b = max(a, b)
- Tropical multiplication: a ⊗ b = a + b
- Tropical zero: -∞ (absent in our ℝ-valued formalization)
- Tropical one: 0

Matrices are indexed by `Fin (n+1)`, ensuring nonemptiness of the index set.

## 2. Definitions

### 2.1 Tropical Matrix Operations

**Definition 2.1** (Tropical Matrix Multiplication). For matrices A, B of compatible dimensions:
```
(tropMM A B)_{ij} = max_k (A_{ik} + B_{kj})
```

**Definition 2.2** (Tropical Matrix Power). The tropical power is defined recursively:
```
tropPow' W 0 = W
tropPow' W (m+1) = tropMM (tropPow' W m) W
```
so `tropPow' W m` represents the (m+1)-fold tropical product.

**Definition 2.3** (Tropical Determinant). The tropical determinant is:
```
tropDet A = max_σ Σ_i A_{i,σ(i)}
```
where σ ranges over all permutations of the index set.

**Definition 2.4** (Tropical Permanent). The tropical permanent has the same formula:
```
tropPerm A = max_σ Σ_i A_{i,σ(i)}
```

**Definition 2.5** (Tropical Trace). The tropical trace is:
```
tropTr A = max_i A_{ii}
```

**Definition 2.6** (Tropical Cycle Mean). The maximum cycle mean is:
```
tropCycleMean A = max_{i,m ∈ Fin(n+1)} tropPow' A m i i / (m + 1)
```

## 3. Main Results

### 3.1 Tropical Determinant = Tropical Permanent

**Theorem 3.1** (`tropDet_eq_tropPerm`). For any (n+1)×(n+1) matrix A over ℝ:
```
tropDet A = tropPerm A
```

*Proof sketch.* This is definitional — both are `max_σ Σ_i A_{i,σ(i)}`. The conceptual content is that in classical algebra, `det A = Σ_σ ε(σ) Π_i A_{i,σ(i)}` differs from `perm A = Σ_σ Π_i A_{i,σ(i)}` by the sign factor ε(σ). In tropical algebra, ε(σ) tropicalizes to 0 (the tropical multiplicative identity), so the sign factor vanishes. □

*Example.* For A = [[3, 1], [2, 4]]:
- Classically: det(A) = 3·4 - 1·2 = 10, perm(A) = 3·4 + 1·2 = 14.
- Tropically: tropDet(A) = max(3+4, 1+2) = max(7, 3) = 7 = tropPerm(A).

*Generalization.* This extends to any idempotent semiring (where a ⊕ a = a), not just the max-plus semiring. The key property is the absence of additive inverses.

*Boundary.* The identity breaks when we add a sign structure. The "signed tropical determinant" (also called the tropical sign-determinant), where terms are classified by permutation parity, can differ from the permanent. This signed version is relevant for tropical Cramer's rule.

### 3.2 Transpose Invariance

**Theorem 3.2** (`tropDet_transpose`). For any matrix A:
```
tropDet(Aᵀ) = tropDet(A)
```

*Proof sketch.* The map σ ↦ σ⁻¹ is a bijection on the symmetric group. For any σ, reindexing via the substitution j = σ(i) gives `Σ_i A_{σ⁻¹(i),i} = Σ_j A_{j,σ(j)}`. □

### 3.3 Super-Multiplicativity

**Theorem 3.3** (`tropDet_product_ge`). For any matrices A, B:
```
tropDet(A) + tropDet(B) ≤ tropDet(tropMM A B)
```

*Proof sketch.* Let σ, τ achieve tropDet(A) and tropDet(B) respectively. The permutation τ·σ witnesses:

```
tropDet(A ⊗ B) ≥ Σ_i (A ⊗ B)_{i,(τ·σ)(i)}
               ≥ Σ_i (A_{i,σ(i)} + B_{σ(i),τ(σ(i))})
               = Σ_i A_{i,σ(i)} + Σ_j B_{j,τ(j)}
               = tropDet(A) + tropDet(B)
```

The reindexing step uses the bijectivity of σ. □

*Example.* Take A = [[10, 0], [10, 0]], B = [[0, 0], [0, 0]]. Then:
- tropDet(A) = max(10+0, 0+10) = 10
- tropDet(B) = max(0+0, 0+0) = 0
- tropMM A B = [[10, 10], [10, 10]]
- tropDet(tropMM A B) = max(10+10, 10+10) = 20 > 10 = tropDet(A) + tropDet(B)

This shows strict inequality is possible.

*Generalization.* The inequality extends to rectangular factorizations: if C = tropMM A B where A is n×k and B is k×n, then tropDet(C) ≥ tropDet(A') + tropDet(B') for appropriate square submatrices.

*Boundary.* Equality `tropDet(A ⊗ B) = tropDet(A) + tropDet(B)` holds when the optimal permutations for A, B, and A⊗B are "compatible" — specifically, when the argmax intermediate vertices form a permutation. This is related to the notion of "generically tropical" matrices.

### 3.4 Associativity

**Theorem 3.4** (`tropMM_assoc`). Tropical matrix multiplication is associative:
```
tropMM (tropMM A B) C = tropMM A (tropMM B C)
```

*Proof sketch.* Entry (i,j) of both sides equals `max_{k,l} (A_{il} + B_{lk} + C_{kj})`. For ≤: the LHS is `max_k (max_l (A_{il} + B_{lk}) + C_{kj})`, and for each k, the inner max witnesses a particular l that can be propagated to the RHS. For ≥: symmetric argument. □

### 3.5 Diagonal Superadditivity

**Theorem 3.5** (`tropPow'_diag_superadd`). For any matrix W and vertex i:
```
tropPow' W m i i + tropPow' W k i i ≤ tropPow' W (m+k+1) i i
```

*Proof sketch.* By the power splitting theorem (`tropPow'_add`), `tropPow' W (m+k+1) = tropMM (tropPow' W m) (tropPow' W k)`. Then `tropMM (tropPow' W m) (tropPow' W k) i i ≥ tropPow' W m i i + tropPow' W k i i` by choosing the intermediate vertex to be i. □

This superadditivity is the key ingredient in:
- Fekete's lemma for convergence of `tropPow' W m i i / (m+1)`
- The tropical Perron-Frobenius theorem

### 3.6 Tropical Distributivity

**Theorem 3.6** (`tropMM_tropAdd_left`). Tropical multiplication distributes over entrywise maximum:
```
tropMM A (max(B₁, B₂)) = max(tropMM A B₁, tropMM A B₂)
```

*Proof sketch.* For each entry (i,j):
```
max_k (A_{ik} + max(B₁_{kj}, B₂_{kj}))
= max_k max(A_{ik} + B₁_{kj}, A_{ik} + B₂_{kj})     [+ distributes over max]
= max(max_k (A_{ik} + B₁_{kj}), max_k (A_{ik} + B₂_{kj}))  [max commutes with max]
```
□

*Example.* This distributivity underlies the correctness of dynamic programming: the Bellman-Ford shortest-path algorithm relies on the fact that extending paths distributes over the minimum operation.

### 3.7 Translation Invariance

**Theorem 3.7** (`tropDet_add_const`). Adding a constant c to every entry scales the determinant:
```
tropDet(A + c) = tropDet(A) + (n+1)·c
```

**Theorem 3.8** (`tropCycleMean_add_const_diag`). The cycle mean shifts linearly:
```
tropCycleMean(W + c) = tropCycleMean(W) + c
```

*Proof sketch.* For Theorem 3.7: each permutation sum `Σ_i (A_{i,σ(i)} + c) = Σ_i A_{i,σ(i)} + (n+1)c`, so the maximum shifts by (n+1)c. For Theorem 3.8: by induction, `tropPow'(W+c) k i j = tropPow' W k i j + (k+1)c`, so the normalized diagonal entry shifts by exactly c. □

### 3.8 Cycle Mean Bounds

**Theorem 3.9** (`diag_le_tropCycleMean`). Each diagonal entry is a lower bound for the cycle mean:
```
W_{ii} ≤ tropCycleMean(W)
```

**Theorem 3.10** (`tropPow'_diag_div_mono_helper`). The Fekete lower bound:
```
(k+1) · W_{ii} ≤ tropPow' W k i i
```

These establish that the normalized diagonal powers are monotonically bounded below by the diagonal entries.

## 4. Algorithms

### 4.1 Tropical Matrix Multiplication
The max-plus matrix product can be computed in O(n³) time, identical to classical matrix multiplication. For special structured matrices (e.g., Monge matrices), sub-cubic algorithms exist.

### 4.2 Tropical Determinant (Assignment Problem)
The tropical determinant equals the optimal assignment value, computable in O(n³) by the Hungarian algorithm (Kuhn-Munkres).

### 4.3 Maximum Cycle Mean
The maximum cycle mean can be computed in O(n³) by Karp's algorithm, which exploits the superadditivity of diagonal entries.

## 5. Connection to Existing Catalog Results

Our work builds on and extends:

1. **`tropical_perron_frobenius`** (Catalog/Tropical/PerronFrobenius.lean): The existing formalization proves the asymptotic convergence `tropPow W m i j / (m+1) → tropRate W`. Our work provides the algebraic substrate (associativity, power splitting, superadditivity) in a slightly different formalization (using `Fin (n+1) → Fin (n+1) → ℝ` instead of `Matrix`) and adds the determinant theory.

2. **`tropical_fundamental_theorem`** (Catalog/Tropical/Surjectivity_of_the_Tropical_Satake_Transform_for_GL₃.lean): Our determinant-permanent identity connects to the fundamental theorem of tropical algebra.

3. **`exp_tropical_hom_max`** (Catalog/Tropical/TropicalNNFrontier.lean): The exponential map from max-plus to ordinary algebra provides the bridge between our algebraic results and their classical counterparts.

## 6. Discussion

### 6.1 The Determinant-Permanent Gap
The tropical collapse of determinant and permanent raises deep questions. Classically, computing the permanent is #P-complete (Valiant, 1979), while the determinant is in P. Tropically, both are the same problem — the assignment problem, solvable in O(n³). This suggests that the computational hardness of the permanent is intrinsically linked to the sign structure of classical algebra, not to the combinatorial structure of permutations.

### 6.2 Super-Multiplicativity vs. Multiplicativity
The failure of tropical determinant multiplicativity `tropDet(A⊗B) = tropDet(A) + tropDet(B)` is connected to the phenomenon of **tropical rank deficiency**. When the optimal assignment in the product uses non-permutation intermediate vertices, the inequality is strict. Characterizing when equality holds is an open problem related to tropical matrix rank theory.

### 6.3 Tropical Cayley-Hamilton
In the classical setting, every matrix satisfies its characteristic polynomial: p(A) = 0. The tropical analog states that tropPow' A n ⊕ c_{n-1} ⊗ tropPow' A (n-1) ⊕ ... ⊕ c₀ ⊗ I = tropPow' A n (in an inequality sense), where the coefficients c_i are the tropical elementary symmetric functions. Formalizing this is a natural next step.

## 7. Future Work

1. **Tropical Cayley-Hamilton**: Formalize the tropical characteristic polynomial and prove the tropical Cayley-Hamilton theorem (in inequality form).
2. **Tropical rank theory**: Define tropical rank (Barvinok rank, Kapranov rank) and prove basic properties.
3. **Infinite-dimensional tropical operators**: Extend the theory to tropical linear operators on function spaces.
4. **Connection to valuations**: Formalize the tropicalization functor and prove that tropical matrix operations arise as limits of classical operations under logarithmic scaling.

## References

1. R.A. Cuninghame-Green, *Minimax Algebra*, Springer-Verlag, 1979.
2. P. Butkovič, *Max-linear Systems: Theory and Algorithms*, Springer, 2010.
3. D. Maclagan and B. Sturmfels, *Introduction to Tropical Geometry*, AMS, 2015.
4. M. Akian, S. Gaubert, and A. Guterman, "Tropical polyhedra are equivalent to mean payoff games," *International Journal of Algebra and Computation*, 22(1), 2012.
5. S. Gaubert and M. Plus, "Methods and applications of (max,+) linear algebra," STACS 1997.
