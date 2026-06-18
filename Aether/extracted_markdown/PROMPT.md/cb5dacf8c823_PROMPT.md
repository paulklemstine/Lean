
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

**Title**: Functorial bridge from combinatorial species generating functions to tropical valuation profiles
**Domain**: Bridges
**Mathematical framing**: 
Research domain: Bridges
Research mode: formalize


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: 049cc9b2_retry3_aristotle/Catalog/Algebra/MarkovBases/TwoWay.lean
/-
# Basic `2 × 2` moves on integer-valued two-way contingency tables

This file develops a clean, narrowly scoped formal foundation for the basic
`2 × 2` move used in the theory of Markov bases for two-way contingency tables.

A *table* is an integer matrix `Table m n = Matrix (Fin m) (Fin n) ℤ`.  We record
its row sums, column sums and total sum, and define `sameMargins` to mean that two
tables agree on all row and column sums.

The basic move `basicMove i i' j j'` is the integer table that is `-1` at `(i,j)`
and `(i',j')`, `+1` at `(i,j')` and `(i',j)`, and `0` elsewhere.  Adding such a
move to a table leaves all margins unchanged, which is the content of the final
results in this file.
-/

import Mathlib

namespace Algebra.MarkovBases.TwoWay

open scoped BigOperators

/-- A two-way contingency table is an integer matrix indexed by `Fin m × Fin n`. -/
abbrev Table (m n : ℕ) := Matrix (Fin m) (Fin n) ℤ

variable {m n : ℕ}

/-- The sum of the entries in row `i`. -/
def rowSum (T : Table m n) (i : Fin m) : ℤ := ∑ j, T i j

/-- The sum of the entries in column `j`. -/
def colSum (T : Table m n) (j : Fin n) : ℤ := ∑ i, T i j

/-- The sum of all entries of the table. -/
def totalSum (T : Table m n) : ℤ := ∑ i, ∑ j, T i j

/-- Two tables have the same margins if all of their row sums and all of their
column sums agree. -/
def sameMargins (T T' : Table m n) : Prop :=
  (∀ i, rowSum T i = rowSum T' i) ∧ (∀ j, colSum T j = colSum T' j)

/-! ## Additivity lemmas -/

theorem rowSum_add (T T' : Table m n) (i : Fin m) :
    rowSum (T + T') i = rowSum T i + rowSum T' i := by
  simp [rowSum, Finset.sum_add_distrib]

theorem colSum_add (T T' : Table m n) (j : Fin n) :
    colSum (T + T') j = colSum T j + colSum T' j := by
  simp [colSum, Finset.sum_add_distrib]

theorem totalSum_add (T T' : Table m n) :
    totalSum (T + T') = totalSum T + totalSum T' := by
  simp [totalSum, Finset.sum_add_distrib]

/-! ## The basic `2 × 2` move -/

/-- The basic `2 × 2` move table: it has value `-1` at `(i,j)` and `(i',j')`,
value `+1` at `(i,j')` and `(i',j)`, and `0` everywhere else.

The `ite`s are ordered so that the four distinguished coordinates take the stated
values whenever `i ≠ i'` and `j ≠ j'`. -/
def basicMove (i i' : Fin m) (j j' : Fin n) : Table m n :=
  fun a b =>
    if a = i ∧ b = j then -1
    else if a = i ∧ b = j' then 1
    else if a = i' ∧ b = j then 1
    else if a = i' ∧ b = j' then -1
    else 0

/-! ## Pointwise evaluation of the basic move -/

@[simp] theorem basicMove_apply_same_left_same_left (i i' : Fin m) (j j' : Fin n) :
    basicMove i i' j j' i j = -1 := by
  simp [basicMove]

theorem basicMove_apply_same_left_same_right (i i' : Fin m) (j j' : Fin n)
    (hj : j ≠ j') : basicMove i i' j j' i j' = 1 := by
  simp [basicMove, hj.symm]

theorem basicMove_apply_same_right_same_left (i i' : Fin m) (j j' : Fin n)
    (hi : i ≠ i') : basicMove i i' j j' i' j = 1 := by
  simp [basicMove, hi.symm]

theorem basicMove_apply_same_right_same_right (i i' : Fin m) (j j' : Fin n)
    (hi : i ≠ i') (hj : j ≠ j') : basicMove i i' j j' i' j' = -1 := by
  simp [basicMove, hi.symm, hj.symm]

/-- Entries away from the two distinguished columns `j, j'` are zero. -/
theorem basicMove_apply_off_col (i i' : Fin m) (j j' : Fin n) (a : Fin m) (b : Fin n)
    (hbj : b ≠ j) (hbj' : b ≠ j') : basicMove i i' j j' a b = 0 := by
  simp [basicMove, hbj, hbj']

/-- Entries away from the two distinguished rows `i, i'` are zero. -/
theorem basicMove_apply_off_row (i i' : Fin m) (j j' : Fin n) (a : Fin m) (b : Fin n)
    (hai : a ≠ i) (hai' : a ≠ i') : basicMove i i' j j' a b = 0 := by
  simp [basicMove, hai, hai']

/-- Away from the four distinguished coordinates the basic move is zero. -/
theorem basicMove_apply_of_ne (i i' : Fin m) (j j' : Fin n) (a : Fin m) (b : Fin n)
    (h₁ : ¬ (a = i ∧ b = j)) (h₂ : ¬ (a = i ∧ b = j'))
    (h₃ : ¬ (a = i' ∧ b = j)) (h₄ : ¬ (a = i' ∧ b = j')) :
    basicMove i i' j j' a b = 0 := by
  simp [basicMove, h₁, h₂, h₃, h₄]

/-- In each row, the two entries in the distinguished columns cancel
(assuming `j ≠ j'`). -/
theorem basicMove_row_pair (i i' : Fin m) (j j' : Fin n) (hj : j ≠ j') (a : Fin m) :
    basicMove i i' j j' a j + basicMove i i' j j' a j' = 0 := by
  by_cases hai : a = i
  · subst hai
    by_cases hai' : a = i' <;> simp [basicMove, hj.symm, hai']
  · by_cases hai' : a = i'
    · subst hai'
      simp [basicMove, hj, hj.symm, hai]
    · simp [basicMove, hai, hai']

/-- In each column, the two entries in the distinguished rows cancel
(assuming `i ≠ i'`). -/
theorem basicMove_col_pair (i i' : Fin m) (j j' : Fin n) (hi : i ≠ i') (b : Fin n) :
    basicMove i i' j j' i b + basicMove i i' j j' i' b = 0 := by
  by_cases hbj : b = j
  · subst hbj
    simp [basicMove, hi.symm]
  · by_cases hbj' : b = j'
    · subst hbj'
      simp [basicMove, hi.symm, hbj]
    · simp [basicMove, hbj, hbj']

/-! ## Zero-margin results -/

/-- Every row sum of the basic move vanishes (assuming `j ≠ j'`). -/
theorem rowSum_basicMove (i i' : Fin m) (j j' : Fin n) (hj : j ≠ j') (a : Fin m) :
    rowSum (basicMove i i' j j') a = 0 := by
  unfold rowSum
  rw [← Finset.sum_subset (Finset.subset_univ ({j, j'} : Finset (Fin n)))]
  · rw [Finset.sum_pair hj]
    exact basicMove_row_pair i i' j j' hj a
  · intro b _ hb
    rw [Finset.mem_insert, Finset.mem_singleton] at hb
    push_neg at hb
    exact basicMove_apply_off_col i i' j j' a b hb.1 hb.2

/-- Every column sum of the basic move vanishes (assuming `i ≠ i'`). -/
theorem colSum_basicMove (i i' : Fin m) (j j' : Fin n) (hi : i ≠ i') (b : Fin n) :
    colSum (basicMove i i' j j') b = 0 := by
  unfold colSum
  rw [← Finset.sum_subset (Finset.subset_univ ({i, i'} : Finset (Fin m)))]
  · rw [Finset.sum_pair hi]
    exact basicMove_col_pair i i' j j' hi b
  · intro a _ ha
    rw [Finset.mem_insert, Finset.mem_singleton] at ha
    push_neg at ha
    exact basicMove_apply_off_row i i' j j' a b ha.1 ha.2

/-- The total sum of the basic move vanishes (assuming `j ≠ j'`). -/
theorem totalSum_basicMove (i i' : Fin m) (j j' : Fin n) (hj : j ≠ j') :
    totalSum (basicMove i i' j j') = 0 := by
  unfold totalSum
  have hrow : ∀ a, (∑ b, basicMove i i' j j' a b) = 0 := by
    intro a
    have := rowSum_basicMove i i' j j' hj a
    simpa [rowSum] using this
  simp [hrow]

/-! ## Preservation of margins under addition -/

/-- Adding the basic move preserves all row sums. -/
theorem basicMove_preserves_rowSum (T : Table m n) (i i' : Fin m) (j j' : Fin n)
    (hj : j ≠ j') (a : Fin m) :
    rowSum (T + basicMove i i' j j') a = rowSum T a := by
  rw [rowSum_add, rowSum_basicMove i i' j j' hj, add_zero]

/-- Adding the basic move preserves all column sums. -/
theorem basicMove_preserves_colSum (T : Table m n) (i i' : Fin m) (j j' : Fin n)
    (hi : i ≠ i') (b : Fin n) :
    colSum (T + basicMove i i' j j') b = colSum T b := by
  rw [colSum_add, colSum_basicMove i i' j j' hi, add_zero]

/-- Adding the basic move preserves all margins. -/
theorem basicMove_preserves_margins (T : Table m n) (i i' : Fin m) (j j' : Fin n)
    (hi : i ≠ i') (hj : j ≠ j') :
    sameMargins T (T + basicMove i i' j j') := by
  refine ⟨fun a => ?_, fun b => ?_⟩
  · rw [basicMove_preserves_rowSum T i i' j j' hj]
  · rw [basicMove_preserves_colSum T i i' j j' hi]

end Algebra.MarkovBases.TwoWay
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions

These directions extend the `ordEGF` bridge in
`Catalog/Bridges/SpeciesTropicalValuation.lean` from a single order-only invariant toward
richer tropical and valuation-theoretic semantics for combinatorial sequences.

## 1. From order-only profiles to coefficientwise valuation profiles

The current invariant `ordEGF a = order (egf a)` retains only the *first* place where the EGF
is supported; it discards everything about the remaining coefficients. The key insight is that
the order map is just the degree-`0` shadow of a far finer object — the full *valuation profile*
`n ↦ v(coeff n (egf a))` valued in an ordered value group — and the same two transport lemmas
(`order_mul`, `min_order_le_order_add`) are the leading-term specializations of coefficientwise
additivity and ultrametric subadditivity. Why now? Because the bridge already isolates the exact
two power-series facts being transported, so swapping `order` for a `p`-adic or `X`-adic
valuation profile is a localized change: once Mathlib's valuation infrastructure on
`PowerSeries`/Laurent series is connected to `egf`, the present theorems generalize almost
verbatim to a coefficientwise profile that detects cancellation in *every* degree rather than
only the first.

## 2. A genuine tropical-semiring homomorphism object

Right now the multiplicative and additive bridges live as two separate theorems. The key
insight is that `ordEGF` is a structure-preserving map from the exponential-convolution
semiring `(ℕ → ℚ, binConv, +)` into the tropical semiring `(WithTop ℕ, +, min)`, and that this
should be packaged as a bundled semiring (or at least monoid) homomorphism rather than as loose
lemmas. Why now? Because `Catalog/Applications/SpeciesConvolutionRing.lean` already exhibits the
counting sequences as a commutative semiring under `binConv`, so the domain object exists; the
only missing piece is choosing the right tropical target instance, after which `ordEGF_binConv`
and `ordEGF_add_ge` become the `map_mul`/`map_add`-style fields of a single bundled morphism that
downstream files can apply uniformly.

## 3. Sharp cancellation criteria for the additive bridge

The additive bridge is an inequality, `min (ordEGF a) (ordEGF b) ≤ ordEGF (a + b)`, and the gap
is exactly leading-term cancellation. The key insight is that equality fails *iff* the lowest
nonvanishing coefficients of `egf a` and `egf b` sit in the same degree and cancel, which is a
decidable, fully explicit condition on `a` and `b` at the common order. Why now? Because the
order API in Mathlib (`order_le`, `coeff_order`, and friends) already exposes the leading
coefficient, so a clean `ordEGF (a + b) = min (ordEGF a) (ordEGF b)` theorem under a
"no leading cancellation" hypothesis is within immediate reach and would turn the present
superadditivity into a tight tropical valuation law.

## 4. Tropicalized species operations and a Newton-polygon layer

The species corollary layer is currently a thin wrapper (`speciesOrdEGF`, 
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
