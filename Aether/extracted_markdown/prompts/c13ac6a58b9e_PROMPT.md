## Soli Deo Gloria

## Assignment: Hessian-Based Lorentzian Gap from MvPolynomial Infrastructure

Prove new, non-trivial theorems. Build on catalog theorems. Minimize sorry.

## Depth Requirements (MANDATORY)

Your output must satisfy ALL of these:

1. **NO trivial proofs**: Do NOT prove statements by `native_decide`, `decide`, `norm_num`, or `rfl` unless the statement itself is genuinely important. If the only proof tactic is enumeration, the theorem is not worth formalizing.

2. **At least 3 theorems with deep proof tactics**: Your file must contain at least 3 theorems proven using induction, rcases, by_contra, field_simp, or multi-step calc reasoning.

3. **Novel definitions**: Define at least one new mathematical structure or concept that does not already exist in the Catalog. Check the catalog references to confirm novelty.

4. **Cross-domain connections**: Include at least one theorem that connects your domain to a different mathematical domain (e.g., number theory + tropical geometry, algebra + physics).

5. **Conjecture with testable prediction**: State at least one falsifiable conjecture with a clear computational test that could disprove it.

---

## Research Direction: Hessian-Based Lorentzian Gap from MvPolynomial Infrastructure

### Core Mathematical Insight

For a free-fermionic ground state with correlation matrix $K$ (symmetric, positive semidefinite, eigenvalues in $[0,1]$), the measurement distribution $\mu(S) = \det(K_S)$ is a **determinantal point process (DPP)**. Its generating polynomial:

$$P_\mu(z) = \sum_{S \subseteq [n]} \det(K_S) \prod_{i \in S} z_i = \det(I + (\text{diag}(z) - I)K)$$

has a Hessian at $z = \mathbf{1}$ with an exquisitely constrained structure:

$$H_{ij} = \frac{\partial^2 P}{\partial z_i \partial z_j}\bigg|_{z=\mathbf{1}} = K_{ii}K_{jj} - K_{ij}^2 = \det\begin{pmatrix} K_{ii} & K_{ij} \\ K_{ji} & K_{jj} \end{pmatrix}$$

In matrix form: $H = \mathbf{d}\mathbf{d}^T - K \odot K$ where $\mathbf{d} = \text{diag}(K)$ and $\odot$ is the Hadamard product. This is the **matrix of $2 \times 2$ principal minors** of $K$.

**The Lorentzian gap conjecture**: When $K$ arises from a gapped free-fermionic Hamiltonian with gap $\Delta$, the Hessian $H$ has at most one positive eigenvalue (Lorentzian signature), and the gap between the largest and second-largest eigenvalue of $H$ is bounded below by $\Omega(\Delta^2 / n)$.

This transforms the abstract `GappedMeasurementLift` certificate into a **computable spectral invariant** of a concrete polynomial.

---

### Precise Theorem Targets (Lean 4 Type Signatures)

**Definition 1: Determinantal Point Process Distribution**
```lean
/-- A determinantal point process (DPP) with kernel K assigns probability det(K_S) 
    to subset S, normalized by det(I + K). -/
structure DPP (n : ℕ) where
  K : Matrix (Fin n) (Fin n) ℝ
  hK_sym : K.IsSymm
  hK_pos : K.PosSemidef
  hK_bounded : ∀ i, K i i ∈ Icc 0 1
```

**Definition 2: Generating Polynomial of a Distribution**
```lean
/-- The generating polynomial P_μ(z) = Σ_S μ(S) · Π_{i∈S} z_i -/
def generatingPolynomial {n : ℕ} (μ : (Fin n → Bool) → ℝ) : MvPolynomial (Fin n) ℝ :=
  ∑ S, μ S • ∏ i in Finset.filter (fun i => S i) Finset.univ, MvPolynomial.X i
```

**Definition 3: Hessian Matrix at a Point**
```lean
/-- Hessian matrix of a multivariate polynomial at a point -/
def hessianAt {n : ℕ} (P : MvPolynomial (Fin n) ℝ) (z : Fin n → ℝ) : Matrix (Fin n) (Fin n) ℝ :=
  fun i j => (MvPolynomial.eval z) (MvPolynomial.pderiv j (MvPolynomial.pderiv i P))
```

**Theorem 1 (DPP Generating Polynomial Identity):**
```lean
theorem dpp_generating_polynomial_eq_det {n : ℕ} (dpp : DPP n) :
  generatingPolynomial (dppMeasure dpp.K) = 
    MvPolynomial.map (fun z => z - 1) (detPolynomial dpp.K)
  -- where detPolynomial K z = det(I + diag(z) · K)
  -- This is the Cauchy-Binet expansion of det(I + ZK) in the variables z_i
```

**Theorem 2 (Hessian = Principal Minor Matrix):**
```lean
theorem hessian_eq_principal_minors {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ) 
    (hK : K.IsSymm) :
  hessianAt (generatingPolynomial (dppMeasure K)) 1 = 
    fun i j => K i i * K j j - K i j * K j i
  -- i.e., H = d·dᵀ - K ⊙ Kᵀ where d = diag(K)
  -- Proof uses Jacobi's formula for ∂det(A)/∂x
```

**Theorem 3 (Lorentzian Signature of Gapped DPPs):**
```lean
theorem dpp_lorentzian_signature {n : ℕ} (dpp : DPP n) 
    (h_gap : spectralGap dpp.K ≥ Δ) (hΔ : Δ > 0) :
  -- H = hessianAt P 1 has at most one positive eigenvalue
  -- Equivalently: ∀ v w, vᵀHv > 0 → wᵀHw > 0 → ∃ c > 0, w = c · v
  -- (The positive eigenspace is 1-dimensional)
  sorry
```

**Theorem 4 (Quantitative Lorentzian Gap — Main Result):**
```lean
theorem dpp_lorentzian_gap_bound {n : ℕ} (dpp : DPP n) 
    (h_gap : spectralGap dpp.K ≥ Δ) (hΔ : Δ > 0) (hn : 0 < n) :
  let H := hessianAt (generatingPolynomial (dppMeasure dpp.K)) 1
  let λ₁ := H.maxEigenvalue  -- largest eigenvalue
  let λ₂ := H.secondLargestEigenvalue  -- second largest
  -- ∃ C > 0, λ₁ - λ₂ ≥ C * Δ² / n
  -- The Lorentzian gap is Ω(Δ²/n)
  sorry
```

**Theorem 5 (Cross-Domain: DPP Diversity ↔ Spectral Gap):**
```lean
/-- The Lorentzian gap controls the diversity of DPP samples.
    This connects quantum many-body physics to machine learning diversity metrics. -/
theorem lorentzian_gap_implies_diversity {n : ℕ} (dpp : DPP n) 
    (h_gap : spectralGap dpp.K ≥ Δ) :
  -- The expected number of distinct elements in k independent DPP samples
  -- is bounded below by a function of the Lorentzian gap
  -- This bridges: spectral gap physics ↔ DPP diversity in ML
  sorry
```

---

### Proof Strategies

**Strategy A: Jacobi's Formula + Hadamard Product Spectral Theory (RECOMMENDED)**

This is the most direct path to formalization:

1. **Step 1 — Cauchy-Binet for the generating polynomial**: Prove $P_\mu(z) = \det(I + \text{diag}(z - \mathbf{1}) \cdot K)$ by expanding the determinant via Cauchy-Binet. Each subset $S$ contributes $\det(K_S) \cdot \prod_{i \in S} z_i$. This is a well-known identity in DPP theory but requires careful formalization with `MvPolynomial`.

2. **Step 2 — Hessian via Jacobi's formula**: Use the matrix derivative identity $\frac{\partial}{\partial z_i} \det(A(z)) = \det(A) \cdot \text{tr}(A^{-1} \frac{\partial A}{\partial z_i})$. At $z = \mathbf{1}$, $A = I$ and $\frac{\partial A}{\partial z_i} = E_{ii} K$ (where $E_{ii}$ is the matrix with 1 in position $(i,i)$). The second derivative gives $H_{ij} = K_{ii}K_{jj} - K_{ij}K_{ji}$ via the identity $\text{tr}(E_{ii}K \cdot E_{jj}K) = K_{ij}K_{ji}$.

3. **Step 3 — Spectral analysis of $H = \mathbf{d}\mathbf{d}^T - K \odot K$**: Write $H = \mathbf{d}\mathbf{d}^T - K^{\odot 2}$ (Hadamard square). When $K$ has a spectral gap $\Delta$, its eigenvalues cluster near 0 and 1. The rank-1 matrix $\mathbf{d}\mathbf{d}^T$ provides the dominant positive eigenvalue, while $K^{\odot 2}$ contributes negative eigenvalues. Use Weyl's inequality to bound the spectral gap: if $K$ has $k$ eigenvalues in $[1-\epsilon, 1]$ and $n-k$ in $[0, \epsilon]$, then $\lambda_1(H) \geq k(1-\epsilon)^2 - n\epsilon^2$ and $\lambda_2(H) \leq C \epsilon$ for appropriate constants.

**Strategy B: Stable Polynomial Theory (Most Elegant)**

1. Prove $P_\mu$ is **stable** (no zeros in the open positive orthant $\mathbb{R}_{>0}^n$) because $\det(I + \text{diag}(z-1)K) \neq 0$ when $z_i > 0$ and $K \succeq 0$.
2. Apply Brändén-Huh theory: stable polynomials are Lorentzian, which directly gives the 1-positive-eigenvalue property.
3. For the quantitative gap, use the **inverse stability** bound: the distance from $P_\mu$ to the zero set in the positive orthant is bounded below by a function of the spectral gap of $K$.

*Why Strategy A is more promising*: Strategy B requires formalizing the Brändén-Huh theory of stable/Lorentzian polynomials, which is a major undertaking. Strategy A works with concrete linear algebra that Mathlib already supports.

**Strategy C: Perturbation from Zero Temperature (Connects to Catalog)**

1. At zero temperature with gap $\Delta$, $K$ has eigenvalues exactly 0 or 1 (after diagonalization). In this case, $H$ has a clean block structure and the Lorentzian gap is exactly computable.
2. Use the catalog's `RobustLorentzianCertificate` and perturbation theory to extend to finite temperature.
3. The gap degrades as $O(\Delta^2/n)$ under perturbation.

*This connects directly to existing infrastructure but gives weaker quantitative bounds.*

---

### Catalog Building Blocks

From `Catalog/Pythagorean/QuantumLorentzianBridge.lean`:
- `GappedMeasurementLift`: The abstract certificate we are making concrete
- `RobustLorentzianCertificate`: Use for the perturbation argument in Strategy C

From `Catalog/Bridges/Catalog/Pythagorean/RobustLorentzianSampling.lean`:
- `HasGappedSignature`: Typeclass for quadratic forms with gapped signature — instantiate for our Hessian $H$
- `QuadFormBound`: Bounds on quadratic forms — apply to get the $\Omega(\Delta^2/n)$ bound

From `Catalog/Pythagorean/LorentzianSpectralGap.lean`:
- Spectral gap infrastructure: `spectralGap`, eigenvalue bounds — use for the gap computation in Theorem 4

---

### Conjecture with Testable Prediction

**Conjecture (Tight Lorentzian Gap for TFIM)**: For the transverse-field Ising model on $n$ qubits with coupling $J$ and field $h$, the Lorentzian gap of the measurement distribution satisfies:

$$\lambda_1(H) - \lambda_2(H) \geq \frac{4\Delta^2}{n^2}$$

where $\Delta = 2|J - h|$ is the spectral gap of the single-particle Hamiltonian.

**Test**: Compute $H$ for the TFIM on $n = 3, 4, 5, 6$ qubits for various $(J, h)$ values. Plot $\lambda_1 - \lambda_2$ vs $\Delta^2/n^2$ and verify the linear bound. The constant 4 is falsifiable — if the ratio drops below 4 for any tested system, the conjecture is false.

**Falsification criterion**: Find any $(n, J, h)$ with $n \leq 10$ where $(\lambda_1 - \lambda_2) \cdot n^2 / \Delta^2 < 4$.

---

### Revolutionary Significance

This work establishes the first **computable Lorentzian invariant** for quantum measurement distributions. The implications cascade across three fields:

1. **Quantum many-body physics**: The Lorentzian gap becomes a *measurable* diagnostic for phase structure. Unlike abstract certificates, $H = \mathbf{d}\mathbf{d}^T - K^{\odot 2}$ can be computed from experimental correlation data. This opens the door to experimental verification of Lorentzian phase transitions.

2. **Machine learning**: DPPs are fundamental diversity-promoting distributions in ML. The Lorentzian gap directly controls the **sample complexity of diverse sampling** — a larger gap means fewer samples are needed to cover the diversity of the DPP. This connects spectral gaps in quantum Hamiltonians to algorithmic efficiency in ML.

3. **Algebraic combinatorics**: The identity $H = \mathbf{d}\mathbf{d}^T - K^{\odot 2}$ reveals that the Hessian of a DPP generating polynomial at $\mathbf{1}$ is a **rank-1 perturbation of a Hadamard square**. This is a new structural result about principal minor matrices that may generalize beyond DPPs to arbitrary polynomials with determinantal structure.

---

### Mandatory Deliverables

(a) **FUTURE_DIRECTIONS.md** with 3-5 research directions. Each must include "The key insight is..." and "Why now?" At least one direction must bridge to a different domain. Suggested directions:
   - *From Hessian to Higher Derivatives*: The key insight is that the $k$-th derivative tensor of $P_\mu$ at $\mathbf{1}$ equals the matrix of $k \times k$ principal minors of $K$, and the Lorentzian property extends to higher-order hyperbolicity cones. Why now? Because the catalog already has `HasGappedSignature` which generalizes to higher-order signatures.
   - *Tropical DPPs and Min-Plus Generating Functions*: The key insight is that replacing $\det$ with the tropical determinant (permanant under min-plus) yields a tropical generating polynomial whose "Hessian" is the min-plus principal minor matrix. Why now? Because tropical algebra connects to the EML catalog infrastructure.
   - *DPP Diversity and Information Theory*: The key insight is that the Lorentzian gap lower-bounds the Rényi entropy of the DPP, connecting spectral physics to information-theoretic diversity. Why now? Because the catalog has information-theoretic infrastructure from the Pythagorean work.

(b) **RESEARCH_PAPER.md** — A standalone scientific document explaining the Hessian-Lorentzian correspondence, the DPP generating polynomial identity, the quantitative gap bound, and the diversity application. Someone reading ONLY this paper must understand what was discovered and why it matters.

(c) **ARTICLE.md** — Written in Scientific American style. Explain how the Hessian of a polynomial built from quantum correlations reveals a hidden "Lorentzian" structure — a single direction in which the polynomial curves upward — and how the gap between this direction and all others is controlled by the quantum system's spectral gap. TABOO: Do NOT focus on formal verification.

(d) **A verified algorithm**: Implement the computation of $H = \mathbf{d}\mathbf{d}^T - K^{\odot 2}$ from a DPP kernel $K$, and verify that the eigenvalue gap satisfies the bound for gapped systems.

(e) **demo.py**: Interactive demonstration showing:
   - Construction of the TFIM correlation matrix for $n = 3, 4, 5$ qubits
   - Computation of $H$ and its eigenvalues
   - Visualization of the Lorentzian gap as a function of the Hamiltonian gap $\Delta$
   - Comparison with the $\Omega(\Delta^2/n)$ bound

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
