
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

**Title**: The parametric continuity theorem (`parametric_fixedPoint_continuous`) establish
**Domain**: Applications
**Mathematical framing**: # Future Directions: Parametric Fixed-Point Theory

## 1. Lipschitz Parametric Banach Theorem with Explicit Constants

The parametric continuity theorem (`parametric_fixedPoint_continuous`) establishes that the fixed-point map is continuous when the family varies continuously. A stronger result should hold: if the family `t ↦ F(t)` is Lipschitz in a metric parameter space with constant `L` (i.e., `dist(F(s)(x), F(t)(x)) ≤ L · dist(s,t)` uniformly in `x`), then `t ↦ x⋆(t)` is Lipschitz with constant `L/(1-K)`.

The key insight is that the bound `dist(x⋆(s), x⋆(t)) ≤ sup_x dist(F(s)(x), F(t)(x)) / (1-K)` already implicit in our proof gives the Lipschitz constant directly — no additional machinery is needed beyond plugging in the uniform Lipschitz hypothesis on the family.

Why now? The `contraction_fixedPoint_stability` theorem already handles the pointwise case. The upgrade to Lipschitz families is a one-line corollary once the uniform bound is formalized. This would directly connect to the implicit function theorem via the parametric contraction mapping approach.

## 2. Hölder Continuity of Fixed Points for Non-Uniformly Contracting Families

When the contraction factor itself varies with the parameter — `K(t) < 1` for each `t` but `sup_t K(t) = 1` — the fixed-point map may still be continuous but loses Lipschitz regularity. The conjecture is that if `K(t) ≤ 1 - c · dist(t, t₀)^β` for some `β > 0`, then the fixed-point map is Hölder continuous with exponent depending on `β`.

The key insight is that the denominator `1 - K(t)` in the stability bound degenerates as `K(t) → 1`, creating a singularity that Hölder regularity can still control. This bridges our sharp K=1 counterexample with the smooth K<1 theory.

Why now? The sharpness result (`contraction_sharpness`) precisely identifies where the theory breaks down. Understanding the transition region between K<1 (guaranteed fixed points) and K=1 (possible failure) requires exactly this Hölder analysis. Mathlib's `HolderWith` API provides the formalization target.

## 3. Equivariant Fixed Points for Group-Parametrized Families

If a group `G` acts on both the parameter space and the metric space, and the family of contracting maps is equivariant (`F(g·t)(g·x) = g · F(t)(x)`), then the fixed-point map should be equivariant as well (`x⋆(g·t) = g · x⋆(t)`). This would formalize the principle that symmetries of the causal structure are inherited by self-consistent solutions.

The key insight is that uniqueness of fixed points forces equivariance: since `g · x⋆(t)` is a fixed point of `F(g·t)` (by equivariance of the family), it must equal the unique fixed point `x⋆(g·t)`. The proof is a direct application of `fixedPoint_unique`.

Why now? The composition theorem (`ContractingWith.comp`) shows that the algebraic structure of contracting maps is well-behaved. Group equivariance is the natural next algebraic property to formalize, and connects to Mathlib's extensive `MulAction` framework.

## 4. Nadler's Theorem: Set-Valued Contractions

For a set-valued map `F : α → Closeds α` that is contracting under the Hausdorff metric (i.e., `hausdorffDist(F(x), F(y)) ≤ K · dist(x,y)` with `K < 1`), Nadler's theorem guarantees existence of a fixed point `x ∈ F(x)`. This generalizes the Banach theorem to nondeterministic dynamics.

The key insight is that the Banach iteration can be adapted: choose `x₁ ∈ F(x₀)` closest to `x₀`, then `x₂ ∈ F(x₁)` closest to `x₁`, etc. The contraction on the Hausdorff metric ensures this sequence is Cauchy, and the limit is a fixed point. The challenge is formalizing the "choose closest point" step using Mathlib's `EMetric.hausdorffDist`.

Why now? Mathlib has `EMetric.hausdorffDist` and `TopologicalSpace.Closeds`. The gap is connecting the Hausdorff metric contraction to pointwise fixed-point existence. Our parametric framework provides the template for handling the iteration argument.

## 5. Rate-Optimal Iteration for Non-Autonomous Contractions

Given a sequence of contracting maps `f₁, f₂, ...` with possibly different contraction factors `K_n < 1`, the composition `f_n ∘ ... ∘ f₁` converges to a unique "target" point. The conjecture is that the convergence rate is `∏ᵢ Kᵢ`, and when `∑ᵢ (1 - Kᵢ) = ∞`, convergence is guaranteed even though individual factors may approach 1.

The key insight is that `ContractingWith.comp` gives `K₁ · K₂` as the factor for the composition of two contractions. Iterating this, the composition of `n` maps has factor `∏ᵢ₌₁ⁿ Kᵢ`. The divergence condition `∑(1-Kᵢ) = ∞` ensures `∏ Kᵢ → 0`, guaranteeing convergence even in the non-stationary case.

Why now? The composition theorem is now proved, giving the base case. The extension to infinite products connects to Mathlib's `HasProd` API and provides convergence guarantees for adaptive algorithms where the contraction factor changes at each step (e.g., learning rate schedules in optimization).

Research domain: Applications
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/MachineLearning/FixedPoint/Parametric.lean
/-
# Parametric Fixed-Point Theory

This module extends the quantitative Banach contraction principle developed in
`MachineLearning.FixedPoint.Core` to *parametric* families of contractions.
The unifying engine is a single stability estimate

  `dist xf xg ≤ dist (f xg) (g xg) / (1 - K)`,

from which Lipschitz dependence of the fixed point on a metric parameter,
equivariance under symmetries, and non-autonomous composition rates all follow.

## Main Results

- `contraction_fixedPoint_stability` : the fundamental fixed-point stability bound.
- `lipschitz_parametric_fixedPoint`  : Lipschitz families have Lipschitz fixed-point maps.
- `equivariant_fixedPoint`           : symmetries of a contraction family are inherited
                                        by the fixed point (via uniqueness).
- `iteratedComp_contraction`         : a non-autonomous composition of `n` contractions
                                        contracts with constant `∏ i, K i`.
- `contraction_K_eq_one_no_fixedPoint` : sharpness — at `K = 1` fixed points may fail.

## Catalog synthesis

We build directly on `MachineLearning.FixedPoint.Core`:
* `eq_of_fixedPoints_of_contraction` (uniqueness) powers `equivariant_fixedPoint`;
* `contraction_comp` (two-map composition) is generalized by `iteratedComp_contraction`;
* the stability bound is the missing quantitative companion to the qualitative
  Banach existence theorem `exists_unique_fixedPoint_of_contraction`.
-/

import Mathlib
import MachineLearning.FixedPoint.Core

open Filter Topology Metric Set Function

namespace ParametricFixedPoint

-- !-- Lab Notebook: contraction_fixedPoint_stability -- !--
-- !-- Hypothesis: The distance between fixed points of two maps is controlled by how far -- !--
-- !--   the maps disagree at one of the fixed points, amplified by 1/(1-K). -- !--
-- !-- Result: Proved by a single triangle inequality + the contraction of `f`. -- !--
-- !-- Insight: Only ONE of the two maps need be a contraction; `g` is arbitrary. This is -- !--
-- !--   the quantitative core that all parametric corollaries reduce to. -- !--
-- !-- Failure analysis: A symmetric two-sided hypothesis is unnecessary, and even `0 ≤ K` -- !--
-- !--   is not needed; weakening to a single contraction makes the lemma maximally reusable. -- !--
-- !-- End Lab Notebook -- !--

/-- **Fixed-point stability.** If `f` is a `K`-contraction (`K < 1`) with fixed point
`xf`, and `g` is *any* map with fixed point `xg`, then the two fixed points differ by at
most `dist (f xg) (g xg) / (1 - K)`. This is the quantitative engine of parametric
fixed-point theory. -/
theorem contraction_fixedPoint_stability
    {α : Type*} [MetricSpace α]
    (f g : α → α) (K : ℝ) (hK1 : K < 1)
    (hf : ∀ x y, dist (f x) (f y) ≤ K * dist x y)
    {xf xg : α} (hxf : f xf = xf) (hxg : g xg = xg) :
    dist xf xg ≤ dist (f xg) (g xg) / (1 - K) := by
  -- !-- triangle inequality `dist xf xg ≤ dist (f xf) (f xg) + dist (f xg) (g xg)`,
  --     then absorb the contracted term into the LHS and divide by `1 - K > 0`. -- !--
  have h_triangle : dist xf xg ≤ dist (f xf) (f xg) + dist (f xg) (g xg) := by
    simpa [hxf, hxg] using dist_triangle xf (f xg) xg
  rw [le_div_iff₀] <;> nlinarith [hf xf xg]

-- !-- Lab Notebook: lipschitz_parametric_fixedPoint -- !--
-- !-- Hypothesis: If a family `F : β → α → α` is uniformly `L`-Lipschitz in the parameter -- !--
-- !--   and each `F t` is a `K`-contraction, the fixed-point map is `L/(1-K)`-Lipschitz. -- !--
-- !-- Result: One-line corollary of `contraction_fixedPoint_stability`. -- !--
-- !-- Insight: The explicit constant `L/(1-K)` falls out of the stability denominator with -- !--
-- !--   no extra machinery — confirming Direction 1 of the seed FUTURE_DIRECTIONS. -- !--
-- !-- Failure analysis: Stating Lipschitz dependence directly would require redoing the -- !--
-- !--   triangle-inequality argument; routing through stability avoids duplication. -- !--
-- !-- End Lab Notebook -- !--

/-- **Lipschitz parametric Banach theorem (explicit constant).**
Let `F : β → α → α` be a family where each `F t` is a `K`-contraction, the family is
uniformly `L`-Lipschitz in the parameter (`dist (F s x) (F t x) ≤ L * dist s t`), and
`xstar t` is a fixed point of `F t`. Then the fixed-point map is `L/(1-K)`-Lipschitz. -/
theorem lipschitz_parametric_fixedPoint
    {α β : Type*} [MetricSpace α] [PseudoMetricSpace β]
    (F : β → α → α) (K L : ℝ) (hK1 : K < 1)
    (hcontr : ∀ t, ∀ x y, dist (F t x) (F t y) ≤ K * dist x y)
    (hlip : ∀ s t x, dist (F s x) (F t x) ≤ L * dist s t)
    (xstar : β → α) (hfix : ∀ t, F t (xstar t) = xstar t)
    (s t : β) :
    dist (xstar s) (xstar t) ≤ (L / (1 - K)) * dist s t := by
  rw [div_mul_eq_mul_div, le_div_iff₀]
  · have := hlip s t (xstar t)
    have := hcontr s (xstar s) (xstar t)
    have := dist_triangle (xstar s) (F s (xstar t)) (xstar t)
    simp_all +decide [dist_comm]
    nlinarith
  · linarith

-- !-- Lab Notebook: equivariant_fixedPoint -- !--
-- !-- Hypothesis: A symmetry `φ` intertwining two contractions (`φ ∘ f = f' ∘ φ`) maps the -- !--
-- !--   fixed point of `f` to the fixed point of `f'`. -- !--
-- !-- Result: Proved via uniqueness of fixed points (Core.eq_of_fixedPoints_of_contraction). -- !--
-- !-- Insight: Equivariance is *forced* by uniqueness, not built in — symmetries of the -- !--
-- !--   dynamics are automatically inherited by self-consistent solutions. -- !--
-- !-- Failure analysis: A `MulAction` formulation is heavier; the bare intertwining map `φ` -- !--
-- !--   captures the same content and is more reusable. -- !--
-- !-- End Lab Notebook -- !--

/-- **Equivariance of fixed points.** If `φ` intertwines `f` and `f'`
(`φ (f x) = f' (φ x)` for all `x`) and `f'` is a `K`-contraction, then `φ` sends the
fixed point of `f` to the fixed point of `f'`. Symmetries of the family are inherited
by the fixed point. -/
theorem equivariant_fixedPoint
    {α : Type*} [MetricSpace α]
    (f f' φ : α → α) (K : ℝ) (hK0 : 0 ≤ K) (hK1 : K < 1)
    (hf' : ∀ x y, dist (f' x) (f' y) ≤ K * dist x y)
    (hconj : ∀ x, φ (f x) = f' (φ x))
    {x x' : α} (hx : f x = x) (hx' : f' x' = x') :
    φ x = x' := by
  -- !-- `φ x` is a fixed point of `f'` (since `f' (φ x) = φ (f x) = φ x`), so it equals the
  --     unique fixed point `x'` by `eq_of_fixedPoints_of_contraction`. -- !--
  convert eq_of_fixedPoints_of_contraction f' K hK0 hK1 hf' _ hx'
  rw [← hconj, hx]

/-- A non-autonomous composition `g (n-1) ∘ ⋯ ∘ g 0`. -/
def iteratedComp {α : Type*} (g : ℕ → α → α) : ℕ → (α → α)
  | 0 => id
  | (n + 1) => g n ∘ iteratedComp g n

@[simp] theorem iteratedComp_zero {α : Type*} (g : ℕ → α → α) :
    iteratedComp g 0 = id := rfl

@[simp] theorem iteratedComp_succ {α : Type*} (g : ℕ → α → α) (n : ℕ) :
    iteratedComp g (n + 1) = g n ∘ iteratedComp g n := rfl

-- !-- Lab Notebook: iteratedComp_contraction -- !--
-- !-- Hypothesis: Composing `n` maps with individual constants `K i` gives a contraction -- !--
-- !--   with constant `∏ i ∈ range n, K i`. -- !--
-- !-- Result: Proved by induction on `n`, generalizing Core.contraction_comp from 2 maps. -- !--
-- !-- Insight: Non-autonomous (varying-`K`) dynamics contract at the *product* rate; the -- !--
-- !--   stationary `K^n` bound is the special case `K i = K`. -- !--
-- !-- Failure analysis: Using `Fin n → _` index types creates coercion friction; indexing by -- !--
-- !--   `ℕ` with a `Finset.range` product is far smoother for induction. -- !--
-- !-- End Lab Notebook -- !--

/-- **Non-autonomous composition rate.** The composition of `n` maps with individual
contraction constants `K i ≥ 0` is a contraction with constant `∏ i ∈ range n, K i`.
This generalizes the two-map composition lemma `contraction_comp` from the catalog. -/
theorem iteratedComp_contraction
    {α : Type*} [MetricSpace α]
    (g : ℕ → α → α) (K : ℕ → ℝ) (hK0 : ∀ i, 0 ≤ K i)
    (hg : ∀ i x y, dist (g i x) (g i y) ≤ K i * dist x y) :
    
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: Parametric Fixed-Point Theory

## Synthesis

This cycle isolated the *quantitative engine* of parametric Banach theory: a single
stability estimate `dist xf xg ≤ dist (f xg) (g xg) / (1 - K)`
(`contraction_fixedPoint_stability`). The decisive structural insight is that this bound
needs only **one** of the two maps to be a contraction — `g` is completely arbitrary, and
even `0 ≤ K` is unnecessary. Once isolated, every parametric phenomenon in the seed
document reduces to plugging a hypothesis into this one inequality: uniform Lipschitz
dependence (`lipschitz_parametric_fixedPoint`, Direction 1 of the seed) becomes a literal
one-liner with the *exact* advertised constant `L/(1-K)`.

The second theme is that **uniqueness does the algebra for free**. Equivariance under
symmetries (`equivariant_fixedPoint`) is not an extra hypothesis to be imposed but a
*forced* consequence: any intertwining map `φ` sends a fixed point to a fixed point, and
uniqueness (`eq_of_fixedPoints_of_contraction` from the catalog `Core`) collapses the two.
The same uniqueness principle is what makes the non-autonomous composition rate
(`iteratedComp_contraction`, generalizing the catalog's two-map `contraction_comp` to the
product `∏ K i`) interesting rather than tautological.

The Critic's contribution — `contraction_K_eq_one_no_fixedPoint` — pins down the exact
failure locus: the translation `x ↦ x+1` is a `1`-Lipschitz isometry of ℝ with no fixed
point, so the denominator `1-K` genuinely cannot vanish. Nothing surprising *failed* this
cycle; the main lesson was negative-engineering: stating each corollary directly (rather
than routing through the stability bound) would have duplicated the triangle-inequality
argument three times. Centralizing it is what made the batch tractable.

## Results Summary

- `contraction_fixedPoint_stability`: proved — the fundamental bound `dist xf xg ≤ dist (f xg) (g xg)/(1-K)`, requiring only that `f` contracts; the engine for everything below.
- `lipschitz_parametric_fixedPoint`: proved — a uniformly `L`-Lipschitz family of `K`-contractions has an `L/(1-K)`-Lipschitz fixed-point map (explicit constant).
- `equivariant_fixedPoint`: proved — an intertwining symmetry `φ` of two contractions maps fixed point to fixed point, i.e. symmetries are inherited by self-consistent solutions.
- `iteratedComp_contraction`: proved — composition of `n` maps with constants `K i` contracts with factor `∏ i∈range n, K i`, generalizing the catalog two-map rule.
- `contraction_K_eq_one_no_fixedPoint`: disproved (the `K=1` existence claim) — `x ↦ x+1` is a `1`-Lipschitz map on ℝ with no fixed point, proving `K<1` is sharp.

## Research Directions

### Direction 1: Hölder fixed points for degenerating contraction factors
**Hypothesis**: If a family of contractions satisfies `K(t) ≤ 1 - c · dist(t,t₀)^β` (with
`β > 0`, `c > 0`) rather than a uniform `K < 1`, then the fixed-point map is Hölder
continuous near `t₀` with an exponent determined by `β` 
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
