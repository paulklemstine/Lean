Soli Deo Gloria

## Assignment: Direction 4: Plücker Coordinates and Fermionic State Preparation

**Mode:** prove

Prove genuinely new, non-trivial theorems at the interface of matroid theory, multilinear algebra, and free-fermion quantum mechanics. Build explicitly on:

- `Catalog/Pythagorean/MatroidQuantumCertificates.lean`

and extract from it the basis-weighted partition-function viewpoint, then push decisively beyond it: representable matroids should not merely admit combinatorial basis certificates; they should admit a **Grassmann–fermionic normal form** in which basis amplitudes are Plücker coordinates and basis probabilities are principal-minor weights.

Your goal is to formalize the mathematical backbone of the following paradigm:

> A representable matroid is not just a combinatorial object with a basis-generating polynomial; it is the shadow of a decomposable fermionic wavefunction in exterior algebra, and its weighted basis law is the diagonal measurement law of a Slater determinant state.

This is a breakthrough because it replaces recursive combinatorics (deletion/contraction) with geometric and physical structure (Grassmannians, wedge states, Gaussian/free-fermion preparation). If successful, this opens a new field: **quantum matroid geometry**, where representable matroids become exactly the classical observables of fermionic Gaussian states.

---

## Core theorem targets

You must prove at least **3 substantial theorems** with multi-step proofs. At least one theorem must connect matroid theory to another domain, specifically **quantum/free-fermion physics via exterior algebra**.

You must also introduce at least **one genuinely new definition** not already present in the catalog.

### New definitions to introduce

You should define a structure capturing the Plücker-weighted basis law attached to a matrix representation.

Suggested definitions:

1. **Weighted Plücker mass**
   - For `A : Matrix (Fin r) (Fin n) ℝ` and `w : Fin n → ℝ`,
   define the sum over `r`-subsets
   \[
   \mathrm{pluckerMass}(A,w) := \sum_{S \subseteq [n],\, |S|=r} (\det A_S)^2 \prod_{i\in S} w_i.
   \]
   Use a finite-set/subtype formulation in Lean.

2. **Fermionic basis amplitude**
   - For each `r`-subset `S`, define the amplitude
   \[
   \psi_A(S) := \det(A_S),
   \]
   interpreted as the coordinate of the decomposable wedge state
   \[
   a_1 \wedge \cdots \wedge a_r \in \bigwedge^r \mathbb{R}^n
   \]
   in the occupation basis.

3. **Representable matroid Slater state** (new concept)
   - A predicate or structure expressing that a basis distribution arises from squared amplitudes of a decomposable wedge / free-fermion Gaussian state.

These definitions are not cosmetic. They are the formal bridge between:
- matroid basis enumeration,
- Cauchy–Binet / Gram determinants,
- and fermionic occupation-number amplitudes.

---

## Precise theorem statements

You should formalize the strongest version feasible in Lean 4. Below are target statements; adapt indexing details as needed, but keep the mathematical content intact.

### Theorem 1: Cauchy–Binet weighted Plücker expansion

For a real matrix \(A \in \mathbb{R}^{r \times n}\) and nonnegative weights \(w : [n] \to \mathbb{R}\), let \(D_w\) be the diagonal matrix with entries \(w_i\). Then
\[
\det\!\big(A D_w A^\top\big)
=
\sum_{S \subseteq [n],\, |S|=r}
(\det A_S)^2 \prod_{i\in S} w_i.
\]

This is the central identity. It identifies the weighted basis-generating polynomial of the represented matroid with a Gram determinant.

### Suggested Lean 4 type signature
```lean
theorem det_mul_diagonal_mul_transpose_eq_pluckerMass
  {r n : ℕ} (A : Matrix (Fin r) (Fin n) ℝ) (w : Fin n → ℝ) :
  Matrix.det (A * Matrix.diagonal w * A.transpose) =
    ∑ S in (Finset.powersetLen r (Finset.univ : Finset (Fin n))),
      (Matrix.det (A.submatrix Finset.orderEmbOfFin S ?_))^2 *
        ∏ i in S, w i
```
You will need to choose or build the right minor-extraction API; the exact `submatrix` embedding arguments may differ. The key requirement is that the theorem is formally about **all** `r,n`, not only tiny examples.

### Why this matters
This theorem upgrades the catalog’s basis-weight polynomial into a **spectral/Gram object**. It says representable matroids have partition functions computable as determinants, which is exactly the algebraic signature of free-fermion solvability.

---

### Theorem 2: Support equals the basis family of the represented matroid

Assume \(A\) represents a rank-\(r\) matroid \(M\) on ground set \([n]\). Then for every \(r\)-subset \(S\),
\[
\det(A_S) \neq 0 \iff S \text{ is a basis of } M.
\]
Consequently,
\[
\mathrm{pluckerMass}(A,w)
=
\sum_{S \in \mathcal{B}(M)} (\det A_S)^2 \prod_{i\in S} w_i.
\]

### Suggested Lean 4 type signature
```lean
theorem det_minor_ne_zero_iff_isBasis_of_represents
  {r n : ℕ} (A : Matrix (Fin r) (Fin n) ℝ)
  (M : Matroid (Fin n))
  (hrep : RepresentsMatroid A M) :
  ∀ S ∈ Finset.powersetLen r (Finset.univ : Finset (Fin n)),
    Matrix.det (minorFromFinset A S) ≠ 0 ↔ M.IsBasis (S : Set (Fin n))
```

and then

```lean
theorem pluckerMass_eq_basis_sum_of_represents
  {r n : ℕ} (A : Matrix (Fin r) (Fin n) ℝ)
  (w : Fin n → ℝ) (M : Matroid (Fin n))
  (hrep : RepresentsMatroid A M) :
  pluckerMass A w =
    ∑ S in ((Finset.powersetLen r Finset.univ).filter
      (fun S => M.IsBasis (S : Set (Fin n)))),
      (Matrix.det (minorFromFinset A S))^2 * ∏ i in S, w i
```

### Why this matters
This theorem says the Plücker support is not accidental linear algebra; it is exactly matroid structure. It is the formal point where Grassmannian geometry becomes combinatorics.

---

### Theorem 3: Positivity and partition-function interpretation

If all weights are nonnegative, then
\[
0 \le \mathrm{pluckerMass}(A,w),
\]
and if \(A\) has full row rank and at least one \(r\)-subset has strictly positive weight product, then the mass is strictly positive.

### Suggested Lean 4 type signature
```lean
theorem pluckerMass_nonneg
  {r n : ℕ} (A : Matrix (Fin r) (Fin n) ℝ) (w : Fin n → ℝ)
  (hw : ∀ i, 0 ≤ w i) :
  0 ≤ pluckerMass A w
```

and a strict positivity version:
```lean
theorem pluckerMass_pos
  {r n : ℕ} (A : Matrix (Fin r) (Fin n) ℝ) (w : Fin n → ℝ)
  (hfull : A.rank = r)
  (hw : ∀ i, 0 ≤ w i)
  (hex : ∃ S ∈ Finset.powersetLen r (Finset.univ : Finset (Fin n)),
    Matrix.det (minorFromFinset A S) ≠ 0 ∧ 0 < ∏ i in S, w i) :
  0 < pluckerMass A w
```

### Why this matters
This is the probabilistic doorway: once positivity is established, you can normalize the Plücker weights into an actual sampling distribution. This is exactly what a quantum state preparation theorem needs.

---

### Theorem 4: Fermionic occupation law for decomposable states

Formalize a finite-dimensional exterior-algebra surrogate if full exterior algebra machinery is too heavy: define amplitudes on `r`-subsets by minors, and prove the squared amplitude law is the normalized basis distribution. At minimum prove:

\[
\sum_{|S|=r} \psi_A(S)^2 = \det(A A^\top),
\]
and more generally,
\[
\sum_{|S|=r} \psi_A(S)^2 \prod_{i\in S} w_i
=
\det(A D_w A^\top).
\]

### Suggested Lean 4 type signature
```lean
theorem sum_sq_minor_eq_det_gram
  {r n : ℕ} (A : Matrix (Fin r) (Fin n) ℝ) :
  ∑ S in (Finset.powersetLen r (Finset.univ : Finset (Fin n))),
      (Matrix.det (minorFromFinset A S))^2
    =
  Matrix.det (A * A.transpose)
```

This is mathematically the same determinant identity specialized to `w ≡ 1`, but conceptually it is the **Born rule for Slater amplitudes**.

### Why this matters
This is the cross-domain theorem. It says the normalization constant of a fermionic occupation state is exactly a Gram determinant. That is the signature of free fermions, and it connects matroid basis sampling to many-body physics.

---

## Strong conjecture with computational test

State and test at least one falsifiable conjecture. Here is the right one:

### Conjecture: Matchgate-preparable exact basis sampler
For every real rank-\(r\) matrix \(A \in \mathbb{R}^{r \times n}\), the normalized distribution
\[
\mathbb{P}_A(S)
=
\frac{(\det A_S)^2}{\sum_{|T|=r} (\det A_T)^2}
\quad (|S|=r)
\]
is exactly the occupation-number measurement law of a polynomial-size free-fermion / matchgate circuit on \(n\) modes with \(r\) particles.

### Testable prediction
For all randomly generated small matrices with `r ∈ {2,3}` and `n ∈ {4,5,6}`:
1. compute all `r × r` minors,
2. normalize the squared minors into a probability law,
3. compute the one-particle correlation matrix \(K = A^\top (A A^\top)^{-1} A\) when full row rank holds,
4. verify numerically that the induced determinantal point process law
   \[
   \mathbb{P}(S) = \det(K_S)
   \]
   matches the normalized squared-minor law.

This conjecture is falsifiable: any mismatch on a small full-row-rank matrix disproves it.

If you can prove the identity
\[
\frac{(\det A_S)^2}{\det(A A^\top)} = \det(K_S),
\qquad K = A^\top (A A^\top)^{-1} A,
\]
that would be a major theorem in its own right and should become the centerpiece.

### Suggested Lean target if feasible
```lean
theorem normalized_sq_minor_eq_det_projection_minor
  {r n : ℕ} (A : Matrix (Fin r) (Fin n) ℝ)
  (hfull : A.rank = r) :
  ∀ S ∈ Finset.powersetLen r (Finset.univ : Finset (Fin n)),
    (Matrix.det (minorFromFinset A S))^2 / Matrix.det (A * A.transpose)
      =
    Matrix.det (minorFromFinset
      (A.transpose * (gramInverse A hfull) * A) S)
```
Even a weaker, carefully formalized version would be substantial.

---

## Proof strategy architecture

You must include multi-path reasoning, not just one hint. Here are the three main proof routes.

### Strategy A: Cauchy–Binet determinant expansion through diagonal factorization
**Most promising.**

1. Write
   \[
   A D_w A^\top = (A D_{\sqrt{w}})(A D_{\sqrt{w}})^\top
   \]
   when weights are nonnegative, or work directly with diagonal entries symbolically.
2. Apply the Cauchy–Binet formula to
   \[
   \det(A D_w A^\top).
   \]
3. Show each selected column-submatrix contributes
   \[
   \det(A_S)\det((D_w A^\top)_S)= (\det A_S)^2 \prod_{i\in S} w_i.
   \]

Why this is best: it is algebraically canonical, scales to weighted and unweighted cases, and naturally yields positivity and Gram interpretations.

### Strategy B: Exterior algebra / wedge-coordinate proof
**Most conceptually revolutionary.**

1. Interpret the rows of `A` as vectors \(a_1,\dots,a_r \in \mathbb{R}^n\).
2. Consider the decomposable \(r\)-vector
   \[
   a_1 \wedge \cdots \wedge a_r.
   \]
3. Expand in the standard occupation basis \(e_S\); the coefficient of \(e_S\) is \(\det(A_S)\).
4. Use the induced inner product on \(\bigwedge^r \mathbb{R}^n\) to prove
   \[
   \|a_1 \wedge \cdots \wedge a_r\|^2 = \det(A A^\top),
   \]
   hence the sum-of-squares minor identity.

Why this matters: this is the theorem’s true meaning. Even if some exterior algebra machinery must be modeled manually via alternating maps or basis expansions, this route gives the conceptual payoff.

### Strategy C: Determinantal point process / projection-kernel route
**Best for the cross-domain leap.**

1. Assume full row rank and form
   \[
   K = A^\top (A A^\top)^{-1} A.
   \]
2. Prove \(K\) is an idempotent symmetric matrix of rank \(r\), hence a fermionic correlation kernel.
3. Use Jacobi/Cauchy–Binet identities to show
   \[
   \det(K_S)=\frac{(\det A_S)^2}{\det(A A^\top)}.
   \]
4. Conclude that the matroid basis law is a determinantal point process and therefore a free-fermion measurement law.

Why this is transformative: it links matroids not only to quantum states but specifically to **Gaussian fermionic states and integrable sampling laws**.

---

## Cross-domain connections you must emphasize

You are required to include at least one theorem that explicitly bridges domains. The following bridges are central and should appear in your statements, proofs, and exposition:

1. **Matroid theory ↔ quantum many-body physics**
   - Bases correspond to occupation-number sectors.
   - Plücker coordinates are Slater amplitudes.
   - Basis probabilities become Born probabilities.

2. **Combinatorics ↔ algebraic geometry**
   - The represented matroid is encoded by a point in the Grassmannian.
   - Basis support is the support of Plücker coordinates.
   - The basis-generating polynomial is a shadow of the Plücker embedding.

3. **Linear algebra ↔ probabilistic algorithms**
   - Gram determinants produce normalized sampling laws.
   - The resulting distributions are determinantal point processes.
   - This suggests exact or efficient samplers via projection kernels.

4. **Quantum computation ↔ combinatorial optimization**
   - If the basis law is matchgate-preparable, then representable-matroid basis sampling may admit efficient fermionic circuits.
   - This would complement deletion/contraction methods with a spectral/geometric algorithm.

---

## Application keywords

Include these explicitly in your deliverables and framing:

- representable matroids
- Grassmannian
- Plücker coordinates
- Cauchy–Binet
- exterior algebra
- Slater determinant
- fermionic Gaussian state
- matchgate circuit
- determinantal point process
- basis-generating polynomial
- occupation-number measurement
- Gram determinant
- quantum state preparation
- combinatorial sampling
- many-body physics

---

## Lean formalization guidance

Be precise and ambitious, but choose representations Lean can support.

### Likely implementation choices
- Work with `Matrix (Fin r) (Fin n) ℝ`.
- Encode `r`-subsets as `Finset (Fin n)` with membership in `powersetLen r univ`.
- Create a helper `minorFromFinset` extracting the square submatrix indexed by a size-`r` finset.
- Define `pluckerMass` as a finite sum over `powersetLen`.
- Reuse Mathlib matrix determinant lemmas and Cauchy–Binet if available; if not available in the exact form needed, prove an intermediate finite-sum determinant identity yourself.

### Deep proof tactics requirement
At least 3 theorems must require nontrivial proof structure using some of:
- `induction`
- `rcases`
- `by_contra`
- `field_simp`
- multi-step `calc`
- decomposition into cases on subset membership
- rewriting finite products over transported finsets
- determinant multiplicativity / submatrix manipulations

Do not choose statements whose proofs collapse to `native_decide`, `decide`, `norm_num`, or `rfl`.

---

## Concrete file-level expectations

Create or extend a Lean file centered on this program, for example:
- `Grassmann/FermionicPlucker.lean`
or another mathematically appropriate location.

The file must contain:
1. at least one new definition,
2. at least three substantial theorems,
3. at least one cross-domain theorem,
4. one conjecture with explicit computational test scaffolding,
5. minimal sorry usage.

You should also include small executable examples for `r=2,3` and `n=4,5,6` verifying the determinant identities numerically/symbolically where practical.

---

## Deliverables (ALL mandatory)

You must produce all of the following:

### 1. `FUTURE_DIRECTIONS.md`
Include **3–5 original research directions** growing out of this work. Each direction must include:
- a sentence beginning exactly with **“The key insight is…”**
- a sentence beginning exactly with **“Why now?”**

At least one direction must bridge to a different domain, such as:
- quantum chemistry,
- integrable probability,
- tropical geometry,
- coding theory,
- or complexity theory.

Possible future directions:
- tropicalization of Plücker-weighted basis laws,
- interacting-fermion deformations of matroid states,
- determinantal samplers for optimization over representable matroids,
- Grassmannian entanglement invariants for combinatorial states.

### 2. `RESEARCH_PAPER.md`
A standalone scientific paper that explains:
- the exact theorem statements,
- how they build on `Catalog/Pythagorean/MatroidQuantumCertificates.lean`,
- why the Plücker/Grassmannian route is new,
- what the free-fermion interpretation means mathematically,
- what applications become possible,
- and what conjectures should be attacked next.

This document must make sense to a reader with no access to the code.

### 3. `ARTICLE.md`
Write an accessible Scientific American–style article about the discovery.
Do **not** focus on formal verification or proof assistants.
Focus on the ideas:
- matroids as hidden quantum states,
- Grassmannians as geometry of many-particle configurations,
- and why free fermions make exact sampling unexpectedly possible.

### 4. Verified algorithm or computational method
Not just theorems: implement a verified computational method, for example:
- an algorithm computing `pluckerMass`,
- a normalized basis sampler for small representable matroids,
- or a routine constructing the projection kernel \(K\) and verifying the determinantal law.

The algorithm should come with proved correctness lemmas tying computation to theorems.

### 5. `demo.py`
Provide an interactive Python demo that:
- accepts a small matrix `A`,
- enumerates all `r`-subsets,
- computes minors and squared amplitudes,
- computes `det(A A^T)` and optionally `det(A D_w A^T)`,
- compares the normalized law to the determinantal kernel law,
- and displays the basis distribution in an interpretable way.

Include examples for small rank-2 and rank-3 representable matroids.

---

## Final call to arms

Do not treat this as a minor extension of basis-weight identities. The real target is to show that **representable matroids are exactly the combinatorial boundary of fermionic Gaussian geometry**. If you can formalize even the first layer of this—weighted Cauchy–Binet, support equals bases, Gram normalization, and the determinantal/free-fermion law—you will have created a new bridge between combinatorics, algebraic geometry, and quantum many-body theory.

This is the kind of result that changes what people think a matroid is.

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
