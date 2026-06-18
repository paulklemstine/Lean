# Future Directions: Information-Theoretic Monotonicity for Lorentzian Measures

## Synthesis

The results established in this cycle reveal that robust Lorentzian negativity imposes a rich information geometry on finite subset distributions. The susceptibility bound, MI ≤ χ² inequality, and Fisher information bridge create a formal dictionary between discrete curvature, information theory, and statistical mechanics. The key open frontier is extending this pairwise theory to many-coordinate inequalities (Shearer-type bounds), sharpening the MI bounds from polynomial to logarithmic in ε, and developing polynomial-time algorithms that exploit the matroid/Lorentzian structure. Each direction below builds directly on the proved theorems and targets a specific gap between the current results and the ultimate vision of a complete discrete Hodge-information theory.

---

## Direction 1: Shearer Inequality with Lorentzian Error Term

**Conjecture:** For every robustly Lorentzian law μ with gap ε, and every covering family A₁,...,Aₘ of [n] with each coordinate covered at least r times:

$$H(\mu) \leq \frac{1}{r} \sum_{t=1}^{m} H(\pi_{A_t} \mu) + \Psi(\varepsilon)$$

where Ψ(ε) = O(n² · ε / r) depends only on the gap and the covering multiplicity.

**Test:** Compute both sides for uniform matroid distributions U(k,n) with k = n/2, using coverings by (n-1)-element subsets (each coordinate covered n-1 times). If the inequality holds with Ψ = c · n · ε for a moderate constant c, the conjecture is validated. If Ψ must grow faster than linearly in n, the conjecture needs revision.

**Impact:** This would be the first entropy submodularity theorem with error controlled by a geometric parameter. It would unlock applications in distributed computing (secret sharing), coding theory (source coding bounds), and privacy (composition of deletion mechanisms).

**Catalog References:** `Catalog/Pythagorean/InfoTheoreticMonotonicity.lean` — `susceptibility_le_of_robust`, `offDiag_cov_sum_nonpos`

**Proof Strategy:** Use the entropy chain rule H(X) = Σ H(Xᵢ | X_{<i}) and bound each conditional entropy using the MI bounds from the current paper. The key step is showing that conditioning on a subset of coordinates doesn't increase the Lorentzian gap by more than a controlled amount. This requires a "conditional robustness" lemma that is not yet proved. The key insight is that the off-diagonal covariance sum being nonpositive (Theorem 7) means the entropy chain rule terms are individually bounded.

**Domain Bridges:** Information theory (Shearer's lemma), distributed computing (secret sharing), coding theory (rate-distortion)

**Lineage:** Extends `susceptibility_le_of_robust` and `offDiag_cov_sum_nonpos` from pairwise to many-coordinate bounds

**Ambition:** Grand challenge — would establish a new class of entropy inequalities parameterized by geometric data

---

## Direction 2: Logarithmic Mutual Information Bound

**Conjecture:** For robustly Lorentzian laws with gap ε:

$$I(X_i; X_j) \leq C \cdot \log\left(1 + \frac{1}{\varepsilon}\right)$$

for all i ≠ j, where C is a universal constant.

**Test:** Compute exact MI for families of distributions parameterized by ε (e.g., weighted matroid distributions or DPP-like laws). Fit MI vs ε to both ε² (current bound) and log(1+1/ε). If the logarithmic fit is consistently better with residuals → 0, the conjecture is supported. A counterexample family where MI ~ ε^α with α < 2 would also be informative.

**Impact:** A logarithmic MI bound would be asymptotically much tighter than the ε² bound from KL ≤ χ². It would give optimal scaling for the information contraction coefficient and directly improve the privacy amplification guarantees.

**Catalog References:** `Catalog/Pythagorean/InfoTheoreticMonotonicity.lean` — `mutualInfoPair_cov_bound`, `kl_le_chi_sq_four`

**Proof Strategy:** Replace the KL ≤ χ² route with a direct bound on the KL divergence using Taylor expansion of the entropy function around the product measure. The key insight is that for small covariance c, the MI has expansion I ≈ c²/(2·Var₁·Var₂) + O(c⁴), and the Lorentzian gap gives |c| ≤ ε·p·q. This suggests I = O(ε²), not O(log(1/ε)), so the conjecture may be false as stated. A revised conjecture might be I ≤ C·ε²·p²·q²/(p(1-p)·q(1-q)), which is what we already proved.

**Domain Bridges:** Information theory (channel capacity), privacy (differential privacy amplification), learning theory (sample complexity)

**Lineage:** Refines `mutualInfoPair_cov_bound` with tighter analytic tools

**Ambition:** Solid extension — refines existing bounds with sharper analysis

---

## Direction 3: Entropy Retention Under Multi-Coordinate Deletion

**Conjecture:** For robustly Lorentzian μ with gap ε, deleting any set A of coordinates with |A| = k:

$$H(\pi_{[n] \setminus A} \mu) \geq H(\mu) - k \cdot \left(\log(1/\varepsilon) + C\right)$$

where C is a universal constant.

**Test:** For U(⌊n/2⌋, n), compute H(μ) and H(π_{[n]\setminus A} μ) for random k-element sets A with k = 1, 2, ..., n/2. Check whether the entropy drop is bounded by k · log(1/ε) + O(1). If the drop grows faster than linearly in k, the conjecture fails.

**Impact:** Multi-coordinate deletion bounds would be the foundation for privacy amplification theorems in the subsampling model. They would also connect to the data processing inequality for multiple rounds of processing.

**Catalog References:** `Catalog/Pythagorean/InfoTheoreticMonotonicity.lean` — `fisher_information_style_bound`, `susceptibility_le_eps_n_sq`; `Catalog/Bridges/Catalog/Pythagorean/RobustLorentzianSampling.lean` — `robust_quadform_negativity`

**Proof Strategy:** Use induction on k, applying the single-deletion bound at each step. The key insight is that if μ is robustly Lorentzian with gap ε, then the deletion π_k μ should also be robustly Lorentzian with a controlled gap. This "hereditary robustness" property is the main technical challenge. The iterated perturbation stability theorem from `RobustLorentzianSampling.lean` provides the template.

**Domain Bridges:** Differential privacy (subsampling amplification), data compression (rate-distortion with side information), Markov chain mixing (telescoping)

**Lineage:** Extends the single-deletion case using `iterated_perturbation_gap` as template

**Ambition:** Solid extension — combines existing tools in a new way

---

## Direction 4: Continuous Log-Concave Extension via Bakry-Émery Theory

**Conjecture:** For a continuous strongly log-concave distribution on ℝⁿ with Hessian gap λ > 0 (i.e., −∇² log ρ ≽ λI on the orthogonal complement of a 1D subspace), the mutual information between any two coordinates satisfies:

$$I(X_i; X_j) \leq C/\lambda$$

**Test:** Compute exact MI for multivariate Gaussian distributions with prescribed covariance structure matching the Lorentzian signature condition. Compare against the bound C/λ for various λ.

**Impact:** This would extend the discrete theory to continuous distributions, connecting Lorentzian polynomials to the Bakry-Émery theory of curvature-dimension conditions. It would provide a unified framework for negative dependence in both discrete and continuous settings.

**Catalog References:** `Catalog/Pythagorean/InfoTheoreticMonotonicity.lean` — `RobustlyLorentzian` structure; `Catalog/Bridges/Catalog/Pythagorean/RobustLorentzianSampling.lean` — `HasGappedSignature`

**Proof Strategy:** The key insight is that the discrete `HasGappedSignature` condition is the finite-dimensional analog of the Bakry-Émery curvature condition Ric ≥ λ. In the continuous setting, the MI bound should follow from the Brascamp-Lieb inequality applied to the conditional distribution. The main challenge is formalizing the connection between the Hessian gap and the Bakry-Émery constant.

**Domain Bridges:** Differential geometry (Bakry-Émery theory), optimal transport (displacement convexity), machine learning (sampling from log-concave distributions)

**Lineage:** Lifts the entire discrete framework to the continuous setting

**Ambition:** Grand challenge — would unify discrete and continuous negative dependence theory

---

## Direction 5: Polynomial-Time Information Profile via Matroid Structure

**Conjecture:** For distributions supported on bases of a matroid of rank r on [n], the information profile (marginals, pairwise covariances, MI estimates) can be computed in O(n² · poly(r)) time, without enumerating all 2ⁿ subsets.

**Test:** Implement the algorithm for graphic matroids and compare running times against the naive O(2ⁿ · n²) algorithm. For n = 20, r = 10, the naive algorithm is infeasible (~10⁶ subsets × 400 pairs = 4 · 10⁸ operations), while a polynomial algorithm should terminate in seconds.

**Impact:** Polynomial-time computation would make the information-theoretic audit practical for real-world combinatorial distributions, enabling certified sampling quality diagnostics, privacy audits, and statistical mechanics simulations.

**Catalog References:** `Catalog/Pythagorean/InfoTheoreticMonotonicity.lean` — `audit_robust_lorentzian_info_profile`; `Catalog/Bridges/Catalog/Pythagorean/RobustLorentzianSampling.lean` — `spectral_gap_stability`

**Proof Strategy:** The key insight is that for matroid distributions, the marginals pᵢ = P(i ∈ B) can be computed via the matroid polytope, and the pairwise joint probabilities P(i,j ∈ B) are related to contractions and deletions of the matroid. Both can be computed by O(n) matroid operations, each taking poly(n) time for representable matroids. The overall algorithm would compute the rank function oracle, then iterate over O(n²) pairs.

**Domain Bridges:** Combinatorial optimization (matroid intersection), algorithmic game theory (mechanism design), machine learning (DPP sampling)

**Lineage:** Makes the computational deliverables from the current cycle scalable

**Ambition:** Solid extension — algorithmic rather than theoretical, but practically transformative

Why now? The formal infrastructure from this cycle provides the mathematical foundation. The proved bounds tell us *what* to compute; the algorithmic direction tells us *how* to compute it efficiently.
