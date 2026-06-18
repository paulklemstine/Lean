# Future Directions: Repulsive Information Geometry

## Synthesis

The identification of DPP log-Hessians with graph Laplacians opens a rich interface between probabilistic repulsion, electrical network theory, information geometry, and spectral graph theory. The formally verified Dirichlet form identity (Theorem 1) and its DPP specialization (Theorem 3) establish the foundational dictionary. The five directions below explore increasingly ambitious extensions, from immediate corollaries to potential paradigm shifts in how we understand negative dependence.

All directions share a common theme: **repulsion is geometry**. The log-Hessian defines not just a matrix but a metric space, and that metric space has the structure of a resistance network. Each direction exploits a different aspect of this geometric viewpoint.

---

## Direction 1: Entropy Bounds via Resistance Inequalities

**Conjecture:** For a DPP with kernel $L$ on $[n]$, the Shannon entropy $H(\mu)$ of the inclusion probabilities satisfies:
$$H(\mu) \leq \frac{1}{2} \sum_{i \neq j} L_{ij}^2 \cdot R_{\text{eff}}(i, j)$$
where $R_{\text{eff}}$ is the effective resistance in the graph with conductances $L_{ij}^2$.

**Test:** Compute both sides for random DPP kernels of size $n \leq 10$. Search for counterexamples and refine the bound constant.

**Impact:** This would give the first entropy bound for DPPs derived purely from resistance geometry, connecting Shannon theory to Kirchhoff's laws. It could improve existing bounds by Lyons (2003) on negative association.

**Catalog References:** `Catalog/Speculative/AutoResearch/DPPLorentzian.lean` (DPP partition function), `Catalog/Pythagorean/RepulsiveInfoGeometry.lean` (Dirichlet form identity).

**Proof Strategy:** Use the variational characterization of entropy and the Dirichlet form identity to bound the KL divergence between the DPP and a product distribution. Apply the resistance monotonicity principle (Rayleigh) to simplify.

**Domain Bridges:** Information theory ↔ Electrical networks ↔ Probability.

**Lineage:** Extends Theorem 1 (Dirichlet form) and the Fisher-repulsion equivalence.

**Ambition:** Grand challenge — if successful, creates a new class of entropy inequalities.

**The key insight is** that the pairwise Dirichlet form controls the KL divergence between the DPP and its closest independent approximation, and resistance bounds directly bound this divergence.

**Why now?** The Dirichlet form identity (formally verified) provides the precise tool needed to convert Hessian curvature into pairwise resistance sums, which was the missing link.

---

## Direction 2: Natural Gradient Optimization via Laplacian Solvers

**Conjecture:** The natural gradient for maximum likelihood estimation of DPP parameters can be computed in $\tilde{O}(n^2)$ time (near-linear in the number of matrix entries) using fast Laplacian solvers.

**Test:** Implement natural gradient DPP estimation using Spielman-Teng Laplacian solvers and compare convergence speed and per-iteration cost with standard gradient descent and Newton's method.

**Impact:** Current DPP parameter estimation requires $O(n^3)$ per iteration (for the pseudoinverse). If the log-Hessian Laplacian structure can be exploited, this drops to $\tilde{O}(n^2)$, making DPP learning practical for large datasets.

**Catalog References:** `Catalog/Pythagorean/RepulsiveInfoGeometry.lean` (dpp_laplacianEnergy_eq_resolventDirichlet), `Catalog/Speculative/AutoResearch/DPPLorentzian.lean` (DPPKernel structure).

**Proof Strategy:** Show that the natural gradient direction $H^+ \nabla$ can be approximated by solving the Laplacian system $Hx = \nabla$ (projected to zero-sum). Apply Spielman-Teng nearly-linear-time Laplacian solver.

**Domain Bridges:** Optimization ↔ Spectral graph theory ↔ Machine learning.

**Lineage:** Direct application of Theorem 3 (DPP Dirichlet form).

**Ambition:** Solid extension — the mathematical infrastructure is in place, and the algorithmic speedup is a concrete, testable claim.

**The key insight is** that the natural gradient preconditioner for DPPs is a graph Laplacian, and graph Laplacians admit nearly-linear-time solvers.

**Why now?** The formal identification of the DPP Hessian as a Laplacian (Theorem 3) removes the conceptual gap between DPP optimization and Laplacian linear algebra.

---

## Direction 3: Repulsion Metric as a Lorentzian Hessian

**Conjecture:** For any Lorentzian polynomial $p$ (in the sense of Brändén-Huh), the Hessian of $\log p$ at any point in the positive orthant defines a graph Laplacian on the zero-sum subspace, generalizing the DPP case.

**Test:** Compute log-Hessians for known families of Lorentzian polynomials (elementary symmetric polynomials, basis generating polynomials of matroids) and check whether they have the Laplacian structure (nonpositive off-diagonal, zero row sums, PSD on zero-sum).

**Impact:** Would unify the Laplacian interpretation across all Lorentzian polynomials, not just DPP generating polynomials. This would bring the entire Brändén-Huh theory into contact with resistance networks.

**Catalog References:** `Catalog/Speculative/AutoResearch/DPPLorentzian.lean` (IsDPPLorentzian definition, dpp_partition_function_lorentzian conjecture), `Catalog/Pythagorean/RepulsiveInfoGeometry.lean` (laplacianEnergy_eq_pairwise).

**Proof Strategy:** Use the characterization of Lorentzian polynomials via their Hessian eigenvalue signature (at most one positive eigenvalue for degree-2 derivatives). Show that this implies the log-Hessian has the Laplacian sign pattern.

**Domain Bridges:** Algebraic combinatorics (Lorentzian polynomials) ↔ Spectral graph theory ↔ Information geometry.

**Lineage:** Extends Theorem 3 from DPP generating polynomials to all Lorentzian polynomials.

**Ambition:** Grand challenge — would create a unified theory of "Lorentzian resistance networks."

**The key insight is** that the Lorentzian condition (at most one positive eigenvalue per Hessian slice) might force the log-Hessian to have the sign pattern of a Laplacian, extending the DPP result to all strongly log-concave polynomials.

**Why now?** The DPP case (verified in this work) provides the first concrete example, and the Brändén-Huh theory provides the algebraic tools needed for the general case.

---

## Direction 4: Fluctuation-Dissipation for DPPs (Statistical Physics Bridge)

**Conjecture:** For a DPP at inverse temperature $\beta$ (i.e., with kernel $\beta L$), the static susceptibility matrix $\chi_{ij} = \partial \langle n_i \rangle / \partial h_j$ (response of marginal to external field) equals $\beta$ times the effective resistance Green function of the graph with conductances $\beta^2 L_{ij}^2$.

**Test:** For small DPP instances ($n \leq 6$), compute the susceptibility matrix by finite differences of marginal probabilities and compare to the predicted resistance Green function.

**Impact:** Would establish a fluctuation-dissipation theorem for DPPs, connecting the variance of occupation numbers (fluctuation) to the response to external fields (dissipation) via the resistance metric. This would import the full toolkit of linear response theory from statistical physics.

**Catalog References:** `Catalog/Pythagorean/RepulsiveInfoGeometry.lean` (dppLogHessian, laplacianEnergy_eq_pairwise), `Catalog/Speculative/AutoResearch/DPPLorentzian.lean` (dpp_partitionFunction_eval_ones).

**Proof Strategy:** Differentiate the log-partition function $\log \det(I + \text{diag}(e^h) \cdot \beta K)$ twice with respect to the field $h$, and show the result is the Laplacian pseudoinverse.

**Domain Bridges:** Statistical physics (fluctuation-dissipation) ↔ Information geometry (Fisher metric) ↔ Electrical networks (resistance).

**Lineage:** Builds on the Fisher-repulsion connection (Conjecture B) and the Dirichlet form identity.

**Ambition:** Solid extension — the calculation is straightforward, but the conceptual unification is significant.

**The key insight is** that the DPP susceptibility is the derivative of the marginal kernel with respect to external fields, and this derivative is controlled by the log-Hessian (= Laplacian), whose inverse is the resistance Green function.

**Why now?** The formal identification of the Hessian as a Laplacian (this work) provides the missing dictionary entry between DPP response functions and resistance.

---

## Direction 5: Geodesic Convexity and Cramér-Rao Bounds on Repulsive Manifolds

**Conjecture:** The log-likelihood function of a DPP, viewed as a function on the statistical manifold with the repulsion metric, is geodesically convex in a neighborhood of the true parameter. Consequently, the Cramér-Rao bound for DPP estimation can be tightened using resistance-geometric techniques.

**Test:** For parameterized families of DPPs (e.g., Gaussian DPPs on $\mathbb{R}^d$ restricted to $n$ points), compute the geodesic convexity radius numerically and compare the classical Cramér-Rao bound with the geodesically corrected version.

**Impact:** Would give optimal estimation bounds for DPP parameters that account for the curved geometry of the parameter space. Classical Cramér-Rao bounds ignore curvature; geodesic corrections can be dramatically tighter.

**Catalog References:** `Catalog/Pythagorean/RepulsiveInfoGeometry.lean` (laplacianEnergy_posDef_on_zeroSum — ensures the metric is genuine).

**Proof Strategy:** Compute the Riemannian curvature of the repulsion metric (which is the Laplacian metric on the zero-sum subspace), bound the sectional curvatures, and use Toponogov comparison to establish convexity.

**Domain Bridges:** Statistics (Cramér-Rao) ↔ Riemannian geometry (geodesic convexity) ↔ Electrical networks (resistance curvature).

**Lineage:** Extends the positive definiteness result (Theorem 2) to a full Riemannian geometry framework.

**Ambition:** Grand challenge — would create a new class of estimation bounds for repulsive models.

**The key insight is** that the repulsion metric, being a graph Laplacian metric, has bounded curvature related to the spectral gap and graph connectivity, and these bounds translate into statistical efficiency guarantees.

**Why now?** The positive definiteness theorem (formally verified) establishes that the repulsion metric is genuine, and the Dirichlet form identity provides computable formulas for all metric quantities.
