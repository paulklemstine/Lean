

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

## ASSIGNMENT: Tropical Lattice Cryptography — Provable SVP-Hardness of Commutative Max-Plus Matrix Recovery

**DOMAIN**: Cryptography × Tropical Geometry × Lattice Theory

### I. FOUNDATIONAL DEFINITIONS (5+ required)

Formalize the following novel structures, each bridging at least two domains:

```lean
/-- Bridge: connects tropical algebra to lattice cryptography.
A tropical lattice is the image of Z^n under a max-plus linear map,
equipped with the tropical minimum-distance metric. -/
structure TropicalLattice (n : ℕ) where
  basis : Fin n → Matrix (Fin n) (Fin n) ℝ  -- commuting max-plus generators
  spectral_gap : ℝ
  gap_pos : 0 < spectral_gap
  commute : ∀ i j, i ≠ j → basis i ⊗ basis j = basis j ⊗ basis i

/-- Bridge: connects tropical geometry to post-quantum security.
The tropical SVP norm measures shortest non-zero vector in a tropical lattice. -/
def tropicalSVP_norm {n : ℕ} (L : TropicalLattice n) : ℝ :=
  sInf { d : ℝ | ∃ (v : Fin n → ℤ), v ≠ 0 ∧
    tropical_embed L v = tropical_embed L 0 + d }

/-- Bridge: connects cryptographic hardness to certified robustness.
The exponent-recovery problem: given A^{⊗a} ⊗ B^{⊗b}, find (a,b). -/
structure ExponentRecoveryProblem (n : ℕ) where
  lattice : TropicalLattice n
  target : Matrix (Fin n) (Fin n) ℝ
  cert : ∃ (e : Fin n → ℤ), tropical_embed lattice e = target

/-- Bridge: connects tropical metrics to Lipschitz certified robustness.
Minimum-distance bound for the tropical lattice embedding. -/
def tropical_embedding_min_dist {n : ℕ} (L : TropicalLattice n) : ℝ :=
  sInf { d : ℝ | ∃ (e e' : Fin n → ℤ), e ≠ e' ∧
    dist (tropical_embed L e) (tropical_embed L e') = d }

/-- Bridge: connects SVP hardness to post-quantum key exchange security.
Ajtai-type security parameter for tropical lattice cryptosystems. -/
def ajtai_security_param {n : ℕ} (L : TropicalLattice n) : ℝ :=
  L.spectral_gap ^ (n / 2 : ℕ)
```

### II. CORE THEOREM SEQUENCE (10+ theorems, diverse tactics, ZERO sorries)

**Theorem 1: Tropical Embedding is Well-Defined and Injective**
```lean
/-- Bridge: connects tropical algebra to injective lattice maps.
The tropical lattice embedding is injective when the spectral gap is positive. -/
theorem tropical_embed_injective_of_spectral_gap {n : ℕ} (L : TropicalLattice n)
    (h_gap : 0 < L.spectral_gap) :
    Function.Injective (tropical_embed L) := by
  -- Strategy: by_contra on distinct exponent pairs mapping to same matrix,
  -- then use spectral gap to derive contradiction via tropical eigenvalue separation.
  -- Key lemma: commuting max-plus matrices have separated eigenvalues when gap > 0.
  sorry  -- FILL WITH FULL PROOF
```

**Theorem 2: Minimum-Distance Lower Bound (The Critical Lemma)**
```lean
/-- Bridge: connects tropical geometry to lattice minimum-distance theory.
For distinct exponent pairs, the tropical embedding separates them by at least
Δ times the L∞ distance. This is the geometric heart of the SVP reduction. -/
theorem tropical_min_dist_lower_bound {n : ℕ} (L : TropicalLattice n)
    (e e' : Fin n → ℤ) (h_ne : e ≠ e') :
    dist (tropical_embed L e) (tropical_embed L e') ≥
      L.spectral_gap * (∑ i : Fin n, |(e i : ℝ) - (e' i : ℝ)|) / n := by
  -- Strategy A (preferred): Induction on ||e - e'||₁ with tropical power computation.
  --   Base: ||e-e'||₁ = 1 means exactly one coordinate differs by 1.
  --   Step: tropical matrix product amplifies gap by spectral_gap each time.
  -- Strategy B: Direct computation using tropPow_tropPow_comm_of_comm and
  --   tropicalLipschitz_composition to bound entry-wise differences.
  -- Strategy C: Reduce to single-coordinate case via commutativity, then
  --   apply spectral gap bound entry-by-entry.
  sorry
```

**Theorem 3: Tropical SVP Norm Equals Spectral Gap (up to constants)**
```lean
/-- Bridge: connects tropical SVP to classical SVP via norm equivalence.
The tropical shortest vector has norm Θ(Δ), establishing the lattice structure
required for Ajtai's reduction. -/
theorem tropical_SVP_spectral_gap_bound {n : ℕ} (L : TropicalLattice n) :
    L.spectral_gap ≤ tropicalSVP_norm L ∧
    tropicalSVP_norm L ≤ (n : ℝ) * L.spectral_gap := by
  -- Lower bound: shortest vector has at least Δ separation (Thm 2, n=1 case).
  -- Upper bound: unit coordinate vector gives Δ separation, amplified by n entries.
  sorry
```

**Theorem 4: Exponent Recovery Reduces to SVP**
```lean
/-- Bridge: connects cryptographic recovery to lattice problems.
Solving the exponent recovery problem is at least as hard as SVP in the
associated tropical lattice. This is the security reduction. -/
theorem exponent_recovery_SVP_reduction {n : ℕ} (P : ExponentRecoveryProblem n)
    (h_gap : 0 < P.lattice.spectral_gap) :
    ∀ (oracle : (Matrix (Fin n) (Fin n) ℝ → Fin n → ℤ)),
      (∀ M, tropical_embed P.lattice (oracle M) = M → True) →
      ∀ (v : Fin n → ℤ), v ≠ 0 →
        dist (tropical_embed P.lattice v) (tropical_embed P.lattice 0) =
          tropicalSVP_norm P.lattice →
        ∃ (e : Fin n → ℤ), oracle P.target = e ∧ tropical_embed P.lattice e = P.target := by
  -- Key insight: SVP oracle finds shortest lattice vector, which by Thm 2
  -- corresponds to the exponent pair with minimal L1 norm. Iterating SVP
  -- recovers all coordinates of the exponent vector.
  sorry
```

**Theorem 5: Ajtai Hardness Inheritance**
```lean
/-- Bridge: connects tropical cryptography to post-quantum security.
The Ajtai security parameter provides an Ω(Δ^{n/2}) lower bound on
exponent recovery, inheriting SVP hardness from Ajtai's reduction. -/
theorem ajtai_hardness_inheritance {n : ℕ} (L : TropicalLattice n)
    (h_gap : 0 < L.spectral_gap) (h_n : 2 ≤ n) :
    ajtai_security_param L = L.spectral_gap ^ (n / 2 : ℕ) ∧
    ajtai_security_param L ≥ L.spectral_gap ^ ((n - 1) / 2 : ℕ) := by
  -- Direct from definition and arithmetic on n/2 vs (n-1)/2.
  sorry
```

**Theorem 6: Tropical Lipschitz Bound on Embedding (ML Connection)**
```lean
/-- Bridge: connects tropical lattice embeddings to certified robustness.
The tropical embedding is Lipschitz with constant Δ, enabling certified
robustness guarantees for tropical key exchange protocols. -/
theorem tropical_embed_lipschitz_certified {n : ℕ} (L : TropicalLattice n) :
    ∃ (K : ℝ), K = L.spectral_gap ∧
    ∀ (e e' : Fin n → ℤ),
      dist (tropical_embed L e) (tropical_embed L e') ≤
        K * (∑ i : Fin n, |(e i : ℝ) - (e' i : ℝ)|) := by
  -- Uses tropicalLipschitz_composition from catalog.
  -- Each tropPow contributes factor ≤ spectral_gap by eigenvalue bound.
  -- Composition of n Lipschitz maps with constant Δ gives K = Δ.
  sorry
```

**Theorem 7: Stickel Key Agreement Security Parameter**
```lean
/-- Bridge: connects tropical key exchange to provable post-quantum security.
The Stickel bilateral key agreement has security parameter at least Δ^{n/2},
making it the first tropical cryptosystem with provable SVP-hardness. -/
theorem stickel_key_agreement_security {n : ℕ} (L : TropicalLattice n)
    (h_gap : 1 < L.spectral_gap) (h_n : 2 ≤ n) :
    ajtai_security_param L > 1 ∧
    ajtai_security_param L ≥ L.spectral_gap ^ ((n - 1) / 2 : ℕ) := by
  -- From Thm 5 and h_gap > 1, the security parameter exceeds 1.
  -- The bound Δ^{(n-1)/2} follows from integer arithmetic.
  sorry
```

**Theorem 8: Spectral Gap Preservation Under Tropical Powers**
```lean
/-- Bridge: connects tropical spectral theory to quantum energy gaps.
Tropical powers preserve and amplify the spectral gap, analogous to
quantum energy level separation under time evolution. -/
theorem tropPow_spectral_gap_amplification {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ)
    (h_comm : ∀ B, A ⊗ B = B ⊗ A) (k : ℕ) (hk : 1 ≤ k) (Δ : ℝ) (hΔ : 0 < Δ) :
    tropical_spectral_gap A = Δ →
    tropical_spectral_gap (tropPow A k) ≥ k * Δ := by
  -- Induction on k. Base: k=1 trivial.
  -- Step: tropPow A (k+1) = A ⊗ tropPow A k, and by commutativity + eigenvalue
  -- additivity in tropical semiring, eigenvalues multiply (add in log scale),
  -- so gaps multiply by k.
  sorry
```

**Theorem 9: Tropical Lattice Is Discrete**
```lean
/-- Bridge: connects tropical geometry to discrete lattice structures.
The image of the tropical embedding forms a discrete subset of the
matrix space, essential for the lattice analogy. -/
theorem tropical_lattice_discrete {n : ℕ} (L : TropicalLattice n)
    (h_gap : 0 < L.spectral_gap) :
    ∀ (M : Matrix (Fin n) (Fin n) ℝ), ∃ (ε : ℝ), 0 < ε ∧
    ∀ (e : Fin n → ℤ), dist (tropical_embed L e) M < ε →
      ∃ (e' : Fin n → ℤ), tropical_embed L e' = M := by
  -- By Thm 2, distinct lattice points are separated by ≥ Δ/n.
  -- Choose ε = Δ/(2n), then ball of radius ε contains at most one lattice point.
  sorry
```

**Theorem 10: Post-Quantum Security Level Classification**
```lean
/-- Bridge: connects tropical cryptography to NIST post-quantum standards.
Classifies tropical lattice cryptosystems by NIST security levels based
on the Ajtai parameter. Level 1 (128-bit) requires Δ^{n/2} ≥ 2^128. -/
theorem nist_security_level_classification {n : ℕ} (L : TropicalLattice n)
    (h_gap : 1 < L.spectral_gap) (h_n : 10 ≤ n) :
    (L.spectral_gap ^ (n / 2 : ℕ) ≥ 2 ^ 128 → ajtai_security_param L ≥ 2 ^ 128) ∧
    (L.spectral_gap ≥ 4 → ajtai_security_param L ≥ 2 ^ (2 * (n / 2 : ℕ))) := by
  -- Direct computation from definition and h_gap ≥ 4.
  sorry
```

**Theorem 11: Tropical Hash Collision Resistance**
```lean
/-- Bridge: connects tropical lattice embeddings to collision-resistant hashing.
The tropical embedding defines a collision-resistant hash function family
under SVP hardness, with collision probability bounded by the inverse
Ajtai parameter. -/
theorem tropical_hash_collision_resistance {n : ℕ} (L : TropicalLattice n)
    (h_gap : 1 < L.spectral_gap) (h_n : 2 ≤ n) :
    ∀ (e e' : Fin n → ℤ), e ≠ e' →
      tropical_embed L e = tropical_embed L e' →
      False := by
  -- Contradicts injectivity (Thm 1).
  sorry
```

**Theorem 12: Composition Bound for Multi-Key Recovery**
```lean
/-- Bridge: connects multi-party cryptography to Lipschitz certified robustness.
Recovering k exponent pairs simultaneously costs at least k · Δ^{n/2}
operations, establishing composition hardness. -/
theorem multi_key_recovery_composition_hardness {n k : ℕ} (L : TropicalLattice n)
    (h_gap : 1 < L.spectral_gap) (h_n : 2 ≤ n) (hk : 1 ≤ k) :
    ∀ (targets : Fin k → Matrix (Fin n) (Fin n) ℝ),
      (∀ i, ∃ (e : Fin n → ℤ), tropical_embed L e = targets i) →
      ajtai_security_param L ^ k ≤
        (ajtai_security_param L) * (k : ℝ) := by
  -- Each recovery independently costs ≥ Δ^{n/2} by Thm 5.
  -- Total cost is multiplicative in the number of targets.
  sorry
```

### III. PROOF STRATEGY ARCHITECTURE

**Path A (RECOMMENDED — Eigenvalue Separation):**
1. Prove that commuting max-plus matrices have simultaneously diagonalizable tropical eigenspaces (build on `tropPow_tropPow_comm_of_comm`)
2. Show that spectral gap Δ implies entry-wise separation Δ in the tropical eigenbasis
3. Derive the min-dist bound from eigenvalue separation via direct computation
4. Chain: min-dist bound → SVP equivalence → Ajtai hardness inheritance

**Path B (Lipschitz Composition):**
1. Use `tropicalLipschitz_composition` to bound the Lipschitz constant of the embedding
2. Show that the Lipschitz constant equals Δ by tightness
3. Derive min-dist from Lipschitz bound + injectivity
4. This path is cleaner but may give weaker constants (O(nΔ) vs Δ)

**Path C (Tropical Polynomial View):**
1. Interpret the embedding as a tropical polynomial evaluation map
2. Use `tropPolyEval_lipschitz_certified_robustness` for the polynomial bound
3. Connect tropical polynomial degree to lattice dimension
4. This path bridges to ML certified robustness most directly

### IV. SIGNIFICANCE AND FUTURE DIRECTIONS

This work establishes the **first provable security reduction** for any tropical cryptographic scheme, connecting Stickel-type key exchange to the well-studied SVP hardness assumption that underpins NIST post-quantum standards (Kyber, Dilithium). The tropical SVP reduction is novel because:

1. **Post-quantum relevance**: Tropical lattices inherit Ajtai's worst-case-to-average-case reduction, making them quantum-resistant
2. **Certified robustness bridge**: The Lipschitz bound (Thm 6) directly enables certified robustness for tropical neural network verification
3. **New lattice family**: Tropical lattices are a previously unstudied lattice family with natural algebraic structure (commutative semiring action)

**Aristotle: produce a FUTURE_DIRECTIONS.md containing:**
1. Extension to non-commutative tropical lattices via tropical Hecke operators
2. Tropical LWE (Learning With Errors) analogue with provable hardness
3. Certified robustness for tropical ReLU networks via tropical SVP bounds
4. Quantum Hamiltonian simulation using tropical spectral gaps (physics bridge)
5. NIST standardization pathway for tropical lattice-based signatures

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
            Prove the first formally verified computational lower bound for a tropical cryptographic primitive: for commuting n×n max-plus matrices A, B with spectral gap Δ > 0, recovering the exponent pair (a,b) from the mixed tropical power A^{⊗a} ⊗ B^{⊗b} requires Ω(Δ^{n/2}) operations under SVP hardness. The proof constructs a tropical lattice embedding φ: (a,b) ↦ A^{⊗a} ⊗ B^{⊗b}, establishes a minimum-distance lower bound d(φ(a,b), φ(a',b')) ≥ Δ·||(a,b)-(a',b')||_∞ for distinct exponent pairs, and reduces the recovery problem to the Shortest Vector Problem in the associated tropical lattice, inheriting Ajtai's Ω(n^{c·log n}) SVP hardness. This would make the Stickel-type tropical key exchange the first tropical cryptographic scheme with a provable security reduction, opening the field of provable tropical cryptography and enabling NIST post-quantum standardization discussions.

            ### Precise Mathematical Framing
            Let A, B ∈ M_n(ℝ_max) be commuting tropical matrices (A⊗B = B⊗A) with spectral gap Δ = min_{i≠j} |μ_i(A) - μ_j(A)| > 0 where μ_i are tropical eigenvalues. Define the tropical lattice L(A,B) = {A^{⊗a} ⊗ B^{⊗b} : (a,b) ∈ ℕ²}. THEOREM 1 (Injective Lattice Embedding): The map φ: ℕ² → L(A,B) defined by φ(a,b) = A^{⊗a} ⊗ B^{⊗b} is injective and satisfies d_trop(φ(a,b), φ(a',b')) ≥ Δ · max(|a-a'|, |b-b'|) for all distinct (a,b), (a',b') ∈ ℕ². THEOREM 2 (Recovery-SVP Reduction): The commutative matrix recovery problem CMR(A,B,M) — given M = A^{⊗a} ⊗ B^{⊗b}, find (a,b) — polynomially reduces to SVP in the rank-2 lattice Λ(A,B) = {(a,b) ∈ ℤ² : d_trop(M, φ(a,b)) < Δ/2}. THEOREM 3 (Hardness Lower Bound): Under the SVP hardness assumption (Ajtai 1996), any quantum algorithm for CMR requires Ω(2^{c·n}) operations for some constant c > 0, making tropical Stickel key exchange post-quantum secure.



            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `pair_margin_lower_bound_under_perturbation` : lemma pair_margin_lower_bound_under_perturbation
     (file: Bridges/GL3TopCycleRobustness.lean)
  2. `spectral_gap_lower_bound` : theorem spectral_gap_lower_bound (p : ℕ) (hp : Nat.Prime p) (hp2 : 2 < p) :
     (file: Computation/Factoring/FutureResearchTheorems.lean)
  3. `height_lower_bound_length` : theorem height_lower_bound_length (w : BWord) {t : Triple} (ht : GoodTriple t) :
     (file: Cryptography/BerggrenHeightDescent.lean)
  4. `height_lower_bound_length` : theorem height_lower_bound_length (w : BerggrenWord) {t : Triple} (ht : GoodTriple t) :
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



Recent successful concepts: Thermodynamic Sanov–Large-Deviation Completeness for Closure Self-Models via Prime-Spectral Free-Energy Rate Function, Max-Plus Hecke Algebras and Satake Isomorphism on Idempotent Prime Spectra, unnamed_concept


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
