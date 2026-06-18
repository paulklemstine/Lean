# Future Directions: Spectral Tropical Stability

## Synthesis

The spectral tropical stability theorem establishes that the Fiedler eigenvalue (algebraic connectivity) quantitatively controls tropical barcode robustness under metric perturbation. This opens a rich interface between spectral graph theory, tropical geometry, isoperimetric analysis, and topological data analysis. The five directions below exploit this interface in complementary ways: Direction 1 sharpens the bound via higher-order spectral data; Direction 2 extends the framework to higher-dimensional homology; Direction 3 bridges to statistical physics and phase transitions; Direction 4 connects to random geometric graph theory for probabilistic certificates; Direction 5 pursues the tropical algebraic geometry connection through chip-firing and divisor theory. Together, they form a program to develop *spectral certification of topological robustness* as a general-purpose tool spanning pure mathematics, data science, and mathematical physics.

---

## Direction 1: Sharp Spectral Exponents and Higher-Order Eigenvalue Refinements

**Conjecture:** The optimal exponent in the spectral stability bound d_tb ≤ C · ε^α / λ*^β is (α, β) = (1, 1), and the constant C_d grows at most polynomially in the ambient dimension d. Furthermore, incorporating higher eigenvalues λ₃, λ₄, ... into a "spectral profile" bound yields strictly tighter certificates than using λ₂ alone.

**Test:** For random geometric graphs in ℝ^d (d = 2, 3, ..., 20) with n = 50–500 points, compute the empirical ratio d_tb · λ*^β / ε^α for (α, β) ∈ {(1,1), (1,2), (2,1)}. If (1,1) gives bounded ratios while alternatives diverge, the conjecture is confirmed. Test whether the variance of the ratio decreases when using the full Laplacian spectrum (not just λ₂).

**Impact:** Establishing sharp constants would transform the spectral stability theorem from a qualitative principle to a quantitative engineering tool. If higher eigenvalues refine the bound, it would justify more expensive spectral computations for critical applications (medical imaging, structural engineering).

**Catalog References:** `Catalog/Pythagorean/SpectralTropicalStability.lean` (Theorem `tropBarcodeDist_le_spectralBound`, definition `spectralGapFloor`); `Catalog/Pythagorean/TropicalBridge/ChipFiringCorrespondence.lean` (`graphLap`, `graphLap_symmetric`).

**Proof Strategy:** For the sharp exponent, use random matrix theory for the Laplacian of random geometric graphs (Penrose 2003) to obtain concentration bounds on λ₂. For higher eigenvalues, define a weighted spectral profile σ(G) = Σ_k w_k / λ_k and prove d_tb ≤ σ(G) · ε using per-eigenspace perturbation analysis.

**Domain Bridges:** Random matrix theory ↔ TDA; high-dimensional geometry ↔ spectral graph theory.

**Lineage:** Direct extension of the spectral stability theorem proven in this cycle.

**Ambition:** 🔴 Grand Challenge — requires new techniques at the intersection of random matrix theory and tropical geometry.

**The key insight is** that the full Laplacian spectrum, not just the gap, encodes a richer stiffness profile that can separate "uniformly stiff" filtrations from those with directional softness invisible to λ₂ alone.

**Why now?** The spectral stability theorem provides the first formal bridge between eigenvalue data and barcode stability, making spectral refinements immediately relevant.

---

## Direction 2: Higher-Dimensional Tropical Persistence via Hodge Laplacians

**Conjecture:** The spectral gap of the k-th Hodge Laplacian Δ_k on the Vietoris–Rips simplicial complex controls the stability of the k-th tropical Betti number β_k under metric perturbation: d_tb^(k) ≤ K_k · ε / λ*_k, where λ*_k is the minimum positive eigenvalue of Δ_k across filtration stages.

**Test:** Construct VR complexes on point clouds sampled from tori (β₁ = 2, β₂ = 1) and compute Hodge Laplacian spectra at each stage. Perturb the cloud and measure β₁ and β₂ drift. Check whether the ratio d_tb^(k) · λ*_k / ε is bounded for k = 1, 2.

**Impact:** Would extend the spectral certification framework from cycle detection (β₁) to cavity detection (β₂) and beyond, making it applicable to protein pocket detection, material void analysis, and cosmological structure.

**Catalog References:** `Catalog/Pythagorean/SpectralTropicalStability.lean` (full proof pipeline); `Catalog/Bridges/Catalog/Pythagorean/TropicalPersistentHomology.lean` (`tropNullity`, `tropBarcodeDist_le_edgePerturbation`).

**Proof Strategy:** Define tropical k-nullity as the k-th Betti number of the clique complex. Prove a k-dimensional analog of `tropNullity_stable_under_edgeSymmDiff` using the Hodge decomposition. Then apply the spectral bound with Δ_k replacing the graph Laplacian.

**Domain Bridges:** Hodge theory ↔ TDA; differential geometry (continuous Hodge Laplacian) ↔ combinatorial topology.

**Lineage:** Extends the β₁ theory of this cycle to higher Betti numbers.

**Ambition:** 🟡 Solid Extension — the proof architecture is clear but the Hodge Laplacian formalization is substantial.

**The key insight is** that the Hodge Laplacian Δ_k = ∂_{k+1}∂_{k+1}^T + ∂_k^T∂_k generalizes the graph Laplacian to higher dimensions, and its spectral gap should control stability of β_k exactly as λ₂ controls β₁.

**Why now?** With β₁ spectral stability established, the extension to higher dimensions follows a clear template, and Hodge Laplacian computations are becoming practical for moderate-size complexes.

---

## Direction 3: Phase Transitions in Spectral Topological Stability — A Statistical Mechanics Bridge

**Conjecture:** For random geometric graphs G(n, r) on compact Riemannian manifolds, the spectral stability ratio d_tb · λ* / ε undergoes a phase transition at the connectivity threshold r_c(n): below r_c, the ratio diverges (fragile regime); above r_c, it concentrates around a dimension-dependent constant (rigid regime). The critical exponent of this transition is universal and related to the correlation length exponent of percolation.

**Test:** Generate Poisson point processes on the flat torus [0,1]² with n = 100, 200, 500 and vary r near r_c = √(log n / (π n)). At each r, compute the spectral stability ratio over 100 perturbation trials. Plot the ratio as a function of (r - r_c) · n^{1/2} to test for data collapse indicative of a universal scaling function.

**Impact:** Would establish a rigorous connection between the percolation phase transition in random geometric graphs and the robustness of topological data analysis. This would give practitioners a principled threshold for "when TDA can be trusted" based on sampling density.

**Catalog References:** `Catalog/Pythagorean/SpectralTropicalStability.lean` (`uniformSpectralExponentConjecture`, `spectralGapFloor_pos`).

**Proof Strategy:** Use the known spectral gap estimates for random geometric graphs (Penrose 2003, Arias-Castro et al. 2011): below connectivity, λ₂ = 0 (disconnected); above connectivity, λ₂ ~ c · n · r². Near the threshold, λ₂ fluctuates with variance controlled by the connectivity transition. Prove that the spectral stability ratio inherits the phase transition structure from λ₂.

**Domain Bridges:** Statistical mechanics (percolation theory) ↔ spectral graph theory ↔ TDA; universality classes ↔ topological robustness.

**Lineage:** Tests the boundary of the uniform spectral exponent conjecture from this cycle.

**Ambition:** 🔴 Grand Challenge — requires combining percolation theory, spectral analysis, and tropical persistence in a novel way.

**The key insight is** that the spectral gap floor λ* undergoes a sharp transition from 0 to positive at the connectivity threshold, and this transition should govern when tropical persistence becomes reliable — connecting the physics of phase transitions to the reliability of data analysis.

**Why now?** The spectral stability theorem provides the formal link between λ* and barcode stability. Known results on spectral gaps of random geometric graphs provide the probabilistic input. The synthesis is newly possible.

---

## Direction 4: Certified Streaming Persistence via Online Spectral Updates

**Conjecture:** For dynamically evolving point clouds (streaming data), the spectral stability certificate can be maintained in O(n²) amortized time per point insertion/deletion, using rank-one updates to the Laplacian eigendecomposition. The certificate remains valid between updates, providing continuous robustness guarantees.

**Test:** Implement a streaming VR filtration on a simulated trajectory of n = 100 points undergoing Brownian motion. At each time step, update the certificate using rank-one spectral perturbation (Sherman-Morrison for the Laplacian inverse). Compare the streaming certificate bound against the batch-recomputed bound. Measure time per update.

**Impact:** Would make spectral stability certification practical for real-time systems: autonomous vehicles processing LiDAR point clouds, neuroscience experiments with streaming electrode data, financial market topology monitoring.

**Catalog References:** `Catalog/Pythagorean/SpectralTropicalStability.lean` (`SpectralStabilityCertificate`, `SpectralStabilityCertificate.bound`); `Catalog/Pythagorean/TropicalBridge/ChipFiringCorrespondence.lean` (`graphLap`, `graphLap_row_sum_zero`).

**Proof Strategy:** When a single edge is added/removed, the Laplacian changes by a rank-one matrix. Use Weyl's perturbation theorem to bound Δλ₂. Show that the certificate bound changes by at most a controlled amount, allowing lazy recomputation.

**Domain Bridges:** Numerical linear algebra (eigenvalue perturbation) ↔ streaming algorithms ↔ TDA; real-time systems ↔ certified computation.

**Lineage:** Operationalizes the certificate structure from this cycle for dynamic settings.

**Ambition:** 🟡 Solid Extension — the mathematical content is moderate, but the engineering impact is high.

**The key insight is** that the spectral stability certificate separates "structural analysis" (computing λ*) from "perturbation analysis" (bounding d_tb), and the structural analysis can be amortized across many perturbation queries via efficient spectral updates.

**Why now?** The certificate structure provides a clean interface for incremental updates, and efficient rank-one eigenvalue update algorithms are well-understood in numerical linear algebra.

---

## Direction 5: Tropical Brill–Noether Theory and Spectral Rigidity of Divisor Flows

**Conjecture:** The Fiedler eigenvalue λ₂ controls not only tropical barcode stability but also the rank of the tropical linear system |D| for divisors D of degree g (the genus). Specifically, for connected graphs with λ₂ ≥ λ_min, the Brill–Noether number ρ(g, r, d) = g - (r+1)(g-d+r) provides a lower bound on the dimension of |D| that is *stable* under edge perturbation: r(D) ≥ ρ - K' · ε / λ₂.

**Test:** Compute divisor ranks on small graphs (|V| ≤ 12) using Dhar's burning algorithm. Perturb the graph (add/remove edges near threshold) and recompute ranks. Check whether Δr(D) · λ₂ / ε is bounded. Compare with the tropical Riemann–Roch prediction r(D) - r(K-D) = deg(D) - g + 1.

**Impact:** Would establish a deep connection between spectral graph theory and tropical algebraic geometry, showing that the same eigenvalue that controls topological persistence also controls the algebraic structure of divisor theory on graphs. This would bridge TDA to the Baker–Norine program and potentially to applications in coding theory (via algebraic geometry codes on graphs).

**Catalog References:** `Catalog/Pythagorean/TropicalBridge/ChipFiringCorrespondence.lean` (`GraphDivisor`, `chipFire_degree_preserved`, `genus_nonneg_of_connected`, `linearEquiv_degree_invariant`); `Catalog/Pythagorean/SpectralTropicalStability.lean` (`cheeger_to_spectral_bound`).

**Proof Strategy:** The graph Laplacian kernel is spanned by constant functions (proven in the catalog as `laplacian_kernel_contains_constants`). For connected graphs, this kernel is one-dimensional. The Fiedler eigenvalue measures the gap to the next eigenspace, which controls the "cost" of chip-firing moves (Laplacian action on divisors). Prove that perturbing edges changes the Laplacian spectrum by at most O(1), hence the chip-firing dynamics (and divisor ranks) change by at most O(1/λ₂).

**Domain Bridges:** Tropical algebraic geometry (Baker–Norine theory) ↔ spectral graph theory; coding theory (AG codes) ↔ combinatorial optimization (chip-firing); number theory (Riemann–Roch) ↔ TDA.

**Lineage:** Builds on the chip-firing correspondence and Cheeger bridge from this cycle to enter tropical algebraic geometry proper.

**Ambition:** 🔴 Grand Challenge — paradigm-shifting if successful, connecting TDA to one of the deepest areas of algebraic geometry.

**The key insight is** that chip-firing is the Laplacian action on divisors (proven in the catalog as `chipFire_eq_laplacian_action`), and therefore the spectral gap that controls topological stability should also control the algebraic stability of divisor ranks — unifying two seemingly independent notions of "rigidity" through the graph Laplacian.

**Why now?** The spectral stability theorem provides the topological side of the bridge, and the chip-firing correspondence in the catalog provides the algebraic side. The synthesis requires only connecting them through the shared Laplacian structure, which is newly available as a formally verified foundation.
