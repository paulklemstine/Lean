# Future Directions: Invariant Subspace Theory

## Synthesis

This research cycle established a formally verified foundation for invariant subspace theory on complex Hilbert spaces, extending the existing compact operator results with three new pillars: hyperinvariant subspace theory, the cyclic vector reformulation, and the spectral decomposition depth invariant. The most promising cross-domain connection emerged between **operator theory and quantum mechanics**: the orthogonality of self-adjoint eigenspaces (Theorem `selfAdjoint_eigenspaces_orthogonal`) and the reducing subspace property (Theorem `selfAdjoint_eigenspace_ortho_invariant`) provide the exact mathematical infrastructure needed to formalize quantum measurement theory. The spectral decomposition depth introduces a quantitative invariant that could bridge the gap between known positive cases (compact, normal) and the general ISP.

The cycle's key insight is that the ISP has a *dynamical* reformulation via cyclic vectors (Theorem `ISP_of_no_cyclic_vector`): the problem is equivalent to asking whether bounded linear dynamics can be "totally ergodic." This connects operator theory to ergodic theory and topological dynamics in a way that could import new proof techniques. The Enflo-Read obstruction theorem (`noISP_implies_no_compact_eigenvalue`) establishes precise necessary conditions for counterexamples, constraining the search space.

The highest breakthrough potential lies in Direction 1 (Lomonosov's full theorem), which would significantly extend the class of operators known to have the ISP. Direction 3 (spectral depth dichotomy) offers the most testable predictions and could yield surprising counterexamples to the conjecture even if the ISP itself holds.

---

### Direction 1: Lomonosov's Full Theorem via Schauder Fixed Point

**Conjecture**: Every nonzero compact operator $K$ on an infinite-dimensional complex Hilbert space $H$ has the property that every operator $T$ commuting with $K$ has a nontrivial hyperinvariant subspace — even when $K$ has no nonzero eigenvalues (the quasinilpotent case).

**Test**: Formalize the Schauder fixed-point theorem in Lean 4 (if not already in Mathlib), then use it to prove that for any nonzero compact $K$ and any $T$ commuting with $K$, there exists a nonzero vector $x$ with $K(B(x,1) \cap \text{CommutantOrbit}(T,x)) \cap B(x,1) \neq \emptyset$, where $B(x,1)$ is the closed unit ball centered at $x$. The fixed point yields an invariant subspace.

**Impact**: This would extend our current formalization from "compact operators with nonzero eigenvalues" to "all nonzero compact operators," covering the quasinilpotent case. It would also produce hyperinvariant (not just invariant) subspaces, which is strictly stronger.

**Catalog References**: `Catalog/Algebra/CompactOperators.lean` (compact eigenspace theory), `Catalog/Algebra/InvariantSubspaceProblem.lean` (ISP foundations)

**Proof Strategy**:
1. Formalize the Schauder fixed-point theorem: every continuous map of a compact convex subset of a locally convex topological vector space has a fixed point.
2. Define the "Lomonosov map" $\phi(x) = \frac{Kx}{\|Kx\|}$ restricted to a suitable compact convex set.
3. Show that the commutant orbit of a fixed point generates a hyperinvariant subspace.
4. Handle the quasinilpotent case by showing that $K \neq 0$ implies the map is well-defined on a suitable domain.

**Domain Bridges**: Algebra <-> Topology (fixed-point theory), Algebra <-> Physics (quantum observable commutants)

**Lineage**: Builds on `compact_eigenspace_is_hyperinvariant` and `noISP_implies_no_compact_eigenvalue` from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Weighted Shift Classification and ISP

**Conjecture**: Every weighted shift operator $S_w$ on $\ell^2(\mathbb{N})$ with weights $(w_n)$ satisfying $\inf_n |w_n| > 0$ has a nontrivial invariant subspace if and only if the weight sequence $(w_n)$ is not eventually strictly increasing to infinity.

**Test**: For the following concrete weight sequences, compute invariant subspaces of $100 \times 100$ truncations:
- $w_n = 1$ for all $n$ (unweighted shift — known to have ISP via $H^2$ subspaces).
- $w_n = n/(n+1)$ (weights converging to 1 — ISP status should be testable).
- $w_n = \sqrt{n+1}$ (weights growing — this is the creation operator in quantum mechanics, known to have ISP).
- $w_n = 1 + (-1)^n / n$ (oscillating weights — novel test case).

Verify each $100 \times 100$ truncation has a nontrivial invariant subspace. If any fails, investigate the limit.

**Impact**: A classification of weighted shifts with ISP would resolve one of the most concrete special cases of the ISP and connect to the rich theory of Hardy spaces and composition operators.

**Catalog References**: `Catalog/Algebra/InvariantSubspaceProblem.lean`, `Catalog/Algebra/SpectralTheory.lean`

**Proof Strategy**:
1. Define weighted shift operators formally as `(S_w x)_n = w_{n-1} x_{n-1}` for $n \geq 1$.
2. Show that $\{e_n, e_{n+1}, \ldots\}$ spans an invariant subspace when weights are bounded.
3. For the general case, use the analytic function model: $S_w$ on $\ell^2$ is unitarily equivalent to multiplication by $z$ on a weighted Hardy space $H^2(w)$.
4. Classify invariant subspaces of multiplication by $z$ using Beurling's theorem for weighted spaces.

**Domain Bridges**: Algebra <-> Analysis (Hardy spaces), Algebra <-> Physics (creation/annihilation operators)

**Lineage**: Builds on `cyclicSubspace` and `ISP_of_no_cyclic_vector` from this cycle.

**Ambition**: extension

---

### Direction 3: Spectral Depth Dichotomy — Computational Exploration

**Conjecture**: For every bounded operator $T$ on a separable infinite-dimensional Hilbert space, the spectral decomposition depth $\text{sd}(T)$ is either $0$ or $\infty$.

**Test**: Implement the following computational protocol:
1. For dimensions $n = 50, 100, 200, 500$, construct random weighted shift operators with 5 different weight patterns (periodic, quasiperiodic, random, exponentially decaying, polynomial growth).
2. For each operator, compute the truncated spectral depth using 1000 random compact commutant candidates.
3. Plot spectral depth vs. dimension for each weight pattern.
4. If depth is $0$ for small $n$ but positive for large $n$, or vice versa, investigate the transition.

The conjecture predicts: periodic weights give depth growing with $n$ (converging to $\infty$), while aperiodic weights give depth $0$ for all $n$. An intermediate regime would disprove the conjecture.

**Impact**: If true, the dichotomy would constrain the ISP: operators with $\text{sd}(T) \geq 1$ automatically have the ISP (by the compact eigenvalue theorem), so the conjecture reduces the ISP to operators with $\text{sd}(T) = 0$. If false, the failure mode reveals new structure in the commutant of operators.

**Catalog References**: `Catalog/Algebra/CompactOperators.lean`, `Catalog/Algebra/SpectralArithmetic.lean`

**Proof Strategy**:
1. Show that $\text{sd}(T) \geq 1$ implies $T$ has ISP (already proved as `ISP_of_spectralDecompDepth_pos` — needs strengthening).
2. For normal operators, prove $\text{sd}(T) = \infty$ using the spectral measure.
3. For operators with Enflo-Read obstruction, prove $\text{sd}(T) = 0$ (already proved as `noISP_implies_no_compact_eigenvalue`).
4. Investigate whether intermediate values are possible by constructing explicit examples.

**Domain Bridges**: Algebra <-> Computation (numerical spectral analysis), Algebra <-> Physics (quantum spectral theory)

**Lineage**: Builds on `spectralDecompDepth` and `SpectralDepthDichotomyConjecture` from this cycle.

**Ambition**: grand_challenge

---

### Direction 4: Quantum Measurement Formalization via Reducing Subspaces

**Conjecture**: Every self-adjoint operator $T$ on a separable Hilbert space admits a countable decomposition into mutually orthogonal reducing subspaces corresponding to its spectral measure. This decomposition formalizes the quantum measurement postulate: measurement of an observable $T$ produces an eigenvalue $\lambda$ and collapses the state into the corresponding eigenspace.

**Test**: Formalize the spectral theorem for compact self-adjoint operators as a countable direct sum decomposition $H = \bigoplus_{n} E_{\lambda_n}$, where $E_{\lambda_n}$ are the eigenspaces. Verify that:
1. Each $E_{\lambda_n}$ is reducing (proved in this cycle for individual eigenspaces).
2. The eigenspaces are mutually orthogonal (proved as `selfAdjoint_eigenspaces_orthogonal`).
3. The sum is dense in $H$ (requires the spectral theorem).
4. The projection-valued measure $P_{\lambda_n}$ satisfies $T = \sum_n \lambda_n P_{\lambda_n}$.

**Impact**: A fully formalized spectral theorem for compact self-adjoint operators would be a significant Mathlib contribution and would provide rigorous foundations for quantum mechanics formalization.

**Catalog References**: `Catalog/Algebra/InvariantSubspaceProblem.lean` (reducing subspaces), `Catalog/Algebra/SelfAdjoint.lean`, `Catalog/Algebra/SpectralTheory.lean`

**Proof Strategy**:
1. Use the existing `selfAdjoint_eigenspaces_orthogonal` and `selfAdjoint_eigenspace_ortho_invariant` as building blocks.
2. For compact self-adjoint operators, use the fact that eigenvalues form a sequence converging to 0.
3. Construct the direct sum decomposition using `Submodule.isInternal` or `DirectSum`.
4. Prove the spectral resolution formula using the orthogonal projection onto each eigenspace.

**Domain Bridges**: Algebra <-> Physics (quantum mechanics), Algebra <-> Analysis (spectral theory)

**Lineage**: Builds on `selfAdjoint_eigenspaces_orthogonal` and `selfAdjoint_eigenspace_ortho_invariant` from this cycle.

**Ambition**: extension

---

### Direction 5: Invariant Subspace Lattice and Computational Algebra

**Conjecture**: For a finite-dimensional operator $T$ on $\mathbb{C}^n$ with $k$ distinct eigenvalues and Jordan block structure $(n_1, \ldots, n_k)$, the number of invariant subspaces is exactly $\prod_{i=1}^{k} G(n_i)$ where $G(m)$ is the number of subspaces of $\mathbb{C}^m$ invariant under a single Jordan block of size $m$.

**Test**: For Jordan blocks of size $m$, enumerate invariant subspaces computationally:
- $m = 1$: $G(1) = 2$ (trivial cases $\{0\}$ and $\mathbb{C}$).
- $m = 2$: $G(2) = 3$ ($\{0\}$, $\ker T$, $\mathbb{C}^2$).
- $m = 3$: $G(3) = 4$ ($\{0\}$, $\ker T$, $\ker T^2$, $\mathbb{C}^3$).
- Conjecture: $G(m) = m + 1$ for all $m$.

Verify computationally for $m \leq 10$, then prove formally.

**Impact**: A complete classification of invariant subspace lattices for finite-dimensional operators would provide a rigorous base case for the ISP and connect to the combinatorics of partition theory.

**Catalog References**: `Catalog/Algebra/InvariantSubspaceProblem.lean` (lattice closure properties), `Catalog/Algebra/FiniteDimensional.lean`

**Proof Strategy**:
1. Prove that invariant subspaces of a single Jordan block $J_m$ are exactly $\ker J_m^k$ for $0 \leq k \leq m$.
2. Use the formalized intersection and sum closure (from `iInf_invariant_closed` and `invariantSubspace_sup_invariant`) to construct the full lattice.
3. Show that for operators with multiple Jordan blocks, invariant subspaces decompose as products.
4. Count using the product formula.

**Domain Bridges**: Algebra <-> Combinatorics (lattice theory), Algebra <-> Computation (algorithmic enumeration)

**Lineage**: Builds on `iInf_invariant_closed`, `invariantSubspace_sup_invariant`, and `finiteDimensional_ISP` from this cycle.

**Ambition**: extension
