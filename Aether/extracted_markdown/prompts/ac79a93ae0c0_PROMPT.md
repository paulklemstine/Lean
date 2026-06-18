Soli Deo Gloria

## Assignment: Direction 1 — Sharp Cutoff for the Adjacent-Transposition-Plus-Cycle Walk on `S_n`

Prove genuinely new theorems about the random walk on the symmetric group generated simultaneously by all adjacent transpositions and the long cycle. The target is not a routine mixing bound: the goal is to isolate a new universality class of permutation walks where **local diffusion plus a single coherent global rotation** produces a cutoff profile at the diffusive time scale.

This problem is mathematically compelling because it sits exactly between two worlds that are usually analyzed separately:

- **local interchange/diffusion phenomena** on Coxeter generators, where time scales are typically `n^2` or `n^3`,
- **global scrambling phenomena** on highly nonlocal generators, where representation theory often diagonalizes the chain.

The adjacent-transposition-plus-cycle walk is neither purely local nor purely global. If you can prove a sharp transition here, you open a new theory of **hybrid-generator cutoff**, with consequences for card shuffling, expander design on nonabelian groups, spectral preconditioning, and Markov-chain design in cryptography and sampling.

Build explicitly on:

- `Pythagorean/CayleyExpander/MixingTime.lean`
  - especially any TV–`L²` comparison lemmas, spectral-gap-to-mixing-time bounds, and observable lower-bound machinery;
- `Bridges/Catalog/Pythagorean/CayleyExpander/SymmetricGroup.lean`
  - especially the certified definitions and lemmas for permutations, adjacent generators, long cycles, and spectral nondegeneracy scaffolding;
- any `Defs.lean` containing `CanonicalPathData` or related congestion frameworks.

Minimize `sorry`. Do not spend your effort on toy lemmas. Establish structural theorems that would matter even outside Lean.

---

## Core mathematical object

Let `μ_n` be the symmetric probability measure on `S_n` supported on
- the adjacent transpositions `(i, i+1)` for `1 ≤ i < n`,
- the long cycle `c_n = (1 2 ... n)` and its inverse.

A natural normalization is
\[
\mu_n = \frac{1}{n+1}\left(\sum_{i=1}^{n-1}\delta_{(i\,i+1)} + \delta_{c_n} + \delta_{c_n^{-1}}\right),
\]
or the lazy version if needed for aperiodicity. You may choose the precise normalization, but it must be fixed clearly and used consistently in both theorem statements and computation.

Define the associated random walk operator
\[
P_n f(\sigma) = \sum_{g \in S_n} \mu_n(g)\, f(g\sigma).
\]

---

## Precise theorem targets

You should aim to formalize at least the following theorem package. If the full cutoff profile is too ambitious in one cycle, prove the strongest certified partial breakthrough and leave a sharply testable conjecture.

### Theorem A — Diffusive spectral gap lower bound

There exist universal constants `c, C > 0` such that for all sufficiently large `n`,
\[
\frac{c}{n^2} \le \gamma_n \le \frac{C}{n^2},
\]
where `γ_n = 1 - λ₂(P_n)` is the spectral gap of the walk.

This theorem is already significant: it proves that adding the long cycle does **not** accelerate the walk to the random-transposition scale, but it does preserve a diffusive regime. That identifies the walk as a new hybrid-diffusive object rather than a mean-field one.

A Lean-style target signature should look like:

```lean
theorem spectralGap_adjTransposition_plus_cycle_lower
    (n : ℕ) (hn : 2 ≤ n) :
    ∃ c : ℝ, 0 < c ∧
      c / (n : ℝ)^2 ≤ spectralGap (adjCycleWalk n) := by
  sorry

theorem spectralGap_adjTransposition_plus_cycle_upper
    (n : ℕ) (hn : 2 ≤ n) :
    ∃ C : ℝ, 0 < C ∧
      spectralGap (adjCycleWalk n) ≤ C / (n : ℝ)^2 := by
  sorry
```

If the library uses a different notion such as `secondLargestEigenvalue`, `dirichletForm`, or `isSpectralGapAtLeast`, adapt accordingly, but keep the statement mathematically exact.

---

### Theorem B — Mixing upper bound at order `n^2 log n`

There exists `C > 0` such that for all `n ≥ 2`,
\[
t_{\mathrm{mix}}^{(n)}(1/4) \le C n^2 \log n.
\]

This is the first genuinely nontrivial mixing theorem to certify. It should be deduced from the gap bound together with a quantitative state-space-size or `L²` comparison estimate already present in the catalog.

Lean-style target:

```lean
theorem mixingTime_adjCycleWalk_upper
    (n : ℕ) (hn : 2 ≤ n) :
    ∃ C : ℝ, 0 < C ∧
      mixingTimeTV (adjCycleWalk n) (1/4 : ℝ) ≤ C * (n : ℝ)^2 * Real.log n := by
  sorry
```

If your catalog defines mixing time on `ℕ` rather than `ℝ`, use ceiling/floor carefully and prove the integer version.

---

### Theorem C — Observable lower bound at order `n^2 log n`

Construct an explicit permutation statistic `F_n : S_n → ℝ` such that
- `F_n` is mean-zero under the uniform measure,
- its expectation under the walk started at identity decays slowly enough to force a total variation lower bound before time `c n^2 log n`.

A concrete candidate is a low-frequency Fourier mode of the cyclic displacement statistic, e.g. a trigonometric observable on the image of a marked card under the long cycle coordinate, or a smoothed descent/inversion imbalance adapted to the cycle action.

Target theorem:

\[
\exists c > 0,\ \forall n \gg 1,\quad
t_{\mathrm{mix}}^{(n)}(1/4) \ge c n^2 \log n.
\]

Lean-style target:

```lean
theorem mixingTime_adjCycleWalk_lower
    (n : ℕ) (hn : 2 ≤ n) :
    ∃ c : ℝ, 0 < c ∧
      c * (n : ℝ)^2 * Real.log n ≤ mixingTimeTV (adjCycleWalk n) (1/4 : ℝ) := by
  sorry
```

This theorem is the conceptual heart of the project. It says the chain genuinely needs `n^2 log n` time, not just `n^2`.

---

### Theorem D — Pre-cutoff or cutoff-window theorem

The full visionary target is:

\[
\exists c > 0,\ \exists w_n = O(n^2),\quad
t_{\mathrm{mix}}^{(n)}(\varepsilon) = c\, n^2 \log n + O_\varepsilon(n^2).
\]

If the full profile limit
\[
d_n(c n^2 \log n + s n^2) \to \Phi(s)
\]
is too difficult in one cycle, prove at least **pre-cutoff**:
\[
\sup_{0<\varepsilon<1/2}\limsup_{n\to\infty}
\frac{t_{\mathrm{mix}}^{(n)}(\varepsilon)}{t_{\mathrm{mix}}^{(n)}(1-\varepsilon)} < \infty.
\]

Lean-style targets:

```lean
theorem precutoff_adjCycleWalk :
    ∃ A B : ℝ, 0 < A ∧ 0 < B ∧
      ∀ n : ℕ, 2 ≤ n →
        A * (n : ℝ)^2 * Real.log n ≤ mixingTimeTV (adjCycleWalk n) (1/4 : ℝ) ∧
        mixingTimeTV (adjCycleWalk n) (1/4 : ℝ) ≤ B * (n : ℝ)^2 * Real.log n := by
  sorry
```

and, if feasible,

```lean
theorem cutoff_window_adjCycleWalk
    (ε : ℝ) (hε1 : 0 < ε) (hε2 : ε < 1/2) :
    ∃ C c : ℝ, 0 < C ∧ 0 < c ∧
      ∀ n : ℕ, 2 ≤ n →
        |mixingTimeTV (adjCycleWalk n) ε - c * (n : ℝ)^2 * Real.log n|
          ≤ C * (n : ℝ)^2 := by
  sorry
```

---

## New definitions you should introduce

You are required to define at least one genuinely new concept not already in the catalog. Here are two strong candidates.

### 1. Hybrid generator walk structure

Define a structure capturing a symmetric walk on `S_n` built from a local generator family plus a global generator family:

```lean
structure HybridPermutationWalk where
  n : ℕ
  localGens : Finset (Equiv.Perm (Fin n))
  globalGens : Finset (Equiv.Perm (Fin n))
  symm_local : ∀ g ∈ localGens, g⁻¹ ∈ localGens
  symm_global : ∀ g ∈ globalGens, g⁻¹ ∈ globalGens
  prob : Equiv.Perm (Fin n) → ℝ
  prob_support :
    ∀ g, prob g ≠ 0 → g ∈ localGens ∪ globalGens
  prob_nonneg : ∀ g, 0 ≤ prob g
  prob_sum_one : ∑ g in (localGens ∪ globalGens), prob g = 1
```

Then instantiate `adjCycleWalk : ℕ → HybridPermutationWalk`.

This is not mere packaging: it opens a reusable theory of cutoff for hybrid local/global random walks.

### 2. Cycle-displacement observable

Define a statistic measuring how far the current permutation is from cycle-equivariance on low Fourier modes. For example, if `ω = exp(2π i / n)`, consider
\[
F_n(\sigma) = \sum_{j=1}^n \omega^{\sigma(j)-j}.
\]
Or use its real part if complex-valued observables are inconvenient in the current library.

A Lean-style real-valued surrogate:

```lean
def cycleDisplacementObservable (n : ℕ) (σ : Equiv.Perm (Fin n)) : ℝ := ...
```

Then prove variance and contraction bounds for it.

This is novel and important: it bridges permutation mixing with harmonic analysis on the discrete circle.

---

## Proof strategy architecture

You must provide at least 2–3 proof pathways and choose the most promising one.

### Strategy A — Canonical paths + catalog mixing inequalities
Most promising for a first certified breakthrough.

1. **Construct canonical paths** from identity to any permutation using a decomposition into adjacent transpositions, with occasional use of the long cycle to rebalance positions globally.
2. **Bound edge congestion** in the Cayley graph using the `CanonicalPathData` infrastructure from `Defs.lean`. The key point is to show that the long cycle reduces congestion constants but does not change the `n^2` diffusive scaling.
3. **Deduce `γ_n ≥ c/n^2`** from the canonical path theorem in the catalog.
4. **Combine with TV–`L²` comparison** from `MixingTime.lean` and `|S_n| = n!` to get
   \[
   t_{\mathrm{mix}} \lesssim \gamma_n^{-1}\log |S_n| \asymp n^2 \log n.
   \]

Why this is promising: it is robust, formalizable, and likely already supported by the library. It gives a theorem of independent value even before the full cutoff profile.

### Strategy B — Explicit slow observable via harmonic analysis on the cycle coordinate
Most promising for the lower bound and window scale.

1. Mark a card, or define a low-frequency statistic on cyclic displacement.
2. Show the adjacent transpositions act like a discrete Laplacian on this observable, while the long cycle acts as a rigid rotation.
3. Derive a one-step contraction factor
   \[
   \mathbb E[F(X_{t+1}) \mid X_t] \approx \left(1 - \frac{c}{n^2}\right)F(X_t),
   \]
   at least in expectation.
4. Compare expectation to equilibrium variance to force TV distance lower bounds up to time `c' n^2 log n`.
5. If possible, identify the second mode and derive an `O(n^2)` window.

Why this is exciting: it would reveal a hidden Fourier mechanism inside a nonabelian walk and produce the first real candidate for the cutoff profile constant.

### Strategy C — Comparison with interchange/exclusion dynamics on the path plus rotation
Cross-domain and conceptually deep.

1. Project the permutation walk to the trajectory of one or several labeled cards.
2. Show that these projected dynamics compare to a random walk on the discrete circle/path with occasional rotations.
3. Transfer spectral and mixing information from one-particle or few-particle diffusions.
4. Use comparison theorems to lift back to the full permutation walk.

Why this matters: it links nonabelian group random walks with interacting particle systems and statistical mechanics. Even partial success would be field-opening.

Recommendation: pursue **A + B** in the current cycle. A secures the upper bound and diffusive scale; B is the route to a real lower bound and possibly the window.

---

## Cross-domain connections you must exploit

This project should not remain isolated inside finite-group random walks. Make at least one theorem explicitly bridge to another domain.

### Bridge 1 — Statistical mechanics / exclusion processes
Adjacent transpositions are the algebraic shadow of local particle exchange. The long cycle is a coherent drive. This makes the walk a permutation-level analogue of a **driven diffusive system**. Formalize at least one theorem comparing your observable or spectral gap to a discrete Laplacian / exclusion-process quantity.

Possible theorem shape:

```lean
theorem cycleObservable_contraction_compares_discreteLaplacian
    (n : ℕ) (hn : 2 ≤ n) :
    ∃ c C : ℝ, 0 < c ∧ 0 < C ∧
      ∀ σ, c / (n : ℝ)^2 * ‖cycleDisplacementObservable n σ‖
          ≤ ...
          ∧ ... ≤ C / (n : ℝ)^2 * ‖cycleDisplacementObservable n σ‖ := by
  sorry
```

### Bridge 2 — Cryptography / mixing by local-plus-global updates
A walk that alternates local adjacent swaps with a deterministic-style global rotation is exactly the architecture of many lightweight scrambling heuristics. If your theorem shows an `n^2 log n` barrier, that gives a mathematically certified warning: **hybrid local/global scrambling may remain diffusive despite the global move**.

### Bridge 3 — Harmonic analysis / representation theory
Even if full irreducible decomposition is hard, your low-frequency observable is a shadow of a representation-theoretic mode. Make this explicit in the paper and, if possible, in one theorem connecting permutation statistics to eigenfunction-like behavior.

---

## Conjecture with falsifiable prediction

You must state at least one conjecture that can fail under computation.

### Main conjecture
There exists an explicit constant `c_* > 0` and a nontrivial profile `Φ : ℝ → [0,1]` such that
\[
\lim_{n\to\infty} d_n(c_* n^2 \log n + s n^2) = \Phi(s)
\quad \text{for every } s \in \mathbb R.
\]

### Testable prediction
Let
\[
r_n(\varepsilon) = \frac{t_{\mathrm{mix}}^{(n)}(\varepsilon)}{n^2 \log n}.
\]
Then for `ε ∈ {0.25, 0.5, 0.75}`, the sequence `r_n(ε)` for `n = 5,6,7,8` should stabilize toward the same constant `c_*`, while
\[
\frac{t_{\mathrm{mix}}^{(n)}(0.25) - t_{\mathrm{mix}}^{(n)}(0.75)}{n^2}
\]
should remain bounded away from both `0` and `∞`.

A stronger falsifiable conjecture:
the dominant nontrivial eigenmode is represented by the cycle-displacement observable, so that
\[
1-\lambda_2(P_n) \sim \kappa/n^2
\]
for an explicit `κ` matching the discrete Laplacian constant of the first Fourier mode.

This is highly testable numerically by sparse eigensolvers for `n ≤ 8`.

---

## Concrete theorem list for the Lean file

Your file must contain at least 3 substantial theorems with nontrivial proofs. A strong minimal set is:

1. **Spectral-gap lower bound via canonical paths**
   - uses induction / `rcases` / multistep inequalities.
2. **Mixing upper bound from spectral gap and state-space size**
   - uses `calc`, logarithmic estimates, and catalog TV–`L²` comparison.
3. **Observable lower bound forcing `n^2 log n`**
   - uses contradiction or expectation/variance comparison.
4. Optional but desirable: **pre-cutoff theorem** or **observable contraction theorem**.

Do not waste one of the three slots on bookkeeping.

---

## Computational method requirement

You must deliver a verified computational method, not just a theorem statement.

### Required algorithm
Implement an algorithm that constructs the transition matrix of the walk on `S_n`, computes or approximates:
- total variation profiles,
- second eigenvalue magnitude,
- candidate observable decay curves.

If exact arithmetic becomes expensive, use certified rational or interval bounds where feasible.

Suggested Python deliverables:
- enumerate `S_n` for `n ≤ 8`,
- build sparse transition matrices,
- compute powers or Krylov approximations,
- estimate `t_mix(ε)`,
- compare rescaled curves.

The algorithm should directly test the conjectured `n^2 log n` law and the `O(n^2)` window.

---

## Application keywords

Include these explicitly in your write-up and code comments where relevant:

**cutoff phenomenon, symmetric group, Cayley graph, adjacent transposition walk, long cycle, spectral gap, canonical paths, total variation mixing, Fourier mode, discrete Laplacian, exclusion process, card shuffling, cryptographic scrambling, nonabelian Markov chains, universality, sparse matrix computation**

---

## Mandatory deliverables

You must produce **all** of the following:

1. **Lean file(s)** proving the main theorems with minimal `sorry`.
2. **A verified algorithm or computational method** for exact/approximate TV profiles and spectral data.
3. **`demo.py`** demonstrating the result interactively:
   - choose `n = 5,6,7,8`,
   - compute/plot TV distance versus time,
   - rescale time by `n^2` and by `n^2 log n`,
   - estimate spectral gap and mixing ratios.
4. **`RESEARCH_PAPER.md`** as a standalone scientific paper:
   - define the walk,
   - state theorems precisely,
   - explain the significance,
   - discuss why hybrid local/global generators are new,
   - include numerical evidence and next conjectures.
5. **`ARTICLE.md`** in Scientific American style:
   - explain the mathematics and why a single global move does not instantly randomize,
   - taboo: do not focus on formal verification machinery.
6. **`FUTURE_DIRECTIONS.md`** with 3–5 original research directions.
   - Each direction must include the exact sentences:
     - **“The key insight is...”**
     - **“Why now?”**
   - At least one direction must bridge to a different domain, such as statistical mechanics, cryptography, or quantum information.

---

## Final call

Do not settle for “a bound.” Either prove a certified `n^2 log n` upper/lower theorem pair, or isolate the exact obstruction with a new observable and a strong computational profile. The real breakthrough is to show that one coherent global move does not destroy diffusive bottlenecks, but instead creates a sharply analyzable hybrid scrambling regime. If this works, it opens a new chapter in the theory of cutoff on nonabelian groups.

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
