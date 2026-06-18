## Soli Deo Gloria

## Assignment: Direction 1: Real Stability of Determinantal Polynomials and the Full Lorentzianity Bridge

Prove new, non-trivial theorems. Build on catalog theorems. Minimize sorry.

## Depth Requirements (MANDATORY)

Your output must satisfy ALL of these:

1. **NO trivial proofs**: Do NOT prove statements by `native_decide`, `decide`, `norm_num`, or `rfl` unless the statement itself is genuinely important. If the only proof tactic is enumeration, the theorem is not worth formalizing.

2. **At least 3 theorems with deep proof tactics**: Your file must contain at least 3 theorems proven using induction, rcases, by_contra, field_simp, or multi-step calc reasoning.

3. **Novel definitions**: Define at least one new mathematical structure or concept that does not already exist in the Catalog. Check the catalog references to confirm novelty.

4. **Cross-domain connections**: Include at least one theorem that connects your domain to a different mathematical domain (e.g., number theory + tropical geometry, algebra + physics).

5. **Conjecture with testable prediction**: State at least one falsifiable conjecture with a clear computational test that could disprove it.

---

### The Central Breakthrough

The determinantal polynomial $Z_K(\mathbf{x}) = \det(I + \operatorname{diag}(\mathbf{x}) \cdot K)$ for a symmetric PSD matrix $K$ is the generating polynomial of every Determinantal Point Process (DPP). Proving it is **real stable** — nonzero on the open upper half-plane $\mathbb{H}^n = \{z \in \mathbb{C}^n : \operatorname{Im}(z_i) > 0\}$ — unlocks the full Brändén–Huh bridge to Lorentzian polynomials, which in turn yields the complete cascade of Hodge-type inequalities for DPP coefficient arrays. This is the keystone arch of the entire program: without real stability, the Lorentzian recognition pathway from `LorentzianRecognitionComplete.lean` cannot be activated for DPPs.

### Novel Definition (Required)

```lean
/-- A multivariate polynomial over ℝ is real stable if it is nonzero 
    at every point in the open upper half-plane ℍ^n. 
    This is the fundamental analytic property connecting DPP theory, 
    Lee-Yang-type theorems, and Lorentzian polynomials. -/
def IsRealStable {σ : Type*} [Fintype σ] (p : MvPolynomial σ ℝ) : Prop :=
  ∀ z : σ → ℂ, (∀ i, 0 < (z i).im) → aeval z p ≠ (0 : ℂ)
```

This definition does not exist in the Catalog. It is the gateway predicate for the entire stability-to-Lorentzianity pipeline.

### Core Theorem: Real Stability of Determinantal Polynomials

**Precise Statement with Lean 4 Signature:**

```lean
/-- The determinantal polynomial of a real symmetric PSD matrix has no zeros 
    in the open upper half-plane. This is the DPP analogue of the Lee-Yang theorem 
    from statistical mechanics. -/
theorem determinantal_real_stable {n : ℕ} [Fintype (Fin n)]
    (K : Matrix (Fin n) (Fin n) ℝ)
    (hK_sym : Matrix.IsSymm K)
    (hK_psd : K.PosSemidef ℝ)
    (z : Fin n → ℂ)
    (hz : ∀ i, 0 < (z i).im) :
    (1 + Matrix.diag z * (K.map (algebraMap ℝ ℂ))).det ≠ 0 := by
```

### Proof Strategy A (Primary — Inner Product Contradiction)

This is the cleanest and most elegant route. It exploits a beautiful tension between the algebraic reality of $v^\dagger K v$ and the analytic positivity forced by $\operatorname{Im}(z_i) > 0$.

**Step 1 — Extract the null vector.** By contradiction: assume the determinant is zero. Then $\exists\, v \in \mathbb{C}^n \setminus \{0\}$ such that $(I + \operatorname{diag}(z) K_{\mathbb{C}}) v = 0$, giving $v_i = -z_i (K_{\mathbb{C}} v)_i$ for all $i$. Use `Matrix.det_eq_zero_iff_exists_cons` or the equivalence between singular matrices and nontrivial null spaces.

**Step 2 — Compute $v^\dagger K v$ two ways.** Since $z_i \neq 0$ (as $\operatorname{Im}(z_i) > 0$), we have $(Kv)_i = -v_i / z_i$. Therefore:
$$v^\dagger K v = \sum_i \overline{v_i}(Kv)_i = -\sum_i \frac{|v_i|^2}{z_i} = -\sum_i |v_i|^2 \cdot \frac{\overline{z_i}}{|z_i|^2}$$
Writing $z_i = a_i + ib_i$ with $b_i > 0$:
$$\operatorname{Im}(v^\dagger K v) = \sum_i \frac{|v_i|^2 \cdot b_i}{a_i^2 + b_i^2} > 0$$
since $v \neq 0$ implies some $|v_i|^2 > 0$ and all $b_i > 0$.

**Step 3 — Contradiction via Hermitian reality.** Since $K$ is real symmetric, $K$ is Hermitian ($K^\dagger = K$). For any Hermitian matrix $H$ and any complex vector $w$, $w^\dagger H w \in \mathbb{R}$ (proof: $(w^\dagger H w)^* = w^\dagger H^\dagger w = w^\dagger H w$). Therefore $\operatorname{Im}(v^\dagger K v) = 0$, contradicting $\operatorname{Im}(v^\dagger K v) > 0$.

**Key supporting lemma (deep proof required):**

```lean
/-- For a real symmetric (hence Hermitian) matrix K and any complex vector v,
    the quadratic form v†Kv is real. This is the algebraic fact that 
    creates the contradiction with the analytic positivity from Step 2. -/
theorem hermitian_quadratic_real {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ) 
    (hK_sym : Matrix.IsSymm K) (v : Fin n → ℂ) :
    (star v ⬝ᵥ (K.map (algebraMap ℝ ℂ)).mulVec v).im = 0 := by
```

### Proof Strategy B (Alternative — Positive Definite Hermitian Part)

Show directly that the Hermitian part $H = \frac{1}{2}(M + M^\dagger)$ of $M = I + \operatorname{diag}(z)K$ is positive definite. For any $u \neq 0$:
$$u^\dagger H u = \|u\|^2 + \operatorname{Re}(u^\dagger \operatorname{diag}(z) K u)$$
Decompose $u = \alpha w$ where $w = K^{1/2} u$ and use the PSD structure of $K$ to bound the real part. This approach is more direct but requires formalizing the Cholesky/spectral decomposition of PSD matrices, which is heavier machinery. **Strategy A is strongly preferred** because it avoids spectral theory entirely and produces a sharper, more informative contradiction.

### Proof Strategy C (Alternative — Continuity + Boundary Analysis)

For $t \in [0,1]$, consider $M(t) = I + \operatorname{diag}(\mathbf{a} + it\mathbf{b})K$ where $z = \mathbf{a} + i\mathbf{b}$. At $t = 0$, $M(0) = I + \operatorname{diag}(\mathbf{a})K$ is real symmetric with all eigenvalues $\geq 1$ (since $K$ is PSD and $\operatorname{diag}(\mathbf{a})K$ has non-negative real quadratic form). Show $\det M(t)$ never vanishes by proving $M(t)$ stays invertible, using the argument from Strategy A at each $t$. This is essentially Strategy A in a parametric coat and offers no advantage.

### Cross-Domain Bridge Theorem: Lee-Yang for DPPs

```lean
/-- The DPP generating polynomial Z_K satisfies the Lee-Yang property:
    it has no zeros in the upper half-plane. This connects the theory of 
    determinantal point processes (probability) to the Lee-Yang circle theorem 
    (statistical mechanics) and the Kac-Rice formula (random matrix theory). 
    In statistical mechanics, the Lee-Yang theorem states that the partition 
    function of a ferromagnetic Ising model has all its zeros on the unit circle 
    in the complex fugacity plane. Our result is the DPP analogue: the "partition 
    function" det(I + diag(x)K) has no zeros in the upper half-plane. -/
theorem dpp_lee_yang {n : ℕ} [Fintype (Fin n)]
    (K : Matrix (Fin n) (Fin n) ℝ)
    (hK_sym : Matrix.IsSymm K) (hK_psd : K.PosSemidef ℝ) :
    IsRealStable (determinantalPoly K) := by
```

**Domain bridges unlocked by this theorem:**
- **Probability ↔ Algebraic Geometry**: Real stability of $Z_K$ implies *negative association* for the corresponding DPP (the probability measure that assigns probability $\det(K_S)/\det(I + K)$ to subset $S$). This is the Rosetta stone connecting the analytic (stability), probabilistic (negative association), and geometric (Lorentzian/Hodge) worlds.
- **Statistical Mechanics ↔ Combinatorics**: The Lee-Yang theorem for Ising models and our DPP stability are twin manifestations of the same principle: ferromagnetic interactions produce partition functions with controlled zero loci. The common mechanism is the positive semidefiniteness of the interaction matrix.
- **Quantum Information ↔ Tropical Geometry**: PSD matrices are exactly the Choi matrices of completely positive quantum channels. The determinantal polynomial $\det(I + \operatorname{diag}(x)\Phi)$ for a quantum channel $\Phi$ being real stable would certify information-theoretic monotonicity properties under tropical limits.

### Conjecture with Testable Prediction

**Conjecture (Quantum Channel Stability):** For any completely positive trace-preserving quantum channel $\Phi : M_n(\mathbb{C}) \to M_m(\mathbb{C})$ with Kraus representation $\Phi(\rho) = \sum_i A_i \rho A_i^\dagger$, the polynomial
$$Z_\Phi(\mathbf{x}) = \det\left(I_m + \sum_i x_i A_i A_i^\dagger\right)$$
is real stable, where $x_i$ are associated with the Kraus operators.

**Computational test that could disprove it:** Generate 1000 random quantum channels (random Kraus operators satisfying $\sum_i A_i^\dagger A_i = I_n$, using the Stinespring dilation or Qiskit's `random_quantum_channel`), compute $Z_\Phi$ symbolically for small dimensions ($n = 2, 3$ with 2–4 Kraus operators), and search for zeros in $\mathbb{H}^k$ by evaluating $Z_\Phi$ at $10^4$ random points in $\{z \in \mathbb{C}^k : \operatorname{Im}(z_i) \in (0.01, 10)\}$. If any evaluation yields $|Z_\Phi(z)| < 10^{-10}$, the conjecture is falsified. This is the first step toward a non-commutative Lee-Yang theorem.

### Building on Catalog Theorems

From `Catalog/Pythagorean/LorentzianRecognitionComplete.lean`, the `IsBrandenHuhLorentzian` definition provides the recursive spectral certificate equivalence. Once real stability of $Z_K$ is established, the bridge works as follows:

1. **Homogenize**: $h_K(\mathbf{x}, t) = t^n Z_K(\mathbf{x}/t) = \det(tI + \operatorname{diag}(\mathbf{x})K)$ is homogeneous of degree $n$ with non-negative coefficients (the coefficients are elementary symmetric polynomials $e_k(\lambda_1, \ldots, \lambda_n)$ of the eigenvalues of $K$, which are non-negative since $K$ is PSD).

2. **Stability preservation under homogenization**: If $p(\mathbf{x})$ is real stable, then $t^{\deg p} p(\mathbf{x}/t)$ is real stable as a homogeneous polynomial in $(\mathbf{x}, t)$. This needs formalization.

3. **Brändén-Huh direction**: Real stable homogeneous polynomial with non-negative coefficients ⟹ Lorentzian. Apply `IsBrandenHuhLorentzian` to $h_K$.

4. **Dehomogenize**: The Lorentzian property of $h_K$ implies the Hodge-type inequalities for the coefficients $e_k$, yielding ultra log-concavity: $e_k^2 \geq \frac{k(n-k+1)}{(k-1)(n-k)} e_{k-1} e_{k+1}$.

### Revolutionary Significance

This result would be the **first formally verified proof of the Lee-Yang property for DPPs**, establishing the complete analytic-to-combinatorial pipeline:

$$K \text{ is PSD} \xRightarrow{\text{Real Stability}} Z_K \neq 0 \text{ on } \mathbb{H}^n \xRightarrow{\text{Brändén-Huh}} Z_K \text{ is Lorentzian} \xRightarrow{\text{Hodge}} \text{Ultra log-concavity of } e_k(\lambda)$$

No prior formalization of real stability for any nontrivial polynomial class exists in Lean 4 or any other proof assistant. This opens:
- **Formal DPP theory**: Certified negative association, Rayleigh monotonicity, and sampling guarantees.
- **Formal Lee-Yang program**: The template for verifying zero-free regions of partition functions across statistical mechanics.
- **Tropical Hodge theory**: The tropical limit of real stable polynomials produces tropical Lorentzian polynomials with certified margin bounds (connecting to the `certified_radius_inequality` results in the Catalog).
- **Algorithmic implications**: A PSD certificate for $K$ becomes a *stability certificate* for $Z_K$, enabling verified algorithms for DPP sampling with provable mixing time bounds.

### Required Deliverables

(a) **FUTURE_DIRECTIONS.md** with 3–5 research directions. Each must include "The key insight is..." and "Why now?" At least one must bridge to a different domain (suggested: quantum information theory, where PSD matrices are Choi matrices and stability connects to channel capacity monotonicity).

(b) **RESEARCH_PAPER.md** — A standalone scientific document. Someone reading ONLY this paper must understand: what real stability is, why determinantal polynomials of PSD matrices satisfy it, how the inner-product contradiction proof works, and what the Lorentzianity bridge unlocks. Include the full proof of the main theorem.

(c) **ARTICLE.md** — Scientific American style. Explain how the ancient tension between "algebraic reality" (Hermitian quadratic forms are real) and "analytic positivity" (the upper half-plane forces positive imaginary parts) creates an impossibility: a polynomial that *seems* like it could vanish in the upper half-plane... but never does. This is the DPP version of a deep principle from statistical physics. TABOO: Do NOT focus on formal verification machinery.

(d) **Verified algorithm**: Implement a certified real-stability checker that, given a symmetric matrix $K$, (1) verifies PSD-ness via Cholesky decomposition, (2) produces the determinantal polynomial $Z_K$, and (3) certifies real stability via the PSD certificate. The algorithm should output a computable certificate that can be independently verified.

(e) **demo.py** that: (1) generates random PSD matrices of sizes 3×3 through 6×6, (2) computes $Z_K$ symbolically, (3) samples $10^4$ random points in $\mathbb{H}^n$ and verifies $|Z_K(z)| > 0$ numerically, (4) displays the ultra log-concavity ratios $e_k^2 / (e_{k-1} e_{k+1})$ for the eigenvalue elementary symmetric polynomials, and (5) tests the Quantum Channel Stability conjecture for random quantum channels of small dimension.

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
