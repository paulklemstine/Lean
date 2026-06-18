
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

**Title**: Tropical weight enumerator profiles for binary linear codes via Smooth Poincaré primitives
**Domain**: Applications
**Mathematical framing**: 
Research domain: Applications
Research mode: formalize


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Applications/SmoothPoincare/TropicalWeightEnumerator.lean
/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Tropical weight enumerator profiles for binary linear codes

This file develops the **tropical shadow** of the classical weight enumerator that the
catalog's `SmoothPoincare` code files (`TopologicalCodes`, `CodeDirectSum`,
`MinimumDistance`, `GleasonLength`) study over `ℂ`.

The classical (Hamming) weight enumerator of a binary code `C ⊆ (ZMod 2)ⁿ` is the
two-variable polynomial `W_C(x,y) = ∑_{c∈C} x^{n−wt c} y^{wt c}`.  Its single most
important structural property, used implicitly all over `CodeDirectSum`, is that it is
**multiplicative** under the direct sum (coordinate concatenation) of codes:
`W_{C⊕D} = W_C · W_D`.

Tropicalizing — replacing the semiring `(ℝ, +, ×)` by the **min-plus tropical
semiring** `(ℝ, min, +)` of `Bridges/CategoricalTropicalUltrametric` — turns the
generating *sum* `∑` into a *minimum* and the *product* `×` into a *sum* `+`.  The
tropical weight enumerator is therefore the piecewise-linear function

  `twe C t = min_{c ∈ C} (wt c · t)`,

and the multiplicativity `W_{C⊕D} = W_C · W_D` becomes the **tropical additivity**
`twe (C ⊕ D) = twe C + twe D` (`twe_append`), the headline of this file: it is the
exact tropical mirror of `CodeDirectSum.wt_append` (`wt (a ++ b) = wt a + wt b`).

Alongside this, the **minimum distance** of a code is itself a tropical quantity: under
direct sum it behaves like tropical *addition* (a `min`):
`minDist (C ⊕ D) = min (minDist C) (minDist D)` (`minDist_append`), reflecting that the
shortest nonzero codeword of a concatenation lives entirely in one block.

The two together give a clean "tropical dictionary" for the direct-sum operation:

  | classical invariant            | direct-sum law      | tropical reading      |
  |--------------------------------|---------------------|-----------------------|
  | length `n`                     | `n_C + n_D`         | additive              |
  | `|C|`                          | `|C|·|D|`           | log-additive          |
  | weight enumerator `W_C`        | `W_C · W_D`         | `twe` additive        |
  | minimum distance `d`           | `min(d_C, d_D)`     | tropical `min`        |

Finally, instantiating on the catalog's extended Hamming `[8,4,4]` code reveals a
genuine *information-loss* phenomenon: although the classical enumerator is
`1 + 14x⁴ + x⁸` (`MinimumDistance.hamming_weightEnum_*`), the tropical enumerator is
just `twe hamming t = min(0, 8·t)` (`hamming_twe`) — the weight-`4` stratum, i.e. the
minimum distance itself, is **invisible** to the tropical enumerator because `4` is not
a vertex of the convex hull of the weight spectrum `{0,4,8}`.  This is exactly why the
minimum distance must be recorded by the *separate* tropical-min invariant `minDist`.

-- !-- Lab Notes -- !--
Hypothesis: the multiplicativity of the weight enumerator under direct sum
  (`W_{C⊕D}=W_C·W_D`, the engine behind `CodeDirectSum.appendCode_*`) tropicalizes to a
  clean additive law `twe (C⊕D)=twe C+twe D`, and the minimum distance tropicalizes to a
  `min` law `minDist (C⊕D)=min (minDist C) (minDist D)`.
Result: both laws proved `sorry`-free for arbitrary lengths via `Finset.inf'`
  antisymmetry arguments resting only on `wt_append`. Instantiated on `hamming` and
  `hamming16`: `twe hamming = min(0, 8t)` and `minDist hamming = minDist hamming16 = 4`.
Insight 1: `min_{a,b}(f a + g b) = min_a f a + min_b g b` holds for ALL real slopes `t`
  (no sign hypothesis), because the two blocks are independent — this is the tropical
  fingerprint of the factorisation `W_{C⊕D}=W_C·W_D`.
Insight 2 (information loss): the tropical enumerator only sees the *convex hull* of the
  weight spectrum. For `hamming` the spectrum `{0,4,8}` has hull vertices `{0,8}`, so the
  minimum distance `4` is erased by `twe` — a concrete reason the `minDist` invariant is
  not redundant.
Failure analysis: `Finset.inf'` nonemptiness side-goals are routed through `C.erase 0`
  (nonzero codewords) and the membership witnesses `append a 0`, `append 0 b`, which keep
  the additivity/min proofs free of any `Fin`-index arithmetic — the same routing as
  `CodeDirectSum.appendCode_selfDual`.
-/

import Mathlib
import Catalog.Applications.SmoothPoincare.CodeDirectSum

open scoped BigOperators

namespace SmoothPoincare
namespace Codes

variable {m n : ℕ}

/-! ## The tropical weight enumerator -/

/-- **Tropical weight enumerator.** The min-plus tropicalization of the classical
weight enumerator: `twe C t = min_{c ∈ C} (wt c · t)`.  As a function of the tropical
variable `t : ℝ` it is concave and piecewise linear, its slopes being the codeword
weights. -/
noncomputable def twe (C : Finset (Fin n → ZMod 2)) (hC : C.Nonempty) (t : ℝ) : ℝ :=
  C.inf' hC (fun c => (wt c : ℝ) * t)

/-- The tropical enumerator is a lower bound for every codeword's linear term. -/
theorem twe_le_of_mem {C : Finset (Fin n → ZMod 2)} (hC : C.Nonempty) (t : ℝ)
    {c : Fin n → ZMod 2} (hc : c ∈ C) : twe C hC t ≤ (wt c : ℝ) * t :=
  Finset.inf'_le _ hc

/-- The tropical enumerator is *attained* by some codeword. -/
theorem twe_attained {C : Finset (Fin n → ZMod 2)} (hC : C.Nonempty) (t : ℝ) :
    ∃ c ∈ C, twe C hC t = (wt c : ℝ) * t :=
  Finset.exists_mem_eq_inf' hC _

/-- A lower bound certificate: if `b ≤ wt c · t` for every codeword `c`, then
`b ≤ twe C t`. -/
theorem le_twe {C : Finset (Fin n → ZMod 2)} (hC : C.Nonempty) (t : ℝ) {b : ℝ}
    (h : ∀ c ∈ C, b ≤ (wt c : ℝ) * t) : b ≤ twe C hC t :=
  Finset.le_inf' hC _ h

/-! ## Headline: tropical additivity under direct sum -/

/-- The direct sum of two nonempty codes is nonempty. -/
theorem appendCode_nonempty {C : Finset (Fin m → ZMod 2)} {D : Finset (Fin n → ZMod 2)}
    (hC : C.Nonempty) (hD : D.Nonempty) : (C ⊕c D).Nonempty :=
  (hC.product hD).image _

/-
**Tropical additivity of the weight enumerator under direct sum.** This is the
min-plus tropicalization of the classical multiplicativity `W_{C⊕D} = W_C · W_D`, and
the exact tropical mirror of `wt_append`. It holds for *all* real slopes `t`.
-/
theorem twe_append {C : Finset (Fin m → ZMod 2)} {D : Finset (Fin n → ZMod 2)}
    (hC : C.Nonempty) (hD : D.Nonempty) (t : ℝ) :
    twe (C ⊕c D) (appendCode_nonempty hC hD) t = twe C hC t + twe D hD t := by
  refine' le_antisymm _ _ <;> norm_num [ twe ] at *;
  · obtain ⟨ a, ha, hae ⟩ := twe_attained hC t; obtain ⟨ b, hb, hbe ⟩ := twe_attained hD t; use Fin.append a b; simp_all +decide [ wt_append ] ; ring;
    simp_all +decide [ mul_comm, Finset.mem_image, Finset.mem_product, twe ];
    exact Finset.mem_image.mpr ⟨ ( a, b ), Finset.mem_product.mpr ⟨ ha, hb ⟩, rfl ⟩;
  · intro b hb; obtain ⟨ a, ha, b, hb, rfl ⟩ := mem_appendCode_iff_exists.mp hb; simp +decide [ wt_append ] ;
    rw [ add_mul ] ; exact add_le_add ( Finset.inf'_le _ ha ) ( Finset.inf'_le _ ‹_› ) ;

/-! ## The minimum distance as a tropical-min invariant -/

/-- **Minimum distance.** The least weight of a *nonzero* codeword, defined over
`C.erase 0`. -/
noncomputable def minDist (C : Finset (Fin n → ZMod 2))
    (h : (C.erase 0).Nonempty) : ℕ :=
  (C.erase 0).inf' h wt

/-- `minDist` is a lower bound for the weight of every nonzero codeword. -/
theorem minDist_le_of_mem {C : Finset (Fin n → ZMod 2)} (h : (C.erase 0).Nonempty)
    {c : Fin n → ZMod 2} (hc : c ∈ C) (hc0 : c ≠ 0) : minDist C h ≤ wt c :=
  Finset.inf'_le _ (Finset.mem_erase.mpr ⟨hc0, hc⟩)

/-- A lower bound certificate for `minDist`. -/
theorem le_minDist {C : Finset (Fin n → ZMod 2)} (h : (C.erase 0).Nonempty) {b : ℕ}
    (hb : ∀ c ∈ C, c ≠ 0 → b ≤ wt c) : b ≤ minDist C h :=
  Finset.le_inf' h _ (fun c hc => hb c (Finset.mem_of_mem_erase hc)
    (Finset.ne_of_mem_erase hc))

/-- The nonzero codewords of a direct sum form a nonempty set, provided each factor
contains `0` and the left factor has at least one nonzero codeword. -/
theorem appendCode_erase_nonempty {C : Finset (Fin m → ZMod 2)}
 
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: Tropical weight enumerator profiles for binary linear codes

This cycle introduced `TropicalWeightEnumerator.lean`, the **min-plus tropicalization**
of the classical Hamming weight enumerator on top of the catalog's `SmoothPoincare`
code primitives. The headline results were:

* `twe_append` — **tropical additivity**: `twe (C ⊕ D) = twe C + twe D`, the min-plus
  shadow of the classical multiplicativity `W_{C⊕D} = W_C · W_D`.
* `minDist_append` — **the minimum distance is a tropical-`min` invariant**:
  `minDist (C ⊕ D) = min (minDist C) (minDist D)`.
* `hamming_twe` — `twe hamming t = min(0, 8·t)`, exhibiting **information loss**: the
  weight-`4` stratum (the minimum distance) is invisible to `twe` because `4` is not a
  vertex of the convex hull of the weight spectrum `{0, 4, 8}`.

The conjectures below are concrete, falsifiable, and each comes with a suggested Lean
shape so a follow-up cycle can attack them directly.

---

## Conjecture 1 (Tropical hull recovery — the profile is exactly the lower convex hull)

**Claim.** For any nonempty binary code `C ⊆ (ZMod 2)ⁿ`, the slopes realized by the
piecewise-linear function `t ↦ twe C t` are *exactly* the weights of `C` that are
vertices of the lower convex hull of the weight-multiplicity set
`{(wt c, 1) : c ∈ C}`. Equivalently, a weight `w` present in `C` is realized as the
minimizer of `twe C t` for some `t` **iff** `w` is a hull vertex.

**Why it is bold.** It makes precise *exactly* how much the tropicalization forgets:
the `hamming` computation (`twe hamming = min(0,8t)` despite spectrum `{0,4,8}`) becomes
a special case of a general "hull recovery" theorem.

**Suggested Lean shape.**
```
def realizedSlope (C) (hC) (w : ℕ) : Prop := ∃ t : ℝ, ∀ c ∈ C, (w:ℝ)*t ≤ (wt c:ℝ)*t ∧ ...
theorem twe_slopes_eq_hull_vertices (C) (hC) :
    {w | realizedSlope C hC w} = hullVertices (weightSpectrum C)
```
**First test.** Recompute for the `[6,3,?]` shortened code and the repetition code
`{0…0, 1…1}`, where the hull is the full spectrum, and verify against `hamming`.

---

## Conjecture 2 (Tropical Gleason / Mallows–Sloane bound)

**Claim.** Every binary doubly-even self-dual code of length `n` satisfies
`minDist C ≤ 4 · ⌊n / 24⌋ + 4`. The tropical-`min` law `minDist_append` shows the
right-hand side is *not* additive (stacking two `[8,4,4]` codes keeps `d = 4`), so the
bound is genuinely a global obstruction, the distance-side analogue of Gleason's length
divisibility (`GleasonLength.doublyEven_selfDual_length_div_eight`).

**Suggested Lean shape.**
```
theorem doublyEven_selfDual_minDist_le
    (C : Finset (Fin n → ZMod 2)) (hDE : ∀ v ∈ C, DoublyEven v)
    (hSD : ∀ x, x ∈ C ↔ ∀ y ∈ C, ip x y = 0) (hne : (C.erase 0).Nonempty) :
    minDist C hne ≤ 4 * (n / 24) + 4
```
**First test.** `n = 8` (`hamming`, bound `= 4`, tight) and `n = 24` (the extended Golay
code, bound `= 8`); a follow-up cycle can build the Golay generator and `native_decide`
the spectrum to check tightness.

---

## Con
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
