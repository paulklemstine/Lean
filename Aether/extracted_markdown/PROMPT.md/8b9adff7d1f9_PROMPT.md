            ## YOUR ASSIGNMENT: geometry_breakthrough_discovery

            **TARGET DOMAIN**: Geometry

**PRECISE ASSIGNMENT**: Survey the catalog infrastructure in Geometry. Identify the deepest structural result you can prove. Construct definitions that organize the territory, then prove theorems about them.

**PROOF STRATEGY**: Start from the existing catalog theorems listed below. Look for patterns that suggest isomorphisms, functors, or equivalence results. Every theorem you prove should open a door to three more.

**FAILURE MODE**: Do not produce trivial tautologies. If you cannot find deep structure, state precise conjectures about what you observe.

**CATALOG INFRASTRUCTURE**: Build directly on: Algebra/IntegerEnergy/PredictionGeometry.lean, Bridges/TropicalInformationGeometry.lean, Bridges/TropicalSymplecticGeometry.lean, Geometry/Other/GapMatterResearch.lean
**KEY REFERENCES**: Algebra/IntegerEnergy/PredictionGeometry.lean, Bridges/TropicalInformationGeometry.lean, Bridges/TropicalSymplecticGeometry.lean

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
            Discover deep theorems in Geometry (587 declarations, exploration ratio 587.0).  This domain shares field, group, lattice, manifold, measure, metric, norm, normed, order, ring, topology structures with Geometry but no bridge exists. Find unexpected structure, prove non-trivial results, open new territory.

            ### Precise Mathematical Framing
            Survey Geometry for under-explored theorems. The catalog has 587 declarations but few deep results. Look for: (1) structural theorems connecting existing definitions, (2) unexpected isomorphisms between objects in Geometry, (3) algorithmic results that leverage the existing infrastructure.



            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `tropical_lattice_norm_bridge` : theorem tropical_lattice_norm_bridge [NeZero n] (u v : Fin n → ℝ) :
     (file: Cryptography/TropicalPostQuantumPrimitives.lean)
  2. `hasse_bound_implies_group_order` : theorem hasse_bound_implies_group_order (p : ℕ) (a_p : ℤ) (hp : 2 ≤ p)
     (file: Computation/ResearchQuestions.lean)
  3. `photon_addresses_measure_zero` : theorem photon_addresses_measure_zero :
     (file: Geometry/Other/GapMatterResearch.lean)
  4. `padic_norm_mul` : theorem padic_norm_mul (x y : ℚ_[p]) :
     (file: Geometry/PAdic/PadicMobius.lean)
  5. `group_velocity_approaches_c` : theorem group_velocity_approaches_c (ℓ : ℕ) (hℓ : 0 < ℓ) :
     (file: Geometry/SphericalUniverse/GravitationalWaves.lean)

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



Recent successful concepts: algebra_breakthrough_discovery, tropical_cryptography_breakthrough_bridge, tropical_cryptography_breakthrough_bridge


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
            @Algebra/IntegerEnergy/PredictionGeometry.lean
```lean
import Mathlib

/-! # CatalogBuild.MachineLearning.Prediction.PredictionGeometry

Auto-generated from theorem catalog database.
Domain: MachineLearning/Prediction
Declarations: 26
-/


noncomputable section

/-- A prediction oracle on a type α is an idempotent endomorphism.
Asking the oracle twice yields the same answer: the oracle is "settled." -/
structure PredictionOracle (α : Type*) where
  predict : α → α
  idempotent : ∀ x, predict (predict x) = predict x




/-- The fixed points of an oracle — the "settled predictions" -/
def PredictionOracle.fixedPoints {α : Type*} (O : PredictionOracle α) : Set α :=
  {x | O.predict x = x}




/-- [Section: # CatalogBuild.MachineLearning.Prediction.PredictionGeometry
Auto-generated from theorem catalog database.
Domain: MachineLearning/Prediction
Declarations: 26] -/
theorem PredictionOracle.predict_mem_fixedPoints {α : Type*} (O : PredictionOracle α)
    (x : α) : O.predict x ∈ O.fixedPoints := by
  exact O.idempotent x




/-- [Section: # CatalogBuild.MachineLearning.Prediction.PredictionGeometry
Auto-generated from theorem catalog database.
Domain: MachineLearning/Prediction
Declarations: 26] -/
def PredictionOracle.identity (α : Type*) : PredictionOracle α where
  predict := id
  idempotent := by
    exact fun x => rfl




theorem PredictionOracle.identity_fixedPoints (α : Type*) :
    (PredictionOracle.identity α).fixedPoints = Set.univ := by
  exact Set.eq_univ_iff_forall.mpr fun x => rfl




/-- The prediction horizon: after H steps, prediction error exceeds threshold.
This captures the "butterfly effect" — chaos limits prediction depth. -/
structure PredictionHorizon where
  lyapunov : ℝ
  epsilon_0 : ℝ
  delta : ℝ
  lyapunov_pos : 0 < lyapunov
  epsilon_pos : 0 < epsilon_0
  delta_pos : 0 < delta
  delta_gt_eps : epsilon_0 < delta




/-- The prediction horizon formula: H = ln(δ/ε₀) / λ -/
noncomputable def PredictionHorizon.horizon (h : PredictionHorizon) : ℝ :=
  Real.log (h.delta / h.epsilon_0) / h.lyapunov




theorem PredictionHorizon.horizon_pos (h : PredictionHorizon) : 0 < h.horizon := by
  exact div_pos ( Real.log_pos <| by rw [ lt_div_iff₀ h.epsilon_pos ] ; linarith [ h.delta_gt_eps ] ) h.lyapunov_pos




theorem PredictionHorizon.doubling_precision_gain (h : PredictionHorizon) :
    let h' : PredictionHorizon := {
      lyapunov := h.lyapunov
      epsilon_0 := h.epsilon_0 / 2
      delta := h.delta
      lyapunov_pos := h.lyapunov_pos
      epsilon_pos := by linarith [h.epsilon_pos]
      delta_pos := h.delta_pos
      delta_gt_eps := by linarith [h.delta_gt_eps, h.epsilon_pos]
    }
    h'.horizon = h.horizon + Real.log 2 / h.lyapunov := by
  unfold PredictionHorizon.horizon;
  field_simp;
  rw [ ← Real.log_mul ( by exact div_ne_zero ( by linarith [ h.delta_pos, h.epsilon_pos ] ) ( by linarith [ h.delta_pos, h.epsilon_pos ] ) ) ( by linarith [ h.delta_pos, h.epsilon_pos ] ), mul_div_right_comm ]




theorem horizon_decreases_with_chaos (delta eps0 : ℝ) (hdelta : 0 < delta) (heps : 0 < eps0)
    (hlt : eps0 < delta)
    (lam1 lam2 : ℝ) (hlam1 : 0 < lam1) (hlam2 : 0 < lam2) (hlam : lam1 < lam2) :
    let h2 : PredictionHorizon := ⟨lam2, eps0, delta, hlam2, heps, hdelta, hlt⟩
    let h1 : PredictionHorizon := ⟨lam1, eps0, delta, hlam1, heps, hdelta, hlt⟩
    h2.horizon < h1.horizon := by
  exact div_lt_div_of_pos_left ( Real.log_pos <| by rw [ lt_div_iff₀ heps ] ; linarith ) ( by positivity ) hlam




theorem max_entropy_uniform (n : ℕ) (hn : 0 < n) (p : Fin n → ℝ)
    (hp_nonneg : ∀ i, 0 ≤ p i) (hp_sum : ∑ i, p i = 1) :
    shannonEntropy p ≤ Real.log n := by
  by_cases hn2 : n = 0 <;> simp_all +decide [ shannonEntropy ];
  have h_jensen : (∑ i : Fin n, (1 / n : ℝ) * (p i * Real.log (p i))) ≥ ((∑ i : Fin n, (1 / n : ℝ) * p i)) * Real.log ((∑ i : Fin n, (1 / n : ℝ) * p i)) := by
    have h_jensen : ConvexOn ℝ (Set.Ici 0) (fun x => x * Real.log x) := by
      exact ( Real.convexOn_mul_log );
    apply ConvexOn.map_sum_le h_jensen;
    · finiteness;
    · norm_num [ hn2 ];
    · aesop;
  simp_all +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul ];
  nlinarith [ inv_pos.mpr ( by positivity : 0 < ( n : ℝ ) ) ]




/-- Predictability: how far below maximum entropy a source is. -/
noncomputable def predictability {n : ℕ} (p : Fin n → ℝ) (hn : 0 < n) : ℝ :=
  Real.log n - shannonEntropy p




theorem predictability_nonneg {n : ℕ} (p : Fin n → ℝ) (hn : 0 < n)
    (hp_nonneg : ∀ i, 0 ≤ p i) (hp_sum : ∑ i, p i = 1) :
    0 ≤ predictability p hn := by
  exact sub_nonneg_of_le ( max_entropy_uniform n hn p hp_nonneg hp_sum )




/-- A contractive oracle shrinks prediction error at each step. -/
structure ContractiveOracle (α : Type*) [PseudoMetricSpace α] extends PredictionOracle α where
  contraction_rate : ℝ
  rate_bound : contraction_rate ∈ Set.Ico 0 1
-- ... (truncated, full file has 281 lines)
```

@Bridges/TropicalInformationGeometry.lean
```lean
/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Tropical Information Geometry: Min-Plus Fisher Information and Certified Bounds

This file opens the field of **tropical (min-plus) information geometry** by establishing
foundational definitions and theorems connecting idempotent semiring analysis to
statistical geometry, optimization, and certified robustness.

## Bridge: Tropical Geometry ↔ Information Theory ↔ Certified ML ↔ Post-Quantum Crypto

## Main Results
1. Tropical semiring foundations with full algebraic properties
2. L∞ entropy metric: triangle inequality, symmetry, identity
3. Tropical Fisher information: structure, symmetry, score bounds
4. Tropical spectral theory: eigenvalue bounds, condition numbers
5. Tropical determinant: trace bounds, spectral connections
6. Cross-domain bridges: crypto, ML, quantum, thermodynamics
-/

noncomputable section

open Finset BigOperators

namespace TropicalInfoGeom

/-! ## Section 1: Tropical Semiring -/

/-- Min-plus tropical addition: ⊕ = min.
    Bridge: tropical algebraic geometry ↔ dynamic programming. -/
@[reducible] def tropOplus (a b : ℝ) : ℝ := min a b

/-- Tropical multiplication: ⊗ = +.
    Bridge: tropical algebraic geometry ↔ logarithmic probability. -/
@[reducible] def tropOtimes (a b : ℝ) : ℝ := a + b

theorem tropOplus_comm (a b : ℝ) : tropOplus a b = tropOplus b a := min_comm a b
theorem tropOplus_assoc (a b c : ℝ) :
    tropOplus (tropOplus a b) c = tropOplus a (tropOplus b c) := min_assoc a b c

/-- Idempotency: a ⊕ a = a. Foundation of tropical fixed-point theory. -/
theorem tropOplus_idem (a : ℝ) : tropOplus a a = a := min_self a

/-- Distributivity: c ⊗ (a ⊕ b) = (c ⊗ a) ⊕ (c ⊗ b). -/
theorem tropOtimes_distributes_tropOplus (a b c : ℝ) :
    tropOtimes c (tropOplus a b) = tropOplus (tropOtimes c a) (tropOtimes c b) := by
  simp [tropOtimes, tropOplus, min_add_add_left]

theorem tropOtimes_comm (a b : ℝ) : tropOtimes a b = tropOtimes b a := add_comm a b
theorem tropOtimes_assoc (a b c : ℝ) :
    tropOtimes (tropOtimes a b) c = tropOtimes a (tropOtimes b c) := add_assoc a b c
theorem tropOtimes_zero_left (a : ℝ) : tropOtimes 0 a = a := zero_add a
theorem tropOtimes_zero_right (a : ℝ) : tropOtimes a 0 = a := add_zero a

/-- Min-max absorption: min(a, max(a, b)) = a.
    Bridge: lattice theory ↔ tropical geometry ↔ neural network activation. -/
theorem tropical_min_max_absorption_info (a b : ℝ) :
    min a (max a b) = a := min_eq_left (le_max_left a b)

theorem tropical_max_min_absorption_info (a b : ℝ) :
    max a (min a b) = a := max_eq_left (min_le_left a b)

/-- Min-plus duality: min(a,b) = -(max(-a, -b)).
    Bridge: min-plus ↔ max-plus duality ↔ ReLU/tropical. -/
theorem tropOplus_neg_duality (a b : ℝ) :
    min a b = -max (-a) (-b) := by
  simp [min_def, max_def]; split_ifs with h1 h2 h2 <;> linarith

/-! ## Section 2: L∞ Entropy Distance -/

/-- L∞ distance between real-valued functions on Fin n.
    Bridge: normed space theory ↔ adversarial perturbation measurement. -/
def linftyDist {n : ℕ} [NeZero n] (f g : Fin n → ℝ) : ℝ :=
  Finset.sup' Finset.univ Finset.univ_nonempty (fun k => |f k - g k|)

/-- L∞ distance is non-negative. -/
theorem linftyDist_nonneg {n : ℕ} [NeZero n] (f g : Fin n → ℝ) :
    0 ≤ linftyDist f g := by
  unfold linftyDist
  exact le_trans (abs_nonneg (f 0 - g 0))
    (Finset.le_sup' (fun k => |f k - g k|) (Finset.mem_univ 0))

/-- L∞ distance is symmetric. -/
theorem linftyDist_symm {n : ℕ} [NeZero n] (f g : Fin n → ℝ) :
    linftyDist f g = linftyDist g f := by
  unfold linftyDist; congr 1; ext k; rw [abs_sub_comm]

/-- Each coordinate difference is bounded by L∞ distance. -/
theorem coord_le_linftyDist {n : ℕ} [NeZero n] (f g : Fin n → ℝ)
    (k : Fin n) : |f k - g k| ≤ linftyDist f g :=
  Finset.le_sup' (fun k => |f k - g k|) (Finset.mem_univ k)

/-- L∞ self-distance is zero. -/
theorem linftyDist_self {n : ℕ} [NeZero n] (f : Fin n → ℝ) :
    linftyDist f f = 0 := by
  simp [linftyDist, sub_self]

/-
**L∞ triangle inequality**: d_∞(f, h) ≤ d_∞(f, g) + d_∞(g, h).
    Bridge: metric geometry ↔ certified robustness composition.
-/
theorem linftyDist_triangle {n : ℕ} [NeZero n] (f g h : Fin n → ℝ) :
    linftyDist f h ≤ linftyDist f g + linftyDist g h := by
      unfold linftyDist;
      exact Finset.sup'_le _ _ fun x hx => by cases abs_cases ( f x - h x ) <;> cases abs_cases ( f x - g x ) <;> cases abs_cases ( g x - h x ) <;> linarith [ Finset.le_sup' ( fun x => |f x - g x| ) hx, Finset.le_sup' ( fun x => |g x - h x| ) hx ] ;

/-
L∞ distance zero iff equal.
    Bridge: metric identity ↔ information indistinguishability.
-/
theorem linftyDist_eq_zero_iff {n : ℕ} [NeZero n] (f g : Fin n → ℝ) :
    linftyDist f g = 0 ↔ f = g := by
      constructor <;> intro h;
      · exact funext fun x => sub_eq_zero.mp ( abs_eq_zero.mp ( le_antisymm ( le_trans ( coord_le_linftyDist f g x ) h.le ) ( abs_nonneg _ ) ) );
      · -- If $f = g$, then for every $k$, $|f k - g k| = 0$, so the supremum is also $0$.
        simp [h, linftyDist]

/-! ## Section 3: Tropical Matrix Operations -/

/-- Tropical matrix-vector product: (A ⊗ v)_i = min_j (A_{ij} + v_j).
    Bridge: shortest-path computation ↔ tropical Fisher preconditioning. -/
def tropMatVecMul {m p : ℕ} [NeZero p]
    (A : Matrix (Fin m) (Fin p) ℝ) (v : Fin p → ℝ) : Fin m → ℝ :=
  fun i => Finset.inf' Finset.univ Finset.univ_nonempty (fun j => A i j + v j)

/-- Tropical matrix multiplication: (A ⊗ B)_{ij} = min_k (A_{ik} + B_{kj}).
    Computable in O(n³). Bridge: Floyd-Warshall ↔ tropical linear algebra. -/
def tropMatMul {m p q : ℕ} [NeZero p]
    (A : Matrix (Fin m) (Fin p) ℝ) (B : Matrix (Fin p) (Fin q) ℝ) :
    Matrix (Fin m) (Fin q) ℝ :=
  fun i j => Finset.inf' Finset.univ Finset.univ_nonempty (fun k => A i k + B k j)

/-
Tropical mat-vec product is monotone: v ≤ w ⟹ Av ≤ Aw.
    Bridge: order-preserving dynamics ↔ certified convergence.
-/
theorem tropMatVecMul_mono {m p : ℕ} [NeZero p]
    (A : Matrix (Fin m) (Fin p) ℝ) (v w : Fin p → ℝ)
    (hvw : ∀ j, v j ≤ w j) :
    ∀ i, tropMatVecMul A v i ≤ tropMatVecMul A w i := by
      unfold tropMatVecMul;
      simp +decide [ Finset.le_inf', hvw ];
      grind

/-- Tropical matrix multiplication entry bounded by any summand. -/
theorem tropMatMul_le_entry {m p q : ℕ} [NeZero p]
-- ... (truncated, full file has 580 lines)
```

@Bridges/TropicalSymplecticGeometry.lean
```lean
/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Tropical Symplectic Geometry: Min-Plus Hamiltonian Mechanics and Idempotent Action

This file opens the field of **tropical symplectic geometry** — the min-plus deformation
of classical symplectic mechanics — by proving foundational theorems establishing
tropical analogues of Hamilton's principle, Noether's theorem, and Gromov's non-squeezing.

## Bridge: Tropical Geometry ↔ Symplectic Topology ↔ Lattice Cryptography ↔ Neural Networks

## Main Results

1. Tropical Semiring Foundations with min-plus operations
2. Tropical Symplectic Forms with antisymmetry and bilinearity
3. Tropical Symplectic Capacity with ball/cylinder computation
4. Tropical Non-Squeezing: capacity gap → symplectic rigidity
5. Tropical Noether Correspondence: Symmetries ↔ conservation laws
6. Computational bounds for cryptography and neural network robustness
-/

noncomputable section

open Real Set BigOperators Finset

namespace TropicalSymplectic

/-! ## Section 1: Min-Plus Semiring -/

/-- Tropical addition (min). -/
def tropAdd (a b : ℝ) : ℝ := min a b

/-- Tropical multiplication (classical +). -/
def tropMul (a b : ℝ) : ℝ := a + b

theorem tropAdd_comm (a b : ℝ) : tropAdd a b = tropAdd b a := min_comm a b

theorem tropAdd_assoc (a b c : ℝ) :
    tropAdd (tropAdd a b) c = tropAdd a (tropAdd b c) := min_assoc a b c

/-- Tropical addition is idempotent: min(a,a) = a.
    Bridge: connects idempotent analysis ↔ optimization theory. -/
theorem tropAdd_idem (a : ℝ) : tropAdd a a = a := min_self a

theorem tropMul_comm (a b : ℝ) : tropMul a b = tropMul b a := add_comm a b

theorem tropMul_assoc (a b c : ℝ) :
    tropMul (tropMul a b) c = tropMul a (tropMul b c) := add_assoc a b c

/-- **Tropical distributivity**: c + min(a,b) = min(c+a, c+b).
    Bridge: connects tropical semiring ↔ Bellman dynamic programming. -/
theorem tropMul_distributes_tropAdd (a b c : ℝ) :
    tropMul c (tropAdd a b) = tropAdd (tropMul c a) (tropMul c b) := by
  simp only [tropMul, tropAdd, min_add_add_left]

theorem tropMul_zero_left (a : ℝ) : tropMul 0 a = a := zero_add a

theorem tropMul_zero_right (a : ℝ) : tropMul a 0 = a := add_zero a

/-- **Tropical absorption**: min(a, a + b) = a when b ≥ 0.
    Bridge: connects tropical absorption ↔ dominant term analysis. -/
theorem tropAdd_absorb (a b : ℝ) (hb : 0 ≤ b) : tropAdd a (a + b) = a := by
  simp [tropAdd, min_eq_left (le_add_of_nonneg_right hb)]

/-- **Min-max duality**: min(a,b) = -max(-a,-b).
    Bridge: connects min-plus (tropical) ↔ max-plus (ReLU/neural network) algebras. -/
theorem tropAdd_neg_duality (a b : ℝ) : tropAdd a b = -max (-a) (-b) := by
  simp only [tropAdd]
  rcases le_total a b with h | h
  · rw [min_eq_left h, max_eq_left (by linarith), neg_neg]
  · rw [min_eq_right h, max_eq_right (by linarith), neg_neg]

/-! ## Section 2: Tropical Symplectic Forms -/

/-- **Tropical symplectic form** on ℝⁿ × ℝⁿ:
    ω(q₁,p₁,q₂,p₂) is an antisymmetric bilinear form on phase space.
    Bridge: connects symplectic topology ↔ tropical geometry. -/
structure TropSymplecticForm (n : ℕ) where
  form : (Fin n → ℝ) → (Fin n → ℝ) → (Fin n → ℝ) → (Fin n → ℝ) → ℝ
  antisymm : ∀ q₁ p₁ q₂ p₂, form q₁ p₁ q₂ p₂ + form q₂ p₂ q₁ p₁ = 0

/-- The standard tropical symplectic form: ω = Σᵢ (p₁ᵢ·q₂ᵢ - q₁ᵢ·p₂ᵢ).
    Bridge: connects Darboux's theorem ↔ tropical normal forms. -/
def stdTropSymplecticForm (n : ℕ) : TropSymplecticForm n where
  form q₁ p₁ q₂ p₂ := ∑ i : Fin n, (p₁ i * q₂ i - q₁ i * p₂ i)
  antisymm q₁ p₁ q₂ p₂ := by
    trans ∑ i : Fin n, ((p₁ i * q₂ i - q₁ i * p₂ i) + (p₂ i * q₁ i - q₂ i * p₁ i))
    · rw [← Finset.sum_add_distrib]
    · apply Finset.sum_eq_zero; intro i _; ring

/-- Symplectomorphism: preserves the tropical symplectic form.
    Bridge: connects Sp(2n) ↔ tropical linear group. -/
structure TropSymplectomorphism (n : ℕ) (ω : TropSymplecticForm n) where
  mapQ : (Fin n → ℝ) → (Fin n → ℝ) → (Fin n → ℝ)
  mapP : (Fin n → ℝ) → (Fin n → ℝ) → (Fin n → ℝ)
  preserves : ∀ q₁ p₁ q₂ p₂,
    ω.form (mapQ q₁ p₁) (mapP q₁ p₁) (mapQ q₂ p₂) (mapP q₂ p₂) = ω.form q₁ p₁ q₂ p₂

/-- Strict antisymmetry: ω(x,y) = -ω(y,x).
    Bridge: connects symplectic antisymmetry ↔ tropical duality. -/
theorem trop_symplectic_strict_antisymm (n : ℕ) (q₁ p₁ q₂ p₂ : Fin n → ℝ) :
    (stdTropSymplecticForm n).form q₁ p₁ q₂ p₂ =
    -(stdTropSymplecticForm n).form q₂ p₂ q₁ p₁ := by
  have h := (stdTropSymplecticForm n).antisymm q₁ p₁ q₂ p₂; linarith

/-- Bilinearity: ω(α·x, y) = α · ω(x, y).
    Bridge: connects symplectic linearity ↔ tropical scalar action. -/
theorem trop_symplectic_scalar_left (n : ℕ) (α : ℝ) (q₁ p₁ q₂ p₂ : Fin n → ℝ) :
    (stdTropSymplecticForm n).form (fun i => α * q₁ i) (fun i => α * p₁ i) q₂ p₂ =
    α * (stdTropSymplecticForm n).form q₁ p₁ q₂ p₂ := by
  simp only [stdTropSymplecticForm]
  rw [Finset.mul_sum]
  congr 1; ext i; ring

/-- Zero gives zero: ω(0, y) = 0. -/
theorem trop_symplectic_zero_left (n : ℕ) (q₂ p₂ : Fin n → ℝ) :
    (stdTropSymplecticForm n).form 0 0 q₂ p₂ = 0 := by
  simp only [stdTropSymplecticForm, Pi.zero_apply, zero_mul, sub_self,
             Finset.sum_const_zero]

/-! ## Section 3: Tropical Symplectic Capacity -/

/-- Tropical ball of radius R (ℓ∞ ball).
    Bridge: connects tropical metric ↔ lattice geometry. -/
def tropBall (n : ℕ) (R : ℝ) : Set (Fin n → ℝ) := {x | ∀ i, |x i| ≤ R}

/-- Tropical cylinder of radius r in first coordinate.
    Bridge: connects symplectic cylinders ↔ tropical halfspaces. -/
def tropCylinder {n : ℕ} (hn : 1 ≤ n) (r : ℝ) : Set (Fin n → ℝ) :=
  {x | |x ⟨0, by omega⟩| ≤ r}

/-- Tropical symplectic capacity: sup of ball radii fitting in S.
    Bridge: connects Gromov capacity ↔ tropical rigidity ↔ lattice crypto. -/
def tropCapacity (n : ℕ) (S : Set (Fin n → ℝ)) : ℝ :=
  sSup {r : ℝ | 0 ≤ r ∧ tropBall n r ⊆ S}

/-- Ball monotonicity: R₁ ≤ R₂ → B_{R₁} ⊆ B_{R₂}. -/
theorem tropBall_mono {n : ℕ} {R₁ R₂ : ℝ} (h : R₁ ≤ R₂) :
    tropBall n R₁ ⊆ tropBall n R₂ :=
  fun _ hx i => le_trans (hx i) h

/-- Ball ⊆ cylinder. -/
theorem tropBall_sub_cylinder {n : ℕ} (hn : 1 ≤ n) (r : ℝ) :
    tropBall n r ⊆ tropCylinder hn r :=
  fun _ hx => hx ⟨0, by omega⟩

-- ... (truncated, full file has 441 lines)
```

@Geometry/Other/GapMatterResearch.lean
```lean
import Mathlib

/-! # CatalogBuild.Speculative.Other.GapMatterResearch

Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 34
-/

noncomputable section

/-- [Section: # CatalogBuild.Speculative.Other.GapMatterResearch
Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 34] -/
theorem photon_addresses_measure_zero :
    MeasureTheory.volume (Set.range (Nat.cast : ℕ → ℝ)) = 0 := by
      rw [ Set.countable_range _ |> Set.Countable.measure_zero ]

/-- [Section: # CatalogBuild.Speculative.Other.GapMatterResearch
Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 34] -/
theorem gaps_have_full_measure :
    MeasureTheory.volume (Set.range (Nat.cast : ℕ → ℝ))ᶜ = ⊤ := by
      rw [ MeasureTheory.measure_compl ] <;> norm_num [ photon_addresses_measure_zero ];
      exact Set.countable_range _ |> Set.Countable.measurableSet

/-- No natural number lies strictly between n and n+1 (the gap is truly empty of photons). -/
theorem gap_contains_no_photon (n : ℕ) :
    ¬ ∃ m : ℕ, (n : ℝ) < (m : ℝ) ∧ (m : ℝ) < (n : ℝ) + 1 := by
  push_neg
  intro m hm
  have : (n : ℝ) < (m : ℝ) := hm
  have h1 : n < m := by exact_mod_cast this
  linarith [show (m : ℝ) ≥ (n : ℝ) + 1 from by exact_mod_cast h1]

theorem gap_is_uncountable (n : ℕ) :
    ¬ Set.Countable (Set.Ioo (n : ℝ) ((n : ℝ) + 1)) := by
      aesop

/-- The Stokes-Minkowski form. -/
def stokesMinkowskiForm (S₀ S₁ S₂ S₃ : ℝ) : ℝ :=
  S₀^2 - S₁^2 - S₂^2 - S₃^2

theorem mixing_creates_mass
    (S₁ S₂ S₃ T₁ T₂ T₃ I : ℝ)
    (hI : I > 0)
    (hS : I^2 = S₁^2 + S₂^2 + S₃^2)
    (hT : I^2 = T₁^2 + T₂^2 + T₃^2)
    (hne : (S₁, S₂, S₃) ≠ (T₁, T₂, T₃)) :
    stokesMinkowskiForm I ((S₁ + T₁)/2) ((S₂ + T₂)/2) ((S₃ + T₃)/2) > 0 := by
      unfold stokesMinkowskiForm;
      linarith [ sq_nonneg ( S₁ - T₁ ), sq_nonneg ( S₂ - T₂ ), sq_nonneg ( S₃ - T₃ ), show 0 < ( S₁ - T₁ ) ^ 2 + ( S₂ - T₂ ) ^ 2 + ( S₃ - T₃ ) ^ 2 from not_le.mp fun h => hne <| by congr <;> nlinarith only [ h ] ]

theorem null_sphere_has_measure_zero :
    MeasureTheory.volume {p : EuclideanSpace ℝ (Fin 3) |
      p 0 ^ 2 + p 1 ^ 2 + p 2 ^ 2 = 1} = 0 := by
        -- The sphere is a smooth codimension-1 submanifold of ℝ³ and hence has Lebesgue measure zero.
        have h_sphere_measure_zero : MeasureTheory.volume (Metric.sphere (0 : EuclideanSpace ℝ (Fin 3)) 1) = 0 := by
          norm_num [ MeasureTheory.Measure.addHaar_sphere ];
        convert h_sphere_measure_zero using 1;
        congr ; ext ; simp +decide [ EuclideanSpace.norm_eq, Fin.sum_univ_three ]

theorem timelike_ball_positive_measure :
    MeasureTheory.volume {p : EuclideanSpace ℝ (Fin 3) |
      p 0 ^ 2 + p 1 ^ 2 + p 2 ^ 2 < 1} > 0 := by
        refine' ( lt_of_lt_of_le _ ( MeasureTheory.measure_mono _ ) );
        case refine'_2 => exact Metric.ball 0 ( 1 / 2 );
        · norm_num [ EuclideanSpace.volume_ball ];
          exact ⟨ by positivity, by positivity ⟩;
        · intro p hp; have := hp.out; norm_num [ EuclideanSpace.norm_eq ] at *;
          rw [ Real.sqrt_lt' ] at this <;> norm_num [ Fin.sum_univ_three ] at * ; nlinarith

theorem gap_interpolation_massive
    (S₁ S₂ S₃ T₁ T₂ T₃ I : ℝ)
    (hI : I > 0)
    (hS : I^2 = S₁^2 + S₂^2 + S₃^2)
    (hT : I^2 = T₁^2 + T₂^2 + T₃^2)
    (hne : (S₁, S₂, S₃) ≠ (T₁, T₂, T₃))
    (t : ℝ) (ht0 : 0 < t) (ht1 : t < 1) :
    isTimelike I
      ((1-t) * S₁ + t * T₁)
      ((1-t) * S₂ + t * T₂)
      ((1-t) * S₃ + t * T₃) := by
        -- By the properties of the dot product and the fact that $S$ and $T$ are distinct, we have $S₁T₁ + S₂T₂ + S₃T₃ < I²$.
        have h_dot_product : S₁ * T₁ + S₂ * T₂ + S₃ * T₃ < I^2 := by
          contrapose! hne;
          exact Prod.ext ( by nlinarith [ sq_nonneg ( S₁ - T₁ ), sq_nonneg ( S₁ + T₁ ), sq_nonneg ( S₂ - T₂ ), sq_nonneg ( S₂ + T₂ ), sq_nonneg ( S₃ - T₃ ), sq_nonneg ( S₃ + T₃ ) ] ) ( Prod.ext ( by nlinarith [ sq_nonneg ( S₁ - T₁ ), sq_nonneg ( S₁ + T₁ ), sq_nonneg ( S₂ - T₂ ), sq_nonneg ( S₂ + T₂ ), sq_nonneg ( S₃ - T₃ ), sq_nonneg ( S₃ + T₃ ) ] ) ( by nlinarith [ sq_nonneg ( S₁ - T₁ ), sq_nonneg ( S₁ + T₁ ), sq_nonneg ( S₂ - T₂ ), sq_nonneg ( S₂ + T₂ ), sq_nonneg ( S₃ - T₃ ), sq_nonneg ( S₃ + T₃ ) ] ) );
        exact show 0 < I ^ 2 - ( ( 1 - t ) * S₁ + t * T₁ ) ^ 2 - ( ( 1 - t ) * S₂ + t * T₂ ) ^ 2 - ( ( 1 - t ) * S₃ + t * T₃ ) ^ 2 from by nlinarith [ mul_pos ht0 ( sub_pos.2 ht1 ) ] ;

theorem midpoint_maximum_mass
    (S₁ S₂ S₃ T₁ T₂ T₃ I : ℝ)
    (hS : I^2 = S₁^2 + S₂^2 + S₃^2)
    (hT : I^2 = T₁^2 + T₂^2 + T₃^2)
    (t : ℝ) (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    stokesMinkowskiForm I
      ((1-t) * S₁ + t * T₁)
      ((1-t) * S₂ + t * T₂)
      ((1-t) * S₃ + t * T₃)
    ≤ stokesMinkowskiForm I
      ((S₁ + T₁)/2)
      ((S₂ + T₂)/2)
      ((S₃ + T₃)/2) := by
        unfold stokesMinkowskiForm; ring_nf; norm_num; nlinarith [ sq_nonneg ( t - 1 / 2 ), mul_self_nonneg ( S₁ - T₁ ), mul_self_nonneg ( S₂ - T₂ ), mul_self_nonneg ( S₃ - T₃ ) ] ;

/-- **Theorem 6 (Parabolic Mass Profile)**:
The Minkowski norm of the interpolated state is a quadratic function of t,
vanishing at t=0 and t=1, with maximum at t=1/2.
Explicitly: η(S(t)) = t(1-t) · [2I² - 2(S⃗·T⃗)]
where S⃗·T⃗ = S₁T₁ + S₂T₂ + S₃T₃. -/
theorem parabolic_mass_profile
    (S₁ S₂ S₃ T₁ T₂ T₃ I : ℝ)
    (hS : I^2 = S₁^2 + S₂^2 + S₃^2)
    (hT : I^2 = T₁^2 + T₂^2 + T₃^2)
    (t : ℝ) :
    stokesMinkowskiForm I
      ((1-t) * S₁ + t * T₁)
      ((1-t) * S₂ + t * T₂)
      ((1-t) * S₃ + t * T₃)
    = t * (1 - t) * (2 * I^2 - 2 * (S₁*T₁ + S₂*T₂ + S₃*T₃)) := by
  unfold stokesMinkowskiForm
  nlinarith [sq_nonneg (S₁ - T₁), sq_nonneg (S₂ - T₂), sq_nonneg (S₃ - T₃),
             sq_nonneg ((1-t)*S₁ + t*T₁), sq_nonneg ((1-t)*S₂ + t*T₂),
             sq_nonneg ((1-t)*S₃ + t*T₃), sq_nonneg t, sq_nonneg (1-t)]

/-- **Experiment 1**: H-polarized photon (1,1,0,0) is null. -/
theorem experiment_H_null : isNull 1 1 0 0 := by
  unfold isNull stokesMinkowskiForm; ring

/-- **Experiment 2**: V-polarized photon (1,-1,0,0) is null. -/
theorem experiment_V_null : isNull 1 (-1) 0 0 := by
  unfold isNull stokesMinkowskiForm; ring

/-- **Experiment 3**: 50-50 mixture of H and V is unpolarized (1,0,0,0), which is timelike. -/
theorem experiment_HV_mix_timelike : isTimelike 1 0 0 0 := by
  unfold isTimelike stokesMinkowskiForm; norm_num

/-- **Experiment 4**: The mass of the H+V mixture. -/
theorem experiment_HV_mass : stokesMinkowskiForm 1 0 0 0 = 1 := by
  unfold stokesMinkowskiForm; ring

/-- **Experiment 5**: At t = 1/4, the interpolation between H and V. -/
theorem experiment_interpolation_quarter :
    stokesMinkowskiForm 1 ((3/4)*1 + (1/4)*(-1)) 0 0 = 1 - (1/2)^2 := by
  unfold stokesMinkowskiForm; ring

/-- **Experiment 6**: Verify parabolic formula for H-V interpolation.
S⃗·T⃗ = 1·(-1) + 0 + 0 = -1, so η(t) = t(1-t)·(2-2·(-1)) = 4t(1-t). -/
theorem experiment_HV_parabola (t : ℝ) :
-- ... (truncated, full file has 269 lines)
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

Research domain: Geometry
Research mode: discover
