
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

**Title**: `Applications/BoltzmannBridge/InterleavingIsometry.lean` discharges **Future
**Domain**: Novelty
**Mathematical framing**: # Future Directions — Boltzmann Bridge VIII: Persistence is an *Isometry*

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
| `eInterleavingDist_eq_weightSupEDist` | **the isometry formula** |
| `weightSupEDist_eq_zero_iff_eq` | T0 separation recovered from the formula |

## Falsifiable Research Directions

### Direction 1 — Vietoris–Rips stability is *tight*: an entrywise isometry

**Conjecture.** For symmetric, hollow distance matrices `d₁ d₂ : α → α → ℝ` over a
finite vertex type,
`eInterleavingDist (diamFiltrationOf d₁) (diamFiltrationOf d₂)
   = ⨆ x, ⨆ y, ENNReal.ofReal |d₁ x y − d₂ x y|`.
That is, the simplex-indexed sup `⨆ σ` of Bridge VIII collapses to an
*edge-indexed* sup, sharpening `vr_eStability` (Bridge V, the `≤` direction) to an
equality and making the VR functor a distortion-preserving embedding of distance
matrices.

The key insight is that Bridge VIII already reduces the left side to
`⨆ σ, ENNReal.ofReal |diamWeightOf d₁ σ − diamWeightOf d₂ σ|`, and `diamWeightOf`
is a finite `sup'` over the vertex pairs of `σ`; the gap of two `sup'`s is bounded
by the worst single pair (`diamWeightOf_dist_le` gives `≤`, and the pair attaining
`diamWeightOf d₁ σ` realises the reverse), so the whole equality is a finite
`sup'`-vs-`sup'` extremal-pair argument with no new analysis.

Why now? Bridge VIII converts the abstract interleaving infimum into a concrete
weight sup, so the remaining content is purely the combinatorial identity "the
diameter gap is attained on an edge"; the explicit `cloud₁`/`cloud₂` pair already
in `BottleneckStability.lean` is an immediate falsifier if the edge sup ever
strictly exceeds the simplex sup.

### Direction 2 — The isometric embedding into bounded weight functions, and completeness

**Conjecture.** The map `F ↦ F.weight` is an `Isometry` from `(Filtration α,
eInterleavingDist)` onto the set of monotone, `∅`-grounded functions inside
`(Finset α → ℝ)` equipped with the extended sup-emetric
`edist f g = ⨆ σ, ENNReal.ofReal |f σ − g σ|`; moreover this image is *closed*, so
`(Filtration α, eInterleavingDist)` is a **complete** extended metric space and its
Cauchy limits have weight the uniform limit of the weights.

The key insight is that Bridge VIII's formula *is* the statement that `weight` is
distance-preserving; what remains is purely topological, namely that a uniform
(sup-emetric) limit of monotone, `∅`-grounded functions is again monotone and
`∅`-grounded — both are closed conditions defined by non-strict inequalities, hence
preserved under pointwise/uniform limits.

Why now? Completeness was ill-posed while the space had indistinguishable points;
Bridge VII separated them and Bridge VIII identified the metric with a sup-norm on
functions, so completeness reduces to closedness of the constraint set `{w | w ∅ ≤ 0
∧ Monotone w}` — a Mathlib-shaped lemma rather than a persistence question.

### Direction 3 — Functoriality: weight-nondecreasing pullback is 1-Lipschitz

**Conjecture.** A vertex map `f : α → β` induces a pullback
`f* : Filtration β → Filtration α` by `(f* F).weight σ = F.weight (σ.image f)`
(monotone because `image` is), and `f*` is **1-Lipschitz** for `eInterleavingDist`:
`eInterleavingDist (f* F) (f* G) ≤ eInterleavingDist F G`, with *equality* when `f`
is injective. Thus `Filtration` is a functor into extended metric spaces and short
maps.

The key insight is that Bridge VIII turns Lipschitz-ness into a pure sup
comparison: `⨆ σ, |F.weight (σ.image f) − G.weight (σ.image f)|` ranges over a
*subset* of the values `⨆ τ, |F.weight τ − G.weight τ|` (those `τ` in the image of
`·.image f`), so the bound is monotonicity of `⨆` over a reindexing, and injectivity
makes the reindexing surjective onto all `τ`, giving equality.

Why now? Functoriality was unstatable cleanly while the structure was a
pseudometric with an opaque kernel; with the closed-form `eInterleavingDist`,
"short map" is the literal Mathlib predicate `LipschitzWith 1` and the proof is a
`iSup`-mono one-liner over the new formula.

### Direction 4 — Where the isometry breaks: non-Archimedean weight codomains

**Conjecture.** Replace the codomain `ℝ` of `Filtration.weight` by an ordered
additive structure `W` that is not Archimedean / not densely ordered (e.g. the
min-plus tropical semiring of `Catalog/Tropical/MinPlusAlgebra.lean`, or a
discrete value group). Then `interleaved_iff_weightCloseBy` *survives* (it is order
algebra), but the attained-infimum step `eInterleavingDist_le_weightSupEDist`
**fails**: the sup of weight gaps need not be an admissible shift, so
`eInterleavingDist` strictly undercuts `weightSupEDist`, the T0 collapse degenerates
back to a pseudometric, and the Bridge VI `SeparationQuotient` becomes nontrivial.

The key insight is that Bridge VIII isolates the *unique* analytic input — the step
"`c.toReal` is itself a witness", which silently uses `ENNReal.ofReal_toReal` and
the order-completeness of `ℝ` — so removing density/Archimedeanity surgically
removes exactly the attainment, while leaving the relational characterisation
intact; the kernel then measures the order-completeness of `W`, not of the topology.

Why now? Bridge VIII names the load-bearing lemma in one place, making the
counterexample a single explicit `W`-filtration pair; the catalog already ships the
tropical scaffolding to instantiate `W`, so the obstruction is constructible and
falsifiable today.

### Direction 5 — Surjectivity: a representation theorem for the filtration emetric

**Conjecture.** The weight embedding of Direction 2 is **surjective** onto
`{w : Finset α → ℝ | w ∅ ≤ 0 ∧ Monotone w}`: every monotone, `∅`-grounded weight
function arises as `F.weight` for a unique `F`, so `(Filtration α, eInterleavingDist)`
is *isometrically isomorphic* to that constraint set under the sup-emetric. Hence the
interleaving geometry of persistence is, up to isometry, nothing more than the
order interval of monotone functions in sup-norm.

The key insight is that the `Filtration` structure carries exactly the two
propositional fields `weight_empty` and `weight_mono`, so building `F` from a `w`
satisfying the two constraints is immediate (the converse direction of `ext_weight`
from Bridge VII), and Bridge VIII makes the resulting bijection distance-preserving
on the nose.

Why now? `ext_weight` (Bridge VII) gave injectivity and Bridge VIII gave the
isometry; the only missing half is the trivial constructor for surjectivity, after
which the persistence emetric is *completely classified* — turning the entire arc
(IV–VIII) into a representation theorem that downstream homology-stability results
can cite as a black box.

Research domain: Novelty
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Applications/BoltzmannBridge/InterleavingFunctor.lean
/-
# The Boltzmann Bridge IX — The Persistence Functor and the Representation Theorem

This file discharges **Future Directions 3 and 5** of Boltzmann Bridge VIII
(`Applications.BoltzmannBridge.InterleavingIsometry`).  Bridge VIII proved the
closed-form **isometry formula**

> `eInterleavingDist F G = ⨆ σ, ENNReal.ofReal |F.weight σ - G.weight σ|`
> (`eInterleavingDist_eq_weightSupEDist`),

identifying the interleaving emetric with the sup-distance of the weight
functions.  With the metric pinned to a sup-norm on functions, two purely
structural questions become tractable.

## Direction 3 — Functoriality (the contravariant pullback is short)

A vertex map `f : α → β` induces a **pullback** `pullback f : Filtration β →
Filtration α`, `(pullback f F).weight σ = F.weight (σ.image f)`, monotone because
`Finset.image` is.  This is a genuine contravariant functor (`pullback_id`,
`pullback_comp`), and Bridge VIII makes it **`1`-Lipschitz**
(`eInterleavingDist_pullback_le`, `pullback_lipschitzWith_one`): the simplex-sup of
`pullback`-weight gaps ranges over a *subset* of the simplex-sup of weight gaps, so
the bound is monotonicity of `⨆` over a reindexing.  When `f` is **surjective** the
reindexing is itself surjective onto all simplices of `β`, upgrading the bound to an
**equality** (`eInterleavingDist_pullback_eq_of_surjective`).

> *Correction to the published Direction 3.*  Bridge VIII's narrative claimed
> equality for *injective* `f`.  This is false: an injective `f : α → β` with `α`
> strictly smaller than `β` leaves simplices of `β` outside the image of
> `·.image f`, where `F` and `G` may differ arbitrarily, so the pullback distance
> can strictly undercut `eInterleavingDist F G`.  The reindexing
> `σ ↦ σ.image f` is *surjective* (hence the sups agree) exactly when `f` is
> surjective, which is the correct hypothesis proved here.

## Direction 5 — The representation theorem (surjectivity of `weight`)

Bridge VII's `ext_weight` showed `weight` is *injective*: a filtration is its
weight function.  The converse constructor `ofWeight` shows it is *surjective* onto
the monotone, `∅`-grounded functions: every `w : Finset α → ℝ` with `w ∅ ≤ 0` and
`Monotone w` is the weight of a (unique) filtration (`weight_surjective`).  Packaged
as a bijection (`weightEquiv`), and combined with Bridge VIII, this **completely
classifies** the persistence emetric: `(Filtration α, eInterleavingDist)` is, up to
the explicit isometry `weightEquiv`, nothing but the order interval of monotone
`∅`-grounded functions under the sup-emetric (`eInterleavingDist_ofWeight`).

## Main results

* `pullback`, `pullback_weight`, `pullback_id`, `pullback_comp` — the contravariant
  persistence functor.
* `eInterleavingDist_pullback_le` / `pullback_lipschitzWith_one` — pullback is
  `1`-Lipschitz (Direction 3).
* `eInterleavingDist_pullback_eq_of_surjective` — equality for surjective maps
  (corrected Direction 3).
* `ofWeight`, `weight_surjective`, `weightEquiv` — the representation theorem
  (Direction 5).
* `eInterleavingDist_ofWeight` — the emetric in fully explicit weight-function form.
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

variable {α β γ : Type*}

/-! ## The contravariant pullback functor (Direction 3) -/

-- !-- `weight σ := F.weight (σ.image f)`.  `weight_empty`: `(∅).image f = ∅`.
-- !-- `weight_mono`: `σ ⊆ τ ⇒ σ.image f ⊆ τ.image f` (`Finset.image_subset_image`),
-- !-- then `F.weight_mono`. -- !--
/-- **The pullback of a filtration along a vertex map.**  `pullback f F` assigns the
simplex `σ` the weight `F.weight (σ.image f)`; monotone because `Finset.image` is.
This is the action on objects of the contravariant persistence functor. -/
def pullback [DecidableEq β] (f : α → β) (F : Filtration β) : Filtration α where
  weight := fun σ => F.weight (σ.image f)
  weight_empty := by simpa using F.weight_empty
  weight_mono := fun h => F.weight_mono (Finset.image_subset_image h)

@[simp] theorem pullback_weight [DecidableEq β] (f : α → β) (F : Filtration β)
    (σ : Finset α) : (pullback f F).weight σ = F.weight (σ.image f) := rfl

-- !-- `image id = id`, so weights agree; conclude by `ext_weight`. -- !--
/-- **Functoriality (identity).**  Pullback along the identity is the identity. -/
theorem pullback_id [DecidableEq α] (F : Filtration α) : pullback id F = F := by
  apply ext_weight; funext σ; simp

-- !-- `(σ.image f).image g = σ.image (g ∘ f)` (`Finset.image_image`), so the weights
-- !-- of the two filtrations agree; conclude by `ext_weight`. -- !--
/-- **Functoriality (composition, contravariant).**  Pullback turns composition
around: `pullback (g ∘ f) = pullback f ∘ pullback g`. -/
theorem pullback_comp [DecidableEq β] [DecidableEq γ] (f : α → β) (g : β → γ)
    (F : Filtration γ) : pullback (g ∘ f) F = pullback f (pullback g F) := by
  apply ext_weight; funext σ; simp [Finset.image_image]

-- !-- Rewrite both distances by the Bridge VIII isometry formula
-- !-- `eInterleavingDist_eq_weightSupEDist`.  Then `⨆ σ, ofReal |…(σ.image f)…|` is a
-- !-- reindexing of `⨆ τ, ofReal |…τ…|` along `σ ↦ σ.image f`; bound each term by
-- !-- `le_iSup` at `τ = σ.image f`. -- !--
/-- **Pullback is `1`-Lipschitz (Direction 3).**  The interleaving distance can only
contract under pullback: persistence is functorial into short maps. -/
theorem eInterleavingDist_pullback_le [DecidableEq β] (f : α → β) (F G : Filtration β) :
    eInterleavingDist (pullback f F) (pullback f G) ≤ eInterleavingDist F G := by
  rw [eInterleavingDist_eq_weightSupEDist, eInterleavingDist_eq_weightSupEDist,
      weightSupEDist, weightSupEDist]
  refine iSup_le fun σ => ?_
  simp only [pullback_weight]
  exact le_iSup (fun τ : Finset β => ENNReal.ofReal |F.weight τ - G.weight τ|) (σ.image f)

-- !-- `le_antisymm` with `eInterleavingDist_pullback_le`.  For `≥`: by the isometry
-- !-- formula, every `τ : Finset β` is `σ.image f` for some `σ` (use `Function.surjInv`
-- !-- and `Finset.image_image`), so each weight gap at `τ` is realised by the pullback
-- !-- gap at `σ`; bound by `le_iSup`. -- !--
/-- **Pullback along a surjection is an isometry (corrected Direction 3).**  When `f`
is surjective the reindexing `σ ↦ σ.image f` is surjective onto all simplices of
`β`, so the pullback *preserves* the interleaving distance.  (Surjectivity, not
injectivity, is the correct hypothesis — see the file header.) -/
theorem eInterleavingDist_pullback_eq_of_surjective [DecidableEq α] [DecidableEq β]
    (f : α → β) (hf : Function.Surjective f) (F G : Filtration β) :
    eInterleavingDist (pullback f F) (pullback f G) = eInterleavingDist F G := by
  refine le_antisymm (eInterleavingDist_pullback_le f F G) ?_
  rw [eInterleavingDist_eq_weightSupEDist, eInterleavingDist_eq_weightSupEDist,
      weightSupEDist, weightSupEDist]
  refine iSup_le fun τ => ?_
  obtain ⟨σ, rfl⟩ : ∃ σ : Finset α, σ.image f = τ :=
    ⟨τ.image (Function.surjInv hf), by
      rw [Finset.image_image]
      simp only [Function.comp_def, Function.surjInv_eq hf, Finset.image_id']⟩
  exact le_iSup
    (fun σ : Finset α => ENNReal.ofReal |(pullback f F).weight σ - (pullback f G).weight σ|) σ

/-! ## Pullback as a Mathlib short map -/

/-- The Bridge V/VIII pseudo-emetric, as a file-local instance for every vertex
type, so `LipschitzWith` and `edist` are available below. -/
noncomputable local instance pullbackInterleavingPseudoEMetricInst {δ : Type*} :
    PseudoEMetricSpace (Filtration δ) := interleavingPseudoEMetric

-- !-- `LipschitzWith 1 g` unfolds to `edist (g F) (g G) ≤ 1 * edist F G`; 
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — Boltzmann Bridge IX: The Persistence Functor and the Representation Theorem

## Synthesis

`Catalog/Applications/BoltzmannBridge/InterleavingFunctor.lean` (Bridge IX)
discharges **Future Directions 3 and 5** of Boltzmann Bridge VIII
(`InterleavingIsometry`) and, in doing so, turns the closed-form isometry of
Bridge VIII into *structural* statements about the whole space of filtrations.

Bridge VIII pinned the interleaving emetric to a sup-norm on weight functions:

> `eInterleavingDist F G = ⨆ σ, ENNReal.ofReal |F.weight σ − G.weight σ|`.

Bridge IX exploits this in two complementary ways.

* **Functoriality (Direction 3).** A vertex map `f : α → β` pulls a filtration
  back, `(pullback f F).weight σ = F.weight (σ.image f)`, monotone because
  `Finset.image` is. This is a genuine contravariant functor (`pullback_id`,
  `pullback_comp`) and Bridge VIII makes it **1-Lipschitz**
  (`eInterleavingDist_pullback_le`, packaged as `pullback_lipschitzWith_one :
  LipschitzWith 1 (pullback f)`): the simplex-sup of pullback-weight gaps ranges
  over a *subset* of the simplex-sup of weight gaps, so the bound is monotonicity
  of `⨆` over a reindexing. When `f` is **surjective** the reindexing is itself
  surjective onto every simplex of `β`, upgrading the bound to an *equality*
  (`eInterleavingDist_pullback_eq_of_surjective`).

  This also **corrects** Bridge VIII's published narrative, which claimed equality
  for *injective* `f`. That is false — an injective `f : α → β` with `α` strictly
  smaller than `β` leaves simplices of `β` outside the image of `·.image f`, where
  the weights may differ arbitrarily, so the pullback distance can strictly
  undercut `eInterleavingDist F G`. The reindexing `σ ↦ σ.image f` is surjective
  (hence sup-preserving) exactly when `f` is surjective. Bridge IX proves the
  honest, surjective version.

* **Representation theorem (Direction 5).** Bridge VII's `ext_weight` showed
  `weight` is *injective*. The converse constructor `ofWeight` shows it is
  *surjective* onto the monotone, `∅`-grounded functions: every `w : Finset α → ℝ`
  with `w ∅ ≤ 0` and `Monotone w` is the weight of a unique filtration
  (`weight_surjective`). Packaged as the bijection `weightEquiv : Filtration α ≃
  {w // w ∅ ≤ 0 ∧ Monotone w}` and combined with Bridge VIII
  (`eInterleavingDist_ofWeight`), this **classifies** the persistence emetric: up
  to the explicit bijection, `(Filtration α, eInterleavingDist)` is nothing but the
  order interval of monotone, `∅`-grounded functions under the sup-emetric.

The methodological lesson of Bridge IX: once the metric is a sup-norm on
functions (Bridge VIII), every structural question — functoriality, isometry,
classification — collapses to elementary facts about `⨆` and `Finset.image`. The
closed form turns geometry into bookkeeping.

## Results Summary

All theorems in `InterleavingFunctor.lean` compile with `sorry`-count `0` and
depend only on `propext`, `Classical.choice`, `Quot.sound`
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
