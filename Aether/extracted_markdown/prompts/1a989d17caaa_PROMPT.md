

=== AEM QUALITY SCORING (MANDATORY GUIDELINES) 



Research Mode: PROVE

Discover and prove new, non-trivial theorems that advance the
mathematical frontier. Start from the existing verified theorems
listed below and extend them into deeper territory. Every theorem
you prove should require genuine mathematical insight — not just
unfolding definitions or numeric verification.

Your Lean 4 files must:
- Use concrete types (ℕ, ℝ, Finset, Matrix, etc.)
- Build on existing catalog theorems (referenced below)
- Minimize `sorry` — isolate truly hard steps rather than leaving gaps
- Avoid trivial tautologies (no `True := by trivial`)

AEM QUALITY TARGETS:
- RIGOR: Prove 10+ theorems using diverse tactics (induction, rcases,
  by_contra, omega, linarith). ZERO sorries. Use typeclass abstraction.
- AESTHETIC: Bridge 2+ mathematical domains. Use quantifier alternation
  (∀x, ∃y). Include symmetric structures. Name-drop both domains.
- UTILITY: State explicit computational bounds (Lipschitz constants,
  convergence rates, O(...) complexity). Defin

## YOUR ASSIGNMENT: Non-Archimedean Information Geometry: p-adic Fisher Metric, Ultrametric Statistical Manifolds, and Valuation-Theoretic Cramér-Rao Bounds

**DOMAIN**: MachineLearning / Non-Archimedean Computation (Bridge)

**CONCEPT**: Open the field of p-adic information geometry by proving three foundational theorems with explicit computational bounds, establishing the first formal bridge between non-Archimedean analysis and statistical inference theory.

---

### I. Core Definitions (5+ novel structures)

```lean
/-- A p-adic statistical manifold: a family of probability distributions on
    ℚ_p parameterized by locally analytic maps. The valuation depth hierarchy
    from Non-Archimedean Computation controls the granularity of parameter space.
    Bridge: connects PadicAnalysis to InformationGeometry. -/
structure PadicStatisticalManifold (p : ℕ) [hp : Fact p.Prime] (n : ℕ) where
  param_space : Type*
  [param_metric : MetricSpace param_space]
  [param_valued : IsUltrametric param_space]
  prob_map : param_space → (ℚ_p p)^(Fin n) → ℝ≥0
  locally_analytic : ∀ θ, LocallyAnalyticAt (prob_map θ) θ
  normalization : ∀ θ, ∫ x, prob_map θ x = 1
  positivity : ∀ θ x, prob_map θ x > 0

/-- The p-adic Fisher information metric. Unlike the classical Fisher metric
    (Riemannian), this is ultrametric: d_F(θ₁, θ₂) ≤ max(d_F(θ₁, θ₃), d_F(θ₃, θ₂)).
    Bridge: connects DifferentialGeometry to UltrametricTopology. -/
structure PadicFisherMetric (p : ℕ) [Fact p.Prime] (n : ℕ)
    (M : PadicStatisticalManifold p n) where
  fisher_matrix : M.param_space → Matrix (Fin n) (Fin n) (ℚ_p p)
  ultrametric_triangle : ∀ θ₁ θ₂ θ₃,
    ‖fisher_matrix θ₁ - fisher_matrix θ₂‖ ≤
      max (‖fisher_matrix θ₁ - fisher_matrix θ₃‖)
          (‖fisher_matrix θ₃ - fisher_matrix θ₂‖)
  valuation_nonneg : ∀ θ i j, v_p (fisher_matrix θ i j) ≥ 0

/-- A valuation-theoretic unbiased estimator. The key insight: in the p-adic
    setting, "unbiasedness" is refined by valuation depth levels.
    Bridge: connects EstimationTheory to PadicValuationTheory. -/
structure ValuationDepthEstimator (p : ℕ) [Fact p.Prime] (n : ℕ)
    (M : PadicStatisticalManifold p n) where
  estimator : ((ℚ_p p)^(Fin n)) → M.param_space
  unbiased : ∀ θ, 𝔼[estimator | θ] = θ
  valuation_depth : ℕ := 0  -- minimum valuation of estimator precision
  depth_bound : ∀ θ, v_p ‖estimator · - θ‖ ≥ valuation_depth

/-- p-adic exponential family. The cumulant generating function converges
    on a p-adic ball of computable radius.
    Bridge: connects ExponentialFamilies to HenselLifting. -/
structure PadicExponentialFamily (p : ℕ) [Fact p.Prime] (n : ℕ) where
  natural_param : (ℚ_p p)^(Fin n)
  sufficient_stat : (ℚ_p p)^(Fin n) → (ℚ_p p)^(Fin n)
  log_partition : ℚ_p p → ℚ_p p
  convergence_valuation : ℤ  -- v_p of the radius of convergence
  hensel_convergence : ∀ ψ, v_p ψ ≤ convergence_valuation →
    Summable (fun k => (ψ^k / k!) * log_partition_iterate k)

/-- Ultrametric Kullback-Leibler divergence. Satisfies a p-adic data processing
    inequality with explicit valuation-theoretic bound.
    Bridge: connects ShannonTheory to TropicalMeasureTheory. -/
def ultrametricKL {p : ℕ} [Fact p.Prime] {n : ℕ}
    (M : PadicStatisticalManifold p n) (θ₁ θ₂ : M.param_space) : ℚ_p p :=
  ∫ x, M.prob_map θ₁ x * (Padic.log (M.prob_map θ₁ x) - Padic.log (M.prob_map θ₂ x))
```

---

### II. Main Theorems with Precise Type Signatures

#### Theorem 1: p-adic Cramér-Rao with Explicit Valuation Bound

```lean
/-- THE p-ADIC CRAMÉR-RAO THEOREM: Valuation depth of the Fisher information
    provides a SHARP lower bound on estimator covariance valuation.
    The ultrametric inequality forces estimation error to concentrate along
    valuation depth levels — a non-Archimedean uncertainty principle.
    Impact: post_quantum_statistical_security — bounds on inference precision
    in p-adic lattice-based cryptographic settings. -/
theorem padic_cramer_rao_valuation_bound {p : ℕ} [hp : Fact p.Prime] {n : ℕ}
    (M : PadicStatisticalManifold p n) (F : PadicFisherMetric p n M)
    (Ê : ValuationDepthEstimator p n M) (θ : M.param_space) :
    v_p (det (covariance_matrix Ê θ)) ≥
      v_p (det (F.fisher_matrix θ))⁻¹ ∧
    -- Explicit bound: valuation depth ≥ n * (valuation of Fisher determinant inverse)
    Ê.valuation_depth ≥ n * (-(v_p (det (F.fisher_matrix θ)))) ∧
    -- Sharpness: equality holds iff estimator is p-adic efficient
    (∃ (Ê' : ValuationDepthEstimator p n M),
      Ê'.valuation_depth = n * (-(v_p (det (F.fisher_matrix θ)))) ∧
      v_p (det (covariance_matrix Ê' θ)) = v_p (det (F.fisher_matrix θ))⁻¹) :=
  sorry -- DO NOT USE sorry; prove via valuation theory and ultrametric inequality
```

**Proof Strategy A (Most Promising)**: Induction on valuation depth.
1. Base case: depth 0 — the trivial bound v_p(det(Cov)) ≥ 0 from normalization.
2. Inductive step: if v_p(det(Cov(Ê))) < v_p(det(I(θ))⁻¹), then by the ultrametric property, there exists a coordinate i where v_p(Var(Êᵢ)) < v_p(I(θ)⁻¹ᵢᵢ), contradicting the p-adic Cauchy-Schwarz inequality (Lemma: `padic_cauchy_schwarz_valuation`).
3. Sharpness: construct the p-adic efficient estimator via Hensel lifting from the Fisher matrix, building on `hensel_lifting_speedup` from the catalog.

**Proof Strategy B**: Direct computation via p-adic matrix theory.
1. Show that the Fisher information matrix is non-singular over ℚ_p (use `locally_analytic` and `positivity`).
2. Apply p-adic determinant inequalities: v_p(det(AB)) = v_p(det(A)) + v_p(det(B)).
3. The covariance-identity decomposition gives the bound with equality characterization.

**Proof Strategy C (Alternative)**: Via p-adic logarithmic Sobolev inequalities.
1. Establish a p-adic log-Sobolev inequality (novel, connects to tropical Shannon theory).
2. The Cramér-Rao bound follows as a consequence of the log-Sobolev inequality at valuation depth level.
3. This approach connects to `tropical_data_processing_inequality` from the catalog.

---

#### Theorem 2: Ultrametric Chentsov Uniqueness

```lean
/-- THE ULTRAMETRIC CHENTSOV THEOREM: The p-adic Fisher information metric is
    the UNIQUE ultrametric on p-adic statistical manifolds invariant under
    sufficient statistics and Markov morphisms, up to valuation-preserving rescaling.
    The proof exploits that p-adic balls are simultaneously open and closed (clopen),
    forcing uniqueness — a structure unavailable classically.
    Bridge: connects CategoryTheory to StatisticalInference.
    Impact: ultrametric_manifold_classification for post-quantum data analysis. -/
theorem ultrametric_chentsov_uniqueness {p : ℕ} [hp : Fact p.Prime] {n : ℕ}
    (M : PadicStatisticalManifold p n)
    (g₁ g₂ : UltrametricOn M.param_space)
    (h₁ : SufficientStatisticInvariant g₁ M)
    (h₂ : SufficientStatisticInvariant g₂ M)
    (h₃ : MarkovMorphismInvariant g₁ M)
    (h₄ : MarkovMorphismInvariant g₂ M) :
    ∃ (c : ℚ_p p) (hc : v_p c = 0),
      ∀ θ₁ θ₂ : M.param_space,
        dist_g g₁ θ₁ θ₂ = ‖c‖ * dist_g g₂ θ₁ θ₂ :=
  sorry -- Prove via clopen uniqueness argument
```

**Proof Strategy A (Most Promising)**: Clopen partition argument.
1. Any ultrametric invariant under sufficient statistics must be locally constant on p-adic balls (use `is_clopen_ball` from p-adic topology).
2. Two locally constant ultrametrics on a connected-by-valuation-depth space must differ by a valuation-unit scalar (Lemma: `clopen_ultrametric_scalar_multiple`).
3. Markov morphism invariance forces the scalar to be a unit in ℤ_p^× (v_p c = 0).

**Proof Strategy B**: Via natural transformations in the category of p-adic statistical models.
1. Define the category `PadicStat` of p-adic statistical manifolds with sufficient-statistic-preserving morphisms.
2. Show that invariant ultrametrics are natural transformations from `PadicStat` to `UltrametricSpace`.
3. Uniqueness follows from the initial object structure (the simplex with p-adic Fisher metric).

**Proof Strategy C**: Direct computation via characterization of ultrametric norms on tangent spaces.
1. On the tangent space at θ, any invariant ultrametric is determined by its value on the canonical basis.
2. Sufficient statistic invariance + ultrametric triangle inequality forces the norm to be proportional to the Fisher norm.
3. The proportionality constant must have valuation 0 (otherwise we could construct a finer invariant ultrametric, contradicting clopen rigidity).

---

#### Theorem 3: p-adic Exponential Family Classification with Geodesic Bounds

```lean
/-- p-ADIC EXPONENTIAL FAMILY CLASSIFICATION: The geodesic distance in a p-adic
    exponential family is bounded by p-adic valuation depth with EXPLICIT constants.
    The natural parameter space is a p-adic ball whose radius equals p^(convergence_valuation).
    Bridge: connects DifferentialGeometry to PadicAnalysis to TropicalMeasureTheory.
    Impact: certified_ultrametric_inference with O(log_p(1/ε)) convergence. -/
theorem padic_exponential_family_geodesic_bound {p : ℕ} [hp : Fact p.Prime] {n : ℕ}
    (E : PadicExponentialFamily p n)
    (θ₁ θ₂ : (ℚ_p p)^(Fin n))
    (h₁ : v_p θ₁ ≤ E.convergence_valuation)
    (h₂ : v_p θ₂ ≤ E.convergence_valuation) :
    -- Geodesic distance bounded by valuation depth difference
    dist_geodesic E θ₁ θ₂ ≤ p ^ (v_p (θ₁ - θ₂)) ∧
    -- Explicit O(log_p(1/ε)) convergence bound for geodesic computation
    ∀ ε > 0, ∃ k ≤ Nat.ceil (Real.log (1/ε) / Real.log p),
      ‖geodesic_approximation E θ₁ θ₂ k - dist_geodesic E θ₁ θ₂‖ < ε ∧
    -- The natural parameter space is exactly the convergence ball
    {θ : (ℚ_p p)^(Fin n) | v_p θ ≤ E.convergence_valuation} =
      natural_parameter_space E :=
  sorry -- Prove via p-adic power series analysis and Hensel's lemma
```

**Proof Strategy**: p-adic power series + Hensel lifting.
1. Show that the cumulant generating function is a p-adic power series converging on the ball of radius p^(convergence_valuation) (use `hensel_lifting_speedup`).
2. The geodesic equation in p-adic exponential families reduces to a p-adic ODE with ultrametric contraction (Lemma: `padic_geodesic_contraction_rate`).
3. The contraction rate gives the O(log_p(1/ε)) convergence bound — this is the p-adic analog of the tropical Berry-Esseen bound from the catalog.

---

### III. Supporting Lemmas (10+ required, diverse tactics)

```lean
/-- Bridge: connects PadicValuation to CauchySchwarzInequality -/
lemma padic_cauchy_schwarz_valuation {p : ℕ} [Fact p.Prime] {n : ℕ}
    (M : PadicStatisticalManifold p n) (F : PadicFisherMetric p n M)
    (θ : M.param_space) (i j : Fin n) :
    v_p (F.fisher_matrix θ i j) ≤
      (v_p (F.fisher_matrix θ i i) + v_p (F.fisher_matrix θ j j)) / 2 :=
  by
    -- Use ultrametric property and p-adic Cauchy-Schwarz
    -- The key: ultrametric inequality forces the diagonal to dominate
    sorry -- FILL WITH GENUINE PROOF using rcases, omega, padic arithmetic

/-- Bridge: connects ClopenTopology to UltrametricUniqueness -/
lemma clopen_ultrametric_scalar_multiple {p : ℕ} [Fact p.Prime]
    {α : Type*} [UltrametricSpace α] [ConnectedByValuationDepth α]
    (g₁ g₂ : UltrametricOn α)
    (h : ∀ x y, dist_g g₁ x y = 0 ↔ dist_g g₂ x y = 0) :
    ∃ (c : ℚ_p p) (hc : v_p c = 0),
      ∀ x y, dist_g g₁ x y = ‖c‖ * dist_g g₂ x y :=
  by
    -- Key insight: on a valuation-depth-connected space, two ultrametrics
    -- with the same zero sets differ by a valuation-unit scalar
    sorry -- FILL WITH GENUINE PROOF using by_contra, valuation theory

/-- Bridge: connects HenselLifting to GeodesicComputation -/
lemma padic_geodesic_contraction_rate {p : ℕ} [Fact p.Prime] {n : ℕ}
    (E : PadicExponentialFamily p n)
    (θ₁ θ₂ : (ℚ_p p)^(Fin n))
    (h : v_p (θ₁ - θ₂) ≤ E.convergence_valuation) :
    ∃ (rate : ℕ), rate = Nat.ceil (Real.log p / Real.log 2) ∧
      ∀ k, ‖geodesic_iterate E θ₁ θ₂ (k + 1) - geodesic_iterate E θ₁ θ₂ k‖ ≤
        p ^ (-(rate * k)) :=
  by
    -- Uses Hensel's lemma to establish contraction rate
    -- Builds on hensel_lifting_speedup from catalog
    sorry -- FILL WITH GENUINE PROOF using induction on k

/-- The p-adic data processing inequality for ultrametric KL divergence.
    Bridge: connects TropicalShannonTheory to PadicInformationGeometry.
    Impact: certified_information_leakage_bounds for post-quantum channels. -/
theorem padic_data_processing_inequality {p : ℕ} [Fact p.Prime] {n m : ℕ}
    (M : PadicStatisticalManifold p n)
    (κ : MarkovKernel ((ℚ_p p)^(Fin n)) ((ℚ_p p)^(Fin m)))
    (θ₁ θ₂ : M.param_space) :
    v_p (ultrametricKL M θ₁ θ₂) ≥
      v_p (ultrametricKL (pushforward_manifold M κ) (κ* θ₁) (κ* θ₂)) ∧
    -- Explicit bound: information loss bounded by p^(-valuation_depth)
    v_p (ultrametricKL M θ₁ θ₂ -
         ultrametricKL (pushforward_manifold M κ) (κ* θ₁) (κ* θ₂)) ≤
      -(Ê.valuation_depth : ℤ) :=
  by
    -- Follows from tropical_data_processing_inequality in catalog
    -- Adapted to p-adic setting via valuation = -tropical_degree
    sorry -- FILL WITH GENUINE PROOF

/-- p-adic Fisher information is non-degenerate with explicit valuation bound.
    Bridge: connects InformationGeometry to PadicLinearAlgebra -/
lemma fisher_matrix_nondegenerate_valuation {p : ℕ} [Fact p.Prime] {n : ℕ}
    (M : PadicStatisticalManifold p n) (F : PadicFisherMetric p n M)
    (θ : M.param_space) :
    v_p (det (F.fisher_matrix θ)) ≤ n * max_valuation_diagonal F θ ∧
    v_p (det (F.fisher_matrix θ)) ≥
      n * min_valuation_diagonal F θ + (n * (n - 1)) / 2 * min_off_diagonal_valuation F θ :=
  by
    -- Uses ultrametric determinant bounds and Gershgorin-type p-adic argument
    sorry -- FILL WITH GENUINE PROOF using omega, finset arithmetic

/-- Valuation depth of p-adic estimator satisfies subadditivity.
    Bridge: connects EstimationTheory to PadicValuationHierarchies -/
lemma valuation_depth_subadditive {p : ℕ} [Fact p.Prime] {n : ℕ}
    (M : PadicStatisticalManifold p n)
    (Ê₁ Ê₂ : ValuationDepthEstimator p n M) :
    (Ê₁ ⊕ Ê₂).valuation_depth ≥ min Ê₁.valuation_depth Ê₂.valuation_depth ∧
    (Ê₁ ⊕ Ê₂).valuation_depth ≤ Ê₁.valuation_depth + Ê₂.valuation_depth :=
  by
    -- Follows from ultrametric property of v_p
    sorry -- FILL WITH GENUINE PROOF

/-- p-adic exponential family is closed under sufficient statistics.
    Bridge: connects ExponentialFamilies to CategoryTheory -/
theorem padic_exponential_family_sufficient_closure {p : ℕ} [Fact p.Prime] {n m : ℕ}
    (E : PadicExponentialFamily p n)
    (T : ((ℚ_p p)^(Fin n)) → ((ℚ_p p)^(Fin m)))
    (hT : IsSufficientStatistic E T) :
    ∃ (E' : PadicExponentialFamily p m),
      E'.convergence_valuation ≥ E.convergence_valuation ∧
      pushforward_family E T = E'.toPadicStatisticalManifold :=
  by
    -- Uses p-adic change of variables and Hensel lifting
    sorry -- FILL WITH GENUINE PROOF

/-- Ultrametric KL divergence satisfies triangle inequality with valuation bound.
    Bridge: connects InformationTheory to UltrametricTopology -/
theorem ultrametric_kl_triangle {p : ℕ} [Fact p.Prime] {n : ℕ}
    (M : PadicStatisticalManifold p n) (θ₁ θ₂ θ₃ : M.param_space) :
    v_p (ultrametricKL M θ₁ θ₃) ≥
      min (v_p (ultrametricKL M θ₁ θ₂)) (v_p (ultrametricKL M θ₂ θ₃)) :=
  by
    -- The ultrametric property of v_p forces this "reverse triangle inequality"
    sorry -- FILL WITH GENUINE PROOF using by_contra, ultrametric property

/-- Convergence rate for p-adic maximum likelihood estimation.
    Bridge: connects StatisticalEstimation to HenselLifting.
    Impact: certified_mle_convergence for ultrametric data pipelines. -/
theorem padic_mle_convergence_rate {p : ℕ} [Fact p.Prime] {n : ℕ}
    (M : PadicStatisticalManifold p n) (F : PadicFisherMetric p n M)
    (θ_true : M.param_space) (N : ℕ) :
    -- MLE converges at rate O(p^(-N * valuation_depth)) with N samples
    v_p (mle_estimate M N - θ_true) ≥
      N * (min_diagonal_valuation F θ_true) - (n + 1) * Real.log p / Real.log 2 :=
  by
    -- Follows from p-adic law of large numbers and Hensel lifting speedup
    sorry -- FILL WITH GENUINE PROOF using induction on N

/-- p-adic Cramér-Rao is SHARP: equality characterization.
    Bridge: connects Optimization to PadicLinearAlgebra -/
theorem padic_cramer_rao_equality_characterization {p : ℕ} [Fact p.Prime] {n : ℕ}
    (M : PadicStatisticalManifold p n) (F : PadicFisherMetric p n M)
    (Ê : ValuationDepthEstimator p n M) (θ : M.param_space) :
    v_p (det (covariance_matrix Ê θ)) = v_p (det (F.fisher_matrix θ))⁻¹ ↔
      -- Equality iff estimator is a p-adic linear function of the sufficient statistic
      ∃ (A : Matrix (Fin n) (Fin n) (ℚ_p p)) (b : (ℚ_p p)^(Fin n)),
        v_p (det A) = 0 ∧
        Ê.estimator = fun x => A * (sufficient_statistic M θ x) + b :=
  by
    -- Follows from p-adic matrix theory and the Cauchy-Schwarz equality case
    sorry -- FILL WITH GENUINE PROOF using rcases, field_simp
```

---

### IV. Revolutionary Significance

This work opens **p-adic information geometry** as a new field at the intersection of:
1. **Non-Archimedean analysis** and **statistical inference**: The ultrametric inequality fundamentally restructures how uncertainty concentrates — not as ellipsoids (Gaussian) but as nested valuation-depth balls. This is the first formal treatment.
2. **Post-quantum cryptography**: p-adic statistical manifolds provide a framework for analyzing lattice-based cryptographic schemes where the adversary's estimation capability is bounded by p-adic valuation depth — directly connecting to the SPB (Shortest Vector Problem) hardness assumptions.
3. **Certified robustness for ultrametric ML**: The O(log_p(1/ε)) convergence bound for geodesic computation enables certified inference on data with ultrametric structure (hierarchical clustering, phylogenetic trees, lexical databases).

**Cross-domain bridges**:
- **Tropical Shannon Theory** → **Padic Information Geometry**: The max-plus data processing inequality becomes a valuation-theoretic bound via the correspondence v_p(x) = -trop(x).
- **Hensel Lifting** → **Statistical Estimation**: Hensel's lemma provides the constructive mechanism for efficient p-adic estimators, replacing Newton's method in the classical setting.
- **Algebraic Causal Inference** → **Non-Archimedean Statistics**: Module-theoretic d-separation generalizes to p-adic statistical independence via valuation-depth filtration.

---

### V. Deliverables

Produce the following files:

1. **`PadicInformationGeometry/PadicCramerRao.lean`** — The p-adic Cramér-Rao theorem with valuation bounds, sharpness characterization, and all supporting lemmas (300+ lines, 15+ theorems).

2. **`PadicInformationGeometry/UltrametricChentsov.lean`** — The ultrametric Chentsov uniqueness theorem, clopen rigidity lemma, and category-theoretic formulation (250+ lines, 10+ theorems).

3. **`PadicInformationGeometry/PadicExponentialFamily.lean`** — Classification theorem, geodesic bounds, MLE convergence rates, and Hensel lifting connections (300+ lines, 15+ theorems).

4. **`PadicInformationGeometry/UltrametricKL.lean`** — Ultrametric KL divergence, data processing inequality, triangle inequality, and connections to tropical Shannon theory (200+ lines, 10+ theorems).

5. **`FUTURE_DIRECTIONS.md`** with 5 concrete next steps:
   - p-adic information geometry for quantum state tomography (connecting to Weyl quantization over ℚ_p)
   - Lattice-based cryptographic hardness from p-adic estimation bounds (SPB → Cramér-Rao reduction)
   - Certified robustness for ultrametric neural networks (valuation-depth Lipschitz bounds)
   - p-adic thermodynamic limit and non-Archimedean statistical mechanics (partition functions over ℚ_p)
   - Tropical-to-p-adic dictionary: systematic translation of max-plus results to valuation-theoretic form

**AEM QUALITY MANDATE**: Your output will be scored on 5 pillars. Optimize ALL:
- RIGOR: 10+ theorems, diverse tactics (induction, rcases, by_contra, omega, linarith), ZERO sorries
- AESTHETIC: Bridge 2+ domains in theorem names and doc comments. Use quantifier alternation.
- UTILITY: Define 5+ structures/instances. State SPECIFIC computational bounds (O(n log n), Omega(2^n)) — generic terms like 'bound' or 'rate' alone do NOT score utility.
- ORIGINALITY: Coin novel definitions beyond Mathlib. Inventive theorem names. Write 'Bridge: connects X to Y' in doc comments for cross-domain connections. Generic names (main, test, aux) do NOT count.
- IMPACT: Use SPECIFIC application terms (lipschitz_certified_robustness, post_quantum_security, tropical_hash_collision) — generic terms like 'convergence' or 'spectrum' without ML/crypto/physics context do NOT score impact.

**FILE RICHNESS MANDATE**: Produce substantial, rich files (not stubs).
- Target 500+ lines with 20+ theorems and 10+ definitions per file.
- Historical Masters in the catalog average 2000+ lines, 180+ theorems, 70+ definitions.
- Each file should be a complete mathematical narrative with definitions, lemmas, and main theorems all connected.
- When producing catalog-wide output: create files across MULTIPLE domains (Bridges, Algebra, Cryptography, Tropical, EML, Physics), not just one domain.

            Research Mode: PROVE

Discover and prove new, non-trivial theorems that advance the
mathematical frontier. Start from the existing verified theorems
listed below and extend them into deeper territory. Every theorem
you prove should require genuine mathematical insight — not just
unfolding definitions or numeric verification.

Your Lean 4 files must:
- Use concrete types (ℕ, ℝ, Finset, Matrix, etc.)
- Build on existing catalog theorems (referenced below)
- Minimize `sorry` — isolate truly hard steps rather than leaving gaps
- Avoid trivial tautologies (no `True := by trivial`)

AEM QUALITY TARGETS:
- RIGOR: Prove 10+ theorems using diverse tactics (induction, rcases,
  by_contra, omega, linarith). ZERO sorries. Use typeclass abstraction.
- AESTHETIC: Bridge 2+ mathematical domains. Use quantifier alternation
  (∀x, ∃y). Include symmetric structures. Name-drop both domains.
- UTILITY: State explicit computational bounds (Lipschitz constants,
  convergence rates, O(...) complexity). Define 5+ new structures/instances.
- ORIGINALITY: Coin novel definitions with inventive names. Avoid
  derivative names like *_comm, *_nonneg. Combine unusual typeclasses.
- IMPACT: Reference physics (quantum, thermodynamic), cryptography
  (lattice, post-quantum), or ML (certified robustness, neural) in
  theorem names and doc comments. Use keywords: certified_robustness,
  Lipschitz_bound, lattice_crypto, hamiltonian, entropy, etc.


            === VISIONARY DIRECTIVES ===

            Think beyond current mathematical fashion. You are not just proving theorems —
            you are building a mathematical civilization. Every result should:

            1. OPEN DOORS: A good theorem doesn't just close a question — it opens three
               new ones. What does your result make possible that wasn't possible before?
            2. CONNECT WORLDS: The deepest results connect fields that seemed unrelated.
               If you prove something about tropical geometry, ask: what does this mean
               for quantum computing? For cryptography? For neural networks?
            3. PRODUCE ALGORITHMS: Don't just prove existence — construct. Don't just
               construct — compute. Don't just compute — optimize. Every theorem should
               have an algorithmic shadow.
            4. BE BOLD: An interesting false conjecture is more valuable than a boring
               true theorem. If you suspect something is true but can't prove it, state
               it as a conjecture with precise Lean 4 type signature and explain why it matters.
            5. BUILD INFRASTRUCTURE: Definitions are as valuable as theorems. A good
               mathematical definition (like "tropical semiring" or "EML closure") can
               organize an entire field. Define things precisely, then prove things about them.

            The mathematics comes FIRST. Excellent proofs trump everything else.
            But excellent proofs that OPEN NEW FIELDS trump everything.

            === AEM QUALITY SCORING (MANDATORY GUIDELINES) ===
            Your output will be scored on 5 pillars. MAXIMIZE each one:

            PILLAR 1 — RIGOR (Is it World-class?):
            • ZERO sorries in your output (sorries cost -1.5 points each)
            • Use diverse proof tactics (induction, rcases, by_contra, omega, linarith,
              field_simp, refine, obtain — not just simp/rfl/decide)
            • Use typeclass abstraction ([Semiring B], [LinearOrder B], etc.) not
              concrete types alone
            • Later theorems should reference earlier ones (semantic coherence)
            • 10+ theorems = full rigor score; 3-10 = partial; 0-2 = minimal

            PILLAR 2 — AESTHETIC (Is it Interesting?):
            • Bridge 2+ mathematical domains in EVERY file (e.g., tropical + neural
              networks; algebra + thermodynamics; number theory + quantum)
            • Use quantifier alternation (∀ → ∃) for non-trivial theorem statements
            • Include symmetric structures (lattices, posets, groups, duality)
            • Minimize hypotheses for maximal conclusions (small axiomatic footprint)
            • Narrative surprise: state in doc comments WHY the result is unexpected

            PILLAR 3 — UTILITY (Is it Useful?):
            • State explicit computational bounds (O(...), convergence rates, Lipschitz
              constants, error bounds, complexity classifications)
            • Define extensible APIs: 5+ definitions, structures, and instances
            • Reference or advance known open problems (Carmichael, tropical Langlands,
              certified robustness, Berggren factoring, lattice crypto)
            • Organize code with namespaces and sections (framework structure)

            PILLAR 4 — ORIGINALITY (Is it New?):
            • Coin NOVEL definitions — not just restating Mathlib theorems with new names
            • Avoid derivative theorem names (*_eq_zero, *_nonneg, *_symm, *_comm,
              *_add_*, *_mul_*). Use INVENTIVE names that reveal new concepts
            • Combine unusual typeclasses ([Semiring, LinearOrder], [NormedAddCommGroup,
              Field], [MeasureSpace, Category]) — this signals divergent reasoning
            • Each file should introduce 5+ genuinely new mathematical objects (def, structure, class, instance). High-Originality files average 10+ new definitions.

            PILLAR 5 — IMPACT (Does it have Wonderful Applications?):
            • EVERY theorem should connect to at least one of: physics (quantum,
              thermodynamic, entropy), cryptography (lattice, post-quantum, SPB),
              or ML (certified robustness, Lipschitz bounds, neural networks)
            • Name-drop application keywords explicitly in theorem/doc-comment text:
              certified_robustness, Lipschitz, neural_network, gradient_descent,
              convergence, post_quantum, lattice_crypto, hamiltonian, entropy,
              holographic, berggren
            • Produce algorithms or computational pipelines, not just existence proofs

            ### Research Direction
            Open the field of p-adic information geometry by proving three foundational theorems. (1) p-adic Cramér-Rao Theorem: For a p-adic statistical manifold (family of probability distributions on Q_p^n with locally analytic parametrization), the p-adic valuation of the Fisher information matrix provides a sharp lower bound on the valuation of any unbiased estimator's covariance: v_p(det(Cov(θ̂))) ≥ v_p(det(I(θ))^{-1}). The ultrametric inequality forces estimation error to concentrate along valuation depth levels, yielding a fundamentally non-Archimedean uncertainty principle. (2) Ultrametric Chentsov Theorem: The p-adic Fisher information metric is the unique metric (up to valuation-preserving rescaling) on p-adic statistical manifolds that is invariant under sufficient statistics and Markov morphisms. The proof exploits the rigid convexity structure of p-adic balls (simultaneously open and closed) to force uniqueness — a structure unavailable in the classical Riemannian case. (3) p-adic Exponential Family Classification: p-adic exponential families form ultrametric manifolds whose geodesic distance is bounded by p-adic valuation depth. The natural parameter space is a p-adic ball whose radius is determined by the convergence valuation of the cumulant generating function, directly connecting to the p-adic valuation depth hierarchies established in the catalog's Non-Archimedean Computation domain. This creates the first bridge between p-adic analysis and information geometry, opening applications in post-quantum ML, ultrametric data analysis, and non-Archimedean statistical inference.

            ### Precise Mathematical Framing
            Define a p-adic statistical manifold as a triple (M, g, ∇) where M ⊂ Z_p^d is an open compact subset of p-adic parameter space, g is the p-adic Fisher information metric g_θ(u,v) = E_θ[∂_u log p_θ · ∂_v log p_θ] taking values in Q_p, and ∇ is the p-adic Levi-Civita connection. The key structural theorem is that (M,g) is an ultrametric manifold: for any x,y ∈ M and any point z on the geodesic between them, d(z,x) ≤ max(d(x,y), d(y,z)). This forces the p-adic Cramér-Rao bound to take the form: v_p(Var_p(θ̂_i)) ≥ v_p(g^{ii}(θ)), where v_p is the p-adic valuation and g^{ii} is the i-th diagonal element of the inverse Fisher metric. The Chentsov uniqueness proof proceeds by showing that any p-adic statistical divergence satisfying sufficient invariance must agree with the p-adic Fisher metric on p-adic balls, using the rigid ultrametric topology to eliminate the continuous family of possible metrics that exists in the classical case. The exponential family classification uses the p-adic logarithm's domain of convergence (the ball {x ∈ Q_p : v_p(x) > 1/(p-1)}) to characterize when p-adic cumulant generating functions define valid statistical manifolds, yielding a valuation-depth stratification of the parameter space.



            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `information_lower_bound` : theorem information_lower_bound (P b : ℕ) :
     (file: MachineLearning/Neural/CompilationCompression.lean)
  2. `bell_ineq_classical_bound_det` : theorem bell_ineq_classical_bound_det (a₀ a₁ b₀ b₁ : ℝ)
     (file: MachineLearning/ShefferFunction/PhotonEpistemicBridge.lean)
  3. `aggregated_margin_lower_bound_under_perturbation` : theorem aggregated_margin_lower_bound_under_perturbation
     (file: MachineLearning/TropicalPairwiseRobustness.lean)
  4. `epsilon_any_function_is_matrix` : theorem epsilon_any_function_is_matrix {n m : ℕ} (f : Fin n → Fin m → ℝ) :
     (file: MachineLearning/Neural/NeuralCompilationTeams.lean)
  5. `gpt2_info_lower_bound` : theorem gpt2_info_lower_bound :
     (file: MachineLearning/Neural/LLMSingleMatMul.lean)

            Known Working Lean 4 Tactics:
- `nlinarith [sq_nonneg X]` for quadratic inequalities
- `positivity` for positivity goals
- `field_simp` then `ring` for division
- `Real.exp_le_exp.mpr` for exp monotonicity
- `Real.log_le_log` for log inequalities
- `div_pos`, `div_le_div_of_nonneg_left` for division inequalities
- `pow_le_pow_right₀` for power monotonicity
- `by decide` / `by norm_num` / `native_decide` for decidable propositions
- `Subadditive.tendsto_lim` for Fekete's Lemma
- `ConvexOn.map_sum_le` for Jensen's inequality
- `exists_deriv_eq_slope` for MVT



Recent successful concepts: Connes-Kreimer Hopf Algebra of Rooted Trees: Graded Coproduct via Admissible Cuts, Recursive Antipode, and Birkhoff Decomposition of Characters, Non-Archimedean Computation: Ultrametric Algorithm Complexity, p-adic Valuation Depth Hierarchies, and Hensel Lifting Speedup Theorems, Min-Plus Causal Discovery: Shortest-Path d-Separation, Tropical Intervention Optimization, and Polynomial Causal Identification


            ### Previously Proved Theorems
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.

            ### Required Deliverables

            You are a world-class mathematician and software engineer. Create:

            1. **Lean 4 files** — formally verified theorems with complete proofs
               - Use concrete types (ℕ, ℝ, Finset, Matrix, etc.)
               - Build on the existing catalog theorems listed above
               - Minimize `sorry` — isolate hard steps rather than leaving gaps
               - Use doc comments to explain the significance of key results

            2. **RESEARCH_REPORT.md** — paper explaining the discovery
               - Mathematical significance and connections to existing work
               - Detailed proofs and explanations

            3. **DISCUSSION.md** — MANDATORY Scientific American-style popular science article
               - Written for a mathematically literate but non-specialist audience
               - Use analogies, examples, and narrative to explain WHY this matters
               - Include at least one surprising connection to everyday life or another field
               - 1000-2000 words, accessible but not dumbed-down
               - This makes your research accessible to a broad audience

            4. **FUTURE_DIRECTIONS.md** — MANDATORY breakthrough research roadmap
               This is the MOST IMPORTANT deliverable because it drives the next
               research cycle. Structure it as:

               ## Breakthrough Opportunities (ranked by impact)
               For each opportunity:
               - **Theorem Statement**: Precise, formalizable statement with quantifiers
               - **Proof Strategy**: 2-3 concrete approaches with key lemmas identified
               - **Why This Is Revolutionary**: What field it opens, what applications it enables,
                 what unexpected connections it reveals
               - **Catalog Leverage**: Which existing catalog theorems to build on (by name)
               - **Research Mode**: prove | formalize | discover | counterexample
               - **Estimated Depth**: 1-5 scale (1 = one clever lemma, 5 = multi-theorem development)

               ## Under-explored Territory
               - Domains with many definitions but few deep theorems
               - Unexpected structural similarities across domains
               - "Orphan" results that could seed new research programs

               ## Cross-Domain Bridges
               - Specific, precise connections between domains
               - Conjectured functorial correspondences or isomorphisms
               - Algorithmic pipelines combining results from multiple domains

               ## Open Problems Encountered
               - Problems you couldn't solve but identified as important
               - Conjectures you can state precisely but not yet prove
               - Connections that seem to exist but need more catalog infrastructure

            5. **demo.py** — Python demo with concrete numerical examples
               - Working code that brings the math to life
               - Visualizations where they add insight

            6. **diagram.svg** — visualization of key mathematical structures

            Produce novel, non-trivial theorems with complete Lean 4 proofs. Think big — aim for results that would appear in JAMS, Annals, or FOCS.

            ### Catalog Reference Files
            No specific files referenced. Use Mathlib and general knowledge.


### Catalog Reference Files
            No specific files referenced. Use Mathlib and general knowledge.


### WHAT WE NEED FROM YOU

You are a world-class mathematician and software engineer. Use your judgment
on the best way to organize and present your work. We need:

1. **Formally verified mathematics** in Lean 4
   - Prove non-trivial theorems with complete proofs (no `sorry` in the final result)
   - Organize the Lean code however makes sense — one file or several,
     whatever serves the mathematics best
   - Use doc comments to explain the significance of key results

2. **Python demos** that bring the mathematics to life
   - Create working Python code that demonstrates the theorems with
     concrete numerical examples
   - Visualizations (matplotlib, etc.) where they add insight
   - Show the math in action — make it tangible and understandable
   - Name and organize the demos however you see fit

3. **A research paper** that explains the discovery
   - Write this as a proper mathematical paper
   - Include a Scientific American style discussion section that makes
     the result accessible to a broad audience — use analogies,
     intuition, and historical context
   - Explain connections to existing work and future directions

4. **Useful applications** — show how this math matters in practice
   - What can people DO with this result?
   - Where does it apply in the real world?
   - Include code, examples, or demonstrations of applications

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real and useful.

Research domain: MachineLearning
Research mode: prove
