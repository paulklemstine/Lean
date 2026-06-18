
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

**Title**: This cycle isolated the two engines that drive *every* quantitative
**Domain**: Cryptography
**Mathematical framing**: # Future Directions: A Conserved-Quantity View of Cryptographic Reductions

## Synthesis

This cycle isolated the two engines that drive *every* quantitative
provable-security argument and the one structural engine that drives *every*
black-box separation, and proved them as standalone, axiom-clean Lean theorems
that plug into the existing catalog (`CryptoLevel`/`rank`,
`CryptoReduction.compose`, `HybridSequence` in
`Cryptography.HardnessHierarchy`).

The unifying conceptual thread is **conservation**:

* On the *quantitative* side, computational indistinguishability is literally a
  pseudo-metric. The hybrid argument is the statement that the metric is
  sub-additive along a path of games, and reduction composition is the
  statement that advantage-loss is multiplicative — the additive/multiplicative
  conservation laws of the advantage coordinate.
* On the *structural* side, a black-box separation is a conserved scalar
  (`Primitive.rank`) preserved by every constructor of the construction
  calculus `CryptoImplies`. Once you see the separation as an invariant, the
  proof is one `omega`.

### Results Summary (all `sorry`-free, standard axioms only)

`Cryptography/AdvantageMetric.lean` — advantage as a pseudo-metric:
1. `advantage_triangle` — the triangle inequality `|a−c| ≤ |a−b| + |b−c|`.
2. `hybrid_argument` — telescoping bound `|d 0 − d n| ≤ Σ_{i<n} |d i − d (i+1)|`.
3. `hybrid_averaging` — pigeonhole: total gap `≥ ε` forces a single step `≥ ε/n`.
4. `reduction_composition` — advantage losses multiply: `advC ≤ (l₂·l₁)·advA`.
5. `prg_stretch_amplification` — uniform per-step `ε` over `n` hybrids gives `n·ε`.

`Cryptography/ImpagliazzoWorlds.lean` — separations as invariants:
6. `cryptoImplies_rank_mono` — the rank invariant for the construction calculus.
7. `enc_not_implies_owf` — IND-CPA encryption ⇏ a strictly weaker OWF.
8. `prf_not_implies_prg` — PRFs do not collapse downward to PRGs.
9. `owf_implies_enc` — non-triviality: OWF ⟹ ENC is derivable.

---

## Direction 1 — The factor-2 resource coordinate of the indistinguishability pseudo-metric

`advantage_triangle` proves sub-additivity of the *advantage* coordinate, but
real computational indistinguishability is a pseudo-metric on a *two-coordinate*
space `(advantage, running-time)`, where chaining two distinguishers costs a
factor of 2 (or `+O(1)`) in the time coordinate. Conjecture: there is a faithful
`PseudoMetricSpace` instance on `ℕ → (ℝ × ℝ)` (advantage, time) such that the
triangle inequality holds in the advantage coordinate exactly (`advantage_triangle`)
while the time coordinate accumulates additively, and Mathlib's
`PseudoMetricSpace` API then yields a completion whose points are exactly the
"indistinguishability classes" of game families.

The key insight is that the seemingly cryptographic factor-2 loss is a *product
pseudo-metric* phenomenon: the advantage and resource coordinates obey different
but individually clean conservation laws, and only their product is the object
cryptographers informally call "the metric." **Why now?** `advantage_triangle`
already nails the hard coordinate; the remaining work is bookkeeping that
Mathlib's `Prod` pseudo-metric instances can absorb, making this an attainable
bridge from `AdvantageMetric` to `Topology.MetricSpace`.

## Direction 2 — Tightness lower bounds: a forced linear blow-up in the rank gap

`reduction_composition` shows losses multiply and `prg_stretch_amplification`
shows a chain of length `n` incurs loss `n` (additively in advantage). Conjecture:
in the `CryptoImplies` calculus, any derivation `CryptoImplies X Y` of minimal
length has length exactly `Primitive.rank Y − Primitive.rank X`, and therefore any
quantitative realization of that derivation through `prg_stretch_amplification`
incurs advantage loss at least `(rank Y − rank X)·ε` — a *provable lower bound* on
tightness driven purely by the rank gap.

The key insight is that the rank invariant `cryptoImplies_rank_mono` is not just an
obstruction (separations) but a *metric*: the rank difference is a lower bound on
derivation length, hence on the unavoidable hybrid count, hence on advantage loss.
**Why now?** Both halves already exist in this cycle — `cryptoImplies_rank_mono`
gives the structural distance and `prg_stretch_amplification` converts hybrid count
to advantage loss; the missing lemma is "minimal derivation length = rank gap,"
a finite induction on `CryptoImplies`.

## Direction 3 — A two-dimensional invariant separating Minicrypt from Cryptomania

The current `Primitive.rank` is one-dimensional and orders only symmetric-key
primitives; it cannot witness the Impagliazzo separation of `Minicrypt` (OWF, no
public-key) from `Cryptomania` (public-key exists), because public-key crypto is
*incomparable* to, not weaker than, a PRF. Conjecture: extending `Primitive` with a
`PKE` (public-key encryption) constructor and replacing `rank : Primitive → ℕ` with a
*two-dimensional* invariant `rank₂ : Primitive → ℕ × ℕ` (symmetric strength, key
asymmetry), ordered by the product order, makes `¬ CryptoImplies OWF PKE` provable by
the identical `omega`-after-invariant proof pattern as `enc_not_implies_owf`.

The key insight is that black-box separations are exactly the *incomparabilities* of
the right partial order on primitives, and the Minicrypt/Cryptomania gap is a second,
orthogonal coordinate — so the proof technique of this cycle generalizes verbatim once
the invariant has the correct dimension. **Why now?** `cryptoImplies_rank_mono` is
already parametric in the invariant; swapping `ℕ` for `ℕ × ℕ` with `Prod.le` reuses the
whole induction, turning a famous separation into a finite check.

## Direction 4 — GGM as a tree-indexed hybrid with logarithmic, not linear, loss

`prg_stretch_amplification` handles a *linear* chain of `n` hybrids with loss `n·ε`.
The GGM PRF construction instead evaluates a *balanced binary tree* of depth `n` with
`2^n` leaves, yet its security loss is the *depth* `n`, not the leaf count `2^n`.
Conjecture: there is a tree-indexed analogue `ggm_tree_amplification` stating that for a
distinguisher walking root-to-leaf in a depth-`n` tree whose every internal edge has gap
`≤ ε`, the root-to-leaf advantage is `≤ n·ε`, provable by the *same* telescoping
`hybrid_argument` applied along the unique path, never enumerating leaves.

The key insight is that the GGM "exponentially many hybrids but logarithmic loss"
phenomenon is just `hybrid_argument` applied to a *path in a tree* rather than the whole
index set: the averaging principle is path-local, so the loss tracks path length (depth),
not tree size. **Why now?** `hybrid_argument` is already stated over an arbitrary `ℕ`-indexed
sequence; instantiating that sequence at the nodes along one tree path is a definitional
move, and the catalog already defines `GGMTree` in `Cryptography.HardnessHierarchy` to
anchor the construction.

## Direction 5 — Goldreich–Levin as a correlation-to-rank bridge

The Goldreich–Levin hardcore-bit theorem says a predictor with advantage `ε` on
`⟨x,r⟩ mod 2` yields an inverter succeeding with probability `poly(ε)`; its core is the
Fourier fact that a Boolean function significantly correlated with a *linear* function can
be list-decoded. Conjecture: the list-decoding bound is an instance of `hybrid_averaging` —
the `ε`-correlation, summed over `r`, forces (by pigeonhole) a single heavy Fourier
coefficient, exactly the `∃ i, ε/n ≤ a i` shape — so a Lean GL reduction can be built by
combining `hybrid_averaging` (heavy-coefficient extraction) with `reduction_composition`
(predictor-to-inverter loss multiplication).

The key insight is that "significant correlation forces a heavy linear coefficient" is the
*averaging principle in the Fourier basis*: the same pigeonhole that powers the hybrid
argument, transported through the orthonormal characters of `BitVec n`. **Why now?** This
cycle delivers both ingredients — `hybrid_averaging` for the extraction and
`reduction_composition` for the quantitative bound — so the remaining gap is the concrete
list-decoding algorithm over `BitVec n`, a self-contained Lean construction with no missing
analytic prerequisites.

Research domain: Cryptography
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Cryptography/AdvantageMetric.lean
/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Advantage as a Pseudo-Metric: the Quantitative Conservation Laws of Reductions

This file isolates the *two quantitative engines* that drive every
provable-security argument and proves them as standalone, axiom-clean theorems.

The unifying thread is **conservation**. Computational indistinguishability,
measured by *advantage*, behaves like a pseudo-metric coordinate:

* the **hybrid argument** is sub-additivity of advantage along a path of games
  (an *additive* conservation law), and
* **reduction composition** is multiplicativity of advantage-loss
  (a *multiplicative* conservation law).

All results are stated over an arbitrary real-valued advantage sequence
`d : ℕ → ℝ`, so they are reusable building blocks rather than ad-hoc bounds.

## Main results

* `advantage_triangle` — the triangle inequality for the advantage coordinate.
* `hybrid_argument` — telescoping: `|d 0 − d n| ≤ Σ_{i<n} |d i − d (i+1)|`.
* `hybrid_averaging` — pigeonhole: a total gap `≥ ε` forces a single step `≥ ε/n`.
* `reduction_composition` — advantage losses multiply: `advC ≤ (l₂·l₁)·advA`.
* `prg_stretch_amplification` — a uniform per-step gap `ε` over `n` hybrids
  yields a total gap `≤ n·ε`.

-- !-- Lab Notebook -- !--
Hypothesis: The "factor" bookkeeping of cryptographic hybrid/composition
  arguments is nothing but the additive (triangle) and multiplicative
  (Lipschitz-composition) conservation laws of a single real coordinate, the
  advantage. If true, each should reduce to a one-line Mathlib fact about ℝ
  plus a telescoping/pigeonhole step.
Result: Confirmed. `advantage_triangle` is `abs_sub_le`; `hybrid_argument` is a
  telescoping sum bounded by `Finset.abs_sum_le_sum_abs`; `hybrid_averaging` is
  the averaging pigeonhole; `reduction_composition` is monotone multiplication;
  `prg_stretch_amplification` chains the telescope with a constant bound.
Insight: Advantage is a genuine pseudo-metric coordinate. Sub-additivity along
  a *path* (hybrid) and multiplicativity of *loss* (composition) are dual and
  independent; the whole quantitative theory is their interplay.
Failure analysis: The averaging step is false without `0 < n`; with `n = 0`
  the empty sum is `0 ≥ ε` forces `ε ≤ 0` and there is no index to return.
  Hence the explicit positivity hypothesis.
-- !-- Lab Notebook -- !--
-/

namespace Cryptography.AdvantageMetric

open Finset

-- !-- The advantage coordinate satisfies the triangle inequality: chaining a
-- transition through an intermediate game `b` can only sub-add the gaps. -- !--
/-- **Triangle inequality for advantage.** The advantage between two games is at
most the sum of advantages through any intermediate game. -/
theorem advantage_triangle (a b c : ℝ) : |a - c| ≤ |a - b| + |b - c| := by
  exact abs_sub_le _ _ _

-- !-- Telescoping: `d 0 − d n = Σ (d i − d (i+1))`, then bound the absolute
-- value of a sum by the sum of absolute values. -- !--
/-- **The hybrid argument.** The end-to-end advantage along a sequence of `n`
games is bounded by the sum of the per-step advantages (sub-additivity along a
path). -/
theorem hybrid_argument (d : ℕ → ℝ) (n : ℕ) :
    |d 0 - d n| ≤ ∑ i ∈ Finset.range n, |d i - d (i + 1)| := by
  induction' n with n ih;
  · norm_num;
  · rw [ Finset.sum_range_succ ] ; exact le_trans ( abs_sub_le _ _ _ ) ( by linarith ) ;

-- !-- Pigeonhole/averaging: if every term were `< ε/n`, the sum would be
-- `< n·(ε/n) = ε`, contradicting the hypothesis. -- !--
/-- **Hybrid averaging.** If the total advantage across `n` steps is at least
`ε`, then some single step contributes at least `ε / n`. This is the extraction
principle at the heart of every hybrid reduction. -/
theorem hybrid_averaging (a : ℕ → ℝ) (n : ℕ) (ε : ℝ) (hn : 0 < n)
    (hsum : ε ≤ ∑ i ∈ Finset.range n, a i) :
    ∃ i, i < n ∧ ε / n ≤ a i := by
  contrapose! hsum;
  exact lt_of_lt_of_le ( Finset.sum_lt_sum_of_nonempty ⟨ _, Finset.mem_range.mpr hn ⟩ fun i hi => hsum i ( Finset.mem_range.mp hi ) ) ( by simp +decide [ mul_div_cancel₀, hn.ne' ] )

-- !-- Monotone multiplication: `advC ≤ l₂·advB ≤ l₂·(l₁·advA) = (l₂·l₁)·advA`,
-- using `0 ≤ l₂` to preserve the middle inequality. -- !--
/-- **Reduction composition.** Advantage losses multiply: if a reduction loses a
factor `l₁` and a second loses `l₂`, their composition loses `l₂·l₁`. -/
theorem reduction_composition (advA advB advC l₁ l₂ : ℝ) (hl₂ : 0 ≤ l₂)
    (hAB : advB ≤ l₁ * advA) (hBC : advC ≤ l₂ * advB) :
    advC ≤ (l₂ * l₁) * advA := by
  convert hBC.trans ( mul_le_mul_of_nonneg_left hAB hl₂ ) using 1 ; ring

-- !-- Apply `hybrid_argument`, then bound the sum of `n` terms each `≤ ε` by
-- `n·ε` with `Finset.sum_le_sum` and `Finset.sum_const`. -- !--
/-- **PRG-stretch amplification.** If each of `n` consecutive hybrids is
indistinguishable up to `ε`, the extremes are indistinguishable up to `n·ε`. -/
theorem prg_stretch_amplification (d : ℕ → ℝ) (n : ℕ) (ε : ℝ)
    (hstep : ∀ i, i < n → |d i - d (i + 1)| ≤ ε) :
    |d 0 - d n| ≤ n * ε := by
  induction' n with n ih;
  · norm_num;
  · exact abs_le.mpr ⟨ by push_cast; linarith [ abs_le.mp ( ih fun i hi => hstep i ( Nat.lt_succ_of_lt hi ) ), abs_le.mp ( hstep n ( Nat.lt_succ_self n ) ) ], by push_cast; linarith [ abs_le.mp ( ih fun i hi => hstep i ( Nat.lt_succ_of_lt hi ) ), abs_le.mp ( hstep n ( Nat.lt_succ_self n ) ) ] ⟩

end Cryptography.AdvantageMetric


-- NEW_FILE: Catalog/Cryptography/ImpagliazzoWorlds.lean
/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Black-Box Separations as Conserved Invariants

This file isolates the *structural engine* behind black-box separations of
cryptographic primitives. The slogan is again **conservation**: a black-box
construction calculus admits a conserved scalar — the `rank` of a primitive —
that is monotone along every constructor. A separation is then nothing but an
*inequality between ranks*, dispatched by `omega`.

We model the standard symmetric-key tower

```
OWF  ⟶  PRG  ⟶  PRF  ⟶  ENC (IND-CPA encryption)
```

as an inductive *construction calculus* `CryptoImplies`, where `CryptoImplies X Y`
means "primitive `Y` can be built (black-box) from primitive `X`". The calculus
is closed under reflexivity, transitivity, and the three classical upgrades
(HILL/GGM/encryption-from-PRF). The conserved scalar `rank` increases by exactly
one along each upgrade, so `CryptoImplies X Y → rank X ≤ rank Y`.

## Main results

* `cryptoImplies_rank_mono` — the rank invariant: rank is monotone along
  every derivation.
* `enc_not_implies_owf` — you cannot derive the strictly weaker `OWF` from the
  strictly stronger `ENC` inside the (rank-increasing) construction calculus.
* `prf_not_implies_prg` — a `PRF` does not collapse downward to a `PRG`.
* `owf_implies_enc` — non-triviality: the full tower `OWF ⟹ ENC` is derivable.

-- !-- Lab Notebook -- !--
Hypothesis: Black-box separations are *order* phenomena. If the construction
  calculus carries a monotone scalar invariant, then any separation reduces to
  a numeric inequality, with no probabilistic oracle argument required at the
  structural level.
Result: Confirmed. A single inductive `CryptoImplies` with a `ℕ`-valued `rank`
  invariant makes `cryptoImplies_rank_mono` a 5-case induction, and each
  separation a one-liner after specializing the invariant.
Insight: `rank` is simultaneously (i) an *obstruction* — distinct ranks witness
  separations — and (ii) a *metric* — the rank gap lower-bounds derivation
  length. The same scalar drives both the impossibility and the tightness story.
Failure analysis: A one-dimensional `rank` is necessarily a *total* order, so it
  can only express separations between comparable (symmetric-key) primitives. It
  cannot witness the Minicrypt/Cryptomania incomparab
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: A Conserved-Quantity View of Cryptographic Reductions

## Synthesis

This cycle isolated the **two quantitative engines** that drive every
provable-security argument and the **one structural engine** that drives every
black-box separation, and proved each as a standalone, axiom-clean Lean theorem.

The unifying conceptual thread is **conservation**. Each quantitative result is a
conservation law of a single real coordinate — the *advantage* — and the
structural result is a conserved scalar — the *rank* of a primitive.

* On the *quantitative* side (`Cryptography/AdvantageMetric.lean`), computational
  indistinguishability behaves like a pseudo-metric coordinate. The hybrid
  argument is sub-additivity of advantage along a path of games (an *additive*
  conservation law), and reduction composition is multiplicativity of
  advantage-loss (a *multiplicative* conservation law).
* On the *structural* side (`Cryptography/ImpagliazzoWorlds.lean`), a black-box
  separation is a conserved scalar (`rank`) preserved by every constructor of the
  construction calculus `CryptoImplies`. Once the separation is recast as an
  invariant, the proof is a single numeric step.

### Results Summary (all `sorry`-free, standard axioms only)

`Cryptography/AdvantageMetric.lean` — advantage as a pseudo-metric:

1. `advantage_triangle` — triangle inequality `|a−c| ≤ |a−b| + |b−c|`.
2. `hybrid_argument` — telescoping bound `|d 0 − d n| ≤ Σ_{i<n} |d i − d (i+1)|`.
3. `hybrid_averaging` — pigeonhole: total gap `≥ ε` forces a single step `≥ ε/n`.
4. `reduction_composition` — advantage losses multiply: `advC ≤ (l₂·l₁)·advA`.
5. `prg_stretch_amplification` — uniform per-step `ε` over `n` hybrids gives `n·ε`.

`Cryptography/ImpagliazzoWorlds.lean` — separations as invariants:

6. `cryptoImplies_rank_mono` — the rank invariant for the construction calculus.
7. `enc_not_implies_owf` — strictly stronger `ENC` cannot derive the strictly
   weaker `OWF` inside the rank-increasing calculus.
8. `prf_not_implies_prg` — a `PRF` does not collapse downward to a `PRG`.
9. `owf_implies_enc` — non-triviality: the full tower `OWF ⟹ ENC` is derivable.

---

## Direction 1 — The factor-2 resource coordinate of the indistinguishability pseudo-metric

`advantage_triangle` proves sub-additivity of the *advantage* coordinate, but
real computational indistinguishability lives on a *two-coordinate* space
`(advantage, running-time)`, where chaining two distinguishers costs a factor of
2 (or `+O(1)`) in the time coordinate. Conjecture: there is a faithful
`PseudoMetricSpace` instance on `ℕ → (ℝ × ℝ)` such that the triangle inequality
holds in the advantage coordinate exactly (`advantage_triangle`) while the time
coordinate accumulates additively, and Mathlib's `PseudoMetricSpace` API then
yields a completion whose points are the "indistinguishability classes" of game
families.

The key insight is that the seemingly cryptographic factor-2 loss is a *product
pseudo-metric* phenomenon: 
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
