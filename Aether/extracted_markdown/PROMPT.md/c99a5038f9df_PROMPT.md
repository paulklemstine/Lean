## Assignment: Extremal Graph Theory Beyond the Classical Frontier — Turán, Removal, Regularity, and Additive Structure

You are not being asked for a routine formalization of textbook extremal combinatorics. You are being asked to carve out a verified extremal-combinatorial bridge between graph theory, additive combinatorics, and algorithmic certification. The classical chain

Turán ⇒ supersaturation ⇒ regularity/removal ⇒ Roth

is one of the great conceptual pipelines in modern mathematics. Formalizing isolated pieces is useful; formalizing a structurally coherent, theorem-driven version that exposes new reusable abstractions in Lean is field-opening.

Your goal is to produce **new, non-trivial theorems and verified algorithms** around this pipeline, using Mathlib aggressively and minimizing sorry. Do not settle for “Turán exists in finite graph folklore.” Build a machine-checked extremal framework that can support future formal proofs of graph limits, property testing, and arithmetic regularity.

## Core Vision

The breakthrough is not merely proving a version of Turán’s theorem. The breakthrough is to formalize an **extremal-energy language** in which:

- clique-freeness is converted into edge upper bounds,
- triangle counts control edit distance from triangle-free structure,
- graph removal becomes an algorithmic certificate,
- additive combinatorics enters via Cayley graphs / 3-AP counting,
- and regularity-style decomposition is represented in Lean in a way that future work can extend to hypergraphs and pseudorandomness.

This opens a verified path toward:
- certified extremal graph algorithms,
- machine-checked additive combinatorics,
- property testing in Lean,
- graphon-inspired asymptotic reasoning,
- and eventually hypergraph removal / Green–Tao style infrastructure.

## Depth Requirements (MANDATORY)

Your output must satisfy ALL of these:

1. **NO trivial proofs**: Do NOT prove statements by `native_decide`, `decide`, `norm_num`, or `rfl` unless the statement itself is genuinely important.
2. **At least 3 theorems with deep proof tactics**: Your file must contain at least 3 theorems proven using induction, `rcases`, `by_contra`, `field_simp`, or multi-step `calc` reasoning.
3. **Novel definitions**: Define at least one new mathematical structure or concept not already in the catalog.
4. **Cross-domain connections**: Include at least one theorem connecting extremal graph theory to another domain.
5. **Conjecture with testable prediction**: State at least one falsifiable conjecture with a clear computational test.

## Research Program

### I. Formalize a sharp finite Turán framework, not just a slogan

Do **not** start with the asymptotic expression `ex(n, K_r) = (1 - 1/(r-1)) n^2 / 2` in informal real notation. In Lean, the right entry point is a finite simple graph on `Fin n`, with edge count as a natural number and a precise upper bound using floor/partition arithmetic.

Define a new structure capturing extremal witnesses:

```lean
structure ExtremalWitness (n r : ℕ) where
  G : SimpleGraph (Fin n)
  cliqueFree : ¬ ∃ s : Finset (Fin n), s.card = r ∧ G.IsClique s
  edgeMaximal :
    ∀ H : SimpleGraph (Fin n),
      (¬ ∃ s : Finset (Fin n), s.card = r ∧ H.IsClique s) →
      H.edgeFinset.card ≤ G.edgeFinset.card
```

If `SimpleGraph.edgeFinset` is unavailable in the exact needed form, define a robust finite edge-count notion yourself using `Sym2 (Fin n)` or an equivalent finite representation. This itself is mathematically valuable infrastructure.

### Target Theorem A: Finite Turán Upper Bound

Prove a precise finite upper bound of the following shape:

```lean
theorem turan_edge_bound
    (r n : ℕ) (hr : 2 ≤ r) :
    ∀ G : SimpleGraph (Fin n),
      (¬ ∃ s : Finset (Fin n), s.card = r ∧ G.IsClique s) →
      2 * G.edgeFinset.card ≤ (1 - 1 / (r - 1 : ℚ)) * n^2
```

This rational-valued statement may need to be reformulated to avoid coercion pain. A better Lean-ready integer formulation is strongly encouraged:

```lean
theorem turan_edge_bound_int
    (r n : ℕ) (hr : 2 ≤ r) :
    ∀ G : SimpleGraph (Fin n),
      (¬ ∃ s : Finset (Fin n), s.card = r ∧ G.IsClique s) →
      (r - 1) * (2 * G.edgeFinset.card) ≤ (r - 2) * n^2
```

This is the real theorem. It avoids division and is exactly the extremal inequality behind Turán.

### Target Theorem B: Exactness for balanced complete multipartite graphs

Define the Turán graph explicitly:

```lean
def turanPartitionClass (r n : ℕ) (i : Fin n) : Fin (r - 1) := ...
def TuranGraph (r n : ℕ) : SimpleGraph (Fin n) := ...
```

Then prove:

```lean
theorem TuranGraph_cliqueFree
    (r n : ℕ) (hr : 2 ≤ r) :
    ¬ ∃ s : Finset (Fin n), s.card = r ∧ (TuranGraph r n).IsClique s
```

and an exact edge-count formula in quotient-remainder form:

```lean
theorem TuranGraph_edge_count
    (r n q t : ℕ)
    (hr : 2 ≤ r)
    (hdecomp : n = (r - 1) * q + t)
    (ht : t < r - 1) :
    2 * (TuranGraph r n).edgeFinset.card
      = (r - 2) * (r - 1) * q^2 + 2 * (r - 2) * t * q + t * (t - 1)
```

Even if you must adjust the exact polynomial, the theorem should be explicit and exact. This is not bookkeeping; it is the certified combinatorial skeleton of extremal graph theory.

### Target Theorem C: Degree-sum / symmetrization lemma as reusable infrastructure

A genuinely important stepping stone is a formalized symmetrization inequality. Define a new notion such as:

```lean
def degreeEnergy {V : Type*} [Fintype V] (G : SimpleGraph V) : ℕ :=
  ∑ v, (G.degree v)^2
```

Then prove a theorem of the form:

```lean
theorem cliqueFree_degree_square_bound
    (r : ℕ) (hr : 2 ≤ r) :
    ∀ G : SimpleGraph (Fin n),
      (¬ ∃ s : Finset (Fin n), s.card = r ∧ G.IsClique s) →
      (∑ v : Fin n, (G.degree v)^2) ≤ (r - 2) * n * G.edgeFinset.card
```

This kind of inequality is deep, nontrivial, and reusable for supersaturation and stability arguments.

## II. Build a triangle-removal interface that is algorithmic, not merely existential

The regularity lemma in full quantitative horror may be too large for one cycle, but the triangle removal principle can still be attacked in a **finite, computationally certified** way. You should define a finite edit distance on graphs.

### Novel definition: graph edit distance

```lean
def edgeEditDistance {V : Type*} [Fintype V] [DecidableEq V]
    (G H : SimpleGraph V) : ℕ :=
  ((G.edgeFinset \ H.edgeFinset).card + (H.edgeFinset \ G.edgeFinset).card)
```

Then define triangle count:

```lean
def triangleCount (G : SimpleGraph V) : ℕ := ...
```

using ordered or unordered triples with a normalization lemma.

### Target Theorem D: Certified triangle destruction by greedy deletion

Prove a finite algorithmic theorem:

```lean
theorem greedy_triangle_removal_certificate
    (G : SimpleGraph V) :
    ∃ H : SimpleGraph V,
      triangleCount H = 0 ∧
      edgeEditDistance G H ≤ triangleCount G
```

This is not the full triangle removal lemma, but it is a powerful verified algorithmic certificate: deleting one edge from each found triangle kills all triangles with cost at most the number of triangles. The proof should be by induction on `triangleCount G`, using explicit edge deletion and strict descent.

This theorem is mathematically meaningful and computationally demonstrable.

### Stronger asymptotic-removal-style theorem (if feasible)

If you can build enough finite density machinery, aim for a quantitative theorem of the form:

```lean
theorem triangle_removal_weak
    (ε : ℚ) (hε : 0 < ε) :
    ∃ δ : ℚ, 0 < δ ∧
    ∀ n : ℕ, ∀ G : SimpleGraph (Fin n),
      triangleCount G ≤ δ * n^3 →
      ∃ H : SimpleGraph (Fin n),
        triangleCount H = 0 ∧
        edgeEditDistance G H ≤ ε * n^2
```

Even a weak explicit `δ(ε)` with bad constants would be a major formal milestone.

## III. Cross-domain theorem: encode 3-term arithmetic progressions as triangles in a graph

This is where the project becomes visionary rather than incremental.

Construct a graph from a subset `A ⊆ Z/NZ` or from a finite interval model so that 3-term arithmetic progressions correspond to triangles in an auxiliary graph. Then prove a precise correspondence theorem.

### Novel definition: additive pattern graph

For a finite abelian group `G`, define a graph whose vertices encode positions or cosets and whose triangles represent solutions to `x + z = 2y`.

A possible Lean-facing structure:

```lean
structure AdditivePatternGraph (α : Type*) [AddCommGroup α] [Fintype α] where
  carrier : Finset α
  graph : SimpleGraph α
  triangle_iff_threeAP :
    ∀ x y z : α,
      x ∈ carrier → y ∈ carrier → z ∈ carrier →
      graph.Adj x y ∧ graph.Adj y z ∧ graph.Adj x z ↔ x + z = y + y
```

You may need a more sophisticated tripartite construction; that is fine and probably better.

### Target Theorem E: 3-AP/triangle correspondence

Prove a theorem of the form:

```lean
theorem threeAP_corresponds_triangle
    (N : ℕ) :
    ∃ T : SimpleGraph (Fin N × Fin 3),
      ∀ A : Finset (Fin N),
      (# three-term APs in A) = triangleCount (inducedSubgraphFromA T A)
```

You may need to replace literal equality by a bounded comparison or by a tripartite graph construction. The exact shape is flexible; the essential requirement is a formally verified bridge from additive combinatorics to graph triangles.

This is revolutionary because it imports Roth-type phenomena into the graph-removal universe in Lean.

## IV. Kruskal–Katona: compressions, shadows, and extremal set systems

Do not attempt the full theorem only as a massive combinatorial endpoint. First define the **shadow** and **compression operators** and prove structural lemmas.

### Novel definition: shadow family

```lean
def lowerShadow {α : Type*} [DecidableEq α] (𝒜 : Finset (Finset α)) : Finset (Finset α) :=
  𝒜.biUnion (fun s => s.powersetCard (s.card - 1))
```

Then define a left-compression operator on uniform families.

### Target Theorem F: compression does not increase shadow

```lean
theorem compression_shadow_monotone
    (𝒜 : Finset (Finset (Fin n))) (k i j : ℕ) :
    uniformFamily 𝒜 k →
    (lowerShadow (compress ij 𝒜)).card ≤ (lowerShadow 𝒜).card
```

Even a restricted version is deep and valuable. This theorem is the engine behind Kruskal–Katona and also creates reusable machinery for extremal set theory in Lean.

### Target Theorem G: initial-segment extremality for a restricted regime

If full Kruskal–Katona is too ambitious, prove a genuinely nontrivial restricted case:

```lean
theorem kruskal_katona_restricted
    (𝒜 : Finset (Finset (Fin n))) :
    uniformFamily 𝒜 2 →
    m = 𝒜.card →
    (lowerShadow 𝒜).card ≥ kkBoundForPairs m
```

A sharp theorem for `k = 2` or `k = 3` is acceptable if proved deeply and cleanly.

## Proof Strategy Architecture

You must pursue at least 2–3 proof paths and explicitly document which one you used and why.

### Strategy A: Zykov-style symmetrization for Turán
1. Define a graph transformation that clones neighborhoods of nonadjacent vertices.
2. Prove it preserves `K_r`-freeness and does not decrease edge count.
3. Iterate to a complete multipartite graph, then optimize part sizes by convexity / smoothing.

Why promising: it matches the true combinatorial geometry of the theorem and yields reusable infrastructure for stability.

### Strategy B: Degree-energy + induction on vertex count
1. Prove a clique-free neighborhood lemma: the neighborhood of any vertex in a `K_r`-free graph is `K_{r-1}`-free.
2. Induct on `r` or `n`, bounding local edge counts in neighborhoods.
3. Sum over vertices and use double counting plus a quadratic inequality.

Why promising: more Lean-friendly than full symmetrization because it decomposes into local finite sums and induction.

### Strategy C: Compression / extremal optimization
1. Formalize graph or family compression operations.
2. Show extremal objects are monotone under compression.
3. Identify canonical extremizers and compute exact counts.

Why promising: this scales from Turán to Kruskal–Katona and creates a unified extremal-method toolkit.

**Recommended route:** Use **Strategy B** for the first fully verified Turán theorem, then add elements of **Strategy C** for Kruskal–Katona and **induction on triangle count** for removal. Strategy A is the conceptual north star and should be sketched in the paper even if not fully formalized.

## Lean 4 Type Signature Guidance

You must include precise theorem signatures in the file, even if auxiliary definitions evolve. At minimum, aim to realize Lean declarations close to:

```lean
theorem turan_edge_bound_int
    (r n : ℕ) (hr : 2 ≤ r)
    (G : SimpleGraph (Fin n))
    (hKrFree : ¬ ∃ s : Finset (Fin n), s.card = r ∧ G.IsClique s) :
    (r - 1) * (2 * G.edgeFinset.card) ≤ (r - 2) * n^2
```

```lean
theorem greedy_triangle_removal_certificate
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) :
    ∃ H : SimpleGraph V,
      triangleCount H = 0 ∧ edgeEditDistance G H ≤ triangleCount G
```

```lean
theorem neighborhood_Kr_free
    (r n : ℕ) (hr : 2 ≤ r)
    (G : SimpleGraph (Fin n)) (v : Fin n)
    (hKrFree : ¬ ∃ s : Finset (Fin n), s.card = r ∧ G.IsClique s) :
    ¬ ∃ s : Finset {w // G.Adj v w}, s.card = r - 1 ∧
      (G.induce (fun w => G.Adj v w)).IsClique s
```

```lean
theorem compression_shadow_monotone
    (n k : ℕ) (𝒜 : Finset (Finset (Fin n))) :
    uniformFamily 𝒜 k →
    (lowerShadow (leftCompress 𝒜)).card ≤ (lowerShadow 𝒜).card
```

```lean
theorem threeAP_triangle_bridge
    (N : ℕ) :
    ∃ T : SimpleGraph (Fin N × Fin 3),
      ∀ A : Finset (Fin N),
        threeAPCount A = triangleCount (patternSubgraph T A)
```

If exact library APIs differ, adapt responsibly, but preserve theorem content.

## Cross-Domain Connections You Must Exploit

1. **Additive combinatorics**: Roth’s theorem via triangle-removal philosophy.
2. **Algorithms / property testing**: edge edit distance and certified triangle elimination.
3. **Discrete probability / pseudorandomness**: discuss how triangle counts behave like third-order statistics.
4. **Information/energy viewpoint**: your `degreeEnergy` definition is a combinatorial analogue of variance/energy and connects extremal graph theory to analytic methods.
5. **Potential physics analogy**: multipartite extremizers minimize local obstruction under global density constraints, akin to frustration minimization in spin systems.

## How to Build on Existing Verified Theorems

The listed catalog theorems are not directly extremal-combinatorial, but you should still exploit the *architectural lesson*:
- `master_theorem` and `grand_unification_theorem` suggest building **high-level structures** first, then deriving theorem families.
- `rewinding_lemma` is a model for turning existential combinatorics into a **certified algorithmic procedure**; imitate that style in the triangle-removal certificate.
- `divisor_gap_theorem` demonstrates that arithmetic inequalities can and should be formalized in exact integer form; likewise prefer integer Turán inequalities over vague real asymptotics.

If any FINAL versions are usable as style references, prefer them.

## Concrete Deliverables

You must produce **ALL** of the following:

1. **Lean file(s)** with at least:
   - 3 substantial theorems,
   - 1 novel definition,
   - 1 cross-domain theorem,
   - minimized sorry usage,
   - explicit comments marking the deepest proof steps.

2. **FUTURE_DIRECTIONS.md** with 3–5 **testable scientific hypotheses**, each falsifiable and computationally checkable. Example caliber:
   - “For the certified greedy triangle-removal algorithm, on random dense graphs `G(n,1/2)`, the achieved edit distance is within a factor `< 1.2` of optimum for `n ≤ 30`.”
   - “Balanced multipartite extremizers remain algorithmically recoverable from degree-energy descent for all `K_4`-free graphs up to `n = 40`.”
   - “The tripartite 3-AP graph encoding yields a removal-based density bound numerically matching Roth thresholds better than naive Fourier estimates on small `N`.”

3. **RESEARCH_PAPER.md** as a standalone scientific paper:
   - precise statements,
   - proof ideas,
   - why the formalization matters,
   - what new mathematical infrastructure was created,
   - what future theorems are now unlocked.

4. **ARTICLE.md** in Scientific American style:
   - explain Turán/removal/Roth as one conceptual story,
   - make the graph/additive-combinatorics bridge vivid,
   - describe why machine-checked extremal mathematics changes the game.

5. **A verified algorithm or computational method**:
   - e.g. greedy triangle removal,
   - or balanced multipartition optimizer,
   - or compression-based shadow minimizer.

6. **demo.py**:
   - construct example graphs,
   - compute triangle counts / edit distances,
   - display Turán graph edge counts,
   - test the 3-AP ↔ triangle bridge on small `N`,
   - empirically probe at least one conjecture from `FUTURE_DIRECTIONS.md`.

## Application Keywords

extremal graph theory; Turán theorem; clique-free graphs; degree energy; Zykov symmetrization; graph removal lemma; triangle removal; property testing; certified algorithms; additive combinatorics; Roth theorem; arithmetic progressions; Kruskal–Katona; shadows and compressions; graph edit distance; formal verification; Lean 4; combinatorial optimization; pseudorandomness; discrete harmonic analysis; graph limits infrastructure

## Non-Negotiable Standard

Do not return a shallow classroom formalization. Return a verified extremal-combinatorics platform: exact finite inequalities, algorithmic certificates, and a bridge to additive structure. The ideal outcome is that a future researcher can build hypergraph removal, arithmetic regularity, and graph property testing directly on your abstractions.

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

Research domain: Algebra
Research mode: prove
