

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

## Antipode Uniqueness and Deterministic Birkhoff Decomposition: Unambiguous Renormalization Prescriptions from Convolution-Inverse Uniqueness in Graded Hopf Algebras

### I. THE GRAND VISION

In quantum field theory, the Connes-Kreimer revolution revealed that renormalization is fundamentally algebraic: Feynman graphs form a Hopf algebra, and renormalization is a Birkhoff decomposition of characters. But a foundational question has lingered: **is the renormalization prescription canonical, or does it admit gauge freedom?** This brief answers: it is unique. There are no choices. The Birkhoff decomposition of any character on a connected graded Hopf algebra through a Rota-Baxter splitting is uniquely determined — the antipode is not merely an involution but a *deterministic prescription*.

This has immediate consequences beyond physics:
- **Cryptography**: The uniqueness of the Birkhoff decomposition means that certain lattice-free "renormalization obfuscation" schemes cannot exist — the decomposition is a *cryptographic hash function* from the space of characters to its polar decomposition, with collision resistance following from uniqueness.
- **Certified ML**: The antipode acts as a *gradient canceller* on the Hopf algebra of neural network layers; its uniqueness means that certified Lipschitz bounds derived from renormalization are unambiguous, not dependent on decomposition choices.

### II. FORMALIZATION TARGETS — PRECISE LEAN 4 TYPE SIGNATURES

#### Novel Structures (5+ required)

```lean
/-- A connected graded bialgebra: the grade-0 component is isomorphic to the base ring.
    Bridge: connects algebraic combinatorics to quantum_field_theory via renormalization. -/
structure ConnectedGradedHopfAlgebra (R : Type*) [CommSemiring R] where
  carrier : Type*
  [semiring : Semiring carrier]
  [graded : GradedAlgebra carrier ℕ]
  [coalgebra : Coalgebra carrier]
  [antipode : HasAntipode carrier]
  connected : ∀ x : carrier, grade x = 0 → ∃ r : R, x = algebraMap R carrier r

/-- A Rota-Baxter operator of weight λ on an algebra A.
    Satisfies R(a)R(b) = R(R(a)b + aR(b)) + λR(ab).
    Bridge: connects combinatorial_algebra to statistical_mechanics via fluctuation-dissipation. -/
structure RotaBaxterOperator (A : Type*) [Semiring A] (λ : A) where
  map : A → A
  rota_baxter_identity : ∀ a b : A, map a * map b = map (map a * b + a * map b) + λ * map (a * b)

/-- The convolution group of characters on a Hopf algebra with values in A.
    Bridge: connects representation_theory to quantum_renormalization via character_decomposition. -/
structure ConvolutionCharacterGroup (H : Type*) [Semiring H] [Coalgebra H] (A : Type*) [Semiring A] where
  char : H →ₐ[A] A  -- algebra morphism
  is_invertible : ∃ inv : H → A, ∀ x, finsum (fun b => inv b * char (x - b)) = ε x

/-- Birkhoff splitting of an algebra via a Rota-Baxter operator.
    The polar decomposition A = A₋ ⊕ A₊ determines the renormalization prescription.
    Bridge: connects complex_analysis to lattice_cryptography via short_vector_decomposition. -/
structure BirkhoffSplitting (A : Type*) [Semiring A] (R : RotaBaxterOperator A 0) where
  neg_proj : A → A  -- projection onto A₋
  pos_proj : A → A  -- projection onto A₊
  neg_fixed : ∀ a, R.map a = neg_proj a
  pos_complement : ∀ a, a = neg_proj a + pos_proj a
  direct_sum : ∀ a, neg_proj a * pos_proj a = 0

/-- A renormalization prescription: the canonical Birkhoff decomposition of a character.
    Uniqueness is the main theorem.
    Bridge: connects quantum_field_theory to certified_robustness via deterministic_decomposition. -/
structure RenormalizationPrescription (H : Type*) [Semiring H] [Coalgebra H]
    (A : Type*) [Semiring A] (R : RotaBaxterOperator A 0) where
  φ : H →ₐ[A] A
  φ_neg : H → A  -- counterterm map
  φ_pos : H → A  -- renormalized map
  birkhoff : ∀ x, φ x = (φ_neg ⋆ φ_pos) x  -- convolution product
  neg_character : IsAlgebraMorphism φ_neg
  pos_character : IsAlgebraMorphism φ_pos
```

#### Main Theorems with Precise Signatures

```lean
/-- THEOREM 1: Convolution-inverse uniqueness via strong induction on grade.
    For any character φ on a connected graded Hopf algebra H with values in A,
    the convolution inverse φ⁻¹ satisfying φ⁻¹ ⋆ φ = ε is unique.
    
    Proof strategy: Strong induction on grade n. Base case: grade 0 is determined by
    φ⁻¹(1) = 1 (since H is connected, grade-0 elements are scalars). Inductive step:
    the Bogoliubov recursion φ⁻¹(x) = -φ(x) - Σ φ⁻¹(x')·φ(x'') where Δ(x) = x ⊗ 1 + 
    1 ⊗ x + Σ x' ⊗ x'' with grade(x') < grade(x), grade(x'') < grade(x).
    
    Computational bound: The recursive computation requires O(2^n) multiplications
    for an element of grade n, establishing Omega(2^n) lower bound on any
    antipode computation from the coproduct alone.
    
    Bridge: connects inductive_algebra to quantum_renormalization via bogoliubov_recursion. -/
theorem convolution_inverse_unique {H : Type*} [Semiring H] [Coalgebra H]
    [HasAntipode H] {A : Type*} [Semiring A]
    (φ : H →ₐ[A] A) (φ_inv₁ φ_inv₂ : H → A)
    (h₁ : ∀ x, ConvolutionProduct φ_inv₁ φ x = Counit.ε x)
    (h₂ : ∀ x, ConvolutionProduct φ_inv₂ φ x = Counit.ε x) :
    ∀ x : H, φ_inv₁ x = φ_inv₂ x := by
  -- Proof by strong induction on grade

/-- THEOREM 2: Bogoliubov recursion determines the antipode with explicit complexity.
    The antipode S on a connected graded Hopf algebra satisfies:
    S(x) = -x - Σ S(x') · x'' where Δ(x) = x ⊗ 1 + 1 ⊗ x + Σ x' ⊗ x''
    
    This is the mathematical heart of the Connes-Kreimer forest formula.
    Computational bound: O(n!) for graphs with n external legs, 
    O(2^n) for abstract algebraic elements of grade n.
    
    Bridge: connects combinatorial_algebra to certified_complexity via antipode_recursion. -/
theorem bogoliubov_recursion_determines_antipode {H : Type*} [Semiring H] 
    [ConnectedGradedCoalgebra H] [HasAntipode H] :
    ∀ x : H, grade x > 0 → 
      antipode x = -x - finsum (fun (p : H × H) => 
        if p.1 = 1 ∨ p.2 = 1 then 0 else antipode p.1 * p.2) := by
  -- Proof uses connectedness and the recursive structure of reduced coproduct

/-- THEOREM 3: Birkhoff decomposition uniqueness — the renormalization prescription is canonical.
    Given a Rota-Baxter operator R: A → A of weight 0, and a character φ: H → A,
    the Birkhoff decomposition φ = φ₋⁻¹ ⋆ φ₊ is UNIQUE.
    
    This is the central result: there are no gauge choices in renormalization.
    The counterterms φ₋ and the renormalized value φ₊ are uniquely determined
    by φ and R alone.
    
    Bridge: connects quantum_field_theory to post_quantum_cryptography via 
    collision_resistant_decomposition. -/
theorem birkhoff_decomposition_unique {H : Type*} [Semiring H] [Coalgebra H]
    [HasAntipode H] [ConnectedGraded H] {A : Type*} [Semiring A]
    (R : RotaBaxterOperator A 0) (split : BirkhoffSplitting A R)
    (φ : H →ₐ[A] A)
    (φ_neg₁ φ_neg₂ φ_pos₁ φ_pos₂ : H → A)
    (h_birk₁ : ∀ x, φ x = ConvolutionProduct (InvChar φ_neg₁) φ_pos₁ x)
    (h_birk₂ : ∀ x, φ x = ConvolutionProduct (InvChar φ_neg₂) φ_pos₂ x)
    (h_neg₁ : IsRotaBaxterProjection φ_neg₁ R neg_proj)
    (h_neg₂ : IsRotaBaxterProjection φ_neg₂ R neg_proj)
    (h_pos₁ : IsComplementProjection φ_pos₁ R pos_proj)
    (h_pos₂ : IsComplementProjection φ_pos₂ R pos_proj) :
    ∀ x : H, φ_neg₁ x = φ_neg₂ x ∧ φ_pos₁ x = φ_pos₂ x := by
  -- Key: uniqueness of φ₋ follows from uniqueness of convolution inverse
  -- applied to the Bogoliubov preparation map, then φ₊ = φ₋ ⋆ φ

/-- THEOREM 4: The antipode is a cryptographic collision-resistant function.
    Since the Birkhoff decomposition is unique, the map φ ↦ (φ₋, φ₊) is injective
    on the space of characters. This means the "renormalization hash" has no collisions.
    
    Bridge: connects algebraic_quantum_field_theory to lattice_cryptography via 
    collision_resistant_hash. -/
theorem renormalization_hash_collision_resistant {H : Type*} [Semiring H] [Coalgebra H]
    [HasAntipode H] [ConnectedGraded H] {A : Type*} [Semiring A]
    (R : RotaBaxterOperator A 0) (split : BirkhoffSplitting A R)
    (φ₁ φ₂ : H →ₐ[A] A) :
    (∀ x : H, BirkhoffNeg R split φ₁ x = BirkhoffNeg R split φ₂ x) → 
    ∀ x : H, φ₁ x = φ₂ x := by
  -- If the counterterms agree, then φ₊ agree by uniqueness, hence φ₁ = φ₋⁻¹ ⋆ φ₊ = φ₂

/-- THEOREM 5: Certified Lipschitz bound for the antipode on grade-n elements.
    The antipode S satisfies |S(x)| ≤ C^n · |x| for elements of grade n,
    where C depends only on the structure constants of the coproduct.
    
    This gives a certified_robustness guarantee: perturbations of the 
    character φ at grade k do not propagate to grades > k with unbounded amplification.
    
    Bridge: connects quantum_renormalization to certified_robustness via 
    grade_lipschitz_antipode. -/
theorem grade_lipschitz_antipode_bound {H : Type*} [Semiring H] 
    [ConnectedGradedCoalgebra H] [HasAntipode H] {A : Type*} [NormedSemiring A]
    (φ : H →ₐ[A] A) (C : ℝ) (hC : C > 0)
    (h_structure : ∀ x, ‖Δ x‖ ≤ C * ‖x‖) :
    ∀ (n : ℕ) (x : H), grade x = n → ‖antipode x‖ ≤ (C ^ n) * ‖x‖ := by
  -- Induction on grade with explicit Lipschitz constant propagation
```

### III. PROOF STRATEGIES (MULTIPLE PATHS)

**Strategy A: Direct Strong Induction on Grade (RECOMMENDED for Theorem 1)**
1. Define the *reduced coproduct* Δ̃(x) = Δ(x) - x⊗1 - 1⊗x, which strictly decreases grade.
2. Show that φ⁻¹(x) = -φ(x) - (φ⁻¹ ⊗ φ)(Δ̃(x)) by the convolution algebra axioms.
3. Apply strong induction: if φ⁻¹₁ and φ⁻¹₂ agree on all elements of grade < n, they agree on grade n because Δ̃ maps grade n to sums of tensor products of lower-grade elements.
4. Base case: grade 0 elements are scalars, and φ⁻¹(1) = 1 is forced.
5. **Key lemma**: `reduced_coproduct_grade_decrease`: ∀ x, grade x > 0 → ∀ (a,b) in support of Δ̃(x), grade a < grade x ∧ grade b < grade x.

**Strategy B: Convolution Group Argument (for Theorem 3)**
1. The set of characters Homₐ(H, A) forms a group under convolution ⋆ with unit ε.
2. The Bogoliubov preparation map B(φ) = φ - R(φ) - R(φ ⋆ (φ⁻¹ - ε)) is well-defined.
3. The Birkhoff decomposition is φ₋ = -R(B(φ)⁻¹)⁻¹ and φ₊ = (id - R)(B(φ)⁻¹).
4. Uniqueness follows because B(φ) is uniquely determined by φ and R, and the convolution inverse is unique by Theorem 1.
5. **Key lemma**: `bogoliubov_map_unique`: The Bogoliubov map B depends only on φ and R, not on any choices.

**Strategy C: Forest Formula Combinatorics (for Theorem 2 and computational bounds)**
1. Define the Connes-Kreimer forest formula: S(Γ) = -Γ - Σ_{γ⊂Γ} S(γ) · Γ/γ for Feynman graphs.
2. Prove by induction on the number of divergent subgraphs that this computes the antipode.
3. The number of terms in the forest formula for a graph with n divergent subgraphs is the Bell number B(n), giving O(B(n)) complexity.
4. **Key lemma**: `forest_formula_grade_decrease`: Each γ in the sum has strictly fewer divergent subgraphs than Γ.

### IV. CONCRETE LEMMA SEQUENCE (BUILDING BLOCKS)

Build these 15+ supporting results before the main theorems:

```lean
-- Grade 0: scalars are determined
theorem connected_grade_zero_scalar {H : Type*} [Semiring H] [ConnectedGraded H]
    (x : H) (hx : grade x = 0) : ∃ r : R, x = algebraMap R H r

-- Reduced coproduct decreases grade
theorem reduced_coproduct_grade_decrease {H : Type*} [Semiring H] 
    [ConnectedGradedCoalgebra H]
    (x : H) (hx : grade x > 0) (a b : H) (hab : (a, b) ∈ reducedCoproductSupport x) :
    grade a < grade x ∧ grade b < grade x

-- Convolution algebra is associative
theorem convolution_assoc {H A : Type*} [Semiring H] [Coalgebra H] [Semiring A]
    (f g h : H → A) : 
    ConvolutionProduct f (ConvolutionProduct g h) = 
    ConvolutionProduct (ConvolutionProduct f g) h

-- Counit is unit for convolution
theorem convolution_unit {H A : Type*} [Semiring H] [Coalgebra H] [Semiring A]
    (f : H → A) : 
    ConvolutionProduct f Counit.ε = f ∧ ConvolutionProduct Counit.ε f = f

-- Left inverse equals right inverse in convolution group
theorem convolution_inverse_unique_left_right {H A : Type*} [Semiring H] 
    [Coalgebra H] [Semiring A] (f : H → A) (g h : H → A)
    (hg : ConvolutionProduct g f = Counit.ε)
    (hh : ConvolutionProduct f h = Counit.ε) :
    g = h

-- Rota-Baxter identity implies direct sum splitting
theorem rota_baxter_direct_sum {A : Type*} [Semiring A] (R : RotaBaxterOperator A 0) :
    ∀ a : A, ∃! (a₋ a₊ : A), a = a₋ + a₊ ∧ R a₋ = a₋ ∧ R a₊ = 0

-- Bogoliubov map is uniquely determined
theorem bogoliubov_map_welldefined {H A : Type*} [Semiring H] [Coalgebra H]
    [ConnectedGraded H] [Semiring A] (R : RotaBaxterOperator A 0)
    (φ : H →ₐ[A] A) : ∃! B : H → A, ∀ x, B x = φ x - R.map (φ x) - 
    R.map (ConvolutionProduct (fun y => (InvChar (fun z => R.map (φ z))) y - ε y) φ x)

-- Antipode satisfies the Bogoliubov recursion
theorem antipode_bogoliubov_recursion {H : Type*} [Semiring H] 
    [ConnectedGradedCoalgebra H] [HasAntipode H] (x : H) (hx : grade x > 0) :
    antipode x = -x - finsum (fun (p : H × H) => 
      if p.1 = 1 ∨ p.2 = 1 then (0 : H) else antipode p.1 * p.2)

-- Grade Lipschitz bound for convolution
theorem convolution_grade_lipschitz {H A : Type*} [Semiring H] 
    [ConnectedGradedCoalgebra H] [NormedSemiring A]
    (f g : H → A) (n : ℕ) (C : ℝ) 
    (hf : ∀ m ≤ n, ∀ x, grade x = m → ‖f x‖ ≤ C ^ m)
    (hg : ∀ m ≤ n, ∀ x, grade x = m → ‖g x‖ ≤ C ^ m) :
    ∀ x, grade x ≤ n → ‖ConvolutionProduct f g x‖ ≤ (2 * C) ^ n

-- Renormalization group flow is grade-local
theorem renormalization_grade_local {H A : Type*} [Semiring H] [Coalgebra H]
    [ConnectedGraded H] [Semiring A] (R : RotaBaxterOperator A 0)
    (φ : H →ₐ[A] A) (n : ℕ) :
    ∀ x, grade x ≤ n → (BirkhoffNeg R φ x) depends only on (φ y) for grade y ≤ n
```

### V. SIGNIFICANCE AND APPLICATIONS

**Physics**: This resolves the foundational question: renormalization in QFT is not merely well-defined but *canonically determined*. There is no gauge freedom in the Birkhoff decomposition. The Connes-Kreimer Hopf algebra of Feynman graphs has a unique antipode, and any Rota-Baxter splitting gives a unique decomposition. This is the algebraic counterpart of the statement that "physical predictions are independent of the renormalization scheme" — but elevated from physical intuition to mathematical theorem.

**Cryptography**: The map φ ↦ (φ₋, φ₊) is injective on the character group. This means the "renormalization hash" has zero collision probability, a property of interest for post-quantum cryptographic protocols where one seeks functions that are both collision-resistant and computable in O(2^n) time (matching the lower bound from Theorem 2).

**Certified ML Robustness**: The grade-Lipschitz bound (Theorem 5) means that perturbations of neural network parameters at "grade k" (layer k, in the Hopf algebra of layer compositions) propagate with bounded amplification to deeper layers. This gives *certified_robustness* guarantees for neural networks viewed as characters on the Hopf algebra of layer compositions, with the antipode playing the role of gradient backpropagation.

### VI. DEMANDED OUTPUT STRUCTURE

Produce a single Lean 4 file `AntipodeUniqueness.lean` with:
1. **Definitions** (5+): `ConnectedGradedHopfAlgebra`, `RotaBaxterOperator`, `BirkhoffSplitting`, `RenormalizationPrescription`, `ConvolutionCharacterGroup`, `ReducedCoproduct`, `BogoliubovMap`, `BirkhoffNeg`, `BirkhoffPos`
2. **Supporting lemmas** (10+): Including all lemmas from Section IV above
3. **Main theorems** (5): Theorems 1-5 from Section II with complete proofs
4. **Computational bounds** (3+): Explicit O(2^n) complexity for antipode, Omega(B(n)) for forest formula, Lipschitz constant C^n for grade propagation
5. **Cross-domain bridges** (3+): Each main theorem doc comment must name two domains it bridges
6. **FUTURE_DIRECTIONS.md**: 3-5 concrete next steps including:
   - Extension to weight-λ Rota-Baxter operators (deformation theory)
   - Tropical Birkhoff decomposition for certified robustness of min-plus neural networks
   - Post-quantum cryptographic protocol based on renormalization hash collision resistance
   - Analytic continuation of Birkhoff decomposition (Riemann-Hilbert connection)
   - Hochschild cohomology obstructions to Birkhoff decomposition in non-commutative settings

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
            Open the field of unique renormalization theory by proving three foundational theorems: (1) Convolution-Inverse Uniqueness: For any augmented character φ on a connected graded Hopf algebra H, the convolution inverse φ⁻¹ satisfying φ⁻¹ ⋆ φ = ε is unique, proved via strong induction on grade using the recursive structure φ⁻¹(n) = -φ(n) - Σ_{k<n} φ⁻¹(k+1)·φ(n-k). (2) Birkhoff Decomposition Uniqueness: Given a Rota-Baxter operator R on the target algebra A = A₋ ⊕ A₊, the Birkhoff decomposition φ = φ₋⁻¹ ⋆ φ₊ is unique, following from convolution-inverse uniqueness and the uniqueness of the Rota-Baxter splitting. (3) Forest-Formula Determinism: The Connes-Kreimer recursive forest formula computes the unique antipode on the Hopf algebra of Feynman graphs, establishing that the renormalization prescription is unambiguous — there are no 'gauge choices' in the Birkhoff decomposition. This resolves a foundational question in mathematical physics: renormalization is not merely well-defined but canonically determined.

            ### Precise Mathematical Framing
            Let H be a connected graded Hopf algebra with grading H = ⊕_{n≥0} H_n, counit ε, and coproduct Δ. Let G(H) be the group of characters φ: H → A where A is a commutative algebra with Rota-Baxter operator R. The convolution product is (φ ⋆ ψ)(h) = Σ φ(h₁)ψ(h₂) over Sweedler notation. An augmented character satisfies φ(1) = 1. Theorem 1 states: ∀φ ∈ G(H) with φ(1) = 1, ∃!ψ such that ψ ⋆ φ = ε. Proof by strong induction: at grade 0, ψ(1) = 1 = ε(1). At grade n+1, the equation (ψ ⋆ φ)(h) = 0 for h ∈ H_{n+1} expands to ψ(h)φ(1) + Σ_{k<n} ψ(h_{(1)})φ(h_{(2)}) = 0, which determines ψ(h) uniquely from ψ-values on lower grades. Theorem 2: If R: A → A satisfies the Rota-Baxter identity R(x)R(y) = R(R(x)y + xR(y)), then the Birkhoff decomposition φ₋ = -R(φ(P)), φ₊ = (id - R)(φ(P)) with P the projector onto primitive elements, is the unique decomposition with φ₋(Hₙ) ⊆ A₋ and φ₊(Hₙ) ⊆ A₊. Theorem 3: The forest formula φ⁻¹(h) = -φ(h) - Σ_{cuts C} (-1)^{|C|} Π_{T ∈ C} φ⁻¹(T) gives the unique convolution inverse, making the Connes-Kreimer renormalization prescription canonical.



            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `factor_from_three_squares` : theorem factor_from_three_squares (N p x y z : ℤ)
     (file: Algebra/Factoring/LatticeTreeDuality.lean)
  2. `not_timelike_and_lightlike` : theorem not_timelike_and_lightlike (a b c : ℝ) :
     (file: Algebra/IntegerEnergy/LightConeTheory.lean)
  3. `no_three_squares_for_7` : theorem no_three_squares_for_7 :
     (file: Algebra/IntegerEnergy/MetaOracleNextSteps.lean)
  4. `seven_not_sum_three_squares` : theorem seven_not_sum_three_squares :
     (file: Algebra/IntegerEnergy/OpenQuestions.lean)
  5. `unique_self_from_contraction` : theorem unique_self_from_contraction
     (file: Algebra/IntegerEnergy/StrangeLoops.lean)

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



Recent successful concepts: Toric Code as a Chain Complex: Verified Topological Quantum Error Correction via Homological Distance Bounds, algebra_breakthrough_discovery, Connes-Kreimer Quantum Circuit Renormalization: Hopf-Algebraic Gate Decomposition, Birkhoff Channel Decomposition, and Forest-Formula Amplitude Optimization


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

Research domain: Algebra
Research mode: prove
