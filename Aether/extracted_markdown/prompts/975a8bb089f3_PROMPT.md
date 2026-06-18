Soli Deo Gloria

## Assignment: Direction 5: Tropical Morse Theory for Network Phase Transitions

**Mode:** `prove` + `discover`

You are not being asked for a routine formalization of graph filtration folklore. You are being asked to carve out a genuinely new bridge: a **tropical Morse theory for weighted graph filtrations** that turns phase transitions in networks into a theorem schema connecting tropical homology, persistent topology, and statistical mechanics.

Build on:

- `Pythagorean/TropicalBridge/TropicalHomology.lean`
  - especially `tropicalBetti'`, `tropicalBoundary`
- `Pythagorean/TropicalBridge/WeightedDefect.lean`
  - especially the weighted graph infrastructure

Your goal is to isolate a **canonical notion of tropical critical value**, prove a **discrete tropical Morse principle** for graph filtrations, and extract a **verified algorithm** computing the phase-transition data.

## Core Vision

For a weighted finite graph, edges appear in increasing threshold order. At each threshold, exactly one of two things should happen to the 1-dimensional topology of the filtered graph:

1. a new edge merges two connected components, decreasing `β₀` by `1`, or
2. a new edge closes an independent cycle, increasing `β₁` by `1`.

This is elementary at an intuitive level, but the breakthrough is to formalize it **as tropical Morse theory**, with a mathematically clean notion of critical event, a filtration theorem, and a persistent pairing statement that identifies the tropical barcode with the classical graph persistence barcode. That gives a new conceptual language for **network phase transitions**: thresholds act like inverse temperatures, and critical values mark topological transitions in the state space.

---

## Precise Formalization Targets

You should introduce at least one genuinely new definition not already present in the catalog.

### New definitions to create

1. **Threshold subgraph**
   - For a weighted graph `G` with edge weight function `w`, define the threshold graph at level `t` by keeping exactly the edges of weight `≤ t`.

2. **Tropical critical value**
   - A threshold `t` is tropical critical if crossing `t` changes either `β₀` or `β₁` of the threshold subgraph.

3. **Edge event type**
   - For an inserted edge, define whether it is a `mergeEvent` or `cycleEvent`, according to whether its endpoints were previously disconnected or connected.

4. **Persistence birth function for graph cycles**
   - Optional but highly valuable: define the birth time of a cycle class as the weight of the unique edge whose insertion creates that class.

These definitions should not be cosmetic. They should support theorem statements and algorithm extraction.

---

## Precise Theorem Statements

You must prove at least **3 substantial theorems**. The following are the target theorems.

### Theorem 1: Edge insertion dichotomy

For any threshold step in which a new edge `e` is inserted into the filtration, exactly one of two mutually exclusive events occurs: either `β₀` drops by `1` and `β₁` is unchanged, or `β₀` is unchanged and `β₁` rises by `1`.

#### Mathematical statement
Let `G_t` be the threshold subgraph and let `e = {u,v}` be an edge with weight `t` newly added at level `t`. If `G_{<t}` denotes the graph using only edges of weight `< t`, then:

- if `u` and `v` lie in distinct connected components of `G_{<t}`, then
  `β₀(G_t) = β₀(G_{<t}) - 1` and `β₁(G_t) = β₁(G_{<t})`;
- if `u` and `v` lie in the same connected component of `G_{<t}`, then
  `β₀(G_t) = β₀(G_{<t})` and `β₁(G_t) = β₁(G_{<t}) + 1`.

This is the atomic local Morse law.

#### Suggested Lean 4 signature
Use the actual graph type from `WeightedDefect.lean`, but the theorem should look structurally like:

```lean
theorem betti_update_dichotomy
  {V E : Type} [Fintype V] [DecidableEq V]
  (G : WeightedGraph V)
  (e : Sym2 V) (t : ℝ)
  (hnew : G.weight e = t)
  (h_insert : e ∈ thresholdEdges G t)
  (h_prev : e ∉ thresholdEdges G (t - ε)) :
  let Gprev := thresholdSubgraph G (t - ε)
  let Gcurr := thresholdSubgraph G t
  (ConnectedIn Gprev (Sym2.mem₁ e) (Sym2.mem₂ e) →
      tropicalBetti0 Gcurr = tropicalBetti0 Gprev ∧
      tropicalBetti1 Gcurr = tropicalBetti1 Gprev + 1) ∧
  (¬ ConnectedIn Gprev (Sym2.mem₁ e) (Sym2.mem₂ e) →
      tropicalBetti0 Gcurr + 1 = tropicalBetti0 Gprev ∧
      tropicalBetti1 Gcurr = tropicalBetti1 Gprev)
```

If `Sym2.mem₁`/`mem₂` are not the right accessors for your edge representation, replace them with the correct endpoint projections. The essential point is the exact update law.

---

### Theorem 2: Global tropical Morse equality for graphs

The total number of critical edge insertions equals the final rank contribution to topology:
- cycle events occur exactly `β₁(G)` times,
- merge events occur exactly `|V| - β₀(G)` times,
- therefore the total number of topological critical events equals `|E'|`, where `E'` is the set of distinct filtration insertions, and the cycle-event count is exactly `β₁(G)`.

More conceptually: the tropical Morse data of the filtration recovers the graph Euler relation.

#### Mathematical statement
For a finite weighted graph with pairwise distinct edge weights (or after quotienting equal-weight insertions into batches handled carefully), if `CycCrit(G)` is the set of thresholds at which `β₁` jumps and `MergeCrit(G)` the set where `β₀` drops, then

- `|CycCrit(G)| = β₁(G)`,
- `|MergeCrit(G)| = |V| - β₀(G)`,
- `|CycCrit(G)| + |MergeCrit(G)| = |E|`.

If equal weights occur, prove the batched version using edge multiplicities or prove the distinct-weight theorem first and then a corollary under a tie-breaking perturbation.

#### Suggested Lean 4 signature
```lean
theorem card_cycleCritical_eq_betti1
  {V : Type} [Fintype V] [DecidableEq V]
  (G : WeightedGraph V)
  (hdistinct : Pairwise fun e f => G.weight e ≠ G.weight f) :
  Fintype.card (cycleCriticalValues G) = tropicalBetti1 (fullSubgraph G)

theorem card_mergeCritical_eq_rank_drop
  {V : Type} [Fintype V] [DecidableEq V]
  (G : WeightedGraph V)
  (hdistinct : Pairwise fun e f => G.weight e ≠ G.weight f) :
  Fintype.card (mergeCriticalValues G) =
    Fintype.card V - tropicalBetti0 (fullSubgraph G)
```

A stronger theorem would combine them via an Euler-characteristic identity.

---

### Theorem 3: Tropical persistence agrees with classical graph persistence

This is the cross-domain theorem. Show that for 1-dimensional filtered graph complexes, the tropical persistence barcode coincides with the classical persistence barcode obtained from the filtered chain complex. In graph degree `1`, all cycle classes are born at cycle-closing events and never die inside the graph filtration unless you enrich the complex; for ordinary graph filtrations this means the barcode consists of intervals `[birth, ∞)` corresponding exactly to cycle events.

#### Mathematical statement
Let `G_t` be the threshold filtration of a weighted graph. Then the multiset of birth times of 1-dimensional tropical persistence classes equals the multiset of cycle-critical values. Equivalently, the persistent rank function in degree `1` is determined by the cumulative count of cycle-closing insertions.

This identifies tropical and classical persistence in the graph case.

#### Suggested Lean 4 signature
```lean
theorem tropical_persistence_degree1_eq_classical
  {V : Type} [Fintype V] [DecidableEq V]
  (G : WeightedGraph V) :
  tropicalBarcode1 G = classicalGraphBarcode1 G
```

If full barcode equality is too large for one cycle, prove a precise rank-function equality:

```lean
theorem tropical_persistentRank1_eq_classical
  {V : Type} [Fintype V] [DecidableEq V]
  (G : WeightedGraph V) (s t : ℝ) (hs : s ≤ t) :
  tropicalPersistentRank1 G s t = classicalPersistentRank1 G s t
```

This is a field-opening theorem because it says the tropical formalism is not merely analogous to persistent homology on graphs; it is **exactly the same invariant in degree one**, giving a tropical interpretation of network topology.

---

## Lean-Oriented Structure

You should aim to define objects with signatures resembling:

```lean
def thresholdSubgraph {V : Type} [DecidableEq V]
    (G : WeightedGraph V) (t : ℝ) : WeightedGraph V := ...

def isTropicalCritical {V : Type} [Fintype V] [DecidableEq V]
    (G : WeightedGraph V) (t : ℝ) : Prop :=
  tropicalBetti0 (thresholdSubgraph G t) ≠ tropicalBetti0 (thresholdSubgraph G (t - ε)) ∨
  tropicalBetti1 (thresholdSubgraph G t) ≠ tropicalBetti1 (thresholdSubgraph G (t - ε))

inductive EdgeEventType
  | mergeEvent
  | cycleEvent

def edgeEventType {V : Type} [Fintype V] [DecidableEq V]
    (G : WeightedGraph V) (e : Edge V) : EdgeEventType := ...
```

If the use of `t - ε` is awkward in Lean, replace it with a filtration indexed by a sorted list of distinct edge weights:

```lean
def filtrationValues {V : Type} (G : WeightedGraph V) : List ℝ := ...
def filtrationGraphAtIndex {V : Type} (G : WeightedGraph V) (i : Fin n) : WeightedGraph V := ...
```

This discrete indexing may be far easier to prove over than real thresholds, and then you can derive the real-threshold corollary.

---

## Proof Strategy Architecture

You must not rely on trivial automation. The proofs should visibly use multi-step mathematical reasoning: induction over sorted edges, case splits on connectivity, and Euler characteristic identities.

### Strategy A: Induction on the sorted edge filtration
This is the most promising route.

1. Sort edges by weight and define `G_i` as the subgraph containing the first `i` edges.
2. Prove the one-edge insertion lemma:
   - if the new edge connects distinct components, `β₀` drops by `1`;
   - otherwise it creates one new independent cycle, so `β₁` rises by `1`.
3. Sum these local updates inductively to obtain the global Morse equality.
4. Extract the persistence statement by identifying cycle births with exactly the cycle-event indices.

**Why this is most promising:** it avoids analysis on `ℝ`, reduces everything to finite combinatorics, and matches Lean’s strengths: `Fin`, `List`, induction, and cardinality lemmas.

### Strategy B: Euler characteristic plus spanning forest decomposition
A second route for the global theorem.

1. For each threshold graph, use the graph identity
   `β₁ = |E| - |V| + β₀`.
2. Show that adding one edge changes `|E|` by `1`, while `|V|` is fixed.
3. Deduce that the pair `(Δβ₀, Δβ₁)` must be either `(-1,0)` or `(0,+1)`.
4. Characterize which case occurs by whether the edge lies outside a spanning forest.

**Why it is powerful:** it converts homological change into a finite combinatorial invariant, and gives a clean path to the count theorem `#cycle events = β₁(G)`.

### Strategy C: Filtered chain complex comparison
Best for the persistence theorem.

1. Build the filtered chain complex of the graph using catalog boundary maps such as `tropicalBoundary`.
2. Show that in degree `1`, the tropical boundary operator on the threshold complex agrees with the classical incidence boundary after specialization.
3. Prove equality of kernel/image ranks at each filtration level.
4. Conclude barcode equality or at least persistent rank equality.

**Why this matters:** this is the theorem that crosses from tropical geometry to topological data analysis. Even a rank-equality version would be highly significant.

---

## Mandatory Cross-Domain Connections

You must include at least one theorem explicitly connecting this work to a different domain.

### Cross-domain theorem target: statistical mechanics interpretation
Define a monotone observable analogous to susceptibility:
- let `χ(t)` be the number of connected components or a normalized cycle count of `G_t`;
- prove that tropical critical values are exactly the discontinuity points of this observable in the discrete filtration.

This is a rigorous mathematical translation of **phase transitions** in network growth.

Possible Lean-facing theorem:

```lean
theorem critical_iff_topology_jump
  {V : Type} [Fintype V] [DecidableEq V]
  (G : WeightedGraph V) (i : ℕ) :
  isTropicalCriticalIndex G i ↔
    tropicalBetti0 (filtrationGraphAtIndex G (i+1)) ≠ tropicalBetti0 (filtrationGraphAtIndex G i) ∨
    tropicalBetti1 (filtrationGraphAtIndex G (i+1)) ≠ tropicalBetti1 (filtrationGraphAtIndex G i)
```

Then interpret the jump set as a discrete phase-transition locus.

### Additional bridge options
You only need one theorem, but these are excellent directions:
- **Matroid theory:** cycle events correspond to elements not in a spanning forest; the filtration defines a weighted graphic matroid process.
- **Probability/random graphs:** formulate a conjecture about expected number of cycle-critical thresholds in `G(n,p)`.
- **Electrical networks:** cycle births correspond to emergence of independent current loops.
- **Statistical mechanics:** threshold acts as inverse temperature, critical values as topological phase changes.

---

## Conjecture with Testable Prediction

You must include at least one falsifiable conjecture with a computational disproof path.

### Conjecture: concentration of tropical critical profiles in random weighted graphs
For `G ~ G(n,p)` with i.i.d. continuous edge weights on `[0,1]`, define the empirical cycle-birth measure
\[
\mu_G = \frac{1}{\beta_1(G)} \sum_{t \in \mathrm{CycCrit}(G)} \delta_t.
\]
Conjecture: for fixed `p` in the supercritical regime, `μ_G` converges in probability to a deterministic measure `μ_p` as `n → ∞`.

A weaker and more computationally testable version:
- the normalized count of cycle-critical values below threshold `t` converges to a deterministic function of `t`.

This is falsifiable by simulation:
1. sample many weighted random graphs,
2. compute sorted cycle-critical thresholds,
3. compare empirical distributions across `n`,
4. reject if no concentration emerges.

You may also state a finite-size scaling conjecture:
- near the giant-component threshold, the density of merge events and cycle events exhibits a crossover analogous to percolation criticality.

This would be a spectacular bridge: **tropical topology ↔ random graph phase transitions ↔ statistical mechanics**.

---

## Algorithmic Deliverable

You must produce a **verified algorithm**, not just theorem statements.

### Required algorithm
Implement an algorithm that, given a finite weighted graph:
1. sorts edges by weight,
2. incrementally inserts edges,
3. tracks connected components and cycle events,
4. outputs:
   - all tropical critical values,
   - whether each is a merge or cycle event,
   - the sequences `β₀(i)` and `β₁(i)`,
   - the degree-1 tropical persistence births.

A union-find style algorithm is ideal computationally, but if verification is easier, begin with a simpler finite-set implementation and prove correctness. Then optimize if time permits.

### Correctness theorem target
```lean
theorem computeCriticalValues_correct
  {V : Type} [Fintype V] [DecidableEq V]
  (G : WeightedGraph V) :
  let out := computeCriticalValues G
  out.cycleValues = cycleCriticalValues G ∧
  out.mergeValues = mergeCriticalValues G ∧
  out.betti0Seq = trueBetti0Seq G ∧
  out.betti1Seq = trueBetti1Seq G
```

This algorithm is essential: it turns the theory into an experimental instrument for discovering network phase transitions.

---

## File and Theorem Expectations

Your Lean development must contain at least:
- one new structure/definition,
- at least 3 substantial theorems,
- proofs using induction / `rcases` / `by_contra` / `field_simp` / multi-step `calc`,
- minimal `sorry`,
- no fake difficulty via giant definitional expansions.

Suggested file:
- `Pythagorean/TropicalBridge/TropicalMorseGraphs.lean`

Suggested theorem names:
- `betti_update_dichotomy`
- `cycle_event_iff_same_component`
- `card_cycleCritical_eq_betti1`
- `card_mergeCritical_eq_rank_drop`
- `tropical_persistentRank1_eq_classical`
- `computeCriticalValues_correct`

---

## Revolutionary Significance

If you succeed, you will have created a new dictionary:

- **weighted network filtration** = **tropical Morse flow**
- **cycle birth** = **tropical critical point of index 1**
- **component merge** = **tropical critical point of index 0**
- **barcode** = **phase-transition spectrum**

This opens a program, not just a theorem:
- a tropical theory of persistent homology,
- topological order parameters for network phase transitions,
- probabilistic laws for critical-value distributions,
- links to graphic matroids, percolation, and nonequilibrium statistical mechanics.

This is exactly the kind of result that makes a researcher say: *I did not expect tropical geometry to clarify graph phase transitions.*

---

## Application Keywords

tropical geometry; Morse theory; persistent homology; weighted graphs; random graphs; phase transitions; percolation; statistical mechanics; graphic matroids; filtered chain complexes; Betti numbers; topological data analysis; network science; barcode stability; cycle birth process

---

## Mandatory Deliverables

You must produce **all** of the following:

1. **`FUTURE_DIRECTIONS.md`**
   - 3–5 original research directions
   - each direction must include the exact sentences:
     - **“The key insight is...”**
     - **“Why now?”**
   - at least one direction must bridge to a different domain

2. **`RESEARCH_PAPER.md`**
   - standalone scientific paper
   - readable without code access
   - must explain:
     - the new definitions,
     - the main theorems,
     - why the tropical viewpoint is new,
     - algorithmic consequences,
     - future questions

3. **`ARTICLE.md`**
   - Scientific American style
   - broad audience
   - explain the mathematical ideas and why they matter
   - **do not focus on formal verification**

4. **A verified algorithm or computational method**
   - specifically for computing tropical critical values / event types / Betti evolution

5. **`demo.py`**
   - interactive or script-based demonstration
   - should:
     - generate weighted graphs,
     - compute the filtration,
     - display critical values and event types,
     - compare tropical and classical persistence in sample cases

Do not settle for a cosmetic graph-filtration formalization. Build the first rigorous tropical Morse theory for network phase transitions.

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
    "visualizations": [ { "name": "...", "code": "# matplotlib or plotly script, self-contained", "description": "What this visualizes" } ],
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
