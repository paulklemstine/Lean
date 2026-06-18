## Assignment: Compositional tropical semantics for event graphs

Prove a genuinely new bridge theorem: **modular composition of timed event-graph systems is functorially represented by tropical matrix operations**, so that throughput bounds and feasibility certificates become compositional and machine-checkable in Lean 4.

This is not a request for a minor encoding exercise. The breakthrough is to turn max-plus / tropical scheduling folklore into a **certified algebra of composition**: series composition becomes tropical matrix multiplication, parallel composition becomes tropical block sum / tropical supremum composition, and throughput certification becomes a reusable theorem rather than a per-instance calculation.

The right target is a theorem family for a concrete but expressive class of event graphs first, then abstraction upward.

---

## Mode
**prove**

---

## Core breakthrough target

Formalize a class of weighted event graphs with tropical transfer matrices, and prove that composition on graphs matches composition on matrices.

A mathematically sharp first version is:

- each event graph \(G\) has:
  - a finite set of interface events `ι`
  - internal weighted precedence constraints
  - an associated tropical transfer matrix \(M_G\) over `ℝ ∪ {-\infty}` or an equivalent Lean-friendly max-plus carrier
- **series composition** \(G₂ ∘ G₁\) corresponds to tropical matrix multiplication
- **parallel composition** \(G₁ ∥ G₂\) corresponds to tropical block-diagonal sum, or to pointwise tropical max if you choose a shared-interface semantics
- the `k`-step execution time / schedule propagation is given by tropical matrix powers
- throughput / cycle time certification is inherited compositionally from matrix inequalities

This opens a formal pathway from graph-theoretic scheduling to certified hardware/software timing analysis.

---

## Precise theorem statements

You should pick a concrete formalization where the statements are exactly provable. A highly viable first layer is finite interface semantics with weighted adjacency matrices over `ℝ`.

If using plain `ℝ`, interpret tropical multiplication as addition and tropical addition as `max`, with unreachable edges encoded by a sufficiently negative sentinel only if necessary. If possible, define a dedicated max-plus structure instead.

### Theorem 1: series composition = tropical matrix multiplication

For compatible event graphs `G₁ : EventGraph α β` and `G₂ : EventGraph β γ`, with transfer semantics
`transfer : EventGraph ι κ → Matrix ι κ ℝ`, prove:

```lean
theorem transfer_series
  {α β γ : Type} [Fintype α] [Fintype β] [Fintype γ]
  [DecidableEq α] [DecidableEq β] [DecidableEq γ]
  (G₁ : EventGraph α β) (G₂ : EventGraph β γ) :
  transfer (series G₁ G₂) = tropicalMul (transfer G₁) (transfer G₂)
```

where `tropicalMul` should mean
\[
(A \otimes B)_{i,k} = \max_j (A_{i,j} + B_{j,k}).
\]

A more explicit Lean signature, if you define tropical multiplication directly on matrices:

```lean
def tropicalMatMul
  {m n p : Type} [Fintype m] [Fintype n] [Fintype p]
  [DecidableEq m] [DecidableEq n] [DecidableEq p]
  (A : Matrix m n ℝ) (B : Matrix n p ℝ) : Matrix m p ℝ :=
fun i k => Finset.univ.sup fun j => A i j + B j k

theorem transfer_series
  {α β γ : Type} [Fintype α] [Fintype β] [Fintype γ]
  [DecidableEq α] [DecidableEq β] [DecidableEq γ]
  (G₁ : EventGraph α β) (G₂ : EventGraph β γ) :
  transfer (series G₁ G₂) = tropicalMatMul (transfer G₁) (transfer G₂)
```

If `Finset.sup` over `ℝ` becomes awkward, use `WithBot ℝ` or `ℝ≥∞` with order-dual conventions, whichever gives the cleanest supremum API.

---

### Theorem 2: parallel composition = tropical block sum

For disjoint interfaces:

```lean
theorem transfer_parallel
  {α₁ β₁ α₂ β₂ : Type}
  [Fintype α₁] [Fintype β₁] [Fintype α₂] [Fintype β₂]
  [DecidableEq α₁] [DecidableEq β₁] [DecidableEq α₂] [DecidableEq β₂]
  (G₁ : EventGraph α₁ β₁) (G₂ : EventGraph α₂ β₂) :
  transfer (parallel G₁ G₂) = tropicalBlockDiag (transfer G₁) (transfer G₂)
```

where `tropicalBlockDiag` is the matrix on `Sum α₁ α₂ → Sum β₁ β₂ → ℝ` with the two transfers on diagonal blocks and tropical zero/off-support elsewhere.

If you choose shared-source/shared-sink semantics instead, then parallel composition may satisfy:

```lean
theorem transfer_parallel_shared
  {α β : Type} [Fintype α] [Fintype β] [DecidableEq α] [DecidableEq β]
  (G₁ G₂ : EventGraph α β) :
  transfer (parallelShared G₁ G₂) = tropicalAdd (transfer G₁) (transfer G₂)
```

with `tropicalAdd A B := fun i j => max (A i j) (B i j)`.

This version is especially elegant and aligns directly with nondeterministic / resource-sharing interpretations.

---

### Theorem 3: compositional throughput certification

Define a throughput/cycle-time bound predicate `ThroughputLE G λ` or dually `CycleTimeLE G c`. Then prove a modular theorem such as:

```lean
theorem throughput_series_certified
  {α β γ : Type} [Fintype α] [Fintype β] [Fintype γ]
  [DecidableEq α] [DecidableEq β] [DecidableEq γ]
  (G₁ : EventGraph α β) (G₂ : EventGraph β γ) {c₁ c₂ : ℝ}
  (h₁ : CycleTimeLE G₁ c₁) (h₂ : CycleTimeLE G₂ c₂) :
  CycleTimeLE (series G₁ G₂) (c₁ + c₂)
```

and for parallel composition:

```lean
theorem throughput_parallel_certified
  {α₁ β₁ α₂ β₂ : Type}
  [Fintype α₁] [Fintype β₁] [Fintype α₂] [Fintype β₂]
  [DecidableEq α₁] [DecidableEq β₁] [DecidableEq α₂] [DecidableEq β₂]
  (G₁ : EventGraph α₁ β₁) (G₂ : EventGraph α₂ β₂) {c₁ c₂ : ℝ}
  (h₁ : CycleTimeLE G₁ c₁) (h₂ : CycleTimeLE G₂ c₂) :
  CycleTimeLE (parallel G₁ G₂) (max c₁ c₂)
```

This is the theorem that matters scientifically: it says timing certificates compose by tropical arithmetic.

---

## Stronger theorem if the infrastructure supports it

If you can define max-plus spectral radius / maximum cycle mean for square transfer matrices, aim for:

```lean
theorem maxCycleMean_parallel
  {α β : Type} [Fintype α] [Fintype β] [DecidableEq α] [DecidableEq β]
  (G₁ G₂ : EventGraph α β) :
  maxCycleMean (transfer (parallelShared G₁ G₂)) =
    max (maxCycleMean (transfer G₁)) (maxCycleMean (transfer G₂))
```

and a subadditivity result for series composition:

```lean
theorem maxCycleMean_series_le
  {α β γ : Type} [Fintype α] [Fintype β] [Fintype γ]
  [DecidableEq α] [DecidableEq β] [DecidableEq γ]
  (G₁ : EventGraph α β) (G₂ : EventGraph β γ) :
  maxCycleMean (transfer (series G₁ G₂)) ≤
    maxCycleMean (transfer G₁) + maxCycleMean (transfer G₂)
```

Even a one-sided inequality here would already be a major formal contribution.

---

## Why this is a breakthrough

The literature knows that event graphs, synchronous dataflow, and max-plus linear systems are deeply related. What is missing is a **proof-relevant, compositional, reusable formal semantics** where:

1. graph composition is a certified algebraic operation,
2. throughput proofs become transportable across system boundaries,
3. hardware pipelines, streaming DSP graphs, and timetable systems all inherit the same theorem.

This is the seed of a new field direction: **formal tropical systems theory**.

It would make Lean a platform not just for abstract algebra or theorem proving, but for **certified scheduling science**.

---

## 2–3 proof strategy paths

### Strategy A: direct path semantics via longest weighted paths
Most promising for a first theorem.

1. Define `transfer G i j` as the maximum weight of any admissible path from input event `i` to output event `j`.
2. Show that paths in `series G₁ G₂` decompose uniquely into a path through `G₁` followed by one through `G₂`.
3. Convert this decomposition into
   \[
   transfer(series\ G₁\ G₂)_{i,k} = \max_j (transfer(G₁)_{i,j} + transfer(G₂)_{j,k}).
   \]
4. For parallel composition, prove paths remain confined to one summand, yielding block-diagonal or pointwise-max semantics.

Why this is best: it is combinatorial, finite, and Lean-friendly. It avoids premature spectral theory and makes the semantics transparent.

---

### Strategy B: categorical/algebraic semantics via enriched relations
More visionary, likely second stage.

1. Model an event graph as a morphism in a category enriched over the tropical semiring.
2. Define `transfer` as a functor from event graphs with composition to tropical matrices with tropical multiplication.
3. Prove functoriality:
   - identities map to tropical identity matrices,
   - series maps to composition,
   - parallel maps to monoidal product.

Why this matters: this upgrades the result from “a theorem about graphs” to “a semantics theorem.” It opens future work on traced monoidal categories, feedback systems, and compiler correctness for timing models.

---

### Strategy C: inductive structured networks
Good engineering route if general event graphs are too heavy.

1. Define a syntax of compositional systems:
   ```lean
   inductive Network
   | atom : ...
   | series : Network → Network → Network
   | parallel : Network → Network → Network
   ```
2. Give both operational semantics and matrix semantics recursively.
3. Prove by structural induction that they coincide.

Why useful: this reduces graph-theoretic complexity and gives a clean certified DSL for pipelines and stream networks. It is likely the fastest route to usable throughput certification.

---

## Recommended execution order

1. **Start with Strategy C or A on acyclic or single-rate event graphs.**
2. Prove exact composition theorems for transfer matrices.
3. Then define compositional throughput bounds from matrix inequalities.
4. Only then attempt cycle-mean/spectral statements.

The biggest risk is overcommitting to a general timed automata formalization too early. Win first with a mathematically crisp event-graph fragment.

---

## How to build on catalog theorems

The current catalog is tropical-heavy but not yet systems-theoretic. Use that asymmetry creatively.

- `tropical_and_distributes` and `bool_and_as_tropical_max` suggest an existing pattern: logical/system composition can be encoded by tropical `max`-algebraic operations. Use these as conceptual precedents for proving that **parallel composition corresponds to tropical addition/max**.
- `tropical_and_bound` may be repurposed as a lemma pattern for compositional bounds: if two components satisfy lower/upper timing constraints, the combined system inherits a tropical combination bound.
- `tropical_certified_robustness` and `multi_class_tropical_certified_robustness` show the codebase already contains certified tropical inequalities. Reuse their style of theorem packaging to state `CycleTimeLE` or `ThroughputGE` as certifiable predicates, not just raw equalities.

The conceptual leap is: move from tropical geometry of classifiers to tropical algebra of schedules.

---

## Cross-domain connections

- **VLSI design**: compositional delay and throughput certification for hardware pipelines, handshake circuits, and latency-insensitive design.
- **Signal processing**: certified rates for synchronous dataflow and streaming kernels; reusable bounds under pipeline fusion and fork-join.
- **Embedded systems**: formal end-to-end timing analysis for reactive tasks and sensor-processing chains.
- **Railway signaling**: timetable feasibility and delay propagation via max-plus event systems.
- **Concurrency theory**: bridge to traced monoidal categories and weighted automata semantics.
- **Control theory**: entry point to formal max-plus linear systems and discrete-event dynamical systems.
- **Tropical geometry**: interpretation of scheduling constraints as tropical linear maps and feasibility regions as tropical polyhedra.
- **Formal methods**: semantics-preserving compilation from network DSLs to certified timing certificates.

This is exactly the kind of cross-pollination that can create a new formalized discipline.

---

## Suggested Lean architecture

You will likely want something like:

```lean
structure EventGraph (ι κ : Type) [Fintype ι] [Fintype κ] where
  State : Type
  instFintypeState : Fintype State
  instDecidableEqState : DecidableEq State
  inEdge  : ι → State → ℝ
  inner   : State → State → ℝ
  outEdge : State → κ → ℝ
```

or a path-based / matrix-only interface if graph internals are unnecessary initially.

Then:

```lean
def transfer (G : EventGraph ι κ) : Matrix ι κ ℝ := ...
def series   (G₁ : EventGraph α β) (G₂ : EventGraph β γ) : EventGraph α γ := ...
def parallel (G₁ : EventGraph α₁ β₁) (G₂ : EventGraph α₂ β₂) :
  EventGraph (Sum α₁ α₂) (Sum β₁ β₂) := ...
```

If graph internals make proofs painful, define a first-class compositional syntax with an interpretation into matrices and only later connect syntax to actual event graphs.

---

## Minimal nontrivial milestone

If the full throughput theorem is too ambitious in one cycle, the minimum acceptable breakthrough is:

1. define a compositional network syntax,
2. define tropical matrix semantics,
3. prove:
   - `denote (series N₁ N₂) = tropicalMatMul (denote N₁) (denote N₂)`
   - `denote (parallel N₁ N₂) = tropicalBlockDiag (denote N₁) (denote N₂)` or pointwise `max`,
4. derive one certified bound theorem for latency/throughput from matrix inequalities.

That already establishes the modular certification principle.

---

## Application keywords

**max-plus algebra, tropical semiring, event graphs, synchronous dataflow, discrete-event systems, throughput certification, cycle time, longest-path semantics, hardware timing, railway scheduling, compositional verification, formal methods, matrix semantics, categorical semantics, stream processing**

---

## Deliverables

1. Lean file(s) proving the composition theorem(s).
2. At least one executable small example:
   - a 2-stage pipeline,
   - a fork-join streaming graph,
   - or a toy railway segment composition.
3. Minimize `sorry`; isolate any unavoidable gaps behind clearly named lemmas.
4. Produce `FUTURE_DIRECTIONS.md` with **3–5 concrete breakthrough next steps**, for example:
   - formalize max-plus spectral radius / maximum cycle mean and derive asymptotic throughput theorems,
   - prove a tropical Kleene-star theorem for event-graph reachability and buffering,
   - connect compositional event-graph semantics to weighted automata or enriched category theory,
   - build a certified compiler from a small SDF DSL to tropical transfer matrices,
   - formalize residuation / controller synthesis for timing repair in discrete-event systems.

Be bold: the real objective is not just one theorem, but the birth of a formal tropical theory of compositional timing.

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
DELIVERABLE 4 — Python Code: Demos, Visualizations, Algorithms
────────────────────────────────────────────────────────────────────────────
- **demo.py** — Working Python code demonstrating the theorems with
  concrete numerical examples. Make the math tangible.
- **visualizations** — matplotlib / plotly charts showing key mathematical
  structures, convergence behavior, phase diagrams, etc.
  Save figures as PNG/SVG files for inclusion in the HTML package.
- **algorithms.py** — Implement any algorithms from the research paper.
  Include docstrings, type hints, and example usage.
- **applications.py** — Code showing real-world applications of the results.
  If the math applies to ML, crypto, physics — show it working.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 5 — FUTURE_DIRECTIONS.md  (MANDATORY — drives next cycle)
────────────────────────────────────────────────────────────────────────────
The MOST IMPORTANT deliverable. Structured roadmap of breakthrough
research opportunities opened by this work. See detailed spec below.

**Team Directive**: Create a team to conduct research, brainstorm hypotheses,
run experiments, validate data, update knowledge base and iterate forever.
Each future direction should be specific enough for a team to pick up and
pursue with clear hypotheses, proof strategies, and cross-domain connections.

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
    "visualizations": [ { "name": "...", "data": "base64 encoded URI or inline SVG string" } ],
    "lean_proofs": "Raw lean code..."
  }
• **String Encoding**: Ensure all Markdown and code is properly JSON-escaped (e.g. `
` for newlines).
• **Embedded images**: ALL images (charts, diagrams, visualizations) MUST be
  embedded directly in the JSON. If you generate matplotlib/plotly figures, convert them to base64
  data URIs (e.g., `data:image/png;base64,...`). For SVG diagrams, put the raw `<svg>...</svg>`
  string into the `data` field. NEVER reference external image files.
• **Complete**: Include ALL content from the article, research paper, and code. This JSON file
  is the sole data source for the frontend web application.

────────────────────────────────────────────────────────────────────────────

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real, useful, and
beautiful. Every deliverable should be something you'd be proud to show.

Research domain: Tropical
Research mode: prove
