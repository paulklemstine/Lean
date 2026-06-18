
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

**Title**: `Applications/BoltzmannBridge/BottleneckStability.lean` closes the catalog's
**Domain**: Novelty
**Mathematical framing**: # Future Directions — Persistent-Homology Stability (Boltzmann Bridge IV)

## Synthesis

`Applications/BoltzmannBridge/BottleneckStability.lean` closes the catalog's
persistent-homology arc. The earlier files built the filtration calculus
(`HigherPersistence`: `Filtration`, `sublevelFaces`, the Vietoris–Rips
`diamWeight`) and the relational interleaving lemmas
(`PersistenceStability`: `stability_interleaving`, `stability_compose`,
`stability_two_sided`). This cycle turns those scattered inequalities into a
single coherent metric theory:

* a named, symmetric, additively-composable interleaving relation
  `Interleaved F G δ`;
* a real-valued `interleavingDist` (nonneg, `= 0` on the diagonal, symmetric,
  bounded by any admissible shift);
* the Cohen-Steiner–Edelsbrunner–Harer sublevel stability theorem in sharp
  `1`-Lipschitz form (`stability_supDist`, `interleavingDist_le_supDist`);
* a Gromov–Hausdorff / correspondence-distortion layer over *explicit* distance
  matrices `d : α → α → ℝ` (`diamWeightOf`, `diamFiltrationOf`), with the single
  load-bearing estimate `diamWeightOf_dist_le` (the diameter is `1`-Lipschitz in
  the data) yielding `vr_stability_interleaved` / `vr_stability_dist`;
* an end-to-end concrete verification on two `3`-point clouds
  (`cloud_distortion`, `cloud_stability`, `cloud_interleavingDist_le`).

The whole stability phenomenon collapses onto one inequality: *the simplex weight
is 1-Lipschitz in the input metric*. Everything downstream is monotonicity
bookkeeping. The deliberate adversarial probing exposed exactly one fault line:
the `sInf`-based distance is honest only up to the `sInf ∅ = 0` convention, which
is where the next cycle should push.

## Results Summary

| Theorem | Statement | Status |
|---|---|---|
| `Interleaved_{refl,symm,mono,trans}` | interleaving is a graded equivalence-like preorder | ✅ proved |
| `interleavingDist_{nonneg,le,self,comm}` | `interleavingDist` is a symmetric, grounded pre-distance | ✅ proved |
| `stability_supDist` / `interleavingDist_le_supDist` | CESH sublevel stability, sharp `1`-Lipschitz | ✅ proved |
| `diamWeightOf_dist_le` | VR diameter is `1`-Lipschitz in the distance matrix | ✅ proved |
| `vr_stability_interleaved` / `vr_stability_dist` | distortion `≤ ε` ⇒ `ε`-interleaving ⇒ bottleneck `≤ ε` | ✅ proved |
| `cloud_{distortion,stability,interleavingDist_le}` | concrete point-cloud certificate | ✅ proved |

All main results are `sorry`-free and depend only on
`propext`, `Classical.choice`, `Quot.sound`.

## Research Directions

### 1. The `EReal` interleaving distance is a true extended pseudometric
The current `interleavingDist` quietly breaks the triangle inequality because
Lean evaluates `sInf ∅ = 0`: two filtrations that are *never* interleaved are
reported at distance `0` rather than `+∞`. Replace the codomain by `EReal` (or
`ℝ≥0∞`), defining `interleavingEDist F G = sInf {(δ : EReal) | Interleaved F G δ}`,
and prove the full pseudometric axioms — crucially
`interleavingEDist F H ≤ interleavingEDist F G + interleavingEDist G H` — using
`Interleaved_trans` as the additive engine. **The key insight is** that
`Interleaved_trans` is already the entire triangle inequality at the relational
level, so the only missing ingredient is an order-complete codomain that records
"no interleaving exists" as `⊤` instead of collapsing to `0`. **Why now?** The
relational composition lemma is proved and the failure mode is documented in the
file's Lab Notebook; the remaining work is purely a change of codomain plus
`EReal` `sInf` API, with no new mathematics required. *Falsifiable:* if the
triangle inequality still fails in `EReal`, the conjecture is refuted by an
explicit three-filtration counterexample.

### 2. Combinatorial isometry theorem: bottleneck `= ` interleaving
We currently bound the bottleneck distance via interleaving and *cite* the
Bauer–Lesnick isometry `d_B = d_I`. Formalize a finite multiset model of a
persistence diagram (`Multiset (ℝ × ℝ)` over the diagonal), define the bottleneck
distance through partial matchings, and prove the easy inequality
`d_B ≤ d_I` directly from `Interleaved`, then attack the converse for the
restricted class of diagrams arising from `diamFiltrationOf` on finite clouds.
**The key insight is** that for *finite* point clouds every persistence diagram
has finitely many off-diagonal points, so the matching infimum is attained and
the converse reduces to a finite combinatorial optimization rather than the full
measure-theoretic argument. **Why now?** Our filtrations are finite by
construction (`Finset α` simplices), so the hard analytic part of the general
isometry theorem is absent and a self-contained finite proof is in reach.
*Falsifiable:* exhibit a finite cloud where the matching-defined `d_B` strictly
exceeds `interleavingDist`.

### 3. The sharp factor-two Gromov–Hausdorff bound
Promote the correspondence-distortion estimate to the genuine Gromov–Hausdorff
distance: define `dGH` between two finite distance matrices as the infimum over
correspondences of half the metric distortion, and prove
`interleavingDist (diamFiltrationOf d₁) (diamFiltrationOf d₂) ≤ 2 * dGH d₁ d₂`,
the Chazal–Cohen-Steiner–Guibas–Mémoli–Oudot bound. **The key insight is** that
`diamWeightOf_dist_le` already gives the per-correspondence bound; upgrading to
`dGH` only requires taking an infimum over the (finite) set of correspondences
and tracking the factor `2` coming from the symmetric distortion definition.
**Why now?** The per-correspondence inequality — historically the technical
heart — is fully proved here, so the generalization is an `sInf`-monotonicity
wrapper. *Falsifiable:* a pair of clouds with
`interleavingDist > 2 * dGH` would refute the constant.

### 4. Interleaving controls every numerical invariant (Euler/Betti stability)
The catalog already has `euler_char_full_simplex`. Conjecture: the Euler
characteristic curve `t ↦ χ(sublevelComplex t)` and the persistent Betti
numbers are themselves stable — uniformly close filtrations produce Euler curves
that agree except on a set of total length `≤ 2δ`. **The key insight is** that an
`Interleaved F G δ` sandwiches each sublevel complex of `F` between two sublevel
complexes of `G` at scales `t ± δ`, so any monotone-in-inclusion invariant is
trapped in a `δ`-window and inherits stability for free. **Why now?** Both the
interleaving sandwich (`sublevel_mono`, `Interleaved`) and a computed Euler
invariant exist in the catalog; combining them needs only a monotonicity lemma
for `χ` under `ASC.Sub`. *Falsifiable:* a `δ`-interleaved pair whose Euler curves
differ on a set longer than `2δ`.

### 5. Functoriality / data-processing inequality for filtrations
Conjecture a contraction principle: if `Φ` transforms weight functions and is
itself `1`-Lipschitz in sup-norm (e.g. pushforward along a `1`-Lipschitz map of
vertices, or smoothing), then
`interleavingDist (Φ F) (Φ G) ≤ interleavingDist F G`. **The key insight is**
that `interleavingDist_le_supDist` already shows persistence is `1`-Lipschitz in
the weight, so any `1`-Lipschitz preprocessing composes to a non-expansive map on
persistence — a topological "data-processing inequality". **Why now?** The
sup-norm Lipschitz bound is the proved cornerstone; functoriality is its closure
under composition, and it directly justifies the common TDA pipeline step of
denoising before computing diagrams. *Falsifiable:* a `1`-Lipschitz `Φ` and a
pair `F, G` with `interleavingDist (Φ F) (Φ G) > interleavingDist F G`.

Research domain: Novelty
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Applications/BoltzmannBridge/BottleneckStability.lean
/-
# The Boltzmann Bridge IV — The Interleaving Distance and Bottleneck Stability

This file closes the catalog's persistent-homology arc.  The earlier files built
the *filtration calculus* (`Applications.BoltzmannBridge.HigherPersistence`:
`Filtration`, `sublevelFaces`, `sublevel_mono`, the Vietoris–Rips `diamWeight`)
and the *relational interleaving lemmas*
(`Applications.BoltzmannBridge.PersistenceStability`: `stability_interleaving`,
`stability_compose`, `stability_two_sided`).  Those files produced a family of
scattered set-inclusion inequalities.  This file turns them into a single
coherent **metric theory of persistence stability**:

* a named, symmetric, additively-composable interleaving relation
  `Interleaved F G δ` (with `Interleaved_refl/symm/mono/trans`) — the relational
  skeleton of a graded preorder;
* a real-valued `interleavingDist`, shown to be a *symmetric, grounded
  pre-distance* (`interleavingDist_nonneg`, `interleavingDist_le`,
  `interleavingDist_self`, `interleavingDist_comm`);
* the Cohen-Steiner–Edelsbrunner–Harer sublevel stability theorem in sharp
  `1`-Lipschitz form: uniform `D`-closeness of the weights forces a
  `D`-interleaving and `interleavingDist ≤ D` (`stability_supDist`,
  `interleavingDist_le_supDist`);
* a Gromov–Hausdorff / correspondence-distortion layer over **explicit distance
  matrices** `d : α → α → ℝ` (`diamWeightOf`, `diamFiltrationOf`), resting on the
  single load-bearing estimate `diamWeightOf_dist_le` — *the simplex diameter is
  `1`-Lipschitz in the input metric* — yielding `vr_stability_interleaved` and
  `vr_stability_dist`;
* an end-to-end concrete certificate on two `3`-point clouds
  (`cloud_distortion`, `cloud_stability`, `cloud_interleavingDist_le`).

The entire stability phenomenon collapses onto one inequality: the simplex weight
is `1`-Lipschitz in the data.  Everything else is monotonicity bookkeeping.

## Main results

* `Interleaved_refl/symm/mono/trans` — interleaving is a graded preorder
* `interleavingDist_nonneg/le/self/comm` — a symmetric grounded pre-distance
* `stability_supDist`, `interleavingDist_le_supDist` — CESH `1`-Lipschitz stability
* `diamWeightOf_dist_le` — VR diameter is `1`-Lipschitz in the distance matrix
* `vr_stability_interleaved`, `vr_stability_dist` — distortion `≤ ε` ⇒ stability
* `cloud_distortion/stability/interleavingDist_le` — concrete point-cloud certificate
-/
import Mathlib
import Applications.BoltzmannBridge.HigherPersistence
import Applications.BoltzmannBridge.PersistenceStability

open Finset BigOperators

namespace BoltzmannBridge

namespace Filtration

variable {α : Type*}

/-! ## The interleaving relation -/

/-- **`δ`-interleaving of two filtrations.**  Two filtrations are `δ`-interleaved
(for `δ ≥ 0`) when each one's sublevel family is contained in the other's after a
uniform `δ`-shift of scale.  This is the relational core of the interleaving /
bottleneck distance and the combinatorial form of an interleaving of persistence
modules. -/
def Interleaved (F G : Filtration α) (δ : ℝ) : Prop :=
  0 ≤ δ ∧
    (∀ t : ℝ, F.sublevelFaces t ⊆ G.sublevelFaces (t + δ)) ∧
    (∀ t : ℝ, G.sublevelFaces t ⊆ F.sublevelFaces (t + δ))

-- !-- `0 ≤ 0`; and `F.sublevelFaces t ⊆ F.sublevelFaces (t+0)` simplifies via `t+0 = t`. -- !--
/-- Every filtration is `0`-interleaved with itself: interleaving is reflexive. -/
theorem Interleaved_refl (F : Filtration α) : Interleaved F F 0 :=
  ⟨le_rfl, fun _ => by simp, fun _ => by simp⟩

-- !-- Swap the two inclusion clauses; `0 ≤ δ` is preserved. -- !--
/-- Interleaving is symmetric in the two filtrations. -/
theorem Interleaved_symm {F G : Filtration α} {δ : ℝ} (h : Interleaved F G δ) :
    Interleaved G F δ :=
  ⟨h.1, h.2.2, h.2.1⟩

-- !-- Enlarge each shift via `sublevel_mono` (`t+δ ≤ t+δ'`); `0 ≤ δ ≤ δ'` by `linarith`. -- !--
/-- Interleaving is monotone in the shift: a `δ`-interleaving is a
`δ'`-interleaving for any `δ' ≥ δ`. -/
theorem Interleaved_mono {F G : Filtration α} {δ δ' : ℝ}
    (h : Interleaved F G δ) (hδ : δ ≤ δ') : Interleaved F G δ' := by
  refine ⟨by linarith [h.1], fun t => ?_, fun t => ?_⟩
  · exact Set.Subset.trans (h.2.1 t) (Filtration.sublevel_mono _ (by linarith))
  · exact Set.Subset.trans (h.2.2 t) (Filtration.sublevel_mono _ (by linarith))

-- !-- Chain the two interleavings' inclusions (cf. `stability_compose`); the shifts
-- !-- add since `t + (δ + δ') = (t + δ) + δ'`. -- !--
/-- **Additivity / triangle inequality at the relational level.**  A
`δ`-interleaving composed with a `δ'`-interleaving is a `(δ + δ')`-interleaving.
This is the engine behind the triangle inequality for `interleavingDist`. -/
theorem Interleaved_trans {F G H : Filtration α} {δ δ' : ℝ}
    (h₁ : Interleaved F G δ) (h₂ : Interleaved G H δ') :
    Interleaved F H (δ + δ') := by
  refine ⟨by linarith [h₁.1, h₂.1], fun t => ?_, fun t => ?_⟩
  · have := Set.Subset.trans (h₁.2.1 t) (h₂.2.1 (t + δ))
    rwa [add_assoc] at this
  · have := Set.Subset.trans (h₂.2.2 t) (h₁.2.2 (t + δ'))
    rwa [add_assoc, add_comm δ' δ] at this

/-! ## The interleaving distance -/

/-- **The interleaving distance** between two filtrations: the infimum of all
admissible interleaving shifts.  (With the Lean convention `sInf ∅ = 0`, two
never-interleaved filtrations are reported at distance `0`; promoting the codomain
to `EReal` to record `⊤` is left to future work — see the Lab Notebook.) -/
noncomputable def interleavingDist (F G : Filtration α) : ℝ :=
  sInf {δ : ℝ | Interleaved F G δ}

-- !-- Every admissible shift is `≥ 0` (first component of `Interleaved`), so
-- !-- `Real.sInf_nonneg` gives the bound. -- !--
/-- The interleaving distance is nonnegative. -/
theorem interleavingDist_nonneg (F G : Filtration α) : 0 ≤ interleavingDist F G :=
  Real.sInf_nonneg fun _ hx => hx.1

-- !-- `δ` lies in the shift set, which is bounded below by `0`; apply `csInf_le`. -- !--
/-- **Upper bound by any witness.**  Any admissible interleaving shift bounds the
interleaving distance from above. -/
theorem interleavingDist_le (F G : Filtration α) {δ : ℝ} (h : Interleaved F G δ) :
    interleavingDist F G ≤ δ :=
  csInf_le ⟨0, fun _ hx => hx.1⟩ h

-- !-- `≤ 0` from `interleavingDist_le` with `Interleaved_refl`, `≥ 0` from `nonneg`. -- !--
/-- The interleaving distance vanishes on the diagonal. -/
theorem interleavingDist_self (F : Filtration α) : interleavingDist F F = 0 :=
  le_antisymm
    (le_trans (interleavingDist_le _ _ (Interleaved_refl _)) (by norm_num))
    (interleavingDist_nonneg _ _)

-- !-- `Interleaved_symm` makes the two shift sets equal, hence equal infima. -- !--
/-- The interleaving distance is symmetric. -/
theorem interleavingDist_comm (F G : Filtration α) :
    interleavingDist F G = interleavingDist G F := by
  unfold interleavingDist
  congr! 2
  ext δ
  exact ⟨Interleaved_symm, Interleaved_symm⟩

/-! ## Cohen-Steiner–Edelsbrunner–Harer sublevel stability (1-Lipschitz form) -/

/-- Uniform `D`-closeness of two weight functions in sup-norm. -/
def WeightCloseBy (F G : Filtration α) (D : ℝ) : Prop :=
  ∀ σ : Finset α, |F.weight σ - G.weight σ| ≤ D

-- !-- Each direction is `stability_two_sided`; the shift `D ≥ 0` packages the
-- !-- symmetric bound into an `Interleaved`. -- !--
/-- **CESH stability (interleaving form).**  Two filtrations whose weights are
uniformly within `D` are `D`-interleaved. -/
theorem stability_supDist (F G : Filtration α) {D : ℝ}
    (hD : 0 ≤ D) (h : WeightCloseBy F G D) : Interleaved F G D :=
  ⟨hD, fun t => (Filtration.stability_two_sided F G h t).1,
       fun t => (Filtration.stability_two_sided F G h t).2⟩

-- !-- Combine `stability_supDist` with `interleavingDist_le`. -- !--
/-- **CESH stability, sharp `1`-Lipschitz form.**  The interleaving distance is
bounded by the sup-norm distance of the weights — persistence is `1`-Lipschitz in
the data. -/
theorem interleavingDist_le_supDist (F G : Filtration α) {D : ℝ}
    (hD : 0 ≤ D) (h : W
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — Persistent-Homology Stability (Boltzmann Bridge IV)

## Synthesis

`Applications/BoltzmannBridge/BottleneckStability.lean` closes the catalog's
persistent-homology arc. The earlier files built the filtration calculus
(`HigherPersistence`: `Filtration`, `sublevelFaces`, `sublevel_mono`, the
Vietoris–Rips `diamWeight`) and the relational interleaving lemmas
(`PersistenceStability`: `stability_interleaving`, `stability_compose`,
`stability_two_sided`). This cycle turns those scattered inequalities into a
single coherent metric theory:

* a named, symmetric, additively-composable interleaving relation
  `Interleaved F G δ` (`Interleaved_refl/symm/mono/trans`);
* a real-valued `interleavingDist` — nonnegative, `= 0` on the diagonal,
  symmetric, and bounded by any admissible shift
  (`interleavingDist_nonneg/le/self/comm`);
* the Cohen-Steiner–Edelsbrunner–Harer sublevel stability theorem in sharp
  `1`-Lipschitz form (`stability_supDist`, `interleavingDist_le_supDist`);
* a Gromov–Hausdorff / correspondence-distortion layer over *explicit* distance
  matrices `d : α → α → ℝ` (`diamWeightOf`, `diamFiltrationOf`), with the single
  load-bearing estimate `diamWeightOf_dist_le` (the diameter is `1`-Lipschitz in
  the data) yielding `vr_stability_interleaved` / `vr_stability_dist`;
* an end-to-end concrete verification on two `3`-point clouds
  (`cloud_distortion`, `cloud_stability`, `cloud_interleavingDist_le`).

The whole stability phenomenon collapses onto one inequality: *the simplex weight
is `1`-Lipschitz in the input metric*. Everything downstream is monotonicity
bookkeeping. Deliberate adversarial probing exposed exactly one fault line: the
`sInf`-based distance is honest only up to the `sInf ∅ = 0` convention, which is
where the next cycle should push.

## Results Summary

| Theorem | Statement | Status |
|---|---|---|
| `Interleaved_{refl,symm,mono,trans}` | interleaving is a graded preorder | ✅ proved |
| `interleavingDist_{nonneg,le,self,comm}` | a symmetric, grounded pre-distance | ✅ proved |
| `stability_supDist` / `interleavingDist_le_supDist` | CESH sublevel stability, sharp `1`-Lipschitz | ✅ proved |
| `diamWeightOf_dist_le` | VR diameter is `1`-Lipschitz in the distance matrix | ✅ proved |
| `vr_stability_interleaved` / `vr_stability_dist` | distortion `≤ ε` ⇒ `ε`-interleaving ⇒ bottleneck `≤ ε` | ✅ proved |
| `cloud_{distortion,stability,interleavingDist_le}` | concrete point-cloud certificate | ✅ proved |

All main results are `sorry`-free and depend only on `propext`,
`Classical.choice`, `Quot.sound`.

## Research Directions

### 1. The `EReal` interleaving distance is a true extended pseudometric
The current `interleavingDist` quietly breaks the triangle inequality because
Lean evaluates `sInf ∅ = 0`: two filtrations that are *never* interleaved are
reported at distance `0` rather than `+∞`. Replace the codomain by `EReal` (or
`ℝ≥0∞`), defining `interleavingEDist F G = sInf {(δ : EReal) | Interleaved F G δ}`,
an
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
