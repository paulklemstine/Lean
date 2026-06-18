# Future Directions: Lorentzian Condition Number Theory

## Synthesis

The Lorentzian condition number κ(f) establishes a quantitative bridge between the algebraic geometry of Lorentzian polynomials and algorithmic performance. Our formalization proves that κ controls perturbation stability (Theorem 1), recovers known matroid stability radii as a calibration case (Theorem 2), and provides curvature surrogates relevant to MCMC mixing (Theorem 3). These results open five specific research directions, ranging from immediate extensions within the Catalog framework to paradigm-shifting conjectures that could unite algebraic combinatorics with computational complexity theory. The unifying theme is that **spectral geometry of quadratic leaves is a universal predictor of both robustness and tractability**.

---

## Direction 1: Tight Norm Conversion and Optimal Stability Radii

**Conjecture:** For the uniform matroid U_{r,m}, the true stability radius in entry norm is Θ(1/m), not 1/m². The factor-of-m gap arises from the suboptimal n²-factor in the entry-to-quadratic-form conversion, and can be closed by exploiting the structure of the Hessian perturbation (specifically, that perturbations of J−I have correlated entries when they arise from coefficient perturbations of e_r).

**Test:** Compute the empirical stability radius for uniform matroids with m = 5, 10, 20, 50 by binary search over random perturbation magnitudes. Compare with 1/m and 1/m². If the empirical radius scales as 1/m, the conjecture is supported. If it scales as 1/m², the current bound is already tight.

**Impact:** A tight norm conversion would improve all downstream certified radii by a polynomial factor. This is immediately useful for certified numerical computation with matroid invariants.

**Catalog References:**
- `Catalog/Pythagorean/LorentzianConditionNumber.lean` — `quadFormBound_of_entry_bound`
- `Catalog/Pythagorean/UniformMatroidLorentzianStability.lean` — `stability_radius_from_entries`

**Proof Strategy:** Replace the generic AM-GM bound |v_i · v_j| ≤ (v_i² + v_j²)/2 with a structure-aware bound that exploits the Cauchy-Schwarz inequality directly. For the uniform matroid, the key is that coefficient perturbations of e_r induce rank-1 or low-rank Hessian perturbations, not arbitrary symmetric perturbations.

**Domain Bridges:** Numerical analysis (optimal conditioning theory), randomized algorithms (improved certified sampling budgets).

**Lineage:** Direct extension of `quadFormBound_of_entry_bound` and `uniform_matroid_stability_radius_m_squared`.

**Ambition:** Solid extension — provable within the current framework with a more careful analysis.

**The key insight is** that the n² conversion factor is a worst-case bound over all matrices, but Hessian perturbations arising from coefficient changes have algebraic structure that reduces the effective conversion factor.

**Why now?** The current formalization provides the exact framework (LeafSpectralData, CertifiedConditionBound) needed to state and prove tighter bounds. The gap between 1/m and 1/m² is computationally measurable.

---

## Direction 2: Condition-Number-Controlled Mixing Times (Grand Challenge)

**Conjecture:** For any Lorentzian polynomial f of degree d in n variables with condition number κ(f), the Glauber dynamics (basis-exchange walk) on the support of f mixes in time O(κ(f) · n · log(n/ε)) to within total variation distance ε of the stationary distribution.

**Test:** Implement the Glauber dynamics for uniform matroids with m = 5, 10, 20. Measure the empirical mixing time (using the second-largest eigenvalue of the transition matrix for small m, or coupling-from-the-past for large m). Plot mixing time vs κ = m−1. If the relationship is linear with logarithmic corrections, the conjecture is supported.

**Impact:** This would be the first quantitative theorem connecting a *computable algebraic invariant* of a polynomial to the *computational complexity* of sampling from its associated distribution. It would make condition-number theory actionable for algorithm design.

**Catalog References:**
- `Catalog/Pythagorean/LorentzianConditionNumber.lean` — `LocalContractionSurrogate`, `local_contraction_bound`
- `Catalog/Speculative/AutoResearch/LorentzianStability.lean` — `strong_concavity_on_orthogonal_complement`

**Proof Strategy:** 
1. Prove that 1/κ lower-bounds the spectral gap of the log-Hessian restricted to positive slices.
2. Use a Bakry-Émery-type argument to transfer this curvature bound to a Poincaré inequality.
3. Deduce a mixing time bound via the standard spectral gap → mixing time theorem.

The key technical challenge is formalizing the Bakry-Émery criterion in the discrete setting. A possible shortcut is to use the modified log-Sobolev inequality framework of [ALOGV19].

**Domain Bridges:** Probability theory (Markov chain mixing), statistical physics (Glauber dynamics), optimization (sampling-based algorithms), machine learning (probabilistic inference).

**Lineage:** Extends `local_contraction_bound` from a static curvature bound to a dynamic mixing guarantee.

**Ambition:** Grand challenge — would require formalizing substantial MCMC theory, but the conceptual path is clear.

**The key insight is** that the contraction surrogate 1/κ is precisely the curvature parameter that enters Bakry-Émery-type mixing time bounds, so the algebraic condition number directly predicts computational complexity.

**Why now?** The formalization of the contraction surrogate provides a clean, verified starting point. The MCMC mixing theory of [ALOGV19] provides the target framework. The gap is "only" the formal connection.

---

## Direction 3: Non-Uniform Matroid Condition Numbers

**Conjecture:** For the graphic matroid of a connected graph G on n vertices, the Lorentzian condition number satisfies κ(M(G)) ≤ n · λ₁(G) / λ₂(G), where λ₁ and λ₂ are the largest and second-largest eigenvalues of the Laplacian.

**Test:** Compute condition numbers for graphic matroids of:
- Complete graphs K_n (should match uniform matroid)
- Path graphs P_n (expected: high κ due to poor expansion)
- Cycle graphs C_n (intermediate)
- Random Erdős-Rényi graphs G(n, p) for various p

Plot κ vs Laplacian spectral ratio. If the correlation is strong and the upper bound holds, the conjecture is supported.

**Impact:** Would extend the theory from the single calibration case (uniform matroid) to the entire class of graphic matroids, connecting Lorentzian conditioning to spectral graph theory.

**Catalog References:**
- `Catalog/Pythagorean/LorentzianConditionNumber.lean` — `CertifiedConditionBound`, `LeafSpectralData`
- `Catalog/Pythagorean/UniformMatroidLorentzianStability.lean` — `leafHessian_decomposition`

**Proof Strategy:** For graphic matroids, the quadratic leaf Hessians are principal submatrices of weighted Laplacians. The spectral gap of these submatrices can be bounded using Cauchy interlacing and the Laplacian spectrum of G.

**Domain Bridges:** Spectral graph theory, network analysis, algebraic graph theory.

**Lineage:** Generalizes `uniform_leaf_gap_one` and `uniform_leaf_opnorm_bound` from complete graphs to arbitrary graphs.

**Ambition:** Solid extension — the spectral theory of graph Laplacians is well-developed and the connection to quadratic leaves is structural.

**The key insight is** that the leaf Hessian J−I of the uniform matroid is the Laplacian of the complete graph, so the spectral gap = algebraic connectivity connection extends to all graphic matroids.

**Why now?** The formalization infrastructure (LeafSpectralData, CertifiedConditionBound) is ready to accept new matroid families. The spectral graph theory needed is classical.

---

## Direction 4: Tropical Condition Numbers and Valuated Matroids (Grand Challenge)

**Conjecture:** There exists a tropical analogue of the Lorentzian condition number, defined via the piecewise-linear geometry of tropical polynomials, that controls both perturbation stability in the tropical semiring and convergence of tropical sampling algorithms.

**Test:** Define a "tropical spectral gap" as the minimum slope change at a breakpoint of a tropical quadratic form. Compute this for tropical uniform matroids (which are matroid polytopes). Test whether this quantity predicts the stability of the tropical Lorentzian property under perturbation of tropical coefficients.

**Impact:** Would extend the condition-number framework from classical algebra to tropical geometry, opening connections to optimization (tropical linear programming), phylogenetics (tropical tree spaces), and algebraic statistics.

**Catalog References:**
- `Catalog/Pythagorean/LorentzianConditionNumber.lean` — conceptual framework
- `Catalog/Tropical/` — existing tropical algebra formalization

**Proof Strategy:** 
1. Define tropical quadratic leaves via the second derivative of the tropical polynomial (the "tropical Hessian").
2. Define the tropical spectral gap as the minimum over all tropical leaves of the gap in the induced piecewise-linear form.
3. Prove that tropical coefficient perturbations smaller than the tropical gap preserve tropical Lorentzianity.

**Domain Bridges:** Tropical geometry, optimization (linear programming duality), computational biology (phylogenetic inference), information theory (rate-distortion theory).

**Lineage:** Conceptual transfer of the κ(f) framework to the tropical setting.

**Ambition:** Grand challenge — requires developing substantial tropical spectral theory from scratch.

**The key insight is** that the tropicalization of the condition number should correspond to the minimum slack in the tropical Lorentzian inequalities, which has a clean piecewise-linear interpretation.

**Why now?** Tropical Lorentzian polynomials have been recently defined (Brändén-Huh), and the Catalog already contains tropical algebra formalizations. The condition number framework provides the right conceptual lens.

---

## Direction 5: Certified Robustness for Log-Concave Generative Models

**Conjecture:** For a generative model whose probability distribution is defined by a Lorentzian polynomial f (e.g., determinantal point processes, strongly Rayleigh distributions), the certified perturbation radius 1/(n²·κ(f)) provides a provable adversarial robustness guarantee: any adversarial perturbation of the model parameters within this radius preserves the qualitative properties (log-concavity, negative association, stochastic dominance) of the generated samples.

**Test:** Train a determinantal point process (DPP) model on a subset selection task. Compute κ of the learned kernel polynomial. Test whether adversarial perturbations of the kernel entries within the certified radius preserve the quality of generated subsets (measured by diversity, coverage, and negative association).

**Impact:** Would provide the first *provable* robustness certificates for an important class of structured probabilistic models, connecting algebraic combinatorics to trustworthy AI.

**Catalog References:**
- `Catalog/Pythagorean/LorentzianConditionNumber.lean` — `lorentzian_perturbation_radius_of_condition`, `certified_radius_from_algorithm`
- `Catalog/Speculative/AutoResearch/LorentzianStability.lean` — `certifyStability_sound`

**Proof Strategy:** 
1. Show that the DPP kernel polynomial is Lorentzian (this is known for L-ensembles).
2. Compute the condition number from the kernel eigenvalues.
3. Apply the certified perturbation theorem to guarantee that adversarial perturbations preserve Lorentzianity.
4. Use the preserved Lorentzian structure to deduce preservation of log-concavity and negative association.

**Domain Bridges:** Machine learning (adversarial robustness, trustworthy AI), information theory (entropy preservation), statistical mechanics (lattice gas models).

**Lineage:** Applies `lorentzian_perturbation_radius_of_condition` to learned models.

**Ambition:** Solid extension with high applied impact — the mathematical ingredients are available, and the application to DPPs is immediate.

**The key insight is** that adversarial robustness of structured probabilistic models can be reduced to perturbation stability of their defining polynomials, which is exactly what the Lorentzian condition number quantifies.

**Why now?** DPPs are increasingly used in machine learning for diverse subset selection. The need for robustness certificates is growing as these models are deployed in safety-critical applications.
