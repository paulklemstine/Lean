
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

**Title**: `Applications/BoltzmannBridge/InterleavingGeodesic.lean` closes the
**Domain**: Novelty
**Mathematical framing**: # Future Directions — Boltzmann Bridge IX: the Interleaving Metric is *Geodesic*

## Synthesis

`Applications/BoltzmannBridge/InterleavingGeodesic.lean` closes the
persistence-stability arc's metric story and opens its **homotopical** chapter.
The arc moved from a relational preorder (`BottleneckStability`, `Interleaved`),
to a pseudo-emetric (`InterleavingMetric`, `eInterleavingDist`), to a genuine
`EMetricSpace` with attained infimum (`InterleavingClosure`,
`eInterleavingDist_eq_zero_iff_eq`), to an exact isometry onto weight functions
under the sup-distance (`InterleavingIsometry`,
`eInterleavingDist_eq_weightSupEDist`).

Bridge IX adds the missing geometric layer: the space is not merely isometric to a
sup-space but is itself **geodesic**. Convex interpolation of weights,
`lerp F G t` with weight `(1−t)·F.weight + t·G.weight`, is a valid filtration for
`0 ≤ t ≤ 1`, gives a path from `F` (`lerp_zero`) to `G` (`lerp_one`), and the
interleaving distance varies *exactly linearly* along it
(`eInterleavingDist_lerp`: `d(lerp s, lerp t) = ofReal |s − t| · d(F, G)`), with the
midpoint bisecting the distance additively (`eInterleavingDist_midpoint`). This is
the first explicit **path of filtrations** in the catalog — a homotopy between data
shapes that realises the interleaving distance — and it is the natural launch point
for a full path-space / fundamental-groupoid treatment of persistence.

## Results summary

* `lerp`, `lerp_zero`, `lerp_one` — the convex-interpolation path of filtrations and
  its endpoints.
* `weight_lerp_sub` — pointwise weight gaps scale linearly: `|lerp s − lerp t| =
  |s − t| · |F − G|`.
* `weightSupEDist_lerp` — the sup-distance is linear along the path.
* `eInterleavingDist_lerp` — **the constant-speed geodesic identity** (built on
  Bridge VIII's `eInterleavingDist_eq_weightSupEDist`).
* `eInterleavingDist_lerp_left` — distance from the endpoint is `ofReal t · d(F, G)`.
* `eInterleavingDist_midpoint` — the midpoint bisects the distance additively.

All main results are `sorry`-free and depend only on `propext`, `Classical.choice`,
`Quot.sound`.

## Research directions

### Direction 1 — The path space of filtrations is contractible

Conjecture: for any basepoint `F₀ : Filtration α`, the map
`H : Filtration α × [0,1] → Filtration α`, `H(G, t) = lerp G F₀ t`, is a
*continuous* (indeed `1`-Lipschitz-in-`t`) contraction of `(Filtration α,
eInterleavingDist)` onto `F₀`, so the metric space is contractible and its
fundamental groupoid is trivial. Falsifiable: exhibit two paths between fixed
endpoints whose concatenation is not null-homotopic, or show `H` fails continuity at
some `(G, t)`.

The key insight is that the geodesic identity `eInterleavingDist_lerp` already gives
`d(H(G,t), H(G,t')) = ofReal|t−t'|·d(G,F₀)` and `d(H(G,t),H(G',t)) ≤ d(G,G')`
(by `1`-Lipschitzness of `lerp` in its endpoint, which follows from the same
`weight_lerp_sub` factorisation), so joint continuity is purely an
`ENNReal`-estimate the existing lemmas almost deliver.

Why now? Bridge IX has just produced the segment-geodesics and proved the linear
distance law; assembling them into a single straight-line homotopy is the immediate
next algebraic step, and it converts the *metric* result into a genuine *homotopy*
invariant (contractibility) that the engine's homotopy/path-space mandate targets.

### Direction 2 — Uniqueness fails: characterise *all* geodesics

Conjecture: a path `γ : [0,1] → Filtration α` from `F` to `G` is a (constant-speed)
geodesic for `eInterleavingDist` **iff** for every simplex `σ` the scalar path
`t ↦ γ(t).weight σ` stays monotonically between `F.weight σ` and `G.weight σ` and
the *sup* over `σ` of the gap travels at constant speed. In particular `lerp` is one
geodesic among a convex family, so the space is geodesic but **not uniquely
geodesic**. Falsifiable: produce a constant-speed geodesic that is *not* of this
pointwise-between form, or prove the `lerp` geodesic is the unique one.

The key insight is that `eInterleavingDist` is a `⨆` of per-simplex absolute-value
metrics, and on the real line `[a,b]` is uniquely geodesic while a *supremum* of
such intervals is highly non-uniquely geodesic — the slack in non-maximising
simplices is free to wander.

Why now? `weight_lerp_sub` isolates exactly the per-simplex contribution, so the
non-uniqueness can be tested by perturbing `lerp` on a single non-maximising simplex
and re-running `eInterleavingDist_lerp`'s `⨆`-argument — no new infrastructure
needed.

### Direction 3 — Geodesic convexity of the Vietoris–Rips locus

Conjecture: the image of the Vietoris–Rips functor `d ↦ diamFiltration d`
(`HigherPersistence`) is a *geodesically convex* subset of `(Filtration α,
eInterleavingDist)`: the `lerp` of two diameter-filtrations is again a
diameter-filtration of the linearly interpolated distance matrix `(1−t)d₁ + t d₂`,
provided that interpolation remains a pseudometric. Falsifiable: find `d₁, d₂` whose
midpoint diameter-filtration differs from `diamFiltration((d₁+d₂)/2)` at some
simplex.

The key insight is that the diameter weight is a *pointwise supremum* of edge
distances, and suprema commute with convex combinations only up to inequality — so
the conjecture pins down precisely when persistence interpolation is "geometric"
versus merely "combinatorial".

Why now? Bridge VIII flagged "realising the sup for the Vietoris–Rips functor" as
its open frontier; the geodesic `lerp` now gives the canonical interpolation to test
that realisation against, turning a vague frontier into a sharp commuting-square
question.

### Direction 4 — Curvature: the interleaving space is a geodesic `CAT(0)`–style sup-space

Conjecture: `(Filtration α, eInterleavingDist)` satisfies the *Busemann
non-positive curvature* inequality
`d(lerp F G ½, lerp F H ½) ≤ ½ · d(G, H)` (convexity of the metric along
`lerp`-geodesics), inherited from the sup-metric structure. It is, however, **not**
`CAT(0)` in general (sup-metrics are flat-but-cornered, like `ℓ^∞`). Falsifiable:
violate the Busemann inequality for some `F, G, H`, or conversely verify the
`CAT(0)` four-point condition and refute the `ℓ^∞`-analogy.

The key insight is that an `ℓ^∞`/sup-metric is Busemann-convex but not `CAT(0)`, and
Bridge VIII proved `eInterleavingDist` *is* such a sup-metric — so curvature bounds
transfer term-by-term through the same `⨆`-and-`mul_iSup` machinery used in
`weightSupEDist_lerp`.

Why now? The midpoint lemma `eInterleavingDist_midpoint` is the `F = G` instance of
the Busemann inequality; generalising one endpoint is the smallest possible step and
immediately yields a *curvature* statement, the deepest classification of a geodesic
space.

### Direction 5 — The geodesic identity characterises the sup-metric (rigidity)

Conjecture: among all translation-invariant metrics on weight functions
`Finset α → ℝ` for which every `lerp`-segment is a constant-speed geodesic with the
*same* per-simplex speeds, the sup-distance is the unique one realised by an
interleaving-type relation; i.e. `eInterleavingDist` is *rigid* — the geodesic law
plus `1`-Lipschitz stability forces the formula
`eInterleavingDist_eq_weightSupEDist`. Falsifiable: construct a different metric
(e.g. an `ℓ^p` weight-distance, `p < ∞`) that also makes `lerp` geodesic yet arises
from a stability relation, contradicting uniqueness.

The key insight is that geodesy plus the linear speed law `eInterleavingDist_lerp`
encodes a functional equation on the metric, and on a sup-of-coordinates space only
the `ℓ^∞` norm solves it compatibly with the *one-edge* stability witnesses of
`stability_supDist`.

Why now? With the isometry (Bridge VIII) and the geodesic law (Bridge IX) both
formalised, the inverse problem — *which* metric is forced by these properties — is
now a precisely stated rigidity theorem rather than an informal expectation, and it
would crown the arc by characterising the interleaving distance uniquely.

Research domain: Novelty
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Applications/BoltzmannBridge/InterleavingGeodesic.lean
/-
# The Boltzmann Bridge IX — The Interleaving Metric is *Geodesic*

This file closes the metric story of the persistence-stability arc and opens its
**homotopical** chapter.  The arc so far moved from a relational preorder
(`BottleneckStability`: `Interleaved`), to a pseudo-emetric
(`InterleavingMetric`: `eInterleavingDist`, `interleavingPseudoEMetric`), to a
genuine `EMetricSpace` with attained infimum (`InterleavingClosure`:
`eInterleavingDist_eq_zero_iff_eq`), to an exact isometry onto weight functions
under the extended sup-distance (`InterleavingIsometry`:
`eInterleavingDist_eq_weightSupEDist`, `weightSupEDist`).

Bridge IX adds the missing geometric layer: the space is not merely *isometric* to
a sup-space, it is itself **geodesic**.  Convex interpolation of the weight
functions,

> `lerp F G t` with weight `σ ↦ (1 − t)·F.weight σ + t·G.weight σ`,

is a valid `Filtration` for `0 ≤ t ≤ 1` (the convex combination preserves
`weight_empty` and `weight_mono`), gives a path from `F` (`lerp_zero`) to `G`
(`lerp_one`), and the interleaving distance varies **exactly linearly** along it:

> **`eInterleavingDist (lerp F G s) (lerp F G t) = ENNReal.ofReal |s − t| · eInterleavingDist F G`**
> (`eInterleavingDist_lerp`).

This is the first explicit *path of filtrations* in the catalog — a homotopy
between data shapes that realises the interleaving distance at constant speed —
and the natural launch point for a path-space / fundamental-groupoid treatment of
persistence.

## Main results

* `lerp`, `lerp_weight`, `lerp_zero`, `lerp_one` — the convex-interpolation path of
  filtrations and its endpoints.
* `weight_lerp_sub` — pointwise weight gaps scale linearly:
  `|lerp s − lerp t| = |s − t| · |F − G|`.
* `weightSupEDist_lerp` — the extended sup-distance is linear along the path.
* `eInterleavingDist_lerp` — **the constant-speed geodesic identity** (built on
  Bridge VIII's `eInterleavingDist_eq_weightSupEDist`).
* `eInterleavingDist_lerp_left` — distance from the endpoint `F` is
  `ENNReal.ofReal t · eInterleavingDist F G`.
* `eInterleavingDist_midpoint` — the midpoint bisects the distance additively.
-/
import Mathlib
import Applications.BoltzmannBridge.HigherPersistence
import Applications.BoltzmannBridge.PersistenceStability
import Applications.BoltzmannBridge.BottleneckStability
import Applications.BoltzmannBridge.InterleavingMetric
import Applications.BoltzmannBridge.InterleavingClosure
import Applications.BoltzmannBridge.InterleavingIsometry

open Finset BigOperators
open scoped ENNReal

namespace BoltzmannBridge

namespace Filtration

variable {α : Type*}

/-! ## The convex-interpolation path of filtrations -/

-- !-- The convex combination `(1−t)·F + t·G` of weights.  `weight_empty`:
-- !-- both `F.weight ∅, G.weight ∅ ≤ 0` and both coefficients `≥ 0`, so `nlinarith`.
-- !-- `weight_mono`: combine `F.weight_mono h` and `G.weight_mono h` with nonneg
-- !-- coefficients. -- !--
/-- **The convex-interpolation path of filtrations.**  For `0 ≤ t ≤ 1`, `lerp F G t`
is the filtration whose weight is the convex combination
`σ ↦ (1 − t)·F.weight σ + t·G.weight σ`.  The convexity hypotheses `0 ≤ t` and
`t ≤ 1` are exactly what make the combination a valid monotone, grounded weight. -/
noncomputable def lerp (F G : Filtration α) (t : ℝ) (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    Filtration α where
  weight σ := (1 - t) * F.weight σ + t * G.weight σ
  weight_empty := by nlinarith [F.weight_empty, G.weight_empty]
  weight_mono := by
    intro σ τ h
    have h1 := F.weight_mono h
    have h2 := G.weight_mono h
    nlinarith

@[simp] theorem lerp_weight (F G : Filtration α) (t : ℝ) (ht0 : 0 ≤ t) (ht1 : t ≤ 1)
    (σ : Finset α) :
    (lerp F G t ht0 ht1).weight σ = (1 - t) * F.weight σ + t * G.weight σ := rfl

-- !-- At `t = 0` the weight is `1·F + 0·G = F`; `ext_weight` then `simp`/`ring`. -- !--
/-- The path starts at `F`: `lerp F G 0 = F`. -/
theorem lerp_zero (F G : Filtration α) : lerp F G 0 le_rfl zero_le_one = F := by
  apply ext_weight; funext σ; simp

-- !-- At `t = 1` the weight is `0·F + 1·G = G`; `ext_weight` then `simp`/`ring`. -- !--
/-- The path ends at `G`: `lerp F G 1 = G`. -/
theorem lerp_one (F G : Filtration α) : lerp F G 1 zero_le_one le_rfl = G := by
  apply ext_weight; funext σ; simp

/-! ## Linearity of the weight gaps and the sup-distance -/

-- !-- `(lerp s − lerp t).weight σ = (t − s)·(F.weight σ − G.weight σ)` by `ring`;
-- !-- take `|·|` via `abs_mul`, `abs_sub_comm`. -- !--
/-- **Pointwise weight gaps scale linearly.**  For `s, t ∈ [0,1]` the gap between
the interpolated weights at every simplex is `|s − t|` times the original gap. -/
theorem weight_lerp_sub (F G : Filtration α) {s t : ℝ}
    (hs0 : 0 ≤ s) (hs1 : s ≤ 1) (ht0 : 0 ≤ t) (ht1 : t ≤ 1) (σ : Finset α) :
    |(lerp F G s hs0 hs1).weight σ - (lerp F G t ht0 ht1).weight σ|
      = |s - t| * |F.weight σ - G.weight σ| := by
  simp only [lerp_weight]
  rw [show (1 - s) * F.weight σ + s * G.weight σ
        - ((1 - t) * F.weight σ + t * G.weight σ)
        = (t - s) * (F.weight σ - G.weight σ) by ring,
      abs_mul, abs_sub_comm t s]

-- !-- `weightSupEDist (lerp s)(lerp t) = ⨆ σ, ofReal |lerp s − lerp t|`.  Pull the
-- !-- constant `ofReal |s − t|` out of the `⨆` (`ENNReal.mul_iSup`), then match termwise
-- !-- with `weight_lerp_sub` and `ENNReal.ofReal_mul`. -- !--
/-- **The extended sup-distance is linear along the path.** -/
theorem weightSupEDist_lerp (F G : Filtration α) {s t : ℝ}
    (hs0 : 0 ≤ s) (hs1 : s ≤ 1) (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    weightSupEDist (lerp F G s hs0 hs1) (lerp F G t ht0 ht1)
      = ENNReal.ofReal |s - t| * weightSupEDist F G := by
  unfold weightSupEDist
  rw [ENNReal.mul_iSup]
  refine iSup_congr fun σ => ?_
  rw [weight_lerp_sub, ENNReal.ofReal_mul (abs_nonneg _)]

/-! ## The constant-speed geodesic identity -/

-- !-- Rewrite both sides through Bridge VIII's `eInterleavingDist_eq_weightSupEDist`
-- !-- and apply `weightSupEDist_lerp`. -- !--
/-- **The constant-speed geodesic identity.**  The interleaving distance varies
*exactly linearly* along the convex-interpolation path:
`d(lerp F G s, lerp F G t) = ofReal |s − t| · d(F, G)`.  Hence `(Filtration α,
eInterleavingDist)` is a geodesic space and `lerp` is a constant-speed geodesic. -/
theorem eInterleavingDist_lerp (F G : Filtration α) {s t : ℝ}
    (hs0 : 0 ≤ s) (hs1 : s ≤ 1) (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    eInterleavingDist (lerp F G s hs0 hs1) (lerp F G t ht0 ht1)
      = ENNReal.ofReal |s - t| * eInterleavingDist F G := by
  rw [eInterleavingDist_eq_weightSupEDist, eInterleavingDist_eq_weightSupEDist,
      weightSupEDist_lerp]

-- !-- `F = lerp F G 0` (`lerp_zero`), so the distance equals
-- !-- `d(lerp 0, lerp t) = ofReal |0 − t| · d`; `|0 − t| = t` since `t ≥ 0`. -- !--
/-- **Distance from the start of the path.**  The interleaving distance from the
endpoint `F` to the point `lerp F G t` is `ofReal t · d(F, G)`. -/
theorem eInterleavingDist_lerp_left (F G : Filtration α) {t : ℝ}
    (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    eInterleavingDist F (lerp F G t ht0 ht1)
      = ENNReal.ofReal t * eInterleavingDist F G := by
  have h : eInterleavingDist F (lerp F G t ht0 ht1)
      = eInterleavingDist (lerp F G 0 le_rfl zero_le_one) (lerp F G t ht0 ht1) := by
    rw [lerp_zero]
  rw [h, eInterleavingDist_lerp]
  congr 2
  rw [show (0 : ℝ) - t = -t by ring, abs_neg, abs_of_nonneg ht0]

-- !-- `d(F, mid) = ofReal(1/2)·d` (`eInterleavingDist_lerp_left`) and `d(mid, G) =
-- !-- d(lerp ½, lerp 1) = ofReal|½ − 1|·d = ofReal(1/2)·d`; sum the `ofReal` halves to
-- !-- `ofReal 1 = 1` and `1 · d = d`. -- !--
/-- **The midpoint bisects the distance additively.**  The point `lerp F G ½` sits
exactly halfway: `d(F, lerp F G ½) + d(lerp F G ½, G) = d(F, G)`.  This is the
metric witness that the geodesic `lerp` has constant speed. -/
theorem eInterleavingDist_midpoint (F G : Filtration α) :
    eInterleavingDist F (lerp F G (1/2) (by norm_num) (
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — Boltzmann Bridge IX: the Interleaving Metric is *Geodesic*

## Synthesis

`Applications/BoltzmannBridge/InterleavingGeodesic.lean` closes the
persistence-stability arc's metric story and opens its **homotopical** chapter.
The arc moved from a relational preorder (`Interleaved`, with
`Interleaved_refl/symm/mono/trans`), to a pseudo-emetric (`eInterleavingDist`,
`interleavingPseudoEMetric`), to a genuine `EMetricSpace` with attained infimum
(`eInterleavingDist_eq_zero_iff_eq`), to an exact isometry onto weight functions
under the extended sup-distance (`eInterleavingDist_eq_weightSupEDist`,
`weightSupEDist`).

Bridge IX adds the missing geometric layer: the space is not merely isometric to a
sup-space but is itself **geodesic**. Convex interpolation of weights, `lerp F G t`
with weight `σ ↦ (1−t)·F.weight σ + t·G.weight σ`, is a valid filtration for
`0 ≤ t ≤ 1`, gives a path from `F` (`lerp_zero`) to `G` (`lerp_one`), and the
interleaving distance varies *exactly linearly* along it (`eInterleavingDist_lerp`:
`d(lerp s, lerp t) = ofReal |s − t| · d(F, G)`), with the midpoint bisecting the
distance additively (`eInterleavingDist_midpoint`). This is the first explicit
**path of filtrations** in the catalog — a homotopy between data shapes that
realises the interleaving distance at constant speed — and the natural launch point
for a path-space / fundamental-groupoid treatment of persistence.

## Results summary

* `lerp`, `lerp_weight`, `lerp_zero`, `lerp_one` — the convex-interpolation path of
  filtrations and its endpoints.
* `weight_lerp_sub` — pointwise weight gaps scale linearly:
  `|lerp s − lerp t| = |s − t| · |F − G|`.
* `weightSupEDist_lerp` — the extended sup-distance is linear along the path.
* `eInterleavingDist_lerp` — **the constant-speed geodesic identity**, built on
  Bridge VIII's `eInterleavingDist_eq_weightSupEDist`.
* `eInterleavingDist_lerp_left` — distance from the endpoint `F` is
  `ofReal t · d(F, G)`.
* `eInterleavingDist_midpoint` — the midpoint bisects the distance additively.

All main results are `sorry`-free and depend only on `propext`, `Classical.choice`,
and `Quot.sound`.

## Research directions

### Direction 1 — The path space of filtrations is contractible

Conjecture: for any basepoint `F₀ : Filtration α`, the straight-line map
`H : Filtration α × [0,1] → Filtration α`, `H(G, t) = lerp G F₀ t`, is a continuous
(indeed `1`-Lipschitz-in-`t`) contraction of `(Filtration α, eInterleavingDist)`
onto `F₀`, so the metric space is contractible and its fundamental groupoid is
trivial. Falsifiable: exhibit two paths between fixed endpoints whose concatenation
is not null-homotopic, or show `H` fails continuity at some `(G, t)`.

The key insight is that the geodesic identity `eInterleavingDist_lerp` already
delivers `d(H(G,t), H(G,t')) = ofReal |t−t'| · d(G,F₀)`, while `1`-Lipschitzness of
`lerp` in its moving endpoint (the same `weight_lerp_sub` factorisation, now applied
to the endpoint rather than the
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
