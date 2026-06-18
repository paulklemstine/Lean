## Assignment: Master-Class Research via Conceptual Dependency Graphs and Critical Path Analysis

Mode: **prove** with a supporting **formalize** component.

You are not being asked for a metaphor about “deep ideas.” You are being asked to create a formal theory of **conceptual depth** extracted from actual Lean proof objects, and then prove nontrivial theorems showing that longest dependency chains force lower bounds on the depth of any discovery process. If this works, it opens a new field: **metamathematical complexity theory for formalized mathematics**, where one can certify that some results are intrinsically “master-class” because every route to them crosses a long conceptual bottleneck.

This is a cold start, so do two things in parallel:

1. If you can quickly close a known priority `sorry_fill` in `CarmichaelComposite` or `Fib_gcd_identity`, do that first to reduce global debt.
2. Then pivot immediately to this research program and produce a new standalone file, ideally under something like:
   `Speculative/AutoResearch/ConceptualDependencyCriticalPath.lean`

The target is a theorem suite, not a toy definition.

---

## Core Vision

Formalize a finite directed acyclic graph of conceptual dependencies extracted from proof terms, define:

- a notion of **conceptual depth** of a theorem/node,
- a notion of **discovery procedure** as a traversal or generation process on the graph,
- the **critical path length** as the maximum chain length in the dependency DAG,

and prove that any valid discovery of a node must have depth at least the longest prerequisite chain below it. Then prove a separation theorem: under a precise shallow-search model, there exist target results on the critical path that cannot be discovered by bounded-depth exploration, while they are reachable by critical-path-guided exploration.

This is revolutionary because it turns “deep theorem” from rhetoric into a certifiable graph invariant. It would enable:
- theorem-proving guidance based on conceptual bottlenecks,
- automated curriculum extraction from libraries,
- metascientific analysis of why some research programs stall,
- principled steering of Aether toward nonlocal, breakthrough targets.

Application keywords: **metamathematics, proof complexity, theorem discovery, DAG algorithms, automated reasoning, curriculum extraction, research planning, formal epistemology, proof mining, AI for mathematics**

---

## Precise Theorem Targets

You need at least one clean abstract theorem and one algorithmic/formal-extraction theorem.

### Target A: Critical path lower-bounds conceptual depth

Work in a finite DAG `G = (V,E)`.

Suggested definitions:
- `Reaches G u v`: reflexive-transitive closure of edges.
- `depth G v : ℕ`: maximum length of a directed path ending at `v`.
- `DiscoverableIn G S n v`: node `v` can be discovered from seed set `S` in at most `n` conceptual rounds, where each round may add only nodes all of whose immediate predecessors are already discovered.
- `SeedsBelow G S v`: every source ancestor needed for `v` is in `S`.

Then prove:

> **Theorem A1 (depth lower bound).**  
> For every finite DAG `G`, seed set `S`, node `v`, if `v` is discoverable from `S` in at most `n` rounds and all source ancestors of `v` lie in `S`, then `depth G v ≤ n`.

A Lean-style type signature could look like:

```lean
theorem depth_le_of_discoverableIn
  {V : Type*} [Fintype V] [DecidableEq V]
  (G : SimpleGraph V)
  (hdag : IsDag G)
  (S : Finset V)
  (discoverableIn : Finset V → ℕ → V → Prop)
  (depth : V → ℕ)
  (hmono : ∀ {T n v}, discoverableIn T n v → discoverableIn T (n+1) v)
  (hstep :
    ∀ {n v},
      discoverableIn S (n+1) v →
      v ∈ S ∨ ∀ u, G.Adj u v → discoverableIn S n u)
  (hdepth_spec :
    ∀ v, depth v =
      sSup {m : ℕ | ∃ p : List V, p ≠ [] ∧ p.getLast? = some v ∧ DirectedPath G p ∧ p.length = m+1})
  :
  ∀ {n v}, discoverableIn S n v → depth v ≤ n
```

That exact signature may be too ambitious initially; simplify if needed. The mathematical content matters more than the first-pass API.

A more implementable version is to define discovery recursively:

```lean
def layer (G : SimpleGraph V) : Finset V → Finset V
def discovered (G : SimpleGraph V) (S : Finset V) : ℕ → Finset V
def depth (G : SimpleGraph V) (v : V) : ℕ
```

and prove:

```lean
theorem mem_discovered_imp_depth_le
  {V : Type*} [Fintype V] [DecidableEq V]
  (G : SimpleGraph V) (hdag : IsDag G) (S : Finset V) :
  ∀ {n v}, v ∈ discovered G S n → depth G v ≤ n
```

This is the central theorem.

---

### Target B: Critical path is attained and yields hard targets for shallow search

> **Theorem B1 (critical path attainment).**  
> In every finite nonempty DAG, there exists a node `v` whose conceptual depth equals the global critical path length.

Lean-style target:

```lean
theorem exists_node_of_depth_eq_criticalPath
  {V : Type*} [Fintype V] [DecidableEq V]
  (G : SimpleGraph V) (hdag : IsDag G) [Nonempty V] :
  ∃ v : V, depth G v = criticalPathLength G
```

where `criticalPathLength G := Finset.univ.sup depth`.

This should be straightforward once depth is defined pointwise.

Then prove the real separation theorem:

> **Theorem B2 (shallow exploration misses deep targets).**  
> If `k < criticalPathLength G`, then there exists a node `v` not discoverable in `k` rounds from the source set.

Lean-style target:

```lean
theorem exists_not_discoverable_within_of_lt_criticalPath
  {V : Type*} [Fintype V] [DecidableEq V]
  (G : SimpleGraph V) (hdag : IsDag G)
  (S : Finset V)
  (hsources : ∀ v, IsSource G v → v ∈ S)
  {k : ℕ}
  (hk : k < criticalPathLength G) :
  ∃ v : V, v ∉ discovered G S k
```

This theorem is the exact formal content behind “shallow exploration cannot reach master-class results.”

---

### Target C: Critical-path-guided exploration is complete on finite DAGs

To justify the Aether claim, prove not merely a lower bound but a constructive upper-bound method.

> **Theorem C1 (guided completeness).**  
> If one repeatedly expands a frontier by selecting nodes whose predecessors are already discovered, then after `criticalPathLength G` rounds all nodes are discovered.

Lean-style target:

```lean
theorem discovered_eq_univ_at_criticalPath
  {V : Type*} [Fintype V] [DecidableEq V]
  (G : SimpleGraph V) (hdag : IsDag G)
  (S : Finset V)
  (hsources : ∀ v, IsSource G v → v ∈ S) :
  discovered G S (criticalPathLength G) = Finset.univ
```

This gives the positive half: critical-path-aware exploration is not just “deeper,” it is complete in the optimal number of rounds up to your model.

---

## Stronger Breakthrough Variant

If feasible, go beyond ordinary graph depth and define **weighted conceptual depth**:

- each node has a weight `w : V → ℕ` measuring local conceptual novelty,
- path cost is the sum of weights,
- weighted critical path bounds weighted discovery complexity.

Then prove:

```lean
theorem weightedDepth_le_of_discoverableIn
  ...
```

This would be genuinely field-opening, because it distinguishes long-but-routine chains from short-but-revolutionary conceptual jumps.

---

## Formalization Architecture in Lean 4

A practical architecture:

### 1. Define a custom finite dependency DAG
Mathlib’s graph APIs may or may not be ideal for directed acyclic graphs with computable predecessor sets. If `SimpleGraph` becomes awkward because it is undirected, define your own structure:

```lean
structure DepGraph (V : Type*) [Fintype V] [DecidableEq V] where
  pred : V → Finset V
  acyclic : ∀ v, v ∉ transPred pred v
```

Or more realistically:

```lean
structure DepGraph (V : Type*) [Fintype V] [DecidableEq V] where
  pred : V → Finset V
  wf : WellFounded (fun u v => u ∈ pred v)
```

This is probably the most promising route. A well-founded predecessor relation is exactly what you need for recursion on depth and induction on dependencies. It avoids fighting `SimpleGraph` over orientation and paths.

Then define:

```lean
def isSource (G : DepGraph V) (v : V) : Prop := G.pred v = ∅

def depth (G : DepGraph V) : V → ℕ
| v => if h : G.pred v = ∅ then 0
       else 1 + (G.pred v).sup depth
```

This recursive definition may require well-founded recursion over `G.wf`.

### 2. Define layered discovery
```lean
def nextLayer (G : DepGraph V) (A : Finset V) : Finset V :=
  Finset.univ.filter (fun v => v ∉ A ∧ ∀ u, u ∈ G.pred v → u ∈ A)

def discovered (G : DepGraph V) (S : Finset V) : ℕ → Finset V
| 0 => S
| n+1 => discovered G S n ∪ nextLayer G (discovered G S n)
```

### 3. Define critical path
```lean
def criticalPathLength (G : DepGraph V) : ℕ :=
  Finset.univ.sup G.depth
```

### 4. Prove monotonicity and soundness lemmas
- `discovered_mono`
- `mem_nextLayer_iff`
- predecessors of a discovered node are discovered earlier
- `depth_pred_lt_depth`

These are the engine-room lemmas.

---

## Proof Strategy Options

### Strategy A: Well-founded recursion on predecessor relation
This is the most promising strategy.

1. Define `depth` by well-founded recursion using the predecessor relation.
2. Prove the key strict inequality: if `u ∈ pred v`, then `depth u < depth v`.
3. Induct on discovery round `n` to prove `v ∈ discovered G S n → depth v ≤ n`.

Why this is strongest: the well-founded predecessor relation aligns exactly with conceptual dependency and avoids heavy path combinatorics. It is likely the cleanest Lean development.

### Strategy B: Longest-path characterization via topological ranking
Alternative route.

1. Construct a topological rank function `rank : V → ℕ` satisfying `u ∈ pred v → rank u < rank v`.
2. Define `depth` as the least such ranking or as longest-path length.
3. Show each discovery round can increase rank by at most one, hence any node discovered by round `n` has rank at most `n`.

Why this is attractive: it connects to scheduling theory and critical path methods directly. If you can formalize topological sorting on finite DAGs, many theorems become elegant. But this may cost more setup.

### Strategy C: Path-based proof using explicit chains
Most combinatorial, least elegant, but robust if recursion is difficult.

1. Define a directed path to `v` as a list where each successive element is a predecessor of the next.
2. Define `depth v` as the supremum of path lengths ending at `v`.
3. Prove by induction on `n` that any path to a node discovered by round `n` has length at most `n+1`.
4. Take the supremum to conclude `depth v ≤ n`.

Why it may help: explicit path witnesses make the lower-bound theorem conceptually transparent. But list/path bookkeeping in Lean can become tedious.

**Recommendation:** Use **Strategy A** for the main development, with a possible Strategy B corollary if topological ranking emerges naturally.

---

## Cross-Domain Connections You Should Explicitly Exploit

### 1. Scheduling theory / PERT / critical path method
This is not just analogy. Your theorem is a mathematical transplant of classical project scheduling into theorem discovery. A theorem is a task, prerequisites are dependencies, and conceptual depth is project makespan. Formalizing this creates a bridge between:
- proof theory,
- operations research,
- automated theorem search.

### 2. Proof complexity and circuit depth
Your `depth` invariant is analogous to circuit depth and formula depth. Shallow exploration corresponds to bounded-depth proof search. There is a real possibility of importing ideas from:
- AC⁰ vs deeper circuits,
- stratified derivations,
- proof-net depth.
Even if not fully formalized now, frame your theorem as a “depth lower bound for discovery.”

### 3. Category-theoretic semantics of dependency
A theory can be seen as a category of constructions; the dependency graph is a shadow of compositional structure. A critical path then measures irreducible compositional height. This points toward future work on:
- categorical depth,
- functorial transfer of conceptual complexity between theories,
- adjunctions preserving or collapsing depth.

### 4. AI research guidance and curriculum learning
Your layered discovery process is mathematically a curriculum schedule. The critical path theorem says that some targets demand staged acquisition of prerequisites. This directly connects to:
- curriculum learning,
- theorem-prover guidance,
- active learning on proof corpora.

---

## How to Use Catalog Theorems as Building Blocks

Even if these theorems are not about graphs per se, use them as inspiration for “depth bounded by finite complexity” arguments.

1. `operadic_depth_bounded_by_card`  
   This is especially relevant by name and likely by structure. Mine it for a pattern:
   - finite cardinality controls a depth parameter,
   - recursive/inductive depth arguments over finite systems.
   If it proves depth bounded by size, adapt that style to show `depth v ≤ Fintype.card V - 1`.

2. `bounded_depth_consciousness`  
   This may contain an abstract bounded-depth system interface. If so, reuse its architecture:
   - define a bounded-depth system for dependency discovery,
   - instantiate it with your graph process,
   - derive a generic boundedness theorem.

3. `cell_split_bound_from_height` and `key_dimension_lower_bound_from_height`  
   These suggest a pattern of proving lower/upper bounds from a structural “height.” Your conceptual depth is exactly such a height invariant. Borrow the theorem style:
   - “from height to lower bound” becomes “from critical path length to minimal discovery depth.”

4. `periodic_orbit_from_any`  
   Less directly relevant, but if it uses finite-state recurrence or graph traversal on finite types, there may be useful combinatorial lemmas about iteration over finite systems.

Do not cite these superficially. Look for reusable proof idioms: induction on finite complexity, `Finset.sup` bounds, cardinality controls, and fixed-point iteration.

---

## Concrete Theorem Suite to Aim For

A strong minimal deliverable is this chain:

```lean
structure DepGraph (V : Type*) [Fintype V] [DecidableEq V] where
  pred : V → Finset V
  wf : WellFounded (fun u v => u ∈ pred v)

def isSource ...
def depth ...
def nextLayer ...
def discovered ...
def criticalPathLength ...
```

Then prove, in order:

```lean
theorem depth_nonneg ...
theorem depth_eq_zero_of_isSource ...
theorem depth_pred_lt_depth ...
theorem depth_le_card_sub_one ...
theorem discovered_mono ...
theorem pred_mem_discovered_of_mem_nextLayer ...
theorem mem_discovered_imp_depth_le ...
theorem exists_node_of_depth_eq_criticalPath ...
theorem exists_not_mem_discovered_of_lt_criticalPath ...
theorem discovered_eq_univ_at_criticalPath ...
```

The theorem `depth_le_card_sub_one` is especially useful:
```lean
theorem depth_le_card_sub_one
  {V : Type*} [Fintype V] [DecidableEq V]
  (G : DepGraph V) (v : V) :
  G.depth v ≤ Fintype.card V - 1
```
This gives finitary control and may parallel `operadic_depth_bounded_by_card`.

---

## Extraction-from-Proof-Terms Component

Do not overpromise full proof-term semantic extraction from arbitrary Lean expressions unless you can do it. Instead formalize a clean abstraction layer:

1. Define a finite set of named lemmas/theorems.
2. Define an externally supplied dependency map:
   ```lean
   depOf : Name → Finset Name
   ```
3. State the graph theorems abstractly over this map.
4. Optionally provide a lightweight meta function that, for selected declarations, reads constants appearing in an expression and populates `depOf`.

This gives a two-level architecture:
- **object level**: graph theorems proved in Lean,
- **meta level**: extraction tool producing instances.

If you can, add a theorem showing acyclicity when dependencies are restricted to declarations earlier in a topological order/list:
```lean
theorem wf_of_order_decreasing_pred ...
```
This is the bridge from extracted declaration order to your abstract `DepGraph`.

Do not let meta-programming consume the entire project. The mathematical theorem is the core.

---

## Statement Connecting to Aether

Avoid unverifiable hype. Make the Aether claim precise:

> If Aether prioritizes targets maximizing `depth` or lying on a critical path, then for every finite dependency theory it will eventually select nodes that are provably inaccessible to any exploration capped below the critical path length.

Formal theorem version:

```lean
theorem critical_path_policy_finds_shallowly_inaccessible_target
  {V : Type*} [Fintype V] [DecidableEq V]
  (G : DepGraph V)
  (k : ℕ)
  (hk : k < criticalPathLength G) :
  ∃ v : V, depth G v = criticalPathLength G ∧ v ∉ discovered G (sourceSet G) k
```

This is the mathematically legitimate version of “Aether can guide research toward master-class results.”

---

## What Would Make This a Breakthrough

If you succeed, you will have created:

- a formal invariant of theorem-discovery depth,
- a proof that some results are intrinsically inaccessible to shallow search,
- a certified bridge from proof corpora to research guidance,
- the beginnings of a theory of **conceptual complexity of formal mathematics**.

That is not an incremental variant. It is a new axis for theorem proving and metamathematics.

It could spawn:
- depth-aware benchmark suites for theorem provers,
- automated detection of conceptual bottlenecks in Mathlib,
- transfer theorems comparing depth across algebra, topology, analysis,
- weighted and probabilistic models of mathematical discovery.

---

## Deliverable Expectations

Produce:

1. A Lean file with the abstract graph theory and at least theorems A1, B1, and one of B2/C1.
2. Minimal `sorry` count; prioritize finishing the core lower-bound theorem completely.
3. If meta extraction is implemented, keep it modular and clearly separated.
4. A structured `FUTURE_DIRECTIONS.md` with **3–5 concrete breakthrough next steps**, for example:
   - weighted conceptual depth and novelty costs,
   - categorical/functorial transfer of dependency depth across theories,
   - comparison of proof-term dependency depth with human-written textbook dependency depth,
   - lower bounds for discovery under branching-factor constraints,
   - empirical extraction of critical paths from selected Mathlib domains.

Be specific in that file: theorem statements, target files, and why each step opens a new frontier.

---

## Final Tactical Advice

Start with the cleanest abstraction: a finite well-founded predecessor map. Prove the lower bound theorem before touching proof-term extraction. Once the theorem exists, the extraction layer becomes a source of examples rather than a blocker. If time permits, instantiate the framework on a tiny hand-built dependency theory to demonstrate the separation between shallow and critical-path-guided discovery.

This project becomes master-class the moment you prove, in Lean, that **deep results are not merely harder in practice but unavoidable in principle because their dependency geometry forces conceptual depth**.

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

Research domain: Speculative
Research mode: prove
