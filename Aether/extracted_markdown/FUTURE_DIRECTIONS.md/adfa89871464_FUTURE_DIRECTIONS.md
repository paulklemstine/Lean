# Future Directions: Weighted Curvature Variance and Discrete Optimal Transport

## Synthesis

The weighted curvature variance theory established in this cycle opens a **three-way bridge** between discrete geometry, optimal transport, and spectral graph theory. The condition number κ = w_max/w_min emerged as the universal control parameter: it governs convergence speed (Theorem 5), bounds the gap between weighted and unweighted variance, and is conjectured to equal the discrete Poincaré constant of the weighted flip graph.

The five directions below form a coherent research program:
- **Directions 1-2** deepen the optimal transport connection (tight bounds + spectral gap).
- **Direction 3** extends the theory to dynamic, adaptive settings.
- **Direction 4** bridges to information geometry via Fisher information.
- **Direction 5** is a grand challenge: extending to higher-dimensional simplicial complexes.

Each direction builds directly on the machine-verified theorems from this cycle and is designed to be falsifiable through explicit computational experiments.

---

## Direction 1: Tight Convergence Rate — The κ-Scaling Conjecture

**Conjecture:** The convergence time $T(\varepsilon) = \min\{k : V_w^{(k)} < \varepsilon\}$ satisfies
$$T(\varepsilon) = \Theta\left(\frac{\kappa \cdot V_w^{(0)}}{\varepsilon}\right)$$
where the $\Theta$-constant is independent of $n$ and the specific weight distribution, depending only on the combinatorial structure of the triangulation.

**Test:** Generate random weighted planar triangulations with $n \in \{50, 100, 200, 500\}$ vertices. For each $n$, draw weights from Pareto($\alpha$) with $\alpha \in \{1.1, 1.5, 2, 4, 8\}$, giving condition numbers $\kappa \in [2, 500]$. Run weighted greedy flow to $\varepsilon = 0.001$. Fit $\log T$ vs $\log(\kappa V_0/\varepsilon)$. **Prediction:** slope $\approx 1.0 \pm 0.1$ with $R^2 > 0.95$. If slope $< 0.5$ or $> 2.0$, the conjecture is false.

**Impact:** A proof would establish the first tight convergence rate for weighted discrete curvature flow, analogous to the Langevin diffusion convergence rates in continuous optimal transport.

**Catalog References:**
- `Pythagorean/CurvatureFlow/Convergence.lean:FlowSystem.convergence` (upper bound)
- `Pythagorean/CurvatureFlow/WeightedVariance.lean:WeightedFlowSystem.convergence` (κ-dependent upper bound)

**Proof Strategy:** Construct an explicit sequence of triangulations achieving $T(\varepsilon) \geq C_1 \kappa V_0/\varepsilon$ (lower bound). The construction places extreme curvature at the minimum-weight vertex, forcing the flow to move curvature through heavy vertices. Use the pairwise identity to track progress vertex by vertex.

**Domain Bridges:** Discrete geometry ↔ Optimization theory (condition-number-dependent convergence)

**Lineage:** Extends `WeightedFlowSystem.convergence` by proving matching lower bound.

**Ambition:** ★★★☆☆ (Extension — requires careful construction but no fundamentally new tools)

---

## Direction 2: Spectral Gap of the Weighted Flip Graph

**Conjecture:** The spectral gap $\lambda_1$ of the weighted Laplacian on the flip graph satisfies
$$\lambda_1 \geq \frac{C}{n^2 \kappa}$$
for a universal constant $C > 0$, where $\kappa$ is the condition number of the vertex weights.

**Test:** For triangulations of the sphere with $n \in \{10, 20, 50, 100\}$ vertices and weights from various distributions, compute the flip graph, form the weighted Laplacian, and measure $\lambda_1$ numerically. **Prediction:** $\lambda_1 \cdot n^2 \kappa$ converges to a constant as $n \to \infty$. If $\lambda_1 \cdot n^2 \kappa \to 0$ or $\to \infty$, the conjecture is false.

**Impact:** Would provide the first spectral characterization of weighted curvature flow, enabling exponential (rather than polynomial) convergence results via the Bakry-Émery theory.

**Catalog References:**
- `Pythagorean/CurvatureFlow/WeightedVariance.lean:conditionNumber_ge_one`
- `Pythagorean/CurvatureFlow/Convergence.lean:exponential_convergence_conjecture`

**Proof Strategy:** Use Cheeger's inequality to relate $\lambda_1$ to the isoperimetric constant of the flip graph. Bound the Cheeger constant using the combinatorial structure of Pachner moves. The $1/\kappa$ factor arises from the weight ratio at the bottleneck of the isoperimetric partition.

**Domain Bridges:** Discrete geometry ↔ Spectral graph theory ↔ Markov chain mixing

**Lineage:** Grand challenge extending the exponential convergence conjecture from Defs.lean.

**Ambition:** ★★★★★ (Grand challenge — connects to open problems in flip graph connectivity)

---

## Direction 3: Adaptive Weighted Flow with Dynamic Weights

**Conjecture:** If weights are updated adaptively at each step via $w_i^{(k+1)} = w_i^{(k)} \cdot (1 + \eta |K_i^{(k)} - \bar{K}_w|)$ with learning rate $\eta > 0$, the resulting flow converges to equilibrium and the condition number $\kappa^{(k)}$ remains bounded by $\kappa^{(0)} \cdot e^{\eta T}$ where $T$ is the convergence time.

**Test:** Implement adaptive weight updates alongside greedy flips. Start with uniform weights ($\kappa = 1$). Run for $n \in \{50, 100, 200\}$ with $\eta \in \{0.01, 0.1, 0.5\}$. Track both $V_w^{(k)}$ and $\kappa^{(k)}$. **Prediction:** $V_w$ converges faster than fixed-weight flow for small $\eta$, but $\kappa$ growth eventually dominates for large $\eta$, creating a U-shaped curve in total convergence time vs $\eta$.

**Impact:** Would establish the first adaptive mesh refinement algorithm with provable curvature guarantees.

**Catalog References:**
- `Pythagorean/CurvatureFlow/WeightedVariance.lean:weightedCurvVar_scale_invariant`
- `Pythagorean/CurvatureFlow/WeightedVariance.lean:WeightedFlowSystem.convergence`

**Proof Strategy:** Use the scale invariance theorem to normalize weights at each step. Bound condition number growth using the progress guarantee: if V_w decreases fast enough, the weight updates are small and κ growth is controlled.

**Domain Bridges:** Discrete geometry ↔ Online learning ↔ Adaptive algorithms

**Lineage:** Extends scale invariance and convergence to the dynamic setting.

**Ambition:** ★★★☆☆ (Extension — requires coupling analysis of two interacting dynamical systems)

---

## Direction 4: Fisher Information and Curvature — The Information-Geometric Bridge

**Conjecture:** The weighted curvature variance equals the $\chi^2$-divergence between the curvature distribution and its barycenter:
$$V_w = \chi^2(\mu_K \| \delta_{\bar{K}_w}) = \int \frac{(d\mu_K - d\delta_{\bar{K}_w})^2}{d\delta_{\bar{K}_w}}$$
Furthermore, the curvature flow decreases the Fisher information $I(\mu_K) = \sum_i \mu_w(i) (\partial_i \log \mu_K)^2$ at rate $1/\kappa$.

**Test:** Compute $\chi^2$-divergence and Fisher information numerically for random weighted triangulations. Verify $V_w = \chi^2$ exactly (up to floating point). Track Fisher information decay during flow and fit to $I^{(k)} \leq I^{(0)} (1 - C/\kappa)^k$. **Prediction:** Exact equality for $\chi^2$, exponential decay for Fisher information.

**Impact:** Would establish curvature flow as an information-theoretic process, connecting to the de Bruijn identity and the entropy power inequality.

**Catalog References:**
- `Pythagorean/CurvatureFlow/WeightedVariance.lean:weighted_pairwise_sq_diff_eq`
- `Pythagorean/CurvatureFlow/WeightedVariance.lean:weighted_var_cross_domain_bound`

**Proof Strategy:** The $\chi^2$ identity follows directly from the definition. The Fisher information bound requires establishing a discrete log-Sobolev inequality for the weighted flip graph, using the pairwise identity to decompose Fisher information into local contributions.

**Domain Bridges:** Discrete geometry ↔ Information geometry ↔ Statistical physics

**Lineage:** Extends the Popoviciu cross-domain connection to information-theoretic territory.

**Ambition:** ★★★★☆ (Paradigm-shifting — requires developing discrete information geometry tools)

---

## Direction 5: Weighted Curvature Flow on Simplicial Complexes (Grand Challenge)

**Conjecture:** The weighted curvature variance theory extends to $d$-dimensional simplicial complexes, with the condition number $\kappa$ of the vertex weight distribution controlling convergence of the generalized curvature (Regge calculus deficit angle) flow in $O(\kappa^d V_0/\varepsilon)$ steps.

**Test:** Implement weighted curvature flow on random 3-dimensional triangulations (tetrahedralizations) with $n \in \{100, 500, 2000\}$ vertices. Compare convergence times for $d = 2$ (surfaces) and $d = 3$ (solids) with the same $\kappa$ and $V_0$. **Prediction:** 3D convergence is $O(\kappa)$ times slower than 2D, supporting the $\kappa^d$ scaling.

**Impact:** Would establish the first general convergence theory for weighted discrete curvature flow in arbitrary dimension, with applications to 3D mesh generation for finite element analysis.

**Catalog References:**
- `Pythagorean/CurvatureFlow/WeightedVariance.lean:WeightedFlowSystem.convergence`
- `Pythagorean/CurvatureFlow/Convergence.lean:FlowSystem.convergence`

**Proof Strategy:** Generalize the Lyapunov analysis from surfaces to simplicial complexes. The key challenge is defining the "edge flip" analog (bistellar flips / Pachner moves) in higher dimensions and proving the progress guarantee. The pairwise identity should generalize via the simplicial Laplacian.

**Domain Bridges:** Discrete geometry ↔ Algebraic topology ↔ Finite element methods

**Lineage:** Grand challenge generalizing the entire weighted flow theory to higher dimensions.

**Ambition:** ★★★★★ (Grand challenge — requires fundamentally new tools for higher-dimensional combinatorial topology)
