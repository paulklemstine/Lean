Soli Deo Gloria

## Assignment: Direction 1: Shadow Inequalities for Lorentzian Polynomials

**Mode:** `prove`

Prove genuinely new, non-trivial theorems at the interface of Lorentzian polynomials, combinatorial shadow operators, and ultra log-concavity of support profiles. Build directly on the catalog transport lemmas for iterated partial derivatives and weighted shadows. Minimize sorry. The goal is not to repackage known Hodge-theoretic log-concavity, but to extract a new **support-level shadow theory** from coefficient-level Lorentzian structure.

## Central Vision

Lorentzian polynomials encode deep negative dependence and Hodge-theoretic convexity at the coefficient level. Your task is to show that this rigidity survives a drastic coarse-graining: passing from coefficients to the mere **shape of the support**. If true, this would reveal a new principle:

> **Lorentzianity forces combinatorial regularity of support shadows.**

That is a field-opening statement. It would create a bridge from algebraic geometry and matroid Hodge theory to extremal set theory, discrete convexity, and algorithmic certification.

The conceptual breakthrough is to prove that **shadow log-concavity descends from coefficient log-concavity through the coefficient transport law for iterated derivatives**. This would supply an elementary combinatorial shadow machine for a class of objects previously controlled only through much heavier geometry.

---

## Primary Theorem Target

Let \(f = \sum_{\alpha \in \mathbb{N}^n, |\alpha| = d} c_\alpha X^\alpha\) be a homogeneous polynomial with nonnegative coefficients. Write
\[
S := \operatorname{supp}(f) = \{\alpha : c_\alpha \neq 0\}.
\]
For \(k \le d\), define the \(k\)-th shadow profile
\[
\Sh_k(S) := \{\beta \in \mathbb{N}^n : |\beta| = d-k,\ \exists \alpha \in S,\ \beta \le \alpha\},
\]
equivalently the set of exponent vectors appearing in some \(k\)-fold partial derivative of \(f\).

### Exact theorem to target
Prove a theorem of the following form, with the strongest hypotheses you can sustain in Lean:

> **Theorem A (Shadow log-concavity for Lorentzian supports).**  
> Let \(f\) be a homogeneous Lorentzian polynomial of degree \(d\) with nonnegative coefficients and M-convex support. Then for every admissible \(k\) with \(1 \le k \le d-1\),
> \[
> |\Sh_k(S)|^2 \ge |\Sh_{k-1}(S)| \cdot |\Sh_{k+1}(S)|.
> \]
> Equivalently, the sequence \(k \mapsto |\Sh_k(S)|\) is log-concave on its support.

If the full Lorentzian statement is too ambitious for one cycle, prove one or more decisive breakthrough cases:

1. **Matroid basis generating polynomials**;
2. **Products of simplices / polymatroidal supports**;
3. **Schur or symmetric Lorentzian families where support is partition-dominated**.

A major success would be any theorem showing that Lorentzianity implies shadow log-concavity under a structural support hypothesis that is itself natural and nontrivial.

---

## Lean 4 Formalization Targets

You must include precise theorem statements in Lean 4 style. If the exact existing Lorentzian API is absent, define an appropriate interim predicate and state the theorem relative to it.

### New definitions to introduce
At least one of these should be formalized as a genuinely new concept:

```lean
def shadowProfile
    (S : Finset (Fin n → ℕ)) (d k : ℕ) : Finset (Fin n → ℕ) :=
  S.biUnion (fun α =>
    (((Finset.univ.powerset.filter fun T => T.card = k)).image fun _ => α)) -- placeholder blueprint only
```

Better: define shadows intrinsically via coordinatewise order and total degree:

```lean
def InShadow
    (S : Set (Fin n → ℕ)) (d k : ℕ) (β : Fin n → ℕ) : Prop :=
  (∑ i, β i = d - k) ∧ ∃ α ∈ S, β ≤ α
```

and a finite version:

```lean
def shadowFinset
    (S : Finset (Fin n → ℕ)) (d k : ℕ) : Finset (Fin n → ℕ) := ...
```

Also define a support-profile sequence:

```lean
def shadowCardSeq
    (S : Finset (Fin n → ℕ)) (d : ℕ) (k : ℕ) : ℕ :=
  (shadowFinset S d k).card
```

If needed, define a support-side Lorentzian surrogate:

```lean
def HasLorentzianShadowDescent
    (f : MvPolynomial (Fin n) ℝ) : Prop := ...
```

### Precise theorem signatures to aim for

A finite combinatorial theorem, independent of analytic Lorentzian infrastructure:

```lean
theorem shadowCard_logConcave_of_exchange
    {n d : ℕ}
    (S : Finset (Fin n → ℕ))
    (hdeg : ∀ α ∈ S, ∑ i, α i = d)
    (hexch : MConvexSupport S) :
    ∀ k, 1 ≤ k → k + 1 ≤ d →
      (shadowFinset S d k).card ^ 2 ≥
        (shadowFinset S d (k - 1)).card *
        (shadowFinset S d (k + 1)).card := by
```

A bridge theorem from polynomial coefficients to shadows:

```lean
theorem shadow_nonempty_iff_exists_iteratedPDeriv_coeff
    {n d k : ℕ}
    (f : MvPolynomial (Fin n) ℝ)
    (hhom : f.IsHomogeneousOfDegree d)
    (β : Fin n → ℕ)
    (hβ : ∑ i, β i = d - k) :
    β ∈ shadowFinset (f.support) d k ↔
      ∃ γ, ∑ i, γ i = k ∧
        coeff β (iteratedPDeriv γ f) ≠ 0 := by
```

A weighted intermediate theorem likely more tractable than raw cardinality:

```lean
theorem weightedShadow_logConcave_of_lorentzian
    {n d : ℕ}
    (f : MvPolynomial (Fin n) ℝ)
    (hhom : f.IsHomogeneousOfDegree d)
    (hlor : IsLorentzian f) :
    ∀ k, 1 ≤ k → k + 1 ≤ d →
      weightedShadow f d k ^ 2 ≥
        weightedShadow f d (k - 1) * weightedShadow f d (k + 1) := by
```

Then deduce the support theorem via positivity of descending-factorial weights on support:

```lean
theorem shadowCard_logConcave_of_lorentzian
    {n d : ℕ}
    (f : MvPolynomial (Fin n) ℝ)
    (hhom : f.IsHomogeneousOfDegree d)
    (hcoeff : ∀ α, 0 ≤ coeff α f)
    (hlor : IsLorentzian f)
    (hdisc : SupportUniformityHypothesis f) :
    ∀ k, 1 ≤ k → k + 1 ≤ d →
      (shadowFinset f.support d k).card ^ 2 ≥
        (shadowFinset f.support d (k - 1)).card *
        (shadowFinset f.support d (k + 1)).card := by
```

If full `IsLorentzian` is unavailable in Mathlib, formalize the theorem for a proxy hypothesis that is both checkable and mathematically meaningful, e.g.:
- all relevant derivative coefficient arrays are ultra log-concave,
- support is M-convex,
- Hessians of quadratic derivatives have Lorentzian signature.

That is acceptable if the bridge to the true Lorentzian conjecture is clearly stated in `RESEARCH_PAPER.md`.

---

## Catalog Building Blocks You Must Exploit

### 1. `Pythagorean/IteratedShadowGeometry.lean`
Use:
- `coeff_iteratedPDeriv`
- `descFactorial_prod_pos`

These are the algebraic engine. They convert “\(\beta\) lies in a shadow” into “some iterated derivative has nonzero coefficient at \(\beta\)” with explicit descending factorial multiplicities. This is the exact transport law from coefficient geometry to support geometry.

### 2. `Bridges/Catalog/Speculative/AutoResearch/WeightedSupportShadow.lean`
Use:
- `coeff_pderiv_pderiv`

This should help build second-derivative / mixed-derivative identities and weighted shadow counts. The right intermediate object is likely not raw cardinality but a weighted count:
\[
W_k(f) = \sum_{|\beta|=d-k} \mathbf{1}_{\exists \alpha\in S,\beta\le\alpha}\, w_{k,\beta},
\]
or better,
\[
W_k(f)=\sum_{|\gamma|=k}\#\operatorname{supp}(\partial^\gamma f),
\]
which can often be re-indexed using the coefficient transport formula.

### 3. Any existing finite-set shadow / antichain / compression lemmas in Mathlib
Search for:
- `Finset.card_biUnion`
- coordinatewise partial orders on functions `Fin n → ℕ`
- multiset / stars-and-bars combinatorics
- log-concavity lemmas over `ℕ`, `ℤ`, or `ℝ`

You may need to build your own compact API for multigraded shadows. That is desirable and counts as new infrastructure.

---

## Recommended Proof Architecture

## Strategy A: Weighted-shadow descent from coefficient log-concavity
**Most promising.**

1. **Define a weighted shadow statistic** \(W_k(f)\) that is exactly expressible through coefficients of iterated partial derivatives using `coeff_iteratedPDeriv`.
2. **Prove log-concavity of \(W_k(f)\)** from Lorentzian coefficient inequalities or from Alexandrov–Fenchel-type inequalities already encoded in the Lorentzian condition.
3. **Compare \(W_k(f)\) and \(|\Sh_k(S)|\)** using positivity of descending factorial factors (`descFactorial_prod_pos`) and a support-uniformity lemma. In structured families (matroids, simplices, Schur supports), the weights may be constant or monotone enough to let weighted log-concavity descend to cardinality log-concavity.

Why this is promising: the catalog already gives the exact coefficient transport formulas, and Lorentzian theory naturally controls weighted coefficient sums much better than bare support cardinalities.

### Concrete steps
- Prove a support-detection lemma: nonzero coefficient in an iterated derivative iff membership in shadow.
- Define a canonical weighted count that sums derivative coefficients over all multiindices of order \(k\).
- Re-index the sum over original support exponents and identify the descending-factorial multiplicity.
- Use positivity and structural regularity to compare with unweighted support counts.

---

## Strategy B: M-convex support plus discrete Brunn–Minkowski / exchange argument
This may yield a theorem stronger than the Lorentzian case and more combinatorial.

1. Prove that supports of the Lorentzian families under study are **M-convex** or satisfy a basis-exchange axiom.
2. Show that the multigraded shadow operator preserves a form of discrete convexity.
3. Derive log-concavity of the shadow-cardinality sequence via injections, compressions, or a rank-selected Macaulay-style argument.

Why this is exciting: if successful, the theorem becomes a purely support-level statement independent of coefficients, revealing that the true mechanism is discrete convexity rather than analytic Lorentzianity.

This would be revolutionary because it would identify the exact combinatorial skeleton beneath Lorentzian log-concavity.

---

## Strategy C: Symmetric-family reduction
Use this if the full general theorem is difficult.

1. Restrict to symmetric homogeneous polynomials whose support is determined by partitions or majorization.
2. Show the shadow sets correspond to partition truncations or dominance intervals.
3. Prove log-concavity by explicit enumerative formulas or via representation-theoretic monotonicity.

Targets:
- elementary symmetric polynomials,
- complete homogeneous polynomials,
- Schur-polynomial support families,
- products of simplex-generating polynomials.

Why useful: this gives a compelling first breakthrough case and yields computationally testable formulas for `demo.py`.

---

## Minimum Theorem Deliverables

Your Lean file must contain at least **3 substantial theorems** with nontrivial proofs. Suggested list:

### Theorem 1: Support-detection via iterated derivatives
A precise bridge theorem from shadow membership to nonvanishing derivative coefficients.

```lean
theorem mem_shadowFinset_iff_exists_iteratedPDeriv
    ...
```

Expected proof style:
- `rcases` on support membership,
- multi-step `calc`,
- use `coeff_iteratedPDeriv`,
- prove positivity of multiplicative factors with `descFactorial_prod_pos`.

### Theorem 2: Weighted shadow transport identity
An exact finite sum identity expressing a weighted shadow count in terms of original support.

```lean
theorem weightedShadow_eq_sum_descFactorial
    ...
```

Expected proof style:
- finite reindexing,
- `Finset.sum_biUnion`,
- coefficient extraction,
- `field_simp` if rational weights appear.

### Theorem 3: Log-concavity theorem in a structured Lorentzian family
For matroid supports, products of simplices, or another substantial family.

```lean
theorem shadowCard_logConcave_matroidBases
    ...
```

Expected proof style:
- induction on rank/ground set or derivative order,
- exchange axiom decomposition,
- `by_contra` to rule out cardinality failure,
- multi-step `calc`.

A fourth theorem connecting to another domain is strongly encouraged:

### Theorem 4: Cross-domain bridge
Examples:
- shadow log-concavity implies entropy concavity for the induced layer distribution,
- shadow profiles of basis-generating polynomials control reliability polynomials,
- support shadows correspond to occupancy models / statistical mechanics partition layers.

```lean
theorem entropyBound_of_shadowLogConcave
    ...
```

Even a rigorous inequality relating shadow-cardinality sequences to a probabilistic or information-theoretic quantity would satisfy the cross-domain requirement.

---

## Cross-Domain Connections You Should Exploit

### 1. Information theory
A log-concave sequence defines a unimodal layer distribution and controls entropy concentration. If \(a_k = |\Sh_k(S)|\), then normalized \(p_k = a_k / \sum_j a_j\) often satisfies stronger concentration and anti-tail bounds. A theorem here would connect Lorentzian geometry to **entropy maximization** and **negative dependence**.

### 2. Statistical physics
Lorentzian polynomials already interact with strongly Rayleigh measures and partition functions. Your shadow sequence can be interpreted as a **coarse-grained density of states** across derivative depth. Shadow log-concavity would imply thermodynamic regularity of this density profile.

### 3. Commutative algebra
Shadows are cousins of Macaulay growth, Hilbert functions, and rank-selected derivative spaces. A support-level Lorentzian shadow theorem may become a new route to Hilbert-function inequalities.

### 4. Matroid theory
For basis-generating polynomials, \(\Sh_k(S)\) should encode rank-selected deletion patterns. Proving log-concavity here would give a new support-shadow invariant of matroids, potentially related to Mason-type inequalities but not identical to them.

### 5. Representation theory
Schur-support shadows organize partition truncations. This hints at connections with branching multiplicities and Gelfand–Tsetlin patterns.

---

## Application Keywords

Use these in the paper and article:
**Lorentzian polynomials, Hodge theory, M-convexity, shadow operators, log-concavity, ultra log-concavity, matroids, strongly Rayleigh measures, entropy, partition functions, discrete convex analysis, combinatorial Hodge theory, coefficient transport, iterated derivatives, Schur support, polymatroids, Hilbert-function analogies.**

---

## Conjectures and Testable Predictions

You must state at least one falsifiable conjecture with a computational disproof pathway.

### Main conjecture
> **Conjecture 1.** Every homogeneous Lorentzian polynomial with nonnegative coefficients has a log-concave shadow-cardinality sequence.

### Stronger support-only conjecture
> **Conjecture 2.** Every finite M-convex set \(S \subseteq \{\alpha \in \mathbb{N}^n : |\alpha|=d\}\) has a log-concave shadow-cardinality sequence \(k \mapsto |\Sh_k(S)|\).

This is stronger and could be false. That is good science.

### Quantitative weighted conjecture
> **Conjecture 3.** For Lorentzian \(f\), the weighted shadow sequence \(W_k(f)\) is ultra log-concave after normalization by \(\binom{d}{k}\) or the relevant multiset coefficient.

This may be the true theorem underlying the cardinality statement.

### Computational test
Implement a verification pipeline for:
- matroid basis generating polynomials,
- products of simplices,
- Schur polynomial supports,
- random M-convex supports,
for \(n \le 8\), degree \(\le 10\).

For each instance:
1. test the Lorentzian proxy or exact criterion available,
2. compute all shadow sets \(\Sh_k\),
3. check log-concavity inequalities,
4. search for counterexamples to Conjecture 2 among M-convex supports lacking Lorentzian coefficients.

A counterexample to the support-only conjecture would itself be a meaningful result and should be documented.

---

## Algorithmic Deliverable

You must produce a **verified algorithm**, not just theorem statements.

### Required algorithm
Implement a certified shadow-profile computation and Lorentzian-test pipeline:

1. represent support sets as exponent vectors in `Fin n → ℕ`,
2. compute iterated shadows \(\Sh_k(S)\),
3. compute weighted shadow statistics from derivative transport,
4. verify log-concavity inequalities,
5. test Lorentzian conditions through:
   - Hessians of second derivatives,
   - sign patterns / eigenvalue checks where feasible,
   - structural family certificates (matroid basis polynomials, products of simplices).

The algorithm should expose both:
- exact combinatorial shadow counts,
- weighted transport counts predicted by theorems.

---

## demo.py Requirements

Create an interactive `demo.py` that:
- lets the user choose a family: `matroid`, `simplex_product`, `schur`, `random_mconvex`,
- generates the polynomial/support,
- computes \(|\Sh_k|\) for all \(k\),
- plots the shadow profile,
- highlights whether log-concavity holds,
- compares raw and weighted shadow profiles,
- if possible, displays a small witness of the coefficient transport identity.

The demo should make the phenomenon visually undeniable.

---

## File / Documentation Deliverables

You must produce **all** of the following:

1. **Lean file(s)** with the new definitions, at least 3 deep theorems, and minimal sorry.
2. **`FUTURE_DIRECTIONS.md`** with 3–5 original research directions.  
   Each direction must explicitly include:
   - “**The key insight is...**”
   - “**Why now?**”
   At least one direction must bridge to a different domain such as information theory, statistical mechanics, or commutative algebra.
3. **`RESEARCH_PAPER.md`** as a standalone scientific paper.  
   Someone reading only this document must understand:
   - the theorem,
   - why it is new,
   - how it connects to Lorentzian theory,
   - what was computationally tested,
   - what the next conjectures are.
4. **`ARTICLE.md`** in Scientific American style.  
   Explain the ideas and significance for a broad audience.  
   **Taboo:** do not focus on formal verification machinery.
5. **A verified algorithm / computational method** implementing the Lorentzian-shadow test pipeline.
6. **`demo.py`** demonstrating the result interactively.

---

## What Would Count as a Breakthrough

Any one of the following would be a major success:

- a general theorem proving shadow log-concavity for a robust class of Lorentzian polynomials;
- a weighted-shadow theorem from which multiple support inequalities follow;
- a support-only M-convex theorem showing Lorentzianity is not the essential mechanism;
- a counterexample to the naive support-only conjecture together with a corrected theorem;
- a cross-domain theorem linking shadow log-concavity to entropy concentration or partition-function geometry.

The dream result is not “another log-concavity statement.” It is the birth of a new object:

> **the shadow profile of a Lorentzian polynomial as a universal coarse-grained invariant.**

Build that theory.

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
