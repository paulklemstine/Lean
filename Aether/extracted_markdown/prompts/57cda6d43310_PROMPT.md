## Assignment: Entropy Monotonicity under Derivative Transport — A Deep Connection Between Lorentzian Geometry and Information Theory

### The Central Theorem

**Theorem (Entropy Monotonicity under Derivative Transport).** Let $p \in \mathbb{R}_{\geq 0}[x_1, \ldots, x_n]$ be a homogeneous Lorentzian polynomial of degree $d$ with M-convex support. Define the **coefficient entropy** $H(p) := -\sum_{\alpha} \bar{c}_\alpha \log \bar{c}_\alpha$ where $\bar{c}_\alpha = c_\alpha / \|p\|_1$ is the normalized coefficient distribution. Then for any coordinate $i$:

$$H(\partial_i p / \|\partial_i p\|_1) \leq H(p / \|p\|_1)$$

with equality if and only if $p$ is a product of linear forms with equal coefficients.

### Lean 4 Type Signatures

```lean
-- New definitions
def shannonEntropy {ι : Type*} [Fintype ι] (p : ι → ℝ) (hp : ∀ i, 0 ≤ p i) 
    (hsum : ∑ i, p i = 1) : ℝ := - ∑ i, p i * log (p i)

def normalizeCoeffs {n : ℕ} (c : Fin n → Fin (n + 1) → ℝ) 
    (hpos : ∀ i j, 0 ≤ c i j) : Fin n → Fin (n + 1) → ℝ :=
  fun i j => c i j / (∑ i, ∑ j, c i j)

-- Main theorem
theorem entropy_pderiv_le_entropy {n d : ℕ} (p : FormalMultilinearSeries ℝ (Fin n) ℝ)
    (hL : IsLorentzian p) (hMconvex : MConvexSupport p) (i : Fin n) :
    shannonEntropy (normalizeCoeffs (pderivCoeffs p i))
      (pderivCoeffs_nonneg hL hMconvex i)
      (pderivCoeffs_normalize_sum hL hMconvex i)
    ≤ shannonEntropy (normalizeCoeffs (coeffs p))
      (coeffs_nonneg hL) (coeffs_normalize_sum hL) := by
  sorry

-- Characterization of equality
theorem entropy_pderiv_eq_entropy_iff {n d : ℕ} (p : FormalMultilinearSeries ℝ (Fin n) ℝ)
    (hL : IsLorentzian p) (hMconvex : MConvexSupport p) (i : Fin n) :
    shannonEntropy (normalizeCoeffs (pderivCoeffs p i)) _ _ 
      = shannonEntropy (normalizeCoeffs (coeffs p)) _ _
    ↔ IsProductOfEqualLinearForms p := by
  sorry
```

### Proof Strategy (Three Paths)

**Strategy A: Log-Sum Inequality (Most Promising).** 
The coefficient transport identity from `Catalog/Pythagorean/ValuatedMConvexDifferentiation.lean` Theorem 1 gives $c'_{\beta} = c_{\beta + e_i}(\beta_i + 1)$. Apply the **log-sum inequality**: for nonneg $a_k, b_k$,
$$\sum_k a_k \log \frac{a_k}{b_k} \geq \bigl(\sum_k a_k\bigr) \log \frac{\sum_k a_k}{\sum_k b_k}$$
Set $a_\beta = c_{\beta+e_i}(\beta_i + 1)$ and $b_\beta = c_{\beta+e_i}$. The left side telescopes to $H(\bar{c}) - H(\bar{c}')$, and the right side is nonneg by the arithmetic-mean inequality. The factor $(\beta_i + 1)$ creates a "tilt" away from uniformity, guaranteeing strict entropy decrease unless all $\beta_i$ are equal on the support. **Why this works:** The log-sum inequality is *exactly* designed for this type of reweighting argument, and the transport identity provides the precise reweighting factors.

**Strategy B: Majorization and Schur Concavity.**
Show that the normalized derivative distribution $\bar{c}'$ **majorizes** the restriction of $\bar{c}$ to the shifted support: $\bar{c}' \succ \bar{c}|_{\text{supp}(\partial_i p)}$. Since Shannon entropy is Schur-concave, majorization implies entropy decrease. The majorization order follows from the Lorentzian property (2-positivity of Hessian) which forces coefficient ratios to satisfy log-concavity constraints. **Why this might work:** Majorization is the natural order for entropy comparisons, and the Lorentzian property provides exactly the log-concavity needed. **Risk:** Proving majorization from Lorentzian constraints may require delicate combinatorial arguments about the M-convex support.

**Strategy C: Free Energy and Variational Principle.**
Define the "derivative free energy" $F_i(p) = -\log \|\partial_i p\|_1 + \log \|p\|_1$ and show $F_i(p) \geq 0$ via the transport identity. Then connect to entropy through the Gibbs variational principle: $H(\bar{c}) = \log \|p\|_1 - \sum_\alpha \bar{c}_\alpha \log c_\alpha$. The derivative acts as a "cooling" operation on the coefficient distribution. **Why this is elegant:** It connects to statistical mechanics where differentiation = cooling = entropy decrease. **Risk:** The variational connection requires additional regularity.

**Recommended approach:** Start with Strategy A (log-sum inequality) for the inequality, then use Strategy C (free energy) for the equality characterization.

### Required Theorems (Deep Proof Tactics)

**Theorem 1: Log-Sum Entropy Decrease** (uses `by_contra`, `field_simp`, `calc`)
```lean
theorem log_sum_entropy_decrease {n : ℕ} (c : Fin n → ℝ) (w : Fin n → ℝ)
    (hc : ∀ i, 0 < c i) (hw : ∀ i, 0 < w i) :
    let S := ∑ i, w i * c i
    let T := ∑ i, c i
    shannonEntropy (fun i => w i * c i / S) (fun i => by positivity)
      (by -- sum normalization
        sorry)
    ≤ shannonEntropy (fun i => c i / T) (fun i => by positivity)
      (by sorry) := by
  -- Apply log-sum inequality with a = wᵢcᵢ, b = cᵢ
  -- The key calculation: H(wc/‖wc‖₁) - H(c/‖c‖₁) = -∑ (wᵢcᵢ/S) log(wᵢ/S') ≤ 0
  sorry
```

**Theorem 2: Transport Identity Entropy Bound** (uses `induction`, multi-step `calc`)
```lean
theorem transport_entropy_bound {n d : ℕ} 
    (c : (Fin n → ℕ) → ℝ) -- coefficients indexed by multi-indices
    (hc : ∀ α, 0 ≤ c α)
    (hL : lorentzian_condition c) -- 2-positivity
    (i : Fin n) :
    let c' := fun β => c (β +ᵥ Pi.single i 1) * (β i + 1)
    shannonEntropy (normalize c') ≤ shannonEntropy (normalize c) := by
  -- Decompose via Theorem 1 applied coordinatewise
  -- The (βᵢ + 1) factor is the "concentration weight"
  sorry
```

**Theorem 3: Cross-Domain — Entropy-Combinatorics Bridge** (uses `rcases`, `omega`)
```lean
-- Connection: Shannon entropy bounds the number of M-convex points
theorem mconvex_card_entropy_bound {n d : ℕ} (S : Finset (Fin n → ℕ))
    (hMconvex : IsMConvex S) (c : S → ℝ) (hc : ∀ s, 0 < c s)
    (hL : lorentzian_on S c) :
    (S.card : ℝ) ≤ Real.exp (shannonEntropy (normalize c S hc)) + 1 := by
  -- M-convexity constrains support to at most exp(H) + 1 points
  -- Uses the entropy power inequality adapted to discrete M-convex setting
  sorry
```

### Novel Definition: Derivative Entropy Tower

```lean
/-- The entropy tower of a Lorentzian polynomial: entropy at each derivative level.
    This is a new invariant that captures the "information content" of the 
    coefficient geometry as differentiation concentrates mass. -/
structure DerivativeEntropyTower (n d : ℕ) where
  tower : Fin (d + 1) → ℝ
  h_monotone : ∀ k < d, tower (k + 1) ≤ tower k
  h_nonneg : ∀ k, 0 ≤ tower k
  deriving Repr

/-- Construct the tower from a Lorentzian polynomial -/
def derivativeEntropyTower {n d : ℕ} (p : LorentzianPoly n d) : DerivativeEntropyTower n d where
  tower := fun k => shannonEntropy (normalizeCoeffs (iteratedPderivCoeffs p k))
  h_monotone := by
    intro k hk
    -- Each step: entropy of k-th derivative ≤ entropy of (k-1)-th derivative
    -- Proved by induction using transport_entropy_bound
    sorry
  h_nonneg := by
    intro k
    -- Shannon entropy is nonneg for probability distributions
    sorry
```

### Conjecture with Testable Prediction

**Conjecture (Quantitative Entropy Collapse).** For a generic Lorentzian polynomial of degree $d$ in $n$ variables with M-convex support, the total entropy decrease across the full derivative tower satisfies:

$$H(p/\|p\|_1) - H(\partial_1 \cdots \partial_n p / \|\partial_1 \cdots \partial_n p\|_1) \geq \frac{1}{2}\log\binom{n+d-1}{d-1} - \frac{d-1}{2}\log(d)$$

The lower bound is achieved by the complete homogeneous symmetric polynomial $h_d(x_1, \ldots, x_n)$, and the inequality is tight for this case.

**Computational test:** For $3 \leq n \leq 7$ and $2 \leq d \leq 5$, generate random weighted uniform matroid polynomials, compute the entropy tower, and verify the quantitative bound. The complete homogeneous symmetric polynomial should saturate the bound.

### Cross-Domain Connections

1. **Information Theory → Combinatorics:** The entropy monotonicity implies that the number of terms in a Lorentzian polynomial is bounded by $\exp(H) + 1$, giving an information-theoretic bound on M-convex set cardinality. This bridges Shannon's source coding theorem to Murota's discrete convex analysis.

2. **Statistical Mechanics → Algebraic Geometry:** The derivative tower is a "cooling process" on the coefficient distribution. The free energy $F = -\log \|p\|_1$ satisfies $F(\partial_i p) \geq F(p)$, analogous to the second law. This connects the Hodge-theoretic origins of Lorentzian polynomials (Brändén-Huh) to thermodynamic principles.

3. **Tropical Geometry → Entropy:** The tropicalization of the derivative tower concentrates on the M-convex support, and the entropy decrease corresponds to the tropicalization of the probability distribution — a bridge between tropical semiring entropy and classical Shannon entropy.

4. **Optimal Transport → Derivative Transport:** The coefficient transport identity is a discrete optimal transport map between probability distributions on M-convex sets. The entropy decrease is the transport cost in the entropy-regularized optimal transport framework.

### Application Keywords

`entropy-monotonicity`, `Lorentzian-polynomials`, `M-convex`, `derivative-tower`, `log-sum-inequality`, `information-theoretic-bounds`, `discrete-convex-analysis`, `free-energy`, `coefficient-transport`, `Schur-concavity`

### Mandatory Deliverables

(a) **FUTURE_DIRECTIONS.md** with 3-5 directions. Must include: (1) "Entropy power inequality for M-convex convolutions — the key insight is that M-convex sets form a lattice under convolution, and the entropy power inequality would give optimal bounds on joint distributions. Why now? The derivative transport identity provides the multiplicative structure needed." (2) A bridge to quantum information: "Von Neumann entropy monotonicity for quantum Lorentzian matrices — the key insight is that positive-semidefinite matrices with Lorentzian minors satisfy a quantum entropy decrease under partial trace. Why now? Recent work on quantum matroids provides the algebraic foundation." (3) A bridge to computational complexity.

(b) **RESEARCH_PAPER.md** — standalone scientific document proving entropy monotonicity for Lorentzian polynomials, with full proofs via the log-sum inequality, the equality characterization, and the quantitative bound conjecture.

(c) **ARTICLE.md** — Scientific American style: "When You Differentiate a Polynomial, Its Information Shrinks — A deep connection between the geometry of polynomials and the mathematics of information reveals that differentiation is a form of compression."

(d) **Verified algorithm:** `derivativeEntropyTower` computation with certified monotonicity check.

(e) **demo.py:** Interactive visualization of entropy towers for various Lorentzian polynomials, with computational verification of the quantitative bound conjecture for small parameters.

### Catalog Building Blocks

From `Catalog/Pythagorean/ValuatedMConvexDifferentiation.lean`:
- **Theorem 1** (`coeff_pderiv_transport`): The exact transport identity $c'_{\beta} = c_{\beta+e_i}(\beta_i+1)$ — this is the engine of the entropy decrease.
- **Theorem 2** (`pderiv_preserves_nonneg`): Nonnegativity preservation ensures we can normalize to probability distributions at each level.
- Extend these with: `entropy_decrease_via_transport`, `equality_iff_product_of_linears`, `quantitative_entropy_collapse_bound`.

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
