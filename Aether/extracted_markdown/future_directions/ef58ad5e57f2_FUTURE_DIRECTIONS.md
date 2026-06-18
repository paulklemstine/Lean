# Future Directions: Tropical Surgery and Spectral Perturbation Theory

This document outlines concrete next steps building on the rank-2 tropical spectral monotonicity theorem. Each direction includes a precise target theorem, breakthrough potential, proof strategy, and cross-domain applications.

---

## Direction 1: Tropical Interlacing for k-Edge Surgery

### Target Theorem
For an n×n min-plus matrix A, define k-edge surgery as modifying at most k entries:
```
B(i,j) = min(A(i,j), c_{i,j}) for (i,j) ∈ S with |S| ≤ k
B(i,j) = A(i,j) otherwise
```

**Conjecture (Tropical k-Interlacing).** Let λ₁ ≤ λ₂ ≤ ⋯ ≤ λₙ be the cycle means of all simple cycles of A (sorted), and μ₁ ≤ ⋯ ≤ μₙ the cycle means of B. Then:
```
μᵢ ≤ λᵢ for all i, and
μᵢ ≥ λ_{i+k} for all i ≤ n-k
```

### Why It Would Be a Breakthrough
Classical Cauchy interlacing controls how eigenvalues shift under rank-k perturbations. A tropical analogue would give *quantitative* control over the entire cycle mean spectrum under bounded surgery, not just the minimum. This would enable multi-objective optimization in scheduling and routing.

### Proof Strategy
1. Prove the k=1 case by analyzing how a single-entry decrease affects individual cycles.
2. Compose k single-entry results using the idempotency of min.
3. The lower bound μᵢ ≥ λ_{i+k} requires showing that at most k cycles can have their means decreased below any threshold — this follows from a pigeonhole argument on edge-disjoint cycles.

### Cross-Domain Impact
- **Manufacturing:** Multi-bottleneck analysis. Upgrading k connections shifts at most k critical cycles.
- **Network design:** QoS guarantees for multi-path routing under k link upgrades.
- **Tropical geometry:** Structural result on tropical hypersurface deformation.

---

## Direction 2: Critical Graph Invariance Theorem

### Target Theorem
Define the *critical graph* G*(A) as the subgraph consisting of all edges appearing in cycles achieving the minimum cycle mean.

**Theorem (Critical Graph Stability).** Let B be obtained from A by k-edge surgery on edges *not in G*(A)*, and suppose the surgery values satisfy:
```
For all (i,j) ∈ S: c_{i,j} ≥ ρ(A) · k_{i,j} - (total weight of rest of any cycle through (i,j))
```
where k_{i,j} is the length of the shortest cycle through (i,j). Then:
```
ρ(B) = ρ(A) and G*(B) = G*(A)
```

### Why It Would Be a Breakthrough
This would show that the tropical eigenvalue and its geometric certificate (the critical graph) are stable under sufficiently mild surgery away from the critical region. This is the tropical analogue of eigenvalue stability under perturbations orthogonal to the eigenspace.

### Proof Strategy
1. The ≤ direction follows from monotonicity (already proved).
2. For the ≥ direction, show that all critical cycles of A are also cycles of B with unchanged weight (since surgery avoids their edges).
3. Show that no non-critical cycle of A becomes critical under surgery, using the quantitative condition on surgery values.
4. Formalize this using the existing `closedWalkWeight` and `cycleMean` machinery.

### Cross-Domain Impact
- **Control theory:** Certified robustness of discrete event system throughput under parameter perturbation.
- **Tropical geometry:** Stability of the tropical eigenspace under deformations.
- **Algorithm design:** Incremental update algorithms that avoid recomputing ρ when changes are off-critical.

---

## Direction 3: Tropical Sherman-Morrison Principle

### Target Theorem
For rank-1 surgery (single outer product), seek a closed-form expression:

**Conjecture.** For B(i,j) = min(A(i,j), u(i) + v(j)):
```
ρ(B) = min(ρ(A), min over simple cycles C of (W_A(C) + Δ(C, u, v)) / |C|)
```
where Δ(C, u, v) accounts for the weight change on edges of C that are affected by surgery.

More precisely, if C = (i₀, i₁, ..., i_{k-1}, i₀), then:
```
Δ(C, u, v) = Σ_{t: u(iₜ)+v(i_{t+1}) < A(iₜ, i_{t+1})} (u(iₜ) + v(i_{t+1}) - A(iₜ, i_{t+1}))
```

### Why It Would Be a Breakthrough
The Sherman-Morrison formula in classical algebra gives an *exact* expression for the inverse of a rank-1 update. A tropical analogue would give an *exact* spectral radius, not just a bound. This would enable O(n²) spectral updates (vs O(n³) for recomputation), transforming iterative optimization algorithms.

### Proof Strategy
1. Enumerate simple cycles that could become critical under surgery.
2. For each such cycle, compute the new cycle mean exactly.
3. Show that the minimum over all such modified cycle means equals ρ(B).
4. The key difficulty is showing that non-simple cycles don't achieve the minimum — this uses a decomposition argument showing that any non-simple cycle can be split into simple cycles, one of which has mean ≤ the original.

### Cross-Domain Impact
- **Optimization:** Fast incremental updates for parametric shortest-path algorithms.
- **Machine learning:** Efficient tropical neural network parameter sensitivity analysis.
- **Control:** Real-time spectral monitoring in discrete event systems with changing parameters.

---

## Direction 4: Algorithmic Sensitivity Certificates

### Target Theorem
**Theorem (Certified Sensitivity).** There exists an O(n³)-time algorithm that, given a matrix A and a surgery specification (S, c), produces:
1. The exact value ρ(B).
2. A *certificate*: a cycle σ* witnessing ρ(B) = cycleMean(B, σ*).
3. A *sensitivity vector*: for each (i,j) ∈ S, the marginal effect ∂ρ/∂c_{i,j}.

### Why It Would Be a Breakthrough
This converts the formal theorem into an *executable verified algorithm*. The certificate can be independently checked in O(n) time, providing trust even when the algorithm implementation is complex. The sensitivity vector enables gradient-based optimization of surgery parameters.

### Proof Strategy
1. Modify Karp's algorithm to track the critical cycle and its interaction with surgery edges.
2. The sensitivity ∂ρ/∂c_{i,j} is either 0 (if the critical cycle doesn't use edge (i,j)) or 1/|C*| (if it does), where C* is the critical cycle.
3. Formalize the algorithm in Lean 4 as a computable function with a correctness proof.
4. Use `@[csimp]` to provide an efficient implementation verified against the specification.

### Cross-Domain Impact
- **Network operations:** Real-time capacity planning with formal guarantees.
- **Verified software:** Certified scheduling algorithms for safety-critical systems (avionics, railway interlocking).
- **Optimization:** Interior-point methods for tropical linear programming with certified feasibility.

---

## Direction 5: Tropical Control Synthesis via Surgery

### Target Theorem
**Problem.** Given a min-plus system matrix A and a target spectral radius ρ_target < ρ(A), find the minimum-cost rank-2 surgery achieving ρ(B) ≤ ρ_target.

**Theorem (Surgery Synthesis).** The optimal surgery can be computed in polynomial time when the cost function is linear in the surgery parameters, and the formulated optimization problem is:
```
minimize  Σ_{i,j} cost(i,j) · max(0, A(i,j) - B(i,j))
subject to  ρ(B) ≤ ρ_target
            B(i,j) = min(A(i,j), u(i)+v(j), u'(i)+v'(j))
```

### Why It Would Be a Breakthrough
This transforms the spectral monotonicity theorem from a *passive* bound into an *active* design tool. Given a performance target, it automatically synthesizes the cheapest two-template upgrade. This is directly applicable to infrastructure planning, network design, and production system optimization.

### Proof Strategy
1. Reformulate as a parametric min-plus linear program in (u, v, u', v').
2. Show that the feasible set {(u,v,u',v') : ρ(B) ≤ ρ_target} is a tropical polyhedron.
3. Exploit the rank-2 structure to decompose into two independent rank-1 problems, each solvable in O(n³) time.
4. The key insight: the explicit bound (Theorem 6.1) provides sufficient conditions that are individually optimizable.

### Cross-Domain Impact
- **Infrastructure planning:** Optimal highway/railway expansion with guaranteed throughput improvement.
- **Manufacturing:** Minimum-cost equipment upgrades with certified cycle time reduction.
- **Telecommunications:** Optimal link capacity allocation with worst-case latency guarantees.

---

## Research Program Summary

| Direction | Difficulty | Impact | Dependencies |
|-----------|-----------|--------|--------------|
| 1. Tropical interlacing | Medium-Hard | High | Current work |
| 2. Critical graph invariance | Medium | High | Current work |
| 3. Sherman-Morrison | Hard | Very High | Direction 2 |
| 4. Sensitivity certificates | Medium | High | Current work |
| 5. Control synthesis | Hard | Very High | Directions 1, 4 |

The recommended order is: 2 → 4 → 1 → 3 → 5. Direction 2 (critical graph invariance) provides the conceptual foundation, Direction 4 (certificates) provides the algorithmic framework, and the remaining directions build on these.

---

## Team Directive

Each direction should be pursued by a team with:
- **Hypothesis formulation:** State the precise conjecture with edge cases.
- **Computational validation:** Test on random instances (n = 3 to 100) before formalizing.
- **Formal proof:** Lean 4 formalization building on the existing `Tropical/Surgery.lean` infrastructure.
- **Algorithm implementation:** Python/Julia prototypes for computational experiments.
- **Cross-domain validation:** At least one worked application example per theorem.
- **Iteration:** If a conjecture fails, analyze the counterexample and refine the statement.

The existing codebase provides all necessary infrastructure:
- Definitions: `tropicalRankTwoSurgery`, `closedWalkWeight`, `cycleMean`, `tropicalSpectralRadius`
- Core lemmas: `closedWalkWeight_mono`, `cycleMean_mono`, `tropicalSpectralRadius_mono`
- Main theorems: `tropicalRankTwoSurgery_spectral_bound`, `tropicalRankTwoSurgery_explicit_bound`
- Algebraic tools: `tropical_add_min_left`, `tropical_add_min_right`, `tropicalRankTwoSurgery_idem`
