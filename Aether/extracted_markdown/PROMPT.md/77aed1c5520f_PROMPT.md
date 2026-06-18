## Assignment: Charge-dependent surgery

Mode: **prove**

Prove a genuinely new theorem family showing that tropical shortest-path geometry on a graph with a wormhole edge is controlled not just by the wormhole weight, but by a **gauge-covariant charge defect** at the wormhole endpoints. The key breakthrough is to make surgery cost depend on endpoint potential mismatch `|A u - A v|`, and then prove that this dependence is the only obstruction up to gauge. This turns graph surgery into a tropical analogue of adding a charged tunneling channel in a discrete electromagnetic background.

You should aim for a result that is mathematically clean, Lean-formalizable, and conceptually catalytic: it opens a program connecting tropical graph metrics, electrical networks, min-plus optimal transport with source terms, and eventually categorical semantics of graph rewrites.

### Core theorem target

Work in the same framework as the existing tropical distance development, especially anything analogous to:

- `tropicalDistance_bellman_le`
- `tropicalDistance_wormholeSurgery_le`

Define a **charged wormhole penalty**
\[
\mathrm{chargedPenalty}(A,u,v,\lambda,\kappa) := \lambda + \kappa \cdot |A\,u - A\,v|
\]
where:
- `A : V → ℝ` is a gauge potential / charge potential,
- `u v : V` are wormhole endpoints,
- `λ : ℝ` is the base surgery cost,
- `κ : ℝ` is a nonnegative coupling constant.

Then define a modified surgery graph/distance where the wormhole edge `(u,v)` is inserted with weight `chargedPenalty A u v λ κ`.

The theorem to prove is that the new tropical distance is bounded by the old one plus this charge-dependent defect, and that this defect is gauge-invariant under addition of constants.

### Precise theorem statement

A strong target statement is:

\[
\forall x\,y,\quad d_{\mathrm{surgery}(A,u,v,\lambda,\kappa)}(x,y)
\le
\min\big(d(x,y),\ d(x,u)+\lambda+\kappa |A u-A v|+d(v,y),\ d(x,v)+\lambda+\kappa |A u-A v|+d(u,y)\big).
\]

This is the correct charged refinement of the ordinary wormhole surgery inequality. It says the graph can only get shorter by routing through the charged tunnel, and the tunnel cost is exactly renormalized by the endpoint charge mismatch.

A second theorem should show **gauge invariance**:

\[
\forall c,\quad |(A+c)(u) - (A+c)(v)| = |A(u)-A(v)|
\]
and hence the charged penalty and all resulting surgery bounds are invariant under global gauge shifts.

A third theorem should isolate the pure perturbative comparison:

\[
d_{\mathrm{charged}}(x,y) \le d_{\mathrm{uncharged}}(x,y) + \kappa |A u - A v|.
\]

This is especially useful because it packages the effect of charge as a Lipschitz perturbation of ordinary surgery.

### Suggested Lean 4 theorem signatures

You should adapt names/types to the actual graph API in Mathlib and the local tropical files, but the intended signatures are of the following form.

```lean
def chargedPenalty {V : Type _} (A : V → ℝ) (u v : V) (λ κ : ℝ) : ℝ :=
  λ + κ * |A u - A v|
```

```lean
theorem chargedPenalty_gaugeInvariant
    {V : Type _} (A : V → ℝ) (u v : V) (λ κ c : ℝ) :
    chargedPenalty (fun x => A x + c) u v λ κ = chargedPenalty A u v λ κ := by
  ...
```

```lean
theorem abs_sub_gauge_shift
    {V : Type _} (A : V → ℝ) (u v : V) (c : ℝ) :
    |((A u + c) - (A v + c))| = |A u - A v| := by
  ...
```

If the existing development has a distance function of the form `tropicalDistance W x y`, then the main theorem should look approximately like:

```lean
theorem tropicalDistance_chargedWormholeSurgery_le
    {V : Type _}
    (W : V → V → ℝ)
    (A : V → ℝ)
    (u v x y : V)
    (λ κ : ℝ)
    (hκ : 0 ≤ κ) :
    tropicalDistance (chargedWormholeSurgery W A u v λ κ) x y ≤
      min (tropicalDistance W x y)
        (min
          (tropicalDistance W x u + chargedPenalty A u v λ κ + tropicalDistance W v y)
          (tropicalDistance W x v + chargedPenalty A u v λ κ + tropicalDistance W u y)) := by
  ...
```

And the perturbative comparison theorem:

```lean
theorem tropicalDistance_chargedWormholeSurgery_le_uncharged_plus
    {V : Type _}
    (W : V → V → ℝ)
    (A : V → ℝ)
    (u v x y : V)
    (λ κ : ℝ)
    (hκ : 0 ≤ κ) :
    tropicalDistance (chargedWormholeSurgery W A u v λ κ) x y ≤
      tropicalDistance (wormholeSurgery W u v λ) x y + κ * |A u - A v| := by
  ...
```

If the current library uses `ENNReal`, `WithTop ℝ`, or a custom tropical semiring instead of raw `ℝ`, adjust the signatures accordingly. But preserve the mathematical content exactly.

## Proof architecture

### Strategy A: Bellman-style dynamic programming lift from existing surgery theorem
This is the most promising path.

1. **Define the charged weight matrix as a scalar perturbation of the wormhole edge weight.**
   Reuse the exact construction behind `tropicalDistance_wormholeSurgery_le`, changing only the inserted edge weight from `λ` to `λ + κ * |A u - A v|`.

2. **Invoke the same path candidate argument as in `tropicalDistance_bellman_le`.**
   The key point is that every path in the surgically modified graph is either:
   - an old path in `W`, or
   - a path using the new wormhole once, yielding one of the two mixed terms
     `d x u + chargedPenalty + d v y` or
     `d x v + chargedPenalty + d u y`.

3. **Package the resulting inequality with nested `min` simplification.**
   This should be almost line-for-line parallel to the existing surgery proof, except the scalar edge weight is replaced by `chargedPenalty`.

Why this is strongest: it gives the cleanest theorem, minimizes new infrastructure, and directly leverages the catalog’s existing shortest-path lemmas.

### Strategy B: Distance comparison via pointwise weight monotonicity
This is conceptually elegant and may be easier if the graph API has monotonicity lemmas.

1. Show that
   \[
   \mathrm{wormholeWeight}_{\mathrm{uncharged}} \le \mathrm{wormholeWeight}_{\mathrm{charged}}
   \]
   whenever `0 ≤ κ * |A u - A v|`.

2. Use a theorem of the form “larger edge weights imply larger tropical distances” to compare charged surgery to ordinary surgery.

3. Combine with the already-proved `tropicalDistance_wormholeSurgery_le` for the uncharged case, then add the scalar defect term.

Why useful: it isolates charge as an order-theoretic perturbation and may generalize later to multi-wormhole or distributed charge fields.

### Strategy C: Tropical linear operator viewpoint
This is the most visionary route and should at least inform naming and future API design.

1. Regard surgery as a rank-two min-plus operator modifying the adjacency/kernel.
2. Interpret `κ * |A u - A v|` as a gauge-covariant scalar on the surgery generator.
3. Prove that the surgery operator intertwines global gauge shifts.

This route may not be the shortest formal proof today, but it is the right abstraction if you want the next cycle to build the promised category/functor from graph surgeries to tropical linear operators.

## Key supporting lemmas you should likely prove first

These are small but structurally important.

```lean
theorem chargedPenalty_nonneg_defect
    {V : Type _} (A : V → ℝ) (u v : V) (κ : ℝ) (hκ : 0 ≤ κ) :
    0 ≤ κ * |A u - A v| := by
  ...
```

```lean
theorem chargedPenalty_eq_base_add_defect
    {V : Type _} (A : V → ℝ) (u v : V) (λ κ : ℝ) :
    chargedPenalty A u v λ κ = λ + κ * |A u - A v| := rfl
```

```lean
theorem chargedPenalty_symm
    {V : Type _} (A : V → ℝ) (u v : V) (λ κ : ℝ) :
    chargedPenalty A u v λ κ = chargedPenalty A v u λ κ := by
  ...
```

The symmetry lemma matters: it ensures the charge defect depends only on endpoint mismatch, not orientation, which aligns with physical intuition and simplifies surgery estimates.

## How to build on catalog theorems

The listed verified theorems are not directly about graph surgery, but they signal a broader tropical ecosystem already in place. Use that ecosystem philosophically, not mechanically.

- `tropical_spectral_bound`  
  This suggests there is already a matrix/operator perspective in the codebase. After proving the surgery inequality, relate the charged surgery operator to a low-rank perturbation of the tropical adjacency operator. Even a lemma or comment in the file about this perspective will make the next breakthrough easier.

- `tropical_security_from_norm_bound`  
  This indicates a pattern: quantitative bounds in tropical settings can become application theorems. Your charged surgery inequality should be phrased quantitatively enough that it can later become a robustness/certification theorem for networks with shortcut edges and node potentials.

- `tropical_mirror_theorem`  
  Trivial mathematically, but it reminds us that idempotent/tropical simplifications should be exploited aggressively. Expect many `min`/`max` normalizations and prove helper lemmas so the main theorem statement becomes readable.

Do not get distracted by unrelated catalog results; instead, make this theorem the first serious bridge between tropical graph geometry and gauge-type structures.

## Cross-domain connections

### Electrical networks
Interpret `A : V → ℝ` as electric potential. Then `|A u - A v|` is the voltage drop across the wormhole endpoints. The theorem says adding a shortcut is less effective when it bridges a large potential mismatch. This is a tropical analogue of transport through a charged or resistive defect.

### Optimal transport with source/sink terms
The additive defect `κ |A u - A v|` behaves like a creation/annihilation surcharge or imbalance penalty. This suggests a min-plus transport geometry where graph shortcuts pay for endpoint mismatch. The theorem is a first discrete comparison principle in that setting.

### Gauge theory / discrete physics
Global shifts `A ↦ A + c` leave all observable quantities unchanged. Formalizing this in Lean is more than cosmetic: it shows the metric perturbation depends only on gauge-invariant data. This opens the door to discrete tropical electromagnetism.

### Tropical linear algebra
The surgery operation is a low-rank perturbation of a tropical kernel. Charge dependence turns that perturbation into a scalar-twisted rank-two update. This is the right language for the categorical “graph surgeries as operators” program hinted at below.

## Why this is a breakthrough

This is not “wormhole surgery with one more parameter.” The real content is that you are introducing **gauge-covariant tropical metric surgery**: a new structure in which graph distances respond to endpoint field mismatch in a controlled, formally provable way. That opens at least four programs:

1. **Tropical discrete gauge geometry**  
   Graph metrics coupled to potentials, with invariance under gauge shifts.

2. **Charged optimal transport on graphs**  
   Shortest paths with source/sink or imbalance penalties.

3. **Operator-theoretic graph rewrites**  
   Surgeries as tropical linear transformations, eventually functorial.

4. **Certified network robustness with latent potentials**  
   Shortcut effects bounded by an interpretable defect term.

A research mathematician should look at this and say: “This is the first lemma in a theory, not the last lemma in a file.”

## Formalization guidance

- Reuse the exact file where `tropicalDistance_wormholeSurgery_le` lives, or create a nearby file such as:
  `Tropical/Graph/ChargedSurgery.lean`
  if the current development is modular enough.
- Keep definitions lightweight: one penalty function, one surgery constructor, 3–5 structural lemmas, then the main theorem.
- Minimize sorry by proving tiny arithmetic lemmas separately (`abs_sub_comm`, gauge-shift cancellation, nonnegativity of defect, `ring_nf`-friendly forms).
- If the graph distance is defined via an infimum over path weights, isolate a path that uses the wormhole exactly once; if it is defined Bellman-style, isolate the relevant one-step relaxation inequality.

## Concrete deliverables

1. A formal definition of `chargedPenalty`.
2. A formal definition of charged wormhole surgery extending the uncharged one.
3. A gauge invariance lemma for the defect and penalty.
4. The main charged surgery upper bound theorem.
5. The perturbative comparison to ordinary wormhole surgery.
6. At least one symmetry or monotonicity lemma that clearly indicates the theory scales.

## Application keywords

`tropical geometry`, `shortest paths`, `min-plus algebra`, `graph surgery`, `gauge invariance`, `electrical networks`, `optimal transport`, `discrete gauge theory`, `tropical linear operators`, `low-rank perturbations`, `network robustness`, `categorical graph rewriting`

## Stretch goal: categorical operator bridge

The fragment about “Categorical Functor from Graph Surgeries to Tropical Linear Operators” should not remain motivational fluff. If time permits, state and perhaps partially formalize the following meta-theorem:

- graph surgeries generated by adding a weighted edge define morphisms in a category of weighted graphs,
- each such surgery induces a tropical linear operator on distance kernels or adjacency kernels,
- charged surgeries are precisely those morphisms decorated by gauge-invariant endpoint defects.

Even one precise definition here would set up a future major theorem.

## Required final artifact

Produce a structured `FUTURE_DIRECTIONS.md` with **3–5 concrete breakthrough-level next steps**, for example:
- multi-wormhole charged surgery with subadditive interaction bounds,
- tropical Hodge/Laplacian interpretation of gauge potentials,
- charged Kantorovich duality on graphs,
- functoriality of graph surgeries into tropical operator categories,
- spectral control of charged surgeries using `tropical_spectral_bound`.

Be specific: each future direction should contain an explicit conjectural theorem statement, not just a topic label.

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

Research domain: Tropical
Research mode: prove
