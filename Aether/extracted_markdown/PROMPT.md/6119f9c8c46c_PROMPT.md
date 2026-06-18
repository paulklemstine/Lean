Soli Deo Gloria

## Assignment: Direction 2: Anti-Cancellation for Aggregated Derivatives in Lorentzian Polynomials

**Mode:** `prove`

Build a field-opening theorem about **anti-cancellation for aggregated derivatives of Lorentzian polynomials**. The aim is not another support-preservation lemma for a single derivative, but a genuinely new principle: **positive second-order differential operators should preserve the entire second shadow of an M-convex support under Lorentzian sign/concavity constraints**. If true, this is a structural bridge between discrete convex analysis, Hodge-theoretic positivity, and certified symbolic computation.

You should work from the catalog material around:

- `Catalog/Speculative/AutoResearch/LorentzianMConvex.lean`
  - especially exchange lemmas such as `IsMConvexExchangeNat`
  - Lorentzian quadratic infrastructure such as `IsLorentzianQuadratic`
- any existing support/shadow/derivative lemmas in the nearby speculative Lorentzian files
- any polynomial support APIs in Mathlib for multivariate polynomials / finitely supported coefficient maps

The scientific target is to turn the informal anti-cancellation principle into a precise theorem family with a verified computational testbed.

---

## Core breakthrough target

Let `f` be a homogeneous multivariate polynomial with nonnegative coefficients, Lorentzian in the appropriate catalog sense, and with M-convex support. Define the **second shadow**
\[
\mathrm{Sh}_2(S) := \{\beta \mid \exists \alpha \in S,\ \exists i,j,\ \alpha = \beta + e_i + e_j\}.
\]
For the diagonal Hessian trace
\[
\Delta_{\mathrm{diag}} f := \sum_i \partial_i^2 f,
\]
and more generally for a positive weighted Hessian operator
\[
D_A f := \sum_{i,j} A_{ij}\,\partial_i\partial_j f \qquad (A_{ij} > 0),
\]
the conjectural phenomenon is:

> **Positive aggregation does not erase reachable second-shadow exponents.**

This would be the first theorem saying that Lorentzian positivity controls not merely signs or log-concavity, but **support survival under summation of distinct differential channels**.

---

## Precise theorem targets

You must formalize at least **3 substantial theorems**, with proofs using real mathematical structure (induction, `rcases`, contradiction, exchange arguments, multi-step `calc`, coefficient extraction, etc.), not computational trivialities.

### New definitions you should introduce

At least one of these should be implemented as a genuinely new concept.

1. **Second shadow of a support set**
   ```lean
   def secondShadow (S : Finset (σ →₀ ℕ)) : Finset (σ →₀ ℕ)
   ```

2. **Reachability by diagonal second derivative**
   ```lean
   def DiagReachable (S : Finset (σ →₀ ℕ)) (β : σ →₀ ℕ) : Prop :=
     ∃ α ∈ S, ∃ i : σ, α = β + Finsupp.single i 2
   ```

3. **Positive second-order differential operator**
   ```lean
   structure PositiveHessianOperator (σ : Type*) [Fintype σ] where
     weight : σ → σ → ℝ
     pos' : ∀ i j, 0 < weight i j
   ```

4. **Anti-cancellation at an exponent**
   ```lean
   def AntiCancelsAt
     (T : MvPolynomial σ ℝ →ₗ[ℝ] MvPolynomial σ ℝ)
     (f : MvPolynomial σ ℝ) (β : σ →₀ ℕ) : Prop :=
     MvPolynomial.coeff β (T f) ≠ 0
   ```

5. **Support-level universal survivability**
   ```lean
   def PreservesSecondShadow
     (T : MvPolynomial σ ℝ →ₗ[ℝ] MvPolynomial σ ℝ)
     (S : Finset (σ →₀ ℕ)) : Prop :=
     ∀ β, β ∈ secondShadow S → ∃ c ≠ (0 : ℝ), True
   ```
   You may refine this to a coefficient statement tied to a polynomial `f` rather than a bare support.

The most mathematically meaningful new structure would be a support predicate encoding the theorem’s hypothesis:

```lean
structure LorentzianMConvexData (σ : Type*) [Fintype σ] where
  f : MvPolynomial σ ℝ
  homogeneous : ...
  nonneg_coeff : ∀ α, 0 ≤ MvPolynomial.coeff α f
  mconvex_support : IsMConvex ...
  lorentzian : IsLorentzian ...
```

If catalog notions already exist, reuse them; otherwise build a minimal wrapper that lets the theorem statements be clean.

---

## Primary theorem statement

### Theorem A: diagonal anti-cancellation from unique reachability
First prove a robust theorem that does not require the full Lorentzian machine and is likely the easiest formal foothold.

> **Theorem A.** Let `f` be a polynomial over `ℝ` with nonnegative coefficients. If `β` is diagonally reachable from the support of `f`, and every support element contributing to `β` under the trace operator has nonnegative contribution with at least one strictly positive one, then the coefficient of `β` in `∑ i, ∂ᵢ^2 f` is nonzero.

Lean-style target:
```lean
theorem coeff_traceSecond_nonzero_of_diagReachable
  {σ : Type*} [DecidableEq σ] [Fintype σ]
  (f : MvPolynomial σ ℝ)
  (hnonneg : ∀ α, 0 ≤ MvPolynomial.coeff α f)
  (β : σ →₀ ℕ)
  (hreach : ∃ α i, MvPolynomial.coeff α f ≠ 0 ∧ α = β + Finsupp.single i 2) :
  MvPolynomial.coeff β
    (∑ i : σ, MvPolynomial.pderiv i (MvPolynomial.pderiv i f)) ≠ 0
```

This may require strengthening hypotheses so that the coefficient extraction formula is exact and transparent. A better version is one where you prove an explicit formula:
\[
[\beta]\Big(\sum_i \partial_i^2 f\Big)
=
\sum_i (\beta_i+2)(\beta_i+1)\,[\beta+2e_i]f.
\]
Then nonnegativity makes anti-cancellation immediate.

This theorem is not yet revolutionary by itself; it is the coefficient identity that powers the deeper results.

---

### Theorem B: support-survival on the diagonal second shadow
This is the first genuine target.

> **Theorem B.** Let `f` be homogeneous with nonnegative coefficients and M-convex support. Then every exponent in the diagonal second shadow of the support survives in the support of the diagonal Hessian trace.

Lean-style target:
```lean
theorem secondShadow_subset_support_traceSecond
  {σ : Type*} [DecidableEq σ] [Fintype σ]
  (f : MvPolynomial σ ℝ)
  (hhom : MvPolynomial.IsHomogeneous f)
  (hnonneg : ∀ α, 0 ≤ MvPolynomial.coeff α f)
  (hmconv : IsMConvex ((f.support).toFinset)) :
  ∀ β,
    DiagReachable ((f.support).toFinset) β →
    MvPolynomial.coeff β
      (∑ i : σ, MvPolynomial.pderiv i (MvPolynomial.pderiv i f)) ≠ 0
```

If the support API uses `Finset` or `Finsupp.supported`, adapt accordingly.

Why this matters: this converts a **combinatorial shadow operation on support** into a **certified analytic support theorem for a differential operator**. It is a sparsity theorem for Hessians.

---

### Theorem C: positive weighted Hessian anti-cancellation
This is the breakthrough theorem.

> **Theorem C.** Let `f` be Lorentzian with M-convex support and nonnegative coefficients. Let `A` be a strictly positive matrix. If `β` lies in the second shadow of `Supp(f)`, then the coefficient of `β` in `D_A f = ∑_{i,j} A_{ij}\partial_i\partial_j f` is nonzero.

Lean-style target:
```lean
theorem coeff_posWeightedHessian_nonzero_of_secondShadow
  {σ : Type*} [DecidableEq σ] [Fintype σ]
  (A : PositiveHessianOperator σ)
  (f : MvPolynomial σ ℝ)
  (hhom : MvPolynomial.IsHomogeneous f)
  (hnonneg : ∀ α, 0 ≤ MvPolynomial.coeff α f)
  (hmconv : IsMConvex ((f.support).toFinset))
  (hlor : IsLorentzian f)
  (β : σ →₀ ℕ)
  (hβ : β ∈ secondShadow ((f.support).toFinset)) :
  MvPolynomial.coeff β
    (∑ i : σ, ∑ j : σ,
      A.weight i j • MvPolynomial.pderiv i (MvPolynomial.pderiv j f)) ≠ 0
```

You may need to split this into two theorems:

- a **coefficient formula theorem**
- then a **nonvanishing theorem under positivity + Lorentzian/M-convex hypotheses**

The coefficient identity should be something like
\[
[\beta](D_A f)
=
\sum_{i,j} A_{ij}\,(\beta_i+1)(\beta_j+1+\mathbf{1}_{i=j})\,[\beta+e_i+e_j]f
\]
with the usual diagonal/off-diagonal case distinction handled carefully in Lean.

If the full theorem is too hard in one pass, prove first:

- strictly positive `A`
- all coefficients of `f` strictly positive on support
- then relax strict positivity to nonnegativity plus a reachability witness

But the final statement should be ambitious and explicitly tied to Lorentzian structure.

---

## Cross-domain theorem requirement

You must include at least one theorem connecting this subject to another domain.

### Suggested theorem: discrete convex geometry + elliptic operator positivity
Interpret the positive weighted Hessian as a discrete analogue of an elliptic operator with positive symbol.

> **Cross-domain theorem.** For a homogeneous polynomial with nonnegative coefficients, the support of `D_A f` contains the image of the support under the combinatorial second-shadow operator whenever `A` is strictly positive. Thus positive elliptic symbols induce monotone support propagation on M-convex/Lorentzian data.

Lean-style target:
```lean
theorem support_monotone_under_positive_hessian
  {σ : Type*} [DecidableEq σ] [Fintype σ]
  (A : PositiveHessianOperator σ)
  (f : MvPolynomial σ ℝ)
  ... :
  secondShadow ((f.support).toFinset) ⊆ ((positiveHessian A f).support.toFinset)
```

This is a bridge between:

- **discrete convex analysis**: M-convex exchange
- **Hodge/Lorentzian theory**: coefficient positivity and derivative stability
- **PDE / mathematical physics**: positive elliptic second-order operators preserve observable modes

Application keywords: `Lorentzian polynomials`, `M-convexity`, `Hessian sparsity`, `elliptic operators`, `support propagation`, `discrete convex analysis`, `Hodge theory`, `symbolic computation`, `combinatorial PDE`, `stability theory`.

---

## Proof strategy architecture

You must pursue at least 2–3 proof routes and explain in comments or accompanying prose which one is most promising.

### Strategy 1: coefficient-extraction identity + positivity cone
**Most promising.**

1. Prove explicit coefficient formulas for `∂ᵢ∂ⱼ f` at exponent `β` in terms of coefficients of `f` at `β + e_i + e_j`.
2. Sum these formulas over `i,j` with positive weights.
3. Use coefficient nonnegativity to show the sum cannot vanish if any contributing source monomial exists.

Why this is strongest: it turns the theorem into a finite positive linear combination problem and isolates all hard combinatorics in the reachability hypothesis.

Key Lean ingredients:
- `MvPolynomial.coeff`
- derivative coefficient lemmas
- `Finset.sum_eq_zero_iff_of_nonneg`-type arguments, or custom positivity lemmas
- `calc` chains rewriting coefficient sums

### Strategy 2: support-level combinatorics via M-convex exchange
1. Show any `β ∈ secondShadow(S)` admits at least one witness `α = β + e_i + e_j`.
2. Use M-convex exchange to connect all such witnesses inside the support and rule out “isolated cancellation patterns”.
3. Combine with coefficient sign coherence from Lorentzianity to deduce support survival.

Why this is deeper: it explains **why** M-convex support, not merely positivity of coefficients, is the correct combinatorial substrate.

This is the route most likely to produce a publishable conceptual theorem rather than a support bookkeeping fact.

### Strategy 3: polarization / quadratic reduction
1. Reduce the second derivative statement to a quadratic form on lower-degree derivatives of `f`.
2. Invoke Lorentzian quadratic negativity/positivity infrastructure from the catalog.
3. Interpret the weighted Hessian coefficient as evaluation of a positive quadratic form on a support-localized slice.

Why this is attractive: Lorentzian theory is often most rigid at degree two. If catalog lemmas about `IsLorentzianQuadratic` are strong enough, this could yield the most elegant theorem.

But it is riskier formally, because the translation from coefficient nonvanishing to quadratic Lorentzian signatures may be delicate.

---

## Mathematical insight you should exploit

The anti-cancellation mechanism is not mystical; it comes from a precise decomposition.

For diagonal trace:
\[
[\beta]\Big(\sum_i \partial_i^2 f\Big)
=
\sum_i (\beta(i)+2)(\beta(i)+1)\,[\beta+2e_i]f.
\]
If coefficients are nonnegative, every summand is nonnegative, and any witness `β+2e_i ∈ Supp(f)` with positive coefficient yields strict positivity. Thus the diagonal theorem should be formalizable without full Lorentzianity.

For full weighted Hessian:
\[
[\beta](D_A f)
=
\sum_{i,j} A_{ij} \cdot c_{ij}(\beta)\cdot [\beta+e_i+e_j]f,
\]
where `c_{ij}(\beta)` is the combinatorial multiplicity from differentiation. If `A_{ij}>0` and all coefficients on support are nonnegative, then again any witness in the second shadow yields positivity.

This suggests a potentially even stronger truth:

> Lorentzianity may not be needed for the raw nonvanishing theorem once coefficientwise nonnegativity is assumed.

That is an important meta-discovery. If you can prove the theorem under weaker assumptions than the original conjecture, do it boldly. Then explain that Lorentzianity becomes significant in guaranteeing these coefficient/sign hypotheses and in suggesting stronger converse statements.

---

## Strengthened theorem to consider

If feasible, prove the sharper positivity statement:

```lean
theorem coeff_posWeightedHessian_pos_of_secondShadow
  {σ : Type*} [DecidableEq σ] [Fintype σ]
  (A : PositiveHessianOperator σ)
  (f : MvPolynomial σ ℝ)
  (hcoeff : ∀ α, 0 ≤ MvPolynomial.coeff α f)
  (β : σ →₀ ℕ)
  (hβ : ∃ α, MvPolynomial.coeff α f ≠ 0 ∧
        ∃ i j, α = β + Finsupp.single i 1 + Finsupp.single j 1) :
  0 <
  MvPolynomial.coeff β
    (∑ i : σ, ∑ j : σ,
      A.weight i j • MvPolynomial.pderiv i (MvPolynomial.pderiv j f))
```

This is better than nonzero and would be a clean anti-cancellation theorem.

---

## Conjecture with testable prediction

State and investigate the following falsifiable conjecture.

> **Conjecture (Lorentzian converse anti-cancellation).**  
> Let `f` be homogeneous with M-convex support. If for every strictly positive matrix `A`, every exponent in `secondShadow(Supp(f))` survives in `D_A f`, then `f` is coefficientwise sign-coherent and lies in the Lorentzian cone after normalization.

This is strong and likely false in full generality, which makes it scientifically useful.

### Computational test
For degree `d ≤ 6`, `n ≤ 5`:
1. Sample random homogeneous supports that are M-convex.
2. Assign positive coefficients.
3. Test whether the polynomial is Lorentzian using available numerical criteria or catalog quadratic reductions.
4. For 10,000 samples, compute `D_A f` for random strictly positive matrices `A`.
5. Check whether every second-shadow exponent survives.

A disproof is:
- a non-Lorentzian polynomial with universal anti-cancellation, or
- a Lorentzian polynomial where some second-shadow exponent disappears under positive aggregation.

You should formalize at least the operator and exact support test, and implement the random search in `demo.py`.

---

## Deliverables (ALL mandatory)

You must produce all of the following:

### 1. Lean development
A new Lean file proving at least 3 substantial theorems, with:
- no trivial theorem padding
- at least one genuinely new definition
- at least one cross-domain theorem
- minimized `sorry`
- proofs using nontrivial tactics (`induction`, `rcases`, `by_contra`, `field_simp` where relevant, multi-step `calc`, coefficient extraction, finite-sum positivity arguments)

Suggested filename:
- `Catalog/Speculative/AutoResearch/AntiCancellationLorentzian.lean`

### 2. `FUTURE_DIRECTIONS.md`
Provide **3–5 original research directions**, each with:
- **“The key insight is…”**
- **“Why now?”**
At least one direction must bridge to a different field, such as:
- matroid Hodge theory
- elliptic PDE / spectral graph theory
- optimization / barrier methods
- statistical physics via strongly Rayleigh measures

### 3. `RESEARCH_PAPER.md`
A standalone scientific paper that:
- states the main theorem precisely
- explains why anti-cancellation is surprising
- situates the result relative to Lorentzian polynomials and M-convexity
- includes proof ideas, examples, limitations, and future work
- is readable without access to the code

### 4. `ARTICLE.md`
Write in Scientific American style:
- vivid, idea-driven exposition
- explain the discovery to a broad audience
- emphasize the mathematics and significance
- **do not focus on formal verification machinery**

### 5. Verified algorithm / computational method
Implement a certified procedure that:
- computes the second shadow of a support
- computes the coefficient witnesses for `D_A f`
- checks anti-cancellation at each candidate exponent
- ideally returns witness monomials proving positivity/nonvanishing

### 6. `demo.py`
Interactive demonstration script that:
- generates random homogeneous M-convex supports
- assigns positive coefficients
- computes diagonal trace and positive weighted Hessian
- visualizes which shadow exponents survive
- runs the 10,000-sample falsification search
- prints candidate counterexamples if found

---

## What would make this a breakthrough

If you can prove that **positive second-order differential operators preserve second-shadow support for Lorentzian/M-convex polynomials**, you open a new theory of **differential support propagation**. That would create a fresh interface among:

- Lorentzian/Hodge positivity
- discrete convex geometry
- symbolic sparse differentiation
- elliptic operator analogies
- algorithmic support certification

This is not an incremental variant. It asks for a new law of motion for polynomial support under aggregation of derivatives. The right outcome is a theorem that makes researchers say: *“I knew Lorentzian polynomials controlled log-concavity, but I had never considered that they might forbid cancellation across Hessian channels.”*

Be bold: if the strongest Lorentzian statement is too difficult, prove the more powerful surprise theorem under coefficientwise nonnegativity, then reposition Lorentzianity as the natural structural source of that positivity and as the gateway to converse theorems. That would still be a genuine advance.

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
