# Future Directions: Invariant Subspace Theory Formalization

## Hypothesis 1: Fredholm Alternative Formalization

**Conjecture:** The Fredholm alternative for compact operators — that if K is compact and (I - K) is injective, then (I - K) is surjective — can be formalized in Lean 4/Mathlib using the existing compact operator infrastructure (`IsCompactOperator`), the open mapping theorem, and Riesz's lemma on approximate eigenvalues.

**Test:** 
1. Formalize Riesz's lemma: for a proper closed subspace M of a normed space, there exists a unit vector with distance > 1-ε from M.
2. Use Riesz's lemma to show that a compact operator on an infinite-dimensional space cannot have a bounded inverse.
3. Build the ascending chain argument: if (I - K) is injective but not surjective, the subspaces Vₙ = range((I-K)ⁿ) form a strictly decreasing chain, contradicting compactness of K via Riesz's lemma.
4. Conclude: (I - K) injective implies (I - K) surjective.

**Impact:** This would immediately unlock the Riesz-Schauder theorem and the full compact operator invariant subspace theorem. It is the single highest-impact target. It would also enable formalization of Fredholm index theory, spectral theory of compact operators, and the Fredholm alternative for integral equations.

**Feasibility:** HIGH. All prerequisites exist in Mathlib: compact operators, the open mapping theorem, Riesz's lemma (may need to be formalized but is elementary). The proof is well-understood and involves only finite-dimensional approximation arguments.

## Hypothesis 2: Spectral Projection API for Normal Operators

**Conjecture:** The continuous functional calculus (CFC) infrastructure in Mathlib can be extended to produce spectral projections for bounded normal operators on Hilbert spaces, specifically: for a normal operator T and a clopen subset S of σ(T), the CFC applied to the characteristic function 1_S gives an orthogonal projection whose range is a nontrivial reducing subspace of T.

**Test:**
1. Verify that Mathlib's CFC can handle indicator functions of clopen spectral subsets (these are continuous on the spectrum since the spectrum is compact and the subset is clopen).
2. Show that cfcHom applied to 1_S produces an idempotent (1_S² = 1_S) and self-adjoint (1_S̄ = 1_S) element.
3. Prove the range of this projection is T-invariant and T*-invariant (reducing).
4. Verify nontriviality when σ(T) has at least two points.

**Impact:** This would give the normal operator invariant subspace theorem for all bounded normal operators whose spectrum is not a single point. Combined with the trivial case (T = λI has every subspace invariant), this completely resolves the invariant subspace problem for normal operators.

**Feasibility:** MEDIUM. The CFC exists in Mathlib but spectral projections via indicator functions require careful handling of the continuity conditions. The key challenge is that characteristic functions of arbitrary Borel sets are not continuous; one needs clopen sets or an extension to the Borel functional calculus.

## Hypothesis 3: Unilateral Shift Counterexample Infrastructure

**Conjecture:** The unilateral shift operator on ℓ²(ℕ) can be formalized in Lean 4 using Mathlib's `lp` or `EuclideanSpace` types, and one can prove: (a) the shift has no eigenvalues of modulus ≥ 1; (b) the shift has explicit nontrivial closed invariant subspaces (e.g., the Hardy-space inner function subspaces).

**Test:**
1. Define the unilateral shift S on ℓ²(ℕ): S(eₙ) = eₙ₊₁.
2. Prove: if Sv = λv with v ∈ ℓ², then |λ| < 1 (by showing v = (c, λc, λ²c, ...) must converge).
3. Prove: the subspace Mₖ = {x ∈ ℓ² : x₀ = ... = xₖ₋₁ = 0} is a nontrivial closed invariant subspace.
4. [Stretch] Formalize Beurling's theorem: every invariant subspace of the shift is of the form θ·H² for an inner function θ.

**Impact:** This would provide the first formal counterexample to the naive conjecture "every invariant subspace arises from eigenvalues." It demonstrates the depth gap between eigenvalue-based invariant subspace theorems and the general theory, and builds infrastructure for Hardy space theory and function-theoretic operator theory.

**Feasibility:** MEDIUM-HIGH for parts (a)-(c). Part (d) (Beurling's theorem) is a significant undertaking requiring Hardy space formalization.

## Hypothesis 4: Compact Self-Adjoint Spectral Theorem via Variational Methods

**Conjecture:** For compact self-adjoint operators, the existence of eigenvalues can be proved via the variational characterization: ‖T‖ = sup{|⟨Tx,x⟩| : ‖x‖ = 1}, and this supremum is achieved (giving an eigenvalue ±‖T‖). This bypasses the full Riesz-Schauder theory and may be more amenable to formalization.

**Test:**
1. Prove the Rayleigh quotient characterization: for T self-adjoint, ‖T‖ = sup |⟨Tx,x⟩|/‖x‖².
2. Show this supremum is achieved using compactness of T: extract a maximizing sequence, use compactness to get convergence of T(xₙ), deduce convergence of xₙ.
3. Conclude that the limit is an eigenvector with eigenvalue ±‖T‖.
4. Iterate on the orthogonal complement to get the full spectral decomposition.

**Impact:** This would give the compact self-adjoint invariant subspace theorem without requiring the Fredholm alternative. It would also provide the min-max characterization of eigenvalues (Courant-Fischer theorem), which is fundamental to numerical eigenvalue algorithms and PDE spectral theory.

**Feasibility:** HIGH. The variational argument is more elementary than the Riesz-Schauder approach and uses only compactness, completeness, and the Cauchy-Schwarz inequality — all available in Mathlib.

## Hypothesis 5: Operator-Theoretic Controllability Decomposition

**Conjecture:** The formal invariant subspace framework developed here can be extended to prove a Hilbert-space version of the Kalman controllability decomposition: for a bounded linear operator A on a Hilbert space H and a bounded operator B : U → H (input operator), the closure of the reachable subspace R = cl(span{B u, AB u, A²B u, ... : u ∈ U}) is a closed A-invariant subspace, and its orthogonal complement is A*-invariant.

**Test:**
1. Define the reachable subspace R as the topological closure of span{AⁿBu : n ∈ ℕ, u ∈ U}.
2. Prove R is closed (by definition as a closure).
3. Prove R is A-invariant: A maps range(Aⁿ ∘ B) into range(Aⁿ⁺¹ ∘ B) ⊆ R, and A is continuous so preserves closures.
4. Prove R⊥ is A*-invariant (dual controllability): if ⟨y, AⁿBu⟩ = 0 for all n, u, then ⟨A*y, AⁿBu⟩ = ⟨y, Aⁿ⁺¹Bu⟩ = 0.
5. State and prove: if R ≠ ⊤ (system not controllable), then R is a nontrivial closed invariant subspace.

**Impact:** This bridges invariant subspace theory and infinite-dimensional control theory. It provides the foundation for formal verification of controllability and observability in distributed-parameter systems (PDEs, delay systems, infinite-dimensional quantum systems). It would be the first machine-verified result connecting operator-theoretic invariant subspaces to control-theoretic system decompositions.

**Feasibility:** HIGH. All required ingredients (closure of submodules, invariance of closures under continuous maps, adjoint properties) are available in Mathlib. The proofs are straightforward applications of the existing infrastructure.
