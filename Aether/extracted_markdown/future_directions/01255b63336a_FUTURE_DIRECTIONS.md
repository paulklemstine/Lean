# Future Directions: Causal Integration Algebra

## Synthesis

This cycle extended the Causal Integration Algebra with four structural theorems about the integrated information functional Φ on weighted directed graphs. We proved superadditivity of Φ under edge-wise addition, the complete characterization Φ = 0 ↔ disconnected, complement duality for symmetric systems, and a lower bound on Φ by minimum off-diagonal weight. Each theorem comes with examples, generalizations, and boundary analysis.

## Direction 1: Direct Sum Decomposition and Φ-Spectrum

The superadditivity theorem `phi_add_superadditive` shows Φ(C₁ + C₂) ≥ Φ(C₁) + Φ(C₂). A natural question is: when is equality achieved? We conjecture that equality holds if and only if the two systems share an optimal cut (i.e., the argmin bipartition for Φ(C₁ + C₂) is simultaneously optimal for both C₁ and C₂).

The key insight is that the gap Φ(C₁ + C₂) - Φ(C₁) - Φ(C₂) measures the "misalignment" of integration bottlenecks. Formalizing this gap as a metric on CausalSystem pairs could yield a novel distance function on the space of causal systems.

Why now? We have the superadditivity proof and the crossInfo_add decomposition. The next step is purely about argmin structure, which is tractable using Finset.inf' properties already in Mathlib.

## Direction 2: Spectral Characterization of Φ via Laplacian Eigenvalues

For symmetric causal systems, the cross-information functional is closely related to the graph Laplacian. We conjecture that for symmetric C with n ≥ 2, Φ(C) equals the second-smallest eigenvalue of the weighted Laplacian matrix (the algebraic connectivity / Fiedler value), multiplied by a combinatorial factor depending on the optimal partition sizes.

The key insight is that the complement duality theorem `crossInfo_compl_eq_of_symmetric` implies the min-cut problem is equivalent to a Rayleigh quotient optimization, which connects to eigenvalue theory. This would bridge the combinatorial (discrete cut) and spectral (continuous eigenvalue) perspectives on integration.

Why now? The symmetric complement duality is now proven. Formalizing the Laplacian as a matrix and connecting its spectrum to crossInfo would require Mathlib's `Matrix.IsHermitian` and eigenvalue theory, which are increasingly well-developed.

## Direction 3: Submodularity of Cross-Information

We conjecture that the set function S ↦ crossInfo(C, S) is submodular: for all S, T ⊆ V, crossInfo(S ∪ T) + crossInfo(S ∩ T) ≤ crossInfo(S) + crossInfo(T). If true, this would imply that the minimum cut can be found in polynomial time via submodular function minimization, connecting the IIT computation to algorithmic complexity theory.

The key insight is that crossInfo decomposes as a sum of modular functions (one per edge), and sums of modular functions are submodular. The crossInfo_compl_skew theorem already shows how crossInfo decomposes into individual edge contributions.

Why now? The skew decomposition theorem provides the right algebraic framework. Submodularity would follow from showing each edge's contribution to crossInfo is submodular, which is a finite verification.

## Direction 4: Tensor Product of Causal Systems

Define the tensor product C₁ ⊗ C₂ on Fin(n₁ · n₂) with weight (i₁,i₂) → (j₁,j₂) given by w₁(i₁,j₁) · w₂(i₂,j₂). We conjecture Φ(C₁ ⊗ C₂) = Φ(C₁) · Φ(C₂). This multiplicativity would make Φ a ring homomorphism from the Grothendieck ring of causal systems to ℝ.

The key insight is that tensor product cuts decompose as products of component cuts: any bipartition of Fin(n₁ · n₂) can be analyzed via its "fiber structure" over bipartitions of each factor. The minimum of products equals the product of minima when the factors are independent.

Why now? The phi_scale theorem already proves multiplicativity for scalar factors. The tensor product extends this to system-level multiplicativity, requiring only the combinatorial analysis of how bipartitions of a product decompose.

## Direction 5: Continuity and Approximation of Φ

The phi_mono_of_weight_le theorem shows Φ is monotone. We conjecture Φ is Lipschitz continuous with respect to the L∞ norm on weights: |Φ(C₁) - Φ(C₂)| ≤ n² · max_{i,j} |w₁(i,j) - w₂(i,j)|. This would make Φ a well-behaved functional for optimization and perturbation analysis.

The key insight is that crossInfo is a sum of at most n² terms, each differing by at most the max weight difference. The Lipschitz bound follows from the triangle inequality on the inf' functional.

Why now? The monotonicity and lower bound theorems provide the key inequalities. Extending from monotonicity to Lipschitz requires only the observation that C₁ ≤ C₂ + ε·J (where J is the all-ones system) for appropriate ε, combined with phi_scale and phi_add_superadditive.
