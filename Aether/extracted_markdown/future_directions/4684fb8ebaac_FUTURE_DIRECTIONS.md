# Future Directions: Integrated Information via Tensor Networks

## 1. Tight Integration Bounds via Schmidt Rank

The integration measure Φ(ψ) = ‖ψ‖⁴ − Tr(ρ_A²) is bounded above by ‖ψ‖⁴(1 − 1/r) where r is the Schmidt rank (number of nonzero singular values of ψ viewed as a matrix). Conversely, for a state with exactly r equal singular values, Φ attains this bound. The key insight is that Tr(ρ_A²) = Σ σ_k⁴ is minimized (at fixed ‖ψ‖² = Σ σ_k²) when all nonzero singular values are equal, by the power-mean inequality. Why now? We have already formalized the Cauchy-Schwarz bound (Theorem 2) and the product-state characterization (Theorem 5), so the singular value decomposition is the natural next tool to bring in. Mathlib has `Matrix.SVD` infrastructure that may suffice.

## 2. Subadditivity of Integration Under Tensor Products

For a tripartite system ψ : Fin m → Fin n → Fin p → ℝ, does the integration across the (A|BC) bipartition satisfy Φ_{A|BC} ≤ Φ_{A|B} + Φ_{A|C} in some appropriate sense? The key insight is that the purity-based integration measure should be subadditive under composition of bipartitions, analogous to subadditivity of von Neumann entropy. This would establish Φ as a bona fide information measure on the lattice of bipartitions. Why now? The symmetry theorem (Theorem 3) shows that Φ is a well-defined function of the bipartition rather than the labeling, which is the essential prerequisite for studying its behavior under partition refinement.

## 3. Monotonicity Under Local Operations

Conjecture: If T : (Fin n → ℝ) → (Fin n' → ℝ) is a linear map applied to subsystem B (a "local operation"), then Φ(id ⊗ T)(ψ) ≤ ‖T‖² · Φ(ψ), where ‖T‖ is the operator norm. More precisely, local operations cannot increase integration beyond a norm factor. The key insight is that applying T to columns of the matrix ψ multiplies singular values by at most ‖T‖, so Tr(ρ_A²) transforms predictably. Why now? The homogeneity theorem (Theorem 4) already handles the scalar case T = c·Id. Extending to general linear maps is the natural next step and would connect to the theory of quantum channels.

## 4. Categorical Formulation via Tensor Categories

The integration measure can be defined for any morphism in a symmetric monoidal category with a trace (pivotal category). Specifically, for an endomorphism f : V ⊗ W → V ⊗ W, define Φ(f) = Tr(f²) − Tr_W(f)², where Tr_W is the partial trace. The key insight is that our theorems (non-negativity, product-state vanishing, symmetry) are consequences of the pivotal structure and should hold categorically. Why now? The concrete ℝ-vector-space formalization provides the ground truth against which a categorical generalization can be validated. Mathlib's `CategoryTheory.MonoidalCategory` and `CategoryTheory.Pivotal` provide the categorical scaffolding.

## 5. Connection to Quantum Mutual Information

For normalized quantum states (‖ψ‖² = 1), the purity-based integration Φ relates to the Rényi-2 mutual information: I₂(A:B) = −log(Tr(ρ_A²)) − log(Tr(ρ_B²)) + log(Tr(ρ²)) = −2·log(Tr(ρ_A²)) (since ρ is pure and Tr(ρ_A²) = Tr(ρ_B²) by our symmetry theorem). Thus Φ = 1 − Tr(ρ_A²) is a monotone function of I₂. The key insight is that our integration measure is not merely "inspired by" IIT but is precisely the linearized version of Rényi-2 mutual information, connecting rigorously to quantum information theory. Why now? The symmetry theorem (Tr(ρ_A²) = Tr(ρ_B²)) is exactly the statement that Rényi-2 entropies of complementary subsystems agree for pure states, so the bridge is already half-built.
