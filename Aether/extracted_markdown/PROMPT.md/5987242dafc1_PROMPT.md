Soli Deo Gloria

## Assignment: Direction 1: Exact Weighted Tropical Dimension Formula

**Mode:** `prove`

Prove a genuinely new structural theorem in weighted tropical graph theory: an exact formula for the dimension of the weighted tropical kernel in terms of a weight-sensitive cycle invariant and a visibility defect term. This must not be a cosmetic weighted variant of an existing unweighted statement. The goal is to identify the *correct* weighted Betti-type invariant and prove that it exactly controls tropical kernel dimension.

Build explicitly on:

- `Pythagorean/TropicalBridge/WeightedTropicalHodge.lean`
  - especially the verified analogues of Theorems 3.4 and 3.9 governing generic-weight collapse and degeneracy-driven kernel membership,
- `Pythagorean/TropicalBridge/WeightedDefect.lean`
  - especially any defect decomposition or component-count formula already certified there.

Your mission is to discover and formalize the right notion of **weight-degeneracy cycle rank** and prove an exact dimension theorem.

---

## Core Mathematical Vision

The unweighted tropical dimension formula counts cycles and visible components of a graph. In the weighted world, this is false if one naïvely replaces the graph by its underlying combinatorial skeleton: generic weights destroy tropical ties, while repeated or resonant weights revive hidden cycle degrees of freedom. The correct invariant should therefore not be the ordinary first Betti number, but the first Betti number of a **degeneracy geometry** extracted from local weight ties.

The breakthrough theorem should show that tropical dimension is governed not by topology alone, but by topology filtered through valuation-like degeneracy. This is the weighted tropical analogue of passing from ordinary cohomology to a stratified or resonance cohomology theory.

If successful, this opens a new field: **weighted tropical Hodge theory on graphs**, with applications to divisor theory, metric graph moduli, optimization on weighted networks, and valuation-sensitive combinatorial geometry.

---

## Precise Theorem Target

You should define a new structure capturing the local tie geometry of weighted graphs relative to a basepoint `q` and vertex subset `S`.

### New definitions to introduce

At minimum, define:

1. **Weight degeneracy subgraph**  
   A subgraph whose edges are precisely those participating in a local tropical tie relevant to kernel formation.

   Possible formal object:
   ```lean
   structure WeightedTieSubgraph (G : SimpleGraph V) [Fintype V] where
     carrier : SimpleGraph V
     le_ambient : carrier ≤ G
     tie_cert : ∀ ⦃u v : V⦄, carrier.Adj u v → Prop
   ```

   But if a lighter-weight definition is more natural in the existing codebase, prefer that.

2. **Weighted first Betti number** `weightedBetti₁`
   This should be defined as the cycle rank of the tie/degeneracy subgraph:
   \[
   \beta_1^w(G,q,S) := |E_{\mathrm{tie}}| - |V_{\mathrm{tie}}| + c(E_{\mathrm{tie}})
   \]
   or an equivalent graph-theoretic rank notion already compatible with Mathlib.

3. **Weighted q-visible degeneracy component count** `weightedVisibleDefect`
   A weighted refinement of the existing `κ`-term, counting components that remain tropically invisible/degenerate from `q` relative to `S`.

4. **Weighted tropical kernel dimension** `weightedTropKernelDim`
   If this already exists in the catalog under another name, use the catalog name and prove equivalence lemmas rather than duplicating.

---

## Exact theorem statement

You should aim to prove a theorem of the following form, with all hypotheses made precise enough for Lean:

### Mathematical statement
For every finite weighted graph \(G\), basepoint \(q\), and distinguished subset \(S\),
\[
\dim_{\mathrm{trop}}(G,q,S)
=
\beta_1^w(G,q,S) + \kappa^w(G,q,S),
\]
where \(\beta_1^w\) is the first Betti number of the weight-degeneracy subgraph and \(\kappa^w\) counts weight-degenerate \(q\)-visible components.

Under generic weights, the tie subgraph is acyclic or empty, so
\[
\beta_1^w(G,q,S)=0,
\]
and the formula reduces to the generic weighted kernel theorem already in the catalog. Under fully uniform weights, the tie subgraph recovers the original graph (or the relevant visible subgraph), so
\[
\beta_1^w(G,q,S)=\beta_1(G,S),
\]
recovering the unweighted dimension formula.

### Lean 4 type signature target

You will need to adapt names/types to the actual catalog. A target of this shape is expected:

```lean
theorem weighted_tropical_kernel_dim_eq_weightedBetti_add_visibleDefect
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V)
    (w : Sym2 V → ℕ)
    (q : V) (S : Finset V)
    (hq : q ∈ S)
    :
    weightedTropKernelDim G w q S
      = weightedBetti₁ G w q S + weightedVisibleDefect G w q S
```

If the kernel is represented as a finite-dimensional module/submodule, the more refined theorem is even better:

```lean
theorem finrank_weightedTropKernel_eq_weightedBetti_add_visibleDefect
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V)
    (w : Sym2 V → ℕ)
    (q : V) (S : Finset V)
    (hS : S.Nonempty)
    :
    FiniteDimensional.finrank ℚ (weightedTropKernel G w q S)
      = weightedBetti₁ G w q S + weightedVisibleDefect G w q S
```

If the existing development uses `ℝ≥0`, `ℤ`, tropical semiring objects, or a custom kernel notion, match the ambient type exactly. Do not force `ℚ` unless it is already present.

---

## Mandatory theorem suite

Your file must contain at least **3 nontrivial theorems** with real proof structure. A suggested suite:

### Theorem A: Generic-weight collapse
Under a suitable genericity hypothesis, the tie subgraph has no cycle contribution.

```lean
theorem weightedBetti₁_eq_zero_of_generic
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) (w : Sym2 V → ℕ) (q : V) (S : Finset V)
    (hgen : WeightGeneric G w q S) :
    weightedBetti₁ G w q S = 0
```

This should build on the catalog theorem corresponding to generic weights eliminating nontrivial kernel directions.

### Theorem B: Uniform-weight recovery
When all relevant edges have the same weight, the weighted invariant recovers the ordinary one.

```lean
theorem weightedBetti₁_eq_betti₁_of_constant_weights
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) (w : Sym2 V → ℕ) (q : V) (S : Finset V)
    (hconst : IsConstantOnEdges G w) :
    weightedBetti₁ G w q S = ordinaryBetti₁Visible G q S
```

If `ordinaryBetti₁Visible` is not already defined, define it carefully or connect to the catalog’s existing cycle-rank invariant.

### Theorem C: Exact dimension formula
The main theorem.

```lean
theorem weighted_tropical_kernel_dim_formula
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) (w : Sym2 V → ℕ) (q : V) (S : Finset V)
    (hq : q ∈ S) :
    weightedTropKernelDim G w q S
      = weightedBetti₁ G w q S + weightedVisibleDefect G w q S
```

### Theorem D: Cross-domain theorem
You must include at least one theorem connecting this to another domain. Strong options:

#### Option 1: Matroid/rank theory
Show that `weightedBetti₁` is the nullity of a tie-incidence matrix or a cycle-space rank defect.

```lean
theorem weightedBetti₁_eq_nullity_tieIncidence
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) (w : Sym2 V → ℕ) (q : V) (S : Finset V) :
    weightedBetti₁ G w q S
      = tieIncidenceNullity G w q S
```

#### Option 2: Statistical physics / resistor networks
Interpret degeneracy cycles as zero-energy modes of a weighted Laplacian-like operator.

```lean
theorem weightedBetti₁_le_zeroModeMultiplicity
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) (w : Sym2 V → ℕ) (q : V) (S : Finset V) :
    weightedBetti₁ G w q S
      ≤ zeroModeMultiplicity (weightedTieLaplacian G w q S)
```

This is especially exciting because it links tropical degeneracy to constrained energy landscapes.

---

## Proof architecture: 3 viable strategies

You must not just state the theorem — choose a proof program. Here are three serious routes.

### Strategy 1: Degeneracy-subgraph decomposition
**Most promising if the catalog already isolates local tie edges.**

1. Define the tie subgraph `Tie(G,w,q,S)` using the local weight-equality criterion implicit in kernel membership theorems from `WeightedTropicalHodge.lean`.
2. Prove that every tropical kernel degree of freedom is supported on a connected component of this tie subgraph, and that each independent tie-cycle contributes one dimension.
3. Prove that the remaining contribution is exactly the weighted visible defect term from `WeightedDefect.lean`.
4. Conclude by additivity over connected components:
   \[
   \dim = (\text{cycle rank of tie subgraph}) + (\text{defect components}).
   \]

**Why this is promising:** it directly explains the theorem conceptually, and should align best with Theorems 3.4 and 3.9 if those already characterize kernel membership via degeneracy conditions.

### Strategy 2: Rank-nullity via weighted incidence matrices
**Best if the existing development has matrix encodings or finite-dimensional linear algebra.**

1. Encode weighted tropical constraints as a linearized compatibility matrix on candidate kernel functions.
2. Show that rows corresponding to non-tie edges are rank-forcing, while tie edges contribute only dependent constraints.
3. Identify the nullity as:
   \[
   |E_{\text{tie}}| - \operatorname{rank}(\partial_{\text{tie}})
   \]
   and rewrite this as a Betti-type quantity plus component defect.
4. Use a finite graph rank-nullity theorem to conclude the formula.

**Why this is promising:** it gives a canonical computational algorithm and naturally yields a verified procedure for `demo.py`.

### Strategy 3: Induction on edges with tie-preserving deletion-contraction
**Best if graph recursion is easier than matrix formalization.**

1. Prove the theorem for forests and single-cycle graphs.
2. Develop a weighted deletion-contraction principle:
   - deleting a non-tie edge preserves both sides,
   - contracting a tie edge reduces both dimension and weighted Betti term in sync.
3. Induct on the number of edges, splitting into tie/non-tie cases.
4. Handle visible defect carefully under component changes.

**Why this is promising:** it can produce elegant proofs and may reveal a Tutte-polynomial-like weighted tropical invariant. This is conceptually powerful, though formal bookkeeping may be harder.

**Recommendation:** Start with Strategy 1, then derive Strategy 2’s algorithm as a corollary. That combination gives both theorem and computation.

---

## How to use the catalog theorems

Do not cite the catalog abstractly. Build on it explicitly.

- From `WeightedTropicalHodge.lean`:
  - Use the theorem corresponding to “genericity kills kernel directions” to prove `weightedBetti₁_eq_zero_of_generic`.
  - Use the theorem corresponding to “degenerate local ties force kernel membership” to show every tie-cycle produces a nontrivial kernel vector.
- From `WeightedDefect.lean`:
  - Extract the structural defect term and prove it equals your `weightedVisibleDefect`.
  - If the defect theorem already gives a lower/upper bound for kernel dimension, use it as one half of the exact formula and prove the complementary inequality using the tie-subgraph cycle rank.

A strong result would be to prove two inequalities separately:

```lean
theorem weightedBetti_add_visibleDefect_le_kernelDim ...
theorem kernelDim_le_weightedBetti_add_visibleDefect ...
```

and then combine them.

This forces deeper proof tactics and avoids superficial automation.

---

## Required new definitions and concepts

You must introduce at least one genuinely new notion not already present in the catalog. Good candidates:

- `TieEdge`: edge participating in a local tropical weight tie;
- `weightedTieSubgraph`;
- `weightedBetti₁`;
- `qVisibleTieComponent`;
- `tieIncidenceMatrix`;
- `weightedResonanceClass`.

A particularly strong concept is:

```lean
def TieEdge
    {V : Type*} [DecidableEq V]
    (G : SimpleGraph V) (w : Sym2 V → ℕ) (q : V) (S : Finset V) :
    Sym2 V → Prop := ...
```

with a theorem connecting `TieEdge` to kernel support.

---

## Cross-domain connections you should explicitly develop

At least one theorem must bridge to another field. Strong possibilities:

1. **Matroid theory / combinatorial Hodge theory**
   - `weightedBetti₁` as nullity of a weighted cycle-space representation.
   - Opens a path to valuation-sensitive matroids.

2. **Spectral graph theory / physics**
   - Tie cycles as zero modes of a constrained weighted Laplacian.
   - Opens interpretation as frustration-free states or resonant transport modes.

3. **Algebraic geometry / valuation theory**
   - The tie subgraph behaves like the support of an initial degeneration.
   - This suggests a graph-theoretic model of Berkovich skeleta with resonance strata.

4. **Optimization / network science**
   - Weighted tropical kernel dimension predicts multiplicity of shortest-path degeneracies.
   - This is relevant to routing, transportation, and min-plus control.

You should mention these connections in the paper and formalize at least one theorem-level bridge.

---

## Falsifiable conjecture with computational test

You must include at least one explicit conjecture and a brute-force test capable of disproving it.

### Recommended conjecture
For every finite weighted graph \(G\), the weighted tropical kernel dimension equals the cycle rank of the *maximal tie subgraph visible from \(q\)* plus the weighted visible defect.

```lean
def MaxVisibleTieSubgraph ... := ...

conjecture visible_tie_formula
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) (w : Sym2 V → ℕ) (q : V) (S : Finset V) :
    weightedTropKernelDim G w q S
      = cycleRank (MaxVisibleTieSubgraph G w q S)
        + weightedVisibleDefect G w q S
```

### Computational test
Enumerate all connected graphs on `4` and `5` vertices and all edge weights in `{1,2,3,4,5}`:
- compute `weightedTropKernelDim` by brute-force kernel search or certified rank computation,
- compute candidate invariants for several definitions of tie subgraph,
- output the first counterexample if equality fails.

This is scientifically valuable because it can distinguish the *correct* definition of `weightedBetti₁`.

---

## Lean deliverables

Produce a new Lean file, likely of the form:

`Pythagorean/TropicalBridge/ExactWeightedTropicalDimension.lean`

unless the local project structure suggests a better location.

The file must contain:

- at least one new definition,
- at least 3 nontrivial theorems,
- proofs using induction, `rcases`, `by_contra`, `field_simp` where appropriate, and/or multi-step `calc`,
- minimal `sorry` usage,
- explicit imports from the catalog files above.

Do not settle for toy lemmas. The main theorem must be structurally meaningful.

---

## Verified algorithm / computational method

You must produce a verified algorithm, not just theorem statements.

### Required algorithm
A procedure computing the candidate right-hand side:
1. construct the tie subgraph,
2. compute its connected components,
3. compute cycle rank / weighted Betti,
4. compute weighted visible defect,
5. return the predicted kernel dimension.

Then prove:

```lean
theorem algorithm_correct
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) (w : Sym2 V → ℕ) (q : V) (S : Finset V) :
    weightedKernelDimAlgorithm G w q S
      = weightedTropKernelDim G w q S
```

If full generality is too heavy, first prove correctness for a substantial class:
- connected graphs,
- or graphs with decidable tie structure,
- or graphs with bounded support.

But push as far as possible.

---

## demo.py requirements

Write `demo.py` that:

1. generates or accepts a small weighted graph,
2. computes:
   - the tie subgraph,
   - `weightedBetti₁`,
   - `weightedVisibleDefect`,
   - predicted dimension,
   - brute-force/independent kernel dimension,
3. displays agreement or produces a counterexample.

The demo should allow:
- random graph generation,
- exhaustive search on small `n`,
- printing the first violating example for any candidate definition.

This is not auxiliary — it is part of the scientific loop.

---

## Research significance

If you prove this theorem, you will have created a valuation-sensitive dimension theory for tropical graph kernels. That is a serious conceptual advance.

It would mean:

- tropical kernel dimension is not merely combinatorial topology,
- weight resonance creates a new cohomological layer,
- genericity and full degeneracy are just the two endpoints of a unified theory.

This opens the possibility of:
- weighted tropical Riemann–Roch,
- resonance stratifications on graph moduli,
- tropical divisor theory with valuations,
- shortest-path degeneracy invariants in optimization,
- spectral/tropical correspondences for weighted networks.

This is exactly the kind of result that can define a new subfield rather than extend an old lemma.

---

## Application keywords

Weighted tropical geometry; tropical Hodge theory; graph cohomology; Baker–Norine analogue; valuation-sensitive Betti numbers; degeneracy subgraphs; min-plus linear algebra; spectral graph theory; matroid nullity; resonance varieties; shortest-path degeneracy; network optimization; combinatorial Laplacians; Berkovich skeleta; tropical divisor theory.

---

## Mandatory non-Lean deliverables

You must also produce **all** of the following:

### 1. `FUTURE_DIRECTIONS.md`
Give 3–5 original research directions. Each direction must include:
- a sentence beginning **“The key insight is...”**
- a sentence beginning **“Why now?”**

At least one direction must bridge to a different domain, such as spectral graph theory, valuation theory, optimization, or statistical physics.

### 2. `RESEARCH_PAPER.md`
A standalone scientific paper explaining:
- the exact weighted tropical dimension formula,
- the new definitions,
- why the result is conceptually new,
- proof ideas,
- computational evidence,
- open problems.

Someone reading only this document must understand the discovery without access to the code.

### 3. `ARTICLE.md`
Write this in **Scientific American** style:
- vivid,
- accessible,
- idea-centered,
- broad audience.

Taboo: do **not** focus on formal verification machinery. Explain the mathematics and why it matters.

### 4. Verified algorithm
As above: a certified computational method, not merely theorem statements.

### 5. `demo.py`
Interactive or script-based demonstration of the theorem and conjecture testing.

---

## Final standard

Do not return an incremental variant. Either identify the correct weighted Betti invariant and prove the formula, or discover a counterexample that forces a sharper invariant. In either case, the outcome must be mathematically illuminating.

The bar is: a research mathematician should say, “I had not realized tropical kernel dimension was controlled by a resonance subgraph.”

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
