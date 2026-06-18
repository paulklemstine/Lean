
## PHASE B: PACKAGING ONLY — COMMUNICATING THE MATH

Phase A of this cycle has already done the math. Lean 4 files have
been produced with 3-5 world-class theorems. Your ONLY job in
Phase B is to **package this work for human readers**.

### DELIVERABLES (strict — only this):
1. **ARTICLE.md** — Standalone popular-science article (1500-3000 words).
   Write about IDEAS, not formal verification. No mentions of Lean or
   proof assistants. Vivid prose, narrative arc, real-world connections.
   Reference the specific theorems proved in Phase A using @file references.
2. **RESEARCH_PAPER.md** — In-depth research paper (3000-8000 words).
   Abstract, definitions, main results (with proof sketches — NOT
   full Lean), algorithms, applications, discussion, future work,
   references to catalog results. Use @file references for theorems.
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
    {"name": "descriptive_name", "description": "What this demo shows", "code": "# full Python source..."}
  ],
  "algorithms": [
    {"name": "descriptive_name", "pseudocode": "Brief description", "code": "# full Python source..."}
  ],
  "visualizations": [
    {"name": "descriptive_name", "description": "What this visualizes", "code": "# standalone Python script that generates a visualization..."}
  ],
  "interactive_demos": [
    {"title": "Interactive Widget Title", "description": "What users can explore", "html": "<!DOCTYPE html><html>...</html>"}
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
Use the @file references above to point readers to specific theorems.


## Concept

**Title**: P vs NP Problem
**Domain**: Logic
**Mathematical framing**: Prove or disprove that P = NP. Formalize known barriers: relativization, natural proofs, algebrization. Explore circuit complexity lower bounds, proof complexity, and connections to cryptographic hardness assumptions.
Research domain: Logic
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Bridges/IRVStability.lean
/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# GL3 Tropical Satake Certified Robustness for IRV Classifiers

This file formalizes a robustness theory for deterministic, tie-free
instant-runoff / sequential-elimination classifiers built from multiclass
tropical score maps.

## Main results

* `roundLoser_eq_of_strict_min` — uniqueness of the minimizer on a finite set
* `gap_preserved_under_perturbation` — the one-round perturbation lemma
* `eliminationOrderOn_stable` — elimination-order stability under bounded perturbation
* `irvWinnerOn_stable` — winner stability under bounded perturbation
* `irvWinner_certified_robust` — the full tropical/Lipschitz robustness corollary

## Proof architecture

The core theorem proceeds by induction on the cardinality of the active
candidate set. At each round, the gap certificate ensures the current loser
has score at least γ below every other active candidate. A uniform
perturbation of size ≤ ε shifts each score by at most ε, so the gap shrinks
by at most 2ε. When 2ε < γ, the same candidate remains the unique loser,
and the induction carries through the remaining rounds.
-/

import Mathlib

namespace IRV

open Finset

/-! ## Part 1: Core Definitions -/

/-- Pairwise distinct scores on a candidate set. -/
def PairwiseDistinctOn {m : ℕ} (S : Finset (Fin m)) (v : Fin m → ℝ) : Prop :=
  ∀ ⦃i⦄, i ∈ S → ∀ ⦃j⦄, j ∈ S → i ≠ j → v i ≠ v j

/-- Gap certificate: `i` is in `S` and every other element of `S` has
    score at least `γ` above `v i`. -/
def HasGapAtLeast {m : ℕ} (S : Finset (Fin m)) (v : Fin m → ℝ)
    (i : Fin m) (γ : ℝ) : Prop :=
  i ∈ S ∧ ∀ j ∈ S, j ≠ i → v i + γ ≤ v j

/-- The round loser: the element of `S` minimizing `v`, chosen via `Classical.choose`
    from the existence of a minimizer on a nonempty finite set. -/
noncomputable def roundLoser {m : ℕ} (S : Finset (Fin m)) (hS : S.Nonempty)
    (v : Fin m → ℝ) : Fin m :=
  (S.exists_min_image v hS).choose

/-! ## Part 2: Properties of `roundLoser` -/

lemma roundLoser_mem {m : ℕ} (S : Finset (Fin m)) (hS : S.Nonempty)
    (v : Fin m → ℝ) : roundLoser S hS v ∈ S :=
  (S.exists_min_image v hS).choose_spec.1

lemma roundLoser_le {m : ℕ} (S : Finset (Fin m)) (hS : S.Nonempty)
    (v : Fin m → ℝ) : ∀ j ∈ S, v (roundLoser S hS v) ≤ v j :=
  (S.exists_min_image v hS).choose_spec.2

/-
If `i ∈ S` is strictly below every other element of `S` under `v`,
    then `roundLoser S hS v = i`.
-/
lemma roundLoser_eq_of_strict_min {m : ℕ} {S : Finset (Fin m)} {hS : S.Nonempty}
    {v : Fin m → ℝ} {i : Fin m}
    (hi : i ∈ S) (hmin : ∀ j ∈ S, j ≠ i → v i < v j) :
    roundLoser S hS v = i := by
  -- Since `roundLoser S hS v` is in `S` and `v i < v j` for all `j ∈ S \ {i}`, it must be that `roundLoser S hS v = i`.
  have h_unique_min : ∀ j ∈ S, v j < v (roundLoser S hS v) → False := by
    exact fun j hj => not_lt_of_ge ( roundLoser_le S hS v j hj );
  exact Classical.not_not.1 fun h => h_unique_min i hi <| hmin _ ( roundLoser_mem _ hS _ ) h

/-! ## Part 3: Recursive Elimination -/

private lemma erase_nonempty_of_card_gt_one {m : ℕ} {S : Finset (Fin m)}
    {a : Fin m} (ha : a ∈ S) (hcard : ¬ S.card ≤ 1) :
    (S.erase a).Nonempty := by
  -- Since S has more than one element, removing one element a from S leaves a set with at least one element.
  have h_card_erase : (S.erase a).card ≥ 1 := by
    grind +locals;
  -- Since the cardinality of S.erase a is at least 1, the set must be nonempty.
  apply Finset.card_pos.mp h_card_erase

private lemma erase_card_lt {m : ℕ} {S : Finset (Fin m)}
    {a : Fin m} (ha : a ∈ S) :
    (S.erase a).card < S.card := by
  grind +locals

/-- Recursive elimination order on active set `S`: produces the list
    `[first_eliminated, second_eliminated, ..., winner]`. -/
noncomputable def eliminationOrderOn {m : ℕ}
    (S : Finset (Fin m)) (hS : S.Nonempty) (v : Fin m → ℝ) : List (Fin m) :=
  if hcard : S.card ≤ 1 then
    [S.min' hS]
  else
    let i := roundLoser S hS v
    have hi : i ∈ S := roundLoser_mem S hS v
    have hS' : (S.erase i).Nonempty := erase_nonempty_of_card_gt_one hi hcard
    have : (S.erase i).card < S.card := erase_card_lt hi
    i :: eliminationOrderOn (S.erase i) hS' v
termination_by S.card

/-- The IRV winner on active set `S`: the last candidate surviving
    sequential elimination by minimum score. -/
noncomputable def irvWinnerOn {m : ℕ}
    (S : Finset (Fin m)) (hS : S.Nonempty) (v : Fin m → ℝ) : Fin m :=
  if hcard : S.card ≤ 1 then
    S.min' hS
  else
    let i := roundLoser S hS v
    have hi : i ∈ S := roundLoser_mem S hS v
    have hS' : (S.erase i).Nonempty := erase_nonempty_of_card_gt_one hi hcard
    have : (S.erase i).card < S.card := erase_card_lt hi
    irvWinnerOn (S.erase i) hS' v
termination_by S.card

/-- The IRV winner on all candidates. -/
noncomputable def irvWinner {m : ℕ} [NeZero m] (v : Fin m → ℝ) : Fin m :=
  irvWinnerOn Finset.univ Finset.univ_nonempty v

/-- Recursive gap certificate: at every round of the elimination of `v` on `S`,
    the current loser has gap at least `γ` to every other active candidate. -/
noncomputable def EliminationGapCertified {m : ℕ}
    (S : Finset (Fin m)) (hS : S.Nonempty) (v : Fin m → ℝ) (γ : ℝ) : Prop :=
  if hcard : S.card ≤ 1 then
    True
  else
    let i := roundLoser S hS v
    have hi : i ∈ S := roundLoser_mem S hS v
    have hS' : (S.erase i).Nonempty := erase_nonempty_of_card_gt_one hi hcard
    have : (S.erase i).card < S.card := erase_card_lt hi
    HasGapAtLeast S v i γ ∧ EliminationGapCertified (S.erase i) hS' v γ
termination_by S.card

/-! ## Part 4: One-Round Perturbation Lemma -/

/-
The algebraic heart: if `i` has gap `γ` in `S` under `v`, and `v'` is
    within `ε` of `v` coordinatewise, then `i` still has gap `γ - 2*ε`
    in `S` under `v'`.
-/
lemma gap_preserved_under_perturbation {m : ℕ}
    {S : Finset (Fin m)} {v v' : Fin m → ℝ}
    {i : Fin m} {γ ε : ℝ}
    (hgap : HasGapAtLeast S v i γ)
    (hclose : ∀ k, |v' k - v k| ≤ ε) :
    ∀ j ∈ S, j ≠ i → v' i + (γ - 2 * ε) ≤ v' j := by
  exact fun j hj hij => by linarith [ abs_le.mp ( hclose i ), abs_le.mp ( hclose j ), hgap.2 j hj hij ] ;

/-
From a preserved positive gap, the same candidate is the strict minimizer.
-/
lemma strict_min_of_gap {m : ℕ}
    {S : Finset (Fin m)} {v : Fin m → ℝ}
    {i : Fin m} {δ : ℝ}
    (_hi : i ∈ S) (hδ : 0 < δ)
    (hsep : ∀ j ∈ S, j ≠ i → v i + δ ≤ v j) :
    ∀ j ∈ S, j ≠ i → v i < v j := by
  exact fun j hj hij => lt_of_lt_of_le ( lt_add_of_pos_right _ hδ ) ( hsep j hj hij )

/-! ## Part 5: Main Stability Theorem -/

/-
**Elimination-order stability theorem.** If the elimination of `v` on `S`
    is gap-certified with parameter `γ`, and `v'` is within `ε` of `v`
    coordinatewise with `2ε < γ`, then the elimination order of `v'` on `S`
    equals that of `v`.
-/
theorem eliminationOrderOn_stable {m : ℕ}
    {v v' : Fin m → ℝ}
    (S : Finset (Fin m)) (hS : S.Nonempty)
    {ε γ : ℝ}
    (hcert : EliminationGapCertified S hS v γ)
    (hε : 0 ≤ ε)
    (hgap : 2 * ε < γ)
    (hclose : ∀ i, |v' i - v i| ≤ ε) :
    eliminationOrderOn S hS v' = eliminationOrderOn S hS v := by
  nontriviality;
  -- Apply the induction hypothesis to the smaller set S.erase i.
  have ih : ∀ (S : Finset (Fin m)) (hS : S.Nonempty), S.card < Finset.card S + 1 → EliminationGapCertified S hS v γ → 2 * ε < γ → (∀ i, |v' i - v i| ≤ ε) → eliminationOrderOn S hS v' = eliminationOrderOn S hS v := by
    intros S hS hcard hcert hgap hclose;
    induction' n : Finset.card S using Nat.strong_induction_on with n ih generalizing S hS;
    unfold eliminationOrderOn;
    grind +locals;
  exact ih S hS ( Nat.lt_succ_self _ ) hcert hgap hclose

/-! ## Part 6: Winner Stability -/

/-
**Winner stability theorem.** Under the same hypotheses as
    `eliminationOrderOn_stable`, the IRV winner is preserved.
-/
theorem irvWinnerOn_stable {m : ℕ}
    {v v' : Fin m → ℝ}
    (S : Finset (Fin m))
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: P vs NP Structural Foundations

## 1. Formalize the Karchmer-Wigderson Connection Between Communication and Circuit Complexity

The Karchmer-Wigderson theorem establishes that the circuit depth of a Boolean function f equals the communication complexity of a related two-party problem: Alice gets an input where f(x) = 1, Bob gets one where f(y) = 0, and they must find a coordinate where x and y differ. Our `RectangleCover` and `CombRect` infrastructure provides the combinatorial foundation.

The key insight is that our `rectangle_cover_lower_bound` theorem, combined with a formalization of protocol trees as binary trees whose leaves are monochromatic rectangles, would yield a direct proof that CC(f_KW) = depth(f). This would connect our communication complexity lower bounds directly to circuit depth lower bounds.

Why now? The rectangle partition infrastructure is already in place, and the Karchmer-Wigderson reduction is essentially a structural bijection between protocol transcripts and circuit paths. The proof is purely combinatorial and doesn't require any analytic machinery.

## 2. Formalize Razborov's Approximation Method for Monotone Circuit Lower Bounds

Razborov's 1985 proof that the clique function requires superpolynomial monotone circuits uses an "approximation method" where each gate in a monotone circuit is replaced by a simpler approximating function. Our `BoolCircuit.isMonotone` predicate and `monotone_circuit_preserves_order` theorem (in CircuitComplexityBarriers.lean) provide the starting point.

The key insight is that the approximation method works by induction on circuit structure: each AND/OR gate introduces controlled error that accumulates multiplicatively through the circuit. Formalizing this requires defining sunflower systems and showing that the error from approximating k-cliques grows faster than any polynomial number of gates can compensate.

Why now? The monotone circuit formalization and order-preservation theorem already exist. The remaining work is the approximation functions and the combinatorial counting of sunflowers, both of which are self-contained and don't require external analytic tools.

## 3. Prove the Polynomial Hierarchy Collapse Consequence for NP ∩ co-NP

Our `complement_inter_implies_union` and `hierarchy_collapse` theorems establish that Boolean closure propagates upward through hierarchies. A natural next step is to formalize the specific consequence: if NP = co-NP, then the polynomial hierarchy collapses to its first level (PH = NP).

The key insight is that our abstract `ComplexityHierarchy` can be instantiated with Σ_k^P classes, and the "stable" hypothesis in `hierarchy_collapse` can be derived from the alternating quantifier characterization of PH levels. The collapse NP = co-NP means Σ_1^P = Π_1^P, which by Meyer's theorem propagates upward.

Why now? The hierarchy collapse machinery is proved and ready to instantiate. The missing piece is connecting the abstract hierarch
```

## Your task

Produce the deliverables listed above. Reference the specific theorems and
results in the Lean code by their @file path and statement. The Lean file is
the source of truth — your prose must accurately explain it.

ARTICLE.md: write a popular-science narrative that makes the key idea accessible.
RESEARCH_PAPER.md: write the formal paper with abstract, definitions, results.
demo.py: write numerical examples that demonstrate the results.
PACKAGE.json: bundle everything into a single JSON with ALL fields populated.
Make sure demos, algorithms, visualizations, and interactive_demos are arrays
of objects (not placeholder strings). Include future directions from Phase A
in the future_directions field.

Be vivid, be precise, be world-class. The math has already been done — now
make it beautiful to read.
