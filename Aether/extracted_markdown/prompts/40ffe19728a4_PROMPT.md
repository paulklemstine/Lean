## Assignment: Precision

Prove new, non-trivial theorems. Build on catalog theorems. Minimize sorry.

### Mode
prove

### Research Direction
Quantify the tropical approximation at operational temperatures: make precise, in certified Lean 4 form, how the finite-temperature log-sum-exp semiring converges to the tropical max-plus semiring, with explicit uniform error bounds, stability under composition, and matrix-level spectral consequences.

This should not be treated as a soft analytic estimate. The goal is to build a formal bridge between:
- tropical algebra,
- statistical mechanics / free energy,
- smooth optimization,
- and tropical spectral theory.

The breakthrough is to show that “temperature” is not just a heuristic smoothing parameter, but a mathematically controlled deformation from classical analytic structures to tropical ones, with quantitative guarantees usable in downstream formalized mathematics.

## Mathematical Framing

For inverse temperature parameter `β > 0`, define the soft tropical addition
\[
x \oplus_\beta y := \frac{1}{\beta}\log(\exp(\beta x)+\exp(\beta y)).
\]
As `β → ∞`, this converges to `max x y`. The first target is to formalize the exact two-sided estimate
\[
\max(x,y) \le x \oplus_\beta y \le \max(x,y) + \frac{\log 2}{\beta},
\]
and then lift this scalar control to finite sums
\[
\operatorname{LSE}_\beta(f) := \frac{1}{\beta}\log\!\left(\sum_{i\in s} e^{\beta f(i)}\right),
\]
where the sharp error is governed by the logarithm of the support size:
\[
\max_{i\in s} f(i) \le \operatorname{LSE}_\beta(f)
\le \max_{i\in s} f(i) + \frac{\log |s|}{\beta}.
\]

This is the operational-temperature law for tropicalization. It says finite temperature introduces an entropic correction of size `log(cardinality)/β`. That correction is the exact formal analogue of free energy = energy + entropy/β, and this is where the cross-domain significance begins.

The second target is compositional: if a tropical expression is built from finitely many soft-max layers, the total deviation from the tropical expression is bounded by an explicit sum of local entropy terms. This opens a route to certifiable approximation theory for tropicalized networks, dynamic programming, and spectral optimization.

The third target is matrix/spectral: if one replaces tropical matrix products / path maxima by finite-temperature log-sum-exp aggregation, derive a quantitative bound showing convergence of the finite-temperature operator to the tropical operator in sup norm, and connect this to the existing `tropical_spectral_bound`.

## Precise Theorem Targets

You should aim to formalize at least three theorem families.

### Theorem A: Binary finite-temperature tropical approximation

Mathematical statement:
For all `β > 0` and all `x y : ℝ`,
\[
\max x y \le \frac{1}{\beta}\log(\exp(\beta x)+\exp(\beta y))
\le \max x y + \frac{\log 2}{\beta}.
\]

Suggested Lean 4 type signature:
```lean
theorem softmax2_max_bounds
    {β x y : ℝ} (hβ : 0 < β) :
    max x y
      ≤ Real.log (Real.exp (β * x) + Real.exp (β * y)) / β
    ∧
    Real.log (Real.exp (β * x) + Real.exp (β * y)) / β
      ≤ max x y + Real.log 2 / β
```

A more algebraically convenient variant:
```lean
theorem softmax2_max_bounds'
    {β x y : ℝ} (hβ : 0 < β) :
    max x y
      ≤ (1 / β) * Real.log (Real.exp (β * x) + Real.exp (β * y))
    ∧
    (1 / β) * Real.log (Real.exp (β * x) + Real.exp (β * y))
      ≤ max x y + (1 / β) * Real.log 2
```

### Theorem B: Finset log-sum-exp versus tropical maximum

Let `s : Finset α` with decidable equality and `f : α → ℝ`. For `s.Nonempty`,
\[
\max_{i\in s} f(i)
\le \frac{1}{\beta}\log\Big(\sum_{i\in s} e^{\beta f(i)}\Big)
\le \max_{i\in s} f(i) + \frac{\log(s.card)}{\beta}.
\]

Suggested Lean 4 type signature:
```lean
theorem finset_lse_max_bounds
    {α : Type} [DecidableEq α]
    (s : Finset α) (f : α → ℝ) {β : ℝ}
    (hβ : 0 < β) (hs : s.Nonempty) :
    s.sup' hs f
      ≤ Real.log (∑ i in s, Real.exp (β * f i)) / β
    ∧
    Real.log (∑ i in s, Real.exp (β * f i)) / β
      ≤ s.sup' hs f + Real.log s.card / β
```

If `Finset.sup'` over `ℝ` is awkward due to order structure/API friction, define:
```lean
def finsetMax (s : Finset α) (hs : s.Nonempty) (f : α → ℝ) : ℝ := s.sup' hs f
```
or work via a witness `m` satisfying
```lean
(∀ i ∈ s, f i ≤ m) ∧ (∃ i ∈ s, m = f i)
```
and prove the bound in that abstract form first.

### Theorem C: Uniform operator approximation for finite-temperature tropical matrix action

For `A : Fin n → Fin n → ℝ` and `x : Fin n → ℝ`, define
\[
(T_A x)(i) := \max_j (A_{ij}+x_j),
\qquad
(T_{A,\beta}x)(i) := \frac{1}{\beta}\log\sum_j e^{\beta(A_{ij}+x_j)}.
\]
Then for every `i`,
\[
(T_A x)(i) \le (T_{A,\beta}x)(i)
\le (T_A x)(i) + \frac{\log n}{\beta},
\]
hence
\[
\|T_{A,\beta}x - T_A x\|_\infty \le \frac{\log n}{\beta}.
\]

Suggested Lean 4 type signature:
```lean
theorem tropical_matrix_soft_approx
    {n : ℕ} (hn : 0 < n)
    (A : Fin n → Fin n → ℝ) (x : Fin n → ℝ) {β : ℝ}
    (hβ : 0 < β) :
    ∀ i : Fin n,
      (Finset.univ.sup' (Finset.univ_nonempty) (fun j => A i j + x j))
        ≤ Real.log (∑ j : Fin n, Real.exp (β * (A i j + x j))) / β
      ∧
      Real.log (∑ j : Fin n, Real.exp (β * (A i j + x j))) / β
        ≤ (Finset.univ.sup' (Finset.univ_nonempty) (fun j => A i j + x j))
          + Real.log n / β
```

A norm version is even better if convenient:
```lean
theorem tropical_matrix_soft_supnorm_bound
    {n : ℕ} (hn : 0 < n)
    (A : Fin n → Fin n → ℝ) (x : Fin n → ℝ) {β : ℝ}
    (hβ : 0 < β) :
    ‖fun i => Real.log (∑ j : Fin n, Real.exp (β * (A i j + x j))) / β
          - (Finset.univ.sup' Finset.univ_nonempty (fun j => A i j + x j))‖∞
      ≤ Real.log n / β
```
If the norm API is too expensive, prove the pointwise theorem and record the sup-norm corollary in `FUTURE_DIRECTIONS.md`.

## How to Build on Existing Verified Theorems

1. `tropical_mirror_theorem : theorem tropical_mirror_theorem (a : ℝ) : max a a = a`
   Use this as the degenerate consistency check for the softmax theorem when `x = y`. In that case,
   \[
   \frac{1}{\beta}\log(2e^{\beta a}) = a + \frac{\log 2}{\beta},
   \]
   so the upper bound is attained exactly. This is not just a toy case: it identifies the sharpness of the entropy correction term.

2. `tropical_spectral_bound`
   Use this as the tropical endpoint theorem. Your finite-temperature matrix operator theorem should be explicitly framed as a quantitative deformation toward the tropical spectral regime. The new theorem should say: the finite-temperature operator lies in a `log n / β` tube around the tropical one, so any spectral or fixed-point estimate for the tropical operator becomes asymptotically transferable.

3. `tropical_young_ineq`
   This can serve as a variational lens. Log-sum-exp is the Legendre dual regularization of max by Shannon entropy. Even if you do not fully formalize convex duality now, cite `tropical_young_ineq` as the seed for a later entropy-duality theorem:
   \[
   \operatorname{LSE}_\beta(z_1,\dots,z_n)
   =
   \sup_{p \in \Delta_n}
   \left(\sum_i p_i z_i + \frac{1}{\beta}H(p)\right).
   \]
   This is the real conceptual bridge: tropical max is zero-temperature optimization; log-sum-exp is positive-temperature free energy.

## Proof Strategy Architecture

### Strategy A: Direct factorization around the maximum
Most promising for Theorems A and B.

Step 1:
Let `m = max x y` in the binary case, or `m = s.sup' hs f` in the finset case. Factor:
\[
\sum_i e^{\beta f(i)} = e^{\beta m}\sum_i e^{\beta(f(i)-m)}.
\]

Step 2:
Since `f(i) - m ≤ 0`, each factor satisfies `e^{β(f(i)-m)} ≤ 1`, while at least one term equals `1` because the maximum is attained on a finite set. Therefore:
\[
1 \le \sum_i e^{\beta(f(i)-m)} \le |s|.
\]

Step 3:
Apply `Real.log`, use monotonicity, and divide by positive `β`:
\[
m \le \frac{1}{\beta}\log\sum_i e^{\beta f(i)} \le m + \frac{\log|s|}{\beta}.
\]

Why this is best:
It is elementary, sharp, and aligns perfectly with finite-set APIs in Lean. It also gives the exact entropy correction constant without any asymptotic machinery.

### Strategy B: Convex-analytic / variational free-energy proof
Most visionary; may be partially formalized or deferred.

Step 1:
Express log-sum-exp as the Fenchel dual of negative entropy:
\[
\frac{1}{\beta}\log\sum_i e^{\beta z_i}
=
\sup_{p\in\Delta}
\left(\sum_i p_i z_i + \frac{1}{\beta}H(p)\right).
\]

Step 2:
Bound entropy:
\[
0 \le H(p) \le \log n.
\]

Step 3:
Since `sup_p ∑ p_i z_i = max_i z_i`, the result follows immediately.

Why it matters:
This proof reveals the theorem as a free-energy principle, not merely an exponential estimate. It connects directly to statistical mechanics, mirror descent, and information geometry. Even if full formalization is deferred, this perspective should shape your definitions and theorem naming.

### Strategy C: Induction on `Finset.card`
Useful if API friction blocks `sup'` factorization.

Step 1:
Prove the empty/nonempty decomposition carefully; nonempty is the main case.

Step 2:
For insertion `insert a s`, compare
\[
\log(e^{\beta f(a)} + \sum_{i\in s} e^{\beta f(i)})
\]
with the binary softmax of `f a` and the previous log-sum-exp over `s`.

Step 3:
Use Theorem A recursively plus cardinal arithmetic to control the accumulated error.

Why this helps:
This route may interact better with existing `Finset` lemmas if direct maximum-attainment lemmas are awkward. It also naturally yields compositional error propagation.

## Cross-Domain Connections

### Statistical mechanics
`LSE_β` is free energy; tropical max is zero-temperature ground-state energy. Your theorem is a formal low-temperature asymptotic with explicit entropy correction. This opens a rigorous path from tropical geometry to thermodynamic limits.

### Optimization and machine learning
Softmax is the smooth approximation to argmax/max used throughout optimization and deep learning. A formal theorem in Lean gives certified error bars for replacing smooth inference with tropical inference, potentially enabling verified robustness and verified dynamic programming approximations.

### Information theory
The error term `log n / β` is an entropy budget. This is the finite-state analogue of data compression / Gibbs variational principles. It suggests future formalization of tropical mutual information and entropy-regularized control.

### Spectral theory and control
Tropical matrix actions model longest-path / deterministic Bellman operators. Finite-temperature soft operators model risk-sensitive or entropy-regularized control. Quantitative convergence theorems would bridge deterministic tropical control and stochastic control.

### Mirror symmetry / algebraic degeneration
The catalog’s `tropical_mirror_theorem` hints at degeneration phenomena. Finite-temperature tropicalization can be framed as a one-parameter analytic degeneration, potentially linking tropical mirror heuristics with controlled analytic deformations.

## Application Keywords
tropicalization, log-sum-exp, softmax approximation, zero-temperature limit, free energy, entropy regularization, tropical spectral theory, Bellman operators, risk-sensitive control, convex duality, information geometry, thermodynamic formalism, verified optimization, formal asymptotics

## Concrete Lean Guidance

Define reusable objects early:
```lean
def softmax2 (β x y : ℝ) : ℝ :=
  Real.log (Real.exp (β * x) + Real.exp (β * y)) / β

def finsetLSE {α : Type} [DecidableEq α] (β : ℝ) (s : Finset α) (f : α → ℝ) : ℝ :=
  Real.log (∑ i in s, Real.exp (β * f i)) / β
```

Potential helper lemmas:
```lean
theorem exp_beta_max_factor
    {α : Type} [DecidableEq α]
    (s : Finset α) (f : α → ℝ) (m β : ℝ) :
    (∑ i in s, Real.exp (β * f i))
      = Real.exp (β * m) * ∑ i in s, Real.exp (β * (f i - m))
```
and
```lean
theorem finset_exp_shift_upper
    {α : Type} [DecidableEq α]
    (s : Finset α) (f : α → ℝ) {m β : ℝ}
    (hβ : 0 ≤ β)
    (hm : ∀ i ∈ s, f i ≤ m) :
    ∑ i in s, Real.exp (β * (f i - m)) ≤ s.card
```

You may need standard real-analysis facts:
- `Real.exp_pos`
- monotonicity of `Real.log`
- `Real.log_mul` under positivity
- `Real.log_le_log`
- `div_le_div_of_nonneg_right` / `le_div_iff`
- positivity of finite sums of exponentials

For `s.sup' hs f`, extract:
- attainment: some `i ∈ s` with `f i = s.sup' hs f`
- domination: for all `i ∈ s`, `f i ≤ s.sup' hs f`

If this API is cumbersome, prove an abstract theorem parameterized by a chosen `m`:
```lean
theorem finset_lse_bounds_of_mem_top
    {α : Type} [DecidableEq α]
    (s : Finset α) (f : α → ℝ) {β m : ℝ}
    (hβ : 0 < β)
    (hupper : ∀ i ∈ s, f i ≤ m)
    (hmem : ∃ i ∈ s, f i = m) :
    m ≤ finsetLSE β s f ∧ finsetLSE β s f ≤ m + Real.log s.card / β
```
This may be the cleanest formal route; the `sup'` theorem then becomes a corollary.

## What Would Make This a Breakthrough

If you prove only a scalar inequality, this is useful. If you prove the finset theorem and matrix operator theorem with clean reusable definitions, you create a foundational library for positive-temperature tropical mathematics.

That would open:
- entropy-regularized tropical linear algebra,
- formal free-energy methods,
- certified approximations for tropical neural and control architectures,
- and a new bridge between tropical geometry and statistical mechanics.

The key is not the inequality alone. The key is establishing a formal language in Lean where tropical mathematics is the zero-temperature boundary of a quantitatively controlled analytic family.

## Deliverables

1. Lean 4 code proving at least Theorem A and one of Theorem B or C.
2. Clean definitions for softmax/log-sum-exp operators.
3. Minimal sorry usage; if blocked, isolate blockers into helper lemmas with exact statements.
4. A structured `FUTURE_DIRECTIONS.md`.

## Required FUTURE_DIRECTIONS.md

You must produce `FUTURE_DIRECTIONS.md` with 3–5 concrete next steps, each including:
- exact theorem statement,
- likely Lean definitions,
- proof strategy,
- cross-domain significance.

The next steps should be breakthrough-level, such as:
1. Gibbs variational principle for finite `Finset` in Lean.
2. Entropy-regularized Bellman fixed-point convergence to tropical eigenvectors.
3. Tropical Laplace principle / large deviations for finite state spaces.
4. Certified error propagation for multilayer softmax-to-tropical networks.
5. Finite-temperature deformation of `tropical_spectral_bound`.

Be bold: do not merely smooth tropical algebra; formalize temperature as a new mathematical axis connecting optimization, entropy, and tropical structure.

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
