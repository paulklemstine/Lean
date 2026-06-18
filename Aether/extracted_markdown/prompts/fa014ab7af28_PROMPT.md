
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

**Title**: Close Proofs: Neural Network Training as Renormalization Group Flow
**Domain**: Applications
**Mathematical framing**: Cycle d4cfb6f8 (Q=0.464) proved 519 theorems in Applications but left 20 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: The key insight is that neural network training is a renormalization group (RG) flow in function space. Each training step integrates out high-frequency modes (gradient descent on fast-varying paramet
Research domain: Applications
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/MachineLearning/RGFlowTraining.lean
/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

-- This file develops the RG-flow viewpoint on top of the spectral picture in
-- `MachineLearning/NTKSpectral.lean`; the relevant results there
-- (`ntkGram`, `ntk_mode_decay`, `ntk_optimal_tendsto_zero`) are referenced in the
-- docstrings. The development below is self-contained (`import Mathlib` only).

/-!
# Neural Network Training as Renormalization-Group Flow

This file formalizes the **renormalization-group (RG) picture of gradient-based
training** in the linearized / Neural-Tangent-Kernel (NTK) regime, building
directly on `Catalog/MachineLearning/NTKSpectral.lean`.

## The physical picture

In the NTK regime the training residual `r` evolves by `r_{k+1} = (I - η Θ) r_k`
with `Θ = JᵀJ` the NTK Gram matrix (cf. `NTKSpectral.ntkGram`). Diagonalizing `Θ`
turns the matrix recurrence into independent scalar modes, each rescaled by its
**gain** `g_i = 1 - η λ_i` (cf. `NTKSpectral.ntk_mode_decay`).

A single training step is therefore a *diagonal flow* `rgStep` on mode space that
rescales mode `i` by `g_i`. This is precisely a **renormalization-group step**:

* iterating the step is a discrete RG semigroup (`rgStep_semigroup`);
* modes with large NTK eigenvalue have small gain and decay fastest — these are
  the **high-frequency / irrelevant** directions that training "integrates out"
  (`rg_scale_separation`);
* the surviving **relevant** directions are the slow modes, and the RG flow runs
  to an **IR fixed point** which is exactly the kernel of the NTK
  (`rgStep_fixed_iff`);
* when every mode is contracting, the flow converges to that fixed point
  (`rg_flow_tendsto_zero`), a multi-mode generalization of
  `NTKSpectral.ntk_optimal_tendsto_zero`.

## Main results

* `rgStep_iterate` — closed form of the diagonal RG flow: `(rgStep)^[k] v i = g_i^k v_i`.
* `rgStep_semigroup` — the RG/training steps form a discrete one-parameter
  semigroup: coarse-graining to scale `k+m` = scale `m` then scale `k`.
* `rg_scale_separation` — **separation of scales**: a faster-contracting
  (higher-frequency) mode becomes negligible relative to a slower one; its
  amplitude ratio tends to `0`. This is the RG act of *integrating out* fast modes.
* `rgStep_fixed_iff` — the **IR fixed points** of the training flow are exactly the
  residuals annihilated by every active NTK eigenvalue (the NTK kernel).
* `rg_flow_tendsto_zero` — if every gain has `|g_i| < 1` the whole flow converges to
  the IR fixed point `0`.

## References

* Jacot, Gabriel, Hongler, *Neural Tangent Kernel* (2018).
* The RG interpretation of coarse-graining/optimization dynamics is folklore in the
  physics-of-learning literature; here it is given a fully verified algebraic core.
-/

open Filter
open scoped BigOperators

namespace RGFlowTraining

-- !-- Lab Notebook -- !--
-- Hypothesis: NTK-regime gradient descent is a renormalization-group flow on the
--   space of spectral modes. Each step rescales mode i by its gain g_i = 1-ηλ_i;
--   high NTK-eigenvalue modes contract fastest and are "integrated out", leaving a
--   relevant low-eigenvalue subspace whose IR fixed point is the NTK kernel.
-- Result: Formalized the diagonal RG step `rgStep`, its closed-form iterate
--   (g_i^k v_i), the semigroup law, scale separation (fast modes vanish relative
--   to slow ones), the fixed-point = NTK-kernel characterization, and global
--   convergence to the IR fixed point when all gains contract.
-- Insight: The "integrating out high-frequency modes" slogan becomes the precise
--   statement that the *ratio* of a fast mode to a slow mode tends to 0 — a
--   geometric-sequence fact once the iterate is in closed form. The RG semigroup
--   is exactly `Function.iterate_add`, and the IR fixed point is exactly the
--   kernel of the NTK, linking optimization dynamics to linear algebra.
-- Failure analysis: A continuous-time RG-flow ODE formulation was avoided (heavy
--   matrix-exponential API). The discrete diagonal flow captures the same scaling
--   physics with clean, fully verified proofs and reuses NTKSpectral directly.

/-- The per-mode **gain** of one training step: mode `i` with NTK eigenvalue `lam`
is rescaled by `1 - lr * lam` (cf. `NTKSpectral.ntk_mode_decay`). -/
def gain (lr lam : ℝ) : ℝ := 1 - lr * lam

/-- One **renormalization-group / training step**, modeled as the diagonal flow on
mode space that rescales each spectral mode `i` by its gain `1 - lr*(lam i)`. -/
def rgStep {d : ℕ} (lr : ℝ) (lam : Fin d → ℝ) (v : Fin d → ℝ) : Fin d → ℝ :=
  fun i => gain lr (lam i) * v i

-- !-- Induction on `k`: `iterate_succ_apply'` peels one step, then `pow_succ`. -- !--
/-- **Closed form of the RG flow.** Iterating the diagonal step `k` times multiplies
each mode by `g_i^k`: `(rgStep)^[k] v i = (gain lr (lam i))^k * v i`. This is the
multi-mode generalization of `NTKSpectral.ntk_mode_decay`. -/
theorem rgStep_iterate {d : ℕ} (lr : ℝ) (lam : Fin d → ℝ) (v : Fin d → ℝ)
    (i : Fin d) :
    ∀ k, ((rgStep lr lam)^[k] v) i = (gain lr (lam i)) ^ k * v i := by
  intro k
  induction k with
  | zero => simp
  | succ k ih =>
    rw [Function.iterate_succ_apply']
    simp only [rgStep]
    rw [ih, pow_succ]; ring

-- !-- `Function.iterate_add_apply` splits the iterate of a sum of scales. -- !--
/-- **RG semigroup law.** The training/RG steps form a discrete one-parameter
semigroup: coarse-graining to scale `k + m` equals coarse-graining to scale `m`
and then to scale `k`. -/
theorem rgStep_semigroup {d : ℕ} (lr : ℝ) (lam : Fin d → ℝ) (v : Fin d → ℝ)
    (k m : ℕ) :
    (rgStep lr lam)^[k + m] v = (rgStep lr lam)^[k] ((rgStep lr lam)^[m] v) :=
  Function.iterate_add_apply (rgStep lr lam) k m v

-- !-- Read off coordinatewise: the IR fixed condition `(1-lr·lam_i)v_i = v_i`
--     simplifies to `lr·(lam_i·v_i)=0`, and `lr ≠ 0` cancels. -- !--
/-- **IR fixed points = NTK kernel.** A residual is a fixed point of the training/RG
flow iff every active NTK eigenvalue annihilates it (`lam i * v i = 0` for all `i`).
Equivalently, the flow halts exactly on the kernel of the NTK — its infrared fixed
manifold. -/
theorem rgStep_fixed_iff {d : ℕ} (lr : ℝ) (lam : Fin d → ℝ) (hlr : lr ≠ 0)
    (v : Fin d → ℝ) :
    rgStep lr lam v = v ↔ ∀ i, lam i * v i = 0 := by
  constructor;
  · intro h i; have := congr_fun h i; simp_all +decide [ rgStep, gain ] ;
    exact Classical.or_iff_not_imp_right.2 fun hi => mul_left_cancel₀ hi <| mul_left_cancel₀ hlr <| by linarith;
  · intro h; ext i; simp +decide [ *, rgStep, gain ] ;
    grind

-- !-- `rgStep_iterate` writes the ratio as `(|g_i|/|g_j|)^k · (|v_i|/|v_j|)`;
--     the base is `< 1`, so the geometric sequence times a constant tends to `0`. -- !--
/-- **Separation of scales (integrating out high-frequency modes).** If mode `i`
contracts strictly faster than mode `j` (`|g_i| < |g_j|`), then the relative
amplitude of the fast mode `i` to the slow mode `j` tends to `0` along the RG flow.
The high-frequency mode is asymptotically negligible — exactly the
renormalization-group act of integrating it out. (In the physically relevant regime
`v j ≠ 0` this is an honest amplitude ratio; the statement also holds trivially when
`v j = 0`, where the quotient is identically `0`.) -/
theorem rg_scale_separation {d : ℕ} (lr : ℝ) (lam : Fin d → ℝ) (v : Fin d → ℝ)
    (i j : Fin d)
    (hlt : |gain lr (lam i)| < |gain lr (lam j)|) :
    Tendsto (fun k => |((rgStep lr lam)^[k] v) i| / |((rgStep lr lam)^[k] v) j|)
      atTop (nhds 0) := by
  -- By `rgStep_iterate`, the k-th term equals `|(gain lr (lam i))^k * v i| / |(gain lr (lam j))^k * v j| = (|gain lr (lam i)|^k * |v i|) / (|gain lr (lam j)|^k * |v j|)`.
  have h_ratio : ∀ k, |(rgStep lr lam)^[k] v i| / |(rgStep lr lam)^[k] v j| = (|gain lr (lam i)| / |gain lr (lam j)|) ^ k * |v i| / |v j| := by
    intro k; rw [ rgStep_iterate, rgStep_iterate ] ; simp +decide [ 
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: Neural Network Training as Renormalization-Group Flow

## Synthesis

This cycle takes the spectral theory of NTK training already in the catalog
(`MachineLearning/NTKSpectral.lean`: `ntkGram`, `ntk_mode_decay`,
`optimal_lr_contraction`, `ntk_optimal_tendsto_zero`) and recasts it as a
**discrete renormalization-group (RG) flow** in `MachineLearning/RGFlowTraining.lean`.
A single gradient step becomes a diagonal flow `rgStep` on the space of spectral
modes, rescaling each mode `i` by its gain `g_i = 1 - η λ_i`. From this one object
we proved, fully `sorry`-free and on only the standard axioms:

* `rgStep_iterate` — the flow's closed form `g_i^k v_i` (multi-mode lift of
  `NTKSpectral.ntk_mode_decay`);
* `rgStep_semigroup` — training steps form a one-parameter RG semigroup;
* `rg_scale_separation` — fast (high-frequency) modes vanish *relative* to slow
  modes: the precise sense in which training "integrates out" UV degrees of freedom;
* `rgStep_fixed_iff` — the IR fixed manifold of the flow is exactly the kernel of
  the NTK;
* `rg_flow_tendsto_zero` — contracting spectra flow to the IR fixed point
  (multi-mode lift of `NTKSpectral.ntk_optimal_tendsto_zero`).

## Results Summary

The "training = RG flow" slogan is now a theorem-level dictionary:
gain ↔ RG eigenvalue, eigenvalue magnitude ↔ scaling dimension (relevant vs.
irrelevant), NTK kernel ↔ IR fixed point, geometric mode ratio ↔ separation of
scales. The whole development is diagonal and discrete by design, which is what made
clean, axiom-minimal proofs possible while staying faithful to what optimizers run.

## Research Directions

### 1. A genuine RG group law with explicit scaling dimensions
The current `rgStep_semigroup` is the additive iterate law; the next step is to
define a *continuous-time* flow `Φ_t v i = exp(-t λ_i) v_i` and prove `Φ_s ∘ Φ_t =
Φ_{s+t}` together with the eigenvalue's role as a **scaling dimension**: mode `i` is
relevant, marginal, or irrelevant according to `λ_i <, =, > 0` (about a shifted
fixed point). **The key insight is** that gradient flow is literally a heat
semigroup in the NTK eigenbasis, so RG "scaling dimensions" are NTK eigenvalues and
the relevant/irrelevant trichotomy is a sign condition. *Why now?* `rgStep_iterate`
already gives the discrete analogue, and Mathlib's `Real.exp` semigroup lemmas make
the continuous law a short reach — turning a discrete picture into a true flow.

### 2. Universality / scaling collapse of the loss curve
Conjecture: under `rg_flow_tendsto_zero` the training loss
`L_k = ∑_i (g_i^k v_i)^2` obeys a **two-regime scaling law** — an early plateau set
by the slowest mode `g_max = max_i |g_i|` and a final rate `L_k ≍ g_max^{2k}` — and
the rescaled curve `L_k / g_max^{2k}` converges to a mode-count constant independent
of the data. **The key insight is** that the slowest relevant mode dominates the
long-time flow, so the loss curve is universal up to the single number `g_max`, a
direct analogue of critical-expo
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
