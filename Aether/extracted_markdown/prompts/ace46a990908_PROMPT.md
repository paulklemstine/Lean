
## PHASE B: PACKAGING ONLY — COMMUNICATING THE MATH

Phase A of this cycle has already done the math. Lean 4 files have
been produced with 3-5 world-class theorems. Your ONLY job in
Phase B is to **package this work for human readers**.

### DELIVERABLES (strict — only this):
1. **ARTICLE.md** — Standalone popular-science article (1500-3000 words).
   Write about IDEAS, not formal verification. No mentions of Lean or
   proof assistants. Vivid prose, narrative arc, real-world connections.
   **Must be fully self-contained and publishable without any external
   references.** State every theorem, result, and definition inline —
   do NOT use @file references or point to other files. A reader with
   only this article must understand every result without looking elsewhere.
2. **RESEARCH_PAPER.md** — In-depth research paper (3000-8000 words).
   Abstract, definitions, main results (with proof sketches — NOT
   full Lean), algorithms, applications, discussion, future work.
   **Must be fully self-contained and publishable quality without any
   external references.** State every theorem, lemma, and definition
   inline with its full mathematical statement and proof sketch. Do NOT
   use @file references or reference other files. A reader with only this
   paper must be able to follow every result from start to finish.
3. **RESEARCH_PAPER.tex** (NEW) — A clean, compilable LaTeX version of
   the paper that mirrors the content of RESEARCH_PAPER.md. Use standard
   amsmath/amsart or article class, define all theorems inline, and make
   it suitable for direct PDF compilation with `pdflatex`. This is the
   publishable artifact.
4. **demo.py** — Numerical examples demonstrating the key results.
   Self-contained Python, type hints, all functions inlined.
4. **PACKAGE.json** — Single JSON bundling all of the above, with this schema:

```json
{
  "title": "Human-Readable Package Title",
  "domain": "Algebra|Applications|Bridges|Computation|Cryptography|EML|Geometry|Logic|MachineLearning|Novelty|Physics|Pythagorean|Shared|Tropical",
  "description": "1-2 sentence description of the package",
  "authors": ["Author Name"],
  "date": "YYYY-MM-DD",
  "key_results": ["Key result 1", "Key result 2"],
  "keywords": ["keyword1", "keyword2"],
  "article": "ARTICLE.md",
  "research_paper": "RESEARCH_PAPER.md",
  "research_paper_tex": "RESEARCH_PAPER.tex",
  "demo": "demo.py",
  "demos": [
    {"name": "Descriptive and Professional Title of the Python Demo", "description": "A comprehensive, high-quality description of what this Python demo calculates and shows mathematically.", "code": "# full Python source..."}
  ],
  "algorithms": [
    {
      "name": "Formal Mathematical Title of the Algorithm",
      "description": "Detailed in-depth explanation of the algorithm, its mathematical foundation, computational complexity, and role in the pipeline.",
      "pseudocode": "Formal, structured step-by-step pseudocode detailing the logic.",
      "code": "# full Python source with type hints..."
    }
  ],
  "visualizations": [
    {"name": "Descriptive Visualization Title", "description": "What this visualizes", "code": "# standalone Python script that generates a visualization..."}
  ],
  "interactive_demos": [
    {"title": "Beautiful Math-Rich Interactive Widget Title", "description": "Detailed description of the interactive widget and what users can explore.", "html": "<!DOCTYPE html><html>...</html>"}
  ],
  "lean_proofs": "LEAN_FILE_CONTENT_OR_PLACEHOLDER",
  "future_directions": "FUTURE_DIRECTIONS_CONTENT",
  "modules": {"demo": "# full demo.py source..."},
  "lean_files": ["Catalog/Domain/Package/File.lean"]
}
```

**CRITICAL**: The `demos`, `algorithms`, `visualizations`, and
`interactive_demos` fields MUST be arrays of objects with the
exact structure shown above. Do NOT use placeholder strings like
"MISSING" — either include real content or omit the field entirely.

### DO NOT OUTPUT:
- NO new `.lean` files
- NO new theorem proofs
- NO changes to the existing Lean 4 source
- NO `FUTURE_DIRECTIONS.md` as a separate file (Phase A already produced
  future directions — they are provided below for inclusion in PACKAGE.json)

The math is already proved. Treat the Lean files below as the
ground truth — your prose should explain and contextualize them.
State theorems inline in your article and paper — they must be
self-contained and publishable without external references.


## Concept

**Title**: Cellular Automata at the Ordinals: Transfinite Computation
**Domain**: Shared
**Mathematical framing**: Prove that cellular automata can perform transfinite computations when run on ordinals instead of N. Formalize a Rule 110 analog on omega-squared and prove it achieves super-Turing computation. Connect to Infinite Time Turing Machines and ordinal computation.
Research domain: Shared
Research mode: formalize


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: c1948da4_retry3_aristotle/Catalog/Computation/TransfiniteCellularAutomata.lean
import Mathlib

/-!
# Transfinite cellular automata: limit stages on `ℕ`

This file develops a minimal core theory of *transfinite* cellular automata, focusing
exclusively on the construction of limit stages.

A cellular automaton acts on configurations `Config σ = ℕ → σ` via a radius-`1` local
rule `f : σ → σ → σ → σ`. The successor dynamics is the global update `step f`. To talk
about limit stages we record, for each ordinal stage, the configuration reached so far as
a *history* `H : Ordinal → Config σ`, and we ask that each coordinate be *eventually
constant below* a limit ordinal `λ`. Under that hypothesis the limit configuration exists
and is unique (`limit_exists_unique`), with an explicit characterization
(`limit_characterization`).

The concrete payload is the Boolean `ω`-stage: if a global map `F : Config Bool → Config
Bool` is pointwise inflationary, then along the chain of finite iterates every coordinate
is monotone, hence eventually constant, so the `ω`-limit configuration exists
(`omega_limit_exists`). The local "or" rule `l || c || r` is one such automaton
(`orRule_inflationary`, `orRule_omega_limit_exists`).
-/

namespace TransfiniteCA

open Ordinal

/-- A configuration assigns a state in `σ` to each cell of `ℕ`. -/
def Config (σ : Type*) : Type _ := ℕ → σ

/-- The one-step global update induced by a radius-`1` local rule `f`.
The left neighbour of cell `n` is `n - 1` in natural-number subtraction, so the left
neighbour of cell `0` is `0` itself. -/
def step {σ : Type*} (f : σ → σ → σ → σ) (c : Config σ) : Config σ :=
  fun n => f (c (n - 1)) (c n) (c (n + 1))

/-- A history `h : Ordinal → σ` is eventually constant with value `v` below `lam` if there
is a witness ordinal `β < lam` past which (and still below `lam`) `h` is always `v`. -/
def EventuallyConstBelow {σ : Type*} (h : Ordinal → σ) (v : σ) (lam : Ordinal) : Prop :=
  ∃ β, β < lam ∧ ∀ γ, β ≤ γ → γ < lam → h γ = v

/-- Coordinatewise eventual constancy: each coordinate history of `H` is eventually
constant below `lam`, with value given by the configuration `c`. -/
def EventuallyConstBelowConfig {σ : Type*} (H : Ordinal → Config σ) (c : Config σ)
    (lam : Ordinal) : Prop :=
  ∀ n, EventuallyConstBelow (fun α => H α n) (c n) lam

/--
The eventual value of a coordinate history below `lam` is unique.
-/
theorem eventuallyConstBelow_unique {σ : Type*} {h : Ordinal → σ} {u v : σ} {lam : Ordinal}
    (hu : EventuallyConstBelow h u lam) (hv : EventuallyConstBelow h v lam) : u = v := by
  obtain ⟨ βu, hβu, hu ⟩ := hu
  obtain ⟨ βv, hβv, hv ⟩ := hv;
  rw [ ← hu ( Max.max βu βv ) ( le_max_left _ _ ) ( max_lt hβu hβv ), ← hv ( Max.max βu βv ) ( le_max_right _ _ ) ( max_lt hβu hβv ) ]

/-- Choice of the eventual value at each coordinate, when one exists. -/
noncomputable def limitConfig {σ : Type*} (H : Ordinal → Config σ) (lam : Ordinal)
    (hyp : ∀ n, ∃ v, EventuallyConstBelow (fun α => H α n) v lam) : Config σ :=
  fun n => (hyp n).choose

/--
The constructed limit configuration realizes the eventual value at every coordinate.
-/
theorem limit_characterization {σ : Type*} (H : Ordinal → Config σ) (lam : Ordinal)
    (hyp : ∀ n, ∃ v, EventuallyConstBelow (fun α => H α n) v lam) :
    EventuallyConstBelowConfig H (limitConfig H lam hyp) lam := by
  exact fun n => ( hyp n ).choose_spec

/--
**Limit stage, existence and uniqueness.** If every coordinate history of `H` is
eventually constant below `lam`, then there is a unique configuration whose coordinates are
exactly those eventual values.
-/
theorem limit_exists_unique {σ : Type*} (H : Ordinal → Config σ) (lam : Ordinal)
    (hyp : ∀ n, ∃ v, EventuallyConstBelow (fun α => H α n) v lam) :
    ∃! c : Config σ, EventuallyConstBelowConfig H c lam := by
  refine' ⟨ limitConfig H lam hyp, limit_characterization H lam hyp, _ ⟩;
  intro y hy; funext n; apply eventuallyConstBelow_unique; exact hy n; exact (hyp n).choose_spec;

/-- Pointwise inflationarity of a global map on Boolean configurations. -/
def Inflationary (F : Config Bool → Config Bool) : Prop := ∀ c n, c n ≤ F c n

/--
Along the chain of finite iterates of an inflationary map, every coordinate is a
monotone Boolean sequence.
-/
theorem iterate_monotone (F : Config Bool → Config Bool) (hF : Inflationary F)
    (c0 : Config Bool) (n : ℕ) : Monotone (fun k => (F^[k] c0) n) := by
  refine' monotone_nat_of_le_succ _;
  exact fun k => by simpa only [ Function.iterate_succ_apply' ] using hF _ _;

/--
A monotone Boolean sequence is eventually constant.
-/
theorem bool_monotone_eventually_const (s : ℕ → Bool) (hs : Monotone s) :
    ∃ N, ∀ k, N ≤ k → s k = s N := by
  by_cases h : ∃ j, s j = true;
  · cases' h with N hN; use N; intros k hk; have := hs hk; aesop;
  · aesop

/-- A noncomputable retraction `Ordinal → ℕ` that is a genuine inverse of the cast below
`ω`. It is used to index the chain of finite iterates by ordinals `< ω`. -/
noncomputable def natOfOrdinal (α : Ordinal) : ℕ :=
  if h : α < ω then (lt_omega0.1 h).choose else 0

theorem natOfOrdinal_natCast (n : ℕ) : natOfOrdinal (n : Ordinal) = n := by
  unfold natOfOrdinal;
  split_ifs with h;
  · exact Nat.cast_injective ( lt_omega0.1 h |>.choose_spec.symm );
  · exact False.elim <| h <| Ordinal.nat_lt_omega0 n

theorem natCast_natOfOrdinal {α : Ordinal} (h : α < ω) : (natOfOrdinal α : Ordinal) = α := by
  unfold natOfOrdinal;
  grind

/--
**Boolean `ω`-limit.** For any pointwise inflationary global map `F` and any initial
configuration `c0`, the coordinate histories of the iterate chain (indexed by ordinals
`< ω`) are eventually constant below `ω`, so the `ω`-limit configuration exists uniquely.
-/
theorem omega_limit_exists (F : Config Bool → Config Bool) (hF : Inflationary F)
    (c0 : Config Bool) :
    ∃! c : Config Bool,
      EventuallyConstBelowConfig (fun α => F^[natOfOrdinal α] c0) c ω := by
  apply limit_exists_unique;
  intro n
  obtain ⟨N, hN⟩ : ∃ N, ∀ k, N ≤ k → (F^[k] c0) n = (F^[N] c0) n := by
    have := bool_monotone_eventually_const ( fun k => ( F^[k] c0 ) n ) ( iterate_monotone F hF c0 n ) ; aesop;
  refine' ⟨ _, N, Ordinal.nat_lt_omega0 N, _ ⟩;
  exact F^[N] c0 n;
  intro γ hγ₁ hγ₂; exact hN _ ( by exact_mod_cast natCast_natOfOrdinal hγ₂ ▸ hγ₁ ) ;

/-- The Boolean local "or" rule: a cell becomes `true` if it or either neighbour is. -/
def orRule : Bool → Bool → Bool → Bool := fun l c r => l || c || r

/--
The global step of the "or" rule is pointwise inflationary.
-/
theorem orRule_inflationary : Inflationary (step orRule) := by
  intro c n; simp +decide [ step ] ;
  cases c n <;> simp +decide [ orRule ]

/--
The `ω`-limit of the "or" cellular automaton exists and is unique.
-/
theorem orRule_omega_limit_exists (c0 : Config Bool) :
    ∃! c : Config Bool,
      EventuallyConstBelowConfig (fun α => (step orRule)^[natOfOrdinal α] c0) c ω := by
  convert omega_limit_exists ( step orRule ) orRule_inflationary c0

end TransfiniteCA
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — Cellular Automata at the Ordinals

Derived from the verified results in
`Catalog/Shared/TransfiniteCellularAutomata.lean` and
`Catalog/Shared/TransfiniteCAGardenOrdinalBridge.lean`.

These two files established, with 0 sorries:

* a transfinite (ordinal-indexed) cellular-automaton evolution `TransfiniteCA.run`
  that restricts to `step^[n]` on `ℕ` and applies a global limit rule at limit stages;
* the **ITTM limit law inside a cellular automaton** (`ittm_run_omega`): the value at
  stage `ω` is the `limsup` (`∃ᶠ`, "cofinally on") of the finite history;
* a **super-Turing separation** (`ittmLim_not_finitary`, `ittm_toggle_super_turing`):
  the parity automaton's finite orbit never converges, yet the `ω`-stage assigns it a
  definite value;
* a **cross-domain collapse theorem** (`wellfounded_transfinite_ca_collapses`): when an
  ordinal Lyapunov potential exists, the orbit reaches a non-Garden-of-Eden fixed point
  in `< ω` steps and the `ω`-stage adds nothing.

---

## Conjecture 1 — The potential dichotomy is exact

**Statement.** A transfinite cellular automaton's `ω`-stage is informative (differs from
every finite stage on some cell) **iff** the local rule admits *no* ordinal Lyapunov
potential on the reachable configurations.

The key insight is that `wellfounded_transfinite_ca_collapses` proves one direction
(potential ⇒ collapse) and the parity automaton refutes the converse hypothesis's
contrapositive, so the only missing piece is "no collapse ⇒ no potential," which should
follow from building a potential out of the stabilization stage itself.

Why now? We already have both halves as separate theorems in the bridge file; promoting
them to an `iff` only requires a converse construction, and the Mathlib ordinal API
(`Ordinal.lt_wf`, `nonincreasing_eventually_constant`) is in place.

## Conjecture 2 — A clock-hierarchy theorem at `ω·k`

**Statement.** For every `k`, there is a transfinite CA whose output first stabilizes at
stage `ω·k` and not before; hence the stages `ω·k` form a strict hierarchy of
computational power, and `ω²` strictly dominates every `ω·k`.

The key insight is that `omega_sq_has_infinitely_many_limit_stages` shows the limit stages
`ω·(k+1)` are cofinal below `ω²`, so iterating the `limsup` rule across them stacks `k`
independent ITTM limits — exactly the resource a single `ω`-limit cannot supply.

Why now? The cofinality lemma is already proved; the remaining work is a diagonal
construction nesting `k` copies of the `toggle` separation, each resolved one limit later.

## Conjecture 3 — Genuine ordinal limsup rule subsumes nat-sampling at `ω`

**Statement.** Replacing the nat-sampling `ittmLim` with the true ordinal `limsup`
("cell on cofinally below `o`") yields a rule that (a) agrees with `ittmLim` at `ω` but
(b) is strictly more expressive at every limit `o ≥ ω·2`.

The key insight is that `ittmLim` only reads stages `< ω` (documented as the Analyst's
failure mode), so it is blind to information cre
```

## Your task

Produce the deliverables listed above. The Lean file is the source of truth —
your prose must accurately explain it. Both ARTICLE.md and RESEARCH_PAPER.md
MUST be self-contained and publishable without referencing any external files.
State every theorem, definition, and result inline so a reader can follow the
entire argument from the document alone.

ARTICLE.md: write a popular-science narrative that makes the key idea accessible.
RESEARCH_PAPER.md: write the formal paper with abstract, definitions, results.
demo.py: write numerical examples that demonstrate the results.
PACKAGE.json: bundle everything into a single JSON with ALL fields populated.
Make sure demos, algorithms, visualizations, and interactive_demos are arrays
of objects (not placeholder strings). For each algorithm in the algorithms array, provide a clear, professional mathematical title in 'name' (do not use generic placeholders; this will be displayed as the header on the interactive site), a detailed explanation of its logic and complexity in 'description', formal step-by-step pseudocode in 'pseudocode', and clean type-hinted Python code in 'code'. For each Python demo in the demos array, provide a highly descriptive title in 'name', a comprehensive functional description in 'description', and the implementation code in 'code'. For each interactive HTML demo in interactive_demos, provide a beautiful title in 'title' and a detailed description in 'description'. Include future directions from Phase A in the future_directions field.

Be vivid, be precise, be world-class. The math has already been done — now
make it beautiful to read.
