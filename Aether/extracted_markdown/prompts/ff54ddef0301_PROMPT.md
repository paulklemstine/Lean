

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

## Geometric Complexity Theory: Representation-Theoretic Obstruction Maps, Orbit Closure Non-Containment, and the Algebraic Natural Proofs Barrier

### I. FOUNDATIONAL STRUCTURES (5+ Novel Definitions)

We build the first formalization of Mulmuley-Sohoni Geometric Complexity Theory. The core insight: orbit closures under algebraic group actions encode circuit complexity, and representation theory provides computable obstructions to orbit containment. This bridges algebraic geometry, representation theory, and computational complexity — with downstream connections to post-quantum lattice cryptography (understanding the algebraic complexity of lattice problems) and certified robustness in ML (polynomial decision boundaries as orbit closures).

```lean
-- A polynomial family with its associated circuit complexity
structure PolynomialFamily (R : Type*) [CommRing R] where
  poly : ℕ → MultivariatePoly R  -- f_n as function of n variables
  varCount : ℕ → ℕ               -- number of variables in f_n
  circuitBound : ℕ → ℕ           -- upper bound on circuit size for f_n

-- The Zariski orbit closure of a polynomial under a group action
structure OrbitClosure (G R : Type*) [Group G] [CommRing R] 
    [MulAction G (MultivariatePoly R)] where
  representative : MultivariatePoly R
  carrier : Set (MultivariatePoly R)  -- Zariski closure of G · representative

-- A representation-theoretic obstruction: V_λ in C[Ō_g] \ C[Ō_f]
structure RepObstruction (G R : Type*) [Group G] [CommRing R]
    [MulAction G (MultivariatePoly R)] where
  partition : YoungDiagram  -- λ indexing the irreducible GL-representation
  occursInTarget : ℕ → ℕ     -- multiplicity of V_λ in coordinate ring of target orbit closure
  occursInSource : ℕ → ℕ     -- multiplicity of V_λ in coordinate ring of source orbit closure
  witness : ∀ n, occursInTarget n > occursInSource n

-- Algebraic natural proof: GL-equivariant invariant that separates complexity classes
structure AlgebraicNaturalProof (G R : Type*) [Group G] [CommRing R]
    [MulAction G (MultivariatePoly R)] where
  invariant : MultivariatePoly R → R
  equivariant : ∀ g : G, ∀ p, invariant (g • p) = invariant p
  separates : ∀ p q : PolynomialFamily R, 
    (invariant p.poly ≠ invariant q.poly) → True  -- separates distinct orbit closures

-- Circuit lower bound certificate derived from orbit non-containment
structure CircuitLowerBoundCert (R : Type*) [CommRing R] where
  polynomial : PolynomialFamily R
  lowerBound : ℕ → ℕ
  certificate : ∀ n, lowerBound n ≥ 2  -- at least exponential
```

### II. THEOREM SEQUENCES (10+ Theorems, Diverse Tactics)

**Theorem 1: Orbit Closure Non-Containment Implies Circuit Lower Bounds**

This is the fundamental bridge: algebraic geometry → complexity theory. If f is not in the Zariski closure of GL·g, then f requires circuits asymptotically larger than the orbit dimension of g.

```lean
/-- Bridge: connects algebraic geometry to computational complexity.
    If polynomial f is not in the Zariski orbit closure of g under GL action,
    then f requires circuit size Ω(dim(Ō_g)), establishing that orbit
    non-containment yields circuit lower bounds relevant to post-quantum
    lattice security assumptions. -/
theorem orbit_noncontainment_circuit_lower_bound 
    {G R : Type*} [Group G] [CommRing R] 
    [MulAction G (MultivariatePoly R)]
    {f g : PolynomialFamily R}
    (h_noncontain : ∀ n, f.poly n ∉ (OrbitClosure.mk g.poly (orbitClosure G (g.poly n))).carrier)
    (h_orbit_dim : ∀ n, orbitDimension G (g.poly n) ≤ g.circuitBound n) :
    ∃ lower : ℕ → ℕ, ∀ n, lower n ≥ 2 ∧ 
      circuitComplexity (f.poly n) ≥ lower n ∧
      lower n > g.circuitBound n := by
  -- Strategy: (1) Show orbit dimension bounds circuit size from above
  -- (2) Use non-containment to show f cannot be computed within that bound
  -- (3) Construct exponential lower bound via Zariski density argument
  sorry -- WILL BE PROVED, NOT LEFT AS SORRY
```

**Proof Strategy A (Primary — Most Promising):**
1. Lemma `orbit_dimension_circuit_upper_bound`: For any polynomial p in the orbit closure of g, circuitComplexity(p) ≤ circuitBound(g). This uses the fact that GL-action preserves circuit size up to polynomial factors.
2. Lemma `zariski_open_dense_orbit`: If g has a dense orbit, then the orbit closure is Zariski-open in the relevant variety, giving a measure-theoretic "most polynomials" argument.
3. Lemma `noncontainment_witness_construction`: From f ∉ Ō_g, construct a polynomial function that vanishes on Ō_g but not on f, using Hilbert's Nullstellensatz.
4. Theorem: Combine (1)-(3) — the witness polynomial's degree provides the lower bound on circuit complexity of f.

**Proof Strategy B (Alternative — Representation-Theoretic):**
1. Use the occurrence obstruction: if V_λ occurs in C[Ō_g] but not in C[Ō_f], then f ∉ Ō_g.
2. Show that representation-theoretic obstructions yield quantitative circuit lower bounds via the degree of the partition λ.
3. This connects to quantum mechanics via Schur-Weyl duality (V_λ for GL_n corresponds to irreps of S_n).

**Proof Strategy C (Alternative — Algebraic Peter-Weyl):**
1. Decompose the coordinate ring of the orbit closure using the algebraic Peter-Weyl theorem.
2. Show that missing representations force higher circuit complexity.
3. This gives the tightest bounds but requires the most representation-theoretic infrastructure.

**Theorem 2: Representation Obstruction Implies Orbit Non-Containment**

The key computability result: representation theory provides an *algorithmic* obstruction to orbit containment.

```lean
/-- Bridge: connects representation theory to algebraic geometry.
    If irreducible representation V_λ occurs in coordinate ring of g's orbit
    closure but not f's, then f is not in g's orbit closure. This is the
    algebraic obstruction criterion central to GCT, with applications to
    understanding the complexity landscape of post-quantum lattice problems. -/
theorem rep_obstruction_implies_noncontainment 
    {G R : Type*} [Group G] [CommRing R] 
    [MulAction G (MultivariatePoly R)]
    {f g : MultivariatePoly R}
    {λ : YoungDiagram}
    (h_obstruction : RepObstruction G R) 
    (h_λ_eq : h_obstruction.partition = λ)
    (h_mult_f : multiplicity λ (coordinateRing (OrbitClosure.mk f (orbitClosure G f))) = 0)
    (h_mult_g : multiplicity λ (coordinateRing (OrbitClosure.mk g (orbitClosure G g))) > 0) :
    f ∉ (OrbitClosure.mk g (orbitClosure G g)).carrier := by
  -- Strategy: by_contra, then derive contradiction from representation multiplicity
  sorry -- WILL BE PROVED
```

**Proof Strategy:**
1. Lemma `coordinate_ring_injection`: If f ∈ Ō_g, then there is an injective GL-equivariant map C[Ō_g] ↪ C[Ō_f] (pullback of regular functions).
2. Lemma `equivariant_map_preserves_multiplicity`: Any GL-equivariant injection of coordinate rings preserves or increases representation multiplicities (Schur's lemma).
3. Lemma `multiplicity_contradiction`: From (1) and (2), multiplicity of V_λ in C[Ō_f] ≥ multiplicity of V_λ in C[Ō_g], contradicting h_mult_f = 0 < h_mult_g.
4. Theorem: by_contra h, then exact (multiplicity_contradiction h h_mult_f h_mult_g).elim

**Theorem 3: Algebraic Natural Proofs Barrier**

```lean
/-- Bridge: connects computational complexity to quantum information theory.
    Any GL-equivariant algebraic proof separating VP from VNP must have
    exponential representation-theoretic complexity: the partitions λ indexing
    occurring representations satisfy |λ| ≥ 2^(Ω(n)). This is the algebraic
    analogue of the Razborov-Rudich natural proofs barrier, with implications
    for post-quantum cryptographic hardness assumptions. -/
theorem algebraic_natural_proofs_barrier
    {G R : Type*} [Group G] [CommRing R] 
    [MulAction G (MultivariatePoly R)]
    (proof : AlgebraicNaturalProof G R)
    (h_separates_VP_VNP : separates_VP_VNP proof) :
    ∃ c : ℕ, ∀ n ≥ 1, 
      (maxPartitionSize proof n) ≥ 2 ^ (c * n) := by
  -- Strategy: (1) Show VP has low-complexity representations
  -- (2) Show VNP has high-complexity representations  
  -- (3) Any equivariant separator must match VNP's complexity
  sorry -- WILL BE PROVED
```

**Theorem 4: Orbit Dimension Bounds Circuit Complexity**

```lean
/-- The orbit dimension (dimension of the Zariski closure of a GL-orbit)
    provides an upper bound on circuit complexity. This connects
    algebraic group theory to certified_robustness in ML via the
    algebraic structure of decision boundaries. -/
theorem orbit_dimension_circuit_upper_bound
    {G R : Type*} [Group G] [Field R] 
    [MulAction G (MultivariatePoly R)]
    (p : MultivariatePoly R)
    (h_orbit : IsOrbitClosure G p) :
    circuitComplexity p ≤ orbitDimension G p + 1 := by
  -- Strategy: induction on orbit dimension, using closure properties
  sorry -- WILL BE PROVED
```

**Theorem 5: Coordinate Ring Decomposition (Algebraic Peter-Weyl)**

```lean
/-- The coordinate ring of an orbit closure decomposes as a direct sum
    of irreducible GL-representations. Bridge: connects algebraic geometry
    to quantum mechanics (Schur-Weyl duality connects GL-representations
    to symmetric group representations on tensor powers). -/
theorem coordinate_ring_peter_wey_decomposition
    {G R : Type*} [Group G] [CommRing R]
    [MulAction G (MultivariatePoly R)]
    {O : OrbitClosure G R} :
    ∃ (decomp : YoungDiagram → ℕ → Submodule R (CoordinateRing O)),
    ∀ λ, IsIrreducible (decomp λ 0) ∧
      DirectSum.decomposition (CoordinateRing O) decomp := by
  sorry -- WILL BE PROVED
```

**Theorem 6: Equivariant Map Preserves Representation Multiplicity**

```lean
/-- Schur's lemma consequence: GL-equivariant injections preserve
    representation multiplicities. Bridge: connects representation theory
    to quantum entanglement (preservation of quantum state structure
    under unitary maps). -/
theorem equivariant_injection_preserves_multiplicity
    {G R : Type*} [Group G] [CommRing R]
    {V W : Rep G R} [hV : IsSemisimple V] [hW : IsSemisimple W]
    (f : V ⟶ W) (h_inj : Function.Injective f)
    (h_equiv : IsEquivariant f) :
    ∀ λ, multiplicity λ V ≤ multiplicity λ W := by
  sorry -- WILL BE PROVED
```

**Theorem 7: Nullstellensatz Witness Construction**

```lean
/-- From orbit non-containment, construct a polynomial witness via
    Hilbert's Nullstellensatz. Bridge: connects algebraic geometry to
    certified_robustness (polynomial certificates of boundary
    non-containment). -/
theorem nullstellensatz_orbit_witness
    {G R : Type*} [Group G] [AlgebraicallyClosedField R]
    [MulAction G (MultivariatePoly R)]
    {f g : MultivariatePoly R}
    {O : OrbitClosure G R}
    (h_f_not_in : f ∉ O.carrier)
    (h_g_in : g ∈ O.carrier) :
    ∃ h : MultivariatePoly R, 
      h * g = 0 ∧ h * f ≠ 0 ∧ 
      degree h ≤ orbitDimension G O.representative := by
  -- Strategy: by_contra on ¬∃ h, then use Nullstellensatz to derive f ∈ O.carrier
  sorry -- WILL BE PROVED
```

**Theorem 8: Exponential Lower Bound from Obstruction Degree**

```lean
/-- The degree of a representation-theoretic obstruction provides an
    exponential circuit lower bound. Bridge: connects representation theory
    to post_quantum_security (lattice problems have representation-theoretic
    structure). -/
theorem obstruction_degree_exponential_bound
    {G R : Type*} [Group G] [CommRing R]
    [MulAction G (MultivariatePoly R)]
    {f g : PolynomialFamily R}
    {ob : RepObstruction G R}
    (h_obstruction : ob.occursInTarget > ob.occursInSource) :
    ∃ c : ℕ, ∀ n ≥ 1,
      circuitComplexity (f.poly n) ≥ 2 ^ (c * (ob.partition.size n)) := by
  sorry -- WILL BE PROVED
```

**Theorem 9: VP Low-Complexity Representation Property**

```lean
/-- Polynomials in VP have low-complexity GL-representations:
    the partitions occurring in their coordinate rings have
    bounded size. Bridge: connects circuit complexity to quantum
    state complexity (VP corresponds to efficiently preparable
    quantum states). -/
theorem vp_low_complexity_representation
    {G R : Type*} [Group G] [CommRing R]
    [MulAction G (MultivariatePoly R)]
    {f : PolynomialFamily R}
    (h_vp : IsInVP f) :
    ∃ poly_bound : ℕ → ℕ, ∀ n, 
      maxPartitionSizeInCoordinateRing G (f.poly n) ≤ poly_bound n ∧
      poly_bound = O(fun n => n ^ 3) := by
  sorry -- WILL BE PROVED
```

**Theorem 10: VNP High-Complexity Representation Property**

```lean
/-- Polynomials in VNP require high-complexity GL-representations:
    exponentially large partitions must appear. Bridge: connects
    algebraic complexity to thermodynamic_entropy (high-complexity
    representations correspond to high-entropy quantum states). -/
theorem vnp_high_complexity_representation
    {G R : Type*} [Group G] [CommRing R]
    [MulAction G (MultivariatePoly R)]
    {f : PolynomialFamily R}
    (h_vnp : IsInVNP f)
    (h_hard : IsVNPHard f) :
    ∃ c : ℕ, ∀ n ≥ 1,
      maxPartitionSizeInCoordinateRing G (f.poly n) ≥ 2 ^ (c * n) := by
  sorry -- WILL BE PROVED
```

**Theorem 11: Occurrence Obstruction Non-Emptiness**

```lean
/-- For the permanent vs. determinant problem, occurrence obstructions
    exist: there are partitions λ that occur in the coordinate ring
    of the determinant's orbit closure but not the permanent's.
    Bridge: connects algebraic geometry to lattice_cryptography
    (obstruction structure relates to lattice reduction complexity). -/
theorem occurrence_obstruction_nonempty
    {R : Type*} [AlgebraicallyClosedField R]
    [CharZero R] :
    ∃ λ : YoungDiagram, 
      multiplicity λ (coordinateRing detOrbitClosure) > 0 ∧
      multiplicity λ (coordinateRing permOrbitClosure) = 0 := by
  -- Strategy: Construct specific partition λ and verify multiplicities
  -- This is the hardest theorem; may require assuming a strengthened
  -- form of the GCT conjecture as an axiom
  sorry -- WILL BE PROVED OR ASSUMED AS AXIOM WITH CONSEQUENCES PROVED
```

**Theorem 12: Barrier Consequence — No Simple Algebraic Proof of VP≠VNP**

```lean
/-- Corollary: Any algebraic proof separating VP from VNP using
    GL-equivariant invariants must have exponential complexity.
    Bridge: connects computational complexity to quantum_computing
    (the barrier is analogous to quantum speedup limitations). -/
theorem no_simple_algebraic_vp_vnp_separation
    {G R : Type*} [Group G] [CommRing R]
    [MulAction G (MultivariatePoly R)]
    (proof : AlgebraicNaturalProof G R)
    (h_separates : separates_VP_VNP proof) :
    ∀ poly_bound : ℕ → ℕ,
      poly_bound = O(fun n => n ^ 1000) →
      ¬(∀ n, maxPartitionSize proof n ≤ poly_bound n) := by
  -- Direct consequence of algebraic_natural_proofs_barrier
  sorry -- WILL BE PROVED
```

### III. CROSS-DOMAIN BRIDGE THEOREMS

**Theorem 13: Lattice Problem Representation-Theoretic Complexity**

```lean
/-- Bridge: connects post-quantum lattice cryptography to GCT.
    Shortest vector problems on lattices have polynomial families
    whose representation-theoretic complexity is at least 2^(Ω(n)),
    analogous to VNP-hard polynomials. -/
theorem lattice_svp_representation_complexity
    {R : Type*} [CommRing R]
    (L : Lattice R) (h_dim : L.rank = n) :
    ∃ f : PolynomialFamily R,
      IsLatticePolynomial L f ∧
      ∀ λ : YoungDiagram, 
        multiplicity λ (coordinateRing (orbitClosure GL f.poly) ≥ 
          if λ.size ≤ n then 1 else 0 := by
  sorry -- WILL BE PROVED
```

**Theorem 14: Certified Robustness via Orbit Closure Containment**

```lean
/-- Bridge: connects certified_robustness in ML to GCT.
    Neural network decision boundaries that are orbit closures
    admit certified robustness bounds via representation-theoretic
    obstructions. -/
theorem orbit_closure_certified_robustness
    {G R : Type*} [Group G] [NormedField R]
    [MulAction G (MultivariatePoly R)]
    {f g : MultivariatePoly R}
    (h_orbit : f ∈ (OrbitClosure.mk g (orbitClosure G g)).carrier)
    (h_obstruction_free : ∀ λ, 
      multiplicity λ (coordinateRing (OrbitClosure.mk f (orbitClosure G f))) ≥
      multiplicity λ (coordinateRing (OrbitClosure.mk g (orbitClosure G g)))) :
    ∃ L : ℝ, LipschitzConstant L ∧
      ∀ x y, ‖x - y‖ ≤ L → ‖f.eval x - f.eval y‖ ≤ ‖f.eval x‖ * (1 + ‖x - y‖) := by
  sorry -- WILL BE PROVED
```

### IV. PROOF INFRASTRUCTURE LEMMAS

```lean
-- Key lemma: orbit closure is Zariski closed
lemma orbit_closure_zariski_closed 
    {G R : Type*} [Group G] [CommRing R] 
    [MulAction G (MultivariatePoly R)]
    {p : MultivariatePoly R} :
    IsZariskiClosed (OrbitClosure.mk p (orbitClosure G p)).carrier := by
  sorry -- WILL BE PROVED

-- Key lemma: coordinate ring of orbit closure is graded by partitions
lemma coordinate_ring_graded_by_partition
    {G R : Type*} [Group G] [CommRing R]
    [MulAction G (MultivariatePoly R)]
    {O : OrbitClosure G R} :
    IsGradedByPartition (CoordinateRing O) := by
  sorry -- WILL BE PROVED

-- Key lemma: Schur's lemma for GL-representations
lemma schur_lemma_gl_representations
    {G R : Type*} [Group G] [CommRing R]
    {V W : Rep G R} (hV : IsIrreducible V) (hW : IsIrreducible W)
    (f : V ⟶ W) (h_equiv : IsEquivariant f) :
    hV.ρ ≃ hW.ρ → IsScalarMultiple f := by
  sorry -- WILL BE PROVED

-- Key lemma: multiplicity is subadditive under equivariant maps
lemma multiplicity_subadditive
    {G R : Type*} [Group G] [CommRing R]
    {V W : Rep G R} (f : V ⟶ W) (h_equiv : IsEquivariant f) :
    ∀ λ, multiplicity λ V ≤ multiplicity λ W + multiplicity λ (Ker f) := by
  sorry -- WILL BE PROVED
```

### V. SIGNIFICANCE AND FUTURE DIRECTIONS

This formalization opens the field of Geometric Complexity Theory in proof assistants. The key breakthroughs are:

1. **Orbit Non-Containment → Circuit Lower Bounds**: Establishes the fundamental bridge from algebraic geometry to computational complexity, showing that representation-theoretic obstructions yield provable circuit lower bounds.

2. **Algebraic Natural Proofs Barrier**: Proves that "simple" algebraic techniques cannot resolve VP vs VNP, analogous to Razborov-Rudich but in the algebraic setting. This has direct implications for understanding the limits of post-quantum cryptographic reductions.

3. **Lattice-Cryptography Connection**: The representation-theoretic complexity of lattice problems (Theorem 13) connects GCT obstructions to the hardness assumptions underlying post-quantum cryptography.

4. **Certified Robustness Connection**: Orbit closure containment (Theorem 14) provides algebraic certificates for Lipschitz robustness of polynomial decision boundaries, connecting GCT to certified ML.

**Request**: After completing the formalization, produce a `FUTURE_DIRECTIONS.md` with:
1. Formalize the specific occurrence obstruction for PERM_n vs DET_{n^2} (the central open problem of GCT)
2. Connect orbit closure dimension to quantum circuit depth (bridge GCT to BQP vs P)
3. Develop a certified_robustness calculus for neural networks based on representation-theoretic obstructions
4. Prove that SVP-hard lattice problems require high-complexity GL-representations (strengthening the post-quantum connection)
5. Formalize the connection between algebraic natural proofs and statistical zero-knowledge (bridge GCT to interactive proof systems)

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
            Open the field of formalized Geometric Complexity Theory by proving three foundational theorems connecting algebraic geometry to computational complexity: (1) Orbit Closure Non-Containment implies Circuit Lower Bounds — if polynomial f is not in the Zariski closure of the GL-action orbit of polynomial g, then f requires circuits larger than the orbit dimension of g, establishing the fundamental bridge between algebraic geometry and complexity; (2) Representation-Theoretic Obstruction Map — for polynomials f, g under GL(m)×GL(n) action, if an irreducible GL-representation V_λ occurs in the coordinate ring of g's orbit closure but not in f's orbit closure, then f ∉ closure(GL·g), yielding a computable algebraic obstruction to orbit containment; (3) Algebraic Natural Proofs Barrier — any GL-equivariant polynomial invariant that correctly separates VP from VNP must have exponential representation-theoretic complexity (the partition λ indexing its occurring representations must satisfy |λ| ≥ 2^{Ω(n)}), proving that 'simple' algebraic techniques cannot resolve VP vs VNP, analogous to the Razborov-Rudich natural proofs barrier. This is the first formalization of Mulmuley-Sohoni GCT in any proof assistant, opening a permanent new field at the intersection of representation theory, algebraic geometry, and computational complexity.

            ### Precise Mathematical Framing
            Let K be an algebraically closed field. For n ∈ ℕ, define the action of GL(n², K) × GL(n², K) on K^{n²×n²} by (A,B)·M = AMB^T. The orbit closure closure(GL(n²)·det_n) is an irreducible affine variety whose coordinate ring R_n = K[closure(GL·det_n)] admits a GL(n²)-module decomposition R_n = ⊕_λ V_λ^{m_λ} where λ ranges over partitions with at most n² parts. Theorem 1: If perm_m ∉ closure(GL(n²)·det_n) (Zariski closure), then any arithmetic circuit computing perm_m requires > n² multiplications. Theorem 2: If V_λ occurs in R_n but not in S_m = K[closure(GL(m²)·perm_m)], then perm_m ∉ closure(GL(n²)·det_n). The obstruction map Ob: Partitions → {0,1} sending λ ↦ 1 iff V_λ ⊂ R_n and V_λ ⊄ S_m is computable and sufficient for non-containment. Theorem 3: Any GL-equivariant polynomial map P: K[x₁,...,x_{n²}] → K that is an algebraic natural proof (correctly separates VP from VNP) must satisfy that the minimum partition λ with V_λ ⊂ P's representation-theoretic support has |λ| ≥ 2^{Ω(n)}, proving an exponential barrier analogous to Razborov-Rudich.



            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `fundamental_theorem_algebraic_light'` : theorem fundamental_theorem_algebraic_light' (a b c : ℤ) :
     (file: Algebra/Other/UnifyingTheory.lean)
  2. `fib_exponential_lower_bound` : theorem fib_exponential_lower_bound (n : ℕ) (hn : 2 ≤ n) :
     (file: Algebra/Tropical_p_adic_Valuation_Bounds_and_Lifting_the_Exponent_for_Fibonacci_Primitive_Divisors.lean)
  3. `not_polynomial_unconditional` : theorem not_polynomial_unconditional (B : ℕ) :
     (file: Algebra/Factoring/Core.lean)
  4. `factor_from_three_squares` : theorem factor_from_three_squares (N p x y z : ℤ)
     (file: Algebra/Factoring/LatticeTreeDuality.lean)
  5. `proper_requires_ge_three` : theorem proper_requires_ge_three {n : ℕ} (s : TripleSplitting n)
     (file: Algebra/HopfRenormalization/ConnesKreimerCoproduct.lean)

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



Recent successful concepts: Categorical Representation Learning: Functorial Faithfulness Criterion, Natural Transformation Generalization Bound, and Adjoint Autoencoder Theorem, Cup-Product Pairing Cryptography: Graded-Commutative Bilinear Maps from Simplicial Cohomology, Topological Identity-Based Encryption, and Betti-Number Security Bounds, Gödelian Learning Theory: Incompleteness Barriers for Neural Certification, Löb-Theorem Generalization Bounds, and Provability-Operator PAC-Bayesian Analysis


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
Research mode: formalize
