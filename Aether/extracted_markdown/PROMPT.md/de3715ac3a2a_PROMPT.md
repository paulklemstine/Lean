Soli Deo Gloria

## Assignment: Direction 1: Proving the SSH Newton-Order Conjecture via Toeplitz Asymptotics

**Mode:** prove

Prove a genuinely new theorem package that turns the SSH Newton-order conjecture into a rigorous bridge between algebraic inequalities, Toeplitz asymptotics, and quantum criticality. This is not an incremental extension: the goal is to show that a purely algebraic statistic built from elementary symmetric polynomials of correlation-spectrum eigenvalues detects a topological/critical transition in a free-fermion model.

The breakthrough is conceptual as much as technical:

> **A quantum phase transition should be detectable from the Newton profile of the entanglement spectrum.**

If established, this would create a new phase-detection paradigm: no order parameter in the traditional field-theoretic sense, no transport observable, no many-body tomography — only the algebra of symmetric polynomials in subsystem correlation eigenvalues.

---

## Core Mathematical Target

Let `λ₁(m,δ), …, λ_m(m,δ)` be the eigenvalues of the SSH half-chain correlation matrix for a block of size `m` at half filling and dimerization `δ`. Let
\[
e_k(\lambda)=\sum_{1\le i_1<\cdots<i_k\le m}\lambda_{i_1}\cdots \lambda_{i_k}
\]
be the elementary symmetric polynomial, and define the **Newton ratio profile**
\[
R_k(\lambda):=\frac{e_k(\lambda)^2}{e_{k-1}(\lambda)e_{k+1}(\lambda)}
\quad (1\le k\le m-1),
\]
and the **Newton order parameter**
\[
\mathcal N(\lambda):=\sup_{1\le k\le m-1}\bigl(-\log R_k(\lambda)\bigr).
\]
For the SSH spectrum, write
\[
\mathcal N_m(\delta):=\mathcal N(\lambda_1(m,\delta),\dots,\lambda_m(m,\delta)).
\]

### Precise Theorem Program

You should formalize and prove, at minimum, a theorem schema of the following form:

#### Theorem A: Gapped SSH implies bounded Newton order
For every dimerization `δ` with `δ ≠ 0`, there exist constants `ε(δ) > 0` and `C(δ) < ∞` such that for all subsystem sizes `m`,
\[
\lambda_i(m,\delta)\in[\varepsilon(\delta),1-\varepsilon(\delta)] \quad \forall i
\]
implies
\[
\mathcal N_m(\delta)\le C(\delta).
\]
This should be deduced by reducing the SSH statement to a spectral pinching hypothesis and invoking/extending the catalog theorem `newtonRatio_bounded_of_spectral_pinching`.

#### Theorem B: Abstract logarithmic blowup criterion from Toeplitz asymptotics
Let `λ^(m)` be a sequence of spectra arising from finite Toeplitz compressions with Fisher–Hartwig singular symbol at criticality. Assume there exists a window `k = k(m)` and constants `a > 0`, `b`, `c > 0` such that
\[
\log e_{k+1}^{(m)} - 2\log e_k^{(m)} + \log e_{k-1}^{(m)} \le - c \frac{\log m}{m^\alpha}
\]
or any asymptotic inequality strong enough to imply
\[
-\log R_{k(m)}(\lambda^{(m)}) \ge c' \log m - b
\]
for infinitely many `m`. Then
\[
\mathcal N(\lambda^{(m)}) \ge c' \log m - b
\]
for infinitely many `m`.

This theorem should be formalized abstractly, so that the Toeplitz/Fisher–Hartwig input is encapsulated as a hypothesis about second log-differences of `e_k`.

#### Theorem C: Critical SSH Toeplitz criterion implies Newton-order divergence
At `δ = 0`, if the SSH block correlation matrix is identified with a Toeplitz compression whose symbol has the critical Fisher–Hartwig singularity, and if the corresponding asymptotic for the elementary symmetric profile yields an unbounded negative second log-difference along some subsequence, then
\[
\forall B>0,\ \exists^\infty m,\ \mathcal N_m(0)\ge B,
\]
in particular,
\[
\exists c>0,\ \exists^\infty m,\ \mathcal N_m(0)\ge c\log m.
\]

This is the conjectural flagship. If the full Fisher–Hartwig asymptotic is too deep to complete fully in Lean in one cycle, prove the implication theorem rigorously and isolate the exact asymptotic lemma needed from analysis/physics literature.

---

## Lean 4 Formalization Targets

You must include precise theorem statements with Lean-oriented signatures, even if some analytic hypotheses are abstracted. Suggested signatures:

```lean
def NewtonRatio (s : Finset α) (w : α → ℝ) (k : ℕ) : ℝ := ...
def NewtonOrderParam (s : Finset α) (w : α → ℝ) : ℝ := ...

def LogConcavityGap (e : ℕ → ℝ) (k : ℕ) : ℝ :=
  Real.log (e (k-1)) + Real.log (e (k+1)) - 2 * Real.log (e k)

theorem ssh_gapped_newton_bounded
  (δ : ℝ) (hδ : δ ≠ 0)
  (hcluster :
    ∃ ε > 0, ∀ m : ℕ, ∀ i : Fin m, ε ≤ sshEigenvalue δ m i ∧ sshEigenvalue δ m i ≤ 1 - ε) :
  ∃ C > 0, ∀ m : ℕ, sshNewtonOrder δ m ≤ C
```

```lean
theorem newtonOrder_lower_bound_of_log_gap
  (e : ℕ → ℝ) (N : ℕ → ℝ)
  (hpos : ∀ k ≥ 1, 0 < e k)
  (hdef : ∀ k ≥ 1, N k = Real.log (e (k-1) * e (k+1) / (e k)^2))
  (hk : ℕ → ℕ)
  (hgap : ∃ c > 0, ∃ b : ℝ, ∀ᶠ m in Filter.atTop,
    c * Real.log m - b ≤ N (hk m)) :
  ∃ c > 0, ∃ b : ℝ, ∀ᶠ m in Filter.atTop,
    c * Real.log m - b ≤ criticalNewtonOrder e m
```

```lean
theorem unbounded_of_frequently_ge_log
  (f : ℕ → ℝ)
  (h : ∃ c > 0, ∃ b : ℝ, ∀ᶠ m in Filter.atTop, c * Real.log m - b ≤ f m) :
  ¬ BddAbove (Set.range f)
```

```lean
structure ToeplitzNewtonAsymptotic where
  e : ℕ → ℕ → ℝ
  pos : ∀ m k, 0 < e m k
  admissible : ∀ m, ...
  critical_gap :
    ∃ c > 0, ∃ b : ℝ, ∀ᶠ m in Filter.atTop,
      c * Real.log m - b ≤
        supNewtonGap (e m)

theorem critical_toeplitz_implies_unbounded_newton
  (A : ToeplitzNewtonAsymptotic) :
  ¬ BddAbove (Set.range fun m => supNewtonGap (A.e m))
```

If Mathlib’s exact API forces modifications, preserve the mathematical content. The point is to make the asymptotic criterion itself formal and reusable.

---

## New Definitions You Should Introduce

You are required to define at least one genuinely new structure not already present in the catalog. Recommended definitions:

1. **`ToeplitzNewtonAsymptotic`**  
   Encodes a family of positive elementary-symmetric profiles together with a critical lower bound on the Newton gap.

2. **`supNewtonGap`**  
   The supremal logarithmic Newton defect of a finite positive sequence:
   \[
   \sup_k \log\frac{e_{k-1}e_{k+1}}{e_k^2}.
   \]

3. **`SpectrallyPinchedFamily`**  
   A reusable abstraction for families of spectra uniformly contained in `[ε,1-ε]`, allowing the SSH gapped theorem to be a corollary of a general algebraic result.

These definitions should not be decorative: they should organize the theory and make it transportable to other free-fermion or Toeplitz systems.

---

## Required Theorem List

Your Lean development must contain at least **3 substantial theorems** with nontrivial proofs. Suggested package:

1. **General pinching-to-boundedness theorem**  
   Extending the catalog theorem to a family indexed by `m`, using multi-step inequalities and `calc`.

2. **Log-second-difference to Newton-order lower bound**  
   A theorem converting asymptotic concavity defects of `log e_k` into lower bounds on the Newton order parameter.

3. **Unboundedness from logarithmic lower growth**  
   A theorem showing that if `f m ≥ c log m - b` frequently enough, then `f` is unbounded above.

4. **Cross-domain theorem:** Toeplitz asymptotic criterion ⇒ algebraic phase diagnostic  
   This is the conceptual bridge theorem and should be stated in abstract enough form to apply beyond SSH.

At least one proof should seriously use `by_contra`, one should use `rcases`, and one should use a multi-line `calc` or asymptotic comparison argument. Avoid toy lemmas.

---

## Proof Architecture: 3 Possible Routes

### Strategy A: Algebraic reduction + abstract asymptotic criterion
**Most promising for this cycle.**

1. **Gapped side:** Formalize a general theorem: any family of spectra uniformly pinched away from `0` and `1` has uniformly bounded Newton order. Then instantiate to SSH using the catalog foundation `newtonRatio_bounded_of_spectral_pinching`.
2. **Critical side:** Avoid full Fisher–Hartwig formalization initially. Instead prove an abstract theorem: if the elementary-symmetric profile satisfies a lower bound on the log-concavity defect along a subsequence, then the Newton order diverges.
3. **Bridge theorem:** Package the critical SSH claim as “Toeplitz/Fisher–Hartwig asymptotics imply the abstract hypothesis.” Even if this last implication remains partially axiomatized, isolate the exact analytic statement needed.

**Why this is best:** it delivers a field-opening theorem schema now, while making the hard analytic input modular. It also creates reusable infrastructure for many-body free-fermion models beyond SSH.

### Strategy B: Determinantal route through generating functions
1. Let
   \[
   E_m(t)=\sum_{k=0}^m e_k^{(m)} t^k = \det(I+tC_m),
   \]
   where `C_m` is the correlation matrix.
2. Use Toeplitz determinant asymptotics for `det(I+tC_m)` and extract coefficient asymptotics for `e_k^{(m)}` by saddle-point or coefficient comparison methods.
3. Convert coefficient asymptotics into second-difference estimates for `\log e_k^{(m)}`.

**Why it is powerful:** it identifies the Newton profile with curvature of the logarithm of a determinantal generating function, making the algebraic invariant look like a thermodynamic susceptibility. This is mathematically deeper, but likely heavier analytically.

### Strategy C: Majorization / entanglement-spectrum geometry
1. Study how concentration of eigenvalues in the gapped phase enforces near-binomial behavior of `e_k`.
2. At criticality, use broadening of the entanglement spectrum and Toeplitz-induced edge singularities to force failure of uniform strong log-concavity.
3. Reinterpret the Newton order as a curvature invariant on the entropy-generating sequence.

**Why this matters:** it connects algebraic combinatorics with entanglement geometry and could lead to a universal criterion not tied specifically to Toeplitz operators. It is visionary but less direct for the current theorem.

---

## How to Build on the Catalog

Use `Pythagorean/NewtonQuantumOrderParameters.lean` as the starting spine. In particular:

- **`newtonRatio_bounded_of_spectral_pinching`** should be promoted from a one-shot statement to a **family theorem** indexed by subsystem size.
- **`SSHGappedConjecture`** should be turned into a rigorous theorem by replacing the physical statement “gapped SSH correlation eigenvalues cluster away from 0 and 1” with a formal hypothesis or imported analytic lemma.
- **`SSHCriticalConjecture`** should be refactored into:
  1. an abstract Toeplitz/Fisher–Hartwig criterion,
  2. an SSH specialization,
  3. a conjectural analytic input if necessary.

Also connect to any catalog theorem analogous to `esymm_newton_ineq`: the point is to elevate Newton inequalities from static inequalities to a **scale-dependent phase diagnostic**.

---

## Cross-Domain Connections You Must Make Explicit

This project must contain at least one theorem or formal proposition that explicitly bridges domains.

### Bridge 1: Algebraic combinatorics ↔ Toeplitz analysis
The `e_k` are coefficients of a Toeplitz determinant generating series. This means Newton inequalities become curvature statements about Toeplitz determinant asymptotics.

### Bridge 2: Symmetric polynomials ↔ quantum many-body physics
The Newton ratio profile of correlation eigenvalues acts as an **algebraic order parameter** for phase structure. This is a new kind of observable: combinatorial rather than local or spectral in the usual sense.

### Bridge 3: Asymptotic analysis ↔ information theory
Since correlation eigenvalues also determine Rényi entropies and entanglement spectra, any theorem controlling Newton defects should be discussed as a possible proxy for information-theoretic criticality.

You should state at least one theorem in a form reusable for:
- Toeplitz operators,
- determinantal point processes,
- free-fermion entanglement spectra,
- log-concave coefficient sequences in statistical mechanics.

---

## Falsifiable Conjecture with Computational Test

State and support at least one explicit conjecture that can be attacked with `demo.py`.

### Recommended conjecture
For the critical SSH chain (`δ = 0`), there exists `c > 0` such that
\[
\max_{1\le k\le m-1} \log\frac{e_{k-1}^{(m)}e_{k+1}^{(m)}}{(e_k^{(m)})^2}
\sim c \log m.
\]

### Testable prediction
Numerically compute the SSH block correlation matrix for increasing `m`, extract eigenvalues, compute `e_k` via stable recurrence, and plot
\[
\max_k \log\frac{e_{k-1}e_{k+1}}{e_k^2}
\]
against `\log m`. A linear trend with positive slope supports the conjecture; bounded behavior falsifies the strongest form.

Also test whether the maximizing index `k_*(m)` scales like `m/2`, `m^\alpha`, or remains edge-localized. This is scientifically important because it reveals where the critical curvature of the coefficient profile lives.

---

## Concrete Deliverables

You must produce **all** of the following:

### 1. Lean file with theorem package
Include:
- the new definitions above,
- at least 3 nontrivial theorems,
- minimal sorry usage,
- proofs using induction / `rcases` / `by_contra` / `field_simp` / multi-step `calc`,
- explicit reuse of catalog results.

### 2. `FUTURE_DIRECTIONS.md`
Provide **3–5 original research directions**, each written as real prose and each containing:
- **“The key insight is…”**
- **“Why now?”**

At least one direction must bridge to a different domain, such as:
- determinantal point processes,
- random matrix theory,
- tropical geometry,
- complexity of coefficient extraction,
- statistical mechanics.

### 3. `RESEARCH_PAPER.md`
A standalone scientific paper explaining:
- the Newton-order invariant,
- the SSH motivation,
- the main theorems,
- why bounded vs logarithmically divergent Newton order is a new phase diagnostic,
- what analytic input remains open if the full critical theorem is conditional.

Someone reading only this paper must understand the discovery and its significance.

### 4. `ARTICLE.md`
Write this in **Scientific American style**:
- vivid,
- accessible,
- focused on the mathematical and physical ideas,
- no emphasis on formal verification machinery.

The story is that a hidden algebraic curvature inside symmetric polynomials may detect when quantum matter becomes critical.

### 5. Verified computational method
Implement a certified or semi-certified algorithm to compute:
- SSH correlation eigenvalues for finite blocks,
- elementary symmetric polynomials stably,
- Newton ratio profile and its maximum.

This is not optional. The theorem should be accompanied by an executable mathematical method.

### 6. `demo.py`
Interactive demonstration showing:
- gapped (`δ ≠ 0`) versus critical (`δ = 0`) behavior,
- plots of `supNewtonGap` versus `m`,
- optionally heatmaps of the full Newton ratio profile in `(m,k)`.

---

## Suggested Lean Lemmas to Prove Along the Way

These are good intermediate targets:

```lean
theorem log_newtonRatio_eq_log_esymm
  (hkm1 : 1 ≤ k) (hkp1 : k + 1 ≤ n) :
  Real.log (NewtonRatio s w k)
    = 2 * Real.log (esymm s w k)
      - Real.log (esymm s w (k-1))
      - Real.log (esymm s w (k+1))
```

```lean
theorem supNewtonGap_ge_pointwise
  (k : ℕ) :
  pointwiseNewtonGap e k ≤ supNewtonGap e
```

```lean
theorem unbounded_of_subseq_log_lower_bound
  (f : ℕ → ℝ)
  (h : ∃ c > 0, ∃ b : ℝ, ∃ φ : ℕ → ℕ,
      StrictMono φ ∧
      ∀ n, c * Real.log (φ n) - b ≤ f (φ n)) :
  ¬ BddAbove (Set.range f)
```

```lean
theorem bounded_newton_of_uniform_pinching_family
  (hpinch : ∃ ε > 0, ∀ m i, ε ≤ λ m i ∧ λ m i ≤ 1 - ε) :
  ∃ C > 0, ∀ m, NewtonOrderOfSpectrum (λ m) ≤ C
```

```lean
theorem toeplitz_critical_gap_implies_phase_signal
  (hFH : CriticalFisherHartwigWitness A) :
  ∃ c > 0, ∃ b : ℝ, ∀ᶠ m in Filter.atTop,
    c * Real.log m - b ≤ sshNewtonOrder 0 m
```

---

## Revolutionary Significance

If you can prove even the abstract criterion plus the gapped SSH theorem, you have already opened a new research program:

- **Quantum phase detection by symmetric-polynomial curvature**
- **Toeplitz asymptotics as algebraic order-parameter theory**
- **Entanglement-spectrum diagnostics without entropy compression**
- **A transportable invariant for free fermions, determinantal processes, and statistical mechanics**

If you can push the critical case to a rigorous logarithmic divergence theorem, this becomes a flagship result: a mathematically clean algebraic invariant that detects criticality in a canonical quantum model. That would not be “another SSH theorem.” It would be the birth of a new language for phase transitions.

---

## Application Keywords

SSH model; Su–Schrieffer–Heeger chain; Newton inequalities; elementary symmetric polynomials; entanglement spectrum; Toeplitz determinants; Fisher–Hartwig asymptotics; quantum phase transition; free fermions; determinantal processes; log-concavity; spectral pinching; algebraic order parameter; condensed matter mathematics; asymptotic combinatorics; information-theoretic criticality.

---

## Nonnegotiable Standard

Do not settle for merely restating conjectures. Build the reusable algebraic-analytic infrastructure, prove the gapped theorem rigorously, and isolate the critical Toeplitz input in a form sharp enough that the remaining gap is a single identifiable analytic statement rather than a cloud of heuristics.

The key insight is that Newton defects are not just inequalities—they are curvature observables on determinantal coefficient profiles, and criticality should force that curvature to blow up.

Why now? Because the catalog already contains the algebraic backbone (`newtonRatio_bounded_of_spectral_pinching`), and this is the moment to connect it to one of the most analyzable quantum phase transitions in mathematical physics.

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
