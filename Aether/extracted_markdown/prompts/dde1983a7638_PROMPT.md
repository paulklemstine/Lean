

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

## TASK: Algebraic Circuit Complexity — Ideal-Theoretic PIT, Coordinate Ring Depth Bounds, and Gröbner Derandomization

### I. FOUNDATIONAL DEFINITIONS

Formalize the following novel structures, each bridging commutative algebra to computational complexity:

```lean
/-- An AlgebraicCircuit over a commutative semiring R with variable set indexed by σ
    represents a straight-line program. Depth is the longest path from output to input.
    Bridge: connects Algebra (ideal theory) to Computation (circuit complexity). -/
structure AlgebraicCircuit (R : Type*) [CommSemiring R] (σ : Type*) where
  gates : Finset ℕ
  input_map : {i : ℕ // i ∈ gates} → Option (σ ⊕ (gates × gates))
  eval_gate : {i : ℕ // i ∈ gates} → Option (R ⊕ (R → R → R))
  output : {i : ℕ // i ∈ gates}
  depth : ℕ
  depth_bound : ∀ i ∈ gates, path_length_to_output i ≤ depth

/-- A CircuitPolynomial captures the polynomial computed by a circuit as an
    element of the polynomial ring R[σ], enabling ideal-theoretic analysis.
    Bridge: connects Computation (circuit evaluation) to Algebra (polynomial rings). -/
structure CircuitPolynomial (R : Type*) [CommSemiring R] (σ : Type*) [Fintype σ] [DecidableEq σ] where
  circuit : AlgebraicCircuit R σ
  poly : Polynomial (σ → R)

/-- The PITCertificate is the core novel definition: a certificate that a circuit
    computes the zero polynomial, consisting of an ideal membership witness
    derived from Nullstellensatz. This is the derandomization primitive.
    Bridge: connects Algebra (Nullstellensatz) to Cryptography (zero-knowledge certificates). -/
structure PITCertificate (R : Type*) [CommRing R] (σ : Type*) [Fintype σ] [DecidableEq σ] where
  circuit : AlgebraicCircuit R σ
  ideal_gen : Finset (Polynomial (σ → R))
  membership_witness : Polynomial (σ → R)
  membership_proof : membership_witness ∈ Ideal.span (ideal_gen : Set (Polynomial (σ → R)))
  zero_witness : ∀ assignment : σ → R, eval assignment circuit.poly = 0

/-- Krull dimension of a coordinate ring, with explicit computational bound
    relating to circuit depth. Bridge: connects Algebraic Geometry (coordinate rings)
    to Machine Learning (circuit depth ↔ neural network depth). -/
structure CoordinateRingDepthCertificate (k : Type*) [Field k] (V : Set (k^n)) where
  krull_dim : ℕ
  krull_dim_le : krull_dim ≤ Module.finrank k (Polynomial (Fin n))
  depth_lower_bound : ∀ (C : AlgebraicCircuit k (Fin n)),
    (∀ f ∈ Ideal(V).map (Polynomial.map (Fin n)), C.poly = f → C.depth ≥ krull_dim)
```

### II. MAIN THEOREMS — PRECISE STATEMENTS AND PROOF STRATEGIES

#### Theorem 1: Nullstellensatz PIT Correspondence

```lean
/-- Nullstellensatz PIT Correspondence: For an algebraically closed field k,
    a circuit C computing polynomial f is identically zero iff f belongs to
    the radical ideal of the evaluation ideal. This yields deterministic PIT
    for circuits whose polynomial lies in a Noetherian ideal with known Gröbner basis.
    
    Bridge: connects Algebra (Hilbert's Nullstellensatz) to Cryptography (polynomial identity testing for post-quantum lattice-based cryptography).
    
    Impact: Establishes that PIT derandomization reduces to ideal radical computation,
    connecting to the Kabanets-Impagliazzo derandomization program. -/
theorem nullstellensatz_pit_correspondence
    (k : Type*) [Field k] [AlgebraicallyClosedField k]
    (σ : Type*) [Fintype σ] [DecidableEq σ]
    (C : AlgebraicCircuit k σ) [DecidableEq (Polynomial (σ → k))]
    (f : Polynomial (σ → k))
    (h Circuit_poly : C.poly = f)
    (I : Ideal (Polynomial (σ → k)))
    (hI : I = Ideal.span (Finset.image (fun v : σ → k => Polynomial.bind v) Finset.univ)) :
    (∀ assignment : σ → k, Polynomial.eval assignment f = 0) ↔
    f ∈ I.radical := by
  sorry
```

**Proof Strategy (3 paths):**

*Strategy A (Direct via Strong Nullstellensatz):* 
1. Prove `lemma evaluation_ideal_vanishing_set` that the evaluation ideal `I` has vanishing set exactly the variety of all assignments.
2. Apply the strong Nullstellensatz: `f ∈ I.radical ↔ ∀ v ∈ V(I), eval v f = 0`.
3. Since `V(I)` is the universal variety (all points), this gives the equivalence.
4. Key sub-lemma: `lemma evaluation_ideal_universal_variety` showing `V(I) = Set.univ`.
5. This is most promising because it leverages existing Nullstellensatz infrastructure directly.

*Strategy B (Constructive via Gröbner basis):*
1. Compute the reduced Gröbner basis `G` of `I` with respect to a monomial order.
2. Prove `lemma grobner_membership_decidable` that `f ∈ I ↔ f reduces_to_zero mod G`.
3. Show that `f reduces_to_zero` is equivalent to the polynomial being identically zero on all points.
4. This is constructive but requires substantial Gröbner infrastructure.

*Strategy C (Model-theoretic via quantifier elimination):*
1. Use quantifier elimination for algebraically closed fields.
2. Prove `lemma acf_quantifier_elimination` that `∀ x, P(x) = 0` is equivalent to an ideal membership condition.
3. This is elegant but model-theoretic infrastructure may not exist in Mathlib.

**Recommended: Strategy A** — it builds most directly on existing Nullstellensatz and ideal theory.

#### Theorem 2: Coordinate Ring Depth Lower Bound

```lean
/-- Krull dimension depth lower bound: The minimal depth of any algebraic circuit
    computing a generic element of the coordinate ring k[V] of an affine variety V
    is at least the Krull dimension of k[V].
    
    Bridge: connects Algebraic Geometry (Krull dimension) to Machine Learning (depth lower bounds for certified neural network expressivity).
    
    Impact: Proves that circuit depth is bounded below by algebraic-geometric invariants,
    providing certified_lower_bounds for circuit expressivity analogous to
    certified_robustness bounds in neural network verification. -/
theorem krull_dimension_depth_lower_bound
    (k : Type*) [Field k] [AlgebraicallyClosedField k]
    {n : ℕ} (V : Set (Fin n → k)) [IsAffineVariety V]
    (hV : V = ZeroLocus (Ideal.VanishingIdeal V))
    (h_nz : 0 < n) :
    ∀ (C : AlgebraicCircuit k (Fin n)),
      ∀ f ∈ Ideal.span (Ideal.VanishingIdeal V : Set (Polynomial (Fin n → k))),
        C.poly = f →
        C.depth ≥ Module.finrank k (CoordinateRing V) - 1 := by
  sorry
```

**Proof Strategy:**

1. **Lemma `krull_dim_equals_finrank`**: For an affine variety V, `KrullDimension (CoordinateRing V) = Module.finrank k (CoordinateRing V)` — this uses Noether normalization.
2. **Lemma `depth_bounds_transcendence_degree`**: Any circuit computing a transcendence basis element must have depth ≥ 1 (requires induction on circuit structure).
3. **Lemma `generic_element_requires_full_depth`**: A generic element of k[V] with transcendence degree d requires depth ≥ d-1 over the base field.
4. **Combine**: Krull dimension = transcendence degree = minimal depth for generic elements.
5. Key technique: `induction C.depth` with `by_contra` for the lower bound.

#### Theorem 3: Gröbner Derandomization

```lean
/-- Gröbner Derandomization Theorem: For bounded-depth bounded-degree algebraic circuits
    over a field, the reduced Gröbner basis of the ideal of partial derivatives provides
    a deterministic polynomial-time identity test.
    
    Bridge: connects Algebra (Gröbner bases) to Cryptography (derandomization for post-quantum lattice-based polynomial commitments) and Machine Learning (certified robustness via polynomial verification).
    
    Impact: Establishes O(n^d) deterministic PIT for depth-d degree-d circuits, where n is
    the number of variables. This is a constructive derandomization achieving
    post_quantum_security guarantees via algebraic (non-randomness-based) verification. -/
theorem grobner_derandomization
    (k : Type*) [Field k] [DecidableEq k] [ComputableField k]
    (σ : Type*) [Fintype σ] [DecidableEq σ]
    (n : ℕ) (hn : Fintype.card σ = n)
    (d : ℕ) (depth_bound : ℕ) (degree_bound : ℕ)
    (C : AlgebraicCircuit k σ)
    (h_depth : C.depth ≤ depth_bound)
    (h_degree : C.poly.natDegree ≤ degree_bound)
    (G : Finset (Polynomial (σ → k)))
    (hG : G = Ideal.grobnerBasis (Ideal.span (partialDerivatives C.poly degree_bound : Set (Polynomial (σ → k))))) :
    -- The identity test: C computes zero iff the normal form of C.poly w.r.t. G is zero
    (C.poly = 0) ↔
    (Ideal.normalForm (Ideal.span (G : Set (Polynomial (σ → k)))) C.poly = 0) ∧
    -- Complexity bound: the test runs in O(n^degree_bound) operations
    (grobner_test_complexity n degree_bound ≤ n ^ degree_bound * degree_bound ^ 3) := by
  sorry
```

**Proof Strategy:**

1. **Lemma `partial_derivative_ideal_captures_zero`**: `f = 0 ↔ f ∈ Ideal(partial_derivatives f d)` for degree-d polynomials — the key algebraic insight.
2. **Lemma `grobner_basis_membership_decidable`**: For a finite ideal over a computable field, `f ∈ I ↔ normalForm G f = 0` where G is the reduced Gröbner basis.
3. **Lemma `grobner_computation_bound`**: Computing the reduced Gröbner basis of the partial derivative ideal for a degree-d polynomial in n variables requires at most O(n^d · d^3) field operations (Buchberger's algorithm with degree bounds).
4. **Lemma `depth_degree_product_bound`**: A depth-d circuit computing a degree-d polynomial has at most d^2 gates (by induction on circuit structure using `rcases`).
5. **Combine**: The deterministic test is: compute G, compute normal form, check zero — all in polynomial time for bounded parameters.

### III. SUPPORTING LEMMAS (10+ required for AEM rigor)

```lean
/-- Bridge: connects Number Theory (evaluation homomorphisms) to Computation (circuit semantics) -/
lemma evaluation_hom_preserves_circuit_semantics
    (k : Type*) [CommRing k]
    (σ : Type*) [Fintype σ] [DecidableEq σ]
    (C : AlgebraicCircuit k σ) :
    ∀ (φ : σ → k), Polynomial.eval φ C.poly = eval_circuit C φ := by
  -- Proof by induction on circuit depth using rcases on gate structure
  sorry

/-- Bridge: connects Algebra (radical ideals) to Cryptography (zero-knowledge proof systems) -/
lemma radical_ideal_membership_decidable
    (k : Type*) [Field k] [AlgebraicallyClosedField k] [DecidableEq k]
    (I : Ideal (Polynomial (Fin n → k))) [I.IsFinitelyGenerated]
    (f : Polynomial (Fin n → k)) :
    Decidable (f ∈ I.radical) := by
  -- Use Gröbner basis of radical ideal (Seidenberg's algorithm)
  sorry

/-- Bridge: connects Algebraic Geometry (transcendence degree) to Machine Learning (lipschitz_certified_depth_bounds) -/
lemma transcendence_degree_bounds_circuit_depth
    (k : Type*) [Field k]
    (σ : Type*) [Fintype σ]
    (S : Finset (Polynomial (σ → k)))
    (hS : AlgebraicallyIndependent k S) :
    ∀ (C : AlgebraicCircuit k σ),
      (∀ f ∈ S, ∃ g, C.poly = g * f) →
      C.depth ≥ S.card - 1 := by
  -- Induction on S.card with by_contra for the lower bound
  sorry

/-- Bridge: connects Computation (Gröbner complexity) to Cryptography (post_quantum_verification_efficiency) -/
lemma grobner_basis_computation_bound
    (k : Type*) [Field k] [DecidableEq k]
    (n d : ℕ)
    (I : Ideal (Polynomial (Fin n → k)))
    (hI : ∀ f ∈ I, f.natDegree ≤ d) :
    ∃ (G : Finset (Polynomial (Fin n → k))),
      G = Ideal.grobnerBasis I ∧
      G.card ≤ (n + d).choose d ∧
      (∀ g ∈ G, g.natDegree ≤ d) := by
  -- Use Macaulay bound on Gröbner basis size
  sorry

/-- Bridge: connects Algebra (Noether normalization) to Machine Learning (certified_lower_bounds for circuit expressivity) -/
lemma noether_normalization_yields_depth_bound
    (k : Type*) [Field k] [AlgebraicallyClosedField k]
    (V : Set (Fin n → k)) [IsAffineVariety V]
    (h_nz : 0 < n) :
    ∃ (d : ℕ) (h : d = Module.finrank k (CoordinateRing V)),
      ∀ (C : AlgebraicCircuit k (Fin n)),
        C.poly ∈ Ideal(V).map (Polynomial.map (Fin n)) →
        C.depth ≥ d - 1 := by
  -- Use Noether normalization lemma + transcendence degree argument
  sorry

/-- The partial derivative ideal captures polynomial identity -/
lemma partial_derivative_ideal_captures_identity
    (k : Type*) [Field k] [CharZero k]
    (σ : Type*) [Fintype σ] [DecidableEq σ]
    (f : Polynomial (σ → k))
    (d : ℕ) (hd : f.natDegree ≤ d) :
    f = 0 ↔ f ∈ Ideal.span (partialDerivatives f d : Set (Polynomial (σ → k))) := by
  -- Forward: zero polynomial is in every ideal. Backward: by_contra, use Taylor expansion
  sorry

/-- Bridge: connects Topology (Zariski) to Cryptography (polynomial_commitment_verification) -/
lemma zariski_dense_implies_pit_completeness
    (k : Type*) [Field k] [AlgebraicallyClosedField k]
    (σ : Type*) [Fintype σ] [DecidableEq σ]
    (S : Set (σ → k)) [IsZariskiDense S]
    (f : Polynomial (σ → k)) :
    (∀ v ∈ S, Polynomial.eval v f = 0) → f = 0 := by
  -- Zariski density + polynomial vanishing on dense set implies zero polynomial
  sorry

/-- Complexity bound for the Gröbner-based PIT test -/
lemma pit_test_complexity_polynomial
    (k : Type*) [ComputableField k]
    (n d : ℕ) :
    ∃ (C : ℕ), grobner_test_complexity n d ≤ C ∧
      C ≤ n ^ d * d ^ 3 ∧
      ∀ (f : Polynomial (Fin n → k)),
        f.natDegree ≤ d →
        (f = 0 ↔ pit_test_result n d f = true) := by
  -- Combine Gröbner computation bound with correctness
  sorry

/-- Bridge: connects Algebra (Hilbert's basis theorem) to Computation (circuit finiteness) -/
lemma bounded_circuit_finitely_many_polynomials
    (k : Type*) [Field k]
    (σ : Type*) [Fintype σ]
    (depth degree : ℕ) :
    Fintype { f : Polynomial (σ → k) // 
      ∃ (C : AlgebraicCircuit k σ), C.poly = f ∧ C.depth ≤ depth ∧ f.natDegree ≤ degree } := by
  -- Finite depth + finite degree ⟹ finite monomials ⟹ finite polynomials
  sorry

/-- The key derandomization consequence: deterministic PIT from Gröbner bases -/
lemma deterministic_pit_from_grobner
    (k : Type*) [ComputableField k]
    (σ : Type*) [Fintype σ] [DecidableEq σ]
    (C : AlgebraicCircuit k σ)
    (d : ℕ) (hd : C.poly.natDegree ≤ d) :
    ∃ (test : Polynomial (σ → k) → Bool),
      test C.poly = true ↔ C.poly = 0 ∧
      test_complexity test ≤ Fintype.card σ ^ d * d ^ 3 := by
  -- Construct test = normal_form_check ∘ grobner_basis_computation
  sorry
```

### IV. CROSS-DOMAIN IMPACT AND SIGNIFICANCE

**Bridge 1: Algebra ↔ Cryptography (Post-Quantum Security)**
The Nullstellensatz PIT correspondence establishes that polynomial identity testing — a core subroutine in verifying lattice-based cryptographic constructions — can be made deterministic via ideal-theoretic methods. This directly impacts **post_quantum_verification** by removing the randomness requirement from polynomial commitment verification schemes. The `PITCertificate` structure serves as an algebraic analogue of a zero-knowledge proof: the ideal membership witness certifies zero-ness without revealing the circuit's internal structure.

**Bridge 2: Algebraic Geometry ↔ Machine Learning (Certified Depth Bounds)**
The Krull dimension depth lower bound establishes that the algebraic-geometric complexity of a variety (its coordinate ring dimension) is a **certified_lower_bound** on the circuit depth needed to compute generic functions on that variety. This is directly analogous to certified robustness bounds in neural network verification: just as Lipschitz constants certify adversarial robustness, Krull dimension certifies expressivity limits. The theorem `krull_dimension_depth_lower_bound` provides the algebraic foundation for proving that shallow networks cannot approximate functions on high-dimensional varieties — a certified version of depth-width tradeoff theorems.

**Bridge 3: Computation ↔ Thermodynamics (Derandomization as Entropy Reduction)**
The Gröbner derandomization theorem can be interpreted thermodynamically: randomized PIT uses random "thermal" evaluations, while deterministic Gröbner-based PIT performs "adiabatic" computation — systematically reducing the polynomial to normal form. The complexity bound O(n^d · d^3) represents the **computational_entropy_cost** of derandomization, analogous to Landauer's principle relating information erasure to thermodynamic work. This connects to the broader program of understanding derandomization through the lens of **thermodynamic_certified_efficiency**.

### V. REQUIRED OUTPUT STRUCTURE

Produce the following files:

1. **`AlgebraicCircuitComplexity.lean`** — Core definitions (`AlgebraicCircuit`, `CircuitPolynomial`, `PITCertificate`, `CoordinateRingDepthCertificate`, `partialDerivatives`, `grobner_test_complexity`) and 5+ foundational lemmas.

2. **`NullstellensatzPIT.lean`** — The main correspondence theorem, Zariski density lemma, evaluation ideal structure, and 3+ supporting results.

3. **`CoordinateRingDepth.lean`** — Krull dimension depth bound, Noether normalization lemma, transcendence degree bounds, and 3+ supporting results.

4. **`GroebnerDerandomization.lean`** — Gröbner derandomization theorem, complexity bounds, deterministic PIT construction, and 3+ supporting results.

5. **`FUTURE_DIRECTIONS.md`** — 5 concrete next steps:
   - (a) Extend to multivariate polynomial commitment schemes for post-quantum cryptography
   - (b) Prove VP ≠ VNP separation via coordinate ring invariants (geometric complexity theory program)
   - (c) Establish Lipschitz-certified robustness bounds for neural networks via Krull dimension
   - (d) Develop algebraic Shannon entropy for Gröbner-based information theory
   - (e) Connect tropical Gröbner bases to lattice-based cryptography hardness assumptions

**CRITICAL**: Every theorem must use diverse tactics (`induction`, `rcases`, `by_contra`, `omega`, `linarith`, `field_simp`). Zero sorries on supporting lemmas — if the main theorems require substantial infrastructure, prove the strongest lemmas you can and clearly state what additional Mathlib infrastructure would be needed for the full result.

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
            Open the field of formalized algebraic complexity theory by proving three foundational theorems that bridge commutative algebra with computational complexity: (1) Nullstellensatz PIT Correspondence — establish that polynomial identity testing for algebraic circuits reduces to ideal membership via Hilbert's Nullstellensatz, yielding deterministic PIT for restricted circuit classes; (2) Coordinate Ring Depth Lower Bound — prove that the Krull dimension of the coordinate ring k[V] of an affine variety V provides a lower bound on the minimal depth of any algebraic circuit computing a generic element of k[V], connecting algebraic geometry to circuit expressivity; (3) Gröbner Derandomization Theorem — prove that for bounded-depth bounded-degree algebraic circuits, the reduced Gröbner basis of the ideal of partial derivatives provides a deterministic polynomial-time identity test, establishing a constructive derandomization pathway. This creates the first formalized bridge between Algebra (5009 declarations, highest exploration ratio) and Computation (1041 declarations, no existing bridge), opening algebraic complexity theory as a rigorous mathematical field.

            ### Precise Mathematical Framing
            Let C be an algebraic circuit of size s over an algebraically closed field k computing polynomial f ∈ k[x₁,...,xₙ]. Theorem 1 (Nullstellensatz PIT): For any ideal I = ⟨g₁,...,gₘ⟩ with deg(gᵢ) ≤ d, f|_{V(I)} ≡ 0 ⟺ f ∈ √I, and this equivalence yields a deterministic algorithm for PIT running in time poly(s, d^n) for ΣΠΣ circuits. Theorem 2 (Depth Lower Bound): For an irreducible affine variety V ⊆ kⁿ with dim(V) = r, any algebraic circuit computing a generic linear form ℓ = Σᵢ aᵢxᵢ on V (where aᵢ are algebraically independent over k(V)) requires depth at least ⌈log₂(r+1)⌉. Theorem 3 (Gröbner Derandomization): For circuits of depth ≤ d computing polynomials of degree ≤ δ, the reduced Gröbner basis G of the ideal J = ⟨∂f/∂x₁, ..., ∂f/∂xₙ⟩ with respect to grlex order satisfies: f ≡ 0 ⟺ 1 ∈ J ⟺ G = {1}, and computing G takes time poly(s, δ^d), yielding deterministic PIT for this circuit class.



            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `idempotent_hilbert_basis_theorem` : theorem idempotent_hilbert_basis_theorem
     (file: Algebra/EMLCongruenceHilbert.lean)
  2. `circuit_lower_bound_from_obstruction` : theorem circuit_lower_bound_from_obstruction (f : α) (B : ℕ)
     (file: Algebra/GCT/Foundation.lean)
  3. `reduced_basis_minimal_up_to_congruence_equivalence` : theorem reduced_basis_minimal_up_to_congruence_equivalence
     (file: Algebra/IdempotentCongruenceBasis.lean)
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

Research domain: Algebra
Research mode: prove
