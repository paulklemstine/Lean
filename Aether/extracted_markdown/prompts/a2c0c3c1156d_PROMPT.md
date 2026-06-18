## Assignment: Boundary determines bulk distances

**Mode:** prove

Prove a genuinely new rigidity theorem: under a tree / unique-geodesic hypothesis, the metric on the boundary determines the metric in the interior. Do not settle for a graph-isomorphism statement; target an explicit reconstruction formula for interior distances from boundary distances, then derive uniqueness. The breakthrough is to turn “boundary data” into a **tropical inverse problem**: recover bulk geometry from min-plus observables.

This is the right scale of theorem because it sits at a three-way intersection:
- **metric graph rigidity / inverse problems**,
- **tropical geometry** via min-plus distance structure,
- **discrete tomography / network science** via boundary measurements.

The conceptual ambition is: **boundary distance matrices are tropical scattering data, and the interior metric is the bulk phase recovered from them.**

---

## Core theorem target

Let `V` be a finite vertex type, `B : Finset V` a designated boundary, and `d : V → V → ℝ` a graph metric. The correct theorem is not merely “if two graphs have the same boundary matrix then maybe some interior values agree,” but:

> **Boundary-to-bulk rigidity for trees.**  
> Let `T₁, T₂` be weighted trees on the same finite vertex set `V`, with the same boundary set `B ⊆ V`. Assume every interior vertex has degree ≠ 2 or, equivalently, the combinatorial tree is reduced enough that vertices are metrically identifiable. If
> \[
> \forall b_1,b_2\in B,\quad d_1(b_1,b_2)=d_2(b_1,b_2),
> \]
> then
> \[
> \forall x,y\in V,\quad d_1(x,y)=d_2(x,y).
> \]
> Moreover, for each interior vertex `x`, its distances to boundary points are determined by the boundary matrix alone, and for all `x,y`
> \[
> d(x,y)=\max_{a,b\in B}\frac{d(x,a)+d(y,b)-d(a,b)-d(x,b)-d(y,a)+d(a,b)}{2}
> \]
> or, more canonically in a tree, by Gromov products / median formulas extracted from boundary data.

The deepest formalizable version is a **reconstruction formula**. Uniqueness should be a corollary.

---

## Lean 4 formalization target

You likely need to define a lightweight structure for finite tree metrics or work abstractly with a metric satisfying the four-point/tree condition. Prefer the abstract metric route if graph infrastructure becomes heavy.

A plausible formal target is:

```lean
/-- A finite metric is tree-like if it satisfies the four-point condition. -/
def IsTreeLikeMetric {V : Type} [Fintype V] (d : V → V → ℝ) : Prop := 
  (∀ x y, 0 ≤ d x y) ∧
  (∀ x y, d x y = d y x) ∧
  (∀ x, d x x = 0) ∧
  (∀ w x y z,
    d w x + d y z ≤ max (d w y + d x z) (d w z + d x y))

/-- A vertex is boundary-visible if its distances to boundary points determine it uniquely. -/
def BoundaryVisible {V : Type} (B : Finset V) (d : V → V → ℝ) (x : V) : Prop :=
  ∀ y, (∀ b ∈ B, d x b = d y b) → y = x

/-- Boundary distance matrices determine the whole metric under tree-likeness and visibility. -/
theorem boundary_determines_bulk_distance
  {V : Type} [Fintype V] [DecidableEq V]
  (B : Finset V)
  (d₁ d₂ : V → V → ℝ)
  (hBnonempty : B.Nonempty)
  (h₁tree : IsTreeLikeMetric d₁)
  (h₂tree : IsTreeLikeMetric d₂)
  (h₁vis : ∀ x : V, BoundaryVisible B d₁ x)
  (h₂vis : ∀ x : V, BoundaryVisible B d₂ x)
  (hbdry : ∀ a ∈ B, ∀ b ∈ B, d₁ a b = d₂ a b) :
  ∀ x y : V, d₁ x y = d₂ x y := by
  sorry
```

A more tractable intermediate theorem, and probably the one to prove first, is the **boundary embedding uniqueness** statement:

```lean
theorem boundary_distance_vector_injective
  {V : Type} [Fintype V] [DecidableEq V]
  (B : Finset V) (d : V → V → ℝ)
  (hvis : ∀ x : V, BoundaryVisible B d x) :
  Function.Injective (fun x : V => fun b : {v // v ∈ B} => d x b) := by
  sorry
```

Then prove a reconstruction identity for tree-like metrics:

```lean
/-- Candidate Gromov-product style reconstruction from boundary data. -/
def boundaryGromov
  {V : Type} [DecidableEq V]
  (B : Finset V) (d : V → V → ℝ) (x a b : V) : ℝ :=
  (d x a + d x b - d a b) / 2

theorem tree_metric_reconstruction_from_boundary
  {V : Type} [Fintype V] [DecidableEq V]
  (B : Finset V) (d : V → V → ℝ)
  (htree : IsTreeLikeMetric d)
  (hvis : ∀ x : V, BoundaryVisible B d x)
  (hBcard : 2 ≤ B.card) :
  ∀ x y : V, ∃ F : ({v // v ∈ B} → ℝ) → ({v // v ∈ B} → ℝ) → ℝ,
    d x y = F (fun b => d x b.1) (fun b => d y b.1) := by
  sorry
```

If this fully abstract theorem is too ambitious for one cycle, specialize to a concrete finite tree model with weighted edges and shortest-path distance. A highly formalizable finite version is:

```lean
theorem weighted_tree_boundary_matrix_determines_all_pair_distances
  {V : Type} [Fintype V] [DecidableEq V]
  (B : Finset V)
  (d₁ d₂ : V → V → ℝ)
  (h₁tree : IsTreeLikeMetric d₁)
  (h₂tree : IsTreeLikeMetric d₂)
  (h₁leafBoundary : ∀ v, v ∈ B ↔ IsLeafMetricVertex d₁ v)
  (h₂leafBoundary : ∀ v, v ∈ B ↔ IsLeafMetricVertex d₂ v)
  (hbdry : ∀ a ∈ B, ∀ b ∈ B, d₁ a b = d₂ a b) :
  ∀ x y, d₁ x y = d₂ x y := by
  sorry
```

You may need to define `IsLeafMetricVertex` in purely metric terms if graph-theoretic leaf notions are inconvenient.

---

## Why this is a breakthrough

If formalized cleanly, this opens a new lane in Lean:
1. **Discrete inverse problems** become formal theorem objects.
2. **Tropical reconstruction** becomes a reusable pattern: min-plus boundary observables determine hidden geometry.
3. It creates a bridge from certified tropical identities in the catalog to geometric rigidity. The catalog’s `gl3_value_determined_by_boundary_and_levi` and `interior_value_determined_by_edge_and_levi` already express a philosophy: **interior structure is pinned down by restricted external data**. Your theorem should lift that philosophy from representation-theoretic/tropical local data to global finite metric geometry.

This is not an incremental graph lemma. It is a formal prototype of boundary rigidity, the discrete cousin of the boundary rigidity problem in Riemannian geometry.

---

## How to build on catalog theorems

Use the catalog theorems conceptually, not decoratively:

- `gl3_value_determined_by_boundary_and_levi`  
  Treat this as a precedent for **partial boundary/Levi data determining internal valuation data**. Mirror its architecture: identify a compressed observable, prove it is sufficient, then bootstrap to full reconstruction.

- `interior_value_determined_by_edge_and_levi`  
  This is especially relevant. It suggests a proof pattern:
  1. define an “interface” object (boundary matrix instead of edge+Levi data),
  2. prove an interior quantity is a function of that interface,
  3. conclude equality by extensionality.
  Your theorem should explicitly imitate this decomposition.

- `tropical_interior_convex`  
  Use it if you define reconstruction functionals via min/max or convex combinations of boundary distances. There may be a tropical convexity viewpoint: interior vertices correspond to tropical convex combinations or median points determined by boundary data.

- `bool_and_as_tropical_max`, `tropical_and_bound`  
  These can support the general min/max algebraic style if your reconstruction formula uses maxima over boundary pairs/triples. Even if not directly used, they reinforce the tropical semantics: logical constraints become max/min constraints.

---

## Proof strategy options

### Strategy A: Tree-metric via Buneman/four-point reconstruction
This is the mathematically strongest and most canonical route.

1. **Abstract tree-likeness from the boundary matrix.**  
   Show the boundary distance matrix on `B` determines the split system / four-point structure on boundary quadruples.

2. **Recover vertex positions metrically.**  
   For each interior vertex `x`, define its boundary distance profile `ρ_x : B → ℝ`, and prove in a reduced tree this profile identifies `x` uniquely.

3. **Derive pairwise distances from profiles.**  
   Prove `d x y` is computable from `ρ_x`, `ρ_y`, and the boundary matrix. Then if two metrics have the same boundary matrix and the same admissible profiles, all distances agree.

**Why promising:** this avoids low-level graph combinatorics and uses standard metric characterizations. It is closest to a reusable Mathlib-style theorem.

---

### Strategy B: Median/Steiner characterization in trees
This may be easier if you work concretely with finite trees.

1. **For each interior vertex, choose boundary witnesses.**  
   Prove every branch point/interior vertex is the median of some triple of boundary vertices under suitable reduced-tree hypotheses.

2. **Express depth and separation by boundary distances.**  
   Use the median identity:
   \[
   d(m,a)+d(m,b)=d(a,b), \quad
   d(m,a)=\tfrac{1}{2}(d(a,b)+d(a,c)-d(b,c))
   \]
   when `m` is the branch point of `a,b,c`.

3. **Reconstruct arbitrary `d(x,y)` from branch-point formulas.**  
   Once every interior vertex is represented by a boundary triple, compute distances between two interior vertices from the corresponding boundary formulas.

**Why promising:** explicit, constructive, and Lean-friendly if you can encode medians.

---

### Strategy C: Tropical linearization / min-plus embedding
This is the most visionary route.

1. **Embed each vertex into tropical coordinate space** by
   \[
   x \mapsto (d(x,b))_{b\in B}.
   \]

2. **Show the image satisfies tropical convex / injective constraints** in tree-like metrics; interior points become tropical intersections of boundary-induced halfspaces.

3. **Recover `d(x,y)` as a tropical bilinear functional** of the two coordinate vectors plus the boundary matrix.

**Why promising:** if successful, this creates a new language for tropical inverse geometry and could connect directly to the catalog’s tropical core.  
**Why risky:** more definitions, more algebra, and less off-the-shelf Mathlib support.

**Recommendation:** pursue **Strategy B first** for a concrete theorem, while structuring definitions so Strategy A can subsume it later. If progress is smooth, package the final theorem in Strategy A language.

---

## Concrete theorem ladder

Do not attack the final theorem first. Prove the following staircase.

### Theorem 1: Boundary profile injectivity
Under your chosen uniqueness hypothesis:
```lean
theorem boundary_profile_injective ...
```
If two vertices have identical distances to all boundary vertices, they are equal.

### Theorem 2: Interior vertex represented by boundary triple
For a reduced finite tree, every interior branching vertex `x` admits `a,b,c ∈ B` such that `x` is the median / branch point of `a,b,c`.

### Theorem 3: Branch-point depth formula
For such an `x` and witnesses `a,b,c`,
```lean
d x a = (d a b + d a c - d b c) / 2
```
and analogous formulas for `d x b`, `d x c`.

### Theorem 4: Boundary determines interior-boundary distances
Use Theorem 3 to show that if two trees have the same boundary matrix, then every interior vertex determined by the same witness triple has the same boundary distance profile in both trees.

### Theorem 5: Boundary determines all bulk distances
Combine boundary profile injectivity and a profile-to-distance formula to conclude:
```lean
∀ x y, d₁ x y = d₂ x y
```

This ladder is realistic and mathematically meaningful even if the final fully abstract theorem remains unfinished.

---

## Cross-domain connections to exploit

### 1. Riemannian boundary rigidity
Your theorem is a finite/tropical avatar of the boundary rigidity problem: can one recover a metric from distances between boundary points? This creates a formal sandbox for ideas from inverse geometry and geometric tomography.

### 2. Phylogenetics and tree reconstruction
Boundary vertices as leaves; interior reconstruction from leaf distances is exactly the language of phylogenetic tree metrics. If formalized, Lean could certify parts of distance-based reconstruction theory.

### 3. Tropical geometry
The map `x ↦ (d(x,b))_{b∈B}` is a min-plus coordinate chart. Bulk reconstruction from boundary data resembles tropicalization of hidden geometry. This is the most novel framing and should be emphasized in prose and `FUTURE_DIRECTIONS.md`.

### 4. Network tomography / sensor localization
Boundary nodes act as sensors, interior nodes as hidden states. The theorem says under tree-like uniqueness assumptions, sensor pair data determines hidden pair geometry. This has algorithmic and verification implications.

### 5. Representation-theoretic analogy
Levi/boundary data determining internal values in the catalog suggests a broad principle: **restricted observable data can rigidify hidden structure**. Make this analogy explicit.

---

## Suggested definitions if graph APIs are inconvenient

If shortest-path graph structures are cumbersome in Lean, define the theorem at the level of finite metrics satisfying tree axioms. This is acceptable and may be stronger.

Possible lightweight definitions:
- `IsPseudometricFinite`
- `IsTreeLikeMetric` via the four-point condition
- `BoundaryVisible`
- `BoundaryProfile B d x := fun b : {v // v ∈ B} => d x b`

Then prove rigidity of these structures. A later cycle can connect them to actual weighted trees.

---

## Lean implementation advice

- Use `Fintype`, `DecidableEq`, `Finset`, and functions `V → V → ℝ`.
- Keep all formulas over `ℝ`; avoid `ENNReal` unless necessary.
- Build helper lemmas for symmetry, diagonal zero, and algebraic rearrangements early.
- If max-over-boundary formulas are needed, define them with `Finset.sup` or `Finset.fold max`.
- If medians are hard to define globally, define a predicate:
  ```lean
  def IsMedian (d : V → V → ℝ) (m a b c : V) : Prop := ...
  ```
  with equations characterizing branch points.
- If existence of witness triples is difficult, first prove a theorem assuming such witnesses are given. That already yields a nontrivial and publishable formal result.

---

## Minimal nontrivial target if the full theorem is too large

Prove this sharply scoped theorem:

```lean
theorem branchpoint_distance_from_boundary_triple
  {V : Type} [DecidableEq V]
  (d : V → V → ℝ) (x a b c : V)
  (hmed : IsMedian d x a b c)
  (hmetric : IsTreeLikeMetric d) :
  d x a = (d a b + d a c - d b c) / 2 := by
  sorry
```

Then derive a comparison theorem:

```lean
theorem boundary_matrix_agrees_implies_branchpoint_depth_agrees
  {V : Type} [Fintype V] [DecidableEq V]
  (B : Finset V) (d₁ d₂ : V → V → ℝ)
  (x a b c : V)
  (ha : a ∈ B) (hb : b ∈ B) (hc : c ∈ B)
  (hmed₁ : IsMedian d₁ x a b c)
  (hmed₂ : IsMedian d₂ x a b c)
  (hbdry : ∀ u ∈ B, ∀ v ∈ B, d₁ u v = d₂ u v) :
  d₁ x a = d₂ x a := by
  sorry
```

This already establishes a real boundary-to-bulk reconstruction phenomenon.

---

## Deliverables

1. Lean file with the strongest proved theorem.
2. Supporting definitions and helper lemmas.
3. Minimize `sorry`; if a major gap remains, isolate it into a clearly named conjectural lemma.
4. Create `FUTURE_DIRECTIONS.md` with **3–5 specific next steps**, each containing:
   - a precise theorem statement,
   - likely proof strategy,
   - cross-domain significance.

This file is mandatory.

---

## Application keywords

boundary rigidity, tree metrics, tropical geometry, min-plus algebra, inverse problems, metric reconstruction, phylogenetics, network tomography, discrete geometry, finite metric spaces, Gromov products, median graphs, tropical convexity, sensor localization, certified reconstruction

---

## Standard of success

Success is not a toy lemma. Success is a formally verified theorem showing that **boundary observables determine hidden geometry** in a mathematically precise class of finite tropical/tree-like spaces. That would open a new program: certified inverse geometry in Lean, with tropical methods as the organizing principle.

Be bold: turn boundary distance matrices into a bulk reconstruction machine.

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
