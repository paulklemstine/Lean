
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

**Title**: Close Proofs: Proof-Complexity Holography: Geometric Duals of Formal Derivations
**Domain**: Novelty
**Mathematical framing**: Cycle 420383c4 (Q=0.422) proved 91 theorems in Applications but left 1 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: Conjecture: For every proof system in a broad class of finitely presented deductive systems (including propositional resolution and bounded-depth Frege), there exists a computable assignment from any 
Research domain: Novelty
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Logic/ProofComplexity/Holography.lean
/-
# Proof-Complexity Holography: Geometric Duals of Formal Derivations

This module unifies two strands of the catalog's proof-complexity program:

* the **proof quasi-metric** `minDerivLen` of `Logic.ProofMetric`
  (length-graded derivability `DerivOfLen`, additive composition `derivOfLen_comp`,
  the directed triangle inequality, and the chain geodesic), and
* the **Cook–Reckhow simulation preorder** of
  `Logic.ProofComplexity.SimulationPreorder` (`Simulates`, polynomial blow-ups, the
  p-degree poset), whose entire content is the statement that proof translations between
  systems are size-Lipschitz maps.

The unifying object is a **proof translation** (`Translation`): a map `φ` of atoms together
with a stretch bound `L` certifying that every *axiom step* of the source theory `T` is
realized by a `≤ L`-step derivation in the target theory `S`.  The headline is that such a
local, one-step bound *propagates holographically* to a global metric statement: the induced
map on the proof geometry is `L`-Lipschitz for `minDerivLen`.  This is precisely the abstract
geometric content of "p-simulation = bounded blow-up", now realized inside the ℕ-valued proof
metric rather than the size order.

Headline results:

* `translate_deriv` — **holographic propagation / functoriality with Lipschitz bound**: a
  translation with stretch `L` sends every length-`k` source derivation to a target
  derivation of length `≤ L * k`.  The structural engine of the file; the length-graded
  refinement, at the level of *derivations*, of Cook–Reckhow simulation.
* `minDerivLen_translate_le` — **the proof metric is `L`-Lipschitz under translation**:
  `minDerivLen S (φ a) (φ b) ≤ L * minDerivLen T a b` whenever `a ⊢ b`.  This is the
  geometric (boundary) shadow of the bulk fact `translate_deriv`.
* `translate_comp_step` — **translations compose, stretches multiply**: the order-theoretic
  heart of transitivity in the simulation preorder (`Simulates_trans`), now as a stretch
  inequality `≤ M * L`.  Reuses `translate_deriv`, exhibiting the latter as the genuine
  engine of compositionality.
* `chain_doubling_isometry` — **holographic exactness on the chain**: the doubling embedding
  `n ↦ 2n` of the chain theory multiplies proof distance by *exactly* `2`, showing the
  Lipschitz bound of `minDerivLen_translate_le` is attained (the chain is the extremal
  zero-slack geometry, sharpening `ProofMetric.minDerivLen_chain_geodesic`).

-- !-- Lab Notebook -- !--
-- Hypothesis: A *local* one-step bound (every source axiom realized by a `≤ L`-step target
--   derivation) should propagate to a *global* metric Lipschitz bound on `minDerivLen`,
--   making "proof translation" a morphism of proof geometries and exhibiting Cook–Reckhow
--   p-simulation as the special (size-order) case of a contraction in the proof metric.
-- Result: All four pillars formalize with `sorry = 0`.  `translate_deriv` is a clean
--   induction on the source derivation, accumulating stretch additively via
--   `derivOfLen_comp` (`L*n + L = L*(n+1)`).  The metric bound is `Nat.sInf_mem` (realize the
--   minimal source derivation) + `translate_deriv` + `Nat.sInf_le`.  Composition multiplies
--   stretches by feeding a single source step through `translate_deriv` of the second
--   translation.  Chain doubling is exact by `minDerivLen_chain_eq` + `omega`.
-- Insight: The one-step bound is the *bulk* data; the metric Lipschitz constant is its
--   *boundary* shadow — a discrete holography.  Compositionality of translations is not a new
--   fact but a corollary of holographic propagation, unifying `derivOfLen_comp` (metric side)
--   with `Simulates_trans` (order side) under one engine.  The chain saturates the bound, so
--   "zero proof slack" (geodesic rigidity) is exactly "the Lipschitz constant is attained".
-- Failure analysis: Inducting on the target side or trying to track exact (rather than `≤`)
--   lengths breaks because a single source axiom may have several target realizations of
--   different lengths; carrying the bound as `∃ j ≤ L*k, …` keeps the induction definitional.
--   Stretch `0` is harmless: it forces source and target endpoints to coincide along
--   derivations, consistent with `L*0 = 0`.
-- !-- end Lab Notebook -- !--
-/
import Mathlib

open Relation

namespace ProofHolography

/-! ### Mirrored base infrastructure

These declarations mirror `Logic.ProofMetric` (`ImplTheory`, `Derivable`, `chainT`,
`DerivOfLen`, `minDerivLen`, `derivOfLen_comp`, `chain_derivOfLen_iff`,
`minDerivLen_chain_eq`).  They are reproduced here verbatim so this file is self-contained;
they are *definitionally identical* to the catalog versions, so every result below extends
the proof-metric / simulation program on the very same objects. -/

/-- An **implicational theory** on atoms `α`. -/
abbrev ImplTheory (α : Type*) := α → α → Prop

/-- **Derivability**: reflexive–transitive closure of the axioms. -/
def Derivable {α : Type*} (T : ImplTheory α) : α → α → Prop := ReflTransGen T

/-- The **chain theory** on `ℕ`: axioms `k → k+1`. -/
def chainT : ImplTheory ℕ := fun a b => b = a + 1

/-- **Length-graded derivability**: `DerivOfLen T a b k` asserts a derivation of `b` from
`a` using *exactly* `k` axioms. -/
inductive DerivOfLen {α : Type*} (T : ImplTheory α) : α → α → ℕ → Prop
  | refl (a : α) : DerivOfLen T a a 0
  | tail {a b c : α} {n : ℕ} : DerivOfLen T a b n → T b c → DerivOfLen T a c (n + 1)

/-- The **minimal proof length** of `a ⊢ b` in `T`. -/
noncomputable def minDerivLen {α : Type*} (T : ImplTheory α) (a b : α) : ℕ :=
  sInf {k | DerivOfLen T a b k}

/-- **Sharp graded boundary for the chain theory**: a length-`k` derivation of `b` from `a`
exists iff `b = a + k`. -/
theorem chain_derivOfLen_iff (a b k : ℕ) :
    DerivOfLen chainT a b k ↔ b = a + k := by
  constructor
  · induction' k with k ih generalizing a b
    · rintro ⟨⟩; tauto
    · rintro ⟨c, hc⟩; grind +locals
  · intro h
    induction' k with k ih generalizing a b
    · exact h.symm ▸ DerivOfLen.refl _
    · convert DerivOfLen.tail (ih a (a + k) rfl) _ using 1
      exact h.symm ▸ rfl

/-- **Graded transitivity / additive composition** (`ProofMetric.derivOfLen_comp`):
concatenating a length-`m` derivation of `b` from `a` with a length-`n` derivation of `c`
from `b` yields a length-`(m + n)` derivation of `c` from `a`. -/
theorem derivOfLen_comp {α : Type*} {T : ImplTheory α} {a b c : α} {m n : ℕ}
    (h₁ : DerivOfLen T a b m) (h₂ : DerivOfLen T b c n) :
    DerivOfLen T a c (m + n) := by
  induction' h₂ with b' c' n' h₂ ih generalizing a m
  · exact h₁
  · exact DerivOfLen.tail (‹∀ {a : α} {m : ℕ}, DerivOfLen T a b m → DerivOfLen T a b' (m + n')› h₁) ih

/-- On the chain theory the proof metric is exactly the index gap
(`ProofMetric.minDerivLen_chain_eq`): `minDerivLen chainT a b = b - a` for `a ≤ b`. -/
theorem minDerivLen_chain_eq (a b : ℕ) (h : a ≤ b) :
    minDerivLen chainT a b = b - a := by
  refine le_antisymm (Nat.sInf_le ?_) (le_csInf ?_ ?_)
  · grind +suggestions
  · exact ⟨b - a, by simpa [h] using (chain_derivOfLen_iff a b (b - a)).2 (by omega)⟩
  · intro k hk; have := chain_derivOfLen_iff a b k; aesop

/-! ### A single axiom step as a length-`1` derivation -/

/-
!-- One axiom application is a length-`1` derivation: `tail` onto the empty `refl`. -- !--

A single axiom step `T a b` yields a length-`1` derivation of `b` from `a`.
-/
theorem derivOfLen_one_of_step {α : Type*} {T : ImplTheory α} {a b : α}
    (h : T a b) : DerivOfLen T a b 1 := by
  exact DerivOfLen.tail ( DerivOfLen.refl a ) h

/-! ### Proof translations: morphisms of proof geometries -/

/-- A **proof translation** from theory `T` (on atoms `α`) to theory `S` (on atoms `β`):
a map `map` on atoms together with a *stretch* bound `stretch` certifying that every axiom
step of `T` is realized by a derivation of length `≤ stretch` in `S`.  This is the
length-graded, system-to-system morphism abstracting Cook–Reckhow p-
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — Proof-Complexity Holography

## Synthesis

This cycle isolates the *geometric* content shared by two previously separate strands of the
catalog's proof-complexity program:

* the **proof quasi-metric** `minDerivLen` of `Logic.ProofMetric` (length-graded derivability
  `DerivOfLen`, additive composition `derivOfLen_comp`, the directed triangle inequality, and
  the chain geodesic `minDerivLen_chain_geodesic`); and
* the **Cook–Reckhow simulation preorder** of `Logic.ProofComplexity.SimulationPreorder`
  (`Simulates`, polynomial blow-ups, `Simulates_trans`, the p-degree `Setoid`).

The bridging object is a **proof translation** (`Translation`): a map of atoms plus a *local*
one-step stretch certificate. The central discovery (`Catalog/Logic/ProofComplexity/Holography.lean`)
is that this purely local datum propagates *holographically* to a *global* metric statement:

* `translate_deriv` — a stretch-`L` translation sends every length-`k` derivation to one of
  length `≤ L·k` (the bulk engine);
* `minDerivLen_translate_le` — hence the proof metric is `L`-Lipschitz under translation (the
  boundary shadow), which is exactly Cook–Reckhow p-simulation read inside the ℕ-valued metric;
* `translate_comp_step` — translation composition / stretch multiplication, derived *from*
  `translate_deriv` rather than reproved, unifying `derivOfLen_comp` with `Simulates_trans`;
* `chain_doubling_isometry` — on the chain the Lipschitz bound is *attained exactly* (doubling
  scales distance by exactly 2), so geodesic rigidity ("zero proof slack") = "Lipschitz constant
  attained".

## Results Summary

Four sorry-free theorems (plus the helper `derivOfLen_one_of_step`), all depending only on
`propext, Classical.choice, Quot.sound`. The file is self-contained (mirrors the catalog
infrastructure verbatim, as `ProofMetric.lean` does) and so extends the existing program on
definitionally identical objects.

## Research Directions

### 1. Translations form a category; the proof metric is a (lax) functor to `(ℕ, ≤, ·)`

Promote `Translation` to a genuine category: objects are implicational theories, morphisms are
translations, with `identity` (stretch 1) and `comp` (stretch `M·L`, justified by
`translate_comp_step`). Then `minDerivLen_translate_le` says the assignment
`(T, a, b) ↦ minDerivLen T a b` is a lax functor into the multiplicative monoid `(ℕ, ·)` acting
on the metric. **The key insight is** that compositionality of proof translation is not an axiom
but a *theorem* about derivation length, so the whole simulation preorder is the shadow of a
category whose hom-data is a single natural number (the stretch). **Why now?** `translate_comp_step`
already supplies the associativity-compatible composition law; only the bookkeeping of an
identity/associativity proof remains, and Mathlib's `CategoryTheory` scaffolding makes this
mechanical. Falsifiable: if stretches did *not* multiply (e.g. only added), the functor law would
fail and no `CategoryTheory.Funct
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
