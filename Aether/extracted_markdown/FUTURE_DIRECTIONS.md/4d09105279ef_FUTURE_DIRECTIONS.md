# Future Directions: Tropical-Transport Formal Mathematics Program

## Overview

This document outlines five breakthrough-level research directions opened by the formally verified results in this cycle. Each direction includes a precise theorem statement, Lean 4 type signature, proof strategy, and cross-domain significance.

Our verified foundation consists of:
- **Wasserstein invariance** under cost-preserving bijections (`wasserstein1_invariant_under_equiv`)
- **Tropical power subadditivity** for diagonal entries (`tropPow_diag_subadditive`)
- **Tropical matrix associativity and power splitting** (`tropMulS_assoc`, `tropPowS_add`)
- **Permutation coupling validity** and **assignment cost conjugation invariance**

---

## Direction 1: Finite Kantorovich Duality

### Theorem Statement
For a finite type `Fin n` with cost function `c` and probability vectors `μ, ν`, the Wasserstein-1 distance equals the supremum of expected value differences over 1-Lipschitz functions:

$$W_c(\mu, \nu) = \sup_{f : \text{1-Lip}} \left(\sum_i f(i)\,\mu(i) - \sum_i f(i)\,\nu(i)\right)$$

where `f` is 1-Lipschitz with respect to `c`: `f(j) - f(i) ≤ c(i,j)` for all `i,j`.

### Lean 4 Type Signature

```lean
def IsLipschitz1 (c : Fin n → Fin n → ℝ) (f : Fin n → ℝ) : Prop :=
  ∀ i j, f j - f i ≤ c i j

noncomputable def kantorovichDual (c : Fin n → Fin n → ℝ) (μ ν : Fin n → ℝ) : ℝ :=
  sSup {v | ∃ f, IsLipschitz1 c f ∧ v = ∑ i, f i * μ i - ∑ i, f i * ν i}

theorem finite_kantorovich_duality
    (c : Fin n → Fin n → ℝ) (μ ν : Fin n → ℝ)
    (hμ : IsProbVec μ) (hν : IsProbVec ν)
    (hc : ∀ i j, 0 ≤ c i j) :
    wasserstein1 c μ ν = kantorovichDual c μ ν := by
  sorry
```

### Proof Strategy
1. **Weak duality** (≥ direction): For any coupling π and 1-Lipschitz f, show `∑ij π(i,j) * c(i,j) ≥ ∑i f(i)*μ(i) - ∑i f(i)*ν(i)` using the marginal constraints and Lipschitz bound. Take infimum over π and supremum over f.
2. **Strong duality** (≤ direction): Use the finite-dimensional LP strong duality theorem. The transport problem is a linear program with the coupling matrix as variable, marginal constraints as equalities, and nonnegativity constraints. Its dual is exactly the Kantorovich dual.
3. **LP formulation**: Package the transport problem as `minimize c^T x subject to Ax = b, x ≥ 0` and apply finite LP duality (which may need to be formalized first as an auxiliary result).

### Cross-Domain Significance
Kantorovich duality is the cornerstone of modern optimal transport theory. In tropical terms, it connects primal minimization (over couplings) to dual maximization (over potentials), mirroring the min-max structure of tropical algebra (`tropical_duality_min_to_max`). This would be the first formally verified instance of LP duality in a transport context, opening the door to verified algorithms for Wasserstein computation.

---

## Direction 2: Tropical Cycle-Mean Theorem (Karp's Theorem)

### Theorem Statement
For a strongly connected weighted directed graph represented as a matrix `A ∈ ℝ^{n×n}`, the minimum cycle mean equals the tropical eigenvalue:

$$\lambda^*(A) = \min_{1 \le k \le n} \min_i \frac{(A^{\otimes k})_{ii}}{k}$$

Moreover, this limit exists by Fekete's lemma applied to the subadditive sequence of diagonal entries.

### Lean 4 Type Signature

```lean
/-- The tropical eigenvalue (minimum cycle mean) of a matrix. -/
noncomputable def tropEigenvalue (A : Matrix (Fin n) (Fin n) ℝ) : ℝ :=
  ⨅ k : Fin n, ⨅ i : Fin n, tropPow A k i i / (↑k + 1)

/-- The asymptotic cycle mean converges to the tropical eigenvalue. -/
theorem tropEigenvalue_is_limit [Nonempty (Fin n)]
    (A : Matrix (Fin n) (Fin n) ℝ) :
    Filter.Tendsto (fun m => (⨅ i : Fin n, tropPow A m i i) / (↑m + 1))
      Filter.atTop (nhds (tropEigenvalue A)) := by
  sorry

/-- Karp's characterization: the tropical eigenvalue equals the minimum
    over cycles of the average edge weight. -/
theorem karp_theorem [Nonempty (Fin n)]
    (A : Matrix (Fin n) (Fin n) ℝ) :
    tropEigenvalue A = ⨅ k : Fin n, ⨅ i : Fin n, tropPow A k i i / (↑k + 1) := by
  sorry
```

### Proof Strategy
1. **Fekete's lemma**: Formalize Fekete's lemma for subadditive sequences: if `a(m+n) ≤ a(m) + a(n)`, then `a(n)/n → inf_n a(n)/n`. Apply to the diagonal sequence `tropPow A m i i`.
2. **Finite minimum characterization**: Show that for an `n×n` matrix, the minimum cycle mean is achieved by a cycle of length ≤ n (by a pigeonhole argument on vertices visited).
3. **Convergence**: Combine Fekete's lemma with the finite characterization to show convergence and identify the limit.

### Cross-Domain Significance
This theorem is the tropical analogue of the Perron-Frobenius eigenvalue theorem. It connects:
- **Graph theory**: minimum-weight cycles and shortest paths
- **Dynamical systems**: asymptotic growth rates of iterated tropical maps
- **Operations research**: cycle-time optimization in discrete event systems
- **Formal verification**: a verified algorithm for computing tropical eigenvalues

Our subadditivity theorem (`tropPow_diag_subadditive`) provides the key input.

---

## Direction 3: Birkhoff–von Neumann Decomposition

### Theorem Statement
Every doubly stochastic matrix (nonneg entries with row and column sums equal to 1) is a convex combination of permutation matrices.

### Lean 4 Type Signature

```lean
def IsDoublyStochastic (M : Matrix (Fin n) (Fin n) ℝ) : Prop :=
  (∀ i j, 0 ≤ M i j) ∧
  (∀ i, ∑ j, M i j = 1) ∧
  (∀ j, ∑ i, M i j = 1)

def permMatrix (σ : Fin n ≃ Fin n) : Matrix (Fin n) (Fin n) ℝ :=
  fun i j => if σ i = j then 1 else 0

theorem birkhoff_von_neumann (M : Matrix (Fin n) (Fin n) ℝ)
    (hM : IsDoublyStochastic M) :
    ∃ (k : ℕ) (σ : Fin k → Fin n ≃ Fin n) (w : Fin k → ℝ),
      (∀ i, 0 ≤ w i) ∧ (∑ i, w i = 1) ∧
      M = ∑ i, w i • permMatrix (σ i) := by
  sorry
```

### Proof Strategy
1. **Hall's theorem**: Prove that every doubly stochastic matrix has a positive entry pattern that admits a perfect matching (system of distinct representatives).
2. **Inductive decomposition**: Find a permutation σ such that `M` has positive entries along `{(i, σ(i))}`. Let `α = min_i M(i, σ(i)) > 0`. Then `M' = (M - α·P_σ)/(1-α)` is doubly stochastic with at least one more zero entry.
3. **Termination**: Since `Fin n → Fin n → ℝ` is finite-dimensional and each step increases the number of zeros, the process terminates in at most `n²-2n+2` steps.

### Cross-Domain Significance
This theorem directly connects to our permutation coupling work: it shows that the Birkhoff polytope (set of doubly stochastic matrices) equals the convex hull of permutation matrices. Combined with our `permPlan_is_transportPlan`, this means:
- Every transport plan between uniform measures is a convex combination of permutation plans
- The Wasserstein distance for uniform measures can be computed as a minimum over permutation costs
- This bridges optimal transport to combinatorial optimization (assignment problem)

---

## Direction 4: Hungarian Algorithm Correctness

### Theorem Statement
Formalize the Hungarian algorithm for the assignment problem and prove it computes the optimal assignment in polynomial time.

### Lean 4 Type Signature

```lean
/-- The optimal assignment cost. -/
noncomputable def optimalAssignment (c : Fin n → Fin n → ℝ) : ℝ :=
  ⨅ σ : Fin n ≃ Fin n, ∑ i, c i (σ i)

/-- The Hungarian algorithm output: a permutation and dual variables. -/
structure HungarianOutput (n : ℕ) where
  σ : Fin n ≃ Fin n
  u : Fin n → ℝ
  v : Fin n → ℝ

/-- Complementary slackness: the optimal permutation only uses tight edges. -/
def isOptimalCertificate (c : Fin n → Fin n → ℝ) (out : HungarianOutput n) : Prop :=
  (∀ i j, out.u i + out.v j ≤ c i j) ∧
  (∀ i, out.u i + out.v (out.σ i) = c i (out.σ i))

theorem hungarian_optimality (c : Fin n → Fin n → ℝ)
    (out : HungarianOutput n) (h : isOptimalCertificate c out) :
    ∑ i, c i (out.σ i) = optimalAssignment c := by
  sorry

theorem hungarian_dual_bound (c : Fin n → Fin n → ℝ)
    (u v : Fin n → ℝ) (h : ∀ i j, u i + v j ≤ c i j) :
    ∑ i, u i + ∑ j, v j ≤ optimalAssignment c := by
  sorry
```

### Proof Strategy
1. **Weak duality**: Show that for any feasible dual (u,v) with u(i)+v(j) ≤ c(i,j), and any permutation σ, we have ∑u(i)+∑v(j) ≤ ∑c(i,σ(i)). This follows by summing the dual constraints along σ.
2. **Complementary slackness**: If σ and (u,v) satisfy u(i)+v(σ(i))=c(i,σ(i)) for all i, then both are optimal by strong duality.
3. **Algorithm correctness**: Show the Hungarian algorithm produces such a complementary pair by maintaining dual feasibility and augmenting matchings.

### Cross-Domain Significance
This connects to our assignment cost invariance theorem: the optimal assignment is invariant under simultaneous relabeling, which follows from our `assignment_cost_conjugation_invariant`. In tropical terms, the Hungarian algorithm computes the tropical determinant of the cost matrix, and the dual variables are tropical eigenvectors. This creates a verified computational bridge between optimal transport and tropical linear algebra.

---

## Direction 5: Wasserstein Quotient by Finite Group Actions

### Theorem Statement
When a finite group G acts on `Fin n` preserving the cost function, the Wasserstein distance descends to a well-defined metric on the quotient space of probability measures modulo G-action.

### Lean 4 Type Signature

```lean
/-- A group action on Fin n that preserves the cost function. -/
structure CostPreservingAction (n : ℕ) (G : Type*) [Group G] where
  act : G → Fin n ≃ Fin n
  cost : Fin n → Fin n → ℝ
  hom : ∀ g h, act (g * h) = (act g).trans (act h)
  preserve : ∀ g i j, cost (act g i) (act g j) = cost i j

/-- The orbit Wasserstein distance: inf over group elements of W(g·μ, ν). -/
noncomputable def orbitWasserstein [Fintype G] [Group G]
    (A : CostPreservingAction n G) (μ ν : Fin n → ℝ) : ℝ :=
  ⨅ g : G, wasserstein1 A.cost (pushforwardEquiv (A.act g) μ) ν

theorem orbitWasserstein_well_defined [Fintype G] [Group G]
    (A : CostPreservingAction n G) (μ ν : Fin n → ℝ)
    (g : G) :
    orbitWasserstein A (pushforwardEquiv (A.act g) μ) ν =
    orbitWasserstein A μ ν := by
  sorry

theorem orbitWasserstein_triangle [Fintype G] [Group G]
    (A : CostPreservingAction n G) (μ ν ρ : Fin n → ℝ)
    (hc_triangle : ∀ i j k, A.cost i k ≤ A.cost i j + A.cost j k) :
    orbitWasserstein A μ ρ ≤ orbitWasserstein A μ ν + orbitWasserstein A ν ρ := by
  sorry
```

### Proof Strategy
1. **Well-definedness**: Use our `wasserstein1_invariant_under_equiv` to show that `W(g·μ, ν) = W(g·μ, ν)` under the group action. Then show the orbit infimum is invariant under further group action on μ.
2. **Triangle inequality**: For any ε > 0, find g₁, g₂ achieving near-optimal orbit distances to ν, then compose the transport plans and use the triangle inequality for the cost function.
3. **Metric structure**: Show symmetry (by inverting group elements) and definiteness (by assuming the cost is a metric).

### Cross-Domain Significance
This is the formal foundation for equivariant optimal transport, with applications to:
- **Shape analysis**: comparing shapes up to rotation/reflection
- **Chemistry**: comparing molecular configurations up to symmetry
- **Machine learning**: G-invariant Wasserstein GANs
- **Physics**: transport on orbit spaces in gauge theory

Our `wasserstein1_invariant_under_equiv` is the key ingredient, showing that the basic distance respects individual symmetries. The quotient construction extends this to the full group orbit.

---

## Implementation Priority

1. **Kantorovich Duality** (Direction 1) — highest impact, uses existing transport infrastructure directly
2. **Birkhoff–von Neumann** (Direction 3) — connects transport and combinatorics, needed for Direction 4
3. **Cycle-Mean Theorem** (Direction 2) — uses existing subadditivity, relatively self-contained
4. **Hungarian Algorithm** (Direction 4) — requires Directions 1 and 3 as prerequisites
5. **Wasserstein Quotient** (Direction 5) — most conceptually novel, requires Direction 1

Each direction is designed to be pursued by a team with clear hypotheses, existing infrastructure to build on, and concrete proof strategies.
