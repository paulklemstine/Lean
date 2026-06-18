
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
3. **RESEARCH_PAPER.tex** (NEW) — A clean, compilable LaTeX version of
   the paper that mirrors the content of RESEARCH_PAPER.md. Use standard
   amsmath/amsart or article class, define all theorems inline, and make
   it suitable for direct PDF compilation with `pdflatex`. This is the
   publishable artifact.
4. **demo.py** — Numerical examples demonstrating the key results.
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
  "research_paper_tex": "RESEARCH_PAPER.tex",
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

**Title**: Speculative: Topological Data Analysis of Theorem Networks
**Domain**: Tropical
**Mathematical framing**: Construct a simplicial complex from the citation graph of mathematical theorems: vertices are theorems, edges connect co-cited theorems, triangles connect tri-cited theorems, etc. Compute the persistent homology of this complex. Conjecture: H_1 reveals 'schools of mathematics' (connected research communities) and H_2 reveals 'paradigm shifts' (structural changes in the network). Prove: the Betti numbers grow as β_k ≈ n^(k+1) where n is the number of theorems.
Research domain: Tropical
Research mode: sorry_fill


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: 2d22ac65_retry3_aristotle/Catalog/Logic/BelnapFour/Paraconsistency.lean
import Logic.BelnapFour.Core

/-!
# Belnap's FOUR: paraconsistency and the product representation `FOUR ≅ 2 ⊙ 2`

Building on `Logic.BelnapFour.Core`, this file proves the two facts that make FOUR the
*smallest non-trivial paraconsistent bilattice*:

* **Paraconsistency (non-explosion).** With the designated set `D = {T, B}`, the
  "contradiction" premise `designated a ∧ designated (¬a)` is *satisfiable* in FOUR
  (witness `B`), yet it does **not** entail an arbitrary conclusion. By contrast the
  classical two-valued algebra makes that premise *unsatisfiable*, which is why classical
  logic is explosive.

* **Representation `FOUR ≅ Bool × Bool` (Ginsberg's `2 ⊙ 2`).** The map
  `N ↦ (ff,ff)`, `F ↦ (ff,tt)`, `T ↦ (tt,ff)`, `B ↦ (tt,tt)`
  ("evidence-for", "evidence-against") is a bijection under which the knowledge order is
  the product order, the knowledge meet/join are componentwise `&&`/`||`, the truth order
  is the *twisted* product order (first up, second down), and negation is the coordinate
  swap. Hence FOUR has exactly `2² = 4` elements: it is the bilattice over the smallest
  non-trivial lattice `2 = Bool`.

-- !-- Lab Notebook -- !--
Hypothesis: FOUR is paraconsistent and is the smallest such bilattice, realised as the
  product `2 ⊙ 2` of the two-element lattice with itself.
Result: `explosion_premise_satisfiable` + `no_explosion` establish paraconsistency;
  `bool_explosion_*` show the classical algebra is explosive only because its
  contradiction premise is unsatisfiable; `belnap_iso_prod` and the transport lemmas
  establish `FOUR ≅ Bool × Bool`; `card_four` + `orders_two_dimensional` pin down
  minimality and genuine two-dimensionality.
Insight: Paraconsistency is exactly the gap between *satisfiable* contradiction premises
  and *valid* explosion — a gap that opens precisely when a value (here `B`) is both
  designated and has a designated negation. The fourth value `N` is forced as the
  knowledge-order bottom dual to `B`, which is why four is the minimum.
Failure analysis: A naive "conflation = componentwise negation" guess is false; the
  correct transport is `conf ↦ (¬·₂, ¬·₁)` (swap-then-negate), found by recomputing the
  table. The `decide`-checked transport lemmas guard against such table errors.
-/

namespace BelnapFour
namespace Belnap

/-- The designated ("at least true") values: `T` and `B`. A valuation makes a sentence
assertible exactly when its value is designated. -/
def designated (a : Belnap) : Prop := a = T ∨ a = B

instance (a : Belnap) : Decidable (designated a) := by
  unfold designated; exact inferInstance

/-! ## Designation respects the truth order -/

-- !-- The truth order is the FDE entailment relation: moving up `≤_t` can only turn a
-- non-designated value designated, never the reverse. Finite case check. -- !--
/-- Tautological (FDE) entailment is the truth order: if `a ≤_t b` then designation is
preserved from `a` to `b`. -/
theorem tle_preserves_designated :
    ∀ a b : Belnap, tle a b → designated a → designated b := by
  decide

/-! ## Theorem 4 — paraconsistency (non-explosion) -/

-- !-- `B` is designated and so is `¬B = B`, so the contradiction premise is satisfiable
-- in FOUR — unlike in the classical algebra. -- !--
/-- **Theorem 4a.** The contradiction premise is *satisfiable* in FOUR: some value is
designated together with its negation (witness `B`). -/
theorem explosion_premise_satisfiable :
    ∃ a : Belnap, designated a ∧ designated (neg a) := by
  decide

-- !-- Taking the satisfiable premise `a = B` and conclusion `q = F` (not designated)
-- refutes explosion. Finite case check. -- !--
/-- **Theorem 4b (Paraconsistency).** FOUR is *non-explosive*: it is not the case that a
designated value with a designated negation entails every conclusion. -/
theorem no_explosion :
    ¬ (∀ a q : Belnap, designated a → designated (neg a) → designated q) := by
  decide

/-- **Theorem 4c.** The classical two-valued algebra is explosive *because* its
contradiction premise is unsatisfiable: no Boolean value is designated together with its
classical negation. -/
theorem bool_explosion_premise_unsatisfiable :
    ¬ ∃ b : Bool, b = true ∧ (!b) = true := by
  decide

/-- **Theorem 4c′.** Consequently classical logic validates explosion (vacuously): from a
Boolean contradiction premise every conclusion follows. -/
theorem bool_validates_explosion :
    ∀ b q : Bool, b = true → (!b) = true → q = true := by
  decide

/-! ## Theorem 5 — the product representation `FOUR ≅ 2 ⊙ 2` -/

/-- The representation map sending a Belnap value to its
`(evidence-for, evidence-against)` pair in `Bool × Bool`. -/
def toProd : Belnap → Bool × Bool
  | N => (false, false)
  | F => (false, true)
  | T => (true, false)
  | B => (true, true)

/-- The inverse of `toProd`. -/
def ofProd : Bool × Bool → Belnap
  | (false, false) => N
  | (false, true)  => F
  | (true, false)  => T
  | (true, true)   => B

-- !-- `ofProd` and `toProd` are mutually inverse on the four-element carrier; finite
-- round-trip check. -- !--
/-- **Theorem 5a.** `toProd` is a bijection `Belnap ≃ Bool × Bool`; in particular FOUR has
exactly `2² = 4` elements, the bilattice over the two-element lattice. -/
theorem belnap_iso_prod :
    (∀ a : Belnap, ofProd (toProd a) = a) ∧ (∀ p : Bool × Bool, toProd (ofProd p) = p) := by
  refine ⟨?_, ?_⟩ <;> decide

/-- Packaged equivalence `Belnap ≃ Bool × Bool`. -/
def equivProd : Belnap ≃ Bool × Bool where
  toFun := toProd
  invFun := ofProd
  left_inv a := belnap_iso_prod.1 a
  right_inv p := belnap_iso_prod.2 p

-- !-- Under `toProd` the knowledge order is the product order and the truth order is the
-- twisted product order (first coordinate up, second coordinate down). -- !--
/-- **Theorem 5b.** Transport of the two orders: knowledge = product order, truth =
twisted product order. -/
theorem orders_transport :
    (∀ a b : Belnap, kle a b ↔
        (toProd a).1 ≤ (toProd b).1 ∧ (toProd a).2 ≤ (toProd b).2) ∧
    (∀ a b : Belnap, tle a b ↔
        (toProd a).1 ≤ (toProd b).1 ∧ (toProd b).2 ≤ (toProd a).2) := by
  refine ⟨?_, ?_⟩ <;> decide

-- !-- All four operations and both involutions transport to coordinatewise Boolean
-- operations on `Bool × Bool`, confirming `FOUR = 2 ⊙ 2`. -- !--
/-- **Theorem 5c.** Transport of all operations: every Belnap operation becomes a
coordinatewise Boolean operation on `Bool × Bool` (knowledge meet/join are componentwise
`&&`/`||`; truth meet/join twist the second coordinate; negation swaps; conflation
swap-negates). This is the defining property of the product bilattice `2 ⊙ 2`. -/
theorem operations_transport :
    (∀ a b : Belnap, toProd (a ⊗ₖ b) = ((toProd a).1 && (toProd b).1, (toProd a).2 && (toProd b).2)) ∧
    (∀ a b : Belnap, toProd (a ⊕ₖ b) = ((toProd a).1 || (toProd b).1, (toProd a).2 || (toProd b).2)) ∧
    (∀ a b : Belnap, toProd (a ⊓ₜ b) = ((toProd a).1 && (toProd b).1, (toProd a).2 || (toProd b).2)) ∧
    (∀ a b : Belnap, toProd (a ⊔ₜ b) = ((toProd a).1 || (toProd b).1, (toProd a).2 && (toProd b).2)) ∧
    (∀ a : Belnap, toProd (neg a) = ((toProd a).2, (toProd a).1)) ∧
    (∀ a : Belnap, toProd (conf a) = (!(toProd a).2, !(toProd a).1)) := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩ <;> decide

/-! ## Theorem 6 — minimality and genuine two-dimensionality -/

/-- **Theorem 6a.** FOUR has exactly four elements. -/
theorem card_four : Fintype.card Belnap = 4 := by decide

-- !-- The two orders are genuinely different: each contains a strict relation absent from
-- the other, so FOUR is a real bilattice rather than one order duplicated. -- !--
/-- **Theorem 6b.** The truth and knowledge orders are genuinely two-dimensional: neither
order refines the other, so the bilattice does not collapse to a single chain/lattice. -/
theorem orders_two_dimensional :
    (∃ a b : Belnap, tle a b ∧ ¬ kle a b) ∧ (∃ a b : Belnap, kle a b ∧ ¬ tle a b) := by
  decide

/-- **Theorem 6c.** Minimality witness: paraco
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# FUTURE DIRECTIONS — Tropical Persistent Topology

Research cycle: *Topological Data Analysis of Theorem Networks* (Domain: Tropical).
Foundation laid in `Catalog/Tropical/Persistence/SublevelFiltration.lean`:
tropical polynomials are convex, their sublevel filtrations have a single-bar
degree-0 persistence, and the tropical semiring operations `⊕ = max`, `⊗ = +`
act on value functions and on the filtration in a controlled way.

Below are bold, **testable** conjectures for follow-up cycles. Each is stated so
that it can be formalized as a Lean theorem (or refuted by a Lean
counterexample).

## C1 — Degree-`k` persistence collapse (k ≥ 1)
**Conjecture.** For every tropical polynomial `p : TropPoly n` and every threshold
`c`, the sublevel set `sublevel p c` is contractible whenever it is nonempty;
hence *all* reduced persistent homology vanishes and the full persistence diagram
is the single H₀ bar already established.
*Test.* Strengthen `convex_sublevel` to `Contractible`/`StarConvex` (a convex set
in `ℝⁿ` is contractible). Formalize via `Convex.contractibleSpace` or by
exhibiting a star-center. Falsifiable: produce a `p`, `c` with disconnected or
holey sublevel set (impossible if convexity is unconditional — so the conjecture
predicts no such example exists).

## C2 — Tropical hypersurfaces are the true carriers of topology
**Conjecture.** Replace the *sublevel* set by the **tropical hypersurface**
(the non-differentiability locus `V(p) = { x | the max in p.toFun x is attained
≥ twice }`). Then the filtration of `ℝⁿ \ V(p)` by connected components is
governed by `card p.ι`: the number of top-dimensional regions equals the number
of monomials that are "essential" (achieve the max somewhere), and this count is
*sub-additive* under `⊕` and *multiplicative-with-defect* under `⊗`.
*Test.* Define `essential p = { i | ∃ x, p.toFun x = monomial (coeff i) (slope i) x }`
and prove `essential (tropAdd p q) ⊆ image essential p ∪ image essential q`.

## C3 — Persistence stability for tropical polynomials  *(pointwise core: PROVED)*
**Status.** The pointwise, dimension-free part is established as `toFun_stable`
in `SublevelFiltration.lean`: `|p.toFun x − (p.recoeff a').toFun x| ≤
⨆ᵢ |coeffᵢ − a'ᵢ|`, uniformly in `x`, with the generic `sup'`-Lipschitz lemma
`abs_sup'_sub_sup'_le`.
**Remaining conjecture.** Lift this to *barcode* stability: the degree-0 birth
value `b(p)` (see C4) is `1`-Lipschitz in the coefficients, and more generally the
bottleneck distance of persistence diagrams is bounded by the sup-distance of
coefficients.
*Test.* Combine `toFun_stable` with the existence of a minimizer (C4) to bound
`|b(p) − b(q)|`. Falsifiable by any coefficient perturbation producing a
birth-value jump exceeding the perturbation.

## C4 — Newton-polytope ↔ persistence dictionary
**Conjecture.** The birth value `b(p) = inf { c | sublevel p c ≠ ∅ }` of the
single H₀ bar equals the value of the tropical polynomial at the *tropical
minimum*, and is determined entirely by
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
