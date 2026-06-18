# Future Directions: Tropical Surgery and Spectral Perturbation Theory

## Team Directive

Create a team to conduct research, brainstorm hypotheses, run experiments, validate data, update knowledge base and iterate. Each direction below includes specific hypotheses, proof strategies, and cross-domain connections.

---

## Direction 1: Tropical Interlacing for k-Edge Surgery

### Precise theorem statement

**Conjecture.** Let A be an (n+1)×(n+1) tropical matrix and let B be obtained by taking the entrywise minimum of A with k rank-one outer products:

```
B(i,j) = min(A(i,j), min_{ℓ=1..k} (u_ℓ(i) + v_ℓ(j)))
```

Then:
```
ρ(B) ≤ ρ(A)
```
and moreover, for the sequence of "partial surgery" matrices B_1, B_2, ..., B_k defined by cumulatively adding one rank-one template at a time:
```
ρ(B_k) ≤ ρ(B_{k-1}) ≤ ... ≤ ρ(B_1) ≤ ρ(A)
```

```lean
theorem tropical_rankK_surgery_interlacing {n k : ℕ}
    (A : Fin (n+1) → Fin (n+1) → ℝ)
    (U V : Fin k → Fin (n+1) → ℝ) :
    -- Partial surgeries are spectrally monotone
    ∀ m : Fin k, tropicalSpectralRadius (partialSurgery A U V (m+1))
      ≤ tropicalSpectralRadius (partialSurgery A U V m) := by sorry
```

### Why this would be a breakthrough

This would be the first **tropical interlacing theorem**, analogous to the classical Cauchy interlacing theorem for eigenvalues of bordered matrices. It would establish that adding rank-one components to surgery produces a monotone chain of spectral radii, opening the door to bounding spectral changes by counting the "rank" of the perturbation.

### Plausible proof strategy

The base case (k=1) follows from our existing monotonicity theorem. For the induction step, observe that adding one more rank-one template to an existing surgery only decreases entries further, so the entrywise monotonicity argument applies directly. The key insight is that `partialSurgery A U V (m+1)` is obtained by surgery on `partialSurgery A U V m`, so the induction is immediate.

### Cross-domain impact

- **Optimization**: Provides a framework for *incremental* network optimization — add one improvement at a time, with certified spectral bounds at each step.
- **Approximation algorithms**: The interlacing chain gives a certificate of the "marginal value" of each rank-one component.
- **Tropical geometry**: Connects to the stratification of tropical linear spaces by rank.

---

## Direction 2: Critical Graph Invariance Theorem

### Precise theorem statement

**Conjecture.** Let A be an irreducible (n+1)×(n+1) tropical matrix with critical graph G*(A). Let B = tropicalRankTwoSurgery(A, u, v, u', v'). If the surgery support S = {(i,j) : B(i,j) < A(i,j)} is disjoint from the edge set of G*(A), then:

1. ρ(B) = ρ(A) (spectral invariance — already partially proved)
2. G*(B) ⊇ G*(A) (critical graph containment)
3. The tropical eigenvector of B restricted to nodes of G*(A) equals the tropical eigenvector of A (eigenvector stability)

```lean
theorem critical_graph_invariance {n : ℕ}
    {A B : Fin (n+1) → Fin (n+1) → ℝ}
    (hle : ∀ i j, B i j ≤ A i j)
    (hcrit : ∀ (i j : Fin (n+1)),
      isCriticalEdge A i j → B i j = A i j) :
    tropicalSpectralRadius B = tropicalSpectralRadius A ∧
    (∀ i j, isCriticalEdge A i j → isCriticalEdge B i j) := by sorry
```

### Why this would be a breakthrough

This would establish that the critical graph — the combinatorial core of the spectral theory — is *stable* under off-support surgery. This is the tropical analogue of the classical result that eigenspaces are stable under perturbations that preserve the eigenspace.

### Plausible proof strategy

Part (1) follows from our existing spectral equality criterion. For part (2), note that any critical cycle of A uses only edges where B = A, so its cycle mean in B equals ρ(A) = ρ(B), making it critical for B as well. Part (3) requires showing that the tropical eigenvector equation A ⊗ x = ρ ⊗ x, when restricted to critical nodes, depends only on critical edges.

### Cross-domain impact

- **Discrete event systems**: Guarantees that system modifications outside the bottleneck cycle preserve the bottleneck structure, enabling targeted optimization.
- **Tropical geometry**: Connects to the stability of tropical varieties under deformation.
- **Network design**: Provides certificates for "safe" modifications that don't change system-critical paths.

---

## Direction 3: Tropical Sherman–Morrison Principle

### Precise theorem statement

**Conjecture.** For a rank-1 tropical surgery B(i,j) = min(A(i,j), u(i) + v(j)), there exists a closed-form expression:

```
ρ(B) = min(ρ(A), min over critical cycles C of B
           that use at least one surgery edge of μ(B, C))
```

More precisely, the spectral radius of B equals the minimum of ρ(A) and the minimum cycle mean over cycles that use at least one edge from the surgery support.

```lean
theorem tropical_sherman_morrison {n : ℕ}
    (A : Fin (n+1) → Fin (n+1) → ℝ)
    (u v : Fin (n+1) → ℝ) :
    tropicalSpectralRadius (fun i j => min (A i j) (u i + v j)) =
    min (tropicalSpectralRadius A)
        (infCycleMeanUsingSurgeryEdge A u v) := by sorry
```

### Why this would be a breakthrough

The classical Sherman-Morrison formula gives an explicit expression for the inverse of a rank-1 update of a matrix. A tropical analogue would provide an explicit formula for the spectral radius change, enabling O(n²) spectral updates instead of O(n³) recomputation.

### Plausible proof strategy

1. Show that optimal cycles for B either (a) avoid the surgery support (giving cycle mean = ρ(A)) or (b) use at least one surgery edge.
2. For case (b), characterize the cycle means using the structure of the rank-one template.
3. Combine via a min to get the closed-form expression.

The key difficulty is characterizing cycles that "partially" use the surgery template — some edges from A, some from u⊕v.

### Cross-domain impact

- **Algorithms**: Enables incremental spectral radius computation for dynamic graphs, with potential for subquadratic update complexity.
- **Control theory**: Provides explicit formulas for sensitivity coefficients in min-plus control systems.
- **Weighted automata**: Enables efficient cost analysis under transition modifications.

---

## Direction 4: Algorithmic Sensitivity Certificates

### Precise theorem statement

**Theorem (target).** Given an n×n tropical matrix A and a set of k edge perturbations, there exists an algorithm that:

1. Computes ρ(B) in O(n³) time (using Karp's or Howard's algorithm).
2. Produces a *sensitivity certificate*: a compact witness (optimal cycle + critical graph) of size O(n) that certifies ρ(B) = claimed value.
3. Determines in O(n²) time whether the perturbation is off-critical (ρ(B) = ρ(A)).

```lean
def spectralSensitivityCertificate {n : ℕ}
    (A : Fin (n+1) → Fin (n+1) → ℝ)
    (perturbations : List (Fin (n+1) × Fin (n+1) × ℝ)) :
    { cert : SensitivityCert n //
      cert.verifies (applyPerturbations A perturbations) } := by sorry
```

### Why this would be a breakthrough

Certified sensitivity analysis would enable *verifiable* optimization of large-scale networks — a requirement in safety-critical applications (transportation, manufacturing, infrastructure planning).

### Plausible proof strategy

1. Compute the critical graph of A in O(n³) time using Karp's algorithm plus cycle identification.
2. Check whether any perturbed edge intersects the critical graph (O(k·n) time).
3. If not, certificate = critical cycle of A (unchanged). If so, recompute using Karp's algorithm on B.
4. Formalize the certificate verification as a polynomial-time checkable predicate.

### Cross-domain impact

- **Formal methods**: Connects to certified algorithms and proof-carrying code.
- **Infrastructure**: Enables verified sensitivity analysis for transportation and logistics networks.
- **Real-time systems**: Supports online reoptimization with certified guarantees.

---

## Direction 5: Tropical Control Synthesis via Surgery

### Precise theorem statement

**Problem.** Given a min-plus linear system x(k+1) = A ⊗ x(k) with tropical spectral radius ρ(A), find vectors u, v, u', v' minimizing ρ(B) where B = tropicalRankTwoSurgery(A, u, v, u', v'), subject to resource constraints ‖u‖ + ‖v‖ + ‖u'‖ + ‖v'‖ ≤ budget.

**Conjecture.** The optimal surgery vectors concentrate their "mass" on the critical graph: the optimal u, v target edges of the critical cycle.

```lean
theorem optimal_surgery_on_critical_graph {n : ℕ}
    (A : Fin (n+1) → Fin (n+1) → ℝ)
    (budget : ℝ) (hbudget : budget > 0) :
    ∃ u v u' v' : Fin (n+1) → ℝ,
      surgeryResourceCost u v u' v' ≤ budget ∧
      ∀ u₂ v₂ u₂' v₂', surgeryResourceCost u₂ v₂ u₂' v₂' ≤ budget →
        tropicalSpectralRadius (tropicalRankTwoSurgery A u v u' v') ≤
        tropicalSpectralRadius (tropicalRankTwoSurgery A u₂ v₂ u₂' v₂') := by sorry
```

### Why this would be a breakthrough

This would create a new field of **tropical control synthesis** — designing optimal modifications to min-plus systems. Current approaches to optimizing discrete event systems are largely heuristic; a rigorous framework based on surgery would provide certifiable optimality guarantees.

### Plausible proof strategy

1. Use the explicit bound (Theorem 5.1) to reduce the optimization to minimizing min_i(u_i + v_i) under resource constraints.
2. Show that for rank-one surgery, the optimal vectors concentrate on the critical cycle by a combinatorial exchange argument.
3. Extend to rank-2 using the sequential interlacing structure (Direction 1).

### Cross-domain impact

- **Manufacturing**: Optimal scheduling and throughput improvement with budget constraints.
- **Transportation**: Resource allocation for road/rail network improvements.
- **Telecommunications**: Optimal routing under delay constraints.
- **Operations research**: A new class of network design problems with algebraic structure.
