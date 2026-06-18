Soli Deo Gloria

## Assignment: Direction 4: Stability of Partition Functions Under Noisy Couplings

**Mode:** `prove`

Prove genuinely new, non-trivial theorems at the interface of **Lorentzian polynomials, Ising partition functions, log-concavity, and noisy statistical physics**. Build directly on the catalog results

- `Catalog/Pythagorean/LorentzianSharpStability.lean`
  - especially `dimension_degree_stability_law_linear`
- `Catalog/Speculative/AutoResearch/LorentzianStability.lean`
  - especially `strong_concavity_on_orthogonal_complement`

and extract from them a mathematically sharp, physically meaningful **robustness theory for partition functions under coupling noise**.

This must not become a routine “perturbation lemma.” The goal is to formalize a theorem that says: **Lorentzian geometry controls the stability of observable thermodynamic structure under microscopic uncertainty in the couplings.** If successful, this opens a route from modern Hodge-theoretic combinatorics to rigorous noise tolerance in phase-transition diagnostics.

---

## Central Vision

For an Ising system on `n` spins with couplings `J : Fin n → Fin n → ℝ`, inverse temperature `β > 0`, and external field vector `h : Fin n → ℝ`, consider the partition function

\[
Z_J(h) \;=\; \sum_{\sigma \in \{\pm 1\}^n}
\exp\!\Big(\beta \sum_i h_i \sigma_i + \beta \sum_{i,j} J_{ij}\sigma_i\sigma_j\Big).
\]

The research target is to prove that if the **magnetization generating polynomial** associated to `J` is Lorentzian, then sufficiently small entrywise perturbations of the couplings preserve the **log-concavity of `log Z_J` in the external field variables**, with a sharp scale of order `1/(β n)`.

This is revolutionary because it would turn Lorentzian stability from a static algebraic property into a **quantitative robustness principle for noisy physical models**. That is the bridge: from combinatorial Hodge theory to experimentally relevant statistical mechanics.

---

## Precise Theorem Targets

You should introduce a mathematically clean finite-state formal model first, then derive the robustness statements. Work with a finite spin configuration type and a polynomial/exponential generating formalism that is feasible in Lean 4.

### New definitions you should introduce

At least one genuinely new concept is mandatory. The following package is recommended.

1. **Weighted Ising partition function**
   ```lean
   def isingEnergy {n : ℕ} (J : Fin n → Fin n → ℝ) (h : Fin n → ℝ)
       (σ : Fin n → ℝ) : ℝ := ...

   def isingPartition {n : ℕ} (β : ℝ) (J : Fin n → Fin n → ℝ)
       (h : Fin n → ℝ) : ℝ :=
       ∑ σ in spinConfigSet n, Real.exp (β * isingEnergy J h σ)
   ```

2. **Magnetization generating polynomial / field polynomial**
   A multivariate polynomial version is strongly encouraged:
   ```lean
   def isingFieldPoly {n : ℕ} (β : ℝ) (J : Fin n → Fin n → ℝ) :
       MvPolynomial (Fin n) ℝ := ...
   ```
   where the coefficient of a monomial records the weighted sum over spin configurations with a fixed sign pattern or occupation encoding.

3. **Coupling perturbation predicate**
   ```lean
   def couplingPerturbation {n : ℕ}
       (J J' : Fin n → Fin n → ℝ) (δ : ℝ) : Prop :=
     ∀ i j, |J' i j - J i j| ≤ δ
   ```

4. **Robust log-concavity in fields**
   ```lean
   def fieldLogConcaveOn {n : ℕ}
       (β : ℝ) (J : Fin n → Fin n → ℝ) (S : Set (Fin n → ℝ)) : Prop :=
       ∀ ⦃x y : Fin n → ℝ⦄, x ∈ S → y ∈ S → ∀ t ∈ Set.Icc (0:ℝ) 1,
         Real.log (isingPartition β J (t • x + (1 - t) • y)) ≥
           t * Real.log (isingPartition β J x) +
           (1 - t) * Real.log (isingPartition β J y)
   ```
   or, if differential infrastructure is more feasible, define a Hessian-based local notion:
   ```lean
   def negSemidefHessianLogPartition {n : ℕ}
       (β : ℝ) (J : Fin n → Fin n → ℝ) (x : Fin n → ℝ) : Prop := ...
   ```

5. **Lorentzian-compatible Ising instance**
   A new structure tying the physical model to the catalog’s Lorentzian theorems:
   ```lean
   structure LorentzianIsingModel (n : ℕ) where
     β : ℝ
     J : Fin n → Fin n → ℝ
     fieldPoly : MvPolynomial (Fin n) ℝ
     fieldPoly_def : fieldPoly = isingFieldPoly β J
     lorentzian : IsLorentzian fieldPoly
   ```

This structure is not merely packaging; it is the conceptual invention that lets Aristotle connect catalog Lorentzian theorems to a statistical-mechanical semantics.

---

## Main theorem statement

### Theorem A: quantitative preservation of field log-concavity under noisy couplings

Formal target, approximately:

```lean
theorem logConcavity_preserved_under_coupling_noise
    {n d : ℕ} (hn : 0 < n) {β ε : ℝ}
    (hβ : 0 < β) (hε : 0 ≤ ε)
    (M : LorentzianIsingModel n)
    (hsharp :
      ε ≤ dimension_degree_stability_constant n d / β)
    {J' : Fin n → Fin n → ℝ}
    (hpert : couplingPerturbation M.J J' (ε / (β * n)))
    (hpoly_close :
      polynomialCoefficientDistance
        (isingFieldPoly M.β M.J)
        (isingFieldPoly M.β J')
        ≤ ε)
    :
    fieldLogConcaveOn β J' Set.univ
```

This type signature can be adapted to the actual catalog API, but the theorem must explicitly express:

- quantified dependence on `n`, `β`, and perturbation scale,
- the `ε / (β * n)` coupling bound,
- a transfer from Lorentzian stability of the unperturbed model to log-concavity of the perturbed partition function.

If full global log-concavity is too ambitious in the first pass, prove a local Hessian theorem first:

### Theorem A' (acceptable stepping stone)
```lean
theorem hessian_logPartition_negSemidef_of_small_coupling_noise
    {n : ℕ} {β ε : ℝ}
    (hβ : 0 < β) (hε : 0 ≤ ε)
    (M : LorentzianIsingModel n)
    {J' : Fin n → Fin n → ℝ}
    (hpert : couplingPerturbation M.J J' (ε / (β * n)))
    (hstable : ... ) :
    ∀ h : Fin n → ℝ,
      negSemidefHessianLogPartition β J' h
```

The breakthrough is the **translation theorem** from coefficient stability of a Lorentzian polynomial to physical robustness of the partition function.

---

## Additional required theorems

You must prove at least **3 substantial theorems**, with proofs involving real mathematical structure: induction, `rcases`, `by_contra`, `field_simp`, nontrivial `calc`, and reduction arguments. Avoid proofs that collapse to automation.

### Theorem B: Lipschitz control of partition function under coupling perturbations
Show the partition function changes in a quantitatively controlled way under entrywise perturbation.

Suggested statement:
```lean
theorem isingPartition_logLipschitz_in_couplings
    {n : ℕ} {β δ : ℝ}
    (hβ : 0 ≤ β) (hδ : 0 ≤ δ)
    {J J' : Fin n → Fin n → ℝ}
    (hpert : couplingPerturbation J J' δ) :
    ∀ h : Fin n → ℝ,
      |Real.log (isingPartition β J' h) - Real.log (isingPartition β J h)|
        ≤ β * n^2 * δ
```

This theorem is important because it gives the analytic bridge between microscopic perturbation size and macroscopic free-energy stability. It also supplies the quantitative ingredient needed to compare noisy and noiseless systems.

### Theorem C: covariance/Hessian identity linking statistical physics to concavity
Prove a theorem expressing the Hessian of `log Z` in terms of spin covariances. This is the key cross-domain identity.

Suggested statement:
```lean
theorem hessian_logPartition_eq_covariance
    {n : ℕ} {β : ℝ} (hβ : 0 < β)
    (J : Fin n → Fin n → ℝ) :
    ∀ h : Fin n → ℝ, ∀ i j : Fin n,
      secondFieldDerivativeLogPartition β J h i j
        = β^2 * spinCovariance β J h i j
```

This is the conceptual heart of the program. It connects:

- **statistical physics**: susceptibility/covariance,
- **analysis**: Hessian of `log Z`,
- **Lorentzian geometry**: negative semidefiniteness / strong concavity.

Even if you implement this with a finite-difference or directional-derivative formalism rather than full Fréchet derivatives, the identity should be mathematically explicit and usable.

### Theorem D: transfer from Lorentzian strong concavity to covariance negativity on constrained directions
Using `strong_concavity_on_orthogonal_complement`, prove a physically meaningful corollary such as:

```lean
theorem covariance_form_nonpos_on_zero_sum_directions
    {n : ℕ} (M : LorentzianIsingModel n) :
    ∀ h : Fin n → ℝ, ∀ v : Fin n → ℝ,
      (∑ i, v i) = 0 →
      quadraticCovarianceForm M.β M.J h v ≤ 0
```

This is a beautiful bridge theorem: the Hodge-theoretic “orthogonal complement” condition becomes a **zero-total-magnetization fluctuation mode** in physics.

If signs or conventions force a nonnegative statement, that is acceptable, but the theorem must clearly identify the physical interpretation of the Lorentzian concavity direction constraint.

---

## Conjecture with testable prediction

You must include at least one falsifiable conjecture and a computational test.

### Conjecture E: sharpness of the `1 / (β n)` robustness scale
```lean
conjecture sharp_coupling_noise_scale
    {n : ℕ} :
    ∃ c > 0, ∀ β > 0, ∀ ε > 0,
      ∃ J J' : Fin n → Fin n → ℝ,
        couplingPerturbation J J' ((c * ε) / (β * n)) ∧
        IsLorentzian (isingFieldPoly β J) ∧
        ¬ fieldLogConcaveOn β J' Set.univ
```
Interpretation: the `1/(β n)` scale is not an artifact of proof but close to optimal.

### Computational test
For the complete graph Ising model `K_n`, compute the partition function / magnetization polynomial for
`n ∈ {4, 6, 8, 10, 12}` and perturb couplings at scale `c/(β n)`. Numerically test whether the Hessian of `log Z` in sampled field directions remains negative semidefinite. Search for a threshold constant. A counterexample would immediately refute the sharpness claim.

---

## Proof strategy architecture

You must present and pursue **2–3 serious proof pathways**, not a single hint.

### Strategy 1: coefficient-stability transfer via Lorentzian polynomial technology
1. Define `isingFieldPoly β J` so that evaluation at positive field variables recovers the partition function up to an explicit exponential or monomial change of variables.
2. Use the catalog theorem `dimension_degree_stability_law_linear` to show that sufficiently small coefficient perturbations preserve Lorentzianity or the required strong concavity estimates.
3. Prove a comparison lemma translating entrywise perturbations of `J` into coefficient perturbations of `isingFieldPoly β J'`.
4. Transfer Lorentzian strong concavity to log-concavity of `log Z` through the evaluation map.

**Why this is promising:** it directly leverages the catalog’s strongest new theorem and yields the sharp `1/n` scaling. This should be the primary route.

### Strategy 2: direct Hessian/covariance analysis in the Gibbs measure
1. Express first and second derivatives of `log Z` with respect to fields in terms of expectations and covariances under the Gibbs distribution.
2. Bound the effect of perturbing `J` on these covariances using comparison inequalities and finite-state exponential estimates.
3. Show that if the unperturbed covariance form satisfies the Lorentzian-induced sign condition, then small perturbations preserve it.

**Why this is promising:** it gives the cleanest physical interpretation and may produce stronger constants for special graph families such as complete graphs or ferromagnets.

### Strategy 3: one-parameter interpolation in coupling space
1. Define `J_t = J + t (J' - J)` for `t ∈ [0,1]`.
2. Differentiate `log Z_{J_t}(h)` with respect to `t`, obtaining an integral formula involving pair correlations.
3. Integrate the derivative bounds to obtain a quantitative stability estimate, then combine with the Lorentzian base case.

**Why this is promising:** interpolation often avoids messy coefficient bookkeeping and may produce a robust algorithmic certificate. It is especially attractive for the verified computational method.

**Recommended order:** start with Strategy 2 to derive the covariance/Hessian identities, then use Strategy 1 for the breakthrough theorem. Strategy 3 is ideal for the algorithmic and numerical certification layer.

---

## Cross-domain connections you must emphasize

This project is valuable only if the bridges are made explicit.

### 1. Statistical physics ↔ Lorentzian/Hodge theory
The partition function is not just a sum over states; through the generating polynomial, it becomes an object governed by Lorentzian inequalities. This reframes noise robustness in phase-transition models as a problem in algebraic concavity.

### 2. Probability ↔ strongly log-concave measures
If `log Z` remains concave in fields, then the induced Gibbs family retains concentration and stability properties. This connects to negative dependence, concentration inequalities, and sampling.

### 3. Quantum information / tensor network viewpoint
Noisy couplings in Ising-type Hamiltonians are a classical shadow of perturbations in commuting Hamiltonians and variational tensor network energies. A robust log-concavity theorem suggests stable inference of susceptibilities and response functions under calibration error.

### 4. Optimization / machine learning
Log-concavity of partition-like objectives under parameter noise is a structural guarantee relevant to variational inference, energy-based models, and robust training of Boltzmann machines.

### 5. Experimental physics
The theorem would justify when measured susceptibility profiles or magnetization curves are **intrinsically robust** to uncertainty in pairwise interaction estimates.

---

## Application keywords

Include these explicitly in the paper and article:

**Lorentzian polynomial, Ising model, partition function, log-concavity, Gibbs measure, covariance identity, susceptibility, phase transition, noisy couplings, robustness certificate, magnetization polynomial, Hodge theory, negative dependence, concentration of measure, variational inference, tensor networks, experimental noise, free energy stability**

---

## Lean 4 formalization guidance

You are working in Lean 4 with Mathlib. Keep the formalization finite and exact.

### Suggested implementation choices
- Model spins as functions `σ : Fin n → Bool` or `σ : Fin n → ℝ` constrained to values `±1`.
- Use a finite set of spin configurations:
  ```lean
  def spinConfigSet (n : ℕ) : Finset (Fin n → Bool) := ...
  ```
  then define a sign map `spinVal : Bool → ℝ`.
- If full multivariate differential calculus becomes too heavy, define:
  - directional second derivatives,
  - explicit finite sums for expectations/covariances,
  - Hessian entries via closed forms from the finite partition function.
- For polynomial connections, use `MvPolynomial (Fin n) ℝ` and prove an evaluation identity.

### Critical supporting lemmas to build
1. Positivity of partition function:
   ```lean
   theorem isingPartition_pos ... : 0 < isingPartition β J h
   ```
2. Finite-sum expectation identities.
3. A lemma comparing energies under coupling perturbation:
   ```lean
   theorem isingEnergy_diff_bound ... :
     |isingEnergy J' h σ - isingEnergy J h σ| ≤ n^2 * δ
   ```
4. Exponential comparison:
   ```lean
   theorem exp_energy_comparison ... : ...
   ```
5. Partition-function comparison and log comparison.
6. Evaluation identity between `isingFieldPoly` and `isingPartition`.

These are not filler; they are the scaffolding of the main theorem.

---

## Minimum theorem inventory

Your final Lean development must contain at least:

- **1 new definition/structure** of real conceptual value,
- **3 nontrivial proved theorems**,
- **1 cross-domain theorem** explicitly linking Lorentzian concavity to a statistical-physics quantity such as covariance/susceptibility,
- **1 conjecture** with a testable computational prediction,
- **1 verified algorithm or computational method**.

Do not rely on trivial automation. At least three proofs should visibly use techniques such as:
- induction over spins or finite sets,
- `rcases` decomposition of configurations,
- `by_contra` for sign/concavity arguments,
- `field_simp` in derivative/covariance manipulations,
- multi-step `calc` chains.

---

## Verified algorithm / computational method

You must produce a verified algorithm, not just theorem statements.

### Algorithm target: robustness certificate for noisy Ising couplings
Implement a procedure that, given:
- `n`,
- `β`,
- base coupling matrix `J`,
- perturbation radius `δ`,

returns either:
1. a certificate that the perturbation scale is within the theorem’s safe regime and hence field log-concavity is preserved, or
2. failure to certify.

Suggested interface:
```lean
def certifyLogConcavityUnderNoise
    (n : ℕ) (β : ℝ) (J : Fin n → Fin n → ℝ) (δ : ℝ) :
    Bool := ...
```

Then prove a soundness theorem:
```lean
theorem certifyLogConcavityUnderNoise_sound
    ... :
    certifyLogConcavityUnderNoise n β J δ = true →
    ∀ J', couplingPerturbation J J' δ →
      fieldLogConcaveOn β J' Set.univ
```

This is scientifically crucial: it turns the theorem into an actionable diagnostic.

---

## demo.py requirement

Produce `demo.py` that:
1. constructs complete-graph Ising models for `n = 4, 6, 8, 10, 12`,
2. perturbs couplings at scales `c/(β n)` for several `c`,
3. computes the partition function and samples Hessian/covariance diagnostics,
4. visualizes the empirical threshold where log-concavity appears preserved or lost,
5. highlights agreement or tension with the formal theorem and conjectured sharpness.

The demo should be interactive enough to vary `β`, `n`, and perturbation size.

---

## Mandatory deliverables

You must produce **all** of the following:

### 1. `FUTURE_DIRECTIONS.md`
Include **3–5 original research directions**. Each direction must contain:
- a title,
- a paragraph with the exact phrase **“The key insight is...”**
- a paragraph with the exact phrase **“Why now?”**
- at least one direction that bridges to a different domain, e.g. quantum information, optimization, or experimental condensed matter.

Possible follow-ons:
- robustness of Lee–Yang zero locations under noisy couplings,
- Lorentzian control of Glauber dynamics mixing,
- tropical or entropy analogues of partition-function stability,
- extension to Potts models or determinantal spin systems.

### 2. `RESEARCH_PAPER.md`
A standalone scientific document. Someone reading only this paper must understand:
- the mathematical problem,
- the new definitions,
- the main theorems,
- why the results are surprising,
- how the proof works at a high level,
- what the computational experiments test,
- what the next open problems are.

Do not write this as notes to yourself; write it as a real paper.

### 3. `ARTICLE.md`
Write this in **Scientific American style**:
- engaging,
- broad-audience,
- idea-centered,
- significance-focused.

**Taboo:** do **not** focus on formal verification or machine verification. The story is about robust physical laws emerging from deep geometry.

### 4. Verified algorithm / computational method
As specified above.

### 5. `demo.py`
As specified above.

---

## Final charge

Do not settle for a cosmetic formalization of a known identity. The aim is to show that **Lorentzian stability is a physical robustness principle**: tiny uncertainty in microscopic couplings does not destroy the macroscopic concavity structure that underlies susceptibility, concentration, and phase-transition diagnostics.

If you can prove even the local Hessian version with a sharp or near-sharp `1/(β n)` scale, and support it with a verified certificate plus computational evidence on complete graphs, that is already a field-opening result. If you can prove the full global log-concavity preservation theorem, it becomes a blueprint for a new mathematics of **noise-stable thermodynamics**.

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
