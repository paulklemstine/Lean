Soli Deo Gloria

## Assignment: Direction 5 — Certified DPP Sampling with Lorentzian Guarantees

**Mode:** `prove` + `discover`

Aristotle, do not treat this as a routine formalization of known DPP folklore. The target is a new synthesis:

> **Turn Lorentzian geometry into a certified algorithmic interface for randomized sampling.**

The breakthrough is not merely to sample approximately from a determinantal point process. The breakthrough is to prove that **approximate spectral sampling can emit a mathematically checkable certificate of near–negative dependence**, and that this certificate is governed by a **Lorentzian/Hessian signature condition** rather than by opaque probabilistic arguments. If successful, this opens a new field: **certified geometric randomized algorithms**, where concavity and signature conditions become executable safety certificates.

Build explicitly on:

- `Pythagorean/DPPLorentzian.lean`
  - especially any negative dependence theorem already certified there
  - especially any “spectral bridge” linking PSD kernels, generating polynomials, and Lorentzian structure
- `algorithms.py`
  - especially the Hessian recognizer, which should be elevated from heuristic computation to theorem-guided certified computation

Your goal is to formalize new mathematics, not just an implementation wrapper.

---

## Core Vision

Let `K : Matrix (Fin n) (Fin n) ℝ` be symmetric PSD with eigenvalues in `[0,1]`, so that it defines a marginal kernel of a DPP on `Fin n`. The classical exact sampler factors through eigenspace Bernoulli selection and projection. But exact spectral computation is fragile in realistic settings. We want a theorem of the following kind:

> If an approximate eigendecomposition and approximate Lorentzian/Hessian certificate satisfy explicit algebraic inequalities, then the output law is close in total variation to the target DPP, and its pairwise dependence defects are bounded by an explicit additive error `δ`.

This is the kind of theorem that changes practice: it replaces “trust the floating-point routine” with “verify a short certificate.”

---

## Precise Theorem Targets

You must prove at least **3 substantial theorems**, with nontrivial proofs using induction, `rcases`, `by_contra`, `field_simp`, or multi-step `calc`. Avoid trivial extensionality-only results. At least one theorem must connect DPP/Lorentzian theory to a different domain.

### New definitions to introduce

You must define at least one genuinely new concept not already present in the catalog. Recommended definitions:

1. **Approximate spectral certificate**
   ```lean
   structure ApproxSpectralCert (n : ℕ) where
     U : Matrix (Fin n) (Fin n) ℝ
     Λ : Fin n → ℝ
     ortho_error : ℝ
     recon_error : ℝ
     eig_range : Prop
   ```

2. **Pairwise negative dependence defect**
   ```lean
   def pairwiseNegDepDefect
     {α : Type} [Fintype α]
     (μ : Finset α → ℝ) : ℝ := ...
   ```
   Intended meaning: the least `δ ≥ 0` such that for all distinct `i,j`,
   \[
   \Pr[i,j \in S] \le \Pr[i \in S]\Pr[j \in S] + \delta.
   \]

3. **Lorentzian empirical certificate**
   ```lean
   structure LorentzianEmpiricalCert (n : ℕ) where
     p : MvPolynomial (Fin n) ℝ
     hessianWitness : Prop
     signatureDefect : ℝ
   ```

4. Optionally, a bundled notion of **certified approximate DPP law**
   ```lean
   structure CertifiedApproxDPP (n : ℕ) where
     μ : Finset (Fin n) → ℝ
     tvError : ℝ
     negDepError : ℝ
     spectralCert : ApproxSpectralCert n
     lorentzianCert : LorentzianEmpiricalCert n
   ```

These definitions should be mathematically meaningful, not merely data containers.

---

## Theorem 1: Spectral perturbation gives certified approximate marginals

Formalize a theorem showing that if `K` and `K'` are close, then their singleton and pairwise inclusion probabilities are close, with explicit defect bounds.

### Mathematical statement
For symmetric PSD contractions `K, K' ∈ ℝ^{n×n}`,
if
\[
\|K-K'\|_{\max} \le \eta,
\]
then for all distinct `i,j`,
\[
\big|\Pr_K(i\in S)-\Pr_{K'}(i\in S)\big| \le \eta,
\]
and
\[
\big|\Pr_K(i,j\in S)-\Pr_{K'}(i,j\in S)\big|
= \left| \det(K_{\{i,j\}})-\det(K'_{\{i,j\}})\right|
\le C(\|K\|,\|K'\|)\eta,
\]
for an explicit constant that you prove in the 2×2 case.

This is not yet full TV control, but it is the right certified gateway theorem: **approximate spectral data imply approximate dependence inequalities**.

### Suggested Lean 4 type signature
```lean
theorem pairwise_inclusion_det_perturb_bound
  {n : ℕ}
  (K K' : Matrix (Fin n) (Fin n) ℝ)
  (h_symm : K.IsSymm)
  (h'_symm : K'.IsSymm)
  (h_eta : ∀ i j, |K i j - K' i j| ≤ η) :
  ∀ i j, i ≠ j →
    |((K i i) * (K j j) - (K i j) * (K j i))
      - ((K' i i) * (K' j j) - (K' i j) * (K' j i))|
      ≤ (|K i i| + |K j j| + |K' i j| + |K j i| + 1) * η
```

You may sharpen the constant if convenient. The key is a real theorem with a nontrivial proof using algebraic expansion and inequalities, not a toy bound.

### Why this matters
This theorem turns the exact DPP determinant formula into a **robust certificate theorem**. It is the first step from symbolic DPP theory to numerically stable, checkable randomized algorithms.

---

## Theorem 2: Lorentzian certificate implies pairwise negative dependence up to defect

This is the conceptual center of the project.

### Mathematical statement
Let `p` be a multiaffine polynomial with nonnegative coefficients encoding an empirical law on subsets of `Fin n`. Suppose `p` is normalized and its Hessian on the positive orthant has at most one positive eigenvalue, up to an explicit signature defect `δ`. Then the induced law satisfies pairwise negative dependence up to additive error controlled by `δ`.

In exact Lorentzian theory, the Hessian signature condition yields strong log-concavity and negative dependence. You must prove an **approximate version** suitable for certificates.

A clean finite-dimensional target is:

For all distinct `i,j`,
\[
\partial_i\partial_j p(\mathbf{1}) \, p(\mathbf{1})
\le \partial_i p(\mathbf{1}) \partial_j p(\mathbf{1}) + \delta.
\]

When `p(1)=1`, this becomes:
\[
\Pr[i,j\in S] \le \Pr[i\in S]\Pr[j\in S] + \delta.
\]

### Suggested Lean 4 type signature
```lean
theorem lorentzian_cert_pairwise_negdep
  {n : ℕ}
  (p : MvPolynomial (Fin n) ℝ)
  (δ : ℝ)
  (h_nonneg : ∀ s, 0 ≤ coeff s p)
  (h_multiaffine : IsMultiaffine p)
  (h_norm : eval (fun _ => (1 : ℝ)) p = 1)
  (h_cert : ApproxLorentzianOnes p δ) :
  ∀ i j : Fin n, i ≠ j →
    eval (fun _ => (1 : ℝ)) (pderiv i (pderiv j p))
      ≤ eval (fun _ => (1 : ℝ)) (pderiv i p) *
        eval (fun _ => (1 : ℝ)) (pderiv j p) + δ
```

You may need to define `ApproxLorentzianOnes p δ` in a tractable way, e.g. as a quadratic-form inequality on the Hessian at `1`. If full Hessian-eigenvalue formalization is too heavy, define an equivalent certificate in terms of:
\[
v^\top H_p(\mathbf{1}) v \le \delta \|v\|^2
\quad \text{for all } v \perp \mathbf{1},
\]
or a finite-coordinate version sufficient to derive pairwise inequalities.

### Why this is revolutionary
This theorem says: **negative dependence is not just a hidden structural fact; it is certifiable by a finite geometric witness**. That is a new interface between algebraic geometry, probability, and trustworthy algorithms.

---

## Theorem 3: Certified sampler correctness theorem

You should state and prove a theorem connecting a verified algorithmic output to the mathematical guarantees.

### Mathematical statement
Suppose an algorithm returns:
- an approximate eigendecomposition certificate for `K`,
- an empirical multiaffine generating polynomial `p̂`,
- a Lorentzian certificate defect `δ`,
- and a reconstruction error `ε`.

Then the produced law `μ̂` satisfies:
1. pairwise negative dependence defect at most `δ + Cε`,
2. marginal errors bounded by `C'ε`,
3. if exact DPP normalization constraints are certified, then `μ̂` is a bona fide probability law.

You do **not** need a full formal complexity proof inside Lean, but the theorem must make the certificate-checking pipeline mathematically precise.

### Suggested Lean 4 type signature
```lean
theorem certifiedApproxDPP_sound
  {n : ℕ}
  (K : Matrix (Fin n) (Fin n) ℝ)
  (μ : Finset (Fin n) → ℝ)
  (cert : CertifiedApproxDPP n)
  (h_kernel : IsValidDPPKernel K)
  (h_models : cert.ModelsKernel K μ ε δ) :
  pairwiseNegDepDefect cert.μ ≤ δ + C * ε
```

If necessary, replace `ModelsKernel` with a more explicit conjunction of hypotheses. The theorem should be a genuine mathematical soundness theorem for the certificate abstraction you define.

### Why this matters
This elevates DPP sampling from “an algorithm that seems to work” to a **proof-carrying randomized computation**. That is exactly the sort of theorem that can move DPPs into high-stakes applications.

---

## Theorem 4 (Cross-domain theorem): Lorentzian certificate as a discrete hyperbolic/physical stability witness

You must include at least one theorem bridging to another domain. The strongest option is to connect Lorentzian DPP certificates to **hyperbolic PDE / statistical physics style stability**.

### Candidate cross-domain theorem
Show that for a multiaffine generating polynomial `p`, the Lorentzian quadratic-form inequality at `1` implies a discrete susceptibility bound:
\[
\sum_{i,j} a_i a_j \,\mathrm{Cov}(X_i,X_j) \le \delta \|a\|^2
\]
for all coefficient vectors `a` orthogonal to the all-ones direction.

This bridges:
- **probability / DPPs** (covariance)
- **Lorentzian geometry** (Hessian signature)
- **statistical physics** (susceptibility/compressibility inequalities)

### Suggested Lean 4 type signature
```lean
theorem lorentzian_covariance_susceptibility_bound
  {n : ℕ}
  (p : MvPolynomial (Fin n) ℝ)
  (δ : ℝ)
  (a : Fin n → ℝ)
  (h_sum_zero : (∑ i, a i) = 0)
  (h_prob : EncodesProbabilityLaw p)
  (h_cert : ApproxLorentzianOnes p δ) :
  covarianceQuadraticForm p a ≤ δ * ∑ i, (a i)^2
```

Even a pairwise-expanded finite version is valuable. This theorem would make the project intellectually larger than DPPs: it becomes a statement about **geometric control of fluctuations**.

### Application keywords
`determinantal point processes`, `negative dependence`, `Lorentzian polynomials`, `strong log-concavity`, `certified randomized algorithms`, `spectral perturbation`, `stability certificates`, `statistical physics`, `safe machine learning`, `diverse subset selection`, `experimental design`, `autonomous systems`

---

## Conjecture with testable prediction

You must include at least one falsifiable conjecture and a computational disproof protocol.

### Recommended conjecture
> **Conjecture (dimension-free defect transfer).**  
> There exists a universal constant `C > 0` such that for every `n`, every PSD contraction kernel `K`, and every certified approximate sampler producing empirical generating polynomial `p̂`, if the reconstruction error of the kernel is at most `ε` and the Lorentzian signature defect is at most `δ`, then
> \[
> d_{\mathrm{TV}}(\hat{\mu}, \mu_K) \le C(\varepsilon + \delta),
> \]
> independent of `n`.

This is bold and falsifiable.

### Computational test
For random PSD contractions `K` of increasing dimension:
1. compute exact or high-precision DPP statistics for small/moderate `n`,
2. run the approximate spectral sampler,
3. estimate TV distance empirically or via exhaustive enumeration for small `n`,
4. compute Lorentzian signature defect using the Hessian recognizer,
5. test whether `d_TV / (ε + δ)` remains uniformly bounded.

A single family where this ratio grows with `n` would refute the conjecture.

---

## Proof Strategy Architecture

You must pursue at least **2–3 proof paths**, and explicitly document which is most promising.

### Strategy A: Local determinant algebra + derivative identities
Best for Theorems 1 and 3.

1. Express singleton and pairwise inclusion probabilities via diagonal entries and 2×2 principal minors.
2. Expand determinant differences explicitly:
   \[
   ab-cd-a'b'+c'd'
   \]
   and bound term-by-term using triangle inequality.
3. Convert polynomial derivative evaluations at `1` into probabilities:
   - `∂_i p(1)` = singleton marginal
   - `∂_i∂_j p(1)` = pairwise marginal
4. Combine perturbation estimates with the exact negative dependence theorem from `Pythagorean/DPPLorentzian.lean`.

**Why promising:** avoids heavy spectral analysis and keeps everything in finitistic algebra that Lean handles well.

### Strategy B: Hessian quadratic form route
Best for Theorems 2 and 4.

1. Define `ApproxLorentzianOnes p δ` as a quadratic-form inequality for the Hessian at `1`.
2. Choose test vectors of the form `e_i - e_j`, `e_i + e_j - 2e_k`, or more generally vectors orthogonal to `1`.
3. Expand
   \[
   v^\top H_p(1)v
   \]
   into derivative coefficients and isolate the pairwise negative dependence inequality.
4. Use multiaffineness to simplify second derivatives and eliminate diagonal terms if appropriate.

**Why promising:** captures the Lorentzian mechanism directly and yields the strongest cross-domain statements.

### Strategy C: Spectral bridge through generating polynomials
Best if the catalog already has substantial spectral-to-Lorentzian lemmas.

1. Use the spectral bridge in `Pythagorean/DPPLorentzian.lean` to move from PSD kernel data to generating polynomial data.
2. Show approximate reconstruction preserves enough of the bridge to produce an approximate Lorentzian certificate.
3. Deduce negative dependence defect from the approximate certificate.

**Why promising:** conceptually deepest and closest to the research vision.  
**Risk:** may require more infrastructure than is practical in one cycle.

**Recommendation:**  
Lead with **Strategy A + B** for solid theorem completion, then integrate pieces of **Strategy C** where catalog support already exists.

---

## Lean Implementation Guidance

You are working in Lean 4 with Mathlib. Formalize with an eye toward reusable infrastructure.

### Suggested supporting lemmas
You will likely need lemmas of the following flavor:

```lean
lemma det_fin_two_explicit
  (a b c d : ℝ) :
  Matrix.det (!![![a, b], ![c, d]]) = a*d - b*c := ...
```

```lean
lemma pderiv_eval_one_eq_marginal
  {n : ℕ} (p : MvPolynomial (Fin n) ℝ) :
  ...
```

```lean
lemma hessian_quadform_bound_of_approx_lorentzian
  {n : ℕ} (p : MvPolynomial (Fin n) ℝ) (δ : ℝ) :
  ...
```

```lean
lemma pairwise_negdep_of_hessian_test_vector
  {n : ℕ} (p : MvPolynomial (Fin n) ℝ) :
  ...
```

Expect to use:
- `Matrix`
- `MvPolynomial`
- finite sums over `Fin n`
- explicit `calc` chains
- `field_simp` where rational expressions appear
- `by_contra` for signature/inequality arguments
- `rcases` for unpacking certificate structures

Avoid theorem statements whose proofs collapse to automation. The point is to build real mathematical mechanisms.

---

## File and artifact expectations

Create a focused Lean file, e.g.
- `CertifiedDPP/CertifiedSamplingLorentzian.lean`

and ensure it contains:
- at least one new structure definition,
- at least 3 substantial theorems,
- at least one cross-domain theorem,
- one explicit conjecture in comments or markdown, tied to computational tests.

Also produce the following mandatory deliverables:

### 1. `FUTURE_DIRECTIONS.md`
Include **3–5 original research directions**, each with:
- a title,
- **“The key insight is...”**
- **“Why now?”**
At least one direction must bridge to a different domain, such as:
- statistical physics,
- convex optimization,
- causal inference,
- quantum sampling,
- safety-critical control.

### 2. `RESEARCH_PAPER.md`
A standalone scientific paper that explains:
- the problem,
- the new definitions,
- the exact theorem statements,
- proof ideas,
- why Lorentzian certificates matter,
- algorithmic implications,
- limitations and next steps.

Someone reading only this paper must understand the discovery without seeing the code.

### 3. `ARTICLE.md`
Write in **Scientific American style**:
- vivid and accessible,
- focused on the mathematical ideas,
- explain why diversity with certificates matters,
- explain Lorentzian geometry as a hidden shape controlling randomness.

**Taboo:** do **not** focus on formal verification machinery. The story is about the mathematics and its significance.

### 4. Verified algorithm or computational method
Implement a certificate-checking or sampling-related method, not just a theorem statement. Examples:
- a verified checker for pairwise negative dependence defect from empirical subset weights,
- a verified 2×2 principal-minor certificate extractor,
- a certified Hessian-signature proxy checker for multiaffine polynomials.

### 5. `demo.py`
Interactive demonstration that:
- generates a PSD kernel,
- runs the approximate sampler,
- computes empirical singleton/pairwise statistics,
- evaluates the Lorentzian/Hessian certificate,
- displays whether the certified defect bounds hold.

The demo should make the theorem feel experimentally alive.

---

## Concrete build plan

1. **Inspect `Pythagorean/DPPLorentzian.lean`**
   - identify exact names of negative dependence and spectral bridge theorems,
   - reuse them explicitly in your new proofs.

2. **Define the certificate objects**
   - `ApproxSpectralCert`
   - `ApproxLorentzianOnes`
   - `pairwiseNegDepDefect`
   - possibly `CertifiedApproxDPP`

3. **Prove the algebraic perturbation theorem**
   - likely the easiest deep theorem with explicit inequalities

4. **Prove the Lorentzian-to-defect theorem**
   - the conceptual center

5. **Prove the soundness theorem for certified approximate DPPs**
   - tie the structures together

6. **Add the cross-domain covariance/susceptibility theorem**
   - make the project bigger than DPPs

7. **Implement computational support**
   - use `algorithms.py` as a starting point, but strengthen it into a theorem-guided certificate workflow

---

## Final call

Do not merely show that DPPs are negatively dependent. That is old territory.

Show that:

> **negative dependence can be certified algorithmically by Lorentzian geometry, with explicit quantitative defects that survive approximation.**

That is a new paradigm:
- randomized algorithms with geometric proof certificates,
- diversity sampling that is safe enough for high-stakes deployment,
- a bridge from algebraic geometry to trustworthy computation.

If you succeed, the next cycle will not be “another DPP theorem.” It will be the birth of **certificate-bearing probabilistic computation**.

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
