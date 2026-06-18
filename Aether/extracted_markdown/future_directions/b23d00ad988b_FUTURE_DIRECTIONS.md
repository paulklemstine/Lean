# Future Directions: Tropical Barcode Stability

## Synthesis

The stability theorem for tropical persistence barcodes establishes that the tropical barcode distance is Lipschitz in the filtration perturbation, with constant (D+1) controlled by the maximum vertex degree. This opens five concrete research directions, each building on the formally verified foundation and extending it toward different mathematical and applied domains. The directions form a coherent program: Directions 1 and 2 sharpen the stability analysis itself, Direction 3 lifts the theory to richer algebraic structures, Direction 4 bridges to information theory, and Direction 5 pushes toward applications in network neuroscience. Together, they constitute a research program that could establish tropical TDA as a serious alternative to classical persistence in settings where graph-local interactions, min-plus structure, and visibility phenomena matter intrinsically.

---

## Direction 1: Optimal Stability Constants for Random Graphs

**Conjecture:** For Erdős–Rényi random graphs G(n, c/n) with bounded expected degree c and random vertex filtrations f, g satisfying FiltrationSupDist(f, g) ≤ ε, the empirical ratio d_T(TPB(G,f), TPB(G,g)) / ((D+1)·ε) concentrates below a universal constant α(c) < 1 as n → ∞. Moreover, the effective stability constant is O(√c) rather than O(c), reflecting the Poisson nature of the degree distribution.

**Test:** Compute the empirical ratio for n ∈ {100, 500, 1000, 5000} across 1000 trials each, with c ∈ {3, 5, 10, 20}. Test whether the ratio converges as n grows and whether it scales as √c. A single family of graphs where the ratio exceeds 0.9 consistently would require revising the conjecture.

**Impact:** If confirmed, this would provide practitioners with much tighter stability guarantees for real-world networks, which typically resemble random graphs more than worst-case constructions. It would also connect tropical persistence to random matrix theory through the spectral properties of random graph Laplacians.

**Catalog References:** `Pythagorean/TropicalBridge/Stability.lean` (tropical_barcode_stability, degree_le_half_laplacianNorm)

**Proof Strategy:** Use concentration inequalities for the sum of degree-weighted indicators. The key random variable is Σ_{v ∈ border(t)} (deg(v) + 1) where border(t) = {v : |f(v) - g(v)| > |max(f(v),g(v)) - t|}. For Poisson-degree graphs, this sum concentrates around its mean by Bernstein's inequality, giving an O(√c) bound with high probability.

**Domain Bridges:** Random matrix theory, concentration of measure, probabilistic combinatorics

**Lineage:** Extends Theorem 6.1 (tropical_barcode_stability) to the probabilistic setting

**Ambition:** Solid extension — high probability of success within 6 months

---

## Direction 2: Tropical Interleaving Distance and Algebraic Stability

**Conjecture:** There exists a categorical interleaving distance on the category of tropical persistence modules (parametrized by monotone functions ℝ → ℤ with bounded local variation) such that (a) the interleaving distance is bounded above by the barcode distance, (b) the two distances are bi-Lipschitz equivalent for finite-type modules, and (c) the interleaving distance satisfies a universal property analogous to the Bubenik–Scott framework for classical persistence.

**Test:** Formalize the tropical persistence category in Lean 4. Verify the bi-Lipschitz equivalence computationally for graphs up to n = 50. Construct an explicit example showing the two distances are not equal (gap in the bi-Lipschitz constant).

**Impact:** This would establish a complete algebraic stability theory for tropical persistence, paralleling the Chazal–Cohen-Steiner–Glisse–Guibas–Oudot framework [CCGGO09] for classical persistence. It would make tropical persistence amenable to the full toolkit of abstract persistence theory.

**Catalog References:** `Pythagorean/TropicalBridge/Stability.lean` (tropical_event_profile_interleaved, tropicalBarcodeDist_nonneg, tropicalBarcodeDist_symm)

**Proof Strategy:** Define the tropical persistence module as a functor from (ℝ, ≤) to (ℤ-Mod, ≤), where morphisms are order-preserving maps. The interleaving distance is the infimum δ such that the modules are δ-shifted comparable. Use the monotonicity theorem (tropicalEventProfile_mono) as the starting point and extend to the full module structure.

**Domain Bridges:** Category theory, homological algebra, abstract persistence theory

**Lineage:** Extends Theorems 5.1–5.2 (interleaving) to a full categorical framework

**Ambition:** Grand challenge — would unify tropical and classical persistence theory

---

## Direction 3: Sheaf-Theoretic Tropical Persistence

**Conjecture:** The tropical persistence barcode can be realized as the derived pushforward of a constructible sheaf on the real line, valued in the category of tropical semimodules. The stability theorem then follows from the properness of the pushforward and the continuity of the derived functor, providing a conceptual explanation for the degree-dependent constant.

**Test:** Construct the sheaf explicitly for path graphs and cycle graphs. Verify that the stalk at each point t equals the tropical kernel dimension. Check that the derived pushforward reproduces the event profile.

**Impact:** This would connect tropical persistence to the rapidly developing theory of persistent sheaves (Curry, Kashiwara–Schapira), opening access to powerful tools from algebraic geometry and microlocal analysis. It would also suggest natural higher-dimensional generalizations.

**Catalog References:** `Pythagorean/TropicalBridge/Stability.lean` (tropicalEventProfile, TPB), `Catalog/Pythagorean/TropicalBridge/FiltrationPersistence.lean` (TropicalFiltration)

**Proof Strategy:** Define the sheaf F on ℝ with stalks F_t = tropical kernel of G[activeVertices(f,t)]. The restriction maps are the natural inclusions. Constructibility follows from the finite number of critical values (entrance times). The pushforward to a point gives the global sections, which encode the barcode.

**Domain Bridges:** Sheaf theory, derived categories, algebraic geometry, microlocal analysis

**Lineage:** Conceptual reformulation of the entire stability framework

**Ambition:** Grand challenge — would place tropical persistence in the mainstream of modern geometry

---

## Direction 4: Information-Theoretic Bounds on Tropical Barcode Stability

**Conjecture:** The tropical barcode distance between random filtrations on a fixed graph G is, up to constants, equal to the mutual information between the filtration and the barcode, divided by the graph's entropy rate. Formally: d_T(TPB(G,f), TPB(G,g)) ≈ I(f; TPB(G,f)) · FiltrationSupDist(f,g) / H(G), where H(G) is the entropy of the degree sequence.

**The key insight is** that the degree-weighted event profile is essentially a sufficient statistic for the filtration, and the stability constant (D+1) reflects the information capacity of a degree-D vertex.

**Why now?** Recent advances in information-theoretic persistence (Bubenik, Vergne) have made the connection between persistence and entropy precise for classical barcodes. The tropical setting, with its natural connection to min-plus entropy and max-plus probability, is ripe for an analogous development.

**Test:** Compute mutual information between filtration and barcode for G(n, c/n) with n = 100, c ∈ {3, 5, 10}. Compare I(f; TPB(G,f)) / H(G) with the empirical stability ratio. Plot the relationship across 500 random graph instances.

**Impact:** Would provide a principled, information-theoretic explanation for why the degree bound is the natural stability constant. Could lead to optimal data compression for tropical barcodes.

**Catalog References:** `Pythagorean/TropicalBridge/Stability.lean` (tropicalEventProfile, certified_stability_bound)

**Proof Strategy:** Model the filtration as a random process and the barcode as its image under a deterministic function. Apply the data processing inequality to bound the mutual information. Connect the channel capacity to the maximum degree via the capacity of a discrete memoryless channel with D+1 outputs.

**Domain Bridges:** Information theory, entropy, data processing inequality, rate-distortion theory

**Lineage:** Bridges from tropical persistence (Direction 1 foundation) to information theory

**Ambition:** Solid extension — draws on mature information-theoretic tools

---

## Direction 5: Stable Tropical Barcodes for Network Neuroscience

**Conjecture:** For brain connectivity graphs derived from fMRI or diffusion tensor imaging, the tropical barcode under a distance-based vertex filtration provides a more discriminative biomarker for neurological conditions than classical persistent homology, while maintaining comparable stability guarantees. Specifically, the tropical barcode should achieve at least 10% higher classification accuracy on the ABIDE autism spectrum dataset while the stability bound ensures that scan-to-scan variability (ε ≈ 0.05 in normalized coordinates) produces at most (D+1)·0.05 ≈ 0.5 barcode distance for typical cortical connectivity (D ≈ 8).

**The key insight is** that brain networks have heterogeneous degree distributions (hubs vs. peripheral regions), and the tropical barcode's degree-weighted structure naturally emphasizes hub perturbations — exactly the vertices that carry the most diagnostic information.

**Why now?** The stability theorem provides, for the first time, a rigorous noise tolerance guarantee for tropical barcodes. Previous applications of tropical algebra to neuroscience lacked this foundation, making it impossible to separate signal from noise.

**Test:** Apply tropical barcode computation to the ABIDE dataset (n ≈ 1000 subjects, ~100 ROIs per subject). Compute tropical barcodes under Euclidean distance filtrations. Compare classification accuracy (autism vs. control) using tropical barcodes vs. classical persistence barcodes as features. Report stability ratios for repeated scans of the same subject.

**Impact:** Could establish tropical TDA as a standard tool in computational neuroscience, with formal guarantees that practitioners can trust.

**Catalog References:** `Pythagorean/TropicalBridge/Stability.lean` (tropical_barcode_stability, tropical_stability_via_laplacian_bound)

**Proof Strategy:** Not a proof per se, but a computational study. Use the stability theorem to establish noise tolerance. Use the spectral bridge theorem to connect stability to known spectral properties of brain networks (which have been extensively characterized).

**Domain Bridges:** Neuroscience, fMRI analysis, graph classification, machine learning

**Lineage:** Direct application of Theorems 6.1 and 7.1

**Ambition:** Solid extension with high practical impact — 3-6 months to initial results
