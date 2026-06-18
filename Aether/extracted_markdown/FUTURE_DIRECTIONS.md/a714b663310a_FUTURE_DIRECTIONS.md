# Future Directions: Canonical Kernel Theory on Metric Graphs

## Synthesis

The canonical kernel theory developed here establishes the first formally verified bridge between discrete chip-firing / Laplacian theory and continuous metric graph geometry. The key structural theorems — pendant-edge rigidity, normalized kernel uniqueness, and energy positivity — provide the computational backbone for a tropical Jacobian calculus. The five directions below extend this foundation in complementary ways: Direction 1 completes the passage to genuine continuous metric graphs; Direction 2 connects to spectral theory and quantum dynamics; Direction 3 builds the algorithmic infrastructure for tropical Abel–Jacobi computation; Direction 4 bridges to statistical mechanics; and Direction 5 opens the non-Archimedean door to arithmetic geometry. Together, they define a program for *algorithmic tropical Hodge theory*.

---

## Direction 1: Full Metric Graph Theory — Piecewise-Linear Functions on Continuous Edges

**Conjecture:** For a compact connected metric graph Γ and a finite separated support set S meeting every cycle, the canonical kernel generators (PL functions harmonic off S with prescribed unit sources) form a basis for the S-supported harmonic space, and the resulting Jacobian quotient Div⁰_S(Γ) / Prin_S(Γ) is canonically isomorphic to the discrete Jacobian of any sufficiently fine finite model.

**Test:** Implement PL functions on continuous edges (as piecewise-affine functions parameterized by edge coordinates). Compute the continuous kernel matrix by solving the PL Laplacian system exactly (it reduces to a tridiagonal system per edge plus junction conditions). Compare with finite model kernel matrices under refinement. Any discrepancy in the limit falsifies the conjecture.

**Impact:** This would complete the passage from the finite model theorems (proven here) to genuine tropical curve theory, making the Baker–Norine Riemann–Roch theorem computationally explicit for metric graphs.

**Catalog References:**
- `Pythagorean.TropicalBridge.MetricCanonicalForms.Theorems`: `normalized_kernel_unique`, `energy_nonneg`
- `Pythagorean.TropicalBridge.MetricKernel.Theorems`: `weightedLaplacian_psd`

**Proof Strategy:** Define PL functions as continuous functions that are affine-linear on each edge. The key lemma is that the slope-sum Laplacian at interior edge points vanishes for affine functions (automatic), so harmonicity reduces to vertex conditions. Then the continuous kernel existence/uniqueness reduces to the finite model theorem plus an edge-interpolation argument.

**Domain Bridges:** Tropical geometry → continuous analysis → finite element theory

**Lineage:** Extends `normalized_kernel_unique` from discrete to continuous

**Ambition:** ★★★★☆ — requires new definitions but the mathematics is well-understood

**The key insight is** that PL harmonic functions on metric graphs are completely determined by their vertex values plus affine interpolation, so the continuous theory is isomorphic to the discrete theory on any chosen model.

**Why now?** The formal verification of the discrete uniqueness theorem provides the precise algebraic foundation. The continuous extension requires only the observation that affine-linearity on edges is automatic.

---

## Direction 2: Spectral Connections — Canonical Kernels and Quantum Graph Eigenvalues

**Conjecture:** For a compact metric graph Γ, the eigenvalues of the canonical kernel matrix K (restricted to a cycle-hitting support set S) approximate the reciprocals of the nonzero eigenvalues of the continuous Laplacian on Γ, with error O(h²) where h is the maximum edge length.

**Test:** Compute eigenvalues of K for cycle graphs and theta graphs with known spectra. Compare with exact Laplacian eigenvalues (which are known in closed form for cycles). Discrepancies exceeding O(h²) falsify the conjecture.

**Impact:** This would establish canonical kernels as a computational tool for spectral graph theory, enabling certified eigenvalue approximation via finite linear algebra.

**Catalog References:**
- `Pythagorean.TropicalBridge.MetricCanonicalForms.Theorems`: `energy_nonneg`, `twice_energy_eq_sum_sq_diff`
- `Pythagorean.TropicalBridge.HarmonicSectorFactorization`: `gffEnergy_nonneg_of_psd`

**Proof Strategy:** Use the Rayleigh quotient characterization of eigenvalues. The energy form E(f) = f^T L f restricted to the support set gives a finite-dimensional approximation of the continuous Rayleigh quotient. Standard finite element error analysis gives the O(h²) bound.

**Domain Bridges:** Tropical geometry → spectral theory → quantum mechanics → PDE theory

**Lineage:** Extends `energy_nonneg` to a quantitative spectral statement

**Ambition:** ★★★★★ — would bridge tropical geometry and spectral theory in a novel way

**The key insight is** that the canonical kernel matrix is a finite-rank approximation of the continuous Green's function, and its eigenvalues should converge to the reciprocal Laplacian spectrum.

**Why now?** The energy positivity theorem provides the variational framework, and the refinement convergence experiments confirm the quantitative convergence rate.

---

## Direction 3: Algorithmic Tropical Abel–Jacobi Maps

**Conjecture:** The tropical Abel–Jacobi map AJ: Div⁰(Γ) → J(Γ) can be computed explicitly via the canonical kernel matrix: for a divisor D = Σ nᵢ pᵢ, the image AJ(D) is the lattice coset [K · n] where K is the kernel matrix and n is the coefficient vector.

**Test:** For genus-1 graphs (cycles), the Jacobian is S¹ and the Abel–Jacobi map is integration along the cycle. Compute AJ via the kernel formula and compare with direct integration. For genus-2 theta graphs, compare with the known Jacobian structure.

**Impact:** This would give the first certified algorithm for tropical Abel–Jacobi computation, enabling verified arithmetic on tropical curves.

**Catalog References:**
- `Pythagorean.TropicalBridge.Defs`: `rootedSubsetDivisor`, `graphLaplacian`
- `Pythagorean.TropicalBridge.MetricCanonicalForms.Theorems`: `normalized_kernel_unique`, `Lf_total_sum_zero`

**Proof Strategy:** Define the Abel–Jacobi map via integration of canonical kernel generators. Use the uniqueness theorem to show the map is well-defined. Use the energy form to show it descends to the Jacobian quotient.

**Domain Bridges:** Tropical geometry → algebraic geometry → number theory → cryptography

**Lineage:** Extends `Lf_total_sum_zero` (degree-zero = Jacobian element) to a map

**Ambition:** ★★★★☆ — algorithmically novel, mathematically straightforward

**The key insight is** that the canonical kernel generators are exactly the basis of harmonic 1-forms needed for Abel–Jacobi integration, and the kernel matrix is the period matrix.

**Why now?** The uniqueness theorem guarantees the map is well-defined, and the Python implementation provides immediate computational validation.

---

## Direction 4: Tropical Gaussian Free Fields and Covariance Coordinates

**Conjecture (Grand Challenge):** The Dirichlet energy form on canonical kernels defines a natural Gaussian measure on the space of vertex potentials, and the partition function of this tropical Gaussian free field factors as Z = Z_pin · Z_harm where Z_harm = covol(J(Γ)) is the covolume of the Jacobian torus.

**Test:** Compute Z_pin and Z_harm for small graphs using the canonical kernel matrix. Compare with the known partition function (determinant of reduced Laplacian times explicit constants). Any discrepancy falsifies the factorization.

**Impact:** This would establish a rigorous bridge between tropical geometry and statistical mechanics, identifying the Jacobian covolume as a topological partition function.

**Catalog References:**
- `Pythagorean.TropicalBridge.HarmonicSectorFactorization`: `periodic_partition_factorization`, `harmonic_factor_invariant_under_subdivision`
- `Pythagorean.TropicalBridge.MetricCanonicalForms.Theorems`: `energy_nonneg`, `energy_zero_of_constant`

**Proof Strategy:** Build on the existing `HarmonicSectorFactorization` results, which already prove a formal Z = Z_pin · Z_harm factorization. The new contribution is to identify Z_harm with the canonical kernel determinant and to extend this to metric graphs with arbitrary edge lengths.

**Domain Bridges:** Tropical geometry → statistical mechanics → random matrix theory → quantum field theory

**Lineage:** Extends `HarmonicSectorFactorization.periodic_partition_factorization` to metric graphs

**Ambition:** ★★★★★ — grand challenge connecting geometry to physics

**The key insight is** that the canonical kernel matrix IS the covariance matrix of the tropical Gaussian free field, making the Jacobian covolume a natural normalization constant.

**Why now?** The energy positivity theorem provides the essential positive-definiteness needed for the Gaussian measure to be well-defined, and the harmonic sector factorization provides the algebraic framework.

---

## Direction 5: Non-Archimedean Skeleta and Arithmetic Geometry

**Conjecture (Grand Challenge):** For a smooth algebraic curve C over a non-Archimedean valued field, the canonical kernel matrix computed on its Berkovich skeleton Σ(C) recovers the tropical Jacobian of Σ(C), and this Jacobian maps faithfully to the reduction of the algebraic Jacobian J(C).

**Test:** For Tate curves (elliptic curves with bad reduction), the Berkovich skeleton is a cycle whose length equals the valuation of the j-invariant. Compute the canonical kernel and compare with the known tropical Jacobian (= ℝ/ℓℤ where ℓ is the cycle length). Check that the Abel–Jacobi map is compatible with the algebraic one.

**Impact:** This would connect the formal metric graph theory to arithmetic geometry, potentially enabling computational results about rational points on curves via tropical methods.

**Catalog References:**
- `Pythagorean.TropicalBridge.MetricCanonicalForms.Theorems`: all main theorems
- `Pythagorean.TropicalBridge.Defs`: `graphLaplacian` (discrete prototype)

**Proof Strategy:** Use the specialization map from the Berkovich analytification to the skeleton. The key is to show that the canonical kernel generators on the skeleton lift to analytic functions on the Berkovich space, using non-Archimedean potential theory (as developed by Baker, Chinburg, and Rumely).

**Domain Bridges:** Tropical geometry → arithmetic geometry → number theory → algebraic geometry

**Lineage:** Extends the entire canonical kernel framework to non-Archimedean settings

**Ambition:** ★★★★★ — paradigm-shifting, connecting formal verification to arithmetic

**The key insight is** that the Berkovich skeleton is a metric graph in the precise sense of our formalization, so all proven theorems apply directly — the challenge is the lifting to the algebraic setting.

**Why now?** The machine-verified correctness of the discrete theory provides a trusted computational foundation. The non-Archimedean connection has been explored informally by Baker and others, but never in a verified setting.
