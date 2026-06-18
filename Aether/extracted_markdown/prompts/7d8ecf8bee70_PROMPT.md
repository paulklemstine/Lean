## Assignment: PAC-Bayes Generalization Bounds as a Formal Information-Geometric Bridge

You are not being asked to merely formalize a known inequality. You are being asked to turn PAC-Bayes into a certified Lean 4 interface between statistical learning theory, information geometry, perturbation analysis, and neural network stability. The breakthrough is to make posterior-vs-prior generalization control *machine-checkable* in a way that composes with existing perturbation theorems and supports asymptotic sharpness statements.

Prove new, non-trivial theorems. Build on catalog theorems. Minimize sorry.

### Mode
**prove**

### Core Vision

Formalize a finite-sample PAC-Bayes theory in Lean 4 for bounded losses, prove both McAllester-type and Catoni-type bounds, then instantiate them with Gaussian perturbation posteriors for parametric predictors and derive asymptotic tightness for linear classifiers under explicit regularity assumptions.

This is a field-opening bridge because it connects:

- **statistical learning theory**: PAC-Bayes posterior generalization guarantees,
- **information geometry**: KL divergence as complexity and curvature proxy,
- **robustness theory**: perturbation-based control of empirical loss,
- **neural network analysis**: Gaussian posterior/prior perturbations,
- **asymptotic statistics**: tightness and rate-optimality for linear predictors.

If done cleanly, this creates a reusable Lean library for:
- certified generalization bounds for randomized predictors,
- robustness-to-generalization transfer theorems,
- future formalizations of compression bounds, flat minima, Gibbs posteriors, and Bayesian deep learning.

---

## Precise Theorem Targets

Work with a finite sample space first if necessary, then generalize to measurable spaces once the architecture is stable. Use bounded losses `ℓ : α → Θ → ℝ` with values in `[0,1]`.

### 1. Abstract PAC-Bayes McAllester Bound

Formalize a theorem of the following shape:

For any prior `P` on hypotheses, any posterior `Q` absolutely continuous with respect to `P`, any confidence `δ ∈ (0,1)`, with probability at least `1 - δ` over an i.i.d. sample `S` of size `n`, one has
\[
\mathrm{KL}\big(\hat L_S(Q)\,\|\,L(Q)\big)
\le \frac{\mathrm{KL}(Q\|P) + \log\frac{2\sqrt n}{\delta}}{n},
\]
and therefore
\[
L(Q) \le \hat L_S(Q) + \sqrt{\frac{\mathrm{KL}(Q\|P)+\log(2\sqrt n/\delta)}{2n}}
\]
up to the exact constants supported by the formal route you choose.

A Lean-oriented target signature could look like:

```lean
theorem pac_bayes_mcallester_bound
  {α Θ : Type*}
  [Fintype α] [DecidableEq α] [MeasurableSpace Θ]
  (dist : ProbabilityMeasure α)
  (loss : α → Θ → ℝ)
  (P Q : ProbabilityMeasure Θ)
  (n : ℕ)
  (δ : ℝ)
  (hδ0 : 0 < δ) (hδ1 : δ < 1)
  (hloss_nonneg : ∀ x θ, 0 ≤ loss x θ)
  (hloss_le_one : ∀ x θ, loss x θ ≤ 1)
  (hn : 1 ≤ n) :
  ∃ bad : Set ((Fin n) → α),
    dist.vec n bad ≤ ENNReal.ofReal δ ∧
    ∀ S, S ∉ bad →
      klBernoulli
        (empiricalGibbsRisk loss Q S)
        (trueGibbsRisk dist loss Q)
      ≤
      (klDiv Q P + Real.log (2 * Real.sqrt n / δ)) / n
```

You may need to replace `ProbabilityMeasure`, `dist.vec`, `klDiv`, `klBernoulli`, `empiricalGibbsRisk`, `trueGibbsRisk` with your own definitions depending on what Mathlib already supports. If full measure-theoretic probability becomes a bottleneck, first prove a finitary version over `PMF` and then lift.

### 2. Catoni PAC-Bayes Bound

Prove a Catoni-style exponential bound with tunable inverse temperature `λ > 0`:

\[
L(Q) \le \frac{1}{1-e^{-\lambda}}
\left(
1 - \exp\left(
-\lambda \hat L_S(Q)
-\frac{\mathrm{KL}(Q\|P)+\log(1/\delta)}{n}
\right)
\right)
\]
or an equivalent certified form obtained from the convex dual / Donsker–Varadhan route.

Lean target:

```lean
theorem pac_bayes_catoni_bound
  {α Θ : Type*}
  [Fintype α] [DecidableEq α] [MeasurableSpace Θ]
  (dist : ProbabilityMeasure α)
  (loss : α → Θ → ℝ)
  (P Q : ProbabilityMeasure Θ)
  (n : ℕ)
  (δ λ : ℝ)
  (hδ0 : 0 < δ) (hδ1 : δ < 1)
  (hλ : 0 < λ)
  (hloss_nonneg : ∀ x θ, 0 ≤ loss x θ)
  (hloss_le_one : ∀ x θ, loss x θ ≤ 1)
  (hn : 1 ≤ n) :
  ∃ bad : Set ((Fin n) → α),
    dist.vec n bad ≤ ENNReal.ofReal δ ∧
    ∀ S, S ∉ bad →
      trueGibbsRisk dist loss Q
      ≤
      (1 / (1 - Real.exp (-λ))) *
        (1 - Real.exp
          (-λ * empiricalGibbsRisk loss Q S
           - (klDiv Q P + Real.log (1 / δ)) / n))
```

The exact constant package may differ depending on the route. What matters is a genuine Catoni-type theorem with explicit exponential structure.

### 3. Gaussian Perturbation Posterior Bound for Parametric Predictors

Let `θ ∈ ℝ^d`, let `P = N(0, σ₀² I)` and `Q = N(w, σ² I)` or at least the equal-covariance case `Q = N(w, σ² I), P = N(0, σ² I)`. Prove the KL term is explicit:
\[
\mathrm{KL}(Q\|P) = \frac{\|w\|_2^2}{2\sigma^2}
\]
in the equal-covariance centered-prior case.

Then combine this with a perturbation theorem controlling empirical loss under Gaussian weight noise to derive a concrete PAC-Bayes bound for randomized neural predictors.

Lean target, first in finite-dimensional Euclidean form:

```lean
theorem gaussian_shift_kl_eq
  (d : ℕ) (σ : ℝ) (w : Fin d → ℝ)
  (hσ : 0 < σ) :
  klDiv (gaussianVec w σ) (gaussianVec 0 σ)
    = (∑ i, (w i)^2) / (2 * σ^2)
```

Then a transfer theorem:

```lean
theorem pac_bayes_neural_perturbation_bound
  {α : Type*} [Fintype α] [DecidableEq α]
  (loss : α → ℝ → ℝ)
  (f : (Fin d → ℝ) → α → ℝ)
  (w : Fin d → ℝ) (σ : ℝ)
  (S : Fin n → α)
  (hσ : 0 < σ)
  (hloss_lipschitz : ...)
  (hperturb : ...)
  (hloss_nonneg : ...)
  (hloss_le_one : ...) :
  truePerturbedRisk loss f w σ
    ≤ empiricalRisk loss f w S
      + perturbationPenalty ...
      + Real.sqrt (((∑ i, (w i)^2) / (2 * σ^2) + Real.log (2 * Real.sqrt n / δ)) / (2*n))
```

The precise hypotheses should reflect what you can actually prove: Lipschitzness in parameters, bounded perturbation effect, or a direct inequality between empirical perturbed and unperturbed risks.

### 4. Asymptotic Tightness for Linear Classifiers

This is the genuinely bold theorem. Do not settle for “a bound exists.” Show that under a realizable or well-specified linear classification model, with posterior centered at the empirical minimizer and variance shrinking at the right rate, the PAC-Bayes complexity term and excess empirical risk term match the true excess risk rate up to constants.

A precise formalizable version:

Let data come from a linearly separable or logistic linear model in fixed dimension `d`. Let `Q_n = N(\hat w_n, σ_n^2 I)` and `P = N(0, τ^2 I)` with `σ_n^2 ≍ 1/n`. Then the PAC-Bayes upper bound scales as
\[
\hat L_n(Q_n) + O(d/n)
\]
and there exists a matching lower-order asymptotic regime showing no improvement below `c d/n` is possible for this posterior family.

Lean target, likely in a simplified deterministic asymptotic form first:

```lean
theorem pac_bayes_linear_classifier_rate_upper
  (d : ℕ) (τ : ℝ) (ŵ : ℕ → (Fin d → ℝ))
  (σ : ℕ → ℝ)
  (hτ : 0 < τ)
  (hσ_rate : ∃ C1 C2 > 0, ∀ᶠ n in Filter.atTop,
    C1 / n ≤ (σ n)^2 ∧ (σ n)^2 ≤ C2 / n)
  (hwnorm : ∃ C > 0, ∀ᶠ n in Filter.atTop, ∑ i, (ŵ n i)^2 ≤ C) :
  ∃ C' > 0, ∀ᶠ n in Filter.atTop,
    gaussianShiftComplexity (ŵ n) (σ n) τ ≤ C' * (d : ℝ) / n
```

and ideally a matching lower bound:

```lean
theorem pac_bayes_linear_classifier_rate_lower
  (d : ℕ) (τ : ℝ) (ŵ : ℕ → (Fin d → ℝ))
  (σ : ℕ → ℝ)
  ... :
  ∃ c > 0, ∀ᶠ n in Filter.atTop,
    c * (d : ℝ) / n ≤ gaussianShiftComplexity (ŵ n) (σ n) τ
```

Even if full probabilistic asymptotic tightness is too heavy, proving these deterministic complexity asymptotics already opens the door.

---

## Definitions You Likely Need

You should define clean reusable objects.

- `empiricalRisk`
- `trueRisk`
- `empiricalGibbsRisk`
- `trueGibbsRisk`
- `klBernoulli : ℝ → ℝ → ℝ`
- `klDiv : Measure/PMF/ProbabilityMeasure → ...`
- `gaussianShiftComplexity`
- `posteriorPerturbedPredictor`

Prefer bounded-loss finite-sample abstractions first. A strong architecture would include a finitary namespace like:

```lean
namespace PACBayes

def empiricalRisk ...
def trueRisk ...
def gibbsPredictor ...
def empiricalGibbsRisk ...
def trueGibbsRisk ...
def klBernoulli ...
def klDiv ...
def complexityTerm ...

end PACBayes
```

---

## How to Build on Catalog Theorems

Do not merely cite the catalog; integrate it.

1. `residual_perturbation_bound`
   - Use this as a prototype for converting parameter perturbation into output perturbation.
   - In a PAC-Bayes neural instantiation, this can control the gap between deterministic predictor risk and posterior-averaged risk.
   - If it is scalar-valued, first derive a corollary for expected perturbed outputs under Gaussian noise.

2. `dag_node_perturbation_bound`
   - This suggests a compositional perturbation calculus for layered or DAG-structured predictors.
   - Use it to bound how Gaussian weight perturbations propagate through network architecture, yielding an empirical-risk inflation term.

3. `aggregated_margin_lower_bound_under_perturbation`
   - This is especially powerful: if margins survive perturbation, then 0-1 loss under the posterior can be controlled by margin loss of the base predictor.
   - This gives a robustness-to-generalization bridge: posterior risk ≤ perturbed margin risk + PAC-Bayes complexity.

4. `padic_geodesic_tight_bound`
   - This is not superficial decoration. It hints at a geometric treatment of divergence and tightness.
   - Use it conceptually to motivate an information-geometric section: KL as geodesic energy / complexity.
   - If formal transfer is possible, seek a generic “geodesic divergence upper-controls posterior complexity” lemma.

5. `max_entropy_linear_bound`
   - This is highly relevant for priors. PAC-Bayes priors often arise from entropy maximization principles.
   - Use it to justify or derive canonical Gaussian / Gibbs priors in linear settings, or to compare PAC-Bayes complexity with max-entropy regularization.

---

## Proof Strategy Architecture

### Strategy A: Finitary Exponential-Moment Route
Most promising for initial formal success.

1. Formalize bounded empirical loss as an average of i.i.d. bounded random variables and prove an exponential moment inequality for each fixed hypothesis.
2. Lift from a fixed hypothesis to a posterior `Q` using the change-of-measure / convex dual inequality:
   \[
   \mathbb E_Q[f] \le \mathrm{KL}(Q\|P) + \log \mathbb E_P[e^f].
   \]
3. Apply Markov’s inequality and union/change-of-measure reasoning to obtain a high-probability PAC-Bayes bound.

Why promising:
- This route is modular.
- It reduces the theorem to a small number of reusable lemmas: exponential moments, KL variational formula, and bounded-loss concentration.
- It adapts naturally to Catoni.

### Strategy B: Donsker–Varadhan Variational Formula Route
Best for Catoni and future Gibbs posterior theory.

1. Prove or import a finite/discrete Donsker–Varadhan formula:
   \[
   \log \mathbb E_P[e^f] = \sup_Q \left(\mathbb E_Q[f] - \mathrm{KL}(Q\|P)\right).
   \]
2. Instantiate `f` with a scaled deviation between empirical and true risks.
3. Derive Catoni’s bound by optimizing the exponential tilt parameter `λ`.

Why important:
- This is conceptually deeper and more extensible.
- It sets up future formalization of Gibbs posteriors, free energy, and variational inference.
- It is the right route if you want PAC-Bayes to become an information-theoretic library rather than an isolated theorem.

### Strategy C: Robustness-Transfer Route for Neural Networks
Most promising for the application theorem.

1. Use `residual_perturbation_bound`, `dag_node_perturbation_bound`, and/or `aggregated_margin_lower_bound_under_perturbation` to show:
   posterior-averaged empirical loss ≤ deterministic empirical loss + perturbation penalty.
2. Compute or bound `KL(Q||P)` for Gaussian posterior/prior pairs.
3. Plug these into McAllester or Catoni to derive an explicit neural PAC-Bayes bound.

Why this matters:
- It turns an abstract theorem into a usable certified bound for architectures already present in the catalog.
- It creates a reusable theorem schema: perturbation stability + KL complexity ⇒ generalization.

**Recommended order:** A → C → B.  
Get the finitary McAllester theorem first, then the Gaussian/perturbation instantiation, then return for Catoni via Donsker–Varadhan if needed.

---

## Cross-Domain Connections You Must Exploit

### Information Geometry
PAC-Bayes is not just a learning bound; it is a geometry of posterior movement away from prior belief. The KL term is a path-energy. Connect this explicitly to the geometric intuition behind `padic_geodesic_tight_bound`. Even if the p-adic theorem is not directly reusable, the analogy can motivate a generalized divergence geometry library.

### Statistical Mechanics
Catoni/Gibbs posteriors are free-energy minimizers:
\[
Q^\star(d\theta) \propto P(d\theta)\exp(-\lambda \hat L(\theta)).
\]
This is a formal bridge to partition functions, entropy, and variational principles. If you can prove the variational characterization in Lean, you open the door to thermodynamic interpretations of learning.

### Robustness and Margin Theory
Use `aggregated_margin_lower_bound_under_perturbation` to connect PAC-Bayes posterior averaging to robust margin preservation. This suggests a future theorem: robust margins imply small posterior Gibbs risk under structured perturbations.

### Quantum / Max-Entropy Perspectives
`max_entropy_linear_bound` suggests priors as maximum-entropy objects under moment constraints. This ties PAC-Bayes to Jaynes-style inference and potentially to quantum-inspired variational formulations already emerging in the catalog.

### Asymptotic Statistics
The asymptotic tightness theorem is a statement about the *sharpness* of certified learning bounds, not just their existence. This is what elevates the work beyond formal bookkeeping.

---

## Concrete Intermediate Lemmas

You should likely prove several of these before the headline theorems.

```lean
theorem kl_nonneg ...
theorem kl_zero_iff ...
theorem bernoulli_kl_nonneg ...
theorem change_of_measure_ineq ...
theorem log_mgf_empirical_loss_le ...
theorem gibbs_risk_empirical_le_of_pointwise_le ...
theorem gaussian_shift_kl_eq ...
theorem gaussian_shift_kl_le_isotropic ...
theorem posterior_risk_le_deterministic_risk_plus_perturbation ...
theorem complexity_scales_as_d_over_n ...
```

If Gaussian measure formalization is too difficult in full generality, prove a discrete Gaussian-grid surrogate or a deterministic quadratic complexity theorem first, then abstract the KL term as an axiomatically computed quantity.

---

## Lean 4 Formalization Guidance

Use concrete types aggressively.

- For samples: `S : Fin n → α`
- For parameters: `Fin d → ℝ`
- For finite hypothesis classes, use `PMF`.
- For asymptotics, use `Filter.atTop`.
- For norms in finite dimensions, start with `∑ i, (w i)^2` rather than abstract inner product spaces unless Mathlib support is clearly sufficient.

If measure theory becomes a wall, stage the project:

1. **Phase I:** finite hypothesis class PAC-Bayes over `PMF`.
2. **Phase II:** finite-dimensional Gaussian-shift complexity as a standalone theorem.
3. **Phase III:** posterior perturbation application theorem for predictors `Fin d → ℝ → ...`.
4. **Phase IV:** asymptotic rate theorem.

This staged approach still yields genuine theorems.

---

## What Would Count as a Breakthrough Here

A successful cycle would produce at least one theorem from each of the following categories:

1. **Foundational theorem**
   - a certified McAllester or Catoni PAC-Bayes inequality in Lean.

2. **Bridge theorem**
   - a theorem connecting perturbation bounds from the catalog to posterior Gibbs risk.

3. **Complexity theorem**
   - an explicit KL formula or upper bound for Gaussian shift priors/posteriors.

4. **Asymptotic theorem**
   - an `O(d/n)` upper bound, ideally with a matching lower bound, for linear classifier PAC-Bayes complexity.

That combination would not be an incremental extension. It would create a formal PAC-Bayes platform.

---

## Application Keywords

PAC-Bayes, Catoni bound, McAllester bound, KL divergence, Donsker–Varadhan, Gibbs posterior, Gaussian perturbation prior, neural network generalization, margin robustness, information geometry, variational inference, statistical mechanics, asymptotic tightness, linear classifiers, certified generalization, posterior stability, entropy regularization.

---

## Deliverables

Required:
- Lean 4 files with theorems and supporting definitions.
- `FUTURE_DIRECTIONS.md`

Optional:
- `ARTICLE.md`
- `RESEARCH_PAPER.md`
- `demo.py`
- `diagram.svg`

### Critical Requirement: FUTURE_DIRECTIONS.md

You must produce a structured `FUTURE_DIRECTIONS.md` with **3–5 concrete breakthrough-level next steps**, each including:
- precise theorem statement,
- Lean-facing formalization target,
- proof strategy,
- cross-domain connection.

Examples of strong future directions:
- Donsker–Varadhan variational principle for general measurable spaces,
- PAC-Bayes bounds for margin losses under tropical perturbation certificates,
- Gibbs posterior free-energy minimization for transformer-like architectures,
- data-dependent priors with formal differential privacy constraints,
- PAC-Bayes mutual information bounds connecting to information bottleneck theory.

---

## Team Directive

Create a research team to conduct the cycle in parallel:

- **Foundation team:** definitions of risks, KL, bounded-loss concentration.
- **Variational team:** change-of-measure, Donsker–Varadhan, Catoni machinery.
- **Neural bridge team:** perturbation catalog integration and Gaussian posterior theorem.
- **Asymptotics team:** `d/n` rate and lower-bound architecture.
- **Verification team:** minimize sorry, simplify hypotheses, refactor reusable lemmas.

Run experiments, validate statements, update the knowledge base, and iterate forever.

---

## Non-Negotiable Standard

Do not stop at a vague formalization skeleton. Prove at least one explicit PAC-Bayes theorem with exact constants, one Gaussian KL theorem, and one bridge theorem to perturbation robustness. If a fully measure-theoretic proof stalls, retreat to a finite/discrete theorem and make it airtight. That still advances the frontier if the architecture is right.

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
