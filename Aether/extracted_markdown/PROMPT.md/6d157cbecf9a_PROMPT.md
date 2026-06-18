
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
    {
      "name": "descriptive_name",
      "description": "Detailed in-depth explanation of the algorithm, its mathematical foundation, computational complexity, and role in the pipeline.",
      "pseudocode": "Formal, structured step-by-step pseudocode detailing the logic.",
      "code": "# full Python source with type hints..."
    }
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
State theorems inline in your article and paper — they must be
self-contained and publishable without external references.


## Concept

**Title**: Natural Proofs Barrier: Formalization
**Domain**: Novelty
**Mathematical framing**: Formalize the Razborov-Rudich natural proofs barrier: circuit lower bound proofs using 'natural' properties cannot separate P from NP unless pseudorandom generators don't exist. Explore algebrization.
Research domain: Novelty
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Computation/NaturalProofsBarrier.lean
import Mathlib

/-!
# The Razborov–Rudich Natural Proofs Barrier: a Quantitative Distinguisher

This file formalizes the *core mechanism* of the Razborov–Rudich natural proofs
barrier (1994). The catalog already contains a **skeleton** of the barrier in
`Catalog/Computation/BarrierFramework.lean`
(`BoolFnProperty`, `IsLargeProperty`, `IsUsefulAgainst`,
`natural_proof_distinguisher`) and the *relativization* / *algebrization*
barriers in `Catalog/Computation/CircuitBarriers.lean`
(`relativization_barrier`, `algebrization_barrier`,
`no_relativizing_equivalence`).

Those skeletons only assert the *existence* of a hard function inside a large,
useful property — they never extract the actual cryptographic distinguisher that
makes the barrier bite. This file closes that gap with a fully quantitative,
finite, and `sorry`-free development:

A property `P` that is **large** (accepts a `δ`-fraction of all truth tables)
and **useful** against a function family `g` (rejects every function the family
produces) is *exactly* a statistical test that separates the pseudorandom
ensemble `g` from the uniform ensemble with advantage `≥ δ`. If the family is a
secure pseudorandom function generator against the class of properties the proof
lives in, no such property can exist — this is the barrier.

## Main results

* `pseudoProb_eq_zero_of_useful` — usefulness collapses the pseudorandom
  acceptance probability to `0`.
* `natural_property_distinguishes` — **largeness + usefulness ⇒ advantage ≥ δ**.
  This is the quantitative heart of Razborov–Rudich.
* `natural_property_distinguishes_approx` — a *strengthening* allowing the
  property to leak on an `ε`-fraction of seeds: advantage `≥ δ − ε`.
* `useful_of_class_useful` — bridge: usefulness against a circuit *class*
  containing the family yields usefulness against the family.
* `natural_proofs_barrier` — a natural property in a class against which `g` is
  `δ`-secure **cannot** be useful: security is destroyed.
* `razborov_rudich` — the headline: a constructive, large property useful
  against a circuit class that contains a secure PRF breaks that PRF.
* `barrier_needs_largeness` — boundary case: drop largeness and the advantage
  can be `0`, so the barrier genuinely requires the largeness hypothesis.
-/

noncomputable section
open Classical Finset

namespace NaturalProofs

variable {F S : Type*} [Fintype F] [Fintype S]

/-! ## Section 1: Statistical-test semantics of a property

We identify the universe `F` with the set of all Boolean truth tables on `n`
inputs (so `Fintype.card F = 2 ^ 2 ^ n`), and `S` with the seed space of a
pseudorandom function family `g : S → F`. A property `P : F → Prop` is a
statistical test: it accepts a function when `P f` holds. -/

/-- Number of functions accepted by `P` (the "size" of the property). -/
def acceptCount (P : F → Prop) : ℕ := (univ.filter (fun f => P f)).card

/-- Acceptance probability of `P` under the **uniform** ensemble on `F`. -/
def randomProb (P : F → Prop) : ℚ := (acceptCount P : ℚ) / (Fintype.card F : ℚ)

/-- Number of seeds whose function `g s` is accepted by `P`. -/
def pseudoCount (P : F → Prop) (g : S → F) : ℕ :=
  (univ.filter (fun s => P (g s))).card

/-- Acceptance probability of `P` under the **pseudorandom** ensemble `g`. -/
def pseudoProb (P : F → Prop) (g : S → F) : ℚ :=
  (pseudoCount P g : ℚ) / (Fintype.card S : ℚ)

/-- Distinguishing advantage of the test `P` between the uniform ensemble and the
pseudorandom ensemble `g`. -/
def advantage (P : F → Prop) (g : S → F) : ℚ := |randomProb P - pseudoProb P g|

/-- `P` is **useful against** the family `g` if it rejects every function the
family can produce — the complexity-theoretic notion of usefulness (no
"easy" function satisfies `P`). -/
def UsefulAgainst (P : F → Prop) (g : S → F) : Prop := ∀ s, ¬ P (g s)

/-! ## Section 2: Basic probability facts -/

/-
The uniform acceptance probability is non-negative.
-/
theorem randomProb_nonneg (P : F → Prop) : 0 ≤ randomProb P := by
  exact div_nonneg ( Nat.cast_nonneg _ ) ( Nat.cast_nonneg _ )

/-
The pseudorandom acceptance probability is non-negative.
-/
omit [Fintype F] in
theorem pseudoProb_nonneg (P : F → Prop) (g : S → F) : 0 ≤ pseudoProb P g := by
  exact div_nonneg ( Nat.cast_nonneg _ ) ( Nat.cast_nonneg _ )

/-! ## Section 3: Usefulness kills the pseudorandom mass -/

/-
!-- Useful ⇒ no seed is accepted ⇒ the filtered set is empty ⇒ probability 0. -- !--

If `P` is useful against `g`, then `g` never lands in the accepting set, so
the pseudorandom acceptance probability is exactly `0`.
-/
omit [Fintype F] in
theorem pseudoProb_eq_zero_of_useful (P : F → Prop) (g : S → F)
    (h : UsefulAgainst P g) : pseudoProb P g = 0 := by
      unfold pseudoProb pseudoCount;
      rw [ Finset.card_eq_zero.mpr ] <;> aesop

/-! ## Section 4: The quantitative distinguisher (heart of Razborov–Rudich) -/

/-
!-- pseudoProb = 0 by usefulness, so advantage = |randomProb| = randomProb ≥ δ. -- !--

**Natural properties are distinguishers.** A property that accepts a
`δ`-fraction of all functions (largeness) yet rejects everything the family `g`
produces (usefulness) distinguishes the pseudorandom ensemble from uniform with
advantage at least `δ`. This is the quantitative core that the catalog skeleton
`natural_proof_distinguisher` only gestured at.
-/
theorem natural_property_distinguishes
    (P : F → Prop) (g : S → F) (δ : ℚ)
    (hlarge : δ ≤ randomProb P)
    (huseful : UsefulAgainst P g) :
    δ ≤ advantage P g := by
      refine' le_trans hlarge _;
      unfold advantage;
      rw [ pseudoProb_eq_zero_of_useful P g huseful, sub_zero, abs_of_nonneg ( randomProb_nonneg P ) ]

/-
!-- |randomProb − pseudoProb| ≥ randomProb − pseudoProb ≥ δ − ε. -- !--

**Strengthening (approximate usefulness).** Even if `P` is allowed to leak,
accepting the family's output on a set of seeds of probability at most `ε`, the
distinguishing advantage is still at least `δ − ε`. Setting `ε = 0` recovers
`natural_property_distinguishes`.
-/
theorem natural_property_distinguishes_approx
    (P : F → Prop) (g : S → F) (δ ε : ℚ)
    (hlarge : δ ≤ randomProb P)
    (hweak : pseudoProb P g ≤ ε) :
    δ - ε ≤ advantage P g := by
      unfold advantage;
      grind

/-! ## Section 5: From circuit-class usefulness to family usefulness -/

/-- `P` is useful against a **class** `C` of functions if no function with
property `P` lies in `C` (e.g. `C` = functions computable by small circuits). -/
def UsefulAgainstClass (P : F → Prop) (C : F → Prop) : Prop :=
  ∀ f, P f → ¬ C f

/-
!-- The family lands in C; P rejects everything in C; hence P rejects the family. -- !--

**Bridge.** If every seed of the family `g` produces a function inside the
circuit class `C`, and `P` is useful against `C`, then `P` is useful against the
family `g`. This is how "useful against P/poly" upgrades to "useful against a
PRF computable in P/poly".
-/
omit [Fintype F] [Fintype S] in
theorem useful_of_class_useful
    (P C : F → Prop) (g : S → F)
    (hCg : ∀ s, C (g s))
    (huse : UsefulAgainstClass P C) :
    UsefulAgainst P g := by
      exact fun s hs => huse _ hs ( hCg s )

/-! ## Section 6: The barrier -/

/-- The family `g` is **`δ`-secure** against a class `cls` of admissible tests
(the "constructive" properties that a natural proof is allowed to use) if no
test in `cls` distinguishes it from uniform with advantage `≥ δ`. -/
def SecureAgainst (g : S → F) (cls : Set (F → Prop)) (δ : ℚ) : Prop :=
  ∀ P ∈ cls, advantage P g < δ

/-- A property is **natural for** the admissible class `cls` at density `δ` if it
is constructive (lies in `cls`) and large (`δ`-dense). This packages the two
non-usefulness Razborov–Rudich axioms. -/
def Natural (P : F → Prop) (cls : Set (F → Prop)) (δ : ℚ) : Prop :=
  P ∈ cls ∧ δ ≤ randomProb P

/-
!-- Distinguisher (advantage ≥ δ) contradicts δ-security (advantage < δ). -- !--

**Natural proofs barrier.** If `g` is `δ`-secure against the admissib
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: The Razborov–Rudich Natural Proofs Barrier

The file `Computation/NaturalProofsBarrier.lean` turns the catalog's *skeleton*
of the natural-proofs barrier (`natural_proof_distinguisher`,
`IsLargeProperty`, `IsUsefulAgainst` in `Computation/BarrierFramework.lean`)
into a fully quantitative, `sorry`-free distinguisher: a property that is
**large** (`δ`-dense over all truth tables) and **useful** (rejects every
function a family produces) distinguishes the pseudorandom ensemble from uniform
with advantage `≥ δ` (`natural_property_distinguishes`), and therefore breaks any
family that is `δ`-secure against the constructive class the proof lives in
(`razborov_rudich`). The development sits naturally beside the *relativization*
and *algebrization* barriers already formalized in
`Computation/CircuitBarriers.lean` (`relativization_barrier`,
`algebrization_barrier`). The following directions extend it.

## 1. Constructivity as an explicit circuit-size budget on the test

Right now "constructive" is abstracted as membership in an opaque admissible
class `cls`. The next step is to instantiate `cls` concretely as the set of
properties `P` whose indicator is computed by a `BoolFormula` (from
`CircuitBarriers.lean`) of size `2^{O(n)}` in the `2^n`-bit truth table, and to
prove that `razborov_rudich` still fires for that concrete class. **The key
insight is** that constructivity is not a side condition but the precise hinge
that makes the distinguisher *efficient enough* to count as a cryptographic
adversary — so the barrier must be re-derived against an explicit size budget,
not an abstract set. **Why now?** `CircuitBarriers.lean` already provides
`BoolFormula`, `size`, and `formula_leaves_le_pow_depth`, giving the exact
size/depth bookkeeping needed to define the constructive class and bound the
test's own complexity, so the instantiation is within reach today.

## 2. Largeness from a counting/Shannon argument, not as a hypothesis

`barrier_needs_largeness` shows largeness is indispensable, but largeness is
currently assumed. The conjecture is that the *symmetric* properties used in real
lower bounds (e.g. "has high sensitivity", "is not approximated by low-degree
polynomials") are automatically `δ`-dense with `δ ≥ 2^{-O(n)}`, provable by the
Shannon counting bound `num_boolean_functions` already in
`CircuitBarriers.lean`. **The key insight is** that the same counting that gives
`2^{2^n}` total functions and Shannon's `2^n/(n+1)` lower bound also forces
natural combinatorial properties to be dense, so largeness is a *theorem* about
the property, not an axiom. **Why now?** `num_boolean_functions` and
`shannonLowerBound` are proved in the catalog; combining them with `acceptCount`
from the new file would let us discharge `δ ≤ randomProb P` for a concrete `P`.

## 3. A formal "if PRFs exist then no natural proof of P≠NP" corollary

Package `razborov_rudich` into a single statement quantifying over *all* natural
properties and *all* circuit cla
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
of objects (not placeholder strings). For each algorithm in the algorithms array, provide a name, a detailed explanation of its logic and complexity in 'description', formal step-by-step pseudocode in 'pseudocode', and clean type-hinted Python code in 'code'. Include future directions from Phase A in the future_directions field.

Be vivid, be precise, be world-class. The math has already been done — now
make it beautiful to read.
