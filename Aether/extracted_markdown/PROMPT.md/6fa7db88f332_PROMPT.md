## Assignment: Kleene star update

Mode: **prove**

Aristotle, do not treat this as a routine graph lemma. Treat it as a tropical Woodbury/Sherman–Morrison theorem for min-plus linear algebra. The target is a **surgery formula for all-pairs shortest paths**: when a weighted directed graph is modified by a low-rank tropical update (adding or changing one edge, or one two-step hub), its Kleene star should be expressible *exactly* from the old star and the surgery parameters. If formalized cleanly in Lean, this opens a program of **certified dynamic shortest-path algebra**, tropical control, and low-rank update theory in idempotent semirings.

The catalog theorems listed are not directly about graph closure, but they certify that the project should aggressively exploit tropical algebra identities (`max_self`, distributivity analogues, boolean/tropical correspondences). Use them as stylistic and algebraic precedents for min/max rewrites and semiring reasoning.

### Core breakthrough target

Let `A : Matrix (Fin n) (Fin n) ℝ∞` be the weighted adjacency matrix of a directed graph in the min-plus semiring (`ℝ∞` with addition as multiplication and infimum/min as addition). Let `A⋆` denote its tropical Kleene star, interpreted entrywise as all-pairs shortest path cost when no negative cycle is reachable. Let a surgery add a single edge `u → v` of weight `w`. Then the new adjacency matrix is
`A' = A ⊕ E(u,v,w)`,
where `E(u,v,w)` has entry `w` at `(u,v)` and `∞` elsewhere.

The theorem to aim for is the exact rank-one tropical update:
\[
(A')^\star_{ij}
=
\min\Big( A^\star_{ij},\; A^\star_{iu} + w + A^\star_{vj} \Big)
\]
for all vertices `i,j`, under a hypothesis excluding creation of a negative cycle through the new edge, namely
\[
0 \le w + A^\star_{vu}.
\]
More conceptually:
\[
(A \oplus E(u,v,w))^\star
=
A^\star \oplus \big( \mathrm{col}_u(A^\star) \otimes w \otimes \mathrm{row}_v(A^\star) \big),
\]
where the outer product is tropical.

This is not just an APSP fact: it is the tropical analogue of a resolvent identity. If done well, it becomes the foundational lemma for dynamic graph algorithms in proof assistants and a bridge to tropical linear systems, automata, and control.

---

## Precise theorem statements to formalize

Work with `ENNReal` or `WithTop ℝ` if `ℝ∞` infrastructure is smoother in Mathlib; if you can support `ℝ∞ = EReal` cleanly, even better. The key is to have a min-plus semiring-like setting with `∞` and finite path lengths. If necessary, define the closure by a finite `Fin n` path infimum rather than relying on an existing Kleene-star typeclass.

### Theorem 1: single-edge surgery update for APSP closure

Suggested Lean-facing statement skeleton:

```lean
theorem kleene_star_single_edge_update
    {n : ℕ} [Fact (0 < n)]
    (A S : Matrix (Fin n) (Fin n) ENNReal)
    (hS : IsAPSPClosure A S)
    (u v : Fin n) (w : ENNReal)
    (hNoNegCycle : 1 ≤ (w + S v u)) :
    IsAPSPClosure (fun i j => min (A i j) (if i = u ∧ j = v then w else ⊤))
      (fun i j => min (S i j) (S i u + w + S v j))
```

This type signature is intentionally schematic: you may want a dedicated `edgeUpdate A u v w` definition instead of the raw lambda. Also, in `ENNReal`, the “no negative cycle” condition is automatic/non-problematic because there are no negative weights; then the theorem becomes unconditional. If you instead work in `WithTop ℝ`, use a more meaningful hypothesis:

```lean
theorem kleene_star_single_edge_update_real
    {n : ℕ} [Fact (0 < n)]
    (A S : Matrix (Fin n) (Fin n) (WithTop ℝ))
    (hS : IsAPSPClosure A S)
    (u v : Fin n) (w : ℝ)
    (hCycle : (0 : ℝ) ≤ w + Option.getD (S v u) 0) :
    IsAPSPClosure (edgeUpdate A u v w)
      (fun i j => min (S i j) (S i u + w + S v j))
```

If `IsAPSPClosure` does not exist, define it:

```lean
def IsAPSPClosure {n : ℕ} (A S : Matrix (Fin n) (Fin n) ENNReal) : Prop :=
  (∀ i j, A i j ≤ S i j) ∧
  (∀ i, 1 ≤ S i i) ∧
  (∀ i j k, S i k + S k j ≤ S i j) ∧
  ∀ T, (∀ i j, A i j ≤ T i j) →
       (∀ i, 1 ≤ T i i) →
       (∀ i j k, T i k + T k j ≤ T i j) →
       ∀ i j, S i j ≤ T i j
```

This encodes the least reflexive-transitive tropical closure. Adjust `1`/`0` depending on your semiring encoding conventions.

### Theorem 2: exact entrywise formula

This is often easier to prove first and then package as closure:

```lean
theorem apsp_single_edge_update_eq_min
    {n : ℕ} [Fact (0 < n)]
    (A : Matrix (Fin n) (Fin n) ENNReal)
    (u v : Fin n) (w : ENNReal) :
    apsp (edgeUpdate A u v w)
      = fun i j => min (apsp A i j) (apsp A i u + w + apsp A v j)
```

For `ENNReal`, this is a genuinely clean theorem and already nontrivial. It says every shortest path in the updated graph either avoids the new edge or uses it once; because weights are nonnegative, repeated use cannot improve the path.

### Theorem 3: two-sided low-rank surgery / hub insertion

Push beyond one edge. Let surgery connect a new “hub” pattern through vectors `p,q`:
\[
A'_{ij} = \min(A_{ij},\, p_i + q_j).
\]
Then conjecturally
\[
(A')^\star_{ij}
=
\min\big(A^\star_{ij},\, (A^\star p)_i + (q A^\star)_j,\,
(A^\star p)_i + \delta^\star + (q A^\star)_j\big),
\]
with the middle simplifiable depending on whether a scalar feedback term
\[
\delta = q A^\star p
\]
is non-improving (`0 ≤ δ`). In the nonnegative setting this may collapse to the rank-one formula
\[
(A')^\star = A^\star \oplus (A^\star p)\otimes(q A^\star).
\]

Suggested Lean target:

```lean
theorem kleene_star_rank_one_update
    {n : ℕ} [Fact (0 < n)]
    (A : Matrix (Fin n) (Fin n) ENNReal)
    (p q : Fin n → ENNReal) :
    apsp (rankOneUpdate A p q)
      = fun i j => min (apsp A i j) ((minPlusMulVec (apsp A) p i) + (minPlusVecMul q (apsp A) j))
```

Even proving a clean inequality in each direction would already be significant.

---

## Definitions you may need

Use concrete, finite definitions. Avoid abstract Kleene algebra unless Mathlib support is unexpectedly mature.

1. `edgeUpdate : Matrix (Fin n) (Fin n) α → Fin n → Fin n → α → Matrix ...`
2. `PathWeight` for a list/vector of vertices.
3. `apsp : Matrix (Fin n) (Fin n) ENNReal → Matrix (Fin n) (Fin n) ENNReal`
   defined as infimum over path weights, or via Floyd–Warshall recurrence.
4. `IsAPSPClosure` as least reflexive transitive majorant in min-plus form.
5. Optional:
   - `rankOneUpdate`
   - `minPlusMulVec`, `minPlusVecMul`
   - `outerTrop`

If path-infimum over arbitrary lists is painful, use the **finite-vertex simple-path bound**: in a graph on `n` vertices with nonnegative weights, shortest paths can be taken with length at most `n-1`. Then define APSP via minimum over `Finset` of paths of bounded length, or use Floyd–Warshall dynamic programming over `Fin n`.

---

## Why this is a breakthrough

A formal theorem of this shape would be one of the first **certified dynamic tropical linear algebra identities** in Lean:

- It turns APSP recomputation into an exact symbolic update law.
- It is the min-plus analogue of matrix inverse low-rank updates.
- It opens a path to formally verified dynamic graph algorithms with proof-producing updates.
- It creates a bridge between graph theory, automata/Kleene algebra, and tropical geometry.
- It enables certified reasoning about network intervention, routing, and control under local perturbations.

This is not “another shortest path theorem.” It is a **structural law for surgery in idempotent mathematics**.

---

## Proof strategy architecture

### Strategy A: shortest-path decomposition by first use of the new edge
Most promising for a first Lean proof.

1. **Upper bound construction**  
   Show that any old shortest path from `i` to `j` is still available after update, giving
   `apsp A' i j ≤ apsp A i j`.
   Also concatenate an old shortest path `i → u`, the new edge `u → v` of weight `w`, and an old shortest path `v → j` to obtain
   `apsp A' i j ≤ apsp A i u + w + apsp A v j`.
   Hence
   \[
   apsp(A')_{ij} \le \min( apsp(A)_{ij}, apsp(A)_{iu}+w+apsp(A)_{vj}).
   \]

2. **Lower bound by path normal form**  
   Take any path in the updated graph from `i` to `j`.
   - If it does not use the new edge, its weight is at least `apsp A i j`.
   - If it uses the new edge, let the first occurrence split the path into prefix, the edge, and suffix. Replace prefix/suffix by optimal old-graph costs to get lower bound
     `apsp A i u + w + apsp A v j`.
   Therefore every updated path has weight at least the claimed minimum.

3. **Single-use reduction**  
   In `ENNReal` or nonnegative weights, repeated uses of the new edge cannot help; any path using it multiple times can be reduced to one use or bounded below by one-use cost. This is where the theorem becomes especially clean.  
   This strategy is likely the most Lean-friendly because it avoids abstract star algebra.

Why best: it uses finite combinatorics, explicit witnesses, and bounded path lengths. It is robust against library gaps.

---

### Strategy B: Floyd–Warshall surgery recurrence
Best if you want a highly algorithmic theorem and executable extraction.

1. Define `FW k A i j` = shortest path from `i` to `j` using intermediate vertices from the first `k`.
2. Show the standard recurrence:
   \[
   FW(k+1,i,j)=\min(FW(k,i,j), FW(k,i,k)+FW(k,k,j)).
   \]
3. Analyze the effect of inserting one edge `u→v,w` on this recurrence and prove by induction on `k` that the updated dynamic table is exactly
   \[
   \min(FW_k(A,i,j), FW_k(A,i,u)+w+FW_k(A,v,j)).
   \]
4. Pass to `k=n`.

Why valuable: gives an executable certified dynamic APSP algorithm, not just an existence theorem. This could later support code generation.

---

### Strategy C: tropical resolvent / closure algebra
Most conceptually powerful, but only pursue if the concrete proof is secure.

1. Formalize closure axioms:
   \[
   A^\star = I \oplus A A^\star = I \oplus A^\star A.
   \]
2. Let `B = E(u,v,w)` or more generally `B = p ⊗ q`. Show
   \[
   (A \oplus B)^\star = A^\star (B A^\star)^\star
   \]
   in an appropriate idempotent-semiring setting.
3. Compute `(B A^\star)^\star` explicitly for rank one. Under the no-improving-cycle condition, the scalar feedback collapses and yields the exact outer-product formula.

Why revolutionary: this becomes a reusable theorem for all tropical low-rank perturbations, not just graphs. But it may require more algebraic infrastructure than the current library supports.

---

## Concrete Lean engineering plan

1. **Choose the ambient type carefully**
   - If you want the cleanest first theorem: use `ENNReal` and nonnegative weights.
   - If you want maximal mathematical depth: use `WithTop ℝ`, but expect more bookkeeping around finite/infinite values and no-negative-cycle hypotheses.

2. **Start with an entrywise theorem**
   Prove `apsp_single_edge_update_eq_min` before abstract closure characterizations.

3. **Use bounded-length paths**
   Since vertices are `Fin n`, define path candidates of length at most `n`. This avoids arbitrary infimum over all lists and makes `Finset.inf'` possible.

4. **Package algebraic corollaries**
   Once the entrywise formula is proven, derive:
   - monotonicity under edge insertion,
   - idempotence of repeated identical surgery,
   - commutation criteria for disjoint surgeries.

---

## Cross-domain connections to exploit

1. **Dynamic algorithms / verified complexity**
   This theorem is a proof assistant analogue of dynamic shortest path update formulas. It suggests certified incremental routing and reactive planning.

2. **Control theory / discrete event systems**
   Min-plus linear systems model scheduling and synchronization. A rank-one closure update corresponds to adding a resource channel or timing constraint. Your theorem becomes a certified controller reconfiguration law.

3. **Automata and weighted languages**
   Kleene star is literally closure in automata. Edge surgery corresponds to adding a transition. The theorem predicts exact update of weighted reachability semantics.

4. **Tropical geometry / low-rank perturbation**
   The formula is a tropical analogue of low-rank resolvent identities and should interact with tropical convexity: the updated distance matrix lies in a tropical segment between the old closure and a rank-one tropical outer product.

5. **Network science / intervention**
   In transportation or communication networks, the theorem gives exact symbolic effect of adding a link. This is a mathematically rigorous intervention calculus.

---

## Build on catalog theorems intelligently

The listed theorems are not directly APSP lemmas, but they suggest useful algebraic patterns:

- `tropical_mirror_theorem` (`max a a = a`) is the max-plus analogue of idempotence; mirror this with `min a a = a` rewrites in your closure algebra.
- `tropical_and_distributes` signals that tropical operations should be normalized aggressively; create local lemmas for `min`/`+` distributive manipulations.
- `bool_and_as_tropical_max` hints at a boolean-to-tropical bridge. You can derive a special case: when weights are `0/∞`, your theorem specializes to transitive closure under insertion of one boolean edge.
- `tropical_and_bound` suggests proving monotonicity/bounds as helper lemmas first.

Do not force these theorems into the proof; instead, use them as precedent for a **tropical-normal-form proof style**.

---

## Strong secondary targets

If the main theorem lands, immediately pursue one or two of these:

### Corollary A: boolean transitive closure update
For adjacency matrices over `{false,true}` encoded tropically, adding edge `u→v` updates reachability by
\[
R'_{ij} = R_{ij} \lor (R_{iu}\land R_{vj}).
\]
This is the boolean shadow of the weighted theorem.

Lean sketch:
```lean
theorem transitive_closure_single_edge_update
    {n : ℕ} [Fact (0 < n)]
    (R : Matrix (Fin n) (Fin n) Bool)
    (u v : Fin n) :
    tc (boolEdgeUpdate R u v)
      = fun i j => tc R i j || (tc R i u && tc R v j)
```

### Corollary B: commutation of independent surgeries
If two added edges cannot form an improving cycle through each other, then closure after both surgeries is independent of order.

### Corollary C: sensitivity / Lipschitz monotonicity
If the added edge weight changes from `w₁` to `w₂`, derive an entrywise monotone comparison of closures. This would be a certified parametric sensitivity theorem.

---

## Minimal viable file/package structure

Create something like:

- `Tropical/Graphs/APSP.lean`
- `Tropical/Graphs/KleeneStarUpdate.lean`
- `Tropical/Graphs/BooleanClosureBridge.lean`

Possible theorem names:

- `apsp_single_edge_update_eq_min`
- `kleene_star_single_edge_update`
- `transitive_closure_single_edge_update`
- `apsp_edge_update_mono`
- `apsp_double_edge_update_comm_of_acyclic_feedback`

---

## What to write in Lean

Prioritize definitions and lemmas that will survive future generalization:

```lean
def edgeUpdate {n : ℕ} (A : Matrix (Fin n) (Fin n) ENNReal)
    (u v : Fin n) (w : ENNReal) : Matrix (Fin n) (Fin n) ENNReal :=
  fun i j => min (A i j) (if i = u ∧ j = v then w else ⊤)

def rankOneUpdate {n : ℕ} (A : Matrix (Fin n) (Fin n) ENNReal)
    (p q : Fin n → ENNReal) : Matrix (Fin n) (Fin n) ENNReal :=
  fun i j => min (A i j) (p i + q j)
```

Then prove local helper lemmas:

- `edgeUpdate_apply_same`
- `edgeUpdate_apply_ne`
- `min_le_left`, `min_le_right`, `le_min_iff`
- path concatenation weight lemmas
- “first use of updated edge” decomposition

---

## Application keywords

tropical linear algebra, min-plus semiring, Kleene star, all-pairs shortest paths, dynamic graph algorithms, verified routing, low-rank update, Sherman–Morrison analogue, Floyd–Warshall, weighted automata, discrete event systems, tropical control, intervention calculus, transitive closure, certified optimization

---

## Deliverables

1. Lean 4 file(s) with at least one nontrivial theorem fully proved:
   - preferably `apsp_single_edge_update_eq_min` or a closure-form equivalent.
2. Supporting definitions for APSP/closure if absent from Mathlib.
3. At least one cross-domain corollary, ideally boolean transitive closure update.
4. **FUTURE_DIRECTIONS.md** with 3–5 concrete next theorems.

---

## Required FUTURE_DIRECTIONS.md content

Include specific statements and strategies, not vague ideas. At minimum propose 3 of the following:

1. **Rank-one tropical Woodbury theorem**  
   Formalize and prove the general `p ⊗ q` update formula for APSP closure.

2. **Vertex surgery / Schur complement theorem**  
   Add a new vertex with incident edge vectors `p,q` and prove an exact block formula for the enlarged graph closure.

3. **Order-independence of sparse surgeries**  
   Characterize when two edge updates commute at the closure level.

4. **Boolean-weighted bridge**  
   Prove that the weighted update theorem specializes to boolean transitive closure under `0/∞` encoding.

5. **Certified dynamic APSP algorithm**  
   Extract an executable Lean function implementing edge updates in `O(n^2)` from the theorem and prove correctness against full recomputation.

Be ambitious. If you can make the single-edge theorem precise and machine-checked, you are not just updating a graph—you are formalizing the first piece of a tropical perturbation calculus.

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
