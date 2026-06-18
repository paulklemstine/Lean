
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

**Title**: `Applications/BoltzmannBridge/InterleavingClosure.lean` discharges **Future
**Domain**: Novelty
**Mathematical framing**: # Future Directions — Boltzmann Bridge VII: the Interleaving Distance is a *Metric*

## Synthesis

`Applications/BoltzmannBridge/InterleavingClosure.lean` discharges **Future
Direction 1** of Boltzmann Bridge VI and, in doing so, *overturns* the central
pessimistic claim that ran through Bridges V and VI.

Bridge V (`InterleavingMetric`) built the `ℝ≥0∞`-valued `eInterleavingDist` and
the pseudo-emetric `interleavingPseudoEMetric`, recording an "honest defect":
allegedly *distinct* filtrations could sit at extended interleaving distance `0`,
so the structure was "only a pseudometric". Bridge VI (`InterleavingQuotient`)
took that defect at face value and quotiented it away with Mathlib's universal
`SeparationQuotient`, obtaining a genuine `EMetricSpace` on the quotient and
characterising the kernel only as the *limiting* relation
`eInterleavingDist = 0 ↔ ∀ ε>0, ∃ δ<ε, Interleaved F G δ`
(`eInterleavingDist_eq_zero_iff`). It explicitly deferred the clean equivalence
`eInterleavingDist = 0 ↔ Interleaved F G 0` to "future work requiring closedness
of the witness set".

Bridge VII proves that closedness in one line of mathematics — and shows the
"defect" never existed:

1. **Closedness** (`interleaved_zero_of_forall_pos`): if `F, G` are
   `ε`-interleaved for *every* `ε > 0` then they are `0`-interleaved. The only
   input is the Archimedean squeeze `(∀ ε>0, a ≤ b+ε) → a ≤ b`
   (`le_of_forall_pos_le_add`) applied to the weights.
2. **Attained infimum** (`eInterleavingDist_eq_zero_iff_interleaved_zero`):
   combining (1) with Bridge VI's limiting characterisation and the upward
   monotonicity `Interleaved_mono` of Bridge IV gives
   `eInterleavingDist F G = 0 ↔ Interleaved F G 0`. The infimum is *attained*.
3. **T0 separation** (`eInterleavingDist_eq_zero_iff_eq`): `Interleaved F G 0`
   means the sublevel families coincide at every scale
   (`interleaved_zero_iff_sublevel_eq`) ⇔ equal weight functions
   (`interleaved_zero_iff_weight_eq`) ⇔ equal filtrations (`ext_weight`, by
   proof irrelevance on the non-data fields of `Filtration`). Hence
   `eInterleavingDist F G = 0 ↔ F = G`.
4. **Consequences**: `Filtration α` is *already* a genuine `EMetricSpace`
   (`interleavingEMetricDirect`); Bridge VI's `SeparationQuotient` map is
   *injective* (`mk_injective`, `mk_eq_mk_iff_eq`); and the converse Bridge VI
   declared to "fail in general" in fact *holds* (`mk_eq_mk_iff_interleaved_zero`).

The lesson is methodological: a *limiting* characterisation of a kernel
("distance 0 = arbitrarily tight interleavings") is weaker than an *algebraic*
one ("distance 0 = a literal 0-interleaving"), and the gap between them is
exactly an attained-infimum argument. Pushing the squeeze through collapsed the
entire pseudometric/quotient apparatus of two prior bridges.

## Results Summary

All theorems in `InterleavingClosure.lean` compile with `sorry`-count `0` and
depend only on `propext`, `Classical.choice`, `Quot.sound`.

| Theorem | Statement |
|---|---|
| `ext_weight` | a filtration is determined by its weight function |
| `interleaved_zero_iff_sublevel_eq` | `Interleaved F G 0 ↔ ∀ t, F.sublevelFaces t = G.sublevelFaces t` |
| `interleaved_zero_iff_weight_eq` | `Interleaved F G 0 ↔ F.weight = G.weight` |
| `interleaved_zero_of_forall_pos` | `(∀ ε>0, Interleaved F G ε) → Interleaved F G 0` |
| `eInterleavingDist_eq_zero_iff_interleaved_zero` | the infimum is attained |
| `eInterleavingDist_eq_zero_iff_eq` | **distance `0` ⇔ equality** |
| `interleavingEMetricDirect` | genuine `EMetricSpace (Filtration α)` |
| `mk_injective`, `mk_eq_mk_iff_eq`, `mk_eq_mk_iff_interleaved_zero` | the Bridge VI quotient is trivial |

## Falsifiable Research Directions

### Direction 1 — The interleaving distance *is* the sup-distance of weights

**Conjecture.** For all `F G : Filtration α`,
`eInterleavingDist F G = ⨆ σ, ENNReal.ofReal |F.weight σ - G.weight σ|`
(the extended sup-norm distance of the weight functions); equivalently, on
filtrations with bounded weight-gap, `interleavingDist F G = sSup {|F.weight σ -
G.weight σ| : σ}`. This would upgrade `eInterleavingDist_le_supDist` (Bridge V,
one inequality) to an *equality* and exhibit `Filtration α` as isometric to a
subspace of `(Finset α → ℝ, sup-norm)`.

The key insight is that Bridge VII proved the defining infimum is *attained* at a
literal `0`-interleaving exactly when weights are equal; the same attained-infimum
machinery should pin the value of the infimum in general, because `stability_supDist`
already shows every weight-gap bound `D` yields a `D`-interleaving, and the reverse
("an interleaving forces a weight-gap bound") is the contrapositive of the
sublevel-membership argument used in `interleaved_zero_iff_weight_eq`.

Why now? With T0 separation established, the remaining content is purely
quantitative, and both inequalities already have half-proofs in the arc
(`eInterleavingDist_le_supDist` one way, the membership squeeze the other) — the
conjecture is a sharp, immediately testable equality with a clear falsifier (any
filtration pair whose interleaving distance strictly undercuts the sup-gap).

### Direction 2 — Where the collapse *fails*: non-Archimedean weights

**Conjecture.** Replace the codomain `ℝ` of `Filtration.weight` by an ordered
field/monoid `W` that is **not** densely ordered or not Archimedean (e.g. the
tropical/min-plus semiring of `Catalog/Tropical/MinPlusAlgebra.lean`, or an
ultrametric value group as in
`Catalog/Speculative/AutoResearch/TropicalUltrametricBridge.lean`). Then
`interleaved_zero_of_forall_pos` becomes **false**: there exist distinct
`W`-filtrations `F ≠ G` with `eInterleavingDist F G = 0`, so the separation
quotient of Bridge VI is genuinely non-trivial and the `EMetricSpace` of Bridge
VII degenerates back to a pseudometric.

The key insight is that the *entire* T0 collapse of Bridge VII rests on the single
Archimedean fact `le_of_forall_pos_le_add`, which is exactly what a non-densely-
ordered or non-Archimedean `W` denies — so the kernel is an invariant measuring
the *order-theoretic completeness* of the weight space, not of the topology.

Why now? Bridge VII isolates the unique load-bearing hypothesis to a named one-line
lemma, making it surgically removable; and the catalog already contains both the
tropical and ultrametric scaffolding to instantiate `W`, so the cross-domain
counterexample is constructible today and falsifiable by a single explicit pair.

### Direction 3 — Functoriality and 1-Lipschitz pushforward

**Conjecture.** A weight-nonincreasing map of vertex sets `f : α → β` (or a
simplicial map) induces a pushforward `f# : Filtration α → Filtration β` that is
**1-Lipschitz** for `eInterleavingDist`, i.e.
`eInterleavingDist (f# F) (f# G) ≤ eInterleavingDist F G`, making
`F ↦ (Filtration, eInterleavingDist)` a functor into the category of extended
metric spaces and short maps.

The key insight is that `Interleaved_trans`/`Interleaved_mono` already make
interleaving a graded preorder closed under composition, and Bridge VII's attained
infimum lets one transport a witnessing `0`- or `δ`-interleaving *through* `f#`
without an approximation argument, so Lipschitz-ness reduces to monotonicity
bookkeeping on sublevel sets.

Why now? Functoriality was impossible to state cleanly while the structure was only
a pseudometric with an opaque kernel; with a genuine `EMetricSpace` on `Filtration α`
itself (no quotient), "short map" is now a literal Mathlib property
(`LipschitzWith 1`) that can be discharged directly.

### Direction 4 — Completeness of the interleaving emetric space

**Conjecture.** `(Filtration α, eInterleavingDist)` is a **complete** extended
metric space: every Cauchy sequence of filtrations converges, with the limit
filtration's weight the pointwise limit of the weights. Consequently the metric
of Bridge VII is not merely T0 but a Polish-type completion target.

The key insight is that Bridge VII's `eInterleavingDist_eq_zero_iff_eq` identifies
the metric with a weight-space metric (Direction 1), and pointwise/uniform limits
of monotone weight functions are again monotone — so completeness of the weight
sup-metric should transfer to completeness of the filtration emetric verbatim.

Why now? Completeness only becomes a meaningful (non-vacuous) question once points
are separated; before Bridge VII the "space" had indistinguishable points and the
notion of a unique limit was ill-posed.

### Direction 5 — Quantitative stability is an isometric embedding of data

**Conjecture.** The Vietoris–Rips assignment `d ↦ diamFiltrationOf d` from
distance matrices `(α → α → ℝ, sup-norm)` to `(Filtration α, eInterleavingDist)`
is itself **1-Lipschitz and, on symmetric hollow matrices, an isometry**:
`eInterleavingDist (diamFiltrationOf d₁) (diamFiltrationOf d₂)
   = ENNReal.ofReal (⨆ x y, |d₁ x y - d₂ x y|)`. This sharpens `vr_eStability`
(Bridge V, the `≤` direction) to an equality and makes the persistence pipeline a
*distortion-preserving* embedding rather than a mere contraction.

The key insight is that `diamWeightOf_dist_le` (Bridge IV) already gives the `≤`
direction with a matching constant `1`, and Bridge VII's attained-infimum result
removes the only obstruction to the reverse inequality, namely the fear that the
interleaving infimum could be strictly smaller than any realised weight gap.

Why now? The forward stability bound and the attained infimum are both in hand;
the conjecture is the precise statement that "stability is tight", with an explicit
falsifier available from small point clouds such as the `cloud₁`/`cloud₂` pair
already certified in `BottleneckStability.lean`.

Research domain: Novelty
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Applications/BoltzmannBridge/InterleavingIsometry.lean
/-
# The Boltzmann Bridge VIII — The Interleaving Distance *is* the Sup-Distance of Weights

This file discharges **Future Direction 1** of Boltzmann Bridge VII
(`Applications.BoltzmannBridge.InterleavingClosure`): it upgrades the *one*
inequality `eInterleavingDist_le_supDist` of Bridge V to an exact **isometry
formula**, exhibiting `Filtration α` as the weight functions
`Finset α → ℝ` under the (extended) sup-distance.

## The arc so far

* **IV — `BottleneckStability`**: the relational interleaving preorder
  (`Interleaved`, `Interleaved_refl/symm/mono/trans`), the predicate
  `WeightCloseBy F G D := ∀ σ, |F.weight σ - G.weight σ| ≤ D`, and the CESH
  stability theorem `stability_supDist : 0 ≤ D → WeightCloseBy F G D →
  Interleaved F G D` (uniform `D`-closeness ⇒ `D`-interleaving).
* **V — `InterleavingMetric`**: the `ℝ≥0∞`-valued `eInterleavingDist` and the
  one-sided stability bound `eInterleavingDist_le_supDist`.
* **VII — `InterleavingClosure`**: the attained infimum at `0`
  (`eInterleavingDist_eq_zero_iff_eq`), proving the structure is a genuine
  `EMetricSpace` and the `0`-interleaving relation is *equality of weights*
  (`interleaved_zero_iff_weight_eq`).

## The synthesis (this file)

Bridge VII observed that `Interleaved F G 0 ↔ F.weight = G.weight`.  The decisive
generalisation is that this is *quantitative*: the converse of `stability_supDist`
holds for **every** shift, not just `0`.

* **The interleaving relation is exactly uniform closeness of weights**
  (`interleaved_iff_weightCloseBy`):
  `Interleaved F G δ ↔ 0 ≤ δ ∧ WeightCloseBy F G δ`.
  The forward direction evaluates the sublevel inclusions at the two birth times
  `t = F.weight σ` and `t = G.weight σ`; the backward direction is exactly
  `stability_supDist`.  (At `δ = 0` this *is* Bridge VII's
  `interleaved_zero_iff_weight_eq`.)
* Therefore the defining infimum of `eInterleavingDist` is an infimum of sup-norm
  bounds, and it **equals the extended sup-distance of the weights**
  (`eInterleavingDist_eq_weightSupEDist`):

  > **`eInterleavingDist F G = ⨆ σ, ENNReal.ofReal |F.weight σ - G.weight σ|`.**

  The `≥` direction (`weightSupEDist_le_eInterleavingDist`) holds because every
  interleaving witness `δ` dominates every weight gap; the `≤` direction
  (`eInterleavingDist_le_weightSupEDist`) is the attained-infimum argument — when
  the sup is finite, its real value is itself an admissible shift.
* As a cross-check, Bridge VII's T0 separation re-derives instantly from the
  formula (`weightSupEDist_eq_zero_iff_eq`).

The metric content of the entire persistence-stability arc thus collapses to a
single, sharp, closed form: **persistence is an isometry, not merely a
contraction.**

## Main results

* `interleaved_iff_weightCloseBy` — interleaving = uniform weight closeness.
* `weightSupEDist` — the extended sup-distance of two weight functions.
* `weightSupEDist_le_eInterleavingDist` / `eInterleavingDist_le_weightSupEDist` —
  the two halves of the isometry.
* `eInterleavingDist_eq_weightSupEDist` — **the isometry formula** (Direction 1).
* `weightSupEDist_eq_zero_iff_eq` — T0 separation, recovered from the formula.
-/
import Mathlib
import Applications.BoltzmannBridge.HigherPersistence
import Applications.BoltzmannBridge.PersistenceStability
import Applications.BoltzmannBridge.BottleneckStability
import Applications.BoltzmannBridge.InterleavingMetric
import Applications.BoltzmannBridge.InterleavingClosure

open Finset BigOperators
open scoped ENNReal

namespace BoltzmannBridge

namespace Filtration

variable {α : Type*}

-- !-- Forward: from `Interleaved F G δ`, evaluate `h.2.1` at `t = F.weight σ` and
-- !-- `h.2.2` at `t = G.weight σ` to get `G.weight σ ≤ F.weight σ + δ` and
-- !-- `F.weight σ ≤ G.weight σ + δ`, then `abs_sub_le_iff`.  Backward: this is
-- !-- exactly `stability_supDist`. -- !--
/-- **Interleaving is exactly uniform closeness of the weights.**  Two filtrations
are `δ`-interleaved iff `δ ≥ 0` and their weight functions are uniformly within `δ`
in sup-norm.  This is the quantitative converse of `stability_supDist`, and at
`δ = 0` it is Bridge VII's `interleaved_zero_iff_weight_eq`. -/
theorem interleaved_iff_weightCloseBy (F G : Filtration α) (δ : ℝ) :
    Interleaved F G δ ↔ 0 ≤ δ ∧ WeightCloseBy F G δ := by
  -- By definition of Interleaved, we have that F and G are δ-interleaved if and only if for every time t, F.sublevelFaces t is a subset of G.sublevelFaces (t + δ) and vice versa.
  rw [Filtration.Interleaved];
  constructor <;> intro h <;> simp_all +decide [ Set.subset_def, Filtration.mem_sublevelFaces ];
  · exact fun σ => abs_sub_le_iff.mpr ⟨ by linarith [ h.2.1 ( F.weight σ ) σ le_rfl, h.2.2 ( G.weight σ ) σ le_rfl ], by linarith [ h.2.1 ( F.weight σ ) σ le_rfl, h.2.2 ( G.weight σ ) σ le_rfl ] ⟩;
  · exact ⟨ fun t x hx => by linarith [ abs_le.mp ( h.2 x ) ], fun t x hx => by linarith [ abs_le.mp ( h.2 x ) ] ⟩

/-- **The extended sup-distance of two weight functions**: the supremum over all
simplices of the `ℝ≥0∞`-valued gap `ENNReal.ofReal |F.weight σ - G.weight σ|`.
The index type `Finset α` is always nonempty (it contains `∅`). -/
noncomputable def weightSupEDist (F G : Filtration α) : ℝ≥0∞ :=
  ⨆ σ : Finset α, ENNReal.ofReal |F.weight σ - G.weight σ|

-- !-- `eInterleavingDist` is `⨅` over witnesses `δ`; for each witness,
-- !-- `interleaved_iff_weightCloseBy` gives `|F.weight σ - G.weight σ| ≤ δ` for all
-- !-- `σ`, so `ofReal |…| ≤ ofReal δ`; `iSup_le` then `le_iInf`. -- !--
/-- **Lower half of the isometry.**  The extended sup-distance of the weights is at
most the extended interleaving distance: every interleaving witness dominates every
weight gap. -/
theorem weightSupEDist_le_eInterleavingDist (F G : Filtration α) :
    weightSupEDist F G ≤ eInterleavingDist F G := by
  refine le_iInf fun δ => ?_
  have h_weightCloseBy : WeightCloseBy F G δ :=
    ((interleaved_iff_weightCloseBy F G δ).1 δ.2).2
  exact iSup_le fun σ => ENNReal.ofReal_le_ofReal (h_weightCloseBy σ)

-- !-- If `weightSupEDist F G = ⊤`, the bound is `le_top`.  Otherwise set
-- !-- `c := weightSupEDist F G ≠ ⊤`; for each `σ`, `ofReal |…| ≤ c` (`le_iSup`) gives
-- !-- `|…| ≤ c.toReal`, i.e. `WeightCloseBy F G c.toReal`; with `0 ≤ c.toReal`,
-- !-- `stability_supDist` yields `Interleaved F G c.toReal`, and `eInterleavingDist_le`
-- !-- gives `≤ ofReal c.toReal = c` (`ENNReal.ofReal_toReal`). -- !--
/-- **Upper half of the isometry (attained infimum).**  The extended interleaving
distance is at most the extended sup-distance of the weights: when the sup is
finite its real value is itself an admissible interleaving shift. -/
theorem eInterleavingDist_le_weightSupEDist (F G : Filtration α) :
    eInterleavingDist F G ≤ weightSupEDist F G := by
  by_cases h : F.weightSupEDist G = ⊤;
  · exact h.symm ▸ le_top;
  · have h_weightCloseBy : ∀ σ : Finset α, |F.weight σ - G.weight σ| ≤ (F.weightSupEDist G).toReal := by
      intro σ
      have h_abs : ENNReal.ofReal |F.weight σ - G.weight σ| ≤ F.weightSupEDist G := by
        exact le_iSup ( fun σ : Finset α => ENNReal.ofReal |F.weight σ - G.weight σ| ) σ;
      convert ENNReal.toReal_mono h h_abs using 1 ; norm_num;
    convert Filtration.stability_supDist F G ( ENNReal.toReal_nonneg ) h_weightCloseBy |> fun h => Filtration.eInterleavingDist_le F G h using 1;
    rw [ ENNReal.ofReal_toReal h ]

-- !-- `le_antisymm` of the two halves. -- !--
/-- **The isometry formula (Future Direction 1).**  The extended interleaving
distance equals the extended sup-distance of the weight functions:
`eInterleavingDist F G = ⨆ σ, ENNReal.ofReal |F.weight σ - G.weight σ|`.  Hence
`Filtration α` embeds isometrically into `(Finset α → ℝ)` under the sup-distance —
persistence is an isometry, not merely a `1`-Lipschitz contraction. -/
theorem eInterleavingDist_eq_weightSupEDist (F G : Filtration α) :
    eInterleavingDist F G = weightSupEDist F G :=
  le_antisymm (eInterleavingDist_le
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — Boltzmann Bridge VIII: Persistence is an *Isometry*

## Synthesis

`Applications/BoltzmannBridge/InterleavingIsometry.lean` discharges **Future
Direction 1** of Boltzmann Bridge VII (`InterleavingClosure`) and closes the
metric theory of the whole persistence-stability arc into a single closed form.

Bridge V (`InterleavingMetric`) proved only *one* inequality:
`eInterleavingDist_le_supDist`, "a uniform weight-gap bound `D` forces interleaving
distance `≤ ofReal D`" — persistence is `1`-Lipschitz in the data. Bridge VII
(`InterleavingClosure`) proved the *boundary* case, `eInterleavingDist F G = 0 ↔
F = G`, by showing `0`-interleaving is exactly equality of weight functions
(`interleaved_zero_iff_weight_eq`) and that the defining infimum is *attained* at
`0`. Bridge VIII shows that the boundary case is the shadow of a fully
quantitative phenomenon: the infimum is attained at *every* scale.

The single new engine is `interleaved_iff_weightCloseBy`:

> `Interleaved F G δ ↔ 0 ≤ δ ∧ ∀ σ, |F.weight σ - G.weight σ| ≤ δ`.

This is the exact converse of `stability_supDist` (Bridge IV), proved by
evaluating the two sublevel inclusions of an interleaving at the two birth times
`t = F.weight σ` and `t = G.weight σ`. At `δ = 0` it specialises to Bridge VII's
`interleaved_zero_iff_weight_eq`, so Bridge VIII genuinely *generalises* Bridge VII
rather than reproving it. With this characterisation the defining infimum of
`eInterleavingDist` becomes an infimum of sup-norm bounds, and the two duality
halves —

* `weightSupEDist_le_eInterleavingDist` (every witness `δ` dominates every weight
  gap, so the `⨆` of gaps is below the `⨅` of witnesses), and
* `eInterleavingDist_le_weightSupEDist` (the attained-infimum argument: when the
  `⨆` of gaps is finite, its real value `c.toReal` is itself an admissible shift
  via `stability_supDist`) —

combine to the **isometry formula**

> **`eInterleavingDist F G = ⨆ σ, ENNReal.ofReal |F.weight σ - G.weight σ|`**
> (`eInterleavingDist_eq_weightSupEDist`).

As a one-line corollary, Bridge VII's T0 separation `weightSupEDist F G = 0 ↔ F = G`
(`weightSupEDist_eq_zero_iff_eq`) falls out of the formula. The methodological
lesson sharpens Bridge VII's: an *attained* infimum is not just enough to separate
points — it pins the *entire* metric to a closed sup-norm form. Persistence is an
isometry, not merely a contraction.

## Results Summary

All theorems in `InterleavingIsometry.lean` compile with `sorry`-count `0` and
depend only on `propext`, `Classical.choice`, `Quot.sound`.

| Theorem | Statement |
|---|---|
| `interleaved_iff_weightCloseBy` | `Interleaved F G δ ↔ 0 ≤ δ ∧ ∀ σ, \|F.weight σ − G.weight σ\| ≤ δ` |
| `weightSupEDist` | the extended sup-distance `⨆ σ, ENNReal.ofReal \|F.weight σ − G.weight σ\|` |
| `weightSupEDist_le_eInterleavingDist` | the `≥` half of the isometry |
| `eInterleavingDist_le_weightSupEDist` | the `≤` half (attained infimum) |
| `eInterleavingDist_eq_weightSupEDist` | **the isome
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
