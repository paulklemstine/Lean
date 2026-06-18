            ## YOUR ASSIGNMENT: algebra_breakthrough_discovery

            **TARGET DOMAIN**: Algebra

**PRECISE ASSIGNMENT**: Survey the catalog infrastructure in Algebra. Identify the deepest structural result you can prove. Construct definitions that organize the territory, then prove theorems about them.

**PROOF STRATEGY**: Start from the existing catalog theorems listed below. Look for patterns that suggest isomorphisms, functors, or equivalence results. Every theorem you prove should open a door to three more.

**FAILURE MODE**: Do not produce trivial tautologies. If you cannot find deep structure, state precise conjectures about what you observe.

**CATALOG INFRASTRUCTURE**: Build directly on: 438dd389_aristotle/Algebra/HopfRenormalization/BerggrenHopfCore.lean, 438dd389_aristotle/Catalog/Algebra/HopfRenormalization/BerggrenHopfCore.lean, Algebra/AdditiveCombinatorics/MontgomeryPairCorrelation.lean, Algebra/Advanced/MetaOracleAdvanced.lean
**KEY REFERENCES**: 438dd389_aristotle/Algebra/HopfRenormalization/BerggrenHopfCore.lean, 438dd389_aristotle/Catalog/Algebra/HopfRenormalization/BerggrenHopfCore.lean, Algebra/AdditiveCombinatorics/MontgomeryPairCorrelation.lean

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
            Discover deep theorems in Algebra (5271 declarations, exploration ratio 5271.0).  This domain shares category, field, functor, group, hilbert, lattice, manifold, measure, metric, metricspace, module, monoid, norm, normed, order, ring, semiring, topological, topologicalspace, topology, tropical structures with MachineLearning but no bridge exists. Find unexpected structure, prove non-trivial results, open new territory.

            ### Precise Mathematical Framing
            Survey Algebra for under-explored theorems. The catalog has 5271 declarations but few deep results. Look for: (1) structural theorems connecting existing definitions, (2) unexpected isomorphisms between objects in Algebra, (3) algorithmic results that leverage the existing infrastructure.



            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `tropical_lattice_norm_bridge` : theorem tropical_lattice_norm_bridge [NeZero n] (u v : Fin n → ℝ) :
     (file: Cryptography/TropicalPostQuantumPrimitives.lean)
  2. `norm_congruence_bridge` : theorem norm_congruence_bridge (p : ℕ) (hp : Nat.Prime p) (hmod : p % 4 = 3)
     (file: Algebra/Core/OpenQuestions.lean)
  3. `any_semiring_reduced_basis_exists` : theorem any_semiring_reduced_basis_exists {A : Type*} [Semiring A]
     (file: Algebra/EMLCongruenceHilbert.lean)
  4. `symmetric_group_order` : theorem symmetric_group_order (n : ℕ) :
     (file: Algebra/Factoring/FutureExploration.lean)
  5. `qdf_symmetry_group_order` : theorem qdf_symmetry_group_order :
     (file: Algebra/IntegerEnergy/QDF_HE_Frontiers.lean)

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



Recent successful concepts: Non-Archimedean Quantum Information: p-Adic Density Matrix Certification, Ultrametric Von Neumann Entropy Subadditivity, and Valuation Quantum Capacity Bounds, Galois-Theoretic Deep Learning: Architecture-Extension Correspondence, Solvable Network Expressivity Certification, and Derived Depth Lower Bounds, Persistent Homology of Proof Complexes: Barcode Obstruction Classification, Betti Number Length Certification, and Theory Perturbation Stability


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
               • ALL images MUST be embedded as base64 data URIs:
                 `<img src="data:image/png;base64,..." />` for PNGs,
                 `<img src="data:image/svg+xml;base64,..." />` for SVGs.
                 For SVG diagrams, prefer inlining `<svg>...</svg>` markup directly.
                 If you generate matplotlib/plotly charts, convert to base64 and embed.
                 NEVER reference external image files — they won't exist standalone.
               • Tab/sidebar navigation: Article, Research Paper, Demos, Algorithms,
                 Visualizations, Code Listings
               • Modern design: clean typography, dark/light toggle, responsive layout
               • KaTeX for math rendering (CDN OK), syntax-highlighted code blocks
               • Collapsible sections, smooth scroll, table of contents
               • Must work when opened directly in any browser

            Produce novel, non-trivial theorems with complete Lean 4 proofs. Think big — aim for results that would appear in JAMS, Annals, or FOCS.

            ### Catalog Reference Files
            @438dd389_aristotle/Algebra/HopfRenormalization/BerggrenHopfCore.lean
```lean
import Mathlib

/-!
# Berggren-Hopf Algebra: Graded Coproduct Decomposition,
# Antipode-Factoring Correspondence, and Birkhoff Renormalization
# of Pythagorean Triples

This file inaugurates **Hopf-algebraic Diophantine theory**: a framework where
the algebraic structure of integer factorization is read off the graded
decomposition of a coalgebra built from primitive Pythagorean triples via the
Berggren tree.

## Bridge: Diophantine number theory (Pythagorean triples, prime factorization)
↔ Hopf algebra (graded coproduct, antipode, Birkhoff decomposition)
↔ post-quantum cryptography (factoring hardness, antipode complexity)
↔ Connes-Kreimer renormalization (counterterms, forest formula)

## Main Results

1. **Berggren matrices** preserve the Pythagorean-Lorentz quadratic form and
   have explicit determinants (+1, -1, +1), establishing O(2,1;ℤ) membership.
2. **Hypotenuse growth bounds**: explicit linear bounds on children's hypotenuses.
3. **Graded structure**: hypotenuse-based grading with connected degree-0.
4. **Antipode complexity lower bound**: 2^ω(c) operations, ω = distinct prime factors.
5. **B-branch exponential growth**: 5^n lower bound on B-branch hypotenuses.
-/

set_option maxHeartbeats 800000

/-! ## Part I: Berggren Matrices and Lorentz Structure -/

namespace BerggrenHopf

/-- The Lorentz quadratic form Q(a,b,c) = a² + b² - c².
    For Pythagorean triples, Q = 0. The Berggren matrices preserve this form,
    making them elements of O(2,1;ℤ).
    Bridge: connects Diophantine geometry to Lorentzian structure. -/
def lorentzQ (a b c : ℤ) : ℤ := a ^ 2 + b ^ 2 - c ^ 2

/-- A triple (a,b,c) is Pythagorean iff a² + b² = c². -/
def IsPythag (a b c : ℤ) : Prop := a ^ 2 + b ^ 2 = c ^ 2

/-- Berggren matrix B₁ (child A). -/
def B₁ : Matrix (Fin 3) (Fin 3) ℤ := !![1, -2, 2; 2, -1, 2; 2, -2, 3]

/-- Berggren matrix B₂ (child B). -/
def B₂ : Matrix (Fin 3) (Fin 3) ℤ := !![1, 2, 2; 2, 1, 2; 2, 2, 3]

/-- Berggren matrix B₃ (child C). -/
def B₃ : Matrix (Fin 3) (Fin 3) ℤ := !![-1, 2, 2; -2, 1, 2; -2, 2, 3]

/-- The Lorentz metric matrix diag(1,1,-1). -/
def QLor : Matrix (Fin 3) (Fin 3) ℤ := !![1, 0, 0; 0, 1, 0; 0, 0, -1]

/-- THEOREM 1: Determinant asymmetry of Berggren matrices.
    B₁ and B₃ have det = +1 (proper Lorentz), B₂ has det = -1 (improper).
    Bridge: connects tree branching to orientation in O(2,1;ℤ). -/
theorem berggren_det_B₁ : Matrix.det B₁ = 1 := by native_decide
theorem berggren_det_B₂ : Matrix.det B₂ = -1 := by native_decide
theorem berggren_det_B₃ : Matrix.det B₃ = 1 := by native_decide

/-- THEOREM 2: Det asymmetry combined — two proper, one improper Lorentz.
    Bridge: algebraic topology (orientation) ↔ number theory (generation). -/
theorem berggren_det_asymmetry :
    Matrix.det B₁ = 1 ∧ Matrix.det B₂ = -1 ∧ Matrix.det B₃ = 1 :=
  ⟨berggren_det_B₁, berggren_det_B₂, berggren_det_B₃⟩

/-- THEOREM 3: B₁ preserves the Lorentz form Q = diag(1,1,-1).
    Establishes B₁ ∈ O(2,1;ℤ), the integer Lorentz group.
    Bridge: Pythagorean preservation ↔ Lorentz invariance. -/
theorem B₁_lorentz : B₁.transpose * QLor * B₁ = QLor := by native_decide
theorem B₂_lorentz : B₂.transpose * QLor * B₂ = QLor := by native_decide
theorem B₃_lorentz : B₃.transpose * QLor * B₃ = QLor := by native_decide

/-- THEOREM 4: All Berggren matrices lie in O(2,1;ℤ).
    Bridge: the Berggren tree is a subgroup orbit in the Lorentz group. -/
theorem berggren_all_lorentz :
    B₁.transpose * QLor * B₁ = QLor ∧
    B₂.transpose * QLor * B₂ = QLor ∧
    B₃.transpose * QLor * B₃ = QLor :=
  ⟨B₁_lorentz, B₂_lorentz, B₃_lorentz⟩

/-- THEOREM 5: Pairwise products preserve Lorentz form — subgroup closure.
    Bridge: closure under products ↔ subgroup generation of O(2,1;ℤ). -/
theorem B₁B₂_lorentz :
    (B₁ * B₂).transpose * QLor * (B₁ * B₂) = QLor := by native_decide
theorem B₁B₃_lorentz :
    (B₁ * B₃).transpose * QLor * (B₁ * B₃) = QLor := by native_decide
theorem B₂B₃_lorentz :
    (B₂ * B₃).transpose * QLor * (B₂ * B₃) = QLor := by native_decide

/-- THEOREM 6: det(B₁ · B₂) = -1 — det homomorphism preserved.
    Bridge: determinant homomorphism ↔ graded structure on the Lorentz group. -/
theorem det_B₁B₂ : Matrix.det (B₁ * B₂) = -1 := by native_decide
theorem det_B₁B₃ : Matrix.det (B₁ * B₃) = 1 := by native_decide

/-! ## Part II: Berggren Children and Pythagorean Preservation -/

/-- Berggren child A: applies B₁ to triple (a,b,c). -/
def bergA (a b c : ℤ) : ℤ × ℤ × ℤ := (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

/-- Berggren child B: applies B₂ to triple (a,b,c). -/
def bergB (a b c : ℤ) : ℤ × ℤ × ℤ := (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

/-- Berggren child C: applies B₃ to triple (a,b,c). -/
def bergC (a b c : ℤ) : ℤ × ℤ × ℤ := (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

/-- THEOREM 7: All Berggren children preserve the Pythagorean property.
    Foundation of Berggren tree enumeration.
    Bridge: tree generation ↔ Diophantine invariants. -/
theorem bergA_preserves_pythag (a b c : ℤ) (h : IsPythag a b c) :
    IsPythag (bergA a b c).1 (bergA a b c).2.1 (bergA a b c).2.2 := by
  unfold IsPythag bergA at *; nlinarith [h]

theorem bergB_preserves_pythag (a b c : ℤ) (h : IsPythag a b c) :
    IsPythag (bergB a b c).1 (bergB a b c).2.1 (bergB a b c).2.2 := by
  unfold IsPythag bergB at *; nlinarith [h]

theorem bergC_preserves_pythag (a b c : ℤ) (h : IsPythag a b c) :
    IsPythag (bergC a b c).1 (bergC a b c).2.1 (bergC a b c).2.2 := by
  unfold IsPythag bergC at *; nlinarith [h]

/-- THEOREM 8: Berggren children preserve the Lorentz quadratic form.
    Bridge: Q-preservation ↔ gauge invariance in the Hopf-algebraic setting. -/
theorem bergA_preserves_Q (a b c : ℤ) :
    lorentzQ (bergA a b c).1 (bergA a b c).2.1 (bergA a b c).2.2 = lorentzQ a b c := by
  unfold lorentzQ bergA; ring

theorem bergB_preserves_Q (a b c : ℤ) :
    lorentzQ (bergB a b c).1 (bergB a b c).2.1 (bergB a b c).2.2 = lorentzQ a b c := by
  unfold lorentzQ bergB; ring

theorem bergC_preserves_Q (a b c : ℤ) :
    lorentzQ (bergC a b c).1 (bergC a b c).2.1 (bergC a b c).2.2 = lorentzQ a b c := by
  unfold lorentzQ bergC; ring

/-! ## Part III: Hypotenuse Growth Bounds -/

/-- The hypotenuse of child B. -/
def hypB (a b c : ℤ) : ℤ := 2*a + 2*b + 3*c

/-- THEOREM 9: Hypotenuse of child B exceeds parent (when legs positive).
    Bridge: depth ↔ O(log c) complexity for tree navigation. -/
theorem hypB_strict_growth (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    c < hypB a b c := by
  unfold hypB; linarith

/-- THEOREM 10: Child B hypotenuse lower bound: c_B ≥ 3c.
    Bridge: O(log c) depth bound ↔ efficient tree algorithms. -/
theorem hypB_lower_bound (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) :
-- ... (truncated, full file has 608 lines)
```

@438dd389_aristotle/Catalog/Algebra/HopfRenormalization/BerggrenHopfCore.lean
```lean
import Mathlib

/-!
# Berggren-Hopf Algebra: Graded Coproduct Decomposition,
# Antipode-Factoring Correspondence, and Birkhoff Renormalization
# of Pythagorean Triples

This file inaugurates **Hopf-algebraic Diophantine theory**: a framework where
the algebraic structure of integer factorization is read off the graded
decomposition of a coalgebra built from primitive Pythagorean triples via the
Berggren tree.

## Bridge: Diophantine number theory (Pythagorean triples, prime factorization)
↔ Hopf algebra (graded coproduct, antipode, Birkhoff decomposition)
↔ post-quantum cryptography (factoring hardness, antipode complexity)
↔ Connes-Kreimer renormalization (counterterms, forest formula)

## Main Results

1. **Berggren matrices** preserve the Pythagorean-Lorentz quadratic form and
   have explicit determinants (+1, -1, +1), establishing O(2,1;ℤ) membership.
2. **Hypotenuse growth bounds**: explicit linear bounds on children's hypotenuses.
3. **Graded structure**: hypotenuse-based grading with connected degree-0.
4. **Antipode complexity lower bound**: 2^ω(c) operations, ω = distinct prime factors.
5. **B-branch exponential growth**: 5^n lower bound on B-branch hypotenuses.
-/

set_option maxHeartbeats 800000

/-! ## Part I: Berggren Matrices and Lorentz Structure -/

namespace BerggrenHopf

/-- The Lorentz quadratic form Q(a,b,c) = a² + b² - c².
    For Pythagorean triples, Q = 0. The Berggren matrices preserve this form,
    making them elements of O(2,1;ℤ).
    Bridge: connects Diophantine geometry to Lorentzian structure. -/
def lorentzQ (a b c : ℤ) : ℤ := a ^ 2 + b ^ 2 - c ^ 2

/-- A triple (a,b,c) is Pythagorean iff a² + b² = c². -/
def IsPythag (a b c : ℤ) : Prop := a ^ 2 + b ^ 2 = c ^ 2

/-- Berggren matrix B₁ (child A). -/
def B₁ : Matrix (Fin 3) (Fin 3) ℤ := !![1, -2, 2; 2, -1, 2; 2, -2, 3]

/-- Berggren matrix B₂ (child B). -/
def B₂ : Matrix (Fin 3) (Fin 3) ℤ := !![1, 2, 2; 2, 1, 2; 2, 2, 3]

/-- Berggren matrix B₃ (child C). -/
def B₃ : Matrix (Fin 3) (Fin 3) ℤ := !![-1, 2, 2; -2, 1, 2; -2, 2, 3]

/-- The Lorentz metric matrix diag(1,1,-1). -/
def QLor : Matrix (Fin 3) (Fin 3) ℤ := !![1, 0, 0; 0, 1, 0; 0, 0, -1]

/-- THEOREM 1: Determinant asymmetry of Berggren matrices.
    B₁ and B₃ have det = +1 (proper Lorentz), B₂ has det = -1 (improper).
    Bridge: connects tree branching to orientation in O(2,1;ℤ). -/
theorem berggren_det_B₁ : Matrix.det B₁ = 1 := by native_decide
theorem berggren_det_B₂ : Matrix.det B₂ = -1 := by native_decide
theorem berggren_det_B₃ : Matrix.det B₃ = 1 := by native_decide

/-- THEOREM 2: Det asymmetry combined — two proper, one improper Lorentz.
    Bridge: algebraic topology (orientation) ↔ number theory (generation). -/
theorem berggren_det_asymmetry :
    Matrix.det B₁ = 1 ∧ Matrix.det B₂ = -1 ∧ Matrix.det B₃ = 1 :=
  ⟨berggren_det_B₁, berggren_det_B₂, berggren_det_B₃⟩

/-- THEOREM 3: B₁ preserves the Lorentz form Q = diag(1,1,-1).
    Establishes B₁ ∈ O(2,1;ℤ), the integer Lorentz group.
    Bridge: Pythagorean preservation ↔ Lorentz invariance. -/
theorem B₁_lorentz : B₁.transpose * QLor * B₁ = QLor := by native_decide
theorem B₂_lorentz : B₂.transpose * QLor * B₂ = QLor := by native_decide
theorem B₃_lorentz : B₃.transpose * QLor * B₃ = QLor := by native_decide

/-- THEOREM 4: All Berggren matrices lie in O(2,1;ℤ).
    Bridge: the Berggren tree is a subgroup orbit in the Lorentz group. -/
theorem berggren_all_lorentz :
    B₁.transpose * QLor * B₁ = QLor ∧
    B₂.transpose * QLor * B₂ = QLor ∧
    B₃.transpose * QLor * B₃ = QLor :=
  ⟨B₁_lorentz, B₂_lorentz, B₃_lorentz⟩

/-- THEOREM 5: Pairwise products preserve Lorentz form — subgroup closure.
    Bridge: closure under products ↔ subgroup generation of O(2,1;ℤ). -/
theorem B₁B₂_lorentz :
    (B₁ * B₂).transpose * QLor * (B₁ * B₂) = QLor := by native_decide
theorem B₁B₃_lorentz :
    (B₁ * B₃).transpose * QLor * (B₁ * B₃) = QLor := by native_decide
theorem B₂B₃_lorentz :
    (B₂ * B₃).transpose * QLor * (B₂ * B₃) = QLor := by native_decide

/-- THEOREM 6: det(B₁ · B₂) = -1 — det homomorphism preserved.
    Bridge: determinant homomorphism ↔ graded structure on the Lorentz group. -/
theorem det_B₁B₂ : Matrix.det (B₁ * B₂) = -1 := by native_decide
theorem det_B₁B₃ : Matrix.det (B₁ * B₃) = 1 := by native_decide

/-! ## Part II: Berggren Children and Pythagorean Preservation -/

/-- Berggren child A: applies B₁ to triple (a,b,c). -/
def bergA (a b c : ℤ) : ℤ × ℤ × ℤ := (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

/-- Berggren child B: applies B₂ to triple (a,b,c). -/
def bergB (a b c : ℤ) : ℤ × ℤ × ℤ := (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

/-- Berggren child C: applies B₃ to triple (a,b,c). -/
def bergC (a b c : ℤ) : ℤ × ℤ × ℤ := (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

/-- THEOREM 7: All Berggren children preserve the Pythagorean property.
    Foundation of Berggren tree enumeration.
    Bridge: tree generation ↔ Diophantine invariants. -/
theorem bergA_preserves_pythag (a b c : ℤ) (h : IsPythag a b c) :
    IsPythag (bergA a b c).1 (bergA a b c).2.1 (bergA a b c).2.2 := by
  unfold IsPythag bergA at *; nlinarith [h]

theorem bergB_preserves_pythag (a b c : ℤ) (h : IsPythag a b c) :
    IsPythag (bergB a b c).1 (bergB a b c).2.1 (bergB a b c).2.2 := by
  unfold IsPythag bergB at *; nlinarith [h]

theorem bergC_preserves_pythag (a b c : ℤ) (h : IsPythag a b c) :
    IsPythag (bergC a b c).1 (bergC a b c).2.1 (bergC a b c).2.2 := by
  unfold IsPythag bergC at *; nlinarith [h]

/-- THEOREM 8: Berggren children preserve the Lorentz quadratic form.
    Bridge: Q-preservation ↔ gauge invariance in the Hopf-algebraic setting. -/
theorem bergA_preserves_Q (a b c : ℤ) :
    lorentzQ (bergA a b c).1 (bergA a b c).2.1 (bergA a b c).2.2 = lorentzQ a b c := by
  unfold lorentzQ bergA; ring

theorem bergB_preserves_Q (a b c : ℤ) :
    lorentzQ (bergB a b c).1 (bergB a b c).2.1 (bergB a b c).2.2 = lorentzQ a b c := by
  unfold lorentzQ bergB; ring

theorem bergC_preserves_Q (a b c : ℤ) :
    lorentzQ (bergC a b c).1 (bergC a b c).2.1 (bergC a b c).2.2 = lorentzQ a b c := by
  unfold lorentzQ bergC; ring

/-! ## Part III: Hypotenuse Growth Bounds -/

/-- The hypotenuse of child B. -/
def hypB (a b c : ℤ) : ℤ := 2*a + 2*b + 3*c

/-- THEOREM 9: Hypotenuse of child B exceeds parent (when legs positive).
    Bridge: depth ↔ O(log c) complexity for tree navigation. -/
theorem hypB_strict_growth (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    c < hypB a b c := by
  unfold hypB; linarith

/-- THEOREM 10: Child B hypotenuse lower bound: c_B ≥ 3c.
    Bridge: O(log c) depth bound ↔ efficient tree algorithms. -/
theorem hypB_lower_bound (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) :
-- ... (truncated, full file has 608 lines)
```

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
• **Embedded images**: ALL images (charts, diagrams, visualizations) MUST be
  embedded directly in the HTML as base64 data URIs. Use the format:
  `<img src="data:image/png;base64,..." />` for PNGs,
  `<img src="data:image/svg+xml;base64,..." />` for SVGs.
  If you generate matplotlib/plotly figures in Python, convert them to base64
  and embed them. For SVG diagrams, inline the SVG markup directly with
  `<svg>...</svg>` tags — this is preferred over base64 for vector graphics.
  NEVER use `<img src="filename.png">` — the file won't exist when viewing.
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
Research mode: discover
