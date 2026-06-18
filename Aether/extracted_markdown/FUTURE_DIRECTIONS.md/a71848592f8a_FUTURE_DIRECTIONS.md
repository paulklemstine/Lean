# Future Directions: Ultra-Log-Concavity and Beyond

## Synthesis

The ultra-log-concavity program establishes a formalized bridge between elementary symmetric polynomials, convex geometry (Alexandrov–Fenchel), statistical mechanics (fermionic systems), and information theory (entropy bounds). Our verified results provide a certified foundation: ESP recurrence, positivity, the AM-GM base case, and log-concavity preservation. The central open challenge — completing the formal proof of Newton's inequality — is connected to all five directions below. Each direction extends the verified core in a different domain, and together they form a coherent program to understand the algebraic, geometric, and information-theoretic manifestations of ultra-log-concavity.

---

## Direction 1: Completing Newton's Inequality via Lorentzian Polynomials

**Conjecture:** The full Newton inequality $\tilde{e}_k^2 \geq \tilde{e}_{k-1} \cdot \tilde{e}_{k+1}$ can be formally verified by showing that $\prod(1 + w_i X)$ is a Lorentzian polynomial (in the sense of Brändén–Huh) and applying the general ULC theorem for Lorentzian polynomials.

**Test:** Formalize the definition of Lorentzian polynomials (homogeneous polynomials with M-convex support and log-concave coefficients on every restriction). Verify that the homogenization of $\prod(1 + w_i X)$ satisfies these conditions. Check: for $m = 10$ random weight vectors, verify that the Hessian condition of Lorentzian polynomials holds numerically.

**Impact:** Would provide the first fully formalized proof of Newton's inequality and establish the Lorentzian polynomial framework in a proof assistant.

**Catalog References:** `Pythagorean/UltraLogConcave.lean` (ESP properties), `Pythagorean/UltraLogConcaveDefs.lean` (definitions)

**Proof Strategy:** Define `IsLorentzian` for multivariate polynomials. Prove that products of nonneg linear forms are Lorentzian. Then prove the general ULC theorem: Lorentzian ⟹ ULC for coefficient sequences.

**Domain Bridges:** Algebraic geometry (Hodge index theorem) ↔ Combinatorics (matroid theory)

**Lineage:** Extends `ultra_log_concavity` (currently sorry) and `ulc_two_weights` (proved)

**Ambition:** Grand challenge — would be the first machine-verified proof of Newton's inequality via Lorentzian polynomials

---

## Direction 2: Quantitative ULC Margin Bounds (Corrected Tropical Conjecture)

**Conjecture:** For positive weights $w_1 \geq \cdots \geq w_m > 0$, the ULC margin satisfies:

$$\text{margin}_k \geq \frac{(w_{\max} - w_{\min})^2}{8m^2 \cdot w_{\max} \cdot w_{\min}} \cdot \frac{k(m-k)}{m-1}$$

(Note: the factor is $1/8$ instead of $1/4$ in the original conjecture, based on computational evidence showing the $1/4$ version has rare violations for extreme heterogeneity.)

**Test:** Generate $10^6$ random weight vectors with $m \in \{3, \ldots, 25\}$, $w_i \in [0.01, 100]$. Compute the ratio LHS/RHS for all valid $k$. The conjecture is falsified if any ratio < 1. If it holds, fit the optimal constant $c$ in $\text{margin}_k \geq c \cdot (w_{\max} - w_{\min})^2 / (m^2 w_{\max} w_{\min}) \cdot k(m-k)/(m-1)$.

**Impact:** Would give the first explicit, computable lower bound on the ULC gap, with applications to robustness certification in machine learning.

**Catalog References:** `Pythagorean/UltraLogConcaveDefs.lean` (ulcMargin, minUlcMargin)

**Proof Strategy:** Start with the case $m = 3, k = 1$ where the bound reduces to an explicit AM-GM-type inequality. Extend by induction using the ESP recurrence.

**Domain Bridges:** Tropical geometry (margin bounds) ↔ Machine learning (adversarial robustness)

**Lineage:** Builds on `ulcMargin` and `tropicalUlcMarginConj` from `Pythagorean/UltraLogConcave.lean`

**Ambition:** Solid extension — quantitative refinement of a classical inequality

---

## Direction 3: Shepp–Olkin Entropy Maximization

**Conjecture:** Among all ultra-log-concave distributions on $\{0, \ldots, m\}$ with given mean $\mu$, the binomial distribution $\text{Bin}(m, \mu/m)$ maximizes Shannon entropy.

**Test:** For $m = 8$ and $\mu = 4$:
1. Generate 10,000 random ULC distributions (from positive weight vectors with mean approximately $\mu$)
2. Compute Shannon entropy for each
3. Compare with $H(\text{Bin}(8, 0.5))$
4. The conjecture is falsified if any ULC distribution has strictly higher entropy

**Impact:** Establishes the binomial as the "least informative" ULC distribution, analogous to how the Gaussian maximizes entropy under variance constraints. This would connect combinatorics to information theory in a new way.

**Catalog References:** `Pythagorean/UltraLogConcaveDefs.lean` (UltraLogConcaveSeq), `applications.py` (entropy computation)

**Proof Strategy:** Use the method of Lagrange multipliers on the entropy functional subject to the ULC constraints and the mean constraint. Show that the KKT conditions are satisfied by the binomial distribution.

**Domain Bridges:** Information theory ↔ Combinatorics

**Lineage:** New direction building on the UltraLogConcaveSeq structure

**Ambition:** Grand challenge — would establish a deep information-theoretic characterization of ULC

---

## Direction 4: Alexandrov–Fenchel for Zonoids via ULC

**Conjecture:** The combinatorial proof of ULC for line segments (products of linear factors) can be extended to *zonoids* (limits of Minkowski sums of line segments), providing a new, purely combinatorial proof of the Alexandrov–Fenchel inequality for this class of convex bodies.

**Test:**
1. Approximate a given convex body $K$ by a Minkowski sum of $N$ line segments (a zonotope)
2. Verify ULC for the corresponding weight vector
3. Check that as $N \to \infty$, the ULC margins converge to the AF mixed-volume inequality for $K$
4. Test with: (a) ellipsoids, (b) simplices, (c) cross-polytopes

**Impact:** Would extend the combinatorial proof paradigm from finite sums to continuous limits, potentially opening a new approach to the full AF inequality.

**Catalog References:** `Pythagorean/UltraLogConcave.lean` (alexandrov_fenchel_implies_ulc)

**Proof Strategy:** Establish that the ULC functional is continuous under Hausdorff limits of zonotopes. Use the density of zonotopes in the space of centrally symmetric convex bodies.

**Domain Bridges:** Convex geometry ↔ Combinatorics ↔ Functional analysis

**Lineage:** Extends `alexandrov_fenchel_implies_ulc` to the continuous setting

**Ambition:** Grand challenge — paradigm-shifting if successful

---

## Direction 5: Wasserstein Stability of Near-ULC-Equality

**Conjecture:** If the minimum ULC margin is at most $\epsilon$, then the weights are $O(\sqrt{\epsilon})$-close to a uniform vector in Wasserstein-1 distance:

$$W_1\left(\frac{1}{m}\sum_i \delta_{w_i},\ \delta_{\bar{w}}\right) \leq C(m) \cdot \sqrt{\epsilon}$$

where $\bar{w} = \frac{1}{m}\sum_i w_i$ and $C(m)$ depends only on $m$.

**Test:** For $m = 5, 10, 20$:
1. Sample 100,000 weight vectors with controlled ULC margin $\epsilon$
2. Compute $W_1$ distance to the uniform distribution at the mean
3. Fit the empirical relationship between $W_1$ and $\epsilon$
4. Check if the $\sqrt{\epsilon}$ scaling holds

**Impact:** Establishes quantitative stability for Newton's inequality — a "robust inverse theorem."

**Catalog References:** `Pythagorean/UltraLogConcave.lean` (ulc_uniform, ulcMargin)

**Proof Strategy:** Taylor expand the ULC functional around uniform weights. The Hessian of $F(w) = \tilde{e}_k^2 - \tilde{e}_{k-1}\tilde{e}_{k+1}$ at $w = (c, \ldots, c)$ is positive semi-definite with kernel spanned by $(1, \ldots, 1)$. Use this to establish the quadratic relationship.

**Domain Bridges:** Optimal transport ↔ Symmetric function theory

**Lineage:** Extends `ulc_uniform` (equality characterization) to a quantitative setting

**Ambition:** Solid extension — connects classical inequalities to modern stability theory
