# Tropical Causal Ordering: A Formal Framework for Min-Plus Causality, Nonexpansive Functoriality, and Budgeted Reachability

## Abstract

We introduce a formal framework for **tropical causal ordering** — a preorder structure derived from displacement functionals satisfying the triangle inequality in the tropical (min-plus / max-plus) semiring setting. We define budgeted causal reachability, zero-budget future relations, and prove their transitivity, reflexivity under diagonal bounds, and composition along chains. We establish functoriality: tropical nonexpansive maps preserve causal order, and their composition yields causal morphisms. We instantiate the abstract theory on finite-dimensional real vector spaces using both the sup-norm displacement (symmetric) and the one-sided displacement (giving the coordinatewise partial order). For weighted directed graphs, we define path-cost based matrix causality and prove transitivity by path concatenation. Finally, we prove a security propagation theorem linking causal budgets to degradation of Lipschitz-type security certificates. All results are fully machine-verified in Lean 4 with Mathlib, with zero sorry-dependent proofs.

**Keywords**: tropical geometry, causal preorder, min-plus algebra, nonexpansive maps, certified robustness, shortest paths, formal verification

---

## 1. Introduction

### 1.1 Motivation

The triangle inequality is a ubiquitous structure in mathematics: metrics, norms, distance-like functionals in optimization, and cost functions in dynamic programming all satisfy it. It is well known that the triangle inequality implies transitivity of "being within distance T" — this is the foundation of ε-ball arguments in analysis. However, this observation has not been systematically exploited to derive *causal* or *preorder* structures from tropical (min-plus / max-plus) displacement data.

In tropical mathematics, the operations (⊕, ⊗) = (max, +) or (min, +) replace classical (+ , ×). Tropical distance, defined via the sup-norm or via one-sided displacement, satisfies analogues of the triangle inequality. These inequalities arise naturally in:

- **Min-plus linear systems**: scheduling, manufacturing, discrete-event simulation
- **Tropical neural networks**: piecewise-linear classifiers with ReLU activations
- **Shortest-path algorithms**: dynamic programming, Floyd-Warshall, Bellman-Ford
- **Certified robustness**: adversarial perturbation bounds for neural networks

Our contribution is to unify these applications under a single **causal order framework**, where:
1. A displacement functional τ satisfying the triangle inequality defines a preorder.
2. Nonexpansive maps become order-preserving (causal) morphisms.
3. Path costs in weighted graphs yield a concrete matrix causality relation.
4. Security certificates propagate along causal chains with bounded degradation.

### 1.2 Related Work

**Tropical geometry**: Maclagan and Sturmfels (2015) established the algebraic foundations. Tropical convexity and tropical polytopes have been studied by Develin and Sturmfels, and Joswig. Our work adds an order-theoretic layer to this geometric toolkit.

**Min-plus algebra and control**: Baccelli, Cohen, Olsder, and Quadrat (1992) developed the foundational theory of min-plus linear systems for discrete-event control. The connection between min-plus eigenvalues and cycle times is classical. Our causal preorder provides a formal order structure for the state evolution of these systems.

**Certified robustness**: Zhang, Weng, et al. introduced tropical geometric approaches to neural network verification. Our functoriality theorem (nonexpansive maps preserve causal order) formalizes the compositional structure underlying these certificate methods.

**Formal verification**: The use of Lean 4 and Mathlib for machine-verified mathematical proofs follows the tradition of Hales' Flyspeck project, the Liquid Tensor Experiment, and ongoing Mathlib development.

### 1.3 Contributions

1. **Abstract budgeted transitivity** (Theorem 3.1): composition of causal budgets under the triangle inequality.
2. **Preorder packaging** (Definition 3.3): zero-budget future as a formal `Preorder`.
3. **Functoriality** (Theorem 4.1): nonexpansive maps preserve causal order, with categorical composition.
4. **Chain composition** (Theorem 5.1): causal chains of length n compose with additive budgets.
5. **Concrete instantiation** (Section 6): sup-norm and one-sided displacement on `Fin n → ℝ`.
6. **Matrix causality** (Theorem 7.3): path-concatenation transitivity for weighted digraphs.
7. **Security propagation** (Theorem 8.1): Lipschitz security bounds degrade linearly along causal chains.
8. **Full machine verification**: all results verified in Lean 4 with no sorry dependencies.

---

## 2. Definitions and Notation

### 2.1 Tropical Causal Relation

**Definition 2.1** (Tropical Causal). Let α be a type and τ : α → α → ℝ a displacement functional. For T ∈ ℝ, define:
```
TropicalCausal τ T x y  :⟺  τ(x, y) ≤ T
```

**Definition 2.2** (Tropical Future). The zero-budget future relation:
```
TropicalFuture τ x y  :⟺  τ(x, y) ≤ 0
```

### 2.2 Tropical Nonexpansive Maps

**Definition 2.3**. A map f : α → β is *tropical nonexpansive* from (α, τ₁) to (β, τ₂) if:
```
∀ x y, τ₂(f(x), f(y)) ≤ τ₁(x, y)
```

### 2.3 Concrete Displacements

**Definition 2.4** (Sup-norm displacement). For x, y : Fin n → ℝ:
```
tropicalSupDisplacement(x, y) = max_i |x_i - y_i|
```

**Definition 2.5** (One-sided displacement). For x, y : Fin n → ℝ:
```
tropicalOneSidedDisplacement(x, y) = max_i (y_i - x_i)
```

### 2.4 Path Cost and Matrix Causality

**Definition 2.6** (Path Cost). For a weight matrix A : Matrix (Fin n) (Fin n) ℝ and a path p = [v₀, v₁, ..., vₖ]:
```
PathCost(A, p) = Σᵢ A(vᵢ, vᵢ₊₁)
```

**Definition 2.7** (Matrix Causal). Vertex i can causally reach vertex j with budget T if:
```
MatrixCausal A T i j  :⟺  ∃ path p from i to j, PathCost(A, p) ≤ T
```

---

## 3. Abstract Theory

### 3.1 Budgeted Transitivity

**Theorem 3.1** (Budgeted Causal Transitivity). *Let τ : α → α → ℝ satisfy the triangle inequality ∀ x y z, τ(x,z) ≤ τ(x,y) + τ(y,z). If TropicalCausal τ T₁ x y and TropicalCausal τ T₂ y z, then TropicalCausal τ (T₁ + T₂) x z.*

*Proof.* τ(x,z) ≤ τ(x,y) + τ(y,z) ≤ T₁ + T₂. □

**Theorem 3.2** (Future Transitivity). *Under the same triangle inequality, TropicalFuture τ is transitive.*

*Proof.* Special case of Theorem 3.1 with T₁ = T₂ = 0: τ(x,z) ≤ τ(x,y) + τ(y,z) ≤ 0 + 0 = 0. □

**Definition 3.3** (Tropical Future Preorder). *If additionally τ(x,x) ≤ 0 for all x, then (α, TropicalFuture τ) is a preorder.*

The Lean formalization packages this as `tropicalFuturePreorder`, providing a `Preorder α` instance.

### 3.2 Budgeted Reflexivity

**Theorem 3.4**. *If τ(x,x) ≤ 0 and T ≥ 0, then TropicalCausal τ T x x.*

*Proof.* τ(x,x) ≤ 0 ≤ T. □

---

## 4. Functoriality

### 4.1 Monotonicity under Nonexpansive Maps

**Theorem 4.1** (Causal Monotonicity). *If f : α → β is tropical nonexpansive from (α, τ₁) to (β, τ₂), and TropicalFuture τ₁ x y, then TropicalFuture τ₂ (f x) (f y).*

*Proof.* τ₂(f(x), f(y)) ≤ τ₁(x, y) ≤ 0. □

**Theorem 4.2** (Budgeted Monotonicity). *Under the same hypotheses, TropicalCausal τ₁ T x y implies TropicalCausal τ₂ T (f x) (f y).*

### 4.2 Categorical Structure

**Theorem 4.3** (Composition). *The composition of two tropical nonexpansive maps is tropical nonexpansive.*

*Proof.* τ₃(g(f(x)), g(f(y))) ≤ τ₂(f(x), f(y)) ≤ τ₁(x, y). □

**Theorem 4.4** (Identity). *The identity map id : α → α is tropical nonexpansive.*

**Corollary 4.5** (Causal Morphism Composition). *If f and g are causal morphisms, then g ∘ f is a causal morphism.*

This establishes a category of tropical spaces with nonexpansive maps, where causal order is a functor from this category to the category of preorders.

---

## 5. Chain Composition

**Theorem 5.1** (Causal Chain). *Let τ satisfy the triangle inequality and τ(x,x) ≤ 0. For a chain x₀, x₁, ..., xₙ with individual budgets T₀, ..., Tₙ₋₁ satisfying TropicalCausal τ Tᵢ xᵢ xᵢ₊₁, we have TropicalCausal τ (ΣTᵢ) x₀ xₙ.*

*Proof.* By induction on n. Base case n = 0: τ(x₀, x₀) ≤ 0 = Σ∅. Inductive step: by the triangle inequality, τ(x₀, xₙ₊₁) ≤ τ(x₀, xₙ) + τ(xₙ, xₙ₊₁) ≤ (Σᵢ₌₀ⁿ⁻¹ Tᵢ) + Tₙ = Σᵢ₌₀ⁿ Tᵢ. □

**Corollary 5.2** (Future Chain). *Under the same hypotheses, if each link is in TropicalFuture, then so is the composite.*

---

## 6. Concrete Instantiations

### 6.1 Sup-Norm Displacement

**Theorem 6.1** (Triangle Inequality). *tropicalSupDisplacement satisfies:*
```
tropicalSupDisplacement(x, z) ≤ tropicalSupDisplacement(x, y) + tropicalSupDisplacement(y, z)
```

*Proof.* For each coordinate i: |xᵢ - zᵢ| ≤ |xᵢ - yᵢ| + |yᵢ - zᵢ| ≤ max_j|x_j - y_j| + max_j|y_j - z_j|. Take the max over i. □

**Theorem 6.2** (Reflexivity). *tropicalSupDisplacement(x, x) = 0 ≤ 0.*

**Corollary 6.3**. *The sup-norm displacement induces a preorder on Fin n → ℝ. Under this preorder, x ≤ y iff x = y (the discrete preorder).*

### 6.2 One-Sided Displacement

**Theorem 6.4** (Triangle Inequality). *tropicalOneSidedDisplacement satisfies the triangle inequality.*

*Proof.* For each i: zᵢ - xᵢ = (yᵢ - xᵢ) + (zᵢ - yᵢ) ≤ max_j(y_j - x_j) + max_j(z_j - y_j). □

**Theorem 6.5** (Characterization). *TropicalFuture tropicalOneSidedDisplacement x y ↔ ∀ i, yᵢ ≤ xᵢ.*

This connects the abstract causal framework to the concrete coordinatewise partial order, giving a nontrivial preorder where not all elements are comparable.

### 6.3 Norm-Induced Displacement

**Theorem 6.6** (Norm-Induced Triangle). *If ν : V → ℝ satisfies ν(u + v) ≤ ν(u) + ν(v), then τ(x, y) := ν(y - x) satisfies the triangle inequality.*

*Proof.* ν(z - x) = ν((y - x) + (z - y)) ≤ ν(y - x) + ν(z - y). □

**Definition 6.7** (Norm-Induced Preorder). *Any subadditive functional ν with ν(0) ≤ 0 induces a preorder via x ≤ y iff ν(y - x) ≤ 0.*

---

## 7. Matrix / Path Causality

### 7.1 Path Cost

We define PathCost recursively: an empty or singleton path has cost 0; a path [i, j, ...rest] has cost A(i,j) + PathCost(A, [j, ...rest]).

### 7.2 Valid Path Concatenation

**Theorem 7.1** (Valid Path Concatenation). *If p is a valid path from i to j and q is a valid path from j to k, then p ++ tail(q) is a valid path from i to k.*

**Theorem 7.2** (Path Cost Bound). *PathCost(A, p ++ tail(q)) ≤ PathCost(A, p) + PathCost(A, q).*

### 7.3 Matrix Causal Transitivity

**Theorem 7.3** (Matrix Causal Transitivity). *If MatrixCausal A T₁ i j and MatrixCausal A T₂ j k, then MatrixCausal A (T₁ + T₂) i k.*

*Proof.* Let p be a path from i to j with cost ≤ T₁ and q a path from j to k with cost ≤ T₂. Then p ++ tail(q) is a valid path from i to k with cost ≤ T₁ + T₂. □

### 7.4 Algorithmic Implications

Matrix causal transitivity is the mathematical foundation of:
- **Floyd-Warshall**: computing all-pairs shortest paths as causal closure
- **Bellman-Ford**: single-source causal reachability
- **Min-plus matrix multiplication**: computing k-hop causal reachability via A^⊗k

The formal verification ensures these algorithmic foundations are mathematically sound.

---

## 8. Security Propagation

**Theorem 8.1** (Security Propagation). *Let f : α → ℝ satisfy |f(x) - f(y)| ≤ τ(x,y) for all x, y (i.e., f is 1-Lipschitz with respect to τ). If TropicalCausal τ T x y and f(y) ≥ λ, then f(x) ≥ λ - T.*

*Proof.* From the Lipschitz condition: f(y) - f(x) ≤ |f(x) - f(y)| ≤ τ(x,y) ≤ T. Thus f(x) ≥ f(y) - T ≥ λ - T. □

**Interpretation**: Security levels (measured by f) degrade by at most the causal budget T along causal chains. This provides a compositional framework for analyzing how security guarantees weaken as information flows through a system.

---

## 9. Computational Experiments

### 9.1 Budget Composition on Random Graphs

We generate random weighted directed graphs on n = 10 vertices and verify that path-cost transitivity holds numerically. For 1000 random triples (i, j, k), we compute optimal paths i→j, j→k, and i→k, confirming that cost(i→k) ≤ cost(i→j) + cost(j→k) in every case.

### 9.2 Causal Cone Visualization

For 2D and 3D examples, we visualize the causal cone {y : τ(x,y) ≤ T} for both the sup-norm and one-sided displacements, showing how the cone grows with the budget T.

### 9.3 Security Degradation Along Chains

We simulate a chain of 10 nonexpansive transformations with individual budgets drawn uniformly from [0, 0.5]. Starting with a security level of 10.0, we track the guaranteed lower bound through the chain, verifying that it decreases by at most the sum of budgets.

See `demo.py` for implementation and `algorithms.py` for the core algorithms.

---

## 10. Discussion

### 10.1 Conceptual Compression

The main contribution is not any single theorem — each is elementary — but the *conceptual framework* that unifies:
- Tropical metric geometry (triangle inequality → preorder)
- Nonexpansive map theory (Lipschitz-1 → causal morphism)
- Shortest-path algorithms (path concatenation → causal transitivity)
- Certified robustness (security bounds → causal budget degradation)

### 10.2 Limitations

1. The sup-norm displacement yields a trivial preorder (x ≤ y iff x = y). The one-sided displacement gives a nontrivial order but is not symmetric.
2. The matrix causality framework uses simple path concatenation; a tighter analysis using min-plus matrix algebra could give sharper bounds.
3. The security propagation theorem assumes 1-Lipschitz regularity; extensions to L-Lipschitz maps would multiply the degradation by L.

### 10.3 Open Questions

1. Can the tropical causal preorder be extended to a *partial order* (antisymmetric) under natural conditions on τ?
2. Is there a tropical analogue of the causal hierarchy (chronological, causal, horismos) from Lorentzian geometry?
3. Can tropical causal cones be characterized as tropical polytopes?

---

## 11. Future Work

See `FUTURE_DIRECTIONS.md` for a detailed roadmap including:
1. Tropical Lorentzian geometry and causal cone structure
2. Floyd-Warshall as causal closure (Kleene star)
3. Neural network causal certificates
4. Spectral causality via tropical eigenpairs
5. Tropical entropy and causal information flow

---

## References

1. Baccelli, F., Cohen, G., Olsder, G.J., Quadrat, J.P. (1992). *Synchronization and Linearity: An Algebra for Discrete Event Systems*. Wiley.
2. Maclagan, D., Sturmfels, B. (2015). *Introduction to Tropical Geometry*. AMS.
3. Zhang, H., et al. (2018). Tropical geometry of deep neural networks. *ICML*.
4. Joswig, M. (2022). *Essentials of Tropical Combinatorics*. AMS.
5. Akian, M., Gaubert, S., Guterman, A. (2012). Tropical polyhedra are equivalent to mean payoff games. *IJAC*.
