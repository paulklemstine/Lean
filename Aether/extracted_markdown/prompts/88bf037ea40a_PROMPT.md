## Assignment: Direction 1: Universal M-Convex Compression Theorem

Prove a genuinely new theorem package showing that Lorentzian-recognition complexity is controlled not merely by matroidal supports, but by the full discrete-convex geometry of M-convex sets. The ambition is to turn discrete convex analysis into the universal compression language for derivative trees of homogeneous polynomials with nonnegative coefficients.

This is not an incremental generalization. If successful, it would identify a structural reason that Lorentzian certification remains sparse under repeated differentiation: the combinatorics of surviving quadratic leaves is already encoded in the M-convex shadow geometry of the Newton support. That would unify matroid basis generating polynomials, flow-type supports, valuated exchange systems, and tropical shadow operators under one theorem schema.

Build explicitly on:

- `Catalog/Pythagorean/MatroidBasisLeafCompression.lean`
  - theorem: `derivative_nonzero_iff_dominated_support`
- `Catalog/Speculative/AutoResearch/LorentzianMConvex.lean`
  - definition/theory around: `IsMConvexExchangeNat`

Minimize sorry. Do not settle for finite-case enumeration. Produce structural proofs.

## Core Mathematical Objective

Let `p : MvPolynomial (Fin n) ℝ` be homogeneous of degree `r`, with all coefficients nonnegative, and let `S ⊆ (Fin n →₀ ℕ)` be its Newton support. Assume `S` is M-convex in the sense of discrete convex analysis. Define the `(r-2)`-shadow of `S` by all exponent vectors obtainable from support elements by subtracting a total of `2` through admissible coordinatewise domination, and refine this to the **exchange-visible shadow** consisting of those `α` for which the second derivative fiber above `α` is nonempty and exchange-rigid enough to prevent coefficient cancellation.

The breakthrough target is:

> **Universal M-Convex Compression Theorem.**
> For every homogeneous polynomial `p` with nonnegative coefficients and M-convex Newton support `S`, the number of nonzero quadratic leaves in the full derivative recognition tree of `p` is exactly the cardinality of the exchange-visible `(r-2)`-shadow of `S`. Under a suitable injectivity/no-collision criterion implied by M-convex exchange, this equals the ordinary `(r-2)`-shadow cardinality.

This should recover the matroid basis case as a corollary and then go beyond it to non-matroidal M-convex supports such as integer flow families.

## Precise Formalization Targets

You should introduce at least one genuinely new definition, and preferably a small API around it. Suggested definitions:

- `MConvexShadow`
- `QuadraticLeafFiber`
- `NoCancellationOnFiber`
- `ExchangeVisibleShadow`

A plausible Lean 4 theorem spine is:

```lean
def NewtonSupport (p : MvPolynomial (Fin n) ℝ) : Finset (Fin n →₀ ℕ) := ...

def MConvexShadow
    (S : Finset (Fin n →₀ ℕ)) (k : ℕ) : Finset (Fin n →₀ ℕ) := ...

def QuadraticLeafFiber
    (S : Finset (Fin n →₀ ℕ)) (α : Fin n →₀ ℕ) :
    Finset (Fin n →₀ ℕ) := ...

def NoCancellationOnFiber
    (p : MvPolynomial (Fin n) ℝ) (α : Fin n →₀ ℕ) : Prop := ...

def ExchangeVisibleShadow
    (p : MvPolynomial (Fin n) ℝ) (S : Finset (Fin n →₀ ℕ)) :
    Finset (Fin n →₀ ℕ) := ...

theorem quadratic_leaf_nonzero_iff_mem_exchangeVisibleShadow
    {n r : ℕ} (p : MvPolynomial (Fin n) ℝ)
    (hp_hom : p.IsHomogeneous r)
    (hp_nonneg : ∀ d, 0 ≤ p.coeff d)
    (hS : IsMConvexExchangeNat (NewtonSupport p))
    {α : Fin n →₀ ℕ}
    (hdeg : α.sum (fun _ m => m) = r - 2) :
    coeff α (iteratedDerivativeToQuadratic p α) ≠ 0 ↔
      α ∈ ExchangeVisibleShadow p (NewtonSupport p) := ...
```

A stronger counting theorem should be stated as:

```lean
theorem card_nonzero_quadratic_leaves_eq_card_exchangeVisibleShadow
    {n r : ℕ} (p : MvPolynomial (Fin n) ℝ)
    (hp_hom : p.IsHomogeneous r)
    (hp_nonneg : ∀ d, 0 ≤ p.coeff d)
    (hS : IsMConvexExchangeNat (NewtonSupport p)) :
    quadraticLeafCount p =
      (ExchangeVisibleShadow p (NewtonSupport p)).card := ...
```

And the aspirational compression theorem, under a structural no-cancellation hypothesis derived from M-convexity, should be:

```lean
theorem card_nonzero_quadratic_leaves_eq_card_shadow
    {n r : ℕ} (p : MvPolynomial (Fin n) ℝ)
    (hp_hom : p.IsHomogeneous r)
    (hp_nonneg : ∀ d, 0 ≤ p.coeff d)
    (hS : IsMConvexExchangeNat (NewtonSupport p))
    (hinj : ∀ α, α ∈ MConvexShadow (NewtonSupport p) (r - 2) →
      NoCancellationOnFiber p α) :
    quadraticLeafCount p =
      (MConvexShadow (NewtonSupport p) (r - 2)).card := ...
```

You should also isolate a theorem that derives `NoCancellationOnFiber` from a purely combinatorial exchange property stronger than raw M-convexity. That theorem is scientifically important because it identifies the exact boundary between universal compression and failure by coefficient collision.

## Minimum Theorem Package

Your Lean development must contain at least 3 substantial theorems with nontrivial proofs. Recommended set:

1. **Shadow-membership / derivative-survival theorem**  
   Generalize `derivative_nonzero_iff_dominated_support` from matroid bases to M-convex supports.

2. **Fiber injectivity / no-cancellation theorem**  
   Show that under a suitable exchange-separation hypothesis, distinct support elements cannot contribute canceling terms to the same quadratic leaf.

3. **Counting compression theorem**  
   Deduce exact equality between quadratic leaf count and shadow cardinality.

4. **Cross-domain theorem**  
   Instantiate the theory for a non-matroidal M-convex family, e.g. feasible integer flows on a fixed network, or a tropical/valuated specialization.

At least one theorem must explicitly connect to a different domain.

## Suggested New Definitions

You are required to define at least one novel concept. The most promising is:

> **Exchange-visible shadow**: the set of degree-`r-2` exponent vectors `α` such that there exists `β ∈ S` with `α ≤ β`, `|β|-|α|=2`, and the derivative fiber above `α` is collision-free in the sense that distinct `β` do not produce cancellation after differentiation.

This is not just a technical patch. It is the right invariant if the universal theorem is true only after refining the naive shadow by algebraic visibility. If later you prove M-convexity implies visibility, then the refined definition collapses to the ordinary shadow and the theory becomes even stronger.

A second possible new notion:

> **Exchange-separation**: an M-convex support property asserting uniqueness of the unordered pair of removed coordinates from any support element descending to a fixed quadratic leaf.

This may be the exact combinatorial condition that kills cancellation.

## Proof Strategy Architecture

### Strategy A: Support-fiber analysis via coefficient positivity
Most promising for the first pass.

1. **Describe the derivative fiber explicitly.**  
   For fixed `α` of degree `r-2`, characterize all `β` in the support with `α ≤ β` and `|β - α| = 2`. Show the coefficient of the quadratic leaf is a finite sum over this fiber with explicit multinomial weights.

2. **Exploit nonnegativity to eliminate true cancellation.**  
   Since coefficients are nonnegative and differential multiplicities are positive, cancellation in the literal sign sense cannot occur over `ℝ≥0` coefficients. The actual issue is collision of contributions to the same monomial basis element. Prove that nonzeroness reduces to existence of at least one fiber element, then identify exactly when distinct fiber elements merge.

3. **Use M-convex exchange to control merging.**  
   Show exchange implies enough local connectedness/uniformity that every shadow point has a realizable derivative path, and under exchange-separation the path is unique up to a harmless symmetry.

Why this is promising: it converts the problem into a positive-combinatorial one and uses M-convexity where it is strongest—navigating between nearby exponent vectors by unit exchanges.

### Strategy B: Polarization to multiaffine space, then compress back
Conceptually powerful and likely field-opening.

1. **Polarize the polynomial.**  
   Replace exponents by cloned variables to obtain a multiaffine polynomial whose support is matroid-like in a larger ambient space.

2. **Apply matroid-style leaf compression upstairs.**  
   Use the catalog theorem `derivative_nonzero_iff_dominated_support` on the polarized support or an induced basis system.

3. **Push the result back down.**  
   Prove that quotienting by clone symmetry identifies the quadratic leaves with M-convex shadows downstairs, with multiplicities exactly accounting for non-multiaffine collisions.

Why this is exciting: if it works, polarization becomes a universal bridge from M-convex analysis to Lorentzian certification. This would connect discrete convexity, polarization theory, and Hodge-style combinatorics.

### Strategy C: Tropicalization / valuated support approach
Best for the cross-domain theorem and conjectural follow-up.

1. **Associate a valuated support or tropical Newton complex** to `p`.
2. **Interpret shadow membership tropically** as a codimension-2 face visibility condition.
3. **Relate quadratic leaf count to tropical cells** surviving under truncation.

Why this matters: it would place Lorentzian complexity inside tropical geometry and suggest robust algorithms based on polyhedral computation rather than symbolic differentiation.

## Key Technical Insight to Exploit

Because coefficients are assumed nonnegative, the feared “cancellation” is subtler than sign cancellation. The real obstruction is **many-to-one collapse of derivative ancestry**: several support exponents may descend to the same quadratic monomial after differentiation. Therefore the theorem should be framed in terms of:

- existence of an ancestral support point,
- positivity of the induced weight,
- and uniqueness or controlled multiplicity of the ancestral fiber.

This reframes the problem from algebraic cancellation to combinatorial compression. That is exactly where M-convex exchange should intervene.

## Cross-Domain Connections

You must include at least one theorem or construction bridging to another domain. Strong options:

### 1. Discrete optimization: flow polytopes
Model a family of feasible integer flows with fixed divergence. Their lattice points often form M-convex sets. Prove that the derivative shadow operator on the corresponding generating polynomial matches a combinatorial edge-removal or rerouting operator on flows.

Possible theorem shape:
```lean
theorem flow_support_is_mconvex ...
theorem quadratic_leaf_count_flow_poly_eq_shadow_card ...
```

This would connect Lorentzian certification to network optimization and opens algorithmic applications.

### 2. Tropical geometry: valuated matroids / tropical shadows
Define a tropical shadow on exponent vectors and show compatibility with ordinary shadow after forgetting valuations. This would suggest a “tropical certificate complexity” invariant.

### 3. Algebraic combinatorics: Schur-positive or log-concavity phenomena
Investigate whether M-convex compression preserves a symmetric-function positivity statistic or a Lorentzian/Hodge-type inequality.

### 4. Statistical physics / partition functions
Interpret `p` as a partition function with occupancy vectors in an exchange system. Quadratic leaves then correspond to two-particle fluctuations after conditioning. A theorem here would connect discrete convexity to correlation structure.

## Conjecture With Testable Prediction

State and formalize a falsifiable conjecture such as:

> **Conjecture (Exchange-Separation Suffices).**  
> If `S` is M-convex and exchange-separated, then every degree-`r-2` shadow point is exchange-visible, hence
> `quadraticLeafCount p = |MConvexShadow S (r-2)|`
> for every homogeneous polynomial `p` with nonnegative coefficients and Newton support exactly `S`.

Computational test:
- implement `MConvexShadow`,
- implement `QuadraticLeafFiber`,
- generate explicit non-matroidal M-convex supports from small flow networks,
- compare `quadraticLeafCount p` with shadow cardinality,
- search for counterexamples where fiber multiplicity exceeds one.

A disproof would be scientifically valuable: it would reveal that M-convexity alone is insufficient and isolate the missing combinatorial invariant.

## Application Keywords

Lorentzian polynomials; discrete convex analysis; M-convex sets; Newton polytopes; derivative complexity; support compression; flow polytopes; tropical geometry; valuated matroids; partition functions; combinatorial Hodge theory; symbolic differentiation; exact certification; algebraic combinatorics; network optimization.

## Deliverables (ALL MANDATORY)

1. **Lean file(s)** proving the theorem package above, with at least 3 substantial theorems using real proof structure (`induction`, `rcases`, `by_contra`, `field_simp`, multi-step `calc`, etc.). No trivial enumeration-based formalization.
2. **A verified algorithm or computational method** that computes:
   - `NewtonSupport`,
   - `MConvexShadow`,
   - `QuadraticLeafFiber`,
   - and `quadraticLeafCount`,
   and compares them on explicit examples.
3. **`demo.py`** that interactively demonstrates the result on:
   - a matroidal example,
   - a non-matroidal M-convex example (preferably a flow support),
   - and a candidate counterexample search.
4. **`RESEARCH_PAPER.md`** as a standalone scientific paper explaining:
   - the theorem,
   - the new definitions,
   - why M-convex compression is a conceptual breakthrough,
   - examples,
   - limitations,
   - and next questions.
5. **`ARTICLE.md`** in Scientific American style, focusing on the mathematical ideas and significance, not on formal verification.
6. **`FUTURE_DIRECTIONS.md`** with 3–5 original research directions. Each direction must include the exact sentences:
   - “The key insight is ...”
   - “Why now? ...”
   At least one direction must bridge to a different domain.

## Final Standard

Aim for a result that makes the following sentence true:

> “The complexity of Lorentzian recognition is governed not by ad hoc derivative trees, but by the exchange geometry of discrete convex supports.”

That is the level of theorem this assignment demands.

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
