
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

**Title**: Close Proofs: Close Proofs: One-Way Functions: Existence and Hierarchy
**Domain**: Applications
**Mathematical framing**: Cycle 7d85fa5d (Q=0.421) proved 1952 theorems in Tropical but left 6 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: Cycle ac6121a8 (Q=0.425) proved 482 theorems in Novelty but left 2 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: Formalize the lattice of 
Research domain: Applications
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Cryptography/OneWayHierarchy.lean
/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Cryptography.HardnessHierarchy

/-!
# One-Way Functions: Existence and Hierarchy

This module isolates the *conceptual core* of one-way function (OWF) theory: the
reason OWFs are a **computational** rather than an **information-theoretic** notion.

We formalize, over arbitrary (possibly infinite, only nonempty) domains, the fact
that every function admits a **weak inverse** — a map that recovers, for every
input `x`, *some* preimage of `f x`. Consequently no function can be one-way in the
information-theoretic sense: an unbounded adversary always inverts perfectly. This
makes precise the folklore slogan "one-wayness lives entirely in complexity", which
is the foundation of the whole hardness hierarchy `OWF → PRG → PRF → ENC`.

We then quantify the *combinatorial optimality* of inversion: over a finite domain,
the maximal number of exactly-recovered inputs of any inverter equals the image
size `|Im f|`, and this optimum is attained by the canonical inverter `Function.invFun f`.

Finally we expose the **order-theoretic skeleton** of the hardness hierarchy
(`CryptoLevel` from `Cryptography.HardnessHierarchy`): the rank map is injective, the
implication relation is a total order, OWF is its weakest and ENC its strongest level.

## Catalog synthesis

* Extends `Cryptography.HardnessHierarchy` (`CryptoLevel`, `LossyFunction`, `fiber`,
  `hierarchy_strict`): we add the *existence* layer beneath the hierarchy and turn the
  discrete `rank` chain into a genuine total order with extremal elements.
* Complements `Cryptography.OneWay` (`ProofSearch`): that file models OWF *hardness*
  (verification + exponential sparsity); here we explain why such hardness is
  *necessary* — information theory alone never yields one-wayness.

## Main results

* `exists_weakInverse`        — every function over a nonempty domain has a weak inverse.
* `not_infoTheoreticOneWay`   — no function is information-theoretically one-way.
* `weakInverse_inverts_all`   — a weak inverter succeeds on every one of the `|α|` inputs.
* `exact_inversions_le_image` — any inverter exactly recovers ≤ `|Im f|` inputs.
* `invFun_exact_inversions`   — `Function.invFun f` attains the optimum `|Im f|`.
* `level_total`/`owf_weakest`/`enc_strongest` — the hierarchy is a total order with extrema.
-/

open Function Finset

namespace OneWayHierarchy

/-! ## Section 1: Weak inverses and information-theoretic impossibility -/

variable {α β : Type*}

-- !-- Lab Notebook -- !--
-- Hypothesis: "One-wayness" of `f` should be impossible without a complexity bound,
--   because an adversary with no resource constraint can simply tabulate a preimage map.
-- Result: Confirmed. `Function.invFun f` is a weak inverse for ANY `f` over a nonempty
--   domain (Section 1), so the information-theoretic security game is always lost.
-- Insight: The only obstacle to inversion is *computation*, never *information*; this is
--   exactly why the hierarchy assumes (rather than proves) OWF existence.
-- Failure analysis: An early attempt phrased weak inversion as `g (f x) = x` (a genuine
--   left inverse); that is false for non-injective `f`. The correct invariant is
--   `f (g (f x)) = f x` — recover *a* preimage, not *the* input.

/-- `g` is a **weak inverse** of `f` when, for every input `x`, `g` maps `f x` back to
some genuine preimage of `f x` (equivalently `g (f x)` lies in the fiber of `f x`). -/
def WeakInverse (f : α → β) (g : β → α) : Prop := ∀ x, f (g (f x)) = f x

-- !-- comment: `Function.invFun_eq` applied to the witness `⟨x, rfl⟩` gives precisely
--   `f (invFun f (f x)) = f x`, so the canonical inverse is always weak. -- !--
theorem invFun_weakInverse [Nonempty α] (f : α → β) : WeakInverse f (invFun f) :=
  fun x => invFun_eq ⟨x, rfl⟩

-- !-- comment: Existence is witnessed by `Function.invFun f`. -- !--
theorem exists_weakInverse [Nonempty α] (f : α → β) : ∃ g : β → α, WeakInverse f g :=
  ⟨invFun f, invFun_weakInverse f⟩

/-- A function is **information-theoretically one-way** if *no* inverter recovers a
preimage of `f x` for every `x`; i.e. every candidate inverter fails somewhere. -/
def InfoTheoreticOneWay (f : α → β) : Prop := ∀ g : β → α, ∃ x, f (g (f x)) ≠ f x

-- !-- comment: Immediate from `exists_weakInverse`: the weak inverse refutes the
--   universally-failing requirement. This is the central conceptual theorem. -- !--
theorem not_infoTheoreticOneWay [Nonempty α] (f : α → β) : ¬ InfoTheoreticOneWay f := by
  rintro hOW
  obtain ⟨g, hg⟩ := exists_weakInverse f
  obtain ⟨x, hx⟩ := hOW g
  exact hx (hg x)

/-! ## Section 2: Quantitative inversion success over finite domains -/

variable [Fintype α] [DecidableEq α] [DecidableEq β]

-- !-- comment: A weak inverter succeeds on *every* input, so the set of successes is
--   all of `univ`, of cardinality `|α|` — perfect information-theoretic advantage. -- !--
omit [DecidableEq α] in
theorem weakInverse_inverts_all (f : α → β) (g : β → α) (h : WeakInverse f g) :
    (Finset.univ.filter (fun x => f (g (f x)) = f x)).card = Fintype.card α := by
  rw [Finset.filter_true_of_mem (fun x _ => h x), Finset.card_univ]

/-! ## Section 3: Combinatorial optimality of exact inversion -/

-- !-- Lab Notebook -- !--
-- Hypothesis: While *weak* inversion is always perfect, *exact* inversion
--   (`g (f x) = x`) is genuinely limited by collisions: an inverter can pin down at
--   most one input per fiber, hence at most `|Im f|` inputs total.
-- Result: Proven sharp. `exact_inversions_le_image` gives the upper bound for ALL `g`;
--   `invFun_exact_inversions` shows `Function.invFun f` attains it.
-- Insight: `|Im f|` is the information-theoretic capacity of *exact* recovery — the
--   precise bridge between collision structure (Section 6 of HardnessHierarchy) and
--   inversion. A lossy function with small image is intrinsically hard to invert exactly.
-- Failure analysis: The achievability direction needs the bijection
--   `Im f ≃ {fixed points of invFun∘f}`, `y ↦ invFun f y`; a naive `card_image` of `f`
--   over the fixed set only gives `≤`, not the reverse, so an explicit bijection is used.

/-- The set of inputs that `g` recovers **exactly**: `g (f x) = x`. -/
def exactInversions (f : α → β) (g : β → α) : Finset α :=
  Finset.univ.filter (fun x => g (f x) = x)

-- !-- comment: On the exact-inversion set `f` is injective (`x = g(f x)`), so `f`
--   embeds it into `Im f`; hence its size is `≤ |Im f|`. -- !--
theorem exact_inversions_le_image (f : α → β) (g : β → α) :
    (exactInversions f g).card ≤ (Finset.univ.image f).card := by
  refine Finset.card_le_card_of_injOn f ?_ ?_
  · intro x hx
    exact Finset.mem_image_of_mem f (Finset.mem_univ x)
  · intro x hx y hy hxy
    simp only [exactInversions, Finset.mem_coe, Finset.mem_filter] at hx hy
    calc x = g (f x) := hx.2.symm
      _ = g (f y) := by rw [hxy]
      _ = y := hy.2

-- !-- comment: The optimum `|Im f|` is attained by `invFun f`: the map `y ↦ invFun f y`
--   is a bijection from `Im f` onto the fixed-point set `{x | invFun f (f x) = x}`,
--   because `f (invFun f y) = y` for `y ∈ Im f`. -- !--
theorem invFun_exact_inversions [Nonempty α] (f : α → β) :
    (exactInversions f (invFun f)).card = (Finset.univ.image f).card := by
  have hset : exactInversions f (invFun f) = (Finset.univ.image f).image (invFun f) := by
    ext x
    simp only [exactInversions, Finset.mem_filter, Finset.mem_image, Finset.mem_univ, true_and]
    constructor
    · intro hx
      exact ⟨f x, ⟨x, rfl⟩, hx⟩
    · rintro ⟨y, ⟨a, rfl⟩, rfl⟩
      have : f (invFun f (f a)) = f a := invFun_eq ⟨a, rfl⟩
      rw [this]
  rw [hset, Finset.card_image_of_injOn]
  intro y hy z hz hyz
  simp only [Finset.mem_coe, Finset.mem_image, Finset.mem_univ, true_and] at hy hz
  obtain ⟨a, rfl⟩ := hy
  obtain ⟨b, rfl⟩ := hz
  have h1 : f (invFun f (f a)) = f a :
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — One-Way Functions: Existence and Hierarchy

## Synthesis

The cycle's central discovery is conceptual rather than computational: **one-wayness
is never an information-theoretic property**. Over any nonempty domain the canonical
inverse `Function.invFun f` is already a *weak inverse* (`invFun_weakInverse`), so an
adversary with unbounded resources always wins the inversion game
(`not_infoTheoreticOneWay`). What remains genuinely scarce is *exact* inversion: over a
finite domain no inverter can pin down more than `|Im f|` inputs
(`exact_inversions_le_image`), and that capacity is exactly met by `invFun f`
(`invFun_exact_inversions`). The image size `|Im f|` therefore emerges as the precise
information-theoretic capacity of inversion, the bridge between the collision/fiber
analysis of `Cryptography.HardnessHierarchy` (`fiber`, `large_fiber_exists`,
`LossyFunction`) and the one-wayness layer. Finally, the qualitative hierarchy
`OWF → PRG → PRF → ENC` was upgraded from the mere antisymmetry of `hierarchy_strict`
to a genuine total order with extremal elements (`level_total`, `owf_weakest`,
`enc_strongest`): the cryptographic hierarchy is order-isomorphic to `Fin 4`.

## Results Summary

| Theorem | Statement | Axioms |
|---|---|---|
| `exists_weakInverse` | every `f` over nonempty `α` has a weak inverse | standard |
| `not_infoTheoreticOneWay` | no `f` is information-theoretically one-way | standard |
| `weakInverse_inverts_all` | a weak inverter succeeds on all `\|α\|` inputs | standard |
| `exact_inversions_le_image` | any inverter exactly recovers `≤ \|Im f\|` inputs | standard |
| `invFun_exact_inversions` | `invFun f` attains the optimum `\|Im f\|` | standard |
| `rank_injective`, `level_total`, `owf_weakest`, `enc_strongest` | hierarchy is a total order with extrema | none / standard |

All main results compile with `sorry = 0` and depend only on `propext`,
`Classical.choice`, `Quot.sound` (the order results use no axioms at all).

## Research Directions

### 1. Exact-inversion capacity equals domain size minus collision deficit

Sharpen `exact_inversions_le_image` to an exact identity for *the* optimal inverter:
the maximal exact-inversion count over all `g` equals `|Im f| = |α| − (collision
deficit)`, where the deficit is `∑_{y} (|fiber y| − 1)` over the image. The key
insight is that `invFun_exact_inversions` already names the optimum `|Im f|`, so the
only missing piece is the algebraic identity `|α| = ∑_{y ∈ Im f} |fiber f y|`, which is
exactly `fiber_sum_eq_card` from `HardnessHierarchy`; combining them turns the
inversion optimum into a *collision invariant*. Why now? Both halves —
`invFun_exact_inversions` (this cycle) and `fiber_sum_eq_card` (catalog) — are already
formalized, so the bridge is a short, falsifiable composition rather than new theory.

### 2. Information-theoretic impossibility is monotone along the hierarchy

Conjecture: the impossibility of information-theoretic security propagates *upward*
through 
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
