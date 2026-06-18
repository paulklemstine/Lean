## Assignment: Direction 3: Efficient Lorentzian Certificate Computation

Prove new, non-trivial theorems. Build on catalog theorems. Minimize sorry.

This direction should not be treated as a mere implementation of a Hessian formula. The real target is a new computational bridge between **determinantal probability**, **Lorentzian geometry of generating polynomials**, and **numerical linear algebra**: a theorem saying that the Lorentzian certificate for a DPP is not an abstract existential object, but an explicitly computable matrix certificate with the same asymptotic complexity as standard spectral preprocessing.

The breakthrough is to convert a qualitative theorem
“DPP generating polynomials are Lorentzian”
into a **quantitative, efficiently computable signature certificate**
whose entries are expressed through resolvent minors of `I + K`.
If successful, this opens a new program: **algorithmic Lorentzian geometry**.

## Depth Requirements (MANDATORY)

Your output must satisfy ALL of these:

1. **NO trivial proofs**: Do NOT prove statements by `native_decide`, `decide`,
   `norm_num`, or `rfl` unless the statement itself is genuinely important.
   If the only proof tactic is enumeration, the theorem is not worth formalizing.

2. **At least 3 theorems with deep proof tactics**: Your file must contain at
   least 3 theorems proven using induction, `rcases`, `by_contra`, `field_simp`,
   or multi-step `calc` reasoning.

3. **Novel definitions**: Define at least one new mathematical structure or concept
   that does not already exist in the Catalog. Check the catalog references to
   confirm novelty.

4. **Cross-domain connections**: Include at least one theorem that connects your
   domain to a different mathematical domain (e.g., number theory + tropical
   geometry, algebra + physics).

5. **Conjecture with testable prediction**: State at least one falsifiable
   conjecture with a clear computational test that could disprove it.

---

### Core Research Goal

Let `K : Matrix (Fin n) (Fin n) ℝ` be a symmetric PSD contraction, and let

\[
Z_K(x) := \det(I + \operatorname{diag}(x)\,K)
\]

be the DPP partition polynomial. Define the Hessian certificate at the all-ones point by

\[
H_{ij}(K) := \frac{\partial^2}{\partial x_i \partial x_j} Z_K(1,\dots,1).
\]

The central theorem to formalize is that this Hessian can be expressed in closed form using the inverse of `I + K`, and that this expression yields an `O(n^3)` algorithm for computing the Lorentzian signature defect.

This is not just a computational convenience: it identifies the Lorentzian certificate with a **resolvent correlation geometry** attached to the kernel. That is the conceptual advance.

---

## Precise Theorem Targets

You should aim for at least the following three theorem-level deliverables.

### Theorem 1: Closed Hessian Formula for DPP Partition Polynomials

For `A = I + K` invertible, prove that for `i ≠ j`,

\[
\partial_i \partial_j Z_K(1)
= \det(A)\Big((A^{-1})_{ii}(A^{-1})_{jj} - (A^{-1})_{ij}(A^{-1})_{ji}\Big),
\]

and in the symmetric real case,

\[
\partial_i \partial_j Z_K(1)
= \det(A)\Big((A^{-1})_{ii}(A^{-1})_{jj} - (A^{-1})_{ij}^2\Big).
\]

For diagonal entries, identify the correct second derivative contribution from multilinearity of the determinant; in the standard multiaffine DPP partition polynomial one expects

\[
\partial_i^2 Z_K = 0,
\]

so part of the theorem is to prove the polynomial is multiaffine and hence the diagonal Hessian entries vanish.

#### Lean-oriented target signature
A realistic formal target may look like:

```lean
theorem dpp_partition_hessian_offDiag_formula
    {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ)
    (hKsymm : K.IsSymm)
    (hAinv : IsUnit (Matrix.det (1 + K)))
    {i j : Fin n} (hij : i ≠ j) :
    dppHessianEntry K i j
      = Matrix.det (1 + K) *
        (((1 + K)⁻¹ i i) * (((1 + K)⁻¹) j j) - (((1 + K)⁻¹) i j)^2) := by
  ...
```

and separately

```lean
theorem dpp_partition_hessian_diag_eq_zero
    {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ)
    (i : Fin n) :
    dppHessianEntry K i i = 0 := by
  ...
```

If exact matrix inverse notation requires `Invertible` or a field-generalized statement, adjust accordingly. The important thing is the mathematical content, not syntactic rigidity.

### Theorem 2: Efficient Certificate Construction

Define a new certificate object encoding the Hessian/signature data.

#### Novel definition
Introduce a new structure, for example:

```lean
structure LorentzianHessianCertificate (n : ℕ) where
  hess : Matrix (Fin n) (Fin n) ℝ
  defect : ℕ
  symmetric : hess.IsSymm
  defect_spec : defect = matrixPositiveSignatureDefect hess
```

or, if spectral machinery is too heavy, define a certificate through an “at most one positive direction” quadratic-form property on a codimension-1 subspace.

Then prove that for PSD contraction kernels the certificate can be constructed from one inverse and one determinant computation.

#### Lean-oriented target signature
```lean
theorem exists_lorentzian_hessian_certificate_of_psd_contraction
    {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ)
    (hKsymm : K.IsSymm)
    (hKpsd : Matrix.PosSemidef K)
    (hKcontr : Matrix.IsContraction K) :
    ∃ cert : LorentzianHessianCertificate n,
      cert.hess = dppHessianMatrix K := by
  ...
```

This theorem should be paired with a complexity-aware mathematical statement in comments / paper text:

- one determinant of `I + K`,
- one inversion of `I + K`,
- `O(n²)` entry assembly,
- total arithmetic complexity `O(n³)`.

You likely will not formalize bit-complexity in Lean, but you should formalize the exact algebraic reduction showing the certificate depends only on these objects.

### Theorem 3: Signature Control / Lorentzian Defect Bound

Prove a mathematically nontrivial spectral consequence: for PSD contraction kernels, the Hessian certificate has at most one positive eigenvalue, or equivalently its quadratic form is nonpositive on an explicit codimension-1 subspace.

A practical formal substitute for full eigenvalue counting is a theorem of the shape:

\[
\forall v,\ \sum_i w_i v_i = 0 \implies v^\top H v \le 0
\]

for a canonical positive weight vector `w` derived from diagonal entries or first derivatives. This is exactly the kind of hyperbolicity/Lorentzian signature statement that avoids overcommitting to finite-dimensional spectral APIs if those are cumbersome.

#### Lean-oriented target signature
```lean
theorem dpp_hessian_conditional_negative_semidefinite
    {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ)
    (hKsymm : K.IsSymm)
    (hKpsd : Matrix.PosSemidef K)
    (hKcontr : Matrix.IsContraction K) :
    ∃ w : Fin n → ℝ,
      (∀ i, 0 < w i) ∧
      ∀ v : Fin n → ℝ,
        (∑ i, w i * v i) = 0 →
        quadraticForm (dppHessianMatrix K) v ≤ 0 := by
  ...
```

This theorem is a major conceptual bridge: it recasts Lorentzianity as a **conditionally negative semidefinite kernel statement**, linking DPP theory to harmonic analysis and kernel methods.

---

## New Definitions to Introduce

At least one of the following should be introduced as genuinely new catalog-level objects.

### 1. `dppHessianMatrix`
The matrix of second derivatives of `Z_K` at the all-ones point.

```lean
def dppHessianMatrix {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ) :
    Matrix (Fin n) (Fin n) ℝ := ...
```

### 2. `signatureDefect`
A numerical invariant measuring how far a symmetric matrix is from the Lorentzian one-positive-eigenvalue regime.

```lean
def signatureDefect {n : ℕ} (H : Matrix (Fin n) (Fin n) ℝ) : ℕ := ...
```

If exact eigenvalue counting is technically difficult, define a surrogate defect via maximal dimension of a positive subspace, then relate it to the usual notion in the paper.

### 3. `LorentzianHessianCertificate`
A compact witness object bundling the Hessian, a defect bound, and the key quadratic-form property.

This is the right abstraction if you want downstream algorithms to consume certificates without reproving all determinant identities.

---

## Proof Strategy Architecture

You must present at least 2–3 viable proof paths in the code comments or paper, and pursue the strongest one formally.

### Strategy A: Jacobi Formula + Multiaffinity + Resolvent Identity
**Most promising.**

1. Prove `Z_K(x) = det(I + diag(x) K)` is multiaffine in the coordinates `x_i`.  
   This gives `∂²_i Z_K = 0` immediately and reduces attention to `i ≠ j`.

2. Use determinant differentiation/Jacobi’s formula:
   \[
   \frac{d}{dt}\det(A(t)) = \det(A(t)) \operatorname{tr}(A(t)^{-1} A'(t)).
   \]

3. Differentiate a second time with `A(x)=I+diag(x)K`, then simplify at `x=1`
   using the derivative of the inverse:
   \[
   \partial_j A^{-1} = -A^{-1}(\partial_j A)A^{-1}.
   \]

4. Reduce the trace expression to rank-one coordinate matrices and obtain the entrywise formula.

Why this is best: it is conceptually clean, aligns with matrix identities already present in Mathlib, and scales to future generalizations (strongly Rayleigh measures, mixed discriminants, hyperbolic barrier functions).

### Strategy B: Principal-Minor Expansion
1. Expand
   \[
   Z_K(x)=\sum_{S \subseteq [n]} \det(K_S)\prod_{i\in S} x_i.
   \]

2. Identify
   \[
   \partial_i \partial_j Z_K(1)
   = \sum_{S \ni i,j} \det(K_S).
   \]

3. Use complementary minor / Cauchy–Binet / Schur-complement identities to show this sum equals the resolvent expression involving `(I+K)^{-1}`.

Why it matters: this route ties the Hessian directly to DPP inclusion probabilities and may give a cleaner combinatorial interpretation of the certificate entries.

Risk: the principal-minor identity infrastructure may be heavier in Lean than the analytic matrix calculus route.

### Strategy C: Exterior Algebra / Mixed Discriminant Route
1. Interpret `det(I + diag(x)K)` as a generating function of wedge-power traces.
2. Identify second derivatives with mixed discriminants of rank-one perturbations.
3. Use Alexandrov–Fenchel-type inequalities or Hodge-Riemann relations to derive the one-positive-direction property.

Why it is exciting: this exposes the Hodge-theoretic origin of Lorentzianity and could connect directly to matroid and mixed volume theory.

Risk: likely too ambitious for the first formal pass, but excellent for `RESEARCH_PAPER.md` and future directions.

---

## Cross-Domain Connections (MANDATORY)

Include at least one theorem or substantial discussion connecting this work to another domain.

### Bridge 1: Numerical Linear Algebra
The Hessian certificate depends on the resolvent `L = (I+K)⁻¹`. This makes Lorentzian certification a problem in **stable inverse computation** and **structured matrix analysis**. A theorem worth proving:

```lean
theorem dpp_hessian_from_resolvent_entries
    {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ) :
    ∀ i j, dppHessianEntry K i j = resolventFormula K i j := by
  ...
```

This reframes Lorentzianity as a property readable from a resolvent kernel.

### Bridge 2: Optimization / Semidefinite Geometry
The conditional negative semidefiniteness theorem makes the certificate verifiable by SDP-style inequalities. This links DPP Lorentzianity to **convex optimization** and **spectrahedral feasibility**.

A useful theorem statement: if the codimension-1 quadratic inequality holds, then the matrix has at most one positive eigenvalue. This is a linear-algebraic bridge from hyperbolic geometry to optimization.

### Bridge 3: Machine Learning / Kernel Methods
DPP kernels are already used in diversity sampling. The Hessian certificate can be interpreted as a curvature diagnostic for diversity-promoting kernels. The theorem that the Hessian is conditionally negative semidefinite on a weighted-zero-sum subspace links directly to **kernel learning**, **Gaussian process covariance diagnostics**, and **repulsive point process model selection**.

### Bridge 4: Statistical Physics
`Z_K(x)` is a partition function. Its Hessian at `x=1` measures pair correlations / susceptibility. The Lorentzian signature statement becomes a constraint on correlation geometry, linking DPPs to **stability of fermionic partition functions** and **negative dependence phenomena**.

Application keywords: **determinantal point processes, Lorentzian polynomials, hyperbolicity, resolvent identity, matrix inverse, conditional negative definiteness, semidefinite programming, kernel methods, statistical physics, partition functions, diversity sampling**.

---

## Catalog Building Blocks

You must explicitly build on:

- `Pythagorean/CertifiedDPPSampling.lean`
  - especially `LorentzianEmpiricalCert`
  - and any quadratic-form lemmas such as `covarianceQuadForm`

- `Speculative/AutoResearch/DPPLorentzian.lean`
  - especially `IsDPPLorentzian`
  - and `dpp_partition_function_lorentzian`

Use these not as citations but as infrastructure:
- refine `LorentzianEmpiricalCert` into a **closed-form exact certificate**,
- turn `IsDPPLorentzian` from a global existence statement into a **computable local Hessian witness**,
- use `covarianceQuadForm` to connect Hessian signatures to covariance-style quadratic forms.

A strong outcome would be a theorem showing that your new Hessian certificate implies or recovers the existing Lorentzian empirical certificate.

---

## Suggested Formalization Sequence

1. Define `dppHessianEntry` and `dppHessianMatrix`.
2. Prove multiaffinity of `Z_K`.
3. Prove diagonal second derivatives vanish.
4. Prove off-diagonal second derivative formula by Jacobi/resolvent calculus.
5. Package the Hessian into `LorentzianHessianCertificate`.
6. Prove symmetry.
7. Prove conditional negative semidefiniteness on a weighted-zero-sum subspace.
8. Relate defect `= 0` or `≤ 1` to Lorentzianity / existing certificate notions.
9. Extract an executable algorithm for certificate computation.

This sequence should naturally produce at least 3 deep proofs with nontrivial tactics.

---

## Computational Deliverable

You must produce a **verified algorithm or computational method**, not just theorem statements.

Implement a formally specified routine that:
1. takes a symmetric PSD contraction kernel `K`,
2. forms `A = I + K`,
3. computes `det(A)` and `A⁻¹`,
4. assembles the Hessian matrix using the closed formula,
5. computes or estimates the signature defect,
6. returns a `LorentzianHessianCertificate`.

Even if the numerical linear algebra itself is outside Lean’s executable core, the mathematical reduction from Hessian computation to inverse-entry assembly must be formally verified.

A plausible interface:

```lean
def computeLorentzianCertificate {n : ℕ}
    (K : Matrix (Fin n) (Fin n) ℝ) :
    LorentzianHessianCertificate n := ...
```

and a correctness theorem:

```lean
theorem computeLorentzianCertificate_correct
    {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ)
    (hKsymm : K.IsSymm)
    (hKpsd : Matrix.PosSemidef K)
    (hKcontr : Matrix.IsContraction K) :
    (computeLorentzianCertificate K).hess = dppHessianMatrix K := by
  ...
```

---

## Conjecture with Testable Prediction (MANDATORY)

State and investigate at least one falsifiable conjecture.

### Conjecture A: Exact Defect Collapse for PSD Contractions
For every symmetric PSD contraction kernel `K`, the Hessian certificate at `x = 1` has **exactly** one positive eigenvalue unless `K = 0`, in which case it has none.

This is stronger than “at most one positive eigenvalue.” It predicts a rigid spectral law.

**Computational test:** generate random PSD contractions, compute the Hessian certificate numerically, and count positive eigenvalues. A single counterexample disproves it.

### Conjecture B: Trace-Normalized Stability Gap
There exists a universal constant `c > 0` such that for every nonzero PSD contraction `K`,
\[
\lambda_+(H_K) \ge c \,\det(I+K)\,\operatorname{tr}((I+K)^{-1})^{-2},
\]
where `λ₊` is the unique positive eigenvalue of the Hessian certificate.

**Computational test:** estimate the ratio over random ensembles and search for collapse toward zero.

### Conjecture C: Conditional Negative Type of the Normalized Hessian
After dividing by `det(I+K)`, the off-diagonal Hessian matrix defines a kernel of negative type on `[n]`.

**Computational test:** for random zero-sum vectors `v`, verify `vᵀHv ≤ 0`; search for violations.

At least one of these must appear in the formal/experimental package with a clear scriptable falsification procedure.

---

## Revolutionary Significance

If you succeed, the result says that Lorentzian structure in DPPs is not only a deep structural theorem from Hodge-theoretic combinatorics; it is an **algorithmically accessible certificate** with no asymptotic cost beyond standard kernel inversion. That changes the game.

It opens:
- **algorithmic Lorentzian geometry** for probabilistic models,
- certified diversity sampling with exact curvature witnesses,
- optimization pipelines where Lorentzianity is enforced or checked in-loop,
- a new interface between negative dependence theory and matrix computation,
- future generalizations to strongly Rayleigh measures, mixed discriminants, and hyperbolic barrier methods.

This is the kind of result that could define a new subfield: not just proving that a partition function is Lorentzian, but computing the geometry that witnesses it.

---

## Mandatory Deliverables

You must produce **ALL** of the following:

### 1. `FUTURE_DIRECTIONS.md`
Include 3–5 original research directions.
Each direction must contain:
- a sentence beginning **“The key insight is...”**
- a sentence beginning **“Why now?”**
At least one direction must bridge to a different domain.

Possible themes:
- strongly Rayleigh measures beyond DPPs,
- hyperbolic barrier certificates in convex optimization,
- Lorentzian kernels in machine learning,
- mixed discriminant analogues in statistical physics.

### 2. `RESEARCH_PAPER.md`
A standalone scientific paper that explains:
- the exact theorem proved,
- why the Hessian formula is mathematically surprising,
- how it yields an efficient certificate,
- what experiments support the conjectural extensions,
- what future work this unlocks.

Someone reading only this paper, without code access, must understand the discovery.

### 3. `ARTICLE.md`
Write this in **Scientific American** style.
Explain the ideas, the significance, and the broader picture.
Do **not** focus on formal verification or proof assistant mechanics.
Focus on DPPs, Lorentzian geometry, efficient certificates, and why this matters scientifically.

### 4. Verified algorithm / computational method
Not just theorem statements: provide a mathematically verified certificate-construction procedure.

### 5. `demo.py`
An interactive demonstration that:
- generates random PSD contractions,
- computes the Hessian certificate numerically,
- checks the “at most one positive eigenvalue” condition,
- reports signature defect and runtime,
- compares certificate cost against eigendecomposition,
- optionally visualizes eigenvalue histograms or defect frequencies.

---

## Implementation Notes

- Prefer exact symbolic/algebraic identities in Lean, with numerical experiments in Python.
- If full Fréchet derivative infrastructure is too heavy, formalize the polynomial / principal-minor route and then derive the matrix formula.
- Use nontrivial proof tactics: `rcases` for structural decomposition, `field_simp` for inverse-entry simplification, `by_contra` for signature arguments, and substantial `calc` chains for determinant identities.
- Avoid shallow lemmas whose only content is unfolding definitions.
- Package the main theorem so downstream files can reuse the certificate object.

This is the right scale of ambition: transform Lorentzianity from an abstract property into a computable matrix geometry.

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
