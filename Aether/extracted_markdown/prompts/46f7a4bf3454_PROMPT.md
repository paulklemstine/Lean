Soli Deo Gloria

## Assignment: Direction 2 — M-Convexity Inheritance for Hessian Shadows

**Mode:** `prove`

Prove a genuinely new theorem at the interface of **discrete convex analysis, combinatorial Hodge theory, and matroid optimization**. Do not settle for the existing sub-convexity statement: push to a full inheritance principle showing that Hessian aggregation acts as a structure-preserving operator on M-convex supports.

This is not merely an extension. If successful, it identifies a new **functorial mechanism** from Lorentzian geometry to discrete optimization: second-derivative aggregation would become a morphism on the level of exchange systems. That would open an algorithmic pathway from Hodge-theoretic positivity to polynomial-time optimization over derived combinatorial state spaces.

---

## Central Objective

Let `p` be a homogeneous polynomial with finite support in `ℕ^n`, and let `A : Fin n → Fin n → ℝ` be a positive weight matrix. Define the **aggregate Hessian shadow support**
\[
\operatorname{AgSh}(p,A)
:= \left\{ \gamma \in \mathbb{N}^n :
\exists \alpha \in \operatorname{supp}(p),\ \exists i,j,\ \alpha_i>0,\ \alpha_j>0,\ 
\gamma = \alpha - e_i - e_j,\ A_{ij}>0 \right\}.
\]
When multiplicities are aggregated coefficientwise, this is the support of the weighted second-derivative aggregate
\[
\operatorname{AgHess}(p,A)
:= \sum_{i,j} A_{ij}\,\partial_i\partial_j p.
\]

Your target is to prove that **M-convexity is inherited by this aggregate shadow** under meaningful hypotheses, first in a robust special case, then in maximal generality if possible.

---

## Precise Theorem Targets

### Theorem 1: Uniform positive Hessian-shadow M-convexity
Prove a theorem of the following form:

> If `S ⊆ ℕ^n` is M-convex and all weights are strictly positive, then the two-step derivative shadow
> \[
> \partial^{(2)}S := \{ \alpha - e_i - e_j \mid \alpha\in S,\ \alpha_i>0,\ \alpha_j>0 \}
> \]
> is again M-convex.

This is the clean combinatorial heart. It removes coefficient complications and isolates the exchange mechanism.

A Lean 4 target signature could be:

```lean
theorem mconvex_twoStepShadow
    {n : ℕ}
    (S : Finset (Fin n → ℕ))
    (hS : MConvexSupport S) :
    MConvexSupport (twoStepShadow S)
```

where you define:

```lean
def twoStepShadow {n : ℕ} (S : Finset (Fin n → ℕ)) : Finset (Fin n → ℕ) := ...
```

and `MConvexSupport` is your formal predicate expressing the symmetric exchange axiom on finite supports of constant total degree.

This theorem is already significant: it says that “remove two units in all allowable coordinate directions” preserves the full exchange geometry, not merely sub-convexity.

---

### Theorem 2: Weighted aggregate shadow support invariance
Lift the set-theoretic theorem to weighted Hessian aggregation.

> If `supp(p)` is M-convex and `A` is entrywise positive, then the support of the aggregate Hessian polynomial is M-convex:
> \[
> \operatorname{supp}(\operatorname{AgHess}(p,A)) \text{ is M-convex.}
> \]

A Lean-style target signature:

```lean
theorem mconvex_support_aggregateHessian
    {n : ℕ}
    (p : MvPolynomial (Fin n) ℝ)
    (A : Fin n → Fin n → ℝ)
    (hp_hom : IsHomogeneous p)
    (hp_mconvex : MConvexSupport (polySupportFinset p))
    (hApos : ∀ i j, 0 < A i j) :
    MConvexSupport (polySupportFinset (aggregateHessian p A))
```

You will likely need a support-level lemma identifying the support of `aggregateHessian` with the `twoStepShadow` of the support, up to anti-cancellation hypotheses already suggested by the catalog theorem in `Pythagorean/LorentzianAggregateAntiCancel.lean`.

---

### Theorem 3: Matroid basis polynomial corollary
Specialize to basis generating polynomials of matroids, especially uniform matroids, where the support is a classical M-convex set.

> For any matroid basis polynomial `B_M`, the support of its aggregate Hessian under positive weights is M-convex.

Lean-style target:

```lean
theorem matroidBasis_aggregateHessian_mconvex
    {n : ℕ}
    (M : Matroid (Fin n))
    (A : Fin n → Fin n → ℝ)
    (hApos : ∀ i j, 0 < A i j) :
    MConvexSupport
      (polySupportFinset (aggregateHessian (basisPolynomial M) A))
```

This theorem is your bridge to optimization and testable experiments. It should connect the exchange axiom for matroid bases to Hessian-derived state spaces.

---

## New Definitions You Must Introduce

You are required to define at least one genuinely new concept. Introduce the following:

### 1. `twoStepShadow`
The pure support-level second-derivative shadow.

```lean
def twoStepShadow {n : ℕ} (S : Finset (Fin n → ℕ)) : Finset (Fin n → ℕ) := ...
```

### 2. `WeightedShadowCompatible`
A predicate stating that a weight matrix does not erase any allowable second derivative support element.

```lean
def WeightedShadowCompatible {n : ℕ}
    (S : Finset (Fin n → ℕ))
    (A : Fin n → Fin n → ℝ) : Prop := ...
```

Suggested meaning:
\[
\forall \alpha\in S,\ \forall i,j,\ \alpha_i>0 \to \alpha_j>0 \to A_{ij}\neq 0.
\]

This weakens strict positivity and may let you prove a sharper theorem than the all-positive case.

### 3. `HessianShadowMorphism`
A structure/property encapsulating that a support operator preserves M-convexity.

```lean
def HessianShadowMorphism {n : ℕ}
    (T : Finset (Fin n → ℕ) → Finset (Fin n → ℕ)) : Prop := ...
```

Use it to state a meta-theorem:
```lean
theorem twoStepShadow_is_morphism {n : ℕ} :
  HessianShadowMorphism (@twoStepShadow n)
```

This is conceptually powerful: it upgrades a theorem into a reusable categorical principle.

---

## Recommended Proof Architecture

You must provide at least 3 substantial theorems with nontrivial proofs using induction, `rcases`, `by_contra`, `field_simp` where relevant, and multi-step `calc`. Avoid any theorem whose proof collapses to computation.

### Strategy A: Direct symmetric exchange descent on preimages
Most promising.

1. **Lift shadow points to antecedents.**  
   For `γ, δ ∈ twoStepShadow S`, choose witnesses
   \[
   \gamma = \alpha - e_i - e_j,\qquad \delta = \beta - e_k - e_\ell
   \]
   with `α, β ∈ S`.

2. **Compare imbalance coordinates.**  
   Given `t` with `γ_t > δ_t`, analyze whether the excess comes from the underlying `α, β` or from the derivative indices. This creates a finite case split:
   - genuine support imbalance (`α_t > β_t`);
   - artificial imbalance created by shadow subtraction.

3. **Invoke M-convex exchange in `S`.**  
   Use the exchange property on `α, β` to find `u` with `α_u < β_u` and
   \[
   \alpha' = \alpha - e_t + e_u \in S.
   \]
   Then show that after adjusting the derivative witness pair appropriately, one obtains
   \[
   \gamma - e_t + e_u \in twoStepShadow S.
   \]

Why this is promising: it attacks the exact axiom to be proved and should align with the existing sub-convexity theorem from the catalog. The main work is witness bookkeeping, which Lean can handle with careful lemmas on coordinate arithmetic.

---

### Strategy B: Decompose the two-step shadow into compositions of one-step shadow operators
Potentially cleaner if one-step theory is easier.

1. Define the one-step shadow
   \[
   \partial S := \{\alpha - e_i : \alpha\in S,\ \alpha_i>0\}.
   \]

2. Prove:
   ```lean
   theorem mconvex_oneStepShadow
       {n : ℕ} (S : Finset (Fin n → ℕ))
       (hS : MConvexSupport S) :
       MConvexSupport (oneStepShadow S)
   ```

3. Then derive:
   \[
   twoStepShadow(S) = oneStepShadow(oneStepShadow(S))
   \]
   up to definitional equality or support extensionality, hence M-convexity follows by iteration.

Why this is elegant: M-convexity is often stable under natural “lowering” operations, and one-step exchange may be much easier to formalize. If successful, this gives a reusable toolbox beyond the immediate theorem.

Risk: support equality for repeated differentiation may require delicate handling of repeated indices (`i=j`) and positivity conditions.

---

### Strategy C: Anti-cancellation plus support exactness from aggregate Hessians
Best for the polynomial-level theorem.

1. Use catalog anti-cancellation results from  
   `Pythagorean/LorentzianAggregateAntiCancel.lean`
   to prove support exactness:
   \[
   \operatorname{supp}(\operatorname{AgHess}(p,A)) = twoStepShadow(\operatorname{supp}(p))
   \]
   under positive or compatibility hypotheses.

2. Reduce the polynomial theorem to Theorem 1:
   ```lean
   rw [support_aggregateHessian_eq_twoStepShadow]
   exact mconvex_twoStepShadow _ hp_mconvex
   ```

3. For Lorentzian polynomials, invoke the known theorem from  
   `Catalog/Speculative/AutoResearch/LorentzianMConvex.lean`
   that the support is M-convex.

Why this matters: this is the route that converts the combinatorial theorem into a bona fide Hodge-theoretic statement.

---

## Specific Intermediate Lemmas to Target

These lemmas will likely be the backbone of the formalization.

```lean
lemma mem_twoStepShadow_iff
    {n : ℕ} {S : Finset (Fin n → ℕ)} {γ : Fin n → ℕ} :
    γ ∈ twoStepShadow S ↔
      ∃ α ∈ S, ∃ i j,
        0 < α i ∧ 0 < α j ∧ γ = α - single i 1 - single j 1
```

```lean
lemma totalDegree_twoStepShadow
    {n : ℕ} {S : Finset (Fin n → ℕ)} {d : ℕ}
    (hdeg : ∀ α ∈ S, Finset.univ.sum α = d) :
    ∀ γ ∈ twoStepShadow S, Finset.univ.sum γ = d - 2
```

```lean
lemma exchange_lift_from_shadow
    {n : ℕ} {S : Finset (Fin n → ℕ)}
    (hS : MConvexSupport S)
    {γ δ : Fin n → ℕ}
    (hγ : γ ∈ twoStepShadow S)
    (hδ : δ ∈ twoStepShadow S)
    {t : Fin n}
    (ht : δ t < γ t) :
    ∃ u : Fin n, γ u < δ u ∧ γ - single t 1 + single u 1 ∈ twoStepShadow S
```

```lean
lemma support_aggregateHessian_eq_twoStepShadow
    {n : ℕ}
    (p : MvPolynomial (Fin n) ℝ)
    (A : Fin n → Fin n → ℝ)
    (hcompat : WeightedShadowCompatible (polySupportFinset p) A) :
    polySupportFinset (aggregateHessian p A) = twoStepShadow (polySupportFinset p)
```

These should require actual proof engineering, not automation.

---

## Cross-Domain Connections You Must Explicitly Develop

### 1. Discrete convex analysis ↔ Combinatorial Hodge theory
The support of a Lorentzian polynomial is already known to encode deep concavity/exchange phenomena. Showing Hessian aggregation preserves M-convexity would mean **second-order Hodge operators preserve discrete exchange geometry**.

### 2. Matroid theory ↔ Optimization algorithms
M-convex sets admit steepest-descent and exchange-based polynomial-time optimization methods in Murota’s framework. If aggregate Hessian shadows are M-convex, then one can optimize linear and separable convex objectives over Hessian-derived supports efficiently.

### 3. Tropical / valuated viewpoint ↔ Algebraic geometry
The support transformation
\[
\alpha \mapsto \alpha - e_i - e_j
\]
is the combinatorial skeleton of a second-order differential operator. In tropical language, this resembles a controlled erosion of Newton polytopes. Proving M-convexity inheritance suggests a new bridge between **Lorentzian Hessians and tropical convexity of Newton subdivisions**.

### 4. Statistical physics / negative dependence
Lorentzian and strongly log-concave polynomials appear in partition functions and determinantal models. A preserved M-convex shadow would imply that **pairwise-response landscapes** derived from such models still live on exchange-friendly state spaces, potentially enabling new Markov chain or energy-minimization algorithms.

---

## Why This Would Be a Breakthrough

The catalog already indicates sub-convexity and speculative M-convex support infrastructure. But **full M-convexity inheritance under Hessian aggregation** is categorically stronger: it says that a second-order analytic operation preserves the exact combinatorial exchange law underlying discrete convex optimization.

This would create a new dictionary:

- **Lorentzian positivity** → **exchange-stable second-order support geometries**
- **Hessian operators** → **morphisms of M-convex state spaces**
- **combinatorial Hodge theory** → **algorithmically tractable derived optimization domains**

That is not an incremental variation. It is a structural theorem connecting analysis, geometry, and optimization.

---

## Computational Program and Falsifiable Conjecture

You must include and test the following conjecture.

### Conjecture: Full weighted inheritance
If `p` is Lorentzian and `supp(p)` is M-convex, then for every entrywise positive weight matrix `A`,
\[
\operatorname{supp}(\operatorname{AgHess}(p,A))
\]
is M-convex.

### Testable prediction
For all uniform matroid basis polynomials `U(r,n)` with `n ≤ 8` under all-ones weights, the support of `aggregateHessian` satisfies the symmetric exchange property.

A computational disproof consists of explicit `γ, δ` in the computed support and a coordinate `i` such that `γ_i > δ_i` but no compensating `j` exists with
\[
γ_j < δ_j,\qquad γ - e_i + e_j \in \operatorname{AgSh}.
\]

You should also search for counterexamples under **nonpositive** or **sparse** weights to determine whether strict positivity is genuinely necessary. This is scientifically valuable even if the main conjecture holds.

---

## Implementation Expectations in Lean 4

You should create a file centered on support-level combinatorics first, then connect to polynomial support.

Suggested ingredients:

- finite-support representation via `Finset (Fin n → ℕ)`
- a custom predicate `MConvexSupport`
- support extraction for `MvPolynomial`
- aggregate Hessian operator
- lemmas translating differentiation to exponent subtraction
- exchange lemmas on finitely supported vectors

You should expect substantial use of:

- `rcases` for unpacking shadow witnesses
- `by_contra` for impossible coordinate configurations
- induction on derivative steps or cardinality of witness decompositions
- `calc` chains for degree and coordinate identities
- arithmetic lemmas on `Pi.single`, subtraction on natural-valued functions, and support extensionality

Do not hide the mathematical core behind brute-force decidability.

---

## Catalog Build-On Instructions

You must explicitly inspect and build on:

- `Pythagorean/LorentzianAggregateAntiCancel.lean`  
  Use this to control when aggregated second derivatives have support exactly equal to the expected combinatorial shadow, rather than a subset caused by cancellation.

- `Catalog/Speculative/AutoResearch/LorentzianMConvex.lean`  
  Use this for the existing relationship between Lorentzian support and M-convexity, so your new theorem composes into a polynomial-level inheritance principle.

If the exact theorem names differ, locate the strongest vetted analogues and cite them in comments near the final theorem statements.

---

## Application Keywords

**Application keywords:** M-convex optimization, discrete Hessians, Lorentzian polynomials, combinatorial Hodge theory, matroid basis generating polynomials, tropical Newton polytopes, exchange axioms, negative dependence, polynomial-time optimization, valuated matroids, discrete Legendre geometry, partition functions.

---

## Mandatory Deliverables

You must produce **all** of the following:

1. **Lean file(s)** with at least 3 nontrivial proved theorems, including the support-level inheritance theorem and at least one polynomial-level corollary.
2. **A verified algorithm or computational method** for checking the symmetric exchange property of aggregate shadows on finite examples.
3. **`demo.py`** that interactively:
   - constructs `U(r,n)` for small `n`,
   - computes the aggregate shadow under chosen weights,
   - checks the symmetric exchange property,
   - reports any counterexample witnesses.
4. **`RESEARCH_PAPER.md`** as a standalone scientific paper explaining the theorem, proof ideas, significance, limitations, and next questions.
5. **`ARTICLE.md`** in Scientific American style, accessible and idea-focused; do **not** emphasize formal verification machinery.
6. **`FUTURE_DIRECTIONS.md`** with 3–5 original research directions. Each direction must include:
   - a sentence beginning **“The key insight is...”**
   - a sentence beginning **“Why now?”**
   At least one direction must bridge to a different domain, such as statistical physics, tropical geometry, or algorithmic game theory.

---

## Success Criterion

A successful outcome is not “some evidence” or “more sub-convexity.” A successful outcome is a precise formal theorem showing that the **aggregate Hessian shadow is M-convex**, first in a clean combinatorial model and then, as far as possible, for Lorentzian polynomial supports via anti-cancellation and support exactness.

If the full theorem fails, pivot boldly: isolate the sharpest true hypothesis, produce a counterexample under weakened assumptions, and formalize the exact boundary of validity. That boundary itself would be a publishable structural discovery.

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
