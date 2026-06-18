Soli Deo Gloria

## Assignment: Direction 3: Tropical Geometry of Entanglement Spectra

**Mode:** `prove`

You are to push the Newton-entropy hierarchy into a genuinely new asymptotic regime: a **tropical theory of entanglement spectra** for free-fermion states. The goal is not to repackage known log-concavity, but to extract a new geometric object from the elementary symmetric polynomials of a spectrum and prove that it obeys rigid convexity laws strong enough to support algorithms and falsifiable predictions.

Build explicitly on:

- `Pythagorean/NewtonEntropyHierarchy.lean`
  - `esymmCoeff`
  - `esymm_newton_inequality`
- `Catalog/Bridges/LorentzianNewton.lean`
  - `newton_inequality`

Your task is to define the tropicalized profile attached to a finite spectrum `λ : Fin m → ℝ≥0`, prove nontrivial structural theorems about it, and connect it to a second domain: **quantum information / statistical mechanics** via grouped spectra and asymptotic dominance.

## Core mathematical vision

For a free-fermion entanglement spectrum `λ₁, …, λ_m`, consider the generating polynomial
\[
E_\lambda(t) := \prod_{i=1}^m (1+\lambda_i t)
= \sum_{k=0}^m e_k(\lambda)\, t^k.
\]
The classical Newton inequalities say the coefficient sequence `e_k` is log-concave. The breakthrough is to show that after tropicalization, the profile
\[
k \mapsto \log e_k(\lambda)
\]
behaves like a **discrete concave potential**, and under grouped/gapped spectra it is controlled by a **piecewise-linear tropical envelope** determined by spectral sectors. This would be a tropical analogue of entanglement thermodynamics: dominant quasiparticle bands become linear faces of a Newton polygon.

This opens a field: **tropical entanglement geometry**. It would allow one to study many-body spectra using Newton polytopes, discrete convex analysis, and asymptotic optimization, rather than only analytic inequalities.

## Precise formal targets

You must introduce at least one genuinely new definition not already present in the catalog.

### New definitions to introduce

Define a normalized tropical profile for a finite nonnegative spectrum:
```lean
def tropicalProfile {m : ℕ} (λ : Fin m → ℝ) : ℕ → ℝ
```
intended to satisfy
\[
\mathrm{tropicalProfile}\ \lambda\ k = \log\big(e_k(\lambda)\big)
\]
on the valid range, with a convention outside `k ≤ m`.

Define its discrete slope:
```lean
def tropicalSlope {m : ℕ} (λ : Fin m → ℝ) (k : ℕ) : ℝ :=
  tropicalProfile λ (k+1) - tropicalProfile λ k
```

Define a grouped-spectrum model capturing spectral gaps / degeneracy sectors:
```lean
structure SpectralBlock where
  weight : ℝ
  multiplicity : ℕ
  nonneg : 0 ≤ weight

def blockSpectrum : List SpectralBlock → Fin (blocks.foldr (fun b n => b.multiplicity + n) 0) → ℝ
```
or an equivalent formalization.

Define a tropical upper envelope attached to blocks:
```lean
def blockEnvelope (B : List SpectralBlock) : ℕ → ℝ
```
modeling the max-plus contribution from choosing `r_j` particles from each block:
\[
\max \left\{ \sum_j r_j \log w_j \;\middle|\; \sum_j r_j = k,\ 0 \le r_j \le m_j \right\}.
\]

This definition is the heart of the project: it is the tropicalized free energy / microcanonical variational principle for grouped entanglement spectra.

## Theorem package to prove

You must prove at least 3 substantial theorems, and they must use real proof structure: induction, `rcases`, `by_contra`, `field_simp`, multi-step `calc`, or similar. No trivial enumeration proofs.

### Theorem 1: Discrete concavity from Newton
Formalize the statement that the tropical profile is midpoint-concave on valid indices.

Mathematical statement:
For every finite nonnegative spectrum `λ` with positive elementary symmetric coefficients on adjacent indices,
\[
2 \log e_k(\lambda) \ge \log e_{k-1}(\lambda) + \log e_{k+1}(\lambda)
\quad (1 \le k < m).
\]
Equivalently, the slope sequence is weakly decreasing:
\[
\mathrm{tropicalSlope}(\lambda,k) \le \mathrm{tropicalSlope}(\lambda,k-1).
\]

Suggested Lean theorem signature:
```lean
theorem tropicalProfile_concave
    {m : ℕ} (λ : Fin m → ℝ)
    (hnonneg : ∀ i, 0 ≤ λ i)
    (hpos : ∀ k, k ≤ m → 0 < esymmCoeff λ k) :
    ∀ k, 1 ≤ k → k + 1 ≤ m →
      2 * tropicalProfile λ k
        ≥ tropicalProfile λ (k-1) + tropicalProfile λ (k+1)
```

A slope version is also welcome:
```lean
theorem tropicalSlope_antitone
    {m : ℕ} (λ : Fin m → ℝ)
    (hnonneg : ∀ i, 0 ≤ λ i)
    (hpos : ∀ k, k ≤ m → 0 < esymmCoeff λ k) :
    ∀ k, 1 ≤ k → k + 1 ≤ m →
      tropicalSlope λ k ≤ tropicalSlope λ (k-1)
```

Why this is a breakthrough:
This theorem upgrades Newton’s inequality from a coefficient inequality to a **discrete tropical curvature law**. It identifies `log e_k` as a discrete concave potential, which is exactly the kind of structure tropical geometry and discrete convex analysis can exploit.

### Theorem 2: Block spectra give piecewise-linear tropical envelopes
For grouped spectra with constant value on each block, prove that the tropical envelope is concave and piecewise linear in `k`, with slope changes only when a block saturates.

Mathematical statement:
If the spectrum consists of blocks with weights `w₁ > w₂ > ··· > w_s ≥ 0` and multiplicities `m₁, …, m_s`, then the max-plus envelope
\[
F(k)=\max\Big\{\sum_j r_j \log w_j : \sum_j r_j = k,\ 0 \le r_j \le m_j\Big\}
\]
is a concave piecewise-linear function of `k`, and its discrete slopes are exactly the multiset
\[
\underbrace{\log w_1,\dots,\log w_1}_{m_1},
\underbrace{\log w_2,\dots,\log w_2}_{m_2},\dots
\]
in decreasing order.

Suggested Lean theorem signature:
```lean
theorem blockEnvelope_slopes
    (B : List SpectralBlock)
    (hstrict : B.Chain' (fun a b => b.weight < a.weight))
    (hpos : ∀ b ∈ B, 0 < b.weight) :
    ∃ N : ℕ,
      N = B.foldr (fun b n => b.multiplicity + n) 0 ∧
      ∀ k, k < N →
        ∃ w, tropicalSlope (blockSpectrum B) k = Real.log w
```
A stronger theorem describing exact multiplicities of slopes is ideal, even if the formal statement uses list counting rather than direct geometric language.

Why this is a breakthrough:
This is the precise tropical manifestation of spectral gaps. Distinct entanglement bands become linear facets of a Newton polygon. The theorem turns the heuristic “gaps create corners” into a certified statement.

### Theorem 3: Tropical profile is bounded by the block envelope, with equality in the exactly degenerate case
For a block-constant spectrum, prove the tropical profile is controlled by the block envelope; in the idealized degenerate case, the dominant tropical term is exactly the envelope.

Mathematical statement:
For any grouped spectrum,
\[
\log e_k(\lambda) \le \log\!\Big(\#\mathcal{C}_k\Big) + F(k),
\]
where `F(k)` is the block envelope and `\#\mathcal{C}_k` counts admissible block occupancies. In the strict tropical limit where only the dominant monomial is retained, equality holds with `F(k)`.

Suggested Lean theorem signature:
```lean
theorem tropicalProfile_le_blockEnvelope_plus_count
    (B : List SpectralBlock)
    (hpos : ∀ b ∈ B, 0 < b.weight) :
    ∀ k,
      tropicalProfile (blockSpectrum B) k
        ≤ blockEnvelope B k + Real.log (admissibleOccupancyCount B k)
```

If you can formalize a clean exact statement for a two-block model, do it:
```lean
theorem twoBlock_blockEnvelope_exact
    (a b : ℝ) (p q : ℕ)
    (h : b < a) (ha : 0 < a) (hb : 0 < b) :
    ∀ k, k ≤ p + q →
      blockEnvelope [⟨a,p,le_of_lt ha⟩, ⟨b,q,le_of_lt hb⟩] k
        = Real.log a * min k p + Real.log b * (k - min k p)
```

Why this is a breakthrough:
This theorem creates the bridge from exact algebra to tropical asymptotics. It says the full entanglement polynomial is shadowed by a variational max-plus object. That is the formal seed of a tropical large-deviation principle.

## Cross-domain theorem requirement

You must include at least one theorem connecting tropical geometry to a different domain. The most natural and ambitious option here is:

### Theorem 4: Statistical-mechanical variational principle for block spectra
Interpret `blockEnvelope` as the zero-temperature limit of a partition optimization problem. Prove a finite-dimensional max-vs-log-sum-exp inequality:
\[
\max_i a_i \le \log\sum_i e^{a_i} \le \max_i a_i + \log n.
\]
Then instantiate it for block occupancies to derive Theorem 3.

Suggested Lean theorem signatures:
```lean
theorem max_le_log_sum_exp
    (s : Finset α) (a : α → ℝ) :
    s.Nonempty →
    s.sup' ?h a ≤ Real.log (∑ i in s, Real.exp (a i))
```

```lean
theorem log_sum_exp_le_max_add_log_card
    (s : Finset α) (a : α → ℝ)
    (h : s.Nonempty) :
    Real.log (∑ i in s, Real.exp (a i))
      ≤ s.sup' h a + Real.log s.card
```

Then use these to bound `tropicalProfile` by `blockEnvelope`.

Why this matters:
This is the bridge to **statistical mechanics**. The tropical envelope is the zero-temperature free energy, and the entanglement profile becomes a thermodynamic object. This is exactly the kind of cross-pollination that can open a new line of research.

## Conjecture with falsifiable computational prediction

You must state and computationally test a conjecture.

### Conjecture: asymptotic tropical segmentation by spectral gaps
For any sequence of block spectra
\[
\lambda^{(m)} = (\underbrace{w_1,\dots,w_1}_{\lfloor \alpha_1 m\rfloor},
\dots,
\underbrace{w_s,\dots,w_s}_{\lfloor \alpha_s m\rfloor}),
\quad w_1>\cdots>w_s>0,
\]
the normalized profile
\[
\phi_m(x) := \frac{1}{m}\,\log e_{\lfloor xm\rfloor}(\lambda^{(m)})
\]
converges pointwise on `x ∈ [0,1]` to a concave piecewise-linear function whose slope multiset is
\[
\{\log w_1 \text{ on } [0,\alpha_1],\ \log w_2 \text{ on } [\alpha_1,\alpha_1+\alpha_2],\dots\}.
\]

A Lean-ready placeholder for documentation:
```lean
def AsymptoticTropicalSegmentationConjecture : Prop := ...
```

### Testable prediction
For randomly generated two- and three-block spectra, if you plot
\[
k \mapsto \log e_k(\lambda)
\]
and its discrete slopes, then the slopes should cluster into plateaus near `log w_j`, with transition locations near cumulative multiplicities. If this fails for clean block models at large size, the conjecture is false.

Your `demo.py` must compute:
1. exact `e_k` values,
2. the tropical profile,
3. the discrete slope profile,
4. the block envelope,
5. overlay plots showing agreement / deviation.

## Proof strategy architecture

You must present and exploit multiple proof paths, not a single hint.

### Strategy A: Newton → logarithmic concavity → discrete tropical concavity
1. Use `esymm_newton_inequality` / `newton_inequality` to obtain
   \[
   e_k^2 \ge e_{k-1}e_{k+1}.
   \]
2. Under positivity assumptions, apply monotonicity of `Real.log` and convert multiplicative inequalities into additive inequalities.
3. Rearrange into midpoint concavity and then prove antitonicity of discrete slopes by a multi-step `calc`.

Why promising:
This directly leverages the catalog and gives a clean formal path. It is the most reliable route for Theorem 1.

### Strategy B: Combinatorial occupancy optimization for block spectra
1. Expand `e_k` for a block spectrum as a sum over occupancy vectors `r_j` with binomial multiplicity weights.
2. Define the tropical envelope by dropping subdominant terms and keeping the maximum weight contribution.
3. Prove exact formulas in the two-block case by induction on `k` and case-splitting on whether the first block is saturated.
4. Generalize to many blocks via a greedy/exchange argument: if `w_i > w_j`, any optimizer must fill block `i` before block `j`.

Why promising:
This is the right route to piecewise-linearity. It converts spectral gaps into a discrete optimization problem, where tropical geometry naturally lives.

### Strategy C: Statistical mechanics / log-sum-exp sandwich
1. Write the block expansion of `e_k` as a finite sum of exponentials.
2. Apply the max-vs-log-sum-exp inequalities to compare `log e_k` with the maximal occupancy energy.
3. Control the entropy term by `log(cardinality of occupancy set)`.
4. Infer that after normalization by system size, the entropy correction vanishes, yielding the tropical limit heuristic.

Why promising:
This is the most conceptually revolutionary route because it interprets the tropical profile as a zero-temperature free energy. It is the best strategy for the cross-domain theorem and the conjectural asymptotic picture.

**Most promising overall:** combine A + B. Strategy A gives immediate certified curvature; Strategy B gives the geometric mechanism for piecewise-linear faces. Strategy C then packages the result into a thermodynamic interpretation and motivates the asymptotic conjecture.

## Lean-specific implementation guidance

- Be careful with positivity assumptions before taking `Real.log`.
- If the existing `esymmCoeff` is defined on a different domain, adapt your spectrum to the required coefficient type and then map into `ℝ`.
- If exact logarithmic formalization becomes too brittle, prove a multiplicative form first, then derive additive/logarithmic corollaries separately.
- For block spectra, start with the **two-block case**. A complete exact theorem there is already nontrivial and scientifically meaningful.
- Use:
  - induction on `k`,
  - `rcases` on occupancy decompositions,
  - `by_contra` for greedy optimality/exchange lemmas,
  - `field_simp` if rational normalization appears,
  - multi-step `calc` for the log-concavity-to-slope argument.

## Required deliverables

You must produce **all** of the following:

1. **Lean file(s)** containing:
   - at least 3 substantial theorems,
   - at least 1 new definition,
   - at least 1 cross-domain theorem,
   - at least 1 explicit conjecture formalized as a `def` or documented proposition,
   - minimized `sorry` usage.

2. **A verified algorithm or computational method**
   - implement an algorithm to compute `e_k`,
   - compute the tropical profile and slope sequence,
   - compute the block envelope by dynamic programming or greedy optimization in the sorted-block case,
   - prove at least one correctness theorem for the algorithm.

3. **`demo.py`**
   - interactively generate block spectra,
   - compute exact and tropicalized profiles,
   - visualize Newton polygon / slope plateaus,
   - test the conjecture numerically on families with tunable gap parameters.

4. **`RESEARCH_PAPER.md`**
   - standalone scientific paper,
   - define tropical entanglement profile,
   - state and explain the main theorems,
   - explain why spectral gaps become tropical corners,
   - include the asymptotic conjecture and computational evidence,
   - readable without code access.

5. **`ARTICLE.md`**
   - Scientific American style,
   - explain how many-body quantum spectra can be turned into a geometric landscape of slopes and corners,
   - do **not** focus on formal verification machinery,
   - focus on the mathematical and physical ideas.

6. **`FUTURE_DIRECTIONS.md`**
   include 3–5 original research directions, each with:
   - “**The key insight is...**”
   - “**Why now?**”
   At least one direction must bridge to another field, such as:
   - Lorentzian polynomials and matroid entropy,
   - tropical complexity theory,
   - random matrix theory,
   - fermionic large deviations,
   - quantum marginal problems.

## Application keywords

Tropical geometry; entanglement spectrum; free fermions; Newton inequalities; Lorentzian polynomials; discrete concavity; Newton polygon; max-plus algebra; statistical mechanics; zero-temperature free energy; large deviations; spectral gaps; many-body quantum states; combinatorial optimization; quantum information.

## Revolutionary significance

If successful, this project would do more than prove another inequality. It would create a **dictionary**:

- `e_k` coefficients ↔ occupation statistics,
- Newton log-concavity ↔ discrete tropical curvature,
- spectral gaps ↔ slope plateaus / Newton polygon facets,
- log-sum-exp ↔ finite-temperature smoothing,
- tropical envelope ↔ zero-temperature entanglement free energy.

That dictionary could seed an entirely new program: using tropical and Lorentzian methods to study entanglement structure, phase segmentation, and asymptotic spectra in many-body systems. This is not an extension of the catalog. It is a new geometry for quantum information.

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
