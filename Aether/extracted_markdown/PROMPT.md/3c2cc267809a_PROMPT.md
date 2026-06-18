Soli Deo Gloria

## Assignment: Direction 2: Newton Ratios as Algebraic Order Parameters for Quantum Phases

**Mode:** prove

Build a new bridge from algebraic inequalities to many-body physics: make Newton ratio profiles into a mathematically precise diagnostic for phase structure. The target is not a minor extension of `Pythagorean/NewtonEntropyHierarchy.lean`, but a field-opening theorem scheme showing that the *defect from equality* in Newton’s inequalities can function as an order parameter.

You should treat the catalog theorem
- `Pythagorean/NewtonEntropyHierarchy.lean`
  - `esymm_newton_inequality`
  - `newtonDefect_nonneg`
  - `NewtonRatioProfile`
as the algebraic launchpad. The breakthrough is to show that these purely symmetric-polynomial quantities control, and are controlled by, spectral concentration phenomena that in free-fermion physics encode gapped vs. critical behavior.

## Core Mathematical Vision

For a finite multiset of nonnegative numbers `μ₁, …, μ_n`—thought of as eigenvalues of a reduced correlation matrix—the elementary symmetric polynomials `e_k(μ)` define the **Newton ratio**
\[
\rho_k(\mu) := \frac{e_k(\mu)^2}{e_{k-1}(\mu)e_{k+1}(\mu)}
\quad (1 \le k \le n-1),
\]
whenever the denominator is nonzero. Newton’s inequality says `ρ_k ≥ ((k+1) (n-k+1)) / (k (n-k))` in normalized forms, or at minimum that the associated defect is nonnegative. The physical thesis is that the *profile* of these ratios across `k` detects phase structure.

Your formal work should isolate a mathematically robust version of this thesis that is already nontrivial and provable in Lean, while preparing the route to the full SSH/free-fermion conjecture.

---

## Precise Formal Targets

### New definitions to introduce

Define at least one genuinely new concept, preferably all three:

1. **Newton ratio profile energy**
   \[
   \mathcal N(\mu) := \sup_{1 \le k \le n-1} \left| \log \rho_k(\mu) \right|
   \]
   on strictly positive spectra.

2. **Uniform Newton-gap family**
   A family of finite spectra `μ^(m)` is uniformly Newton-gapped if there exists `C > 0` such that for all subsystem sizes `m` and all admissible `k`,
   \[
   |\log \rho_k(\mu^{(m)})| \le C.
   \]

3. **Asymptotically critical Newton family**
   A family `μ^(m)` is Newton-critical if
   \[
   \sup_k |\log \rho_k(\mu^{(m)})| \to \infty
   \]
   and preferably with a quantitative lower bound `≥ c log m` along a subsequence.

These are not just definitions for bookkeeping: they are the algebraic analogues of gapped and critical phases.

---

## Theorems to Prove

You must prove **at least 3 substantial theorems** with nontrivial tactics and multi-step reasoning. Avoid any theorem whose proof is just computation or simplification.

### Theorem 1: Equality-rigidity / geometric-spectrum characterization

Prove a structural theorem identifying when Newton ratios are exactly flat.

**Mathematical statement**
For a finite positive sequence `x : Fin n → ℝ` with `n ≥ 2`, if the Newton ratio profile is constant and equal to `1` in the strongest normalized sense (or if all Newton defects vanish), then the sequence of elementary symmetric polynomials is geometric:
\[
\forall k,\quad e_k(x)^2 = e_{k-1}(x)e_{k+1}(x)
\]
implies
\[
\exists a b,\quad e_k(x)=a b^k
\]
for all admissible `k`. Strengthen further, if possible, to a classification of the underlying spectrum under suitable nondegeneracy assumptions.

**Lean-style target**
```lean
theorem esymm_geometric_of_all_newton_eq
  {n : ℕ} (hn : 2 ≤ n) (x : Fin n → ℝ)
  (hx : ∀ i, 0 < x i)
  (hEq :
    ∀ k : ℕ, 1 ≤ k → k + 1 < n →
      (esymm x k)^2 = esymm x (k - 1) * esymm x (k + 1)) :
  ∃ a b : ℝ, 0 < a ∧ 0 < b ∧
    ∀ k : ℕ, k < n → esymm x k = a * b^k
```

If the exact statement above needs adjustment to fit the existing `esymm` API, do so, but preserve the content: *vanishing Newton defect forces rigid algebraic structure*.

**Why this is a breakthrough**
This turns Newton inequalities from one-sided constraints into a rigidity principle. In physics language: “perfect saturation” corresponds to an exactly solvable spectral organization. In mathematics language: equality in a log-concavity hierarchy forces hidden linearity in logarithmic coordinates.

---

### Theorem 2: Uniform spectral pinching implies bounded Newton order parameter

Prove a theorem showing that if eigenvalues lie in a fixed multiplicative window, then the Newton profile is uniformly bounded. This is the cleanest formal proxy for “gapped phase implies saturation.”

**Mathematical statement**
If all positive entries of `x` satisfy
\[
0 < a \le x_i \le b,
\]
then there exists a constant `C = C(n,a,b)` such that for every admissible `k`,
\[
|\log \rho_k(x)| \le C.
\]
A stronger and more algebraic version is acceptable:
\[
c(n,a,b) \le \rho_k(x) \le C(n,a,b).
\]

**Lean-style target**
```lean
theorem newtonRatio_bounded_of_spectral_pinching
  {n : ℕ} (hn : 2 ≤ n) (x : Fin n → ℝ)
  (a b : ℝ) (ha : 0 < a) (hab : a ≤ b)
  (hx_lower : ∀ i, a ≤ x i) (hx_upper : ∀ i, x i ≤ b) :
  ∃ C : ℝ, 0 ≤ C ∧
    ∀ k : ℕ, 1 ≤ k → k + 1 < n →
      |Real.log ((esymm x k)^2 / (esymm x (k - 1) * esymm x (k + 1)))| ≤ C
```

A ratio-bound theorem without `Real.log` is also valuable if the log version becomes technically cumbersome:
```lean
theorem newtonRatio_two_sided_bound_of_spectral_pinching ...
```

**Why this matters**
This is the first rigorous step toward the condensed-matter claim: a spectral gap prevents runaway Newton-ratio fluctuations. It formalizes the slogan that “gapped spectra look algebraically tame.”

---

### Theorem 3: Cross-domain theorem — variance / entropy control from Newton defects

You must include at least one theorem connecting this domain to a different area. The best target is information theory or probability.

Define a local defect
\[
\delta_k := \log e_k - \frac12(\log e_{k-1}+\log e_{k+1}),
\]
or equivalently `log ρ_k = 2 δ_k`. Then prove a theorem showing that bounded Newton defect implies discrete concavity of `k ↦ log e_k`, and derive a consequence for concentration, entropy, or unimodality.

**Possible statement**
For positive `e_k`, if `|log ρ_k| ≤ C` for all `k`, then the sequence `k ↦ log e_k` is approximately affine on scales controlled by `C`, yielding quantitative bounds on the displacement of the maximizing index and on the width of the distribution proportional to `e_k`.

A more Lean-friendly exact theorem:
\[
\forall i<j<\ell,\quad
\log e_j \ge \frac{\ell-j}{\ell-i}\log e_i + \frac{j-i}{\ell-i}\log e_\ell - \frac{(\ell-i)^2}{8}C.
\]
This is a discrete semiconcavity theorem from local second-difference bounds.

**Lean-style target**
```lean
theorem log_esymm_semiconcave_of_newtonRatio_bound
  {n : ℕ} (hn : 3 ≤ n) (x : Fin n → ℝ)
  (hx : ∀ i, 0 < x i)
  (C : ℝ) (hC : 0 ≤ C)
  (hbound :
    ∀ k : ℕ, 1 ≤ k → k + 1 < n →
      |Real.log ((esymm x k)^2 / (esymm x (k - 1) * esymm x (k + 1)))| ≤ C) :
  ∀ i j ℓ : ℕ, i < j → j < ℓ → ℓ < n →
    Real.log (esymm x j) ≥
      ((ℓ - j : ℝ) / (ℓ - i : ℝ)) * Real.log (esymm x i) +
      ((j - i : ℝ) / (ℓ - i : ℝ)) * Real.log (esymm x ℓ) -
      ((ℓ - i : ℝ)^2 / 8) * C
```

**Cross-domain significance**
This theorem links:
- algebraic combinatorics: elementary symmetric polynomials,
- discrete convex analysis: second-difference control,
- statistical mechanics / quantum matter: phase diagnostics,
- information theory: entropy-like shape constraints on coefficient profiles.

This is exactly the kind of theorem that opens a new domain rather than polishing an old one.

---

### Theorem 4 (optional but highly desirable): Majorization monotonicity or Schur-convexity phenomenon

If you can define a suitable aggregate Newton functional
\[
\Phi(x) = \sum_k \psi(\rho_k(x))
\]
for convex `ψ`, prove monotonicity under majorization or doubly stochastic smoothing. Even a restricted version would be excellent.

**Lean-style target**
```lean
theorem newtonProfile_smooths_under_averaging
  ...
```

This would connect the subject to matrix analysis and renormalization heuristics: coarse-graining smooths Newton fluctuations.

---

## Recommended Proof Architectures

You must provide and then execute 2–3 possible proof routes in the file comments or paper. Use the most promising one, but record alternatives.

### Strategy A: Discrete log-concavity to affine rigidity
1. Use `esymm_newton_inequality` and `newtonDefect_nonneg` to show `k ↦ log (esymm x k)` has nonpositive second differences wherever defined.
2. For equality-rigidity, prove that vanishing second difference everywhere forces an arithmetic progression in `log (esymm x k)`, hence a geometric progression in `esymm x k`.
3. For quantitative bounds, telescope second-difference estimates to obtain semiconcavity / affine approximation bounds.

**Why promising:** It is closest to existing catalog infrastructure and should formalize cleanly in Lean using induction on intervals and `calc` chains.

### Strategy B: Generating polynomial / real-rootedness route
1. Let `P(t) = ∏ i, (1 + x_i t)` and identify `e_k(x)` as coefficients.
2. Use positivity and real-rootedness to derive strong log-concavity of the coefficient sequence.
3. Translate coefficient inequalities into Newton ratio profile bounds and rigidity statements.

**Why promising:** Conceptually powerful and opens a route to future extensions involving stability theory, but may require more library support for coefficient extraction and polynomial real-rootedness.

### Strategy C: Exterior algebra / fermionic occupancy route
1. Interpret `e_k(x)` as traces of `Λ^k A` for a positive diagonal or diagonalizable operator `A`.
2. Express Newton ratios through multiplicative relations among exterior powers.
3. Prove spectral pinching results by operator inequalities, then specialize back to scalar eigenvalues.

**Why promising:** This is the deepest bridge to quantum physics and matrix analysis. It may not be the shortest Lean path now, but it is scientifically the most revolutionary and should be discussed in the paper even if only partially formalized.

**Most promising formal route:** Strategy A for the main verified theorems, supplemented by Strategy C in the exposition and conjectural section.

---

## Concrete Lean 4 Expectations

Your file should include:
- a new structure or predicate for Newton-bounded / Newton-critical families,
- at least 3 substantial theorems with proofs using tactics such as:
  - induction,
  - `rcases`,
  - `by_contra`,
  - `field_simp`,
  - multi-step `calc`,
- explicit avoidance of trivial proof patterns,
- lemmas controlling positivity of `esymm x k` under `x_i > 0`,
- interval-indexing lemmas for second differences of `log (esymm x k)`.

You should likely create a new file such as:
- `Pythagorean/NewtonQuantumOrderParameters.lean`

and import the catalog file:
- `Pythagorean/NewtonEntropyHierarchy.lean`

---

## Computational/Physical Conjecture to State Precisely

Formalize a falsifiable conjecture, even if not fully proved:

### SSH Newton-order conjecture
For the half-filled SSH chain with subsystem size `m` and reduced correlation spectrum `μ^(m)(δ)` at dimerization parameter `δ`, define
\[
\mathcal N_m(\delta) := \max_{1 \le k \le m-1} |\log \rho_k(\mu^{(m)}(\delta))|.
\]
Then:
1. if `δ ≠ 0` (gapped phase), there exists `C(δ) < ∞` such that
   \[
   \sup_m \mathcal N_m(\delta) \le C(δ);
   \]
2. if `δ = 0` (critical point), there exists `c > 0` such that
   \[
   \mathcal N_m(0) \ge c \log m
   \]
   for infinitely many `m`;
3. the derivative `d/dδ` of a suitably smoothed version of `\mathcal N_m(δ)` develops a nonanalyticity at `δ = 0`.

**Computational test:** numerically diagonalize the subsystem correlation matrix for SSH chains, compute `e_k` stably via recursive symmetric-polynomial updates, and plot `max_k |log ρ_k|` vs. `m` and `δ`. A smooth bounded curve across criticality falsifies the naive conjecture.

---

## Cross-Domain Bridges You Must Exploit

1. **Condensed matter physics:** reduced correlation matrices of Gaussian fermionic states.
2. **Discrete convex analysis:** log-concavity, semiconcavity, discrete Hessians.
3. **Random matrix / Toeplitz theory:** asymptotics of spectra and coefficient profiles.
4. **Information theory:** `log e_k` behaves like a finite-particle entropy profile; bounded Newton defects imply controlled profile curvature.
5. **Lorentzian / strongly log-concave geometry:** use the philosophical link that Newton inequalities are shadows of deeper concavity structures.

At least one theorem in the Lean file should explicitly read as a bridge theorem rather than a purely internal algebra lemma.

---

## Application Keywords

Newton inequalities; elementary symmetric polynomials; free fermions; SSH model; topological phase transition; Toeplitz determinants; Fisher–Hartwig asymptotics; log-concavity; discrete convexity; algebraic order parameter; entanglement spectrum; strong Rayleigh phenomena; majorization; spectral pinching; information-theoretic curvature; random matrix theory; condensed matter mathematics.

---

## Deliverables (ALL MANDATORY)

1. **Lean file(s)** with the new definitions and at least 3 deep theorems, minimizing `sorry`.
2. **A verified algorithm or computational method** for computing Newton ratio profiles stably from a list of positive reals or matrix eigenvalues. This must be more than a theorem statement.
3. **`demo.py`** that interactively demonstrates the SSH test:
   - builds finite SSH correlation matrices,
   - computes Newton ratio profiles,
   - visualizes `max |log ρ_k|` across subsystem size and phase parameter.
4. **`RESEARCH_PAPER.md`** as a standalone scientific paper:
   - define Newton order parameters,
   - state and prove the main theorems,
   - explain the physics motivation,
   - discuss what the theorems do and do not yet prove about phase transitions,
   - include the SSH conjecture and numerical evidence.
5. **`ARTICLE.md`** in Scientific American style:
   - explain the idea that “how tightly an inequality is saturated can reveal a phase of matter,”
   - focus on the mathematics and physics significance,
   - do **not** focus on formal verification machinery.
6. **`FUTURE_DIRECTIONS.md`** with 3–5 original research directions. Each direction must include the exact sentences:
   - **“The key insight is...”**
   - **“Why now?”**
   At least one direction must bridge to a different domain, such as:
   - black hole microstate counting,
   - random tensor networks,
   - coding theory via strongly log-concave weight enumerators,
   - tropical analogues of entanglement spectra.

---

## Final Standard

Do not settle for “Newton ratios are nonnegative” or any theorem that merely restates the catalog. The goal is to make a serious case that Newton defects are *observable algebraic curvature* on coefficient profiles, and that this curvature can distinguish physical regimes. If successful, this opens an entirely new program: **algebraic order parameters from inequality saturation profiles**.

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
