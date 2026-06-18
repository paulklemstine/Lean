# Future Directions: Tropical Compositional Dynamics

## 1. Tropical Perron–Frobenius Exact Asymptotics for Vertical Composition

**Hypothesis**: For irreducible tropical matrices (where the associated directed graph is strongly connected), the maximum cycle mean equals the tropical spectral radius, and vertical composition growth converges to exactly this rate.

**Proof Strategy**:
1. Formalize the notion of *irreducibility* for tropical matrices: the weighted digraph `G(A)` with edge weights `A_ij` is strongly connected.
2. Define the *maximum cycle mean*: `μ(A) = max_{σ cycle} (∑_{(i,j)∈σ} A_ij) / |σ|`.
3. Prove the tropical Perron–Frobenius theorem: for irreducible `A`, there exists a tropical eigenvector `v` with eigenvalue `μ(A)`, i.e., `A ⊗ v = μ(A) + v`.
4. Use `tropical_eigenvector_iterate_exact` to deduce: `verticalIterate A k v = k * μ(A) + v`.
5. Prove the *converse bound*: `supNorm(A^k ⊗ x) ≥ k * μ(A) + C` for some constant depending on `x`.

**Suggested theorem**:
```lean
theorem tropical_perron_frobenius_asymptotic
    {n : ℕ} (A : Fin (n+1) → Fin (n+1) → ℝ) (hIrr : TropicalIrreducible A) (x : Fin (n+1) → ℝ) :
    Filter.Tendsto (fun k => supNorm (verticalIterate A k x) / k)
      Filter.atTop (nhds (maxCycleMean A))
```

**Cross-domain significance**: This gives the exact tropical Lyapunov exponent for compositional systems, analogous to the classical Lyapunov exponent in dynamical systems theory. It would provide tight depth-efficiency bounds for tropical neural networks.

---

## 2. Subadditive Ergodic / Tropical Lyapunov Theory for Random Layer Composition

**Hypothesis**: When layers are drawn i.i.d. from a distribution over tropical matrices, the growth rate of `supNorm(A_k ⊗ ··· ⊗ A_1 ⊗ x)` converges almost surely to a deterministic tropical Lyapunov exponent by the subadditive ergodic theorem.

**Proof Strategy**:
1. Formalize the product of tropical matrices: `(A ⊗ B)_{ij} = max_k (A_{ik} + B_{kj})`.
2. Show that `f(k) = supNorm(A_k ⊗ ··· ⊗ A_1 ⊗ 0)` is subadditive: `f(m+n) ≤ f(m) + f(n)` (up to a constant).
3. Apply Kingman's subadditive ergodic theorem (formalized in Mathlib) to obtain almost-sure convergence.
4. Identify the limit as the max-plus analogue of the top Lyapunov exponent.

**Suggested theorem**:
```lean
theorem tropical_lyapunov_exponent_exists
    {n : ℕ} (μ : MeasureTheory.Measure (Fin (n+1) → Fin (n+1) → ℝ))
    [MeasureTheory.IsProbabilityMeasure μ] (hErg : Ergodic μ) :
    ∃ λ_trop : ℝ, ∀ᵐ ω, Filter.Tendsto
      (fun k => supNorm (tropicalRandomProduct ω k (fun _ => 0)) / k)
      Filter.atTop (nhds λ_trop)
```

**Cross-domain significance**: This creates a rigorous theory of *stochastic depth* — what happens when network layers are randomly initialized or randomly dropped (as in dropout). The tropical Lyapunov exponent becomes a trainability diagnostic.

---

## 3. Enriched Categorical Semantics of Tropical Depth

**Hypothesis**: Tropical matrix composition defines an enrichment of the category of finite sets over the max-plus semiring, where morphism composition growth is controlled by the spectral radius functor.

**Proof Strategy**:
1. Define a category `TropMat` with objects `Fin n` and morphisms `Fin n → Fin m → ℝ` (tropical matrices).
2. Define composition as tropical matrix multiplication.
3. Show this forms a category enriched over `(ℝ ∪ {-∞}, max, +)`.
4. Define a "spectral radius functor" `ρ : TropMat → ℝ` sending matrices to their maximum cycle mean.
5. Prove that `ρ(A ∘ B) ≤ ρ(A) + ρ(B)` (subadditivity of spectral radius under composition).
6. Use this to derive depth-composition bounds categorically.

**Suggested theorem**:
```lean
theorem tropical_enriched_composition_bound
    {n m p : ℕ}
    (A : Fin (n+1) → Fin (m+1) → ℝ) (B : Fin (m+1) → Fin (p+1) → ℝ) :
    matMaxEntry (tropMatMul A B) ≤ matMaxEntry A + matMaxEntry B
```

**Cross-domain significance**: This provides the mathematical foundation for a *compositional type theory* for neural architectures, where the "type" of a layer includes its spectral growth rate. Architecture search could then be guided by categorical constraints on composition.

---

## 4. Certified Robustness and Generalization Bounds from Tropical Spectral Growth

**Hypothesis**: The tropical spectral bound directly yields Lipschitz constants for tropical neural networks, which in turn give certified robustness radii and PAC-Bayes generalization bounds.

**Proof Strategy**:
1. Show that `tropMatVec A` is a nonexpansive map with respect to the tropical (L∞) metric up to an additive shift: `d∞(A⊗x, A⊗y) ≤ d∞(x, y)` (this is actually an equality — tropical maps are isometries of the Hilbert projective metric).
2. Derive: for a k-layer tropical network with matrices `A₁, ..., A_k`, the Lipschitz constant in L∞ is exactly 1 (additive Lipschitz).
3. Use this to prove certified robustness: if the input perturbation is ε in L∞, the output perturbation is at most ε.
4. Combine with margin bounds to get generalization certificates.

**Suggested theorem**:
```lean
theorem tropical_certified_robustness
    {n : ℕ} (A : Fin (n+1) → Fin (n+1) → ℝ)
    (x y : Fin (n+1) → ℝ) (k : ℕ) :
    tropicalDistance (verticalIterate A k x) (verticalIterate A k y) ≤
      tropicalDistance x y
```

**Cross-domain significance**: This gives the first *certified* robustness bounds specifically tailored to tropicalized neural networks, potentially much tighter than generic Lipschitz bounds for standard networks. The key insight is that tropical composition preserves the L∞ metric exactly.

---

## 5. Tropical Control-Theoretic Interpretation of Deep Architectures

**Hypothesis**: A deep tropical neural network with k layers is equivalent to a k-step max-plus optimal control problem, where the weight matrices are the stage costs and the iterate bound gives the value function growth rate.

**Proof Strategy**:
1. Formalize the max-plus Bellman equation: `V_{k+1}(i) = max_j (A_ij + V_k(j))`, which is exactly `tropMatVec`.
2. Show that `verticalIterate A k (fun _ => 0)` computes the k-step optimal value function.
3. Prove the connection to shortest/longest path problems: the (i,j) entry of the k-th tropical matrix power gives the maximum-weight path of length k from j to i.
4. Use the iterate bound to derive finite-horizon cost certificates.

**Suggested theorem**:
```lean
theorem tropical_bellman_optimality
    {n : ℕ} (A : Fin (n+1) → Fin (n+1) → ℝ) (k : ℕ) (i : Fin (n+1)) :
    verticalIterate A k (fun _ => 0) i =
      Finset.sup' (allPathsOfLength k i) ⟨...⟩ (fun path => pathWeight A path)
```

**Cross-domain significance**: This creates a formal dictionary between deep learning and optimal control. Network depth becomes planning horizon, weight matrices become stage costs, and the tropical spectral bound becomes the per-stage cost growth rate. This opens the door to using control-theoretic tools (Pontryagin maximum principle, Hamilton-Jacobi-Bellman theory) in neural architecture design.

---

## 6. Tropical Circuit Complexity and Depth Separation

**Hypothesis**: The tropical spectral radius provides lower bounds on the depth required to compute certain functions, giving tropical analogues of circuit complexity depth-separation results.

**Proof Strategy**:
1. Show that functions with large "tropical oscillation" (many changes in which monomial is dominant) require depth proportional to `log(oscillation) / log(width)`.
2. Prove that depth-k tropical circuits with width w can represent at most `w^k` linear regions.
3. Use the spectral bound to show that certain functions require the iterate bound to be tight, implying depth lower bounds.

**Cross-domain significance**: This connects tropical geometry to computational complexity, potentially yielding new lower bounds on the expressivity of neural networks.

---

## 7. Tropical Transfer Learning via Spectral Alignment

**Hypothesis**: Two tropical networks with similar spectral radii can be aligned via a tropical change of basis, enabling certified transfer of depth-stability guarantees.

**Proof Strategy**:
1. Define tropical similarity: `A ~ D⁻¹ ⊗ B ⊗ D` where `D` is a diagonal tropical matrix (scaling).
2. Show that similar matrices have the same spectral radius (maximum cycle mean).
3. Prove that the iterate bound transfers: if `A ~ B`, then depth-stability certificates for `A` apply to `B`.

**Cross-domain significance**: This provides a mathematical framework for understanding when and how depth-stability guarantees transfer between architectures, a key question in practical deep learning.

---

## Summary: Research Roadmap

| Priority | Direction | Difficulty | Impact |
|----------|-----------|-----------|--------|
| 🔴 High | Perron–Frobenius asymptotics | Medium | Exact growth rates |
| 🔴 High | Certified robustness | Low-Medium | Direct applications |
| 🟡 Medium | Random layer Lyapunov theory | High | Stochastic depth theory |
| 🟡 Medium | Enriched categorical semantics | Medium | Foundational |
| 🟢 Future | Tropical control theory | Medium | Cross-domain bridge |
| 🟢 Future | Circuit complexity | High | Depth lower bounds |
| 🟢 Future | Transfer learning | Medium | Practical applications |

Each direction builds on the formal infrastructure established in `TropicalVerticalComposition.lean`, particularly the definitions of `tropMatVec`, `verticalIterate`, `supNorm`, `matMaxEntry`, and the key theorems `vertical_composition_iterate_bound` and `tropical_eigenvector_iterate_exact`.
