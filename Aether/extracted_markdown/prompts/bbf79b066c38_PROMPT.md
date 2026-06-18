

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

## Toric Code as a Chain Complex: Verified Topological Quantum Error Correction via Homological Distance Bounds

**DOMAIN**: Physics → Algebra → Cryptography

**CONCEPT**: Open the field of formalized topological quantum error correction by proving that the torus T² with its canonical L×L CW-decomposition yields a verified F₂-chain complex whose homological distance certifies quantum code parameters [[2L², 2, L]]. This is the first fully machine-verified toric code construction, bridging algebraic topology, quantum physics, and post-quantum coding theory. The key insight: non-trivial homology classes in H₁(T²; F₂) have minimum Hamming weight exactly L, which is simultaneously the quantum code distance, the topological winding number, and a lattice crypto hardness parameter for syndrome decoding.

---

### STRUCTURE DEFINITIONS (5+ required)

```lean
/-- The L×L toric grid: vertices are (Fin L) × (Fin L) with periodic identification -/
structure ToricGrid (L : ℕ) where
  -- L ≥ 2 enforced by a field
  grid_dim : Fin L × Fin L
  deriving DecidableEq

/-- Edges of the toric grid: horizontal and vertical with wraparound -/
inductive ToricEdge (L : ℕ) where
  | hedge : Fin L → Fin L → ToricEdge L  -- horizontal edge at (i,j)
  | vedge : Fin L → Fin L → ToricEdge L  -- vertical edge at (i,j)
  deriving DecidableEq

/-- Faces of the toric grid: one per vertex position -/
def ToricFace (L : ℕ) := Fin L × Fin L

/-- The F₂-chain complex of the toric grid, with explicit boundary maps -/
structure ToricChainComplex (L : ℕ) where
  C₂ : Type  -- := (ToricFace L) → F₂
  C₁ : Type  -- := (ToricEdge L) → F₂  
  C₀ : Type  -- := (Fin L × Fin L) → F₂
  boundary₂ : C₂ → C₁
  boundary₁ : C₁ → C₀
  boundary_comp : ∀ x, boundary₁ (boundary₂ x) = 0

/-- CSS code extracted from the toric chain complex -/
structure ToricCSSCode (L : ℕ) where
  n_qubits : ℕ  -- = 2 * L²
  k_logical : ℕ  -- = 2
  distance : ℕ   -- = L
  x_stabilizers : Finset (C₁)  -- from im ∂₂
  z_stabilizers : Finset (C₁)  -- from ker ∂₁ / im ∂₂ dual
```

---

### KEY THEOREM STATEMENTS (10+ required)

```lean
/-- Bridge: connects algebraic topology to quantum error correction
    The boundary composition vanishes: every face contributes even-edge boundary
    to every vertex on the torus. -/
theorem toric_boundary_sq_zero (L : ℕ) (hL : L ≥ 2) :
    ∀ f : ToricFace L, 
      toric_boundary₁ L (toric_boundary₂ L f) = 0 := by
  -- Each face has 4 edges; each vertex in ∂₁(∂₂(f)) appears exactly twice

/-- Bridge: connects homological algebra to quantum information theory
    The first homology of the toric grid over F₂ has rank 2, yielding exactly
    2 logical qubits for quantum error correction -/
theorem toric_first_homology_rank (L : ℕ) (hL : L ≥ 2) :
    Module.rank (ZMod 2) (toric_homology₁ L) = 2 := by
  -- rank-nullity on ∂₁ and ∂₂ over F₂ with periodic boundary conditions

/-- Bridge: connects topology to combinatorial optimization
    The minimum Hamming weight of any non-trivial homology class equals L,
    establishing the quantum code distance -/
theorem toric_homological_distance_cert (L : ℕ) (hL : L ≥ 2) :
    ∀ h ∈ nontrivial_homology_classes L,
      HammingWeight h ≥ L ∧ 
      ∃ (h₀ : toric_homology₁ L), HammingWeight h₀ = L := by
  -- Lower bound: any non-trivial cycle must wind around torus ≥ L times
  -- Upper bound: horizontal/vertical cycles achieve weight L

/-- Bridge: connects quantum codes to lattice cryptography
    The toric code parameters are [[2L², 2, L]], giving explicit code construction -/
theorem toric_CSS_code_parameters (L : ℕ) (hL : L ≥ 2) :
    (toric_css_code L).n_qubits = 2 * L^2 ∧
    (toric_css_code L).k_logical = 2 ∧
    (toric_css_code L).distance = L := by
  -- Combines homology rank and distance theorems

/-- The toric grid incidence matrices satisfy the chain complex condition -/
theorem toric_incidence_matrices_composition_zero (L : ℕ) (hL : L ≥ 2) :
    (toric_face_edge_incidence L L) * (toric_edge_vertex_incidence L L) = 0 := by
  -- Matrix multiplication over F₂; each column sum is even

/-- Horizontal winding cycle has weight exactly L -/
theorem toric_horizontal_cycle_weight (L : ℕ) (hL : L ≥ 2) :
    HammingWeight (toric_horizontal_cycle L) = L := by
  -- One edge per column, L columns total

/-- Vertical winding cycle has weight exactly L -/
theorem toric_vertical_cycle_weight (L : ℕ) (hL : L ≥ 2) :
    HammingWeight (toric_vertical_cycle L) = L := by
  -- One edge per row, L rows total

/-- Bridge: connects combinatorics to quantum threshold theorems
    The degenerate ground space dimension is 4 = 2^2, certifying 2 logical qubits -/
theorem toric_degenerate_ground_space_dim (L : ℕ) (hL : L ≥ 2) :
    Fintype.card (toric_ground_space L) = 4 := by
  -- 2^k = 2^2 = 4 for k=2 logical qubits

/-- Any non-boundary 1-cycle must wrap around at least one torus direction -/
theorem toric_winding_number_lower_bound (L : ℕ) (hL : L ≥ 2) 
    (c : toric_cycle_space L) (hc : c ∉ toric_boundary_space L) :
    (toric_horizontal_winding c ≥ 1 ∨ toric_vertical_winding c ≥ 1) ∧
    HammingWeight c ≥ L := by
  -- If winding = 0 in both directions, cycle is null-homologous
  -- Minimum edges to achieve winding ≥ 1 is L (must cross entire grid)

/-- Bridge: connects topological quantum memory to post-quantum security
    Syndrome decoding on the toric code is NP-hard for weight < L/2,
    establishing post-quantum security of the homological decoding problem -/
theorem toric_syndrome_decoding_hardness (L : ℕ) (hL : L ≥ 2) :
    ∀ (s : toric_syndrome L), 
      ∃ (e : toric_error L), 
        toric_syndrome_of e = s ∧ HammingWeight e ≤ L/2 →
        -- The unique minimum-weight decoder succeeds iff weight < L/2
        HammingWeight e < L/2 := by
  -- Minimum weight decoder has threshold L/2; below this, correction is unique
```

---

### PROOF STRATEGIES

**Strategy A (Incidence Matrix Computation — Most Direct)**:
1. Define explicit incidence matrices `face_edge_matrix` and `edge_vertex_matrix` over `ZMod 2`
2. Prove each row of `face_edge_matrix` has exactly 4 ones (4 edges per face)
3. Prove `edge_vertex_matrix * face_edge_matrix` = 0 by showing each vertex appears in exactly 0 or 2 boundary edges of each face
4. Use `omega` for the arithmetic and `decide` for the finite verification
5. **Most promising for the ∂²=0 theorem** because it reduces to finite F₂ arithmetic

**Strategy B (Homological Algebra via Snake Lemma — Most Elegant)**:
1. Use the long exact sequence in homology for the pair (T², T² minus disk)
2. Apply rank-nullity over F₂ to get dim H₁ = dim H₀ + dim H₂ - χ(T²) = 1 + 1 - 0 = 2
3. This avoids explicit matrix computation but requires developing the relative homology machinery
4. **Most promising for the rank theorem** once relative homology is established

**Strategy C (Combinatorial Winding Number — Most Novel)**:
1. Define `toric_horizontal_winding` and `toric_vertical_winding` as homomorphisms H₁(T²; F₂) → F₂
2. Prove these form an isomorphism H₁(T²; F₂) ≅ F₂² (the "crossing number" theorem)
3. Prove winding number ≥ 1 implies Hamming weight ≥ L (any path crossing the torus uses ≥ L edges)
4. This is the **key insight for the distance theorem**: winding number is a topological invariant that lower-bounds the combinatorial weight

**Strategy D (Contradiction for Distance Lower Bound — Most Robust)**:
1. Assume ∃ non-trivial homology class with weight < L
2. Such a cycle cannot wind around the torus (insufficient edges)
3. By the winding number theorem, it must be null-homologous — contradiction
4. **Combine with Strategy C** for the complete distance proof

---

### SIGNIFICANCE AND APPLICATIONS

This formalization establishes the first verified pipeline from **algebraic topology** → **quantum error correction** → **post-quantum cryptography**:

1. **Quantum Physics**: The [[2L², 2, L]] toric code is the canonical example in topological quantum memory (Kitaev 1997, Dennis et al. 2002). The distance L determines the error threshold — our verified bound enables *certified* threshold calculations.

2. **Post-Quantum Cryptography**: Syndrome decoding on the toric code with weight < L/2 is a lattice problem. Our distance certifies that the decoding problem has a unique solution below L/2, enabling **homomorphic_hash_collision_resistance** for post-quantum secure schemes.

3. **Machine Learning**: The homological distance cert is a **Lipschitz_bound** on the quantum error correction map — perturbations of weight < L/2 in the syndrome space lift uniquely, giving certified_robustness for quantum neural decoders.

---

### EXPLICIT COMPUTATIONAL BOUNDS

- Code parameters: **[[2L², 2, L]]** — explicit polynomial scaling
- Encoding rate: **k/n = 2/(2L²) = 1/L²** — vanishes as O(1/L²)
- Distance scaling: **d = L = O(√n)** — square-root distance bound
- Error threshold: **p_th ≈ 10.3%** (numerical; our formalization certifies the structural bound d ≥ L)
- Decoding complexity: **O(L²)** for minimum-weight matching decoder
- Homological winding lower bound: **w(h) ≥ 1 ⟹ wt(h) ≥ L** — linear in grid size

---

### FUTURE DIRECTIONS (required output)

Aristotle MUST produce a `FUTURE_DIRECTIONS.md` with:
1. **Topological Order Classification**: Extend to arbitrary surfaces Σ_g to verify [[2L², 2g, L]] codes for genus g
2. **Frustration-Free Hamiltonian**: Prove the toric code Hamiltonian is frustration-free and has spectral gap Ω(1/L²)
3. **Quantum LDPC Constructions**: Verify good quantum LDPC codes (e.g., Tanner codes) via homological distance bounds
4. **Certified Quantum Decoder**: Build a verified minimum-weight perfect matching decoder with O(L² log L) complexity
5. **Homomorphic Hash from Homology**: Construct collision-resistant hash functions from H₁(T²; F₂) with post-quantum security reductions

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
            Open the field of formalized topological quantum error correction by proving three foundational theorems: (1) The torus T² with standard CW-decomposition on an L×L grid yields a valid F₂-chain complex C₂ →∂₂ C₁ →∂₁ C₀ satisfying ∂²=0, verified by explicit incidence computation showing each face contributes even-edge boundary to every vertex. (2) The first homology H₁(T²; F₂) ≅ F₂², giving exactly 2 logical qubits via rank-nullity on the boundary maps over F₂ with periodic identification. (3) The minimum Hamming weight of any non-trivial homology class in H₁(T²; F₂) equals L, yielding CSS code parameters [[2L², 2, L]] — the first fully verified toric code construction in a proof assistant. This connects the catalog's F2ChainComplex.toCSSCode and cohomological_distance_cert infrastructure to the foundational example in topological quantum memory, establishing a verified pipeline from algebraic topology to quantum code parameters.

            ### Precise Mathematical Framing
            Let T²(L) denote the torus as Fin L × Fin L with periodic identification (i,j) ~ (i+L, j) ~ (i, j+L). Define the CW-chain complex: C₂ has 2L² faces f_{i,j}^{□} (□ ∈ {+, -} for horizontal/vertical orientation), C₁ has 4L² edges e_{i,j}^{dir} (dir ∈ {h, v} for horizontal/vertical), C₀ has L² vertices v_{i,j}. Boundary maps ∂₁ : C₁ → C₀ and ∂₂ : C₂ → C₁ are defined by incidence with periodic wraparound. Theorem 1: ∂₁ ∘ ∂₂ = 0 (each face boundary is a cycle). Theorem 2: dim ker(∂₁)/dim im(∂₂) = 2, so H₁(T²; F₂) ≅ F₂². Theorem 3: For any z ∈ Z₁(T²; F₂) \ B₁(T²; F₂), the Hamming weight wt(z) ≥ L, with equality achieved by the horizontal and vertical cycles. Corollary: F2ChainComplex.toCSSCode applied to this complex yields a [[2L², 2, L]] stabilizer code — the toric code of Kitaev (1997), now formally verified.



            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `quantum_hamming_bound_5_1_3` : theorem quantum_hamming_bound_5_1_3 :
     (file: Physics/Quantum/MoonshotQuantum.lean)
  2. `reconstruct_from_rank2Levi_profiles_and_edge_moments` : theorem reconstruct_from_rank2Levi_profiles_and_edge_moments
     (file: Tropical/GL3_ReconstructionFromRank2LeviProfiles.lean)
  3. `quantum_error_correction` : theorem quantum_error_correction (d : ℕ) (hd : 1 ≤ d) :
     (file: Bridges/Moonshine/MoonshineCodingTheory.lean)
  4. `quantum_birthday_bound` : theorem quantum_birthday_bound (S : ℕ) (hS : 0 < S) :
     (file: Physics/QuantumE8ModularForms.lean)
  5. `maslov_tropical_error_bound` : theorem maslov_tropical_error_bound (x y h : ℝ) (hh : h > 0) :
     (file: Physics/TropicalQuantum/Foundations.lean)

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



Recent successful concepts: Topological Zero-Knowledge Proofs from Cup-Product Bilinear Pairings: Sigma Protocol Construction, Honest-Verifier Simulation, and Betti-Number Soundness, Geometric Complexity Theory: Representation-Theoretic Obstruction Maps, Orbit Closure Non-Containment, and Algebraic Natural Proofs Barrier, Čech Cohomological Stabilizer Codes: Sheaf-Theoretic Quantum Error Correction, Obstruction Class Distance Bounds, and Local-to-Global Decoding Certification


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

Research domain: Physics
Research mode: prove
