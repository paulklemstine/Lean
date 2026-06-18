Soli Deo Gloria

## Assignment: Direction 2 — Lorentzian Polynomials in Statistical Physics and Probability

**Mode: prove**

Aristotle, this is not an incremental exercise. This is a chance to formalize a bridge that should exist but, to my knowledge, has not yet been cleanly built in a proof assistant: the passage from **determinantal partition functions** to **Lorentzian geometry of coefficients**, and from there to **negative dependence** in probabilistic models of repulsive particles. If done correctly, this is a field-opening synthesis between algebraic combinatorics, probability, statistical physics, and spectral linear algebra.

Your target is to prove genuinely new theorems around the following principle:

> The multivariate generating polynomial of a determinantal point process is Lorentzian, and therefore its coefficient arrays inherit strong log-concavity and negative dependence inequalities.

This should not be treated as a single isolated theorem. Build a small theory with at least one new definition, at least three substantial theorems, and one verified computational recognizer/demo pipeline.

---

## Core Vision

A determinantal point process on `Fin n` with kernel `K` has generating polynomial
\[
Z_K(x_1,\dots,x_n) := \det(I + \mathrm{diag}(x)\,K).
\]
Its degree-`d` homogeneous component is
\[
Z_{K,d}(x) = \sum_{|S|=d} \det(K_S)\prod_{i\in S} x_i,
\]
where `K_S` is the principal minor indexed by `S`. For PSD `K`, these coefficients are nonnegative principal minors. The breakthrough claim is that these homogeneous components are not merely stable or log-concave in some weak sense: they are **Lorentzian**, hence satisfy the Hodge-style inequalities that force negative dependence.

This creates a formally verified route:

**PSD kernel → determinantal generating polynomial → Lorentzian homogeneous layers → ultra log-concavity / Rayleigh inequalities → negative dependence bounds.**

That route matters because it exports geometric inequalities into probability in a way that is computationally testable and algorithmically exploitable.

---

## Precise Formal Targets

You should introduce a new definition capturing the DPP generating polynomial and its homogeneous layers in a way that interfaces with existing Lorentzian-recognition theorems from the catalog.

### New definitions to introduce

At minimum, define something of the following shape:

```lean
def dppPartitionFunction {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ) :
    MvPolynomial (Fin n) ℝ := ...

def dppHomogeneousComponent {n d : ℕ} (K : Matrix (Fin n) (Fin n) ℝ) :
    MvPolynomial (Fin n) ℝ :=
  homogeneousComponent d (dppPartitionFunction K)

def pairInclusionWeight {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ) (i j : Fin n) : ℝ := ...
```

If the catalog already has a suitable `homogeneousComponent`, use it directly; otherwise define the finite-support projection and prove the compatibility lemmas you need.

I also strongly recommend introducing a new structure expressing the probabilistic-algebraic interface:

```lean
structure DPPKernel (n : ℕ) where
  K : Matrix (Fin n) (Fin n) ℝ
  symm : K.IsSymm
  psd : K.PosSemidef
```

This is mathematically natural and not merely cosmetic: it lets you state theorems at the right conceptual level.

---

## Theorem Cluster to Prove

You must prove at least 3 substantial theorems. The following package is ambitious but coherent.

### Theorem 1: homogeneous determinantal expansion
This is the algebraic backbone.

```lean
theorem dpp_homogeneousComponent_eq_principalMinorSum
    {n d : ℕ} (K : Matrix (Fin n) (Fin n) ℝ) :
    dppHomogeneousComponent (d := d) K
      =
    ∑ S : Finset (Fin n),
      if hS : S.card = d then
        C (K.principalSubmatrix S).det *
          ∏ i in S, (MvPolynomial.X i)
      else 0
```

You may need to adjust the exact principal-submatrix API and monomial encoding to fit Mathlib. The point is exactness: the degree-`d` piece is the generating function of principal minors.

**Why this matters:** this theorem turns the partition function into a combinatorial object whose coefficients are manifestly probabilistic weights. It is the point where linear algebra becomes discrete probability.

---

### Theorem 2: Lorentzianity of homogeneous DPP layers
This is the flagship theorem.

```lean
theorem dpp_partition_function_lorentzian
    {n d : ℕ} (K : Matrix (Fin n) (Fin n) ℝ)
    (hKsymm : K.IsSymm) (hKpsd : K.PosSemidef) :
    IsBrandenHuhLorentzian d (dppHomogeneousComponent (d := d) K)
```

If the catalog’s Lorentzian predicate is parameterized differently, adapt the signature exactly to the existing API. But do not weaken the mathematical statement.

If the strongest theorem is currently too difficult at full generality, prove the following staged versions in one file:

```lean
theorem dpp_partition_function_lorentzian_rank_one
    {n d : ℕ} (v : Fin n → ℝ) :
    IsBrandenHuhLorentzian d
      (dppHomogeneousComponent (d := d) (rankOneMatrix v))

theorem dpp_partition_function_lorentzian_diagonal
    {n d : ℕ} (w : Fin n → ℝ) (hw : ∀ i, 0 ≤ w i) :
    IsBrandenHuhLorentzian d
      (dppHomogeneousComponent (d := d) (Matrix.diagonal w))

theorem dpp_partition_function_lorentzian
    {n d : ℕ} (K : Matrix (Fin n) (Fin n) ℝ)
    (hKsymm : K.IsSymm) (hKpsd : K.PosSemidef) :
    IsBrandenHuhLorentzian d (dppHomogeneousComponent (d := d) K)
```

The diagonal and rank-one cases are not fallback trivia; they are strategically useful base cases and sanity checks for the full theorem.

---

### Theorem 3: negative dependence / pairwise negative correlation
This is the probabilistic payoff.

State it in coefficient language if you do not yet have a full probability measure API, but make the probabilistic interpretation explicit in `RESEARCH_PAPER.md`.

A coefficient-form theorem might look like:

```lean
theorem dpp_pairwise_negative_dependence
    {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ)
    (hKsymm : K.IsSymm) (hKpsd : K.PosSemidef)
    (i j : Fin n) (hij : i ≠ j) :
    pairInclusionWeight K i j ≤ singleInclusionWeight K i * singleInclusionWeight K j
```

Or, if you define the normalized DPP measure:

```lean
theorem dpp_pairwise_negative_correlation
    {n : ℕ} (D : DPPKernel n) (i j : Fin n) (hij : i ≠ j) :
    dppProb₂ D i j ≤ dppProb₁ D i * dppProb₁ D j
```

This theorem must not be a trivial numerical corollary. It should genuinely use the Lorentzian/Hodge machinery or a Rayleigh inequality derived from it.

---

### Theorem 4: cross-domain theorem linking statistical physics and spectral theory
You are required to include at least one theorem bridging domains. Here is the right bridge:

```lean
theorem dpp_partitionFunction_eval_eigenvalues
    {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ)
    (hKsymm : K.IsSymm) :
    MvPolynomial.aeval (fun _ => (1 : ℝ)) (dppPartitionFunction K)
      = ∏ i, (1 + K.eigenvalues i)
```

The exact spectral API may differ; if full eigenvalue indexing is awkward, prove instead the scalar specialization
\[
Z_K(t,\dots,t)=\det(I+tK)
\]
and connect this to the characteristic polynomial or elementary symmetric functions of eigenvalues.

A Lean-friendly version:

```lean
theorem dpp_partitionFunction_uniformSpecialization
    {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ) (t : ℝ) :
    MvPolynomial.aeval (fun _ => t) (dppPartitionFunction K)
      = Matrix.det (1 + t • K)
```

Then add a corollary expressing the degree-`d` coefficient as the `d`th elementary symmetric polynomial in the eigenvalues under symmetry/diagonalizability assumptions.

**Why this matters:** it connects random subset models to spectral statistics, opening a channel to random matrix theory and interacting particle systems.

---

## Lean 4 Type-Signature Guidance

Use exact Mathlib names where available, but target signatures of this kind:

```lean
theorem dpp_partition_function_uniformSpecialization
    {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ) (t : ℝ) :
    MvPolynomial.aeval (fun _ : Fin n => t) (dppPartitionFunction K)
      = Matrix.det (1 + t • K)
```

```lean
theorem dpp_homogeneousComponent_eq_principalMinorSum
    {n d : ℕ} (K : Matrix (Fin n) (Fin n) ℝ) :
    dppHomogeneousComponent (d := d) K =
      ∑ S : Finset (Fin n),
        if hS : S.card = d then
          MvPolynomial.C ((K.principalSubmatrix S).det) *
            ∏ i in S, MvPolynomial.X i
        else 0
```

```lean
theorem dpp_partition_function_lorentzian
    {n d : ℕ} (K : Matrix (Fin n) (Fin n) ℝ)
    (hKsymm : K.IsSymm) (hKpsd : K.PosSemidef) :
    IsBrandenHuhLorentzian d (dppHomogeneousComponent (d := d) K)
```

```lean
theorem dpp_pairwise_negative_dependence
    {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ)
    (hKsymm : K.IsSymm) (hKpsd : K.PosSemidef)
    (i j : Fin n) (hij : i ≠ j) :
    pairInclusionWeight K i j ≤ singleInclusionWeight K i * singleInclusionWeight K j
```

If exact APIs force a reformulation, preserve the mathematics, not the syntax.

---

## Proof Strategy Architecture

You must pursue at least 2–3 real proof avenues and explain in comments or notes which one is most promising.

### Strategy A: principal-minor expansion → known Lorentzian criterion
1. Expand `det (I + diag(X) * K)` via Leibniz/Cauchy–Binet to identify the homogeneous degree-`d` part with the principal-minor generating polynomial.
2. Use PSD of `K` to show all coefficients are nonnegative.
3. Invoke or extend a catalog Lorentzian recognition theorem from `Pythagorean/LorentzianRecognitionComplete.lean` for principal-minor generating polynomials, if available, or reduce to a certified criterion there.

**Why promising:** it matches the combinatorial definition of Lorentzian polynomials most closely and gives direct access to coefficient inequalities.

---

### Strategy B: stability-first route, then transfer stability → Lorentzianity
1. Prove `dppPartitionFunction K` is real stable for PSD/symmetric `K` using determinantal stability of `det(A + diag(z))` or a specialized matrix half-plane argument.
2. Use the Brändén–Huh theorem: homogeneous stable polynomials with nonnegative coefficients are Lorentzian.
3. Deduce pairwise negative correlation from Rayleigh inequalities for stable/Lorentzian polynomials.

**Why this may be the strongest route:** determinantal polynomials are classically stable, and the stability-to-Lorentzian bridge is conceptually clean. If the catalog already contains stability machinery or Lorentzian recognition from Hessian signatures, this route may minimize low-level determinant algebra.

---

### Strategy C: spectral decomposition / Gram factorization
1. Use PSD to write `K = Bᵀ B` or spectrally diagonalize `K = Uᵀ D U`.
2. Rewrite principal minors using Cauchy–Binet as sums of squares / mixed discriminants.
3. Show the coefficient sequence satisfies the Lorentzian inequalities through closure of Lorentzian polynomials under suitable linear transforms, convolution, or polarization.

**Why valuable:** this exposes the physics directly. A PSD kernel is a Gram matrix of interacting modes; the DPP partition function becomes a geometric object measuring repulsion in phase space. Even if this route is not the shortest formal proof, it is likely the best narrative route for `RESEARCH_PAPER.md`.

**Recommended priority:** pursue **Strategy B** if the catalog has enough stable/Lorentzian infrastructure; otherwise start with **Strategy A** and use Strategy C for insight and special cases.

---

## Required Deep Tactics / Proof Texture

Your file must contain at least 3 nontrivial theorems with real proof structure. Concretely, I expect to see proofs involving:
- `induction` on degree or finite set cardinality,
- `rcases` decomposition of subset/eigenvalue/principal-minor cases,
- `by_contra` in inequality or support arguments,
- `field_simp` when normalizing probability ratios,
- multi-step `calc` blocks for determinant / coefficient identities.

Do not let the file devolve into a sequence of one-line simp lemmas. The mathematics here demands structural proofs.

---

## How to Build on the Catalog

You cited:

- `Pythagorean/LorentzianRecognitionComplete.lean`

You should explicitly inspect and leverage the strongest vetted theorem there, especially any result of the form:
- a spectral or Hessian-based recognizer for `IsBrandenHuhLorentzian`,
- closure properties under homogeneous projection,
- coefficient positivity + Hessian signature criteria.

Your job is not just to mention the catalog but to **thread your theorem through it**. For example:

- If there is a theorem recognizing Lorentzianity from a quadratic form signature on all directional derivatives, use the determinantal formula to compute those derivatives as lower-order principal-minor sums.
- If there is a complete recognizer for multiaffine homogeneous polynomials with nonnegative coefficients, note that `dppHomogeneousComponent` is multiaffine and homogeneous, so you only need the right local Hessian inequalities.
- If there is a theorem already handling elementary symmetric polynomials, use the spectral specialization as a reduction check in diagonal cases.

This is where rigor meets architecture.

---

## Cross-Domain Connections You Must Highlight

This project should explicitly connect at least two of the following domains in theorem statements, examples, or discussion:

1. **Statistical physics**  
   DPPs model repulsive fermionic systems and exclusion statistics. The partition function viewpoint makes the polynomial a discrete analog of a grand canonical ensemble.

2. **Random matrix theory / spectral theory**  
   Uniform specialization of the partition function produces spectral elementary symmetric statistics of `K`.

3. **Algebraic combinatorics / Hodge theory**  
   Lorentzianity is the algebraic shadow of Hodge-Riemann relations; here it governs probabilistic repulsion.

4. **Machine learning**  
   DPPs are used for diverse subset selection, summarization, and experimental design. Verified negative dependence yields certified diversity guarantees.

5. **Optimization / algorithms**  
   Lorentzian structure suggests efficient certification heuristics for negative dependence using Hessian signatures and coefficient tests.

At least one theorem should make one of these bridges mathematically explicit, not just motivationally.

---

## Falsifiable Conjecture with Computational Test

You must include at least one conjecture that could fail and a clear test for it.

Here is a strong candidate:

### Conjecture: strict Lorentzianity from positive definiteness
For strictly positive definite kernels, every nonzero homogeneous component is **strictly** Lorentzian.

```lean
conjecture dpp_partition_function_strictly_lorentzian
    {n d : ℕ} (K : Matrix (Fin n) (Fin n) ℝ)
    (hKsymm : K.IsSymm) (hKpd : K.PosDef) :
    IsStrictlyLorentzian d (dppHomogeneousComponent (d := d) K)
```

### Computational test
For random symmetric positive definite matrices with `n ≤ 8`:
1. compute `dppPartitionFunction K`,
2. extract homogeneous degree-`d` component,
3. run the catalog spectral/Hessian recognizer for strict Lorentzianity,
4. compare failures against near-rank-deficient spectra.

A single counterexample falsifies the conjecture. This is exactly the kind of conjecture that should drive experiment.

A second optional conjecture, more daring:

### Conjecture: Lorentzianity is equivalent to PSD representability for multiaffine determinantal generating polynomials
Any multiaffine homogeneous Lorentzian polynomial with nonnegative coefficients and normalized constant term arises as a homogeneous component of some PSD determinantal partition function.

This is probably false in full generality, which makes it scientifically useful. Test small `n,d` by coefficient fitting against principal-minor varieties.

---

## Verified Algorithm / Computational Method

You are required to produce not just theorems but a computational method.

### Algorithmic deliverable
Implement a verified procedure that, for a PSD matrix `K` and degree `d`:
1. computes the homogeneous component `dppHomogeneousComponent K d`,
2. extracts coefficient data indexed by `d`-subsets,
3. computes pairwise inclusion weights and correlation ratios,
4. optionally applies the catalog Lorentzian recognizer / Hessian signature test,
5. certifies the inequality
   \[
   \Pr[i,j\in S] \le \Pr[i\in S]\Pr[j\in S]
   \]
   in the finite examples.

This can be semi-symbolic in Lean with a practical mirror in Python.

Possible Lean-facing signature:

```lean
def certifyPairwiseNegativeDependence
    {n : ℕ} (K : Matrix (Fin n) (Fin n) ℚ) :
    Option (∀ i j : Fin n, i ≠ j →
      pairInclusionWeight (K.map (Rat.castHom ℝ)) i j ≤
      singleInclusionWeight (K.map (Rat.castHom ℝ)) i *
      singleInclusionWeight (K.map (Rat.castHom ℝ)) j) := ...
```

Even if the final executable certification sits partly in `demo.py`, the mathematical criterion it uses should be justified by proved lemmas.

---

## demo.py Requirements

Your `demo.py` should:
- generate random PSD matrices `K = A.T @ A`,
- build the determinantal partition function for `n ≤ 8`,
- extract homogeneous components,
- numerically test Lorentzianity via the catalog-inspired spectral/Hessian criterion,
- compute all pairwise correlations,
- print or visualize which inequalities are tight,
- compare diagonal, rank-one, and generic PSD examples.

An interactive slider over spectrum or rank would be ideal:
- vary eigenvalue spread,
- observe how correlation ratios change,
- identify near-degenerate cases where strict Lorentzianity may fail.

This is not ornamental. It is the experimental arm of the theory.

---

## Revolutionary Significance

If you succeed, you will have done more than verify a known probability fact. You will have formalized a new **structural doctrine**:

> Repulsive probabilistic laws are governed by Lorentzian geometry.

That doctrine has consequences.

- In **probability**, it provides a certified path from algebraic geometry to negative dependence.
- In **statistical physics**, it reframes fermionic partition functions as Hodge-theoretic objects.
- In **machine learning**, it offers mathematically certified diversity guarantees for DPP-based selection methods.
- In **spectral theory**, it interprets elementary symmetric eigenvalue statistics as shadows of Lorentzian coefficient geometry.
- In **algorithm design**, it suggests new recognizers and certification pipelines for repulsive measures.

This is exactly the kind of result that makes people say: “I did not expect Hodge theory, determinant identities, and randomized subset selection to live in the same theorem.”

---

## Mandatory Deliverables

You must produce **all** of the following:

1. **A Lean file** with:
   - at least one novel definition,
   - at least 3 substantial theorems,
   - minimized `sorry`,
   - at least one cross-domain theorem,
   - at least one explicit conjecture.

2. **FUTURE_DIRECTIONS.md**
   - 3–5 research directions.
   - Each direction must include the exact sentences:
     - **“The key insight is...”**
     - **“Why now?”**
   - At least one direction must bridge to a different domain, such as quantum information, random matrix universality, or matroid Hodge theory.

3. **RESEARCH_PAPER.md**
   - A standalone scientific paper.
   - A reader with no access to code must understand:
     - the main theorem,
     - why it matters,
     - how it connects DPPs, Lorentzian polynomials, and negative dependence,
     - what comes next.
   - Include examples, proof sketch architecture, and computational findings.

4. **ARTICLE.md**
   - Scientific American style.
   - Engaging and accessible.
   - Do **not** focus on formal verification machinery.
   - Focus on the ideas: repulsive randomness, hidden geometric order, and why this matters for science and algorithms.

5. **A verified algorithm or computational method**
   - not just theorem statements,
   - with clear correctness justification.

6. **demo.py**
   - interactive or exploratory,
   - demonstrates the theorem numerically on random PSD kernels,
   - tests the conjecture,
   - visualizes pairwise negative correlations.

---

## Application Keywords

Lorentzian polynomials; determinantal point processes; negative dependence; Rayleigh inequalities; strong log-concavity; real stable polynomials; principal minors; Cauchy–Binet; Hodge theory; fermionic partition functions; repulsive particle systems; random matrix theory; spectral statistics; diverse subset selection; certified randomized algorithms; algebraic combinatorics; statistical physics; machine learning; multiaffine generating polynomials; Hessian signature recognizer.

---

## Final Charge

Do not settle for a cosmetic formalization of a folklore identity. Build the algebraic-probabilistic machine. Make the determinant speak the language of Hodge theory, and make Hodge theory deliver a certified theorem about randomness. This direction has the right shape for a genuine conceptual advance.

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
