Soli Deo Gloria

## Assignment: Direction 1: Lorentzian-to-Coefficient Bridge via Bivariate Specialization

Prove a genuinely new bridge theorem between Lorentzian geometry of homogeneous polynomials and higher-order log-concavity of coefficient sequences. This should not be a cosmetic extension of existing catalog results: the goal is to convert recursive Hessian-signature information into an explicit coefficient-inequality engine.

Build directly on:

- `Catalog/Pythagorean/LorentzianRecognitionComplete.lean`
  - especially `IsRecursivelyLorentzian`
  - and any certified recognition lemmas for products of linear forms / structured examples
- `Catalog/Pythagorean/HigherOrderLogConcavity.lean`
  - especially `KFoldLogConcave`
- the formalized reversed Cauchy–Schwarz bridge
  - `lorentzian_reversed_cauchy_schwarz`

Your mission is to establish a theorem schema of the following form:

> recursive Lorentzianity of a homogeneous multivariate polynomial  
> ⇒ Lorentzianity of every positive bivariate specialization / contraction  
> ⇒ ultra/log-concavity inequalities on the resulting coefficient sequence  
> ⇒ iterated inequalities giving `KFoldLogConcave`.

This is a field-opening statement because it would transform Lorentzian recognition from a structural certification tool into an inequality-production mechanism for sequences, matroids, graph polynomials, and statistical-mechanical partition functions. If successful, this opens a new program: **Lorentzian discrete analysis**, where spectral negativity statements in algebraic geometry generate provable higher-order shape constraints on combinatorial data.

## Precise theorem targets

You should define at least one new notion capturing bivariate extraction/specialization from a homogeneous polynomial, and then prove at least 3 substantial theorems around it.

### New definition (mandatory novelty)

Introduce a new concept along the lines of a positive bivariate specialization profile. For example:

- a structure encoding a homogeneous polynomial together with two exponent directions / a specialization map,
- or a definition of the coefficient sequence produced by restricting a multivariate homogeneous polynomial to a 2-variable slice,
- or a predicate asserting that a bivariate specialization is coefficient-positive and degree-preserving.

Possible Lean-facing definitions:

```lean
/-- Coefficients of the bivariate specialization of a homogeneous polynomial
    along a chosen 2-dimensional slice. -/
def bivariateSpecializationCoeffs
  (P : MvPolynomial σ ℝ)
  (u v : σ →₀ ℕ) :
  ℕ → ℝ := ...

/-- A specialization is admissible if it preserves total degree `d`
    and yields strictly positive coefficients. -/
structure AdmissibleBivariateSpecialization
  (P : MvPolynomial σ ℝ) (d : ℕ) where
  u v : σ →₀ ℕ
  homogeneous : ...
  positive_coeff : ∀ m ≤ d, 0 < bivariateSpecializationCoeffs P u v m
  support_range : ∀ m, d < m → bivariateSpecializationCoeffs P u v m = 0
```

If the existing catalog already has nearby notions, refine rather than duplicate—but you must still introduce at least one genuinely new formal concept.

---

## Flagship theorem

### Mathematical statement

Let `P` be a homogeneous polynomial of degree `d` with nonnegative coefficients. Assume `P` is recursively Lorentzian of depth `k`. Let
\[
Q(x,y)=\sum_{m=0}^{d} a_m x^m y^{d-m}
\]
be any admissible bivariate specialization with all `a_m > 0`. Then the coefficient sequence `a : ℕ → ℝ` is `min(k, d-2)`-fold log-concave.

More explicitly: for every `j ≤ min(k, d-2)`, the `j`-th iterated ratio / derived sequence associated to `a` satisfies the relevant concavity inequalities encoded by `KFoldLogConcave`.

This is the exact bridge conjectured in the prompt, and it should be formalized as close to this shape as Mathlib permits.

### Suggested Lean 4 type signature

You may need to adapt names/types to match the actual catalog APIs, but aim for a theorem of this precision:

```lean
theorem recursivelyLorentzian_bivariateSpecialization_kFoldLogConcave
  {σ : Type*} [DecidableEq σ]
  (P : MvPolynomial σ ℝ) (d k : ℕ)
  (hhom : P.IsHomogeneousOfDegree d)
  (hLor : IsRecursivelyLorentzian P k)
  (hspec : AdmissibleBivariateSpecialization P d)
  (hpos : ∀ m ≤ d, 0 < bivariateSpecializationCoeffs P hspec.u hspec.v m) :
  KFoldLogConcave (min k (d - 2))
    (fun m => bivariateSpecializationCoeffs P hspec.u hspec.v m)
```

If `KFoldLogConcave` is stated on finite lists rather than functions `ℕ → ℝ`, prove the function version first and derive the list version, or conversely.

---

## Theorem 2: one-step Lorentzian-to-Newton inequality

Before the full k-fold theorem, isolate the one-step mechanism. This theorem is likely the real engine.

### Mathematical statement

Under the same hypotheses, if `Q(x,y)=∑ a_m x^m y^{d-m}` is a positive bivariate specialization of a Lorentzian homogeneous polynomial of degree `d ≥ 2`, then for every `1 ≤ m ≤ d-1`,
\[
a_m^2 \ge a_{m-1} a_{m+1},
\]
with the stronger weighted form if available:
\[
\frac{a_m^2}{\binom{d}{m}^2}
\ge
\frac{a_{m-1}}{\binom{d}{m-1}}
\frac{a_{m+1}}{\binom{d}{m+1}}.
\]

This is the coefficient-level shadow of the Hessian having at most one positive eigenvalue. It should be explicitly derived from `lorentzian_reversed_cauchy_schwarz` after suitable directional differentiation.

### Suggested Lean signature

```lean
theorem lorentzian_bivariateSpecialization_logConcave
  {σ : Type*} [DecidableEq σ]
  (P : MvPolynomial σ ℝ) (d : ℕ)
  (hhom : P.IsHomogeneousOfDegree d)
  (hLor : IsRecursivelyLorentzian P 1)
  (hspec : AdmissibleBivariateSpecialization P d)
  (hdeg : 2 ≤ d) :
  ∀ m, 1 ≤ m → m + 1 ≤ d →
    bivariateSpecializationCoeffs P hspec.u hspec.v m ^ 2
      ≥
    bivariateSpecializationCoeffs P hspec.u hspec.v (m - 1) *
    bivariateSpecializationCoeffs P hspec.u hspec.v (m + 1)
```

This theorem should require a real proof: use differentiation, coefficient extraction, and the reversed Cauchy–Schwarz inequality in a multi-step `calc`.

---

## Theorem 3: recursive propagation theorem

The core novelty is not just one-step log-concavity, but propagation through recursive Lorentzian depth.

### Mathematical statement

If every admissible derivative of order `r ≤ k` of `P` remains Lorentzian in the recursive sense, then the derived coefficient sequence after `r` ratio-transform / normalized finite-difference transform remains log-concave. Therefore the original coefficient sequence is `k`-fold log-concave up to the degree ceiling `d-2`.

This theorem should explicitly connect one level of recursive Lorentzianity to one level of the `KFoldLogConcave` hierarchy.

### Suggested Lean signature

```lean
theorem recursivelyLorentzian_step_preserves_ratioLogConcavity
  {σ : Type*} [DecidableEq σ]
  (P : MvPolynomial σ ℝ) (d k : ℕ)
  (hhom : P.IsHomogeneousOfDegree d)
  (hLor : IsRecursivelyLorentzian P (k + 1))
  (hspec : AdmissibleBivariateSpecialization P d) :
  KFoldLogConcave k
    (derivedRatioSeq (fun m => bivariateSpecializationCoeffs P hspec.u hspec.v m)) := by
  ...
```

If `derivedRatioSeq` is not in the catalog, define it carefully and prove basic positivity/domain lemmas.

---

## Theorem 4: cross-domain theorem

You must include at least one theorem connecting this program to a different mathematical domain.

### Option A: Graph theory / statistical mechanics

Let `G` be a finite connected graph and `κ_G` its Kirchhoff polynomial. Show that for any positive bivariate specialization obtained by partitioning edge variables into two groups, the resulting coefficient sequence is log-concave; under recursive Lorentzian depth, obtain higher-order log-concavity.

Interpretation: coefficients count spanning trees with prescribed usage profile across the partition, so the theorem yields shape constraints on a graph-enumeration sequence.

Possible Lean target:

```lean
theorem kirchhoff_partition_coeffs_logConcave
  (G : SimpleGraph V) [Fintype V] [DecidableEq V]
  ... :
  KFoldLogConcave r (kirchhoffPartitionCoeffSeq G A B)
```

### Option B: Matroid theory

For the basis generating polynomial of a uniform matroid or another certified Lorentzian matroid polynomial, prove that the coefficients of a rank-profile bivariate specialization are `KFoldLogConcave`.

This creates a direct bridge:
**algebraic geometry ↔ combinatorics of matroids**.

### Option C: Physics / partition functions

For a ferromagnetic multiaffine partition polynomial already known or provably Lorentzian, show that magnetization-sector coefficients along a two-parameter specialization are log-concave. This connects Lorentzian geometry to thermodynamic stability and fluctuation suppression.

Application keywords:
- matroid theory
- graph reliability
- partition functions
- negative dependence
- ultra-log-concavity
- spectral inequalities
- combinatorial Hodge theory
- statistical mechanics

At least one of these cross-domain theorems must be formalized and proved.

---

## Proof architecture: 3 viable strategies

You must not just attack the flagship theorem head-on. Build the bridge in layers.

### Strategy A: Differential reduction + reversed Cauchy–Schwarz + induction on depth
**Most promising.**

1. Define the bivariate specialization coefficients via mixed directional derivatives:
   \[
   a_m \propto \partial_u^m \partial_v^{d-m} P.
   \]
   This turns coefficient inequalities into derivative inequalities.
2. Use `lorentzian_reversed_cauchy_schwarz` on suitable first derivatives / directional contractions to derive the Newton-type inequality
   \[
   a_m^2 \ge a_{m-1} a_{m+1}.
   \]
3. Prove by induction on `k` that recursive Lorentzianity of derivatives yields log-concavity of the transformed sequence at the next level, concluding `KFoldLogConcave`.

Why this is best: it directly exploits the catalog theorem already identified as the algebraic bridge, and recursive Lorentzianity is itself defined by closure under differentiation, so the induction is structurally aligned with the predicate.

### Strategy B: Real-rootedness of the bivariate slice + Newton inequalities
1. Show the bivariate specialization `Q(x,y)` induces a univariate polynomial `q(t)=Q(t,1)` whose coefficients are `a_m`.
2. Derive or import that Lorentzianity of `Q` implies real-rootedness / stability properties of `q`.
3. Apply Newton inequalities, then iterate through recursively Lorentzian derivatives to obtain higher-order log-concavity.

Why this is powerful: if the real-rootedness bridge is available, coefficient inequalities become classical. Why it is riskier: the formalized path from Lorentzianity to real-rootedness may not yet exist in the catalog, so this may require additional infrastructure.

### Strategy C: Alexandrov–Fenchel style mixed-form inequalities
1. Interpret coefficients `a_m` as mixed-form evaluations.
2. Apply Lorentzian/Hodge-type inequalities to mixed terms.
3. Convert these to weighted log-concavity and then to the catalog’s `KFoldLogConcave`.

Why this matters: it could generalize beyond bivariate specializations to higher-dimensional coefficient arrays. Why it is harder: the multilinear formalization burden may be substantial.

Use Strategy A as the primary route. Keep B and C in reserve for stronger corollaries or future directions.

---

## Technical expectations for the proofs

Your file must contain at least 3 theorems with deep proof tactics. Concretely, I expect to see:

- induction on recursive Lorentzian depth `k`,
- `rcases` on specialization data / derivative structure,
- `by_contra` to rule out positivity or support pathologies,
- `field_simp` when normalizing factorial/binomial coefficient identities,
- multi-step `calc` blocks converting derivative expressions to coefficient inequalities.

Do not produce shallow wrappers around existing lemmas. The point is to create new mathematics in the formal ecosystem.

---

## Specific intermediate lemmas to prove

These are not optional if needed by your architecture.

1. **Coefficient extraction lemma**
   Relate the coefficient `a_m` of the bivariate specialization to a mixed derivative evaluation.

   ```lean
   theorem bivariateSpecializationCoeff_eq_mixedDerivative
     ...
   ```

2. **Positivity inheritance lemma**
   Show nonnegative coefficients of `P` imply nonnegativity/positivity of specialization coefficients under admissibility assumptions.

   ```lean
   theorem bivariateSpecializationCoeff_nonneg
     ...
   ```

3. **Derivative-degree compatibility**
   Differentiating a recursively Lorentzian homogeneous polynomial lowers both degree and recursive depth in the expected way.

   ```lean
   theorem recursivelyLorentzian_iteratedDerivative
     ...
   ```

4. **One-step ratio inequality lemma**
   Convert reversed Cauchy–Schwarz into adjacent coefficient log-concavity.

   ```lean
   theorem reversedCS_implies_adjacentCoeff_logConcavity
     ...
   ```

5. **Iteration lemma**
   One level of recursive Lorentzianity implies one level of the `KFoldLogConcave` hierarchy.

   ```lean
   theorem recursivelyLorentzian_implies_next_logConcavity_level
     ...
   ```

These lemmas together form a publishable architecture, not just a single isolated theorem.

---

## Conjecture with testable prediction

State and formalize a falsifiable conjecture extending the theorem beyond the proven range.

### Conjecture
For every homogeneous polynomial `P` with nonnegative coefficients whose every positive bivariate specialization is Lorentzian (even without full recursive Lorentzian depth), the coefficient sequence of every such specialization is infinitely ratio-log-concave until support exhaustion.

This is stronger than the main theorem and very likely false in full generality, which is good: it creates a real scientific frontier.

### Computational test
Implement a search over explicit families:

- products of positive linear forms,
- uniform matroid basis generating polynomials,
- Kirchhoff polynomials of graphs on up to a chosen small number of vertices/edges,
- hand-constructed sparse homogeneous polynomials with positive coefficients.

For each:
1. compute specialization coefficients,
2. compute iterated ratio / derived sequences,
3. test `KFoldLogConcave` numerically up to the maximal admissible depth,
4. report the first counterexample if one exists.

A single recursively shallow but slice-Lorentzian family failing 2-fold log-concavity would refute the conjecture.

---

## Verified algorithm / computational deliverable

You must produce a verified computational method, not just theorem statements.

### Required algorithm
Implement a certified procedure that:

1. accepts an explicit homogeneous polynomial `P`,
2. constructs chosen admissible bivariate specializations,
3. extracts the coefficient sequence,
4. computes iterated transforms relevant to `KFoldLogConcave`,
5. returns either:
   - a proof certificate of `KFoldLogConcave r`, or
   - a concrete violating index.

This should be formalized enough that key correctness properties are proven in Lean, even if the executable portion is partly reflected through computation.

Possible signature:

```lean
def certifyBivariateKFoldLogConcavity
  (P : MvPolynomial σ ℚ) (d r : ℕ)
  (spec : AdmissibleBivariateSpecialization P d) :
  Sum (KFoldLogConcave r (fun m => bivariateSpecializationCoeffs P spec.u spec.v m))
      {m // violationAt r m (fun m => bivariateSpecializationCoeffs P spec.u spec.v m)}
```

Adapt codomain as needed.

---

## demo.py requirements

Produce `demo.py` that interactively demonstrates the discovery.

It should:

- construct sample Lorentzian polynomials:
  - products of positive linear forms,
  - uniform matroid basis generating polynomials,
  - Kirchhoff polynomials of small graphs;
- perform several bivariate specializations;
- print coefficient sequences;
- test ordinary and higher-order log-concavity;
- visualize the sequence and iterated transforms;
- highlight any counterexample to the stronger conjecture.

This is not auxiliary fluff: the computational exploration is part of the research loop.

---

## Cross-domain significance

You must explicitly explain in the paper and article that this project connects:

- **algebraic geometry**: Lorentzian polynomials, Hessian signatures, Hodge-type inequalities;
- **discrete analysis**: log-concavity, ratio sequences, Newton inequalities;
- **combinatorics**: matroids, spanning trees, partition enumerators;
- **physics/statistical mechanics**: sector coefficients of partition polynomials, negative dependence, fluctuation constraints.

This is what makes the theorem revolutionary: it says a spectral-geometric condition on a polynomial controls the shape of observable counting sequences after coarse-graining to two variables.

---

## Application keywords

Use and discuss these explicitly:

- Lorentzian polynomials
- recursive Lorentzian depth
- higher-order log-concavity
- ultra-log-concavity
- Newton inequalities
- combinatorial Hodge theory
- matroid generating polynomials
- Kirchhoff polynomial
- spanning tree profile
- negative dependence
- partition function coefficients
- real-rootedness heuristics
- Alexandrov–Fenchel inequalities
- spectral signature to discrete inequality transfer

---

## Deliverables (ALL mandatory)

You must produce all of the following:

1. **Lean file(s)** with the new definitions and at least 3 substantial proved theorems as above, using deep proof tactics and minimizing `sorry`.
2. **`FUTURE_DIRECTIONS.md`** with 3–5 original research directions. Each direction must include:
   - a sentence beginning exactly with **“The key insight is...”**
   - a sentence beginning exactly with **“Why now?”**
   At least one direction must bridge to a different domain.
3. **`RESEARCH_PAPER.md`** as a standalone scientific paper. A reader with no access to the code must understand:
   - the precise theorem,
   - the proof architecture,
   - why it matters,
   - computational evidence,
   - and what comes next.
4. **`ARTICLE.md`** in Scientific American style, engaging and broadly accessible.
   **Taboo:** do **not** focus on formal verification machinery; focus on the mathematics and significance.
5. **A verified algorithm or computational method** certifying or refuting `KFoldLogConcave` for bivariate specializations.
6. **`demo.py`** demonstrating the theorem and the stronger conjecture experimentally.

---

## Final standard

Do not settle for “some inequalities about coefficients.” The target is a new theorem-schema:

\[
\text{recursive Lorentzian geometry}
\Longrightarrow
\text{iterated coefficient concavity}
\Longrightarrow
\text{shape laws for combinatorial and physical counting sequences}.
\]

If you can make this bridge precise in Lean, you will have created a new artery between combinatorial Hodge theory and discrete inequality theory.

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
