Soli Deo Gloria

## Assignment: Direction 2: Multi-Mode Lorentzian Witnesses via Higher Derivative Leaves

**Mode:** prove

Build a new formal bridge between Lorentzian polynomials, higher-order derivative leaves, spectral signatures of mixed Hessians, and multipartite entanglement witnesses. The goal is not to mildly extend pairwise leaf analysis, but to create a genuine **higher-body Lorentzian witness theory**: a formalism in which codimension-\((n-k)\) derivative leaves encode \(k\)-mode correlation data invisible to all quadratic reductions.

You should treat the existing pairwise theory as the shadow of a much larger structure.

---

## Core Mathematical Vision

Let \(K\) be a matrix generating a Lorentzian partition polynomial \(Z_K\). For a subset \(A \subseteq \{1,\dots,n\}\) of size \(k\), define the codimension-\((n-k)\) derivative leaf
\[
L_A(x_A) := \left(\prod_{i \notin A} \partial_i\right) Z_K(x_1,\dots,x_n),
\]
a homogeneous polynomial of degree \(k\) in the variables indexed by \(A\).

For Lorentzian \(Z_K\), Brändén–Huh implies that every quadratic derivative of \(L_A\) has Hessian with at most one positive eigenvalue. The breakthrough step is to show that the **mixed Hessian geometry of \(L_A\)** itself gives a computable and structurally meaningful witness of \(k\)-partite entanglement, not merely pairwise correlation.

The decisive formal target is to isolate a **new invariant** attached to each leaf:
- a mixed Hessian matrix,
- its unique positive spectral direction when it exists,
- and a derived scalar witness measuring “multipartite Lorentzian curvature.”

This should become the first rigorous higher-mode Lorentzian witness framework in the library.

---

## New Definitions You Must Introduce

You must define at least one genuinely new concept not already present in the cited catalog files. I recommend introducing all of the following.

### 1. Higher derivative leaf
For a multivariate polynomial \(p\) and finite set \(S\), define the iterated partial derivative leaf obtained by differentiating once in each variable outside \(S\).

Suggested Lean-facing abstraction:
```lean
def derivativeLeaf
  (p : MvPolynomial σ R) (s : Finset σ) : MvPolynomial σ R := ...
```
Specialize to the case where \(σ = Fin n\).

### 2. Mixed Hessian matrix of a leaf
For a polynomial \(p\) and a finite index set \(s\), define the matrix whose \((i,j)\)-entry is the coefficient/expression corresponding to \(\partial_i \partial_j p\), restricted to variables in \(s\), optionally evaluated at the all-ones point.

A practical formal version may use evaluation at \(1\):
```lean
def mixedHessianAtOnes
  (p : MvPolynomial σ ℝ) (s : Finset σ) : Matrix s s ℝ := ...
```

### 3. Lorentzian positive spectral witness
Define the scalar witness as the top eigenvalue when it is positive, and \(0\) otherwise.

```lean
def positiveSpectralWitness
  (M : Matrix n n ℝ) : ℝ := ...
```

### 4. Multipartite witness extracted from a leaf
```lean
def leafWitness
  (p : MvPolynomial σ ℝ) (s : Finset σ) : ℝ :=
positiveSpectralWitness (mixedHessianAtOnes p s)
```

These definitions are mathematically natural, computationally testable, and open a reusable API for future work.

---

## Precise Theorem Targets

You must prove at least 3 substantial theorems. The following are the right targets.

### Theorem 1: Derivative leaves preserve Lorentzian spectral signature
This is the structural theorem on which everything else rests.

#### Mathematical statement
Let \(p\) be a Lorentzian homogeneous polynomial of degree \(n\). Let \(A\) be a subset of variables with \(|A| = k \ge 2\), and let
\[
L_A := \prod_{i \notin A} \partial_i \, p.
\]
Then \(L_A\) is homogeneous of degree \(k\), and for every choice of \(k-2\) further directional derivatives, the Hessian of the resulting quadratic polynomial has at most one positive eigenvalue.

This is the higher-leaf inheritance principle.

#### Lean 4 target signature
A realistic signature, adapted to available Lorentzian definitions in the catalog, is:
```lean
theorem derivativeLeaf_isLorentzian
  {n : ℕ} {p : MvPolynomial (Fin n) ℝ}
  (hp : IsLorentzian p)
  (A : Finset (Fin n)) :
  IsLorentzian (derivativeLeaf p A)
```
If the catalog’s actual notion is `IsDPPLorentzian`, specialize accordingly:
```lean
theorem derivativeLeaf_isDPPLorentzian
  {n : ℕ} {K : Matrix (Fin n) (Fin n) ℝ}
  (hK : IsDPPLorentzian K)
  (A : Finset (Fin n)) :
  IsLorentzian (derivativeLeaf (ZK K) A)
```

#### Why this is a breakthrough
This theorem upgrades Lorentzianity from a global property to a **hierarchical geometry of subsystems**. It says every subsystem leaf remains inside the Lorentzian universe, so one can recursively mine multipartite structure without leaving the theory.

---

### Theorem 2: Mixed Hessian of a higher leaf has Lorentzian spectral constraint
This theorem extracts the spectral witness.

#### Mathematical statement
Let \(p\) be Lorentzian and \(A\) a subset of size \(k \ge 2\). Then the symmetric mixed Hessian matrix of \(L_A\), evaluated at a positive point (in particular at the all-ones point when defined), has at most one positive eigenvalue.

Equivalently, its positive inertia index is at most one.

#### Lean 4 target signature
```lean
theorem mixedHessianAtOnes_posIndex_le_one
  {n : ℕ} {p : MvPolynomial (Fin n) ℝ}
  (hp : IsLorentzian p)
  (A : Finset (Fin n)) :
  Matrix.PosInertiaIndex (mixedHessianAtOnes (derivativeLeaf p A) A) ≤ 1
```
If `PosInertiaIndex` is unavailable, formulate using eigenvalues:
```lean
theorem mixedHessianAtOnes_atMostOne_pos_eigenvalue
  {n : ℕ} {p : MvPolynomial (Fin n) ℝ}
  (hp : IsLorentzian p)
  (A : Finset (Fin n)) :
  AtMostOnePositiveEigenvalue (mixedHessianAtOnes (derivativeLeaf p A) A)
```

#### Why this is a breakthrough
This is the exact formal mechanism that turns Lorentzian geometry into a **multipartite witness machine**. It says the leaf Hessian behaves like a Lorentzian metric: one expanding direction, all others neutral or contracting. That spectral asymmetry is the higher-mode analogue of a causal cone.

---

### Theorem 3: Monotonicity/comparison of higher witness versus pairwise witness
You need at least one theorem comparing the new invariant to existing pairwise leaves.

#### Mathematical statement
For a Lorentzian \(p\), if \(A \subseteq B\) and both leaves are nontrivial, then the pairwise witness extracted from a 2-subset of \(A\) is bounded above by a natural compression of the \(B\)-leaf witness. At minimum, prove that the higher witness dominates some pairwise principal submatrix spectral quantity.

A precise, formally manageable version:
If \(i,j \in A\), then the \(2\times 2\) principal submatrix of the mixed Hessian of \(L_A\) has at most one positive eigenvalue and its top eigenvalue is bounded by the top eigenvalue of the full mixed Hessian.

#### Lean 4 target signature
```lean
theorem principalSubmatrix_topEigenvalue_le_leafWitness
  {n : ℕ} {p : MvPolynomial (Fin n) ℝ}
  (A : Finset (Fin n))
  (hA : A.Nonempty)
  (i j : A)
  (hsym :
    IsSymmetric (mixedHessianAtOnes (derivativeLeaf p A) A)) :
  topEigenvalue (principalSubmatrix₂
      (mixedHessianAtOnes (derivativeLeaf p A) A) i j)
    ≤ leafWitness p A
```

A more DPP-specialized comparison theorem is also excellent:
```lean
theorem pairwiseWitness_le_tripartiteWitness
  {n : ℕ} {K : Matrix (Fin n) (Fin n) ℝ}
  (hK : IsDPPLorentzian K)
  {A : Finset (Fin n)} (hA : A.card = 3) {i j : Fin n}
  (hij : i ∈ A ∧ j ∈ A) :
  pairwiseLeafWitness K i j ≤ leafWitness (ZK K) A
```

#### Why this is a breakthrough
This is where the theory stops being abstract and becomes scientifically meaningful: it formally explains why higher-body probes can detect structure pairwise probes miss.

---

### Theorem 4: Cross-domain theorem via principal minors / Grassmannian shadow
You are required to include a cross-domain bridge. The best one here is exterior algebra / Grassmannian geometry.

#### Mathematical statement
For a DPP-generated Lorentzian polynomial \(Z_K\), the coefficients of a derivative leaf \(L_A\) are linear combinations of principal minors of \(K\). Hence the mixed Hessian entries of \(L_A\) are determined by principal minor data, which may be viewed as a Plücker-type shadow of a point in a Grassmannian.

At the formal level, prove a coefficient-to-minor identity for the leaf Hessian entries.

#### Lean 4 target signature
```lean
theorem mixedHessian_entry_eq_principalMinorCombination
  {n : ℕ} {K : Matrix (Fin n) (Fin n) ℝ}
  (A : Finset (Fin n)) (i j : A) :
  ∃ c : Finset (Fin n) → ℝ,
    (mixedHessianAtOnes (derivativeLeaf (ZK K) A) A) i j
      = ∑ S in A.powerset, c S * principalMinor K (↑S : Finset (Fin n))
```

A weaker but still excellent theorem:
```lean
theorem derivativeLeaf_coefficients_controlled_by_principalMinors
  {n : ℕ} {K : Matrix (Fin n) (Fin n) ℝ}
  (A : Finset (Fin n)) :
  ∀ m ∈ (derivativeLeaf (ZK K) A).support,
    ∃ S : Finset (Fin n), coeff m (derivativeLeaf (ZK K) A) = principalMinor K S
```

#### Why this is a breakthrough
This links Lorentzian witness theory to **algebraic geometry of minors**, opening a path toward Grassmannians, matroids, and cluster structures. This is exactly the kind of connection that can seed an entire research program.

---

## Conjecture With Falsifiable Prediction

You must state at least one explicit conjecture with a computational refutation path.

### Conjecture: Strict multipartite separation
There exists a family of Lorentzian DPP polynomials \(Z_{K_n}\) and subsets \(A\) with \(|A|=3\) or \(4\) such that:
1. every pairwise leaf witness on \(A\) is below a fixed threshold \(\varepsilon\),
2. but the higher leaf witness satisfies
   \[
   \mathrm{leafWitness}(Z_{K_n},A) \ge c > \varepsilon.
   \]

In words: genuine multipartite Lorentzian curvature can be large even when all pairwise witnesses are weak.

#### Lean-facing conjecture skeleton
```lean
conjecture strict_multipartite_separation
  : ∃ (n : ℕ) (K : Matrix (Fin n) (Fin n) ℝ) (A : Finset (Fin n)) (ε c : ℝ),
      IsDPPLorentzian K ∧
      A.card = 3 ∨ A.card = 4 ∧
      (∀ i j, i ∈ A → j ∈ A → pairwiseLeafWitness K i j ≤ ε) ∧
      ε < c ∧
      c ≤ leafWitness (ZK K) A
```

### Computational test
For \(n = 6,8\), enumerate candidate \(K\) from a structured family:
- diagonal plus low-rank perturbations,
- correlation matrices,
- Gram matrices of random vectors,
- block matrices with weak pair couplings but strong collective overlap.

For each \(A\) with \(|A|=3,4\):
1. compute the derivative leaf,
2. build the mixed Hessian at ones,
3. compute its top positive eigenvalue,
4. compare against all pairwise witnesses on \(A\).

A single counterexample with large pairwise witnesses relative to the higher witness would refute naive forms of the conjecture. This is exactly the kind of testable prediction we want.

---

## Proof Strategy Architecture

You must give Aristotle multiple routes and choose the most promising.

### Strategy A: Direct Lorentzian inheritance through iterated derivatives
1. Express `derivativeLeaf p A` as an iterated partial derivative over the complement of `A`.
2. Invoke the closure of Lorentzian polynomials under partial differentiation from the catalog or derive it by induction on the complement cardinality.
3. Transfer the spectral Hessian property from the Lorentzian definition to the mixed Hessian at ones.

**Why promising:** this is the cleanest route if the catalog already exposes derivative stability of `IsLorentzian` / `IsDPPLorentzian`.

### Strategy B: Hessian-level induction on codimension
1. Prove by induction on \(m = n-k\) that each additional derivative preserves the “at most one positive eigenvalue” property of the relevant quadratic descendants.
2. Use `Finset.induction` on the complement set and `rcases` on membership splits.
3. At the evaluation stage, use `calc` chains to identify mixed Hessian entries with iterated derivatives.

**Why promising:** robust even if the catalog’s Lorentzian API is incomplete. This is likely the most formalization-friendly route.

### Strategy C: Principal-minor expansion and spectral comparison
1. Expand derivative leaf coefficients using the DPP/minor formula for \(Z_K\).
2. Show each mixed Hessian entry is a linear combination of principal minors.
3. Use symmetric-matrix comparison, principal submatrix inequalities, and Cauchy interlacing to control top eigenvalues.

**Why promising:** best for the cross-domain theorem and witness comparison theorem, especially if `QuantumDPPEntanglement.lean` already computes pairwise leaves via minors.

**Most promising overall:** combine **Strategy B** for the inheritance theorem with **Strategy C** for the spectral witness/comparison theorems. Strategy A is elegant but depends heavily on existing API shape.

---

## Required Deep Proof Tactics

Your file must visibly contain multi-step, nontrivial proofs. In particular, ensure at least three theorem proofs use some of the following:
- `induction` on `Finset.card` or on the complement set,
- `rcases` to unpack subset/cardinality/eigenvalue hypotheses,
- `by_contra` to prove uniqueness of the positive direction or nonexistence of two positive eigenvalues,
- `field_simp` in any principal-minor or determinant-ratio identities,
- substantial `calc` blocks converting derivative expressions into Hessian entries and then into minor formulas.

Do not hide everything behind automation. The point is to expose mathematical structure.

---

## Concrete Lean Development Targets

You should work near the cited files and explicitly import and build on them:

- `Catalog/Speculative/AutoResearch/DPPLorentzian.lean`
  - Use its Lorentzianity definition and any derivative closure lemmas.
  - Reuse `IsDPPLorentzian` if available rather than inventing a parallel notion.

- `Catalog/Pythagorean/QuantumDPPEntanglement.lean`
  - Extract the pairwise leaf API and witness constructions.
  - Generalize degree-2 leaf computations to degree-3 and degree-4 leaves.

Suggested new file:
```lean
Catalog/Speculative/AutoResearch/MultiModeLorentzianWitnesses.lean
```

Possible theorem names:
```lean
derivativeLeaf_isLorentzian
mixedHessianAtOnes_symmetric
mixedHessianAtOnes_posIndex_le_one
principalSubmatrix_topEigenvalue_le_leafWitness
derivativeLeaf_coefficients_controlled_by_principalMinors
pairwiseWitness_le_tripartiteWitness
```

---

## Cross-Domain Connections You Must Explicitly Develop

### 1. Algebraic geometry / Grassmannians
Principal minors and Plücker-like coordinates suggest that higher derivative leaves are shadows of Grassmannian data. Even if you do not fully formalize Grassmannians, state and prove the coefficient/minor theorem as the algebraic-geometric bridge.

### 2. Quantum information / many-body physics
Interpret the positive spectral witness as a many-body correlation detector, analogous to how three-body cumulants reveal structure invisible to two-point functions.

### 3. Tensor networks
Derivative leaves can be viewed as marginal contractions of a higher-order tensor encoded by polynomial coefficients. A theorem relating leaf coefficients to restricted supports or contractions would be a valuable bridge.

### 4. Spectral graph theory
If \(K\) is chosen from a graph Laplacian/correlation family, then the leaf witness becomes a higher-order spectral observable. Mention this explicitly in the paper and future directions.

---

## Application Keywords

Use these in the paper, article, and code comments where appropriate:

**Lorentzian polynomials, derivative leaves, mixed Hessian, multipartite entanglement, principal minors, DPP, Brändén–Huh theory, Grassmannian geometry, Plücker coordinates, tensor networks, spectral witnesses, higher-order correlations, many-body physics, Cauchy interlacing, algebraic statistics, negative dependence, quantum marginals**

---

## Deliverables You Must Produce

You must produce **all** of the following:

### 1. Lean theorem file
A substantial file with:
- at least one new definition,
- at least 3 nontrivial theorems,
- minimal `sorry`,
- explicit use of deep proof tactics.

### 2. Verified algorithm / computational method
Implement a certified procedure that:
1. enumerates derivative leaves of codimension \(n-k\),
2. constructs mixed Hessian matrices at ones,
3. computes or bounds the unique positive eigenvalue,
4. compares this against pairwise witnesses.

Even if exact spectral computation is hard in Lean, formally verify a sound upper/lower bounding method or a symbolic extraction pipeline.

### 3. `demo.py`
An interactive demonstration that:
- samples or inputs a matrix \(K\),
- enumerates subsets \(A\) of size \(3\) or \(4\),
- computes leaf Hessians,
- displays pairwise versus higher-order witnesses,
- highlights candidate strict-separation examples.

### 4. `RESEARCH_PAPER.md`
A standalone scientific paper explaining:
- the new definitions,
- the main theorems,
- why higher derivative leaves matter,
- how they connect to principal minors and many-body correlations,
- what conjectures and experiments come next.

This must be understandable without reading the Lean code.

### 5. `ARTICLE.md`
Write this in **Scientific American** style for a broad audience. Explain the ideas as a discovery about hidden many-body structure in Lorentzian geometries and quantum-like systems.  
**Taboo:** do not focus on formal verification machinery.

### 6. `FUTURE_DIRECTIONS.md`
Give 3–5 original research directions. Each direction must include the sentences:
- **“The key insight is...”**
- **“Why now?”**

At least one direction must bridge to a different domain, such as:
- tropical geometry,
- algebraic statistics,
- condensed matter physics,
- complexity theory,
- matroid theory.

Write this as genuine research prose, not as a template.

---

## Final Scientific Ambition

The pairwise theory says: “there is hidden geometry in second derivatives.”  
Your job is to show something far more powerful:

**entanglement is stratified by derivative leaves, and Lorentzian geometry furnishes a hierarchy of witnesses for many-body structure.**

If this works, it opens a field:
- a Lorentzian theory of multipartite correlation,
- a minor-based algebraic geometry of entanglement witnesses,
- and a computational pipeline for discovering many-body structure from polynomial curvature.

Do not settle for a formal variant of known degree-2 statements. Build the first real higher-body Lorentzian witness theory.

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
