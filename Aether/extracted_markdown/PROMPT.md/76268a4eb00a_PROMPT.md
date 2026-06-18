Soli Deo Gloria

## Assignment: Direction 3: Lorentzian Control of Glauber Dynamics Mixing

**Mode:** `prove`

Prove genuinely new theorems at the interface of **Lorentzian polynomials, high-dimensional discrete probability, and Markov chain mixing**. The target is not a routine Ising bound, but a new structural principle:

> **Lorentzian curvature of the partition function should force quantitative anti-correlation and a Poincaré/spectral-gap inequality for single-site Glauber dynamics, hence rapid mixing.**

This would open a new program: **Lorentzian MCMC**, where algebraic-combinatorial curvature replaces classical Dobrushin or monotonicity hypotheses.

Build explicitly on:

- `Catalog/Speculative/AutoResearch/LorentzianStability.lean`
  - `strong_concavity_on_orthogonal_complement`
  - `tangent_strong_concavity_of_gapped`

These are not decorative references: they are the geometric engine. The intended leap is to transfer **gapped Lorentzian Hessian control** into **variance contraction for discrete Gibbs measures** and then into **mixing-time bounds** for Glauber dynamics.

---

## Central Theorem Targets

You should formalize a mathematically precise surrogate of the conjecture that is both provable in Lean 4 and strong enough to be scientifically meaningful. If the full Ising-model statement is too ambitious in one cycle, prove the strongest rigorous finite-dimensional theorem that captures the mechanism.

### New definitions to introduce

You must define at least one genuinely new concept. Suggested definitions:

1. `LorentzianGapCertificate`
   - a structure encoding a partition function/log-partition function together with a quantitative one-positive-direction / negative-transverse-curvature condition.

2. `DiscretePoincareCertificate`
   - a structure asserting a variance-vs-Dirichlet-form bound for functions on `{−1,1}^n` or `Fin n → Bool`.

3. `GlauberGenerator`
   - a finite-state Markov generator built from single-site conditional resampling.

4. `PerturbationStableGap`
   - a predicate asserting that under entrywise perturbation bounded by `δ`, the spectral/Poincaré constant degrades by at most a controlled factor.

These should be mathematically motivated, not wrappers around existing notions.

---

## Precise theorem statements with Lean 4 targets

You may need to work with a finite state space `Ω := Fin n → Bool` first, then interpret Ising spins as booleans. If real-spin notation is easier, encode `Bool` to `ℝ` via `cond b 1 (-1)`.

### Theorem 1: Lorentzian transverse concavity gives a quadratic form gap

This theorem should be a direct extraction/extension of the catalog results.

**Mathematical statement.**  
Let `φ : EuclideanSpace ℝ (Fin n) → ℝ` be `C²` in the formal sense available in the catalog, and suppose at a point `x` the Hessian has Lorentzian signature with one positive direction and all orthogonal directions bounded above by `-ε`. Then every `v` orthogonal to the distinguished direction satisfies
\[
\langle v, (\mathrm{Hess}\,\phi)(x)\, v\rangle \le -\varepsilon \|v\|^2.
\]
This is the curvature input for all subsequent variance estimates.

**Lean 4 target signature (schematic):**
```lean
theorem lorentzian_transverse_quadratic_gap
  {n : ℕ} {ε : ℝ} {x u v : EuclideanSpace ℝ (Fin n)}
  (hε : 0 < ε)
  (hgap : LorentzianGapCertificate n ε x u)
  (hvorth : ⟪v, u⟫_ℝ = 0) :
  quadraticFormAt hgap.hess x v ≤ -ε * ‖v‖^2
```

If the exact Hessian interface from the catalog differs, adapt the signature, but keep the theorem explicit and quantitative.

**Why this matters.**  
This is the algebraic curvature statement from which discrete functional inequalities can be bootstrapped. Without a quantitative transverse gap, “Lorentzian” remains qualitative and cannot control dynamics.

---

### Theorem 2: Lorentzian covariance bound implies a Poincaré inequality surrogate

You likely need a finite-state, weighted variance theorem first.

**Mathematical statement.**  
Let `μ` be a strictly positive probability measure on a finite configuration space `Ω`, and suppose its log-density admits a Lorentzian gap certificate in a suitable embedding/statistics map. Then for every observable `f : Ω → ℝ`,
\[
\mathrm{Var}_\mu(f) \le \frac{1}{\varepsilon}\,\mathcal E_\mu(f,f),
\]
where `𝓔_μ` is the single-site Glauber Dirichlet form or a formally simpler surrogate Dirichlet form that you define and prove sufficient.

If the full theorem is too hard immediately, prove first a covariance inequality:
\[
|\mathrm{Cov}_\mu(f,g)| \le \frac{1}{\varepsilon}
\big(\mathcal E_\mu(f,f)\big)^{1/2}\big(\mathcal E_\mu(g,g)\big)^{1/2}.
\]
Then derive the Poincaré inequality by setting `g = f - Eμ f`.

**Lean 4 target signature (schematic):**
```lean
theorem lorentzian_poincare_inequality
  {n : ℕ} {ε : ℝ}
  (hε : 0 < ε)
  (μ : ProbabilityMassFunction (Fin n → Bool))
  (G : GlauberGenerator n μ)
  (hLor : μ.HasLorentzianGap ε)
  (f : (Fin n → Bool) → ℝ) :
  variance μ f ≤ (1 / ε) * dirichletForm G f
```

A covariance version may be:

```lean
theorem lorentzian_covariance_bound
  {n : ℕ} {ε : ℝ}
  (hε : 0 < ε)
  (μ : ProbabilityMassFunction (Fin n → Bool))
  (hLor : μ.HasLorentzianGap ε)
  (f g : (Fin n → Bool) → ℝ) :
  |covariance μ f g| ≤
    (1 / ε) * Real.sqrt (dirichletForm (glauberGenerator μ) f)
                  * Real.sqrt (dirichletForm (glauberGenerator μ) g)
```

**Why this is a breakthrough.**  
This is the bridge theorem. It would translate a signature condition from algebraic combinatorics into a functional inequality central to probability theory. That is exactly the kind of field-opening transfer that creates a new research area.

---

### Theorem 3: Spectral gap / mixing-time bound for Glauber dynamics

Even if total variation mixing is technically heavy, you should at minimum prove a spectral-gap contraction estimate. If possible, then derive a finite-state mixing bound.

**Mathematical statement.**  
Assume the Glauber chain is reversible with respect to `μ` and `μ` satisfies the Lorentzian Poincaré inequality with constant `1/ε`. Then the spectral gap of the Glauber generator is at least `ε / n` (or the strongest normalization-compatible bound you can prove), hence
\[
t_{\mathrm{mix}}(\delta) \le C \,\frac{n}{\varepsilon}\,
\log\!\Big(\frac{1}{\delta\,\mu_{\min}}\Big).
\]
If your generator already averages over `n` sites, the factor of `n` may move; be precise about normalization.

**Lean 4 target signature (schematic):**
```lean
theorem glauber_spectral_gap_lower_bound
  {n : ℕ} {ε : ℝ}
  (hε : 0 < ε)
  (μ : ProbabilityMassFunction (Fin n → Bool))
  (G : GlauberGenerator n μ)
  (hrev : Reversible μ G)
  (hPoin : DiscretePoincareConstant μ G (1 / ε)) :
  spectralGap G ≥ ε / n
```

and, if feasible,

```lean
theorem glauber_mixing_time_bound
  {n : ℕ} {ε δ : ℝ}
  (hn : 0 < n)
  (hε : 0 < ε)
  (hδ : 0 < δ ∧ δ < 1)
  (μ : ProbabilityMassFunction (Fin n → Bool))
  (G : GlauberGenerator n μ)
  (hgap : spectralGap G ≥ ε / n) :
  mixingTimeTV G δ ≤ (n / ε) * Real.log ((μMin μ)⁻¹ / δ)
```

If `mixingTimeTV` is too large a formalization burden for this cycle, prove the `L²` contraction theorem rigorously and state the TV corollary in `RESEARCH_PAPER.md` with the finite-state comparison argument.

**Why this matters.**  
This is the first theorem that says **Lorentzian geometry implies fast MCMC**. It would be conceptually analogous to the role of convexity/log-concavity in continuous sampling, but in a combinatorial discrete setting.

---

### Theorem 4: Stability under coupling perturbations

This theorem is essential: it upgrades a static criterion into a robust scientific principle.

**Mathematical statement.**  
Let `J` and `J'` be two coupling matrices for finite Ising models with
\[
\|J-J'\|_\infty \le \delta, \qquad \delta \le \frac{\varepsilon}{2n^2}.
\]
If `J` has Lorentzian gap `ε`, then `J'` has Lorentzian gap at least `ε/2`, and consequently the associated Glauber Poincaré constant and spectral gap degrade by at most a factor `2`.

**Lean 4 target signature (schematic):**
```lean
theorem glauber_gap_stable_under_coupling_perturbation
  {n : ℕ} {ε δ : ℝ}
  (hε : 0 < ε)
  (hδ : 0 ≤ δ)
  (hsmall : δ ≤ ε / (2 * n^2))
  (J J' : Matrix (Fin n) (Fin n) ℝ)
  (hclose : ∀ i j, |J i j - J' i j| ≤ δ)
  (hLor : IsingCoupling.HasLorentzianGap J ε) :
  IsingCoupling.HasLorentzianGap J' (ε / 2)
```

and a propagated consequence:

```lean
theorem glauber_mixing_stability
  {n : ℕ} {ε δ : ℝ}
  (hε : 0 < ε)
  (hsmall : δ ≤ ε / (2 * n^2))
  (J J' : Matrix (Fin n) (Fin n) ℝ)
  (hclose : ∀ i j, |J i j - J' i j| ≤ δ)
  (hmix : MixingBoundFromLorentzian J ε) :
  MixingBoundFromLorentzian J' (ε / 2)
```

**Why this matters.**  
Robustness is the difference between a fragile theorem and a usable theory. This would make Lorentzian mixing control experimentally testable and numerically stable.

---

## Proof architecture: 3 strategy paths

You must include 2–3 serious proof strategies in your working notes and execute the most promising one.

### Strategy A: Hessian-to-covariance transfer via exponential family coordinates
1. Represent the Ising/Gibbs measure as an exponential family with log-partition function `A(θ)`.
2. Use catalog Lorentzian gap theorems to show strong concavity of a dual potential on the orthogonal complement of the mass/mean direction.
3. Identify covariance of sufficient statistics with second derivatives of `A`; convert the transverse negative curvature into a covariance bound.
4. Upgrade covariance control to a Poincaré inequality for single-site updates via a decomposition of variance into conditional variances.

**Why promising:** this most directly uses the catalog’s strong concavity theorems. It is the cleanest conceptual route from Lorentzian geometry to probability.

### Strategy B: Dirichlet-form comparison through influence matrices
1. Define the influence/correlation matrix for the Gibbs measure.
2. Prove Lorentzian gap implies a quantitative upper bound on off-diagonal correlations or on the operator norm of the centered covariance matrix restricted to the orthogonal complement.
3. Compare the Dirichlet form of Glauber dynamics with the variance via this matrix inequality.
4. Deduce a spectral-gap lower bound by Rayleigh quotient methods.

**Why promising:** more combinatorial and potentially easier to formalize than full Hessian duality. This may be the best route if the exponential-family formalization becomes heavy.

### Strategy C: Perturbative bootstrap from a mean-field solvable model
1. First prove the theorem for Curie–Weiss / complete graph Ising models where partition function and conditional expectations are explicit.
2. Establish a perturbative theorem showing Lorentzian gap and spectral gap are stable under small coupling perturbations.
3. Extend from the solvable model to a neighborhood of couplings with the required gap.

**Why promising:** strongest computational connection and best for demo/simulation.  
**Why less universal:** may prove only a local theorem rather than the full structural result.

**Recommendation:** pursue **Strategy A** for the main theorem, use **Strategy B** as a fallback formal route for the Poincaré estimate, and **Strategy C** for computational validation and a concrete theorem on `K_n`.

---

## Required cross-domain theorem

You must include at least one theorem explicitly connecting this domain to another mathematical domain.

### Suggested cross-domain theorem: algebraic combinatorics ↔ statistical mechanics
Prove that a Lorentzian-gap certificate for the partition polynomial induces a negative/transverse curvature statement for the free energy, interpreted as a thermodynamic susceptibility bound.

**Mathematical form.**
If the partition polynomial `Z(z)` is gapped Lorentzian, then the free energy
\[
F(h) = \log Z(e^h)
\]
has susceptibility matrix bounded on the hyperplane orthogonal to the all-ones direction:
\[
v^\top \nabla^2 F(h)\, v \le \frac{1}{\varepsilon}\|v\|^2.
\]

**Lean target (schematic):**
```lean
theorem lorentzian_free_energy_susceptibility_bound
  {n : ℕ} {ε : ℝ}
  (hε : 0 < ε)
  (Z : MvPolynomial (Fin n) ℝ)
  (hLor : GappedLorentzianPolynomial Z ε)
  (h : EuclideanSpace ℝ (Fin n))
  (v : EuclideanSpace ℝ (Fin n))
  (hv : ⟪v, (fun _ => (1 : ℝ))⟫_ℝ = 0) :
  susceptibilityQuadraticForm Z h v ≤ (1 / ε) * ‖v‖^2
```

This theorem is a direct bridge from **Lorentzian polynomials** to **thermodynamic response theory**.

---

## Conjecture with testable prediction

State and formalize a falsifiable conjecture.

### Conjecture: Lorentzian mixing principle for dense ferromagnets
For Ising models on `K_n` with coupling matrix `J` whose partition polynomial has Lorentzian gap `ε > 0`, the lazy single-site Glauber dynamics satisfies
\[
t_{\mathrm{mix}}(1/4) \le C \frac{n \log n}{\varepsilon}
\]
for a universal constant `C`, and if `‖J-J'‖_∞ ≤ ε/(2n²)`, then
\[
t_{\mathrm{mix}}^{J'}(1/4) \le 2C \frac{n \log n}{\varepsilon}.
\]

### Computational test
Simulate Glauber dynamics on `K_n` for `n ∈ {8,12,16,20}`:
- vary the coupling scale to vary the empirical Lorentzian/susceptibility gap,
- estimate mixing by coupling-from-the-past proxy, autocorrelation decay, or TV proxy from multiple starts,
- perturb couplings entrywise by `≤ ε/(2n²)`,
- test whether `t_mix / (n log n)` scales like `1/ε`.

A failed scaling law or instability under the prescribed perturbation would refute the conjecture.

---

## Lean implementation guidance

You should target a file such as:

`Catalog/Speculative/AutoResearch/LorentzianGlauberMixing.lean`

and explicitly import/build on:

- `Catalog/Speculative/AutoResearch/LorentzianStability.lean`

Possible foundational imports from Mathlib:
- finite probability mass functions,
- matrices and quadratic forms,
- finite-dimensional inner product spaces,
- sums over `Fin n`,
- real logarithm/exponential if needed.

Prefer proving finite-state theorems with explicit sums over `Ω := Fin n → Bool` if abstract Markov-chain infrastructure is too thin. It is perfectly acceptable to define:
- expectation,
- variance,
- covariance,
- Dirichlet form,
- one-step Glauber averaging operator,

directly as finite sums and prove the inequalities from first principles. This often gives stronger control in Lean than chasing abstract APIs.

---

## Minimal deep-proof requirements inside the file

Your file must contain at least **3 nontrivial theorems** whose proofs genuinely use multi-step reasoning. At least three of the following proof styles must appear across the file:

- induction over coordinates/sites/configurations,
- `rcases` decomposition of finite configuration cases or orthogonal decompositions,
- `by_contra` for coercivity/gap arguments,
- `field_simp` in rational-function manipulations from conditional probabilities,
- multi-step `calc` chains comparing variance, covariance, and Dirichlet forms.

Do **not** discharge the core results by brute-force enumeration.

---

## Revolutionary significance

If successful, this project establishes a new paradigm:

- **Algebraic combinatorics:** Lorentzian signatures become quantitative, not just qualitative.
- **Probability theory:** a new sufficient condition for rapid mixing of discrete Gibbs samplers.
- **Statistical physics:** susceptibility and equilibration become controlled by a geometric signature condition.
- **Algorithms/MCMC:** a potentially checkable certificate for when Glauber dynamics is provably efficient.
- **Future field:** “Lorentzian sampling theory,” paralleling the role of convexity in continuous optimization and sampling.

This is not an incremental strengthening of Dobrushin-style bounds. It proposes that a deep algebraic curvature notion can govern stochastic dynamics.

---

## Application keywords

Lorentzian polynomials; Glauber dynamics; Ising model; spectral gap; Poincaré inequality; modified log-Sobolev inequality; covariance decay; Gibbs measures; Markov chain Monte Carlo; algebraic combinatorics; statistical mechanics; susceptibility; perturbation stability; rapid mixing; finite-state reversible chains; free energy curvature.

---

## Mandatory deliverables

You must produce **all** of the following:

1. **A Lean file** with the new definitions and at least 3 deep theorems, minimizing `sorry`.
2. **A verified algorithm or computational method**:
   - implement a certified procedure to estimate the Lorentzian/susceptibility gap proxy and produce a predicted mixing upper bound from couplings;
   - prove at least one correctness theorem relating the computed quantity to your formal bound.
3. **`demo.py`**:
   - simulate Glauber dynamics on `K_n` for `n ∈ {8,12,16,20}`,
   - vary coupling strength and perturbations,
   - estimate empirical mixing diagnostics,
   - compare with the predicted `n log n / ε` trend,
   - visualize stability under perturbations.
4. **`RESEARCH_PAPER.md`**:
   - a standalone scientific paper explaining the definitions, theorems, proof ideas, computational experiment, and significance;
   - readable without any access to code.
5. **`ARTICLE.md`**:
   - Scientific American style,
   - explain the discovery and why it matters to a broad audience,
   - do **not** focus on formal verification machinery.
6. **`FUTURE_DIRECTIONS.md`** with 3–5 original directions.
   Each direction must include:
   - a sentence beginning **“The key insight is...”**
   - a sentence beginning **“Why now?”**
   At least one direction must bridge to a different domain, e.g.:
   - interacting particle systems,
   - matroid theory,
   - optimization,
   - information theory,
   - quantum spin systems.

Be bold. The ideal outcome is not just a theorem, but the birth of a new principle: **Lorentzian curvature controls discrete equilibration.**

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
