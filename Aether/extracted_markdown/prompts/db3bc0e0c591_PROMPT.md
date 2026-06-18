Soli Deo Gloria

## Assignment: Direction 1 — Sharp Constants and Eigenvalue Interlacing on Augmented Discrete Tori

You are not being asked to tidy up an existing estimate. You are being asked to expose an exact hidden law in the spectral geometry of finite abelian Cayley graphs.

The target is a **precise identity theorem** for the spectral gap of a torus graph after adding a single global diagonal generator. If true, this is not “one more comparison bound.” It is a rigidity phenomenon: a rank-one-looking combinatorial augmentation produces an **exact universal multiplicative speedup** in relaxation, independent of the modulus `n`. That would signal a deeper Fourier-theoretic and interlacing principle for graph unions on abelian groups, and it would suggest a new exact calculus for spectral design of sparse expanders built from local + coherent global moves.

Build directly on:

- `Catalog/Pythagorean/CayleyExpander/HybridLocalGlobal.lean`
- `Catalog/Pythagorean/CayleyExpander/SpectralGap.lean`

Your mission is to go beyond order bounds and prove exact formulas, sharp inequalities, or—if the conjecture fails—construct the exact obstruction and replace the conjecture by the true theorem.

---

## Core Objects

Let
\[
G_{n,d} := (\mathbb Z/n\mathbb Z)^d.
\]

Let `e₁, …, e_d` be the standard basis vectors and let
\[
\delta := (1,1,\dots,1)\in G_{n,d}.
\]

Consider two symmetric generating multisets / sets:

- **local generators**
  \[
  S_{\mathrm{loc}} := \{\pm e_1,\dots,\pm e_d\},
  \]
- **hybrid generators**
  \[
  S_{\mathrm{hyb}} := \{\pm e_1,\dots,\pm e_d,\pm \delta\}.
  \]

Let `L_loc` and `L_hyb` denote the corresponding unnormalized graph Laplacians on functions `f : G_{n,d} → ℝ` (or `ℂ` when using Fourier diagonalization).

The spectral gaps are the smallest positive eigenvalues:
\[
\gamma_{\mathrm{loc}}(n,d),\qquad \gamma_{\mathrm{hyb}}(n,d).
\]

The conjectural identity is:
\[
\gamma_{\mathrm{hyb}}(n,d) \;=\; \frac{d+1}{d}\,\gamma_{\mathrm{loc}}(n,d).
\]

This is equivalent to the exact ratio law
\[
\frac{\gamma_{\mathrm{hyb}}(n,d)}{\gamma_{\mathrm{loc}}(n,d)}=\frac{d+1}{d}.
\]

---

## Precise Theorem Targets

You must aim for **at least 3 substantial theorems**, and at least one must genuinely bridge to another domain.

### Theorem A — Exact local spectral gap formula
For all integers `n ≥ 2`, `d ≥ 1`,
\[
\gamma_{\mathrm{loc}}(n,d)=2-2\cos(2\pi/n)=4\sin^2(\pi/n).
\]

This theorem is foundational, but it must be proved in a way that supports the hybrid theorem: not by ad hoc matrix diagonalization, but through the character basis of the finite abelian group and an exact minimization over nontrivial frequencies.

### Theorem B — Exact hybrid eigenvalue formula
For every frequency `k = (k₁,\dots,k_d) ∈ G_{n,d}`,
\[
\lambda_{\mathrm{hyb}}(k)
=
\sum_{j=1}^d \bigl(2-2\cos(2\pi k_j/n)\bigr)
+
\bigl(2-2\cos(2\pi (k_1+\cdots+k_d)/n)\bigr).
\]

Equivalently,
\[
\lambda_{\mathrm{hyb}}(k)
=
4\sum_{j=1}^d \sin^2(\pi k_j/n)
+
4\sin^2\!\Bigl(\pi(k_1+\cdots+k_d)/n\Bigr).
\]

This is the exact spectral symbol. Once formalized, it becomes reusable infrastructure for many future results.

### Theorem C — Sharp spectral gap theorem or exact obstruction theorem
Prove one of the following, depending on truth:

#### Option C1: Exact identity theorem
For all `n ≥ 2` and `d ≥ 1`,
\[
\gamma_{\mathrm{hyb}}(n,d)=\frac{d+1}{d}\gamma_{\mathrm{loc}}(n,d).
\]

#### Option C2: Corrected sharp theorem
If the conjecture is false, determine the true exact formula or the exact range:
\[
\gamma_{\mathrm{hyb}}(n,d)
=
\min_{k\neq 0}
\left[
4\sum_{j=1}^d \sin^2(\pi k_j/n)
+
4\sin^2\!\Bigl(\pi(k_1+\cdots+k_d)/n\Bigr)
\right],
\]
and prove a sharp theorem of the form
\[
\gamma_{\mathrm{hyb}}(n,d)=c_{n,d}\,\gamma_{\mathrm{loc}}(n,d),
\]
with an explicit closed-form constant `c_{n,d}`, or a sharp universal bound with equality classification:
\[
\frac{d+1}{d} \le c_{n,d} \le 2,
\]
or whatever the true sharp interval is.

If the original conjecture fails, the real breakthrough is to identify **why**: the minimizer may move from coordinate characters to more structured frequency vectors. That is not a failure; it is the beginning of a spectral phase diagram.

### Theorem D — Interlacing / comparison theorem for graph unions
Let `L_A`, `L_B` be Laplacians of two symmetric Cayley graphs on the same finite abelian group. Formalize and prove a theorem showing that in the common character basis,
\[
\lambda_{A\cup B}(\chi)=\lambda_A(\chi)+\lambda_B(\chi),
\]
and deduce a spectral-gap comparison principle:
\[
\gamma_{A\cup B} = \min_{\chi\neq 1}\bigl(\lambda_A(\chi)+\lambda_B(\chi)\bigr).
\]

Then specialize this to the torus + diagonal setting. This is the conceptual theorem: the hybrid graph is not merely “better connected”; it is spectrally additive in Fourier space.

### Theorem E — Cross-domain theorem: discrete diffusion speedup / mixing-time corollary
Connect spectral graph theory to probability or mathematical physics by proving a corollary on the heat semigroup or random walk relaxation time. For example:

If `P_loc`, `P_hyb` are the simple random walk operators associated to the normalized Laplacians, prove an explicit comparison of `L²` mixing rates:
\[
\|P_{\mathrm{hyb}}^t f - \mathbb E f\|_2
\le
e^{-t\gamma_{\mathrm{hyb}}}
\|f-\mathbb E f\|_2,
\]
and hence, under the exact identity theorem,
\[
t_{\mathrm{rel}}^{\mathrm{hyb}}
=
\frac{d}{d+1}\,t_{\mathrm{rel}}^{\mathrm{loc}}.
\]

This is the bridge to **Markov chains / statistical mechanics / diffusion on lattices**.

---

## Lean 4 Formalization Targets

You must include a precise Lean-facing formulation. The exact names may vary to fit Mathlib conventions, but your file should contain theorem statements morally of the following shape.

### Suggested new definitions

Introduce at least one genuinely new concept. For example:

```lean
def diagVec (d n : ℕ) : Fin d → ZMod n := fun _ => 1

def torusStdGen (d n : ℕ) : Finset ((Fin d → ZMod n)) := ...

def torusHybridGen (d n : ℕ) : Finset ((Fin d → ZMod n)) := ...

def laplaceEigenvalueLocal (n d : ℕ) (k : Fin d → ZMod n) : ℝ := ...

def laplaceEigenvalueHybrid (n d : ℕ) (k : Fin d → ZMod n) : ℝ := ...

def spectralGapLocal (n d : ℕ) : ℝ := ...
def spectralGapHybrid (n d : ℕ) : ℝ := ...

def isCoordinateFrequency (n d : ℕ) (k : Fin d → ZMod n) : Prop := ...
```

A stronger novel definition would be something like:

```lean
def FourierSharpAugmentation
    (G : Type*) [Finite G] [AddCommGroup G]
    (S T : Finset G) : Prop := ...
```

capturing when the spectral gap of `S ∪ T` is attained on a prescribed Fourier stratum. That would be genuinely reusable and not already in the catalog.

### Suggested theorem signatures

```lean
theorem spectralGapLocal_torus_exact
    (n d : ℕ) (hn : 2 ≤ n) (hd : 1 ≤ d) :
    spectralGapLocal n d = 4 * Real.sin (Real.pi / n)^2 := by
  ...
```

```lean
theorem laplaceEigenvalueHybrid_fourier
    (n d : ℕ) (k : Fin d → ZMod n) :
    laplaceEigenvalueHybrid n d k
      =
      4 * (∑ i : Fin d, Real.sin (Real.pi * ((k i).val : ℝ) / n)^2)
      + 4 * Real.sin (Real.pi * (((∑ i : Fin d, (k i).val) % n : ℕ) : ℝ) / n)^2 := by
  ...
```

If the trigonometric representation is awkward in Lean, use the cosine form first:

```lean
theorem laplaceEigenvalueHybrid_cos
    (n d : ℕ) (k : Fin d → ZMod n) :
    laplaceEigenvalueHybrid n d k
      =
      (∑ i : Fin d, (2 - 2 * Real.cos (2 * Real.pi * ((k i).val : ℝ) / n)))
      + (2 - 2 * Real.cos (2 * Real.pi * (((∑ i : Fin d, (k i).val) % n : ℕ) : ℝ) / n)) := by
  ...
```

Then derive the sine-square version.

```lean
theorem spectralGapHybrid_ratio_exact
    (n d : ℕ) (hn : 2 ≤ n) (hd : 1 ≤ d) :
    spectralGapHybrid n d = ((d : ℝ) + 1) / d * spectralGapLocal n d := by
  ...
```

If false, replace by a theorem that exactly characterizes the minimizer:

```lean
theorem spectralGapHybrid_eq_inf_fourierSymbol
    (n d : ℕ) (hn : 2 ≤ n) :
    spectralGapHybrid n d
      =
      sInf {x : ℝ | ∃ k : Fin d → ZMod n, k ≠ 0 ∧ x = laplaceEigenvalueHybrid n d k} := by
  ...
```

And then prove the corrected sharp result.

For the cross-domain theorem:

```lean
theorem l2_decay_hybrid_walk
    (n d t : ℕ) (hn : 2 ≤ n) (hd : 1 ≤ d)
    (f : (Fin d → ZMod n) → ℝ) :
    ‖iterate (hybridWalkOp n d) t f - meanValue f‖
      ≤ Real.exp (-(spectralGapHybrid n d) * t) * ‖f - meanValue f‖ := by
  ...
```

The exact operator formalization may differ, but you must include one theorem connecting the spectral computation to diffusion / mixing / heat flow.

---

## Proof Architecture: 3 Viable Strategies

You must not rely on a single brittle route. Develop at least 2–3 proof pathways and decide which one is best after experiments.

### Strategy A — Full Fourier diagonalization on finite abelian groups
**Most promising.**

1. Formalize the character eigenbasis for `(Fin d → ZMod n)` using the finite abelian group Fourier transform already available in Mathlib or lightweight custom lemmas.
2. Show that each character is an eigenvector of the Cayley Laplacian with eigenvalue equal to the generator symbol
   \[
   \sum_{s\in S}(1-\Re \chi(s)).
   \]
3. For the local graph, minimize the symbol over nontrivial frequencies and prove the minimum occurs at a coordinate frequency.
4. For the hybrid graph, derive the exact symbol and solve the minimization problem.

**Why this is best:** it reveals the exact mechanism and generalizes immediately to arbitrary abelian augmentations. It also naturally yields the graph-union theorem and diffusion corollaries.

### Strategy B — Rayleigh quotient + trigonometric convexity
1. Use the Dirichlet form formulas from `HybridLocalGlobal.lean` and `SpectralGap.lean`.
2. Express the Laplacian quadratic form in Fourier coordinates.
3. Prove lower bounds using inequalities for
   \[
   \sin^2(x+y+\cdots) \quad \text{vs.} \quad \sum \sin^2(x_i),
   \]
   or small-angle convexity and frequency counting.
4. Show sharpness by exhibiting explicit test functions corresponding to coordinate characters.

**Why it matters:** even if the exact conjecture fails, this route can still deliver sharp universal inequalities and equality cases.

### Strategy C — Matrix perturbation / interlacing viewpoint
1. Realize the diagonal generator contribution as an additional circulant convolution operator.
2. Show all convolution operators commute and are simultaneously diagonalizable.
3. Interpret the hybrid Laplacian as a structured perturbation of the local one.
4. Use eigenvalue interlacing or symbol addition to identify the second eigenvalue.

**Why this is conceptually powerful:** it links the problem to numerical linear algebra, circulant matrices, and spectral design. It also gives a language for non-abelian analogues later.

---

## Critical Mathematical Insight to Investigate First

Before trying to prove the conjectured ratio, compute the hybrid symbol at coordinate frequencies:
\[
k=e_i \implies \lambda_{\mathrm{hyb}}(e_i)
=
4\sin^2(\pi/n)+4\sin^2(\pi/n)
=
2\,\gamma_{\mathrm{loc}}(n,d).
\]

This already suggests a serious tension with the conjectured factor \((d+1)/d\), since for `d > 1`,
\[
2 \neq \frac{d+1}{d}.
\]

So you must not blindly formalize the conjecture. You must determine whether:

- the local Laplacian normalization in the existing catalog differs from the unnormalized one,
- the hybrid generator is counted differently,
- the spectral gap uses a normalized operator,
- or the conjecture is actually false.

This is exactly the kind of moment where real mathematics begins.

If normalized Laplacians are used, then:
- local degree is `2d`,
- hybrid degree is `2(d+1)`,

and the normalized gaps may indeed satisfy a ratio like
\[
\frac{2\gamma_{\mathrm{loc}}/(2d+2)}{\gamma_{\mathrm{loc}}/(2d)} = \frac{2d}{d+1},
\]
or some variant depending on conventions. You must resolve these conventions precisely and state the theorem in the exact normalization used in the catalog.

This normalization issue is not bookkeeping. It is the heart of the theorem statement.

---

## Cross-Domain Connections You Must Exploit

This project sits at a fertile junction. Make that explicit in both the mathematics and the exposition.

### 1. Harmonic analysis
The exact spectral gap is a minimization of a Fourier symbol over the dual torus. This is finite-group harmonic analysis in its cleanest form.

### 2. Numerical linear algebra / circulant matrices
The Cayley Laplacians are block-circulant operators. The diagonal generator is a coherent structured perturbation. This invites matrix-symbol and interlacing interpretations.

### 3. Probability / Markov chains
The spectral gap controls mixing time, correlation decay, and relaxation to equilibrium. The theorem becomes an exact statement about accelerated diffusion by adding a single nonlocal move.

### 4. Statistical mechanics / lattice transport
Adding the diagonal generator changes the dispersion relation of a discrete Laplacian on a periodic lattice. This is directly analogous to modifying transport channels in crystal models or spin systems.

### 5. Theoretical computer science
The result informs sparse graph design, product replacement heuristics, and communication-efficient augmentation of local networks.

**Application keywords:** spectral gap, Cayley graph, discrete torus, Fourier analysis, circulant matrix, eigenvalue interlacing, graph union, mixing time, lattice diffusion, Markov chain acceleration, abelian harmonic analysis, structured perturbation, expander design.

---

## Concrete Deliverables

You must produce **all** of the following.

### 1. Lean file with at least 3 deep theorems
Requirements:
- no trivial enumeration proofs,
- at least 3 theorems using nontrivial tactics (`induction`, `rcases`, `by_contra`, `field_simp`, multi-step `calc`, etc.),
- at least one novel definition,
- at least one theorem bridging to another domain,
- minimal `sorry`.

### 2. A verified computational method
Implement an algorithm that computes:
- the exact Fourier symbol for all frequencies,
- the spectral gaps `γ_loc(n,d)` and `γ_hyb(n,d)`,
- the ratio under the catalog’s normalization.

This should not be a mere script; it should be tied to a proved correctness theorem when feasible.

### 3. `demo.py`
Interactive demonstration that:
- computes the exact spectral gap ratio for `d = 2,3,4` and `n = 5,...,50`,
- plots the ratio,
- compares conjectured vs actual formula,
- highlights any counterexample automatically.

If the conjecture is false, the demo must become a discovery engine for the corrected law.

### 4. `RESEARCH_PAPER.md`
A standalone scientific paper explaining:
- the exact normalization,
- the spectral symbol,
- the main theorem,
- the proof idea,
- computational evidence,
- the conceptual significance.

A reader with no access to code must still understand the discovery.

### 5. `ARTICLE.md`
Scientific American style. Explain the mathematics as a discovery about how one extra “long-range move” changes diffusion on a periodic world. Do **not** focus on formal verification.

### 6. `FUTURE_DIRECTIONS.md`
Include 3–5 original research directions. Each one must contain the sentences:
- **“The key insight is...”**
- **“Why now?”**

At least one direction must bridge to a genuinely different domain, e.g.:
- quantum walks on augmented tori,
- anisotropic transport in condensed matter models,
- optimal sparse augmentation of communication graphs,
- non-abelian analogues on Heisenberg groups.

---

## Falsifiable Conjecture and Testable Prediction

You must include at least one conjecture that could be disproved computationally.

### Primary conjecture to test
After resolving normalization, one of the following should emerge:

1. **Exact ratio conjecture** under the catalog normalization:
   \[
   \gamma_{\mathrm{hyb}}/\gamma_{\mathrm{loc}} = C_d
   \]
   with explicit `C_d` (possibly `(d+1)/d`, possibly another formula).

2. **Coordinate-minimizer conjecture**:
   the minimum hybrid symbol is always attained at a coordinate frequency `e_i`.

3. **Phase-transition conjecture**:
   for certain normalizations or augmentations, the minimizer changes type as `d` or `n` varies.

### Computational test
For each `d = 2,3,4` and `n = 5,...,50`, enumerate all frequencies `k ∈ (ℤ/nℤ)^d`, compute the exact symbol, and determine:
- the minimum value,
- the set of minimizers,
- whether the minimizer is coordinate-supported,
- whether the ratio matches the predicted constant.

If even one case fails, revise the theorem and explain the new structure.

---

## What Would Make This a Breakthrough

If you prove an exact spectral gap formula for the hybrid torus, you will have done more than settle a conjecture. You will have shown that **coherent sparse augmentation admits exact Fourier control**. That opens a field:

- exact spectral engineering on finite abelian groups,
- optimization of mixing by a handful of global moves,
- sharp graph-union theorems in the Fourier domain,
- a pathway from combinatorial expansion to transport design.

If the original conjecture is false and you discover the corrected law, that may be even better. The decisive result is not “yes” or “no”; it is the exact structure of the minimizer and the sharp formula that replaces folklore intuition.

Do not deliver a small lemma. Deliver the spectral anatomy of hybrid tori.

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
