

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

## YOUR ASSIGNMENT: Galois-Theoretic Deep Learning — Architecture-Extension Correspondence, Solvable Expressivity Certification, and Derived Depth Lower Bounds

**DOMAIN**: Algebra × Machine Learning × Cryptography

**CONCEPT**: Open the field of *Galois deep learning* by proving three foundational theorems that establish a Galois correspondence between neural network architectures and field extension towers. A feedforward architecture defines a tower of feature field extensions K₀ ⊂ K₁ ⊂ ⋯ ⊂ K_d over the input field ℝ(x₁,…,xₙ), and the Galois group Gal(K_d/K₀) classifies architectural symmetries. This yields a deep learning analog of Abel-Ruffini: non-solvable Galois groups certify that a feature map requires non-radical (deep) architectures, with depth lower bounds given by the composition length of the derived series. These results directly impact *certified_robustness* (algebraic certificates for depth efficiency), *post_quantum_cryptography* (solvable-group-based key exchange hardness from non-solvable feature maps), and *quantum_entanglement_classification* (Galois groups of entanglement varieties).

---

### PRECISE FORMALIZATION TARGETS

#### Structure 1: Feature Field Extension Tower
```lean
/-- A tower of finite field extensions representing a feedforward architecture.
    Each step corresponds to a layer adding algebraic features.
    Bridge: connects Algebra (field extensions) to Machine Learning (network depth). -/
structure FeatureTower (F : Type*) [Field F] where
  /-- Base field, e.g., ℝ(x₁,...,xₙ) -/
  base : Subfield (FractionRing (Polynomial F))
  /-- Finite tower of intermediate extensions -/
  steps : List (IntermediateField (↥base) (FractionRing (Polynomial F)))
  steps_finite : ∀ s ∈ steps, FiniteDimensional (↥base) s
  /-- Tower inclusions: each step contains the previous -/
  step_chain : ∀ i j, i < j → (steps.get i : Set _) ⊆ steps.get j
  deriving Repr
```

#### Structure 2: Radical Activation Layer
```lean
/-- An activation that generates a radical extension (solvable by radicals).
    Corresponds to elementary activations (ReLUⁿ, sigmoid, tanh).
    Bridge: connects Algebra (radical extensions) to ML (activation functions). -/
structure RadicalActivation (F : Type*) [Field F] where
  /-- The polynomial whose root is adjoined -/
  minimal_poly : Polynomial F
  /-- The root adjoined at this layer -/
  root : (FractionRing (Polynomial F))
  is_root : minimal_poly.IsRoot root
  /-- Radical: the polynomial is of the form Xⁿ - a -/
  is_radical : ∃ (n : ℕ) (a : F), n > 0 ∧ minimal_poly = Polynomial.X ^ n - Polynomial.C a
  /-- The extension degree -/
  degree : ℕ
  degree_eq : (minimal_poly.map (algebraMap F _)).natDegree = degree
```

#### Structure 3: Solvable Expressivity Certificate
```lean
/-- Certificate that a feature map is realizable by a bounded-depth
    architecture with radical activations.
    Bridge: connects Group Theory (solvable groups) to ML (expressivity bounds). -/
structure SolvableExpressivityCert (F : Type*) [Field F] where
  /-- The feature tower -/
  tower : FeatureTower F
  /-- Certificate of solvability for the Galois group -/
  galois_solvable : IsSolvable (tower.topGaloisGroup)
  /-- Explicit radical activations realizing each layer -/
  activations : List (RadicalActivation F)
  /-- The activations generate the tower -/
  activations_generate : tower.IsGeneratedBy activations
  /-- Depth bound: length of derived series ≤ number of layers -/
  depth_bound : tower.derivedSeriesLength ≤ activations.length
```

#### Definition 4: Derived Depth Lower Bound
```lean
/-- The minimal depth required to realize a feature map φ is bounded below
    by the composition length of the derived series of its Galois group.
    This is the Galois Deep Learning analog of Abel-Ruffini. -/
def derivedDepthLowerBound {F : Type*} [Field F] (φ : FeatureMap F) : ℕ :=
  (galoisGroup φ).derivedSeriesLength
```

#### Definition 5: Architecture Morphism (for contravariant functor)
```lean
/-- A morphism of architectures is a depth-preserving field embedding.
    The contravariant functor reverses direction: deeper architectures
    map to larger extensions. -/
structure ArchMorphism {F : Type*} [Field F]
    (T₁ T₂ : FeatureTower F) where
  /-- The field embedding (reverses depth order) -/
  toFun : T₂.topField →+* T₁.topField
  /-- It restricts to the base -/
  commutes : ∀ x : T₁.base, toFun (algebraMap _ _ x) = algebraMap _ _ x
  /-- Depth preservation (contravariant: more depth → smaller in morphism order) -/
  depth_monotone : T₁.steps.length ≤ T₂.steps.length
```

---

### THEOREM 1: Architecture-Extension Correspondence

```lean
/-- **Architecture-Extension Correspondence** (Fundamental Theorem of Galois Deep Learning)
    Feedforward architectures with depth-preserving morphisms are contravariantly
    equivalent to towers of finite field extensions of the input field.
    
    Bridge: connects Category Theory (functorial equivalence) to ML (architecture spaces).
    Application: certified_robustness — architectural symmetries are classified by Galois groups. -/
theorem arch_extension_correspondence {F : Type*} [Field F] [CharZero F] :
    CategoryTheory.Equivalence
      (ArchCategory F)ᵒᵖ
      (TowerCategory F) := by
  sorry -- FULL PROOF REQUIRED
```

**PROOF STRATEGY (3 paths, ranked by promise):**

*Strategy A (Direct Construction — RECOMMENDED)*: 
1. Define the functor F: ArchCategory → TowerCategory sending each architecture to its feature field tower
2. Define the inverse functor G: TowerCategory → ArchCategory recovering the architecture from extension data
3. Prove F ∘ G ≅ id and G ∘ F ≅ id using natural isomorphisms constructed from field automorphism data
4. Key lemma: `tower_extension_preserves_depth` — each layer increases extension degree by at least 1
5. Key lemma: `architecture_recover_from_tower` — the architecture is determined up to isomorphism by its tower

*Strategy B (Via Galois Group Functor)*:
1. Factor through Galois groups: ArchCategory → GroupCategory → TowerCategory
2. Use the fundamental theorem of Galois theory as a black box
3. Compose equivalences

*Strategy C (Synthetic Differential Geometry)*:
1. Use infinitesimal neighborhoods to capture local feature behavior
2. Relate to formal schemes over the input field
3. Requires more infrastructure — less promising for initial formalization

**Key Lemmas for Strategy A:**
```lean
/-- Each layer in a feature tower increases the extension degree by at least 1. -/
lemma layer_degree_strictly_increases {F : Type*} [Field F]
    (T : FeatureTower F) (i : Fin T.steps.length) :
    (T.steps.get i).finrank < (T.steps.get i.succ).finrank := by
  -- Use the tower law for finite extensions and the fact that
  -- each step is a proper extension (not equal to the previous)
  sorry

/-- An architecture is determined up to isomorphism by its feature tower. -/
lemma architecture_determined_by_tower {F : Type*} [Field F]
    (A₁ A₂ : Architecture F) (h : A₁.featureTower ≅ A₂.featureTower) :
    A₁ ≅ A₂ := by
  -- Construct the isomorphism from the field isomorphism
  sorry
```

---

### THEOREM 2: Solvable Expressivity Certification

```lean
/-- **Solvable Expressivity Certification** (Deep Learning Abel-Ruffini)
    A feature map φ is realizable by a bounded-depth architecture with radical
    (elementary) activations if and only if the Galois group of its associated
    extension is solvable.
    
    Bridge: connects Group Theory (solvable groups) to ML (expressivity bounds).
    Application: certified_robustness — solvable feature maps admit efficient
    certified depth bounds; non-solvable maps require Ω(derivedSeriesLength) depth.
    
    This is the deep learning analog of the Abel-Ruffini theorem:
    just as non-solvable Galois groups prevent solution by radicals,
    non-solvable feature Galois groups prevent realization by shallow radical architectures. -/
theorem solvable_expressivity_certification {F : Type*} [Field F] [CharZero F]
    {φ : FeatureMap F} (h_ext : φ.HasAssociatedExtension) :
    (∃ cert : SolvableExpressivityCert F, cert.featureMap = φ) ↔
      IsSolvable (galoisGroup φ) := by
  sorry -- FULL PROOF REQUIRED
```

**PROOF STRATEGY:**

*Forward direction (⇒): Radical activations ⟹ Solvable Galois group*
1. Each `RadicalActivation` adjoins a root of Xⁿ - a, generating a cyclic extension
2. Composition of cyclic extensions yields solvable extensions (by the theorem that cyclic groups are solvable and extensions of solvable by solvable are solvable)
3. Key lemma: `radical_activation_cyclic` — adjoining a root of Xⁿ - a gives a cyclic extension
4. Key lemma: `solvable_tower_solvable` — a tower of solvable extensions has solvable Galois group

*Backward direction (⇐): Solvable Galois group ⟹ Radical activations exist*
1. Use the derived series decomposition of the solvable Galois group
2. Each quotient G⁽ⁱ⁾/G⁽ⁱ⁺¹⁾ is abelian, corresponding to a radical extension
3. Construct radical activations layer by layer along the derived series
4. Key lemma: `derived_series_to_radical_tower` — each derived quotient gives a radical extension

**Key Lemmas:**
```lean
/-- Adjoining a root of Xⁿ - a yields a cyclic extension. -/
lemma radical_activation_cyclic {F : Type*} [Field F] [CharZero F]
    (act : RadicalActivation F) :
    IsCyclic (IntermediateField.alternatingGroup act.extension) := by
  -- The Galois group of Xⁿ - a = 0 is a subgroup of (ℤ/nℤ)×, which is cyclic
  -- when F contains primitive n-th roots of unity
  sorry

/-- A tower of solvable extensions has solvable Galois group. -/
lemma solvable_tower_solvable {F : Type*} [Field F] [CharZero F]
    {T : FeatureTower F} (h : ∀ i, IsSolvable (T.galoisGroupAt i)) :
    IsSolvable T.topGaloisGroup := by
  -- Induction on tower length, using that solvable-by-solvable is solvable
  sorry

/-- Each quotient of the derived series yields a radical extension. -/
lemma derived_quotient_radical {G : Type*} [Group G] [IsSolvable G]
    {K : Type*} [Field K] [CharZero K]
    (hG : IsGalois K (SplittingField (minimalPolynomial K (G.derivedSeries.head)))) :
    ∀ i < G.derivedSeriesLength,
      ∃ (n : ℕ) (a : K), n > 0 ∧
        (G.derivedSeries.get i).quotient (G.derivedSeries.get (i+1)) ≃* ZMod n := by
  -- Derived quotients of solvable groups are abelian, hence products of cyclic groups
  sorry
```

---

### THEOREM 3: Derived Depth Lower Bound

```lean
/-- **Derived Depth Lower Bound** (Certified Depth Incompressibility)
    The minimal depth required to realize a feature map φ satisfies:
      depth(φ) ≥ derivedSeriesLength(Gal(K_φ/K₀))
    
    This provides a certified lower bound on architectural depth from purely
    algebraic invariants — the Galois group acts as an "algebraic depth certificate."
    
    Bridge: connects Group Theory (derived series) to ML (depth lower bounds).
    Application: certified_robustness — non-solvable feature maps require
    Ω(derivedSeriesLength) depth, yielding adversarial robustness certificates
    that are algebraically verified.
    
    Computational bound: depth(φ) ≥ ⌈log₂(|Gal(K_φ/K₀)|)/log₂(max_deg)⌉
    where max_deg is the maximum activation degree. -/
theorem derived_depth_lower_bound {F : Type*} [Field F] [CharZero F]
    {φ : FeatureMap F} {max_deg : ℕ} (h_deg : max_deg ≥ 2)
    (h_real : φ.IsRealizableWithMaxDegree max_deg) :
    φ.minimalDepth ≥ (galoisGroup φ).derivedSeriesLength ∧
    φ.minimalDepth ≥ ⌈(galoisGroup φ).order.log₂ / max_deg.log₂⌉ := by
  sorry -- FULL PROOF REQUIRED
```

**PROOF STRATEGY:**

1. **Derived series bound**: Each layer can only reduce the derived series length by at most the extension degree, and radical activations have bounded degree
2. **Logarithmic bound**: Use the tower law for degrees and the fact that |Gal(K_d/K₀)| = [K_d : K₀]
3. Key lemma: `layer_derived_series_reduction` — each radical activation reduces derived series length by at most 1
4. Key lemma: `non_solvable_depth_omega` — non-solvable groups require Ω(log |G|) depth

```lean
/-- Each radical activation layer reduces the derived series length by at most 1. -/
lemma layer_derived_series_reduction {F : Type*} [Field F]
    (act : RadicalActivation F) (G : Group _) [IsSolvable G] :
    (G.derivedSeries.length) ≤ (act.extensionGaloisGroup).derivedSeries.length + 1 := by
  -- A cyclic quotient reduces derived series by at most 1
  sorry

/-- Non-solvable Galois groups require Ω(log |G|) depth with bounded-degree activations. -/
lemma non_solvable_depth_omega {F : Type*} [Field F] [CharZero F]
    {G : Type*} [Group G] (h_ns : ¬IsSolvable G) {d : ℕ} (h_d : d ≥ 2) :
    ∀ (arch : Architecture F), arch.maxActivationDegree ≤ d →
      arch.depth ≥ ⌈(Nat.card G).log₂ / d.log₂⌉ := by
  -- Use the degree tower law and the fact that solvable groups of order ≤ d^k
  -- have derived series of length ≤ k
  sorry
```

---

### CROSS-DOMAIN THEOREM: Post-Quantum Cryptographic Hardness from Non-Solvable Feature Maps

```lean
/-- **Galois Feature Hash Collision Resistance**
    Non-solvable feature Galois groups yield collision-resistant hash functions
    with certified security against algebraic attacks.
    
    Bridge: connects Algebra (Galois groups) to Cryptography (hash collision resistance).
    Application: post_quantum_security — the hardness of finding collisions in
    non-solvable feature maps is equivalent to computing Galois group elements,
    which is believed to be hard even for quantum computers (hidden subgroup
    problem for non-abelian groups). -/
theorem galois_hash_collision_resistance {F : Type*} [Field F] [CharZero F]
    {φ : FeatureMap F} (h_ns : ¬IsSolvable (galoisGroup φ))
    (h_inj : Function.Injective φ.toFun) :
    ∀ (adversary : QuantumAdversary F),
      adversary.collisionProbability φ ≤
        1 / (galoisGroup φ).order := by
  -- The collision probability is bounded by 1/|Gal(K_φ/K₀)| because
  -- finding collisions requires solving the hidden subgroup problem
  -- in the non-solvable Galois group, which is hard for quantum computers
  sorry -- FULL PROOF REQUIRED
```

---

### ADDITIONAL THEOREMS (10+ total required)

```lean
/-- The Galois group of a feature tower acts faithfully on the set of
    architectural symmetries. -/
theorem galois_faithful_on_symmetries {F : Type*} [Field F]
    (T : FeatureTower F) :
    Function.Injective (galoisAction T).toFun := by
  sorry

/-- Solvable feature maps are closed under composition. -/
theorem solvable_expressivity_composition {F : Type*} [Field F]
    {φ₁ φ₂ : FeatureMap F}
    (h₁ : IsSolvable (galoisGroup φ₁))
    (h₂ : IsSolvable (galoisGroup φ₂)) :
    IsSolvable (galoisGroup (φ₁ ∘ φ₂)) := by
  sorry

/-- The derived depth lower bound is tight for S₅-extensions (depth ≥ 2). -/
theorem derived_depth_tight_S5 {F : Type*} [Field F] [CharZero F]
    (h_S5 : galoisGroup (default : FeatureMap F) ≃* Equiv.Perm (Fin 5)) :
    (default : FeatureMap F).minimalDepth ≥ 2 := by
  sorry

/-- Abel-Ruffini for Deep Learning: S₅ feature maps are not realizable
    by radical activations alone (require non-radical depth). -/
theorem abel_ruffini_deep_learning {F : Type*} [Field F] [CharZero F]
    {φ : FeatureMap F} (h_S5 : galoisGroup φ ≃* Equiv.Perm (Fin 5)) :
    ¬∃ (arch : Architecture F), arch.IsRadical ∧ arch.realizes φ := by
  -- S₅ is not solvable, so by solvable_expressivity_certification,
  -- φ cannot be realized by radical activations
  sorry

/-- Composition length of the derived series equals the minimal
    number of radical extensions in a solvable realization. -/
theorem derived_length_equals_radical_count {F : Type*} [Field F] [CharZero F]
    {φ : FeatureMap F} (h_sol : IsSolvable (galoisGroup φ)) :
    (galoisGroup φ).derivedSeriesLength = φ.minimalRadicalActivationCount := by
  sorry

/-- Feature maps with abelian Galois groups are realizable by single-layer
    architectures (depth 1 suffices). -/
theorem abelian_expressivity_depth_one {F : Type*} [Field F] [CharZero F]
    {φ : FeatureMap F} (h_ab : IsAbelian (galoisGroup φ)) :
    φ.minimalDepth ≤ 1 := by
  sorry

/-- The Galois group of a feature map is a topological invariant of the
    corresponding neural network function. -/
theorem galois_invariant_under_homeomorphism {F : Type*} [Field F] [CharZero F]
    {φ₁ φ₂ : FeatureMap F}
    (h_homeo : ∃ (h : F → F), IsHomeomorphism h ∧ φ₂ = φ₁ ∘ h) :
    galoisGroup φ₁ ≃* galoisGroup φ₂ := by
  sorry

/-- Lipschitz-certified depth bound: for K-Lipschitz feature maps,
    the depth lower bound improves by a factor of log(K). -/
theorem lipschitz_certified_depth_bound {F : Type*} [Field F] [CharZero F]
    {φ : FeatureMap F} {K : ℕ} (h_lip : φ.IsKLipschitz K) (h_K : K ≥ 2) :
    φ.minimalDepth ≥
      ⌈((galoisGroup φ).derivedSeriesLength : ℝ) * Real.log K / Real.log 2⌉ := by
  sorry

/-- Post-quantum security: S₅ feature maps are hard to invert even
    for quantum adversaries (hidden subgroup problem for non-abelian groups). -/
theorem post_quantum_inversion_hardness {F : Type*} [Field F] [CharZero F]
    {φ : FeatureMap F} (h_S5 : galoisGroup φ ≃* Equiv.Perm (Fin 5)) :
    ∀ (A : QuantumAdversary F),
      A.inversionProbability φ ≤ 1 / 120 := by
  -- |S₅| = 120, and inverting requires solving HSP in S₅
  sorry
```

---

### REQUIRED STRUCTURES AND INSTANCES (5+)

```lean
/-- The category of feature towers over a base field. -/
instance : Category (TowerCategory F) where ...

/-- The category of architectures over a base field. -/
instance : Category (ArchCategory F) where ...

/-- Feature towers form a partial order by inclusion. -/
instance : PartialOrder (FeatureTower F) where ...

/-- The Galois group of a feature map forms a group. -/
instance (φ : FeatureMap F) : Group (galoisGroup φ) where ...

/-- Solvable expressivity certificates form a lattice under refinement. -/
instance : Lattice (SolvableExpressivityCert F) where ...
```

---

### SIGNIFICANCE AND FUTURE DIRECTIONS

This work opens the field of **Galois Deep Learning**, establishing that:
1. **Architecture = Field Extension Tower** (categorical equivalence)
2. **Expressivity = Solvability** (Abel-Ruffini for neural networks)
3. **Depth = Derived Series Length** (certified lower bounds)

The implications for *certified_robustness* are immediate: non-solvable feature maps are provably hard to approximate with shallow radical architectures, yielding algebraic robustness certificates. For *post_quantum_cryptography*, non-solvable feature maps yield collision-resistant hashes based on the hardness of the hidden subgroup problem in non-abelian groups. For *quantum_entanglement_classification*, Galois groups of entanglement varieties classify entanglement types.

**Produce a FUTURE_DIRECTIONS.md** with 3-5 concrete next steps:
1. Galois-theoretic universal approximation: prove that the closure of solvable-expressible maps is dense in continuous functions
2. Tropical Galois theory: replace ℝ with the tropical semiring and prove an analogous correspondence
3. Homotopy type-theoretic refinement: replace field extensions with homotopy types and prove a HoTT version
4. Quantum feature fields: extend to quantum field extensions (non-commutative Galois theory) for quantum neural networks
5. Adversarial Galois theory: prove that adversarial perturbations correspond to field automorphisms of the feature field

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
            Open the field of Galois deep learning by proving three foundational theorems that establish a Galois correspondence between neural network architectures and field extensions. The key insight: a feedforward architecture defines a tower of feature field extensions K₀ ⊂ K₁ ⊂ ... ⊂ K_d over the input field ℝ(x₁,...,xₙ), and the Galois group Gal(K_d/K₀) classifies architectural symmetries. This yields a deep learning analog of the Abel-Ruffini theorem: non-solvable Galois groups certify that a feature map requires non-radical (deep) architectures, with depth lower bounds given by the composition length of the derived series. Theorem 1 (Architecture-Extension Correspondence): Feedforward architectures with depth-preserving morphisms are contravariantly equivalent to towers of finite field extensions of ℝ(x₁,...,xₙ), with Galois groups recovering architecture automorphisms. Theorem 2 (Solvable Expressivity Certification): A feature map is realizable by a bounded-depth architecture with radical (elementary) activations if and only if the Galois group of its associated extension is solvable. Theorem 3 (Derived Depth Lower Bound): The minimal depth required to realize a feature map satisfies depth(φ) ≥ ℓ(Der(Gal(K_φ/K₀))), where ℓ is the composition length of the derived series, yielding certified depth lower bounds from algebraic invariants.

            ### Precise Mathematical Framing
            Let Arch denote the category of feedforward neural architectures A = (L₁,...,L_d) where each layer Lᵢ defines a feature map φᵢ: K_{i-1} → Kᵢ over the function field K₀ = ℝ(x₁,...,xₙ). The coordinate ring A_φ = ℝ[φ₁,...,φ_d] is a finitely generated ℝ-algebra, and its fraction field K_φ = Frac(A_φ) is a finite extension of K₀. Define the Galois group G_A = Aut(K_φ/K₀) as the automorphism group fixing the input field. Theorem 1 proves the contravariant equivalence Archᵒᵖ ≅ FieldExt via the functor F(A) = K_φ and G(K_φ/K₀) = ArchSpec(G_A). Theorem 2 proves that φ is expressible as a composition of radical maps (maps with solvable Galois groups) if and only if G_A is solvable, via the Galois correspondence and the fundamental theorem of Galois theory applied to the derived series G_A ⊵ [G_A,G_A] ⊵ ... ⊵ {e}. Theorem 3 proves depth(φ) ≥ ℓ(Der(G_A)) by showing each derived quotient G^{(i)}/G^{(i+1)} requires a separate non-linear layer, yielding certified depth lower bounds. Key lemma: for ReLU networks, the Galois group embeds into a product of reflection groups, and solvability reduces to checking whether all irreducible representations have prime-power order.



            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `circuit_lower_bound_from_obstruction` : theorem circuit_lower_bound_from_obstruction (f : α) (B : ℕ)
     (file: Algebra/GCT/Foundation.lean)
  2. `depth_lower_bound_from_obstruction` : theorem depth_lower_bound_from_obstruction
     (file: Bridges/HomologicalDeepLearning.lean)
  3. `composition_quality_bound` : theorem composition_quality_bound {α β γ : Type*}
     (file: Algebra/Core/CategoryTheory.lean)
  4. `depth_bound_prime` : theorem depth_bound_prime (p : ℕ) (hodd : p % 2 = 1) (hp5 : 5 ≤ p) :
     (file: Algebra/Factoring/ChainFactoring.lean)
  5. `hypotenuse_lower_bound_B2` : theorem hypotenuse_lower_bound_B2 {a b c : ℤ} (h : a ^ 2 + b ^ 2 = c ^ 2)
     (file: Algebra/Factoring/Hyperbolic.lean)

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



Recent successful concepts: Neural Proof Mining: Tactic Monoid Representation, Goal Embedding Lipschitz Certification, and Irreducible Proof Depth Bounds, Foundations of Information-Theoretic Shared Structures, Tannakian Neural Architecture Theory: Fiber Functor Reconstruction, Frobenius-Perron Expressivity Certification, and Coalgebraic Feature Importance


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

Research domain: Algebra
Research mode: prove
