

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

## YOUR ASSIGNMENT: EML Quantum Stabilizer Theory — Closure-Stabilizer Galois Connection, Knaster-Tarski Codespace Certification, and Idempotent Recovery Concatenation

### The Grand Vision

We establish that the stabilizer formalism of quantum error correction is *precisely* the theory of closure operators on the lattice of quantum subspaces that respect Pauli symmetries. This is not analogy — it is theorem. The Knaster-Tarski fixed point theorem, recast in the Hilbert space setting, *certifies* codespaces as fixed points of stabilizer projections, and the idempotent composition theorem *guarantees* that concatenating quantum error recovery operators yields certified robustness bounds. This bridges order theory, quantum information, and certified machine learning in a single formal framework.

### Core Definitions (5+ Required)

```lean
/-- The Pauli group on n qubits as a multiplicative subgroup of unitary matrices.
    Bridge: connects algebraic group theory to quantum error correction. -/
structure PauliGroup (n : ℕ) where
  elem : Matrix (Fin (2^n)) (Fin (2^n)) ℂ
  is_unitary : elem * elemᴴ = 1
  pauli_decomposition : ∃ (P : Fin n → {I, X, Y, Z}), elem = tensorPower n P

/-- A stabilizer code: an abelian subgroup of the Pauli group excluding -I. -/
structure StabilizerCode (n : ℕ) extends Subgroup (PauliGroup n) where
  is_abelian : ∀ P Q ∈ carrier, P * Q = Q * P
  excludes_minus_I : ¬(-1 • 1 : PauliGroup n) ∈ carrier

/-- The projection onto a stabilizer codespace. This is a closure operator on L(H). -/
def stabilizerProjection {n : ℕ} (S : StabilizerCode n) : L(H n) →ₗ[L] L(H n) :=
  (1 / S.card : ℂ) • ∑ P ∈ S.carrier, adj (P.elem)

/-- Certified robustness radius for a stabilizer code against Pauli noise.
    Gives an explicit O(2^n) bound on the error correction capability. -/
def certifiedRobustnessRadius {n : ℕ} (S : StabilizerCode n) : ℝ :=
  (1/2) * (S.card : ℝ)⁻¹ * (2^n : ℝ)

/-- Idempotent recovery operator: concatenating recovery operations
    is equivalent to a single recovery. Bridge: connects monad theory
    to quantum error correction. -/
structure IdempotentRecovery (n : ℕ) where
  operator : L(H n) →ₗ[L] L(H n)
  is_closure : IsClosureOperator operator
  commutes_pauli : ∀ P : PauliGroup n, operator ∘ (adj P.elem) = (adj P.elem) ∘ operator

/-- The Galois connection between stabilizer subgroups and closed subspaces. -/
def stabilizerGaloisConnection (n : ℕ) :
    GaloisConnection (StabilizerCode n) (ClosedSubspace (H n)) :=
  ⟨fun S => fixedPoints (stabilizerProjection S),
   fun V => { P : PauliGroup n | ∀ v ∈ V, P.elem • v = v }⟩
```

### Target Theorems (10+ Required)

**THEOREM 1 (Main): Stabilizer-Closure Correspondence**
```lean
/-- Every closure operator on L(H) that commutes with a Pauli subgroup IS
    a stabilizer projection, and conversely. This is the fundamental theorem
    bridging order theory and quantum error correction.
    Bridge: connects lattice theory to quantum stabilizer formalism.
    Impact: certified_robustness for quantum error correction. -/
theorem stabilizer_closure_correspondence {n : ℕ}
    (S : StabilizerCode n) :
    IsClosureOperator (stabilizerProjection S) ∧
    ∀ C : L(H n) →ₗ[L] L(H n),
      IsClosureOperator C →
      (∀ P ∈ S, C ∘ (adj P.elem) = (adj P.elem) ∘ C) →
      ∃ S' : StabilizerCode n, C = stabilizerProjection S'
```

**THEOREM 2: Knaster-Tarski Codespace Certification**
```lean
/-- The codespace of a stabilizer code is precisely the set of fixed points
    of its stabilizer projection. Knaster-Tarski guarantees this is a complete
    sublattice. Bridge: connects fixed-point theory to quantum codespace certification.
    Impact: lattice_crypto — stabilizer codes form lattices resistant to
    post-quantum attacks. -/
theorem knaster_tarski_codespace_certification {n : ℕ} (S : StabilizerCode n) :
    ∀ v : H n, v ∈ fixedPoints (stabilizerProjection S) ↔
      ∀ P ∈ S, P.elem • v = v
```

**THEOREM 3: Idempotent Recovery Concatenation**
```lean
/-- Concatenating two idempotent recovery operators that commute with the
    same stabilizer group yields an idempotent recovery operator whose
    robustness radius is the minimum of the two.
    Gives explicit bound: R(R₁ ⊙ R₂) ≥ min(R(R₁), R(R₂)).
    Impact: certified_robustness for concatenated quantum codes. -/
theorem idempotent_recovery_concatenation {n : ℕ} (S : StabilizerCode n)
    (R₁ R₂ : IdempotentRecovery n)
    (h₁ : R₁.commutes_pauli = commutes_with_stabilizer S)
    (h₂ : R₂.commutes_pauli = commutes_with_stabilizer S) :
    IsClosureOperator (R₁.operator ∘ R₂.operator) ∧
    certifiedRobustnessRadius (concatenated_code R₁ R₂) ≥
      min (certifiedRobustnessRadius (recovery_to_code R₁))
          (certifiedRobustnessRadius (recovery_to_code R₂))
```

**THEOREM 4: Pauli Group Order Bound**
```lean
/-- The Pauli group on n qubits has order 4^(n+1). This is O(4^n),
    giving exponential growth in the stabilizer search space.
    Impact: post_quantum_security — exponential Pauli group size
    provides information-theoretic security guarantees. -/
theorem pauli_group_order (n : ℕ) : Fintype.card (PauliGroup n) = 4^(n+1)
```

**THEOREM 5: Stabilizer Projection is Trace-Preserving on Codespace**
```lean
/-- The stabilizer projection preserves the trace on its codespace,
    making it a valid quantum channel (CPTP map).
    Impact: hamiltonian — stabilizer projections are physical operations. -/
theorem stabilizer_projection_trace_preserving {n : ℕ} (S : StabilizerCode n) :
    ∀ ρ : L(H n), ρ ∈ codespace S →
      Tr (stabilizerProjection S ρ) = Tr ρ
```

**THEOREM 6: Certified Robustness Against Pauli Noise**
```lean
/-- For any Pauli error E with weight ≤ certifiedRobustnessRadius S,
    the stabilizer projection recovers the original state.
    Explicit bound: weight(E) ≤ (|S| - 1)/2 guarantees recovery.
    Impact: certified_robustness with explicit Lipschitz bound. -/
theorem certified_robustness_pauli_noise {n : ℕ} (S : StabilizerCode n)
    (E : PauliGroup n) (hE : pauliWeight E ≤ (S.card - 1) / 2) (ρ : L(H n)) :
    stabilizerProjection S (E.elem * ρ * E.elemᴴ) = ρ
```

**THEOREM 7: Galois Connection Adjunction**
```lean
/-- The stabilizer-subspace correspondence forms a Galois connection.
    Bridge: connects Galois theory to quantum error correction.
    This is the order-theoretic shadow of the quantum-classical duality. -/
theorem stabilizer_galois_adjunction {n : ℕ} :
    IsGaloisConnection (stabilizerGaloisConnection n).fun
                       (stabilizerGaloisConnection n).inv
```

**THEOREM 8: Dual Stabilizer Lattice Isomorphism**
```lean
/-- The lattice of stabilizer codes is dually isomorphic to the lattice
    of their codespaces. Bridge: connects lattice duality to quantum
    code hierarchy.
    Impact: tropical_hash_collision — dual lattice structure prevents
    collision attacks in post-quantum cryptography. -/
theorem dual_stabilizer_lattice_isomorphism {n : ℕ} :
    Nonempty (LatticeIso (StabilizerCode n)ᵒᵈ (ClosedSubspace (H n)))
```

**THEOREM 9: Entropy Bound on Stabilizer Codespace**
```lean
/-- The von Neumann entropy of a stabilizer codespace is bounded by
    log₂(|S|), giving an explicit O(n) bound for n-qubit codes.
    Impact: entropy — connects stabilizer theory to information theory. -/
theorem stabilizer_entropy_bound {n : ℕ} (S : StabilizerCode n) :
    vonNeumannEntropy (stabilizerProjection S 1) ≤ Real.log₂ (S.card : ℝ)
```

**THEOREM 10: Composition Closure Under Stabilizer Intersection**
```lean
/-- The intersection of stabilizer codes corresponds to the join of
    their closure operators. Bridge: connects order-theoretic joins
    to quantum code concatenation.
    Impact: post_quantum_security — intersection codes are exponentially
    harder to break. -/
theorem stabilizer_intersection_closure_join {n : ℕ}
    (S₁ S₂ : StabilizerCode n) :
    stabilizerProjection (S₁ ⊓ S₂) =
      closureJoin (stabilizerProjection S₁) (stabilizerProjection S₂)
```

### Proof Strategies (3 Paths)

**Strategy A (Direct via Knaster-Tarski):** Prove `stabilizerProjection S` is a closure operator by verifying extensivity, monotonicity, and idempotence directly from the Pauli group axioms. Then show that any closure operator `C` commuting with `S` must fix exactly the `S`-invariant subspace, making `C = stabilizerProjection S'` for `S' = {P : PauliGroup n | ∀ v ∈ fixedPoints C, P • v = v}`. *This is the most promising path* because Knaster-Tarski already gives us the fixed-point lattice structure, and the commutation condition forces `C` to respect the Pauli symmetry.

**Strategy B (Constructive via Spectral Decomposition):** Decompose `C` as a sum over its eigenvalues (which must be 0 or 1 for a closure operator). The commutation condition forces the eigenspaces to be Pauli-invariant, hence they are spanned by simultaneous eigenvectors of `S`. Each such eigenspace corresponds to a coset of `S` in the Pauli group. *Risk:* requires spectral theorem for operators on `H n`, which may not be in the catalog.

**Strategy C (Contrapositive + Galois Connection):** Assume `C` is a closure operator not of the form `stabilizerProjection S'`. Use the Galois connection to show there exists a Pauli operator `P` that does not commute with `C`, yielding the contrapositive. *This is cleanest for the existence direction* but requires building the full Galois connection machinery first.

**Recommended order:** Prove Theorem 4 (Pauli group order) first as a warmup. Then Theorem 2 (Knaster-Tarski certification) using Strategy A. Then Theorem 7 (Galois connection). Then Theorem 1 (main correspondence) using Strategy A + C. Then Theorems 3, 5, 6, 8, 9, 10 in sequence, each building on the previous.

### Revolutionary Significance

This work establishes that **quantum error correction is order theory in disguise**. The stabilizer formalism — the workhorse of quantum computing — is precisely the theory of closure operators that respect Pauli symmetries. This means:

1. **For quantum computing:** Every result about closure operators (Knaster-Tarski, composition, Galois connections) immediately yields a quantum error correction result. The idempotent composition theorem guarantees that concatenated quantum codes inherit certified robustness.

2. **For post-quantum cryptography:** The exponential growth of the Pauli group (Theorem 4, O(4^n)) and the lattice structure of stabilizer codes (Theorem 8) provide structural hardness assumptions for lattice-based cryptography. The dual lattice isomorphism prevents collision attacks.

3. **For certified ML:** The certified robustness radius (Theorem 6) with its explicit Lipschitz bound `(1/2)|S|⁻¹·2^n` transfers directly to certified robustness for quantum neural networks via the stabilizer formalism.

### FUTURE_DIRECTIONS.md Requirement

At the end of your output, include a structured `FUTURE_DIRECTIONS.md` with 3-5 concrete, specific, breakthrough-level next steps:

1. **Tropical Stabilizer Codes:** Replace the Pauli group with the tropical Pauli group (min-plus algebra) and prove a tropical stabilizer-closure correspondence. This connects to tropical geometry and gives O(n log n) decoding algorithms.

2. **Topological Stabilizer Persistence:** Define persistent stabilizer homology and prove stability theorems (Lipschitz bound on barcode distance). This bridges topological data analysis with quantum error correction.

3. **Post-Quantum Lattice Hardness from Stabilizer Lattices:** Prove that finding short vectors in stabilizer code lattices is NP-hard under quantum reductions, advancing post-quantum cryptography.

4. **Neural Stabilizer Certification:** Train neural networks to predict certified robustness radii and prove Lipschitz bounds on the predictor using the stabilizer-closure correspondence.

5. **Thermodynamic Stabilizer Codes:** Connect stabilizer projections to free energy minimization and prove that the codespace minimizes a quantum Gibbs free energy functional.

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
            Open the field of closure-theoretic quantum error correction by proving three foundational theorems that establish a rigorous correspondence between EML closure operators and quantum stabilizer codes. Theorem 1 (EML Stabilizer Correspondence): Every stabilizer code on n qubits defines a closure operator on the subspace lattice L(ℂ^{2^n}) via the projection Π_S = (1/|S|)Σ_{P∈S} P, and conversely every Pauli-compatible closure operator arises from a stabilizer code. Theorem 2 (Knaster-Tarski Codespace Certification): The codespace of a stabilizer code equals Fix(Π_S), which by Knaster-Tarski forms a complete sublattice with certified dimension bound dim(Fix(Π_S)) = 2^{n-k} where k = log₂|S|. Theorem 3 (Idempotent Recovery Concatenation): A recovery map is certified if and only if it is a closure operator fixing the codespace; composition of commuting certified recoveries R₁∘R₂ yields certified concatenated codes with Fix(R₁∘R₂) = Fix(R₁)∩Fix(R₂).

            ### Precise Mathematical Framing
            Let P_n denote the n-qubit Pauli group and S ≤ P_n a stabilizer subgroup with -I ∉ S. Define the subspace lattice L(H) = {V : V ≤ H} ordered by inclusion. The stabilizer projection Π_S : L(ℂ^{2^n}) → L(ℂ^{2^n}) sending V ↦ Π_S(V) is proven to be a closure operator (extensive: V ≤ Π_S(V); monotone: V ≤ W → Π_S(V) ≤ Π_S(W); idempotent: Π_S(Π_S(V)) = Π_S(V)). Conversely, any closure operator C on L(ℂ^{2^n}) satisfying C ∘ Ad_P = Ad_P ∘ C for all P in a commutative subgroup of P_n arises from a stabilizer code. The Knaster-Tarski theorem guarantees Fix(Π_S) is a complete lattice, certifying the logical subspace. Recovery concatenation follows from the composition theory of commuting closure operators.

            ### Lean 4 Sketch
theorem eml_stabilizer_correspondence {n : ℕ} (S : Subgroup (PauliGroup n)) (hS : ¬(-1 • 1 : PauliGroup n) ∈ S) : IsClosureOperator (stabilizerProjection S) ∧ ∀ C : L(H) →ₗ L(H), IsClosureOperator C → (∀ P ∈ S, C ∘ (adj P) = (adj P) ∘ C) → ∃ S' : Subgroup (PauliGroup n), C = stabilizerProjection S'

            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `certified_robust_from_margin_bound` : lemma certified_robust_from_margin_bound {n m : ℕ}
     (file: Bridges/MaslovDequantizationRobustness.lean)
  2. `quantum_error_correction` : theorem quantum_error_correction (d : ℕ) (hd : 1 ≤ d) :
     (file: Bridges/Moonshine/MoonshineCodingTheory.lean)
  3. `prime_bound_of_admissible_code` : theorem prime_bound_of_admissible_code
     (file: Bridges/LawvereRateDistortionDuality.lean)
  4. `ultrametric_composition_depth_bound` : theorem ultrametric_composition_depth_bound
     (file: Bridges/NonArchimedeanComputation.lean)
  5. `purity_lower_bound_from_spectrum` : theorem purity_lower_bound_from_spectrum (k : ℕ) (hk : k > 0)
     (file: Bridges/QuantumIdempotent.lean)

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



Recent successful concepts: Causal Reconstruction of Zariski Topology: Finite Causal Decomposition, Causal Depth-Dimension Identity, and Holographic Uniqueness, Diophantine Cryptography: Berggren Descent One-Way Functions, Modular Triple Hash Universality, and Tree-Geodesic Collision Resistance, Quantum Berggren Walks: Hopf-Algebraic Unitary Evolution, Spectral Gap Speedup, and Diophantine Quantum Search


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
