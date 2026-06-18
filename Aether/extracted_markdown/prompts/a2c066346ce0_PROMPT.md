Soli Deo Gloria

## Assignment: Direction 3: Support Rigidity Lower Bounds for Structured Arithmetic Circuits

**Mode:** `prove`

Prove genuinely new theorems at the interface of **arithmetic circuit complexity**, **Lorentzian/combinatorial Hodge theory**, and **matroid geometry**. Build explicitly on the support exactness / anti-cancellation infrastructure from:

- `Pythagorean/LorentzianAggregateAntiCancel.lean`
- `Catalog/Bridges/Catalog/Speculative/AutoResearch/AntiCancellationLorentzian.lean`

The goal is not a small variant. The goal is to create a new lower-bound mechanism: **positivity-constrained circuit lower bounds from support rigidity under Hessian-type aggregation**.

---

## Central Vision

The breakthrough target is to show that **positive second-order aggregation cannot compress combinatorial support** for structured multilinear polynomials, and therefore any depth-3 arithmetic circuit with nonnegative intermediate polynomials must pay for that support explicitly in multiplication complexity.

If achieved, this would be one of the first formal bridges from **Lorentzian/Hodge-theoretic structure** to **arithmetic circuit lower bounds**, even in a restricted monotone/nonnegative regime. That is already scientifically significant: it reframes complexity lower bounds as a problem in **geometric support monotonicity** rather than cancellation analysis.

This is not merely about one family of polynomials. It opens a program:
- lower bounds from Hessian shadows,
- monotone complexity via geometric support invariants,
- matroid basis polynomials as canonical hard instances,
- a possible new route toward restricted forms of **VP vs VNP**.

---

## Precise Theorem Targets

You must formalize at least **3 substantial theorems**, with multi-step proofs using induction, `rcases`, `by_contra`, `field_simp`, or serious `calc` chains. Avoid trivial automation.

You should introduce at least one **new definition** not already present in the catalog. Suggested new notions:

- `shadow` of a support under positive Hessian aggregation,
- `supportRigidity` for a polynomial family,
- `depthThreeNonnegCost` as a formal lower-bound surrogate,
- `graphicBasisPoly` or a simplified structured polynomial family encoding graphic matroid bases / spanning trees.

---

## Core New Definitions to Introduce

You should define a finite-support polynomial model appropriate for Lean and then define:

1. **Positive Hessian shadow size**
   - the set of monomials reachable from a polynomial support by allowed positive second-order aggregation operations;
   - or a simplified combinatorial abstraction sufficient to prove lower bounds.

2. **Support rigidity**
   - a polynomial is support-rigid at scale `k` if every admissible positive Hessian operator produces support/shadow size at least `k`.

3. **Depth-3 nonnegative multiplication cost surrogate**
   - a formal combinatorial lower-bound notion capturing the minimum number of multiplicative components needed to cover/support-generate the polynomial under positivity constraints.

You are free to use a mathematically faithful abstraction rather than a full semantic circuit formalization, provided the theorem clearly implies a genuine lower bound statement.

---

## Exact Theorem Statements to Target

### Theorem 1: Anti-cancellation implies shadow lower bounds

Formalize a theorem of the following shape:

> For any multilinear polynomial `p` with nonnegative coefficients satisfying the catalog anti-cancellation/support-exactness hypotheses, every positive Hessian aggregation operator `H` has output support cardinality at least the cardinality of a combinatorially defined shadow of `supp(p)`.

Suggested Lean 4 type signature schematic:

```lean
theorem support_card_ge_shadow_card
    {σ : Type} [Fintype σ] [DecidableEq σ]
    (p : MvPolynomial σ ℝ)
    (hp_nonneg : ∀ d, 0 ≤ p.coeff d)
    (hp_multilinear : IsMultilinear p)
    (H : PositiveHessianOperator σ)
    (h_exact : SupportExactUnder H p) :
    Fintype.card (supportOf (H.eval p)) ≥
      Fintype.card (shadowSet H (supportOf p)) := by
```

If `MvPolynomial` support cardinality is awkward, use `Finset` cardinalities:

```lean
theorem support_finset_card_ge_shadow
    {σ : Type} [Fintype σ] [DecidableEq σ]
    (p : MvPolynomial σ ℝ)
    (hp_nonneg : ∀ d, 0 ≤ p.coeff d)
    (hp_multilinear : IsMultilinear p)
    (H : PositiveHessianOperator σ)
    (h_exact : SupportExactUnder H p) :
    (supportFinset (H.eval p)).card ≥
      (shadowFinset H (supportFinset p)).card := by
```

**Why this matters:** this is the support-rigidity engine. It turns anti-cancellation from a structural statement into a quantitative lower-bound tool.

---

### Theorem 2: Graphic/matroid family has quadratic shadow growth

Choose an explicit family. The most ambitious is a graphic matroid basis polynomial; a more Lean-realistic fallback is a combinatorial polynomial whose support is indexed by spanning trees, forests, or 2-edge patterns in a graph family where shadow growth can be counted exactly.

Target statement:

> For the chosen graph family `G_n`, the associated structured multilinear polynomial `p_n` has support shadow size at least `c * n^2` under every positive Hessian operator in the admissible class.

Suggested Lean 4 signature schematic:

```lean
theorem graphic_family_shadow_quadratic
    (n : ℕ) (hn : 2 ≤ n)
    (H : PositiveHessianOperator (EdgeVar n))
    (hH : AdmissibleOnGraphicFamily H n) :
    ∃ c : ℕ, 0 < c ∧
      c * n^2 ≤ (shadowFinset H (supportFinset (graphicBasisPoly n))).card := by
```

Or, if constant extraction is too awkward, use a concrete lower bound:

```lean
theorem graphic_family_shadow_lower_bound
    (n : ℕ) (hn : 4 ≤ n)
    (H : PositiveHessianOperator (EdgeVar n))
    (hH : AdmissibleOnGraphicFamily H n) :
    n^2 ≤ (shadowFinset H (supportFinset (graphicBasisPoly n))).card := by
```

If full graphic matroids are too heavy, use a surrogate family with a clear combinatorial shadow-counting argument and explicitly state that it models the intended matroid mechanism.

**Why this matters:** this is the first place where combinatorial Hodge positivity becomes a quantitative complexity invariant.

---

### Theorem 3: Depth-3 nonnegative lower bound from support rigidity

Target a theorem reducing circuit size to shadow size.

> Any depth-3 arithmetic circuit with nonnegative intermediate polynomials computing `p_n` requires at least as many multiplication gates as the minimum support-rigidity lower bound divided by the maximum shadow contribution per multiplication gate.

Suggested Lean 4 signature schematic:

```lean
theorem depth3_nonneg_cost_ge_shadow_ratio
    {σ : Type} [Fintype σ] [DecidableEq σ]
    (p : MvPolynomial σ ℝ)
    (hp_nonneg : ∀ d, 0 ≤ p.coeff d)
    (hp_multilinear : IsMultilinear p) :
    depthThreeNonnegCost p ≥
      supportRigidityBound p / maxShadowPerProduct p := by
```

Then specialize:

```lean
theorem graphic_family_depth3_quadratic_lower_bound
    (n : ℕ) (hn : 4 ≤ n) :
    depthThreeNonnegCost (graphicBasisPoly n) ≥ n^2 / C := by
```

for some explicit constant `C`, or simply

```lean
theorem graphic_family_depth3_linear_times_n_lower_bound
    (n : ℕ) (hn : 4 ≤ n) :
    n^2 ≤ C * depthThreeNonnegCost (graphicBasisPoly n) := by
```

**Why this matters:** this is the complexity-theoretic payoff. It translates geometric support rigidity into arithmetic circuit lower bounds.

---

## Most Promising Proof Architecture

### Strategy A: Direct support transport from anti-cancellation to circuit lower bounds
This is the most promising route.

1. **Abstract positive Hessian operators combinatorially.**  
   Define an operator class whose action on support is explicit enough to count, but broad enough to be justified by the catalog anti-cancellation theorem.

2. **Use support exactness as a no-collapse principle.**  
   From the catalog theorem, deduce that admissible positive aggregation cannot merge away monomials below a shadow lower bound.

3. **Prove a covering lemma for depth-3 products.**  
   Show each multiplication gate contributes only a bounded amount to the admissible shadow geometry. Then total circuit cost is bounded below by total required shadow size.

Why this is best: it converts existing catalog theorems almost directly into complexity lower bounds with minimal dependence on heavy external algebraic geometry.

---

### Strategy B: Matroid basis exchange + Hessian reachability
This is the most conceptually deep route.

1. Model support monomials as bases of a matroid / spanning trees of a graph family.
2. Show positive Hessian moves correspond to basis exchanges, edge swaps, or local adjacency in the basis graph.
3. Prove the reachable shadow contains a large ball / large exchange neighborhood, whose size is `Ω(n^2)` by combinatorial counting.

Why it is powerful: it reveals the **combinatorial Hodge origin** of hardness.  
Why it is harder: formalizing graphic matroids and basis exchange may be substantial unless the catalog already contains enough infrastructure.

---

### Strategy C: Newton polytope / convex-geometric surrogate
A useful fallback if support-level exactness is easier to lift geometrically than combinatorially.

1. Associate support to a Newton polytope or a discrete convex body.
2. Show positive Hessian aggregation preserves a large face/edge neighborhood or mixed-volume shadow.
3. Derive support lower bounds from lattice-point counting.

Why it is interesting: this connects arithmetic complexity to discrete convex geometry and could generalize beyond matroids.  
Why it is less immediate: support cardinality from polytope volume often needs nontrivial lattice estimates.

---

## Recommended Execution Order

1. **Formalize the new support-shadow abstraction** independent of circuits.
2. **Prove support lower bounds from anti-cancellation** in maximal generality.
3. **Instantiate on one explicit polynomial family** with a clean counting proof.
4. **Define a depth-3 nonnegative cost surrogate** and prove a lower bound theorem.
5. **Only then** upgrade language from surrogate to genuine restricted arithmetic circuits if the infrastructure allows.

This order maximizes the chance of landing a real theorem even if full circuit semantics become heavy.

---

## Surrounding Mathematical Context

The key insight is that **support rigidity under Hessian aggregation is a monotone invariant of positivity-constrained computation**. In ordinary arithmetic complexity, lower bounds are obstructed by cancellation. But in the nonnegative/Lorentzian regime, cancellation is forbidden, and Hodge-theoretic structure may force support to remain visible. That visibility can be counted.

This is a new worldview:

- complexity lower bounds from **support geometry**,
- support geometry from **Lorentzian anti-cancellation**,
- Lorentzian anti-cancellation from **combinatorial Hodge theory**.

That triangle is scientifically fresh.

---

## Cross-Domain Connections You Must Include

You must include at least one theorem and discussion connecting this program to another domain. Good options:

### 1. Complexity ↔ Statistical physics
Interpret support as a partition-function state space and positive Hessian aggregation as a response/susceptibility operator. Then support rigidity resembles the persistence of a large phase-space shell.

Possible theorem direction:
- show that for a class of ferromagnetic partition polynomials, positive response operators preserve a large combinatorial support shadow.

### 2. Complexity ↔ Discrete convex geometry
Relate support shadows to Newton polytopes, M-convexity, or basis exchange polytopes.

Possible theorem direction:
- prove that support-rigid families have Newton polytopes with large edge neighborhoods, yielding shadow lower bounds.

### 3. Complexity ↔ Information theory
View support size as a zero-temperature entropy. Positive Hessian aggregation cannot collapse entropy below a shadow threshold.

Possible theorem direction:
- define a combinatorial entropy from support cardinality and show monotonic lower bounds under admissible operators.

At least one such bridge theorem or formal proposition should appear in the Lean development.

---

## Suggested New Definitions / Lean Targets

You may introduce structures like:

```lean
structure PositiveHessianOperator (σ : Type) [DecidableEq σ] where
  eval : MvPolynomial σ ℝ → MvPolynomial σ ℝ
  preservesNonneg : ∀ p, (∀ d, 0 ≤ p.coeff d) → ∀ d, 0 ≤ (eval p).coeff d
  supportMonotone : ∀ p, shadowFinset ⟨eval, ...⟩ (supportFinset p) ⊆ supportFinset (eval p)
```

```lean
def supportRigidityBound {σ : Type} [Fintype σ] [DecidableEq σ]
    (p : MvPolynomial σ ℝ) : ℕ :=
  sInf {k | ∀ H : PositiveHessianOperator σ, admissible H p →
    k ≤ (shadowFinset H (supportFinset p)).card}
```

```lean
def depthThreeNonnegCost {σ : Type} [Fintype σ] [DecidableEq σ]
    (p : MvPolynomial σ ℝ) : ℕ := ...
```

If full `sInf` over naturals is cumbersome, define the property relationally rather than numerically.

---

## Concrete Proof Ingredients to Reuse from Catalog

Use the catalog theorems not by name-dropping but by extracting exact leverage:

- From `LorentzianAggregateAntiCancel.lean`, use the theorem asserting that under admissible positive aggregation, support is **exactly** preserved or bounded below by the combinatorial anti-cancellation shadow.  
  Your job is to turn this into a **cardinality lower bound**.

- From `AntiCancellationLorentzian.lean`, extract any certified statement that positivity prevents support collapse under aggregate Hessian operators.  
  Use this as the key lemma in the transition:
  `structural positivity theorem → support shadow theorem → counting theorem → complexity lower bound`.

Do not merely restate catalog results. Push them into a new domain: arithmetic complexity.

---

## Explicit Conjecture with Testable Prediction

State and formalize a falsifiable conjecture such as:

> **Conjecture (Graphic Hessian Rigidity).**  
> For the graphic basis polynomial `p_n` of the complete graph `K_n`, every admissible positive Hessian operator has shadow size at least `c n^2` for some absolute constant `c > 0`.

Suggested Lean skeleton:

```lean
conjecture graphic_hessian_rigidity
    (n : ℕ) (hn : 4 ≤ n) :
    ∃ c : ℕ, 0 < c ∧
      ∀ H : PositiveHessianOperator (EdgeVar n),
        AdmissibleOnGraphicFamily H n →
        c * n^2 ≤ (shadowFinset H (supportFinset (graphicBasisPoly n))).card
```

### Computational falsification test
For `n ≤ 20`:
1. generate the chosen polynomial family,
2. enumerate or sample admissible positive weight/Hessian matrices,
3. compute the induced shadow size,
4. search for subquadratic shadows.

A single counterexample with shadow `o(n^2)` falsifies the conjecture.

---

## Required Verified Algorithm / Computational Method

You must deliver a verified algorithm, not just theorems.

### Minimum required algorithm
A certified procedure that:
- constructs the support of the chosen polynomial family,
- computes its positive Hessian shadow under a given admissible operator,
- returns the shadow cardinality together with correctness lemmas.

Possible theorem:

```lean
theorem shadowAlgorithm_correct
    {σ : Type} [Fintype σ] [DecidableEq σ]
    (H : PositiveHessianOperator σ)
    (p : MvPolynomial σ ℝ) :
    shadowAlgorithm H p = (shadowFinset H (supportFinset p)).card := by
```

Then use this algorithm in `demo.py` to explore the conjecture computationally.

---

## Demo Requirements

Produce `demo.py` that:
- allows the user to choose `n`,
- constructs the structured polynomial family,
- samples admissible positive operators,
- computes shadow sizes,
- plots observed growth versus `n^2`,
- highlights whether data supports the rigidity conjecture.

This should feel like an experimental mathematics instrument, not a toy script.

---

## Deliverables (ALL MANDATORY)

You must produce all of the following:

### 1. `FUTURE_DIRECTIONS.md`
Include **3–5 original research directions**, each with:
- a title,
- **“The key insight is...”**
- **“Why now?”**
- a concrete theorem or conjecture target,
- at least one direction bridging to a different field.

Possible future directions:
- tropical analogues of support rigidity,
- entropy lower bounds for partition polynomials,
- Newton-polytope hardness measures for monotone circuits,
- Hodge-theoretic barriers for tensor rank.

### 2. `RESEARCH_PAPER.md`
A standalone scientific paper that explains:
- the problem,
- the new definitions,
- the main theorems,
- proof ideas,
- why the result matters for complexity theory,
- limitations,
- next conjectures.

A reader with no access to the code must still understand the discovery.

### 3. `ARTICLE.md`
Write in **Scientific American** style:
- vivid and concept-driven,
- accessible to a broad scientific audience,
- focused on the ideas and significance,
- **do not focus on formal verification machinery**.

Frame it as a surprising new alliance between geometry and computation.

### 4. Verified algorithm / computational method
As above: shadow computation, correctness proof, and complexity discussion.

### 5. `demo.py`
Interactive or semi-interactive demonstration of the conjecture and the proven bounds.

---

## Application Keywords

Arithmetic circuit complexity; monotone lower bounds; depth-3 circuits; multilinear polynomials; Lorentzian polynomials; combinatorial Hodge theory; anti-cancellation; support rigidity; Hessian shadow; graphic matroids; basis generating polynomials; Newton polytopes; discrete convexity; partition functions; statistical physics; zero-temperature entropy; VP vs VNP; symbolic computation; experimental mathematics.

---

## Nontriviality Requirements (MANDATORY)

Your output must satisfy all of these:

1. **NO trivial proofs**: do not prove statements by `native_decide`, `decide`, `norm_num`, or `rfl` unless the statement itself is genuinely mathematically important.

2. **At least 3 substantial theorems** with deep proof tactics:
   - induction,
   - `rcases`,
   - `by_contra`,
   - `field_simp`,
   - multi-step `calc`,
   - nontrivial cardinality/counting arguments.

3. **Novel definitions**:
   - at least one new mathematical structure/concept absent from the catalog.

4. **Cross-domain connection**:
   - at least one theorem connecting complexity to another domain.

5. **Conjecture with computational test**:
   - explicit falsifiable statement and a procedure that could disprove it.

---

## Final Charge

Do not settle for a formalized curiosity. Build a new lower-bound technology.

The key insight is that **support rigidity under positive Hessian aggregation is a monotone geometric obstruction to efficient positive computation**. If you can make that precise, you will have created a new language for arithmetic lower bounds—one grounded not in cancellation, but in the geometry of what positivity cannot hide.

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
