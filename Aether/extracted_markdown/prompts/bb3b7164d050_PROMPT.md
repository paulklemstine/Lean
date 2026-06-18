
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

**Title**: Intersection Form Classification Pipeline via Self-Dual Code Direct Sums
**Domain**: Applications
**Mathematical framing**: 
Research domain: Applications
Research mode: sorry_fill


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Applications/SmoothPoincare/CodeDirectSum.lean
/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Direct sums (concatenation) of binary self-dual codes

This file is the **coding-theory mirror** of
`Catalog.Applications.SmoothPoincare.DirectSum`, where the orthogonal direct sum
`Q ⊕ R` of intersection forms is shown to be *closed* under the three structural
predicates (`Unimodular`, `IsEven`, `StdDiagonalizable`), with headline `E8 ⊕ E8`.

Under Construction A the orthogonal direct sum of even unimodular lattices reduces,
modulo `2`, to the **direct sum (coordinate concatenation)** of binary self-dual
codes.  This file develops that operation `C ⊕ D ⊆ (ZMod 2)^{m+n}` and proves the
exact code-side analogues of the lattice closure theorems:

* `wt_append` / `ip_append` — weight is *additive* and the binary inner product is
  *block-diagonal* under concatenation (the combinatorial shadow of the block-diagonal
  Gram matrix `diag(G_Q, G_R)`).
* `appendCode_card` — `|C ⊕ D| = |C|·|D|` (the code shadow of `det` multiplicativity
  used in `directSum_unimodular`).
* `appendCode_doublyEven` — double-evenness is closed under `⊕` (shadow of
  `directSum_isEven`).
* `appendCode_selfDual` — **the headline closure theorem**: self-duality is closed
  under `⊕` (the code shadow of `directSum_unimodular`, Poincaré self-duality being
  preserved by connected sum).
* `appendCode_length_div_eight` — Gleason length divisibility is *additive*: the direct
  sum of two doubly-even self-dual codes again has length divisible by `8`.

The headline application is `hamming ⊕ hamming`, the length-`16` direct sum of two
copies of the extended Hamming `[8,4,4]` code — the precise mod-2 shadow of the
rank-`16` lattice `E8 ⊕ E8` (`DirectSum.E8E8form`).  It is self-dual, doubly even, has
`256 = 16·16` codewords, and length `16` divisible by `8`, all *derived* from the
general closure theorems rather than by a brute-force `decide` over `2^16` vectors.

## References
* J. H. Conway, N. J. A. Sloane, *Sphere Packings, Lattices and Groups* (Construction A).
* F. J. MacWilliams, N. J. A. Sloane, *The Theory of Error-Correcting Codes*.

-- !-- Lab Notebook -- !--
Hypothesis: the lattice direct-sum closure theorems of `DirectSum.lean` (Unimodular,
  IsEven, StdDiagonalizable closed under `⊕`) have verbatim coding-theory shadows under
  coordinate concatenation, with `hamming ⊕ hamming` the mod-2 image of `E8 ⊕ E8`.
Result: all closure theorems (`appendCode_selfDual`, `appendCode_doublyEven`,
  `appendCode_card`) proved `sorry`-free for arbitrary lengths; `hamming ⊕ hamming`
  shown self-dual + doubly-even of length 16 with 256 codewords, with `8 ∣ 16` recovered
  via Gleason rather than by `native_decide` over `2^16` vectors.
Insight: concatenation makes weight additive and the inner product block-diagonal, so
  self-orthogonality is transparent; the only content of the *backward* self-duality
  direction is that a self-dual code contains `0`, letting one probe each block
  independently via `append a 0` and `append 0 b`. This is the exact mirror of the
  block-diagonal `Tᵀ G T` argument in `directSum_stdDiagonalizable`.
Failure analysis: the `Fin (m+n)` index split is handled entirely by
  `Fin.sum_univ_add`, `Fin.append_left/right`, and `Fin.append_castAdd_natAdd`, with no
  explicit index arithmetic — the code analogue of routing the lattice proof through
  `finSumFinEquiv` / `submatrix_mul_equiv`.
-/

import Mathlib
import Catalog.Applications.SmoothPoincare.GleasonLength

open scoped BigOperators

namespace SmoothPoincare
namespace Codes

variable {m n : ℕ}

/-! ## The left/right coordinate projections and the concatenation code -/

/-- The "left block" of a length-`(m+n)` vector: its first `m` coordinates. -/
def leftPart (z : Fin (m + n) → ZMod 2) : Fin m → ZMod 2 := fun i => z (Fin.castAdd n i)

/-- The "right block" of a length-`(m+n)` vector: its last `n` coordinates. -/
def rightPart (z : Fin (m + n) → ZMod 2) : Fin n → ZMod 2 := fun i => z (Fin.natAdd m i)

@[simp] theorem leftPart_append (a : Fin m → ZMod 2) (b : Fin n → ZMod 2) :
    leftPart (Fin.append a b) = a := by
  funext i; simp [leftPart, Fin.append_left]

@[simp] theorem rightPart_append (a : Fin m → ZMod 2) (b : Fin n → ZMod 2) :
    rightPart (Fin.append a b) = b := by
  funext i; simp [rightPart, Fin.append_right]

theorem append_leftPart_rightPart (z : Fin (m + n) → ZMod 2) :
    Fin.append (leftPart z) (rightPart z) = z :=
  Fin.append_castAdd_natAdd

/-- **Direct sum (concatenation) of binary codes.**  `C ⊕ D ⊆ (ZMod 2)^{m+n}` is the
set of all concatenations `Fin.append a b` of a codeword `a ∈ C` and `b ∈ D`.  This is
the code-side analogue of `IntersectionForm.directSum` (block-diagonal Gram matrix). -/
def appendCode (C : Finset (Fin m → ZMod 2)) (D : Finset (Fin n → ZMod 2)) :
    Finset (Fin (m + n) → ZMod 2) :=
  (C ×ˢ D).image (fun p => Fin.append p.1 p.2)

@[inherit_doc] infixl:65 " ⊕c " => appendCode

/-! ## Membership, weight, inner product, and cardinality -/

/-- **Membership criterion** for the concatenation code: a vector lies in `C ⊕ D` iff
its left block lies in `C` and its right block lies in `D`. -/
theorem mem_appendCode {C : Finset (Fin m → ZMod 2)} {D : Finset (Fin n → ZMod 2)}
    {z : Fin (m + n) → ZMod 2} :
    z ∈ C ⊕c D ↔ leftPart z ∈ C ∧ rightPart z ∈ D := by
  constructor <;> intro h;
  · obtain ⟨ p, hp, rfl ⟩ := Finset.mem_image.mp h;
    aesop;
  · exact Finset.mem_image.mpr ⟨ ( leftPart z, rightPart z ), Finset.mem_product.mpr h, append_leftPart_rightPart z ⟩

/-- **Weight is additive under concatenation.** -/
theorem wt_append (a : Fin m → ZMod 2) (b : Fin n → ZMod 2) :
    wt (Fin.append a b) = wt a + wt b := by
  unfold wt;
  rw [ Finset.card_filter, Finset.card_filter, Finset.card_filter ];
  rw [ Fin.sum_univ_add ] ; aesop

/-- **The inner product is block-diagonal under concatenation.** -/
theorem ip_append (a c : Fin m → ZMod 2) (b d : Fin n → ZMod 2) :
    ip (Fin.append a b) (Fin.append c d) = ip a c + ip b d := by
  unfold ip;
  rw [ Fin.sum_univ_add ] ; aesop

/-- The concatenation map is injective on the product `C ×ˢ D`, hence
**`|C ⊕ D| = |C|·|D|`** — the code shadow of `det` multiplicativity. -/
theorem appendCode_card (C : Finset (Fin m → ZMod 2)) (D : Finset (Fin n → ZMod 2)) :
    (C ⊕c D).card = C.card * D.card := by
  rw [ Codes.appendCode, Finset.card_image_of_injective ];
  · exact Finset.card_product _ _;
  · intro p q h; have := congr_fun h; simp_all +decide [ Fin.append ] ;
    exact Prod.ext ( funext fun i => by simpa using congr_fun h ( Fin.castAdd n i ) ) ( funext fun i => by simpa using congr_fun h ( Fin.natAdd m i ) )

/-! ## Closure of the structural predicates -/

/-- **Double-evenness is additive under concatenation** (shadow of `directSum_isEven`). -/
theorem doublyEven_append {a : Fin m → ZMod 2} {b : Fin n → ZMod 2}
    (ha : DoublyEven a) (hb : DoublyEven b) : DoublyEven (Fin.append a b) := by
  exact dvd_trans ( by decide ) ( Nat.dvd_add ha hb ) |> fun h => h.trans ( by rw [ wt_append ] ) ;

/-- **Double-evenness is closed under `⊕`.** -/
theorem appendCode_doublyEven {C : Finset (Fin m → ZMod 2)} {D : Finset (Fin n → ZMod 2)}
    (hC : ∀ v ∈ C, DoublyEven v) (hD : ∀ v ∈ D, DoublyEven v) :
    ∀ v ∈ C ⊕c D, DoublyEven v := by
  intro v hv; rw [ mem_appendCode ] at hv; obtain ⟨ hv₁, hv₂ ⟩ := hv; exact append_leftPart_rightPart v ▸ doublyEven_append ( hC _ hv₁ ) ( hD _ hv₂ ) ;

/-- **Self-duality is closed under `⊕`** — the headline closure theorem, the code-side
analogue of `directSum_unimodular` (Poincaré self-duality preserved by connected sum). -/
theorem appendCode_selfDual {C : Finset (Fin m → ZMod 2)} {D : Finset (Fin n → ZMod 2)}
    (hC : ∀ x, x ∈ C ↔ ∀ y ∈ C, ip x y = 0)
    (hD : ∀ x, x ∈ D ↔ ∀ y ∈ D, ip x y = 0) :
    ∀ x, x ∈ C ⊕c D ↔ ∀ y ∈ C ⊕c D, ip x y = 0 := by
  intro x
  rw [mem_appendCode];
  constructor;
  · intro hx y hy
    obtain ⟨a, b, ha, hb, rfl⟩ : ∃ a b, a 
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# FUTURE DIRECTIONS — Intersection Form Classification via Self-Dual Code Direct Sums

This cycle added `CodeDirectSum.lean`: the direct sum (coordinate concatenation)
`C ⊕c D` of binary codes, with closure of self-duality (`appendCode_selfDual`),
double-evenness (`appendCode_doublyEven`), cardinality multiplicativity
(`appendCode_card`, `|C ⊕ D| = |C|·|D|`), weight additivity (`wt_append`), inner-product
block-diagonality (`ip_append`), and additive Gleason length divisibility
(`appendCode_length_div_eight`). Headline: `hamming16 = hamming ⊕c hamming`, the mod-2
shadow of the rank-16 lattice `E8 ⊕ E8`, shown self-dual + doubly even with 256
codewords and length `16` divisible by `8`. This is the coding-theory mirror of the
lattice closure theorems in `DirectSum.lean`.

Below are falsifiable conjectures for follow-up cycles, ordered roughly by ambition.

## Conjecture 1 — Weight-enumerator multiplicativity (MacWilliams convolution)
**Statement.** For binary codes `C ⊆ (ZMod 2)^m`, `D ⊆ (ZMod 2)^n`, the weight
distribution of `C ⊕c D` is the *convolution* of those of `C` and `D`:
`(C ⊕c D).filter (wt · = k)).card = ∑_{i+j=k} (C.filter (wt·=i)).card · (D.filter (wt·=j)).card`.
**Test.** Specialize to `hamming16`: predict the weight enumerator
`(1 + 14x⁴ + x⁸)² = 1 + 28x⁴ + 198x⁸ + 28x¹² + x¹⁶`, and check each coefficient by
`native_decide`. This refines `appendCode_card` (the `x=1` evaluation) exactly as the
lattice theta-series of `E8 ⊕ E8` is the square of the `E8` theta-series. Directly
extends `MinimumDistance.hamming_weightEnum_*`.

## Conjecture 2 — Minimum distance of a direct sum is the minimum of the parts
**Statement.** For nonzero-containing self-dual `C`, `D`, the minimum distance of
`C ⊕c D` equals `min (d C) (d D)`: every nonzero codeword of `C ⊕c D` has weight `≥
min(d C, d D)`, and this bound is attained. **Test.** Conclude `hamming16` has minimum
distance `4` (not `8`), so `hamming16` is an `[16,8,4]` code — strictly worse than the
genuinely indecomposable rank-16 datum `D16⁺` (whose code shadow has minimum distance
`4` as well but a different weight enumerator). This pins the *decomposability gap*:
direct sums never improve `d`, mirroring how `E8 ⊕ E8` is decomposable while `D16⁺` is
not, even though both are even unimodular of rank 16. Extends
`MinimumDistance.hamming_minDist_lower/attained`.

## Conjecture 3 — The rank-16 dichotomy: `E8 ⊕ E8` vs `D16⁺` are inequivalent
**Statement.** There exist exactly two even unimodular lattices of rank 16 up to
isometry, `E8 ⊕ E8` and `D16⁺`; their mod-2 code shadows are inequivalent binary
doubly-even self-dual `[16,8,4]` codes, distinguished by their weight enumerators
(Conjecture 1) being equal yet their automorphism-orbit structure differing.
**Test (algebraic, code side).** Build `D16plus : Finset (Fin 16 → ZMod 2)` explicitly,
prove it self-dual and doubly even (so Gleason gives `8 ∣ 16` again), then show it is
**not** of the form `appendCode C D` for any nontrivial split — i.e. it is 
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
