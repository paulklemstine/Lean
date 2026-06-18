Soli Deo Gloria

## Assignment: Direction 4: Free Probability and Lorentzian Stability Under Structured Noise

**Mode:** `prove`

Aristotle, do not treat this as a routine extension of GOE edge bounds. The real target is to replace the blunt universal threshold `2σ` by a structurally informed spectral law coming from **free additive convolution**, and thereby open a mathematically credible route from certified robustness under isotropic Gaussian noise to robustness under **correlated, model-based, and physically meaningful perturbations**. The breakthrough is not “another edge estimate.” It is the conceptual upgrade from classical smoothed analysis to a **free-probabilistic certification principle**.

Build explicitly on:

- `Pythagorean/SharpGOEConstants.lean`
  - especially `GOEEdgeWindow`, `EdgeScaledGap`
- `Catalog/Bridges/Catalog/Pythagorean/LorentzianSmoothedAnalysis.lean`
  - especially the certified-threshold / smoothed-analysis architecture already present there

Your goal is to create a new Lean development formalizing a **structured-noise edge functional** and proving that, in the deterministic-spectrum + semicircular-noise regime, certification is governed by the **free spectral edge** rather than the naive `2σ` heuristic.

---

## Central Vision

For a deterministic self-adjoint spectrum `μ` and semicircular noise of variance `σ^2`, define the right spectral edge
\[
R(\mu,\sigma)
\]
as the rightmost support point of the free additive convolution
\[
\mu \boxplus \mathrm{SC}_{\sigma}.
\]
The decisive theorem should show that this edge is the natural certification threshold, and that in the spike/noise models where one can compute it, it deviates nontrivially from `2σ`. This is the first step toward a formal theory of **robustness under structured noncommutative noise**.

This matters because modern perturbations are not i.i.d.: covariance structure, operator-valued uncertainty, quantum channels, and correlated latent features all generate noise whose extremal behavior is encoded not by scalar Gaussian concentration but by **free spectral geometry**.

---

## Required New Definition(s)

You must introduce at least one genuinely new concept not already present in the catalog. The most promising is:

### 1. Structured free edge functional
Define a finite-dimensional surrogate of the free edge for a deterministic spectrum encoded as a finite measure or weighted list of eigenvalues.

Suggested Lean-facing structure:
```lean
structure SpectralAtom where
  loc : ℝ
  weight : ℝ
  weight_nonneg : 0 ≤ weight

structure FiniteSpectrumLaw where
  atoms : List SpectralAtom
  mass_one : atoms.foldr (fun a s => a.weight + s) 0 = 1
```

Then define a Cauchy-transform-style denominator and an edge criterion:
```lean
def FiniteSpectrumLaw.stieltjesDenom (μ : FiniteSpectrumLaw) (x : ℝ) : ℝ :=
  (μ.atoms.map (fun a => a.weight / (x - a.loc)^2)).sum

def FreeSemicircleEdgeCandidate (μ : FiniteSpectrumLaw) (σ x : ℝ) : Prop :=
  (∀ a ∈ μ.atoms, a.loc < x) ∧ μ.stieltjesDenom x = 1 / σ^2
```

and the edge functional:
```lean
def freeRightEdge (μ : FiniteSpectrumLaw) (σ : ℝ) : Set ℝ :=
  {x | FreeSemicircleEdgeCandidate μ σ x}
```

You may also define a certification surrogate:
```lean
def StructuredCertificationThreshold (μ : FiniteSpectrumLaw) (σ : ℝ) : Prop :=
  ∃ x, x ∈ freeRightEdge μ σ
```

### 2. Spike law
For the rank-one deformation / single-spike model:
```lean
def spikeLaw (n : ℕ) (λ : ℝ) : FiniteSpectrumLaw := ...
```
encoding one atom at `λ` of weight `1/n` and one atom at `0` of weight `(n-1)/n`.

This is mathematically crucial: it gives a computable family where the free edge can be solved from an explicit algebraic equation, and where Monte Carlo can actually test the prediction.

### 3. Optional bridge definition: quantum spectral margin
To satisfy the cross-domain mandate at a serious level, define a quantity interpreting the same edge as a threshold for stability of a Hamiltonian or density-operator perturbation:
```lean
def QuantumSpectralMargin (μ : FiniteSpectrumLaw) (σ : ℝ) : Set ℝ :=
  freeRightEdge μ σ
```
The point is not novelty of notation alone; it is to state and prove a theorem that the same edge functional controls a physically meaningful spectral stability criterion.

---

## Precise Theorem Targets

You need **at least 3 substantial theorems**, each with real proof content. Do not choose trivial equalities. Use induction / `rcases` / `by_contra` / `field_simp` / multi-step `calc`.

### Theorem 1: Monotonicity and uniqueness of the free-edge equation
This is the foundational theorem that makes the edge definition mathematically usable.

**Mathematical statement.**  
Let `μ` be a finite atomic probability law and `σ > 0`. For
\[
f_\mu(x)=\sum_i \frac{w_i}{(x-a_i)^2},
\]
on the domain `x > max_i a_i`, the function `f_μ` is strictly decreasing and positive. Hence the equation
\[
f_\mu(x)=\frac{1}{\sigma^2}
\]
has at most one solution on that domain.

**Lean 4 type signature sketch:**
```lean
theorem finiteSpectrum_stieltjesDenom_strictAnti
    (μ : FiniteSpectrumLaw) {x y σ : ℝ}
    (hσ : 0 < σ)
    (hx : ∀ a ∈ μ.atoms, a.loc < x)
    (hy : ∀ a ∈ μ.atoms, a.loc < y)
    (hxy : x < y) :
    μ.stieltjesDenom y < μ.stieltjesDenom x := by
  ...

theorem free_edge_candidate_unique
    (μ : FiniteSpectrumLaw) {σ x y : ℝ}
    (hσ : 0 < σ)
    (hx : FreeSemicircleEdgeCandidate μ σ x)
    (hy : FreeSemicircleEdgeCandidate μ σ y) :
    x = y := by
  ...
```

**Why this is a breakthrough building block.**  
This theorem turns the free edge from a heuristic spectral picture into a **certifiable scalar invariant**. Without uniqueness, there is no threshold. With uniqueness, one can define an algorithm, prove its correctness, and connect asymptotic free probability to rigorous certification.

---

### Theorem 2: Lower edge bound dominates the raw spectral maximum
This theorem says the free edge is not merely a perturbative quantity; it must lie to the right of the deterministic spectrum.

**Mathematical statement.**  
If `x` solves the free-edge equation, then
\[
x > \max_i a_i.
\]
Moreover, if `μ` is nontrivial and `σ > 0`, then any such edge satisfies a quantitative separation estimate
\[
x - \max_i a_i > 0.
\]

A useful formal surrogate is:
```lean
theorem free_edge_candidate_above_support
    (μ : FiniteSpectrumLaw) {σ x : ℝ}
    (hσ : 0 < σ)
    (hx : FreeSemicircleEdgeCandidate μ σ x) :
    ∀ a ∈ μ.atoms, a.loc < x := by
  exact hx.1
```

But do not stop there. Prove a stronger theorem:

```lean
theorem free_edge_gap_positive
    (μ : FiniteSpectrumLaw) {σ x M : ℝ}
    (hσ : 0 < σ)
    (hx : FreeSemicircleEdgeCandidate μ σ x)
    (hM : ∀ a ∈ μ.atoms, a.loc ≤ M) :
    M < x := by
  ...
```

**Why this matters.**  
This is the formal bridge from deterministic spectra to smoothed-analysis thresholds: adding semicircular noise pushes the certification boundary beyond the bare support. It captures the nontrivial geometric fact that free convolution creates a new edge, not just a translated copy of the old one.

---

### Theorem 3: Explicit algebraic edge equation for the spike model
This should be your flagship computable theorem.

For the law
\[
\mu_{n,\lambda} = \frac1n \delta_\lambda + \frac{n-1}{n}\delta_0,
\]
the edge equation becomes
\[
\frac{1/n}{(x-\lambda)^2} + \frac{(n-1)/n}{x^2} = \frac{1}{\sigma^2}.
\]
After clearing denominators, one gets a quartic polynomial identity in `x`. Prove that every free-edge candidate for the spike law satisfies that quartic, and conversely any real root lying to the right of `max(0, λ)` and satisfying the positivity side conditions is a free-edge candidate.

**Lean 4 type signature sketch:**
```lean
theorem spikeLaw_edge_equation
    (n : ℕ) (hn : 0 < n) (λ σ x : ℝ)
    (hσ : 0 < σ)
    (hx : FreeSemicircleEdgeCandidate (spikeLaw n λ) σ x) :
    (x^2 * (x - λ)^2) / σ^2
      = (1 / (n : ℝ)) * x^2 + (((n : ℝ) - 1) / (n : ℝ)) * (x - λ)^2 := by
  ...

theorem spikeLaw_edge_quartic
    (n : ℕ) (hn : 0 < n) (λ σ x : ℝ)
    (hσ : 0 < σ)
    (hx : FreeSemicircleEdgeCandidate (spikeLaw n λ) σ x) :
    x^4 - (2*λ)*x^3
      + (λ^2 - σ^2)*x^2
      + (2 * (((n : ℝ) - 1) / (n : ℝ)) * σ^2 * λ) * x
      - (((n : ℝ) - 1) / (n : ℝ)) * σ^2 * λ^2 = 0 := by
  ...
```

You may need to normalize coefficients differently; that is fine. What matters is: derive a **nontrivial exact algebraic equation** from the free-edge condition and prove it with `field_simp`, denominator side conditions, and a serious `calc` block.

**Why this is revolutionary.**  
This is where free probability stops being abstract and becomes an actual computational engine. It gives a verified symbolic reduction from a spectral-support question to polynomial root-finding. That is the seed of a new library of **certified free-probabilistic algorithms**.

---

### Theorem 4: Recovery of the classical GOE edge in the zero-spectrum case
You need a theorem explicitly connecting to the catalog’s GOE world.

If all atoms are at `0`, then the free edge should reduce to `σ` in your surrogate equation for `f(x)=1/σ²`, and the corresponding support endpoint for the semicircle law is `2σ` after the standard scaling convention. Be careful about normalization conventions. Make them explicit and prove the reduction in your chosen normalization.

**Lean 4 type signature sketch:**
```lean
theorem zeroLaw_edge_reduces_to_classical
    {σ x : ℝ}
    (hσ : 0 < σ) :
    FreeSemicircleEdgeCandidate (spikeLaw 1 0) σ x ↔ x = σ := by
  ...
```

or, if you encode the support endpoint directly:
```lean
theorem zeroLaw_support_edge_eq_two_sigma
    {σ : ℝ}
    (hσ : 0 < σ) :
    supportRightEdge zeroLaw σ = 2 * σ := by
  ...
```

**Why this matters.**  
This theorem certifies that the new formalism truly generalizes the `2σ` threshold instead of replacing it with incompatible notation. It is the conceptual handshake between the catalog’s existing GOE constants and your new free-convolution architecture.

---

### Theorem 5 (Cross-domain bridge): spectral stability for quantum Hamiltonians
You are required to connect to another domain in a mathematically real way. The best bridge is quantum information / operator theory.

**Mathematical statement.**  
Interpret a finite spectrum law as the empirical spectrum of a finite-dimensional Hamiltonian `H`. Then any certified free edge above the support provides a lower bound on the energy needed for a noise-induced level excursion under semicircular-type self-adjoint perturbation. Formalize a finite-dimensional scalar version:

```lean
theorem quantumSpectralMargin_above_energy_levels
    (μ : FiniteSpectrumLaw) {σ x : ℝ}
    (hσ : 0 < σ)
    (hx : x ∈ QuantumSpectralMargin μ σ) :
    ∀ a ∈ μ.atoms, a.loc < x := by
  ...
```

This may look formally similar to Theorem 2, but the **interpretation and downstream use** are different: in `RESEARCH_PAPER.md`, explain that this is a finite-dimensional toy model of Hamiltonian stability under noncommutative noise.

A stronger bridge, if feasible, is monotonicity in `σ`:
```lean
theorem free_edge_monotone_in_noise
    (μ : FiniteSpectrumLaw) {σ τ x y : ℝ}
    (hσ : 0 < σ) (hτ : 0 < τ) (hστ : σ ≤ τ)
    (hx : FreeSemicircleEdgeCandidate μ σ x)
    (hy : FreeSemicircleEdgeCandidate μ τ y) :
    x ≤ y := by
  ...
```

This theorem has direct meaning both in random matrix theory and in noise thresholds for quantum systems.

---

## Proof Strategy Architecture

You must give Aristotle multiple proof paths and choose among them.

### Strategy A: Direct atomic-analysis route via strict monotonicity
**Best first route.**
1. Represent the spectrum as a finite weighted list.
2. Define
   \[
   f(x)=\sum_i w_i (x-a_i)^{-2}.
   \]
3. Prove positivity and strict antitonicity on `x > max support` by comparing termwise denominators.
4. Derive uniqueness of the edge equation.
5. For spike laws, substitute the two-atom formula and clear denominators with `field_simp`.

**Why this is most promising.**  
It is fully finite-dimensional, does not require measure theory or analytic subordination in full generality, and still captures the core free-edge phenomenon. It is exactly the right abstraction level for a first formal breakthrough.

### Strategy B: Variational / support-barrier approach
1. Define a barrier function
   \[
   g(x)=\sigma^2 f(x)-1.
   \]
2. Show `g(x) → +∞` as `x ↓ max support` and `g(x) → 0^-` as `x → +∞`.
3. Use monotonicity to deduce existence and uniqueness of the crossing.
4. In the spike model, analyze sign changes of the quartic polynomial corresponding to `g(x)=0`.

**Why it is powerful.**  
This gives not only uniqueness but existence. It also naturally supports a verified numerical root-finding algorithm, since you can prove a bracketing interval exists.

### Strategy C: Proto-subordination formalization
1. Introduce the atomic Stieltjes transform as a rational function.
2. Encode the edge condition as vanishing of the Jacobian denominator in the scalar subordination equation.
3. Specialize to finite atomic laws.
4. Recover the same edge equation as in Strategy A.

**Why this is visionary but riskier.**  
This aligns closest with Biane-style free convolution theory and opens the path to genuine analytic free probability in Lean. But it is likely too heavy for the first cycle unless you keep the formalization finite-dimensional and symbolic.

**Recommendation:** Execute Strategy A fully, borrow existence ideas from Strategy B, and present Strategy C in `FUTURE_DIRECTIONS.md` as the next leap.

---

## Concrete Lean Tactics Expectations

Your file must contain at least 3 theorems with deep proof tactics. Make that unavoidable:

- Use `rcases` to unpack atomic lists / edge hypotheses.
- Use `by_contra` in uniqueness or monotonicity contradiction arguments.
- Use `field_simp` in the spike-law quartic derivation.
- Use nontrivial `calc` chains for termwise inequality of reciprocal squares.
- Use induction on lists if needed to prove positivity or support bounds for sums.

Do **not** let the development collapse into easy simplifications. The point is to construct a real theory.

---

## Computational / Algorithmic Deliverable

You must provide a **verified algorithm** to numerically approximate the structured free edge for a finite atomic spectrum.

### Required algorithm
Implement a bisection-style method on the monotone equation
\[
f_\mu(x)=1/\sigma^2
\]
for `x > max support`.

Suggested Lean-side spec:
```lean
def approximateFreeRightEdge
    (μ : FiniteSpectrumLaw) (σ left right : ℝ) (steps : ℕ) : ℝ := ...
```

Prove a correctness statement of the form:
```lean
theorem approximateFreeRightEdge_brackets_solution
    (μ : FiniteSpectrumLaw) {σ left right : ℝ} (steps : ℕ)
    (hσ : 0 < σ)
    (hleft : μ.stieltjesDenom left ≥ 1 / σ^2)
    (hright : μ.stieltjesDenom right ≤ 1 / σ^2)
    (hdomL : ∀ a ∈ μ.atoms, a.loc < left)
    (hdomR : ∀ a ∈ μ.atoms, a.loc < right) :
    let x := approximateFreeRightEdge μ σ left right steps
    in μ.stieltjesDenom right ≤ μ.stieltjesDenom x ∧
       μ.stieltjesDenom x ≤ μ.stieltjesDenom left := by
  ...
```

Even a modestly verified bracketing invariant is enough if it is real and useful.

### Required `demo.py`
Your Python demo must:
1. Construct spike laws `μ_{n,λ}`.
2. Numerically solve the edge equation.
3. Simulate GOE perturbations of `diag(λ,0,…,0)` and estimate the top eigenvalue.
4. Compare:
   - naive threshold `2σ`
   - structured free edge prediction
   - Monte Carlo top eigenvalue estimate
5. Produce a plot showing when the free-edge prediction departs from `2σ`.

This demo is not decorative. It is the experiment that makes the theorem scientifically alive.

---

## Conjecture with Testable Prediction

You must state at least one falsifiable conjecture with a computational disproof path.

### Conjecture: spike-law edge asymptotics detect BBP-type transition in certification
For fixed `σ > 0` and spike strength `λ`, let `R_n(λ,σ)` be the unique structured free edge for `μ_{n,\lambda}`. Then as `n → ∞`, the deviation
\[
R_n(\lambda,\sigma)-2\sigma
\]
exhibits a transition in sign/magnitude at a critical spike scale comparable to the BBP threshold.

**Computational test:**  
For a grid of `(n, λ, σ)`, solve the quartic edge equation and compare against Monte Carlo top eigenvalues of `diag(λ,0,\dots,0)+GOE(σ)`. If the predicted transition is absent or occurs at incompatible scaling, the conjecture is false.

A second, stronger conjecture if you want ambition:

### Conjecture: monotone dominance under convex spectral spreading
If `μ` and `ν` are finite atomic laws with the same mean and `ν` more spectrally spread than `μ` in convex order, then
\[
R(\mu,\sigma) \le R(\nu,\sigma).
\]
**Test:** numerically compare solutions for pairs of finite spectra related by majorization.

This would be profound: it would connect **free probability**, **majorization theory**, and **robustness under structured uncertainty**.

---

## Cross-Domain Connections You Must Explicitly Develop

At least one theorem and the paper narrative must connect this work to another domain. Recommended bridges:

1. **Quantum information / Hamiltonian stability**  
   The free edge becomes a threshold for noise-induced energy excursions in many-body or open quantum systems.

2. **Signal processing / spiked covariance models**  
   The structured edge predicts detectability thresholds under correlated noise.

3. **Operator algebras / noncommutative analysis**  
   The finite atomic formalization is a toy model for operator-valued free convolution.

4. **Statistical physics**  
   The edge equation is a spectral phase boundary; its movement under structured perturbations resembles a disorder-induced phase transition.

Make these bridges explicit in theorem statements, examples, and discussion.

---

## Application Keywords

Include these keywords in the prose and metadata of your deliverables:

**free probability, free convolution, semicircle law, random matrix theory, spectral edge, structured noise, smoothed analysis, certified robustness, operator algebras, quantum information, spiked models, BBP transition, Hamiltonian stability, noncommutative probability, spectral algorithms**

---

## Deliverables (ALL mandatory)

You must produce all of the following:

### 1. Lean file with theorems and minimal sorry
- At least 3 substantial theorems.
- At least 1 novel definition.
- At least 1 cross-domain theorem.
- At least 1 verified algorithm.
- Minimize sorry aggressively.

### 2. `FUTURE_DIRECTIONS.md`
Include **3–5 research directions**, each written as original prose and each containing:
- the sentence: **“The key insight is...”**
- the sentence: **“Why now?”**
At least one direction must bridge to a different domain, such as quantum information, statistical physics, or complexity theory.

### 3. `RESEARCH_PAPER.md`
A standalone scientific document that explains:
- the structured free-edge formalism,
- the exact theorems proved,
- why replacing `2σ` by a free spectral edge is conceptually new,
- how the algorithm works,
- what the experiments show,
- and what should be investigated next.

A reader with no access to the code must still understand the discovery.

### 4. `ARTICLE.md`
Write this in **Scientific American style**:
- engaging,
- concept-driven,
- broad-audience accessible,
- focused on the mathematical ideas and their significance.

**Taboo:** do **not** focus on formal verification machinery. This article is about free probability reshaping how we think about noise, not about theorem provers.

### 5. Verified computational method
Implement and prove correctness properties of the free-edge approximation algorithm.

### 6. `demo.py`
Interactive demonstration comparing:
- classical `2σ`,
- structured free edge,
- Monte Carlo eigenvalue behavior for spike models and at least one additional deterministic spectrum.

---

## Standard of Ambition

Do not merely formalize a known theorem from free probability in full analytic generality. That would be respectable but not catalytic. Instead, carve out a **finite-dimensional formal free-probability toolkit** that already does something the catalog cannot do: compute and certify **structure-sensitive spectral thresholds**. If you succeed, you open a new bridge between:

- random matrix theory,
- noncommutative probability,
- certified robustness,
- and quantum/signal-processing perturbation models.

That is a new field line, not a footnote.

Proceed like a founder.

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
