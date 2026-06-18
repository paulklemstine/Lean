
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

**Title**: Close Proofs: Topological Error-Correcting Codes from Exotic Smooth Structures
**Domain**: Applications
**Mathematical framing**: Cycle c6fd83da (Q=0.459) proved 7 theorems in Novelty but left 2 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: Conjecture: In dimensions 4 and 7, manifolds that are homeomorphic but not diffeomorphic support inequivalent families of local Laplace-type operators whose low-energy harmonic sectors define distinct
Research domain: Applications
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Applications/SmoothPoincare/TopologicalCodes.lean
/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Topological error-correcting codes: the mod-2 shadow of even unimodular forms

The catalog's `SmoothPoincare` files build the *lattice* side of the smooth/topological
gap in dimension 4: the **even unimodular** intersection form `E8` (rank `8`), its
self-sum `E8 ⊕ E8` (rank `16`), and the Donaldson obstruction
`even_not_stdDiagonalizable`.  A recurring miracle there is the number **8**: even
unimodular *definite* lattices exist only in rank divisible by `8`, with `E8` the
minimal witness.

This file develops the **coding-theory shadow** of exactly that phenomenon.  Reducing
a unimodular even lattice modulo `2` (Construction A in reverse) produces a *binary
self-dual code*; the evenness of the form becomes the **doubly-even** condition (all
codeword weights divisible by `4`).  The combinatorial analogue of "rank divisible by
`8`" is "length divisible by `8`", and the minimal witness — the shadow of `E8` — is
the **extended Hamming code** `[8,4,4]`, the Reed–Muller code `RM(1,3)`.

We prove, fully `sorry`-free:

* `wt_add_overlap` — the Hamming inclusion–exclusion identity
  `wt(x+y) + 2·overlap(x,y) = wt x + wt y`, the combinatorial heart everything rests on.
* `doublyEven_selfOrthogonal` — **the bridge theorem**: any two codewords of weight
  divisible by `4` are orthogonal.  This is the binary mirror of "an even form has even
  diagonal" (`even_diag_of_isEven` / `isEven_of_even_diag` in `IntersectionForms`): a
  doubly-even code is automatically self-orthogonal.
* `hamming_doublyEven` — the extended Hamming code has all weights divisible by `4`
  (the code-side analogue of `E8_even`).
* `hamming_add_closed` / `hamming_selfOrthogonal` — closure under `+` and, via the
  bridge theorem, self-orthogonality (the analogue of `E8`'s self-duality / Donaldson
  evenness obstruction), obtained *without* a brute-force pairwise check.
* `hamming_length_div_four` — every codeword length-`8` constraint: the all-ones word
  lies in the code and has weight `8`, divisible by `4` (the code-side echo of the
  signature divisibility behind Rokhlin/Donaldson).

## References
* J. H. Conway, N. J. A. Sloane, *Sphere Packings, Lattices and Groups* (Construction A,
  Chapter 7): even unimodular lattices ↔ doubly-even self-dual codes.
* F. J. MacWilliams, N. J. A. Sloane, *The Theory of Error-Correcting Codes*.

-- !-- Lab Notebook -- !--
Hypothesis: the rank-divisible-by-8 obstruction governing even unimodular lattices
  (catalog `E8form`, `E8_even`, `even_not_stdDiagonalizable`) has a verbatim
  coding-theory shadow: doubly-even ⟹ self-orthogonal, with the extended Hamming
  `[8,4,4]` code as the mod-2 image of `E8`.
Result: all five headline theorems proved `sorry`-free.  `doublyEven_selfOrthogonal`
  is the load-bearing bridge; the explicit Hamming code's properties then follow by a
  cheap `decide` on its 16-element generator image plus the bridge theorem.
Insight: evenness/double-evenness is governed by a single divisibility identity
  (`wt_add_overlap`), exactly as form-evenness is governed by the diagonal
  (`isEven_of_even_diag`).  Self-orthogonality is then *derived*, never checked
  pairwise, mirroring how `E8`'s obstruction is derived from `E8_even`.
Failure analysis: the only subtlety is ℕ-subtraction in inclusion–exclusion; stating
  the identity additively (`wt(x+y) + 2·overlap = wt x + wt y`) and passing to ℤ for
  the divisibility step avoids it entirely.
-/

import Mathlib

-- Conceptually builds on `Catalog.Applications.SmoothPoincare.IntersectionForms`
-- (`E8form`, `E8_even`, `even_not_stdDiagonalizable`, `isEven_of_even_diag`,
-- `even_diag_of_isEven`); kept self-contained here so the file verifies standalone.

open scoped BigOperators

namespace SmoothPoincare
namespace Codes

variable {n : ℕ}

/-- **Hamming weight**: the number of nonzero coordinates of a binary vector. -/
def wt (v : Fin n → ZMod 2) : ℕ := (Finset.univ.filter (fun i => v i = 1)).card

/-- **Overlap**: the number of coordinates where both vectors equal `1`. -/
def overlap (x y : Fin n → ZMod 2) : ℕ :=
  (Finset.univ.filter (fun i => x i = 1 ∧ y i = 1)).card

/-- **Binary inner product** in `ZMod 2`; `selfOrthogonal` codes have all such products
zero. -/
def ip (x y : Fin n → ZMod 2) : ZMod 2 := ∑ i, x i * y i

/-
!-- Per-coordinate case check: only `(0,0),(1,0),(0,1),(1,1)` occur; in each the
contributions to both sides of `wt(x+y)+2·overlap = wt x + wt y` agree, so summing
over coordinates gives the identity. -- !--

**Inclusion–exclusion for Hamming weight.** Stated additively to avoid ℕ-subtraction:
`wt(x+y) + 2·overlap(x,y) = wt x + wt y`.
-/
theorem wt_add_overlap (x y : Fin n → ZMod 2) :
    wt (x + y) + 2 * overlap x y = wt x + wt y := by
  unfold wt overlap
  rw [ Finset.card_filter, Finset.card_filter, Finset.card_filter, Finset.card_filter ];
  rw [ Finset.mul_sum _ _ _ ] ; rw [ ← Finset.sum_add_distrib, ← Finset.sum_add_distrib ] ; congr ; ext i ; have := Fin.exists_fin_two.mp ⟨ x i, rfl ⟩ ; have := Fin.exists_fin_two.mp ⟨ y i, rfl ⟩ ; aesop;

/-
!-- `ip x y = ∑ x_i·y_i`; a product is `1` iff both factors are `1`, so the sum counts
overlap positions mod 2, i.e. `ip x y = (overlap x y : ZMod 2)`. -- !--

The binary inner product is the parity of the overlap.
-/
theorem ip_eq_overlap (x y : Fin n → ZMod 2) :
    ip x y = (overlap x y : ZMod 2) := by
  unfold ip overlap;
  rw [ Finset.card_filter, Nat.cast_sum ];
  exact Finset.sum_congr rfl fun i _ => by rcases x i with ( _ | _ | x ) <;> rcases y i with ( _ | _ | y ) <;> trivial;

/-- A vector is **doubly even** when its weight is divisible by `4`. -/
def DoublyEven (v : Fin n → ZMod 2) : Prop := 4 ∣ wt v

/-
!-- From `wt_add_overlap` in ℤ, `2·overlap = wt x + wt y − wt(x+y)`; if `4` divides
all three weights then `4 ∣ 2·overlap`, so `2 ∣ overlap`, so `ip x y = overlap mod 2
= 0`. -- !--

**The bridge theorem.** Two doubly-even vectors whose sum is also doubly even are
orthogonal.  This is the coding-theory mirror of "an even form has even diagonal"
(`SmoothPoincare.IntersectionForm.even_diag_of_isEven`): a doubly-even code is
automatically self-orthogonal.
-/
theorem doublyEven_selfOrthogonal (x y : Fin n → ZMod 2)
    (hx : DoublyEven x) (hy : DoublyEven y) (hxy : DoublyEven (x + y)) :
    ip x y = 0 := by
  convert ip_eq_overlap x y;
  exact Eq.symm ( ZMod.natCast_eq_zero_iff _ _ |>.2 <| Nat.dvd_of_mod_eq_zero <| by have := wt_add_overlap x y; obtain ⟨ k, hk ⟩ := hx; obtain ⟨ l, hl ⟩ := hy; obtain ⟨ m, hm ⟩ := hxy; omega )

/-! ## The extended Hamming code `[8,4,4]` — the mod-2 shadow of `E8` -/

/-- Generator matrix of the extended Hamming code `RM(1,3)`: the all-ones row together
with the three coordinate "address-bit" functions. -/
def hammingGen : Fin 4 → Fin 8 → ZMod 2 :=
  ![ ![1,1,1,1,1,1,1,1],
     ![0,0,0,0,1,1,1,1],
     ![0,0,1,1,0,0,1,1],
     ![0,1,0,1,0,1,0,1] ]

/-- Encoding map: a message `a ∈ (ZMod 2)⁴` maps to `∑ aᵢ · gen i`. -/
def encode (a : Fin 4 → ZMod 2) : Fin 8 → ZMod 2 := fun j => ∑ i, a i * hammingGen i j

/-- The **extended Hamming code** as the image of the encoder: a 16-element set of
length-`8` binary words. -/
def hamming : Finset (Fin 8 → ZMod 2) := Finset.image encode Finset.univ

/-
!-- Direct enumeration: the encoder image has 16 distinct words. -- !--

The extended Hamming code has `16 = 2⁴` codewords.
-/
theorem hamming_card : hamming.card = 16 := by
  native_decide

/-
!-- Encoding is ℤ/2-linear: `encode a + encode b = encode (a+b)` coordinatewise,
so the image is closed under addition. -- !--

The Hamming code is closed under addition (it is a linear code).
-/
theorem hamming_add_closed {x y : Fin 8 → ZMod 2}
    (hx : x ∈ hamming) (hy : y ∈ hamming) : x + y ∈ hamming := by
  by_contra hxy;
  unfold hamming at *;
  simp +zetaDelta at *;
  rcases hx with ⟨ a, rfl ⟩ ; rcases hy with ⟨ b, rfl ⟩ ; exact hxy ( a + b ) ( by ext
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — Topological Error-Correcting Codes from Exotic Smooth Structures

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
exact code-theoretic twin of "even unimodular definite lattice
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
