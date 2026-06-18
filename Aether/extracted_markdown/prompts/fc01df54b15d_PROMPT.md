Soli Deo Gloria

## Assignment: Direction 3: Tropical Shadows of Lorentzian Stability

**Mode:** prove

You are not being asked for an incremental extension. You are being asked to carve out a new interface between **Lorentzian stability theory**, **Maslov dequantization**, and **tropical/max-plus spectral theory**. The target is a theorem family that turns an analytic stability radius into a combinatorial tropical invariant. If successful, this creates a new computational language for Lorentzian certification: one can estimate or certify robustness without dense eigenvalue computations, replacing them by tropical gap computations on quadratic leaves.

Build on the catalog, especially:

- `Pythagorean/LorentzianStability.lean` — in particular any theorem around `UniformSpectralMargin`
- `Catalog/Tropical/` — tropical polynomial infrastructure, min/max-plus algebra, tropical hypersurface reasoning
- any existing matrix spectral lemmas in Mathlib that can support comparison estimates for quadratic forms and principal minors

The vision is to isolate a **tropical shadow** of Lorentzian robustness and prove rigorous inequalities first, then sharpen toward equality in structured classes.

---

## Core Mathematical Program

### New concept to define

Introduce a new notion capturing the tropical obstruction to Lorentzianity on quadratic leaves.

Suggested definitions:

1. **Tropical quadratic leaf**
   For a homogeneous polynomial `f` with nonnegative coefficients, and a multi-index `α`, define the quadratic leaf obtained by differentiating to degree 2:
   \[
   Q_{f,\alpha}(x) := \partial^\alpha f(x)
   \quad \text{whenever } |\alpha| = \deg(f)-2.
   \]
   Tropicalize its coefficient vector by valuation/log-weight.

2. **Tropical spectral gap**
   For a tropical quadratic form encoded by weights \(w_{ij}\), define
   \[
   \operatorname{tGap}(w)
   := \min_{i,j,k,\ell}\bigl((w_{ij}+w_{k\ell})-(w_{ik}+w_{j\ell})\bigr)
   \]
   over admissible 2×2 exchange patterns, or an equivalent max-plus eigen-gap notion if the catalog already supports a better formal object.

3. **Tropical Lorentzian margin**
   Define the global invariant
   \[
   \operatorname{tropMargin}(f)
   := \inf_{\alpha: |\alpha|=\deg(f)-2} \operatorname{tGap}(\operatorname{TropCoeff}(Q_{f,\alpha})).
   \]
   This should be the combinatorial proxy for the logarithmic asymptotic stability radius.

This definition is not cosmetic. It is the bridge object that lets one compare analytic perturbation thresholds to tropical exchange inequalities.

---

## Precise theorem targets

You must prove at least **3 substantial theorems**. At least one should be a cross-domain theorem. At least one should involve a genuinely new definition from above.

### Theorem 1: Tropical gap gives a lower bound on Lorentzian stability radius

This is the first breakthrough theorem and the most realistic anchor result.

#### Mathematical statement
Let \(f\) be a homogeneous polynomial with positive coefficients over `ℝ`, of degree \(d \ge 2\), and assume every quadratic leaf \(Q_{f,\alpha}\) is represented by a symmetric matrix. Let `stabilityRadius f` denote the infimum coefficient perturbation size that destroys Lorentzianity, and let `tropMargin f` be the tropical quadratic-leaf gap defined above. Then under suitable positivity/nondegeneracy hypotheses,
\[
\log(\operatorname{stabilityRadius}(f)) \ge \operatorname{tropMargin}(f) - C_f,
\]
for an explicit normalization constant \(C_f\) depending on the chosen valuation/log convention; in scale-normalized families, this becomes
\[
\operatorname{tropMargin}(f) \le \log(\operatorname{stabilityRadius}(f)).
\]

#### Lean-style target signature
A realistic formal target, adaptable to your actual definitions:

```lean
theorem tropMargin_le_log_stabilityRadius
    {σ : Type*} [Fintype σ] [DecidableEq σ]
    (f : MvPolynomial σ ℝ)
    (d : ℕ)
    (hf_hom : f.IsHomogeneousOfDegree d)
    (hd : 2 ≤ d)
    (hf_pos : PositiveCoefficients f)
    (hf_nd : TropicallyNondegenerateQuadraticLeaves f) :
    tropMargin f ≤ Real.log (stabilityRadius f)
```

If `Real.log` creates domain-management pain, formulate an exponential version:

```lean
theorem exp_tropMargin_le_stabilityRadius
    {σ : Type*} [Fintype σ] [DecidableEq σ]
    (f : MvPolynomial σ ℝ)
    (d : ℕ)
    (hf_hom : f.IsHomogeneousOfDegree d)
    (hd : 2 ≤ d)
    (hf_pos : PositiveCoefficients f)
    (hf_nd : TropicallyNondegenerateQuadraticLeaves f) :
    Real.exp (tropMargin f) ≤ stabilityRadius f
```

This theorem matters because it converts a hard analytic radius into a computable combinatorial lower bound.

---

### Theorem 2: Exact equality for uniform/constant-coefficient quadratic leaf models

This is where you should aim for a clean exact theorem, likely using the catalog theorem `UniformSpectralMargin`.

#### Mathematical statement
For the uniform Lorentzian families already controlled by the catalog, the tropical margin equals the logarithmic stability radius exactly:
\[
\operatorname{tropMargin}(f)=\log(\operatorname{stabilityRadius}(f)).
\]
At minimum, prove this for a family where all quadratic leaves are exchange-symmetric (uniform matroids, complete graph basis-generating polynomials, or any class directly supported by `UniformSpectralMargin`).

#### Lean-style target signature
```lean
theorem tropMargin_eq_log_stabilityRadius_uniform
    {σ : Type*} [Fintype σ] [DecidableEq σ]
    (f : MvPolynomial σ ℝ)
    (d : ℕ)
    (hf_hom : f.IsHomogeneousOfDegree d)
    (hd : 2 ≤ d)
    (hf_uniform : UniformLorentzianFamily f)
    (hf_pos : PositiveCoefficients f) :
    tropMargin f = Real.log (stabilityRadius f)
```

Or, if the catalog theorem is parameterized by a combinatorial object:

```lean
theorem tropMargin_eq_uniformSpectralMargin
    (U : UniformData n r) :
    tropMargin (U.basisGeneratingPolynomial) =
      Real.log (stabilityRadius (U.basisGeneratingPolynomial))
```

This is your “exact solvable model.” It demonstrates the bridge is not merely asymptotic handwaving.

---

### Theorem 3: Cross-domain theorem — tropical exchange gap controls a combinatorial optimization quantity

You are required to connect domains. Do it by linking tropical Lorentzian margin to a discrete optimization invariant.

A strong option: prove that for valuated matroid-type quadratic leaves, the tropical spectral gap coincides with the minimum slack in an exchange inequality, hence is computable by finite combinatorial search.

#### Mathematical statement
For a valuated matroid / exchange-weight quadratic leaf \(w\), the tropical spectral gap equals the minimum exchange defect:
\[
\operatorname{tGap}(w)
=
\min \{\, w_{ij}+w_{k\ell}-w_{ik}-w_{j\ell} \,\},
\]
and therefore can be computed by a polynomial-time combinatorial routine over the support graph.

This links:
- Lorentzian geometry
- tropical/max-plus algebra
- combinatorial optimization / valuated matroids

#### Lean-style target signature
```lean
theorem tropicalSpectralGap_eq_min_exchange_defect
    {σ : Type*} [Fintype σ] [DecidableEq σ]
    (w : TropicalQuadraticWeight σ)
    (hw : ExchangeAdmissible w) :
    tropicalSpectralGap w =
      sInf {δ : ℝ | ∃ i j k l, IsExchangeQuadruple i j k l ∧
        δ = weight w i j + weight w k l - weight w i k - weight w j l}
```

And then a computability corollary:

```lean
theorem tropicalSpectralGap_computable
    {σ : Type*} [Fintype σ] [DecidableEq σ]
    (w : TropicalQuadraticWeight σ) :
    ∃ alg : TropicalGapCertificate w,
      alg.value = tropicalSpectralGap w
```

This is the theorem that turns the theory into an algorithmic science.

---

## Grand conjecture to state explicitly

You must state the full conjecture in the Lean file and in prose.

### Conjecture
For every homogeneous Lorentzian polynomial \(f\) with positive coefficients,
\[
\lim_{t\to\infty}
\frac{\log(\operatorname{stabilityRadius}(t^{\omega}\!\cdot f))}{\log t}
=
\operatorname{tropMargin}(f,\omega),
\]
where \(t^\omega\!\cdot f\) denotes coefficient rescaling by weight vector \(\omega\), and the right-hand side is the minimum tropical spectral gap over all quadratic leaves of the weighted tropicalization.

A Lean placeholder could be:

```lean
conjecture maslov_limit_eq_tropMargin
    {σ : Type*} [Fintype σ] [DecidableEq σ]
    (f : MvPolynomial σ ℝ)
    (ω : σ → ℝ)
    (d : ℕ)
    (hf_hom : f.IsHomogeneousOfDegree d)
    (hd : 2 ≤ d)
    (hf_pos : PositiveCoefficients f) :
    Tendsto
      (fun t : ℝ => Real.log (stabilityRadius (weightedRescale f ω t)) / Real.log t)
      atTop
      (𝓝 (tropMarginWeighted f ω))
```

If full limit machinery is too heavy, state a falsifiable asymptotic inequality conjecture with upper and lower lim bounds.

### Computationally testable prediction
For small examples (complete graphs, uniform matroids, sparse strongly Rayleigh families), compute:
1. exact or certified `stabilityRadius`
2. `tropicalSpectralGap` on all quadratic leaves
3. compare `log(stabilityRadius)` against `tropMargin`

**Disproof criterion:** if
\[
\bigl|\log(\operatorname{stabilityRadius}(f))-\operatorname{tropMargin}(f)\bigr| > C \log n
\]
for repeated structured families with consistent normalization, the conjecture is false in its current form.

This must be implemented in `demo.py`.

---

## Proof strategy architecture

You must not pursue only one route. Develop at least 2–3 proof paths and decide which is most viable.

### Strategy A: Quadratic-leaf reduction + exchange inequalities
1. Reduce Lorentzian failure under perturbation to failure of a quadratic leaf spectral inequality, using the existing Lorentzian stability infrastructure from `Pythagorean/LorentzianStability.lean`.
2. Express each quadratic leaf by a symmetric coefficient matrix and identify the smallest perturbation that breaks the one-positive-eigenvalue condition or equivalent principal-minor inequalities.
3. Tropicalize the exchange inequalities controlling those minors; show the dominant exponent is exactly the tropical exchange defect / tropical spectral gap.

**Why promising:** This leverages the catalog directly and stays close to finite-dimensional matrix inequalities that Lean can handle.

### Strategy B: Maslov dequantization via logarithmic asymptotics
1. Introduce coefficient scaling \(a_I(t)=t^{\omega_I}c_I\).
2. Show that determinant/minor inequalities governing Lorentzianity become asymptotically piecewise-linear in \(\log t\).
3. Identify the leading exponent with a tropical minimum over exchange patterns, yielding the tropical gap.

**Why promising:** This is conceptually the right theorem and captures the true dequantization story.  
**Risk:** limit arguments and asymptotic comparison may be technically heavy in Lean.

### Strategy C: Uniform exact model first, then perturbative extension
1. Prove exact equality for uniform families using `UniformSpectralMargin`.
2. Show local Lipschitz/monotonic comparison between analytic stability margin and tropical gap under controlled coefficient deformations.
3. Derive lower/upper bounds for nearby families, giving the first nontrivial general theorem.

**Why promising:** It secures a publishable exact theorem early and creates a scaffold for the full conjecture.  
**Most promising overall:** **Strategy C feeding into Strategy A.** Get an exact solvable family theorem, then generalize to inequalities by quadratic-leaf comparison.

---

## Lean 4 formalization guidance

You should introduce definitions that are mathematically meaningful and tractable.

Possible definitions:

```lean
structure TropicalQuadraticWeight (σ : Type*) where
  weight : σ → σ → ℝ
  symm : ∀ i j, weight i j = weight j i
```

```lean
def tropicalExchangeDefect
    {σ : Type*} [Fintype σ] [DecidableEq σ]
    (w : TropicalQuadraticWeight σ) : ℝ :=
  sInf {δ : ℝ | ∃ i j k l, PairwiseDistinct #[i,j,k,l] ∧
    δ = w.weight i j + w.weight k l - w.weight i k - w.weight j l}
```

```lean
def tropMargin
    {σ : Type*} [Fintype σ] [DecidableEq σ]
    (f : MvPolynomial σ ℝ) : ℝ := ...
```

```lean
def QuadraticLeaf
    {σ : Type*} [Fintype σ] [DecidableEq σ]
    (f : MvPolynomial σ ℝ) (α : σ →₀ ℕ) : MvPolynomial σ ℝ := ...
```

Also define a certificate structure for algorithmic computation:

```lean
structure TropicalGapCertificate {σ : Type*} [Fintype σ] [DecidableEq σ]
    (w : TropicalQuadraticWeight σ) where
  witness : σ × σ × σ × σ
  admissible : IsExchangeQuadruple witness.1 witness.2.1 witness.2.2.1 witness.2.2.2
  value : ℝ
  cert : value = tropicalSpectralGap w
```

This helps satisfy the “verified algorithm” requirement.

---

## Expected theorem-proving style

The file must contain at least 3 nontrivial theorems with real proof structure. Use:
- induction on degree or support size
- `rcases` to unpack quadratic leaves / exchange witnesses
- `by_contra` for minimality or gap-positivity arguments
- `field_simp` if any rational/logarithmic normalization enters
- multi-step `calc` blocks for inequalities linking spectral margin, determinants, and tropical defects

Do not hide the substance behind computation or case enumeration.

---

## Cross-domain bridges to emphasize

You must explicitly connect this project to at least one different domain. Good bridges include:

1. **Combinatorial optimization:**  
   Tropical spectral gap as minimum exchange slack; polynomial-time certification via finite exchange search.

2. **Statistical physics / phase transitions:**  
   Lorentzian stability radius behaves like a robustness threshold; tropicalization extracts a zero-temperature limit, akin to free-energy domination by ground states.

3. **Numerical linear algebra:**  
   Replace eigenvalue-based robustness estimation with tropical gap certificates for massive sparse systems.

4. **Matroid theory / discrete convexity:**  
   Quadratic leaves encode valuated exchange geometry; the tropical gap measures distance from exchange degeneracy.

These bridges should appear both in the theorems and in the prose documents.

---

## Application keywords

Use these explicitly in the paper and article:

**Lorentzian polynomials, tropical geometry, max-plus algebra, Maslov dequantization, valuated matroids, combinatorial optimization, spectral gap, stability radius, exchange inequalities, discrete convexity, sparse certification, zero-temperature asymptotics, robust inference, polynomial-time certification**

---

## Concrete deliverables

You must produce **all** of the following:

1. **Lean file(s)** with the new definitions and at least 3 substantial theorems, minimizing sorry.
2. **A verified algorithm or computational method** for computing or certifying `tropicalSpectralGap` / `tropMargin` on finite examples.
3. **`demo.py`** that:
   - constructs small examples (complete graphs, uniform matroids, perhaps hand-built Lorentzian families),
   - computes tropical quadratic leaves,
   - computes tropical gap certificates,
   - compares against exact or approximate `stabilityRadius`,
   - prints a table and highlights potential counterexamples.
4. **`RESEARCH_PAPER.md`** as a standalone scientific paper:
   - problem statement
   - precise theorem statements
   - mathematical intuition
   - proof architecture
   - computational experiments
   - limitations and next conjectures
5. **`ARTICLE.md`** in Scientific American style:
   - explain the discovery as a new way to see robustness through tropical shadows
   - do **not** focus on formal verification
   - focus on ideas, significance, and future impact
6. **`FUTURE_DIRECTIONS.md`** with 3–5 original research directions, each containing:
   - “**The key insight is...**”
   - “**Why now?**”
   At least one direction must bridge to a different domain, such as statistical physics, optimization, or information theory.

---

## Suggested file-level milestone plan

### Milestone 1: Definitions and exact solvable model
- Define `TropicalQuadraticWeight`, `QuadraticLeaf`, `tropicalExchangeDefect`, `tropMargin`
- Prove basic invariance/monotonicity lemmas
- Prove exact equality for a uniform family using `UniformSpectralMargin`

### Milestone 2: General lower bound theorem
- Relate perturbation-induced Lorentzian failure to a quadratic-leaf defect
- Prove `exp_tropMargin_le_stabilityRadius` or a normalized variant

### Milestone 3: Cross-domain algorithmic theorem
- Prove tropical gap equals minimum exchange defect in the finite combinatorial model
- Implement a certificate-producing algorithm
- Benchmark in `demo.py`

### Milestone 4: Conjectural frontier
- State `maslov_limit_eq_tropMargin`
- Gather computational evidence
- Identify where the proof breaks: asymptotics, normalization, or non-uniform leaf interactions

---

## Standard of success

Success is **not** “we formalized a definition.”  
Success is: you establish the first rigorous theorem that a tropical combinatorial invariant controls Lorentzian robustness, prove exactness in a meaningful class, and deliver an executable method for testing the conjectural equality.

If you pull this off, you open a field: **tropical robustness theory for Lorentzian polynomials**. That would matter to combinatorics, optimization, and any domain where one needs scalable certificates of high-dimensional stability.

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
