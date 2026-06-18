## Assignment: Precise Threshold Constant for Certificate Complexity — The c = 1 Conjecture

### The Central Conjecture

**Conjecture (Certificate Complexity Threshold equals Connectivity Threshold).** There exists a sharp phase transition for the expected certificate complexity of the graphic matroid $M(G(n,p))$ at $p = \ln(n)/n$, with threshold constant $c = 1$.

Specifically: For every $\varepsilon > 0$, there exists $C > 0$ such that:

$$p < (1-\varepsilon)\frac{\ln n}{n} \implies \mathbb{E}[\text{certComplexity}(M(G(n,p)))] \leq n^C$$

$$p > (1+\varepsilon)\frac{\ln n}{n} \implies \mathbb{E}[\text{certComplexity}(M(G(n,p)))] \geq 2^{n^C}$$

This mirrors the Erdős–Rényi connectivity threshold exactly — certificate complexity "detects" connectivity at the same point random graphs become connected.

---

### Formalization Targets

**Novel Definition — Monotone Certificate Property:**
```lean
/-- A graph property P is monotone if adding edges preserves truth. -/
def IsMonotoneGraphProp (P : SimpleGraph α → Prop) : Prop :=
  ∀ ⦃G₁ G₂ : SimpleGraph α⦄, G₁ ≤ G₂ → P G₁ → P G₂

/-- The property "graphic matroid has certificate complexity ≥ t" is monotone. -/
def certComplexityAtLeast {α : Type*} [Fintype α] [DecidableEq α]
    (t : ℕ) (G : SimpleGraph α) : Prop :=
  certComplexity (graphicMatroid G) ≥ t
```

**Novel Definition — Threshold Constant:**
```lean
/-- The infimum of p where certificate complexity becomes exponential. -/
def certComplexityThreshold (n : ℕ) : ℝ :=
  sInf {p : ℝ | ∃ c > 0, ∀ᵉ q > p,
    𝔼[certComplexity (M (G n q))] ≥ 2 ^ (n ^ c)}
```

**Theorem 1 (Monotonicity — Foundation Stone):**
```lean
theorem cert_complexity_monotone {α : Type*} [Fintype α] [DecidableEq α]
    {G₁ G₂ : SimpleGraph α} (h_sub : G₁ ≤ G₂) :
    certComplexity (graphicMatroid G₁) ≤ certComplexity (graphicMatroid G₂) := by
  -- Key insight: adding edges introduces new circuits, which are new
  -- minimal obstructions to independence, requiring more certification data.
```

**Theorem 2 (Kirchhoff Information Bound — The Bridge):**
```lean
theorem cert_complexity_lower_bound_spanning_trees {α : Type*} [Fintype α] [DecidableEq α]
    {G : SimpleGraph α} (h_conn : G.Connected) :
    (2 : ℝ) ^ (certComplexity (graphicMatroid G) : ℝ) ≥
      (spanningTreeCount G : ℝ) := by
  -- Each spanning tree is a basis of the graphic matroid.
  -- A certificate must distinguish among all bases.
  -- Information-theoretic bound: need ≥ log₂(|bases|) bits.
```

**Theorem 3 (Phase Transition at c = 1 — The Crown):**
```lean
theorem cert_complexity_phase_transition_at_one :
    ∀ᵉ n ≥ 2, ∀ᵉ ε > 0, ∃ C > 0,
      (∀ p < (1 - ε) * (Real.log n / n),
        𝔼[certComplexity (M (G n p))] ≤ n ^ C) ∧
      (∀ p > (1 + ε) * (Real.log n / n),
        𝔼[certComplexity (M (G n p))] ≥ 2 ^ (n ^ C)) := by
  -- Combines: (1) monotonicity, (2) Kirchhoff bound,
  -- (3) Friedgut's sharp threshold theorem,
  -- (4) known spanning tree counts in G(n,p).
```

---

### Proof Strategies

**Strategy A: Friedgut's Sharp Threshold + Monotonicity (Most Promising).**

1. Prove `cert_complexity_monotone` — adding edges adds circuits, which are new minimal dependent sets requiring certification. This makes $\{G : \text{certComplexity}(M(G)) \geq t\}$ a monotone graph property.

2. Apply **Friedgut's sharp threshold theorem** (1999): for any monotone graph property that is not approximately local, there is a sharp threshold. Certificate complexity being large is non-local because it depends on the global spanning tree structure.

3. Pin the threshold to $p = \ln(n)/n$ using the **Kirchhoff bound**: below connectivity, $\tau(G) = 0$ (no spanning trees), so the bound is vacuous; above connectivity, $\tau(G) \sim n^{n-2} \cdot p^{n-1}$ grows exponentially. The transition in $\tau(G)$ occurs precisely at the connectivity threshold.

4. *Why most promising*: This directly connects the well-studied connectivity threshold to the new certificate complexity threshold, and Friedgut's machinery is purpose-built for exactly this type of result.

**Strategy B: Direct Probabilistic Method via Kirchhoff.**

1. Use the **Matrix Tree Theorem**: $\tau(G) = \frac{1}{n} \prod_{i=2}^{n} \lambda_i$ where $\lambda_i$ are the nontrivial eigenvalues of the Laplacian.

2. In $G(n,p)$ with $p > (1+\varepsilon)\ln(n)/n$, show $\mathbb{E}[\log \tau(G)] \geq n^{1-o(1)}$ using spectral concentration of the Laplacian.

3. Apply Theorem 2 to convert: $\text{certComplexity} \geq \log_2 \tau(G)$.

4. *Risk*: Spectral concentration in random graphs is technically demanding, and the Laplacian eigenvalue bounds for sparse random graphs are less well-developed than the combinatorial approach.

**Strategy C: Reduction to k-SAT Threshold Analogy.**

1. Encode the certificate complexity problem as a **constraint satisfaction problem**: each basis of $M(G)$ must be distinguished, each circuit provides a "clause."

2. Use the **probabilistic analysis of CSP thresholds** (Achlioptas–Moore, 2006): the number of solutions undergoes a phase transition at a critical clause-to-variable ratio.

3. Map: bases ↔ satisfying assignments, circuits ↔ clauses. The critical ratio corresponds to the edge density threshold.

4. *Risk*: The mapping is not exact — circuit constraints are not independent in the way SAT clauses are. This strategy is more speculative but would open a deep connection to satisfiability theory.

**Recommended**: Strategy A is the primary path. Strategy C is the high-risk, high-reward path that would open a new research direction.

---

### Cross-Domain Connections

| Domain Pair | Connection | Bridge Theorem |
|---|---|---|
| Random graphs ↔ Matroid theory | Graphic matroid of $G(n,p)$ | `cert_complexity_monotone` |
| Matroid theory ↔ Information theory | Certificate = minimum distinguishing information | `cert_complexity_lower_bound_spanning_trees` |
| Statistical mechanics ↔ Combinatorics | Phase transition ↔ Sharp threshold | Friedgut's theorem applied to cert complexity |
| k-SAT threshold ↔ Certificate complexity | CSP encoding of basis distinction | Strategy C above |
| Spectral graph theory ↔ Random graphs | Laplacian eigenvalues ↔ Tree counts | Matrix Tree Theorem |

---

### Testable Predictions

**Conjecture (Sharp Threshold Value):** $c = 1$ precisely, i.e., `certComplexityThreshold n = Real.log n / n`.

**Computational Test:** For $n \in \{20, 30, 50, 100\}$, compute certificate complexity bounds for $G(n,p)$ at $p = k \cdot \ln(n)/n$ for $k \in \{0.5, 0.8, 0.9, 1.0, 1.1, 1.2, 1.5, 2.0\}$. Plot $\log(\text{cert\_complexity})$ vs $k$. The conjecture predicts convergence to a step function at $k = 1$ as $n \to \infty$.

**Falsification Criterion:** If the step occurs at $k \neq 1$ for large $n$, or if the transition window does not narrow as $O(1/\ln n)$, the conjecture is false.

---

### Mandatory Deliverables

(a) **FUTURE_DIRECTIONS.md** with 3–5 research directions. Each must include "The key insight is..." and "Why now?" At least one must bridge to a different domain (e.g., satisfiability thresholds, statistical mechanics, or information theory).

(b) **RESEARCH_PAPER.md** — a standalone scientific document. A reader with no access to the code must understand: (i) what the certificate complexity threshold conjecture is, (ii) why $c = 1$ connects to connectivity, (iii) how Friedgut's theorem applies, and (iv) what the computational experiments reveal.

(c) **ARTICLE.md** in Scientific American style — engaging and accessible. Explain phase transitions in matroid complexity to a broad audience. **TABOO**: Do not focus on formal verification or machine-checked proofs. Write about the *ideas* and their significance.

(d) A **verified algorithm** for computing certificate complexity bounds on graphic matroids, not just a theorem statement. This should be an executable computation in Lean.

(e) **demo.py** — an interactive demonstration that computes certificate complexity for random graphs $G(n,p)$ at various threshold ratios $k$, plots $\log(\text{cert\_complexity})$ vs $k$, and visually displays the predicted phase transition at $k = 1$.

---

### Depth Requirements Checklist

- [ ] At least 3 theorems with deep proof tactics (induction, by_contra, multi-step calc, rcases)
- [ ] At least 1 novel definition (`certComplexityAtLeast`, `certComplexityThreshold`, or equivalent)
- [ ] Cross-domain theorem (Kirchhoff information bound connects matroid theory ↔ information theory)
- [ ] Falsifiable conjecture with computational test (threshold value $c = 1$)
- [ ] No trivial proofs by `native_decide`, `decide`, `norm_num`, or `rfl`

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
