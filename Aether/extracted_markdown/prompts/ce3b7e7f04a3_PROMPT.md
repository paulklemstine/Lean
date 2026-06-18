
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
    {"name": "descriptive_name", "description": "What this demo shows", "code": "# full Python source..."}
  ],
  "algorithms": [
    {
      "name": "descriptive_name",
      "description": "Detailed in-depth explanation of the algorithm, its mathematical foundation, computational complexity, and role in the pipeline.",
      "pseudocode": "Formal, structured step-by-step pseudocode detailing the logic.",
      "code": "# full Python source with type hints..."
    }
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
State theorems inline in your article and paper — they must be
self-contained and publishable without external references.


## Concept

**Title**: Close Proofs: These directions extend `Catalog/MachineLearning/RademacherSpectral.le
**Domain**: Novelty
**Mathematical framing**: Cycle 57276ea9 (Q=0.421) proved 491 theorems in Novelty but left 9 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: # Future Directions — Rademacher Complexity of Neural Networks

These directions extend `Catalog/MachineLearning/RademacherSpectral.lean`, which
formalizes the *empirical* Rademacher complexity as an 
Research domain: Novelty
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/MachineLearning/RademacherSpectral.lean
/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.

# Empirical Rademacher Complexity of Finite Hypothesis Classes

This file formalizes the **empirical Rademacher complexity** of a finite hypothesis
class, represented by the *behavior of each hypothesis on the sample*: a hypothesis
is identified with the vector `(f(x₁), …, f(xₙ)) : Fin n → ℝ` of its values on the
`n` sample points.  The empirical Rademacher complexity is the average, over all
`2ⁿ` sign patterns `σ ∈ {±1}ⁿ`, of the best (sup) correlation between a sign pattern
and a hypothesis:

  `empRad F = (1/(2ⁿ · n)) · Σ_σ  sup_{v ∈ F}  Σᵢ σᵢ · vᵢ`.

This is exactly the empirical Rademacher complexity used in statistical learning
theory; the finite-behavior representation makes it fully rigorous and computable.

This extends the algebraic-learning-theory development in
`Catalog/MachineLearning/Foundations.lean`, which discusses Rademacher complexity
abstractly but does not pin down the empirical quantity itself.

## Main results

* `signSum_coord_eq_zero`  — for each coordinate the signs cancel over all patterns.
* `empRad_singleton`       — a *single* hypothesis has empirical Rademacher complexity 0.
* `empRad_nonneg`          — if `0 ∈ F` the complexity is nonnegative.
* `empRad_mono`            — monotone in the hypothesis class.
* `empRad_le_of_bounded`   — the trivial uniform upper bound `empRad F ≤ B`.

A finite-class (Massart) refinement is stated as a `conjecture` with `sorry`.
-/
import Mathlib

open Finset

namespace RademacherSpectral

variable {n : ℕ}

/-- The Rademacher sign of a boolean: `true ↦ +1`, `false ↦ -1`. -/
def sgn (b : Bool) : ℝ := if b then 1 else -1

@[simp] lemma sgn_true : sgn true = 1 := rfl
@[simp] lemma sgn_false : sgn false = -1 := rfl

lemma sgn_not (b : Bool) : sgn (!b) = - sgn b := by cases b <;> simp [sgn]

lemma abs_sgn (b : Bool) : |sgn b| = 1 := by cases b <;> simp [sgn]

/-- Correlation of a sign pattern `σ` with a behavior vector `v`. -/
def corr (σ : Fin n → Bool) (v : Fin n → ℝ) : ℝ := ∑ i, sgn (σ i) * v i

/-- **Empirical Rademacher complexity** of a nonempty finite hypothesis class `F`,
where each hypothesis is represented by its vector of values on the `n` sample points. -/
noncomputable def empRad (F : Finset (Fin n → ℝ)) (hF : F.Nonempty) : ℝ :=
  (∑ σ : Fin n → Bool, F.sup' hF (fun v => corr σ v)) / (2 ^ n * n)

-- !-- Lab Notebook: signSum_coord_eq_zero -- !--
-- !-- Hypothesis: Summing the Rademacher sign at a fixed coordinate over all 2ⁿ patterns cancels. -- !--
-- !-- Result: Proved by the coordinate-flip involution σ ↦ update σ i (!σ i). -- !--
-- !-- Insight: Equiv.sum_comp over an involution forces S = -S, hence S = 0; this is the seed of every cancellation in the theory. -- !--
-- !-- Failure analysis: Direct sum_nbij' bookkeeping failed; packaging the flip as Function.Involutive.toPerm was the clean route. -- !--
-- !-- End Lab Notebook -- !--

-- !-- For each coordinate `i`, the signs `σ i` sum to zero over all sign patterns,
-- !-- via the involution flipping coordinate `i`. -- !--
/-- The signs at a fixed coordinate cancel when summed over all `2ⁿ` patterns. -/
lemma signSum_coord_eq_zero (i : Fin n) :
    ∑ σ : Fin n → Bool, sgn (σ i) = 0 := by
  have hinv : Function.Involutive (fun σ : Fin n → Bool => Function.update σ i (!(σ i))) := by
    intro σ; funext j; by_cases h : j = i <;> simp [Function.update, h]
  set e := Function.Involutive.toPerm _ hinv with he
  have hcomp : ∑ σ : Fin n → Bool, sgn ((e σ) i) = ∑ σ : Fin n → Bool, sgn (σ i) :=
    Equiv.sum_comp e (fun σ => sgn (σ i))
  have hval : ∀ σ : Fin n → Bool, sgn ((e σ) i) = - sgn (σ i) := by
    intro σ
    have hev : e σ = Function.update σ i (!(σ i)) := by rw [he]; rfl
    rw [hev]
    have : (Function.update σ i (!(σ i))) i = !(σ i) := by simp
    rw [this, sgn_not]
  rw [Finset.sum_congr rfl (fun σ _ => hval σ), Finset.sum_neg_distrib] at hcomp
  linarith [hcomp]

-- !-- Lab Notebook: empRad_singleton -- !--
-- !-- Hypothesis: One fixed hypothesis carries no Rademacher complexity (it cannot fit random noise on average). -- !--
-- !-- Result: Proved; numerator is Σ_σ Σ_i σ_i v_i = Σ_i v_i (Σ_σ σ_i) = 0 by signSum_coord_eq_zero. -- !--
-- !-- Insight: Empirical Rademacher complexity measures *richness of the class*, not of any single function; the singleton is the base case. -- !--
-- !-- Failure analysis: Needed Finset.sum_comm to move the σ-sum inside before applying the coordinate cancellation. -- !--
-- !-- End Lab Notebook -- !--

-- !-- sup' over a singleton is the value itself; swap the σ and i sums and apply
-- !-- signSum_coord_eq_zero coordinatewise. -- !--
/-- A single hypothesis has empirical Rademacher complexity exactly `0`. -/
theorem empRad_singleton (v : Fin n → ℝ) :
    empRad ({v} : Finset (Fin n → ℝ)) (singleton_nonempty v) = 0 := by
  unfold empRad
  have hnum : (∑ σ : Fin n → Bool,
      ({v} : Finset (Fin n → ℝ)).sup' (singleton_nonempty v) (fun w => corr σ w)) = 0 := by
    have : ∀ σ : Fin n → Bool,
        ({v} : Finset (Fin n → ℝ)).sup' (singleton_nonempty v) (fun w => corr σ w) = corr σ v := by
      intro σ; simp [Finset.sup'_singleton]
    rw [Finset.sum_congr rfl (fun σ _ => this σ)]
    unfold corr
    rw [Finset.sum_comm]
    have : ∀ i : Fin n, (∑ σ : Fin n → Bool, sgn (σ i) * v i) = 0 := by
      intro i
      rw [← Finset.sum_mul, signSum_coord_eq_zero i, zero_mul]
    rw [Finset.sum_congr rfl (fun i _ => this i), Finset.sum_const_zero]
  rw [hnum, zero_div]

-- !-- Lab Notebook: empRad_nonneg -- !--
-- !-- Hypothesis: A class containing the zero hypothesis has nonnegative empirical Rademacher complexity. -- !--
-- !-- Result: Proved; each sup' dominates the value at 0, which is 0, so the numerator and the nonneg denominator give the bound. -- !--
-- !-- Insight: Nonnegativity is a *containment* property, not automatic; it needs a witness (here 0 ∈ F). -- !--
-- !-- Failure analysis: Care with n = 0 where the denominator vanishes — div_nonneg still applies. -- !--
-- !-- End Lab Notebook -- !--

-- !-- Each σ-term is ≥ corr σ 0 = 0 by le_sup'; sum and divide by the nonneg denom. -- !--
/-- If the zero hypothesis is in the class, the empirical Rademacher complexity is `≥ 0`. -/
theorem empRad_nonneg (F : Finset (Fin n → ℝ)) (hF : F.Nonempty)
    (h0 : (0 : Fin n → ℝ) ∈ F) : 0 ≤ empRad F hF := by
  unfold empRad
  apply div_nonneg
  · apply Finset.sum_nonneg
    intro σ _
    have hle : corr σ (0 : Fin n → ℝ) ≤ F.sup' hF (fun v => corr σ v) :=
      Finset.le_sup' (fun v => corr σ v) h0
    have : corr σ (0 : Fin n → ℝ) = 0 := by simp [corr]
    rw [this] at hle; exact hle
  · positivity

-- !-- Lab Notebook: empRad_mono -- !--
-- !-- Hypothesis: A richer hypothesis class has at least as much empirical Rademacher complexity. -- !--
-- !-- Result: Proved via Finset.sup'_mono pointwise in σ, then sum monotonicity and division by a nonneg denominator. -- !--
-- !-- Insight: Monotonicity is the structural backbone that lets one bound complex classes by simple supersets. -- !--
-- !-- Failure analysis: gcongr discharges the division step including the 0 ≤ denominator side goal. -- !--
-- !-- End Lab Notebook -- !--

-- !-- sup' is monotone in the Finset (Finset.sup'_mono); sum and divide. -- !--
/-- Empirical Rademacher complexity is monotone under class inclusion. -/
theorem empRad_mono (F G : Finset (Fin n → ℝ)) (hF : F.Nonempty) (hG : G.Nonempty)
    (hsub : F ⊆ G) : empRad F hF ≤ empRad G hG := by
  unfold empRad
  have hnum : (∑ σ : Fin n → Bool, F.sup' hF (fun v => corr σ v))
      ≤ ∑ σ : Fin n → Bool, G.sup' hG (fun v => corr σ v) := by
    apply Finset.sum_le_sum
    intro σ _
    exact Finset.sup'_mono (fun v => corr σ v) hsub hF
  gcongr

-- !-- Lab Notebook: empRad_le_of_bounded -- !--
-- !-- Hypothesis: If every hypothesis is uniformly bounded by B in each coordinate, the complexity is ≤ B. -- !--
-- !-- Result: Proved; corr σ v ≤ Σ|vᵢ| ≤ nB 
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — Empirical Rademacher Complexity of Neural Networks

## Synthesis

This cycle opened a self-contained, fully rigorous formalization of the **empirical
Rademacher complexity** of a finite hypothesis class, the central object behind the
narrative of `Catalog/MachineLearning/RademacherSpectral.lean` (which did not exist
on disk at the start of the cycle, so we built it from scratch rather than filling
phantom `sorry` placeholders). The key modeling decision was to represent each
hypothesis by its *behavior on the sample* — the vector `(f(x₁),…,f(xₙ)) : Fin n → ℝ`
— so that a hypothesis class is a `Finset (Fin n → ℝ)` and the complexity is a finite
average over the `2ⁿ` sign patterns of the best correlation `sup_v Σᵢ σᵢ vᵢ`. This
makes the quantity computable and removes every measure-theoretic subtlety while
remaining faithful to the textbook definition.

The structural insight that emerged is that *every* elementary property of empirical
Rademacher complexity reduces to a single cancellation fact: `signSum_coord_eq_zero`,
which says the Rademacher signs at any fixed coordinate sum to zero over all patterns.
We proved it via the coordinate-flip involution `σ ↦ update σ i (!σ i)`, packaged as a
permutation, so that `Equiv.sum_comp` forces `S = -S`. From this single seed the
"singleton has zero complexity" theorem falls out immediately, and the remaining
properties (nonnegativity, monotonicity, the uniform bound) are order-theoretic
consequences of `Finset.sup'` monotonicity together with sign cancellation. What
failed/needed care: the `n = 0` boundary (vanishing denominator) had to be treated
separately in the uniform bound, and several automation tactics (`gcongr`, `simp`)
closed goals more aggressively than expected, which is a good sign the lemmas are
"the right shape."

The one result we could not close is the **Massart finite-class refinement**
(`empRad_massart_conjecture`), which would beat the trivial bound `empRad ≤ B` by a
`√(log|F|/n)` factor. It is left as an explicit conjecture because it requires a
sub-Gaussian / moment-generating-function (Hoeffding) argument — exactly the analytic
ingredient our purely order-theoretic toolkit lacks. This gap is the natural seam
along which the next cycle should cut.

## Results Summary

- `signSum_coord_eq_zero`: proved — the Rademacher signs at any fixed coordinate cancel over all `2ⁿ` patterns; the cancellation engine for the whole file.
- `empRad_singleton`: proved — a single hypothesis has empirical Rademacher complexity exactly `0`, confirming the quantity measures class richness, not individual functions.
- `empRad_nonneg`: proved — a class containing the zero hypothesis has nonnegative complexity (nonnegativity is a containment property, not automatic).
- `empRad_mono`: proved — complexity is monotone under class inclusion, the backbone for bounding rich classes by simple supersets.
- `empRad_le_of_bounded`: proved — the trivial uniform bound `empRad F ≤ B` for a class bound
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
of objects (not placeholder strings). For each algorithm in the algorithms array, provide a name, a detailed explanation of its logic and complexity in 'description', formal step-by-step pseudocode in 'pseudocode', and clean type-hinted Python code in 'code'. Include future directions from Phase A in the future_directions field.

Be vivid, be precise, be world-class. The math has already been done — now
make it beautiful to read.
