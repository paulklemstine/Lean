
## PHASE B: PACKAGING ONLY — COMMUNICATING THE MATH

Phase A of this cycle has already done the math. Lean 4 files have
been produced with 3-5 world-class theorems. Your ONLY job in
Phase B is to **package this work for human readers**.

### DELIVERABLES (strict — only this):
1. **ARTICLE.md** — Standalone popular-science article (1500-3000 words).
   Write about IDEAS, not formal verification. No mentions of Lean or
   proof assistants. Vivid prose, narrative arc, real-world connections.
   Reference the specific theorems proved in Phase A using @file references.
2. **RESEARCH_PAPER.md** — In-depth research paper (3000-8000 words).
   Abstract, definitions, main results (with proof sketches — NOT
   full Lean), algorithms, applications, discussion, future work,
   references to catalog results. Use @file references for theorems.
3. **demo.py** — Numerical examples demonstrating the key results.
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
  "demo": "demo.py",
  "demos": [
    {"name": "descriptive_name", "description": "What this demo shows", "code": "# full Python source..."}
  ],
  "algorithms": [
    {"name": "descriptive_name", "pseudocode": "Brief description", "code": "# full Python source..."}
  ],
  "visualizations": [
    {"name": "descriptive_name", "description": "What this visualizes", "code": "# standalone Python script that generates a visualization..."}
  ],
  "interactive_demos": [
    {"title": "Interactive Widget Title", "description": "What users can explore", "html": "<!DOCTYPE html><html>...</html>"}
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
Use the @file references above to point readers to specific theorems.


## Concept

**Title**: Self-Modifying Code That Cannot Be Stopped
**Domain**: Geometry
**Mathematical framing**: Prove that any Turing-complete system with self-modification capabilities has no general algorithm for predicting its own termination. Formalize the halting problem for programs that can rewrite their own code mid-execution and show this is strictly harder than the classical halting problem. Connect to the virus paradox and AI alignment.
Research domain: Geometry
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Computation/SelfModifyingHalt.lean
/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Self-Modifying Computation and the Halting Problem

We formalize self-modifying computation — machines whose transition function
can change during execution — and prove that the halting problem for such
machines is equivalent to (not strictly harder than) the classical halting
problem. This contradicts the folk intuition that self-modification makes
termination analysis fundamentally harder.

## Main results

* `diagonal_no_decider` — abstract diagonalization: no total Boolean function
  can decide membership in the diagonal set of an enumerated family.
* `selfmod_halts_iff_standard` — behavioral equivalence between a self-modifying
  machine and its standard simulation.
* `no_selfmod_halting_decider` — the halting problem for self-modifying machines
  is undecidable.
* `selfmod_halting_reduces_to_standard` — many-one reduction from self-modifying
  halting to standard halting, and vice versa.

## Mathematical overview

A *self-modifying machine* over state type `S` and program type `P` is given by
a step function `step : P → S → Option (P × S)` where the program component `P`
can change at each step. The *standard simulation* encodes the current program
into the state, yielding a fixed-program machine. We prove mutual simulation
and deduce equivalence of the halting problems via abstract diagonalization.
-/

import Mathlib

-- ============================================================================
-- SECTION 1: Abstract Diagonalization
-- ============================================================================

namespace SelfModHalt

/-
Abstract diagonalization theorem: given a surjective enumeration of predicates
on `α`, no total Boolean function can agree with every predicate on its index.

This is the core engine behind all halting-problem undecidability results.
The proof is by contradiction: if such a decider `d` existed, the "anti-diagonal"
predicate `fun a => ¬ d a a` would be in the enumerated family (by surjectivity),
yielding a fixed point contradiction.

!-- The diagonal argument: if `enum` surjects onto Bool-valued functions on α,
no function d : α → α → Bool can satisfy d i a = enum i a for all i, a. --!--
-/
theorem diagonal_no_decider {α : Type*}
    (enum : α → α → Bool) (surj : Function.Surjective enum) :
    ¬ ∃ d : α → α → Bool, ∀ i a, d i a = enum i a := by
  obtain ⟨ f, hf ⟩ := surj ( fun x => not ( enum x x ) );
  have := congr_fun hf f; simp +decide at this;

/-
Concrete instance: the diagonal set {i | ¬ enum i i} is not in the range of enum
    when enum enumerates subsets via characteristic functions.
-/
example {α : Type*} (enum : α → α → Bool) (_surj : Function.Surjective enum) :
    ¬ ∃ j, ∀ a, enum j a = !enum a a := by
  intro ⟨j, hj⟩; have := hj j; simp at this

/-
Generalization: diagonal_no_decider holds for any type β with ≥ 2 elements,
    not just Bool.
-/
theorem diagonal_no_decider_general {α β : Type*} [DecidableEq β]
    (b₀ b₁ : β) (hne : b₀ ≠ b₁)
    (enum : α → α → β) (surj : Function.Surjective enum) :
    ¬ ∃ d : α → α → β, ∀ i a, d i a = enum i a := by
  obtain ⟨ j, hj ⟩ := surj ( fun i => if enum i i = b₀ then b₁ else b₀ );
  have := congr_fun hj j; by_cases h : enum j j = b₀ <;> simp +decide [ h ] at this;
  contradiction

/-
Boundary: the theorem fails when `enum` is not surjective.
    Here we exhibit a non-surjective enum with a valid decider.
-/
example : ∃ (enum : Fin 2 → Fin 2 → Bool),
    (¬ Function.Surjective enum) ∧
    (∃ d : Fin 2 → Fin 2 → Bool, ∀ i a, d i a = enum i a) := by
  simp +decide

-- ============================================================================
-- SECTION 2: Self-Modifying Machine Model
-- ============================================================================

/-- A self-modifying machine: the transition function takes and returns
    a program-state pair, allowing the program to change at each step. -/
structure SelfModMachine (P S : Type*) where
  /-- One-step transition: returns `none` if the machine halts -/
  step : P → S → Option (P × S)

/-- Configuration of a self-modifying machine -/
structure SelfModConfig (P S : Type*) where
  prog : P
  state : S

/-- Run a self-modifying machine for `n` steps. Returns `none` if it halted
    before completing `n` steps. -/
def SelfModMachine.run {P S : Type*} (m : SelfModMachine P S) :
    SelfModConfig P S → ℕ → Option (SelfModConfig P S)
  | cfg, 0 => some cfg
  | cfg, n + 1 => match m.step cfg.prog cfg.state with
    | none => none  -- halted
    | some (p', s') => m.run ⟨p', s'⟩ n

/-- A self-modifying machine halts from configuration `cfg` if there exists
    some step count at which it returns `none`. -/
def SelfModMachine.halts {P S : Type*} (m : SelfModMachine P S)
    (cfg : SelfModConfig P S) : Prop :=
  ∃ n : ℕ, m.run cfg n = none

-- ============================================================================
-- SECTION 3: Standard (Fixed-Program) Machine and Simulation
-- ============================================================================

/-- A standard (fixed-program) machine: the transition function only
    modifies the state, not the program. -/
structure StdMachine (S : Type*) where
  step : S → Option S

def StdMachine.run {S : Type*} (m : StdMachine S) : S → ℕ → Option S
  | s, 0 => some s
  | s, n + 1 => match m.step s with
    | none => none
    | some s' => m.run s' n

def StdMachine.halts {S : Type*} (m : StdMachine S) (s : S) : Prop :=
  ∃ n : ℕ, m.run s n = none

/-- The standard simulation of a self-modifying machine: encode the program
    into the state, yielding a fixed-program machine over `P × S`. -/
def SelfModMachine.toStd {P S : Type*} (m : SelfModMachine P S) :
    StdMachine (P × S) where
  step := fun ⟨p, s⟩ => match m.step p s with
    | none => none
    | some (p', s') => some (p', s')

/-
!-- Key simulation lemma: running the standard simulation for n steps
gives the same result as running the self-modifying machine for n steps. --!--
-/
theorem selfmod_run_eq_std_run {P S : Type*} (m : SelfModMachine P S)
    (cfg : SelfModConfig P S) (n : ℕ) :
    (m.run cfg n).map (fun c => (c.prog, c.state)) =
    m.toStd.run (cfg.prog, cfg.state) n := by
  induction' n with n ih generalizing cfg;
  · rfl;
  · grind +locals

/-
The step-level correspondence between self-modifying and standard runs.
-/
theorem selfmod_steps_eq_std_steps {P S : Type*} (m : SelfModMachine P S)
    (cfg : SelfModConfig P S) (n : ℕ) :
    m.run cfg n = none ↔ m.toStd.run (cfg.prog, cfg.state) n = none := by
  rw [ ← selfmod_run_eq_std_run ];
  cases m.run cfg n <;> simp +decide

/-
**Simulation Theorem**: A self-modifying machine halts from `cfg` if and
    only if its standard simulation halts from the corresponding state.

    This is the key result: self-modification adds no computational power
    beyond what a standard machine can achieve by encoding the program as data.

!-- Follows directly from selfmod_steps_eq_std_steps: halting is characterized by
some step returning none, and the simulation preserves this exactly. --!--
-/
theorem selfmod_halts_iff_standard {P S : Type*} (m : SelfModMachine P S)
    (cfg : SelfModConfig P S) :
    m.halts cfg ↔ m.toStd.halts (cfg.prog, cfg.state) := by
  exact exists_congr fun n => by simpa using selfmod_steps_eq_std_steps m cfg n;

-- PEGB for selfmod_halts_iff_standard:

/-- Example: a trivial self-modifying machine that immediately halts -/
example : let m : SelfModMachine Unit Unit := ⟨fun _ _ => none⟩
    let cfg : SelfModConfig Unit Unit := ⟨(), ()⟩
    m.halts cfg ↔ m.toStd.halts (cfg.prog, cfg.state) := by
  exact selfmod_halts_iff_standard _ _

/-
Boundary: for infinite state spaces, the simulation is faithful but
    the standard machine's state space is strictly larger (P × S vs S).
-/
theorem std_simulation_state_space_larger :
    ∃ (P S : Type) (_ : Fintype S
```

## Your task

Produce the deliverables listed above. Reference the specific theorems and
results in the Lean code by their @file path and statement. The Lean file is
the source of truth — your prose must accurately explain it.

ARTICLE.md: write a popular-science narrative that makes the key idea accessible.
RESEARCH_PAPER.md: write the formal paper with abstract, definitions, results.
demo.py: write numerical examples that demonstrate the results.
PACKAGE.json: bundle everything into a single JSON with ALL fields populated.
Make sure demos, algorithms, visualizations, and interactive_demos are arrays
of objects (not placeholder strings). Include future directions from Phase A
in the future_directions field.

Be vivid, be precise, be world-class. The math has already been done — now
make it beautiful to read.
