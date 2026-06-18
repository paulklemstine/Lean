# Future Directions: Canonical Kernel Calculus on Metric Graphs

## Synthesis

The canonical kernel calculus developed here — with its core theorems on pendant-edge rigidity, energy characterization, and normalized kernel uniqueness — opens a systematic route from discrete chip-firing to continuous tropical geometry. The five directions below form a coherent program: Direction 1 lifts the theory to continuous metric graphs, Direction 2 proves the full Jacobian isomorphism, Direction 3 connects to Baker-Norine Riemann-Roch, Direction 4 bridges to quantum graph spectral theory, and Direction 5 develops certified tropical Abel-Jacobi algorithms. Together, they would establish a complete **algorithmic tropical Hodge theory** — a computationally effective theory of harmonic forms on tropical curves.

The unifying thread is the canonical kernel family: normalized harmonic representatives indexed by support vertices. These objects simultaneously serve as electrical Green's functions, tropical Abel-Jacobi coordinates, quantum graph resolvent kernels, and Gaussian free field covariance entries. Each direction exploits a different facet of this universality.

---

## Direction 1: Continuous Metric Graph Extension

**Conjecture:** The canonical kernel calculus extends from vertex-based models to continuous metric graphs (compact metric spaces locally isometric to intervals), with piecewise-linear harmonic functions indexed by points on edge interiors, and all algebraic theorems (uniqueness, energy positivity, leaf rigidity) carrying over verbatim.

**The key insight is** that subdivision invariance — the exact preservation of kernel matrices under edge refinement — is not merely a computational observation but a *functorial property*: the canonical kernel construction defines a presheaf on the category of metric graph models with refinement morphisms, and the limit of this presheaf is the continuous canonical kernel.

**Why now?** The formal subdivision invariance verified computationally in this work (kernel matrices preserved to machine precision through 5 levels of refinement) provides the empirical foundation. The existing `WMGraph` infrastructure in Lean 4 — metric Laplacian, energy form, harmonicity — provides the algebraic scaffolding. What's needed is the geometric realization: modeling edge interiors as intervals and defining PL functions thereon.

**Test:** Formalize `MetricGraph` as a colimit of `WMGraph` models under refinement. Prove that the canonical kernel at any pair of support points is independent of the model chosen to compute it. Verify that the energy pairing is invariant.

**Impact:** This would be the first formal bridge between discrete graph theory and continuous tropical geometry, enabling rigorous transfer of results between the two settings.

**Catalog References:**
- `Pythagorean/TropicalBridge/CanonicalKernelCalculus.lean` — `mL_row_sum_zero`, `normalized_kernel_unique`
- `Catalog/Pythagorean/TropicalBridge/MetricCanonicalForms/Theorems.lean` — `MGModel.energy_nonneg`

**Proof Strategy:** Define continuous metric graphs as quotients of disjoint intervals by endpoint identifications. Show that PL functions on any model extend uniquely to PL functions on any refinement. Prove that the Laplacian image is preserved under refinement by induction on the number of subdivisions.

**Domain Bridges:** Tropical geometry (Mikhalkin-Zharkov), spectral graph theory

**Lineage:** Extends `normalized_kernel_unique` and `energy_eq_zero_iff_constant`

**Ambition:** Grand challenge — foundational for all subsequent directions

---

## Direction 2: Full Jacobian Quotient Isomorphism

**Conjecture:** For a connected metric graph model M with support set S containing at least one vertex from each edge in a spanning tree complement, the natural map

Div⁰_S(M) / Prin_S(M) → J_S(M)

is an isomorphism of abelian groups, where J_S(M) is the S-supported Jacobian and Prin_S(M) is the lattice of S-principal divisors.

**The key insight is** that the image of the Laplacian (restricted to functions harmonic off S) has rank |S| − 1 when S is "sufficiently spread" — meeting every independent cycle. The kernel uniqueness theorem (Theorem 3.13) handles the well-definedness; what remains is to prove surjectivity and compute the rank.

**Why now?** The normalized kernel uniqueness theorem provides the injectivity half. The S-principal degree-zero theorem provides the necessary constraint. What's needed is a formal rank computation for the restricted Laplacian, which Mathlib's linear algebra library now supports.

**Test:** For the cycle graph C_n with n ≥ 3 and S = V, verify that dim(Prin_S) = n − 1 and dim(Div⁰_S) = n − 1, giving J_S = 0 (trivial Jacobian for trees after identification). For the theta graph, verify rank = genus = 2.

**Impact:** Would complete the formal tropical Abel-Jacobi theory for metric graph models.

**Catalog References:**
- `Pythagorean/TropicalBridge/CanonicalKernelCalculus.lean` — `sPrincipal_degree_zero`, `normalized_kernel_unique`
- `Catalog/Pythagorean/TropicalBridge/Defs.lean` — `graphLaplacian`, `firingIndependentOn`

**Proof Strategy:** Use the Kirchhoff matrix-tree theorem to compute the rank of the Laplacian restricted to S. Show that the restricted Laplacian has rank min(|S|−1, g) where g is the genus. Construct the isomorphism explicitly.

**Domain Bridges:** Algebraic geometry (Jacobian varieties), combinatorics (chip-firing groups)

**Lineage:** Extends `sPrincipal_degree_zero` and `Lf_total_sum_zero`

**Ambition:** Solid extension — central to the program

---

## Direction 3: Tropical Riemann-Roch via Canonical Kernels

**Conjecture:** The Baker-Norine rank of a divisor D on a metric graph model can be computed as the dimension of the space of effective divisors in the class [D], and this dimension can be read off from the canonical kernel matrix: r(D) = max{k : all k×k minors of the Abel-Jacobi image matrix are nonsingular} − 1.

**The key insight is** that the canonical kernel matrix encodes exactly the linear system |D|: the set of effective divisors equivalent to D. The rank r(D) measures how many "independent directions" the effective class occupies, which is detected by the rank of the kernel matrix restricted to the support of D.

**Why now?** The formal canonical kernel calculus provides the computational infrastructure. The connection to matrix minors is classical in tropical geometry but has never been formalized.

**Test:** For the cycle graph C₄ with divisor D = δ₀ + δ₂, compute r(D) via the kernel matrix and compare with the Baker-Norine formula r(D) = deg(D) − g = 2 − 1 = 1 (genus 1, degree 2 → r = 1).

**Impact:** A formally verified Riemann-Roch theorem for metric graph models.

**Catalog References:**
- `Catalog/Pythagorean/TropicalBridge/Defs.lean` — `rootedSubsetDivisor`, `firingIndependentOn`
- `Catalog/Pythagorean/TropicalBridge/Theorems.lean` — `rootedSubsetDivisor_total`

**Proof Strategy:** Define divisor rank via the canonical kernel representation. Prove the Riemann-Roch formula r(D) − r(K−D) = deg(D) − g + 1 by analyzing the kernel matrix and its complement.

**Domain Bridges:** Algebraic geometry (Riemann-Roch), coding theory (algebraic-geometric codes)

**Lineage:** Extends `energy_eq_zero_iff_constant` (characterizes constant functions, hence trivial divisors)

**Ambition:** Grand challenge — would be a landmark in formal tropical geometry

---

## Direction 4: Quantum Graph Spectral Theory via Canonical Kernels

**Conjecture:** The canonical kernel family on a metric graph model provides a complete set of spectral data for the discrete quantum graph Hamiltonian: the eigenvalues of the energy pairing matrix Q are the non-zero eigenvalues of the Laplacian restricted to the S-complement, and the eigenvectors give the normal modes of the quantum graph.

**The key insight is** that the energy pairing matrix Q_{ij} = ⟨k_i, k_j⟩_L is the Gram matrix of the canonical kernel generators in the energy inner product. Its spectral decomposition gives the principal axes of the energy landscape, which are exactly the normal modes of the quantum graph.

**Why now?** The formal proof of energy form symmetry (`energyForm_symm`) establishes that Q is a real symmetric matrix with well-defined spectral theory. The energy non-negativity (`energy_nonneg`) ensures all eigenvalues are non-negative.

**Test:** For the cycle graph C_n with uniform edge lengths, compare the eigenvalues of Q with the known Laplacian spectrum 2(1 − cos(2πk/n))/ℓ. For the theta graph, compare with known quantum graph eigenvalues.

**Impact:** Would connect tropical geometry to quantum mechanics and establish canonical kernels as a computational tool for quantum graph spectral problems.

**Catalog References:**
- `Pythagorean/TropicalBridge/CanonicalKernelCalculus.lean` — `energy_nonneg`, `energyForm_symm`
- `Catalog/Pythagorean/TropicalBridge/MetricKernel/Theorems.lean` — `weightedLaplacian_psd`

**Proof Strategy:** Diagonalize the energy form using the spectral theorem for real symmetric matrices. Identify the eigenvectors with Laplacian eigenfunctions. Use the trace formula tr(Q) = ∑ λ_i to connect spectral sums.

**Domain Bridges:** Quantum mechanics, spectral graph theory, scattering theory

**Lineage:** Extends `energyForm_symm` and `energy_nonneg`

**Ambition:** Solid extension with high cross-domain impact

---

## Direction 5: Certified Tropical Abel-Jacobi Algorithms

**Conjecture:** There exists a polynomial-time certified algorithm that, given a metric graph model M and a divisor D, computes the Abel-Jacobi image of D in the Jacobian J(M) and certifies whether D is principal (i.e., whether its Abel-Jacobi image is zero).

**The key insight is** that the pendant-tree pruning theorem reduces the problem to the cycle core (typically much smaller than the full graph), and the normalized kernel uniqueness theorem makes the computation deterministic. Combined, these give an algorithm whose complexity is O(g³) where g is the genus, independent of the total number of vertices.

**Why now?** The formal pruning justification (leaf rigidity) and kernel uniqueness provide correctness certificates. What's needed is a formal complexity analysis and a certified implementation.

**Test:** Implement for genus-2 theta graphs and genus-3 complete graphs. Verify correctness by comparing with brute-force computation. Measure speedup from pruning on random graphs with 90% tree structure.

**Impact:** Would provide the first certified implementation of tropical Jacobian arithmetic, enabling rigorous computation in tropical algebraic geometry.

**Catalog References:**
- `Pythagorean/TropicalBridge/CanonicalKernelCalculus.lean` — `metric_leaf_eq_neighbor`, `normalized_kernel_unique`
- `Catalog/Pythagorean/TropicalBridge/MetricCanonicalForms/Defs.lean` — `MetricGraphModel`

**Proof Strategy:** Formalize the pruning algorithm with complexity bounds. Show that the reduced Laplacian system has size g × g. Prove that Gaussian elimination produces the correct kernel generators in O(g³) operations.

**Domain Bridges:** Algorithmic algebraic geometry, certified computation, software verification

**Lineage:** Extends `metric_leaf_eq_neighbor` (pruning) and `normalized_kernel_unique` (determinism)

**Ambition:** Solid extension with direct practical applications
