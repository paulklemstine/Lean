# Future Directions: Entropy Curvature and Information-Theoretic Depth

## Synthesis

The entropy curvature framework established in this work opens a systematic bridge between discrete combinatorics (higher-order log-concavity) and information geometry (curvature of the log-probability landscape). The theorems proved here — the second-difference characterization, normalization invariance, geometric vanishing, score monotonicity, and the Gibbs connection — form the foundation layer. The directions below extend this foundation in five distinct trajectories: deeper into the log-concavity hierarchy, outward into continuous probability theory, across into statistical mechanics and coding theory, and upward into abstract categorical structure. Each direction is specific enough to fail and daring enough to reshape its target domain.

---

## Direction 1: Alternating Curvature Signs for Totally Positive Sequences

**Conjecture:** If a positive sequence $a : \mathbb{N} \to \mathbb{R}_{>0}$ arises as the diagonal of a totally positive matrix (or equivalently, is a Pólya frequency sequence of infinite order), then for all $k \geq 2$:
$$(-1)^k \cdot \Delta^k(\log a)(n) \geq 0 \quad \text{for all } n \text{ in the interior of the support.}$$

**Test:** Compute the curvature profile for the diagonal of the Toeplitz matrix of a Pólya frequency function $\varphi(t) = \prod_i (1 + \alpha_i t) / \prod_j (1 - \beta_j t)$ for small parameter sets. Check the alternating sign law numerically for sequences up to length 50 and curvature order up to 15.

**Impact:** This would establish that total positivity — a pervasive structure in combinatorics, representation theory, and cluster algebras — is equivalent to a discrete "nonpositive curvature" condition in the information-geometric sense. It would give the first intrinsic characterization of Pólya frequency sequences in terms of discrete Riemannian-type curvature.

**Catalog References:** `Catalog/Pythagorean/HigherOrderLogConcavity.lean` (KFoldLogConcave, iterRatio_logConcave)

**Proof Strategy:** Use the Schoenberg representation of PF sequences and the fact that products of geometric sequences (which have zero higher curvature by Theorem 3) inherit curvature bounds via the product stability theorem. The key step is showing that convolution with a PF kernel preserves the alternating sign law.

**Domain Bridges:** Cluster algebras (Fomin–Zelevinsky), Kazhdan–Lusztig theory, symmetric function theory.

**The key insight is** that total positivity and nonpositive information curvature may be the same condition viewed from two different mathematical traditions — one algebraic, one geometric.

**Why now?** The Brändén–Huh Lorentzian polynomial machinery provides the first rigorous recursive framework for higher-order positivity, and our entropy curvature formalism provides the matching geometric language.

**Lineage:** Extends Theorem 1 (second-difference characterization) and Theorem 3 (geometric vanishing).

**Ambition:** Grand challenge — would unify three decades of log-concavity results under a single curvature umbrella.

---

## Direction 2: Curvature-Controlled Redundancy Bounds in Source Coding

**Conjecture:** For a memoryless source with positive PMF $\pi$ on $\{0, 1, \ldots, N-1\}$, the redundancy of optimal prefix-free coding satisfies:
$$R(\pi) \leq C \cdot \sum_{k=2}^{K} \|\Delta^k(\log \pi)\|_\infty$$
for some universal constant $C$ depending only on $K$, where $\|\cdot\|_\infty$ is the supremum over the support.

**Test:** Implement arithmetic coding and Huffman coding for binomial, Poisson, and geometric sources. Measure actual redundancy vs. the curvature bound for $K = 2, 3, 4$. Fit the constant $C$ empirically.

**Impact:** This would give a new structural explanation for why distributions with "simpler shape" (lower curvature) are easier to compress. Geometric distributions (zero curvature) have zero redundancy in the limit; this conjecture would quantify how curvature adds redundancy.

**Catalog References:** `Pythagorean/EntropyCurvature.lean` (iterForwardDiff_log_normalize_eq, geometric_iterForwardDiff_log_eq_zero)

**Proof Strategy:** Use the connection between second curvature and the monotone likelihood ratio to bound the discrepancy between the Shannon entropy and the optimal code length. The key technical tool is the Kraft inequality combined with curvature-controlled approximation of $-\log \pi(n)$ by affine functions.

**Domain Bridges:** Coding theory, data compression, rate-distortion theory.

**The key insight is** that entropy curvature measures the deviation from the "ideally compressible" geometric distribution, and this deviation should translate directly into coding overhead.

**Why now?** Modern neural compression methods implicitly learn distribution shapes; a formal curvature bound would provide theoretical guarantees for these methods.

**Lineage:** Builds on Theorem 2 (normalization invariance) and Theorem 3 (geometric vanishing).

**Ambition:** Solid extension — directly applicable to practical compression.

---

## Direction 3: Discrete Ricci Curvature via Entropy Curvature

**Conjecture:** For a random walk on a graph $G$ with stationary distribution $\pi$, define the *entropy Ricci curvature* at vertex $v$ as $\kappa_2(\pi, v)$ where $\pi$ is ordered by graph distance from a reference vertex. Then $\kappa_2 \leq 0$ everywhere if and only if $G$ satisfies a discrete Bakry–Émery curvature lower bound.

**Test:** Compute $\kappa_2$ for path graphs, cycle graphs, complete graphs, and hypercube graphs. Compare with known Ollivier–Ricci and Bakry–Émery curvature values from the literature.

**Impact:** This would provide a new, computationally simpler notion of discrete Ricci curvature based entirely on the entropy curvature of the stationary distribution, avoiding the transport-theoretic machinery of Ollivier's definition.

**Catalog References:** `Pythagorean/EntropyCurvature.lean` (logConcave_iff_secondDiff_log_nonpos)

**Proof Strategy:** Use the spectral gap of the graph Laplacian to control the second curvature of the stationary distribution. The key lemma should relate $\Delta^2(\log \pi)$ to the combinatorial Laplacian eigenvalues.

**Domain Bridges:** Spectral graph theory, Riemannian geometry, optimal transport.

**The key insight is** that entropy curvature of the stationary distribution encodes the same geometric information as Ricci curvature of the underlying graph, but in a form that is directly computable from the sequence of probabilities.

**Why now?** The explosion of interest in discrete curvature for graph neural networks and network science creates immediate demand for efficiently computable curvature notions.

**Lineage:** Extends Theorem 1 to graph-theoretic settings.

**Ambition:** Grand challenge — would bridge two active research communities (discrete curvature and log-concavity).

---

## Direction 4: Entropy Curvature of Partition Functions in Statistical Mechanics

**Conjecture:** For the partition function $Z(\beta) = \sum_n g(n) e^{-\beta E(n)}$ of a system with density of states $g(n)$ and energy levels $E(n)$, the entropy curvature profile $\Delta^k(\log Z_n)$ (where $Z_n$ is the microcanonical partition function at energy level $n$) detects phase transitions: the second curvature $\kappa_2$ diverges at critical points.

**Test:** Compute entropy curvature profiles for the 1D Ising model (exact solution), the 2D Ising model (numerical transfer matrix), and the mean-field Curie–Weiss model. Check whether curvature divergence correlates with known critical temperatures.

**Impact:** This would give a purely information-geometric diagnostic for phase transitions, complementing the traditional order parameter approach.

**Catalog References:** `Pythagorean/EntropyCurvature.lean` (affine_energy_gibbs_zero_higher_curvature), `Catalog/Pythagorean/HigherOrderLogConcavity.lean` (geometric_kFoldLogConcave)

**Proof Strategy:** For exactly solvable models, compute the partition function coefficients explicitly and analyze the curvature profile. For the Curie–Weiss model, use the saddle-point approximation to show that the second curvature is proportional to the inverse susceptibility, which diverges at the critical point.

**Domain Bridges:** Statistical mechanics, thermodynamic formalism, phase transition theory.

**The key insight is** that the vanishing higher curvature of geometric/Gibbs distributions (Theorems 3 and 6) characterizes the *non-interacting* regime, and deviations from zero curvature measure the strength of interactions.

**Why now?** The formal verification of the Gibbs zero-curvature theorem provides the baseline against which phase-transition-induced curvature can be measured.

**Lineage:** Directly extends Theorem 6 (affine energy Gibbs theorem).

**Ambition:** Solid extension — connects to well-studied physics with clear experimental predictions.

---

## Direction 5: Tropical Entropy Curvature and Idempotent Information Geometry

**Conjecture:** Replace $(\mathbb{R}, +, \times)$ with the tropical semiring $(\mathbb{R} \cup \{-\infty\}, \max, +)$. Define the *tropical entropy curvature* as the iterated max-plus finite difference of sequences. Then tropical log-concavity (equivalent to concavity of the sequence itself) is characterized by nonpositivity of the second tropical curvature, and the entire entropy curvature hierarchy tropicalizes to a hierarchy of discrete concavity conditions with combinatorial interpretations.

**Test:** Compute tropical curvature profiles for Newton polygons of polynomials, valuations of coefficients of Kazhdan–Lusztig polynomials, and tropical Grassmannian coordinates. Check whether tropical curvature signs match classical curvature signs under valuation.

**Impact:** This would create a *tropical information geometry*, connecting the entropy curvature framework to tropical algebraic geometry and providing new invariants for Newton polytopes and tropical varieties.

**Catalog References:** `Pythagorean/EntropyCurvature.lean` (iterForwardDiff, logConcave_iff_secondDiff_log_nonpos)

**Proof Strategy:** Verify that the proofs of Theorems 1–3 tropicalize: replace $\log$ with the identity (the tropical logarithm), replace $+$ with $\max$, and check that the algebraic structure of the proofs is preserved. The key technical point is that the forward difference operator commutes with tropicalization.

**Domain Bridges:** Tropical geometry, valuations, Newton polytopes, combinatorial optimization.

**The key insight is** that entropy curvature, being defined purely through differences of logarithms, is inherently a "tropical object in disguise" — it should tropicalize cleanly and yield new invariants.

**Why now?** The recent connections between Lorentzian polynomials and tropical geometry (Brändén–Huh) suggest that the log-concavity hierarchy has a natural tropical incarnation waiting to be formalized.

**Lineage:** Novel direction extending the core definitions to a new algebraic setting.

**Ambition:** Grand challenge — would open an entirely new subfield of tropical information geometry.
