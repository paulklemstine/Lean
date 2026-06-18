Soli Deo Gloria

## Assignment: Direction 1: Weighted Distance Equality via Tropical Cycle Optimization

**Mode:** prove

Prove genuinely new theorems at the interface of tropical Morse theory, weighted graph optimization, and quantum CSS code geometry. This must not be a cosmetic weighted variant of the unweighted story: the goal is to isolate the exact structural mechanism by which weighted cycle formation controls code distance, and to formalize an algorithmic principle that could matter for non-uniform quantum hardware.

Build explicitly on:

- `Pythagorean/TropicalMorse/QuantumGraphCodes.lean`:
  - `codeDistance_eq_firstCycleBirth_of_simpleCycle`
- `Pythagorean/TropicalMorse/Theorems.lean`:
  - `redundant_edges_eq_cycle_rank`

The conceptual leap is this: in the unit-weight case, “first cycle birth” is a combinatorial event. In the weighted case, it should become a **tropical optimization invariant**. The theorem you should aim for is that, under an appropriate cycle-aware filtration, the first non-tree obstruction appears exactly at the weighted systole of the graph. If true, this creates a mathematically clean bridge from persistent-style graph filtrations to weighted quantum code distance.

---

## Central Objects to Introduce

You must define at least one genuinely new concept not already present in the catalog. The most promising is a cycle-aware filtration score.

### New definition 1: minimum cycle support weight of an edge
For a weighted graph `G` with edge weight function `w : E → ℝ≥0`, define the **cycle support weight** of an edge `e` by
\[
\operatorname{csw}_G(e) := \inf \{ \sum_{e' \in C} w(e') \mid C \text{ is a simple cycle of } G,\ e \in C \}.
\]
When no simple cycle contains `e`, set `csw_G(e) = ⊤` or a designated sentinel.

This is the local tropical shadow of the global weighted systole.

### New definition 2: girth-adapted filtration
Order edges by the lexicographic key
\[
e \mapsto (\operatorname{csw}_G(e),\ w(e),\ \text{tie-breaker}),
\]
and let the induced filtration be the **girth-adapted filtration**.

This is not merely Kruskal by raw weight; it is a filtration informed by latent cycle geometry.

### New definition 3: weighted first cycle birth
For an edge ordering `σ`, define the **weighted first cycle birth value**
as the total weight of the unique cycle created when the first redundant edge is inserted, or equivalently the minimum cycle weight among cycles realizable at the first non-forest stage.

This quantity should be stated carefully so that it is mathematically robust and implementable.

---

## Precise Theorem Targets

You must formalize at least 3 substantial theorems. Here is the target package.

### Theorem A: weighted systolic realization by cycle-adapted birth
For a finite simple graph with positive edge weights, if every edge belonging to a minimum-weight simple cycle is ordered before every edge whose cycle support weight is strictly larger, then the first cycle birth value equals the minimum total weight of a simple cycle.

#### Mathematical statement
Let `G` be a finite simple graph, let `w : E(G) → ℝ≥0` with `0 < w e` for all edges, and let
\[
\operatorname{mwsc}(G,w) := \min\left\{ \sum_{e\in C} w(e) \;\middle|\; C \text{ a simple cycle in } G \right\}.
\]
If `σ` is a girth-adapted filtration, then
\[
\operatorname{firstCycleBirthValue}(G,w,\sigma)=\operatorname{mwsc}(G,w).
\]

#### Lean 4 target signature sketch
```lean
theorem firstCycleBirthValue_eq_minSimpleCycleWeight_of_girthAdapted
  {V E : Type*} [Fintype V] [DecidableEq V]
  (G : SimpleGraph V)
  (w : Sym2 V → ℝ≥0)
  (hw_pos : ∀ e, 0 < w e)
  (hcyc : ∃ C, IsSimpleCycle G C)
  (σ : List (Sym2 V))
  (hσ : IsGirthAdaptedOrder G w σ) :
  firstCycleBirthValue G w σ = minSimpleCycleWeight G w
```

If `Sym2 V` is not the right edge model in the local graph API, adapt accordingly, but preserve the theorem’s mathematical content exactly.

### Theorem B: weighted code distance equals weighted systole for graph-derived CSS codes
Define a weighted notion of code distance for graph-derived CSS codes in which the cost of a logical operator is the sum of edge weights in its support. Then prove that for the graph family covered by the unweighted theorem, the weighted code distance equals the minimum weight of a simple cycle.

#### Mathematical statement
For a graph-derived CSS code `Q(G)`, under the same simplicity hypotheses as in `codeDistance_eq_firstCycleBirth_of_simpleCycle`,
\[
d_w(Q(G)) = \operatorname{mwsc}(G,w).
\]

This is the real breakthrough theorem: it says hardware non-uniformity can be absorbed into a clean topological-combinatorial invariant.

#### Lean 4 target signature sketch
```lean
theorem weightedCodeDistance_eq_minSimpleCycleWeight
  {V : Type*} [Fintype V] [DecidableEq V]
  (G : SimpleGraph V)
  (w : Sym2 V → ℝ≥0)
  (hw_pos : ∀ e, 0 < w e)
  (hG : GraphCodeAdmissible G) :
  weightedCodeDistance G w = minSimpleCycleWeight G w
```

You may need an intermediate theorem connecting `weightedCodeDistance` to `firstCycleBirthValue` under a girth-adapted filtration:
```lean
theorem weightedCodeDistance_eq_firstCycleBirthValue_of_girthAdapted
  ...
```

### Theorem C: structural obstruction theorem
If the naive raw-weight Kruskal filtration fails to realize the minimum simple cycle weight, then there exists a specific obstruction: a minimum-weight cycle contains an edge whose insertion is delayed by a lower-weight bridge-dominated prefix that creates a heavier cycle first.

This theorem matters because the conjecture is not merely “Kruskal should work”; it predicts exactly why it can fail and why cycle-adaptation repairs it.

#### Mathematical statement
If
\[
\operatorname{firstCycleBirthValue}_{\mathrm{Kruskal}}(G,w) \neq \operatorname{mwsc}(G,w),
\]
then there exists a minimum-weight simple cycle `C*` and an edge `e ∈ C*` such that before `e` is processed, the filtration has already privileged a path structure forcing the first redundant edge to close a cycle of strictly larger total weight.

#### Lean 4 target signature sketch
```lean
theorem exists_obstruction_of_kruskal_failure
  {V : Type*} [Fintype V] [DecidableEq V]
  (G : SimpleGraph V)
  (w : Sym2 V → ℝ≥0)
  (hw_pos : ∀ e, 0 < w e)
  (hfail : kruskalFirstCycleBirthValue G w ≠ minSimpleCycleWeight G w) :
  ∃ C e, IsSimpleCycle G C ∧ e ∈ C.edgeSet ∧
    cycleWeight w C = minSimpleCycleWeight G w ∧
    EdgeObstruction G w C e
```

This theorem is the right place to use contradiction, decomposition into cases, and careful graph induction.

### Theorem D: cycle rank compatibility with weighted birth
Use `redundant_edges_eq_cycle_rank` as a structural backbone: prove that the count of redundant edges is unchanged by weighting, while the **location** of first redundancy in the filtration detects weighted systole under cycle-adapted orderings.

#### Lean 4 target signature sketch
```lean
theorem redundantEdgeCount_invariant_under_weighting
  {V : Type*} [Fintype V] [DecidableEq V]
  (G : SimpleGraph V) (w₁ w₂ : Sym2 V → ℝ≥0) :
  redundantEdgeCount G w₁ = redundantEdgeCount G w₂
```

and then

```lean
theorem firstRedundantEdge_detects_weightedSystole_of_girthAdapted
  ...
```

This theorem gives the conceptual synthesis: cycle rank is topological; first birth value is tropical.

---

## Why this would be a breakthrough

The existing unit-weight theorem identifies code distance with a combinatorial cycle invariant. That is already elegant. But real hardware does not live in the unit-weight world: couplings vary, noise penalties vary, routing costs vary, and “distance” is effectively weighted. If you prove the weighted equality theorem, you are not extending a lemma — you are showing that **quantum code distance is governed by a tropical systolic principle**.

This opens a field:
- weighted quantum LDPC design via tropical filtrations,
- persistent-homological heuristics for code construction,
- hardware-aware code synthesis where geometry and optimization become the same language,
- graph-theoretic analogues of systolic geometry for fault-tolerant architectures.

The cross-domain significance is strong:
- **tropical geometry:** min-plus optimization of cycle birth,
- **combinatorial optimization:** weighted cycle basis and shortest cycle structure,
- **quantum information:** non-uniform logical operator cost,
- **topological data analysis:** filtration-dependent birth values,
- **hardware design:** weighted coupler layouts and defect-aware routing.

---

## Proof Architecture: 3 viable strategies

You should not rely on one route. Develop at least two seriously.

### Strategy A: direct minimal-cycle forcing argument
This is likely the most Lean-friendly and the most promising.

1. Define `minSimpleCycleWeight G w` and prove existence of a minimizing simple cycle using finiteness.
2. Show that in a girth-adapted ordering, every edge of some minimizing cycle appears no later than any edge whose cycle support weight is larger.
3. Prove that before the final edge of that minimizing cycle is inserted, the prefix is acyclic on the cycle support; when that final edge is inserted, the created cycle has exactly the minimizing total weight.
4. Show no earlier inserted redundant edge can create a smaller-weight cycle by contradiction with minimality.

Why promising: it reduces the theorem to finite combinatorics plus a carefully chosen ordering invariant. It should naturally use `rcases`, finite minimization, and contradiction.

### Strategy B: bootstrap from the unit-weight theorem by tropical expansion
This is more conceptual and may produce stronger corollaries.

1. Replace each weighted edge of integer weight `n` by a chain/path gadget of length `n`, producing an unweighted expansion graph.
2. Show that simple cycles in the weighted graph correspond to simple cycles in the expansion graph with equal total length.
3. Transfer `codeDistance_eq_firstCycleBirth_of_simpleCycle` to the expansion graph.
4. Descend the equality back to the original weighted graph.

Why promising: it imports existing catalog results directly and reveals weighted distance as a shadow of unweighted distance in a larger geometry. This is especially attractive if your weights are naturals first, then extend to `ℚ≥0` or `ℝ≥0` by scaling/rational approximation.

Potential issue: formal graph gadgetry may be heavy in Lean. Still worth exploring for the paper and future generalization.

### Strategy C: matroid/greedy obstruction analysis
This is the right route for the obstruction theorem.

1. Interpret forests as independent sets in the graphic matroid.
2. Observe that raw-weight Kruskal optimizes spanning forests, not minimum cycle closure weight.
3. Characterize failure as a mismatch between edge-local weight priority and cycle-global objective.
4. Show the cycle-support-weight ordering repairs this mismatch by encoding a cycle-sensitive greedy potential.

Why promising: this yields the obstruction theorem and makes the result feel inevitable rather than ad hoc. It also creates bridges to weighted matroid optimization and tropical bases.

---

## Required deep-proof tactics

At least 3 theorem proofs must use nontrivial tactics such as:
- induction on the number of edges or on the filtration prefix,
- `rcases` on existence of minimizing cycles / decomposition of first redundant edge,
- `by_contra` to rule out earlier lower-weight births,
- `field_simp` if you normalize rational weights by scaling,
- multi-step `calc` chains for weight inequalities and order comparisons.

Avoid trivialized proofs. If a theorem collapses to `native_decide`, it is not one of the core results.

---

## Cross-domain theorem requirement

You must include at least one theorem that explicitly bridges to a different domain. The strongest candidate is a statement linking weighted cycle birth to a tropical optimization principle.

### Theorem E: tropical min-plus characterization
Show that the weighted first cycle birth under girth-adapted filtration can be expressed as a min-plus optimization over cycle incidence vectors:
\[
\operatorname{firstCycleBirthValue}(G,w,\sigma_{\mathrm{ga}})
=
\min_{x \in \mathcal{C}_{\mathrm{simp}}}
\langle w, x\rangle_{\min+}
\]
where the right-hand side is formalized appropriately as the minimum of ordinary sums over simple cycle indicator vectors.

#### Lean 4 target signature sketch
```lean
theorem firstCycleBirthValue_eq_tropicalCycleMinimum
  {V : Type*} [Fintype V] [DecidableEq V]
  (G : SimpleGraph V)
  (w : Sym2 V → ℝ≥0)
  (hw_pos : ∀ e, 0 < w e)
  (σ : List (Sym2 V))
  (hσ : IsGirthAdaptedOrder G w σ) :
  firstCycleBirthValue G w σ =
    sInf {t | ∃ C, IsSimpleCycle G C ∧ cycleWeight w C = t}
```

This theorem is the conceptual bridge:
- tropical geometry via min-plus linearization,
- combinatorial optimization via shortest simple cycle,
- quantum codes via weighted logical support.

If full tropical notation is awkward in Lean, formalize the substance first and state the tropical interpretation clearly in the paper.

---

## Conjecture with falsifiable computational prediction

State and test the following sharpened conjecture.

### Conjecture: generic exactness of local cycle-support ordering
For connected finite weighted graphs with i.i.d. positive integer edge weights and no ties in cycle support weights, the girth-adapted filtration realizes the minimum simple cycle weight exactly:
\[
\operatorname{firstCycleBirthValue}(G,w,\sigma_{\mathrm{ga}})=\operatorname{mwsc}(G,w).
\]
Moreover, failures of raw-weight Kruskal occur precisely when a minimum-weight cycle is not prefix-closed under shortest-path completion.

### Testable prediction
On random graphs with 8–20 vertices and weights in `{1,…,10}`:
- compute `minSimpleCycleWeight`,
- compute `kruskalFirstCycleBirthValue`,
- compute `girthAdaptedFirstCycleBirthValue`,
- record obstruction witnesses when Kruskal fails.

A disproof occurs if the girth-adapted value differs from the minimum cycle weight. A structural refinement occurs if equality holds but the predicted obstruction classification fails.

You should implement this experimentally in `demo.py`.

---

## Algorithmic deliverable

You must provide a verified computational method, not just a theorem.

### Required algorithm
Implement a function that:
1. enumerates simple cycles for small finite graphs,
2. computes `cycleSupportWeight` for each edge,
3. constructs the girth-adapted filtration,
4. computes the first cycle birth value under:
   - raw-weight Kruskal,
   - girth-adapted filtration,
5. compares both with the exhaustive minimum simple cycle weight.

This algorithm should be reflected both in Lean definitions/theorems and in `demo.py`.

Suggested computational names:
- `enumerate_simple_cycles`
- `cycle_support_weight`
- `girth_adapted_order`
- `first_cycle_birth_value`
- `min_simple_cycle_weight`

---

## Application keywords

Use these explicitly in the paper and article:

- weighted systole
- tropical optimization
- min-plus geometry
- graph-derived CSS codes
- quantum LDPC
- hardware-aware code design
- persistent cycle birth
- shortest simple cycle
- graphic matroid obstruction
- non-uniform couplings
- fault-tolerant architecture
- combinatorial Morse filtration

---

## Concrete implementation milestones

1. **Define**:
   - `cycleWeight`
   - `minSimpleCycleWeight`
   - `cycleSupportWeight`
   - `IsGirthAdaptedOrder`
   - `firstCycleBirthValue`
   - `weightedCodeDistance`
   - `EdgeObstruction`

2. **Prove foundational lemmas**:
   - existence of a minimum-weight simple cycle in finite graphs,
   - every first redundant edge closes a cycle,
   - under positive weights, cycle weights are strictly monotone under proper supercycle extension when appropriate hypotheses hold,
   - cycle-support ordering is compatible with minimum-cycle realization.

3. **Prove 3+ major theorems**:
   - Theorem A,
   - Theorem B,
   - Theorem C,
   - optionally Theorem D/E.

4. **Experiment**:
   - random weighted graphs on 8–20 vertices,
   - exhaustive cycle search for small cases,
   - compare filtrations,
   - log counterexamples and obstruction patterns.

---

## Deliverables you must produce

You must produce **all** of the following:

### 1. `FUTURE_DIRECTIONS.md`
Give 3–5 original research directions. Each direction must include the exact sentences:
- **“The key insight is...”**
- **“Why now?”**

At least one direction must bridge to a different field, such as:
- tropical quantum decoding,
- weighted matroid persistence,
- systolic inequalities for hardware graphs,
- statistical mechanics of logical operator formation.

### 2. `RESEARCH_PAPER.md`
A standalone scientific paper. A reader with no access to the code must understand:
- the new definitions,
- the main theorems,
- why weighted cycle birth matters,
- how this changes the landscape for graph-based quantum codes,
- what the obstruction theorem teaches us,
- what comes next.

### 3. `ARTICLE.md`
Write in Scientific American style. Make it vivid and idea-driven. Explain how a weighted network “reveals its weakest loop” and why that matters for quantum architectures and optimization. Do **not** focus on formal verification machinery.

### 4. Verified algorithm / computational method
Formalize and verify at least one nontrivial algorithmic component related to girth-adapted filtration or minimum-cycle detection.

### 5. `demo.py`
Interactive demonstration:
- generate random weighted graphs,
- visualize edge weights,
- compute and compare the three quantities,
- display success/failure rates,
- show obstruction witnesses when present.

---

## Final call

Do not settle for “weighted analogue of an old theorem.” The mission is to show that **weighted code distance is a tropical cycle invariant**, and that the right filtration does not merely detect topology — it detects optimization structure hidden inside topology. If you can make this precise in Lean, you will have created a new blueprint for hardware-aware quantum code geometry.

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
