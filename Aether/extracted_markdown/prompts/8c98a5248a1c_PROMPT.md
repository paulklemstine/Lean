
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

**Title**: The persistence-stability arc of the catalog climbed a ladder of structure: a
**Domain**: Shared
**Mathematical framing**: # Future Directions — Boltzmann Bridge XI: Convexity & Bicombing of Interleaving Geodesics

## Synthesis

The persistence-stability arc of the catalog climbed a ladder of structure: a
relational preorder (`BottleneckStability`), a pseudo-emetric
(`InterleavingMetric`), a genuine `EMetricSpace` (`InterleavingClosure`), an exact
isometry onto weight functions under the sup-distance (`InterleavingIsometry`:
`eInterleavingDist_eq_weightSupEDist`), an explicit constant-speed geodesic
(`InterleavingGeodesic`: `lerp`, `eInterleavingDist_lerp`), and a self-coherent
field of geodesics glued affinely (`InterleavingGeodesicGluing`: `lerp_lerp`).

Bridge XI (`InterleavingGeodesicConvexity.lean`) supplies the **curvature** layer.
Where Bridges IX–X studied a single geodesic and its reparametrisations, Bridge XI
compares *different* geodesics and proves the interleaving metric is **convex** in
the strong sense of admitting a convex geodesic bicombing:

> `d(lerp F G t, lerp F' G' t) ≤ ofReal (1−t)·d(F,F') + ofReal t·d(G,G')`.

Two geodesics run by the same clock never separate faster than the convex
combination of the distances between their endpoints — the defining inequality of a
Busemann (non-positively curved) space. Specialising one geodesic to a constant
point (`lerp H H t = H`) recovers ordinary convexity of the distance to a fixed
filtration along a geodesic. The whole result is, once again, the Bridge VIII
sup-isometry transporting a single elementary fact — the triangle inequality for
real absolute values, `|(1−t)a + tb| ≤ (1−t)|a| + t|b|` — through a supremum.

## Results summary

* `lerp_reverse` — the affine reversal symmetry `lerp F G t = lerp G F (1−t)`.
* `lerp_self` — constant geodesics are stationary, `lerp F F t = F`.
* `weightSupEDist_lerp_bicombing` — the convexity bound at the sup-distance level.
* `eInterleavingDist_lerp_bicombing` — the convex geodesic bicombing inequality
  (Busemann convexity of the interleaving metric).
* `eInterleavingDist_lerp_convex` — convexity of the distance to a fixed filtration
  along the geodesic, as the constant-geodesic special case.

All five are proved `sorry`-free over an arbitrary index type `α`, building on
`eInterleavingDist_lerp` (Bridge IX), `lerp_lerp` (Bridge X), and the isometry
`eInterleavingDist_eq_weightSupEDist` (Bridge VIII).

## Falsifiable research directions

### Direction 1 — Bundle a `ConvexGeodesicBicombing` and certify it as a Busemann space

Bridge X gave reparametrisation-consistency (`lerp_lerp`) and Bridge XI gives the
convexity bound (`eInterleavingDist_lerp_bicombing`); together these are exactly the
two axioms of a *consistent convex geodesic bicombing* in the sense of Descombes–Lang.
The conjecture: `lerp` assembles into a single bundled structure
`σ : Filtration α × Filtration α → ℝ≥0∞-geodesic` that is simultaneously consistent
(`σ` restricts to itself, from `lerp_lerp`) and conical/convex (from the bicombing
bound), making `(Filtration α, eInterleavingDist)` a *Busemann space* and hence
contractible with unique geodesics between distinct distance-zero classes. **The key
insight is** that bicombing consistency is an *affine* identity at the weight-function
level while convexity is a *metric* inequality read off through the sup-isometry, so
the two axioms live in genuinely different layers and can be discharged independently
before being glued. **Why now?** Both axioms are already proved in isolation
(`lerp_lerp`, `eInterleavingDist_lerp_bicombing`); only the packaging into Mathlib's
bicombing vocabulary remains, and it is falsifiable — if the conical inequality failed
to be *consistent* with the reparametrisation, the bundle would not typecheck.

### Direction 2 — Strict-convexity defect is exactly the multiplicity of supremising simplices

The bicombing bound is an inequality, not the equality of the constant-speed law
`eInterleavingDist_lerp`. Conjecture: equality
`d(lerp F G t, lerp F' G' t) = ofReal (1−t)·d(F,F') + ofReal t·d(G,G')` holds **iff**
there is a single simplex `σ` that simultaneously realises both endpoint suprema
`d(F,F')` and `d(G,G')` with matching signs of the weight gaps; otherwise the bound is
strict. **The key insight is** that an ℓ^∞-type (sup-normed) geometry is flat-convex
but never strictly convex, and the precise location of the convexity *defect* is the
combinatorial event "the argmax simplex of one geodesic differs from the other's."
**Why now?** Bridge XI already isolates the per-simplex triangle inequality as the only
nontrivial step, so the equality case is a finite, decidable side-condition on a pair of
`Finset α` argmaxes — directly testable on the catalog's concrete `3`-point clouds
(`cloud₁`, `cloud₂`) via `#eval`, and falsifiable by exhibiting one cloud pair where the
two argmaxes coincide yet equality still fails.

### Direction 3 — 1-Lipschitz nonexpansiveness of the bicombing in all four endpoints

Conjecture: the map `(F, G) ↦ lerp F G t` is jointly `1`-Lipschitz, i.e. the bicombing
endpoints depend nonexpansively on the data:
`d(lerp F G t, lerp F' G' t) ≤ max (d(F,F')) (d(G,G'))` for every `t ∈ [0,1]`, a
sharpening of the convex bound (since a convex combination is `≤` the max). **The key
insight is** that in a sup-normed space the convex-combination bound and the max bound
*coincide at the supremising simplex*, so nonexpansiveness should be readable from the
same per-simplex estimate by replacing `add_le_add` with `sup_le`. **Why now?** The
proof skeleton of `weightSupEDist_lerp_bicombing` already produces the two endpoint
suprema separately; swapping the final `+` for `⊔` is a one-line structural change, and
the claim is falsifiable — if true it upgrades `lerp` to a nonexpansive retraction,
yielding contractibility of the metric quotient for free.

### Direction 4 — A reverse (lower) bicombing bound and a two-sided sandwich

The upper bicombing bound has a conjectural mirror: for the *same-clock* geodesics,
`|d(F,F') − d(G,G')| · something ≤ d(lerp F G t, lerp F' G' t)`, giving a two-sided
sandwich that pins the bicombing distance to within a computable band. Concretely we
conjecture `ofReal (1−t)·d(F,F') ⊖ ofReal t·d(G,G') ≤ d(lerp F G t, lerp F' G' t)`
(truncated subtraction in `ℝ≥0∞`), the reverse triangle inequality lifted through the
sup. **The key insight is** that the supremum of `|(1−t)a + tb|` is bounded *below* by
the reverse triangle inequality `|(1−t)|a| − t|b||` at the dominant simplex, so the same
isometry that gives the upper bound gives a matching lower bound on a possibly different
simplex. **Why now?** Mathlib's `ENNReal` truncated subtraction and `tsub` lemmas make
the lower bound formally expressible without leaving the extended reals, and the
two-sided form is immediately falsifiable on the concrete clouds where all four
distances are explicit rationals.

### Direction 5 — Convexity descends to the metric quotient and to the Vietoris–Rips locus

`InterleavingQuotient` already constructs the `EMetricSpace` quotient that separates
distance-zero filtrations. Conjecture: `lerp` and the bicombing bound descend to this
quotient (well-definedness of convex interpolation modulo the distance-zero kernel),
making the *quotient* a genuine Busemann space; and, more ambitiously, that the
restriction of `lerp` to the Vietoris–Rips locus (`diamFiltrationOf` of a distance
matrix) stays inside the locus, so VR-persistence is itself a convex sub-geometry.
**The key insight is** that convexity is a `⨆`-level inequality insensitive to the
distance-zero kernel, so it should pass to the quotient verbatim, whereas the VR-locus
question is genuinely harder because a convex combination of two *diameter* weights need
not be a diameter weight of any single matrix. **Why now?** The quotient machinery is in
hand (`InterleavingQuotient`) and the descent is a routine `Quotient.lift` once
well-definedness is checked; the VR question is sharply falsifiable — a single pair of
`3`-point clouds whose midpoint weight is provably not realised by any distance matrix
would refute the locus-convexity half while leaving the quotient half intact.

Research domain: Shared
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Applications/BoltzmannBridge/InterleavingGeodesicConvexity.lean
/-
# The Boltzmann Bridge XI — Convexity & Bicombing of Interleaving Geodesics

Bridges IX–X (`Applications.BoltzmannBridge.InterleavingGeodesic`,
`Applications.BoltzmannBridge.InterleavingGeodesicGluing`) studied a *single*
geodesic `lerp F G` and its reparametrisations.  Bridge XI supplies the
**curvature** layer: it compares *different* geodesics run by the *same* clock and
proves the interleaving metric is **convex** in the strong sense of admitting a
convex geodesic bicombing:

> `d(lerp F G t, lerp F' G' t) ≤ ofReal (1−t)·d(F,F') + ofReal t·d(G,G')`.

Two geodesics run by the same clock never separate faster than the convex
combination of the distances between their endpoints — the defining inequality of a
Busemann (non-positively curved) space.  Specialising one geodesic to a constant
point (`lerp H H t = H`, `lerp_self`) recovers ordinary convexity of the distance to
a fixed filtration along a geodesic.  The whole result is, once again, the Bridge
VIII sup-isometry (`eInterleavingDist_eq_weightSupEDist`) transporting a single
elementary fact — the triangle inequality for real absolute values,
`|(1−t)a + tb| ≤ (1−t)|a| + t|b|` — through a supremum.

## Main results

* `lerp_reverse` — the affine reversal symmetry `lerp F G t = lerp G F (1−t)`.
* `lerp_self` — constant geodesics are stationary, `lerp F F t = F`.
* `weightSupEDist_lerp_bicombing` — the convexity bound at the sup-distance level.
* `eInterleavingDist_lerp_bicombing` — the convex geodesic bicombing inequality
  (Busemann convexity of the interleaving metric).
* `eInterleavingDist_lerp_convex` — convexity of the distance to a fixed filtration
  along the geodesic, as the constant-geodesic special case.
-/
import Mathlib
import Applications.BoltzmannBridge.HigherPersistence
import Applications.BoltzmannBridge.PersistenceStability
import Applications.BoltzmannBridge.BottleneckStability
import Applications.BoltzmannBridge.InterleavingMetric
import Applications.BoltzmannBridge.InterleavingClosure
import Applications.BoltzmannBridge.InterleavingIsometry
import Applications.BoltzmannBridge.InterleavingGeodesic
import Applications.BoltzmannBridge.InterleavingGeodesicGluing

open Finset BigOperators
open scoped ENNReal

namespace BoltzmannBridge

namespace Filtration

variable {α : Type*}

/-! ## Affine symmetries of the geodesic -/

-- !-- `ext_weight`; pointwise `(1−t)F + tG = (1−(1−t))G + (1−t)F` by `ring`. -- !--
/-- **Affine reversal symmetry.**  Running the geodesic from `G` to `F` with the
reversed clock `1 − t` traces the *same* points: `lerp F G t = lerp G F (1 − t)`. -/
theorem lerp_reverse (F G : Filtration α) {t : ℝ} (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    lerp F G t ht0 ht1 = lerp G F (1 - t) (by linarith) (by linarith) := by
  apply ext_weight; funext σ; simp only [lerp_weight]; ring

-- !-- `ext_weight`; pointwise `(1−t)F + tF = F` by `ring`. -- !--
/-- **Constant geodesics are stationary.**  Interpolating a filtration with itself
never moves: `lerp F F t = F` for every `t`. -/
theorem lerp_self (F : Filtration α) {t : ℝ} (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    lerp F F t ht0 ht1 = F := by
  apply ext_weight; funext σ; simp only [lerp_weight]; ring

/-! ## The convex geodesic bicombing -/

-- !-- `iSup_le`: for each `σ`, the per-simplex gap factors as
-- !-- `|(1−t)(F−F') + t(G−G')| ≤ (1−t)|F−F'| + t|G−G'|` (`abs_add`, `abs_mul`,
-- !-- nonnegativity of `1−t, t`).  Push `ofReal` through the sum/products and dominate
-- !-- each weight gap by its `weightSupEDist` supremum (`le_iSup`), then `gcongr`. -- !--
/-- **Convexity bound at the sup-distance level.**  The sup-distance between two
same-clock interpolants is bounded by the convex combination of the endpoint
sup-distances. -/
theorem weightSupEDist_lerp_bicombing (F G F' G' : Filtration α) {t : ℝ}
    (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    weightSupEDist (lerp F G t ht0 ht1) (lerp F' G' t ht0 ht1)
      ≤ ENNReal.ofReal (1 - t) * weightSupEDist F F'
        + ENNReal.ofReal t * weightSupEDist G G' := by
  refine' iSup_le _;
  intro σ
  have h_abs : |(F.lerp G t ht0 ht1).weight σ - (F'.lerp G' t ht0 ht1).weight σ| ≤ (1 - t) * |F.weight σ - F'.weight σ| + t * |G.weight σ - G'.weight σ| := by
    rw [ lerp_weight, lerp_weight ];
    cases abs_cases ( F.weight σ - F'.weight σ ) <;> cases abs_cases ( G.weight σ - G'.weight σ ) <;> cases abs_cases ( ( 1 - t ) * F.weight σ + t * G.weight σ - ( ( 1 - t ) * F'.weight σ + t * G'.weight σ ) ) <;> nlinarith;
  refine' le_trans ( ENNReal.ofReal_le_ofReal h_abs ) _;
  rw [ ENNReal.ofReal_add, ENNReal.ofReal_mul, ENNReal.ofReal_mul ] <;> try linarith;
  · gcongr; all_goals exact le_iSup_of_le σ ( by simp +decide );
  · exact mul_nonneg ( sub_nonneg.2 ht1 ) ( abs_nonneg _ );
  · positivity

-- !-- Rewrite the three distances via Bridge VIII's
-- !-- `eInterleavingDist_eq_weightSupEDist` and apply `weightSupEDist_lerp_bicombing`. -- !--
/-- **Convex geodesic bicombing (Busemann convexity).**  Two geodesics run by the
same clock never separate faster than the convex combination of the distances
between their endpoints:
`d(lerp F G t, lerp F' G' t) ≤ ofReal (1−t)·d(F,F') + ofReal t·d(G,G')`. -/
theorem eInterleavingDist_lerp_bicombing (F G F' G' : Filtration α) {t : ℝ}
    (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    eInterleavingDist (lerp F G t ht0 ht1) (lerp F' G' t ht0 ht1)
      ≤ ENNReal.ofReal (1 - t) * eInterleavingDist F F'
        + ENNReal.ofReal t * eInterleavingDist G G' := by
  -- Apply the isometry property to rewrite the goal in terms of weightSupEDist.
  rw [eInterleavingDist_eq_weightSupEDist, eInterleavingDist_eq_weightSupEDist,
    eInterleavingDist_eq_weightSupEDist]
  exact weightSupEDist_lerp_bicombing F G F' G' ht0 ht1

-- !-- Write `H = lerp H H t` (`lerp_self`) and apply `eInterleavingDist_lerp_bicombing`
-- !-- with `F' = G' = H`. -- !--
/-- **Convexity of the distance to a fixed filtration.**  Along the geodesic
`lerp F G`, the distance to any fixed filtration `H` is a convex function of the
parameter: `d(lerp F G t, H) ≤ ofReal (1−t)·d(F,H) + ofReal t·d(G,H)`.  This is the
constant-geodesic special case of the bicombing bound (`lerp H H t = H`). -/
theorem eInterleavingDist_lerp_convex (F G H : Filtration α) {t : ℝ}
    (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    eInterleavingDist (lerp F G t ht0 ht1) H
      ≤ ENNReal.ofReal (1 - t) * eInterleavingDist F H
        + ENNReal.ofReal t * eInterleavingDist G H := by
  convert eInterleavingDist_lerp_bicombing F G H H ht0 ht1 using 1;
  rw [ lerp_self ]

end Filtration

/-
-- !-- Lab Notebook -- !--

## Hypothesis
Bridges IX–X established that `(Filtration α, eInterleavingDist)` is geodesic with a
self-coherent field of geodesics `lerp`.  The adversarial hypothesis: the space is
not merely geodesic but *non-positively curved* in the Busemann sense, i.e. `lerp`
is a **convex geodesic bicombing** — two geodesics run by the same clock separate at
most as fast as the convex combination of their endpoint distances.

## Result
Confirmed.  `weightSupEDist_lerp_bicombing` is the convexity bound at the
sup-distance level; transported through the Bridge VIII isometry it becomes
`eInterleavingDist_lerp_bicombing`, the Busemann convexity inequality.  Specialising
one geodesic to a constant point (`lerp_self`: `lerp H H t = H`) yields
`eInterleavingDist_lerp_convex`, ordinary convexity of the distance to a fixed
filtration.  The affine reversal `lerp_reverse` records the segment's symmetry.

## Insight
Curvature, like geodesy (Bridge IX) and coherence (Bridge X), is *inherited through
the isometry*.  The only nontrivial step is the per-simplex triangle inequality for
real absolute values, `|(1−t)a + tb| ≤ (1−t)|a| + t|b|`; the supremum then preserves
the bound coordinatewise.  An ℓ^∞-type (sup-normed) geometry is flat-convex: the
bicombing inequality holds with the optimal convex coefficients, but it is never
*strict*, since the sup is attained on possibly different simplices for the
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — Boltzmann Bridge XI: Convexity & Bicombing of Interleaving Geodesics

## Synthesis

The persistence-stability arc of the catalog has climbed a ladder of structure: a
relational preorder (`BottleneckStability`), a pseudo-emetric
(`InterleavingMetric`), a genuine `EMetricSpace` (`InterleavingClosure`), an exact
isometry onto weight functions under the sup-distance (`InterleavingIsometry`:
`eInterleavingDist_eq_weightSupEDist`), an explicit constant-speed geodesic
(`InterleavingGeodesic`: `lerp`, `eInterleavingDist_lerp`), and a self-coherent
field of geodesics glued affinely (`InterleavingGeodesicGluing`: `lerp_lerp`).

Bridge XI (`InterleavingGeodesicConvexity.lean`) supplies the **curvature** layer.
Where Bridges IX–X studied a single geodesic and its reparametrisations, Bridge XI
compares *different* geodesics run by the same clock and proves the interleaving
metric is **convex** in the strong sense of admitting a convex geodesic bicombing:

> `d(lerp F G t, lerp F' G' t) ≤ ofReal (1−t)·d(F,F') + ofReal t·d(G,G')`.

Two geodesics run by the same clock never separate faster than the convex
combination of the distances between their endpoints — the defining inequality of a
Busemann (non-positively curved) space. Specialising one geodesic to a constant
point (`lerp H H t = H`) recovers ordinary convexity of the distance to a fixed
filtration along a geodesic. The whole result is, once again, the Bridge VIII
sup-isometry transporting a single elementary fact — the triangle inequality for
real absolute values, `|(1−t)a + tb| ≤ (1−t)|a| + t|b|` — through a supremum.

## Results summary

* `lerp_reverse` — the affine reversal symmetry `lerp F G t = lerp G F (1−t)`.
* `lerp_self` — constant geodesics are stationary, `lerp F F t = F`.
* `weightSupEDist_lerp_bicombing` — the convexity bound at the sup-distance level.
* `eInterleavingDist_lerp_bicombing` — the convex geodesic bicombing inequality
  (Busemann convexity of the interleaving metric).
* `eInterleavingDist_lerp_convex` — convexity of the distance to a fixed filtration
  along the geodesic, as the constant-geodesic special case.

All five are proved `sorry`-free over an arbitrary index type `α`, building on
`eInterleavingDist_lerp` (Bridge IX), `lerp_lerp` (Bridge X), and the isometry
`eInterleavingDist_eq_weightSupEDist` (Bridge VIII). Each depends only on the
standard kernel axioms (`propext`, `Classical.choice`, `Quot.sound`).

## Falsifiable research directions

### Direction 1 — Bundle a `ConvexGeodesicBicombing` and certify a Busemann space

Bridge X gave reparametrisation-consistency (`lerp_lerp`) and Bridge XI gives the
convexity bound (`eInterleavingDist_lerp_bicombing`); together these are exactly the
two axioms of a *consistent convex geodesic bicombing* in the sense of Descombes–Lang.
The conjecture: `lerp` assembles into a single bundled structure that is
simultaneously consistent (it restricts to itself, from `lerp_lerp`) and
conical/convex (from the bicombing 
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
