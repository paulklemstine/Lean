
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

**Title**: The catalog's `SmoothPoincare` files develop the *lattice* side of the smooth /
**Domain**: Applications
**Mathematical framing**: # Future Directions — Topological Error-Correcting Codes from Exotic Smooth Structures

## Synthesis

The catalog's `SmoothPoincare` files develop the *lattice* side of the smooth /
topological gap in dimension 4: the even unimodular intersection form `E8`
(`E8form`, `E8_even`, `E8_unimodular`), its closure under orthogonal direct sum
(`directSum_isEven`, `directSum_unimodular`, `E8E8_not_stdDiagonalizable`), and the
Donaldson obstruction `even_not_stdDiagonalizable`. The recurring miracle there is the
integer **8**: positive-definite even unimodular lattices exist only in rank divisible
by 8, with `E8` the minimal witness.

This cycle opened the *coding-theory shadow* of that story in
`Catalog/Applications/SmoothPoincare/TopologicalCodes.lean`. Via Construction A (the
reduction of an even unimodular lattice modulo 2), evenness of a form becomes the
**doubly-even** condition on a binary code (all weights divisible by 4), and unimodular
self-duality becomes **self-orthogonality**. We proved, `sorry`-free:

- `wt_add_overlap`: the additive inclusion–exclusion identity
  `wt(x+y) + 2·overlap(x,y) = wt x + wt y`, the combinatorial engine.
- `doublyEven_selfOrthogonal`: **the bridge theorem** — any two doubly-even codewords
  whose sum is doubly even are orthogonal. This is the exact binary mirror of
  "an even form has even diagonal" (`even_diag_of_isEven` / `isEven_of_even_diag`):
  double-evenness *forces* self-orthogonality, just as form-evenness forces the
  Donaldson obstruction.
- The explicit extended Hamming code `[8,4,4] = RM(1,3)` as the mod-2 shadow of `E8`:
  `hamming_card` (16 words), `hamming_add_closed` (linearity), `hamming_doublyEven`
  (analogue of `E8_even`), `hamming_length_div_four` (the all-ones word, weight 8), and
  `hamming_selfOrthogonal` — derived from double-evenness through the bridge theorem
  *without* any pairwise brute force, mirroring how `E8`'s obstruction is derived from
  `E8_even`.

## Results Summary

| Theorem | Role | Lattice-side analogue |
|---|---|---|
| `wt_add_overlap` | weight inclusion–exclusion | symmetric bilinear expansion |
| `ip_eq_overlap` | inner product = overlap parity | Gram pairing mod 2 |
| `doublyEven_selfOrthogonal` | doubly-even ⟹ self-orthogonal | `even_diag_of_isEven` |
| `hamming_doublyEven` | code is doubly even | `E8_even` |
| `hamming_selfOrthogonal` | code is self-orthogonal | `E8` unimodular self-duality |
| `hamming_length_div_four` | all-ones word, weight 8 | signature divisibility (Rokhlin) |

All proofs reduce either to the single arithmetic identity `wt_add_overlap` or to a
`native_decide` on the concrete 16-element generator image.

## Research Directions

### 1. The Gleason "length divisible by 8" theorem for doubly-even self-dual codes
We proved doubly-even self-dual codes force length divisible by **4** (the all-ones word
has weight a multiple of 4). The sharp classical statement is **divisibility by 8** — the
exact code-theoretic twin of "even unimodular definite lattices have rank divisible by 8"
(`E8` minimal). A falsifiable target: formalize that every doubly-even self-dual binary
code has length `≡ 0 (mod 8)`, and that 8 is attained only by the extended Hamming code up
to equivalence. **The key insight is** that the weight enumerator of such a code is fixed
by the order-8 Gleason–MacWilliams transformation group, whose polynomial invariant ring
is generated in degrees 8 and 24 — forcing `8 ∣ n` purely algebraically, with no analysis.
**Why now?** Our `wt_add_overlap` + `doublyEven_selfOrthogonal` already give the mod-4 step
`sorry`-free; the remaining mod-8 jump is a self-contained generating-function identity in
`ℤ[x,y]` that Mathlib's polynomial and `MvPolynomial` invariant-theory API can now carry.

### 2. Construction A as a verified functor: lattices ⇄ codes
Make the analogy a theorem, not a metaphor: build the map `C ↦ Λ_C = {v ∈ ℤⁿ : v mod 2 ∈ C}`
and prove `C` doubly-even self-dual ⟺ `Λ_C` even unimodular, then exhibit `E8form` (the
catalog object) as `Λ_Hamming` explicitly. **The key insight is** that the Gram matrix
`E8mat` (already `decide`-verified even and unimodular in `IntersectionForms.lean`) is, up
to integral congruence, `½·(2·I + reduction-of-Hamming-generators)`, so the lattice and
code obstructions are literally the same `mod 2` computation. **Why now?** Both endpoints
already exist `sorry`-free in this project (`E8form`, `E8_unimodular`, `hamming`); only the
single congruence bridge is missing, and it is a finite `decide`-able matrix identity.

### 3. Minimum distance and the "exotic = correcting" dictionary
Define minimum distance `d(C)` and prove `d(Hamming) = 4`, then state the singular
conjecture driving the whole concept title: the **smooth-structure-distinguishing power** of
a lattice equals the **error-correcting power** of its mod-2 code, i.e. inequivalent even
unimodular lattices of equal rank/discriminant produce codes of strictly different minimum
distance. **The key insight is** that exotic smooth structure on a 4-manifold is detected by
the *fine* arithmetic of the intersection lattice (not just its genus), and that arithmetic
survives reduction mod 2 precisely as the code's distance spectrum. **Why now?** With
`wt` and `hamming` already in place, `d(C)` is a one-line `Finset.min'` definition and the
distance-4 fact is `native_decide`; the conjecture then becomes a sharp, falsifiable
statement testable on the rank-16 pair `E8⊕E8` vs `D16⁺` (the first lattices where the genus
fails to separate but the codes might).

### 4. The signature/syndrome correspondence and a topological decoder
Rokhlin's theorem says a smooth spin 4-manifold has signature divisible by 16; the code
shadow is that the syndrome map of a doubly-even self-dual code is `ℤ/2`-valued with a
distinguished quadratic refinement. Conjecture: the Brown–Arf invariant of the code's
quadratic form computes the signature `mod 16` of the associated lattice/manifold, giving a
*combinatorial decoder* for the smooth signature obstruction. **The key insight is** that the
Arf invariant of the mod-2 quadratic enhancement is exactly the `mod 16` content Rokhlin
extracts analytically, so a purely finite syndrome computation reproduces a gauge-theoretic
divisibility. **Why now?** `doublyEven_selfOrthogonal` supplies the quadratic refinement's
self-orthogonality hypothesis for free, and Mathlib's `ZMod` / quadratic-form API makes the
Arf invariant computable and `decide`-checkable on `hamming`.

### 5. Low-energy harmonic sectors as the weight-zero subspace (the original conjecture)
Return to the seed conjecture: homeomorphic-but-not-diffeomorphic manifolds support
inequivalent Laplace-type operators whose low-energy harmonic sectors differ. Model the
"harmonic sector" as the radical / minimum-weight subcode and conjecture that exotic pairs
yield codes with isomorphic ambient space but non-isometric minimum-weight subspaces.
**The key insight is** that the kernel of a discrete Laplacian on the lattice is graded by
weight, and the smallest nonzero stratum (weight = minimum distance) is the combinatorial
avatar of the lowest nonzero Laplace eigenspace — so "distinct harmonic sectors" becomes
"non-isometric minimum-weight subcodes". **Why now?** This reframes a hard analytic
conjecture as a finite linear-algebra statement already half-built here: `hamming`,
`hamming_doublyEven`, and `ip` give the graded pairing, and the minimum-weight stratum is
a decidable `Finset`, making the first nontrivial case (`E8`-Hamming vs a fake `E8`) an
immediately testable computation.

Research domain: Applications
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Applications/SmoothPoincare/MinimumDistance.lean
/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Minimum distance, the weight enumerator of `[8,4,4]`, and self-dual ⟹ even weights

Companion to `Catalog.Applications.SmoothPoincare.SelfDualLength`.  Where that file
extracts a *global length* invariant from the local bridge theorem, this file extracts
the *distance spectrum* — the combinatorial avatar of the "fine arithmetic" that
distinguishes smooth structures (catalog Research Direction 3).

Contents (all `sorry`-free):

* `selfDual_even_weight` — **general theorem**: in any binary *self-dual* code every
  codeword has *even* weight.  This is the unconditional companion of the doubly-even
  hypothesis used in `SelfDualLength`: `ip x x = (wt x mod 2)`, and self-duality makes
  `ip x x = 0`.  (Lattice shadow: a unimodular *even* form has even diagonal.)
* `hamming_minDist_lower` / `hamming_minDist_attained` — the **minimum distance is 4**:
  every nonzero codeword has weight `≥ 4`, and weight `4` is attained.  Together these
  pin the parameters `[n=8, k=4, d=4]` of the extended Hamming code.
* `hamming_weightEnum_0/4/8` — the **complete weight enumerator** `1 + 14·x⁴ + x⁸`:
  exactly `1` word of weight `0`, `14` of weight `4`, `1` of weight `8`, accounting for
  all `16` codewords.  This is the explicit MacWilliams-self-dual weight polynomial of
  the mod-2 shadow of `E8`.

-- !-- Lab Notebook -- !--
Hypothesis: the catalog's `hamming` code, being the mod-2 shadow of `E8`, should carry
  a sharp `[8,4,4]` distance spectrum whose weight enumerator is the order-8
  Gleason-invariant polynomial `1 + 14x⁴ + x⁸`; and self-duality alone (no double
  evenness) should already force even weights.
Result: `selfDual_even_weight` proved generally; the `[8,4,4]` parameters and the full
  weight enumerator `1 + 14x⁴ + x⁸` proved by `native_decide`, accounting for all 16
  codewords (`1 + 14 + 1 = 16`).
Insight: the diagonal pairing `ip x x` collapses to `wt x mod 2` because `t² = t` in
  `ZMod 2`; self-duality then *is* the statement that this diagonal vanishes — the exact
  code-side mirror of "even diagonal" on the lattice side.  The weight enumerator being
  supported only on `{0,4,8}` is the finite fingerprint that the next cycle should test
  against rank-16 lattice pairs (`E8⊕E8` vs `D16⁺`).
Failure analysis: `Finset.min'`/`inf'` definitions of minimum distance drag in
  nonemptiness side-goals; stating the spectrum as a lower bound + attainment pair sides
  steps this entirely and is strictly more informative.
-/

import Mathlib

open scoped BigOperators

namespace SmoothPoincare
namespace Codes

variable {n : ℕ}

/-! ## Core definitions (self-contained mirror of `TopologicalCodes`) -/

/-- **Hamming weight**: the number of nonzero coordinates of a binary vector. -/
def wt (v : Fin n → ZMod 2) : ℕ := (Finset.univ.filter (fun i => v i = 1)).card

/-- **Overlap**: the number of coordinates where both vectors equal `1`. -/
def overlap (x y : Fin n → ZMod 2) : ℕ :=
  (Finset.univ.filter (fun i => x i = 1 ∧ y i = 1)).card

/-- **Binary inner product** in `ZMod 2`. -/
def ip (x y : Fin n → ZMod 2) : ZMod 2 := ∑ i, x i * y i

/-
!-- A product `x_i · y_i` in `ZMod 2` is `1` iff both factors are `1`. -- !--

The binary inner product equals the parity of the overlap.
-/
theorem ip_eq_overlap (x y : Fin n → ZMod 2) :
    ip x y = (overlap x y : ZMod 2) := by
  unfold ip overlap
  rw [Finset.card_filter, Nat.cast_sum]
  exact Finset.sum_congr rfl fun i _ => by
    rcases x i with (_ | _ | x) <;> rcases y i with (_ | _ | y) <;> trivial

/-
!-- `overlap x x` filters coordinates with `x i = 1 ∧ x i = 1`, i.e. the support of
`x`, so it equals `wt x`. -- !--

The self-overlap is the weight.
-/
theorem overlap_self (x : Fin n → ZMod 2) : overlap x x = wt x := by
  unfold overlap wt
  congr 1
  apply Finset.filter_congr
  intro i _
  simp

/-
!-- Combine `ip_eq_overlap` with `overlap_self`. -- !--

The diagonal inner product is the parity of the weight.
-/
theorem ip_self (x : Fin n → ZMod 2) : ip x x = (wt x : ZMod 2) := by
  rw [ip_eq_overlap, overlap_self]

/-! ## General theorem: self-dual codes have even weights -/

/-
!-- For a self-dual code, `x ∈ C` is orthogonal to all of `C`, in particular to itself,
so `ip x x = 0`; but `ip x x = wt x mod 2`, hence `2 ∣ wt x`. -- !--

**In a self-dual binary code, every codeword has even weight.**  This is the
unconditional lattice-shadow of "a unimodular even form has even diagonal", and the
companion to the doubly-even hypothesis of `SelfDualLength`.
-/
theorem selfDual_even_weight
    (C : Finset (Fin n → ZMod 2))
    (hSD : ∀ x, x ∈ C ↔ ∀ y ∈ C, ip x y = 0)
    {x : Fin n → ZMod 2} (hx : x ∈ C) :
    2 ∣ wt x := by
  have hxx : ip x x = 0 := (hSD x).1 hx x hx
  rw [ip_self, ZMod.natCast_eq_zero_iff] at hxx
  exact hxx

/-! ## The extended Hamming code `[8,4,4]` -/

/-- Generator matrix of the extended Hamming code `RM(1,3)`. -/
def hammingGen : Fin 4 → Fin 8 → ZMod 2 :=
  ![ ![1,1,1,1,1,1,1,1],
     ![0,0,0,0,1,1,1,1],
     ![0,0,1,1,0,0,1,1],
     ![0,1,0,1,0,1,0,1] ]

/-- Encoding map: `a ↦ ∑ aᵢ · gen i`. -/
def encode (a : Fin 4 → ZMod 2) : Fin 8 → ZMod 2 := fun j => ∑ i, a i * hammingGen i j

/-- The **extended Hamming code** as the image of the encoder. -/
def hamming : Finset (Fin 8 → ZMod 2) := Finset.image encode Finset.univ

/-! ### Minimum distance is 4 -/

/-
!-- `native_decide`: every one of the 16 codewords other than `0` has weight `≥ 4`. -- !--

**Lower bound:** every nonzero Hamming codeword has weight at least `4`.
-/
theorem hamming_minDist_lower :
    ∀ v ∈ hamming, v ≠ 0 → 4 ≤ wt v := by
  native_decide

/-
!-- `native_decide`: e.g. the second generator row has weight exactly 4. -- !--

**Attainment:** there is a nonzero Hamming codeword of weight exactly `4`, so the
minimum distance equals `4` — the `d` in the parameter triple `[8,4,4]`.
-/
theorem hamming_minDist_attained :
    ∃ v ∈ hamming, v ≠ 0 ∧ wt v = 4 := by
  native_decide

/-! ### The complete weight enumerator `1 + 14·x⁴ + x⁸` -/

/-
!-- `native_decide`: only the zero word has weight `0`. -- !--
There is exactly `1` codeword of weight `0`.
-/
theorem hamming_weightEnum_0 :
    (hamming.filter (fun v => wt v = 0)).card = 1 := by
  native_decide

/-
!-- `native_decide`: the `14` "middle" codewords have weight `4`. -- !--
There are exactly `14` codewords of weight `4`.
-/
theorem hamming_weightEnum_4 :
    (hamming.filter (fun v => wt v = 4)).card = 14 := by
  native_decide

/-
!-- `native_decide`: only the all-ones word has weight `8`. -- !--
There is exactly `1` codeword of weight `8`.
-/
theorem hamming_weightEnum_8 :
    (hamming.filter (fun v => wt v = 8)).card = 1 := by
  native_decide

/-
!-- `1 + 14 + 1 = 16`: the three strata `{0,4,8}` exhaust all codewords. -- !--

**The weight enumerator accounts for every codeword:** the supports at weights
`0, 4, 8` sum to the full `16 = 2⁴`, confirming the enumerator `1 + 14x⁴ + x⁸` is
complete.
-/
theorem hamming_weightEnum_complete :
    (hamming.filter (fun v => wt v = 0)).card
      + (hamming.filter (fun v => wt v = 4)).card
      + (hamming.filter (fun v => wt v = 8)).card = 16 := by
  rw [hamming_weightEnum_0, hamming_weightEnum_4, hamming_weightEnum_8]

end Codes
end SmoothPoincare



-- NEW_FILE: Catalog/Applications/SmoothPoincare/SelfDualLength.lean
/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Self-dual doubly-even codes have length divisible by 4 (and the all-ones glue)

This file is the *local-to-global* sequel to
`Catalog.Applications.SmoothPoincare.TopologicalCodes`.  There, the headline
`doublyEven_selfOrthogonal` shows that double-evenness *forces* pairwise
orthogonality — the coding-theory shadow of "an even form has even diagonal"
(`SmoothPoincare.IntersectionForm.even_diag_of_isEven`).  Here we turn that *local*
(per-pair) datum into a *global* divisibility constraint on t
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — Topological Codes from Exotic Smooth Structures (Cycle 2)

## Synthesis

The previous cycle (`TopologicalCodes.lean`) established the *local* bridge of the
lattice ⇄ code dictionary: double-evenness forces pairwise orthogonality
(`doublyEven_selfOrthogonal`), the code-side mirror of "an even form has even diagonal"
(`IntersectionForms.even_diag_of_isEven`). It exhibited the extended Hamming code
`[8,4,4] = RM(1,3)` as the mod-2 shadow of `E8` and proved it doubly even and
self-orthogonal.

This cycle performs the **local-to-global** upgrade — the configured research core. A
*local* (per-pair, per-coordinate) weight datum is glued, through the canonical all-ones
"global section", into *global* numerical invariants of the whole code:

- **Global length divisibility** (`SelfDualLength.lean`). The theorem
  `selfDual_doublyEven_length_div_four` shows that *any* self-dual doubly-even binary
  code of length `n` has `4 ∣ n`, for arbitrary `n`. The proof is exactly a
  sheaf-style argument: the dual code is the presheaf of orthogonality conditions, the
  all-ones vector is the distinguished global section, and self-duality is the gluing
  axiom that forces its membership — whence `4 ∣ wt(𝟙) = n`. We then prove the
  extended Hamming code is *genuinely self-dual* (`hamming_selfDual`, by a finite
  `native_decide` over its `256`-point ambient space) and recover `4 ∣ 8` as a
  *corollary of the general theorem*, mirroring how `E8`'s obstruction is *derived*
  from `E8_even`.

- **Self-dual ⟹ even weights, unconditionally** (`MinimumDistance.lean`). The theorem
  `selfDual_even_weight` shows every codeword of a self-dual code has even weight,
  because `ip x x = wt x (mod 2)` (using `t² = t` in `ZMod 2`) and self-duality kills
  the diagonal. This is the unconditional companion of the doubly-even hypothesis and
  the code mirror of "a unimodular even form has even diagonal".

- **The distance spectrum** (`MinimumDistance.lean`). We pin the parameters `[8,4,4]`
  (`hamming_minDist_lower`, `hamming_minDist_attained`) and compute the **complete
  weight enumerator** `1 + 14·x⁴ + x⁸` (`hamming_weightEnum_0/4/8`,
  `hamming_weightEnum_complete`: `1 + 14 + 1 = 16`). This is the finite fingerprint the
  next cycle should test against rank-16 lattice pairs.

## Results Summary

| Theorem | Role | Lattice-side analogue |
|---|---|---|
| `selfDual_doublyEven_length_div_four` | **global** length `4 ∣ n` for any self-dual doubly-even code | rank divisible by `8` for even unimodular definite lattices |
| `ip_ones` / `overlap_ones` / `wt_ones` | all-ones global section machinery | distinguished lattice vectors |
| `hamming_selfDual` | Hamming code is self-dual | `E8` unimodular (Poincaré self-duality) |
| `hamming_length_div_four_general` | `4 ∣ 8` as a corollary, not by hand | obstruction derived from evenness |
| `selfDual_even_weight` | self-dual ⟹ even weights (unconditional) | unimodular even form has even diagonal |
| `hamming_minDist_lower/at
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
