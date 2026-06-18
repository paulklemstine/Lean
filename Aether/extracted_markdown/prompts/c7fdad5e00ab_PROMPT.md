## Mode: prove

## Breakthrough Objective
Use computational experimentation to discover and then formally prove a **sharp bridge theorem between Bayesian evidence, online regret, and coherence/entanglement constraints**. The goal is not another isolated inequality, but a unification principle: show that the catalog’s “logic” theorems are shadows of a common convex-information law.

This is the right cold-start move because the existing verified results already hint at a hidden architecture:

- `evidence_upper_bound` controls Bayesian-style evidence accumulation.
- `expert_regret_bound_nonneg` controls adversarial prediction regret.
- `coherence_bounded` controls a resource-like quantity called coherence.
- `info_lower_bound` gives a logarithmic information floor.
- `bell_chsh_bound` controls nonclassical correlations via a CHSH inequality.

The breakthrough is to prove that **bounded evidence growth induces bounded regret after logarithmic compression, and that both are structurally compatible with coherence and Bell-type constraints**. This opens a new formal field: **resource-sensitive prediction logic**, where online learning, information bounds, and nonclassical constraints live in one Lean-native framework.

## Precise Theorem Target

You should introduce a minimal abstraction capturing a nonnegative “evidence” quantity and prove a logarithmic domination theorem. The theorem should be strong enough to subsume the existing bounds as corollaries or comparison lemmas.

A concrete target:

```lean
theorem log_evidence_controlled_by_linear_bound
    {n : ℕ} (hn : 0 < n)
    (b : BState n) (l : Fin n → ℝ) :
    Real.log (1 + evidence b l) ≤ evidenceUpperEnvelope b l
```

where `evidence : BState n → (Fin n → ℝ) → ℝ` is the evidence quantity already implicit in `evidence_upper_bound`, and `evidenceUpperEnvelope` is the upper bound furnished by that theorem or a definable expression extracted from it.

Then prove a finite-dimensional comparison theorem of the following form:

```lean
theorem regret_le_log_evidence_plus_coherence
    (n T : ℕ) (hn : 0 < n) (hT : 0 < T)
    (H : ℝ) :
    regret n T ≤ Real.log n + H
```

under hypotheses that connect regret to evidence accumulation and coherence to an additive resource budget. If the exact catalog definitions force a modified right-hand side, that is acceptable, but the theorem must preserve the conceptual form:

**regret ≤ information term + coherence term**

Finally, push to a genuinely cross-domain theorem:

```lean
theorem classical_prediction_chsh_compatibility
    {n : ℕ} (L : LocalModel n) (i j : Fin n)
    (H : ℝ) (hn : 0 < n) :
    predictionCorrelation L i j + coherencePenalty H n ≤ 2
```

or an equivalent theorem showing that any predictive correlation extracted from a local model is bounded by a Bell/CHSH ceiling plus a coherence budget. If direct formulation with current definitions is impossible, prove a comparison lemma that packages `bell_chsh_bound` and `coherence_bounded` into a single certified resource inequality.

## Lean 4 Type Signature Candidates
You should aim for one or more of these exact signatures, adapting names to the actual catalog constants after inspection:

```lean
theorem log_one_plus_le_of_evidence_upper_bound
    {n : ℕ} (b : BState n) (l : Fin n → ℝ) :
    Real.log (1 + evidence b l) ≤ evidence_upper_rhs b l
```

```lean
theorem coherence_controls_log_evidence
    {n : ℕ} (H : ℝ) (hn : 0 < n) (b : BState n) (l : Fin n → ℝ) :
    Real.log (1 + evidence b l) ≤ H + Real.log n
```

```lean
theorem regret_bounded_by_information_budget
    (n T : ℕ) (hn : 0 < n) (hT : 0 < T) :
    regret n T ≤ Nat.log 2 (2 ^ T) + 1
```

```lean
theorem local_model_correlation_is_classically_bounded
    {n : ℕ} (L : LocalModel n) (i j : Fin n) :
    |correlation L i j| ≤ 2
```

Even if the exact constant `2` or exact regret object differs from the file’s definitions, the theorem must be a nontrivial synthesis theorem, not a restatement of an existing one.

## Why This Would Be a Breakthrough
If you succeed, you will have formalized a new theorem schema linking:

- Bayesian evidence accumulation,
- adversarial prediction regret,
- coherence/resource constraints,
- information compression,
- Bell/CHSH locality bounds.

That is not an incremental extension. It says that **prediction under logical/resource constraints obeys the same geometry as classical-vs-nonclassical correlation bounds**. This opens a new direction where theorem-proved online learning guarantees are interpreted as resource inequalities, and where Bell-type bounds become certificates for prediction architectures.

This could seed:
- a formal theory of **logical thermodynamics of prediction**,
- certified online-learning bounds under resource constraints,
- Lean-native bridges between decision theory and quantum information,
- new abstractions for “coherence budgets” in machine learning and game theory.

## Python-First Discovery Protocol
Before formal proof, run experiments to identify the sharp constants and plausible formulations.

### Experiment 1: Evidence vs log-compression
Sample simple `l : Fin n → ℝ` vectors and candidate belief states `b`. Numerically test:
- `log(1 + evidence)` vs raw upper bound,
- whether a tighter inequality like `log(1 + evidence) ≤ max l_i`, `≤ avg l_i + log n`, or `≤ H + log n` appears empirically.

### Experiment 2: Regret vs information floor
For small `n, T`, simulate expert advice processes and compare:
- empirical regret,
- `log n`,
- `Nat.log 2 (2^T) + 1`,
- candidate evidence-derived bounds.

Look for a theorem of the shape:
`regret ≤ C * log n + D * coherence + E`.

### Experiment 3: CHSH-compatible predictive correlations
Construct toy local models and compare any prediction/correlation statistic against:
- `bell_chsh_bound`,
- coherence budget from `coherence_bounded`.

Search for additive, multiplicative, or max-type combined inequalities.

These experiments are not optional decoration. They should determine the strongest true statement before you commit to Lean.

## Proof Strategy A: Monotone Compression of Existing Bounds
Most promising.

1. Inspect `evidence_upper_bound` and isolate its RHS as a nonnegative linear or affine quantity.
2. Use analytic inequalities from Mathlib such as:
   - `Real.log_le_iff_le_exp`,
   - `Real.log_one_plus_le_of_nonneg`,
   - concavity/monotonicity of `Real.log`,
   - standard inequalities like `log(1+x) ≤ x` for `x ≥ 0`.
3. Convert the linear evidence upper bound into a logarithmic one, then combine with `coherence_bounded` and `info_lower_bound` to derive a unified information-budget inequality.

Why promising: it leverages existing theorems directly and only needs one layer of abstraction. It is the shortest route to a new theorem with real conceptual force.

## Proof Strategy B: Resource Semiring / Potential Function Method
Potentially deeper.

1. Define a new quantity, e.g.
   ```lean
   def predictionPotential := Real.log (1 + evidence b l) + coherencePenalty H n
   ```
2. Prove it is bounded by an information envelope using `coherence_bounded` and `info_lower_bound`.
3. Show regret is controlled by this potential, giving a generic transfer theorem from evidence processes to online prediction.

Why powerful: if it works, it yields an extensible framework. Future theorems become corollaries of a single potential inequality.

Risk: may require introducing new definitions and proving auxiliary lemmas before any payoff.

## Proof Strategy C: Bell-to-Prediction Comparison via Absolute Bounds
Most speculative but scientifically bold.

1. Extract a bounded correlation quantity from `LocalModel n`.
2. Use `bell_chsh_bound` to certify a classical ceiling.
3. Show that any prediction statistic encoded via the same finite structure must respect the same ceiling, possibly after normalization by coherence or evidence.

Why this matters: it creates the cross-domain bridge no one expects — adversarial prediction constrained by Bell locality.

Risk: definitions may not line up directly. If so, prove a comparison lemma rather than the full bridge theorem.

## Build Explicitly on Catalog Theorems
Do not just cite them; use them structurally.

- From `evidence_upper_bound`:
  extract an explicit upper envelope for evidence and push it through `log(1+x) ≤ x`.
- From `expert_regret_bound_nonneg`:
  combine nonnegativity with your new upper bound to sandwich regret into an information interval.
- From `coherence_bounded`:
  use coherence as an additive penalty/resource budget in the final inequality.
- From `info_lower_bound`:
  convert combinatorial growth into logarithmic information control.
- From `bell_chsh_bound`:
  certify that your predictive/correlation quantity remains in the classical regime.

## Cross-Domain Connections
You must explicitly frame the work in at least one of these languages:

- **Online learning / game theory**: regret as information expenditure.
- **Quantum information**: CHSH bound as a classicality certificate for predictive systems.
- **Statistical mechanics**: evidence/coherence as free-energy-like resources.
- **Proof theory / logic**: coherence as consistency budget; evidence as derivability weight.
- **Complexity theory**: logarithmic information bounds as compression limits on strategy classes.

The strongest narrative is:
**prediction regret behaves like dissipated free energy under logical coherence and Bell-locality constraints.**

That sentence should guide theorem naming and exposition.

## Concrete Lean Tasks
1. Inspect the exact RHS and hypotheses of:
   - `evidence_upper_bound`
   - `expert_regret_bound_nonneg`
   - `coherence_bounded`
   - `bell_chsh_bound`
2. Define any missing wrappers with simple concrete codomains (`ℝ`, `Nat`, `Fin n → ℝ`).
3. Prove at least one new theorem that is not a trivial corollary by `linarith`.
4. If a strong theorem fails, salvage a weaker but still meaningful version:
   - replace equality by inequality,
   - replace sharp constants by safe constants,
   - add nonnegativity assumptions,
   - restrict to finite-dimensional or local-model settings.

## Validation Standard
A theorem counts only if it:
- is new relative to the listed catalog,
- uses at least one existing verified theorem nontrivially,
- has a mathematically interpretable statement,
- survives computational testing before formalization.

## Deliverables
Required:
- Lean 4 theorem(s) with minimized `sorry`
- `FUTURE_DIRECTIONS.md`

Recommended:
- `demo.py` with experimental discovery code
- `ARTICLE.md` explaining the bridge theorem
- a short note documenting failed conjectures and counterexamples

## FUTURE_DIRECTIONS.md Requirements
You must include 3–5 concrete next steps, each with:
- a precise theorem statement,
- why it would be breakthrough-level,
- 2 proof ideas,
- one cross-domain connection.

Examples of strong future directions:
1. A minimax theorem equating coherence budget with regret phase transition.
2. A Bell-type inequality for adversarial experts.
3. A free-energy variational principle for evidence accumulation.
4. A categorical abstraction unifying local models and prediction games.
5. An algorithm extracting certified strategy complexity from information bounds.

## Application Keywords
online learning, adversarial prediction, Bayesian evidence, coherence, CHSH inequality, Bell locality, information theory, convex potential, free energy, logical uncertainty, finite models, certified bounds, Lean 4 formalization, resource-sensitive reasoning

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

Research domain: Logic
Research mode: prove
