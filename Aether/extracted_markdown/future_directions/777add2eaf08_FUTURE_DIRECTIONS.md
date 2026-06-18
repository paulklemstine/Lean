# Future Directions: Tropical Probabilistic Comparison Theory

*A founding research manifesto for the systematic comparison of spectral mixing and tropical cycle geometry.*

---

## Overview

The theorems proved in this work establish the first formal bridge between Markov chain mixing theory and tropical (min-plus) cycle geometry. The logarithmic weight transform `W = -log P` converts a stochastic matrix into a tropical weight matrix, and we have shown that **entrywise probability bounds force tropical cycle separation**. This opens five specific research programs, each building directly on the formalized infrastructure.

---

## Direction 1: Multi-Step Heat-Kernel Tropicalization

### Statement

For a row-stochastic strictly positive matrix `P` on `Fin (n+1)` and any `m ≥ 1`, define the m-step tropical weight matrix:

$$W^{(m)}_{ij} := -\log((P^m)_{ij})$$

If the spectral gap `γ(P) = 1 - λ_2(P)` satisfies `γ > 0`, then for large enough `m`:

$$g(W^{(m)}) \geq -\log\left(\frac{1}{n+1} + (1 - \gamma)^m\right)$$

### Proof Strategy

1. **Spectral mixing bound**: For symmetric row-stochastic `P` with spectral gap `γ`, standard spectral theory gives `(P^m)_{ij} ≤ 1/(n+1) + (1-γ)^m`.
2. **Apply our framework**: Feed the entrywise bound into `triangleCycleGap_logWeight_lower_bound` applied to `P^m`.
3. **Asymptotic analysis**: As `m → ∞`, the bound converges to `-log(1/(n+1)) = log(n+1)`, the maximum possible tropical cycle mean.

### Cross-Domain Significance

- **Markov chains**: Converts mixing time estimates into tropical energy barriers at scale `m`.
- **Statistical physics**: The quantity `-log((P^m)_{ij})` is the m-step free energy cost of reaching state `j` from `i`; cycle means become average loop free energies.
- **Algorithms**: Provides computable certificates for mixing via tropical cycle computation on powered matrices.

### Lean Formalization Target

```
theorem multi_step_tropical_gap
    {n m : ℕ} (P : Matrix (Fin (n+1)) (Fin (n+1)) ℝ)
    (hrow : RowStochastic P) (hpos : PositiveMatrix P)
    (α : ℝ) (hα : 0 < α) (hα1 : α < 1)
    (hpow : ∀ i j, (P ^ m) i j ≤ α) :
    -Real.log α ≤ triangleCycleGap (logWeight (P ^ m))
```

---

## Direction 2: Tropical Cheeger Inequality

### Statement

Define the **tropical edge conductance** of a weight matrix `W` with stationary measure `π`:

$$\Phi_{\mathrm{trop}}(W) := \min_{S \subset V, \pi(S) \leq 1/2} \frac{\sum_{i \in S, j \notin S} \exp(-W_{ij}) \cdot \pi_i}{\pi(S)}$$

Then for `W = -log P`:

$$\Phi_{\mathrm{trop}}(W) = \Phi(P)$$

where `Φ(P)` is the classical Cheeger conductance of the Markov chain. Combined with the classical Cheeger inequality `γ(P) ≥ Φ(P)²/2`, this gives:

$$g(W) \geq -\log(1 - \Phi_{\mathrm{trop}}(W)^2/2)$$

### Proof Strategy

1. Show that `exp(-W_{ij}) = P_{ij}` recovers the classical transition probabilities.
2. Prove that tropical conductance equals classical conductance under the log transform.
3. Chain: Cheeger inequality → entrywise bound via spectral gap → tropical cycle gap via our Theorem 1.

### Cross-Domain Significance

- **Graph theory**: Connects tropical bottleneck structure (min-cut analogue in tropical geometry) to classical expansion.
- **Algorithms**: Tropical conductance is computable via min-cut algorithms on tropical semirings, providing new algorithmic approaches to mixing certificates.
- **Geometry**: This is a tropical analogue of the Riemannian Cheeger inequality, replacing curvature bounds with cycle-mean bounds.

---

## Direction 3: Entropy-Rate Lower Bounds via Tropical Cycle Means

### Statement

For an ergodic Markov chain with stationary distribution `π` and entropy rate

$$h(P) = -\sum_i \pi_i \sum_j P_{ij} \log P_{ij} = \sum_i \pi_i \sum_j P_{ij} W_{ij}$$

prove that:

$$h(P) \geq g(W)$$

That is, the entropy rate (average surprisal per step under stationarity) is bounded below by the minimum tropical cycle mean.

### Proof Strategy

1. Write `h(P)` as a weighted average of edge weights `W_{ij}`.
2. Show that any weighted average of `W_{ij}` with stochastic weights is at least `min_{ij} W_{ij}`.
3. Since `g(W) ≤ min_{ij} W_{ij}` (the minimum single-edge weight is a trivial cycle mean), we get `h(P) ≥ g(W)`.
4. For a tighter bound, use the cycle representation: the entropy rate can be decomposed into contributions from cycle flows (via the Markov chain tree theorem), each contributing at least `g(W)` per unit flow.

### Cross-Domain Significance

- **Information theory**: The tropical cycle gap becomes an information-theoretic barrier — every stationary bit stream from the Markov source carries at least `g(W)` bits of surprisal per step.
- **Large deviations**: By Sanov's theorem and the Donsker-Varadhan formula, the rate function for empirical measures is related to relative entropy, and our bound constrains the minimum cost of any empirical cycle.
- **Coding theory**: The tropical cycle gap provides a lower bound on the compression limit for Markov sources.

### Lean Formalization Target

```
theorem entropy_rate_ge_tropical_gap
    {n : ℕ} (P : Fin (n+1) → Fin (n+1) → ℝ)
    (π : Fin (n+1) → ℝ)
    (hrow : RowStochastic P) (hpos : PositiveMatrix P)
    (hstat : ∀ j, π j = ∑ i, π i * P i j)
    (hπpos : ∀ i, 0 < π i) (hπsum : ∑ i, π i = 1) :
    triangleCycleGap (logWeight P) ≤
      ∑ i, π i * ∑ j, P i j * (-Real.log (P i j))
```

---

## Direction 4: Reversible Chains and Exact Spectral Comparison

### Statement

For a **symmetric** row-stochastic strictly positive matrix `P` on `Fin (n+1)`, the eigenvalues are real: `1 = λ_1 ≥ λ_2 ≥ ... ≥ λ_{n+1} ≥ -1`. The spectral gap is `γ = 1 - λ_2`.

Prove the **exact spectral-tropical comparison**:

$$g(W) \geq -\log(1 - \gamma(P))$$

when `γ(P) < 1`, and `g(W) = +∞` (no finite cycles) is vacuously satisfied otherwise.

### Proof Strategy

1. For symmetric stochastic `P`, use the spectral decomposition `P = \sum_k λ_k v_k v_k^T` to bound entries: `P_{ij} ≤ λ_2 + (1-λ_2)/(n+1) ≤ 1 - γ + γ/(n+1)`.
2. Actually, a cleaner bound: since `P` is doubly stochastic (symmetric + row-stochastic), `P_{ij} ≤ max(λ_k) = max(1, |λ_n|) = 1`, which is trivial. The nontrivial bound requires using that `P_{ij} - 1/(n+1) = \sum_{k≥2} λ_k (v_k)_i (v_k)_j`, and bounding this by spectral radius.
3. Use Cauchy-Schwarz: `|P_{ij} - 1/(n+1)| ≤ (1-γ) \cdot \sqrt{P_{ii} P_{jj}}`. Under uniform distribution, `P_{ii} ≤ 1`, giving `P_{ij} ≤ 1/(n+1) + (1-γ)`.
4. Feed into `triangleCycleGap_logWeight_lower_bound`.

### Cross-Domain Significance

- **Random walks on graphs**: The spectral gap of the normalized Laplacian controls random walk mixing; this theorem gives a tropical-geometric interpretation.
- **Expander graphs**: For expander families, `γ` is bounded away from 0, giving uniform tropical cycle separation — a new characterization of expansion.
- **Quantum computing**: Spectral gaps of stochastic matrices appear in quantum walk analysis; tropical cycle gaps could provide new algorithmic invariants.

### Lean Formalization Target

```
theorem symmetric_spectral_tropical_comparison
    {n : ℕ} (P : Matrix (Fin (n+1)) (Fin (n+1)) ℝ)
    (hsymm : P.IsSymm) (hrow : ∀ i, ∑ j, P i j = 1)
    (hpos : ∀ i j, 0 < P i j)
    (γ : ℝ) (hγ : 0 < γ)
    (hspec : ∀ i j, P i j ≤ 1/(n+1) + (1 - γ)) :
    -Real.log (1/(n+1) + (1-γ)) ≤
      triangleCycleGap (logWeight P)
```

---

## Direction 5: Support-Sensitive Sparse Extension

### Statement

Replace the strict positivity assumption with a **support graph** `G ⊆ Fin n × Fin n` and assign tropical weight `⊤` (infinity) to absent edges. Define the **extended tropical cycle gap**:

$$g_G(W) := \inf_{c \in \mathcal{C}(G)} \frac{\text{cycleWeight}(W,c)}{\text{length}(c)}$$

where `C(G)` ranges over cycles supported on `G`.

Prove: If `G` is strongly connected and `P_{ij} > 0 iff (i,j) ∈ G`, then:

$$g_G(W) \geq -\log\left(\max_{(i,j) \in G} P_{ij}\right) > 0$$

### Proof Strategy

1. Define edge weights in `WithTop ℝ` (or `ENNReal`) to handle the `∞` case.
2. Restrict cycle enumeration to the support graph.
3. On supported edges, apply our existing `neg_log_antitone` bound.
4. The strong connectivity assumption ensures at least one finite cycle exists.

### Cross-Domain Significance

- **Sparse Markov chains**: Most practical Markov chains (e.g., MCMC on graphs, random walks on networks) are sparse. This extension handles them natively.
- **Network optimization**: Tropical cycle means on sparse digraphs are the core object of study in min-plus spectral theory and network timing analysis (Howard's algorithm, Karp's algorithm).
- **Tropical algebraic geometry**: Support constraints correspond to tropical varieties — the set of weight matrices with prescribed support. This direction connects our comparison theory to the geometry of tropical discriminants and Newton polytopes.

### Lean Formalization Target

```
theorem sparse_tropical_gap_lower_bound
    {n : ℕ} (P : Fin (n+1) → Fin (n+1) → ℝ)
    (G : Fin (n+1) → Fin (n+1) → Prop)
    (hsupp : ∀ i j, G i j ↔ 0 < P i j)
    (s : ℝ) (hs : 0 < s)
    (hbound : ∀ i j, G i j → P i j ≤ s)
    (c : List (Fin (n+1)))
    (hcycle : ∀ t < c.length - 1, G (c[t]) (c[t+1]))
    (hlen : 1 < c.length) :
    (-Real.log s) * (c.length - 1) ≤ pathWeight (logWeight P) c
```

---

## Cross-Cutting Research Program

### Unifying Theme

All five directions share a common structure:

1. **Probabilistic input**: A stochastic matrix `P` with mixing/spectral/conductance properties.
2. **Logarithmic bridge**: The transform `W = -log P` converts to tropical geometry.
3. **Tropical output**: A cycle-mean or path-weight inequality in the tropical domain.

This suggests a general **tropical comparison functor** that maps:
- Spectral data of `P` → Cycle-mean bounds on `W`
- Entropy/information data of `P` → Weighted cycle bounds on `W`
- Conductance/cut data of `P` → Tropical bottleneck data on `W`

### Existing Infrastructure

The theorems already formalized provide the foundation:
- `spectral_tropical_bound` (from `SpectralIdempotentBridge.lean`): Classical trace ≤ tropical eigenvalue for 2×2 matrices — the scalar seed.
- `TropicalMixing` (from `MixingTheory.lean`): Diagonal-based tropical cycle gaps and mixing bounds for 2-state chains.
- Our new `triangleCycleGap_logWeight_lower_bound`: The first general-dimension bridge theorem.

### Computational Experiments

Each direction should be accompanied by:
1. Python implementations computing the relevant invariants.
2. Numerical experiments on random stochastic matrices validating the bounds.
3. Visualization of the tropical-spectral landscape as matrix dimension grows.

---

## Timeline and Dependencies

```
Direction 1 (Multi-step)    ← Requires: matrix power lemmas in Mathlib
Direction 2 (Cheeger)       ← Requires: Cheeger inequality formalization
Direction 3 (Entropy)       ← Requires: stationary distribution theory
Direction 4 (Symmetric)     ← Requires: symmetric matrix eigenvalue bounds
Direction 5 (Sparse)        ← Requires: WithTop ℝ infrastructure
```

Directions 1 and 5 are most immediately achievable given current Mathlib coverage. Direction 3 is the most information-theoretically impactful. Direction 4 is the deepest mathematically. Direction 2 is the most algorithmically significant.

---

*This document serves as the founding roadmap for tropical probabilistic comparison theory — a systematic program to translate between the spectral world of Markov chain mixing and the combinatorial world of tropical cycle geometry.*
