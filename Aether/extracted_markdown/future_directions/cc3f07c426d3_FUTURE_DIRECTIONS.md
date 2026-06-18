# Future Directions: Stereographic Persistence and Conformal Topological Data Analysis

## Synthesis

This research cycle established the mathematical foundations for computing persistent homology on spheres via stereographic projection. The core insight—that stereographic projection preserves enough metric structure (through conformal weighting) for persistence computations—connects three classical areas: conformal geometry, metric topology, and computational algebraic topology. The key results are: (1) forward and reverse containment theorems relating weighted and unweighted Čech filtrations, (2) a separation bound ensuring distinct points remain separated under conformal weighting, and (3) a formal filtration isomorphism theorem for conformal isometries.

The most promising cross-domain connection emerging from this cycle is between conformal geometry and tropical algebra. The interleaving distance on persistence modules is naturally a tropical (min-plus) algebraic object, and the conformal weight function w(x) = 2/(1+‖x‖²) behaves like an exponential kernel—suggesting a connection to tropical persistence as developed in the Catalog's `Computation/TropicalAmortized.lean` framework. The filtration containment results (Theorems `weighted_cech_containment` and `unweighted_cech_containment`) are structurally analogous to the comparison bounds in `Computation/ApproximationMethod.lean`, pointing to a unified approximation theory for filtered complexes.

The direction with highest breakthrough potential is Direction 1 (Optimal Conformal Projection), because it bridges computational geometry (projection selection) with persistence stability theory, and a positive result would immediately impact every application of spherical TDA. Direction 3 (Conformal Persistence on Hyperbolic Space) has high impact for machine learning, where hyperbolic embeddings are increasingly common.

---

### Direction 1: Optimal Conformal Projection Selection

**Conjecture**: For any finite point cloud X = {p₁,...,pₙ} ⊂ Sⁿ with n ≥ 3, there exists a projection pole p* ∈ Sⁿ such that the interleaving ratio of the stereographic persistence is at most C·n^{2/(n+1)}, where C depends only on the dimension. Specifically, if R(p*) = max_i ‖π_{p*}(pᵢ)‖ is the maximum projected norm, then min_{p* ∈ Sⁿ} (1 + R(p*)²)² ≤ C·n^{2/(n+1)} for well-separated point clouds.

**Test**: For N = 50, 100, 500 random points on S², enumerate 1000 candidate projection poles uniformly on S², compute R for each, and plot the minimum interleaving ratio versus N. Fit a power law; the exponent should be approximately 2/3 for S². Compare against the theoretical bound.

**Impact**: If true, this gives a polynomial-time algorithm for choosing the projection center, making stereographic persistence practical for arbitrary spherical point clouds without manual pole selection. If false, the failure mode reveals which point cloud configurations resist conformal approximation.

**Catalog References**: `Computation/ApproximationMethod.lean` (kw_log_entropy_lower_bound), `Computation/StereographicPersistence.lean` (stereo_persistence_reverse)

**Proof Strategy**: 
1. Show that for any point cloud, there exists a hemisphere containing at most N/2 points (pigeonhole).
2. Place the pole at the center of the emptiest spherical cap.
3. Bound R using the angular separation from the pole to the nearest data point.
4. Use the separation bound theorem to control the interleaving.
Key lemma: for uniformly distributed points, the maximum angular distance to the nearest point is O(1/N^{1/(n+1)}) by covering number arguments.

**Domain Bridges**: Geometry <-> Computation, Algebra <-> Topology

**Lineage**: Builds on `stereo_persistence_reverse` and `conformal_factor_lower_bound` from this cycle's formalization.

**Ambition**: grand_challenge

---

### Direction 2: Tropical Interleaving and Conformal Persistence

**Conjecture**: The interleaving distance between the geodesic and conformally weighted persistence modules can be expressed as a tropical polynomial in the conformal weights {w(xᵢ)}. Specifically, the bottleneck distance d_B(PD_geo, PD_weighted) equals the tropical max of -log(w(xᵢ)) over all vertices i, where the tropical max corresponds to the worst-case conformal distortion.

**Test**: Compute d_B(PD_geo, PD_weighted) for 100 random S² point clouds and compare against the tropical expression max_i(-log w(xᵢ)) = max_i log((1+‖xᵢ‖²)/2). The conjecture predicts a linear relationship with slope 2 on a log-log plot.

**Impact**: If true, this provides an explicit, closed-form expression for the persistence approximation error, eliminating the need to compute persistence diagrams to assess the quality of the conformal approximation. It would also establish a new bridge between tropical algebra and persistence theory, suggesting that conformal distortion is fundamentally a tropical-algebraic phenomenon.

**Catalog References**: `Computation/TropicalAmortized.lean`, `Computation/CollatzTropical.lean` (collatz_two_step_log_bound), `Tropical/` directory

**Proof Strategy**:
1. Express the interleaving parameter δ as a function of max/min conformal weights.
2. Show that δ = log(c_max/c_min) using the log-scale structure of persistence.
3. Identify this as a tropical max operation.
4. Prove the algebraic stability theorem carries the tropical structure through.
Key difficulty: connecting the additive structure of persistence interleaving with the multiplicative structure of conformal weights—the logarithm is the bridge.

**Domain Bridges**: Tropical <-> Computation, Algebra <-> Topology

**Lineage**: Builds on `weighted_cech_containment`, `unweighted_cech_containment`, and the interleaving triangle inequality from this cycle. Connects to `Computation/TropicalAmortized.lean` in the Catalog.

**Ambition**: grand_challenge

---

### Direction 3: Conformal Persistence on Hyperbolic Space

**Conjecture**: The Poincaré disk model of hyperbolic space Hⁿ admits a conformal weight w_H(x) = 2/(1-‖x‖²) such that for any point cloud in the Poincaré disk with ‖xᵢ‖ ≤ r < 1, the hyperbolic and conformally weighted Euclidean persistence diagrams are ((1-r²)²/4)-interleaved.

**Test**: Generate N = 100 random points in the Poincaré disk with various radial distributions. Compute persistence with the hyperbolic metric d_H(x,y) and with the weighted Euclidean metric w_H(x)·w_H(y)·‖x-y‖. Verify the interleaving bound for r ∈ {0.5, 0.8, 0.9, 0.95}.

**Impact**: Hyperbolic embeddings are widely used in NLP (Poincaré embeddings) and network science (hyperbolic random graphs). Enabling efficient persistence computation in hyperbolic space would immediately benefit these fields. The Poincaré disk is conformally equivalent to the upper half-plane, so this also opens connections to modular forms and number theory.

**Catalog References**: `EML/ModularForms.lean` (T_sq, S_gen), `Geometry/` directory

**Proof Strategy**:
1. Define the hyperbolic conformal factor w_H(x) = 2/(1-‖x‖²) (dual to the spherical case).
2. Prove positivity, upper bound, and lower bound theorems (analogous to the spherical case).
3. Define weighted Čech complex with w_H.
4. Prove forward and reverse containment using the same framework as `weighted_cech_containment` and `unweighted_cech_containment`.
Key difference from the spherical case: the hyperbolic conformal factor diverges at ‖x‖ → 1 rather than vanishing, so the upper bound comes from restricting to ‖x‖ ≤ r < 1.

**Domain Bridges**: Geometry <-> Computation, EML <-> Topology

**Lineage**: Direct extension of the stereographic persistence framework from this cycle. The proof architecture (conformal weight → containment → interleaving) transfers with minimal modification.

**Ambition**: extension

---

### Direction 4: Discrete Morse Theory on Conformally Weighted Complexes

**Conjecture**: Given a conformal weight w on the vertices of a Čech complex, there exists a discrete Morse function compatible with the weighted filtration whose critical cells correspond exactly to the persistence pairs. Moreover, the number of critical cells of dimension k equals the k-th Betti number of the weighted complex at the terminal filtration value.

**Test**: For N = 50 random points on S², construct the weighted Čech complex, compute a discrete Morse gradient field using the algorithm in `ExplicitMorseTheory.lean`, and verify that the critical cell count matches the Betti numbers.

**Impact**: This would connect the conformal persistence framework to discrete Morse theory, enabling gradient-based optimization on persistence (e.g., finding the conformal weight that minimizes the number of persistence pairs above a threshold). It would also provide a constructive proof that conformal weighting preserves the Morse-theoretic structure of the filtration.

**Catalog References**: `Pythagorean/ExplicitMorseTheory.lean` (persistence_invariant_of_filtration_compatible, ExplicitFormanField), `Computation/StereographicPersistence.lean`

**Proof Strategy**:
1. Define a discrete Morse function f(σ) = max_{v ∈ σ} birth_time_weighted(v) on the weighted Čech complex.
2. Show that f is a valid discrete Morse function (satisfying the pairing conditions in `ExplicitFormanField`).
3. Prove that the critical cells under f correspond to persistence generators.
4. Apply the critical count theorem from `ExplicitMorseTheory.lean`.
Key challenge: the weighted filtration may not be "generic" (multiple simplices entering at the same parameter), requiring perturbation arguments.

**Domain Bridges**: Computation <-> Pythagorean, Geometry <-> Topology

**Lineage**: Combines `persistence_invariant_of_filtration_compatible` from the Catalog with the new filtration morphism framework. Bridges this cycle's Čech complex formalization with the existing Morse theory formalization.

**Ambition**: extension

---

### Direction 5: Conformal Entropy and Information-Theoretic Bounds

**Conjecture**: The entropy of the persistence diagram of a conformally weighted point cloud is bounded by H(PD) ≤ log(N) + 2·E[-log w(X)], where E[-log w(X)] is the expected negative log-conformal-weight over the data distribution. Equality holds when the point cloud is uniformly distributed on the sphere.

**Test**: For uniform random point clouds on S² of sizes N = 50, 100, 500, compute the persistence entropy (Shannon entropy of the normalized lifetimes) and compare against the conjectured bound. Also test with non-uniform distributions (clustered, antipodal, equatorial).

**Impact**: This would connect persistence theory to information theory through conformal geometry, providing fundamental limits on how much topological information a conformally projected point cloud can carry. The bound E[-log w(X)] has a natural interpretation as the KL divergence between the projected and uniform distributions, linking topological complexity to distributional properties.

**Catalog References**: `Computation/ApproximationMethod.lean` (kw_log_entropy_lower_bound), `Computation/Entropy.lean`, `Computation/InformationEntropy.lean`

**Proof Strategy**:
1. Define persistence entropy as H(PD) = -Σ (ℓᵢ/L) log(ℓᵢ/L), where ℓᵢ are lifetimes and L = Σℓᵢ.
2. Show that scaling distances by w(x)·w(y) adds at most 2·log(max w / min w) to the entropy.
3. Use the conformal factor bounds to express this in terms of -log w.
4. Apply the KW log-entropy lower bound from `ApproximationMethod.lean` to get the final inequality.
Key insight: the conformal weight acts as a reweighting of the persistence measure, and the entropy change under reweighting is controlled by the KL divergence.

**Domain Bridges**: Computation <-> Information Theory, Geometry <-> Entropy

**Lineage**: Builds on `kw_log_entropy_lower_bound` from the Catalog and the conformal factor bounds from this cycle.

**Ambition**: extension
