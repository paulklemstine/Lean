Soli Deo Gloria

## Assignment: Direction 4: Tropical Tensor Distributivity and Min-Plus Normal Forms

**Mode:** prove

Build a field-opening bridge between **term rewriting**, **tropical algebra**, and **combinatorial optimization**. Do not merely port an existing confluence proof line-by-line. The goal is to isolate the structural heart of distributive tensor rewriting, show that it is genuinely **semiring-parametric**, and then identify a new optimization meaning of the resulting normal forms in the tropical setting.

You should aim to formalize a theorem package that makes a mathematician say: *the rewrite normal form of a tropical tensor expression is not just syntax — it is an algorithmic shortest-path certificate*.

Use and extend the ideas in:

- `Catalog/Pythagorean/TensorConfluence.lean`
- `Catalog/Tropical/`  
and any semiring-normalization infrastructure in Mathlib that helps abstract away from coefficient-specific reasoning.

Minimize sorry. If a theorem turns out false as stated, pivot to a precise counterexample and replace the theorem by the strongest true version.

---

## Core Vision

The classical distributivity rules for tensor expressions appear syntactic, but in the tropical semiring
\[
(\mathbb{R}\cup\{\infty\}, \min, +)
\]
they encode dynamic-programming structure: “sum” becomes path concatenation, and “min” becomes path choice. If confluence modulo associativity/commutativity survives in this setting for the 8 distributivity rules, then tropical normal forms become canonical optimization decompositions.

This would create a new interface:

- **rewriting theory** gives canonical decomposition,
- **tropical algebra** gives min-plus semantics,
- **graph algorithms** give shortest-path meaning,
- **algebraic statistics / tropical geometry** gain a symbolic normal-form engine.

This is not an incremental extension. It is a proposal that **canonical rewriting computes optimization semantics**.

---

## Precise Formal Targets

You must introduce at least one genuinely new definition not already present in the catalog. Suggested new concepts:

1. `TropicalNF` — a predicate/structure expressing that an expression is in tropical distributive normal form.
2. `distPotential` generalized semiring-independently to show the termination measure is structural.
3. `PathDecomposition` — a combinatorial object extracted from a tropical normal form.
4. `RealizesShortestPath` — semantics connecting a normalized expression to graph path weights.

At least 3 substantial theorems are required, with proofs involving induction / rcases / by_contra / field-style rearrangement where relevant / multi-step `calc`.

---

## Theorem Package to Prove

### Theorem 1: Structural termination measure is semiring-independent

The key structural insight is that the distributive rewrite system does not depend on the values in the coefficient semiring; it depends only on the expression tree.

A precise target is:

```lean
theorem distPotential_invariant_under_semiring
  {σ : Type} [Semiring σ]
  {τ : Type} [Semiring τ]
  (e : TensorExpr) :
  distPotential (σ := σ) e = distPotential (σ := τ) e
```

If `TensorExpr` in the catalog is not coefficient-parametric, refactor to a parametric version or define a coefficient-erasure map:

```lean
def TensorExpr.eraseCoeff : TensorExpr α → TensorExpr Unit
```

and prove instead:

```lean
theorem distPotential_eq_of_eraseCoeff_eq
  {α β : Type} (e : TensorExpr α) (f : TensorExpr β)
  (h : e.eraseCoeff = f.eraseCoeff) :
  distPotential e = distPotential f
```

A stronger and more useful theorem would be:

```lean
theorem rewrite_decreases_distPotential
  {σ : Type} [Semiring σ]
  {e e' : TensorExpr σ} :
  RewriteStep e e' → distPotential e' < distPotential e
```

combined with semiring-independence of `distPotential`.

**Why this matters:** this isolates the confluence/termination engine from any specific arithmetic and makes tropical transfer mathematically honest rather than heuristic.

---

### Theorem 2: Tropical confluence modulo AC for distributive tensor rewriting

You should formulate a precise tropical version of the confluence theorem. Depending on the catalog setup, this may be either a direct theorem about a rewrite relation or a normalization theorem.

Suggested statement:

```lean
theorem tropical_rewrite_confluent_mod_AC :
  ConfluentModAC (RewriteStep (σ := Tropical))
```

or, if the infrastructure is more computational:

```lean
theorem normalizeCanon_tropical_unique_mod_AC
  (e : TensorExpr Tropical) :
  ∃! n, IsNormalForm n ∧ RewriteClosureModAC e n
```

If full global confluence modulo AC is too ambitious for the current library, prove a semiring-parametric transfer theorem:

```lean
theorem distributive_confluence_semiring_parametric
  (σ : Type) [IdemSemiring σ] :
  ConfluentModAC (RewriteStep (σ := σ))
```

and instantiate it for the tropical semiring.

If Mathlib lacks a ready `IdemSemiring`, define a local class expressing the needed axioms:

```lean
class MinPlusLike (σ : Type) extends Semiring σ where
  add_idem : ∀ a : σ, a + a = a
```

or use a more semantically faithful class if available.

**Why this matters:** it upgrades confluence from a one-off syntactic fact to a theorem schema across idempotent algebra, with tropical algebra as the flagship case.

---

### Theorem 3: Tropical normal forms compute shortest-path decompositions

This is the breakthrough theorem. You need a semantics from tensor expressions to weighted graphs or path matrices. A manageable but nontrivial formalization is to interpret expressions as min-plus matrix formulas.

Define a semantic evaluation:

```lean
def evalTropical : TensorExpr Tropical → TropicalMatrix n n
```

and a graph/path semantics:

```lean
def shortestPathMatrix (G : WeightedGraph n) : TropicalMatrix n n
```

Then prove a theorem of the following shape:

```lean
theorem tropical_normal_form_realizes_shortest_paths
  (G : WeightedGraph n)
  (e : TensorExpr Tropical)
  (henc : EncodesGraph e G) :
  evalTropical (normalizeCanon e) = shortestPathDecompositionMatrix G
```

If exact equality to all-pairs shortest paths is too strong for a first pass, prove the decomposition theorem first:

```lean
theorem tropical_nf_is_path_decomposition
  (e : TensorExpr Tropical) :
  ∃ P : PathDecomposition,
    evalTropical (normalizeCanon e) = P.toMatrix
```

Then prove correctness for graph-generated expressions:

```lean
theorem graph_expression_nf_correct
  (G : WeightedGraph n) :
  evalTropical (normalizeCanon (graphExpr G)) = shortestPathDecompositionMatrix G
```

A more local and perhaps more Lean-friendly theorem is:

```lean
theorem entry_of_normalized_graphExpr_eq_shortest_path_weight
  (G : WeightedGraph n) (i j : Fin n) :
  (evalTropical (normalizeCanon (graphExpr G))) i j =
    shortestPathWeight G i j
```

This theorem should not be a definitional tautology. The proof should pass through the rewrite system and the distributive normal form, not bypass normalization.

**Why this matters:** this turns a canonical rewrite normal form into a certified optimization object, opening a symbolic theory of shortest paths.

---

## Lean 4 Type Signature Suggestions

These are targets, not rigid requirements. Adapt to actual catalog names.

```lean
-- New structural notion
inductive TropicalNF : TensorExpr Tropical → Prop
| atom ...
| min_node ...
| plus_node ...

-- Structural erasure
def TensorExpr.eraseCoeff : TensorExpr α → TensorExpr Unit

-- Path semantics
structure PathDecomposition (n : ℕ) where
  pieces : List (Fin n × Fin n × Tropical)
  sound : ...

def realizesShortestPath
  (G : WeightedGraph n) (P : PathDecomposition n) : Prop := ...

theorem distPotential_eq_of_eraseCoeff_eq
  {α β : Type} (e : TensorExpr α) (f : TensorExpr β)
  (h : e.eraseCoeff = f.eraseCoeff) :
  distPotential e = distPotential f

theorem normalizeCanon_preserves_evalTropical
  (e : TensorExpr Tropical) :
  evalTropical (normalizeCanon e) = evalTropical e

theorem tropical_nf_unique
  (e n₁ n₂ : TensorExpr Tropical)
  (h₁ : RewriteClosureModAC e n₁) (hn₁ : TropicalNF n₁)
  (h₂ : RewriteClosureModAC e n₂) (hn₂ : TropicalNF n₂) :
  ACEquivalent n₁ n₂

theorem entry_of_normalized_graphExpr_eq_shortest_path_weight
  (G : WeightedGraph n) (i j : Fin n) :
  (evalTropical (normalizeCanon (graphExpr G))) i j =
    shortestPathWeight G i j
```

If a true tropical semiring type is not already in the catalog, define a lightweight wrapper around `WithTop ℝ` with operations corresponding to `min` and `+`, and prove the needed algebraic lemmas. Keep this focused: do not get lost building all tropical algebra from scratch if `Catalog/Tropical/` already has the essentials.

---

## Proof Strategy Architecture

You must include at least 2–3 real proof pathways in the code/comments/notes and choose the most promising one.

### Strategy A: Structural transfer of confluence from the catalog proof
1. Refactor the termination measure (`distPotential` or analogous) so that it depends only on syntax, via `eraseCoeff`.
2. Reprove every local rewrite decrease lemma semiring-parametrically.
3. Transfer the catalog confluence proof to tropical coefficients by abstracting only the arithmetic lemmas needed for semantics preservation.

**Why promising:** the assignment already points to a structural measure. This is the shortest route to a robust theorem schema.

### Strategy B: Newman's lemma + local critical-pair analysis in the tropical setting
1. Prove strong normalization from strict decrease of `distPotential`.
2. Enumerate the critical overlaps of the 8 distributivity rules modulo AC.
3. Show tropical semantics does not create new obstructions because all overlaps join structurally, not numerically.

**Why promising:** if the catalog already contains local confluence ingredients, this gives a clean, conceptually satisfying proof. It also makes the “same 8 rules” thesis mathematically transparent.

### Strategy C: Semantic uniqueness via evaluation into free idempotent semiring
1. Interpret expressions into a free idempotent semiring / formal path algebra.
2. Show each rewrite step preserves semantics.
3. Prove the chosen normal forms are canonical representatives of semantic equivalence classes.
4. Deduce confluence or uniqueness of normal form from semantic faithfulness.

**Why revolutionary:** this would elevate the result from rewriting folklore to a representation theorem.  
**Why riskier:** Lean overhead may be larger, especially if the free object is not already formalized.

**Recommendation:** Start with Strategy A for guaranteed progress; use Strategy B to strengthen the final theorem; pursue Strategy C if the syntax/semantics alignment becomes clean enough.

---

## Cross-Domain Connections You Must Make Explicit

You are required to include at least one theorem bridging to another domain. Good targets:

### 1. Combinatorial optimization
Show that tropical normalization computes or certifies shortest-path decompositions.

**Bridge theorem idea:**
```lean
theorem normalized_tropical_expression_gives_dynamic_programming_certificate ...
```

### 2. Algebraic statistics / tropical geometry
Interpret tropical normal forms as piecewise-linear regions or tropical polynomial decompositions.

Possible theorem:
```lean
theorem evalTropical_is_piecewise_linear_on_nf_cells ...
```

Even a modest but precise statement would be valuable: normal forms determine a canonical minimum of affine-linear forms.

### 3. Mathematical physics / control
Min-plus algebra appears in deterministic optimal control and Hamilton–Jacobi limits. A theorem connecting normalized forms to Bellman operators would be genuinely unexpected.

Possible target:
```lean
theorem normalizeCanon_commutes_with_bellman_update_on_encoded_systems ...
```

If this is too ambitious, include it in FUTURE_DIRECTIONS, but at least one proved theorem must bridge domains now.

---

## New Definitions to Introduce

You must define at least one novel concept. Strong candidates:

- `TropicalNF`
- `PathDecomposition`
- `EncodesGraph`
- `RealizesShortestPath`
- `CriticalPeakJoinable`
- `SemiringStructuralInvariant`

Do not merely alias an existing predicate. The definition should capture a new mathematical idea and then be used in at least one substantial theorem.

---

## Falsifiable Conjecture with Computational Test

State at least one conjecture that can fail, and specify how `demo.py` tests it.

### Recommended conjecture
**Conjecture (Geodesic Sparsity of Tropical Normal Forms):**  
For graph-generated expressions `graphExpr G`, the number of summands in `normalizeCanon (graphExpr G)` is bounded above by the number of geodesically essential paths in `G`, and equals it for generic edge weights.

A Lean-facing formulation may be too strong initially, but it should appear in `RESEARCH_PAPER.md` and be computationally tested in `demo.py`.

### Test protocol
- Generate random weighted directed graphs on `n = 5..20`.
- Build tropical tensor expressions encoding adjacency/path composition.
- Normalize them.
- Compute:
  - normal-form term count,
  - all-pairs shortest paths,
  - number of edges/paths participating in shortest-path witnesses.
- Check whether normal-form support matches shortest-path witness structure.

A second conjecture:

**Conjecture (Generic Uniqueness):**  
For graphs with distinct path weights, the tropical normal form of `graphExpr G` contains exactly one witness monomial for each pair `(i,j)`.

This is sharply falsifiable and computationally meaningful.

---

## Required Theorems: Minimum Standard

Your final Lean development must include at least 3 nontrivial theorem proofs. A recommended trio:

1. `distPotential_eq_of_eraseCoeff_eq`
2. `normalizeCanon_preserves_evalTropical`
3. `entry_of_normalized_graphExpr_eq_shortest_path_weight`

Additional strong theorem:
4. `tropical_nf_unique`

At least three proofs must genuinely use deep tactics/structure:
- induction on expressions,
- `rcases` on rewrite cases,
- `by_contra` for uniqueness or minimality,
- multi-step `calc`,
- careful algebraic reasoning on min-plus semantics.

No trivial theorem padding.

---

## Concrete Build Plan

### Phase 1: Structural abstraction
- Inspect `Catalog/Pythagorean/TensorConfluence.lean`.
- Identify:
  - expression datatype,
  - rewrite relation,
  - termination measure,
  - normalizer.
- Generalize the measure to coefficient-erased syntax.
- Prove semiring-independence lemmas.

### Phase 2: Tropical semantics
- Reuse `Catalog/Tropical/` definitions if present.
- Define `evalTropical` for expressions.
- Prove rewrite-step semantic preservation:
```lean
theorem rewriteStep_preserves_evalTropical ...
```

### Phase 3: Graph encoding
- Define `WeightedGraph n`.
- Define `graphExpr`.
- Define `shortestPathWeight` or connect to an existing path-minimization notion.
- Prove normalization correctness on graph-generated expressions.

### Phase 4: Experiment and conjecture testing
- Implement the normalizer in Python mirroring the Lean definitions.
- Compare with Floyd–Warshall / Dijkstra outputs on random graphs.
- Search for counterexamples to the geodesic sparsity conjecture.

---

## Application Keywords

Include these explicitly in your paper and article:

- tropical semiring
- idempotent algebra
- term rewriting
- confluence modulo AC
- canonical normal form
- shortest paths
- dynamic programming
- min-plus linear algebra
- weighted graphs
- Bellman principle
- tropical geometry
- algebraic statistics
- optimization certificates
- symbolic computation

---

## Deliverables (ALL mandatory)

You must produce all of the following:

### 1. Lean development
A new Lean file proving the theorem package above, with minimal sorry. If a theorem must be weakened, do so explicitly and explain the obstruction.

### 2. `FUTURE_DIRECTIONS.md`
Provide **3–5 original research directions**.  
Each direction must include:
- a title,
- **“The key insight is...”**
- **“Why now?”**
At least one direction must bridge to a different domain, such as control theory, algebraic statistics, or complexity theory.

### 3. `RESEARCH_PAPER.md`
A **standalone scientific paper** that explains:
- the problem,
- the precise theorems,
- why they are surprising,
- proof architecture,
- computational experiments,
- conjectures and next steps.

Someone reading only this document must understand the mathematics and its significance.

### 4. `ARTICLE.md`
Write in **Scientific American style**:
- engaging,
- vivid,
- concept-first,
- accessible to a broad scientific audience.

Do **not** focus on formal verification machinery. Focus on the mathematics, optimization meaning, and why canonical rewriting in tropical algebra is exciting.

### 5. Verified algorithm / computational method
Provide a verified normalization or shortest-path extraction method tied to the theorem statements.

### 6. `demo.py`
An interactive demonstration that:
- generates random weighted graphs,
- builds tropical tensor expressions,
- normalizes them,
- compares outputs to shortest-path computations,
- tests the conjectures above,
- prints informative diagnostics and at least one counterexample if a conjecture fails.

---

## Standard of Ambition

Do not settle for “the tropical version probably works.” Either:

- prove that the confluence/normal-form mechanism is semiring-structural and therefore tropical, or
- discover the exact obstruction and turn it into a theorem/counterexample.

The most exciting outcome is a theorem showing that **canonical tropical tensor normal forms are optimization certificates for shortest-path structure**. That would open a new program at the interface of rewriting theory, tropical mathematics, and algorithmic optimization.

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
