## Assignment: Grokking as Tropical Phase Transition in Neural Loss Landscapes

**Mode:** prove

Prove a genuinely new bridge theorem: delayed generalization (“grokking”) can be formalized as a **discrete tropical phase transition** in a piecewise-linear loss geometry, detected by a monotone tropical order parameter and witnessed by a strict drop in min-plus distance to the decision boundary.

This should not be treated as metaphor. The goal is to isolate a formal theorem in Lean 4 showing that, under explicit hypotheses on a training trajectory in a tropicalized model of the loss landscape, a corner-locus crossing forces a discontinuous change in the active affine chart and therefore a sharp decrease in tropical margin / boundary distance. That theorem would create a new formal language for phase transitions in learning dynamics.

---

## Core Breakthrough Target

### Theorem A: Tropical Grokking Jump Theorem
Let `θ : Fin T → (Fin n → ℝ)` be a discrete training trajectory in parameter space, let `score : (Fin n → ℝ) → Fin k → ℝ` be class scores represented as minima of finitely many affine forms, and let the predicted class be the argmin of these tropical scores. Define the **tropical decision margin**
\[
\operatorname{margin}(θ_t) := \min_{j \neq y_*} \big(score(θ_t,j)-score(θ_t,y_*)\big),
\]
and define the **tropical boundary distance**
\[
d_{\mathrm{trop}}(θ_t) := \inf\{ \|θ_t-η\|_\infty : \exists j \neq y_*,\ score(η,j)=score(η,y_*) \}.
\]
Assume:
1. each `score · j` is a finite tropical polynomial / minimum of affine forms;
2. along the trajectory, the active affine chart is constant on `t < τ` and changes at `τ`;
3. the chart change at `τ` is a genuine corner-locus crossing;
4. pre-transition margins are uniformly small but positive, while post-transition margins are bounded below by a larger constant.

Then there exists a strict jump:
\[
d_{\mathrm{trop}}(θ_{\tau+1}) < d_{\mathrm{trop}}(θ_{\tau-1})
\]
and, under a local Lipschitz equivalence between margin and boundary distance, the jump is quantitatively controlled by the margin gap.

This theorem makes “grokking onset” mathematically identifiable as a corner-locus event in tropical geometry.

### Lean 4 formal target
A realistic first formalization should use a finite family of affine forms and a computable surrogate for the decision boundary distance.

```lean
def AffineForm (n : ℕ) := (Fin n → ℝ) × ℝ

def evalAffine {n : ℕ} (a : AffineForm n) (x : Fin n → ℝ) : ℝ :=
  (∑ i, a.1 i * x i) + a.2

def TropPoly {n m : ℕ} (P : Fin m → AffineForm n) (x : Fin n → ℝ) : ℝ :=
  Finset.inf' Finset.univ Finset.univ_nonempty (fun i => evalAffine (P i) x)

def marginFromScores {k n : ℕ} (score : (Fin n → ℝ) → Fin k → ℝ)
    (y : Fin k) (x : Fin n → ℝ) : ℝ :=
  Finset.inf' {j : Fin k | j ≠ y}.toFinset
    (by
      have : ({j : Fin k | j ≠ y}.Finite) := Set.toFinite _
      -- nonemptiness handled separately by hypothesis k > 1
      sorry)
    (fun j => score x j - score x y)

def activeSet {n m : ℕ} (P : Fin m → AffineForm n) (x : Fin n → ℝ) : Finset (Fin m) :=
  Finset.univ.filter (fun i => evalAffine (P i) x = TropPoly P x)

def isCornerCrossing {n m : ℕ} (P : Fin m → AffineForm n)
    (x₁ x₂ : Fin n → ℝ) : Prop :=
  activeSet P x₁ ≠ activeSet P x₂

theorem tropical_grokking_jump
    {T n k m : ℕ}
    (hk : 1 < k) (hm : 0 < m) (τ : Fin T)
    (traj : Fin T → (Fin n → ℝ))
    (score : (Fin n → ℝ) → Fin k → ℝ)
    (y : Fin k)
    (P : Fin k → Fin m → AffineForm n)
    (hscore : ∀ j x, score x j = TropPoly (P j) x)
    (hcross : isCornerCrossing (P y) (traj τ) (traj (next τ)))
    (hgap :
      marginFromScores score y (traj (next τ)) >
      marginFromScores score y (traj τ)) :
    ∃ ε > 0,
      marginFromScores score y (traj (next τ)) ≥
      marginFromScores score y (traj τ) + ε := by
  sorry
```

This is the minimal formal seed. If exact `boundary distance` is too heavy initially, prove a **strict margin jump theorem** first, then derive a corollary interpreting margin as a proxy for tropical boundary distance.

---

## Secondary Breakthrough Target

### Theorem B: Tropical Order Parameter Predicts Grokking
Define an order parameter
\[
\Phi(θ_t) := \#\{\text{active affine forms at } θ_t\} - 1
\]
or, better, the **margin degeneracy index**
\[
\Phi(θ_t) := \sum_{j \neq y_*} \mathbf{1}\big(\operatorname{margin}_j(θ_t)\le \delta\big),
\]
measuring how many competing classes lie tropically near the decision boundary.

Prove that if:
- `Φ` is nonincreasing along training,
- and there is a unique time `τ` where `Φ` drops strictly,
- and training loss continues decreasing monotonically before and after `τ`,

then the strict drop in `Φ` predicts a later-or-simultaneous strict increase in generalization margin.

Interpretation: optimization improves train loss continuously, but generalization changes when the tropical combinatorial type changes.

### Lean 4 target
```lean
def degeneracyIndex {k n : ℕ}
    (score : (Fin n → ℝ) → Fin k → ℝ) (y : Fin k) (δ : ℝ)
    (x : Fin n → ℝ) : ℕ :=
  ((Finset.univ.filter fun j =>
      j ≠ y ∧ score x j - score x y ≤ δ).card)

theorem order_parameter_predicts_grokking
    {T n k : ℕ}
    (hk : 1 < k) (traj : Fin T → (Fin n → ℝ))
    (score : (Fin n → ℝ) → Fin k → ℝ)
    (y : Fin k) (δ : ℝ)
    (hmono : ∀ t s, t ≤ s →
      degeneracyIndex score y δ (traj s) ≤ degeneracyIndex score y δ (traj t))
    (hdrop : ∃ τ : Fin T, degeneracyIndex score y δ (traj (next τ)) <
                         degeneracyIndex score y δ (traj τ)) :
    ∃ τ : Fin T,
      marginFromScores score y (traj (next τ)) >
      marginFromScores score y (traj τ) := by
  sorry
```

This is a mathematically modest but conceptually powerful formal predictor theorem.

---

## Ambitious Geometric Target

### Theorem C: Tropical Geodesic Crossing Criterion for Delayed Generalization
Model training as a discrete geodesic-like path in tropical parameter space:
\[
θ_{t+1} = θ_t \oplus v_t
\]
or more concretely as a path with piecewise-constant active affine support. Prove:

If a trajectory stays within a single tropical cell, then the classifier’s combinatorial decision type is stable and no sharp generalization transition occurs. If the trajectory crosses the corner locus between two cells with distinct active supports, then there exists a witness sample on which the decision margin changes non-smoothly.

This theorem is the geometric heart of the story: **grokking is not “late optimization”; it is a chamber transition.**

### Lean 4 target
```lean
theorem no_grokking_without_corner_crossing
    {T n m : ℕ}
    (traj : Fin T → (Fin n → ℝ))
    (P : Fin m → AffineForm n)
    (hconst : ∀ t s, activeSet P (traj t) = activeSet P (traj s)) :
    ∀ t s, TropPoly P (traj t) - TropPoly P (traj s) =
           ∑ i, ((traj t i) - (traj s i)) * ((P ((activeSet P (traj t)).min' ?_) ).1 i) := by
  sorry
```

Even if this exact linear identity needs adjustment, the right theorem is: **on a fixed active cell, the tropical polynomial is affine**. Then delayed generalization can only arise from leaving that cell.

---

## How to Build on the Catalog

Use the existing verified theorems as algebraic scaffolding, not decoration:

1. `max_plus_order_preserving`
   - Use it to show monotonicity of tropical score transforms and margin comparisons.
   - This is especially useful when proving that if one affine chart dominates another before the crossing, order is preserved under tropical updates.

2. `order_parameter_nonneg`
   - Use it as the seed for proving your new tropical order parameter is well-defined and nonnegative.
   - Generalize from the existing order parameter to a combinatorial degeneracy index on active sets / near-ties.

3. `tropical_sum_to_min`
   - This is the conceptual bridge to ultrametric information geometry.
   - Use it to justify that certain loss surrogates or score aggregations tropicalize into minima, making the corner-locus formalization natural rather than ad hoc.

4. `tropical_plus_distributes_over_min`
   - This is the main algebraic engine for rewriting score updates under tropicalization.
   - It should let you normalize affine perturbations and prove that chartwise updates preserve min-plus structure.

If one of these theorems is too specialized in its current file, extract the reusable algebraic statement into a local lemma in your new development.

---

## Proof Architecture: 3 Viable Strategies

### Strategy A: Finite Polyhedral Cell Decomposition
Most promising.

1. Represent each class score as a finite minimum of affine forms.
2. Define the active set and prove that on any region with fixed active set, the score is affine.
3. Show that a strict change in active set implies crossing the corner locus.
4. Prove that margin can only undergo a non-smooth jump when the active set changes.
5. Deduce that the tropical order parameter drop coincides with a jump in margin or boundary-distance surrogate.

Why this is strongest: it is fully finitary, Lean-friendly, and captures the geometry exactly.

### Strategy B: Order-Theoretic / Lattice-Theoretic Proof
Elegant and robust.

1. Encode tropical score evolution as a monotone map on a finite semilattice of active charts.
2. Show that training within one lattice stratum preserves combinatorial decision type.
3. Prove that grokking requires descending to a lower-degeneracy stratum.
4. Use `max_plus_order_preserving` and tropical distributivity to transfer inequalities through updates.

Why this matters: it could generalize beyond neural nets to any min-plus classifier, including automata and symbolic systems.

### Strategy C: Tropical-Information-Geometric Route
High-risk, high-reward.

1. Define a tropical divergence between class score vectors.
2. Show that delayed generalization corresponds to a collapse of tropical divergence to the decision boundary.
3. Use `tropical_sum_to_min` to connect p-adic / ultrametric aggregation with tropicalized loss.
4. Interpret the order parameter as an entropy-like quantity that sharply decreases at grokking.

Why this is revolutionary: it reframes grokking as an information phase transition, not just a geometric one.

Recommendation: prove Theorem A via Strategy A first, then reinterpret it using Strategy C in remarks/corollaries.

---

## Cross-Domain Connections You Must Exploit

### 1. Statistical Physics
Treat the active-set degeneracy as a symmetry-breaking parameter.
- Pre-grokking: many near-degenerate affine competitors.
- Post-grokking: one dominant chart.
This is directly analogous to crystallization / free-energy minimization, and the existing `order_parameter_nonneg` suggests this bridge is already latent in the library.

### 2. Polyhedral / Tropical Geometry
The loss landscape is a polyhedral complex; grokking is movement across codimension-1 walls.
This imports methods from tropical hypersurfaces, corner loci, and regular subdivisions.

### 3. Information Geometry / p-adic or Ultrametric Models
The theorem `tropical_sum_to_min` hints that tropicalization and ultrametric collapse are formally aligned.
Use this to argue that delayed generalization is an **ultrametric reorganization of class competition**.

### 4. Dynamical Systems
The training path is a discrete orbit through a stratified state space.
A corner crossing is a bifurcation event in the symbolic dynamics of active charts.

### 5. Complexity / Mechanistic Interpretability
A drop in degeneracy index can be interpreted as circuit simplification or algorithm selection.
This would connect tropical geometry to the mechanistic emergence of modular arithmetic algorithms in grokking experiments.

---

## Concrete Definitions Worth Formalizing

You should introduce clean Lean definitions for:

```lean
def activeSet ...
def cornerLocus ...
def marginFromScores ...
def degeneracyIndex ...
def tropicallySeparable ...
def chartStableOn ...
def grokkingOnset ...
```

Suggested shape:

```lean
def chartStableOn {T n m : ℕ}
    (traj : Fin T → (Fin n → ℝ)) (P : Fin m → AffineForm n) (a b : Fin T) : Prop :=
  ∀ t, a ≤ t → t ≤ b → activeSet P (traj t) = activeSet P (traj a)

def grokkingOnset {T n k : ℕ}
    (traj : Fin T → (Fin n → ℝ))
    (score : (Fin n → ℝ) → Fin k → ℝ)
    (y : Fin k) (τ : Fin T) : Prop :=
  marginFromScores score y (traj τ) <
  marginFromScores score y (traj (next τ))
```

---

## Minimal Theorem Stack to Aim For

1. **Cellwise Affinity Lemma**  
   On a region with fixed active set, a tropical polynomial equals a single affine form.

2. **Corner Crossing Lemma**  
   If active set changes between consecutive iterates, then the segment intersects the corner locus.

3. **Margin Jump Lemma**  
   A corner crossing that removes a competing active form strictly increases decision margin.

4. **Order Parameter Monotonicity Lemma**  
   Degeneracy index is nonnegative and decreases when active competitors disappear.

5. **Grokking Predictor Theorem**  
   A strict drop in degeneracy index predicts a strict margin jump.

6. **No-Grokking-in-a-Cell Theorem**  
   If trajectory remains in one tropical cell, no sharp combinatorial generalization transition occurs.

That stack would already be publishable as a formal blueprint.

---

## Why This Would Be a Breakthrough

This would open a **new formal theory of learning phase transitions**:
- a rigorous tropical-geometric language for grokking;
- computable order parameters for delayed generalization;
- a bridge from mechanistic interpretability to polyhedral geometry;
- a route to certifiable grokking predictors in toy and possibly real architectures.

It would enable follow-on work on:
- tropical scaling laws;
- phase diagrams for modular arithmetic learning;
- certified onset detection in training trajectories;
- ultrametric and p-adic reformulations of representation collapse;
- tropical renormalization of deep network training.

This is not “another theorem about piecewise linear networks.” It is a candidate formal foundation for the geometry of emergent algorithmic generalization.

---

## Application Keywords

tropical geometry, grokking, delayed generalization, phase transition, neural loss landscape, min-plus algebra, corner locus, order parameter, polyhedral complex, mechanistic interpretability, ultrametric information geometry, statistical physics, bifurcation, decision boundary, margin collapse, affine cell decomposition, tropical geodesic, symmetry breaking

---

## Execution Directive

Create a small internal team with explicit roles:
- **Geometer:** formalize tropical cells, active sets, corner loci.
- **Dynamicist:** define trajectory-level grokking onset and transition criteria.
- **Algebraist:** exploit distributivity/order-preservation lemmas from the catalog.
- **Experimental Formalist:** test definitions on tiny finite examples (`n = 2`, `k = 2`, `m = 2`) before scaling.
- **Scribe:** maintain theorem dependency structure and prune bad definitions quickly.

Run this as an iterative theorem-discovery program:
1. formalize definitions,
2. prove cellwise-affinity,
3. prove corner-crossing,
4. define order parameter,
5. prove predictor theorem,
6. extract conceptual corollaries.

Minimize `sorry`, but use temporary local `sorry` only to unblock architecture while searching for the right theorem statement.

---

## Required Deliverables

1. A new Lean file formalizing the tropical-grokking framework and proving at least one nontrivial main theorem from the stack above.
2. Clear comments explaining which theorem corresponds to the “phase transition” claim.
3. At least one finite worked example showing active-set change and margin jump.
4. A structured `FUTURE_DIRECTIONS.md` with **3–5 concrete breakthrough next steps**, such as:
   - tropical scaling law theorem for grokking time;
   - tropical-noise metastability and delayed transitions;
   - ultrametric mutual information as a grokking precursor;
   - chamber-complexity bounds for modular arithmetic tasks;
   - tropical renormalization flow for deep ReLU networks.

Be bold: the correct theorem here is one that makes a skeptical mathematician say, “Yes, delayed generalization really can be seen as a wall-crossing phenomenon.”

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
