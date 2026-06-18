## Assignment: Direction 1: Strongly Rayleigh Extension

**Mode:** prove / discover

Prove genuinely new theorems at the interface of **strongly Rayleigh measures, real stable polynomials, Lorentzian geometry, and algorithmic spectral certification**. This should not be a minor generalization of the DPP case: the goal is to replace determinant-specific structure by a polynomial-intrinsic Hessian theory that applies to broad negative dependence phenomena.

The central vision is this:

> **Break the determinant barrier.**  
> Show that the Lorentzian/Hessian certificate phenomenon is not an artifact of determinantal formulas, but a structural consequence of real stability itself for multiaffine generating polynomials of strongly Rayleigh measures.

If successful, this opens a new field: **algorithmic Lorentzian certification for negative dependence**, with applications to matroids, random spanning structures, spectral sampling, and log-concavity in combinatorics and optimization.

---

## Core Mathematical Objective

Let `μ : Finset (Fin n) → ℝ≥0∞` or, more formally for Lean-friendly algebra, let the measure be encoded by a multiaffine polynomial
\[
g_\mu(z_1,\dots,z_n)=\sum_{S \subseteq [n]} \mu(S)\prod_{i\in S} z_i
\]
with nonnegative coefficients. Assume `g_μ` is **real stable**, equivalently that `μ` is strongly Rayleigh in the usual multiaffine setting.

You should define a polynomial-intrinsic Hessian certificate from logarithmic/resolvent data and prove that it recovers the DPP certificate from the catalog, while extending beyond determinant representations.

### Precise target theorem family

Introduce a new notion, e.g.

- `StronglyRayleighGenPoly`
- `HasLorentzianHessianCertificate`
- `logHessianForm`
- `conditionalNSDOnCodimOne`

These should be new definitions, not aliases.

A mathematically precise target is:

> **Theorem A (Strongly Rayleigh Hessian negativity).**  
> Let \(g \in \mathbb{R}[z_1,\dots,z_n]\) be multiaffine, homogeneous of degree \(d \ge 2\), with nonnegative coefficients, and real stable. Then for every \(x \in \mathbb{R}_{>0}^n\), the Hessian of \(\log g\) at \(x\),
> \[
> H_{\log g}(x) = \left(\partial_i \partial_j \log g(x)\right)_{i,j},
> \]
> is negative semidefinite on the codimension-one subspace orthogonal to the gradient direction \(Dg(x)\) (equivalently, it has at most one positive eigenvalue after the appropriate sign normalization).

This is the real-stability-to-Lorentzian bridge in its cleanest form.

A stronger and more certificate-oriented formulation is:

> **Theorem B (Lorentzian Hessian certificate from directional derivatives).**  
> Let \(g\) be as above. Define
> \[
> Q_{g,x}(u,v) := g(x)\,D_uD_v g(x) - D_u g(x)\,D_v g(x).
> \]
> Then for every \(x \in \mathbb{R}_{>0}^n\), the quadratic form \(u \mapsto Q_{g,x}(u,u)\) is nonpositive on the hyperplane
> \[
> \{u : D_u g(x)=0\}.
> \]
> Hence the symmetric matrix
> \[
> M_g(x) := g(x)\,\mathrm{Hess}(g)(x)-\nabla g(x)\nabla g(x)^\top
> \]
> has at most one positive eigenvalue.

This avoids analytic logs in the core proof and is more Lean-friendly.

Then prove a comparison theorem with the DPP certificate:

> **Theorem C (Recovery of the DPP case).**  
> For the determinantal generating polynomial \(g_K(z)=\det(I+\operatorname{diag}(z)K)\) with \(K \succeq 0\), the new intrinsic certificate matrix \(M_{g_K}(x)\) agrees with the catalog resolvent/Hessian certificate up to the normalization already established in:
> - `Catalog/Speculative/AutoResearch/DPPLorentzian.lean`
> - `Pythagorean/LorentzianCertificate.lean`

This theorem is strategically vital: it certifies that your new framework strictly extends the existing one.

---

## Lean 4 Formalization Targets

You should aim for theorem statements of the following flavor. The exact namespaces may vary, but keep the mathematical content precise.

### New definitions

```lean
def IsMultiaffineNonneg (g : MvPolynomial (Fin n) ℝ) : Prop := ...
def IsStronglyRayleighGenPoly (g : MvPolynomial (Fin n) ℝ) : Prop := ...
def logHessianCertificateMatrix
    (g : MvPolynomial (Fin n) ℝ) (x : Fin n → ℝ) : Matrix (Fin n) (Fin n) ℝ := ...
def ConditionalNSD
    (A : Matrix (Fin n) (Fin n) ℝ) (w : Fin n → ℝ) : Prop := ...
```

A robust certificate matrix definition should be something equivalent to
```lean
def lorentzianCertificateMatrix
    (g : MvPolynomial (Fin n) ℝ) (x : Fin n → ℝ) : Matrix (Fin n) (Fin n) ℝ :=
  (eval x g) • hessianEval g x - outer (gradientEval g x) (gradientEval g x)
```
where `hessianEval` and `gradientEval` are your own definitions if needed.

### Theorem 1: intrinsic conditional negativity

```lean
theorem stronglyRayleigh_conditionalNSD
    {n d : ℕ}
    (g : MvPolynomial (Fin n) ℝ)
    (hg_SR : IsStronglyRayleighGenPoly g)
    (hg_hom : g.IsHomogeneousOfDegree d)
    (hd : 2 ≤ d)
    (hx : ∀ i, 0 < x i) :
    ConditionalNSD (lorentzianCertificateMatrix g x) (gradientEval g x) := ...
```

### Theorem 2: at-most-one-positive-eigenvalue consequence

```lean
theorem stronglyRayleigh_hessian_atMostOnePos
    {n d : ℕ}
    (g : MvPolynomial (Fin n) ℝ)
    (hg_SR : IsStronglyRayleighGenPoly g)
    (hg_hom : g.IsHomogeneousOfDegree d)
    (hd : 2 ≤ d)
    (hx : ∀ i, 0 < x i) :
    Matrix.AtMostOnePositiveEigenvalue (lorentzianCertificateMatrix g x) := ...
```

If `Matrix.AtMostOnePositiveEigenvalue` does not exist, define an appropriate spectral predicate in terms of quadratic forms on codimension-one subspaces. Do not weaken the mathematics just to match a missing API.

### Theorem 3: DPP compatibility

```lean
theorem dpp_certificate_agrees_with_intrinsic
    {n : ℕ}
    (K : Matrix (Fin n) (Fin n) ℝ)
    (hK_psd : K.PosSemidef)
    (hx : ∀ i, 0 < x i) :
    lorentzianCertificateMatrix (dppGenPoly K) x =
      dppCatalogCertificateMatrix K x := ...
```

### Theorem 4: matroid-basis specialization

Formalize at least one non-determinantal family.

A good target is:

```lean
theorem regularMatroid_basisGenerating_polynomial_certificate
    {n r : ℕ}
    (M : RegularMatroid (Fin n) r)
    (hx : ∀ i, 0 < x i) :
    ConditionalNSD
      (lorentzianCertificateMatrix (basisGeneratingPolynomial M) x)
      (gradientEval (basisGeneratingPolynomial M) x) := ...
```

If full regular matroids are too far from current Mathlib infrastructure, define a more elementary intermediary structure encoding a finite family of equicardinal subsets with a real stable basis generating polynomial, and prove the theorem at that level. The point is to move beyond DPPs in a mathematically meaningful way.

---

## Why this would be a breakthrough

The existing DPP theory says: determinant structure gives a spectral certificate.  
The deeper conjectural reality is: **real stability itself is the hidden engine**.

If you prove this, you will have shown that:

1. **Lorentzian certification is intrinsic to strong Rayleigh geometry**, not tied to PSD kernels.
2. **Negative dependence becomes algorithmically certifiable** for families from matroid theory and graph theory.
3. The spectral language of Hessians, the combinatorial language of stable generating polynomials, and the geometric language of Lorentzian forms all become formally interoperable.

This is exactly the kind of theorem that changes what people think is computable in algebraic combinatorics.

---

## Proof Strategy Architecture

You must pursue at least 2–3 viable proof routes and explain which one is most promising.

### Strategy A: Direct real-stability → Rayleigh inequality → Hessian certificate
**Most promising.**

1. Use the multiaffine real stability characterization to derive pairwise Rayleigh inequalities:
   \[
   \partial_i g(x)\partial_j g(x)-g(x)\partial_i\partial_j g(x)\ge 0
   \quad \text{for } x>0.
   \]
2. Upgrade these coordinate inequalities to a full quadratic-form inequality for arbitrary directions \(u\), via polarization and multiaffinity:
   \[
   (D_u g(x))^2 - g(x) D_u^2 g(x) \ge 0.
   \]
3. Rewrite this as conditional negative semidefiniteness of
   \[
   g(x)\,\mathrm{Hess}(g)(x)-\nabla g(x)\nabla g(x)^\top.
   \]
4. Deduce the at-most-one-positive-eigenvalue statement by linear algebra on symmetric forms.

**Why most promising:** it avoids determinant formulas entirely and is closest to known Borcea–Brändén machinery. It also produces the cleanest Lean decomposition: polynomial inequalities first, spectral consequence second.

---

### Strategy B: Hyperbolicity/Lorentzian route via homogeneous stable polynomials

1. Homogenize the multiaffine generating polynomial \(g\) to a homogeneous stable polynomial \(\tilde g\).
2. Invoke the bridge between stable/hyperbolic behavior and Lorentzian Hessian signatures on the positive cone.
3. Dehomogenize carefully to recover the certificate for \(g\) itself.
4. Compare the resulting quadratic form to your intrinsic matrix definition.

**Why promising:** conceptually elegant and closer to the modern “Lorentzian polynomials” literature.  
**Why harder in Lean:** homogenization bookkeeping and importing the right hyperbolic signatures may be technically heavy unless enough infrastructure already exists.

---

### Strategy C: Determinantal approximation / closure argument

1. Approximate strongly Rayleigh generating polynomials by determinant-type stable polynomials or by a class already covered by the catalog.
2. Prove the certificate is closed under coefficientwise or locally uniform limits on the positive orthant.
3. Transfer the DPP certificate by continuity.

**Why interesting:** it would make the DPP case the universal seed from which the general theory grows.  
**Why risky:** approximation theorems and continuity of spectral signatures may be more difficult to formalize than the intrinsic direct proof.

---

## Required Theorem Package

Your Lean development must contain at least **3 nontrivial theorems** with genuine proof structure. Suggested package:

1. **Directional Rayleigh inequality from strong Rayleighness**
2. **Conditional NSD of the intrinsic Hessian certificate**
3. **At-most-one-positive-eigenvalue / Lorentzian signature theorem**
4. **DPP compatibility theorem**
5. **One non-determinantal specialization theorem** (matroidal or stable-family level)

At least 3 of these must use deep proof tactics such as induction, `rcases`, `by_contra`, `field_simp`, or substantial `calc` blocks.

---

## Novel Definitions You Should Introduce

At least one truly new concept is mandatory. Strong candidates:

- `lorentzianCertificateMatrix`
- `ConditionalNSD`
- `DirectionalRayleigh`
- `ResolventFreeCertificate`
- `StronglyRayleighWitness`

A particularly strong new definition is a **certificate object** bundling both the matrix and its proof obligations:

```lean
structure LorentzianHessianCertificate
    (g : MvPolynomial (Fin n) ℝ) (x : Fin n → ℝ) where
  mat : Matrix (Fin n) (Fin n) ℝ
  eq_intrinsic :
    mat = lorentzianCertificateMatrix g x
  cond_nsd :
    ConditionalNSD mat (gradientEval g x)
```

This converts a theorem into reusable certified data and is exactly the kind of structure that supports downstream algorithmics.

---

## Cross-Domain Connection Theorems

You must include at least one theorem connecting this domain to another area.

### Recommended bridge: combinatorics ↔ analysis ↔ spectral linear algebra
Prove that strong Rayleighness implies a spectral signature constraint on a Hessian matrix. This already bridges combinatorics and analysis.

### Stronger bridge: graph theory / matroids ↔ optimization
If you can encode basis generating polynomials of regular matroids or graphic matroids, prove the certificate yields a concavity or one-positive-direction property relevant to convex optimization on the positive orthant.

Possible theorem formulation:

```lean
theorem graphicMatroid_spanningTree_certificate
    (G : SimpleGraph V)
    (hx : ∀ e, 0 < x e) :
    ConditionalNSD
      (lorentzianCertificateMatrix (spanningTreeGeneratingPolynomial G) x)
      (gradientEval _ x) := ...
```

Even a simplified finite-family version would be valuable if the graph infrastructure is not ready.

### Physics bridge
Interpret the log-Hessian as a susceptibility/correlation matrix of a repulsive particle system. Prove that the strong Rayleigh property forces a one-unstable-direction bound. This is a mathematically serious bridge to statistical mechanics.

**Application keywords:** negative dependence, real stability, Lorentzian polynomials, hyperbolicity, matroid theory, spectral certification, log-concavity, convex optimization, graphical models, statistical mechanics.

---

## Computational / Algorithmic Deliverable

You must produce a verified computational method, not just existence theorems.

### Target algorithm
Implement an algorithm that, given a multiaffine polynomial with nonnegative coefficients and a positive point `x`, computes:

1. `g(x)`
2. `∇g(x)`
3. `Hess(g)(x)`
4. the intrinsic certificate matrix
   \[
   M_g(x)=g(x)\,\mathrm{Hess}(g)(x)-\nabla g(x)\nabla g(x)^\top
   \]
5. a numerical check of whether `M_g(x)` has at most one positive eigenvalue

The verified part should establish that the matrix computed by the algorithm equals the formal certificate matrix.

A strong algorithm theorem would look like:

```lean
theorem compute_certificate_correct
    (g : MvPolynomial (Fin n) ℝ)
    (x : Fin n → ℝ) :
    computeCertificate g x = lorentzianCertificateMatrix g x := ...
```

Then `demo.py` should test:
- DPP examples
- uniform bases of small regular matroids
- balanced matroid-inspired examples if representable in code
- random strongly Rayleigh candidate families when available

The demo should report eigenvalue counts and highlight any candidate counterexample.

---

## Falsifiable Conjecture with Testable Prediction

You must explicitly state and computationally probe at least one conjecture.

### Main conjecture
> **Conjecture (Strongly Rayleigh resolvent-free Lorentzian certificate).**  
> Every multiaffine homogeneous real stable polynomial with nonnegative coefficients satisfies that, for every positive point \(x\), the intrinsic certificate matrix \(M_g(x)\) has at most one positive eigenvalue.

### Clear falsification test
Search over:
- basis generating polynomials of small regular matroids,
- uniform matroids,
- graphic matroids from small graphs,
- non-DPP strongly Rayleigh examples from the literature.

A single example with two or more positive eigenvalues at some positive `x` refutes the conjecture.

### Sharper secondary conjecture
> **Conjecture (Extremal rigidity).**  
> Equality in the codimension-one NSD bound occurs iff the polynomial decomposes, after scaling and permutation, into a degenerate product/limit form corresponding to a reducible stable structure.

This is deeper and may generate future structural classification work.

---

## How to Build on the Catalog

You must explicitly leverage and extend:

- `Catalog/Speculative/AutoResearch/DPPLorentzian.lean`
  - use `IsDPPLorentzian` and `dpp_partition_function_lorentzian` as the determinantal seed case;
  - extract the exact matrix identity used there and prove your intrinsic matrix specializes to it.

- `Pythagorean/LorentzianCertificate.lean`
  - use `LorentzianHessianCertificate` and `dpp_hessian_conditional_neg_semidef`;
  - generalize from kernel-defined certificates to polynomial-defined certificates;
  - preserve theorem shape so downstream code can reuse the API.

Do not merely cite these files. Architect your definitions so the old DPP theorems become lemmas in the new general framework.

---

## Expected Proof Tactics / Technical Moves

You are required to include nontrivial proofs using:
- `rcases` to unpack multiaffinity / homogeneity hypotheses,
- `by_contra` for spectral contradiction arguments,
- `field_simp` when converting log-Hessian formulas into polynomial identities,
- multi-step `calc` blocks for directional derivative manipulations,
- induction on support size / degree / number of variables where natural.

A likely key algebraic identity:
\[
\partial_i\partial_j \log g
=
\frac{g\,\partial_i\partial_j g-\partial_i g\,\partial_j g}{g^2}
\]
for \(g(x)>0\), which will likely require `field_simp` and positivity lemmas.

---

## Deliverables (ALL mandatory)

Produce all of the following:

1. **Lean file(s)** with the new definitions, algorithm, and at least 3 deep theorems.
2. **FUTURE_DIRECTIONS.md** with 3–5 original research directions.  
   Each direction must include the exact sentences:
   - **“The key insight is...”**
   - **“Why now?”**
   At least one direction must bridge to a different domain.
3. **RESEARCH_PAPER.md** as a standalone scientific paper explaining the theorem, proof architecture, significance, examples, conjectures, and next steps. Someone reading only this document must understand the discovery.
4. **ARTICLE.md** in Scientific American style, accessible and engaging, focused on the mathematical ideas and significance. Do **not** focus on formal verification machinery.
5. **A verified algorithm or computational method** for computing the certificate matrix.
6. **demo.py** that interactively computes and tests the certificate on examples, including non-DPP strongly Rayleigh candidates.

---

## Standard of Success

A successful outcome is not “we proved another DPP lemma.”  
A successful outcome is:

- a **new intrinsic certificate theory** for strongly Rayleigh measures,
- a theorem showing **real stability forces Lorentzian spectral behavior**,
- a bridge from **matroid combinatorics to Hessian geometry**,
- and a computational pipeline that can actually search for obstructions or confirm the conjecture on meaningful families.

This is the kind of result that could seed an entire research program in **algorithmic negative dependence geometry**.

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
