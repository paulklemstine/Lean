Soli Deo Gloria

## Assignment: Direction 3 — Weighted Tropical Hodge Extension

**Mode: prove**

Aristotle, do not treat this as a parameterized variant of an existing unweighted statement. The real target is to found a **weighted tropical graph Hodge theory** in which cycle spaces are replaced by **valuated cycle spaces**, and visibility from a basepoint is controlled by weighted geodesic degeneracy. The unweighted formula should emerge as the measure-zero shadow of a richer phenomenon. The breakthrough is not “the same theorem with weights”; it is the discovery that the tropical kernel dimension is governed by a new combinatorial invariant sitting between graph homology, shortest-path degeneracy, and valuated matroid theory.

Your task is to isolate the correct weighted invariants, prove their structural properties, and then establish a dimension theorem with computational content.

---

## Core Mathematical Vision

Let `G` be a finite graph with distinguished vertex `q` and vertex subset `S`. In the unweighted setting, catalog results in `Pythagorean/TropicalBridge/TropicalHodge.lean` suggest that tropical harmonicity on `S` is controlled by cycle and component indicator vectors. In the weighted setting, the tropical Laplacian row condition becomes:

> for each constrained vertex `i ∈ S`, the minimum of the quantities  
> `w(i,j) + v(j)` over neighbors `j` of `i` is attained at least twice.

This is no longer ordinary graph homology. It is a **min-plus balancing law with valuations**. The correct dimension count should detect:
1. cycles whose edge-weight valuations permit a balanced min-attainment around the loop, and
2. components whose weighted access to `q` is non-unique in the tropical sense.

The field-opening insight is this:

> **Weighted tropical kernel dimension is a graph-theoretic shadow of valuated matroid rank deficiency.**

If proved cleanly, this creates a bridge from discrete Hodge theory to tropical linear spaces, shortest-path degeneracy, and optimization on networks.

---

## Precise Theorem Targets

You must introduce at least one genuinely new definition, and it should be mathematically meaningful rather than a coding convenience.

### New definitions to introduce

Define a weighted graph structure and weighted tropical harmonicity notion. A possible Lean-facing design:

```lean
structure WeightedGraph (V : Type*) [Fintype V] where
  Adj : V → V → Prop
  symm : Symmetric Adj
  loopless : Irreflexive Adj
  w : V → V → ℤ
  w_symm : ∀ ⦃u v⦄, Adj u v → w u v = w v u
```

Define the weighted tropical local minimum multiplicity at a vertex:
```lean
def weightedNbrVals (G : WeightedGraph V) (v : V → ℤ) (i : V) : Finset ℤ := ...
def tropBalancedAt (G : WeightedGraph V) (v : V → ℤ) (i : V) : Prop := ...
```

where `tropBalancedAt G v i` means the minimum of `G.w i j + v j` over neighbors `j` is achieved at least twice.

Define:
```lean
def weightedTropKernelOn (G : WeightedGraph V) (S : Finset V) : Set (V → ℤ) :=
  {v | ∀ i ∈ S, tropBalancedAt G v i}
```

Then define a weighted cycle compatibility invariant. You may need to choose the right notion experimentally before proving the final theorem. One candidate:

- a cycle is **weight-compatible** if, after transporting vertex potentials along the cycle by edge weights, the induced min-plus constraints are globally consistent and at every cycle vertex the minimum is attained by the two incident cycle edges.

A Lean signature for a first structural theorem might look like:

```lean
def WeightCompatibleCycle (G : WeightedGraph V) (C : Finset V) : Prop := ...
def beta1w (G : WeightedGraph V) (S : Finset V) : Nat := ...
def kappaw (G : WeightedGraph V) (q : V) (S : Finset V) : Nat := ...
```

### Theorem 1 — Weighted cycle vectors lie in the tropical kernel
This theorem should be nontrivial and proved by explicit local analysis around each cycle vertex.

```lean
theorem weightCompatibleCycle_gives_kernel_vector
  (G : WeightedGraph V) [DecidableEq V] [Fintype V]
  (S C : Finset V) (hC : WeightCompatibleCycle G C) (hCS : C ⊆ S) :
  ∃ v : V → ℤ, v ∈ weightedTropKernelOn G S := ...
```

**Meaning:** every weight-compatible cycle produces a tropical harmonic potential on `S`. This is the weighted replacement for the unweighted cycle-indicator theorem.

### Theorem 2 — Weighted visible components contribute kernel directions
Formalize weighted `q`-visibility using shortest-path degeneracy or generic access weight.

A possible definition:

```lean
def qVisibleWeightedComponent (G : WeightedGraph V) (q : V) (T : Finset V) : Prop := ...
```

Then prove:

```lean
theorem weighted_component_indicator_in_kernel
  (G : WeightedGraph V) [DecidableEq V] [Fintype V]
  (q : V) (S T : Finset V)
  (hT : qVisibleWeightedComponent G q T) (hTS : T ⊆ S) :
  ∃ v : V → ℤ, v ∈ weightedTropKernelOn G S := ...
```

**Meaning:** weighted geodesic degeneracy from `q` produces additional tropical harmonic directions.

### Theorem 3 — Generic weights recover the unweighted invariants
You need a theorem making precise that in the absence of tropical degeneracies, the weighted theory collapses to the ordinary one.

```lean
def GenericWeights (G : WeightedGraph V) : Prop :=
  ∀ ⦃i j k⦄, G.Adj i j → G.Adj i k → j ≠ k →
    G.w i j ≠ G.w i k

theorem genericWeights_beta1w_eq_beta1
  (G : WeightedGraph V) [DecidableEq V] [Fintype V] (S : Finset V)
  (hgen : GenericWeights G) :
  beta1w G S = beta1 (G := ...) S := ...

theorem genericWeights_kappaw_eq_kappa
  (G : WeightedGraph V) [DecidableEq V] [Fintype V] (q : V) (S : Finset V)
  (hgen : GenericWeights G) :
  kappaw G q S = kappa (G := ...) q S := ...
```

This is where you make mathematically precise whether “generic” means pairwise distinct incident edge weights, or a stronger no-coincidence condition on path valuations. Be honest: if the stronger condition is needed, define it and prove with that.

### Theorem 4 — Dimension lower bound, and then exact formula under a clean hypothesis
Do not overreach too early. First prove a lower bound from explicit independent constructions. Then prove equality under a robust hypothesis such as weighted-cycle/component decomposition.

```lean
theorem weighted_tropKernel_dim_lower_bound
  (G : WeightedGraph V) [DecidableEq V] [Fintype V]
  (q : V) (S : Finset V) :
  beta1w G S + kappaw G q S ≤
    finrank ℤ (weightedTropLinearSpace G S) := ...
```

Then the exact theorem, possibly under a decomposition hypothesis:

```lean
theorem weighted_tropKernel_dim_formula
  (G : WeightedGraph V) [DecidableEq V] [Fintype V]
  (q : V) (S : Finset V)
  (hdecomp : WeightedTropDecomposable G q S) :
  finrank ℤ (weightedTropLinearSpace G S) =
    beta1w G S + kappaw G q S := ...
```

If the exact equality over `ℤ` is technically awkward because the tropical kernel is not literally a linear submodule in the ordinary sense, then define the correct **combinatorial dimension** of the family of normalized solutions, and state the theorem in those terms. What matters is not forcing a bad formalization, but capturing the right invariant.

### Theorem 5 — Cross-domain theorem: shortest-path degeneracy ↔ tropical kernel growth
This is mandatory for the cross-domain requirement.

```lean
theorem shortestPathDegeneracy_increases_weighted_trop_dimension
  (G : WeightedGraph V) [DecidableEq V] [Fintype V]
  (q : V) (S : Finset V) :
  shortestPathDegeneracyCount G q S ≤ kappaw G q S := ...
```

This connects tropical graph Hodge theory to **metric graph theory / combinatorial optimization**.

---

## Recommended Lean 4 Type Signatures

You are not required to use these exact names, but your theorem statements should be comparably precise and machine-meaningful.

```lean
structure WeightedGraph (V : Type*) [Fintype V] where
  Adj : V → V → Prop
  symm : Symmetric Adj
  loopless : Irreflexive Adj
  w : V → V → ℤ
  w_symm : ∀ ⦃u v⦄, Adj u v → w u v = w v u

def tropBalancedAt (G : WeightedGraph V) (φ : V → ℤ) (i : V) : Prop := ...
def weightedTropKernelOn (G : WeightedGraph V) (S : Finset V) : Set (V → ℤ) := ...

def WeightCompatibleCycle (G : WeightedGraph V) (C : Finset V) : Prop := ...
def beta1w (G : WeightedGraph V) (S : Finset V) : Nat := ...

def qVisibleWeightedComponent (G : WeightedGraph V) (q : V) (T : Finset V) : Prop := ...
def kappaw (G : WeightedGraph V) (q : V) (S : Finset V) : Nat := ...

def GenericWeights (G : WeightedGraph V) : Prop := ...

theorem weightCompatibleCycle_gives_kernel_vector
  (G : WeightedGraph V) [DecidableEq V] [Fintype V]
  (S C : Finset V) :
  WeightCompatibleCycle G C → C ⊆ S →
  ∃ φ : V → ℤ, φ ∈ weightedTropKernelOn G S := ...

theorem weighted_component_indicator_in_kernel
  (G : WeightedGraph V) [DecidableEq V] [Fintype V]
  (q : V) (S T : Finset V) :
  qVisibleWeightedComponent G q T → T ⊆ S →
  ∃ φ : V → ℤ, φ ∈ weightedTropKernelOn G S := ...

theorem genericWeights_recover_unweighted_formula
  (G : WeightedGraph V) [DecidableEq V] [Fintype V]
  (q : V) (S : Finset V) :
  GenericWeights G →
  weightedTropDim G q S = beta1 G S + kappa G q S := ...
```

If you discover that the conjectured equality is false as stated, pivot immediately to **counterexample + corrected theorem**. That would still be a breakthrough if the corrected invariant is conceptually right.

---

## Proof Architecture: 3 Viable Strategies

### Strategy A — Constructive local balancing via weighted potentials
**Most promising for the first three theorems.**

1. **Define explicit potentials on cycles/components.**  
   For a cycle, choose a base vertex and define `φ` by cumulative edge weights along the cycle so that the two cycle neighbors of each cycle vertex produce equal values of `w(i,j)+φ(j)`.  
   For components, define `φ` using weighted distance to the boundary or to `q`.

2. **Prove local double-attainment at each constrained vertex.**  
   This will require multi-step `calc`, `rcases` on neighborhood structure, and careful case splits distinguishing vertices on/off the support. This is where the proof becomes nontrivial.

3. **Extract independence / dimension contribution.**  
   Normalize potentials at `q` or another base vertex, then prove distinct cycle/component supports give distinct normalized kernel directions.

Why this is promising: it aligns with the existing catalog constructions `cycleIndicator` and `componentIndicator`, but forces a genuinely new weighted balancing computation rather than a cosmetic rewrite.

### Strategy B — Tropical linear algebra / valuated matroid route
**Most visionary; best for the exact dimension theorem if Strategy A reveals the right invariant.**

1. Interpret each row condition of the weighted tropical Laplacian as a tropical hyperplane condition.
2. Show the solution set is a tropical linear space associated to a valuated incidence/cycle matroid.
3. Identify `beta1w + kappaw` as the tropical rank defect / dimension of that valuated linear space.

Why this matters: if successful, this turns your theorem from a graph fact into a theorem in tropical linear geometry. It would strongly justify the significance claim and connect directly to valuated matroids.

Risk: formalization overhead is higher unless Mathlib support is already sufficient. Use this as the conceptual guide even if the final Lean proof is more combinatorial.

### Strategy C — Reduction to shortest-path degeneracy and min-plus Bellman equations
**Best for the cross-domain theorem and for discovering corrections to the conjecture.**

1. Rewrite `tropBalancedAt` as a statement about multiple minimizing predecessors in a weighted Bellman operator.
2. Characterize kernel vectors as potentials for which every `i ∈ S` has at least two optimal predecessor choices.
3. Relate the number of independent such degeneracies to shortest-path tie structure, cycle ties, and component access ties.

Why this is powerful: it connects directly to algorithms, lets you test the conjecture computationally, and may reveal that the right invariant is not “minimum-weight edge achieved twice on a cycle” but something like “cycle valuation has at least two geodesically minimizing breakpoints.”

---

## Building Directly on Catalog Theorems

Use the catalog as scaffolding, not as a crutch.

- From `Pythagorean/TropicalBridge/Defs.lean`, leverage the min-plus semantics around `TropicalVal` / `tropMul` to encode weighted transport of potentials.
- From `Pythagorean/TropicalBridge/TropicalHodge.lean`, inspect `cycleIndicator` and `componentIndicator` and identify the exact lemma where unweighted equality of two local minima is proved. Replace the unweighted “two neighbors contribute equally” argument by a weighted cumulative-balance lemma.
- If there is already a kernel-membership theorem for indicators, generalize the **proof pattern**, not the statement. The weighted case should introduce a new transport identity:
  \[
  w(i,j_1)+\phi(j_1)=w(i,j_2)+\phi(j_2),
  \]
  where `j₁, j₂` are the two distinguished balancing neighbors at vertex `i`.

A likely indispensable intermediate lemma:

```lean
lemma weighted_cycle_balance
  (G : WeightedGraph V) (φ : V → ℤ) (i j k : V)
  (hij : G.Adj i j) (hik : G.Adj i k) :
  φ j - φ k = G.w i k - G.w i j →
  G.w i j + φ j = G.w i k + φ k := by
  ...
```

This is nontrivial enough to require algebraic reasoning (`linarith` if available over integers, otherwise explicit rearrangement with `calc`).

---

## What Would Count as a Genuine Breakthrough

A merely acceptable outcome is: “here is a weighted variant under strong assumptions.”  
A breakthrough outcome is one of the following:

1. **Exact weighted dimension theorem with the correct invariant**  
   even if the original conjectural `β₁^w` needs to be replaced.

2. **Counterexample + corrected invariant**  
   showing that naive local edge-weight multiplicity is insufficient, and the true invariant depends on weighted cycle valuation or shortest-path tie structure.

3. **Equivalence with a valuated matroid notion**  
   making weighted tropical graph Hodge theory part of tropical linear geometry.

4. **Algorithmic characterization**  
   reducing weighted tropical kernel dimension to counting independent degeneracies in shortest-path DAGs or weighted cycle spaces.

Any one of these would open a new field line.

---

## Cross-Domain Connections You Must Exploit

At least one theorem and the paper exposition must explicitly connect this work to another domain.

### 1. Tropical geometry / valuated matroids
Weighted cycle compatibility is a graph-level manifestation of valuation data on circuits. This suggests `beta1w` is a graph-theoretic approximation to a valuated circuit rank statistic.

### 2. Combinatorial optimization / shortest paths
The condition “minimum attained at least twice” is exactly a **path degeneracy** phenomenon. Weighted tropical harmonicity is therefore related to multiplicity of optimal routes in transportation and routing networks.

### 3. Statistical physics / energy landscapes
A weighted potential `φ` can be viewed as an energy correction, and balanced minima correspond to local metastable degeneracy. This is speculative but excellent material for the broad article.

### 4. Network science / resilience
Components with multiple equally good weighted access routes to `q` represent robust communication regions. The kernel dimension may become a **resilience index** for weighted infrastructure networks.

---

## Computational Conjecture and Falsifiable Prediction

You must state at least one falsifiable conjecture, and it must be stronger than the initial prose. Here is a sharpened version:

> **Conjecture (generic-exactness / degeneracy-jump law).**  
> For every finite weighted graph `G`, basepoint `q`, and subset `S`,  
> `weightedTropDim G q S ≥ beta1 G[S] + kappa G q S`,  
> with equality for generic weights, and strict inequality if and only if there exists either  
> (i) a cycle in `G[S]` with at least two distinct balancing transports yielding the same tropical valuation, or  
> (ii) a component of `G \ S` with at least two equal-weight optimal access routes to `q`.

This is falsifiable by exhaustive search on `n ≤ 6`.

A second conjecture, even more interesting:

> **Conjecture (valuated matroid equivalence).**  
> `weightedTropDim G q S` equals the dimension of the tropical linear space of a valuated graphic matroid restricted to constraints indexed by `S`.

If this fails computationally, the failure mode itself will reveal the correct replacement object.

---

## Algorithmic Deliverable

You must produce a **verified computational method**, not just theorem statements.

### Required algorithm
Implement an algorithm that, for small finite weighted graphs:
1. enumerates integer-valued potentials `φ` in a normalized range,
2. checks `tropBalancedAt` on all vertices in `S`,
3. computes the observed normalized tropical kernel dimension,
4. computes candidate invariants `beta1w` and `kappaw`,
5. searches for counterexamples to naive formulations,
6. outputs the first obstruction certificate if equality fails.

The key scientific value is not brute force alone, but using computation to refine the invariant. Your `demo.py` should allow the user to:
- input a small weighted graph,
- visualize candidate balanced cycles / visible components,
- compare predicted and observed dimensions,
- toggle perturbations of edge weights to see generic vs degenerate behavior.

---

## Nontrivial Proof Expectations

Your Lean file must contain **at least 3 theorems** proved with genuinely mathematical tactics and structure:
- induction over path/cycle length,
- `rcases` decomposition of local graph structure,
- `by_contra` to rule out unique minima,
- `field_simp` if rational weights are used in an auxiliary theorem,
- multi-step `calc` chains for weighted equality transport.

Do not waste a theorem slot on tautologies or finite enumeration artifacts.

A strong trio would be:
1. weighted cycle balance lemma,
2. cycle-generated kernel theorem,
3. generic weights recover unweighted theorem,
4. shortest-path degeneracy implies extra kernel dimension.

---

## Suggested File-Level Structure

Create a focused Lean development, for example:

- `Pythagorean/TropicalBridge/WeightedDefs.lean`
- `Pythagorean/TropicalBridge/WeightedHodge.lean`
- `Pythagorean/TropicalBridge/WeightedExamples.lean`

Possible organization:
1. definitions of weighted graph and tropical balancing,
2. local balancing lemmas,
3. cycle/component constructions,
4. genericity lemmas,
5. dimension theorem or corrected theorem,
6. explicit examples and counterexamples.

---

## Application Keywords

tropical graph Hodge theory, weighted Laplacian, min-plus algebra, valuated matroids, tropical linear spaces, shortest-path degeneracy, network resilience, metric graph theory, combinatorial optimization, energy landscapes, discrete geometry, transportation networks, communication routing, molecular graph models

---

## Mandatory Deliverables

You must produce **all** of the following:

1. **`FUTURE_DIRECTIONS.md`**  
   Give **3–5 original research directions**, each written as prose and each containing the exact sentences:
   - **“The key insight is...”**
   - **“Why now?”**
   
   At least one direction must bridge to a different domain, such as optimization, physics, or algebraic geometry.

2. **`RESEARCH_PAPER.md`**  
   A standalone scientific paper. A reader with no access to code must understand:
   - the weighted tropical kernel problem,
   - the new definitions,
   - the main theorem or corrected theorem,
   - why it matters,
   - what computations support it,
   - what the next conjectures are.

3. **`ARTICLE.md`**  
   Written in **Scientific American** style. Explain the mathematics and its significance for a broad audience.  
   **Do not focus on formal verification or proof assistants.** Focus on the ideas: weighted networks, degeneracy, tropical balancing, and why this reveals hidden structure.

4. **A verified algorithm or computational method**  
   It must compute or certify the weighted tropical kernel dimension / obstruction data for small graphs.

5. **`demo.py`**  
   An interactive demonstration of the result. It should let a user experiment with weighted graphs, perturb weights, and observe when the dimension jumps.

---

## Final Charge

Do not merely “generalize” the old theorem. Determine whether the conjectured `β₁^w + κ^w` formula is truly correct. If it is, prove it in a structurally illuminating way. If it is not, find the exact correction and formalize that instead. The deepest possible outcome is to show that weighted tropical harmonicity on graphs is controlled not by plain homology, but by **valuated degeneracy data** — a new invariant at the crossroads of tropical geometry and network optimization. That is the theorem worth discovering.

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
