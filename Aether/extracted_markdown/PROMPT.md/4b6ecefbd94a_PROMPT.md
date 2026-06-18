Soli Deo Gloria

## Assignment: Direction 2 — Interacting Fermions and Approximate Gaussianity

**Mode:** prove

You are not being asked for an incremental perturbation lemma. You are being asked to formalize the first mathematically serious bridge from **exactly Gaussian/free fermions** to **weakly interacting fermionic states** using a coefficient-based entropy technology inspired by Lorentzian/DPP methods. The breakthrough is to isolate a formal notion of **approximate Gaussianity on a finite region** and prove that entropy bounds are stable under controlled perturbations of the one-body correlation data.

The conceptual target is this: in free fermion states, the reduced entropy of a region \(A\) is governed by the spectrum of the restricted correlation operator \(K_A\), and hence by its elementary symmetric polynomials. For weakly interacting states, exact determinantal structure disappears — but if one can certify that the interacting state's regional correlation data stays close to a free reference state in a quantified way, then one should still obtain **nontrivial entropy upper bounds with explicit first-order dependence on the interaction scale**.

This is not just a technical extension. It opens a route toward a **perturbative entropy theory for interacting quantum matter**, linking:
- quantum many-body physics,
- matrix perturbation theory,
- entropy inequalities,
- Lorentzian/stable polynomial geometry,
- and computational certification.

---

## Core Mathematical Objective

Build on:

- `Pythagorean/EntanglementEntropy.lean`
- `Speculative/AutoResearch/DPPLorentzian.lean`

and introduce a new formal framework for **approximately Gaussian fermionic states on finite subsystems**.

You should define at least one genuinely new concept, for example:

- `ApproxGaussianRegion`
- `CorrelationPerturbationBound`
- `EntropyStabilityCertificate`

with a mathematically meaningful API.

A promising design is:

- a finite subsystem size `m : ℕ`,
- a free reference correlation matrix `K₀ : Matrix (Fin m) (Fin m) ℝ`,
- a perturbed matrix `K : Matrix (Fin m) (Fin m) ℝ`,
- assumptions that both are symmetric/Hermitian, spectrally confined to `[0,1]`,
- and a quantitative perturbation hypothesis such as
  `‖K - K₀‖ ≤ ε`.

Then prove entropy stability statements comparing the free entropy functional of `K₀` with that of `K`.

---

## Precise Theorem Targets

You must prove at least **3 substantial theorems** with nontrivial proofs. At least one should connect to a different domain.

### Theorem 1: Lipschitz stability of binary entropy away from the spectral edges

Let
\[
h(x) = -x \log x - (1-x)\log(1-x), \qquad x \in (0,1),
\]
with continuous extension at \(0,1\). On any compact interval \([\delta,1-\delta]\), the derivative is bounded by
\[
|h'(x)| \le \log\!\left(\frac{1-\delta}{\delta}\right).
\]
Hence
\[
|h(x)-h(y)| \le L_\delta |x-y|, \qquad L_\delta := \log\!\left(\frac{1-\delta}{\delta}\right).
\]

This is the scalar engine behind entropy stability.

A possible Lean-style target:

```lean
theorem binaryEntropy_lipschitz_on_compact
    {δ x y : ℝ}
    (hδ₀ : 0 < δ) (hδ₁ : δ < 1 / 2)
    (hx : x ∈ Set.Icc δ (1 - δ))
    (hy : y ∈ Set.Icc δ (1 - δ)) :
    |binaryEntropy x - binaryEntropy y| ≤
      Real.log ((1 - δ) / δ) * |x - y|
```

where `binaryEntropy : ℝ → ℝ` is your definition
```lean
def binaryEntropy (x : ℝ) : ℝ := -(x * Real.log x) - ((1 - x) * Real.log (1 - x))
```
possibly with a safer piecewise extension on `[0,1]`.

**Why this matters:** it turns matrix eigenvalue perturbation into entropy perturbation.

---

### Theorem 2: Entropy stability under eigenvalue perturbation

Suppose \(K\) and \(K_0\) are real symmetric matrices of size \(m\), all eigenvalues lying in \([\delta,1-\delta]\). If the ordered eigenvalues satisfy
\[
|\lambda_i(K)-\lambda_i(K_0)| \le \eta \quad \text{for all } i,
\]
then
\[
|S(K)-S(K_0)| \le m \, L_\delta \, \eta,
\]
where
\[
S(K) := \sum_{i=1}^m h(\lambda_i(K)).
\]

A Lean-style theorem target:

```lean
theorem entropy_difference_le_of_eigenvalue_sup_bound
    {m : ℕ} {δ η : ℝ}
    (hδ₀ : 0 < δ) (hδ₁ : δ < 1 / 2)
    {λ μ : Fin m → ℝ}
    (hλ : ∀ i, λ i ∈ Set.Icc δ (1 - δ))
    (hμ : ∀ i, μ i ∈ Set.Icc δ (1 - δ))
    (hclose : ∀ i, |λ i - μ i| ≤ η) :
    |(∑ i, binaryEntropy (λ i)) - (∑ i, binaryEntropy (μ i))| ≤
      (m : ℝ) * Real.log ((1 - δ) / δ) * η
```

This theorem can be proved purely analytically without requiring the full spectral theorem in Lean if you parameterize by eigenvalue lists/functions. That is acceptable and strategically wise.

**Why this matters:** it gives a regionwise entropy stability law with explicit subsystem-size dependence.

---

### Theorem 3: First-order weak-interaction entropy bound for approximately Gaussian states

This is the flagship theorem. Formalize a theorem of the following form:

> Let \(m \in \mathbb{N}\), \(0 < \delta < 1/2\), and let \(K_0, K\) be size-\(m\) correlation matrices whose spectra lie in \([\delta,1-\delta]\). Assume a perturbative closeness condition
> \[
> \max_i |\lambda_i(K)-\lambda_i(K_0)| \le C_0 \varepsilon.
> \]
> Then
> \[
> S(K) \le S(K_0) + m \log\!\left(\frac{1-\delta}{\delta}\right) C_0 \varepsilon.
> \]
> In particular, if \(S(K_0)\) is bounded by a coefficient/Lorentzian free-fermion bound, then the interacting entropy inherits that bound up to an \(O(\varepsilon m)\) correction.

Lean-style target:

```lean
theorem entropy_upper_bound_of_approxGaussian
    {m : ℕ} {δ ε C0 : ℝ}
    (hδ₀ : 0 < δ) (hδ₁ : δ < 1 / 2)
    {λ λ0 : Fin m → ℝ}
    (hλ : ∀ i, λ i ∈ Set.Icc δ (1 - δ))
    (hλ0 : ∀ i, λ0 i ∈ Set.Icc δ (1 - δ))
    (hpert : ∀ i, |λ i - λ0 i| ≤ C0 * ε) :
    (∑ i, binaryEntropy (λ i)) ≤
      (∑ i, binaryEntropy (λ0 i)) +
      (m : ℝ) * Real.log ((1 - δ) / δ) * (C0 * ε)
```

This is the theorem that converts “weakly interacting” into “approximately Gaussian entropy control”.

**Breakthrough significance:** this is the first certified theorem in the project that says the free-fermion coefficient technology is not confined to integrable models.

---

## Stronger Stretch Theorem: coefficient stability for elementary symmetric polynomials

If feasible, go one level deeper and prove a coefficient perturbation theorem. Let \(e_k(\lambda)\) denote the \(k\)-th elementary symmetric polynomial in the eigenvalues. Show that if each eigenvalue changes by at most \(\eta\), then
\[
|e_k(\lambda)-e_k(\mu)| \le \binom{m}{k} k \eta
\]
under a bounded-range hypothesis such as \(\lambda_i,\mu_i \in [0,1]\), or a sharper estimate if available.

Lean-style target:

```lean
theorem elementarySymm_stability_of_sup_norm_bound
    {m k : ℕ} {λ μ : Fin m → ℝ} {η : ℝ}
    (hη : 0 ≤ η)
    (hλ : ∀ i, λ i ∈ Set.Icc 0 1)
    (hμ : ∀ i, μ i ∈ Set.Icc 0 1)
    (hclose : ∀ i, |λ i - μ i| ≤ η) :
    |elemSymm m k λ - elemSymm m k μ| ≤
      ((Nat.choose m k : ℝ) * k * η)
```

You may need a custom `elemSymm` definition over `Fin m → ℝ`. This would connect directly back to the Lorentzian/coefficient machinery in the catalog.

**Why this matters:** it formalizes the slogan that the free coefficient method deforms continuously under weak interactions.

---

## New Definitions You Should Introduce

At least one of these, preferably more:

```lean
structure ApproxGaussianRegion (m : ℕ) where
  spectrum : Fin m → ℝ
  referenceSpectrum : Fin m → ℝ
  delta : ℝ
  epsilon : ℝ
  spectral_gap :
    ∀ i, spectrum i ∈ Set.Icc delta (1 - delta)
  reference_gap :
    ∀ i, referenceSpectrum i ∈ Set.Icc delta (1 - delta)
  perturbation :
    ∀ i, |spectrum i - referenceSpectrum i| ≤ epsilon
```

```lean
def regionEntropy {m : ℕ} (λ : Fin m → ℝ) : ℝ :=
  ∑ i, binaryEntropy (λ i)
```

```lean
def entropyStabilityConstant (δ : ℝ) : ℝ :=
  Real.log ((1 - δ) / δ)
```

If you can tie this to matrix data:

```lean
structure CorrelationPerturbationBound (m : ℕ) where
  K K0 : Matrix (Fin m) (Fin m) ℝ
  epsilon : ℝ
  -- plus symmetry / spectral assumptions / norm bound
```

Even if the full matrix-to-spectrum pipeline is too heavy, defining this interface is valuable for future work.

---

## Proof Strategy Architecture

You must include real mathematical proof architecture, not just theorem statements.

### Strategy A: Entropy as a Lipschitz spectral statistic
**Most promising for this cycle.**

1. Define `binaryEntropy` and prove derivative/monotonicity bounds on `Set.Icc δ (1 - δ)`.
2. Use the mean value theorem or interval derivative bounds to prove scalar Lipschitz continuity.
3. Lift from scalar bounds to finite sums over spectra.
4. Package the result into an `ApproxGaussianRegion` theorem.

**Why most promising:** it avoids deep operator theory while still delivering a nontrivial, publishable entropy stability theorem with explicit constants.

---

### Strategy B: Coefficient route via elementary symmetric polynomials
1. Define elementary symmetric polynomials on finite spectra.
2. Prove perturbation bounds for `elemSymm`.
3. Connect entropy bounds from `DPPLorentzian.lean` to perturbed coefficient data.
4. Derive an entropy correction theorem through the coefficient formalism rather than direct eigenvalue summation.

**Why this is exciting:** it directly extends the Lorentzian/DPP philosophy beyond exact determinantal structure. If successful, this is conceptually deeper than Strategy A.

---

### Strategy C: Matrix perturbation abstraction
1. Introduce an abstract theorem: if a spectral observable is Lipschitz in eigenvalues, then any certified eigenvalue perturbation bound implies a bound on the observable.
2. Keep the spectral perturbation hypothesis abstract rather than proving Weyl’s theorem in full.
3. Use this abstraction to instantiate entropy, trace polynomials, and possibly Rényi entropies.

**Why this matters:** it creates a reusable API for future interacting-state formalizations, including bosonic Gaussian approximations and open-system perturbations.

---

## Cross-Domain Connections You Must Explicitly Exploit

At least one theorem must bridge this domain to another mathematical area.

### Bridge 1: Quantum many-body physics ↔ real analysis
The entropy stability theorem is fundamentally a theorem about **Lipschitz continuity of a singular thermodynamic functional**. This is not merely physics language; it is analysis of \(x \log x\)-type singularities under spectral gap assumptions.

### Bridge 2: Quantum many-body physics ↔ algebraic combinatorics
The elementary symmetric polynomials \(e_k\) are coefficient data of characteristic polynomials. Their perturbation theory connects interacting fermions to **symmetric function bounds** and the Lorentzian polynomial worldview.

### Bridge 3: Quantum many-body physics ↔ matrix theory / numerical analysis
Your computational method should certify entropy error bars from approximate spectra. This turns formal theorem proving into a **reliable numerical certification pipeline** for weakly interacting systems.

Potential theorem phrasing for a cross-domain result:

```lean
theorem entropy_controlled_by_l1_eigenvalue_distance
    {m : ℕ} {δ : ℝ} {λ μ : Fin m → ℝ}
    (hδ₀ : 0 < δ) (hδ₁ : δ < 1 / 2)
    (hλ : ∀ i, λ i ∈ Set.Icc δ (1 - δ))
    (hμ : ∀ i, μ i ∈ Set.Icc δ (1 - δ)) :
    |regionEntropy λ - regionEntropy μ| ≤
      entropyStabilityConstant δ *
      ∑ i, |λ i - μ i|
```

This is a clean bridge between entropy and metric geometry on finite spectra.

---

## Computational/Algorithmic Deliverable

You must produce a **verified algorithm**, not just theorem statements.

### Required algorithm
Implement a computable entropy certificate:

- Input:
  - subsystem size `m`,
  - reference spectrum `λ0 : Fin m → ℝ`,
  - perturbation radius `η`,
  - gap parameter `δ`,
- Output:
  - certified interval
    \[
    [S(\lambda_0)-mL_\delta\eta,\; S(\lambda_0)+mL_\delta\eta]
    \]
  guaranteed to contain the entropy of any approximately Gaussian spectrum within sup-distance `η`.

Suggested Lean-facing spec:
```lean
def entropyCertificate
    (m : ℕ) (δ η : ℝ) (λ0 : Fin m → ℝ) : ℝ × ℝ := ...
```

and prove a soundness theorem:
```lean
theorem entropy_mem_certificate_of_sup_bound
    {m : ℕ} {δ η : ℝ} {λ λ0 : Fin m → ℝ}
    (hδ₀ : 0 < δ) (hδ₁ : δ < 1 / 2)
    (hλ : ∀ i, λ i ∈ Set.Icc δ (1 - δ))
    (hλ0 : ∀ i, λ0 i ∈ Set.Icc δ (1 - δ))
    (hclose : ∀ i, |λ i - λ0 i| ≤ η) :
    let I := entropyCertificate m δ η λ0
    regionEntropy λ ∈ Set.Icc I.1 I.2
```

### Required `demo.py`
Create an interactive demo that:
- generates toy free spectra,
- perturbs them by an interaction proxy,
- computes exact entropy and the certified interval,
- visualizes how the certificate width scales with `m`, `δ`, and `ε`.

The demo should test the prediction that the correction scales linearly in `ε` and approximately linearly in subsystem size.

---

## Conjecture With Testable Prediction

You must state at least one falsifiable conjecture and give a computational protocol that could refute it.

### Conjecture: logarithmically enhanced weak-interaction entropy correction
For physically local weakly interacting fermion systems in one dimension, there exists a universal constant \(C\) such that for subsystem size \(m \ge 2\),
\[
S_{\mathrm{int}}(m,\varepsilon)
\le
S_{\mathrm{free}}(m) + C \varepsilon\, m \log(m+1)
\]
for sufficiently small \(\varepsilon\).

This strengthens the formal theorem above by predicting the physically relevant \(m\log m\) correction rather than the baseline \(m\) bound.

**Computational test:** simulate finite Hubbard chains at \(U/t = 0.1, 0.5, 1.0\), extract reduced entropies for blocks of size \(m\), fit
\[
\frac{S_{\mathrm{int}} - S_{\mathrm{free}}}{\varepsilon m}
\]
against \(\log(m+1)\), and search for violations of a uniform upper envelope.

A second, more combinatorial conjecture if you pursue coefficient stability:

### Conjecture: Lorentzian robustness under approximate Gaussian perturbation
If a free fermion regional generating polynomial is Lorentzian and the interacting perturbation changes each coefficient by at most \(O(\varepsilon)\), then for sufficiently small \(\varepsilon\) the coefficient vector remains inside a controlled neighborhood of the Lorentzian cone that still implies entropy upper bounds.

This is falsifiable numerically by perturbing coefficient vectors and checking log-concavity/Lorentzian proxies.

---

## Catalog Integration Guidance

You should explicitly inspect the APIs in:

- `Pythagorean/EntanglementEntropy.lean`
- `Speculative/AutoResearch/DPPLorentzian.lean`

and reuse:
- entropy definitions or existing lemmas about \( -x \log x \),
- coefficient-based bounds,
- any symmetric polynomial infrastructure,
- any region/subsystem abstractions already present.

Do not merely cite them; identify exact lemmas and explain in comments how your new theorem deforms or abstracts them.

For example:
- if the catalog already bounds `S_free` by coefficient data, your theorem should say:
  “Given `hfree : regionEntropy λ0 ≤ B`, combine `entropy_upper_bound_of_approxGaussian` with `hfree` to obtain `regionEntropy λ ≤ B + correction`.”

This is the precise formal bridge from the free theorem to the interacting theorem.

---

## Minimal Theorem List You Must Deliver

At minimum, your Lean file should contain:

1. `binaryEntropy_lipschitz_on_compact`
2. `entropy_difference_le_of_eigenvalue_sup_bound`
3. `entropy_upper_bound_of_approxGaussian`

and preferably also one of:

4. `entropy_controlled_by_l1_eigenvalue_distance`
5. `elementarySymm_stability_of_sup_norm_bound`
6. a theorem transferring an existing free bound from the catalog to an approximate-Gaussian bound.

At least 3 of these must use genuine proof structure: induction, `rcases`, `by_contra`, `field_simp`, multi-step `calc`, interval estimates, or nontrivial inequalities.

---

## Revolutionary Significance

If you succeed, you will have created the first formal scaffold for **perturbative entanglement theory** in this project: a way to start from exact free-fermion structure and derive certified statements for weakly interacting matter. That changes the scientific program from “formalize solvable models” to “formalize the onset of complexity.”

This opens:
- entropy certification for approximate tensor-network outputs,
- rigorous error bars for DMRG/mean-field comparisons,
- extensions to Rényi entropies and mutual information,
- and eventually a formal theory of **stability of emergent Gaussian structure**.

This is how a field begins: identify the exact regime, then prove its deformation survives contact with reality.

---

## Mandatory Deliverables

You must produce **all** of the following:

### 1. `FUTURE_DIRECTIONS.md`
Include 3–5 original research directions. Each direction must contain:
- a sentence beginning with **“The key insight is...”**
- a sentence beginning with **“Why now?”**
- at least one direction that bridges to a different domain, such as:
  - interacting fermions ↔ information geometry,
  - Lorentzian polynomials ↔ renormalization,
  - entropy certification ↔ numerical linear algebra.

### 2. `RESEARCH_PAPER.md`
A standalone scientific paper explaining:
- the new notion of approximate Gaussianity,
- the main entropy stability theorem,
- how it extends the free-fermion catalog results,
- the computational prediction and conjectures,
- and what should be attacked next.

Someone reading only this document must understand the mathematics and significance without opening the Lean code.

### 3. `ARTICLE.md`
Write in Scientific American style.
Explain:
- why free fermions are solvable,
- why interactions usually destroy exact formulas,
- and why a stability theorem is scientifically powerful.

Do **not** focus on formal verification machinery. Focus on the ideas.

### 4. Verified algorithm / computational method
Implement and verify the entropy certificate described above.

### 5. `demo.py`
Interactive demonstration of the theorem and conjecture:
- free spectrum generation,
- perturbation by `ε`,
- entropy comparison,
- certificate visualization,
- scaling plots in `m` and `ε`.

---

## Application Keywords

approximate Gaussianity, interacting fermions, entanglement entropy, weak coupling, spectral perturbation, Weyl stability, elementary symmetric polynomials, Lorentzian polynomials, determinantal point processes, Hubbard chain, DMRG benchmarking, entropy certification, matrix analysis, many-body physics, information theory, numerical rigor

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
