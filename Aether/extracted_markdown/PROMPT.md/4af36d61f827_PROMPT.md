            ## YOUR ASSIGNMENT: tropical_cryptography_breakthrough_bridge

            **DOMAIN**: Cryptography

**CONCEPT**: Visionary bridge between Tropical and Cryptography: Tropical one-way functions and min-plus cryptographic primitives. The hardness of tropical matrix inversion is a candidate computational assumption for post-quantum cryptography.

**PRECISE ASSIGNMENT**: Formalize and prove the most important theorem you can in this direction. Start from the catalog references below.

**PROOF STRATEGY**: Build on existing results. Every theorem should connect to at least one other domain for cross-domain impact.

**FAILURE MODE**: Prove the strongest lemma you can. Never fall back to trivial tautologies.

**CATALOG INFRASTRUCTURE**: Build directly on: Algebra/Other/OctonionicTropicalApplications.lean, Algebra/Tropical_p_adic_Valuation_Bounds_and_Lifting_the_Exponent_for_Fibonacci_Primitive_Divisors.lean, AutoResearch/CompactTropicalChoquetRadon.lean, Bridges/CupProductCryptography.lean, Bridges/SymplecticCryptography.lean
**KEY REFERENCES**: Tropical, Cryptography

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
  1. `tropical_plus_distributes_over_min` : theorem tropical_plus_distributes_over_min (a b c : ℝ) :
     (file: Cryptography/TropicalPostQuantumPrimitives.lean)
  2. `post_quantum_grover_lower_bound` : theorem post_quantum_grover_lower_bound (security_bits : ℕ) :
     (file: Cryptography/TropicalMinPlusOWF.lean)
  3. `post_quantum_256bit_exists` : theorem post_quantum_256bit_exists :
     (file: Cryptography/CohomologicalCrypto/Foundation.lean)
  4. `universal_bridge_density_one` : theorem universal_bridge_density_one :
     (file: Cryptography/RosettaStone/MasterFormula.lean)
  5. `tropical_owf_quantum_resistance` : theorem tropical_owf_quantum_resistance {S : Type*} [AddCommMonoid S]
     (file: Cryptography/TropicalCryptoBridge.lean)

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



Recent successful concepts: Topos-Theoretic Machine Learning: Presheaf Hypothesis Topos, Subobject Learnability Bound, and Geometric Morphism Transfer, Operator-Algebraic Neural Architecture Theory: Joint Spectral Radius Expressivity, Radical Pruning Verification, and GK-Dimension Complexity, Foundations of Information-Theoretic Shared Structures


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

@Bridges/CupProductCryptography.lean
```lean
import Mathlib

/-!
# Cup-Product Pairing Cryptography

Algebraic foundations of topological pairing-based cryptography, where bilinear
pairings with graded commutativity serve as cryptographic primitives.

## Bridge: Algebraic Topology × Cryptography × Quantum Information

The cup product on simplicial cohomology is a bilinear map
`⌣ : Hᵖ(K; 𝔽_q) × Hʳ(K; 𝔽_q) → Hᵖ⁺ʳ(K; 𝔽_q)` satisfying graded
commutativity `a ⌣ b = (-1)^{pr} b ⌣ a`. This gives both symmetric (type-1)
and alternating (type-3) pairings from a single topological space depending
on degree parity — a property impossible for elliptic curve pairings.

## Main Results

* `BilinearCupPairing` — bilinear map abstraction for cup products
* `GradedCommPairing` — self-pairing with graded commutativity
* `cupPairingType` — classification by degree parity
* `neg_one_pow_even_eq_one` / `neg_one_pow_odd_eq_neg_one` — sign computation
* `cup_comm_of_sign_one` / `cup_anti_of_sign_neg_one` — type classification
* `CohomologicalIBEScheme` — identity-based encryption from cup products
* `ibe_decrypt_correct` — decryption correctness from bilinearity
* `BettiSecurityParams` — Betti number security parameter theorem
* `quantum_grover_security_degradation` — post-quantum security analysis
-/

open Finset BigOperators

noncomputable section

/-! ## Part I: Bilinear Pairings and Graded Commutativity -/

/-- A bilinear pairing between three modules over a commutative ring.
    Bridge: connects algebraic topology (cup product) to cryptography (bilinear maps). -/
structure BilinearCupPairing (R : Type*) [CommRing R]
    (M₁ M₂ M₃ : Type*)
    [AddCommGroup M₁] [Module R M₁]
    [AddCommGroup M₂] [Module R M₂]
    [AddCommGroup M₃] [Module R M₃] where
  cup : M₁ → M₂ → M₃
  map_add_left : ∀ (a b : M₁) (c : M₂), cup (a + b) c = cup a c + cup b c
  map_add_right : ∀ (a : M₁) (b c : M₂), cup a (b + c) = cup a b + cup a c
  map_smul_left : ∀ (r : R) (a : M₁) (b : M₂), cup (r • a) b = r • cup a b
  map_smul_right : ∀ (r : R) (a : M₁) (b : M₂), cup a (r • b) = r • cup a b

namespace BilinearCupPairing

variable {R : Type*} [CommRing R]
  {M₁ M₂ M₃ : Type*}
  [AddCommGroup M₁] [Module R M₁]
  [AddCommGroup M₂] [Module R M₂]
  [AddCommGroup M₃] [Module R M₃]
  (P : BilinearCupPairing R M₁ M₂ M₃)

/-- The cup product of zero on the left is zero.
    Derived from bilinearity — foundational for certified_robustness of pairing computations. -/
theorem cup_zero_left (b : M₂) : P.cup 0 b = 0 := by
  simpa using P.map_add_left 0 0 b

/-- The cup product of zero on the right is zero. -/
theorem cup_zero_right (a : M₁) : P.cup a 0 = 0 := by
  simpa using P.map_add_right a 0 0

/-- Negation passes through the left argument of the cup product. -/
theorem cup_neg_left (a : M₁) (b : M₂) : P.cup (-a) b = -P.cup a b := by
  have := P.map_smul_left (-1) a b; simp_all +decide [neg_smul]

/-- Negation passes through the right argument. -/
theorem cup_neg_right (a : M₁) (b : M₂) : P.cup a (-b) = -P.cup a b := by
  have := P.map_smul_right (-1) a b; aesop

/-- Subtraction in the left argument distributes.
    Bridge: connects homological algebra (chain complex maps) to lattice_crypto (error distribution). -/
theorem cup_sub_left (a₁ a₂ : M₁) (b : M₂) :
    P.cup (a₁ - a₂) b = P.cup a₁ b - P.cup a₂ b := by
  have := P.map_add_left (a₁ - a₂) a₂ b; simp_all +decide [sub_eq_add_neg]

/-- Subtraction in the right argument distributes. -/
theorem cup_sub_right (a : M₁) (b₁ b₂ : M₂) :
    P.cup a (b₁ - b₂) = P.cup a b₁ - P.cup a b₂ := by
  convert P.map_add_right a b₁ (-b₂) using 1 <;> simp +decide [sub_eq_add_neg]
  exact P.cup_neg_right a b₂ ▸ rfl

/-- Double scaling: (r * s) • cup = r • s • cup.
    Bridge: this multiplicative homomorphism property is what enables
    cryptographic key exchange via bilinear maps. -/
theorem cup_smul_smul_left (r s : R) (a : M₁) (b : M₂) :
    P.cup ((r * s) • a) b = r • P.cup (s • a) b := by
  rw [← P.map_smul_left, ← smul_smul]

/-- Iterated cup product with integer scaling for post_quantum_security analysis. -/
theorem cup_nsmul_left (n : ℕ) (a : M₁) (b : M₂) :
    P.cup (n • a) b = n • P.cup a b := by
  induction' n with n ih
  · simpa using P.cup_zero_left b
  · simp +decide [add_smul, ih, P.map_add_left]

end BilinearCupPairing

/-! ## Part II: Pairing Type Classification -/

/-- Classification of cup-product pairings by degree parity.
    Bridge: connects topology (degree of cohomology class) to cryptography (pairing type).
    Type-1 (symmetric) pairings enable efficient key agreement.
    Type-3 (alternating) pairings enable short signatures. -/
inductive PairingType where
  | symmetric   : PairingType  -- type-1: (-1)^{p·r} = 1
  | alternating : PairingType  -- type-3: (-1)^{p·r} = -1
  | mixed       : PairingType  -- one even, one odd degree
  deriving DecidableEq, Repr

/-- Classify the cup-product pairing type from degree parity.
    When both degrees are even, p·r is even so (-1)^{pr} = 1 → symmetric.
    When both are odd, p·r is odd so (-1)^{pr} = -1 → alternating. -/
def cupPairingType (p r : ℕ) : PairingType :=
  if p % 2 = 0 ∧ r % 2 = 0 then PairingType.symmetric
  else if p % 2 = 1 ∧ r % 2 = 1 then PairingType.alternating
  else PairingType.mixed

/-- Even-even degrees give symmetric (type-1) pairings. -/
theorem cupPairingType_even_even {p r : ℕ} (hp : p % 2 = 0) (hr : r % 2 = 0) :
    cupPairingType p r = PairingType.symmetric := by
  exact if_pos ⟨hp, hr⟩

/-- Odd-odd degrees give alternating (type-3) pairings. -/
theorem cupPairingType_odd_odd {p r : ℕ} (hp : p % 2 = 1) (hr : r % 2 = 1) :
    cupPairingType p r = PairingType.alternating := by
  unfold cupPairingType; aesop

/-- Mixed parity gives mixed type. -/
theorem cupPairingType_mixed {p r : ℕ} (hp : p % 2 = 0) (hr : r % 2 = 1) :
    cupPairingType p r = PairingType.mixed := by
  unfold cupPairingType; aesop

/-- The pairing type is symmetric in the degree arguments.
    This reflects that the cup product pairing H^p × H^r and H^r × H^p
    have the same type — crucial for bidirectional cryptographic protocols. -/
theorem cupPairingType_comm (p r : ℕ) : cupPairingType p r = cupPairingType r p := by
  unfold cupPairingType; aesop

/-! ## Part III: Sign Computations for Graded Commutativity -/

/-- When n is even, (-1)^n = 1 in any ring. This is the algebraic core of
    why even-degree cup products are symmetric. -/
theorem neg_one_pow_even_eq_one {R : Type*} [Ring R] {n : ℕ} (hn : Even n) :
    (-1 : R) ^ n = 1 := by
  exact Even.neg_one_pow hn
-- ... (truncated, full file has 684 lines)
```

@Bridges/SymplecticCryptography.lean
```lean
/-
  # Symplectic Cryptography: Post-Quantum Primitives from Alternating-Form Geometry

  This file formalizes foundational algebraic structures bridging symplectic
  geometry with post-quantum cryptographic primitives.

  ## Bridge: Symplectic Geometry ↔ Post-Quantum Cryptography
  The symplectic group Sp(2n, F_q) provides a natural setting for post-quantum
  one-way functions because its eigenvalue structure (reciprocal pairs λ, λ⁻¹)
  resists quantum period-finding algorithms.

  ## Main Results (26 theorems, 0 sorries):
  - `AlternatingBilinearForm`: typeclass for alternating bilinear forms
  - `SymplecticMat`: matrices preserving the symplectic form
  - Closure under multiplication and powers → well-defined OWF
  - Liouville volume preservation → zero-knowledge hiding
  - Determinant structure (det² · det(J) = det(J)) → volume preservation
  - Post-quantum security parameter bounds
  - ZK protocol algebraic properties (completeness, soundness extraction)
  - Birthday bound framework for hash collision analysis
-/

import Mathlib

open Matrix Finset BigOperators

namespace SymplecticCrypto

/-! ## Section 1: Alternating Bilinear Forms

An alternating bilinear form ω satisfies ω(x,x) = 0, implying ω(x,y) = -ω(y,x).
Bridge: Linear Algebra → Cryptographic Hash Functions -/

/-- An alternating bilinear form over a commutative ring R on a module V.
    The algebraic backbone of symplectic cryptography: the form that "cannot
    see its own image," providing the foundation for collision-resistant
    hashing via symplectic geometry.
    Bridge: connects bilinear algebra to collision-resistant hashing. -/
class AlternatingBilinearForm (R : Type*) [CommRing R]
    (V : Type*) [AddCommGroup V] [Module R V] where
  form : V → V → R
  form_self_zero : ∀ x, form x x = 0
  form_add_left : ∀ x y z, form (x + y) z = form x z + form y z
  form_smul_left : ∀ (r : R) x y, form (r • x) y = r * form x y
  form_add_right : ∀ x y z, form x (y + z) = form x y + form x z
  form_smul_right : ∀ (r : R) x y, form x (r • y) = r * form x y

variable {R : Type*} [CommRing R] {V : Type*} [AddCommGroup V] [Module R V]

/-- **Antisymmetry of Alternating Forms**: ω(x,y) = -ω(y,x).
    Derived from ω(x+y, x+y) = 0 via bilinearity. This antisymmetry
    prevents self-collision in symplectic hashing.
    Bridge: algebraic alternating property → geometric orientation reversal. -/
theorem AlternatingBilinearForm.form_antisymm [AlternatingBilinearForm R V]
    (x y : V) : AlternatingBilinearForm.form (R := R) x y =
                -AlternatingBilinearForm.form (R := R) y x := by
  have h := AlternatingBilinearForm.form_self_zero (R := R) (x + y)
  rw [form_add_left, form_add_right, form_add_right] at h
  have hx := form_self_zero (R := R) x
  have hy := form_self_zero (R := R) y
  linear_combination h - hx - hy

/-- ω(0, y) = 0. -/
theorem AlternatingBilinearForm.form_zero_left [AlternatingBilinearForm R V]
    (y : V) : AlternatingBilinearForm.form (R := R) 0 y = 0 := by
  have h : (0 : V) = (0 : R) • y := by simp
  rw [h, form_smul_left, zero_mul]

/-- ω(x, 0) = 0. -/
theorem AlternatingBilinearForm.form_zero_right [AlternatingBilinearForm R V]
    (x : V) : AlternatingBilinearForm.form (R := R) x 0 = 0 := by
  rw [form_antisymm, form_zero_left, neg_zero]

/-- ω(-x, y) = -ω(x, y). -/
theorem AlternatingBilinearForm.form_neg_left [AlternatingBilinearForm R V]
    (x y : V) : AlternatingBilinearForm.form (R := R) (-x) y =
                -AlternatingBilinearForm.form (R := R) x y := by
  have : -x = (-1 : R) • x := by simp
  rw [this, form_smul_left]; ring

/-- ω(x, -y) = -ω(x, y). -/
theorem AlternatingBilinearForm.form_neg_right [AlternatingBilinearForm R V]
    (x y : V) : AlternatingBilinearForm.form (R := R) x (-y) =
                -AlternatingBilinearForm.form (R := R) x y := by
  have : -y = (-1 : R) • y := by simp
  rw [this, form_smul_right]; ring

/-- ω(x - y, z) = ω(x, z) - ω(y, z). Subtraction distributes left. -/
theorem AlternatingBilinearForm.form_sub_left [AlternatingBilinearForm R V]
    (x y z : V) : AlternatingBilinearForm.form (R := R) (x - y) z =
                  AlternatingBilinearForm.form (R := R) x z -
                  AlternatingBilinearForm.form (R := R) y z := by
  rw [sub_eq_add_neg, form_add_left, form_neg_left, sub_eq_add_neg]

/-- ω(x, y - z) = ω(x, y) - ω(x, z). Subtraction distributes right. -/
theorem AlternatingBilinearForm.form_sub_right [AlternatingBilinearForm R V]
    (x y z : V) : AlternatingBilinearForm.form (R := R) x (y - z) =
                  AlternatingBilinearForm.form (R := R) x y -
                  AlternatingBilinearForm.form (R := R) x z := by
  rw [sub_eq_add_neg, form_add_right, form_neg_right, sub_eq_add_neg]

/-! ## Section 2: The Standard Symplectic Matrix

J = [[0, I], [-I, 0]] encodes the canonical alternating form: ω(x,y) = xᵀJy.
Bridge: Matrix Representation Theory → Cryptographic Group Actions -/

/-- The standard symplectic matrix J for R^{2n}, encoding the canonical
    alternating form via the block structure [[0, I], [-I, 0]]. This is
    the mathematical analog of the position-momentum pairing in Hamiltonian
    mechanics, repurposed for post-quantum cryptographic hash functions.
    Bridge: Hamiltonian phase-space structure → post-quantum OWF design. -/
noncomputable def stdSymplecticMatrix (n : ℕ) (R : Type*) [CommRing R] :
    Matrix (Fin (2 * n)) (Fin (2 * n)) R :=
  Matrix.of fun i j =>
    if (i : ℕ) % 2 = 0 ∧ (j : ℕ) = (i : ℕ) + 1 then (1 : R)
    else if (i : ℕ) % 2 = 1 ∧ (j : ℕ) + 1 = (i : ℕ) then (-1 : R)
    else (0 : R)

/-! ## Section 3: Symplectic Matrices

M ∈ Sp(2n, R) satisfies MᵀJM = J: it preserves the symplectic form.
Bridge: Group Theory → Post-Quantum One-Way Functions -/

/-- A symplectic matrix over a commutative ring R, preserving the standard
    symplectic form via MᵀJM = J. The symplectic group Sp(2n, R) is the
    post-quantum analog of F_q*: its DLP resists quantum period-finding
    because eigenvalues come in reciprocal pairs (λ, λ⁻¹).
    Bridge: classical group theory → post-quantum security. -/
structure SymplecticMat (n : ℕ) (R : Type*) [CommRing R] where
  mat : Matrix (Fin (2 * n)) (Fin (2 * n)) R
  symplectic_cond : mat.transpose * (stdSymplecticMatrix n R) * mat =
                    stdSymplecticMatrix n R

/-- **Identity is Symplectic**: 1ᵀJ·1 = J. The neutral element of the
    cryptographic group preserves all geometric structure.
    Bridge: identity transformation → protocol initialization. -/
theorem symplectic_identity_cond (n : ℕ) (R : Type*) [CommRing R] :
    (1 : Matrix (Fin (2 * n)) (Fin (2 * n)) R).transpose *
    stdSymplecticMatrix n R * (1 : Matrix (Fin (2 * n)) (Fin (2 * n)) R) =
    stdSymplecticMatrix n R := by
  simp [Matrix.transpose_one]

/-- Construct the identity as a SymplecticMat. -/
noncomputable def SymplecticMat.one (n : ℕ) (R : Type*) [CommRing R] :
    SymplecticMat n R :=
  ⟨1, symplectic_identity_cond n R⟩

/-- **Symplectic Multiplication Closure**: (MN)ᵀJ(MN) = NᵀMᵀJMN = NᵀJN = J.
    Makes symplectic exponentiation M^k well-defined within the group.
    Bridge: group closure → cryptographic function families. -/
-- ... (truncated, full file has 587 lines)
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

Research domain: Cryptography
Research mode: prove
