# Future Directions: Tropical Shadows of Lorentzian Stability

## Synthesis

The tropical shadow framework establishes a new computational language for Lorentzian stability, replacing eigenvalue computation with combinatorial gap analysis. The proved theorems—perturbation stability, uniform exactness, exchange defect equivalence—form a foundation that can be extended in several directions. The key unifying theme is that **tropical invariants capture asymptotic stability behavior**, and this principle should generalize far beyond the 2×2 minor gap studied here. The directions below range from immediate extensions (higher-order minors, sparse certification) to grand challenges (full Maslov dequantization, quantum information bridges). Each direction builds on the Catalog's existing infrastructure while opening new domain connections.

---

## Direction 1: Higher-Order Tropical Minors and Tighter Bounds

**Conjecture:** For an $n \times n$ symmetric weight matrix, the $k \times k$ tropical minor gap
$$\text{tGap}_k(w) = \min_{|S|=k} \left(\sum_{i \in S} w_{ii} - \frac{2}{k} \sum_{\{i,j\} \subset S} w_{ij}\right)$$
provides a tighter stability bound than the $2 \times 2$ gap, with $\text{tGap}_2 \leq \text{tGap}_3 \leq \cdots \leq \text{tGap}_n$ and the stability radius controlled by $\text{tGap}_n / n^2$.

**Test:** Compute $\text{tGap}_k$ for $k = 2, 3, 4$ on random diagonally dominant matrices of size $n = 10, 20, 50$. Verify the monotonicity inequality. Compare the resulting stability bounds against empirical radii.

**Impact:** A factor-of-$n$ improvement in stability bounds for structured matrices. Would make the tropical approach competitive with exact eigenvalue methods for moderate $n$.

**Catalog References:**
- `Pythagorean/TropicalShadows.lean` — `tropicalSpectralGap`, `diagonalMinorGap_perturbation_bound`
- `Catalog/Tropical/Matrix/Defs.lean` — tropical matrix infrastructure

**Proof Strategy:** Generalize the perturbation bound proof from 2×2 to $k \times k$ by induction on $k$. The key step is showing that the $k \times k$ gap changes by at most $2k\varepsilon$ under $\varepsilon$-perturbation (triangle inequality applied to $k$ diagonal and $\binom{k}{2}$ off-diagonal terms).

**Domain Bridges:** Numerical linear algebra (higher-order condition numbers), statistical physics (cluster expansions).

**Lineage:** Direct extension of Theorems 1 and 3.

**Ambition:** Solid extension. ★★☆

---

## Direction 2: Full Maslov Dequantization Theorem

**Conjecture:** For every tropically PSD weight $w$ with positive gap, weight vector $\omega: \sigma \to \mathbb{R}$, and rescaled weight $w_t(i,j) = w(i,j) + (\omega_i + \omega_j)\log t$:
$$\lim_{t \to \infty} \frac{\text{tGap}(w_t)}{\log t} = 2 \min_{i \neq j} (\omega_i + \omega_j - 2\omega_{\text{avg}}(i,j))$$
where $\omega_{\text{avg}}(i,j)$ is a weighted average depending on the structure of $w$.

**Test:** Compute $\text{tGap}(w_t)/\log t$ for $t = 10, 100, 1000, 10000$ with $\omega = (1, 2, 3, 4)$ on uniform and random weights. Check convergence.

**Impact:** Would complete the bridge between analytic stability theory and tropical combinatorics. A clean asymptotic formula would enable instant stability estimation for parameterized families.

**Catalog References:**
- `Pythagorean/TropicalShadows.lean` — `weightedRescale`, `maslov_weak_positivity`, `tropicalSpectralGap_shift_invariant`
- `Catalog/Tropical/SemiclassicalLimit.lean` — Maslov dequantization infrastructure

**Proof Strategy:** For non-constant $\omega$, the rescaling is NOT a global shift. The diagonal minor gap becomes $\Delta_t(i,j) = \Delta(i,j) + 2(\omega_i + \omega_j - \omega_i - \omega_j)\log t$... wait, this simplifies to $\Delta(i,j)$ only if $\omega$ is constant. For general $\omega$: $\Delta_t(i,j) = \Delta(i,j) + (2\omega_i + 2\omega_j - 2\omega_i - 2\omega_j)\log t$... The shift terms don't cancel in general. Need careful analysis of which pair achieves the minimum as $t$ varies.

**Domain Bridges:** Semiclassical physics (WKB approximation), statistical mechanics (zero-temperature limits), information theory (rate-distortion dequantization).

**Lineage:** Extends `maslov_weak_positivity` to non-constant $\omega$.

**Ambition:** Grand challenge. ★★★

---

## Direction 3: Sparse Tropical Certification

**Conjecture:** For a sparse symmetric weight matrix with $m$ nonzero entries, the tropical spectral gap can be computed in $O(m)$ time (rather than $O(n^2)$), and the stability bound can be improved to depend on the graph structure rather than the dimension.

**Test:** Generate sparse random diagonally dominant matrices with varying sparsity ($m/n^2$ from 0.01 to 1). Compare $O(m)$ sparse gap computation time against $O(n^2)$ dense computation. Verify that the sparse certificate is valid.

**Impact:** Enables tropical stability certification for million-node networks and sparse systems where eigenvalue methods are completely infeasible.

**Catalog References:**
- `Pythagorean/TropicalShadows.lean` — `TropicalGapCertificate`
- `Catalog/Tropical/BellmanFord.lean` — sparse tropical algorithms

**Proof Strategy:** For the gap computation, only pairs $(i,j)$ with nonzero $w_{ij}$ need checking (if $w_{ij} = -\infty$, the gap at $(i,j)$ is $+\infty$). For the stability bound, the perturbation only affects nonzero entries, so the effective bound depends on the maximum degree of the sparsity graph.

**Domain Bridges:** Network science (large-scale graph algorithms), database systems (sparse matrix operations), distributed computing (parallel certification).

**Lineage:** Extension of Theorem 2 (certificate) to sparse setting.

**Ambition:** Solid extension. ★★☆

---

## Direction 4: Quantum Information and Tropical Entanglement Witnesses

**Conjecture:** The tropical spectral gap of the log-weight matrix of a quantum state's density matrix provides a lower bound on the entanglement robustness—the minimum noise required to make the state separable. Specifically, for a bipartite state $\rho_{AB}$ with positive entries:
$$\text{EntanglementRobustness}(\rho) \geq \exp(\text{tGap}(\log \rho) / 4).$$

**Test:** Compute the tropical gap for Werner states $\rho = p|\Phi^+\rangle\langle\Phi^+| + (1-p)I/d^2$ at various $p$, and compare against the known entanglement threshold $p = 1/(d+1)$.

**Impact:** Would create a polynomial-time entanglement witness construction, circumventing the NP-hardness of general entanglement detection. The tropical certificate would be checkable in $O(d^2)$ time.

**Catalog References:**
- `Pythagorean/TropicalShadows.lean` — `tropicalGap_controls_stability`
- `Catalog/Tropical/QuantumTropical.lean` — quantum-tropical connections

**Proof Strategy:** The key observation is that separability of $\rho$ implies certain $2 \times 2$ submatrix conditions on $\rho$ (PPT criterion). These conditions tropicalize to diagonal minor gap conditions. The gap then controls how far $\rho$ is from the PPT boundary.

**Domain Bridges:** Quantum information theory, quantum computing (error correction thresholds), condensed matter physics (topological order robustness).

**Lineage:** New cross-domain application of the bridge theorem.

**Ambition:** Grand challenge. ★★★

---

## Direction 5: Tropical Phase Transitions in Statistical Mechanics

**Conjecture:** For the partition function $Z(\beta) = \sum_\sigma \exp(-\beta H(\sigma))$ of a classical spin system, the tropical spectral gap of the interaction matrix at inverse temperature $\beta$ controls the free energy gap:
$$\text{tGap}(w_\beta) = \beta \cdot \Delta_{\text{gap}} + O(\beta^{-1})$$
where $\Delta_{\text{gap}}$ is the spectral gap of the Hamiltonian and $w_\beta(i,j) = -\beta J_{ij}$ for coupling constants $J_{ij}$.

**Test:** Compute the tropical gap for the 2D Ising model on small lattices ($L = 4, 6, 8$) at various temperatures. Compare against the known phase transition at $\beta_c = \log(1+\sqrt{2})/2$.

**Impact:** Would provide a combinatorial criterion for phase transitions that avoids Monte Carlo sampling. The tropical gap would serve as an order parameter.

**Catalog References:**
- `Pythagorean/TropicalShadows.lean` — `tropicalSpectralGap`, `tropicallyPSD_iff_nonneg_gap`
- `Catalog/Tropical/StatisticalMechanics/Basic.lean` — tropical stat mech
- `Catalog/Tropical/FreeEnergyPrinciple.lean` — free energy tropical connections

**Proof Strategy:** At low temperature ($\beta \to \infty$), the partition function is dominated by the ground state, and Maslov dequantization applies. The tropical gap captures the energy gap between ground and first excited state. The $O(\beta^{-1})$ correction comes from entropic contributions.

**Domain Bridges:** Statistical physics (phase transitions), materials science (stability of crystalline phases), machine learning (energy-based models, Boltzmann machines).

**Lineage:** Connects the Maslov conjecture to physical observables.

**Ambition:** Grand challenge. ★★★
