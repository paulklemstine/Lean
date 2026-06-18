
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

**Title**: The Hodge filtration F^p on the complexification of a pure Hodge structure is th
**Domain**: Algebra
**Mathematical framing**: # Future Directions: Hodge Structure Theory in Lean 4

## 1. Hodge Filtration and Degeneration of the Hodge-to-de Rham Spectral Sequence

The Hodge filtration F^p on the complexification of a pure Hodge structure is the decreasing filtration defined by F^p = ⊕_{i≥p} H^{i,k-i}. A natural next step is to formalize the Hodge filtration as a `Submodule` tower and prove that the filtration determines the decomposition when the "opposition" condition F^p ⊕ F̄^{k-p+1} = V_ℂ holds. This would give the first formalized proof that the Hodge filtration is a complete invariant of a pure Hodge structure.

The key insight is that the Hodge filtration and its conjugate together reconstruct the bigrading — this is the essence of the "opposition" or "Hodge symmetry" condition, and formalizing it would connect the linear-algebraic theory to the geometric fact that the Hodge-to-de Rham spectral sequence degenerates at E₁ for compact Kähler manifolds.

Why now? The `HodgeDiamond` structure and `PureHodgeStructure` definitions are in place, and Mathlib's lattice theory on `Submodule` provides all the infrastructure needed for decreasing filtrations. The main challenge is managing the interplay between ℂ-subspaces and complex conjugation, which can be modeled via an involution on the ambient module.

## 2. Künneth Formula for Hodge Diamonds and Product Stability of the Hodge Conjecture

For compact Kähler manifolds X and Y, the Hodge numbers of the product satisfy h^{p,q}(X × Y) = Σ_{a+c=p, b+d=q} h^{a,b}(X) · h^{c,d}(Y). This "convolution" formula on Hodge diamonds should be formalizable as an operation `HodgeDiamond n → HodgeDiamond m → HodgeDiamond (n + m)` with a proof that the product Hodge diamond satisfies Hodge symmetry and Serre duality.

The key insight is that the product formula, combined with our existing `DirectSumHodgeData`, would give a complete proof that if the Hodge conjecture holds for X and Y separately, then it holds for product-type classes on X × Y. This is the content of the "Künneth component" of the Hodge conjecture, which reduces the general case to "primitive" classes.

Why now? The `HodgeDiamond` and `DirectSumHodgeData` structures are defined and the projective space example provides a test case: ℙⁿ × ℙᵐ should give the Segre variety's Hodge diamond, which can be verified computationally.

## 3. Lefschetz (1,1) Theorem: From Abstract to Geometric

Our `hodgeClasses_eq_top_of_vanishing` proves the Hodge conjecture when H^{2,0} = 0. The natural strengthening is the full Lefschetz (1,1) theorem: every rational (1,1)-class on a smooth projective variety is algebraic. This requires connecting the abstract Hodge structure framework to the Chern class map c₁ : Pic(X) → H²(X, ℤ) ∩ H^{1,1}(X).

The key insight is that the proof reduces to the exponential exact sequence 0 → ℤ → 𝒪 → 𝒪* → 0 and the vanishing of H²(X, 𝒪) → H²(X, ℤ) for (1,1)-classes. Formalizing this requires sheaf cohomology on a site, which Mathlib is beginning to support via `CategoryTheory.Sheaf`.

Why now? Mathlib's category theory library now has sites, sheaves, and derived functors in a usable state. The exponential sequence is a short exact sequence of sheaves, and the connecting homomorphism gives the Chern class. This would be the first formalized proof of Lefschetz (1,1) in any proof assistant.

## 4. Hodge Index Theorem for Surfaces and Signature of the Intersection Form

For a compact complex surface, the Hodge index theorem states that the intersection form on H^{1,1}(X, ℝ) has signature (1, h^{1,1} - 1) — exactly one positive eigenvalue, given by the Kähler class. Our `PolarizedHodgeStructure` already carries a nondegenerate bilinear form Q; the next step is to formalize the signature constraint.

The key insight is that the Hodge index theorem is equivalent to the Cauchy-Schwarz inequality for the intersection form restricted to H^{1,1} ∩ H²(X, ℝ). This can be formalized as: the quadratic form Q restricted to the orthogonal complement of the Kähler class is negative definite.

Why now? Mathlib has `LinearMap.BilinForm`, `Finrank`, and the spectral theory infrastructure for proving signature results via Sylvester's law of inertia. The `hodgeClasses_isCompl_orthogonal` theorem already proves the algebraic-transcendental decomposition, providing the starting point for a signature analysis.

## 5. Mumford-Tate Groups and the Hodge Conjecture for Abelian Varieties

The Mumford-Tate group of a Hodge structure is the smallest algebraic subgroup of GL(V) whose real points contain the image of the Hodge circle homomorphism. For abelian varieties, the Hodge conjecture is equivalent to the statement that the Mumford-Tate group determines all Hodge classes (via the Tannakian formalism). Formalizing Mumford-Tate groups would open the path to the known cases of the Hodge conjecture: CM abelian varieties, abelian varieties of dimension ≤ 3, and products of elliptic curves.

The key insight is that the Mumford-Tate group can be defined purely algebraically from the Hodge structure, without reference to the underlying geometry, as the stabilizer of all Hodge tensors in the tensor algebra of V. This makes it amenable to formalization using Mathlib's algebraic group and representation theory.

Why now? The weight-2 Hodge structure and polarization infrastructure are in place. Mathlib's `AlgebraicGroup` and `RepresentationTheory` modules provide the substrate. The CM case is particularly tractable because the Mumford-Tate group is a torus, reducing the Hodge conjecture to a computation with characters.

Research domain: Algebra
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Geometry/HodgeTheory/Filtration.lean
/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# The Hodge Filtration as a Complete Invariant of a Weight-Two Hodge Structure

This file develops the **Hodge filtration / Hodge bigrading duality** for weight-two
rational Hodge structures, extending the catalog object `HodgeStructureWeightTwo`
(in `Catalog/Geometry/HodgeTheory/Defs.lean`).

Because this project's library is compiled file-by-file (each file imports only `Mathlib`),
the parent structure `HodgeStructureWeightTwo` and the embedding `complexifyEmbed` from
`Catalog/Geometry/HodgeTheory/Defs.lean` are reproduced verbatim below so that this file is
self-contained; the new content is the conjugation-aware structure and the filtration theory.

A pure Hodge structure can be described in two dual languages:

* the **decomposition** language — the bigrading `V_ℂ = H²⁰ ⊕ H¹¹ ⊕ H⁰²`;
* the **filtration** language — the decreasing *Hodge filtration*
  `F² ⊆ F¹ ⊆ F⁰ = V_ℂ` with `Fᵖ = ⊕_{i ≥ p} H^{i,2-i}`.

The central representation/duality theorem (`recover_H11`,
`filtration_determines_decomposition`) is that the filtration `F•`, *together with the
complex conjugation* coming from the real/rational structure, recovers the entire
bigrading via the **opposition** (Hodge-symmetry) formulae
`H^{p,q} = Fᵖ ∩ conj(F^q)`. Consequently the Hodge filtration is a *complete
invariant*: two Hodge structures with the same conjugation and the same filtration are
equal. This is the linear-algebraic shadow of the degeneration of the
Hodge-to-de Rham spectral sequence at `E₁`.

## Main definitions

* `HodgeStructureWeightTwoConj V` — a weight-two Hodge structure whose three pieces form
  a genuine internal direct sum and which is equipped with a conjugate-linear involution
  `conj` (complex conjugation) satisfying Hodge symmetry `conj H²⁰ = H⁰²`, `conj H¹¹ = H¹¹`.
* `HodgeStructureWeightTwoConj.F` — the decreasing Hodge filtration `F⁰ ⊇ F¹ ⊇ F²`.
* `HodgeStructureWeightTwoConj.conjMap` — the image of a subspace under conjugation.

## Main results

* `F_antitone` — `F` is a decreasing filtration.
* `conj_H02`, `conjF1_eq`, `conjF2_eq` — values of conjugation on the pieces and the
  filtration steps.
* `opposition` — the opposition relations: `F²` is complementary to `conj F¹`, and `F¹`
  is complementary to `conj F²` (`Fᵖ ⊕ conj F^{k-p+1} = V_ℂ`).
* `recover_H11` — the middle piece is reconstructed as `H¹¹ = F¹ ∩ conj F¹`.
* `filtration_determines_decomposition` — the Hodge filtration together with
  conjugation is a complete invariant of the Hodge structure.
-/

noncomputable section

open scoped TensorProduct
open Submodule

/-- The natural ℚ-linear embedding `V → ℂ ⊗[ℚ] V` sending `v ↦ 1 ⊗ v`.
(Reproduced from `Catalog/Geometry/HodgeTheory/Defs.lean`.) -/
def complexifyEmbed (V : Type*) [AddCommGroup V] [Module ℚ V] :
    V →ₗ[ℚ] (ℂ ⊗[ℚ] V) :=
  TensorProduct.mk ℚ ℂ V 1

/-- A weight-2 rational Hodge structure (reproduced from
`Catalog/Geometry/HodgeTheory/Defs.lean`): a decomposition of the complexification
`V_ℂ = H²⁰ ⊕ H¹¹ ⊕ H⁰²` whose pieces span and are pairwise independent. -/
structure HodgeStructureWeightTwo (V : Type*) [AddCommGroup V] [Module ℚ V]
    [FiniteDimensional ℚ V] where
  /-- The (2,0)-part of the Hodge decomposition -/
  H20 : Submodule ℂ (ℂ ⊗[ℚ] V)
  /-- The (1,1)-part of the Hodge decomposition -/
  H11 : Submodule ℂ (ℂ ⊗[ℚ] V)
  /-- The (0,2)-part of the Hodge decomposition -/
  H02 : Submodule ℂ (ℂ ⊗[ℚ] V)
  /-- The three parts span the entire complexification -/
  hspan : H20 ⊔ H11 ⊔ H02 = ⊤
  /-- The three parts are pairwise independent -/
  hIndep : H20 ⊓ H11 = ⊥ ∧ H20 ⊓ H02 = ⊥ ∧ H11 ⊓ H02 = ⊥

-- !-- Lab Notebook -- !--
-- Hypothesis: A weight-2 Hodge structure is determined by its Hodge filtration F•
--   together with complex conjugation, via the opposition relations H^{p,q} = Fᵖ ∩ conj(F^q).
-- Result: Proved (recover_H11, filtration_determines_decomposition). The reconstruction of
--   the middle piece H¹¹ = F¹ ⊓ conj F¹ is a pure modular-lattice identity once one knows
--   the three pieces form an internal direct sum (hdir02) and conjugation respects the bigrading.
-- Insight: The catalog object `HodgeStructureWeightTwo` only required *pairwise* trivial
--   intersection, which is strictly weaker than an internal direct sum (three lines in a plane!).
--   Reconstruction genuinely needs the direct-sum hypotheses `hdir20/hdir11/hdir02`, which is
--   exactly the geometric content that the Hodge decomposition is a direct sum.
-- Failure analysis: An earlier plan tried to derive reconstruction from `hIndep` (pairwise)
--   alone; this is false in general, so the strengthened structure was introduced.
-- !-- Lab Notebook -- !--

/-- A weight-two rational Hodge structure that forms a genuine internal direct sum and is
equipped with complex conjugation (a conjugate-linear involution on the complexification)
satisfying Hodge symmetry.

This extends `HodgeStructureWeightTwo` (which only records a spanning, pairwise-independent
triple) with:
* the genuine **direct-sum** conditions `hdir20/hdir11/hdir02` (each piece meets the join of
  the other two trivially), and
* the **conjugation** `conj`, a `starRingEnd ℂ`-semilinear involution swapping `H²⁰ ↔ H⁰²`
  and fixing `H¹¹` (Hodge symmetry `H^{p,q} = conj H^{q,p}`). -/
structure HodgeStructureWeightTwoConj (V : Type*) [AddCommGroup V] [Module ℚ V]
    [FiniteDimensional ℚ V] extends HodgeStructureWeightTwo V where
  /-- `H²⁰` meets the join of the other two pieces trivially (internal direct sum). -/
  hdir20 : H20 ⊓ (H11 ⊔ H02) = ⊥
  /-- `H¹¹` meets the join of the other two pieces trivially (internal direct sum). -/
  hdir11 : H11 ⊓ (H20 ⊔ H02) = ⊥
  /-- `H⁰²` meets the join of the other two pieces trivially (internal direct sum). -/
  hdir02 : H02 ⊓ (H20 ⊔ H11) = ⊥
  /-- Complex conjugation on the complexification: a conjugate-linear automorphism. -/
  conj : (ℂ ⊗[ℚ] V) ≃ₛₗ[starRingEnd ℂ] (ℂ ⊗[ℚ] V)
  /-- Conjugation is an involution. -/
  conj_invol : ∀ x, conj (conj x) = x
  /-- Hodge symmetry: conjugation sends the `(2,0)`-part to the `(0,2)`-part. -/
  conj_H20 : H20.map conj.toLinearMap = H02
  /-- Hodge symmetry: conjugation preserves the `(1,1)`-part. -/
  conj_H11 : H11.map conj.toLinearMap = H11

namespace HodgeStructureWeightTwoConj

variable {V : Type*} [AddCommGroup V] [Module ℚ V] [FiniteDimensional ℚ V]
variable (HC : HodgeStructureWeightTwoConj V)

/-- The image of a subspace under complex conjugation. -/
def conjMap (S : Submodule ℂ (ℂ ⊗[ℚ] V)) : Submodule ℂ (ℂ ⊗[ℚ] V) :=
  S.map HC.conj.toLinearMap

/-- The decreasing **Hodge filtration** `F⁰ = V_ℂ ⊇ F¹ = H²⁰ ⊕ H¹¹ ⊇ F² = H²⁰`.
For `p ≥ 3` we set `Fᵖ = ⊥`. -/
def F : ℕ → Submodule ℂ (ℂ ⊗[ℚ] V)
  | 0 => ⊤
  | 1 => HC.H20 ⊔ HC.H11
  | 2 => HC.H20
  | _ => ⊥

/-
!-- comment -- !--
`F` is decreasing: each step is contained in the previous one, by definition and `le_sup_left`.
!-- comment -- !--

The Hodge filtration is a decreasing (antitone) filtration.
-/
theorem F_antitone : Antitone HC.F := by
  intro n m hnm;
  induction' m with m ih generalizing n;
  · aesop;
  · rcases hnm with ( rfl | hnm );
    · rfl;
    · rcases m with ( _ | _ | _ | m ) <;> simp_all +decide [ HodgeStructureWeightTwoConj.F ]

/-
!-- comment -- !--
Apply conjugation to `conj_H20` and use the involution `conj_invol` to flip it around.
!-- comment -- !--

Hodge symmetry, conjugate form: conjugation sends the `(0,2)`-part to the `(2,0)`-part.
-/
theorem conj_H02 : HC.H02.map HC.conj.toLinearMap = HC.H20 := by
  rw [ ←HC.conj_H20 ];
  rw [ ← Submodule.map_comp ];
  convert Submodule.map_id HC.H20;
  ext; simp +decide [ HC.conj_invol ] ;

/-
!-- comment -- !--
`conj` distributes over `⊔` (`Submodule.map_sup`); then substitute `conj_H20`, `conj_H11`.
!-- comment -- !--

The conjugate of `F¹ = H²⁰ ⊕ H¹¹` is `H⁰² ⊕ H¹¹`.
-/
theorem conjF1_eq : HC.conjMap (HC.F 1) =
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: The Hodge Filtration ↔ Bigrading Duality

## Synthesis

This cycle formalized the **filtration/decomposition duality** at the heart of pure
Hodge theory, in the weight-two case. A pure Hodge structure speaks two dual
languages: the *bigrading* `V_ℂ = H²⁰ ⊕ H¹¹ ⊕ H⁰²` and the decreasing *Hodge
filtration* `F² ⊆ F¹ ⊆ F⁰ = V_ℂ`. The new file
`Catalog/Geometry/HodgeTheory/Filtration.lean` introduces
`HodgeStructureWeightTwoConj`, which extends the catalog's
`HodgeStructureWeightTwo` (`Catalog/Geometry/HodgeTheory/Defs.lean`) by promoting
its *pairwise*-independence to a genuine internal direct sum and equipping the
complexification with complex conjugation. On this object we proved:

* `F_antitone` — `F•` is a genuine decreasing filtration.
* `conj_H02`, `conjF1_eq`, `conjF2_eq` — conjugation acts on the pieces and the
  filtration steps by Hodge symmetry `H^{p,q} = conj H^{q,p}`.
* `opposition` — the *opposition relations* `Fᵖ ⊕ conj F^{k-p+1} = V_ℂ`, i.e. `F²`
  is complementary to `conj F¹` and `F¹` to `conj F²`.
* `recover_H11` — the reconstruction identity `H¹¹ = F¹ ∩ conj F¹`, the case
  `p = q = 1` of `H^{p,q} = Fᵖ ∩ conj F^q`.
* `filtration_determines_decomposition` — **the Hodge filtration together with
  conjugation is a complete invariant**: equal conjugations and equal filtrations
  force equal bigradings.
* `nonempty_of_trivial` — the theory is inhabited, so these results are not vacuous.

## Results Summary

The decisive *Insight* (logged in the Lab Notebook) is that reconstruction genuinely
requires the internal-direct-sum hypothesis, not merely the pairwise-trivial
intersection that the catalog object recorded: three lines in a plane meet pairwise
trivially yet are not independent. With the direct-sum hypothesis in place,
reconstruction of the middle piece collapses to a single application of the modular
law in the submodule lattice — a clean illustration of how a representation-theoretic
"complete invariant" statement reduces to lattice theory once the conjugation pairing
is available. All theorems depend only on `propext`, `Classical.choice`, `Quot.sound`.

## Research Directions

### 1. General-weight Hodge filtration and opposition

Generalize from weight two to an arbitrary weight `k` Hodge structure given by a
family `H : ℤ → Submodule ℂ V_ℂ` supported on `p + q = k`, with `Fᵖ = ⊕_{i ≥ p} H^{i,k-i}`.
Prove the full opposition theorem `Fᵖ ⊕ conj F^{k-p+1} = V_ℂ` and the general
reconstruction `H^{p,q} = Fᵖ ∩ conj F^q` for all `p + q = k`.
**The key insight is** that the weight-two modular-lattice computation
(`recover_H11`) is the base case of a telescoping induction on the filtration length,
where each step peels off one graded piece via `sup_inf_assoc_of_le`.
**Why now?** The weight-two proof is complete and isolates exactly the lattice lemma
and conjugation interface that the induction needs; only the bookkeeping over `ℤ`-indexed
families remains, for which Mathlib's `DirectSum.IsInternal` and `iSupIndep` 
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
