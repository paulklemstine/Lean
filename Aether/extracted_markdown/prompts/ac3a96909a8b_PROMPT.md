## Assignment: Deep Double Descent as Tropical Phase Diagram

Mode: **prove**

You are not being asked for a metaphor. You are being asked to carve out a formal theorem that turns “double descent” into a certified min-plus geometric event. The breakthrough is to replace vague statistical narratives by an exact tropical phase diagram: two affine risk laws, one classical and one overparameterized, glued by `min`, with the interpolation threshold characterized as the unique tropical vertex where the active facet changes.

This is field-opening if done cleanly: it would give a formally verified bridge between statistical learning theory, tropical geometry, and piecewise-linear phase transitions. It creates a language in which “generalization curves” become tropical hypersurfaces, interpolation thresholds become vertices, and descent regimes become facet dominance regions. That is not an incremental variant of existing ML formalization; it is a new organizing principle.

### Core theorem target

Define a simple but nontrivial tropical risk model over a discrete complexity parameter `n : ℕ`, with interpolation threshold `n₀ : ℕ`, and two affine candidate risks:
- a **classical** branch decreasing toward the threshold,
- a **modern** branch decreasing after overparameterization,
- and a global risk given by the tropical minimum of the two branches.

The exact theorem should certify:
1. branch dominance on each side of the threshold,
2. equality at the threshold,
3. strict monotonicity toward the threshold from the left and away from the threshold on the right,
4. a local maximum at the threshold,
5. and therefore a formal “double descent” shape induced by a tropical corner crossing.

A precise formal target is:

```lean
def classicalRisk (A B : ℝ) (n₀ n : ℕ) : ℝ :=
  A + B * (n : ℝ) - 2 * B * (n₀ : ℝ)

def modernRisk (A B : ℝ) (n₀ n : ℕ) : ℝ :=
  A - B * (n : ℝ)

def tropicalRisk (A B : ℝ) (n₀ n : ℕ) : ℝ :=
  min (classicalRisk A B n₀ n) (modernRisk A B n₀ n)
```

with the key theorem:

```lean
theorem tropical_double_descent_phase_transition
    {A B : ℝ} (hB : 0 < B) (n₀ n : ℕ) :
    ((n ≤ n₀) →
      tropicalRisk A B n₀ n = classicalRisk A B n₀ n) ∧
    ((n₀ ≤ n) →
      tropicalRisk A B n₀ n = modernRisk A B n₀ n) ∧
    tropicalRisk A B n₀ n₀ = A - B * (n₀ : ℝ) ∧
    ((n < n₀) →
      tropicalRisk A B n < tropicalRisk A B (n+1)) ∧
    ((n₀ ≤ n) →
      tropicalRisk A B (n+1) < tropicalRisk A B n)
```

You may want to split this into cleaner lemmas rather than forcing one giant theorem. In fact, the most elegant architecture is likely:

```lean
theorem classical_le_modern_iff {A B : ℝ} (hB : 0 < B) (n₀ n : ℕ) :
    classicalRisk A B n₀ n ≤ modernRisk A B n₀ n ↔ n ≤ n₀

theorem modern_le_classical_iff {A B : ℝ} (hB : 0 < B) (n₀ n : ℕ) :
    modernRisk A B n₀ n ≤ classicalRisk A B n₀ n ↔ n₀ ≤ n

theorem tropicalRisk_left_facet {A B : ℝ} (hB : 0 < B) {n₀ n : ℕ} (h : n ≤ n₀) :
    tropicalRisk A B n₀ n = classicalRisk A B n₀ n

theorem tropicalRisk_right_facet {A B : ℝ} (hB : 0 < B) {n₀ n : ℕ} (h : n₀ ≤ n) :
    tropicalRisk A B n₀ n = modernRisk A B n₀ n

theorem tropicalRisk_vertex {A B : ℝ} (hB : 0 < B) (n₀ : ℕ) :
    classicalRisk A B n₀ n₀ = modernRisk A B n₀ n₀

theorem tropicalRisk_strictly_increases_to_threshold
    {A B : ℝ} (hB : 0 < B) {n₀ n : ℕ} (h : n < n₀) :
    tropicalRisk A B n₀ n < tropicalRisk A B n₀ (n+1)

theorem tropicalRisk_strictly_decreases_after_threshold
    {A B : ℝ} (hB : 0 < B) {n₀ n : ℕ} (h : n₀ ≤ n) :
    tropicalRisk A B n₀ (n+1) < tropicalRisk A B n₀ n
```

This is already substantial and formalizable. But do not stop there.

### Stronger breakthrough theorem

Upgrade from a hand-crafted model to a general tropical criterion. Define two affine forms on `ℕ`:
```lean
def affineNat (α β : ℝ) (n : ℕ) : ℝ := α + β * (n : ℝ)
def tropicalAffineRisk (α₁ β₁ α₂ β₂ : ℝ) (n : ℕ) : ℝ :=
  min (affineNat α₁ β₁ n) (affineNat α₂ β₂ n)
```

Then prove a general phase-transition theorem:

> If `β₁ > 0`, `β₂ < 0`, and there exists a unique `n₀ : ℕ` such that
> `affineNat α₁ β₁ n₀ = affineNat α₂ β₂ n₀`, then `tropicalAffineRisk α₁ β₁ α₂ β₂`
> has a unique tropical vertex at `n₀`, is strictly increasing on `{n | n ≤ n₀}`,
> strictly decreasing on `{n | n ≥ n₀}`, and the active minimizer switches exactly at `n₀`.

A Lean-oriented signature:

```lean
theorem tropical_affine_unique_vertex
    {α₁ β₁ α₂ β₂ : ℝ} {n₀ : ℕ}
    (hβ₁ : 0 < β₁) (hβ₂ : β₂ < 0)
    (hcross : affineNat α₁ β₁ n₀ = affineNat α₂ β₂ n₀)
    (huniq : ∀ n : ℕ, affineNat α₁ β₁ n = affineNat α₂ β₂ n → n = n₀) :
    (∀ n ≤ n₀, tropicalAffineRisk α₁ β₁ α₂ β₂ n = affineNat α₁ β₁ n) ∧
    (∀ n₀ ≤ n, tropicalAffineRisk α₁ β₁ α₂ β₂ n = affineNat α₂ β₂ n) ∧
    (∀ n < n₀, tropicalAffineRisk α₁ β₁ α₂ β₂ n < tropicalAffineRisk α₁ β₁ α₂ β₂ (n+1)) ∧
    (∀ n₀ ≤ n, tropicalAffineRisk α₁ β₁ α₂ β₂ (n+1) < tropicalAffineRisk α₁ β₁ α₂ β₂ n)
```

This is the right theorem: abstract, reusable, and mathematically recognizable as a tropical phase-transition principle.

### Why this is a breakthrough

Because it extracts the essence of double descent from statistics and reifies it as a theorem in tropical convexity. Once proved, you have:
- a formal notion of interpolation threshold as a **tropical vertex**,
- a certified decomposition of risk into **competing affine facets**,
- a path to higher-dimensional tropical phase diagrams for multiple hyperparameters,
- and a language to compare learning curves with phase transitions in statistical physics.

This opens a program, not a one-off theorem.

### Build explicitly on catalog theorems

Use the catalog theorem
- `tropical_plus_distributes_over_min` from `Bridges/MinPlusVerificationCore.lean`

as an algebraic engine when manipulating expressions of the form
`a + min b c = min (a+b) (a+c)`.
This is exactly the identity needed to normalize affine tropical risks and compare shifted branches.

Also inspect
- `tropical_sum_to_min` from `MachineLearning/PadicInfoGeom/UltrametricKLDivergence.lean`

for conceptual transfer: it suggests that additive competition laws can collapse to min-laws under valuation-like transforms. Even if not used directly in the final proof, it is a clue for the broader bridge theorem: double descent can be interpreted as a valuation shadow of competing error mechanisms.

If useful, `fixed_point_error` from `MachineLearning/Neural/InferenceArithmetic.lean` can power a robustness corollary: quantized arithmetic perturbs the tropical vertex by a bounded amount, giving a certified shift in the interpolation threshold.

### Proof strategy architecture

#### Strategy A: direct order-theoretic proof on affine differences
Most promising.

1. Define the branch difference:
   ```lean
   def branchGap (A B : ℝ) (n₀ n : ℕ) : ℝ :=
     modernRisk A B n₀ n - classicalRisk A B n₀ n
   ```
   Then simplify to
   `2 * B * ((n₀ : ℝ) - (n : ℝ))`.

2. Prove sign characterization:
   - if `n ≤ n₀`, then `0 ≤ branchGap ...`,
   - if `n₀ ≤ n`, then `branchGap ... ≤ 0`.
   This yields branch dominance by linear arithmetic (`nlinarith` should do most of the work after coercions are normalized).

3. Rewrite `tropicalRisk = min _ _`, apply `min_eq_left` / `min_eq_right`, and derive the facet formulas.
   Then strict monotonicity is immediate because each active facet is affine with slope `+B` on the left and `-B` on the right.

Why this is best: it is elementary, robust in Lean, and exposes the exact geometric mechanism.

#### Strategy B: tropical algebra normalization
Elegant and useful for generalization.

1. Rewrite both branches relative to the vertex value:
   ```lean
   tropicalRisk A B n₀ n
   = (A - B * (n₀ : ℝ)) + min (B * ((n : ℝ) - (n₀ : ℝ))) (-B * ((n : ℝ) - (n₀ : ℝ)))
   ```
   using `tropical_plus_distributes_over_min`.

2. Interpret the inner term as a tropical absolute-value profile:
   `min(x, -x) = -|x|` over reals, so the risk becomes
   `vertexValue - B * |(n : ℝ) - n₀|`.

3. Deduce the unique maximum at `n₀` and both monotonicity directions from properties of absolute value.

Why this matters: it identifies double descent with a tropical cone profile, making the geometry obvious and preparing the jump to multidimensional hyperparameter landscapes.

#### Strategy C: finite-difference / discrete convexity route
Best for future generalization to multiple corners.

1. Define the discrete derivative
   ```lean
   Δf n := f (n+1) - f n
   ```
   for `f := tropicalRisk A B n₀`.

2. Prove:
   - `Δf n = B` for `n < n₀`,
   - `Δf n = -B` for `n₀ ≤ n`.

3. Conclude that the derivative changes sign exactly once, hence there is a unique phase transition.

Why this is powerful: it suggests a formal theory of tropical learning curves via discrete Morse-type invariants and can scale to several competing branches.

### Cross-domain bridge theorems to attempt next in the same file

Do not settle for the 1D theorem. Add at least one bridge result.

#### Bridge 1: statistical physics
Formalize the analogy with zero-temperature free energy. Define
```lean
def freeEnergyLike (E₁ E₂ T : ℝ) : ℝ :=
  -T * Real.log (Real.exp (-E₁ / T) + Real.exp (-E₂ / T))
```
and prove, at least informally first and then in a restricted Lean form if feasible, that as `T → 0⁺` this converges to `min E₁ E₂`. Then interpret tropical risk as the zero-temperature limit of competing error channels. This is the statistical mechanics meaning of double descent as a phase transition.

#### Bridge 2: p-adic / valuation geometry
Using the spirit of `tropical_sum_to_min`, formulate a theorem schema:
under a valuation transform, additive combinations of model-complexity penalties collapse to tropical minima. This would frame double descent as a valuation image of hidden algebraic competition. Even a modest formal bridge lemma here would be novel.

#### Bridge 3: quantization and certified threshold shift
Using `fixed_point_error`, prove a perturbation theorem of the form:
if each branch is approximated within `ε`, then the tropical vertex location is stable up to an explicit one-step or bounded drift condition whenever the branch gap away from the threshold exceeds `2ε`.

A possible signature:

```lean
theorem tropical_vertex_stability_under_uniform_error
    {f g f' g' : ℕ → ℝ} {n₀ : ℕ} {ε : ℝ}
    (hε : 0 ≤ ε)
    (hfg : ∀ n, |f' n - f n| ≤ ε ∧ |g' n - g n| ≤ ε)
    (hsep : ∀ n ≠ n₀, 2 * ε < |f n - g n|) :
    ∀ n ≠ n₀, min (f' n) (g' n) ≠ min (f' n₀) (g' n₀)
```

This would turn the theorem into a verification tool for finite-precision ML.

### Concrete Lean implementation guidance

Use concrete types:
- complexity parameter: `ℕ`
- risks: `ℝ`

Likely useful imports:
```lean
import Mathlib.Data.Real.Basic
import Mathlib.Algebra.Order.MinMax
import Mathlib.Tactic
```

Likely useful lemmas/tactics:
- `min_eq_left`, `min_eq_right`
- `Nat.cast_le`, `Nat.cast_lt`
- `sub_nonneg`, `sub_nonpos`
- `linarith`, `nlinarith`, `ring_nf`
- `by_cases h : n ≤ n₀`

A very likely useful normalization lemma:

```lean
lemma classicalRisk_sub_modernRisk
    (A B : ℝ) (n₀ n : ℕ) :
    classicalRisk A B n₀ n - modernRisk A B n₀ n
      = 2 * B * ((n : ℝ) - (n₀ : ℝ)) := by
  ring_nf
```

and its sign consequences.

### Nontrivial corollary target

After the main theorem, prove a uniqueness corollary:

```lean
theorem tropicalRisk_unique_maximum
    {A B : ℝ} (hB : 0 < B) (n₀ n : ℕ) :
    tropicalRisk A B n₀ n ≤ tropicalRisk A B n₀ n₀
```

with strict inequality when `n ≠ n₀`.

This elevates the result from “shape intuition” to a certified extremal theorem.

### Application keywords

tropical geometry, double descent, interpolation threshold, min-plus algebra, phase transition, statistical learning theory, discrete convexity, zero-temperature limit, valuation theory, certified robustness, quantization error, piecewise-affine risk, formal verification, Lean 4, Mathlib

### Deliverables

1. A Lean file proving the main tropical double descent theorem and at least two supporting lemmas.
2. A stronger abstract theorem for `min` of two affine functions on `ℕ`.
3. At least one cross-domain bridge lemma or corollary, preferably quantization stability or zero-temperature/tropical correspondence.
4. Minimal sorry usage; if a theorem is too ambitious, isolate the exact obstruction and prove the strongest clean restricted version.
5. Produce a structured `FUTURE_DIRECTIONS.md` with **3–5 concrete breakthrough next steps**, such as:
   - tropical phase diagrams in two hyperparameters,
   - tropical Morse theory for learning curves,
   - certified threshold drift under noisy arithmetic,
   - valuation-theoretic derivation of min-plus risk,
   - tropical information-theoretic generalization bounds.

### Final directive

Do not merely encode a toy example. Distill a reusable theorem schema: **double descent is the tropical vertex theorem for competing affine risk facets**. If you can formalize that cleanly, you will have created a new bridge between learning theory and tropical mathematics that others can build an entire research program on top of.

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
