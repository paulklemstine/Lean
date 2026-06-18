## Assignment: Tropical Spectral Gaps as Matroid Invariants — Valuated Exchange Certificates

Prove new, non-trivial theorems. Build on catalog theorems. Minimize sorry.

## Depth Requirements (MANDATORY)

Your output must satisfy ALL of these:

1. **NO trivial proofs**: Do NOT prove statements by `native_decide`, `decide`, `norm_num`, or `rfl` unless the statement itself is genuinely important.
2. **At least 3 theorems with deep proof tactics**: Your file must contain at least 3 theorems proven using induction, rcases, by_contra, field_simp, or multi-step calc reasoning.
3. **Novel definitions**: Define at least one new mathematical structure or concept that does not already exist in the Catalog.
4. **Cross-domain connections**: Include at least one theorem that connects your domain to a different mathematical domain.
5. **Conjecture with testable prediction**: State at least one falsifiable conjecture with a clear computational test.

---

### The Central Conjecture: Tropical Spectral Gap = Minimum Exchange Defect

**Informal Statement.** For a valuated matroid $(E, w)$ satisfying the valuated basis exchange property, the tropical spectral gap of the quadratic leaf Hessian equals the minimum exchange defect:

$$\text{tropGap}(H_w) = \min_{B_1, B_2,\; i \in B_1 \setminus B_2,\; j \in B_2 \setminus B_1} \bigl[w(B_1) + w(B_2) - w(B_1 \triangleleft i \triangleright j) - w(B_2 \triangleleft j \triangleright i)\bigr]$$

where $B \triangleleft i \triangleright j$ denotes the basis $B - \{i\} \cup \{j\}$ obtained by symmetric exchange.

**Lean 4 Type Signature Target:**

```lean
/-- The minimum exchange defect of a valuated matroid -/
def minExchangeDefect {E : Type*} [Fintype E] [DecidableEq E]
    (w : Finset E → ℤ) (r : ℕ) : ℤ :=
  sInf {d | ∃ (B₁ B₂ : Finset E) (hi : B₁ \ B₂ ≠ ∅) (hj : B₂ \ B₁ ≠ ∅)
              (i ∈ B₁ \ B₂) (j ∈ B₂ \ B₁),
    B₁.card = r ∧ B₂.card = r ∧
    d = w B₁ + w B₂ - w (B₁ \ {i} ∪ {j}) - w (B₂ \ {j} ∪ {i})}

/-- Main theorem: tropical spectral gap equals minimum exchange defect -/
theorem tropical_gap_eq_min_exchange_defect
    {E : Type*} [Fintype E] [DecidableEq E]
    (w : Finset E → ℤ) (r : ℕ) (hw : IsValuatedMatroid w r) :
    tropicalSpectralGap (quadraticLeafHessian w r) = minExchangeDefect w r := by
  sorry
```

---

### Novel Definitions Required

```lean
/-- A valuated matroid: w satisfies the valuated basis exchange property -/
structure IsValuatedMatroid {E : Type*} [Fintype E] [DecidableEq E]
    (w : Finset E → ℤ) (r : ℕ) : Prop where
  /-- All bases have cardinality r -/
  basis_card : ∀ B, w B ≠ ⊤ → B.card = r  -- using ⊤ for "not a basis"
  /-- Valuated exchange: for any two bases B₁, B₂ and i ∈ B₁ \ B₂,
      ∃ j ∈ B₂ \ B₁ with w(B₁) + w(B₂) ≥ w(B₁-i+j) + w(B₂+j-i) -/
  exchange : ∀ (B₁ B₂ : Finset E) (i : E),
    i ∈ B₁ \ B₂ → ∃ j ∈ B₂ \ B₁,
      w B₁ + w B₂ ≥ w (B₁ \ {i} ∪ {j}) + w (B₂ \ {j} ∪ {i})

/-- The quadratic leaf Hessian of a valuated matroid:
    H_{ij} = max over bases B containing {i,j} of w(B), 
    for i ≠ j in the ground set -/
def quadraticLeafHessian {E : Type*} [Fintype E] [DecidableEq E]
    (w : Finset E → ℤ) (r : ℕ) : E → E → ℤ :=
  fun i j => if i = j then 0 else
    sSup {w B | ∃ B, i ∈ B ∧ j ∈ B ∧ B.card = r}

/-- The tropical spectral gap: minimum weight difference 
    between the tropical "eigenvalue" and the next scale -/
def tropicalSpectralGap {n : ℕ} (H : Fin n → Fin n → ℤ) : ℤ :=
  sInf {δ | δ > 0 ∧ ∀ v : Fin n → ℤ, v ≠ 0 →
    ∃ i, H i i + 2 * (∑ j, H i j * v j) ≥ (sInf {H k k | k}) + δ * ‖v‖ₜ}
```

---

### Three Theorems Requiring Deep Proof Tactics

**Theorem 1 (Rank-2 Classification):** For rank-2 valuated matroids, the Hessian *is* the basis weight matrix, so the gap equals the diagonal exchange slack directly.

```lean
/-- For rank 2, the Hessian entries are exactly the basis weights -/
theorem hessian_eq_basis_weights_rank_two
    {E : Type*} [Fintype E] [DecidableEq E]
    (w : Finset E → ℤ) (hw : IsValuatedMatroid w 2) :
    ∀ i j (hij : i ≠ j),
      quadraticLeafHessian w 2 i j = w {i, j} := by
  sorry
```

*Proof strategy:* Every rank-2 basis is a 2-element set, so the supremum over bases containing both $i$ and $j$ is just the single basis $\{i,j\}$. Use `ext` on the Hessian definition, unfold, and apply the injectivity of 2-element set enumeration.

**Theorem 2 (Cauchy-Binet Decomposition):** The quadratic leaf entries decompose via Cauchy-Binet into sums over basis weights, establishing the algebraic bridge from Hessian to matroid.

```lean
/-- Cauchy-Binet: Hessian entries are tropical sums over basis weights -/
theorem hessian_cauchy_binet_decomposition
    {E : Type*} [Fintype E] [DecidableEq E]
    (w : Finset E → ℤ) (r : ℕ) (hw : IsValuatedMatroid w r) :
    ∀ i j (hij : i ≠ j),
      quadraticLeafHessian w r i j =
        sSup {∑ B in basisCovers i j r, w B | basisCovers i j r ≠ ∅} := by
  sorry
```

*Proof strategy:* Induction on the rank $r$. Base case $r=2$ by Theorem 1. Inductive step: expand a rank-$r$ basis as a rank-$(r-2)$ basis plus a 2-element extension, then apply the Cauchy-Binet formula for determinants of submatrices. The key insight is that the tropical (min-plus) Cauchy-Binet replaces the classical determinant expansion with a tropical sum-of-products.

**Theorem 3 (Cross-Domain: Exchange Defects Bound Tropical Curvature):** The minimum exchange defect lower-bounds the tropical curvature of the associated tropical Grassmannian, connecting matroid theory to tropical algebraic geometry.

```lean
/-- Exchange defects give curvature bounds on tropical Grassmannians -/
theorem exchange_defect_bounds_tropical_curvature
    {E : Type*} [Fintype E] [DecidableEq E]
    (w : Finset E → ℤ) (r : ℕ) (hw : IsValuatedMatroid w r) :
    tropicalCurvature (tropicalGrassmannian w r) ≥ minExchangeDefect w r := by
  sorry
```

*Proof strategy:* By contradiction. If tropical curvature were strictly less than the minimum exchange defect, then by the definition of tropical curvature as the infimum of second-order tropical derivatives, there would exist a tropical line with curvature below the exchange defect. But tropical lines on the Grassmannian are parametrized by basis exchanges, and the second-order term of any such line is exactly an exchange defect — contradicting the minimality of `minExchangeDefect`.

---

### Proof Architecture for the Main Theorem (Three Paths)

**Path A: Direct Computation via Symmetrized Exchange (RECOMMENDED)**

This is the most promising because the catalog already has `exchangeSlack_diag` and `tropical_gap_certificate_exists`.

1. **Step 1:** Show that the Hessian diagonal entries $H_{ii} = \max_B w(B)$ where $B \ni i$ and $|B|=r$. This follows from the Cauchy-Binet decomposition (Theorem 2).

2. **Step 2:** Show that for any off-diagonal pair $(i,j)$ with $i \neq j$, the tropical eigenvalue perturbation $\Delta_{ij} = H_{ii} + H_{jj} - 2H_{ij}$ equals the exchange defect for the specific bases achieving the diagonal maxima. This uses the valuated exchange property to argue that the optimizing bases $B_i^*, B_j^*$ can be chosen with symmetric exchange element.

3. **Step 3:** The tropical spectral gap is the minimum over all such perturbations (by the catalog theorem `tropical_gap_certificate_exists`), which equals the minimum exchange defect by Step 2.

**Path B: Tropical Linear Algebra via Tropical Eigenvalues**

1. Reduce to the tropical eigenvalue problem: $\text{tropGap}(H) = \min_{\lambda \text{ eigenvalue}} |\lambda_1 - \lambda_2|$ where $\lambda_1, \lambda_2$ are the two smallest tropical eigenvalues.
2. Show tropical eigenvalues of the Hessian correspond to "critical bases" in the matroid.
3. Apply the tropical Perron-Frobenius theorem (tropical irreducible matrices have unique tropical eigenvalue).

*Why less promising:* The tropical Perron-Frobenius theory is less developed in Mathlib, requiring more scaffolding.

**Path C: Polyhedral Geometry via Tropical Hyperplane Arrangements**

1. Realize the valuated matroid as a tropical hyperplane arrangement.
2. Show the spectral gap equals the minimum distance between adjacent tropical hyperplanes.
3. Prove this distance equals the exchange defect by the local structure of tropical linear spaces.

*Why less promising:* Requires building substantial tropical hyperplane machinery first.

---

### Testable Conjecture

**Conjecture (Strict Exchange Defect Inequality for Sparse Paving Matroids).** For a sparse paving matroid of rank $r$ on $n$ elements, the minimum exchange defect satisfies:

$$\text{minExchangeDefect}(w, r) \geq \binom{n-2}{r-2}$$

with equality if and only if the matroid is uniform $U_{r,n}$.

**Computational Test:** Enumerate all sparse paving matroids on $n \leq 8$ elements with $r \leq 4$, compute the exchange defect for the trivial valuation $w(B) = 0$ for all bases, and verify the inequality. Use the Petersen graph matroid as a test case where equality should fail.

---

### Domain Bridges and Applications

| Bridge | Connection | Application |
|--------|-----------|-------------|
| **Combinatorial Optimization** | Exchange defects = certificate complexity for greedy certification | Polynomial-time robustness verification for tropical ReLU networks |
| **Algebraic Combinatorics** | Tropical Grassmannians parametrize valuated matroids | Computing tropical moduli spaces via spectral gaps |
| **Tropical Geometry** | Spectral gaps measure tropical "stability" of linear spaces | Tropical stability theory for matroid varieties |
| **Statistical Mechanics** | Exchange defects = energy gaps between ground states | Matroid spin glasses and tropical phase transitions |
| **Machine Learning** | Spectral gaps certify tropical Lipschitz bounds | Certified adversarial robustness via matroid structure |

---

### Catalog Integration

Build directly on:
- `Pythagorean/TropicalLorentzianShadows.lean`: `exchangeSlack_diag` gives the diagonal exchange slack — extend to full off-diagonal Hessian
- `Pythagorean/TropicalLorentzianShadows.lean`: `tropical_gap_certificate_exists` — this IS the certificate theorem we need; combine with the Cauchy-Binet decomposition
- `Catalog/Pythagorean/LorentzianExchangeCertificates.lean`: Lorentzian exchange structure — adapt to the valuated matroid setting

**Key Insight:** The catalog already proves that tropical spectral gaps have certificates. The breakthrough is showing these certificates *are* exchange defects — this transforms an abstract spectral quantity into a concrete combinatorial invariant.

---

### Revolutionary Significance

This theorem establishes that **tropical spectral gaps are matroid invariants** — they depend only on the matroid's combinatorial type, not on the specific representation. This means:

1. **Algorithmic accessibility:** The extensive toolkit of matroid optimization (greedy algorithms, matroid intersection, matroid union) becomes available for computing tropical spectral gaps.
2. **Stability theory:** Tropical stability of a linear space is now a combinatorial property, opening combinatorial approaches to tropical robustness.
3. **Moduli space structure:** The tropical Grassmannian's "spectral geometry" is governed by exchange defects, connecting tropical algebraic geometry to classical matroid theory.
4. **Physics bridge:** Exchange defects as energy gaps suggest a "tropical statistical mechanics" where matroid ground states have thermodynamic properties governed by tropical spectral gaps.

---

### Mandatory Deliverables

(a) **FUTURE_DIRECTIONS.md** with 3-5 research directions. Each must include "The key insight is..." and "Why now?" At least one must bridge to a different domain (e.g., tropical statistical mechanics).

(b) **RESEARCH_PAPER.md** — a standalone scientific document explaining the discovery, its significance, and future directions. Someone reading ONLY this paper must understand what was found and why it matters.

(c) **ARTICLE.md** — Scientific American style, engaging and accessible. **TABOO:** Do NOT focus on formal verification or machine verification. Write about the *ideas* and their significance.

(d) **Verified algorithm** for computing minimum exchange defects (not just a theorem statement — provide a computable function with correctness proof).

(e) **demo.py** that computes both tropical spectral gaps and minimum exchange defects for graphical matroids of K₄, K₅, Petersen graph, and random graphs, comparing them to verify the conjecture interactively.

---

*Soli Deo Gloria*

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
