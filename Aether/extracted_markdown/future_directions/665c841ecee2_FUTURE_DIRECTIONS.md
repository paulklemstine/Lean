# Future Directions: Information-Theoretic Monotonicity for Lorentzian Measures

## Synthesis

The results in this cycle establish the first formal bridge between Lorentzian polynomial negativity and information theory. The key achievement is the pipeline: Lorentzian gap → covariance bound → chi-squared bound → mutual information bound → susceptibility bound. This pipeline creates a new dictionary between discrete geometry and information quantities. The five directions below extend this dictionary along complementary axes: deeper analytic bounds (Direction 1), multi-coordinate structural theorems (Direction 2), algorithmic applications (Direction 3), cross-domain connections to physics (Direction 4), and a grand challenge unifying the entire framework (Direction 5). Together, they chart a program for "discrete Hodge-information theory" — the systematic study of how algebraic curvature controls information flow in combinatorial probability spaces.

---

## Direction 1: Tight Mutual Information Bounds via Second-Order Expansion

**Conjecture:** For robustly Lorentzian $\mu$ with gap $\varepsilon$ and marginals bounded away from 0 and 1 by $\delta > 0$, the pairwise mutual information satisfies
$$I(X_i; X_j) \le \frac{\varepsilon^2}{2\delta^2(1-\delta)^2} + O(\varepsilon^3)$$
and this bound is asymptotically tight for a family of perturbed uniform matroids.

**Test:** Compute exact MI and the predicted bound for $U(n, \lfloor n/2 \rfloor)$ with $n = 4, \ldots, 12$ and perturbation strengths $0.01, 0.1, 1.0$. If the ratio MI/bound converges to a constant in $(0.4, 0.6)$ as $n \to \infty$, the bound captures the correct scaling but with a factor-2 slack from the KL ≤ χ² inequality.

**Impact:** Tighter MI bounds would strengthen all downstream applications: communication complexity bounds, privacy guarantees, and anti-clustering limits. A factor-2 improvement is significant in cryptographic applications.

**Catalog References:** `Catalog/Pythagorean/InfoTheoreticMonotonicity.lean` (Theorem `mutualInfoPair_cov_bound`, Theorem `kl_le_chi_sq_four`)

**Proof Strategy:** Replace the crude bound $\log x \le x - 1$ with the tighter $\log x \le x - 1 - (x-1)^2/(2x)$ for $x > 0$ (second-order Taylor remainder for log). This would give $D_{KL} \le \chi^2/2$ instead of $D_{KL} \le \chi^2$, tightening the MI bound by a factor of 2.

**Domain Bridges:** Information theory (tighter MI bounds → better source coding), Cryptography (privacy amplification constants)

**Lineage:** Direct refinement of `kl_le_chi_sq_four` and `mutualInfoPair_cov_bound`

**Ambition:** Solid extension — well within reach, high impact on applications

The key insight is that the factor-2 gap between KL and chi-squared divergence is not inherent to the problem but an artifact of using the linearization $\log x \le x - 1$ rather than the quadratic approximation. A tighter analytic inequality would propagate through the entire pipeline.

Why now? The Lean formalization already contains the complete pipeline; replacing one analytic inequality is a surgical upgrade that leverages all existing infrastructure.

---

## Direction 2: Shearer-Type Entropy Inequality Under Lorentzian Negativity

**Conjecture:** For a robustly Lorentzian $\mu$ with gap $\varepsilon$ on $n$ coordinates, and any family $A_1, \ldots, A_m \subseteq [n]$ of coordinate subsets covering each coordinate at least $r$ times:
$$H(\mu) \le \frac{1}{r} \sum_{t=1}^m H(\pi_{A_t} \mu) + C \cdot \varepsilon \cdot n$$
where $C$ is a universal constant and $\pi_{A_t}$ denotes projection to coordinates in $A_t$.

**Test:** For $U(8, 4)$ with the covering $A_t = [8] \setminus \{t\}$ (each coordinate covered $n-1$ times), compute both sides. The correction term $C \cdot \varepsilon \cdot n$ should be small relative to $H(\mu)$ for small $\varepsilon$.

**Impact:** This would upgrade pairwise information bounds into a many-coordinate structural theorem, enabling entropy compression bounds and distributed sampling certificates.

**Catalog References:** `Catalog/Pythagorean/InfoTheoreticMonotonicity.lean` (Theorem `susceptibility_le_of_robust`, Definition `RobustlyLorentzian`)

**Proof Strategy:** Start from the classical Shearer lemma (entropy submodularity): $H(\mu) \le \frac{1}{r} \sum H(\pi_{A_t} \mu)$ holds with equality for product distributions. For negatively dependent distributions, the defect is controlled by pairwise MI terms. Use `susceptibility_le_of_robust` to bound the total MI defect by $\varepsilon \cdot (\sum p_i)^2 \le \varepsilon \cdot n^2$, giving the error term.

**Domain Bridges:** Combinatorics (Shearer's lemma), Coding theory (distributed source coding), Privacy (composition theorems)

**Lineage:** Extends `susceptibility_le_of_robust` from pairwise to multi-coordinate

**Ambition:** Grand challenge — requires new entropy submodularity infrastructure in Lean

The key insight is that Shearer's lemma is exact for product distributions, and robust Lorentzianity quantifies how far a distribution is from being a product. The susceptibility bound provides the bridge.

Why now? The susceptibility bound is already formalized and provides the quantitative control needed. The main gap is formalizing the classical Shearer lemma in the FinsetLaw framework.

---

## Direction 3: Certified MCMC Diagnostics via Information Profiles

**Conjecture:** For a robustly Lorentzian target distribution $\mu$ with gap $\varepsilon$, a Markov chain with spectral gap $\gamma$ satisfies, after $t$ steps from any initial state:
$$D_{KL}(\mu_t \| \mu) \le \frac{n}{\varepsilon} \cdot e^{-\gamma t}$$
where $\mu_t$ is the distribution at time $t$.

**Test:** Implement the basis-exchange Markov chain for $U(8, 4)$, run 1000 steps from a worst-case initial state, and compare the empirical KL divergence against the predicted bound for $t = 10, 50, 100, 500$.

**Impact:** This would provide the first certified MCMC convergence diagnostics using information-theoretic quantities derived from Lorentzian geometry, applicable to matroid sampling, determinantal point processes, and log-concave optimization.

**Catalog References:** `Catalog/Bridges/Catalog/Pythagorean/RobustLorentzianSampling.lean` (Theorem `spectral_gap_stability`, `mixing_time_bound_pos`)

**Proof Strategy:** Combine the spectral gap lower bound from `spectral_gap_stability` with the Pinsker/chi-squared chain: spectral gap → $L^2$ convergence → chi-squared convergence → KL convergence. The factor $n/\varepsilon$ comes from the initial condition bound using the susceptibility.

**Domain Bridges:** Machine learning (MCMC diagnostics), Bayesian inference (convergence certificates), Statistical physics (relaxation times)

**Lineage:** Combines catalog's mixing-time bounds with new information-theoretic framework

**Ambition:** Solid extension with high practical impact

The key insight is that information-theoretic convergence is fundamentally different from total-variation convergence: it measures how much the sampler "knows" about the initial state, not just how close the distributions are. Lorentzian structure controls both.

Why now? The spectral gap stability theorems are already in the catalog, and the information-theoretic framework from this cycle provides the missing link to KL convergence.

---

## Direction 4: Lorentzian Curvature as a Phase Transition Barrier

**Conjecture:** For a family of repulsive lattice spin systems parameterized by inverse temperature $\beta$, if the Gibbs measure at temperature $\beta$ is robustly Lorentzian with gap $\varepsilon(\beta) > c/\beta$ for some constant $c > 0$, then the system has no phase transition (unique Gibbs measure) for all $\beta$.

**Test:** Compute $\varepsilon(\beta)$ for the hard-core lattice gas on $\mathbb{Z}^2$ truncated to an $n \times n$ grid, for $n = 4, 6, 8$ and $\beta = 0.1, 0.5, 1.0, 2.0, 5.0$. If $\varepsilon(\beta) \cdot \beta$ remains bounded below by a positive constant in the subcritical regime but collapses near the critical activity, this supports the conjecture.

**Impact:** This would establish Lorentzian geometry as a tool for understanding phase transitions, connecting the algebraic theory of generating polynomials to one of the central problems in mathematical physics.

**Catalog References:** `Catalog/Bridges/Catalog/Pythagorean/RobustLorentzianSampling.lean` (Theorem `gibbs_weight_ratio_bound`), `Catalog/Pythagorean/InfoTheoreticMonotonicity.lean` (Theorem `susceptibility_le_of_robust`)

**Proof Strategy:** The susceptibility bound $\chi \le \varepsilon \cdot (\sum p_i)^2$ combined with the Lee-Yang theorem (zeros of the partition function lie on the unit circle) should give $\varepsilon(\beta) \ge c/\beta$ in the absence of phase transitions. Conversely, at a phase transition, the susceptibility diverges, forcing $\varepsilon \to 0$. The Gibbs perturbation stability theorem (`gibbs_weight_ratio_bound`) provides the connection between energy perturbations and coefficient perturbations.

**Domain Bridges:** Statistical mechanics (phase transitions, Gibbs measures), Mathematical physics (Lee-Yang theory), Probability (Dobrushin uniqueness)

**Lineage:** Extends `gibbs_weight_ratio_bound` from perturbation bounds to phase transition analysis

**Ambition:** Grand challenge — paradigm-shifting if true

The key insight is that the Lorentzian gap $\varepsilon$ is a proxy for the "distance to criticality" in the statistical mechanics sense. When $\varepsilon > 0$, the system is in a single phase; when $\varepsilon \to 0$, correlations diverge and phase transitions become possible.

Why now? The susceptibility bound is formalized, the Gibbs bridge theorem is in the catalog, and recent advances in the Lee-Yang program provide the analytic tools needed on the physics side.

---

## Direction 5: A Unified Discrete Hodge-Information Theory

**Conjecture:** There exists a functorial construction that assigns to every Lorentzian polynomial $f$ of degree $d$ in $n$ variables a "Hodge-information complex" — a chain complex of information spaces whose cohomology groups are isomorphic to the tropical cohomology of the support of $f$, and whose Laplacian eigenvalues equal the information divergences between coordinate projections.

**Test:** For the elementary symmetric polynomial $e_k(x_1, \ldots, x_n)$ (generating polynomial of $U(n,k)$), compute the proposed Laplacian eigenvalues and compare them to the pairwise MI values. If they match up to a universal rescaling, the functorial construction exists at least for this family.

**Impact:** This would create an entirely new field — "discrete Hodge-information theory" — where algebraic negativity (Lorentzian signature) directly computes information-theoretic quantities (entropy, MI, channel capacity) via a geometric intermediary (Hodge Laplacian). It would unify Brändén-Huh theory, Shannon theory, and Hodge theory into a single framework.

**Catalog References:** All theorems in `Catalog/Pythagorean/InfoTheoreticMonotonicity.lean`, `Catalog/Bridges/Catalog/Pythagorean/RobustLorentzianSampling.lean`

**Proof Strategy:** Step 1: Define the information complex. For each subset $A \subseteq [n]$, the "information space" is the space of FinsetLaws projected to coordinates in $A$. The boundary maps are deletion pushforwards. Step 2: Show that the Hodge Laplacian (sum of boundary and coboundary) has eigenvalues controlled by pairwise MI terms. Step 3: Use the tropical geometry of the Newton polytope to relate the Hodge numbers to the combinatorial structure of the support.

**Domain Bridges:** Algebraic geometry (Hodge theory), Tropical geometry (Newton polytopes), Information theory (channel capacity), Category theory (functorial constructions)

**Lineage:** The culmination of all five directions — requires results from Directions 1-4

**Ambition:** Grand challenge — paradigm-shifting, possibly decade-scale

The key insight is that the MI bounds proved in this cycle are not isolated inequalities but shadows of a deeper structural relationship between Lorentzian signature and information flow. The Hodge complex would make this relationship explicit and functorial.

Why now? The formal verification of the KL ≤ χ² inequality and the susceptibility bound provides the first computational evidence for the Hodge-information correspondence. The tropical geometry tools developed in other parts of the catalog (TropicalBridge, TropicalMorse) provide the geometric infrastructure.
