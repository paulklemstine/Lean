Soli Deo Gloria

## Assignment: Direction 3: Complexity-Theoretic Phase Transition for Lorentzian Recognition

**Mode:** `prove` / `discover`

Build a genuine average-case complexity theory for Lorentzian recognition at the spectral edge. Do not merely restate stability results: extract an algorithmic phase transition from the geometric phase transition already visible in the sharp GOE constants. The target is a theorem package that makes the sentence

> “Lorentzianity undergoes a statistical-to-computational transition at the same edge constant that governs random matrix gap formation”

mathematically precise.

Your job is to turn the existing spectral-edge geometry into the first formal blueprint for **average-case hardness and efficient recognition near Lorentzian criticality**.

---

## Core Vision

The breakthrough is to show that Lorentzian recognition is not just a geometric yes/no property under perturbation, but a **computational order parameter**. The same edge constant `2σ` that governs random matrix norm behavior should separate three regimes:

1. **Easy phase:** above the edge, a simple spectral certificate succeeds with overwhelming probability.
2. **Critical phase:** at the edge, certificates still exist, but confidence decays only polynomially.
3. **Hard phase:** below the edge, either every low-degree/spectral algorithm fails, or one can formally reduce a planted detection problem to Lorentzian recognition.

This would open a new field: **algorithmic Lorentzian geometry**, connecting hyperbolic/Hodge-type inequalities to average-case complexity, random matrix theory, and statistical learning.

Application keywords: **average-case complexity, random matrix theory, planted clique, spectral algorithms, low-degree method, Lorentzian polynomials, hyperbolic geometry, statistical-computational gap, robust certification, phase transitions**

---

## Precise Mathematical Program

You should introduce a formal model of noisy Lorentzian recognition and prove at least 3 substantial theorems.

### New definitions to introduce

Define a new concept not already in the catalog: a **spectral recognition instance** and its **algorithmic margin**.

Suggested Lean-facing structures:

```lean
structure LorentzianRecognitionInstance where
  n : ℕ
  signal : Matrix (Fin n) (Fin n) ℝ
  noise : Matrix (Fin n) (Fin n) ℝ
  epsilon : ℝ

def perturbedMatrix (I : LorentzianRecognitionInstance) :
    Matrix (Fin I.n) (Fin I.n) ℝ :=
  I.signal + I.epsilon • I.noise

def algorithmicMargin (A : Matrix (Fin n) (Fin n) ℝ) : ℝ :=
  maxEigenvalue A - secondLargestEigenvalue A
```

If `secondLargestEigenvalue` is too heavy to formalize globally, replace by a certified proxy based on trace / Frobenius norm / Rayleigh quotient gap that is sufficient for the theorems. The key is not notation purity but a formally robust notion of “spectral separability implies recognizability.”

Also define a recognition predicate abstracting the Lorentzian side:

```lean
def SpectrallyRecognizable (A : Matrix (Fin n) (Fin n) ℝ) : Prop :=
  0 < algorithmicMargin A

def HasCriticalWindow (σ ε δ : ℝ) : Prop :=
  |ε - 2 * σ| ≤ δ
```

If `HasGappedSignature` from
`Catalog/Speculative/AutoResearch/LorentzianStability.lean`
already captures the right geometric side, connect your new recognition predicate to it rather than duplicating it.

---

## Primary theorem targets

You do **not** need to solve the full planted-clique hardness conjecture in Lean. But you **must** prove mathematically nontrivial theorems that make the conjectural trichotomy structurally real.

### Theorem 1: Easy-phase spectral certification above the edge

Formalize a theorem of the following shape:

> For every fixed `δ > 0`, if `ε ≥ 2σ + δ` and the perturbation satisfies the catalog’s sharp random-matrix norm control, then the perturbed instance has a positive algorithmic margin; hence Lorentzian recognition is certified by a polynomial-time spectral test.

Suggested Lean signature skeleton:

```lean
theorem easy_phase_spectral_certification
    {n : ℕ} {σ ε δ : ℝ}
    (hδ : 0 < δ)
    (hε : 2 * σ + δ ≤ ε)
    (hgap : HasGappedSignature (perturbedMatrix I))
    (hsharp : ‖I.noise‖ ≤ 2 * σ + δ / 2) :
    SpectrallyRecognizable (perturbedMatrix I)
```

This theorem should explicitly build on:
- `Pythagorean/SharpGOEConstants.lean`
- `Catalog/Speculative/AutoResearch/LorentzianStability.lean`
especially any theorem certifying a signature gap from a norm bound.

**Why this is a breakthrough:** it converts a geometric phase transition into an algorithmic guarantee. That is the first half of a complexity dichotomy.

---

### Theorem 2: Critical-window instability / polynomial-confidence regime

Prove a theorem showing that in the edge window `|ε - 2σ| ≤ δ`, the spectral margin cannot be uniformly bounded below by a positive constant depending only on `δ`; instead, one gets only a scale-sensitive lower bound.

A precise theorem could be:

> In the critical window, any recognition guarantee derived solely from the sharp edge bound degrades to a margin estimate that vanishes with the window width.

Lean skeleton:

```lean
theorem critical_window_margin_bound
    {n : ℕ} {σ ε δ : ℝ}
    (hδ : 0 < δ)
    (hcrit : |ε - 2 * σ| ≤ δ)
    (hsharp : ‖I.noise‖ ≤ 2 * σ + δ) :
    algorithmicMargin (perturbedMatrix I) ≤ C * δ
```

for some explicitly defined constant `C` (possibly depending on dimension if necessary).

A stronger variant is even better:

```lean
theorem no_uniform_gap_in_critical_window
    {σ δ γ : ℝ}
    (hδ : 0 < δ)
    (hγ : 0 < γ)
    :
    ¬ ∀ I : LorentzianRecognitionInstance,
      HasCriticalWindow σ I.epsilon δ →
      SpectrallyRecognizable (perturbedMatrix I) →
      γ ≤ algorithmicMargin (perturbedMatrix I)
```

This is a mathematically deep negation theorem: at criticality, there is no uniform constant-margin certificate. It formalizes “computational criticality” as certificate degeneration.

**Why this matters:** this is the missing middle regime. Without it, one only has easy vs unknown. With it, you identify a bona fide critical window.

---

### Theorem 3: Cross-domain theorem connecting Lorentzian recognition to average-case hypothesis testing

Prove a reduction-style theorem at an abstract level: if one has a robust polynomial-time Lorentzian recognizer in the critical window, then one obtains a polynomial-time distinguisher for a planted perturbation family.

You may formalize this abstractly rather than fully encoding planted clique graphs.

Suggested theorem statement:

> Given two distributions over matrix instances whose means differ by a rank-one planted signal, any recognizer that succeeds with advantage `η` on the induced Lorentzian predicate yields a hypothesis test with the same advantage.

Lean skeleton:

```lean
structure MatrixHypothesisTest (n : ℕ) where
  nullDist : Type
  plantedDist : Type
  encodeNull : nullDist → Matrix (Fin n) (Fin n) ℝ
  encodePlanted : plantedDist → Matrix (Fin n) (Fin n) ℝ

def TestAdvantage {α β : Type} (f : α ⊕ β → Bool) : ℝ := ...

theorem recognizer_yields_tester
    {n : ℕ}
    (H : MatrixHypothesisTest n)
    (R : Matrix (Fin n) (Fin n) ℝ → Bool)
    (hR :
      ∀ x, R (H.encodePlanted x) = true)
    (hN :
      ∀ y, R (H.encodeNull y) = false) :
    ∃ T : H.nullDist ⊕ H.plantedDist → Bool,
      0 < TestAdvantage T
```

Then strengthen this by making `R` arise from `SpectrallyRecognizable` or `HasGappedSignature`.

This is your required **cross-domain theorem**: algebraic/Lorentzian recognition implies a statistical test in average-case complexity. It bridges:
- Lorentzian geometry
- random matrix theory
- computational complexity
- statistical decision theory

**Why this is revolutionary:** it says geometric recognizers can simulate average-case detectors. That is the conceptual bridge needed for future hardness reductions.

---

## Bold conjecture with a falsifiable prediction

State and formalize a conjecture in Lean-style comments and in the paper:

> **Conjecture (Critical hardness for Lorentzian recognition).**
> For every fixed `δ > 0`, there is no polynomial-time algorithm that, on random instances with `ε ≤ 2σ - δ`, recognizes Lorentzianity with success probability `1/2 + c` for any absolute constant `c > 0`, unless planted clique of size `o(√n)` is detectable in polynomial time.

Make the prediction testable:

1. Generate null GOE-like perturbations and planted rank-one perturbations.
2. Run a spectral Lorentzian recognizer.
3. Measure empirical advantage as a function of `ε / σ`.
4. Prediction: success curve exhibits a sharp bend near `2`.

This is falsifiable because if the empirical advantage remains bounded away from `0` far below `2σ`, the conjecture is wrong or the model is mis-specified.

---

## Proof architecture: 3 strategy paths

You must include 2–3 proof approaches and explain which is most promising.

### Strategy A: Direct spectral-gap transport from catalog sharp constants
1. Use `SharpGOEConstants.lean` to obtain a certified operator-norm threshold near `2σ`.
2. Use `HasGappedSignature` to convert norm separation into signature or Lorentzian recognition.
3. Define a computable spectral certificate and prove correctness above the edge.

**Most promising first step.**
This is closest to existing catalog machinery and likely gives a complete formal theorem quickly.

---

### Strategy B: Contrapositive critical-window theorem via gap collapse
1. Assume a uniform positive recognition margin in the critical window.
2. Use `by_contra` and perturbative comparison to build instances whose spectral edge lies within `O(δ)`.
3. Derive contradiction with sharpness of the edge constant or with the catalog’s extremal examples.

This is likely the best route for Theorem 2. It naturally uses `by_contra`, `rcases`, and multi-step `calc`.

---

### Strategy C: Abstract reduction to hypothesis testing / planted detection
1. Define a generic encoding from planted-vs-null instances into matrices.
2. Show that a Lorentzian recognizer composed with the encoding yields a distinguisher.
3. Instantiate with rank-one perturbation families or a simplified spiked-Wigner model.

This is the best route for the cross-domain theorem. It does not require fully formalizing planted clique immediately, yet it captures the exact reduction pattern needed for later field-opening work.

---

## Lean 4 formalization targets

You must include precise theorem statements with Lean signatures as close to executable as possible. If a full spectral library dependency is too heavy, create certified surrogate notions and prove nontrivial implications. The important thing is to formalize **the phase transition logic**, not to get stuck on one missing eigenvalue API.

Recommended theorem targets:

```lean
theorem gapped_signature_of_norm_separation
    {n : ℕ} {A E : Matrix (Fin n) (Fin n) ℝ} {σ δ : ℝ}
    (hδ : 0 < δ)
    (hE : ‖E‖ ≤ 2 * σ + δ)
    (hA : HasGappedSignature A) :
    HasGappedSignature (A + E)
```

```lean
theorem recognizable_of_gapped_signature
    {n : ℕ} {A : Matrix (Fin n) (Fin n) ℝ} :
    HasGappedSignature A → SpectrallyRecognizable A
```

```lean
theorem critical_window_forces_small_margin
    {n : ℕ} {A E : Matrix (Fin n) (Fin n) ℝ} {σ δ : ℝ}
    (hδ : 0 < δ)
    (hcrit : ‖E‖ ≤ 2 * σ + δ)
    (hedge : 2 * σ - δ ≤ ‖E‖) :
    algorithmicMargin (A + E) ≤ C * δ
```

```lean
theorem recognizer_induces_average_case_test
    {n : ℕ}
    (H : MatrixHypothesisTest n)
    (R : Matrix (Fin n) (Fin n) ℝ → Bool)
    (hsep :
      (∀ x, R (H.encodePlanted x) = true) ∧
      (∀ y, R (H.encodeNull y) = false)) :
    ∃ T, 0 < TestAdvantage T
```

If needed, replace `‖E‖` by a finite-dimensional proxy already available in Mathlib, such as Frobenius norm, and prove the relevant inequalities.

---

## Required deep-proof style

Your file must contain at least 3 theorems with substantive proofs using several of:
- `induction`
- `rcases`
- `by_contra`
- `field_simp`
- `nlinarith`
- `linarith`
- multi-step `calc`
- nontrivial rewriting with inequalities
- decomposition of cases in the critical window

Do not hide the mathematics behind automation. The point is to exhibit proof architecture.

Suggested places:
- proving monotonicity of your margin proxy,
- proving critical-window impossibility by contradiction,
- proving composition of recognizers with hypothesis tests,
- proving norm/gap inequalities by chained estimates.

---

## Catalog building blocks to exploit

### 1. `Pythagorean/SharpGOEConstants.lean`
Use this as the source of the edge constant `2σ` and any theorem certifying sharp norm concentration or phase transition. You are not allowed to mention it vaguely; explicitly import and invoke its final theorems as the source of the spectral threshold.

### 2. `Catalog/Speculative/AutoResearch/LorentzianStability.lean`
Use `HasGappedSignature` as the geometric predicate that survives perturbation. Your mission is to turn this into an algorithmic recognition criterion.

### 3. Any Mathlib linear algebra / matrix norm / finite-dimensional spectral facts
Even if full eigenvalue ordering is cumbersome, use:
- symmetric matrices,
- Rayleigh quotient bounds,
- operator/Frobenius norm comparison,
- trace identities,
- rank-one perturbation formulas if available.

---

## Cross-domain connections you must emphasize

1. **Average-case complexity:** Lorentzian recognition as a decision problem with a sharp noise threshold.
2. **Random matrix theory:** the constant `2σ` is not decorative; it is the algorithmic edge.
3. **Statistical learning theory:** recognition confidence behaves like a margin; criticality means low-confidence classification.
4. **Algebraic geometry / combinatorics:** Lorentzian structures encode deep log-concavity and Hodge-type inequalities.
5. **Physics:** interpret the edge as a computational analogue of a second-order phase transition, with susceptibility = inverse margin.

At least one theorem in the Lean file must concretely connect two of these domains.

---

## Concrete deliverables

You must produce **all** of the following:

### 1. Lean development
A new file formalizing the definitions and proving at least 3 nontrivial theorems.

### 2. Verified algorithm / computational method
Implement a certified spectral recognizer or margin estimator:
- input: matrix instance and parameters `(σ, ε, δ)`
- output: certificate `easy / critical / unresolved`
- prove a correctness theorem for the `easy` output

This is mandatory. Not just theorem statements.

### 3. `demo.py`
An interactive script that:
- samples random symmetric noise,
- adds planted/rank-one signal options,
- computes empirical spectral gaps,
- visualizes success vs `ε / σ`,
- highlights the predicted bend near `2`.

### 4. `RESEARCH_PAPER.md`
A standalone scientific document containing:
- problem definition,
- exact theorem statements,
- proof ideas,
- why the phase transition is new,
- experiments,
- limitations,
- next conjectures.

Someone reading only this paper must understand the discovery without seeing code.

### 5. `ARTICLE.md`
Write in Scientific American style.
Explain:
- what Lorentzian recognition is in intuitive terms,
- why a random matrix constant can govern computational difficulty,
- why this hints at a new science of geometric phase transitions.

**Taboo:** do not focus on formal verification machinery.

### 6. `FUTURE_DIRECTIONS.md`
Include 3–5 original research directions.
Each direction must include the exact sentences:
- **“The key insight is...”**
- **“Why now?”**

At least one direction must bridge to a different domain, such as:
- low-degree polynomial hardness,
- spiked tensor models,
- tropical geometry,
- statistical physics,
- quantum information.

---

## Suggested file themes

A strong file could be organized around:

1. `LorentzianRecognitionInstance`
2. `algorithmicMargin`
3. `SpectrallyRecognizable`
4. easy-phase certification theorem
5. critical-window small-margin theorem
6. recognizer-to-tester reduction theorem
7. verified classifier algorithm

This would already constitute a field-opening seed.

---

## Standard of ambition

Do not settle for “there exists a threshold-like phenomenon.” Prove theorems that isolate:
- a concrete easy regime,
- a concrete critical obstruction,
- a concrete reduction bridge to average-case testing.

If you can do this cleanly, you will have created the first formal skeleton of a theory in which **Lorentzian geometry has computational universality at random matrix criticality**. That is not an incremental extension. That is a new program.

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
