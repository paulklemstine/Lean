# Future Directions: Tropical Spectral Mechanics

## Synthesis

The formalization of tropical spectral mechanics — establishing the tropical variational principle, Lipschitz stability, and eigenpair-eigenvalue relationship — opens several research frontiers. The core insight is that the principle of least action is a tropical eigenvalue problem, with the minimum cycle mean playing the role of the ground state energy. The verified theorems provide a rigorous foundation for extending this bridge in five directions: (1) completing the tropical Perron-Frobenius theorem, (2) establishing a tropical data processing inequality, (3) connecting tropical spectral data to quantum-mechanical ground states, (4) proving Lipschitz stability beyond the eigenvalue to the eigenvector, and (5) characterizing the critical graph structure for non-degenerate potentials. These directions range from immediate formalizations building directly on the existing Lean code to grand-challenge conjectures connecting tropical geometry to quantum field theory.

---

## Direction 1: Complete Tropical Perron-Frobenius

**Conjecture:** For an irreducible min-plus matrix $T \in \mathbb{R}^{n \times n}$ (equivalently, a strongly connected weighted digraph), there exists a unique (up to additive constant) tropical eigenvector $v^*$ satisfying $\min_j (T_{ij} + v^*_j) = \lambda^* + v^*_i$, where $\lambda^*$ is the minimum cycle mean. The eigenvector can be constructed as $v^*(i) = \lim_{N \to \infty} [\text{minCostPath}(T, N, r, i) - N\lambda^*]$ for any reference vertex $r$, and the convergence is eventually periodic with period dividing the cyclicity of the critical graph.

**Test:** Formalize the construction in Lean 4, proving: (a) existence of $v^*$ via the limit construction, (b) uniqueness modulo additive constants, (c) the eigenvector equation. Computationally verify for random $n \times n$ matrices with $n = 3, 5, 10, 20$.

**Impact:** Completes the tropical analogue of the spectral theorem and provides constructive eigenvector computation. This is the natural next theorem after the results in `Pythagorean/TropicalAction/Spectrum.lean`.

**Catalog References:** `Pythagorean/TropicalAction/Defs.lean` (IsTropEigenpair), `Pythagorean/TropicalAction/Spectrum.lean` (eigenpair_implies_eigenvalue_le)

**Proof Strategy:** Define the potential $\phi_N(i) = \text{minCostPath}(T, N, r, i) - (N+1)\lambda^*$. Show $\phi_N$ is bounded using the min-cost path bounds. Extract a convergent subsequence by Bolzano-Weierstrass on $[-M, M]^n$. Show the limit satisfies the eigenvector equation by passing the Bellman recursion to the limit. Uniqueness follows from the contraction property in Hilbert's projective metric.

**Domain Bridges:** Tropical geometry ↔ functional analysis (Hilbert metric), tropical geometry ↔ ergodic theory (invariant measures)

**Lineage:** Extends eigenpair_implies_eigenvalue_le from one direction to a full equivalence.

**Ambition:** 🟡 Solid extension — well-established in the literature but not yet formalized.

---

## Direction 2: Tropical Data Processing Inequality

**Conjecture:** For a discrete mechanical system with tropical eigenvalue $\lambda^*$ and spectral gap $\gamma > 0$, define the tropical mutual information between initial state $X_0$ and state $X_N$ after $N$ steps as $I_\oplus(X_0; X_N) = \max_{i,j} [\text{minCostPath}(L, N, i, j) - \text{minCostPath}(L, N, i_0, j)]$. Then $I_\oplus(X_0; X_N) \leq C \cdot \exp(-N\gamma)$ for some constant $C$ depending only on $L$.

**Test:** (a) Formalize the definition of tropical mutual information. (b) Prove the inequality for $N$ a multiple of the cyclicity. (c) Computationally verify the exponential decay rate for $5 \times 5$ and $10 \times 10$ random matrices.

**Impact:** Establishes the tropical analogue of the fundamental mixing time result for Markov chains, with the spectral gap playing the role of the log-Sobolev constant.

**Catalog References:** `Pythagorean/TropicalAction/Defs.lean` (tropSpectralGap), `Pythagorean/TropicalAction/Spectrum.lean` (minCostPath_lipschitz)

**Proof Strategy:** Use the min-plus path decomposition from `minCostPath_lipschitz` to show that the difference $\text{minCostPath}(L, N, i, j) - N\lambda^*$ converges to $v^*(j) - v^*(i)$ at rate $\exp(-N\gamma)$, where the spectral gap controls the separation between the critical cycle and all other cycles. The tropical mutual information then decays because it measures the dependence on the initial state, which vanishes as $N \to \infty$.

**Domain Bridges:** Tropical geometry ↔ information theory (channel capacity), tropical geometry ↔ Markov chain theory (mixing times)

**Lineage:** Builds on minCostPath_lipschitz and tropSpectralGap definition.

**Ambition:** 🔴 Grand challenge — a new information-theoretic inequality in the tropical setting.

---

## Direction 3: Tropical-Quantum Ground State Correspondence

**Conjecture:** For the harmonic oscillator $L(q, \dot{q}) = \frac{1}{2}\dot{q}^2 - \frac{1}{2}\omega^2 q^2$ discretized on $[0,1]$ with $M$ grid points, the tropical eigenvector $v^*_M$ (suitably normalized) converges as $M \to \infty$ to $-\frac{1}{2}\omega q^2$ — the logarithm of the ground state wave function $|\psi_0(q)|^2 \propto \exp(-\omega q^2)$ of the corresponding quantum Hamiltonian.

**Test:** (a) Compute the tropical eigenvector for $M = 10, 20, 50, 100, 200$. (b) Fit $v^*_M$ to a quadratic $aq^2 + bq + c$. (c) Check that $a \to -\omega/2$ as $M \to \infty$. (d) Repeat for anharmonic potentials and compare to WKB approximations.

**Impact:** Would establish a rigorous bridge between tropical spectral theory and quantum mechanics, showing that the tropical eigenvector encodes the semiclassical ground state.

**Catalog References:** `Pythagorean/TropicalAction/Defs.lean` (IsTropEigenpair), `Catalog/FINAL/Physics/TropicalVacuumEnergy.lean` (tropical_vacuum_energy_eq_minimal_action)

**Proof Strategy:** Use the Maslov dequantization framework: as $\hbar \to 0$, the Schrödinger equation becomes the Hamilton-Jacobi equation, and the ground state eigenfunction $\psi_0$ concentrates on $\exp(-S_0/\hbar)$ where $S_0$ is Hamilton's principal function. The tropical eigenvector should equal $S_0$ at the grid points. Prove this by showing that the discrete tropical eigenvector equation converges to the viscosity solution of the Hamilton-Jacobi equation.

**Domain Bridges:** Tropical geometry ↔ quantum mechanics (semiclassical limit), tropical geometry ↔ PDE theory (viscosity solutions)

**Lineage:** Builds on TropicalVacuumEnergy.lean and the tropical eigenvector construction.

**Ambition:** 🔴 Grand challenge — paradigm-shifting if true, connecting tropical mathematics to quantum mechanics.

---

## Direction 4: Tropical Eigenvector Lipschitz Stability

**Conjecture:** For strongly connected discrete mechanical systems with spectral gap $\gamma > 0$, the tropical eigenvector (normalized so $v^*(0) = 0$) is $\gamma^{-1}$-Lipschitz in the Lagrangian:
$$\|v^*_1 - v^*_2\|_\infty \leq \frac{1}{\gamma} \|L_1 - L_2\|_\infty$$

**Test:** (a) Formalize the statement in Lean 4, building on `tropEigenvalue_lipschitz`. (b) Verify computationally for random matrices. (c) Prove or disprove by constructing explicit perturbation examples near the spectral gap threshold.

**Impact:** Extends the eigenvalue Lipschitz result (Theorem 5.2) to the eigenvector. The $\gamma^{-1}$ factor shows that systems with small spectral gaps have fragile ground states — a tropical analogue of spectral sensitivity in quantum chemistry.

**Catalog References:** `Pythagorean/TropicalAction/Spectrum.lean` (tropEigenvalue_lipschitz, eigenvector_lower_bound)

**Proof Strategy:** Use the contraction mapping theorem in Hilbert's projective metric. The min-plus matrix acts as a contraction with ratio $\tanh(\Delta/4)$ where $\Delta$ is the Hilbert diameter. Relate $\Delta$ to the spectral gap $\gamma$. The Lipschitz constant of the fixed point with respect to the operator follows from the inverse of the contraction gap.

**Domain Bridges:** Tropical geometry ↔ functional analysis (contraction mappings), tropical geometry ↔ perturbation theory

**Lineage:** Direct extension of tropEigenvalue_lipschitz.

**Ambition:** 🟡 Solid extension — the eigenvalue case is proved; the eigenvector case requires additional machinery.

---

## Direction 5: Critical Graph Primitivity for Non-Degenerate Potentials

**Conjecture:** For a discrete mechanical system arising from a smooth Lagrangian $L(q, \dot{q}) = T(\dot{q}) - V(q)$ with $T$ strictly convex and $V$ having a unique global minimum, the critical graph (the subgraph of edges and vertices participating in optimal cycles) has cyclicity 1 (is primitive). This implies that the projective convergence in the tropical Perron-Frobenius theorem holds without periodicity corrections.

**Test:** (a) Compute the critical graph for discretizations of the harmonic oscillator ($V = q^2$), double-well potential ($V = (q^2 - 1)^2$), and random smooth potentials. (b) Check that the cyclicity is 1 in all non-degenerate cases. (c) Construct a degenerate example where cyclicity $> 1$ (e.g., $V = 0$ on a discrete torus).

**Impact:** Primitivity of the critical graph eliminates the need for periodicity corrections in the convergence theorem, simplifying the theory significantly for physical systems.

**Catalog References:** `Pythagorean/TropicalAction/Defs.lean` (tropEigenvalue, cycleMean), `Pythagorean/TropicalAction/Basic.lean` (tropEigenvalue_achieved)

**Proof Strategy:** Show that strict convexity of $T$ implies that the optimal cycle uses edges with small velocity (nearby grid points), and uniqueness of the potential minimum implies the optimal cycle passes through the minimum-potential region. Argue that the GCD of cycle lengths in this region is 1 by constructing two cycles of coprime lengths passing through the potential minimum.

**Domain Bridges:** Tropical geometry ↔ dynamical systems (ergodic optimization), tropical geometry ↔ graph theory (strongly connected digraphs)

**Lineage:** Builds on tropEigenvalue_achieved and the cycle mean structure.

**Ambition:** 🟡 Solid extension — graph-theoretic argument with physical content.
