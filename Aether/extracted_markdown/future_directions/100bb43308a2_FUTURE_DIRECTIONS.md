# Future Directions: Depth-Sensitive Exchange Descent

## Synthesis

The depth-sensitive exchange descent theory established in this work opens a *new axis* for discrete optimization complexity, where certificate depth plays the role of a regularity parameter analogous to curvature in continuous optimization. The directions below explore the natural frontiers of this theory: deriving depth certificates from first principles (Direction 1), extending to richer combinatorial structures (Direction 2), connecting to tropical geometry (Direction 3), building adaptive algorithms (Direction 4), and pursuing the ultimate goal of a sharp exponent classification (Direction 5).

These directions form a coherent program: Directions 1 and 3 deepen the *theoretical foundations*, Direction 2 extends the *scope* to new combinatorial structures, Direction 4 turns theory into *practice*, and Direction 5 aims for the *optimal* characterization. Together, they would establish certificate depth as a first-class complexity parameter across discrete mathematics.

---

## Direction 1: Deriving Depth Decrements from Log-Concavity (Grand Challenge)

**Conjecture:** For a separable objective $f(x) = \sum_{i=1}^d w_i(x_i)$ on a simplex exchange family, if each $w_i$ is $k$-fold log-concave with ratio bound $\rho$, then every improving exchange step decreases the canonical potential by at least $\delta_k \geq c(\rho) / d^{d-k}$, where $c(\rho) > 0$ depends only on the ratio bound.

**Test:** Formalize the statement in Lean 4. Prove it for $k = 1$ (ordinary log-concavity) using the ratio monotonicity theorem (`logConcave_ratio_nonincreasing` from `Pythagorean/DepthSensitiveExchangeDescent.lean`). For $k > 1$, compute $\delta_k$ empirically on simplex families with binomial weights and verify the predicted scaling.

**Impact:** This would close the gap between the *assumed* decrement (current formalization) and a *derived* one, making the full pipeline — from analytic structure to runtime bound — purely deductive. It would be the first result connecting higher-order log-concavity quantitatively to algorithmic complexity.

**Catalog References:** `Pythagorean/DepthSensitiveExchangeDescent.lean` (depth decrement definition, log-concave ratio theorem), `Catalog/Pythagorean/HigherOrderLogConcavity.lean` (iterated ratio sequences, `KFoldLogConcave.iterRatio_kfold`).

**Proof Strategy:** Use iterated ratio monotonicity to bound the per-coordinate improvement from an exchange step. The $k$-th iterated ratio of a $k$-fold log-concave sequence is monotone, which provides a quantitative gap between the "donor" and "receiver" coordinates in an exchange. Sum these gaps to bound the total potential decrease.

**Domain Bridges:** Analytic combinatorics (log-concavity hierarchy) → Discrete optimization (exchange descent complexity).

**Lineage:** Extends `logConcave_ratio_nonincreasing` and `kFoldLogConcave_induces_depthCertificate`.

**Ambition:** Grand challenge — would require new quantitative transfer theorems between analytic and combinatorial structures.

**The key insight is** that the iterated ratio sequences of $k$-fold log-concave weights provide a *quantitative* exchange improvement, not merely an existential one, and this quantitative gap scales precisely as $d^{-(d-k)}$.

**Why now?** The formalized ratio monotonicity theorem and the depth certificate bridge in this work provide the exact formal infrastructure needed to attempt this derivation.

---

## Direction 2: Extension to Valuated Matroid Exchange

**Conjecture:** The depth-sensitive descent theory extends to valuated matroid bases, where the depth parameter relates to the degree of the associated tropical Plücker vector. Specifically, for a valuated matroid of rank $r$ on $n$ elements with tropical Plücker degree $\leq k$, exchange descent on the valuation function terminates in $O(n^{r-k} \cdot D)$ steps.

**Test:** Formalize the valuated matroid exchange axiom in Lean 4, define tropical Plücker degree, and prove the descent bound for the case $k = r$ (uniform valuations). Test computationally on random valuated matroids of rank 3–6 on 6–12 elements.

**Impact:** Would connect the depth-sensitive theory to one of the most active areas of algebraic combinatorics, opening applications to combinatorial auction theory, network optimization, and tropical geometry.

**Catalog References:** `Catalog/Pythagorean/ValuatedMatroidExchange.lean`, `Catalog/Pythagorean/TropicalMConvexity.lean`, `Catalog/Pythagorean/ExchangeDescent.lean`.

**Proof Strategy:** Adapt the potential descent framework by replacing the coordinate-wise exchange with the matroid basis exchange. The key step is showing that tropical Plücker degree controls the per-step potential decrease via a generalization of the depth decrement.

**Domain Bridges:** Algebraic combinatorics (valuated matroids) → Tropical geometry (Plücker degree) → Discrete optimization (descent bounds).

**Lineage:** Builds on `exchangeDescent_depth_bound` and `exchangeDLC_k_depth_mono`.

**Ambition:** Solid extension with high potential for cross-domain impact.

**The key insight is** that tropical Plücker degree is the natural valuated-matroid analogue of certificate depth: it measures how "uniformly structured" the valuation is, and this uniformity controls exchange descent complexity.

**Why now?** The foundation theorems for depth-sensitive descent are now formalized, and the connection to tropical geometry via M-convexity is well-established in the combinatorics literature.

---

## Direction 3: Depth-Curvature Duality via Lorentzian Polynomials (Grand Challenge)

**Conjecture:** There exists a functorial correspondence between certificate depth $k$ of an exchange family and the signature depth (number of Lorentzian directions) of the associated generating polynomial. Specifically, if the generating polynomial of the exchange family is $k$-Lorentzian (has Lorentzian Hessian on a $k$-dimensional subspace), then the exchange family has certificate depth $\geq k$.

**Test:** Compute the Hessian signature of generating polynomials for simplex families with binomial weights (known to be Lorentzian). Verify that the Lorentzian depth matches the certificate depth estimated from descent experiments. Attempt to formalize the $k = 1$ case using the existing Lorentzian polynomial infrastructure.

**Impact:** Would establish a deep structural bridge between the algebraic geometry of Lorentzian polynomials (Brändén–Huh) and the algorithmic complexity of exchange descent. This would be a paradigm-shifting connection: polynomial geometry determining runtime.

**Catalog References:** `Catalog/Pythagorean/HigherOrderLogConcavity.lean`, `Catalog/Pythagorean/LorentzianExchangeCertificates.lean`, `Catalog/Pythagorean/HessianLorentzianGap.lean`.

**Proof Strategy:** Use the Hodge–Riemann relations for Lorentzian polynomials to derive quantitative exchange improvement inequalities. The $k$-Lorentzian condition provides $k$ independent directions of convexity, each contributing a dimension's worth of exchange improvement.

**Domain Bridges:** Algebraic geometry (Lorentzian polynomials) → Spectral theory (Hessian signature) → Discrete optimization (certificate depth).

**Lineage:** Would extend the Brändén–Huh Lorentzian polynomial theory into algorithmic territory.

**Ambition:** Grand challenge — would require new results in real algebraic geometry.

**The key insight is** that Lorentzian signature depth is a *geometric* measure of the same structural regularity that certificate depth captures *combinatorially*, and the two should be functorially related via the generating polynomial.

**Why now?** The Brändén–Huh theory is mature, and the formalized depth-sensitive theory provides the exact target for the correspondence.

---

## Direction 4: Depth-Adaptive Exchange Algorithms

**Conjecture:** There exists a polynomial-time algorithm that, given an exchange family $S$ and objective $f$, estimates the certificate depth $k$ to within $\pm 1$ using $O(|S| \cdot d^2)$ oracle queries, and then selects a descent strategy optimized for depth $k$.

**Test:** Implement the depth estimation algorithm on exchange families of sizes 100–10,000. Measure the accuracy of depth estimation against the true depth (computed by exhaustive verification on small instances). Benchmark the adaptive algorithm against non-adaptive exchange descent.

**Impact:** Would turn the theoretical framework into a practical algorithmic tool: estimate structure, then exploit it. This is the engineering payoff of the depth-sensitive theory.

**Catalog References:** `Pythagorean/DepthSensitiveExchangeDescent.lean` (certificate depth definition, descent bounds).

**Proof Strategy:** Use random sampling of exchange pairs to estimate the minimum per-step improvement (related to $\delta_k$), then invert the depth-decrement formula to recover $k$. The concentration of the improvement estimator follows from log-concavity of the objective.

**Domain Bridges:** Algorithm design → Statistical estimation (depth estimation) → Discrete optimization (adaptive descent).

**Lineage:** Direct application of `depthDecrement_pos` and `depthDecrement_mono`.

**Ambition:** Solid engineering extension with clear practical value.

**The key insight is** that certificate depth can be *estimated* from a polynomial number of random exchange probes, because the depth decrement formula $\delta_k = c/d^{d-k}$ has a unique inverse as a function of $k$.

**Why now?** The formal relationship between depth and runtime is established; the remaining challenge is statistical estimation, which is a well-understood problem.

---

## Direction 5: Sharp Exponent Classification

**Conjecture:** The exponent $d - k$ in the descent bound $O(d^{d-k} \cdot D)$ is generically sharp: for each $0 \leq k < d$, there exist exchange families with descent chains of length $\Omega(d^{d-k-1} \cdot D)$. Moreover, the *exact* optimal exponent is $d - k$ for the upper bound and $d - k - 1$ for the lower bound, with a multiplicative gap of exactly $d$.

**Test:** Construct explicit "hard instances" for each $(d, k)$ pair. For $k = 0$ (no certificate), use adversarial constructions from matroid intersection lower bounds. For intermediate $k$, use "partially structured" exchange families where $k$ coordinates have log-concave weights and $d - k$ coordinates have adversarial weights. Verify step counts computationally for $d \leq 12$.

**Impact:** Would complete the depth-sensitive complexity theory by showing the bounds are essentially tight. This is the "completeness" result that elevates the theory from an upper bound framework to a full classification.

**Catalog References:** `Pythagorean/DepthSensitiveExchangeDescent.lean` (upper bound), `Catalog/Pythagorean/DepthSharpness.lean`.

**Proof Strategy:** For the lower bound, construct an exchange family where the first $k$ coordinates admit rapid descent (deep structure) but the remaining $d - k$ coordinates form a "maze" requiring $d^{d-k-1}$ steps to navigate. The construction uses a product of a simplex (structured part) with a hypercube path (unstructured part).

**Domain Bridges:** Computational complexity (lower bounds) → Combinatorics (explicit constructions) → Discrete optimization (tight bounds).

**Lineage:** Complements all upper bound theorems in this work.

**Ambition:** Solid extension that would be the natural completion of the theory.

**The key insight is** that certificate depth partitions the coordinates into "easy" (structured) and "hard" (unstructured) groups, and the hard coordinates must each contribute a factor of $d$ to the descent length, giving the $d^{d-k}$ scaling.

**Why now?** The upper bounds are established; the lower bound constructions are now precisely guided by the theory's predictions.
