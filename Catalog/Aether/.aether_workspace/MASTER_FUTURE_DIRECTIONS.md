# MASTER FUTURE DIRECTIONS — Accumulated Research Wisdom

*Last updated: 2026-05-09 12:32*

## Breakthrough Opportunities (ranked by impact)

### 1. Formalized Schwartz-Zippel Lemma for Multivariate Polynomials

- **Theorem Statement:** For a nonzero polynomial f ∈ k[x₁,...,xₙ] of total degree d, and a finite set S ⊆ k, Pr_{a ∈ Sⁿ}[f(a) = 0] ≤ d/|S|.
- **Proof Strategy:**
  - (A) Induction on n, reducing to the univariate case using Polynomial.card_roots'.
  - (B) Use the DeMillo-Lipton-Schwartz-Zippel counting argument with MvPolynomial.totalDegree.
  - Key lemma: `MvPolynomial.eval_nonzero_of_totalDegree_lt_card` — a nonzero polynomial of degree d has a nonzero evaluation in any grid of size > d.
- **Why This Is Revolutionary:** Would give the first formally verified probabilistic PIT algorithm with explicit soundness bounds, directly applicable to cryptographic protocol verification.
- **Catalog Leverage:** Builds on `totalDegree_le_degreeBound`, `univariate_root_bound`, `circuit_zero_poly_vanishes`.
- **Research Mode:** prove
- **Estimated Depth:** 3

### 2. DAG Circuit Model with Gate Reuse

- **Theorem Statement:** Define `DAGCircuit` with shared sub-computations. Prove that `size(DAG) ≤ size(tree)` for equivalent computations, and that the degree-depth bound `degreeBound ≤ 2^depth` still holds.
- **Proof Strategy:**
  - Define DAG circuits as functions `Fin m → GateSpec` with topological ordering.
  - Prove well-definedness of evaluation via topological induction.
  - Key lemma: Tree-to-DAG conversion preserves semantics.
- **Why This Is Revolutionary:** DAG circuits are the standard model in complexity theory. This would make the formalization applicable to real circuit lower bound proofs.
- **Catalog Leverage:** All existing `AlgCircuit` theorems transfer via the tree-to-DAG embedding.
- **Research Mode:** formalize
- **Estimated Depth:** 4

### 3. VP ≠ VNP Separation via Coordinate Ring Invariants

- **Theorem Statement:** Define VP(k) and VNP(k) as families of circuit-computable polynomials. Prove that certain coordinate ring invariants (e.g., dimension of the symmetry group orbit) distinguish VP from VNP.
- **Proof Strategy:**
  - (A) Formalize the permanent vs. determinant framework.
  - (B) Use Mulmuley-Sohoni's geometric complexity theory approach.
  - (C) Prove that the permanent's symmetry group orbit closure has higher dimension than the determinant's.
- **Why This Is Revolutionary:** Would make progress on one of the most important open problems in theoretical computer science.
- **Catalog Leverage:** `circuit_lower_bound_from_obstruction`, `degreeBound_le_two_pow_depth`.
- **Research Mode:** discover
- **Estimated Depth:** 5

### 4. Certified Neural Network Depth Bounds via Polynomial Degree

- **Theorem Statement:** For a ReLU neural network N of depth d and width w, the piecewise polynomial computed by N has degree ≤ 2^d on each linear region. Therefore, approximating a degree-D polynomial to precision ε requires depth ≥ ⌈log₂ D⌉.
- **Proof Strategy:**
  - Formalize the connection between ReLU networks and piecewise polynomials.
  - Use `degreeBound_le_two_pow_depth` on each linear region.
  - Derive the depth lower bound by contradiction.
- **Why This Is Revolutionary:** Would provide the first formally verified depth separation for practical neural network architectures, with immediate applications to neural architecture search.
- **Catalog Leverage:** `degreeBound_le_two_pow_depth`, `depth_lower_bound_log`, `CertifiedCircuit`.
- **Research Mode:** prove
- **Estimated Depth:** 3

### 5. Gröbner-Based Deterministic PIT for Bounded-Depth Circuits

- **Theorem Statement:** For circuits of depth ≤ d computing polynomials of degree ≤ δ in n variables, there exists a deterministic PIT algorithm running in time poly(n, δ^d).
- **Proof Strategy:**
  - Formalize Gröbner basis computation for `MvPolynomial` (requires substantial infrastructure).
  - Prove that the Jacobian ideal J = ⟨∂f/∂x₁, ..., ∂f/∂xₙ⟩ captures zero-ness: f = 0 ⟺ 1 ∈ J for char 0.
  - Bound the Gröbner basis computation cost.
- **Why This Is Revolutionary:** Would establish the first formalized constructive derandomization of PIT, connecting to the Kabanets-Impagliazzo program.
- **Catalog Leverage:** `jacobianIdeal`, `pderiv_C_eq`, `pderiv_add_eq`, `pderiv_mul_leibniz`.
- **Research Mode:** prove
- **Estimated Depth:** 5