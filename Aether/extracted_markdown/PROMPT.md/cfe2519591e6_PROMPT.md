
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

**Title**: Deepening: `Applications/BoltzmannBridge/InterleavingIsometry.lean` discharges **Future
**Domain**: Applications
**Mathematical framing**: Building on cycle 0914fa07 (Q=0.765), which proved 206 theorems in Novelty. Go DEEPER: prove the strongest remaining conjecture, close open sorries, or extend the core result to a more general setting. Original direction: # Future Directions — Boltzmann Bridge VIII: Persistence is an *Isometry*

## Synthesis

`Applications/BoltzmannBridge/InterleavingIsometry.lean` discharges **Future
Direction 1** of Boltzmann Bridge VII (`InterleavingClosure`) and closes the
metric theory of the whole persistence-stability arc into
Research domain: Applications
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Applications/BoltzmannBridge/InterleavingRepresentation.lean
/-
# The Boltzmann Bridge IX — Representation and Edge-Realization of the Isometry

This file goes **deeper** than Boltzmann Bridge VIII
(`Applications.BoltzmannBridge.InterleavingIsometry`), which proved the isometry
formula

> `eInterleavingDist F G = ⨆ σ, ENNReal.ofReal |F.weight σ - G.weight σ|`
> (`eInterleavingDist_eq_weightSupEDist`).

Bridge VIII's Lab Notebook flagged two open frontiers; this file discharges both.

## The arc so far

* **IV — `BottleneckStability`**: the interleaving preorder, `WeightCloseBy`, CESH
  stability `stability_supDist`, and the explicit distance-matrix layer
  (`diamWeightOf`, `diamFiltrationOf`, `diamWeightOf_dist_le`,
  `vr_stability_interleaved`).
* **V — `InterleavingMetric`**: the `ℝ≥0∞`-valued `eInterleavingDist`.
* **VII — `InterleavingClosure`**: `eInterleavingDist = 0 ↔ F = G` (a genuine
  `EMetricSpace`).
* **VIII — `InterleavingIsometry`**: `interleaved_iff_weightCloseBy`,
  `weightSupEDist`, and the isometry `eInterleavingDist_eq_weightSupEDist`.

## The deepening (this file)

### Direction A — the representation is a *bijection* (range characterization).

Bridge VIII showed the weight map is an **isometric embedding**.  We upgrade this
to a full **representation theorem**: the weight map is a *bijection* of
`Filtration α` onto the subtype of weight functions that are grounded at `∅` and
monotone under inclusion (`filtrationEquivWeight`).  Persistence is thus not merely
an isometry *into* `(Finset α → ℝ)`; its image is *exactly* the cone of admissible
weights, and `eInterleavingDist` is transported to the sup-distance there
(`eInterleavingDist_eq_repr_supEDist`).

### Direction B — *realizing the sup at a single edge* for Vietoris–Rips.

Bridge VIII deferred "turning `⨆ σ` over simplices into `⨆ x y` over the underlying
distance matrices — which needs the diameter sup to be attained at a single edge."
We settle this for genuine (symmetric, grounded, nonnegative) distance matrices: the
isometry sup over *all* simplices collapses onto the sup over *edges*,

> **`eInterleavingDist (diamFiltrationOf d₁) (diamFiltrationOf d₂)
>   = ⨆ (x y), ENNReal.ofReal |d₁ x y - d₂ x y|`**  (`vr_eInterleavingDist_eq_edgeSup`).

The `≤` half is the `1`-Lipschitz estimate `diamWeightOf_dist_le` (no hypotheses);
the `≥` half is the edge-realization `diamWeightOf_pair` (every two-vertex simplex
`{x,y}` has diameter exactly `d x y`), so the maximizing edge is itself a simplex.

As a corollary, the concrete `3`-point cloud certificate of Bridge IV/V is upgraded
from an *inequality* to an **exact equality**
(`cloud_eInterleavingDist_eq` : the distance is *exactly* `1/10`).

## Main results

* `filtrationEquivWeight` — filtrations ≃ grounded-monotone weight functions
* `eInterleavingDist_eq_repr_supEDist` — distance transported across the bijection
* `diamWeightOf_pair` — two-vertex diameter = the single edge length
* `vr_eInterleavingDist_eq_edgeSup` — **the edge-realization of the isometry**
* `cloud_eInterleavingDist_eq` — the concrete cloud distance is *exactly* `1/10`
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

/-! ## Direction A — the representation bijection -/

-- !-- Both maps are the identity on the underlying weight (with proof-irrelevant
-- !-- side conditions repackaged), so `left_inv`/`right_inv` are `rfl` by structure
-- !-- and subtype eta. -- !--
/-- **The representation bijection.**  The weight map identifies `Filtration α`
with the subtype of weight functions that are grounded at `∅` (`w ∅ ≤ 0`) and
monotone under inclusion.  Combined with Bridge VIII's isometry, this is the full
representation theorem: persistence is an isometric *bijection* onto the cone of
admissible weights, not merely an embedding. -/
def filtrationEquivWeight :
    Filtration α ≃ {w : Finset α → ℝ // w ∅ ≤ 0 ∧ ∀ σ τ : Finset α, σ ⊆ τ → w σ ≤ w τ} where
  toFun F := ⟨F.weight, F.weight_empty, fun _ _ h => F.weight_mono h⟩
  invFun w := ⟨w.1, w.2.1, fun {_ _} h => w.2.2 _ _ h⟩
  left_inv := fun _ => rfl
  right_inv := fun _ => rfl

-- !-- `(filtrationEquivWeight F).1` is definitionally `F.weight`, so this is exactly
-- !-- Bridge VIII's `eInterleavingDist_eq_weightSupEDist`. -- !--
/-- **The distance is transported across the representation bijection.**  Under
`filtrationEquivWeight`, the extended interleaving distance becomes the extended
sup-distance of the represented weight functions. -/
theorem eInterleavingDist_eq_repr_supEDist (F G : Filtration α) :
    eInterleavingDist F G
      = ⨆ σ : Finset α,
          ENNReal.ofReal |(filtrationEquivWeight F).1 σ - (filtrationEquivWeight G).1 σ| :=
  eInterleavingDist_eq_weightSupEDist F G

end Filtration

/-! ## Direction B — edge-realization for Vietoris–Rips -/

section VR

variable {α : Type*} [DecidableEq α]

/-- A bare **distance matrix**: nonnegative, with zero diagonal and symmetric.
No `PseudoMetricSpace` structure or triangle inequality is required — only the
algebra needed to realize the diameter at a single edge. -/
structure IsDistMatrix (d : α → α → ℝ) : Prop where
  nonneg : ∀ i j, 0 ≤ d i j
  diag : ∀ i, d i i = 0
  symm : ∀ i j, d i j = d j i

-- !-- `le_antisymm` of `sup'_le` (each pairwise value of `{x,y}` is `0`, `d x y`,
-- !-- `d y x = d x y`, or `0`, all `≤ d x y` by `nonneg`/`diag`/`symm`) and
-- !-- `le_sup'` applied to the pair `(x,y) ∈ {x,y} ×ˢ {x,y}`. -- !--
/-- **Edge-realization of the diameter.**  For a distance matrix, the diameter
weight of the two-vertex simplex `{x, y}` is exactly the single edge length
`d x y`.  (When `x = y` both sides are `0`.)  Hence every edge is realized by a
simplex, the key to collapsing the simplex-sup onto the edge-sup. -/
theorem diamWeightOf_pair (d : α → α → ℝ) (hd : IsDistMatrix d) (x y : α) :
    diamWeightOf d ({x, y} : Finset α) = d x y := by
  refine le_antisymm (Finset.sup'_le _ _ ?_) ?_
  · simp +decide [Finset.mem_insert, Finset.mem_image]
    refine ⟨hd.nonneg x y, ?_⟩
    rintro a u v (rfl | rfl) (rfl | rfl) rfl <;> simp +decide [hd.diag, hd.symm] <;>
      exact hd.nonneg _ _
  · exact Finset.le_sup' (fun p => id p) (by aesop)

/-- The **edge sup-distance** of two distance matrices: the `ℝ≥0∞`-valued supremum
of `ENNReal.ofReal |d₁ x y - d₂ x y|` over all ordered pairs `(x, y)`. -/
noncomputable def edgeSupEDist (d₁ d₂ : α → α → ℝ) : ℝ≥0∞ :=
  ⨆ p : α × α, ENNReal.ofReal |d₁ p.1 p.2 - d₂ p.1 p.2|

-- !-- If `edgeSupEDist = ⊤`, `le_top`.  Else every pair gap is `≤ E.toReal`
-- !-- (`le_iSup` + `toReal_mono`), so `diamWeightOf_dist_le` gives every simplex gap
-- !-- `≤ E.toReal`; then `iSup_le` and `ofReal_toReal` close it. -- !--
omit [DecidableEq α] in
/-- **Upper half of the edge-realization (the `1`-Lipschitz estimate).**  The
weight-sup distance of the VR filtrations is at most the edge sup-distance — every
simplex gap is dominated by the worst edge gap.  Requires no hypotheses on the
matrices. -/
theorem weightSupEDist_diam_le_edgeSup (d₁ d₂ : α → α → ℝ) :
    Filtration.weightSupEDist (diamFiltrationOf d₁) (diamFiltrationOf d₂)
      ≤ edgeSupEDist d₁ d₂ := by
  by_contra h_contra
  by_cases hE_top : edgeSupEDist d₁ d₂ = ⊤
  · aesop
  · have h_pair_bound : ∀ x y, |d₁ x y - d₂ x y| ≤ (edgeSupEDist d₁ d₂).toReal := by
      intro x y
      have h_pair_bound : ENNReal.ofReal |d₁ x y - d₂ x y| ≤ edgeSupEDist d₁ d₂ :=
        le_iSup_of_le (x, y) le_rfl
      convert ENNReal.toReal_mono hE_top h_pair_bound using 1
      simp +decide [ENNReal.toReal_ofReal (abs_nonneg _)]
    refine h_contra (le_trans ?_ (le_of_eq (EN
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — Boltzmann Bridge IX: Representation & Edge-Realization

## Synthesis

`Applications/BoltzmannBridge/InterleavingRepresentation.lean` (Bridge IX) takes
the metric theory of persistence stability past the isometry formula proved in
Bridge VIII (`InterleavingIsometry`) and closes the two frontiers its Lab Notebook
had flagged.

Bridge VIII proved that the extended interleaving distance is *exactly* the
extended sup-distance of the weight functions,
`eInterleavingDist F G = ⨆ σ, ENNReal.ofReal |F.weight σ − G.weight σ|`. That is an
isometric *embedding* into `(Finset α → ℝ)`. Bridge IX upgrades it on two fronts,
in the spirit of duality and representation:

1. **Representation as a bijection.** `filtrationEquivWeight` exhibits `Filtration α`
   as the *full* subtype of weight functions that are grounded at `∅` (`w ∅ ≤ 0`)
   and monotone under inclusion. The image of the persistence map is pinned down
   exactly — it is the cone of admissible weights — and `eInterleavingDist` is
   transported across the bijection (`eInterleavingDist_eq_repr_supEDist`). The
   abstract filtration geometry and the concrete weight-function geometry are one
   and the same object viewed through a duality.

2. **Edge-realization for Vietoris–Rips.** For a genuine distance matrix
   (`IsDistMatrix`: nonnegative, zero diagonal, symmetric), the simplex-indexed
   supremum collapses onto an *edge*-indexed one:
   `eInterleavingDist (diamFiltrationOf d₁) (diamFiltrationOf d₂)
   = ⨆ (x y), ENNReal.ofReal |d₁ x y − d₂ x y|` (`vr_eInterleavingDist_eq_edgeSup`).
   The VR persistence distance is *literally* the `ℓ∞` distance of the distance
   matrices. As a concrete dividend, the catalog's `≤ 1/10` certificate for the two
   `3`-point clouds is sharpened to an exact equality `= 1/10`
   (`cloud_eInterleavingDist_eq`).

## Results Summary

| Result | Statement | Axioms |
| --- | --- | --- |
| `filtrationEquivWeight` | `Filtration α ≃` grounded-monotone weights | `propext, Classical.choice, Quot.sound` |
| `eInterleavingDist_eq_repr_supEDist` | distance transported across the bijection | standard |
| `diamWeightOf_pair` | `diam d {x,y} = d x y` for a distance matrix | standard |
| `weightSupEDist_diam_le_edgeSup` | simplex-sup `≤` edge-sup (no hypotheses) | standard |
| `edgeSup_le_weightSupEDist_diam` | edge-sup `≤` simplex-sup (distance matrices) | standard |
| `vr_eInterleavingDist_eq_edgeSup` | **edge-realization of the isometry** | standard |
| `cloud_eInterleavingDist_eq` | concrete cloud distance is *exactly* `1/10` | standard |

All proofs are `sorry`-free and depend only on `propext`, `Classical.choice`, and
`Quot.sound`.

## Research Directions

### Direction 1 — Higher-clique realization: from edges to `k`-faces.

Bridge IX realizes the persistence sup at a single *edge* (a two-vertex simplex).
Conjecture: for a weight built as the maximum of a `k`-ary symmetric kernel
`κ : (Fin k → α) → ℝ` over the injections of a simplex (the genuine *higher*
Vi
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
