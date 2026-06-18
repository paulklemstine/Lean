Soli Deo Gloria

## Assignment: Direction 5: Numerical Stability of Lorentzian Recognition

**Mode:** prove

Prove genuinely new, nontrivial theorems that turn qualitative Lorentzian recognition into a **quantitative, numerically stable certification theory**. The goal is not merely to restate openness of Lorentzianity, but to isolate explicit spectral margins on quadratic leaves that survive coefficient perturbations and therefore make **floating-point Lorentzian recognition** mathematically defensible.

This direction is timely because the catalog already contains the qualitative geometric engine:
- `Pythagorean/LorentzianRecognition.lean`
  - `HasAtMostOnePositiveEigenvalue`
  - `lorentzian_signature_tangent_neg_semidef`

Your task is to build the missing quantitative layer: **stability radii, perturbation inequalities, and a certifiable algorithm**.

---

## Central Vision

A Lorentzian polynomial is recognized through the signatures of quadratic leaves. The catalog gives a tangent-space negativity theorem, but modern applications need more: if the Hessians of all quadratic leaves have a **uniform spectral gap**, then small perturbations of coefficients should not destroy Lorentzianity. That would transform Lorentzian recognition from an exact-symbolic criterion into a **robust numerical certificate**, with consequences for optimization, strongly log-concave sampling, matroid theory, and machine learning models built from hyperbolic or Lorentzian generating functions.

This is a breakthrough if you can formalize a theorem of the form:

> **Uniform spectral margin on quadratic leaves ⇒ explicit coefficient-stability radius for Lorentzianity.**

That statement would open a new field of **certified Lorentzian numerics**.

---

## Precise Mathematical Target

Let `f` be a homogeneous polynomial of degree `d` in `n` variables over `ℝ`. For each multi-index `α` with `|α| = d - 2`, the corresponding quadratic leaf is the second-order derivative
\[
Q_\alpha(x) := \partial^\alpha f(x),
\]
a homogeneous quadratic form with Hessian matrix `H_α`. Assume each such leaf is strictly Lorentzian with a **uniform margin**:
\[
\lambda_2(H_\alpha) \le -\varepsilon \,\|H_\alpha\|,
\]
where `λ₂` is the second-largest eigenvalue.

You should prove a quantitative theorem showing that if another homogeneous polynomial `g` has sufficiently close coefficients to `f`, then every quadratic leaf of `g` still has at most one positive eigenvalue, hence `g` is Lorentzian.

The conceptual form should be:

> There exists an explicit constant `C(d,n)` such that if  
> \[
> \max_\alpha \|H_\alpha(g)-H_\alpha(f)\| \le \tfrac{\varepsilon}{C(d,n)} \min_\alpha \|H_\alpha(f)\|,
> \]
> then `g` is Lorentzian.

Even if the final Lean theorem uses a slightly weaker norm or a finite-indexed coefficient model, the theorem must be **quantitative**, not merely topological.

---

## New Definitions You Must Introduce

You must define at least one genuinely new concept absent from the catalog. Recommended definitions:

1. **Uniform spectral margin for quadratic leaves**
   ```lean
   def QuadraticLeafSpectralMargin
     (f : MvPolynomial σ ℝ) (d : ℕ) (ε : ℝ) : Prop := ...
   ```
   Intended meaning: every quadratic leaf of order `d - 2` has second eigenvalue bounded above by `-ε * ‖H‖`.

2. **Coefficient perturbation radius preserving Lorentzianity**
   ```lean
   def LorentzianStabilityRadius
     (f : MvPolynomial σ ℝ) (d : ℕ) : ℝ := ...
   ```
   Intended meaning: the supremal coefficient-radius such that all nearby degree-`d` homogeneous perturbations remain Lorentzian.

3. **Certified numerical recognizer**
   ```lean
   def CertifiedLorentzianRecognizer
     (f : MvPolynomial σ ℝ) (d : ℕ) : Bool := ...
   ```
   together with a theorem of soundness:
   ```lean
   theorem CertifiedLorentzianRecognizer_sound ... : 
     CertifiedLorentzianRecognizer f d = true → Lorentzian f
   ```

If Mathlib’s exact polynomial/Hessian API forces a finite-indexed surrogate, specialize to `σ := Fin n` and represent homogeneous polynomials through coefficient families or associated symmetric matrices for quadratic leaves. Precision matters more than maximal generality.

---

## Lean 4 Theorem Targets

You should aim for at least the following theorem statements, adapted as needed to actual available APIs.

### Theorem 1: spectral gap is stable under Hessian perturbation
A matrix-theoretic theorem independent of Lorentzianity, likely the easiest entry point.

```lean
theorem secondEigenvalue_upper_bound_under_perturbation
    {n : ℕ} (A E : Matrix (Fin n) (Fin n) ℝ)
    (hA : A.IsSymm) (hE : E.IsSymm) :
    secondLargestEigenvalue (A + E)
      ≤ secondLargestEigenvalue A + ‖E‖ := ...
```

If `secondLargestEigenvalue` is unavailable, formulate instead via `HasAtMostOnePositiveEigenvalue` and a norm-small perturbation lemma:

```lean
theorem hasAtMostOnePositiveEigenvalue_of_close
    {n : ℕ} (A E : Matrix (Fin n) (Fin n) ℝ)
    (hA : A.IsSymm)
    (hgap : spectralGapAtMostOnePositive A ε)
    (hsmall : ‖E‖ < ε) :
    HasAtMostOnePositiveEigenvalue (A + E) := ...
```

This is the linear-algebraic core. It is deep because it bridges eigenvalue perturbation with signature control.

### Theorem 2: quantitative persistence of tangent-space negativity
This theorem should explicitly build on the catalog theorem
`lorentzian_signature_tangent_neg_semidef`.

```lean
theorem tangent_negativity_with_margin
    {n : ℕ} {Q : MvPolynomial (Fin n) ℝ} {x : Fin n → ℝ}
    (hQquad : IsHomogeneousOfDegree 2 Q)
    (hpos : eval x Q > 0)
    (hgap : QuadraticSpectralGap Q ε) :
    ∀ v, tangentTo x v → hessianEval Q x v v ≤ -ε * ‖v‖^2 := ...
```

If exact pointwise Hessian evaluation is cumbersome, formulate directly for a symmetric matrix `H`:
```lean
theorem tangent_negativity_with_margin_matrix
    {n : ℕ} {H : Matrix (Fin n) (Fin n) ℝ} {x v : EuclideanSpace ℝ (Fin n)}
    (hsym : H.IsSymm)
    (hpos : 0 < quadraticForm H x)
    (hgap : spectralGapAtMostOnePositive H ε)
    (htan : inner x (H.mulVec v) = 0) :
    quadraticForm H v ≤ -ε * ‖v‖^2 := ...
```

This theorem is the quantitative strengthening of the catalog’s qualitative tangent-space result.

### Theorem 3: coefficient perturbations preserve Lorentzianity
This is the flagship theorem.

```lean
theorem lorentzian_of_uniform_leaf_gap_of_small_perturbation
    {n d : ℕ}
    {f g : MvPolynomial (Fin n) ℝ}
    (hf_hom : IsHomogeneousOfDegree d f)
    (hg_hom : IsHomogeneousOfDegree d g)
    (hgap : QuadraticLeafSpectralMargin f d ε)
    (hclose : coefficientDist f g < stabilityConstant n d * ε) :
    Lorentzian g := ...
```

A weaker but still excellent version is:

```lean
theorem lorentzian_stable_in_coefficient_ball
    {n d : ℕ} {f : MvPolynomial (Fin n) ℝ}
    (hf : Lorentzian f)
    (hgap : QuadraticLeafSpectralMargin f d ε) :
    ∃ δ > 0, ∀ g,
      IsHomogeneousOfDegree d g →
      coefficientDist f g < δ →
      Lorentzian g := ...
```

This theorem must not be a bare compactness/openness statement. The proof should exhibit a **computable δ** or at least derive δ from explicit finite minima over quadratic leaves.

### Theorem 4: cross-domain theorem linking Lorentzian stability to optimization
You must include at least one theorem bridging to another domain. The most natural bridge is convex/optimization theory.

For a quadratic leaf matrix `H`, one positive eigenvalue and negative tangent directions imply controlled saddle geometry. A theorem of the following flavor would be excellent:

```lean
theorem stable_lorentzian_leaf_gives_trust_region_uniqueness
    {n : ℕ} {H : Matrix (Fin n) (Fin n) ℝ}
    (hsym : H.IsSymm)
    (hgap : spectralGapAtMostOnePositive H ε) :
    ∀ r > 0, ∃! x, ‖x‖ ≤ r ∧ maximizesOnSphere (quadraticForm H) r x := ...
```

If uniqueness on spheres is too ambitious, prove instead a rigorously formalized optimization corollary:

```lean
theorem tangent_strong_concavity_of_stable_leaf
    {n : ℕ} {H : Matrix (Fin n) (Fin n) ℝ}
    (hsym : H.IsSymm)
    (hgap : spectralGapAtMostOnePositive H ε) :
    stronglyConcaveOnTangentSpaces H ε := ...
```

This creates the bridge:
**Lorentzian geometry → numerical optimization / robust control**.

---

## Recommended Proof Architecture

You asked for 2–3 proof strategy steps. Here are three viable routes.

### Strategy A: Weyl-type eigenvalue perturbation + finite leaf enumeration
**Most promising.**

1. Prove a matrix perturbation lemma: for symmetric matrices, the second-largest eigenvalue changes by at most the operator norm of the perturbation.
2. Show each quadratic leaf Hessian depends **linearly** on the coefficients of `f`, so coefficient perturbations induce controlled Hessian perturbations with an explicit constant depending on `(n,d)`.
3. Since there are finitely many quadratic leaves for fixed `(n,d)`, take the minimum spectral margin over all leaves. If perturbations are smaller than half this margin after the linear map constant, every leaf retains the “at most one positive eigenvalue” property, hence `g` is Lorentzian.

Why this is best: it is explicit, algorithmic, and matches the catalog’s finite combinatorial nature of quadratic leaves.

### Strategy B: Quantitative tangent-space negativity
1. Start from `lorentzian_signature_tangent_neg_semidef`.
2. Strengthen it from semidefinite negativity on tangent spaces to a **strict negativity estimate with margin** derived from the spectral gap.
3. Show this estimate is stable under perturbation of Hessians and positive evaluation directions, then transfer back to Lorentzianity.

Why it matters: this route produces the deepest geometric theorem and explains *why* the numerical certificate works. It is conceptually stronger than pure eigenvalue bookkeeping.

### Strategy C: Compactness/contradiction with normalization
1. Normalize coefficient norm and spectral margin.
2. Assume there are arbitrarily small perturbations destroying Lorentzianity.
3. Extract a convergent sequence of bad perturbations; use continuity of quadratic leaf Hessians and the catalog tangent-space theorem to derive a contradiction.

Why this is useful: if explicit constants become difficult in Lean, this still gives a robust existence theorem. However, it is less revolutionary than Strategy A because it does not produce a certifiable radius.

**Recommendation:** Use Strategy A for the flagship theorem, Strategy B for the geometric strengthening theorem, and Strategy C only as backup if an explicit constant becomes technically blocked.

---

## Building Blocks from the Catalog

You must explicitly leverage:
- `HasAtMostOnePositiveEigenvalue`  
  Use this as the signature predicate preserved under sufficiently small perturbations.
- `lorentzian_signature_tangent_neg_semidef`  
  Use this to convert leaf spectral conditions into tangent-space negativity, then strengthen quantitatively.

The ideal proof pipeline is:

`leaf spectral gap`  
→ quantitative `HasAtMostOnePositiveEigenvalue` persistence  
→ quantitative tangent negativity  
→ all quadratic leaves remain Lorentzian-signatured  
→ perturbed polynomial is Lorentzian.

Do not merely cite these theorems; explain in comments/docstrings exactly where each enters.

---

## Cross-Domain Connections You Must Surface

At least one theorem and the paper narrative must connect Lorentzian recognition to another domain. Strong options:

1. **Numerical Linear Algebra**
   - spectral perturbation bounds
   - condition numbers for Hessian-signature certification
   - verified eigengap-based recognition

2. **Optimization**
   - tangent-space strong concavity
   - trust-region geometry of quadratic leaves
   - robustness of hyperbolic relaxations

3. **Machine Learning**
   - stable certification of negative dependence / log-concavity surrogates
   - reliable floating-point screening of Lorentzian feature polynomials
   - robust energy landscapes

4. **Robust Control / Engineering**
   - Hessian signature margins as safety certificates
   - perturbation-tolerant polynomial models in uncertain environments

5. **Combinatorics / Matroid Theory**
   - noisy basis-generating polynomials
   - practical Lorentzian testing for combinatorial generating functions

A particularly striking bridge theorem would relate spectral margin to a **condition number** for recognition:
```lean
def LorentzianConditionNumber (f : MvPolynomial (Fin n) ℝ) (d : ℕ) : ℝ := ...
```
and then prove that a smaller condition number implies larger certified perturbation tolerance. This is exactly the kind of concept that can launch a new subfield.

---

## Application Keywords

Include these explicitly in comments, paper, and article:

**application keywords:** numerical stability, eigenvalue perturbation, certified computation, Lorentzian polynomials, hyperbolic optimization, strong log-concavity, matroid generating polynomials, trust-region methods, robust machine learning, robust control, condition number, floating-point certification

---

## Conjecture with Testable Prediction

You must state and discuss at least one falsifiable conjecture with a computational disproof criterion. Strengthen the supplied one into a sharper form:

> **Conjecture (dimension-degree stability law).**  
> For every `n,d`, there exists `C(n,d) > 0` such that if a homogeneous degree-`d` polynomial `f` has every quadratic leaf Hessian satisfying
> \[
> \lambda_2(H_\alpha) \le -\varepsilon \|H_\alpha\|,
> \]
> then every homogeneous `g` with
> \[
> \|g-f\|_{\mathrm{coeff}} < C(n,d)\,\varepsilon
> \]
> is Lorentzian.

**Testable prediction:** For elementary symmetric polynomials and matroid basis polynomials, Monte Carlo perturbations should show an empirical destruction threshold proportional to the minimum quadratic-leaf eigengap.

**Disproof criterion:** Exhibit a family `f_k` of Lorentzian polynomials with normalized leaf gap bounded below, and perturbations `g_k → f_k` in coefficient norm for which `g_k` is not Lorentzian. That would falsify any universal linear stability law.

A second, bolder conjecture is encouraged:

> **Conjecture (condition-number universality).**  
> The reciprocal of the minimum normalized quadratic-leaf spectral gap is, up to polynomial factors in `(n,d)`, the correct condition number for Lorentzian recognition.

This directly invites numerical experiments and future asymptotic theory.

---

## Required Deep Proof Tactics

Your file must contain at least 3 substantial theorem proofs using nontrivial tactics such as:
- induction
- `rcases`
- `by_contra`
- `field_simp`
- multi-step `calc`
- careful inequality chaining
- finite minimum arguments over quadratic leaves
- contradiction via normalized bad sequence

Do **not** waste theorem slots on tautologies or finite enumeration. The point is to build a durable theory.

---

## Suggested File-Level Structure

1. **Definitions**
   - `QuadraticLeafSpectralMargin`
   - `coefficientDist`
   - `LorentzianStabilityRadius`
   - optionally `LorentzianConditionNumber`

2. **Matrix perturbation lemmas**
   - norm control
   - signature persistence
   - eigengap preservation

3. **Quadratic leaf transport lemmas**
   - leaf Hessian depends linearly/continuously on coefficients
   - explicit perturbation constants

4. **Main Lorentzian stability theorem**
   - explicit or computable radius

5. **Cross-domain corollary**
   - tangent strong concavity / optimization certificate

6. **Algorithm**
   - compute all quadratic leaves
   - estimate eigengaps numerically
   - return certified radius or failure

---

## Verified Algorithm Deliverable

You must produce a **verified computational method**, not just theorem statements.

Target:
```lean
def certifyLorentzianStability
    (f : MvPolynomial (Fin n) ℝ) (d : ℕ) :
    Option ℝ := ...
```
Interpretation:
- returns `some δ` if the procedure certifies that every homogeneous `g` with coefficient distance `< δ` is Lorentzian;
- returns `none` if no certificate is found.

Then prove a soundness theorem:
```lean
theorem certifyLorentzianStability_sound
    {f : MvPolynomial (Fin n) ℝ} {d : ℕ} {δ : ℝ}
    (hcert : certifyLorentzianStability f d = some δ) :
    0 < δ ∧ ∀ g, IsHomogeneousOfDegree d g →
      coefficientDist f g < δ → Lorentzian g := ...
```

This would be a major advance: a **formal certificate generator** for numerical Lorentzian recognition.

---

## demo.py Deliverable

Your `demo.py` must:
1. construct known Lorentzian examples:
   - elementary symmetric polynomials
   - small matroid basis polynomials if feasible
2. compute quadratic leaves
3. estimate Hessian eigengaps
4. perturb coefficients by random noise at varying scales
5. display empirical stability threshold versus certified bound
6. visualize gap degradation

The demo should let a user see the phenomenon:
**certified radius ≤ empirical destruction radius**, ideally with examples where the certificate is conservative but nontrivial.

---

## RESEARCH_PAPER.md Deliverable

This must be a standalone scientific paper explaining:
- what Lorentzian polynomials are
- why numerical recognition is hard
- the new quantitative stability theorem
- the proof architecture
- the algorithm
- experiments on elementary symmetric and matroid polynomials
- limitations and next questions

Someone reading only the paper must understand the discovery without seeing the code.

---

## ARTICLE.md Deliverable

Write this in Scientific American style. Explain:
- why a fragile exact criterion became a robust numerical one
- how spectral gaps act like “buffers” protecting geometric structure
- why this matters for optimization, combinatorics, and data science

Do **not** focus on formal verification machinery. Focus on the mathematics and its significance.

---

## FUTURE_DIRECTIONS.md Deliverable

Provide 3–5 research directions, each written as original prose and each including:
- **“The key insight is…”**
- **“Why now?”**

At least one direction must bridge to a different domain, such as:
- stochastic optimization,
- hyperbolic programming,
- statistical physics,
- robust control,
- condition numbers in algebraic geometry.

Strong candidates:
1. Lorentzian condition numbers and smoothed analysis
2. Stability of strongly log-concave distributions under noisy generating functions
3. Certified hyperbolicity via Lorentzian leaf margins
4. Tropical or combinatorial shadows of Lorentzian stability
5. Robust recognition for matroid and valuated matroid generating polynomials

---

## Standard of Ambition

Do not settle for “Lorentzianity is open.” That is known in spirit and not enough. The breakthrough is to identify a **quantitative, computable stability margin** and to connect it to **condition numbers, eigenvalue perturbation, and optimization geometry**.

If you succeed, you will have created the foundation for a new subject:

> **Certified numerical Lorentzian geometry** —

a bridge from deep combinatorial Hodge theory to practical computation under noise.

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
    "visualizations": [ { "name": "...", "code": "# matplotlib or plotly script, self-contained", "description": "What this visualizes" } ],
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
