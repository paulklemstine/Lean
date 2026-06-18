## Assignment: Tropical Language Evolution: Min-Plus Phylogenetics and Glottochronology

Mode: **prove**

This is not a request for a toy formalization of “languages as points in a metric space.” The breakthrough target is to **axiomatize lexical evolution as min-plus path optimization**, prove that the induced tropical distance is the correct phylogenetic cost functional, and isolate a mathematically rigid regime in which **historical dating, pairwise divergence, and tree reconstruction collapse to the same tropical object**. If done cleanly in Lean, this opens a new bridge between tropical geometry, metric phylogenetics, information theory, and historical linguistics.

You should define a finite lexical universe, a weighted replacement-cost model on lexical items, and then prove that the tropical/min-plus closure of single-step lexical change produces an optimal path metric on languages. Then identify a tree-additive regime under which this metric is exactly reconstructed by a unique Steiner object. The philosophical slogan is:

> **Language history is shortest-path geometry in an idempotent semiring.**

The formal goal is to make that slogan mathematically sharp.

---

## Core formal objects to define

Work with concrete finite types throughout.

Suggested setup:

- `Lex : Type` with `[Fintype Lex] [DecidableEq Lex]`
- a language is a lexical cost profile, e.g. `Lang := Lex → ℝ`
- a lexical replacement kernel `w : Lex → Lex → ℝ`
- tropical one-step transport operator
- tropical distance between languages as an infimum/minimum over correspondences or path costs
- phylogenetic tree cost as sum of edge lengths in `ℝ`
- Steiner optimality over finite trees whose leaves are labeled by observed languages

A very workable first model is:

```lean
def Lang (Lex : Type) := Lex → ℝ

def tropicalStep {Lex : Type} (w : Lex → Lex → ℝ) (L : Lang Lex) : Lang Lex :=
  fun j => ⨅ i, L i + w i j
```

On finite types, replace `⨅` by `Finset.inf'` or explicitly use `s.inf'`. Since the assignment requests concrete types, you may prefer `Lex := Fin n` and define all minima over `Finset.univ`.

Then define the induced multi-step cost by iterating `tropicalStep`, or more directly define the tropical metric closure of the kernel:

```lean
def tropicalKernelClosure {Lex : Type} [Fintype Lex] [DecidableEq Lex]
    (w : Lex → Lex → ℝ) : Lex → Lex → ℝ :=
  fun i j => sInf {c : ℝ | ∃ p : List Lex, p.Head? = some i ∧ p.getLast? = some j ∧
    c = pathCost w p}
```

But because `sInf` over arbitrary sets is painful, a more Lean-friendly route is to define path cost over bounded-length paths on finite types and use the standard fact that shortest paths on a finite graph can be realized with simple paths of length at most `Fintype.card Lex`. This gives computable minima.

For languages themselves, one natural distance is a coordinatewise tropical transport discrepancy:

```lean
def tropicalDist {Lex : Type} [Fintype Lex] [DecidableEq Lex]
    (w : Lex → Lex → ℝ) (L₁ L₂ : Lang Lex) : ℝ :=
  max
    (Finset.univ.sup fun j => L₂ j - tropicalStep w L₁ j)
    (Finset.univ.sup fun i => L₁ i - tropicalStep (fun a b => w b a) L₂ i)
```

This is a tropical analogue of the asymmetric residual distance; symmetrizing it gives a genuine metric candidate. If this becomes too heavy, use a simpler and very formalizable model:

```lean
def tropicalDistSimple {Lex : Type} [Fintype Lex]
    (L₁ L₂ : Lex → ℝ) : ℝ :=
  Finset.univ.sup fun x => |L₁ x - L₂ x|
```

and prove the tropical dynamics result for `tropicalStep` separately. Then show that in the additive tree regime the pairwise leaf distances are exactly path sums.

---

## Precise theorem targets

You should aim for a cluster of theorems, not one monolith.

### Theorem 1: Tropical diffusion is min-plus linear and nonexpansive

This is the foundational dynamics theorem: one-step lexical evolution is a min-plus linear operator and contracts/satisfies nonexpansiveness in sup norm. This is the formal mathematical content behind “language divergence follows a tropical diffusion process.”

**Lean 4 target signature:**
```lean
theorem tropicalStep_minplus_linear
    {Lex : Type} [Fintype Lex] [DecidableEq Lex]
    (w : Lex → Lex → ℝ) (a : ℝ) (L₁ L₂ : Lex → ℝ) :
    tropicalStep w (fun i => min (a + L₁ i) (a + L₂ i)) =
      fun j => min (a + tropicalStep w L₁ j) (a + tropicalStep w L₂ j)
```

This should build directly on the catalog theorem
`tropical_plus_distributes_over_min`.

A second key statement:

```lean
theorem tropicalStep_nonexpansive
    {Lex : Type} [Fintype Lex] [DecidableEq Lex]
    (w : Lex → Lex → ℝ) (L₁ L₂ : Lex → ℝ) :
    tropicalDistSimple (tropicalStep w L₁) (tropicalStep w L₂) ≤
      tropicalDistSimple L₁ L₂
```

This is the rigorous diffusion statement: the tropical update does not amplify lexical discrepancy.

**Why this is a breakthrough:** it turns lexical change into a certified idempotent dynamical system, making historical linguistics accessible to the machinery of tropical linear algebra and fixed-point theory.

---

### Theorem 2: Tropical path closure gives the optimal phylogenetic distance

Define a finite weighted graph on lexical states or proto-language states. Let `dₜ` be the shortest-path distance induced by edge weights in the min-plus semiring. Prove that it is the least path-additive metric dominating one-step transitions.

**Lean 4 target signature:**
```lean
theorem tropical_closure_is_shortestPath_optimal
    {V : Type} [Fintype V] [DecidableEq V]
    (w d : V → V → ℝ)
    (h_refl : ∀ v, d v v = 0)
    (h_step : ∀ u v, d u v ≤ w u v)
    (h_tri : ∀ u v z, d u z ≤ d u v + d v z)
    (h_closure : ∀ u v, shortestPathDist w u v ≤ d u v) :
    ∀ u v, shortestPathDist w u v ≤ d u v
```

More interestingly, prove the universal property in the other direction:

```lean
theorem shortestPathDist_least_path_metric
    {V : Type} [Fintype V] [DecidableEq V]
    (w : V → V → ℝ) :
    ∀ d : V → V → ℝ,
      (∀ v, d v v = 0) →
      (∀ u v, d u v ≤ w u v) →
      (∀ u v z, d u z ≤ d u v + d v z) →
      ∀ u v, shortestPathDist w u v ≤ d u v
```

This theorem is the formal version of:

> the tropical distance between languages is the optimal phylogenetic distance.

It says shortest tropical path cost is not merely a heuristic; it is the **initial object** among all admissible phylogenetic metrics compatible with lexical transitions.

---

### Theorem 3: Glottochronological dating is recovered from additive tropical distance

To avoid pseudoscientific overreach, formalize this in a rigid additive regime: if lexical replacement occurs at a constant edge rate `ρ ≥ 0`, then branch length is proportional to tropical path cost, and pairwise dating is recovered as half the tree distance between leaves descending from a common ancestor.

Define a rooted tree with edge lengths and a leaf labeling. Assume lexical evolution along an edge of length `t` adds cost `ρ * t`.

**Lean 4 target signature:**
```lean
theorem glottochronology_from_tropical_tree
    {V : Type} [Fintype V] [DecidableEq V]
    (root : V) (parent : V → Option V) (len : V → ℝ)
    (ρ : ℝ) (x y : V)
    (hx : isLeaf parent x) (hy : isLeaf parent y)
    (hρ : 0 ≤ ρ)
    (hTree : isRootedTree root parent)
    (hAdd : ∀ v, 0 ≤ len v) :
    tropicalLeafDist parent len ρ x y =
      ρ * treePathLength parent len x y
```

Then derive the standard dating formula under ultrametricity:

```lean
theorem glottochronological_date_formula
    {V : Type} [Fintype V] [DecidableEq V]
    (root : V) (parent : V → Option V) (len : V → ℝ)
    (ρ : ℝ) (x y : V)
    (hUltra : isUltrametric root parent len)
    (hρ : 0 < ρ) :
    divergenceTime root parent len x y =
      tropicalLeafDist parent len ρ x y / (2 * ρ)
```

This is the mathematically disciplined version of “glottochronological dating is recovered as tropical distance estimation.”

**Why this matters:** it replaces heuristic logarithmic dating rules by a semiring-geometric identity, showing exactly when such dating is valid and when it fails.

---

### Theorem 4: Uniqueness of the tropical phylogenetic tree as a min-plus Steiner tree

This is the flagship theorem. You probably need a restricted but meaningful regime: finite leaf set, additive metric satisfying Buneman’s four-point condition, and strict edge weights ensuring no degeneracy. Under these hypotheses, the realizing tree is unique, and it is the unique minimizer of the Steiner cost among all trees spanning the observed languages.

A realistic formal target:

```lean
theorem unique_steiner_of_strict_tree_metric
    {X : Type} [Fintype X] [DecidableEq X]
    (d : X → X → ℝ)
    (hmetric : IsMetric d)
    (hfour : FourPointCondition d)
    (hstrict : StrictInternalEdgeCondition d) :
    ∃! (T : PhyloTree X),
      realizesTreeMetric T d ∧
      ∀ S : PhyloTree X, steinerCost T ≤ steinerCost S
```

If full uniqueness is too ambitious in the first pass, prove first:

```lean
theorem exists_steiner_realizing_tree_of_four_point
    {X : Type} [Fintype X] [DecidableEq X]
    (d : X → X → ℝ)
    (hmetric : IsMetric d)
    (hfour : FourPointCondition d) :
    ∃ T : PhyloTree X, realizesTreeMetric T d
```

and then a second theorem:

```lean
theorem realization_unique_under_strictness
    {X : Type} [Fintype X] [DecidableEq X]
    (d : X → X → ℝ)
    (hstrict : StrictInternalEdgeCondition d) :
    ∀ {T₁ T₂ : PhyloTree X},
      realizesTreeMetric T₁ d →
      realizesTreeMetric T₂ d →
      T₁ = T₂
```

This would already be major. The “min-plus Steiner” language becomes precise once you define tree cost tropically as path-sum and optimize over internal vertices.

**Why this is revolutionary:** it identifies a class of language families where historical reconstruction is not underdetermined. In that regime, the tropical tree is not one plausible history among many; it is the unique semiring-optimal explanation.

---

## How to build on catalog theorems

Use the existing catalog results explicitly, not decoratively.

1. **`tropical_plus_distributes_over_min`**
   - This is the engine for proving `tropicalStep_minplus_linear`.
   - At each coordinate `j`, expand:
     \[
     \min_i \big(\min(a+L_1(i), a+L_2(i)) + w(i,j)\big)
     \]
     and rewrite using distributivity of addition over `min`.
   - This is exactly the idempotent linearity law needed for tropical diffusion.

2. **`tropical_and_bound`**
   - Use this as the order-theoretic one-sided inequality when comparing min-expressions during nonexpansiveness proofs.
   - It helps discharge goals of the form `min a b ≤ a`, `min a b ≤ b`.

3. **`tropical_distance_descends_codeEq`**
   - This is conceptually important if you quotient lexical items by synonymy, orthographic equivalence, or cognate coding.
   - Use it to show that your tropical distance is invariant under coding-equivalence classes of lexical features. This gives a robust theorem:
   ```lean
   theorem tropical_language_distance_invariant_under_coding
   ```
   meaning the phylogenetic metric depends only on coded lexical structure, not arbitrary representational choices.

This is the bridge to information theory and coding theory: lexical comparison should descend to equivalence classes exactly as source coding distances do.

---

## Proof strategy architecture

### Strategy A: Finite-coordinate tropical operator calculus
Most promising for Theorems 1 and 3.

1. Define all operators over `Finset.univ`, avoiding `sInf` and infinite infima.
2. Prove coordinatewise identities using:
   - distributivity of `+` over `min`
   - `Finset` lemmas for `inf'`, `sup`
   - pointwise extensionality `funext`
3. Derive nonexpansiveness in sup norm by bounding each coordinate and then taking `sup`.

**Why most promising:** it is Lean-native, computational, and directly exploits the catalog theorem `tropical_plus_distributes_over_min`.

---

### Strategy B: Shortest-path universal property via graph metrics
Best for Theorem 2.

1. Model lexical evolution as a weighted directed graph.
2. Define path cost and shortest-path distance over bounded simple paths in a finite graph.
3. Prove:
   - shortest-path distance is path-additive
   - any path-additive metric bounded above by edge costs dominates shortest-path distance
4. Conclude optimality/universality.

**Why promising:** this avoids difficult analytic infimum arguments and turns “optimal phylogenetic distance” into a standard extremal graph theorem formalized over finite combinatorics.

---

### Strategy C: Tree-metric rigidity through four-point condition
Best for Theorem 4, but likely hardest.

1. Define `FourPointCondition d` and a concrete `PhyloTree X`.
2. Use known finite-metric characterizations: additive tree metrics are exactly those satisfying the four-point condition.
3. Add a strictness hypothesis to eliminate isomorphic ambiguities from zero-length internal edges.
4. Show any two realizing trees must agree on all quartet splits, hence coincide.

**Why promising:** quartet rigidity is combinatorial and finite, making it suitable for Lean. It also imports a deep phylogenetic theorem into the tropical framework.

---

## Cross-domain connections you must exploit

Do not leave this as “math inspired by linguistics.” Make it a bridge theorem.

### 1. Tropical geometry × historical linguistics
The min-plus semiring is the natural algebra of optimal change and ancestral reconstruction. This reframes language evolution as tropical convexity and shortest-path geometry.

### 2. Information theory × lexical coding
Use `tropical_distance_descends_codeEq` to argue that lexical distances are coding-invariant under finite cognate encodings. This suggests a new theory of **idempotent source coding for language families**.

### 3. Graph algorithms × phylogenetic reconstruction
Shortest paths, Steiner trees, and four-point conditions connect the formalization to certified reconstruction algorithms. This opens machine-verifiable historical inference.

### 4. Dynamical systems × glottochronology
`tropicalStep_nonexpansive` makes lexical change a discrete dissipative dynamical system. Fixed points correspond to stable lexical cores; contraction rates correspond to historical retention.

### 5. Category-theoretic semantics of evolution
If time permits, package tropical diffusion as an endofunctor on finite weighted lexical spaces, with tree reconstruction as a universal property. This could become a semantic language for evolutionary processes across biology and linguistics alike.

---

## Application keywords

tropical geometry, min-plus algebra, phylogenetics, glottochronology, Steiner tree, shortest-path metric, tree metric rigidity, four-point condition, lexical diffusion, historical linguistics, coding invariance, idempotent information theory, finite graph optimization, ultrametric reconstruction, certified evolutionary inference

---

## Concrete implementation advice in Lean 4

- Prefer `Fin n` or a finite custom type over abstract infinite lexical spaces.
- Define path costs over `List` or `Vector`; then restrict to bounded length using finiteness.
- For sup/inf over finite sets, use `Finset`.
- Build `IsMetric` yourself if existing Mathlib metric-space abstractions are too heavy for function-valued finite metrics.
- Separate asymmetric tropical transport from symmetrized distance.
- Prove lemmas in layers:
  1. pointwise min-plus algebra
  2. finite infimum/supremum lemmas
  3. path metric lemmas
  4. tree reconstruction lemmas

A very good decomposition is:

1. `TropicalLexicon.lean`
2. `TropicalDiffusion.lean`
3. `TropicalShortestPath.lean`
4. `TropicalGlottochronology.lean`
5. `TropicalPhyloSteiner.lean`

---

## Minimum theorem bundle to deliver

At minimum, prove a coherent package of 3–5 nontrivial theorems, ideally including:

1. `tropicalStep_minplus_linear`
2. `tropicalStep_nonexpansive`
3. `shortestPathDist_least_path_metric`
4. `glottochronological_date_formula`
5. one existence/uniqueness theorem for tree realization under four-point or strict tree-metric assumptions

If the full uniqueness theorem is too difficult, prove the existence theorem plus a rigorously stated strictness-to-uniqueness theorem under stronger hypotheses.

---

## Team directive

Create a research team with explicit subproblems:

- **Algebra team:** tropical operator identities and semiring lemmas
- **Dynamics team:** contraction/nonexpansiveness and iteration of lexical diffusion
- **Graph team:** shortest-path universal property and Steiner optimization
- **Phylogeny team:** four-point condition, tree realization, uniqueness
- **Semantics team:** coding invariance and cross-domain interpretation

Run small formal experiments on finite examples (`Fin 2`, `Fin 3`, `Fin 4`) before generalizing.

---

## Deliverables

1. Lean files with minimized `sorry`.
2. Precise theorem statements, even for the hardest targets.
3. At least one theorem explicitly invoking a catalog theorem.
4. A structured `FUTURE_DIRECTIONS.md` containing **3–5 concrete, breakthrough-level next steps**, for example:
   - tropical mutual information for lexical families
   - tropical Gromov reconstruction for incomplete word lists
   - stability of phylogenetic trees under lexical coding noise
   - idempotent Bayesian inference for proto-language reconstruction
   - comparison of tropical linguistic trees with biological phylogenetic metrics

Be bold: the true target is not merely a formal model of linguistic distance, but a new theorem schema saying that **historical structure can be recovered as tropical optimization geometry**.

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

Research domain: Bridges
Research mode: prove
