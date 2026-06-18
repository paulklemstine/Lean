Soli Deo Gloria

## Assignment: Direction 3 — Spectral Gap and Curvature Variance Bound

**Mode:** prove

Aristotle, this direction has the right shape for a real breakthrough if you do **not** stop at the obvious Rayleigh-quotient reformulation. The revolutionary target is to turn discrete curvature on triangulated surfaces into a genuinely spectral object, and then push that bridge far enough that curvature fluctuation becomes controllable by Laplacian gap data. If successful, this opens a new program: **spectral discrete differential geometry**, where mesh curvature, topological defect, and spectral rigidity interact in formally verified mathematics.

The conjecture as stated is promising, but too raw. You should sharpen it into a hierarchy of theorems: one unconditional theorem that is formally reachable now, one stronger theorem under an explicit “curvature potential” hypothesis, and one falsifiable conjecture that can drive computation.

The key point is this: by the catalog results, the curvature defect vector is mean-zero, so it lies orthogonally to constants. That makes it visible to the first positive Laplacian eigenvalue. The nontrivial step is to identify a geometric or combinatorial operator whose energy controls curvature variance. This is where you must introduce a **new definition** and make the project field-opening rather than incremental.

---

## Core Mathematical Vision

For a finite triangulated closed orientable surface with vertex set \(V\), let
- \(K : V \to \mathbb{R}\) be the combinatorial curvature,
- \(\bar K\) its mean,
- \(\delta(v) := K(v) - \bar K\) the mean-zero curvature defect,
- \(L\) the combinatorial graph Laplacian of the 1-skeleton,
- \(\lambda_1(L)\) the smallest nonzero eigenvalue / spectral gap.

From the catalog:
- `curvatureVariance_eq_norm_sq_of_mean_zero_part` identifies variance with squared norm of the mean-zero part;
- `defect_sum_vanishes` gives \(\sum_v \delta(v)=0\);
- `discrete_gauss_bonnet` gives the topological total curvature constraint.

The conceptual leap is to define a **curvature potential** \( \phi \) solving
\[
L \phi = \delta,
\]
or more realistically in Lean, a witness to this equation under a surjectivity-on-mean-zero hypothesis. Then
\[
\|\delta\|^2 = \langle L\phi,\delta\rangle
\]
and spectral/Poincaré inequalities convert between curvature variance and Laplacian energy. This is the discrete analogue of controlling scalar curvature fluctuations by elliptic estimates.

---

## Precise Theorem Targets

You should prove at least **3 substantial theorems**, with multi-step arguments. I recommend the following hierarchy.

### Theorem 1: Spectral lower bound from a curvature-potential energy inequality
This is the most mathematically meaningful theorem and should be the flagship result.

**Informal statement.**
Let \(T\) be a finite connected triangulated surface. Suppose \(\delta\) is the mean-zero curvature defect and there exists a potential \(\phi\) such that \(L\phi=\delta\). Then
\[
\operatorname{Var}(K_T)
\;\le\;
\frac{1}{\lambda_1(L)} \,\langle L\delta,\delta\rangle.
\]
Equivalently,
\[
\lambda_1(L)\,\operatorname{Var}(K_T)\;\le\;\mathcal E(\delta),
\]
where \(\mathcal E(\delta)=\langle L\delta,\delta\rangle\) is the Dirichlet energy of the defect.

This is already nontrivial and robust: it says curvature variance cannot be large unless the defect oscillates along edges.

**Lean 4 target signature (schematic but precise enough to formalize):**
```lean
theorem curvatureVariance_le_defectDirichletEnergy_div_spectralGap
  {V : Type*} [Fintype V] [DecidableEq V]
  (L : Matrix V V ℝ)
  (K δ : V → ℝ)
  (hδ : δ = fun v => K v - ((∑ w, K w) / Fintype.card V))
  (hmean : ∑ v, δ v = 0)
  (hLsymm : L.IsSymm)
  (hLpos : ∀ x, 0 ≤ dotProduct x (fun i => ∑ j, L i j * x j))
  (hker :
    ∀ x, (∀ i, (∑ j, L i j * x j) = 0) → ∃ c : ℝ, x = fun _ => c)
  (hgap : 0 < spectralGap L)
  :
  curvatureVariance K
    ≤ defectDirichletEnergy L δ / spectralGap L
```

You will likely need to define:
```lean
def defectDirichletEnergy {V : Type*} [Fintype V] (L : Matrix V V ℝ) (δ : V → ℝ) : ℝ :=
  ∑ i, δ i * (∑ j, L i j * δ j)
```
and perhaps a reusable notion:
```lean
def MeanZero {V : Type*} [Fintype V] (f : V → ℝ) : Prop := ∑ v, f v = 0
```

This theorem is a genuine bridge between discrete geometry and spectral graph theory.

---

### Theorem 2: Lower bound on variance from an inverse Poincaré-type curvature forcing hypothesis
This theorem is closer to the original conjectural direction.

**New definition.**
Introduce a novel concept not in the catalog:

```lean
def CurvatureForcing
  {V : Type*} [Fintype V] [DecidableEq V]
  (L : Matrix V V ℝ) (δ : V → ℝ) (A : ℝ) : Prop :=
  A * ‖δ‖∞^2 ≤ defectDirichletEnergy L δ
```

Interpretation: the curvature defect is “spectrally forced” if its Dirichlet energy dominates its sup-norm square. This is not a standard catalog object and creates a reusable interface between local curvature concentration and global spectral rigidity.

**Informal statement.**
If \( \delta \) is mean-zero and satisfies
\[
A \|\delta\|_\infty^2 \le \langle L\delta,\delta\rangle,
\]
then
\[
\operatorname{Var}(K_T) \ge \frac{A}{\lambda_{\max}(L)\,|V|}\,\|\delta\|_\infty^2.
\]
This gives an explicit constant depending only on spectral size bounds and vertex count. If you can bound \(\lambda_{\max}(L)\) in terms of maximal degree, you get a purely combinatorial constant.

**Lean 4 target signature:**
```lean
theorem variance_ge_supNorm_sq_of_curvatureForcing
  {V : Type*} [Fintype V] [DecidableEq V]
  (L : Matrix V V ℝ)
  (K δ : V → ℝ)
  (A : ℝ)
  (hδ : δ = fun v => K v - ((∑ w, K w) / Fintype.card V))
  (hmean : MeanZero δ)
  (hforce : CurvatureForcing L δ A)
  (hmax :
    defectDirichletEnergy L δ ≤ topEigenvalue L * squaredNorm δ)
  :
  (A / (topEigenvalue L * Fintype.card V : ℝ)) * supNormSq δ
    ≤ curvatureVariance K
```

You may need definitions:
```lean
def squaredNorm {V : Type*} [Fintype V] (f : V → ℝ) : ℝ := ∑ v, (f v)^2
def supNormSq {V : Type*} [Fintype V] (f : V → ℝ) : ℝ := (Finset.univ.sup (fun v => |f v|))^2
```
or a more Lean-friendly substitute using `sSup`.

This theorem is important because it converts a local extremal curvature defect into a global variance lower bound via spectral control. It is exactly the kind of theorem that can power mesh-quality certification.

---

### Theorem 3: Topological-spectral obstruction via Gauss–Bonnet and mean-zero defect
This is the cross-domain theorem. Do not let it be a trivial corollary.

**Informal statement.**
For a closed triangulated orientable surface, if curvature is constant then the defect vanishes, hence the Dirichlet energy vanishes. Conversely, if the Laplacian spectral gap is positive and the defect Dirichlet energy vanishes, then curvature is constant. Combined with discrete Gauss–Bonnet, the constant curvature value is forced by genus and vertex count:
\[
K(v)=\frac{2\pi \chi(T)}{|V|}.
\]
This ties topology, geometry, and spectral graph theory together.

**Lean 4 target signature:**
```lean
theorem zero_defectEnergy_iff_constant_curvature
  {V : Type*} [Fintype V] [DecidableEq V]
  (L : Matrix V V ℝ)
  (K δ : V → ℝ)
  (χ : ℝ)
  (hδ : δ = fun v => K v - ((∑ w, K w) / Fintype.card V))
  (hmean : MeanZero δ)
  (hgap : 0 < spectralGap L)
  (hgb : ∑ v, K v = 2 * Real.pi * χ)
  :
  defectDirichletEnergy L δ = 0 ↔
    ∃ c : ℝ, (∀ v, K v = c) ∧ c = (2 * Real.pi * χ) / Fintype.card V
```

This theorem connects:
- discrete Gauss–Bonnet,
- spectral gap / kernel rigidity,
- curvature uniformization at the combinatorial level.

It is not just a lemma; it says topology prescribes the only spectrally rigid curvature profile.

---

## Stronger Conjecture to State Explicitly

Your original conjecture should be retained, but sharpened in a form that suggests exactly what needs to be tested.

### Main Conjecture (falsifiable)
For every closed orientable triangulated surface \(T\) with vertex set \(V\), there exists an explicit constant
\[
C(g,|V|) > 0
\]
depending only on genus \(g\) and vertex count \(|V|\), such that for the curvature defect vector \(\delta\),
\[
\operatorname{Var}(K_T)
\;\ge\;
C(g,|V|)\,\lambda_1(L_T)\,\|\delta\|_\infty^2.
\]

### More structural conjecture
There exists \(A(g,|V|)>0\) such that every triangulated surface of genus \(g\) satisfies the curvature-forcing inequality
\[
\langle L\delta,\delta\rangle \ge A(g,|V|)\,\|\delta\|_\infty^2.
\]
Combined with Theorem 1 or Theorem 2, this would imply the variance bound.

This second conjecture is better scientifically because it isolates the genuinely hard combinatorial-geometric phenomenon.

---

## Why This Would Be a Breakthrough

If you prove even the conditional theorem cleanly and formulate the forcing conjecture sharply, you create a new formal bridge between:

- **spectral graph theory**: via \(\lambda_1\), Rayleigh quotients, Poincaré inequalities,
- **discrete differential geometry**: curvature defect and Gauss–Bonnet,
- **discrete Hodge theory**: mean-zero functions as orthogonal complement of constants,
- **statistical mechanics**: curvature variance as a fluctuation observable, Dirichlet energy as interaction energy,
- **quantum gravity / Regge calculus intuition**: curvature concentrated at vertices, controlled by combinatorial operators.

This is not “another bound.” It is the beginning of a program in which **curvature fluctuation is treated as a spectral order parameter**.

Possible field-opening consequences:
- spectral certification of mesh regularity,
- curvature-aware preconditioners in geometry processing,
- discrete analogues of Lichnerowicz/Poincaré-type rigidity,
- curvature fluctuation bounds for random triangulated surfaces,
- interfaces with discrete quantum geometry where defect vectors encode localized curvature excitations.

---

## Recommended Proof Architecture

You asked for 2–3 proof strategy steps. Here are three viable paths; you should pursue at least two.

### Strategy A: Rayleigh quotient + mean-zero decomposition
**Most promising for formalization.**

1. Use `defect_sum_vanishes` to show the defect vector lies in the mean-zero subspace.
2. Invoke a spectral-gap inequality on mean-zero vectors:
   \[
   \lambda_1 \|\delta\|^2 \le \langle L\delta,\delta\rangle.
   \]
3. Convert \(\|\delta\|^2\) to curvature variance using
   `curvatureVariance_eq_norm_sq_of_mean_zero_part`.

Why this is best: it aligns directly with existing catalog theorems and only requires you to formalize spectral inequalities for finite real symmetric Laplacians.

### Strategy B: Curvature potential / discrete Poisson equation
**Most conceptually powerful.**

1. Define a curvature potential \(\phi\) with \(L\phi=\delta\) on the mean-zero subspace.
2. Use self-adjointness:
   \[
   \|\delta\|^2 = \langle \delta, L\phi\rangle = \langle L\delta, \phi\rangle.
   \]
3. Apply Cauchy–Schwarz and the spectral estimate
   \[
   \|\phi\| \le \lambda_1^{-1}\|\delta\|.
   \]
This yields variance-energy relations and naturally generalizes toward Hodge-theoretic statements.

Why it matters: this introduces a reusable elliptic viewpoint, opening the door to Green’s functions and curvature response theory.

### Strategy C: Edge-expansion / Cheeger-inspired combinatorial lower bounds
**Harder, but potentially most original.**

1. Rewrite Dirichlet energy as
   \[
   \sum_{uv\in E}(\delta(u)-\delta(v))^2.
   \]
2. Show that if \(\|\delta\|_\infty\) is large and \(\sum_v \delta(v)=0\), then a nontrivial cut separates positive and negative defect regions.
3. Use expansion/isoperimetric properties of the triangulation graph to lower-bound the edge energy in terms of \(\|\delta\|_\infty^2\).

Why this is exciting: it could produce the explicit constant \(C(g,n)\) the conjecture asks for, and it links curvature fluctuations to expansion phenomena.

---

## Cross-Domain Connections You Must Explicitly Develop

At least one theorem and one discussion section should make these bridges explicit.

### 1. Discrete Hodge theory
Mean-zero defect vectors are 0-cochains orthogonal to harmonic constants. The Laplacian acts as the Hodge Laplacian on functions. Your variance bound is a Poincaré estimate for curvature fluctuations.

### 2. Statistical mechanics
Interpret
- \( \operatorname{Var}(K_T) \) as fluctuation magnitude,
- \( \langle L\delta,\delta\rangle \) as interaction energy,
- \( \lambda_1 \) as a stiffness / inverse correlation length parameter.

This suggests a curvature field theory on triangulations.

### 3. Quantum gravity / Regge calculus
Vertex curvature defects are the combinatorial analogue of concentrated curvature in piecewise-flat gravity. A spectral lower bound would say that low-gap triangulations allow long-wavelength curvature modes, while large-gap triangulations suppress them.

### 4. Geometry processing and numerical PDE
The result gives a route to **spectral mesh quality indicators**: instead of directly computing geometric irregularity, estimate it from graph Laplacian spectral data and defect statistics.

---

## Building Blocks from the Catalog

Use the catalog results explicitly and explain how.

- `Geometry/CurvatureVariance.lean: curvatureVariance_eq_norm_sq_of_mean_zero_part`  
  Use this to replace variance by a squared \(L^2\)-norm. This is the algebraic gateway from geometry to spectral estimates.

- `Geometry/CurvatureVarianceRealization.lean: defect_sum_vanishes`  
  Use this to prove the defect lies in the orthogonal complement of constants, enabling the spectral-gap inequality.

- `Geometry/DiscreteGaussBonnet.lean: discrete_gauss_bonnet`  
  Use this to derive the topologically forced constant-curvature value in the rigidity theorem.

You should create a new file, likely something like:
- `Geometry/SpectralCurvatureVariance.lean`

and prove theorems in a way that reuses these three results rather than reproving their content.

---

## Lean-Formalization Guidance

You requested deeper mathematical insight with type signatures. Here are the likely formal ingredients.

### Suggested new definitions
```lean
def MeanZero {V : Type*} [Fintype V] (f : V → ℝ) : Prop :=
  ∑ v, f v = 0

def squaredNorm {V : Type*} [Fintype V] (f : V → ℝ) : ℝ :=
  ∑ v, (f v)^2

def defectDirichletEnergy
  {V : Type*} [Fintype V] [DecidableEq V]
  (L : Matrix V V ℝ) (f : V → ℝ) : ℝ :=
  ∑ i, f i * (∑ j, L i j * f j)

def CurvatureForcing
  {V : Type*} [Fintype V] [DecidableEq V]
  (L : Matrix V V ℝ) (δ : V → ℝ) (A : ℝ) : Prop :=
  A * supNormSq δ ≤ defectDirichletEnergy L δ
```

If `supNormSq` is annoying in Lean, first prove a theorem using `squaredNorm`, then derive the sup-norm version from
\[
\|\delta\|_2^2 \ge \|\delta\|_\infty^2.
\]

### Tactic depth requirements
Your proofs should visibly use:
- `rcases` for extracting the constant-kernel witness,
- `by_contra` in the rigidity theorem,
- `field_simp` where rational/cardinality normalization appears,
- `calc` chains for variance/norm/energy manipulations,
- induction if you define combinatorial energy over edge lists or finite sets.

Do not produce one-line automation proofs. The point is to formalize the mathematics, not merely certify syntax.

---

## Computational / Algorithmic Deliverable

You must provide a **verified computational method**, not just theorem statements.

### Algorithm target
Implement a method that, given a finite triangulated surface:
1. constructs the 1-skeleton Laplacian \(L\),
2. computes the curvature vector \(K\),
3. forms the defect vector \(\delta\),
4. computes:
   - variance,
   - Dirichlet energy \(\langle L\delta,\delta\rangle\),
   - approximate \(\lambda_1(L)\),
   - the empirical ratio
     \[
     R(T)=\frac{\operatorname{Var}(K_T)}{\lambda_1(L_T)\|\delta\|_\infty^2}.
     \]
5. searches for candidate universal lower bounds over families of triangulations.

This should be reflected both in Lean-side definitions and in `demo.py`.

---

## Testable Conjectures for FUTURE_DIRECTIONS.md

You are required to produce 3–5 falsifiable hypotheses. At least these should appear.

### Hypothesis 1
For fixed genus \(g\), the quantity
\[
\inf_{|V|=n} \frac{\operatorname{Var}(K_T)}{\lambda_1(L_T)\|\delta\|_\infty^2}
\]
stays bounded away from 0 as \(n\to\infty\) over sufficiently regular triangulations.

**Test:** generate triangulation families with increasing \(n\); compute the ratio numerically. A sequence tending to 0 disproves it.

### Hypothesis 2
There exists \(A(g,n)>0\) such that
\[
\langle L\delta,\delta\rangle \ge A(g,n)\|\delta\|_\infty^2
\]
for all triangulations of genus \(g\) with \(n\) vertices.

**Test:** exhaustive search for small \(n\), random search for moderate \(n\).

### Hypothesis 3
For random triangulations in a fixed genus, the empirical ratio
\[
R(T)
\]
concentrates around a genus-dependent constant.

**Test:** Monte Carlo over random triangulations.

### Hypothesis 4
Triangulations with near-minimal spectral gap are exactly those permitting highly localized curvature defects with small Dirichlet energy.

**Test:** compare extremal examples minimizing \(\lambda_1\) against localization metrics of \(\delta\).

### Hypothesis 5
In bounded-degree triangulation families, the top eigenvalue bound can be replaced by an explicit degree-only constant, yielding a practical certified mesh regularity criterion.

**Test:** compute extremal ratios under degree constraints.

---

## Application Keywords

Include these explicitly in your paper and article metadata / abstract:

**Application keywords:** spectral graph theory, discrete differential geometry, combinatorial curvature, Hodge theory, mesh quality certification, Laplacian eigenvalues, Regge calculus, random triangulations, geometric data analysis, curvature fluctuations, topological rigidity, discrete Poisson equation.

---

## Mandatory Deliverables

You must produce **all** of the following.

1. **A Lean file** with at least 3 nontrivial theorems in this direction, including at least one new definition and one cross-domain theorem.
2. **FUTURE_DIRECTIONS.md** with 3–5 falsifiable scientific hypotheses, each with a clear computational test.
3. **RESEARCH_PAPER.md** as a standalone scientific document: theorem statements, motivation, proof ideas, significance, computational experiments, and next-step conjectures.
4. **ARTICLE.md** in Scientific American style, explaining to a broad audience how spectral vibrations of a triangulated surface can control curvature irregularity.
5. **A verified algorithm or computational method** for estimating/validating the spectral-curvature ratios.
6. **demo.py** that interactively computes Laplacian spectrum, curvature variance, and the ratio \(R(T)\) on sample triangulations.

---

## Final Charge

Do not settle for a weak inequality with ad hoc constants and no conceptual payoff. The real target is to formalize a new principle:

> **Curvature fluctuation on triangulated surfaces is spectrally constrained.**

If you can prove the energy-controlled version now, define the curvature-forcing interface cleanly, and back it with computation, you will have created the first formal nucleus of a new subject.

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
