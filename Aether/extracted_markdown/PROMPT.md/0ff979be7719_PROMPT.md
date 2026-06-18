## Assignment: Direction 2: Cancellation-Aware Shadow Bounds for General Circuits

**Mode:** `prove`

Prove genuinely new theorems that push the shadow method beyond the monotone world and into the cancellation-dominated regime where algebraic complexity becomes structurally subtle. Build directly on:

- `Pythagorean/CircuitLowerBounds/KruskalKatonaSupport.lean`
  - `card_oneShadow_union_le`
  - `shadow_bound_of_supportCircuit`

The goal is not to repackage the monotone bound, but to create a **cancellation-aware support/shadow calculus** for general algebraic circuits, with theorems strong enough to become a plausible entry point toward non-monotone lower bounds.

---

## Core Vision

For monotone circuits, support growth is controlled because addition behaves like union and multiplication behaves like Minkowski sum. In general circuits, subtraction and coefficient cancellation can drastically shrink support. The revolutionary step is to show that **cancellation is not arbitrary**: it leaves detectable combinatorial traces in the one-shadow, and these traces can still be bounded from above and below in terms of circuit structure.

This would open a new program:

- **algebraic complexity × extremal set theory**: shadow inequalities as complexity invariants,
- **algebraic complexity × additive combinatorics**: cancellation patterns as structured overlap phenomena,
- **algebraic complexity × symbolic computation**: verified support-pruning algorithms for circuits,
- potentially a new route toward separating determinant/permanent-type families by **shadow rigidity** rather than coefficient-growth or rank methods.

Application keywords: **algebraic complexity, non-monotone circuits, support cancellation, Kruskal–Katona, additive combinatorics, symbolic algorithms, determinant vs permanent, Newton polytope, sparse elimination**.

---

## New Mathematical Objects to Introduce

You must define at least one genuinely new notion. Suggested definitions:

### 1. Cancellation witness set
For finitely supported polynomials `f g`, define the set of monomials that disappear in the sum:
\[
\mathrm{Cancel}(f,g) := (\mathrm{supp}(f)\cup \mathrm{supp}(g)) \setminus \mathrm{supp}(f+g).
\]
This is the exact combinatorial footprint of coefficient cancellation.

### 2. Cancellation-aware shadow deficit
Define
\[
\Delta_{\mathrm{sh}}(f,g)
:= |\mathrm{Sh}_1(\mathrm{supp}(f)\cup \mathrm{supp}(g))|
 - |\mathrm{Sh}_1(\mathrm{supp}(f+g))|.
\]
This measures how much one-shadow is lost under cancellation.

### 3. Support overlap multiplicity profile
For a decomposition \(f = \sum_i h_i\), define a profile recording how many summands contribute to each monomial before cancellation. The conjectural principle is that large shadow deficit requires high overlap multiplicity and hence circuit reuse/structure.

These are not just bookkeeping devices: they are the bridge from syntax (circuit operations) to semantics (support geometry).

---

## Precise Theorem Targets

You should aim for at least the following three theorem-level deliverables, with proofs using real tactics and structure, not brute-force decision procedures.

### Theorem 1: Support cancellation inclusion and shadow upper transfer
Formalize the fundamental fact that cancellation can only reduce support, hence the monotone shadow upper bound transfers to arbitrary circuits by forgetting signs.

**Mathematical statement**
For finitely supported polynomials \(f,g\),
\[
\mathrm{supp}(f+g)\subseteq \mathrm{supp}(f)\cup \mathrm{supp}(g).
\]
Consequently,
\[
|\mathrm{Sh}_1(\mathrm{supp}(f+g))|
\le
|\mathrm{Sh}_1(\mathrm{supp}(f)\cup \mathrm{supp}(g))|.
\]
Iterating over the circuit DAG yields a general-circuit upper shadow bound controlled by the monotone support circuit obtained by replacing subtraction by formal addition.

**Lean 4 target signature sketch**
```lean
theorem support_add_subset_union
    {σ R : Type _} [DecidableEq σ] [Semiring R]
    (f g : MvPolynomial σ R) :
    f.support ⊆ g.support ∪ f.support := by
  sorry
```
Better / intended version:
```lean
theorem support_add_subset_union
    {σ R : Type _} [DecidableEq σ] [Semiring R]
    (f g : MvPolynomial σ R) :
    (f + g).support ⊆ f.support ∪ g.support := by
  sorry
```

and then a shadow corollary:
```lean
theorem card_oneShadow_support_add_le_card_oneShadow_union
    {α : Type _} [DecidableEq α]
    (A B : Finset (Finset α)) :
    card (oneShadow (A ∪ B)) ≥ card (oneShadow ((A ∩ B))) := by
  sorry
```
But the more relevant polynomial-facing theorem is:
```lean
theorem card_oneShadow_support_add_le
    {σ R : Type _} [DecidableEq σ] [Semiring R]
    (f g : MvPolynomial σ R) :
    (oneShadow ((f + g).support.image monomialSupport)).card ≤
      (oneShadow ((f.support ∪ g.support).image monomialSupport)).card := by
  sorry
```
You may need to introduce an appropriate `monomialSupport` map from monomials/exponent vectors to finite subsets of variables.

**Why it matters**
This theorem is the portal from existing monotone catalog results to non-monotone circuits. It says: even with arbitrary cancellation, the monotone shadow machine remains a valid **outer envelope**.

---

### Theorem 2: Quantitative shadow-deficit bound from cancellation witnesses
This is the first genuinely new statement: the amount by which the shadow drops is controlled by the shadow generated by the cancelled monomials.

**Mathematical statement**
For finitely supported polynomials \(f,g\),
\[
\mathrm{Sh}_1(\mathrm{supp}(f)\cup \mathrm{supp}(g))
\subseteq
\mathrm{Sh}_1(\mathrm{supp}(f+g))
\cup
\mathrm{Sh}_1(\mathrm{Cancel}(f,g)).
\]
Hence
\[
\Delta_{\mathrm{sh}}(f,g)
\le
|\mathrm{Sh}_1(\mathrm{Cancel}(f,g))|.
\]

This is subtle and important: the only way to lose shadow is through shadows already “explained” by cancelled monomials. It converts cancellation from a mysterious semantic event into a localized combinatorial obstruction.

**Lean 4 target signature sketch**
```lean
def cancelSet
    {σ R : Type _} [DecidableEq σ] [Semiring R]
    (f g : MvPolynomial σ R) : Finset (σ →₀ ℕ) :=
  (f.support ∪ g.support) \ (f + g).support

theorem oneShadow_union_subset_oneShadow_add_union_cancel
    {α : Type _} [DecidableEq α]
    (A B : Finset (Finset α)) :
    oneShadow (A ∪ B) ⊆ oneShadow ((A \ B) ∪ (B \ A) ∪ (A ∩ B)) := by
  sorry
```
That set-theoretic version is too coarse; the intended polynomial support theorem is:
```lean
theorem oneShadow_support_union_subset
    {σ R : Type _} [DecidableEq σ] [Semiring R]
    (f g : MvPolynomial σ R) :
    oneShadow (supportFamily (f.support ∪ g.support)) ⊆
      oneShadow (supportFamily (f + g).support) ∪
      oneShadow (supportFamily (cancelSet f g)) := by
  sorry
```
and then:
```lean
theorem shadow_deficit_le_cancel_shadow
    {σ R : Type _} [DecidableEq σ] [Semiring R]
    (f g : MvPolynomial σ R) :
    card (oneShadow (supportFamily (f.support ∪ g.support))) -
      card (oneShadow (supportFamily ((f + g).support))) ≤
    card (oneShadow (supportFamily (cancelSet f g))) := by
  sorry
```

**Why it is a breakthrough**
This theorem is the first “conservation law” for shadow under cancellation. It suggests that lower bounds can survive non-monotonicity if one can independently limit cancellation complexity.

---

### Theorem 3: Circuit-level recursive bound with cancellation budget
Define a circuit semantics together with a recursive cancellation budget \(B(C)\), and prove that the final one-shadow is bounded by the monotone support envelope plus accumulated cancellation losses.

**Mathematical statement**
For every algebraic circuit \(C\) computing polynomial \(f_C\), there exists a recursively defined quantity \(B(C)\) such that
\[
|\mathrm{Sh}_1(\mathrm{supp}(f_C))|
\le U(C),
\]
where \(U(C)\) is the monotone shadow bound from the catalog, and moreover
\[
U(C)-|\mathrm{Sh}_1(\mathrm{supp}(f_C))| \le B(C).
\]
For an addition gate \(C=C_1+C_2\),
\[
B(C) \le B(C_1)+B(C_2)+|\mathrm{Sh}_1(\mathrm{Cancel}(f_{C_1},f_{C_2}))|,
\]
while for multiplication gates the budget propagates through support sum structure.

This theorem should be formalized for a simplified circuit datatype if necessary.

**Lean 4 target signature sketch**
```lean
inductive ACircuit (σ : Type _)
| var : σ → ACircuit σ
| C : ℤ → ACircuit σ
| add : ACircuit σ → ACircuit σ → ACircuit σ
| mul : ACircuit σ → ACircuit σ → ACircuit σ

def cancelBudget : ACircuit σ → ℕ
-- recursive definition

theorem shadow_le_monotoneEnvelope
    {σ : Type _} [DecidableEq σ]
    (C : ACircuit σ) :
    shadowCard (evalSupport C) ≤ monotoneEnvelopeShadow C := by
  sorry

theorem monotoneEnvelopeGap_le_cancelBudget
    {σ : Type _} [DecidableEq σ]
    (C : ACircuit σ) :
    monotoneEnvelopeShadow C - shadowCard (evalSupport C) ≤ cancelBudget C := by
  sorry
```

**Why it matters**
This is the theorem that turns local cancellation analysis into a global circuit invariant. It is the right formal statement if the long-term dream is a non-monotone shadow lower-bound method.

---

## Strong Cross-Domain Theorem Requirement

Include at least one theorem connecting this program to a different field.

### Recommended bridge: additive combinatorics / Newton polytopes
Support of products behaves like sumset/Minkowski sum. Shadow control on support families should imply a coarse boundary bound for Newton polytope vertex neighborhoods, or conversely additive overlap should constrain cancellation.

A clean theorem target:

**Mathematical statement**
If \(A,B\) are support families of multilinear monomials, then
\[
\mathrm{supp}(fg) \subseteq A \oplus B,
\]
and the one-shadow of the product support is controlled by a sumset shadow expression. This links algebraic circuits to additive combinatorics on set systems.

**Lean 4 target signature sketch**
```lean
theorem support_mul_subset_supSum
    {σ R : Type _} [DecidableEq σ] [Semiring R]
    (f g : MvPolynomial σ R) :
    (f * g).support ⊆ finsetAdd f.support g.support := by
  sorry
```
Then prove a one-shadow consequence using multi-step `calc` and subset arguments.

Alternative bridge: interpret support families as states in a deletion graph / simplicial complex and prove a statement about boundary size. That would connect to topological combinatorics.

---

## Conjecture with Testable Prediction

You must include at least one falsifiable conjecture and a computational protocol.

### Conjecture: Low cancellation budget for determinant circuits
Let `det_n` be the determinant polynomial on \(n \times n\) variables. There exists a family of circuits \(C_n\) of polynomial size computing `det_n` such that
\[
B(C_n) = O(n^k)
\]
for some fixed \(k\), and therefore
\[
U(C_n)-|\mathrm{Sh}_1(\mathrm{supp}(\det_n))| = O(n^k).
\]

### Competing conjecture: Permanent shadow rigidity
Any polynomial-size circuit family \(C_n\) computing `perm_n` must satisfy
\[
B(C_n) \ge n^{\Omega(\log n)}
\quad\text{or}\quad
U(C_n)-|\mathrm{Sh}_1(\mathrm{supp}(\mathrm{perm}_n))| \ge n^{\Omega(\log n)}.
\]

These are falsifiable:
- compute exact support and one-shadow for \(3\times3\) and \(4\times4\) determinant/permanent,
- compare to monotone envelope and cancellation budget for known circuits,
- search for anomalously low-budget permanent circuits.

This is exactly the kind of experiment that can kill the conjecture early if it is wrong.

---

## Proof Architecture: 3 Viable Strategies

You must discuss and attempt at least two of these in code/comments, and ideally implement the strongest one.

### Strategy A: Local-to-global cancellation accounting via induction on circuit structure
1. Define support semantics and monotone envelope semantics for circuits.
2. Prove local lemmas for `add` and `mul` gates:
   - support inclusion,
   - shadow transfer,
   - cancellation deficit control.
3. Induct on the circuit to obtain global upper/gap bounds.

**Why promising:** best aligned with catalog support-circuit results and with Lean induction. This should be the main route.

---

### Strategy B: Extremal set theory via Kruskal–Katona lower envelopes
1. Represent support as a family of finite variable sets in the multilinear case.
2. Use catalog KK bounds to show that if support cardinality remains large, its one-shadow cannot collapse too much.
3. Combine with the cancellation witness set to derive lower bounds on how much overlap is required to produce substantial shadow deficit.

**Why promising:** this is where actual non-monotone lower-bound content begins. It turns cancellation into a combinatorial rarity statement.

---

### Strategy C: Additive-combinatorial overlap control
1. Treat support addition/multiplication as sumset-like operations on exponent vectors.
2. Bound cancellation by overlap multiplicity of coefficient contributions.
3. Use combinatorial inequalities on overlaps / energy-like quantities to constrain shadow deficit.

**Why promising:** conceptually deepest and most field-opening, because it imports additive combinatorics into algebraic circuit complexity. Harder to fully formalize, but even a first rigorous lemma here would be important.

**Recommendation:** Use Strategy A for the core verified theorems, Strategy B for the strongest lower-bound flavored theorem, and Strategy C for at least one bridge lemma or conjectural framework.

---

## Specific Lean Guidance

You should avoid toy statements. The file must contain at least 3 substantial theorems proved with:
- induction on circuits or finite sets,
- `rcases` decomposition of membership in unions/products,
- `by_contra` for shadow-deficit impossibility,
- `field_simp` only if a coefficient identity genuinely requires it,
- nontrivial `calc` chains for cardinal inequalities.

Likely ingredients:
- `Finset` subset/cardinality lemmas,
- support lemmas for `MvPolynomial`,
- image/union/diff reasoning,
- catalog shadow lemmas from `KruskalKatonaSupport.lean`.

If `MvPolynomial` support-to-variable-set conversion is awkward, formalize first in an abstract support-family model:
- a family `𝒜 : Finset (Finset α)`,
- abstract addition envelope `𝒜 ⊔ 𝒝 := 𝒜 ∪ 𝒝`,
- cancellation-pruned family `prune 𝒜 𝒝`,
then instantiate later to polynomial supports.

That abstraction is not a cop-out: it may reveal the true combinatorial invariant more clearly.

---

## Deliverables You Must Produce

You must produce **all** of the following:

1. **Lean file(s)** with the new definitions and at least 3 nontrivial theorems as above, minimizing `sorry`.
2. **A verified algorithm or computational method**:
   - compute support families,
   - compute one-shadow,
   - compute cancellation witness sets,
   - compute shadow deficit and monotone envelope gap for small circuits/polynomials.
3. **`demo.py`**:
   - interactively evaluate determinant/permanent examples for \(n=3,4\),
   - print support size, one-shadow size, cancellation witness size, and the predicted inequalities,
   - optionally visualize support/shadow statistics.
4. **`RESEARCH_PAPER.md`**:
   - standalone scientific exposition,
   - define the new invariants,
   - state and interpret the main theorems,
   - explain why cancellation-aware shadows could matter for non-monotone lower bounds,
   - include limitations and next experiments.
5. **`ARTICLE.md`** in Scientific American style:
   - tell the story as a conceptual breakthrough about how “missing monomials leave geometric scars,”
   - do not focus on verification machinery.
6. **`FUTURE_DIRECTIONS.md`** with 3–5 original research directions.
   Each direction must include both sentences:
   - **“The key insight is...”**
   - **“Why now?”**
   At least one direction must bridge to a different domain, e.g. additive combinatorics, convex geometry, or statistical physics.

---

## Concrete Experimental Targets

Your computational test suite should include:

- determinant and permanent for \(3\times3\),
- if feasible, determinant and permanent for \(4\times4\),
- hand-built non-monotone circuits with explicit cancellation,
- random sparse circuits with signed coefficients.

For each example, compute:
- support size,
- one-shadow size,
- monotone envelope shadow size,
- cancellation witness size,
- shadow deficit,
- candidate budget \(B(C)\).

The purpose is not just illustration: the data should suggest whether cancellation deficit scales with overlap structure rather than raw circuit size.

---

## What Would Count as a Field-Opening Success

A successful outcome would not merely show that `supp(f+g) ⊆ supp(f) ∪ supp(g)`. That is only the starting axiom. The real success is to prove one or more of the following:

- a **quantitative deficit theorem** showing shadow loss is controlled by explicit cancellation structure,
- a **recursive circuit invariant** whose smallness is certifiable and whose largeness obstructs efficient circuits,
- a **bridge theorem** importing additive combinatorics or convex geometry into support-based complexity,
- convincing evidence that determinant and permanent behave differently under cancellation-aware shadow analysis.

That would create a new research lane: **cancellation-sensitive extremal combinatorics for algebraic complexity**.

Soli Deo Gloria

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
