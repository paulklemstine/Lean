# Future Directions: Dynamic Lorentzian Certificates

## Synthesis

The theory of dynamic Lorentzian certificates established in this work — locality of derivative perturbation, dynamic complexity bounds, and warm-start total variation control — opens a rich landscape of follow-up research. The five directions below form a coherent program: Direction 1 (mixing time) sharpens the probabilistic core, Direction 2 (batch updates) generalizes the algebraic engine, Direction 3 (negative dependence) deepens the combinatorial theory, Direction 4 (streaming implementation) delivers practical algorithms, and Direction 5 (statistical physics) bridges to a new domain entirely. Together, they constitute a roadmap for transforming dynamic Lorentzian certification from a proof-of-concept into a mature computational theory.

---

## Direction 1: Sharp Warm-Start Mixing Time Bounds

**Conjecture.** For Lorentzian polynomials evolving under rank-1 updates with coefficient perturbation $\delta_t$ (measured in normalized $\ell_1$), the basis-exchange Markov chain started from the old stationary distribution mixes to within $\varepsilon$ of the new stationary distribution in $O(\log(1/\varepsilon) \cdot (1 + \delta_t / \gamma))$ steps, where $\gamma$ is the spectral gap of the new chain.

**Test.** Implement the basis-exchange walk for graphic matroids on $G(n, p)$ for $n \in \{20, 50, 100, 200\}$. For each edge update, measure:
1. Warm-start mixing time (empirical TV convergence to stationarity)
2. Cold-start mixing time (from uniform initialization)
3. Spectral gap estimate via coupling or conductance

Compare the ratio warm/cold against the predicted $O(1 + \delta_t/\gamma)$. The conjecture is falsified if the ratio grows polynomially in $n$ for bounded $\delta_t$.

**Impact.** A positive result would give the first rigorous warm-start mixing guarantee for Lorentzian distributions, enabling streaming MCMC with provable efficiency. This would subsume and unify several results on log-concave distribution sampling.

**Catalog References.** `Catalog/Pythagorean/CertificateSampling.lean` (`spectral_gap_log_concave_lower_bound`, `certificate_sampling_efficiency`), `Pythagorean/DynamicLorentzianCertificates.lean` (`normalizedCoeffDist_tv_bound`).

**Proof Strategy.** Combine the warm-start TV bound with the spectral gap bound from `CertificateSampling.lean`. The key step is a multiplicative reversibility argument: if the old and new stationary distributions are close in TV, then the old chain's conductance profile transfers to the new chain with bounded loss. Formalize via a comparison theorem for Markov chain spectral gaps.

**Domain Bridges.** MCMC theory, spectral graph theory, streaming algorithms.

**Lineage.** Extends `normalizedCoeffDist_tv_bound` (this work) + `spectral_gap_log_concave_lower_bound` (CertificateSampling).

**Ambition.** 🔬 Solid extension — builds directly on two existing catalog results.

---

## Direction 2: Multi-Monomial Batch Updates and Amortized Certificates

**Conjecture.** For a batch of $m$ rank-1 updates $f \to f + \sum_{j=1}^m c_j X^{\alpha_j}$, the total amortized dynamic certificate cost satisfies:
$$\text{Cost}_{\text{batch}} \le m \cdot \max_j \text{dynamicCertificateCost}(\alpha_j) + |\bigcup_j \text{Affected}(\alpha_j, \cdot)|$$
where the union term captures interaction between updates. For "spread" batches (disjoint affected sets), this is strictly subadditive.

**Test.** Generate random batches of $m \in \{1, 5, 10, 50\}$ monomial updates. Measure the exact affected node count after the batch vs. the sum of individual affected counts. The conjecture predicts subadditivity grows with batch size for spread updates and saturates for concentrated ones.

**Impact.** Practical streaming systems process updates in batches, not one at a time. A batch-aware dynamic certificate theory would reduce the per-update amortized cost and enable pipelined processing.

**Catalog References.** `Pythagorean/DynamicLorentzianCertificates.lean` (`iterated_pderiv_rankOneUpdate_eq_of_not_le`, `dynamic_certificate_cost_le_prod_bound`).

**Proof Strategy.** Iterate the locality theorem for each monomial in the batch. The key insight is that the affected set for $f + c_1 X^{\alpha_1} + c_2 X^{\alpha_2}$ is contained in $\text{Affected}(\alpha_1) \cup \text{Affected}(\alpha_2)$. Formalize the union bound and prove subadditivity when the supports are disjoint.

**Domain Bridges.** Amortized analysis, batch-dynamic data structures, streaming databases.

**Lineage.** Direct extension of the single-update locality theorem.

**Ambition.** 🔬 Solid extension.

---

## Direction 3: Dynamic Negative Dependence Certification

**Conjecture.** If a homogeneous polynomial $f$ with nonneg coefficients is Lorentzian, and $f' = f + c X^\alpha$ preserves nonnegativity and the Lorentzian property at all affected certificate nodes, then $f'$ is also Lorentzian, and the induced distribution on bases retains the negative association property.

**Test.** For graphic matroids on random graphs, verify that:
1. All affected Hessian leaves maintain Lorentzian signature after each update.
2. The negative correlation inequality $\text{Cov}(e \in T, e' \in T) \le 0$ holds empirically for all edge pairs $(e, e')$ after each update.
Falsification: find an update where negative correlation fails despite the certificate passing.

**Impact.** Negative dependence is the gateway to concentration inequalities, correlation decay, and algorithmic applications (Chernoff bounds for dependent random variables). Dynamic certification of negative dependence would enable online guarantees for these properties.

**Catalog References.** `Catalog/Bridges/LorentzianRecognition.lean` (`IsRecursivelyLorentzian`, `pderiv_isHomogeneous_degree_pred`), `Pythagorean/DynamicLorentzianCertificates.lean` (all theorems).

**Proof Strategy.** Use the locality theorem to reduce to checking only affected leaves. For those leaves, verify the spectral condition. The challenge is proving that the spectral condition at individual leaves implies the global Lorentzian property — this requires formalizing the "certificate implies Lorentzian" direction more carefully.

**Domain Bridges.** Negative dependence theory, determinantal point processes, concentration of measure.

**Lineage.** Combines locality theorem + LorentzianRecognition soundness theorem.

**Ambition.** 🌟 Grand challenge — proving the preservation of Lorentzianness under certified updates would be a major theoretical advance.

---

## Direction 4: Practical Streaming Matroid Sampler

**Conjecture.** A streaming matroid sampler based on dynamic Lorentzian certificates can maintain approximate samples from the basis distribution with $O(n^{s+2})$ work per edge update (where $s$ is the update sparsity), compared to $O(n^d)$ for full resampling, while maintaining $\varepsilon$-approximate sampling guarantees.

**Test.** Implement a streaming sampler for graphic matroids:
1. Initialize with a random spanning tree.
2. For each edge update, perform dynamic certificate maintenance and warm-start sampling.
3. Measure: (a) wall-clock time per update vs. full resample, (b) empirical distribution quality vs. exact distribution, (c) memory usage.
Test on graphs with $n \in \{50, 100, 500, 1000\}$ vertices.

**Impact.** This would be the first practical streaming matroid sampler with provable guarantees, applicable to network reliability, random spanning tree generation, and online combinatorial optimization.

**Catalog References.** `Pythagorean/DynamicLorentzianCertificates.lean` (all theorems), `Catalog/Pythagorean/CertificateSampling.lean` (`certificate_sampling_efficiency`).

**Proof Strategy.** Combine dynamic certificate maintenance with the warm-start mixing bound. The practical implementation requires:
1. Efficient affected-set enumeration (backtracking with pruning)
2. Incremental Hessian spectral tests (rank-1 matrix updates)
3. Warm-start Metropolis-Hastings with the TV bound as acceptance criterion

**Domain Bridges.** Streaming algorithms, network science, randomized algorithms, systems engineering.

**Lineage.** Practical instantiation of the full theory.

**Ambition.** 🔬 Solid extension — engineering-heavy but theoretically grounded.

---

## Direction 5: Partition Function Stability in Statistical Physics

**Conjecture.** For ferromagnetic spin systems whose partition function is a Lorentzian polynomial (including the Ising model below critical temperature and the random cluster model), rank-1 energy perturbations (changing one coupling constant) induce partition function changes that are controlled by the dynamic certificate locality bound:
$$\left|\frac{Z'}{Z} - 1\right| \le \frac{|c| \cdot \text{dynamicCertificateCost}}{Z}$$
Furthermore, the equilibrium correlation functions change only in a neighborhood of the perturbed coupling, with a decay rate governed by the certificate tree structure.

**Test.** Simulate the 2D Ising model on $L \times L$ lattices ($L \in \{10, 20, 50\}$) at subcritical temperature. Perturb one coupling constant by $\delta J$ and measure:
1. Partition function ratio $Z'/Z$ (via thermodynamic integration)
2. Correlation function changes at distance $r$ from the perturbation
3. Dynamic certificate cost for the corresponding polynomial update
Falsification: if the correlation change at large distance exceeds the certificate-based prediction.

**Impact.** This would establish the first rigorous connection between Lorentzian certificate structure and correlation decay in statistical physics, potentially yielding new cluster expansion bounds and algorithmic applications for partition function computation.

**Catalog References.** `Pythagorean/DynamicLorentzianCertificates.lean` (`rankOneUpdate_isHomogeneous`, `normalizedCoeffDist_tv_bound`).

**Proof Strategy.** Identify the partition function of the spin system as a Lorentzian polynomial (known for ferromagnetic models via the FKG inequality). Apply the warm-start TV bound to the Gibbs measure. The key insight is that the "distance" in the certificate tree corresponds to geometric distance in the lattice, so locality in the certificate implies spatial locality of correlation changes.

**Domain Bridges.** Statistical physics, lattice models, cluster expansions, computational phase transitions.

**Lineage.** Extends warm-start TV bound to physics setting.

**Ambition.** 🌟 Grand challenge — bridging algebraic combinatorics and statistical physics through certificate structure would be paradigm-shifting.
