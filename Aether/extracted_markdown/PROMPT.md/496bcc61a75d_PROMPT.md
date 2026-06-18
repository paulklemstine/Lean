Soli Deo Gloria

## Assignment: Direction 4 — Quantum DPPs and Entanglement Bounds via Lorentzian Geometry

**Mode:** `prove`

Aristotle, this is not an incremental extension. This is a chance to build a genuinely new bridge between **quantum information theory**, **determinantal probability**, and **Lorentzian polynomial geometry**. The central ambition is to extract **entanglement witnesses** from the purely algebraic geometry of the DPP partition polynomial. If successful, this would turn Hessian-signature data of a generating polynomial into a computable proxy for quantum correlations.

Build on:
- `Pythagorean/DPPLorentzian.lean`  
  in particular the existing definitions of DPP kernels and their partition function `Z_K`.

Your task is to formalize a mathematically precise version of the entropy–Lorentzian-signature principle, prove several nontrivial theorems around it, and implement a verified computational pipeline that tests the conjectural bridge on explicit kernels.

---

## Central Vision

For a positive semidefinite kernel `K`, the DPP partition polynomial
\[
Z_K(z_1,\dots,z_n)=\det(I+\mathrm{Diag}(z)\,K)
\]
encodes occupation statistics of a fermionic Gaussian state with correlation kernel `K`. Lorentzian geometry of `Z_K` controls its mixed Hessian signatures after differentiation. Quantum information, meanwhile, measures bipartite entanglement from the spectrum of compressed correlation matrices. The breakthrough target is to show that **Lorentzian Hessian positivity data constrains entanglement entropy from below or above** in a structurally meaningful way.

This would open a new program:

- **computable entanglement witnesses from polynomial geometry**,
- **new spectral inequalities for free fermions**,
- **a Lorentzian approach to many-body complexity**, and
- a route from **combinatorial generating functions** to **quantum information bounds**.

Application keywords: `quantum information`, `fermionic Gaussian states`, `entanglement entropy`, `determinantal point processes`, `Lorentzian polynomials`, `Hessian signatures`, `spectral majorization`, `free fermions`, `correlation matrices`, `entanglement witnesses`, `algebraic statistics`, `statistical mechanics`.

---

## Precise Formal Target

You should introduce a mathematically clean finite-dimensional model in Lean that does **not** require the full analytic machinery of infinite-dimensional quantum mechanics. Work with finite index type `ι` and kernels as symmetric real matrices or Hermitian complex matrices, depending on what is already most feasible from Mathlib and the catalog.

The most promising formal path is to define a **proxy entropy functional** from eigenvalues of a principal compression of `K`, and then prove rigorous inequalities connecting it to Hessian-signature invariants of `Z_K`.

### New definitions you should introduce

At least one of these must be genuinely new in the codebase:

1. `hessianPosIndexAtLeaf`  
   The number of positive eigenvalues of the Hessian of a derivative leaf of `Z_K`.

2. `leafSignatureProfile`  
   The multiset/list of Hessian positive indices over all derivative leaves of fixed codimension.

3. `binaryEntropy` and `fermionicEntropy`  
   \[
   h(x) = -x\log x -(1-x)\log(1-x), \quad
   S_A(K)=\sum_i h(\lambda_i(K_A))
   \]
   where `K_A` is a principal submatrix/compression.

4. `lorentzianEntanglementWitness`
   A scalar extracted from the leaf signature profile, designed to bound or correlate with `fermionicEntropy`.

5. `balancedBipartitions`
   A finite family of subsets used for computational testing.

These definitions create the new structure the assignment requires.

---

## Precise theorem statements

You must prove at least 3 substantial theorems. The statements below are the right scale.

### Theorem 1: Monotonicity of entropy under principal extension
This is the cleanest rigorous anchor: entropy should increase when enlarging the subsystem, provided the compressed kernel remains in the fermionic regime `0 ≤ K ≤ I`.

**Mathematical statement**
For a PSD contraction kernel `K`, if `A ⊆ B`, then
\[
S_A(K) \le S_B(K).
\]

This is a genuine quantum-information theorem in finite free-fermion language and gives the entropy side a solid formal foundation.

**Lean 4 target signature (schematic)**
```lean
theorem fermionicEntropy_mono_of_subset
  {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ)
  (hKsymm : K.IsSymm)
  (hKpsd : Matrix.PosSemidef K)
  (hKle1 : ∀ v, quadraticForm K v ≤ ‖v‖^2)
  {A B : Finset (Fin n)}
  (hAB : A ⊆ B) :
  fermionicEntropy K A ≤ fermionicEntropy K B
```

If the exact spectral hypotheses are easier to state using eigenvalue bounds of principal submatrices, do that instead. Precision matters more than elegance.

### Theorem 2: Derivative-leaf Hessian has at most one positive direction
This should crystallize the Lorentzian side. For a Lorentzian polynomial, degree-2 derivative leaves have Hessians with Lorentzian signature, i.e. at most one positive eigenvalue. If `DPPLorentzian.lean` already gives Lorentzianity of `Z_K`, exploit it ruthlessly.

**Mathematical statement**
If `Z_K` is Lorentzian, then for every derivative leaf `∂^α Z_K` of degree 2, its Hessian has positive index at most 1:
\[
\forall \alpha,\ |\alpha|=\deg(Z_K)-2 \implies \operatorname{posIndex}(\nabla^2 \partial^\alpha Z_K)\le 1.
\]

**Lean 4 target signature (schematic)**
```lean
theorem hessianPosIndexAtLeaf_le_one
  {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ)
  (hLor : IsLorentzian (dppPartitionPolynomial K)) :
  ∀ α : Fin n → ℕ,
    derivLeafDegreeTwo (dppPartitionPolynomial K) α →
    hessianPosIndexAtLeaf (dppPartitionPolynomial K) α ≤ 1
```

This theorem is conceptually crucial: it turns Lorentzian geometry into a concrete spectral restriction.

### Theorem 3: A rigorous entropy witness from nontrivial leaf signature
You likely cannot fully prove the original conjectured lower bound in one leap. Instead, prove a mathematically sharp **witness theorem**: if some principal `2×2` compression exhibits a strictly positive mixed curvature invariant, then the corresponding subsystem entropy is nonzero. This is already a new bridge.

**Mathematical statement**
Let `A = {i,j}`. If the degree-2 derivative leaf corresponding to complement variables has Hessian with a positive eigenvalue / nonzero determinant / strictly negative discriminant in the Lorentzian sense, then the two-mode compressed kernel is not pure, hence
\[
S_A(K) > 0.
\]

Equivalently: nontrivial Lorentzian curvature on a leaf forces nonzero local fermionic entropy.

**Lean 4 target signature (schematic)**
```lean
theorem positive_leaf_curvature_implies_positive_entropy_pair
  {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ)
  (hKsymm : K.IsSymm)
  (hKpsd : Matrix.PosSemidef K)
  (hK01 : spectrumInUnitInterval K)
  {i j : Fin n} (hij : i ≠ j)
  (hcurv : 0 < leafCurvaturePairWitness (dppPartitionPolynomial K) i j) :
  0 < fermionicEntropy K ({i, j}.toFinset)
```

This is a real theorem, not merely a correlation statement, and it directly links algebraic geometry to quantum information.

---

## Strong conjectural target

After proving the rigorous core theorems above, formulate and computationally test the stronger bridge:

### Conjecture: Lorentzian signature lower-bounds bipartite entropy complexity
For every finite fermionic Gaussian state with correlation kernel `K` satisfying `0 ≤ K ≤ I`,
\[
\min_{A \in \mathcal B_n} S_A(K)
\;\ge\;
c_n \cdot \max_{\alpha \in \mathcal L_{n-2}} \operatorname{posIndex}\!\left(\nabla^2 \partial^\alpha Z_K\right),
\]
or at least a monotone variant such as
\[
\min_{A \in \mathcal B_n} S_A(K) > 0
\quad\Longleftarrow\quad
\max_{\alpha \in \mathcal L_{n-2}} \operatorname{posIndex}\!\left(\nabla^2 \partial^\alpha Z_K\right)=1.
\]

Here `\mathcal B_n` denotes balanced bipartitions and `\mathcal L_{n-2}` derivative leaves of degree 2.

If the direct lower bound is false, find the correct normalization or produce a counterexample. Either outcome is scientifically valuable.

**Computationally falsifiable prediction**
For random PSD contractions `K` of small sizes `n = 3,4,5,6`, the statistic
\[
\min_A S_A(K)
\]
should positively correlate with
\[
\max_\alpha \operatorname{posIndex}(\nabla^2 \partial^\alpha Z_K)
\quad\text{or with}\quad
\sum_\alpha \mathbf 1[\operatorname{posIndex}=1].
\]
Your `demo.py` must compute this on random and structured examples.

---

## Proof architecture: 3 viable strategies

You must include real proof tactics: induction, `rcases`, `by_contra`, `field_simp`, multi-step `calc`, spectral decompositions, principal-minor arguments. Avoid toy proofs.

### Strategy A: Principal-minor / generating-polynomial route
**Most promising for formalization.**

1. Express coefficients and derivative leaves of `Z_K` in terms of principal minors of `K` using determinant identities already available from the DPP file.
2. Identify degree-2 leaves explicitly as quadratic forms on pairs of coordinates; compute their Hessians by coefficient extraction.
3. Use Lorentzianity from the catalog to deduce the Hessian signature restriction; then use principal-minor inequalities to infer nontriviality of two-mode compressed kernels and positive entropy.

Why this is promising:
- It stays finite-dimensional and algebraic.
- It leverages exactly the catalog object `dppPartitionPolynomial`.
- Hessians of quadratic leaves are easier to control than general leaves.

### Strategy B: Spectral route via compressed correlation matrices
1. Define `fermionicEntropy` from eigenvalues of principal compressions.
2. Prove monotonicity and positivity properties using interlacing of eigenvalues for principal submatrices.
3. Relate leaf Hessians to `2×2` principal minors and then to eigenvalue gaps of compressed kernels.

Why it matters:
- This gives the quantum-information side in a standard spectral language.
- It creates reusable infrastructure for later free-fermion formalization.

Technical challenge:
- Formal spectral theory may be heavier in Lean than the principal-minor route.

### Strategy C: Exterior algebra / Gaussian-state covariance route
1. Reinterpret `Z_K` as a grand-canonical partition function of occupation observables.
2. Show derivative leaves encode low-order correlation tensors.
3. Bound entropy through fluctuation witnesses derived from these tensors.

Why this is visionary:
- It aligns the theorem with physics most transparently.
- It suggests extensions to bosons, matchgates, and tensor networks.

Why it is less promising immediately:
- Too much analytic and representation-theoretic overhead for one cycle.

**Recommendation:** Make Strategy A the backbone, use pieces of Strategy B for entropy monotonicity and computational validation.

---

## Cross-domain connections you must explicitly develop

At least one theorem and one discussion section must bridge domains. Do not leave this implicit.

### 1. Quantum information ↔ algebraic geometry
The derivative-leaf Hessian signature of `Z_K` is a projective-algebraic invariant, while `fermionicEntropy` is a quantum-information invariant. A theorem connecting them is a new type of entanglement witness.

### 2. Statistical mechanics ↔ combinatorics
`Z_K` is both a DPP generating polynomial and a free-fermion partition function. Principal minors count occupancy statistics; Hessian geometry encodes fluctuation constraints.

### 3. Spectral graph theory ↔ many-body physics
For kernels arising from graph Laplacians, projection kernels, or band matrices, entanglement bounds become graph-structural statements. This opens algorithmic applications in network science and condensed matter.

### 4. Information theory ↔ Lorentzian geometry
Lorentzianity imposes negative dependence and concavity-type constraints; entropy measures uncertainty and correlation. Their interaction could seed a new “Lorentzian information theory.”

---

## Concrete subgoals for the Lean development

You should aim for a file containing at least:

1. A new definition of `fermionicEntropy`.
2. A new definition of `hessianPosIndexAtLeaf` or a computable surrogate.
3. A theorem proving entropy monotonicity under subsystem inclusion.
4. A theorem proving the degree-2 leaf Hessian positive index is at most one.
5. A theorem linking a nontrivial leaf curvature witness to positive two-mode entropy.
6. One explicit worked family:
   - diagonal kernels,
   - rank-one kernels,
   - projection kernels,
   - or Toeplitz/band kernels.

The explicit family theorem is important because it grounds the conjecture and gives `demo.py` something interpretable.

---

## Suggested theorem for an explicit family

### Theorem 4: Diagonal kernel exact entropy formula
For diagonal `K = diag(p_i)` with `0 ≤ p_i ≤ 1`,
\[
S_A(K)=\sum_{i\in A} h(p_i).
\]

**Lean 4 target signature (schematic)**
```lean
theorem fermionicEntropy_diagonal
  {n : ℕ} (p : Fin n → ℝ)
  (hp01 : ∀ i, 0 ≤ p i ∧ p i ≤ 1)
  (A : Finset (Fin n)) :
  fermionicEntropy (Matrix.diagonal p) A
    = ∑ i in A, binaryEntropy (p i)
```

This gives a sanity-check theorem and a testbed for the stronger conjecture.

---

## Implementation notes for nontrivial proof tactics

Your file must contain at least 3 theorems with deep proof tactics. Concretely:

- use `induction` on subsystem size or on finite sets when proving entropy monotonicity or explicit formulas;
- use `rcases` to decompose finite-set membership, principal-submatrix cases, and spectral alternatives;
- use `by_contra` in positivity/nontriviality proofs;
- use `field_simp` in any rational determinant/Hessian computation for `2×2` leaves;
- use multi-step `calc` blocks to connect determinant identities, principal-minor formulas, and entropy inequalities.

Do not allow the development to collapse into decidable finite brute force.

---

## Computational method to verify

You must produce a **verified algorithm**, not just theorem statements.

### Required algorithm
Implement a function that, for a finite kernel `K`:
1. enumerates balanced bipartitions `A`,
2. computes the compressed kernel `K_A`,
3. numerically estimates `fermionicEntropy K A`,
4. computes all degree-2 derivative leaves of `Z_K`,
5. forms their Hessians,
6. computes a signature proxy (positive-eigenvalue count or determinant/trace surrogate),
7. outputs the witness profile and correlation statistics.

The Lean side should verify at least:
- correctness of principal-submatrix extraction,
- correctness of leaf enumeration,
- correctness of the Hessian coefficient formula for degree-2 leaves,
- and correctness of the witness computation on exact rational/small examples.

The Python side can do floating-point experiments, but its formulas must mirror the verified definitions.

---

## demo.py requirements

Your `demo.py` must:
- generate random PSD contractions `K` and several structured kernels;
- compute `min_A S_A(K)` over balanced bipartitions;
- compute `max_α hessianPosIndexAtLeaf(...)` or a surrogate;
- display scatter plots / tables showing correlation;
- include at least one family where the relation is exact or especially clean;
- allow the user to vary `n`, random seed, and kernel family interactively.

---

## Deliverables (ALL mandatory)

You must produce all of the following:

### 1. `FUTURE_DIRECTIONS.md`
3–5 original research directions. Each direction must include:
- **“The key insight is...”**
- **“Why now?”**

At least one direction must bridge to a different domain, such as:
- tensor networks,
- holographic entropy,
- tropical geometry,
- random matrix theory,
- spectral graph theory,
- or coding theory.

### 2. `RESEARCH_PAPER.md`
A standalone scientific paper. A reader with no access to the code must understand:
- the definitions,
- the main theorems,
- why they matter,
- how the proofs work at a high level,
- the computational evidence,
- and what comes next.

### 3. `ARTICLE.md`
Scientific American style. It must explain the discovery and its significance to a broad audience.  
**Taboo:** do **not** focus on formal verification or proof assistants. Focus on the mathematics and physics.

### 4. Verified algorithm / computational method
As described above.

### 5. `demo.py`
Interactive demonstration of the result.

---

## What would make this a breakthrough

If you can show that **a Hessian-signature invariant of the DPP partition polynomial detects nonzero entanglement or controls subsystem entropy**, you will have created a new language for free-fermion quantum correlations. This would suggest that entanglement is not merely spectral or operator-theoretic, but also **visible in the Lorentzian geometry of generating polynomials**.

That is a field-opening statement:
- it gives quantum information a new algebraic-combinatorial toolbox,
- gives Lorentzian polynomials a new physical interpretation,
- and creates a testable program for many-body systems where direct entropy computation is expensive but polynomial data is accessible.

Do not settle for a weak analogy. Build the bridge as a theorem.

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
