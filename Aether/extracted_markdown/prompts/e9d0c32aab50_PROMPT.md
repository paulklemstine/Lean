
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

**Title**: Close Proofs: The file `Geometry/FractalDimension.lean` builds the **set-local** the
**Domain**: Applications
**Mathematical framing**: Cycle cd56fc3f (Q=0.466) proved 1150 theorems in Bridges but left 2 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: # Future Directions: Set-Local Distortion of Hausdorff Dimension

The file `Geometry/FractalDimension.lean` builds the **set-local** theory of Hausdorff
dimension distortion: the `AntilipschitzOnWith`
Research domain: Applications
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Geometry/FractalDimension.lean
/-
Copyright (c) 2025. All rights reserved.
Set-Local Distortion of Hausdorff Dimension

This module develops the **set-local** theory of how the Hausdorff dimension of a
set is distorted under maps that are only assumed to be (anti)Lipschitz *on the set
itself*, rather than globally.

Mathlib already provides the global theory:
* `LipschitzOnWith.dimH_image_le` — Lipschitz-on-a-set maps do not increase dimension;
* `AntilipschitzWith.le_dimH_image` — *globally* antilipschitz maps do not decrease
  dimension.

What is missing is the genuinely set-local antilipschitz lower bound.  Mathlib has no
`AntilipschitzOnWith` predicate at all.  We introduce it and prove that a map which is
antilipschitz *only on `s`* still satisfies `dimH s ≤ dimH (f '' s)`.  Combined with the
Lipschitz-on upper bound this yields a clean set-local *bilipschitz invariance* of
Hausdorff dimension, and a set-local isometry invariance, neither of which follows from
the global Mathlib lemmas (which would require `f` to be antilipschitz on the *whole*
space).

Key results:
1. `AntilipschitzOnWith` — the set-local antilipschitz predicate.
2. `AntilipschitzOnWith.le_dimH_image` — the set-local dimension lower bound
   `dimH s ≤ dimH (f '' s)` (the headline theorem).
3. `dimH_image_eq_of_bilipschitzOn` — bilipschitz-on-a-set maps preserve dimension.
4. `dimH_image_eq_of_isometryOn` — isometry-on-a-set maps preserve dimension.
-/
import Mathlib

open MeasureTheory Set

noncomputable section

variable {X Y : Type*} [EMetricSpace X] [EMetricSpace Y]
variable {K K' : NNReal} {f : X → Y} {s t : Set X}

/-! ## The set-local antilipschitz predicate -/

-- !-- Lab Notebook -- !--
-- Hypothesis: The global `AntilipschitzWith.le_dimH_image` should have a set-local
--   analogue.  A map antilipschitz only on `s` cannot collapse `s`, so it must not
--   decrease the Hausdorff dimension of `s`.
-- Result: Confirmed.  The right vehicle is to restrict `f` to the subtype `s`, where
--   set-local antilipschitzness becomes *global* antilipschitzness, then transport via
--   the isometric inclusion `Subtype.val`.
-- Insight: `edist` on a subtype is *definitionally* the ambient `edist`, so the
--   restriction lemma is essentially free; all the work is bookkeeping of `'' univ`.
-- Failure analysis: A direct Hausdorff-measure argument (mirroring
--   `AntilipschitzWith.dimH_preimage_le`) is possible but would need a set-local
--   `hausdorffMeasure_preimage_le`, which Mathlib lacks; the subtype route avoids it.

/-- `AntilipschitzOnWith K f s` says that `f` is `K`-antilipschitz when restricted to the
set `s`: for all `x, y ∈ s`, `edist x y ≤ K * edist (f x) (f y)`.  This is the set-local
companion of `AntilipschitzWith`. -/
def AntilipschitzOnWith (K : NNReal) (f : X → Y) (s : Set X) : Prop :=
  ∀ ⦃x : X⦄, x ∈ s → ∀ ⦃y : X⦄, y ∈ s → edist x y ≤ K * edist (f x) (f y)

-- !-- A globally antilipschitz map is antilipschitz on every set (trivial specialisation). -- !--
/-- A globally antilipschitz map is antilipschitz on every set. -/
theorem AntilipschitzWith.antilipschitzOnWith (h : AntilipschitzWith K f) (s : Set X) :
    AntilipschitzOnWith K f s :=
  fun x _ y _ => h x y

-- !-- Restricting to a smaller set preserves the antilipschitz-on property. -- !--
/-- Restricting to a smaller set preserves the antilipschitz-on property. -/
theorem AntilipschitzOnWith.mono (h : AntilipschitzOnWith K f s) (hts : t ⊆ s) :
    AntilipschitzOnWith K f t :=
  fun _ hx _ hy => h (hts hx) (hts hy)

-- !-- `edist (f x) (f y) = 0` forces `edist x y = 0`, hence `x = y` in an `EMetricSpace`. -- !--
/-- An antilipschitz-on map is injective on the set. -/
theorem AntilipschitzOnWith.injOn (h : AntilipschitzOnWith K f s) : Set.InjOn f s := by
  intro x hx y hy hxy
  exact edist_le_zero.mp (le_trans (h hx hy) (by simp [hxy]))

/-! ## Reduction to a global antilipschitz map on the subtype -/

-- !-- The pulled-back map `x : s ↦ f x` is *globally* antilipschitz on the subtype `s`,
--     because subtype `edist` is definitionally the ambient `edist`. -- !--
/-- The pulled-back map `x : s ↦ f x` is globally antilipschitz on the subtype `s`. -/
theorem AntilipschitzOnWith.subtype_antilipschitzWith (h : AntilipschitzOnWith K f s) :
    AntilipschitzWith K (fun x : s => f x.val) := by
  intro x y; specialize h x.2 y.2; aesop

/-! ## The headline theorem: set-local dimension lower bound -/

-- !-- Lab Notebook -- !--
-- Hypothesis: `AntilipschitzOnWith K f s → dimH s ≤ dimH (f '' s)`.
-- Result: Proved via the subtype reduction
--   `dimH s = dimH (univ : Set s) ≤ dimH ((f ∘ val) '' univ) = dimH (f '' s)`, using
--   `AntilipschitzWith.le_dimH_image`, `isometry_subtype_coe`, `Subtype.coe_image_univ`.
-- Insight: This is strictly stronger than the global Mathlib lemma — `f` may wildly
--   contract or even be non-injective *off* `s` and the bound still holds.

-- !-- Apply the subtype antilipschitz lemma + `AntilipschitzWith.le_dimH_image`, then
--     transport `dimH (univ : Set s) = dimH s` along the isometric inclusion. -- !--
/-- **Set-local antilipschitz dimension lower bound.**  If `f` is antilipschitz on `s`,
then it cannot decrease the Hausdorff dimension of `s`: `dimH s ≤ dimH (f '' s)`.  This
strengthens `AntilipschitzWith.le_dimH_image`, which requires `f` to be antilipschitz on
the whole space. -/
theorem AntilipschitzOnWith.le_dimH_image (h : AntilipschitzOnWith K f s) :
    dimH s ≤ dimH (f '' s) := by
  convert AntilipschitzWith.le_dimH_image h.subtype_antilipschitzWith Set.univ using 1
  have h_iso : Isometry (Subtype.val : s → X) := isometry_subtype_coe
  rw [← h_iso.dimH_image]
  · aesop
  · congr! 1; aesop

/-! ## Bilipschitz and isometry invariance, set-locally -/

-- !-- Lab Notebook -- !--
-- Hypothesis: A map that is both Lipschitz-on and antilipschitz-on `s` preserves the
--   Hausdorff dimension of `s` exactly.
-- Result: Immediate from `LipschitzOnWith.dimH_image_le` (≤) and
--   `AntilipschitzOnWith.le_dimH_image` (≥) by antisymmetry.
-- Insight: Hausdorff dimension is a *bilipschitz-on invariant*, not merely a global
--   bilipschitz invariant.  This is the conceptual payload of the file.

-- !-- Antisymmetry of the Lipschitz-on upper bound and the antilipschitz-on lower bound. -- !--
/-- **Set-local bilipschitz invariance of Hausdorff dimension.**  If `f` is Lipschitz on
`s` (constant `K`) and antilipschitz on `s` (constant `K'`), then `f` preserves the
Hausdorff dimension of `s`. -/
theorem dimH_image_eq_of_bilipschitzOn (hL : LipschitzOnWith K f s)
    (hA : AntilipschitzOnWith K' f s) : dimH (f '' s) = dimH s :=
  le_antisymm hL.dimH_image_le hA.le_dimH_image

-- !-- An isometry-on map satisfies both `LipschitzOnWith 1` and `AntilipschitzOnWith 1`. -- !--
/-- A map that is an isometry on `s` (it preserves `edist` between points of `s`) is both
Lipschitz-on and antilipschitz-on `s` with constant `1`. -/
theorem isometryOn_bilipschitz
    (h : ∀ ⦃x⦄, x ∈ s → ∀ ⦃y⦄, y ∈ s → edist (f x) (f y) = edist x y) :
    LipschitzOnWith 1 f s ∧ AntilipschitzOnWith 1 f s := by
  simp_all +decide [LipschitzOnWith, AntilipschitzOnWith]

-- !-- Combine `isometryOn_bilipschitz` with `dimH_image_eq_of_bilipschitzOn`. -- !--
/-- **Set-local isometry invariance of Hausdorff dimension.**  If `f` preserves `edist`
between points of `s`, then it preserves the Hausdorff dimension of `s`.  This is the
set-local form of `Isometry.dimH_image`. -/
theorem dimH_image_eq_of_isometryOn
    (h : ∀ ⦃x⦄, x ∈ s → ∀ ⦃y⦄, y ∈ s → edist (f x) (f y) = edist x y) :
    dimH (f '' s) = dimH s :=
  dimH_image_eq_of_bilipschitzOn (isometryOn_bilipschitz h).left (isometryOn_bilipschitz h).right

end



-- NEW_FILE: Catalog/MachineLearning/ErdosStraus/Families.lean
/-
# Erdős–Straus: Parametric Families

This module proves that infinite families of integers satisfy the
Erdős–Straus conjecture via explicit symbolic constructions.

## Main results

* `erdos_straus_even` — Every even n ≥ 2 has a decompos
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: Set-Local Distortion of Hausdorff Dimension

## Synthesis

The file `Catalog/Geometry/FractalDimension.lean` closes a genuine gap in the Mathlib
theory of Hausdorff dimension. Mathlib provides `LipschitzOnWith.dimH_image_le` (a
*set-local* upper bound) but only `AntilipschitzWith.le_dimH_image` (a *global* lower
bound). There was no `AntilipschitzOnWith` predicate at all, so there was no way to state
— let alone prove — that a map which is antilipschitz **only on a set `s`** cannot
collapse the dimension of `s`. We introduced `AntilipschitzOnWith` and proved the missing
lower bound `dimH s ≤ dimH (f '' s)`, then combined it with the existing upper bound to
obtain set-local *bilipschitz* and *isometry* invariance of Hausdorff dimension.

The decisive technical move is a **subtype reduction**: on the subtype `s`, the ambient
`edist` is definitionally the induced one, so "antilipschitz on `s`" becomes "globally
antilipschitz on the metric space `s`". One then transports the conclusion back along the
isometric inclusion `Subtype.val`. This pattern is reusable for *every* set-local
distortion statement, which is what makes the directions below tractable today.

## Results Summary (all proved, `sorry`-free, only standard axioms)

- `AntilipschitzOnWith` — the new set-local antilipschitz predicate, the companion of
  Mathlib's `AntilipschitzWith` and `LipschitzOnWith`.
- `AntilipschitzOnWith.le_dimH_image` — **headline**: `dimH s ≤ dimH (f '' s)` whenever
  `f` is antilipschitz on `s`. Strictly stronger than `AntilipschitzWith.le_dimH_image`.
- `dimH_image_eq_of_bilipschitzOn` — bilipschitz-on-a-set maps preserve Hausdorff
  dimension exactly.
- `dimH_image_eq_of_isometryOn` — isometry-on-a-set maps preserve Hausdorff dimension
  (set-local form of `Isometry.dimH_image`).
- Supporting API: `AntilipschitzWith.antilipschitzOnWith`, `AntilipschitzOnWith.mono`,
  `AntilipschitzOnWith.injOn`, `AntilipschitzOnWith.subtype_antilipschitzWith`,
  `isometryOn_bilipschitz`.

---

## Direction 1 — Set-local Hölder lower bound (`AntiholderOnWith`)

Mathlib's `HolderOnWith.dimH_image_le` gives `dimH (f '' s) ≤ dimH s / r` for a
Hölder-on map with exponent `r`. The matching lower bound should read: if `f` satisfies a
*reverse* Hölder estimate on `s`, namely `edist x y ≤ C * edist (f x) (f y) ^ r` for all
`x, y ∈ s`, then `dimH s ≤ dimH (f '' s) / r`, equivalently `r · dimH s ≤ dimH (f '' s)`.
The key insight is that the same subtype reduction used for `AntilipschitzOnWith` applies
verbatim once `AntiholderOnWith` is defined, reducing the set-local statement to a global
reverse-Hölder dimension bound that can be obtained from
`HolderWith.hausdorffMeasure_image_le` run "in reverse". **Why now?** We already have the
isometric-inclusion transport lemma `isometry_subtype_coe` wired up and verified in this
cycle; the only new ingredient is the reverse-Hölder measure estimate, making this the
lowest-hanging generalization.

## Direction 2 — Exact dimensi
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
