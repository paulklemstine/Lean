Soli Deo Gloria

## Assignment: Direction 1: Partition Matroid Spectral Stability

**Mode:** prove

Prove genuinely new, nontrivial theorems about the Lorentzian spectral stability of **partition matroids** by extending the certified uniform-matroid theory to direct sums. This is not an incremental exercise: the point is to expose a **block-spectral principle** for Lorentzian Hessians, showing that combinatorial decomposability manifests as spectral decomposability. If successful, this would open a program of **certified block-structured stability** for matroids, strongly log-concave polynomials, and combinatorial optimization.

Partition matroids are the first family where direct-sum factorization is rich enough to create nontrivial Hessian interaction terms, yet structured enough to admit exact analysis. A theorem here would be a bridge from the catalog’s uniform one-block theory to a full **modular spectral calculus** for Lorentzian generating polynomials.

---

## Core Mathematical Vision

Let
\[
M = U_{r_1,n_1} \oplus \cdots \oplus U_{r_k,n_k}
\]
be a partition matroid on a ground set decomposed into blocks \(E = E_1 \sqcup \cdots \sqcup E_k\), with \(|E_i|=n_i\), rank \(r_i\), and basis generating polynomial
\[
g_M(x) = \prod_{i=1}^k e_{r_i}(x_{E_i}),
\]
where \(e_{r_i}\) is the elementary symmetric polynomial of degree \(r_i\) on block \(E_i\).

The uniform-matroid catalog already gives a one-block spectral gap theorem for quadratic leaves and a stability lower bound. Your mission is to prove that **direct-sum decomposition is spectrally visible**: after taking suitable leaves to degree \(2\), the Hessian of the partition matroid generating polynomial admits a block/cross decomposition whose Lorentzian gap is controlled by the worst block.

This would be a breakthrough because it upgrades isolated spectral facts into a **compositional theorem**. Such a theorem would immediately suggest algorithms for block-structured resource allocation, certified perturbation radii for combinatorial relaxations, and new routes toward negative dependence inequalities.

---

## Precise Theorem Targets

You should introduce at least one new formal structure capturing partition-matroid leaf data and then prove at least 3 substantial theorems.

### New definition to introduce
Define a notion of a **partition quadratic leaf** or **block leaf profile** encoding how many derivatives are taken in each block before reaching total degree \(2\). For example, if the original total degree is \(R=\sum_i r_i\), then a leaf is determined by a profile
\[
a = (a_1,\dots,a_k), \qquad 0 \le a_i \le r_i, \qquad \sum_i a_i = R-2,
\]
so the residual degree in block \(i\) is \(d_i = r_i-a_i\), with \(\sum_i d_i = 2\). Hence only two cases occur:

1. one block contributes residual degree \(2\), all others residual degree \(0\);
2. two distinct blocks contribute residual degree \(1\) each.

This dichotomy is the key insight. It means every quadratic leaf of a partition matroid is either:
- a **single-block quadratic leaf**, or
- a **two-block bilinear leaf**.

That is the structural theorem from which the spectral analysis should flow.

---

## Suggested Lean 4 formalization targets

The exact signatures may need adjustment to match existing catalog definitions, but aim for statements of this shape.

### 1. Structural classification of quadratic leaves
A theorem formalizing that every degree-2 leaf profile is supported either on one block with residual degree 2 or on two blocks with residual degree 1.

```lean
theorem partition_leaf_profile_degree_two_classification
  {k : ℕ} (r n : Fin k → ℕ) (a : Fin k → ℕ)
  (ha : ∀ i, a i ≤ r i)
  (hdeg : (∑ i, (r i - a i)) = 2) :
  (∃ i, (r i - a i) = 2 ∧ ∀ j, j ≠ i → (r j - a j) = 0) ∨
  (∃ i j, i ≠ j ∧ (r i - a i) = 1 ∧ (r j - a j) = 1 ∧
    ∀ ℓ, ℓ ≠ i → ℓ ≠ j → (r ℓ - a ℓ) = 0)
```

This is not a mere combinatorial lemma: it is the classification theorem that makes the entire spectral theory tractable.

### 2. Spectral gap for single-block leaves
Using the catalog theorem for uniform matroids, show that if the quadratic leaf lives entirely in one block, then the Hessian gap is inherited from that block.

A plausible abstract signature:

```lean
theorem partition_single_block_leaf_has_gapped_signature
  (P : PartitionMatroidData)
  (L : PartitionQuadraticLeaf P)
  (hsingle : L.IsSingleBlock) :
  HasGappedSignature (leafHessian P L) (P.blockGap L.singleBlock)
```

If the catalog normalizes the uniform gap to `1`, target the sharper statement:

```lean
theorem partition_single_block_leaf_gap_one
  (P : PartitionMatroidData)
  (L : PartitionQuadraticLeaf P)
  (hsingle : L.IsSingleBlock) :
  HasGappedSignature (leafHessian P L) 1
```

provided the block satisfies the same hypotheses as in `uniform_leaf_has_gapped_signature`.

### 3. Bilinear two-block leaf theorem
For a leaf with residual degree \(1\) in two distinct blocks \(i,j\), the quadratic form is proportional to
\[
\ell_i(x_{E_i}) \ell_j(x_{E_j}),
\]
whose Hessian has off-diagonal block form
\[
H = \begin{pmatrix}
0 & uv^\top \\
vu^\top & 0
\end{pmatrix},
\]
hence rank at most \(2\), with exactly one positive and one negative direction on its support. Prove a Lorentzian-style signature theorem for this case.

A Lean target:

```lean
theorem partition_two_block_leaf_has_one_positive_eigenvalue
  (P : PartitionMatroidData)
  (L : PartitionQuadraticLeaf P)
  (htwo : L.IsTwoBlock) :
  HasAtMostOnePositiveEigenvalue (leafHessian P L)
```

Stronger if feasible:

```lean
theorem partition_two_block_leaf_exact_signature
  (P : PartitionMatroidData)
  (L : PartitionQuadraticLeaf P)
  (htwo : L.IsTwoBlock) :
  HasSignatureOnePosOneNegRestZero (leafHessian P L)
```

This is mathematically important because it reveals that “cross-block” leaves are not perturbative accidents; they are explicitly rank-2 spectral couplings.

### 4. Main partition spectral stability theorem
Prove that every quadratic leaf of a partition matroid has Lorentzian signature, and the certified gap/stability radius is bounded below by the minimum block gap.

```lean
theorem partition_matroid_leaf_has_gapped_signature
  (P : PartitionMatroidData)
  (L : PartitionQuadraticLeaf P) :
  HasAtMostOnePositiveEigenvalue (leafHessian P L) ∧
  HasGappedSignature (leafHessian P L) P.minBlockGap
```

Or, if the exact gap theorem is too strong in full generality, prove the certified lower bound:

```lean
theorem partition_stability_lower_bound
  (P : PartitionMatroidData) :
  P.minBlockGap ≤ stabilityRadius P
```

This theorem should explicitly build on:

- `Catalog/Speculative/AutoResearch/LorentzianStability.lean`
  - `lorentzian_stability_radius_exists`
  - `hasAtMostOnePositiveEigenvalue_of_gapped_perturbation`

- `Catalog/Pythagorean/UniformMatroidLorentzianStability.lean`
  - `uniform_leaf_has_gapped_signature`
  - `uniform_stability_lower_bound`

### 5. Cross-domain theorem: optimization or probability bridge
Include at least one theorem connecting this spectral statement to another domain.

Two promising options:

#### Option A: optimization bridge
Show that blockwise certified spectral gaps imply a robust feasible perturbation radius for a block-separable quadratic optimization surrogate.

```lean
theorem partition_gap_controls_block_sdp_perturbation
  (P : PartitionMatroidData) :
  CertifiedPerturbationRadius P.minBlockGap ≤ blockSDPRobustnessRadius P
```

Even if the optimization object is newly defined and simplified, the theorem should say something real: the spectral gap yields a quantitative robustness certificate for block-structured semidefinite or quadratic programs.

#### Option B: probability bridge
Show that the Hessian decomposition induces a covariance sign pattern or a negative-association surrogate for block variables under a natural Gibbs or basis-weighted distribution.

```lean
theorem partition_two_block_leaf_covariance_nonpos
  (P : PartitionMatroidData)
  (i j : Fin P.numBlocks) (hij : i ≠ j) :
  blockCovariance P i j ≤ 0
```

This would connect Lorentzian geometry to probabilistic dependence and is scientifically exciting.

---

## Why this would be a breakthrough

The catalog currently supports **uniform-matroid Lorentzian stability**. Partition matroids are the first setting where one must understand how stability behaves under **direct sums**, and therefore the first place to discover whether Lorentzian spectral certification is **compositional**.

If you prove that the gap or stability radius is the minimum of block gaps, you establish a new principle:

> **Combinatorial modularity implies spectral modularity.**

That principle would not just solve one family. It would suggest a general method for:
- matroid sums,
- strongly log-concave product measures,
- block-structured hyperbolic/Lorentzian polynomials,
- decomposable optimization certificates.

This is field-opening because it converts isolated spectral calculations into a reusable architecture.

---

## Proof strategy architecture

You must include 2–3 proof avenues and identify the most promising one.

### Strategy A: exact leaf classification + explicit Hessian normal forms
**Most promising.**

1. Formalize the degree-2 leaf profile classification: only single-block quadratic or two-block bilinear leaves can occur.
2. In the single-block case, reduce directly to `uniform_leaf_has_gapped_signature`.
3. In the two-block case, compute the leaf polynomial explicitly as a scalar multiple of a product of two linear forms. Then compute its Hessian as an off-diagonal rank-2 matrix and prove its signature directly by linear algebra.
4. Conclude the global theorem by case splitting on the classification theorem.

Why this is best: it avoids fragile perturbation arguments and gives exact normal forms. It should also be Lean-friendly because the case split is discrete and the linear algebra in the bilinear case is low-rank and explicit.

### Strategy B: product Hessian decomposition + perturbative gap control
1. Use the identity \(f_{M_1\oplus M_2}=f_{M_1}f_{M_2}\).
2. Derive a formula for the Hessian of a quadratic leaf of a product as a block-diagonal term plus cross terms.
3. Apply `hasAtMostOnePositiveEigenvalue_of_gapped_perturbation` from the Lorentzian stability catalog to show the cross term preserves the one-positive-eigenvalue property when controlled by the minimal block gap.
4. Infer a stability lower bound from `lorentzian_stability_radius_exists`.

Why it is attractive: it interfaces directly with the speculative Lorentzian-stability API and could generalize beyond partition matroids. Why it is harder: controlling the perturbation norm sharply may be technically messy.

### Strategy C: induct on the number of blocks
1. Prove the theorem for one block from the uniform catalog.
2. Assume the result for \(k\) blocks and add one new uniform block.
3. Analyze how degree-2 leaves transform under multiplication by \(e_r(x_{E_{k+1}})\).
4. Preserve the spectral theorem through the inductive step.

Why it is valuable: it reveals compositional structure cleanly. Why it is less promising than Strategy A: the induction still requires the same normal-form classification internally, so it may duplicate work.

---

## Mathematical details to exploit

### Explicit leaf dichotomy
Since the total residual degree is 2, the only possibilities are:
- \(d_i = 2\) for one block \(i\), all others \(0\);
- \(d_i = d_j = 1\) for two distinct blocks \(i \neq j\), all others \(0\).

This should be turned into a reusable lemma. It is the combinatorial heart of the project.

### Single-block leaf
If all other blocks are fully differentiated away, the leaf polynomial is
\[
C \cdot e_2(x_{E_i}),
\]
for an explicit scalar \(C>0\). Then the Hessian is just \(C\) times the uniform-block Hessian, so the signature and gap scale accordingly.

### Two-block leaf
The leaf polynomial becomes
\[
C \cdot e_1(x_{E_i}) e_1(x_{E_j}) = C\left(\sum_{u\in E_i} x_u\right)\left(\sum_{v\in E_j} x_v\right).
\]
Its Hessian has the form
\[
H = C\begin{pmatrix}
0 & J \\
J^\top & 0
\end{pmatrix},
\]
where \(J\) is the all-ones matrix between the two blocks. Since \(J\) has rank 1, \(H\) has rank at most 2 and eigenvalues \(\pm C\sqrt{|E_i||E_j|}\), with the rest zero. Hence there is exactly one positive eigenvalue.

This is a beautiful, exact spectral computation and should be formalized if possible.

### Stability radius principle
If every quadratic leaf has one-positive-eigenvalue Lorentzian signature with gap at least \(\gamma\), then the catalog’s stability theorem should yield a certified perturbation radius depending on \(\gamma\). The partition theorem should therefore imply:
\[
\mathrm{stab}(M) \ge \min_i \mathrm{stab}(U_{r_i,n_i}),
\]
or at least a computable lower bound in terms of the minimum block gap.

---

## Conjecture with testable prediction

State and test the following falsifiable conjecture.

### Conjecture: exact partition gap formula
For every partition matroid
\[
M = \bigoplus_{i=1}^k U_{r_i,n_i},
\]
every nonzero quadratic leaf Hessian has spectral gap exactly
\[
\min\bigl(\{ \mathrm{gap}(U_{r_i,n_i}) : \text{single-block leaves occur}\} \cup
\{ \sqrt{n_i n_j}\, c_{ij} : \text{two-block leaves occur}\}\bigr),
\]
where \(c_{ij}\) is the explicit scalar arising from the differentiation profile.

A simpler normalized conjecture, if scaling conventions absorb \(c_{ij}\), is:

> The normalized Lorentzian gap of a partition quadratic leaf is the minimum of the normalized gaps of its active blocks.

### Computational disproof test
For all small tuples
\[
(n_i,r_i)\in \{(2,1),(3,1),(3,2),(4,2)\}
\]
with 2–4 blocks:
1. enumerate all degree-2 leaf profiles;
2. compute the explicit leaf polynomial;
3. form its Hessian matrix numerically;
4. compute nonzero eigenvalues;
5. compare the observed minimal positive-vs-negative separation to the predicted block formula.

If any leaf violates the formula, the conjecture is false and should be refined to a profile-dependent gap theorem. This is scientifically excellent: a failed conjecture here still yields a classification theorem.

---

## Cross-domain connections to emphasize

### Optimization
Partition matroids model resource allocation, scheduling, and assignment constraints. A blockwise spectral stability theorem would give **certified perturbation budgets** for algorithms using generating-polynomial relaxations or Hessian-based surrogates. This is especially relevant to block-structured SDP and combinatorial convexity.

### Probability
Partition matroids under basis-weighted measures are natural models of constrained sampling. The bilinear two-block Hessian structure suggests a route toward **negative dependence across blocks** and covariance control, connecting Lorentzian geometry with probabilistic correlation inequalities.

### Statistical physics
The direct-sum/product structure is analogous to weakly coupled subsystems. The theorem would amount to a rigorous statement that the quadratic response of a decomposed combinatorial ensemble is controlled by its least stable component. This is a spectral stability principle reminiscent of susceptibility bounds in multipart systems.

### Algebraic combinatorics
This work suggests a compositional calculus for strongly log-concave and Lorentzian polynomials under structured products, potentially leading toward broader closure theorems.

---

## Concrete build plan in Lean

1. **Define** a partition-matroid data structure and a quadratic leaf profile structure.
2. **Prove** the residual-degree-2 classification theorem by induction or finite-support sum reasoning.
3. **Formalize** explicit formulas for single-block and two-block leaf polynomials.
4. **Compute** Hessians in both cases.
5. **Reduce** the single-block case to `uniform_leaf_has_gapped_signature`.
6. **Prove** the two-block signature theorem by explicit low-rank linear algebra.
7. **Assemble** the main partition stability theorem.
8. **Derive** a certified stability lower bound using `lorentzian_stability_radius_exists`.
9. **Add** a cross-domain theorem, preferably optimization robustness or covariance nonpositivity.
10. **Implement** computational tests in `demo.py` for small block profiles.

---

## Catalog building blocks to use explicitly

- `Catalog/Speculative/AutoResearch/LorentzianStability.lean`
  - `lorentzian_stability_radius_exists`
  - `hasAtMostOnePositiveEigenvalue_of_gapped_perturbation`

Use these to convert leafwise spectral gap statements into certified stability radius statements, or to control cross-term perturbations if pursuing Strategy B.

- `Catalog/Pythagorean/UniformMatroidLorentzianStability.lean`
  - `uniform_leaf_has_gapped_signature`
  - `uniform_stability_lower_bound`

Use these as the exact one-block base case. The partition theorem should be visibly built as a genuine extension, not a restatement.

---

## Required theorem count and proof style

Your file must contain **at least 3 substantial theorems** with real proof architecture. At least three proofs should materially use techniques such as:
- induction,
- `rcases`,
- `by_contra`,
- `field_simp`,
- multi-step `calc`,
- explicit matrix/eigenvalue reasoning,
- nontrivial decomposition arguments.

Do **not** trivialize the project with decidable enumeration or reflexive simplifications. If a theorem collapses to `native_decide`, it is not one of the core results.

---

## Deliverables

You must produce **all** of the following:

1. **Lean development** proving the main theorems with minimal sorrys.
2. **A verified algorithm or computational method**:
   - algorithm to enumerate quadratic leaf profiles of a partition matroid,
   - construct the corresponding leaf Hessian,
   - compute or certify its block type and predicted spectral gap.
3. **`demo.py`**:
   - interactive exploration for small tuples \((n_i,r_i)\),
   - display leaf types, Hessians, eigenvalues, and whether the conjectured formula holds.
4. **`RESEARCH_PAPER.md`**:
   - standalone scientific exposition,
   - define partition matroids and quadratic leaves,
   - state the main theorem precisely,
   - explain why compositional Lorentzian stability matters,
   - include conjectures and next steps.
5. **`ARTICLE.md`**:
   - Scientific American style,
   - explain the discovery as a story about how complex constrained systems inherit stability from their weakest component,
   - do not focus on formal verification.
6. **`FUTURE_DIRECTIONS.md`** with 3–5 original directions.
   Each direction must include:
   - “The key insight is...”
   - “Why now?”
   At least one direction must bridge to a different domain.

---

## Application keywords

partition matroid, Lorentzian polynomial, spectral gap, Hessian signature, strong log-concavity, direct sum decomposition, block stability, perturbation radius, semidefinite optimization, negative dependence, covariance bounds, combinatorial Hodge theory, resource allocation, scheduling, statistical physics, robust optimization, algebraic combinatorics

---

## Final objective

Do not merely show that partition matroids “also work.” Show something conceptually stronger:

> **Quadratic Lorentzian stability is compositional under partition decomposition, and the weakest block governs the certified spectral robustness of the whole system.**

That is the theorem worth proving.

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
