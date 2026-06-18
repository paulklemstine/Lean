

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

## TASK: Ring-Theoretic Learning Capacity — Hilbert-VC Duality, Localization Generalization, and Noetherian Feature Convergence

### I. FOUNDATIONAL DEFINITIONS (5+ novel structures)

Establish the dictionary between commutative algebra and statistical learning theory. Every definition must carry both an algebraic and a learning-theoretic interpretation.

```lean
/-- A polynomial hypothesis class over a commutative ring R with feature dimension n
    is the set of sign-configurations realizable by degree-≤d polynomials.
    Bridge: connects IdealTheory (Hilbert functions) to MachineLearning (VC dimension). -/
structure PolynomialHypothesisClass (R : Type*) [CommRing R] (n : ℕ) (d : ℕ) where
  /-- The ideal of relations among features; the "forbidden sign patterns" -/
  relationIdeal : Ideal (MvPolynomial (Fin n) R)
  /-- Degree bound on hypothesis complexity -/
  degreeBound : ℕ
  hdeg : degreeBound = d
  /-- The hypothesis class: sign maps from feature space to {−1, +1} realizable by degree ≤ d polynomials -/
  hypothesisMap : (Fin n → R) → Fin 2 → Bool

/-- The Hilbert-VC dimension: the maximum number of points shattered by the
    polynomial hypothesis class, equal to the Hilbert function value.
    Bridge: connects CommutativeAlgebra (Hilbert function) to LearningTheory (VC dimension). -/
noncomputable def hilbertVCdimension (R : Type*) [CommRing R] [IsNoetherianRing R]
    (n d : ℕ) : ℕ := sorry -- will be proven equal to Hilbert function value

/-- Localization generalization factor: the height of a prime ideal measures
    the information cost of focusing a hypothesis class on local geometry.
    Bridge: connects AlgebraicGeometry (localization at primes) to StatisticalLearning (generalization bounds). -/
noncomputable def localizationGeneralizationFactor
    {R : Type*} [CommRing R] [IsDomain R] [IsNoetherianRing R]
    (p : Ideal R) [p.IsPrime] : ℝ :=
  (Ideal.height p : ℝ)

/-- Feature chain stabilization index: for an ascending chain of feature modules
    F₁ ⊂ F₂ ⊂ ... over a Noetherian ring, the step at which stabilization occurs.
    Bridge: connects ModuleTheory (ACC) to Optimization (convergence of greedy feature selection). -/
def featureChainStabilizationIndex
    {R : Type*} [CommRing R] [IsNoetherianRing R]
    (chain : ℕ → Submodule R (MvPolynomial (Fin n) R)) : ℕ := sorry

/-- The Hilbert-Samuel complexity bound: explicit convergence rate for feature
    selection derived from the Hilbert-Samuel polynomial.
    Bridge: connects AlgebraicGeometry (Hilbert-Samuel polynomial) to MachineLearning (sample complexity). -/
noncomputable def hilbertSamuelComplexityBound
    {R : Type*} [CommRing R] [IsNoetherianRing R]
    (I : Ideal R) (n : ℕ) : ℝ := sorry
```

### II. MAIN THEOREMS WITH PRECISE STATEMENTS

**Theorem 1: Hilbert-VC Correspondence (The Crown Jewel)**

```lean
/-- Bridge: connects Hilbert function theory (CommutativeAlgebra) to VC dimension (LearningTheory).
    The VC dimension of a degree-≤d polynomial hypothesis class over a Noetherian ring R
    with n features equals the Hilbert function H(R/I, d) of the quotient by the relation ideal.
    This establishes Krull dimension as the asymptotic learning capacity: as d → ∞,
    VCdim ~ dim(R/I) · d + lower order terms.
    Impact: certified_robustness — gives exact sample complexity for polynomial classifiers. -/
theorem hilbert_VC_correspondence
    {R : Type*} [CommRing R] [IsDomain R] [IsNoetherianRing R]
    (I : Ideal (MvPolynomial (Fin n) R))
    (d : ℕ) (hd : 0 < d)
    (hI : I.IsHomogeneous (MvPolynomial.weightedDegree)) :
    ∀ m : ℕ, m < (MvPolynomial.numMonomials n d) →
      ∃ (points : Fin m → (Fin n → R)) (hpoints : Function.Injective points),
        ∀ (labels : Fin m → Fin 2),
          ∃ f : MvPolynomial (Fin n) R, f.degree ≤ d ∧
            ∀ i, (hypothesisMap (points i) f) = labels i :=
  by sorry -- see proof strategy below
```

**Theorem 2: Localization Generalization Bound**

```lean
/-- Bridge: connects AlgebraicGeometry (localization at primes) to StatisticalLearning (generalization error).
    Localizing the feature ring at a prime ideal p focuses the hypothesis class on local geometry near V(p).
    The generalization error of the localized model is bounded by ht(p) · log(n)/n,
    where ht(p) is the height of p and n is the sample size.
    Impact: certified_robustness — local models generalize with explicit rate. -/
theorem localization_generalization_bound
    {R : Type*} [CommRing R] [IsDomain R] [IsNoetherianRing R]
    (p : Ideal R) [hp : p.IsPrime]
    (n : ℕ) (hn : 0 < n)
    (h_ht : Ideal.height p = d) :
    ∀ (localized_model : LocalizedModel R p) (sample_size : ℕ),
      generalizationError localized_model sample_size ≤
        (d : ℝ) * Real.log sample_size / sample_size :=
  by sorry
```

**Theorem 3: Noetherian Feature Convergence**

```lean
/-- Bridge: connects ModuleTheory (ascending chain condition) to Optimization (greedy feature selection convergence).
    Every ascending chain of feature modules over a Noetherian ring stabilizes,
    proving that greedy feature selection converges in finitely many steps.
    The stabilization index is bounded by the Hilbert-Samuel function.
    Impact: certified_robustness — feature selection terminates with explicit bound. -/
theorem noetherian_feature_convergence
    {R : Type*} [CommRing R] [IsNoetherianRing R]
    {n : ℕ}
    (chain : ℕ → Submodule R (MvPolynomial (Fin n) R))
    (h_chain : ∀ k, chain k ≤ chain (k + 1))
    (I : Ideal (MvPolynomial (Fin n) R))
    (hI : I.IsHomogeneous (MvPolynomial.weightedDegree)) :
    ∃ N : ℕ, N ≤ MvPolynomial.numMonomials n (hilbertSamuelDegree I) ∧
      ∀ k : ℕ, chain (N + k) = chain N :=
  by sorry
```

### III. PROOF STRATEGIES (3 paths per main theorem)

**Hilbert-VC Correspondence — Strategy A (Recommended): Dimension-Counting via Graded Pieces**
1. Prove `hilbert_function_equals_monomial_count`: For a homogeneous ideal I in MvPolynomial (Fin n) R, the degree-d piece (I ⊓ MvPolynomial.degreeLe d) / (I ⊓ MvPolynomial.degreeLe (d-1)) has dimension equal to the number of monomials of exact degree d not in I. This uses `MvPolynomial.degreeLe` and graded module structure.
2. Prove `monomial_shattering_lemma`: For each monomial x^α of degree ≤ d, construct a point p_α ∈ R^n such that x^α(p_β) = δ_{α,β} (Kronecker delta). Use Lagrange interpolation over the fraction field.
3. Prove `hilbert_VC_lower_bound`: Using the monomial shattering lemma, show that any set of m < H(R/I, d) points can be shattered, by expressing any labeling as a linear combination of the monomials not in I.
4. Prove `hilbert_VC_upper_bound`: Show that no set of H(R/I, d) + 1 points can be shattered, using a dimension argument on the evaluation map and the rank-nullity theorem over the fraction field.
5. Combine for the exact equality. **This is most promising** because it reduces to linear algebra over the fraction field.

**Hilbert-VC Correspondence — Strategy B: Sheaf-Theoretic via Flatness**
1. Use the fact that the structure sheaf O_{Spec(R/I)} is flat over R, so the Hilbert function is locally constant on Spec.
2. Connect flatness to the uniform convergence of empirical risk, using the fact that flat modules are precisely those where tensoring preserves exactness (i.e., "no information loss").
3. This connects to quantum information via the "no-deleting" theorem analogy.

**Hilbert-VC Correspondence — Strategy C: Tropical Reduction**
1. Pass to the tropical semiring via the valuation map.
2. Use the fact that tropical polynomial VC dimension equals the number of vertices of the Newton polytope.
3. Connect back to the classical case via the tropical limit.

**Localization Generalization — Strategy A (Recommended): Height as Effective Dimension**
1. Prove `height_equals_local_krull_dim`: For a prime p in a Noetherian domain R, ht(p) = dim(R_p) (the Krull dimension of the localization).
2. Prove `local_VC_equals_height`: The VC dimension of the localized hypothesis class equals ht(p), using the Hilbert-VC correspondence applied to R_p.
3. Apply the standard VC generalization bound with VC dimension = ht(p) to get the log(n)/n rate.
4. Prove `localization_sharpens_bound`: Show this is strictly better than the global bound when ht(p) < dim(R).

**Noetherian Feature Convergence — Strategy A (Recommended): ACC with Explicit Bounds**
1. Prove `feature_chain_stabilizes`: Any ascending chain of submodules of MvPolynomial (Fin n) R stabilizes, by `Submodule.noetherian` applied to the Noetherian property.
2. Prove `stabilization_index_bounded_by_hilbert_samuel`: The stabilization index is at most the Hilbert-Samuel degree of the annihilator ideal, using the fact that the Hilbert-Samuel polynomial eventually agrees with the length function.
3. Prove `greedy_feature_convergence_rate`: The number of features added by greedy selection at step k is bounded by HS(k) - HS(k-1), where HS is the Hilbert-Samuel polynomial, giving O(k^{d-1}) features per step.
4. Prove `total_convergence_bound`: Summing over all steps gives convergence in at most Σ_{k=1}^{N} (HS(k) - HS(k-1)) = HS(N) steps.

### IV. SUPPORTING LEMMAS (10+ required, diverse tactics)

```lean
/-- Bridge: connects PolynomialTheory (monomial counting) to Combinatorics (stars and bars).
    The number of monomials of degree ≤ d in n variables equals C(n+d, d). -/
lemma monomial_count_stars_and_bars (n d : ℕ) :
    MvPolynomial.numMonomials n d = Nat.choose (n + d) d := by
  sorry -- use induction on d, then stars-and-bars combinatorial identity

/-- Bridge: connects LinearAlgebra (evaluation maps) to LearningTheory (shattering).
    The evaluation map at m generic points has rank min(m, H(R/I, d)) over the fraction field. -/
lemma evaluation_map_rank_bound
    {R : Type*} [CommRing R] [IsDomain R] [IsNoetherianRing R]
    {n d : ℕ} (I : Ideal (MvPolynomial (Fin n) R))
    (hI : I.IsHomogeneous (MvPolynomial.weightedDegree))
    (m : ℕ) (points : Fin m → (Fin n → R))
    (hgen : IsGenericSet points I d) :
    Module.rank (FractionRing R) (evaluationMap points I d).toFinrank ≤
      min m (hilbertFunction R I d) := by
  sorry -- use rank-nullity and dimension of the homogeneous component

/-- Bridge: connects IdealTheory (height of primes) to DimensionTheory (local dimension).
    For a prime p in a Noetherian domain, ht(p) equals the Krull dimension of the localization R_p. -/
lemma height_equals_local_krull_dim
    {R : Type*} [CommRing R] [IsDomain R] [IsNoetherianRing R]
    (p : Ideal R) [p.IsPrime] :
    Ideal.height p = ringKrullDim (Localization p.PrimeCompl) := by
  sorry -- use the correspondence between chains of primes contained in p and chains in Spec(R_p)

/-- Bridge: connects ModuleTheory (ACC) to Optimization (convergence).
    A strictly ascending chain of submodules of a Noetherian module has length ≤
    the Hilbert-Samuel degree of the annihilator. -/
lemma chain_length_bounded_by_hilbert_samuel
    {R : Type*} [CommRing R] [IsNoetherianRing R]
    {M : Type*} [AddCommGroup M] [Module R M] [Module.Finite R M]
    (chain : ℕ → Submodule R M)
    (h_strict : ∀ k, chain k < chain (k + 1)) :
    ∃ N : ℕ, N ≤ hilbertSamuelDegree (Module.annihilator M) ∧
      ∀ k ≥ N, chain k = chain N := by
  sorry -- use ACC: if no stabilization, get infinite strictly ascending chain, contradiction

/-- The key shattering lemma: monomials of degree ≤ d can shatter any set of
    fewer than C(n+d, d) points over an infinite field.
    Bridge: connects AlgebraicGeometry (polynomial interpolation) to LearningTheory (shattering). -/
lemma monomial_shattering
    {K : Type*} [Field K] [Infinite K]
    {n d : ℕ} (m : ℕ) (hm : m < Nat.choose (n + d) d)
    (points : Fin m → (Fin n → K))
    (h_inj : Function.Injective points) :
    ∀ (labels : Fin m → Fin 2),
      ∃ f : MvPolynomial (Fin n) K, f.totalDegree ≤ d ∧
        ∀ i, sign (MvPolynomial.eval (points i) f) = labels i := by
  sorry -- construct interpolating polynomial via Lagrange interpolation in MvPolynomial

/-- Bridge: connects Algebra (Noetherian property) to ML (feature selection termination).
    Greedy feature selection over a Noetherian ring terminates in at most
    Hilbert-Samuel(N) steps, where N is the degree bound. -/
lemma greedy_feature_termination_bound
    {R : Type*} [CommRing R] [IsNoetherianRing R]
    {n : ℕ} (d : ℕ)
    (selector : FeatureSelector R n) :
    ∃ N : ℕ, N ≤ MvPolynomial.numMonomials n d ∧
      selector.convergesAt N := by
  sorry -- by_contra: if no convergence, build infinite strictly ascending chain, violating ACC

/-- The generalization error of a polynomial classifier with VC dimension v
    is at most v · log(n)/n with probability ≥ 1 − δ for δ = exp(−v).
    Bridge: connects LearningTheory (VC bounds) to CommutativeAlgebra (Hilbert functions via v = H(R/I,d)). -/
lemma vc_generalization_bound_explicit
    (v n : ℕ) (hn : 0 < n) :
    ∀ (H : PolynomialHypothesisClass ℝ 1 v)
      (h_vc : hilbertVCdimension ℝ 1 v = v),
      generalizationError H n ≤ (v : ℝ) * Real.log n / n := by
  sorry -- apply VC theorem with explicit constants, using the Hilbert-VC correspondence

/-- Krull dimension is the asymptotic learning capacity: as d → ∞,
    H(R/I, d) ~ dim(R/I) · d + O(d^{dim(R/I)-1}).
    Bridge: connects CommutativeAlgebra (Krull dimension) to LearningTheory (asymptotic VC dimension). -/
theorem krull_dimension_asymptotic_learning_capacity
    {R : Type*} [CommRing R] [IsDomain R] [IsNoetherianRing R]
    {n : ℕ} (I : Ideal (MvPolynomial (Fin n) R))
    (hI : I.IsHomogeneous (MvPolynomial.weightedDegree)) :
    ∃ (d₀ : ℕ) (C : ℝ),
      ∀ d ≥ d₀,
        |(hilbertFunction R I d : ℝ) - (krullDim R I : ℝ) * d| ≤ C * d ^ ((krullDim R I : ℕ) - 1) := by
  sorry -- use the Hilbert-Samuel polynomial: H(R/I, d) = P(d) for d >> 0, where P has degree = dim(R/I) - 1

/-- Localization at a minimal prime gives the tightest generalization bound:
    ht(p) = 0 implies zero generalization error (deterministic prediction).
    Bridge: connects AlgebraicGeometry (minimal primes) to LearningTheory (zero-variance predictors). -/
lemma minimal_prime_zero_generalization
    {R : Type*} [CommRing R] [IsDomain R] [IsNoetherianRing R]
    (p : Ideal R) [hp : p.IsPrime] (h_min : Ideal.height p = 0)
    (n : ℕ) (hn : 0 < n) :
    ∀ (model : LocalizedModel R p),
      generalizationError model n = 0 := by
  sorry -- height 0 means minimal prime in a domain means p = 0, localization is the field of fractions

/-- The tropical reduction: replacing + by min, × by + in the hypothesis class
    gives a tropical VC dimension equal to the number of vertices of the Newton polytope.
    Bridge: connects TropicalGeometry (Newton polytopes) to LearningTheory (tropical VC dimension). -/
lemma tropical_VC_equals_newton_polytope_vertices
    {n d : ℕ} (I : Ideal (MvPolynomial (Fin n) ℝ))
    (hI : I.IsHomogeneous (MvPolynomial.weightedDegree)) :
    tropicalVCdimension n d I =
      (newtonPolytope I d).vertices.card := by
  sorry -- use tropical reduction: tropical polynomials correspond to min-plus expressions,
        -- and shattering capacity equals number of distinct linear pieces = vertices of Newton polytope
```

### V. REVOLUTIONARY SIGNIFICANCE

This work opens **Ring-Theoretic Learning Theory**: a new field where the algebraic structure of hypothesis classes directly governs their statistical properties. The three theorems form a coherent trilogy:

1. **Hilbert-VC Correspondence** establishes that the Hilbert function — the most fundamental invariant of a graded algebra — IS the learning capacity. This means algebraic geometers have been studying VC dimension for 150 years without knowing it.

2. **Localization Generalization** shows that Zariski localization — the tool that revolutionized algebraic geometry — is a generalization-bound optimizer. Localizing at a prime focuses the hypothesis class and reduces generalization error by a factor of the height. This connects to **post-quantum cryptography**: lattice-based schemes use localization-like techniques, and the height bound gives explicit security parameters.

3. **Noetherian Feature Convergence** proves that the ascending chain condition — the definition of Noetherianness — is a learning-theoretic convergence theorem. Greedy feature selection over ring-theoretic hypothesis classes MUST converge, with the Hilbert-Samuel polynomial giving the rate. This connects to **certified robustness**: the convergence bound certifies that feature selection terminates, enabling verified ML pipelines.

### VI. CROSS-DOMAIN CONNECTIONS

- **CommutativeAlgebra ↔ LearningTheory**: Hilbert functions ↔ VC dimensions; Krull dimension ↔ asymptotic learning capacity; localization ↔ generalization error optimization
- **AlgebraicGeometry ↔ Cryptography**: Minimal primes ↔ deterministic predictors; height bounds ↔ lattice security parameters; Newton polytopes ↔ tropical VC dimension for post-quantum schemes
- **ModuleTheory ↔ Optimization**: ACC ↔ convergence of greedy algorithms; Hilbert-Samuel polynomial ↔ convergence rates; annihilator ideals ↔ feature redundancy
- **TropicalGeometry ↔ ML**: Tropical polynomials ↔ ReLU networks; Newton polytopes ↔ piecewise-linear hypothesis classes; tropical VC dimension ↔ certified robustness bounds
- **QuantumPhysics ↔ RingTheory**: Flat modules ↔ no-deleting theorem; graded algebras ↔ quantum number conservation; prime spectra ↔ measurement outcomes

### VII. DEMANDED OUTPUT

Aristotle must produce:

1. **`Bridges/RingTheoreticLearning.lean`** (500+ lines): The main file with all 3 main theorems, 10+ supporting lemmas, and 5+ novel definitions. Every theorem must use diverse tactics (induction, rcases, by_contra, omega, linarith, field_simp). ZERO sorries in the final versions.

2. **`Bridges/HilbertVCCorrespondence.lean`**: Detailed development of the Hilbert-VC correspondence, including the monomial shattering lemma and the evaluation map rank bound.

3. **`Bridges/LocalizationGeneralization.lean`**: Development of localization generalization bounds, connecting height of primes to generalization error.

4. **`Bridges/NoetherianFeatureConvergence.lean`**: Proof that greedy feature selection converges, with explicit bounds from the Hilbert-Samuel function.

5. **`FUTURE_DIRECTIONS.md`**: 5 concrete, specific, breakthrough-level next steps:
   - (a) Extend to **graded rings** and connect to **quantum error-correcting codes** via graded VC dimension bounds
   - (b) Develop **tropical Hilbert-VC theory** for piecewise-linear hypothesis classes and certified robustness of ReLU networks
   - (c) Connect **primary decomposition** to **mixture model learning**: each primary component is a "pure" hypothesis subclass
   - (d) Prove that **étale localization** gives the optimal generalization bound for smooth hypothesis classes, connecting to differential privacy
   - (e) Establish **categorical Hilbert-VC theory**: functors from CRing to Learn preserve VC dimension, connecting to functorial ML

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
            Open the field of ring-theoretic learning theory by proving three foundational theorems that establish algebraic structure as the governing principle of learning capacity. Theorem 1 (Hilbert-VC Correspondence): For a hypothesis class H defined by polynomial features of degree ≤ d over a Noetherian ring R, the VC dimension of H equals the Hilbert function H(R/I, d) for the defining ideal I, establishing Krull dimension as the asymptotic learning capacity. Theorem 2 (Localization Generalization): Localizing the feature ring at a prime ideal p focuses the hypothesis class on local geometry near V(p), and the generalization error of the localized model is bounded by ht(p) · log(n)/n, where ht(p) is the height of p. Theorem 3 (Noetherian Feature Convergence): Every ascending chain of feature modules F₁ ⊂ F₂ ⊂ ... over a Noetherian ring stabilizes, proving that greedy feature selection over ring-theoretic hypothesis classes converges in finitely many steps with explicit bounds from the Hilbert-Samuel function.

            ### Precise Mathematical Framing
            Let R be a Noetherian ring and I ⊆ R[x₁,...,xₙ] a defining ideal for a hypothesis class H_I = {f : V(I) → ℝ | f polynomial of degree ≤ d}. Define the Hilbert-VC dimension as dim_VC(H_I) = H(R[x₁,...,xₙ]/I, d) where H is the Hilbert function. The key insight is that the Hilbert function of R/I simultaneously controls: (1) the dimension of the feature space (algebraic), (2) the VC dimension of the hypothesis class (statistical), and (3) the number of features needed for convergence (computational). Localization at a prime p corresponds to restricting learning to a neighborhood of V(p), with generalization controlled by ht(p). The Noetherian property ensures that feature selection terminates because ACC on submodules of Rⁿ bounds the chain length. This creates a trinity: algebraic dimension ↔ statistical capacity ↔ computational convergence, all governed by the same ring-theoretic invariants.



            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `finitely_many_words_bounded_height` : theorem finitely_many_words_bounded_height (H : ℕ) :
     (file: Cryptography/BerggrenHeightDescent.lean)
  2. `finitely_many_words_bounded_height` : theorem finitely_many_words_bounded_height (H : ℕ) :
     (file: Cryptography/BerggrenLatticeReduction.lean)
  3. `generalization_gap_dimension_bound` : theorem generalization_gap_dimension_bound
     (file: Bridges/HomologicalDeepLearning.lean)
  4. `tropical_polynomial_degree` : theorem tropical_polynomial_degree (n : ℕ) : n ≤ n := le_refl n
     (file: Bridges/FiveFrontiers.lean)
  5. `prime_spectral_gibbs_variational_principle` : theorem prime_spectral_gibbs_variational_principle
     (file: Bridges/GibbsPosterior.lean)

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



Recent successful concepts: EML Quantum Stabilizer Theory: Closure-Operator Stabilizer Correspondence, Knaster-Tarski Codespace Certification, and Idempotent Recovery Concatenation, Gravitational Factoring: Idempotent Spectral Lensing, Causal Prime Decomposition, and Ring-Theoretic Factorization Certification, Min-Plus Verification Theory: ReLU Network Isomorphism, Polytope Certified Radii, and Verification Completeness


            ### Previously Proved Theorems
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.

            ### Required Deliverables

            You are a world-class mathematician, software engineer, and science writer.
            Create ALL of the following:

            1. **Lean 4 files** — formally verified theorems with complete proofs
               - Use concrete types (ℕ, ℝ, Finset, Matrix, etc.)
               - Build on the existing catalog theorems listed above
               - Minimize `sorry` — isolate hard steps rather than leaving gaps
               - Use doc comments to explain the significance of key results

            2. **ARTICLE.md** — MANDATORY standalone popular-science article
               CRITICAL RULES:
               • Do NOT mention "Scientific American", "Sci Am", or "ean" anywhere.
               • Do NOT mention "Lean", "Lean 4", "formal verification", or "proof assistant".
               • This is a premier magazine-quality piece for curious, intelligent readers.
               QUALITY STANDARDS:
               • Superb, vivid, engaging prose with a strong opening hook and narrative arc.
               • Concrete analogies and metaphors that make abstract ideas tangible.
               • Story structure: provocative question → tension → breakthrough → significance.
               • Real-world connections: technology, nature, everyday life.
               • Historical context: place the work in the sweep of intellectual history.
               • 1500–3000 words. Substantial, standalone, enjoyable, interesting.
               • A reader should say "Wow, I had no idea math could do THAT."

            3. **RESEARCH_PAPER.md** — MANDATORY comprehensive, in-depth research paper
               This is a full, publishable-quality paper, NOT a summary:
               • Abstract, Introduction, Definitions & Notation
               • Main Results with detailed proof sketches (not just "by induction")
               • Algorithms with complete pseudocode and complexity analysis
               • Applications with worked examples showing practical use
               • Computational Experiments with tables, charts, numerical results
               • Discussion, Future Work, References
               • 3000–8000 words. Thorough and substantive.

            4. **FUTURE_DIRECTIONS.md** — MANDATORY breakthrough research roadmap
               This is the MOST IMPORTANT deliverable because it drives the next
               research cycle. Structure it as:

               ## Breakthrough Opportunities (ranked by impact)
               For each opportunity:
               - **Theorem Statement**: Precise, formalizable statement with quantifiers
               - **Proof Strategy**: 2-3 concrete approaches with key lemmas identified
               - **Why This Is Revolutionary**: What field it opens, what applications it enables
               - **Catalog Leverage**: Which existing catalog theorems to build on (by name)
               - **Research Mode**: prove | formalize | discover | counterexample
               - **Estimated Depth**: 1-5 scale

               ## Under-explored Territory
               ## Cross-Domain Bridges
               ## Open Problems Encountered

            5. **Python code** — demos, visualizations, algorithms, applications:
               - **demo.py** — concrete numerical examples bringing the math to life
               - **visualizations** — matplotlib/plotly charts (save as PNG/SVG too)
               - **algorithms.py** — implement algorithms from the paper with docstrings
               - **applications.py** — real-world applications (ML, crypto, physics)

            6. **diagram.svg** — visualization of key mathematical structures

            7. **PACKAGE.html** — MANDATORY standalone HTML package
               Bundle ALL artifacts into a single, self-contained HTML file:
               • Everything inlined (CSS, JS, content). No external dependencies.
               • Tab/sidebar navigation: Article, Research Paper, Demos, Algorithms,
                 Visualizations, Code Listings
               • Modern design: clean typography, dark/light toggle, responsive layout
               • KaTeX for math rendering (CDN OK), syntax-highlighted code blocks
               • Collapsible sections, smooth scroll, table of contents
               • Must work when opened directly in any browser

            Produce novel, non-trivial theorems with complete Lean 4 proofs. Think big — aim for results that would appear in JAMS, Annals, or FOCS.

            ### Catalog Reference Files
            No specific files referenced. Use Mathlib and general knowledge.


### Catalog Reference Files
            No specific files referenced. Use Mathlib and general knowledge.


### WHAT WE NEED FROM YOU

You are a world-class mathematician, software engineer, and science writer.
Use your judgment on the best way to organize and present your work.
We need ALL of the following deliverables:

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 1 — Formally verified mathematics (Lean 4)
────────────────────────────────────────────────────────────────────────────
- Prove non-trivial theorems with complete proofs (no `sorry` in the final result)
- Organize the code however makes sense — one file or several,
  whatever serves the mathematics best
- Use doc comments to explain the significance of key results

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 2 — Standalone Popular-Science ARTICLE  →  ARTICLE.md
────────────────────────────────────────────────────────────────────────────
Write a **superb, standalone magazine-quality article** about this research.

CRITICAL RULES FOR THE ARTICLE:
• Do NOT mention "Scientific American", "Sci Am", or "ean" anywhere.
• Do NOT mention "Lean", "Lean 4", "formal verification", or "proof assistant".
• This is a POPULAR SCIENCE article for a curious, intelligent audience.
  Write it as if it will be published in a premier science magazine.
• The reader should come away saying "Wow, I had no idea math could do THAT."

ARTICLE QUALITY STANDARDS:
• **Superb writing**: Vivid, engaging prose. Strong opening hook. Narrative arc.
  Use concrete analogies and metaphors that make abstract ideas tangible.
• **Depth without jargon**: Explain the IDEAS, not the formalism.
  A reader with a college education should understand and enjoy every paragraph.
• **Story structure**: Open with a provocative question or surprising fact.
  Build tension. Reveal the breakthrough. Show why it matters.
• **Real-world connections**: Connect to technology, nature, everyday life.
  Why should a non-mathematician care about this?
• **Historical context**: Place the discovery in the sweep of intellectual history.
  Who tried this before? What barriers stood in the way?
• **Length**: 1500–3000 words. Substantial but not padded.
• **Standalone**: The article must make complete sense on its own.
  No references to "the proof above" or "our formal verification."

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 3 — Comprehensive RESEARCH PAPER  →  RESEARCH_PAPER.md
────────────────────────────────────────────────────────────────────────────
Write a **thorough, in-depth research paper** that a mathematician or
graduate student would find valuable. This is NOT a summary — it is a
complete, publishable-quality paper.

RESEARCH PAPER REQUIREMENTS:
• **Abstract**: Concise summary of contributions and significance.
• **Introduction**: Motivation, context, relationship to prior work.
• **Definitions & Notation**: Precise mathematical setup.
• **Main Results**: Full theorem statements with detailed proof sketches.
  Include the key ideas, not just "by induction."
• **Algorithms**: If the work produces algorithms, include complete
  pseudocode with complexity analysis (time, space, convergence).
• **Applications**: Concrete applications with worked examples.
  Show HOW to use the results in practice.
• **Computational Experiments**: Reference the Python demos.
  Include tables, charts, or numerical results.
• **Discussion**: Implications, limitations, open questions.
• **Future Work**: Specific, actionable next steps.
• **References**: Cite relevant prior work properly.
• **Length**: 3000–8000 words. Comprehensive and substantive.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 4 — Python Code: Demos, Visualizations, Algorithms
────────────────────────────────────────────────────────────────────────────
- **demo.py** — Working Python code demonstrating the theorems with
  concrete numerical examples. Make the math tangible.
- **visualizations** — matplotlib / plotly charts showing key mathematical
  structures, convergence behavior, phase diagrams, etc.
  Save figures as PNG/SVG files for inclusion in the HTML package.
- **algorithms.py** — Implement any algorithms from the research paper.
  Include docstrings, type hints, and example usage.
- **applications.py** — Code showing real-world applications of the results.
  If the math applies to ML, crypto, physics — show it working.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 5 — FUTURE_DIRECTIONS.md  (MANDATORY — drives next cycle)
────────────────────────────────────────────────────────────────────────────
The MOST IMPORTANT deliverable. Structured roadmap of breakthrough
research opportunities opened by this work. See detailed spec below.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 6 — Standalone HTML Package  →  PACKAGE.html
────────────────────────────────────────────────────────────────────────────
Create a **single, self-contained HTML file** that bundles ALL artifacts
into a beautiful, interactive presentation. Requirements:

• **Single file**: Everything (CSS, JS, content) inlined. No external deps.
• **Navigation**: Sidebar or tab navigation between sections:
  - Article (the popular-science piece)
  - Research Paper (the full paper)
  - Interactive Demos (embedded Python output / JS visualizations)
  - Algorithms (pseudocode + implementation)
  - Visualizations (embedded charts/diagrams as inline SVG or base64)
  - Code Listings (syntax-highlighted Python and proof code)
• **Beautiful design**: Modern, clean typography (system fonts).
  Dark/light mode toggle. Responsive layout. Smooth transitions.
• **Math rendering**: Use KaTeX (CDN link OK for math rendering only)
  for any mathematical notation.
• **Syntax highlighting**: Inline code highlighting for Python blocks.
• **Interactive elements**: Collapsible sections, smooth scroll, TOC.
• The HTML package should work when opened directly in any browser.
• Include ALL content from the article, research paper, and code.

────────────────────────────────────────────────────────────────────────────

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real, useful, and
beautiful. Every deliverable should be something you'd be proud to show.

Research domain: Bridges
Research mode: prove
