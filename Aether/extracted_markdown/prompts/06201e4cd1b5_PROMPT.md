
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

**Title**: Close Proofs: Close Proofs: This cycle added `Catalog/Pythagorean/FibonacciEntryFact
**Domain**: Novelty
**Mathematical framing**: Cycle d5040457 (Q=0.446) proved 1008 theorems in Cryptography but left 5 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: Cycle c390fa53 (Q=0.424) proved 1255 theorems in Novelty but left 7 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: # Future Directions — Pr
Research domain: Novelty
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Algebra/MarkovBases/NoThreeWay.lean
import Mathlib

/-!
# Algebraic Statistics: Markov Basis of the No-Three-Way Interaction Model

This file formalises the celebrated `2 × 2 × 2` **no-three-way interaction model** of
algebraic statistics (Diaconis–Sturmfels) and proves the *Fundamental Theorem of Markov
Bases* for it: a single explicit move connects every fiber.

A `2 × 2 × 2` contingency table is `u : Fin 2 → Fin 2 → Fin 2 → ℤ`.  The no-three-way
interaction model fixes **all three families of two-dimensional margins**
(`(i,j)`-margins summing over `k`, `(i,k)`-margins summing over `j`, and `(j,k)`-margins
summing over `i`).  A *fiber* is the set of non-negative integer tables with prescribed
two-way margins.

The remarkable fact is that, although there are 8 cells and many margin constraints, the
move lattice is **rank one**: it is generated by the single alternating move
`m(i,j,k) = (-1)^(i+j+k)`.  This is the smallest Markov basis whose generator is *not* a
simple `2×2` swap; the move has degree 4 (it touches all 8 cells), which is exactly why the
no-three-way model is the textbook first example beyond decomposable models.

## Main results

* `noThreeWay_move_preserves_margins` — the alternating move `M3` lies in the kernel of the
  two-way margin map (it is a legal model move).
* `noThreeWay_kernel` — **the move lattice has rank one**: any two equal-margin tables
  differ by `(v 0 0 0 - u 0 0 0) • M3`.  Equivalently `{M3}` generates the move lattice,
  i.e. it is *the* Markov basis.
* `noThreeWay_fiber_connected` — **Fundamental Theorem of Markov Bases (this model).** Any
  two *non-negative* tables with equal two-way margins are joined by a walk of `± M3` moves
  that stays non-negative at every step: `{M3}` connects every fiber.

## Catalog synthesis

The move `M3` is a rank-one `ℤ`-sublattice of the free module `Fin 2 → Fin 2 → Fin 2 → ℤ`;
`noThreeWay_kernel` is a concrete kernel computation for an integer "design matrix", linking
linear algebra over `ℤ` (catalog: lattice/module structure theory) with combinatorial walks
(catalog: connectivity of step relations via `Relation.ReflTransGen`).  The connectivity
proof is a discrete convexity argument: the non-negative locus on the move line is an
integer interval, so a monotone walk never leaves it — a reusable bridge lemma.
-/

namespace MarkovBases.NoThreeWay

/-- A `2 × 2 × 2` integer contingency table. -/
abbrev Table3 := Fin 2 → Fin 2 → Fin 2 → ℤ

/-- The `(i,j)` two-way margin (sum over the third index `k`). -/
def m12 (u : Table3) (i j : Fin 2) : ℤ := u i j 0 + u i j 1
/-- The `(i,k)` two-way margin (sum over the second index `j`). -/
def m13 (u : Table3) (i k : Fin 2) : ℤ := u i 0 k + u i 1 k
/-- The `(j,k)` two-way margin (sum over the first index `i`). -/
def m23 (u : Table3) (j k : Fin 2) : ℤ := u 0 j k + u 1 j k

/-- Two tables lie in the same fiber of the no-three-way interaction model iff **all three**
families of two-dimensional margins agree. -/
def SameMargins (u v : Table3) : Prop :=
  (∀ i j, m12 u i j = m12 v i j) ∧
  (∀ i k, m13 u i k = m13 v i k) ∧
  (∀ j k, m23 u j k = m23 v j k)

/-- The degree-4 alternating Markov move `m(i,j,k) = (-1)^(i+j+k)`. -/
def M3 : Table3 := fun i j k => if (i.val + j.val + k.val) % 2 = 0 then 1 else -1

/-- The move `M3` takes only the values `±1`. -/
theorem M3_apply_eq (i j k : Fin 2) : M3 i j k = 1 ∨ M3 i j k = -1 := by
  unfold M3
  split <;> simp

-- !-- Lab Notebook: noThreeWay_move_preserves_margins -- !--
-- !-- Hypothesis: the alternating move M3 has all two-way margins zero, so it is a legal move -- !--
-- !-- Result: proved by 2-case splits on the two free indices then simp+ring on the ±1 values -- !--
-- !-- Insight: every line of M3 (fix two coords, vary one) sums to +1 + (-1) = 0 -- !--
-- !-- Failure analysis: keeping margins as explicit two-term sums (not Finset.sum) keeps the
--     goals decidable by simp/ring after the `if` in M3 reduces on concrete indices -- !--
-- !-- End Lab Notebook -- !--

-- !-- noThreeWay_move_preserves_margins: every line sum of M3 is +1-1=0, so adding a multiple
-- of M3 changes no two-way margin; M3 lies in the kernel of the margin map. -- !--
/-- Adding any integer multiple of `M3` preserves all three families of two-way margins:
`M3` lies in the kernel of the two-way margin map. -/
theorem noThreeWay_move_preserves_margins (u : Table3) (t : ℤ) :
    SameMargins u (u + t • M3) := by
  refine ⟨?_, ?_, ?_⟩ <;> intro a b <;> fin_cases a <;> fin_cases b <;>
    simp only [m12, m13, m23, M3, Pi.add_apply, Pi.smul_apply, smul_eq_mul, Fin.isValue] <;>
    norm_num <;> ring

-- !-- Lab Notebook: noThreeWay_kernel -- !--
-- !-- Hypothesis: despite 8 cells and 12 margin equations the move lattice is rank one (gen by M3) -- !--
-- !-- Result: proved any equal-margin pair differs by exactly (v000 - u000) • M3 -- !--
-- !-- Insight: zero two-way margins force w(i,j,k) = (-1)^(i+j+k) · w(0,0,0) by propagating sign flips -- !--
-- !-- Failure analysis: funext + fin_cases over all 3 indices gives 8 scalar goals; all twelve
--     margin equations must be instantiated as hypotheses before omega closes each cell -- !--
-- !-- End Lab Notebook -- !--

-- !-- noThreeWay_kernel: zero two-way margins propagate sign flips through all 8 cells, forcing
-- the difference to be the single multiple (v000 - u000) • M3 — so {M3} is the Markov basis. -- !--
/-- **Rank-one move lattice = the Markov basis.** If `u` and `v` have the same two-way
margins then their difference is the single integer multiple `(v 0 0 0 - u 0 0 0) • M3`.
Hence the singleton `{M3}` generates the whole move lattice of the no-three-way interaction
model: it is *the* Markov basis. -/
theorem noThreeWay_kernel (u v : Table3) (h : SameMargins u v) :
    v = u + (v 0 0 0 - u 0 0 0) • M3 := by
  obtain ⟨h12, h13, h23⟩ := h
  simp only [m12, m13, m23] at h12 h13 h23
  have a00 := h12 0 0; have a01 := h12 0 1; have a10 := h12 1 0; have a11 := h12 1 1
  have b00 := h13 0 0; have b01 := h13 0 1; have b10 := h13 1 0; have b11 := h13 1 1
  have c00 := h23 0 0; have c01 := h23 0 1; have c10 := h23 1 0; have c11 := h23 1 1
  funext i j k
  fin_cases i <;> fin_cases j <;> fin_cases k <;>
    simp only [M3, Pi.add_apply, Pi.smul_apply, smul_eq_mul, Fin.isValue] <;>
    norm_num <;> omega

/-- Non-negativity of a table (membership in a fiber requires non-negative counts). -/
def Nonneg (u : Table3) : Prop := ∀ i j k, 0 ≤ u i j k

/-- A single legal Markov step: move by `± M3`, staying non-negative at both ends. -/
def Step (u v : Table3) : Prop :=
  Nonneg u ∧ Nonneg v ∧ (v = u + M3 ∨ v = u - M3)

/-- `Connected u v`: there is a walk of legal `± M3` steps from `u` to `v`. -/
def Connected (u v : Table3) : Prop := Relation.ReflTransGen Step u v

/-- Pointwise evaluation of `u + t • M3`. -/
theorem add_smul_M3_apply (u : Table3) (t : ℤ) (i j k : Fin 2) :
    (u + t • M3) i j k = u i j k + t * M3 i j k := by
  simp [Pi.add_apply]

-- !-- Lab Notebook: connected_add_smul -- !--
-- !-- Hypothesis: along the move line the non-negative locus is an integer interval, so a
--     monotone walk of unit steps from u to u + t•M3 never leaves it -- !--
-- !-- Result: proved by induction on n = t.natAbs; one unit step toward the target stays non-negative -- !--
-- !-- Insight: if a cell has M3 = -1 and the far endpoint is ≥ 0 then the near value is ≥ |t| ≥ 1,
--     so subtracting 1 keeps it ≥ 0 (discrete convexity) -- !--
-- !-- Failure analysis: inducting on n = t.natAbs (not on t) gives a clean Nat recursion; the
--     sign split t > 0 / t < 0 chooses the +M3 or -M3 first step -- !--
-- !-- End Lab Notebook -- !--

-- !-- connected_add_smul: induct on |t|; take one unit step (±M3) toward the target, which the
-- discrete-convexity bound keeps non-negative, then recurse on |t|-1. -- !--
/-- Key induction: if both `u` and `u + t • M3` are non-negative then they are connected by
a monotone walk of `± M3` steps.  Proof by induction on `n = t.natAbs`. -/
theorem c
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — Chromatic Polynomial Synthesis Cycle

## Synthesis

This cycle closed the central open `sorry` of the catalog's chromatic-polynomial
package: the **fundamental evaluation theorem**
`SimpleGraph.eval_chromaticPolynomial` in
`Catalog/Speculative/ChromaticPolynomial/Defs.lean`. The proof is a self-contained
inclusion–exclusion over edge subsets (the Whitney rank formula): for each edge
subset `A`, the value `k^{c(A)}` counts functions constant on the connected
components of the spanning subgraph `(V, A)`; swapping the order of summation and
collapsing the alternating sum over the powerset of the edge set with
`Finset.prod_add` sifts out exactly the proper colourings.

On top of that single theorem we built a coherent, `sorry`-free corollary layer
in `Catalog/Speculative/ChromaticPolynomial/Corollaries.lean`:

* `numColorings_eq_eval` — the colour count *is* the polynomial evaluation;
* `chromaticPolynomial_eval_nonneg` — evaluations at naturals are `≥ 0`;
* `exists_polynomial_numColorings` — `k ↦ numColorings k` is the restriction of a
  single integer polynomial (polynomiality of the count);
* `colorable_iff_eval_pos` — graph colourability is equivalent to `χ_G(k) > 0`,
  turning a *search* problem into an *evaluation* problem;
* `numColorings_eq_of_chromaticPolynomial_eq` — chromatically equivalent graphs
  agree on colour counts at every `k`.

All five depend only on `propext`, `Classical.choice`, and `Quot.sound`.

## Results Summary

| Theorem | File | Status |
|---|---|---|
| `eval_chromaticPolynomial` | `ChromaticPolynomial/Defs.lean` | proved (was `sorry`) |
| `numColorings_eq_eval` | `ChromaticPolynomial/Corollaries.lean` | proved |
| `chromaticPolynomial_eval_nonneg` | `ChromaticPolynomial/Corollaries.lean` | proved |
| `exists_polynomial_numColorings` | `ChromaticPolynomial/Corollaries.lean` | proved |
| `colorable_iff_eval_pos` | `ChromaticPolynomial/Corollaries.lean` | proved |
| `numColorings_eq_of_chromaticPolynomial_eq` | `ChromaticPolynomial/Corollaries.lean` | proved |

Infrastructure fix: the package `srcDir` was set to `Catalog` in `lakefile.toml`
so the library globs resolve to the actual source tree.

## Research Directions

### 1. Deletion–contraction recurrence for `chromaticPolynomial`

The next structural theorem the package needs is the deletion–contraction law:
for an edge `e = s(u,v)` of `G`,
`χ_G = χ_{G \ e} - χ_{G / e}` as integer polynomials. This is the recurrence that
makes chromatic polynomials *computable* and that powers most downstream theory
(Tutte polynomial specialisations, broken-circuit theorems).
**The key insight is** that deletion–contraction is the polynomial shadow of a
bijective partition of proper colourings of `G \ e` into those that already
properly colour `G` and those that identify `u` with `v` (hence colour `G / e`);
combined with `eval_chromaticPolynomial` it reduces to a *finite identity at every
`k`*, and two integer polynomials agreeing on all of `ℕ` are equal. This is

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
