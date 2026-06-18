## Assignment: Information-Theoretic Bounds on Tropical Barcode Stability

Prove new, non-trivial theorems. Build on catalog theorems. Minimize sorry.

## Depth Requirements (MANDATORY)

Your output must satisfy ALL of these:

1. **NO trivial proofs**: Do NOT prove statements by `native_decide`, `decide`, `norm_num`, or `rfl` unless the statement itself is genuinely important.

2. **At least 3 theorems with deep proof tactics**: Your file must contain at least 3 theorems proven using induction, rcases, by_contra, field_simp, or multi-step calc reasoning.

3. **Novel definitions**: Define at least one new mathematical structure or concept that does not already exist in the Catalog.

4. **Cross-domain connections**: Include at least one theorem that connects your domain to a different mathematical domain.

5. **Conjecture with testable prediction**: State at least one falsifiable conjecture with a clear computational test.

---

### Research Direction: Tropical Information Theory and Barcode Stability

**Core Thesis:** The stability constant (Δ+1) in tropical barcode stability is not merely combinatorial—it is the *tropical channel capacity* of a degree-Δ vertex. This reframes stability as an information-theoretic phenomenon: barcodes lose at most (Δ+1) bits of information per vertex under the tropical semiring, and this capacity constraint *is* the stability bound.

**Precise Theorem Statements with Lean 4 Signatures:**

**Theorem 1 — Tropical Data Processing Inequality:**
```lean
/-- The entropy of a tropical barcode is bounded by (Δ+1)/|V| times the
    entropy of the filtration. This is the tropical analog of the data
    processing inequality: the barcode (a deterministic function of the
    filtration) cannot increase entropy beyond the channel capacity. -/
theorem tropical_data_processing_inequality
    {n : ℕ} (G : SimpleGraph (Fin n)) [DecidableRel G.Adj]
    (f : Fin G.edgeFinset.card → ℝ)
    (Δ : ℕ) (hΔ : ∀ v, G.degree v ≤ Δ)
    (P : Measure (Fin G.edgeFinset.card → ℝ))
    [IsProbabilityMeasure P]
    (hf : Measurable f)
    (h_bdd : ∀ e, f e ∈ Set.Ioc 0 1) :
    let barcode := tropicalEventProfile G f
    entropy P (barcodeRVar G f P) ≤ (Δ + 1) * entropy P hf / n
```

**Theorem 2 — Information-Theoretic Stability Bound:**
```lean
/-- The tropical barcode distance is bounded by a function of mutual information
    and graph entropy, establishing that stability is governed by information capacity. -/
theorem info_theoretic_stability
    {n : ℕ} (G : SimpleGraph (Fin n)) [DecidableRel G.Adj]
    (f g : Fin G.edgeFinset.card → ℝ)
    (Δ : ℕ) (hΔ : ∀ v, G.degree v ≤ Δ)
    (P : Measure (Fin G.edgeFinset.card → ℝ))
    [IsProbabilityMeasure P] :
    tropicalBarcodeDist (tropicalEventProfile G f) (tropicalEventProfile G g)
      ≤ √(2 * mutualInfo P (filtrationRV P f) (barcodeRV G f P))
        * (Δ + 1) / √(graphDegreeEntropy G)
```

**Theorem 3 — Cross-Domain: Tropical Entropy and Spectral Gap (Number Theory + Tropical Geometry + Spectral Graph Theory):**
```lean
/-- The tropical entropy of a graph is bounded below by log(λ₁/Δ),
    where λ₁ is the largest eigenvalue of the adjacency matrix.
    This connects tropical information theory to spectral graph theory
    and the Alon-Boppana bound from expander graph theory. -/
theorem tropical_entropy_spectral_bound
    {n : ℕ} (G : SimpleGraph (Fin n)) [DecidableRel G.Adj]
    [Fintype G.edgeSet] [DecidableEq G.edgeSet.Elem]
    (hconn : G.Connected) (hn : 2 ≤ n)
    (λ₁ : ℝ) (hλ : IsLargestEigenvalue G λ₁)
    (Δ : ℕ) (hΔ : ∀ v, G.degree v ≤ Δ) :
    tropicalGraphEntropy G ≥ Real.log (λ₁ / Δ)
```

**Novel Definition:**
```lean
/-- The tropical channel capacity of a vertex: the maximum rate at which
    filtration information can be transmitted through a degree-d vertex
    in the min-plus semiring. This is a new information-theoretic quantity
    that unifies tropical degree bounds with Shannon capacity. -/
def tropicalChannelCapacity (d : ℕ) : ℝ :=
  (d + 1 : ℝ) * Real.log 2  -- d+1 symbols in min-plus alphabet, log₂ scale

/-- The graph degree entropy: Shannon entropy of the normalized degree sequence,
    viewed as a probability distribution. This measures the information content
    of the graph's topology. -/
def graphDegreeEntropy {n : ℕ} (G : SimpleGraph (Fin n)) [DecidableRel G.Adj] : ℝ :=
  let dseq := fun v => (G.degree v : ℝ) / (2 * G.edgeFinset.card : ℝ)
  - ∑ v, dseq v * Real.log (dseq v)
```

**Proof Strategies:**

**Strategy A (Channel Capacity — Most Promising):** Model the barcode construction as a communication channel Φ: Filtration → Barcode over the tropical semiring. Each vertex of degree Δ acts as a relay with capacity Δ+1 (it receives Δ+1 signals: its own weight plus Δ neighbors). Apply the tropical analog of Shannon's channel coding theorem: the mutual information I_trop(f; Φ(f)) ≤ C where C = (Δ+1)/|V| is the per-vertex capacity. The stability bound follows by Pinsker's inequality: d_T ≤ √(2·D_KL) ≤ √(2·I) · capacity_factor. This is most promising because it directly explains *why* Δ+1 is the natural constant—it's not ad hoc, it's the channel capacity.

**Strategy B (Convex Optimization / Lagrange Duality):** Formulate mutual information maximization as a convex program over tropical probability measures. The degree constraint enters as a linear inequality. Apply Lagrange duality: the dual variable associated with the degree constraint is exactly Δ+1, and strong duality gives the stability bound. This approach connects to tropical convexity and the recent theory of tropical polyhedra as second-order cones.

**Strategy C (Combinatorial Compression — For Theorem 3):** Show that any degree-Δ vertex admits a prefix-free code with at most Δ+1 codewords (Kraft's inequality in min-plus). The compression ratio bounds the tropical entropy from below. Then connect to spectral graph theory via the Alon-Boppana bound: λ₁ ≥ 2√(Δ-1) - o(1), which gives log(λ₁/Δ) ≥ log(2√(Δ-1)/Δ) > 0 for Δ ≥ 3. This bridges tropical information theory to Ramanujan graphs and number-theoretic constructions of expanders.

**Cross-Domain Connections:**

- **Spectral Graph Theory → Tropical Information**: The largest eigenvalue λ₁ of the adjacency matrix controls both the mixing time of random walks (classical) and the tropical channel capacity (new). Ramanujan graphs (number-theoretic constructions from ℚ(√d)) achieve optimal capacity.
- **Shannon Theory → Min-Plus Algebra**: The data processing inequality, normally stated for KL divergence, has a tropical analog where addition is min and multiplication is +. This connects tropical geometry to rate-distortion theory.
- **Expander Graphs → Optimal Barcodes**: Graphs with large spectral gap (expanders) minimize information loss in the barcode channel, suggesting that expander families give optimally stable tropical barcodes—a connection to the Lubotzky-Phillips-Sarnak construction.

**Application Keywords:** `tropical channel capacity`, `min-plus information theory`, `barcode compression`, `spectral stability`, `Ramanujan barcodes`, `data processing inequality tropical`, `degree-entropy stability`, `topological data compression`

**Falsifiable Conjecture:**
```lean
/-- Conjecture: For Erdős-Rényi graphs G(n, c/n) with n vertices,
    the ratio I(f; TPB(G,f)) / H(G) converges to (1 - e^{-c}) as n → ∞,
    independently of the filtration distribution f.
    This predicts that sparse random graphs achieve near-optimal
    information transmission through their barcode channels. -/
axiom erdos_renyi_capacity_conjecture :
    ∀ᶠ n in atTop,
    ∀ (c : ℝ) (hc : 0 < c),
    let G := erdosRenyi n (c / n)
    |mutualInfo P (filtrationRV P f) (barcodeRV G f P) / graphDegreeEntropy G
      - (1 - Real.exp (-c))| < ε
```

**Test:** Generate 500 instances of G(100, c/n) for c ∈ {3, 5, 10}. For each, compute a random filtration f ~ Uniform([0,1]^|E|), compute I(f; TPB(G,f)) via kernel density estimation, compute H(G) from the degree sequence, and plot I/H against (1-e^{-c}). The conjecture predicts convergence to the curve y = 1-e^{-c}.

**Catalog Integration:** Build on `tropicalEventProfile` and `certified_stability_bound` from `Pythagorean/TropicalBridge/Stability.lean`. The key extension is: where the catalog gives the *combinatorial* bound d_T ≤ (Δ+1)·‖f-g‖∞, this work gives the *information-theoretic* explanation: the bound is tight because Δ+1 is the channel capacity, and the inequality is an instance of the data processing inequality.

**Revolutionary Significance:** This would establish that topological data analysis is fundamentally an information-theoretic enterprise. The stability theorems that underlie all of TDA are not arbitrary combinatorial facts—they reflect the information capacity of the underlying graph topology. This opens: (1) optimal compression schemes for persistence barcodes via rate-distortion theory, (2) new stability bounds for graphs with known spectral properties (expanders get tighter bounds), (3) a bridge between tropical geometry and Shannon theory that could reformulate coding theory in the min-plus semiring.

---

### Mandatory Deliverables

(a) **FUTURE_DIRECTIONS.md** with 3-5 research directions. Each must include "The key insight is..." and "Why now?" At least one direction must bridge to a different domain (suggested: quantum error correction via tropical channels, or algebraic number theory via Ramanujan graph barcodes).

(b) **RESEARCH_PAPER.md** — a standalone scientific document readable without code access. Must explain: what was discovered (tropical channel capacity governs barcode stability), why it matters (information-theoretic foundation for TDA), and what to investigate next (rate-distortion curves for barcodes, Ramanujan optimality).

(c) **ARTICLE.md** in Scientific American style — engaging, accessible. TABOO: Do NOT focus on formal verification. Write about the *ideas*: why the stability constant Δ+1 is really a channel capacity, what this means for data compression, and how expander graphs give optimal barcodes. Think "Shannon meets topology."

(d) A verified algorithm or computational method — implement tropical mutual information estimation and the capacity computation.

(e) **demo.py** that generates random graphs, computes filtrations, estimates mutual information I(f; TPB(G,f)), computes H(G), and plots the ratio against the theoretical prediction 1-e^{-c}.

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
