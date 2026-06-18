
            ## PHASE A: LEAN 4 ONLY — DOING THE MATH

            You are a world-class mathematician. Your ONLY job in this cycle is
to produce **new Lean 4 code that extends the frontier of mathematics**.

            ### DELIVERABLES (strict — only this):
            1. **lean files (count chosen by the Plan)**
            2. **2-4 theorems with correct proofs (sorry = 0 on main results)**
            3. **Brief proof sketches** as `-- !-- comment -- !--` blocks (1-2 sentences each)
            4. **A FUTURE_DIRECTIONS.md file** listing 3-5 testable, falsifiable
               conjectures as a freeform narrative (NOT a form). Each direction MUST
               include a "The key insight is..." sentence and a "Why now?" justification.
               This file drives the next research cycle — make it count.

            ### DO NOT OUTPUT (Phase B handles these — if your work passes quality bar):
            - NO `ARTICLE.md`
            - NO `RESEARCH_PAPER.md`
            - NO `demo.py` / `algorithms.py`
            - NO HTML widgets
            - NO `PACKAGE.json`
            - NO prose for human readers (except FUTURE_DIRECTIONS.md)

            ### WHY THIS NARROW:
            The Lean 4 file IS the deliverable. A self-contained Lean file with
            3-5 world-class theorems is worth more than 30K characters of prose
            about trivial results. Focus 100% of your compute on the math.
            If your work is genuinely world-class, the packaging step is dispatched
            automatically and cheaply.

            ### CATALOG SYNTHESIS (required — read the catalog context below):
            The Catalog Context and Recent Discoveries sections list existing theorems
            already proven in this project. You MUST analyze these and combine concepts
            from the catalog with the research direction above. Specifically:

            1. **Identify relevant catalog theorems** — Which existing results connect
               to your research direction? Cite them by name in your proof sketches.
            2. **Build on catalog foundations** — Your theorems should EXTEND or
               GENERALIZE catalog results, not reprove them from scratch. Use `import`
               and reference existing definitions and lemmas where possible.
            3. **Combine concepts across domains** — The most valuable theorems connect
               ideas from different catalog domains (e.g., applying algebraic structures
               to topological problems, or using combinatorial arguments in number theory).
               Look for cross-domain connections in the catalog context.
            4. **Avoid duplication** — Check the catalog context before proving. If a
               similar result already exists, extend it rather than reproving it.


## Concept

**Title**: Quantitative Arrow's Theorem via Tournament Curvature
**Domain**: Bridges
**Mathematical framing**: Given Tournament α with Has3Cycle T defined for 3-subsets {a,b,c} forming directed cycles: (1) Close the sorry proving tournament_no_3cycle_of_trans ↔ tournament_trans_of_no_3cycle (equivalence of transitivity and 3-cycle-freeness). (2) Define curvature : Tournament α → ℝ by κ(T) = |{S ∈ Finset α // S.card = 3 ∧ Has3Cycle T S}| / C(n,3). (3) Prove curvature T = 0 ↔ IsTransitive T, curvature T ∈ [0,1], with maximum attained iff T is the cyclic tournament on 3 vertices extended. (4) Define SocialWelfareFunction (aggregation of voter preferences) and MajorityTournament (pairwise majority rule). (5) Prove the quantitative Arrow bound: for any non-dictatorial F with m ≥ 3 alternatives and n odd voters, E[κ(MajorityTournament(F))] ≥ 1/(4m). This gives a metric on the space of aggregation rules where dictatorial rules are isolated points at curvature 0 and all non-dictatorial rules live in a curvature-bounded region.
**Concept description**: The key insight is that Arrow's impossibility theorem admits a quantitative strengthening through tournament curvature. For a tournament T on n vertices, define κ(T) as the fraction of 3-element subsets forming directed 3-cycles. Then κ(T) ∈ [0,1], κ(T) = 0 iff T is transitive, and crucially: any non-dictatorial aggregation rule on m ≥ 3 alternatives produces majority tournaments with expected curvature bounded below by a function of m and n. For 3 alternatives and odd n, any non-dictatorial rule yields κ ≥ 1/4. This transforms Arrow's qualitative impossibility into a quantitative tradeoff: the degree of dictatorship is inversely proportional to expected tournament curvature. Why now: The catalog has Bridges/ArrowCurvature/Defs.lean with Tournament, IsTransitive, Has3Cycle already defined and a foundational sorry (tournament_no_3cycle_of_trans ↔ tournament_trans_of_no_3cycle) that must be closed before curvature can be developed. The Bridges domain has 12007 declarations but only 2 sorries — massive under-explored territory. The Has3Cycle predicate is exactly the combinatorial foundation needed for curvature. Closing this sorry and building curvature theory creates the first quantitative bridge between social choice theory and combinatorial geometry, connecting Arrow's theorem to metric properties of tournament space.
**Novelty estimate**: 0.78
**Breakthrough potential**: 0.65
Research domain: Bridges
Research mode: formalize



### Catalog Context
@Bridges/ArrowCurvature/Defs.lean
```lean
import Mathlib

/-!
# Arrow's Theorem as Curvature of Preference Space

We formalize the connection between Arrow's impossibility theorem and the
geometry of preference aggregation. The central insight: Condorcet cycles
in majority voting correspond to *holonomy* (curvature) in the space of
preference profiles.

## Main Definitions

* `Tournament` — A complete asymmetric binary relation (majority tournament)
* `PreferenceProfile` — A collection of voter strict-order preferences
* `MajorityTournament` — The tournament induced by majority rule
* `SinglePeaked` — The single-peaked domain restriction
* `CondorcetCurvature` — Numerical curvature measuring cycle strength

## Main Results

* `tournament_trans_iff_no_3cycle` — Tournament transitivity ↔ no 3-cycle
* `single_peaked_majority_transitive` — Black's theorem: single-peaked ⟹ transitive majority
* `curvature_zero_iff_no_majority_cycle` — Zero curvature ↔ transitive majority
* `positive_curvature_obstruction` — Positive curvature implies existence of cycles
-/

open Finset Function

/-! ## Part I: Tournament Theory -/

/-- A tournament on `Fin n`: a complete, irreflexive, asymmetric relation.
    This models the majority relation in voting theory. -/
structure Tournament (n : ℕ) where
  /-- `beats a b` means `a` defeats `b` in pairwise comparison -/
  beats : Fin n → Fin n → Prop
  [beatsDecidable : DecidableRel beats]
  beats_irrefl : ∀ a, ¬beats a a
  beats_complete : ∀ a b, a ≠ b → beats a b ∨ beats b a
  beats_asymm : ∀ a b, beats a b → ¬beats b a

attribute [instance] Tournament.beatsDecidable

namespace Tournament

variable {n : ℕ} (T : Tournament n)

/-- A tournament is transitive -/
def IsTransitive : Prop :=
  ∀ a b c : Fin n, T.beats a b → T.beats b c → T.beats a c

/-- A tournament has a 3-cycle (Condorcet cycle) -/
def Has3Cycle : Prop :=
  ∃ a b c : Fin n, T.beats a b ∧ T.beats b c ∧ T.beats c a

/-- The number of directed 3-cycles (curvature count) -/
noncomputable def cycleCount : ℕ :=
  ((Finset.univ (α := Fin n × Fin n × Fin n)).filter
    (fun ⟨a, b, c⟩ => T.beats a b ∧ T.beats b c ∧ T.beats c a)).card

end Tournament
-- ... (truncated, full file has 436 lines)
```

@Bridges/AlgebraEMLClosureComputation.lean
```lean
/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Algebra–EML Turing–Myhill Reconstruction via Closure Semimodule Dynamics

This file formalizes a Myhill–Nerode-style minimal quotient reconstruction from
semiring-valued closure observables.

## Central Bridge

- **Automata theory / intrinsic computation**: closure-driven weighted transition semantics
- **Semiring-linear dynamics / Koopman-style closure evolution**: probe observables
- **Thermodynamic / quantum / cryptographic interpretations**: indistinguishability
-/

import Mathlib

universe u v w

/-! ## §1 Core Definitions -/

/-- A closure semimodule system: a deterministic transition system equipped with
a closure operator on state sets and a semiring-valued output function.

Bridge: connects automata theory to Koopman dynamics and semiring-linear algebra
via closure-enriched observational semantics. -/
structure ClosureSemimoduleSystem
    (σ : Type u) (α : Type v) (K : Type w)
    [Semiring K] where
  step : σ → α → σ
  output : σ → K
  closure : Set σ → Set σ
  closure_extensive : ∀ S : Set σ, S ⊆ closure S
  closure_mono : ∀ ⦃S T : Set σ⦄, S ⊆ T → closure S ⊆ closure T
  closure_idem : ∀ S : Set σ, closure (closure S) ⊆ closure S

/-- Bridge: a family of semiring-valued probes on states, connecting to quantum
observables and Koopman eigenfunctions. -/
structure ProbeFamily (σ : Type u) (K : Type w) [Semiring K] where
  probes : Set (σ → K)

/-- Bridge: a closure-stable probe is an observable invariant under closure expansion,
connecting to Koopman eigenfunctions and quantum coarse-grained observables. -/
def ClosureStableProbe
    {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) (p : σ → K) : Prop :=
  ∀ S : Set σ, ∀ x ∈ M.closure S, ∃ y ∈ S, p x = p y

/-- Bridge: a Koopman-style observable pairs a probe with its spectral weight,
connecting Koopman operator theory to closure automata semantics and
thermodynamic partition functions. -/
structure ThermoKoopmanObservable (σ : Type u) (K : Type w) [Semiring K] where
  observable : σ → K
  spectralWeight : K

/-- Bridge: post-quantum indistinguishability captures the property that no
probe family can distinguish two states, connecting automata quotients to
post-quantum security via observational completeness. -/
def PostQuantumIndistinguishability
-- ... (truncated, full file has 758 lines)
```

@Bridges/AlgebraEMLReconstruction.lean
```lean
/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Algebraic–EML Tannaka Reconstruction via Closure Endomorphism Monoids

This file formalizes a reconstruction principle: a finitary closure operator on a
set is completely determined by its closed-set lattice, and hence by any
data (such as an endomorphism monoid) that determines that lattice. This bridges:
- **Algebraic lattice theory** / closure operators
- **Semiring and endomorphism algebra**
- **EML / Lawvere-style fixed-point semantics**
- **Post-quantum lattice cryptography** (separator hardness)

## Main results

* `closure_subset_closed_of_subset` — closed sets absorb closures of subsets
* `compactClosed_closed` — compact-closed sets are closed
* `algebraicLike_finite_witness` — finitary closures have finite witnesses
* `closure_eq_sInf_closed_eq` — closure = infimum of closed supersets
* `reconstructsClosure_empty` — reconstruction from closed sets (empty monoid)
* `closure_eq_of_sameClosedSets` — **Tannaka uniqueness**: closures with
  the same closed-set lattice must be equal
* `closure_eq_of_endMonoid_eq` — endomorphism monoid + separator → equal closures
* `closure_pointwise_quantum_reconstruction` — pointwise membership corollary
* `lipschitz_certified_robustness_identity` — identity is 1-Lipschitz on set distance
* `post_quantum_lattice_separator_bound` — finite separator orbit bound

## References

Inspired by Tannakian reconstruction in representation theory, adapted to
closure dynamics in the spirit of Lawvere's fixed-point semantics.
-/

import Mathlib

open Function Set Classical

noncomputable section

namespace Bridges.AlgebraEMLReconstruction

/-! ## Section 1: Basic Closure Operator -/
section BasicClosure

/-- A set-level closure operator: extensive, monotone, idempotent. -/
structure SetClosureOperator (α : Type*) where
  toFun : Set α → Set α
  extensive : ∀ s, s ⊆ toFun s
  monotone : Monotone toFun
  idempotent : ∀ s, toFun (toFun s) = toFun s

instance {α : Type*} : CoeFun (SetClosureOperator α) (fun _ => Set α → Set α) :=
  ⟨SetClosureOperator.toFun⟩

@[simp] theorem SetClosureOperator.coe_apply {α : Type*} (cl : SetClosureOperator α)
    (s : Set α) : cl.toFun s = cl s := rfl

/-- A set is closed under `cl` if applying `cl` leaves it unchanged. -/
def ClosedSet {α : Type*} (cl : SetClosureOperator α) (s : Set α) : Prop :=
-- ... (truncated, full file has 575 lines)
```


### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v7 Depth Requirements — Structured Proofs with Completeness Gates

You are producing Lean 4 code on the mathematical frontier. Your output must
be COMPILABLE and your proofs must be COMPLETE. A single correct proof of a
non-trivial result is worth more than 5 theorems with `sorry`.

### STEP 1: THEOREM DECLARATIONS (required — before any code)

List every theorem you intend to prove. For each, state:
- **Name**: The Lean declaration name
- **Statement**: One-sentence informal statement
- **Status**: `proved` | `conjecture` | `proved_with_lemma_sorry`
- **Why non-trivial**: One sentence on the key mathematical insight

Example:
1. `cantorPairing_surjective`: Cantor pairing is surjective — proved — constructive inverse
2. `cantorPairing_injective`: Cantor pairing is injective — proved — diagonal argument
3. `cantorPairing_bijection`: Cantor pairing is a bijection — proved_with_lemma_sorry — follows from 1+2

### STEP 2: PROVE THEOREMS (completeness gate)

Every theorem declared as `proved` MUST have a complete, compiling Lean proof.
No `sorry` on the main result. If you cannot complete a proof, change its status
to `conjecture` or `proved_with_lemma_sorry` and explain why.

For `proved_with_lemma_sorry`:
- The theorem statement must be complete (no sorry in the statement)
- `sorry` is allowed ONLY in supporting lemmas, never the main proof
- A comment must explain what the sorry replaces and why it's deferred

For your BEST theorem, also provide:
- A generalization or strengthening (can use sorry if proving would take too long)
- A boundary case or counterexample showing where the result fails

### STEP 3: Anti-patterns (reject these)

These tactics indicate trivial proofs:
- `native_decide` / `decide` / `norm_num` / `rfl` — unless genuinely proving a numeric fact
- `simp only []` with no simp set specified
- `sorry` on any theorem declared as `proved`

`omega`, `linarith`, and `Aesop` are fine for supporting lemmas.
`sorry` is fine for conjectures and generalizations.

### STEP 4: Novelty

Your theorems must be genuinely new. If a statement appears in a textbook,
generalize it. If you cannot formalize a concept rigorously, pick a different topic.

### Output format

Your output must include:
1. `.lean` files with the proofs (structured as declared in Step 1)
2. `FUTURE_DIRECTIONS.md` with 3-5 research conjectures extending the work

Both are required. Missing FUTURE_DIRECTIONS.md = automatic quality penalty.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
