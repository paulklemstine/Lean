## Assignment: Scaling Laws as Tropical Power-Law Fixed Points

Mode: **prove**

You are not being asked for a metaphor. You are being asked to carve out a mathematically rigid tropical theory of neural scaling laws that can actually live in Lean 4. The core vision is this:

> empirical power-law scaling should be reinterpreted as a piecewise-affine tropical object in log-coordinates, and the observed “phase transitions” between parameter-limited, data-limited, and compute-limited regimes should become literal corner loci of a tropical polyhedral complex.

If formalized cleanly, this opens a new program: **tropical statistical learning theory**, where asymptotic learning curves are governed by idempotent geometry rather than smooth convexity. This would connect scaling laws, tropical neural networks, polyhedral geometry, and asymptotic optimization in a way that is genuinely field-opening.

### Primary Theorem Target

Work in log-coordinates. The raw expression
\[
L(N,D,C)=\min\{A+a\log N,\; B+b\log D,\; E+c\log C\}
\]
is the tropicalization of a three-regime power-law model after taking logarithms of multiplicative variables. This is the correct formal object for Lean.

Define the tropical scaling loss
\[
T(x,y,z)=\min(\alpha x+\beta,\ \gamma y+\delta,\ \eta z+\theta)
\]
for \(x=\log N,\ y=\log D,\ z=\log C\).

Prove that this function is piecewise affine, that each strict dominance region is affine, and that the phase-transition set is exactly the union of pairwise equality hyperplanes intersected with dominance conditions. In particular, the “emergent capability threshold” is modeled by a corner of the tropical polytope where at least two regimes tie.

A precise theorem statement to target:

```lean
def tropicalScalingLoss (a b c A B C : ℝ) (x y z : ℝ) : ℝ :=
  min (A + a * x) (min (B + b * y) (C + c * z))

def StrictNRegion (a b c A B C x y z : ℝ) : Prop :=
  A + a * x < B + b * y ∧ A + a * x < C + c * z

def StrictDRegion (a b c A B C x y z : ℝ) : Prop :=
  B + b * y < A + a * x ∧ B + b * y < C + c * z

def StrictCRegion (a b c A B C x y z : ℝ) : Prop :=
  C + c * z < A + a * x ∧ C + c * z < B + b * y

theorem tropicalScalingLoss_eq_affine_on_StrictNRegion
    {a b c A B C x y z : ℝ}
    (h : StrictNRegion a b c A B C x y z) :
    tropicalScalingLoss a b c A B C x y z = A + a * x := by
  ...

theorem tropicalScalingLoss_eq_affine_on_StrictDRegion
    {a b c A B C x y z : ℝ}
    (h : StrictDRegion a b c A B C x y z) :
    tropicalScalingLoss a b c A B C x y z = B + b * y := by
  ...

theorem tropicalScalingLoss_eq_affine_on_StrictCRegion
    {a b c A B C x y z : ℝ}
    (h : StrictCRegion a b c A B C x y z) :
    tropicalScalingLoss a b c A B C x y z = C + c * z := by
  ...
```

This is the local affine structure theorem. But do not stop there.

### Breakthrough Theorem: Tropical Phase Transitions as Corner Loci

Formalize the tropical phase boundary as the non-differentiability / non-unique minimizer locus. Since full differentiability infrastructure may be unnecessary, define the corner set combinatorially:

```lean
def IsCorner (a b c A B C x y z : ℝ) : Prop :=
  ((A + a * x = B + b * y) ∧ A + a * x ≤ C + c * z) ∨
  ((A + a * x = C + c * z) ∧ A + a * x ≤ B + b * y) ∨
  ((B + b * y = C + c * z) ∧ B + b * y ≤ A + a * x)

def HasUniqueMin (u v w : ℝ) : Prop :=
  (u < v ∧ u < w) ∨ (v < u ∧ v < w) ∨ (w < u ∧ w < v)

theorem not_unique_min_iff_corner
    {a b c A B C x y z : ℝ} :
    ¬ HasUniqueMin (A + a * x) (B + b * y) (C + c * z) ↔
    IsCorner a b c A B C x y z := by
  ...
```

This theorem is the mathematical heart: **phase transition = tropical corner**.

If you can strengthen it, prove a stratification theorem:

```lean
theorem tropicalScalingLoss_trichotomy
    {a b c A B C x y z : ℝ} :
    StrictNRegion a b c A B C x y z ∨
    StrictDRegion a b c A B C x y z ∨
    StrictCRegion a b c A B C x y z ∨
    IsCorner a b c A B C x y z := by
  ...
```

This would give a complete polyhedral decomposition of scaling-law behavior.

## Fixed-Point Interpretation

The phrase “fixed point” must be made mathematically precise, not rhetorical. One promising formalization is tropical idempotent closure: applying the tropical aggregator again does not change the loss once the regime representatives are already affine candidates.

Define:
```lean
def tropicalAggregate3 (u v w : ℝ) : ℝ := min u (min v w)
```

Then prove the idempotent stability statement:
```lean
theorem tropicalScalingLoss_idempotent
    (a b c A B C x y z : ℝ) :
    tropicalAggregate3
      (tropicalScalingLoss a b c A B C x y z)
      (A + a * x)
      (min (B + b * y) (C + c * z))
    = tropicalScalingLoss a b c A B C x y z := by
  ...
```

And ideally the cleaner theorem:
```lean
theorem tropicalAggregate3_idempotent (u v w : ℝ) :
    tropicalAggregate3 (tropicalAggregate3 u v w) v w = tropicalAggregate3 u v w := by
  ...
```

This builds directly on `tropical_min_idempotent`. The conceptual payoff is that the scaling law is a **fixed point of tropical regime aggregation**: once the dominant regime has been selected by min-plus competition, re-aggregation leaves it unchanged.

## Secondary Theorem: Compute-Constrained Reduction

Introduce a compute budget relation in log-space, e.g.
\[
z = x + y
\]
corresponding to \(C \sim ND\) up to constants. Then reduce the 3-variable tropical loss to a 2-variable tropical hypersurface.

Target theorem:
```lean
theorem tropicalScalingLoss_under_compute_constraint
    (a b c A B C x y : ℝ) :
    tropicalScalingLoss a b c A B C x y (x + y) =
      min (A + a * x) (min (B + b * y) (C + c * (x + y))) := by
  rfl
```

Then prove nontrivial geometry from this reduction: characterize when the compute term dominates.

```lean
def ComputeDominates (a b c A B C x y : ℝ) : Prop :=
  C + c * (x + y) < A + a * x ∧
  C + c * (x + y) < B + b * y

theorem compute_region_affine
    {a b c A B C x y : ℝ}
    (h : ComputeDominates a b c A B C x y) :
    tropicalScalingLoss a b c A B C x y (x + y) = C + c * (x + y) := by
  ...
```

This theorem would let you interpret compute-optimal scaling fronts as tropical half-space intersections.

## Why This Would Be a Breakthrough

If you succeed, you will have converted vague empirical “scaling law phase changes” into a theorem scheme in tropical geometry:

- **Scaling regimes become cells** of a tropical polyhedral complex.
- **Emergent capability thresholds become corners** where affine pieces exchange dominance.
- **Compute-optimal tradeoffs become tropical linear constraints**.
- **Neural scaling becomes analyzable by idempotent algebra**, not just statistical curve fitting.

This opens a rigorous pathway from empirical ML laws to formal geometry. It also suggests a general theory of learning systems whose asymptotics are governed by min-plus competition between resources.

## Build Directly on Catalog Theorems

Use the catalog aggressively, not decoratively:

1. `tropical_min_idempotent`
   - This is the seed for the fixed-point/idempotence interpretation.
   - Generalize from `min a a = a` to nested 3-term tropical aggregators and repeated aggregation stability.

2. `tropical_plus_distributes_over_min`
   - Use this to normalize offsets and prove translation invariance facts such as
     \[
     k + \min(u,v,w)=\min(k+u,k+v,k+w).
     \]
   - This is useful for re-centering losses and proving that only relative intercepts matter.

3. `tropical_network_eq_affine_on_strict_cell`
   - This is a direct model for the theorem you need: strict dominance region implies affine formula.
   - Your scaling-law theorem should look like a 3-term, low-dimensional analogue of this neural tropical cell theorem.

4. `tropical_relu_idempotent`
   - Use as an analogy and possibly a reusable simplification principle: idempotent nonlinearities stabilize after one application.
   - This supports the broader thesis that regime selection in scaling laws is an idempotent computation.

5. `lift_network_scaling`
   - Even if its statement is from a different context, inspect whether it provides infrastructure for moving from discrete network structure to geometric coordinates.
   - If useful, reinterpret settlements/edges as a combinatorial scaffold for resource tradeoff graphs.

## Proof Strategy Paths

### Strategy A: Order-Theoretic Min Analysis
Most promising for Lean.

1. Expand all definitions and reduce everything to elementary order lemmas on `min` and inequalities over `ℝ`.
2. Prove strict-region affine formulas by repeated use of `min_eq_left`, `min_eq_right`, `le_of_lt`.
3. Prove corner characterization by case analysis on trichotomy of the three affine candidates and the negation of strict uniqueness.

Why this is promising:
- Minimal analytic overhead.
- Fully compatible with Mathlib order machinery.
- Likely to minimize `sorry`.

### Strategy B: Tropical Polyhedral Decomposition
Best for conceptual strength.

1. Define the three affine forms \(f_N, f_D, f_C\).
2. Define cells by strict inequalities \(f_i < f_j\), and corner strata by equalities \(f_i = f_j\).
3. Prove that the domain decomposes into open cells plus codimension-1 boundary strata, and that the tropical loss equals the corresponding affine form on each cell.

Why this matters:
- Gives the strongest geometric statement.
- Makes “emergence = corner geometry” literally true in the formal development.
- Bridges immediately to tropical hypersurfaces and polyhedral learning theory.

### Strategy C: Log-Linear Resource Dynamics
Best for future expansion.

1. Add a compute constraint \(z = x + y\) or more general linear budget constraints.
2. Substitute into the tropical loss and derive reduced two-variable phase boundaries.
3. Interpret the boundary lines as optimal scaling frontiers and prove their explicit equations.

Why this is powerful:
- Moves from static geometry to optimization-relevant geometry.
- Connects directly to empirical compute/data tradeoff laws in large-model training.

## Cross-Domain Connections You Must Exploit

Do not present this as only “ML formalization.” Make the mathematics resonate across fields:

- **Tropical Geometry**: the phase transition set is a tropical hypersurface of a 3-term tropical polynomial.
- **Optimization / Operations Research**: dominant regime selection is a min-cost resource bottleneck problem.
- **Statistical Physics**: regime transitions mirror phase boundaries in zero-temperature limits where free energy becomes a minimum over competing affine energies.
- **Theoretical Computer Science**: scaling frontiers can be interpreted as complexity tradeoff surfaces under resource constraints.
- **Algebraic Neural Networks**: this is a toy-but-rigorous model of how tropicalized neural systems exhibit piecewise-linear response and sharp capability transitions.

A truly strong version of this project would explicitly compare the tropical scaling loss to zero-temperature free energy:
\[
F_\beta = -\beta^{-1}\log\left(e^{-\beta f_1}+e^{-\beta f_2}+e^{-\beta f_3}\right)
\to \min(f_1,f_2,f_3).
\]
If you can formalize even a simplified convergence statement later, that would be a profound bridge between statistical mechanics and learning theory.

## Concrete Auxiliary Lemmas Worth Proving

These are highly reusable and should make the main theorems cleaner:

```lean
theorem min_assoc3 (u v w : ℝ) :
    min (min u v) w = min u (min v w) := by
  ...

theorem min_eq_left_of_lt {u v : ℝ} (h : u < v) : min u v = u := by
  ...

theorem min_eq_right_of_lt {u v : ℝ} (h : v < u) : min u v = v := by
  ...

theorem tropicalAggregate3_comm_left (u v w : ℝ) :
    tropicalAggregate3 u v w = tropicalAggregate3 v u w := by
  ...

theorem tropicalScalingLoss_translation
    (a b c A B C x y z k : ℝ) :
    tropicalScalingLoss a b c (A + k) (B + k) (C + k) x y z
      = k + tropicalScalingLoss a b c A B C x y z := by
  ...
```

The translation theorem should use `tropical_plus_distributes_over_min` and is conceptually important: only relative intercepts matter for phase geometry.

## Stretch Goal: Tropical Emergence Criterion

Formalize an “emergent capability” predicate as crossing below a threshold \(τ\):

```lean
def CapabilityReached (a b c A B C τ x y z : ℝ) : Prop :=
  tropicalScalingLoss a b c A B C x y z ≤ τ
```

Then characterize threshold activation near a corner by proving existence of nearby points in different strict cells when equality conditions hold. Even a weak theorem here would be novel:

```lean
theorem corner_indicates_regime_competition
    {a b c A B C x y z : ℝ}
    (h : IsCorner a b c A B C x y z) :
    ∃ u v w, tropicalScalingLoss a b c A B C u v w =
      tropicalScalingLoss a b c A B C x y z := by
  ...
```

This exact statement may need refinement, but the ambition is right: corners should encode unstable or switching behavior between scaling regimes.

## Lean Style Guidance

- Use concrete definitions over `ℝ`.
- Prefer explicit predicates (`StrictNRegion`, `IsCorner`) over abstract geometry classes unless Mathlib gives immediate leverage.
- Prove the 2-term lemmas first, then 3-term nested-min theorems.
- Reuse `linarith`, `nlinarith`, and `simp [tropicalScalingLoss, StrictNRegion, StrictDRegion, StrictCRegion, IsCorner, tropicalAggregate3]` aggressively.
- If a theorem about “corner = non-differentiability” becomes too analysis-heavy, retreat to the combinatorial characterization of non-unique minimizers. That is already mathematically meaningful and robust.

## What This Opens Next

This is not an endpoint. It is the first brick in a new wall:

- tropical scaling laws for more than three resources,
- tropical Pareto frontiers for architecture/data/compute co-design,
- zero-temperature statistical mechanics of learning curves,
- certified phase-boundary detection in tropicalized neural models,
- asymptotic capability forecasting from polyhedral geometry.

This could become a formal language for the geometry of intelligence scaling.

## Deliverables

1. A Lean file containing the definitions and theorems above, with as few `sorry`s as possible.
2. At least one theorem explicitly using a catalog theorem.
3. At least one cross-domain lemma or remark connecting tropical scaling to either statistical mechanics or optimization.
4. A structured `FUTURE_DIRECTIONS.md` with **3–5 concrete, breakthrough-level next steps**, for example:
   - formalize softmin \(\to\) tropical min convergence,
   - define tropical Pareto-optimal scaling fronts,
   - prove higher-dimensional cell decomposition for \(k\)-resource scaling laws,
   - connect tropical phase boundaries to capability threshold bifurcations,
   - derive a certified algorithm for regime identification from affine coefficients.

### Application Keywords
tropical geometry, scaling laws, neural networks, min-plus algebra, idempotent analysis, phase transitions, polyhedral geometry, compute-optimal training, statistical mechanics, asymptotic learning theory, resource tradeoffs, emergent capabilities

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
