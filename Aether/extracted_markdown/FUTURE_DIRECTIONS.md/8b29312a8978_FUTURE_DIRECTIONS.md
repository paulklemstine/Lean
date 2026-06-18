# Future Directions: Tropical Mixing Theory

## Synthesis

The results in this cycle establish a foundational framework: tropical path systems can certify rapid mixing of Markov chains without spectral intermediates. The five directions below extend this framework along complementary axes — deeper geometry (Direction 1), broader algebraic structure (Direction 2), new applications (Direction 3), computational power (Direction 4), and cross-domain bridges (Direction 5). Together, they form a research program aimed at making tropical geometry a practical tool for the analysis of random processes, from MCMC sampling to statistical physics to machine learning.

The key unifying thread is that **Lorentzian polynomial structure imposes geometric constraints on mixing**, and these constraints can be read from the Newton polytope subdivision without eigenvalue computation. Each direction below pushes this thread into a new domain or seeks to tighten it quantitatively.

---

## Direction 1: Tropical Ricci Curvature and Entropic Contraction

**Conjecture:** For Markov chains associated to Lorentzian polynomials, the tropical subdivision admits a notion of discrete Ricci curvature (in the sense of Ollivier or Lin–Lu–Yau) that is uniformly positive, with curvature bounded below by $\kappa \geq c / (dn)$ for a universal constant $c > 0$. This curvature bound implies entropic contraction and hence mixing time $O(dn \cdot \log(1/\pi_{\min}))$, improving the quadratic bound from canonical paths.

**Test:** Compute Ollivier curvature on the dual graph of the Newton subdivision for Lorentzian polynomials of degrees 3–8 in 3–10 variables. Check whether minimum curvature scales as $\Theta(1/(dn))$. A polynomial family where curvature decays faster than $1/(dn)$ would refute the conjecture.

**Impact:** Would establish tropical geometry as a source of *optimal* mixing bounds, not just polynomial ones. Would connect Lorentzian polynomial theory to the Bakry–Émery–Ledoux framework of curvature-dimension inequalities.

**Catalog References:** `Pythagorean/CertificateSampling.lean` (tropical_diameter_le_dn), `Pythagorean/TropicalMixingDirect.lean` (mixing_time_le_of_tropical_congestion).

**Proof Strategy:** Define Ollivier curvature on the tropical dual graph via optimal transport between 1-step distributions. Use the Hodge–Riemann relations for Lorentzian polynomials to show that the transport map between adjacent cells is contractive. The key technical step is connecting the Lorentzian signature condition to 1-Wasserstein contraction.

**Domain Bridges:** Riemannian geometry (Ricci curvature), optimal transport theory, information geometry.

**Lineage:** Extends the canonical path framework of Direction 4 by replacing path-congestion analysis with curvature analysis, potentially yielding linear rather than quadratic mixing bounds.

**Ambition:** Grand challenge — would create a new geometric framework for mixing that unifies spectral, path-based, and curvature-based methods.

---

## Direction 2: Tropical Mixing in Matroid Base Exchange Chains

**Conjecture:** For the basis exchange walk on a matroid of rank $r$ on $n$ elements, the tropical path system induced by the matroid polytope subdivision has congestion $O(rn)$ and diameter $O(rn)$, yielding a direct mixing bound of $O((rn)^2 \cdot \log(1/\pi_{\min}))$ without spectral analysis. For strongly log-concave generating polynomials (a subclass of Lorentzian polynomials), the congestion improves to $O(r + n)$.

**Test:** Implement the basis exchange walk for graphic matroids of small rank (r = 3–8, n = 6–20). Compute tropical diameter and congestion of the matroid polytope dual graph. Compare the certified bound against empirical mixing time from simulation.

**Impact:** Would give the first *purely geometric* proof of rapid mixing for matroid base sampling, complementing the spectral approach of Anari–Liu–Oveis Gharan–Vinzant. The geometric proof would be more constructive and could yield practical algorithms.

**Catalog References:** `Pythagorean/TropicalMixingDirect.lean` (tropical_path_length_le_dn, congestion_lower_bound_exists).

**Proof Strategy:** The matroid polytope is the Newton polytope of the basis generating polynomial, which is Lorentzian by Brändén–Huh. Apply the tropical path system construction to the dual graph of the matroid polytope subdivision. Bound congestion using the exchange property of matroids, which limits how many basis pairs can share a ridge.

**Domain Bridges:** Matroid theory, combinatorial optimization, algebraic combinatorics.

**Lineage:** Direct extension of the cross-domain bridge (toric_model_mixing_certificate) to matroid-specific structure.

**Ambition:** Solid extension — the machinery is in place, and the matroid setting is the most natural next application.

---

## Direction 3: Polyhedral Metastability in Statistical Mechanics

**Conjecture:** For lattice models in statistical mechanics (Ising, Potts, hard-core) whose partition functions are Lorentzian polynomials in the activity parameters, the tropical subdivision of the Newton polytope captures the metastable phases: each cell of the subdivision corresponds to a metastable phase, and the ridges correspond to phase transitions. The tropical diameter of the subdivision controls the mixing time of the Glauber dynamics at high temperature, while at low temperature, the bottleneck between cells controls the exponential slowdown.

**Test:** For the Ising model on small graphs (complete graph $K_n$, $n = 4$–$10$), compute the Newton polytope of the partition function, its tropical subdivision, and compare the cell structure with known phase diagrams. Check whether the tropical diameter predicts the mixing-time crossover between high-temperature rapid mixing and low-temperature slow mixing.

**Impact:** Would provide a geometric explanation for the mixing-time phase transition in statistical mechanics, connecting tropical geometry to the Peierls argument and large-deviation theory.

**Catalog References:** `Pythagorean/CertificateSampling.lean` (spectral_gap_log_concave_lower_bound), `Pythagorean/TropicalMixingDirect.lean` (certifiedMixingBound).

**Proof Strategy:** At high temperature, the partition function is Lorentzian, and the tropical subdivision has small diameter. Apply the tropical mixing bound directly. At low temperature, the subdivision develops large cells separated by narrow ridges, and the congestion through these ridges diverges — this is the geometric signature of metastability.

**Domain Bridges:** Statistical physics, large deviation theory, phase transitions.

**Lineage:** Builds on the certified mixing bound infrastructure and extends it to temperature-dependent families.

**Ambition:** Grand challenge — would bridge tropical algebraic geometry to statistical mechanics, a connection with no current formal framework.

---

## Direction 4: Newton-Polytope Certificates for Algebraic Statistics

**Conjecture:** For toric statistical models with $A$-matrix of size $d \times n$ and degree $D = \max_j \sum_i A_{ij}$, the fiber walk Markov chain (moves along edges of the polytope fiber) mixes in time $O(D^2 n^2 \cdot \log(1/\pi_{\min}))$, certified by the tropical path system on the marginal polytope. The certificate can be computed in polynomial time from $A$ alone, independent of the data.

**Test:** For the independence model on $3 \times 3$ contingency tables ($A$ is the incidence matrix of $K_{3,3}$), compute the tropical diameter and congestion of the fiber polytope. Compare the certified bound against empirical mixing of the Diaconis–Sturmfels fiber walk.

**Impact:** Would provide the first *certified* polynomial mixing bounds for contingency table sampling that do not require spectral analysis of the specific table. The certificate would be reusable across all tables with the same marginals.

**Catalog References:** `Pythagorean/TropicalMixingDirect.lean` (toric_model_mixing_certificate, toric_mixing_from_lorentzian).

**Proof Strategy:** The marginal polytope of a toric model is the Newton polytope of the model's normalizing polynomial. When this polynomial is Lorentzian (which holds for log-linear models with nonneg sufficient statistics), apply the tropical mixing framework. The key technical step is bounding the congestion of the fiber walk in terms of the polytope's combinatorial structure.

**Domain Bridges:** Algebraic statistics, survey sampling, computational social science.

**Lineage:** Direct extension of toric_model_mixing_certificate, adding quantitative bounds.

**Ambition:** Solid extension — the algebraic statistics application is the most immediately practical one.

---

## Direction 5: Tropical Decision Boundaries and Neural Network Mixing

**Conjecture:** The decision boundaries of ReLU neural networks are tropical hypersurfaces (this is known; see Zhang et al. 2018). For MCMC sampling of posterior distributions over neural network weights, the tropical structure of the decision boundary controls the mixing time of gradient-based samplers. Specifically, the tropical diameter of the Newton subdivision of the likelihood polynomial bounds the mixing time of a natural Langevin dynamics on the weight space.

**Test:** For small ReLU networks (2–3 layers, 5–20 neurons), compute the tropical hypersurface of the decision boundary for simple classification tasks. Estimate the tropical diameter and compare against empirical mixing time of stochastic gradient Langevin dynamics.

**Impact:** Would create a direct connection between neural network architecture and sampling efficiency, with practical implications for Bayesian deep learning.

**Catalog References:** `Pythagorean/TropicalMixingDirect.lean` (certifiedMixingBound, tropical_path_length_le_dn).

**Proof Strategy:** The likelihood function of a ReLU network is a piecewise-linear function, hence its Newton polytope admits a tropical subdivision. The tropical diameter of this subdivision is controlled by the depth and width of the network. Apply the tropical mixing bound to the natural Markov chain on weight space restricted to each linear region.

**Domain Bridges:** Machine learning, Bayesian inference, neural network theory.

**Lineage:** Most speculative extension — leverages the known connection between ReLU networks and tropical geometry.

**Ambition:** Grand challenge — would bridge tropical geometry to deep learning theory, a connection that could have enormous practical impact.
