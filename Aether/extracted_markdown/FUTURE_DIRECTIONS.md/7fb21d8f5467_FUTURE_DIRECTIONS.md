# Future Directions: Tropical Algebra, Optimal Transport, and Beyond

This document outlines 5 concrete, breakthrough-level research directions opened by the formally verified theorems in this project. Each direction includes an explicit theorem statement, a Lean-style type signature, a proof strategy, and cross-domain significance.

---

## Direction 1: Finite Kantorovich Duality

### Theorem Statement

For finite probability vectors μ and ν on `Fin n` and a cost function c, the Wasserstein-1 distance equals the supremum of the dual functional:

$$W_c(\mu, \nu) = \sup \left\{ \sum_i f(i) \cdot (\mu(i) - \nu(i)) \;\middle|\; f : \text{Fin } n \to \mathbb{R},\; \forall i\, j,\; f(i) - f(j) \le c(i,j) \right\}$$

This is the discrete Kantorovich duality theorem, the cornerstone of computational optimal transport.

### Lean Type Signature

```lean
def dualFeasible {n : ℕ} (c : Fin n → Fin n → ℝ) (f : Fin n → ℝ) : Prop :=
  ∀ i j, f i - f j ≤ c i j

def dualObjective {n : ℕ} (f : Fin n → ℝ) (μ ν : Fin n → ℝ) : ℝ :=
  ∑ i, f i * (μ i - ν i)

theorem kantorovich_duality {n : ℕ} (c : Fin n → Fin n → ℝ)
    (μ ν : Fin n → ℝ) (hμ : IsProbVec μ) (hν : IsProbVec ν)
    (hc : ∀ i j, 0 ≤ c i j) :
    wasserstein1 c μ ν =
    sSup {v | ∃ f : Fin n → ℝ, dualFeasible c f ∧ dualObjective f μ ν = v} := by
  sorry
```

### Proof Strategy

1. **Weak duality**: Show that for any feasible f and any transport plan π, `dualObjective f μ ν ≤ transportCost c π`. This follows from summing the constraint `f(i) - f(j) ≤ c(i,j)` weighted by `π(i,j)`.
2. **Strong duality**: Use finite-dimensional LP duality (the transport problem is a finite LP). Either formalize the LP duality theorem or construct the dual optimum explicitly.
3. **Alternatively**: Prove strong duality via the complementary slackness conditions for finite LPs.

### Cross-Domain Significance

Kantorovich duality connects optimal transport to Lipschitz analysis (dual variables are 1-Lipschitz functions), convex optimization, and potential theory. Combined with the Wasserstein invariance theorem, it would show that dual optimal potentials transform covariantly under symmetries.

---

## Direction 2: Birkhoff–von Neumann Decomposition

### Theorem Statement

Every doubly stochastic matrix (nonneg entries, row and column sums = 1) is a convex combination of permutation matrices. Equivalently, the Birkhoff polytope (set of doubly stochastic matrices) has permutation matrices as its vertices.

### Lean Type Signature

```lean
def IsDoublyStochastic {n : ℕ} (M : Matrix (Fin n) (Fin n) ℝ) : Prop :=
  (∀ i j, 0 ≤ M i j) ∧
  (∀ i, ∑ j, M i j = 1) ∧
  (∀ j, ∑ i, M i j = 1)

def IsPermMatrix {n : ℕ} (P : Matrix (Fin n) (Fin n) ℝ) : Prop :=
  ∃ σ : Fin n ≃ Fin n, ∀ i j, P i j = if σ i = j then 1 else 0

theorem birkhoff_von_neumann {n : ℕ} (M : Matrix (Fin n) (Fin n) ℝ)
    (hM : IsDoublyStochastic M) :
    ∃ (k : ℕ) (coeffs : Fin k → ℝ) (perms : Fin k → Matrix (Fin n) (Fin n) ℝ),
      (∀ t, 0 ≤ coeffs t) ∧
      (∑ t, coeffs t = 1) ∧
      (∀ t, IsPermMatrix (perms t)) ∧
      M = ∑ t, coeffs t • perms t := by
  sorry
```

### Proof Strategy

1. **Induction on the number of nonzero entries**: By Hall's theorem (which exists in Mathlib), any doubly stochastic matrix contains a permutation's support in its positive entries.
2. **Subtract the permutation** scaled by the minimum positive entry, obtaining a new doubly stochastic matrix with fewer nonzero entries.
3. **Iterate** until the zero matrix is reached.

### Cross-Domain Significance

This connects the Birkhoff polytope to our permutation coupling theory: every transport plan between uniform measures decomposes into permutation couplings. Combined with `permPlan_is_transportPlan`, this would show that Wasserstein-1 between uniform measures can always be computed by optimizing over permutations alone — the bridge between continuous optimization and combinatorial assignment.

---

## Direction 3: Tropical Eigenvalue = Minimum Cycle Mean (Karp's Theorem)

### Theorem Statement

For a matrix A representing edge weights of a complete directed graph on n vertices, the tropical eigenvalue (the limit of diagonal entries of tropical powers divided by the power) equals the minimum cycle mean:

$$\lambda(A) = \min_{1 \le k \le n} \min_{1 \le i \le n} \frac{(A^{\otimes k})_{ii}}{k}$$

Moreover, by the subadditivity theorem (already proved), this minimum is achieved for some k ≤ n.

### Lean Type Signature

```lean
noncomputable def tropicalEigenvalue {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ) : ℝ :=
  ⨅ (k : Fin n) (i : Fin n), tropPow A k i i / (↑k.val + 1)

theorem tropical_eigenvalue_eq_min_cycle_mean {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ) (i : Fin n) :
    Filter.Tendsto (fun m => tropPow A m i i / (↑m + 1))
      Filter.atTop (nhds (tropicalEigenvalue A)) := by
  sorry
```

### Proof Strategy

1. **Use subadditivity** (already proved as `tropPow_diag_subadditive`) to invoke Fekete's lemma.
2. **Formalize Fekete's lemma**: if {aₙ} is subadditive, then `lim aₙ/n = inf aₙ/n`.
3. **Show the infimum is achieved for k ≤ n** by a pigeonhole argument on the vertices visited in an optimal walk.

### Cross-Domain Significance

This connects tropical linear algebra to graph theory (shortest cycle means), dynamical systems (Lyapunov exponents of max-plus linear systems), and operations research (cycle time of discrete-event systems). The subadditivity theorem proved in this project is the formal kernel that makes this possible.

---

## Direction 4: Hungarian Algorithm Correctness

### Theorem Statement

The Hungarian algorithm correctly solves the assignment problem in O(n³) time: given a cost matrix C, it finds a permutation σ minimizing ∑ᵢ C(i, σ(i)).

### Lean Type Signature

```lean
noncomputable def hungarianAlgorithm {n : ℕ} (C : Matrix (Fin n) (Fin n) ℝ) :
    Fin n ≃ Fin n := by
  sorry -- algorithmic definition

theorem hungarian_optimal {n : ℕ} [NeZero n]
    (C : Matrix (Fin n) (Fin n) ℝ) :
    ∀ σ : Fin n ≃ Fin n,
      ∑ i, C i (hungarianAlgorithm C i) ≤ ∑ i, C i (σ i) := by
  sorry
```

### Proof Strategy

1. **Define the algorithm** as a sequence of row/column reductions and augmenting path operations.
2. **Prove termination** by showing the number of assigned rows strictly increases.
3. **Prove optimality** via LP duality: the algorithm simultaneously constructs primal and dual feasible solutions satisfying complementary slackness.
4. **Connect to transport**: by `permPlan_transportCost`, this gives an algorithm for Wasserstein-1 between uniform distributions.

### Cross-Domain Significance

This would be the first formally verified assignment algorithm that simultaneously lives in the transport, tropical, and combinatorial optimization worlds. Combined with conjugation invariance (`assignment_cost_conjugation_invariant`), it would show that the algorithm is equivariant: relabeling the cost matrix by a symmetry merely permutes the output.

---

## Direction 5: Wasserstein Quotient by Finite Group Actions

### Theorem Statement

If a finite group G acts on `Fin n` preserving the cost function c, then the Wasserstein distance descends to a well-defined metric on the space of orbits of probability measures under G.

### Lean Type Signature

```lean
def GroupInvariantCost {n : ℕ} (G : Subgroup (Equiv.Perm (Fin n)))
    (c : Fin n → Fin n → ℝ) : Prop :=
  ∀ g ∈ G, ∀ i j, c (g i) (g j) = c i j

def OrbitallyEquivalent {n : ℕ} (G : Subgroup (Equiv.Perm (Fin n)))
    (μ ν : Fin n → ℝ) : Prop :=
  ∃ g ∈ G, pushforwardEquiv g μ = ν

theorem wasserstein_quotient_well_defined {n : ℕ}
    (G : Subgroup (Equiv.Perm (Fin n)))
    (c : Fin n → Fin n → ℝ)
    (hc : GroupInvariantCost G c)
    (μ₁ μ₂ ν₁ ν₂ : Fin n → ℝ)
    (hμ : OrbitallyEquivalent G μ₁ μ₂)
    (hν : OrbitallyEquivalent G ν₁ ν₂) :
    wasserstein1 c μ₁ ν₁ = wasserstein1 c μ₂ ν₂ := by
  sorry
```

### Proof Strategy

1. **Apply the invariance theorem** (`wasserstein1_invariant_under_equiv`) twice: once for the element taking μ₁ to μ₂, and once for the element taking ν₁ to ν₂.
2. **Use the group structure** to compose the two symmetries and show the result is still in G, hence cost-preserving.
3. **Construct the quotient metric** as the Wasserstein distance on orbit representatives.

### Cross-Domain Significance

This is the gateway to equivariant machine learning: many real-world distributions have symmetries (rotational invariance of point clouds, permutation invariance of sets), and computing transport distances on the quotient dramatically reduces computational cost. It connects geometric group theory, metric geometry, and computational optimal transport in a single formal framework.

---

## Research Program Summary

These five directions form a coherent program:

```
                    ┌─────────────────────┐
                    │  Kantorovich Duality │
                    │     (Direction 1)    │
                    └──────────┬──────────┘
                               │ LP duality
              ┌────────────────┼────────────────┐
              │                │                │
    ┌─────────▼──────┐  ┌─────▼──────┐  ┌──────▼──────────┐
    │    Birkhoff     │  │  Hungarian  │  │   Wasserstein   │
    │  Decomposition  │  │  Algorithm  │  │    Quotient     │
    │  (Direction 2)  │  │(Direction 4)│  │  (Direction 5)  │
    └────────┬───────┘  └──────┬──────┘  └────────┬────────┘
             │                 │                   │
             └─────────┬───────┘                   │
                       │                           │
              ┌────────▼────────┐                  │
              │ Tropical Eigen- │                  │
              │ value = Cycle   │──────────────────┘
              │ Mean (Dir. 3)   │   spectral → geometric
              └─────────────────┘
```

The central insight unifying all directions: **minimization over structured sets (transport plans, permutations, cycles) is governed by algebraic identities (subadditivity, duality, group invariance) that can be formally verified and composed.**
