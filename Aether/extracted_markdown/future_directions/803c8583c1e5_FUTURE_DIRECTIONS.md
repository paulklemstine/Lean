# Future Directions: Sharp Lorentzian Stability Theory

## Synthesis

The discovery that Lorentzian stability scales as 1/n rather than 1/n² reveals a fundamental principle: the perturbation geometry of Lorentzian cones is governed by operator-norm phenomena, not entry-by-entry accumulation. This opens five interconnected research programs that span algebraic combinatorics, random matrix theory, representation theory, numerical optimization, and statistical physics. The unifying thread is that each direction seeks to identify the *true geometric mechanism* controlling stability, whether through probabilistic concentration (Direction 1), symmetry decomposition (Direction 2), algorithmic certification (Direction 3), physical robustness (Direction 4), or structural invariants (Direction 5). Together, they aim to transform Lorentzian stability from a single sharp inequality into a complete quantitative theory.

---

## Direction 1: Probabilistic Stability — The 1/√n Law for Random Perturbations

**Conjecture:** For random symmetric perturbations with i.i.d. mean-zero entries bounded by δ, the Lorentzian signature is preserved with high probability whenever δ ≤ K · ε / √n, where K is a universal constant.

**Test:** Compute survival probabilities for random perturbations of e_k Hessians at scale δ = ε / n^α for α ∈ {0.4, 0.5, 0.6, 0.7} and dimensions n ∈ {10, 50, 100, 500}. If the critical α is 0.5 ± 0.02, the conjecture is confirmed. If α stabilizes near 0.6 or higher, the conjecture needs revision.

**Impact:** A factor-of-√n improvement over the deterministic bound would make certified stochastic algorithms (e.g., randomized rounding, MCMC samplers) dramatically more efficient. It would connect Lorentzian combinatorics directly to random matrix universality.

**Catalog References:** `Catalog/Pythagorean/LorentzianSharpStability.lean` (Theorems 2-3), `Catalog/Speculative/AutoResearch/LorentzianStability.lean` (Theorem 9)

**Proof Strategy:** Use the Wigner semicircle law or matrix Bernstein inequality to bound the spectral radius of the random perturbation matrix. The key step: show that the random perturbation's operator norm concentrates at O(√n · δ) rather than worst-case O(n · δ), then apply the gapped-signature perturbation theorem.

**Domain Bridges:** Random matrix theory (GOE/GUE universality), high-dimensional probability (matrix concentration), statistical physics (random coupling constants).

**Lineage:** Extends `quadFormBound_of_entry_bound_sharp` from deterministic to probabilistic setting.

**Ambition:** Grand challenge — would establish first probabilistic stability theory for Lorentzian cones.

---

## Direction 2: Effective Spectral Dimension via Representation Theory

**Conjecture:** For the elementary symmetric polynomial e_k(x₁,...,xₙ) under S_n symmetry, the effective spectral dimension is O(1) (independent of n), yielding an O(1/1) = O(1) stability constant for symmetric perturbations.

**The key insight is** that S_n-symmetric perturbations of a symmetric polynomial decompose into O(1) irreducible representations (the trivial and standard representations of S_n), so only O(1) "effective directions" matter in the Hessian perturbation.

**Why now?** The sharp 1/n bound for generic perturbations is now established, so the natural next question is whether structured perturbations can do better. The representation-theoretic machinery is available in Mathlib.

**Test:** For e_k with k = 2, 3, 4, compute the destruction threshold for (a) generic perturbations and (b) S_n-symmetric perturbations. If symmetric perturbations have threshold Θ(ε) independent of n while generic ones have threshold Θ(ε/n), the conjecture is confirmed.

**Impact:** Would explain why symmetric families (e_k, matroid basis polynomials) seem much more stable than the worst case suggests. Would create a "representation stability" theory for Lorentzian polynomials.

**Catalog References:** `Catalog/Pythagorean/LorentzianSharpStability.lean` (EffectiveSpectralDimension definition)

**Proof Strategy:** Decompose the space of symmetric perturbations into S_n isotypic components. Show that the Hessian perturbation's quadratic form, restricted to each component, is controlled by the component's dimension (which is O(1) for the trivial and O(n) for the standard representation). The total effective dimension is the sum over relevant components.

**Domain Bridges:** Representation theory (symmetric group representations), algebraic combinatorics (Schur functors), invariant theory.

**Lineage:** Builds on `EffectiveSpectralDimension` structure defined in `LorentzianSharpStability.lean`.

**Ambition:** Solid extension — exploits existing symmetry in the most natural way.

---

## Direction 3: Certified Adaptive Algorithms for Lorentzian Recognition

**Conjecture:** There exists an O(n² log(1/ε)) algorithm that, given a polynomial with coefficients known to precision δ, either certifies it as Lorentzian or reports that certification is impossible at this precision — with the decision boundary matching the sharp 1/n constant.

**The key insight is** that the certified perturbation radius ε/n can be computed in O(n³) time (eigenvalue decomposition) but the *adaptive* version — which checks multiple quadratic leaves and selects the tightest bound — can be parallelized and early-terminated.

**Why now?** The sharp constant makes the certified radius large enough to be practically useful, so the algorithmic question becomes relevant for the first time.

**Test:** Implement the adaptive algorithm and benchmark against naive (check-all-leaves) certification on matroid basis polynomials with n ∈ {10, 50, 100}. Measure speedup and certifiable dimension range.

**Impact:** Would produce the first practical certified Lorentzian recognizer, enabling verified combinatorial optimization and log-concavity testing.

**Catalog References:** `Catalog/Pythagorean/LorentzianSharpStability.lean` (certifiedPerturbationRadius, certifiedPerturbationRadius_sound)

**Proof Strategy:** Formalize the adaptive leaf-selection strategy, prove correctness using the certified radius theorem, and bound the number of leaves that need checking via matroid-theoretic arguments.

**Domain Bridges:** Numerical linear algebra (structured eigenvalue problems), optimization (semidefinite programming), computer science (certified algorithms).

**Lineage:** Extends `certifiedPerturbationRadius_sound` to an adaptive, multi-leaf setting.

**Ambition:** Solid extension — algorithmic realization of the theoretical bound.

---

## Direction 4: Stability of Partition Functions Under Noisy Couplings

**Conjecture:** For the partition function Z(J) = ∑_σ exp(-β ∑_{ij} J_{ij} σ_i σ_j) of an Ising model with Lorentzian coupling structure, perturbations of couplings |ΔJ_{ij}| ≤ ε/(βn) preserve the log-concavity of the partition function as a polynomial in external fields.

**The key insight is** that the Hessian of log Z with respect to external fields is controlled by the Lorentzian stability of the generating polynomial, and the sharp 1/n constant translates directly to coupling robustness.

**Why now?** The connection between Lorentzian polynomials and partition functions is established (Anari et al., 2019), and the sharp stability constant makes the quantitative translation meaningful for physical systems.

**Test:** Compute the partition function of the complete graph Ising model for n ∈ {4, 6, 8, 10, 12} and verify that coupling perturbations of size O(ε/n) preserve log-concavity of the magnetization polynomial.

**Impact:** Would provide rigorous robustness guarantees for phase transition detection in noisy physical systems, connecting Lorentzian geometry to experimental physics.

**Catalog References:** `Catalog/Pythagorean/LorentzianSharpStability.lean` (dimension_degree_stability_law_linear), `Catalog/Speculative/AutoResearch/LorentzianStability.lean` (strong_concavity_on_orthogonal_complement)

**Proof Strategy:** Express the partition function's Hessian in terms of the coupling matrix's Hessian, apply the sharp stability theorem, and translate the coefficient perturbation bound into a coupling perturbation bound via the chain rule.

**Domain Bridges:** Statistical physics (Ising models, phase transitions), probability (log-concave distributions), quantum information (quantum Boltzmann machines).

**Lineage:** Extends the stability theory from abstract polynomials to physical partition functions.

**Ambition:** Grand challenge — would be the first application of sharp Lorentzian stability to physics.

---

## Direction 5: Obstruction Theory — Lower Bounds via Extremal Constructions

**Conjecture:** For every degree d ≥ 2, there exist explicit constants a_d, b_d > 0 such that the optimal stability constant C(n,d) satisfies a_d/n ≤ C(n,d) ≤ b_d/n for all n ≥ d, and the extremal family achieving the lower bound is (up to symmetry) the elementary symmetric polynomial e_{d/2}.

**The key insight is** that the destruction threshold for e_k is determined by the spectral gap of a matrix with known eigenvalues (the Johnson scheme), so exact asymptotics can be computed.

**Why now?** The upper bound b_d/n is now established. The matching lower bound requires constructing explicit adversarial perturbations, which is now guided by the operator-norm perspective.

**Test:** For d = 2, 3, 4, compute the exact destruction threshold for e_k and verify that n · C_{e_k}(n,k) converges to a specific constant as n → ∞.

**Impact:** Would complete the sharp characterization of the stability landscape, determining the exact leading constant for each degree.

**Catalog References:** `Catalog/Pythagorean/LorentzianSharpStability.lean` (all_ones_achieves_linear_bound, linear_bound_is_tight)

**Proof Strategy:** For the lower bound, construct perturbations aligned with the top eigenspace of the Hessian. For the upper bound, use the sharp quadratic form bound. The matching requires careful analysis of the spectral decomposition of the e_k Hessian under the Johnson scheme.

**Domain Bridges:** Extremal combinatorics, association schemes, algebraic graph theory.

**Lineage:** Builds on `linear_bound_is_tight` (which handles the B = 1 case) toward the general degree case.

**Ambition:** Solid extension — natural completion of the sharp stability program.
