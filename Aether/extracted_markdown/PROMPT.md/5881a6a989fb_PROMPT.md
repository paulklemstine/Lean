## Assignment: Compositional bound

Mode: **prove**

Aristotle, do not treat this as a routine inequality about two radii. The real target is a structural theorem explaining how **local tropical margin geometry** and **linear-region combinatorics** compose into a global certification principle. If formalized cleanly, this becomes a bridge theorem between tropical geometry, piecewise-affine deep learning, and exact verification.

You should prove a theorem of the following form, with a Lean statement precise enough to guide implementation.

### Core theorem: local-global certified radius lower bound

Let `f : (Fin n → ℝ) → (Fin k → ℝ)` be a piecewise-affine classifier, let `x₀ : Fin n → ℝ`, and let `y : Fin k` be the predicted class at `x₀`. Assume:
1. `x₀` lies in a linear region `R`,
2. on `R`, each logit difference `f y - f j` is affine,
3. `r_local` is a certified lower bound coming from the affine margin functions within `R`,
4. `r_region` is the distance from `x₀` to the boundary of `R`.

Then the global certified radius is at least the minimum of these two scales:
\[
r_{\mathrm{global}} \ge \min(r_{\mathrm{local}}, r_{\mathrm{region}}).
\]

The nontrivial part is not the inequality itself but the **equality characterization**:
\[
r_{\mathrm{global}} = \min(r_{\mathrm{local}}, r_{\mathrm{region}})
\]
iff the first obstruction to robustness is realized either
- by a class-tie hypersurface inside the current region, or
- by a region-boundary crossing after which some competing class can become optimal arbitrarily close to the boundary.

This should be formulated as a theorem about the infimum of adversarial perturbation norms.

### Suggested Lean 4 theorem signature

A first robust target is a theorem at the level of abstract radii, before specializing to ReLU/tropical networks:

```lean
theorem global_radius_ge_min_local_region
  {n k : ℕ}
  (f : (Fin n → ℝ) → (Fin k → ℝ))
  (x₀ : Fin n → ℝ)
  (y : Fin k)
  (r_global r_local r_region : ℝ)
  (hy : ∀ j, f x₀ y ≥ f x₀ j)
  (hlocal : IsLocalCertifiedRadius f x₀ y r_local)
  (hregion : IsRegionRadius f x₀ r_region)
  (hcompat : LocalCertificateValidOnRegion f x₀ y r_local r_region) :
  r_global ≥ min r_local r_region
```

The breakthrough version should then sharpen to an equality criterion:

```lean
theorem global_radius_eq_min_local_region_iff
  {n k : ℕ}
  (f : (Fin n → ℝ) → (Fin k → ℝ))
  (x₀ : Fin n → ℝ)
  (y : Fin k)
  (r_global r_local r_region : ℝ)
  (hy : ∀ j, f x₀ y ≥ f x₀ j)
  (hlocal : IsExactLocalRadius f x₀ y r_local)
  (hregion : IsExactRegionRadius f x₀ r_region) :
  r_global = min r_local r_region ↔
    FirstFailureByMargin f x₀ y r_local ∨ FirstFailureByRegionEscape f x₀ y r_region
```

If these predicates do not yet exist, define them. This is preferable to baking all semantics directly into one giant theorem.

## Mathematical framing

Inside a fixed linear region, a ReLU or tropical-rational network behaves as an affine map. Therefore the multiclass decision rule is controlled by affine margin functions
\[
\Delta_{y,j}(x) := f_y(x) - f_j(x).
\]
The **local radius** is the largest ball around `x₀` on which all these affine margins stay nonnegative while remaining in the same region. The **region radius** is the distance to the nearest activation-pattern boundary. The global theorem says that the classifier cannot fail before one of these two mechanisms fails.

This is the right theorem because it decomposes robustness into:
- a **tropical hyperplane arrangement problem** inside a Newton cell,
- a **polyhedral escape problem** to the boundary of a linear region.

That decomposition is exactly what modern MILP verifiers and linear-region counting methods are implicitly exploiting, but usually without a theorem isolating the compositional principle.

## Build directly on catalog theorems

Use the existing verified theorems as certified primitives, not just citations:

1. `multi_class_tropical_certified_robustness`  
   Use this as the multiclass margin certificate inside a fixed region. If it gives a robustness radius from class-gap inequalities, reinterpret that radius as `r_local`.

2. `tropical_affine_lipschitz_certified_robustness`  
   This is especially important for the affine-on-region step. It should let you certify robustness of the affine restriction of the network on a cell, likely giving a lower bound that can be compared directly to the region radius.

3. `tropical_certified_robustness` and `certified_robustness_radius_positive`  
   Use these to show positivity/nontriviality of the radius once margins are strictly positive at `x₀`.

4. `tropical_interior_convex`  
   This may become useful if you formalize the linear region as a convex polyhedral cell and need a convexity/interior lemma to show that perturbations of norm `< r_region` remain in the same cell.

The key architectural move is: **reduce the global statement to a local affine certification theorem plus a region-stability lemma**.

## Proof strategies

### Strategy A: Polyhedral decomposition + first-exit argument
Most promising.

1. Define the region `R` containing `x₀` and prove:
   if `‖x - x₀‖ < r_region`, then `x ∈ R`.
2. On `R`, use piecewise-affinity to replace `f` by an affine map `A x + b`.
   Then invoke `multi_class_tropical_certified_robustness` or `tropical_affine_lipschitz_certified_robustness` to show:
   if `‖x - x₀‖ < r_local`, then class `y` remains optimal.
3. Combine the two implications to conclude:
   if `‖x - x₀‖ < min r_local r_region`, then both hypotheses hold, hence no adversarial example exists in that ball.

Why this is best: it isolates the theorem into two reusable abstractions—“stay in region” and “stay class-separated”—which will scale to later work on certified training and barrier methods.

### Strategy B: Contrapositive via minimal adversarial perturbation
Elegant for the equality characterization.

1. Define `r_global` as the infimum norm of perturbations causing misclassification.
2. Assume `r_global < min r_local r_region`.
3. Let `δ` be an adversarial perturbation with `‖δ‖ < min r_local r_region`.
   Since `‖δ‖ < r_region`, `x₀ + δ` remains in the same region.
   Since `‖δ‖ < r_local`, affine margin inequalities imply no misclassification.
4. Contradiction.

Then refine this argument to show equality occurs exactly when a minimizing perturbation hits either a margin hyperplane before the region boundary, or the region boundary before any internal tie.

Why useful: this naturally leads to exact-radius theorems and algorithms for computing witness perturbations.

### Strategy C: Tropical-geometric reformulation
Most visionary; pursue after A is working.

1. Represent the logits or class margins by tropical affine forms on a cell.
2. Interpret `r_local` as distance from `x₀` to the nearest tropical decision hypersurface restricted to the current Newton polytope cell.
3. Interpret `r_region` as distance to a face of the cell.
4. Then `r_global` is bounded below by the minimum distance to either type of tropical wall.

Why this matters: it reframes neural robustness as a metric problem in tropical polyhedral complexes. That is bigger than certification; it opens a geometric theory of expressivity-robustness tradeoffs.

## Equality characterization: exact theorem target

A more exact mathematical statement worth aiming for:

\[
r_{\mathrm{global}} = \min(r_{\mathrm{local}}, r_{\mathrm{region}})
\]
provided:
- the local radius is realized by an actual tie point of some margin hyperplane in the closure of the region, or
- the region radius is realized by an actual boundary point of the current region, and crossing that boundary permits class change arbitrarily nearby.

This should split into cases:

1. **Margin-limited case:**  
   If there exists `j ≠ y` and `x*` in the current region closure such that
   \[
   \|x^* - x₀\| = r_{\mathrm{local}}, \qquad \Delta_{y,j}(x^*) = 0,
   \]
   and `r_local ≤ r_region`, then `r_global = r_local`.

2. **Region-limited case:**  
   If every class margin stays positive strictly inside the region up to radius `r_region`, but there exists a boundary point `x*` with
   \[
   \|x^* - x₀\| = r_{\mathrm{region}}
   \]
   such that across adjacent regions the predicted class can change arbitrarily close to `x*`, and `r_region ≤ r_local`, then `r_global = r_region`.

This is the theorem that actually explains failure modes of robustness certificates.

## Algorithmic deliverable

Formalize an algorithm for computing local radii on each linear region.

For a fixed region where `f` is affine, each margin has form
\[
\Delta_{y,j}(x) = a_j \cdot x + b_j.
\]
Then for a chosen norm:
- in `L₂`, the affine-margin radius is
  \[
  \frac{\Delta_{y,j}(x₀)}{\|a_j\|_*}
  \]
  where `‖·‖_*` is the dual norm;
- in `L∞`, use `L₁` dual norm;
- in `L₁`, use `L∞` dual norm.

Thus
\[
r_{\mathrm{local}} = \min_{j \ne y} \frac{\Delta_{y,j}(x₀)}{\|a_j\|_*}
\]
subject to remaining in the same region.

This is exactly the bridge to MILP verification:
- MILP computes exact region/boundary interactions combinatorially,
- the tropical/affine formula gives closed-form local certificates,
- the compositional theorem says the true robust radius is lower bounded by their minimum.

Application keywords: **certified robustness, exact verification, MILP relaxations, tropical decision boundaries, polyhedral complexes, adversarial geometry, dual norms, affine margin certificates, linear-region expressivity**.

## Cross-domain connections

### Tropical geometry
Linear regions of ReLU/tropical networks are cells of a polyhedral complex. Margin ties are tropical hypersurfaces. Your theorem says the robust radius is controlled by distance to either:
- a tropical decision hypersurface,
- or a face of the current Newton/polyhedral cell.

This suggests a new research program: **robustness as metric tropical intersection theory**.

### Deep learning theory
Region counting alone measures expressivity, but your theorem shows that what matters for robustness is not just how many regions exist, but how far typical inputs sit from:
- decision walls inside regions,
- region walls themselves.

That opens a quantitative tradeoff between expressivity and certified stability.

### Verification
MILP-based verifiers search globally across region boundaries. Your theorem identifies the exact point where local affine certificates stop being complete: the region boundary. This gives a principled hybrid verifier:
1. compute local tropical/affine radius cheaply,
2. compute region radius,
3. launch MILP only when the region-boundary obstruction dominates.

### Interior-point certified training
The barrier-function direction hinted in the draft becomes much sharper after this theorem. Once local margins and region distances are both explicit obstructions, a training objective can penalize proximity to both:
\[
-\sum_{j \neq y}\log \Delta_{y,j}(x₀) \;-\; \sum_{\ell}\log s_\ell(x₀),
\]
where `s_ℓ` are slacks defining the current linear region. This is a genuine interior-point geometry for robust training, not just a heuristic margin loss.

## Lean formalization plan

1. Define abstract notions:
   - `IsLocalCertifiedRadius`
   - `IsExactLocalRadius`
   - `IsRegionRadius`
   - `LocalCertificateValidOnRegion`
   - `FirstFailureByMargin`
   - `FirstFailureByRegionEscape`

2. Prove generic lemmas:
   - perturbations below `r_region` remain in the same region,
   - perturbations below `r_local` preserve class order on the region,
   - conjunction gives perturbations below `min` preserve classification.

3. Specialize to tropical/ReLU affine cells using existing catalog theorems.

4. Add computable formulas for affine local radii under standard norms.

5. If possible, prove a theorem comparing the compositional bound to a global Lipschitz bound, showing the compositional bound is never worse on a fixed region and is often strictly better.

## Concrete theorem extension worth pursuing

If time permits, prove a strict-improvement theorem over naive Lipschitz certification:

```lean
theorem compositional_bound_ge_global_lipschitz_bound
  {n k : ℕ}
  (f : (Fin n → ℝ) → (Fin k → ℝ))
  (x₀ : Fin n → ℝ)
  (y : Fin k) :
  global_lipschitz_bound f x₀ y ≤ min (local_affine_margin_radius f x₀ y) (region_radius f x₀)
```

This would be a publishable conceptual statement: local polyhedral geometry dominates coarse global smoothness bounds.

## Deliverables

- Formal theorem: `r_global ≥ min(r_local, r_region)`.
- Formal equality characterization theorem with explicit failure modes.
- Computable local-radius formula on affine regions.
- Comparison theorem against standard Lipschitz-style certification methods.
- Minimal-sorry Lean development integrated with the catalog theorems above.

## Required final artifact

You must also produce a structured `FUTURE_DIRECTIONS.md` with 3–5 concrete next-step projects at breakthrough level, for example:
1. exact tropical distance-to-decision-boundary algorithms on polyhedral complexes,
2. interior-point robust training via joint margin/region barriers,
3. tropical-MILP hybrid verifiers with completeness certificates,
4. expressivity-vs-robustness theorems using region adjacency graphs,
5. certified robustness as a sheaf/stratification invariant on piecewise-linear models.

Do not settle for a bound alone. Extract the geometry of why the bound is true and when it is sharp.

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
