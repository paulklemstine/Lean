

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

## Min-Plus Satake Isomorphism: Idempotent Hecke Algebra Structure, Tropical Cartan Decomposition, and Spherical Representation Ring Correspondence for GL₂

### I. FOUNDATIONAL DEFINITIONS (5+ new structures/instances)

Define the following hierarchy, each carrying novel typeclass combinations:

```lean
/-- The min-plus Hecke algebra of K-biinvariant functions on GL₂(ℝ_max).
    Bridge: connects representation theory to tropical geometry. -/
structure TropicalHeckeAlgebra where
  /-- Carrier: K-biinvariant functions GL₂(ℝ_max) → ℝ_max -/
  carrier : (Matrix (Fin 2) (Fin 2) WithTop ℝ) → Tropical ℝ
  biinvariant : ∀ {k₁ k₂ : TropicalPermutationMatrix 2},
    carrier (k₁.val * x * k₂.val) = carrier x
  finitely_supported : carrier.support.Finite

/-- A tropical permutation matrix: the compact subgroup K in GL₂(ℝ_max).
    Bridge: connects combinatorial group theory to tropical linear algebra. -/
structure TropicalPermutationMatrix (n : ℕ) where
  val : Matrix (Fin n) (Fin n) (Tropical ℝ)
  is_permutation : ∀ i, ∃! j, val i j = 1 ∧ ∀ k ≠ j, val i k = 0
  is_orthogonal : val * val.transpose = 1

/-- The tropical dominant Weyl chamber A⁺: diagonal matrices with non-increasing entries.
    Bridge: connects root system theory to optimization (tropical eigenspaces). -/
structure TropicalDominantChamber where
  diag : Fin 2 → Tropical ℝ
  nonincreasing : diag 0 ≥ diag 1

/-- Weyl-invariant tropical polynomial: the image of the Satake transform.
    Bridge: connects invariant theory to tropical cryptography (tropical_hash_collision). -/
structure WeylInvariantTropicalPoly where
  poly : Tropicalℝ[X]
  weyl_symmetric : ∀ (w : SymGroup 2), poly = poly.weylAct w

/-- The Satake transform between idempotent semirings.
    Bridge: connects Langlands duality to min-plus information theory. -/
structure SatakeTransform where
  map : TropicalHeckeAlgebra → WeylInvariantTropicalPoly
  preserves_add : map (f + g) = map f + map g
  preserves_mul : map (f * g) = map f * map g
  is_bijective : Function.Bijective map
```

### II. MAIN THEOREMS WITH PRECISE TYPE SIGNATURES

**Theorem 1: Idempotent Commutativity of Min-Plus Hecke Algebra**
```lean
/-- The min-plus Hecke algebra H(GL₂(ℝ_max), K) is a commutative idempotent semiring.
    The idempotence f ⊕ f = f reflects the tropical "maximum principle" from
    viscosity solution theory (Bridge: connects PDE to representation theory).
    The commutativity is the tropical shadow of Satake's isomorphism. -/
theorem minplus_hecke_idempotent_commutative
    (f g : TropicalHeckeAlgebra) :
    f + f = f ∧ f * g = g * f := by
  -- Proof Strategy:
  -- Step 1: Idempotence follows from max(x,x) = x in the tropical semiring.
  -- Step 2: Commutativity requires the K-biinvariance and the tropical
  --   Cartan decomposition to reduce to diagonal elements, then use
  --   commutativity of diagonal matrices in the tropical semiring.
  sorry -- REPLACE with full proof
```

**Theorem 2: Tropical Cartan Decomposition with Uniqueness**
```lean
/-- Every invertible tropical matrix decomposes as K·A⁺·K with uniqueness
    modulo Weyl group action on the diagonal part.
    This is the tropical analogue of the p-adic Cartan decomposition.
    Bridge: connects Lie theory to tropical optimization.
    Computational bound: decomposition computable in O(n log n) via tropical LU. -/
theorem tropical_cartan_decomposition_unique
    (M : Matrix (Fin 2) (Fin 2) (Tropical ℝ))
    (hM : M.det ≠ ⊤) :
    ∃! (d : TropicalDominantChamber),
      ∃ (k₁ k₂ : TropicalPermutationMatrix 2),
        M = k₁.val * (diagonal d.diag) * k₂.val ∧
        ∀ (w : SymGroup 2), diagonal (d.diag ∘ w.equiv) = diagonal d.diag → w = 1 := by
  -- Proof Strategy:
  -- Step 1: Row-reduce M using tropical pivot operations (k₁ acts on left).
  -- Step 2: Column-reduce using k₂ on right.
  -- Step 3: The remaining diagonal entries satisfy d₀ ≥ d₁ by construction.
  -- Step 4: Uniqueness: Weyl group permutes diagonal entries; dominance condition
  --   picks unique representative. O(n log n) from sorting the diagonal.
  sorry -- REPLACE with full proof
```

**Theorem 3: Satake Isomorphism — The Crown Jewel**
```lean
/-- The Satake transform S: H(GL₂(ℝ_max), K) → R(T)^W is a semiring isomorphism.
    This is the foundational theorem of tropical Langlands duality.
    The Weyl-invariant image consists of tropical Schur polynomials.
    Bridge: connects Langlands program to tropical geometry to min-plus
    information theory (tropical mutual information satisfies data processing inequality).
    Cryptographic application: tropical_hash_collision resistance follows from
    injectivity of Satake on support. -/
theorem satake_minplus_isomorphism :
    ∃ (S : SatakeTransform), S.is_bijective ∧
    (∀ f : TropicalHeckeAlgebra, S.map f = tropicalSchurPolynomial f) ∧
    (∀ p : WeylInvariantTropicalPoly,
      ∃ f : TropicalHeckeAlgebra, S.map f = p) := by
  -- Proof Strategy:
  -- Step 1: Define S(f)(χ) = Σ_{a∈A⁺/W} f(a) · χ(a) (tropical sum = max).
  -- Step 2: Show S preserves addition: max of Schur polys = Schur poly of max.
  -- Step 3: Show S preserves multiplication: use tropical Schur polynomial identity
  --   s_λ ⊗ s_μ = ⊕_ν c^ν_{λμ} · s_ν where c^ν_{λμ} are tropical Littlewood-Richardson.
  -- Step 4: Injectivity: if S(f) = S(g), then f and g agree on all double cosets
  --   by the non-vanishing of tropical characters (uses tropical Torsion-freeness).
  -- Step 5: Surjectivity: every W-invariant tropical polynomial is a tropical Schur poly.
  sorry -- REPLACE with full proof
```

### III. LEMMA SCAFFOLDING (10+ supporting results)

```lean
/-- Tropical Schur polynomial satisfies max-plus polynomial identity.
    Bridge: connects algebraic combinatorics to certified_robustness bounds. -/
lemma tropical_schur_maxplus_identity
    (λ μ : YoungDiagram 2) :
    ∃ (c : ℕ → Tropical ℝ),
      tropicalSchur λ * tropicalSchur μ =
      Finset.sup (ν : YoungDiagram 2) (c ν.1 • tropicalSchur ν) ∧
      ∀ ν, c ν ≤ 1 ∧ (c ν = 1 ↔ ν ∈ LRcoefficients λ μ) := by
  sorry -- REPLACE

/-- The tropical determinant is invariant under K-conjugation.
    Bridge: connects invariant theory to lattice_crypto (shortest vector). -/
lemma tropical_det_K_invariant
    (M : Matrix (Fin 2) (Fin 2) (Tropical ℝ))
    (k : TropicalPermutationMatrix 2) :
    (k.val * M * k.val.transpose).det = M.det := by
  sorry -- REPLACE

/-- Tropical Weyl group action on diagonal matrices has the expected order.
    Bridge: connects Coxeter group theory to quantum hamiltonian_spectrum. -/
lemma tropical_weyl_order
    (w : SymGroup 2) (d : Fin 2 → Tropical ℝ) :
    w ≠ 1 → diagonal (d ∘ w.equiv) ≠ diagonal d := by
  sorry -- REPLACE

/-- Min-plus convolution of K-biinvariant functions is K-biinvariant.
    Bridge: connects harmonic analysis to post_quantum_security (lattice convolution). -/
lemma minplus_convolution_biinvariant
    (f g : TropicalHeckeAlgebra) :
    (f * g).biinvariant := by
  sorry -- REPLACE

/-- Tropical Schur polynomial is Weyl-invariant (symmetric in tropical sense).
    Bridge: connects symmetric function theory to certified_robustness (tropical margin). -/
lemma tropical_schur_weyl_symmetric
    (λ : YoungDiagram 2) :
    (tropicalSchur λ).weyl_symmetric := by
  sorry -- REPLACE

/-- Support of min-plus convolution has O(n log n) bound.
    Bridge: connects computational complexity to cryptographic hash efficiency. -/
lemma minplus_convolution_support_bound
    (f g : TropicalHeckeAlgebra) :
    (f * g).carrier.support.card ≤
      f.carrier.support.card * g.carrier.support.card := by
  sorry -- REPLACE

/-- The Satake transform preserves the tropical "unit" (constant function 0).
    Bridge: connects category theory to tropical_hash_collision (identity element). -/
lemma satake_preserves_tropical_unit :
    SatakeTransform.map ⊤ = tropicalSchur (YoungDiagram.zero 2) := by
  sorry -- REPLACE

/-- Tropical Littlewood-Richardson coefficients are idempotent (0 or 1).
    This is the key structural fact enabling commutativity.
    Bridge: connects combinatorics to hamiltonian_spectrum (degeneracy). -/
lemma tropical_LR_coefficients_idempotent
    (λ μ ν : YoungDiagram 2) :
    tropicalLRCoeff λ μ ν = 0 ∨ tropicalLRCoeff λ μ ν = 1 := by
  sorry -- REPLACE

/-- The tropical spectral radius bounds the Satake transform.
    Explicit Lipschitz constant L = 2 for certified_robustness applications.
    Bridge: connects spectral theory to ML certified robustness. -/
lemma satake_lipschitz_bound
    (f : TropicalHeckeAlgebra) :
    ‖SatakeTransform.map f‖ ≤ 2 * ‖f‖ := by
  sorry -- REPLACE

/-- Double coset enumeration: K\GL₂/K ↔ A⁺/W bijectively.
    O(n!) enumeration cost from Weyl group.
    Bridge: connects geometric group theory to lattice_crypto enumeration. -/
lemma double_coset_bijection_weyl :
    ∃ (bij : KDoubleCoset ≃ TropicalDominantChamber),
      ∀ x, bij x = tropicalCartanRepresentative x := by
  sorry -- REPLACE
```

### IV. PROOF STRATEGY ARCHITECTURE

**Strategy A (Direct Combinatorial — Recommended):**
1. Enumerate K-double-cosets via tropical Cartan decomposition (Theorem 2).
2. Show the Hecke algebra has basis indexed by dominant coweights (Young diagrams of size ≤ n).
3. Compute structure constants via tropical LR coefficients (which are 0 or 1 by the idempotent property).
4. The Satake transform sends the coweight basis to tropical Schur polynomials, which are Weyl-invariant.
5. Bijectivity follows from linear independence of tropical Schur polynomials over ℝ_max.

**Strategy B (Tropical Schur-Weyl Duality):**
1. Establish a tropical analogue of Schur-Weyl duality for GL₂(ℝ_max).
2. Use the duality to transfer commutativity from the symmetric group side.
3. The Satake isomorphism becomes the "Fourier transform" in this duality.

**Strategy C (Dequantization — Most Elegant):**
1. Start from the classical Satake isomorphism for GL₂(ℚ_p).
2. Apply the Maslov dequantization parameter h → 0⁺ (replacing x·y with x^(1/h)·y^(1/h) → max(x,y)).
3. Show that the classical isomorphism degenerates to the tropical one in the limit.
4. This connects to Witten's deformation in quantum physics (Bridge: connects geometric Langlands to quantum field theory, hamiltonian_spectrum).

**Recommendation:** Strategy A is most promising for formalization because it avoids analytic limits (Strategy C) and doesn't require developing full Schur-Weyl machinery (Strategy B). The key insight is that tropical LR coefficients being idempotent (0 or 1) makes the algebra commutative — a purely combinatorial fact.

### V. REVOLUTIONARY SIGNIFICANCE

This work opens **tropical Langlands theory** — the min-plus shadow of the Langlands program. The Satake isomorphism is the "first rung" of the Langlands ladder, and its tropicalization suggests:

1. **Tropical automorphic forms** exist and satisfy min-plus functional equations.
2. **Tropical L-functions** can be defined via the Satake correspondence, with potential applications to `lattice_crypto` (tropical hash functions with provable `tropical_hash_collision` resistance).
3. **Certified robustness** for tropical-geometric neural networks: the Satake isomorphism gives a canonical `certified_robustness` certificate via Weyl-invariant polynomials with explicit `lipschitz_bound` L = 2.
4. **Quantum connection**: the dequantization limit h → 0 connects to `hamiltonian_spectrum` in tropical quantum mechanics (Bridge: connects representation theory to quantum physics).

### VI. DEMANDED FUTURE DIRECTIONS

Aristotle MUST produce a structured FUTURE_DIRECTIONS.md containing:

1. **Tropical Langlands for GL_n**: Extend the Satake isomorphism to GL_n(ℝ_max), where the Weyl group is S_n and tropical Schur polynomials become tropical characters. Conjecture: the isomorphism holds for all n with O(n²) computational cost.

2. **Tropical Local L-functions**: Define tropical L-functions L(s, π) = ⊕_v max(0, Re(s) - v) using the Satake correspondence, and prove they satisfy a tropical functional equation with `post_quantum_security` applications.

3. **Certified Robustness via Tropical Representation Theory**: Use the Satake isomorphism to give `certified_robustness` bounds for ReLU networks with `lipschitz_bound` derived from Weyl-invariant tropical polynomials.

4. **Dequantization and Quantum Field Theory**: Formalize the Maslov dequantization limit connecting classical Satake to tropical Satake, establishing a bridge to `hamiltonian_spectrum` computations in tropical quantum mechanics.

5. **Tropical Hash Functions with Provable Collision Resistance**: Define a cryptographic hash based on the Satake transform and prove `tropical_hash_collision` resistance using the injectivity of the isomorphism.

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
            Open the field of tropical Langlands theory by proving three foundational theorems: (1) The spherical Hecke algebra H(GL₂(ℝ_max), K) is a commutative idempotent semiring under min-plus convolution, with structure constants given by tropical Schur polynomials satisfying max-plus polynomial identities; (2) The tropical Cartan decomposition GL₂(ℝ_max) = K·A⁺·K yields a canonical enumeration of double cosets by dominant coweights, with uniqueness modulo the Weyl group action; (3) The Satake transform S: H → R(T)^W establishes a semiring isomorphism between the idempotent Hecke algebra and the Weyl-invariant tropical representation ring, providing the foundational duality for the min-plus Langlands program. This bridges tropical geometry, representation theory, and number theory — the first formalized connection between min-plus algebra and the Langlands philosophy.

            ### Precise Mathematical Framing
            Classically, the Satake isomorphism identifies the spherical Hecke algebra of p-adic GL_n with the representation ring of its Langlands dual group. In the min-plus setting, we replace the p-adic field by ℝ_max = (ℝ∪{∞}, min, +). The Cartan decomposition becomes fully combinatorial: every invertible tropical matrix factors as K·diag(λ₁, λ₂)·K where λ₁ ≥ λ₂ in the tropical order. The Hecke algebra H inherits idempotent structure from the tropical semiring (since min(a,a) = a), making it a commutative idempotent semiring. The Satake transform S(f)(t) = max_{k∈K} f(ktk⁻¹) becomes a max-plus integration, and the isomorphism reduces to verifying that tropical Schur polynomials satisfy the Weyl-symmetry and multiplication identities. For GL₂, the proof is explicitly computable: the structure constants c_{μ,ν}^λ of H are tropical (min-plus) polynomials in the diagonal entries, and the Satake isomorphism identifies these with tropical characters of the dual group.



            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `tropical_max_idempotent` : theorem tropical_max_idempotent (x : ℝ) : max x x = x := max_self x
     (file: Bridges/BreakthroughDirections.lean)
  2. `tropical_duality_min_to_max` : theorem tropical_duality_min_to_max (a b : ℝ) :
     (file: Tropical/Cryptography/TropicalTrapdoorResearch.lean)
  3. `hecke_score_beatpath_stable_under_score_margin_perturbation` : theorem hecke_score_beatpath_stable_under_score_margin_perturbation
     (file: Bridges/BeatpathRobustness.lean)
  4. `tropical_polynomial_degree` : theorem tropical_polynomial_degree (n : ℕ) : n ≤ n := le_refl n
     (file: Bridges/FiveFrontiers.lean)
  5. `gl3_tropical_satake_top1_stability` : theorem gl3_tropical_satake_top1_stability
     (file: Bridges/GL3TropicalSatakeScoreStability.lean)

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



Recent successful concepts: Galois-Neural Correspondence: Weight Permutation Symmetry Groups, Activation Splitting Field Expressivity, and Solvable Architecture Training Certification, tropical_cryptography_breakthrough_bridge, Pythagorean Spin Geometry: Berggren-Clifford Embedding, Light-Cone Spinor Action, and Dirac Spectral Gap on the Modular Tree


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

Research domain: Bridges
Research mode: prove
