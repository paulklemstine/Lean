
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

**Title**: Self-contained Mathlib foundation for the discrete Hodg
**Domain**: Novelty
**Mathematical framing**: # FUTURE DIRECTIONS — Discrete Hodge ↔ Probability

This cycle established a self-contained Mathlib foundation for the discrete Hodge
program on finite weighted graphs and bridged it to the probability of reversible
random walks (file `Catalog/Bridges/DiscreteHodgeRandomWalk.lean`).

Proved this cycle:
- Dirichlet energy identity `xᵀ L x = ½ Σᵢⱼ wᵢⱼ (xᵢ − xⱼ)²`.
- Positive semidefiniteness of the combinatorial Laplacian `L = D − A`.
- Symmetry of `L`, zero row-sums, and harmonicity of constants.
- Detailed balance / reversibility of `P = D⁻¹A` w.r.t. the degree measure
  (stated *unconditionally* using totality of real division).
- The factorization `L f = D(f − Pf)` and the bridge theorem:
  at a positive-degree vertex, `(L f) i = 0 ⟺ (P f) i = f i`
  (discrete harmonic forms = walk-invariant functions).

The following conjectures are bold, precise, and testable in subsequent cycles.

## C1 — Kernel of `L` = locally constant functions (connectivity ⇒ 0th Hodge number)
For a finite weighted graph whose positive-weight relation is connected,
`L.mulVec f = 0 ↔ f` is constant. More generally, `dim ker L` equals the number
of connected components of the support graph. This is the discrete `H⁰` and the
0th Betti number; it is the natural next theorem after `laplacian_mulVec_const`
and `quadForm_nonneg` (the energy `½ Σ wᵢⱼ(fᵢ−fⱼ)²` vanishes iff `f` is constant
on each component).

## C2 — Spectral gap ⇒ exponential mixing of the reversible walk
Let `0 = λ₀ ≤ λ₁ ≤ … ` be the eigenvalues of the *normalized* Laplacian
`𝓛 = I − D^{-1/2} A D^{-1/2}`. Conjecture: for a connected graph with
`λ₁ > 0`, the reversible walk `P` satisfies a Poincaré inequality
`Var_π(f) ≤ (1/λ₁) · 𝓔(f, f)` (Dirichlet form), hence `Lᵖ` mixing
`‖Pᵗf − π(f)‖ ≤ (1 − λ₁)ᵗ ‖f‖`. This connects the Hodge spectrum directly to
the probabilistic convergence rate; the Dirichlet identity proved here is the
exact `𝓔(f,f)` appearing in the inequality.

## C3 — Discrete Hodge decomposition `ℝ^V = ker L ⊕ im L`
Because `L` is symmetric PSD, `ℝ^V` orthogonally decomposes as
`ker L ⊕ range L`, with `ker L` the harmonic part and `range L` the "exact +
co-exact" part. Conjecture (and formalize): every function uniquely splits as
`f = h + Lg` with `h` harmonic, and `h` is the orthogonal projection minimizing
Dirichlet energy among representatives of `f mod range L`. This is the finite-
dimensional Hodge theorem; it needs only `Matrix.IsSymm` + PSD already proved.

## C4 — Reversibility characterizes self-adjointness of `P` in the `π`-inner product
Conjecture: a stochastic kernel `P` on `Fin n` is reversible w.r.t. a positive
measure `π` (`πᵢ Pᵢⱼ = πⱼ Pⱼᵢ`) **iff** `P` is self-adjoint for the weighted
inner product `⟨f,g⟩_π = Σ πᵢ fᵢ gᵢ`, **iff** `P` arises from some symmetric
weight kernel `w` via `wᵢⱼ = πᵢ Pᵢⱼ`. This upgrades `reversible` from a property
of graph-derived walks to a full equivalence, identifying "reversible Markov
chain" with "weighted graph" canonically.

## C5 — Effective resistance is a metric, and a graph-Green's-function identity
Define effective resistance `R(i,j)` via the energy-minimizing `g` with
`L g = eᵢ − eⱼ` (well-defined on connected graphs by C3). Conjecture:
`R` is a metric on vertices (the "resistance metric"), `R(i,j) = (eᵢ−eⱼ)ᵀ L⁺ (eᵢ−eⱼ)`
with `L⁺` the Moore–Penrose pseudoinverse, and it equals the expected commute
time of the reversible walk up to the factor `2·(total weight)`. This is the
deepest probability↔Hodge bridge: the Green's function `L⁺` simultaneously
governs harmonic extension (Hodge) and commute/hitting times (probability).

Research domain: Novelty
Research mode: formalize


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: 02bb27d8_retry2_aristotle/Catalog/Algebra/MarkovBases/TwoWay.lean
/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The `2 × 2` basic move for two-way contingency tables

This file develops, from scratch and in an entirely elementary way, the algebra of
the *basic move* for two-way contingency tables with integer entries.

A two-way contingency table is just an `m × n` matrix of integers.  In algebraic
statistics one studies how to walk between tables sharing the same row and column
sums (the *margins*).  The fundamental building block of such a walk for the
independence model is the `2 × 2` basic move: pick two distinct rows `i, i'` and
two distinct columns `j, j'` and add the pattern

```
        j    j'
   i  [ -1   +1 ]
   i' [ +1   -1 ]
```

to the table (leaving all other entries untouched).  Adding such a move changes no
margin, so it produces another table with the same row and column sums.

This file proves exactly that elementary fact and nothing more: it is meant as a
reusable foundation for later work on contingency-table moves and Markov bases.
No connectivity theorems, Smith normal form, or general Markov-basis machinery is
used or developed here.

## Main definitions

* `Table m n` : the type of `m × n` integer matrices.
* `rowSum`, `colSum`, `totalSum` : the marginal sums.
* `sameMargins` : two tables have equal row sums and equal column sums.
* `basicMove i i' j j'` : the basic move pattern described above.
* `legalBasicStep T i i' j j'` : the move keeps every entry of `T` nonnegative.

## Main results

* `rowSum_basicMove` / `colSum_basicMove` : each marginal of the move vanishes.
* `totalSum_basicMove_zero` : the grand total of the move is `0`.
* `basicMove_preserves_rowSum` / `basicMove_preserves_colSum` : adding the move to
  a table does not change its margins entrywise.
* `basicMove_preserves_margins` : adding the move preserves all margins.
* `legalBasicStep_preserves_margins` : the same conclusion, packaged with the
  legality hypothesis (which is *not* needed for the margin computation and is
  retained only to record the typical context in which the move is applied).

## A note on hypotheses

The informal description of the basic move asks, for the *row* version, only that
`i ≠ i'`, and for the *column* version only that `j ≠ j'`.  With the concrete
pattern above this is not quite enough: the row sums of the move vanish precisely
when `j ≠ j'` (the `+1`/`-1` in a given row must sit in distinct columns to
cancel), while the column sums vanish precisely when `i ≠ i'`.  Accordingly each
statement below carries the hypothesis it genuinely needs.  We additionally keep
the originally requested hypothesis (`i ≠ i'` for the row statements, `j ≠ j'` for
the column statements); it is logically unused there but is harmless and records
the intended setting of a genuine basic move where all four indices are pairwise
"non-degenerate".
-/

import Mathlib

namespace Catalog.MarkovBases

open scoped BigOperators

variable {m n : ℕ}

/-- A two-way contingency table is an `m × n` matrix of integers. -/
abbrev Table (m n : ℕ) := Matrix (Fin m) (Fin n) ℤ

/-- The sum of the entries in row `r`. -/
def rowSum (T : Table m n) (r : Fin m) : ℤ := ∑ c, T r c

/-- The sum of the entries in column `c`. -/
def colSum (T : Table m n) (c : Fin n) : ℤ := ∑ r, T r c

/-- The grand total of all entries of the table. -/
def totalSum (T : Table m n) : ℤ := ∑ r, ∑ c, T r c

/-- Two tables have the *same margins* when their row sums agree and their column
sums agree. -/
def sameMargins (S T : Table m n) : Prop :=
  (∀ r, rowSum S r = rowSum T r) ∧ (∀ c, colSum S c = colSum T c)

/-- The `2 × 2` basic move: it places `-1` at `(i, j)`, `+1` at `(i, j')`,
`+1` at `(i', j)`, `-1` at `(i', j')`, and `0` everywhere else. -/
def basicMove (i i' : Fin m) (j j' : Fin n) : Table m n :=
  fun r c =>
    if r = i then (if c = j then -1 else if c = j' then 1 else 0)
    else if r = i' then (if c = j then 1 else if c = j' then -1 else 0)
    else 0

/-- A basic step is *legal* at `T` when adding the move keeps every entry
nonnegative (so that the result is again a genuine, non-negative, contingency
table). -/
def legalBasicStep (T : Table m n) (i i' : Fin m) (j j' : Fin n) : Prop :=
  ∀ r c, 0 ≤ (T + basicMove i i' j j') r c

/-! ### Pointwise description of the basic move -/

/-- Outside the two distinguished rows the move is identically zero. -/
theorem basicMove_apply_of_ne_rows (i i' : Fin m) (j j' : Fin n) {r : Fin m}
    (hr : r ≠ i) (hr' : r ≠ i') (c : Fin n) :
    basicMove i i' j j' r c = 0 := by
  unfold basicMove; aesop

/-! ### Marginals of the basic move -/

/-- Every row sum of the basic move vanishes (assuming the two columns are
distinct). The hypothesis `i ≠ i'` is retained from the informal statement but is
not needed for the row computation. -/
theorem rowSum_basicMove (i i' : Fin m) (j j' : Fin n) (_hi : i ≠ i') (hj : j ≠ j')
    (r : Fin m) : rowSum (basicMove i i' j j') r = 0 := by
  unfold basicMove rowSum; by_cases h : r = i <;> by_cases h' : r = i' <;> simp_all +decide [ Finset.sum_ite ] ;
  · rw [ Finset.card_filter ] ; aesop;
  · rw [ Finset.card_filter ] ; aesop

/-- Every column sum of the basic move vanishes (assuming the two rows are
distinct). The hypothesis `j ≠ j'` is retained from the informal statement but is
not needed for the column computation. -/
theorem colSum_basicMove (i i' : Fin m) (j j' : Fin n) (hi : i ≠ i') (_hj : j ≠ j')
    (c : Fin n) : colSum (basicMove i i' j j') c = 0 := by
  unfold colSum
  simp +decide [*, Finset.sum_ite, Finset.filter_ne', Finset.filter_eq', basicMove]
  omega

/-- The grand total of the basic move is zero.  We deduce it from the vanishing of
the (row) margins. -/
theorem totalSum_basicMove_zero (i i' : Fin m) (j j' : Fin n) (hi : i ≠ i')
    (hj : j ≠ j') : totalSum (basicMove i i' j j') = 0 := by
  convert Finset.sum_eq_zero fun r hr => rowSum_basicMove i i' j j' hi hj r

/-! ### The basic move preserves margins -/

/-- Adding the basic move to a table leaves each row sum unchanged. -/
theorem basicMove_preserves_rowSum (T : Table m n) (i i' : Fin m) (j j' : Fin n)
    (hi : i ≠ i') (hj : j ≠ j') (r : Fin m) :
    rowSum (T + basicMove i i' j j') r = rowSum T r := by
  have h : ∑ c, basicMove i i' j j' r c = 0 := rowSum_basicMove i i' j j' hi hj r
  simp only [rowSum, Matrix.add_apply, Finset.sum_add_distrib]
  rw [h, add_zero]

/-- Adding the basic move to a table leaves each column sum unchanged. -/
theorem basicMove_preserves_colSum (T : Table m n) (i i' : Fin m) (j j' : Fin n)
    (hi : i ≠ i') (hj : j ≠ j') (c : Fin n) :
    colSum (T + basicMove i i' j j') c = colSum T c := by
  have h : ∑ r, basicMove i i' j j' r c = 0 := colSum_basicMove i i' j j' hi hj c
  simp only [colSum, Matrix.add_apply, Finset.sum_add_distrib]
  rw [h, add_zero]

/-- Adding the basic move to a table preserves all of its margins. -/
theorem basicMove_preserves_margins (T : Table m n) (i i' : Fin m) (j j' : Fin n)
    (hi : i ≠ i') (hj : j ≠ j') :
    sameMargins T (T + basicMove i i' j j') := by
  refine ⟨fun r => ?_, fun c => ?_⟩
  · exact (basicMove_preserves_rowSum T i i' j j' hi hj r).symm
  · exact (basicMove_preserves_colSum T i i' j j' hi hj c).symm

/-- The legal version: if the basic step is legal and the indices are
non-degenerate, then it preserves all margins.  The proof makes explicit that the
legality hypothesis `_hlegal` plays no role in the margin computation: it is
introduced into the context but never used, the conclusion following directly from
`basicMove_preserves_margins`. -/
theorem legalBasicStep_preserves_margins (T : Table m n) (i i' : Fin m)
    (j j' : Fin n) (_hlegal : legalBasicStep T i i' j j') (hi : i ≠ i')
    (hj : j ≠ j') : sameMargins T (T + basicMove i i' j j') :=
  basicMove_preserves_margins T i i' j j' hi hj

end Catalog.MarkovBases
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# FUTURE DIRECTIONS — Discrete Hodge ↔ Probability (cycle v16a)

This cycle delivered a self-contained Mathlib foundation for the discrete Hodge
program on finite weighted graphs and proved two of the program's headline
conjectures:

* `Catalog/Bridges/DiscreteHodgeRandomWalk.lean` — the foundation: Dirichlet
  energy identity `xᵀLx = ½ Σᵢⱼ wᵢⱼ(xᵢ−xⱼ)²`, positive semidefiniteness and
  symmetry of `L = D − A`, harmonicity of constants, unconditional detailed
  balance for `P = D⁻¹A`, the factorization `L f = D(f − Pf)`, and the bridge
  `(L f)ᵢ = 0 ⟺ (P f)ᵢ = fᵢ` at positive-degree vertices.
* `Catalog/Bridges/DiscreteHodgeKernel.lean` — **C1 solved**: on a connected
  graph, `ker L` is exactly the constants (discrete `H⁰`).
* `Catalog/Bridges/DiscreteHodgeReversibility.lean` — **C4 solved**: reversibility
  ⟺ `π`-self-adjointness ⟺ symmetry of the weight kernel `wᵢⱼ = πᵢ Pᵢⱼ`.

The adversarial review of each theorem (recorded in the in-file Lab Notes) located
the exact boundary cases — disconnection for C1, zero-degree vertices for the
bridge, and indicator-vector necessity for C4 — and those boundaries are precisely
what the conjectures below promote to theorems.

---

## D1 — `dim ker L` equals the number of connected components

For a finite weighted graph, `Module.finrank ℝ (LinearMap.ker (Matrix.mulVecLin (lap w)))`
equals the number of connected components of the positive-weight support graph,
with the component indicator functions as an explicit basis.

**The key insight is** that `lap_mulVec_eq_zero_iff_const` already pins the kernel
on *one* connected component to a 1-dimensional space; the global kernel is the
direct sum over components, so the dimension is a pure counting statement once the
component partition (via `Relation.ReflTransGen`) is in hand.

**Why now?** The connectedness counterexample surfaced by the C1 critic (two
isolated vertices give a 2-dimensional kernel) is exactly the `n`-component case,
so the proof is a localization of the already-formalized connected result rather
than new analysis.

---

## D2 — Spectral gap ⇒ Poincaré inequality for the reversible walk

For a connected graph, let `λ₁ > 0` be the smallest nonzero eigenvalue of `L`
relative to the degree inner product. Then `Var_π(f) ≤ (1/λ₁) · 𝓔(f,f)` where
`𝓔(f,f) = ½ Σᵢⱼ wᵢⱼ(fᵢ−fⱼ)²` is the Dirichlet form proved here, hence the walk
contracts variance by a factor `(1 − λ₁)` per step.

**The key insight is** that `lap_quadForm` identifies `𝓔(f,f)` *on the nose* with
`fᵀLf`, and `lap_posSemidef` plus C1 give the spectral decomposition `0 = λ₀ < λ₁`
with the constants as the bottom eigenspace; the Poincaré constant is then the
Courant–Fischer minimum over the orthogonal complement of constants.

**Why now?** Both ingredients — the exact energy identity and the
"kernel = constants" gap-opening fact — are formalized this cycle, so the
inequality reduces to a Rayleigh-quotient argument with no missing analytic input.

---

## D3 — Finite-dimensional discrete Hodge
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
