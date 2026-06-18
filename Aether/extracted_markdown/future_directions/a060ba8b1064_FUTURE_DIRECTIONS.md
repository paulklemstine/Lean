# Future Directions: Lorentzian MCMC

## Synthesis

The results established here — connecting Lorentzian curvature to spectral gaps for discrete dynamics — represent the first step in a broader program. The core mechanism (algebraic curvature → variance contraction → mixing) is universal and should apply far beyond the Ising setting. The five directions below form a coherent research arc: Direction 1 deepens the theory within statistical mechanics, Direction 2 strengthens the functional inequality, Direction 3 bridges to quantum systems, Direction 4 connects to optimization, and Direction 5 opens the door to information-theoretic applications. Together, they constitute a roadmap for developing Lorentzian curvature into a general-purpose tool for controlling stochastic and quantum dynamics.

---

## Direction 1: Lorentzian Control of Interacting Particle Systems

**Conjecture:** For interacting particle systems on general graphs (not just complete graphs), the Lorentzian gap of the *graph-weighted* partition function controls the mixing time of the associated Glauber dynamics. Specifically, if the weighted Hessian ∇²log Z restricted to the orthogonal complement of the density direction has eigenvalues ≤ -ε, then the spectral gap of single-site dynamics is ≥ ε/(d_max · n) where d_max is the maximum degree.

**Test:** Formalize the graph-weighted version of `LorentzianGapCertificate` that incorporates graph structure. Prove the spectral gap bound for tree graphs (where exact conditional variance decomposition is available) and test computationally on random regular graphs of degree 3, 5, and 10. Compare empirical mixing times with the predicted d_max · n / ε scaling.

**Impact:** Would extend the Lorentzian MCMC paradigm from mean-field (complete graph) models to spatially structured systems, covering the vast majority of applications in statistical physics and network science.

**Catalog References:**
- `Catalog/Speculative/AutoResearch/LorentzianStability.lean`: `HasGappedSignature`, `gapped_signature_perturbation_residual`
- `Catalog/Speculative/AutoResearch/LorentzianGlauberMixing.lean`: `GlauberGenerator`, `glauber_gap_stable_under_coupling_perturbation`

**Proof Strategy:** Decompose the variance along the tree structure using the conditional variance formula Var(f) = E[Var(f|subtree)] + Var(E[f|subtree]). The Lorentzian gap controls each conditional variance, and the tree structure provides the inductive framework.

**Domain Bridges:** Statistical mechanics → graph theory, spectral graph theory

**Lineage:** Extends `glauber_gap_stable_under_coupling_perturbation` to structured graphs.

**Ambition:** Grand challenge. Would unify Dobrushin conditions, tree-based decompositions, and Lorentzian geometry.

**The key insight is** that tree-structured conditional variance decompositions provide exactly the right inductive framework for propagating Lorentzian curvature bounds through a graph.

**Why now?** The formal infrastructure for Lorentzian gap certificates and perturbation stability is now in place, and tree decompositions are well-understood in both the probability and formal verification communities.

---

## Direction 2: Lorentzian Modified Log-Sobolev Inequality

**Conjecture:** If the partition function has Lorentzian gap ε, then the Gibbs measure satisfies a modified log-Sobolev inequality (MLSI) with constant O(1/ε), yielding mixing time O(n · log log(1/δ) / ε) — exponentially better than the Poincaré-based bound in the precision parameter δ.

**Test:** Prove the MLSI for product measures (where it is known to hold with constant 1) and verify that the Lorentzian gap condition is sufficient in this base case. Then attempt to extend via the tensorization property of MLSI.

**Impact:** Would provide the strongest possible mixing time bounds from Lorentzian geometry, matching the best known results for log-concave distributions.

**Catalog References:**
- `Catalog/Speculative/AutoResearch/LorentzianGlauberMixing.lean`: `DiscretePoincareCertificate`, `poincare_composition`

**Proof Strategy:** Use the factorization approach of Cesi (2001): decompose the entropy functional along single-site conditioning, bound each conditional entropy using the Lorentzian gap, then aggregate.

**Domain Bridges:** Functional analysis → information theory (entropy methods)

**Lineage:** Strengthens `spectral_gap_from_poincare` from Poincaré to log-Sobolev.

**Ambition:** Solid extension. The MLSI is the natural strengthening of the Poincaré inequality.

**The key insight is** that the Lorentzian gap controls not just the second moment (Poincaré) but the entropy (log-Sobolev) because the curvature bound implies strong convexity of the log-partition function, which is the Bregman divergence generating function.

**Why now?** The entropy factorization framework exists in the probability literature, and the Lorentzian gap provides exactly the right local curvature bound to make it work.

---

## Direction 3: Quantum Lorentzian Thermalization

**Conjecture:** For quantum spin systems with Hamiltonian H, if the Hessian of the quantum free energy F(β) = -log Tr(e^{-βH}) / β has Lorentzian gap ε in the coupling parameters, then the quantum Gibbs sampler (Lindbladian dynamics) has spectral gap ≥ ε / poly(n).

**Test:** Verify computationally for the transverse-field Ising model on small systems (n = 4, 6, 8) by computing both the quantum free energy Hessian and the Lindbladian spectral gap, and checking whether the predicted relationship holds.

**Impact:** Would establish the first algebraic-geometric criterion for quantum thermalization, potentially resolving open questions about the efficiency of quantum Gibbs sampling.

**Catalog References:**
- `Catalog/Speculative/AutoResearch/LorentzianStability.lean`: `strong_concavity_on_orthogonal_complement`, `reversed_cauchy_schwarz_of_gapped`

**Proof Strategy:** Adapt the classical covariance-to-Poincaré pipeline to the quantum setting using the KMS inner product and quantum conditional expectations. The Lorentzian gap of the classical partition function should control the quantum covariance via the Bogoliubov inner product.

**Domain Bridges:** Algebraic combinatorics → quantum information, quantum thermodynamics

**Lineage:** Extends the entire `LorentzianGlauberMixing` pipeline to the quantum setting.

**Ambition:** Grand challenge. Would open "Quantum Lorentzian MCMC."

**The key insight is** that the quantum free energy is a natural generalization of the classical log-partition function, and its Hessian controls quantum fluctuations just as the classical Hessian controls classical covariances.

**Why now?** Quantum Gibbs sampling algorithms are under intense development (e.g., for quantum computing applications), and there is no algebraic-geometric framework for certifying their convergence.

---

## Direction 4: Lorentzian Certificates for Discrete Optimization

**Conjecture:** For combinatorial optimization problems whose feasible solutions can be encoded as spin configurations, a Lorentzian gap in the "softened" partition function Z_β(J) = ∑_σ e^{-β E(σ)} at inverse temperature β implies that simulated annealing with cooling schedule β(t) = O(ε · t / n) finds a near-optimal solution in polynomial time.

**Test:** Implement and test on MAX-CUT instances for random graphs. Compute the Lorentzian gap of the softened partition function at various temperatures and compare with the actual convergence rate of simulated annealing.

**Impact:** Would provide a new sufficient condition for the tractability of combinatorial optimization, complementing existing approaches based on semidefinite programming relaxations.

**Catalog References:**
- `Catalog/Speculative/AutoResearch/LorentzianGlauberMixing.lean`: `iterated_l2_contraction`, `spectral_gap_from_poincare`
- `Catalog/Speculative/AutoResearch/LorentzianStability.lean`: `lorentzian_stability_radius_exists`

**Proof Strategy:** Combine the iterated contraction theorem with a cooling schedule analysis. At each temperature, the Lorentzian gap provides a mixing time bound. The cooling schedule must be slow enough that the system re-equilibrates at each temperature, but fast enough for polynomial total time.

**Domain Bridges:** Algebraic combinatorics → combinatorial optimization, complexity theory

**Lineage:** Extends `iterated_l2_contraction` to the annealing setting.

**Ambition:** Solid extension with high impact.

**The key insight is** that the Lorentzian gap typically increases with temperature (stronger curvature at higher temperature), providing a natural schedule for simulated annealing that adapts to the problem's geometric structure.

**Why now?** The formal framework for iterated contraction is established, and the connection between spectral gaps and simulated annealing is classical (Holley–Stroock).

---

## Direction 5: Information-Theoretic Capacity from Lorentzian Geometry

**Conjecture:** For discrete memoryless channels whose transition probabilities are parameterized by an Ising model with Lorentzian gap ε, the channel capacity is bounded below by Ω(ε · log n / n), and the capacity-achieving distribution can be found by a Blahut-Arimoto algorithm that converges in O(n/ε) iterations.

**Test:** Compute channel capacities for small symmetric channels (n = 4, 8, 16) parameterized by Ising couplings, verify the predicted capacity lower bound, and measure Blahut-Arimoto convergence rates.

**Impact:** Would connect the Lorentzian MCMC framework to information theory, providing geometric conditions for efficient channel coding.

**Catalog References:**
- `Catalog/Speculative/AutoResearch/LorentzianGlauberMixing.lean`: `lorentzian_free_energy_susceptibility_bound`, `PerturbationStableGap`

**Proof Strategy:** The Blahut-Arimoto algorithm is an alternating minimization for the mutual information, which can be expressed as a KL divergence. The Lorentzian gap controls the strong convexity of the KL divergence in the relevant direction, giving convergence rate bounds via the optimization theory of strongly convex functions.

**Domain Bridges:** Algebraic combinatorics → information theory, coding theory

**Lineage:** Extends `lorentzian_free_energy_susceptibility_bound` to the information-theoretic setting.

**Ambition:** Solid extension bridging to a different domain.

**The key insight is** that channel capacity optimization is a convex problem whose convergence rate is controlled by the curvature of the mutual information functional, which is directly related to the Hessian of the free energy — exactly what the Lorentzian gap measures.

**Why now?** The cross-domain susceptibility bound theorem establishes the formal connection between Lorentzian gaps and free energy curvature, which is the starting point for the information-theoretic extension.
