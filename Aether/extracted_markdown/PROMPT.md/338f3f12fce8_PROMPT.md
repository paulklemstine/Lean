
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

**Title**: Close Proofs: The new file `Catalog/MachineLearning/PerturbedGeneralization.lean` br
**Domain**: Novelty
**Mathematical framing**: Cycle 15f2a404 (Q=0.445) proved 118 theorems in MachineLearning but left 5 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: # Future Directions: Perturbation-Stable Generalization Bounds

The new file `Catalog/MachineLearning/PerturbedGeneralization.lean` bridges the
catalog's two previously disconnected machine-learning s
Research domain: Novelty
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/MachineLearning/PerturbedGeneralization.lean
/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Perturbation-Stable Generalization Bounds

This file is a **cross-domain bridge** in the `MachineLearning` catalog.  It
connects two previously disconnected threads:

* `MachineLearning/CompressionGeneralization.lean` — the Occam / compression
  generalization bound `occamBound R C n δ = R + sqrt ((C + log(1/δ))/(2n))`,
  governing how empirical risk plus description-length complexity controls the
  true risk; and
* the *Lipschitz perturbation-stability* theme (the subject of
  `MachineLearning/Stability.lean`), governing how the loss of a model changes
  under bounded input perturbations.

The synthesis is the **perturbation-stable Occam bound**

  `perturbedOccamBound R C L ρ n δ = occamBound (R + L·ρ) C n δ`,

which certifies the true risk of a model evaluated on data perturbed by up to
`ρ` in input space, when the loss is `L`-Lipschitz.  The single extra term `L·ρ`
is the entire price of adversarial robustness inside an otherwise unchanged
compression bound.

## Main results

* `lipschitz_perturbation_le`        — per-point: an `L`-Lipschitz loss rises by ≤ `L·ρ` under a ρ-perturbation
* `robust_empRisk_valid`             — dataset: the worst-case perturbed empirical risk ≤ `R + L·ρ`
* `perturbed_ge_clean`               — perturbation can only loosen the certificate
* `perturbed_gap_decomposition`      — the excess over `R` splits into robustness `L·ρ` + capacity penalty
* `perturbed_collapse`               — with no perturbation (`ρ=0`) or no sensitivity (`L=0`) the clean bound is recovered
* `perturbed_bound_tendsto`          — **consistency**: the bound → `R + L·ρ` as `n → ∞` (robustness is the irreducible floor)
* `perturbed_sample_complexity`      — inversion: `n ≥ (C+log(1/δ))/(2ε²)` ⟹ bound ≤ `R + L·ρ + ε`
* `perturbed_certificate`            — **the bridge**: the clean-data certificate + margin dominates the true perturbed bound
* `perturbed_overparam_invariance`   — the perturbed bound still ignores raw parameter count

## The key insight

Robustness and generalization are usually studied with disjoint machinery.  The
compression bound shows generalization is controlled by *description length*; the
Lipschitz analysis shows robustness is controlled by *the constant `L` and the
radius `ρ`*.  Composing them is exact and additive: the robust generalization
certificate is the clean Occam bound with its empirical-risk slot shifted by the
single scalar `L·ρ`.  Nothing else in the capacity penalty changes — in
particular `perturbed_overparam_invariance` shows robustness does **not**
reintroduce a dependence on parameter count.
-/
import Mathlib
import MachineLearning.CompressionGeneralization

open Real Filter Topology

noncomputable section

namespace PerturbedGen

open CompressionGen

/-! ## Definitions -/

/-- The **robust empirical risk**: the clean empirical risk `R` inflated by the
worst-case loss increase `L·ρ` produced by perturbing inputs by up to `ρ`
against an `L`-Lipschitz loss. -/
def robustEmpRisk (R L ρ : ℝ) : ℝ := R + L * ρ

/-- The **perturbation-stable Occam bound**: the compression generalization
bound evaluated at the robust empirical risk. -/
def perturbedOccamBound (R C L ρ : ℝ) (n : ℕ) (δ : ℝ) : ℝ :=
  occamBound (robustEmpRisk R L ρ) C n δ

/-! ## Lipschitz stability → robust empirical risk -/

-- !-- Per-point perturbation bound: an `L`-Lipschitz loss can grow by at most
-- `L·ρ` under any perturbation of radius `≤ ρ`; immediate from `dist_le_mul`. -- !--
/-- If the loss `ℓ` is `L`-Lipschitz, then perturbing the input within radius `ρ`
raises the loss by at most `L·ρ`. -/
theorem lipschitz_perturbation_le
    {X : Type*} [PseudoMetricSpace X] {ℓ : X → ℝ} {L : ℝ} (hL : 0 ≤ L)
    (hLip : LipschitzWith ⟨L, hL⟩ ℓ) {x y : X} {ρ : ℝ} (hxy : dist x y ≤ ρ) :
    ℓ y ≤ ℓ x + L * ρ := by
  have h := hLip.dist_le_mul x y
  simp only [Real.dist_eq, NNReal.coe_mk] at h
  have h3 : L * dist x y ≤ L * ρ := mul_le_mul_of_nonneg_left hxy hL
  have h4 : ℓ y - ℓ x ≤ |ℓ x - ℓ y| := by rw [abs_sub_comm]; exact le_abs_self _
  linarith

-- !-- Dataset-level robustness: averaging the per-point bound over a finite
-- training set shows the worst-case perturbed empirical risk is `≤ R + L·ρ`. -- !--
/-- The mean perturbed loss over a finite dataset is at most the mean clean loss
plus `L·ρ`.  This validates `robustEmpRisk` as a genuine upper bound on the
perturbed empirical risk. -/
theorem robust_empRisk_valid
    {X : Type*} [PseudoMetricSpace X] {ι : Type*} {ℓ : X → ℝ} {L ρ : ℝ}
    (hL : 0 ≤ L) (hLip : LipschitzWith ⟨L, hL⟩ ℓ)
    (s : Finset ι) (x y : ι → X)
    (hd : ∀ i ∈ s, dist (x i) (y i) ≤ ρ) :
    (∑ i ∈ s, ℓ (y i)) ≤ (∑ i ∈ s, ℓ (x i)) + s.card * (L * ρ) := by
  calc (∑ i ∈ s, ℓ (y i)) ≤ ∑ i ∈ s, (ℓ (x i) + L * ρ) :=
        Finset.sum_le_sum (fun i hi => lipschitz_perturbation_le hL hLip (hd i hi))
    _ = (∑ i ∈ s, ℓ (x i)) + s.card * (L * ρ) := by
        rw [Finset.sum_add_distrib, Finset.sum_const, nsmul_eq_mul]

/-! ## Structure of the perturbed bound -/

-- !-- The robust empirical risk is monotone in `R`, hence the Occam bound is
-- too; perturbing can only loosen the certificate. -- !--
/-- Adding a nonnegative robustness budget `L·ρ` never tightens the bound. -/
theorem perturbed_ge_clean (R C L ρ : ℝ) (n : ℕ) (δ : ℝ) (h : 0 ≤ L * ρ) :
    occamBound R C n δ ≤ perturbedOccamBound R C L ρ n δ := by
  unfold perturbedOccamBound robustEmpRisk occamBound; linarith

-- !-- Unfolding the definitions, the excess of the perturbed bound over the
-- clean empirical risk `R` splits exactly into the robustness term `L·ρ` and the
-- capacity penalty `sqrt(...)`. -- !--
/-- The perturbed bound, measured against the clean empirical risk, decomposes
into a robustness term `L·ρ` plus the usual capacity penalty. -/
theorem perturbed_gap_decomposition (R C L ρ : ℝ) (n : ℕ) (δ : ℝ) :
    perturbedOccamBound R C L ρ n δ - R
      = L * ρ + Real.sqrt ((C + Real.log (1 / δ)) / (2 * n)) := by
  unfold perturbedOccamBound robustEmpRisk occamBound; ring

-- !-- With no perturbation (`ρ = 0`) or a perturbation-insensitive loss
-- (`L = 0`) the robustness term vanishes and the clean Occam bound is recovered. -- !--
/-- If either the radius `ρ` or the Lipschitz constant `L` is zero, the perturbed
bound collapses to the clean Occam bound. -/
theorem perturbed_collapse (R C L ρ : ℝ) (n : ℕ) (δ : ℝ) (h : L * ρ = 0) :
    perturbedOccamBound R C L ρ n δ = occamBound R C n δ := by
  unfold perturbedOccamBound robustEmpRisk; rw [h, add_zero]

/-! ## Consistency and sample complexity -/

-- !-- Generalizes `occam_gap_tendsto_zero`: the capacity penalty still vanishes,
-- so the perturbed bound converges to its irreducible robustness floor `R+L·ρ`. -- !--
/-- **Consistency.** With fixed complexity the perturbed bound converges, as the
sample size grows, to the robustness floor `R + L·ρ` (not to `R`). -/
theorem perturbed_bound_tendsto (R C L ρ δ : ℝ) :
    Tendsto (fun n : ℕ => perturbedOccamBound R C L ρ n δ) atTop
      (𝓝 (R + L * ρ)) := by
  have h := occam_gap_tendsto_zero (robustEmpRisk R L ρ) C δ
  have h2 := h.add (tendsto_const_nhds (x := robustEmpRisk R L ρ))
  rw [zero_add] at h2
  have hf : (fun n : ℕ => perturbedOccamBound R C L ρ n δ)
      = (fun n => (occamBound (robustEmpRisk R L ρ) C n δ - robustEmpRisk R L ρ)
          + robustEmpRisk R L ρ) := by
    funext n; unfold perturbedOccamBound; ring
  rw [hf]; simpa [robustEmpRisk] using h2

-- !-- Lab Notebook: perturbed_bound_tendsto -- !--
-- !-- Hypothesis: Under perturbation the generalization gap no longer vanishes;
--     it should converge to the irreducible robustness floor R + L·ρ. -- !--
-- !-- Result: Proved by reduction to the catalog's `occam_gap_tendsto_zero`:
--     the capacity penalty still → 0, so the bound → robustEmpRisk = R + L·ρ. -- !--
-- !-- Insight: Robustness changes the *limit* of the bound, not its *rate* of
--  
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: Perturbation-Stable Generalization Bounds

## Synthesis

This cycle built `MachineLearning/PerturbedGeneralization.lean`, a cross-domain
bridge connecting two previously disconnected threads of the catalog: the
compression / Occam generalization bound of `MachineLearning/CompressionGeneralization.lean`
(`occamBound R C n δ = R + sqrt((C + log(1/δ))/(2n))`) and the Lipschitz
perturbation-stability theme of `MachineLearning/Stability.lean`. The synthesis
is the *perturbation-stable Occam bound* `perturbedOccamBound R C L ρ n δ =
occamBound (R + L·ρ) C n δ`, which certifies the true risk of a model evaluated
on inputs perturbed by up to `ρ` against an `L`-Lipschitz loss.

The central structural discovery is that robustness and generalization compose
*additively and without coupling*: the only modification to the entire
compression bound is a single scalar `L·ρ` inserted into the empirical-risk slot.
Everything downstream — the capacity penalty, the sample-complexity inversion,
the consistency limit, and crucially the overparameterization invariance —
carries over verbatim. The bridge theorem `perturbed_certificate` makes this
operational: a robustness certificate computed entirely on *clean* training data
(via Lipschitz averaging in `robust_empRisk_valid`) dominates the Occam bound on
*any* `ρ`-perturbed dataset, lifted by monotonicity of the bound in its risk slot
(`occam_mono_risk`). The consistency theorem `perturbed_bound_tendsto` reduces to
the catalog's `occam_gap_tendsto_zero` and shows robustness shifts the *limit* of
the bound to `R + L·ρ` while leaving the *rate* of convergence in `n` untouched —
a clean separation of the statistical and adversarial axes that parallels the
catalog's `memorization_gap_limit`.

What did not happen: no result required reproving any catalog lemma, and the
attempt to depend on `Stability.lean` directly failed because that file imports a
missing module (`MachineLearning.TopKRobustness.Defs`) and does not compile in
this checkout. We therefore re-derived a self-contained Lipschitz-perturbation
core (`lipschitz_perturbation_le`) rather than coupling to a broken file. The
heterogeneous generalization `robust_empRisk_heterogeneous` turned out to be
provable in this same cycle (per-example constants `L i`, radii `ρ i`, summed),
rather than remaining a conjecture — its boundary behaviour seeds the directions
below.

## Results Summary

- `lipschitz_perturbation_le`: proved — an `L`-Lipschitz loss rises by at most `L·ρ` under any perturbation of radius `≤ ρ`.
- `robust_empRisk_valid`: proved — the worst-case perturbed empirical risk over a finite dataset is `≤ R + L·ρ`, validating the robust-risk definition.
- `perturbed_ge_clean`: proved — adding a nonnegative robustness budget `L·ρ` can only loosen the certificate.
- `perturbed_gap_decomposition`: proved — the excess of the perturbed bound over clean risk splits exactly into robustness `L·ρ` plus the capacity penalty.
- `perturbed_collapse`: prov
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
