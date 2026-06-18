# Future Directions

## Synthesis

This research cycle established the **Poincaré Detector** — a novel mathematical structure that formalizes manifold detection from point cloud data via the Vietoris-Rips edge filtration. The central achievement is a suite of 25+ formally verified theorems establishing monotonicity, stability, phase transitions, packing-covering duality, and the handshaking lemma for metric filtrations. These results provide rigorous foundations for topological data analysis that go beyond what existed in the Catalog.

The most promising cross-domain connection is between the **Poincaré threshold stability** (this cycle) and the **stereographic Čech filtration** (`Computation/StereographicPersistence.lean`). The stability theorem proves that the detection threshold varies Lipschitz-continuously under L∞ perturbations, which is precisely the property needed to extend the stereographic persistence framework to noisy data. The conformal weight bounds from StereographicPersistence provide the "weights" that can be plugged into our general perturbation framework, creating a bridge between spherical geometry and discrete topology.

The highest breakthrough potential lies in **Direction 1** (proving the scaling law n^{-1/d}), because it would provide the first rigorous, dimension-dependent convergence rate for manifold detection. This would complete the "Poincaré conjecture for data" program by showing that not only CAN spheres be detected, but that the detection has optimal sample complexity.

---

### Direction 1: Scaling Law for Sphere Detection Thresholds

**Conjecture**: For n points sampled uniformly from the unit sphere S^d ⊂ ℝ^{d+1}, the Poincaré threshold satisfies ε*(n,d) = Θ(n^{-1/d}) as n → ∞. More precisely, there exist constants 0 < c_d ≤ C_d depending only on d such that c_d · n^{-1/d} ≤ ε*(n,d) ≤ C_d · n^{-1/d} with high probability.

**Test**: Generate K = 1000 independent samples of n points on S^d for n ∈ {50, 100, 200, 500, 1000} and d ∈ {1, 2, 3}. Compute ε* for each sample. Verify that log(ε*) vs log(n) has slope ≈ -1/d by linear regression, with R² > 0.95.

**Impact**: If true, this establishes the sample complexity of manifold detection — the minimum number of samples needed to detect a d-sphere scales as ε^{-d}. This connects TDA to classical results on covering numbers of spheres and would be the first such result with a formal proof.

**Catalog References**: `Computation/PoincareThreshold/Defs.lean` (PoincareDetector, equidistant_threshold_eq), `Applications/PoincareData/SimplicialComplex.lean` (sphere_detection_stable)

**Proof Strategy**: 
1. Prove a covering number bound: the covering number N(S^d, ε) satisfies C₁ · ε^{-d} ≤ N(S^d, ε) ≤ C₂ · ε^{-d}.
2. Use the packing-covering duality (maximal_packing_is_cover) to relate packing numbers to covering numbers.
3. Show that n uniform samples form an ε-cover with high probability when ε ≥ C · n^{-1/d} (using the coupon collector argument on a covering partition).
4. Show that the Rips graph at scale 2ε is connected when the sample is an ε-cover.

**Domain Bridges**: Computation <-> Geometry (covering numbers connect discrete and continuous topology)

**Lineage**: Builds on poincare_threshold_stable and equidistant_threshold_eq from this cycle, extends sphere_detection_stable from the catalog.

**Ambition**: grand_challenge

---

### Direction 2: Homological Poincaré Threshold via Betti Numbers

**Conjecture**: Define the *homological Poincaré threshold* as ε*_hom = inf{ε : β_k(VR_ε(X)) = β_k(S^d) for all k}. Then ε*_hom ≤ ε*_edge (the edge-based threshold is an upper bound), and for uniform sphere samples, ε*_hom = Θ(ε*_edge).

**Test**: Compute persistent homology for point clouds on S² using ripser or gudhi. Compare ε*_hom (where H_0 ≅ ℤ and H_2 ≅ ℤ) with ε*_edge (where edge count = n(n-1)). Verify the ratio is bounded.

**Impact**: If true, the computationally cheaper edge count is a reliable proxy for the topologically richer Betti number signature. This would validate the Poincaré Detector as a practical tool.

**Catalog References**: `Computation/PoincareThreshold/Defs.lean`, `Applications/PoincareData/SimplicialComplex.lean` (euler_char_sphere)

**Proof Strategy**:
1. Formalize Betti numbers for abstract simplicial complexes (building on AbstractSimplicialComplex).
2. Define a BettiProfile structure analogous to ConnectivityProfile.
3. Prove that β₀(VR_ε) = 1 implies the graph is connected, which implies edge count ≥ n-1.
4. Use the Euler characteristic formula to relate edge count to higher Betti numbers.

**Domain Bridges**: Computation <-> Applications (connects edge combinatorics to homological algebra)

**Lineage**: Extends euler_char_sphere and the PoincareDetector from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Conformal Poincaré Threshold via Stereographic Projection

**Conjecture**: The stereographic conformal weight transforms the Poincaré threshold by a bounded factor: if X ⊂ S^d and X' = stereo(X) ⊂ ℝ^d, then ε*(X') / ε*(X) ∈ [c_min², c_max²] where c_min, c_max are the conformal weight bounds.

**Test**: Generate 100 points on S², project stereographically, compute both thresholds, and verify the ratio is bounded by (2/(1+R²))² from below and 4 from above.

**Impact**: Would unify the Poincaré threshold theory with the stereographic persistence framework, showing that sphere detection is conformally invariant up to bounded distortion.

**Catalog References**: `Computation/StereographicPersistence.lean` (conformal_factor_le_two, conformal_factor_lower_bound, stereo_persistence_forward, stereo_persistence_reverse), `Computation/PoincareThreshold/Defs.lean`

**Proof Strategy**:
1. Use stereo_persistence_forward and stereo_persistence_reverse to get Čech containment.
2. Convert Čech containment to edge count containment via the edge count definition.
3. Apply threshold minimality to get the threshold bound.

**Domain Bridges**: Computation <-> Geometry (conformal geometry meets discrete topology)

**Lineage**: Directly combines poincare_threshold_stable with conformal_factor_le_two and stereo_persistence_forward.

**Ambition**: extension

---

### Direction 4: Phase Transition Sharpness and Manifold Curvature

**Conjecture**: The *sharpness* of the phase transition — defined as diam(X)/min_dist(X) — is bounded by the curvature of the underlying manifold. For constant-curvature manifolds, sharpness = Θ(n^{1/d}). For variable-curvature manifolds, sharpness grows with the curvature ratio.

**Test**: Generate points on ellipsoids with varying eccentricity (ratio a/b of semi-axes). Measure sharpness as the ratio of the Poincaré threshold to the minimum pairwise distance. Plot sharpness vs eccentricity.

**Impact**: Would connect the combinatorial Poincaré threshold to differential geometry, providing a data-driven curvature estimator.

**Catalog References**: `Computation/PoincareThreshold/Defs.lean` (equidistant_no_edges_below, equidistant_complete_at), `Applications/PoincareData/SimplicialComplex.lean`

**Proof Strategy**:
1. Define sharpness formally: sharp(X) = diam(X) / min_{i≠j} dist(i,j).
2. For the equidistant cloud, sharp = 1 (the sharpest transition).
3. Bound sharp for uniform sphere samples using sphere packing bounds.
4. Relate to curvature via comparison geometry.

**Domain Bridges**: Computation <-> Geometry (curvature meets combinatorial phase transitions)

**Lineage**: Extends equidistant_no_edges_below and equidistant_complete_at from this cycle.

**Ambition**: extension

---

### Direction 5: Tropical Poincaré Threshold

**Conjecture**: Replace the standard (ℝ, +, ×) arithmetic with tropical (ℝ ∪ {∞}, min, +) arithmetic in the Poincaré detector. The *tropical Poincaré threshold* — defined using the tropical distance (min-plus path metric on the Rips graph) — equals the ordinary threshold for ultrametric spaces but differs for general metrics, with the ratio bounded by the hyperbolicity constant.

**Test**: Compute both thresholds for random point clouds and verify the ratio correlates with Gromov hyperbolicity.

**Impact**: Would connect the Poincaré threshold to tropical geometry, creating a bridge between manifold detection and the tropical complexity theory already developed in the Catalog.

**Catalog References**: `Computation/CollatzTropical.lean`, `Computation/TropicalAmortized.lean`, `Computation/PoincareThreshold/Defs.lean`

**Proof Strategy**:
1. Define tropical distance on the Rips graph: d_trop(i,j) = min-weight path from i to j.
2. Show tropical distance ≤ ordinary distance (every edge is a one-hop path).
3. For ultrametric spaces, show equality (strong triangle inequality implies shortest path uses one hop).
4. Bound the ratio using Gromov's four-point condition.

**Domain Bridges**: Computation <-> Tropical (connects topological data analysis to tropical geometry)

**Lineage**: Builds on the PoincareDetector from this cycle and tropical infrastructure from the Catalog.

**Ambition**: extension
