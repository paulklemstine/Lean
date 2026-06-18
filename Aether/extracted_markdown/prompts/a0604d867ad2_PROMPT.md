
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

**Title**: Nonarchimedean triangle inequality for arithmetic-height-induced ultrametrics
**Domain**: Bridges
**Mathematical framing**: Define a depth function `δ : ℚ → ℕ ∪ {∞}` modeled on valuation depth, with `δ(0)=∞`, `δ(-x)=δ(x)`, and a target inequality `δ(x+y) ≥ min (δ x) (δ y)` on a controlled subclass of rationals. Use arithmetic-height data to instantiate or bound `δ`, possibly via denominator/exponent data extracted from normalized fractions. Then define `d(x,y)` from `δ(x-y)` and prove: (1) `d(x,y)=0 ↔ x=y`; (2) symmetry; (3) strong triangle inequality `d(x,z) ≤ max (d(x,y)) (d(y,z))`. A second theorem should package this as an object in the tropical-ultrametric bridge layer, giving a constructor from arithmetic height/depth data to `UltraNormObj`-style structures. The restricted subclass could be dyadic rationals, p-local rationals, or rationals with denominator supported on a fixed prime set; the best choice is whichever aligns most directly with existing valuation-depth lemmas and avoids in-flight overlap with tropical filtration stability.
Research domain: Bridges
Research mode: prove


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Bridges/ArithmeticHeightUltrametric.lean
/-
  # Arithmetic-Height-Induced Ultrametrics
  ## A nonarchimedean bridge from p-adic arithmetic height/depth data to
  ## ultrametric distances and to the catalog's tropical–ultrametric object layer.

  Bridge: Number theory (p-adic valuation / arithmetic height) ↔ Metric geometry
  (ultrametric / strong triangle inequality) ↔ the categorical tropical–ultrametric
  interface (`CategoricalTropicalUltrametric.UltraNormObj`).

  **Core principle.** A valuation-style *arithmetic depth* on rational differences
  induces a genuine ultrametric distance `d(x,y) = padicNorm p (x - y)`, and the
  *integer* divisibility-depth packages as a multiplicative ℕ-valued seminorm — a
  bona fide `TropicalValuationCarrier`, hence (via `valuationReconstruct`) an
  `UltraNormObj`.  A representation/rigidity result explains *why* the carrier must
  live on the integers rather than the field: on a field every multiplicative
  ℕ-valued norm is trivial on nonzero elements.

  -- !-- Lab Notebook -- !--
  Hypothesis: arithmetic height/depth data on ℚ yields a strong (max-type) triangle
    inequality, and the discrete divisibility depth on ℤ is a multiplicative
    ultrametric ℕ-seminorm that instantiates the catalog `UltraNormObj` interface.
  Result: proved identity / symmetry / strong-triangle for `hDist p` on ℚ, built
    `arithDepthCarrier p : TropicalValuationCarrier`, reconstructed it into an
    ultrametric object via the catalog's `valuationReconstruct`, and proved the
    field-rigidity obstruction forcing the carrier to be ℤ rather than ℚ.
  Insight: the catalog `UltraNormObj` norm axioms (ℕ-valued, multiplicative,
    `norm_add ≤ max`) are satisfiable nontrivially only on a non-field: on ℚ
    multiplicativity + `norm 1 = 1` collapses the norm to the nonzero-indicator
    (`field_norm_rigid`).  Quantitative depth therefore lives in the *real-valued*
    `padicNorm` distance, while the *categorical object* lives over ℤ via the
    prime-divisibility (residue-field) indicator `val n = if p ∣ n then 0 else 1`,
    which is exactly the indicator of nonvanishing in `ZMod p` (`valInt_eq_one_iff_residue`).
  Failure analysis: a first attempt put the divisibility indicator on all of ℚ; it
    fails multiplicativity (v_p = 1 times v_p = -1 gives a unit), so the carrier was
    restricted to ℤ, where p-adic valuations are nonnegative and Euclid's lemma
    makes the indicator multiplicative.
  -- !-- Lab Notebook -- !--
-/

import Mathlib
import Bridges.CategoricalTropicalUltrametric

open scoped Classical
open CategoricalTropicalUltrametric

namespace ArithmeticHeightUltrametric

noncomputable section

/-! ## §1. The arithmetic-height depth distance on ℚ

The quantitative heart: `hDist p x y := padicNorm p (x - y)` is a real (ℚ-valued)
ultrametric whose value is `p ^ (-(arithmetic depth of x - y))`. -/

/-- The arithmetic-height-induced distance: the p-adic norm of the difference,
    equal to `p ^ (-(padicValRat p (x - y)))`. -/
def hDist (p : ℕ) (x y : ℚ) : ℚ := padicNorm p (x - y)

variable {p : ℕ} [Fact p.Prime]

-- !-- The p-adic norm is always nonnegative. -- !--
omit [Fact p.Prime] in
/-- The depth distance is nonnegative. -/
theorem hDist_nonneg (x y : ℚ) : 0 ≤ hDist p x y := by
  convert padicNorm.nonneg (x - y) using 1

-- !-- `x - x = 0` and `padicNorm p 0 = 0`. -- !--
omit [Fact p.Prime] in
/-- A point is at distance zero from itself. -/
theorem hDist_self (x : ℚ) : hDist p x x = 0 := by
  unfold hDist; simp

-- !-- `padicNorm` vanishes iff its argument is `0`, and `x - y = 0 ↔ x = y`. -- !--
/-- **Identity of indiscernibles.** The depth distance separates points. -/
theorem hDist_eq_zero_iff (x y : ℚ) : hDist p x y = 0 ↔ x = y := by
  rw [hDist, IsAbsoluteValue.abv_eq_zero (padicNorm p), sub_eq_zero]

-- !-- `x - y = -(y - x)` and `padicNorm` is invariant under negation. -- !--
omit [Fact p.Prime] in
/-- **Symmetry** of the depth distance. -/
theorem hDist_symm (x y : ℚ) : hDist p x y = hDist p y x := by
  unfold hDist; rw [← neg_sub, padicNorm.neg]

-- !-- Write `x - z = (x - y) + (y - z)` and apply the nonarchimedean inequality
-- for `padicNorm`. -- !--
/-- **Strong (ultrametric) triangle inequality** — the headline theorem:
    the arithmetic-height distance satisfies `d(x,z) ≤ max (d(x,y)) (d(y,z))`. -/
theorem hDist_strong_triangle (x y z : ℚ) :
    hDist p x z ≤ max (hDist p x y) (hDist p y z) := by
  unfold hDist
  rw [show x - z = (x - y) + (y - z) by ring]
  exact padicNorm.nonarchimedean

-- !-- Both distances are nonnegative, so `max a b ≤ a + b`. -- !--
/-- The ordinary triangle inequality is a consequence of the strong one. -/
theorem hDist_triangle (x y z : ℚ) :
    hDist p x z ≤ hDist p x y + hDist p y z := by
  refine le_trans (hDist_strong_triangle x y z) ?_
  exact max_le (le_add_of_nonneg_right (hDist_nonneg _ _))
    (le_add_of_nonneg_left (hDist_nonneg _ _))

/-! ## §2. The discrete arithmetic-divisibility depth on ℤ

The *categorical* carrier.  On the integers the p-adic valuation is nonnegative, so
the prime-divisibility indicator `valInt n = if (p:ℤ) ∣ n then 0 else 1` is a
multiplicative ℕ-valued ultrametric seminorm — a `TropicalValuationCarrier`. -/

/-- Arithmetic divisibility depth on ℤ: `0` exactly on the multiples of `p`
    (the "deep" integers), `1` on the p-adic units. -/
def valInt (p : ℕ) (n : ℤ) : ℕ := if (p : ℤ) ∣ n then 0 else 1

-- !-- `(p:ℤ) ∣ 0` holds, so the indicator is `0`. -- !--
omit [Fact p.Prime] in
theorem valInt_zero : valInt p 0 = 0 := if_pos (dvd_zero _)

-- !-- `(p:ℤ) ∣ -n ↔ (p:ℤ) ∣ n`. -- !--
omit [Fact p.Prime] in
theorem valInt_neg (n : ℤ) : valInt p (-n) = valInt p n := by
  simp [valInt]

-- !-- Euclid's lemma: a prime divides a product iff it divides a factor, so the
-- {0,1}-indicator is multiplicative. -- !--
theorem valInt_mul (m n : ℤ) : valInt p (m * n) = valInt p m * valInt p n := by
  unfold valInt
  split_ifs <;> simp_all [← ZMod.intCast_zmod_eq_zero_iff_dvd]

-- !-- If `p ∤ (m+n)` then `p` divides at most one of `m, n` (else it divides the
-- sum), so the indicator of the sum is `≤ max`. -- !--
omit [Fact p.Prime] in
theorem valInt_add (m n : ℤ) : valInt p (m + n) ≤ max (valInt p m) (valInt p n) := by
  by_cases hm : (p : ℤ) ∣ m <;> by_cases hn : (p : ℤ) ∣ n <;> simp [*, valInt]
  · exact dvd_add hm hn
  · split_ifs <;> norm_num
  · split_ifs <;> norm_num
  · split_ifs <;> norm_num

-- !-- Unfolding the indicator, `valInt p n = 1 ↔ ¬ (p:ℤ) ∣ n`, and
-- `(n : ZMod p) = 0 ↔ (p:ℤ) ∣ n`. -- !--
/-- **Representation via the residue field.** The divisibility depth is exactly the
    indicator of nonvanishing in `ZMod p`: `valInt p n = 1 ↔ (n : ZMod p) ≠ 0`.
    This is the Gelfand-style "evaluation at the prime `p`" reading of the depth. -/
theorem valInt_eq_one_iff_residue (n : ℤ) :
    valInt p n = 1 ↔ ((n : ZMod p) ≠ 0) := by
  unfold valInt; simp [ZMod.intCast_zmod_eq_zero_iff_dvd]

/-! ## §3. Bridge constructor into the catalog object layer -/

/-- **Bridge constructor.** Package the integer arithmetic-divisibility depth as a
    `TropicalValuationCarrier`, the source object for the catalog's
    `valuationReconstruct` functor into `UltraNormObj`. -/
def arithDepthCarrier (p : ℕ) [Fact p.Prime] : TropicalValuationCarrier where
  K := ℤ
  add_op := (· + ·)
  neg_op := Neg.neg
  zero_val := 0
  sub_op := (· - ·)
  sub_def := fun x y => by ring
  mul_op := (· * ·)
  one_val := 1
  val := valInt p
  val_zero := valInt_zero
  val_neg := valInt_neg
  val_mul := valInt_mul
  val_add := valInt_add

-- !-- After unfolding `valuationReconstruct` and `arithDepthCarrier`, the norm is
-- `valInt p` and the goal is exactly `valInt_add`. -- !--
/-- **Main bridge theorem.** The ultrametric object reconstructed from the arithmetic
    depth carrier satisfies the strong triangle inequality on the integers — i.e. the
    arithmetic-height data really does instantiate the catalog `UltraNormObj` interface
    with a nonarchimedean norm. -/
theorem a
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — Arithmetic-Height-Induced Ultrametrics

## Synthesis

The new file `Bridges/ArithmeticHeightUltrametric.lean` builds a concrete pipeline
from *arithmetic height / p-adic depth data* to the catalog's categorical
tropical–ultrametric object layer (`Bridges/CategoricalTropicalUltrametric.lean`).
Two complementary faces of the same nonarchimedean idea are formalized:

1. **A quantitative real-valued ultrametric on ℚ.** `hDist p x y := padicNorm p (x - y)`
   satisfies identity of indiscernibles (`hDist_eq_zero_iff`), symmetry
   (`hDist_symm`), and the strong/ultrametric triangle inequality
   (`hDist_strong_triangle`), with the ordinary triangle inequality as a corollary.
   This is the "depth distance" `d(x,y) = p^(-(depth (x-y)))` of the concept brief.

2. **A categorical carrier over ℤ.** The prime-divisibility indicator
   `valInt p n = if (p:ℤ) ∣ n then 0 else 1` is a multiplicative ℕ-valued ultrametric
   seminorm (`valInt_mul`, `valInt_add`), so it assembles into a
   `TropicalValuationCarrier` (`arithDepthCarrier`) and, via the catalog functor
   `valuationReconstruct`, into an `UltraNormObj` whose norm is genuinely
   nonarchimedean (`arithDepthCarrier_ultrametric`). The representation theorem
   `valInt_eq_one_iff_residue` identifies this depth with the indicator of
   nonvanishing in the residue field `ZMod p` — a Gelfand-style "evaluation at the
   prime `p`".

The conceptual unifier is a **rigidity/duality obstruction**, `field_norm_rigid`:
on *any* field, a multiplicative ℕ-valued map sending `1 ↦ 1` is identically `1` on
nonzero elements. This explains a structural fork that the catalog interface forces
but never made explicit: quantitative depth cannot live in an ℕ-valued *multiplicative*
norm over a field, so it must be carried either by a real-valued absolute value (face 1)
or by a non-field carrier such as ℤ (face 2).

## Results Summary

- `hDist_nonneg`, `hDist_self`, `hDist_eq_zero_iff`, `hDist_symm`,
  `hDist_strong_triangle`, `hDist_triangle` — the depth metric on ℚ is an ultrametric.
- `valInt_zero`, `valInt_neg`, `valInt_mul`, `valInt_add` — the ℤ divisibility depth
  is a multiplicative ℕ-valued ultrametric seminorm.
- `valInt_eq_one_iff_residue` — residue-field representation of the depth.
- `arithDepthCarrier` + `arithDepthCarrier_ultrametric` — the bridge constructor into
  the catalog object layer.
- `field_norm_rigid` — the field-rigidity obstruction.

All main results are `sorry`-free and depend only on `propext`, `Classical.choice`,
and `Quot.sound`.

## Falsifiable Research Directions

### 1. Completeness of the depth metric and the p-adic integers as a limit object
The key insight is that `hDist p` is not merely an ultrametric but the restriction to ℚ
of the metric whose completion is `ℚ_p`, so the abstract `UltraNormObj` carrier should
admit a *completion functor* landing in a complete ultrametric object. Conjecture: the
Cauchy-sequence completion of `(ℚ, hDist p)` is isometric to Mathlib's 
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
