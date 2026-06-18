Soli Deo Gloria

## Assignment: Direction 4 Reforged — Verified Near-Linear Tropical Morse Spectrum via Dynamic Homology Invariants

**Mode:** `prove`

You should not treat this as a software-engineering exercise. The real target is a theorem-level synthesis:

> **A computable Kruskal/union-find procedure recovers the 1-dimensional tropical Morse spectrum of a weighted graph, and every emitted event is certified by a homological conservation law relating connectivity, cycle rank, and filtration time.**

This is stronger, deeper, and more interesting than merely “the code matches the spec.” The breakthrough is to turn a classical graph algorithm into a **certified topological measurement process**: an executable mechanism whose output is not just correct, but mathematically interpretable as a discrete Morse-theoretic decomposition of persistent topology.

This opens a field: **verified topological algorithms with semantic certificates**, where each computational event is paired with a theorem explaining what topological quantity changed and why.

---

## Core Mathematical Objective

Build a verified algorithm
`computeTMS : EdgeWeightedGraph n → TMSpectrum`
together with a correctness theory proving:

1. **Termination** of the Kruskal-style event extraction loop.
2. **Spectral validity**: the output is sorted by filtration value and complete with respect to the edge filtration.
3. **Topological soundness**:
   - every **merge** event decreases the number of connected components by exactly `1`,
   - every **cycle** event increases the first Betti number by exactly `1`,
   - the cumulative event counts recover the graph-theoretic Euler relation
     \[
     \beta_0(t) - \beta_1(t) = |V| - |E_{\le t}|.
     \]
4. **Specification equivalence**: the computable algorithm yields the same event sequence as the abstract filtration semantics already present in the catalog.
5. **Algorithmic certificate layer**: each output event carries enough local data to reconstruct a proof witness of the associated topological change.

The real theorem is not just that Kruskal works — it is that **Kruskal computes a homology-sensitive spectral factorization of a filtration**.

---

## Precise Theorem Targets

You should formulate and prove at least the following theorem family, with exact quantifiers and Lean-ready signatures.

### New definitions you should introduce

Introduce at least one genuinely new concept not already in the catalog. Recommended:

```lean
structure CertifiedTMEvent (n : ℕ) where
  weight : ℤ
  edge : Fin n × Fin n
  eventType : TMEventType
  certifies :
    eventType = TMEventType.merge ∨ eventType = TMEventType.cycle
```

This is only the beginning; the stronger and more interesting structure is:

```lean
structure HomologyDeltaCertificate (n : ℕ) where
  before after : FiltrationStep n
  edge : Fin n × Fin n
  added : after = addEdge before edge
  delta_beta0 : ℤ
  delta_beta1 : ℤ
  euler_conservation :
    delta_beta0 - delta_beta1 = -1
```

and then package algorithm output as:

```lean
structure CertifiedTMSpectrum (n : ℕ) where
  events : List (CertifiedTMEvent n)
  sorted_by_weight : events.Pairwise (fun a b => a.weight ≤ b.weight)
  complete : True -- replace by actual completeness predicate
```

Even better: define a predicate expressing that an event sequence is **homologically exact** over a filtration:

```lean
def HomologicallyExactSpectrum {n : ℕ} (G : EdgeWeightedGraph n)
    (S : TMSpectrum) : Prop := ...
```

This is the conceptual novelty. You are not merely verifying output shape; you are formalizing **topological exactness of an event stream**.

---

## Main Theorem Statement with Lean 4 Type Signature

You should aim for a theorem of approximately the following form:

```lean
theorem computeTMS_correct
    {n : ℕ} (G : EdgeWeightedGraph n) :
    let S := computeTMS G
    S.IsSorted ∧
    S.IsCompleteFor G ∧
    HomologicallyExactSpectrum G S ∧
    S.events = abstractTMS G
```

A stronger decomposition into separately reusable theorems is preferable:

```lean
theorem computeTMS_terminates
    {n : ℕ} (G : EdgeWeightedGraph n) :
    ∃ fuel : ℕ, kruskalLoop G fuel = computeTMS G
```

```lean
theorem computeTMS_sorted
    {n : ℕ} (G : EdgeWeightedGraph n) :
    (computeTMS G).IsSorted
```

```lean
theorem computeTMS_complete
    {n : ℕ} (G : EdgeWeightedGraph n) :
    (computeTMS G).IsCompleteFor G
```

```lean
theorem computeTMS_event_sound
    {n : ℕ} (G : EdgeWeightedGraph n) (e : Edge) :
    e ∈ G.edges →
    let step := processEdge G e
    (step.eventType = TMEventType.merge →
      beta0 step.after = beta0 step.before - 1 ∧
      beta1 step.after = beta1 step.before) ∧
    (step.eventType = TMEventType.cycle →
      beta0 step.after = beta0 step.before ∧
      beta1 step.after = beta1 step.before + 1)
```

```lean
theorem computeTMS_matches_abstract
    {n : ℕ} (G : EdgeWeightedGraph n) :
    (computeTMS G).events = abstractTMS G
```

And the deepest theorem should express the global conservation law:

```lean
theorem kruskal_homology_conservation
    {n : ℕ} (G : EdgeWeightedGraph n) :
    let S := computeTMS G
    totalMerges S + beta0_final G = n ∧
    totalCycles S = beta1_final G ∧
    totalMerges S + totalCycles S = G.edges.length
```

If possible, sharpen the final identity to the graph-theoretic rank-nullity form:
\[
\#\mathrm{cycleEvents} = |E| - |V| + \beta_0(G).
\]

Lean target:

```lean
theorem total_cycle_events_eq_cycle_rank
    {n : ℕ} (G : EdgeWeightedGraph n) :
    totalCycles (computeTMS G) = G.edges.length - n + numComponents G
```

This is mathematically powerful: it identifies the algorithmic notion of “cycle event” with the first Betti number of the final graph.

---

## Why This Would Be a Breakthrough

The important step is not path compression by itself. The breakthrough is the theorem:

> **A near-linear graph algorithm can be certified as a topological semantics engine.**

This creates a new bridge among:
- **algorithm design**: union-find / Kruskal / amortized complexity,
- **algebraic topology**: Betti numbers, Euler characteristic, filtration semantics,
- **scientific computing**: trustworthy topological summaries,
- **applied geometry / TDA**: persistence-like event extraction,
- **program verification**: certified complexity and certified semantics.

Today, many TDA pipelines are trusted empirically. This project would show that one can certify not just the final barcode-like object, but the **meaning of every event** in the computation. That is a qualitatively new standard.

---

## Catalog Build Plan

You must explicitly build on these catalog results and explain how.

### 1. `Pythagorean/TropicalMorse/Defs.lean`
Use:
- `FiltrationStep`
- `TMSpectrum`

These give the abstract semantic layer. Your algorithm should refine this specification. Do not invent a disconnected output type unless it embeds back into `TMSpectrum`.

### 2. `Pythagorean/TropicalMorse/Theorems.lean`
Use:
- `cycle_rank_additive_over_filtration`

This is the key bridge theorem. It should become the global invariant that lets you prove the “cycle event increases β₁ by 1” theorem. The intended use is:

- local edge addition changes the edge count by `1`,
- merge edges preserve cycle rank,
- non-merge edges create exactly one new independent cycle,
- therefore the event classifier can be validated against the additive cycle-rank theorem.

### 3. `Pythagorean/TropicalBridge/FiltrationPersistence.lean`
Use:
- `tropicalKernelDim_of_barcode`

This is the bridge to persistence semantics. Once you prove `computeTMS_matches_abstract`, this theorem should let you derive a downstream corollary that the computable spectrum determines the same persistence-style kernel dimensions as the abstract barcode reconstruction. This is the key cross-domain theorem: graph algorithmics → tropical persistence invariants.

A possible theorem:

```lean
theorem computeTMS_preserves_tropical_kernel_dim
    {n : ℕ} (G : EdgeWeightedGraph n) :
    tropicalKernelDim_of_barcode (computeTMS G) =
    tropicalKernelDim_of_barcode (abstractTMS G)
```

If the exact signature differs, adapt accordingly, but preserve the idea.

---

## Proof Strategy Architecture

You must give yourself at least 2–3 genuine proof paths and choose one as primary.

### Strategy A: Filtration refinement via edge-order induction
**Most promising.**

1. Sort edges by weight and define the Kruskal loop as a fold over this ordered list.
2. Prove an induction theorem over prefixes:
   - the union-find state matches connected components of the prefix subgraph,
   - the emitted event list equals the abstract event list of that prefix filtration,
   - β₀ and β₁ satisfy the Euler conservation law at each step.
3. Deduce correctness for the full edge list.

Why this is strongest:
- It aligns perfectly with existing `FiltrationStep` semantics.
- It naturally supports sortedness/completeness.
- It turns global correctness into a reusable prefix invariant.
- It avoids proving too much low-level union-find behavior all at once.

Essential tactics: `induction` on sorted edge list, `rcases` on connectivity cases, `by_contra` for event misclassification, `calc` chains for Euler characteristic identities.

---

### Strategy B: Abstract disjoint-set quotient semantics
1. Define an abstract partition structure representing connected components.
2. Prove that each union operation corresponds to quotient refinement of the vertex set.
3. Show that the event classifier is exactly the dichotomy:
   - endpoints in different blocks ⇒ merge,
   - endpoints in same block ⇒ cycle.
4. Transport these facts to `FiltrationStep` homology invariants.

Why it is attractive:
- Conceptually clean.
- Separates combinatorial connectivity from implementation details.
- Makes future generalizations to higher-dimensional cell complexes more plausible.

Why it is less immediate:
- Lean quotient/partition reasoning can become technically heavy.
- You may spend too much effort on infrastructure.

---

### Strategy C: Matroid-theoretic proof of event correctness
1. Interpret the graph filtration in the graphic matroid.
2. Show merge events correspond to independent edge insertions; cycle events correspond to circuit-closing insertions.
3. Use rank increments to prove:
   - independent insertion reduces β₀ by 1,
   - dependent insertion increases β₁ by 1.
4. Transfer to TMS semantics.

Why this is visionary:
- It reveals the algorithm as computing a **matroidal Morse spectrum**.
- It would immediately suggest extensions to representable matroids and tropical linear spaces.

Why it is risky:
- You may need more infrastructure than currently available in Mathlib/catalog.
- Best treated as a theorem-level corollary or FUTURE_DIRECTIONS item unless the needed machinery is already close.

**Recommendation:** Use Strategy A as the backbone, borrow the conceptual language of Strategy C in the paper.

---

## Required Deep Theorems

You must include at least 3 nontrivial theorems using real proof tactics. Suggested minimum set:

### Theorem 1: Prefix connectivity invariant
```lean
theorem kruskal_prefix_components_correct
    {n : ℕ} (G : EdgeWeightedGraph n) :
    ∀ k,
    let st := kruskalStateAfter G k
    UFRepresentsComponents st.uf (prefixSubgraph G k)
```

This should require induction on `k`, `rcases` on whether the new edge joins distinct components, and multi-step reasoning.

### Theorem 2: Local homology delta theorem
```lean
theorem edge_addition_homology_delta
    {n : ℕ} (F : FiltrationStep n) (e : Edge) :
    let F' := addEdge F e
    (ConnectedIn F e.1 e.2 →
      beta0 F' = beta0 F ∧ beta1 F' = beta1 F + 1) ∧
    (¬ ConnectedIn F e.1 e.2 →
      beta0 F' = beta0 F - 1 ∧ beta1 F' = beta1 F)
```

This is the local semantic heart of the project.

### Theorem 3: Global conservation / equivalence theorem
```lean
theorem computeTMS_semantic_correctness
    {n : ℕ} (G : EdgeWeightedGraph n) :
    HomologicallyExactSpectrum G (computeTMS G) ∧
    (computeTMS G).events = abstractTMS G
```

This should combine induction, contradiction, and calculation.

### Optional Theorem 4: Persistence bridge theorem
```lean
theorem computeTMS_barcode_compatibility
    {n : ℕ} (G : EdgeWeightedGraph n) :
    BarcodeInvariant (computeTMS G) = BarcodeInvariant (abstractTMS G)
```

This is the cross-domain theorem that makes the work field-opening rather than merely algorithmic.

---

## Complexity Target

The assignment title says **Verified O(E log E) Implementation with Correctness Certificate**. You should sharpen this mathematically.

There are really two complexity layers:

1. **Sorting cost:** `O(E log E)` for ordering weighted edges.
2. **Dynamic connectivity cost:** `O(E α(V))` for union-find operations, if path compression / union by rank are formalized.

So the strongest honest theorem is:
\[
T(E,V) = O(E \log E + E \alpha(V)).
\]
Since sorting dominates asymptotically under ordinary assumptions, one gets `O(E log E)` overall.

You should formulate a theorem in the style:

```lean
theorem computeTMS_time_bound
    {n : ℕ} (G : EdgeWeightedGraph n) :
    TimeComplexity (computeTMS G) ∈ bigO (fun _ => G.edges.length * Nat.log G.edges.length + G.edges.length * inverseAckermann n)
```

If a full asymptotic framework is too heavy, prove a **certified step-count bound** instead:

```lean
theorem computeTMS_step_bound
    {n : ℕ} (G : EdgeWeightedGraph n) :
    stepCount G ≤ C * G.edges.length * Nat.log (G.edges.length + 1) + D * G.edges.length
```

Do not fake the amortized proof. If full `α(V)` formalization is too large for this cycle, prove the stronger semantic theorems first and present the `α(V)` bound as a clearly marked conjectural extension. But if you can do it, that would be a major result.

---

## Cross-Domain Connections You Must Make Explicit

At least one theorem must bridge to another domain. Here are the best options.

### Bridge 1: Graph algorithms ↔ algebraic topology
This is mandatory and central:
- merge event ↔ decrease of `β₀`,
- cycle event ↔ increase of `β₁`.

### Bridge 2: TDA ↔ tropical geometry
Use the persistence/barcode theorem from `TropicalBridge/FiltrationPersistence.lean` to show that the algorithmic spectrum determines tropical kernel dimensions.

### Bridge 3: Algorithms ↔ matroid theory
Even if not fully formalized, state and partially formalize the correspondence:
- merge edges are rank-increasing,
- cycle edges are rank-preserving but nullity-increasing.

A possible theorem statement:

```lean
theorem cycle_event_iff_matroid_dependence
    {n : ℕ} (G : EdgeWeightedGraph n) (e : Edge) :
    IsCycleEvent G e ↔ MatroidDependentAfterPrefix G e
```

### Bridge 4: Topology ↔ physics
In `ARTICLE.md` and perhaps `RESEARCH_PAPER.md`, interpret the event stream as a **discrete phase-transition ledger**:
- merge = annihilation of connected components,
- cycle = birth of circulation modes.

This is not fluff; it gives a scientific language for the significance.

---

## Conjecture With Falsifiable Computational Prediction

You must state at least one falsifiable conjecture, not just an aspiration.

### Recommended conjecture
> **Conjecture (Stability of TMS event multiplicities under weight perturbation).**
> For any finite graph `G`, if all edge weights are perturbed without changing their strict total order, then `computeTMS G` produces the same sequence of event types, and only the numerical filtration values change.

This has a clear computational falsification test:
1. Generate weighted graphs.
2. Apply random monotone perturbations preserving edge order.
3. Compare event-type sequences.
4. A single mismatch refutes the conjecture.

Lean-style statement:
```lean
conjecture event_types_depend_only_on_edge_order
    {n : ℕ} (G H : EdgeWeightedGraph n) :
    sameStrictEdgeOrder G H →
    eventTypes (computeTMS G) = eventTypes (computeTMS H)
```

This is mathematically interesting because it says the topological event structure is **order-theoretic rather than metric**, which points toward matroid and tropical interpretations.

### Stronger alternative conjecture
> The TMS spectrum of a graph filtration is a complete invariant of the 1-skeleton barcode up to weight-order equivalence.

This is more ambitious and more revolutionary, but also easier to falsify experimentally.

---

## Implementation Blueprint

You should organize the development into layers.

### Layer 1: Computable graph filtration engine
- edge sorting by weight,
- prefix subgraphs,
- computable connectivity state.

### Layer 2: Union-find semantics
- parent/rank structure,
- find/union correctness,
- if feasible, path compression correctness,
- extensional theorem: same connectivity relation as prefix graph.

### Layer 3: Event extraction
- classify each edge as merge or cycle,
- emit certified event record,
- accumulate into `TMSpectrum`.

### Layer 4: Semantic proof
- sortedness,
- completeness,
- local homology delta,
- global equivalence with abstract filtration semantics.

### Layer 5: Persistence/tropical bridge
- connect output to barcode/kernel-dimension theorem from the catalog.

---

## Suggested Lean Artifacts

You should aim to define something close to:

```lean
def processEdge :
    KruskalState n → WeightedEdge n → KruskalState n
```

```lean
def computeTMS :
    EdgeWeightedGraph n → TMSpectrum
```

```lean
def prefixSubgraph :
    EdgeWeightedGraph n → ℕ → EdgeWeightedGraph n
```

```lean
def IsMergeEdgeAtPrefix :
    EdgeWeightedGraph n → ℕ → WeightedEdge n → Prop
```

```lean
def IsCycleEdgeAtPrefix :
    EdgeWeightedGraph n → ℕ → WeightedEdge n → Prop
```

```lean
def EventDeltaExact :
    FiltrationStep n → CertifiedTMEvent n → Prop
```

These definitions should not be ornamental. Each should participate in a theorem.

---

## Proof Tactic Requirements

Your file must contain at least 3 theorems whose proofs genuinely use:
- `induction`
- `rcases`
- `by_contra`
- `field_simp` if rational-weight normalization appears
- multi-step `calc`

Recommended places:
- induction on edge prefixes,
- contradiction for impossible simultaneous “merge and cycle” classification,
- `calc` for Euler characteristic identities:
  \[
  \beta_1 = |E| - |V| + \beta_0.
  \]

Do not trivialize statements into decidable finite checks.

---

## Application Keywords

Include these explicitly in your paper, article, and metadata-style prose:

**Application keywords:** topological data analysis, persistent homology, certified algorithms, union-find, Kruskal filtration, Betti numbers, Euler characteristic, tropical geometry, barcode reconstruction, scientific computing, trustworthy AI, network science, phase transitions, matroid theory.

---

## Deliverables You Must Produce

You must produce **all** of the following.

### 1. `FUTURE_DIRECTIONS.md`
3–5 original research directions. Each direction must include:
- a sentence beginning **“The key insight is...”**
- a sentence beginning **“Why now?”**
- at least one direction bridging to a different domain.

Strong candidate directions:
- higher-dimensional simplicial filtrations,
- matroidal tropical Morse spectra,
- stability theory under perturbations,
- certified dynamic persistence for streaming graphs,
- statistical mechanics interpretation of event spectra.

### 2. `RESEARCH_PAPER.md`
A standalone scientific document explaining:
- the problem,
- the exact theorem,
- why this is a conceptual breakthrough,
- proof architecture,
- computational implications,
- limitations,
- future work.

It must be readable without any code access.

### 3. `ARTICLE.md`
Scientific American style.
Do **not** focus on formal verification machinery.
Focus on:
- why topology can be computed event-by-event,
- why trustworthy topological summaries matter,
- why this changes scientific computing.

### 4. Verified algorithm / computational method
Not just theorem statements. You must deliver executable `computeTMS` and associated certificate-checking machinery.

### 5. `demo.py`
Interactive demonstration:
- generate random weighted graphs,
- run Python reference implementation,
- run extracted/ported Lean-aligned implementation if available,
- display event sequence, merge/cycle counts, and Betti-number checks,
- test the falsifiable conjecture on random monotone perturbations.

---

## Final Call to Arms

Do not settle for “Kruskal is correct.” That is not the theorem.

The theorem is that a near-linear combinatorial process computes a **topological event calculus** whose every step is certified by homological law, whose global output matches abstract filtration semantics, and whose structure interfaces with tropical persistence invariants.

If you pull this off cleanly in Lean 4, you will not merely verify an algorithm. You will demonstrate that **topological computation can be made semantically exact, executable, and reusable as a scientific primitive**. That is a new standard, and it is worth building.

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
