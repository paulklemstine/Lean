# Future Directions: Tropical Surgery and Spectral Perturbation Theory

## Overview

The rank-2 tropical surgery spectral monotonicity theorem establishes the foundation for a systematic tropical perturbation theory. Below are five concrete next steps, each with precise theorem statements, breakthrough potential, proof strategies, and cross-domain impact.

---

## Direction 1: Tropical Interlacing for k-Edge Surgery

### Precise Theorem Statement

**Conjecture (k-Edge Tropical Interlacing).** Let $A \in \mathbb{R}^{n \times n}$ and let $B$ be obtained from $A$ by decreasing at most $k$ entries. Let $\lambda_1 \leq \lambda_2 \leq \cdots \leq \lambda_n$ be the "tropical eigenvalues" of $A$ (cycle means of critical cycles, ordered) and $\mu_1 \leq \cdots \leq \mu_n$ those of $B$. Then:
$$\mu_i \leq \lambda_i \leq \mu_{i+k} \quad \text{for appropriate index ranges}$$

```lean
theorem tropical_interlacing_k_surgery
    {n k : ℕ} (A B : Fin (n+1) → Fin (n+1) → ℝ)
    (hle : ∀ i j, B i j ≤ A i j)
    (hsupp : Finset.card (surgerySupport_fin A B) ≤ k) :
    ∀ i, tropicalEigenvalue B i ≤ tropicalEigenvalue A i := by sorry
```

### Why It Would Be a Breakthrough

Classical interlacing theorems (Cauchy, Poincaré) are among the most powerful tools in spectral graph theory. A tropical analogue would:
- Provide tight eigenvalue bounds under localized perturbations
- Enable tropical analogues of spectral partitioning algorithms
- Connect to tropical Hodge theory via eigenvalue deformation

### Proof Strategy

1. Define "tropical eigenvalues" as the ordered sequence of critical cycle means
2. Show that k-edge surgery can destroy at most k critical cycles
3. Use a combinatorial argument relating surviving critical cycles to interlacing bounds
4. Verify computationally on small dimensions before generalizing

### Cross-Domain Impact

- **Graph algorithms**: Tight bounds on how k edge modifications affect optimal routing
- **Control theory**: Quantitative robustness certificates for k-parameter perturbations
- **Algebraic geometry**: Tropical analogue of eigenvalue deformation in algebraic families

---

## Direction 2: Critical Graph Invariance Theorem

### Precise Theorem Statement

**Conjecture (Critical Graph Invariance).** Let $G^*(A)$ denote the critical graph of $A$ (the union of all edges appearing in cycles achieving the minimum cycle mean). If $B \leq A$ entrywise and $B(i,j) = A(i,j)$ for all $(i,j)$ in $G^*(A)$, then:
$$\rho(B) = \rho(A)$$
and moreover the critical graph $G^*(B) \supseteq G^*(A)$.

```lean
def criticalGraph {n : ℕ} (A : Fin (n+1) → Fin (n+1) → ℝ) :
    Set (Fin (n+1) × Fin (n+1)) :=
  {e | ∃ k σ, cycleMean A (Nat.succ_pos k) σ = tropicalSpectralRadius A ∧
    ∃ t, e = (σ t, σ ⟨(t.val+1) % (k+1), Nat.mod_lt _ (Nat.succ_pos k)⟩)}

theorem critical_graph_invariance
    {n : ℕ} (A B : Fin (n+1) → Fin (n+1) → ℝ)
    (hle : ∀ i j, B i j ≤ A i j)
    (hcrit : ∀ e ∈ criticalGraph A, B e.1 e.2 = A e.1 e.2) :
    tropicalSpectralRadius B = tropicalSpectralRadius A := by sorry
```

### Why It Would Be a Breakthrough

This would be the definitive tropical analogue of "perturbations orthogonal to the eigenspace don't change the eigenvalue." It identifies exactly when surgery is spectrally invisible, providing:
- Sharp necessary and sufficient conditions for spectral preservation
- The foundation for tropical eigenspace perturbation theory
- A bridge to tropical algebraic geometry (stability of tropical varieties)

### Proof Strategy

1. Formalize the critical graph as the union of edges on optimal cycles
2. Show that if B = A on all critical edges, then every optimal cycle of A has the same weight in B
3. Show that no new cycle in B can have a lower mean than ρ(A), using the fact that any such cycle must use a non-critical edge of A where B might be smaller, but this alone cannot create a cycle mean below ρ(A)
4. The key subtlety: a new cycle might combine critical and non-critical edges. Need to show that the non-critical edges' decrease is offset by the critical edges' contribution

### Cross-Domain Impact

- **Network optimization**: Identify which edges are "safe to modify" without affecting system performance
- **Manufacturing**: Determine which machine upgrades will actually impact throughput
- **Tropical geometry**: Characterize stability locus of tropical hypersurfaces

---

## Direction 3: Tropical Sherman–Morrison Principle

### Precise Theorem Statement

**Conjecture (Tropical Sherman–Morrison).** For a single-entry surgery $B = A$ with $B(p,q) = \min(A(p,q), c)$:
$$\rho(B) = \min\left(\rho(A),\; \min_{\text{cycles through } (p,q)} \frac{W(A,\sigma) - A(p,q) + c}{|\sigma|}\right)$$

In other words, the new spectral radius is determined by the old spectral radius and the cycle means of cycles through the modified edge, with the old edge weight replaced by the new one.

```lean
theorem tropical_sherman_morrison_single_entry
    {n : ℕ} (A : Fin (n+1) → Fin (n+1) → ℝ)
    (p q : Fin (n+1)) (c : ℝ) (hc : c ≤ A p q) :
    tropicalSpectralRadius (Function.update₂ A p q c) =
      min (tropicalSpectralRadius A)
        (⨅ σ ∈ cyclesThroughEdge p q,
          (closedWalkWeight A σ - A p q + c) / σ.length) := by sorry
```

### Why It Would Be a Breakthrough

The Sherman-Morrison formula is one of the most used results in numerical linear algebra, enabling efficient rank-1 updates to matrix inverses. A tropical analogue would:
- Enable O(n²) spectral radius updates instead of O(n³) recomputation
- Provide exact formulas rather than bounds
- Open the door to tropical resolvent theory

### Proof Strategy

1. Partition all cycles into those that use edge (p,q) and those that don't
2. Cycles not using (p,q) have unchanged cycle means → their minimum is still ρ(A) if they were critical
3. Cycles using (p,q) have their weight decreased by (A(p,q) - c) → compute new cycle means
4. The new spectral radius is the minimum over both groups

### Cross-Domain Impact

- **Algorithms**: Efficient incremental shortest-path updates
- **Control**: Real-time spectral radius tracking under single-parameter changes
- **Online optimization**: Streaming tropical spectral computations

---

## Direction 4: Algorithmic Sensitivity Certificates

### Precise Theorem Statement

**Conjecture (Polynomial Sensitivity Certificate).** There exists a polynomial-time algorithm that, given $A \in \mathbb{R}^{n \times n}$ and edge $(p,q)$, computes:
1. The maximum decrease $\delta^*$ such that $\rho(B) = \rho(A)$ when $B(p,q) = A(p,q) - \delta$ and $B = A$ elsewhere
2. The rate of change $d\rho/d\delta$ at $\delta = 0$

```lean
-- Executable sensitivity certificate
def spectralSensitivity {n : ℕ} (A : Fin (n+1) → Fin (n+1) → ℝ)
    (p q : Fin (n+1)) : ℝ × ℝ :=
  -- Returns (max safe decrease, sensitivity)
  sorry

theorem spectralSensitivity_correct {n : ℕ}
    (A : Fin (n+1) → Fin (n+1) → ℝ) (p q : Fin (n+1)) :
    let (δ_star, rate) := spectralSensitivity A p q
    ∀ δ ≤ δ_star,
      tropicalSpectralRadius (Function.update₂ A p q (A p q - δ)) =
        tropicalSpectralRadius A := by sorry
```

### Why It Would Be a Breakthrough

Moving from existential theorems to executable algorithms with certified correctness is the key step toward practical impact. This would:
- Enable real-time sensitivity analysis in network optimization
- Provide the first certified tropical sensitivity solver
- Bridge formal verification and combinatorial optimization

### Proof Strategy

1. Use Karp's algorithm to find the critical graph G*(A)
2. If (p,q) ∉ G*(A), then δ* = A(p,q) - (minimum cycle mean through (p,q)) and sensitivity = 0
3. If (p,q) ∈ G*(A), then δ* = 0 and sensitivity = (frequency of (p,q) in critical cycles) / (critical cycle length)
4. Formalize the algorithm and prove correctness using critical graph characterization

### Cross-Domain Impact

- **Network engineering**: Certified robustness analysis for communication networks
- **Supply chain**: Quantify impact of disruptions on production cycle times
- **Formal methods**: Verified optimization algorithms

---

## Direction 5: Tropical Control Synthesis via Surgery

### Precise Theorem Statement

**Conjecture (Optimal Two-Edge Control).** Given $A \in \mathbb{R}^{n \times n}$ and a target spectral radius $\lambda < \rho(A)$, the problem of finding $(p_1, q_1, c_1, p_2, q_2, c_2)$ minimizing total cost $|A(p_1,q_1) - c_1| + |A(p_2,q_2) - c_2|$ subject to $\rho(\text{twoEntry}(A, p_1, q_1, c_1, p_2, q_2, c_2)) \leq \lambda$ is solvable in polynomial time.

```lean
-- Optimal two-edge control synthesis
noncomputable def optimalTwoEdgeControl {n : ℕ}
    (A : Fin (n+1) → Fin (n+1) → ℝ) (target : ℝ) :
    Option (Fin (n+1) × Fin (n+1) × ℝ × Fin (n+1) × Fin (n+1) × ℝ) :=
  sorry

theorem optimalTwoEdgeControl_achieves_target {n : ℕ}
    (A : Fin (n+1) → Fin (n+1) → ℝ) (target : ℝ)
    (h : ∃ i₁ j₁ c₁ i₂ j₂ c₂,
      tropicalSpectralRadius (twoEntrySurgery A i₁ j₁ i₂ j₂ c₁ c₂) ≤ target) :
    ∃ result, optimalTwoEdgeControl A target = some result ∧
      tropicalSpectralRadius (twoEntrySurgery A result.1 result.2.1 result.2.2.1
        result.2.2.2.1 result.2.2.2.2.1 result.2.2.2.2.2) ≤ target := by sorry
```

### Why It Would Be a Breakthrough

This moves tropical surgery from analysis to synthesis: not just predicting the effect of surgery, but *designing* optimal surgeries. This would:
- Solve a fundamental optimization problem in discrete event systems
- Enable automated network design under spectral constraints
- Connect tropical algebra to mathematical programming

### Proof Strategy

1. Enumerate all pairs of edges as candidate surgery locations (O(n⁴) pairs)
2. For each pair, use the Tropical Sherman-Morrison principle to compute the minimum cost achieving the target
3. Select the minimum-cost pair
4. Prove that this brute-force search can be accelerated using critical graph structure

### Cross-Domain Impact

- **Manufacturing optimization**: Design minimal-cost machine upgrades to hit throughput targets
- **Network design**: Optimal link upgrades under budget constraints
- **Control theory**: Min-cost control input selection for tropical linear systems

---

## Summary Table

| Direction | Difficulty | Impact | Dependencies |
|-----------|-----------|--------|-------------|
| 1. k-Edge Interlacing | Hard | Very High | Tropical eigenvalue ordering |
| 2. Critical Graph Invariance | Medium-Hard | Very High | Critical graph formalization |
| 3. Sherman-Morrison | Medium | High | Single-entry analysis |
| 4. Sensitivity Certificates | Medium | High | Directions 2-3 |
| 5. Control Synthesis | Hard | Very High | Directions 3-4 |

Each direction builds on the spectral monotonicity foundation established in this work. The recommended pursuit order is: 2 → 3 → 4 → 1 → 5, as each provides tools for the next.

---

## Team Directive

Create a team to:
1. **Formalize** the critical graph definition and prove Direction 2
2. **Implement** the tropical Sherman-Morrison formula (Direction 3) and test on large matrices
3. **Develop** certified sensitivity algorithms (Direction 4) with executable code
4. **Investigate** the interlacing conjecture (Direction 1) via computational experiments
5. **Prototype** the control synthesis algorithm (Direction 5) for discrete event systems

Each team member should maintain a feedback loop between formal proofs and computational experiments. Use the existing Lean formalization as the foundation, extending it module by module.
