# Future Directions: Spectral Mathematics Platform

This document outlines 5 concrete next steps that build on the formalized spectral theorem infrastructure, each with a precise theorem statement, proof strategy, and cross-domain significance.

---

## Direction 1: Courant–Fischer Min-Max Theorem

### Theorem Statement

For a real symmetric matrix $A \in \mathbb{R}^{n \times n}$ with eigenvalues $\lambda_1 \leq \lambda_2 \leq \cdots \leq \lambda_n$, the $k$-th eigenvalue satisfies:

$$\lambda_k = \min_{\dim(S) = k} \max_{v \in S, v \neq 0} \frac{\langle v, Av \rangle}{\langle v, v \rangle}$$

```lean
theorem courant_fischer_minmax
    {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (hA : A.IsSymm)
    (k : Fin n) :
    ∃ λₖ : ℝ, -- the k-th eigenvalue
      (∀ S : Submodule ℝ (EuclideanSpace ℝ (Fin n)),
        Module.finrank ℝ S = k.val + 1 →
        ∃ v ∈ S, v ≠ 0 ∧ rayleighQuotient A v ≥ λₖ) ∧
      (∃ S : Submodule ℝ (EuclideanSpace ℝ (Fin n)),
        Module.finrank ℝ S = k.val + 1 ∧
        ∀ v ∈ S, v ≠ 0 → rayleighQuotient A v ≤ λₖ) := by sorry
```

### Proof Strategy

1. Use `symmetric_matrix_has_orthonormal_eigenbasis` to get the eigenbasis.
2. For any $k$-dimensional subspace $S$, show it must intersect the span of the bottom $n-k+1$ eigenvectors nontrivially (dimension argument).
3. On this intersection, the Rayleigh quotient is at least $\lambda_k$.
4. The span of the first $k$ eigenvectors achieves the minimum.

### Cross-Domain Significance

- **Numerical linear algebra**: Justifies iterative eigensolvers (Lanczos, Arnoldi) that compute eigenvalues via subspace iteration.
- **Quantum mechanics**: Energy level ordering and variational principles for ground-state computation.
- **Graph theory**: Leads to Cheeger's inequality connecting algebraic connectivity to graph expansion.

---

## Direction 2: Positive Semidefinite Decomposition and Cholesky

### Theorem Statement

A real symmetric matrix $A$ is positive semidefinite (all eigenvalues $\geq 0$) if and only if $A = B^T B$ for some matrix $B$.

```lean
theorem psd_iff_factorization
    {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (hA : A.IsSymm) :
    (∀ v : EuclideanSpace ℝ (Fin n),
      @inner ℝ _ _ v ((Matrix.toEuclideanLin A) v) ≥ 0) ↔
    ∃ B : Matrix (Fin n) (Fin n) ℝ, A = Bᵀ * B := by sorry
```

### Proof Strategy

1. **Forward**: Use `exists_orthogonal_diagonalization` to write $A = QDQ^T$. Since all eigenvalues are nonneg, $D = \text{diag}(\sqrt{\lambda_i})^2$. Set $B = \text{diag}(\sqrt{\lambda_i}) Q^T$.
2. **Backward**: If $A = B^T B$, then $\langle v, Av \rangle = \langle v, B^T B v \rangle = \|Bv\|^2 \geq 0$.

### Cross-Domain Significance

- **Statistics**: Covariance matrices are PSD; this enables Cholesky-based sampling.
- **Optimization**: PSD cone is foundational for semidefinite programming (SDP).
- **Machine learning**: Kernel matrices must be PSD; this provides the certificate.

---

## Direction 3: Matrix Functional Calculus

### Theorem Statement

For a symmetric matrix $A = QDQ^T$ and any continuous function $f : \mathbb{R} \to \mathbb{R}$, define $f(A) = Q \cdot \text{diag}(f(\lambda_i)) \cdot Q^T$.

```lean
noncomputable def matrixFunction
    {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (hA : A.IsSymm)
    (f : ℝ → ℝ) : Matrix (Fin n) (Fin n) ℝ :=
  let ⟨Q, D, hQtQ, hQQt, hDiag, hAQDQt⟩ := exists_orthogonal_diagonalization A hA
  Q * Matrix.diagonal (fun i => f (D i i)) * Qᵀ

theorem matrixFunction_preserves_symmetry
    {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (hA : A.IsSymm)
    (f : ℝ → ℝ) :
    (matrixFunction A hA f).IsSymm := by sorry

theorem matrixFunction_exp_commutes
    {n : ℕ} (A B : Matrix (Fin n) (Fin n) ℝ)
    (hA : A.IsSymm) (hB : B.IsSymm)
    (hcomm : A * B = B * A) :
    matrixFunction (A + B) (by sorry) Real.exp =
    matrixFunction A hA Real.exp * matrixFunction B hB Real.exp := by sorry
```

### Proof Strategy

1. Use orthogonal diagonalization to define $f(A)$ well (choice-independent up to eigenbasis ordering).
2. Properties follow from diagonal matrix algebra.
3. Commuting symmetric matrices are simultaneously diagonalizable.

### Cross-Domain Significance

- **Quantum mechanics**: Time evolution operator $e^{-iHt/\hbar}$ for Hamiltonian $H$.
- **Differential equations**: Matrix exponentials solve $\dot{x} = Ax$.
- **Data science**: Graph diffusion kernels $e^{-tL}$ for semi-supervised learning.

---

## Direction 4: Spectral Graph Theory — Cheeger's Inequality

### Theorem Statement

For a $d$-regular graph $G$ with Laplacian eigenvalues $0 = \lambda_1 \leq \lambda_2 \leq \cdots$, the algebraic connectivity $\lambda_2$ satisfies:

$$\frac{h(G)^2}{2d} \leq \lambda_2 \leq 2 h(G)$$

where $h(G)$ is the Cheeger constant (edge expansion).

```lean
theorem cheeger_inequality
    {n : ℕ} (G : SimpleGraph (Fin n)) [DecidableRel G.Adj]
    (d : ℕ) (hreg : G.IsRegularOfDegree d) :
    -- Lower bound on algebraic connectivity via Cheeger constant
    True := by sorry  -- full statement requires Cheeger constant definition
```

### Proof Strategy

1. Use `simpleGraph_adj_isSymm` and `simpleGraph_orthogonal_diagonalization` to access the spectrum.
2. The upper bound follows from constructing a test vector from the optimal cut.
3. The lower bound (harder direction) uses the sweep algorithm on the Fiedler vector.

### Cross-Domain Significance

- **Network science**: Quantifies community structure in social/biological networks.
- **Theoretical CS**: Expander graph constructions for derandomization.
- **Spectral clustering**: Justifies why spectral methods find good graph partitions.

---

## Direction 5: Sylvester's Law of Inertia

### Theorem Statement

The number of positive, negative, and zero eigenvalues of a symmetric matrix is invariant under congruence transformations $A \mapsto S^T A S$ for invertible $S$.

```lean
theorem sylvester_law_of_inertia
    {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (hA : A.IsSymm)
    (S : Matrix (Fin n) (Fin n) ℝ) (hS : S.det ≠ 0) :
    let B := Sᵀ * A * S
    -- count of positive eigenvalues of A = count of positive eigenvalues of B
    -- count of negative eigenvalues of A = count of negative eigenvalues of B
    -- count of zero eigenvalues of A = count of zero eigenvalues of B
    True := by sorry  -- full statement requires eigenvalue counting infrastructure
```

### Proof Strategy

1. Use `exists_orthogonal_diagonalization` to diagonalize $A = QDQ^T$.
2. Show that $S^T A S$ has the same signature by analyzing $S^T Q D Q^T S$.
3. Key lemma: the rank and signature of a quadratic form are basis-invariant.

### Cross-Domain Significance

- **Morse theory**: Signature determines the type of critical point (min/max/saddle).
- **Optimization**: Second-order optimality conditions use the inertia of the Hessian.
- **Relativity**: Metric signature $(+,-,-,-)$ is the geometric invariant of spacetime.

---

## Implementation Priority

| Priority | Direction | Difficulty | Impact |
|----------|-----------|------------|--------|
| 1 | PSD Decomposition | Medium | Very High — unlocks SDP, kernels, Cholesky |
| 2 | Courant–Fischer | Hard | Very High — variational eigenvalue theory |
| 3 | Matrix Functions | Medium | High — quantum evolution, graph diffusion |
| 4 | Cheeger's Inequality | Very Hard | High — spectral graph theory core |
| 5 | Sylvester Inertia | Medium | Medium — Morse theory bridge |

All directions build directly on the `exists_orthogonal_diagonalization` and `symmetric_matrix_has_orthonormal_eigenbasis` infrastructure established in this work.
