            ## YOUR ASSIGNMENT: shared_breakthrough_discovery

            **TARGET DOMAIN**: Shared

**PRECISE ASSIGNMENT**: Survey the catalog infrastructure in Shared. Identify the deepest structural result you can prove. Construct definitions that organize the territory, then prove theorems about them.

**PROOF STRATEGY**: Start from the existing catalog theorems listed below. Look for patterns that suggest isomorphisms, functors, or equivalence results. Every theorem you prove should open a door to three more.

**FAILURE MODE**: Do not produce trivial tautologies. If you cannot find deep structure, state precise conjectures about what you observe.

**CATALOG INFRASTRUCTURE**: Build directly on: Shared/Fib_gcd_identity.lean, Shared/FibonacciLTE.lean, Shared/TropicalEntropy/Defs.lean, Shared/TropicalEntropy/Theorems.lean
**KEY REFERENCES**: Shared/Fib_gcd_identity.lean, Shared/FibonacciLTE.lean, Shared/TropicalEntropy/Defs.lean

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
            Discover deep theorems in Shared (97 declarations, exploration ratio 97.0).  This domain shares lattice, measure, metric, monoid, norm, ring, semiring, tropical structures with Shared but no bridge exists. Find unexpected structure, prove non-trivial results, open new territory.

            ### Precise Mathematical Framing
            Survey Shared for under-explored theorems. The catalog has 97 declarations but few deep results. Look for: (1) structural theorems connecting existing definitions, (2) unexpected isomorphisms between objects in Shared, (3) algorithmic results that leverage the existing infrastructure.



            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `tropical_lattice_norm_bridge` : theorem tropical_lattice_norm_bridge [NeZero n] (u v : Fin n → ℝ) :
     (file: Cryptography/TropicalPostQuantumPrimitives.lean)
  2. `idempotent_semiring_with_inverses_trivial` : theorem idempotent_semiring_with_inverses_trivial {S : Type*} [IdempotentSemiring S]
     (file: Cryptography/PostIdempotentCrypto.lean)
  3. `tropical_lattice_dimension_bound` : theorem tropical_lattice_dimension_bound (n : ℕ) (hn : 8 ≤ n) :
     (file: Bridges/ProofAlgGeomBridge.lean)
  4. `tropical_lattice_det_bound` : theorem tropical_lattice_det_bound (bridge : TropicalLatticeBridge) :
     (file: Cryptography/TropicalOneWayFoundations.lean)
  5. `tropical_row_norm_bound_coord` : theorem tropical_row_norm_bound_coord {m n : ℕ} [NeZero m] [NeZero n]
     (file: MachineLearning/Neural/TropicalCertifiedRobustness.lean)

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



Recent successful concepts: tropical_cryptography_breakthrough_bridge, tropical_cryptography_breakthrough_bridge, Foundations of Information-Theoretic Shared Structures


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
            @Shared/Fib_gcd_identity.lean
```lean
import Mathlib
import Speculative.PisanoPeriodFactoring
import Shared.CarmichaelProof
import Shared.CarmichaelHelper

/-! # CatalogBuild.Shared.Fib_gcd_identity

Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 8
-/

/-- GCD identity: gcd(F(m), F(n)) = F(gcd(m,n)). -/
theorem fib_gcd_identity (m n : ℕ) :
    Nat.gcd (Nat.fib m) (Nat.fib n) = Nat.fib (Nat.gcd m n) :=
  (Nat.fib_gcd m n).symm




/-- Fibonacci divisibility: m | n implies F(m) | F(n). -/
theorem fib_dvd_chain (m n : ℕ) (h : m ∣ n) : Nat.fib m ∣ Nat.fib n :=
  Nat.fib_dvd _ _ h




/-- Carmichael's theorem (weak): For n ≥ 13, F(n) has a primitive prime divisor. -/
theorem fib_primitive_divisor_existence :
    ∀ n : ℕ, 13 ≤ n → ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧
      ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
  intro n hn
  by_cases hnp : Nat.Prime n
  · exact fib_primitive_divisor_prime n hn hnp
  · exact fib_carmichael_composite n hn hnp



/-- [Section: # CatalogBuild.Shared.Fib_gcd_identity
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 8] -/
theorem fib_linear_lower (n : ℕ) (hn : 6 ≤ n) : n ≤ Nat.fib n := by
  rcases n with ( _ | _ | _ | _ | _ | _ | _ | n ) <;> simp_all +arith +decide;
  exact Nat.recOn n ( by decide ) fun n ihn => by norm_num [ Nat.fib_add_two ] at * ; linarith




/-- F(n) ≤ 2^n for all n. -/
theorem fib_exp_bound (n : ℕ) : Nat.fib n ≤ 2^n := by
  induction n using Nat.strongRecOn with
  | ind n ih =>
    match n with
    | 0 => simp
    | 1 => simp [Nat.fib]
    | n + 2 =>
      rw [Nat.fib_add_two]
      have h1 := ih (n+1) (by omega)
      have h2 := ih n (by omega)
      have : 2^n ≤ 2^(n+1) := Nat.pow_le_pow_right (by omega) (by omega)
      linarith [show 2^(n+2) = 2^(n+1) + 2^(n+1) from by ring]




/-- [Section: # CatalogBuild.Shared.Fib_gcd_identity
Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 8] -/
theorem fib_sq_mod_prime (p : ℕ) (hp : Nat.Prime p) (hp2 : p ≠ 2) (hp5 : p ≠ 5) :
    (Nat.fib p ^ 2) % p = 1 % p := by
  haveI := Fact.mk hp; norm_num [ ← ZMod.natCast_eq_natCast_iff' ] ; ring_nf;
  -- By definition of Fibonacci sequence, we know that $F_p = \frac{(1 + \sqrt{5})^p - (1 - \sqrt{5})^p}{2^p \sqrt{5}}$.
  have h_fib_def : (Nat.fib p : ℤ) = ((1 + Real.sqrt 5) ^ p - (1 - Real.sqrt 5) ^ p) / (2 ^ p * Real.sqrt 5) := by
    have h_fib_def : ∀ n, (Nat.fib n : ℝ) = ((1 + Real.sqrt 5) ^ n - (1 - Real.sqrt 5) ^ n) / (2 ^ n * Real.sqrt 5) := by
      intro n; induction' n using Nat.strong_induction_on with n ih; rcases n with ( _ | _ | n ) <;> norm_num [ Nat.fib_add_two ] at *;
      · ring_nf; norm_num;
      · rw [ ih n ( by linarith ), ih ( n + 1 ) ( by linarith ) ] ; repeat ring <;> norm_num [ pow_succ' ] ;
    exact h_fib_def p ▸ by norm_num;
  -- Let's simplify the expression for $F_p$ modulo $p$.
  have h_fib_mod : ((1 + Real.sqrt 5) ^ p - (1 - Real.sqrt 5) ^ p) / (2 ^ p * Real.sqrt 5) = (∑ k ∈ Finset.range (p / 2 + 1), Nat.choose p (2 * k + 1) * 5 ^ k) / 2 ^ (p - 1) := by
    have h_binom : ((1 + Real.sqrt 5) ^ p - (1 - Real.sqrt 5) ^ p) = ∑ k ∈ Finset.range (p + 1), Nat.choose p k * Real.sqrt 5 ^ k * (if k % 2 = 1 then 2 else 0) := by
      have h_binom : ((1 + Real.sqrt 5) ^ p - (1 - Real.sqrt 5) ^ p) = ∑ k ∈ Finset.range (p + 1), Nat.choose p k * Real.sqrt 5 ^ k - ∑ k ∈ Finset.range (p + 1), Nat.choose p k * (-Real.sqrt 5) ^ k := by
        exact congrArg₂ _ ( by rw [ add_comm, add_pow ] ; simp +decide [ mul_comm ] ) ( by rw [ sub_eq_add_neg, add_comm, add_pow ] ; simp +decide [ mul_comm ] );
      rw [ h_binom, ← Finset.sum_sub_distrib ] ; refine' Finset.sum_congr rfl fun x hx => _ ; rcases Nat.even_or_odd' x with ⟨ k, rfl | rfl ⟩ <;> norm_num [ pow_add, pow_mul ] ; ring;
    -- Let's simplify the expression for $F_p$ modulo $p$ using the binomial theorem.
    have h_binom_simplified : ∑ k ∈ Finset.range (p + 1), Nat.choose p k * Real.sqrt 5 ^ k * (if k % 2 = 1 then 2 else 0) = 2 * ∑ k ∈ Finset.range ((p + 1) / 2), Nat.choose p (2 * k + 1) * Real.sqrt 5 ^ (2 * k + 1) := by
      have h_binom_simplified : Finset.filter (fun k => k % 2 = 1) (Finset.range (p + 1)) = Finset.image (fun k => 2 * k + 1) (Finset.range ((p + 1) / 2)) := by
        ext ( _ | k ) <;> simp +arith +decide [ Nat.add_mod, Nat.mul_mod ];
        exact ⟨ fun h => ⟨ k / 2, by omega, by omega ⟩, fun ⟨ a, ha, ha' ⟩ => ⟨ by omega, by omega ⟩ ⟩;
      simp_all +decide [ Finset.sum_ite, mul_comm, Finset.mul_sum _ _ _ ];
    rcases Nat.even_or_odd' p with ⟨ c, rfl | rfl ⟩ <;> norm_num [ Nat.add_div ] at *;
    · simp_all +decide [ Nat.prime_mul_iff ];
    · rw [ h_binom, h_binom_simplified ] ; ring_nf ; norm_num [ pow_add, pow_mul, mul_assoc, mul_left_comm, mul_comm ] ; ring;
      norm_num [ pow_mul', mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _ ];
  -- Let's simplify the expression for $F_p$ modulo $p$ further.
  have h_fib_mod_simplified : (∑ k ∈ Finset.range (p / 2 + 1), Nat.choose p (2 * k + 1) * 5 ^ k) ≡ 5 ^ ((p - 1) / 2) [ZMOD p] := by
    have h_fib_mod_simplified : ∀ k ∈ Finset.range (p / 2), Nat.choose p (2 * k + 1) ≡ 0 [ZMOD p] := by
      exact fun k hk => Int.modEq_zero_iff_dvd.mpr <| mod_cast hp.dvd_choose_self ( by linarith [ Finset.mem_range.mp hk ] ) ( by linarith [ Finset.mem_range.mp hk, Nat.div_mul_le_self p 2 ] ) ;
    rcases Nat.even_or_odd' p with ⟨ c, rfl | rfl ⟩ <;> norm_num at *;
    · simp_all +decide [ Nat.prime_mul_iff ];
    · norm_num [ Nat.add_div, Finset.sum_range_succ ] at *;
      exact Finset.dvd_sum fun i hi => dvd_mul_of_dvd_left ( Int.dvd_of_emod_eq_zero ( h_fib_mod_simplified i ( Finset.mem_range.mp hi ) ) ) _;
  -- Let's simplify the expression for $F_p$ modulo $p$ further using the fact that $2^{p-1} \equiv 1 \pmod{p}$.
  have h_fib_mod_final : (Nat.fib p : ℤ) * 2 ^ (p - 1) ≡ 5 ^ ((p - 1) / 2) [ZMOD p] := by
    convert h_fib_mod_simplified using 1;
    rw [ ← @Int.cast_inj ℝ ] ; aesop;
  have h_fermat : 2 ^ (p - 1) ≡ 1 [ZMOD p] ∧ 5 ^ (p - 1) ≡ 1 [ZMOD p] := by
    have := Nat.totient_prime hp; erw [ ← this ] ; exact ⟨ by simpa [ ← Int.natCast_modEq_iff ] using Nat.ModEq.pow_totient <| Nat.coprime_comm.mp <| hp.coprime_iff_not_dvd.mpr fun h => by have := Nat.le_of_dvd ( by decide ) h; interval_cases p <;> trivial, by simpa [ ← Int.natCast_modEq_iff ] using Nat.ModEq.pow_totient <| Nat.coprime_comm.mp <| hp.coprime_iff_not_dvd.mpr fun h => by have := Nat.le_of_dvd ( by decide ) h; interval_cases p <;> trivial ⟩ ;
  simp_all +decide [ ← ZMod.intCast_eq_intCast_iff ];
  exact eq_or_eq_neg_of_sq_eq_sq _ _ <| by rw [ ← pow_mul', Nat.mul_div_cancel' <| even_iff_two_dvd.mp <| hp.even_sub_one hp2 ] ; aesop;




theorem fib_composite_test (n : ℕ) (hn : 1 < n) (hn2 : n ≠ 2) (hn5 : n ≠ 5)
    (h : (Nat.fib n ^ 2) % n ≠ 1 % n) :
    ¬Nat.Prime n := by
  exact fun h' => h <| by have := fib_sq_mod_prime n h' hn2 hn5; simpa [ sq, Nat.mul_mod ] using this;




/-- F(4) = 3. -/
theorem fib_four_val : Nat.fib 4 = 3 := by native_decide




```

@Shared/FibonacciLTE.lean
```lean
import Mathlib

/-!
# Fibonacci Entry Point Theory and Lifting-the-Exponent

This file develops the valuation-theoretic backbone for the Fibonacci
primitive-divisor program. The central results are:

1. **Entry point theory**: For a prime `p`, the *Fibonacci entry point*
   is the least positive index `z` with `p ∣ F(z)`. We prove existence,
   positivity, minimality, and the fundamental divisibility criterion:
   `p ∣ F(n) ↔ z ∣ n`.

2. **LTE-style valuation theorem**: For odd prime `p ≠ 5` with entry point `z`,
   `v_p(F(k·z)) = v_p(F(z)) + v_p(k)`.

3. **GCD identity**: `gcd(F(m), F(n)) = F(gcd(m,n))` and its consequences.

4. **Composite-index primitive divisor theorem**: For composite `n ≥ 13`,
   `F(n)` has a primitive prime divisor.

## References

* Carmichael, R.D. (1913). *On the numerical factors of the arithmetic
  forms α^n ± β^n*. Annals of Mathematics.
-/

open Nat

set_option maxHeartbeats 800000

/-! ## Section 1: IsFibEntry — the entry point specification -/

/-- A predicate asserting that `z` is the Fibonacci entry point of `p`:
the least positive index where `p` divides `F(z)`. -/
def IsFibEntry (p z : ℕ) : Prop :=
  0 < z ∧ p ∣ fib z ∧ ∀ m, 0 < m → m < z → ¬ p ∣ fib m

/-! ## Section 2: GCD identity and divisibility sequence -/

/-- The GCD identity: `gcd(F(m), F(n)) = F(gcd(m, n))`. -/
theorem fib_gcd_eq (m n : ℕ) : Nat.gcd (fib m) (fib n) = fib (Nat.gcd m n) :=
  (Nat.fib_gcd m n).symm

/-- Divisibility in the index lifts to divisibility in values. -/
theorem fib_dvd_of_dvd {m n : ℕ} (h : m ∣ n) : fib m ∣ fib n :=
  Nat.fib_dvd m n h

/-- If `p` divides both `F(m)` and `F(n)`, then `p ∣ F(gcd(m,n))`. -/
theorem dvd_fib_gcd_of_dvd_fib {p m n : ℕ}
    (hm : p ∣ fib m) (hn : p ∣ fib n) :
    p ∣ fib (Nat.gcd m n) := by
  rw [← fib_gcd_eq]; exact Nat.dvd_gcd hm hn

/-- `gcd(F(m), F(n)) = F(gcd(m,n))` — valuation corollary. -/
theorem padicValNat_fib_gcd {p m n : ℕ} :
    padicValNat p (Nat.gcd (fib m) (fib n)) = padicValNat p (fib (Nat.gcd m n)) := by
  rw [fib_gcd_eq]

/-- A prime divides `gcd(F(m), F(n))` iff it divides `F(gcd(m,n))`. -/
theorem prime_dvd_fib_gcd_iff {p m n : ℕ} :
    p ∣ Nat.gcd (fib m) (fib n) ↔ p ∣ fib (Nat.gcd m n) := by
  rw [fib_gcd_eq]

attribute [local simp] fib_gcd_eq


/-! ## Section 3: Entry point divisibility -/

/-- The entry point divides any positive index where divisibility occurs. -/
theorem isFibEntry_dvd_of_dvd {p n z : ℕ}
    (hz : IsFibEntry p z) (_hn : 0 < n) (hpn : p ∣ fib n) :
    z ∣ n := by
  obtain ⟨hz_pos, hz_dvd, hz_min⟩ := hz
  have h_gcd_dvd_fib : p ∣ fib (Nat.gcd z n) :=
    dvd_fib_gcd_of_dvd_fib hz_dvd hpn
  have h_gcd_le : Nat.gcd z n ≤ z := Nat.gcd_le_left n hz_pos
  rcases eq_or_lt_of_le h_gcd_le with h | h
  · exact h ▸ Nat.gcd_dvd_right z n
  · exact absurd h_gcd_dvd_fib (hz_min _ (Nat.gcd_pos_of_pos_left n hz_pos) h)

/-- Non-divisibility below the entry point. -/
theorem not_dvd_fib_of_lt_entry {p m z : ℕ}
    (hz : IsFibEntry p z) (hm0 : 0 < m) (hmz : m < z) :
    ¬ p ∣ fib m :=
  hz.2.2 m hm0 hmz

/-- The divisibility criterion: `p ∣ F(n) ↔ z ∣ n`. -/
theorem prime_dvd_fib_iff_entry_dvd {p n z : ℕ} (_hp : Nat.Prime p)
    (hz : IsFibEntry p z) (hn : 0 < n) :
    p ∣ fib n ↔ z ∣ n := by
  constructor
  · exact isFibEntry_dvd_of_dvd hz hn
  · exact fun hdvd => dvd_trans hz.2.1 (fib_dvd_of_dvd hdvd)

/-- If the entry point doesn't divide `n`, then `p ∤ F(n)`. -/
theorem not_dvd_fib_of_not_entry_dvd {p n z : ℕ} (_hp : Nat.Prime p)
    (hz : IsFibEntry p z) (hn : 0 < n) (hnd : ¬ z ∣ n) :
    ¬ p ∣ fib n :=
  fun h => hnd (isFibEntry_dvd_of_dvd hz hn h)

/-- When the entry point doesn't divide `n`, the p-adic valuation of F(n) is zero. -/
theorem padicValNat_fib_eq_zero_of_not_entry_dvd {p n z : ℕ}
    (hp : Nat.Prime p) (hz : IsFibEntry p z) (hn : 0 < n) (hnd : ¬ z ∣ n) :
    padicValNat p (fib n) = 0 :=
  padicValNat.eq_zero_of_not_dvd (not_dvd_fib_of_not_entry_dvd hp hz hn hnd)

/-! ## Section 4: Existence of entry points -/

/-
Every prime divides some positive Fibonacci number.
For any prime `p`, the Pisano period `π(p) ≤ p² - 1` guarantees
that `p ∣ F(k)` for some `1 ≤ k ≤ p² - 1`.
-/
theorem prime_dvd_some_pos_fib (p : ℕ) (hp : Nat.Prime p) :
    ∃ k, 0 < k ∧ p ∣ fib k := by
  -- By the pigeonhole principle, among the p²+1 pairs (F(n) mod p, F(n+1) mod p) for n = 0,...,p², two must coincide (since there are only p² possible pairs).
  obtain ⟨i, j, hij, h_pair⟩ : ∃ i j : ℕ, i < j ∧ (fib i % p = fib j % p) ∧ (fib (i + 1) % p = fib (j + 1) % p) ∧ j ≤ p^2 := by
    have h_pigeonhole : Finset.card (Finset.image (fun n => (fib n % p, fib (n + 1) % p)) (Finset.range (p^2 + 1))) ≤ p^2 := by
      exact le_trans ( Finset.card_le_card <| Finset.image_subset_iff.mpr fun n hn => Finset.mem_product.mpr ⟨ Finset.mem_range.mpr <| Nat.mod_lt _ hp.pos, Finset.mem_range.mpr <| Nat.mod_lt _ hp.pos ⟩ ) ( by norm_num [ sq ] );
    contrapose! h_pigeonhole;
    rw [ Finset.card_image_of_injOn ] <;> norm_num;
    exact fun i hi j hj hij => le_antisymm ( le_of_not_gt fun hi' => by have := h_pigeonhole _ _ hi' ( by aesop ) ( by aesop ) ; linarith [ Set.mem_Iio.mp hi, Set.mem_Iio.mp hj ] ) ( le_of_not_gt fun hj' => by have := h_pigeonhole _ _ hj' ( by aesop ) ( by aesop ) ; linarith [ Set.mem_Iio.mp hi, Set.mem_Iio.mp hj ] );
  induction' i with i ih generalizing j;
  · exact ⟨ j, hij, Nat.dvd_of_mod_eq_zero <| by simpa using h_pair.1.symm ⟩;
  · apply ih ( j - 1 ) ( Nat.lt_pred_iff.mpr hij );
    rcases j <;> simp_all +decide [ Nat.fib_add_two ];
    exact ⟨ Nat.ModEq.symm ( Nat.modEq_of_dvd <| by simpa [ ← Int.natCast_dvd_natCast ] using Nat.modEq_iff_dvd.mp ( h_pair.2.1.symm.trans <| Nat.ModEq.add ( Nat.ModEq.refl _ ) h_pair.1 ) ), by linarith ⟩

/-- For any prime `p`, there exists `z` with `IsFibEntry p z`. -/
theorem exists_isFibEntry (p : ℕ) (hp : Nat.Prime p) : ∃ z, IsFibEntry p z := by
  obtain ⟨k, hk_pos, hk_dvd⟩ := prime_dvd_some_pos_fib p hp
  have hP : ∃ n, 0 < n ∧ p ∣ fib n := ⟨k, hk_pos, hk_dvd⟩
  exact ⟨Nat.find hP, (Nat.find_spec hP).1, (Nat.find_spec hP).2,
    fun m hm hmz hpm => Nat.find_min hP hmz ⟨hm, hpm⟩⟩

/-! ## Section 5: Fibonacci LTE — Lifting the Exponent

The key machinery: if `p ∣ F(m)` and `p ∤ k`, then
`v_p(F(mk)) = v_p(F(m))`; and for `k = p`,
`v_p(F(mp)) = v_p(F(m)) + 1`. Together these give
`v_p(F(mk)) = v_p(F(m)) + v_p(k)`.

The proofs use the quotient `Q(m,k) = F(mk)/F(m)` and the congruence
`Q(m,k) ≡ k · F(m-1)^{k-1} (mod p)`.
-/

/-- If `p ∣ F(m)`, then `p ∤ F(m-1)` (consecutive Fibonacci numbers are coprime). -/
theorem not_dvd_fib_pred {p m : ℕ} (hp : Nat.Prime p) (hm : 0 < m)
    (h : p ∣ fib m) : ¬ p ∣ fib (m - 1) := by
-- ... (truncated, full file has 415 lines)
```

@Shared/TropicalEntropy/Defs.lean
```lean
/-
Copyright (c) 2025. All rights reserved.

# Tropical Entropy Algebra — Foundational Definitions

## Overview

This file establishes the algebraic foundation unifying information theory,
cryptography, and thermodynamics through the tropical semiring. We define:

* Finite probability distributions with strict positivity
* The tropical semiring structure (ℝ, min, +)
* Min-entropy and max-entropy
* Markov kernels (channels) for data processing
* Entropy gap structures for post-quantum security
* Tropical distance for certified robustness

## Bridge: connects Algebra to InformationTheory to Cryptography

The key insight is that entropy functions are homomorphisms from the
multiplicative monoid of distributions to the tropical semiring (ℝ, min, +).
This single observation generates subadditivity, data processing inequalities,
and the second law of thermodynamics as corollaries.
-/
import Mathlib

open Finset Real BigOperators

noncomputable section

namespace TropicalEntropyAlgebra

/-! ## Section 1: Probability Distributions on Finite Types -/

/-- A probability mass function on a finite type: nonnegative and sums to 1.
    This is the fundamental object of information theory. -/
structure PMF (α : Type*) [Fintype α] where
  val : α → ℝ
  nonneg : ∀ x, 0 ≤ val x
  sum_one : ∑ x : α, val x = 1

/-- A strictly positive probability mass function: all values are positive.
    Required for well-defined entropy (avoids 0 * log 0 issues). -/
structure StrictPMF (α : Type*) [Fintype α] extends PMF α where
  pos : ∀ x, 0 < val x

/-- The uniform distribution on a finite type. -/
def uniformPMF (α : Type*) [Fintype α] [Nonempty α] : StrictPMF α where
  val := fun _ => 1 / (Fintype.card α : ℝ)
  nonneg := fun _ => by positivity
  pos := fun _ => by positivity
  sum_one := by simp [Finset.sum_const, Finset.card_univ, mul_comm]

/-! ## Section 2: The Tropical Semiring Structure -/

/-- The tropical semiring uses (min, +) instead of (+, ×).
    This structure captures the algebraic essence of entropy.
    Bridge: connects Algebra (semiring theory) to InformationTheory (entropy). -/
structure TropicalReal where
  val : ℝ

namespace TropicalReal

instance : Add TropicalReal where
  add a b := ⟨min a.val b.val⟩

instance : Mul TropicalReal where
  mul a b := ⟨a.val + b.val⟩

/-- Tropical addition is commutative: min(a,b) = min(b,a). -/
theorem tadd_comm (a b : TropicalReal) : a + b = b + a := by
  show TropicalReal.mk _ = TropicalReal.mk _
  congr 1; exact min_comm a.val b.val

/-- Tropical addition is associative: min(min(a,b),c) = min(a,min(b,c)). -/
theorem tadd_assoc (a b c : TropicalReal) : a + b + c = a + (b + c) := by
  show TropicalReal.mk _ = TropicalReal.mk _
  congr 1; exact min_assoc a.val b.val c.val

/-- Tropical addition is idempotent: min(a,a) = a. -/
theorem tadd_idem (a : TropicalReal) : a + a = a := by
  show TropicalReal.mk _ = TropicalReal.mk _
  congr 1; exact min_self a.val

/-- Tropical multiplication is commutative: a + b = b + a. -/
theorem tmul_comm (a b : TropicalReal) : a * b = b * a := by
  show TropicalReal.mk _ = TropicalReal.mk _
  congr 1; exact add_comm a.val b.val

/-- Tropical multiplication is associative. -/
theorem tmul_assoc (a b c : TropicalReal) : a * b * c = a * (b * c) := by
  show TropicalReal.mk _ = TropicalReal.mk _
  congr 1; exact add_assoc a.val b.val c.val

/-- Tropical distributivity: a * min(b,c) = min(a*b, a*c).
    THIS is the key property that generates subadditivity of entropy.
    Bridge: connects Algebra (distributive law) to InformationTheory (subadditivity). -/
theorem tropical_distributivity (a b c : TropicalReal) :
    a * (b + c) = a * b + (a * c) := by
  show TropicalReal.mk _ = TropicalReal.mk _
  congr 1
  show a.val + min b.val c.val = min (a.val + b.val) (a.val + c.val)
  exact (min_add_add_left a.val b.val c.val).symm

end TropicalReal

/-! ## Section 3: Max-Probability and Min-Entropy -/

/-- The maximum probability in a distribution. Used for min-entropy.
    Bridge: connects InformationTheory (entropy) to Cryptography (guessing). -/
def PMF.maxProb {α : Type*} [Fintype α] [Nonempty α] (p : PMF α) : ℝ :=
  Finset.sup' Finset.univ Finset.univ_nonempty p.val

/-- The minimum probability in a strict distribution. -/
def StrictPMF.minProb {α : Type*} [Fintype α] [Nonempty α] (p : StrictPMF α) : ℝ :=
  Finset.inf' Finset.univ Finset.univ_nonempty p.val

/-- Min-entropy: H_∞(X) = -log(max_x p(x)).
    Critical for post-quantum security: measures worst-case guessing difficulty.
    Bridge: connects InformationTheory to Cryptography (lattice-based). -/
def minEntropy {α : Type*} [Fintype α] [Nonempty α] (p : PMF α) : ℝ :=
  -Real.log (p.maxProb)

/-- Max-entropy (Hartley entropy): H_0(X) = log |α|.
    The entropy of the uniform distribution.
    Bridge: connects InformationTheory to Algebra (cardinality). -/
def maxEntropy (α : Type*) [Fintype α] : ℝ :=
  Real.log (Fintype.card α : ℝ)

/-! ## Section 4: Markov Kernels and Channels -/

/-- A Markov kernel (channel) from α to β: for each input x,
    gives a probability distribution over outputs.
    Bridge: connects InformationTheory to Cryptography (noisy channels). -/
structure MarkovKernel (α β : Type*) [Fintype α] [Fintype β] where
  kernel : α → β → ℝ
  nonneg : ∀ x y, 0 ≤ kernel x y
  sum_one : ∀ x, ∑ y : β, kernel x y = 1

/-- The output distribution when a channel acts on an input distribution.
    p_Y(y) = Σ_x p_X(x) · K(x,y) -/
def channelOutput {α β : Type*} [Fintype α] [Fintype β]
    (K : MarkovKernel α β) (p : PMF α) : PMF β where
  val := fun y => ∑ x : α, p.val x * K.kernel x y
  nonneg := fun y => Finset.sum_nonneg fun x _ =>
    mul_nonneg (p.nonneg x) (K.nonneg x y)
  sum_one := by
    rw [Finset.sum_comm]
    simp_rw [← Finset.mul_sum, K.sum_one, mul_one, p.sum_one]

-- ... (truncated, full file has 255 lines)
```

@Shared/TropicalEntropy/Theorems.lean
```lean
/-
Copyright (c) 2025. All rights reserved.

# Tropical Entropy Algebra — Core Theorems

## Overview

This file proves the main theorems of tropical entropy algebra, establishing
that the algebraic structure of the tropical semiring (ℝ, min, +) automatically
generates the fundamental inequalities of information theory, cryptography,
and thermodynamics.

## Main Results (25+ theorems)

### Max-Probability Bounds (InformationTheory ↔ Cryptography)
### Min-Entropy (InformationTheory ↔ Cryptography)
### Tropical Subadditivity (Algebra ↔ InformationTheory)
### Data Processing (InformationTheory ↔ Cryptography ↔ Physics)
### Thermodynamics (Physics ↔ Algebra)
### Distance and Robustness (ML ↔ InformationTheory)
### Tropical Algebra (Algebra ↔ Physics)
-/
import Mathlib
import Shared.TropicalEntropy.Defs

open Finset Real BigOperators

noncomputable section

namespace TropicalEntropyAlgebra

variable {α : Type*} [Fintype α] [Nonempty α]

/-! ## Part I: Properties of Max-Probability
    Bridge: connects InformationTheory (entropy) to Cryptography (guessing attacks) -/

/-- The maximum probability is always positive for a valid PMF. -/
theorem maxProb_pos (p : PMF α) : 0 < p.maxProb := by
  unfold PMF.maxProb
  rw [Finset.lt_sup'_iff]
  by_contra h; push_neg at h
  have : ∀ x, x ∈ Finset.univ → p.val x ≤ 0 := fun x hx => h x hx
  linarith [p.sum_one, Finset.sum_nonpos this]

/-- The maximum probability is at most 1. -/
theorem maxProb_le_one (p : PMF α) : p.maxProb ≤ 1 := by
  unfold PMF.maxProb
  rw [Finset.sup'_le_iff]
  intro x _
  calc p.val x ≤ ∑ y : α, p.val y :=
        Finset.single_le_sum (fun y _ => p.nonneg y) (Finset.mem_univ x)
    _ = 1 := p.sum_one

/-- Pigeonhole: max probability ≥ 1/|α|.
    Explicit bound: max_x p(x) ≥ 2^(-log|α|).
    Bridge: connects Algebra (pigeonhole) to Cryptography (guessing). -/
theorem maxProb_ge_inv_card (p : PMF α) :
    1 / (Fintype.card α : ℝ) ≤ p.maxProb := by
  by_contra h; push_neg at h
  have hlt : ∀ x, x ∈ Finset.univ → p.val x < 1 / (Fintype.card α : ℝ) :=
    fun x _ => lt_of_le_of_lt (Finset.le_sup' p.val (Finset.mem_univ x)) h
  have : ∑ x : α, p.val x < ∑ _x : α, (1 / (Fintype.card α : ℝ)) :=
    Finset.sum_lt_sum (fun x hx => le_of_lt (hlt x hx))
      ⟨Classical.arbitrary α, Finset.mem_univ _, hlt _ (Finset.mem_univ _)⟩
  simp [Finset.sum_const, Finset.card_univ] at this
  linarith [p.sum_one]

/-! ## Part II: Min-Entropy Bounds
    Bridge: connects InformationTheory to Cryptography (post-quantum security) -/

/-- Min-entropy is non-negative: H_∞(X) ≥ 0.
    Bridge: connects InformationTheory to Physics (second law). -/
theorem minEntropy_nonneg (p : PMF α) : 0 ≤ minEntropy p := by
  unfold minEntropy
  rw [neg_nonneg]
  exact Real.log_nonpos (le_of_lt (maxProb_pos p)) (maxProb_le_one p)

/-- Min-entropy ≤ max-entropy: H_∞(X) ≤ log|α|.
    Bridge: connects InformationTheory to Algebra (Hartley bound). -/
theorem minEntropy_le_maxEntropy (p : PMF α) :
    minEntropy p ≤ maxEntropy α := by
  unfold minEntropy maxEntropy
  suffices h : 1 ≤ (Fintype.card α : ℝ) * p.maxProb by
    have := Real.log_le_log (by positivity : (0:ℝ) < 1) h
    simp [Real.log_mul (by positivity : (Fintype.card α : ℝ) ≠ 0)
      (ne_of_gt (maxProb_pos p))] at this
    linarith
  calc 1 = ∑ x : α, p.val x := p.sum_one.symm
    _ ≤ ∑ _x : α, p.maxProb :=
        Finset.sum_le_sum fun x _ => Finset.le_sup' p.val (Finset.mem_univ x)
    _ = (Fintype.card α : ℝ) * p.maxProb := by
        simp [Finset.sum_const, Finset.card_univ]

/-- Min-entropy of uniform = log|α| (max-entropy).
    Bridge: connects InformationTheory to Algebra. -/
theorem minEntropy_uniform :
    minEntropy (uniformPMF α).toPMF = maxEntropy α := by
  unfold minEntropy maxEntropy PMF.maxProb uniformPMF
  simp [Finset.sup'_const, Real.log_inv, neg_neg]

/-! ## Part III: Tropical Subadditivity
    Bridge: connects Algebra (tropical distributivity) to InformationTheory -/

/-
Max-probability is multiplicative for product distributions.
    Bridge: connects Algebra to InformationTheory (independence).
-/
theorem tropical_subadditivity_maxProb {β : Type*} [Fintype β] [Nonempty β]
    (p : PMF α) (q : PMF β) :
    (productPMF p q).maxProb = p.maxProb * q.maxProb := by
  refine' le_antisymm _ _;
  · refine' Finset.sup'_le _ _ _;
    exact fun ⟨ a, b ⟩ _ => mul_le_mul ( Finset.le_sup' ( fun a => p.val a ) ( Finset.mem_univ a ) ) ( Finset.le_sup' ( fun b => q.val b ) ( Finset.mem_univ b ) ) ( q.nonneg b ) ( by exact le_trans ( p.nonneg a ) ( Finset.le_sup' ( fun a => p.val a ) ( Finset.mem_univ a ) ) );
  · unfold PMF.maxProb productPMF;
    obtain ⟨ x, hx ⟩ := Finset.exists_mem_eq_sup' Finset.univ_nonempty p.val;
    obtain ⟨ y, hy ⟩ := Finset.exists_mem_eq_sup' Finset.univ_nonempty q.val;
    simp_all +decide [ Finset.sup'_le_iff ];
    exact ⟨ x, y, le_rfl ⟩

/-- TROPICAL SUBADDITIVITY OF MIN-ENTROPY: H_∞(X,Y) = H_∞(X) + H_∞(Y)
    for independent random variables.

    Bridge: connects Algebra (tropical homomorphism) to InformationTheory
    to Cryptography (composable security bounds). -/
theorem tropical_subadditivity_minEntropy {β : Type*} [Fintype β] [Nonempty β]
    (p : PMF α) (q : PMF β) :
    minEntropy (productPMF p q) = minEntropy p + minEntropy q := by
  unfold minEntropy
  rw [tropical_subadditivity_maxProb,
    Real.log_mul (ne_of_gt (maxProb_pos p)) (ne_of_gt (maxProb_pos q))]
  ring

/-! ## Part IV: Data Processing Inequality
    Bridge: connects InformationTheory to Cryptography to Physics -/

/-- The pushforward distribution of p through f. -/
def pushforwardPMF [DecidableEq α] {β : Type*} [Fintype β] [DecidableEq β]
    (p : PMF α) (f : α → β) : PMF β where
  val := fun y => ∑ x ∈ Finset.univ.filter (fun x => f x = y), p.val x
  nonneg := fun y => Finset.sum_nonneg fun x _ => p.nonneg x
  sum_one := by
    rw [← Finset.sum_biUnion]
    · convert p.sum_one using 1
      rw [Finset.biUnion_filter_eq_of_maps_to (fun x _ => Finset.mem_univ (f x))]
    · intro y₁ _ y₂ _ hne
      exact Finset.disjoint_filter.mpr fun x _ h1 h2 => hne (h1 ▸ h2)

/-- DATA PROCESSING INEQUALITY (deterministic): max_y p_f(y) ≥ max_x p(x).
    Processing cannot create information.

-- ... (truncated, full file has 338 lines)
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

Research domain: Shared
Research mode: discover
