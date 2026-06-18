
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

**Title**: Neural Network Training as Renormalization Group Flow
**Domain**: Applications
**Mathematical framing**: The key insight is that neural network training is a renormalization group (RG) flow in function space. Each training step integrates out high-frequency modes (gradient descent on fast-varying parameters), just as each RG step integrates out short-distance modes. Conjecture: The fixed points of SGD on neural networks are precisely the critical points of a renormalization group flow defined by the coarse-graining operator that averages over parameter subsets. Why now: recent work on neural network Gaussian processes shows that infinite-width networks have exact RG fixed points, and the beta function of SGD training has been computed for linear networks. Test: prove that for a 2-layer ReLU network trained on isotropic data, the SGD fixed point corresponds to the Wilson-Fisher fixed point in d=2 dimensions, and compute the critical exponents. Impact: neural network training would be governed by universality classes, meaning the same network trained on different data converges to the same fixed point if the data distribution is in the same universality class.
Research domain: Applications
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/MachineLearning/RGFlowTraining.lean
/-
# Neural Network Training as Renormalization Group Flow

This file formalizes the rigorous mathematical core of the idea that
**neural-network training is a renormalization-group (RG) flow in parameter
space**.  The conceptual dictionary is:

* A *coarse-graining* (RG) step is modelled by an **idempotent linear operator**
  `P : V →ₗ[ℝ] V` on the parameter inner-product space `V`.  `P` "integrates
  out" the high-frequency / fast modes, keeping only the slow, relevant modes
  in its range.
* An *RG fixed point* is a parameter vector `θ` with `P θ = θ`, i.e. a vector
  that survives coarse-graining unchanged.
* A *training (SGD / gradient-flow) fixed point* is a critical point of the
  loss.  For the natural quadratic relevance loss
  `L(θ) = ½‖θ - P θ‖²`, whose gradient is the **residual operator**
  `R = id - P` (the "irrelevant content removed by coarse graining"), the
  critical points are exactly `{θ : R θ = 0}`.

The main results prove that these two notions of fixed point **coincide**, that
the continuous-time training flow `θ'(t) = -R(θ(t))` is an explicit exponential
relaxation onto the RG fixed-point manifold (the slope of the SGD beta-function
being the critical exponent `1`), and that the limiting fixed point depends only
on `P θ₀` — a **universality** statement: two data/initialisations in the same
coarse-grained class converge to the same fixed point.

This extends the finite-dimensional NTK / gradient-flow algebra in
`Catalog/MachineLearning/NTKCore.lean` (Jacot–Gabriel–Hongler lazy-training
dynamics) by giving the gradient flow an RG interpretation via an idempotent
coarse-graining operator.

## Theorem catalogue

1. `rgResidual_apply`            — `R θ = θ - P θ`. (definitional unfolding)
2. `rg_sgd_fixedPoint_iff`       — SGD fixed point `R θ = 0` ↔ RG fixed point `P θ = θ`.
3. `rg_fixedPoint_iff_mem_range` — for idempotent `P`, `P θ = θ` ↔ `θ ∈ range P`.
4. `rgFlow_zero`                 — the flow starts at the initial condition.
5. `rgFlow_proj`                 — `P` is conserved along the flow (slow modes are invariant).
6. `rgFlow_hasDerivAt`           — the flow solves the gradient ODE `θ' = -R θ`.
7. `rgFlow_dist`                 — exact exponential decay `‖θ(t) - Pθ₀‖ = e^{-t}‖Rθ₀‖`.
8. `rgFlow_tendsto`              — convergence to the RG fixed point `P θ₀`.
9. `rgFlow_limit_isFixedPoint`   — the limit is a genuine RG (and SGD) fixed point.
10. `rg_universality`            — same coarse-grained class ⇒ same limiting fixed point.
-/

import Mathlib

open Filter Topology

noncomputable section

variable {V : Type*} [NormedAddCommGroup V] [InnerProductSpace ℝ V]

/-- The **RG residual operator** `R = id - P`.  It extracts the "irrelevant"
content that a coarse-graining step `P` removes.  It is the gradient of the
quadratic relevance loss `L(θ) = ½‖θ - Pθ‖²` when `P` is an orthogonal
projection. -/
def rgResidual (P : V →ₗ[ℝ] V) : V →ₗ[ℝ] V := LinearMap.id - P

@[simp] theorem rgResidual_apply (P : V →ₗ[ℝ] V) (x : V) :
    rgResidual P x = x - P x := rfl

-- !-- `R θ = 0 ↔ Pθ = θ`: the gradient/SGD fixed points are exactly the RG
-- fixed points, by `sub_eq_zero`. This is the rigorous core of the conjecture. -- !--
/-- **SGD ↔ RG fixed-point correspondence.**  A parameter vector is a critical
point of the relevance loss (`R θ = 0`) iff it is a fixed point of the
coarse-graining / renormalization-group step (`P θ = θ`). -/
theorem rg_sgd_fixedPoint_iff (P : V →ₗ[ℝ] V) (x : V) :
    rgResidual P x = 0 ↔ P x = x := by
  rw [rgResidual_apply, sub_eq_zero, eq_comm]

-- !-- For idempotent `P`, fixed points are exactly the range: `←` uses `P²=P`. -- !--
/-- For an idempotent coarse-graining operator, the RG fixed points are exactly
the range of `P` (the manifold of "relevant" / slow configurations). -/
theorem rg_fixedPoint_iff_mem_range (P : V →ₗ[ℝ] V) (hP : ∀ x, P (P x) = P x)
    (x : V) : P x = x ↔ x ∈ Set.range P := by
  constructor
  · intro h; exact ⟨x, h⟩
  · rintro ⟨y, rfl⟩; exact hP y

/-- The **renormalization-group training flow** with coarse-graining operator
`P` started at `x₀`.  It is the closed-form solution of the gradient ODE
`θ'(t) = -R(θ(t))`: the slow component `P x₀` is frozen and the irrelevant
component `x₀ - P x₀` relaxes exponentially to zero. -/
def rgFlow (P : V →ₗ[ℝ] V) (x₀ : V) (t : ℝ) : V :=
  P x₀ + Real.exp (-t) • (x₀ - P x₀)

@[simp] theorem rgFlow_zero (P : V →ₗ[ℝ] V) (x₀ : V) : rgFlow P x₀ 0 = x₀ := by
  simp [rgFlow]

-- !-- `P` is linear and idempotent so `P(rgFlow t) = P x₀`: the slow modes are
-- conserved along the flow (RG invariance of relevant couplings). -- !--
/-- The coarse-grained (slow / relevant) part of the parameters is **conserved**
along the training flow. -/
theorem rgFlow_proj (P : V →ₗ[ℝ] V) (hP : ∀ x, P (P x) = P x) (x₀ : V) (t : ℝ) :
    P (rgFlow P x₀ t) = P x₀ := by
  simp only [rgFlow, map_add, map_smul, map_sub, hP]
  simp

-- !-- Differentiate the closed form: `d/dt e^{-t}•c = -e^{-t}•c`; then
-- `-R(flow t) = -(flow t - P x₀) = -e^{-t}•(x₀-Px₀)` using `rgFlow_proj`. -- !--
/-- **The flow solves the gradient ODE** `θ'(t) = -R(θ(t))`.  This identifies
the closed form `rgFlow` with the continuous-time gradient descent on the
relevance loss whose gradient is the RG residual `R`. -/
theorem rgFlow_hasDerivAt (P : V →ₗ[ℝ] V) (hP : ∀ x, P (P x) = P x) (x₀ : V)
    (t : ℝ) :
    HasDerivAt (rgFlow P x₀) (-(rgResidual P) (rgFlow P x₀ t)) t := by
  have hexp : HasDerivAt (fun s : ℝ => Real.exp (-s)) (-Real.exp (-t)) t := by
    have := (Real.hasDerivAt_exp (-t)).comp t ((hasDerivAt_id t).neg)
    simpa using this
  have hderiv : HasDerivAt (rgFlow P x₀) ((-Real.exp (-t)) • (x₀ - P x₀)) t := by
    have h := (hexp.smul_const (x₀ - P x₀)).const_add (P x₀)
    exact h
  -- rewrite the target derivative into the same shape
  have hres : -(rgResidual P) (rgFlow P x₀ t) = (-Real.exp (-t)) • (x₀ - P x₀) := by
    rw [rgResidual_apply, rgFlow_proj P hP]
    simp only [rgFlow]
    abel_nf
    module
  rw [hres]; exact hderiv

-- !-- `rgFlow t - P x₀ = e^{-t}•(x₀-Px₀)`, take norms and `‖c•v‖ = |c|‖v‖`. -- !--
/-- **Exact exponential relaxation.**  The distance from the running parameters
to the fixed point decays as `e^{-t}`; the unit rate is the critical exponent /
slope of the SGD beta-function for the irrelevant direction. -/
theorem rgFlow_dist (P : V →ₗ[ℝ] V) (x₀ : V) (t : ℝ) :
    ‖rgFlow P x₀ t - P x₀‖ = Real.exp (-t) * ‖x₀ - P x₀‖ := by
  have : rgFlow P x₀ t - P x₀ = Real.exp (-t) • (x₀ - P x₀) := by
    simp [rgFlow]
  rw [this, norm_smul, Real.norm_eq_abs, abs_of_pos (Real.exp_pos _)]

-- !-- `‖flow t - P x₀‖ = e^{-t}‖x₀-Px₀‖ → 0`, so flow → P x₀ via
-- `tendsto_iff_norm_sub_tendsto_zero`. -- !--
/-- **Convergence to the RG fixed point.**  Every training trajectory converges
to the coarse-grained projection `P x₀` of its initialisation. -/
theorem rgFlow_tendsto (P : V →ₗ[ℝ] V) (x₀ : V) :
    Tendsto (rgFlow P x₀) atTop (nhds (P x₀)) := by
  rw [tendsto_iff_norm_sub_tendsto_zero]
  have hzero : Tendsto (fun t : ℝ => Real.exp (-t) * ‖x₀ - P x₀‖) atTop (nhds 0) := by
    have := Real.tendsto_exp_neg_atTop_nhds_zero.mul_const ‖x₀ - P x₀‖
    simpa using this
  refine hzero.congr ?_
  intro t
  rw [rgFlow_dist]

-- !-- The limit `P x₀` satisfies `P(Px₀)=Px₀` by idempotency. -- !--
/-- The limiting point of the training flow is a genuine **RG fixed point**
(equivalently, an SGD critical point by `rg_sgd_fixedPoint_iff`). -/
theorem rgFlow_limit_isFixedPoint (P : V →ₗ[ℝ] V) (hP : ∀ x, P (P x) = P x)
    (x₀ : V) : P (P x₀) = P x₀ := hP x₀

-- !-- Both limits equal `P x₀ = P y₀` by `rgFlow_tendsto`. -- !--
/-- **Universality.**  If two initialisations (or data distributions) lie in the
same coarse-grained class, `P x₀ = P y₀`, then their training flows converge to
the *same* RG fixed point.  The fixed point is determined entirely by the
universality class `P x₀`, not by the microscopic initialisation. -/
theorem rg_universality
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: Neural Network Training as Renormalization Group Flow

The file `RGFlowTraining.lean` establishes a rigorous, machine-checked core of
the analogy *training = renormalization-group (RG) flow*. We model a
coarse-graining step by an idempotent linear operator `P` on parameter space,
identify the residual `R = id - P` as the gradient of the quadratic relevance
loss `½‖θ - Pθ‖²`, and prove that:

* SGD critical points (`R θ = 0`) **coincide** with RG fixed points (`P θ = θ`);
* the closed-form flow `rgFlow` solves the gradient ODE `θ' = -Rθ`;
* it relaxes exponentially (`‖θ(t) − Pθ₀‖ = e^{-t}‖Rθ₀‖`) onto the fixed-point
  manifold (range of `P`);
* the limit is determined solely by the coarse-grained class `Pθ₀`
  (**universality**: `rg_universality`); and
* each irrelevant eigenmode of the linearized beta-operator decays at its own
  critical rate `λ` (`rg_spectral_decay`).

These results build on and complement the finite-dimensional NTK / lazy-training
algebra in `NTKCore.lean` (Jacot–Gabriel–Hongler), where gradient flow under a
fixed kernel `K` gives `u_t = (I − ηK)^t u₀`. The RG viewpoint reinterprets the
fixed kernel's spectral projections as coarse-graining operators.

Below are five testable, falsifiable directions that extend this work.

## 1. Multi-mode spectral RG flow and the full critical spectrum

We proved single-mode decay (`rg_spectral_decay`). The next step is to assemble
the modes: for a self-adjoint coarse-graining beta-operator `A`, prove that the
flow `e^{-tA} x₀` converges to the orthogonal projection of `x₀ onto ker A`,
decomposing the trajectory over the eigenbasis with mode-specific rates.

**The key insight is** that the orthogonal projection `P` onto `ker A` is itself
the RG fixed-point operator, so the spectral theorem turns "the flow forgets
irrelevant modes" into "negative/zero eigenspaces of the beta-function are the
relevant/marginal couplings." **Why now?** Mathlib now has the finite-dimensional
spectral theorem (`LinearMap.IsSymmetric.orthogonalComplement_iSup_eigenspaces`
and `DiagonalizableOn` machinery), so the eigen-decomposition that previously
forced a `sorry` is within reach. *Falsifiable:* if some eigenmode failed to
decay at exactly rate `λ`, `rgFlow_dist`'s generalization would be violated.

## 2. Idempotency is necessary as well as sufficient

We assumed `P` idempotent. Conjecture: among bounded linear `P`, the
fixed-point/range correspondence `rg_fixedPoint_iff_mem_range` holds for *all*
`x` **iff** `P` is idempotent on its range. Formalize the converse and the exact
hypothesis class for which "coarse-graining is a projection" is forced.

**The key insight is** that a coarse-graining operator must be a retraction onto
the manifold of relevant configurations — applying it twice cannot remove more
than applying it once — which is precisely idempotency. **Why now?** With the
clean separation of `rgResidual` and `rgFlow`, the converse is a short linear
algebra argument and pins down the 
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
