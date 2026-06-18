## Assignment: Define tropical protocols

Mode: **prove**

You are not being asked to decorate an existing toy definition. You are being asked to carve out a new formal object that can support an entire theory: **tropical communication protocols**. The core idea is to tropicalize decision/protocol trees by replacing boolean acceptance with min-plus or max-plus value aggregation, so that communication cost and output value interact in a single algebraic object. This should become a bridge between protocol complexity, tropical geometry, dynamic programming, and reconstruction phenomena already present in the catalog.

Prove new, non-trivial theorems. Build on catalog theorems. Minimize sorry.

### Research Direction
A **protocol tree** where:
- each leaf has a value in `ℕ∞ := WithTop ℕ` or in `ℝ≥0∞`,
- each edge has a communication cost,
- the value of an internal node is the tropical combination of its outgoing edges and child values:
  - **min-plus semantics**: node value = `inf_i (cost_i + child_i.value)`,
  - optionally later, **max-plus semantics** for dual formulations.

This should formalize the idea that the protocol computes the least communication cost needed to realize a target outcome encoded at leaves.

### Mathematical Framing
Define a finite rooted tree with edge labels in `ℕ` (or `ℝ`) and leaf labels in `WithTop ℕ`. Then define its **tropical value function** recursively. The first breakthrough target is not merely definitional: prove that tropical protocol values satisfy a **Bellman principle**, a **monotonicity/reconstruction theorem**, and a **depth lower bound** interacting with branching constraints.

The catalog already contains reconstruction theorems for tropical boundary/interior data in GL₃ settings and a depth inequality in a post-quantum tree setting. Your task is to extract the invariant pattern: **interior tropical data is determined by boundary data plus local transition data**. Tropical protocols should become the combinatorial-complexity analogue of those geometric reconstruction principles.

### Existing Verified Theorems
Existing theorems you can build on:
1. `interior_value_determined_by_edge_and_levi` : theorem `interior_value_determined_by_edge_and_levi`
   (file: `Tropical/GL3SatakeFiniteGen.lean`)
2. `gl3_value_determined_by_boundary_and_levi` : theorem `gl3_value_determined_by_boundary_and_levi {B : ℕ}`
   (file: `Tropical/GL3Reconstruction.lean`)
3. `reconstruct_from_rank2Levi_profiles_and_edge_moments` : theorem `reconstruct_from_rank2Levi_profiles_and_edge_moments`
   (file: `Tropical/GL3_ReconstructionFromRank2LeviProfiles.lean`)
4. `post_quantum_tree_depth_bound` : theorem `post_quantum_tree_depth_bound (d : ℕ) : 3 ^ d ≥ 2 ^ d :=`
   (file: `Tropical/MaxPlusLightCone.lean`)
5. `tropical_and_bound` : theorem `tropical_and_bound (c₁ c₂ : ℝ) (h₁ : 1 ≤ c₁) (h₂ : 1 ≤ c₂) :`
   (file: `Tropical/Oracles/OracleApplicationsFrontier.lean`)

### Vision
The field-opening theorem is this: **a tropical protocol is determined by its boundary leaf data and local edge costs, and its root value is the shortest tropical path to the boundary**. This sounds simple, but once formalized properly it opens:
- tropical communication complexity,
- certified lower bounds via tree geometry,
- dynamic-programming semantics in Lean,
- bridges to shortest-path algorithms, control theory, and idempotent analysis,
- a path toward tropical information theory and tropical circuit complexity.

This is the right level of ambition for a cold start: define the object once, prove universal principles once, and the entire downstream theory becomes available.

---

## Precise formalization target

Use a simple custom inductive tree first, not a maximally general graph. Favor a finite rose-tree style object where each node stores a finite list of children with edge costs.

A robust first definition is:

```lean
inductive TropProtocolTree where
  | leaf : WithTop ℕ → TropProtocolTree
  | node : List (ℕ × TropProtocolTree) → TropProtocolTree
deriving Repr, DecidableEq
```

Then define the tropical value recursively:

```lean
open WithTop

def TropProtocolTree.value : TropProtocolTree → WithTop ℕ
  | .leaf a => a
  | .node cs =>
      (cs.map (fun p => ((p.1 : WithTop ℕ) + p.2.value))).foldr inf ⊤
```

You may also define:
- `depth : TropProtocolTree → ℕ`
- `leafValues : TropProtocolTree → List (WithTop ℕ)`
- `allPathSums : TropProtocolTree → List (WithTop ℕ)` if useful
- `boundaryValue : TropProtocolTree → WithTop ℕ := infimum over root-to-leaf path cost + leaf label`

The key theorem should identify `value` with this boundary quantity.

---

## Breakthrough theorem target 1: tropical Bellman/path characterization

### Exact theorem statement
For every finite tropical protocol tree `T`, the recursively defined node value equals the infimum over all root-to-leaf paths of the sum of edge costs along the path plus the leaf value.

### Lean 4 type signature target
You will likely need an auxiliary function for root-to-leaf path costs. One possible signature is:

```lean
def TropProtocolTree.pathValues : TropProtocolTree → List (WithTop ℕ)
  | .leaf a => [a]
  | .node cs =>
      cs.bind (fun p =>
        (p.2.pathValues).map (fun v => (p.1 : WithTop ℕ) + v))

theorem value_eq_inf_pathValues :
  ∀ T : TropProtocolTree,
    T.value = (T.pathValues.foldr inf ⊤)
```

This is the foundational theorem. It is the tropical protocol analogue of “dynamic programming = global optimization”.

### Why this is a breakthrough
This theorem turns protocol trees into certified tropical optimization objects. It gives a semantics that is simultaneously:
- algorithmic: shortest-path/Bellman style,
- algebraic: min-plus aggregation,
- complexity-theoretic: communication cost accumulates along transcript paths.

This is the theorem from which nearly everything else follows.

### Proof strategies
**Strategy A: structural induction on the tree**  
Most promising.  
1. Prove the leaf case by simp.  
2. In the node case, expand `value`, `pathValues`, and `List.bind/map/foldr`.  
3. Use an induction hypothesis on each child and a lemma that `inf` distributes over the folded child path-value lists in the exact way induced by `bind`.

**Strategy B: prove a stronger accumulator lemma**  
1. Define `shiftedPathValues c T := T.pathValues.map (fun v => (c : WithTop ℕ) + v)`.  
2. Show `(shiftedPathValues c T).foldr inf ⊤ = c + T.value`.  
3. Then the node theorem becomes a one-line reduction by folding inf over children.

**Strategy C: recast via `sInf` over a finite set/list**  
1. Convert `List` path values into a `Finset` or finite set if deduplication is manageable.  
2. Use order-theoretic lemmas for `sInf` and addition on `WithTop ℕ`.  
3. This is conceptually elegant and better for later generalization, but likely heavier in Lean at the cold-start stage.

---

## Breakthrough theorem target 2: monotonicity and boundary determination

### Exact theorem statement
If two tropical protocol trees have the same shape, the same edge costs, and leaf labels ordered pointwise, then their root values are ordered the same way. In particular, if they have identical edge costs and identical leaf labels, they have identical root values.

This is the protocol analogue of the catalog’s reconstruction principles: interior values are determined by boundary values plus local edge data.

### Lean 4 type signature target
You may need a same-shape relation. For example:

```lean
inductive SameShape : TropProtocolTree → TropProtocolTree → Prop
  | leaf : ∀ a b, SameShape (.leaf a) (.leaf b)
  | node :
      ∀ cs₁ cs₂,
      List.Forall₂
        (fun p q => p.1 = q.1 ∧ SameShape p.2 q.2)
        cs₁ cs₂ →
      SameShape (.node cs₁) (.node cs₂)
```

Then define a pointwise leaf order relation compatible with shape, or define a simultaneous relation:

```lean
inductive LeData : TropProtocolTree → TropProtocolTree → Prop
  | leaf : ∀ a b, a ≤ b → LeData (.leaf a) (.leaf b)
  | node :
      ∀ cs₁ cs₂,
      List.Forall₂
        (fun p q => p.1 = q.1 ∧ LeData p.2 q.2)
        cs₁ cs₂ →
      LeData (.node cs₁) (.node cs₂)
```

Target theorem:

```lean
theorem value_mono :
  ∀ {T₁ T₂ : TropProtocolTree}, LeData T₁ T₂ → T₁.value ≤ T₂.value
```

And reconstruction corollary:

```lean
theorem value_eq_of_same_edge_and_leaf_data :
  ∀ {T₁ T₂ : TropProtocolTree},
    -- encode equality of edge/leaf data in a suitable relation
    ...
    → T₁.value = T₂.value
```

### Why this is a breakthrough
This is the exact combinatorial shadow of the catalog’s GL₃ reconstruction theorems:
- boundary data = leaf values,
- local structure = edge costs,
- interior quantity = node/root tropical value.

If you prove this cleanly, you create a transport principle from tropical geometric reconstruction to protocol semantics.

### Proof strategies
**Strategy A: direct induction on the relational proof `LeData`**  
Most promising.  
1. Leaf case is immediate from the assumed order.  
2. Node case: use induction hypotheses on children.  
3. Apply monotonicity of addition and `inf` fold.

**Strategy B: reduce to path characterization**  
1. Use `value_eq_inf_pathValues`.  
2. Show every path value in `T₁` is ≤ the corresponding path value in `T₂` under the data relation.  
3. Conclude by monotonicity of infimum over finite lists.

**Strategy C: prove a generic theorem about monotone folds in idempotent semirings**  
1. Abstract over `WithTop ℕ` into a min-plus ordered algebraic structure.  
2. Instantiate at `WithTop ℕ`.  
3. More revolutionary, but likely phase-2 unless Mathlib support aligns cleanly.

---

## Breakthrough theorem target 3: depth lower bound from finite leaf support

### Exact theorem statement
If every internal node has branching arity at most `b`, and the tree has at least `N` leaves carrying finite value, then
`N ≤ b ^ depth T`.
Equivalently, if `N > b ^ d`, no depth-`d` protocol with branching ≤ `b` can realize `N` distinct finite terminal outcomes.

This is where tropical protocols touch communication complexity. The theorem says a protocol cannot encode too many realizable outcomes without sufficient depth.

### Lean 4 type signature target
Define:
- `depth : TropProtocolTree → ℕ`
- `numFiniteLeaves : TropProtocolTree → ℕ`
- `boundedBranching (b : ℕ) : TropProtocolTree → Prop`

Then target:

```lean
def TropProtocolTree.numFiniteLeaves : TropProtocolTree → ℕ
  | .leaf a => if a = ⊤ then 0 else 1
  | .node cs => (cs.map (fun p => p.2.numFiniteLeaves)).sum

def TropProtocolTree.depth : TropProtocolTree → ℕ
  | .leaf _ => 0
  | .node cs => 1 + (cs.map (fun p => p.2.depth)).foldr max 0

def TropProtocolTree.boundedBranching (b : ℕ) : TropProtocolTree → Prop
  | .leaf _ => True
  | .node cs => cs.length ≤ b ∧ ∀ p ∈ cs, p.2.boundedBranching b
```

Target theorem:

```lean
theorem numFiniteLeaves_le_branching_pow_depth :
  ∀ (b : ℕ) (T : TropProtocolTree),
    T.boundedBranching b →
    T.numFiniteLeaves ≤ b ^ T.depth
```

### Why this is a breakthrough
This is the first real complexity lower bound in the theory. It transforms tropical protocol trees from semantic gadgets into quantitative complexity objects. It also connects directly to:
- decision tree complexity,
- communication complexity,
- branching processes,
- entropy-style counting arguments.

The theorem resonates with `post_quantum_tree_depth_bound`; you should explicitly cite that theorem as evidence that tree-depth inequalities are already natural in the catalog, then generalize from a fixed exponential comparison to a protocol-intrinsic counting law.

### Proof strategies
**Strategy A: induction on the tree using `sum_le_card_nsmul_max`-style estimates**  
Most promising.  
1. Leaf case is trivial.  
2. Node case: each child satisfies the induction hypothesis.  
3. Sum child bounds, use `length ≤ b`, and bound each child by `b ^ maxDepth`; conclude with `b * b ^ m = b ^ (m+1)`.

**Strategy B: first prove a stronger theorem for exact depth budget `d`**  
1. Show: if `depth T ≤ d` and branching ≤ `b`, then `numFiniteLeaves ≤ b ^ d`.  
2. Prove by induction on `d`.  
3. Deduce the stated theorem by taking `d = depth T`.

**Strategy C: derive from a leaf-index injection into `Fin (b ^ depth)`**  
1. Encode each leaf by its child-choice sequence padded to full depth.  
2. Show injectivity.  
3. This is conceptually beautiful and closer to coding theory, but more implementation-heavy.

---

## Cross-domain bridge theorem target: shortest paths / dynamic programming

Once theorem 1 is in place, formalize the statement that tropical protocol evaluation is equivalent to shortest-path evaluation on an acyclic weighted graph obtained from the tree.

### Suggested statement
Construct a DAG from a protocol tree by turning each node into a graph vertex and each parent-child relation into a weighted edge, then attach a terminal sink weighted by leaf labels. Prove that the protocol root value equals the shortest-path distance from the root to the sink.

You do not need a full graph-library masterpiece on day one. A lightweight bespoke finite DAG encoding is enough.

### Why it matters
This opens direct connections to:
- operations research,
- control theory,
- Viterbi/Bellman-Ford style algorithms,
- tropical linear algebra,
- semiring-weighted automata.

This is how the theory escapes being “just another tree recursion”.

---

## How to use the catalog theorems

Do not cite the existing theorems decoratively. Extract their pattern.

1. `interior_value_determined_by_edge_and_levi`  
   Treat this as the prototype for “local transition data + partial boundary data determine interior values.” In tropical protocols, edge costs are the local transition data; leaf labels are the boundary data.

2. `gl3_value_determined_by_boundary_and_levi`  
   This is philosophically the exact ancestor of your boundary determination theorem. Mirror its architecture: identify the minimal data needed to reconstruct the root value.

3. `reconstruct_from_rank2Levi_profiles_and_edge_moments`  
   This suggests a richer second generation of the theory: protocol values may be reconstructible from compressed local summaries, not just full leaf data. After the foundational theorems, ask whether certain aggregated subtree statistics already determine the root value.

4. `post_quantum_tree_depth_bound`  
   Use this as evidence that exponential depth laws belong naturally in this codebase. Your leaf-count theorem should be the protocol-complexity generalization.

5. `tropical_and_bound`  
   This can inspire binary composition inequalities. For example, if a node models conjunction/combination of two protocol subgoals, prove a tropical upper bound on the composed cost. Even if not central to the first theorem set, this is an excellent secondary lemma.

---

## Suggested implementation plan

### Phase 1: core definitions
Create:
- `TropProtocolTree`
- `value`
- `depth`
- `numFiniteLeaves`
- `boundedBranching`
- `pathValues`

Keep the datatype simple and structurally recursive.

### Phase 2: foundational semantics
Prove:
1. `value_eq_inf_pathValues`
2. `value_mono`
3. `value_eq_of_same_edge_and_leaf_data`

These establish semantics and reconstruction.

### Phase 3: complexity theorem
Prove:
4. `numFiniteLeaves_le_branching_pow_depth`

This is the first lower-bound theorem and should be highlighted as a major result.

### Phase 4: optional strengthening
If time permits:
- define a max-plus dual,
- prove a min-max duality statement where appropriate,
- relate protocol evaluation to shortest paths in a bespoke DAG.

---

## Additional theorem candidates if momentum is strong

### 1. Uniform leaf shift theorem
Adding the same finite constant `k` to every leaf label adds `k` to the root value.

```lean
def TropProtocolTree.mapLeaves (f : WithTop ℕ → WithTop ℕ) : TropProtocolTree → TropProtocolTree
  | .leaf a => .leaf (f a)
  | .node cs => .node (cs.map (fun p => (p.1, mapLeaves f p.2)))

theorem value_mapLeaves_add_const :
  ∀ (T : TropProtocolTree) (k : ℕ),
    (T.mapLeaves (fun a => (k : WithTop ℕ) + a)).value
      = (k : WithTop ℕ) + T.value
```

This is a tropical gauge invariance and useful for normalization.

### 2. Subtree replacement principle
If two subtrees have equal tropical value, replacing one by the other inside any context preserves the total protocol value.

This is a congruence principle and would be extremely useful for rewriting and optimization.

### 3. Binary composition inequality
For a binary node combining subprotocols with edge costs `c₁, c₂`, prove a bound analogous in spirit to `tropical_and_bound`.

---

## Cross-domain connections to emphasize
This project should explicitly connect tropical protocols to at least one other domain in the writeup and theorem naming/comments.

### Tropical geometry
Protocol evaluation is a min-plus polynomial in leaf labels and edge costs. Internal nodes compute tropical linear forms; the root computes a tropical piecewise-linear functional.

### Communication complexity
A path is a transcript; depth is communication rounds; edge cost is transcript cost; root value is minimal communication expenditure needed to realize a target terminal outcome.

### Dynamic programming / control
The Bellman principle is exactly your theorem `value_eq_inf_pathValues`. This is shortest-path semantics on a finite acyclic system.

### Idempotent analysis
`inf` and `+` place the whole theory in the min-plus semiring. This is the natural language for optimization and tropicalization.

### Weighted automata / formal languages
A protocol tree is a finite acyclic weighted automaton with terminal weights. This invites future generalization from trees to DAGs and then to automata.

### Information theory
The depth-vs-leaf-count theorem is a proto-entropy bound: finite realizable outputs require exponential transcript growth. This is the seed of tropical information complexity.

---

## Application keywords
tropical communication complexity, min-plus semantics, Bellman principle, shortest paths, weighted automata, dynamic programming, idempotent analysis, protocol reconstruction, boundary determination, transcript complexity, tropical optimization, decision tree lower bounds, semiring methods, acyclic weighted graphs, tropical information theory

---

## Deliverables
Required:
- Lean 4 definitions and proofs
- `FUTURE_DIRECTIONS.md`

Optional:
- `ARTICLE.md`
- `RESEARCH_PAPER.md`
- `demo.py`
- `diagram.svg`

### FUTURE_DIRECTIONS.md is critical
You must produce a structured `FUTURE_DIRECTIONS.md` with **3–5 concrete, breakthrough-level next steps**, each containing:
1. a precise theorem statement,
2. a plausible Lean formalization target,
3. 2–3 proof strategy bullets,
4. a cross-domain significance note.

At least two of those future directions should be genuinely ambitious, such as:
- extending from trees to finite DAG protocols,
- proving a tropical cut-set lower bound,
- defining tropical mutual information or tropical protocol rank,
- relating protocol values to min-plus matrix powers,
- establishing a normal form theorem for protocol minimization.

---

## Team Directive
Create a team to conduct research, brainstorm hypotheses, run experiments, validate data, update knowledge base and iterate forever.

Suggested team roles:
- **Definition Architect**: designs `TropProtocolTree` and recursion principles.
- **Semantics Engineer**: proves `value_eq_inf_pathValues`.
- **Complexity Theorist**: proves the branching/depth lower bound.
- **Cross-Domain Synthesist**: connects to shortest paths, automata, and tropical geometry.
- **Lean Integrator**: minimizes sorry, simplifies recursion and list lemmas, documents reusable proof patterns.

---

## Final call
Do not settle for a mere datatype plus a few simp lemmas. Build the first axiomatic layer of a new subject:
**tropical protocol theory**.

The minimum successful outcome is:
- a clean tree definition,
- a Bellman/path theorem,
- a reconstruction/monotonicity theorem,
- a depth-vs-boundary complexity theorem.

If you achieve those four, you will have created a reusable formal language for tropical communication processes that can scale into geometry, complexity, optimization, and information theory.

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
