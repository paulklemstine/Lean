Soli Deo Gloria

## Assignment: Direction 4: Extension to Potts Models and Determinantal Spin Systems

**Mode:** `prove`

Build a new formal theory that pushes the Lorentzian robustness program from binary spin systems to genuinely multistate statistical mechanics, and then open a second front by connecting this framework to determinantal interaction systems. Do not produce a minor variant of Ising. Produce a theorem package that makes it plausible that “Lorentzian stability” is a structural principle for discrete probabilistic physics.

You should build explicitly on:

- `Catalog/Pythagorean/LorentzianSharpStability.lean`
- `Catalog/Speculative/AutoResearch/LorentzianStability.lean`

Use those files not merely as inspiration but as **infrastructure**: identify the exact quadratic-form estimates, spectral-gap lemmas, and log-Lipschitz arguments already available there, and lift them to the Potts setting by replacing scalar spin encodings with simplex-valued state embeddings and replacing matrix couplings with block/tensor interaction data.

The target is not just “formalize the 3-state Potts partition function.” The target is to prove that **robustness of partition functions is controlled by a geometric gap condition that survives passage from Ising to Potts and plausibly to determinantal systems.**

---

## Core Vision

For the Ising model, robustness emerges because the partition function is governed by a structured polynomial/exponential sum whose logarithm is stable under perturbations when the interaction form has a Lorentzian-type gap. For the Potts model, the correct replacement is not a naive scalar spin variable but a **one-hot / simplex embedding** of q states. This turns pairwise Potts interactions into block quadratic forms, and the partition function becomes a generating function over q-state occupancy data. The breakthrough is to show that the same stability mechanism survives in this higher-rank setting.

Then go one conceptual step further: determinantal spin systems encode repulsion through minors and kernels rather than ferromagnetic couplings. If a parallel log-stability statement can be isolated there, this would suggest a unifying theory of **robustness from hyperbolicity/Lorentzianity/negative dependence** across statistical mechanics.

This is the kind of result that could open a new field: **certified robustness theory for multistate discrete physics**.

---

## Required New Definitions

You must introduce at least one genuinely new definition not already present in the catalog. Suggested definitions:

1. **Simplex spin embedding**
   - Encode each Potts state `a : Fin q` as a vector in `EuclideanSpace ℝ (Fin q)` or as an indicator function `Fin q → ℝ`.
   - Prefer a centered embedding to isolate the nontrivial `(q-1)`-dimensional fluctuation space.

2. **Potts interaction form**
   - A block interaction object assigning a real weight to `(i,a),(j,b)` pairs, or equivalently a bilinear form on site-state functions.
   - This should specialize to standard Potts couplings when only equal-state interactions matter.

3. **Multilinear signature gap / Potts-Lorentzian gap**
   - A condition asserting coercivity or one-positive-direction behavior on the centered subspace.
   - This is the conceptual heart of the project.

4. Optionally: **Determinantal spin kernel**
   - A finite kernel whose principal minors define configuration weights, together with a perturbation norm.

---

## Precise Formalization Targets

### A. Potts partition function and perturbation theory

Work with a finite site type `α` and a state count `q : ℕ` with `hq : 2 ≤ q`. Let `n = Fintype.card α`.

A clean formal target is to define:

```lean
def PottsConfig (α : Type _) (q : ℕ) [Fintype α] : Type := α → Fin q

def pottsEnergy
  {α : Type _} [Fintype α]
  (q : ℕ)
  (β : ℝ)
  (J : α → α → ℝ)
  (σ : PottsConfig α q) : ℝ :=
β * ∑ i, ∑ j, if σ i = σ j then J i j else 0

def pottsPartition
  {α : Type _} [Fintype α]
  (q : ℕ)
  (β : ℝ)
  (J : α → α → ℝ) : ℝ :=
∑ σ : PottsConfig α q, Real.exp (pottsEnergy q β J σ)
```

You may prefer a half-sum or off-diagonal convention to avoid double-counting; that is fine, but state it clearly and keep all theorems aligned to that normalization.

### B. Main theorem: Lipschitz stability under coupling perturbation

Prove a theorem of the following shape:

```lean
theorem log_pottsPartition_lipschitz
  {α : Type _} [Fintype α] [DecidableEq α]
  {q : ℕ} (hq : 2 ≤ q)
  (β : ℝ) (J K : α → α → ℝ) :
  |Real.log (pottsPartition q β J) - Real.log (pottsPartition q β K)|
    ≤ |β| * (Fintype.card α)^2 * ‖J - K‖∞
```

You will need to formalize `‖J - K‖∞` appropriately, likely as a finite sup norm over `α × α`. If the exact constant is difficult, prove a sharp theorem with a clean explicit constant `C(q,n,β)` and then derive the heuristic bound
`β n² (q-1) δ`
or a mathematically justified variant.

This theorem is important because it is already nontrivial, uses real analysis and finite combinatorics, and gives a certified perturbation bound for multistate systems.

### C. Refined theorem using centered simplex geometry

The true breakthrough theorem should not merely be a counting-based Lipschitz estimate. Prove a stronger statement showing that the effective perturbation constant is governed by the centered `(q-1)`-dimensional fluctuation space.

Suggested statement:

```lean
theorem log_pottsPartition_centered_bound
  {α : Type _} [Fintype α] [DecidableEq α]
  {q : ℕ} (hq : 2 ≤ q)
  (β : ℝ)
  (J K : α → α → ℝ)
  (hcenteredGap : PottsCenteredGap q J K) :
  |Real.log (pottsPartition q β J) - Real.log (pottsPartition q β K)|
    ≤ |β| * (q - 1) * (Fintype.card α)^2 * centeredPerturbationNorm J K
```

Here `PottsCenteredGap` and `centeredPerturbationNorm` are your new definitions. The exact form is up to you, but the theorem must encode the conceptual insight that only the nonconstant state fluctuations matter. This is where you should leverage the quadratic-form machinery from the Lorentzian catalog files.

### D. Cross-domain theorem: graph coloring / computer vision bridge

The antiferromagnetic Potts model is a soft graph-coloring model; in image segmentation it is a smoothness prior. Prove a theorem making one of these bridges mathematically explicit.

For example, if `J` is supported on edges of a finite graph and `β < 0`, prove monotonic suppression of monochromatic edges:

```lean
theorem antiferro_potts_monochromatic_penalty
  {α : Type _} [Fintype α] [DecidableEq α]
  {q : ℕ} (hq : 2 ≤ q)
  (G : SimpleGraph α)
  (β : ℝ) (hβ : β < 0) :
  -- a precise inequality comparing partition functions or expected edge agreement
  ...
```

Or prove a clean comparison theorem relating the zero-temperature limit to proper q-colorings:

```lean
theorem potts_zero_temperature_coloring_limit
  {α : Type _} [Fintype α] [DecidableEq α]
  (G : SimpleGraph α)
  {q : ℕ} (hq : 2 ≤ q) :
  Filter.Tendsto
    (fun β : ℝ => scaledPottsPartition G q β)
    Filter.atBot
    (nhds (numProperColorings G q))
```

If the full limit is too heavy, prove a finite inequality that clearly exhibits the graph-coloring connection. This satisfies the required cross-domain bridge: **statistical mechanics ↔ graph theory / computer vision**.

### E. Determinantal spin-system theorem

Introduce a finite determinantal configuration model on a finite type `α`, with weights proportional to principal minors of a positive semidefinite kernel `L`. Then prove a perturbation inequality for the log normalizer.

A plausible formal target:

```lean
def detSpinPartition
  {α : Type _} [Fintype α] [DecidableEq α]
  (L : Matrix α α ℝ) : ℝ := ...

theorem log_detSpinPartition_lipschitz
  {α : Type _} [Fintype α] [DecidableEq α]
  (L M : Matrix α α ℝ)
  (hL : IsSymm L) (hM : IsSymm M)
  (hpsdL : 0 ≤ L) (hpsdM : 0 ≤ M) :
  |Real.log (detSpinPartition L) - Real.log (detSpinPartition M)|
    ≤ C α L M * ‖L - M‖
```

If the full PSD/matrix-order apparatus becomes too large, restrict to diagonalizable or finite explicit kernels and prove a meaningful finite-dimensional theorem. The point is to establish a **second robustness mechanism** beyond Potts, showing this is not a one-model phenomenon.

---

## Three Theorems Minimum — with Deep Proof Tactics

Your file must contain at least 3 substantial theorems, and they must use genuine proof architecture: induction, `rcases`, `by_contra`, `field_simp`, multi-step `calc`, decomposition into cases, and nontrivial inequalities. Avoid proofs that collapse to computation.

A recommended theorem set:

1. **Configuration energy perturbation bound**
   - For every configuration `σ`, bound `|pottsEnergy q β J σ - pottsEnergy q β K σ|`.
   - This should use finite-sum estimates and a nontrivial norm bound.
   - Good place for `calc`, `Finset.sum_le_sum`, and case splits.

2. **Partition-function log-Lipschitz theorem**
   - Derive from the previous theorem using exponential monotonicity and sum comparison.
   - Good place for `by_contra`, monotonicity of `Real.exp`, and log inequalities.

3. **Centered-gap refinement**
   - Use the centered simplex embedding and imported Lorentzian quadratic-form bounds.
   - Good place for `rcases` on the decomposition into constant and centered subspaces.

4. **Cross-domain theorem**
   - Graph-coloring / segmentation / community detection theorem.

5. **Determinantal theorem**
   - Even a restricted but nontrivial finite-kernel version counts, provided the proof is substantive.

At least 3 of these must be fully proved.

---

## Lean 4 Type Signatures to Aim For

These are suggested signatures; adapt only if necessary for Mathlib compatibility.

```lean
def PottsConfig (α : Type _) (q : ℕ) [Fintype α] : Type := α → Fin q

def pottsEnergy
  {α : Type _} [Fintype α]
  (q : ℕ) (β : ℝ) (J : α → α → ℝ) (σ : PottsConfig α q) : ℝ

def pottsPartition
  {α : Type _} [Fintype α]
  (q : ℕ) (β : ℝ) (J : α → α → ℝ) : ℝ

def centeredStateVec (q : ℕ) (a : Fin q) : Fin q → ℝ

def PottsCenteredGap
  {α : Type _} [Fintype α]
  (q : ℕ) (J K : α → α → ℝ) : Prop

def centeredPerturbationNorm
  {α : Type _} [Fintype α]
  (J K : α → α → ℝ) : ℝ

theorem pottsEnergy_perturbation_bound
  {α : Type _} [Fintype α] [DecidableEq α]
  {q : ℕ} (β : ℝ) (J K : α → α → ℝ) (σ : PottsConfig α q) :
  |pottsEnergy q β J σ - pottsEnergy q β K σ|
    ≤ |β| * (Fintype.card α)^2 * ‖J - K‖∞

theorem pottsPartition_pos
  {α : Type _} [Fintype α]
  (q : ℕ) (β : ℝ) (J : α → α → ℝ) :
  0 < pottsPartition q β J

theorem log_pottsPartition_lipschitz
  {α : Type _} [Fintype α] [DecidableEq α]
  {q : ℕ} (hq : 2 ≤ q)
  (β : ℝ) (J K : α → α → ℝ) :
  |Real.log (pottsPartition q β J) - Real.log (pottsPartition q β K)|
    ≤ |β| * (Fintype.card α)^2 * ‖J - K‖∞

theorem log_pottsPartition_centered_bound
  {α : Type _} [Fintype α] [DecidableEq α]
  {q : ℕ} (hq : 2 ≤ q)
  (β : ℝ) (J K : α → α → ℝ)
  (hgap : PottsCenteredGap q J K) :
  |Real.log (pottsPartition q β J) - Real.log (pottsPartition q β K)|
    ≤ |β| * (q - 1) * (Fintype.card α)^2 * centeredPerturbationNorm J K
```

For determinantal systems:

```lean
def detSpinPartition
  {α : Type _} [Fintype α] [DecidableEq α]
  (L : Matrix α α ℝ) : ℝ

theorem detSpinPartition_pos
  {α : Type _} [Fintype α] [DecidableEq α]
  (L : Matrix α α ℝ) :
  0 < detSpinPartition L

theorem log_detSpinPartition_lipschitz
  {α : Type _} [Fintype α] [DecidableEq α]
  (L M : Matrix α α ℝ) :
  |Real.log (detSpinPartition L) - Real.log (detSpinPartition M)|
    ≤ detPerturbationConstant L M * ‖L - M‖
```

---

## Proof Strategy Architecture

### Strategy A: Direct finite-energy perturbation route
Most promising for the first main theorem.

1. **Configurationwise control**
   - For each `σ`, show the energy difference is bounded by summing the pointwise coupling perturbation over all site pairs.
   - This is robust and elementary, and should give a theorem immediately.

2. **Exponential sandwich**
   - Deduce
     `exp (-C) * Z(K) ≤ Z(J) ≤ exp (C) * Z(K)`.
   - Then pass to logarithms using positivity of partition functions.

3. **Refine constants**
   - Improve the crude `n²` factor using symmetry, zero diagonal, or centered embeddings where possible.

Why this is promising: it gives a complete theorem with modest infrastructure and produces a verified computational bound that can be tested immediately.

### Strategy B: Centered simplex / Lorentzian quadratic-form lift
Most promising for the breakthrough theorem.

1. **Embed states into the centered simplex**
   - Replace each Potts spin by a vector in the hyperplane `∑ a x_a = 0`.
   - Rewrite equal-state interactions as a constant term plus an inner-product term on the centered space.

2. **Transfer the catalog machinery**
   - Identify the exact quadratic-form estimate in `LorentzianSharpStability.lean`.
   - Show the Potts interaction decomposes into a form to which the Lorentzian stability lemmas apply on the `(q-1)`-dimensional fluctuation sector.

3. **Derive a sharpened log-stability bound**
   - The key gain should be the replacement of naive `q`-dimensional counting by a `(q-1)`-dimensional geometric constant.

Why this is the most revolutionary: it extracts the **correct geometry** of Potts fluctuations and ties multistate statistical mechanics to Lorentzian polynomial theory.

### Strategy C: Determinantal analogy via principal-minor generating functions
Most speculative, but potentially field-opening.

1. **Define a finite determinantal partition function**
   - Sum weights over subsets using principal minors or determinant-based configuration weights.

2. **Use multilinear determinant identities**
   - Bound change in the partition function under kernel perturbations by controlling principal minors or traces.

3. **Compare robustness mechanisms**
   - Isolate a common pattern: log-normalizer stability under structured positivity/negative dependence.

Why this matters: if successful, it suggests that robustness is not specific to ferromagnetic models but is a property of broad classes of structured probabilistic systems.

---

## Cross-Domain Connections You Must Surface

At least one theorem and the paper narrative must explicitly connect this work to another domain.

1. **Computer vision**
   - Potts energies are foundational in image segmentation and Markov random fields.
   - Your stability theorem becomes a certified guarantee that segmentation energies are insensitive to bounded perturbations in affinity weights.

2. **Community detection / network science**
   - Multistate labels model cluster assignments.
   - Perturbation bounds imply robustness of soft partition statistics under noisy graph weights.

3. **Graph coloring / combinatorics**
   - Antiferromagnetic Potts models interpolate toward proper colorings.
   - This ties robustness of partition functions to counting and extremal combinatorics.

4. **Protein folding / biological sequence models**
   - Multistate residues and pairwise couplings naturally fit Potts models.
   - Stability bounds speak to parameter uncertainty in inverse statistical models.

5. **Determinantal processes / random matrix theory**
   - Determinantal systems model repulsion and diversity.
   - A common perturbation theory would bridge positive-correlation and negative-correlation worlds.

---

## Conjecture with Testable Prediction

State at least one falsifiable conjecture and implement a computational test that could refute it.

### Conjecture 1: Sharp Potts scaling
For finite systems with `n = |α|` and `q ≥ 2`, the optimal first-order perturbation constant for the log partition function under sup-norm coupling perturbations scales as
`|β| (q - 1) n²`
after centering, not `|β| q n²`.

This is falsifiable: for `q = 3`, `n ≤ 6`, enumerate all configurations, perturb couplings randomly, and compare
`|log Z(J) - log Z(K)| / ‖J-K‖∞`
against the proposed bound.

### Conjecture 2: Determinantal robustness analogue
For PSD kernels with spectrum uniformly bounded away from `-1`, the log normalizer of the determinantal spin partition function is globally Lipschitz in operator norm with constant controlled by a trace-resolvent quantity.

This is falsifiable by explicit matrix experiments for sizes `n ≤ 8`.

Your `demo.py` must include experiments designed to potentially **disprove** these conjectures, not merely illustrate them.

---

## Algorithmic / Computational Deliverable

You must provide a verified computational method, not just theorems.

### Required algorithm
Implement an algorithm that, for a finite Potts model with small `n,q`, computes:

- the exact partition function by enumeration,
- the perturbed partition function,
- the empirical log-ratio,
- the certified upper bound from your theorem.

This should be formalized at least at the level of a mathematically specified algorithm in Lean, with correctness statements for the enumeration or bound computation where feasible.

A suggested Lean-side object:

```lean
def enumeratePottsPartition
  {α : Type _} [Fintype α] [DecidableEq α]
  (q : ℕ) (β : ℝ) (J : α → α → ℝ) : ℝ := ...
```

with a theorem relating it to `pottsPartition`.

Then `demo.py` should:
- generate random symmetric couplings,
- compute exact `Z`,
- perturb by `δ`,
- compare empirical and certified log-Lipschitz bounds,
- test the `β n² (q-1) δ` heuristic,
- optionally compare ferromagnetic and antiferromagnetic regimes,
- optionally run a determinantal-kernel experiment.

---

## What Would Count as a Breakthrough

A successful project would establish, in a mathematically precise and machine-checked form, that:

- multistate Potts partition functions obey explicit perturbation stability bounds;
- these bounds sharpen when one passes to the centered simplex geometry;
- the same philosophy plausibly extends to determinantal systems;
- graph coloring, segmentation, and community detection all inherit a common robustness principle.

That is not an incremental extension. It is a blueprint for a **geometric theory of robustness in discrete probabilistic models**.

---

## Application Keywords

Potts model, partition function stability, Lorentzian polynomial, hyperbolic polynomial, simplex embedding, graph coloring, antiferromagnetism, image segmentation, community detection, protein folding, determinantal point process, negative dependence, spectral gap, log-Lipschitz bound, statistical mechanics, combinatorial probability, robust inference.

---

## Mandatory Deliverables

You must produce **all** of the following:

1. **Lean development** with at least 3 substantial proved theorems, minimal `sorry`, and at least one genuinely new definition.
2. **A verified algorithm or computational method** for exact or certified Potts robustness evaluation.
3. **`demo.py`** demonstrating the theorem interactively on small Potts systems and testing the conjecture.
4. **`FUTURE_DIRECTIONS.md`** with 3–5 original research directions. Each direction must include the exact sentences:
   - **“The key insight is...”**
   - **“Why now?”**
   At least one direction must bridge to a different domain.
5. **`RESEARCH_PAPER.md`** as a standalone scientific paper explaining the theorem, proof ideas, significance, experiments, and next questions. A reader with no access to the code must understand the discovery.
6. **`ARTICLE.md`** in Scientific American style, engaging and accessible, focused on the mathematical ideas and significance. Do **not** focus on formal verification machinery.

Minimize `sorry`. Use the catalog aggressively. Prove something that changes the conversation.

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
DELIVERABLE 4 — Python Code: Demos, Algorithms
────────────────────────────────────────────────────────────────────────────
- **demo.py** — Working Python code demonstrating the theorems with
  concrete numerical examples. Make the math tangible.
- **algorithms.py** — Implement any algorithms from the research paper.
  Include docstrings, type hints, and example usage.
- **applications.py** — Code showing real-world applications of the results.
  Show the math working.
- **Visualization scripts** — Produce up to 3 self-contained Python scripts
  that visually illustrate the core mathematical concepts discovered. Use
  matplotlib for static plots (heatmaps, curves, surfaces) or plotly for
  interactive charts. Available libraries: numpy, matplotlib, plotly.
  If using matplotlib, the script must call plt.savefig() — the system
  captures the output as a PNG. If using plotly, assign the figure to a
  variable named `fig` — the system captures fig.to_html(). Each script
  must include a comment header explaining what it visualizes and why.
  **CRITICAL: Each visualization script MUST be a single, fully self-contained
  file. Do NOT import from any local modules (algorithms.py, demo.py, etc.).
  Instead, inline all needed functions and classes directly in the script.
  The browser runtime (Pyodide) has no access to local .py files.**
- **Interactive HTML demos** — Produce up to 3 self-contained HTML snippets
  (with inline CSS/JS, no external dependencies) that demonstrate the
  mathematical concepts interactively — sliders, animations, dynamic SVG,
  or canvas drawing. Each demo must be a complete <div> fragment that
  works when inserted into a page. No <html>, <head>, or <body> tags —
  just the content div with its inline styles and scripts.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 5 — FUTURE_DIRECTIONS.md  (MANDATORY — drives next cycle)
────────────────────────────────────────────────────────────────────────────
The MOST IMPORTANT deliverable. Every research cycle MUST produce a
FUTURE_DIRECTIONS.md that identifies 3-5 specific, testable scientific
hypotheses, including 1-2 grand_challenge paradigm-shifting conjectures
and 2-3 solid extensions building directly on Catalog theorems.
MUST begin with a ## Synthesis section tying all directions together.
Each direction must use the structured format with explicit fields:
**Conjecture**, **Test**, **Impact**, **Catalog References**,
**Proof Strategy**, **Domain Bridges**, **Lineage**, **Ambition**.
Reference specific Catalog theorems by file path. Every hypothesis
must be daring enough to matter and specific enough to fail.


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
    "visualizations": [ { "name": "...", "code": "# Must be 100% self-contained. Do not import local files. Inline all needed functions directly.", "description": "What this visualizes" } ],
    "interactive_demos": [ { "name": "...", "html": "<div>...</div>", "description": "What this demonstrates" } ],
    "lean_proofs": "Raw lean code..."
  }
• **String Encoding**: Ensure all Markdown and code is properly JSON-escaped (e.g. `
` for newlines).
• **Complete**: Include ALL content from the article, research paper, and code. This JSON file
  is the sole data source for the frontend web application.

────────────────────────────────────────────────────────────────────────────

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real, useful, and
beautiful. Every deliverable should be something you'd be proud to show.

Research domain: Pythagorean
Research mode: prove
