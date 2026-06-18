
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

**Title**: Functor from finite linear codes to tropical valuation objects via weight-threshold profiles
**Domain**: Bridges
**Mathematical framing**: 
Research domain: Bridges
Research mode: formalize


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Bridges/CodeThresholdValuation.lean
/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# A functor from finite linear codes to tropical valuation objects via weight-threshold profiles

This file builds the **bridge** announced by its title: a functor sending finite binary
linear codes (and threshold-compatible code maps) to the *tropical valuation objects* of
`Catalog.Bridges.CategoricalTropicalUltrametric`.

The connecting invariant is the **threshold profile valuation** `tprof`.  For a binary
vector `x : Fin n → ZMod 2`, `tprof x` is the smallest prefix length `t` such that `x` is
supported entirely in coordinates `< t` — equivalently `lead(x) + 1`, where `lead(x)` is
the top active coordinate.  This is the classical *degree / leading-position
nonarchimedean valuation*, here read off the **weight-threshold profile** of the codeword:
scanning coordinates `0,1,2,…`, `tprof x` is the threshold beyond which `x` is silent.

Unlike the Hamming weight `wt` (which is *not* ultrametric — `wt (x+y)` can exceed both
`wt x` and `wt y`), the threshold profile satisfies the **strong (ultrametric) triangle
inequality** and even the sharp **isosceles law**, so it descends to the catalog's
`UltraNormObj`/`TropObj` world.

## Main results (all `sorry`-free)

* `tprof_eq_zero_iff` — the valuation *separates* `0` (`tprof x = 0 ↔ x = 0`).
* `tprof_add_le` — **strong triangle inequality** `tprof (x+y) ≤ max (tprof x) (tprof y)`.
* `tprof_add_eq_of_ne` — **isosceles law**: unequal profiles force
  `tprof (x+y) = max (tprof x) (tprof y)` (the nonarchimedean "all triangles isosceles").
* `wt_le_tprof` / `tprof_le_card` — the profile *dominates* the Hamming weight and is
  bounded by the length: `wt x ≤ tprof x ≤ n`.
* `CodeVal` / `CodeValHom` — the category of *threshold-valued codes* (ultrametric objects
  without the multiplicative-norm axiom that codes cannot satisfy), with full category
  laws.
* `thresholdSpace` — the ambient length-`n` code as a `CodeVal`, and `padHom` — the
  prefix-inclusion `length m ↪ length n` as a profile-*preserving* `CodeValHom`, giving a
  concrete functorial family.
* `CodeVal.toTrop` / `CodeVal.toTropMap` — **the functor to tropical valuation objects**:
  every threshold-valued code maps to a genuine `CategoricalTropicalUltrametric.TropObj`
  (the value semiring `(ℕ, max, +)`), functorially (`toTropMap_id`, `toTropMap_comp`),
  exactly mirroring the catalog's `tropicalization`.

-- !-- Lab Notes -- !--
Hypothesis: the Hamming weight `wt` used throughout `SmoothPoincare.Codes` is the *wrong*
  invariant for a tropical/ultrametric functor (it fails the strong triangle inequality);
  but the *weight-threshold profile* `tprof` (leading active coordinate `+1`) is a genuine
  nonarchimedean valuation and therefore *does* factor through the catalog's tropical
  valuation objects, giving an honest functor `FinLinCodes → TropObj`.
Result: confirmed.  `tprof` satisfies separation, the strong triangle inequality, the
  sharp isosceles law, dominates `wt`, and is `≤ n`.  `CodeVal` is a category and
  `CodeVal.toTrop` is a functor into the catalog's `TropObj`, all `sorry`-free.
Insight: the move from `wt` (additive, archimedean) to `tprof` (max-stable,
  nonarchimedean) is precisely the move from the metric to the *tropical* world — the
  support union bound `support (x+y) ⊆ support x ∪ support y` plus `Finset.sup_union` is
  the entire content of the ultrametric inequality, and char-2 cancellation at the top
  coordinate upgrades it to the isosceles equality.
Failure analysis: the catalog's `UltraNormObj` demands a *multiplicative* norm
  (`norm (x*y) = norm x * norm y`), which no nontrivial code valuation satisfies (most
  valuations are additive: `v(xy) = v x + v y`).  We therefore land in a bespoke `CodeVal`
  (= `UltraNormObj` minus the multiplicative axiom) and bridge to the catalog via the
  *value semiring* `(ℕ, max, +) = tropicalization_base`, exactly as the catalog's own
  `tropicalization` functor is constant on objects.
-/

import Mathlib
import Catalog.Bridges.CategoricalTropicalUltrametric
import Catalog.Applications.SmoothPoincare.MinimumDistance

open scoped BigOperators

namespace CodeThresholdValuation

variable {n m : ℕ}

/-! ## §1. The weight-threshold profile valuation -/

/-- The **support** of a binary vector: the coordinates where it is nonzero. -/
def support (x : Fin n → ZMod 2) : Finset (Fin n) :=
  Finset.univ.filter (fun i => x i ≠ 0)

/-- The **weight-threshold profile** valuation: the smallest prefix length `t` such that
    `x` is supported in coordinates `< t`.  Equals `lead(x) + 1` where `lead(x)` is the
    top active coordinate; `tprof 0 = 0`. -/
def tprof (x : Fin n → ZMod 2) : ℕ := (support x).sup (fun i => (i : ℕ) + 1)

@[simp] theorem mem_support {x : Fin n → ZMod 2} {i : Fin n} :
    i ∈ support x ↔ x i ≠ 0 := by
  simp [support]

theorem support_zero : support (0 : Fin n → ZMod 2) = ∅ := by
  ext i; simp

/-- A coordinate of `x + y` is active only if it was active in `x` or in `y`. -/
theorem support_add_subset (x y : Fin n → ZMod 2) :
    support (x + y) ⊆ support x ∪ support y := by
  intro i hi
  simp only [mem_support, Pi.add_apply] at hi
  simp only [Finset.mem_union, mem_support]
  by_contra h
  push_neg at h
  obtain ⟨hx, hy⟩ := h
  simp [hx, hy] at hi

/-
The profile vanishes exactly on the zero vector (separation).
-/
theorem tprof_eq_zero_iff {x : Fin n → ZMod 2} : tprof x = 0 ↔ x = 0 := by
  unfold tprof;
  by_cases hx : x = 0 <;> simp +decide [ hx, support ];
  exact Function.ne_iff.mp hx

@[simp] theorem tprof_zero : tprof (0 : Fin n → ZMod 2) = 0 := by
  simp [tprof, support_zero]

/-
In characteristic two negation is the identity, so the profile is `neg`-invariant.
-/
theorem tprof_neg (x : Fin n → ZMod 2) : tprof (-x) = tprof x := by
  -- By definition of `support`, we have `support (-x) = {i | (-x) i ≠ 0}`.
  simp [tprof, support]

/-
**Strong (ultrametric) triangle inequality** for the threshold profile.
-/
theorem tprof_add_le (x y : Fin n → ZMod 2) :
    tprof (x + y) ≤ max (tprof x) (tprof y) := by
  unfold tprof
  refine le_trans (Finset.sup_mono (support_add_subset x y)) ?_
  rw [Finset.sup_union]

/-- If a coordinate `i` realizes the profile of `x` (i.e. `i ∈ support x` with
    `(i:ℕ)+1 = tprof x`), it is the top active coordinate. -/
theorem le_tprof_of_mem {x : Fin n → ZMod 2} {i : Fin n} (hi : i ∈ support x) :
    (i : ℕ) + 1 ≤ tprof x :=
  Finset.le_sup (f := fun i => (i : ℕ) + 1) (s := support x) hi

/-
The top active coordinate is itself active: for `x ≠ 0` there is a coordinate `i`
    with `x i ≠ 0` and `(i:ℕ)+1 = tprof x`.
-/
theorem exists_top_coord {x : Fin n → ZMod 2} (hx : x ≠ 0) :
    ∃ i, x i ≠ 0 ∧ (i : ℕ) + 1 = tprof x := by
  obtain ⟨i, hi⟩ : ∃ i ∈ support x, (i : ℕ) + 1 = tprof x := by
    obtain ⟨i, hi⟩ : ∃ i ∈ Finset.univ.filter (fun i => x i ≠ 0), ∀ j ∈ Finset.univ.filter (fun i => x i ≠ 0), (i : ℕ) + 1 ≥ (j : ℕ) + 1 := by
      exact Finset.exists_max_image _ _ ⟨ Classical.choose ( Function.ne_iff.mp hx ), by simpa using Classical.choose_spec ( Function.ne_iff.mp hx ) ⟩;
    exact ⟨ i, hi.1, le_antisymm ( Finset.le_sup ( f := fun i : Fin n => ( i : ℕ ) + 1 ) hi.1 ) ( Finset.sup_le fun j hj => hi.2 j hj ) ⟩
  generalize_proofs at *;
  use i;
  aesop;

/-
**Isosceles law** (nonarchimedean sharpness): when the two profiles differ, the
    profile of the sum equals the larger of the two.
-/
theorem tprof_add_eq_of_ne (x y : Fin n → ZMod 2) (h : tprof x ≠ tprof y) :
    tprof (x + y) = max (tprof x) (tprof y) := by
  -- Assume without loss of generality that $tprof x < tprof y$.
  wlog hxy : tprof x < tprof y generalizing x y;
  · convert this y x ( Ne.symm h ) ( lt_of_le_of_ne ( le_of_not_gt hxy ) ( Ne.symm h ) ) using 1 ; rw [ add_comm ];
    exact max_comm _ _;
  · -- Since $tprof y > tprof x \geq 0$, $tprof y \neq 0$ (tprof_eq_zero_iff). Apply exists_top_coord to $y$: get $i$ with $y i \neq 0$ and $(i:ℕ)+1
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — Weight-Threshold Profiles & the Codes → Tropical Valuation Functor

These conjectures extend `Catalog/Bridges/CodeThresholdValuation.lean`, which builds the
functor `FinLinCodes ⥤ TropObj` via the threshold-profile valuation `tprof`, proves it is
a genuine nonarchimedean valuation (strong triangle + isosceles laws), induces an
ultrametric distance `tdist`, and assembles the prefix-inclusion family into a functor
`(ℕ, ≤) ⥤ CodeVal`. They are stated to be falsifiable and Lean-formalizable.

## Conjecture 1 — Tropical weight enumerator factors through `tprof`
The (Hamming) weight enumerator `W_C(x) = Σ_{c∈C} x^{wt c}` proved for `[8,4,4]` in
`MinimumDistance.lean` (`1 + 14x⁴ + x⁸`) has a **tropical companion** `T_C(t) = max_{c∈C,
tprof c ≤ t} wt c`, the *threshold-truncated max-weight profile*. Conjecture: `T_C` is a
piecewise-constant, monotone, **concave** tropical polynomial whose breakpoints are exactly
the distinct values of `tprof` attained on `C`, and for any self-dual code the number of
breakpoints equals `1 + (minimum distance)/4`. Testable first on `hamming` (predicted
breakpoints at `t = 7, 8`).

## Conjecture 2 — `tprof` characterises the standard-form generator order
A binary `[n,k]` code admits a generator matrix in row-echelon (standard) form iff the
multiset `{ tprof c : c ∈ C, c ≠ 0 }` contains exactly `2^k − 1` values whose distinct
representatives are `k` *consecutive-pivot* thresholds. Conjecture: `tprof`'s value set on
`C` recovers the pivot columns of the reduced row-echelon form, so the functor
`CodeVal.toTrop` is **faithful on standard-form codes** (distinct codes ⇒ distinct
threshold value-multisets). Falsifiable by exhibiting two inequivalent codes with identical
`tprof` multisets.

## Conjecture 3 — Ultrametric MacWilliams duality
For the induced ultrametric `tdist`, define the dual code `C⊥` and the *threshold ball
counting function* `N_C(r) = #{c ∈ C : tprof c ≤ r}`. Conjecture: a **MacWilliams-type
identity** relates `N_C` and `N_{C⊥}` linearly, `N_C(r) · N_{C⊥}(n−r) = |C| · 2^{?}` for a
predictable exponent, mirroring the classical weight-enumerator duality. This would make
`tprof` (not just `wt`) a self-dual invariant. Test on `hamming` (self-dual, so
`C = C⊥`): predicts `N_C(r)·N_C(8−r)` is constant in `r`.

## Conjecture 4 — Functoriality under the direct sum `C ⊕ D`
`CodeDirectSum.lean` shows `wt` is additive and self-duality is closed under coordinate
concatenation `⊕`. Conjecture: under the threshold functor,
`tprof_{C⊕D}(append a b) = max (tprof_C a) (offset + tprof_D b)` where `offset = m` (the
left block length), i.e. **`tprof` of a direct sum is the *shifted max* of the blocks** —
the tropical (max-plus) shadow of the block-diagonal Gram matrix. Hence
`CodeVal.toTrop (C ⊕ D)` is the tropical product of `CodeVal.toTrop C` and a shifted
`CodeVal.toTrop D`, upgrading the functor to a **lax monoidal** functor
`(FinLinCodes, ⊕) → (TropObj, ⊗_max)`.

## Conjecture 5 — The multiplicative obstru
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
