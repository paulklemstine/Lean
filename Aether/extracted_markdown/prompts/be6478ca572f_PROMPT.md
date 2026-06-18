

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

## YOUR ASSIGNMENT: tropical_cryptography_breakthrough_bridge

**DOMAIN**: Cryptography × Tropical Algebra × Lattice Theory

**CONCEPT**: Tropical one-way functions and the min-plus discrete logarithm problem as a post-quantum cryptographic primitive. The core insight: while tropical matrix multiplication computes shortest paths in O(n³), the *inverse problem* — recovering the exponent n from a tropical matrix power A^n — requires searching a space of dimension growing as Ω(2^n), and this asymmetry yields a one-way function candidate resistant to Shor's algorithm because tropical semirings lack the additive group structure that quantum Fourier transforms exploit.

---

### PRECISE THEOREMS TO PROVE

**Theorem 1: Tropical Discrete Logarithm Search Space Lower Bound**
```
theorem tropical_discrete_log_search_space_expansion
    {n : ℕ} {d : ℕ} (A : Matrix (Fin d) (Fin d) ℝ)
    (hA : ∀ i j, 0 < A i j) (hk : 1 < d) :
    ∀ m : ℕ, ∃ S : Finset (Matrix (Fin d) (Fin d) ℝ),
      S.card = 2 ^ m ∧
      ∀ B ∈ S, ∃ k : ℕ, B = tropical_matrix_power A k ∧
      ¬∃ polynomial_time_algorithm : Type, RecoverExponent A B k
```
*Proof Strategy A (most promising):* Induction on `m`, using the tropical semiring identity `A^(k+1) = A ⊕ (A ⊗ A^k)` to show each power creates a new distinct matrix when `A` has strictly positive entries. The key lemma: tropical eigenvalue multiplicity is bounded by the dimension, so distinct exponents yield distinct matrices for a Zariski-dense set of inputs. Use `rcases` on the existential witness for each new matrix.

*Proof Strategy B:* Reduce from the subset-sum problem. Encode a subset S ⊆ {1,...,m} as a tropical matrix product ∏_{i∈S} A^{2^i}. Show this encoding is injective when A has algebraically independent entries over ℚ, giving 2^m distinct products.

*Proof Strategy C:* Use the connection to all-pairs shortest paths — each distinct exponent corresponds to a distinct path-length distribution, and the number of such distributions grows exponentially.

**Theorem 2: Tropical Hash Collision Resistance**
```
theorem tropical_hash_collision_resistance_bound
    {d : ℕ} {λ : ℝ} (hd : 2 ≤ d) (hλ : 0 < λ)
    (A : Matrix (Fin d) (Fin d) ℝ)
    (hA_lipschitz : ∀ x y, ‖tropical_mat_vec A x - tropical_mat_vec A y‖ ≤ λ * ‖x - y‖)
    (hA_injective : Function.Injective (tropical_mat_vec A)) :
    ∀ ε : ℝ, 0 < ε →
      ∃ N : ℕ, N = ⌈(d * Real.log (1/ε)) / Real.log (1 + 1/λ²)⌉₊ ∧
      ∀ m ≥ N,
        (tropical_hash A m).collision_probability ≤ ε
```
*Bridge: connects tropical algebra to certified robustness in ML via Lipschitz bounds.*

**Theorem 3: Tropical Key Exchange Quantum Resistance**
```
theorem tropical_diffie_hellman_quantum_resistance
    {d : ℕ} (hd : 3 ≤ d)
    (A : Matrix (Fin d) (Fin d) ℝ)
    (hA : is_tropical_generator A) :
    ¬∃ (q : QuantumCircuit d),
      q.gate_count ≤ d^3 ∧
      ∀ k : ℕ, k ≤ 2^d →
        q.run A (tropical_matrix_power A k) = k
```
*Bridge: connects tropical cryptography to quantum computing. Proof: tropical semiring (ℝ∪{∞}, min, +) has no additive inverses, so the quantum Fourier transform cannot be applied — the group-theoretic structure Shor's algorithm requires (a cyclic group ℤ/nℤ) is absent in the tropical setting.*

**Theorem 4: Min-Plus Inversion Hardness Reduction**
```
theorem tropical_inversion_lattice_reduction
    {d : ℕ} (hd : 2 ≤ d) :
    ∀ L : Lattice d,
      ∃ f : Lattice d → Matrix (Fin d) (Fin d) (WithTop ℝ),
      Function.Injective f ∧
      (∀ v ∈ L.shortest_vector_set, ‖f L‖ₜ ≥ ‖v‖ₜ) ∧
      (∃ B : Matrix (Fin d) (Fin d) (WithTop ℝ),
        tropical_det B ≠ ⊤ ∧
        tropical_inversion_time B ≥ shortest_vector_time L)
```
*Bridge: connects tropical algebra to lattice cryptography (SVP). Proof: embed lattice basis vectors as rows of a tropical matrix; tropical matrix inversion requires finding tropical eigenvectors, which reduces to finding short lattice vectors.*

**Theorem 5: Tropical Eigenvalue Lattice Embedding**
```
theorem tropical_eigenvalue_svp_equivalence
    {d : ℕ} (hd : 2 ≤ d)
    (A : Matrix (Fin d) (Fin d) ℝ)
    (hA : is_min_plus_irreducible A) :
    ∃ L : Lattice d,
      ∀ μ : ℝ, is_tropical_eigenvalue A μ →
        ∃ v : Fin d → ℝ, v ∈ L.basis ∧
        |μ - tropical_spectral_radius A| ≤ ‖v‖ / ‖v‖ₜ ∧
        shortest_vector_time L ≤ tropical_eigenvalue_time A
```

**Theorem 6: Certified Lipschitz Bound for Tropical Primitives**
```
theorem certified_tropical_lipschitz_robustness
    {d : ℕ} {R : Type*} [Semiring R] [LinearOrder R]
    (A : Matrix (Fin d) (Fin d) R)
    (hA : ∀ i j, (0 : R) < A i j) :
    ∃ L : ℝ, L = ∏ i : Fin d, ∑ j : Fin d, (A i j : ℝ) ∧
    ∀ x y : Fin d → R,
      ‖tropical_mat_vec A x - tropical_mat_vec A y‖ ≤ L * ‖x - y‖
```
*Bridge: connects tropical cryptography to certified robustness in neural networks. The Lipschitz constant L provides a certified radius for adversarial robustness of tropical-based classifiers.*

**Theorem 7: Tropical Semiring Has No Shor-Exploitable Structure**
```
theorem tropical_semiring_no_cyclic_additive_group
    {α : Type*} [LinearOrder α] [AddCommMonoid α] :
    ¬∃ (G : Type*) [CommGroup G], ∀ (x y : α),
      (x ⊕ y : Tropical α) = Tropical.of (x + y) →
      ∃ (g : G), Tropical.of (x + y) = g * Tropical.of x
```
*Proof: by_contra, then derive that a linear order with commutative group structure forces triviality. This is the key lemma explaining quantum resistance — Shor's algorithm needs a cyclic group, which cannot exist in the tropical semiring.*

**Theorem 8: Tropical Matrix Power Distinctness**
```
theorem tropical_matrix_power_distinctness
    {d : ℕ} (hd : 1 < d)
    {A : Matrix (Fin d) (Fin d) ℝ}
    (hA : ∀ i, A i i > 0)
    (hA_strict : ∀ i j, i ≠ j → A i j > A i i) :
    ∀ m n : ℕ, m ≠ n → tropical_matrix_power A m ≠ tropical_matrix_power A n
```
*Proof: induction on `m`, using the strict diagonal dominance condition to show each power strictly increases all off-diagonal entries in the tropical sense.*

**Theorem 9: Exponential Lower Bound for Tropical Inversion**
```
theorem tropical_inversion_exponential_lower_bound
    {d : ℕ} (hd : 2 ≤ d) :
    ∃ A : Matrix (Fin d) (Fin d) ℝ,
      is_tropical_generator A ∧
      ∀ (algo : TropicalInversionAlgorithm d),
        algo.query_count ≥ 2^(d - 1) ∨
        ∃ B, B = algo.run A ∧
        tropical_relative_error A B > 1/2
```
*Proof: Construct A from a binary encoding matrix. Any algorithm that inverts A in fewer than 2^(d-1) tropical queries must have >50% relative error. Uses an adversary argument.*

**Theorem 10: Tropical Cryptographic Security Parameter Extraction**
```
theorem tropical_security_parameter_from_dimension
    {d : ℕ} (hd : 3 ≤ d) :
    ∃ (sec : ℕ), sec = 2^d ∧
    ∀ (adv : TropicalAdversary d),
      adv.success_probability ≤ (1 : ℝ) / sec ∧
      adv.quantum_query_count ≥ sec / (d^2 : ℕ)
```

---

### DEFINITIONS TO INTRODUCE (5+)

1. **`TropicalOneWayFunction`**: Structure bundling a function `f`, a polynomial-time computability witness, and an exponential lower bound on inversion.
2. **`TropicalDiscreteLogProblem`**: The problem of recovering `n` from `A^n` in the tropical semiring, with explicit search space size.
3. **`TropicalHashFunction`**: A hash family based on tropical matrix products, with collision probability bounds.
4. **`PostQuantumSecurityLevel`**: A typeclass indexing security against quantum adversaries, parametrized by dimension and tropical spectral gap.
5. **`TropicalInversionAlgorithm`**: An oracle model for algorithms attempting tropical matrix inversion, with query complexity.
6. **`LatticeTropicalEmbedding`**: A structure witnessing the reduction from lattice SVP to tropical eigenvalue computation.
7. **`CertifiedTropicalRobustness`**: A structure bundling a Lipschitz constant with a certified radius, for use in adversarial ML.

---

### PROOF STRATEGY ARCHITECTURE

**Phase 1: Foundation (Theorems 7, 8)**
- Prove the structural no-go theorem: tropical semirings lack the cyclic group structure Shor's algorithm needs. This is the *fundamental reason* for post-quantum security.
- Prove tropical matrix power distinctness under strict diagonal dominance. This gives us injectivity of the one-way function.
- *Key tactics*: `by_contra`, `rcases`, `omega` for arithmetic bounds, custom `tropical_simp` tactic for min-plus algebra.

**Phase 2: Hardness (Theorems 1, 9)**
- Establish the exponential search space lower bound for tropical discrete log.
- Establish the exponential query lower bound for tropical inversion.
- *Key tactics*: `induction` on matrix dimension, adversary argument construction, `field_simp` for real arithmetic.

**Phase 3: Cryptographic Construction (Theorems 2, 3, 10)**
- Build the hash function and prove collision resistance.
- Formalize quantum resistance via the structural theorem from Phase 1.
- Extract concrete security parameters.
- *Key tactics*: `linarith` for probability bounds, `norm_num` for concrete computations.

**Phase 4: Cross-Domain Bridges (Theorems 4, 5, 6)**
- Reduce lattice SVP to tropical eigenvalue computation.
- Establish Lipschitz bounds connecting to certified robustness.
- *Key tactics*: `induction` with custom induction principle for lattice basis reduction.

---

### SIGNIFICANCE

This work establishes **tropical cryptography as a formally verified post-quantum primitive**. The key breakthrough is Theorem 7: the tropical semiring's lack of additive inverses *structurally prevents* Shor-type attacks, because quantum Fourier transforms require cyclic group structure. This is not a hardness assumption — it is a *mathematical impossibility theorem*.

The lattice reduction (Theorems 4-5) creates a two-way bridge: any attack on tropical cryptosystems yields a lattice SVP solver, and vice versa. This means tropical cryptography inherits the decades of confidence in lattice-based post-quantum security.

The Lipschitz bound (Theorem 6) bridges to certified adversarial robustness in ML: tropical neural networks have provable certified radii proportional to the tropical spectral gap.

---

### FUTURE_DIRECTIONS.md REQUIREMENT

Produce a structured `FUTURE_DIRECTIONS.md` with these concrete next steps:

1. **Tropical NTRU**: Formalize a tropical analogue of NTRU encryption, prove correctness and IND-CPA security under tropical discrete log hardness.

2. **Tropical Lattice-Based Signatures**: Construct a signature scheme from the tropical SVP equivalence (Theorem 5), prove existential unforgeability.

3. **Certified Adversarial Robustness via Tropical Networks**: Use Theorem 6's Lipschitz bound to construct tropical ReLU networks with provable certified radii against ℓ∞ adversarial attacks.

4. **Tropical Isogeny-Based Cryptography**: Explore whether tropical elliptic curves (tropicalizations of elliptic curves over p-adic fields) support SIDH-like key exchange, connecting to the catalog's p-adic valuation bounds.

5. **Quantum Query Lower Bounds for Tropical Problems**: Prove that any quantum algorithm solving tropical matrix inversion requires Ω(2^{d/2}) queries, using the polynomial method adapted to the tropical semiring.

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
            Visionary bridge between Tropical and Cryptography: Tropical one-way functions and min-plus cryptographic primitives. The hardness of tropical matrix inversion is a candidate computational assumption for post-quantum cryptography.

            ### Precise Mathematical Framing
            Establish a precise, provable connection between Tropical and Cryptography mathematics. Tropical one-way functions and min-plus cryptographic primitives. The hardness of tropical matrix inversion is a candidate computational assumption for post-quantum cryptography. Formalize the connection as a theorem with a specific, precise statement.



            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `universal_bridge_density_one` : theorem universal_bridge_density_one :
     (file: Cryptography/RosettaStone/MasterFormula.lean)
  2. `tropical_and_bound` : theorem tropical_and_bound (c₁ c₂ : ℝ) (h₁ : 1 ≤ c₁) (h₂ : 1 ≤ c₂) :
     (file: Computation/Oracles/OracleApplicationsFrontier.lean)
  3. `evalBergWord_eq_one_iff` : theorem evalBergWord_eq_one_iff {w : BergWord} : evalBergWord w = 1 ↔ w = [] :=
     (file: Cryptography/BerggrenAntiRigidity.lean)
  4. `one_mem_berggrenBall` : theorem one_mem_berggrenBall (R : ℕ) : (1 : Matrix (Fin 2) (Fin 2) ℤ) ∈ berggrenBall R := by
     (file: Cryptography/BerggrenBallRigidity.lean)
  5. `evalBergWord_eq_one_iff` : theorem evalBergWord_eq_one_iff {w : BergWord} : evalBergWord w = 1 ↔ w = [] :=
     (file: Cryptography/BerggrenFreeMonoid.lean)

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



Recent successful concepts: Provability Spectral Theory: Löb Fixed-Point Lattices, Modal Eigenvalue Decomposition, and Stone Duality for EML Closure Self-Models, Algebraic Learning Theory: Module-Theoretic VC Dimension, Spectral Rademacher Decomposition, and Certified Generalization over Algebraic Structures, Berggren Stabilizer Codes: Pythagorean Symplectic Lattices, Modular Tree Reductions, and Diophantine Quantum Error Correction


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
            @Algebra/Other/OctonionicTropicalApplications.lean
```lean
import Mathlib

/-! # CatalogBuild.Speculative.Other.OctonionicTropicalApplications

Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 15
-/

noncomputable section

/-- [Section: # CatalogBuild.Speculative.Other.OctonionicTropicalApplications
Auto-generated from theorem catalog database.
Declarations: 15] -/
def associator {α : Type*} [AddGroup α] (mul : α → α → α) (a b c : α) : α :=
  mul (mul a b) c - mul a (mul b c)

-- For real numbers (associative), the associator is zero

/-- [Section: # CatalogBuild.Speculative.Other.OctonionicTropicalApplications
Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 15] -/
theorem real_associator_zero (a b c : ℝ) :
    associator (· * ·) a b c = 0 := by
  simp [associator, mul_assoc]

-- Tropical max-plus is associative

theorem tropical_associator_zero (a b c : ℝ) :
    max (max a b) c = max a (max b c) :=
  max_assoc a b c

-- Error detection: nonzero associator means non-associative path

theorem error_detection_principle {α : Type*} [AddGroup α]
    (mul : α → α → α) (a b c : α)
    (h : associator mul a b c ≠ 0) :
    mul (mul a b) c ≠ mul a (mul b c) := by
  intro heq
  apply h
  simp [associator, heq]

def unitSphere (n : ℕ) : Set (Fin n → ℝ) :=
  {v | ∑ i, (v i) ^ 2 = 1}

-- The real Hopf map: (x, y) on S¹ ↦ x² - y²

def realHopfMap (v : Fin 2 → ℝ) : ℝ := (v 0) ^ 2 - (v 1) ^ 2

-- The Hopf map sends S¹ to [-1, 1]

theorem hopf_bounded (v : Fin 2 → ℝ) (hv : v ∈ unitSphere 2) :
    |realHopfMap v| ≤ 1 := by
  have h1 : (v 0) ^ 2 + (v 1) ^ 2 = 1 := by
    have := hv; simp [unitSphere, Fin.sum_univ_two] at this; exact this
  rw [realHopfMap, abs_le]
  constructor <;> nlinarith [sq_nonneg (v 0), sq_nonneg (v 1)]

-- The Hopf map is not constant on S¹

theorem hopf_nonconstant :
    ∃ v w : Fin 2 → ℝ, v ∈ unitSphere 2 ∧ w ∈ unitSphere 2 ∧
    realHopfMap v ≠ realHopfMap w := by
  refine ⟨![1, 0], ![0, 1], ?_, ?_, ?_⟩
  · simp [unitSphere, Fin.sum_univ_two, Matrix.cons_val_zero, Matrix.cons_val_one]
  · simp [unitSphere, Fin.sum_univ_two, Matrix.cons_val_zero, Matrix.cons_val_one]
  · simp [realHopfMap, Matrix.cons_val_zero, Matrix.cons_val_one]
    norm_num

theorem fano_line_count : fanoLines.length = 7 := by native_decide

-- Each point appears in exactly 3 lines

theorem fano_regularity_0 :
    (fanoLines.filter (fun t => t.1 = 0 ∨ t.2.1 = 0 ∨ t.2.2 = 0)).length = 3 := by
  native_decide

-- Fano plane diameter is at most 2

theorem fano_diameter_le_2 :
    ∀ (p q : Fin 7), p ≠ q →
    ∃ r : Fin 7, ∃ L₁ ∈ fanoLines, ∃ L₂ ∈ fanoLines,
      (L₁.1 = p ∨ L₁.2.1 = p ∨ L₁.2.2 = p) ∧
      (L₁.1 = r ∨ L₁.2.1 = r ∨ L₁.2.2 = r) ∧
      (L₂.1 = q ∨ L₂.2.1 = q ∨ L₂.2.2 = q) ∧
      (L₂.1 = r ∨ L₂.2.1 = r ∨ L₂.2.2 = r) := by
  native_decide

theorem triality_triple_gap (g₁ g₂ g₃ : ℝ) (h₁ : g₁ = 1) (h₂ : g₂ = 1) (h₃ : g₃ = 1) :
    g₁ + g₂ + g₃ = 3 := by linarith

theorem tropical_moufang (a b c : ℝ) :
    max (max a b) (max c a) = max a (max (max b c) a) := by
  simp [max_comm, max_left_comm]

-- One-way function: max preimage is not unique

theorem max_preimage_nonunique (c : ℝ) :
    ∃ a b a' b' : ℝ, max a b = c ∧ max a' b' = c ∧ (a ≠ a' ∨ b ≠ b') := by
  refine ⟨c, c - 1, c - 1, c, ?_, ?_, ?_⟩
  · exact max_eq_left (by linarith)
  · exact max_eq_right (by linarith)
  · left; linarith

-- Catalan number C₃ = 5 (number of bracketings of 4 elements)

theorem five_applications_summary :
    -- 1. Error correction: associator detects errors in non-associative algebras
    (∀ a b c : ℝ, max (max a b) c = max a (max b c)) ∧
    -- 2. Hopf fibration: dimension reduction preserves structure
    (∀ v : Fin 2 → ℝ, v ∈ OctonionicHopf.unitSphere 2 →
      |OctonionicHopf.realHopfMap v| ≤ 1) ∧
    -- 3. Fano routing: 7 lines
    (TropicalFanoRouting.fanoLines.length = 7) ∧
    -- 4. Spectral gap: projection eigenvalues are 0 or 1
    ((1 : ℝ) - 0 = 1) ∧
    -- 5. Moufang crypto: max preimage is non-unique
    (∀ c : ℝ, ∃ a b a' b' : ℝ, max a b = c ∧ max a' b' = c ∧ (a ≠ a' ∨ b ≠ b')) :=
  ⟨fun a b c => max_assoc a b c,
   fun v hv => OctonionicHopf.hopf_bounded v hv,
   TropicalFanoRouting.fano_line_count,
   by norm_num,
   TropicalMoufangCrypto.max_preimage_nonunique⟩

end
```

@Algebra/Tropical_p_adic_Valuation_Bounds_and_Lifting_the_Exponent_for_Fibonacci_Primitive_Divisors.lean
```lean
/-
# Fibonacci Primitive Divisors and Lifting-the-Exponent

This file formalizes key results about primitive prime divisors of Fibonacci numbers,
including:
- The Fibonacci entry point (rank of apparition) z(p)
- The characterization: p | F_n ↔ z(p) | n
- Growth bounds for Fibonacci numbers
- The Lifting-the-Exponent (LTE) framework for Fibonacci sequences
- Carmichael's theorem: F_n has a primitive prime divisor for n ∉ {1, 2, 6, 12}

## References
- Carmichael, R.D. "On the numerical factors of the arithmetic forms αⁿ ± βⁿ" (1913)
- Yabuta, M. "A simple proof of Carmichael's theorem on primitive divisors" (2001)
-/

import Mathlib

open scoped BigOperators Nat
open Nat

set_option maxHeartbeats 8000000
set_option maxRecDepth 4000

/-! ## Section 1: Basic Fibonacci Properties -/

/-
Fibonacci numbers are strictly monotone for indices ≥ 2.
-/
theorem fib_strict_mono_of_ge_two {m n : ℕ} (hm : 2 ≤ m) (hmn : m < n) :
    Nat.fib m < Nat.fib n := by
  exact?

/-
F_n ≥ n for n ≥ 5.
-/
theorem fib_ge_index (n : ℕ) (hn : 5 ≤ n) : n ≤ Nat.fib n := by
  -- We can prove this by induction on $n$.
  induction' n using Nat.strong_induction_on with n ih;
  rcases hn with ( _ | _ | _ | _ | _ | n ) <;> simp +arith +decide [ Nat.fib_add_two ] at *;
  grind

/-- F_n > 0 for n > 0. -/
theorem fib_pos_of_pos {n : ℕ} (hn : 0 < n) : 0 < Nat.fib n :=
  Nat.fib_pos.mpr hn

/-! ## Section 2: The Fibonacci Entry Point (Rank of Apparition)

For a prime p, the entry point z(p) is the smallest positive integer k
such that p | F_k. This exists because p | F_{p - (p/5)} by quadratic
reciprocity properties of Fibonacci numbers.
-/

open Classical in
/-- The Fibonacci entry point: the smallest positive k such that p | F_k.
    Returns 0 if no such k exists (which doesn't happen for primes ≥ 2). -/
noncomputable def fibEntryPoint (p : ℕ) : ℕ :=
  if h : ∃ k : ℕ, 0 < k ∧ p ∣ Nat.fib k then
    Nat.find h
  else
    0

/-
If the entry point is positive, then p divides F_{z(p)}.
-/
theorem fib_entry_point_dvd (p : ℕ) (h : ∃ k : ℕ, 0 < k ∧ p ∣ Nat.fib k) :
    p ∣ Nat.fib (fibEntryPoint p) := by
  unfold fibEntryPoint;
  split_ifs ; exact Nat.find_spec h |>.2

/-
The entry point is positive when a divisibility witness exists.
-/
theorem fib_entry_point_pos (p : ℕ) (h : ∃ k : ℕ, 0 < k ∧ p ∣ Nat.fib k) :
    0 < fibEntryPoint p := by
  unfold fibEntryPoint; aesop;

/-
The entry point is minimal: if p | F_k and k > 0, then z(p) ≤ k.
-/
theorem fib_entry_point_le (p k : ℕ) (hk : 0 < k) (hpk : p ∣ Nat.fib k)
    (h : ∃ k : ℕ, 0 < k ∧ p ∣ Nat.fib k) :
    fibEntryPoint p ≤ k := by
  unfold fibEntryPoint;
  split_ifs ; aesop

/-! ## Section 3: Entry Point Divides Index

The key characterization: p | F_n if and only if z(p) | n.
This follows from the strong divisibility property gcd(F_m, F_n) = F_{gcd(m,n)}.
-/

/-
**Entry point divisibility**: For a prime p with p | F_m for some m > 0,
    we have p | F_n ↔ z(p) | n (assuming n > 0).
-/
theorem fib_dvd_iff_entry_dvd (p n : ℕ) (hp : Nat.Prime p) (hn : 0 < n)
    (hex : ∃ k : ℕ, 0 < k ∧ p ∣ Nat.fib k) :
    p ∣ Nat.fib n ↔ fibEntryPoint p ∣ n := by
  -- By definition of z(p), we know that p | F_{z(p)} and z(p) is the smallest such positive integer.
  have hz : p ∣ Nat.fib (fibEntryPoint p) ∧ ∀ k : ℕ, 0 < k → p ∣ Nat.fib k → fibEntryPoint p ≤ k := by
    exact ⟨ fib_entry_point_dvd p hex, fun k hk hk' => fib_entry_point_le p k hk hk' hex ⟩;
  have h_div : ∀ k : ℕ, 0 < k → p ∣ Nat.fib k → fibEntryPoint p ∣ k := by
    intros k hk_pos hk_div
    have h_gcd : Nat.gcd (fibEntryPoint p) k = fibEntryPoint p := by
      refine' Nat.le_antisymm _ _;
      · exact Nat.le_of_dvd ( fib_entry_point_pos p hex ) ( Nat.gcd_dvd_left _ _ );
      · refine' hz.2 _ ( Nat.gcd_pos_of_pos_right _ hk_pos ) _;
        have h_gcd : Nat.gcd (Nat.fib (fibEntryPoint p)) (Nat.fib k) = Nat.fib (Nat.gcd (fibEntryPoint p) k) := by
          exact?;
        exact h_gcd ▸ Nat.dvd_gcd hz.1 hk_div;
    exact h_gcd ▸ Nat.gcd_dvd_right _ _;
  exact ⟨ h_div n hn, fun h => dvd_trans hz.1 ( Nat.fib_dvd _ _ h ) ⟩

/-! ## Section 4: Primitive Prime Divisors -/

/-- A prime p is a **primitive prime divisor** of F_n if p | F_n and
    p does not divide F_k for any 0 < k < n. Equivalently, z(p) = n. -/
def IsPrimitivePrimeDivisor (p n : ℕ) : Prop :=
  Nat.Prime p ∧ p ∣ Nat.fib n ∧ ∀ k : ℕ, 0 < k → k < n → ¬(p ∣ Nat.fib k)

/-- F_n **has a primitive prime divisor** if there exists a prime p with z(p) = n. -/
def HasPrimitivePrimeDivisor (n : ℕ) : Prop :=
  ∃ p : ℕ, IsPrimitivePrimeDivisor p n

/-
A prime is a primitive divisor of F_n iff its entry point equals n.
-/
theorem isPrimitivePrimeDivisor_iff_entry_eq (p n : ℕ) (hp : Nat.Prime p) (hn : 0 < n)
    (hex : ∃ k : ℕ, 0 < k ∧ p ∣ Nat.fib k) :
    IsPrimitivePrimeDivisor p n ↔ (p ∣ Nat.fib n ∧ fibEntryPoint p = n) := by
  constructor <;> intro h;
  · exact ⟨ h.2.1, le_antisymm ( fib_entry_point_le p n hn h.2.1 hex ) ( Nat.le_of_not_gt fun hlt => h.2.2 _ ( fib_entry_point_pos p hex ) hlt ( fib_entry_point_dvd p hex ) ) ⟩;
  · exact ⟨ hp, h.1, fun k hk₁ hk₂ hk₃ => by have := fib_entry_point_le p k hk₁ hk₃ hex; linarith ⟩

/-! ## Section 5: Growth Bounds for Fibonacci Numbers

These bounds are essential for proving that F_n has prime factors beyond
those of F_d for proper divisors d of n.
-/

/-
Exponential lower bound: F_n ≥ 2^((n-2)/2) for n ≥ 2.
-/
theorem fib_exponential_lower_bound (n : ℕ) (hn : 2 ≤ n) :
    2 ^ ((n - 2) / 2) ≤ Nat.fib n := by
  rcases Nat.even_or_odd' n with ⟨ k, rfl | rfl ⟩;
  · induction' k with k ih <;> norm_num [ Nat.fib_add_two, Nat.mul_succ ] at *;
    rcases k with ( _ | _ | k ) <;> simp_all +arith +decide [ Nat.fib_add_two, Nat.mul_succ ];
    grind;
-- ... (truncated, full file has 493 lines)
```

@AutoResearch/CompactTropicalChoquetRadon.lean
```lean
/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Compact Tropical Choquet–Radon Representation

This file formalizes a Choquet–Radon representation theorem for upper-continuous
max-plus linear functionals on continuous real-valued functions over a compact
Hausdorff space.

## Main definitions

* `UCTropicalFunctional` — A structure encoding an upper-continuous, max-plus linear
  functional on `C(X, ℝ)` with values in `EReal`.
* `compactCapacity` — The compact-set capacity extracted from a functional.
* `infOnCompact` — The infimum of a continuous function on a compact set.
* `tropSupport` — The support of a tropical functional (smallest closed carrier).
* `supportedOn` — Predicate for a functional being supported on a set.
* `pushforwardFunctional` — Pushforward of a tropical functional along a continuous map.

## Main results

* `compactCapacity_empty` — Capacity of the empty compact set is ⊥.
* `compactCapacity_mono` — Capacity is monotone (larger sets, larger capacity).
* `compactCapacity_union` — Capacity is maxitive: `μ(K ∪ L) = max(μ(K), μ(L))`.
* `infOnCompact_le_eval` — The infimum on a compact set is bounded by point evaluation.
* `tropical_choquet_radon_le` — One direction of the representation:
    `⊔_K (μ(K) + inf_K f) ≤ Λ(f)`.
* `isClosed_tropSupport` — The tropical support is closed.
* `tropSupport_supported` — The functional is supported on its tropical support.
* `tropSupport_minimal` — The tropical support is the smallest closed carrier.
* `compactCapacity_pushforward_le` — Capacity is functorial under pushforward.

## Mathematical overview

In max-plus (tropical) algebra, addition is `max` and multiplication is `+`.
A max-plus linear functional Λ on continuous functions satisfies:
- `Λ(f ⊔ g) = Λ(f) ⊔ Λ(g)` (preserves tropical addition = max)
- `Λ(f + c) = Λ(f) + c` (equivariant under tropical scalar action = real translation)

The Choquet–Radon representation expresses such a functional as a "max-plus integral":
  `Λ(f) = ⊔_K (μ(K) + inf_K f)`
where `μ` is a maxitive capacity on compact sets.
-/

noncomputable section

open TopologicalSpace Set EReal

/-! ### The functional structure -/

/-- An upper-continuous tropical (max-plus linear) functional on `C(X, ℝ)`,
taking values in `EReal` (extended reals with ±∞).

The axioms encode:
- `monotone'`: monotonicity with respect to pointwise order
- `sup_preserving'`: max-plus additivity `Λ(f ⊔ g) = max(Λ(f), Λ(g))`
- `shift_equivariant'`: tropical scalar action `Λ(f + c) = Λ(f) + c`
- `normalized'`: normalization `Λ(0) = 0`

The upper-continuity axiom (`top_continuous'`) states that Λ commutes with
directed suprema of continuous functions, provided the supremum is itself continuous.
-/
structure UCTropicalFunctional (X : Type*) [TopologicalSpace X]
    [CompactSpace X] [T2Space X] where
  /-- The underlying function from continuous maps to extended reals. -/
  toFun : C(X, ℝ) → EReal
  /-- The functional is monotone. -/
  monotone' : Monotone toFun
  /-- The functional preserves binary suprema (max-plus additivity). -/
  sup_preserving' : ∀ f g : C(X, ℝ), toFun (f ⊔ g) = toFun f ⊔ toFun g
  /-- The functional is equivariant under translation by real constants. -/
  shift_equivariant' : ∀ (c : ℝ) (f : C(X, ℝ)),
    toFun (f + ContinuousMap.const X c) = toFun f + (c : EReal)
  /-- Upper continuity: Λ commutes with monotone suprema of continuous functions,
      provided the supremum is itself continuous. -/
  top_continuous' : ∀ {ι : Type*} [Nonempty ι] [Preorder ι] (s : ι → C(X, ℝ))
    (f : C(X, ℝ)),
    (∀ x, f x = ⨆ i, (s i x : EReal)) →
    Monotone s →
    toFun f = ⨆ i, toFun (s i)
  /-- Normalization: the zero function maps to zero. -/
  normalized' : toFun 0 = 0

variable {X : Type*} [TopologicalSpace X] [CompactSpace X] [T2Space X]

namespace UCTropicalFunctional

instance : CoeFun (UCTropicalFunctional X) (fun _ => C(X, ℝ) → EReal) :=
  ⟨toFun⟩

@[simp]
theorem coe_toFun (Λ : UCTropicalFunctional X) (f : C(X, ℝ)) :
    Λ f = Λ.toFun f := rfl

theorem monotone (Λ : UCTropicalFunctional X) : Monotone Λ.toFun :=
  Λ.monotone'

theorem sup_preserving (Λ : UCTropicalFunctional X) (f g : C(X, ℝ)) :
    Λ (f ⊔ g) = Λ f ⊔ Λ g :=
  Λ.sup_preserving' f g

theorem shift_equivariant (Λ : UCTropicalFunctional X) (c : ℝ) (f : C(X, ℝ)) :
    Λ (f + ContinuousMap.const X c) = Λ f + (c : EReal) :=
  Λ.shift_equivariant' c f

theorem normalized (Λ : UCTropicalFunctional X) :
    Λ 0 = 0 := Λ.normalized'

/-- The functional maps constant functions to the constant. -/
theorem map_const (Λ : UCTropicalFunctional X) (c : ℝ) :
    Λ (ContinuousMap.const X c) = (c : EReal) := by
  have h := Λ.shift_equivariant c 0
  simp [Λ.normalized] at h
  exact h

/-- As constants decrease to -∞, the functional value goes to ⊥. -/
theorem map_const_neg_iInf (Λ : UCTropicalFunctional X) :
    ⨅ (n : ℕ), Λ (ContinuousMap.const X (-(n : ℝ))) = ⊥ := by
  simp [map_const]
  rw [iInf_eq_bot]
  intro b hb
  induction b with
    | bot => exact absurd rfl (ne_of_gt hb)
    | top => exact ⟨0, by simp⟩
    | coe r =>
      obtain ⟨n, hn⟩ := exists_nat_gt (-r)
      exact ⟨n, EReal.coe_lt_coe_iff.mpr (by linarith)⟩

end UCTropicalFunctional

/-! ### Compact-set capacity -/

/-- The compact-set capacity extracted from a tropical functional.
    `compactCapacity Λ K` is the infimum of `Λ(f)` over all continuous functions `f`
    that are nonneg (≥ 0) on `K`. -/
def compactCapacity (Λ : UCTropicalFunctional X) (K : Compacts X) : EReal :=
  sInf {a : EReal | ∃ f : C(X, ℝ), (∀ x ∈ (K : Set X), (0 : ℝ) ≤ f x) ∧ a = Λ.toFun f}

/-- The infimum of a continuous function over a compact set.
    When `K` is empty, this is `⊤` by convention (infimum of empty set). -/
def infOnCompact (f : C(X, ℝ)) (K : Compacts X) : EReal :=
  ⨅ x ∈ (K : Set X), (f x : EReal)

/-! ### Basic capacity properties -/

/-- Helper: the defining set for compactCapacity is nonempty. -/
-- ... (truncated, full file has 459 lines)
```

@Cryptography/BerggrenAntiRigidity.lean
```lean
import Mathlib

/-!
# Berggren Semigroup: Anti-Involution Rigidity

We prove that the Berggren free semigroup inside GL₂(ℤ) is **completely disjoint from its
image under the adjugate anti-involution**, except at the identity. The adjugate of a 2×2
matrix M = !![a,b;c,d] is adj(M) = !![d,-b;-c,a], satisfying M * adj(M) = det(M) • I.
For invertible matrices (det = ±1), this equals ±M⁻¹, making it the natural matrix-level
"inverse" anti-involution.

## Main Results

* `evalBergWord_entry_00_pos` — top-left entry is always ≥ 1
* `evalBergWord_entry_10_nonneg` — bottom-left entry is always ≥ 0
* `evalBergWord_entry_00_ge_10` — top-left ≥ bottom-left (diagonal dominance)
* `adjugate2_anti_hom` — adjugate reverses multiplication
* `adjugate2_not_in_BergSemigroup` — **main theorem**: adjugate is never in the semigroup
* `berggren_inverse_rigidity` — no non-identity semigroup element has its inverse in the semigroup

## Mathematical Significance

This result upgrades the Berggren free-monoid injectivity theorem to a much stronger
structural statement: the semigroup occupies an "orientation-rigid" region of GL₂(ℤ) that
is completely separated from its image under the adjugate/inverse anti-involution. In
cryptographic applications, this means that reversing a Berggren-encoded transcript (taking
adjoints/inverses) can never accidentally produce a valid semigroup element, providing
anti-automorphism resistance for protocol canonicalization.

## References

The Berggren generators arise from the classical tree of primitive Pythagorean triples,
lifted to 2×2 integer matrices via the spin covering SL₂ → SO₂₁.
-/

set_option linter.unusedVariables false

/-! ## Generator Type and Word Evaluation -/

/-- The three Berggren generators. -/
inductive BergGen : Type
  | A | B | C
  deriving DecidableEq, Repr

/-- A Berggren word is a list of generators. -/
abbrev BergWord := List BergGen

/-- Action of each generator on the pair space (m, n). -/
def actGen (g : BergGen) (p : ℤ × ℤ) : ℤ × ℤ :=
  match g with
  | .A => (2 * p.1 - p.2, p.1)
  | .B => (2 * p.1 + p.2, p.1)
  | .C => (p.1 + 2 * p.2, p.2)

/-- The root pair (2, 1), corresponding to the identity matrix. -/
def rootPair : ℤ × ℤ := (2, 1)

/-- Pair-based evaluation of a Berggren word. -/
def evalPair : BergWord → ℤ × ℤ
  | [] => rootPair
  | g :: rest => actGen g (evalPair rest)

/-- A valid pair satisfies 0 < n < m. -/
def ValidPair (p : ℤ × ℤ) : Prop := 0 < p.2 ∧ p.2 < p.1

theorem rootPair_valid : ValidPair rootPair := ⟨by norm_num [rootPair], by norm_num [rootPair]⟩

theorem actGen_preserves_valid (g : BergGen) {p : ℤ × ℤ} (hp : ValidPair p) :
    ValidPair (actGen g p) := by
  obtain ⟨hn, hmn⟩ := hp
  cases g <;> constructor <;> simp only [actGen] <;> linarith

theorem evalPair_valid (w : BergWord) : ValidPair (evalPair w) := by
  induction w with
  | nil => exact rootPair_valid
  | cons g rest ih => exact actGen_preserves_valid g ih

theorem m_ge_three_after_gen (g : BergGen) {p : ℤ × ℤ} (hp : ValidPair p) :
    3 ≤ (actGen g p).1 := by
  obtain ⟨hn, hmn⟩ := hp; cases g <;> simp only [actGen] <;> linarith

theorem actGen_ne_root (g : BergGen) {p : ℤ × ℤ} (hp : ValidPair p) :
    actGen g p ≠ rootPair := by
  intro h; linarith [m_ge_three_after_gen g hp, show (actGen g p).1 = 2 from congr_arg Prod.fst h]

theorem actGen_injective (g : BergGen) : Function.Injective (actGen g) := by
  intro ⟨m₁, n₁⟩ ⟨m₂, n₂⟩ h
  cases g <;> simp only [actGen, Prod.mk.injEq] at h <;>
    exact Prod.ext (by linarith [h.1, h.2]) (by linarith [h.1, h.2])

theorem actGen_generator_determined {g₁ g₂ : BergGen} {p₁ p₂ : ℤ × ℤ}
    (hp₁ : ValidPair p₁) (hp₂ : ValidPair p₂)
    (h : actGen g₁ p₁ = actGen g₂ p₂) : g₁ = g₂ := by
  obtain ⟨hn₁, hmn₁⟩ := hp₁; obtain ⟨hn₂, hmn₂⟩ := hp₂
  have hf := congr_arg Prod.fst h; have hs := congr_arg Prod.snd h
  rcases g₁ with _ | _ | _ <;> rcases g₂ with _ | _ | _ <;>
    simp only [actGen] at hf hs <;> (first | rfl | linarith)

theorem actGen_unique_parent {g₁ g₂ : BergGen} {p₁ p₂ : ℤ × ℤ}
    (hp₁ : ValidPair p₁) (hp₂ : ValidPair p₂)
    (h : actGen g₁ p₁ = actGen g₂ p₂) : g₁ = g₂ ∧ p₁ = p₂ :=
  ⟨actGen_generator_determined hp₁ hp₂ h,
   actGen_injective g₁ (actGen_generator_determined hp₁ hp₂ h ▸ h)⟩

/-- **Freeness via pairs**: the pair evaluation is injective. -/
theorem evalPair_injective : Function.Injective evalPair := by
  intro w₁
  induction w₁ with
  | nil =>
    intro w₂ h; match w₂ with
    | [] => rfl
    | g :: rest => exact absurd h.symm (actGen_ne_root g (evalPair_valid rest))
  | cons g₁ rest₁ ih =>
    intro w₂ h; match w₂ with
    | [] => exact absurd h (actGen_ne_root g₁ (evalPair_valid rest₁))
    | g₂ :: rest₂ =>
      have ⟨hg, hp⟩ := actGen_unique_parent (evalPair_valid rest₁) (evalPair_valid rest₂) h
      subst hg; exact congrArg (g₁ :: ·) (ih hp)

/-! ## Matrix Formulation -/

/-- The 2×2 matrix for each Berggren generator. -/
def bergMat : BergGen → Matrix (Fin 2) (Fin 2) ℤ
  | .A => !![2, -1; 1, 0]
  | .B => !![2, 1; 1, 0]
  | .C => !![1, 2; 0, 1]

/-- Matrix evaluation of a Berggren word (left-multiplication). -/
def evalBergWord : BergWord → Matrix (Fin 2) (Fin 2) ℤ
  | [] => 1
  | g :: rest => bergMat g * evalBergWord rest

@[simp] theorem evalBergWord_nil : evalBergWord [] = 1 := rfl
@[simp] theorem evalBergWord_cons (g : BergGen) (w : BergWord) :
    evalBergWord (g :: w) = bergMat g * evalBergWord w := rfl

theorem evalBergWord_append (u v : BergWord) :
    evalBergWord (u ++ v) = evalBergWord u * evalBergWord v := by
  induction u with
  | nil => simp
  | cons g rest ih => simp [ih, Matrix.mul_assoc]

/-- Extract the pair invariant from a 2×2 matrix. -/
def pairOfMat (M : Matrix (Fin 2) (Fin 2) ℤ) : ℤ × ℤ :=
  (2 * M 0 0 + M 0 1, 2 * M 1 0 + M 1 1)

theorem pairOfMat_evalBergWord (w : BergWord) :
    pairOfMat (evalBergWord w) = evalPair w := by
  induction w with
  | nil => simp [pairOfMat, evalBergWord, evalPair, rootPair]
-- ... (truncated, full file has 404 lines)
```

@Cryptography/BerggrenBallRigidity.lean
```lean
import Mathlib

/-!
# Finite-Ball Rigidity and Generic-Group Lower-Bound Transfer for the Berggren Embedding

This file establishes finite-ball injectivity theorems for quotients of Berggren semigroup
elements in `SL₂(ℤ)`, and derives algebraic consequences for generic-group style
discrete-log attacks on reduced Berggren images.

## Main results


### Catalog Reference Files
            @Algebra/Other/OctonionicTropicalApplications.lean
```lean
import Mathlib

/-! # CatalogBuild.Speculative.Other.OctonionicTropicalApplications

Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 15
-/

noncomputable section

/-- [Section: # CatalogBuild.Speculative.Other.OctonionicTropicalApplications
Auto-generated from theorem catalog database.
Declarations: 15] -/
def associator {α : Type*} [AddGroup α] (mul : α → α → α) (a b c : α) : α :=
  mul (mul a b) c - mul a (mul b c)

-- For real numbers (associative), the associator is zero

/-- [Section: # CatalogBuild.Speculative.Other.OctonionicTropicalApplications
Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 15] -/
theorem real_associator_zero (a b c : ℝ) :
    associator (· * ·) a b c = 0 := by
  simp [associator, mul_assoc]

-- Tropical max-plus is associative

theorem tropical_associator_zero (a b c : ℝ) :
    max (max a b) c = max a (max b c) :=
  max_assoc a b c

-- Error detection: nonzero associator means non-associative path

theorem error_detection_principle {α : Type*} [AddGroup α]
    (mul : α → α → α) (a b c : α)
    (h : associator mul a b c ≠ 0) :
    mul (mul a b) c ≠ mul a (mul b c) := by
  intro heq
  apply h
  simp [associator, heq]

def unitSphere (n : ℕ) : Set (Fin n → ℝ) :=
  {v | ∑ i, (v i) ^ 2 = 1}

-- The real Hopf map: (x, y) on S¹ ↦ x² - y²

def realHopfMap (v : Fin 2 → ℝ) : ℝ := (v 0) ^ 2 - (v 1) ^ 2

-- The Hopf map sends S¹ to [-1, 1]

theorem hopf_bounded (v : Fin 2 → ℝ) (hv : v ∈ unitSphere 2) :
    |realHopfMap v| ≤ 1 := by
  have h1 : (v 0) ^ 2 + (v 1) ^ 2 = 1 := by
    have := hv; simp [unitSphere, Fin.sum_univ_two] at this; exact this
  rw [realHopfMap, abs_le]
  constructor <;> nlinarith [sq_nonneg (v 0), sq_nonneg (v 1)]

-- The Hopf map is not constant on S¹

theorem hopf_nonconstant :
    ∃ v w : Fin 2 → ℝ, v ∈ unitSphere 2 ∧ w ∈ unitSphere 2 ∧
    realHopfMap v ≠ realHopfMap w := by
  refine ⟨![1, 0], ![0, 1], ?_, ?_, ?_⟩
  · simp [unitSphere, Fin.sum_univ_two, Matrix.cons_val_zero, Matrix.cons_val_one]
  · simp [unitSphere, Fin.sum_univ_two, Matrix.cons_val_zero, Matrix.cons_val_one]
  · simp [realHopfMap, Matrix.cons_val_zero, Matrix.cons_val_one]
    norm_num

theorem fano_line_count : fanoLines.length = 7 := by native_decide

-- Each point appears in exactly 3 lines

theorem fano_regularity_0 :
    (fanoLines.filter (fun t => t.1 = 0 ∨ t.2.1 = 0 ∨ t.2.2 = 0)).length = 3 := by
  native_decide

-- Fano plane diameter is at most 2

theorem fano_diameter_le_2 :
    ∀ (p q : Fin 7), p ≠ q →
    ∃ r : Fin 7, ∃ L₁ ∈ fanoLines, ∃ L₂ ∈ fanoLines,
      (L₁.1 = p ∨ L₁.2.1 = p ∨ L₁.2.2 = p) ∧
      (L₁.1 = r ∨ L₁.2.1 = r ∨ L₁.2.2 = r) ∧
      (L₂.1 = q ∨ L₂.2.1 = q ∨ L₂.2.2 = q) ∧
      (L₂.1 = r ∨ L₂.2.1 = r ∨ L₂.2.2 = r) := by
  native_decide

theorem triality_triple_gap (g₁ g₂ g₃ : ℝ) (h₁ : g₁ = 1) (h₂ : g₂ = 1) (h₃ : g₃ = 1) :
    g₁ + g₂ + g₃ = 3 := by linarith

theorem tropical_moufang (a b c : ℝ) :
    max (max a b) (max c a) = max a (max (max b c) a) := by
  simp [max_comm, max_left_comm]

-- One-way function: max preimage is not unique

theorem max_preimage_nonunique (c : ℝ) :
    ∃ a b a' b' : ℝ, max a b = c ∧ max a' b' = c ∧ (a ≠ a' ∨ b ≠ b') := by
  refine ⟨c, c - 1, c - 1, c, ?_, ?_, ?_⟩
  · exact max_eq_left (by linarith)
  · exact max_eq_right (by linarith)
  · left; linarith

-- Catalan number C₃ = 5 (number of bracketings of 4 elements)

theorem five_applications_summary :
    -- 1. Error correction: associator detects errors in non-associative algebras
    (∀ a b c : ℝ, max (max a b) c = max a (max b c)) ∧
    -- 2. Hopf fibration: dimension reduction preserves structure
    (∀ v : Fin 2 → ℝ, v ∈ OctonionicHopf.unitSphere 2 →
      |OctonionicHopf.realHopfMap v| ≤ 1) ∧
    -- 3. Fano routing: 7 lines
    (TropicalFanoRouting.fanoLines.length = 7) ∧
    -- 4. Spectral gap: projection eigenvalues are 0 or 1
    ((1 : ℝ) - 0 = 1) ∧
    -- 5. Moufang crypto: max preimage is non-unique
    (∀ c : ℝ, ∃ a b a' b' : ℝ, max a b = c ∧ max a' b' = c ∧ (a ≠ a' ∨ b ≠ b')) :=
  ⟨fun a b c => max_assoc a b c,
   fun v hv => OctonionicHopf.hopf_bounded v hv,
   TropicalFanoRouting.fano_line_count,
   by norm_num,
   TropicalMoufangCrypto.max_preimage_nonunique⟩

end
```

@Algebra/Tropical_p_adic_Valuation_Bounds_and_Lifting_the_Exponent_for_Fibonacci_Primitive_Divisors.lean
```lean
/-
# Fibonacci Primitive Divisors and Lifting-the-Exponent

This file formalizes key results about primitive prime divisors of Fibonacci numbers,
including:
- The Fibonacci entry point (rank of apparition) z(p)
- The characterization: p | F_n ↔ z(p) | n
- Growth bounds for Fibonacci numbers
- The Lifting-the-Exponent (LTE) framework for Fibonacci sequences
- Carmichael's theorem: F_n has a primitive prime divisor for n ∉ {1, 2, 6, 12}

## References
- Carmichael, R.D. "On the numerical factors of the arithmetic forms αⁿ ± βⁿ" (1913)
- Yabuta, M. "A simple proof of Carmichael's theorem on primitive divisors" (2001)
-/

import Mathlib

open scoped BigOperators Nat
open Nat

set_option maxHeartbeats 8000000
set_option maxRecDepth 4000

/-! ## Section 1: Basic Fibonacci Properties -/

/-
Fibonacci numbers are strictly monotone for indices ≥ 2.
-/
theorem fib_strict_mono_of_ge_two {m n : ℕ} (hm : 2 ≤ m) (hmn : m < n) :
    Nat.fib m < Nat.fib n := by
  exact?

/-
F_n ≥ n for n ≥ 5.
-/
theorem fib_ge_index (n : ℕ) (hn : 5 ≤ n) : n ≤ Nat.fib n := by
  -- We can prove this by induction on $n$.
  induction' n using Nat.strong_induction_on with n ih;
  rcases hn with ( _ | _ | _ | _ | _ | n ) <;> simp +arith +decide [ Nat.fib_add_two ] at *;
  grind

/-- F_n > 0 for n > 0. -/
theorem fib_pos_of_pos {n : ℕ} (hn : 0 < n) : 0 < Nat.fib n :=
  Nat.fib_pos.mpr hn

/-! ## Section 2: The Fibonacci Entry Point (Rank of Apparition)

For a prime p, the entry point z(p) is the smallest positive integer k
such that p | F_k. This exists because p | F_{p - (p/5)} by quadratic
reciprocity properties of Fibonacci numbers.
-/

open Classical in
/-- The Fibonacci entry point: the smallest positive k such that p | F_k.
    Returns 0 if no such k exists (which doesn't happen for primes ≥ 2). -/
noncomputable def fibEntryPoint (p : ℕ) : ℕ :=
  if h : ∃ k : ℕ, 0 < k ∧ p ∣ Nat.fib k then
    Nat.find h
  else
    0

/-
If the entry point is positive, then p divides F_{z(p)}.
-/
theorem fib_entry_point_dvd (p : ℕ) (h : ∃ k : ℕ, 0 < k ∧ p ∣ Nat.fib k) :
    p ∣ Nat.fib (fibEntryPoint p) := by
  unfold fibEntryPoint;
  split_ifs ; exact Nat.find_spec h |>.2

/-
The entry point is positive when a divisibility witness exists.
-/
theorem fib_entry_point_pos (p : ℕ) (h : ∃ k : ℕ, 0 < k ∧ p ∣ Nat.fib k) :
    0 < fibEntryPoint p := by
  unfold fibEntryPoint; aesop;

/-
The entry point is minimal: if p | F_k and k > 0, then z(p) ≤ k.
-/
theorem fib_entry_point_le (p k : ℕ) (hk : 0 < k) (hpk : p ∣ Nat.fib k)
    (h : ∃ k : ℕ, 0 < k ∧ p ∣ Nat.fib k) :
    fibEntryPoint p ≤ k := by
  unfold fibEntryPoint;
  split_ifs ; aesop

/-! ## Section 3: Entry Point Divides Index

The key characterization: p | F_n if and only if z(p) | n.
This follows from the strong divisibility property gcd(F_m, F_n) = F_{gcd(m,n)}.
-/

/-
**Entry point divisibility**: For a prime p with p | F_m for some m > 0,
    we have p | F_n ↔ z(p) | n (assuming n > 0).
-/
theorem fib_dvd_iff_entry_dvd (p n : ℕ) (hp : Nat.Prime p) (hn : 0 < n)
    (hex : ∃ k : ℕ, 0 < k ∧ p ∣ Nat.fib k) :
    p ∣ Nat.fib n ↔ fibEntryPoint p ∣ n := by
  -- By definition of z(p), we know that p | F_{z(p)} and z(p) is the smallest such positive integer.
  have hz : p ∣ Nat.fib (fibEntryPoint p) ∧ ∀ k : ℕ, 0 < k → p ∣ Nat.fib k → fibEntryPoint p ≤ k := by
    exact ⟨ fib_entry_point_dvd p hex, fun k hk hk' => fib_entry_point_le p k hk hk' hex ⟩;
  have h_div : ∀ k : ℕ, 0 < k → p ∣ Nat.fib k → fibEntryPoint p ∣ k := by
    intros k hk_pos hk_div
    have h_gcd : Nat.gcd (fibEntryPoint p) k = fibEntryPoint p := by
      refine' Nat.le_antisymm _ _;
      · exact Nat.le_of_dvd ( fib_entry_point_pos p hex ) ( Nat.gcd_dvd_left _ _ );
      · refine' hz.2 _ ( Nat.gcd_pos_of_pos_right _ hk_pos ) _;
        have h_gcd : Nat.gcd (Nat.fib (fibEntryPoint p)) (Nat.fib k) = Nat.fib (Nat.gcd (fibEntryPoint p) k) := by
          exact?;
        exact h_gcd ▸ Nat.dvd_gcd hz.1 hk_div;
    exact h_gcd ▸ Nat.gcd_dvd_right _ _;
  exact ⟨ h_div n hn, fun h => dvd_trans hz.1 ( Nat.fib_dvd _ _ h ) ⟩

/-! ## Section 4: Primitive Prime Divisors -/

/-- A prime p is a **primitive prime divisor** of F_n if p | F_n and
    p does not divide F_k for any 0 < k < n. Equivalently, z(p) = n. -/
def IsPrimitivePrimeDivisor (p n : ℕ) : Prop :=
  Nat.Prime p ∧ p ∣ Nat.fib n ∧ ∀ k : ℕ, 0 < k → k < n → ¬(p ∣ Nat.fib k)

/-- F_n **has a primitive prime divisor** if there exists a prime p with z(p) = n. -/
def HasPrimitivePrimeDivisor (n : ℕ) : Prop :=
  ∃ p : ℕ, IsPrimitivePrimeDivisor p n

/-
A prime is a primitive divisor of F_n iff its entry point equals n.
-/
theorem isPrimitivePrimeDivisor_iff_entry_eq (p n : ℕ) (hp : Nat.Prime p) (hn : 0 < n)
    (hex : ∃ k : ℕ, 0 < k ∧ p ∣ Nat.fib k) :
    IsPrimitivePrimeDivisor p n ↔ (p ∣ Nat.fib n ∧ fibEntryPoint p = n) := by
  constructor <;> intro h;
  · exact ⟨ h.2.1, le_antisymm ( fib_entry_point_le p n hn h.2.1 hex ) ( Nat.le_of_not_gt fun hlt => h.2.2 _ ( fib_entry_point_pos p hex ) hlt ( fib_entry_point_dvd p hex ) ) ⟩;
  · exact ⟨ hp, h.1, fun k hk₁ hk₂ hk₃ => by have := fib_entry_point_le p k hk₁ hk₃ hex; linarith ⟩

/-! ## Section 5: Growth Bounds for Fibonacci Numbers

These bounds are essential for proving that F_n has prime factors beyond
those of F_d for proper divisors d of n.
-/

/-
Exponential lower bound: F_n ≥ 2^((n-2)/2) for n ≥ 2.
-/
theorem fib_exponential_lower_bound (n : ℕ) (hn : 2 ≤ n) :
    2 ^ ((n - 2) / 2) ≤ Nat.fib n := by
  rcases Nat.even_or_odd' n with ⟨ k, rfl | rfl ⟩;
  · induction' k with k ih <;> norm_num [ Nat.fib_add_two, Nat.mul_succ ] at *;
    rcases k with ( _ | _ | k ) <;> simp_all +arith +decide [ Nat.fib_add_two, Nat.mul_succ ];
    grind;
-- ... (truncated, full file has 493 lines)
```

@AutoResearch/CompactTropicalChoquetRadon.lean
```lean
/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Compact Tropical Choquet–Radon Representation

This file formalizes a Choquet–Radon representation theorem for upper-continuous
max-plus linear functionals on continuous real-valued functions over a compact
Hausdorff space.

## Main definitions

* `UCTropicalFunctional` — A structure encoding an upper-continuous, max-plus linear
  functional on `C(X, ℝ)` with values in `EReal`.
* `compactCapacity` — The compact-set capacity extracted from a functional.
* `infOnCompact` — The infimum of a continuous function on a compact set.
* `tropSupport` — The support of a tropical functional (smallest closed carrier).
* `supportedOn` — Predicate for a functional being supported on a set.
* `pushforwardFunctional` — Pushforward of a tropical functional along a continuous map.

## Main results

* `compactCapacity_empty` — Capacity of the empty compact set is ⊥.
* `compactCapacity_mono` — Capacity is monotone (larger sets, larger capacity).
* `compactCapacity_union` — Capacity is maxitive: `μ(K ∪ L) = max(μ(K), μ(L))`.
* `infOnCompact_le_eval` — The infimum on a compact set is bounded by point evaluation.
* `tropical_choquet_radon_le` — One direction of the representation:
    `⊔_K (μ(K) + inf_K f) ≤ Λ(f)`.
* `isClosed_tropSupport` — The tropical support is closed.
* `tropSupport_supported` — The functional is supported on its tropical support.
* `tropSupport_minimal` — The tropical support is the smallest closed carrier.
* `compactCapacity_pushforward_le` — Capacity is functorial under pushforward.

## Mathematical overview

In max-plus (tropical) algebra, addition is `max` and multiplication is `+`.
A max-plus linear functional Λ on continuous functions satisfies:
- `Λ(f ⊔ g) = Λ(f) ⊔ Λ(g)` (preserves tropical addition = max)
- `Λ(f + c) = Λ(f) + c` (equivariant under tropical scalar action = real translation)

The Choquet–Radon representation expresses such a functional as a "max-plus integral":
  `Λ(f) = ⊔_K (μ(K) + inf_K f)`
where `μ` is a maxitive capacity on compact sets.
-/

noncomputable section

open TopologicalSpace Set EReal

/-! ### The functional structure -/

/-- An upper-continuous tropical (max-plus linear) functional on `C(X, ℝ)`,
taking values in `EReal` (extended reals with ±∞).

The axioms encode:
- `monotone'`: monotonicity with respect to pointwise order
- `sup_preserving'`: max-plus additivity `Λ(f ⊔ g) = max(Λ(f), Λ(g))`
- `shift_equivariant'`: tropical scalar action `Λ(f + c) = Λ(f) + c`
- `normalized'`: normalization `Λ(0) = 0`

The upper-continuity axiom (`top_continuous'`) states that Λ commutes with
directed suprema of continuous functions, provided the supremum is itself continuous.
-/
structure UCTropicalFunctional (X : Type*) [TopologicalSpace X]
    [CompactSpace X] [T2Space X] where
  /-- The underlying function from continuous maps to extended reals. -/
  toFun : C(X, ℝ) → EReal
  /-- The functional is monotone. -/
  monotone' : Monotone toFun
  /-- The functional preserves binary suprema (max-plus additivity). -/
  sup_preserving' : ∀ f g : C(X, ℝ), toFun (f ⊔ g) = toFun f ⊔ toFun g
  /-- The functional is equivariant under translation by real constants. -/
  shift_equivariant' : ∀ (c : ℝ) (f : C(X, ℝ)),
    toFun (f + ContinuousMap.const X c) = toFun f + (c : EReal)
  /-- Upper continuity: Λ commutes with monotone suprema of continuous functions,
      provided the supremum is itself continuous. -/
  top_continuous' : ∀ {ι : Type*} [Nonempty ι] [Preorder ι] (s : ι → C(X, ℝ))
    (f : C(X, ℝ)),
    (∀ x, f x = ⨆ i, (s i x : EReal)) →
    Monotone s →
    toFun f = ⨆ i, toFun (s i)
  /-- Normalization: the zero function maps to zero. -/
  normalized' : toFun 0 = 0

variable {X : Type*} [TopologicalSpace X] [CompactSpace X] [T2Space X]

namespace UCTropicalFunctional

instance : CoeFun (UCTropicalFunctional X) (fun _ => C(X, ℝ) → EReal) :=
  ⟨toFun⟩

@[simp]
theorem coe_toFun (Λ : UCTropicalFunctional X) (f : C(X, ℝ)) :
    Λ f = Λ.toFun f := rfl

theorem monotone (Λ : UCTropicalFunctional X) : Monotone Λ.toFun :=
  Λ.monotone'

theorem sup_preserving (Λ : UCTropicalFunctional X) (f g : C(X, ℝ)) :
    Λ (f ⊔ g) = Λ f ⊔ Λ g :=
  Λ.sup_preserving' f g

theorem shift_equivariant (Λ : UCTropicalFunctional X) (c : ℝ) (f : C(X, ℝ)) :
    Λ (f + ContinuousMap.const X c) = Λ f + (c : EReal) :=
  Λ.shift_equivariant' c f

theorem normalized (Λ : UCTropicalFunctional X) :
    Λ 0 = 0 := Λ.normalized'

/-- The functional maps constant functions to the constant. -/
theorem map_const (Λ : UCTropicalFunctional X) (c : ℝ) :
    Λ (ContinuousMap.const X c) = (c : EReal) := by
  have h := Λ.shift_equivariant c 0
  simp [Λ.normalized] at h
  exact h

/-- As constants decrease to -∞, the functional value goes to ⊥. -/
theorem map_const_neg_iInf (Λ : UCTropicalFunctional X) :
    ⨅ (n : ℕ), Λ (ContinuousMap.const X (-(n : ℝ))) = ⊥ := by
  simp [map_const]
  rw [iInf_eq_bot]
  intro b hb
  induction b with
    | bot => exact absurd rfl (ne_of_gt hb)
    | top => exact ⟨0, by simp⟩
    | coe r =>
      obtain ⟨n, hn⟩ := exists_nat_gt (-r)
      exact ⟨n, EReal.coe_lt_coe_iff.mpr (by linarith)⟩

end UCTropicalFunctional

/-! ### Compact-set capacity -/

/-- The compact-set capacity extracted from a tropical functional.
    `compactCapacity Λ K` is the infimum of `Λ(f)` over all continuous functions `f`
    that are nonneg (≥ 0) on `K`. -/
def compactCapacity (Λ : UCTropicalFunctional X) (K : Compacts X) : EReal :=
  sInf {a : EReal | ∃ f : C(X, ℝ), (∀ x ∈ (K : Set X), (0 : ℝ) ≤ f x) ∧ a = Λ.toFun f}

/-- The infimum of a continuous function over a compact set.
    When `K` is empty, this is `⊤` by convention (infimum of empty set). -/
def infOnCompact (f : C(X, ℝ)) (K : Compacts X) : EReal :=
  ⨅ x ∈ (K : Set X), (f x : EReal)

/-! ### Basic capacity properties -/

/-- Helper: the defining set for compactCapacity is nonempty. -/
-- ... (truncated, full file has 459 lines)
```

@Cryptography/BerggrenAntiRigidity.lean
```lean
import Mathlib

/-!
# Berggren Semigroup: Anti-Involution Rigidity

We prove that the Berggren free semigroup inside GL₂(ℤ) is **completely disjoint from its
image under the adjugate anti-involution**, except at the identity. The adjugate of a 2×2
matrix M = !![a,b;c,d] is adj(M) = !![d,-b;-c,a], satisfying M * adj(M) = det(M) • I.
For invertible matrices (det = ±1), this equals ±M⁻¹, making it the natural matrix-level
"inverse" anti-involution.

## Main Results

* `evalBergWord_entry_00_pos` — top-left entry is always ≥ 1
* `evalBergWord_entry_10_nonneg` — bottom-left entry is always ≥ 0
* `evalBergWord_entry_00_ge_10` — top-left ≥ bottom-left (diagonal dominance)
* `adjugate2_anti_hom` — adjugate reverses multiplication
* `adjugate2_not_in_BergSemigroup` — **main theorem**: adjugate is never in the semigroup
* `berggren_inverse_rigidity` — no non-identity semigroup element has its inverse in the semigroup

## Mathematical Significance

This result upgrades the Berggren free-monoid injectivity theorem to a much stronger
structural statement: the semigroup occupies an "orientation-rigid" region of GL₂(ℤ) that
is completely separated from its image under the adjugate/inverse anti-involution. In
cryptographic applications, this means that reversing a Berggren-encoded transcript (taking
adjoints/inverses) can never accidentally produce a valid semigroup element, providing
anti-automorphism resistance for protocol canonicalization.

## References

The Berggren generators arise from the classical tree of primitive Pythagorean triples,
lifted to 2×2 integer matrices via the spin covering SL₂ → SO₂₁.
-/

set_option linter.unusedVariables false

/-! ## Generator Type and Word Evaluation -/

/-- The three Berggren generators. -/
inductive BergGen : Type
  | A | B | C
  deriving DecidableEq, Repr

/-- A Berggren word is a list of generators. -/
abbrev BergWord := List BergGen

/-- Action of each generator on the pair space (m, n). -/
def actGen (g : BergGen) (p : ℤ × ℤ) : ℤ × ℤ :=
  match g with
  | .A => (2 * p.1 - p.2, p.1)
  | .B => (2 * p.1 + p.2, p.1)
  | .C => (p.1 + 2 * p.2, p.2)

/-- The root pair (2, 1), corresponding to the identity matrix. -/
def rootPair : ℤ × ℤ := (2, 1)

/-- Pair-based evaluation of a Berggren word. -/
def evalPair : BergWord → ℤ × ℤ
  | [] => rootPair
  | g :: rest => actGen g (evalPair rest)

/-- A valid pair satisfies 0 < n < m. -/
def ValidPair (p : ℤ × ℤ) : Prop := 0 < p.2 ∧ p.2 < p.1

theorem rootPair_valid : ValidPair rootPair := ⟨by norm_num [rootPair], by norm_num [rootPair]⟩

theorem actGen_preserves_valid (g : BergGen) {p : ℤ × ℤ} (hp : ValidPair p) :
    ValidPair (actGen g p) := by
  obtain ⟨hn, hmn⟩ := hp
  cases g <;> constructor <;> simp only [actGen] <;> linarith

theorem evalPair_valid (w : BergWord) : ValidPair (evalPair w) := by
  induction w with
  | nil => exact rootPair_valid
  | cons g rest ih => exact actGen_preserves_valid g ih

theorem m_ge_three_after_gen (g : BergGen) {p : ℤ × ℤ} (hp : ValidPair p) :
    3 ≤ (actGen g p).1 := by
  obtain ⟨hn, hmn⟩ := hp; cases g <;> simp only [actGen] <;> linarith

theorem actGen_ne_root (g : BergGen) {p : ℤ × ℤ} (hp : ValidPair p) :
    actGen g p ≠ rootPair := by
  intro h; linarith [m_ge_three_after_gen g hp, show (actGen g p).1 = 2 from congr_arg Prod.fst h]

theorem actGen_injective (g : BergGen) : Function.Injective (actGen g) := by
  intro ⟨m₁, n₁⟩ ⟨m₂, n₂⟩ h
  cases g <;> simp only [actGen, Prod.mk.injEq] at h <;>
    exact Prod.ext (by linarith [h.1, h.2]) (by linarith [h.1, h.2])

theorem actGen_generator_determined {g₁ g₂ : BergGen} {p₁ p₂ : ℤ × ℤ}
    (hp₁ : ValidPair p₁) (hp₂ : ValidPair p₂)
    (h : actGen g₁ p₁ = actGen g₂ p₂) : g₁ = g₂ := by
  obtain ⟨hn₁, hmn₁⟩ := hp₁; obtain ⟨hn₂, hmn₂⟩ := hp₂
  have hf := congr_arg Prod.fst h; have hs := congr_arg Prod.snd h
  rcases g₁ with _ | _ | _ <;> rcases g₂ with _ | _ | _ <;>
    simp only [actGen] at hf hs <;> (first | rfl | linarith)

theorem actGen_unique_parent {g₁ g₂ : BergGen} {p₁ p₂ : ℤ × ℤ}
    (hp₁ : ValidPair p₁) (hp₂ : ValidPair p₂)
    (h : actGen g₁ p₁ = actGen g₂ p₂) : g₁ = g₂ ∧ p₁ = p₂ :=
  ⟨actGen_generator_determined hp₁ hp₂ h,
   actGen_injective g₁ (actGen_generator_determined hp₁ hp₂ h ▸ h)⟩

/-- **Freeness via pairs**: the pair evaluation is injective. -/
theorem evalPair_injective : Function.Injective evalPair := by
  intro w₁
  induction w₁ with
  | nil =>
    intro w₂ h; match w₂ with
    | [] => rfl
    | g :: rest => exact absurd h.symm (actGen_ne_root g (evalPair_valid rest))
  | cons g₁ rest₁ ih =>
    intro w₂ h; match w₂ with
    | [] => exact absurd h (actGen_ne_root g₁ (evalPair_valid rest₁))
    | g₂ :: rest₂ =>
      have ⟨hg, hp⟩ := actGen_unique_parent (evalPair_valid rest₁) (evalPair_valid rest₂) h
      subst hg; exact congrArg (g₁ :: ·) (ih hp)

/-! ## Matrix Formulation -/

/-- The 2×2 matrix for each Berggren generator. -/
def bergMat : BergGen → Matrix (Fin 2) (Fin 2) ℤ
  | .A => !![2, -1; 1, 0]
  | .B => !![2, 1; 1, 0]
  | .C => !![1, 2; 0, 1]

/-- Matrix evaluation of a Berggren word (left-multiplication). -/
def evalBergWord : BergWord → Matrix (Fin 2) (Fin 2) ℤ
  | [] => 1
  | g :: rest => bergMat g * evalBergWord rest

@[simp] theorem evalBergWord_nil : evalBergWord [] = 1 := rfl
@[simp] theorem evalBergWord_cons (g : BergGen) (w : BergWord) :
    evalBergWord (g :: w) = bergMat g * evalBergWord w := rfl

theorem evalBergWord_append (u v : BergWord) :
    evalBergWord (u ++ v) = evalBergWord u * evalBergWord v := by
  induction u with
  | nil => simp
  | cons g rest ih => simp [ih, Matrix.mul_assoc]

/-- Extract the pair invariant from a 2×2 matrix. -/
def pairOfMat (M : Matrix (Fin 2) (Fin 2) ℤ) : ℤ × ℤ :=
  (2 * M 0 0 + M 0 1, 2 * M 1 0 + M 1 1)

theorem pairOfMat_evalBergWord (w : BergWord) :
    pairOfMat (evalBergWord w) = evalPair w := by
  induction w with
  | nil => simp [pairOfMat, evalBergWord, evalPair, rootPair]
-- ... (truncated, full file has 404 lines)
```

@Cryptography/BerggrenBallRigidity.lean
```lean
import Mathlib

/-!
# Finite-Ball Rigidity and Generic-Group Lower-Bound Transfer for the Berggren Embedding

This file establishes finite-ball injectivity theorems for quotients of Berggren semigroup
elements in `SL₂(ℤ)`, and derives algebraic consequences for generic-group style
discrete-log attacks on reduced Berggren images.

## Main results

### Layer 1: Finite-ball injectivity

* `exists_modulus_injective_on_finite_int_matrix_set`: For any finite set of 2×2 integer
  matrices, there exists a modulus `N ≥ 2` such that reduction mod `N` is injective.

* `exists_modulus_injective_on_pairwiseDiffSet`: Injectivity of reduction on the set
  of pairwise differences from a Berggren ball.

* `berggren_ball_quotient_powers_injective_up_to`: Injectivity of reduction on all
  bounded powers of pairwise differences.

### Layer 2: Generic-group transfer

* `reduced_relation_lifts`: Any equality mod `N` among bounded-complexity power expressions
  built from Berggren ball elements already holds over the integers.

* `berggren_ball_power_collision_lifts`: Any power collision mod `N` among quotient elements
  from the Berggren ball is already a genuine collision over `ℤ`.

* `exists_modulus_injective_on_bounded_wordExprs`: Bounded symbolic manipulations in the
  reduced group cannot create new equalities not already present over `ℤ`.

## Strategy

The core mathematical argument is:
1. The Berggren ball of radius `R` is finite, hence all derived expression sets are finite.
2. For any finite set of distinct integer matrices, a sufficiently large prime separates them
   upon reduction — this is residual separation.
3. Power collision avoidance and relation lifting follow by applying residual separation to
   enlarged finite expression sets.

## References

The Berggren tree parametrizes all primitive Pythagorean triples via three generators
acting on (3,4,5). The 2×2 matrix representation embeds this into `GL₂(ℤ)`, with two
of the three generators (M₁ and M₃) lying in `SL₂(ℤ)`.
-/

open Matrix Finset

noncomputable section

/-! ## Section 1: The three Berggren 2×2 generators -/

/-- Berggren generator M₁ (A-branch): det = 1, in SL₂(ℤ) -/
def berggren_M₁ : Matrix (Fin 2) (Fin 2) ℤ := !![2, -1; 1, 0]

/-- Berggren generator M₂ (B-branch): det = -1, in GL₂(ℤ) -/
def berggren_M₂ : Matrix (Fin 2) (Fin 2) ℤ := !![2, 1; 1, 0]

/-- Berggren generator M₃ (C-branch): det = 1, in SL₂(ℤ) -/
def berggren_M₃ : Matrix (Fin 2) (Fin 2) ℤ := !![1, 2; 0, 1]

theorem det_berggren_M₁ : Matrix.det berggren_M₁ = 1 := by native_decide
theorem det_berggren_M₃ : Matrix.det berggren_M₃ = 1 := by native_decide

/-! ## Section 2: Berggren ball definition -/

/-- A Berggren generator index. -/
inductive BerggrenGen : Type
  | g1 | g2 | g3
  deriving DecidableEq, Fintype

/-- Map generator index to its 2×2 matrix. -/
def BerggrenGen.toMatrix : BerggrenGen → Matrix (Fin 2) (Fin 2) ℤ
  | .g1 => berggren_M₁
  | .g2 => berggren_M₂
  | .g3 => berggren_M₃

/-- Evaluate a word (list of generators) to a matrix product. -/
def berggrenWordEval : List BerggrenGen → Matrix (Fin 2) (Fin 2) ℤ
  | [] => 1
  | g :: gs => g.toMatrix * berggrenWordEval gs

/-- All words of exactly length `n` over the 3 generators. -/
def berggrenWordsOfLength : ℕ → Finset (List BerggrenGen)
  | 0 => {[]}
  | n + 1 => Fintype.elems.biUnion fun g =>
      (berggrenWordsOfLength n).image (g :: ·)

/-- All words of length at most `R`. -/
def berggrenWordsUpTo (R : ℕ) : Finset (List BerggrenGen) :=
  (range (R + 1)).biUnion berggrenWordsOfLength

/-- The Berggren ball of radius `R`: all matrices obtainable as products of at most `R`
    generators. This is manifestly a `Finset`. -/
def berggrenBall (R : ℕ) : Finset (Matrix (Fin 2) (Fin 2) ℤ) :=
  (berggrenWordsUpTo R).image berggrenWordEval

/-- The identity matrix is always in the Berggren ball. -/
theorem one_mem_berggrenBall (R : ℕ) : (1 : Matrix (Fin 2) (Fin 2) ℤ) ∈ berggrenBall R := by
  simp only [berggrenBall, berggrenWordsUpTo, mem_image, mem_biUnion, mem_range]
  exact ⟨[], ⟨0, Nat.zero_lt_succ _, by simp [berggrenWordsOfLength]⟩,
    by simp [berggrenWordEval]⟩

/-! ## Section 3: Core residual separation lemmas -/

/-- For any finite set of integers, there exists a prime larger than all their absolute values. -/
theorem exists_prime_gt_finset_natAbs (s : Finset ℤ) :
    ∃ p : ℕ, Nat.Prime p ∧ ∀ z ∈ s, Int.natAbs z < p := by
  obtain ⟨p, hp, hle⟩ := Nat.exists_infinite_primes ((s.image Int.natAbs).sup id + 1)
  exact ⟨p, hle, fun z hz => by
    have h1 : Int.natAbs z ≤ (s.image Int.natAbs).sup id :=
      Finset.le_sup_of_le (Finset.mem_image_of_mem _ hz) le_rfl
    omega⟩

/-- If |z| < p and z ≠ 0, then z is nonzero mod p. -/
theorem int_cast_ne_zero_of_natAbs_lt
    {z : ℤ} {p : ℕ} (h : Int.natAbs z < p) (hz : z ≠ 0) :
    (z : ZMod p) ≠ 0 := by
  rw [Ne, ZMod.intCast_zmod_eq_zero_iff_dvd]
  intro hdvd
  have h1 : p ∣ z.natAbs := Int.ofNat_dvd_left.mp hdvd
  exact absurd (Nat.le_of_dvd (Int.natAbs_pos.mpr hz) h1) (by omega)

/-- The set of all entrywise differences between pairs of matrices in a finite set. -/
def allEntryDiffs (T : Finset (Matrix (Fin 2) (Fin 2) ℤ)) : Finset ℤ :=
  T.biUnion fun A =>
    T.biUnion fun B =>
      Finset.univ.biUnion fun i =>
        Finset.univ.image fun j => A i j - B i j

theorem allEntryDiffs_mem {T : Finset (Matrix (Fin 2) (Fin 2) ℤ)}
    {A B : Matrix (Fin 2) (Fin 2) ℤ} {i j : Fin 2}
    (hA : A ∈ T) (hB : B ∈ T) :
    A i j - B i j ∈ allEntryDiffs T := by
  simp only [allEntryDiffs, mem_biUnion, mem_image, Finset.mem_univ, true_and]
  exact ⟨A, hA, B, hB, i, ⟨j, rfl⟩⟩

/-
**Key lemma**: For any finite set of 2×2 integer matrices, there exists `N ≥ 2`
    such that reduction mod `N` is injective on the set.

    The proof picks a prime larger than all entrywise differences, ensuring that
    distinct matrices remain distinct upon reduction.
-/
theorem exists_modulus_injective_on_finite_int_matrix_set
    (T : Finset (Matrix (Fin 2) (Fin 2) ℤ)) :
    ∃ N : ℕ, 2 ≤ N ∧
-- ... (truncated, full file has 319 lines)
```


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
