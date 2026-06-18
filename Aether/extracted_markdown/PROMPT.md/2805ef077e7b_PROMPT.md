
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

**Title**: The file `IntersectionForms.lean` formalizes the algebraic core of four-dimensio
**Domain**: Applications
**Mathematical framing**: # Future Directions: Intersection Forms and the Smooth 4D Poincaré Frontier

The file `IntersectionForms.lean` formalizes the algebraic core of four-dimensional
gauge theory: symmetric integral intersection forms, their unimodularity (Poincaré
duality), evenness (spin), and standard diagonalizability (Donaldson's conclusion).
Its headline result, `even_not_stdDiagonalizable`, is the algebraic mechanism that
forbids even definite forms on smooth 4-manifolds, instantiated by the `E8` form
(`E8_not_stdDiagonalizable`). The following research directions extend this nucleus
toward a genuinely useful Lean theory of 4-manifold invariants. Each is concrete,
testable, and falsifiable: a precise Lean statement that either compiles or does not.

## 1. The 8-divisibility theorem for even unimodular definite forms

**Conjecture.** Every positive-definite *even* unimodular symmetric integral form has
rank divisible by `8`. In Lean: if `Q : IntersectionForm n` is `Unimodular`, `IsEven`,
and positive-definite (a `PosDef` predicate to be added: `∀ v ≠ 0, 0 < Q.value v`),
then `8 ∣ n`.

The key insight is that evenness plus unimodularity force the form, over `ℝ`, to embed
in the even unimodular lattice tower whose signature is constrained mod 8 by the
`E8`/Milnor classification; the rank `8` of our explicit `E8form` is the minimal
witness, so the obstruction `even_not_stdDiagonalizable` is really the `n < 8` shadow
of a `mod 8` law. Why now? We already have a fully verified even unimodular definite
form of rank `8` (`E8form`, `E8_even`, `E8_unimodular`), so the base case and the
sharpness example are in hand — only the modular bookkeeping remains, and Mathlib's
quadratic-form and lattice libraries have matured enough to host it.

## 2. A formal van der Blij / signature-mod-8 invariant

**Conjecture.** For any unimodular `Q : IntersectionForm n` there is an integer vector
`c` (a *characteristic element*, `Q.value v ≡ c ⬝ᵥ v (mod 2)` for all `v`) and the
quantity `Q.value c` is congruent to the signature of `Q` modulo `8`; for *even* forms
one may take `c = 0`, giving `signature ≡ 0 (mod 8)`.

The key insight is that the characteristic element packages the obstruction
`even_not_stdDiagonalizable` into a single `ℤ/8`-valued invariant: oddness of the
diagonal in the standard form is exactly the statement that `c ≠ 0`, and van der Blij's
lemma turns this parity datum into a signature congruence. Why now? Our `value` and
`IsEven` predicates already isolate the parity pairing `Q.value v mod 2`; defining a
`signature` for diagonalizable forms and proving the congruence on the diagonal case is
a self-contained next step that reuses `value_basisChange` verbatim.

## 3. Connected-sum additivity and a stable cancellation law

**Conjecture.** Define the block-diagonal direct sum `Q ⊕ R` of intersection forms
(modeling the connected sum `M # N`). Then `Unimodular` and `IsEven` are each closed
under `⊕`, signatures add, and a *stable* form of Donaldson holds: if `Q ⊕ ⟨1⟩^k` is
standard-diagonalizable for some `k`, then so is `Q` — i.e. adding `ℂP²` summands cannot
"smooth away" the `E8` obstruction.

The key insight is that the obstruction in `even_not_stdDiagonalizable` is detected by a
single odd diagonal value, which survives orthogonal summation; thus the smooth/topological
gap is *stable*, mirroring Wall's theorem that 4-manifolds become diffeomorphic after
connected-summing with enough copies of `S²×S²`. Why now? The structure `IntersectionForm`
is parametric in `n`, and Mathlib's `Matrix.fromBlocks`/`reindex` API makes the direct sum
definable today; additivity proofs are pure block-matrix algebra of the kind already
exercised in `value_basisChange`.

## 4. Rokhlin's theorem as a `ℤ/16` obstruction, abstractly

**Conjecture.** Introduce a `Smoothable` predicate on intersection forms abstracting the
Donaldson and Rokhlin inputs as hypotheses (not axioms): a `Smoothable` even form has
signature divisible by `16`. Conclude that `E8form ⊕ E8form` (signature `16`, even,
unimodular, rank `16`) is the *smallest* even unimodular form that clears the Rokhlin
hurdle yet still fails Donaldson — pinpointing exactly where the two obstructions diverge.

The key insight is that `E8` fails Donaldson (rank `8`, our `E8_not_stdDiagonalizable`)
while `E8 ⊕ E8` passes Rokhlin (signature `16`) but is realized smoothly only as the
indefinite `K3` form after sign change — so the two obstructions, one analytic and one
characteristic-class, are genuinely independent and must be tracked separately. Why now?
With `E8form` in hand, `E8form ⊕ E8form` is one direct sum away (Direction 3), and the
`Smoothable`-as-hypothesis pattern keeps everything axiom-free while still proving a
sharp comparison.

## 5. A homotopy-`S⁴` certificate: forms cannot detect exotic structure

**Conjecture.** Formalize a `HomotopySphere4` record carrying `b₂ = 0` (equivalently an
`IntersectionForm 0`) and prove that *every* such object has the trivial form
`sphereForm`, hence is indistinguishable from the standard `S⁴` by any intersection-form
invariant — a precise statement of *why* the smooth 4D Poincaré conjecture is invisible
to this entire toolkit.

The key insight is that `sphere_intersection_trivial` already shows the rank-`0` form is
unimodular, even, and standard, so the intersection form is a *complete invariant of the
empty kind*: it collapses all homotopy-`S⁴` candidates to one point, proving a sharp
*negative* metatheorem that the conjecture demands genuinely smooth (gauge-theoretic /
Seiberg–Witten) input beyond algebra. Why now? The rank-`0` boundary case is fully
proved, so the remaining work is purely definitional packaging plus a one-line transport,
making this the most immediately reachable — and conceptually clarifying — direction.

Research domain: Applications
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Applications/SmoothPoincare/DirectSum.lean
/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Orthogonal (connected-sum) direct sums of intersection forms

This file extends `IntersectionForms.lean` with the **orthogonal direct sum**
`Q ⊕ R` of intersection forms, the algebraic model of the connected sum `M # N`
of 4-manifolds (whose intersection form is the orthogonal sum of the summands').

We prove that the three structural predicates of the theory are *closed* under `⊕`:

* `directSum_unimodular` — unimodularity (Poincaré duality) is additive;
* `directSum_isEven`     — evenness (spin) is additive;
* `directSum_stdDiagonalizable` — the standard form `⟨1⟩ⁿ` is closed under `⊕`.

The headline application is the rank-`16` form `E8form ⊕ E8form`: it is even,
unimodular, and **not** standard-diagonalizable (`E8E8_not_stdDiagonalizable`).
This is the smallest even unimodular form of signature `16`; it clears Rokhlin's
`ℤ/16` signature hurdle yet still fails Donaldson's diagonalization, pinpointing
where the analytic and characteristic-class obstructions diverge.

Builds on: `SmoothPoincare.IntersectionForm` and `even_not_stdDiagonalizable`,
`isEven_of_even_diag`, `E8form`, `E8_even`, `E8_unimodular` from `IntersectionForms`.

-- !-- Lab Notebook -- !--
Hypothesis: the predicates `Unimodular`, `IsEven`, `StdDiagonalizable` should be
  monoidal under the orthogonal block-diagonal sum, so the `E8` obstruction is
  *stable* under connected sum with itself.
Result: all three closure theorems proved `sorry`-free, plus the sharp corollary
  `E8E8_not_stdDiagonalizable` for the rank-16 signature-16 form.
Insight: evenness is governed entirely by the *diagonal* (`isEven_of_even_diag`
  and its converse `even_diag_of_isEven`), so it is transparently additive; the
  obstruction `even_not_stdDiagonalizable` then transfers verbatim to any sum of
  even forms, giving the stable comparison E8 (fails Donaldson) vs E8⊕E8 (passes
  Rokhlin, still fails Donaldson).
Failure analysis: the `Fin (m+n)` vs `Fin m ⊕ Fin n` indexing requires reindexing
  through `finSumFinEquiv`; the clean route is `submatrix_mul_equiv` /
  `transpose_submatrix` / `submatrix_one_equiv`, avoiding any explicit index
  arithmetic.
-/

import Mathlib
import Catalog.Applications.SmoothPoincare.IntersectionForms

open Matrix
open scoped BigOperators

noncomputable section

namespace SmoothPoincare

namespace IntersectionForm

variable {m n : ℕ}

/-- The reindexing equivalence `Fin m ⊕ Fin n ≃ Fin (m + n)`. -/
abbrev sumEquiv (m n : ℕ) : Fin m ⊕ Fin n ≃ Fin (m + n) := finSumFinEquiv

-- !-- The diagonal computes the quadratic value on a basis vector,
-- `Q.value (single i 1) = Q.gram i i`, so evenness forces each diagonal entry even. -- !--
/-- The converse of `isEven_of_even_diag`: an even form has even diagonal entries. -/
theorem even_diag_of_isEven {Q : IntersectionForm n} (hQ : Q.IsEven) (i : Fin n) :
    Even (Q.gram i i) := by
  have := hQ (fun j => if j = i then 1 else 0)
  simp_all +decide [IntersectionForm.value]
  simp_all +decide [Matrix.mulVec, dotProduct]

-- !-- `fromBlocks` of two symmetric blocks with zero off-diagonal is symmetric
-- (`fromBlocks_transpose`), and `reindex e e` preserves symmetry. -- !--
/-- The reindexed block-diagonal of two symmetric matrices is symmetric. -/
theorem reindex_fromBlocks_diag_isSymm {Q : IntersectionForm m} {R : IntersectionForm n} :
    (reindex (sumEquiv m n) (sumEquiv m n) (fromBlocks Q.gram 0 0 R.gram)).IsSymm := by
  simp_all +decide [Matrix.IsSymm, Matrix.reindex_apply]
  ext i j
  simp +decide [Matrix.fromBlocks_transpose]
  simp +decide [Q.isSymm.eq, R.isSymm.eq, sumEquiv]

/-- **Orthogonal direct sum** of intersection forms, the algebraic connected sum.
Its Gram matrix is the block-diagonal `diag(G_Q, G_R)` reindexed to `Fin (m+n)`. -/
def directSum (Q : IntersectionForm m) (R : IntersectionForm n) :
    IntersectionForm (m + n) where
  gram := reindex (sumEquiv m n) (sumEquiv m n) (fromBlocks Q.gram 0 0 R.gram)
  isSymm := reindex_fromBlocks_diag_isSymm

@[inherit_doc] infixl:65 " ⊕ᵢ " => directSum

-- !-- `det (reindex e e (fromBlocks G 0 0 H)) = det G · det H` by `det_reindex_self`
-- and `det_fromBlocks_zero₁₂`; a product of units is a unit. -- !--
/-- **Unimodularity is additive.** `Q ⊕ R` is unimodular when its blocks are. -/
theorem directSum_unimodular {Q : IntersectionForm m} {R : IntersectionForm n}
    (hQ : Q.Unimodular) (hR : R.Unimodular) : (Q ⊕ᵢ R).Unimodular := by
  unfold IntersectionForm.Unimodular at *
  unfold IntersectionForm.directSum
  rw [Matrix.det_reindex_self]
  aesop

-- !-- The diagonal of the block-diagonal sum consists of the diagonals of `Q` and
-- `R`, each even by `even_diag_of_isEven`; apply `isEven_of_even_diag`. -- !--
/-- **Evenness is additive.** The orthogonal sum of two even forms is even. -/
theorem directSum_isEven {Q : IntersectionForm m} {R : IntersectionForm n}
    (hQ : Q.IsEven) (hR : R.IsEven) : (Q ⊕ᵢ R).IsEven := by
  apply isEven_of_even_diag
  intro i
  simp [IntersectionForm.directSum]
  cases h : (sumEquiv m n).symm i <;> simp_all +decide [even_diag_of_isEven]

-- !-- With `T₁ᵀG_QT₁ = 1` and `T₂ᵀG_RT₂ = 1`, the block-diagonal `T = diag(T₁,T₂)`
-- gives `TᵀG T = reindex (fromBlocks 1 0 0 1) = 1` via `fromBlocks_multiply`,
-- `fromBlocks_transpose`, and `submatrix`/`reindex` lemmas. -- !--
/-- **The standard form is closed under `⊕`.** A sum of standard-diagonalizable
forms is standard-diagonalizable. -/
theorem directSum_stdDiagonalizable {Q : IntersectionForm m} {R : IntersectionForm n}
    (hQ : Q.StdDiagonalizable) (hR : R.StdDiagonalizable) :
    (Q ⊕ᵢ R).StdDiagonalizable := by
  obtain ⟨T₁, hT₁⟩ := hQ
  obtain ⟨T₂, hT₂⟩ := hR
  refine ⟨Matrix.reindex (sumEquiv m n) (sumEquiv m n) (Matrix.fromBlocks T₁ 0 0 T₂), ?_, ?_⟩
  · simp_all +decide [Matrix.reindex_apply]
  · unfold IntersectionForm.directSum
    simp +decide [Matrix.fromBlocks_transpose, Matrix.fromBlocks_multiply, hT₁.2, hT₂.2]

/-! ## The rank-16 form `E8 ⊕ E8` -/

/-- The orthogonal sum `E8 ⊕ E8`: even, unimodular, rank `16`, signature `16`. -/
def E8E8form : IntersectionForm (8 + 8) := E8form ⊕ᵢ E8form

/-- `E8 ⊕ E8` is even. -/
theorem E8E8_even : E8E8form.IsEven := directSum_isEven E8_even E8_even

/-- `E8 ⊕ E8` is unimodular. -/
theorem E8E8_unimodular : E8E8form.Unimodular :=
  directSum_unimodular E8_unimodular E8_unimodular

-- !-- `E8 ⊕ E8` is even of positive rank, so `even_not_stdDiagonalizable` applies:
-- adding an `E8` summand (to clear Rokhlin's signature-16 hurdle) does not remove
-- Donaldson's evenness obstruction. -- !--
/-- **Stable obstruction.** `E8 ⊕ E8` — the smallest even unimodular form clearing
Rokhlin's signature-`16` hurdle — is still not standard-diagonalizable, so it is not
the intersection form of any smooth closed simply-connected 4-manifold. -/
theorem E8E8_not_stdDiagonalizable : ¬ E8E8form.StdDiagonalizable :=
  even_not_stdDiagonalizable E8E8form (by norm_num) E8E8_even

end IntersectionForm

end SmoothPoincare



-- NEW_FILE: Catalog/Applications/SmoothPoincare/HomotopySphere.lean
/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Homotopy 4-spheres and the blindness of intersection forms

A *homotopy 4-sphere* is a smooth closed simply-connected 4-manifold homotopy
equivalent to `S⁴`.  By Poincaré duality its second Betti number `b₂` vanishes, so
its intersection form lives on a rank-`0` lattice — it is an `IntersectionForm 0`.

This file proves a sharp **negative metatheorem**: the intersection form is a
*complete invariant of the empty kind* on homotopy 4-spheres.  Every rank-`0` form
is *equal* to the standard `sphereForm` (`intersectionForm_zero_unique`), so the
intersection form collapses all homotopy-`S⁴` candidates to a single point and can
never distinguish an exotic smooth structure from the standard `S⁴`
(`homotopySphere_form_indistinguishable`).  This is precisely *why* the 
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: Intersection Forms and the Smooth 4D Poincaré Frontier

## Synthesis

The `SmoothPoincare` nucleus now contains three layers. `IntersectionForms.lean`
fixes the algebraic vocabulary — symmetric integral Gram matrices with the predicates
`Unimodular` (Poincaré duality), `IsEven` (spin), `StdDiagonalizable` (Donaldson's
conclusion) — and proves the obstruction `even_not_stdDiagonalizable`, instantiated by
the rank-`8` `E8form`. This cycle added two structural extensions:

* **`DirectSum.lean`** makes the orthogonal sum `⊕ᵢ` (the algebraic connected sum
  `M # N`) a first-class operation and proves that all three predicates are *closed*
  under it (`directSum_unimodular`, `directSum_isEven`, `directSum_stdDiagonalizable`).
  The decisive corollary `E8E8_not_stdDiagonalizable` shows the obstruction is
  **stable**: the rank-`16`, signature-`16` form `E8 ⊕ E8` clears Rokhlin's hurdle yet
  still fails Donaldson. The single odd diagonal value that detects the obstruction
  survives orthogonal summation, so connected sums cannot smooth it away.

* **`HomotopySphere.lean`** proves a sharp *negative metatheorem*: every rank-`0`
  intersection form equals `sphereForm` (`intersectionForm_zero_unique`), so the
  intersection form is constant on homotopy 4-spheres
  (`HomotopySphere4.form_indistinguishable`). The toolkit is provably blind to exotic
  smooth structure on `S⁴` — which is exactly why the smooth 4D Poincaré conjecture
  requires genuinely smooth (gauge-theoretic / Seiberg–Witten) input.

Together these isolate *where* algebra stops and analysis must begin: the additive
structure (`⊕ᵢ`) carries every algebraic invariant faithfully, the obstruction is
stable under it, and on the rank-`0` boundary the algebra collapses entirely.

## Results Summary

| Theorem | Statement | Status |
|---|---|---|
| `even_diag_of_isEven` | even form ⇒ even diagonal (converse of `isEven_of_even_diag`) | proved |
| `reindex_fromBlocks_diag_isSymm` | reindexed block-diagonal of symmetric blocks is symmetric | proved |
| `directSum_unimodular` | `Unimodular` closed under `⊕ᵢ` | proved |
| `directSum_isEven` | `IsEven` closed under `⊕ᵢ` | proved |
| `directSum_stdDiagonalizable` | `StdDiagonalizable` closed under `⊕ᵢ` | proved |
| `E8E8_even`, `E8E8_unimodular` | `E8 ⊕ E8` is even and unimodular | proved |
| `E8E8_not_stdDiagonalizable` | `E8 ⊕ E8` (signature 16) still fails Donaldson | proved |
| `intersectionForm_zero_unique` | every rank-0 form equals `sphereForm` | proved |
| `HomotopySphere4.form_indistinguishable` | intersection form constant on homotopy 4-spheres | proved |

All results are `sorry`-free and depend only on `propext`, `Classical.choice`,
`Quot.sound`.

## Direction 1 — A formal `signature` and the van der Blij congruence

**Conjecture.** Equip diagonalizable forms with an integer `signature` (number of
positive minus negative diagonal entries after an `ℝ`-diagonalization) that is *additive*
under `⊕ᵢ`: `signature (Q ⊕ᵢ R) = signat
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
