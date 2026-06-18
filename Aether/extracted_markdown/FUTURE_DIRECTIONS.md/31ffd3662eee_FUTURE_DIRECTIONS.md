# Future Research Directions

## Synthesis

This cycle established the **Divisor Energy Functional** as a bridge between chip-firing theory and spectral graph theory. The key discovery is that the energy $E_G(D) = \sum_{v \sim w} (D(v) - D(w))^2$ equals twice the Laplacian quadratic form, and on complete graphs $K_n$ equals twice the divisor variance. This connects three previously separate domains: Baker-Norine divisor theory (algebraic), spectral graph theory (analytic), and statistical dispersion (probabilistic).

The most promising cross-domain connection is between the energy spectrum (the set of energies achievable within a linear equivalence class) and the divisor rank from Baker-Norine theory. Since both are invariants of divisor classes, there should be a functional relationship between them. The energy spectrum is computable (via Laplacian eigenvalues), while the rank involves an existential quantifier over effective divisors. If we can bound rank in terms of minimum energy, we obtain an efficiently computable upper bound on divisor rank — with algorithmic implications for chip-firing solvability.

The formalized results connect to several existing Catalog entries: `genus_complete_graph` (from `EML/BakerNorine.lean`), `capacity_tight_for_complete_graph` (from `Bridges/TropicalInformationTheory.lean`), and the spectral graph theory barrier results in `Algebra/SpectralGraphTheory`. The energy functional should be viewed as the "missing link" between the combinatorial Baker-Norine theory and the analytic spectral theory.

---

### Direction 1: Rank-Energy Inequality for Graph Divisors

**Conjecture**: For a divisor $D$ on a connected graph $G$ of genus $g \geq 1$, the rank $r(D)$ satisfies:
$$r(D) \leq \frac{\deg(D)}{2} + \frac{1}{2} - \frac{E_{\min}([D])}{4g}$$
where $E_{\min}([D]) = \min\{E_G(D') : D' \sim D\}$ is the minimum energy in the divisor class. Equality holds for the canonical class.

**Test**: Compute $r(D)$ and $E_{\min}([D])$ for all divisor classes of degree $\leq 2g$ on $K_4$ (genus 3) and $K_5$ (genus 6). Verify the inequality for each class. Check tightness by examining which classes achieve equality.

**Impact**: If true, this provides an efficiently computable upper bound on divisor rank, since minimum energy can be found via the reduced Laplacian inverse. This would bridge the algebraic theory (rank) and the analytic theory (energy) in a quantitative way, and could lead to polynomial-time approximations for the NP-hard divisor rank computation.

**Catalog References**: `EML/BakerNorine.lean` (genus_complete_graph, divRank), `Algebra/ChipFiring/EnergySpectrum.lean` (energy_complete_eq_variance, divisorVariance_nonneg)

**Proof Strategy**: Start with the Baker-Norine Riemann-Roch theorem $r(D) - r(K-D) = \deg(D) + 1 - g$. The minimum energy of a divisor class is related to the distance of $D$ from the kernel of the Laplacian. Use the spectral gap $\lambda_1$ (smallest nonzero eigenvalue of the Laplacian) to bound $E_{\min} \geq \lambda_1 \cdot \|D - \bar{D}\|^2$ where $\bar{D}$ is the average. Then relate $\|D - \bar{D}\|$ to the failure of effectiveness via a counting argument.

**Domain Bridges**: Chip-firing combinatorics ↔ Spectral graph theory ↔ Tropical geometry

**Lineage**: Builds on `energy_complete_eq_variance`, `divisorVariance_nonneg`, and the Baker-Norine foundations from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Energy Spectrum as a Graph Invariant

**Conjecture**: For a fixed degree $d$, the multiset $\{E_{\min}([D]) : [D] \in \text{Pic}^d(G)\}$ of minimum energies over all divisor classes of degree $d$ determines the graph $G$ up to isomorphism (for 3-connected graphs).

**Test**: Compute the minimum energy multisets for all connected graphs on $\leq 8$ vertices. Find two non-isomorphic graphs with the same multisets, or prove they don't exist for small cases. Start with strongly regular graphs (known to be hard to distinguish).

**Impact**: If true, this gives a new polynomial-time computable graph invariant stronger than the spectrum. If false (and a counterexample is found), the counterexample pair would be mathematically interesting — it would show that "divisor geometry" cannot distinguish certain graphs that "vertex/edge geometry" can.

**Catalog References**: `Algebra/ChipFiring/EnergySpectrum.lean` (linEquiv_energySpectrum), `Algebra/SpectralGraphTheory`

**Proof Strategy**: For 3-connected graphs, Whitney's theorem gives edge-reconstruction. The energy spectrum encodes the Laplacian spectrum (via the quadratic form), and the Laplacian spectrum together with the degree sequence determines many graph properties. The key question is whether the *class-level* energy data (grouped by linear equivalence) encodes more information than the raw Laplacian spectrum.

**Domain Bridges**: Algebraic graph theory ↔ Spectral graph theory ↔ Graph isomorphism

**Lineage**: Builds on `linEquiv_energySpectrum` and `energySpectrum_bdd_below`.

**Ambition**: grand_challenge

---

### Direction 3: Tropical Dirichlet Energy on Metric Graphs

**Conjecture**: The divisor energy functional extends naturally to **metric graphs** (tropical curves) as the Dirichlet integral $E(f) = \int_{\Gamma} |f'(x)|^2 dx$, and the minimum energy within a divisor class equals $D^T L^+ D$ where $L^+$ is the Moore-Penrose pseudoinverse of the graph Laplacian.

**Test**: Compute the continuous Dirichlet energy for piecewise-linear functions on the metric graph $\Gamma$ underlying $K_4$ with uniform edge lengths. Compare with the discrete energy $E_{K_4}(D)$ and verify they agree (up to normalization by edge length).

**Impact**: This would provide a rigorous bridge between the discrete Baker-Norine theory and the continuous theory of divisors on tropical/metric curves. The pseudoinverse formula would give an explicit computation of minimum energy, enabling efficient algorithms.

**Catalog References**: `Bridges/TropicalInformationTheory.lean` (capacity_tight_for_complete_graph), `Tropical/GL3_ReconstructionFromRank2LeviProfiles.lean`

**Proof Strategy**: Define the metric graph Laplacian as a measure-valued operator. Show that the piecewise-linear functions on the metric graph form a finite-dimensional space isomorphic to the discrete divisor group. The Dirichlet energy on this space, restricted to integer-valued boundary conditions, recovers the discrete energy. The minimum is achieved by the harmonic extension, which equals $L^+ D$.

**Domain Bridges**: Chip-firing ↔ Tropical geometry ↔ Potential theory on metric spaces

**Lineage**: Builds on `energy_eq_twice_laplacianQuadForm` and the tropical bridge results.

**Ambition**: extension

---

### Direction 4: Chip-Firing Mixing Time via Energy Barriers

**Conjecture**: The mixing time of the random chip-firing Markov chain on $\text{Pic}^0(K_n)$ (where at each step a uniformly random vertex fires) satisfies $t_{\text{mix}} = \Theta(n^2 \log n)$. The energy functional provides the bottleneck: the maximum energy barrier between any two divisor classes determines the mixing time up to constants.

**Test**: Simulate the random chip-firing chain on $K_n$ for $n = 5, 6, 7, 8$ with $10^6$ steps each. Estimate the mixing time by measuring convergence to the uniform distribution on $\text{Pic}^0(K_n)$ (which has $n^{n-2}$ elements). Compare with the predicted $\Theta(n^2 \log n)$.

**Impact**: If true, this gives the first tight bound on chip-firing mixing times for complete graphs, using energy as the Lyapunov function. The technique could extend to arbitrary graphs via spectral gap estimates.

**Catalog References**: `Algebra/ChipFiring/Core.lean` (energy_nonneg, energy_smul, total_excess_zero)

**Proof Strategy**: Use the energy as a potential function for a conductance argument. The key is to show that the energy changes by $O(n)$ per chip-fire step (since one vertex changes by $\pm O(n)$), and the total energy range is $O(n^3)$. The mixing time is then bounded by $O(n^3/n) \cdot \log(n^{n-2}) = O(n^2 \log n)$.

**Domain Bridges**: Chip-firing dynamics ↔ Markov chain theory ↔ Spectral graph theory

**Lineage**: Builds on `energy_nonneg`, `chipFire_energy_in_spectrum`, and the Jacobian order computations.

**Ambition**: extension

---

### Direction 5: Weierstrass Gap Sequences via Energy Filtration

**Conjecture**: The Weierstrass gap sequence of a graph $G$ at vertex $v$ — the set of integers $n$ such that there is no divisor $D$ of degree $n$ with $r(D) \geq 1$ and $D(w) \geq 0$ for $w \neq v$ — can be characterized in terms of the energy filtration: $n$ is a gap if and only if the minimum energy over all divisor classes of degree $n$ with a "pole only at $v$" exceeds a threshold related to the spectral gap.

**Test**: Compute the Weierstrass gaps for $K_n$ at any vertex (by symmetry, all vertices give the same sequence). For $K_4$ (genus 3), the gaps should be $\{1, 2, 3\}$. For $K_5$ (genus 6), compute the 6 gaps. Verify the energy characterization.

**Impact**: The Weierstrass gap theorem ($|$gaps$|$ = $g$) is a fundamental result. An energy-theoretic characterization would provide algorithmic tools and connect to the tropical Weierstrass point theory.

**Catalog References**: `EML/BakerNorine.lean` (isQReduced, divRank), `Algebra/ChipFiring/EnergySpectrum.lean`

**Proof Strategy**: For each degree $n$, consider divisors $D$ with $D(w) \geq 0$ for $w \neq v$ and $\deg(D) = n$. The constraint $r(D) \geq 1$ means $D - w$ is equivalent to an effective divisor for every vertex $w$. The minimum energy of such $D$ is bounded below by a function of the spectral gap and the gap structure. Use q-reduced divisors as the canonical representatives to make this precise.

**Domain Bridges**: Algebraic geometry (Weierstrass points) ↔ Chip-firing ↔ Energy functional

**Lineage**: Builds on the full framework from this cycle, especially `divisorVariance_eq_zero_iff` and the effective divisor bounds.

**Ambition**: extension
