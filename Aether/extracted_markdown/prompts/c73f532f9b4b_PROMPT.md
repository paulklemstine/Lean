Soli Deo Gloria

## Assignment: Direction 2 — Concentration and Universality of Tropical Critical Distributions

**Mode:** `prove`

You are to turn the heuristic “cycle-birth times in random weighted Erdős–Rényi graphs concentrate to a universal law” into a mathematically sharp, formally verified breakthrough. This is not an incremental extension of random graph folklore. The target is a new bridge between **tropical Morse theory, persistent homology on graphs, concentration of measure, and universality phenomena from statistical mechanics / random matrix theory**.

Build explicitly on:

- `Catalog/Pythagorean/TropicalBridge/TropicalMorseGraphs.lean`
  - `filtration_betti1_eq_cycleCount`
  - `filtration_rank_eq_mergeCount`

These are the structural hinge: they identify the first Betti number along the filtration with a combinatorial cycle-count process. Your job is to upgrade that deterministic identity into **probabilistic concentration and distributional universality**.

---

## Core Vision

For a finite weighted graph, the birth times of 1-cycles are the tropical critical values of the graph filtration. In a random graph with random edge weights, these critical values become a random point process. If this process concentrates and its empirical law is asymptotically deterministic, then we get a new object:

> a **tropical spectral law for random graphs**,

playing the role that the semicircle law plays for eigenvalues of random matrices.

This would open a field: **probabilistic tropical topology**. It would also create a mathematically precise route from tropical geometry to network science, percolation, and universality theory.

---

## Precise Theorem Targets

You must prove at least **3 substantial theorems**. At least one should be a concentration theorem, at least one a structural theorem about cycle-birth measures, and at least one a cross-domain theorem connecting to another area.

### New definitions you should introduce

You must define at least one genuinely new concept absent from the cited catalog. Suggested definitions:

1. **Cycle-birth multiset / measure**
   - For a weighted graph filtration, define the multiset of edge weights whose insertion increases `β₁`.
   - Normalize to an empirical probability measure when `β₁ > 0`.

2. **Edge-resampling sensitivity**
   - A function measuring how much the cycle-birth counting function changes when a single edge weight is altered.

3. **Universal rescaled birth law**
   - A notion expressing invariance of the limiting empirical birth distribution under monotone transport of the base edge-weight distribution.

These are not mere packaging; they are the language needed for concentration and universality.

---

## Theorem 1: Deterministic combinatorial characterization of cycle-birth times

### Mathematical statement

Let `G` be a finite simple graph with distinct edge weights. For each threshold `t`, let `G≤t` be the subgraph of edges with weight at most `t`. Then an edge `e` of weight `w(e)` is a cycle-birth edge iff its endpoints are already connected in the subgraph of lighter edges. Equivalently, the cycle-birth counting function is the count of edges whose insertion closes an existing path.

This is the deterministic foundation for all probabilistic arguments.

### Lean 4 target signature (schematic but precise)
```lean
theorem edge_is_cycle_birth_iff_connected_before
  {V : Type u} [Fintype V] [DecidableEq V]
  (G : SimpleGraph V)
  (w : Sym2 V → ℝ)
  (hGeneric : Pairwise fun e f => e ≠ f → w e ≠ w f)
  (e : Sym2 V) :
  IsCycleBirthEdge G w e ↔
    ConnectedInLowerSubgraph G w e
```

If needed, define:
```lean
def lowerSubgraph (G : SimpleGraph V) (w : Sym2 V → ℝ) (t : ℝ) : SimpleGraph V := ...
def IsCycleBirthEdge (G : SimpleGraph V) (w : Sym2 V → ℝ) (e : Sym2 V) : Prop := ...
def ConnectedInLowerSubgraph (G : SimpleGraph V) (w : Sym2 V → ℝ) (e : Sym2 V) : Prop := ...
```

### Why this matters
This theorem identifies tropical criticality with a purely graph-theoretic predicate. It converts persistent topology into a local connectivity event, which is exactly what concentration inequalities can exploit.

### Proof strategy options

**Strategy A: Betti jump via rank-merge decomposition**  
1. Use `filtration_betti1_eq_cycleCount` and `filtration_rank_eq_mergeCount` to express the jump in `β₁` when inserting a single edge.  
2. Show that adding an edge either merges two components or creates one new cycle, and these are mutually exclusive.  
3. Deduce the characterization by whether the endpoints were already connected.

**Strategy B: Forest invariant / Kruskal-style argument**  
1. Order edges by increasing weight using genericity.  
2. Track a spanning forest of the lower filtration.  
3. Prove an edge is excluded from the forest iff it closes a path, hence creates a cycle.

**Most promising:** Strategy A, because it directly reuses the catalog’s certified filtration identities and minimizes reinvention.

---

## Theorem 2: Single-edge Lipschitz stability of the cycle-birth counting process

### Mathematical statement

Let `N_G(t)` be the number of cycle-birth times at most `t` in a weighted graph filtration. If one modifies the weight of a single edge, then for every threshold `t`, the counting function changes by at most `1`. Consequently, the empirical cycle-birth CDF has bounded differences with respect to independent edge-weight resampling.

### Lean 4 target signature
```lean
theorem cycleBirthCount_single_edge_weight_change_le_one
  {V : Type u} [Fintype V] [DecidableEq V]
  (G : SimpleGraph V)
  (w w' : Sym2 V → ℝ)
  (e0 : Sym2 V)
  (hAgree : ∀ e, e ≠ e0 → w e = w' e) :
  ∀ t : ℝ,
    |cycleBirthCountLE G w t - cycleBirthCountLE G w' t| ≤ 1
```

Possible supporting definitions:
```lean
def cycleBirthCountLE (G : SimpleGraph V) (w : Sym2 V → ℝ) (t : ℝ) : ℤ := ...
def empiricalCycleBirthCDF (G : SimpleGraph V) (w : Sym2 V → ℝ) (t : ℝ) : ℝ := ...
```

### Why this matters
This is the exact Lipschitz estimate needed for McDiarmid/Azuma concentration. It is the analogue of a rank-one perturbation bound in random matrix theory.

### Proof strategy options

**Strategy A: Direct edge-swap dichotomy**  
1. Show only the status of the modified edge can directly change at threshold values.  
2. Prove all other edges retain their cycle-birth indicator except possibly through one exchange event.  
3. Sum the indicator differences and bound by `1`.

**Strategy B: Matroid viewpoint**  
1. Interpret cycle-birth edges as edges outside the greedy spanning forest.  
2. Changing one weight alters the greedy basis by at most one exchange.  
3. Conclude the number of rejected edges below threshold changes by at most `1`.

**Strategy C: Betti-process telescoping**  
1. Write the count via cumulative `β₁` jumps.  
2. Show each filtration rank function changes by at most one under a single edge modification.  
3. Telescope over thresholds.

**Most promising:** Strategy B if you can formalize enough of the greedy forest exchange principle; otherwise Strategy A is safer in Lean.

---

## Theorem 3: Concentration inequality for the empirical cycle-birth CDF

### Mathematical statement

Fix `n` and `p`. Let `G ~ G(n,p)` and let edge weights be i.i.d. from a continuous law. For each threshold `t`, conditional on the graph structure or in the mixed model, the centered cycle-birth count satisfies a subgaussian tail:
\[
\Pr\big(|N_G(t)-\mathbb E N_G(t)| \ge r\big)
\le 2\exp\!\left(-\frac{2r^2}{m}\right),
\]
where `m` is the number of potential edges (or present edges, depending on model formalization), because the function is 1-Lipschitz in each independent edge weight. After normalization by `β₁` or by `m`, obtain concentration of the empirical CDF.

### Lean 4 target signature

You may need to formalize a finite-product probability space over edge weights. A schematic target:

```lean
theorem cycleBirthCount_subgaussian
  {V : Type u} [Fintype V] [DecidableEq V]
  (G : SimpleGraph V)
  (μ : Measure (Sym2 V → ℝ))
  (hIndep : EdgeWeightIID μ)
  (hCont : EdgeWeightContinuous μ) :
  ∀ t r : ℝ, 0 ≤ r →
    μ {w | |cycleBirthCountLE G w t - 𝔼[w], cycleBirthCountLE G w t| ≥ r}
      ≤ 2 * Real.exp (-2 * r^2 / Fintype.card (Sym2 V))
```

If full measure-theoretic McDiarmid is too heavy in one cycle, prove a finite discrete approximation theorem first and then a transfer theorem for continuous laws. But the end result must be nontrivial and structurally faithful.

### Why this matters
This is the gateway theorem: it turns tropical critical values into a concentrated observable. Without concentration there is no law, only numerics.

### Proof strategy options

**Strategy A: McDiarmid from Theorem 2**  
1. Package `cycleBirthCountLE G w t` as a function on independent coordinates indexed by edges.  
2. Use Theorem 2 to provide bounded differences constants `c_e = 1`.  
3. Invoke or formalize McDiarmid/Azuma for finite products.

**Strategy B: Doob martingale**  
1. Reveal edge weights one at a time.  
2. Define the Doob martingale of conditional expectations of the counting function.  
3. Use the one-step difference bound from Theorem 2 and apply Azuma–Hoeffding.

**Most promising:** Strategy B if Mathlib’s martingale infrastructure is usable; otherwise Strategy A via a custom finite bounded-differences lemma may be cleaner.

---

## Theorem 4: Distribution-freeness under monotone transport

### Mathematical statement

Let `F` be any continuous strictly increasing CDF on edge weights, and let `U = F(W)`. Then the ordering of edge weights is preserved, hence the set of cycle-birth edges is unchanged, and the birth times for `W` are exactly the inverse-CDF pushforward of the birth times for uniform weights. Therefore the empirical birth law depends on the edge-weight distribution **only through monotone rescaling**.

This is the correct universality theorem available at the graph-filtration level.

### Lean 4 target signature
```lean
theorem cycleBirthMeasure_monotone_transport
  {V : Type u} [Fintype V] [DecidableEq V]
  (G : SimpleGraph V)
  (w : Sym2 V → ℝ)
  (φ : ℝ → ℝ)
  (hmono : StrictMono φ) :
  cycleBirthEdges G (φ ∘ w) = cycleBirthEdges G w
```

And stronger:
```lean
theorem empiricalCycleBirthCDF_comp_strictMono
  {V : Type u} [Fintype V] [DecidableEq V]
  (G : SimpleGraph V) (w : Sym2 V → ℝ) (φ : ℝ → ℝ)
  (hmono : StrictMono φ) (hbij : Bijective φ) :
  empiricalCycleBirthCDF G (φ ∘ w) t
    = empiricalCycleBirthCDF G w (φ⁻¹ t)
```

### Why this matters
This is the universality mechanism. It shows that for continuous i.i.d. weights, all dependence on the sampling law is order-theoretic. That is profoundly tropical: only valuations/order matter.

### Cross-domain connection
This theorem links:
- **tropical geometry**: order/valuation controls geometry,
- **probability**: probability integral transform,
- **statistical physics universality**: microscopic law washed out after rescaling.

### Proof strategy options

**Strategy A: Order preservation**  
1. Show lower subgraphs for `φ ∘ w` at threshold `φ(t)` coincide with lower subgraphs for `w` at threshold `t`.  
2. Transfer the cycle-birth predicate through Theorem 1.  
3. Conclude edge sets and empirical laws are pushforwards.

**Strategy B: Rank filtration invariance**  
1. Express births via filtration Betti jumps.  
2. Show monotone transport preserves the entire filtration up to reparameterization.  
3. Deduce invariance of critical edge identities.

**Most promising:** Strategy A; it is conceptually exact and likely shortest in Lean.

---

## Theorem 5: Cross-domain theorem — cycle births and minimum spanning tree complement

This is the theorem that makes the whole story feel inevitable.

### Mathematical statement

For a weighted connected graph with distinct weights, the set of cycle-birth edges is exactly the complement of the minimum spanning tree edges. Consequently, the empirical cycle-birth measure is the empirical weight measure of non-MST edges.

### Lean 4 target signature
```lean
theorem cycleBirthEdges_eq_compl_MSTEdges
  {V : Type u} [Fintype V] [DecidableEq V]
  (G : SimpleGraph V)
  (w : Sym2 V → ℝ)
  (hGeneric : Pairwise fun e f => e ≠ f → w e ≠ w f)
  (hConn : G.Connected) :
  cycleBirthEdges G w = graphEdges G \ MSTEdges G w
```

### Why this is revolutionary
This connects:
- **persistent/tropical topology** with
- **combinatorial optimization** (Kruskal, MST),
- and therefore with
- **probabilistic optimization** and **network design**.

It says the “tropical critical spectrum” of a graph is literally the weight spectrum of edges rejected by the MST. That reframes cycle-birth laws as a shadow of random optimization.

### Proof strategy options

**Strategy A: Kruskal equivalence**  
1. An edge is chosen by Kruskal iff its endpoints are disconnected among lighter edges.  
2. By Theorem 1, an edge is a cycle birth iff its endpoints are connected among lighter edges.  
3. These are complements.

**Strategy B: Basis exchange in graphic matroids**  
1. Interpret MST edges as the greedy basis in the weighted graphic matroid.  
2. Cycle-birth edges are exactly nonbasis elements.  
3. Use matroid duality language if available.

**Most promising:** Strategy A.

---

## The actual asymptotic conjecture to state clearly

Your original conjecture should be sharpened and split into formalizable stages.

### Main asymptotic conjecture
For each fixed `p ∈ (0,1)`, let `G_n ~ G(n,p)` and let edge weights be i.i.d. from any continuous distribution. Let
\[
\mu_{G_n} := \frac{1}{\beta_1(G_n)} \sum_{e \in \mathrm{CycleBirthEdges}(G_n,w)} \delta_{w(e)}
\]
on the event `β₁(G_n) > 0`. Then there exists a deterministic probability measure `μ_p` on `[0,1]` such that
\[
\mu_{G_n} \xrightarrow{\mathbb P} \mu_p
\]
weakly as `n → ∞`. Moreover, if `F` is another continuous edge-weight law, the limiting measure is the monotone pushforward of the uniform-law limit.

### Testable prediction
For fixed `p > 0`, the KS distance between empirical CDFs from independent trials should decay like `O(n^{-1/2})` after suitable normalization. Under different continuous weight laws, the rescaled empirical CDFs should collapse onto one curve.

### Falsifiable stronger conjecture
For dense `G(n,p)` with fixed `p ∈ (0,1)`, the limit law `μ_p` is **Beta-like** with parameters determined only by `p` and not by the underlying continuous weight law beyond monotone transport.  
This is falsifiable by simulation: fit transformed empirical laws under Uniform / Exponential / Gaussian and reject if transformed KS distance does not vanish.

You must include at least one explicit conjecture in Lean-comment prose and implement the computational test in `demo.py`.

---

## How to use the catalog theorems explicitly

You must not merely cite the catalog. Use it as follows:

- `filtration_betti1_eq_cycleCount`  
  Use this to identify the cumulative number of cycle births up to threshold `t` with the first Betti number of the threshold subgraph, adjusted by component/rank identities if needed.

- `filtration_rank_eq_mergeCount`  
  Use this to decompose the effect of adding an edge into “merge” versus “cycle birth.” This is the key deterministic dichotomy behind both Theorem 1 and the Lipschitz bound.

These theorems should appear in the proofs, not just in comments.

---

## Proof architecture: recommended order of attack

### Path A — Most promising
1. Define `lowerSubgraph`, `IsCycleBirthEdge`, `cycleBirthEdges`, `cycleBirthCountLE`, `empiricalCycleBirthCDF`.
2. Prove the edge dichotomy theorem (Theorem 1) using catalog filtration identities.
3. Prove MST complement theorem (Theorem 5).
4. Prove single-edge Lipschitz stability (Theorem 2).
5. Formalize a finite bounded-differences / Azuma lemma and derive concentration (Theorem 3).
6. Prove monotone-transport universality (Theorem 4).
7. Build simulations around these definitions.

### Path B — Optimization-first route
1. Formalize MST/Kruskal behavior under generic weights.
2. Identify cycle births as rejected Kruskal edges.
3. Import concentration through optimization stability.
4. Then derive tropical statements as corollaries.

### Path C — Persistence-first route
1. Work entirely with Betti jump processes and filtration identities.
2. Define birth measures from jump locations.
3. Prove all stability and universality at the process level.
4. Only later identify with MST complement.

**Recommendation:** Path A. It is both mathematically elegant and Lean-feasible.

---

## Required deep proof tactics

Your file must contain at least 3 theorems with genuinely nontrivial proofs using techniques such as:

- induction on the ordered edge list,
- `rcases` decomposition of connectivity/cycle alternatives,
- `by_contra` to show exclusivity of merge vs cycle creation,
- `field_simp` if normalizations of empirical measures require rational expressions,
- multi-step `calc` chains for filtration equalities and monotone transport.

Do not hide the substance behind automation.

---

## Cross-domain connections you must explicitly develop

At least one theorem and one discussion section in `RESEARCH_PAPER.md` must connect this work to another domain. Strong options:

1. **Random graph theory / percolation**
   - Cycle births track emergence of redundant connectivity beyond the forest phase.
   - The empirical birth law should detect the onset of the giant 2-core.

2. **Combinatorial optimization**
   - Cycle births = non-MST edges under generic weights.
   - This links tropical criticality to greedy algorithms and matroid theory.

3. **Statistical mechanics / random matrix universality**
   - The limiting birth law is a topological analogue of a spectral law.
   - Universality under monotone transport mirrors insensitivity to microscopic disorder.

4. **Topological data analysis**
   - These are 1-dimensional persistence birth times in graph filtrations.
   - Concentration gives confidence intervals for topological summaries of random networks.

---

## Application keywords

Include these keywords verbatim where appropriate:

**Application keywords:** tropical Morse theory, persistent homology, Erdős–Rényi graphs, concentration of measure, McDiarmid inequality, Azuma–Hoeffding, universality, minimum spanning tree, graphic matroid, percolation, network science, topological statistics, random optimization, KS distance, empirical process.

---

## Deliverables — ALL mandatory

You must produce all of the following:

### 1. Lean file with theorems and new definitions
- At least 3 substantial theorems.
- At least one new definition absent from the catalog.
- Minimal `sorry`; if any remain, isolate them and explain exactly what infrastructure is missing.

### 2. `FUTURE_DIRECTIONS.md`
Include **3–5 original research directions**, each with:
- a title,
- **“The key insight is...”**
- **“Why now?”**
At least one direction must bridge to a different domain, e.g. random matrix theory, statistical physics, or topological data analysis.

Possible future directions:
- tropical spectral laws for sparse graph limits,
- higher-dimensional random clique complexes,
- universality classes for MST-complement statistics,
- tropical large deviations for network failures,
- topological hypothesis testing from cycle-birth spectra.

### 3. `RESEARCH_PAPER.md`
A standalone scientific paper that someone can read without code access. It must include:
- motivation,
- precise definitions,
- theorem statements,
- proof sketches,
- computational experiments,
- significance,
- limitations,
- next-step conjectures.

Do not write this as verification notes. Write it as mathematics.

### 4. `ARTICLE.md`
A Scientific American–style article for broad readers.  
Taboo: do **not** focus on formal verification. Focus on the ideas:
how random networks acquire loops, why their “birth times” obey law-like behavior, and why this may become a new universal language for complex systems.

### 5. Verified algorithm / computational method
Implement a certified or at least theorem-backed procedure that:
- computes cycle-birth edges from a weighted graph,
- computes the empirical cycle-birth CDF,
- compares distributions across trials via KS distance,
- optionally compares with MST-complement statistics to validate Theorem 5 computationally.

### 6. `demo.py`
An interactive demonstration that:
- samples `G(n,p)` with random weights,
- computes cycle-birth times,
- plots empirical CDFs,
- estimates KS distances across trials for increasing `n`,
- compares weight laws (uniform / exponential / normal transformed to continuous laws),
- illustrates monotone-transport universality.

---

## Concrete experimental agenda for `demo.py`

Run at least:

1. **Concentration test**
   - `p = 0.15`
   - `n = 50, 100, 200, 500, 1000`
   - multiple trials each
   - compute pairwise KS distances between empirical cycle-birth CDFs
   - test whether mean KS distance decreases approximately like `n^{-1/2}`

2. **Universality test**
   - fixed `n` large, fixed `p`
   - edge weights from Uniform, Exponential, Gaussian
   - transform to common quantile scale when appropriate
   - compare resulting empirical CDFs
   - reject universality if transformed curves fail to align

3. **MST complement validation**
   - verify experimentally that cycle-birth edges coincide with non-MST edges under distinct weights

---

## Final challenge

Do not merely prove that some graph statistic is bounded. Show that **tropical critical values behave like a new spectral observable** of random networks.

The breakthrough theorem package should make a researcher say:

> “Cycle births are to random topology what eigenvalues are to random linear algebra.”

That is the bar.

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
