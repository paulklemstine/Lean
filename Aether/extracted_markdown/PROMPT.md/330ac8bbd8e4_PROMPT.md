## Assignment: Hyperbolic Crafting: Optimal Nether Portals via Tropical Shortest Paths

Mode: **prove**

You are not being asked for a toy formalization of a game mechanic. You are being asked to extract a mathematically sharp, certifiable tropical-geometric principle from the Minecraft Nether/Overworld correspondence and turn it into a reusable theorem schema about scaled metrics, min-plus path optimization, and spanning structures on paired worlds.

The breakthrough is to formalize the folklore “Nether travel is 8× faster” as a **tropical metric compression law**: a deterministic scaling between two metric spaces induces a min-plus shortest-path problem on a dual-world graph, and the globally optimal portal architecture is characterized by tropical closure and MST optimality. If done correctly, this opens a small but real field: **algorithmic tropical infrastructure design on scaled coupled geometries**.

## Core theorem targets

Work with concrete finite vertex sets of planar coordinates. Use `ℤ × ℤ` or `Fin n → ℤ`-style encodings if convenient, but keep the final statements executable over finite sets.

### Definition layer to introduce

You should define, in Lean, a scaled Nether map and a dual-world cost model. One clean choice:

- Overworld coordinates: `Fin n → ℤ × ℤ`
- Nether coordinates induced by integer scaling by `8`
- Overworld distance: Manhattan metric
- Nether distance: Manhattan metric after compression
- Portal jump cost: either `0` or a fixed constant `c`; start with `0` for the clean theorem, then generalize

A promising concrete definition is:

- `overDist (a b : ℤ × ℤ) : ℤ := |a.1 - b.1| + |a.2 - b.2|`
- `netherCoord (a : ℤ × ℤ) : ℤ × ℤ := (a.1 / 8, a.2 / 8)` or, better for exactness, define the theorem first on coordinates known to be divisible by `8`
- `netherDist a b := overDist (netherCoord a) (netherCoord b)`

For exact scaling, avoid rounding at first. Restrict to the sublattice `8ℤ × 8ℤ`, where the induced Nether metric is literally `1/8` of the Overworld metric.

### Theorem 1: exact tropical scaling on the 8-lattice

This should be your first clean theorem. State it with exact quantifiers and prove it fully.

**Mathematical statement.**  
For all Overworld points `a, b ∈ (8ℤ)^2`, the Manhattan distance between their Nether images is exactly one-eighth of the Overworld Manhattan distance:
\[
d_N(\phi(a),\phi(b)) = \frac{1}{8} d_O(a,b),
\]
where `φ(x,z) = (x/8, z/8)`.

This is the rigorous content of “1:8 is the tropical scaling factor.”

A Lean-oriented signature could be:

```lean
def L1Dist (p q : ℤ × ℤ) : ℤ :=
  Int.natAbs (p.1 - q.1) + Int.natAbs (p.2 - q.2)

def NetherMap (p : ℤ × ℤ) : ℤ × ℤ := (p.1 / 8, p.2 / 8)

def DivBy8Point (p : ℤ × ℤ) : Prop := 8 ∣ p.1 ∧ 8 ∣ p.2

theorem nether_scaling_exact
    (p q : ℤ × ℤ)
    (hp : DivBy8Point p) (hq : DivBy8Point q) :
    L1Dist (NetherMap p) (NetherMap q) * 8 = L1Dist p q
```

If division on `ℤ` becomes annoying, define points directly as Nether coordinates and lift them:
```lean
def LiftOver (p : ℤ × ℤ) : ℤ × ℤ := (8 * p.1, 8 * p.2)

theorem lift_scaling_exact
    (p q : ℤ × ℤ) :
    L1Dist (LiftOver p) (LiftOver q) = 8 * L1Dist p q
```

This second form is likely the best formal entry point.

### Theorem 2: tropical shortest path collapses to Nether-weight minimization

Define a dual-world graph whose vertices are portal sites, with edge weight equal to the minimum of Overworld travel and scaled Nether travel. Then prove that the path semiring is min-plus and that the all-pairs optimal travel matrix is the tropical closure of the edge matrix.

Let
\[
W_{ij} = \min\big(d_O(i,j),\ 8\, d_N(i,j)\big),
\]
or equivalently, if you formulate in Nether units,
\[
W_{ij} = \min\big(d_O(i,j),\ d_O(i,j)\big)
\]
on aligned pairs; more interesting is to include portal-entry penalties:
\[
W_{ij} = \min\big(d_O(i,j),\ c + 8\,d_N(i,j)+c\big).
\]

Then prove the shortest path operator is tropical matrix multiplication, and idempotent closure stabilizes optimal travel costs.

A Lean-facing theorem target:

```lean
def tropicalMul (A B : Matrix (Fin n) (Fin n) ℤ) : Matrix (Fin n) (Fin n) ℤ :=
  fun i k => Finset.inf' Finset.univ ?h (fun j => A i j + B j k)

theorem dual_world_shortest_path_is_tropical
    (W : Matrix (Fin n) (Fin n) ℤ) :
    -- formulate with your chosen closure operator
    IsShortestPathClosure W (tropicalClosure W)
```

If a full closure theorem is too large, prove a finite-step version:
```lean
theorem tropical_two_step_bound
    (W : Matrix (Fin n) (Fin n) ℤ) (i k : Fin n) :
    tropicalMul W W i k =
      Finset.inf' Finset.univ ?h (fun j => W i j + W j k)
```

Then connect to the catalog theorem:

- `tropical_matrix_idempotent` should be used as the certified algebraic backbone showing that once your cost matrix is tropically closed, recomposition adds no new information. This is exactly the statement that the portal network’s optimal travel geometry is stable under route concatenation.

### Theorem 3: optimal portal backbone is an MST of the compressed metric

This is the most ambitious and most conceptually important theorem. For a finite set of settlements `S`, define the complete graph weighted by Nether-compressed travel cost:
\[
w(i,j) = d_N(\phi(i),\phi(j))
\]
or, if staying entirely Overworld-side,
\[
w(i,j) = \frac{1}{8} d_O(i,j)
\]
on the lifted lattice.

Then prove:

> Among all connected portal networks on `S`, any minimum spanning tree minimizes total infrastructure cost, and because tropical addition is `min`, this tree is the canonical tropical backbone of the dual-world travel system.

A Lean theorem signature could be:

```lean
theorem portal_network_mst_optimal
    (w : Fin n → Fin n → ℕ)
    (hw_symm : Symmetric w)
    (hw_zero : ∀ i, w i i = 0) :
    IsMST w T → ∀ T', IsSpanningTree T' → totalWeight w T ≤ totalWeight w T'
```

If a full graph-theoretic MST development in current files is too costly, prove a weaker but still meaningful theorem:

```lean
theorem star_bound_by_mst
    (w : Fin n → Fin n → ℕ)
    (T : SimpleGraph (Fin n)) :
    IsMST w T →
    totalWeight w T ≤ totalWeight w (starGraph defaultRoot)
```

The conceptual claim is that optimal portal placement is not arbitrary pairwise portal matching: it is a **global infrastructure optimization problem** whose efficient solution is a spanning tree in the compressed metric.

## Why this is a breakthrough

This is not about Minecraft. It is about formalizing a new species of theorem:

- a **scaled metric coupling**
- inducing a **tropical semiring shortest-path geometry**
- whose infrastructure optimum is governed by **MST structure**

That triple connection touches:
- tropical linear algebra,
- metric embeddings,
- combinatorial optimization,
- algorithmic network design.

If formalized cleanly, this becomes a prototype for:
- transportation on multi-layer infrastructures,
- wormhole routing models,
- hierarchical network compression,
- tropical control in multi-scale environments.

The synthetic insight is that “hyperbolic crafting” is a discrete avatar of **travel in a compressed auxiliary geometry**, and tropical methods are the natural language because route composition is additive while route choice is minimization.

## Proof strategy architecture

You must pursue at least 2–3 proof routes in parallel and record which one actually works.

### Strategy A: exact arithmetic on the 8-lattice
Most promising for the first theorem.

1. Define `LiftOver (x,z) = (8x, 8z)`.
2. Prove `L1Dist (LiftOver p) (LiftOver q) = 8 * L1Dist p q` by direct expansion and `Int.natAbs_mul`.
3. Derive the exact scaling theorem for divisible coordinates as a corollary.

Why this is promising: it avoids all subtleties of integer division and rounding and gives a perfectly clean formal theorem with minimal sorry pressure.

### Strategy B: min-plus matrix semantics for route composition
Best for the shortest-path theorem.

1. Define tropical matrix product explicitly using `inf` over intermediate vertices.
2. Show that one-step route costs compose by addition and route selection by `min`.
3. Invoke or adapt `tropical_matrix_idempotent` to show closure stabilizes optimal travel costs.

Why this is promising: the catalog already contains `tropical_matrix_idempotent`, so you are not inventing the algebraic machinery from scratch; you are specializing an existing bridge theorem to a concrete metric-routing model.

### Strategy C: cut-property / exchange proof for MST optimality
Best for the network theorem.

1. Define total network cost over a finite edge set.
2. Use standard cut or cycle exchange arguments to prove any non-MST spanning tree can be improved.
3. Interpret the resulting tree as the tropical portal backbone.

Why this is promising: the mathematics is classical, but the novelty is the interpretation in a scaled tropical geometry. If graph-library support is weak, you can still prove a bespoke finite complete-graph result over `Fin n`.

## How to use the catalog theorems

Do not merely cite them; absorb them into the architecture.

- `tropical_matrix_idempotent`  
  Use this as the formal certificate that once shortest-path costs are tropically closed, further composition does not improve them. In portal language: once the network has been optimized, chaining optimized routes yields no better route than the stored tropical distance matrix.

- `tropical_min_comm`  
  Use in basic rewrites of edge-cost symmetry and in normalizing min-expressions when proving route-choice identities.

- `tropical_min_idem`  
  Use to simplify self-composition and diagonal entries: staying at a portal or considering duplicate route options should collapse immediately.

- `tropical_min_not_injective`  
  This is not a nuisance result; it is a warning and an opportunity. It tells you that tropical minimization forgets information. Leverage this to explain non-uniqueness of optimal portal layouts: distinct raw geometries can induce identical tropical cost profiles.

- `min_factor_le_sqrt`  
  Probably not central, but if you seek a surprising side theorem about factor-balanced rectangular portal grids or search-space pruning for candidate portal placements, this theorem may become useful.

## Cross-domain connections you should explicitly exploit

### 1. Tropical geometry ↔ shortest path algorithms
The Floyd–Warshall recurrence is tropical matrix multiplication. Make this explicit. The portal network is a vivid finite model of tropical linear algebra in action.

### 2. Metric embedding ↔ hyperbolic/scaled auxiliary spaces
Although Minecraft’s Nether is not literally hyperbolic geometry, the mathematical abstraction is a **compressed auxiliary metric layer**. Connect this to multi-scale routing, coarse geometry, and hierarchical metric embeddings.

### 3. Network design ↔ infrastructure science
Interpret the MST theorem as a theorem about cheapest interdimensional infrastructure. This is directly analogous to:
- fiber backbones,
- logistics corridors,
- overlay routing in communication networks.

### 4. Semiring optimization ↔ dynamic programming
The min-plus semiring is the algebraic heart of dynamic programming. Position your shortest-path theorem as a semiring-certified optimization law.

## Concrete theorem variants worth attempting if the main theorem lands

If the exact 8-lattice theorem is done quickly, immediately push to one of these stronger statements:

### Variant A: bounded rounding distortion
For arbitrary integer Overworld coordinates, prove that integer division by `8` introduces only bounded error:
\[
\left| d_O(p,q) - 8\, d_N(\phi(p),\phi(q)) \right| \le C
\]
for an explicit constant `C` (likely small, dimension-dependent).

Possible Lean shape:
```lean
theorem nether_scaling_rounding_error_bound
    (p q : ℤ × ℤ) :
    Int.natAbs ((L1Dist p q : ℤ) - 8 * (L1Dist (NetherMap p) (NetherMap q) : ℤ)) ≤ 14
```

This would be genuinely nontrivial and much closer to the actual game mechanic.

### Variant B: portal-entry penalty phase transition
Introduce a fixed portal activation cost `c`. Prove there is a threshold distance beyond which Nether travel strictly dominates Overworld travel.

```lean
theorem nether_beats_overworld_beyond_threshold
    (c d : ℕ)
    (h : 2 * c < 7 * d) :
    2 * c + d < 8 * d
```

Then package it geometrically in terms of `L1Dist`.

### Variant C: non-uniqueness theorem via tropical collapse
Prove that distinct portal configurations can have the same tropical distance matrix, formalizing infrastructure degeneracy.

This is where `tropical_min_not_injective` becomes conceptually powerful.

## Lean 4 implementation guidance

Use concrete types:
- coordinates as `ℤ × ℤ`
- finite worlds indexed by `Fin n`
- cost matrices as `Matrix (Fin n) (Fin n) ℤ` or `ℕ`

Prefer proving arithmetic scaling lemmas first. Then define graph/cost structures. Then connect to tropical closure.

A practical sequence:

1. Arithmetic file:
   - `L1Dist`
   - `LiftOver`
   - exact scaling lemmas

2. Tropical routing file:
   - cost matrix
   - tropical product
   - two-step shortest-path theorem
   - closure/idempotence theorem

3. Network design file:
   - weighted complete graph on `Fin n`
   - spanning tree cost
   - MST optimality theorem or a strong finite special case

Minimize sorry by isolating graph-theoretic ambitions. If MST infrastructure in Mathlib is awkward, prove a finite bespoke theorem for trees on `Fin n` with edge lists.

## Deliverables

Produce Lean 4 code proving at least one exact theorem fully, ideally `lift_scaling_exact` and one tropical routing theorem. If the full MST theorem is too large, prove a strong finite special case and state the general conjecture precisely.

Also produce `FUTURE_DIRECTIONS.md` with **3–5 concrete, breakthrough-level next steps**, for example:
1. bounded-distortion tropical scaling with rounding,
2. stochastic portal failures and tropical reliability,
3. multi-layer dimension networks and semiring routing,
4. tropical Voronoi regions for portal service areas,
5. categorical semantics of scaled-world transport.

## Application keywords

tropical geometry, min-plus algebra, shortest paths, metric compression, multi-layer routing, minimum spanning tree, semiring optimization, infrastructure design, coarse geometry, algorithmic graph theory, dynamic programming, metric embeddings, portal networks, discrete geometry

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
