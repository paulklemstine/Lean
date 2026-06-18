# Future Research Directions: Tropical Surprise Theory

## Synthesis

This research cycle established a rigorous mathematical framework for "surprise" that bridges three domains: metric geometry (surprise as distance), tropical algebra (max-plus structure on surprise values), and information theory (entropy, KL divergence, convexity). The framework produced seven formally verified theorems, including the geometric convergence of repeated surprise ($\sum s_0 r^n = s_0/(1-r)$), Jensen's inequality for the convex surprise function $-\log$, the entropy maximization bound $H(p) \leq \log n$, and KL non-negativity. The novel concept of the **Surprise Spectrum** — a non-negative weight function on outcomes forming a tropical module — provides a bridge between the combinatorial (finite sum) and tropical (max) perspectives on surprise.

The most promising cross-domain connection uncovered is between the **Novelty-Familiarity Duality** ($p \cdot (-\log p) \leq 1/e$) and the **Spectral Bound** ($\sum w(a) \leq |α| \cdot \max w(a)$). Together, these suggest a richer theory where the "information geometry" of probability simplices carries a natural tropical metric. The $1/e$ bound arises from calculus of variations on a single variable; extending this to distributions on $n$ outcomes should yield a tropical version of the Fisher information metric, connecting to the Catalog's existing work on tropical structures (`Catalog/Tropical/TropicalStructure.lean`) and the information-theoretic surprise results in `Catalog/Tropical/CategoricalSurprise.lean`.

The direction with the highest breakthrough potential is **Direction 1 (Tropical Fisher Information)**, because it would unify the pointwise bound $p(-\log p) \leq 1/e$ with the spectral bound into a single geometric framework on the probability simplex with tropical structure. **Direction 3 (Surprise Martingales)** has the highest practical impact, as it would connect the narrative chain model to the stochastic analysis infrastructure already available in Mathlib.

---

### Direction 1: Tropical Fisher Information Geometry

**Conjecture**: On the probability simplex $\Delta_n = \{p \in \mathbb{R}^n : p_i > 0, \sum p_i = 1\}$, define the *tropical information metric* $g^{trop}_{ij}(p) = \max(1/p_i, 1/p_j) \cdot \delta_{ij}$. This metric makes the KL divergence $D_{KL}(p \| q)$ a squared distance with respect to $g^{trop}$ up to first order: $D_{KL}(p \| p + dp) = \frac{1}{2} \sum_i dp_i^2 / p_i + O(\|dp\|^3)$, and the tropical analogue (replacing sum with max) satisfies a Pythagorean identity: $D^{trop}(p \| r) = D^{trop}(p \| q) \oplus D^{trop}(q \| r)$ where $\oplus = \max$ and $q$ is the tropical projection of $r$ onto the exponential geodesic through $p$.

**Test**: Compute the tropical KL divergence for the 2-simplex (three outcomes) explicitly. Check whether the Pythagorean identity holds for the triple $(p, q, r)$ where $p$ is uniform, $q = (1/2, 1/4, 1/4)$, and $r = (1/3, 1/2, 1/6)$, with $q$ as the tropical $m$-projection of $r$ onto the exponential family through $p$. This is a concrete computation that can be verified with `#eval` in Lean or floating-point Python.

**Impact**: If true, this would establish that the probability simplex has a natural tropical Riemannian structure dual to the classical Fisher-Rao metric. This would connect tropical geometry to information geometry, opening a new chapter in both fields. If false, the specific failure mode would reveal which properties of the Fisher-Rao metric fail to tropicalize — potentially because the tropical analogue of the exponential family is not well-defined.

**Catalog References**: `Catalog/Tropical/TropicalStructure.lean`, `Catalog/Tropical/CategoricalSurprise.lean`, `Catalog/Tropical/InformationTheory.lean`

**Proof Strategy**: (1) Define the tropical KL divergence as $D^{trop}(p \| q) = \max_i p_i \log(p_i/q_i)$. (2) Prove it satisfies non-negativity (from the pointwise $\log(p_i/q_i) \geq 0$ when $p_i \geq q_i$, taking max). (3) Define tropical $m$-projection via the tropical Legendre transform. (4) Prove the Pythagorean identity by showing the max decomposes.

**Domain Bridges**: Tropical Geometry <-> Information Geometry <-> Surprise Theory

**Lineage**: Builds on `klDiv_nonneg`, `neg_log_convexOn`, `novelty_familiarity_bound` from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Surprise Half-Life and Optimal Callback Placement

**Conjecture**: In a comedy routine modeled as a sequence of $L$ jokes with a running gag (callback), the optimal placement of $k$ callbacks maximizes total surprise $\sum_{j=1}^{k} s_0 r^{n_j}$ where $n_j$ is the number of non-callback jokes since the last callback. The optimal strategy is equal spacing: place callbacks at positions $\lfloor L \cdot j / (k+1) \rfloor$ for $j = 1, \ldots, k$. Moreover, the optimal number of callbacks is $k^* = \lfloor -L / \log_r(2) \rfloor$ (one callback per surprise half-life).

**Test**: For $L = 20$, $s_0 = 1$, $r = 0.5$: compute the total callback surprise for (a) equal spacing with $k = 4$ callbacks at positions 4, 8, 12, 16, and (b) the claimed optimal $k^* = \lfloor 20/1 \rfloor = 20$... Actually with $r = 0.5$, $\log_{0.5}(2) = -1$, so $k^* = 20$, which is degenerate. Try $r = 0.8$: half-life = $\log 2 / \log(5/4) \approx 3.1$, so $k^* = \lfloor 20/3.1 \rfloor = 6$. Verify computationally that spacing 6 callbacks equally outperforms other placements.

**Impact**: Provides a quantitative theory of comedic timing grounded in the surprise decay theorem. Could be applied to narrative design, music composition (leitmotif placement), and UX design (notification timing).

**Catalog References**: `Catalog/Tropical/CategoricalSurprise.lean` (surprise_decay_monotone, surprise_tsum)

**Proof Strategy**: (1) Model as a discrete optimization problem. (2) Show the objective is Schur-concave in the spacing vector (by concavity of $r^n$). (3) Apply the Schur-Osgood inequality to conclude equal spacing is optimal. (4) Optimize over $k$ using the tsum formula.

**Domain Bridges**: Combinatorial Optimization <-> Surprise Theory <-> Narrative Design

**Lineage**: Builds on `surprise_decay_monotone`, `surprise_tsum` from this cycle.

**Ambition**: extension

---

### Direction 3: Surprise Martingales and Doob Decomposition

**Conjecture**: Let $(X_n)$ be a stochastic process adapted to a filtration $(\mathcal{F}_n)$, and define the *surprise process* $S_n = -\log P(X_n | \mathcal{F}_{n-1})$. Then $(S_n)$ admits a Doob decomposition $S_n = M_n + A_n$ where $M_n$ is a martingale (the "pure surprise") and $A_n$ is a predictable process (the "habituation drift"). The habituation drift $A_n$ is non-decreasing (surprise tends to decrease over time) if and only if the conditional entropy $H(X_n | \mathcal{F}_{n-1})$ is non-increasing — i.e., the narrative becomes more predictable over time.

**Test**: Construct a simple 2-state Markov chain with transition matrix $P = [[0.7, 0.3], [0.4, 0.6]]$. Compute the surprise process, its Doob decomposition, and verify computationally that the predictable part is non-decreasing when started from the less-likely state.

**Impact**: Connects surprise theory to the rich Mathlib infrastructure for martingales and stochastic processes. Would enable proving convergence theorems for surprise (e.g., surprise converges a.s. in ergodic narratives) using existing martingale convergence results.

**Catalog References**: `Catalog/Tropical/CategoricalSurprise.lean` (NarrativeChain, conditionalEntropy_nonneg)

**Proof Strategy**: (1) Define the surprise process formally as a function of the narrative chain's path measure. (2) Apply Doob's decomposition theorem (available in Mathlib as `MeasureTheory.Submartingale.doobDecomp`). (3) Characterize when $A_n$ is non-decreasing in terms of the transition matrix eigenvalues.

**Domain Bridges**: Stochastic Analysis <-> Surprise Theory <-> Ergodic Theory

**Lineage**: Builds on `NarrativeChain.conditionalEntropy_nonneg`, `NarrativeChain.conditionalEntropy_le_log` from this cycle.

**Ambition**: grand_challenge

---

### Direction 4: Refinement Towers and Entropy Growth Rate

**Conjecture**: Consider a sequence of refinements $\sigma_0 \preceq \sigma_1 \preceq \sigma_2 \preceq \ldots$ of a probability space, where each refinement $\sigma_{k+1}$ splits each atom of $\sigma_k$ into at most $m$ sub-atoms. By the Refinement Theorem, the entropy sequence $H(\sigma_k)$ is non-decreasing. The conjecture is that the entropy growth rate satisfies $H(\sigma_k) \leq H(\sigma_0) + k \log m$, and this bound is tight (achieved when each refinement splits uniformly).

**Test**: For $m = 2$ (binary refinements) starting from a uniform distribution on 4 atoms, compute $H(\sigma_k)$ for $k = 0, 1, 2, 3$ under: (a) uniform binary splitting, (b) maximally asymmetric splitting (99:1). Verify that (a) achieves the upper bound and (b) grows strictly slower.

**Impact**: Provides a quantitative theory of "surprise potential" — how much additional surprise capacity is unlocked by adding detail to a narrative. Connects to the theory of filtrations and conditional expectations.

**Catalog References**: `Catalog/Tropical/CategoricalSurprise.lean` (refinement_increases_entropy)

**Proof Strategy**: (1) Prove by induction on $k$, using the refinement entropy increase at each step. (2) At each step, the maximum entropy increase from splitting an atom of probability $p$ into $m$ sub-atoms is $p \log m$ (achieved by uniform splitting). (3) Sum over all atoms to get the global bound $H(\sigma_{k+1}) \leq H(\sigma_k) + \log m$.

**Domain Bridges**: Probability Theory <-> Information Theory <-> Combinatorics

**Lineage**: Builds on `refinement_increases_entropy`, `entropy_le_log_card` from this cycle.

**Ambition**: extension

---

### Direction 5: KL Divergence as Tropical Distance

**Conjecture**: The KL divergence $D_{KL}(p \| q)$ can be decomposed as $D_{KL}(p \| q) = \sum_i f(p_i, q_i)$ where $f(a, b) = a \log(a/b)$. Define the *tropical KL divergence* as $D^{trop}(p \| q) = \max_i f(p_i, q_i)$. Then $D^{trop}$ satisfies: (a) $D^{trop}(p \| q) \geq 0$ with equality iff $p = q$; (b) $D^{trop}(p \| q) \leq D_{KL}(p \| q)$ (the tropical version is a lower bound on the classical); (c) $D_{KL}(p \| q) \leq n \cdot D^{trop}(p \| q)$ (the spectral bound applies); (d) $D^{trop}$ satisfies a tropical triangle inequality.

**Test**: Compute both divergences for $p = (1/3, 1/3, 1/3)$ and $q = (1/2, 1/4, 1/4)$ in $\Delta_3$. Verify parts (a)-(c) numerically. Check (d) with a third distribution $r = (1/4, 1/2, 1/4)$.

**Impact**: If $D^{trop}$ is a well-behaved tropical metric on the simplex, it provides a new notion of "distance between distributions" that is computationally simpler (only requires finding the max coordinate) and connects distribution comparison to tropical geometry.

**Catalog References**: `Catalog/Tropical/CategoricalSurprise.lean` (klDiv_nonneg, klDiv_self), `Catalog/Tropical/TropicalStructure.lean`

**Proof Strategy**: (1) Part (a): follows from $a \log(a/b) = 0$ iff $a = b$ (for positive $a, b$). (2) Part (b): max ≤ sum for non-negative terms. (3) Part (c): sum ≤ n · max. (4) Part (d): this is the hardest — requires showing $\max_i f(p_i, r_i) \leq \max(\max_i f(p_i, q_i), \max_i f(q_i, r_i))$ or some tropical analogue. This may fail; the failure would be interesting.

**Domain Bridges**: Information Theory <-> Tropical Geometry <-> Metric Geometry

**Lineage**: Builds on `klDiv_nonneg`, `klDiv_self`, `SurpriseSpectrum.totalSurprise_le_card_mul_max` from this cycle.

**Ambition**: extension
