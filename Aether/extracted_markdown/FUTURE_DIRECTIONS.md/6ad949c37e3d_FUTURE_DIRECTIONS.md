# Future Directions: Tropical Shadows of Lorentzian Stability

## Synthesis

The tropical shadow framework established here reveals that Lorentzian stability — an analytic property of quadratic forms — has a combinatorial skeleton encoded by exchange inequalities on logarithmic weights. This synthesis opens at least five research directions spanning tropical geometry, optimization, statistical physics, and matroid theory. The unifying thread is that *spectral properties of structured matrices can be read from combinatorial invariants of their log-transform*, and this reading becomes asymptotically exact under Maslov dequantization. Each direction below tests a specific aspect of this principle.

---

## Direction 1: Higher-Dimensional Tropical Bridge

**Conjecture.** For an n×n exp-weight matrix with all diagonal exchange slacks nonneg (δ(i,j) ≥ 0 for all i ≠ j), the matrix has at most one positive eigenvalue.

**Test.** Construct random n×n weight matrices with all δ(i,j) ≥ 0 for n = 3, 5, 10, 20. Compute eigenvalues of the exp-weight matrix. If any matrix has two or more positive eigenvalues, the conjecture is false.

**Impact.** If true, this would extend the 2×2 bridge theorem to arbitrary dimension, providing a complete tropical certification of Lorentzian polynomials. This would make the O(n²) gap computation sufficient for certification in any dimension, replacing O(n³) eigenvalue decomposition.

**Catalog References.** `Pythagorean/TropicalLorentzianShadows.lean` (Theorems 1-3), `Catalog/Speculative/AutoResearch/LorentzianStability.lean` (UniformSpectralMargin)

**Proof Strategy.** Strategy A (quadratic-leaf reduction): Show that nonneg diagonal exchange slacks on all 2×2 submatrices implies the full matrix has at most one positive eigenvalue, by induction on dimension using Cauchy interlacing. Strategy B: Use the tropical Plücker relations (general exchange slack nonneg) as the stronger hypothesis and connect to the theory of M-convex functions.

**Domain Bridges.** Matroid theory (exchange axioms), tropical linear algebra (tropical eigenvalues), convex optimization (log-concavity)

**Lineage.** Extends Theorem 3.4 (tropical_lorentzian_bridge, Fin 2 case) to general finite types.

**Ambition.** Grand challenge — would complete the tropical certificate theory for Lorentzian polynomials.

---

## Direction 2: Tropical Stability Radius Asymptotics

**Conjecture.** For any positive-entry symmetric weight w and rescaling direction ω:

lim_{t→∞} log(StabRad(exp(w + tω))) / t = min_{i≠j} δ_ω(i,j)

where StabRad is the entry-wise perturbation tolerance for preserving Lorentzianity.

**Test.** For uniform families (n = 3,...,20) and random ω, compute StabRad numerically (by binary search on perturbation magnitude with eigenvalue checking) and compare log(StabRad)/t against min δ_ω for t ∈ {1, 2, 5, 10, 50, 100}.

**Impact.** Proves that tropical geometry captures the exact asymptotic stability threshold under Maslov dequantization. This would be the first rigorous "zero-temperature limit" theorem connecting tropical invariants to analytic stability radii.

**Catalog References.** `Pythagorean/TropicalLorentzianShadows.lean` (rescale_tropical_gap_linear, maslov_conjecture_tropical_part), `Catalog/Speculative/AutoResearch/LorentzianStability.lean` (lorentzian_stability_radius_exists)

**Proof Strategy.** Strategy C (uniform first, then extend): Prove exact equality for uniform models using the closed-form gap formula. Then establish semicontinuity of the stability radius as a function of weights, giving the inequality in one direction. The reverse inequality uses compactness and the explicit bridge identity.

**Domain Bridges.** Statistical physics (zero-temperature limits, ground-state dominance), information theory (rate-distortion asymptotics), numerical analysis (condition number asymptotics)

**Lineage.** Builds on Theorem 3.10 (rescaling linearity) and the grand conjecture.

**Ambition.** Grand challenge — paradigm-shifting if proven, as it would establish tropical methods as the correct framework for asymptotic stability analysis.

---

## Direction 3: Valuated Matroid Exchange Certificates

**Conjecture.** For a valuated matroid (E, w) with basis exchange property, the tropical spectral gap of the quadratic leaf Hessian equals the minimum exchange defect in the matroid:

tropGap = min_{B₁, B₂, i, j} [w(B₁) + w(B₂) - w(B₁ - i + j) - w(B₂ + i - j)]

where the minimum is over all pairs of bases B₁, B₂ and exchange elements i ∈ B₁\B₂, j ∈ B₂\B₁.

**Test.** Compute both quantities for graphical matroids of small graphs (K₄, K₅, Petersen graph, random graphs on 6-8 vertices) and compare.

**Impact.** Establishes tropical spectral gaps as matroid invariants, making them accessible to the extensive algorithmic toolkit of matroid optimization (greedy algorithms, matroid intersection, etc.).

**Catalog References.** `Pythagorean/TropicalLorentzianShadows.lean` (exchangeSlack_diag, tropical_gap_certificate_exists), `Catalog/Pythagorean/LorentzianExchangeCertificates.lean`

**Proof Strategy.** For rank-2 matroids, the quadratic leaf Hessian is directly the basis weight matrix, and the exchange defect is the diagonal exchange slack. For higher rank, use the Cauchy-Binet formula to express quadratic leaf entries in terms of basis weights.

**Domain Bridges.** Combinatorial optimization (polynomial-time certification), algebraic combinatorics (matroid theory), tropical geometry (tropical Grassmannians)

**Lineage.** Extends the certificate theorem (Theorem 3.8) to the matroid setting.

**Ambition.** Solid extension — connects established matroid theory with the new tropical stability framework.

---

## Direction 4: Phase Transitions in Tropical Stability

**Conjecture.** For random symmetric weight matrices drawn from a Gaussian ensemble with mean μ and variance σ², the probability that tropGap(w) ≥ 0 (i.e., the exp-weight matrix is Lorentzian at all 2×2 submatrices) undergoes a sharp phase transition at a critical signal-to-noise ratio:

P(tropGap ≥ 0) → 1 when μ_off - μ_diag > c·σ·√(log n)
P(tropGap ≥ 0) → 0 when μ_off - μ_diag < c·σ·√(log n)

for a universal constant c.

**Test.** Sample 10,000 random weight matrices for each (n, μ, σ) with n ∈ {5, 10, 20, 50} and plot the Lorentzian probability as a function of (μ_off - μ_diag)/(σ·√(log n)). If the curves collapse to a single transition, the conjecture is supported.

**Impact.** Characterizes the "typical" difficulty of Lorentzian certification in random models, relevant for average-case complexity analysis and for understanding when tropical certificates are most useful.

**Catalog References.** `Pythagorean/TropicalLorentzianShadows.lean` (tropical_gap_eq_uniform, exchange_slack_lipschitz)

**Proof Strategy.** The tropical gap is the minimum of O(n²) Gaussian random variables (each diagonal exchange slack is a linear combination of Gaussian entries). Use extreme value theory for correlated Gaussians, specifically the Slepian-Fernique inequality, to bound the expected minimum.

**Domain Bridges.** Statistical physics (phase transitions, percolation), random matrix theory (extreme eigenvalue statistics), machine learning (random feature models)

**Lineage.** New direction inspired by the Lipschitz stability theorem (Theorem 3.6).

**Ambition.** Solid extension — applies existing probabilistic tools to the tropical framework.

---

## Direction 5: Tropical Spectral Certificates for Neural Network Robustness

**Conjecture.** For ReLU neural networks whose layer weight matrices have Lorentzian quadratic leaves, the tropical spectral gap of the Hessian at critical points provides a lower bound on the adversarial perturbation radius:

robust_radius(x) ≥ C · exp(tropGap(Hessian(x))) / ‖gradient(x)‖

**Test.** Train small (2-layer, width 20-100) ReLU networks on MNIST/CIFAR-10. At each test point, compute the Hessian's tropical gap and compare against the empirical adversarial radius (found by PGD attack).

**Impact.** Would provide the first non-trivial certified robustness bound that is *computationally cheaper* than eigenvalue-based methods (O(d²) vs O(d³) for d-dimensional Hessians) and *tighter* than Lipschitz-based bounds in regions with favorable curvature structure.

**Catalog References.** `Pythagorean/TropicalLorentzianShadows.lean` (tropical_to_stability_bridge), `Catalog/MachineLearning/TropicalCertifiedRobustness.lean`, `Catalog/Speculative/AutoResearch/LorentzianStability.lean` (quadFormBound_of_entry_bound)

**Proof Strategy.** Use the stability radius lower bound (Theorem 3.7) on the Hessian at critical points, combined with the quadratic approximation of the loss landscape. The gap between quadratic approximation and true loss is controlled by third-order terms, which can be bounded for ReLU networks using tropical analysis of the piecewise-linear structure.

**Domain Bridges.** Machine learning (adversarial robustness, certified defense), optimization (trust-region methods, saddle-point avoidance), signal processing (robust estimation)

**Lineage.** Extends the stability-to-tropical bridge (Theorem 3.7) to the applied setting.

**Ambition.** Grand challenge — would bridge pure mathematics and practical ML robustness in a novel way.
