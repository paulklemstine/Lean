

=== AEM QUALITY SCORING (MANDATORY GUIDELINES) 



Research Mode: DISCOVER

You are an explorer in uncharted mathematical territory. There is no
specific conjecture to prove. Your mission is to SURVEY the landscape,
IDENTIFY deep structures, and PROVE whatever theorems the territory reveals.

Strategy:
1. Examine the catalog references and existing theorems carefully
2. Look for unexpected patterns, symmetries, or structural correspondences
3. Conjecture and prove theorems that reveal the underlying mathematical truth
4. If you find a connection to another domain, prove it rigorously
5. Produce a FUTURE_DIRECTIONS.md mapping the territory you've discovered

Your Lean 4 files must contain genuine theorems with complete or near-complete
proofs. "Discovery" is not an excuse for vague or trivial results — every
theorem must be precise and mathematically substantive.

Think beyond current mathematical fashion. What would a civilization 200 years
more advanced prove? What connections would surprise specialists?

AEM QUALITY TARGETS:
- RIGOR:

## YOUR ASSIGNMENT: algebra_breakthrough_discovery — Spectral Arithmetic and the Dark Matter Correspondence

**TARGET DOMAIN**: Algebra / Additive Combinatorics / Mathematical Physics

**PRECISE ASSIGNMENT**: Discover and prove the **Dark Matter Correspondence**: a structural isomorphism between Montgomery-type pair correlation operators on arithmetic sequences, eigenvalue gap distributions of quantum Hamiltonians, and lattice packing densities relevant to post-quantum cryptography. This correspondence reveals that "arithmetic dark matter" — the unexplained statistical regularities in prime and multiplicative distributions — is governed by the same spectral laws as quantum chaos and optimal lattice codes.

**CORE CONJECTURE TO PROVE**: For any arithmetic sequence with bounded pair correlation, there exists a quantum Hamiltonian whose eigenvalue gap distribution isospectrally matches the pair correlation, and a lattice whose packing density is spectrally determined by the same operator. Formally:

```
theorem dark_matter_spectral_correspondence
    {α : Type*} [LinearOrderedAddCommGroup α] [Countable α]
    {K : Type*} [RatValuedField K] [CompleteSpace K]
    (s : ArithmeticSpectralSequence α K)
    (hs : BoundedPairCorrelation s 1)
    (hdark : DarkMatterConcentration s > (1 : K) / 2) :
    ∃ (H : QuantumHamiltonian (α →ₗ[K] α))
      (L : IntegralLattice ℤ (Fin s.dimension)),
      IsospectralTo H s.PairCorrelationOperator ∧
      LatticePackingDensity L =
        (1 : K) / Real.sqrt (2 * π * (DarkMatterConcentration s : ℝ)) ∧
      ∀ ε > 0, CertifiedSpectralRadius H ≤
        (1 : K) + ε + DarkMatterConcentration s
```

**PROOF STRATEGY (Three Paths)**:

*Strategy A — Spectral Bridge via Trace Formula*: 
1. Define `PairCorrelationOperator` as a compact self-adjoint operator on ℓ²(α) whose kernel encodes pair distances
2. Prove `pair_correlation_trace_formula`: the trace of this operator equals the Montgomery integral, linking additive combinatorics to operator spectra
3. Construct the quantum Hamiltonian via inverse spectral theory: given the spectrum, build H with matching gaps using Weyl's law
4. Connect to lattice packing via `lattice_spectral_determination`: prove that the packing density of an integral lattice is determined by the spectral gap of its theta series operator
5. Combine to establish the correspondence

*Strategy B — Tropical Min-Plus Deformation*:
1. Deform the pair correlation into the tropical semiring: define `TropicalPairCorrelation`
2. Prove that in the tropical limit, the pair correlation operator becomes the min-plus convolution that computes optimal lattice packing
3. Use `tropical_spectral_convergence`: as tropical parameter → ∞, the classical pair correlation converges to the lattice packing functional
4. This is MOST PROMISING because it gives explicit O(1/ε) convergence bounds and directly connects to certified robustness via tropical geometry

*Strategy C — Random Matrix Universality*:
1. Prove that any sequence with `BoundedPairCorrelation` and `DarkMatterConcentration > 1/2` must have GUE-level statistics
2. Use Keating-Snaith moments to construct the matching Hamiltonian
3. Prove lattice packing bounds via the Siegel mean value theorem deformed by the GUE measure

**Strategy B is most promising** because: (a) it yields explicit computational bounds, (b) it naturally produces certified_robustness guarantees via tropical geometry, (c) it connects to the existing `TropicalDegreeRobustness.lean` infrastructure, and (d) it gives a constructive algorithm, not just existence.

**REQUIRED DEFINITIONS (5+ novel structures)**:

```lean
/-- An arithmetic sequence equipped with a spectral measure capturing its
    pair correlation structure. Bridge: connects additive combinatorics
    to spectral analysis of quantum Hamiltonians. -/
structure ArithmeticSpectralSequence (α K : Type*)
    [LinearOrderedAddCommGroup α] [RatValuedField K] [CompleteSpace K] where
  carrier : α → K
  dimension : ℕ
  pair_correlation_kernel : α → α → K
  spectral_measure : BorelMeasure K
  dark_matter_mass : K

/-- The pair correlation operator: a compact self-adjoint operator whose
    spectrum encodes the statistical regularities of the arithmetic sequence.
    Bridge: connects Montgomery pair correlation to quantum spectral theory. -/
def PairCorrelationOperator {α K : Type*}
    [LinearOrderedAddCommGroup α] [RatValuedField K] [CompleteSpace K]
    (s : ArithmeticSpectralSequence α K) :
    (α → K) →L[K] (α → K) := sorry -- CONSTRUCT THIS

/-- The concentration of "arithmetic dark matter": the ratio of spectral mass
    not explained by standard multiplicative models. When > 1/2, implies
    nontrivial GUE statistics and lattice_crypto hardness. -/
def DarkMatterConcentration {α K : Type*}
    [LinearOrderedAddCommGroup α] [RatValuredField K] [CompleteSpace K]
    (s : ArithmeticSpectralSequence α K) : K := sorry

/-- Bridge type: a quantum Hamiltonian whose eigenvalue gaps are
    spectrally determined by an arithmetic sequence. Bridge: connects
    number theory to quantum_chaotic_simulation. -/
structure QuantumHamiltonian (V : Type*) [NormedAddCommGroup V] [InnerProductSpace ℝ V] where
  operator : V →L[ℝ] V
  self_adjoint : ∀ x y, ⟪operator x, y⟫ = ⟪x, operator y⟫
  compact : CompactOperator operator
  certified_spectral_radius : ℝ

/-- Bridge type: an integral lattice whose packing density is determined
    by the spectral gap of a pair correlation operator. Bridge: connects
    lattice_crypto to arithmetic_spectral_theory. -/
structure SpectralLattice (R : Type*) [CommRing R] (n : ℕ) where
  basis : Fin n → R^n
  pair_correlation_link : ArithmeticSpectralSequence (R^n) ℚ
  packing_density : ℝ
  packing_bound : packing_density ≥ 1 / Real.sqrt (2 * π * DarkMatterConcentration pair_correlation_link)

/-- Certified bound on spectral radius with explicit Lipschitz constant,
    enabling certified_robustness in neural network verification. -/
class CertifiedSpectralBound (H : Type*) where
  spectral_radius_bound : ℝ
  lipschitz_certified_robustness : ℝ
  bound_sharp : ∀ ε > 0, ∃ x, ‖x‖ = 1 ∧ ‖H x‖ ≥ spectral_radius_bound - ε
```

**REQUIRED THEOREMS (10+ with diverse tactics)**:

1. `pair_correlation_trace_formula` — The trace of the pair correlation operator equals the Montgomery integral. Use `simp` + `integral_congr` + `tendsto`.

2. `dark_matter_spectral_gap` — If DarkMatterConcentration > 1/2, then the pair correlation operator has a spectral gap ≥ 1/4. Use `by_contra` + `linarith` + compact operator theory.

3. `isospectral_hamiltonian_construction` — Given bounded pair correlation, construct a quantum Hamiltonian with matching eigenvalue gaps. Use `Classical.exists_somthing` + `NormedSpace.exists_norm_le`.

4. `lattice_packing_spectral_bound` — The packing density of a spectral lattice is ≥ 1/√(2π·dark_matter). Use `omega` + `Real.sqrt_pos` + lattice sphere packing bounds.

5. `tropical_pair_correlation_convergence` — The tropical deformation of pair correlation converges to the lattice packing functional at rate O(1/ε). Use `induction` on the tropical parameter + `field_simp`.

6. `certified_robustness_from_spectral_gap` — A neural network with spectral gap δ has certified ℓ₂ robustness radius δ/(2L) where L is the Lipschitz constant. Use `norm_num` + `mul_comm` + robustness certification lemmas.

7. `dark_matter_gue_statistics` — Sequences with DarkMatterConcentration > 1/2 exhibit GUE level spacing. Use `rcases` on the correlation structure + `linarith` for the Dyson density.

8. `post_quantum_hardness_from_spectral` — Finding short vectors in spectral lattices with dark_matter > 1/2 is as hard as worst-case lattice problems. Use `by_contra` + reduction to SVP + `omega`.

9. `hamiltonian_simulation_spectral_efficiency` — Simulating a quantum Hamiltonian with certified spectral bound B requires O(B² log(1/ε)) quantum gates. Use `induction` on precision + `field_simp`.

10. `montgomery_siegal_mean_value_bridge` — The Montgomery pair correlation is the Fourier transform of the Siegel mean value. Use `integral_transform` + `simp` + Fourier inversion.

11. `dark_matter_additive_energy_bound` — For any arithmetic spectral sequence with DarkMatterConcentration c, the additive energy E+(S) ≤ |S|³ · (1 + c⁻¹). Use `rcases` + `linarith` + additive combinatorics bounds.

12. `spectral_lattice_minkowski_bound` — Spectral lattices satisfy Minkowski's bound with a dark matter improvement: λ₁(L) ≥ √(dark_matter · n/(2πe)) · det(L)^(1/n). Use `omega` + `Real.sqrt_le_sqrt` + Minkowski's theorem.

**CROSS-DOMAIN BRIDGES**:
- **Algebra ↔ Quantum Physics**: Pair correlation operators ↔ quantum Hamiltonians via isospectrality
- **Additive Combinatorics ↔ Cryptography**: Dark matter concentration ↔ lattice problem hardness via spectral lattices
- **Tropical Geometry ↔ ML**: Tropical pair correlation ↔ certified robustness via tropical Lipschitz bounds
- **Number Theory ↔ Information Theory**: Montgomery's conjecture ↔ spectral entropy via trace formulas

**APPLICATION KEYWORDS TO USE IN THEOREM NAMES AND DOC COMMENTS**:
- `post_quantum_security` — for lattice hardness results
- `certified_robustness` — for neural network verification bounds
- `hamiltonian_simulation` — for quantum algorithm efficiency
- `lattice_crypto` — for SVP hardness connections
- `tropical_hash_collision` — for min-plus structural results
- `spectral_entropy` — for information-theoretic bounds

**SIGNIFICANCE**: This would establish that the "arithmetic dark matter" observed in Montgomery's pair correlation — the unexplained GUE statistics of zeta zeros — is not an isolated number-theoretic phenomenon but a universal spectral law. The same operator governs:
1. The distribution of prime gaps (additive combinatorics)
2. The eigenvalue gaps of quantum chaotic systems (physics)
3. The optimal packing of lattice codes (cryptography)
4. The certified robustness of neural networks (ML)

This is a **civilization-level** result: it says that nature computes with the same spectral architecture whether it's distributing primes, organizing quantum energy levels, or packing lattices. The explicit bounds (O(1/ε) tropical convergence, δ/(2L) certified robustness, O(B² log(1/ε)) quantum simulation) make this computationally actionable for post-quantum cryptography and certified AI.

**FAILURE MODE**: If the full correspondence is too strong, prove the **Weak Dark Matter Hypothesis**: for sequences with DarkMatterConcentration > 1/2, there exists a *local* isospectrality between the pair correlation operator and some quantum Hamiltonian on a finite-dimensional subspace, with explicit dimension bounds.

**DEMAND**: Produce a `FUTURE_DIRECTIONS.md` with 5 concrete breakthrough-level next steps:
1. Extend the correspondence to automorphic L-functions (Langlands program connection)
2. Prove that post-quantum key exchange based on spectral lattices achieves IND-CPA security
3. Establish tropical information theory: tropical mutual information satisfies data processing inequality
4. Show that dark matter concentration governs the phase transition in random neural network spectral norms
5. Connect to the Birch-Swinnerton-Dyer conjecture via dark matter in elliptic curve L-functions

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

            Research Mode: DISCOVER

You are an explorer in uncharted mathematical territory. There is no
specific conjecture to prove. Your mission is to SURVEY the landscape,
IDENTIFY deep structures, and PROVE whatever theorems the territory reveals.

Strategy:
1. Examine the catalog references and existing theorems carefully
2. Look for unexpected patterns, symmetries, or structural correspondences
3. Conjecture and prove theorems that reveal the underlying mathematical truth
4. If you find a connection to another domain, prove it rigorously
5. Produce a FUTURE_DIRECTIONS.md mapping the territory you've discovered

Your Lean 4 files must contain genuine theorems with complete or near-complete
proofs. "Discovery" is not an excuse for vague or trivial results — every
theorem must be precise and mathematically substantive.

Think beyond current mathematical fashion. What would a civilization 200 years
more advanced prove? What connections would surprise specialists?

AEM QUALITY TARGETS:
- RIGOR: 10+ theorems with diverse proof tactics. ZERO sorries.
- AESTHETIC: Discover AND prove cross-domain bridges. Name both domains.
  Look for dualities, correspondences, isomorphisms across fields.
- UTILITY: Discover theorems with explicit bounds or algorithmic content.
  Define 5+ structures organizing the discovered territory.
- ORIGINALITY: Coin names for new concepts YOU discovered — not Mathlib restatements.
  Define novel typeclasses combining unexpected mathematical structures.
- IMPACT: Frame discoveries in terms of applications: certified_robustness,
  lattice_crypto, hamiltonian_simulation, entropy, etc.


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
            Discover deep theorems in Algebra (4487 declarations, exploration ratio 4487.0).  This domain shares category, field, functor, group, hilbert, lattice, measure, metric, metricspace, module, monoid, norm, normed, order, ring, semiring, topological, topologicalspace, topology, tropical structures with Bridges but no bridge exists. Find unexpected structure, prove non-trivial results, open new territory.

            ### Precise Mathematical Framing
            Survey Algebra for under-explored theorems. The catalog has 4487 declarations but few deep results. Look for: (1) structural theorems connecting existing definitions, (2) unexpected isomorphisms between objects in Algebra, (3) algorithmic results that leverage the existing infrastructure.



            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `norm_congruence_bridge` : theorem norm_congruence_bridge (p : ℕ) (hp : Nat.Prime p) (hmod : p % 4 = 3)
     (file: Algebra/Core/OpenQuestions.lean)
  2. `any_semiring_reduced_basis_exists` : theorem any_semiring_reduced_basis_exists {A : Type*} [Semiring A]
     (file: Algebra/EMLCongruenceHilbert.lean)
  3. `symmetric_group_order` : theorem symmetric_group_order (n : ℕ) :
     (file: Algebra/Factoring/FutureExploration.lean)
  4. `qdf_symmetry_group_order` : theorem qdf_symmetry_group_order :
     (file: Algebra/IntegerEnergy/QDF_HE_Frontiers.lean)
  5. `trivial_tropical_character` : theorem trivial_tropical_character {G : Type*} [Group G] :
     (file: Algebra/Other/Bridges.lean)

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



Recent successful concepts: Tropical Shannon Theory: Max-Plus Entropy, Data Processing Inequality, and Idempotent Channel Capacity, Berggren–Farey Correspondence: Free Monoid Structure, PSL(2,ℤ) Faithfulness, and Continued Fraction Descent Encoding for Primitive Pythagorean Triples, Tropical Modular Lensing: Berggren Critical Curves, Cuspidal Factorization, and Max-Plus Geodesic Deflection on the Modular Tree


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
            @Algebra/AdditiveCombinatorics/MontgomeryPairCorrelation.lean
```lean
import Mathlib

/-! # CatalogBuild.Algebra.Core.MontgomeryPairCorrelation

Auto-generated from theorem catalog database.
Domain: Algebra/Core
Declarations: 34
-/


noncomputable section

/-- The difference set of a finite set S: all values s - t for s, t ∈ S. -/
def differenceSet (S : Finset ℤ) : Finset ℤ :=
  (S ×ˢ S).image (fun p => p.1 - p.2)




/-- The nonzero difference set — excludes the trivial zero difference. -/
def nonzeroDifferenceSet (S : Finset ℤ) : Finset ℤ :=
  (differenceSet S).filter (· ≠ 0)




/-- Zero is always in the difference set of a nonempty set. -/
theorem zero_mem_differenceSet {S : Finset ℤ} (hS : S.Nonempty) :
    (0 : ℤ) ∈ differenceSet S := by
  obtain ⟨x, hx⟩ := hS
  simp only [differenceSet, Finset.mem_image, Finset.mem_product]
  exact ⟨⟨x, x⟩, ⟨hx, hx⟩, sub_self x⟩




/-- [Section: # CatalogBuild.Algebra.Core.MontgomeryPairCorrelation
Auto-generated from theorem catalog database.
Domain: Algebra/Core
Declarations: 34] -/
theorem nonzero_diff_card_le (S : Finset ℤ) :
    (nonzeroDifferenceSet S).card ≤ S.card ^ 2 - S.card := by
  refine' le_trans ( Finset.card_le_card _ ) _;
  exact Finset.image ( fun p : ℤ × ℤ => p.1 - p.2 ) ( Finset.filter ( fun p : ℤ × ℤ => p.1 ≠ p.2 ) ( S ×ˢ S ) );
  · unfold nonzeroDifferenceSet differenceSet;
    intro x hx; aesop;
  · refine' le_trans ( Finset.card_image_le ) _;
    rw [ show ( Finset.filter ( fun p : ℤ × ℤ => p.1 ≠ p.2 ) ( S ×ˢ S ) ) = Finset.offDiag S by ext ⟨ x, y ⟩ ; aesop ] ; simp +decide [ sq, Finset.offDiag_card ]




/-- [Section: # CatalogBuild.Algebra.Core.MontgomeryPairCorrelation
Auto-generated from theorem catalog database.
Domain: Algebra/Core
Declarations: 34] -/
theorem sidon_diff_card (S : Finset ℤ) (hS : IsSidonSet S) :
    (nonzeroDifferenceSet S).card = S.card * (S.card - 1) := by
  -- For a Sidon set, every nonzero difference d = s - t with s ≠ t appears exactly once. The total number of ordered pairs (s,t) with s ≠ t is |S|*(|S|-1). Each such pair contributes a unique nonzero difference (this is the Sidon condition). So the number of distinct nonzero differences equals |S|*(|S|-1).
  have h_diff_set_card : ((S ×ˢ S).filter (fun p => p.1 ≠ p.2)).card = S.card * (S.card - 1) := by
    simp +contextual [ Finset.filter_ne, Finset.card_product ];
    rw [ show ( Finset.filter ( fun p => ¬p.1 = p.2 ) ( S ×ˢ S ) ) = Finset.offDiag S by ext; aesop ] ; simp +decide [ Finset.offDiag_card ];
    rw [ Nat.mul_sub_left_distrib, Nat.mul_one ];
  -- Since these pairs contribute distinct nonzero differences, the cardinality of the nonzero difference set is equal to the cardinality of the set of pairs.
  have h_distinct_diffs : Finset.image (fun p : ℤ × ℤ => p.1 - p.2) ((S ×ˢ S).filter (fun p => p.1 ≠ p.2)) = nonzeroDifferenceSet S := by
    ext; simp [differenceSet, nonzeroDifferenceSet];
    grind +ring;
  rw [ ← h_diff_set_card, ← h_distinct_diffs, Finset.card_image_of_injOn ];
  intro p hp q hq; have := hS ( p.1 - p.2 ) ; simp_all +decide [ Set.InjOn ] ;
  intro h; have := this ( sub_ne_zero_of_ne hp.2 ) ; simp_all +decide [ autocorrelation ] ;
  contrapose! this;
  refine' Finset.one_lt_card.mpr ⟨ p, _, q, _, _ ⟩ <;> aesop




/-- The autocorrelation energy: sum of squared autocorrelation values over
the difference set. This measures departure from randomness. -/
def autocorrelationEnergy (S : Finset ℤ) : ℕ :=
  ∑ d ∈ differenceSet S, (autocorrelation S d) ^ 2




theorem autocorrelation_total_sum (S : Finset ℤ) :
    ∑ d ∈ differenceSet S, autocorrelation S d = S.card ^ 2 := by
  unfold differenceSet autocorrelation;
  rw [ Finset.sum_image' ];
  rotate_left;
  use fun _ => 1;
  · aesop;
  · norm_num [ sq ]




/-- The number of "additive quadruples" (a,b,c,d) with a-b = c-d. -/
def additiveQuadruples (S : Finset ℤ) : ℕ :=
  ((S ×ˢ S).filter (fun p => p.1 - p.2 = 0)).card  -- simplified placeholder




/-- The Sidon defect: number of nonzero differences with multiplicity ≥ 2. -/
def sidonDefect (S : Finset ℤ) : ℕ :=
  ((S ×ˢ S).image (fun p => p.1 - p.2) |>.filter
    (fun d => d ≠ 0 ∧ 1 < autocorrelation S d)).card




theorem sidon_iff_defect_zero (S : Finset ℤ) :
    IsSidonSet S ↔ sidonDefect S = 0 := by
  rw [ sidonDefect ];
  constructor;
  · aesop;
  · intro h;
    intro d hd; contrapose! h; simp_all +decide [ Finset.ext_iff ] ;
    obtain ⟨ p, hp ⟩ := Finset.card_pos.mp ( pos_of_gt h ) ; use p.1, by aesop, p.2; aesop;




/-- Compute the Sidon defect of a list-represented set. -/
def sidonDefectCompute (S : List ℤ) : ℕ :=
  let diffs := (S.product S).map (fun p => p.1 - p.2)
  let nonzeroDiffs := diffs.filter (· ≠ 0) |>.eraseDups
  nonzeroDiffs.countP (fun d =>
    1 < (S.product S).countP (fun p => p.1 - p.2 = d))




/-- Compute maximum autocorrelation value for d ≠ 0. -/
def maxAutocorrCompute (S : List ℤ) : ℕ :=
  let diffs := (S.product S).map (fun p => p.1 - p.2)
  let nonzeroDiffs := diffs.filter (· ≠ 0) |>.eraseDups
  nonzeroDiffs.foldl (fun acc d =>
    max acc ((S.product S).countP (fun p => p.1 - p.2 = d))) 0




/-- Compute autocorrelation energy. -/
def autocorrEnergyCompute (S : List ℤ) : ℕ :=
  let diffs := (S.product S).map (fun p => p.1 - p.2)
  let allDiffs := diffs.eraseDups
  allDiffs.foldl (fun acc d =>
    acc + ((S.product S).countP (fun p => p.1 - p.2 = d))^2) 0

-- ... (truncated, full file has 409 lines)
```

@Algebra/Advanced/MetaOracleAdvanced.lean
```lean
import Mathlib

/-! # CatalogBuild.Computation.Oracles.MetaOracleAdvanced

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 12
-/


noncomputable section

/-- The identity meta-oracle: does nothing. -/
def metaOracleId {α : Type*} : α → α := id




/-- The identity is a fixed point of any meta-oracle composition scheme. -/
theorem metaOracleId_fixed {α : Type*} (f : (α → α) → (α → α))
    (hf : f id = id) : f metaOracleId = metaOracleId :=
  hf




/-- [Section: # CatalogBuild.Computation.Oracles.MetaOracleAdvanced
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 12] -/
theorem exists_fixed_quality_strict {n : ℕ} (hn : 0 < n)
    (M : Fin n → Fin n) (q : Fin n → ℝ)
    (h_strict : ∀ i, M i ≠ i → q i < q (M i)) :
    ∃ i, M i = i := by
  contrapose! h_strict with h;
  -- Consider the maximum value of $q$ over all elements in $Fin n$.
  obtain ⟨i₀, hi₀⟩ : ∃ i₀ : Fin n, ∀ i : Fin n, q i₀ ≥ q i := by
    simpa using Finset.exists_max_image Finset.univ q ( Finset.univ_nonempty_iff.mpr ⟨ 0, hn ⟩ );
  exact ⟨ i₀, h i₀, hi₀ _ ⟩




/-- The improvement ratio after n steps of a contraction with rate k. -/
def improvementRatio (k : ℝ) (n : ℕ) : ℝ := 1 - k ^ n




/-- The improvement ratio approaches 1 (complete improvement) as n → ∞. -/
theorem improvementRatio_tendsto_one (k : ℝ) (hk : 0 < k) (hk1 : k < 1) :
    Filter.Tendsto (improvementRatio k) Filter.atTop (nhds 1) := by
  unfold improvementRatio
  have h := tendsto_pow_atTop_nhds_zero_of_lt_one (le_of_lt hk) hk1
  convert Filter.Tendsto.const_sub 1 h using 1 <;> ring




/-- Number of iterations needed to achieve ε-optimality. -/
def iterationsNeeded (k ε d₀ : ℝ) : ℝ :=
  Real.log (ε / d₀) / Real.log k




/-- The number of iterations needed is proportional to 1/H where H is oracle entropy. -/
theorem iterations_proportional_to_inv_entropy
    (k ε d₀ : ℝ) (_hk : 0 < k) (_hk1 : k < 1) (_hε : 0 < ε) (_hd : 0 < d₀) :
    iterationsNeeded k ε d₀ = Real.log (ε / d₀) / (-(-Real.log k)) := by
  unfold iterationsNeeded
  ring




/-- Meta-oracles on a fixed type form a semigroup under composition. -/
instance metaOracleSemigroup (α : Type*) : Semigroup (α → α) where
  mul := Function.comp
  mul_assoc := Function.comp_assoc




/-- Meta-oracles on a fixed type form a monoid with identity. -/
instance metaOracleMonoid (α : Type*) : Monoid (α → α) where
  one := id
  one_mul := Function.id_comp
  mul_one := Function.comp_id




/-- If f and g both contract with rates k₁ and k₂, then f ∘ g contracts with rate k₁ * k₂. -/
theorem comp_contraction_rate {α : Type*} [PseudoMetricSpace α]
    (f g : α → α) (k₁ k₂ : ℝ)
    (hk₁ : 0 ≤ k₁) (_hk₂ : 0 ≤ k₂)
    (hf : ∀ x y, dist (f x) (f y) ≤ k₁ * dist x y)
    (hg : ∀ x y, dist (g x) (g y) ≤ k₂ * dist x y) :
    ∀ x y, dist ((f ∘ g) x) ((f ∘ g) y) ≤ (k₁ * k₂) * dist x y := by
  intro x y
  simp only [Function.comp_apply]
  calc dist (f (g x)) (f (g y))
      ≤ k₁ * dist (g x) (g y) := hf _ _
    _ ≤ k₁ * (k₂ * dist x y) := by
        apply mul_le_mul_of_nonneg_left (hg _ _) hk₁
    _ = (k₁ * k₂) * dist x y := by ring




/-- A weighted combination of quality values (portfolio quality). -/
def portfolioQuality {n : ℕ} (weights : Fin n → ℝ) (qualities : Fin n → ℝ) : ℝ :=
  ∑ i, weights i * qualities i




/-- [Section: # CatalogBuild.Computation.Oracles.MetaOracleAdvanced
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 12] -/
theorem portfolio_quality_bounded {n : ℕ} (hn : 0 < n)
    (w : Fin n → ℝ) (q : Fin n → ℝ)
    (hw_nn : ∀ i, 0 ≤ w i)
    (hw_sum : ∑ i, w i = 1) :
    (∃ i, q i ≤ portfolioQuality w q) ∧ (∃ i, portfolioQuality w q ≤ q i) := by
  constructor;
  · -- Let $j$ be an index such that $q_j$ is the minimum among the $q_i$.
    obtain ⟨j, hj⟩ : ∃ j, ∀ i, q i ≥ q j := by
      simpa using Finset.exists_min_image Finset.univ ( fun i => q i ) ⟨ ⟨ 0, hn ⟩, Finset.mem_univ _ ⟩;
    exact ⟨ j, by simpa [ ← Finset.sum_mul _ _ _, hw_sum ] using Finset.sum_le_sum fun i ( hi : i ∈ Finset.univ ) => mul_le_mul_of_nonneg_left ( hj i ) ( hw_nn i ) ⟩;
  · -- Since the weights are non-negative and sum to 1, the weighted average of the qualities is bounded above by the maximum quality.
    have h_max : ∃ i, ∀ j, q j ≤ q i := by
      simpa using Finset.exists_max_image Finset.univ q ⟨ ⟨ 0, hn ⟩, Finset.mem_univ _ ⟩;
    exact ⟨ h_max.choose, le_trans ( Finset.sum_le_sum fun i _ => mul_le_mul_of_nonneg_left ( h_max.choose_spec i ) ( hw_nn i ) ) ( by simp +decide [ ← Finset.sum_mul, hw_sum ] ) ⟩




end
```

@Algebra/AutoResearch/ArithmeticDarkMatter.lean
```lean
import Mathlib

/-! # CatalogBuild.Algebra.Core.ArithmeticDarkMatter

Auto-generated from theorem catalog database.
Domain: Algebra/Core
Declarations: 24
-/


/-- The Lorentz form Q(a,b,c) = a² + b² - c² -/
def Q_form (a b c : ℤ) : ℤ := a ^ 2 + b ^ 2 - c ^ 2




/-- An arithmetic particle: an integer triple with its mass classification -/
structure ArithParticle where
  a : ℤ
  b : ℤ
  c : ℤ
  a_pos : 0 < a
  b_pos : 0 < b
  c_pos : 0 < c




/-- The mass-squared of a particle -/
def ArithParticle.massSq (p : ArithParticle) : ℤ :=
  p.c ^ 2 - p.a ^ 2 - p.b ^ 2




/-- A particle is a photon (null/massless) -/
def ArithParticle.isPhoton (p : ArithParticle) : Prop :=
  p.massSq = 0




/-- A particle is massive (timelike) -/
def ArithParticle.isMassive' (p : ArithParticle) : Prop :=
  p.massSq > 0




/-- A particle is tachyonic (spacelike) -/
def ArithParticle.isTachyon (p : ArithParticle) : Prop :=
  p.massSq < 0




/-- The mass spectrum: which mass-squared values are realized? -/
def massIsRealized (m_sq : ℤ) : Prop :=
  ∃ a b c : ℤ, 0 < a ∧ 0 < b ∧ 0 < c ∧ c ^ 2 - a ^ 2 - b ^ 2 = m_sq




/-- [Section: # CatalogBuild.Algebra.Core.ArithmeticDarkMatter
Auto-generated from theorem catalog database.
Domain: Algebra/Core
Declarations: 24] -/
theorem every_nonneg_mass_realized (m_sq : ℕ) :
    massIsRealized (m_sq : ℤ) := by
  by_contra h;
  -- For even m_sq, we can take a=1, b=m_sq/2, c=m_sq/2+1.
  by_cases h_even : Even m_sq;
  · obtain ⟨ k, rfl ⟩ := h_even;
    exact h ⟨ 1, k, k + 1, by norm_num, by linarith [ show k > 0 from Nat.pos_of_ne_zero ( by rintro rfl; exact h ⟨ 3, 4, 5, by norm_num ⟩ ) ], by linarith [ show k > 0 from Nat.pos_of_ne_zero ( by rintro rfl; exact h ⟨ 3, 4, 5, by norm_num ⟩ ) ], by push_cast; linarith ⟩;
  · -- For odd m_sq, we can take a=2, b=(m_sq+3)/2, c=(m_sq+5)/2.
    obtain ⟨k, hk⟩ : ∃ k : ℕ, m_sq = 2 * k + 1 := by
      exact m_sq.even_or_odd.resolve_left h_even;
    refine h ⟨ 2, k + 2, k + 3, by norm_num, by linarith, by linarith, ?_ ⟩ ; push_cast [ hk ] ; ring




/-- The Berggren B₁ matrix action on a triple -/
def berggren_B1 (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)




/-- The Berggren matrices preserve Q (the full Lorentz form, not just Q=0) -/
theorem B1_preserves_Q (a b c : ℤ) :
    Q_form (berggren_B1 a b c).1 (berggren_B1 a b c).2.1 (berggren_B1 a b c).2.2
    = Q_form a b c := by
  unfold berggren_B1 Q_form
  ring




/-- B₂ also preserves Q -/
def berggren_B2 (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)




/-- [Section: # CatalogBuild.Algebra.Core.ArithmeticDarkMatter
Auto-generated from theorem catalog database.
Domain: Algebra/Core
Declarations: 24] -/
theorem B2_preserves_Q (a b c : ℤ) :
    Q_form (berggren_B2 a b c).1 (berggren_B2 a b c).2.1 (berggren_B2 a b c).2.2
    = Q_form a b c := by
  unfold berggren_B2 Q_form
  ring




/-- B₃ also preserves Q -/
def berggren_B3 (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)




theorem B3_preserves_Q (a b c : ℤ) :
    Q_form (berggren_B3 a b c).1 (berggren_B3 a b c).2.1 (berggren_B3 a b c).2.2
    = Q_form a b c := by
  unfold berggren_B3 Q_form
  ring




/-- A path in the dark matter tree (same branching as the photon tree) -/
inductive DarkPath where
  | root : DarkPath
  | b1 : DarkPath → DarkPath
  | b2 : DarkPath → DarkPath
  | b3 : DarkPath → DarkPath
  deriving Repr




/-- The triple at a given dark matter path, starting from seed (a₀, b₀, c₀) -/
def darkTriple (seed : ℤ × ℤ × ℤ) : DarkPath → ℤ × ℤ × ℤ
  | .root => seed
  | .b1 p =>
-- ... (truncated, full file has 299 lines)
```

@Algebra/AutoResearch/DeepOpenProblems.lean
```lean
import Mathlib

/-! # CatalogBuild.Pythagorean.ThreeRoads.DeepOpenProblems

Auto-generated from theorem catalog database.
Domain: Pythagorean/ThreeRoads
Declarations: 35
-/

/-- The gap c² - 2ab = (a-b)² is always a perfect square. -/
theorem smooth_density_gap_square (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    c ^ 2 - 2 * a * b = (a - b) ^ 2 := by nlinarith

/-- The minimum gap when a ≠ b is 1, giving 2ab ≤ c² - 1. -/
theorem smooth_density_min_gap (a b c : ℤ) (ha : 0 < a) (hb : 0 < b)
    (h : a ^ 2 + b ^ 2 = c ^ 2) (hne : a ≠ b) :
    2 * a * b ≤ c ^ 2 - 1 := by
  have : (a - b) ^ 2 ≥ 1 := by
    nlinarith [sq_abs (a - b), abs_pos.mpr (sub_ne_zero.mpr hne)]
  nlinarith [smooth_density_gap_square a b c h]

/-- Leg sum identities for each branch. -/
theorem B1_leg_sum (a b c : ℤ) :
    (a - 2*b + 2*c) + (2*a - b + 2*c) = 3*a - 3*b + 4*c := by ring

/-- [Section: # CatalogBuild.Pythagorean.ThreeRoads.DeepOpenProblems
Auto-generated from theorem catalog database.
Domain: Pythagorean/ThreeRoads
Declarations: 35] -/
theorem B2_leg_sum (a b c : ℤ) :
    (a + 2*b + 2*c) + (2*a + b + 2*c) = 3*a + 3*b + 4*c := by ring

/-- [Section: # CatalogBuild.Pythagorean.ThreeRoads.DeepOpenProblems
Auto-generated from theorem catalog database.
Domain: Pythagorean/ThreeRoads
Declarations: 35] -/
theorem B3_leg_sum (a b c : ℤ) :
    (-a + 2*b + 2*c) + (-2*a + b + 2*c) = -3*a + 3*b + 4*c := by ring

/-- The B₂ child's leg product expanded. -/
theorem B2_leg_product_expanded (a b c : ℤ) :
    (a + 2*b + 2*c) * (2*a + b + 2*c) =
    2*a^2 + 5*a*b + 2*b^2 + 6*a*c + 6*b*c + 4*c^2 := by ring

/-- B₂ has determinant -1. -/
theorem B2_det_value : (1 : ℤ) * (1*3 - 2*2) - 2 * (2*3 - 2*2) +
    2 * (2*2 - 1*2) = -1 := by norm_num

/-- The product of two matrices with det ±1 has det 1. -/
theorem berggren_product_det_one : (-1 : ℤ) * (-1) = 1 := by norm_num

/-- After d steps, the determinant is (-1)^d. -/
theorem berggren_path_det (d : ℕ) : (-1 : ℤ) ^ d = 1 ∨ (-1 : ℤ) ^ d = -1 := by
  rcases Nat.even_or_odd d with ⟨k, hk⟩ | ⟨k, hk⟩
  · left; simp [hk, pow_mul, pow_succ, neg_one_sq]
  · right; simp [hk, pow_add, pow_mul, pow_succ, neg_one_sq]

theorem B2_quadratic_discriminant : (4 : ℤ)^2 - 4*1*1 = 12 := by norm_num

theorem eigenvalue_one_B2 : (1 : ℤ)^3 - 5*(1)^2 + 5*1 - 1 = 0 := by norm_num

/-- The spectral radius of B₂ satisfies ρ²-4ρ+1=0, so ρ = 2+√3. -/
theorem spectral_radius_B2_equation :
    (2 + Real.sqrt 3) ^ 2 - 4 * (2 + Real.sqrt 3) + 1 = 0 := by
  set s := Real.sqrt 3 with hs_def
  have h3 : s * s = 3 := Real.mul_self_sqrt (by norm_num : (3:ℝ) ≥ 0)
  have hsq : s ^ 2 = s * s := sq s
  nlinarith [hsq, h3]

theorem B1_char_poly_factored (x : ℤ) :
    x^3 - 3*x^2 + 3*x - 1 = (x - 1)^3 := by ring

theorem B2_eigenvalue_product :
    (2 + Real.sqrt 3) * (2 - Real.sqrt 3) = 1 := by
  have : Real.sqrt 3 ^ 2 = 3 := Real.sq_sqrt (by norm_num : (3:ℝ) ≥ 0)
  nlinarith

theorem B2_hyp_growth_factor (a b c : ℤ) (ha : 0 < a) (hb : 0 < b)
    (h : a ^ 2 + b ^ 2 = c ^ 2) :
    3 * c ≤ 2*a + 2*b + 3*c := by nlinarith

theorem B2_hyp_growth_upper (a b c : ℤ) (ha : 0 < a) (hb : 0 < b)
    (hc : 0 < c) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    2*a + 2*b + 3*c < 7 * c := by
  have ha_lt : a < c := by nlinarith [sq_nonneg b]
  have hb_lt : b < c := by nlinarith [sq_nonneg a]
  linarith

theorem total_paths_bound (d : ℕ) : 3^(d+1) - 1 ≥ 2 * 3^d := by
  have : 3^(d+1) = 3^d * 3 := pow_succ 3 d
  omega

theorem euclid_B1_transform (m n : ℤ) :
    let m' := 2*m - n
    let n' := m
    m' + n' = 3*m - n ∧ m' - n' = m - n := by constructor <;> ring

theorem grover_cost_bound (d : ℕ) : Nat.sqrt (3^d) ≤ 3^d := Nat.sqrt_le_self _

theorem classical_tree_search_lower (d : ℕ) : 3^d ≥ d + 1 := by
  induction d with
  | zero => norm_num
  | succ n ih =>
    have h3 : 3^(n+1) = 3^n * 3 := pow_succ 3 n
    omega

theorem qs_tree_sieve_bridge (N x : ℤ) :
    x^2 - N^2 = (x - N) * (x + N) := by ring

theorem tree_sieve_value_divides (N b c : ℤ) (h : N^2 + b^2 = c^2) :
    (c - b) ∣ N^2 := ⟨c + b, by linarith⟩

theorem tree_sieve_complement_divides (N b c : ℤ) (h : N^2 + b^2 = c^2) :
    (c + b) ∣ N^2 := ⟨c - b, by linarith⟩

theorem root_triple : (3 : ℤ)^2 + 4^2 = 5^2 := by norm_num

theorem level1_products :
    (5 : ℕ) * 12 = 60 ∧ 21 * 20 = 420 ∧ 15 * 8 = 120 := by norm_num

theorem level1_all_7_smooth :
    60 = 2^2 * 3 * 5 ∧ 420 = 2^2 * 3 * 5 * 7 ∧ 120 = 2^3 * 3 * 5 := by norm_num

theorem berggren_B1_injective (a₁ b₁ c₁ a₂ b₂ c₂ : ℤ)
    (h_a : a₁ - 2*b₁ + 2*c₁ = a₂ - 2*b₂ + 2*c₂)
    (h_b : 2*a₁ - b₁ + 2*c₁ = 2*a₂ - b₂ + 2*c₂)
    (h_c : 2*a₁ - 2*b₁ + 3*c₁ = 2*a₂ - 2*b₂ + 3*c₂) :
    a₁ = a₂ ∧ b₁ = b₂ ∧ c₁ = c₂ := by
  constructor; · linarith
  constructor <;> linarith

theorem berggren_B2_injective (a₁ b₁ c₁ a₂ b₂ c₂ : ℤ)
    (h_a : a₁ + 2*b₁ + 2*c₁ = a₂ + 2*b₂ + 2*c₂)
    (h_b : 2*a₁ + b₁ + 2*c₁ = 2*a₂ + b₂ + 2*c₂)
    (h_c : 2*a₁ + 2*b₁ + 3*c₁ = 2*a₂ + 2*b₂ + 3*c₂) :
    a₁ = a₂ ∧ b₁ = b₂ ∧ c₁ = c₂ := by
  constructor; · linarith
  constructor <;> linarith

theorem berggren_B3_injective (a₁ b₁ c₁ a₂ b₂ c₂ : ℤ)
    (h_a : -a₁ + 2*b₁ + 2*c₁ = -a₂ + 2*b₂ + 2*c₂)
    (h_b : -2*a₁ + b₁ + 2*c₁ = -2*a₂ + b₂ + 2*c₂)
    (h_c : -2*a₁ + 2*b₁ + 3*c₁ = -2*a₂ + 2*b₂ + 3*c₂) :
    a₁ = a₂ ∧ b₁ = b₂ ∧ c₁ = c₂ := by
  constructor; · linarith
  constructor <;> linarith

theorem poincare_on_circle (a b c : ℤ) (hc : c ≠ 0)
    (h : a^2 + b^2 = c^2) :
    (a : ℚ)^2 / (c : ℚ)^2 + (b : ℚ)^2 / (c : ℚ)^2 = 1 := by
-- ... (truncated, full file has 174 lines)
```


### Catalog Reference Files
            @Algebra/AdditiveCombinatorics/MontgomeryPairCorrelation.lean
```lean
import Mathlib

/-! # CatalogBuild.Algebra.Core.MontgomeryPairCorrelation

Auto-generated from theorem catalog database.
Domain: Algebra/Core
Declarations: 34
-/


noncomputable section

/-- The difference set of a finite set S: all values s - t for s, t ∈ S. -/
def differenceSet (S : Finset ℤ) : Finset ℤ :=
  (S ×ˢ S).image (fun p => p.1 - p.2)




/-- The nonzero difference set — excludes the trivial zero difference. -/
def nonzeroDifferenceSet (S : Finset ℤ) : Finset ℤ :=
  (differenceSet S).filter (· ≠ 0)




/-- Zero is always in the difference set of a nonempty set. -/
theorem zero_mem_differenceSet {S : Finset ℤ} (hS : S.Nonempty) :
    (0 : ℤ) ∈ differenceSet S := by
  obtain ⟨x, hx⟩ := hS
  simp only [differenceSet, Finset.mem_image, Finset.mem_product]
  exact ⟨⟨x, x⟩, ⟨hx, hx⟩, sub_self x⟩




/-- [Section: # CatalogBuild.Algebra.Core.MontgomeryPairCorrelation
Auto-generated from theorem catalog database.
Domain: Algebra/Core
Declarations: 34] -/
theorem nonzero_diff_card_le (S : Finset ℤ) :
    (nonzeroDifferenceSet S).card ≤ S.card ^ 2 - S.card := by
  refine' le_trans ( Finset.card_le_card _ ) _;
  exact Finset.image ( fun p : ℤ × ℤ => p.1 - p.2 ) ( Finset.filter ( fun p : ℤ × ℤ => p.1 ≠ p.2 ) ( S ×ˢ S ) );
  · unfold nonzeroDifferenceSet differenceSet;
    intro x hx; aesop;
  · refine' le_trans ( Finset.card_image_le ) _;
    rw [ show ( Finset.filter ( fun p : ℤ × ℤ => p.1 ≠ p.2 ) ( S ×ˢ S ) ) = Finset.offDiag S by ext ⟨ x, y ⟩ ; aesop ] ; simp +decide [ sq, Finset.offDiag_card ]




/-- [Section: # CatalogBuild.Algebra.Core.MontgomeryPairCorrelation
Auto-generated from theorem catalog database.
Domain: Algebra/Core
Declarations: 34] -/
theorem sidon_diff_card (S : Finset ℤ) (hS : IsSidonSet S) :
    (nonzeroDifferenceSet S).card = S.card * (S.card - 1) := by
  -- For a Sidon set, every nonzero difference d = s - t with s ≠ t appears exactly once. The total number of ordered pairs (s,t) with s ≠ t is |S|*(|S|-1). Each such pair contributes a unique nonzero difference (this is the Sidon condition). So the number of distinct nonzero differences equals |S|*(|S|-1).
  have h_diff_set_card : ((S ×ˢ S).filter (fun p => p.1 ≠ p.2)).card = S.card * (S.card - 1) := by
    simp +contextual [ Finset.filter_ne, Finset.card_product ];
    rw [ show ( Finset.filter ( fun p => ¬p.1 = p.2 ) ( S ×ˢ S ) ) = Finset.offDiag S by ext; aesop ] ; simp +decide [ Finset.offDiag_card ];
    rw [ Nat.mul_sub_left_distrib, Nat.mul_one ];
  -- Since these pairs contribute distinct nonzero differences, the cardinality of the nonzero difference set is equal to the cardinality of the set of pairs.
  have h_distinct_diffs : Finset.image (fun p : ℤ × ℤ => p.1 - p.2) ((S ×ˢ S).filter (fun p => p.1 ≠ p.2)) = nonzeroDifferenceSet S := by
    ext; simp [differenceSet, nonzeroDifferenceSet];
    grind +ring;
  rw [ ← h_diff_set_card, ← h_distinct_diffs, Finset.card_image_of_injOn ];
  intro p hp q hq; have := hS ( p.1 - p.2 ) ; simp_all +decide [ Set.InjOn ] ;
  intro h; have := this ( sub_ne_zero_of_ne hp.2 ) ; simp_all +decide [ autocorrelation ] ;
  contrapose! this;
  refine' Finset.one_lt_card.mpr ⟨ p, _, q, _, _ ⟩ <;> aesop




/-- The autocorrelation energy: sum of squared autocorrelation values over
the difference set. This measures departure from randomness. -/
def autocorrelationEnergy (S : Finset ℤ) : ℕ :=
  ∑ d ∈ differenceSet S, (autocorrelation S d) ^ 2




theorem autocorrelation_total_sum (S : Finset ℤ) :
    ∑ d ∈ differenceSet S, autocorrelation S d = S.card ^ 2 := by
  unfold differenceSet autocorrelation;
  rw [ Finset.sum_image' ];
  rotate_left;
  use fun _ => 1;
  · aesop;
  · norm_num [ sq ]




/-- The number of "additive quadruples" (a,b,c,d) with a-b = c-d. -/
def additiveQuadruples (S : Finset ℤ) : ℕ :=
  ((S ×ˢ S).filter (fun p => p.1 - p.2 = 0)).card  -- simplified placeholder




/-- The Sidon defect: number of nonzero differences with multiplicity ≥ 2. -/
def sidonDefect (S : Finset ℤ) : ℕ :=
  ((S ×ˢ S).image (fun p => p.1 - p.2) |>.filter
    (fun d => d ≠ 0 ∧ 1 < autocorrelation S d)).card




theorem sidon_iff_defect_zero (S : Finset ℤ) :
    IsSidonSet S ↔ sidonDefect S = 0 := by
  rw [ sidonDefect ];
  constructor;
  · aesop;
  · intro h;
    intro d hd; contrapose! h; simp_all +decide [ Finset.ext_iff ] ;
    obtain ⟨ p, hp ⟩ := Finset.card_pos.mp ( pos_of_gt h ) ; use p.1, by aesop, p.2; aesop;




/-- Compute the Sidon defect of a list-represented set. -/
def sidonDefectCompute (S : List ℤ) : ℕ :=
  let diffs := (S.product S).map (fun p => p.1 - p.2)
  let nonzeroDiffs := diffs.filter (· ≠ 0) |>.eraseDups
  nonzeroDiffs.countP (fun d =>
    1 < (S.product S).countP (fun p => p.1 - p.2 = d))




/-- Compute maximum autocorrelation value for d ≠ 0. -/
def maxAutocorrCompute (S : List ℤ) : ℕ :=
  let diffs := (S.product S).map (fun p => p.1 - p.2)
  let nonzeroDiffs := diffs.filter (· ≠ 0) |>.eraseDups
  nonzeroDiffs.foldl (fun acc d =>
    max acc ((S.product S).countP (fun p => p.1 - p.2 = d))) 0




/-- Compute autocorrelation energy. -/
def autocorrEnergyCompute (S : List ℤ) : ℕ :=
  let diffs := (S.product S).map (fun p => p.1 - p.2)
  let allDiffs := diffs.eraseDups
  allDiffs.foldl (fun acc d =>
    acc + ((S.product S).countP (fun p => p.1 - p.2 = d))^2) 0

-- ... (truncated, full file has 409 lines)
```

@Algebra/Advanced/MetaOracleAdvanced.lean
```lean
import Mathlib

/-! # CatalogBuild.Computation.Oracles.MetaOracleAdvanced

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 12
-/


noncomputable section

/-- The identity meta-oracle: does nothing. -/
def metaOracleId {α : Type*} : α → α := id




/-- The identity is a fixed point of any meta-oracle composition scheme. -/
theorem metaOracleId_fixed {α : Type*} (f : (α → α) → (α → α))
    (hf : f id = id) : f metaOracleId = metaOracleId :=
  hf




/-- [Section: # CatalogBuild.Computation.Oracles.MetaOracleAdvanced
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 12] -/
theorem exists_fixed_quality_strict {n : ℕ} (hn : 0 < n)
    (M : Fin n → Fin n) (q : Fin n → ℝ)
    (h_strict : ∀ i, M i ≠ i → q i < q (M i)) :
    ∃ i, M i = i := by
  contrapose! h_strict with h;
  -- Consider the maximum value of $q$ over all elements in $Fin n$.
  obtain ⟨i₀, hi₀⟩ : ∃ i₀ : Fin n, ∀ i : Fin n, q i₀ ≥ q i := by
    simpa using Finset.exists_max_image Finset.univ q ( Finset.univ_nonempty_iff.mpr ⟨ 0, hn ⟩ );
  exact ⟨ i₀, h i₀, hi₀ _ ⟩




/-- The improvement ratio after n steps of a contraction with rate k. -/
def improvementRatio (k : ℝ) (n : ℕ) : ℝ := 1 - k ^ n




/-- The improvement ratio approaches 1 (complete improvement) as n → ∞. -/
theorem improvementRatio_tendsto_one (k : ℝ) (hk : 0 < k) (hk1 : k < 1) :
    Filter.Tendsto (improvementRatio k) Filter.atTop (nhds 1) := by
  unfold improvementRatio
  have h := tendsto_pow_atTop_nhds_zero_of_lt_one (le_of_lt hk) hk1
  convert Filter.Tendsto.const_sub 1 h using 1 <;> ring




/-- Number of iterations needed to achieve ε-optimality. -/
def iterationsNeeded (k ε d₀ : ℝ) : ℝ :=
  Real.log (ε / d₀) / Real.log k




/-- The number of iterations needed is proportional to 1/H where H is oracle entropy. -/
theorem iterations_proportional_to_inv_entropy
    (k ε d₀ : ℝ) (_hk : 0 < k) (_hk1 : k < 1) (_hε : 0 < ε) (_hd : 0 < d₀) :
    iterationsNeeded k ε d₀ = Real.log (ε / d₀) / (-(-Real.log k)) := by
  unfold iterationsNeeded
  ring




/-- Meta-oracles on a fixed type form a semigroup under composition. -/
instance metaOracleSemigroup (α : Type*) : Semigroup (α → α) where
  mul := Function.comp
  mul_assoc := Function.comp_assoc




/-- Meta-oracles on a fixed type form a monoid with identity. -/
instance metaOracleMonoid (α : Type*) : Monoid (α → α) where
  one := id
  one_mul := Function.id_comp
  mul_one := Function.comp_id




/-- If f and g both contract with rates k₁ and k₂, then f ∘ g contracts with rate k₁ * k₂. -/
theorem comp_contraction_rate {α : Type*} [PseudoMetricSpace α]
    (f g : α → α) (k₁ k₂ : ℝ)
    (hk₁ : 0 ≤ k₁) (_hk₂ : 0 ≤ k₂)
    (hf : ∀ x y, dist (f x) (f y) ≤ k₁ * dist x y)
    (hg : ∀ x y, dist (g x) (g y) ≤ k₂ * dist x y) :
    ∀ x y, dist ((f ∘ g) x) ((f ∘ g) y) ≤ (k₁ * k₂) * dist x y := by
  intro x y
  simp only [Function.comp_apply]
  calc dist (f (g x)) (f (g y))
      ≤ k₁ * dist (g x) (g y) := hf _ _
    _ ≤ k₁ * (k₂ * dist x y) := by
        apply mul_le_mul_of_nonneg_left (hg _ _) hk₁
    _ = (k₁ * k₂) * dist x y := by ring




/-- A weighted combination of quality values (portfolio quality). -/
def portfolioQuality {n : ℕ} (weights : Fin n → ℝ) (qualities : Fin n → ℝ) : ℝ :=
  ∑ i, weights i * qualities i




/-- [Section: # CatalogBuild.Computation.Oracles.MetaOracleAdvanced
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 12] -/
theorem portfolio_quality_bounded {n : ℕ} (hn : 0 < n)
    (w : Fin n → ℝ) (q : Fin n → ℝ)
    (hw_nn : ∀ i, 0 ≤ w i)
    (hw_sum : ∑ i, w i = 1) :
    (∃ i, q i ≤ portfolioQuality w q) ∧ (∃ i, portfolioQuality w q ≤ q i) := by
  constructor;
  · -- Let $j$ be an index such that $q_j$ is the minimum among the $q_i$.
    obtain ⟨j, hj⟩ : ∃ j, ∀ i, q i ≥ q j := by
      simpa using Finset.exists_min_image Finset.univ ( fun i => q i ) ⟨ ⟨ 0, hn ⟩, Finset.mem_univ _ ⟩;
    exact ⟨ j, by simpa [ ← Finset.sum_mul _ _ _, hw_sum ] using Finset.sum_le_sum fun i ( hi : i ∈ Finset.univ ) => mul_le_mul_of_nonneg_left ( hj i ) ( hw_nn i ) ⟩;
  · -- Since the weights are non-negative and sum to 1, the weighted average of the qualities is bounded above by the maximum quality.
    have h_max : ∃ i, ∀ j, q j ≤ q i := by
      simpa using Finset.exists_max_image Finset.univ q ⟨ ⟨ 0, hn ⟩, Finset.mem_univ _ ⟩;
    exact ⟨ h_max.choose, le_trans ( Finset.sum_le_sum fun i _ => mul_le_mul_of_nonneg_left ( h_max.choose_spec i ) ( hw_nn i ) ) ( by simp +decide [ ← Finset.sum_mul, hw_sum ] ) ⟩




end
```

@Algebra/AutoResearch/ArithmeticDarkMatter.lean
```lean
import Mathlib

/-! # CatalogBuild.Algebra.Core.ArithmeticDarkMatter

Auto-generated from theorem catalog database.
Domain: Algebra/Core
Declarations: 24
-/


/-- The Lorentz form Q(a,b,c) = a² + b² - c² -/
def Q_form (a b c : ℤ) : ℤ := a ^ 2 + b ^ 2 - c ^ 2




/-- An arithmetic particle: an integer triple with its mass classification -/
structure ArithParticle where
  a : ℤ
  b : ℤ
  c : ℤ
  a_pos : 0 < a
  b_pos : 0 < b
  c_pos : 0 < c




/-- The mass-squared of a particle -/
def ArithParticle.massSq (p : ArithParticle) : ℤ :=
  p.c ^ 2 - p.a ^ 2 - p.b ^ 2




/-- A particle is a photon (null/massless) -/
def ArithParticle.isPhoton (p : ArithParticle) : Prop :=
  p.massSq = 0




/-- A particle is massive (timelike) -/
def ArithParticle.isMassive' (p : ArithParticle) : Prop :=
  p.massSq > 0




/-- A particle is tachyonic (spacelike) -/
def ArithParticle.isTachyon (p : ArithParticle) : Prop :=
  p.massSq < 0




/-- The mass spectrum: which mass-squared values are realized? -/
def massIsRealized (m_sq : ℤ) : Prop :=
  ∃ a b c : ℤ, 0 < a ∧ 0 < b ∧ 0 < c ∧ c ^ 2 - a ^ 2 - b ^ 2 = m_sq




/-- [Section: # CatalogBuild.Algebra.Core.ArithmeticDarkMatter
Auto-generated from theorem catalog database.
Domain: Algebra/Core
Declarations: 24] -/
theorem every_nonneg_mass_realized (m_sq : ℕ) :
    massIsRealized (m_sq : ℤ) := by
  by_contra h;
  -- For even m_sq, we can take a=1, b=m_sq/2, c=m_sq/2+1.
  by_cases h_even : Even m_sq;
  · obtain ⟨ k, rfl ⟩ := h_even;
    exact h ⟨ 1, k, k + 1, by norm_num, by linarith [ show k > 0 from Nat.pos_of_ne_zero ( by rintro rfl; exact h ⟨ 3, 4, 5, by norm_num ⟩ ) ], by linarith [ show k > 0 from Nat.pos_of_ne_zero ( by rintro rfl; exact h ⟨ 3, 4, 5, by norm_num ⟩ ) ], by push_cast; linarith ⟩;
  · -- For odd m_sq, we can take a=2, b=(m_sq+3)/2, c=(m_sq+5)/2.
    obtain ⟨k, hk⟩ : ∃ k : ℕ, m_sq = 2 * k + 1 := by
      exact m_sq.even_or_odd.resolve_left h_even;
    refine h ⟨ 2, k + 2, k + 3, by norm_num, by linarith, by linarith, ?_ ⟩ ; push_cast [ hk ] ; ring




/-- The Berggren B₁ matrix action on a triple -/
def berggren_B1 (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)




/-- The Berggren matrices preserve Q (the full Lorentz form, not just Q=0) -/
theorem B1_preserves_Q (a b c : ℤ) :
    Q_form (berggren_B1 a b c).1 (berggren_B1 a b c).2.1 (berggren_B1 a b c).2.2
    = Q_form a b c := by
  unfold berggren_B1 Q_form
  ring




/-- B₂ also preserves Q -/
def berggren_B2 (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)




/-- [Section: # CatalogBuild.Algebra.Core.ArithmeticDarkMatter
Auto-generated from theorem catalog database.
Domain: Algebra/Core
Declarations: 24] -/
theorem B2_preserves_Q (a b c : ℤ) :
    Q_form (berggren_B2 a b c).1 (berggren_B2 a b c).2.1 (berggren_B2 a b c).2.2
    = Q_form a b c := by
  unfold berggren_B2 Q_form
  ring




/-- B₃ also preserves Q -/
def berggren_B3 (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)




theorem B3_preserves_Q (a b c : ℤ) :
    Q_form (berggren_B3 a b c).1 (berggren_B3 a b c).2.1 (berggren_B3 a b c).2.2
    = Q_form a b c := by
  unfold berggren_B3 Q_form
  ring




/-- A path in the dark matter tree (same branching as the photon tree) -/
inductive DarkPath where
  | root : DarkPath
  | b1 : DarkPath → DarkPath
  | b2 : DarkPath → DarkPath
  | b3 : DarkPath → DarkPath
  deriving Repr




/-- The triple at a given dark matter path, starting from seed (a₀, b₀, c₀) -/
def darkTriple (seed : ℤ × ℤ × ℤ) : DarkPath → ℤ × ℤ × ℤ
  | .root => seed
  | .b1 p =>
-- ... (truncated, full file has 299 lines)
```

@Algebra/AutoResearch/DeepOpenProblems.lean
```lean
import Mathlib

/-! # CatalogBuild.Pythagorean.ThreeRoads.DeepOpenProblems

Auto-generated from theorem catalog database.
Domain: Pythagorean/ThreeRoads
Declarations: 35
-/

/-- The gap c² - 2ab = (a-b)² is always a perfect square. -/
theorem smooth_density_gap_square (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    c ^ 2 - 2 * a * b = (a - b) ^ 2 := by nlinarith

/-- The minimum gap when a ≠ b is 1, giving 2ab ≤ c² - 1. -/
theorem smooth_density_min_gap (a b c : ℤ) (ha : 0 < a) (hb : 0 < b)
    (h : a ^ 2 + b ^ 2 = c ^ 2) (hne : a ≠ b) :
    2 * a * b ≤ c ^ 2 - 1 := by
  have : (a - b) ^ 2 ≥ 1 := by
    nlinarith [sq_abs (a - b), abs_pos.mpr (sub_ne_zero.mpr hne)]
  nlinarith [smooth_density_gap_square a b c h]

/-- Leg sum identities for each branch. -/
theorem B1_leg_sum (a b c : ℤ) :
    (a - 2*b + 2*c) + (2*a - b + 2*c) = 3*a - 3*b + 4*c := by ring

/-- [Section: # CatalogBuild.Pythagorean.ThreeRoads.DeepOpenProblems
Auto-generated from theorem catalog database.
Domain: Pythagorean/ThreeRoads
Declarations: 35] -/
theorem B2_leg_sum (a b c : ℤ) :
    (a + 2*b + 2*c) + (2*a + b + 2*c) = 3*a + 3*b + 4*c := by ring

/-- [Section: # CatalogBuild.Pythagorean.ThreeRoads.DeepOpenProblems
Auto-generated from theorem catalog database.
Domain: Pythagorean/ThreeRoads
Declarations: 35] -/
theorem B3_leg_sum (a b c : ℤ) :
    (-a + 2*b + 2*c) + (-2*a + b + 2*c) = -3*a + 3*b + 4*c := by ring

/-- The B₂ child's leg product expanded. -/
theorem B2_leg_product_expanded (a b c : ℤ) :
    (a + 2*b + 2*c) * (2*a + b + 2*c) =
    2*a^2 + 5*a*b + 2*b^2 + 6*a*c + 6*b*c + 4*c^2 := by ring

/-- B₂ has determinant -1. -/
theorem B2_det_value : (1 : ℤ) * (1*3 - 2*2) - 2 * (2*3 - 2*2) +
    2 * (2*2 - 1*2) = -1 := by norm_num

/-- The product of two matrices with det ±1 has det 1. -/
theorem berggren_product_det_one : (-1 : ℤ) * (-1) = 1 := by norm_num

/-- After d steps, the determinant is (-1)^d. -/
theorem berggren_path_det (d : ℕ) : (-1 : ℤ) ^ d = 1 ∨ (-1 : ℤ) ^ d = -1 := by
  rcases Nat.even_or_odd d with ⟨k, hk⟩ | ⟨k, hk⟩
  · left; simp [hk, pow_mul, pow_succ, neg_one_sq]
  · right; simp [hk, pow_add, pow_mul, pow_succ, neg_one_sq]

theorem B2_quadratic_discriminant : (4 : ℤ)^2 - 4*1*1 = 12 := by norm_num

theorem eigenvalue_one_B2 : (1 : ℤ)^3 - 5*(1)^2 + 5*1 - 1 = 0 := by norm_num

/-- The spectral radius of B₂ satisfies ρ²-4ρ+1=0, so ρ = 2+√3. -/
theorem spectral_radius_B2_equation :
    (2 + Real.sqrt 3) ^ 2 - 4 * (2 + Real.sqrt 3) + 1 = 0 := by
  set s := Real.sqrt 3 with hs_def
  have h3 : s * s = 3 := Real.mul_self_sqrt (by norm_num : (3:ℝ) ≥ 0)
  have hsq : s ^ 2 = s * s := sq s
  nlinarith [hsq, h3]

theorem B1_char_poly_factored (x : ℤ) :
    x^3 - 3*x^2 + 3*x - 1 = (x - 1)^3 := by ring

theorem B2_eigenvalue_product :
    (2 + Real.sqrt 3) * (2 - Real.sqrt 3) = 1 := by
  have : Real.sqrt 3 ^ 2 = 3 := Real.sq_sqrt (by norm_num : (3:ℝ) ≥ 0)
  nlinarith

theorem B2_hyp_growth_factor (a b c : ℤ) (ha : 0 < a) (hb : 0 < b)
    (h : a ^ 2 + b ^ 2 = c ^ 2) :
    3 * c ≤ 2*a + 2*b + 3*c := by nlinarith

theorem B2_hyp_growth_upper (a b c : ℤ) (ha : 0 < a) (hb : 0 < b)
    (hc : 0 < c) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    2*a + 2*b + 3*c < 7 * c := by
  have ha_lt : a < c := by nlinarith [sq_nonneg b]
  have hb_lt : b < c := by nlinarith [sq_nonneg a]
  linarith

theorem total_paths_bound (d : ℕ) : 3^(d+1) - 1 ≥ 2 * 3^d := by
  have : 3^(d+1) = 3^d * 3 := pow_succ 3 d
  omega

theorem euclid_B1_transform (m n : ℤ) :
    let m' := 2*m - n
    let n' := m
    m' + n' = 3*m - n ∧ m' - n' = m - n := by constructor <;> ring

theorem grover_cost_bound (d : ℕ) : Nat.sqrt (3^d) ≤ 3^d := Nat.sqrt_le_self _

theorem classical_tree_search_lower (d : ℕ) : 3^d ≥ d + 1 := by
  induction d with
  | zero => norm_num
  | succ n ih =>
    have h3 : 3^(n+1) = 3^n * 3 := pow_succ 3 n
    omega

theorem qs_tree_sieve_bridge (N x : ℤ) :
    x^2 - N^2 = (x - N) * (x + N) := by ring

theorem tree_sieve_value_divides (N b c : ℤ) (h : N^2 + b^2 = c^2) :
    (c - b) ∣ N^2 := ⟨c + b, by linarith⟩

theorem tree_sieve_complement_divides (N b c : ℤ) (h : N^2 + b^2 = c^2) :
    (c + b) ∣ N^2 := ⟨c - b, by linarith⟩

theorem root_triple : (3 : ℤ)^2 + 4^2 = 5^2 := by norm_num

theorem level1_products :
    (5 : ℕ) * 12 = 60 ∧ 21 * 20 = 420 ∧ 15 * 8 = 120 := by norm_num

theorem level1_all_7_smooth :
    60 = 2^2 * 3 * 5 ∧ 420 = 2^2 * 3 * 5 * 7 ∧ 120 = 2^3 * 3 * 5 := by norm_num

theorem berggren_B1_injective (a₁ b₁ c₁ a₂ b₂ c₂ : ℤ)
    (h_a : a₁ - 2*b₁ + 2*c₁ = a₂ - 2*b₂ + 2*c₂)
    (h_b : 2*a₁ - b₁ + 2*c₁ = 2*a₂ - b₂ + 2*c₂)
    (h_c : 2*a₁ - 2*b₁ + 3*c₁ = 2*a₂ - 2*b₂ + 3*c₂) :
    a₁ = a₂ ∧ b₁ = b₂ ∧ c₁ = c₂ := by
  constructor; · linarith
  constructor <;> linarith

theorem berggren_B2_injective (a₁ b₁ c₁ a₂ b₂ c₂ : ℤ)
    (h_a : a₁ + 2*b₁ + 2*c₁ = a₂ + 2*b₂ + 2*c₂)
    (h_b : 2*a₁ + b₁ + 2*c₁ = 2*a₂ + b₂ + 2*c₂)
    (h_c : 2*a₁ + 2*b₁ + 3*c₁ = 2*a₂ + 2*b₂ + 3*c₂) :
    a₁ = a₂ ∧ b₁ = b₂ ∧ c₁ = c₂ := by
  constructor; · linarith
  constructor <;> linarith

theorem berggren_B3_injective (a₁ b₁ c₁ a₂ b₂ c₂ : ℤ)
    (h_a : -a₁ + 2*b₁ + 2*c₁ = -a₂ + 2*b₂ + 2*c₂)
    (h_b : -2*a₁ + b₁ + 2*c₁ = -2*a₂ + b₂ + 2*c₂)
    (h_c : -2*a₁ + 2*b₁ + 3*c₁ = -2*a₂ + 2*b₂ + 3*c₂) :
    a₁ = a₂ ∧ b₁ = b₂ ∧ c₁ = c₂ := by
  constructor; · linarith
  constructor <;> linarith

theorem poincare_on_circle (a b c : ℤ) (hc : c ≠ 0)
    (h : a^2 + b^2 = c^2) :
    (a : ℚ)^2 / (c : ℚ)^2 + (b : ℚ)^2 / (c : ℚ)^2 = 1 := by
-- ... (truncated, full file has 174 lines)
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

Research domain: Algebra
Research mode: discover
