Soli Deo Gloria

## Assignment: Direction 5: Spectral Phase Transitions in Quantum Many-Body Certification

**Mode:** prove

You are not being asked for an incremental adaptation of a catalog theorem. You are being asked to create the first rigorous bridge between **edge universality / spectral transition phenomena** and **certification thresholds for quantum many-body order**. The target is a mathematically clean theorem family that captures a sharp transition in certifiability when a structured Hamiltonian is perturbed by noise whose operator norm competes with the spectral gap.

The conceptual leap is this: the same “edge beats gap” mechanism that governs phase transitions in random spectral problems should govern when a noisy quantum state ceases to be certifiably in a topological phase. If you can formalize even a finite-dimensional prototype of this principle in Lean, you open a new program at the interface of **spectral theory, quantum information, topological order, and random-matrix-inspired certification**.

---

## Core Vision

Let \( H \) be a finite-dimensional Hermitian Hamiltonian with a distinguished low-energy subspace \( \mathcal G \) separated from the rest of the spectrum by a gap \( \Delta > 0 \). Let \( N \) be a Hermitian noise operator. Consider the perturbed Hamiltonian
\[
H_p := H + p N.
\]
The certification question is: when does the low-energy projector of \(H_p\) remain close enough to that of \(H\) to certify persistence of the original phase / order?

The breakthrough theorem should show that **there is a sharp norm-controlled threshold**
\[
p_* \asymp \frac{\Delta}{2 \|N\|},
\]
or more generally with an effective edge parameter \( \sigma_{\mathrm{eff}} \),
\[
p_* \asymp \frac{\Delta}{2 \sigma_{\mathrm{eff}}},
\]
such that below threshold the ground-space projector is stable and above threshold one can no longer guarantee certification by gap-based methods. This is the many-body analog of the \(2\sigma\) edge phenomenon.

Your formalization should not depend on the full analytic machinery of infinite-dimensional quantum mechanics. Work in **finite-dimensional inner product spaces / matrices**, define a robust notion of certification, and prove sharp finite-dimensional threshold theorems.

---

## Precise Formal Targets

You must introduce at least one genuinely new definition, and prove at least 3 substantial theorems with nontrivial proof structure.

### New Definitions to Introduce

A promising definition package:

1. **Gap-certified projector stability**
   - A predicate saying that a perturbation preserves a spectral certificate if the perturbation norm is strictly less than half the gap.

2. **Effective certification threshold**
   - A numerical quantity
     \[
     \mathrm{certThreshold}(H,N) := \frac{\mathrm{gap}(H)}{2 \|N\|},
     \]
     with appropriate conventions when \(\|N\|=0\).

3. **Phase transition window**
   - A structure encoding lower-stable regime / upper-unstable regime, possibly abstracting over any spectral certificate.

These are novel enough if formulated specifically for certification rather than generic perturbation theory.

---

## Suggested Lean 4 Formalization Targets

You do not need to hit exactly these names, but the mathematical content should be this precise.

### Definition sketches

```lean
/-- A finite-dimensional spectral certificate consisting of a low-energy subspace
and a positive spectral gap separating it from the complement. -/
structure SpectralCertificate (𝕜 V : Type _) [IsROrC 𝕜]
    [NormedAddCommGroup V] [InnerProductSpace 𝕜 V] [FiniteDimensional 𝕜 V] where
  carrier : Submodule 𝕜 V
  gap : ℝ
  gap_pos : 0 < gap

/-- Effective threshold for certification stability under a Hermitian perturbation. -/
def certThreshold (Δ σ : ℝ) : ℝ := Δ / (2 * σ)

/-- A perturbation is subcritical if its operator norm is below half the gap. -/
def Subcritical (Δ ‖N‖ : ℝ) : Prop := ‖N‖ < Δ / 2
```

If matrix-based formalization is easier:

```lean
def HermitianMatrix (n : Type _) [Fintype n] [DecidableEq n] :=
  Matrix n n ℂ

def spectralGapLowerBound {n : Type _} [Fintype n] [DecidableEq n]
    (H : Matrix n n ℂ) (Δ : ℝ) : Prop := ...

def certThresholdMatrix {n : Type _} [Fintype n] [DecidableEq n]
    (Δ : ℝ) (N : Matrix n n ℂ) : ℝ :=
  Δ / (2 * ‖N‖)
```

### Theorem 1: Subcritical stability theorem

This is the central theorem.

**Mathematical statement**

Let \(H\) be Hermitian with a low-energy sector separated by gap \(\Delta>0\). Let \(N\) be Hermitian. If
\[
p \|N\| < \frac{\Delta}{2},
\]
then the perturbation \(H_p = H + pN\) preserves the spectral separation, hence the low-energy sector remains uniquely certifiable by the same gap-based criterion.

**Lean-style target**

```lean
theorem subcritical_gap_stability
    {n : Type _} [Fintype n] [DecidableEq n]
    (H N : Matrix n n ℂ) (Δ p : ℝ)
    (hH : IsHermitian H)
    (hN : IsHermitian N)
    (hgap : spectralGapLowerBound H Δ)
    (hΔ : 0 < Δ)
    (hsub : p * ‖N‖ < Δ / 2) :
    spectralGapLowerBound (H + (p : ℂ) • N) (Δ - 2 * p * ‖N‖)
```

This is already a real theorem: it says the gap degrades at most linearly with perturbation norm, and remains positive in the subcritical regime.

### Theorem 2: Certification threshold positivity

**Mathematical statement**

Under the same hypotheses, if \(p < \mathrm{certThreshold}(\Delta,\|N\|)\), then the perturbed gap lower bound is positive:
\[
\Delta - 2p\|N\| > 0.
\]

This theorem turns the abstract stability bound into an explicit phase transition criterion.

**Lean-style target**

```lean
theorem certThreshold_spec
    (Δ σ p : ℝ)
    (hΔ : 0 < Δ)
    (hσ : 0 < σ)
    (hp : p < certThreshold Δ σ) :
    0 < Δ - 2 * p * σ
```

This theorem should not be discharged by linear arithmetic alone if you can avoid it; prove it via `field_simp`, rearrangement, and a multi-step `calc`.

### Theorem 3: Cross-domain theorem — fidelity lower bound from spectral stability

This is where you bridge spectral theory to quantum information.

Define a finite-dimensional notion of a **ground-state certification score** or a **projector overlap score**, and prove that positive post-perturbation gap implies a quantitative lower bound on overlap/fidelity for any vector initially in the certified subspace.

A prototype:

**Mathematical statement**

If \(P\) is the projector onto the certified subspace of \(H\), and the perturbed Hamiltonian retains gap at least \(\delta>0\), then vectors \( \psi \in \mathrm{range}(P)\) remain energetically separated under \(H_p\), yielding a lower bound on a certification functional
\[
\mathcal C_{H_p}(\psi) \ge \delta.
\]

Or in a simpler algebraic version:

For a normalized vector \(\psi\), if \( \psi \) is in the kernel of \(H\) and \( \|pN\| < \Delta/2\), then
\[
\langle \psi, H_p \psi \rangle \le p \|N\|
\]
while every vector orthogonal to the ground space has energy at least
\[
\Delta - p\|N\|,
\]
hence the energy test still certifies the phase.

**Lean-style target**

```lean
theorem energy_certification_survives_subcritical_noise
    {n : Type _} [Fintype n] [DecidableEq n]
    (H N : Matrix n n ℂ) (Δ p : ℝ) (ψ : n → ℂ)
    (hH : IsHermitian H) (hN : IsHermitian N)
    (hgap : spectralGapLowerBound H Δ)
    (hψ_ground : IsGroundStateVector H ψ)
    (hnorm : ‖ψ‖ = 1)
    (hsub : p * ‖N‖ < Δ / 2) :
    certificationScore (H + (p : ℂ) • N) ψ > 0
```

This theorem is the bridge: **spectral perturbation theory implies quantum certification stability**.

### Theorem 4: Monotonicity of the certification window

A clean theorem that can support algorithms:

```lean
theorem certThreshold_monotone_gap
    {Δ₁ Δ₂ σ : ℝ}
    (hσ : 0 < σ) (hΔ : Δ₁ ≤ Δ₂) :
    certThreshold Δ₁ σ ≤ certThreshold Δ₂ σ
```

and/or

```lean
theorem certThreshold_antitone_noise
    {Δ σ₁ σ₂ : ℝ}
    (hΔ : 0 ≤ Δ) (hσ : 0 < σ₁) (hσσ : σ₁ ≤ σ₂) :
    certThreshold Δ σ₂ ≤ certThreshold Δ σ₁
```

These may look elementary, but they become conceptually important once interpreted physically: larger gap helps certification, larger noise edge hurts it.

---

## Stronger Theorem Ambition: A Finite-Dimensional “Phase Transition Window” Result

If the library support allows, aim for a theorem of the following shape:

**Theorem (Finite-dimensional certification transition window).**  
Let \(H\) be Hermitian with isolated ground-space and gap \(\Delta>0\). Let \(N\) be Hermitian with effective edge parameter \(\sigma_{\mathrm{eff}}>0\) satisfying \(\|N\| \le \sigma_{\mathrm{eff}}\). Then:

1. (**Stable regime**) If \(p < \Delta/(2\sigma_{\mathrm{eff}})\), certification persists.
2. (**No universal certification beyond threshold**) If \(p > \Delta/(2\sigma_{\mathrm{eff}})\), there exists a perturbation of admissible size for which the gap lower bound vanishes.

This gives both a **lower stability theorem** and an **upper impossibility theorem**. The second clause is especially important: it turns a bound into a genuine phase transition statement.

**Lean-style sketch**

```lean
theorem stable_regime_below_threshold
    ...
    (hσ : ‖N‖ ≤ σeff)
    (hp : p < Δ / (2 * σeff)) :
    certificationStable H N Δ p

theorem no_uniform_certification_above_threshold
    ...
    (hp : Δ / (2 * σeff) < p) :
    ∃ N : Matrix n n ℂ, IsHermitian N ∧ ‖N‖ ≤ σeff ∧
      ¬ certificationStable H N Δ p
```

This pair would be genuinely field-opening.

---

## Proof Strategy Architecture

You must include 2–3 possible proof routes in your working notes and choose one as primary.

### Strategy A: Direct spectral-gap perturbation route
**Most promising.**

1. Formalize a lower bound showing that under Hermitian perturbation, every excited-state energy can move by at most \(p\|N\|\), and every ground-state energy can also move by at most \(p\|N\|\).
2. Deduce that the gap can shrink by at most \(2p\|N\|\).
3. Convert positivity of the residual gap into a certification statement.

**Why this is promising:** it requires only finite-dimensional operator norm estimates and avoids heavy topology / C\(^*\)-algebra machinery. It is also the cleanest way to connect catalog spectral stability results to a quantum-information theorem.

### Strategy B: Min-max / Courant–Fischer style route
1. Express low eigenvalues and excited eigenvalues variationally.
2. Bound perturbative shifts in Rayleigh quotients.
3. Derive the same threshold via min-max inequalities.

**Why this is powerful:** it gives sharper and more canonical spectral statements, and may scale better to higher-rank ground spaces. Use this if Mathlib’s linear algebra / sesquilinear form tools are strong enough.

### Strategy C: Projector geometry / Davis–Kahan inspired route
1. Define spectral projectors for the low-energy band.
2. Show that subcritical perturbation controls projector angle / overlap.
3. Translate projector closeness into fidelity or certification-score lower bounds.

**Why this is visionary:** this is the route that most clearly connects to topological order certification and quantum information. It is mathematically deeper, but may require more analytic infrastructure than is currently practical. If feasible, this becomes the crown jewel theorem.

**Recommendation:** Prove the core threshold theorem by Strategy A, then derive the quantum-information bridge theorem with a simplified projector/energy certificate. If infrastructure permits, add a Strategy C theorem as the headline result.

---

## How to Build on Catalog Theorems

You are explicitly expected to build on:

- `Pythagorean/SharpGOEConstants.lean`
- `Catalog/Speculative/AutoResearch/LorentzianStability.lean`

Use them not as decorative citations but as structural input.

### From `SharpGOEConstants.lean`
Extract the philosophical and formal pattern:
- there is a **sharp edge scale**,
- there is a **transition when signal/gap matches twice the edge size**,
- finite-size scaling and universality are encoded through explicit threshold constants.

Your job is to port this pattern from random matrix eigenvalue separation to **quantum certification under structured perturbations**. Even if you do not formalize GOE randomness itself, you should mirror the theorem architecture:
- define the critical threshold,
- prove below-threshold stability,
- prove above-threshold failure of uniform certification.

### From `LorentzianStability.lean`
Use any certified perturbative stability lemma for spectral gaps, resolvent-type stability, or norm-controlled operator perturbations.
The key transfer is:
- catalog theorem gives: perturbation smaller than gap preserves a spectral feature;
- your theorem upgrades this to: perturbation smaller than half-gap preserves a **two-sided certification window**, because both the low-energy band and the excited band can move.

That “factor of 2” is the conceptual heart. Make it explicit.

---

## Cross-Domain Connections You Must Make Explicit

This direction is only worthwhile if the paper and code visibly connect domains.

### 1. Quantum information ↔ spectral theory
Certification of topological order becomes a theorem about persistence of an isolated low-energy spectral band.

### 2. Random matrix theory ↔ many-body physics
The \(2\sigma\) edge phenomenon becomes a prototype for a many-body noise threshold:
the random edge scale is replaced by an effective operator norm / edge parameter of the noise channel.

### 3. Condensed matter ↔ verified algorithms
A computable threshold
\[
p_* = \frac{\Delta}{2 \sigma_{\mathrm{eff}}}
\]
becomes an algorithm for certifying whether a noisy finite-size Hamiltonian remains in the stable regime.

### 4. Error correction ↔ variational spectral inequalities
The same inequalities that protect encoded states in topological codes become gap-preservation lemmas in finite-dimensional linear algebra.

---

## Application Keywords

Include these in comments, paper prose, and article prose where appropriate:

- topological order
- toric code
- quantum error correction
- spectral gap stability
- phase transition
- universality
- random matrix edge
- fidelity certification
- many-body localization
- noise threshold
- projector stability
- Hamiltonian complexity
- robust quantum memory
- condensed matter
- variational principle

---

## Computational / Algorithmic Deliverable

You must provide a **verified algorithm**, not merely theorem statements.

### Algorithm target
Implement a procedure that takes:
- a finite Hermitian matrix \(H\),
- a Hermitian noise matrix \(N\),
- a candidate gap lower bound \(\Delta\),
- a noise strength \(p\),

and returns:
- the certified residual gap lower bound \( \Delta - 2p\|N\| \),
- whether the perturbation is subcritical,
- the predicted threshold \( p_* = \Delta/(2\|N\|) \).

### Lean-facing spec sketch

```lean
def certificationResidualGap (Δ p σ : ℝ) : ℝ := Δ - 2 * p * σ

def certifyPhase (Δ p σ : ℝ) : Bool :=
  0 < certificationResidualGap Δ p σ
```

Then prove correctness theorems connecting the boolean output to the mathematical predicate.

### demo.py
Create an interactive Python demo that:
1. constructs small toric-code-inspired or toy gapped Hermitian matrices,
2. perturbs them by Hermitian noise,
3. computes empirical eigenvalue gaps and compares with the certified bound,
4. plots the normalized parameter \(p/p_*\),
5. explores whether finite-size collapse heuristics appear.

Even a toy model is acceptable if the mathematical theorem is exact and the simulation illustrates the predicted transition.

---

## Conjecture with Testable Prediction

You must state at least one falsifiable conjecture.

### Conjecture A: Finite-size certification collapse
For a family of finite-size toric-code Hamiltonians \(H_L\) with effective noise matrices \(N_L\), the normalized certification score
\[
\Phi_L(p) := \frac{\text{certification score at } p}{\text{certification score at } 0}
\]
when plotted against \(p/p_*(L)\), exhibits finite-size collapse near the threshold, with transition width scaling like \(L^{-2/3}\) or equivalently \(n^{-2/3}\) under suitable indexing.

**Computational test:** simulate small \(L\), compute certification score curves, rescale by \(p_*(L)\), and check collapse.

### Conjecture B: Effective-edge universality
For broad classes of local Hermitian noise with matching variance profile, the certification threshold depends asymptotically only on \(\sigma_{\mathrm{eff}}\) and \(\Delta\), not on microscopic details of the noise ensemble.

**Computational test:** compare Gaussian, sparse, and local Pauli noise ensembles after matching \(\sigma_{\mathrm{eff}}\).

These conjectures are scientifically valuable because they predict a universality class for many-body certification thresholds.

---

## Minimum Theorem List You Should Actually Aim to Formalize

At minimum, prove these three with substantial proof scripts:

1. `certThreshold_spec`
   - use `field_simp`, contradiction, and `calc`.

2. `subcritical_gap_stability`
   - use multi-step perturbative inequalities; avoid trivial automation.

3. `energy_certification_survives_subcritical_noise`
   - use `rcases`, subspace decomposition or Rayleigh quotient bounds, and a nontrivial inequality chain.

If possible, add a fourth:
4. `no_uniform_certification_above_threshold`

---

## What Would Make This a Breakthrough

If you succeed, you will have produced the first Lean-formalized theorem schema in which:

- a **random-matrix-style edge threshold** becomes
- a **many-body certification threshold** for quantum phases,
- with an explicit **algorithmic certificate**,
- and a testable conjecture for **finite-size scaling** in topological systems.

That is not a routine formalization. It is the seed of a new field: **certified quantum phase stability via spectral universality**.

---

## Mandatory Deliverables

You must produce **all** of the following:

### 1. `FUTURE_DIRECTIONS.md`
Include 3–5 original research directions. Each direction must include the exact sentences:
- **“The key insight is...”**
- **“Why now?”**

At least one direction must bridge to a different domain, such as:
- Hamiltonian complexity ↔ random matrix universality
- topological matter ↔ tropical/spectral geometry
- quantum coding ↔ certified optimization

### 2. `RESEARCH_PAPER.md`
A standalone scientific paper. A reader with no access to code must understand:
- the theorem statements,
- why the \(2\sigma\)-style threshold is conceptually new,
- how it connects to topological order and noise thresholds,
- what the conjectural finite-size scaling program is.

Do not write this as verification notes. Write it as mathematics / physics.

### 3. `ARTICLE.md`
Scientific American style. Accessible, engaging, idea-centered.  
**Taboo:** do **not** focus on formal verification or theorem proving infrastructure. Focus on the scientific idea: that noisy quantum matter may lose certifiability at a sharply predictable spectral threshold.

### 4. Verified algorithm or computational method
The certification-threshold algorithm described above, with correctness theorems.

### 5. `demo.py`
Interactive demonstration of the threshold on toy many-body Hamiltonians or toric-code-inspired finite matrices.

---

## Final Instruction

Do not retreat to vague physics language. Extract the mathematically rigid finite-dimensional core and prove it. The real target is not “quantum many-body hype”; it is a new theorem schema:

> **gap protection + edge-scale perturbation = sharp certification threshold**

Formalize that schema, prove it in a robust finite-dimensional setting, and make the bridge to quantum certification explicit.

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
