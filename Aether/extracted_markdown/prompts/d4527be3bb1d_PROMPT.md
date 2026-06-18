## Assignment: Direction 1: Double Scaling Limit — When Does m Matter?

**Mode:** prove

Prove genuinely new theorems about the **double-scaling asymptotics** of the wreath-product subgroup-growth pressure, isolating the threshold at which the base multiplicity parameter `m` ceases to be perturbative and becomes a new relevant scaling variable.

This should not be treated as a cosmetic extension of existing perturbation bounds. The target is a **renormalization-style phase diagram** for subgroup-pressure asymptotics of `S_k ≀ S_m`, with a mathematically precise notion of relevance/irrelevance of the wreath perturbation. If successful, this opens a new field-level bridge between **finite group asymptotics**, **statistical mechanics**, and **universality theory**.

You must build directly on:

- `Pythagorean/WreathPerturbation.lean`
  - `beta_wreath_eq_mul_beta_symm_plus_error`
  - `defect_ratio_tendsto_zero`
- `Catalog/Bridges/Catalog/Pythagorean/SubgroupUniversality.lean`
  - `pressure_directPower_linear`

The conceptual goal is to identify a scaling law `m*(k)` and prove theorems showing three regimes:

1. **Irrelevant regime:** `m ≪ m*(k)` implies wreath effects vanish after rescaling.
2. **Marginal regime:** `m ≍ m*(k)` yields a nontrivial crossover profile.
3. **Relevant regime:** `m ≫ m*(k)` forces a new asymptotic law, i.e. a genuine universality-class change.

This is the finite-group analog of identifying the **upper critical dimension** in statistical mechanics.

---

## Core mathematical program

Introduce a new asymptotic observable that measures deviation from direct-power linearity:

- the **wreath defect**
  \[
  \Delta(k,m) := \beta_W(k,m) - m\,\beta(S_k),
  \]
- and the **rescaled defect**
  \[
  \mathcal R_\alpha(k,m) := \frac{\Delta(k,m)}{m/k^\alpha}
  \quad\text{or equivalently}\quad
  \widetilde{\mathcal R}_\alpha(k,m) := \frac{k^\alpha}{m}\,\Delta(k,m),
  \]
  depending on which normalization interacts best with catalog bounds.

You should define at least one genuinely new concept formalizing this threshold phenomenon, for example:

- `CriticalScalingWitness α F`
- `PerturbationRegime α`
- `AsymptoticallyIrrelevant (f : ℕ → ℕ → ℝ)`
- `HasCrossoverExponent (βW : ℕ → ℕ → ℝ) (α : ℝ)`

A particularly promising new definition is:

```lean
def WreathDefect (betaSymm : ℕ → ℝ) (betaW : ℕ → ℕ → ℝ) (k m : ℕ) : ℝ :=
  betaW k m - (m : ℝ) * betaSymm k
```

and a scaling notion such as

```lean
def AsymptoticallyIrrelevantAtExponent
    (betaSymm : ℕ → ℝ) (betaW : ℕ → ℕ → ℝ) (α : ℝ) : Prop :=
  ∀ ⦃m : ℕ → ℕ⦄,
    Tendsto (fun k => (m k : ℝ) / (k : ℝ)^α) atTop (𝓝 0) →
    Tendsto (fun k => WreathDefect betaSymm betaW k (m k)) atTop (𝓝 0)
```

You may refine this to use `ℝ≥0∞`, limsup bounds, or eventually estimates if cleaner in Lean.

---

## Precise theorem targets

You must prove at least **3 substantial theorems**. They should not be vacuous asymptotic repackagings; each theorem must have genuine mathematical content and require multi-step argument.

### Theorem 1: Quantitative irrelevance from explicit m-dependent error growth

Assume the perturbation theorem can be sharpened to an explicit polynomial-in-`m` error envelope:
\[
|\Delta(k,m)| \le C\,m^p\,k^{-q}
\]
for constants `C > 0`, `p,q > 0`.

Then prove a threshold theorem of the form:
\[
m(k)=o\!\left(k^{q/p}\right) \implies \Delta(k,m(k)) \to 0.
\]

This is the first rigorous candidate for a critical exponent:
\[
\alpha_c = q/p.
\]

### Lean 4 type signature target
A model signature, to be adapted to actual catalog definitions:

```lean
theorem wreath_defect_tendsto_zero_of_subcritical
    {betaSymm : ℕ → ℝ} {betaW : ℕ → ℕ → ℝ}
    {C p q : ℝ}
    (hC : 0 ≤ C) (hp : 0 < p) (hq : 0 < q)
    (hbound : ∀ k m : ℕ,
      |WreathDefect betaSymm betaW k m| ≤ C * (m : ℝ)^p / (k : ℝ)^q)
    {mf : ℕ → ℕ}
    (hsub :
      Tendsto (fun k => (mf k : ℝ) / (k : ℝ)^(q/p)) atTop (𝓝 0)) :
    Tendsto (fun k => WreathDefect betaSymm betaW k (mf k)) atTop (𝓝 0)
```

If exponent arithmetic in `ℝ` becomes awkward, specialize to natural exponents:

```lean
theorem wreath_defect_tendsto_zero_of_subcritical_nat
    {betaSymm : ℕ → ℝ} {betaW : ℕ → ℕ → ℝ}
    {C : ℝ} {a b : ℕ}
    (hC : 0 ≤ C)
    (hbound : ∀ k m : ℕ,
      |WreathDefect betaSymm betaW k m| ≤ C * (m : ℝ)^a / (k : ℝ)^b)
    {mf : ℕ → ℕ}
    (hsub :
      Tendsto (fun k => ((mf k : ℝ)^a) / (k : ℝ)^b) atTop (𝓝 0)) :
    Tendsto (fun k => WreathDefect betaSymm betaW k (mf k)) atTop (𝓝 0)
```

**Why this is a breakthrough:** It converts a perturbative estimate into a bona fide **critical-scaling theorem**. That is exactly the conceptual jump from “small error” to “universality boundary.”

---

### Theorem 2: Linear-pressure stability below the critical window

Use `pressure_directPower_linear` together with the wreath perturbation estimate to show that for subcritical `m(k)`,
\[
\beta_W(k,m(k)) \sim m(k)\,\beta(S_k),
\]
or at minimum
\[
\frac{\beta_W(k,m(k))}{m(k)} - \beta(S_k) \to 0,
\]
provided `m(k)` does not vanish eventually.

### Lean 4 type signature target

```lean
theorem wreath_pressure_per_copy_tendsto_betaSymm_of_subcritical
    {betaSymm : ℕ → ℝ} {betaW : ℕ → ℕ → ℝ}
    {mf : ℕ → ℕ}
    (hm_eventually_pos : ∀ᶠ k in atTop, 0 < mf k)
    (hdefect :
      Tendsto (fun k => WreathDefect betaSymm betaW k (mf k)) atTop (𝓝 0)) :
    Tendsto
      (fun k => betaW k (mf k) / (mf k : ℝ) - betaSymm k)
      atTop (𝓝 0)
```

A stronger theorem would directly combine the catalog linear-pressure theorem with your defect control:

```lean
theorem wreath_pressure_matches_direct_power_below_threshold
    {betaSymm : ℕ → ℝ} {betaW : ℕ → ℕ → ℝ}
    {mf : ℕ → ℕ}
    (hm_eventually_pos : ∀ᶠ k in atTop, 0 < mf k)
    (hbound_subcritical : ...)
    :
    Tendsto
      (fun k => betaW k (mf k) / (mf k : ℝ))
      atTop
      (𝓝 (??))
```

If the catalog theorem gives an asymptotic target for `betaSymm k`, plug it in and obtain a two-scale limit. The exact terminal expression depends on the actual statement of `pressure_directPower_linear`.

**Why this matters:** This theorem says that below threshold, the wreath product is not a new universality class at all—it is asymptotically governed by the same intensive pressure as independent copies. That is a finite-group analog of **irrelevant perturbations in the renormalization group**.

---

### Theorem 3: Crossover lower bound / obstruction theorem

Do not only prove irrelevance. Prove that if the defect lower bound scales too fast, then no stronger irrelevance statement can hold. A theorem of the following form is highly desirable:

If along some sequence `m(k)` one has
\[
|\Delta(k,m(k))| \ge c\,m(k)^p k^{-q}
\]
eventually, and
\[
m(k) \asymp k^{q/p},
\]
then the defect does **not** tend to zero unless the normalized profile cancels.

This is a mathematical obstruction to over-optimistic universality claims.

### Lean 4 type signature target

```lean
theorem not_tendsto_zero_of_critical_lower_bound
    {betaSymm : ℕ → ℝ} {betaW : ℕ → ℕ → ℝ}
    {c : ℝ} {a b : ℕ} {mf : ℕ → ℕ}
    (hc : 0 < c)
    (hlower : ∀ᶠ k in atTop,
      c * (k : ℝ)^b ≤ ((mf k : ℝ)^a))
    (hdefect_lower : ∀ᶠ k in atTop,
      c ≤ |WreathDefect betaSymm betaW k (mf k)|)
    :
    ¬ Tendsto (fun k => WreathDefect betaSymm betaW k (mf k)) atTop (𝓝 0)
```

This can be sharpened into a theorem about `Filter.limsup` or existence of a nonzero accumulation point of a normalized defect. If exact nonconvergence is too strong from available hypotheses, prove a limsup lower bound:

```lean
theorem limsup_wreath_defect_pos_of_critical_scaling
    ...
    : 0 < Filter.limsup (fun k => |WreathDefect betaSymm betaW k (mf k)|) atTop
```

**Why this is revolutionary:** It gives the first rigorous evidence that the threshold is not an artifact of upper bounds. A universality-class transition requires both a stable regime and an obstruction to extending it beyond the critical window.

---

## Strong optional theorem: existence/uniqueness of a critical exponent witness

If feasible, define a predicate expressing that exponent `α` separates irrelevant and relevant regimes, and prove monotonicity/uniqueness properties.

Example definition:

```lean
def SeparatesRegimes
    (betaSymm : ℕ → ℝ) (betaW : ℕ → ℕ → ℝ) (α : ℝ) : Prop :=
  (∀ ⦃mf : ℕ → ℕ⦄,
      Tendsto (fun k => (mf k : ℝ) / (k : ℝ)^α) atTop (𝓝 0) →
      Tendsto (fun k => WreathDefect betaSymm betaW k (mf k)) atTop (𝓝 0))
  ∧
  (∃ mf : ℕ → ℕ,
      Tendsto (fun k => (mf k : ℝ) / (k : ℝ)^α) atTop (𝓝 (1 : ℝ)) ∧
      ¬ Tendsto (fun k => WreathDefect betaSymm betaW k (mf k)) atTop (𝓝 0))
```

Then prove that polynomial upper/lower bounds imply `SeparatesRegimes ... (q/p)`.

This would be a true theorem of **finite-group critical phenomena**.

---

## Proof strategy architecture

You must include 2–3 serious proof paths and choose the best one.

### Strategy A: Quantitative asymptotic analysis from explicit defect envelopes
1. Extract from `beta_wreath_eq_mul_beta_symm_plus_error` a usable expression
   \[
   \Delta(k,m)=E(k,m)
   \]
   and isolate all hidden constants depending on `m`.
2. Prove a polynomial or near-polynomial growth bound
   \[
   |E(k,m)| \le C\,m^p\,k^{-q}
   \]
   by repeated inequalities, asymptotic comparison, and explicit norm estimates.
3. Push this through `Tendsto` and squeeze arguments to obtain subcritical irrelevance and critical-window obstructions.

**Why promising:** This is the most direct route from current catalog assets to a publishable scaling theorem. It also fits Lean well: inequalities, `eventually`, and `Tendsto` are robust formal targets.

### Strategy B: Representation-theoretic control via Clifford theory / irreducible count growth
1. Express the wreath-product contribution in terms of partitions, stabilizers, or induced representations.
2. Bound the number and weight of irreducible contributions as functions of both `k` and `m`.
3. Translate those representation counts into defect-growth exponents `p,q`.

**Why promising:** This is conceptually deeper and may reveal the true value of the critical exponent rather than merely proving existence of one. It also connects to random matrix crossover heuristics.

### Strategy C: Subgroup-combinatorial large deviations
1. Interpret subgroup pressure for `S_k ≀ S_m` as a competition between internal `S_k^m` entropy and permutation-coupling cost from `S_m`.
2. Prove that the coupling term is negligible/subcritical precisely when its entropy contribution is lower order than the direct-power term.
3. Derive scaling windows from a variational inequality.

**Why promising:** This is the most visionary route. It may produce not just bounds, but a **crossover profile** analogous to free-energy scaling functions in statistical mechanics.

**Recommended priority:** Start with Strategy A for the formal breakthrough theorem, then use B or C to sharpen the exponent and motivate the conjectural scaling function.

---

## Cross-domain bridge theorems

You are required to include at least one theorem connecting this domain to another. Here are two high-value options.

### Bridge 1: Statistical mechanics
Formalize the analogy between wreath defect and finite-size free-energy correction.

Define a “relevance ratio”:
\[
\Phi_\alpha(k,m)=\frac{|\Delta(k,m)|}{m/k^\alpha}.
\]
Prove monotonicity or boundedness results showing that subcritical scaling forces `Φ_α → 0`.

This is not just metaphor. It is a precise theorem saying the perturbation has a **scaling dimension**.

Possible Lean target:

```lean
def RelevanceRatio
    (betaSymm : ℕ → ℝ) (betaW : ℕ → ℕ → ℝ) (α : ℝ) (k m : ℕ) : ℝ :=
  |WreathDefect betaSymm betaW k m| / ((m : ℝ) / (k : ℝ)^α)

theorem relevance_ratio_tendsto_zero_of_strict_subcriticality
    ...
```

### Bridge 2: Random matrix universality
Use the analogy:
- direct powers ↔ independent blocks,
- wreath action ↔ symmetry-coupled block ensemble,
- threshold in `m` ↔ crossover between universality classes.

A formal theorem here could show that if the coupling defect is subcritical, then intensive observables are asymptotically unchanged. This is the group-theoretic analog of GOE/GUE crossover observables being unchanged below a critical perturbation scale.

Even if the random-matrix analogy remains in prose, at least one theorem should explicitly use a newly defined “crossover observable” with that interpretation.

---

## Conjecture with testable prediction

State and investigate a falsifiable conjecture:

### Conjecture (Critical crossover exponent)
There exists `α > 0` and a nontrivial profile `F : ℝ≥0 → ℝ` such that for any sequence `m(k)` with
\[
m(k)/k^\alpha \to \lambda \in [0,\infty),
\]
one has
\[
\Delta(k,m(k)) \to F(\lambda),
\]
or after a natural normalization,
\[
\widetilde{\mathcal R}_\alpha(k,m(k)) \to F(\lambda).
\]

Moreover:
- `F(0)=0` (irrelevant regime),
- `F(λ)` is nonzero for some `λ>0` (marginal regime),
- `F(λ)` grows or changes sign/convexity for large `λ` (relevant regime).

### Computational disproof test
For `k ∈ {3,4,5,6,7,8}` and
\[
m \in \{\lfloor k/2\rfloor,\, k,\, 2k,\, k^2\},
\]
compute `β_W(k,m)` by subgroup enumeration or GAP, then plot
\[
\widetilde{\mathcal R}_\alpha(k,m)
\]
against `m/k^\alpha` for several candidate exponents `α ∈ {1/2, 1, 3/2, 2}`.
If no collapse occurs for any `α`, the conjecture is false in its current form.

This must be included as a serious scientific conjecture, not decorative prose.

---

## Expected new definitions

You must introduce at least one genuinely new definition. Recommended list:

```lean
def WreathDefect ...
def RelevanceRatio ...
def AsymptoticallyIrrelevantAtExponent ...
def SeparatesRegimes ...
inductive PerturbationRegime
| irrelevant
| marginal
| relevant
```

At least one of these should be used in multiple theorems.

---

## Lean implementation guidance

Use the existing catalog theorems as lemmas, not merely citations. The file should feature real asymptotic reasoning:
- `Tendsto`
- `eventually_atTop`
- `Filter.Eventually`
- squeeze theorem style estimates
- `by_contra`
- `field_simp`
- `calc`
- induction where needed on natural exponents or polynomial envelopes
- `rcases` for extracting asymptotic witnesses from eventual statements

You must avoid trivial proof patterns. At least 3 theorem proofs must involve nontrivial tactic chains.

A good file architecture:

1. `WreathDefect` and scaling definitions
2. general asymptotic lemmas for polynomial defect envelopes
3. subcritical irrelevance theorem
4. per-copy pressure stability theorem
5. critical lower-bound obstruction theorem
6. bridge theorem via relevance ratio
7. conjecture section + computational hooks

---

## Application keywords

finite group asymptotics; subgroup growth; wreath products; universality classes; renormalization group; critical exponent; double scaling limit; finite-size scaling; statistical mechanics; random matrix crossover; Clifford theory; asymptotic representation theory; entropy-perturbation competition; crossover profile; scaling dimension

---

## Deliverables (ALL mandatory)

You must produce all of the following:

1. **Lean file(s)** with the new definitions and at least 3 substantial theorems as above, minimizing sorry.
2. **`FUTURE_DIRECTIONS.md`** with 3–5 original research directions. Each direction must explicitly contain the sentences:
   - **“The key insight is...”**
   - **“Why now?”**
   At least one direction must bridge to a different domain.
3. **`RESEARCH_PAPER.md`** as a standalone scientific paper. A reader with no access to code must understand:
   - the problem,
   - the theorem statements,
   - the proof ideas,
   - why this is a breakthrough,
   - what to do next.
4. **`ARTICLE.md`** in Scientific American style, engaging and accessible, focused on the mathematical ideas and significance. Do **not** focus on formal verification machinery.
5. **A verified algorithm or computational method** for estimating or computing `β_W(k,m)` and the rescaled defect/crossover observable.
6. **`demo.py`** that interactively demonstrates the scaling law:
   - input `k`, `m`, and candidate exponent `α`,
   - compute or load `β_W(k,m)`,
   - display `Δ(k,m)` and rescaled quantities,
   - optionally generate collapse plots across multiple `α`.

---

## Final ambition

Do not stop at “the error goes to zero.” The real target is to formalize the first rigorous **critical-phenomena theory for wreath-product subgroup pressure**: a theorem that identifies when multiplicity is irrelevant, when it becomes marginal, and why a new universality class must emerge beyond threshold.

If you can prove even a robust partial version—especially a theorem pinning the critical exponent to an explicit ratio of defect-growth exponents—you will have transformed a perturbative observation into a new asymptotic theory.

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
