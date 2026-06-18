# Future Directions: Tropical Gauge Reduction Theory

This document outlines five concrete next steps opened by the charged tropical reweighting theorem. Each direction includes an exact mathematical statement, a proposed type signature, a proof strategy, and cross-domain significance.

---

## 1. Charged Value Iteration Equivalence (Convergence)

**Statement.** If `Φ₀` is an initial value field and the sequence `Φₖ₊₁ = maxwellBellmanOp W A q Φₖ` converges pointwise, then the limit equals the limit of `Φₖ₊₁ = bellmanOp (chargedWeight W A q) Φₖ` with the same initial condition.

**Lean type signature:**
```lean
theorem charged_value_iteration_limit {n : ℕ}
    (W A : Matrix (Fin n) (Fin n) ℝ) (q : ℝ)
    (Φ₀ : Fin n → ℝ)
    (hconv : ∀ i, Filter.Tendsto (fun k => ((maxwellBellmanOp W A q)^[k] Φ₀) i)
      Filter.atTop (nhds (Φ_limit i))) :
    ∀ i, Filter.Tendsto (fun k => ((bellmanOp (chargedWeight W A q))^[k] Φ₀) i)
      Filter.atTop (nhds (Φ_limit i))
```

**Proof strategy.** This is an immediate corollary of `iterate_maxwellBellmanOp_eq`, which shows all iterates are literally equal. The limits are therefore identical by uniqueness of limits.

**Cross-domain significance.**
- *Reinforcement learning*: Establishes that value iteration under charged rewards converges to the same value function regardless of which operator formulation is used.
- *Control theory*: Guarantees that Hamilton–Jacobi–Bellman solvers can use the simpler uncharged operator with modified costs.

---

## 2. Monotonicity of the Bellman Operator in Charge

**Statement.** If `A(i,j) ≥ 0` for all `i, j` and `q₁ ≤ q₂`, then `bellmanOp (chargedWeight W A q₁) Φ i ≤ bellmanOp (chargedWeight W A q₂) Φ i` for all `i`.

**Lean type signature:**
```lean
theorem bellmanOp_charged_mono {n : ℕ} [NeZero n]
    (W A : Matrix (Fin n) (Fin n) ℝ) (hA : ∀ i j, 0 ≤ A i j)
    {q₁ q₂ : ℝ} (hq : q₁ ≤ q₂) (Φ : Fin n → ℝ) (i : Fin n) :
    bellmanOp (chargedWeight W A q₁) Φ i ≤ bellmanOp (chargedWeight W A q₂) Φ i
```

**Proof strategy.** Use `ciSup_le_ciSup` with the bounding argument that for each `j`, `chargedWeight W A q₁ i j + Φ j ≤ chargedWeight W A q₂ i j + Φ j` via `chargedWeight_mono_charge` and `add_le_add_right`. Requires `BddAbove` which holds for finite types.

**Cross-domain significance.**
- *Response theory*: Establishes that increasing the coupling charge `q` monotonically increases the value function — a tropical analog of linear response in statistical mechanics.
- *Robust optimization*: Provides formal monotonicity guarantees for cost perturbations, central to sensitivity analysis.

---

## 3. Charged Tropical Eigenproblem Reduction

**Statement.** Define the tropical eigenvalue problem as: find `λ ∈ ℝ` and `Φ : Fin n → ℝ` (not identically -∞) such that `bellmanOp W Φ = fun i => λ + Φ i`. Then the charged tropical eigenvalue of `(W, A, q)` equals the standard tropical eigenvalue of `chargedWeight W A q`.

**Lean type signature:**
```lean
def IsTropicalEigenvalue {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ) (λ_ : ℝ) : Prop :=
  ∃ Φ : Fin n → ℝ, bellmanOp W Φ = fun i => λ_ + Φ i

theorem charged_tropical_eigenvalue_iff {n : ℕ}
    (W A : Matrix (Fin n) (Fin n) ℝ) (q : ℝ) (λ_ : ℝ) :
    IsTropicalEigenvalue (chargedWeight W A q) λ_ ↔
      ∃ Φ : Fin n → ℝ, maxwellBellmanOp W A q Φ = fun i => λ_ + Φ i
```

**Proof strategy.** Direct substitution using `maxwellBellmanOp_eq_bellmanOp_charged`. The eigenvector condition under the Maxwell operator is literally the eigenvector condition under the charged Bellman operator by our main theorem.

**Cross-domain significance.**
- *Max-plus spectral theory*: The tropical eigenvalue equals the maximum cycle mean of the weighted graph. This theorem says charged cycle means reduce to ordinary cycle means on the reweighted graph — a computationally useful reduction.
- *Discrete gauge theory*: A tropical analog of the fact that gauge transformations preserve the spectrum.

---

## 4. Policy / Argmax Transfer Theorem

**Statement.** The set of optimal transitions (argmax indices) for the Maxwell–Bellman operator at state `i` equals the set of optimal transitions for the charged Bellman operator at the same state.

**Lean type signature:**
```lean
def bellmanArgmax {n : ℕ} [NeZero n] (W : Matrix (Fin n) (Fin n) ℝ)
    (Φ : Fin n → ℝ) (i : Fin n) : Set (Fin n) :=
  { j | W i j + Φ j = bellmanOp W Φ i }

def maxwellBellmanArgmax {n : ℕ} [NeZero n]
    (W A : Matrix (Fin n) (Fin n) ℝ) (q : ℝ) (Φ : Fin n → ℝ) (i : Fin n) : Set (Fin n) :=
  { j | W i j + q * A i j + Φ j = maxwellBellmanOp W A q Φ i }

theorem argmax_transfer {n : ℕ} [NeZero n]
    (W A : Matrix (Fin n) (Fin n) ℝ) (q : ℝ) (Φ : Fin n → ℝ) (i : Fin n) :
    maxwellBellmanArgmax W A q Φ i = bellmanArgmax (chargedWeight W A q) Φ i
```

**Proof strategy.** Unfold both definitions; the membership predicate for `j` in both sets reduces to the same equality `chargedWeight W A q i j + Φ j = bellmanOp (chargedWeight W A q) Φ i` after applying `maxwellBellmanOp_eq_bellmanOp_charged` and `chargedWeight_apply`.

**Cross-domain significance.**
- *Optimal control*: Guarantees that the optimal policy under charged costs is the same policy you'd compute from the reweighted uncoupled system — essential for policy extraction in practice.
- *Attention mechanisms*: In hard-attention neural networks, the argmax over scores determines which token receives attention. This theorem says adding a bias field doesn't change which architectural reduction you can use to compute the selection.

---

## 5. Finite Graph Shortest-Path Corollary

**Statement.** On a weighted directed graph with edge weights `W(i,j)` and an additional "toll" field `A(i,j)` with charge `q`, the shortest (or longest) path from `s` to `t` under the combined cost `W(i,j) + q * A(i,j)` equals the shortest path under `chargedWeight W A q`. This is a graph-theoretic restatement of the main theorem.

**Lean type signature:**
```lean
/-- A path in the graph is a sequence of vertices. The cost of a path is the sum of
    edge weights along it. -/
def pathCost {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ)
    (path : List (Fin n)) : ℝ := sorry -- sum of W(path[k], path[k+1])

theorem chargedPathCost_eq {n : ℕ}
    (W A : Matrix (Fin n) (Fin n) ℝ) (q : ℝ) (path : List (Fin n)) :
    pathCost (chargedWeight W A q) path =
      pathCost W path + q * pathCost A path  -- linearity of path cost
```

**Proof strategy.** Define `pathCost` as a sum over consecutive pairs. Then `pathCost (chargedWeight W A q) = Σ (W(i,j) + q * A(i,j)) = Σ W(i,j) + q * Σ A(i,j)` by linearity of summation. This requires a straightforward induction on the path list.

**Cross-domain significance.**
- *Network optimization*: Charged shortest-path is a standard model for tolled road networks, multi-criteria routing, and risk-adjusted pathfinding. The theorem says any such problem reduces to a single-criterion shortest path.
- *Computational complexity*: Since shortest-path on the reweighted graph has the same complexity as ordinary shortest-path, this gives a free reduction for charged variants — no new algorithms needed.
- *Economics*: In transportation networks with congestion pricing (toll = `q * A`), optimal routing under any toll level `q` uses the same algorithmic infrastructure as untolled routing on a modified graph.

---

## Summary

| # | Direction | Difficulty | Impact |
|---|-----------|-----------|--------|
| 1 | Value iteration convergence | Easy (corollary) | High — validates iterative solvers |
| 2 | Monotonicity in charge | Medium | High — tropical response theory |
| 3 | Eigenvalue reduction | Medium | High — spectral theory bridge |
| 4 | Argmax/policy transfer | Easy–Medium | Very high — practical policy extraction |
| 5 | Graph shortest-path | Medium | Very high — algorithmic applications |

Each direction is independently pursuable and builds on the core `maxwellBellmanOp_eq_bellmanOp_charged` theorem as its foundation. Together, they constitute the beginning of a formal tropical gauge theory of Bellman dynamics.
