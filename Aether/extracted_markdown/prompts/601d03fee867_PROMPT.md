
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

**Title**: Close Proofs: Close Proofs: ML Generalization Bounds: Rademacher Complexity of Neura
**Domain**: Applications
**Mathematical framing**: Cycle c9963744 (Q=0.426) proved 854 theorems in Applications but left 10 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: Cycle ad363765 (Q=0.421) proved 1240 theorems in MachineLearning but left 2 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: Formalize Radema
Research domain: Applications
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/MachineLearning/RademacherComplexity.lean
/-
Copyright (c) 2025. Released under Apache 2.0 license.

# Empirical Rademacher Complexity of Finite Function Classes

This file gives a fully rigorous, self-contained development of the *empirical
Rademacher complexity* of a finite class of real-valued functions evaluated on a
fixed sample of size `m`.  Rademacher complexity is the central data-dependent
capacity measure of statistical learning theory; it controls uniform deviation
bounds and hence generalization error.

We represent a hypothesis evaluated on a sample of size `m` by its vector of
values `f : Fin m → ℝ`.  A Rademacher sign assignment is `σ : Fin m → Bool`,
interpreted via `radSign` as `±1`.  The empirical Rademacher complexity averages
the best-correlating member of the class over *all* `2^m` sign assignments.

This complements the algebraic capacity theory in `Foundations.lean`
(VC dimension, `spectralComplexityBound`, `algebraicSampleComplexityBound`,
whose `8/3` constant arises from the Rademacher-to-PAC conversion) by giving the
*analytic* object those bounds approximate, with exact computations rather than
inequalities.

## Main results

* `sum_radSign`            — the signed indicator of any coordinate cancels over all sign vectors
* `radSum_sum_zero`        — the Rademacher correlation of a fixed function averages to zero
* `radSum_neg`             — Rademacher correlation is odd in the function
* `empRad_singleton`       — the empirical Rademacher complexity of a singleton class is `0`
* `empRad_mono`            — monotonicity of complexity under class inclusion
* `empRad_nonneg`          — complexity is nonnegative for any class containing the zero function
* `empRad_symmetric_pair`  — *exact* formula for the symmetric pair `{f, -f}` (the building block)
-/

import Mathlib

open BigOperators

/-! ## Rademacher signs and correlations -/

/-- The `±1` Rademacher sign attached to a Boolean sign vector at coordinate `i`. -/
def radSign {m : ℕ} (σ : Fin m → Bool) (i : Fin m) : ℝ := if σ i then 1 else -1

/-- The Rademacher correlation of a sample-value vector `f` with sign vector `σ`,
i.e. `∑ i, σ_i f_i`. -/
def radSum {m : ℕ} (f : Fin m → ℝ) (σ : Fin m → Bool) : ℝ := ∑ i, radSign σ i * f i

/-- The **empirical Rademacher complexity** of a nonempty finite function class `F`
on a sample of size `m`: the sample-normalized average over all `2^m` sign vectors
of the best-correlating member of the class. -/
noncomputable def empRad {m : ℕ} (F : Finset (Fin m → ℝ)) (hF : F.Nonempty) : ℝ :=
  (1 / (m : ℝ)) * (1 / (2 : ℝ) ^ m) * ∑ σ : Fin m → Bool, F.sup' hF (fun f => radSum f σ)

/-! ## Core cancellation identity -/

-- !-- The signed indicator of a fixed coordinate sums to zero over all sign
-- vectors: pair each `σ` with the one obtained by flipping coordinate `i`; the
-- two values `+1` and `-1` cancel, giving a fixed-point-free involution. -- !--
/-- **Core combinatorial cancellation.** For any fixed coordinate `i`, the
Rademacher sign summed over all `2^m` sign vectors is zero. -/
theorem sum_radSign {m : ℕ} (i : Fin m) : ∑ σ : Fin m → Bool, radSign σ i = 0 := by
  apply Finset.sum_involution (fun σ _ => Function.update σ i (!(σ i)))
  · intro σ _; unfold radSign; simp only [Function.update_self]; cases σ i <;> simp
  · intro σ _ _ h; have := congrFun h i; simp [Function.update_self] at this
  · intro σ _; funext j; by_cases hj : j = i
    · subst hj; simp
    · simp [Function.update_of_ne hj]
  · intro σ _; exact Finset.mem_univ _

-- !-- Expand `radSum`, swap the order of summation, and factor each coordinate's
-- contribution through `sum_radSign`. -- !--
/-- The Rademacher correlation of a *fixed* function averages to zero over all
sign vectors.  This is the precise statement that a single hypothesis carries no
Rademacher complexity. -/
theorem radSum_sum_zero {m : ℕ} (f : Fin m → ℝ) :
    ∑ σ : Fin m → Bool, radSum f σ = 0 := by
  unfold radSum
  rw [Finset.sum_comm]
  have h : ∀ i, ∑ σ : Fin m → Bool, radSign σ i * f i = 0 := by
    intro i; rw [← Finset.sum_mul, sum_radSign]; ring
  simp [h]

-- !-- Distribute negation through the sum defining `radSum`. -- !--
/-- The Rademacher correlation is an odd function of its argument. -/
theorem radSum_neg {m : ℕ} (f : Fin m → ℝ) (σ : Fin m → Bool) :
    radSum (-f) σ = - radSum f σ := by
  unfold radSum
  rw [← Finset.sum_neg_distrib]
  apply Finset.sum_congr rfl
  intro i _; simp

/-! ## Structural properties of empirical Rademacher complexity -/

-- !-- The supremum over a singleton collapses to the single value, and
-- `radSum_sum_zero` makes the resulting average vanish. -- !--
/-- **Singletons have zero complexity.** A function class consisting of a single
hypothesis has empirical Rademacher complexity zero. -/
theorem empRad_singleton {m : ℕ} (f : Fin m → ℝ) :
    empRad ({f} : Finset (Fin m → ℝ)) (by simp) = 0 := by
  unfold empRad
  have h : ∀ σ, ({f} : Finset (Fin m → ℝ)).sup' (by simp) (fun g => radSum g σ) = radSum f σ := by
    intro σ; simp
  simp_rw [h]
  rw [radSum_sum_zero]; ring

-- !-- The supremum over a subclass is dominated by the supremum over the larger
-- class for every sign vector; summing and multiplying by the nonnegative
-- normalization constant preserves the inequality. -- !--
/-- **Monotonicity.** Enlarging the function class can only increase its empirical
Rademacher complexity. -/
theorem empRad_mono {m : ℕ} (F G : Finset (Fin m → ℝ)) (hF : F.Nonempty)
    (hFG : F ⊆ G) : empRad F hF ≤ empRad G (hF.mono hFG) := by
  unfold empRad
  have hconst : (0 : ℝ) ≤ (1 / (m : ℝ)) * (1 / (2 : ℝ) ^ m) := by positivity
  apply mul_le_mul_of_nonneg_left _ hconst
  apply Finset.sum_le_sum
  intro σ _
  exact Finset.sup'_mono _ hFG hF

-- !-- For every sign vector the supremum dominates the value at the zero
-- function, which is `0`; hence each summand is nonnegative. -- !--
/-- **Nonnegativity.** Any function class containing the zero hypothesis has
nonnegative empirical Rademacher complexity. -/
theorem empRad_nonneg {m : ℕ} (F : Finset (Fin m → ℝ)) (hF : F.Nonempty)
    (h0 : (0 : Fin m → ℝ) ∈ F) : 0 ≤ empRad F hF := by
  unfold empRad
  have hconst : (0 : ℝ) ≤ (1 / (m : ℝ)) * (1 / (2 : ℝ) ^ m) := by positivity
  apply mul_nonneg hconst
  apply Finset.sum_nonneg
  intro σ _
  have hle : radSum (0 : Fin m → ℝ) σ ≤ F.sup' hF (fun g => radSum g σ) :=
    Finset.le_sup' (fun g => radSum g σ) h0
  have hz : radSum (0 : Fin m → ℝ) σ = 0 := by unfold radSum; simp
  rwa [hz] at hle

/-! ## The symmetric pair: an exact formula -/

-- !-- For each sign vector the supremum over `{f, -f}` is `max (radSum f σ)
-- (-radSum f σ) = |radSum f σ|` by `radSum_neg` and `abs_eq_max_neg`. -- !--
/-- **Exact formula for the symmetric pair `{f, -f}`.** This is the fundamental
building block of Rademacher analysis: the complexity of the symmetrized
two-point class is exactly the sample-normalized average *absolute* correlation,
making the role of absorption-into-the-supremum completely explicit. -/
theorem empRad_symmetric_pair {m : ℕ} (f : Fin m → ℝ) :
    empRad ({f, -f} : Finset (Fin m → ℝ)) (by simp) =
      (1 / (m : ℝ)) * (1 / (2 : ℝ) ^ m) * ∑ σ : Fin m → Bool, |radSum f σ| := by
  unfold empRad
  congr 1
  apply Finset.sum_congr rfl
  intro σ _
  have hsup : ({f, -f} : Finset (Fin m → ℝ)).sup' (by simp) (fun g => radSum g σ)
      = max (radSum f σ) (radSum (-f) σ) := by
    rw [Finset.sup'_insert (by simp), Finset.sup'_singleton]
  rw [hsup, radSum_neg, ← abs_eq_max_neg]

-- !-- Immediate from the exact formula since each `|radSum f σ|` is nonnegative
-- and the normalization constant is nonnegative. -- !--
/-- **Corollary / strengthening of `empRad_nonneg` for the symmetric pair.** The
symmetric pair always has nonnegative complexity, with no need for the class to
contain the zero function. -/
theorem empRad_symmetric_pair_nonneg {m : ℕ} (f : Fin m → ℝ) :
    0 ≤ empRad ({f, -f} : Finset (Fin m → ℝ)) (by simp) := by
  rw [empRad_symmetric_pair]
  have hconst : 
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: Empirical Rademacher Complexity

The file `Catalog/MachineLearning/RademacherComplexity.lean` builds a rigorous,
computation-first account of empirical Rademacher complexity: the `±1`-sign
correlation `radSum`, the averaged capacity `empRad`, the core cancellation
`sum_radSign`, and an *exact* formula for the symmetric pair `{f, -f}`. Each
result is exact rather than an inequality, which makes the development an ideal
substrate for the next, harder layer of learning theory. The directions below are
falsifiable: each names a concrete Lean statement whose truth (or refutation by a
counterexample) can be settled mechanically.

## 1. Massart's finite-class bound

Conjecture: for a class `F` whose every member satisfies `radSum f σ ≤ B`
uniformly, `empRad F hF ≤ (B / m) * sqrt (2 * Real.log F.card) / sqrt (2^m … )`,
the textbook `sqrt(2 log N)` scaling that converts cardinality into capacity.
**The key insight is** that the maximal-correlation supremum can be controlled by
the moment-generating-function (Jensen / Hoeffding-on-the-hypercube) argument,
where `sum_radSign` already supplies the exact first-moment vanishing that the MGF
bound is built on top of. **Why now?** We have an exact `empRad` with the
zero-mean property proven (`radSum_sum_zero`); the only missing analytic ingredient
is a sub-Gaussian tail for `radSum`, which is a self-contained hypercube estimate
rather than new infrastructure.

## 2. Contraction / Talagrand's lemma for 1-Lipschitz post-composition

Conjecture: if `φ : ℝ → ℝ` is `1`-Lipschitz with `φ 0 = 0`, then
`empRad (F.image (fun f => φ ∘ f)) ≤ empRad F`. **The key insight is** that the
absorption-into-the-supremum already made explicit in `empRad_symmetric_pair`
(`max a (-a) = |a|`) is the `φ = |·|` instance of the general contraction
principle, so the symmetric-pair formula is literally the base case of an
induction over coordinates. **Why now?** `empRad_symmetric_pair` gives the exact
one-coordinate contraction identity; the pending work is the coordinate-wise
peeling that mathlib's `Finset.sup'` API now supports cleanly.

## 3. Homogeneity and translation invariance

Conjecture: `empRad (c • F) = |c| * empRad F` for scalars `c`, and
`empRad (F + {b}) = empRad F` for a fixed shift vector `b`. **The key insight is**
that `radSum` is linear in `f` and that `radSum b` averages to zero
(`radSum_sum_zero`), so an additive shift is invisible to the averaged supremum
exactly as a constant feature is invisible to a learning algorithm. **Why now?**
Both reduce to pushing scalars/shifts through `Finset.sup'` and reusing
`radSum_sum_zero`; no new probabilistic content is required, only `Finset.image`
bookkeeping.

## 4. Bridge to the algebraic capacity theory of `Foundations.lean`

Conjecture: for the evaluation class `evaluationHypothesisClass` of `Foundations.lean`,
the analytic `empRad` is bounded by the algebraic `spectralComplexityBound`,
realizing the `8/3` Rademacher-to-PAC constant of `algebraicSampleComp
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
