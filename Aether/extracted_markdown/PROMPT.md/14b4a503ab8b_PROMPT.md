

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

## TARGET: Noetherian Cryptographic Certification — ACC Protocol Termination, Finitely Generated Key Certification, and Quotient Ring Homomorphic Correctness

**Bridge: connects Noetherian commutative algebra to post-quantum lattice cryptography and certified ML robustness**

---

### Core Definitions (5+ novel structures)

```lean
/-- A Noetherian certification protocol: an ascending chain of ideals
    modeling iterative key refinement in lattice-based cryptography.
    The ACC guarantees termination, bounding the number of refinement rounds
    by the Krull dimension — a structural complexity bound with no analog
    in non-Noetherian settings. -/
structure NoetherianCertProtocol (R : Type*) [CommRing R] where
  chain : ℕ → Ideal R
  chain_mono : ∀ n, chain n ≤ chain (n + 1)
  krull_bound : ℕ

/-- A finitely generated key ideal with an explicit generating set
    and a certified bound on the number of generators.
    This is the algebraic certificate for post-quantum key generation
    in ideal lattice cryptosystems (e.g., NTRU, Ring-LWE). -/
structure CertifiedKeyIdeal (R : Type*) [CommRing R] where
  ideal : Ideal R
  gens : Finset R
  gens_spec : ideal = Ideal.span gens
  gen_card_bound : gens.card ≤ krullDim R + 1

/-- Homomorphic encryption correctness certificate: the quotient map
    R → R/I preserves ring structure, enabling verified computation
    on encrypted data. Critical for FHE schemes where I is the
    noise ideal. -/
structure HomomorphicCertificate (R : Type*) [CommRing R] (I : Ideal R) where
  preserves_add : ∀ x y, Ideal.Quotient.mk I (x + y) = Ideal.Quotient.mk I x + Ideal.Quotient.mk I y
  preserves_mul : ∀ x y, Ideal.Quotient.mk I (x * y) = Ideal.Quotient.mk I x * Ideal.Quotient.mk I y
  preserves_one : Ideal.Quotient.mk I (1 : R) = 1

/-- The stabilization index of an ascending chain — the exact point
    where Noetherian-ness forces equality. This index bounds the
    computational depth of key refinement protocols. -/
def stabilizationIndex {R : Type*} [CommRing R] [IsNoetherianRing R]
    (chain : ℕ → Ideal R) (hmono : ∀ n, chain n ≤ chain (n + 1)) : ℕ :=
  Classical.choose (IsNoetherianRing.ascendingChainCondition chain hmono)

/-- Krull-bounded key generation complexity: the number of
    generators needed for any ideal is bounded by Krull dimension + 1.
    This gives O(d) where d = krullDim R for key generation in
    post-quantum lattice-based schemes. -/
def krullKeyComplexity (R : Type*) [CommRing R] [IsNoetherianRing R] : ℕ :=
  (Classical.choose (∀ (I : Ideal R), ∃ (gens : Finset R), I = Ideal.span gens)).card
```

---

### Theorem 1: ACC Protocol Termination with Krull Dimension Bound

```lean
/-- **Noetherian Certification Protocol Termination**
    Any ascending chain of ideals in a Noetherian ring of Krull dimension d
    stabilizes in at most d+1 steps. This is the algebraic heart of
    termination guarantees for iterative key refinement in lattice-based
    post-quantum cryptography (Ring-LWE, NTRU).

    Bridge: connects commutative algebra (Noetherian rings) to
    post-quantum cryptography (lattice protocol termination). -/
theorem acc_protocol_termination {R : Type*} [CommRing R] [IsNoetherianRing R]
    (hdim : krullDim R = some d)
    (chain : ℕ → Ideal R)
    (hmono : ∀ n, chain n ≤ chain (n + 1)) :
    ∃ N ≤ d + 1, ∀ n ≥ N, chain n = chain N := by
  -- Strategy A (chosen): Use the Noetherian ACC directly from
  -- IsNoetherianRing.ascendingChainCondition, then refine the bound
  -- using Krull dimension: each strict inclusion increases height by ≥ 1,
  -- so at most d+1 strict inclusions are possible.
  -- Strategy B (alternative): Contrapositive — if chain has > d+1 strict
  -- inclusions, construct a prime chain of length > d, contradicting krullDim.
  -- Strategy C (constructive): Explicit witness via stabilizationIndex,
  -- prove stabilizationIndex ≤ d + 1 by well-founded induction on height.
  sorry
```

---

### Theorem 2: Finitely Generated Key Certification

```lean
/-- **Finitely Generated Key Certification**
    Every ideal in a Noetherian ring admits a finite generating set —
    the Hilbert Basis Theorem in ideal form. For cryptographic applications,
    this guarantees that any key ideal (even adversarially constructed)
    has a finite certificate of membership, enabling O(|gens|) verification.

    Bridge: connects ideal theory to post-quantum key certification
    and Gröbner basis computation. -/
theorem finitely_generated_key_certification {R : Type*} [CommRing R]
    [IsNoetherianRing R] (I : Ideal R) :
    ∃ (gens : Finset R), I = Ideal.span gens ∧
      gens.card ≤ (krullDim R).getD 0 + 1 := by
  -- Key lemma: IsNoetherianRing implies every ideal is finitely generated.
  -- The cardinality bound follows from Nakayama's lemma applied to
  -- the minimal generating set, using that height(I) ≤ d.
  sorry
```

---

### Theorem 3: Quotient Ring Homomorphic Correctness

```lean
/-- **Quotient Ring Homomorphic Encryption Correctness**
    The canonical projection R → R/I is a ring homomorphism — the
    foundational certificate for homomorphic encryption schemes where
    I is the noise ideal. This enables verified computation on encrypted
    data with O(1) correctness verification per operation.

    Bridge: connects ring quotients to fully homomorphic encryption
    correctness and lattice-based post-quantum security. -/
theorem quotient_homomorphic_correctness {R : Type*} [CommRing R]
    (I : Ideal R) :
    IsRingHom (Ideal.Quotient.mk I) := by
  -- Direct proof: unfold Ideal.Quotient.mk and verify all three axioms.
  -- The key insight is that coset arithmetic in R/I inherits the ring
  -- structure from R precisely because I is a two-sided ideal.
  sorry
```

---

### Supporting Lemmas (7+ theorems, diverse tactics)

```lean
/-- Strict inclusions increase height: if I ⊊ J then height I < height J.
    Uses by_contra and the definition of Krull dimension. -/
theorem strict_inclusion_height_increase {R : Type*} [CommRing R]
    [IsNoetherianRing R] {I J : Ideal R} (hsub : I < J) :
    (height I).getD 0 < (height J).getD 0 := by
  by_contra h; push_neg at h; -- contradiction approach
  sorry

/-- The stabilization index is well-defined and minimal. -/
theorem stabilization_index_minimal {R : Type*} [CommRing R]
    [IsNoetherianRing R] (chain : ℕ → Ideal R)
    (hmono : ∀ n, chain n ≤ chain (n + 1)) :
    ∀ n < stabilizationIndex chain hmono, chain n ≠ chain (n + 1) := by
  intro n hn; by_contra heq; -- minimality contradiction
  sorry

/-- Krull dimension bounds the length of strict ascending chains. -/
theorem krull_dim_chain_bound {R : Type*} [CommRing R] [IsNoetherianRing R]
    (hdim : krullDim R = some d)
    (chain : ℕ → Ideal R)
    (hmono : ∀ n, chain n ≤ chain (n + 1))
    (hstrict : ∀ n < d + 1, chain n ≠ chain (n + 1)) :
    False := by
  -- Construct prime chain of length > d from strict inclusions
  sorry

/-- Certified key ideals form a lattice under inclusion.
    The meet is intersection, the join is sum.
    This lattice structure is the algebraic backbone of Ring-LWE
    key generation protocols. -/
theorem certified_key_ideal_lattice {R : Type*} [CommRing R]
    [IsNoetherianRing R] (I J : Ideal R) :
    ∃ (KI KJ KIJ : CertifiedKeyIdeal R),
      KI.ideal = I ∧ KJ.ideal = J ∧
      KIJ.ideal = I ⊔ J ∧ -- join = sum
      (KI.ideal ⊓ KJ.ideal : Ideal R) = I ⊓ J := by -- meet = intersection
  sorry

/-- Homomorphic certificates compose: if I ⊆ J then R/J → R/I
    is a ring homomorphism. This enables nested homomorphic encryption
    with O(log d) verification depth where d = krullDim R. -/
theorem homomorphic_certificate_composition {R : Type*} [CommRing R]
    {I J : Ideal R} (hsub : I ≤ J) :
    ∃ (cert : HomomorphicCertificate R J),
      (Ideal.Quotient.mk J ≫ Ideal.Quotient.map I hsub) =
      Ideal.Quotient.mk I := by
  sorry

/-- Nakayama's lemma for generator bound: if M is a finitely generated
    R-module and I ⊆ Jac R, then minimal generators are bounded.
    Critical for O(d) key generation complexity. -/
theorem nakayama_generator_bound {R : Type*} [CommRing R] [IsNoetherianRing R]
    {I : Ideal R} (hI : I ≤ IsNoetherianRing.jacobson R)
    (hfin : Module.Finite R (Ideal.Quotient.mk I).toFun) :
    ∃ (gens : Finset R), Ideal.span gens = I ∧
      gens.card ≤ (krullDim R).getD 0 + 1 := by
  sorry

/-- Post-quantum security reduction: breaking Ring-LWE key generation
    requires solving Ideal-SVP with approximation factor 2^O(d),
    where d = Krull dimension. This connects Noetherian structure to
    lattice crypto hardness. -/
theorem post_quantum_security_reduction {R : Type*} [CommRing R]
    [IsNoetherianRing R] (hdim : krullDim R = some d)
    (I : Ideal R) (hI : I ≠ ⊥) :
    ∃ (λ : ℝ), λ ≥ 2^(d : ℝ) ∧
      ∀ (v : R), v ∈ I → ‖(v : ℝ)‖ ≥ λ * (IsNoetherianRing.minNorm I) := by
  sorry
```

---

### Revolutionary Significance

This suite of theorems establishes the **Noetherian Cryptographic Certification Framework**: the first formal bridge between ascending chain conditions and post-quantum security guarantees. The key breakthroughs are:

1. **ACC → Protocol Termination**: Any key refinement protocol in a Noetherian ring terminates in O(d) rounds where d = Krull dimension — this is the first *dimension-dependent* termination bound, improving on the qualitative "eventually stabilizes" to a *quantitative* O(d) bound.

2. **Finite Generation → Key Certification**: Every ideal has a finite membership certificate, enabling O(|gens|) verification — this is the algebraic foundation of post-quantum key validation.

3. **Quotient Homomorphism → FHE Correctness**: The ring homomorphism property of R → R/I is the formal certificate for homomorphic encryption correctness, enabling verified computation on encrypted data.

**Cross-domain bridges**: Commutative algebra ↔ Post-quantum cryptography ↔ Certified ML robustness (Noetherian termination for verification algorithm convergence).

**FUTURE_DIRECTIONS.md requested**: After proving these theorems, produce a structured document with 3-5 concrete next steps, including:
- Noetherian certification for multivariate polynomial rings (connecting to Gröbner basis crypto)
- Krull dimension as a security parameter in Ring-LWE parameter selection
- Certified robustness bounds for neural networks via Noetherian ACC on verification queries
- Thermodynamic interpretation: ACC as entropy increase, stabilization as thermal equilibrium

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
            Open the field of Noetherian cryptographic certification by proving three foundational theorems that establish a rigorous bridge between commutative algebra (Noetherian ring theory) and cryptographic protocol certification. Theorem 1 (ACC Protocol Termination): For any Noetherian ring R of Krull dimension d, any iterative cryptographic protocol that generates an ascending chain of ideals I₀ ⊆ I₁ ⊆ ... terminates in at most d steps, providing a certified bound on protocol execution depth. Theorem 2 (Finitely Generated Key Certification): For any Noetherian ring R and ideal I, the finite generation of I (guaranteed by Hilbert's basis theorem) provides a certified key generation scheme where the key space R/I has a finite description of size bounded by the number of generators, and key validation is decidable via ideal membership. Theorem 3 (Quotient Ring Homomorphic Correctness): For any Noetherian ring R and ideal I, the quotient map π : R → R/I is a certifiably correct homomorphic encryption scheme for ring operations, where correctness is guaranteed by the ring homomorphism axioms and decryption is provided by canonical representatives via Gröbner basis normal forms. This creates the first formal bridge between Algebra (5009 declarations, highest exploration ratio) and Cryptography (I=7.6, highest impact), two domains with no existing bridge despite sharing ring, module, and norm structures.

            ### Precise Mathematical Framing
            Let R be a Noetherian ring with Krull dimension d. (1) ACC Termination: For any ascending chain of ideals I₀ ⊆ I₁ ⊆ ... arising from a cryptographic protocol over R, there exists N ≤ d such that Iₙ = I_N for all n ≥ N. The bound N ≤ dim(R) follows from the definition of Krull dimension and the ACC. (2) Key Certification: For I = ⟨f₁, ..., fₖ⟩ in R = K[x₁,...,xₘ], the quotient ring R/I has a certified finite description of size O(k·m·max deg(fᵢ)), and for any r ∈ R, the predicate r ∈ I is decidable via Gröbner basis normal form: r ∈ I ⟺ NF(r, G) = 0, where G is the Gröbner basis of I. (3) Homomorphic Correctness: The canonical projection π : R → R/I satisfies π(a + b) = π(a) + π(b) and π(a · b) = π(a) · π(b), certifying homomorphic correctness. Decryption recovers canonical representatives via NF(·, G): R/I → R, with NF(r + I, G) = NF(r, G) giving the unique normal form representative. The security reduction relies on the computational hardness of ideal membership without Gröbner basis access (EXPSPACE-complete in general).

            ### Lean 4 Sketch
theorem acc_protocol_termination {R : Type*} [CommRing R] [IsNoetherianRing R] (hdim : krullDim R = some d) : ∀ (chain : ℕ → Ideal R), (∀ n, chain n ≤ chain (n+1)) → ∃ N ≤ d, ∀ n ≥ N, chain n = chain N := ...

theorem finitely_generated_key_certification {R : Type*} [CommRing R] [IsNoetherianRing R] (I : Ideal R) : ∃ (gens : Finset R), I = Ideal.span gens := ...

theorem quotient_homomorphic_correctness {R : Type*} [CommRing R] (I : Ideal R) : IsRingHom (Ideal.Quotient.mk I) := ...

            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `tropical_key_space_lower_bound` : theorem tropical_key_space_lower_bound (n B : ℕ) :
     (file: Cryptography/TropicalPostQuantum.lean)
  2. `finitely_many_words_bounded_height` : theorem finitely_many_words_bounded_height (H : ℕ) :
     (file: Cryptography/BerggrenHeightDescent.lean)
  3. `svp_depth1_lower_bound` : theorem svp_depth1_lower_bound (s : BStep) :
     (file: Cryptography/BerggrenLatticeCryptography.lean)
  4. `finitely_many_words_bounded_height` : theorem finitely_many_words_bounded_height (H : ℕ) :
     (file: Cryptography/BerggrenLatticeReduction.lean)
  5. `bounded_key_recovery_exists` : theorem bounded_key_recovery_exists
     (file: Cryptography/BerggrenQuotient.lean)

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



Recent successful concepts: VSAlgebra Capacity Bounds: Near-Ring Binding Faithfulness, Superposition Retrieval Thresholds, and Compositional Holographic Certification, Proof Thermodynamics: Cut-Elimination Entropy Increase, Proof Energy Conservation, and Sequent Variational Principle, tropical_cryptography_breakthrough_bridge


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

Research domain: Cryptography
Research mode: prove
