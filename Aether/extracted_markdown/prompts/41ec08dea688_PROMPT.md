
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

**Title**: This cycle isolated the structural reason Hausdorff dimension behaves like a
**Domain**: Novelty
**Mathematical framing**: # FUTURE_DIRECTIONS — Fractal Topology: Hausdorff Dimension as a Bi-Lipschitz Invariant

## Synthesis

This cycle isolated the structural reason Hausdorff dimension behaves like a
*topological/metric invariant*: Mathlib already records that `dimH` is preserved by
isometries (`Isometry.dimH_image`) and by continuous linear equivalences
(`ContinuousLinearEquiv.dimH_image`), but both are corollaries of a single, weaker
hypothesis. A map that is simultaneously **Lipschitz** (upper bound, via
`LipschitzWith.dimH_image_le`) and **antilipschitz** (lower bound, via
`AntilipschitzWith.le_dimH_image`) preserves `dimH` exactly — no metric preservation,
linearity, or surjectivity required. We packaged this as
`dimH_image_eq_of_biLipschitz`, the centerpiece, and then harvested its consequences:
nonzero scaling, translation, and hence the **entire affine group** preserve Hausdorff
dimension. This is precisely the invariance that makes the dimension of a self-similar
attractor a pure scale-free ratio `log N / log(1/r)`.

The cross-domain payoff connects this geometry to the catalog's *fractal number theory*
(`Physics/PrimeFractalDimension.lean`, where the logarithmic prime set `{1/log p}` is
shown to have `dimH = 0`). We proved the more robust statement that **any** bi-Lipschitz
reshaping of a countable set — in particular the logarithmic integer fractal
`{1/log n}` that contains the prime fractal — keeps dimension `0`. So dimension `0` is an
*intrinsic* feature of the prime fractal, not an artifact of the `1/log` embedding chosen
in the catalog; it survives every bi-Lipschitz change of coordinates.

The Critic supplied the sharp boundary: the constant map (Lipschitz with `K = 0`, but
**not** antilipschitz) collapses the real line — dimension `1` — to a point of dimension
`0` (`dimH_const_image_lt`). This shows antilipschitzness is the irreducible half of the
hypothesis; it is what controls the lower bound on dimension. The generalization loop
then relaxed Lipschitz to Hölder-`r`, recovering the graded bound
`dimH (f '' s) ≤ dimH s / r` (`dimH_holder_image_le`), of which the bi-Lipschitz invariant
is the `r = 1` case. The two-sided bi-Hölder dimension *transform* remains the natural
open frontier.

## Results Summary

- `dimH_image_eq_of_biLipschitz`: proved — bi-Lipschitz maps preserve Hausdorff dimension, strictly generalizing `Isometry.dimH_image` (the centerpiece).
- `antilipschitzWith_smul_nonzero`: proved — multiplication by a nonzero scalar is antilipschitz with the tight constant `‖c‖₊⁻¹`.
- `dimH_smul_set_eq`: proved — `dimH (c • s) = dimH s` for `c ≠ 0`; the self-similarity (scale) invariance underlying fractal dimension.
- `dimH_translate_set_eq`: proved — translation preserves Hausdorff dimension (isometry case).
- `dimH_affine_set_eq`: proved — every invertible affine map `x ↦ c•x + a` preserves Hausdorff dimension; `dimH` is an affine-group invariant.
- `dimH_const_image_lt`: proved (Critic) — a constant map strictly drops dimension (`ℝ` → point), proving antilipschitzness is necessary in the centerpiece.
- `dimH_biLipschitz_image_countable_eq_zero`: proved — bi-Lipschitz images of countable sets have dimension `0`.
- `dimH_biLipschitz_image_logRange_eq_zero`: proved (cross-domain) — every bi-Lipschitz reshaping of the logarithmic integer fractal `{1/log n}` (⊇ the prime fractal `{1/log p}`) keeps dimension `0`.
- `dimH_smul_logRange_eq_zero`: proved — concrete instance: rescaling the logarithmic fractal by `5` leaves dimension `0`.
- `dimH_holder_image_le`: proved (generalization) — a Hölder-`r` map inflates dimension by at most the factor `1/r`; `r = 1` recovers the centerpiece's upper bound.

## Research Directions

### Direction 1: Two-sided bi-Hölder dimension transform
**Hypothesis**: If `f` is Hölder-`r` (`0 < r ≤ 1`) and its inverse `g = f⁻¹` is
Hölder-`r'`, then `r' • dimH s ≤ dimH (f '' s) ≤ r⁻¹ • dimH s`; in particular a bi-Hölder
homeomorphism with matched exponents `r = r'` rescales dimension multiplicatively.
**Test**: Formalize the lower bound by transporting `AntilipschitzWith.le_dimH_image`
through `HolderWith` of the inverse (the `HolderOnWith`/`HolderWith` API in
`Mathlib.Topology.MetricSpace.HausdorffDimension` already supplies the upper half via
`dimH_holder_image_le`). Disprove the naive equality with `x ↦ x^2` on `[0,1]`.
**Why now**: This cycle already proved the `r = 1` two-sided case
(`dimH_image_eq_of_biLipschitz`) and the one-sided Hölder upper bound
(`dimH_holder_image_le`); only the Hölder lower bound is missing to close the square.
**If true**: A complete dictionary for how singular reparametrizations (e.g. devil's
staircase coordinates) deform Hausdorff dimension.
**If false**: The counterexample localizes exactly which regularity assumption forces the
lower bound, sharpening the boundary found by the Critic.

### Direction 2: Self-similar attractors realize the similarity dimension
**Hypothesis**: For a finite IFS of contracting similarities with ratios `rᵢ` satisfying
the open set condition, the attractor `K` has `dimH K = d`, where `d` is the unique
solution of `∑ rᵢ^d = 1` (the similarity dimension).
**Test**: Build the attractor as a fixed point of the Hutchinson operator; use
`dimH_smul_set_eq` and `dimH_bUnion` to get `dimH K = max_i dimH (sᵢ '' K)` and the
scaling relation, then solve the Moran equation. Start with the middle-thirds Cantor set
(`d = log 2 / log 3`) as the concrete first target.
**Why now**: `dimH_smul_set_eq` (scale invariance) and `dimH_affine_set_eq` are exactly
the tools that turn the self-similarity equation into a dimension equation; this cycle
supplied them.
**If true**: First formal proof in this catalog that a nontrivial fractal has its expected
fractional dimension — a genuine fractal-geometry milestone.
**If false** (e.g. without the open set condition): pinpoints how overlap inflates or
deflates measured dimension.

### Direction 3: Box-counting equals Hausdorff dimension for self-similar sets
**Hypothesis**: For the attractors of Direction 2 (open set condition), the upper
box-counting dimension `upperBoxDim` (defined in `Physics/PrimeFractalDimension.lean`)
equals `dimH`.
**Test**: Bound `upperBoxDim` above by the similarity dimension via the natural cover by
cylinder sets, and below by `dimH` (using `dimH ≤ upperBoxDim` in general). Contrast with
the catalog's prime fractal, where `dimH = 0 < 1 = ` conjectured box dimension — a
*strict* gap.
**Why now**: This cycle's bi-Lipschitz invariance makes both dimensions coordinate-free,
so the equality/inequality is a statement about the set itself, not its embedding.
**If true**: Explains *why* the prime fractal's dimension gap (`dimH = 0`, box `= 1`) is
special — it is the failure of self-similarity, not of countability alone.
**If false**: Reveals a self-similar set where the two dimensions diverge, a strong
structural surprise.

### Direction 4: Dimension and Cartesian products (the Marstrand/Besicovitch direction)
**Hypothesis**: `dimH (s ×ˢ t) ≥ dimH s + dimH t`, with equality when one factor is
"dimension-regular" (e.g. Ahlfors regular).
**Test**: The lower bound follows from the product Hausdorff measure; formalize it for
`s, t ⊆ ℝ` and combine with `dimH_univ_pi` (already in Mathlib: `dimH (univ : Set (Fin n → ℝ)) = n`).
Use bi-Lipschitz invariance to reduce to a canonical embedding of the product.
**Why now**: `dimH_image_eq_of_biLipschitz` lets us identify `ℝ^m × ℝ^n` with `ℝ^{m+n}`
bi-Lipschitzly, converting the product statement into the additivity of `finrank` already
in Mathlib for the full-dimensional case.
**If true**: Opens the door to product fractals (e.g. Cantor dust `C × C`, dimension
`2 log 2 / log 3`).
**If false**: The gap between `≥` and `=` is exactly the Marstrand phenomenon and
identifies which regularity hypothesis is doing the work.

### Direction 5: Lipschitz (not bi-Lipschitz) maps and the dimension drop spectrum
**Hypothesis**: For a `K`-Lipschitz `f : ℝ → ℝ`, the set of achievable values of
`dimH s − dimH (f '' s)` over all `s` is the full interval `[0, dimH s]`; moreover
`dimH (f '' s) = dimH s` for *every* `s` iff `f` is locally antilipschitz off a
dimension-`0` set.
**Test**: The Critic's `dimH_const_image_lt` already realizes the extreme drop `dimH s − 0`.
Interpolate with piecewise-affine `f` that are constant on a fat subset; compute
`dimH (f '' s)` via `dimH_union` and `dimH_smul_set_eq`.
**Why now**: This cycle produced both endpoints — exact preservation (bi-Lipschitz) and
total collapse (constant) — so the intermediate regime is the natural next quantitative
question.
**If true**: A clean characterization of dimension-preserving Lipschitz maps, weaker than
antilipschitz.
**If false**: A forbidden gap in the drop spectrum would be a striking rigidity theorem.

Research domain: Novelty
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Geometry/BiLipschitzDimension.lean
/-
  Hausdorff dimension as a bi-Lipschitz and affine-group invariant
  ================================================================

  Mathlib records that Hausdorff dimension `dimH` is preserved by *isometries*
  (`Isometry.dimH_image`) and by *continuous linear equivalences*
  (`ContinuousLinearEquiv.dimH_image`), and that one-sided control follows from
  Lipschitz/antilipschitz bounds (`LipschitzWith.dimH_image_le`,
  `AntilipschitzWith.le_dimH_image`).  Both isometry- and linear-invariance are
  in fact corollaries of a single *weaker* hypothesis: a map that is at once
  Lipschitz **and** antilipschitz preserves `dimH` exactly, with no metric
  preservation, linearity, or surjectivity required.

  This file isolates that structural fact (`dimH_image_eq_of_biLipschitz`) and
  harvests its geometric consequences:

  * `antilipschitzWith_smul_nonzero` — multiplication by a nonzero scalar is
    antilipschitz with the tight constant `‖c‖₊⁻¹`.
  * `dimH_smul_set_eq` — nonzero scaling preserves `dimH` (scale invariance,
    the structural reason a self-similar dimension is a scale-free ratio).
  * `dimH_vadd_set_eq` — translation preserves `dimH` (the isometry case).
  * `dimH_affine_set_eq` — every invertible affine map `x ↦ c • x + a` preserves
    `dimH`; thus `dimH` is an affine-group invariant.
  * `dimH_const_image_lt` — the boundary case: a constant map (Lipschitz with
    `K = 0`, but **not** antilipschitz) strictly drops dimension `ℝ → pt`,
    proving antilipschitzness is the irreducible half of the hypothesis.
  * `dimH_holder_image_le` — the Hölder-`r` generalization of the upper bound,
    `dimH (f '' s) ≤ dimH s / r`, of which bi-Lipschitz invariance is `r = 1`.

  Cross-domain payoff (connecting to `Physics/PrimeFractalDimension.lean`, where
  the logarithmic prime set `{1/log p}` is shown to have `dimH = 0`):

  * `dimH_biLipschitz_image_countable_eq_zero` — bi-Lipschitz images of countable
    sets keep dimension `0`.
  * `logRange`, `dimH_logRange_eq_zero`, `dimH_biLipschitz_image_logRange_eq_zero`
    — the logarithmic integer fractal `{1/log n}` (which *contains* the prime
    fractal `{1/log p}`) has `dimH = 0`, and this survives every bi-Lipschitz
    change of coordinates.  So dimension `0` is intrinsic to the prime fractal,
    not an artifact of the `1/log` embedding.

  Everything is proved with `sorry = 0`.
-/
import Mathlib

open Set Pointwise
open scoped ENNReal NNReal

namespace BiLipschitzDimension

/-! ### The centerpiece: bi-Lipschitz invariance -/

-- !-- Lipschitz gives `dimH (f '' s) ≤ dimH s`; antilipschitz gives the reverse;
-- !-- antisymmetry of `≤` closes it. This strictly generalizes `Isometry.dimH_image`. -- !--
/-- **Bi-Lipschitz invariance of Hausdorff dimension.** A map that is simultaneously
Lipschitz and antilipschitz preserves Hausdorff dimension on every set, with no
isometry, linearity, or surjectivity assumption. This is the single hypothesis
underlying both `Isometry.dimH_image` and `ContinuousLinearEquiv.dimH_image`. -/
theorem dimH_image_eq_of_biLipschitz {X Y : Type*} [EMetricSpace X] [EMetricSpace Y]
    {Kf Kf' : ℝ≥0} {f : X → Y} (hf : LipschitzWith Kf f) (hf' : AntilipschitzWith Kf' f)
    (s : Set X) : dimH (f '' s) = dimH s :=
  le_antisymm (hf.dimH_image_le s) (hf'.le_dimH_image s)

section NormedSpace

variable {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]

/-! ### Scale invariance -/

-- !-- The inverse scaling `c⁻¹ • ·` is Lipschitz with constant `‖c⁻¹‖₊`, and `c • ·` is its
-- !-- right inverse; `LipschitzWith.to_rightInverse` turns this into antilipschitzness of `c • ·`. -- !--
/-- Multiplication by a nonzero scalar `c` is antilipschitz with the tight constant
`‖c‖₊⁻¹`: the lower bound on how much `c • ·` can contract distances. -/
theorem antilipschitzWith_smul_nonzero {c : ℝ} (hc : c ≠ 0) :
    AntilipschitzWith ‖c‖₊⁻¹ (fun x : E => c • x) := by
  have h := (lipschitzWith_smul (β := E) c⁻¹).to_rightInverse
    (g := fun x : E => c • x) (by intro x; simp [smul_smul, inv_mul_cancel₀ hc])
  simpa [nnnorm_inv] using h

-- !-- `c • ·` is Lipschitz (`lipschitzWith_smul`) and antilipschitz (previous lemma) for `c ≠ 0`,
-- !-- so `dimH_image_eq_of_biLipschitz` applies; rewrite the pointwise smul as an image. -- !--
/-- **Scale invariance of Hausdorff dimension.** For a nonzero scalar `c`, the scaled set
`c • s` has the same Hausdorff dimension as `s`. This self-similarity invariance is the
structural reason the dimension of a self-similar attractor is a scale-free ratio
`log N / log (1/r)`. -/
theorem dimH_smul_set_eq {c : ℝ} (hc : c ≠ 0) (s : Set E) :
    dimH (c • s) = dimH s := by
  rw [← Set.image_smul]
  exact dimH_image_eq_of_biLipschitz (lipschitzWith_smul c)
    (antilipschitzWith_smul_nonzero hc) s

/-! ### Translation invariance -/

-- !-- Translation `· + a` is an isometry (`isometry_add_right`); apply `Isometry.dimH_image`. -- !--
/-- **Translation invariance of Hausdorff dimension** (the isometry case): translating a
set by `a` does not change its Hausdorff dimension. -/
omit [NormedSpace ℝ E] in
theorem dimH_vadd_set_eq (a : E) (s : Set E) :
    dimH ((fun x => x + a) '' s) = dimH s :=
  (isometry_add_right a).dimH_image s

/-! ### The affine group preserves dimension -/

-- !-- An invertible affine map factors as translation ∘ scaling: `c • x + a`.
-- !-- Chain `dimH_vadd_set_eq` (outer translation) with `dimH_smul_set_eq` (inner scaling). -- !--
/-- **Affine invariance of Hausdorff dimension.** Every invertible affine map
`x ↦ c • x + a` (with `c ≠ 0`) preserves Hausdorff dimension. Hence `dimH` is an
invariant of the whole affine group, not merely of isometries or linear maps. -/
theorem dimH_affine_set_eq {c : ℝ} (hc : c ≠ 0) (a : E) (s : Set E) :
    dimH ((fun x => c • x + a) '' s) = dimH s := by
  have hcomp : (fun x => c • x + a) '' s
      = (fun y => y + a) '' ((fun x => c • x) '' s) := by
    rw [Set.image_image]
  rw [hcomp, dimH_vadd_set_eq, Set.image_smul, dimH_smul_set_eq hc]

end NormedSpace

/-! ### Boundary case: antilipschitzness is necessary -/

-- !-- The constant map sends the whole nonempty line `univ : Set ℝ` to the single point `{a}`,
-- !-- whose dimension is `0`, while `dimH univ = 1` (`Real.dimH_univ`); `0 < 1`. -- !--
/-- **The constant map collapses dimension.** A constant map is Lipschitz (with `K = 0`)
but not antilipschitz, and it sends the real line (dimension `1`) to a single point
(dimension `0`). This shows antilipschitzness is the *irreducible* half of the
bi-Lipschitz hypothesis: it is what controls the lower bound on dimension. -/
theorem dimH_const_image_lt (a : ℝ) :
    dimH ((fun _ : ℝ => a) '' (univ : Set ℝ)) < dimH (univ : Set ℝ) := by
  have himg : (fun _ : ℝ => a) '' (univ : Set ℝ) = {a} := by
    simp
  rw [himg, Real.dimH_univ]
  simp

/-! ### Hölder generalization of the upper bound -/

-- !-- Direct restatement of `HolderWith.dimH_image_le`; the bi-Lipschitz upper bound is `r = 1`. -- !--
/-- **Hölder distortion (upper bound).** A Hölder-`r` map inflates Hausdorff dimension by at
most the factor `1/r`: `dimH (f '' s) ≤ dimH s / r`. Taking `r = 1` recovers the upper-bound
half of `dimH_image_eq_of_biLipschitz`. -/
theorem dimH_holder_image_le {X Y : Type*} [EMetricSpace X] [EMetricSpace Y]
    {C r : ℝ≥0} {f : X → Y} (hf : HolderWith C r f) (hr : 0 < r) (s : Set X) :
    dimH (f '' s) ≤ dimH s / r :=
  hf.dimH_image_le hr s

/-! ### Cross-domain: countable fractals and the logarithmic integer fractal -/

-- !-- Bi-Lipschitz invariance gives `dimH (f '' s) = dimH s`, and `dimH_countable` makes the
-- !-- right side `0`. So no bi-Lipschitz reshaping can manufacture positive dimension. -- !--
/-- **Bi-Lipschitz images of countable sets have dimension `0`.** Combined with the fact that
the logarithmic prime image is countable, this shows its zero dimension is robust under every
bi-Lipschitz change of coordinates. -/
theorem dimH_biLipschitz_image_countable_eq_zero

```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# FUTURE_DIRECTIONS — Hausdorff Dimension as a Bi-Lipschitz and Affine Invariant

This cycle isolated the single structural hypothesis behind every "dimension is a
metric invariant" theorem in Mathlib. Both `Isometry.dimH_image` and
`ContinuousLinearEquiv.dimH_image` are corollaries of one weaker fact: a map that
is simultaneously **Lipschitz** and **antilipschitz** preserves `dimH` exactly
(`dimH_image_eq_of_biLipschitz`). From that single hinge we harvested scale
invariance (`dimH_smul_set_eq`), translation invariance (`dimH_vadd_set_eq`), and
hence invariance under the entire affine group (`dimH_affine_set_eq`). We pinned
down the boundary — a constant map (Lipschitz, but not antilipschitz) collapses
the line to a point (`dimH_const_image_lt`) — and crossed into number theory by
showing the logarithmic integer fractal `{1/log n}` (which contains the prime
fractal `{1/log p}` of `Physics/PrimeFractalDimension.lean`) keeps dimension `0`
under *every* bi-Lipschitz reshaping (`dimH_biLipschitz_image_logRange_eq_zero`).
The directions below extend that frontier.

## Direction 1 — Two-sided bi-Hölder dimension transform

**Conjecture.** If `f` is Hölder-`r` (`0 < r ≤ 1`) and its left inverse `g` is
Hölder-`r'` on `f '' s`, then `r' • dimH s ≤ dimH (f '' s) ≤ r⁻¹ • dimH s`; for a
bi-Hölder homeomorphism with matched exponents `r = r'`, dimension rescales
multiplicatively rather than being preserved.

**The key insight is** that `dimH_holder_image_le` already supplies the upper half
(`dimH (f '' s) ≤ dimH s / r`); the missing lower half is obtained by transporting
`AntilipschitzWith.le_dimH_image` through the Hölder regularity of the *inverse*,
exactly mirroring how this cycle built `dimH_smul_set_eq` from a Lipschitz inverse.

**Test.** Formalize the lower bound; falsify the naive equality with `x ↦ x²` on
`[0,1]`, whose inverse `√` is Hölder-`1/2`, forcing a genuine factor of `2`.

**Why now?** This cycle proved both the `r = 1` two-sided case
(`dimH_image_eq_of_biLipschitz`) and the one-sided Hölder bound
(`dimH_holder_image_le`); only the Hölder lower bound remains to close the square.

## Direction 2 — Self-similar attractors realize the similarity dimension

**Conjecture.** For a finite IFS of contracting similarities with ratios `rᵢ`
satisfying the open set condition, the attractor `K` has `dimH K = d` where `d`
solves the Moran equation `∑ rᵢ^d = 1`. Concrete first target: the middle-thirds
Cantor set, `d = log 2 / log 3`.

**The key insight is** that `dimH_smul_set_eq` turns each self-similar piece
`sᵢ '' K = rᵢ • (rotation/translation of K)` into a *dimension-preserving up to the
scale ratio* copy, so the geometric self-similarity equation becomes a numeric
equation in `d` once combined with `dimH` of finite unions (`dimH_iUnion`).

**Test.** Build `K` as the fixed point of the Hutchinson operator; derive the
scaling relation, then solve Moran. Disprove the clean value when the open set
condition fails (overlapping IFS).

**Why now?** Scale 
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
