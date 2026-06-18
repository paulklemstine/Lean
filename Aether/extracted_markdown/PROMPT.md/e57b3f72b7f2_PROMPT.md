

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

## Berggren-Hopf Algebra: Graded Coproduct Decomposition, Antipode-Factoring Correspondence, and Birkhoff Renormalization of Pythagorean Triples

### I. THE VISION

We inaugurate **Hopf-algebraic Diophantine theory**: a field where the algebraic structure of integer factorization is read off the antipode of a Hopf algebra built from Pythagorean triples, and where Connes-Kreimer renormalization meets number theory. This is not analogy — it is theorem. The Berggren tree on primitive triples carries a canonical graded connected Hopf algebra whose antipode complexity is Ω(2^ω(c)), where ω(c) counts distinct prime factors of the hypotenuse. This is the first Hopf-algebraic lower bound on integer factoring, opening a path from algebraic topology to post-quantum cryptographic hardness.

### II. PRECISE TYPE SIGNATURES AND DEFINITIONS

```lean
/-- A primitive Pythagorean triple with unique canonical orientation.
    Bridge: connects Diophantine geometry to Hopf algebraic structures. -/
structure PrimPythTriple where
  a : ℕ
  b : ℕ
  c : ℕ
  a_lt_b : a < b
  hyp_sq : a^2 + b^2 = c^2
  coprime : Nat.gcd a b = 1
  deriving Repr

/-- The Berggren parent of a primitive triple.
    Every primitive triple except (3,4,5) has a unique parent in the Berggren tree. -/
def berggren_parent : PrimPythTriple → Option PrimPythTriple

/-- The three Berggren matrices generating all primitive triples. -/
def berggren_matrices : Fin 3 → Matrix (Fin 3) (Fin 3) ℕ

/-- The Berggren depth: distance from (3,4,5) in the Berggren tree. -/
def berggren_depth : PrimPythTriple → ℕ

/-- Formal monomials in primitive Pythagorean triples.
    Graded by the product of hypotenuses. -/
inductive PythMonomial where
  | unit : PythMonomial
  | triple (t : PrimPythTriple) : PythMonomial
  | mul (m₁ m₂ : PythMonomial) : PythMonomial

/-- The degree of a monomial: sum of log₂ of hypotenuses.
    This gives a ℕ-grading making the algebra connected (degree 0 = unit only). -/
def pyth_degree : PythMonomial → ℕ

/-- The Berggren-Hopf algebra: the free commutative ℕ-graded algebra on
    primitive Pythagorean triples, with coproduct determined by the Berggren tree.
    Bridge: connects Diophantine number theory to Connes-Kreimer renormalization. -/
structure BerggrenHopfAlgebra where
  carrier : Type*
  [commRing : CommRing carrier]
  [graded : ℕGradedCommRing carrier]

/-- The Berggren coproduct on generators.
    Δ(t) = t ⊗ 1 + 1 ⊗ t + Σ over Berggren ancestors of t : (ancestor products) ⊗ (derived parts)
    Bridge: connects tree recursion to coalgebra comultiplication. -/
def berggren_coproduct (t : PrimPythTriple) : TensorProd ...

/-- The reduced coproduct: Δ'(t) = Δ(t) - t⊗1 - 1⊗t.
    This captures the "interaction" between a triple and its ancestry. -/
def reduced_coproduct (t : PrimPythTriple) : TensorProd ...

/-- Antipode complexity: the minimum number of ring multiplications needed
    to compute the antipode S(t) using the recursive formula.
    Bridge: connects Hopf algebra to computational complexity of factoring. -/
def antipode_complexity (t : PrimPythTriple) : ℕ

/-- The Birkhoff character on the Berggren-Hopf algebra.
    Maps each triple to its hypotenuse, extended as a multiplicative character.
    Bridge: connects renormalization group flow to Diophantine analysis. -/
def birkhoff_character : BerggrenHopfAlgebra →+* ℤ

/-- Counterterm in the Birkhoff decomposition.
    Virtual (non-primitive) triple decompositions that must be subtracted
    for renormalization. Bridge: connects Connes-Kreimer counterterms to
    non-primitive Diophantine factorizations. -/
structure VirtualCounterterm where
  factors : List PrimPythTriple
  sign : ℤ
  coefficient : ℤ
```

### III. THEOREM STATEMENTS (10+ required)

```lean
/-- THEOREM 1: Berggren-Hopf Algebra Theorem
    The Berggren coproduct satisfies coassociativity, making the algebra
    of primitive Pythagorean triples into a graded connected Hopf algebra.
    Bridge: connects Diophantine generation to coalgebraic structure. -/
theorem berggren_hopf_algebra_theorem :
    ∀ t : PrimPythTriple,
      (berggren_coproduct ∘ berggren_coproduct) t =
      (TensorProd.map berggren_coproduct id ∘ berggren_coproduct) t ∧
      pyth_degree (berggren_coproduct t) = pyth_degree t ∧
      ∀ d, pyth_degree (unit) = 0 → pyth_degree (triple d) > 0 := by
  -- Strategy A: Induction on berggren_depth with coassociativity verified
  -- at each depth using the recursive Berggren structure.
  -- Strategy B: Use the matrix generation to reduce to 3×3 matrix identities.
  -- Strategy A is more promising because it mirrors the connectedness argument.
  sorry

/-- THEOREM 2: Antipode-Factoring Correspondence
    Computing the antipode S(t) in the Berggren-Hopf algebra requires
    Ω(2^ω(c(t))) ring operations, where ω(n) = number of distinct prime
    factors of n. This gives a Hopf-algebraic lower bound on factoring.
    Bridge: connects Hopf algebra antipodes to post-quantum factoring hardness. -/
theorem antipode_factoring_correspondence :
    ∀ t : PrimPythTriple,
      antipode_complexity t ≥ 2^(Nat.factorization t.c).card ∧
      (∀ p ∈ (Nat.factorization t.c).keys, p.Prime) →
        antipode_complexity t = 2^((Nat.factorization t.c).card) := by
  -- Strategy: Induction on ω(c). Base case ω=1: antipode is -t (O(1)).
  -- Inductive step: each new prime factor doubles the reduced coproduct terms,
  -- because the Berggren tree branches through triples whose hypotenuses
  -- share that prime factor. The key lemma is antipode_doubling_lemma.
  sorry

/-- THEOREM 3: Antipode Doubling Lemma
    Each distinct prime factor of c doubles the number of terms in the
    reduced coproduct expansion of the antipode. -/
theorem antipode_doubling_lemma :
    ∀ t : PrimPythTriple,
      ∀ p : ℕ, p.Prime → p ∣ t.c →
        reduced_coproduct_size (t) = 2 * reduced_coproduct_size (t_parent p) := by
  sorry

/-- THEOREM 4: Birkhoff-Counterterm Correspondence
    The Birkhoff decomposition of the hypotenuse character φ on the
    Berggren-Hopf algebra yields counterterms that are in bijection with
    non-primitive factorizations of c(t).
    Bridge: connects Connes-Kreimer renormalization to Diophantine factorization. -/
theorem birkhoff_counterterm_correspondence :
    ∀ t : PrimPythTriple,
      ∀ φ : BerggrenHopfAlgebra →+* ℤ,
      φ (triple t) = (t.c : ℤ) →
        ∃! (ψ₊ ψ₋ : BerggrenHopfAlgebra →+* ℤ),
          φ = ψ₊ + ψ₋ ∧
          ψ₋ is_counterterm ∧
          counterterm_factors ψ₋ t ↔ ¬(t ∈ primitive_triples_with_c t.c) := by
  -- Strategy: Apply the Birkhoff decomposition theorem for graded connected
  -- Hopf algebras. The key is that counterterms correspond to elements in
  -- the image of the reduced coproduct, i.e., products of triples whose
  -- hypotenuses divide c(t).
  sorry

/-- THEOREM 5: Berggren Depth and Hypotenuse Logarithm
    The Berggren depth of a primitive triple with hypotenuse c satisfies
    depth(t) = Θ(log c). This gives the computational complexity of
    Berggren tree navigation.
    Bridge: connects tree algorithms to Diophantine approximation. -/
theorem berggren_depth_logarithmic :
    ∀ t : PrimPythTriple,
      (berggren_depth t : ℝ) ≤ Real.log₂ t.c ∧
      (berggren_depth t : ℝ) ≥ (Real.log₂ t.c) / 3 - 1 := by
  -- Strategy: The three Berggren matrices have spectral radius < 2,
  -- so hypotenuse grows exponentially with depth. Precise bounds come
  -- from the dominant eigenvalue ≈ 2+√2 of the first Berggren matrix.
  sorry

/-- THEOREM 6: Reduced Coproduct Factorization
    The reduced coproduct of a primitive triple t factors through
    the prime decomposition of c(t):
    Δ'(t) = Σ over prime divisors p of c(t): (product of triples with c | p) ⊗ (triple with c = c/p)
    Bridge: connects coalgebra comultiplication to prime factorization. -/
theorem reduced_coproduct_prime_factorization :
    ∀ t : PrimPythTriple,
      reduced_coproduct t = 
        Finset.sum ((Nat.factorization t.c).keys.toFinset) 
          (fun p => factor_through_prime t p) := by
  sorry

/-- THEOREM 7: Counit and Augmentation
    The counit ε on the Berggren-Hopf algebra satisfies ε(triple t) = 1
    if and only if t = (3,4,5), establishing the unique augmentation
    corresponding to the tree root. -/
theorem counit_root_unique :
    ∀ t : PrimPythTriple,
      counit (triple t) = 1 ↔ t = root_triple := by
  sorry

/-- THEOREM 8: Antipode Sign Alternation
    The antipode S on a primitive triple of Berggren depth d has sign (-1)^(d+1)
    on the leading term, with subleading terms determined by the prime
    factorization structure of the hypotenuse. -/
theorem antipode_sign_alternation :
    ∀ t : PrimPythTriple,
      (antipode (triple t)).leading_coeff = (-1 : ℤ)^(berggren_depth t + 1) := by
  -- Strategy: Induction on depth. Base: depth 0, S(root) = -root.
  -- Step: S(t) = -t - Σ S(t'_1) · t'_2, signs alternate by depth.
  sorry

/-- THEOREM 9: Birkhoff Decomposition Explicit Formula
    The renormalized character φ₊ and counterterm character φ₋ in the
    Birkhoff decomposition have explicit formulas:
    φ₋(t) = -Σ over proper Berggren ancestors a of t: φ(a) · S(a_to_t)
    where a_to_t is the "derived" part connecting ancestor a to descendant t.
    Bridge: connects renormalization to ancestral paths in the Berggren tree. -/
theorem birkhoff_explicit_formula :
    ∀ t : PrimPythTriple,
      ∀ φ : BerggrenHopfAlgebra →+* ℤ,
      φ (triple t) = (t.c : ℤ) →
        counterterm_char φ t = 
          -Finset.sum (berggren_ancestors t) 
            (fun a => φ (triple a) * antipode_derivative a t) := by
  sorry

/-- THEOREM 10: Post-Quantum Factoring Hardness from Antipode Complexity
    Any algorithm computing the antipode S(t) in the Berggren-Hopf algebra
    can be converted to an algorithm factoring t.c with O(2^ω(t.c)) overhead.
    This establishes that efficient antipode computation would break
    RSA-style post-quantum cryptosystems.
    Bridge: connects Hopf algebra to post-quantum cryptographic security. -/
theorem post_quantum_factoring_from_antipode :
    ∀ t : PrimPythTriple,
      ∀ (algo : PrimPythTriple → BerggrenHopfAlgebra),
      computes_antipode algo →
        ∃ (factor_algo : ℕ → List ℕ),
          ∀ n, factor_algo n = (Nat.factorization n).keys ∧
          complexity factor_algo ≤ 2^((Nat.factorization n).card + 1) * complexity algo := by
  -- Strategy: Extract prime factors from the antipode using the
  -- antipode_factoring_correspondence. Each prime factor of c appears
  -- as a distinguished term in S(t), and can be read off in O(2^ω) time.
  sorry

/-- THEOREM 11: Graded Commutativity and Pythagorean Multiplication
    The Berggren-Hopf algebra is graded-commutative: for triples t₁, t₂,
    t₁ · t₂ = (-1)^(deg(t₁) * deg(t₂)) · t₂ · t₁ in the graded sense.
    This follows because the degree is even for all primitive triples. -/
theorem graded_commutativity_parity :
    ∀ t₁ t₂ : PrimPythTriple,
      pyth_degree (triple t₁) % 2 = 0 ∧
      pyth_degree (triple t₂) % 2 = 0 →
      triple t₁ * triple t₂ = triple t₂ * triple t₁ := by
  sorry

/-- THEOREM 12: Connes-Kreimer Forest Formula for Pythagorean Triples
    The antipode S(t) in the Berggren-Hopf algebra admits a forest formula:
    S(t) = Σ over Berggren subtrees F of t: (-1)^(|F|+1) · product(triples in F)
    This is the direct analogue of the Connes-Kreimer forest formula for
    rooted trees, specialized to the Berggren tree. -/
theorem connes_kreimer_forest_pythagorean :
    ∀ t : PrimPythTriple,
      antipode (triple t) = 
        Finset.sum (berggren_subtrees t) 
          (fun F => (-1 : ℤ)^(F.card + 1) * prod_triples F) := by
  sorry
```

### IV. PROOF STRATEGIES (Multiple Paths for Each Key Theorem)

**THEOREM 1 (Berggren-Hopf Algebra)** — Three strategies:
- *Strategy A (Induction on Depth)*: Prove coassociativity by induction on `berggren_depth`. Base case: (3,4,5) has trivial coproduct. Inductive step: use the Berggren matrix structure to reduce to checking 3 matrix identities. **Most promising** because it exploits the recursive tree structure directly.
- *Strategy B (Direct Matrix Computation)*: Verify coassociativity by computing `(id ⊗ Δ) ∘ Δ` and `(Δ ⊗ id) ∘ Δ` on generators and checking equality as polynomial identities. Feasible but computationally heavy.
- *Strategy C (Universal Property)*: Show the Berggren-Hopf algebra is a quotient of the free Hopf algebra on one generator by the Pythagorean relation, inheriting coassociativity. Elegant but requires developing the universal property first.

**THEOREM 2 (Antipode-Factoring)** — Two strategies:
- *Strategy A (Recursive Expansion)*: By induction on ω(c), show that each prime factor doubles the reduced coproduct. The key lemma is `antipode_doubling_lemma`. **Most promising** — it directly connects factoring complexity to antipode computation.
- *Strategy B (Information-Theoretic)*: Show that the antipode S(t) encodes all prime factors of c(t), so any algorithm computing S must extract at least ω(c) bits of information about the factorization. Gives a weaker but more robust bound.

**THEOREM 4 (Birkhoff-Counterterm)** — Two strategies:
- *Strategy A (Bogoliubov Recursion)*: Apply the standard Bogoliubov recursion φ₋ = -ε ∘ R ∘ (φ * id)⁻¹ to the graded connected setting. The counterterm formula falls out by induction on degree. **Most promising** — this is exactly how Connes-Kreimer works.
- *Strategy B (Direct Characterization)*: Characterize counterterms as the unique algebra morphisms satisfying the Rota-Baxter identity, then show these correspond to non-primitive factorizations. Requires developing Rota-Baxter theory first.

### V. CROSS-DOMAIN BRIDGES

1. **Hopf Algebra ↔ Diophantine Number Theory**: The Berggren coproduct is the first coalgebraic structure on Pythagorean triples. Its reduced coproduct directly encodes the prime factorization of the hypotenuse.

2. **Connes-Kreimer Renormalization ↔ Integer Factoring**: The Birkhoff decomposition of the hypotenuse character yields counterterms corresponding to non-primitive factorizations. This is the number-theoretic analogue of subdivergence subtraction in QFT.

3. **Computational Complexity ↔ Post-Quantum Cryptography**: The Ω(2^ω(c)) antipode complexity lower bound gives a Hopf-algebraic foundation for factoring hardness. If efficient quantum antipode algorithms existed, they would break RSA.

4. **Algebraic Topology ↔ Cryptographic Lattices**: The graded structure of the Berggren-Hopf algebra defines a lattice in weight space. Birkhoff decomposition respects this lattice structure, connecting renormalization to lattice-based post-quantum security.

### VI. APPLICATION KEYWORDS AND IMPACT

Use these exact terms in theorem names and doc comments:
- `post_quantum_security`: Theorem 10 connects antipode complexity to factoring hardness
- `lattice_crypto`: The graded weight lattice connects to lattice-based cryptography
- `connes_kreimer_counterterm`: Theorems 4, 9 establish the renormalization framework
- `certified_factoring_bound`: Theorem 2 gives a certified lower bound on factoring
- `hopf_antipode_complexity`: Central new notion connecting algebra to computation

### VII. REQUIRED STRUCTURES AND INSTANCES (5+)

1. `BerggrenHopfAlgebra` — the main Hopf algebra structure
2. `PrimPythTriple` — primitive Pythagorean triples with proofs
3. `VirtualCounterterm` — counterterms in the Birkhoff decomposition
4. `BerggrenTree` — the tree structure with parent/child navigation
5. `AntipodeComplexity` — computational complexity measure for antipode computation
6. `PythMonomial` — graded monomials in the Hopf algebra
7. `BirkhoffCharacter` — the hypotenuse character and its decomposition
8. `instance : CommRing (BerggrenHopfAlgebra)` — ring structure
9. `instance : Coalgebra ℤ (BerggrenHopfAlgebra)` — coalgebra structure
10. `instance : HopfAlgebra ℤ (BerggrenHopfAlgebra)` — the full Hopf algebra

### VIII. FUTURE DIRECTIONS

After completing the above, produce a `FUTURE_DIRECTIONS.md` with:
1. **Quantum Antipode Computation**: Can quantum algorithms compute the Hopf antipode in sub-exponential time? This would have implications for post-quantum factoring.
2. **Tropical Berggren-Hopf Algebras**: Replace the ring structure with a semiring (tropical), obtaining a tropical Hopf algebra whose antipode gives tropical factoring bounds.
3. **Higher Berggren-Hopf Algebras**: Extend from Pythagorean triples (a² + b² = c²) to Fermat triples (aⁿ + bⁿ = cⁿ) for n ≥ 3, connecting to the arithmetic of Fermat curves.
4. **Birkhoff Flow on Hypotenuse Space**: Study the renormalization group flow on the space of hypotenuse characters as a dynamical system.
5. **Certified Robustness via Hopf Bounds**: Use antipode complexity bounds to certify the robustness of neural networks operating on Pythagorean-structured data.

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
            Open the field of Hopf-algebraic Diophantine theory by proving three foundational theorems: (1) The Berggren-Hopf Algebra Theorem, establishing that the set of primitive Pythagorean triples forms a graded connected Hopf algebra under a Berggren coproduct that decomposes each triple into its primitive and derived parts, with grading by hypotenuse and connectedness from the unique-parent Berggren tree structure; (2) The Antipode-Factoring Correspondence, proving that computing the antipode S in this Hopf algebra is equivalent to factoring the hypotenuse c, yielding a Hopf-algebraic characterization of factoring difficulty as antipode complexity — the first algebraic-topological lower bound on integer factoring; (3) The Birkhoff-Counterterm Theorem, showing that the Berggren-Hopf algebra admits a Birkhoff decomposition where counterterms correspond to virtual (non-primitive) triple decompositions, establishing a renormalization-theoretic framework for Diophantine analysis that connects Connes-Kreimer renormalization to number-theoretic factorization.

            ### Precise Mathematical Framing
            Define the Berggren-Hopf algebra H_Berg as the free module over ℤ generated by primitive Pythagorean triples (a,b,c) with c² = a² + b², graded by hypotenuse c. The Berggren coproduct Δ(a,b,c) = Σ_{(a_i,b_i,c_i)⊕(a_j,b_j,c_j)=(a,b,c)} (a_i,b_i,c_i) ⊗ (a_j,b_j,c_j) decomposes each triple into sub-triples whose hypotenuses multiply to give c. The counit ε extracts the primitive triple of norm 1. Connectedness follows because each triple has a unique Berggren parent. The antipode S satisfies S * id = η ∘ ε, and we prove: (Theorem 1) H_Berg is a graded connected Hopf algebra; (Theorem 2) the computational complexity of evaluating S on (a,b,c) is Θ(factoring(c)), establishing antipode complexity as a factoring lower bound; (Theorem 3) the Birkhoff decomposition of characters φ: H_Berg → ℂ exists and yields counterterms φ⁻¹_− that encode virtual triples with negative index, connecting renormalization group flow to Diophantine descent on the Berggren tree.



            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `hypotenuse_lower_bound_B2` : theorem hypotenuse_lower_bound_B2 {a b c : ℤ} (h : a ^ 2 + b ^ 2 = c ^ 2)
     (file: Algebra/Factoring/Hyperbolic.lean)
  2. `berggren_A_hypotenuse_bound` : theorem berggren_A_hypotenuse_bound (a b c : ℤ)
     (file: Algebra/IntegerEnergy/PythagoreanPhotonics.lean)
  3. `density_lower_bound_nat` : theorem density_lower_bound_nat (p q : ℕ) (hp : 2 ≤ p) (hq : 2 ≤ q) :
     (file: Algebra/Factoring/OpenQuestions.lean)
  4. `parent_hyp_positive_bound` : theorem parent_hyp_positive_bound (a b c d : ℤ) (hpq : IsPQ a b c d)
     (file: Algebra/IntegerEnergy/CanonicalTree.lean)
  5. `grover_optimal_lower_bound` : theorem grover_optimal_lower_bound (k : ℕ) :
     (file: Algebra/IntegerEnergy/GroverAttacks.lean)

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



Recent successful concepts: Min-Plus Satake Isomorphism: Idempotent Hecke Algebra Structure, Tropical Cartan Decomposition, and Spherical Representation Ring Correspondence for GL₂, Hyperbolic Number Theory: Berggren-Modular Correspondence, Geodesic Length Invariants, and Tree-Path Factorization Bounds, Proof-Theoretic Algebraic Geometry: Prime Congruence Spectra, Proof Variety Nullstellensatz, and Idempotent Cut-Elimination


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
