
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

**Title**: The file `TropicalValuationLimitBridge.lean` formalizes the *easy half* of the F
**Domain**: Novelty
**Mathematical framing**: # Future Directions: The Valuation–Tropicalization Bridge

The file `TropicalValuationLimitBridge.lean` formalizes the *easy half* of the Fundamental
Theorem of Tropical Geometry: tropicalizing a point of a classical hypersurface always lands on
the corner locus (`kapranov_easy_direction`), powered by the ultrametric winner-takes-all lemma
(`addValuation_sum_eq_of_unique_min`), and it isolates the min-plus multiplicativity
(`TropPoly.eval_mul`) that makes tropical degrees add. Below are the next conjectures this work
opens up. Each is stated so that it can be falsified by a single counterexample or settled by a
single Lean proof.

## Direction 1 — Kapranov's hard direction (surjectivity onto the corner locus)

Conjecture: if `K` is algebraically closed with a non-trivial valuation `v` whose value group is
divisible (so `v` is surjective onto `Γ`), then for every weight vector `w` lying on the corner
locus of a tropical polynomial `trop(f)` there exists a point `p` with `f(p) = 0` and
`v(p) = w`. This is the converse of `kapranov_easy_direction`, currently recorded as the open
target `kapranov_hard_direction_sketch`.

The key insight is that the easy direction is *purely a consequence of the ultrametric
inequality being an equality away from ties*, whereas the hard direction needs a genuine
*lifting* step: a Newton-polygon / Hensel argument that promotes a "leading-term cancellation"
(two monomials tied for the minimum) into an actual root. Formalizing the univariate case first
(`Fin 1` many variables, where the Newton polygon is literally the lower convex hull of
`{(i, v(cᵢ))}`) reduces the whole theorem to Hensel's lemma plus convexity.

Why now? Mathlib already has `Polynomial.Monic`, Hensel's lemma for complete local rings, and
the `AddValuation` API used here; the missing glue is a Newton-polygon predicate, which is a
finite-combinatorial object identical in spirit to the `inf'_product_add` lemma already proven.

## Direction 2 — The valuation-going-to-infinity limit is genuinely a limit

Conjecture: for the rescaled family `v_t := t • v` (`t : ℝ≥0`, `t → ∞`), the corner locus of
`trop_{v_t}(f)` converges, in the Hausdorff metric on compact windows, to the corner locus of
`trop_v(f)` *scaled by t*; equivalently the normalized amoeba `(1/t)·Log_t(V(f))` converges to
the tropical variety. This makes precise the slogan "tropicalization is the `t → ∞` limit".

The key insight is that `t • v` is *again* an `AddValuation` (scaling preserves the two
valuation axioms), so the entire corner-locus characterization is invariant under `t`-rescaling
up to a homothety — meaning the "limit" is not an analytic limit of moving sets but the fixed
shape that all members of the family already share after normalization.

Why now? The corner-locus predicate `AttainedAtLeastTwice` is scale-equivariant on the nose
(`AttainedAtLeastTwice (t • w) ↔ AttainedAtLeastTwice w` for `t > 0`), a one-line lemma to add,
turning a hard analytic statement into an algebraic invariance that Lean can check directly.

## Direction 3 — Stable intersection and tropical Bézout from `eval_mul`

Conjecture: define the tropical hypersurface `V(P) := {x | AttainedAtLeastTwice (P.termVal x)}`.
Then `V(P.mul Q) = V(P) ∪ V(Q)` exactly, and for plane curves (`n = 2`) the number of stable
intersection points of `V(P)` and `V(Q)`, counted with lattice multiplicity, equals
`deg P · deg Q`.

The key insight is that `TropPoly.eval_mul` already proves `eval (P ⊙ Q) = eval P + eval Q`
*as functions*; a corner of a sum of two convex-piecewise-linear functions occurs exactly where
at least one summand has a corner, so the union law for hypersurfaces is the pointwise shadow of
the additivity of evaluations — no new geometry is needed, only a corner-of-a-sum lemma.

Why now? The catalog already contains `Tropical/Bezout.lean` proving `mixedLatticeIndex` of two
degree simplices equals `d₁·d₂`; combining that lattice count with the union law here would give
the *first end-to-end* tropical Bézout theorem in the catalog that connects the analytic
(min-plus evaluation) and combinatorial (Newton polytope) descriptions.

## Direction 4 — Balancing condition as a conservation law

Conjecture: at every corner point `x` of `V(P)`, the primitive edge directions of the tropical
curve, weighted by lattice length, sum to zero (the *balancing condition*). Moreover this is
equivalent to `∑ᵢ Tᵢ = 0` lifting consistently, i.e. balancing is the tropical shadow of
"a regular function has no poles".

The key insight is that balancing is exactly the statement that the set of monomials achieving
the minimum at `x` (the "tie set" produced by `kapranov_easy_direction`) forms the vertex set of
a polytope whose outward normal fan is complete — so the same tie set that proves membership in
the corner locus *also* carries the balancing data, for free.

Why now? `kapranov_easy_direction` already extracts the tie set (two indices realizing the min);
generalizing its conclusion from "≥ 2 minimizers" to "the minimizer set spans a balanced fan"
is the natural strengthening, and Mathlib's `Finset` convex-geometry API is now rich enough to
state primitive lattice vectors.

## Direction 5 — Tropical semiring morphism packaging of the valuation

Conjecture: the map `x ↦ v x` is a semiring homomorphism `K → Tropical (WithTop Γ)ᵒᵈ` *up to the
single defect on addition*, and the defect locus (where `v(x+y) ≠ min(v x, v y)`) is precisely
the diagonal-tie set `{v x = v y}`. Packaging this as a bundled `TropicalHom` would let every
classical algebraic identity be transported to a tropical inequality automatically.

The key insight is that the only obstruction to `v` being an honest tropical-semiring morphism is
the failure of additivity *exactly when two valuations coincide* — which is the same tie
phenomenon driving the corner locus. So "morphism defect = corner locus" unifies the additive
and multiplicative stories into one statement.

Why now? Mathlib's `Tropical R` type and `Semiring (Tropical R)` instance (from
`Mathlib.Algebra.Tropical.Basic`) are already imported transitively here; the bundling is a
definitional wrapper, after which `AddValuation.map_add` becomes a tropical-additivity inequality
and `map_mul` becomes tropical-multiplicativity on the nose.

Research domain: Novelty
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Bridges/AlgebraTropicalGeometry/TropicalValuationMorphismDefect.lean
/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Bridge: the non-Archimedean valuation as a tropical semiring morphism, up to its defect

This file *extends* `Bridges.AlgebraTropicalGeometry.TropicalValuationLimitBridge` (the easy
direction of Kapranov's theorem and min-plus multiplicativity) and its companion
`Bridges.AlgebraTropicalGeometry.TropicalBezoutFactorization` (the union law for tropical
hypersurfaces).  Both of those files study the *corner locus*; here we settle **Direction 5** of
their shared `FUTURE_DIRECTIONS`:

> The tropicalization map `x ↦ v x` is a semiring morphism into the tropical semiring *up to a
> single defect on addition*, and the defect locus — where additivity fails — is *exactly* the
> diagonal tie set `{v x = v y}` that drives the corner locus.

Concretely, packaging the additive valuation `v : AddValuation K Γ` through `Tropical.trop`
gives a map `tropVal v : K → Tropical Γ` which is:

* **multiplicative on the nose** (`tropVal_mul`, bundled as `tropValMonoidHom : K →* Tropical Γ`),
  because `v (x*y) = v x + v y` and tropical multiplication is ordinary addition; and
* **sub-additive** (`tropVal_add_le`): `tropVal x + tropVal y ≤ tropVal (x+y)`, the tropical
  shadow of the ultrametric inequality `min (v x) (v y) ≤ v (x+y)`.

The single defect on addition is controlled exactly:

* `addValuation_add_eq_min_of_ne` — additivity holds with *equality* whenever `v x ≠ v y`;
* `addValuation_defect_imp_tie` — conversely, every failure of additivity forces `v x = v y`,
  i.e. the **defect locus is contained in the tie set**.

Finally we connect the defect back to the corner-locus vocabulary of the bridge files:

* `attainedTwice_fin2_iff` — for a two-monomial family the corner locus is *exactly* the tie set
  `{a = b}`; and
* `addValuation_defect_imp_corner` — every additive defect of `v` lands on the binary corner
  locus, unifying the additive (defect) and combinatorial (corner) stories.

-- !-- Lab Notebook -- !--
* Hypothesis: the only obstruction to `x ↦ v x` being an honest tropical-semiring morphism is the
  failure of additivity, and that failure happens *exactly* on the tie set `{v x = v y}` — the
  same phenomenon producing corners in `kapranov_easy_direction`.
* Result: confirmed.  Multiplicativity is exact (`tropValMonoidHom`); additivity is an inequality
  (`tropVal_add_le`) that becomes an equality off the tie set (`addValuation_add_eq_min_of_ne`),
  and every defect is on the tie set (`addValuation_defect_imp_tie`), which for two monomials is
  literally the corner locus (`attainedTwice_fin2_iff`, `addValuation_defect_imp_corner`).
* Insight: "morphism defect = corner locus" is a one-line consequence of
  `AddValuation.map_add_eq_of_lt_left`: away from ties one valuation strictly wins, pinning the
  sum's valuation to the minimum.  Tropicalizing through `Tropical.trop` turns Mathlib's additive
  valuation API verbatim into tropical-semiring (in)equalities.
* Failure analysis: a naive attempt to make `tropVal` a *ring* hom fails — it is provably *not*
  an `AddHom` (the defect is real, e.g. `x + (-x) = 0` gives `v 0 = ⊤ ≠ v x`).  The correct
  packaging is therefore a `MonoidHom` plus a sub-additivity inequality, not a `RingHom`.
-/

open Finset
open Tropical

namespace TropicalValuationMorphism

/-! ## §0. Corner-locus vocabulary (re-stated for self-containment) -/

/-- A weight function `w : ι → α` **attains its minimum at least twice**: the corner-locus /
tropical-hypersurface predicate.  Mirrors `TropicalValuationBridge.AttainedAtLeastTwice`. -/
def AttainedAtLeastTwice {ι α : Type*} [LinearOrder α] (w : ι → α) : Prop :=
  ∃ i j, i ≠ j ∧ (∀ k, w i ≤ w k) ∧ (∀ k, w j ≤ w k)

/-! ## §1. The single additive defect is controlled by the tie set -/

/-
!-- By trichotomy on `v x` vs `v y`: if one strictly wins, `AddValuation.map_add_eq_of_lt_left`
pins `v (x+y)` to it, which is the min; the third (equal) case is excluded by `hne`. -- !--

**Additivity off the tie set.**  When the two valuations differ, the ultrametric inequality is an
*equality*: `v (x + y) = min (v x) (v y)`.  This is the precise statement that the tropicalization
is additive away from `{v x = v y}`.
-/
theorem addValuation_add_eq_min_of_ne
    {K Γ : Type*} [Field K] [LinearOrderedAddCommMonoidWithTop Γ]
    (v : AddValuation K Γ) {x y : K} (hne : v x ≠ v y) :
    v (x + y) = min (v x) (v y) := by
  grind +suggestions

/-
!-- Contrapositive of `addValuation_add_eq_min_of_ne`: if the valuations differed, additivity
would hold, contradicting the assumed defect. -- !--

**Defect locus ⊆ tie set.**  Every failure of additivity forces the two valuations to coincide:
the defect of the tropicalization morphism lives exactly on the diagonal tie set `{v x = v y}`.
-/
theorem addValuation_defect_imp_tie
    {K Γ : Type*} [Field K] [LinearOrderedAddCommMonoidWithTop Γ]
    (v : AddValuation K Γ) {x y : K} (hdef : v (x + y) ≠ min (v x) (v y)) :
    v x = v y := by
  grind +suggestions

/-! ## §2. Tropicalization through `Tropical.trop`: a monoid morphism plus a defect -/

/-- The **tropicalization map** of an additive valuation: send `x` to `trop (v x)` in the
tropical semiring `Tropical Γ`, where multiplication is `+` and addition is `min`. -/
def tropVal {K Γ : Type*} [Field K] [LinearOrderedAddCommMonoidWithTop Γ]
    (v : AddValuation K Γ) (x : K) : Tropical Γ :=
  trop (v x)

/-
!-- `v 1 = 0` by `AddValuation.map_one`, and the tropical unit is `trop 0`. -- !--

**Multiplicative unit.**  Tropicalization sends `1` to the tropical multiplicative identity.
-/
theorem tropVal_one {K Γ : Type*} [Field K] [LinearOrderedAddCommMonoidWithTop Γ]
    (v : AddValuation K Γ) : tropVal v 1 = 1 := by
  exact v.map_one.symm ▸ rfl

/-
!-- `v (x*y) = v x + v y` (`AddValuation.map_mul`) and `trop` turns `+` into tropical `*`
(`Tropical.trop_add`). -- !--

**Exact multiplicativity.**  Tropicalization is a homomorphism for the multiplicative structure:
classical multiplication becomes tropical multiplication (ordinary addition of valuations) with no
defect.
-/
theorem tropVal_mul {K Γ : Type*} [Field K] [LinearOrderedAddCommMonoidWithTop Γ]
    (v : AddValuation K Γ) (x y : K) : tropVal v (x * y) = tropVal v x * tropVal v y := by
  -- By definition of tropVal, we have tropVal v (x * y) = trop (v (x * y)).
  simp [tropVal]

/-- **Bundled multiplicative morphism.**  The tropicalization `x ↦ trop (v x)` is a genuine
`MonoidHom K (Tropical Γ)`; this is the "honest half" of Direction 5. -/
def tropValMonoidHom {K Γ : Type*} [Field K] [LinearOrderedAddCommMonoidWithTop Γ]
    (v : AddValuation K Γ) : K →* Tropical Γ where
  toFun := tropVal v
  map_one' := tropVal_one v
  map_mul' := tropVal_mul v

/-
!-- Tropical addition is `min` (`Tropical.add_def`), and `min (v x) (v y) ≤ v (x+y)` is the
ultrametric inequality `AddValuation.map_add`; `trop` is monotone (`untrop_le_iff`). -- !--

**Sub-additivity (the tropical-additivity inequality).**  Tropicalization is sub-additive:
`tropVal x + tropVal y ≤ tropVal (x + y)`.  This is the tropical-semiring shadow of the
ultrametric inequality and is the precise sense in which `v` is "almost" additive.
-/
theorem tropVal_add_le {K Γ : Type*} [Field K] [LinearOrderedAddCommMonoidWithTop Γ]
    (v : AddValuation K Γ) (x y : K) :
    tropVal v x + tropVal v y ≤ tropVal v (x + y) := by
  by_contra! h_contra;
  exact h_contra.not_ge ( v.map_add _ _ )

/-
!-- Off the tie set `addValuation_add_eq_min_of_ne` upgrades the `≤` to `=`; tropical addition is
`min`, so the inequality `tropVal_add_le` becomes an equality. -- !--

**Additivity off the tie set, tropical form.**  Away from the diagonal `{v x = v y}` the
sub-additivity inequality `tropVal_add_le` is an *equality*: there `tropVal` is an honest additive
morphism as well.
-/
theorem tropVal_add_eq_of_ne {K Γ : Ty
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: The Valuation–Tropicalization Bridge (cycle 2)

## Synthesis

This package now formalizes three coherent slabs of the bridge between a non-Archimedean valued
field `(K, v)` and tropical geometry, each building on the previous one:

1. **`TropicalValuationLimitBridge.lean`** — the *easy half* of the Fundamental Theorem of
   Tropical Geometry: `kapranov_easy_direction` (tropicalization of a hypersurface point lands on
   the corner locus), the ultrametric winner-takes-all lemma
   `addValuation_sum_eq_of_unique_min`, the strengthening `corner_of_leading_cancellation`, and
   min-plus multiplicativity `TropPoly.eval_mul`.

2. **`TropicalBezoutFactorization.lean`** — the *combinatorial half*: scale invariance of the
   corner locus (`attainedTwice_smul`, the "valuation → ∞" limit), the union law
   `tropRoot_mul_iff` / `tropRootSet_mul` (`V(P ⊙ Q) = V(P) ∪ V(Q)`), and Newton-polytope
   additivity `range_exp_mul` (Minkowski sum). This settled **Directions 2 and 3** of the
   original future-directions note.

3. **`TropicalValuationMorphismDefect.lean`** (this cycle) — the *algebraic half*, settling
   **Direction 5**: the tropicalization map `tropVal v : K → Tropical Γ`, `x ↦ trop (v x)`, is an
   honest multiplicative morphism (`tropValMonoidHom : K →* Tropical Γ`) and is sub-additive
   (`tropVal_add_le`); its *only* defect on addition is pinned to the diagonal tie set
   (`addValuation_add_eq_min_of_ne`, `addValuation_defect_imp_tie`), which for two monomials is
   *literally* the corner locus (`attainedTwice_fin2_iff`, `addValuation_defect_imp_corner`).
   This unifies the additive (defect) and combinatorial (corner) stories: "morphism defect =
   corner locus".

## Results summary

New, fully proved (sorry-free, only `propext`/`Classical.choice`/`Quot.sound`):

* `addValuation_add_eq_min_of_ne` — `v x ≠ v y → v (x+y) = min (v x) (v y)` (additivity off ties).
* `addValuation_defect_imp_tie` — `v(x+y) ≠ min(v x, v y) → v x = v y` (defect locus ⊆ tie set).
* `tropVal`, `tropValMonoidHom : K →* Tropical Γ` — bundled multiplicative morphism.
* `tropVal_one`, `tropVal_mul` — exact multiplicativity / unit.
* `tropVal_add_le`, `tropVal_add_eq_of_ne` — tropical sub-additivity and its equality off ties.
* `attainedTwice_fin2_iff` — two-monomial corner locus `= {a = b}`.
* `addValuation_defect_imp_corner` — every additive defect of `v` lands on the binary corner locus.

The remaining open targets are **Directions 1 (Kapranov's hard direction)** and
**Direction 4 (balancing)**, refined below alongside three new conjectures the morphism picture
opens up.

## Direction A — Kapranov's hard direction, univariate seed

Conjecture: if `K` is algebraically closed with a non-trivial *divisible*-value-group valuation
`v`, then for every `w` on the corner locus of `trop(f)` there is `p` with `f(p) = 0` and
`v(p) = w`. Start with `Fin 1` variables, where the Newton polygon is the lower convex hull of
`{(i, v(cᵢ))}`.

The key insight is that the e
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
