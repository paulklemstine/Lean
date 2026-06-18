## Assignment: Tropical Neural Tangent Kernel as Polyhedral Linearization of Infinite-Width Learning

Mode: `prove`

Prove new, non-trivial theorems that make the tropical limit of overparameterized learning mathematically rigid. Build on the catalog theorems, minimize sorry, and do not settle for a vague analogy: extract a formally usable tropical NTK object, prove its structural invariances, and identify the exact regime where feature learning collapses to lazy training along tropical flats.

### Core Vision

The breakthrough target is not “some tropicalized neural-network fact.” It is a theorem package showing that, after replacing ordinary addition/multiplication by min-plus structure in a controlled scaling limit, the infinite-width neural tangent kernel becomes a **polyhedral kernel** whose training dynamics are piecewise-linear, constant on tropical flat cells, and therefore admit a sharp decomposition:

- **lazy regime** = dynamics confined to a cell where the tropical NTK is constant,
- **feature-learning regime** = dynamics crossing tropical walls where the active minima change.

This would open a new field: **tropical kernel dynamics**, sitting at the intersection of NTK theory, polyhedral geometry, idempotent analysis, and formal verification of machine learning asymptotics.

### Precise Formalization Target

Because the full analytic infinite-width limit is too large for a first Lean cycle, formalize the mathematically decisive finite-dimensional tropical skeleton first. Then isolate the exact theorem that behaves as the tropical analogue of NTK constancy.

Define a tropical feature family on `d`-dimensional inputs with `m` hidden units by affine forms
`z_i(x) = w_i · x + b_i`, and define the tropical network
`f(x) = Finset.inf' S hs (fun i => z_i(x))`
for a nonempty finite set `S : Finset (Fin m)`. On any region where the argmin set is fixed, the map is affine, hence its parameter-Jacobian is constant; the tropical NTK induced by this Jacobian is therefore constant there.

This is the exact theorem Aristotle should formalize.

### Main Theorem Package

#### Theorem 1: Tropical network is affine on a strict argmin cell

For a fixed hidden unit `i₀`, define the strict tropical cell
\[
C(i₀) := \{x \in \mathbb{R}^d \mid \forall j \in S,\ z_{i₀}(x) < z_j(x)\ \text{for } j \neq i₀\}.
\]
Then on `C(i₀)`, the tropical network equals the affine form `z_{i₀}`.

Lean target:
```lean
theorem tropical_network_eq_affine_on_strict_cell
  {d m : ℕ}
  (S : Finset (Fin m)) (hS : S.Nonempty)
  (W : Fin m → (Fin d → ℝ)) (b : Fin m → ℝ)
  (i0 : Fin m) (hi0 : i0 ∈ S) :
  ∀ x : (Fin d → ℝ),
    (∀ j : Fin m, j ∈ S → j ≠ i0 →
      (∑ k : Fin d, W i0 k * x k) + b i0
        < (∑ k : Fin d, W j k * x k) + b j) →
    (S.inf' hS (fun i =>
      (∑ k : Fin d, W i k * x k) + b i))
      = (∑ k : Fin d, W i0 k * x k) + b i0
```

This is the polyhedral heart: tropical prediction is literally affine inside a chamber.

#### Theorem 2: Tropical parameter gradient is constant on a strict argmin cell

Let the parameter space be `(Fin m → Fin d → ℝ) × (Fin m → ℝ)`. For fixed `x`, the derivative of the active affine form with respect to parameters is constant on any strict argmin cell. In a first formalization, avoid Fréchet derivatives and define the **tropical parameter gradient** combinatorially as the gradient of the active branch:
- weight-gradient at active unit `i₀` equals `x`,
- bias-gradient at active unit `i₀` equals `1`,
- all other coordinates are `0`.

Lean target:
```lean
def tropicalParamGrad
  {d m : ℕ} (S : Finset (Fin m)) (hS : S.Nonempty)
  (W : Fin m → (Fin d → ℝ)) (b : Fin m → ℝ)
  (x : Fin d → ℝ) : (Fin m → Fin d → ℝ) × (Fin m → ℝ) :=
by
  classical
  -- choose an argmin branch, or later refine to strict-cell version
  sorry

theorem tropical_param_grad_on_strict_cell
  {d m : ℕ}
  (S : Finset (Fin m)) (hS : S.Nonempty)
  (W : Fin m → (Fin d → ℝ)) (b : Fin m → ℝ)
  (i0 : Fin m) (hi0 : i0 ∈ S) :
  ∀ x : Fin d → ℝ,
    (∀ j : Fin m, j ∈ S → j ≠ i0 →
      (∑ k : Fin d, W i0 k * x k) + b i0
        < (∑ k : Fin d, W j k * x k) + b j) →
    tropicalParamGrad S hS W b x
      =
      ( (fun i k => if i = i0 then x k else 0),
        (fun i => if i = i0 then 1 else 0) )
```

This theorem is the tropical analogue of “Jacobian frozen in the lazy regime.”

#### Theorem 3: Tropical NTK is constant on a common strict cell

For two inputs `x, y`, define the tropical NTK by the inner product of tropical parameter gradients:
\[
K_{\mathrm{trop}}(x,y)
= \langle \nabla^{\mathrm{trop}}_\theta f(x), \nabla^{\mathrm{trop}}_\theta f(y)\rangle.
\]
If `x` and `y` lie in the same strict argmin cell `C(i₀)`, then
\[
K_{\mathrm{trop}}(x,y)= \langle x,y\rangle + 1.
\]
More generally, for all pairs of points in a fixed cell, the kernel is determined by the active branch only; in particular, if one studies directions tangent to the cell along which the active affine coordinates are fixed, the kernel is constant.

Lean target:
```lean
def tropicalNTK
  {d m : ℕ}
  (S : Finset (Fin m)) (hS : S.Nonempty)
  (W : Fin m → (Fin d → ℝ)) (b : Fin m → ℝ)
  (x y : Fin d → ℝ) : ℝ :=
  let gx := tropicalParamGrad S hS W b x
  let gy := tropicalParamGrad S hS W b y
  (∑ i : Fin m, ∑ k : Fin d, gx.1 i k * gy.1 i k) +
  (∑ i : Fin m, gx.2 i * gy.2 i)

theorem tropical_ntk_eq_dot_add_one_on_common_strict_cell
  {d m : ℕ}
  (S : Finset (Fin m)) (hS : S.Nonempty)
  (W : Fin m → (Fin d → ℝ)) (b : Fin m → ℝ)
  (i0 : Fin m) (hi0 : i0 ∈ S) :
  ∀ x y : Fin d → ℝ,
    (∀ j : Fin m, j ∈ S → j ≠ i0 →
      (∑ k : Fin d, W i0 k * x k) + b i0
        < (∑ k : Fin d, W j k * x k) + b j) →
    (∀ j : Fin m, j ∈ S → j ≠ i0 →
      (∑ k : Fin d, W i0 k * y k) + b i0
        < (∑ k : Fin d, W j k * y k) + b j) →
    tropicalNTK S hS W b x y
      = (∑ k : Fin d, x k * y k) + 1
```

This is the first real theorem that deserves the phrase “tropical NTK.”

#### Theorem 4: Tropical flat directions preserve the tropical NTK

Define a tropical flat direction relative to a cell `C(i₀)` as a displacement `v` such that the active affine branch remains active and its directional score is unchanged:
\[
\sum_k W_{i₀,k} v_k = 0
\]
and the strict inequalities defining the cell remain valid along the segment. Then for all sufficiently admissible `t`,
\[
K_{\mathrm{trop}}(x+tv,y)=K_{\mathrm{trop}}(x,y).
\]

Lean target:
```lean
theorem tropical_ntk_constant_along_flat_directions
  {d m : ℕ}
  (S : Finset (Fin m)) (hS : S.Nonempty)
  (W : Fin m → (Fin d → ℝ)) (b : Fin m → ℝ)
  (i0 : Fin m) (hi0 : i0 ∈ S) :
  ∀ x y v : Fin d → ℝ,
    (∀ j : Fin m, j ∈ S → j ≠ i0 →
      (∑ k : Fin d, W i0 k * x k) + b i0
        < (∑ k : Fin d, W j k * x k) + b j) →
    (∀ j : Fin m, j ∈ S → j ≠ i0 →
      (∑ k : Fin d, W i0 k * y k) + b i0
        < (∑ k : Fin d, W j k * y k) + b j) →
    (∑ k : Fin d, W i0 k * v k) = 0 →
    (∀ t : ℝ, 0 ≤ t →
      (∀ j : Fin m, j ∈ S → j ≠ i0 →
        (∑ k : Fin d, W i0 k * (x k + t * v k)) + b i0
          < (∑ k : Fin d, W j k * (x k + t * v k)) + b j)) →
    ∀ t : ℝ, 0 ≤ t →
      tropicalNTK S hS W b (fun k => x k + t * v k) y
        = tropicalNTK S hS W b x y
```

This theorem gives the precise lazy/feature-learning dichotomy:
- inside a flat cell: no kernel evolution,
- crossing walls: kernel changes.

### Why This Is a Breakthrough

Classical NTK theory says infinite-width training often behaves like kernel regression because the Jacobian freezes. Tropical geometry says min-plus objects are piecewise affine with wall-crossing behavior. Your goal is to prove that these are the same phenomenon in a new asymptotic language:

- **kernel freezing = chamberwise constancy of tropical Jacobian**
- **feature learning = crossing tropical walls**
- **loss landscape = polyhedral complex**
- **training flow = piecewise-linear differential inclusion**

This would create a formally verified bridge between:
1. infinite-width learning theory,
2. tropical/idempotent analysis,
3. polyhedral optimization,
4. certified robustness and causal/sheaf structure in the catalog.

### Proof Strategy Architecture

#### Strategy A: Polyhedral cell decomposition first, kernel second
Most promising.

1. Prove `inf'` of affine forms equals the chosen branch under strict inequalities.
   - This should rely on elementary `Finset.inf'_eq` style arguments and pointwise comparison.
   - Use `tropical_plus_distributes_over_min` conceptually as justification that min-plus linearization behaves well under affine combination.

2. Define the tropical parameter gradient by branch selection on strict cells only.
   - Avoid analytic differentiation initially.
   - The combinatorial gradient is enough to define the kernel and prove constancy.

3. Expand the kernel sum explicitly.
   - Since only one hidden unit is active, all cross-terms vanish.
   - The remaining terms simplify to `dot x y + 1`.

Why this is strongest: it is fully discrete/polyhedral, avoids measure-theoretic or probabilistic width limits, and yields the exact theorem structure needed for later asymptotic upgrade.

#### Strategy B: Tropicalization as scaled log-sum-exp limit
More ambitious, possibly for a second theorem.

1. Define soft-min:
   \[
   f_\tau(x)= -\tau \log \sum_i \exp(-z_i(x)/\tau).
   \]
2. Prove pointwise convergence `f_τ → min_i z_i` as `τ → 0⁺`.
3. Show the classical finite-width NTK of `f_τ` converges on strict cells to the combinatorial tropical NTK.

This is the true “NTK converges to tropical kernel” statement. It is scientifically deeper, but in Lean it is significantly harder because of limits, exponentials, and branch-stability arguments. If attempted, isolate it in a separate file after Theorems 1–4 are complete.

#### Strategy C: Differential inclusion / tropical gradient flow
For the dynamics theorem.

1. Define a polyhedral loss, e.g. finite sample squared loss over tropical network outputs.
2. On each fixed chamber of parameter space, prove the loss is quadratic or affine-quadratic.
3. Show gradient descent/update maps preserve piecewise-affine dynamics until a wall is crossed.

This converts “training in tropical NTK regime” into a theorem about chamberwise linear ODEs or discrete updates. Harder than kernel constancy, but it gives the exact feature-learning-vs-lazy split.

### Building on Existing Verified Theorems

Use the catalog theorems as conceptual anchors and, where possible, proof gadgets.

1. `tropical_attention_prediction_constant_on_ball`
   - Build on the philosophy already formalized there: tropical predictors are locally constant or structurally rigid on regions with fixed combinatorics.
   - Your new theorem should be the kernel-level analogue: not only prediction, but the **tangent kernel** is constant on a tropical region.

2. `tropical_sum_to_min`
   - This is a strong signal that a valuation/log-limit bridge already exists in the library context.
   - Use it to motivate the scaled soft-min or nonarchimedean interpretation of tropicalization: the tropical kernel is not ad hoc, but a degeneration of ordinary analytic structure.

3. `tropical_plus_distributes_over_min`
   - This is exactly the algebraic mechanism behind piecewise affine behavior.
   - Use it to simplify expressions when proving that active-branch formulas behave well under tropical composition.

4. `zero_cochain_constant_iff_kernel`
   - This opens a striking cross-domain connection: constancy on cells can be encoded as a kernel condition in a Čech/sheaf complex.
   - If you can define a cover by tropical cells, then “kernel constancy on overlaps” becomes a sheaf-theoretic compatibility statement. That would be a genuine field-opening bridge.

### Cross-Domain Connections to Exploit

#### 1. Sheaf-theoretic learning dynamics
A tropical cell decomposition gives an open cover of input space. The active affine branch is a local section; constancy of tropical NTK on cells suggests a sheaf of kernels whose gluing obstruction measures feature learning across walls. This is not decorative: it could formalize “global representation learning” as failure of local kernel sections to glue.

#### 2. Idempotent analysis and Hamilton–Jacobi theory
Min-plus linearity is the natural algebra of value functions and viscosity solutions. A tropical gradient flow on a polyhedral loss surface should connect to discrete Hamilton–Jacobi propagation. This suggests that training trajectories in the tropical limit are shortest-path/value-iteration analogues.

#### 3. Nonarchimedean / p-adic degeneration
Given `tropical_sum_to_min`, the tropical NTK may be viewed as a valuation shadow of an analytic kernel over a nonarchimedean field. That would open a route to “kernel degeneration theory,” where learning regimes are classified by valuations rather than Euclidean scaling.

#### 4. Robustness and adversarial geometry
If the tropical NTK is constant on a chamber, then perturbations staying inside the chamber preserve first-order training response. This is a new kind of certified training robustness, not just prediction robustness.

### Concrete Definitions to Introduce

Use simple, explicit Lean-friendly definitions.

```lean
def affineScore {d m : ℕ}
  (W : Fin m → Fin d → ℝ) (b : Fin m → ℝ)
  (i : Fin m) (x : Fin d → ℝ) : ℝ :=
  (∑ k : Fin d, W i k * x k) + b i

def tropicalNet {d m : ℕ}
  (S : Finset (Fin m)) (hS : S.Nonempty)
  (W : Fin m → Fin d → ℝ) (b : Fin m → ℝ)
  (x : Fin d → ℝ) : ℝ :=
  S.inf' hS (fun i => affineScore W b i x)

def strictArgminCell {d m : ℕ}
  (S : Finset (Fin m))
  (W : Fin m → Fin d → ℝ) (b : Fin m → ℝ)
  (i0 : Fin m) (x : Fin d → ℝ) : Prop :=
  i0 ∈ S ∧
  ∀ j : Fin m, j ∈ S → j ≠ i0 →
    affineScore W b i0 x < affineScore W b j x
```

Then prove theorem chains off these definitions.

### Recommended File Targets

Create one focused file:
- `MachineLearning/Neural/TropicalNTK.lean`

Suggested theorem order:
1. `tropical_network_eq_affine_on_strict_cell`
2. `tropical_param_grad_on_strict_cell`
3. `tropical_ntk_eq_dot_add_one_on_common_strict_cell`
4. `tropical_ntk_constant_along_flat_directions`

If time permits, a second file:
- `MachineLearning/Neural/TropicalNTKLimit.lean`

for soft-min convergence and analytic degeneration.

### Minimal Viable Formalization Plan

1. Work with `Fin d → ℝ` instead of matrices first.
2. Use strict cells, not tie sets.
3. Define combinatorial tropical gradients instead of Fréchet derivatives.
4. Prove kernel constancy on cells.
5. Only then generalize to training dynamics.

This avoids getting trapped in analysis before the polyhedral theorem is secured.

### What to Avoid

- Do not claim the full infinite-width probabilistic limit without a formal finite-width approximation scheme.
- Do not define a “tropical NTK” vaguely as just any kernel on tropical features.
- Do not get stuck on nondifferentiability at wall crossings; the correct first theorem lives away from walls.

### Application Keywords

tropical neural tangent kernel, infinite-width limit, min-plus algebra, polyhedral loss landscape, lazy training, feature learning, wall crossing, piecewise affine dynamics, idempotent analysis, sheaf-theoretic learning, certified robustness, nonarchimedean degeneration, Hamilton–Jacobi learning, formal verification of ML theory

### Team Directive

Create a team with sharply separated roles:

- **Polyhedral Geometer**: formalize tropical cells, argmin regions, wall-crossing lemmas.
- **Kernel Theorist**: define tropical parameter gradients and derive the kernel identities.
- **Lean Engineer**: optimize `Finset.inf'`, finite sums, and branch-selection lemmas.
- **Cross-Domain Synthesist**: connect the kernel-constancy theorem to sheaf kernels and robustness.
- **Experimental Scout**: numerically test soft-min convergence and chamberwise kernel freezing to guide theorem statements before formalization.

### Deliverables

1. A Lean file with the theorem package above.
2. At least one nontrivial corollary stating the lazy/feature-learning dichotomy in precise chamber language.
3. A structured `FUTURE_DIRECTIONS.md` with 3–5 concrete breakthrough next steps, such as:
   - formal soft-min-to-tropical NTK convergence,
   - tropical gradient flow as a differential inclusion,
   - sheaf obstruction to global kernel constancy,
   - nonarchimedean kernel degeneration,
   - certified robustness of training trajectories under chamber-preserving perturbations.

Do not write incremental folklore. Isolate the exact polyhedral theorem that turns tropical NTK from metaphor into mathematics.

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
