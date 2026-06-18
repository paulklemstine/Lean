# Future Directions: Tropical Canonical Forms on Metric Graphs

## Synthesis

The metric canonical kernel correspondence reveals that three seemingly independent mathematical structures — chip-firing equivalence classes, electrical resistance distances, and tropical Jacobian lattice quotients — are governed by a single algebraic object: the weighted Laplacian matrix. Our verified theorems (row-sum-zero, symmetry, PSD, leaf rigidity) provide the computational foundation, but the framework naturally extends in several powerful directions. The most immediate extensions exploit the explicitly computable canonical kernel generators to bridge into arithmetic geometry (via Baker's specialization lemma), statistical mechanics (via the Gaussian free field connection), and algorithmic graph theory (via Jacobian-based invariants). The grand challenges ask whether the lattice structure of the tropical Jacobian can be "lifted" to control arithmetic objects over number fields, and whether the chip-firing dynamics on metric graphs admit a continuous-time stochastic extension that connects to conformal field theory.

---

## Direction 1: Smith Normal Form for Rational Metric Graphs

**Conjecture:** For a metric graph Γ with rational edge lengths ℓ_e ∈ ℚ_{>0}, the reduced Laplacian minor (deleting one row and column from the weighted Laplacian scaled to integer entries) has a Smith normal form whose diagonal entries are the invariant factors of the *finite* part of the tropical Jacobian J(Γ). Moreover, the number of spanning trees (weighted by length) equals the determinant of this minor.

**Test:** Implement exact rational arithmetic Smith normal form computation for cycle graphs C_n with rational edge lengths. Verify that the product of invariant factors equals the weighted tree number. Compare with the numerical SVD-based computation from `algorithms.py`. Discrepancies beyond numerical precision would disprove the conjecture.

**Impact:** This would give an *exact* arithmetic characterization of the tropical Jacobian for rational metric graphs, eliminating all floating-point concerns. It would also provide a bridge to the chip-firing literature, where integer lattice computations are standard.

**Catalog References:**
- `Catalog/Pythagorean/TropicalBridge/MetricKernel/Theorems.lean` (weighted Laplacian properties)
- `Catalog/Pythagorean/TropicalBridge/Defs.lean` (graphLaplacian, laplacianPrincipalMinor)
- `Catalog/Bridges/Catalog/Pythagorean/TropicalBridge/CanonicalKernelTheorems.lean` (discrete chip-firing)

**Proof Strategy:** Scale edge lengths to a common denominator to obtain integer conductances. Apply the Kirchhoff Matrix Tree Theorem for weighted graphs. The Smith normal form of the integer Laplacian minor gives the group structure of Z^{n-1}/Im(L), which is isomorphic to the critical group.

**Domain Bridges:** Algebraic graph theory ↔ Number theory ↔ Tropical geometry

**Lineage:** Extends `graphLaplacian` and `laplacianPrincipalMinor` from Defs.lean to the weighted (metric) setting.

**Ambition:** ★★★ (Solid extension — the integer case is well-understood; the rational metric case requires new formalization)

---

## Direction 2: Néron Component Groups via Tropical Jacobians

**Conjecture (Grand Challenge):** For a semistable curve X over a discretely valued field K with dual graph Γ, Baker's specialization lemma gives a surjection sp: J(X)(K) → J(Γ). The canonical kernel generators of Γ provide *explicit coordinates* on the component group Φ_J of the Néron model of J(X), and the Smith normal form of the canonical kernel lattice computes |Φ_J| = det(L_red).

**Test:** For hyperelliptic curves of genus 2 with known Néron models (tabulated in the literature), compute the tropical Jacobian of the dual graph and compare the invariant factors with the known component group structure. A mismatch would indicate either a gap in the specialization map or an error in the dual graph computation.

**Impact:** This would make the Néron component group — a central object in arithmetic geometry — *computationally accessible* through elementary linear algebra on the dual graph. Currently, computing Φ_J requires sophisticated p-adic methods.

**Catalog References:**
- `Catalog/Pythagorean/TropicalBridge/MetricKernel/Theorems.lean` (weighted Laplacian kernel, PSD)
- `Catalog/Bridges/Catalog/Pythagorean/TropicalBridge/CanonicalKernelDefs.lean` (RestrictedLaplacianImage)

**Proof Strategy:** Use Baker's specialization lemma [BN07] combined with Raynaud's theorem on Néron models. The key step is showing that the canonical kernel lattice generators map to generators of the period lattice of J(X)(K) under specialization.

**Domain Bridges:** Tropical geometry ↔ Arithmetic geometry ↔ p-adic analysis

**Lineage:** Extends the canonical kernel correspondence to arithmetic applications.

**Ambition:** ★★★★★ (Grand challenge — connects to deep results in arithmetic geometry)

---

## Direction 3: Gaussian Free Field Lattice Periodicity

**Conjecture:** The canonical kernel lattice Λ_S determines the periodicity structure of the discrete Gaussian free field (GFF) on the metric graph Γ. Specifically, the partition function of the GFF on Γ with periodic boundary conditions factorizes as Z(Γ) = (2π)^{g/2} · (det L_red)^{-1/2}, where g is the genus and L_red is the reduced Laplacian.

**Test:** Compute the GFF partition function numerically for cycle graphs C_n with various edge lengths, and compare with the determinant formula. Also compute the GFF covariance matrix (= L^+) and verify it equals the effective resistance matrix.

**Impact:** This bridges tropical geometry to statistical mechanics, providing a geometric interpretation of GFF observables. The canonical kernel lattice would acquire physical meaning as the "configuration space" of the discrete toroidal model.

**Catalog References:**
- `Catalog/Pythagorean/TropicalBridge/MetricKernel/Theorems.lean` (weightedLaplacian_psd, effective resistance)
- `Catalog/Bridges/Catalog/Pythagorean/TropicalBridge/CanonicalKernelTheorems.lean` (harmonicKernel)

**Proof Strategy:** The GFF on a graph with Laplacian L has density ∝ exp(−(1/2) x^T L x). By our Theorem 6, x^T L x = Σ w_e (x_i − x_j)² ≥ 0, so the measure is well-defined on ℝ^n/{constants}. The partition function is the Gaussian integral, giving det(L_red)^{-1/2}.

**Domain Bridges:** Statistical mechanics ↔ Tropical geometry ↔ Spectral graph theory

**Lineage:** Builds directly on `weightedLaplacian_psd` from Theorems.lean.

**Ambition:** ★★★ (Solid extension — the connection is well-known informally but not formalized)

---

## Direction 4: Continuous-Time Chip-Firing and Conformal Field Theory

**Conjecture (Grand Challenge):** The chip-firing process on a metric graph Γ admits a continuous-time stochastic extension where chips perform Brownian motion along edges. The stationary measure of this process is the GFF restricted to integer-valued configurations, and the recurrent configurations form the tropical Jacobian J(Γ).

**Test:** Simulate continuous-time chip-firing on cycle graphs C_n and theta graphs Θ(a,b,c). Measure the empirical distribution of recurrent configurations and compare with the uniform measure on J(Γ). Deviations from uniformity would disprove the conjecture.

**Impact:** This would establish a direct bridge between the combinatorics of chip-firing (discrete mathematics), the geometry of tropical curves (algebraic geometry), and conformal field theory (physics). The tropical Jacobian would acquire a dynamical interpretation.

**Catalog References:**
- `Catalog/Pythagorean/TropicalBridge/MetricKernel/Theorems.lean` (all theorems)
- `Catalog/Bridges/Catalog/Pythagorean/TropicalBridge/CanonicalKernelTheorems.lean` (FiringEquivalentOn)

**Proof Strategy:** Define the continuous chip-firing process as a Markov chain on Div^0(Γ)/Prin(Γ) ≅ J(Γ). Show that the transition kernel is doubly stochastic (using symmetry of the Laplacian), implying uniformity of the stationary measure.

**Domain Bridges:** Stochastic processes ↔ Tropical geometry ↔ Conformal field theory

**Lineage:** Extends `FiringEquivalentOn` and `RestrictedLaplacianImage` to the stochastic setting.

**Ambition:** ★★★★★ (Grand challenge — requires new ideas at the interface of probability and geometry)

---

## Direction 5: Jacobian-Based Graph Classification

**Conjecture:** The tropical Jacobian invariant factors, combined with the spectral gap and Kirchhoff index, form a complete invariant for connected metric graphs up to isometry, within the class of graphs with at most 8 vertices.

**Test:** Enumerate all connected simple graphs on 6, 7, and 8 vertices (up to isomorphism). For each, compute the tropical Jacobian invariant factors with unit edge lengths. Check whether any two non-isomorphic graphs produce the same invariant factor sequence. A counterexample (two non-isomorphic graphs with identical invariants) would bound the discriminative power of the invariant.

**Impact:** This would provide a practical graph fingerprinting method for small molecule comparison, network classification, and graph database indexing. The invariant factors are computable in O(n³) time, making them competitive with existing graph kernels.

**Catalog References:**
- `Catalog/Pythagorean/TropicalBridge/MetricKernel/Theorems.lean` (weightedLaplacian, PSD)
- `Catalog/Pythagorean/TropicalBridge/Defs.lean` (graphLaplacian)

**Proof Strategy:** Exhaustive computation over the graph atlas. For larger graphs, develop partial invariants based on the Smith normal form of integer Laplacian minors.

**Domain Bridges:** Graph theory ↔ Machine learning ↔ Chemistry

**Lineage:** Applies the computational framework from algorithms.py and applications.py.

**Ambition:** ★★★ (Solid extension — computational verification is straightforward)
