## Assignment: Reconstruction algorithm

**Mode: prove**

Prove a genuinely new reconstruction theorem at the interface of finite metric geometry, graph realization, and algorithmic complexity. The target is not merely “some graph realizing some distances,” but a formally certified **structure theorem plus reconstruction algorithm** for boundary distance data, with explicit witness extraction and asymptotic control.

The breakthrough vision is this: turn a bare finite boundary distance matrix into a canonical combinatorial object whose correctness is machine-checked in Lean. This is a discrete inverse problem, resonant with lens rigidity, phylogenetic reconstruction, network tomography, and tropical geometry. If done well, it opens a new formal bridge between **inverse metric problems** and **constructive graph synthesis**.

---

## Research Direction

Given a finite boundary distance matrix satisfying metric axioms and an additional realizability criterion, reconstruct a weighted graph — first a tree, then potentially a series-parallel graph — whose designated boundary vertices realize exactly those distances. Prove explicit complexity bounds for the reconstruction procedure.

The scientifically ambitious target is:

1. **Exact tree reconstruction from additive metrics** with a certified witness graph.
2. **Uniqueness up to weighted graph isomorphism** for the reconstructed tree.
3. **Algorithmic complexity bound** for the witness extraction.
4. A first bridge theorem connecting boundary separation / rigidity ideas to reconstructibility.

This is a formal inverse problem: from distances on terminals, recover hidden geometry.

---

## Mathematical Framing

Let `n : ℕ` and let `D : Matrix (Fin n) (Fin n) ℝ` be a symmetric zero-diagonal metric on a finite set of boundary labels. The key nontrivial hypothesis is **additivity / tree-metric structure**, e.g. Buneman’s four-point condition. Under this hypothesis, prove there exists a finite weighted tree `T` with leaves identified with `Fin n` such that leaf-to-leaf shortest path distances in `T` are exactly `D`.

Then strengthen this to a reconstruction theorem: not only existence, but an explicit procedure producing such a tree, together with a complexity bound.

This is the correct first frontier because tree metrics are the universal solvable case of graph realization, and series-parallel realization should be approached only after tree reconstruction is formalized cleanly.

---

## Precise Theorem Targets

### Target 1: Four-point condition implies exact tree realization

Define a predicate expressing the four-point condition:

- for every distinct `i j k l`, the two largest of
  `D i j + D k l`, `D i k + D j l`, `D i l + D j k`
  are equal.

Then prove:

```lean
def IsFiniteMetric {n : ℕ} (D : Matrix (Fin n) (Fin n) ℝ) : Prop :=
  (∀ i, D i i = 0) ∧
  (∀ i j, 0 ≤ D i j) ∧
  (∀ i j, D i j = D j i) ∧
  (∀ i j k, D i k ≤ D i j + D j k)

def FourPoint {n : ℕ} (D : Matrix (Fin n) (Fin n) ℝ) : Prop :=
  ∀ i j k l : Fin n,
    let s1 := D i j + D k l
    let s2 := D i k + D j l
    let s3 := D i l + D j k
    ((s1 ≤ s2 ∧ s1 ≤ s3) → s2 = s3) ∧
    ((s2 ≤ s1 ∧ s2 ≤ s3) → s1 = s3) ∧
    ((s3 ≤ s1 ∧ s3 ≤ s2) → s1 = s2)
```

A realizability theorem should look like:

```lean
theorem exists_weighted_tree_realizing_four_point
  {n : ℕ} (hn : 2 ≤ n) (D : Matrix (Fin n) (Fin n) ℝ) :
  IsFiniteMetric D →
  FourPoint D →
  ∃ (V : Type) (_finV : Fintype V) (_decV : DecidableEq V)
    (T : SimpleGraph V) (w : V → V → ℝ)
    (bdry : Fin n ↪ V),
    T.IsTree ∧
    (∀ u v, ¬ T.Adj u v → w u v = 0) ∧
    (∀ u v, 0 ≤ w u v) ∧
    (∀ i j : Fin n,
      graphDistWeighted T w (bdry i) (bdry j) = D i j)
```

You may need to replace `SimpleGraph` and `graphDistWeighted` by a custom finite weighted tree structure if shortest-path infrastructure is easier to control formally.

### Target 2: Reconstruction algorithm with explicit size/complexity control

Introduce a computable reconstruction object, perhaps:

```lean
structure WeightedTreeReconstruction (n : ℕ) where
  V : Type
  instFintype : Fintype V
  instDecEq : DecidableEq V
  T : SimpleGraph V
  w : V → V → ℝ
  bdry : Fin n ↪ V
  isTree : T.IsTree
  support_nonneg : ∀ u v, 0 ≤ w u v
  support_exact : ∀ u v, ¬ T.Adj u v → w u v = 0
```

Then define a specification:

```lean
def RealizesMatrix {n : ℕ} (R : WeightedTreeReconstruction n)
    (D : Matrix (Fin n) (Fin n) ℝ) : Prop :=
  ∀ i j : Fin n,
    graphDistWeighted R.T R.w (R.bdry i) (R.bdry j) = D i j
```

And prove existence of a reconstruction procedure:

```lean
theorem exists_reconstruction_with_complexity_bound
  {n : ℕ} (D : Matrix (Fin n) (Fin n) ℝ) :
  IsFiniteMetric D →
  FourPoint D →
  ∃ R : WeightedTreeReconstruction n,
    RealizesMatrix R D ∧
    reconstructionCost D ≤ C * n^3
```

for some explicit constant `C : ℕ` or `ℝ`, depending on how you encode complexity. If a full executable algorithm is too heavy initially, prove a weaker but still meaningful bound on the size of the witness:

```lean
∃ R, RealizesMatrix R D ∧ Fintype.card R.V ≤ 2 * n
```

This cardinality bound is already mathematically nontrivial and algorithmically suggestive.

### Target 3: Uniqueness of minimal realization

Once existence is established, prove a uniqueness theorem for reduced trees:

```lean
theorem tree_realization_unique_of_no_degree_two
  {n : ℕ} {D : Matrix (Fin n) (Fin n) ℝ}
  (hmetric : IsFiniteMetric D) (h4 : FourPoint D) :
  ∀ R₁ R₂ : WeightedTreeReconstruction n,
    RealizesMatrix R₁ D →
    RealizesMatrix R₂ D →
    ReducedLeafLabeledTree R₁ →
    ReducedLeafLabeledTree R₂ →
    EquivalentLeafLabeledWeightedTrees R₁ R₂
```

This is a theorem of real substance. It converts the inverse problem from “there exists some witness” to “the witness is canonical.”

---

## Why this would be a breakthrough

A formalized exact reconstruction theorem for additive boundary metrics would be a landmark because it would:

- establish a machine-checked version of a classical inverse metric result,
- create infrastructure for certified reconstruction in phylogenetics and network tomography,
- provide a discrete model for lens rigidity ideas,
- open the door to formal inverse problems on richer graph classes such as series-parallel or cactus graphs,
- connect tropical and combinatorial metric geometry to verified algorithms.

This is not a small extension. It is the beginning of a formal theory of **inverse discrete geometry**.

---

## Existing Verified Theorems to Build On

You must use the catalog as conceptual scaffolding, even if the exact statements are from distant domains.

1. `boundary_separating_implies_metric_separated`
   from `Bridges/AlgebraTropicalGeometry/TropicalLensRigidityDuality.lean`

   This is the most conceptually relevant building block. Use it to motivate and possibly formalize a lemma that distinct boundary labels induce distinct metric profiles. In reconstruction, one often needs a separation principle ensuring that terminals are not metrically collapsed. This can support injectivity of the boundary embedding or rule out degenerate identifications.

2. `compressor_gives_complexity_bound`
   from `Computation/ClosureKolmogorovDuality.lean`

   Even if not directly about graphs, it is a valuable pattern theorem: a constructive object comes with a certified complexity bound. Mirror its proof architecture. If it proves a complexity estimate for an extracted object from compressed data, adapt the same “witness + bound” style to the reconstruction output. This is especially important for `exists_reconstruction_with_complexity_bound`.

3. `oracle_reduces_distance`
   from `Computation/Oracles/UniversalOracleTeam.lean`

   Conceptually useful for algorithmic refinement: a reconstruction oracle that progressively reduces discrepancy between current graph distances and target matrix distances. Even if you do not define a literal oracle, you can formulate iterative improvement steps where a residual metric decreases monotonically.

4. `capacity_doubles_with_modes`

   This theorem suggests a pattern for explicit quantitative scaling laws. Use its style as inspiration for proving asymptotic or cardinality bounds such as `|V| ≤ 2n - 2` or `cost ≤ C n^3`.

5. `K_int_combo_with_divisibility`

   Likely less directly relevant, but useful if an inductive splitting step introduces arithmetic normalizations on finite indexing sets or combinatorial decomposition parameters.

---

## Recommended Formal Definitions

You will probably need to define some custom infrastructure rather than force everything through existing shortest-path APIs immediately.

### Suggested structures

```lean
structure WeightedTree where
  V : Type
  instFintype : Fintype V
  instDecEq : DecidableEq V
  T : SimpleGraph V
  w : V → V → ℝ
  isTree : T.IsTree
  symm_w : Symmetric w
  nonneg_w : ∀ u v, 0 ≤ w u v
  zero_off_edge : ∀ u v, ¬ T.Adj u v → w u v = 0
```

```lean
structure LeafLabeledWeightedTree (n : ℕ) extends WeightedTree where
  bdry : Fin n ↪ V
  leaves_boundary : ∀ i, degree T (bdry i) = 1
```

If `degree` is awkward, weaken the leaf condition at first and recover it later in the reduced model.

### Suggested predicates

```lean
def RealizesMatrix {n : ℕ}
    (R : LeafLabeledWeightedTree n)
    (D : Matrix (Fin n) (Fin n) ℝ) : Prop := ...
```

```lean
def ReducedLeafLabeledTree {n : ℕ}
    (R : LeafLabeledWeightedTree n) : Prop := ...
```

A reduced tree should have no nonboundary degree-2 vertices and all zero-length edges contracted away.

---

## Proof Strategy Paths

## Strategy A: Buneman-style inductive reconstruction by cherry reduction
**Most promising.**

This is the classical route and likely the cleanest to formalize.

1. **Detect a cherry or pendant leaf candidate from the metric.**
   Define a quantity like
   `δ(i,j,k) = (D i j + D i k - D j k) / 2`
   and prove that under the four-point condition, some leaf can be identified by consistency of these values.
   This yields the length of a pendant edge.

2. **Reduce the metric by removing one leaf.**
   Construct a smaller matrix `D' : Matrix (Fin (n-1)) (Fin (n-1)) ℝ`, prove it remains a finite metric satisfying four-point, and prove any realization of `D'` extends to one of `D`.

3. **Induct and reattach.**
   By induction obtain a realization of `D'`, then attach the removed leaf by an edge of computed weight at the appropriate attachment point. Prove exact distance preservation.

Why this is most promising:
- It is constructive.
- It naturally gives an algorithm.
- It supports cardinality and complexity bounds.
- It aligns with witness extraction in Lean.

Main formal challenge:
- managing index deletion/reinsertion on `Fin n`.
Use explicit embeddings/subtypes or finite sets of active labels.

---

## Strategy B: Split system / Buneman complex route
More conceptual, potentially stronger for uniqueness.

1. **Extract compatible splits from the metric.**
   Define split inequalities from the four-point condition and prove they form a compatible split family.

2. **Construct the tree from the split family.**
   Build vertices as consistent orientations or as cells in a Buneman complex, then show this collapses to a tree.

3. **Recover edge weights from split parameters.**
   Show the sum over separating splits equals `D i j`.

Why this is powerful:
- Gives canonicity almost for free.
- Sets up future generalizations to tropical and polyhedral geometry.
- Connects directly to combinatorial rigidity and median geometry.

Why it is harder:
- More infrastructure.
- More abstract than necessary for the first Lean breakthrough.

Use this if you want a more field-opening formalization, especially if tropical connections become central.

---

## Strategy C: Tight span / injective hull construction
Most visionary, but technically ambitious.

1. **Define the tight span of the finite metric.**
   Formalize the set of minimal 1-Lipschitz potentials realizing the metric hull.

2. **Prove that for four-point metrics the tight span is 1-dimensional.**
   Show it is a tree object.

3. **Extract a weighted tree realization from the tight span.**
   Boundary points embed isometrically, and the resulting tree realizes `D`.

Why this is revolutionary:
- It links reconstruction to tropical convexity and metric geometry.
- It would create reusable formal infrastructure for injective hulls, hyperconvexity, and tropical polytopes.
- It generalizes beyond tree metrics.

Why it is risky:
- High formal overhead.
- Probably not the first theorem to close.

Best used as a secondary architecture after Strategy A succeeds.

---

## Concrete Intermediate Lemmas to Prove

These are the real engine room.

1. **Metric separation from boundary separation**
```lean
theorem boundary_profiles_separate_vertices
  {n : ℕ} (D : Matrix (Fin n) (Fin n) ℝ) :
  IsFiniteMetric D →
  -- suitable boundary-separation hypothesis
  ∀ i j : Fin n, i ≠ j →
    ∃ k : Fin n, D i k ≠ D j k
```
Build conceptually on `boundary_separating_implies_metric_separated`.

2. **Leaf length formula**
```lean
theorem pendant_length_nonneg
  {n : ℕ} (D : Matrix (Fin n) (Fin n) ℝ) :
  IsFiniteMetric D →
  FourPoint D →
  -- suitable leaf witness hypothesis
  ∀ i j k, 0 ≤ (D i j + D i k - D j k) / 2
```

3. **Reduction preserves four-point**
```lean
theorem reduce_metric_preserves_four_point
  {n : ℕ} (hn : 3 ≤ n) (D : Matrix (Fin n) (Fin n) ℝ) :
  IsFiniteMetric D →
  FourPoint D →
  ∀ -- reduction data,
    FourPoint (reduceMetric D ...)
```

4. **Extension correctness**
```lean
theorem attach_leaf_realizes_extension
  {n : ℕ} (R : WeightedTreeReconstruction n) :
  -- hypotheses describing an attachment
  RealizesMatrix R D' →
  RealizesMatrix (attachLeaf R ...) D
```

5. **Vertex bound**
```lean
theorem tree_reconstruction_vertex_bound
  {n : ℕ} (D : Matrix (Fin n) (Fin n) ℝ) :
  IsFiniteMetric D →
  FourPoint D →
  ∃ R : WeightedTreeReconstruction n,
    RealizesMatrix R D ∧
    Fintype.card R.V ≤ 2 * n - 2
```

This `2n - 2` bound is classical for leaf-labeled trees with no degree-2 internal vertices and is highly worthwhile to formalize.

---

## Cross-Domain Connections

This project should explicitly connect to at least one other domain, preferably two.

### 1. Tropical geometry
Tree metrics are deeply tied to tropical Grassmannians and valuated matroids. The four-point condition is a tropical linearity condition in disguise. A formal theorem here lays groundwork for:

- tropical moduli of phylogenetic trees,
- tropical convex reconstruction,
- metric realizability via tropical Plücker relations.

This is the strongest conceptual bridge.

### 2. Lens rigidity / inverse problems
The phrase “boundary distance matrix” is not cosmetic. Inverse boundary problems in Riemannian geometry ask whether internal geometry is determined by boundary distances. Your theorem becomes the finite combinatorial prototype of lens rigidity. This directly aligns with `boundary_separating_implies_metric_separated`.

### 3. Phylogenetics and computational biology
Additive metrics are exactly the solvable case of evolutionary tree reconstruction. A certified Lean theorem here would be one of the cleanest formal foundations for exact phylogenetic reconstruction.

### 4. Network tomography / communication complexity
Boundary terminals and pairwise delays naturally define a reconstruction problem for hidden networks. Complexity bounds on reconstruction resonate with the catalog’s computation/oracle theorems.

### 5. Information geometry / compression
The reconstruction theorem can be interpreted as extracting minimal latent structure from pairwise observable data. This philosophically connects to `compressor_gives_complexity_bound`: compressed external behavior recovers hidden combinatorial architecture.

---

## Application Keywords

boundary distance reconstruction, additive metrics, tree metrics, Buneman theorem, four-point condition, inverse problems, lens rigidity, phylogenetics, network tomography, tropical geometry, tropical Grassmannian, certified algorithms, graph realization, formalized mathematics, complexity bounds, shortest paths, finite metric spaces

---

## Minimal First Deliverable

If the full theorem is too large in one cycle, prioritize this sequence:

1. Define `IsFiniteMetric` and `FourPoint`.
2. Prove basic lemmas about symmetry and nonnegativity consequences.
3. Prove a small-n exact theorem:
   - for `n = 3`, every finite metric is realized by a tripod tree.
4. Prove a leaf-length formula for additive metrics.
5. Prove an existence theorem with a weak witness:
   - a custom tree datatype rather than full `SimpleGraph`,
   - exact realization but no executable algorithm yet.
6. Add a cardinality bound.
7. Then upgrade to complexity.

Even a formally verified `n = 3` and `n = 4` classification would already be a serious foothold if done with reusable definitions.

---

## Suggested Lean 4 Type Signature Variants

If weighted graph shortest paths are too heavy, use a custom tree semantics:

```lean
inductive WTree
| leaf : Fin n → WTree
| node : WTree → ℝ → WTree → ℝ → WTree
```

with a recursively defined leaf-distance function. Then prove:

```lean
theorem exists_wtree_realizing_four_point
  {n : ℕ} (hn : 2 ≤ n) (D : Matrix (Fin n) (Fin n) ℝ) :
  IsFiniteMetric D →
  FourPoint D →
  ∃ T : WTree, realizesWTree T D
```

This may be the best first formal target. Once established, transport the result to graph-theoretic trees.

---

## What to avoid

- Do not settle for a tautological “there exists a graph with edge weights equal to the complete graph distances.” That trivializes the inverse problem.
- Do not weaken the target to arbitrary graph realization unless you impose meaningful minimality or structural constraints.
- Do not hide complexity in an opaque existential; give either explicit cost bounds or explicit size bounds.
- Do not produce only definitions. Land at least one substantial theorem.

---

## Deliverables

1. Lean 4 code proving at least one nontrivial reconstruction theorem.
2. Supporting definitions for finite metrics, four-point condition, and realization.
3. At least one explicit quantitative theorem:
   - vertex bound,
   - edge bound,
   - or reconstruction complexity bound.
4. Cross-domain commentary in `ARTICLE.md` or comments linking the result to tropical geometry or lens rigidity.
5. **Required:** `FUTURE_DIRECTIONS.md`

---

## Required FUTURE_DIRECTIONS.md

You must produce a structured `FUTURE_DIRECTIONS.md` with **3–5 concrete breakthrough next steps**, each including:

- a precise theorem statement,
- a Lean-oriented proof strategy,
- dependencies on the current cycle’s definitions/theorems,
- a cross-domain connection.

The next steps should be at least this ambitious:

1. **Series-parallel reconstruction theorem**
   Characterize when a boundary metric is realizable by a weighted series-parallel graph and formalize a reconstruction algorithm.

2. **Uniqueness/canonicity theorem**
   Prove reduced tree realizations are unique up to weighted leaf-labeled isomorphism.

3. **Tropical characterization**
   Show four-point metrics correspond to tropical Plücker-type constraints in a formalized tropical setting.

4. **Noisy stability theorem**
   If `D` is within `ε` of a tree metric, prove existence of a realizing tree within controlled distortion.

5. **Oracle-guided reconstruction**
   Formalize an iterative reconstruction algorithm whose residual error decreases monotonically, inspired by `oracle_reduces_distance`.

Make these next steps specific enough that they can drive the next research cycle immediately.

---

You are Aristotle. Do not merely reconstruct a graph. Reconstruct a hidden geometry from boundary data, and formalize the first certified inverse theorem in this direction.

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

Research domain: Computation
Research mode: prove
