
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

**Title**: *pointwise* novelty-certification framework of
**Domain**: Applications
**Mathematical framing**: # Future Directions: Certified Novelty — Regions, Filtrations, and Dual Representations

## Synthesis

This cycle extended the *pointwise* novelty-certification framework of
`Catalog/Novelty/CertifiedNovelty.lean` along three orthogonal axes, each realizing the
"duality & representation" program: replacing a hard object by an easier dual one and
transporting structure across the dictionary.

1. **Geometry of the certificate (point → region).** The continuous novelty score
   `noveltyScore S x = infDist x S` is represented by its strict super-level sets, the
   *novelty regions* `noveltyRegion S ε`. Continuity of the score becomes *openness* of
   the region (`noveltyRegion_isOpen`), and the threshold-indexed family is a decreasing
   filtration of open sets (`noveltyRegion_threshold_antitone`). The score doubles as the
   persistence **birth time**, so each point's "barcode" is the half-line
   `[0, birthTime S x)` (`mem_noveltyRegion_iff_lt_birthTime`).

2. **Robustness under approximate maps (exact → approximate).** Real embeddings only
   satisfy Lipschitz bounds up to an additive error. We introduced
   `ApproxLipschitzWith K c` / `ApproxAntilipschitzWith K c`, showed the exact theory is
   the `c = 0` fragment, and proved the compositional error law
   `(K₂, c₂) ∘ (K₁, c₁) = (K₂·K₁, K₂·c₁ + c₂)` (`ApproxLipschitzWith.comp`) and the
   error-aware certificate transfer `approx_novel_transfer`.

3. **Set-level novelty (point → set, via Hausdorff duality).** Viewing each set as a
   *point* of the Hausdorff metric space, every pointwise theorem casts a set-level
   shadow. We defined `IsNovelSet` and transported the triangle-robustness theorem to
   `novelSet_triangle_transfer`, with family antitonicity in `isNovelSet_antitone_family`.

## Results Summary

| Theorem | File | Content |
|---|---|---|
| `noveltyRegion_isOpen` | `NoveltyRegions.lean` | Stability: certified-novel region is open |
| `noveltyRegion_threshold_antitone` | `NoveltyRegions.lean` | Decreasing filtration in the threshold |
| `noveltyRegion_antitone_set` | `NoveltyRegions.lean` | More knowledge ⇒ smaller region |
| `mem_noveltyRegion_iff_lt_birthTime` | `NoveltyRegions.lean` | Persistent-novelty barcode |
| `noveltyRegion_subset_isNovel` | `NoveltyRegions.lean` | Bridge to the predicate framework |
| `ApproxLipschitzWith.comp` | `ApproxLipschitz.lean` | Affine error accumulation under composition |
| `approx_novel_transfer` | `ApproxLipschitz.lean` | Certificate transfer with multiplicative + additive deflation |
| `LipschitzWith.approxLipschitzWith` | `ApproxLipschitz.lean` | Exact theory ⊆ approximate theory |
| `novelSet_triangle_transfer` | `HausdorffNovelty.lean` | Set-level robustness via Hausdorff triangle |
| `isNovelSet_antitone_family` | `HausdorffNovelty.lean` | Family antitonicity of set-level novelty |

All main results compile with zero `sorry` and depend only on
`propext`, `Classical.choice`, `Quot.sound`.

## Bold, Falsifiable Research Directions

### 1. The novelty region is exactly the complement of an open thickening
Conjecture: `noveltyRegion S ε = (Metric.cthickening ε S)ᶜ` is **false** in general but the
non-strict variant `{x | ε < infDist x S} = (Metric.thickening ε S)ᶜ` holds, identifying
the novelty filtration with the *complement of the offset filtration* used in persistent
homology (the union-of-balls / Čech picture).
**The key insight is** that `infDist x S > ε` is precisely the statement that `x` escapes
every closed `ε`-ball around `S`, so the novelty barcode of a point is dual (order-reversed)
to the death time of the corresponding component in the Čech filtration.
**Why now?** Mathlib already has `Metric.thickening`, `Metric.cthickening`, and
`Metric.infDist_lt_iff`; the proof is a super-level-set computation that directly composes
with `noveltyRegion_isOpen` and `noveltyRegion_threshold_antitone` proven this cycle.

### 2. Layer-budget theorem for approximate embeddings
Conjecture: for an `n`-fold composition of `(K, c)`-approximately-Lipschitz layers, the
accumulated additive error is exactly `c · (K^{n} − 1)/(K − 1)` (for `K ≠ 1`), and the
transferred certificate becomes vacuous (threshold `≤ 0`) once
`n > log_K(1 + ε(K−1)/c)`.
**The key insight is** that `ApproxLipschitzWith.comp` iterates to a geometric series in the
error coordinate, so the certificate's survival is governed by a single closed-form
inequality — a concrete "depth budget" for certified embeddings.
**Why now?** The single-step composition law is already formalized; the iterate is a clean
induction over `Nat`, and `Finset.geom_sum_eq` supplies the closed form.

### 3. Hausdorff novelty regions are open in the space of compact sets
Conjecture: on the metric space of nonempty compact subsets of a proper space (with
`Metric.hausdorffDist`), the set-level novelty region
`{A | ε < infDist A Fam}` is open, and Blaschke selection makes this space proper, so the
filtration/birth-time theory of Direction 1 lifts verbatim to *convex bodies*.
**The key insight is** that `IsNovelSet` is literally the pointwise `IsNovel` predicate in
the Hausdorff metric space, so `noveltyRegion_isOpen` should apply once the compact-sets
metric instance is in scope — no new analysis, only a change of base space.
**Why now?** `novelSet_triangle_transfer` already exhibits sets behaving as metric points;
Mathlib's `EMetric`/`Metric` Hausdorff API plus `TopologicalSpace.NonemptyCompacts` give the
carrier, making the instance plumbing the only gap.

### 4. Quantitative packing/capacity bound from the filtration
Conjecture: in a space with finite `ε`-covering number `N(ε)`, any mutually `ε`-separated
reference set `S` satisfies `|S| ≤ N(ε/2)`, and the novelty region at threshold `ε` is
nonempty iff the `ε`-packing is not maximal.
**The key insight is** that `separated_balls_pairwiseDisjoint` (catalog) plus the filtration
structure proven here means "room for a new novel point" is equivalent to "the packing can
grow", turning capacity into a statement about emptiness of `noveltyRegion`.
**Why now?** The disjoint-balls lemma already exists in the catalog; combining it with
Mathlib's `Metric.exists_finset_cover`/totally-bounded API yields the counting bound
directly.

### 5. Lipschitz dependence of the birth time on the reference set
Conjecture: the map `S ↦ birthTime S x` is `1`-Lipschitz with respect to the Hausdorff
distance on reference sets: `|birthTime S x − birthTime T x| ≤ hausdorffDist S T`. Hence
small Hausdorff perturbations of the *knowledge base* move every barcode endpoint by at
most the perturbation — stability of the entire persistence diagram.
**The key insight is** that `birthTime = infDist x ·` and `infDist` is itself `1`-Lipschitz
in the set argument under Hausdorff distance, so this is the *second-variable* dual of the
already-proven `noveltyScore_lipschitz` (which is Lipschitz in the point).
**Why now?** This unifies the point-variable regularity (this cycle) with set-variable
regularity, and Mathlib's `Metric.infDist_le_infDist_add_hausdorffDist`-style lemmas make
it a short transport argument that immediately stabilizes Directions 1 and 3.

Research domain: Applications
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Algebra/MarkovBases/Geodesic.lean
import Mathlib
import Algebra.MarkovBases.NoThreeWay

/-!
# Algebraic Statistics: Geodesics in the Markov Graph of the No-Three-Way Model

Building directly on `Algebra.MarkovBases.NoThreeWay`, this file upgrades the *qualitative*
Fundamental Theorem of Markov Bases (`noThreeWay_fiber_connected` — "the single move `M3`
connects every fiber") to a *quantitative* one: it computes the **exact graph distance**
between two tables in the Markov graph of the `2 × 2 × 2` no-three-way interaction model.

The Markov graph of a fiber has the non-negative tables as vertices and a `± M3` move as an
edge.  We define a length-counted walk `Walk u v n` (a path of `n` legal `± M3` steps) and
prove:

* every `± M3` step changes the corner cell `u 0 0 0` by exactly one
  (`step_corner_natAbs_le`);
* hence any walk of length `n` satisfies `|v₀₀₀ − u₀₀₀| ≤ n` — a **geodesic lower bound**
  (`walk_corner_bound`);
* conversely there is a walk of length exactly `|t|` realising `u ⇝ u + t • M3`
  (`walk_add_smul`), staying non-negative throughout (discrete convexity);
* therefore the graph distance between any two equal-margin non-negative tables is **exactly**
  `|v₀₀₀ − u₀₀₀|` (`noThreeWay_geodesic`): the natural corner coordinate is an isometry from
  the fiber onto an integer interval.

## Catalog synthesis

This extends `Algebra.MarkovBases.NoThreeWay` (rank-one move lattice + connectivity) and is
the `2×2×2` analogue of the interval picture in `Algebra.MarkovBases.TwoWay`
(`twoWay_fiber_card_interval`).  Where those files show *that* one move suffices, this file
quantifies the *cost*: the Markov graph of every fiber is a path graph, and the corner cell
is a graph isometry onto `ℤ`.  The lower bound is a potential-function argument (a discrete
1-Lipschitz invariant), a reusable bridge between lattice walks (catalog: combinatorial step
relations) and metric geometry on graphs.
-/

namespace MarkovBases.NoThreeWay

/-- A length-counted walk in the Markov graph: a path of `n` legal `± M3` steps from `u`
to `v`, every intermediate table non-negative (the `Step` relation enforces this). -/
inductive Walk : Table3 → Table3 → ℕ → Prop
  | refl (u : Table3) : Walk u u 0
  | cons {u v w : Table3} {n : ℕ} : Step u v → Walk v w n → Walk u w (n + 1)

-- !-- step_corner_natAbs_le: a ±M3 move changes the corner cell by exactly M3 0 0 0 = ±1,
-- so a single Markov step moves the corner coordinate by one. -- !--
/-- A single legal `± M3` step changes the corner cell `u 0 0 0` by exactly one:
`M3 0 0 0 = 1`, so `v 0 0 0 - u 0 0 0 = ±1`. -/
theorem step_corner_natAbs_le {u v : Table3} (h : Step u v) :
    (v 0 0 0 - u 0 0 0).natAbs ≤ 1 := by
  rcases h with ⟨hu, hv, huv⟩
  rcases huv with (rfl | rfl) <;> norm_num [M3]

-- !-- walk_corner_bound: induct on the walk; the corner coordinate is 1-Lipschitz along edges,
-- so its total change is at most the number of steps — the geodesic lower bound. -- !--
/-- **Geodesic lower bound.** Any walk of `n` legal `± M3` steps from `u` to `v` satisfies
`|v 0 0 0 - u 0 0 0| ≤ n`: the corner cell is a `1`-Lipschitz potential, so no path can be
shorter than the corner displacement. -/
theorem walk_corner_bound {u v : Table3} {n : ℕ} (h : Walk u v n) :
    (v 0 0 0 - u 0 0 0).natAbs ≤ n := by
  induction h with
  | refl u => norm_num
  | cons s _ ih =>
      have := step_corner_natAbs_le s
      omega

-- !-- walk_add_smul: induct on |t|; one unit step (±M3) toward the target stays non-negative
-- by discrete convexity, giving a walk of length exactly |t|. -- !--
/-- **Existence of a length-`|t|` geodesic.** If both `u` and `u + t • M3` are non-negative
then there is a walk of length exactly `t.natAbs` between them, staying non-negative at every
step.  (Refines `connected_add_smul`, which forgets the length.) -/
theorem walk_add_smul (t : ℤ) (u : Table3)
    (hu : Nonneg u) (hv : Nonneg (u + t • M3)) :
    Walk u (u + t • M3) t.natAbs := by
  induction' n : t.natAbs with n ih generalizing u t
  · rw [Int.natAbs_eq_zero.mp n]; simp +decide [Walk.refl]
  · rcases Int.natAbs_eq_iff.mp n with (rfl | rfl)
    · -- positive case: first add M3, then recurse with exponent n
      have h_ind : Walk (u + M3) (u + (↑(Nat.succ ‹_›) : ℤ) • M3) ‹_› := by
        convert ih (↑‹ℕ› : ℤ) (u + M3) _ _ _ using 1 <;> norm_num [add_smul_M3_apply]
        · ext i j k; simp; ring
        · intro i j k; specialize hv i j k; specialize hu i j k
          simp_all +decide
          cases M3_apply_eq i j k <;> nlinarith
        · convert hv using 1; ext i j k; simp +decide; ring
      refine Walk.cons ?_ h_ind
      constructor <;> norm_num [hu, hv]
      intro i j k; specialize hv i j k; simp_all +decide [M3]
      split_ifs at * <;> linarith [hu i j k]
    · -- negative case: first subtract M3, then recurse with exponent n
      refine Walk.cons (v := u - M3) ?_ ?_
      · constructor <;> norm_num [Step]
        · assumption
        · intro i j k; have := hu i j k; have := hv i j k
          simp_all +decide [M3]
          split_ifs at * <;> linarith
      · convert ih (-↑‹ℕ›) (u - M3) _ _ _ using 1 <;> norm_num [sub_eq_add_neg]
        · ext i j k; norm_num; ring
        · intro i j k; have := hu i j k; have := hv i j k
          simp_all +decide [M3]
          split_ifs at * <;> linarith
        · convert hv using 1; ext i j k; norm_num; ring

-- !-- noThreeWay_geodesic: the kernel theorem writes v = u + (v000-u000)•M3; walk_add_smul gives
-- a walk of that length and walk_corner_bound shows none is shorter — distance = |v000-u000|. -- !--
/-- **Markov-graph geodesic distance.** For any two non-negative tables `u`, `v` with the same
two-way margins, the corner displacement `|v 0 0 0 - u 0 0 0|` is realised by some walk and is
a lower bound for every walk.  Hence it is *exactly* the graph distance between `u` and `v` in
the Markov graph of the fiber: the corner cell is an isometry onto an integer interval. -/
theorem noThreeWay_geodesic (u v : Table3)
    (hu : Nonneg u) (hv : Nonneg v) (h : SameMargins u v) :
    Walk u v (v 0 0 0 - u 0 0 0).natAbs ∧
      ∀ n, Walk u v n → (v 0 0 0 - u 0 0 0).natAbs ≤ n := by
  refine ⟨?_, fun n hn => walk_corner_bound hn⟩
  have hk := noThreeWay_kernel u v h
  convert walk_add_smul (v 0 0 0 - u 0 0 0) u hu _
  exact hk ▸ hv

end MarkovBases.NoThreeWay


-- NEW_FILE: Catalog/Bridges/HodgeEPolynomial.lean
/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# The Hodge–Deligne E-polynomial as a Bridge to Arithmetic

This file introduces the two-variable **Hodge–Deligne E-polynomial**
`E(X; u, v) = Σ_{p,q} (-1)^{p+q} h^{p,q} uᵖ vᵍ`
on an abstract `HodgeDiamond` structure and proves two genuine *functional equations*:

* `epoly_serre_functional_equation` — the Serre/Poincaré duality equation
  `E(X; u, v) = (uv)ⁿ E(X; 1/u, 1/v)` (under Serre duality of `X`);
* `epoly_mirror_functional_equation` — the mirror equation
  `E(mirror X; u, v) = (-1)ⁿ uⁿ E(X; 1/u, v)` (unconditionally).

Specialising at `u = v = 1` recovers `eulerChar_mirror_sign`, the statement that the
topological Euler characteristic of the mirror diamond is `(-1)ⁿ` times the original.
We also record `totalDim_mirror` (the total Hodge dimension is mirror-invariant) and
upgrade the mirror involution to Calabi–Yau data (`CalabiYauData.mirror`).

This is a *duality / representation* bridge: it translates the geometric mirror
involution `(p,q) ↦ (n-p, q)` and Serre duality `(p,q) ↦ (n-p, n-q)` into algebraic
symmetries (functional equations) of a single polynomial invariant.

-- !-- Lab Notebook -- !--
Hypothesis: The numerical mirror sign `χ(mirror X) = (-1)ⁿ χ(X)` is the `u=v=1`
  shadow of a polynomial-level functional equation in the Hodge–Deligne E-polynomial.
Result: Both the Serre/Poincaré and mirror functional equations are formalised over an
  arbitrary field `K`, and the numerical Euler-characteristic sign and total-dimension
  invariance ar
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: Certified Novelty — Filtrations, Depth Budgets, and Hausdorff Stability

## Synthesis

This cycle extended the *pointwise* novelty-certification framework of
`Catalog/Novelty/CertifiedNovelty.lean` along three orthogonal axes, each an instance
of the "duality & representation" program: replace a hard object by an easier dual one
and transport structure across the dictionary.

1. **Geometry of the certificate (point → region).** In `NoveltyRegions.lean` the
   continuous novelty score `noveltyScore S x = infDist x S` is represented by its
   strict super-level sets, the *novelty regions* `noveltyRegion S ε`. Continuity of
   the score becomes *openness* of the region (`noveltyRegion_isOpen`), and the
   threshold-indexed family is a decreasing filtration of open sets
   (`noveltyRegion_threshold_antitone`, `noveltyRegion_antitone_set`). The score
   doubles as the persistence **birth time**, so each point's barcode is the half-line
   `[0, birthTime S x)` (`mem_noveltyRegion_iff_lt_birthTime`). The new identity
   `noveltyRegion_eq_compl_cthickening` proves the region is *exactly* the complement of
   the closed Čech/offset thickening — tying novelty to persistent homology.

2. **Robustness under approximate maps (exact → approximate).** In
   `ApproxLipschitz.lean` we model real embeddings that satisfy Lipschitz/antilipschitz
   bounds only up to an additive error. We introduced `ApproxLipschitzWith K c` and
   `ApproxAntilipschitzWith K c`, showed the exact catalog theory is the `c = 0`
   fragment (`LipschitzWith.approxLipschitzWith`), and proved the compositional error
   law `(K₂,c₂) ∘ (K₁,c₁) = (K₂·K₁, K₂·c₁+c₂)` (`ApproxLipschitzWith.comp`). Iterating
   gives the **layer-budget theorem**: the depth-`n` iterate is
   `(Kⁿ, c·∑_{i<n}Kⁱ)`-approximately Lipschitz (`ApproxLipschitzWith.iterate`), with
   closed form `c·(Kⁿ−1)/(K−1)` (`ApproxLipschitzWith.iterate_error_closed`). The
   error-aware certificate transfer `approx_novel_transfer` deflates the threshold both
   multiplicatively (`/K`) and additively (`−c`).

3. **Set-level novelty (point → set via Hausdorff duality).** In `HausdorffNovelty.lean`
   each set becomes a *point* of the Hausdorff metric space `NonemptyCompacts β`, so
   every pointwise theorem casts a set-level shadow (`IsNovelSet`,
   `novelSet_triangle_transfer`, `isNovelSet_antitone_family`). We also proved the
   second-variable regularity `birthTime_lipschitz_reference`: the birth time is
   `1`-Lipschitz in the *reference set* under Hausdorff distance, the dual of the
   catalog's point-variable `noveltyScore_lipschitz`.

## Results Summary

| Theorem | File | Content |
|---|---|---|
| `noveltyRegion_isOpen` | `NoveltyRegions.lean` | Stability: certified-novel region is open |
| `noveltyRegion_threshold_antitone` | `NoveltyRegions.lean` | Decreasing filtration in the threshold |
| `noveltyRegion_antitone_set` | `NoveltyRegions.lean` | More knowledge ⇒ smaller region |
| `mem_noveltyRegion_iff_lt_
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
