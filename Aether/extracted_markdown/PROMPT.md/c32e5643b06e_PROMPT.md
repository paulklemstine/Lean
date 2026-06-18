

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

[API_ERROR: Server error '504 Gateway Timeout' for url 'https://gen.pollinations.ai/v1/chat/completions'
For more information check: https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/504 - {"success":false,"error":{"message":"Upstream provider timed out after 90000ms","code":"UNKNOWN_ERROR","timestamp":"2026-05-06T23:02:47.282Z","details":{"name":"UpstreamError","upstreamStatus":504,"upstreamHost":"gen.pollinations.ai"},"cause":{"status":504,"model":"gpt-5.4"}},"status":504}]

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
            Define an entropic transport kernel on the prime spectrum of a coherent closure proof semiring and prove a Sinkhorn-type factorization theorem: every strictly positive proof-cost kernel K on SpectralPoint S induces a unique pair of scaling potentials whose diagonal rescaling realizes the Gibbs-optimal countermodel coupling with prescribed marginals. Then prove that the resulting iterative scaling algorithm converges and yields computable upper/lower bounds on non-derivability separation rates. This extends the recently productive Schrödinger-bridge/thermodynamic line, but differs from in-flight work by targeting matrix-scaling structure, convergence, and algorithmic factorization rather than minimizers, dual semantics, PAC-Bayes, or online regret.

            ### Precise Mathematical Framing
            Let P := SpectralPoint S for a coherent closure proof semiring S with finite prime spectrum. Equip P with a strictly positive reference measure μ and a proof-cost c : P → P → ℝ. Define K(p,q) = exp(-β * c p q). For admissible source/target marginals a,b on P, define the entropic transport functional J(π) = Σ_{p,q} π(p,q) c(p,q) + ε KL(π || μ⊗μ) subject to row marginals a and column marginals b. Prove: (1) existence/uniqueness of the optimizer π*; (2) factorization π*(p,q)=u(p) K(p,q) v(q) μ(p) μ(q); (3) iterative proportional fitting/Sinkhorn updates on (u,v) converge geometrically under positivity bounds; (4) the induced transport free energy gives a computable separation functional T_ε(x,y) built from source mass on witnesses supporting x and sink mass on witnesses refuting y; (5) if derivable x y then T_ε(x,y)=0, while if not derivable x y then under spectral separability assumptions T_ε(x,y)>0; (6) rounding/support-thresholding of π* yields sparse approximate witness plans and a polynomial-time certificate pipeline. This creates a new algorithmic transport layer for proof semantics, connecting entropic OT, matrix scaling, and spectral logic.

            ### Lean 4 Sketch
theorem sinkhorn_factorization_exists_unique
    [CoherentClosureProofSemiring S] [Fintype (SpectralPoint S)]
    (μ : SpectralPoint S → ℝ) (hμ : ∀ p, 0 < μ p)
    (c : SpectralPoint S → SpectralPoint S → ℝ)
    (β ε : ℝ) (hβ : 0 < β) (hε : 0 < ε)
    (a b : SpectralPoint S → ℝ)
    (ha : IsProb a) (hb : IsProb b) :
    ∃! (u v : SpectralPoint S → ℝ),
      (∀ p, 0 < u p) ∧ (∀ q, 0 < v q) ∧
      let K := fun p q => Real.exp (-β * c p q / ε)
      let π := fun p q => u p * K p q * v q * μ p * μ q
      rowMarginal π = a ∧ colMarginal π = b := by
  sorry

theorem sinkhorn_iterates_converge
    [CoherentClosureProofSemiring S] [Fintype (SpectralPoint S)]
    ... :
    Tendsto (sinkhornIterate K a b) atTop (nhds (u,v)) := by
  sorry

theorem entropic_transport_separation_sound
    [CoherentClosureProofSemiring S] [Fintype (SpectralPoint S)]
    (x y : S) : derivable x y → transportGap ε β x y = 0 := by
  sorry

theorem entropic_transport_separation_complete
    [CoherentClosureProofSemiring S] [Fintype (SpectralPoint S)]
    (x y : S) : spectralSeparable x y → ¬ derivable x y → 0 < transportGap ε β x y := by
  sorry

            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `pac_bayes_prime_spectral_bound_of_mgf` : theorem pac_bayes_prime_spectral_bound_of_mgf {S : Type*} {n : ℕ}
     (file: Bridges/PACBayesBound.lean)
  2. `purity_lower_bound_from_spectrum` : theorem purity_lower_bound_from_spectrum (k : ℕ) (hk : k > 0)
     (file: Bridges/QuantumIdempotent.lean)
  3. `rate_distortion_duality_of_coherent_proof_semiring` : theorem rate_distortion_duality_of_coherent_proof_semiring
     (file: Bridges/LawvereRateDistortionDuality.lean)
  4. `thermodynamic_prime_separation` : theorem thermodynamic_prime_separation
     (file: Bridges/ThermodynamicStonePrimeCompleteness.lean)
  5. `unique_top2Set_iff_positive_pair_margin` : theorem unique_top2Set_iff_positive_pair_margin (x : Fin 3 → ℝ) :
     (file: Bridges/TropicalSatakeTop2Margin.lean)

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



Recent successful concepts: Thermodynamic Reflection Capacity and a Sharp Incompleteness Threshold for Closure Self-Models, Prime-Spectral Schrödinger Bridge for Closure-Generated Proof Semirings via Entropic Countermodel Transport, Thermodynamic Sanov–Large-Deviation Completeness for Closure Self-Models via Prime-Spectral Free-Energy Rate Function


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
            @Speculative/AutoResearch/ThermodynamicSanovCompleteness.lean
```lean
/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Thermodynamic Sanov–Large-Deviation Completeness for Closure Self-Models
# via Prime-Spectral Free-Energy Rate Function

This file establishes that derivability in a coherent closure proof semiring
is equivalent to the vanishing of a thermodynamic rate function across all
inverse temperatures β > 0.

## Main results

* `derivable_iff_zero_defect` — semantic adequacy: derivability ↔ zero defect
  at all spectral points.
* `thermodynamicRate_nonneg` — the rate functional is nonneg for nonneg inputs.
* `thermodynamicRate_self_zero_of_derivable` — derivable implies zero rate at reference.
* `nonderivable_rate_at_ref_pos` — non-derivable implies positive rate at reference.
* `thermodynamic_sanov_completeness` — the main biconditional theorem.
* `nonderivable_has_positive_rate_gap` — non-derivability creates a positive rate gap.
-/

import Mathlib

noncomputable section

open Finset BigOperators Classical

/-! ## Part 1: Coherent Closure Proof Semirings -/

/-- A **coherent closure proof semiring** is a bounded distributive lattice `S`
equipped with a closure operator `cl : S → S` satisfying extensiveness,
idempotency, and monotonicity. -/
class CoherentClosureProofSemiring (S : Type*) extends DistribLattice S, BoundedOrder S where
  cl : S → S
  cl_extensive : ∀ x : S, x ≤ cl x
  cl_idempotent : ∀ x : S, cl (cl x) = cl x
  cl_monotone : ∀ x y : S, x ≤ y → cl x ≤ cl y

namespace ThermodynamicSanov

variable {S : Type*} [CoherentClosureProofSemiring S]

abbrev cl : S → S := CoherentClosureProofSemiring.cl

def derivable (x y : S) : Prop := cl x ≤ cl y

theorem derivable_refl (x : S) : derivable x x := le_refl _

theorem derivable_trans {x y z : S} (hxy : derivable x y) (hyz : derivable y z) :
    derivable x z := le_trans hxy hyz

/-! ## Part 2: Spectral Points -/

/-- A **spectral point** of a coherent closure proof semiring is a prime filter
compatible with the closure operator. -/
structure SpectralPoint (S : Type*) [CoherentClosureProofSemiring S] where
  val : S → Prop
  val_mono : ∀ {a b : S}, a ≤ b → val a → val b
  val_top : val ⊤
  val_inf : ∀ a b : S, val (a ⊓ b) ↔ val a ∧ val b
  val_prime : ∀ a b : S, val (a ⊔ b) → val a ∨ val b
  val_cl : ∀ x : S, val (cl x) ↔ val x

/-! ## Part 3: Countermodel Defect Observable -/

/-- The **countermodel defect** observable. Returns `1` when the spectral point
separates `x` from `y`, and `0` otherwise. -/
def countermodelDefect (x y : S) (p : SpectralPoint S) : ℝ :=
  if p.val (cl x) ∧ ¬p.val (cl y) then 1 else 0

theorem countermodelDefect_nonneg (x y : S) (p : SpectralPoint S) :
    0 ≤ countermodelDefect x y p := by
  unfold countermodelDefect; split_ifs <;> norm_num

theorem countermodelDefect_le_one (x y : S) (p : SpectralPoint S) :
    countermodelDefect x y p ≤ 1 := by
  unfold countermodelDefect; split_ifs <;> norm_num

/-- Derivability kills the defect. -/
theorem derivable_implies_zero_defect (x y : S) (h : derivable x y)
    (p : SpectralPoint S) : countermodelDefect x y p = 0 := by
  unfold countermodelDefect
  rw [if_neg]
  push_neg
  exact fun hval => p.val_mono h hval

theorem countermodelDefect_eq_zero_iff (x y : S) (p : SpectralPoint S) :
    countermodelDefect x y p = 0 ↔ (p.val (cl x) → p.val (cl y)) := by
  unfold countermodelDefect
  constructor
  · intro h
    split_ifs at h with hc
    · exact absurd h one_ne_zero
    · push_neg at hc; exact hc
  · intro h
    rw [if_neg]
    push_neg; exact h

/-! ## Part 4: Prime Spectral Completeness -/

/-- The prime spectral completeness hypothesis. -/
class PrimeSpectralComplete (S : Type*) [CoherentClosureProofSemiring S] : Prop where
  separation : ∀ x y : S, ¬derivable x y →
    ∃ p : SpectralPoint S, p.val (cl x) ∧ ¬p.val (cl y)

/-- **Semantic adequacy**: derivability ↔ zero defect everywhere. -/
theorem derivable_iff_zero_defect [PrimeSpectralComplete S] (x y : S) :
    derivable x y ↔ ∀ p : SpectralPoint S, countermodelDefect x y p = 0 := by
  constructor
  · exact derivable_implies_zero_defect x y
  · intro h
    by_contra hnd
    obtain ⟨p, hp1, hp2⟩ := PrimeSpectralComplete.separation x y hnd
    have := h p
    unfold countermodelDefect at this
    simp [hp1, hp2] at this

/-- Non-derivability produces a spectral point with positive defect. -/
theorem nonderivable_exists_positive_defect [PrimeSpectralComplete S] (x y : S)
    (h : ¬derivable x y) :
    ∃ p : SpectralPoint S, 0 < countermodelDefect x y p := by
  obtain ⟨p, hp1, hp2⟩ := PrimeSpectralComplete.separation x y h
  exact ⟨p, by unfold countermodelDefect; simp [hp1, hp2]⟩

/-! ## Part 5: Divergence -/

/-- A **divergence** on a type `Ω` satisfying the core properties:
nonnegativity, identity of indiscernibles, and faithfulness. -/
structure Divergence (Ω : Type*) where
  d : (Ω → ℝ) → (Ω → ℝ) → ℝ
  d_nonneg : ∀ ν μ : Ω → ℝ, 0 ≤ d ν μ
  d_self : ∀ μ : Ω → ℝ, d μ μ = 0
  d_faithful : ∀ ν μ : Ω → ℝ, d ν μ = 0 → ν = μ

/-! ## Part 6: Thermodynamic Rate Function -/

variable [Fintype (SpectralPoint S)]

/-- The **energy defect functional**. -/
def energyDefect (x y : S) (β : ℝ) (ν : SpectralPoint S → ℝ) : ℝ :=
  β * ∑ p : SpectralPoint S, ν p * countermodelDefect x y p

/-- The **thermodynamic rate functional**. -/
def thermodynamicRate (D : Divergence (SpectralPoint S))
    (μ : SpectralPoint S → ℝ) (β : ℝ) (x y : S)
    (ν : SpectralPoint S → ℝ) : ℝ :=
  D.d ν μ + energyDefect x y β ν

/-- Energy defect is nonneg when `β ≥ 0` and `ν ≥ 0`. -/
-- ... (truncated, full file has 477 lines)
```


### Catalog Reference Files
            @Speculative/AutoResearch/ThermodynamicSanovCompleteness.lean
```lean
/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Thermodynamic Sanov–Large-Deviation Completeness for Closure Self-Models
# via Prime-Spectral Free-Energy Rate Function

This file establishes that derivability in a coherent closure proof semiring
is equivalent to the vanishing of a thermodynamic rate function across all
inverse temperatures β > 0.

## Main results

* `derivable_iff_zero_defect` — semantic adequacy: derivability ↔ zero defect
  at all spectral points.
* `thermodynamicRate_nonneg` — the rate functional is nonneg for nonneg inputs.
* `thermodynamicRate_self_zero_of_derivable` — derivable implies zero rate at reference.
* `nonderivable_rate_at_ref_pos` — non-derivable implies positive rate at reference.
* `thermodynamic_sanov_completeness` — the main biconditional theorem.
* `nonderivable_has_positive_rate_gap` — non-derivability creates a positive rate gap.
-/

import Mathlib

noncomputable section

open Finset BigOperators Classical

/-! ## Part 1: Coherent Closure Proof Semirings -/

/-- A **coherent closure proof semiring** is a bounded distributive lattice `S`
equipped with a closure operator `cl : S → S` satisfying extensiveness,
idempotency, and monotonicity. -/
class CoherentClosureProofSemiring (S : Type*) extends DistribLattice S, BoundedOrder S where
  cl : S → S
  cl_extensive : ∀ x : S, x ≤ cl x
  cl_idempotent : ∀ x : S, cl (cl x) = cl x
  cl_monotone : ∀ x y : S, x ≤ y → cl x ≤ cl y

namespace ThermodynamicSanov

variable {S : Type*} [CoherentClosureProofSemiring S]

abbrev cl : S → S := CoherentClosureProofSemiring.cl

def derivable (x y : S) : Prop := cl x ≤ cl y

theorem derivable_refl (x : S) : derivable x x := le_refl _

theorem derivable_trans {x y z : S} (hxy : derivable x y) (hyz : derivable y z) :
    derivable x z := le_trans hxy hyz

/-! ## Part 2: Spectral Points -/

/-- A **spectral point** of a coherent closure proof semiring is a prime filter
compatible with the closure operator. -/
structure SpectralPoint (S : Type*) [CoherentClosureProofSemiring S] where
  val : S → Prop
  val_mono : ∀ {a b : S}, a ≤ b → val a → val b
  val_top : val ⊤
  val_inf : ∀ a b : S, val (a ⊓ b) ↔ val a ∧ val b
  val_prime : ∀ a b : S, val (a ⊔ b) → val a ∨ val b
  val_cl : ∀ x : S, val (cl x) ↔ val x

/-! ## Part 3: Countermodel Defect Observable -/

/-- The **countermodel defect** observable. Returns `1` when the spectral point
separates `x` from `y`, and `0` otherwise. -/
def countermodelDefect (x y : S) (p : SpectralPoint S) : ℝ :=
  if p.val (cl x) ∧ ¬p.val (cl y) then 1 else 0

theorem countermodelDefect_nonneg (x y : S) (p : SpectralPoint S) :
    0 ≤ countermodelDefect x y p := by
  unfold countermodelDefect; split_ifs <;> norm_num

theorem countermodelDefect_le_one (x y : S) (p : SpectralPoint S) :
    countermodelDefect x y p ≤ 1 := by
  unfold countermodelDefect; split_ifs <;> norm_num

/-- Derivability kills the defect. -/
theorem derivable_implies_zero_defect (x y : S) (h : derivable x y)
    (p : SpectralPoint S) : countermodelDefect x y p = 0 := by
  unfold countermodelDefect
  rw [if_neg]
  push_neg
  exact fun hval => p.val_mono h hval

theorem countermodelDefect_eq_zero_iff (x y : S) (p : SpectralPoint S) :
    countermodelDefect x y p = 0 ↔ (p.val (cl x) → p.val (cl y)) := by
  unfold countermodelDefect
  constructor
  · intro h
    split_ifs at h with hc
    · exact absurd h one_ne_zero
    · push_neg at hc; exact hc
  · intro h
    rw [if_neg]
    push_neg; exact h

/-! ## Part 4: Prime Spectral Completeness -/

/-- The prime spectral completeness hypothesis. -/
class PrimeSpectralComplete (S : Type*) [CoherentClosureProofSemiring S] : Prop where
  separation : ∀ x y : S, ¬derivable x y →
    ∃ p : SpectralPoint S, p.val (cl x) ∧ ¬p.val (cl y)

/-- **Semantic adequacy**: derivability ↔ zero defect everywhere. -/
theorem derivable_iff_zero_defect [PrimeSpectralComplete S] (x y : S) :
    derivable x y ↔ ∀ p : SpectralPoint S, countermodelDefect x y p = 0 := by
  constructor
  · exact derivable_implies_zero_defect x y
  · intro h
    by_contra hnd
    obtain ⟨p, hp1, hp2⟩ := PrimeSpectralComplete.separation x y hnd
    have := h p
    unfold countermodelDefect at this
    simp [hp1, hp2] at this

/-- Non-derivability produces a spectral point with positive defect. -/
theorem nonderivable_exists_positive_defect [PrimeSpectralComplete S] (x y : S)
    (h : ¬derivable x y) :
    ∃ p : SpectralPoint S, 0 < countermodelDefect x y p := by
  obtain ⟨p, hp1, hp2⟩ := PrimeSpectralComplete.separation x y h
  exact ⟨p, by unfold countermodelDefect; simp [hp1, hp2]⟩

/-! ## Part 5: Divergence -/

/-- A **divergence** on a type `Ω` satisfying the core properties:
nonnegativity, identity of indiscernibles, and faithfulness. -/
structure Divergence (Ω : Type*) where
  d : (Ω → ℝ) → (Ω → ℝ) → ℝ
  d_nonneg : ∀ ν μ : Ω → ℝ, 0 ≤ d ν μ
  d_self : ∀ μ : Ω → ℝ, d μ μ = 0
  d_faithful : ∀ ν μ : Ω → ℝ, d ν μ = 0 → ν = μ

/-! ## Part 6: Thermodynamic Rate Function -/

variable [Fintype (SpectralPoint S)]

/-- The **energy defect functional**. -/
def energyDefect (x y : S) (β : ℝ) (ν : SpectralPoint S → ℝ) : ℝ :=
  β * ∑ p : SpectralPoint S, ν p * countermodelDefect x y p

/-- The **thermodynamic rate functional**. -/
def thermodynamicRate (D : Divergence (SpectralPoint S))
    (μ : SpectralPoint S → ℝ) (β : ℝ) (x y : S)
    (ν : SpectralPoint S → ℝ) : ℝ :=
  D.d ν μ + energyDefect x y β ν

/-- Energy defect is nonneg when `β ≥ 0` and `ν ≥ 0`. -/
-- ... (truncated, full file has 477 lines)
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

Research domain: Bridges
Research mode: formalize
