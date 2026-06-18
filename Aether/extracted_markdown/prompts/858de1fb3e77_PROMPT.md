## Assignment: Deep Double Descent as Tropical Phase Diagram

Mode: **prove**

This is not a request for a metaphor. It is a request to turn one of the defining empirical phenomena of modern learning theory into a certified tropical theorem: the interpolation threshold should become a tropical vertex, the classical and overparameterized regimes should become competing affine pieces, and double descent should be formalized as a corner-crossing law for a min-plus risk functional.

Prove new, non-trivial theorems in Lean 4. Build on the catalog theorem
`MachineLearning/TropicalDoubleDescent.lean:tropical_double_descent_phase_transition`
and exploit the algebraic infrastructure around
`tropical_plus_distributes_over_min`.
Minimize `sorry`.

### Core Vision

The breakthrough target is to show that a stylized generalization-risk curve can be represented as a tropical piecewise-affine function of model complexity, and that the interpolation threshold is exactly the point where two tropical monomials exchange dominance. This reframes double descent from an empirical bump into a **certified tropical phase transition**.

If formalized cleanly, this opens a field: tropical statistical learning theory, where bias-variance tradeoffs, interpolation thresholds, benign overfitting, and algorithmic stability are studied as polyhedral geometry in min-plus semirings. That is a new language, not a minor variant.

---

## Precise Theorem Targets

You will likely need to define a simple stylized tropical risk model first. Use concrete types and keep definitions Lean-friendly.

### Suggested definitions

Let complexity be indexed by `n : ℕ`. Let `τ : ℕ` be the interpolation threshold. Let
- `classicalRisk n := a₁ * (n : ℝ) + b₁`
- `modernRisk n := a₂ * (n : ℝ) + b₂`
- tropical risk be `min (classicalRisk n) (modernRisk n)`.

To encode “descent then ascent then descent” in a tractable way, the most robust route is to study the **excess risk relative to a baseline** or the **negated score** as a min of affine forms, then recover a max-form risk if needed. In Lean, min-plus is easier to certify than informal curve sketches.

### Theorem 1: Tropical vertex characterization of interpolation threshold

Prove that if two affine tropical facets are equal at `τ`, then `τ` is a tropical vertex and the dominant regime switches there.

Suggested Lean statement:

```lean
theorem tropical_vertex_at_threshold
    (a₁ a₂ b₁ b₂ : ℝ) (τ : ℕ)
    (hEq : a₁ * (τ : ℝ) + b₁ = a₂ * (τ : ℝ) + b₂)
    (hLeft : a₁ < a₂)
    (hRight : ∀ n : ℕ, τ < n →
      a₂ * (n : ℝ) + b₂ < a₁ * (n : ℝ) + b₁)
    (hClassical : ∀ n : ℕ, n < τ →
      a₁ * (n : ℝ) + b₁ < a₂ * (n : ℝ) + b₂) :
    let R : ℕ → ℝ := fun n => min (a₁ * (n : ℝ) + b₁) (a₂ * (n : ℝ) + b₂)
    R τ = a₁ * (τ : ℝ) + b₁ ∧
    (∀ n : ℕ, n < τ → R n = a₁ * (n : ℝ) + b₁) ∧
    (∀ n : ℕ, τ < n → R n = a₂ * (n : ℝ) + b₂) := by
```

This theorem is the clean geometric nucleus: two tropical facets, one crossing, one certified phase boundary.

### Theorem 2: Unique corner crossing for a tropical risk surface

Strengthen to uniqueness: under unequal slopes and equality at `τ`, the switch point is unique.

```lean
theorem unique_tropical_corner_crossing
    (a₁ a₂ b₁ b₂ : ℝ) (τ : ℕ)
    (hSlope : a₁ ≠ a₂)
    (hEq : a₁ * (τ : ℝ) + b₁ = a₂ * (τ : ℝ) + b₂) :
    let f : ℕ → ℝ := fun n => a₁ * (n : ℝ) + b₁
    let g : ℕ → ℝ := fun n => a₂ * (n : ℝ) + b₂
    ∀ n : ℕ, f n = g n → n = τ := by
```

This is the rigorous phase-transition statement: there is a single interpolation threshold, not a smeared family of crossings.

### Theorem 3: Tropicalized double-descent decomposition

Define a risk decomposition by tropicalization of competing error sources, e.g. approximation and interpolation penalties.

A Lean-friendly formulation is:

```lean
def classicalFacet (α β : ℝ) (n : ℕ) : ℝ := α * (n : ℝ) + β
def modernFacet (γ δ : ℝ) (n : ℕ) : ℝ := γ * (n : ℝ) + δ
def tropicalRisk (α β γ δ : ℝ) (n : ℕ) : ℝ :=
  min (classicalFacet α β n) (modernFacet γ δ n)

theorem tropical_risk_piecewise_affine
    (α β γ δ : ℝ) :
    ∀ n : ℕ,
      tropicalRisk α β γ δ n =
        min (α * (n : ℝ) + β) (γ * (n : ℝ) + δ) := by
```

This may look elementary, but it creates the definitional scaffold for stronger phase-transition theorems and lets you rewrite aggressively with catalog lemmas.

### Theorem 4: Monotone facets imply descent regimes on each side of the threshold

Use slope signs to formalize “classical regime” and “modern regime.”

```lean
theorem classical_modern_regime_monotonicity
    (a₁ a₂ b₁ b₂ : ℝ) (τ : ℕ)
    (hEq : a₁ * (τ : ℝ) + b₁ = a₂ * (τ : ℝ) + b₂)
    (hA1 : 0 < a₁)
    (hA2 : a₂ < 0)
    (hClassical : ∀ n : ℕ, n < τ →
      a₁ * (n : ℝ) + b₁ < a₂ * (n : ℝ) + b₂)
    (hModern : ∀ n : ℕ, τ < n →
      a₂ * (n : ℝ) + b₂ < a₁ * (n : ℝ) + b₁) :
    let R : ℕ → ℝ := fun n => min (a₁ * (n : ℝ) + b₁) (a₂ * (n : ℝ) + b₂)
    (∀ ⦃m n : ℕ⦄, m ≤ n → n < τ → R m ≤ R n) ∧
    (∀ ⦃m n : ℕ⦄, τ < m → m ≤ n → R n ≤ R m) := by
```

This certifies that one side behaves like the classical ascent regime and the other like the modern descent regime.

---

## Why this is a breakthrough

If you succeed, you will have replaced hand-wavy “double descent plots” with a formal tropical phase diagram. That matters because:

- it gives a **geometric invariant** of interpolation: the tropical vertex;
- it makes regime-switching amenable to polyhedral and semiring methods;
- it suggests a new route to benign overfitting via dominance of tropical monomials;
- it connects statistical learning curves to discrete convexity, optimization, and information geometry.

This is how a new theory starts: by discovering the right formal object.

---

## How to build on the catalog theorems

1. **`tropical_double_descent_phase_transition`**  
   Use this as the anchor theorem. Inspect its exact statement and strengthen it in one of two ways:
   - from existence of a transition to **uniqueness** of the tropical vertex;
   - from a scalar transition statement to a **piecewise-affine decomposition** theorem.

2. **`tropical_plus_distributes_over_min`**  
   This is likely the key algebraic rewrite lemma. Use it to normalize expressions of the form
   `c + min x y = min (c + x) (c + y)`, which is exactly what you need when shifting risk by a baseline or adding a regularization offset.

3. **`tropical_sum_to_min`**  
   This indicates an ultrametric/tropical bridge. Use it conceptually to justify that aggregation of competing error scales can tropicalize to a `min` law. Even if the theorem lives over `ℚ_[p]`, it can motivate a real-valued analogue or a formal abstraction over linearly ordered semifields if feasible.

4. **`fixed_point_error`**  
   Cross-domain opportunity: define a quantized tropical risk where each affine facet is perturbed by fixed-point arithmetic error. Prove the phase transition is stable under bounded perturbation if the margin at the vertex is large enough.

5. **`two_vertex_weight`**  
   This can serve as a graph-theoretic analogy: the threshold is a two-vertex competition in a weighted network. If usable, encode the two competing regimes as a 2-node tropical graph and interpret the selected risk as shortest-path dominance.

---

## Proof strategy architecture

### Strategy A: Direct order-theoretic proof on `min` of affine functions
Most promising.

1. Define the two affine facets and tropical risk explicitly on `ℕ → ℝ`.
2. Prove side-selection lemmas:
   - if `f n ≤ g n`, then `min (f n) (g n) = f n`;
   - if `g n ≤ f n`, then `min (f n) (g n) = g n`.
3. Use equality at `τ` plus strict inequalities on either side to prove:
   - exact identification of dominant facet left and right of `τ`;
   - uniqueness of crossing by linear cancellation.

Why this is best: it is robust, elementary, and aligns with Lean’s order/ring automation.

### Strategy B: Recast as a tropical convexity / polyhedral geometry theorem
More visionary, slightly harder.

1. Define the epigraph of `R(n) = min(f n)(g n)` as the lower envelope of two affine planes.
2. Show `τ` is exactly the projection of a non-differentiable point of the lower envelope.
3. Formalize uniqueness via slope separation `a₁ ≠ a₂`.

Why it matters: this turns the theorem into a genuine tropical geometry statement and prepares higher-dimensional generalizations where complexity is a vector of hyperparameters.

### Strategy C: Stability under perturbation via error bounds
High impact if time permits.

1. Introduce perturbed facets
   `f̃ n = f n + ε₁ n`, `g̃ n = g n + ε₂ n`
   with `|εᵢ n| ≤ η`.
2. Prove that if the dominance gap away from `τ` exceeds `2η`, then the phase assignment is unchanged.
3. Use `fixed_point_error` as a model perturbation theorem.

Why this is powerful: it converts the idealized phase diagram into a numerically stable statement relevant to finite-precision training and empirical measurement.

---

## Cross-domain connections you should explicitly exploit

### 1. Tropical geometry × statistical learning theory
The lower envelope of affine functions is the tropical analogue of a free-energy landscape. The interpolation threshold becomes a tropical singularity. This is the central bridge.

### 2. Statistical mechanics × double descent
Interpret each affine facet as an “energy branch” and the switch as a zero-temperature phase transition. The tropical limit is the zero-temperature limit of log-sum-exp. If formalization is feasible, define
`softRisk_β n = -(1/β) * log (exp (-β f n) + exp (-β g n))`
and prove pointwise convergence to `min (f n) (g n)` as a mathematical motivation, even if not fully formalized in Lean this cycle.

### 3. Information geometry / p-adic ultrametrics
Use `tropical_sum_to_min` as evidence that competing scales often collapse to `min` under non-Archimedean or tropical limits. This suggests a new interpretation of generalization phases as ultrametric dominance classes.

### 4. Numerical analysis / quantization
Through `fixed_point_error`, show the tropical phase transition is stable under bounded arithmetic noise. This makes the theorem computationally meaningful, not just symbolic.

### 5. Network optimization / shortest paths
Through `two_vertex_weight`, reinterpret regime competition as path competition in a two-node weighted graph. Tropical risk is then a shortest-path selector. This could seed a graph-theoretic generalization where many candidate inductive biases compete.

---

## Concrete Lean 4 implementation plan

1. Create a file such as:
   `MachineLearning/TropicalDoubleDescentPhaseDiagram.lean`

2. Define:
   - `classicalFacet : ℝ → ℝ → ℕ → ℝ`
   - `modernFacet : ℝ → ℝ → ℕ → ℝ`
   - `tropicalRisk : ℝ → ℝ → ℝ → ℝ → ℕ → ℝ`

3. Prove basic simp lemmas:
   - unfolding lemmas for each definition;
   - dominance lemmas for `min_eq_left`, `min_eq_right`;
   - affine equality rearrangement lemmas.

4. Then prove, in order:
   - `tropical_risk_piecewise_affine`
   - `tropical_vertex_at_threshold`
   - `unique_tropical_corner_crossing`
   - `classical_modern_regime_monotonicity`

5. If the existing theorem
   `tropical_double_descent_phase_transition`
   already states some version of this, prove a **strict strengthening** theorem whose assumptions are slightly more structured but whose conclusion is substantially sharper.

---

## What would count as a field-opening extension

If the 1D complexity index succeeds, do not stop. The real prize is a multidimensional tropical phase diagram.

For example, define complexity as `(width, depth) : ℕ × ℕ`, encode risk as the minimum of finitely many affine forms in two variables, and prove that interpolation thresholds form a tropical hypersurface. That would turn “double descent” into a first case of a general theorem on **polyhedral learning phases**.

A possible target:

```lean
def affine2 (a b c : ℝ) (p : ℕ × ℕ) : ℝ :=
  a * (p.1 : ℝ) + b * (p.2 : ℝ) + c

def tropicalRisk2 (L : Finset (ℝ × ℝ × ℝ)) (p : ℕ × ℕ) : ℝ :=
  L.inf' (by ... ) (fun t => affine2 t.1 t.2.1 t.2.2 p)
```

Then show phase boundaries are loci where at least two affine forms are equal and jointly minimal. That is genuine tropical geometry entering learning theory.

---

## Application keywords

tropical geometry, double descent, interpolation threshold, min-plus algebra, phase transition, polyhedral risk, benign overfitting, statistical mechanics, ultrametric learning theory, information geometry, shortest paths, numerical stability, finite precision, tropical convexity, piecewise-affine learning curves

---

## Deliverables

1. Lean 4 theorem file(s) with minimized `sorry`.
2. At least one theorem with a precise phase-transition interpretation, not just a definitional identity.
3. Explicit use or strengthening of `tropical_double_descent_phase_transition`.
4. At least one cross-domain lemma or discussion embedded in comments/docstrings.
5. A structured `FUTURE_DIRECTIONS.md` with **3–5 concrete breakthrough next steps**, for example:
   - multidimensional tropical phase boundaries for width/depth/data-size triples;
   - perturbation-stable interpolation thresholds under quantization noise;
   - tropical free-energy limits of soft risk via log-sum-exp;
   - tropical mutual information as a predictor of phase changes;
   - graph-theoretic learning phases via shortest-path competition.

### Team Directive
Create a research team loop:
- one thread for theorem proving in Lean;
- one for counterexample search when assumptions are too weak;
- one for geometric interpretation and statement sharpening;
- one for catalog-integration and theorem reuse.

Do not settle for a toy observation. Isolate the exact theorem where double descent first becomes tropical mathematics.

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
