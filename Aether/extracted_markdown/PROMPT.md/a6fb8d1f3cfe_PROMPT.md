
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
State theorems inline in your article and paper — they must be
self-contained and publishable without external references.


## Concept

**Title**: Bridge: Tropical Geometry as a Limit of Classical Algebraic Geometry
**Domain**: Novelty
**Mathematical framing**: Prove that the tropicalization of a variety V over a non-Archimedean field is the limit of V as the valuation goes to infinity. Bridge: the tropical fundamental theorem states that the tropicalization of V equals the corner locus of the tropical polynomial. Show that tropical intersection numbers equal classical intersection numbers (tropical Bezout).
Research domain: Novelty
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Bridges/AlgebraEMLMachineLearning/ClosureCapacityAttentionDuality.lean
import Mathlib

/-!
# Closure-Capacity–Attention Duality

This file establishes a finite duality between closure-capacity objects and
minimal sparse tropical attention architectures.

## Main Results

* `ClosureCapacityObj` — structure packaging a closure operator with a monotone,
  normalized capacity function on a finite type.
* `SparseAttentionModel` — structure for sparse attention realizations with
  finitely many heads, each with a support set and weight.
* `canonical_attention_model` — constructs the canonical attention model from
  a closure-capacity object, with one head per extreme generator.
* `extremeRank_le_headCount` — lower bound: any realization needs at least as
  many heads as extreme generators.
* `canonical_model_realizes` — the canonical model realizes the closure-capacity data.
* `canonical_model_is_minimal` — the canonical model achieves the minimum head count.
* `head_count_eq_extremeRank` — for minimal models, head count = extreme rank.
* `reconstructClosure` / `reconstructCapacity` — reconstruct closure operator
  and capacity from an attention model.
* `finite_closureCapacity_attention_duality` — the main duality packaging:
  existence of canonical minimal realization, lower bound, and reconstruction.

## Mathematical Overview

A **closure-capacity object** `(cl, κ)` on a finite type `X` consists of:
- A closure operator `cl` on `Finset X` (extensive, monotone, idempotent),
- A capacity function `κ : Finset X → ℕ` that is monotone on closed sets,
  normalized (`κ ∅ = 0`), and invariant under closure.

An **extreme generator** is a nonempty closed set `C` such that every proper
closed subset has strictly smaller capacity. The number of extreme generators
is the **extreme rank**.

A **sparse attention model** with `n` heads assigns each head a support set
(a closed set) and a weight (matching the capacity). The model **realizes**
the closure-capacity object if every extreme generator appears as some head's
support.

The **duality theorem** states:
1. Every closure-capacity object admits a canonical minimal realization with
   head count equal to the extreme rank.
2. Any realization requires at least as many heads as extreme generators.
3. From any realization, one can reconstruct the closure-capacity data.
-/

open Finset Function

noncomputable section

namespace ClosureCapacityAttention

variable {X : Type*} [Fintype X] [DecidableEq X]

/-! ## Section 1: Finite Closure Operators -/

/-- A closure operator on `Finset X`: extensive, monotone, idempotent. -/
structure FiniteClosure (X : Type*) [Fintype X] [DecidableEq X] where
  cl : Finset X → Finset X
  cl_extensive : ∀ A, A ⊆ cl A
  cl_mono : ∀ ⦃A B⦄, A ⊆ B → cl A ⊆ cl B
  cl_idem : ∀ A, cl (cl A) = cl A

namespace FiniteClosure

/-- A set is closed if it equals its own closure. -/
def IsClosed (C : FiniteClosure X) (A : Finset X) : Prop :=
  C.cl A = A

instance (C : FiniteClosure X) : DecidablePred C.IsClosed :=
  fun A => decEq (C.cl A) A

/-- The closure of any set is closed. -/
theorem cl_closed (C : FiniteClosure X) (A : Finset X) : C.IsClosed (C.cl A) :=
  C.cl_idem A

/-- The full set of all closed subsets of `X`. -/
def closedSets (C : FiniteClosure X) : Finset (Finset X) :=
  Fintype.elems.filter C.IsClosed

theorem mem_closedSets_iff (C : FiniteClosure X) (A : Finset X) :
    A ∈ C.closedSets ↔ C.IsClosed A := by
  simp [closedSets, Fintype.complete]

end FiniteClosure

/-! ## Section 2: Closure-Capacity Objects -/

/-- A closure-capacity object: a closure operator on a finite type equipped with
    a monotone, normalized capacity function. -/
structure ClosureCapacityObj (X : Type*) [Fintype X] [DecidableEq X]
    extends FiniteClosure X where
  κ : Finset X → ℕ
  κ_mono : ∀ ⦃A B⦄, toFiniteClosure.IsClosed A → toFiniteClosure.IsClosed B →
    A ⊆ B → κ A ≤ κ B
  κ_bot : κ ∅ = 0
  κ_cl_invariant : ∀ A, κ A = κ (cl A)
  empty_closed : toFiniteClosure.IsClosed ∅

namespace ClosureCapacityObj

variable (O : ClosureCapacityObj X)

abbrev IsClosed (A : Finset X) : Prop := O.toFiniteClosure.IsClosed A
abbrev closedSets : Finset (Finset X) := O.toFiniteClosure.closedSets

theorem empty_in_closedSets : ∅ ∈ O.closedSets := by
  rw [FiniteClosure.mem_closedSets_iff]
  exact O.empty_closed

theorem cl_mem_closedSets (A : Finset X) : O.cl A ∈ O.closedSets := by
  rw [FiniteClosure.mem_closedSets_iff]
  exact O.toFiniteClosure.cl_closed A

/-- A nonempty closed set is an **extreme generator** if every proper closed subset
    has strictly smaller capacity. These are the irreducible building blocks. -/
def IsExtreme (C : Finset X) : Prop :=
  O.IsClosed C ∧ C ≠ ∅ ∧ ∀ D, O.IsClosed D → D ⊂ C → O.κ D < O.κ C

instance : DecidablePred O.IsExtreme := fun C => by
  unfold IsExtreme; infer_instance

/-- The finset of all extreme generators. -/
def extremeSets : Finset (Finset X) :=
  O.closedSets.filter (fun C => decide (O.IsExtreme C))

theorem mem_extremeSets_iff (C : Finset X) :
    C ∈ O.extremeSets ↔ O.IsExtreme C := by
  simp only [extremeSets, Finset.mem_filter, FiniteClosure.mem_closedSets_iff]
  constructor
  · intro ⟨_, h⟩; exact of_decide_eq_true (by simpa using h)
  · intro h; exact ⟨h.1, by simpa using decide_eq_true h⟩

/-- The extreme rank: number of extreme generators. -/
def extremeRank : ℕ := O.extremeSets.card

end ClosureCapacityObj

/-! ## Section 3: Sparse Attention Models -/

/-- A sparse attention model on `X` with `numHeads` attention heads.
    Each head has a support set (subset of `X`) and a weight (natural number). -/
structure SparseAttentionModel (X : Type*) [Fintype X] [DecidableEq X] where
  numHeads : ℕ
  support : Fin numHeads → Finset X
  weight : Fin numHeads → ℕ

namespace SparseAttentionModel

/-- A sparse attention model **realizes** a closure-capacity object if:
    1. Each head's support is a closed set,
    2. Every extreme generator appears as some head's support,
    3. Weights match capacity on supports. -/
def RealizesClosureCapacity (M : SparseAttentionModel X) (O : ClosureCapacityObj X) : Prop :=
  (∀ h, O.IsClosed (M.support h)) ∧
  (∀ C, O.IsExtreme C → ∃ h, M.support h = C) ∧
  (∀ h, M.weight h = O.κ (M.support h))

/-- A model is **minimal** for `O` if it realizes `O` and no realization uses fewer heads. -/
def IsMinimal (M : SparseAttentionModel X) (O : ClosureCapacityObj X) : Prop :=
  M.RealizesClosureCapacity O ∧
  ∀ M' : SparseAttentionModel X, M'.RealizesClosureCapacity O → M.numHeads ≤ M'.numHeads

/-- A model is **closure-consistent** if it realizes some closure-capacity object. -/
def IsClosureConsistent (M : SparseAttentionModel X) : Prop :=
  ∃ O : ClosureCapacityObj X, M.RealizesClosureCapacity O

end SparseAttentionModel

/-! ## Section 4: Canonical Construction -/

/-- Given an ordering of extreme sets, build the canonical sparse attention model
    with one head per extreme generator. -/
def canonical_attention_model (O : ClosureCapacityObj X)
    (enum : Fin O.extremeRank ≃ O.extremeSets) : SparseAttentionModel X where
  numHeads := O.extremeRank
  support := fun h => (enum h).val
  weight := fun h => O.κ (enum h).val

/-! ## Section 5: Lower Bound -/

/-- **Key lemma**: If a model realizes `O`, any map from extreme sets to matching
    heads is injective. -/
theorem extreme_to_head_injective
    (O : ClosureCapacityObj X)
    (M : SparseAttentionModel X)
    (_hreal : M.RealizesClosureCapacity O)
    (f : ∀ C, O.IsExtreme C → Fin M.numHeads)
    (hf : ∀ C (hC : O.IsExtreme C), M.support (f C hC) = C) :
    ∀ C₁ C₂ (h₁ : O.IsExtreme C₁) (h₂ : O.IsExtreme C₂),
      f C₁ h₁ = f C₂ h₂ → C₁ = C₂ := by
  intro C₁ C₂ h₁ h₂ heq
  have h1 := hf C₁ h₁
  have h2 := hf C₂ h₂
  rw [heq] at h1
  exact h1.symm.trans h2

/-
**Lower bound theorem**: Any realization of a closure-capacity object requires
    at least as many heads as extreme generators.
-/
theorem extremeRank_le_headCount
    (O : ClosureCapacityObj X)
    (M : SparseAtten
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: Tropical Bézout and the Valuation-Limit Bridge

This cycle extended `Bridges.AlgebraTropicalGeometry.TropicalValuationLimitBridge`
(home of `kapranov_easy_direction` and the min-plus multiplicativity engine
`TropPoly.eval_mul`) into the file `TropicalBezoutFactorization.lean`, which now
contains four cross-domain results connecting non-Archimedean valuations,
corner loci, and tropical intersection theory:

- `attainedTwice_smul` — the corner locus is invariant under positive rescaling
  of the weights, the precise "valuation → ∞" limit statement;
- `tropRoot_mul_iff` / `tropRootSet_mul` — the tropical hypersurface of a product
  is the union of the factors' hypersurfaces, `V(P ⊙ Q) = V(P) ∪ V(Q)`;
- `range_exp_mul` — Newton polytopes add as a Minkowski sum under tropical product.

Together with `eval_mul` (degrees add) these are exactly the two combinatorial
ingredients of tropical Bézout. The directions below push toward the full
intersection-number theorem and a tighter dictionary with classical geometry.

---

## Direction 1: From union-of-hypersurfaces to a counted intersection number

The factorization `V(P ⊙ Q) = V(P) ∪ V(Q)` is the *set-theoretic* skeleton of
tropical Bézout. The quantitative theorem counts stable intersection points of two
tropical curves of degrees `d` and `e` with multiplicity, and asserts the total is
exactly `d · e`. The natural next object is a `TropMultiplicity` assigning to each
transverse corner the lattice index `|det|` of the two edge directions, and a theorem
`∑ multiplicities = d * e` for generic translates.

**The key insight is** that `range_exp_mul` already proves the Newton polytopes
Minkowski-add, and the mixed volume of the summands is the Bézout number — so the
intersection count is a *volume* computation on the polytopes we have already
formalized, not a new geometric input. **Why now?** With `eval_mul`,
`range_exp_mul`, and `tropRoot_mul_iff` in place, the only missing piece is the
local multiplicity bookkeeping; Mathlib's `Finset`/lattice-determinant API makes the
`|det|` weights and a genericity (transversality) hypothesis directly expressible.

This is falsifiable: state it for two explicit tropical lines (`d = e = 1`) and check
the unique stable intersection has multiplicity `1`; a wrong multiplicity definition
will fail this base case immediately.

## Direction 2: The hard (converse) direction of the Fundamental Theorem

`kapranov_easy_direction` shows tropicalization lands in the corner locus. The
converse — every corner-locus point lifts to an actual point of the variety over the
valued field (the Kapranov/Speyer–Sturmfels theorem) — is the deep half and is not
yet formalized. A tractable first case is a single hypersurface defined by a binomial
or trinomial, where the lift is an explicit Newton–Puiseux / Hensel construction.

**The key insight is** that for the lift one only needs surjectivity of the value
group plus one application of Hensel's lemma per corner, both of wh
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
of objects (not placeholder strings). Include future directions from Phase A
in the future_directions field.

Be vivid, be precise, be world-class. The math has already been done — now
make it beautiful to read.
