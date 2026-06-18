
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

**Title**: Close Proofs: Algebraic and order-theoretic backbone of stereograph
**Domain**: Applications
**Mathematical framing**: Cycle ccb9b034 (Q=0.423) proved 299 theorems in Geometry but left 13 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: # Future Directions: Stereographic Capacity Theory

This cycle established the algebraic and order-theoretic backbone of stereographic
capacity theory in `Geometry/StereographicCapacity/Theorems.lean`
Research domain: Applications
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Geometry/StereographicCapacity/Theorems.lean
import Mathlib

/-!
# Stereographic Capacity Theory: the algebraic & order-theoretic backbone

This file develops the *group-theoretic* and *order-theoretic* backbone behind the
inverse stereographic projection studied in
`Catalog/Geometry/InverseStereoResearch.lean`.

The chart `invStereo t = (2t/(1+t²), (1-t²)/(1+t²))` parametrizes the unit circle by a
single real coordinate `t` (the tangent of the half-angle).  The central discovery of
this cycle is that the seemingly geometric operation "rotate a point of `S¹`" becomes,
in the stereographic coordinate, a single rational binary operation

    stereoAdd t s = (t + s) / (1 - t·s)

— the *tangent half-angle addition law*, a.k.a. the formal group law of `arctan`.  We
prove that this operation:

* turns rotation into an explicit algebraic identity (`stereo_addition_law`);
* is realized by honest `2×2` real matrix multiplication (`stereoRot_mul`), connecting
  to the Gaussian/rotation matrices of the catalog (`gaussian_matrix_compose`,
  `gaussian_det_multiplicative`);
* is associative (`stereoAdd_assoc`) and commutative (`stereoAdd_comm`) with identity `0`
  (`stereoAdd_zero`) — i.e. a *partial abelian group* on `ℝ`;
* is intertwined with ordinary angle addition by the order embedding
  `stereoAngle t = 2·arctan t` (`stereoAngle_stereoAdd`, `stereoAngle_strictMono`).

We then isolate the *capacity* coordinate `2t/(1+t²)` and prove its extremal
characterization (`stereo_capacity_le_one`, `stereo_capacity_eq_one_iff`): the circle's
horizontal extent is maximized exactly at `t = 1`, the `(3,4,5)`-adjacent point.

## Catalog synthesis

* Extends `inv_stereo_on_circle`, `inv_stereo_injective`, `stereo_critical_line` from
  `InverseStereoResearch.lean` from *pointwise* facts to a *group law*.
* `stereoRot_mul` is the real-analytic shadow of `gaussian_matrix_compose` and
  `gaussian_det_multiplicative`: rotation composition = norm-`1` complex multiplication.
* `stereoAngle_strictMono` supplies the order-theoretic backbone hinted at by the
  `StereographicSheaf` transition theory.
-/

noncomputable section

open Real

/-- Inverse stereographic projection of the line onto the unit circle `S¹`,
parametrized by the tangent of the half-angle. -/
noncomputable def invStereo (t : ℝ) : ℝ × ℝ := (2 * t / (1 + t ^ 2), (1 - t ^ 2) / (1 + t ^ 2))

/-- The **stereographic addition law** `(t + s)/(1 - t·s)`: the tangent half-angle
addition formula, i.e. the partial group law that linearizes circle rotation. -/
noncomputable def stereoAdd (t s : ℝ) : ℝ := (t + s) / (1 - t * s)

/-- The **stereographic angle** `2·arctan t`: the order embedding of the stereographic
coordinate into the open arc `(-π, π)`. -/
noncomputable def stereoAngle (t : ℝ) : ℝ := 2 * Real.arctan t

/-- The `2×2` rotation matrix attached to a stereographic coordinate, with columns the
stereographic point and its quarter-turn. -/
noncomputable def stereoRot (t : ℝ) : Matrix (Fin 2) (Fin 2) ℝ :=
  !![(invStereo t).2, -(invStereo t).1; (invStereo t).1, (invStereo t).2]

/-- Sanity lemma: the chart lands on the unit circle (re-established locally). -/
theorem invStereo_on_circle (t : ℝ) : (invStereo t).1 ^ 2 + (invStereo t).2 ^ 2 = 1 := by
  have h : (1 : ℝ) + t ^ 2 ≠ 0 := by positivity
  simp only [invStereo]
  field_simp
  ring

-- !-- comment -- !--
-- stereo_addition_law: unfold invStereo/stereoAdd; the common denominator
-- (1-ts)² + (t+s)² collapses to (1+t²)(1+s²), so field_simp + ring closes both
-- coordinates. This is the sin/cos angle-addition law written rationally.
-- !-- comment -- !--

-- !-- Lab Notebook: stereo_addition_law -- !--
-- !-- Hypothesis: Circle rotation, opaque in (x,y) coordinates, should become a single
--     rational identity in the stereographic coordinate t = tan(θ/2). -- !--
-- !-- Result: Proved. invStereo(stereoAdd t s) equals the rotation of invStereo t by the
--     angle of s, expressed as (x₁y₂+y₁x₂, y₁y₂-x₁x₂) — exactly sin/cos addition. -- !--
-- !-- Insight: The denominator (1-ts)²+(t+s)² factors as (1+t²)(1+s²); this single
--     algebraic miracle is *why* the half-angle substitution rationalizes trigonometry. -- !--
-- !-- Failure analysis: A coordinate-free `Prod.ext` attempt stalled; splitting into the
--     two scalar coordinates and clearing all three denominators at once was decisive. -- !--
-- !-- End Lab Notebook -- !--

/-- **Main theorem (algebraic backbone).** In stereographic coordinates, rotation is the
rational addition law: `invStereo (stereoAdd t s)` is the rotation of `invStereo t` by the
angle of `s`, i.e. the sine/cosine angle-addition formula written rationally. -/
theorem stereo_addition_law (t s : ℝ) (h : 1 - t * s ≠ 0) :
    invStereo (stereoAdd t s) =
      ((invStereo t).1 * (invStereo s).2 + (invStereo t).2 * (invStereo s).1,
       (invStereo t).2 * (invStereo s).2 - (invStereo t).1 * (invStereo s).1) := by
  have h1 : (1 : ℝ) + t ^ 2 ≠ 0 := by positivity
  have h2 : (1 : ℝ) + s ^ 2 ≠ 0 := by positivity
  simp only [invStereo, stereoAdd, Prod.mk.injEq]
  constructor <;> field_simp <;> ring

-- !-- comment -- !--
-- stereoRot_mul: expand the 2×2 product entrywise (Fin.sum_univ_two), then each entry is
-- the same rational identity as stereo_addition_law; field_simp + ring per entry.
-- !-- comment -- !--

-- !-- Lab Notebook: stereoRot_mul -- !--
-- !-- Hypothesis: The addition law should be matrix multiplication of honest rotation
--     matrices, mirroring the catalog's gaussian_matrix_compose over ℤ. -- !--
-- !-- Result: Proved. stereoRot t * stereoRot s = stereoRot (stereoAdd t s). -- !--
-- !-- Insight: This is the real-analytic image of complex multiplication of unit-modulus
--     numbers; det stereoRot = x²+y² = 1 ties it to gaussian_det_multiplicative. -- !--
-- !-- Failure analysis: None substantive; the entrywise field_simp;ring pattern that
--     proved stereo_addition_law transferred directly to the matrix entries. -- !--
-- !-- End Lab Notebook -- !--

/-- **Matrix form (cross-domain bridge).** The stereographic addition law is realized by
multiplication of `2×2` rotation matrices, the real-analytic shadow of the catalog's
`gaussian_matrix_compose` / `gaussian_det_multiplicative`. -/
theorem stereoRot_mul (t s : ℝ) (h : 1 - t * s ≠ 0) :
    stereoRot t * stereoRot s = stereoRot (stereoAdd t s) := by
  have h1 : (1 : ℝ) + t ^ 2 ≠ 0 := by positivity
  have h2 : (1 : ℝ) + s ^ 2 ≠ 0 := by positivity
  simp only [stereoRot, invStereo, stereoAdd]
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [Matrix.mul_apply, Fin.sum_univ_two] <;> field_simp <;> ring

/-- The stereographic rotation matrix lies in `SO(2)`: its determinant is `1`. -/
theorem stereoRot_det_one (t : ℝ) : (stereoRot t).det = 1 := by
  have := invStereo_on_circle t
  simp only [stereoRot, Matrix.det_fin_two_of]
  nlinarith [this]

-- !-- comment -- !--
-- stereoAdd_assoc: clear denominators with field_simp using h1,h2 then ring_nf; the outer
-- non-vanishing hypotheses turn out unnecessary because the cleared identity is polynomial.
-- !-- comment -- !--

-- !-- Lab Notebook: stereoAdd_assoc -- !--
-- !-- Hypothesis: stereoAdd is associative (a true partial abelian group law). -- !--
-- !-- Result: Proved, and SURPRISINGLY needs only the two *inner* denominators nonzero;
--     the two outer non-vanishing conditions were redundant. -- !--
-- !-- Insight: After clearing the inner denominators the associativity identity is a
--     polynomial identity, so ring_nf alone finishes — a formal-group-law phenomenon. -- !--
-- !-- Failure analysis: An over-specified version with four hypotheses compiled but flagged
--     two as unused; we removed them, yielding a cleaner, more general statement. -- !--
-- !-- End Lab Notebook -- !--

/-- **Associativity of the stereographic addition law.** Together with `stereoAdd_comm`
and `stereoAdd_zero` this exhibits `(ℝ, stereoAdd)` as a *partial abelian group*. -/
theorem stereoAdd_assoc (t s u : ℝ) (h1 : 1 - 
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: Stereographic Capacity Theory

## Synthesis

This cycle built the **algebraic and order-theoretic backbone** of stereographic capacity
theory, in `Catalog/Geometry/StereographicCapacity/Theorems.lean`. The previous cycle
(`InverseStereoResearch.lean`) established *pointwise* facts about the chart
`invStereo t = (2t/(1+t²), (1-t²)/(1+t²))` — that it lands on `S¹`, is injective, and sends
`1/2` to the `(3,4,5)` triple. We upgraded those isolated facts to a **structure**: the
seemingly geometric act of *rotating a point on the circle* is, in the stereographic
coordinate, exactly the single rational binary law `stereoAdd t s = (t+s)/(1-ts)` — the
tangent half-angle / `arctan` formal group law. The central result `stereo_addition_law`
proves this is the sine/cosine angle-addition formula written rationally, and `stereoRot_mul`
realizes it as honest `2×2` rotation-matrix multiplication, the real-analytic shadow of the
catalog's integer `gaussian_matrix_compose` and `gaussian_det_multiplicative`.

The key structural insight is that one algebraic identity does all the work: the combined
denominator `(1-ts)² + (t+s)²` factors as `(1+t²)(1+s²)`. This single factorization is *why*
the half-angle substitution rationalizes trigonometry, why `stereoAdd` is associative
(`stereoAdd_assoc` — which, surprisingly, needs only the two inner denominators nonzero,
because after clearing them the identity is purely polynomial), and why `(ℝ, stereoAdd)` is a
partial abelian group with identity `0`. On the order side, `stereoAngle t = 2·arctan t` is a
strictly monotone order embedding (`stereoAngle_strictMono`) that intertwines `stereoAdd` with
ordinary `+` on the branch `t·s < 1` (`stereoAngle_stereoAdd`); we then pushed this to a
genuine *convexity* backbone, `stereoAngle_concaveOn_Ici`.

What failed / what the critique exposed: the convexity statement is **half-line local**, not
global. `stereoAngle` has an inflection point at `t = 0` (it is convex on `(-∞,0]` and concave
on `[0,∞)`), so a global `ConcaveOn ℝ` statement is false — the restriction to `Set.Ici 0` is
essential, not cosmetic. Likewise every multiplicative result carries the branch hypothesis
`1 - t·s ≠ 0` (resp. `t·s < 1`): these encode the single missing point `∞` of the one-point
compactification where the partial group law is undefined. The directions below are organized
around *removing these blemishes* (compactify to a total group) and *exporting the backbone*
to higher dimensions and to the catalog's number-theoretic constructions.

## Results Summary

- `invStereo_on_circle`: proved — the chart lands on the unit circle (local re-derivation of the catalog fact).
- `stereo_addition_law`: proved — **main result**: circle rotation equals the rational addition law in stereographic coordinates.
- `stereoRot_mul`: proved — the addition law is `2×2` rotation-matrix multiplication; cross-domain bridge to the catalog's Gaussian matrices.
- `stereoRot_det_one`: proved — the stereographic r
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
