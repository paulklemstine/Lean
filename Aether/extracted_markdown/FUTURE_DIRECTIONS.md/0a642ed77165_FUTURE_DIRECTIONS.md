# Future Directions: Spectral Proof Universality

## Overview

The formalized results in this project establish the mathematical foundations for spectral proof universality: the trace-eigenvalue identity, degree-eigenvalue bounds, spectral moment universality, and perturbation stability. Below are five falsifiable scientific hypotheses that build on this foundation, each with precise conjectures, testing methodology, and refutation criteria.

---

## Hypothesis 1: Kesten–McKay Law for Proof Dependency Graphs

**Conjecture:** After normalization and degree-rescaling, the empirical spectral measure of proof dependency graphs from large arithmetic theorem libraries converges to a Kesten–McKay distribution with parameter equal to the average degree.

The Kesten–McKay law governs the spectral distribution of random regular graphs. If proof dependency graphs exhibit local tree-like structure (as expected for large libraries where individual lemmas reference only a few predecessors), the Kesten–McKay law should emerge.

**Precise formulation:** Let $G_n$ be the moralized dependency graph of the first $n$ theorems in a formalized arithmetic library, with average degree $d_n$. Then the empirical spectral measure $\mu_{G_n}$ converges weakly to the Kesten–McKay measure
$$\mu_{d}(x) = \frac{d \sqrt{4(d-1) - x^2}}{2\pi(d^2 - x^2)} \, dx$$
supported on $[-2\sqrt{d-1}, 2\sqrt{d-1}]$.

**Test:** Compute the empirical spectral histogram of Mathlib's dependency graph (restricted to arithmetic modules) at sizes $n = 500, 1000, 2000, 5000$. Compute the first 8 moments and compare against the Kesten–McKay prediction.

**Refutation:** If the first 4 normalized moments deviate from the Kesten–McKay prediction by more than $n^{-1/4}$ at each tested scale $n$, and this deviation is systematic (same sign, growing magnitude), the hypothesis is refuted. In particular, if the excess kurtosis of the empirical spectral distribution grows with $n$, this indicates non-tree-like local structure inconsistent with Kesten–McKay convergence.

**Impact:** If confirmed, this provides a canonical "null model" for proof structure — deviations from the Kesten–McKay law would signal non-generic proof architecture (e.g., heavy reuse of specific lemmas, cyclic proof patterns, or unusual abstraction levels).

---

## Hypothesis 2: Cross-Foundation Spectral Convergence

**Conjecture:** Proof corpora implementing the same mathematical content in different formal systems (e.g., the natural number arithmetic libraries of two different proof assistants) produce dependency graphs with converging spectral moments after canonical normalization.

**Precise formulation:** Let $G^{\text{sys1}}_n$ and $G^{\text{sys2}}_n$ be the moralized dependency graphs of the first $n$ theorems (by topological sort) in System 1's and System 2's respective arithmetic libraries. After normalization (collapsing definitional unfoldings, removing administrative nodes), there exists a subsequence $n_k \to \infty$ such that for all moment orders $p$,
$$\left|\mu_p(G^{\text{sys1}}_{n_k}) - \mu_p(G^{\text{sys2}}_{n_k})\right| \to 0.$$

**Test:** Extract dependency DAGs from two large formalized arithmetic libraries. Apply the canonical graph construction (moralize parent sets, collapse definitional expansions, quotient by alpha-renaming). Compute normalized spectral moments $\mu_0, \ldots, \mu_8$ at multiple scales. Plot moment trajectories and test for convergence.

**Refutation:** If after trying all reasonable normalizations (at least 3 distinct canonical forms), the moment differences at order $p = 4$ remain bounded away from zero (specifically, $|\Delta \mu_4| > 0.1$ at all scales $n > 1000$), the hypothesis is refuted. This would indicate that proof architecture encodes foundation-specific information beyond local combinatorics.

**Impact:** Confirmation would establish that mathematical structure, not syntactic encoding, determines the spectral law — a profound claim about the universality of mathematical reasoning. This would validate transfer learning between proof systems.

---

## Hypothesis 3: Spectral Stability Under Proof Normalization

**Conjecture:** Standard proof normalization operations (definitional unfolding, tactic expansion, proof-term compression, beta-reduction) change the empirical spectral measure of the dependency graph by $o(1)$ in the bounded-Lipschitz metric as the corpus size grows.

**Precise formulation:** Let $G_n$ be the dependency graph before normalization and $G'_n$ after applying a normalization operation that changes at most $C$ vertices locally. Then
$$d_{\text{BL}}(\mu_{G_n}, \mu_{G'_n}) \leq \frac{2C \cdot R^k}{n}$$
for the $k$-th moment contribution, where $R$ is the spectral radius bound from the degree bound (Theorem: eigenvalue_bound_of_degree_bound').

**Test:** Take a fixed proof corpus of $n$ theorems. Apply each of the following operations:
  1. Unfold all definitions to their primitive forms
  2. Inline all lemma applications (proof-term expansion)  
  3. Compress proof terms by maximal sharing (hash-consing)

For each, compute the Kolmogorov distance and bounded-Lipschitz distance between the original and modified spectral measures.

**Refutation:** If any single normalization operation produces $d_{\text{BL}}(\mu_G, \mu_{G'}) > 0.5$ for corpora of size $n > 500$, and this bound does not decrease as $n$ grows, the hypothesis is refuted. This would mean that normalization fundamentally alters the spectral character of proofs.

**Impact:** This hypothesis, once confirmed, would justify treating the spectral law as a genuine invariant of proof content rather than proof presentation. It is the key requirement for cross-system universality.

---

## Hypothesis 4: Spectral Phase Separation of Mathematical Domains

**Conjecture:** The limiting spectral invariants (second moment $\mu_2$, spectral radius, and the ratio $\mu_4/\mu_2^2$) separate mathematical theorem corpora into distinct universality classes corresponding to mathematical domains: elementary arithmetic, algebraic structures, analysis, and higher-order abstraction.

**Precise formulation:** There exist thresholds $\tau_2, \tau_4, \tau_r$ such that:
- **Elementary** (natural number arithmetic, basic combinatorics): $\mu_2 < \tau_2$, $\mu_4/\mu_2^2 < 3$
- **Algebraic** (group theory, ring theory, linear algebra): $\tau_2 \leq \mu_2 < 2\tau_2$, $3 \leq \mu_4/\mu_2^2 < 5$
- **Analytic** (real analysis, measure theory, functional analysis): $\mu_2 \geq 2\tau_2$
- **Abstract** (category theory, topos theory, homotopy type theory): $\mu_4/\mu_2^2 \geq 5$

**Test:** Extract dependency graphs from at least 4 formalized mathematical libraries covering the above domains (e.g., arithmetic and combinatorics modules, algebra modules, analysis modules, and category theory modules from Mathlib). Compute the spectral invariants and apply k-means clustering with $k = 4$.

**Refutation:** If k-means clustering on the spectral feature vector $(\mu_2, \mu_4/\mu_2^2, \rho)$ achieves adjusted Rand index $< 0.3$ against the ground-truth domain labels, the hypothesis is refuted. Equivalently, if a random permutation of domain labels achieves comparable clustering quality, spectral invariants do not carry domain information.

**Impact:** If confirmed, this creates a spectral taxonomy of mathematics — a periodic table for mathematical reasoning, where each domain has a characteristic spectral fingerprint. This would enable automatic mathematical domain classification and could reveal unexpected connections between superficially different areas.

---

## Hypothesis 5: Spectral Transfer Learning for Theorem Proving

**Conjecture:** Proof-search heuristics trained on spectral/motif features of proof dependency graphs in one formal system transfer effectively to another system after canonical graph translation, achieving statistically significant performance gains over baseline search.

**Precise formulation:** Let $\mathcal{H}_1$ be a proof-search heuristic trained on System 1's proof corpus using features derived from the spectral moments $\mu_0, \ldots, \mu_8$ and radius-2 motif frequencies. Let $\mathcal{H}_2$ be $\mathcal{H}_1$ applied to System 2's corpus after canonical graph translation. Then on a held-out test set of 100 theorems in System 2:
$$\text{solve rate}(\mathcal{H}_2) \geq \text{solve rate}(\text{baseline}) + 5\%$$
where the baseline is uniform random proof search.

**Test:** 
  1. Train a graph neural network or gradient-boosted classifier on System 1's proof dependency features to predict "useful lemma" selections during proof search.
  2. Apply the canonical graph translation to map System 1's feature space to System 2's.
  3. Evaluate the transferred heuristic on 100 test theorems in System 2.
  4. Compare solve rates against a baseline (random search, BFS, or untrained heuristic).

**Refutation:** If the transferred heuristic performs no better than random search (p > 0.05 on a one-sided binomial test for solve rate improvement), and this holds across at least 3 different (System 1, System 2) pairs, the hypothesis is refuted.

**Impact:** This is the applied payoff of spectral proof universality. If heuristics transfer across formal systems via spectral features, it would create a unified approach to automated theorem proving that is foundation-agnostic — a "Rosetta Stone" for mathematical reasoning.

---

## Summary Table

| # | Hypothesis | Key Observable | Refutation Criterion |
|---|-----------|----------------|---------------------|
| 1 | Kesten–McKay law for proofs | Spectral moments vs. KM prediction | Moment gap > $n^{-1/4}$ at all scales |
| 2 | Cross-foundation convergence | Moment differences across systems | $\|\Delta\mu_4\| > 0.1$ at $n > 1000$ |
| 3 | Normalization stability | BL distance before/after normalization | $d_{\text{BL}} > 0.5$ at $n > 500$ |
| 4 | Spectral phase separation | Clustering quality by domain | Adjusted Rand index $< 0.3$ |
| 5 | Transfer learning | Solve rate improvement | No significant gain ($p > 0.05$) |
