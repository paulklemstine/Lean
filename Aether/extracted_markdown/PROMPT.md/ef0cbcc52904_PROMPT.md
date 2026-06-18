

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

## YOUR ASSIGNMENT: Berggren Lattice Cryptography: Hyperbolic SVP Hardness, Factoring Reduction, and Post-Quantum Key Exchange via Pythagorean Geometry

**TARGET THEOREM**: `BerggrenLatticeCryptography` — Prove that the Berggren tree of primitive Pythagorean triples induces a lattice structure whose Shortest Vector Problem is at least as hard as integer factoring, establishing a post-quantum cryptographic foundation rooted in Lorentzian geometry.

---

### PRECISE FORMAL TARGETS

**Main Theorem (Lean 4 Signature):**
```lean
theorem berggren_svp_hardness_reduction :
    ∀ (n : ℕ) (h : n > 1),
      ∃ (L : Lattice ℤ³) (hv : L.WellFormed),
        (∀ v ∈ L.basis, BerggrenLorentzInvariant v) ∧
        (ShortestVector L ≤ (3 : ℝ) * Real.sqrt (3 : ℝ)) ∧
        (∃ f : FactoringInstance → SVPLatticeInstance,
          ∀ (fi : FactoringInstance) (hfi : fi.modulus = n),
            (SVP_solution (f fi) → Factorization n) ∧
            ComplexityReduction f = O(polylog n))
```

This states: for every integer n > 1, there exists a well-formed lattice in ℤ³ preserved by the Berggren-Lorentz group, with shortest vector bounded by 3√3, such that solving SVP on this lattice yields a factorization of n, with polynomial-logarithmic reduction overhead.

**Secondary Theorems (10 required, diverse tactics):**

```lean
-- T1: Berggren matrices preserve the Lorentz form (tactic: fin_cases + ring)
theorem berggren_lorentz_preservation :
    ∀ (M : Fin 3 → Fin 3 → ℤ) ∈ {BerggrenMatrix.A, BerggrenMatrix.B, BerggrenMatrix.C},
      Mᵀ * lorentzForm * M = lorentzForm

-- T2: Every primitive triple lies on the light cone (tactic: field_simp + norm_cast)
theorem light_cone_classification :
    ∀ (a b c : ℕ), PrimitivePythagoreanTriple a b c →
      a² + b² - c² = 0 ∧ gcd a b = 1

-- T3: Berggren tree exhaustiveness — surjectivity (tactic: induction on depth)
theorem berggren_tree_surjective :
    ∀ (t : Fin 3 → ℕ), PrimitivePythagoreanTriple t 0 t 1 t 2 →
      ∃ (path : List BerggrenMatrix), berggrenPath path (3, 4, 5) = t

-- T4: Injectivity of Berggren paths (tactic: by_contra + omega)
theorem berggren_path_injective :
    ∀ (p₁ p₂ : List BerggrenMatrix),
      berggrenPath p₁ (3, 4, 5) = berggrenPath p₂ (3, 4, 5) → p₁ = p₂

-- T5: SVP lower bound for Berggren lattices (tactic: linarith + norm_cast)
theorem berggren_svp_lower_bound :
    ∀ (L : BerggrenLattice) (n : ℕ) (hn : n ≥ 2),
      ShortestVector L ≥ 5 ∧
      λ₁(L) ∈ Set.Icc 5 (3 * Real.sqrt 3 * (n : ℝ)^(1/3 : ℝ))

-- T6: Factoring-to-SVP reduction correctness (tactic: rcases + constructive)
theorem factoring_to_svp_correctness :
    ∀ (n : ℕ) (hn : n > 1) (p q : ℕ) (hmul : p * q = n),
      ∃ (L : BerggrenLattice) (v : ℤ³),
        v ∈ L.basis ∧
        ‖v‖ = Real.sqrt ((p : ℝ)² + (q : ℝ)²) ∧
        IsShortestVector L v → p.factorOf n

-- T7: Post-quantum security — quantum query lower bound (tactic: by_contra + measure arguments)
theorem post_quantum_svp_berggren_lower_bound :
    ∀ (ε : ℝ) (hε : ε > 0) (n : ℕ) (hn : n ≥ 256),
      ∀ (A : QuantumOracle → BerggrenLattice → ℤ³),
        Pr[IsShortestVector (A oracle L)] ≤ ε →
          QuantumQueryComplexity A ≥ Ω(n^(1/4 : ℝ) / polylog n)

-- T8: Key exchange completeness — Alice and Bob agree (tactic: induction + simp)
theorem berggren_key_exchange_completeness :
    ∀ (pub : BerggrenPublicKey) (sec₁ sec₂ : BerggrenSecretKey),
      let shared₁ := berggrenDerive pub sec₁
      let shared₂ := berggrenDerive pub sec₂
      sec₁.agrees sec₂ → shared₁ = shared₂

-- T9: Key exchange soundness — eavesdropper bound (tactic: by_contra + field theory)
theorem berggren_key_exchange_soundness :
    ∀ (pub : BerggrenPublicKey) (eavesdropper : QuantumAdversary),
      Pr[eavesdropper.predicts pub.sharedSecret] ≤ 1/2 + negl(λ)
      where negl(λ) = O(λ^2 / 2^λ)

-- T10: Lorentz group action is free on primitive triples (tactic: group theory + rcases)
theorem berggren_lorentz_free_action :
    ∀ (M : LorentzMatrix) (t : PrimitivePythagoreanTriple),
      M • t = t → M = 1
```

---

### PROOF STRATEGY (Multiple Paths)

**Strategy A — Direct Reduction via Minkowski Theory:**
1. Prove `berggren_lorentz_preservation` by direct matrix computation (each Berggren matrix A, B, C satisfies MᵀJM = J where J = diag(1,1,-1)).
2. Show the Berggren lattice L_n has determinant det(L_n) = n · φ(n) where φ is Euler's totient, using the Lorentz form's discriminant.
3. Apply Minkowski's convex body theorem to bound λ₁(L_n) ≤ √(2·det(L_n)/vol(B)) where B is the unit ball in the Lorentz metric.
4. Construct the factoring reduction: given n = pq, the vector (p, q, √(p²+q²)) is a short vector in L_n. Recovering p, q from this vector factors n.
5. **Why promising**: Direct, constructive, gives explicit constants. **Risk**: Minkowski bounds may be too coarse for the lower bound.

**Strategy B — Algebraic Number Theory via ℚ(√-1):**
1. Embed primitive Pythagorean triples into the ring of integers of ℚ(√-1) via (a + bi)(c + di) = (ac - bd) + (ad + bc)i.
2. Use the norm form N(a + bi) = a² + b² to connect to the Lorentz form.
3. The Berggren matrices correspond to units in a related order; SVP in this order's lattice corresponds to factoring the norm.
4. Apply Regev's LWE-to-factoring framework (Regev 2005) to lift the reduction to the quantum setting.
5. **Why promising**: Deep algebraic structure, connects to class field theory. **Risk**: Requires substantial algebraic number theory infrastructure.

**Strategy C — Combinatorial Tree Cryptography (Recommended):**
1. Prove `berggren_tree_surjective` and `berggren_path_injective` establishing the Berggren tree as a bijection between binary strings and primitive triples.
2. Define the Berggren lattice L_n as the ℤ-span of {A·v, B·v, C·v} where v = (3,4,5), with the quadratic form Q(a,b,c) = a² + b² - c².
3. Show that finding the Berggren path from (3,4,5) to a target triple (a,b,c) with c ≡ 0 (mod n) is equivalent to finding a factor of n.
4. Prove `berggren_svp_lower_bound` by showing any short vector in L_n encodes a factorization.
5. Establish `post_quantum_svp_berggren_lower_bound` by adapting Regev's quantum lower bound technique, using the Lorentz group's non-abelian structure to prevent efficient quantum Fourier sampling.
6. **Why most promising**: The tree structure gives a clean bijection (path ↔ triple), the Lorentz invariance gives the lattice structure, and the modular condition gives the factoring connection. Each piece has an independent proof that composes cleanly.

---

### DEFINITIONS REQUIRED (5+ new structures)

```lean
/-- The Lorentz quadratic form Q(a,b,c) = a² + b² - c² -/
structure LorentzForm where
  toFun : ℤ³ → ℤ
  lorentz_property : ∀ v, toFun v = v 0 ^ 2 + v 1 ^ 2 - v 2 ^ 2

/-- The three Berggren matrices preserving the Lorentz form -/
inductive BerggrenMatrix where
  | A : BerggrenMatrix  -- (-1, 2, 2; -2, -1, -2; -2, -2, -3) wait, need the correct ones
  | B : BerggrenMatrix
  | C : BerggrenMatrix
  deriving DecidableEq, Repr

/-- A lattice in ℤ³ preserved by the Berggren-Lorentz group -/
structure BerggrenLattice where
  basis : Fin 3 → ℤ³
  lorentz_invariant : ∀ i j, LorentzForm.eval (basis i) = LorentzForm.eval (basis j) → basis i = basis j ∨ ...
  well_formed : Matrix.det (Matrix.of basis) ≠ 0

/-- Public key for Berggren key exchange -/
structure BerggrenPublicKey where
  lattice : BerggrenLattice
  modulus : ℕ
  commitment : ℤ³  -- A short vector commitment

/-- Post-quantum security parameter -/
structure PostQuantumSecurityParameter (λ : ℕ) where
  quantum_query_lower_bound : ℕ := λ ^ 2
  classical_advantage_bound : ℝ := 1 / (2 ^ λ)
  valid : λ ≥ 128 ∧ classical_advantage_bound < 1/2^128
```

---

### CROSS-DOMAIN CONNECTIONS

**Bridge 1: Hyperbolic Geometry ⟶ Lattice Cryptography**
The Berggren matrices live in O⁺(2,1; ℤ), the orthochronous Lorentz group. This is the same group acting on the hyperboloid model of hyperbolic geometry. SVP in Berggren lattices is thus equivalent to finding short geodesics in a discrete hyperbolic geometry — a problem known to be hard even for quantum computers due to the exponential volume growth of hyperbolic space.

**Bridge 2: Algebraic Number Theory ⟶ Post-Quantum Security**
The ring ℤ[i] of Gaussian integers, where a² + b² = c² becomes N(a+bi) = c², connects Pythagorean triples to ideal factorization. The hardness of SVP in Berggren lattices reduces to the hardness of ideal factorization in orders of imaginary quadratic fields — precisely the setting where Regev's quantum lower bounds apply.

**Bridge 3: Tropical Geometry ⟶ Certified Robustness**
The tropicalization of the Berggren tree (replacing + with min and × with +) yields a tropical Pythagorean tree where the "tropical hypotenuse" min(a,b) + c satisfies a tropical Pythagorean theorem. This tropical structure provides Lipschitz-certified robustness bounds for neural networks whose decision boundaries are tropical hypersurfaces — the margin is exactly the Berggren shortest vector length.

---

### SIGNIFICANCE AND APPLICATIONS

This work establishes that the 3800-year-old structure of Pythagorean triples, organized by Berggren's 1934 tree, conceals a lattice whose computational hardness underpins post-quantum cryptography. Specifically:

1. **Post-Quantum Key Exchange**: The `BerggrenLattice` structure enables a Diffie-Hellman-like protocol where two parties exchange Berggren lattice points and derive a shared secret from the shortest vector. The non-abelian structure of the Lorentz group prevents quantum Fourier sampling attacks.

2. **Factoring Hardness Reduction**: Proving that factoring n reduces to SVP in the Berggren lattice L_n means any quantum algorithm breaking our key exchange would also factor integers efficiently — violating the widely-held assumption that factoring resists quantum attack for classical key sizes.

3. **Certified Robustness for ML**: The tropical Pythagorean theorem gives explicit Lipschitz bounds: if a neural network's decision boundary is a tropical hypersurface with margin δ, then adversarial perturbations of size < δ/(2K) where K = 3√3 are certified safe.

---

### FUTURE_DIRECTIONS REQUIREMENT

After proving the main theorems, produce a `FUTURE_DIRECTIONS.md` with:

1. **Tropical Langlands for Berggren Lattices**: Prove that the tropical Satake transform maps Berggren lattice representations to tropical Hecke eigensheaves, establishing a tropical Langlands correspondence for O(2,1).

2. **Quantum Hamiltonian Encoding**: Embed the Berggren SVP instance into the ground state of a local Hamiltonian, connecting to the quantum PCP conjecture. Prove that estimating the ground state energy to precision O(1/poly(n)) is QCMA-hard.

3. **Neural Network Certified Robustness**: Use the tropical Berggren tree to construct provably robust neural network classifiers where the robustness certificate is a Berggren shortest vector.

4. **Higher-Dimensional Berggren Trees**: Generalize from O(2,1) to O(n,1) for hyperbolic lattices in higher dimensions, connecting to Vinberg's reflection groups and higher-dimensional post-quantum cryptography.

5. **Berggren Lattice-Based Signatures**: Construct a signature scheme where signing requires finding a Berggren path (easy with the secret key) and verification checks Lorentz invariance (easy publicly), with unforgeability reducing to SVP hardness.

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
            Open the field of Pythagorean lattice cryptography by: (1) Defining the Berggren lattice B_n as the Z-lattice generated by Berggren matrix group actions on primitive Pythagorean triples, equipped with the Lorentzian quadratic form Q(a,b,c) = a^2 + b^2 - c^2 inherited from the light cone embedding, and proving that B_n has rank n with determinant related to the Pell sequence; (2) Proving the Berggren-Factoring Reduction: integer factorization polynomially reduces to the shortest vector problem on B_n, establishing Berggren-SVP as FACTORING-hard via the correspondence between factorization witnesses and minimal Berggren geodesics; (3) Proving the Hyperbolic Quantum Barrier: the quantum query complexity of Berggren-SVP satisfies a 2^{Omega(n^{1/3})} lower bound due to destructive interference among exponentially many minimal-length geodesics in the Berggren tree's hyperbolic geometry, which resists Grover-type amplitude amplification; (4) Constructing Berggren Key Exchange: a Diffie-Hellman-type protocol on the Berggren lattice with provable IND-CPA security under Berggren-SVP hardness, with quantum resistance following from the hyperbolic quantum barrier; (5) Establishing the Pythagorean Hardness Hierarchy: FACTORING <=_P BERGGREN-SVP <=_P GAP-SVP_gamma for gamma = poly(n), placing Berggren lattice problems in a novel complexity-theoretic position between factoring and standard lattice problems.

            ### Precise Mathematical Framing
            Let B_n denote the Berggren lattice of rank n with Lorentzian form Q(x) = x_1^2 + x_2^2 - x_3^2 restricted to the Z-span of Berggren orbits on primitive Pythagorean triples. The Berggren matrices A, B, C in SL(2,Z) act on the light cone, generating a lattice with intrinsic hyperbolic geometry. Prove five theorems: (i) BerggrenLatticeStructure: B_n has rank n and det(B_n) = Pell(n+1), where Pell denotes the Pell sequence; (ii) BerggrenSVPFactoringReduction: for all n >= 3, integer factorization of n-bit numbers polynomially many-one reduces to SVP on B_n; (iii) BerggrenQuantumBarrier: QBERG(BerggrenSVP_n) >= 2^{n^{1/3}}, where QBERG denotes bounded-error quantum query complexity; (iv) BerggrenKeyExchangeSecurity: there exists a key exchange protocol KE_B on B_n such that for any QPT adversary A, Adv_{A,KE_B} <= n^2 * Adv_{SVP,B_n}(A) + negl(n); (v) PythagoreanHardnessHierarchy: FACTORING <=_P BERGGREN-SVP <=_P GAP-SVP_{poly(n)}.

            ### Lean 4 Sketch
BerggrenLatticeCryptography

            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `height_lower_bound_length` : theorem height_lower_bound_length (w : BWord) {t : Triple} (ht : GoodTriple t) :
     (file: Cryptography/BerggrenHeightDescent.lean)
  2. `height_lower_bound_length` : theorem height_lower_bound_length (w : BerggrenWord) {t : Triple} (ht : GoodTriple t) :
     (file: Cryptography/BerggrenLatticeReduction.lean)
  3. `berggren_walk_support_lower_bound` : theorem berggren_walk_support_lower_bound :
     (file: Cryptography/BerggrenSpectralHash.lean)
  4. `grover_quadratic_bound` : theorem grover_quadratic_bound (d : ℕ) :
     (file: Cryptography/QuantumSecurity/ShorECDSA.lean)
  5. `lattice_shortest_vector_gap` : theorem lattice_shortest_vector_gap (a b c d : ℤ)
     (file: EML/SPBExtended/QDF_FiveDirections.lean)

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



Recent successful concepts: Tropical Modular Lensing: Berggren Critical Curves, Cuspidal Factorization, and Max-Plus Geodesic Deflection on the Modular Tree, Tropical Holographic Duality: Max-Plus Conformal Extension from the Berggren Light Cone Boundary to the Tropical Upper Half-Plane and Satake Operator-State Correspondence, Tropical Galois Theory: Max-Plus Automorphism Groups, Idempotent Galois Correspondence, and Tropical Solvability of Polynomial Equations


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

Research domain: Cryptography
Research mode: prove
