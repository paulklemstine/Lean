# Future Directions: Spectral Theory of Self-Adjoint Operators

## Synthesis

The formalized spectral theory package establishes a variational-operational core: reality of expectation values, polynomial spectral mapping, eigenvalue positivity, and operator monotonicity. These results create a foundation from which three major research threads emerge: (1) extending to existence theorems and spectral decomposition via compactness arguments, (2) bridging to verified quantum mechanics and certified numerical methods, and (3) exploring the tropical-classical analogy as a unifying variational framework. Each direction below builds directly on the verified theorems and offers concrete falsifiable predictions.

---

## Direction 1: Existence of Extremal Eigenvectors via Compactness

**Conjecture:** For any self-adjoint operator `T : E →L[ℂ] E` on a finite-dimensional Hilbert space with `dim E ≥ 1`, there exist unit vectors `v_max` and `v_min` such that `T v_max = λ_max • v_max`, `T v_min = λ_min • v_min`, and `λ_min ≤ selfAdjointRayleigh T x ≤ λ_max` for all unit vectors `x`.

**Test:** Formalize in Lean 4 using `FiniteDimensional ℂ E`. The proof should use:
- `IsCompact (Metric.sphere (0 : E) 1)` for the unit sphere in finite dimension
- `IsCompact.exists_isMaxOn` and `IsCompact.exists_isMinOn`
- A perturbation/derivative argument showing maximizers satisfy the eigenvalue equation
- Verify with `#print axioms` that only standard axioms are used

**Impact:** Completes the variational eigenvalue theorem (Courant-Fischer for the extremal case), connecting optimization to spectral decomposition. This is the gateway to the full min-max principle.

**Catalog References:** Builds directly on `eigenvalue_real_of_selfAdjoint`, `eigenvalue_nonneg_of_inner_nonneg`, and `selfAdjointRayleigh` from `Speculative/SpectralSelfAdjoint/Basic.lean`.

**Proof Strategy:** (1) Show continuity of `selfAdjointRayleigh T` on `E \ {0}`. (2) Restrict to the unit sphere (compact in finite dim). (3) Apply `IsCompact.exists_isMaxOn`. (4) At a maximum point `v`, show `T v - R(v) • v ⊥ w` for all `w` by analyzing `R(v + tw)` at `t = 0`. (5) Conclude `T v = R(v) • v`.

**Domain Bridges:** Connects functional analysis (compactness) → optimization (extremization) → linear algebra (eigenvalues).

**Lineage:** Extends polynomial spectral mapping (Theorem 2) from "given an eigenvector, compute" to "prove eigenvectors exist."

**Ambition:** Medium-high. The mathematical argument is standard but formalization requires careful interaction with Mathlib's topology and finite-dimensional infrastructure.

---

## Direction 2: Compact Operator Spectral Theorem

**Conjecture:** For a compact self-adjoint operator `T` on an infinite-dimensional Hilbert space, the spectrum consists of at most countably many eigenvalues accumulating only at 0, and there exists a complete orthonormal system of eigenvectors.

**Test:** 
1. Define `IsCompactOperator T` (this exists in Mathlib as `IsCompactOperator`).
2. Formalize the statement that eigenspaces for distinct eigenvalues are orthogonal.
3. Prove eigenvalues have finite multiplicity.
4. Prove eigenvalues form a sequence converging to 0.
5. Computational test: for integral operators with known spectra (e.g., Hilbert-Schmidt kernels), verify the eigenvalue sequence converges to 0 at the predicted rate.

**Impact:** This is the infinite-dimensional analogue of matrix diagonalization and the foundation for quantum mechanics of bound states, Fredholm theory, and spectral methods for PDEs.

**Catalog References:** Extends `eigenvalue_real_of_selfAdjoint` and `eigenvalue_monotone_of_quadform_le` from `Speculative/SpectralSelfAdjoint/Basic.lean`. Could potentially connect to `finite_core_of_totally_bounded` from the catalog for discretization arguments.

**Proof Strategy:** (1) Prove orthogonality of eigenspaces for distinct eigenvalues using `inner_selfAdjoint_apply_conj`. (2) Use compactness of `T` and boundedness of the unit ball to show eigenvalues are bounded. (3) Show that for any ε > 0, the number of eigenvalues with |λ| > ε is finite. (4) Construct the eigenvector system via iterative restriction to orthogonal complements.

**Domain Bridges:** Functional analysis → operator algebras → quantum mechanics (bound states) → PDE theory (Green's functions).

**Lineage:** Grand challenge building on all core theorems.

**Ambition:** High. This is a significant formalization effort but would be a landmark result for the Lean ecosystem.

---

## Direction 3: Polynomial Positivity Transfer (Falsifiable Conjecture)

**Conjecture:** Let `T` be finite-dimensional self-adjoint with spectrum in `[a, b]`, and let `p ∈ ℝ[X]` satisfy `p(t) ≥ 0` for all `t ∈ [a, b]`. Then `∀ x, 0 ≤ Re(⟪p(T)x, x⟫)`.

**Test:** 
1. **Computational falsification:** Generate 10,000 random Hermitian matrices (dimensions 2-10) and random nonneg polynomials on their spectral intervals. Check `Re(⟪p(T)x, x⟫) ≥ 0` for 100 random unit vectors per matrix. A single negative value disproves the conjecture (or reveals a bug).
2. **Formal verification:** If the conjecture holds computationally, formalize in Lean using the finite-dimensional spectral decomposition `T = Σ λ_i |v_i⟩⟨v_i|`.

**Impact:** Establishes that positivity of a polynomial on the spectrum implies positivity of the operator polynomial — the foundation for SOS (sum-of-squares) optimization certificates in spectral theory.

**Catalog References:** Builds on `eigenvalue_nonneg_of_inner_nonneg` and `polynomial_apply_eigenvector` from `Speculative/SpectralSelfAdjoint/Basic.lean`.

**Proof Strategy:** (A) Reduce to diagonal case using spectral decomposition. (B) For diagonal `T = diag(λ_1, ..., λ_n)`, `⟪p(T)x, x⟫ = Σ p(λ_i)|x_i|²`. Since `p(λ_i) ≥ 0` and `|x_i|² ≥ 0`, the sum is nonneg.

**Domain Bridges:** Spectral theory → polynomial optimization (SOS) → semidefinite programming → control theory.

**Lineage:** Direct extension of eigenvalue positivity (Theorem 5).

**Ambition:** Medium. The proof strategy via spectral decomposition is clear; the formalization challenge is having the decomposition available.

---

## Direction 4: Tropical-Classical Spectral Duality

**Conjecture:** For families of discretized Schrödinger operators `H_n` on finite graphs, the ordering of the largest eigenvalue correlates monotonically with the ordering of the tropical (max-plus) cycle mean of the corresponding weight matrix, under perturbation of the potential.

**Test:**
1. Fix a graph topology (e.g., path graph on `n` vertices).
2. Parameterize the potential `V(i) = V_0 + ε · f(i)` for various perturbation functions `f`.
3. Compute: (a) largest eigenvalue of `H = -Δ + V` (classical Hermitian), (b) maximum cycle mean of the weight matrix `W_{ij} = V(i) · δ_{ij} + t · A_{ij}` (tropical).
4. Plot both quantities against the perturbation parameter `ε` and test monotone correlation.
5. A systematic violation (e.g., classical eigenvalue increases while tropical cycle mean decreases under the same perturbation) disproves the conjecture.

**Impact:** Would establish a rigorous bridge between classical spectral theory and tropical geometry, potentially leading to tropical approximations for eigenvalue problems.

**Catalog References:** Connects to `tropical_min_max_duality` and `exists_bounded_cycle_mean_le` from the catalog's tropical theory. Builds on `eigenvalue_monotone_of_quadform_le` from `Speculative/SpectralSelfAdjoint/Basic.lean`.

**Proof Strategy:** For the monotonicity direction: if `V_1 ≤ V_2` entry-wise, then `H_1 ≤ H_2` in quadratic form sense, so `λ_max(H_1) ≤ λ_max(H_2)` by `eigenvalue_monotone_of_quadform_le`. For the tropical side, monotonicity of cycle means under entry-wise increase of weights follows from the definition. The question is whether these two monotonicity principles align for the same perturbation families.

**Domain Bridges:** Spectral theory → tropical geometry → combinatorial optimization → mathematical physics.

**Lineage:** Grand challenge connecting two independent mathematical frameworks.

**Ambition:** High (grand challenge). This is speculative but scientifically daring — a positive result would open a new field.

---

## Direction 5: Certified Eigenvalue Enclosures via Interval Arithmetic

**Conjecture:** By combining the `SpectralBound` structure with verified interval arithmetic, one can produce machine-checked certificates that specific eigenvalues of concrete matrices lie within given intervals, with proofs that are independently verifiable.

**Test:**
1. Implement a certified `SpectralBound` computation for explicit numerical matrices in Lean 4 using `native_decide` or `Decidable` instances.
2. For a 3×3 Hermitian matrix with known eigenvalues, produce a `SpectralBound` certificate with width < 10⁻⁶.
3. Verify the certificate using `#eval` or `decide` in Lean.
4. Compare with uncertified numerical computation (NumPy `eigh`) to check for any discrepancy.

**Impact:** Creates a bridge between formal mathematics and numerical computation — the first step toward a "verified LAPACK."

**Catalog References:** Builds directly on `SpectralBound` and `SpectralBound.shift_nonneg` from `Speculative/SpectralSelfAdjoint/Basic.lean`. Could connect to `feasibleChannelSet_bounded` from the catalog for applications to information-theoretic operators.

**Proof Strategy:** (1) Implement Gershgorin circle theorem in Lean with rational arithmetic. (2) For tighter bounds, implement bisection on the Rayleigh quotient with interval arithmetic. (3) Package results as `SpectralBound` instances. (4) Use `shift_nonneg` to convert bounds into positivity certificates.

**Domain Bridges:** Formal verification → numerical analysis → scientific computing → engineering certification.

**Lineage:** Direct application of SpectralBound infrastructure.

**Ambition:** Medium. The mathematical content is straightforward; the challenge is Lean's computational infrastructure for interval arithmetic.
