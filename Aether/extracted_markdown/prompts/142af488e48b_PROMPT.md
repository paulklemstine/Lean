Soli Deo Gloria

## Assignment: Direction 5 — Tropical Spectral Certificates for Neural Network Robustness

**Mode:** `prove`

## Mission

Do not merely adapt existing certified robustness bounds. Create a new geometric theory of adversarial robustness in which **tropical spectral data of local curvature** replace classical eigenspectral computations. The objective is to prove that, in structured regions of piecewise-linear networks, a **tropical spectral gap** controls the radius of perturbations that preserve local optimality or class separation, yielding certificates that are both mathematically novel and algorithmically cheaper than Euclidean Hessian methods.

This is not “another robustness bound.” This is the beginning of a **tropical second-order theory of deep learning**.

Build explicitly on:

- `Pythagorean/TropicalLorentzianShadows.lean`
  - especially `tropical_to_stability_bridge`
- `Catalog/MachineLearning/TropicalCertifiedRobustness.lean`
  - especially any certified radius lower bounds already formalized there
- `Catalog/Speculative/AutoResearch/LorentzianStability.lean`
  - especially `quadFormBound_of_entry_bound`

Your task is to isolate the correct formal notion of tropical spectral gap, prove it gives a robust radius lower bound under mathematically checkable hypotheses, and implement a verified computational certificate.

---

## Core Vision

Classical second-order certificates rely on eigenvalues of Hessians or smooth curvature surrogates, typically costing cubic time and behaving poorly in high-dimensional piecewise-linear settings. But in ReLU and max-plus-like regimes, geometry is not fundamentally Euclidean — it is **combinatorial, tropical, and regionwise linear-quadratic**. If one can prove that a **tropical gap** extracted from Hessian-like or quadratic surrogate data controls the persistence of a decision margin, then one obtains:

- a new certificate family with lower computational cost,
- a mathematically interpretable bridge between tropical geometry and optimization,
- a foundation for tropical trust-region methods and curvature-aware adversarial defense.

This would open a field: **tropical robustness theory**.

---

## Precise Theorem Targets

You must prove at least **3 nontrivial theorems**, and at least one must be a genuine cross-domain theorem.

Because the exact catalog APIs may differ, you may define the key notions yourself if necessary, but they must be mathematically substantive and not ad hoc.

### New definitions you should introduce

At minimum define one or more of the following in Lean:

1. **Tropical spectral gap** for a finite symmetric matrix:
   - e.g. based on the gap between the two largest tropical cycle means, or
   - a max-plus analogue of the Rayleigh gap, or
   - a combinatorial dominance margin of diagonal-plus-off-diagonal structure.

2. **Lorentzian quadratic leaf**
   - a local quadratic model whose associated symmetric form satisfies a Lorentzian signature surrogate or an entrywise condition sufficient to invoke `quadFormBound_of_entry_bound`.

3. **Tropical curvature certificate**
   - a structure bundling:
     - a quadratic surrogate,
     - a gradient norm bound,
     - a tropical gap lower bound,
     - a third-order remainder control.

Suggested Lean structure:
```lean
structure TropicalCurvatureCertificate (n : ℕ) where
  Q : Matrix (Fin n) (Fin n) ℝ
  gradNorm : ℝ
  gap : ℝ
  remBound : ℝ
  gap_nonneg : 0 ≤ gap
  gradNorm_nonneg : 0 ≤ gradNorm
  remBound_nonneg : 0 ≤ remBound
```

You may refine this substantially.

---

## Main theorem: local tropical robustness from quadratic dominance

A mathematically realistic formal target is the following theorem schema.

### Theorem A — Tropical quadratic robustness lower bound

Let `f : EuclideanSpace ℝ (Fin n) → ℝ` be locally approximated near `x` by
\[
f(x+h) \ge f(x) + \langle \nabla f(x), h \rangle + \tfrac12 Q(h,h) - R \|h\|^3
\]
for `‖h‖ ≤ ρ`, where `Q` is a symmetric quadratic form whose tropical spectral gap is at least `γ > 0`. Assume a catalog theorem converts tropical gap to a stability lower bound for `Q`, i.e.
\[
Q(h,h) \ge \alpha(\gamma)\|h\|^2
\]
for all relevant `h`, with `α(\gamma) > 0`. Then for sufficiently small radius one gets a certified lower bound
\[
\operatorname{robustRadius}(x) \ge
\sup\{ r \le ρ : \tfrac12 \alpha(\gamma) r - R r^2 \ge \|\nabla f(x)\| \}.
\]

A streamlined formal statement could be:

```lean
theorem robustRadius_lower_bound_of_tropical_gap
  {n : ℕ}
  (f : (EuclideanSpace ℝ (Fin n)) → ℝ)
  (x : EuclideanSpace ℝ (Fin n))
  (Q : Matrix (Fin n) (Fin n) ℝ)
  (γ R ρ g α : ℝ)
  (hQsymm : Q.IsSymm)
  (hgap : TropicalSpectralGap Q γ)
  (hα : 0 < α)
  (hbridge : ∀ v, quadraticForm Q v ≥ α * ‖v‖^2)
  (hlocal :
    ∀ h, ‖h‖ ≤ ρ →
      f (x + h) ≥ f x - g * ‖h‖ + (1/2:ℝ) * quadraticForm Q h - R * ‖h‖^3)
  :
  ∀ r, 0 ≤ r → r ≤ ρ →
    g ≤ (1/2:ℝ) * α * r - R * r^2 →
    CertifiedRobustRadius f x r
```

You may need to adapt `CertifiedRobustRadius` to a definition present in the catalog, or define a local surrogate notion if the exact global notion is unavailable.

### Why this is a breakthrough

This theorem would be the first formal statement showing that **tropical spectral information**, rather than ordinary eigenvalue lower bounds, can certify a positive robustness radius through a local second-order model. It changes the language of robustness from “largest singular value / minimum eigenvalue” to “combinatorial curvature dominance.”

---

## Strengthened theorem: explicit exponential-type lower bound

The original research conjecture proposes:
\[
\mathrm{robust\_radius}(x) \ge C \cdot \frac{\exp(\operatorname{tropGap}(\mathrm{Hessian}(x)))}{\|\nabla f(x)\|}.
\]

A formalizable intermediate theorem should derive this from a bridge theorem of the form
\[
\alpha(\gamma) \ge C_0 e^\gamma.
\]

### Theorem B — Exponential tropical certificate

If the catalog bridge plus your new tropical gap notion imply
\[
Q(h,h) \ge C_0 e^\gamma \|h\|^2,
\]
and if the cubic remainder is sufficiently small on the target radius regime, then
\[
\operatorname{robustRadius}(x) \ge C \frac{e^\gamma}{\|\nabla f(x)\| + \varepsilon}
\]
for an explicit `C` depending on the remainder constant and localization radius.

Suggested Lean signature:
```lean
theorem robustRadius_exp_tropGap_lower_bound
  {n : ℕ}
  (f : (EuclideanSpace ℝ (Fin n)) → ℝ)
  (x : EuclideanSpace ℝ (Fin n))
  (Q : Matrix (Fin n) (Fin n) ℝ)
  (γ C0 C ε g ρ R : ℝ)
  (hgap : TropicalSpectralGap Q γ)
  (hbridge : ∀ v, quadraticForm Q v ≥ C0 * Real.exp γ * ‖v‖^2)
  (hlocal :
    ∀ h, ‖h‖ ≤ ρ →
      f (x + h) ≥ f x - g * ‖h‖ + (1/2:ℝ) * quadraticForm Q h - R * ‖h‖^3)
  (hg : g = ‖fderivAt f x‖) -- replace by available gradient notion
  (hC : 0 < C)
  :
  ∃ r > 0, r ≤ ρ ∧
    r ≥ C * Real.exp γ / (g + ε) ∧
    CertifiedRobustRadius f x r
```

You may need to weaken the exact statement if the differentiability API is cumbersome, but preserve the mathematical content: **explicit exponential dependence on tropical gap**.

### Why this matters

This is the theorem that transforms a qualitative geometric insight into a quantitative, testable prediction. It directly motivates experiments and makes the conjecture falsifiable.

---

## Cross-domain theorem: tropical curvature meets optimization or physics

You are required to include at least one theorem connecting this domain to another mathematical domain.

Two strong options:

### Option 1 — Optimization bridge

Prove that a positive tropical spectral gap yields a trust-region lower model improvement bound.

Informally:
\[
\Delta_r := \inf_{\|h\|\le r}
\left(
\langle g,h\rangle + \tfrac12 Q(h,h)
\right)
\]
is controlled from below by the tropical gap via the same `α(γ)` bridge. This ties adversarial robustness to trust-region optimization.

Possible Lean target:
```lean
theorem trustRegion_gain_of_tropical_gap
  {n : ℕ}
  (Q : Matrix (Fin n) (Fin n) ℝ)
  (g : EuclideanSpace ℝ (Fin n))
  (γ α r : ℝ)
  (hgap : TropicalSpectralGap Q γ)
  (hbridge : ∀ v, quadraticForm Q v ≥ α * ‖v‖^2)
  (hr : 0 ≤ r) :
  ∀ h, ‖h‖ ≤ r →
    ⟪g, h⟫_ℝ + (1/2:ℝ) * quadraticForm Q h ≥ -‖g‖ * r + (1/2:ℝ) * α * r^2
```

This is a robust and provable inequality using Cauchy–Schwarz plus your bridge theorem.

### Option 2 — Statistical mechanics / energy landscape bridge

Interpret `Q` as a local energy Hessian and prove a metastability bound: tropical gap prevents low-energy escape directions within radius `r`. This is a beautiful bridge from machine learning to physics.

Possible statement:
```lean
theorem local_energy_barrier_of_tropical_gap
  {n : ℕ}
  (E : (EuclideanSpace ℝ (Fin n)) → ℝ)
  (x : EuclideanSpace ℝ (Fin n))
  (Q : Matrix (Fin n) (Fin n) ℝ)
  (γ α R ρ : ℝ)
  (hbridge : ∀ v, quadraticForm Q v ≥ α * ‖v‖^2)
  (hlocal :
    ∀ h, ‖h‖ ≤ ρ →
      E (x + h) ≥ E x + (1/2:ℝ) * quadraticForm Q h - R * ‖h‖^3) :
  ∀ r, 0 ≤ r → r ≤ ρ → R * r ≤ α / 4 →
    ∀ h, ‖h‖ = r → E (x + h) ≥ E x + (α/4) * r^2
```

This creates a bridge to **energy barriers, metastability, and nonconvex dynamics**.

---

## Concrete proof architecture

You must present and execute 2–3 serious proof strategies. At least one should involve induction/rcases/by_contra/field_simp/calc.

### Strategy A — Quadratic domination via bridge theorem (most promising)

1. **Define tropical spectral gap** in a way that is computable from matrix entries and strong enough to imply a coercive lower bound on the quadratic form.
2. **Invoke catalog bridge results**
   - use `tropical_to_stability_bridge`
   - combine with `quadFormBound_of_entry_bound`
   to derive
   \[
   Q(v,v) \ge \alpha(\gamma)\|v\|^2.
   \]
3. **Insert this into a local Taylor-type lower model** and optimize the resulting scalar inequality in `r`:
   \[
   -g r + \tfrac12 \alpha r^2 - R r^3 \ge 0.
   \]
4. Use `field_simp`, `nlinarith`, and multi-step `calc` blocks to isolate an explicit valid radius.

**Why this is most promising:** it modularly reuses catalog infrastructure and reduces the genuinely new mathematics to the right definition of tropical gap and the scalar optimization lemma.

### Strategy B — Piecewise-linear cell decomposition of ReLU regions

1. Restrict to a fixed activation region where the network is affine and the loss or margin function is quadratic after composition with a Lorentzian surrogate.
2. Prove a **cellwise theorem**: on each region, the certificate follows from the quadratic model exactly.
3. Glue local statements using finite region adjacency or a “radius stays in same activation chamber” lemma.

**Why valuable:** this respects the actual combinatorics of ReLU networks and may produce stronger regionwise certificates.  
**Why harder:** Lean formalization of activation chambers and Hessian surrogates may be substantially heavier.

### Strategy C — Contrapositive / by_contra adversarial escape argument

1. Assume there exists an adversarial perturbation with norm `< r`.
2. Use the local lower bound to show the margin or energy cannot cross zero if
   \[
   -g r + \tfrac12 \alpha r^2 - R r^3 > 0.
   \]
3. Derive contradiction.

This is ideal for a theorem phrased as “every perturbation of norm at most `r` preserves property `P`.” It naturally uses `by_contra` and avoids overcomplicated optimization.

---

## Required theorem inventory

Your Lean development must contain at least the following theorem classes:

1. **Bridge theorem**
   - tropical spectral gap ⇒ quadratic coercivity / stability.
2. **Radius theorem**
   - quadratic coercivity + local remainder control ⇒ certified robustness radius.
3. **Cross-domain theorem**
   - trust-region gain, energy barrier, or another serious bridge outside pure ML.

At least 3 theorems must use deep proof tactics:
- `rcases`
- `by_contra`
- `field_simp`
- induction where appropriate on finite dimensions / lists / region combinatorics
- multi-step `calc`

No trivial “proof by simplification” filler.

---

## Suggested Lean 4 formalization targets

These are targets, not rigid requirements; adjust to actual Mathlib APIs.

### Tropical gap definition
```lean
def TropicalSpectralGap {n : ℕ} (Q : Matrix (Fin n) (Fin n) ℝ) (γ : ℝ) : Prop :=
  ∀ i j : Fin n, i ≠ j → Q i i ≥ Q i j + γ
```

This simple diagonal-dominance-style tropical gap is not the only possibility, but it is likely formalizable and can support nontrivial theorems. If you choose a stronger cycle-mean definition, even better.

### Quadratic form
```lean
def quadraticForm {n : ℕ} (Q : Matrix (Fin n) (Fin n) ℝ)
    (v : EuclideanSpace ℝ (Fin n)) : ℝ :=
  ∑ i, ∑ j, (v i) * Q i j * (v j)
```

### Local certificate notion
```lean
def CertifiedRobustRadius
  {n : ℕ}
  (f : EuclideanSpace ℝ (Fin n) → ℝ)
  (x : EuclideanSpace ℝ (Fin n))
  (r : ℝ) : Prop :=
  0 ≤ r ∧ ∀ h, ‖h‖ ≤ r → f (x + h) ≥ f x
```

If the catalog already has a more relevant notion for classification margin robustness, use that instead.

### Scalar optimization lemma
```lean
theorem cubic_lower_nonneg_of_radius_bound
  {α g R r : ℝ}
  (hr : 0 ≤ r)
  (hα : 0 ≤ α)
  (hR : 0 ≤ R)
  (hineq : g ≤ (1/2:ℝ) * α * r - R * r^2) :
  -g * r + (1/2:ℝ) * α * r^2 - R * r^3 ≥ 0
```

This lemma is likely central and should be proved carefully, probably with `nlinarith`.

---

## Mathematical refinements to pursue

### 1. Replace Hessian by generalized curvature surrogate where necessary
Since ReLU networks are piecewise linear and classical Hessians vanish a.e. away from kinks, you should not blindly formalize a smooth Hessian theorem that misses the actual geometry. Instead, one of the following is acceptable and mathematically stronger:

- Hessian of a **smoothed loss**,
- Hessian of a **quadratic leaf surrogate**,
- generalized Hessian on a fixed activation region,
- curvature matrix arising from second variation of a margin surrogate.

This is an opportunity, not a compromise: it clarifies what “curvature” means in tropical deep learning.

### 2. Lorentzian hypothesis should do real work
Do not leave “Lorentzian quadratic leaf” as decorative language. Make it feed into a coercivity or barrier estimate, using `quadFormBound_of_entry_bound` or a derived corollary. The point is that Lorentzian structure should explain why tropical gap is geometrically meaningful.

### 3. Make the exponential law explicit if possible
If `tropical_to_stability_bridge` already yields an exponential dependence, surface it. If not, prove a weaker polynomial/exponential monotone lower bound and state the stronger exponential law as a conjecture with computational support.

---

## Falsifiable conjecture with computational test

You must include at least one explicit conjecture and a test that could fail.

### Conjecture C — Empirical sharpness of tropical certificates
For trained 2-layer ReLU classifiers with Lorentzian quadratic surrogate leaves, there exist universal constants `A, B > 0` such that for at least 80% of test points `x`,
\[
\operatorname{AdvRad}(x) \ge
A \frac{\exp(\operatorname{tropGap}(Q_x))}{\|\nabla \ell(x)\| + B},
\]
where `Q_x` is the local surrogate curvature matrix and `AdvRad(x)` is the empirical PGD adversarial radius.

**Testable prediction:** on MNIST and CIFAR-10 toy-width models, the Spearman correlation between
\[
\exp(\operatorname{tropGap}(Q_x))/(\|\nabla \ell(x)\|+B)
\]
and empirical adversarial radius exceeds the correlation of a pure Lipschitz certificate baseline.

This can fail. Good. That makes it science.

---

## Verified algorithm / computational method

You must provide a verified algorithm, not just a theorem.

### Required algorithm
Implement a procedure that, given a finite matrix `Q`, gradient norm `g`, remainder bound `R`, and localization radius `ρ`, returns a certified radius lower bound based on your theorem.

For example:

1. Compute tropical spectral gap `γ` from matrix entries.
2. Convert `γ` to a coercivity constant `α`.
3. Solve the scalar inequality
   \[
   g \le \tfrac12 \alpha r - R r^2, \quad r \le ρ
   \]
   for a valid `r`.
4. Return `r_cert`.

Possible Lean-facing specification:
```lean
def tropicalCertifiedRadius
  {n : ℕ} (Q : Matrix (Fin n) (Fin n) ℝ) (g R ρ : ℝ) : ℝ := ...
```

And prove a theorem of the form:
```lean
theorem tropicalCertifiedRadius_sound
  {n : ℕ}
  (Q : Matrix (Fin n) (Fin n) ℝ)
  (g R ρ : ℝ)
  :
  let r := tropicalCertifiedRadius Q g R ρ
  0 ≤ r ∧ r ≤ ρ ∧
  (* if local hypotheses hold, then *)
  (* CertifiedRobustRadius ... r *)
```

This algorithm is one of the central deliverables.

---

## demo.py requirements

Your `demo.py` must:

1. Generate or load small matrices / toy network surrogates.
2. Compute tropical gap and the certified radius.
3. Compare against:
   - a Lipschitz baseline,
   - optionally a classical minimum-eigenvalue baseline on small examples.
4. Visualize:
   - tropical gap vs empirical adversarial radius,
   - certificate comparisons,
   - failure cases.

This should not be decorative. It should operationalize the theorem and the conjecture.

---

## Application keywords

Use these explicitly in your paper and article:

- tropical geometry
- adversarial robustness
- certified defense
- curvature certificates
- max-plus algebra
- Lorentzian polynomials
- trust-region optimization
- energy landscapes
- metastability
- signal processing
- robust estimation
- spectral surrogates
- computational complexity of certification
- piecewise-linear deep learning

---

## Deliverables (ALL mandatory)

You must produce all of the following:

### 1. Lean development
A substantive Lean 4 file with:
- at least 3 deep theorems,
- at least 1 new definition,
- at least 1 cross-domain theorem,
- minimized sorry usage,
- explicit use of catalog results.

### 2. `FUTURE_DIRECTIONS.md`
Include **3–5 original research directions**, each with:
- **The key insight is...**
- **Why now?**
At least one direction must bridge to a different domain, such as:
- statistical physics,
- control theory,
- tropical information theory,
- combinatorial optimization.

### 3. `RESEARCH_PAPER.md`
A **standalone scientific paper** explaining:
- the new definitions,
- theorem statements,
- proof ideas,
- algorithmic implications,
- experiments/conjecture,
- why this matters scientifically.

A reader with no code access must understand the discovery.

### 4. `ARTICLE.md`
A **Scientific American–style** article:
- accessible,
- vivid,
- focused on the ideas,
- no emphasis on formal verification machinery,
- explain why tropical geometry might change how we think about neural network robustness.

### 5. Verified algorithm
A proved-sound computational method for producing tropical robustness certificates.

### 6. `demo.py`
An interactive demonstration of the result.

---

## Final standard

The ambition here is not “formalize a robustness lemma.” It is:

> Show that tropical curvature is a legitimate, computable, theorem-bearing substitute for classical second-order spectral data in robustness theory.

If you can prove even a rigorous local version of this vision — especially with an explicit radius formula and a trust-region or energy-barrier corollary — you will have created a new conceptual tool that links tropical geometry, optimization, and machine learning in a way that feels inevitable in hindsight and surprising today.

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
