## Assignment: Direction 3: DAG Sharing Does Not Reduce Depth (Grand Challenge)

**Mode:** prove

Build the first formal depth-lower-bound theory for **shared** inverse-free EML computations. The central claim is not a cosmetic extension of the tree result: it is a circuit-lower-bound statement. If true, it says that **common subexpression elimination cannot compress the essential sequential complexity** of iterated exponentiation. This places the existing tree-based hierarchy into direct conversation with DAG circuits, compiler optimization, symbolic computation, and non-uniform complexity theory.

Your target is a genuine theorem package, not a translation exercise.

---

## Grand Theorem Target

The existing catalog theorem in `Speculative/TightDepthHierarchy/Theorems.lean` establishes a **tree-based** lower bound for `iterExp`. Your task is to formalize a DAG semantics for inverse-free EML and prove that **sharing does not reduce minimum depth**.

### Precise Mathematical Statement

Let `iterExp : ℕ → EMLExpr → EMLExpr` be the iterated exponentiation family already used in the catalog, and let `eval` denote its semantic interpretation over the intended domain. Introduce a new DAG representation `EMLDag` with:

- a finite type of nodes,
- each node labelled by an inverse-free EML operation,
- edges only to earlier nodes (acyclicity by indexing),
- a distinguished output node,
- a semantic evaluator `EMLDag.eval`,
- a structural depth `EMLDag.depth`,
- an inverse-free predicate `EMLDag.InverseFree`.

Then prove a theorem of the following form:

> **Depth rigidity under sharing.**  
> For every inverse-free DAG `G`, if `G` computes the same function as `iterExp n`, then `G.depth ≥ n`.

A Lean 4 target signature should be engineered as close as possible to:

```lean
theorem dag_depth_lower_bound_for_iterExp
    (n : ℕ)
    (G : EMLDag)
    (hInv : G.InverseFree)
    (hSem : ∀ x, G.eval x = eval (iterExp n (EMLExpr.var 0)) x) :
    n ≤ G.depth
```

If the catalog theorem is stated with a minimum-depth predicate rather than pointwise semantic equality, adapt the statement so that the DAG theorem reduces to the certified tree theorem.

A stronger and more conceptually decisive version is:

```lean
theorem dag_unfold_preserves_semantics_and_depth
    (G : EMLDag) :
    ∃ t : EMLExpr,
      InverseFree t ∧
      (∀ x, eval t x = G.eval x) ∧
      emlDepth t ≤ G.depth
```

Together with the catalog tree lower bound, this immediately yields:

```lean
theorem dag_sharing_does_not_reduce_iterExp_depth
    (n : ℕ)
    (G : EMLDag)
    (hInv : G.InverseFree)
    (hSem : ∀ x, G.eval x = eval (iterExp n (EMLExpr.var 0)) x) :
    n ≤ G.depth
```

This is the breakthrough theorem. It says DAG compression preserves size efficiency but not depth efficiency for this family.

---

## New Definitions You Must Introduce

You are required to create at least one genuinely new mathematical structure. Here the right object is:

```lean
structure EMLDag where
  Node : Type
  [fintype_Node : Fintype Node]
  [decEq_Node : DecidableEq Node]
  idx : Node → ℕ
  op : Node → DagOp Node
  output : Node
  acyclic : ∀ {u v}, v ∈ children (op u) → idx v < idx u
```

or, if dependent typing becomes too heavy, use a finite array/list encoding:

```lean
structure DagNode where
  op : DagOp ℕ

structure EMLDag where
  nodes : Array DagNode
  output : Fin nodes.size
  wf : ∀ i : Fin nodes.size, ∀ j ∈ children ((nodes[i]).op), j.val < i.val
```

You should also define:

- `EMLDag.eval : EMLDag → α → α`
- `EMLDag.depth : EMLDag → ℕ`
- `EMLDag.InverseFree : EMLDag → Prop`
- `EMLDag.unfold : EMLDag → EMLExpr`
- optionally `EMLDag.size`, `EMLDag.reachable`, `EMLDag.layer`, `EMLDag.refCount`

A particularly good novel concept is:

```lean
def EMLDag.SequentialDepth (G : EMLDag) : ℕ := ...
```

interpreting depth as the length of the longest dependency chain. This makes the theorem read as a statement about **parallel time** rather than syntax. That cross-domain interpretation is scientifically important.

---

## Core Theorem Package: at least 3 substantial theorems

Your file must contain at least three nontrivial theorems with real proof structure. A suggested package:

### Theorem 1: Unfolding preserves semantics
```lean
theorem EMLDag.eval_unfold
    (G : EMLDag) :
    ∀ x, eval (G.unfold) x = G.eval x
```
This should require induction over node indices or reachable nodes, with `rcases` on node operations and multi-step `calc`.

### Theorem 2: Unfolding does not increase depth
```lean
theorem EMLDag.emlDepth_unfold_le
    (G : EMLDag) :
    emlDepth G.unfold ≤ G.depth
```
This is the structural bridge theorem. It should not be a one-line simp lemma. Expect induction on the DAG topological order and careful max/succ inequalities.

### Theorem 3: DAG lower bound for iterated exponentials
```lean
theorem dag_sharing_does_not_reduce_iterExp_depth
    (n : ℕ)
    (G : EMLDag)
    (hInv : G.InverseFree)
    (hSem : ∀ x, G.eval x = eval (iterExp n (EMLExpr.var 0)) x) :
    n ≤ G.depth
```
This should combine Theorems 1 and 2 with the catalog tree lower bound.

### Optional Theorem 4: Reachability compression is semantics-preserving
A useful strengthening:

```lean
theorem prune_unreachable_preserves_eval
    (G : EMLDag) :
    ∃ G' : EMLDag,
      (∀ x, G'.eval x = G.eval x) ∧
      G'.depth ≤ G.depth ∧
      -- every node of G' is reachable from output
      G'.AllReachable
```

### Optional Theorem 5: Cross-domain theorem on parallel dependency depth
Connect to scheduling / circuit complexity:
```lean
theorem sequentialDepth_eq_longest_path
    (G : EMLDag) :
    G.SequentialDepth = graphLongestPath G.dependencyGraph
```
Even a weaker theorem (`≤` or `≥`) is valuable if fully formalized.

---

## Proof Architecture: 3 viable strategies

### Strategy A: Unfold-to-tree reduction via topological recursion
**Most promising.**

1. Define `unfoldFrom : Node → EMLExpr` recursively using the acyclic indexing.
2. Prove by induction on `idx` that `eval (unfoldFrom u) = evalNode u`.
3. Prove simultaneously that `emlDepth (unfoldFrom u) ≤ nodeDepth u`, where `nodeDepth` is the longest predecessor chain ending at `u`.
4. Instantiate at `output` and invoke the existing tree theorem from `Speculative/TightDepthHierarchy/Theorems.lean`.

Why this is best: it converts the entire DAG problem into a certified structural reduction, minimizing dependence on extensional function arguments and maximizing reuse of the catalog theorem.

### Strategy B: Semantic invariant via dependency height
1. Define a semantic class `ComputableAtDepth d` for functions realizable by inverse-free DAGs of depth at most `d`.
2. Prove by induction on `d` that every DAG-computable function at depth `d` is tree-computable at depth `d`.
3. Use the catalog separation theorem to show `iterExp n` is not in `ComputableAtDepth d` for `d < n`.

Why it is attractive: cleaner abstraction and potentially reusable for future lower bounds.  
Why it is harder: you may need to reconstruct several closure lemmas already implicit for trees.

### Strategy C: Longest-path/circuit interpretation
1. Interpret `EMLDag` as a non-uniform arithmetic circuit with fan-out.
2. Prove that inverse-free EML depth equals longest path length in the dependency graph.
3. Show any realization of `iterExp n` induces a tree witness of the same or smaller depth by selecting one dependency path per use.
4. Apply the tree lower bound.

Why this is visionary: it creates a bridge to circuit complexity and compiler scheduling.  
Why it is harder: graph formalization overhead may be substantial unless Mathlib graph infrastructure already fits your encoding.

**Recommendation:** Start with Strategy A, then extract graph-theoretic corollaries from the same machinery.

---

## How to Build on the Catalog

You are not starting from zero. The existing theorem
`depth_hierarchy_for_iterExp_family`
in `Speculative/TightDepthHierarchy/Theorems.lean`
is your launch platform.

You should explicitly identify and reuse:

- the formal definition of `iterExp`,
- the semantic evaluator `eval`,
- the tree depth measure `emlDepth`,
- the inverse-free predicate on expressions,
- the existing lower-bound theorem showing tree depth `< n` cannot realize `iterExp n`.

Your reduction theorem should be engineered so that the final lower bound is almost one line after unfolding:

1. Obtain `t := G.unfold`.
2. Use `EMLDag.eval_unfold` to transfer semantics.
3. Use `EMLDag.emlDepth_unfold_le` to transfer depth.
4. Use the catalog theorem to conclude `n ≤ emlDepth t`.
5. Chain inequalities to conclude `n ≤ G.depth`.

That is the exact conceptual bridge: **DAG → tree without depth blowup**.

---

## Cross-Domain Connections You Must Surface

This project matters because it is not just about a syntax tree.

### 1. Circuit complexity
Your theorem is a depth lower bound for a shared computation model. This parallels the distinction between formulas and circuits, and resonates with AC⁰-style lower bounds: **fan-out helps size, but not enough to collapse depth for certain explicit families**.

### 2. Compiler optimization
DAG sharing is formal common subexpression elimination. The theorem says there are functions for which CSE cannot reduce dependency depth. This is a formal lower bound on optimization by sharing.

### 3. Parallel scheduling / critical path theory
`G.depth` is the critical path length of the computation graph. Your theorem says `iterExp n` has unavoidable parallel time `n` in the inverse-free model. This is a theorem about **parallelism limits**.

### 4. Proof theory / term graph rewriting
Unfolding a DAG to a tree while preserving semantics and bounding depth is a term-graph normalization theorem. This opens a bridge to rewriting theory and certified symbolic execution.

### 5. Arithmetic circuit lower bounds
Even in a very restricted arithmetic language, you are proving a lower bound robust under sharing. This is a rare formalized instance of a structural lower-bound phenomenon.

---

## Application Keywords

Use these explicitly in your paper and metadata:

**application keywords:** arithmetic circuits, term graphs, DAG semantics, common subexpression elimination, critical path complexity, parallel time lower bounds, formula-vs-circuit separation, certified compiler optimization limits, symbolic computation, non-uniform complexity

---

## Required computational method

You must not stop at theorem statements. Deliver a verified computational component:

### Verified bounded DAG enumerator
Implement a search procedure for inverse-free DAGs bounded by:
- depth ≤ 4
- node count ≤ 15

and test whether any candidate matches `iterExp 5` on a finite test suite of points.

A target artifact:
```lean
def enumerateInverseFreeDags (maxDepth maxNodes : ℕ) : List EMLDag := ...
def agreesOnTestSet (G : EMLDag) (pts : List α) : Bool := ...
```

Then expose the computational conclusion:
- either no candidate survives the test set,
- or produce a concrete counterexample candidate for further analysis.

This is not a proof of the theorem, but it is a scientifically essential falsification engine.

---

## Testable Conjectures for FUTURE_DIRECTIONS.md

You must include 3–5 falsifiable hypotheses. At least one should be:

1. **Depth rigidity under sharing for iterExp.**  
   For every `n`, any inverse-free DAG computing `iterExp n` has depth at least `n`.  
   **Test:** exhaustive search for small `n`, bounded nodes/depth; attempt synthesis of counterexamples.

Additional strong hypotheses:

2. **Size-depth tradeoff under sharing.**  
   Among inverse-free DAGs computing `iterExp n`, sharing can reduce size exponentially relative to trees, but cannot reduce depth below `n`.  
   **Test:** compute minimal node count for small `n` under fixed depth constraints.

3. **Critical-path universality.**  
   For every inverse-free DAG `G`, the formal depth equals the longest path in its dependency graph.  
   **Test:** compare certified `G.depth` with graph algorithm output on random generated DAGs.

4. **Compiler lower bound hypothesis.**  
   Any semantics-preserving common-subexpression elimination pass on inverse-free EML preserves or lowers size but cannot lower critical-path depth for the `iterExp` family.  
   **Test:** implement CSE normalization on unfolded trees and compare depths.

5. **Restricted arithmetic circuit separation.**  
   There exists a family beyond `iterExp` for which DAG depth lower bounds strictly exceed logarithmic growth despite unrestricted sharing.  
   **Test:** search over recursively defined expression families.

Each must appear in `FUTURE_DIRECTIONS.md` with a concrete disproof protocol.

---

## Deliverables (MANDATORY)

You must produce all of the following:

1. **Lean file(s)** with the new DAG formalization and at least 3 substantial proved theorems.
2. **A structured `FUTURE_DIRECTIONS.md`** containing 3–5 falsifiable scientific hypotheses with explicit computational tests.
3. **A standalone `RESEARCH_PAPER.md`** explaining the theorem, proof architecture, computational experiments, and scientific significance so a reader can understand it without opening the code.
4. **An accessible `ARTICLE.md`** in Scientific American style, explaining why shared computation still cannot compress certain kinds of mathematical depth.
5. **A verified algorithm or computational method**: bounded enumeration / testing of inverse-free DAGs.
6. **A `demo.py`** that interactively:
   - generates bounded DAGs,
   - compares them against `iterExp`,
   - visualizes depth vs node count,
   - highlights the absence (or presence) of low-depth matches.

---

## Formal development guidance

- Prefer an indexed-array DAG encoding if recursion on arbitrary finite types becomes painful.
- Define node semantics by recursion over index and prove well-foundedness from the acyclicity condition.
- Introduce a local lemma for every operation constructor:
  - semantics transfer,
  - inverse-free preservation,
  - depth inequality under unfolding.
- Use induction, `rcases`, `by_contra`, and multi-step `calc` chains. Avoid trivial automation-based “proofs”.
- If exact semantic equality over the full base type is too rigid initially, prove the theorem first over the same semantic domain used by the catalog tree theorem.
- If necessary, first prove a nodewise theorem:
  ```lean
  theorem unfold_node_correct
      (G : EMLDag) (u : G.Node) :
      eval (G.unfoldFrom u) = G.evalNode u
  ```
  and then specialize to the output node.

---

## Why this is revolutionary

If you succeed, you will have formalized a genuine lower-bound principle:

> **Sharing compresses duplication, not dependency.**

That principle is foundational across mathematics and computation. It says the existing depth hierarchy is not a quirk of tree syntax but a robust invariant of the computational process itself. This opens the door to a new formal program: certified lower bounds for restricted arithmetic circuits, verified impossibility results for compiler optimizations, and structural complexity theory inside Lean.

This is exactly the kind of theorem that changes what people think is formalizable.

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
