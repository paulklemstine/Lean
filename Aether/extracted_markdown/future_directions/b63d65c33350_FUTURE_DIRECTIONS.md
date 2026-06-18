# Future Directions: Harmonic-Sector Factorization and Tropical Partition Functions

## Synthesis

The harmonic-sector factorization theorem establishes a precise bridge between the Gaussian free field partition function on a metric graph and the tropical Jacobian covolume. This bridge creates a two-way dictionary: tropical moduli invariants become thermodynamic observables, and statistical mechanical techniques become tools for computing geometric invariants. The directions below exploit this dictionary systematically, extending it to higher-dimensional geometry, interacting field theories, arithmetic settings, and computational applications. Each direction is grounded in the formalized catalog theorems and proposes specific, testable predictions.

---

## Direction 1: Tropical Hodge Theory via Higher-Dimensional Sector Decomposition

**Conjecture:** For a finite CW-complex K with weighted boundary operators, the periodic partition function of the p-form Gaussian free field factors as:

$$Z_{\text{periodic}}^{(p)}(K) = Z_{\text{pin}}^{(p)}(K) \cdot \text{covol}(\Lambda_p)$$

where Λ_p is the p-th harmonic lattice (tropical p-th cohomology) and Z_pin^(p) involves the determinant of the reduced p-Laplacian.

**Test:** Formalize the 1-form GFF on a triangulated torus (genus 1 surface). The harmonic lattice should be 2-dimensional (two independent 1-cycles). Compute the partition function numerically and verify factorization against the area of the harmonic torus.

**Impact:** This would extend the tropical Jacobian bridge from graph theory (1-dimensional) to arbitrary dimensions, creating a framework for "tropical statistical mechanics" on cell complexes.

**Catalog References:**
- `Catalog/Pythagorean/TropicalBridge/MetricKernel/Theorems.lean` — `weightedLaplacian_psd` generalizes to p-Laplacians
- `Catalog/Bridges/Catalog/Pythagorean/TropicalBridge/CanonicalKernelTheorems.lean` — `harmonicKernel` extends to p-form kernels

**Proof Strategy:** Define the p-Laplacian as Δ_p = d_{p-1}* d_{p-1} + d_p d_p* on p-cochains. Prove row-sum-zero and PSD properties by adapting the graph Laplacian proofs. Factor the partition function using the Hodge decomposition for finite complexes.

**Domain Bridges:** Algebraic topology ↔ Statistical mechanics ↔ Tropical Hodge theory

**Lineage:** Directly extends the current factorization from graphs (0-Laplacian on edges) to higher-dimensional complexes.

**Ambition:** Grand challenge — would found the field of "tropical Hodge statistical mechanics."

**The key insight is** that the Hodge decomposition for finite complexes provides an exact orthogonal splitting analogous to ker(L)⊥ ⊕ ker(L), and the tropical analog of the Jacobian in dimension p is the p-th harmonic torus.

**Why now?** The graph-level factorization is now formally verified, providing a template. Mathlib's growing coverage of simplicial complexes and homological algebra makes the higher-dimensional generalization tractable.

---

## Direction 2: Perturbative Corrections to the Factorization for Interacting Fields

**Conjecture:** For the φ⁴ field theory on a connected graph Γ with coupling constant λ:

$$Z_{\text{periodic}}^{(\lambda)}(\Gamma) = Z_{\text{pin}}(\Gamma) \cdot Z_{\text{harm}}(\Lambda_\Gamma) \cdot \left(1 + \sum_{k=1}^{\infty} a_k(\Gamma) \lambda^k\right)$$

where the perturbative coefficients a_k(Γ) depend on both the pinned and harmonic sectors through specific Feynman diagram contributions.

**Test:** Compute a₁(Γ) for the theta graph Θ(a, b, c) explicitly. Verify that a₁ involves both the Green's function (pinned sector) and the harmonic zero-mode integral (winding sector). Test numerically whether a₁ is a metric graph invariant.

**Impact:** Would establish that tropical geometry controls not just free fields but also the structure of perturbative corrections in interacting discrete field theories.

**Catalog References:**
- `Catalog/Pythagorean/TropicalBridge/HarmonicSectorFactorization.lean` — `periodic_partition_factorization` as the λ = 0 base case
- `Catalog/Bridges/Catalog/Pythagorean/TropicalBridge/GaussianFreeField.lean` — `graphGFFEnergy_add_const` for gauge invariance at each perturbative order

**Proof Strategy:** Use the Hubbard-Stratonovich transformation to express the φ⁴ integral as a Gaussian integral with a random mass. Expand in λ using Wick's theorem. Factor each order using the sector decomposition.

**Domain Bridges:** Quantum field theory ↔ Tropical geometry ↔ Combinatorics (Feynman diagrams on graphs)

**Lineage:** Extends the free-field factorization (λ = 0) to the interacting regime.

**Ambition:** Paradigm-shifting — would create "tropical quantum field theory" as a rigorous mathematical subject.

**The key insight is** that the perturbative expansion preserves the sector structure order by order, with each Feynman diagram contributing a factored quantity involving both pinned (propagator) and harmonic (zero-mode) components.

**Why now?** The free-field factorization provides the exact base case. Perturbative QFT on finite graphs is combinatorially manageable, unlike the continuum case.

---

## Direction 3: Arithmetic Partition Functions and Number-Theoretic Jacobians

**Conjecture:** For a graph Γ arising as the dual graph of the special fiber of a semistable arithmetic surface, the partition function factorization specializes to:

$$Z_{\text{periodic}}(\Gamma) = \frac{(2\pi)^{(n-1)/2}}{\sqrt{|\text{Pic}^0(\mathcal{X}_s)|}} \cdot \text{covol}(\Lambda_\Gamma)$$

where |Pic⁰(X_s)| is the order of the component group of the Jacobian of the special fiber (which equals det(L_red) by a theorem of Raynaud).

**Test:** Construct the dual graphs of specific Kodaira fiber types (I_n, II, III, IV) and verify that det(L_red) matches the known component group orders from the classification of Néron models.

**Impact:** Would establish partition functions as a bridge between tropical/arithmetic geometry and statistical mechanics, potentially yielding new computational methods for arithmetic invariants.

**Catalog References:**
- `Catalog/Pythagorean/TropicalBridge/HarmonicSectorFactorization.lean` — `periodic_over_pin_eq_covol` connects the ratio to the covolume
- `Catalog/Pythagorean/TropicalBridge/MetricKernel/Theorems.lean` — `weightedLaplacian_psd` for the Laplacian of the dual graph

**Proof Strategy:** Use Raynaud's theorem (component group ≅ cokernel of the graph Laplacian restricted to integer lattice) to identify det(L_red) with the component group order. Then apply the partition function factorization.

**Domain Bridges:** Arithmetic geometry ↔ Statistical mechanics ↔ Tropical geometry ↔ Number theory

**Lineage:** Extends the factorization from metric graph invariants to arithmetic invariants of algebraic curves.

**Ambition:** Grand challenge — would connect thermodynamics to number theory through the Jacobian.

**The key insight is** that the reduced Laplacian determinant, which appears in the pinned factor as a Gaussian normalization constant, simultaneously counts spanning trees (combinatorics) and measures the component group of the Néron model (arithmetic geometry).

**Why now?** The partition function factorization provides a new perspective on the arithmetic of graph Laplacians, and the formal verification ensures the foundational results are watertight.

---

## Direction 4: Inverse Problems — Recovering Tropical Moduli from Thermodynamic Data

**Conjecture:** For a metric graph Γ of genus g, the map

$$\Gamma \mapsto (Z_{\text{pin}}(\Gamma), Z_{\text{harm}}(\Gamma))$$

is "generically injective" on the moduli space M_g^{trop} of tropical curves of genus g, in the sense that the pair (Z_pin, Z_harm) determines Γ up to finitely many possibilities.

**Test:** For genus 2 theta graphs Θ(a, b, c), the pair (Z_pin, Z_harm) gives two equations in three unknowns (a, b, c). Adding a third measurement (e.g., effective resistance between the two vertices) should uniquely determine (a, b, c). Verify computationally for 1000 random parameter triples.

**Impact:** Would establish thermodynamic measurements as a practical tool for determining network topology, with applications in molecular spectroscopy, network tomography, and materials science.

**Catalog References:**
- `Catalog/Pythagorean/TropicalBridge/HarmonicSectorFactorization.lean` — `periodic_over_pin_eq_covol` for extracting Z_harm from measurements
- `Catalog/Bridges/Catalog/Pythagorean/TropicalBridge/GaussianFreeField.lean` — `effectiveResistance_eq_pseudoinverse_quadratic` for resistance measurements

**Proof Strategy:** Study the Jacobian of the map (a, b, c) → (Z_pin, Z_harm, R_eff) and show it is generically nonsingular. For higher genus, use dimension counting on M_g^{trop}.

**Domain Bridges:** Inverse problems ↔ Network tomography ↔ Tropical moduli theory ↔ Spectroscopy

**Lineage:** Extends the factorization from a structural theorem to a computational tool for geometry recovery.

**Ambition:** Solid extension — practically achievable with current tools.

**The key insight is** that the sector factorization provides two independent "projections" of the metric graph into scalar invariants, and combining them with local measurements (resistance) can overdetermine the geometry.

**Why now?** The factorization theorem provides a principled way to decompose measurements into local and global components, and computational tools for tropical moduli spaces are rapidly maturing.

---

## Direction 5: Topological Phases and Discrete Gauge Theory on Networks

**Conjecture:** For the discrete U(1) gauge theory on a graph Γ (i.e., the GFF with periodic boundary conditions on each edge independently), the partition function factors as:

$$Z_{\text{gauge}}(\Gamma) = Z_{\text{Coulomb}}(\Gamma) \cdot |\text{Jac}(\Gamma)|$$

where |Jac(Γ)| is the number of elements in the (discrete) Jacobian group and Z_Coulomb is the "Coulomb phase" contribution.

**Test:** Compute Z_gauge for small graphs (cycle, theta, K_4) using both the direct summation over gauge-equivalence classes and the proposed factorization. The discrete Jacobian group order equals det(L_red) for integer-weighted graphs.

**Impact:** Would connect the tropical partition function framework to discrete gauge theories, potentially yielding new invariants for topological phases on networks.

**Catalog References:**
- `Catalog/Bridges/Catalog/Pythagorean/TropicalBridge/CanonicalKernelTheorems.lean` — `harmonicKernel` for the gauge equivalence classes
- `Catalog/Pythagorean/TropicalBridge/HarmonicSectorFactorization.lean` — the continuous factorization as a template for the discrete case

**Proof Strategy:** Discretize the winding modes to a finite group (the Jacobian). The sum over this group replaces the covolume integral. Use the chip-firing equivalence from the canonical kernel theorems to identify gauge orbits with Jacobian elements.

**Domain Bridges:** Discrete gauge theory ↔ Tropical geometry ↔ Topological phases ↔ Chip-firing

**Lineage:** Extends the continuous factorization (covolume of a lattice) to the discrete setting (order of a finite group).

**Ambition:** Solid extension — connects to a well-studied area (sandpile groups, chip-firing) with new physical interpretation.

**The key insight is** that the continuous covolume (Z_harm) and the discrete group order (|Jac(Γ)|) are related by a natural discretization, and the partition function factorization bridges these two viewpoints.

**Why now?** Interest in discrete gauge theories for quantum computing and topological quantum error correction provides strong motivation, and the chip-firing / Jacobian group theory is mature enough for rigorous formalization.
