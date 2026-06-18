## Assignment: 3. Executable Recomputation Kernel with Verified Complexity Bounds

**Mode:** prove

Prove a genuinely new executable-locality theorem for dependency DAG recomputation, and do it in a way that turns a static correctness proof into an **algorithmic complexity theorem**. The target is not merely “some incremental algorithm,” but a formally verified kernel showing that **semantic locality implies computational locality**: when an update only changes a finite dependency cone, recomputation cost scales with the cone, not the ambient graph.

This is the kind of result that can become a reusable backbone for certified build systems, proof dependency maintenance, incremental model checking, sparse dynamic programming, and self-updating verified computation.

---

## Core Theorem Vision

Let `V` be a vertex type, `pred : PredFn V` a predecessor function defining an acyclic dependency graph, and `pred'` an updated predecessor function differing from `pred` only through the insertion or modification of a vertex `new`. Let `cone : Finset V` be the finite affected region, closed under updated predecessor dependencies within the changed zone.

Define an executable function
```lean
def incrementalRecompute (oldLevels : V → ℕ) (pred' : PredFn V)
    (new : V) (cone : Finset V) : V → ℕ
```
which recomputes levels only on `cone`, reusing `oldLevels` elsewhere.

### Breakthrough theorem to prove

The theorem should state, with explicit hypotheses, that if `cone` contains exactly the vertices whose level may change under `pred'`, and is topologically ordered compatibly with `pred'`, then:

1. `incrementalRecompute oldLevels pred' new cone` agrees pointwise with the globally recomputed level function;
2. the executable inspects only vertices in `cone` and predecessor edges entering `cone`;
3. the total work is bounded by a linear function of `|cone| + |E_cone|`.

This is not just a program extraction task. It is a formal analogue of **dynamic graph algorithms with certified sensitivity bounds**.

---

## Precise Formal Target

You should introduce, if needed, a cost-counting semantics for the kernel, e.g. returning both a function and a work counter, or proving a separate inductive “visited set” theorem. A clean target is:

```lean
def edgeBoundarySize (pred' : PredFn V) (cone : Finset V) : ℕ :=
  ∑ v in cone, ((pred' v).filter (· ∈ cone)).card

def incrementalRecompute
    [DecidableEq V]
    (oldLevels : V → ℕ) (pred' : PredFn V)
    (new : V) (cone : Finset V) : V → ℕ := ...

def incrementalWork
    [DecidableEq V]
    (pred' : PredFn V) (new : V) (cone : Finset V) : ℕ := ...

theorem incrementalRecompute_correct
    [DecidableEq V]
    (oldLevels globalLevels : V → ℕ)
    (pred pred' : PredFn V)
    (new : V) (cone : Finset V) :
    -- hypotheses expressing acyclicity, cone soundness, oldLevels correctness off cone,
    -- and globalLevels correctness for pred'
    ...
    → ∀ v, incrementalRecompute oldLevels pred' new cone v = globalLevels v
```

and the complexity theorem:

```lean
theorem incrementalRecompute_work_bound
    [DecidableEq V]
    (oldLevels : V → ℕ) (pred' : PredFn V)
    (new : V) (cone : Finset V) :
    incrementalWork pred' new cone ≤ cone.card + edgeBoundarySize pred' cone
```

If you choose a richer executable interface, even better:

```lean
def incrementalRecomputeWithCost
    [DecidableEq V]
    (oldLevels : V → ℕ) (pred' : PredFn V)
    (new : V) (cone : Finset V) : (V → ℕ) × ℕ
```

with projections proving:
```lean
theorem fst_incrementalRecomputeWithCost_eq_global ...
theorem snd_incrementalRecomputeWithCost_le_linear ...
```

### Stronger aspirational theorem

If feasible, prove a **stability/outside-cone theorem**:

```lean
theorem incrementalRecompute_eq_old_outside_cone
    [DecidableEq V]
    (oldLevels : V → ℕ) (pred' : PredFn V)
    (new : V) (cone : Finset V) :
    ∀ v, v ∉ cone → incrementalRecompute oldLevels pred' new cone v = oldLevels v
```

and combine it with global correctness to derive exact localization of semantic change.

---

## Lean 4 Type Signature Guidance

You likely need a finite predecessor representation to make executable complexity meaningful. If `PredFn V` is not already computationally concrete, define or bridge to:

```lean
abbrev PredFn (V : Type _) := V → Finset V
```

or an equivalent finitely enumerable predecessor structure.

A practical executable skeleton:

```lean
def recomputeLevelOn
    [DecidableEq V]
    (levels : V → ℕ) (pred' : PredFn V) (v : V) : ℕ :=
  1 + ((pred' v).sup levels)

def incrementalFold
    [DecidableEq V]
    (order : List V) (pred' : PredFn V) (levels : V → ℕ) : V → ℕ :=
  order.foldl
    (fun lv v =>
      Function.update lv v (recomputeLevelOn lv pred' v))
    levels

def incrementalRecompute
    [DecidableEq V]
    (oldLevels : V → ℕ) (pred' : PredFn V)
    (new : V) (cone : Finset V) : V → ℕ :=
  let order := -- topological order extracted from cone
  incrementalFold order pred' oldLevels
```

If `Finset.sup` is awkward for `ℕ`, use `fold max 0` over predecessor levels.

A correctness theorem for the fold itself will be central:

```lean
theorem incrementalFold_correct_on_prefix
    [DecidableEq V]
    ...
```

---

## Required Mathematical Structure

You will need to make the hypotheses precise. Introduce definitions such as:

- `IsTopoOrder pred' order cone`
- `ConeClosed pred' cone`
- `AffectedCone pred pred' new cone`
- `LevelsCorrect pred levels`
- `SamePredOutsideCone pred pred' cone`

Suggested formal meanings:

```lean
def LevelsCorrect (pred : PredFn V) (levels : V → ℕ) : Prop := ...

def SamePredOutsideCone (pred pred' : PredFn V) (cone : Finset V) : Prop :=
  ∀ v, v ∉ cone → pred' v = pred v

def ConeClosed (pred' : PredFn V) (cone : Finset V) : Prop :=
  ∀ v, v ∈ cone → ∀ u, u ∈ pred' v → u ∈ cone ∨ True
```

The exact closure notion should reflect your locality theorem: either all changed dependencies of cone vertices stay in cone, or predecessors outside cone are known to have stable old levels.

A more useful executable-locality hypothesis is:

```lean
def ConeSupportsRecompute
    (oldLevels : V → ℕ) (globalLevels : V → ℕ)
    (pred' : PredFn V) (cone : Finset V) : Prop :=
  ∀ v ∈ cone, ∀ u ∈ pred' v, u ∉ cone → oldLevels u = globalLevels u
```

This lets you reuse external values safely while recomputing internally.

---

## Proof Strategy A: Topological Fold + Prefix Invariant
**Most promising.** It is algorithmic, compositional, and naturally yields both correctness and cost bounds.

### Step 1: Build a topological order on `cone`
Use a list `order : List V` with:
- `order.Nodup`
- every element of `cone` appears exactly once
- if `u ∈ pred' v ∩ cone`, then `u` appears before `v`

If a generic topological sort theorem already exists in your environment, exploit it. If not, assume `order` as data first, then derive an existence theorem later. This separation is often the fastest route to executable correctness.

### Step 2: Prove a fold invariant
After folding over any prefix `p` of `order`:
- vertices in `p` have updated correct levels;
- vertices not yet processed retain either old values or values irrelevant to correctness of processed nodes;
- vertices outside `cone` remain equal to `oldLevels`.

This is the key induction:
```lean
∀ p, p <:+ order →
  PrefixInvariant p (incrementalFold p pred' oldLevels)
```

The topological-order hypothesis ensures every in-cone predecessor needed to compute `v` has already been updated when `v` is processed.

### Step 3: Derive global agreement and locality
At full order, all vertices in `cone` are correct; outside `cone`, values remain `oldLevels`. Combine with “outside cone stability” to conclude agreement with global recomputation everywhere.

### Step 4: Count work
Define cost per processed vertex as:
- one unit for visiting the vertex,
- plus one unit per predecessor edge scanned.

Then the fold cost is exactly or at most:
```lean
cone.card + ∑ v in cone, ((pred' v).filter (· ∈ cone ∨ · ∉ cone)).card
```
which simplifies to a linear bound in the predecessor enumeration size. If you want the sharper statement “only predecessors of cone vertices are inspected,” count all `pred' v` for `v ∈ cone`; if you want “internal cone edges plus boundary reads,” split the sum accordingly.

**Why this is best:** it aligns executable code, correctness proof, and complexity proof around a single fold invariant. This is the formal methods version of proving a dynamic-programming kernel correct by schedule.

---

## Proof Strategy B: Fixpoint Restriction to an Affected Subsystem
This route is more abstract and may connect better to existing catalog theorems.

### Step 1: View level computation as a monotone operator
Define a global operator `F_pred : (V → ℕ) → (V → ℕ)` and characterize `globalLevels` as a least/greatest fixpoint or as the unique solution under acyclicity.

### Step 2: Restrict the operator to the cone
Construct a restricted operator on assignments over `cone`, with boundary condition given by `oldLevels` outside `cone`.

### Step 3: Show equivalence of restricted and global solutions
Prove that the global recomputation under `pred'` restricted to `cone` is exactly the fixpoint of the restricted operator. Then show the executable fold computes that restricted fixpoint because the DAG schedule realizes fixpoint iteration in one pass.

### Step 4: Transfer complexity from fixpoint iteration
Leverage ideas from:
- `finite_model_checking_by_fixpoint_iteration`
to reinterpret recomputation as one-pass fixpoint stabilization on an acyclic region.

**Why this is powerful:** it links dependency recomputation to modal logic/model checking, opening a bridge between incremental compilation and certified semantic propagation. It is more conceptual than Strategy A, but may require heavier abstraction overhead.

---

## Proof Strategy C: Oracle/Query Complexity Interpretation
This is a cross-domain complexity-theoretic route.

### Step 1: Model predecessor inspection as oracle queries
Treat `pred' v` access and predecessor-level lookup as query steps.

### Step 2: Define a query-count semantics for `incrementalRecompute`
Prove that all queries are confined to:
- `v ∈ cone`,
- `u ∈ pred' v` for such `v`.

### Step 3: Bound query complexity
Use the shape of the algorithm to show the number of queries is linear in cone size and edge boundary size.

### Step 4: Connect to certified complexity theorems
Use the style, and perhaps lemmas, from:
- `query_strategy_output_bound`
to package the recomputation kernel as a verified adaptive query strategy.

**Why this matters:** it reframes incremental recomputation as a certified information-flow process. This could eventually lead to lower bounds, optimality theorems, and adversarial update models.

---

## Existing Catalog Theorems: How to Build on Them

### 1. `query_strategy_output_bound`
**File:** `Logic/OracleComplexity.lean`

Use this as a complexity packaging theorem. Even if the statement is not directly about graphs, the methodology is valuable: define the recomputation kernel as a bounded query process whose output depends only on a controlled region. This can help prove that the algorithm does not “look outside the cone” except via predecessor boundary values already assumed stable.

### 2. `finite_model_checking_by_fixpoint_iteration`
**File:** `Logic/TemporalStoneBridge.lean`

This is the strongest conceptual bridge. Level recomputation is a finite dependency fixpoint problem. If the theorem provides convergence of monotone iteration on finite structures, adapt its iteration invariant machinery to the restricted cone operator. The dramatic insight is that **incremental dependency maintenance is finite fixpoint model checking on a localized Kripke fragment**.

### 3. `proof_complexity_risk_bound`
**File:** `MachineLearning/LoebGeneralization.lean`

Not for direct reuse of content, but for style: it likely formalizes a quantitative bound from structural parameters. Mirror that architecture: define a structural complexity measure on the cone and prove a bound on executable effort. This is useful if you introduce a machine-checked “cost algebra.”

### 4. `global_theorem_of_strategy_triad`
**File:** `MachineLearning/ProofSchemata/Core.lean`

Potentially useful as a meta-pattern: combine local correctness, global soundness, and complexity into a single synthesis theorem. Your end product should not be scattered lemmas only; aim for one flagship theorem bundling:
- semantic correctness,
- outside-cone stability,
- linear work bound.

### 5. `tropical_sort_complexity_bound`
**File:** `Speculative/AutoResearch/Bridges/TropicalValuationFunctor.lean`

This is a surprising but potentially fertile bridge. If it formalizes a complexity theorem for a specialized sorting/topological-like process, adapt its counting lemmas for the topological ordering phase. At minimum, borrow proof patterns for list/finset cardinality accounting. At maximum, reinterpret recomputation scheduling as a valuation-respecting propagation order.

---

## Cross-Domain Connections You Should Explicitly Exploit

### 1. Incremental compilation ↔ fixpoint logic
A dependency graph update is a localized semantic re-evaluation. This is the same mathematics as finite model checking under local perturbation. Formalizing this creates a bridge between verified compilers and temporal logic engines.

### 2. Dynamic programming on DAGs ↔ proof maintenance
Levels are a toy instance of recomputing derived judgments after local axiom changes. This opens the path to certified incremental proof checking, tactic cache invalidation, and theorem database maintenance.

### 3. Sparse message passing ↔ graph neural computation
Your cone-local recomputation theorem is structurally identical to bounded receptive-field propagation in message-passing networks. A verified “affected subgraph only” theorem is a mathematical precursor to certified sparse neural updates.

### 4. Self-adjusting computation ↔ oracle complexity
The statement “the algorithm inspects only the cone and its predecessor edges” is an information-theoretic theorem, not just an implementation detail. It says the computation has bounded **adaptivity footprint**.

### 5. Tropical / max-plus algebra ↔ level propagation
If levels are defined by predecessor maxima plus one, the update rule is max-plus linear. This gives a direct bridge to tropical algebra: incremental recomputation becomes localized tropical Bellman propagation. That connection is unusual and field-opening.

---

## Application Keywords

Use these in theorem names, comments, and FUTURE_DIRECTIONS framing:

- certified incremental computation
- dynamic DAG algorithms
- self-adjusting computation
- localized fixpoint propagation
- verified complexity bounds
- sparse dependency maintenance
- topological dynamic programming
- oracle/query complexity
- tropical max-plus propagation
- incremental model checking
- certified build systems
- proof dependency caching

---

## Concrete Lean Development Plan

1. **Define computational predecessor interface**
   Ensure `pred' v` is finitely enumerable, ideally `Finset V`.

2. **Define local recomputation primitive**
   A one-vertex update from current levels.

3. **Define topological fold over cone**
   Either:
   - assume an `order : List V` with hypotheses, or
   - compute one from the cone if the graph infrastructure exists.

4. **Prove fold locality**
   Outside processed vertices, values are unchanged.

5. **Prove fold correctness by prefix induction**
   The crucial invariant: processed vertices match global recomputation.

6. **Define and prove work-count bound**
   Either exact count or upper bound by a sum over predecessor cards.

7. **Package the flagship theorem**
   One theorem that states correctness + outside-cone stability + linear work.

---

## Suggested Flagship Theorem Statement

A strong final theorem would look like:

```lean
theorem incremental_recompute_spec
    [DecidableEq V]
    (pred pred' : PredFn V)
    (oldLevels globalLevels : V → ℕ)
    (new : V) (cone : Finset V) (order : List V) :
    LevelsCorrect pred oldLevels →
    LevelsCorrect pred' globalLevels →
    SamePredOutsideCone pred pred' cone →
    ConeSupportsRecompute oldLevels globalLevels pred' cone →
    IsTopoOrder pred' cone order →
    (∀ v, v ∉ cone → oldLevels v = globalLevels v) →
    (∀ v, incrementalRecompute oldLevels pred' new cone v = globalLevels v) ∧
    (∀ v, v ∉ cone → incrementalRecompute oldLevels pred' new cone v = oldLevels v) ∧
    incrementalWork pred' new cone ≤ cone.card + edgeBoundarySize pred' cone
```

If this is too ambitious for one pass, first prove the three conjuncts separately, then synthesize them.

---

## What Would Make This a Breakthrough

The breakthrough is not the asymptotic bound alone. It is the **formal unification of locality, executability, and complexity** in a reusable kernel. Most formal developments prove semantic equivalence. Far fewer prove that the executable extracted algorithm is *provably sparse* in exactly the changed region. That is the missing theorem for scaling verified systems.

If you get this right, the next frontier is enormous:
- verified incremental SAT/SMT preprocessing,
- dynamic proof artifact maintenance,
- localized recompilation of formal libraries,
- certified sparse neural/message-passing updates,
- dynamic fixpoint maintenance in temporal logic.

This is how a theorem about `Finset` folds becomes infrastructure for a new class of certified dynamic algorithms.

---

## Deliverable Discipline

Minimize `sorry` aggressively. If topological sort existence becomes a bottleneck, parameterize over a supplied `order` first and isolate existence as a later theorem. Prioritize an executable theorem that actually runs and a complexity theorem that is machine-checked, even if the most general graph interface is deferred.

Also produce a structured `FUTURE_DIRECTIONS.md` with **3–5 concrete breakthrough-level next steps**, for example:
1. exact lower bounds showing cone-linear recomputation is query-optimal;
2. extension from DAG levels to arbitrary monotone semiring valuations;
3. localized fixpoint maintenance for temporal logic formulas;
4. certified self-adjusting computation framework in Lean;
5. tropical/max-plus generalization to shortest-path and Bellman-style updates.

That file is mandatory.

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

Research domain: Logic
Research mode: prove
