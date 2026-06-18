Soli Deo Gloria

## Assignment: Direction 5 — Tropical Rank / Laplacian Minor Bridge

**Mode:** `prove`

You are not being asked for a cosmetic extension. You are being asked to forge a structural bridge between two theories that have developed in parallel and, astonishingly, still lack a canonical formal interface: **Baker–Norine divisor rank on graphs** and **tropical matrix rank of Laplacian minors**. If this bridge is real, it converts subtle chip-firing rank questions into computable tropical linear algebra. If the naive conjecture fails, then the failure mechanism itself will reveal the missing invariant and open a new theory.

Your task is to formalize and prove **new, nontrivial theorems** around this bridge, using the catalog as a launchpad rather than a boundary.

## Core Vision

For a finite connected graph `G` with basepoint `q`, and for a subset `S ⊆ V \ {q}`, consider the degree-zero divisor

\[
D_S := \sum_{v \in S} [v] - |S| [q].
\]

Let `L` be the graph Laplacian and `L_S` the principal submatrix indexed by `S`. The motivating conjecture is that the Baker–Norine rank of `D_S` is controlled from below by a tropical rank invariant of `L_S`.

The raw conjecture

\[
r(D_S) \ge \operatorname{tropRank}(L_S) - 1
\]

is bold enough to matter. But do not merely restate it. Build a formal framework in which one can:
1. define the canonical family `D_S`,
2. define the relevant Laplacian minor object,
3. prove structural theorems linking chip-firing moves to tropical dependence,
4. either prove the inequality in important classes of graphs or isolate a corrected invariant if the full statement is false.

This is the kind of result that could open a **tropical Hodge dictionary for finite graphs**.

---

## Precise Formal Targets

You must introduce at least one genuinely new definition not already present in the catalog. A recommended choice is a structure encoding the canonical bridge object.

### New definition candidates

Define a canonical divisor family and minor extraction interface, e.g.

```lean
structure RootedSubsetData (V : Type _) [Fintype V] [DecidableEq V] where
  q : V
  S : Finset V
  hq : q ∉ S
```

Define the canonical degree-zero divisor attached to `S`:

```lean
def rootedSubsetDivisor
    {V : Type _} [Fintype V] [DecidableEq V]
    (q : V) (S : Finset V) : V → ℤ :=
  fun v => if v ∈ S then 1 else if v = q then -(S.card : ℤ) else 0
```

Define a Laplacian principal minor extraction object:

```lean
def laplacianPrincipalMinor
    {V : Type _} [Fintype V] [DecidableEq V]
    (L : Matrix V V ℤ) (S : Finset V) :
    Matrix (↥S) (↥S) ℤ := fun i j => L i.1 j.1
```

Define a new bridge invariant, more robust than bare tropical rank if needed:

```lean
def tropicalFiringCorank
    {α : Type _} [LinearOrderedRing α]
    {n : Type _} [Fintype n] [DecidableEq n]
    (M : Matrix n n α) : ℕ := Fintype.card n - tropicalRank M
```

or even better, a chip-firing accessibility notion:

```lean
def firingIndependentOn
    {V : Type _} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) (S : Finset V) : Prop := ...
```

If the original conjecture is too rigid, this new invariant may become the correct bridge quantity. That would still be a breakthrough.

---

## Exact Theorem Program

You must prove at least **3 substantial theorems**, each requiring genuine mathematical work: induction, `rcases`, contradiction, `field_simp` where relevant, multi-step `calc`, or a nontrivial reduction argument. Avoid toy lemmas.

Below is the target theorem suite. You may refine hypotheses to fit existing Mathlib graph infrastructure, but keep the mathematical content intact.

### Theorem 1: Degree-zero and support control for canonical subset divisors

This is foundational and should be proved in a structurally rich way, not by unfolding and trivial simplification.

```lean
theorem rootedSubsetDivisor_total
    {V : Type _} [Fintype V] [DecidableEq V]
    (q : V) (S : Finset V) (hq : q ∉ S) :
    (∑ v, rootedSubsetDivisor q S v) = 0
```

Strengthen it with support localization:

```lean
theorem support_rootedSubsetDivisor_subset
    {V : Type _} [Fintype V] [DecidableEq V]
    (q : V) (S : Finset V) :
    {v | rootedSubsetDivisor q S v ≠ 0} ⊆ ({q} ∪ ↑S : Set V)
```

**Why this matters:** this makes `D_S` a canonical point of the degree-zero Jacobian lattice and sets up every later comparison to Laplacian images.

---

### Theorem 2: Tropical rank upper bound from chip-firing dimension on trees or cut-supported subsets

You need at least one genuine bridge theorem that is provable now in a significant class. Trees are the most promising first frontier because Baker–Norine rank becomes rigid and Laplacian minors are classically controlled.

A strong target is:

```lean
theorem tropicalRank_principalMinor_le_one_of_tree
    {V : Type _} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (hconn : G.Connected)
    (htree : IsTree G)
    (q : V) (S : Finset V) (hq : q ∉ S) :
    tropicalRank (laplacianPrincipalMinor (graphLaplacian G) S) ≤ 1
```

paired with the divisor-rank side:

```lean
theorem divisorRank_rootedSubsetDivisor_tree_nonneg
    {V : Type _} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (hconn : G.Connected)
    (htree : IsTree G)
    (q : V) (S : Finset V) (hq : q ∉ S) :
    0 ≤ divisorRank G (rootedSubsetDivisor q S)
```

and then the bridge inequality in this class:

```lean
theorem rootedSubset_bridge_inequality_of_tree
    {V : Type _} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (hconn : G.Connected)
    (htree : IsTree G)
    (q : V) (S : Finset V) (hq : q ∉ S) :
    tropicalRank (laplacianPrincipalMinor (graphLaplacian G) S) - 1
      ≤ divisorRank G (rootedSubsetDivisor q S)
```

If the exact tropical-rank bound on trees needs adjustment, replace it with a theorem of the form “every `2 × 2` tropical-nonsingular minor fails” or another equivalent rank-`≤ 1` criterion. The point is to obtain a **nontrivial verified class** where the bridge is true.

**Why this matters:** trees are not a triviality here; they are the testing ground where chip-firing rank, reduced divisors, and Laplacian structure are all transparent enough to let the theory crystallize.

---

### Theorem 3: Monotonicity or functoriality under subset inclusion

You need a theorem that shows this bridge is not accidental but behaves coherently as `S` varies.

A promising target:

```lean
theorem rootedSubsetDivisor_monotone_under_inclusion
    {V : Type _} [Fintype V] [DecidableEq V]
    (q : V) {S T : Finset V} (hST : S ⊆ T) (hqT : q ∉ T) :
    ∃ E : V → ℤ,
      rootedSubsetDivisor q T = rootedSubsetDivisor q S + E
```

But this is too algebraic on its own. Strengthen it into a graph-theoretic rank monotonicity statement in a class where it is true:

```lean
theorem bridge_monotone_under_inclusion_of_nested_cuts
    {V : Type _} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (q : V) {S T : Finset V}
    (hST : S ⊆ T) (hqT : q ∉ T)
    (hcut : NestedCutFamily G q S T) :
    tropicalRank (laplacianPrincipalMinor (graphLaplacian G) S)
      ≤ tropicalRank (laplacianPrincipalMinor (graphLaplacian G) T)
```

and/or

```lean
theorem divisorRank_rootedSubset_monotone_of_nested_cuts
    {V : Type _} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (q : V) {S T : Finset V}
    (hST : S ⊆ T) (hqT : q ∉ T)
    (hcut : NestedCutFamily G q S T) :
    divisorRank G (rootedSubsetDivisor q S)
      ≤ divisorRank G (rootedSubsetDivisor q T)
```

You may define `NestedCutFamily` yourself if absent from the catalog. This satisfies the novelty requirement and creates a formal language for “independent chip-firing directions.”

**Why this matters:** a monotonicity principle is the first sign that the bridge is controlled by an underlying geometry rather than isolated examples.

---

### Theorem 4: Cross-domain theorem via effective resistance / Green’s function

You are required to include at least one theorem connecting to a different domain. The most compelling bridge is to **electrical network theory / discrete potential theory**.

For connected graphs, the Laplacian pseudoinverse controls effective resistance. Tropical rank defects of Laplacian minors should reflect degeneracies in localized potential propagation.

A formal theorem target could be modest but real:

```lean
theorem principalMinor_nonsingularity_of_connected_graph
    {V : Type _} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (hconn : G.Connected)
    (q : V) :
    IsUnit (Matrix.det (laplacianPrincipalMinor (graphLaplacian G) ({q}ᶜ.toFinset)))
```

or, if determinant infrastructure is already aligned with Kirchhoff in the catalog, prove a consequence:

```lean
theorem positive_treeCount_of_principalMinor
    {V : Type _} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (hconn : G.Connected)
    (q : V) :
    0 < Matrix.det (laplacianPrincipalMinor (graphLaplacian G) ((Finset.univ.erase q)))
```

Then explicitly connect this to tropical rank nondegeneracy:

```lean
theorem tropicalRank_pos_of_treeCount_pos
    ...
```

This theorem links:
- combinatorics: spanning trees,
- linear algebra: principal minors,
- tropical geometry: tropical rank,
- physics: electrical response / Green kernels.

**This is not decorative.** It is the beginning of a tropical-electrical dictionary.

---

## Main Conjecture to Investigate

State and test the central conjecture in Lean-compatible mathematical form.

```lean
conjecture rootedSubset_divisorRank_ge_tropicalRank_sub_one
    {V : Type _} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (hconn : G.Connected)
    (q : V) (S : Finset V) (hq : q ∉ S) :
    tropicalRank (laplacianPrincipalMinor (graphLaplacian G) S) - 1
      ≤ divisorRank G (rootedSubsetDivisor q S)
```

If you discover a counterexample, do **not** bury it. Pivot immediately to a corrected conjecture, for example replacing tropical rank by Kapranov rank, factor rank, Barvinok rank, tropical corank, or a cut-restricted rank. Dead-end clearing is valuable science.

A plausible corrected variant is:

```lean
conjecture rootedSubset_divisorRank_ge_cutTropicalRank_sub_one
    ...
```

where `cutTropicalRank` is your new invariant restricted to minors induced by firing-compatible subsets.

---

## Proof Architecture: 3 Viable Strategies

You must pursue at least two of these, and explain in comments or markdown which appears strongest.

### Strategy A: Reduced divisors + principal minor combinatorics
1. Express `D_S` in the chip-firing lattice and analyze its `q`-reduced representative.
2. Show that for trees or nested cut families, the support of the reduced representative is controlled by the combinatorics of `S`.
3. Translate this support control into tropical dependence among rows/columns of `L_S`, yielding the bridge inequality.

**Why promising:** it respects the actual meaning of divisor rank rather than forcing a linear algebraic shadow too early.

---

### Strategy B: Kirchhoff/minor route through tropical nonsingularity
1. Use matrix-tree type results for principal minors of the Laplacian to identify when a minor is classically nonsingular.
2. Compare classical nonsingularity patterns with tropical nonsingularity of the same principal minor.
3. Deduce lower or upper bounds on tropical rank, then feed them into divisor-rank bounds via explicit firing constructions.

**Why promising:** this is the cleanest route for trees, unicyclic graphs, and block graphs. It is also the route most likely to generate a computational algorithm.

---

### Strategy C: Potential theory / Green’s function / generalized inverse
1. View chip-firing as discrete potential redistribution governed by the Laplacian.
2. Interpret `D_S` as a source-sink pattern concentrated on `S ∪ {q}`.
3. Use pseudoinverse or effective-resistance identities to identify “independent firing directions,” then show these constrain tropical rank.

**Why visionary:** this is the route that could connect graph Brill–Noether theory to statistical mechanics, resistor networks, and tropical Hodge theory.

**Most promising overall:** Strategy A for provable theorems now; Strategy B for strongest formal bridge statements; Strategy C for future field-opening conjectures.

---

## Catalog Building Blocks

You must explicitly build from the catalog references rather than reinventing basics:

- `Catalog/Tropical/FactorRank.lean`
  - mine this for existing tropical rank notions, factor rank lemmas, and any monotonicity/submatrix inheritance theorems;
  - if `tropicalRank` is already defined there, use it directly and prove comparison lemmas for principal minors.

- `Tropical/ChipFiring/Defs.lean`
  - use `divisorRank`, `laplacianDivisor`, and any existing reduced-divisor or chip-firing equivalence machinery;
  - prove your canonical family `rootedSubsetDivisor` integrates with these definitions.

You should also search for:
- graph Laplacian definitions in Mathlib,
- principal submatrix lemmas,
- determinant / matrix-tree statements,
- connectedness/tree APIs,
- finite set coercion lemmas to avoid low-level pain.

Do not merely cite these files. Build explicit theorem dependencies from them.

---

## Required Computational Method

You must produce a **verified algorithm or computational method**, not only theorem statements.

### Minimum algorithmic deliverables
1. A function computing `rootedSubsetDivisor`.
2. A function extracting `laplacianPrincipalMinor`.
3. A tropical rank computation procedure for small matrices.
4. A graph search procedure for all connected graphs on at most 7 vertices and all rooted subsets `S`.
5. A comparison routine checking the conjectural inequality.

If exact tropical rank is difficult to certify for all sizes, implement:
- exact search for tropical nonsingular `k × k` minors,
- or certified upper/lower bounds with explicit witness objects.

The algorithm should be accompanied by proved correctness lemmas for the core components.

---

## Demo Specification

Produce `demo.py` that:
- enumerates connected graphs on `n ≤ 7`,
- chooses a root `q`,
- computes `D_S`, `divisorRank G D_S`, and `tropicalRank(L_S)` for all `S`,
- reports:
  - all verified instances,
  - any counterexamples,
  - equality cases,
  - extremal families.

The demo must be interactive enough to let a reader inspect:
- a graph,
- a chosen root,
- the subset `S`,
- the principal minor,
- the divisor data,
- the computed inequality gap.

---

## Cross-Domain Connections You Must Surface

Do not leave these implicit. Make them explicit in theorem statements, markdown discussion, and examples.

### 1. Tropical geometry ↔ graph Brill–Noether theory
The divisor rank on a graph is the combinatorial shadow of linear series on tropical curves. A successful bridge theorem says tropical matrix rank is not merely analogous to linear series rank — it **computes or bounds it** in canonical graph families.

### 2. Combinatorial optimization ↔ matroid theory
Tropical rank is deeply tied to valuated matroids and independence structures. If principal Laplacian minors encode chip-firing independence, you are uncovering a matroidal skeleton of Baker–Norine rank.

### 3. Discrete physics ↔ Green’s functions / resistor networks
The Laplacian governs electrical flow, random walks, and Gaussian free fields. Any theorem linking divisor rank to Laplacian minor structure imports graph divisor theory into statistical mechanics and network science.

### 4. Spectral graph theory ↔ tropical linear algebra
Principal minors, nullspaces, and pseudoinverses are spectral objects; tropical rank is a piecewise-linear shadow of linear dependence. Their interaction may reveal a new “spectral tropicalization” program.

---

## Application Keywords

Include these keywords in your documentation and paper:

**Baker–Norine rank, chip-firing, tropical rank, Laplacian minor, matrix-tree theorem, principal minor, tropical linear algebra, graph Jacobian, valuated matroid, effective resistance, Green’s function, discrete potential theory, spectral graph theory, combinatorial Hodge theory, resistor networks**

---

## Concrete Scientific Questions to Drive the Work

Your `FUTURE_DIRECTIONS.md` must contain 3–5 **falsifiable** hypotheses with clear tests. At least one should be a sharpened form of the main conjecture, and at least one should concern equality cases.

Examples of acceptable hypotheses:

1. **Tree Exactness Hypothesis**  
   For every finite tree `G`, root `q`, and subset `S ⊆ V \ {q}`,  
   \[
   r(D_S) = \operatorname{tropRank}(L_S) - 1.
   \]
   **Test:** exhaustive computation on trees up to 12 vertices.

2. **Block Graph Stability Hypothesis**  
   The bridge inequality holds for all block graphs.  
   **Test:** enumerate all connected block graphs on at most 9 vertices.

3. **Cut-Closure Equality Hypothesis**  
   Equality holds exactly when `S` is a union of rooted cut-components relative to `q`.  
   **Test:** compare equality cases against cut decompositions for all graphs on at most 8 vertices.

4. **Resistance Defect Hypothesis**  
   The gap
   \[
   r(D_S) - (\operatorname{tropRank}(L_S)-1)
   \]
   is bounded below by a monotone function of the effective resistance diameter of `S ∪ {q}`.  
   **Test:** compute both quantities on graph families with known resistance profiles.

5. **Counterexample Localization Hypothesis**  
   If the naive conjecture fails, the smallest counterexample contains a biconnected non-series-parallel core.  
   **Test:** exhaustive search on graphs up to 8 vertices and decomposition analysis of failures.

These are real scientific hypotheses, not vague suggestions.

---

## Deliverables — All Mandatory

You must produce **all** of the following:

1. **Lean development** with at least 3 nontrivial theorems as above, minimizing `sorry`.
2. **A structured `FUTURE_DIRECTIONS.md`** with 3–5 falsifiable scientific hypotheses and explicit computational tests.
3. **A standalone `RESEARCH_PAPER.md`** explaining:
   - the theorem statements,
   - the conceptual bridge,
   - proof ideas,
   - computational evidence,
   - significance,
   - open problems.
   It must be readable without access to the code.
4. **An `ARTICLE.md`** in Scientific American style:
   - engaging,
   - accessible,
   - focused on the mathematics and scientific meaning,
   - absolutely not centered on formal verification machinery.
5. **A verified algorithm or computational method** for the conjecture search / bridge invariant computation.
6. **A `demo.py`** demonstrating the theory interactively on small graphs.

---

## Standard of Ambition

Do not settle for “some lemmas about divisors and minors.” Either:
- prove the bridge inequality in a genuinely meaningful graph class,
- or find the smallest obstruction and formulate the corrected invariant.

Both outcomes are field-opening:
- a proof yields a new computational lower-bound machine for graph divisor rank;
- a counterexample yields the birth of the correct tropical firing rank.

This project has the right shape to create a new subarea: **tropical spectral Brill–Noether theory on graphs**.

Go build the dictionary.

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
