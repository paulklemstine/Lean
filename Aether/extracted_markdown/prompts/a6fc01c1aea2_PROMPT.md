
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

**Title**: Close Proofs: The file `HodgeSpectralThreshold.lean` extracts a rigorous, sorry-free
**Domain**: Applications
**Mathematical framing**: Cycle 24946444 (Q=0.683) proved 47 theorems in Novelty but left 1 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: # Future Directions — Spectral Depth Thresholds for Hodge-Laplacian Message Passing

## Synthesis

The file `HodgeSpectralThreshold.lean` extracts a rigorous, sorry-free linear-algebraic
skeleton from
Research domain: Applications
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/MachineLearning/HodgeSpectralThreshold.lean
/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Spectral Depth Thresholds for Hodge–Laplacian Message Passing

This file extracts a rigorous, sorry-free linear-algebraic skeleton for the theory of
*spectral depth thresholds* governing message passing with the combinatorial Hodge
Laplacian on a simplicial complex / cell complex.

The Hodge Laplacian on `k`-cochains is built from a coboundary/incidence matrix `B`
as the "up" Laplacian `L = Bᵀ B`.  A single layer of (gradient-descent style) message
passing acts by `x ↦ x - α (L *ᵥ x)`.  Two phenomena are made precise:

* **Homotopy invariance of harmonic signals.**  The kernel of `L` is the space of
  *harmonic* cochains, which (by the discrete Hodge theorem) is isomorphic to a
  cohomology group and is therefore a homotopy/topological invariant.  We prove that
  harmonic signals are *exact fixed points* of message passing at every depth: they
  pass through arbitrarily deep networks undistorted.

* **Spectral contraction off the harmonic core.**  On the complement (signals carrying
  Dirichlet energy), message passing contracts the energy by a factor governed by the
  spectral gap.  Iterating contracts geometrically, yielding a *finite spectral depth
  threshold*: for any tolerance `ε`, finitely many layers suffice to drive the residual
  below `ε`.

## Main results

* `hodge_isSymm`               — the Hodge Laplacian `Bᵀ B` is symmetric.
* `hodge_quadform`             — `⟨x, Lx⟩ = ‖B x‖²` (Dirichlet energy identity).
* `hodge_psd`                  — `L` is positive semidefinite.
* `harmonic_iff_boundary`      — discrete Hodge theorem: `Lx = 0 ↔ Bx = 0`.
* `mpStep_fixes_harmonic`      — harmonic signals are fixed by one layer.
* `mpStep_iterate_fixes_harmonic` — harmonic signals are fixed at every depth.
* `quadform_mpStep`            — exact energy expansion of one layer.
* `mpStep_contraction`         — one-layer spectral contraction under a gap hypothesis.
* `quadform_iterate_bound`     — geometric energy decay over depth.
* `spectral_depth_threshold`   — finitely many layers suffice to reach any tolerance.

## Catalog synthesis

This bridges the *MachineLearning* domain (graph/simplicial neural networks, the
oversmoothing phenomenon) with the *homotopy & path-space* program: the harmonic kernel
is exactly the homotopy-invariant part of a signal, and message passing is a discrete
deformation that fixes invariants while contracting everything else.  It extends the
spirit of the catalog's spectral results (e.g. expander / spectral-gap machinery in
`Algebra/ClassicalGroupExpanders` and `Algebra/ExpanderWalk/Amplification`) from scalar
graph Laplacians to the higher Hodge Laplacian on cochains.
-/
import Mathlib

namespace HodgeSpectralThreshold

open Matrix

variable {m n : ℕ}

-- !-- Lab Notebook -- !--
-- Hypothesis: The combinatorial Hodge Laplacian `L = Bᵀ B` should behave as a symmetric
--   PSD operator whose kernel (harmonic cochains) is fixed by message passing while the
--   energy-carrying complement contracts geometrically with depth.
-- Result: All ten statements below are proven sorry-free; the contraction is fully
--   quantitative (factor `1 - αμ(2 - αλ)`) and yields a finite depth threshold.
-- Insight: The Dirichlet-energy identity `⟨x,Lx⟩ = ⟨Bx,Bx⟩` is the linchpin — it turns
--   both PSD-ness and the discrete Hodge theorem into one-line consequences of
--   `dotProduct`-self positivity, and turns the contraction into pure `nlinarith`.
-- Failure analysis: `positivity` cannot see through the `dotProduct` sum (entries are
--   `v i * v i`, not `(v i)^2`); we unfold to `Finset.sum_nonneg` + `mul_self_nonneg`.
--   The spectral-gap nonnegativity `0 ≤ μ` turned out logically unnecessary for the
--   one-step contraction, so the stated theorem is strictly more general.
-- !-- end Lab Notebook -- !--

/-- The "up" combinatorial Hodge Laplacian associated with a coboundary/incidence
matrix `B`. -/
def hodge (B : Matrix (Fin m) (Fin n) ℝ) : Matrix (Fin n) (Fin n) ℝ := Bᵀ * B

/-- One layer of (gradient-descent style) Hodge message passing with step size `α`:
`x ↦ x - α (L x)`. -/
def mpStep (L : Matrix (Fin n) (Fin n) ℝ) (α : ℝ) (x : Fin n → ℝ) : Fin n → ℝ :=
  x - α • (L *ᵥ x)

-- !-- The transpose of `Bᵀ B` is `Bᵀ B` since `(Bᵀ B)ᵀ = Bᵀ (Bᵀ)ᵀ = Bᵀ B`. -- !--
theorem hodge_isSymm (B : Matrix (Fin m) (Fin n) ℝ) : (hodge B).IsSymm := by
  simp [hodge, Matrix.IsSymm, Matrix.transpose_mul]

-- !-- `⟨x, (BᵀB)x⟩ = ⟨x, Bᵀ(Bx)⟩ = ⟨Bx, Bx⟩` via `mulVec_mulVec`, `dotProduct_mulVec`,
--    and `vecMul_transpose`; this is the discrete Dirichlet energy. -- !--
theorem hodge_quadform (B : Matrix (Fin m) (Fin n) ℝ) (x : Fin n → ℝ) :
    x ⬝ᵥ (hodge B) *ᵥ x = (B *ᵥ x) ⬝ᵥ (B *ᵥ x) := by
  unfold hodge
  rw [← Matrix.mulVec_mulVec, Matrix.dotProduct_mulVec, Matrix.vecMul_transpose]

-- !-- The Dirichlet energy is a sum of squares, hence nonnegative. -- !--
theorem hodge_psd (B : Matrix (Fin m) (Fin n) ℝ) (x : Fin n → ℝ) :
    0 ≤ x ⬝ᵥ (hodge B) *ᵥ x := by
  rw [hodge_quadform]
  exact Finset.sum_nonneg fun i _ => mul_self_nonneg _

-- !-- Discrete Hodge theorem: `Lx = 0 ↔ Bx = 0`.  The `←` is `mulVec_mulVec`; the `→`
--    pushes `Lx = 0` into `⟨Bx,Bx⟩ = 0`, then `dotProduct_self_eq_zero`. -- !--
theorem harmonic_iff_boundary (B : Matrix (Fin m) (Fin n) ℝ) (x : Fin n → ℝ) :
    (hodge B) *ᵥ x = 0 ↔ B *ᵥ x = 0 := by
  constructor
  · intro h
    have hq : (B *ᵥ x) ⬝ᵥ (B *ᵥ x) = 0 := by
      rw [← hodge_quadform, h, dotProduct_zero]
    exact dotProduct_self_eq_zero.mp hq
  · intro h
    unfold hodge
    rw [← Matrix.mulVec_mulVec, h, Matrix.mulVec_zero]

-- !-- If `Lx = 0` then `x - α(Lx) = x - 0 = x`. -- !--
theorem mpStep_fixes_harmonic (L : Matrix (Fin n) (Fin n) ℝ) (α : ℝ) (x : Fin n → ℝ)
    (hx : L *ᵥ x = 0) : mpStep L α x = x := by
  unfold mpStep
  rw [hx, smul_zero, sub_zero]

-- !-- Harmonic signals are fixed at every depth: induction on `k`, applying
--    `mpStep_fixes_harmonic` at the outermost layer. -- !--
theorem mpStep_iterate_fixes_harmonic (L : Matrix (Fin n) (Fin n) ℝ) (α : ℝ)
    (x : Fin n → ℝ) (hx : L *ᵥ x = 0) (k : ℕ) : (mpStep L α)^[k] x = x := by
  induction k with
  | zero => simp
  | succ k ih => rw [Function.iterate_succ_apply', ih]; exact mpStep_fixes_harmonic L α x hx

-- !-- Exact energy expansion `‖x - αLx‖² = ‖x‖² - 2α⟨x,Lx⟩ + α²‖Lx‖²` via bilinearity
--    of `dotProduct`. -- !--
theorem quadform_mpStep (L : Matrix (Fin n) (Fin n) ℝ) (α : ℝ) (x : Fin n → ℝ) :
    (mpStep L α x) ⬝ᵥ (mpStep L α x)
      = (x ⬝ᵥ x) - 2 * α * (x ⬝ᵥ (L *ᵥ x)) + α ^ 2 * ((L *ᵥ x) ⬝ᵥ (L *ᵥ x)) := by
  unfold mpStep
  simp [dotProduct, mul_sub, mul_assoc, mul_comm, mul_left_comm]
  simpa only [← Finset.mul_sum _ _ _, ← Finset.sum_mul] using by ring

-- !-- One-layer spectral contraction.  With spectral-gap lower bound `μ‖x‖² ≤ ⟨x,Lx⟩`,
--    operator bound `‖Lx‖² ≤ λ⟨x,Lx⟩`, and admissible step `0 ≤ α`, `αλ ≤ 2`, the energy
--    expansion plus `nlinarith` give the contraction factor `1 - αμ(2 - αλ)`. -- !--
theorem mpStep_contraction (L : Matrix (Fin n) (Fin n) ℝ) (α μ lam : ℝ) (x : Fin n → ℝ)
    (hα0 : 0 ≤ α) (hαlam : α * lam ≤ 2)
    (hgap : μ * (x ⬝ᵥ x) ≤ x ⬝ᵥ (L *ᵥ x))
    (hbound : (L *ᵥ x) ⬝ᵥ (L *ᵥ x) ≤ lam * (x ⬝ᵥ (L *ᵥ x))) :
    (mpStep L α x) ⬝ᵥ (mpStep L α x) ≤ (1 - α * μ * (2 - α * lam)) * (x ⬝ᵥ x) := by
  rw [quadform_mpStep]
  nlinarith [mul_nonneg hα0 (sub_nonneg_of_le hαlam),
    mul_le_mul_of_nonneg_left hgap hα0, mul_le_mul_of_nonneg_left hbound hα0]

-- !-- Geometric energy decay over depth: if each layer `T` contracts the quadratic
--    form by `ρ ≥ 0`, then `k` layers contract by `ρ^k`.  Induction on `k`, multiplying
--    the inductive bound by `ρ ≥ 0`. -- !--
theorem quadform_iterate_bound (T : (Fin n → ℝ) → (Fin n → ℝ)) (ρ : ℝ) (hρ : 0 ≤ ρ)
    (hstep : ∀ y, (T y) ⬝ᵥ (T y) ≤ ρ * (y ⬝ᵥ y)) (x : Fin n → ℝ) (k : ℕ) :
    (T^[k] x) ⬝ᵥ (T^[k] x) ≤ ρ ^ k * (x ⬝ᵥ x) := 
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — Spectral Depth Thresholds for Hodge–Laplacian Message Passing

## Synthesis

The file `Catalog/MachineLearning/HodgeSpectralThreshold.lean` extracts a rigorous,
sorry-free linear-algebraic skeleton for *spectral depth thresholds* in higher-order
message passing. The combinatorial Hodge Laplacian `L = Bᵀ B` is realized as a symmetric
positive-semidefinite operator whose Dirichlet energy `⟨x, L x⟩ = ⟨B x, B x⟩` is the
single identity from which everything else flows. Two regimes are made precise and
proven in full:

* **Homotopy-invariant core.** Harmonic cochains — the kernel of `L`, isomorphic by the
  discrete Hodge theorem to a cohomology group — are *exact fixed points* of message
  passing at every depth (`mpStep_iterate_fixes_harmonic`). Topology survives arbitrarily
  deep networks undistorted.
* **Contractive complement.** On energy-carrying signals, one layer contracts the energy
  by the quantitative factor `1 - αμ(2 - αλ)` (`mpStep_contraction`); iterating contracts
  geometrically (`quadform_iterate_bound`), so for any tolerance `ε` only finitely many
  layers are needed (`spectral_depth_threshold`).

The conceptual payload is a unification: message passing is a *discrete deformation
retraction* onto the harmonic (homotopy-invariant) subspace, and "depth" is the
continuous-time parameter of that retraction. This is the Homotopy & Path-Space lens
applied to learning on cell complexes.

## Results summary

| Theorem | Statement |
|---|---|
| `hodge_isSymm` | `Bᵀ B` is symmetric |
| `hodge_quadform` | `⟨x, L x⟩ = ⟨B x, B x⟩` (Dirichlet energy) |
| `hodge_psd` | `L` is positive semidefinite |
| `harmonic_iff_boundary` | discrete Hodge: `L x = 0 ↔ B x = 0` |
| `mpStep_fixes_harmonic` / `..._iterate_...` | harmonic signals fixed at every depth |
| `quadform_mpStep` | exact one-layer energy expansion |
| `mpStep_contraction` | one-layer contraction factor `1 - αμ(2 - αλ)` |
| `quadform_iterate_bound` | geometric energy decay `ρ^k` |
| `spectral_depth_threshold` | finite depth suffices for any tolerance |

All proofs use only `propext`, `Classical.choice`, `Quot.sound`.

## Research directions

### 1. The retraction is a deformation onto the harmonic subspace (orthogonal splitting)
Conjecture: with the admissible step `0 < α < 2/λ_max`, the message-passing flow `mpStep`
restricted to the `⟨·,·⟩`-orthogonal complement of `ker L` is a strict contraction, so
the iterate `(mpStep L α)^[k]` converges to the orthogonal projection `P_ker` onto the
harmonic subspace, and `‖(mpStep L α)^[k] x − P_ker x‖² ≤ (1 − αμ(2 − αλ))^k ‖x − P_ker x‖²`.
This is falsifiable: a single complex with an eigenvalue outside `(0, 2/α)` would exhibit
non-contraction or oscillation. **The key insight is** that `quadform_iterate_bound`
already gives the geometric rate on any invariant subspace, so the missing ingredient is
purely the invariance `mpStep L α '' (ker L)ᗮ ⊆ (ker L)ᗮ`, which follows from self-adjointness
of `L`. **Why now?** The orthogonal p
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
