# Future Directions: Concavity Depth as a Spectral Resource

## Synthesis

The work in this cycle establishes **concavity depth** as a new computational invariant linking the recursive structure of probability distributions to spectral gap bounds for Markov chains. We proved that the k-fold log-concavity hierarchy is strictly nested, closed under products, and connected to multiscale energy landscape convexity. Computational experiments revealed that the conjectured universal bound γ ≥ c_k/n^{2/k} requires refinement: flat distributions (like uniform) are trivially k-fold log-concave but do not enjoy improved mixing. This discovery points toward a **quantitative** theory of concavity depth that separates genuine geometric regularity from degenerate flatness. The five directions below chart a path from this foundation toward a full theory of shape-governed computation, with bridges to statistical physics, information theory, and algorithm design.

---

## Direction 1: Quantitative k-fold Log-Concavity and the Hardy Inequality

**Conjecture**: For distributions satisfying a *quantitative* k-fold log-concavity condition — where each ratio a(i)²/(a(i-1)·a(i+1)) ≥ 1 + δ for some δ > 0 — the spectral gap of the associated birth-death chain satisfies γ ≥ c(δ,k)/n^{2/k}.

**Test**: Formalize the discrete Hardy inequality for birth-death chains: Var_π(f) ≤ (max_m Σ_{i≤m} π(i) · Σ_{i>m} 1/c_i) · E(f,f). Then show that quantitative KLC bounds the resistance sum Σ 1/c_i through the iterated ratio tower. Numerically, compute the Hardy constant for discrete Gaussian families with varying a and verify the n^{2/k} scaling.

**Impact**: This would complete the central theorem of the program, providing the first formally verified connection between recursive distributional structure and spectral bounds. It would also resolve the "uniform counterexample" by showing that quantitative concavity strength is the missing ingredient.

**Catalog References**: `Catalog/Pythagorean/CertificateSampling.lean` (spectral_gap_log_concave_lower_bound), `Pythagorean/MixingTimeConcavityDepth.lean` (variance_le_dirichlet_of_KLC — the remaining sorry).

**Proof Strategy**: (1) Define quantitative KLC with parameter δ. (2) Prove that δ-KLC implies edge conductance lower bound c_i ≥ δ^{k-1}/n^{2/k-1}. (3) Substitute into the Hardy inequality. (4) Invoke the variational characterization of the spectral gap.

**Domain Bridges**: Probability ↔ Functional Analysis (Hardy/Poincaré inequalities), Probability ↔ Algorithms (complexity of sampling).

**Lineage**: Directly extends poincare_const_improvement and KLC.iterRat_lc from this cycle.

**Ambition**: Solid extension. Resolves the main open problem of the current development.

---

## Direction 2: Higher-Dimensional Concavity Depth and Lorentzian Polynomials

**Conjecture**: For multivariate distributions arising as coefficients of Lorentzian polynomials in n variables of degree d, there exists a notion of "Lorentzian depth" that controls the spectral gap of natural Glauber dynamics on the support, with gap scaling as n^{-2/d} rather than n^{-2}.

**The key insight is** that the recursive structure of Lorentzian polynomials — where every restriction to a hyperplane is again Lorentzian — provides exactly the "tower of concavity constraints" that our 1D theory exploits, but now in multiple dimensions. The one-dimensional ratio sequence becomes a family of directional restrictions.

**Why now?** The Brändén-Huh theory of Lorentzian polynomials [2020] provides the algebraic foundation, and our 1D results demonstrate the spectral consequences. The Anari-Liu-Oveis Gharan-Vinzant sampling results [2019] provide the algorithmic context. The missing piece is the spectral gap analysis, which our framework is designed to provide.

**Test**: For specific Lorentzian polynomials (e.g., homogeneous stable polynomials with known support structure), compute the Glauber dynamics spectral gap and test the n^{-2/d} scaling numerically. Formalize the notion of Lorentzian depth in Lean, building on the existing KFoldLogConcave hierarchy.

**Impact**: Would establish a systematic theory of sampling complexity for Lorentzian polynomial distributions, with applications to matroid bases, graph colorings, and determinantal point processes.

**Catalog References**: `Catalog/Pythagorean/HigherOrderLogConcavity.lean` (KFoldLogConcave, RecursiveLorentzianSequence), `Catalog/Pythagorean/CertificateSampling.lean` (certificate_sampling_efficiency).

**Proof Strategy**: Define multivariate KLC via directional restrictions. Prove that each restriction provides a 1D Poincaré inequality. Aggregate via tensorization or comparison.

**Domain Bridges**: Combinatorics ↔ Algorithms (sampling from matroids), Algebraic Geometry ↔ Probability (Lorentzian polynomials as distributions).

**Lineage**: Extends geometric_KLC and KLC.mul to the multivariate setting.

**Ambition**: Grand challenge. Would unify the Lorentzian polynomial program with the spectral gap program.

---

## Direction 3: Concavity Depth and Modified Log-Sobolev Inequalities

**Conjecture**: k-fold log-concavity implies a modified log-Sobolev inequality (MLSI) with constant O(n^{2/k}), yielding exponentially fast convergence in relative entropy (not just total variation).

**The key insight is** that the MLSI is strictly stronger than the Poincaré inequality: it controls convergence in KL divergence rather than L² distance. If concavity depth improves the MLSI constant, it would provide exponential concentration inequalities for k-fold log-concave distributions — a qualitative leap beyond our current mixing time bounds.

**Why now?** The relationship between log-concavity and MLSI has been studied by Bobkov-Ledoux [1997] and Diaconis-Saloff-Coste [1996] for the k=1 case. Our tower-of-log-concavity theorem (KLC.iterRat_lc) provides the structural ingredient needed for the k>1 extension.

**Test**: For discrete Gaussian families, compute the MLSI constant numerically and test the n^{2/k} scaling. Formalize the MLSI definition in Lean and state the conjectured bound.

**Impact**: Would provide exponential concentration inequalities and optimal convergence rates for MCMC algorithms targeting k-fold log-concave distributions.

**Catalog References**: `Pythagorean/MixingTimeConcavityDepth.lean` (dirichletFormNN, varianceDist, poincare_to_mixing).

**Proof Strategy**: Use the Herbst argument: MLSI → concentration via exponential moments. Prove MLSI from KLC by bounding the entropy production at each ratio level.

**Domain Bridges**: Probability ↔ Information Theory (entropy, KL divergence), Probability ↔ Statistical Mechanics (Gibbs measures, phase transitions).

**Lineage**: Extends poincare_to_mixing and variance_le_dirichlet_of_KLC.

**Ambition**: Solid extension with high potential impact.

---

## Direction 4: Metastability Bounds from Concavity Depth Gaps

**Conjecture**: If a distribution is k₁-fold log-concave but NOT k₂-fold log-concave (with k₂ > k₁), the gap k₂ - k₁ quantifies the degree of "metastability" — the presence of shallow traps in the energy landscape that slow mixing by a factor of n^{2/k₁ - 2/k₂}.

**The key insight is** that the concavity depth profile ConcavityDepthProfile(a) acts as a signature of the energy landscape's complexity. Distributions where the profile saturates at low k have subtle irregularities at fine scales, corresponding to metastable states that trap the random walk. The depth at which log-concavity breaks characterizes the scale of the deepest traps.

**Why now?** Metastability is a central concept in statistical physics and materials science, but existing mathematical tools (potential theory, capacity bounds) are cumbersome and dimension-specific. Concavity depth provides a purely combinatorial handle on metastability that could be computed efficiently and applied broadly.

**Test**: Construct families of distributions with tunable concavity depth profiles (e.g., by adding controlled perturbations at specific scales). Measure the spectral gap and verify that the depth gap predicts the mixing time.

**Impact**: Would provide a new diagnostic tool for metastability in computational physics and optimization, replacing ad hoc energy landscape analysis with a systematic invariant.

**Catalog References**: `Pythagorean/MixingTimeConcavityDepth.lean` (ConcavityDepthProfile, MultiscaleDiscreteConvex, KLC_implies_multiscaleConvex).

**Proof Strategy**: Show that failure of KLC at depth k₂ implies the existence of a "bottleneck" at scale n^{1/k₂}. Bound the conductance through this bottleneck using the (broken) ratio sequence.

**Domain Bridges**: Probability ↔ Statistical Physics (metastability, Arrhenius law), Probability ↔ Optimization (simulated annealing convergence).

**Lineage**: Extends KLC_implies_multiscaleConvex and exponent_hierarchy_strict.

**Ambition**: Grand challenge. Paradigm-shifting if successful — concavity depth as a complexity measure for energy landscapes.

---

## Direction 5: Algorithmic Implications — Concavity-Certified Sampling

**Conjecture**: Given a polynomial-time oracle for verifying k-fold log-concavity of a distribution (which our VERIFY-KLC algorithm provides), one can construct a sampling algorithm with running time O(n^{2/k} · poly(log n)) — exponentially faster than general-purpose MCMC for high-depth distributions.

**The key insight is** that the concavity depth certificate is not just a passive property to be verified — it can be actively exploited by the sampling algorithm. At each step, the algorithm can use the ratio tower to choose transition probabilities that align with the local geometry of the distribution, avoiding the "random walk" behavior that slows general chains.

**Why now?** The success of structure-exploiting algorithms in continuous optimization (interior point methods, natural gradient) suggests that analogous exploitation of concavity structure should be possible in discrete sampling. Our ratio tower provides exactly the structural information needed.

**Test**: Implement a "concavity-aware" birth-death chain that uses the ratio tower to set transition probabilities adaptively. Compare mixing time with the standard Metropolis chain on k-fold log-concave distributions for k = 2, 3, 4.

**Impact**: Would establish a new paradigm for sampling algorithm design: instead of treating the distribution as a black box, exploit its concavity depth as a structural resource for acceleration.

**Catalog References**: `Catalog/Pythagorean/CertificateSampling.lean` (certificate_sampling_efficiency, certificate_verification_complexity), `Pythagorean/MixingTimeConcavityDepth.lean` (mixingTime_bound_of_KLC).

**Proof Strategy**: Design a non-reversible chain that uses the ratio tower to bias transitions toward high-conductance edges. Prove mixing via a coupling argument that exploits the tower structure.

**Domain Bridges**: Probability ↔ Algorithms (sampling complexity), Probability ↔ Machine Learning (MCMC for Bayesian inference).

**Lineage**: Extends certificate_sampling_efficiency and the concavity-to-mixing pipeline.

**Ambition**: Solid extension with immediate practical applications.
