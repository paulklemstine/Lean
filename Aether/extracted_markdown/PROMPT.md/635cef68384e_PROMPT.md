## Assignment: Direction 1: Lorentzian Equivalence via Hessian Descent

**Mode:** `prove`

Prove a genuinely new theorem family that turns recursive Lorentzianity into an elementary coefficient-inequality theory. Build directly on:

- `Catalog/Pythagorean/LorentzianRecognitionComplete.lean`
  - `IsRecursivelyLorentzian`
  - `recursivelyLorentzian_iff_brandenHuh`
  - `recursive_certificate_sound`
- `Catalog/Pythagorean/HigherOrderLogConcavity.lean`
  - `KFoldLogConcave`
  - `kFoldLogConcave_mono`

Minimize sorry. Do not settle for a reformulation: the goal is a **field-opening equivalence** between Hessian-signature geometry and discrete coefficient inequalities.

---

## Central Vision

The breakthrough target is to show that for homogeneous multivariate polynomials with nonnegative/positive coefficients, the apparently analytic condition underlying Lorentzianity — every quadratic derivative leaf having Hessian with at most one positive eigenvalue — is equivalent to a finite hierarchy of **directional coefficient inequalities** plus a combinatorial support axiom. If successful, this replaces spectral checking by a certificate built from coefficient ratios and exchange moves.

This would be revolutionary because it would recast Lorentzian geometry as a discrete theory of coefficient flows, opening:

- **algorithmic Lorentzian recognition**
- **matroid/Hodge theory without eigenvalue computations**
- **connections to statistical physics** via negative dependence and partition functions
- **connections to discrete convex analysis** via exchange axioms and M-concavity
- **connections to optimization and complexity** by reducing certification to sparse combinatorial checks

Application keywords: **Lorentzian polynomials, log-concavity, Hessian signatures, discrete convex analysis, matroid theory, negative dependence, Hodge theory, symbolic computation, sparse certification, combinatorial optimization, statistical physics, hyperbolic-type inequalities**

---

## Precise Theorem Targets

You must introduce at least one new definition not already in the catalog, and prove at least 3 substantial theorems.

### New definitions to introduce

Define a coefficient-level hierarchy that mirrors recursive Hessian descent.

Suggested definitions:

1. **Directional mixed log-concavity on coefficients**
   ```lean
   def MixedDirectionalLogConcave
     {σ : Type*} [DecidableEq σ]
     (d : ℕ) (c : (σ →₀ ℕ) → ℝ) : Prop := ...
   ```
   Intended meaning: for every multi-index `α` of total degree `d - 2` and every pair of directions `i j`,
   the quadratic derivative leaf coefficients satisfy
   \[
   c(\alpha + e_i + e_i)\, c(\alpha + e_j + e_j) \le
   c(\alpha + e_i + e_j)^2
   \]
   whenever all terms are in degree `d`.

2. **Axis directional log-concavity**
   ```lean
   def AxisDirectionalLogConcave
     {σ : Type*} [DecidableEq σ]
     (d : ℕ) (c : (σ →₀ ℕ) → ℝ) : Prop := ...
   ```
   Intended meaning: for every `α`, `i`,
   \[
   c(\alpha + 2e_i)\, c(\alpha) \le c(\alpha + e_i)^2
   \]
   whenever the degree constraints make sense.

3. **Exchange-closed support**
   ```lean
   def HasExchangeSupport
     {σ : Type*} [Fintype σ] [DecidableEq σ]
     (d : ℕ) (c : (σ →₀ ℕ) → ℝ) : Prop := ...
   ```
   Intended meaning: if `α, β` are in the support of total degree `d` and `α i > β i`, then there exists `j` with `α j < β j` such that `α - e_i + e_j` and `β - e_j + e_i` remain in support.

4. Optionally package these into a new structure:
   ```lean
   structure HessianDescentCertificate
     {σ : Type*} [Fintype σ] [DecidableEq σ]
     (d : ℕ) where
     coeff : (σ →₀ ℕ) → ℝ
     positive_on_support : Prop
     homogeneous_support : Prop
     mixed_log_concave : MixedDirectionalLogConcave d coeff
     axis_log_concave : AxisDirectionalLogConcave d coeff
     exchange_support : HasExchangeSupport d coeff
   ```

This is the right level of novelty: a discrete certificate object that can plausibly become an algorithm.

---

## Exact theorem statement to aim for

### Theorem A: Recursive Lorentzianity implies coefficient Hessian-descent inequalities

For homogeneous polynomials with positive coefficients, recursive Lorentzianity forces every quadratic derivative leaf to satisfy the mixed coefficient inequality hierarchy.

**Mathematical statement**
Let \(f\) be a homogeneous polynomial of degree \(d\) in finitely many variables with positive coefficients. If `IsRecursivelyLorentzian f`, then for every \(k \le d-2\), every order-\(k\) partial derivative leaf of \(f\) has coefficient function satisfying mixed directional log-concavity and axis log-concavity in degree \(d-k\). Moreover the support is exchange-closed.

**Lean 4 target signature (adapt/adjoin existing polynomial encodings as needed)**
```lean
theorem recursivelyLorentzian_implies_hessianDescentCertificate
  {σ : Type*} [Fintype σ] [DecidableEq σ]
  (d : ℕ)
  (f : MvPolynomial σ ℝ)
  (hhom : f.IsHomogeneous d)
  (hpos : ∀ s, s ∈ f.support → 0 < f.coeff s)
  (hLor : IsRecursivelyLorentzian f) :
  MixedDirectionalLogConcave d f.coeff ∧
  AxisDirectionalLogConcave d f.coeff ∧
  HasExchangeSupport d f.coeff := by
  ...
```

This is the forward direction and should be your first major theorem.

---

### Theorem B: Quadratic leaf equivalence between Hessian signature and mixed coefficient inequality

This is the conceptual hinge of the whole program.

**Mathematical statement**
For any homogeneous quadratic polynomial with positive coefficients,
the Hessian has at most one positive eigenvalue if and only if its coefficient matrix satisfies all pairwise mixed log-concavity inequalities
\[
a_{ii} a_{jj} \le a_{ij}^2
\]
together with positivity/nondegeneracy assumptions.

This theorem isolates the exact algebraic content of the spectral condition.

**Lean 4 target signature**
```lean
theorem quadratic_hessian_signature_iff_mixed_coeff_ineq
  {σ : Type*} [Fintype σ] [DecidableEq σ]
  (q : MvPolynomial σ ℝ)
  (hdeg : q.IsHomogeneous 2)
  (hpos : ∀ s, s ∈ q.support → 0 < q.coeff s) :
  QuadraticLeafHasAtMostOnePositiveEigenvalue q ↔
  MixedDirectionalLogConcave 2 q.coeff := by
  ...
```

If direct spectral formalization is too heavy, prove a certified surrogate theorem using the existing Brändén–Huh equivalence in the catalog:

```lean
theorem quadratic_leaf_lorentzian_iff_mixed_coeff_ineq
  {σ : Type*} [Fintype σ] [DecidableEq σ]
  (q : MvPolynomial σ ℝ)
  (hdeg : q.IsHomogeneous 2)
  (hpos : ∀ s, s ∈ q.support → 0 < q.coeff s) :
  IsRecursivelyLorentzian q ↔ MixedDirectionalLogConcave 2 q.coeff := by
  ...
```

Even this surrogate would be substantial if done cleanly and used recursively.

---

### Theorem C: Partial converse under exchange support and full k-fold coefficient descent

This is the bold theorem. If it cannot be fully proved, isolate the strongest formal partial converse for small degree or under stronger support hypotheses.

**Mathematical statement**
Let \(f\) be homogeneous of degree \(d\) with positive coefficients. Assume:
1. `HasExchangeSupport d f.coeff`,
2. every derivative leaf down to degree 2 satisfies mixed and axis directional log-concavity on coefficients.

Then \(f\) is recursively Lorentzian.

**Lean 4 target signature**
```lean
theorem hessianDescentCertificate_implies_recursivelyLorentzian
  {σ : Type*} [Fintype σ] [DecidableEq σ]
  (d : ℕ)
  (f : MvPolynomial σ ℝ)
  (hhom : f.IsHomogeneous d)
  (hpos : ∀ s, s ∈ f.support → 0 < f.coeff s)
  (hcert :
    MixedDirectionalLogConcave d f.coeff ∧
    AxisDirectionalLogConcave d f.coeff ∧
    HasExchangeSupport d f.coeff)
  (hdesc : ∀ k ≤ d, CoeffDerivativeLeafCondition k f) :
  IsRecursivelyLorentzian f := by
  ...
```

If the full converse is too ambitious, prove one of these decisive restricted versions:

- degree `d ≤ 4`
- support equal to a matroid basis generating support
- strongly Rayleigh / multi-affine specialization
- exchange support + all quadratic derivative leaves satisfy the certificate

A nontrivial restricted converse would already be publishable.

---

## Conjecture with falsifiable prediction

State explicitly in the Lean development and accompanying paper:

```lean
/-- Conjecture: coefficient Hessian descent plus exchange support characterizes
recursive Lorentzianity for homogeneous positive-coefficient polynomials. -/
def LorentzianHessianDescentConjecture : Prop := ...
```

**Computational prediction:** for `n ≤ 5`, `d ≤ 6`, exhaustive or randomized search over positive integer coefficients with exchange-closed support should produce:

- no counterexample to
  `certificate ⇒ IsRecursivelyLorentzian`
  if the conjecture is true;
- or a smallest counterexample whose quadratic derivative leaf fails the Hessian condition despite satisfying all tested coefficient inequalities.

This is falsifiable and must be tested in `demo.py`.

---

## Proof Strategy Architecture

You must present and pursue at least 2–3 proof routes. Do not rely on a single brittle path.

### Strategy A: Quadratic leaf reduction through the Brändén–Huh equivalence
1. Use `recursivelyLorentzian_iff_brandenHuh` to reduce recursive Lorentzianity to the known quadratic-leaf criterion already certified in the catalog.
2. Show that for degree-2 homogeneous leaves, the Hessian entries are explicit scalar multiples of coefficients; compute these formulas by multi-step `calc`, coefficient extraction, and derivative identities.
3. Deduce that “at most one positive eigenvalue” translates into pairwise mixed coefficient inequalities. Then recurse upward through derivative leaves.

**Why promising:** it aligns perfectly with the recursive definition and uses catalog theorems as intended, minimizing new spectral infrastructure.

### Strategy B: Discrete coefficient induction on derivative order
1. Define a derivative-leaf coefficient operator:
   ```lean
   def derivLeafCoeff ... := ...
   ```
   encoding how coefficients transform under partial differentiation.
2. Prove by induction on `k` that recursive Lorentzianity implies `KFoldLogConcave`-type inequalities for the transformed coefficient function.
3. Upgrade `KFoldLogConcave` to the stronger mixed directional inequalities by `rcases` on indices and a careful support analysis using positivity.

**Why promising:** it connects directly to `HigherOrderLogConcavity.lean` and may avoid explicit matrix/eigenvalue formalization.

### Strategy C: Exchange support via discrete convexity / M-convexity bridge
1. Show that recursively Lorentzian support satisfies a basis-exchange style axiom.
2. Interpret coefficient support as a jump system or M-convex set.
3. Use this to prove the combinatorial closure needed for the converse direction.

**Why promising:** this is the bridge to discrete convex analysis and matroid theory. It may be the decisive ingredient for the converse, where pure inequalities are not enough.

**Most promising overall:** Strategy A for the forward direction; Strategy C + A for the converse. Strategy B is ideal for producing robust intermediate lemmas and algorithmic certificates.

---

## Required theorem inventory

Your Lean file must contain at least 3 deep theorems. A recommended minimum set:

1. `quadratic_leaf_lorentzian_iff_mixed_coeff_ineq`
2. `recursivelyLorentzian_implies_hessianDescentCertificate`
3. One converse theorem, even if restricted:
   - `hessianDescentCertificate_implies_recursivelyLorentzian_deg4`
   - or `..._multiaffine`
   - or `..._matroidSupport`

At least one proof must use induction, one must use `rcases`, and one must use a contradiction or multi-step algebraic `calc`/`field_simp` argument.

---

## Cross-domain connection requirement

You must include at least one theorem explicitly linking this program to another domain.

### Preferred cross-domain theorem: discrete convex analysis
Prove that exchange-closed support of a positive homogeneous polynomial induces an M-convex/jump-system style support constraint, or a formal surrogate thereof.

Example target:
```lean
theorem recursivelyLorentzian_support_has_exchange_property
  {σ : Type*} [Fintype σ] [DecidableEq σ]
  {f : MvPolynomial σ ℝ} {d : ℕ}
  (hhom : f.IsHomogeneous d)
  (hpos : ∀ s, s ∈ f.support → 0 < f.coeff s)
  (hLor : IsRecursivelyLorentzian f) :
  HasExchangeSupport d f.coeff := by
  ...
```

This connects Lorentzian geometry to **discrete convex analysis** and **matroid-style exchange systems**.

### Alternative cross-domain theorem: statistical physics
Relate the coefficient inequalities to negative dependence heuristics for partition functions, e.g. show a two-site correlation inequality for the normalized coefficient measure in a restricted setting.

Even a modest formal theorem here would dramatically widen the scope of the work.

---

## Computational/algorithmic deliverable

You must produce a **verified algorithm**, not just theorem statements.

### Algorithm target
Implement a certification procedure that checks the coefficient inequalities and support exchange property for sparse homogeneous polynomials.

Suggested interface:
```lean
def checkHessianDescentCertificate
  {σ : Type*} [Fintype σ] [DecidableEq σ]
  (d : ℕ) (f : MvPolynomial σ ℚ) : Bool := ...
```

Then prove a soundness theorem:
```lean
theorem checkHessianDescentCertificate_sound
  {σ : Type*} [Fintype σ] [DecidableEq σ]
  (d : ℕ) (f : MvPolynomial σ ℚ)
  (h : checkHessianDescentCertificate d f = true)
  (hhom : f.IsHomogeneous d)
  (hpos : ∀ s, s ∈ f.support → 0 < f.coeff s) :
  MixedDirectionalLogConcave d (fun s => (f.coeff s : ℝ)) ∧
  AxisDirectionalLogConcave d (fun s => (f.coeff s : ℝ)) ∧
  HasExchangeSupport d (fun s => (f.coeff s : ℝ)) := by
  ...
```

If you can also prove a partial completeness theorem in a restricted regime, that is even better.

This algorithm is the scientific lever: if the equivalence holds, Lorentzianity becomes checkable in near-combinatorial time.

---

## Demo / experimental program

Implement `demo.py` that:

1. generates homogeneous polynomials with positive coefficients for `n ≤ 5`, `d ≤ 6`,
2. computes all quadratic derivative leaves,
3. checks mixed and axis coefficient inequalities,
4. checks exchange-closed support,
5. compares with a direct Hessian/eigenvalue test or a recursive Lorentzian oracle where feasible,
6. searches for counterexamples to the converse.

The demo must expose:
- a forward verification mode,
- a converse counterexample search mode,
- a summary of smallest failing examples.

---

## Mandatory deliverables

You must produce **all** of the following:

### 1. `FUTURE_DIRECTIONS.md`
Give 3–5 original research directions. Each direction must include the exact phrases:

- **“The key insight is...”**
- **“Why now?”**

At least one direction must bridge to a different domain, such as:
- statistical physics,
- combinatorial optimization,
- Hodge theory,
- information theory,
- complexity of symbolic certification.

### 2. `RESEARCH_PAPER.md`
A standalone scientific paper explaining:
- the new definitions,
- the main theorems,
- why coefficient inequalities replacing Hessian signatures is a breakthrough,
- the algorithmic consequences,
- computational evidence for or against the conjecture,
- what comes next.

Someone reading only this paper must fully understand the discovery.

### 3. `ARTICLE.md`
Write in **Scientific American** style. Make it vivid and broadly accessible. Explain the mathematical ideas and why they matter.

**Taboo:** do **not** focus on formal verification or machine verification. The story is about the mathematics: turning curvature-like spectral tests into simple discrete inequalities.

### 4. Verified algorithm
Implement and prove soundness of the coefficient-certificate checker.

### 5. `demo.py`
Interactive or scriptable computational demonstration of the theorem/conjecture search.

---

## Quality bar

- No trivial theorem padding.
- No proofs whose only content is evaluation by `native_decide`, `decide`, `norm_num`, or `rfl`.
- Use substantial tactics: induction, `rcases`, `by_contra`, `field_simp`, `calc`.
- Prefer theorems that reveal structure, not merely technical lemmas.
- If the full converse fails, pivot immediately to:
  - the sharpest counterexample,
  - the weakest additional hypothesis that restores equivalence,
  - and a theorem explaining exactly where the naive converse breaks.

This project has the potential to convert Lorentzian polynomial theory from a spectral black box into a combinatorial calculus. That is the standard.

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
