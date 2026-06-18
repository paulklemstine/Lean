## Assignment: Computational Conjecture Testing as a Theorem-Discovery Engine

Prove new, non-trivial theorems, but do so with an explicit experimental pipeline: use Python to generate conjectures, stress-test boundary cases, and identify the exact algebraic/combinatorial invariant that survives formalization in Lean 4. The goal is not “numerics first” in a weak sense; it is to create a certified conjecture-mining loop where experiments reveal hidden monotonicity, convexity, extremality, or entropy-like structure, and Lean seals the theorem.

Minimize sorry. If a bold theorem stalls, split it into a chain of formally meaningful lemmas and land the strongest fully verified statement.

### Research Direction
Use Python prototypes before formal proof attempts, especially to search for:
- extremizers of finite combinatorial inequalities,
- monotone quantities in recursive or adversarial processes,
- entropy/evidence/coherence tradeoffs suggested by the catalog theorems,
- sharp constants in logarithmic/information-style bounds over finite structures.

The key opportunity in this cycle is to create a bridge theorem between:
- adversarial prediction/regret,
- evidence/information accumulation,
- coherence-style boundedness,
- and finite combinatorial search.

This can open a genuine “experimental theorem synthesis” program in Lean.

## Mathematical Framing

The catalog strongly suggests a latent unification: several existing results control a quantity that grows sublinearly, logarithmically, or remains bounded under finite evolution:
- `evidence_upper_bound`
- `expert_regret_bound_nonneg`
- `coherence_bounded`
- `info_lower_bound`

These are not yet tied together by a common formal principle. Your task is to extract one.

A high-value target is to formalize a finite potential method: define a discrete potential on a finite state space and prove that if each update preserves a supermartingale-like or convexity-like inequality, then cumulative gain/regret/evidence is globally bounded. Computational experiments should identify the correct potential before proof.

This is not merely a technical exercise. If successful, it creates a reusable Lean blueprint for:
- online learning,
- statistical evidence accumulation,
- finite information thermodynamics,
- and holographic/counting-style inequalities.

## Primary Breakthrough Target

### Theorem Proposal A: Finite log-sum-exp lower bound from pointwise normalization
Search experimentally for the strongest version, then prove a formal theorem of the following shape.

If `w : Fin n → ℝ` are nonnegative weights summing to at least `1`, then the log of the exponential moment dominates the weighted mean:
\[
\sum_i w_i = 1 \implies \sum_i w_i x_i \le \log\!\left(\sum_i w_i e^{x_i}\right).
\]
This is classical analytically, but the breakthrough is not the inequality itself — it is to package it in Lean over finite types as a reusable engine that can instantiate evidence, regret, and coherence bounds.

A precise Lean target:

```lean
theorem weighted_le_log_sum_exp
    {n : ℕ} (hn : 0 < n)
    (w x : Fin n → ℝ)
    (hw_nonneg : ∀ i, 0 ≤ w i)
    (hw_sum : (∑ i, w i) = 1) :
    (∑ i, w i * x i) ≤ Real.log (∑ i, w i * Real.exp (x i))
```

You may need positivity side lemmas to show the log argument is positive:
```lean
have hpos : 0 < ∑ i, w i * Real.exp (x i) := ...
```

This theorem becomes the convex analytic backbone for finite evidence/regret inequalities.

### Theorem Proposal B: Finite max bound via log-sum-exp
Prove the sharp finite softmax domination principle:
\[
\max_i x_i \le \log\left(\sum_i e^{x_i}\right)
\]
and ideally the two-sided estimate
\[
\log\left(\sum_i e^{x_i}\right) \le \max_i x_i + \log n.
\]

Lean target:
```lean
theorem max_le_log_sum_exp
    {n : ℕ} (hn : 0 < n) (x : Fin n → ℝ) :
    (Finset.univ.sup' hn x) ≤ Real.log (∑ i, Real.exp (x i))
```

Stronger target:
```lean
theorem log_sum_exp_le_max_add_log_card
    {n : ℕ} (hn : 0 < n) (x : Fin n → ℝ) :
    Real.log (∑ i, Real.exp (x i))
      ≤ (Finset.univ.sup' hn x) + Real.log n
```

If `sup'` over `ℝ` is inconvenient, replace with an explicit witness formulation:
```lean
∃ i : Fin n, x i ≤ Real.log (∑ j, Real.exp (x j))
```
or define `m := Finset.univ.max' ...`.

### Theorem Proposal C: Regret/evidence bridge inequality
Use the previous finite convex inequalities to derive a bridge theorem connecting “expert regret” style nonnegativity with evidence accumulation. A candidate finite theorem:

```lean
theorem cumulative_mean_le_log_average_exp
    {n : ℕ} (hn : 0 < n) (x : Fin n → ℝ) :
    ((∑ i, x i) / n) ≤ Real.log ((∑ i, Real.exp (x i)) / n)
```

This is Jensen in finite form and may be the cleanest deployable bridge theorem. It is highly reusable and can plausibly interact with `evidence_upper_bound` and `coherence_bounded` by substituting semantically meaningful observables.

## Why This Would Be a Breakthrough

A formally reusable finite convexity/information package in Lean 4 would be a field-opening bridge, not an incremental lemma:
- It connects online learning potentials with information-theoretic free energy.
- It turns computationally discovered inequalities into certifiable proof objects.
- It creates infrastructure for proving nontrivial bounds in adversarial prediction, Bayesian evidence, and finite statistical mechanics.
- It opens a path toward formal mirror descent, PAC-Bayes, Gibbs variational principles, and entropy production inequalities in Mathlib-compatible style.

This is the kind of theorem architecture that can propagate far beyond the initial statement.

## Existing Verified Theorems
Existing theorems you can build on:
1. `area_law_proof` : theorem area_law_proof {n : ℕ} (hn : 4 ≤ n) :
   (file: Logic/HolographicProofs.lean)
2. `evidence_upper_bound` : theorem evidence_upper_bound {n : ℕ} (b : BState n) (l : Fin n → ℝ)
   (file: Logic/AdvancedTheorems.lean)
3. `expert_regret_bound_nonneg` : theorem expert_regret_bound_nonneg (n T : ℕ) (hn : 0 < n) (hT : 0 < T) :
   (file: Logic/AdversarialPrediction.lean)
4. `coherence_bounded` : theorem coherence_bounded (H : ℝ) (n : ℕ) (hn : 0 < n)
   (file: Logic/CoherenceStratification.lean)
5. `info_lower_bound` : theorem info_lower_bound (k : ℕ) : k ≤ Nat.log 2 (2 ^ k) + 1 := by
   (file: Logic/CoherenceStratified.lean)

### How to Build on Them
- Use `evidence_upper_bound` as motivation for identifying a log-partition or exponential-moment quantity hidden in `BState` dynamics.
- Use `expert_regret_bound_nonneg` as a minimal sanity theorem: computational experiments should search for stronger inequalities where regret is not only nonnegative but controlled by a log-partition potential.
- Use `coherence_bounded` to test whether coherence-like quantities admit convex-envelope bounds.
- Use `info_lower_bound` to connect logarithmic cardinality bounds with log-sum-exp upper envelopes.
- Use `area_law_proof` conceptually: finite boundary/bulk compression phenomena often reduce to extremal counting or entropy bounds; your finite convex package may become the analytic side of such arguments.

## Proof Strategy Paths

### Strategy A: Jensen/convexity route
Most promising for Theorems A and C.

1. Prove or locate in Mathlib convexity of `Real.exp`.
2. Apply finite Jensen:
   \[
   \exp\left(\sum_i w_i x_i\right) \le \sum_i w_i \exp(x_i)
   \]
   under `w_i ≥ 0` and `∑ w_i = 1`.
3. Apply `Real.log_le_log` with positivity to conclude the desired inequality.

Why promising:
- Conceptually canonical.
- Reusable across all finite probabilistic or adversarial settings.
- Likely closest to Mathlib’s existing convex-analysis toolkit.

### Strategy B: Direct extremal/normalization argument
Especially promising for Theorem B.

1. Let `m = max_i x_i`.
2. Rewrite:
   \[
   \sum_i e^{x_i} = e^m \sum_i e^{x_i - m}.
   \]
3. Since at least one term satisfies `x_i - m = 0` and all others are `≤ 0`,
   \[
   1 \le \sum_i e^{x_i - m} \le n.
   \]
4. Take logs to obtain both lower and upper bounds.

Why promising:
- Elementary and robust.
- Avoids deep convexity dependencies.
- Gives sharp constants immediately.

### Strategy C: Variational/free-energy route
Most visionary and cross-domain.

1. Experimentally conjecture that
   \[
   \log \sum_i e^{x_i}
   \]
   is the least upper bound of weighted means plus entropy:
   \[
   \sup_{p_i \ge 0,\,\sum p_i=1} \left(\sum_i p_i x_i - \sum_i p_i \log p_i\right).
   \]
2. First formalize the easy inequality direction:
   \[
   \sum_i p_i x_i \le \log \sum_i e^{x_i}
   \]
   using Theorem A with `w = p`.
3. If feasible, derive the optimizer `p_i ∝ e^{x_i}` and prove equality.

Why this matters:
- This is the Gibbs variational principle in finite dimension.
- It would connect your current catalog to statistical mechanics, PAC-Bayes, and mirror descent.
- Even the one-sided inequality is already highly valuable.

## Recommended Execution Order

1. Use Python to test Theorem B and candidate strengthened inequalities on random vectors and extremal families.
2. Formalize Theorem B first: it is elementary, sharp, and likely easiest.
3. Then formalize Theorem A or C using either Jensen or a direct tangent-line inequality for `exp`.
4. Finally, derive a bridge corollary interpretable in the language of evidence or regret.

## Computational Experiment Plan

In `demo.py`, search over:
- random vectors `x : ℝ^n`,
- sparse/extremal vectors with one large coordinate,
- nearly constant vectors,
- random probability vectors `w`,
- adversarial update sequences.

Test numerically:
- `max x ≤ log(sum exp x))`,
- `log(sum exp x) ≤ max x + log n`,
- `sum w_i x_i ≤ log(sum w_i exp x_i)`,
- empirical tightness and equality cases.

Use experiments to identify:
- the exact hypotheses needed,
- whether normalization by `n` or by `∑w` gives cleaner formal statements,
- sharpness witnesses.

## Cross-Domain Connections

This project should explicitly connect at least one theorem to another domain:

- **Information theory**: `log-sum-exp` is a finite partition function; Jensen gives free-energy lower bounds and can lead toward data-processing or variational characterizations.
- **Online learning**: softmax potentials are the analytic core of multiplicative weights and regret bounds.
- **Statistical mechanics**: `log ∑ exp` is free energy; the weighted inequality is the finite Gibbs principle.
- **Convex optimization**: this is the Legendre-Fenchel geometry of entropy.
- **Holography / complexity**: area-law and compression phenomena often hide entropy extremization principles; a finite convex package could become a reusable proof layer.

Do not mention these only rhetorically. Produce at least one corollary or discussion note showing how the formal theorem can be instantiated in one of these domains.

## Secondary Direction: Priority Open Problems
Because this is a cold start, if the convex-information bridge stalls, pivot to sorry-filling or foundational bridge work on the named targets:
- `CarmichaelComposite`
- `Fib_gcd_identity`

But do not retreat too early. The finite convexity bridge is more field-opening.

## Deliverables

Required:
- Lean 4 proofs with minimal sorry.
- `FUTURE_DIRECTIONS.md`

Optional:
- `ARTICLE.md`
- `RESEARCH_PAPER.md`
- `demo.py`
- `diagram.svg`

## FUTURE_DIRECTIONS.md Requirements

This file is critical. Include 3–5 concrete next steps, each with:
1. an exact theorem statement,
2. a Lean-style type signature,
3. a plausible proof strategy,
4. a cross-domain significance note.

Suggested next-step targets:
- finite Gibbs variational principle,
- entropy-regularized argmax existence,
- multiplicative weights regret bound via log-sum-exp potential,
- finite KL-nonnegativity from convexity of `log`,
- a bridge from `evidence_upper_bound` to a partition-function inequality.

## Application Keywords
log-sum-exp, Jensen inequality, finite convexity, Gibbs variational principle, multiplicative weights, regret bounds, free energy, entropy, evidence accumulation, coherence bounds, online learning, statistical mechanics, formal verification, theorem discovery, Lean 4, Mathlib, computational conjecture mining

---

You are Aristotle. Pursue the strongest theorem that survives both experiment and formal proof. Use Python not as a crutch but as a telescope: detect the hidden invariant, then certify it in Lean. Define the right finite potential, prove its universal inequality, and turn isolated catalog theorems into the first layer of a formal information dynamics library.

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
