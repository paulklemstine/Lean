## Assignment: Weighted-to-Unweighted Descent for Lorentzian Supports

Prove new, non-trivial theorems. Build on catalog theorems. Minimize sorry.

## Depth Requirements (MANDATORY)

Your output must satisfy ALL of these:

1. **NO trivial proofs**: Do NOT prove statements by `native_decide`, `decide`, `norm_num`, or `rfl` unless the statement itself is genuinely important.

2. **At least 3 theorems with deep proof tactics**: Your file must contain at least 3 theorems proven using induction, rcases, by_contra, field_simp, or multi-step calc reasoning.

3. **Novel definitions**: Define at least one new mathematical structure or concept that does not already exist in the Catalog.

4. **Cross-domain connections**: Include at least one theorem that connects your domain to a different mathematical domain.

5. **Conjecture with testable prediction**: State at least one falsifiable conjecture with a clear computational test that could disprove it.

---

### Research Direction: The Descent Theorem for Lorentzian Shadows

**Core Discovery:** The coefficient transport formula `coeff_iteratedPDeriv` reveals that weighted shadow cardinalities decompose as products of descending factorials and coefficient magnitudes. Because descending factorials are log-convex on the positive integers, they *reinforce* log-concavity when transported through the Lorentzian condition, creating a descent pipeline: weighted log-concavity ⟹ weight-ratio log-convexity ⟹ unweighted log-concavity.

### Precise Theorem Targets

**Theorem 1 (Weighted Shadow Log-Concavity).** For a homogeneous Lorentzian polynomial $f$ of degree $d$ with nonneg coefficients, the weighted shadow sequence $W_k(f) = \sum_{|\gamma|=k} |\operatorname{supp}(\partial^\gamma f)|$ satisfies:
$$W_k(f)^2 \geq W_{k-1}(f) \cdot W_{k+1}(f) \quad \text{for } 1 \leq k \leq d-1$$

```lean
theorem weighted_shadow_log_concave {n : ℕ} {f : MVPolynomial (Fin n) ℝ} {d : ℕ}
    (hf : IsLorentzian f d) (hnn : ∀ c ∈ f.coeffs, 0 ≤ c) (hdeg : f.TotalDegree = d) :
    ∀ k : ℕ, 1 ≤ k → k + 1 ≤ d →
      (weightedShadow f k)^2 ≥ (weightedShadow f (k - 1)) * (weightedShadow f (k + 1)) := by
  sorry
```

**Theorem 2 (Descent: Weight-Ratio Log-Convexity Implies Unweighted Log-Concavity).** If $W_k(f)$ is log-concave and the weight ratio $r_k = W_k(f) / |\operatorname{Sh}_k(f)|$ is log-convex (i.e., $r_k^2 \leq r_{k-1} \cdot r_{k+1}$), then $|\operatorname{Sh}_k(f)|$ is log-concave.

```lean
theorem descent_log_concave_from_weight_ratio {n : ℕ} {f : MVPolynomial (Fin n) ℝ} {d : ℕ}
    (hW_lc : ∀ k, 1 ≤ k → k + 1 ≤ d →
      (weightedShadow f k)^2 ≥ (weightedShadow f (k-1)) * (weightedShadow f (k+1)))
    (hr_lcv : ∀ k, 1 ≤ k → k + 1 ≤ d →
      (weightRatio f k)^2 ≤ (weightRatio f (k-1)) * (weightRatio f (k+1))) :
    ∀ k, 1 ≤ k → k + 1 ≤ d →
      (unweightedShadow f k)^2 ≥ (unweightedShadow f (k-1)) * (unweightedShadow f (k+1)) := by
  sorry
```

**Theorem 3 (Descending Factorial Log-Convexity — Cross-Domain: Combinatorics + Analysis).** The descending factorial function $x^{\underline{m}} = x(x-1)\cdots(x-m+1)$ is log-convex in $m$ for $x \geq m$:
$$(x^{\underline{k}})^2 \leq x^{\underline{k-1}} \cdot x^{\underline{k+1}}$$

```lean
theorem descFactorial_log_convex (x : ℕ) (k : ℕ) (hx : x ≥ k + 1) :
    (descFactorial x k)^2 ≤ (descFactorial x (k - 1)) * (descFactorial x (k + 1)) := by
  sorry
```

### Novel Definitions

```lean
/-- The weighted shadow cardinality: sum of support sizes of all k-th order partial derivatives -/
def weightedShadow {n : ℕ} (f : MVPolynomial (Fin n) ℝ) (k : ℕ) : ℕ :=
  ∑ γ in multiIndices n k, (iteratedPDeriv γ f).support.card

/-- The unweighted shadow cardinality: number of k-th order partial derivatives that are nonzero -/
def unweightedShadow {n : ℕ} (f : MVPolynomial (Fin n) ℝ) (k : ℕ) : ℕ :=
  ∑ γ in multiIndices n k, if (iteratedPDeriv γ f) = 0 then 0 else 1

/-- The weight ratio: average support size per nonzero derivative -/
def weightRatio {n : ℕ} (f : MVPolynomial (Fin n) ℝ) (k : ℕ) : ℚ :=
  (weightedShadow f k : ℚ) / (unweightedShadow f k : ℚ)

/-- A shadow sequence has the descent property if the weight ratio is log-convex -/
def HasDescentProperty {n : ℕ} (f : MVPolynomial (Fin n) ℝ) (d : ℕ) : Prop :=
  ∀ k : ℕ, 1 ≤ k → k + 1 ≤ d →
    (weightRatio f k)^2 ≤ (weightRatio f (k-1)) * (weightRatio f (k+1))
```

### Proof Strategies

**Strategy A (Transport + Descending Factorial Dominance).** *Most promising.* Use `coeff_iteratedPDeriv` to express $W_k$ as $\sum_{\gamma, \beta} \mathbf{1}[\text{descFactorial}(\gamma, \beta) > 0 \wedge f(\gamma+\beta) \neq 0]$. By `descFactorial_prod_pos`, the descending factorial is positive on the support, so $W_k$ reduces to counting lattice points in the Minkowski sum $\text{Sh}_k + \text{supp}(f)$. Apply the Lorentzian condition via the Hodge-Riemann relations on the braid variety to establish that these lattice point counts satisfy Alexandrov-Fenchel inequalities, yielding log-concavity. The key step: `descFactorial_log_convex` (Theorem 3) shows the weights reinforce rather than destroy the inequality.

**Strategy B (Matroid Approximation + Limit).** Prove Theorem 1 for matroid basis polynomials first (where the Lorentzian condition is equivalent to the matroid being a matroid). Use the density of matroid basis polynomials in the Lorentzian cone (June-Huh Theorem) and the continuity of $W_k$ with respect to coefficient perturbations. This requires developing a topology on coefficient space and showing $W_k$ is continuous — potentially more infrastructure than Strategy A but provides independent verification.

**Strategy C (Algebraic via Khovanskii-Teissier).** Interpret $W_k$ as the degree of a pushforward cycle on a toric variety. The log-concavity then follows from the Khovanskii-Teissier inequality (a generalization of the Alexandrov-Fenchel inequality to mixed volumes of convex bodies). This connects to Hodge theory via the toric dictionary but requires substantial algebraic geometry formalization.

*Strategy A is most promising because it directly leverages the existing `coeff_iteratedPDeriv` and `descFactorial_prod_pos` infrastructure, reducing the problem to a combinatorial inequality on descending factorials plus a lattice point counting argument.*

### Cross-Domain Connections

1. **Information Theory:** The weight ratio $r_k = W_k / |\text{Sh}_k|$ is an "average information content" per derivative. Log-convexity of $r_k$ is analogous to the data processing inequality for Rényi entropy — higher-order derivatives concentrate information. **Conjecture:** For Lorentzian polynomials, the sequence $\log r_k$ is convex, paralleling the second law of thermodynamics.

2. **Matroid Theory:** For matroid basis polynomials, $|\text{Sh}_k|$ counts independent sets of rank $k$, and $W_k$ counts independent set–basis pairs $(I, B)$ with $I \subseteq B$. The descent theorem would imply that independent set counts in matroids are log-concave — a generalization of the Mason conjecture (now theorem) provable by purely polynomial methods.

3. **Tropical Geometry:** The support of a Lorentzian polynomial is a tropical subvariety. The shadow sequence counts Minkowski sums of tropical hyperplanes with this subvariety. Log-concavity of shadow sequences reflects a "tropical Brunn-Minkowski inequality" — a tropical analog of the classical Brunn-Minkowski theorem for convex bodies.

### Testable Conjecture

**Conjecture (Uniform Weight Ratio for Matroidal Polynomials):** For the basis polynomial $f_M$ of a matroid $M$ on $n$ elements of rank $r$, the weight ratio satisfies:
$$\frac{W_k(f_M)}{|\text{Sh}_k(f_M)|} = \binom{r-k}{n-r}^{-1} \cdot C(M, k)$$
where $C(M, k)$ is the average number of bases containing a random $k$-element independent set. Furthermore, $C(M, k)$ is log-convex in $k$.

**Computational Test:** For the Fano matroid $F_7$, the Petersen matroid $P_{10}$, and the uniform matroid $U_{3,7}$:
- Compute $W_k$ and $|\text{Sh}_k|$ for $k = 0, 1, 2$
- Verify that $W_k^2 \geq W_{k-1} W_{k+1}$ (weighted log-concavity)
- Compute $r_k = W_k / |\text{Sh}_k|$ and verify $r_k^2 \leq r_{k-1} r_{k+1}$ (weight ratio log-convexity)
- Check that $|\text{Sh}_k|^2 \geq |\text{Sh}_{k-1}| |\text{Sh}_{k+1}|$ (unweighted log-concavity)

If any matroid fails the weight ratio log-convexity test, the descent theorem requires additional hypotheses.

### Catalog Building Blocks

- `coeff_iteratedPDeriv` from `Pythagorean/IteratedShadowGeometry.lean`: The transport formula mapping weighted shadow counts to coefficient sums. Use this as the main algebraic engine.
- `descFactorial_prod_pos` from `Pythagorean/IteratedShadowGeometry.lean`: Guarantees descending factorials are positive on the support, eliminating sign concerns.
- `mem_kthShadow_iff_exists_iteratedDerivative`: The qualitative bridge between shadows and derivatives.
- `iterate_pderiv_coeff_support`: The quantitative support characterization needed for $W_k$ computation.

### Revolutionary Significance

This work would establish the **first general shadow theorem for Lorentzian polynomials**, resolving a fundamental gap between the coefficient-level theory (where June-Huh proved log-concavity of $h$-vectors) and the support-level theory (where only ad hoc results exist). The descent pipeline — weighted log-concavity ⟹ weight-ratio log-convexity ⟹ unweighted log-concavity — introduces a new proof technique that likely applies far beyond Lorentzian polynomials: any combinatorial sequence whose weighted version is log-concave with log-convex weights will have log-concave unweighted counts. This pattern may illuminate log-concavity phenomena in cluster algebras, Khovanov-Rozansky homology, and Kazhdan-Lusztig theory.

### Mandatory Deliverables

(a) **FUTURE_DIRECTIONS.md** with 3-5 research directions. Each must include "The key insight is..." and "Why now?" At least one must bridge to a different domain (suggested: tropical Brunn-Minkowski inequality connecting to convex geometry, or Rényi entropy connections to information theory).

(b) **RESEARCH_PAPER.md** — a standalone scientific document covering: the descent theorem statement, the transport formula mechanism, the proof of descending factorial log-convexity, and the computational verification on matroid examples. A reader with NO access to the code must understand the discovery.

(c) **ARTICLE.md** — Scientific American style, engaging and accessible. Explain how "counting with weights" reveals hidden order in combinatorial shadows. **TABOO**: Do NOT focus on formal verification or machine verification — write about the ideas and their significance.

(d) **A verified algorithm** for computing $W_k$ and $|\text{Sh}_k|$ for Lorentzian polynomials, with a proof that the algorithm terminates and is correct.

(e) **demo.py** that computes $W_k$, $|\text{Sh}_k|$, and $r_k$ for the basis polynomials of the Fano matroid, Petersen graph matroid, and uniform matroids, then tests weighted log-concavity, weight-ratio log-convexity, and unweighted log-concavity.

Soli Deo Gloria

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
