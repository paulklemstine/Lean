# Future Directions: Discrete Uniformization via Curvature Flow

## Synthesis

The results established in this cycle — variance decomposition, zero-variance characterization, Gauss-Bonnet mean curvature, conformal class theory, Pythagorean angle connections, and greedy flow invariance — form a coherent foundation for attacking the full discrete uniformization conjecture. The key insight is that curvature variance serves as a perfect Lyapunov function: it is zero exactly at the target (equicurved profiles), it decomposes cleanly via the bias-variance identity, and it is preserved-in-mean by Gauss-Bonnet. The remaining challenge is bridging the gap between abstract curvature redistribution steps and actual edge flips on triangulations.

The five directions below form a progression from near-term extensions (Directions 1–2) building directly on our formalized results, through ambitious structural conjectures (Directions 3–4), to a paradigm-shifting grand challenge (Direction 5) that would establish the full combinatorial uniformization theorem.

---

## Direction 1: Spectral Gap for Curvature Redistribution

**Conjecture.** For any curvature profile K on n ≥ 4 vertices satisfying Gauss-Bonnet for genus 0 with Var(K) > 0, the greedy pairwise t=1/2 curvature step reduces variance by at least Var(K)/n². More precisely, there exist indices i ≠ j such that:

$$\text{Var}(K) - \text{Var}(\text{step}(K, i, j, 1/2)) \geq \frac{\text{Var}(K)}{n^2}$$

**Test.** For n = 4, 6, 8, ..., 30:
1. Generate 10,000 random curvature profiles with ∑K_i = 4π
2. For each profile, compute the best pairwise step reduction
3. Compute the ratio (reduction / variance)
4. Verify ratio ≥ 1/n² for all profiles
5. Plot the minimum observed ratio vs. 1/n² on log-log scale

If the minimum ratio scales as Θ(1/n) rather than Θ(1/n²), the conjecture can be strengthened. If any ratio drops below 1/n², the conjecture is falsified.

**Impact.** A proof would establish O(n³ log(1/ε)) convergence for the greedy algorithm (n² pairs × n³ steps). A strengthened 1/n bound would give O(n² log(1/ε)) convergence.

**Catalog References.**
- `Pythagorean/CurvatureVariance.lean:sq_dist_decomposition` — variance decomposition
- `Pythagorean/CurvatureVariance.lean:curvatureStep_preserves_sum` — sum preservation
- `Pythagorean/CurvatureVariance.lean:optimal_target_is_mean` — mean optimality

**Proof Strategy.** Use the Cauchy-Schwarz inequality on the deviation vector (K - K̄). The best pairwise step selects the pair (i,j) maximizing |K(i) - K(j)|². By pigeonhole, this maximum is at least Var(K)/n, giving a reduction of at least Var(K)/(2n²).

**Domain Bridges.** Spectral graph theory (Cheeger inequality), random walks on graphs.

**Lineage.** Direct extension of variance decomposition theorem.

**Ambition.** Solid extension — the tools are in place, the conjecture is precise.

---

## Direction 2: Pythagorean Curvature Realizability

**Conjecture.** A curvature profile K : Fin n → ℝ is realizable by a right-angle triangulation of S² if and only if:
1. ∑K(i) = 4π (Gauss-Bonnet)
2. For each i, K(i) = 2π(1 - d_i/4) for some positive integer d_i (degree constraint)
3. ∑d_i = 4(n - 2) (Euler formula for triangulations)

Furthermore, each valid degree sequence {d_i} determines a Pythagorean-compatible curvature profile.

**Test.**
1. Enumerate all integer degree sequences {d_1,...,d_n} with ∑d_i = 4(n-2) and d_i ≥ 3 for n = 4, 5, ..., 12
2. For each sequence, compute K(i) = 2π(1 - d_i/4)
3. Verify ∑K(i) = 4π
4. Attempt to construct an actual right-angle triangulation realizing each degree sequence
5. The conjecture is falsified if a valid degree sequence has no right-angle realization

**Impact.** Would establish the first complete realizability criterion connecting number theory to surface geometry. Would enable enumeration of all right-angle-triangulated spheres.

**Catalog References.**
- `Pythagorean/CurvatureVariance.lean:right_angle_vertex_curvature` — curvature formula
- `Pythagorean/CurvatureVariance.lean:flat_right_angle_degree` — flatness at degree 4
- `Pythagorean/CurvatureVariance.lean:positive_curvature_degree_bound` — degree bound
- `Catalog/Geometry/DiscreteGaussBonnet.lean:discrete_gauss_bonnet` — Gauss-Bonnet

**Proof Strategy.** The necessary conditions follow from our formalized results. Sufficiency requires a constructive argument: given a valid degree sequence, build the dual graph (a planar graph with specified face sizes) and show it is realizable.

**Domain Bridges.** Combinatorial topology, planar graph theory, Steinitz theorem.

**Lineage.** Builds on Pythagorean angle theory from this cycle.

**Ambition.** Solid extension with potential for surprising connections.

---

## Direction 3: Tropical Energy and the Curvature Landscape

**Conjecture.** The curvature variance functional, viewed as a function on the space of curvature profiles satisfying Gauss-Bonnet, has no spurious local minima for genus 0. That is, the only critical point of Var(K) subject to ∑K(i) = 4π is the global minimum K(i) = 4π/n for all i.

**Test.**
1. For n = 4, ..., 20, parameterize the (n-1)-dimensional simplex {K : ∑K_i = 4π}
2. Compute ∇Var(K) on a fine grid
3. Check for critical points (‖∇Var‖ < ε) other than the uniform profile
4. Verify by gradient descent from 1000 random starting points that all trajectories converge to K̄

If any non-uniform critical point is found, the conjecture is falsified.

**Impact.** Would establish that the curvature variance landscape is "benign" (convex when restricted to the Gauss-Bonnet constraint surface), explaining the empirical success of greedy algorithms. This connects to tropical convexity: the variance functional is a tropical polynomial in the edge weights.

**Catalog References.**
- `Pythagorean/CurvatureVariance.lean:variance_eq_zero_iff` — zero variance characterization
- `Pythagorean/CurvatureVariance.lean:equicurved_iff` — equicurved characterization
- `Pythagorean/CurvatureVariance.lean:min_variance_minimizes_dist` — minimum variance optimality

**Proof Strategy.** Show that Var(K) restricted to {∑K_i = c} is strictly convex: its Hessian is I - (1/n)𝟏𝟏ᵀ (identity minus rank-1), which is positive definite on the constraint hyperplane.

**Domain Bridges.** Tropical geometry, convex optimization, Morse theory.

**Lineage.** Motivated by variance decomposition and tropical geometry literature.

**Ambition.** Grand challenge — would unify optimization landscape theory with discrete geometry.

---

## Direction 4: Weil-Petersson Metric on the Discrete Flip Graph

**Conjecture.** The diameter of the flip graph of triangulations of a genus-g surface with n vertices, measured in the Weil-Petersson-like metric induced by curvature variance, is Θ(n · g^{1/2}). Specifically:

$$c_1 \cdot n \cdot \sqrt{g} \leq \text{diam}_{WP}(\mathcal{F}_{n,g}) \leq c_2 \cdot n \cdot \sqrt{g}$$

for universal constants c₁, c₂ > 0.

**Test.**
1. For small (n, g) pairs — (8,0), (10,0), (12,0), (7,1), (10,1), (10,2) — enumerate the flip graph
2. Define the WP distance between adjacent triangulations as |Var(K₁) - Var(K₂)|^{1/2}
3. Compute the diameter via BFS
4. Fit the diameter to the model c · n · g^α and estimate α
5. The conjecture predicts α ≈ 1/2

**Impact.** Would connect the combinatorial geometry of flip graphs to the Riemannian geometry of Teichmüller space, where the Weil-Petersson metric governs the geometry of conformal structures. This bridge could import powerful tools from hyperbolic geometry.

**Catalog References.**
- `Catalog/Geometry/DiscreteGaussBonnet.lean:eulerChar_eq_two_sub_two_mul_genus` — genus formula
- `Catalog/Geometry/DiscreteGaussBonnet.lean:total_curvature_eq_genus` — curvature-genus relation
- `Pythagorean/CurvatureVariance.lean:conformal_class_same_mean` — conformal class mean

**Proof Strategy.** Lower bound: construct explicit pairs of triangulations at WP-distance Ω(n√g) using handle decomposition. Upper bound: show that any two triangulations can be connected by O(n) flips per handle, each changing variance by O(√g/n).

**Domain Bridges.** Teichmüller theory, hyperbolic geometry, spectral graph theory.

**Lineage.** Builds on conformal class theory and Gauss-Bonnet constraints.

**Ambition.** Grand challenge — would establish a new bridge between combinatorics and Riemannian geometry.

---

## Direction 5: Full Discrete Uniformization Theorem

**Conjecture.** For every closed orientable triangulated surface T of genus g with n vertices, and every target curvature profile K* satisfying ∑K*(v) = 2π(2-2g), there exists a sequence of O(n³) edge flips transforming T into a triangulation T' with K_{T'} = K*.

**Test.**
1. For n = 6, ..., 12 on S², enumerate all triangulations with the same vertex set
2. For each pair (T₁, T₂), compute the shortest flip sequence via BFS
3. Verify the sequence length is ≤ 6n - 15 (the conjectured bound for S²)
4. Verify that curvature profiles match after the flip sequence
5. For genus 1, test with n = 7 (minimal torus triangulation) and its flips

**Impact.** A complete proof would be the first constructive discrete uniformization theorem — the combinatorial analogue of one of the deepest results in mathematics. It would establish that combinatorial topology determines conformal geometry, with algorithmic implications for mesh processing, medical imaging, and computational physics.

**Catalog References.**
- `Catalog/Geometry/DiscreteGaussBonnet.lean:discrete_gauss_bonnet` — Gauss-Bonnet
- `Catalog/Geometry/DiscreteGaussBonnet.lean:total_curvature_nonpos_high_genus` — genus obstruction
- `Pythagorean/CurvatureVariance.lean:equicurved_iff` — equicurved characterization
- `Pythagorean/CurvatureVariance.lean:conformal_class_same_mean` — conformal class mean
- `Pythagorean/CurvatureVariance.lean:min_variance_minimizes_dist` — optimality

**Proof Strategy.** Induction on genus:
- Base case (g=0): Use Negami's theorem that the flip graph of S² is connected, combined with variance monotonicity to bound the number of flips.
- Inductive step: Decompose the surface as S^g = S^0 # S^{g-1}. Show that flips can be localized to handles. Apply the inductive hypothesis to each component.

The key missing lemma is that flip graph connectivity implies curvature profile reachability — that is, every curvature profile in the conformal class can be achieved.

**Domain Bridges.** Complex analysis (uniformization), geometric topology (Pachner moves), algebraic geometry (moduli spaces), mathematical physics (2D quantum gravity).

**Lineage.** Ultimate goal of the research program initiated in this cycle.

**Ambition.** Paradigm-shifting — would resolve a decades-old open problem and establish a new computational paradigm for conformal geometry.
