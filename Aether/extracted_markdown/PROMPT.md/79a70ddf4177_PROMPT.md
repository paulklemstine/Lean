## Assignment: Idempotent Convergence and Tropical Holography

Prove a genuinely new theorem at the interface of tropical linear algebra, graph shortest-path dynamics, and inverse boundary reconstruction. The right target is not merely “matrix powers stabilize,” but a formal min-plus nilpotence principle that turns path combinatorics into a certified finite closure theorem in Lean, and then uses that closure as the engine for a boundary reconstruction program.

Minimize `sorry`. If a proof naturally decomposes, prove the finite-stabilization theorem first, then the path-realization lemma, then the boundary-distance factorization theorem.

---

## Mode: prove

## Primary Breakthrough Direction
### Idempotent convergence of tropical matrix powers = finite shortest-path closure

Let `W : Matrix (Fin n) (Fin n) ℝ∞` be a min-plus weighted adjacency matrix of a finite directed graph with no negative cycles. Then the tropical powers
`W, W ⊗ W, W ⊗ W ⊗ W, ...`
encode shortest paths with bounded numbers of edges, and the sequence stabilizes after at most `n - 1` steps on off-diagonal entries. The conceptual theorem is that in idempotent linear algebra, acyclic simple-path truncation forces finite convergence of the Kleene process.

This is the discrete idempotent analogue of finite-dimensional nilpotence bounds, but with shortest-path semantics replacing spectral theory.

### Precise theorem statement
For `i ≠ j`, every shortest walk can be reduced to a simple path of length at most `n - 1`; hence the min-plus distance closure is already attained by the `(n-1)`st tropical power truncation. A strong formal target is:

```lean
theorem tropical_power_stabilizes_at_n_sub_one
    {n : ℕ} (hn : 1 ≤ n)
    (W : Matrix (Fin n) (Fin n) ℝ∞)
    (hno_neg_cycle : ∀ (k : ℕ) (hk : 1 ≤ k) (c : Fin k → Fin n),
      (∀ t, c t ≠ c ((t+1) % k)) →
      (∑ t : Fin k, W (c t) (c ((t+1) % k))) ≠ ⊤ →
      0 ≤ ∑ t : Fin k, W (c t) (c ((t+1) % k))) :
    ∀ m : ℕ, n - 1 ≤ m →
      tropical_mat_pow W m = tropical_mat_pow W (n - 1)
```

That full-matrix statement may be too strong without extra diagonal normalization. A more robust and likely formalizable theorem is the entrywise off-diagonal version:

```lean
theorem tropical_power_entry_stabilizes_at_n_sub_one
    {n : ℕ} (hn : 1 ≤ n)
    (W : Matrix (Fin n) (Fin n) ℝ∞)
    (hdiag : ∀ i, W i i = 0)
    (hno_neg_cycle : no_negative_cycle W) :
    ∀ ⦃i j : Fin n⦄, i ≠ j →
    ∀ m : ℕ, n - 1 ≤ m →
      tropical_mat_pow W m i j = tropical_mat_pow W (n - 1) i j
```

An even better theorem, if your library supports bounded Kleene sums, is:

```lean
theorem tropical_kleene_star_finite
    {n : ℕ} (hn : 1 ≤ n)
    (W : Matrix (Fin n) (Fin n) ℝ∞)
    (hdiag : ∀ i, W i i = 0)
    (hno_neg_cycle : no_negative_cycle W) :
    kleene_star_tropical W = tropical_I ⊓
      finset_inf (Finset.range n) (fun k => tropical_mat_pow W k)
```

or equivalently with `min`/`iInf` depending on your API:

```lean
theorem tropical_distance_equals_infimum_first_n_powers
    {n : ℕ}
    (W : Matrix (Fin n) (Fin n) ℝ∞)
    (hdiag : ∀ i, W i i = 0)
    (hno_neg_cycle : no_negative_cycle W) :
    ∀ i j, shortest_path_matrix W i j =
      ⨅ k : Fin n, tropical_mat_pow W k.1 i j
```

If `ℝ∞` is awkward, use `WithTop ℝ` or a custom tropical semiring already present in the catalog. The mathematical content matters more than the exact codomain.

---

## Secondary Breakthrough Direction
### Tropical holography via boundary distance reconstruction

Push beyond closure: use finite tropical convergence to reconstruct hidden graph structure from boundary distance data. The boundary distance matrix is a tropical transfer operator; finite stabilization says all relevant information is encoded by simple paths. This opens a discrete holography program: infer bulk combinatorics from boundary observables.

### Precise theorem target
Let `B ⊆ V` be a designated boundary set, and let `D_B : B × B → ℝ∞` be the shortest-path distance matrix induced by `W`. For a rigid graph class—start with finite directed trees, series-parallel networks, or rank-2 tropical Levi-type graph models—prove injectivity of the boundary distance transform.

A realistic first theorem:

```lean
theorem boundary_distance_determines_weighted_tree
    {n b : ℕ}
    (T₁ T₂ : WeightedBoundaryTree n b)
    (hEq : boundary_distance_matrix T₁ = boundary_distance_matrix T₂) :
    Nonempty (T₁ ≃w T₂)
```

A more tropical-linear version:

```lean
theorem boundary_distance_factorization_unique
    {n b : ℕ}
    (W₁ W₂ : Matrix (Fin n) (Fin n) ℝ∞)
    (B : Fin b ↪ Fin n)
    (hclass₁ : realizable_by_series_parallel_network W₁ B)
    (hclass₂ : realizable_by_series_parallel_network W₂ B)
    (hEq :
      boundary_shortest_path_matrix W₁ B =
      boundary_shortest_path_matrix W₂ B) :
    equivalent_bulk_network W₁ W₂ B
```

This is the right level of ambition: not arbitrary graph reconstruction, but a rigid class where tropical closure and boundary observables plausibly classify the bulk.

---

## Why this is a breakthrough

1. **Idempotent convergence becomes a certified finite algorithmic theorem.**  
   In classical algebra, powers rarely stabilize exactly. In tropical algebra they do for combinatorial reasons, and formalizing that in Lean creates a reusable shortest-path closure engine for all later tropical work.

2. **It turns graph algorithms into theorem-proving infrastructure.**  
   Bellman–Ford/Floyd–Warshall are not just algorithms here; they become finite completeness theorems for idempotent matrix calculus.

3. **It opens a discrete holography program.**  
   Boundary distance data reconstructing bulk structure is a mathematically sharp bridge between inverse problems, tropical geometry, and network science.

4. **It creates a language for tropical transfer matrices in physics and operads.**  
   Stabilized path composition is exactly what transfer-matrix methods and compositional network semantics need.

---

## Lean 4 formalization targets

You should define or reuse:

- `tropical_mat_mul`
- `tropical_mat_pow`
- `shortest_path_matrix`
- `no_negative_cycle`
- `boundary_shortest_path_matrix`
- `WeightedBoundaryTree` or a similarly rigid graph structure
- `equivalent_bulk_network`

If these definitions do not yet exist in Mathlib/catalog form, formalize them minimally and cleanly around `Matrix (Fin n) (Fin n) α` with a min-plus semiring structure.

A practical entry theorem, easier than the final stabilization statement, is:

```lean
theorem tropical_pow_eq_min_weight_paths_of_length_le
    {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ∞) :
    ∀ k i j,
      tropical_mat_pow W k i j =
      ⨅ p : BoundedPath i j k, path_weight W p
```

Then prove simple-path reduction:

```lean
theorem shortest_walk_reduces_to_simple_path
    {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ∞)
    (hno_neg_cycle : no_negative_cycle W) :
    ∀ ⦃i j : Fin n⦄, ∀ p : Walk i j,
      ∃ q : SimplePath i j,
        path_weight W q ≤ path_weight W p
```

Then stabilization follows immediately from `SimplePath.length ≤ n - 1`.

---

## Proof architecture: 3 viable strategies

### Strategy A: Path semantics of tropical powers → simple-path compression
**Most promising.**

1. Prove that `tropical_mat_pow W k i j` equals the infimum of weights of all `i → j` walks using exactly or at most `k` edges.
2. Show that if a walk repeats a vertex, the intervening cycle can be removed without increasing total weight under `no_negative_cycle`.
3. Conclude every minimizing walk has a simple representative of length at most `n - 1`, hence all powers beyond `n - 1` agree.

Why this is best: it is combinatorial, finite, and Lean-friendly. It avoids heavy semiring spectral machinery and uses the native finite-type strength of `Fin n`.

### Strategy B: Tropical Bellman operator and finite fixed-point convergence
1. Define the Bellman update operator `T(x)_j = min_i (x_i + W i j)`.
2. Show monotone iteration from the source indicator computes bounded-edge shortest paths.
3. Use finite-height descent on simple-path support to prove convergence by step `n - 1`.

Why this is strong: it packages the theorem as a fixed-point result and may generalize naturally to dynamic programming and control.

Risk: requires more order-theoretic scaffolding than Strategy A.

### Strategy C: Tropical rank-1 update / Sherman–Morrison analogue
1. Express edge insertion or local modification as a tropical rank-1 perturbation.
2. Show closure updates propagate through finitely many simple-path layers.
3. Deduce stabilization and possibly incremental boundary-distance updates.

Why pursue it: this is the route to dynamic graph algorithms and could yield a second theorem stronger than mere stabilization.

Risk: elegant but probably not the first proof to formalize.

---

## How to build on catalog theorems

Use the verified results not as decoration, but as structural hints:

1. **`tropical_plus_distributes_over_min`**  
   Use this to normalize algebraic rewrites in min-plus matrix multiplication proofs. It is likely the key lemma for reassociating path weights and proving compatibility of concatenation with tropical multiplication.

2. **`reconstruct_from_rank2Levi_profiles_and_edge_moments`** and  
   **`gl3_value_determined_by_boundary_and_levi`**  
   These suggest the catalog already contains a philosophy of reconstruction from lower-dimensional boundary/Levi data. Treat boundary distance matrices as tropical analogues of those profile invariants. If you can show a graph class admits a factorization into rank-2 local pieces, these theorems become conceptual prototypes for uniqueness from restricted observables.

3. **`skip_connection_rank_bound`**  
   This is a hint that tropical rank controls compositional complexity. Use it as motivation for a theorem that stabilized closure has bounded tropical rank on structured graph classes, potentially strengthening the reconstruction theorem by low-rank rigidity.

4. **`tropical_and_bound`**  
   Likely useful as an example of established order/bound manipulation over tropical quantities. Reuse its style for inequalities in shortest-path monotonicity arguments.

---

## Concrete theorem package to aim for

### Theorem 1: Path-realization of tropical powers
```lean
theorem tropical_pow_realizes_bounded_walks
    {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ∞) :
    ∀ k i j,
      tropical_mat_pow W k i j =
      sInf {w | ∃ p : WalkOfLength k i j, path_weight W p = w}
```

### Theorem 2: Simple-path compression under no negative cycles
```lean
theorem walk_compression_no_negative_cycle
    {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ∞)
    (hno_neg_cycle : no_negative_cycle W) :
    ∀ {i j} (p : Walk i j),
      ∃ q : SimplePath i j,
        path_weight W q ≤ path_weight W p
```

### Theorem 3: Stabilization at `n - 1`
```lean
theorem tropical_power_stabilizes
    {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ∞)
    (hdiag : ∀ i, W i i = 0)
    (hno_neg_cycle : no_negative_cycle W) :
    ∀ m ≥ n - 1, tropical_mat_pow W m = tropical_mat_pow W (n - 1)
```

### Theorem 4: Boundary distance rigidity for a rigid graph class
```lean
theorem boundary_distance_reconstruction_series_parallel
    {n b : ℕ}
    (G₁ G₂ : SeriesParallelBoundaryNetwork n b)
    (hEq : boundary_distance_matrix G₁ = boundary_distance_matrix G₂) :
    Nonempty (G₁ ≃b G₂)
```

If Theorem 4 is too ambitious in one cycle, prove instead:

```lean
theorem boundary_distance_complete_invariant_for_weighted_trees
    {n b : ℕ}
    (T₁ T₂ : WeightedBoundaryTree n b)
    (hEq : boundary_distance_matrix T₁ = boundary_distance_matrix T₂) :
    Nonempty (T₁ ≃w T₂)
```

---

## Cross-domain connections to exploit explicitly

- **Tropical linear algebra**: finite Kleene star, min-plus powers, idempotent spectral analogues.
- **Dynamic graph algorithms**: bounded-edge shortest paths, Bellman–Ford convergence, incremental updates.
- **Higher algebra / operads**: path concatenation as compositional multiplication; stabilized closure as universal composite.
- **Statistical physics**: transfer matrices, zero-temperature limits, path partition functions collapsing to minima.
- **Inverse problems / geometry**: boundary rigidity, Dirichlet-to-Neumann style reconstruction, discrete holography.
- **Control theory**: dynamic programming operators over idempotent semirings.
- **Complexity theory**: finite convergence certificates and low-rank tropical structure as compressed witnesses.

These are not rhetorical flourishes. Mention them in theorem docstrings and comments so the resulting Lean development advertises a new research program.

---

## Application keywords

`tropical algebra`, `min-plus semiring`, `Kleene star`, `shortest paths`, `Bellman-Ford`, `Floyd-Warshall`, `boundary rigidity`, `inverse problems`, `graph reconstruction`, `dynamic programming`, `idempotent analysis`, `transfer matrix`, `series-parallel networks`, `weighted trees`, `tropical rank`, `operads`, `network science`, `discrete holography`

---

## Execution order

1. Formalize tropical matrix powers and prove the bounded-walk semantics.
2. Prove cycle deletion/simple-path compression under `no_negative_cycle`.
3. Deduce stabilization at `n - 1`.
4. Define boundary distance matrices.
5. Prove reconstruction for weighted trees or series-parallel networks.
6. If time remains, prove an incremental rank-1 tropical update lemma as the dynamic analogue of Sherman–Morrison.

---

## Deliverables

- Lean file(s) containing the main theorem(s), with as few `sorry` as possible.
- Clear theorem docstrings explaining shortest-path and holographic interpretations.
- A structured `FUTURE_DIRECTIONS.md` with **3–5 concrete breakthrough next steps**, for example:
  1. tropical resolvent / Green’s function formalization,
  2. low-rank boundary rigidity beyond trees,
  3. tropical Schur complement for graph gluing,
  4. idempotent curvature from boundary distance defects,
  5. tropical renormalization via transfer-matrix composition.

Be bold: the goal is to turn a standard shortest-path fact into the foundation of a formal tropical inverse-geometry theory.

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
