
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

**Title**: Quasi-symmetric maps generalize bi-Lipschitz maps by allowing the distortion con
**Domain**: Novelty
**Mathematical framing**: # Future Directions: Fractal Topology and Hausdorff Dimension Invariance

## 1. Quantitative Distortion Bounds for Quasi-Symmetric Maps

Quasi-symmetric maps generalize bi-Lipschitz maps by allowing the distortion constant to depend on scale. A natural conjecture: if f : X → Y is η-quasi-symmetric (meaning there exists η : [0,∞) → [0,∞) with edist(f(x), f(a)) / edist(f(x), f(b)) ≤ η(edist(x,a) / edist(x,b))), then dimH(f(S)) can be bounded in terms of dimH(S) and the modulus η. The key insight is that quasi-symmetric maps satisfy a local version of the bi-Lipschitz condition at each scale, so the Hausdorff dimension distortion is controlled by the asymptotic behavior of η near 0 and ∞. Why now? Our `AntilipschitzOnWith` infrastructure provides the local lower bound machinery needed; extending it to scale-dependent constants is the natural next step.

## 2. Hausdorff Dimension of Product Sets: The Full Inequality

The classical result states dimH(A × B) ≥ dimH(A) + dimH(B) for any metric spaces, with equality when A satisfies certain regularity conditions (e.g., Ahlfors regularity). Formalizing this in Lean would require developing the product metric space Hausdorff measure theory. The key insight is that the product Hausdorff measure satisfies μH^{s+t}(A × B) ≥ μH^s(A) · μH^t(B), which can be proved using Frostman's lemma or direct covering arguments. Why now? Mathlib already has `dimH` and product metric spaces; the missing piece is the covering-theoretic argument connecting product coverings to factor coverings, which our Lipschitz inverse technique (`dimH_image_eq_of_lipschitz_inverse`) could assist via projection maps.

## 3. Conformal Dimension as a Topological Invariant

The conformal dimension of a metric space X is defined as cdim(X) = inf{dimH(Y) : Y quasi-symmetrically equivalent to X}. This is a genuine topological invariant (invariant under quasi-symmetric homeomorphisms). Conjecturally, for self-similar fractals satisfying the open set condition, cdim equals the Ahlfors regular conformal dimension, which can be computed via moduli of curve families. The key insight is that our `dimH_eq_of_biLipschitzOn_fullDim` theorem is the bi-Lipschitz special case of what should hold for quasi-symmetric maps, and cdim captures exactly what remains after quotienting out by quasi-symmetric equivalence. Why now? The infrastructure for `AntilipschitzOnWith` and dimension preservation under Lipschitz inverses provides the foundation; the next step is extending to the quasi-symmetric category.

## 4. Dimension Spectrum of IFS Attractors via Lipschitz Sections

For an iterated function system (IFS) {f₁, ..., fₙ} of contractions on a complete metric space, the attractor K satisfies dimH(K) ≤ s where s is the similarity dimension (solution to Σ rᵢˢ = 1). When the IFS satisfies the open set condition, equality holds. A formalization strategy: define the coding map π : {1,...,n}^ℕ → K, show it is Hölder continuous (using contractivity), and show it has a Lipschitz section on a dense subset (using the open set condition). Then apply our `dimH_image_bounds_of_holderOnWith_antilipschitzOnWith` to get both directions of the dimension bound. The key insight is that the coding map is Hölder with exponent related to the contraction ratios, and the open set condition provides the antilipschitz inverse needed for the lower bound. Why now? The Hölder-antilipschitz distortion bounds we proved are precisely the tool needed to formalize this classical argument.

## 5. Bi-Lipschitz Embedding Dimension of Fractals

Define the bi-Lipschitz embedding dimension of a compact metric space X as bldim(X) = inf{n ∈ ℕ : X bi-Lipschitz embeds into ℝⁿ}. The Assouad embedding theorem guarantees bldim(X) ≤ C·dim_A(X) for doubling spaces, where dim_A is the Assouad dimension. Conjecture: for self-similar fractals, bldim equals the ceiling of the Hausdorff dimension. The key insight is that our `biLipschitzOn_dimH_image_eq` theorem shows bi-Lipschitz embeddings preserve dimH exactly, so bldim(X) ≥ ⌈dimH(X)⌉ follows immediately (since dimH(ℝⁿ) = n). The upper bound requires constructive embedding arguments specific to each fractal. Why now? The dimension preservation result `biLipschitzOn_dimH_image_eq` gives the lower bound for free; formalizing the Assouad embedding theorem would yield the upper bound and complete the picture.

Research domain: Novelty
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Geometry/QuasiSymmetricDimension.lean
/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Quasi-symmetric gauges, the bi-Lipschitz monoid, and Hausdorff-dimension invariance

This file deepens the quasi-symmetric theory begun in
`Catalog/Applications/QuasiSymmetric/Maps.lean` (definitions `IsQuasisymmetric`,
`IsBiLipschitzWith`; theorems `biLipschitz_isQuasisymmetric`, `isQuasisymmetric_comp`,
`isQuasisymmetric_constant_or_injective`) and connects it, for the first time in this
project, to the measure-theoretic invariant `dimH` and to the set-local distortion theory
of `Catalog/Geometry/QuasiSymmetricComposition.lean`.

A homeomorphism `f` between metric spaces is *η-quasisymmetric* when the relative
distortion of any triple of points is controlled by a single one-variable gauge `η`:

  `dist (f x) (f a) ≤ η (dist x a / dist x b) * dist (f x) (f b)`.

The new contributions are organised around two structural ideas.

* **Gauge calculus.** The gauge is not rigid data: it can be enlarged
  (`IsQuasisymmetric.mono_gauge`), it controls *eccentricity* at a single scale
  (`IsQuasisymmetric.eccentricity`: equidistant points cannot be spread by more than
  `η 1`), and it *iterates* — the `n`-fold iterate of an injective quasisymmetric self-map
  is again quasisymmetric, with gauge the `n`-fold iterate of `η`
  (`isQuasisymmetric_iterate`).  This last fact is exactly the input needed to attack the
  dimension theory of iterated function systems.

* **The bi-Lipschitz monoid and its dimension shadow.** Bi-Lipschitz maps are closed
  under composition with multiplicative constants (`isBiLipschitzWith_comp`) and contain
  the identity (`isBiLipschitzWith_id`); they therefore form a monoid sitting inside the
  quasisymmetric maps (via the linear gauge of `biLipschitz_isQuasisymmetric`).  The
  payoff is the **cross-domain bridge** `IsBiLipschitzWith.dimH_image_eq`: a bi-Lipschitz
  map preserves Hausdorff dimension on every set.  This is the global, conformal-geometry
  packaging of the set-local `dimH_image_eq_of_lipschitzOn_antilipschitzOn` from
  `QuasiSymmetricComposition.lean`, now phrased directly in terms of the `dist`-based
  bi-Lipschitz predicate used throughout the quasisymmetric files.
-/

/-
!-- Lab Notebook: QuasiSymmetricDimension -- !--
Hypothesis: The relative-distortion gauge of a quasisymmetric map admits a small but
  complete "calculus" (enlargement, single-scale eccentricity, iteration), and the
  bi-Lipschitz sub-class — being a monoid — should preserve Hausdorff dimension, bridging
  the conformal `dist`-predicate to Mathlib's measure-theoretic `dimH`.
Result: All five target theorems proved with no `sorry`.  `mono_gauge` and `eccentricity`
  are one-line consequences of monotonicity of multiplication and the ratio collapsing to
  `1`; `isBiLipschitzWith_comp`/`isBiLipschitzWith_id` give the monoid; `dimH_image_eq`
  converts the `dist` bounds to `LipschitzWith`/`AntilipschitzWith` and applies Mathlib's
  `LipschitzWith.dimH_image_le` and `AntilipschitzWith.le_dimH_image`; `isQuasisymmetric_iterate`
  is an induction on top of the reproduced `isQuasisymmetric_comp`.
Insight: The constant `L` of a bi-Lipschitz map serves *simultaneously* as a Lipschitz
  constant and an antilipschitz constant (`L⁻¹ ≤ · ` rearranges to `· ≤ L`), so a single
  `1 ≤ L` packages both halves of dimension invariance.  Iteration of the gauge is the
  algebraic skeleton of the Hölder exponent that appears in IFS coding maps.
Failure analysis: The only friction is the `ℝ → ℝ≥0` coercion needed to feed `dist`-based
  bounds into the `ℝ≥0`-indexed Lipschitz API; resolved by taking the constant `⟨L, _⟩`.
-- !-- End Lab Notebook -- !--
-/

import Mathlib

open Set Function
open scoped ENNReal NNReal

namespace QuasiSymmetric

variable {X Y Z : Type*} [MetricSpace X] [MetricSpace Y] [MetricSpace Z]

/-- `f` is `η`-quasisymmetric: the distortion of every triple `(x, a, b)` with `x ≠ b`
is controlled by the one-variable gauge `η` applied to the input distance ratio.
(Reproduced from `Catalog/Applications/QuasiSymmetric/Maps.lean`.) -/
def IsQuasisymmetric (f : X → Y) (η : ℝ → ℝ) : Prop :=
  ∀ x a b : X, x ≠ b →
    dist (f x) (f a) ≤ η (dist x a / dist x b) * dist (f x) (f b)

/-- `f` is `L`-bi-Lipschitz: absolute distances are distorted by a factor in `[L⁻¹, L]`.
(Reproduced from `Catalog/Applications/QuasiSymmetric/Maps.lean`.) -/
def IsBiLipschitzWith (f : X → Y) (L : ℝ) : Prop :=
  1 ≤ L ∧ ∀ x y : X, L⁻¹ * dist x y ≤ dist (f x) (f y) ∧ dist (f x) (f y) ≤ L * dist x y

/-- **Composition of quasisymmetric maps** (reproduced from
`Catalog/Applications/QuasiSymmetric/Maps.lean`, needed below for iteration). -/
theorem isQuasisymmetric_comp (f : X → Y) (g : Y → Z) (ηf ηg : ℝ → ℝ)
    (hf : IsQuasisymmetric f ηf) (hg : IsQuasisymmetric g ηg)
    (hmono : Monotone ηg) (hinj : Function.Injective f) :
    IsQuasisymmetric (g ∘ f) (ηg ∘ ηf) := by
  intro x a b hxb; have := hg (f x) (f a) (f b); simp_all +decide [hinj.eq_iff]
  refine le_trans this (mul_le_mul_of_nonneg_right (hmono ?_) dist_nonneg)
  exact div_le_iff₀ (dist_pos.mpr (hinj.ne hxb)) |>.2 (hf x a b hxb)

/-! ## Gauge calculus -/

/-
!-- Enlarge the gauge: multiply the QS inequality by the same nonneg base distance. -- !--

**Gauge enlargement.** A quasisymmetric map stays quasisymmetric under any pointwise
larger gauge.  Quasisymmetry is a *property of having some* controlling gauge.
-/
theorem IsQuasisymmetric.mono_gauge {f : X → Y} {η η' : ℝ → ℝ}
    (h : IsQuasisymmetric f η) (hle : ∀ t, η t ≤ η' t) :
    IsQuasisymmetric f η' := by
  exact fun x a b hxb => le_trans ( h x a b hxb ) ( mul_le_mul_of_nonneg_right ( hle _ ) ( dist_nonneg ) )

/-
!-- For equidistant a,b the ratio is exactly 1, so the gauge is evaluated at 1. -- !--

**Single-scale eccentricity.** If `a` and `b` are equidistant from `x`, then their
images cannot be spread apart by more than the factor `η 1`.  This is the precise sense in
which a quasisymmetric map sends "round" configurations to configurations of bounded
eccentricity — the conceptual reason quasisymmetry is a conformal notion.
-/
theorem IsQuasisymmetric.eccentricity {f : X → Y} {η : ℝ → ℝ}
    (h : IsQuasisymmetric f η) {x a b : X} (hb : x ≠ b)
    (heq : dist x a = dist x b) :
    dist (f x) (f a) ≤ η 1 * dist (f x) (f b) := by
  simpa [ heq, ne_of_gt ( dist_pos.mpr hb ) ] using h x a b hb

/-
!-- Induction on n: split f^[n+1] = f^[n] ∘ f and apply isQuasisymmetric_comp with
outer gauge η^[n] (monotone via Monotone.iterate) and inner injective f. -- !--

**Iteration of the gauge.** The `n`-fold iterate of an injective `η`-quasisymmetric
self-map is `η^[n]`-quasisymmetric.  Iterating the *map* iterates the *gauge*; this is the
algebraic skeleton underlying the Hölder exponents of iterated function systems.
-/
theorem isQuasisymmetric_iterate {f : X → X} {η : ℝ → ℝ}
    (h : IsQuasisymmetric f η) (hmono : Monotone η) (hinj : Function.Injective f) (n : ℕ) :
    IsQuasisymmetric (f^[n]) (η^[n]) := by
  induction' n with n ih;
  · intro x a b hx; by_cases h : x = b <;> simp_all +decide ;
  · convert isQuasisymmetric_comp ( f^[n] ) f ( η^[n] ) η ih h _ _ using 1;
    · exact Function.iterate_succ' f n;
    · exact Function.iterate_succ' η n;
    · exact hmono;
    · exact hinj.iterate n

/-! ## The bi-Lipschitz monoid -/

/-
!-- 1 ≤ L*M from the two unit lower bounds; chain the upper/lower bounds through f x. -- !--

**Bi-Lipschitz maps compose**, with the constants multiplying: `g ∘ f` is
`(L · M)`-bi-Lipschitz when `f` is `L`- and `g` is `M`-bi-Lipschitz.
-/
theorem isBiLipschitzWith_comp {f : X → Y} {g : Y → Z} {L M : ℝ}
    (hf : IsBiLipschitzWith f L) (hg : IsBiLipschitzWith g M) :
    IsBiLipschitzWith (g ∘ f) (L * M) := by
  refine' ⟨ _, fun x y => _ ⟩;
  · exact one_le_mul_of_one_le_of_one_le hf.1 hg.1;
  · have := hf.2 x y; have := hg.2 ( f x ) ( f y ) ; simp_all +decide [ mul_comm, mul_left_comm ];
    constructor <;> 
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: Quasi-Symmetric Gauges, the Bi-Lipschitz Monoid, and Dimension

## Synthesis of this cycle

This cycle took the two existing quasi-symmetric files in the catalog —
`Catalog/Applications/QuasiSymmetric/Maps.lean` (the `dist`-based predicates
`IsQuasisymmetric`/`IsBiLipschitzWith`, with composition and the constant-or-injective
rigidity dichotomy) and `Catalog/Geometry/QuasiSymmetricComposition.lean` (the *set-local*
`AntilipschitzOnWith`/Hölder distortion theory for `dimH`) — and tied them together with a
new file, `Catalog/Geometry/QuasiSymmetricDimension.lean`. The unifying observation is that
the *relative-distortion gauge* `η` of a quasisymmetric map behaves like an algebraic object
with its own calculus, and that the bi-Lipschitz sub-class is precisely the part of this
calculus we can already connect to Mathlib's measure-theoretic Hausdorff dimension `dimH`.

## Results summary

Five new theorems, all proved with `sorry = 0` and depending only on
`propext`/`Classical.choice`/`Quot.sound`:

1. `IsQuasisymmetric.mono_gauge` — a quasisymmetric map stays quasisymmetric under any
   pointwise larger gauge (quasisymmetry is *having some* controlling gauge).
2. `IsQuasisymmetric.eccentricity` — equidistant points cannot be spread by more than the
   single number `η 1`; the precise conformal "bounded eccentricity" statement.
3. `isQuasisymmetric_iterate` — the `n`-fold iterate of an injective `η`-quasisymmetric
   self-map is `η^[n]`-quasisymmetric: iterating the map iterates the gauge.
4. `isBiLipschitzWith_comp` + `isBiLipschitzWith_id` — bi-Lipschitz maps form a monoid with
   multiplicative constants, sitting inside the quasisymmetric maps via the linear gauge of
   `biLipschitz_isQuasisymmetric`.
5. `IsBiLipschitzWith.dimH_image_eq` — the cross-domain bridge: a bi-Lipschitz map preserves
   Hausdorff dimension on every set, the global `dist`-predicate packaging of the set-local
   `dimH_image_eq_of_lipschitzOn_antilipschitzOn`.

## Bold, falsifiable research directions

### 1. The quasisymmetric inverse gauge

Conjecture: if `f` is an `η`-quasisymmetric bijection with `η` strictly increasing and
surjective on `[0,∞)`, then `f⁻¹` is `η'`-quasisymmetric for the explicit gauge
`η'(t) = 1 / η⁻¹(1/t)`. **The key insight is** that the defining inequality
`dist(fx,fa) ≤ η(r)·dist(fx,fb)` can be *inverted* by reading it as a lower bound on the
inverse ratio, so that the inverse map's gauge is the reflection of `η` through the
involution `t ↦ 1/t`. **Why now?** We already proved `isQuasisymmetric_comp` and the
rigidity dichotomy `isQuasisymmetric_constant_or_injective`; the missing ingredient is only
the order-theoretic manipulation of a single one-variable gauge, which is well within reach
of the gauge calculus established in `QuasiSymmetricDimension.lean`.

### 2. From the iterated gauge to a contraction/expansion dichotomy

Conjecture: for an injective quasisymmetric self-map `f` whose gauge satisfies `η 1 < 1`,
the iterates `f^[
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
