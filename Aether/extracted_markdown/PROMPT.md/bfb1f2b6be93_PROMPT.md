Soli Deo Gloria

## Assignment: Direction 2 — Valuated M-Convexity and Coefficient Transport

**Mode:** `prove`

You are not being asked for an incremental extension. You are being asked to formalize the first genuine bridge from **support-level M-convex exchange** to **coefficient-level quantitative exchange**, and then to show that this bridge survives a fundamental analytic operation: **partial differentiation**. If this works even in a robust local form, it opens a route from combinatorial exchange axioms to Lorentzian/ultra-log-concave coefficient geometry and ultimately to algorithmic discrete convexity with certified symbolic transport laws.

The central scientific wager is this:

> The support exchange theorem captures where monomials live.  
> The next frontier is to capture how their coefficients are allowed to move.

That is the missing geometry.

---

## Core Objective

Define and study a **valuated exchange property** for multivariate polynomials whose support is M-convex, where the exchange axiom is strengthened by a coefficient inequality involving the four monomials in the elementary exchange square. Then prove that this property is transported by partial differentiation, with the transport law governed explicitly by the coefficient identity
\[
[pderiv\ i\ p]_m = (m_i+1)\,[p]_{m+e_i}.
\]

Your first target is not full generality at all costs. Your first target is a theorem that is:
1. mathematically nontrivial,
2. formally robust in Lean 4,
3. strong enough to expose a new mechanism,
4. computationally testable on weighted uniform matroid polynomials.

Build on:
- `Pythagorean/MConvexDifferentiation.lean`
- `Catalog/Pythagorean/LorentzianRecognitionComplete.lean`

especially the coefficient transport identity and any already-certified support/differentiation lemmas.

---

## New Definitions You Must Introduce

You must define at least one genuinely new concept. The recommended concept is a local four-point valuated exchange predicate.

### Definition 1: local valuated exchange square
For a coefficient function `c : α → R` on exponent vectors `α`, define a four-point multiplicative exchange inequality:
\[
c(\alpha)c(\beta) \le K \cdot c(\alpha-e_i+e_j)c(\beta+e_i-e_j)
\]
whenever `α i > β i` and `j` is an exchange witness.

This is the coefficient-level shadow of M-convexity.

### Definition 2: differentiably stable valuated exchange
A polynomial satisfies differentiably stable valuated exchange if every partial derivative satisfies the corresponding exchange inequality with the explicit rescaling induced by the `(m_i+1)` coefficient factor.

### Suggested Lean 4 structures/signatures
You should tailor these to the exact polynomial/exponent API in Mathlib, but the target should look approximately like this:

```lean
/-- Quantitative exchange inequality for coefficients on an exchange square. -/
def ValuatedExchange
    {σ R : Type*} [DecidableEq σ] [LinearOrderedRing R]
    (p : MvPolynomial σ R) (K : R) : Prop :=
  ∀ ⦃a b : σ →₀ ℕ⦄, a ∈ p.support →
    b ∈ p.support →
    ∀ ⦃i : σ⦄, b i < a i →
    ∃ j : σ,
      a j < b j ∧
      let a' := a - Finsupp.single i 1 + Finsupp.single j 1
      let b' := b + Finsupp.single i 1 - Finsupp.single j 1
      a' ∈ p.support ∧
      b' ∈ p.support ∧
      p.coeff a * p.coeff b ≤ K * (p.coeff a') * (p.coeff b')
```

If subtraction on finitely supported functions is awkward over `ℕ`, define a safe elementary exchange operation by hypothesis that the coordinate inequalities make the decrements legal.

A second, more robust formulation may use logarithmic/additive valuation style:

```lean
def AdditiveValuatedExchange
    {σ Γ : Type*} [DecidableEq σ] [LinearOrderedAddCommMonoid Γ]
    (w : (σ →₀ ℕ) → Γ) : Prop := ...
```

where the inequality is
\[
w(\alpha)+w(\beta)\le w(\alpha-e_i+e_j)+w(\beta+e_i-e_j)+C.
\]

This additive form may be easier to connect to valuated matroids and discrete convex analysis.

---

## Precise Theorem Targets

You must prove at least **3 substantial theorems**. They should involve multi-step reasoning, not brute-force simplification.

### Theorem 1: coefficient transport for partial derivatives
This is the foundational transport identity in the exact form needed for your exchange inequalities.

**Mathematical statement**
For any polynomial `p`, variable `i`, and exponent vector `m`,
\[
\operatorname{coeff}_{m}\big(\partial_i p\big)
= (m_i+1)\,\operatorname{coeff}_{m+e_i}(p).
\]

This likely already exists in the catalog in some form (`coeff_pderiv_eq`). You should not merely restate it: you should use it as a certified building block and derive one or more exchange-oriented corollaries from it.

**Lean target**
```lean
theorem coeff_pderiv_transport
    {σ R : Type*} [DecidableEq σ] [Semiring R]
    (p : MvPolynomial σ R) (i : σ) (m : σ →₀ ℕ) :
    (pderiv i p).coeff m = (m i + 1) • p.coeff (m + Finsupp.single i 1)
```

Adapt the scalar multiplication / multiplication by natural number to the exact existing API.

### Theorem 2: one-step preservation of valuated exchange under differentiation
This is the breakthrough theorem.

**Mathematical statement**
Assume `p` satisfies a multiplicative valuated exchange property with constant `K` on support exponents, and assume all coefficients are nonnegative. Then for any variable `i`, the derivative `∂ᵢ p` satisfies a derived valuated exchange property with an explicit transported constant `K'`, obtained from the original coefficient inequality and the coordinate rescaling factors from the derivative coefficient formula.

At minimum, prove a theorem of the following form:

\[
\mathrm{ValuatedExchange}(p,K)
\;\Longrightarrow\;
\mathrm{ValuatedExchange}\big(\partial_i p, K_i'\big),
\]
where
\[
K_i' = K \cdot \sup \frac{(a_i+1)(b_i+1)}{(a'_i+1)(b'_i+1)}
\]
over the local exchange configurations induced in the proof.

For the first formal milestone, it is enough to prove the **local transported inequality** for a fixed exchange square rather than the full global theorem.

**Lean target**
```lean
theorem valuatedExchange_pderiv_local
    {σ R : Type*} [DecidableEq σ] [LinearOrderedRing R]
    (p : MvPolynomial σ R) (K : R) (i : σ)
    (hVE : ValuatedExchange p K)
    (h_nonneg : ∀ m, 0 ≤ p.coeff m) :
    ∀ ⦃a b : σ →₀ ℕ⦄,
      a ∈ (pderiv i p).support →
      b ∈ (pderiv i p).support →
      ... →
      ∃ j : σ, ... -- exchanged derivative exponents
```

If the full support bookkeeping becomes too difficult, prove a specialized but nontrivial version:
- fixed finite variable set `Fin n`,
- homogeneous degree `d`,
- or weighted uniform matroid basis-generating polynomials.

That is acceptable if the theorem is real and clearly field-opening.

### Theorem 3: explicit preservation/disproof in the first nontrivial case `(n = 3, d = 2)`
You must resolve the smallest interesting case, not by brute-force enumeration but by structural proof.

Let
\[
p = a\,x_1x_2 + b\,x_1x_3 + c\,x_2x_3
\]
with positive coefficients.

Then compute derivatives:
\[
\partial_{x_1}p = a x_2 + b x_3,\quad
\partial_{x_2}p = a x_1 + c x_3,\quad
\partial_{x_3}p = b x_1 + c x_2.
\]

Prove the exact form of your valuated exchange property in this case, and determine whether differentiation preserves it.

A very plausible theorem is:

**Mathematical statement**
For the degree-2 weighted uniform basis polynomial on 3 variables,
\[
p = a\,x_1x_2 + b\,x_1x_3 + c\,x_2x_3,\qquad a,b,c>0,
\]
the multiplicative valuated exchange property with constant `K = 1` holds trivially or reduces to a sharp coefficient inequality, and every partial derivative preserves the property with the same constant.

If this is false for your chosen definition, then your mission is to prove a **counterexample theorem** instead. A negative theorem here is scientifically valuable because it identifies the correct normalization.

**Lean target**
```lean
theorem weighted_uniform_U32_pderiv_preserves
    {R : Type*} [LinearOrderedField R]
    {a b c : R}
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    let p : MvPolynomial (Fin 3) R := ...
    ValuatedExchange p 1 ∧
    ValuatedExchange (pderiv 0 p) 1 ∧
    ValuatedExchange (pderiv 1 p) 1 ∧
    ValuatedExchange (pderiv 2 p) 1
```

If preservation fails, replace the theorem by an exact characterization theorem giving necessary and sufficient conditions on `a,b,c`.

### Theorem 4: cross-domain bridge to Lorentzian or log-concavity
You must include at least one theorem connecting this domain to another area.

Here is the most promising bridge:

**Mathematical statement**
For a homogeneous polynomial with nonnegative coefficients satisfying your valuated exchange property, the coefficient sequence along any one-dimensional exchange ray satisfies a local log-concavity inequality, or a restricted ultra-log-concavity statement.

A modest but real theorem could be:
If the four-point valuated exchange holds on all adjacent exchange squares, then along any two-coordinate slice of fixed total degree, the coefficient sequence is log-concave at interior points.

This directly links discrete convex analysis to Lorentzian-style coefficient inequalities.

**Lean target**
```lean
theorem valuatedExchange_implies_slice_logConcave
    {σ R : Type*} [DecidableEq σ] [LinearOrderedField R]
    (p : MvPolynomial σ R) (K : R)
    (hVE : ValuatedExchange p K)
    (h_hom : p.IsHomogeneous)
    (h_nonneg : ∀ m, 0 ≤ p.coeff m) :
    ∀ (i j : σ) (m : σ →₀ ℕ),
      ... →
      p.coeff m ^ 2 ≤
        K * p.coeff (m - single i 1 + single j 1) *
            p.coeff (m + single i 1 - single j 1)
```

If the exact log-concavity form needs adjustment, state and prove a precise local two-step inequality that clearly points toward Lorentzian geometry.

This is your required cross-domain theorem:
- discrete convex analysis ↔ algebraic geometry/Lorentzian polynomials,
or
- discrete convex analysis ↔ combinatorial optimization/submodularity.

---

## Proof Strategy Architecture

You must not give Aristotle a single route. There are at least three.

### Strategy A: direct coefficient transport through exchange squares
**Best first route.**

1. Start from the certified theorem `coeff_pderiv_eq` / coefficient formula in `Pythagorean/MConvexDifferentiation.lean`.
2. Rewrite each derivative coefficient in the desired exchange inequality.
3. Factor out the multiplicative coordinate terms `(m i + 1)`.
4. Prove that the rescaling terms either:
   - cancel exactly in the relevant exchange configuration, or
   - are bounded by a computable factor `K'`.
5. Transport support membership using the known support-level differentiation/contraction theorem.

**Why this is promising:** it turns the theorem into deterministic algebra plus support bookkeeping, which Lean handles well once the exponent operations are disciplined.

### Strategy B: additive valuation via logarithms / tropicalization
1. Convert positive coefficients to an additive weight function `w(m) = -log(coeff m)` heuristically at the mathematical level.
2. Reformulate multiplicative exchange as additive four-point convexity.
3. Show differentiation adds a coordinate-dependent affine correction:
   \[
   w_{\partial_i}(m)=w(m+e_i)-\log(m_i+1).
   \]
4. The derivative therefore preserves valuated exchange up to a controlled affine perturbation.
5. Translate the additive theorem back to multiplicative inequalities where formalizable.

**Why this is powerful:** it reveals the true conceptual structure: differentiation is a valuation transport operator. Even if logs are not formalized in the final Lean theorem, this viewpoint can guide the normalization and the right statement.

### Strategy C: finite-model exact classification in `Fin 3`, degree 2
1. Define the weighted uniform basis polynomial explicitly.
2. Compute all relevant coefficients and derivatives symbolically.
3. Derive the exact exchange inequalities by hand.
4. Either prove preservation or isolate the obstruction and formulate the corrected normalization.
5. Generalize the pattern into the abstract theorem.

**Why this matters:** if the global theorem is too ambitious on the first pass, this small case can reveal the correct invariant. It is the ideal testbed for a falsifiable conjecture.

**Recommended order:** C → A → B.  
First classify the minimal nontrivial example, then prove the local transport theorem, then package the conceptual additive interpretation.

---

## Concrete Build Plan in Lean

### Phase 1: infrastructure
- Define safe exchange operations on exponent vectors.
- Prove lemmas about coordinate updates, support transport, and coefficient indexing.
- Avoid brittle subtraction on `ℕ`-valued finsupps unless guarded by hypotheses.

Possible helper definitions:
```lean
def exchangeDownUp (a : σ →₀ ℕ) (i j : σ) : σ →₀ ℕ := ...
def exchangeUpDown (b : σ →₀ ℕ) (i j : σ) : σ →₀ ℕ := ...
```

Prove coordinate lemmas:
```lean
theorem exchangeDownUp_apply_eq ...
theorem exchangeDownUp_mem_support_of ...
theorem degree_preserved_exchange ...
```

### Phase 2: local transported inequality
- Use `coeff_pderiv_eq`.
- Establish positivity/nonnegativity lemmas for derivative coefficients from positivity of original coefficients.
- Prove a theorem with explicit rescaling factor.

A realistic theorem form:
```lean
theorem coeff_exchange_transport_bound
    ...
    :
    (pderiv i p).coeff a * (pderiv i p).coeff b
      ≤ K' * (pderiv i p).coeff a' * (pderiv i p).coeff b'
```

### Phase 3: weighted uniform matroid test case
- Define `U_{2,3}` basis polynomial.
- Compute coefficients and derivatives.
- Prove the exact preservation theorem or a sharp counterexample theorem.

### Phase 4: bridge theorem
- Prove a local two-point or three-point log-concavity consequence on slices.
- Connect explicitly to Lorentzian recognition ideas from the catalog.

---

## Cross-Domain Connections You Must Make Explicit

This project is important because it links three theories that are usually studied separately:

1. **Discrete convex analysis / valuated matroids (Murota)**
   - Exchange axioms become coefficient inequalities.
   - This suggests new optimization principles for weighted basis-generating polynomials.

2. **Lorentzian polynomials / algebraic geometry**
   - Support M-convexity is already a combinatorial shadow of Lorentzian geometry.
   - Your valuated exchange law could be a local certificate for coefficient log-concavity and Hodge-type inequalities on slices.

3. **Combinatorial optimization / submodular minimization**
   - If coefficient valuations satisfy exchange inequalities and are stable under contraction/differentiation, then elimination and marginalization operations may preserve algorithmically tractable convexity.
   - This hints at certified optimization on weighted combinatorial objects.

You should mention at least one bridge theorem or discussion connecting to:
- log-concavity,
- ultra-log-concavity,
- Lorentzian signatures,
- valuated matroids,
- or submodular optimization.

---

## Falsifiable Conjecture with Computational Test

You must state a conjecture strong enough to be wrong.

### Conjecture
For every homogeneous polynomial `p` with nonnegative coefficients and M-convex support, if `p` satisfies local multiplicative valuated exchange with constant `K = 1`, then every partial derivative also satisfies local multiplicative valuated exchange with `K = 1`.

This is bold and likely false without normalization. That is good.

### Testable prediction
For weighted uniform matroid basis-generating polynomials
\[
p_{d,n,w}(x)=\sum_{|S|=d} w_S \prod_{i\in S} x_i,
\]
sample positive weights `w_S` and test whether:
- `ValuatedExchange p 1`,
- `ValuatedExchange (∂ᵢ p) 1` for all `i`.

If counterexamples appear, search for the smallest normalization factor `K'(i)` predicted by the coefficient transport formula.

Your `demo.py` should:
- generate weighted uniform examples,
- compute exchange inequalities before/after differentiation,
- report whether the naive `K=1` conjecture survives,
- estimate the minimal transported constant.

This is not optional.

---

## Required Deliverables

You must produce **all** of the following:

### 1. Lean file with at least 3 substantial theorems
Requirements:
- no trivial theorem farming,
- no reliance on `native_decide`, `decide`, `norm_num`, `rfl` except where mathematically incidental,
- at least 3 theorems requiring genuine proof structure,
- at least one new definition,
- at least one cross-domain theorem.

### 2. `FUTURE_DIRECTIONS.md`
Include **3–5 research directions**, each written as original prose, and each containing the exact sentences:
- **“The key insight is...”**
- **“Why now?”**

At least one direction must bridge to a different domain, such as:
- tropical geometry,
- statistical physics,
- optimization,
- or Hodge-theoretic combinatorics.

Possible future directions:
- valuated exchange as a local certificate for Lorentzianity,
- tropicalization of coefficient transport,
- certified submodular optimization via derivative-stable valuations,
- entropy/log-partition interpretations for weighted basis polynomials.

### 3. `RESEARCH_PAPER.md`
A standalone scientific paper that explains:
- the new definition,
- the main theorems,
- why differentiation is the natural contraction/marginalization operator,
- the resolved `n=3, d=2` case,
- the relation to Lorentzian/log-concave geometry,
- and what should be attacked next.

Someone reading only this paper must understand the discovery without seeing the code.

### 4. `ARTICLE.md`
Write this in **Scientific American style**:
- vivid,
- concept-driven,
- accessible to a broad mathematically literate audience.

Taboo:
- do **not** focus on formal verification,
- do **not** center the story on theorem proving infrastructure.

Instead explain the mathematical idea:
how a combinatorial exchange law acquires a quantitative coefficient geometry and survives differentiation.

### 5. Verified algorithm / computational method
You must implement a verified computational method that:
- checks local valuated exchange inequalities for a finite polynomial,
- computes derivative transport constants,
- or searches for counterexamples to naive preservation.

This should be mathematically meaningful, not decorative.

### 6. `demo.py`
Interactive or semi-interactive script that:
- constructs weighted uniform matroid polynomials,
- evaluates exchange inequalities,
- differentiates them,
- visualizes or tabulates preservation/failure,
- and tests the falsifiable conjecture above.

---

## Application Keywords

Use these in your paper and notes where appropriate:

**valuated matroids, M-convexity, discrete convex analysis, Lorentzian polynomials, log-concavity, ultra-log-concavity, coefficient transport, partial differentiation, basis-generating polynomials, weighted matroids, submodular optimization, Hodge inequalities, exchange axiom, tropicalization, combinatorial Hodge theory**

---

## Minimum Theorem Checklist

A successful project should include the following theorem-level artifacts:

1. **A new definition** of `ValuatedExchange` or equivalent.
2. **A local coefficient transport theorem** derived from `coeff_pderiv_eq`.
3. **A nontrivial preservation theorem** for differentiation, even if local/specialized.
4. **A complete resolution of the `(n=3, d=2)` weighted uniform case**: theorem or counterexample.
5. **A cross-domain consequence**: log-concavity/Lorentzian/submodular bridge.

If a universal preservation theorem fails, that is not failure. It is a discovery. Then the correct theorem becomes:

> identify the exact normalization under which differentiation preserves valuated exchange.

That would be the real breakthrough.

Be bold, be precise, and do not stop at support. The coefficients are where the geometry begins.

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
