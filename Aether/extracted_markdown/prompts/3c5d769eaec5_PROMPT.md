
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
    {
      "name": "descriptive_name",
      "description": "Detailed in-depth explanation of the algorithm, its mathematical foundation, computational complexity, and role in the pipeline.",
      "pseudocode": "Formal, structured step-by-step pseudocode detailing the logic.",
      "code": "# full Python source with type hints..."
    }
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

**Title**: The file `TropicalValuationLimitBridge.lean` formalizes the *easy half* of the F
**Domain**: Bridges
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

Research domain: Bridges
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Bridges/AlgebraTropicalGeometry/TropicalCornerLocusFunctorial.lean
/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Bridges.AlgebraTropicalGeometry.TropicalValuationLimitBridge

/-!
# Functoriality of the tropical corner locus: scale-invariance and the union law

This file extends `TropicalValuationLimitBridge.lean` by establishing two structural
properties of the corner-locus predicate `AttainedAtLeastTwice` and of tropical
hypersurfaces.  These were recorded as **Direction 2** (scale invariance / the
"valuation -> infinity limit") and **Direction 3** (stable intersection / tropical Bezout via
the union law) in that file's future directions.

## Main results

* `attainedTwice_smul_iff` — **scale equivariance (Direction 2).**  Rescaling all weights by a
  positive constant does not move the corner locus: `AttainedAtLeastTwice (t * w) ↔
  AttainedAtLeastTwice w`.  This makes precise that the family `v_t = t·v` shares one fixed
  tropical shape, so "tropicalization is the t -> infinity limit" is an algebraic invariance
  rather than an analytic limit of moving sets.

* `attainedTwice_product_add_iff` — **corner of a separated sum.**  The minimum of
  `(i,k) ↦ f i + g k` is attained at least twice **iff** the minimum of `f` is, or the minimum
  of `g` is.  This is the combinatorial shadow of `TropPoly.eval_mul`: the minimizer set of a
  sum is the product of the minimizer sets.

* `TropPoly.tropHypersurface_mul` — **the union law (tropical Bezout engine).**  The tropical
  hypersurface of a product is the union of the hypersurfaces: `V(P ⊙ Q) = V(P) ∪ V(Q)`.  This
  is the analytic half of tropical Bezout, complementing the combinatorial lattice count.

See `FUTURE_DIRECTIONS.md` for the surrounding research narrative.
-/

open Finset TropicalValuationBridge

namespace TropicalValuationBridge

/-! ## §1. Scale equivariance of the corner locus (Direction 2) -/

-- !-- Lab Notebook: attainedTwice_smul_iff -- !--
-- !-- Hypothesis: The corner-locus predicate is invariant under positive rescaling of all -- !--
-- !-- weights, since a strictly increasing map preserves the "global minimiser" relation. -- !--
-- !-- Result: Proved. `t * a ≤ t * b ↔ a ≤ b` for `t > 0` transports each minimality -- !--
-- !-- condition, and the witnessing pair `(i, j)` is unchanged. -- !--
-- !-- Insight: The whole `v_t = t·v` family has one fixed tropical shape; the "limit" slogan -- !--
-- !-- is an algebraic homothety invariance, not an analytic set-convergence. -- !--
-- !-- Failure analysis: A naive `OrderIso`-transport overcomplicated things; a direct iff on -- !--
-- !-- the minimality clauses via positivity of `t` is cleaner. -- !--
-- !-- End Lab Notebook -- !--

-- !-- Multiplying every weight by `t > 0` preserves `a ≤ b`, so the same witnessing indices -- !--
-- !-- `i ≠ j` realise the doubled minimum before and after scaling. -- !--
theorem attainedTwice_smul_iff {ι : Type*} (t : ℝ) (ht : 0 < t) (w : ι → ℝ) :
    AttainedAtLeastTwice (fun i => t * w i) ↔ AttainedAtLeastTwice w := by
  constructor <;> intro h
  · obtain ⟨i, j, hij, hi, hj⟩ := h
    exact ⟨i, j, hij, fun k => by nlinarith [hi k, hj k], fun k => by nlinarith [hi k, hj k]⟩
  · obtain ⟨i, j, hij, hi, hj⟩ := h
    exact ⟨i, j, hij, fun k => mul_le_mul_of_nonneg_left (hi k) ht.le,
      fun k => mul_le_mul_of_nonneg_left (hj k) ht.le⟩

/-! ## §2. Corner of a separated sum (combinatorial core of Direction 3) -/

-- !-- Lab Notebook: attainedTwice_product_add_iff -- !--
-- !-- Hypothesis: The minimum of `f i + g k` over a product is attained twice iff one -- !--
-- !-- factor's minimum is attained twice, because the minimiser set is the product of -- !--
-- !-- minimiser sets. -- !--
-- !-- Result: Proved. Forward: two distinct product-minimisers project to f-minimisers and -- !--
-- !-- g-minimisers; distinctness forces a repeat in one coordinate. Backward: pad a repeated -- !--
-- !-- minimiser of one factor with a fixed minimiser of the other. -- !--
-- !-- Insight: This is the exact pointwise reason `V(P⊙Q)=V(P)∪V(Q)`: corners of a sum of -- !--
-- !-- two convex PL functions occur where either summand has a corner. -- !--
-- !-- Failure analysis: Need finiteness/nonemptiness of BOTH factors for the backward -- !--
-- !-- direction (to produce a fixed minimiser of the passive coordinate). -- !--
-- !-- End Lab Notebook -- !--

-- !-- Forward: from two distinct minimisers of `f·+g·`, fix one coordinate to read off that -- !--
-- !-- the projections are minimisers of `f` and of `g`; distinctness yields a repeat in some -- !--
-- !-- coordinate. Backward: combine a doubled minimiser of one factor with any minimiser of -- !--
-- !-- the other (obtained via `Finite.exists_min`). -- !--
theorem attainedTwice_product_add_iff {ι κ : Type*} [Finite ι] [Nonempty ι] [Finite κ]
    [Nonempty κ] (f : ι → ℝ) (g : κ → ℝ) :
    AttainedAtLeastTwice (fun p : ι × κ => f p.1 + g p.2)
      ↔ AttainedAtLeastTwice f ∨ AttainedAtLeastTwice g := by
  constructor
  · intro h
    obtain ⟨p, q, hpq, h_min⟩ := h
    by_cases h_cases : p.1 = q.1
    · refine Or.inr ⟨p.2, q.2, ?_, ?_, ?_⟩ <;> simp_all +decide [Prod.ext_iff]
      all_goals exact fun k => by linarith [h_min.1 q.1 k, h_min.2 q.1 k]
    · left
      refine ⟨p.1, q.1, h_cases, fun k => ?_, fun k => ?_⟩
      · have := h_min.1 (k, p.2); have := h_min.2 (k, q.2); norm_num at *; linarith
      · have := h_min.1 (k, p.2); have := h_min.2 (k, q.2); norm_num at *; linarith
  · rintro (⟨i, j, hij, hi, hj⟩ | ⟨i, j, hij, hi, hj⟩)
    · obtain ⟨k, hk⟩ := Finite.exists_min g
      exact ⟨(i, k), (j, k), by aesop, fun p => by simpa using add_le_add (hi p.1) (hk p.2),
        fun p => by simpa using add_le_add (hj p.1) (hk p.2)⟩
    · obtain ⟨k, hk⟩ := Finite.exists_min f
      exact ⟨(k, i), (k, j), by aesop, fun p => by simpa using add_le_add (hk p.1) (hi p.2),
        fun p => by simpa using add_le_add (hk p.1) (hj p.2)⟩

/-! ## §3. The union law for tropical hypersurfaces (Direction 3) -/

/-- The tropical hypersurface (corner locus) of a tropical polynomial: the set of points where
the min-plus evaluation is non-smooth, i.e. its defining minimum is attained at least twice. -/
def TropPoly.tropHypersurface {ι : Type*} {n : ℕ} (P : TropPoly ι n) : Set (Fin n → ℝ) :=
  {x | AttainedAtLeastTwice (P.termVal x)}

-- !-- Each `(i,k)` monomial value of `P ⊙ Q` splits as `termVal P i + termVal Q k` by -- !--
-- !-- expanding `mul` and distributing the inner product. -- !--
theorem TropPoly.termVal_mul {ι κ : Type*} {n : ℕ} (P : TropPoly ι n) (Q : TropPoly κ n)
    (x : Fin n → ℝ) (p : ι × κ) :
    (P.mul Q).termVal x p = P.termVal x p.1 + Q.termVal x p.2 := by
  simp [TropPoly.termVal, TropPoly.mul, add_mul, Finset.sum_add_distrib]
  ring

-- !-- Lab Notebook: TropPoly.tropHypersurface_mul -- !--
-- !-- Hypothesis: The tropical hypersurface of a product is the union of the hypersurfaces. -- !--
-- !-- Result: Proved by combining `termVal_mul` (the monomial split) with -- !--
-- !-- `attainedTwice_product_add_iff` (corner of a separated sum). -- !--
-- !-- Insight: This is the analytic half of tropical Bezout; paired with the catalog lattice -- !--
-- !-- count `mixedLatticeIndex`, degrees multiply and hypersurfaces of products decompose. -- !--
-- !-- Failure analysis: The naive attempt to argue geometrically about PL graphs is replaced -- !--
-- !-- by the clean finite-combinatorial minimiser-set argument. -- !--
-- !-- End Lab Notebook -- !--

-- !-- Rewrite the product's term values via `termVal_mul`, then the corner-of-a-sum iff -- !--
-- !-- `attainedTwice_product_add_iff` turns "corner of `P⊙Q`" into "corner of `P` or corner -- !--
-- !-- of `Q`", which is membership in the union. -- !--
theorem TropPoly.tropHypersurface_mul {ι κ : Type*} {n : ℕ} [Finite ι] [Nonempty ι] [Finite κ]
    [Nonempty κ] (P : TropPoly ι n) (Q : TropPoly κ n) :
    (P.mul Q).tropHypersurf
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: Functoriality of the Valuation–Tropicalization Bridge

## Synthesis

This cycle took the *easy half* of the Fundamental Theorem of Tropical Geometry already in
`TropicalValuationLimitBridge.lean` (`kapranov_easy_direction`, the ultrametric winner-takes-all
lemma `addValuation_sum_eq_of_unique_min`, and min-plus multiplicativity `TropPoly.eval_mul`) and
turned three of its stated future directions into compiling Lean theorems. The unifying discovery
is that the corner-locus predicate `AttainedAtLeastTwice` is *functorial*: it is invariant under
positive rescaling of weights, and it interacts with the min-plus product exactly as a "support
of a sum-of-corners" should. Concretely, the minimiser set of a separated sum
`(i,k) ↦ f i + g k` is the **product** of the two minimiser sets, so the sum has a corner iff one
of the factors does. This single combinatorial fact (`attainedTwice_product_add_iff`) is the
pointwise engine behind both the slogan "tropicalize a product = add the tropicalizations"
(`TropPoly.eval_mul`, already in the catalog) and the geometric union law
`V(P ⊙ Q) = V(P) ∪ V(Q)` (`TropPoly.tropHypersurface_mul`, new here).

A second thread closed Direction 5: the valuation map is an *honest tropical morphism away from
ties*. We proved `v (x + y) = min (v x) (v y)` whenever `v x ≠ v y`
(`addValuation_add_eq_min_of_ne`), and packaged its contrapositive as
`addValuation_defect_imp_tie`: the locus where additivity fails is contained in the diagonal
`{v x = v y}`. This makes precise that the *same* tie coincidence that powers
`kapranov_easy_direction` (a minimum attained twice) is the *only* obstruction to `v` being a
strict min-plus semiring homomorphism. The additive and the corner-locus stories are one story.

What did not get formalized, and why: the *hard* direction of Kapranov (surjectivity onto the
corner locus) genuinely needs a lifting step (Newton polygon + Hensel) and remains a conjecture;
and the full tropical Bézout *count* needs to be glued to the catalog's `mixedLatticeIndex`
lattice arithmetic, which is a cross-file integration rather than a single lemma. Both are now
much closer: the union law removes the only analytic ingredient that was missing on the Bézout
side, and the scale-invariance lemma removes the only analytic ingredient that was missing on the
limit side.

## Results Summary

- `attainedTwice_smul_iff`: proved — the corner locus is invariant under positive rescaling of all
  weights, so the family `v_t = t·v` shares one fixed tropical shape (Direction 2 made algebraic).
- `attainedTwice_product_add_iff`: proved — a separated sum `f i + g k` has its minimum attained
  at least twice iff one of `f`, `g` does; the minimiser set of a sum is the product of minimiser
  sets.
- `TropPoly.termVal_mul`: proved — each monomial of a min-plus product splits as the sum of the
  corresponding monomials of the factors.
- `TropPoly.tropHypersurface_mul`: proved — the union law `V(P ⊙ Q) = V(P) ∪ V(Q)`, the a
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
of objects (not placeholder strings). For each algorithm in the algorithms array, provide a name, a detailed explanation of its logic and complexity in 'description', formal step-by-step pseudocode in 'pseudocode', and clean type-hinted Python code in 'code'. Include future directions from Phase A in the future_directions field.

Be vivid, be precise, be world-class. The math has already been done — now
make it beautiful to read.
