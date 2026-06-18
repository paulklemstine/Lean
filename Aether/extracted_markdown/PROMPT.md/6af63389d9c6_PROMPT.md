
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

**Title**: Deepening: `Applications/BoltzmannBridge/InterleavingGeodesic.lean` closes the
**Domain**: Applications
**Mathematical framing**: Building on cycle bc66959c (Q=0.775), which proved 69 theorems in Novelty. Go DEEPER: prove the strongest remaining conjecture, close open sorries, or extend the core result to a more general setting. Original direction: # Future Directions — Boltzmann Bridge IX: the Interleaving Metric is *Geodesic*

## Synthesis

`Applications/BoltzmannBridge/InterleavingGeodesic.lean` closes the
persistence-stability arc's metric story and opens its **homotopical** chapter.
The arc moved from a relational preorder (`BottleneckSta
Research domain: Applications
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Applications/BoltzmannBridge/InterleavingPathSpace.lean
/-
# The Boltzmann Bridge X — The Path Space of Filtrations

This file opens the **homotopical** chapter promised by Bridge IX
(`Applications.BoltzmannBridge.InterleavingGeodesic`).  Bridge IX produced the
first explicit *path of filtrations*, the convex-interpolation geodesic `lerp`,
and proved the constant-speed identity
`eInterleavingDist (lerp F G s) (lerp F G t) = ofReal |s − t| · eInterleavingDist F G`
(`eInterleavingDist_lerp`).  That established `(Filtration α, eInterleavingDist)`
is a geodesic space.

Bridge X studies the **structure of the path space** these geodesics generate:

* **Reparametrisation / path algebra** (`lerp_lerp`): the `lerp` family is closed
  under composition — a `lerp` of two `lerp`s is again a `lerp`, with parameter the
  affine combination `(1−t)·a + t·b`.  Sub-paths of geodesics are geodesics, so the
  geodesics form a reparametrisation-stable family (the combinatorial skeleton of a
  fundamental groupoid).
* **Metric betweenness** (`eInterleavingDist_lerp_betweenness`): for `s ≤ u ≤ t`
  the intermediate point `lerp F G u` lies *metrically between* the endpoints,
  `d(lerp s, lerp u) + d(lerp u, lerp t) = d(lerp s, lerp t)`.  This is the full
  geodesic-segment law generalising Bridge IX's midpoint bisection.
* **Geodesic convexity of the metric** (`eInterleavingDist_convex`): the distance
  to a fixed filtration is convex along `lerp`,
  `d(H, lerp F G t) ≤ ofReal(1−t)·d(H,F) + ofReal t·d(H,G)`.  This is the
  Busemann / non-positive-curvature-flavoured convexity inequality, inherited from
  the sup-distance via Bridge VIII (`eInterleavingDist_eq_weightSupEDist`).
* **The space is geodesic** (`exists_constantSpeed_geodesic`): a single bundled
  existence statement — between any two filtrations there is a path realising the
  interleaving distance at constant speed.

## Main results

* `lerp_self` — `lerp F F t = F` (degenerate geodesic).
* `lerp_lerp` — reparametrisation closure of the geodesic family.
* `eInterleavingDist_lerp_betweenness` — the geodesic-segment additivity law.
* `eInterleavingDist_convex` — convexity of the interleaving distance along `lerp`.
* `exists_constantSpeed_geodesic` — `(Filtration α, eInterleavingDist)` is geodesic.
-/
import Mathlib
import Applications.BoltzmannBridge.HigherPersistence
import Applications.BoltzmannBridge.InterleavingMetric
import Applications.BoltzmannBridge.InterleavingClosure
import Applications.BoltzmannBridge.InterleavingIsometry
import Applications.BoltzmannBridge.InterleavingGeodesic

open Finset BigOperators
open scoped ENNReal

namespace BoltzmannBridge

namespace Filtration

variable {α : Type*}

/-! ## Degenerate geodesic -/

-- !-- `(1−t)·F + t·F = F` pointwise; `ext_weight` then `ring`. -- !--
/-- The geodesic between a filtration and itself is constant. -/
@[simp] theorem lerp_self (F : Filtration α) {t : ℝ} (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    lerp F F t ht0 ht1 = F := by
  apply ext_weight; funext σ; simp only [lerp_weight]; ring

/-! ## Reparametrisation: the geodesic family is closed under composition -/

-- !-- Expand both layers: `lerp (lerp F G a) (lerp F G b) t` has weight
-- !-- `(1−t)[(1−a)F+aG] + t[(1−b)F+bG]`; collecting the `G`-coefficient gives
-- !-- `c := (1−t)a + t b`, and the `F`-coefficient is `1−c`, i.e. `lerp F G c`.
-- !-- `ext_weight` then `simp only [lerp_weight]; ring`. -- !--
/-- **Reparametrisation closure of the geodesic family.**  A `lerp` of two points on
the `F`–`G` geodesic is again a point on that geodesic, at the affine parameter
`(1−t)·a + t·b`.  Hence the geodesics are stable under reparametrisation and
composition — the combinatorial skeleton of a path groupoid. -/
theorem lerp_lerp (F G : Filtration α) {a b t : ℝ}
    (ha0 : 0 ≤ a) (ha1 : a ≤ 1) (hb0 : 0 ≤ b) (hb1 : b ≤ 1)
    (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    lerp (lerp F G a ha0 ha1) (lerp F G b hb0 hb1) t ht0 ht1
      = lerp F G ((1 - t) * a + t * b)
          (by nlinarith) (by nlinarith) := by
  apply ext_weight; funext σ; simp only [lerp_weight]; ring

/-! ## Metric betweenness: the geodesic-segment law -/

-- !-- Rewrite all three distances through `eInterleavingDist_lerp`; with `s ≤ u ≤ t`
-- !-- the absolute values resolve to `u−s`, `t−u`, `t−s`.  Factor `d := d(F,G)` out via
-- !-- `← add_mul`, sum the `ofReal` shifts with `← ENNReal.ofReal_add` (`(u−s)+(t−u)=t−s`). -- !--
/-- **The geodesic-segment law (metric betweenness).**  For `s ≤ u ≤ t` in `[0,1]`,
the point `lerp F G u` lies metrically between `lerp F G s` and `lerp F G t`:
`d(lerp s, lerp u) + d(lerp u, lerp t) = d(lerp s, lerp t)`.  This generalises
Bridge IX's `eInterleavingDist_midpoint` to an arbitrary intermediate parameter and
is the defining additivity property of a geodesic segment. -/
theorem eInterleavingDist_lerp_betweenness (F G : Filtration α) {s u t : ℝ}
    (hs0 : 0 ≤ s) (hs1 : s ≤ 1) (hu0 : 0 ≤ u) (hu1 : u ≤ 1)
    (ht0 : 0 ≤ t) (ht1 : t ≤ 1) (hsu : s ≤ u) (hut : u ≤ t) :
    eInterleavingDist (lerp F G s hs0 hs1) (lerp F G u hu0 hu1)
      + eInterleavingDist (lerp F G u hu0 hu1) (lerp F G t ht0 ht1)
      = eInterleavingDist (lerp F G s hs0 hs1) (lerp F G t ht0 ht1) := by
  rw [eInterleavingDist_lerp, eInterleavingDist_lerp, eInterleavingDist_lerp,
      abs_of_nonpos (by linarith : s - u ≤ 0), abs_of_nonpos (by linarith : u - t ≤ 0),
      abs_of_nonpos (by linarith : s - t ≤ 0), ← add_mul,
      ← ENNReal.ofReal_add (by linarith : (0:ℝ) ≤ -(s - u))
        (by linarith : (0:ℝ) ≤ -(u - t))]
  congr 2
  ring

/-! ## Geodesic convexity of the interleaving distance -/

-- !-- Rewrite every distance via `eInterleavingDist_eq_weightSupEDist` to `weightSupEDist`,
-- !-- `⨆ σ, ofReal |·|`, then `iSup_le`.  Pointwise,
-- !-- `|Hσ − ((1−t)Fσ + tGσ)| ≤ (1−t)|Hσ−Fσ| + t|Hσ−Gσ|` (`abs_cases`/`nlinarith`);
-- !-- push through `ENNReal.ofReal_add`, `ENNReal.ofReal_mul`, then `gcongr` + `le_iSup`. -- !--
/-- **Geodesic convexity of the interleaving distance (Busemann inequality).**  The
distance from a fixed filtration `H` is convex along the geodesic `lerp F G`:
`d(H, lerp F G t) ≤ ofReal(1−t)·d(H,F) + ofReal t·d(H,G)`.  This is the
non-positive-curvature-flavoured convexity inequality; it is inherited from the
sup-distance through Bridge VIII's isometry `eInterleavingDist_eq_weightSupEDist`. -/
theorem eInterleavingDist_convex (H F G : Filtration α) {t : ℝ}
    (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    eInterleavingDist H (lerp F G t ht0 ht1)
      ≤ ENNReal.ofReal (1 - t) * eInterleavingDist H F
        + ENNReal.ofReal t * eInterleavingDist H G := by
  rw [eInterleavingDist_eq_weightSupEDist, eInterleavingDist_eq_weightSupEDist,
      eInterleavingDist_eq_weightSupEDist]
  refine iSup_le fun σ => ?_
  have h_abs : |H.weight σ - (lerp F G t ht0 ht1).weight σ|
      ≤ (1 - t) * |H.weight σ - F.weight σ| + t * |H.weight σ - G.weight σ| := by
    rw [lerp_weight]
    cases abs_cases (H.weight σ - F.weight σ) <;>
      cases abs_cases (H.weight σ - G.weight σ) <;>
        cases abs_cases (H.weight σ - ((1 - t) * F.weight σ + t * G.weight σ)) <;>
          nlinarith
  refine le_trans (ENNReal.ofReal_le_ofReal h_abs) ?_
  rw [ENNReal.ofReal_add (mul_nonneg (by linarith) (abs_nonneg _))
        (mul_nonneg ht0 (abs_nonneg _)),
      ENNReal.ofReal_mul (by linarith), ENNReal.ofReal_mul ht0]
  unfold weightSupEDist
  gcongr
  · exact le_iSup (fun τ => ENNReal.ofReal |H.weight τ - F.weight τ|) σ
  · exact le_iSup (fun τ => ENNReal.ofReal |H.weight τ - G.weight τ|) σ

/-! ## The space is geodesic -/

-- !-- Take `γ r := lerp F G (min 1 (max 0 r)) _ _` (the clamp of `r` to `[0,1]`).
-- !-- `γ 0 = F` and `γ 1 = G` since the clamp fixes `0` and `1` (`lerp_zero`, `lerp_one`).
-- !-- For `s, t ∈ [0,1]` the clamp is the identity, so `eInterleavingDist_lerp` applies. -- !--
/-- **`(Filtration α, eInterleavingDist)` is a geodesic space.**  Between any two
filtrations there is a path `γ : ℝ → Filtration α` with `γ 0 = F`, `γ 1 = G`, that
realise
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — Boltzmann Bridge X: The Path Space of Filtrations

## Synthesis

Bridge IX (`InterleavingGeodesic.lean`) gave the persistence-stability arc its first
explicit *path of filtrations*: the convex-interpolation geodesic `lerp` and the
constant-speed identity `eInterleavingDist (lerp F G s) (lerp F G t) = ofReal |s−t| ·
eInterleavingDist F G`. Bridge X (`InterleavingPathSpace.lean`) turns that single
geodesic into a **path space** and exposes its homotopical and curvature structure.

Three structurally different facts now coexist over the same object `lerp`:

* an **algebraic** law — `lerp_lerp` shows the geodesics are closed under
  reparametrisation, a `lerp` of two `lerp`s being the `lerp` at the affine parameter
  `(1−t)·a + t·b`. This is the combinatorial skeleton of a fundamental groupoid: paths
  compose to paths, and reparametrisations stay inside the family.
* a **metric** law — `eInterleavingDist_lerp_betweenness` upgrades Bridge IX's midpoint
  bisection to the full geodesic-segment additivity `d(s,u)+d(u,t)=d(s,t)` for any
  `s ≤ u ≤ t`, and `exists_constantSpeed_geodesic` packages everything into the textbook
  statement *the space is geodesic*.
* an **analytic** law — `eInterleavingDist_convex` proves Busemann convexity
  `d(H, lerp F G t) ≤ ofReal(1−t)·d(H,F) + ofReal t·d(H,G)`, inherited from the
  sup-distance through Bridge VIII's isometry `eInterleavingDist_eq_weightSupEDist`.

The decisive insight of this cycle is that **geodesy is the sharp diagonal of
convexity**: the constant-speed equality of Bridge IX is exactly the convexity
inequality of Bridge X restricted to the endpoints' own geodesic, where the
non-maximising slack over the simplex supremum vanishes. Convexity holds for every
third point `H`; equality holds only when the maximising simplex is shared. That single
asymmetry organises everything below.

## Results summary

| Theorem | Statement | Role |
|---|---|---|
| `lerp_self` | `lerp F F t = F` | degenerate geodesic |
| `lerp_lerp` | `lerp (lerp F G a) (lerp F G b) t = lerp F G ((1−t)a+tb)` | reparametrisation closure |
| `eInterleavingDist_lerp_betweenness` | `d(s,u)+d(u,t)=d(s,t)` for `s ≤ u ≤ t` | geodesic-segment law |
| `eInterleavingDist_convex` | `d(H, lerp F G t) ≤ ofReal(1−t)·d(H,F)+ofReal t·d(H,G)` | Busemann convexity |
| `exists_constantSpeed_geodesic` | `∃ γ, γ 0 = F ∧ γ 1 = G ∧ d(γ s, γ t)=ofReal\|s−t\|·d(F,G)` | the space is geodesic |

All five compile with `sorry`-count 0 and depend only on `propext`, `Classical.choice`,
`Quot.sound`.

---

## Direction 1 — The convexity defect and the failure of unique geodesy

**Conjecture.** Define the convexity defect
`δ(H,F,G,t) := ofReal(1−t)·d(H,F) + ofReal t·d(H,G) − d(H, lerp F G t)`. Then `δ ≥ 0`
always (this is `eInterleavingDist_convex`), but `δ` is *not* identically zero: there is
a concrete triple `F, G, H` of three-simplex filtrations and a `t ∈ (0,1)` with
`δ(H,F,G,t) > 0`, and moreover there exist two genuinely distinct constant-s
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
