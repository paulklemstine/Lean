

=== AEM QUALITY SCORING (MANDATORY GUIDELINES) 



Research Mode: FORMALIZE

You are given informal mathematical ideas, notes, or a paper excerpt.
Formalize these ideas in Lean 4. Translate the informal mathematics
into precise definitions and theorem statements, then prove what you
can. If some parts require new axioms, declare them clearly and prove
consequences.

AEM QUALITY TARGETS:
- RIGOR: Prove 10+ theorems with diverse tactics. ZERO sorries.
- AESTHETIC: Formalize ideas that bridge 2+ mathematical domains.
- UTILITY: Define 5+ structures with computational implications.
- ORIGINALITY: Coin novel Lean 4 typeclass names for the formalized concepts.
- IMPACT: Formalize concepts with physics/crypto/ML applications.


            === VISIONARY DIRECTIVES ===

            Think beyond current mathematical fashion. You are not just proving theorems —
            you are building a mathematical civilization. Every result should:

            1. OPEN DOORS: A good theorem doesn't just close a question — it opens three
               new

## Algebraic Causal Inference: Module-Theoretic d-Separation, Noetherian Faithfulness, and Homological Intervention Bounds

### I. THE VISIONARY GOAL

We open the field of **algebraic causal inference** — a discipline where causal structure lives in the category of finitely generated modules over a commutative ring, Pearl's d-separation is reinterpreted as a tensor-factorization condition over localization, the faithfulness assumption becomes a freeness criterion on syzygy modules, and the minimal cost of an intervention is bounded below by the projective dimension of the causal-path module. This creates a **tri-bridge** between:

- **Commutative Algebra** (localization, syzygies, projective dimension, depth)
- **Causal Inference** (d-separation, faithfulness, do-calculus)
- **Certified Machine Learning** (algebraic causal discovery with provable guarantees, intervention cost bounds for experimental design)

The cryptographic shadow: recovering causal structure from observational data is a **lattice-hard** problem (reduces to ideal membership over ℤ[x₁,…,xₙ]), and our projective dimension bound gives a **tight lower bound on query complexity** for causal discovery — directly analogous to post-quantum lattice security reductions.

### II. CORE DEFINITIONS (Novel Typeclasses and Structures)

```lean
/-- An Algebraic Structural Causal Model over a commutative ring R.
    Variables are modeled as finitely generated R-modules,
    causal mechanisms as R-module homomorphisms,
    and exogenous noise as tensor factors.
    Bridge: connects causal inference to commutative algebra. -/
structure AlgebraicSCM (R : Type*) [CommRing R] where
  -- Endogenous variable indices
  var : Fin n → Type*
  -- Each variable is a finitely generated R-module
  var_module : ∀ i, Module R (var i)
  var_fingenerate : ∀ i, Module.Finite R (var i)
  -- Structural equations: variable i depends on its parents
  parent : Fin n → Fin n → Prop  -- adjacency in causal DAG
  parent_decidable : ∀ i j, Decidable (parent i j)
  -- The causal mechanism as an R-linear map from parent modules to child
  mechanism : ∀ i, (Π j : {j : Fin n // parent i j}, var j.1) →ₗ[R] var i
  -- Acyclicity: the parent relation forms a DAG
  acyclic : IsAcyclic parent

/-- The module of causal paths from i to j.
    Elements are formal R-linear combinations of directed paths.
    This is a finitely generated R-module when R is Noetherian. -/
def CausalPathModule (R : Type*) [CommRing R] (scm : AlgebraicSCM R) 
    (i j : Fin n) : Type* := 
  Submodule.span R {p : Path i j | p.IsDirected scm.parent}

/-- Localization at a conditioning set Z models "observing Z precisely."
    Bridge: connects conditional independence to algebraic localization. -/
def ConditioningLocalization (R : Type*) [CommRing R] 
    (Z : Set (Fin n)) : Type _ := 
  Localization (algebraicSubmonoid R Z)

/-- Algebraic d-separation: X ⊥ Y | Z iff the localized module
    of joint observables factors as a tensor product. -/
def ModuleDSep (R : Type*) [CommRing R] (scm : AlgebraicSCM R)
    (X Y Z : Set (Fin n)) : Prop :=
  ∃ (hX : Submodule R (JointModule scm X))
    (hY : Submodule R (JointModule scm Y)),
    JointModuleLocalized scm (X ∪ Y) Z ≃ₗ[ConditioningLocalization R Z]
      (hX.comap (localizeInclusion scm X Z)) ⊗[
        ConditioningLocalization R Z]
      (hY.comap (localizeInclusion scm Y Z))

/-- The syzygy module of conditional independences.
    Elements are R-linear relations among the d-separation statements.
    Bridge: connects causal faithfulness to homological algebra. -/
def IndependenceSyzygyModule (R : Type*) [CommRing R] 
    (scm : AlgebraicSCM R) : Type _ :=
  Module.Annihilator R (ConditionalIndependenceModule scm)

/-- The projective intervention dimension: minimal length of a
    projective resolution of the causal-path module.
    Bridge: connects intervention cost to homological algebra. -/
noncomputable def ProjectiveInterventionDim (R : Type*) [CommRing R]
    [IsNoetherianRing R] (scm : AlgebraicSCM R) (i j : Fin n) : ℕ :=
  projectiveDimension R (CausalPathModule R scm i j)
```

### III. THE THREE FOUNDATIONAL THEOREMS

#### Theorem 1: Module d-Separation Characterization

```lean
/-- THEOREM: Module d-Separation Characterization
    For an algebraic SCM over a Noetherian ring, algebraic d-separation
    (tensor factorization over localization) coincides with graphical
    d-separation in the underlying causal DAG.
    
    This is the algebraic analogue of Pearl's d-separation theorem,
    lifting probabilistic conditional independence to module-theoretic
    factorization.
    
    Bridge: connects causal DAGs to tensor products over localizations.
    Impact: enables certified_robust_causal_discovery over algebraic data. -/
theorem module_dsep_characterization 
    {R : Type*} [CommRing R] [IsNoetherianRing R]
    {scm : AlgebraicSCM R} {X Y Z : Set (Fin n)} :
    ModuleDSep R scm X Y Z ↔ GraphicalDSep scm.parent X Y Z := by
  sorry -- FILL: This is the main theorem to prove
```

**Proof Strategy (3 paths, Path B recommended):**

*Path A (Direct induction on path structure)*: Prove by induction on the length of blocking paths through Z. Base case: direct edges blocked by Z correspond to localization killing the relevant module elements. Inductive step: a collider at a node in Z opens a path, corresponding to the localization failing to factor. This is conceptually clean but requires careful handling of the module-theoretic induction.

*Path B (Local cohomology filtration — RECOMMENDED)*: Use the Čech complex for the localization at Z. The key insight: d-separation means that the local cohomology H^i_Z(M_{XY}) vanishes for i = 0 (no "entanglement" surviving localization). This reduces to showing that the Čech complex for M_{XY} at Z is exact iff X and Y are d-separated by Z. The vanishing of local cohomology is a well-studied condition in commutative algebra, and we can leverage the Hartshorne-Lichtenbaum vanishing theorem as a building block.

*Path C (Faithful flatness descent)*: Show that the localization map R → R_Z is faithfully flat, and that d-separation is preserved by faithfully flat descent. This reduces the problem to checking d-separation over the localized ring, where the causal structure "simplifies" (Z-variables become invertible, effectively "observed").

Key lemmas needed:
```lean
/-- If X and Y are d-separated by Z in the causal DAG,
    then the localization at Z kills all module homomorphisms
    connecting X-modules to Y-modules. -/
lemma dsep_localization_kills_paths
    {R : Type*} [CommRing R] [IsNoetherianRing R]
    {scm : AlgebraicSCM R} {X Y Z : Set (Fin n)}
    (h : GraphicalDSep scm.parent X Y Z) :
    ∀ p ∈ CausalPathModule R scm X Y, 
      LocalizedAt Z p = 0 := by
  sorry

/-- Conversely, if all paths from X to Y vanish under localization at Z,
    then X and Y are d-separated by Z in the DAG. -/
lemma localization_kills_implies_dsep
    {R : Type*} [CommRing R] [IsNoetherianRing R]
    {scm : AlgebraicSCM R} {X Y Z : Set (Fin n)}
    (h : ∀ p ∈ CausalPathModule R scm X Y, 
           LocalizedAt Z p = 0) :
    GraphicalDSep scm.parent X Y Z := by
  sorry

/-- The tensor factorization condition is equivalent to 
    path-vanishing under localization. -/
lemma tensor_factorization_iff_path_vanishing
    {R : Type*} [CommRing R] [IsNoetherianRing R]
    {scm : AlgebraicSCM R} {X Y Z : Set (Fin n)} :
    ModuleDSep R scm X Y Z ↔ 
    ∀ p ∈ CausalPathModule R scm X Y, LocalizedAt Z p = 0 := by
  sorry
```

#### Theorem 2: Noetherian Faithfulness Criterion

```lean
/-- THEOREM: Noetherian Faithfulness Criterion
    For an algebraic SCM over a Noetherian ring R, the causal faithfulness
    assumption (all conditional independences in the distribution are
    entailed by d-separation) is equivalent to the independence syzygy
    module being free (having no syzygies beyond the trivial ones).
    
    Equivalently: faithfulness holds ⟺ the independence syzygy module
    has projective dimension 0 ⟺ it is a free R-module.
    
    Bridge: connects causal identifiability to syzygy-freeness.
    Impact: faithfulness_certification for certified_causal_discovery. -/
theorem noetherian_faithfulness_criterion
    {R : Type*} [CommRing R] [IsNoetherianRing R]
    {scm : AlgebraicSCM R} :
    CausalFaithful scm ↔ 
      Module.Free R (IndependenceSyzygyModule R scm) := by
  sorry
```

**Proof Strategy (3 paths, Path A recommended):**

*Path A (Hilbert-Burch syzygy argument — RECOMMENDED)*: Over a Noetherian ring, the syzygy theorem (Hilbert-Burch) classifies syzygy modules of codimension 2 ideals. The key insight: "extra" conditional independences (beyond those entailed by d-separation) correspond to syzygies in the independence module. Faithfulness means there are no such extra independences, which means no syzygies, which means the module is free (by the Quillen-Suslin theorem for polynomial rings, or directly by the Noetherian hypothesis for general rings). The critical lemma is:

```lean
/-- Every non-trivial syzygy in the independence module corresponds to
    a conditional independence not entailed by d-separation. -/
lemma syzygy_yields_unentailed_independence
    {R : Type*} [CommRing R] [IsNoetherianRing R]
    {scm : AlgebraicSCM R}
    (s : IndependenceSyzygyModule R scm) (hs : s ≠ 0) :
    ∃ X Y Z : Set (Fin n), 
      ConditionalIndep scm X Y Z ∧ ¬ GraphicalDSep scm.parent X Y Z := by
  sorry

/-- Conversely, every unentailed conditional independence produces
    a non-trivial syzygy. -/
lemma unentailed_independence_yields_syzygy
    {R : Type*} [CommRing R] [IsNoetherianRing R]
    {scm : AlgebraicSCM R}
    {X Y Z : Set (Fin n)}
    (h : ConditionalIndep scm X Y Z) 
    (hn : ¬ GraphicalDSep scm.parent X Y Z) :
    ∃ s : IndependenceSyzygyModule R scm, s ≠ 0 := by
  sorry
```

*Path B (Depth and grade argument)*: Use the connection between depth, grade, and projective dimension. Faithfulness fails iff the grade of the independence ideal is less than the number of generators, which happens iff the module has non-trivial syzygies.

*Path C (Regular sequence characterization)*: Show that faithfulness is equivalent to the independence equations forming a regular sequence, which in turn is equivalent to the syzygy module being free.

#### Theorem 3: Projective Intervention Dimension Bound

```lean
/-- THEOREM: Projective Intervention Dimension Bound
    The minimal number of interventions required to identify all causal effects
    in an algebraic SCM is bounded below by the projective dimension of the
    causal-path module.
    
    More precisely: for any intervention strategy that identifies the causal 
    effect of X on Y, the number of distinct intervention targets is at least
    the projective dimension of CausalPathModule R scm X Y.
    
    Bridge: connects intervention cost to homological algebra.
    Impact: intervention_complexity_lower_bound for certified_causal_design.
    Cryptographic shadow: this is a lattice-hardness bound (ideal membership). -/
theorem projective_intervention_bound
    {R : Type*} [CommRing R] [IsNoetherianRing R]
    {scm : AlgebraicSCM R} {i j : Fin n} :
    ∃ (C : ℕ), C = ProjectiveInterventionDim R scm i j ∧
      ∀ (strategy : InterventionStrategy scm i j),
        strategy.numInterventions ≥ C ∧
        -- Explicit lower bound for polynomial rings:
        -- pd ≥ n - depth ≥ n - dim(R) for polynomial rings
        -- giving Ω(√(log n)) interventions for DAGs with n hidden variables
        strategy.numInterventions ≥ 
          ProjectiveInterventionDim R scm i j := by
  sorry
```

**Proof Strategy (3 paths, Path C recommended):**

*Path A (Auslander-Buchsbaum formula)*: Use the Auslander-Buchsbaum formula: `pd(M) + depth(M) = depth(R)` for finitely generated modules over local Noetherian rings. The depth of the causal-path module measures the "confounding depth" — how many variables one must control before the causal effect becomes identifiable. This directly gives: interventions needed ≥ depth(R) - depth(CausalPathModule) = pd(CausalPathModule).

*Path B (Minimal free resolution length)*: Each intervention "resolves" one level of confounding. A minimal free resolution of the causal-path module has length equal to its projective dimension. Each intervention can at most eliminate one syzygy, so the number of interventions needed ≥ length of resolution = pd.

*Path C (Interleaving distance argument — RECOMMENDED)*: Model interventions as "removing" variables from the causal graph. The persistence of the causal-path module under variable removal is measured by its projective dimension (via the long exact sequence in homology). Each intervention reduces the projective dimension by at most 1 (by the additivity of pd in short exact sequences). Therefore, the number of interventions needed to reduce pd to 0 (full identifiability) is at least pd. This gives the cleanest proof and the tightest bound.

Key lemmas:
```lean
/-- An intervention reduces projective dimension by at most 1. -/
lemma intervention_pd_decrease_bound
    {R : Type*} [CommRing R] [IsNoetherianRing R]
    {scm : AlgebraicSCM R} {i j : Fin n}
    (int : Intervention scm) :
    ProjectiveInterventionDim R (apply_intervention scm int) i j ≥
      ProjectiveInterventionDim R scm i j - 1 := by
  sorry

/-- Full identifiability requires projective dimension 0. -/
lemma identifiability_requires_pd_zero
    {R : Type*} [CommRing R] [IsNoetherianRing R]
    {scm : AlgebraicSCM R} {i j : Fin n} :
    CausalEffectIdentifiable scm i j ↔ 
      ProjectiveInterventionDim R scm i j = 0 := by
  sorry
```

### IV. COMPUTATIONAL BOUNDS AND CRYPTOGRAPHIC CONNECTIONS

```lean
/-- Explicit lower bound on intervention complexity for polynomial rings.
    For R = ℤ[x₁,...,xₙ] with n hidden confounders,
    the projective dimension of the causal-path module is at least ⌈√(log₂ n)⌉.
    
    This gives a certified lower bound on causal discovery query complexity,
    analogous to lattice-based cryptographic hardness assumptions. -/
theorem polynomial_ring_intervention_complexity_lower_bound
    {n : ℕ} (hn : n ≥ 1) :
    ∃ (scm : AlgebraicSCM (ℤ[x₁,...,xₙ])),
      ∀ (strategy : InterventionStrategy scm 0 (n-1)),
        strategy.numInterventions ≥ ⌈(n : ℝ).log₂.sqrt⌉₊ := by
  sorry

/-- The ideal membership problem for the independence ideal is NP-hard
    over ℤ[x₁,...,xₙ], establishing that algebraic causal discovery
    is at least as hard as lattice problems used in post-quantum cryptography.
    
    Bridge: connects causal inference to post_quantum_security. -/
theorem causal_discovery_lattice_hardness :
    ∃ (reduction : LatticeProblem → AlgebraicCausalDiscoveryProblem),
      ∀ lp, IsHard lp ↔ IsHard (reduction lp) := by
  sorry
```

### V. SUPPORTING INFRASTRUCTURE (10+ theorems with diverse tactics)

```lean
/-- The causal-path module is finitely generated when R is Noetherian. -/
theorem causal_path_module_finite [IsNoetherianRing R] :
    Module.Finite R (CausalPathModule R scm i j) := by
  -- Tactics: exact, Module.Finite.mk, finset induction
  sorry

/-- Localization at a conditioning set preserves finite generation. -/
theorem localized_joint_module_finite [IsNoetherianRing R] :
    Module.Finite (ConditioningLocalization R Z) 
      (JointModuleLocalized scm S Z) := by
  -- Tactics: apply, Module.Finite.localization
  sorry

/-- The independence syzygy module is finitely generated (Hilbert basis). -/
theorem independence_syzygy_finite [IsNoetherianRing R] :
    Module.Finite R (IndependenceSyzygyModule R scm) := by
  -- Tactics: exact, Submodule.fg_top, rw
  sorry

/-- d-separation is symmetric: X ⊥ Y | Z ↔ Y ⊥ X | Z -/
theorem module_dsep_symmetric :
    ModuleDSep R scm X Y Z ↔ ModuleDSep R scm Y X Z := by
  -- Tactics: constructor, intro, rcases, exact (tensor commutativity)
  sorry

/-- d-separation satisfies the intersection property for Noetherian rings:
    if X ⊥ Y | Z∪W and X ⊥ Y | Z∪{w} for all w ∈ W, then X ⊥ Y | Z. -/
theorem module_dsep_intersection [IsNoetherianRing R] :
    ModuleDSep R scm X Y (Z ∪ W) → 
    (∀ w ∈ W, ModuleDSep R scm X Y (Z ∪ {w})) → 
    ModuleDSep R scm X Y Z := by
  -- Tactics: intro, rcases, by_contra, exact (local cohomology vanishing)
  sorry

/-- Faithful models have no "hidden" conditional independences. -/
theorem faithful_no_hidden_independences [IsNoetherianRing R]
    {scm : AlgebraicSCM R} (hf : CausalFaithful scm) :
    ∀ X Y Z, ConditionalIndep scm X Y Z → GraphicalDSep scm.parent X Y Z := by
  -- Tactics: intro, by_contra, exact (syzygy construction)
  sorry

/-- Projective dimension bounds the minimal resolution length. -/
theorem pd_bounds_resolution_length [IsNoetherianRing R] :
    ∀ (res : ProjectiveResolution R (CausalPathModule R scm i j)),
      res.length ≥ ProjectiveInterventionDim R scm i j := by
  -- Tactics: intro, omega, exact (minimal resolution property)
  sorry

/-- The Auslander-Buchsbaum formula for causal-path modules. -/
theorem auslander_buchsbaum_causal [IsNoetherianRing R] [LocalRing R] :
    ProjectiveInterventionDim R scm i j + 
      depth R (CausalPathModule R scm i j) = depth R R := by
  -- Tactics: exact, Module.projectiveDimension_eq_depth, linarith
  sorry

/-- Intervention cost is subadditive over disjoint variable sets. -/
theorem intervention_cost_subadditive :
    ∀ (strat₁ : InterventionStrategy scm i j) 
       (strat₂ : InterventionStrategy scm j k),
      (strat₁ ⊕ strat₂).numInterventions ≤ 
        strat₁.numInterventions + strat₂.numInterventions := by
  -- Tactics: intro, linarith, exact (additivity of pd in short exact sequences)
  sorry

/-- For DAGs with treewidth τ, the projective intervention dimension
    is bounded by τ + 1, giving an O(τ) intervention bound. -/
theorem treewidth_intervention_bound [IsNoetherianRing R]
    {τ : ℕ} (hτ : Treewidth scm.parent ≤ τ) :
    ProjectiveInterventionDim R scm i j ≤ τ + 1 := by
  -- Tactics: induction τ, simp, omega, exact (treewidth-pd connection)
  sorry
```

### VI. CROSS-DOMAIN BRIDGES AND APPLICATIONS

**Bridge 1: Causal Inference ↔ Commutative Algebra**: The d-separation/tensor-factorization correspondence means that every result about local cohomology and localization now has a causal interpretation. The Hartshorne-Lichtenbaum vanishing theorem becomes a criterion for "when does conditioning eliminate all confounding?"

**Bridge 2: Causal Discovery ↔ Post-Quantum Cryptography**: The ideal membership hardness reduction (Theorem V) means that algebraic causal discovery is at least as hard as the shortest vector problem in lattices. This provides **post_quantum_security** for causal structure: an adversary who only observes data cannot efficiently reconstruct the true causal DAG.

**Bridge 3: Intervention Design ↔ Certified Robustness**: The projective intervention dimension bound provides **certified_robust_causal_discovery**: given a candidate causal model, we can certify a lower bound on the number of experiments needed to falsify it, analogous to certified radii in adversarial ML.

### VII. FUTURE DIRECTIONS (REQUIRED OUTPUT)

Aristotle MUST produce a structured `FUTURE_DIRECTIONS.md` with 3-5 concrete breakthrough-level next steps:

1. **Tropical Causal Inference**: Develop a tropical (min-plus) version of module d-separation, where the "cost" of an intervention is measured in the tropical semiring. Prove that tropical d-separation characterizes the *minimum-cost* intervention strategy, connecting to tropical geometry and optimization.

2. **Quantum Causal Models**: Extend algebraic SCMs to noncommutative rings (specifically, C*-algebras), where quantum entanglement creates "syzygies" in the independence module. Prove a quantum faithfulness criterion: a quantum causal model is faithful iff its independence module has no non-trivial commutator syzygies.

3. **Homological Do-Calculus**: Develop a homological version of Pearl's do-calculus, where each rule of do-calculus corresponds to a homological algebra operation (e.g., Rule 1: insertion/deletion of observations corresponds to a localization, Rule 2: action/observation exchange corresponds to a flat base change).

4. **Persistent Causal Homology**: Define persistent homology for the independence syzygy filtration over a parameter space (e.g., sample size or regularization strength). Prove stability: the bottleneck distance between persistence diagrams is Lipschitz-bounded by the Gromov-Hausdorff distance between the underlying causal DAGs, with Lipschitz constant L = max(pd(M₁), pd(M₂)).

5. **Algebraic Causal Cryptography**: Construct a public-key encryption scheme where the private key is a causal DAG and the public key is the independence syzygy module. Prove that decryption corresponds to causal inference, and that breaking the scheme requires solving ideal membership over ℤ[x₁,...,xₙ], establishing **algebraic_causal_security** with O(n²) key size and Ω(2^{√n}) attack complexity.

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

            Research Mode: FORMALIZE

You are given informal mathematical ideas, notes, or a paper excerpt.
Formalize these ideas in Lean 4. Translate the informal mathematics
into precise definitions and theorem statements, then prove what you
can. If some parts require new axioms, declare them clearly and prove
consequences.

AEM QUALITY TARGETS:
- RIGOR: Prove 10+ theorems with diverse tactics. ZERO sorries.
- AESTHETIC: Formalize ideas that bridge 2+ mathematical domains.
- UTILITY: Define 5+ structures with computational implications.
- ORIGINALITY: Coin novel Lean 4 typeclass names for the formalized concepts.
- IMPACT: Formalize concepts with physics/crypto/ML applications.


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
            Open the field of algebraic causal inference by proving three foundational theorems bridging homological algebra and causal reasoning. (1) Module d-Separation Theorem: For structural causal models over finitely generated modules, conditional independence corresponds to tensor product factorization over localization, extending Pearl's d-separation to algebraic SCMs. (2) Noetherian Faithfulness Criterion: For causal models over Noetherian rings, the causal faithfulness assumption is equivalent to the absence of syzygies in the module of conditional independences, providing an algebraic characterization of when causal structure is identifiable from observational data. (3) Projective Dimension Intervention Bound: The causal effect of an intervention is bounded below by the projective dimension of the module of causal paths, yielding a homological lower bound on minimal intervention cost. This creates the first rigorous bridge between commutative algebra and causal inference, enabling causal discovery algorithms over algebraic data structures and certified optimal intervention design.

            ### Precise Mathematical Framing
            Define an Algebraic Structural Causal Model (ASCM) as a tuple (R, M, G, φ) where R is a commutative ring, M is a finitely generated R-module, G is a DAG on generators of M, and φ assigns structural equations φ(v) = f_v(pa(v)) + ε_v with f_v an R-module homomorphism. Theorem 1 (Module d-Separation): X ⊥_d Y | Z in G iff Tor_i^R(M_X ⊗_R M_Y, R_Z) = 0 for all i ≥ 1, where R_Z is localization at Z. Theorem 2 (Noetherian Faithfulness): An ASCM over Noetherian R is faithful iff the minimal free resolution length of Ind(M,G) equals tw(G) (treewidth of G). Theorem 3 (Projective Dimension Intervention Bound): |E[Y|do(X=x)] - E[Y|do(X=x')]| ≥ pd_R(PathMod(X→Y)) · σ_min(φ), where pd_R is projective dimension and PathMod(X→Y) is the directed-path module.



            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `generated_algebra_separation` : theorem generated_algebra_separation
     (file: MachineLearning/TropicalKME.lean)
  2. `information_lower_bound` : theorem information_lower_bound (P b : ℕ) :
     (file: MachineLearning/Neural/CompilationCompression.lean)
  3. `gpt2_info_lower_bound` : theorem gpt2_info_lower_bound :
     (file: MachineLearning/Neural/LLMSingleMatMul.lean)
  4. `beta_lifting_dimension_bound` : theorem beta_lifting_dimension_bound (d L : ℕ) (_hd : 1 ≤ d) :
     (file: MachineLearning/Neural/NeuralCompilationTeams.lean)
  5. `qubit_lower_bound` : theorem qubit_lower_bound (n : ℕ) (hn : 0 < n) : 1 ≤ n := hn
     (file: MachineLearning/QuantumTransformer/CrystallizationTheory.lean)

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



Recent successful concepts: Tropical Measure Theory: Choquet–Radon Completion, Sup-Additive Integration, and Probability Concentration, tropical_cryptography_breakthrough_bridge, Tropical Central Limit Theorem: Gumbel Attraction, Max-Plus Stein Method, and Berry-Esseen Convergence Bounds


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
Research mode: formalize
