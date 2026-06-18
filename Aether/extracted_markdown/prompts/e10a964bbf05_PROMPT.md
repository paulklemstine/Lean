## Mode: prove

## Breakthrough Objective

Prove the Gibbs–variational principle for finite log-sum-exp in Lean 4, in a form strong enough to become the **convex-analytic nucleus of tropicalization, statistical mechanics, attention mechanisms, and entropy-regularized optimization**.

This is not merely an inequality. It is the exact theorem identifying `τ * log ∑ exp(xᵢ/τ)` as the **Legendre–Fenchel dual** of negative Shannon entropy on the probability simplex. Once formalized, this becomes a reusable engine for:

- softmax-as-optimizer theorems,
- entropy-regularized argmax / tropical limit results,
- variational formulations of partition functions,
- certified bounds for attention and energy-based models,
- future formal bridges between convex analysis, information theory, and tropical geometry.

The theorem should be stated and proved with a mathematically correct Lean-facing formulation. The displayed target using `⨆ (p) (hp), ...` is visionary but likely too raw for direct Mathlib execution because the supremum is over a constrained family. You should introduce a predicate or subtype for the simplex and then prove the exact equality there.

---

## Precise Theorem Statement

### Recommended formal target

Define the simplex and entropy functional first:

```lean
def IsProbVec {n : ℕ} (p : Fin n → ℝ) : Prop :=
  (∀ i, 0 ≤ p i) ∧ (∑ i, p i) = 1

def shannonEntropyTerm {n : ℕ} (p : Fin n → ℝ) : ℝ :=
  - ∑ i, if p i = 0 then 0 else p i * Real.log (p i)

def freeEnergyObj {n : ℕ} (τ : ℝ) (x p : Fin n → ℝ) : ℝ :=
  ∑ i, p i * x i + τ * shannonEntropyTerm p
```

Then prove:

```lean
theorem lse_variational_formula
    {n : ℕ} (hn : 0 < n) (τ : ℝ) (hτ : 0 < τ) (x : Fin n → ℝ) :
    τ * Real.log (∑ i : Fin n, Real.exp (x i / τ)) =
      sSup {r : ℝ | ∃ p : Fin n → ℝ, IsProbVec p ∧ r = freeEnergyObj τ x p}
```

This is the cleanest exact statement.

### Stronger attainment theorem

The real breakthrough is to prove not just the supremum identity, but the optimizer:

```lean
def softmaxProb {n : ℕ} (τ : ℝ) (x : Fin n → ℝ) : Fin n → ℝ :=
  fun i => Real.exp (x i / τ) / (∑ j : Fin n, Real.exp (x j / τ))

theorem softmaxProb_isProbVec
    {n : ℕ} (hn : 0 < n) (τ : ℝ) (hτ : 0 < τ) (x : Fin n → ℝ) :
    IsProbVec (softmaxProb τ x)

theorem lse_variational_formula_attained
    {n : ℕ} (hn : 0 < n) (τ : ℝ) (hτ : 0 < τ) (x : Fin n → ℝ) :
    let p := softmaxProb τ x
    IsProbVec p ∧
    freeEnergyObj τ x p = τ * Real.log (∑ i : Fin n, Real.exp (x i / τ))
```

And ideally the inequality half in reusable form:

```lean
theorem freeEnergy_le_lse
    {n : ℕ} (τ : ℝ) (hτ : 0 < τ) (x p : Fin n → ℝ)
    (hp : IsProbVec p) :
    freeEnergyObj τ x p ≤ τ * Real.log (∑ i : Fin n, Real.exp (x i / τ))
```

This decomposition is likely the best route to a fully formal proof.

---

## Why This Is a Breakthrough

This theorem is the finite-dimensional gateway between four worlds that are usually formalized separately:

1. **Convex analysis**: log-sum-exp is the convex conjugate of negative entropy.
2. **Information theory**: the proof is a KL-divergence nonnegativity argument.
3. **Statistical mechanics**: `τ log Z` is free energy, with Gibbs measure as minimizer/maximizer depending on sign convention.
4. **Tropical mathematics / optimization**: as `τ → 0⁺`, log-sum-exp tends to max, so this theorem is the dequantization bridge from smooth to tropical optimization.

Formalizing this in Lean creates infrastructure for an entire research program: entropy-regularized control, Sinkhorn-type duality, variational attention, and tropical thermodynamics.

---

## Core Mathematical Insight

For
\[
Z := \sum_{i : \mathrm{Fin}\ n} e^{x_i/\tau},
\qquad
q_i := \frac{e^{x_i/\tau}}{Z},
\]
one has for any probability vector `p`:
\[
\sum_i p_i x_i + \tau\Big(-\sum_i p_i \log p_i\Big)
= \tau \log Z - \tau \sum_i p_i \log\!\left(\frac{p_i}{q_i}\right).
\]
Thus the objective equals `τ log Z - τ * KL(p || q)`, hence is bounded above by `τ log Z`, with equality at `p = q`.

This is the mathematically canonical proof. The main formal challenge is handling zero coordinates safely. Your entropy term with
```lean
if p i = 0 then 0 else p i * Real.log (p i)
```
is exactly the right finite formalization.

---

## Proof Strategy A: KL-Divergence Route (Most Promising)

This is the best path. It is structurally modular and gives both inequality and attainment.

### Step 1: Define Gibbs / softmax witness
Define
```lean
Z := ∑ j : Fin n, Real.exp (x j / τ)
q i := Real.exp (x i / τ) / Z
```
and prove:
- `0 < Z` using `hn` and positivity of `Real.exp`,
- `0 ≤ q i`,
- `∑ i, q i = 1`.

The positivity lemma here is elementary and should be reusable elsewhere.

### Step 2: Prove the exact decomposition
For arbitrary `p` with `IsProbVec p`, show
\[
freeEnergyObj τ x p
=
τ * Real.log Z - τ * \sum_i \bigl(if p i = 0 then 0 else p i * Real.log ((p i)/(q i))\bigr).
\]
To get this, use:
- `x i = τ * Real.log (Real.exp (x i / τ))`,
- then `Real.log (exp (x i / τ) / Z) = x i / τ - log Z`,
- rearrange finite sums using `∑ i p i = 1`.

This is where `exp_log_roundtrip` may be useful if it packages positivity-sensitive `exp/log` simplification. Even if not directly applicable, it signals that the catalog already contains log-exp normalization reasoning.

### Step 3: Prove nonnegativity of KL term
Show
\[
0 \le \sum_i \bigl(if p i = 0 then 0 else p i * Real.log ((p i)/(q i))\bigr).
\]
There are two possible subroutes:
- derive from Jensen / log inequality,
- or prove the scalar inequality `u * log(u/v) ≥ u - v` for `u ≥ 0`, `v > 0`, sum over `i`, and use `∑ p = ∑ q = 1`.

The scalar inequality route is often easier in Lean because it reduces the global argument to one-variable real analysis. It yields Gibbs inequality in finite form.

Then conclude:
- `freeEnergyObj τ x p ≤ τ * log Z`,
- equality for `p = q`,
- hence the supremum formula.

Why this strategy is most promising: it avoids compactness/existence machinery and directly constructs the optimizer.

---

## Proof Strategy B: Jensen / Concavity of Log

A more conceptual proof, potentially elegant if Mathlib has the right concavity tools.

### Step 1
For any probability vector `p`, rewrite:
\[
\log \sum_i e^{x_i/\tau}
=
\log \sum_i p_i \frac{e^{x_i/\tau}}{p_i}
\]
with the convention that zero-weight terms vanish.

### Step 2
Apply concavity of `log`:
\[
\log \sum_i p_i y_i \ge \sum_i p_i \log y_i
\]
for `y_i > 0`, where `y_i = e^{x_i/\tau}/p_i` on the support of `p`.

### Step 3
Multiply by `τ` and rearrange to get:
\[
τ \log \sum_i e^{x_i/\tau}
\ge
\sum_i p_i x_i - τ \sum_i p_i \log p_i.
\]

This route is beautiful, but may be more painful in Lean due to the need for a weighted Jensen theorem over finite families with side conditions and zero-coordinate conventions.

---

## Proof Strategy C: Convex Conjugacy / Optimization on the Simplex

This is the highest-level route and most revolutionary conceptually, but likely the hardest to close with minimal sorry.

### Step 1
Show the objective in `p` is strictly concave on the simplex for `τ > 0`.

### Step 2
Use Lagrange multiplier conditions under the affine constraint `∑ p = 1`:
\[
x_i - \tau(\log p_i + 1) = \lambda,
\]
hence
\[
p_i \propto e^{x_i/\tau}.
\]

### Step 3
Normalize and evaluate the optimum.

This route could become a formal convex-analysis library seed, but unless Mathlib already has the exact finite-dimensional differentiability apparatus you need, it is riskier than Strategy A.

---

## Lean Architecture Recommendations

You should not attack the final theorem monolithically. Build a reusable mini-library.

### Suggested definitions
```lean
def IsProbVec {n : ℕ} (p : Fin n → ℝ) : Prop := ...
def entropySummand (a : ℝ) : ℝ := if a = 0 then 0 else -a * Real.log a
def shannonEntropyTerm {n : ℕ} (p : Fin n → ℝ) : ℝ := ∑ i, entropySummand (p i)
def freeEnergyObj {n : ℕ} (τ : ℝ) (x p : Fin n → ℝ) : ℝ := ...
def partitionFun {n : ℕ} (τ : ℝ) (x : Fin n → ℝ) : ℝ := ∑ i, Real.exp (x i / τ)
def softmaxProb {n : ℕ} (τ : ℝ) (x : Fin n → ℝ) : Fin n → ℝ := ...
```

### Suggested theorem ladder
1. `partitionFun_pos`
2. `softmaxProb_nonneg`
3. `softmaxProb_sum`
4. `softmaxProb_isProbVec`
5. `freeEnergy_le_lse`
6. `freeEnergy_eq_lse_at_softmax`
7. `lse_variational_formula_attained`
8. `lse_variational_formula`

If the `sSup` target becomes awkward, prove first the pair:
- upper bound for all feasible `p`,
- exact equality for one feasible `p`.

Then discharge the supremum statement via `le_csSup` / `csSup_le` style lemmas or a set-based `sSup` API.

---

## Mathlib-Sensitive Technical Issues

You will need to manage these carefully:

- `Fin 0` is empty, so `hn : 0 < n` is essential for positivity of the partition function.
- `Real.log` requires positivity hypotheses when using simplification lemmas.
- The entropy summand at `0` must be handled by `if`.
- For `q i`, strict positivity follows from positivity of `exp` and `Z`.
- Rearranging sums over `Fin n` is straightforward with `Finset`.
- Expect to use `field_simp` only after proving denominator positivity.

A particularly useful auxiliary lemma would be:

```lean
lemma sum_prob_mul_const
    {n : ℕ} {p : Fin n → ℝ} (hp : IsProbVec p) (c : ℝ) :
    (∑ i, p i * c) = c
```

and also:

```lean
lemma log_softmax
    {n : ℕ} (hn : 0 < n) (τ : ℝ) (hτ : 0 < τ) (x : Fin n → ℝ) (i : Fin n) :
    Real.log (softmaxProb τ x i) =
      x i / τ - Real.log (partitionFun τ x)
```

after proving positivity.

---

## Cross-Domain Connections You Must Exploit

### 1. Information Theory
This theorem is the finite Gibbs variational principle, equivalently the variational representation of the cumulant generating function. It is the formal seed for:
- KL divergence nonnegativity,
- data-processing ambitions,
- entropy maximization under energy constraints.

### 2. Tropical Geometry / Idempotent Analysis
As `τ → 0⁺`,
\[
τ \log \sum_i e^{x_i/\tau} \to \max_i x_i.
\]
Your theorem is therefore a **dequantization identity**: tropical max emerges as zero-temperature free energy. This can launch formal tropical–probabilistic duality.

### 3. Machine Learning / Attention
Softmax attention is exactly the optimizer of a linear score plus entropy regularization. This theorem gives a formal explanation of why softmax is the canonical smooth argmax. It directly connects to the catalog’s attention/compression theorem:
- `compression_theorem` suggests an avenue to reinterpret attention compression through entropy-regularized variational selection.
This is not yet a direct dependency, but the conceptual bridge is powerful.

### 4. Statistical Mechanics
`Z = ∑ exp(x_i/τ)` is the partition function, and the theorem says free energy equals expected energy plus entropy at equilibrium. This opens formal thermodynamic reasoning in finite systems.

### 5. Arithmetic / Complexity Log Bounds
The catalog contains several `log_*` theorems (`heightCapacity_log_bound`, `log_convergence_bound`, `log_depth_lower_bound`). Even if not directly used in proof, your result provides a new universal variational interpretation of logarithmic complexity quantities, potentially enabling entropy-regularized lower bounds.

---

## Application Keywords

entropy regularization, Gibbs variational principle, softmax optimality, log-sum-exp duality, convex conjugacy, Shannon entropy, KL divergence, partition function, free energy, tropical limit, dequantization, attention mechanisms, energy-based models, Fenchel duality, statistical mechanics, information geometry

---

## Concrete Deliverables

1. A Lean file proving as much of the theorem ladder as possible, with priority on:
   - `softmaxProb_isProbVec`
   - `freeEnergy_le_lse`
   - `freeEnergy_eq_lse_at_softmax`
   - `lse_variational_formula`

2. Minimize sorry by splitting into scalar analytic lemmas and finite-sum algebra lemmas.

3. If the exact `sSup` theorem is too heavy in one pass, prove the attained-max formulation first:
   ```lean
   ∃ p, IsProbVec p ∧
     freeEnergyObj τ x p = τ * Real.log (partitionFun τ x) ∧
     ∀ q, IsProbVec q → freeEnergyObj τ x q ≤ freeEnergyObj τ x p
   ```
   This is mathematically equivalent and often easier to formalize.

4. Connect the result in comments or markdown to:
   - tropical max-plus limits,
   - variational softmax,
   - finite statistical mechanics.

---

## Recommended File / Structure

Create a new file along the lines of:

```text
Bridges/InformationTheoryConvexity/LogSumExpVariational.lean
```

with sections:
- `Simplex`
- `Entropy`
- `Softmax`
- `VariationalUpperBound`
- `Attainment`
- `SupremumFormulation`

If you discover missing real-analysis lemmas, isolate them in local helper sections rather than burying them inside the main proof.

---

## High-Value Intermediate Lemmas

These would be excellent formal assets even independently:

```lean
theorem gibbs_inequality_finite
    {n : ℕ} (p q : Fin n → ℝ)
    (hp : IsProbVec p) (hq_pos : ∀ i, 0 < q i) :
    0 ≤ ∑ i, if p i = 0 then 0 else p i * Real.log (p i / q i)

theorem softmax_characterizes_argmax_entropy_regularized
    {n : ℕ} (hn : 0 < n) (τ : ℝ) (hτ : 0 < τ) (x : Fin n → ℝ) :
    ∀ p, IsProbVec p →
      freeEnergyObj τ x p ≤ freeEnergyObj τ x (softmaxProb τ x)

theorem lse_eq_max_free_energy
    {n : ℕ} (hn : 0 < n) (τ : ℝ) (hτ : 0 < τ) (x : Fin n → ℝ) :
    τ * Real.log (partitionFun τ x) =
      freeEnergyObj τ x (softmaxProb τ x)
```

These are publishable-grade formal statements, not mere scaffolding.

---

## Strategic Advice on Existing Catalog Theorems

The catalog theorems are not directly on-point, but use them as stylistic and conceptual precedent for logarithmic reasoning:
- `exp_log_roundtrip` may help package positivity-sensitive exp/log simplifications.
- `log_convergence_bound`, `heightCapacity_log_bound`, and `log_depth_lower_bound` signal that logarithmic expressions are already part of the ecosystem; your theorem can become their variational backbone.
- `compression_theorem` creates a downstream bridge: attention can be reframed through entropy-regularized optimization, and this theorem is the formal mechanism.

Do not force unnatural dependencies. Better to build a pristine core theorem that later work can invoke.

---

## What Would Make This Field-Opening

If you can prove the variational formula together with optimizer attainment, you have effectively installed the first pillar of a formal **Lean thermodynamics / information-geometry / tropical-optimization bridge**.

The next cycle could then attack:
- zero-temperature limit to `max`,
- uniqueness of softmax optimizer,
- finite KL divergence and Pinsker-style inequalities,
- variational formulations of attention operators,
- entropy-regularized transport on finite spaces.

This is the kind of theorem that changes what formalized mathematics can express across disciplines.

---

## Required FUTURE_DIRECTIONS.md

Produce a structured `FUTURE_DIRECTIONS.md` with 3–5 concrete breakthrough next steps. Include items at this level of ambition:

1. **Tropical Zero-Temperature Limit**  
   Formalize:
   \[
   \lim_{\tau \to 0^+} \tau \log \sum_i e^{x_i/\tau} = \max_i x_i.
   \]
   Then derive entropy-regularized argmax convergence.

2. **Finite KL Divergence Theory in Lean**  
   Define KL divergence on finite probability vectors and prove nonnegativity, equality iff identical distributions, and Pinsker-type lower bounds.

3. **Softmax Attention as Variational Inference**  
   Show that attention weights solve an entropy-regularized linear maximization problem, connecting this theorem to the catalog attention/compression results.

4. **Fenchel Duality Library for Finite Convex Functions**  
   Generalize the log-sum-exp/entropy duality into a reusable finite-dimensional convex conjugacy framework.

5. **Statistical Mechanics Bridge**  
   Formalize finite free energy, Gibbs states, and variational equilibrium principles, making partition functions first-class objects in Lean.

Be specific, actionable, and theorem-oriented.

---

## Final Charge

Do not settle for a one-off inequality. Build the formal variational architecture. Prove the upper bound, construct the Gibbs witness, show attainment, and then package the supremum theorem cleanly. If necessary, invent the finite KL machinery yourself. This is the right theorem: exact, deep, cross-domain, and catalytic.

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

Research domain: Bridges
Research mode: prove
