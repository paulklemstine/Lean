Soli Deo Gloria

## Assignment: Direction 1: Probabilistic Stability — The 1/√n Law for Random Perturbations

**Mode:** `prove`

Prove a genuinely new probabilistic stability theorem for Lorentzian signatures under random symmetric perturbations, with a verified computational pipeline that tests the sharp exponent. This should not be a cosmetic probabilistic rewrite of deterministic perturbation bounds: the goal is to show that randomness changes the stability scale from order `1/n` to order `1/√n`, opening a probabilistic theory of Lorentzian cones analogous to random matrix universality.

Build explicitly on:

- `Catalog/Pythagorean/LorentzianSharpStability.lean`
  - especially the deterministic gap-based signature preservation results and any theorem in the lineage of `quadFormBound_of_entry_bound_sharp`
- `Catalog/Speculative/AutoResearch/LorentzianStability.lean`
  - especially Theorem 9 and its gap-preservation mechanism

Your target is to formalize a **probabilistic surrogate theorem** strong enough to imply a high-confidence signature preservation statement from an operator-norm estimate for random perturbations, and then to verify an algorithm that numerically tests the `α = 1/2` threshold.

## Core breakthrough target

The field-opening theorem is not “some random perturbations are okay.” It is:

> **Randomness buys a square-root improvement in stability scale for Lorentzian signature preservation.**

That is the conceptual leap. Deterministically, entrywise perturbations of size `δ` can accumulate linearly in dimension. Randomly, cancellation should reduce the relevant operator scale to `√n δ`. If this is formalized cleanly, it creates a new probabilistic stability theory for Lorentzian structures, with immediate consequences for randomized algorithms, noisy Hessian estimation, stochastic optimization, and random combinatorial models.

## Precise theorem targets

You should aim to prove at least the following three theorems in Lean 4, with substantial proofs using multi-step reasoning. If the full probability-theoretic infrastructure is too heavy, prove a rigorous **finite-sample deterministic-to-probabilistic transfer theorem** plus a verified sampling algorithm and a formally stated conjectural concentration theorem.

### New definition (MANDATORY)

Introduce a new concept capturing the probabilistic perturbation regime. For example:

```lean
/-- A symmetric perturbation matrix is `σ`-subWigner at scale `δ`
if it is symmetric and all upper-triangular entries are centered and bounded
in magnitude by `δ`, with variance proxy controlled by `σ^2`. -/
structure SubWignerSymmetricPerturbation (n : ℕ) where
  M : Matrix (Fin n) (Fin n) ℝ
  symm : M.IsSymm
  entry_bound : ∀ i j, |M i j| ≤ σ * δ
  centered_upper : Prop
  variance_proxy : Prop
```

If probability primitives are awkward, define a deterministic surrogate:

```lean
/-- A symmetric matrix is `randomScaleBounded` if its operator norm
obeys the probabilistic scaling predicted for random perturbations. -/
def RandomScaleBounded (M : Matrix (Fin n) (Fin n) ℝ) (δ C : ℝ) : Prop :=
  ‖M.toLinearMap‖ ≤ C * Real.sqrt n * δ
```

This is acceptable only if you then prove nontrivial consequences from it and pair it with a computational test validating that the property occurs empirically with high frequency.

### Theorem 1: Probabilistic surrogate implies signature preservation

This theorem is the formal hinge: once operator norm is below the spectral gap, signature is preserved.

**Mathematical statement**

Let `A` be a real symmetric matrix with Lorentzian signature `(1, n-1)` and spectral gap
\[
\mathrm{gap}(A) := \min\{ \lambda_+(A), -\lambda_2(A)\} > 0,
\]
where `λ_+(A)` is the unique positive eigenvalue and `λ_2(A)` is the largest nonpositive eigenvalue. If `E` is symmetric and
\[
\|E\|_{\mathrm{op}} < \mathrm{gap}(A),
\]
then `A + E` has the same Lorentzian signature.

**Lean 4 target signature**
```lean
theorem lorentzian_signature_preserved_of_opNorm_lt_gap
  {n : ℕ}
  (A E : Matrix (Fin n) (Fin n) ℝ)
  (hA_symm : A.IsSymm)
  (hE_symm : E.IsSymm)
  (hLor : HasLorentzianSignature A)
  (hgap : 0 < lorentzianGap A)
  (hsmall : ‖(E.toLinearMap : (Fin n → ℝ) →ₗ[ℝ] (Fin n → ℝ))‖ < lorentzianGap A) :
  HasLorentzianSignature (A + E)
```

If `HasLorentzianSignature` and `lorentzianGap` do not yet exist, define them carefully. This is a new foundational theorem and should be proved by combining spectral continuity / min-max style inequalities with the catalog’s deterministic sharp stability results.

### Theorem 2: Entrywise deterministic bound vs random-scale bound

Show the exact contrast between worst-case and random-scale regimes.

**Mathematical statement**

If `E` is symmetric with entrywise bound `|E_ij| ≤ δ`, then deterministically
\[
\|E\|_{\mathrm{op}} \le n \, \delta.
\]
If additionally `RandomScaleBounded E δ C`, then
\[
\|E\|_{\mathrm{op}} \le C \sqrt{n}\,\delta.
\]
Hence, whenever
\[
C \sqrt{n}\,\delta < \mathrm{gap}(A),
\]
the Lorentzian signature is preserved.

**Lean 4 target signature**
```lean
theorem opNorm_bound_of_entry_bound
  {n : ℕ}
  (E : Matrix (Fin n) (Fin n) ℝ)
  (hE_symm : E.IsSymm)
  (hentry : ∀ i j, |E i j| ≤ δ) :
  ‖(E.toLinearMap : (Fin n → ℝ) →ₗ[ℝ] (Fin n → ℝ))‖ ≤ (n : ℝ) * δ
```

and then

```lean
theorem lorentzian_signature_preserved_of_randomScaleBounded
  {n : ℕ}
  (A E : Matrix (Fin n) (Fin n) ℝ)
  (hA_symm : A.IsSymm)
  (hE_symm : E.IsSymm)
  (hLor : HasLorentzianSignature A)
  (hgap : 0 < lorentzianGap A)
  (hRand : RandomScaleBounded E δ C)
  (hsmall : C * Real.sqrt n * δ < lorentzianGap A) :
  HasLorentzianSignature (A + E)
```

This theorem makes the `1/√n` law precise inside Lean, even before proving a full matrix concentration theorem.

### Theorem 3: Dimension-threshold reformulation

Turn the above into the exact threshold statement that can drive experiments.

**Mathematical statement**

If `δ = K * ε / √n` and `K C < 1`, then any `RandomScaleBounded` perturbation at scale `δ` preserves Lorentzian signature whenever the gap is at least `ε`.

**Lean 4 target signature**
```lean
theorem one_div_sqrt_n_stability_law
  {n : ℕ}
  (A E : Matrix (Fin n) (Fin n) ℝ)
  (ε K C δ : ℝ)
  (hA_symm : A.IsSymm)
  (hE_symm : E.IsSymm)
  (hLor : HasLorentzianSignature A)
  (hgap : ε ≤ lorentzianGap A)
  (hε : 0 < ε)
  (hn : 0 < n)
  (hδ : δ = K * ε / Real.sqrt n)
  (hRand : RandomScaleBounded E δ C)
  (hKC : K * C < 1) :
  HasLorentzianSignature (A + E)
```

This is the exact theorem that expresses the research direction. If necessary, use inequalities and `field_simp` to rewrite the threshold carefully.

## Strong conjecture to formalize and test

State a falsifiable conjecture with explicit computational meaning:

```lean
/-- Conjecture: symmetric bounded mean-zero random perturbations satisfy
an operator-norm concentration at scale `√n * δ`, uniformly over dimension. -/
conjecture subWigner_opNorm_concentration
  (C c : ℝ) :
  ∀ ⦃n : ℕ⦄, ∀ (δ t : ℝ),
    0 ≤ δ → 0 ≤ t →
    ∀ (X : RandomVariable Ω (Matrix (Fin n) (Fin n) ℝ)),
      IsSubWignerAtScale X δ →
      ℙ (ω : Ω), ‖((X ω).toLinearMap : _ )‖ ≥ C * Real.sqrt n * δ + t
        ≤ Real.exp (-c * t^2 / δ^2)
```

If full probability is beyond current library convenience, still include this conjecture in comments and in `RESEARCH_PAPER.md`, and make `demo.py` test it numerically. The conjecture is falsifiable by observing whether the critical exponent stabilizes away from `1/2`.

## Proof strategy architecture

You must provide multiple proof avenues and pursue the most promising one.

### Strategy A: Gap perturbation via spectral norm + catalog transfer
1. Define `HasLorentzianSignature A` and `lorentzianGap A` using eigenvalue ordering for real symmetric matrices.
2. Use a Weyl-type perturbation inequality or an existing catalog theorem to show eigenvalues move by at most `‖E‖op`.
3. Deduce that if the perturbation norm is strictly below the gap, no eigenvalue crosses zero, so the count of positive/negative eigenvalues is preserved.

**Why this is most promising:** it isolates the probabilistic difficulty into a single norm estimate. Everything after that is deterministic and should align tightly with the existing catalog stability theorems.

### Strategy B: Quadratic form route using Lorentzian cone inequalities
1. Express Lorentzian signature through positivity on a one-dimensional cone direction and negativity on its orthogonal complement.
2. Bound the perturbation quadratic form:
   \[
   |x^\top E x| \le \|E\|_{\mathrm{op}} \|x\|^2.
   \]
3. Transfer the positive/negative coercivity bounds from `A` to `A + E` under the same gap condition.

**Why this is powerful:** it may avoid some spectral-ordering technicalities and connect more directly to the Pythagorean/Lorentzian catalog theorems, especially if those are already phrased in quadratic form language.

### Strategy C: Courant–Fischer min-max formalization
1. Define extremal eigenvalues of symmetric matrices via Rayleigh quotients.
2. Prove min-max perturbation inequalities directly.
3. Recover signature preservation by comparing the top positive Rayleigh quotient and the maximal quotient on codimension-1 subspaces.

**Why this is deepest but riskier:** mathematically elegant and self-contained, but formalization burden is likely much higher unless Mathlib already has enough min-max machinery exposed in usable form.

**Recommendation:** prioritize **Strategy A**, with **Strategy B** as fallback if spectral ordering APIs are awkward. Strategy C is ideal only if the relevant spectral theorem and min-max interfaces are already smooth in Mathlib.

## Required deep-proof content

Your file must contain **at least 3 nontrivial theorems**, and at least some proofs must use:
- induction
- `rcases`
- `by_contra`
- `field_simp`
- multi-step `calc`

Suggested places:
- prove `opNorm_bound_of_entry_bound` by expanding matrix-vector action and bounding row sums
- prove the threshold equivalence in `one_div_sqrt_n_stability_law` using `field_simp` and square-root positivity
- prove a cross-domain theorem relating random perturbation scale to a Lipschitz energy or partition-function Hessian bound

## Cross-domain connection theorem (MANDATORY)

You must include at least one theorem that links Lorentzian stability to another domain.

### Option 1: Statistical physics bridge
Interpret `A` as a Hessian of an energy landscape and `E` as random couplings. Prove that if the coupling noise is `RandomScaleBounded`, the system remains in the same one-unstable-mode phase.

Possible theorem:

```lean
theorem unique_unstable_mode_preserved_under_random_couplings
  {n : ℕ}
  (H J : Matrix (Fin n) (Fin n) ℝ)
  (hH_symm : H.IsSymm)
  (hJ_symm : J.IsSymm)
  (hphase : HasLorentzianSignature H)
  (hRand : RandomScaleBounded J δ C)
  (hsmall : C * Real.sqrt n * δ < lorentzianGap H) :
  HasLorentzianSignature (H + J)
```

This is mathematically the same theorem, but conceptually it bridges to disordered systems, spin glasses, and metastable energy landscapes.

### Option 2: High-dimensional optimization bridge
Interpret `A` as the Hessian at a strict saddle with one escape direction. Then random Hessian noise of size `ε/√n` preserves the strict-saddle geometry with high probability.

### Option 3: Random matrix universality bridge
Prove a theorem showing that any future concentration theorem of Wigner type automatically yields Lorentzian signature survival. This makes Lorentzian combinatorics a new application domain for random matrix theory.

## Application keywords

Include these explicitly in the written materials and theorem commentary:

- Lorentzian polynomials
- hyperbolic geometry
- random matrix theory
- matrix concentration
- Wigner universality
- strict saddles
- stochastic optimization
- noisy Hessians
- statistical physics
- spin glasses
- metastability
- randomized rounding
- MCMC
- spectral gap certification
- phase stability

## Computational deliverable: verified algorithm

You must produce a verified computational method, not just theorem statements.

### Algorithm target
Implement an algorithm that:
1. takes a symmetric Lorentzian matrix `A` with certified gap `ε`,
2. samples random symmetric perturbations `E(δ)`,
3. estimates the empirical survival probability
   \[
   p_n(\alpha) = \Pr[\text{signature}(A+E)=\text{signature}(A)]
   \quad \text{at } \delta = \epsilon / n^\alpha,
   \]
4. reports the empirical critical exponent.

The verified component should prove that:
- the sampling output is symmetric,
- the computed signature test is well-defined,
- if the sampled matrix satisfies the certified norm condition, the reported “survives” flag is mathematically sound.

If exact probability is hard to formalize, verify the **decision rule** rather than the whole distributional claim.

## `demo.py` requirements

Create `demo.py` that:
- generates model Hessians for `e_k`-type examples or synthetic Lorentzian matrices with known gap
- samples symmetric bounded mean-zero perturbations
- tests `α ∈ {0.4, 0.5, 0.6, 0.7}`
- tests `n ∈ {10, 50, 100, 500}`
- estimates survival probabilities over many trials
- plots survival probability vs `α`
- estimates the critical `α`
- clearly reports whether the observed threshold is near `0.5 ± 0.02`

Also include a mode comparing:
- deterministic threshold `δ ≍ ε/n`
- random threshold `δ ≍ ε/√n`

This visual comparison is essential.

## Concrete falsifiable prediction

Your paper and demo must test:

> For bounded symmetric mean-zero perturbations, the transition in signature survival occurs at exponent `α = 1/2`, not `α = 1`.

If empirical data consistently place the threshold near `0.6` or larger, the conjecture must be revised. Do not hide negative evidence; use it to sharpen the conjecture.

## Why this is revolutionary

A proof here would create the first robust probabilistic stability principle for Lorentzian signatures. That matters because Lorentzian structures encode one-positive-direction geometry across combinatorics, optimization, and hyperbolic phenomena. Deterministic perturbation theory says noise is dangerous in high dimension. Random matrix theory says noise cancels. Unifying those statements would open an entirely new interface:

- **Lorentzian combinatorics × random matrix theory**
- **hyperbolic/Hessian geometry × stochastic algorithms**
- **spectral stability × disordered statistical physics**

This is not a local extension of an existing theorem. It would establish a new universality principle: **indefinite but gapped structures are probabilistically far more stable than worst-case analysis predicts.**

## Mandatory deliverables

You must produce **all** of the following:

1. **Lean file(s)** with:
   - at least 3 substantial theorems
   - at least 1 new definition/structure
   - at least 1 cross-domain theorem
   - minimal `sorry`
   - no trivialized enumeration proofs

2. **`FUTURE_DIRECTIONS.md`**
   - 3–5 original research directions
   - each direction must include the exact sentences:
     - **“The key insight is...”**
     - **“Why now?”**
   - at least one direction must bridge to a different domain, such as free probability, tropical geometry, or statistical mechanics

3. **`RESEARCH_PAPER.md`**
   - standalone scientific paper
   - must explain the theorem, proof architecture, computational evidence, significance, and open problems
   - readable without access to code

4. **`ARTICLE.md`**
   - Scientific American style
   - broad audience
   - explain the ideas and why they matter
   - **do not focus on formal verification machinery**

5. **Verified algorithm / computational method**
   - certified signature-survival checker under norm threshold
   - clear theorem linking the algorithm’s output to the mathematics

6. **`demo.py`**
   - interactive or script-based experiment
   - reproduces the exponent test
   - includes plots and threshold estimation

## Final call

Do not settle for a weak theorem that merely repackages deterministic bounds. The target is a new law of nature for Lorentzian stability:

\[
\text{worst-case scale } \frac{1}{n}
\quad \longrightarrow \quad
\text{random scale } \frac{1}{\sqrt{n}}.
\]

If you can prove even the deterministic-to-random transfer theorem cleanly, define the right structures, and support the `1/2` exponent with a verified experimental pipeline, you will have created the first rigorous blueprint for probabilistic Lorentzian stability.

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
