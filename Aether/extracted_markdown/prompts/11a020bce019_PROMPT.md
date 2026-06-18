
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

**Title**: Close Proofs: Arithmetic Mirror Symmetry for Calabi-Yau
**Domain**: Novelty
**Mathematical framing**: Cycle f8049429 (Q=0.451) proved 972 theorems in Applications but left 1 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: Prove arithmetic mirror symmetry: the number of rational curves on X equals the rank of the Picard group of its mirror Y. Formalize the SYZ picture and modularity of CY zeta functions.
Research domain: Novelty
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Speculative/ArithmeticMirror/Core.lean
/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Arithmetic Mirror Symmetry for Calabi–Yau: the Hodge–diamond shadow

Mirror symmetry predicts that to a Calabi–Yau `d`-fold `X` there is associated a
*mirror* `Y`, again Calabi–Yau, whose Hodge diamond is the **vertical reflection** of
that of `X`:

  `hᵖᵠ(Y) = h^{d-p,q}(X)`.

This single combinatorial swap encodes the deep geometric exchange "complex moduli of
`X` ↔ Kähler moduli of `Y`", and in particular the heuristic that the *count of
rational curves* on `X` (controlled by `h^{d-1,1}(X)`) equals the *rank of the Picard
group* of the mirror `Y` (which is `h^{1,1}(Y)`).

This file isolates the fully verifiable **arithmetic / combinatorial heart** of that
picture and proves it `sorry`-free:

* `CalabiYau d` — a Hodge diamond: a symmetric (`conj_symm`), Serre-dual (`serre`)
  array of Hodge numbers supported on `[0,d]²` (`vanish`).
* `mirror` — the vertical reflection, **proved again to be a `CalabiYau`** (closure of
  the Calabi–Yau axioms under mirroring is itself the structural content).
* `mirror_involutive` — mirroring is an involution.
* `picardRank_mirror` — **arithmetic mirror symmetry**: the Picard rank `h^{1,1}` of
  the mirror equals `h^{d-1,1}` of `X`, the curve-counting Hodge number.
* `eulerChar_mirror` — the topological mirror law `χ(Y) = (-1)^d χ(X)`.
* The **K3** diamond as a worked, self-mirror example with `χ = 24`.

## References
* P. Candelas, X. de la Ossa, P. Green, L. Parkes, *A pair of Calabi–Yau manifolds as
  an exactly soluble superconformal theory* (1991).
* D. Cox, S. Katz, *Mirror Symmetry and Algebraic Geometry* (1999).

-- !-- Lab Notebook -- !--
Hypothesis: The "rational-curve count = Picard rank of mirror" slogan and the
  topological law `χ(Y)=(-1)^d χ(X)` are *purely combinatorial* consequences of the
  vertical Hodge reflection, once the Calabi–Yau Hodge axioms (conjugation + Serre
  duality + finite support) are imposed; no geometry is needed for the arithmetic core.
Result: Confirmed. `mirror` is closed inside `CalabiYau`, it is an involution, it sends
  `h^{1,1}` to `h^{d-1,1}`, and it scales the Euler characteristic by `(-1)^d`. The K3
  diamond is self-mirror with `χ = 24`.
Insight: The closure proof (`mirror` is a `CalabiYau`) is where conjugation symmetry and
  Serre duality must be used *together*: `h^{d-p,q} = h^{q,d-p} = h^{d-q,p}`. Reflecting
  one index and conjugating recovers the other reflection — this is the algebraic
  fingerprint of mirror symmetry being an involution on diamonds.
Failure analysis: A naive `mirror` without the `if p ≤ d ∧ q ≤ d` guard breaks finite
  support (`vanish`) because `Nat` truncated subtraction sends `p > d` to `0` rather than
  off-diamond; guarding the reflection on the support box repairs every axiom.
-/

import Mathlib

open scoped BigOperators

namespace ArithmeticMirror

/-- A **Hodge diamond** of a Calabi–Yau `d`-fold: the array of Hodge numbers
`hᵖᵠ = dim H^q(X, Ωᵖ)`, modeled as a function `ℕ → ℕ → ℕ` satisfying the structural
axioms of a Calabi–Yau Hodge diamond.

* `conj_symm` — complex-conjugation symmetry `hᵖᵠ = hᵠᵖ`;
* `serre`     — Serre duality `hᵖᵠ = h^{d-p,d-q}`;
* `vanish`    — finite support: `hᵖᵠ = 0` outside the box `[0,d]²`. -/
structure CalabiYau (d : ℕ) where
  /-- The Hodge numbers `hᵖᵠ`. -/
  h : ℕ → ℕ → ℕ
  /-- Conjugation symmetry of the Hodge diamond. -/
  conj_symm : ∀ p q, p ≤ d → q ≤ d → h p q = h q p
  /-- Serre duality of the Hodge diamond. -/
  serre : ∀ p q, p ≤ d → q ≤ d → h p q = h (d - p) (d - q)
  /-- Hodge numbers vanish outside the support box `[0,d]²`. -/
  vanish : ∀ p q, (d < p ∨ d < q) → h p q = 0

namespace CalabiYau

variable {d : ℕ}

/-- The **Picard rank** (rank of the Néron–Severi / Picard group), `h^{1,1}`. -/
def picardRank (X : CalabiYau d) : ℕ := X.h 1 1

/-- The **Euler characteristic** `χ = Σ_{p,q} (-1)^{p+q} hᵖᵠ`, summed over the support
box `[0,d]²`. -/
def eulerChar (X : CalabiYau d) : ℤ :=
  ∑ p ∈ Finset.range (d + 1), ∑ q ∈ Finset.range (d + 1),
    (-1 : ℤ) ^ (p + q) * (X.h p q : ℤ)

/-- The mirror's Hodge function: the vertical reflection `p ↦ d - p`, guarded to the
support box so finiteness is preserved. -/
def mirrorH (X : CalabiYau d) : ℕ → ℕ → ℕ :=
  fun p q => if p ≤ d ∧ q ≤ d then X.h (d - p) q else 0

-- !-- conj on `(d-p,q)` then Serre on `(q,d-p)` gives `h^{d-p,q}=h^{q,d-p}=h^{d-q,p}`. -- !--
/-- Reflecting one index and using conjugation + Serre duality recovers the other
reflection: this is the key algebraic identity behind mirror symmetry. -/
theorem reflect_eq (X : CalabiYau d) {p q : ℕ} (hp : p ≤ d) (hq : q ≤ d) :
    X.h (d - p) q = X.h (d - q) p := by
  have h1 := X.conj_symm (d - p) q ?_ ?_ <;> simp_all +decide
  convert X.serre q (d - p) hq (Nat.sub_le _ _) using 1
  rw [Nat.sub_sub_self hp]

-- !-- Within the box `mirrorH p q = h^{d-p,q}`; `reflect_eq` makes it symmetric. -- !--
/-- The mirror diamond is again conjugation-symmetric. -/
theorem mirrorH_conj (X : CalabiYau d) (p q : ℕ) (hp : p ≤ d) (hq : q ≤ d) :
    X.mirrorH p q = X.mirrorH q p := by
  unfold CalabiYau.mirrorH
  rw [if_pos ⟨hp, hq⟩, if_pos ⟨hq, hp⟩, reflect_eq X hp hq]

-- !-- `h^{d-p,q} = h^{d-(d-p),d-q} = h^{p,d-q}` by Serre duality directly. -- !--
/-- The mirror diamond is again Serre-dual. -/
theorem mirrorH_serre (X : CalabiYau d) (p q : ℕ) (hp : p ≤ d) (hq : q ≤ d) :
    X.mirrorH p q = X.mirrorH (d - p) (d - q) := by
  unfold mirrorH; simp +decide [*, Nat.sub_sub_self]
  convert X.serre (d - p) q (by omega) (by omega) using 1
  rw [Nat.sub_sub_self hp]

-- !-- The guard `if p ≤ d ∧ q ≤ d` forces `0` off-box. -- !--
/-- The mirror diamond is again finitely supported. -/
theorem mirrorH_vanish (X : CalabiYau d) (p q : ℕ) (h : d < p ∨ d < q) :
    X.mirrorH p q = 0 := by
  unfold CalabiYau.mirrorH
  grind

/-- The **mirror** Calabi–Yau `Y`: vertical reflection of the Hodge diamond. The content
is that this is *again* a Calabi–Yau (closure under mirroring). -/
def mirror (X : CalabiYau d) : CalabiYau d where
  h := X.mirrorH
  conj_symm := X.mirrorH_conj
  serre := X.mirrorH_serre
  vanish := X.mirrorH_vanish

-- !-- `mirror(mirror)(p,q) = h^{d-(d-p),q} = h^{p,q}` in-box; both sides `0` off-box. -- !--
/-- **Mirroring is an involution** on Hodge diamonds. -/
theorem mirror_involutive (X : CalabiYau d) :
    (X.mirror.mirror).h = X.h := by
  ext p q
  by_cases hp : p ≤ d <;> by_cases hq : q ≤ d <;>
    simp +decide [hp, hq, CalabiYau.mirror, CalabiYau.mirrorH]
  · rw [Nat.sub_sub_self hp]
  · exact Eq.symm (X.vanish p q (Or.inr (not_le.mp hq)))
  · rw [X.vanish p q (Or.inl (not_le.mp hp))]
  · rw [X.vanish p q (Or.inl (not_le.mp hp))]

-- !-- By definition `mirror.h 1 1 = h^{d-1,1}` once `1 ≤ d` activates the guard. -- !--
/-- **Arithmetic mirror symmetry (curve count ↔ Picard rank).** The Picard rank
`h^{1,1}` of the mirror equals `h^{d-1,1}` of `X`, the Hodge number governing the count
of rational curves. -/
theorem picardRank_mirror (X : CalabiYau d) (hd : 1 ≤ d) :
    X.mirror.picardRank = X.h (d - 1) 1 := by
  exact if_pos ⟨hd, hd⟩

-- !-- `(-1)^{d-p+q}·(-1)^{2p} = (-1)^{d+p+q}`, and `(-1)^{2p}=1`, since `p ≤ d`. -- !--
/-- Sign reflection identity used for the Euler-characteristic law. -/
theorem sign_reflect (d p q : ℕ) (hp : p ≤ d) :
    (-1 : ℤ) ^ (d - p + q) = (-1) ^ d * (-1) ^ (p + q) := by
  have key : (d - p + q) + 2 * p = d + (p + q) := by omega
  calc (-1 : ℤ) ^ (d - p + q) = (-1) ^ (d - p + q) * (-1) ^ (2 * p) := by simp [pow_mul]
    _ = (-1) ^ (d - p + q + 2 * p) := by rw [← pow_add]
    _ = (-1) ^ (d + (p + q)) := by rw [key]
    _ = (-1) ^ d * (-1) ^ (p + q) := by rw [pow_add]

-- !-- Reflect the `p`-sum (`Finset.sum_range_reflect`/`sum_flip`); each term picks up
-- `(-1)^{d-p+q} = (-1)^d (-1)^{p+q}` (`sign_reflect`), factoring out `(-1)^d`. -- !--
/-- **Topological mirror law.** `χ(Y) = (-1)^d χ(X)`. -/
theorem eulerChar_mirror (X : CalabiYau d) 
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — Arithmetic Mirror Symmetry for Calabi–Yau

## Synthesis

This cycle established a fully verified *combinatorial skeleton* of mirror symmetry.
We modeled a Calabi–Yau `d`-fold by its **Hodge diamond** — an array `hᵖᵠ : ℕ → ℕ → ℕ`
subject to three axioms that any genuine Hodge diamond satisfies: conjugation symmetry
(`hᵖᵠ = hᵠᵖ`), Serre duality (`hᵖᵠ = h^{d-p,d-q}`), and finite support on `[0,d]²`.
The **mirror** operation is the single combinatorial move `hᵖᵠ ↦ h^{d-p,q}` (vertical
reflection of the diamond). The deliverables (`Core.lean`) prove, with `sorry = 0` and
only the standard axioms `{propext, Classical.choice, Quot.sound}`:

* `mirror` is **closed** inside the class of Calabi–Yau diamonds (the reflection again
  satisfies conjugation symmetry, Serre duality, and finite support);
* `mirror_involutive` — mirroring is an involution;
* `picardRank_mirror` — the **arithmetic mirror slogan**: the Picard rank `h^{1,1}` of
  the mirror equals `h^{d-1,1}` of the original, the Hodge number that governs rational
  curve counts (complex deformations on one side ↔ Kähler/curve data on the other);
* `eulerChar_mirror` — the **topological mirror law** `χ(Y) = (-1)^d χ(X)`;
* a worked **K3** example: a self-mirror diamond with `χ(K3) = 24` and Picard rank `20`.

The central lesson is structural: the closure of the Calabi–Yau axioms under mirroring
forces conjugation symmetry and Serre duality to be used *together* — the identity
`h^{d-p,q} = h^{q,d-p} = h^{d-q,p}` (`reflect_eq`) is the algebraic fingerprint of the
mirror being an involution. This isolates exactly which facts about mirror symmetry are
formal/combinatorial and which require honest geometry (curve counting, Hodge theory,
zeta functions). Everything below is a falsifiable extension of this skeleton.

## Results Summary

| Theorem | Statement | Status |
|---|---|---|
| `reflect_eq` | `h^{d-p,q} = h^{d-q,p}` | proved |
| `mirror` (closure) | reflection is again a `CalabiYau` | proved |
| `mirror_involutive` | `mirror ∘ mirror = id` | proved |
| `picardRank_mirror` | `picardRank (mirror X) = h^{d-1,1}(X)` | proved |
| `eulerChar_mirror` | `χ(Y) = (-1)^d χ(X)` | proved |
| `K3_eulerChar` | `χ(K3) = 24` | proved |
| `K3_self_mirror_picard` | `picardRank(mirror K3) = picardRank K3` | proved |

---

## Direction 1 — A "stringy" mirror invariant: the Hodge–Euler polynomial is mirror-palindromic

Define the two-variable Hodge–Euler polynomial `E(u,v) = Σ_{p,q} hᵖᵠ uᵖ vᵠ` and conjecture
that the mirror exchanges it by `E_Y(u,v) = uᵈ · E_X(u⁻¹, v)` (clearing denominators,
`E_Y(u,v) = Σ_{p,q} h^{d-p,q} uᵖ vᵠ`), and that `eulerChar` is recovered as `E(-1,-1)`.
This refines `eulerChar_mirror` from the single value `χ` to the whole bigraded generating
function, and predicts that `E` is *bidegree-symmetric* under the combined mirror + Serre
symmetries. **The key insight is** that `eulerChar_mirror` is merely the `u=v=-1`
specialization of an identity that holds *coefficientwise*, so t
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
