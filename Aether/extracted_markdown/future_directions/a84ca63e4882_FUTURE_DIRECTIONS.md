# Future Directions: Dynamic Lorentzian Certificates

## Synthesis

The theory of dynamic Lorentzian certificates establishes that algebraic certificates for log-concave polynomials are *locally updatable*: rank-1 monomial perturbations affect only a sparse, precisely characterized subset of the certificate tree. This opens five interconnected research directions, ranging from immediate extensions (multi-monomial updates, sharper affected-count bounds) to grand challenges (streaming high-dimensional expanders, online partition-function inference). The unifying theme is that **algebraic locality in certificates translates to algorithmic locality in dynamic combinatorial systems**.

---

## Direction 1: Streaming Matroid Sampling via Certificate Chains

**Conjecture:** For a sequence of graphic matroid updates $f_0, f_1, f_2, \ldots$ with $f_{t+1} = f_t + c_t X^{\alpha_t}$, the basis-exchange Markov chain can be maintained in *amortized* $O(n^2 \cdot |\text{Affected}(\alpha_t)| \cdot \log(1/\varepsilon))$ time per update, where $\varepsilon$ is the target mixing accuracy.

**Test:** Implement the streaming framework on random graph sequences with $n = 50, 100, 200$ vertices. Measure: (a) per-step dynamic certificate cost vs rebuild cost, (b) warm-start mixing time vs cold-start mixing time, (c) whether amortized cost matches the predicted scaling. Compare against the best known streaming spanning-tree samplers.

**Impact:** Would provide the first provably efficient streaming sampler for matroid bases, with applications to network reliability, randomized rounding, and combinatorial auction design.

**Catalog References:**
- `Pythagorean/DynamicLorentzianCertificates.lean`: `iterated_pderiv_rankOneUpdate_eq_of_not_le`, `graphicMatroid_singleBasisUpdate_local`
- `Catalog/Pythagorean/CertificateSampling.lean`: `certificate_verification_complexity`, `certificate_sampling_efficiency`

**Proof Strategy:** Combine the locality theorem with spectral gap bounds from `certificate_sampling_efficiency`. The key step is showing that the warm-start total variation bound implies a multiplicative-to-additive reduction in mixing time, using the conductance profile framework of Lovász–Kannan.

**Domain Bridges:** Streaming algorithms, matroid optimization, network science.

**Lineage:** Extends Theorems 1, 2, and 4 of the current work.

**Ambition:** 🔴 Grand Challenge — requires new mixing-time machinery beyond what exists in Mathlib.

---

## Direction 2: Multi-Monomial Updates and Batch Certificate Maintenance

**Conjecture:** For a batch update $f' = f + \sum_{j=1}^m c_j X^{\alpha_j}$, the affected certificate nodes are contained in $\bigcup_j \text{Affected}(\alpha_j, k)$ at each depth $k$. The dynamic cost satisfies:
$$\text{dynamicCost}(f \to f') \leq n^2 \sum_{k=0}^{d-2} \left|\bigcup_j \text{Affected}(\alpha_j, k)\right|$$
which can be substantially smaller than $m$ times the single-update cost when the $\alpha_j$ have overlapping support.

**Test:** Construct batch updates with varying overlap structure. Measure the union-affected count vs the sum of individual affected counts. Verify the inequality computationally for random polynomial families.

**Impact:** Extends the theory from rank-1 to rank-$m$ updates, enabling efficient batch processing for scenarios where multiple edges arrive simultaneously.

**Catalog References:**
- `Pythagorean/DynamicLorentzianCertificates.lean`: `AffectedMultiindices`, `dynamicCertificateCost`

**Proof Strategy:** The linearity of `iteratedMvPDeriv` immediately gives additivity: $\partial^\beta(\sum c_j X^{\alpha_j}) = \sum c_j \partial^\beta(X^{\alpha_j})$. A node $\beta$ is unaffected iff $\beta \not\leq \alpha_j$ for ALL $j$, which is $\beta \notin \bigcup_j \text{Affected}(\alpha_j, k)$.

**Domain Bridges:** Batch processing, parallel algorithms.

**Lineage:** Direct extension of Theorem 1.

**Ambition:** 🟡 Solid Extension — proof follows directly from existing infrastructure.

---

## Direction 3: Dynamic High-Dimensional Expanders

**Conjecture:** The Lorentzian certificate tree for a simplicial complex's complete homogeneous polynomial encodes the local spectral expansion properties of the complex. Dynamic certificate updates under face insertions/deletions correspond to local spectral updates, enabling $O(n^{O(1)})$-time maintenance of expansion certificates for bounded-degree complexes.

**Test:** Formalize the connection between certificate tree eigenvalues and Garland's method for spectral expansion. Compute certificate perturbations for face-stream updates on random 2-dimensional complexes. Verify that the certificate eigenvalues track the true expansion eigenvalues.

**Impact:** Would connect dynamic Lorentzian certification to the rapidly developing theory of high-dimensional expanders, with implications for error-correcting codes, agreement testing, and topological sampling.

**Catalog References:**
- `Pythagorean/DynamicLorentzianCertificates.lean`: `rankOneUpdate_isHomogeneous`
- `Catalog/Bridges/LorentzianRecognition.lean`: `pderiv_isHomogeneous_degree_pred`

**Proof Strategy:** Use the certificate depth structure (`certificateDepth'`) to map certificate levels to simplicial levels. Connect the positive-semidefiniteness checks at each level to Garland's eigenvalue bounds via the Lorentzian-to-spectral correspondence.

**Domain Bridges:** Algebraic topology, coding theory, property testing.

**Lineage:** Builds on Theorems 1, 3 and the Lorentzian recognition infrastructure.

**Ambition:** 🔴 Grand Challenge — requires substantial new formalization of simplicial HDX theory.

---

## Direction 4: Online Partition-Function Inference

**Conjecture:** For an evolving partition function $Z_t = \sum_{\sigma} w_t(\sigma)$ where $w_{t+1} = w_t + c_t \cdot \mathbf{1}_{\sigma = \sigma_t}$ (single-configuration insertion), the warm-start bound $\text{TV} \leq \Delta / \min(Z_t, Z_{t+1})$ controls the regret of a follow-the-leader strategy that samples from $w_t / Z_t$. Specifically, the expected regret over $T$ rounds is $O(\sqrt{T \cdot \sum_t \Delta_t / Z_t})$.

**Test:** Implement the online sampling strategy for Ising model partition functions with evolving couplings. Measure empirical regret vs the predicted bound for lattice sizes $L = 4, 8, 16, 32$.

**Impact:** Would connect dynamic Lorentzian certification to online learning theory, providing a new class of sampling-based online algorithms with provable regret bounds.

**Catalog References:**
- `Pythagorean/DynamicLorentzianCertificates.lean`: `normalizedCoeffDist_tv_bound`, `coeffL1Delta`

**Proof Strategy:** Use the TV bound as a stability guarantee for the follow-the-regularized-leader analysis. The coefficient L1 drift $\Delta_t$ plays the role of the loss variation, and the partition function $Z_t$ provides the regularization strength.

**Domain Bridges:** Online learning, statistical physics, stochastic optimization.

**Lineage:** Extends Theorem 5 to the online learning setting.

**Ambition:** 🟡 Solid Extension — requires connecting existing TV bounds to regret analysis.

---

## Direction 5: Optimal Affected-Count Bounds for Structured Matroids

**Conjecture:** For the graphic matroid of a graph $G$ with maximum degree $\Delta$, treewidth $w$, and $n$ edges, the affected count satisfies:
$$|\text{Affected}(\alpha, k)| \leq \binom{\min(\Delta, n-1)}{k}$$
for any squarefree basis monomial $\alpha$. For bounded-treewidth graphs, this gives polynomial dynamic certificate cost even when $d = n - 1$ is large.

**Test:** Compute exact affected counts for graphic matroids of (a) path graphs, (b) cycle graphs, (c) grid graphs, (d) random regular graphs, for $n = 10, 20, 50$. Compare with the binomial bound and identify cases where it is tight.

**Impact:** Would provide structural insight into when dynamic certification is most effective, guiding practitioners to the graph families where streaming algorithms achieve the largest speedups.

**Catalog References:**
- `Pythagorean/DynamicLorentzianCertificates.lean`: `affectedCount`, `dynamic_certificate_cost_eq`

**Proof Strategy:** Use the squarefree structure: $\alpha_i \in \{0, 1\}$, so $\text{Affected}(\alpha, k) = \{\beta : \text{supp}(\beta) \subseteq \text{supp}(\alpha), |\beta| = k, \beta_i \leq 1\}$. This is exactly $\binom{|\text{supp}(\alpha)|}{k}$. The structural bound follows from $|\text{supp}(\alpha)| = n - 1$ (spanning tree) and the relationship between tree support and graph degree.

**Domain Bridges:** Graph theory, parameterized complexity, network science.

**Lineage:** Sharpens Theorem 2 for the graphic matroid case.

**Ambition:** 🟢 Accessible — the squarefree case is combinatorially clean.
