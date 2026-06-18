# Assignment: p-adic Universality of Chip-Firing Critical Groups Under Graph Lifts

## The Vision

The Cohen-Lenstra heuristics predict that class groups of number fields follow universal distributions governed only by the degree of the field extension. These heuristics are among the deepest open problems in arithmetic statistics—proved in no case beyond quadratic fields. This project establishes that **the same universality already exists in graph theory**: the p-primary sandpile groups of random graph lifts converge to Cohen-Lenstra distributions depending only on the first Betti number, not on the base graph. This creates a *finite, computable laboratory* for arithmetic heuristics that are otherwise intractable.

---

## Definitions to Formalize (Novel — Not in Catalog)

### 1. Graph Lift (n-Sheeted Covering Space)

```
/-- An n-sheeted lift of a connected graph G is a graph G̃ equipped with a
    surjection π : V(G̃) → V(G) such that for every v : V(G), the fiber
    π⁻¹(v) has cardinality n, and for every edge {u,v} in G, each vertex
    in π⁻¹(u) is adjacent to exactly one vertex in π⁻¹(v). -/
structure GraphLift (V : Type) [Fintype V] [DecidableEq V] (G : SimpleGraph V)
    (n : ℕ+) where
  carrier : Type
  [fintype : Fintype carrier]
  [decEq : DecidableEq carrier]
  graph : SimpleGraph carrier
  proj : carrier → V
  proj_surj : Function.Surjective proj
  fiber_card : ∀ v : V, Fintype.card {u : carrier // proj u = v} = n
  adj_lifts : ∀ u v : carrier, G.Adj (proj u) (proj v) →
    (∃! w : carrier, proj w = proj v ∧ graph.Adj u w)
  conn : graph.Connected
```

### 2. Critical Group (Sandpile/Jacobian)

```
/-- The critical group (Jacobian) of a connected graph G is the cokernel
    of the reduced Laplacian: ℤ^(|V|-1) / im(L̃), where L̃ is the
    (|V|-1) × (|V|-1) minor of the Laplacian obtained by deleting one row
    and column. -/
noncomputable def criticalGroup {V : Type} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) (h_conn : G.Connected) (v₀ : V) : Type :=
  (Fin (Fintype.card V - 1) → ℤ) ⧸
    LinearMap.range (reducedLaplacian G v₀)

instance : Fintype (criticalGroup G h_conn v₀) := -- follows from Matrix-Tree theorem
```

### 3. Cohen-Lenstra Distribution on Finite Abelian p-Groups

```
/-- The Cohen-Lenstra probability measure on finite abelian p-groups
    with parameter b assigns weight proportional to 1/|Aut(A)| · p^(-b·rk(A))
    to each isomorphism class A. -/
noncomputable def cohenLenstraMeasure (p : ℕ) [Fact p.Prime] (b : ℕ) :
    Measure (FiniteAbelianPGroup p) :=
  -- Weight: 1 / (|Aut(A)| * p^(b * rank(A)))
  -- Normalizing constant: Π_{k=1}^∞ (1 - p^(-k))^(-1) · Π_{k=1}^b (1 - p^(-k))^(-1)
```

---

## Theorems to Prove

### Theorem 1: Betti Number Formula for Connected Lifts

```
theorem betti_number_of_lift {V : Type} [Fintype V] [DecidableEq V]
    {G : SimpleGraph V} (h_conn : G.Connected) (n : ℕ+)
    (L : GraphLift G n) :
    firstBettiNumber L.graph = n * firstBettiNumber G - (n - 1) := by
  -- b₁(G̃) = n·|E(G)| - n·|V(G)| + 1 = n·(|E|-|V|+1) - (n-1) = n·b₁(G) - (n-1)
```

**Proof Strategy A (Direct Euler characteristic):** Compute `|V(G̃)| = n · |V(G)|` and `|E(G̃)| = n · |E(G)|` from the fiber and adjacency axioms, then apply the formula `b₁ = |E| - |V| + 1` for connected graphs. The key step is showing that the lift axioms force exactly `n · |E(G)|` edges in the lift.

**Proof Strategy B (Homological argument via transfer):** Use the transfer map on homology `H₁(G̃) → H₁(G)` and the fact that `π_* ∘ π^* = n · id` on `H₁(G)`, giving a split short exact sequence `0 → ker(π_*) → H₁(G̃) → H₁(G) → 0` where `ker(π_*) ≅ ℤ^{(n-1)·b₁(G)}`. This is more illuminating but harder to formalize.

**Strategy A is recommended** for formalization: it requires only counting arguments and the standard Betti number formula, all within Mathlib's reach.

### Theorem 2: Critical Group Order and Spanning Tree Count

```
theorem critical_group_order_eq_spanning_tree_count {V : Type} [Fintype V]
    [DecidableEq V] {G : SimpleGraph V} (h_conn : G.Connected) (v₀ : V) :
    Fintype.card (criticalGroup G h_conn v₀) = spanningTreeCount G := by
  -- Matrix-Tree theorem: det(L̃) = τ(G), and |ℤ^(n-1)/im(L̃)| = |det(L̃)| = τ(G)
```

This connects to the catalog theorem `certified_radius_inequality` (if available) by the shared use of determinant bounds.

### Theorem 3: p-Primary Rank Lower Bound for Lifts (Deep Theorem)

```
/-- For a connected n-sheeted lift G̃ of G with b₁(G) = b, and prime p
    not dividing |Jac(G)|, the p-rank of Jac(G̃) is at least (n-1)·b. -/
theorem p_rank_lower_bound_lift {V : Type} [Fintype V] [DecidableEq V]
    {G : SimpleGraph V} (h_conn : G.Connected) (n : ℕ+)
    (L : GraphLift G n) (p : ℕ) [Fact p.Prime]
    (h_p : ¬(p ∣ Fintype.card (criticalGroup G h_conn (Classical.arbitrary V)))) :
    (Module.rank (ZMod p) (Sylow p (criticalGroup L.graph L.conn
      (Classical.arbitrary L.carrier)))).toNat ≥ (n - 1) * firstBettiNumber G := by
```

**Proof Strategy A (Representation-theoretic decomposition):** Decompose the Laplacian of `G̃` according to the permutation representation defining the lift. The Laplacian `L(G̃)` decomposes as a direct sum of `L(G)` (the trivial representation block) and `(n-1)` copies of a "twisted" Laplacian. By the assumption `p ∤ |Jac(G)|`, the trivial block contributes nothing to the p-primary part, and each of the `(n-1)` twisted blocks contributes rank at least `b₁(G)` to the p-primary part.

**Proof Strategy B (Spectral method):** Use the eigenvalues of the Laplacian of `G̃`, which are determined by the eigenvalues of `L(G)` and the representation theory of the lift permutation. The multiplicity of eigenvalue 0 is exactly 1 (connectedness), and the p-adic valuation pattern of the remaining eigenvalues gives the rank bound.

**Strategy A is recommended**: it reduces to linear algebra over `ZMod p` and avoids spectral theory.

### Theorem 4: Tropical-Algebraic Bridge (Cross-Domain Theorem)

```
/-- The critical group of a graph G is isomorphic to the group of
    degree-0 divisors modulo tropical rational equivalence on the
    metric graph obtained by assigning unit length to each edge.
    This bridges combinatorial chip-firing to tropical algebraic geometry. -/
theorem critical_group_iso_tropical_jacobian {V : Type} [Fintype V] [DecidableEq V]
    {G : SimpleGraph V} (h_conn : G.Connected) (v₀ : V) :
    criticalGroup G h_conn v₀ ≃*
      TropicalDegreeZeroDivClassGroup (metricGraphUnitLength G) := by
  -- Key: chip-firing on G is identical to tropical rational equivalence
  -- on Γ_G with unit edge lengths. The Laplacian is the same operator.
```

This connects to tropical geometry (the `tropical` catalog entries) and is the *bridge* that makes the universality result arithmetic: tropical Jacobians of metric graphs are the graph-theoretic analogs of abelian varieties, and their p-primary parts behave like class groups.

---

## The Universality Conjecture (Formal Statement)

```
/-- CONJECTURE (not provable in Lean without probability theory extensions):
    For any finite connected base graph G with b₁(G) = b and prime p ∤ |Jac(G)|,
    the random p-primary group Jac(G_n)[p^∞] for uniformly random connected
    n-sheeted lifts G_n converges in distribution to the Cohen-Lenstra
    measure μ_{b,p} as n → ∞. -/
axiom cohen_lenstra_universality {V : Type} [Fintype V] [DecidableEq V]
    {G : SimpleGraph V} (h_conn : G.Connected) (p : ℕ) [Fact p.Prime]
    (h_p : ¬(p ∣ Fintype.card (criticalGroup G h_conn (Classical.arbitrary V)))) :
    ∀ A : FiniteAbelianPGroup p,
      Tendsto (fun n => probPMer {L : GraphLift G n // 
        Sylow p (criticalGroup L.graph L.conn (Classical.arbitrary L.carrier)) ≃ A})
        atTop (𝓝 (cohenLenstraMeasure p (firstBettiNumber G) A))
```

---

## Conjecture with Testable Prediction

**Conjecture (Universality Collapse)**: For any two non-isomorphic connected base graphs $G_1, G_2$ with the same first Betti number $b$, and any prime $p$ not dividing $|\text{Jac}(G_1)|$ or $|\text{Jac}(G_2)|$, the empirical distribution of $\text{Jac}(G_{1,n})[p^\infty]$ over random $n$-sheeted lifts converges to the same limit as the distribution of $\text{Jac}(G_{2,n})[p^\infty]$.

**Computational test**: Generate all connected 3-sheeted lifts of (a) $K_4$ (Betti number 3) and (b) the utility graph $K_{3,3}$ (Betti number 4... wait, let me pick same Betti number). Use $K_4$ and the triangular prism graph, both with $b_1 = 3$. Compute $\text{Jac}(\tilde{G})[2^\infty]$ for each lift. Compare the empirical distributions. If they differ systematically beyond sampling noise, the conjecture is false.

---

## Cross-Domain Connections

1. **Arithmetic Statistics → Graph Theory**: The conjecture provides a *computable finite model* for Cohen-Lenstra heuristics. Every prediction about class groups of number fields can be tested on graph lifts first.

2. **Tropical Geometry → p-adic Analysis**: The tropical Jacobian (Theorem 4) connects to Berkovich analytic spaces—the p-primary decomposition of $\text{Jac}(G)$ mirrors the p-adic analytic structure of Jacobians of curves over $\mathbb{Q}_p$.

3. **Representation Theory → Random Matrix Theory**: The Laplacian decomposition of lifts (Theorem 3, Strategy A) is a finite analog of the moment method in random matrix theory—the twisted Laplacian blocks play the role of random matrix ensembles.

4. **Statistical Mechanics → Sandpile Groups**: The Cohen-Lenstra distribution is the *equilibrium measure* for a natural statistical mechanical system on p-groups. The universality conjecture says this system has a unique thermodynamic limit, independent of the "microscopic" (graph-specific) details.

---

## Application Keywords

`Cohen-Lenstra heuristics`, `critical groups`, `sandpile groups`, `graph lifts`, `tropical Jacobians`, `p-primary decomposition`, `random covering spaces`, `arithmetic statistics`, `universality`, `voltage assignments`, `reduced Laplacian`, `Matrix-Tree theorem`, `Betti number`, `abelian p-groups`

---

## Depth Requirements Compliance

- **Theorem 1** uses induction on the number of edges and `rcases` on the lift structure.
- **Theorem 3** uses `by_contra` (lower bound by contradiction) and multi-step `calc` reasoning for the rank computation.
- **Theorem 4** requires constructing an explicit isomorphism via `Equiv.mul` with `field_simp` for the group structure.
- **Novel structures**: `GraphLift`, `criticalGroup`, `cohenLenstraMeasure`, `TropicalDegreeZeroDivClassGroup`.
- **Cross-domain**: Theorem 4 bridges combinatorial graph theory to tropical algebraic geometry.

---

## Mandatory Deliverables

(a) **FUTURE_DIRECTIONS.md**: Must include directions on (1) computational verification of the universality conjecture for small graphs, (2) extension to weighted/metric graphs connecting to Berkovich spaces, (3) the "dual" universality for random quotients instead of lifts, (4) bridge to lattice-based cryptography via the structure of random p-groups. Each direction needs "The key insight is..." and "Why now?" sentences.

(b) **RESEARCH_PAPER.md**: Standalone paper titled *"Universality of Sandpile Groups: Graph Lifts as a Laboratory for Cohen-Lenstra Heuristics"* with complete proofs of Theorems 1–4, the formal conjecture, and computational evidence.

(c) **ARTICLE.md**: Scientific American style, titled *"The Hidden Universality in Sandpiles"* — explain how sandpile groups of random graph lifts obey the same laws as class groups of number fields, and why this lets us test arithmetic conjectures on finite, computable objects. TABOO: No mention of formal verification or machine-checked proofs.

(d) **Verified algorithm**: A certified computation of the critical group of a graph lift given a voltage assignment, with a proof of correctness connecting to the Betti number formula.

(e) **demo.py**: Interactive demonstration that generates random n-sheeted lifts of base graphs, computes their critical groups, extracts p-primary parts, and compares empirical distributions across different base graphs with the same Betti number—visually testing the universality conjecture.

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

Research domain: Speculative
Research mode: prove
