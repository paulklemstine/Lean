Soli Deo Gloria

## Assignment: Direction 2 — Transversal Matroids and Bipartite Matching Complexity

**Mode:** `prove`

You are not being asked for a routine extension. The goal is to open a new interface between **matroid enumeration**, **matching complexity**, and **algorithmic certification**. The central ambition is to show that sparsity in a bipartite presentation forces unexpectedly small quadratic leaf complexity for the associated transversal matroid, and that this can be exploited algorithmically.

The breakthrough is not merely a better bound: it is a structural theorem saying that **the second-order combinatorial complexity of a transversal matroid is governed by partial matching geometry rather than ambient subset counting**. If established cleanly in Lean, this would create a formal bridge from matroid theory to assignment/scheduling complexity and suggest a new sparse-combinatorial route to Lorentzian and log-concavity certification.

---

## Core Objects and New Definitions

Let `L` and `R` be finite types, and let `E : SimpleGraph (Sum L R)` be bipartite, or more concretely use a relation `Adj : L → R → Prop`. The associated transversal matroid on `L` declares `I ⊆ L` independent iff there exists an injective matching from `I` into `R` along `Adj`.

You should introduce at least one genuinely new definition, for example:

1. **Quadratic leaf profile** of a finite matroid:
   - the number of independent subsets of size `r - 2`, where `r` is the rank;
   - or more generally a function `k ↦ #{I independent | |I| = r-k}`.

2. **Bounded-degree transversal presentation**:
   - a presentation of a transversal matroid by a bipartite graph in which every left vertex has degree at most `Δ` (and optionally every right vertex too).

3. **Partial matching shadow**:
   - the family of right-side neighborhoods realizable by matchings of size `k`;
   - this is the right combinatorial state space through which the leaf bound should factor.

A possible Lean-facing definition package:

```lean
def IsTransversalIndependent
    {L R : Type*} [Fintype L] [Fintype R]
    (Adj : L → R → Prop) (I : Finset L) : Prop :=
  ∃ f : {x // x ∈ I} → R, Function.Injective f ∧
    ∀ x : {x // x ∈ I}, Adj x.1 (f x)

def transversalRank
    {L R : Type*} [Fintype L] [Fintype R]
    (Adj : L → R → Prop) : ℕ :=
  sSup {k | ∃ I : Finset L, I.card = k ∧ IsTransversalIndependent Adj I}

def quadraticLeafCount
    {L R : Type*} [Fintype L] [Fintype R]
    (Adj : L → R → Prop) : ℕ :=
  let r := transversalRank Adj
  ((Finset.univ.powerset.filter
    (fun I => IsTransversalIndependent Adj I ∧ I.card + 2 = r)).card)

def LeftDegreeLe
    {L R : Type*} (Adj : L → R → Prop) (Δ : ℕ) : Prop :=
  ∀ l : L, Fintype.card {r : R // Adj l r} ≤ Δ
```

If Mathlib’s matroid API is more convenient, define these over an existing matroid `M : Matroid α` plus a predicate `M.IsTransversalPresentation Adj`; but if that layer is too heavy, work directly with finite-set independence and prove the needed exchange facts from matching theory.

---

## Precise Theorem Targets

You must prove at least **3 substantial theorems**, with multi-step arguments. Here are the exact targets I recommend.

### Theorem 1: Injection from codimension-2 independent sets to small partial matching data

This is the structural theorem. It should say that every independent set of size `r-2` in a rank-`r` transversal system can be encoded by a bounded amount of matching data, yielding a counting bound.

A Lean-style statement:

```lean
theorem quadraticLeafCount_le_partialMatchingStates
    {L R : Type*} [Fintype L] [DecidableEq L] [Fintype R] [DecidableEq R]
    (Adj : L → R → Prop) (Δ r : ℕ)
    (hdeg : LeftDegreeLe Adj Δ)
    (hrank : transversalRank Adj = r) :
    quadraticLeafCount Adj ≤
      ∑ s in Finset.range (r + 1), Nat.choose (Fintype.card R) s * Δ^(r - 2) := by
  sorry
```

This statement can be sharpened, but the key point is: **codimension-2 independent sets are controlled by partial matching states**, not by all `(r-2)`-subsets of `L`.

A stronger version, if feasible, is to prove a direct polynomial-in-`|L|` bound:

```lean
theorem quadraticLeafCount_le_poly_of_bounded_degree
    {L R : Type*} [Fintype L] [DecidableEq L] [Fintype R] [DecidableEq R]
    (Adj : L → R → Prop) (Δ r : ℕ)
    (hdeg : LeftDegreeLe Adj Δ)
    (hrank : transversalRank Adj = r) :
    ∃ C : ℕ, C ≤ (Δ + 1)^(r+2) ∧
      quadraticLeafCount Adj ≤ C * (Fintype.card L)^(r - 2) := by
  sorry
```

This is the formal version of the research conjecture. Even if you only prove it under an additional hypothesis such as bounded right-degree or a Hall-tightness condition, that would still be meaningful.

---

### Theorem 2: Hereditary compression bound specialized to transversal matroids

Build explicitly on the catalog theorem
`Pythagorean/SupportCompressionPoly.lean`:
- `supportCompressedLeafCount_le_active_choose`

The new theorem should reinterpret the active-support bound in the language of transversal presentations. You want a theorem of the form:

```lean
theorem transversal_quadraticLeafCount_le_active_choose
    {L R : Type*} [Fintype L] [DecidableEq L] [Fintype R] [DecidableEq R]
    (Adj : L → R → Prop) :
    quadraticLeafCount Adj ≤
      Nat.choose (activeLeftVertices Adj) (transversalRank Adj - 2) := by
  sorry
```

where `activeLeftVertices Adj` is a new notion: the number of left vertices that occur in some basis / maximal matching-support witness.

Then sharpen this with degree control:

```lean
theorem activeLeftVertices_le_degree_times_rank
    {L R : Type*} [Fintype L] [DecidableEq L] [Fintype R]
    (Adj : L → R → Prop) (Δ : ℕ)
    (hdeg : LeftDegreeLe Adj Δ) :
    activeLeftVertices Adj ≤ Δ * transversalRank Adj := by
  sorry
```

Combining the two yields a nontrivial sparse bound. This route is especially attractive because it imports a vetted combinatorial compression theorem from the catalog and gives it a new matching-theoretic interpretation.

---

### Theorem 3: Cross-domain theorem — assignment/scheduling state-space bound

You are required to include a theorem connecting to another domain. Do not make this cosmetic. Use the transversal matroid as the feasibility skeleton of an assignment problem.

For a family of jobs `L` and machines `R`, with `Adj l r` meaning “job `l` is feasible on machine `r`,” prove that the number of near-full feasible job sets is polynomially bounded under bounded machine-choice complexity.

A Lean-style statement:

```lean
theorem assignment_feasible_subsystems_bound
    {Job Machine : Type*}
    [Fintype Job] [DecidableEq Job] [Fintype Machine] [DecidableEq Machine]
    (feasible : Job → Machine → Prop) (Δ r : ℕ)
    (hdeg : LeftDegreeLe feasible Δ)
    (hrank : transversalRank feasible = r) :
    quadraticLeafCount feasible ≤ (Δ + 1)^(r+2) * (Fintype.card Job)^(r - 2) := by
  sorry
```

Interpretation: in sparse assignment systems, the number of “almost-maximal feasible subsystems” is polynomially bounded. This is an operations-research statement, not just a matroid statement. It says sparse choice architecture suppresses combinatorial explosion in near-optimal subsystem enumeration.

If possible, derive an algorithmic corollary:

```lean
theorem enumerate_codim2_independent_sets_time_bound
    {L R : Type*} [Fintype L] [DecidableEq L] [Fintype R] [DecidableEq R]
    (Adj : L → R → Prop) (Δ r : ℕ)
    (hdeg : LeftDegreeLe Adj Δ)
    (hrank : transversalRank Adj = r) :
    ∃ algCost : ℕ,
      algCost ≤ (Δ + 1)^(r+3) * (Fintype.card L)^(r - 1) := by
  sorry
```

This is your verified computational method deliverable in theorem form.

---

## Main Conjecture with Testable Prediction

You must include a falsifiable conjecture, with explicit computational test.

### Conjecture
For every finite bipartite graph presentation `Adj : L → R → Prop` of rank `r`, if every left vertex has degree at most `Δ`, then there exists a constant `C_r` depending only on `r` such that

\[
\mathrm{quadraticLeafCount}(Adj) \le C_r \, \Delta^{r-2} \, |L|^{r-2}.
\]

A Lean-facing conjectural declaration:

```lean
conjecture transversal_quadraticLeafCount_sparse_asymptotic
    {L R : Type*} [Fintype L] [DecidableEq L] [Fintype R]
    (Adj : L → R → Prop) (Δ r : ℕ)
    (hdeg : LeftDegreeLe Adj Δ)
    (hrank : transversalRank Adj = r) :
    ∃ C : ℕ, C ≤ (r+1)! * (Δ+1)^(r-2) ∧
      quadraticLeafCount Adj ≤ C * (Fintype.card L)^(r - 2)
```

### Computational test
For each fixed `(r, Δ)`:
1. Generate random left-Δ-bounded bipartite graphs.
2. Generate structured families: grid incidence graphs, expander-like biregular graphs, Ramanujan-inspired bipartite graphs.
3. Compute:
   - rank,
   - quadratic leaf count,
   - number of size-`r-2` partial matchings,
   - permanent or near-perfect matching count when square.
4. Compare the empirical ratio
   \[
   \frac{\mathrm{quadraticLeafCount}}{|L|^{r-2}\Delta^{r-2}}
   \]
   across families.

A single counterexample family with super-polynomial growth in `|L|` for fixed `r,Δ` would disprove the conjecture.

---

## Proof Architecture: 3 Viable Strategies

You must not present only one route. Give Aristotle real optionality.

### Strategy A — Partial matching encoding via Hall witnesses
**Most promising.**

1. For each independent set `I` of size `r-2`, choose a witness matching `μ_I`.
2. Show that `I` can be reconstructed from:
   - the matched right image `μ_I(I)`,
   - at most two deficiency/witness vertices controlling extension to rank `r`.
3. Count the possible right-images and preimages using degree bounds:
   each matched right vertex has at most `Δ` possible left antecedents.

Why this is promising:
- It directly exploits the combinatorial meaning of transversal independence.
- It naturally yields polynomial counting bounds.
- It can be formalized with injective maps on subtypes and finite set cardinality lemmas.
- Hall/König machinery is conceptually clean and likely sufficient without the full Tutte–Berge formalism.

Key proof tactics likely needed:
- `rcases` on witness matchings,
- induction on `r`,
- `by_contra` for Hall obstruction arguments,
- `calc` chains for cardinality bounds.

---

### Strategy B — Compression through active support + catalog theorem
**Best if you want maximal leverage from existing formal infrastructure.**

1. Define the active support of a transversal presentation: left vertices appearing in some basis witness.
2. Prove that every codimension-2 independent set lies inside the active support.
3. Invoke
   `supportCompressedLeafCount_le_active_choose`
   from `Pythagorean/SupportCompressionPoly.lean`.
4. Prove an independent matching-theoretic bound on active support size in bounded-degree presentations.

Why this is promising:
- It directly builds on a vetted catalog theorem.
- It decomposes the problem into a generic compression part and a new matching part.
- Even if the final `Δ`-polynomial exponent is not optimal, the theorem will still be robust and conceptually clean.

Risk:
- The active support bound may require a subtle definition to avoid becoming tautological or too large.

---

### Strategy C — Exchange-theoretic route using M-convexity / Lorentzian structure
**Most visionary, highest upside.**

1. Use `Speculative/AutoResearch/LorentzianMConvex.lean` and especially
   `IsMConvexExchangeNat`
   to reinterpret basis-indicator or support families of transversal matroids as M-convex objects.
2. Show that bounded-degree presentations imply a sparse exchange graph on near-bases.
3. Bound codimension-2 states by counting local exchange neighborhoods in the M-convex structure.

Why this matters:
- If successful, this would connect transversal matroid leaf complexity to discrete convex analysis and Lorentzian geometry.
- It opens the door to certified sparse Lorentzian algorithms for assignment systems.

Risk:
- This route is conceptually powerful but may require more infrastructure than the matching route.

Recommendation:
- Use Strategy A for the main theorem.
- Use Strategy B for a second theorem and stronger catalog integration.
- Use Strategy C for a conjectural section or one smaller theorem linking exchange structure to matching sparsity.

---

## Catalog Build Plan

You are explicitly expected to build on the following catalog results.

### 1. `Pythagorean/SupportCompressionPoly.lean`
Use:
- `supportCompressedLeafCount_le_active_choose`

How to use it:
- Instantiate the abstract “active variable/support” notion with left vertices participating in some maximal transversal witness.
- Prove that quadratic leaves of the transversal system are support-compressed into this active set.
- Then reduce the problem to bounding active support size via matching theory.

This is not just a citation; it is the compression engine for the sparse theorem.

### 2. `Speculative/AutoResearch/LorentzianMConvex.lean`
Use:
- `IsMConvexExchangeNat`

How to use it:
- Model near-bases or degree vectors of partial matchings as integer points in an exchange system.
- Derive local exchange constraints for codimension-2 states.
- Translate exchange sparsity into leaf-count sparsity.

Even a modest theorem here would be a cross-catalog synthesis of real value.

---

## Concrete Theorem List You Should Aim to Formalize

At minimum, produce these three substantial theorems:

1. `quadraticLeafCount_le_partialMatchingStates`
2. `transversal_quadraticLeafCount_le_active_choose`
3. `assignment_feasible_subsystems_bound`

And ideally also:

4. `activeLeftVertices_le_degree_times_rank`
5. `enumerate_codim2_independent_sets_time_bound`

These should involve real proof structure: induction, `rcases`, contradiction through Hall obstruction, and multi-step counting arguments. Avoid vacuous finite brute force.

---

## Cross-Domain Connections

You must explicitly develop at least one theorem or substantial discussion bridging transversal matroids to another field.

### Operations Research
Transversal matroids are the combinatorial skeleton of assignment and scheduling feasibility. A polynomial bound on codimension-2 feasible subsystems means:
- sparse assignment instances have compressed near-optimal state spaces,
- sensitivity analysis around maximum feasible assignments becomes tractable,
- branch-and-bound or local-search heuristics can be certified to explore only polynomially many critical near-bases.

### Discrete Convex Analysis / Lorentzian Geometry
If codimension-2 states are sparse in bounded-degree presentations, this suggests a sparse regime for Lorentzian certification of matching polynomials and basis-generating polynomials. That could become a new route to:
- negative dependence certification,
- stable polynomial approximations,
- combinatorial Hodge-type inequalities for assignment structures.

### Complexity Theory
A theorem of this kind separates **ambient subset complexity** from **presentation complexity**. The same matroid rank can hide wildly different codimension-2 geometry depending on whether the presentation is sparse. This is a structural complexity statement, not just an enumerative one.

---

## Application Keywords

Use these in the paper and article:
**transversal matroid, bipartite matching, Hall’s theorem, König’s theorem, sparse assignment, scheduling feasibility, near-basis enumeration, Lorentzian polynomial, M-convex exchange, combinatorial compression, partial matching complexity, operations research, discrete convex analysis, polynomial-time certification**

---

## Deliverables (MANDATORY)

You must produce **all** of the following:

### 1. `FUTURE_DIRECTIONS.md`
Include 3–5 research directions. Each direction must contain:
- a sentence beginning **“The key insight is...”**
- a sentence beginning **“Why now?”**
At least one direction must bridge to a different domain, such as:
- market design,
- statistical physics of matchings,
- network reliability,
- tropical optimization.

Do not write generic templates; write original research prose.

### 2. `RESEARCH_PAPER.md`
A standalone scientific paper explaining:
- the theorem statements,
- the structural idea behind the sparse bound,
- how the catalog results were used,
- why the result matters for assignment/scheduling and Lorentzian certification,
- the conjecture and computational evidence,
- next problems opened by the work.

Someone reading only this file must understand the mathematics and significance.

### 3. `ARTICLE.md`
Write this in **Scientific American style**:
- vivid,
- broad-audience accessible,
- focused on the mathematical ideas and why sparse choice architectures tame combinatorial explosion.

Taboo:
- do **not** center the story on formal verification machinery.

### 4. Verified algorithm or computational method
You must implement a certified or at least theorem-backed method to:
- enumerate or upper-bound codimension-2 independent sets of a bounded-degree transversal system,
- and prove a complexity bound for it.

This is not optional.

### 5. `demo.py`
Provide an interactive demo that:
- generates random bounded-degree bipartite graphs,
- computes rank and quadratic leaf count,
- compares against the theoretical upper bound,
- optionally compares with perfect matching counts / permanents for small examples,
- visualizes growth versus `n`, `r`, and `Δ`.

---

## Final Scientific Objective

Do not settle for “some bound.” The true target is to show:

> **Sparse presentations force sparse near-basis geometry.**

If you can make that precise for transversal matroids, you will have created a new theorem schema linking combinatorial representation sparsity to higher-order matroid complexity. That is the kind of result that does not merely solve a problem — it opens a program.

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
