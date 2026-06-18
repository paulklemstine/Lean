## Assignment: Neural Tangent Kernel in the Tropical Limit

Mode: **prove**

Aristotle, do not treat this as an incremental “tropicalization of one more ML object.” The target is a genuine bridge theorem between infinite-width learning theory, polyhedral/tropical geometry, and variational dynamics. The breakthrough is to isolate a formally checkable regime in which the classical NTK collapses to a min-plus kernel, and then prove that the induced training flow is not merely analogous to, but exactly representable as, a tropical piecewise-linear gradient flow with rigid flat directions. If successful, this opens a new field: **tropical kernel dynamics**.

You already have a crucial seed theorem:
- `tropical_net_constant_along_flat_directions`
  in `MachineLearning/Neural/TropicalNTK.lean`

This should not remain an isolated invariance lemma. Upgrade it into a structural theorem identifying when the NTK regime is lazy, when feature motion is visible, and how tropical flatness controls both.

---

## Core Theorem Targets

You should introduce precise formal definitions if they do not yet exist, but keep them concrete and Lean-friendly: finite input type, finite hidden width approximants, Real-valued kernels, polyhedral/tropical predictors.

Work with a finite input space `X := Fin n → ℝ` or simply indexed samples `Fin N`, so all kernels can be represented as matrices. This avoids measure-theoretic overhead while preserving the essential phenomenon.

### Theorem 1: Tropical NTK kernel is constant on tropical flat directions

This should strengthen the existing catalog theorem from a network-output statement to a kernel statement.

**Mathematical statement.**
Let `Φ : Θ → X → ℝ` be a tropical network map depending on parameters `θ : Θ`, and let
`K_trop θ : X → X → ℝ`
be its tropical tangent kernel defined as the min-plus analogue of the Jacobian Gram object. If `v` is a tropical flat direction at `θ`, meaning that for sufficiently small perturbations along `v`, the active tropical cells of `Φ` do not change, then
\[
\forall x,x',\quad K_{\mathrm{trop}}(\theta + tv)(x,x') = K_{\mathrm{trop}}(\theta)(x,x')
\]
for all sufficiently small `t ≥ 0`.

A finite-sample matrix version is even better:
\[
\forall i,j < N,\quad K^\mathrm{trop}_{ij}(\theta+tv)=K^\mathrm{trop}_{ij}(\theta).
\]

### Suggested Lean 4 signature
```lean
theorem tropical_ntk_constant_along_flat_directions
  {N P : ℕ}
  (net : (Fin P → ℝ) → (Fin N → ℝ))
  (K : (Fin P → ℝ) → Matrix (Fin N) (Fin N) ℝ)
  (θ v : Fin P → ℝ)
  (hflat : TropicalFlatDirection net θ v)
  (hK : IsTropicalNTK net K) :
  ∃ ε > 0, ∀ t : ℝ, 0 ≤ t → t < ε →
    K (θ + t • v) = K θ
```

If the existing API prefers pointwise equality over matrix equality, use:
```lean
theorem tropical_ntk_constant_along_flat_directions_pointwise
  {N P : ℕ}
  (net : (Fin P → ℝ) → (Fin N → ℝ))
  (K : (Fin P → ℝ) → Fin N → Fin N → ℝ)
  (θ v : Fin P → ℝ)
  (hflat : TropicalFlatDirection net θ v)
  (hK : IsTropicalNTKPointwise net K) :
  ∃ ε > 0, ∀ t : ℝ, 0 ≤ t → t < ε →
    ∀ i j, K (θ + t • v) i j = K θ i j
```

This theorem is the precise mathematical version of “tropical NTK is constant along flat directions.”

---

### Theorem 2: Tropical gradient flow preserves polyhedral cells and is linear on each cell

This is the dynamical theorem. It converts tropical training into a finite combinatorial dynamical system.

**Mathematical statement.**
Let `L : Θ → ℝ` be a tropical/polyhedral loss, e.g. a finite max/min combination of affine functions. On each cell of the polyhedral stratification where the active affine pieces are fixed, the gradient/subgradient is constant, hence the gradient flow trajectory is affine until it hits a cell boundary.

In a formal finite-dimensional statement, if `θ` lies in the relative interior of a cell `C`, then there exists `ε > 0` and a constant vector `g` such that
\[
\forall t \in [0,\varepsilon),\quad \theta(t)=\theta - t g
\]
solves tropical gradient flow on that interval.

### Suggested Lean 4 signature
```lean
theorem tropical_gradient_flow_linear_on_cell
  {P : ℕ}
  (L : (Fin P → ℝ) → ℝ)
  (θ g : Fin P → ℝ)
  (hpoly : IsPolyhedralLoss L)
  (hcell : InRelativeInteriorActiveCell L θ)
  (hgrad : TropicalCellGradient L θ = g) :
  ∃ ε > 0, ∀ t : ℝ, 0 ≤ t → t < ε →
    TropicalGradientFlowStep L θ t = θ - t • g
```

A weaker but very usable theorem is a one-step descent theorem:
```lean
theorem tropical_gradient_descent_step_eq_affine
  {P : ℕ}
  (L : (Fin P → ℝ) → ℝ)
  (θ g : Fin P → ℝ)
  (η : ℝ)
  (hη : 0 ≤ η)
  (hpoly : IsPolyhedralLoss L)
  (hcell : SameActiveCellOnSegment L θ (θ - η • g))
  (hgrad : TropicalCellGradient L θ = g) :
  TropicalGradientDescentStep L θ η = θ - η • g
```

This theorem gives you a certified finite-step version if full flow is too analytic.

---

### Theorem 3: Tropical lazy-training criterion via kernel invariance

This is the conceptual payoff. You need a theorem saying that if the tropical kernel is locally constant along the training trajectory, then the dynamics are kernel/lazy; if the trajectory crosses tropical walls, feature learning occurs.

**Mathematical statement.**
Let `θ_t` be a tropical training trajectory. If the trajectory remains inside a single tropical flat cell, then the predictor evolves according to a fixed kernel operator and no feature-learning transition occurs. Conversely, if the active cell changes, then there exists a pair of samples for which the tropical kernel changes.

A finite-sample version:
\[
\Big(\forall t < T,\ \theta_t \in C\Big) \implies \Big(\forall t < T,\ K^\mathrm{trop}(\theta_t)=K^\mathrm{trop}(\theta_0)\Big).
\]
Conversely, if there exist `t₁ < t₂` with distinct active cells, then under a nondegeneracy hypothesis,
\[
K^\mathrm{trop}(\theta_{t_1}) \neq K^\mathrm{trop}(\theta_{t_2}).
\]

### Suggested Lean 4 signature
```lean
theorem tropical_lazy_training_of_cell_invariance
  {N P : ℕ}
  (traj : ℝ → (Fin P → ℝ))
  (K : (Fin P → ℝ) → Matrix (Fin N) (Fin N) ℝ)
  (T : ℝ)
  (hT : 0 < T)
  (hcell : ∀ t, 0 ≤ t → t < T → SameTropicalCell (traj t) (traj 0))
  (hK : IsTropicalNTKTrajectory K traj) :
  ∀ t, 0 ≤ t → t < T → K (traj t) = K (traj 0)
```

and the converse/nontriviality theorem:
```lean
theorem tropical_feature_learning_of_cell_change
  {N P : ℕ}
  (traj : ℝ → (Fin P → ℝ))
  (K : (Fin P → ℝ) → Matrix (Fin N) (Fin N) ℝ)
  (t₁ t₂ : ℝ)
  (hchange : ¬ SameTropicalCell (traj t₁) (traj t₂))
  (hnd : TropicalKernelNondegenerate K traj t₁ t₂) :
  K (traj t₁) ≠ K (traj t₂)
```

This is the theorem that turns the vague slogan “feature learning vs. lazy training” into a tropical cell-combinatorics criterion.

---

## Ambitious Convergence Theorem

If you can push further, prove a width-limit approximation theorem from finite-width kernels to tropical kernels. Because full infinite-width probability may be cumbersome in Lean, formulate a deterministic surrogate first.

### Theorem 4: Min-plus degeneration of finite-width NTK to tropical kernel

Let `K_w` be a family of width-`w` kernels under a rescaling parameter `τ → 0` (temperature / log-sum-exp / softmin degeneration). Show that after the correct renormalization, `K_w^τ` converges entrywise on finite samples to `K_trop`.

### Suggested Lean 4 signature
```lean
theorem finite_width_ntk_to_tropical_kernel
  {N : ℕ}
  (Kfam : ℝ → Matrix (Fin N) (Fin N) ℝ)
  (Ktrop : Matrix (Fin N) (Fin N) ℝ)
  (hsoft : IsSoftminDegeneration Kfam Ktrop) :
  Tendsto Kfam (nhdsWithin (0 : ℝ) (Set.Ioi 0)) (𝓝 Ktrop)
```

If matrix-valued `Tendsto` is awkward, use entrywise:
```lean
theorem finite_width_ntk_to_tropical_kernel_entrywise
  {N : ℕ}
  (Kfam : ℝ → Fin N → Fin N → ℝ)
  (Ktrop : Fin N → Fin N → ℝ)
  (hsoft : IsSoftminDegenerationPointwise Kfam Ktrop) :
  ∀ i j, Tendsto (fun τ : ℝ => Kfam τ i j)
    (nhdsWithin (0 : ℝ) (Set.Ioi 0)) (𝓝 (Ktrop i j))
```

This theorem is worth pursuing because it transforms tropical NTK from metaphor into limit object.

---

## How to Build on Existing Catalog Theorems

You are not starting from zero.

1. **`tropical_net_constant_along_flat_directions`**
   - Use this as the seed invariance principle.
   - Upgrade from output constancy to Jacobian-pattern constancy, then to kernel constancy.
   - The key move: on a fixed tropical cell, active minima/maxima are fixed, so the network is affine there. Therefore its derivative data is constant, hence any Gram-type tropical kernel is constant.

2. **`tropical_plus_distributes_over_min`**
   - This is a technical engine for normalizing tropical expressions.
   - Use it to simplify active-piece expressions and show cellwise affine formulas are stable under perturbation.
   - This theorem should appear in proofs where you rewrite the network/loss on a fixed cell.

3. **`zero_cochain_constant_iff_kernel`**
   - This is unexpectedly powerful. It suggests a sheaf/cochain interpretation of local constancy.
   - Use it to recast “kernel constant on overlapping cells” as a gluing condition. If the tropical NTK is locally constant on each cell and agrees on overlaps, then it descends to a constructible kernel object on the cell complex.
   - This is the bridge to topological data analysis and sheaf-theoretic learning dynamics.

4. **`tropical_attention_prediction_constant_on_ball`**
   - This gives a robustness-style local constancy theorem.
   - Reinterpret the “ball” as a region contained in a tropical cell. Then constancy of prediction should imply constancy of active pattern, which feeds into NTK constancy.
   - This can also provide examples/counterexamples: prediction may be constant on a ball even when the kernel is not globally constant.

5. **`tropical_sum_to_min`**
   - Use this when passing from classical smoothed sums to tropical minima in degeneration arguments.
   - It is especially relevant for the width-limit/temperature-limit theorem.

---

## Proof Strategy Architectures

You need multiple routes. Here are three.

### Strategy A: Cellwise affine geometry of tropical networks
**Most promising for Lean.**

1. Define a tropical active cell decomposition of parameter space or joint parameter-input space.
2. Prove that on each cell, the network is affine and its tropical derivative/Jacobian descriptor is constant.
3. Deduce kernel constancy by explicit formula from the derivative descriptor.
4. For the loss, prove that on each active cell, the subgradient is constant, so the flow is affine until boundary hitting.

Why this is strongest:
- It is finite-dimensional, combinatorial, and highly formalizable.
- It naturally interfaces with matrices over `Fin n`.
- It converts analytic training claims into exact algebraic equalities.

### Strategy B: Softmin/log-sum-exp degeneration from classical NTK
**Most conceptually revolutionary.**

1. Define a one-parameter family of smooth approximants to the tropical network via softmin or low-temperature log-sum-exp.
2. Show pointwise convergence of outputs to the tropical predictor.
3. Show convergence of Jacobian Gram kernels entrywise to a tropical kernel formula.
4. Pass the training dynamics to the limit, obtaining tropical gradient flow as a singular limit of smooth gradient flow.

Why this matters:
- It connects mainstream infinite-width NTK theory to tropical geometry rigorously.
- It creates a formal degeneration principle analogous to semiclassical limits in physics.

Lean warning:
- Full differentiability and infinite-width limits may be heavy.
- A finite-sample, entrywise, deterministic version is likely the right first formal target.

### Strategy C: Sheaf-theoretic kernel constancy on a polyhedral complex
**Most unexpected cross-domain route.**

1. Model active-cell local kernels as a 0-cochain on the adjacency complex of tropical cells.
2. Use `zero_cochain_constant_iff_kernel` to characterize global constancy from local agreement.
3. Interpret feature learning as failure of the cochain to glue across codimension-1 walls.
4. Derive a topological obstruction theorem: lazy training corresponds to trivial kernel monodromy on the cell complex.

Why this is visionary:
- It reframes learning regimes as sheaf-theoretic obstruction classes.
- It opens the possibility of topological invariants of training trajectories.

This may be harder to close fully, but even one theorem here would be field-opening.

---

## Recommended Formal Definitions

Introduce only what you need, but introduce them sharply.

```lean
def TropicalFlatDirection
  {P N : ℕ} (net : (Fin P → ℝ) → (Fin N → ℝ))
  (θ v : Fin P → ℝ) : Prop := ...
```

Interpretation: small positive movement along `v` does not change the active tropical combinatorics.

```lean
def IsPolyhedralLoss
  {P : ℕ} (L : (Fin P → ℝ) → ℝ) : Prop := ...
```

Interpretation: `L` is given by a finite max/min of affine forms.

```lean
def SameTropicalCell
  {P : ℕ} (θ₁ θ₂ : Fin P → ℝ) : Prop := ...
```

Interpretation: same active set / same affine chart.

```lean
def TropicalCellGradient
  {P : ℕ} (L : (Fin P → ℝ) → ℝ) (θ : Fin P → ℝ) : Fin P → ℝ := ...
```

```lean
def IsTropicalNTK
  {N P : ℕ}
  (net : (Fin P → ℝ) → (Fin N → ℝ))
  (K : (Fin P → ℝ) → Matrix (Fin N) (Fin N) ℝ) : Prop := ...
```

If a full derivative formalization is too heavy, define `IsTropicalNTK` axiomatically as:
- symmetric,
- cellwise constant,
- determined by active linear pieces,
- compatible with tropical predictor increments.

That still yields meaningful theorems.

---

## Concrete Lemma Ladder

A realistic theorem-proving sequence:

1. `same_cell_implies_affine_on_segment`
2. `affine_on_cell_implies_constant_jacobian_descriptor`
3. `constant_jacobian_descriptor_implies_constant_tropical_ntk`
4. `polyhedral_loss_has_constant_subgradient_on_cell`
5. `constant_subgradient_implies_affine_gradient_flow_segment`
6. `cell_invariance_implies_lazy_training`
7. `cell_crossing_plus_nondegeneracy_implies_kernel_change`

Possible signatures:

```lean
theorem same_cell_implies_affine_on_segment
  {P N : ℕ}
  (net : (Fin P → ℝ) → (Fin N → ℝ))
  (θ₁ θ₂ : Fin P → ℝ)
  (hcell : SameTropicalCell θ₁ θ₂) :
  ∃ A : Matrix (Fin N) (Fin P) ℝ, ∃ b : Fin N → ℝ,
    ∀ t : ℝ, 0 ≤ t → t ≤ 1 →
      net ((1 - t) • θ₁ + t • θ₂) = fun i => (A.mulVec (((1 - t) • θ₁ + t • θ₂)) i) + b i
```

```lean
theorem polyhedral_loss_has_constant_subgradient_on_cell
  {P : ℕ}
  (L : (Fin P → ℝ) → ℝ)
  (θ : Fin P → ℝ)
  (hpoly : IsPolyhedralLoss L)
  (hcell : InRelativeInteriorActiveCell L θ) :
  ∃ g : Fin P → ℝ, ∃ ε > 0, ∀ δ : Fin P → ℝ,
    ‖δ‖ < ε → TropicalSubgradient L (θ + δ) = g
```

---

## Cross-Domain Connections You Must Exploit

### 1. Tropical geometry ↔ kernel methods
This project would define a new class of kernels governed by polyhedral combinatorics rather than Hilbert-space smoothness. That opens:
- tropical RKHS analogues,
- kernel interpolation on polyhedral complexes,
- combinatorial generalization bounds.

### 2. Sheaf theory ↔ learning dynamics
Using `zero_cochain_constant_iff_kernel`, interpret local kernel constancy as a gluing problem. Feature learning becomes a failure of global section constancy. This is not decorative; it suggests:
- topological certificates for lazy regimes,
- obstruction classes for representation change,
- cell-complex summaries of training.

### 3. Statistical physics / zero-temperature limits
The softmin-to-min degeneration is a true zero-temperature limit. The tropical NTK is the learning-theoretic analogue of a ground-state effective interaction. This suggests:
- phase transitions at cell boundaries,
- metastability in training,
- wall-crossing phenomena.

### 4. Hamilton–Jacobi / viscosity solutions
Polyhedral losses and tropical semirings naturally connect to max-plus control and Hamilton–Jacobi theory. Tropical gradient flow may be recast as a deterministic control limit, potentially enabling:
- comparison principles,
- stability under perturbation,
- geometric interpretation of descent paths.

### 5. Robustness and certified regions
The existing theorem `tropical_attention_prediction_constant_on_ball` suggests robustness regions are exactly tropical cells or unions of cells. Therefore:
- certified robustness = cellwise kernel invariance,
- adversarial transitions = wall crossings,
- local flatness = exact combinatorial certificate.

---

## What Would Count as a Breakthrough

A theorem merely saying “some tropicalized kernel exists” is not enough. The breakthrough threshold is one of:

1. A **formal equivalence theorem**:
   tropical flatness `↔` kernel invariance `↔` lazy training on a time interval.

2. A **degeneration theorem**:
   a concrete family of smooth kernels converges entrywise to a tropical kernel.

3. A **wall-crossing theorem**:
   feature learning occurs exactly when the trajectory crosses codimension-1 tropical walls, under nondegeneracy.

4. A **sheaf-theoretic reconstruction theorem**:
   the tropical NTK is a constructible global section assembled from cellwise constant local kernels.

Any one of these would make researchers say: “I did not expect NTK theory to become polyhedral topology.”

---

## Lean Execution Guidance

- Keep the ambient spaces finite-dimensional: `Fin P → ℝ`, `Fin N → ℝ`, and `Matrix`.
- Prefer exact cellwise statements over asymptotic probabilistic width limits unless you can reduce the latter to deterministic finite-sample convergence.
- If Fréchet derivatives are cumbersome, define a combinatorial “tropical Jacobian descriptor” from active affine pieces and prove kernel statements from that.
- Use matrix equality whenever possible; it gives a concrete finite object and simplifies extensionality.
- Minimize `sorry` by proving a ladder of exact local lemmas rather than jumping directly to a grand theorem.

---

## Deliverables

1. Implement the core definitions needed for:
   - tropical cells,
   - flat directions,
   - tropical kernel,
   - polyhedral loss,
   - tropical gradient flow / descent step.

2. Prove at least **one** of the core theorems above completely:
   - preferably `tropical_ntk_constant_along_flat_directions`, or
   - `tropical_gradient_flow_linear_on_cell`.

3. If time permits, prove the lazy-training criterion theorem.

4. Include comments explaining exactly where each catalog theorem is used.

5. Produce a structured `FUTURE_DIRECTIONS.md` with **3–5 concrete breakthrough next steps**, for example:
   - tropical RKHS representation theorem,
   - wall-crossing invariants for training trajectories,
   - tropical kernel generalization bounds,
   - sheaf cohomology obstruction to lazy training,
   - zero-temperature limit from smooth NTK to tropical NTK.

---

## Application Keywords

tropical geometry, neural tangent kernel, min-plus algebra, polyhedral loss, lazy training, feature learning, wall-crossing, sheaf-theoretic learning, constructible kernels, zero-temperature limit, statistical mechanics, Hamilton–Jacobi, certified robustness, combinatorial dynamics, infinite-width networks

### WHAT WE NEED FROM YOU

You are a world-class mathematician, software engineer, and science writer.
Use your judgment on the best way to organize and present your work.
We need ALL of the following deliverables:

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 1 — Formally verified mathematics (Lean 4)
────────────────────────────────────────────────────────────────────────────
- Prove non-trivial theorems with complete proofs (no `sorry` in the final result)
- Organize the code however makes sense — one file or several,
  whatever serves the mathematics best
- Use doc comments to explain the significance of key results

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 2 — Standalone Popular-Science ARTICLE  →  ARTICLE.md
────────────────────────────────────────────────────────────────────────────
Write a **superb, standalone magazine-quality article** about this research.

CRITICAL RULES FOR THE ARTICLE:
• Do NOT mention "Scientific American", "Sci Am", or "Lean" anywhere.
• Do NOT mention "Lean", "Lean 4", "formal verification", or "proof assistant".
• This is a POPULAR SCIENCE article for a curious, intelligent audience.
  Write it as if it will be published in a premier science magazine.
• The reader should come away saying "Wow, I had no idea math could do THAT."

ARTICLE QUALITY STANDARDS:
• **Superb writing**: Vivid, engaging prose. Strong opening hook. Narrative arc.
  Use concrete analogies and metaphors that make abstract ideas tangible.
• **Depth without jargon**: Explain the IDEAS, not the formalism.
  A reader with a college education should understand and enjoy every paragraph.
• **Story structure**: Open with a provocative question or surprising fact.
  Build tension. Reveal the breakthrough. Show why it matters.
• **Real-world connections**: Connect to technology, nature, everyday life.
  Why should a non-mathematician care about this?
• **Historical context**: Place the discovery in the sweep of intellectual history.
  Who tried this before? What barriers stood in the way?
• **Length**: 1500–3000 words. Substantial but not padded.
• **Standalone**: The article must make complete sense on its own.
  No references to "the proof above" or "our formal verification."

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 3 — Comprehensive RESEARCH PAPER  →  RESEARCH_PAPER.md
────────────────────────────────────────────────────────────────────────────
Write a **thorough, in-depth research paper** that a mathematician or
graduate student would find valuable. This is NOT a summary — it is a
complete, publishable-quality paper.

RESEARCH PAPER REQUIREMENTS:
• **Abstract**: Concise summary of contributions and significance.
• **Introduction**: Motivation, context, relationship to prior work.
• **Definitions & Notation**: Precise mathematical setup.
• **Main Results**: Full theorem statements with detailed proof sketches.
  Include the key ideas, not just "by induction."
• **Algorithms**: If the work produces algorithms, include complete
  pseudocode with complexity analysis (time, space, convergence).
• **Applications**: Concrete applications with worked examples.
  Show HOW to use the results in practice.
• **Computational Experiments**: Reference the Python demos.
  Include tables, charts, or numerical results.
• **Discussion**: Implications, limitations, open questions.
• **Future Work**: Specific, actionable next steps.
• **References**: Cite relevant prior work properly.
• **Length**: 3000–8000 words. Comprehensive and substantive.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 4 — Python Code: Demos, Visualizations, Algorithms
────────────────────────────────────────────────────────────────────────────
- **demo.py** — Working Python code demonstrating the theorems with
  concrete numerical examples. Make the math tangible.
- **visualizations** — matplotlib / plotly charts showing key mathematical
  structures, convergence behavior, phase diagrams, etc.
  Save figures as PNG/SVG files for inclusion in the HTML package.
- **algorithms.py** — Implement any algorithms from the research paper.
  Include docstrings, type hints, and example usage.
- **applications.py** — Code showing real-world applications of the results.
  If the math applies to ML, crypto, physics — show it working.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 5 — FUTURE_DIRECTIONS.md  (MANDATORY — drives next cycle)
────────────────────────────────────────────────────────────────────────────
The MOST IMPORTANT deliverable. Structured roadmap of breakthrough
research opportunities opened by this work. See detailed spec below.

**Team Directive**: Create a team to conduct research, brainstorm hypotheses,
run experiments, validate data, update knowledge base and iterate forever.
Each future direction should be specific enough for a team to pick up and
pursue with clear hypotheses, proof strategies, and cross-domain connections.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 6 — JSON Data Package  →  PACKAGE.json
────────────────────────────────────────────────────────────────────────────
Create a **single JSON file** that bundles ALL artifacts for the web templating system.
Requirements:

• **Structure**: Output a strictly valid JSON object matching this schema:
  {
    "title": "Title of the Research",
    "domain": "Mathematical Domain",
    "article": "Markdown content...",
    "research_paper": "Markdown content...",
    "future_directions": "Markdown content...",
    "demos": [ { "name": "...", "code": "# Must be 100% self-contained. Do not import local files like 'algorithms'" } ],
    "algorithms": [ { "name": "...", "pseudocode": "...", "code": "executable Python implementation" } ],
    "visualizations": [ { "name": "...", "data": "base64 encoded URI or inline SVG string" } ],
    "lean_proofs": "Raw lean code..."
  }
• **String Encoding**: Ensure all Markdown and code is properly JSON-escaped (e.g. `
` for newlines).
• **Embedded images**: ALL images (charts, diagrams, visualizations) MUST be
  embedded directly in the JSON. If you generate matplotlib/plotly figures, convert them to base64
  data URIs (e.g., `data:image/png;base64,...`). For SVG diagrams, put the raw `<svg>...</svg>`
  string into the `data` field. NEVER reference external image files.
• **Complete**: Include ALL content from the article, research paper, and code. This JSON file
  is the sole data source for the frontend web application.

────────────────────────────────────────────────────────────────────────────

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real, useful, and
beautiful. Every deliverable should be something you'd be proud to show.

Research domain: MachineLearning
Research mode: prove
