
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

**Title**: Self-dual code length enumerators as a bridge to smooth 4-manifold intersection-form pipelines
**Domain**: Applications
**Mathematical framing**: 
Research domain: Applications
Research mode: formalize


## Phase A Lean 4 Output (the math — read this carefully)

```
-- DIFF: a72aaf71_retry1_aristotle/Catalog/Applications/SmoothPoincare/CodeDirectSum.lean
--- a/Applications/SmoothPoincare/CodeDirectSum.lean
+++ b/Applications/SmoothPoincare/CodeDirectSum.lean
@@ -107,6 +107,20 @@
     aesop;
   · exact Finset.mem_image.mpr ⟨ ( leftPart z, rightPart z ), Finset.mem_product.mpr h, append_leftPart_rightPart z ⟩
 
+/-- **Existential membership criterion.** A vector lies in `C ⊕ D` iff it is the
+concatenation `Fin.append a b` of a codeword `a ∈ C` and a codeword `b ∈ D`. This is
+the form `x ∈ C ⊕ D ↔ ∃ a∈C, ∃ b∈D, x = Fin.append a b` directly mirroring the
+lattice-side block decomposition. -/
+theorem mem_appendCode_iff_exists {C : Finset (Fin m → ZMod 2)}
+    {D : Finset (Fin n → ZMod 2)} {z : Fin (m + n) → ZMod 2} :
+    z ∈ C ⊕c D ↔ ∃ a ∈ C, ∃ b ∈ D, z = Fin.append a b := by
+  rw [mem_appendCode]
+  constructor
+  · intro h
+    exact ⟨leftPart z, h.1, rightPart z, h.2, (append_leftPart_rightPart z).symm⟩
+  · rintro ⟨a, ha, b, hb, rfl⟩
+    simp [ha, hb]
+
 /-- **Weight is additive under concatenation.** -/
 theorem wt_append (a : Fin m → ZMod 2) (b : Fin n → ZMod 2) :
     wt (Fin.append a b) = wt a + wt b := by
@@ -141,6 +155,21 @@
     (hC : ∀ v ∈ C, DoublyEven v) (hD : ∀ v ∈ D, DoublyEven v) :
     ∀ v ∈ C ⊕c D, DoublyEven v := by
   intro v hv; rw [ mem_appendCode ] at hv; obtain ⟨ hv₁, hv₂ ⟩ := hv; exact append_leftPart_rightPart v ▸ doublyEven_append ( hC _ hv₁ ) ( hD _ hv₂ ) ;
+
+/-- **Self-orthogonality is closed under `⊕`.** If every pair of codewords of `C` is
+orthogonal and likewise for `D`, then every pair of codewords of the concatenation
+`C ⊕ D` is orthogonal.  This is the code-side analogue of the block-diagonal Gram
+matrix having zero off-diagonal blocks: the inner product `ip_append` splits as the
+sum of the two block inner products, each vanishing by hypothesis. -/
+theorem appendCode_selfOrthogonal {C : Finset (Fin m → ZMod 2)}
+    {D : Finset (Fin n → ZMod 2)}
+    (hC : ∀ x ∈ C, ∀ y ∈ C, ip x y = 0)
+    (hD : ∀ x ∈ D, ∀ y ∈ D, ip x y = 0) :
+    ∀ x ∈ C ⊕c D, ∀ y ∈ C ⊕c D, ip x y = 0 := by
+  intro x hx y hy
+  obtain ⟨a, ha, b, hb, rfl⟩ := mem_appendCode_iff_exists.1 hx
+  obtain ⟨c, hc, d, hd, rfl⟩ := mem_appendCode_iff_exists.1 hy
+  rw [ip_append, hC a ha c hc, hD b hb d hd, add_zero]
 
 /-- **Self-duality is closed under `⊕`** — the headline closure theorem, the code-side
 analogue of `directSum_unimodular` (Poincaré self-duality preserved by connected sum). -/
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — Self-dual codes ↔ smooth 4-manifold intersection forms

This cycle added `SelfDualCardinality.lean`, isolating the *evenness-free* structural
invariant of a binary self-dual code:

* `selfDual_card_sq`   : `|C|² = 2ⁿ`   (master cardinality identity, any self-dual code)
* `selfDual_length_even`: `2 ∣ n`       (every self-dual code has even length)
* `selfDual_card`      : `|C| = 2^(n/2)` (the dimension is exactly `n/2`)

These sit *below* the doubly-even refinements (`4 ∣ n` in `SelfDualLength`, `8 ∣ n` in
`GleasonLength`), giving the layered tower
`self-dual ⟹ 2 ∣ n`  ⊂  `doubly-even self-dual ⟹ 8 ∣ n`,
the code-side mirror of `unimodular` ⊂ `even unimodular ⟹ rank divisible by 8`.

Below are bold, testable conjectures for follow-up cycles.

## Conjecture 1 — Concatenation is the connected sum of codes (mirror of `DirectSum.lean`)

For codes `C ⊆ (ZMod 2)ᵐ`, `D ⊆ (ZMod 2)ⁿ`, define the direct sum
`C ⊕ D ⊆ (ZMod 2)^(m+n)` by coordinate concatenation. Then:

* `C ⊕ D` is self-dual iff both `C` and `D` are;
* `|C ⊕ D| = |C| · |D|`, so `selfDual_card` gives `2^((m+n)/2) = 2^(m/2)·2^(n/2)`;
* double-evenness is preserved (`wt` is additive across the split);
* minimum distance: `d(C ⊕ D) = min (d C) (d D)`.

This is the exact coding-theory shadow of `IntersectionForm.directSum_unimodular` /
`directSum_isEven` and of the connected sum `M # N`. **Testable:** formalize `⊕` on
`Finset (Fin (m+n) → ZMod 2)` via `finSumFinEquiv` and prove the four closure facts;
instantiate on `hamming ⊕ hamming` (length 16) as the code shadow of `E8 ⊕ E8`.

## Conjecture 2 — MacWilliams invariance: a self-dual code's weight enumerator is a fixed point

Let `W_C(X,Y) = ∑_{c∈C} X^{n - wt c} Y^{wt c}`. The MacWilliams identity says
`W_{C^⊥}(X,Y) = |C|⁻¹ · W_C(X+Y, X−Y)`. **Conjecture:** for a self-dual `C` (so
`C = C^⊥`), `W_C` is invariant under `(X,Y) ↦ ((X+Y)/√2, (X−Y)/√2)`; for a *doubly-even*
self-dual `C` it is additionally invariant under `Y ↦ iY`, hence (Gleason) a polynomial
in `W_{[8,4,4]}(X,Y) = X⁸ + 14X⁴Y⁴ + Y⁸` and `(X⁴Y⁴(X⁴−Y⁴)⁴)`.
**Testable:** prove the two-variable MacWilliams identity from the already-established
`char_orthogonality` + `fourier_iwt` machinery (the Fourier transform of `bchar` is
exactly the substitution `X±Y`), then verify the `1 + 14x⁴ + x⁸` enumerator of `hamming`
is a fixed point of the order-8 substitution by `native_decide`.

## Conjecture 3 — Gleason's distance bound `d ≤ 4⌊n/24⌋ + 4`

A doubly-even self-dual code of length `n` has minimum distance
`d ≤ 4⌊n/24⌋ + 4`. For `n = 8` this gives `d ≤ 4`, attained by `hamming`
(`MinimumDistance.hamming_minDist_attained`); the first "extremal" case is `n = 24`
(the binary Golay code, the code shadow of the Leech lattice).
**Testable:** the `n ≤ 22` window of the bound (`d ≤ 4`) follows from the supported
weights `{0,4,8,…}` and the cardinality `2^(n/2)` of this cycle; formalize
`d ≤ 4 → ` weight-distribution constraints and check the Golay parameters `[24,12,8]`
by `native
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
