# Future Directions: Spectral Gap Theory for Discrete Curvature Flow

## Synthesis

The spectral gap framework established in `Pythagorean/CurvatureFlow/SpectralGap.lean` provides a modular, formally verified foundation for exponential convergence of discrete curvature flow. The key insight — decomposing convergence into Dirichlet capture, Poincaré inequality, and geometric iteration — creates a reusable interface that opens five major research directions. These range from concrete verification of spectral gaps on specific graph families (Direction 1) to ambitious connections with continuous Ricci flow (Direction 5). Each direction is testable: we specify exact computational experiments that would validate or refute the conjectures.

The five directions form a coherent program: Directions 1-2 solidify the foundations by proving spectral gaps for specific graph classes. Direction 3 extends the framework to richer physical models with entropy. Directions 4-5 are paradigm-shifting: they propose universal scaling laws and continuous limits that, if true, would unify discrete combinatorial geometry with the analytic theory of geometric flows.

---

## Direction 1: Spectral Gap Verification for Delaunay Triangulations

**Conjecture:** Every Delaunay triangulation of n points in convex position satisfies the Poincaré inequality λ₁ ≥ C/n² with a universal constant C ≥ 1/(2π), where λ₁ is the smallest non-zero eigenvalue of the graph Laplacian.

**Test:** Generate random Delaunay triangulations of n points uniformly distributed in the unit disk, for n ∈ {50, 100, 200, 500, 1000}. Compute λ₁ of the graph Laplacian using scipy.sparse.linalg.eigsh. Plot n² · λ₁ versus n. If the conjecture holds, n² · λ₁ should be bounded below by C > 0 as n → ∞. If n² · λ₁ → 0, the conjecture is false.

**Impact:** Would provide the first concrete instance of the spectral gap hypothesis, converting our conditional exponential convergence theorem into an unconditional result for Delaunay triangulations.

**Catalog References:** `Pythagorean/CurvatureFlow/SpectralGap.lean` (HasUniversalSpectralGap structure), `Pythagorean/CurvatureFlow/Defs.lean` (pairwise_sq_diff_eq).

**Proof Strategy:** Use the canonical paths / congestion method (Strategy C in the research paper). For Delaunay triangulations, the maximum edge congestion is O(n) because shortest paths have length O(√n) and each edge carries O(√n) paths, giving congestion O(n). The Poincaré constant is then at least 1/(congestion) = Ω(1/n), yielding λ₁ ≥ Ω(1/(n · diameter)) = Ω(1/n²).

**Domain Bridges:** Computational geometry ↔ spectral graph theory ↔ discrete curvature flow.

**Lineage:** Extends `variance_le_exp_nsq` from conditional to unconditional for Delaunay triangulations.

**Ambition:** Solid extension — fills the most important gap in the current framework.

---

## Direction 2: Genus-Independent Spectral Constant

**Conjecture:** The optimal spectral gap constant C* in the inequality V(k+1) ≤ (1 − C*/n²) · V(k) is independent of the genus g of the surface, for fixed local move rule (edge flips).

**Test:** For each genus g ∈ {0, 1, 2} and each n ∈ {50, 100, 200, 500}, generate 100 random triangulations. Run greedy curvature flow for 10·n² steps. Estimate C*(g, n) = min_k n² · (1 − V(k+1)/V(k)). Compare the distributions of C* across genera using Kolmogorov-Smirnov tests. A statistically significant separation between genera would refute the conjecture.

**Impact:** If true, this would establish that topology affects the equilibrium manifold (where the flow converges — constant curvature depends on genus) but not the relaxation exponent (how fast it gets there). This is a mathematically sharp dichotomy between static and dynamic effects of topology.

**Catalog References:** `Pythagorean/CurvatureFlow/Convergence.lean` (FlowSystem.convergence), `Pythagorean/CurvatureFlow/SpectralGap.lean` (variance_le_exp_nsq).

**Proof Strategy:** Show that the canonical paths argument (Direction 1) depends only on local mesh geometry (vertex degrees, edge lengths) and not on global topology. Since triangulations of any genus have bounded vertex degree (≤ 6 for most practical triangulations), the congestion bound should be genus-independent.

**Domain Bridges:** Algebraic topology ↔ spectral theory ↔ dynamical systems.

**Lineage:** Builds on Direction 1 and the existing genus-agnostic formulation of SpectralFlowSystem.

**Ambition:** Grand challenge — would sharply separate topology from dynamics.

---

## Direction 3: Entropy Decay and the Boltzmann Spectral Gap

**Conjecture:** There exists a discrete entropy functional H(K) = Σ φ(K(v)) (for a suitable convex function φ) satisfying:
1. c₁ · V(K) ≤ H(K) ≤ c₂ · V(K) along the flow (equivalence with variance).
2. H(K_k) − H(K_{k+1}) ≥ c · E_H(K_k), where E_H is the entropy-Dirichlet energy.
3. The entropy-Poincaré inequality: p_H · H ≤ E_H with p_H ≥ C_H/n².

This would give exponential entropy decay at the same n⁻² scale as variance decay.

**Test:** Define candidate entropies H_α(K) = Σ |K(v) − K̄|^α for α ∈ {1, 1.5, 2, 3}. Run greedy curvature flow on random triangulations and compute the ratios H_α(k)/V(k) along trajectories. If the ratio stays bounded (both above and below) for some α, that α is a viable entropy. Additionally, plot log H_α(k) vs k/n² to check for exponential decay. If H_α decays sub-exponentially for all α, the conjecture fails.

**Impact:** Establishes a second Lyapunov function for curvature flow, opening connections to information theory (entropy production), statistical mechanics (free energy), and optimal transport (Wasserstein gradient flows).

**Catalog References:** `Pythagorean/CurvatureFlow/SpectralGap.lean` (SpectralFlowSystem — can be instantiated with entropy instead of variance), `Pythagorean/CurvatureFlow/Defs.lean` (cVar_nonneg, sum_dev_eq_zero).

**Proof Strategy:** Use the modified log-Sobolev inequality framework. For the quadratic case (α = 2), H = V and the result is already proven. For α ≠ 2, establish Taylor-expansion comparisons near equilibrium where K(v) ≈ K̄, showing that different entropies agree to leading order.

**Domain Bridges:** Information theory ↔ statistical mechanics ↔ optimal transport ↔ discrete geometry.

**Lineage:** Extends SpectralFlowSystem to non-quadratic Lyapunov functions.

**Ambition:** Grand challenge — would create a discrete analog of the entropy-entropy production framework.

---

## Direction 4: Cutoff Phenomenon for Curvature Flow

**Conjecture:** After rescaling time by n², the normalized variance trajectories exhibit a cutoff phenomenon: there exists t* > 0 such that for all ε > 0:
- V(⌊(t* − ε)n²⌋) / V(0) → 1 as n → ∞
- V(⌊(t* + ε)n²⌋) / V(0) → 0 as n → ∞

In other words, the system transitions sharply from "far from equilibrium" to "near equilibrium" at a precise rescaled time t*.

**Test:** For n ∈ {100, 200, 500, 1000, 2000}, generate 50 random triangulations each. Run curvature flow and plot V(⌊t·n²⌋)/V(0) vs t for each trajectory. If cutoff exists, the curves should concentrate around a step function as n increases. Measure the width of the transition window w(n) = {t : 0.1 ≤ V/V₀ ≤ 0.9}; if w(n) → 0 as n → ∞, cutoff is present. If w(n) stays bounded away from 0, there is no cutoff.

**Impact:** Cutoff phenomena are among the most striking discoveries in modern probability theory, first observed in card shuffling (the "seven shuffles" theorem of Diaconis). Proving cutoff for curvature flow would be the first instance in discrete geometry and would connect to deep questions about spectral gap vs. spectral profile.

**Catalog References:** `Pythagorean/CurvatureFlow/SpectralGap.lean` (geom_decay_eventually_small, variance_le_exp_nsq).

**Proof Strategy:** Prove matching upper and lower bounds on the mixing profile. The upper bound follows from our spectral gap theorem. The lower bound requires a "bottleneck" or "distinguishing statistic" argument showing that at time (t* − ε)n², the flow has not yet mixed. This likely requires understanding the second eigenfunction of the flow's linearization.

**Domain Bridges:** Probability theory (Markov chain cutoff) ↔ spectral theory ↔ discrete geometry ↔ information theory.

**Lineage:** Builds on Direction 2 (genus-independence is necessary for universal t*).

**Ambition:** Grand challenge — paradigm-shifting if true, connecting two major research programs.

---

## Direction 5: Scaling Limit to Continuous Ricci Flow

**Conjecture:** As the mesh is refined (n → ∞ with mesh diameter → 0), the greedy discrete curvature flow converges (in a suitable sense) to the continuous combinatorial Ricci flow of Chow-Luo (2003), and the discrete spectral gap converges to the spectral gap of the Laplace-Beltrami operator on the limit surface.

**Test:** Take a fixed smooth surface (e.g., a standard torus). Create triangulations with n ∈ {100, 500, 2000, 10000} vertices approximating the surface. Run greedy curvature flow starting from a fixed initial curvature perturbation. Compare:
1. The discrete curvature K_n(t) at time t = ⌊s·n²⌋ with the continuous Ricci flow K(s) at time s.
2. The discrete spectral gap n² · λ₁(G_n) with the spectral gap λ₁(M) of the Laplace-Beltrami operator.

If the discrete flow diverges from the continuous one, or if n² · λ₁(G_n) does not converge, the conjecture fails.

**Impact:** Would establish discrete curvature flow as a legitimate numerical method for continuous Ricci flow, with convergence rates. This connects discrete combinatorial geometry to the analytic machinery of Hamilton-Perelman theory.

**Catalog References:** `Pythagorean/CurvatureFlow/SpectralGap.lean` (entire framework), `Pythagorean/CurvatureFlow/Defs.lean` (DiscreteLaplacian, laplacian_preserves_sum).

**Proof Strategy:** Use the theory of Γ-convergence for the energy functionals and the Trotter-Kato theorem for the flow semigroups. The key technical challenge is showing that the discrete Laplacian converges to the Laplace-Beltrami operator in a sufficiently strong sense (operator-norm convergence on a suitable function space).

**Domain Bridges:** Numerical analysis ↔ differential geometry ↔ PDE theory ↔ discrete geometry ↔ spectral theory.

**Lineage:** Builds on all four preceding directions; represents the ultimate synthesis of discrete and continuous curvature flow theory.

**Ambition:** Grand challenge — paradigm-shifting, would unify discrete and continuous geometric flow theory.
