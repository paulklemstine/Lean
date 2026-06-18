## Assignment: Primewise Persistent Homology Detects Modularity of Calabi–Yau Threefolds

Prove new, non-trivial theorems. Build on catalog theorems. Minimize sorry.

## Depth Requirements (MANDATORY)

Your output must satisfy ALL of these:

1. **NO trivial proofs**: Do NOT prove statements by `native_decide`, `decide`, `norm_num`, or `rfl` unless the statement itself is genuinely important.

2. **At least 3 theorems with deep proof tactics**: Your file must contain at least 3 theorems proven using induction, rcases, by_contra, field_simp, or multi-step calc reasoning.

3. **Novel definitions**: Define at least one new mathematical structure or concept that does not already exist in the Catalog.

4. **Cross-domain connections**: Include at least one theorem that connects your domain to a different mathematical domain.

5. **Conjecture with testable prediction**: State at least one falsifiable conjecture with a clear computational test.

---

### Visionary Statement

The Langlands program tells us that rigid Calabi–Yau threefolds over $\mathbb{Q}$ "are" weight-4 modular forms—but detecting this correspondence requires computing $L$-functions over infinitely many primes. We propose that **persistent homology**, the workhorse of topological data analysis, provides a *finite, computable* probe of this infinite arithmetic object. Specifically, the barcode of a certain filtered complex $K_p(X)$, built from the combinatorics of $\mathbb{F}_p$-points on $X$, encodes the Hecke eigenvalue $a_p(f)$ in its persistence pairing. This would create an entirely new bridge: **arithmetic topology via computational topology**, where the "shape" of point clouds over finite fields whispers modular secrets.

---

### Precise Theorem Targets

**Definition (Arithmetic Simplicial Complex).** Let $X \subset \mathbb{P}^4_{\mathbb{Z}}$ be a rigid Calabi–Yau threefold given by a homogeneous quintic polynomial $F \in \mathbb{Z}[x_0, \ldots, x_4]$. For a good prime $p$, define $\mathrm{ASC}(X, p)$ as the filtered simplicial complex where:
- Vertices are $\mathbb{F}_p$-points of $X$ (projective, so in $\mathbb{P}^4(\mathbb{F}_p)$).
- A $k$-simplex $\{v_0, \ldots, v_k\}$ is included at filtration level $\ell$ if the points lie on a common $\ell$-codimensional linear subspace of $\mathbb{P}^4$ defined over $\mathbb{F}_p$.

```lean
/-- An arithmetic simplicial complex records the incidence structure
    of F_p-points on a projective variety, filtered by codimension
    of the smallest linear subspace containing each simplex. -/
structure ArithmeticSC where
  prime : ℕ
  hprime : Fact prime.Prime
  dim : ℕ  -- ambient projective dimension
  points : Finset (ProjectiveSpace (ZMod prime) dim)
  simplices : Finset (Finset (ProjectiveSpace (ZMod prime) dim))
  hdown_closed : ∀ σ ∈ simplices, ∀ τ ⊆ σ, τ ∈ simplices
  filtration : Finset (ProjectiveSpace (ZMod prime) dim) → ℕ
  hfiltration_codim : ∀ σ ∈ simplices,
    filtration σ = minCodimensionLinearSubspace σ points
```

**Theorem A (Barcode Recovers Betti Number).** *For any rigid Calabi–Yau threefold $X/\mathbb{Q}$ with good reduction at $p$, the degree-3 barcode of $\mathrm{ASC}(X, p)$ has exactly 2 long bars, reflecting $h^3(X) = 2$ (equivalently, $h^{2,1} = 0$).*

```lean
theorem barcode_recovers_betti_number (X : RigidCY3) (p : ℕ) [Fact p.Prime]
    [GoodReduction X p] :
    (barcode (arithmeticSC X p) 3).longBars.card = 2 := by
  sorry -- Requires: nerve theorem for ASC + rigid CY property h^{2,1}=0
```

**Theorem B (Frobenius Trace from Persistence Pairing).** *For $X$ a rigid CY3 with good reduction at $p$, the trace of Frobenius $\mathrm{Tr}(\mathrm{Frob}_p \mid H^3_{\text{ét}}(X_{\bar{\mathbb{F}}_p}, \mathbb{Q}_\ell))$ equals $p + 1 - \#X(\mathbb{F}_p) + N_p(X)$, where $N_p(X)$ is determined by the persistence pairing of the two long bars in degree 3 of $\mathrm{ASC}(X, p)$. Concretely, if the two long bars have births $b_1, b_2$ and deaths $d_1, d_2$, then $a_p(f) = (b_1 + b_2) - (d_1 + d_2) + p + 1$ modulo normalization.*

```lean
theorem frobenius_trace_from_persistence (X : RigidCY3) (p : ℕ) [Fact p.Prime]
    [GoodReduction X p] (f : ModularForm 4) [hassoc : AssociatedModularForm X f] :
    let K := arithmeticSC X p
    let bars := (barcode K 3).longBars
    let b1 := (bars.toList.get! 0).1
    let b2 := (bars.toList.get! 1).1
    let d1 := (bars.toList.get! 0).2
    let d2 := (bars.toList.get! 1).2
    heckeEigenvalue f p = (b1 + b2 : ℤ) - (d1 + d2) + (p : ℤ) + 1 := by
  sorry -- Core conjecture: persistence pairing encodes Frobenius trace
```

**Theorem C (Cross-Domain: Barcode Entropy Satisfies Data Processing Inequality).** *The Shannon entropy of a persistence barcode, viewed as a probability distribution over bar lengths, satisfies a data processing inequality: if $\phi: \mathrm{ASC}(X, p) \to \mathrm{ASC}(X, q)$ is a simplicial map induced by reduction structure, then $H(\mathrm{Bar}(\mathrm{ASC}(X, p))) \geq H(\mathrm{Bar}(\mathrm{ASC}(X, q)))$ when $q | p-1$. This connects persistent homology to information theory.*

```lean
theorem barcode_entropy_data_processing (X : RigidCY3) (p q : ℕ)
    [Fact p.Prime] [Fact q.Prime] [GoodReduction X p] [GoodReduction X q]
    (hdiv : q ∣ (p - 1))
    (φ : ASCMorphism (arithmeticSC X p) (arithmeticSC X q)) :
    barcodeEntropy (barcode (arithmeticSC X p) 3) ≥
    barcodeEntropy (barcode (arithmeticSC X q) 3) := by
  sorry -- Information-theoretic argument: filtration coarsening loses entropy
```

---

### Proof Strategies

**Strategy A (Nerve-Theoretic, for Theorem A).** The Cech nerve of the standard affine cover of $\mathbb{P}^4$ restricts to $X$ as a filtered complex. By the Nerve Theorem (which exists in Mathlib's `Topology.Cech`), the homology of this complex equals the singular homology of $X(\mathbb{C})$. Over $\mathbb{F}_p$, the étale analogue gives $H^3_{\text{ét}}$. The rigid condition $h^{2,1} = 0$ forces $h^3 = 2$, so the barcode has exactly 2 long bars. *Most promising* because it reduces to a known theorem (Nerve Lemma) plus an arithmetic input.

**Strategy B (Point-Count Decomposition, for Theorem B).** The Weil conjectures give $\#X(\mathbb{F}_p) = p^3 + \cdots + 1 - a_p$ where $a_p = \mathrm{Tr}(\mathrm{Frob}_p)$. The Euler characteristic of the ASC filtration at level $\ell$ counts points lying on $\ell$-codimensional subspaces. By Möbius inversion on the filtration, the persistence pairing decomposes $\#X(\mathbb{F}_p)$ into contributions from each bar. The two long bars in degree 3 carry exactly the $a_p$ information. *Requires careful bookkeeping with inclusion-exclusion over the incidence structure.*

**Strategy C (Information-Theoretic, for Theorem C).** The reduction map $\mathbb{F}_p \to \mathbb{F}_q$ when $q | p-1$ induces a simplicial map $\phi$ on ASCs that coarsens the filtration. By the functoriality of persistent homology, this gives an interleaving. The Shannon entropy of a barcode is a concave function of the bar-length distribution. Since $\phi$ is a deterministic channel (in the information-theoretic sense), $H(\mathrm{Bar}(K)) \geq H(\mathrm{Bar}(\phi(K)))$ by the data processing inequality for concave entropies. *Novel connection between TDA and information theory.*

Strategy A is most promising for Theorem A because it leverages existing infrastructure. Strategy C is the most groundbreaking—**it opens the door to arithmetic information theory**, where L-functions are characterized by entropy inequalities on barcodes.

---

### Cross-Domain Connections

1. **Arithmetic Geometry ↔ Topological Data Analysis**: The core bridge. Persistent homology, designed for "shape of data," now reads arithmetic invariants of varieties over finite fields.

2. **Information Theory ↔ Algebraic Geometry** (Theorem C): Barcode entropy satisfies data-processing inequalities, making L-functions into "channels" and barcodes into "codes." This suggests a **Shannon theorem for arithmetic varieties**: the capacity of the "modularity channel" is bounded by the weight and level.

3. **Quantum Topology ↔ Persistent Homology**: The Reshetikhin–Turaev invariants of 3-manifolds can be expressed via persistent homology of state-sum complexes. For CY3s, this connects quantum invariants to arithmetic L-functions—a **persistent homological route to quantum modularity**.

4. **Tropical Geometry**: The ASC filtration can be tropicalized, yielding a min-plus barcode. Tropical persistent homology should satisfy a **tropical isometry theorem**: the tropical barcode is the log-limit of the classical barcode. This connects to mirror symmetry for CY3s via the tropical SYZ fibration.

---

### Conjecture with Testable Prediction

**Conjecture (Primewise Rigidity Detects Modularity).** *Let $X$ be a rigid CY3 over $\mathbb{Q}$ with good reduction outside $S$. Define the persistence spectral sequence $\{E^{p,q}_r(X)\}$ from the ASC filtration. If $X$ is modular with associated form $f \in S_4(\Gamma_0(N))$, then the persistence pairing function $\kappa_X: p \mapsto \text{pairing type of Bar}_3(\mathrm{ASC}(X,p))$ is uniquely determined by $N$ among all weight-4 newforms of level $\leq N^2$. If $X$ is NOT modular, then $\kappa_X$ fails the Hasse-boundedness condition: there exist infinitely many $p$ where the bar-length ratio exceeds $2\sqrt{p}$.*

**Computational Test**: Compute $\mathrm{ASC}(X, p)$ and its barcode for the Schoen quintic $x_0^5 + x_1^5 + x_2^5 + x_3^5 + x_4^5 - 5\psi x_0 x_1 x_2 x_3 x_4 = 0$ at primes $p = 7, 11, 13, 17, 19, 23$. Extract the persistence pairing. Compare with $a_p(f)$ for the associated form of weight 4 and level 25. The conjecture predicts exact recovery of $a_p$ from the pairing. Then test on a non-modular candidate (if one can be constructed) and verify the Hasse-boundedness failure.

```python
# In demo.py: compute ASC barcodes for CY3 reductions and compare with Hecke eigenvalues
```

---

### Application Keywords

`persistent-homology`, `calabi-yau`, `modularity`, `langlands`, `barcodes`, `frobenius`, `hecke-eigenvalues`, `arithmetic-geometry`, `topological-data-analysis`, `information-theory`, `L-functions`, `étale-cohomology`, `cech-complex`, `filtration-entropy`

---

### Mandatory Deliverables

(a) **FUTURE_DIRECTIONS.md** with 3–5 directions. Each must include "The key insight is…" and "Why now?" At least one must bridge to a different domain (suggest: quantum error-correcting codes via barcode entropy).

(b) **RESEARCH_PAPER.md** — standalone scientific document. A reader with NO access to the code must understand: what was discovered, why it matters for arithmetic geometry and TDA, and what to investigate next. Include the barcode–Hecke eigenvalue correspondence theorem and its proof sketch.

(c) **ARTICLE.md** — Scientific American style. Engaging, accessible. Explain how "the shape of point clouds over finite fields whispers modular secrets." **TABOO**: Do NOT focus on formal verification or machine verification—write about the ideas and their significance.

(d) **Verified algorithm**: A computable function `ascBarcode (equations : List (MvPolynomial (Fin 5) ℤ)) (p : ℕ) : Barcode` that constructs the arithmetic simplicial complex and computes its barcode, with a correctness theorem relating the output to Betti numbers.

(e) **demo.py** that: (1) constructs ASC for the Fermat quintic CY3 over F_p for small primes, (2) computes persistence barcodes, (3) compares bar-length pairings with known Hecke eigenvalues $a_p$ for the associated modular form, (4) visualizes the correspondence, and (5) tests the Hasse-boundedness conjecture on candidate non-modular varieties.

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

Research domain: Speculative
Research mode: prove
