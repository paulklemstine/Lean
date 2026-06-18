# Future Directions: Transport-Tropical Unified Optimization Theory

This document outlines breakthrough-level research opportunities opened by the formally verified theorems in this cycle: Wasserstein invariance under cost-preserving bijections, tropical power subadditivity, and permutation coupling bridge theorems.

---

## Direction 1: Finite Kantorovich Duality

### Theorem Statement
For finite probability vectors μ, ν on `Fin n` and cost function c, the Wasserstein-1 distance equals the supremum of the Kantorovich dual:

W_c(μ,ν) = sup { ∑_i f(i)·(μ(i) - ν(i)) : f is 1-Lipschitz w.r.t. c }

### Lean Type Signature Sketch
```lean
def isLipschitz (c : Fin n → Fin n → ℝ) (f : Fin n → ℝ) : Prop :=
  ∀ i j, f i - f j ≤ c i j

noncomputable def kantorovichDual (c : Fin n → Fin n → ℝ) (μ ν : Fin n → ℝ) : ℝ :=
  sSup { ∑ i, f i * (μ i - ν i) | f : Fin n → ℝ, isLipschitz c f }

theorem kantorovich_duality
    (c : Fin n → Fin n → ℝ) (μ ν : Fin n → ℝ)
    (hμ : IsProbVec μ) (hν : IsProbVec ν)
    (hc : ∀ i j, 0 ≤ c i j) :
    wasserstein1 c μ ν = kantorovichDual c μ ν := by sorry
```

### Proof Strategy
1. Formulate the primal (transport) and dual (Lipschitz potentials) as finite linear programs.
2. Use LP strong duality for bounded feasible problems (both primal and dual are feasible and bounded for probability measures).
3. Alternatively, prove directly via complementary slackness on the finite polytope of transport plans.
4. The Wasserstein invariance theorem from this cycle guarantees the dual inherits the same symmetry properties.

### Cross-Domain Significance
This connects optimal transport to functional analysis (dual spaces), convex optimization (LP duality), and tropical algebra (the dual formulation involves a max/min structure that tropicalizes naturally). It would also enable computational verification of Wasserstein distances via the dual, which is often more efficient than the primal.

---

## Direction 2: Tropical Cycle-Mean = Eigenvalue Theorem (Karp's Theorem)

### Theorem Statement
For a strongly connected weighted directed graph encoded as a matrix A ∈ ℝⁿˣⁿ, the tropical eigenvalue (minimum cycle mean) equals the limit of diagonal entries:

λ(A) = lim_{k→∞} (A^{⊗k})_{ii} / k = min_{σ cycle} (weight(σ) / length(σ))

and this limit is independent of the vertex i.

### Lean Type Signature Sketch
```lean
def minCycleMean (A : Matrix (Fin n) (Fin n) ℝ) : ℝ :=
  ⨅ (k : ℕ) (hk : 0 < k), (tropPow A (k-1) i i) / k

theorem tropPow_diag_limit_exists
    [Nonempty (Fin n)]
    (A : Matrix (Fin n) (Fin n) ℝ) (i : Fin n) :
    Filter.Tendsto (fun k => tropPow A k i i / (k + 1))
      Filter.atTop (nhds (minCycleMean A)) := by sorry

theorem tropical_eigenvalue_independent_of_vertex
    [Nonempty (Fin n)]
    (A : Matrix (Fin n) (Fin n) ℝ)
    (hsc : StronglyConnected A) (i j : Fin n) :
    minCycleMean A i = minCycleMean A j := by sorry
```

### Proof Strategy
1. The subadditivity theorem `tropPow_diag_subadditive` (proved in this cycle) is the key ingredient.
2. Apply Fekete's subadditive lemma: if a_n is subadditive (a_{m+n} ≤ a_m + a_n), then lim a_n/n = inf a_n/n exists.
3. For vertex-independence, use strong connectivity: for any i, j there exist paths of bounded weight, so the diagonal sequences at different vertices differ by bounded amounts, forcing equal limits.
4. The cycle-mean characterization follows from the path interpretation of tropical powers.

### Cross-Domain Significance
This would formalize a cornerstone of combinatorial optimization and control theory. Karp's algorithm for minimum cycle means is used in timing analysis of digital circuits, scheduling theory, and performance evaluation of discrete event systems. The connection to tropical eigenvalues opens doors to nonlinear Perron-Frobenius theory.

---

## Direction 3: Birkhoff–von Neumann Decomposition

### Theorem Statement
Every doubly stochastic matrix (nonneg matrix with row and column sums equal to 1) is a convex combination of permutation matrices. Equivalently, the Birkhoff polytope is the convex hull of permutation matrices.

### Lean Type Signature Sketch
```lean
def isDoublyStochastic (M : Matrix (Fin n) (Fin n) ℝ) : Prop :=
  (∀ i j, 0 ≤ M i j) ∧
  (∀ i, ∑ j, M i j = 1) ∧
  (∀ j, ∑ i, M i j = 1)

def permMatrix (σ : Equiv.Perm (Fin n)) : Matrix (Fin n) (Fin n) ℝ :=
  fun i j => if σ i = j then 1 else 0

theorem birkhoff_von_neumann (M : Matrix (Fin n) (Fin n) ℝ)
    (hM : isDoublyStochastic M) :
    ∃ (k : ℕ) (σs : Fin k → Equiv.Perm (Fin n)) (ws : Fin k → ℝ),
      (∀ i, 0 ≤ ws i) ∧ (∑ i, ws i = 1) ∧
      M = ∑ i, ws i • permMatrix (σs i) := by sorry
```

### Proof Strategy
1. Induction on the number of nonzero entries.
2. By Hall's theorem (or direct argument), every doubly stochastic matrix has a permutation σ such that M(i, σ(i)) > 0 for all i.
3. Subtract the maximum possible weight of this permutation matrix, obtaining a smaller doubly stochastic matrix (after rescaling).
4. The process terminates because each step reduces the number of nonzero entries.
5. The permutation coupling theorem from this cycle (`permPlan_is_transportPlan`) directly connects to this: permutation plans are the extremal transport plans for uniform marginals.

### Cross-Domain Significance
This bridges convex geometry, combinatorics, and optimal transport. Every transport plan between uniform measures decomposes into permutation plans — connecting the continuous optimization view (Wasserstein) with the discrete combinatorial view (assignments). It's also the foundation for the Hungarian algorithm and linear programming over the assignment polytope.

---

## Direction 4: Wasserstein Quotient Under Finite Group Actions

### Theorem Statement
For a finite group G acting on `Fin n` by cost-preserving bijections, the Wasserstein distance descends to a well-defined metric on the quotient space of probability measures modulo G-action.

### Lean Type Signature Sketch
```lean
def GInvariantCost (G : Type*) [Group G] [MulAction G (Fin n)]
    (c : Fin n → Fin n → ℝ) : Prop :=
  ∀ (g : G) (x y : Fin n), c (g • x) (g • y) = c x y

def orbitEquiv (G : Type*) [Group G] [Fintype G] [MulAction G (Fin n)]
    (μ ν : Fin n → ℝ) : Prop :=
  ∃ g : G, pushforwardEquiv (MulAction.toEquiv g) μ = ν

theorem wasserstein_orbit_invariant
    (G : Type*) [Group G] [Fintype G] [MulAction G (Fin n)]
    (c : Fin n → Fin n → ℝ) (hc : GInvariantCost G c)
    (μ ν μ' ν' : Fin n → ℝ)
    (hμ : orbitEquiv G μ μ') (hν : orbitEquiv G ν ν') :
    wasserstein1 c μ ν = wasserstein1 c μ' ν' := by sorry
```

### Proof Strategy
1. Apply `wasserstein1_invariant_under_equiv` (proved in this cycle) for each group element's action.
2. Show that `orbitEquiv` defines an equivalence relation on probability vectors.
3. Conclude that the Wasserstein distance factors through the quotient.
4. For the metric property on the quotient, verify the triangle inequality is inherited.

### Cross-Domain Significance
This enables transport theory on symmetric spaces, orbit spaces, and configuration spaces — fundamental objects in physics (particle systems), chemistry (molecular configurations), and machine learning (invariant representations). It formalizes the principle that Wasserstein geometry respects symmetry, connecting group theory to metric geometry.

---

## Direction 5: Hungarian Algorithm Correctness via Tropical-Transport Duality

### Theorem Statement
The Hungarian algorithm correctly computes the minimum-cost assignment (and hence, for uniform measures, the Wasserstein distance restricted to permutation couplings) in O(n³) time.

### Lean Type Signature Sketch
```lean
def hungarianStep (c : Matrix (Fin n) (Fin n) ℝ)
    (u v : Fin n → ℝ) : (Fin n → ℝ) × (Fin n → ℝ) := sorry

def hungarianResult (c : Matrix (Fin n) (Fin n) ℝ) :
    Equiv.Perm (Fin n) := sorry

theorem hungarian_correct
    (c : Matrix (Fin n) (Fin n) ℝ) :
    ∀ σ : Equiv.Perm (Fin n),
      assignmentCost c (hungarianResult c) ≤ assignmentCost c σ := by sorry

theorem hungarian_eq_tropical_opt
    (c : Matrix (Fin n) (Fin n) ℝ) :
    assignmentCost c (hungarianResult c) =
    Finset.inf' Finset.univ ⟨Equiv.refl _, Finset.mem_univ _⟩
      (fun σ => assignmentCost c σ) := by sorry
```

### Proof Strategy
1. Define the dual variables (potentials) u, v as in the standard Hungarian method.
2. Prove complementary slackness: if u(i) + v(j) ≤ c(i,j) for all i,j and equality holds on the assignment edges, then the assignment is optimal.
3. Show the algorithm maintains dual feasibility and achieves complementary slackness at termination.
4. The `permPlan_transportCost` theorem from this cycle connects assignment costs to transport costs, linking this to Wasserstein computation.
5. The tropical multiplication structure provides the algebraic framework: the Hungarian algorithm is essentially computing the tropical permanent.

### Cross-Domain Significance
This would be a landmark in verified algorithm correctness — connecting the theoretical framework (transport, tropical algebra) to a concrete, widely-used algorithm. Applications span logistics, resource allocation, bipartite matching in computer vision, and network flow optimization. The tropical viewpoint reveals that the Hungarian algorithm is performing iterated tropical operations, unifying the algorithmic and algebraic perspectives.

---

## Research Program Summary

These five directions form a coherent program:

1. **Kantorovich duality** completes the primal-dual picture for transport.
2. **Karp's theorem** completes the spectral picture for tropical algebra.
3. **Birkhoff-von Neumann** bridges the polytope/convex geometry between the two.
4. **Wasserstein quotients** extends the invariance theorem to full group-theoretic generality.
5. **Hungarian algorithm** grounds everything in verified computation.

Together, they would establish a formally verified interface between metric geometry, combinatorial optimization, and idempotent algebra — demonstrating that transport minimization and tropical minimization are indeed manifestations of one unified formal optimization language.
