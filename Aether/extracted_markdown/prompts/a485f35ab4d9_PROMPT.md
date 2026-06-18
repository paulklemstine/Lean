## Assignment: Partition Function Phase Transitions and Matroid Complexity

Prove new, non-trivial theorems. Build on catalog theorems. Minimize sorry.

## Depth Requirements (MANDATORY)

Your output must satisfy ALL of these:

1. **NO trivial proofs**: Do NOT prove statements by `native_decide`, `decide`, `norm_num`, or `rfl` unless the statement itself is genuinely important.
2. **At least 3 theorems with deep proof tactics**: Your file must contain at least 3 theorems proven using induction, rcases, by_contra, field_simp, or multi-step calc reasoning.
3. **Novel definitions**: Define at least one new mathematical structure or concept that does not already exist in the Catalog.
4. **Cross-domain connections**: Include at least one theorem that connects your domain to a different mathematical domain.
5. **Conjecture with testable prediction**: State at least one falsifiable conjecture with a clear computational test.

---

### Research Direction: Phase Transitions in Matroid Certificate Complexity

**Core Conjecture:** For the graphic matroid $M(G)$ of an Erdős–Rényi graph $G \sim G(n, p)$ with uniform edge weights, there exists a constant $c > 0$ such that the minimal deletion/contraction certificate size undergoes a phase transition at $p^* = c \cdot \ln(n)/n$: below $p^*$, certificates are polynomial in $n$; above $p^*$, certificates are exponential in $n$.

**Key Insight:** The connectivity threshold of random graphs ($p \sim \ln(n)/n$) coincides with a structural transition in the matroid: below threshold, the matroid is sparse with few bases (many isolated vertices, small components); above threshold, Kirchhoff's theorem forces the number of spanning trees to grow exponentially, and the deletion/contraction tree must track exponentially many distinct branches. This mirrors the SAT threshold and connects matroid complexity to statistical mechanics.

**Why Now?** Phase transitions in computational complexity are central to TCS (SAT threshold, graph coloring threshold). The matroid certificate framework—already developed in the catalog—provides a new family where phase transitions can be studied both analyitically and experimentally, with direct implications for understanding when quantum sampling advantages become achievable.

---

### Novel Definitions to Formalize

```lean
/-- A deletion/contraction certificate tree for a matroid. Each node is either
    a leaf (base case) or an internal node recording which element was deleted
    or contracted, with subtrees for each branch. -/
inductive CertTree (α : Type*) where
  | leaf : CertTree α
  | node : α → Bool → CertTree α → CertTree α → CertTree α
  -- Bool = false means deletion, true means contraction
  deriving Repr

/-- The size of a certificate tree (number of internal nodes + leaves). -/
def certSize {α : Type*} : CertTree α → ℕ
  | .leaf => 1
  | .node _ _ t₁ t₂ => 1 + certSize t₁ + certSize t₂

/-- The certificate complexity of a matroid M is the minimum size of any
    valid deletion/contraction certificate tree for M. -/
def certComplexity (M : Matroid α) : ℕ :=
  sInf {n : ℕ | ∃ t : CertTree α, certSize t = n ∧ isValidCert M t}
```

---

### Theorem Targets

**Theorem 1 (Sparse Upper Bound):** Below the connectivity threshold, certificate size is polynomial.

```lean
/-- If a graph on n vertices has fewer than ⌈n/2⌉ edges, then the graphic
    matroid certificate complexity is at most n^3. -/
theorem sparse_cert_polynomial_bound {V : Type*} [Fintype V] [DecidableEq V]
    {E : Type*} [Fintype E] (G : SimpleGraph V) (hE : G.edgeFinset.card < (Fintype.card V + 1) / 2)
    (h_conn : ¬G.Connected) :
    ∃ t : CertTree E, isValidCert (graphicMatroid G) t ∧ certSize t ≤ (Fintype.card V)^3 := by
  sorry
```

**Proof Strategy A (Structural Decomposition):**
1. Since $G$ is disconnected, partition $V$ into connected components $C_1, \ldots, C_k$ where $k \geq 2$.
2. The graphic matroid of a disconnected graph decomposes as a direct sum: $M(G) = M(G[C_1]) \oplus \cdots \oplus M(G[C_k])$.
3. The certificate tree for $M(G)$ is built by concatenating the certificate trees for each component.
4. Each component has at most $|C_i| - 1$ edges (since it's a forest or has few cycles), so each sub-certificate is small.
5. The total size is bounded by $\sum_i |C_i|^2 \leq n^2$.

**Theorem 2 (Dense Lower Bound via Kirchhoff):** Above the connectivity threshold, certificate size is exponential.

```lean
/-- If a connected graph on n vertices has at least n * ⌈ln n⌉ edges
    and minimum degree at least 2, then the graphic matroid certificate
    complexity is at least 2^(n/4). -/
theorem dense_cert_exponential_lower_bound {V : Type*} [Fintype V] [DecidableEq V]
    {E : Type*} [Fintype E] (G : SimpleGraph V) (h_conn : G.Connected)
    (h_edges : G.edgeFinset.card ≥ Fintype.card V * (Nat.log 2 (Fintype.card V)))
    (h_min_deg : ∀ v, 2 ≤ G.degree v) :
    ∀ t : CertTree E, isValidCert (graphicMatroid G) t →
      2^(Fintype.card V / 4) ≤ certSize t := by
  sorry
```

**Proof Strategy B (Entropy-Kirchhoff):**
1. By Kirchhoff's matrix-tree theorem, the number of spanning trees $\tau(G) = \frac{1}{n}\prod_{i=1}^{n-1} \lambda_i$ where $\lambda_i$ are the non-zero Laplacian eigenvalues.
2. For dense connected graphs with minimum degree $\geq 2$, bound $\tau(G) \geq 2^{n/2}$ using eigenvalue estimates (Friedman-Komlós bound or direct expansion).
3. Each spanning tree is a basis of $M(G)$. The deletion/contraction tree must distinguish all bases.
4. Information-theoretic argument: a binary tree of depth $d$ has at most $2^d$ leaves, so to distinguish $\tau(G) \geq 2^{n/2}$ bases, we need depth $\geq n/2$, giving size $\geq 2^{n/4}$.

**Theorem 3 (Cross-Domain: Kirchhoff-Laplacian Connection):** Bridge matroid theory to spectral graph theory.

```lean
/-- The number of spanning trees of a connected graph equals the product of
    non-zero Laplacian eigenvalues divided by the number of vertices.
    This connects the matroid partition function to spectral theory. -/
theorem kirchhoff_matrix_tree {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) (h_conn : G.Connected) :
    (spanningTreeCount G : ℝ) =
      (∏ i : Fin (Fintype.card V - 1),
        (laplacianEigenvalues G h_conn i : ℝ)) / (Fintype.card V : ℝ) := by
  sorry
```

**Proof Strategy C (Spectral-Determinant):**
1. Express the Laplacian as $L = D - A$ where $D$ is the degree matrix and $A$ the adjacency matrix.
2. Use the Cauchy-Binet formula on any $(n-1) \times (n-1)$ minor of $L$.
3. Each non-zero term in the determinant expansion corresponds to a spanning tree.
4. The product of non-zero eigenvalues equals any cofactor of $L$ (a classical algebraic identity).
5. Conclude by matching the cofactor with the spanning tree count.

---

### Falsifiable Conjecture with Computational Test

**Conjecture (Sharp Threshold):** The phase transition constant is $c = 1$: for $G(n, p)$ with $p = (1+\epsilon)\ln(n)/n$ where $\epsilon > 0$ is fixed, the expected certificate complexity satisfies $\mathbb{E}[\text{certComplexity}(M(G))] \geq 2^{n^{1-\delta}}$ for any $\delta > 0$ and sufficiently large $n$.

**Computational Test:** For $n \in \{6, 8, 10, 12, 14\}$ and $p \in \{0.1 \cdot k : k = 1, \ldots, 9\}$, generate 100 random $G(n,p)$ graphs per parameter pair. Compute the certificate complexity via exhaustive deletion/contraction tree search. Plot $\log(\text{certComplexity})$ vs. $p$ for each $n$. The conjecture predicts a sharp jump near $p = \ln(n)/n$, with the jump becoming sharper as $n$ increases.

---

### Catalog Integration

Build on `Catalog/Pythagorean/MatroidQuantumCertificates.lean`:
- Use `partition_function_pos` to establish that the partition function is well-defined for the graphic matroid.
- Extend `certificate_construction` to track certificate size explicitly.
- The phase transition result connects to quantum sampling hardness: when certificates are exponential, classical sampling from the matroid partition function is #P-hard, but quantum devices may achieve polynomial-time sampling—precisely the regime where quantum advantage emerges.

---

### Revolutionary Significance

This work opens three new fields:

1. **Structural Phase Transitions in Matroid Theory**: A new family of phase transitions beyond percolation and SAT—now in the algebraic-combinatorial setting of matroid bases.

2. **Spectral-Matroid Duality**: Kirchhoff's theorem becomes the bridge between spectral graph theory and matroid certificate complexity, enabling eigenvalue-based complexity analysis.

3. **Quantum Sampling Thresholds**: The phase transition directly determines when quantum sampling advantages are achievable for matroid partition functions, with implications for BosonSampling and IQP circuit complexity.

**Keywords:** phase transition, matroid certificate complexity, Kirchhoff's matrix-tree theorem, Laplacian eigenvalues, deletion-contraction recurrence, Erdős–Rényi random graphs, computational complexity threshold, quantum sampling advantage, partition function, spanning tree enumeration

---

### Mandatory Deliverables

(a) **FUTURE_DIRECTIONS.md** with 3-5 research directions, each including "The key insight is..." and "Why now?" At least one direction must bridge to statistical mechanics or quantum information.

(b) **RESEARCH_PAPER.md** as a standalone scientific document readable without code access, covering: the phase transition theorem, proof sketches, computational experiments, and implications for quantum sampling.

(c) **ARTICLE.md** in Scientific American style—engaging and accessible. Explain how connectivity in random graphs controls the complexity of verifying matroid properties, and why this mirrors phase transitions in physics. TABOO: Do NOT focus on formal verification machinery.

(d) **Verified algorithm**: An algorithm that computes certificate complexity for a given graph, with a proof of correctness relating it to the deletion/contraction recurrence.

(e) **demo.py**: Generate random $G(n,p)$ graphs, compute certificate complexities (or bounds), and produce a phase diagram plotting certificate complexity vs. edge probability, showing the threshold phenomenon.

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

Research domain: Pythagorean
Research mode: prove
