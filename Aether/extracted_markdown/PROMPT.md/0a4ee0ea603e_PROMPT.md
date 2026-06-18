Mode: prove

# Breakthrough Objective
Formalize and prove a **boundary rigidity theorem for series-parallel tropical networks**: the all-pairs boundary distance matrix of a reduced finite weighted series-parallel network determines its combinatorial/weighted structure up to the natural SP equivalence. This is not a routine graph-theory exercise. If successful, it creates a Lean-certified bridge between:

- tropical elimination / min-plus linear algebra,
- network synthesis and inverse problems,
- categorical decomposition of SP circuits,
- and boundary measurement rigidity phenomena usually studied in electrical, metric, or geometric inverse problems.

The revolutionary point is that a **tropical Schur complement becomes an exact reconstruction invariant** on a nontrivial graph class. This opens a program of tropical inverse theory: recovering hidden combinatorial structure from min-plus boundary observables.

## Precise theorem target

You should choose a concrete finite model and prove at least one strong theorem in that model.

A promising formalization is:

- a finite vertex type `V`
- a finite boundary subset `B : Finset V`
- edge weights in `ℝ`
- path length = sum of edge weights
- boundary distance matrix `D : B → B → ℝ` given by infimum/minimum path length
- a predicate `SeriesParallelOn (G : Network V) (B : Finset V)` expressing inductive generation from atomic edges by series/parallel gluing along designated terminals
- a reduction predicate excluding redundant degree-2 zero-information expansions and duplicate parallel edges with equal effective role

Then aim for the theorem:

> For reduced finite k-terminal SP networks with positive edge weights, equality of boundary distance matrices implies equivalence of networks.

A Lean-shaped target could look like:

```lean
theorem sp_boundary_matrix_rigid
  {V₁ V₂ : Type} [Fintype V₁] [DecidableEq V₁] [Fintype V₂] [DecidableEq V₂]
  (N₁ : TropNetwork V₁) (N₂ : TropNetwork V₂)
  (B₁ : Finset V₁) (B₂ : Finset V₂)
  (hB₁ : B₁.card = k) (hB₂ : B₂.card = k)
  (hsp₁ : SeriesParallelOn N₁ B₁)
  (hsp₂ : SeriesParallelOn N₂ B₂)
  (hred₁ : ReducedSP N₁ B₁)
  (hred₂ : ReducedSP N₂ B₂)
  (hpos₁ : PositiveWeights N₁)
  (hpos₂ : PositiveWeights N₂)
  (hD :
    boundaryDistMatrix N₁ B₁ ≈ boundaryDistMatrix N₂ B₂) :
  SPEquivalent N₁ B₁ N₂ B₂
```

Here `≈` should mean equality after identifying the boundary labels through a chosen `Fin k` indexing. If full graph equivalence is too ambitious at first, prove the labeled version:

```lean
theorem sp_boundary_matrix_rigid_labeled
  {k : ℕ}
  (N₁ N₂ : LabeledSPNetwork k)
  (hred₁ : N₁.Reduced)
  (hred₂ : N₂.Reduced)
  (hpos₁ : N₁.PositiveWeights)
  (hpos₂ : N₂.PositiveWeights)
  (hD : N₁.boundaryDist = N₂.boundaryDist) :
  N₁ ≈ N₂
```

A foundational intermediate theorem, likely the real engine, is:

```lean
theorem boundaryDist_series
  (N₁ N₂ : TwoTerminalNetwork)
  :
  boundaryDist (seriesCompose N₁ N₂)
    = seriesBoundaryTransform (boundaryDist N₁) (boundaryDist N₂)

theorem boundaryDist_parallel
  (N₁ N₂ : TwoTerminalNetwork)
  :
  boundaryDist (parallelCompose N₁ N₂)
    = parallelBoundaryTransform (boundaryDist N₁) (boundaryDist N₂)
```

For `2`-terminal networks this should collapse to:
- series: effective distance adds,
- parallel: effective distance is `min`.

This is already a certified tropical semantics theorem for SP composition. Then push to `k` terminals.

## Stronger matrix/elimination theorem
The deeper theorem, and probably the one that makes the project field-opening, is:

```lean
theorem tropical_schur_complement_eq_boundaryDist
  {V : Type} [Fintype V] [DecidableEq V]
  (N : TropNetwork V) (B : Finset V)
  (hwell : WellFormed N B) :
  tropicalSchurComplement N B = boundaryDistMatrix N B
```

Interpretation:
- the tropical Schur complement obtained by eliminating interior vertices computes exactly the min-plus transfer matrix on the boundary.

Then the SP rigidity theorem becomes a reconstruction theorem from this tropical Schur complement.

This is a tropical analogue of Dirichlet-to-Neumann / response-matrix rigidity, but for shortest-path geometry rather than harmonic flow.

## Why this would be a breakthrough
Because it would certify, inside Lean, that a hidden structured network can be **recovered from its external tropical observable**. That is a genuine inverse-problem theorem, not a local extension. It would connect:

- tropical geometry: min-plus matrix elimination,
- graph algorithms: shortest-path closure and decomposition,
- circuit theory: series-parallel synthesis,
- formal methods: certified reconstruction from observables.

It also suggests a new language for explainable network models: internal architecture encoded by boundary metrics.

## Proof architecture

### Strategy A: Inductive decomposition with matrix invariants
This is likely the most Lean-friendly and should be your primary route.

#### Step A1: Define an inductive type of labeled SP networks
Avoid arbitrary graph isomorphism at first. Define a syntax tree:
- atomic edge between terminals,
- series composition,
- parallel composition,
- perhaps generalized k-terminal gliddings if you want the full theorem.

Then define semantics:
```lean
evalBoundaryDist : SPExpr k → Matrix (Fin k) (Fin k) ℝ
```

For two-terminal syntax:
- atom `w` has matrix with off-diagonal `w`,
- series is tropical/additive composition,
- parallel is entrywise `min` on the effective connection.

#### Step A2: Prove semantic compositionality
Show exactly how boundary matrices transform under constructors. This should be a chain of executable algebra lemmas, using `Matrix`, `Fin`, and `min`/`+` identities.

For example:
```lean
theorem eval_series :
  evalBoundaryDist (series E₁ E₂)
    = seriesBoundaryTransform (evalBoundaryDist E₁) (evalBoundaryDist E₂)

theorem eval_parallel :
  evalBoundaryDist (parallel E₁ E₂)
    = parallelBoundaryTransform (evalBoundaryDist E₁) (evalBoundaryDist E₂)
```

#### Step A3: Prove injectivity on reduced normal forms
Define a canonical reduced normal form for SP expressions:
- flatten associative parallel/series nodes,
- remove trivial one-edge decompositions,
- impose ordering if needed via multiset or list normalization,
- forbid ambiguous mixed decompositions.

Then prove:
```lean
theorem reduced_nf_injective :
  ∀ {E₁ E₂ : SPExpr k},
    ReducedNF E₁ → ReducedNF E₂ →
    evalBoundaryDist E₁ = evalBoundaryDist E₂ →
    E₁ = E₂
```

This yields the rigidity theorem syntactically. Afterwards relate syntax to graph semantics.

**Why Strategy A is promising:** it avoids difficult finite graph quotienting and turns the hard inverse problem into a normal-form theorem for a free algebra with tropical semantics.

---

### Strategy B: Tropical Schur complement / elimination
This is mathematically deeper and more reusable.

#### Step B1: Encode the network by a weighted matrix
Let `A : Matrix V V (WithTop ℝ)` or `ℝ∞`-style weights, where absent edges have weight `∞`. Define tropical matrix multiplication with `min` and `+`.

#### Step B2: Eliminate interior vertices
For a partition `V = B ⊔ I`, define tropical Schur complement as the closure/elimination of `I`:
- either via repeated Floyd–Warshall-style vertex elimination,
- or as a tropical star/closure formula.

Then prove this computes the shortest boundary-to-boundary path weights.

This may leverage existing shortest path formalizations in Mathlib if available; otherwise define the restricted path semantics directly.

#### Step B3: Show SP networks are reconstructible from the Schur complement
Use the decomposition theorem for SP graphs:
- every reduced SP graph has a top-level series or parallel split,
- this split is detectable from metric identities in the boundary matrix.

Typical signatures:
- parallel decomposition corresponds to a min decomposition,
- series decomposition corresponds to additive factorization across a cut terminal.

Then recurse.

**Why Strategy B matters:** it creates a reusable tropical elimination framework beyond SP networks, potentially for treewidth-bounded or chordal classes.

---

### Strategy C: Hybrid semantic-syntactic route
Use Strategy B to prove `tropicalSchurComplement = boundaryDist`, but use Strategy A for injectivity via syntax trees. This may be the optimal balance:
- elimination gives conceptual depth,
- syntax gives manageable formal reconstruction.

## Concrete mathematical invariants to exploit

For 2-terminal SP networks with positive weights:
- effective distance of a single edge: `d = w`
- series: `d(series N₁ N₂) = d(N₁) + d(N₂)`
- parallel: `d(parallel N₁ N₂) = min (d N₁) (d N₂)`

This alone is not rigid, so the true theorem needs richer boundary data:
- either multiple terminals (`k ≥ 3`),
- or enriched observables such as all terminal-to-terminal distances,
- or decomposition trees with distinguished terminals.

For `k = 3` or more, expect decomposition signatures in the matrix:
- cut terminals induce additive equalities,
- parallel branch competition induces min identities,
- reducedness should prevent accidental collisions.

A plausible detectable series signature:
```text
∃ t, ∀ i in left, j in right, D i j = D i t + D t j
```
A plausible detectable parallel signature:
```text
D = min(D₁, D₂) entrywise
```
with each `Dₗ` satisfying consistency constraints from subexpressions.

These identities are tropical analogues of rank/factorization conditions.

## How to leverage catalog theorems
Even if they are from neighboring domains, use them as semantic inspiration and technical scaffolding.

1. `gl3_value_determined_by_boundary_and_levi`
   - This is philosophically central: a global object determined by boundary data plus controlled internal structure.
   - Mirror its architecture: define the “Levi part” of an SP network as its decomposition skeleton, and show boundary data determines the remaining parameters.
   - If the proof in `Tropical/GL3Reconstruction.lean` uses a decomposition + uniqueness pattern, imitate that structure for your reconstruction theorem.

2. `tropical_network_lipschitz_bound`
   - Use this to formulate stability corollaries: the boundary distance map from edge weights to boundary matrix is Lipschitz.
   - After proving rigidity, derive a robustness statement:
   ```lean
   theorem sp_boundary_reconstruction_stable : ...
   ```
   saying small perturbations in weights induce controlled perturbations in boundary observables.
   This makes the theorem algorithmically relevant.

3. `tropical_interior_convex`
   - Use this as a local convexity lemma in min-plus interpolation arguments.
   - If you define the set of realizable boundary matrices for a fixed SP skeleton, tropical convexity may help prove uniqueness or normal-form separation.

4. `bool_and_as_tropical_max`, `tropical_and_bound`
   - These suggest a logic/tropical bridge: SP composition behaves like compositional logic gates in min/max algebra.
   - This can motivate a corollary that SP network semantics forms a tropical circuit model.

## Cross-domain connections to emphasize
You should make the formal development explicitly connect to at least two of these:

- **Inverse problems / Calderón philosophy:** recover hidden structure from boundary observations, but in min-plus metric form.
- **Tropical geometry:** Schur complement as tropical elimination; boundary matrix as an elimination invariant.
- **Circuit complexity:** SP decomposition trees are circuit formulas; rigidity says observable semantics identifies reduced formulas.
- **Phylogenetics / tree metrics:** boundary distances as finite metrics; SP networks generalize tree reconstruction by allowing parallel alternatives.
- **Optimal control / dynamic programming:** tropical semiring semantics is Bellman composition; the theorem says certain dynamic programs are externally identifiable.
- **Explainable AI / neural tropicalization:** hidden architecture reconstructed from tropical input-output geometry.

## Suggested formal definitions
Use concrete, Lean-friendly structures.

```lean
structure WEdge (V : Type) [DecidableEq V] where
  src : V
  dst : V
  w   : ℝ

structure TropNetwork (V : Type) [DecidableEq V] where
  edges : Finset (WEdge V)
```

Then define:
- adjacency cost with `∞` for absent edge, perhaps using `ENNReal` or `WithTop ℝ`
- weighted path length
- `boundaryDistMatrix : TropNetwork V → Finset V → Matrix (Fin b.card) (Fin b.card) ℝ`
  after choosing an ordering of the boundary finite set

If `ℝ` causes existence/minimum headaches, strongly consider:
- positive weights in `ℕ` or `ℚ`,
- or `ENNReal` for shortest path minima on finite graphs.

For a first theorem, `ℕ`-weights may dramatically simplify minimization and normal forms.

## Minimal viable theorem ladder
Do not jump immediately to the grand theorem. Build this ladder:

1. **Semantics of 2-terminal SP expressions**
```lean
theorem eval_effDist_atom ...
theorem eval_effDist_series ...
theorem eval_effDist_parallel ...
```

2. **Normal form and uniqueness for labeled expressions**
```lean
theorem two_terminal_nf_sound ...
theorem two_terminal_nf_complete ...
```

3. **k-terminal boundary matrix compositionality**
```lean
theorem eval_boundary_series_k ...
theorem eval_boundary_parallel_k ...
```

4. **Rigidity for reduced k-terminal SP expressions**
```lean
theorem sp_expr_boundary_rigid ...
```

5. **Graph-level soundness**
```lean
theorem graph_semantics_of_expr ...
```

6. **Optional deep theorem**
```lean
theorem tropical_schur_complement_eq_boundaryDist ...
```

## Lean 4 implementation advice
- Prefer an inductive syntax for SP objects before quotienting by graph equivalence.
- Use `Matrix (Fin k) (Fin k) α` for boundary observables.
- If tropical matrix algebra becomes cumbersome, define the exact entrywise transforms directly first.
- Separate:
  1. combinatorial syntax,
  2. semantic evaluation,
  3. reduction/normalization,
  4. injectivity.
- Keep all terminal labels explicit. Hidden relabeling can be added later as an equivalence theorem.

## Candidate theorem statements to actually prove first

### Theorem 1: compositional tropical semantics
```lean
theorem boundaryDist_two_terminal_series_parallel
  (E₁ E₂ : SPExpr2) :
  effDist (series E₁ E₂) = effDist E₁ + effDist E₂ ∧
  effDist (parallel E₁ E₂) = min (effDist E₁) (effDist E₂)
```

### Theorem 2: reduced normal forms are semantically rigid
```lean
theorem reduced_spexpr2_semantics_injective
  {E₁ E₂ : ReducedSPExpr2}
  (h : eval E₁ = eval E₂) :
  E₁ = E₂
```
This may require enriching semantics beyond a single scalar; if so, move immediately to 3-terminal or boundary matrix semantics.

### Theorem 3: labeled k-terminal rigidity
```lean
theorem reduced_labeled_sp_boundary_rigid
  {k : ℕ}
  {E₁ E₂ : LabeledSPExpr k}
  (h₁ : Reduced E₁) (h₂ : Reduced E₂)
  (h : evalBoundaryDist E₁ = evalBoundaryDist E₂) :
  E₁ = E₂
```

### Theorem 4: elimination computes boundary semantics
```lean
theorem tropical_elim_correct
  {V : Type} [Fintype V] [DecidableEq V]
  (N : TropNetwork V) (B : Finset V) :
  tropicalElimBoundary N B = boundaryDistMatrix N B
```

## Application keywords
tropical geometry, min-plus algebra, inverse problems, boundary rigidity, series-parallel graphs, tropical Schur complement, network synthesis, formalized reconstruction, shortest paths, dynamic programming, circuit semantics, explainable architectures, metric identification, categorical compositionality

## Deliverables
1. One main theorem, fully formalized if possible.
2. Supporting definitions for SP syntax/networks and boundary distance matrices.
3. At least one nontrivial compositionality lemma.
4. At least one rigidity or reconstruction theorem.
5. A structured `FUTURE_DIRECTIONS.md` with 3–5 concrete next breakthroughs, for example:
   - extend rigidity from SP networks to bounded-treewidth tropical networks;
   - prove stability/condition-number bounds for reconstruction;
   - tropical Dirichlet-to-Neumann analogues for weighted directed graphs;
   - categorical equivalence between SP syntax and a class of tropical transfer matrices;
   - algorithm extraction: certified reconstruction procedure from boundary matrix.

Be bold: the real target is not “another graph theorem,” but the birth of a **formal tropical inverse theory**.

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
