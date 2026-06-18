Soli Deo Gloria

## Assignment: Direction 2 — Aggregate Anti-Cancellation via Lorentzian Structure

**Mode:** `prove`

Prove genuinely new theorems at the interface of combinatorial Hodge theory, sparse polynomial support geometry, and arithmetic circuit complexity. The target is not another positivity lemma: it is a structural theorem saying that **Lorentzian geometry rigidifies Hessian support so strongly that weighted aggregation cannot create accidental annihilation**. If true, this is a missing bridge from local support control to global lower-bound technology.

Build explicitly on:

- `Bridges/Catalog/Speculative/AutoResearch/AntiCancellationLorentzian.lean`
- `Bridges/Catalog/Speculative/AutoResearch/WeightedSupportShadow.lean`

Your goal is to push beyond “pairwise no-cancellation” and beyond “positive-weight aggregation” into a theorem where **Lorentzian sign structure itself prevents inter-pair cancellation**.

---

## Core Mathematical Vision

Let
\[
p(x_1,\dots,x_n)=\sum_{\alpha \in \mathbb{N}^n} c_\alpha x^\alpha
\]
be a homogeneous polynomial with support contained in a matroid basis polytope slice, and suppose the coefficient array satisfies a Lorentzian-type condition in the sense of Brändén–Huh. For a symmetric weight matrix \(A=(a_{ij})\), define the aggregated Hessian operator
\[
H_A(p) := \sum_{i,j=1}^n a_{ij}\,\partial_i\partial_j p.
\]
The naive support upper bound is the union of all per-pair shadows:
\[
\operatorname{supp}(H_A(p))
\subseteq
\bigcup_{i,j: a_{ij}\neq 0} \operatorname{supp}(\partial_i\partial_j p).
\]
The breakthrough target is to prove a **support exactness theorem** under Lorentzian hypotheses:
\[
\operatorname{supp}(H_A(p))
=
\bigcup_{i,j: a_{ij}\neq 0} \operatorname{supp}(\partial_i\partial_j p),
\]
so no monomial disappears through cross-pair cancellation.

This would convert Hessian aggregation from an analytically delicate signed operation into a **combinatorially exact support transformer**, opening a route to support-based lower bounds for classes of structured arithmetic circuits.

---

## Precise Theorem Targets

You must formalize at least one new mathematical structure capturing the “Lorentzian anti-cancellation profile” of a polynomial. Do not merely restate existing catalog predicates.

### New definition to introduce

Define a predicate expressing aggregate anti-cancellation for a family of second derivatives.

Suggested concept:

- `AggregateAntiCancel (p : MvPolynomial σ R) (A : σ → σ → R) : Prop`

meaning: every monomial in any active per-pair second derivative survives in the weighted sum.

You should also define a support-shadow object if needed, e.g.

- `pairShadow (p : MvPolynomial σ R) (i j : σ) : Finset (σ →₀ ℕ)`
- `aggregateShadow (p : MvPolynomial σ R) (A : σ → σ → R) : Finset (σ →₀ ℕ)`

with
\[
\texttt{aggregateShadow } p A
=
\bigcup_{A(i,j)\neq 0} \texttt{pairShadow } p\, i\, j.
\]

If existing catalog definitions already cover part of this, extend them with a genuinely new signed/Lorentzian layer.

---

## Main theorem statement

### Theorem A: Lorentzian aggregate support exactness

Formal target (adapt as needed to the exact catalog API):

```lean
theorem support_hessianSum_eq_aggregateShadow_of_lorentzian
    {σ : Type*} [Fintype σ] [DecidableEq σ]
    (p : MvPolynomial σ ℚ)
    (A : σ → σ → ℚ)
    (hhom : p.IsHomogeneous)
    (hmatroid : SupportInBasisPolytope p)
    (hlor : LorentzianSigned p)
    (hsym : Symmetric A)
    (hwt : ∀ i j, A i j ≠ 0 → CompatibleLorentzWeight p A i j) :
    (p.hessianSumSupport A) = aggregateShadow p A
```

If equality of `Finset`s is too brittle, prove set-extensional equality first:

```lean
theorem mem_support_hessianSum_iff_mem_aggregateShadow_of_lorentzian
    {σ : Type*} [Fintype σ] [DecidableEq σ]
    (p : MvPolynomial σ ℚ)
    (A : σ → σ → ℚ)
    (m : σ →₀ ℕ)
    (hhom : p.IsHomogeneous)
    (hmatroid : SupportInBasisPolytope p)
    (hlor : LorentzianSigned p)
    (hsym : Symmetric A)
    (hwt : ∀ i j, A i j ≠ 0 → CompatibleLorentzWeight p A i j) :
    m ∈ p.hessianSumSupport A ↔ m ∈ aggregateShadow p A
```

### Minimal mathematical content of the assumptions

Your `LorentzianSigned` should not be vacuous. It should encode at least one of:

1. coefficient sign coherence on basis-polytope fibers,
2. ultra-log-concavity / two-step Newton inequalities on derivative coefficient sequences,
3. a compatibility condition ensuring that whenever two pairs contribute to the same monomial, their contributions cannot sum to zero.

Do not hide the theorem inside a definition. The theorem should still read as a real mathematical statement.

---

## Second theorem target

### Theorem B: pairwise-to-aggregate lifting via overlap sign coherence

Prove an intermediate theorem separating the combinatorics from the Hodge input:

```lean
theorem aggregateAntiCancel_of_pairwiseShadow_exact_of_overlapSignCoherent
    {σ : Type*} [Fintype σ] [DecidableEq σ]
    (p : MvPolynomial σ ℚ)
    (A : σ → σ → ℚ)
    (hpair : ∀ i j, A i j ≠ 0 →
      support (∂² p i j) = pairShadow p i j)
    (hcoh : OverlapSignCoherent p A) :
    AggregateAntiCancel p A
```

This theorem is strategically crucial: it isolates the genuinely new mechanism. If you can prove this abstract lifting theorem, then the Lorentzian theorem becomes an instantiation via a separate lemma:

```lean
theorem lorentzian_implies_overlapSignCoherent
    ...
    (hlor : LorentzianSigned p) :
    OverlapSignCoherent p A
```

This decomposition is likely the cleanest architecture.

---

## Third theorem target

### Theorem C: cross-domain theorem linking Lorentzian support geometry to log-concavity / convexity

You are required to include a theorem that genuinely bridges domains. A strong option:

```lean
theorem coefficientSlice_logConcave_of_lorentzianShadow
    {σ : Type*} [Fintype σ] [DecidableEq σ]
    (p : MvPolynomial σ ℚ)
    (u v : σ)
    (hlor : LorentzianSigned p) :
    LogConcave (fun k : ℕ => sliceCoeff p u v k)
```

or a support-convexity statement:

```lean
theorem aggregateShadow_Mconvex_of_lorentzian
    {σ : Type*} [Fintype σ] [DecidableEq σ]
    (p : MvPolynomial σ ℚ)
    (A : σ → σ → ℚ)
    (hmatroid : SupportInBasisPolytope p)
    (hlor : LorentzianSigned p) :
    MConvex (aggregateShadow p A : Set (σ →₀ ℕ))
```

This is where the project stops being “about derivatives” and becomes a new bridge among:

- **Hodge theory:** Lorentzian signatures and Hodge–Riemann relations,
- **matroid theory:** basis exchange and jump systems,
- **discrete convex analysis:** \(M\)-convexity / exchange axioms,
- **complexity theory:** support rigidity as a lower-bound invariant.

Even a weaker formally provable bridge theorem is acceptable if it is mathematically nontrivial and not a tautological reformulation.

---

## Conjecture with falsifiable prediction

State and test the following conjecture in Lean comments and in the paper:

### Conjecture: full Hessian support rigidity for Lorentzian basis-generating polynomials

For every homogeneous Lorentzian polynomial \(p\) over characteristic zero with support contained in a matroid basis polytope, and every symmetric weight matrix \(A\) whose nonzero entries have a common sign on each overlap class of derivative contributions,
\[
\operatorname{supp}\!\left(\sum_{i,j} a_{ij}\partial_i\partial_j p\right)
=
\bigcup_{a_{ij}\neq 0}\operatorname{supp}(\partial_i\partial_j p).
\]

### Testable prediction

For all rank-3 and rank-4 matroids on at most 6 elements, for basis-generating polynomials with Lorentzian coefficient perturbations preserving the Brändén–Huh inequalities, exhaustive computation should find:

1. **no counterexample** to support exactness under overlap-sign-coherent weights;
2. **explicit counterexamples** outside the Lorentzian class where two distinct \((i,j)\)-shadows overlap and cancel after aggregation.

This is falsifiable: a single small counterexample destroys the conjecture.

---

## Lean 4 formalization targets

Use exact theorem names from the catalog where available. If names differ, adapt, but preserve the architecture.

Potential formal signatures to aim for:

```lean
def pairShadow
    {σ : Type*} [DecidableEq σ]
    (p : MvPolynomial σ ℚ) (i j : σ) : Finset (σ →₀ ℕ) := ...

def aggregateShadow
    {σ : Type*} [Fintype σ] [DecidableEq σ]
    (p : MvPolynomial σ ℚ) (A : σ → σ → ℚ) : Finset (σ →₀ ℕ) := ...

def AggregateAntiCancel
    {σ : Type*} [Fintype σ] [DecidableEq σ]
    (p : MvPolynomial σ ℚ) (A : σ → σ → ℚ) : Prop := ...

def OverlapSignCoherent
    {σ : Type*} [Fintype σ] [DecidableEq σ]
    (p : MvPolynomial σ ℚ) (A : σ → σ → ℚ) : Prop := ...

def LorentzianSigned
    {σ : Type*} [Fintype σ] [DecidableEq σ]
    (p : MvPolynomial σ ℚ) : Prop := ...
```

and then:

```lean
theorem aggregateAntiCancel_of_pairwiseShadow_exact_of_overlapSignCoherent
    {σ : Type*} [Fintype σ] [DecidableEq σ]
    (p : MvPolynomial σ ℚ)
    (A : σ → σ → ℚ) :
    ... := ...

theorem lorentzian_implies_overlapSignCoherent
    {σ : Type*} [Fintype σ] [DecidableEq σ]
    (p : MvPolynomial σ ℚ)
    (A : σ → σ → ℚ) :
    ... := ...

theorem support_hessianSum_eq_aggregateShadow_of_lorentzian
    {σ : Type*} [Fintype σ] [DecidableEq σ]
    (p : MvPolynomial σ ℚ)
    (A : σ → σ → ℚ) :
    ... := ...
```

If full generality becomes technically prohibitive, first prove a rank-bounded theorem for `σ = Fin 3` or `Fin 4`, but the statement must still be conceptually deep and not a brute-force enumeration result.

---

## Proof architecture: 3 viable strategies

### Strategy A — Overlap-class decomposition + sign coherence
**Most promising.**

1. Partition monomials in the aggregate shadow by the set of pairs \((i,j)\) contributing to them.
2. Show from `WeightedSupportShadow.lean` that each active pair contributes the monomial individually.
3. Use a new `OverlapSignCoherent` lemma to prove all nonzero contributions in a fixed overlap class have the same sign, hence their weighted sum is nonzero.

Why this is promising:
- It cleanly separates existing per-pair support exactness from the new cancellation problem.
- It avoids formalizing the full Brändén–Huh machinery at once.
- It is compatible with a staged proof: abstract lifting theorem first, Lorentzian instantiation second.

Key proof tactics likely needed:
- `rcases` on membership in union shadows,
- `by_contra` for cancellation impossibility,
- multi-step `calc` for coefficient extraction in the aggregated Hessian,
- `field_simp` if rational weight normalization is used.

---

### Strategy B — Coefficient extraction + ultra-log-concavity on local slices
1. For each target monomial \(m\), write the coefficient of \(m\) in \(H_A(p)\) as a finite weighted sum of neighboring coefficients of \(p\).
2. Organize these coefficients along one-dimensional or two-dimensional slices of the exponent lattice.
3. Use Lorentzian slice inequalities (Newton/ultra-log-concavity type) to show the weighted sum cannot vanish when one term is active and weights are sign-compatible.

Why it matters:
- This would reveal the exact analytic mechanism behind anti-cancellation.
- It produces stronger quantitative inequalities, not just support statements.

Risk:
- More beautiful mathematically, but heavier formalization burden.

---

### Strategy C — Discrete convex geometry of support shadows
1. Show the support of a Lorentzian polynomial is a jump system / \(M\)-convex set in the relevant homogeneous slice.
2. Prove second-derivative shadows inherit a controlled exchange geometry.
3. Use exchange paths to show overlapping pair-shadows cannot contribute opposite signs to the same exponent without violating the Lorentzian exchange inequalities.

Why this is visionary:
- It reframes anti-cancellation as a theorem in discrete convex analysis.
- It opens a route to support-rigidity theorems far beyond Hessians.

Risk:
- Requires more infrastructure, but even one good bridge theorem here would be field-opening.

---

## Required theorem style and proof depth

Your file must contain **at least 3 substantial theorems** using real proof structure. At least three proofs should visibly use combinations of:

- `induction`
- `rcases`
- `by_contra`
- `field_simp`
- multi-step `calc`

Do not satisfy the assignment with definitional equalities or finite brute force. If a theorem reduces to a one-line simplification, it does not count toward the depth requirement unless the statement itself is a major structural identity.

---

## Concrete implementation plan

1. Inspect the exact support-shadow theorem in
   `Bridges/Catalog/Speculative/AutoResearch/WeightedSupportShadow.lean`.
   Determine the strongest already-proved per-pair statement:
   - coefficient nonvanishing?
   - exact support equality?
   - under what hypotheses on coefficients/characteristic?

2. Inspect
   `Bridges/Catalog/Speculative/AutoResearch/AntiCancellationLorentzian.lean`
   and identify:
   - whether it proves positive-weight anti-cancellation,
   - what positivity notion is used,
   - whether there is already a sign-regularity lemma to reuse.

3. Introduce the new abstractions:
   - `OverlapSignCoherent`
   - `AggregateAntiCancel`
   - `LorentzianSigned` or a weaker but nontrivial formal proxy

4. Prove the abstract lifting theorem from pairwise exactness + overlap coherence.

5. Prove a Lorentzian-to-overlap-coherence theorem in a tractable setting:
   - ideally all finite variables,
   - fallback: homogeneous degree 3 or 4,
   - fallback: `Fin 3` / `Fin 4` with symbolic, not brute-force, proofs.

6. Deduce the main support exactness theorem.

7. Build a counterexample searcher for non-Lorentzian inputs.

---

## Cross-domain connections you must highlight

This project must explicitly connect at least one theorem to a different mathematical domain.

### Mandatory bridges to discuss and, where possible, formalize:
- **Hodge theory / algebraic geometry:** Lorentzian polynomials encode Hodge–Riemann-type inequalities.
- **Matroid theory:** basis polytope support and basis exchange control where second derivatives can land.
- **Discrete convex analysis:** support shadows should exhibit exchange or \(M\)-convex behavior.
- **Arithmetic complexity:** exact support propagation under Hessian aggregation is a candidate invariant for lower bounds.
- **Convex optimization / probability:** ultra-log-concavity governs concentration and negative dependence; anti-cancellation may be a support-level shadow of these phenomena.

A particularly strong cross-domain theorem would say that a combinatorial Hodge condition implies a support-convexity or log-concavity property strong enough to force algebraic noncancellation.

---

## Application keywords

Include these in the paper and article where relevant:

- Lorentzian polynomial
- Brändén–Huh theory
- Hodge–Riemann relations
- matroid basis polytope
- support shadow
- Hessian aggregation
- anti-cancellation
- ultra-log-concavity
- \(M\)-convexity
- jump systems
- arithmetic circuit lower bounds
- sparse polynomial complexity
- combinatorial Hodge theory
- negative dependence
- discrete convex geometry

---

## Deliverables (ALL mandatory)

You must produce all of the following:

### 1. Lean development
A new Lean file proving theorems in this direction with minimal `sorry`. It must include:
- at least one novel definition,
- at least 3 substantial theorems,
- at least one cross-domain theorem,
- at least one explicitly stated conjecture in comments.

### 2. Verified algorithm / computational method
Implement a verified or semi-verified computational method for:
- checking the aggregate shadow,
- computing the weighted Hessian support,
- testing overlap-sign coherence,
- searching for counterexamples outside the Lorentzian regime.

This must be more than a theorem statement.

### 3. `demo.py`
Create an interactive Python demo that:
- constructs small homogeneous polynomials in 3–4 variables,
- computes pair-shadows and aggregate shadows,
- computes weighted Hessian sums,
- tests support exactness,
- highlights cancellations when Lorentzian conditions fail.

The demo should let the user toggle:
- coefficient signs,
- weight matrices,
- support families from small matroids.

### 4. `RESEARCH_PAPER.md`
A standalone scientific document explaining:
- the precise theorem,
- the mathematical mechanism,
- how it builds on the catalog,
- why aggregate anti-cancellation matters,
- what conjectures and next steps follow.

Someone reading only this paper must understand the discovery.

### 5. `ARTICLE.md`
Write this in Scientific American style:
- engaging,
- idea-centered,
- focused on why Lorentzian geometry can prevent cancellation,
- explaining the significance for geometry, combinatorics, and complexity.

Do **not** focus on formal verification machinery.

### 6. `FUTURE_DIRECTIONS.md`
Include 3–5 original research directions. Each direction must include:
- a sentence beginning **“The key insight is...”**
- a sentence beginning **“Why now?”**

At least one direction must bridge to a different domain, such as:
- statistical physics,
- optimization,
- coding theory,
- quantum information,
- algebraic statistics.

---

## Standard for success

Success is not “some support lemma.” Success is a theorem that makes the following sentence defensible:

> Lorentzian structure does not merely constrain coefficients quantitatively; it enforces a qualitative rigidity of second-derivative support under aggregation.

If you can establish even a sharp special case of that principle in Lean, with a working search tool and compelling counterexamples outside the hypothesis class, you will have created a new research corridor connecting combinatorial Hodge theory to complexity-theoretic anti-cancellation phenomena.

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
