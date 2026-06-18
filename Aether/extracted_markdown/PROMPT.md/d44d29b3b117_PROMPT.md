
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
    {"name": "descriptive_name", "pseudocode": "Brief description", "code": "# full Python source..."}
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

**Title**: Tropical Amoebas and Ronkin Functions
**Domain**: Novelty
**Mathematical framing**: Prove that the tropical amoeba of a Laurent polynomial is the negative logarithm of its zero set. Show that the Ronkin function is convex and piecewise-linear on the amoeba complement. Connect tropical amoebas to tropical geometry via the Maslov dequantization.
Research domain: Novelty
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Physics/Landauer.lean
/-
# Tropical Thermodynamics: Landauer's Principle

This file establishes a tropical (min-plus) formulation of Landauer's principle,
the foundational result linking irreversible computation to entropy loss.

## Main Results

* `entropyDefect` — the tropical entropy defect of a map, measuring information loss
* `card_range_eq_one_of_constant` — a constant map has range of cardinality 1
* `tropical_landauer_finite` — erasure of ≥2 states costs ≥ log 2 in entropy defect
* `tropical_landauer_noninjective` — any non-injective map has non-negative entropy defect

## Mathematical Context

Landauer's principle (1961) states that erasing one bit of information requires
dissipating at least kT ln 2 of energy. Our tropical formulation captures the
information-theoretic core: the entropy defect log|α| - log|range(f)| measures
how many distinguishable states are collapsed by f. For an erasure map (constant
function) on ≥2 states, this defect is at least log 2.

This is the zero-temperature limit of classical Landauer: when thermal fluctuations
vanish, entropy loss reduces to a purely combinatorial quantity — the logarithm of
the cardinality collapse ratio.
-/

import Mathlib

open Real Set Fintype

/-- The **tropical entropy defect** of a map `f : α → β` between finite types.
Measures the information lost by applying `f`, in natural-log units.
Equal to `log |α| - log |range f|`. -/
noncomputable def entropyDefect
    {α β : Type*} [Fintype α] [Fintype β] [DecidableEq β]
    (f : α → β) : ℝ :=
  Real.log (Fintype.card α) - Real.log (Fintype.card (Set.range f))

/-
The range of a constant function on a nonempty type has cardinality 1.
-/
theorem card_range_eq_one_of_constant
    {α β : Type*} [Fintype α] [Fintype β] [DecidableEq β]
    [Nonempty α]
    (f : α → β)
    (hconst : ∀ a a', f a = f a') :
    Fintype.card (Set.range f) = 1 := by
  simp +decide [ show range f = { f ( Classical.arbitrary α ) } from Set.eq_singleton_iff_unique_mem.2 ⟨ Set.mem_range.2 ⟨ Classical.arbitrary α, rfl ⟩, fun b hb => by obtain ⟨ a, rfl ⟩ := Set.mem_range.1 hb; exact hconst _ _ ⟩ ]

/-
**Tropical Landauer's Principle (Erasure Bound).**
For a constant map on a finite type with at least 2 elements,
the entropy defect is at least log 2. This is the tropical
analogue of Landauer's principle: erasing one bit of information
incurs an irreducible entropy cost.

Mathematically: if `f` is constant and `|α| ≥ 2`, then
`log |α| - log |range f| ≥ log 2`, which simplifies to
`log |α| ≥ log 2` since `|range f| = 1`.
-/
theorem tropical_landauer_finite
    {α β : Type*} [Fintype α] [Fintype β]
    [DecidableEq α] [DecidableEq β]
    (f : α → β)
    (hconst : ∀ a a', f a = f a')
    (hcard : 2 ≤ Fintype.card α) :
    Real.log 2 ≤ entropyDefect f := by
  have h_range : Fintype.card ( Set.range f ) = 1 := by
    rcases isEmpty_or_nonempty α with h | h;
    · simp +decide [ card ] at hcard;
    · convert card_range_eq_one_of_constant f hconst;
  unfold entropyDefect;
  rw [ h_range, Nat.cast_one, Real.log_one, sub_zero ] ; gcongr ; norm_cast

/-
**Tropical Irreversibility Bound.**
Any non-injective map between finite types has non-negative entropy defect.
This captures the fundamental asymmetry of irreversible computation:
collapsing states can only increase entropy (decrease information).

The proof uses the fact that a non-injective map on a finite type
must have strictly smaller range than domain.
-/
theorem tropical_landauer_noninjective
    {α β : Type*} [Fintype α] [Fintype β]
    [DecidableEq α] [DecidableEq β]
    (f : α → β)
    (hninj : ¬ Function.Injective f) :
    0 ≤ entropyDefect f := by
  refine' sub_nonneg_of_le ( Real.log_le_log _ _ );
  · rcases isEmpty_or_nonempty α with ( h | h ) <;> simp_all +decide;
    exact hninj fun x y => h.elim x;
  · exact_mod_cast Fintype.card_range_le f


-- NEW_FILE: Catalog/Physics/UncannyValley.lean
import Mathlib

/-!
# The Mathematical Uncanny Valley

We formalize the "mathematical uncanny valley" phenomenon: a model of how trust
in mathematical proofs varies with rigor level. The key insight is that proofs at
intermediate rigor levels (almost-but-not-quite rigorous) can be *less* trusted
than either informal intuitions or fully formal proofs.

## Mathematical Model

We model trust as `U(r) = r - α · S(r)` where:
- `r ∈ [0,1]` is the rigor level
- `S(r) = r²(1-r)` is the "suspicion function" — how suspicious the proof appears
- `α > 0` is the suspicion sensitivity of the mathematical community

The suspicion function `S(r) = r²(1-r)` captures the key dynamic: suspicion requires
both high apparent rigor (the `r²` factor) and incompleteness (the `(1-r)` factor).
Purely informal proofs (r ≈ 0) generate no suspicion because they don't claim rigor.
Fully formal proofs (r = 1) have no gaps. The maximum suspicion occurs at r = 2/3.

## Main Results

* `suspicionFn_le_four_twentysevenths` — The suspicion function is bounded by 4/27 on [0,1]
* `valleyModel_has_valley` — For α > 4, the trust model dips below both endpoints
* `valley_interior_minimum` — Continuous valley functions have interior minima (EVT)
* `valleyModel_nonneg_of_small_alpha` — The threshold α = 4 is sharp
* `epistemic_barrier_depth_bound` — Abstract barrier theorem for general suspicion functions

## Novel Concepts

* `EpistemicBarrier` — Structure capturing barrier properties near completion
* `HasValley` — Predicate for the uncanny valley phenomenon in general functions
-/

open Set Real

noncomputable section

/-! ### Core Definitions -/

/-- The suspicion function: models the level of suspicion generated by a proof
at rigor level `r ∈ [0,1]`. The product `r²(1-r)` captures the idea that suspicion
requires both high apparent rigor (`r²` factor) and incompleteness (`(1-r)` factor).

Informal proofs (r ≈ 0) don't trigger suspicion because they don't claim rigor.
Fully formal proofs (r = 1) have no gaps. Maximum suspicion is at r = 2/3. -/
def suspicionFn (r : ℝ) : ℝ := r ^ 2 * (1 - r)

/-- The uncanny valley trust model: `U(r) = r - α · r²(1-r)`.

Trust equals raw rigor minus a penalty for "suspicious gaps". The parameter `α`
represents the mathematical community's sensitivity to gaps in almost-rigorous
proofs. Higher `α` means the community is more suspicious. -/
def valleyModel (α : ℝ) (r : ℝ) : ℝ := r - α * suspicionFn r

/-- A function `f` has the **valley property** on the interval `(a, b)` if there
exists an interior point where `f` dips below both endpoint values. This is the
mathematical formalization of the "uncanny valley" shape. -/
def HasValley (f : ℝ → ℝ) (a b : ℝ) : Prop :=
  a < b ∧ ∃ x, a < x ∧ x < b ∧ f x < f a ∧ f x < f b

/-- An **epistemic barrier** captures the phenomenon where approaching full
rigor creates a trust deficit that must be overcome. This is the mathematical
analog of an energy barrier in physics. -/
structure EpistemicBarrier where
  /-- The rigor level where suspicion peaks -/
  peakRigor : ℝ
  /-- The maximum trust deficit (barrier height) -/
  height : ℝ
  /-- Range of rigor levels where trust is depressed -/
  width : ℝ
  /-- Peak is in the interior of [0,1] -/
  peak_in_range : 0 < peakRigor ∧ peakRigor < 1
  /-- Barrier has positive height -/
  height_pos : 0 < height
  /-- Barrier has positive width -/
  width_pos : 0 < width

/-- The valley depth at point `x`: how far below the minimum endpoint value
the function dips. Positive depth indicates a valley. -/
def valleyDepth (f : ℝ → ℝ) (a b : ℝ) (x : ℝ) : ℝ :=
  min (f a) (f b) - f x

/-! ### The Suspicion Peak Theorem -/

/-
**Suspicion Peak Theorem**: The suspicion function `r²(1-r)` is bounded
above by `4/27` on `[0,1]`. This bound is tight (achieved at `r = 2/3`).

The proof uses the AM-GM inequality applied to `(r/2, r/2, 1-r)`:
their product `r²(1-r)/4` is at most `(1/3)³ = 1/27` by AM-GM,
giving `r²(1-r) ≤ 4/27`.
-/
theorem suspicionFn_le_four_twentysevenths (r : ℝ) (hr0 : 0 ≤ r) (_hr1 : r ≤ 1) :
    suspicionFn r ≤ 4 / 27 := by
  unfold suspicionF
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: Tropical Amoebas, Ronkin Functions, and Maslov Dequantization

The file `Catalog/Tropical/AmoebaRonkin.lean` builds a computation-free core of amoeba
theory: the tropical polynomial (amoeba spine) `trop f (x) = max_i (log|c_i| + ⟨m_i,x⟩)` is
proved convex and piecewise-linear, its dominance (amoeba-complement) regions are proved
convex with constant integer slope (the order map), and the Maslov-deformed Ronkin function
`R_t(x) = t·log Σ_i exp(A_i(x)/t)` is shown to converge to the spine as `t → 0⁺` with the
explicit rate `|R_t − trop f| ≤ t·log N`. This realises the Maslov-dequantization theme of
`TSM.zeroTemperature_limit` (`SemiclassicalLimit.lean`) in the geometric amoeba setting, and
extends the log-sum-exp analysis of `LSEConvexity.lean`. Below are concrete, falsifiable
continuations.

## 1. Strict convexity of the deformed Ronkin function transverse to the recession cone

The theorem `ronkinDeform_convexOn` already proves `R_t` convex via the finite Hölder
inequality `∑_i u_i^a v_i^b ≤ (∑_i u_i)^a (∑_i v_i)^b`. The natural strengthening is
*strictness*: `R_t` should be **strictly convex** in every direction `v` that is not
orthogonal to all the differences `m_i − m_j`, with equality in Hölder forcing all the
ratios `exp(A_i(x)/t)/exp(A_i(y)/t)` to coincide. The key insight is that the Hölder
inequality is an equality exactly when the two summed vectors are proportional, which pins
down the directions of non-strictness to the lineality space `⋂_{i,j} (m_i − m_j)^⊥` — the
recession directions of the amoeba spine. Why now? The convexity proof already isolates the
Hölder step, so its equality case (`Finset.inner_le_weight_mul_Lp` equality conditions in
Mathlib) is the only missing ingredient, turning a qualitative result into a sharp
characterisation of where the Ronkin function fails to curve — precisely the spine itself.

## 2. The Legendre dual of the Ronkin function is the Newton polytope

Define the Legendre transform `R_t^*(p) = sup_x (⟨p,x⟩ − R_t(x))`. The conjecture is that as
`t → 0⁺`, `R_t^*` converges to the (negated) support function of the Newton polytope
`Δ_f = conv{m_i}`, i.e. `dom(trop f ^*) = Δ_f` and the order map of Theorem
`tropPoly_slope_on_dominant` sends each amoeba-complement component to a distinct lattice
vertex `m_k ∈ Δ_f`. The key insight is that the order map is exactly the subgradient of the
convex function `trop f`, so the amoeba complement is in bijection with the faces of `Δ_f`
hit by the Legendre dual. Why now? `LegendreDuality.lean` already provides the conjugation
infrastructure in this catalog, so the bijection "complement components ↔ Newton lattice
points" can be stated and tested on explicit small supports (e.g. `1 + z + w`, the line, with
three complement components and three vertices).

## 3. Quantitative spine separation and the tentacle count

Conjecture: the number of unbounded complement components ("tentacles") of the amoeba equals
the number of indices `k` whose dominance regi
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
of objects (not placeholder strings). Include future directions from Phase A
in the future_directions field.

Be vivid, be precise, be world-class. The math has already been done — now
make it beautiful to read.
