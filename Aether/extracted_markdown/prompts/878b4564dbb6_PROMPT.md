Soli Deo Gloria

## Assignment: Direction 4 — Certified Floating-Point Lorentzian Recognition

**Mode:** prove

Build a genuinely new bridge between Lorentzian polynomial theory, verified numerical analysis, and spectral certification. Do not settle for a software wrapper around existing results: the target is a mathematically sharp **robust recognition theory** for Lorentzianity under floating-point uncertainty, with explicit certified margins and a provable small ambiguity region.

The central scientific objective is to turn abstract Lorentzian stability criteria into a **quantitative decision theory**: given uncertain coefficients, decide whether Lorentzianity is forced, impossible, or genuinely numerically unresolved — and prove that the unresolved set is asymptotically thin.

This is not merely an implementation problem. If successful, it opens a new field of **certified discrete convexity under uncertainty**, with consequences for optimization, sampling, negative dependence, combinatorial Hodge theory, and robust symbolic-numeric algebra.

---

## Core Breakthrough Goal

Develop a formal theory of **ε-certified Lorentzian recognition** for low-dimensional polynomial families, beginning with bivariate homogeneous polynomials and extending as far as the available catalog theorems permit.

You should build explicitly on:

- `Catalog/Speculative/AutoResearch/LorentzianStability.lean`  
  especially `certifyStability_sound`
- `Pythagorean/UniformMatroidLorentzian.lean`  
  especially `quadFormBound_of_entry_bound`

The key conceptual move is to combine:

1. a **stability margin / perturbation radius** from Lorentzianity theory,
2. a **verified spectral test** for Hessian-type quadratic forms,
3. a **geometric measure estimate** showing that the ambiguous region is controlled by the vanishing of a margin function.

---

## Precise Theorem Targets

You must formalize at least one new structure and prove at least 3 substantial theorems. The following are the target statements; refine hypotheses only if necessary for Lean tractability, but preserve the scientific content.

### New definitions to introduce

Define a new notion such as:

- `LorentzianCertificate`
- `RobustLorentzianRegion`
- `SpectralMargin`
- `FPBox` for coefficient interval uncertainty
- `CertifiedDecision` with values `yes | no | unknown`

Suggested Lean-style declarations:

```lean
structure FPBox (ι : Type _) where
  center : ι → ℝ
  radius : ι → ℝ

inductive CertifiedDecision
  | yes
  | no
  | unknown

def SpectralMargin (Q : Matrix (Fin n) (Fin n) ℝ) : ℝ := ...

def RobustLorentzianOnBox
  (B : FPBox ι) (encode : (ι → ℝ) → MvPolynomial σ ℝ) : Prop :=
  ∀ a, (∀ i, |a i - B.center i| ≤ B.radius i) →
    IsLorentzian (encode a)

def RobustNonLorentzianOnBox
  (B : FPBox ι) (encode : (ι → ℝ) → MvPolynomial σ ℝ) : Prop :=
  ∀ a, (∀ i, |a i - B.center i| ≤ B.radius i) →
    ¬ IsLorentzian (encode a)
```

If `IsLorentzian` is not already present in the exact needed form, define an intermediate formal notion for the bivariate homogeneous case in terms of derivative/Hessian sign structure or a catalog-certified equivalent.

---

## Theorem 1: Soundness of certified robust recognition

### Mathematical statement
For a suitable encoded family of homogeneous bivariate polynomials of fixed degree, if the computed lower bound on the Lorentzian spectral margin exceeds the perturbation error propagated from the coefficient box, then every polynomial in that box is Lorentzian. Dually, if a certified obstruction margin exceeds the perturbation bound, then every polynomial in the box is non-Lorentzian.

This is the theorem that turns floating-point uncertainty into a mathematically valid certificate.

### Suggested Lean 4 type signature
A schematic target:

```lean
theorem certify_lorentzian_of_margin_gt_error
  {ι : Type _} {d : ℕ}
  (B : FPBox ι)
  (encode : (ι → ℝ) → MvPolynomial (Fin 2) ℝ)
  (margin err : ℝ)
  (hmargin : err < margin)
  (hcert : ∀ a,
    (∀ i, |a i - B.center i| ≤ B.radius i) →
    margin ≤ lorentzianMargin (encode a))
  : RobustLorentzianOnBox B encode
```

and a dual theorem

```lean
theorem certify_nonlorentzian_of_obstruction_gt_error
  {ι : Type _} {d : ℕ}
  (B : FPBox ι)
  (encode : (ι → ℝ) → MvPolynomial (Fin 2) ℝ)
  (obs err : ℝ)
  (hobs : err < obs)
  (hcert : ∀ a,
    (∀ i, |a i - B.center i| ≤ B.radius i) →
    obs ≤ nonLorentzianObstacle (encode a))
  : RobustNonLorentzianOnBox B encode
```

### Why this is a breakthrough
This theorem converts an existential perturbation principle into an **algorithmically consumable robust certificate**. It is the exact bridge needed for practical recognition in numerical environments.

---

## Theorem 2: Quantitative perturbation bound via quadratic-form control

### Mathematical statement
Show that the Lorentzian spectral test varies Lipschitz-continuously with respect to coefficient perturbation, with constant controlled by explicit combinatorial/degree data. Use `quadFormBound_of_entry_bound` to pass from coefficient error bounds to Hessian/quadratic-form error bounds.

This theorem should be nontrivial and use actual matrix norm / quadratic form reasoning, not superficial rewriting.

### Suggested Lean 4 type signature
A schematic form:

```lean
theorem spectralMargin_perturbation_bound
  {n : ℕ}
  {Q E : Matrix (Fin n) (Fin n) ℝ}
  (hE : ∀ i j, |E i j| ≤ δ)
  : |SpectralMargin (Q + E) - SpectralMargin Q| ≤ C n * δ
```

Or, in the polynomial family form:

```lean
theorem lorentzianMargin_coeff_perturbation_le
  {ι : Type _}
  (encode : (ι → ℝ) → MvPolynomial (Fin 2) ℝ)
  (a b : ι → ℝ)
  (hclose : ∀ i, |a i - b i| ≤ ε)
  : |lorentzianMargin (encode a) - lorentzianMargin (encode b)| ≤ K * ε
```

You may need to define `C n` or `K` explicitly from degree and support size. A weaker but explicit bound is better than a vague theorem.

### Why this is a breakthrough
Without a quantitative perturbation theorem, “certified recognition” is empty rhetoric. This result gives the **modulus of robustness** needed to propagate floating-point uncertainty through the Lorentzian test.

---

## Theorem 3: Small-volume ambiguity region in coefficient space

### Mathematical statement
For a finite-dimensional coefficient family \(V \cong \mathbb{R}^m\), define the ambiguous set
\[
A_\epsilon = \{a \in V : \text{the certified margin at } a \le C\epsilon\}.
\]
Prove, under a nondegeneracy hypothesis on the margin function, that the measure of \(A_\epsilon\) in a compact coefficient box is \(O(\epsilon)\). At minimum, prove a concrete upper bound of the form
\[
\mathrm{vol}(A_\epsilon \cap K) \le C_K \epsilon
\]
for bivariate degree-\(\le d\) families when the discriminant/margin hypersurface is regular.

### Suggested Lean 4 type signature
A realistic formal target may be a finite-dimensional surrogate using intervals or boxes:

```lean
theorem volume_ambiguous_le_const_mul_eps
  (K : Set (Fin m → ℝ))
  (hK : IsBox K)
  (margin : (Fin m → ℝ) → ℝ)
  (hreg : RegularNearZeroSet margin K)
  :
  ∃ C > 0, ∀ ε ∈ Set.Icc (0 : ℝ) 1,
    boxVolume {a ∈ K | |margin a| ≤ ε} ≤ C * ε
```

If full measure theory is too heavy, prove a box-counting / grid-count theorem instead:

```lean
theorem grid_ambiguous_count_le_const_mul_eps
  ...
```

A discretized theorem is acceptable if it is mathematically meaningful and directly supports `demo.py`.

### Why this is a breakthrough
This is the theorem that justifies the **practical reliability** of the recognition algorithm: indecision is not merely possible, but provably rare. That transforms a symbolic criterion into a robust numerical technology.

---

## Theorem 4: Cross-domain bridge to control / hyperbolic stability

You must include at least one theorem connecting Lorentzian recognition to a different domain.

### Recommended bridge
Interpret the Hessian or associated quadratic form as a verified stability witness analogous to a Lyapunov or inertia certificate in control theory.

### Suggested statement
For a homogeneous bivariate polynomial family whose Lorentzian test reduces to signature conditions on an associated symmetric matrix, prove that certified inertia separation implies robust sign behavior of a corresponding linearized dynamical energy functional.

### Suggested Lean 4 type signature
```lean
theorem lorentzian_signature_implies_control_style_stability
  {Q : Matrix (Fin n) (Fin n) ℝ}
  (hsig : HasLorentzianSignature Q)
  : ∃ c > 0, ∀ x,
      energyDecayFunctional Q x ≤ -c * positiveNormFunctional x
```

If this exact form is too ambitious, prove instead a theorem showing that Lorentzian signature is preserved under bounded perturbations in the same style as robust control stability margins.

### Why this matters
This creates a conceptual bridge from **combinatorial Hodge theory** to **robust systems theory**. That is exactly the sort of cross-domain synthesis that can spawn new mathematics rather than a niche formalization.

---

## Algorithmic Deliverable

Implement a verified computational method, not just theorem statements.

### Required algorithm
For homogeneous bivariate polynomials of degree `d ≤ 10` with floating-point coefficient intervals:

1. construct the relevant derivative/Hessian/spectral object,
2. compute interval bounds for its entries,
3. derive a certified lower bound for the Lorentzian margin,
4. return:
   - `yes` if Lorentzianity is forced,
   - `no` if non-Lorentzianity is forced,
   - `unknown` otherwise.

The algorithm must be accompanied by a **soundness theorem** in Lean tying the return value to mathematical truth.

### Suggested API
```lean
def certifyLorentzianBivariate :
  FPBox (Fin m) → CertifiedDecision
```

with theorem:

```lean
theorem certifyLorentzianBivariate_sound_yes
  (B : FPBox (Fin m))
  (h : certifyLorentzianBivariate B = CertifiedDecision.yes)
  : RobustLorentzianOnBox B encode
```

and similarly for `no`.

---

## Proof Strategy Architecture

You must not give a one-path proof narrative. Pursue at least 2–3 strategies and identify the most promising one.

### Strategy A: Margin propagation from catalog stability theorems
1. Extract a stability-radius statement from `certifyStability_sound`.
2. Define a numerical margin functional that lower-bounds distance to the Lorentzian boundary.
3. Use coefficient-box perturbation estimates to show that if the certified margin exceeds the propagated error, Lorentzianity is uniform on the box.

**Why promising:** This directly leverages the catalog’s strongest vetted theorem and yields the cleanest soundness theorem.

### Strategy B: Quadratic-form / Hessian perturbation route
1. Associate to the polynomial a symmetric matrix or quadratic form governing the Lorentzian criterion in the bivariate case.
2. Use `quadFormBound_of_entry_bound` to control perturbation of the quadratic form from interval coefficient errors.
3. Translate a signature gap into a robust yes/no decision.

**Why promising:** This is likely the best route for explicit constants, concrete algorithms, and practical `demo.py` implementation.

### Strategy C: Semialgebraic boundary and ambiguity-volume analysis
1. Express the Lorentzian/non-Lorentzian boundary as a semialgebraic discriminant-type set.
2. Define the ambiguous region by smallness of a margin polynomial/function.
3. Prove a tube-volume or grid-count estimate near a regular hypersurface.

**Why promising:** This is the route to the headline \(O(\epsilon)\) failure-region theorem. It is conceptually deepest, though perhaps the most technically demanding in Lean.

### Recommended order
- First complete **Strategy B** for a robust bivariate algorithm.
- Then use **Strategy A** to connect to catalog-certified Lorentzian stability.
- Finally formalize a discretized or continuous version of **Strategy C** for the ambiguity-volume estimate.

---

## Cross-Domain Connections to Exploit

Do not merely mention these; use at least one in a theorem or discussion.

1. **Numerical analysis**  
   Interval arithmetic, condition numbers, backward error analysis, Gershgorin-type eigenvalue certification.

2. **Control theory**  
   Robust stability margins, inertia preservation, Lyapunov-style quadratic certificates.

3. **Theoretical computer science**  
   Polynomial-time certification, promise problems, smoothed analysis of near-boundary instances.

4. **Optimization / sampling**  
   Lorentzian polynomials control log-concavity and negative dependence; certified recognition could enable robust optimization primitives and reliable samplers.

5. **Physics / statistical mechanics**  
   Lorentzian and stable polynomials are tied to partition functions and correlation inequalities; robust recognition suggests a numerical phase-detection paradigm.

---

## Application Keywords

Include these explicitly in your paper and article metadata/discussion:

**application keywords:** robust certification, interval arithmetic, Lorentzian polynomials, hyperbolic stability, combinatorial Hodge theory, negative dependence, log-concavity, spectral gap, verified linear algebra, Gershgorin bounds, smoothed analysis, optimization, sampling, control theory, statistical mechanics

---

## Conjecture with Testable Prediction

You must state at least one falsifiable conjecture and implement a computational test.

### Primary conjecture
For bivariate homogeneous polynomials of degree \(d \le 10\) with coefficients sampled from a bounded box distribution, the proportion of coefficient boxes of radius \(\epsilon\) classified as `unknown` by the certified interval algorithm is bounded by \(C_d \epsilon\) for sufficiently small \(\epsilon\).

Suggested Lean-side declaration of the mathematical conjecture:

```lean
conjecture unknown_rate_O_eps
  (d : ℕ) :
  ∃ C > 0, ∀ ε ∈ Set.Icc (0 : ℝ) 1,
    unknownFrequency d ε ≤ C * ε
```

### Computational test
In `demo.py`:
- sample random bivariate degree-`≤ 10` coefficient vectors,
- inflate to interval boxes of radius `ε`,
- run the certified recognizer,
- estimate empirical `unknown` frequency for a grid of `ε`,
- fit a slope/log-log trend,
- search for violations of linear-in-`ε` behavior.

A single convincing disproof would be scientifically valuable.

---

## Lean Expectations

Your Lean file must contain:

1. **At least 3 nontrivial theorem proofs** using deep tactics or substantial multi-step reasoning.
2. **At least 1 novel definition** not already in the catalog.
3. **At least 1 cross-domain theorem**.
4. **At least 1 theorem tied directly to the algorithm’s soundness**.
5. Minimal sorry usage; if any sorry remains, isolate it to the most technically peripheral lemma.

Avoid trivial theorem choices. If a statement collapses to `native_decide`, it is not a research theorem.

---

## Recommended file focus

A plausible organization:

- `CertifiedLorentzianRecognition/Definitions.lean`
- `CertifiedLorentzianRecognition/Perturbation.lean`
- `CertifiedLorentzianRecognition/Algorithm.lean`
- `CertifiedLorentzianRecognition/AmbiguityVolume.lean`

If you keep a single file, ensure the architecture still reflects these layers.

---

## Scientific significance

If you succeed, you will have created the first formal blueprint for **numerically reliable Lorentzian geometry**. That matters because modern mathematics increasingly lives at the boundary of symbolic and numeric reasoning. Stable polynomials, Lorentzian structures, and combinatorial Hodge theory have immense structural power, but they remain difficult to recognize in practice. A certified floating-point recognition theorem would make them computationally accessible without sacrificing rigor.

That would open:
- certified optimization routines exploiting Lorentzianity,
- robust sampling and negative dependence diagnostics,
- numerical discovery pipelines for new Lorentzian families,
- control-theoretic analogues of Hodge-theoretic stability,
- smoothed-analysis theories of algebraic decision problems.

This is not a routine extension. It is the beginning of a new subject: **certified spectral algebraic recognition under uncertainty**.

---

## Mandatory Deliverables

You must produce **all** of the following:

### 1. `FUTURE_DIRECTIONS.md`
Give 3–5 original research directions. Each direction must include:
- a sentence beginning **“The key insight is...”**
- a sentence beginning **“Why now?”**
- at least one direction must bridge to a different domain.

Possible examples to consider:
- higher-dimensional Lorentzian certification,
- certified hyperbolicity recognition,
- smoothed complexity of semialgebraic spectral tests,
- phase-boundary detection in statistical mechanics via Lorentzian margins,
- zero-knowledge certificates for spectral nonnegativity / Lorentzian witnesses.

### 2. `RESEARCH_PAPER.md`
A standalone scientific document explaining:
- the mathematical problem,
- the new definitions,
- the main theorems,
- proof ideas,
- the algorithm,
- computational evidence,
- why this changes the landscape,
- what comes next.

A reader with no access to code must still understand the discovery.

### 3. `ARTICLE.md`
Write in **Scientific American** style:
- vivid and accessible,
- centered on the mathematical ideas and why they matter,
- no focus on formal verification machinery,
- explain Lorentzian polynomials as part of a larger story about hidden geometric order in algebra and computation.

### 4. Verified algorithm / computational method
Not optional. Deliver a working certified recognition procedure with theorem-level soundness guarantees.

### 5. `demo.py`
Provide an interactive demonstration that:
- constructs random bivariate polynomials,
- perturbs coefficients by interval uncertainty,
- runs the recognizer,
- displays `yes/no/unknown`,
- measures empirical unknown rate vs `ε`,
- visualizes the apparent ambiguity region.

---

## Final call

Do not merely formalize that “an algorithm exists.” Build the mathematics that explains **why certification is possible**, **when it fails**, and **how rarely it should fail**. The real prize is not a checker, but a new robust interface between Lorentzian geometry and numerical computation.

The key insight is that Lorentzianity should not be treated as a brittle symbolic property, but as a **spectrally margin-certified geometric phase**. Once that viewpoint is formalized, floating-point uncertainty becomes not an obstacle but a quantitative lens.

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
