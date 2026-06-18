# Future Directions: Idempotent Spectral Duality for EML Operators

## 1. General Eigenvector Existence (Complete Proof)

**Status**: The general tropical Perron theorem (`exists_maxPlusMul_eigenvector`) remains as the single `sorry` in the formalization. The 1×1 and 2×2 cases are fully proved.

**Next steps**:
- Formalize the Bellman-Ford algorithm for difference constraint systems
- Prove that the max cycle mean makes all reduced cycles non-positive
- Construct the eigenvector from shortest (longest) paths in the reduced graph
- Verify the eigenvector equation by combining path decomposition with the no-positive-cycle property

**Approach**: The most promising Lean-friendly route is Howard's policy iteration: define a sequence of "policies" (functional graphs) and show convergence in finitely many steps.

## 2. Tropical Jordan Theory for Eventually Periodic Operators

When a max-plus matrix is **not** irreducible, its critical graph decomposes into strongly connected components. The asymptotic behavior of tropical powers then exhibits a periodic component superimposed on linear growth.

**Key theorem to prove**: For any matrix M, there exist integers p (period) and N (transient length) such that for all k ≥ N:
```
tropicalMatPow M (k + p) = tropicalMatPow M k + p · μ
```
where μ is the maximal cycle mean.

This is the tropical analogue of the Jordan normal form theorem and governs the long-term dynamics of EML operators on reducible presentations.

## 3. Spectral Decomposition by Critical Components

The critical graph of a max-plus matrix admits a natural decomposition into maximal strongly connected components. Each component contributes an **independent eigenvector** to the spectral decomposition.

**Key theorem**: The eigenspace of a tropical matrix is a finitely generated max-plus semimodule whose generators correspond to the critical components of the matrix.

This extends the spectral duality from single eigencharacters to a complete system of spectral observables.

## 4. Collatz–Wielandt Duality for EML Endomorphisms

The Collatz–Wielandt min-max characterization provides a dual description of the spectral radius:
```
μ = min { λ ∈ ℝ | ∃ v > -∞, M ⊗ v ≤ λ + v }
   = max { λ ∈ ℝ | ∃ v, M ⊗ v ≥ λ + v }
```

**Key theorem to prove**: This duality holds and both optima are achieved.

Formalizing this in Lean would connect the spectral theory to optimization (linear programming duality in the max-plus semiring) and provide an alternative computational route to the eigenvalue.

## 5. Tropical Koopman Eigencharacter Theory for Symbolic Dynamics

The spectral duality developed here is the tropical analogue of Koopman operator theory. In the classical setting, a dynamical system T : X → X induces a linear operator on observables f ↦ f ∘ T, and spectral analysis of this "Koopman operator" reveals the dynamical structure.

**Key theorem**: For a symbolic dynamical system with finitely many states and max-plus transition weights, the Koopman eigencharacters are exactly the tropical characters constructed from the left eigenvectors of the transition matrix.

**Application**: Growth rate analysis of weighted automata, complexity measures for string rewriting systems, and neural network tropicalization (studying the piecewise-linear approximation of deep networks through max-plus spectral data).

## 6. Complexity-Theoretic Interpretation of Max Cycle Mean

The max cycle mean μ of a transition matrix has a direct interpretation as a **semantic growth exponent**: it measures the worst-case per-step growth of the operator's iterates. This connects to:

- **Weighted automata theory**: μ = the growth rate of the most productive infinite run
- **Amortized complexity**: μ = the amortized cost per operation in a state machine
- **Neural network expressivity**: μ = the maximal Lipschitz constant growth rate of a piecewise-linear map

Formalizing these connections would bridge the spectral theory to concrete computational applications.

## 7. WithBot ℝ Formalization

The current formalization works over `ℝ` (where every matrix is trivially irreducible). Extending to `WithBot ℝ` (= ℝ ∪ {-∞}, the standard tropical semiring) would:

- Allow proper representation of "absent edges" in weighted digraphs
- Make irreducibility a non-trivial condition
- Enable the full tropical identity matrix (0 on diagonal, -∞ off-diagonal)
- Give the correct path weight semantics for tropical matrix powers

This extension is the natural next step for a complete tropical linear algebra library in Lean.
