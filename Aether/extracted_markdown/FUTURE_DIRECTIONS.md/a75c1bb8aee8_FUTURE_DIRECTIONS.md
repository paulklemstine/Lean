# Future Directions: Tropical-Transport Bridge Theory

## Overview

This document outlines five concrete, breakthrough-level research directions opened by the formalized theorems connecting optimal transport, tropical algebra, and symmetry groups. Each direction includes an explicit theorem statement, Lean-style type signature, proof strategy, and cross-domain significance.

---

## Direction 1: Finite Kantorovich Duality

### Theorem Statement

For finite probability measures μ, ν on Fin n with cost function c, the Wasserstein-1 distance equals the supremum of the Kantorovich dual:

$$W_c(\mu, \nu) = \sup_{\phi} \left\{ \sum_i \phi(i)(\mu(i) - \nu(i)) \mid \phi(i) - \phi(j) \le c(i,j) \;\forall i,j \right\}$$

This is strong LP duality for the transport problem, establishing that the primal (coupling minimization) equals the dual (Lipschitz potential maximization).

### Lean 4 Type Signature

```lean
def KantorovichDual {n : ℕ} (c : Fin n → Fin n → ℝ) (μ ν : Fin n → ℝ) : ℝ :=
  sSup {v | ∃ φ : Fin n → ℝ, (∀ i j, φ i - φ j ≤ c i j) ∧
            v = ∑ i, φ i * (μ i - ν i)}

theorem kantorovich_duality
    {n : ℕ} (c : Fin n → Fin n → ℝ) (μ ν : Fin n → ℝ)
    (hμ : IsProbVec μ) (hν : IsProbVec ν)
    (hc : ∀ i j, 0 ≤ c i j) :
    wasserstein1 c μ ν = KantorovichDual c μ ν := by
  sorry
```

### Proof Strategy

1. Formalize the transport LP and its dual as finite-dimensional linear programs.
2. Prove strong LP duality for this specific structure, either by invoking a general finite LP duality theorem (if available in Mathlib) or by direct Farkas-lemma reasoning.
3. Show that the feasible sets are nonempty and bounded.
4. Conclude equality of optimal values.

Alternative approach: Directly construct optimal dual variables from an optimal primal solution using complementary slackness. Given that we already have `transportPlans` and `wasserstein1`, the primal side is ready; the dual side needs the Lipschitz constraint formalization.

### Cross-Domain Significance

- **Transport ↔ Analysis**: Kantorovich duality connects transport to potential theory and Lipschitz analysis.
- **Transport ↔ Tropical**: The dual variables φ are "tropical potentials" — their difference constraints are exactly the tropical semiring's order structure. This links Kantorovich duality to tropical geometry's notion of tropical curves and valuations.
- **Practical**: Dual formulations enable faster algorithms (dual simplex, auction algorithms) and sensitivity analysis for logistics optimization.

---

## Direction 2: Birkhoff–von Neumann Decomposition

### Theorem Statement

Every doubly stochastic matrix (nonneg matrix with all row sums and column sums equal to 1) is a convex combination of permutation matrices. Equivalently, the set of doubly stochastic matrices equals the convex hull of permutation matrices.

For transport theory: every transport plan between uniform distributions on Fin n is a convex combination of permutation couplings.

### Lean 4 Type Signature

```lean
def IsDoublyStochastic {n : ℕ} (M : Matrix (Fin n) (Fin n) ℝ) : Prop :=
  (∀ i j, 0 ≤ M i j) ∧
  (∀ i, ∑ j, M i j = 1) ∧
  (∀ j, ∑ i, M i j = 1)

def PermMatrix {n : ℕ} (σ : Fin n ≃ Fin n) : Matrix (Fin n) (Fin n) ℝ :=
  fun i j => if σ i = j then 1 else 0

theorem birkhoff_von_neumann {n : ℕ} (hn : 0 < n)
    (M : Matrix (Fin n) (Fin n) ℝ) (hM : IsDoublyStochastic M) :
    ∃ (k : ℕ) (σs : Fin k → (Fin n ≃ Fin n)) (ws : Fin k → ℝ),
      (∀ i, 0 ≤ ws i) ∧
      (∑ i, ws i = 1) ∧
      M = ∑ i, ws i • PermMatrix (σs i) := by
  sorry
```

### Proof Strategy

1. **Induction on the number of nonzero entries**: If M is doubly stochastic and has at least one nonzero entry, then by Hall's theorem (or direct argument), there exists a permutation σ such that M(i, σ(i)) > 0 for all i.
2. **Subtract**: Let α = min_i M(i, σ(i)) > 0. Then M' = (M - α · P_σ) / (1 - α) is doubly stochastic with fewer positive entries.
3. **Induct**: Apply the decomposition to M', obtaining M = α · P_σ + (1-α) · M'.
4. The base case is when M is itself a permutation matrix.

Key prerequisite: Formalize Hall's marriage theorem for bipartite graphs, or use a direct argument about supports of doubly stochastic matrices.

### Cross-Domain Significance

- **Transport ↔ Combinatorics**: This theorem tells us that the Birkhoff polytope (set of doubly stochastic matrices) has permutation matrices as vertices. The minimum of a linear functional over this polytope is attained at a vertex, reducing transport to assignment.
- **Transport ↔ Tropical**: Combined with our `permPlan_is_transportPlan` theorem, this shows every uniform transport plan is a weighted combination of objects naturally described by tropical optimization.
- **Algorithmic**: Enables decomposition-based algorithms for transport, connecting to the Hungarian algorithm.

---

## Direction 3: Tropical Eigenvalue = Minimum Cycle Mean (Karp's Theorem)

### Theorem Statement

For a strongly connected weight matrix A on Fin n, the tropical eigenvalue λ(A) equals the minimum average weight of a directed cycle:

$$\lambda(A) = \min_{\text{cycle } C} \frac{\text{weight}(C)}{|C|} = \lim_{m \to \infty} \frac{(A^{\otimes m})_{ii}}{m}$$

and this limit exists and is independent of the vertex i (for strongly connected matrices).

### Lean 4 Type Signature

```lean
/-- A matrix is strongly connected if for every i, j there exists a path. -/
def IsStronglyConnected {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) : Prop :=
  ∀ i j : Fin n, ∃ m : ℕ, tropPow A m i j < ⊤

/-- The minimum cycle mean through vertex i. -/
noncomputable def minCycleMean {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (i : Fin n) : ℝ :=
  ⨅ m : ℕ, tropPow A m i i / (m + 1 : ℝ)

theorem tropical_eigenvalue_eq_cycle_mean
    {n : ℕ} [NeZero n] (A : Matrix (Fin n) (Fin n) ℝ)
    (hA : IsStronglyConnected A) (i j : Fin n) :
    minCycleMean A i = minCycleMean A j := by
  sorry

theorem tropical_eigenvalue_limit
    {n : ℕ} [NeZero n] (A : Matrix (Fin n) (Fin n) ℝ)
    (hA : IsStronglyConnected A) (i : Fin n) :
    Filter.Tendsto (fun m => tropPow A m i i / (m + 1 : ℝ))
      Filter.atTop (nhds (minCycleMean A i)) := by
  sorry
```

### Proof Strategy

1. **From subadditivity to convergence**: Our `tropPow_diag_subadditive` theorem gives the sequence a_m = tropPow(A, m)(i,i) as subadditive. By Fekete's lemma (which may need to be formalized for this shifted indexing), lim a_m/(m+1) = inf a_m/(m+1) exists.
2. **Independence of vertex**: For strongly connected A, any two vertices i, j can reach each other in bounded time. This bounds |a_m^{(i)} - a_m^{(j)}| by a constant, so after dividing by m, the limits agree.
3. **Karp's characterization**: Express the limit as min_{1 ≤ m ≤ n} (A^m[i,i])/m using the observation that all cycle means are generated by simple cycles of length ≤ n.

### Cross-Domain Significance

- **Tropical ↔ Graph Theory**: This is the fundamental theorem connecting tropical spectral theory to graph-theoretic shortest-path problems.
- **Tropical ↔ Control Theory**: The tropical eigenvalue governs the throughput of discrete-event systems (manufacturing lines, digital circuits).
- **Tropical ↔ Transport**: Combined with our bridge theorem, it suggests that optimal transport costs on orbit spaces converge to tropical spectral invariants.

---

## Direction 4: Hungarian Algorithm Correctness

### Theorem Statement

The Hungarian algorithm correctly solves the assignment problem: given an n×n cost matrix, it finds a permutation σ minimizing Σ_i c(i, σ(i)) in O(n³) time. Formalize the algorithm and prove it returns an optimal solution.

### Lean 4 Type Signature

```lean
/-- The Hungarian algorithm produces an optimal assignment. -/
noncomputable def hungarianAssignment {n : ℕ} (c : Fin n → Fin n → ℝ) :
    Fin n ≃ Fin n := sorry  -- algorithm implementation

theorem hungarian_optimal {n : ℕ} (hn : 0 < n)
    (c : Fin n → Fin n → ℝ) (σ : Fin n ≃ Fin n) :
    ∑ i, c i (hungarianAssignment c i) ≤ ∑ i, c i (σ i) := by
  sorry

/-- Combined with our Wasserstein results: for uniform distributions,
    the Wasserstein distance equals the Hungarian assignment cost / n. -/
theorem wasserstein_uniform_eq_assignment {n : ℕ} (hn : 0 < n)
    (c : Fin n → Fin n → ℝ) :
    wasserstein1 c (uniformProb n) (uniformProb n) =
    (n : ℝ)⁻¹ * ∑ i, c i (hungarianAssignment c i) := by
  sorry
```

### Proof Strategy

1. **Formalize the algorithm**: Define the Hungarian algorithm as a sequence of row/column reductions, augmenting path searches, and updates.
2. **Invariant maintenance**: Prove that each step maintains a dual feasible solution (row and column potentials) and a partial matching.
3. **Termination and optimality**: Show that the algorithm terminates with a complete matching, and complementary slackness with the dual solution proves optimality.
4. **Connection to transport**: Use `permPlan_transportCost` and `permPlan_is_transportPlan` to relate the assignment optimum to the Wasserstein distance.

### Cross-Domain Significance

- **Combinatorics ↔ Transport**: A verified Hungarian algorithm would be the first formally verified optimal transport solver.
- **Combinatorics ↔ Tropical**: The dual potentials in the Hungarian algorithm are tropical eigenfunction-like objects.
- **Practical**: Verified algorithms for assignment/transport have applications in verified robotics, supply chain optimization, and certified ML pipelines.

---

## Direction 5: Wasserstein Quotient Under Finite Group Actions

### Theorem Statement

When a finite group G acts on Fin n by cost-preserving bijections, the Wasserstein distance descends to the quotient: define the equivalence relation μ ~ ν iff ν = g_*μ for some g ∈ G, then the Wasserstein distance on orbits

$$\hat{W}([μ], [ν]) = \inf_{g \in G} W_c(μ, g_*ν)$$

is a well-defined pseudometric on G-orbits of probability measures.

### Lean 4 Type Signature

```lean
/-- The orbit distance: infimum of Wasserstein over group translates. -/
noncomputable def orbitWasserstein
    {n : ℕ} (c : Fin n → Fin n → ℝ)
    (G : Subgroup (Equiv.Perm (Fin n)))
    (hG : ∀ g ∈ G, ∀ i j, c (g i) (g j) = c i j)
    (μ ν : Fin n → ℝ) : ℝ :=
  ⨅ g ∈ G, wasserstein1 c μ (pushforwardEquiv g ν)

theorem orbitWasserstein_triangle
    {n : ℕ} (c : Fin n → Fin n → ℝ)
    (G : Subgroup (Equiv.Perm (Fin n)))
    (hG : ∀ g ∈ G, ∀ i j, c (g i) (g j) = c i j)
    (hc_triangle : ∀ i j k, c i k ≤ c i j + c j k)
    (μ ν ρ : Fin n → ℝ)
    (hμ : IsProbVec μ) (hν : IsProbVec ν) (hρ : IsProbVec ρ) :
    orbitWasserstein c G hG μ ρ ≤
    orbitWasserstein c G hG μ ν + orbitWasserstein c G hG ν ρ := by
  sorry

theorem orbitWasserstein_invariant
    {n : ℕ} (c : Fin n → Fin n → ℝ)
    (G : Subgroup (Equiv.Perm (Fin n)))
    (hG : ∀ g ∈ G, ∀ i j, c (g i) (g j) = c i j)
    (μ ν : Fin n → ℝ) (g : Equiv.Perm (Fin n)) (hg : g ∈ G) :
    orbitWasserstein c G hG (pushforwardEquiv g μ) ν =
    orbitWasserstein c G hG μ ν := by
  sorry
```

### Proof Strategy

1. **Well-definedness**: Use `wasserstein1_invariant_under_equiv` (our main theorem) to show the orbit distance is independent of the choice of representative in the orbit of μ.
2. **Triangle inequality**: For any ε > 0, pick near-optimal group elements g₁, g₂ for (μ,ν) and (ν,ρ). Then g₁·g₂ is a candidate for (μ,ρ), and the triangle inequality for W_c gives the bound.
3. **Symmetry and non-degeneracy**: Follow from the corresponding properties of W_c.

### Cross-Domain Significance

- **Transport ↔ Geometry**: This creates a formal metric geometry on quotient spaces, the foundation for shape matching and molecular comparison.
- **Transport ↔ Physics**: Gauge-invariant transport distances appear in lattice gauge theory and condensed matter physics.
- **Transport ↔ ML**: Equivariant Wasserstein distances enable distribution comparison that respects known symmetries (e.g., rotation-invariant image comparison).
- **Transport ↔ Tropical**: On orbit spaces, the assignment problem becomes a tropical optimization over group-equivalence classes, linking directly to our bridge theorems.

---

## Implementation Priorities

| Priority | Direction | Estimated Effort | Dependencies |
|----------|-----------|-----------------|--------------|
| 1 | Tropical Eigenvalue (Dir 3) | 2–3 weeks | `tropPow_diag_subadditive`, Fekete's lemma |
| 2 | Birkhoff–von Neumann (Dir 2) | 3–4 weeks | Hall's theorem or direct argument |
| 3 | Kantorovich Duality (Dir 1) | 2–3 weeks | LP duality or Farkas lemma |
| 4 | Orbit Wasserstein (Dir 5) | 1–2 weeks | `wasserstein1_invariant_under_equiv` |
| 5 | Hungarian Algorithm (Dir 4) | 4–6 weeks | Dirs 1, 2 |

Direction 3 (Tropical Eigenvalue) is the highest-leverage next step: it directly extends `tropPow_diag_subadditive` using Fekete's lemma, and its proof would be the first formalization of this fundamental result in tropical spectral theory. Direction 5 (Orbit Wasserstein) has the lowest barrier, building directly on our existing invariance theorem.
