## Assignment: 3. Full Discrete Honeycomb Theorem on the Hex Lattice

**Mode:** `prove`

Prove a genuinely new discrete isoperimetric theorem on the hexagonal cell lattice, with a formalization path ambitious enough to open a reusable Lean theory of planar lattice isoperimetry.

### Research Direction

The target is the full **discrete honeycomb theorem** for finite connected unions of hexagonal cells: among all connected regions with a fixed number of cells, the minimizers of edge boundary are the canonical “round” hex patches, equivalently initial segments of the hex graph in the hex-distance metric up to the necessary residue-class effects when the cell count is not exactly hexagonal.

This is not an incremental extremal-combinatorics exercise. A formal proof would create a new bridge between:

- discrete differential geometry,
- edge-isoperimetric inequalities on vertex-transitive graphs,
- crystallization / Wulff-shape phenomena in statistical mechanics,
- and certified combinatorial optimization inside Lean.

The conceptual breakthrough is to isolate the **hexagonal Wulff shape** as the exact optimizer in a purely combinatorial setting and make that statement machine-checkable.

---

## Precise Theorem Targets

You should formulate the theorem at two levels: an exact-radius theorem for perfect hex patches, and a general cardinality theorem for arbitrary `n`.

### Target A: exact optimality at hex numbers

Let `HexPatch r` denote the regular radius-`r` hexagonal patch of cells, with
\[
|HexPatch(r)| = 1 + 3r(r+1), \qquad |\partial_E HexPatch(r)| = 6(r+1)
\]
if boundary means exposed cell-edges, or equivalently `12r + 6` if your current formalization counts oriented/perimeter edge units in the doubled convention. Preserve whichever convention is already in the catalog, but state it explicitly.

**Mathematical statement:**

For every finite connected set `S` of hexagonal cells,
if `|S| = 1 + 3r(r+1)`, then
\[
|\partial_E S| \ge |\partial_E HexPatch(r)|,
\]
with equality iff `S` is a translate of `HexPatch(r)` (and possibly also a lattice symmetry image, depending on representation).

### Lean-oriented type signature sketch

You will need to adapt this to the actual hex-lattice definitions, but the theorem should look structurally like:

```lean
theorem hex_patch_edge_boundary_minimal_at_hex_number
  (r : ℕ) (S : Finset HexCell)
  (hconn : HexConnected S)
  (hcard : S.card = 1 + 3 * r * (r + 1)) :
  edgeBoundaryCard S ≥ edgeBoundaryCard (hexPatch r)
```

and the rigidity theorem:

```lean
theorem hex_patch_edge_boundary_eq_iff
  (r : ℕ) (S : Finset HexCell)
  (hconn : HexConnected S)
  (hcard : S.card = 1 + 3 * r * (r + 1)) :
  edgeBoundaryCard S = edgeBoundaryCard (hexPatch r) ↔
    IsHexPatchUpToSymmetry S r
```

If full equality classification is too expensive for the first pass, prove the inequality first and isolate rigidity as a second theorem.

---

### Target B: full discrete honeycomb theorem for arbitrary `n`

For arbitrary finite connected `S`, define `HexMinBoundary n` as the minimum edge-boundary cardinality among connected cell sets of cardinality `n`. Then prove that the minimizers are the canonical “centered hex patch plus a shortest outer shell prefix” configurations.

This is the true field-opening theorem.

**Mathematical statement:**

For every `n ≥ 1`, there exists a canonical near-hexagonal region `OptimalHexRegion n` such that for every finite connected cell set `S` with `|S| = n`,
\[
|\partial_E S| \ge |\partial_E OptimalHexRegion(n)|.
\]

If exact classification is tractable, characterize all minimizers as shell-initial segments up to translation and dihedral symmetry.

### Lean-oriented type signature sketch

```lean
def HexOptimalRegion (n : ℕ) : Finset HexCell := ...

theorem discrete_honeycomb_hex_lattice
  (n : ℕ) (hn : 0 < n) (S : Finset HexCell)
  (hconn : HexConnected S)
  (hcard : S.card = n) :
  edgeBoundaryCard S ≥ edgeBoundaryCard (HexOptimalRegion n)
```

A sharper formulation packages the extremal function:

```lean
def hexEdgeIsoProfile (n : ℕ) : ℕ :=
  sInf {m | ∃ S : Finset HexCell, HexConnected S ∧ S.card = n ∧ edgeBoundaryCard S = m}

theorem hexEdgeIsoProfile_realized_by_canonical_region
  (n : ℕ) (hn : 0 < n) :
  edgeBoundaryCard (HexOptimalRegion n) = hexEdgeIsoProfile n
```

---

## Most Promising Intermediate Theorem

If the full theorem is too large for one cycle, the right nontrivial stepping stone is:

### Target C: convex discrete honeycomb theorem

Define a robust notion of hex-convexity, for example via cube coordinates `(x,y,z) ∈ ℤ^3` with `x+y+z=0`, where convexity means intersection with every lattice geodesic segment or equivalently interval-convexity in the three coordinate directions.

Then prove:

```lean
theorem hex_patch_minimizes_boundary_among_convex
  (r : ℕ) (S : Finset HexCell)
  (hconv : HexConvex S)
  (hcard : S.card = 1 + 3 * r * (r + 1)) :
  edgeBoundaryCard S ≥ edgeBoundaryCard (hexPatch r)
```

and ideally the arbitrary-size convex version:

```lean
theorem canonical_convex_hex_region_isoperimetric
  (n : ℕ) (hn : 0 < n) (S : Finset HexCell)
  (hconv : HexConvex S)
  (hcard : S.card = n) :
  edgeBoundaryCard S ≥ edgeBoundaryCard (HexOptimalConvexRegion n)
```

This theorem is already mathematically meaningful: it identifies the Wulff shape in the convex subclass and gives a formal route toward full compression arguments.

---

## Proof Architecture: 3 Viable Strategies

## Strategy A: Shell-compression / discrete Steiner symmetrization on cube coordinates
**Most promising for Lean.**

Represent cells in cube coordinates:
\[
HexCell \cong \{(x,y,z)\in \mathbb Z^3 : x+y+z=0\}.
\]
A regular hex patch is then the `L∞` ball:
\[
\max(|x|,|y|,|z|)\le r.
\]

### Steps
1. **Directional interval compression**
   - For each of the three coordinate directions, define a compression that replaces each fiber by a centered interval of the same cardinality.
   - Show compression preserves cardinality and does not increase edge boundary.

2. **Iterate compressions to canonical form**
   - Prove repeated compression terminates in a set convex in all three directions.
   - Show the resulting fully compressed set is exactly a canonical near-hexagonal region.

3. **Compute boundary of the canonical region**
   - Use your existing exact formulas for `hexPatch r` (`12r + 6` or equivalent convention) and extend them to incomplete outer shells.
   - Deduce optimality.

### Why this is promising
This approach is structurally similar to classical compression proofs in edge-isoperimetry, but much more compatible with finite combinatorics in Lean than importing a heavy general theorem on vertex-transitive graphs. It converts the global minimization problem into a sequence of local monotonicity lemmas on fibers.

---

## Strategy B: Layering by hex distance + additive combinatorics on shells
**Best if existing formalization already has radius/shell machinery.**

Let `B_r` be the radius-`r` patch and decompose any connected set by distance layers from a chosen center or from its own hex-convex hull.

### Steps
1. **Lower bound via shell growth**
   - Show that if a set reaches radius `r`, then it must pay at least the boundary cost of a partially filled shell around `B_{r-1}`.
   - Derive a recurrence for boundary in terms of cells added to shell `r`.

2. **Optimal shell filling order**
   - Prove that among all ways to place `k` cells in shell `r`, the boundary is minimized by a contiguous arc arrangement; globally, shell prefixes around a centered hexagon are optimal.
   - This is the discrete analogue of minimizing anisotropic surface energy.

3. **Summation and exact profile**
   - Express `n = 1 + 3r(r+1) + k` with `0 ≤ k < 6(r+1)`.
   - Prove the exact boundary formula for `HexOptimalRegion n`.

### Why this matters
This route naturally yields an explicit extremal profile `hexEdgeIsoProfile n`, not just existence of minimizers. It is especially attractive if current files already define shells and monotonicity of the isoperimetric ratio.

---

## Strategy C: Reduction to a general edge-isoperimetric theorem on Cayley graphs
**Most conceptually grand, but highest risk.**

The hex cell adjacency graph is a Cayley graph of the Eisenstein integer lattice modulo coordinate presentation. One could aim to prove a reusable theorem:

> For certain finitely generated abelian groups with centrally symmetric generating sets, the edge-isoperimetric minimizers are lattice zonotopes / Wulff shapes determined by the generating set.

### Steps
1. Formalize the hex lattice as a Cayley graph of the rank-2 root lattice `A₂`.
2. Define the anisotropic perimeter norm dual to the generating set.
3. Prove that finite-set minimizers are discrete Wulff shapes, then specialize to the hex case.

### Why this is revolutionary
If successful, this would not merely solve the hex theorem; it would create a formal theory of discrete Wulff inequalities for abelian Cayley graphs. But it is likely too large for the current cycle unless the graph-theoretic infrastructure is already mature.

---

## Recommended Route

Prioritize **Strategy A**, with **Target C** as a serious intermediate theorem and **Target A** as the first exact breakthrough milestone. Then push to **Target B** if compression machinery becomes stable.

Suggested order:

1. formalize cube-coordinate model and equivalence with existing hex-cell definitions,
2. prove compression lemmas,
3. prove convex/canonical minimization,
4. derive exact optimality at hex numbers,
5. extend to arbitrary `n` via partial-shell canonical regions.

---

## Building on Existing Verified Results

The listed catalog theorems are not directly in the hex-lattice domain, but they still suggest reusable formal patterns:

- `bounded_berggren_orbit_in_lattice` shows the codebase already handles nontrivial lattice dynamics in `ℤ`-indexed coordinates. Reuse its style for defining lattice-constrained subsets and boundedness arguments.
- `tropMV_one_sided_bound` and `tropical_lattice_det_bound` indicate existing infrastructure for monotonic inequalities over lattice-like combinatorial structures. The proof style for one-sided extremal bounds may transfer well to compression monotonicity.
- The cryptographic/lattice files suggest that integer-coordinate encodings and finite combinatorial counting over lattice objects are already acceptable in the repository. Lean into that style rather than introducing heavy geometry APIs too early.

More importantly, build on the **already verified hex patch facts** mentioned in the assignment:
- exact boundary formula for regular hex patches,
- monotonic decrease of the isoperimetric ratio.

Those theorems should become your calibration lemmas and endpoint checks for the compression/shell machinery.

---

## Key Definitions to Introduce Cleanly

You will likely need the following objects, each with a computable `Finset` formulation:

```lean
structure CubeCoord where
  x : ℤ
  y : ℤ
  z : ℤ
  hsum : x + y + z = 0
```

```lean
def hexAdj (a b : CubeCoord) : Prop := ...
def edgeBoundary (S : Finset CubeCoord) : Finset BoundaryEdge := ...
def edgeBoundaryCard (S : Finset CubeCoord) : ℕ := ...
def hexPatch (r : ℕ) : Finset CubeCoord := ...
def HexConnected (S : Finset CubeCoord) : Prop := ...
def HexConvex (S : Finset CubeCoord) : Prop := ...
def compressX (S : Finset CubeCoord) : Finset CubeCoord := ...
def compressY ...
def compressZ ...
```

The crucial invariant is that `hexPatch r` should be definable as the cube-coordinate `L∞` ball, because then regularity and shell decomposition become transparent.

---

## Important Lemmas to Target Before the Main Theorem

1. **Boundary under one-step cell addition/removal**
```lean
theorem edgeBoundaryCard_insert_formula ...
theorem edgeBoundaryCard_erase_formula ...
```

2. **Compression preserves size**
```lean
theorem compressX_card (S : Finset HexCell) :
  (compressX S).card = S.card
```

3. **Compression does not increase boundary**
```lean
theorem compressX_boundary_mono (S : Finset HexCell) :
  edgeBoundaryCard (compressX S) ≤ edgeBoundaryCard S
```

4. **Triple-compressed sets are hex-convex/canonical**
```lean
theorem fully_compressed_is_hex_convex ...
theorem fully_compressed_classification ...
```

5. **Canonical convex sets are shell prefixes**
```lean
theorem hex_convex_card_boundary_classification ...
```

6. **Hex-number exact minimizer**
```lean
theorem hex_number_boundary_lower_bound ...
```

These lemmas are not bureaucratic scaffolding; they are the true engine of the theorem.

---

## Cross-Domain Connections

This project has unusual reach. Make those connections explicit in the formalization notes and theorem naming.

### 1. Statistical mechanics / Wulff shapes
The theorem is a zero-temperature surface-energy minimization principle on the `A₂` lattice. The regular hexagon emerges as the discrete Wulff crystal for isotropic nearest-neighbor energy on the triangular/hex dual pair.

### 2. Geometric group theory
The cell graph is a Cayley graph of the root lattice `A₂`. The theorem identifies exact finite-set isoperimetric minimizers in that graph, linking combinatorial boundary to word metrics and growth balls.

### 3. Additive combinatorics
Compression arguments place the theorem in the lineage of Harper, Bernstein, Bezrukov, and discrete rearrangement inequalities. A successful formalization could seed a general Lean library for edge-isoperimetric inequalities.

### 4. Materials science / crystallization
This is the combinatorial analogue of why honeycomb and hexagonal crystal grains appear in nature: minimizing interface energy under lattice anisotropy.

### 5. Theoretical computer science
A certified exact isoperimetric profile on the hex lattice could inform separator bounds, cellular automata growth models, and optimal region design in hex-grid algorithms.

---

## Revolutionary Significance

If you prove the full theorem, you will have formalized one of the cleanest possible instances of a **discrete variational principle selecting a crystal shape**. That opens a program, not just a file:

- formal Wulff constructions on lattices,
- isoperimetric profiles of Cayley graphs,
- discrete curvature flows via boundary-reducing compressions,
- and machine-verified crystallization arguments.

This is exactly the kind of result that makes a mathematician stop and say: *Lean is no longer just checking proofs; it is organizing a new science of exact discrete geometry.*

---

## Application Keywords

`discrete isoperimetry`, `hex lattice`, `honeycomb theorem`, `Wulff shape`, `edge boundary minimization`, `A₂ root lattice`, `Cayley graph`, `compression method`, `discrete convexity`, `crystallization`, `statistical mechanics`, `geometric combinatorics`, `formalized extremal geometry`, `anisotropic perimeter`, `shell growth`

---

## Deliverables

1. Formalize the main theorem at least at the **hex-number exact optimality** level.
2. If full arbitrary-`n` optimality is not completed, prove the **convex** version plus enough compression lemmas to make the general route unmistakable.
3. Minimize `sorry` aggressively; isolate any remaining gap to one or two sharply stated compression/classification lemmas.
4. Include theorem statements in Lean 4 with the actual repository types and file paths you use.

---

## Mandatory FUTURE_DIRECTIONS.md

Produce a structured `FUTURE_DIRECTIONS.md` with **3–5 concrete next steps** at breakthrough level. These must be specific, not generic. Strong candidates include:

1. exact edge-isoperimetric profile of the triangular lattice and transfer by planar duality,
2. a general discrete Wulff theorem for finitely generated abelian Cayley graphs,
3. stability theorem: sets with near-minimal boundary are close to hex patches in symmetric-difference distance,
4. anisotropic variant with weighted edge directions yielding distorted hexagonal minimizers,
5. hex-lattice mean-curvature flow by iterative boundary-reducing local moves.

Make the document visionary but executable.

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

Research domain: Cryptography
Research mode: prove
