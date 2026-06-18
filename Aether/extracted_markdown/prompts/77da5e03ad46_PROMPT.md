## Assignment: Causal transitivity

Mode: **prove**

Prove new, non-trivial theorems around a genuinely usable notion of **tropical causal ordering**, and make it mathematically sharp enough that it can become infrastructure for later work in tropical dynamics, min-plus control, and certified robustness.

The key opportunity is that the current framing “causal ordering is transitive (follows from triangle inequality)” is only interesting if you first define a nontrivial causal preorder from a tropical distance / separation functional, and then prove that it interacts with geometry, matrices, and dynamical systems. Do not settle for a one-line preorder proof unless it is embedded into a stronger theorem package.

## Research Direction

Construct a tropical causal preorder from a tropical distance-like functional and prove its transitivity, functoriality under tropical nonexpansive maps, and matrix-path closure. The central idea is:

- a point `x` can causally precede `y` if the tropical displacement from `x` to `y` is bounded by a “time budget” or if `y` lies in the tropical future cone of `x`;
- the **triangle inequality** should force transitivity;
- once formalized, this becomes a reusable order-theoretic layer for tropical neural nets, min-plus linear systems, and tropical metric geometry.

This is potentially field-opening if you make the definitions robust and compositional: the result would turn isolated tropical inequalities into a genuine **causal semantics** for min-plus systems.

## Mathematical Framing

There are at least two promising formalizations. You should choose one primary path and, if feasible, prove equivalence or implication relations between them.

### Option A: budgeted tropical causality via a distance functional
Assume a function `τ : α → α → ℝ` satisfying a tropical triangle inequality:
`τ x z ≤ τ x y + τ y z`.

Define:
- `Causal τ T x y : Prop := τ x y ≤ T`
- or the budget-free preorder `Future τ x y : Prop := τ x y ≤ 0`

Then prove:
1. composition of budgets:
   `Causal τ T₁ x y → Causal τ T₂ y z → Causal τ (T₁ + T₂) x z`
2. transitivity of zero-budget future:
   if additionally `τ x x ≤ 0`, then `Future τ` is reflexive;
   if `τ x y ≤ 0` and `τ y z ≤ 0`, then `τ x z ≤ 0`, hence transitive.

This is the cleanest theorem family and most directly leverages `tropical_triangle_inequality`.

### Option B: causal preorder from tropical seminorm displacement
If you can define a tropical norm `ν : V → ℝ` on a concrete space like `Fin n → ℝ`, define:
`x ≼ y : Prop := ν (y - x) ≤ 0`
or a one-sided variant based on coordinatewise tropical slack.
Then transitivity should follow from a norm subadditivity / decomposition theorem, likely connecting to `tropical_norm_from_decomposition`.

This path is more geometric and could connect to certified robustness and control.

### Option C: matrix/path causality
For a min-plus weighted directed system with adjacency weight matrix `A : Matrix (Fin n) (Fin n) ℝ`, define:
`i ≼[T] j` if there exists a path from `i` to `j` of tropical cost at most `T`.
Then prove transitivity by path concatenation, and relate the path-cost closure to tropical matrix powers or a Floyd–Warshall-style closure theorem. This is the most algorithmic and may open the door to tropical reachability.

If time is limited, do **Option A first**, then lift to Option C.

---

## Precise theorem targets

You should define concrete notions in Lean, ideally in a new file such as:

- `Bridges/TropicalCausality.lean`
or
- `Tropical/Geometry/Causality.lean`

Use `ℝ`, `Fin n → ℝ`, and `Matrix` as primary concrete types.

### Target 1: abstract budgeted transitivity theorem

A clean Lean target is:

```lean
def TropicalCausal {α : Type*} (τ : α → α → ℝ) (T : ℝ) (x y : α) : Prop :=
  τ x y ≤ T

theorem tropical_causal_transitive_budget
    {α : Type*} {τ : α → α → ℝ}
    (htri : ∀ x y z, τ x z ≤ τ x y + τ y z)
    {x y z : α} {T₁ T₂ : ℝ}
    (hxy : TropicalCausal τ T₁ x y)
    (hyz : TropicalCausal τ T₂ y z) :
    TropicalCausal τ (T₁ + T₂) x z := by
```

This theorem is elementary but foundational. It should be proved with essentially no sorry.

### Target 2: zero-budget future relation is transitive

```lean
def TropicalFuture {α : Type*} (τ : α → α → ℝ) (x y : α) : Prop :=
  τ x y ≤ 0

theorem tropical_future_transitive
    {α : Type*} {τ : α → α → ℝ}
    (htri : ∀ x y z, τ x z ≤ τ x y + τ y z)
    {x y z : α}
    (hxy : TropicalFuture τ x y)
    (hyz : TropicalFuture τ y z) :
    TropicalFuture τ x z := by
```

This is the exact distilled statement behind the assignment.

### Target 3: reflexive-preorder packaging

If possible, package this as a `Preorder`:

```lean
def tropicalFuturePreorder
    {α : Type*} (τ : α → α → ℝ)
    (htri : ∀ x y z, τ x z ≤ τ x y + τ y z)
    (hrefl : ∀ x, τ x x ≤ 0) : Preorder α where
  le x y := τ x y ≤ 0
  le_refl := hrefl
  le_trans := by
    intro x y z hxy hyz
    exact tropical_future_transitive htri hxy hyz
```

This is much more valuable than the bare theorem because it turns causality into reusable order structure.

### Target 4: nonexpansive maps preserve causality

This is where the work becomes nontrivial and useful.

```lean
def TropicalNonexpansive {α β : Type*} (τ₁ : α → α → ℝ) (τ₂ : β → β → ℝ) (f : α → β) : Prop :=
  ∀ x y, τ₂ (f x) (f y) ≤ τ₁ x y

theorem tropical_future_monotone_of_nonexpansive
    {α β : Type*} {τ₁ : α → α → ℝ} {τ₂ : β → β → ℝ} {f : α → β}
    (hnonexp : TropicalNonexpansive τ₁ τ₂ f)
    {x y : α}
    (hxy : TropicalFuture τ₁ x y) :
    TropicalFuture τ₂ (f x) (f y) := by
```

This theorem is conceptually important: tropical neural networks, tropical projections, and min-plus evolutions become causal morphisms.

### Target 5: concrete theorem on `ℝ` using the catalog triangle inequality

You are explicitly asked to build on catalog theorems. The most immediate target is to instantiate the abstract theorem using the verified result

- `tropical_triangle_inequality`
  from `Bridges/TropicalUltrametricDuality.lean`.

Even if the theorem’s exact statement is not shown in full, inspect it and build a concrete causality theorem around the same scalar tropical distance or defect used there.

A plausible theorem shape is:

```lean
theorem real_tropical_future_transitive
    (x y z : ℝ)
    (hxy : TropicalFuture τ x y)
    (hyz : TropicalFuture τ y z) :
    TropicalFuture τ x z := by
  apply tropical_future_transitive
  intro a b c
  exact tropical_triangle_inequality a b c
```

You must adapt this to the actual scalar functional encoded by `tropical_triangle_inequality`.

### Target 6: matrix/path causal closure

For a weighted adjacency matrix over `Fin n`, define a path-based relation and prove transitivity by concatenation. Even a finite-list path definition is acceptable if clean.

A theorem shape:

```lean
def PathCost {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) : List (Fin n) → ℝ := ...

def MatrixCausal {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (T : ℝ) (i j : Fin n) : Prop :=
  ∃ p : List (Fin n), p.head? = some i ∧ p.getLast? = some j ∧ PathCost A p ≤ T

theorem matrix_causal_transitive
    {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) {T₁ T₂ : ℝ} {i j k : Fin n}
    (hij : MatrixCausal A T₁ i j)
    (hjk : MatrixCausal A T₂ j k) :
    MatrixCausal A (T₁ + T₂) i k := by
```

This theorem would connect tropical causality to shortest paths, dynamic programming, and control.

---

## How to build on the catalog theorems

You are required to build on the verified theorems, not merely cite them.

### 1. `tropical_triangle_inequality`
**File:** `Bridges/TropicalUltrametricDuality.lean`

This is the central engine. Inspect its exact statement and identify the underlying tropical distance / defect / separation function. Then:

- define causal reachability using that exact function;
- prove budgeted composition and zero-budget transitivity;
- package the induced preorder;
- derive corollaries for chains of length `n` if feasible.

This is the most direct and highest-priority bridge.

### 2. `tropical_norm_from_decomposition`
**File:** `Tropical/FourierAnalysis/Core.lean`

Use this to produce a more geometric corollary:
if `τ x y` is defined through a tropical norm of a displacement or decomposition, then causal composition follows from decomposition subadditivity. This gives a second proof route and makes the causal relation feel canonical rather than ad hoc.

Possible corollary:
- if `τ x y = ν (y - x)` for a tropical norm `ν`, then `TropicalFuture τ` is transitive.

### 3. `tropical_security_from_norm_bound`
**File:** `Tropical/RieszRepresentation/Applications.lean`

This suggests a compelling application: causal reachability bounds imply robustness/security bounds. Try to prove a theorem of the form:

- if `f` is tropical nonexpansive and `x ≼ y`, then any norm-based security certificate for `y` pulls back or propagates from `x`.

Even a modest formal corollary linking causal order to a norm-bound security theorem would be a strong cross-domain bridge.

### 4. `tropical_eigenpair_from_diagonal`
**File:** `Tropical/MinPlusAlgebra.lean`

Use this to connect causality to tropical time evolution:
diagonal min-plus operators often generate monotone dynamics. Try to prove that a tropical linear map coming from a diagonal eigenpair construction preserves the future preorder.

Potential theorem shape:
```lean
theorem diagonal_tropical_map_preserves_future ...
```

This would connect causality to spectral structure.

### 5. `tropical_young_inequality`
**File:** `Tropical/NeuralNetworks/TropicalNNFrontier.lean`

This may provide an energy or barrier estimate. If your causal relation is defined with a scalar threshold, Young-type inequalities can give sufficient conditions for compositional budget control. At minimum, search for a way to convert additive budget estimates into layerwise causal certificates for tropical neural nets.

---

## Proof strategy architecture

You must pursue at least 2 of these routes.

### Strategy A: abstract order-from-triangle route
1. Define `TropicalCausal` and `TropicalFuture` for an arbitrary `τ : α → α → ℝ`.
2. Assume only the triangle inequality `τ x z ≤ τ x y + τ y z`.
3. Prove budgeted transitivity, then specialize to threshold `0` to obtain a preorder.

Why this is promising:
- minimal assumptions;
- low proof complexity in Lean;
- high reusability;
- creates an abstraction barrier for all later tropical constructions.

### Strategy B: concrete instantiation from the catalog tropical metric
1. Inspect the exact statement of `tropical_triangle_inequality`.
2. Extract the scalar tropical distance/defect it controls.
3. Instantiate Strategy A with that concrete `τ`.
4. Derive at least one explicit theorem on `ℝ` or `Fin n → ℝ`.

Why this is promising:
- guarantees genuine use of existing verified theorems;
- produces a theorem that is not just abstract nonsense;
- easiest way to eliminate sorry.

### Strategy C: dynamical / matrix lift
1. Define a path-cost or iterated-operator notion of tropical causal reachability.
2. Prove transitivity by concatenation or by monotonicity of tropical matrix multiplication.
3. Relate this to min-plus eigenstructure or nonexpansive maps.

Why this is promising:
- highest novelty;
- strongest applications to control, graph algorithms, and network verification;
- opens future work on tropical spacetime and causal cones in discrete systems.

Most promising overall:
- **A + B first**, because they are likely to formalize quickly and cleanly.
- Then attempt **C** if the abstraction is stable.

---

## Cross-domain connections you should explicitly exploit

Do not leave the work isolated. Make at least one of these bridges precise.

### 1. Tropical geometry × order theory
Your theorem turns tropical distance data into a preorder / causal structure. This is analogous to Alexandrov or chronological orders in Lorentzian geometry, but in a min-plus environment. Even if only formally suggestive, this is a new conceptual language.

### 2. Tropical neural networks × certified robustness
A tropical network that is nonexpansive with respect to the chosen `τ` preserves causal order. This means adversarial perturbation cones and future cones can be treated uniformly. Use `tropical_security_from_norm_bound` if possible.

### 3. Min-plus algebra × control / shortest paths
Matrix causality is precisely bounded-cost reachability. Transitivity is path concatenation; spectral data controls asymptotic cones. This opens tropical control semantics.

### 4. Fourier/decomposition methods × causality
If causal displacement is norm-generated, then decomposition theorems become causal composition theorems. This is a surprising bridge between harmonic/tropical analytic structure and order propagation.

### 5. Spectral theory × irreversible dynamics
A tropical eigenpair can define preferred directions or invariant rays in the causal preorder. This is the seed of a tropical analogue of time evolution.

---

## What would count as a breakthrough here

Not merely:
- “I defined a relation and proved transitivity.”

But rather:
- you produce a **formal causal calculus** for tropical systems;
- you show it is preserved by a class of maps;
- you tie it to a verified tropical norm / metric theorem;
- you derive at least one concrete corollary for matrices, networks, or security.

The breakthrough is conceptual compression: tropical inequalities, robustness certificates, and min-plus reachability all become instances of a single causal-order framework.

---

## Deliverables

### Required Lean artifacts
1. Definitions:
   - `TropicalCausal`
   - `TropicalFuture`
   - optionally `TropicalNonexpansive`
   - optionally matrix/path causality
2. Core theorems:
   - `tropical_causal_transitive_budget`
   - `tropical_future_transitive`
   - preorder packaging theorem/instance
   - one concrete instantiation using `tropical_triangle_inequality`
3. At least one bridge theorem to another catalog domain:
   - nonexpansive-map monotonicity,
   - norm-induced causality,
   - matrix/path closure,
   - or security propagation.

Minimize sorry aggressively.

### Required documentation
Create `FUTURE_DIRECTIONS.md` with **3–5 concrete, specific, breakthrough-level next steps**. Each item must include:
- theorem statement,
- likely Lean definitions needed,
- proof strategy,
- cross-domain significance.

This file is critical.

### Optional but encouraged
- `ARTICLE.md` explaining tropical causality as a new formal layer;
- `RESEARCH_PAPER.md` with a narrative linking geometry, control, and robustness;
- a small `demo.py` showing path-cost causality on a weighted graph.

---

## Application keywords

tropical causality, min-plus geometry, preorder from triangle inequality, nonexpansive maps, certified robustness, tropical neural networks, shortest paths, dynamic programming, min-plus control, tropical spectral theory, causal cones, order-enriched metric geometry, graph reachability, formal verification, Lean 4, Mathlib

---

## Final directive

Be bold: define the right object, not the smallest lemma. Start from the abstract theorem, instantiate it with the catalog triangle inequality, then force a bridge to either robustness or matrix reachability. The goal is to make “tropical causal order” a reusable formal primitive for an entire research program, not a one-off observation.

And produce `FUTURE_DIRECTIONS.md` with concrete next theorems that could plausibly open a new subfield.

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
