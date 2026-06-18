# Future Directions: Tropical Rank-One Factorization and Beyond

This document outlines concrete next steps opened by the tropical rank-one factorization theorem, which establishes that a matrix satisfies all 2×2 tropical minor equalities if and only if it decomposes as a sum of row and column potentials.

---

## 1. Tropical Factor-Rank-1 Equivalence via Min-Plus

**Goal:** Formalize the min-plus (or max-plus) rank-1 factorization predicate and prove its equivalence with additive separability.

**Mathematical Statement:**
A matrix `A : Fin n → Fin m → ℝ` has *min-plus rank 1* if there exist vectors `p : Fin n → ℝ` and `q : Fin m → ℝ` such that `A i j = p i + q j` (where `+` is ordinary addition, viewed as multiplication in the min-plus semiring). This is exactly additive separability.

More generally, define *min-plus rank ≤ k* as:
```
A(i,j) = min_{t ∈ Fin k} (U(i,t) + V(t,j))
```
and prove that rank ≤ 1 in this sense is equivalent to the 2×2 minor condition.

**Lean Signature:**
```lean
def MinPlusFactorRankLE (k : ℕ) {n m : ℕ} (A : Fin n → Fin m → ℝ) : Prop :=
  ∃ U : Fin n → Fin k → ℝ, ∃ V : Fin k → Fin m → ℝ,
    ∀ i j, A i j = Finset.univ.inf' ⟨⟨0, ‹_›⟩, Finset.mem_univ _⟩
      (fun t => U i t + V t j)

theorem minplus_rank_one_iff_additive_separable
    {n m : ℕ} (hn : 0 < n) (hm : 0 < m)
    (A : Fin n → Fin m → ℝ) :
    MinPlusFactorRankLE 1 A ↔
    ∃ u : Fin n → ℝ, ∃ v : Fin m → ℝ, ∀ i j, A i j = u i + v j
```

**Proof Strategy:** For k=1, `Fin 1` has a unique element, so the min over a singleton is trivial. The forward direction extracts the unique factor; the reverse constructs U and V from u, v.

**Cross-Domain Significance:** Bridges the additive-separability characterization to the standard tropical linear algebra literature. Enables formal treatment of tropical matrix factorization problems arising in scheduling, optimization, and discrete event systems.

---

## 2. Tropical Rank-2 Decomposition Criteria

**Goal:** Characterize matrices expressible as the min (or max) of two additively separable terms.

**Mathematical Statement:**
`A : Fin n → Fin m → ℝ` has min-plus rank ≤ 2 if and only if there exist `u₁, u₂ : Fin n → ℝ` and `v₁, v₂ : Fin m → ℝ` such that
```
A(i,j) = min(u₁(i) + v₁(j), u₂(i) + v₂(j)).
```

A necessary condition is the *tropical 3×3 minor condition*: for all 3×3 submatrices, the tropical determinant achieves its minimum at least twice among the six permutation terms.

**Lean Signature:**
```lean
def MinPlusRankLE2 {n m : ℕ} (A : Fin n → Fin m → ℝ) : Prop :=
  ∃ u₁ u₂ : Fin n → ℝ, ∃ v₁ v₂ : Fin m → ℝ,
    ∀ i j, A i j = min (u₁ i + v₁ j) (u₂ i + v₂ j)

theorem rank2_necessary_condition
    {n m : ℕ} (A : Fin n → Fin m → ℝ) (h : MinPlusRankLE2 A) :
    ∀ i₁ i₂ i₃ : Fin n, ∀ j₁ j₂ j₃ : Fin m,
      <tropical 3×3 minor condition>
```

**Proof Strategy:** Expand the min expressions and use case analysis on which branch achieves the minimum. The 3×3 minor condition follows from a pigeonhole argument on the six permutation terms.

**Cross-Domain Significance:** Rank-2 tropical decomposition captures piecewise-linear functions with two pieces, directly relevant to single-ReLU-layer neural networks. This connects to `relu_tropical_rank_le2` in the catalog and would provide a structural decomposition for ReLU layer outputs.

---

## 3. Neural Separability Theorem

**Goal:** Use the rank-1 factorization theorem to identify conditions under which a ReLU neural network layer admits a verified tropical rank-1 decomposition, implying feature-channel decoupling.

**Mathematical Statement:**
Given a ReLU layer `f(x) = max(Wx + b, 0)` with weight matrix `W : Fin m → Fin d → ℝ`, if the *effective tropical weight matrix* (defined via the max-plus semiring) satisfies all 2×2 tropical minor equalities, then the layer's output features are additively separable in input and channel indices.

**Lean Signature:**
```lean
theorem relu_tropical_rank1_separable
    {d m : ℕ} (hd : 0 < d) (hm : 0 < m)
    (W : Fin m → Fin d → ℝ)
    (hminor : ∀ i₁ i₂ : Fin m, ∀ j₁ j₂ : Fin d,
      W i₁ j₁ + W i₂ j₂ = W i₁ j₂ + W i₂ j₁) :
    ∃ u : Fin m → ℝ, ∃ v : Fin d → ℝ,
      ∀ i j, W i j = u i + v j
```

**Proof Strategy:** Direct application of `tropical_rank_one_iff_additive_separable` to the weight matrix.

**Cross-Domain Significance:** Provides a mathematical certificate for when a neural network layer is "tropically simple" — meaning its features decouple into independent row and column contributions. This is relevant for neural network pruning, interpretability, and compression, giving a rigorous foundation for identifying redundant parameters.

---

## 4. Bipartite Cohomology Formulation

**Goal:** Recast the tropical rank-1 factorization theorem as exactness of a discrete 1-cocycle on the complete bipartite graph K_{n,m}.

**Mathematical Statement:**
Consider the complete bipartite graph with vertex sets `Fin n` (left) and `Fin m` (right). A function `A : Fin n → Fin m → ℝ` assigns a weight to each edge. Define the *discrete coboundary operator* δ₀ mapping vertex potentials (u, v) to edge weights via `(δ₀(u,v))(i,j) = u(i) + v(j)`. Define the *rectangular curl* operator δ₁ mapping edge weights to face values via `(δ₁A)(i₁,i₂,j₁,j₂) = A(i₁,j₁) + A(i₂,j₂) - A(i₁,j₂) - A(i₂,j₁)`.

The rank-1 factorization theorem states: `ker(δ₁) = im(δ₀)`, i.e., the first cohomology group H¹(K_{n,m}; ℝ) vanishes.

**Lean Signature:**
```lean
def rectangular_curl {n m : ℕ} (A : Fin n → Fin m → ℝ)
    (i₁ i₂ : Fin n) (j₁ j₂ : Fin m) : ℝ :=
  A i₁ j₁ + A i₂ j₂ - A i₁ j₂ - A i₂ j₁

def coboundary {n m : ℕ} (u : Fin n → ℝ) (v : Fin m → ℝ) :
    Fin n → Fin m → ℝ := fun i j => u i + v j

theorem bipartite_H1_vanishes {n m : ℕ} (hn : 0 < n) (hm : 0 < m)
    (A : Fin n → Fin m → ℝ) :
    (∀ i₁ i₂ j₁ j₂, rectangular_curl A i₁ i₂ j₁ j₂ = 0) ↔
    ∃ u v, A = coboundary u v
```

**Proof Strategy:** Unfold definitions and reduce to `tropical_rank_one_iff_additive_separable` via `funext`.

**Cross-Domain Significance:** Connects tropical rank theory to discrete Hodge theory, graph cohomology, and network flow theory. The vanishing of H¹ on complete bipartite graphs is a fundamental structural fact that generalizes to resistance networks, optimal transport, and gauge theories on graphs.

---

## 5. Representation-Theoretic Rigidity Bridge

**Goal:** Connect local tropical minor constraints to global injectivity/rigidity phenomena, inspired by `gl3_tropical_satake_injective_of_edge_rank2_marginals` in the catalog.

**Mathematical Statement:**
Consider the tropicalization of the Satake transform for GL_n. The catalog theorem shows that edge rank-2 marginal constraints force injectivity for GL_3. The rank-1 factorization theorem provides the base case: if a tropicalized representation matrix has all 2×2 minors vanishing, then it is completely determined by boundary data (one row and one column potential).

Concretely: define the *tropical Satake fiber* over a point as the set of matrices with prescribed row and column sums (marginals). For rank-1 matrices, the fiber is either empty or a single gauge orbit.

**Lean Signature:**
```lean
theorem tropical_rank1_rigidity
    {n m : ℕ} (hn : 0 < n) (hm : 0 < m)
    (A B : Fin n → Fin m → ℝ)
    (hA : ∀ i₁ i₂ j₁ j₂, A i₁ j₁ + A i₂ j₂ = A i₁ j₂ + A i₂ j₁)
    (hB : ∀ i₁ i₂ j₁ j₂, B i₁ j₁ + B i₂ j₂ = B i₁ j₂ + B i₂ j₁)
    (hrow : ∀ i, A i ⟨0, hm⟩ = B i ⟨0, hm⟩)
    (hcol : ∀ j, A ⟨0, hn⟩ j = B ⟨0, hn⟩ j) :
    ∀ i j, A i j = B i j
```

**Proof Strategy:** Apply the normalized factorization theorem to both A and B with base indices (0,0). The explicit formulas for u, v show that A and B must agree everywhere since they agree on the base row and column.

**Cross-Domain Significance:** This provides the simplest instance of the tropical rigidity phenomenon: local rank constraints plus boundary matching force global agreement. This is the foundational mechanism behind tropical Satake injectivity results and, more broadly, behind the use of tropical geometry to control representation-theoretic data.

---

## Summary Table

| # | Direction | Difficulty | Dependencies | Impact |
|---|-----------|-----------|--------------|--------|
| 1 | Min-plus rank-1 equivalence | Easy | `tropical_rank_one_iff_additive_separable` | Bridges to standard tropical algebra |
| 2 | Rank-2 decomposition | Medium-Hard | Direction 1, `relu_tropical_rank_le2` | ReLU layers, scheduling |
| 3 | Neural separability | Easy | `tropical_rank_one_iff_additive_separable` | ML interpretability |
| 4 | Bipartite cohomology | Medium | `tropical_rank_one_iff_additive_separable` | Graph theory, Hodge theory |
| 5 | Representation rigidity | Medium | Directions 1, 4, `gl3_tropical_satake` | Representation theory |

Each direction includes a concrete theorem statement, a proof strategy, and cross-domain connections, enabling a research team to pick up and pursue any of them with clear hypotheses and formal targets.
