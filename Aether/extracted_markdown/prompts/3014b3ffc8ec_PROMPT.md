Soli Deo Gloria

## Assignment: Direction 3 — Strong Rayleigh Property and Spectral Gap Certificates

**Mode:** `prove`

You are not being asked for a routine extension. You are being asked to build a new bridge between **Lorentzian/Hodge-theoretic curvature** and **quantitative Markov-chain mixing** for basis exchange walks on matroids. The target is a certifiable spectral-gap theory that turns algebraic negativity of Hessians into explicit convergence guarantees. If successful, this is not “another mixing proof”: it is a new **certificate paradigm** for stochastic sampling from combinatorial structures.

Build on the catalog theorems in:

- `Catalog/Pythagorean/LorentzianRecognitionComplete.lean`
- `Catalog/Pythagorean/LorentzianExchangeCertificates.lean`

Use them not as endpoints, but as the first layer of a larger architecture:
- the **Hessian signature** machinery should become a **Dirichlet-form inequality**;
- the existing **exchange certificate** should become a **recursive or truncated spectral certificate**;
- the matroid basis walk should become the first instance of a broader “curvature ⇒ gap” formalism.

---

## Central Theorem Targets

You should aim to formalize **at least 3 substantial theorems** around the following core program. The exact final assumptions may need slight adjustment to fit Mathlib and the catalog interfaces, but the theorem statements should remain as close as possible to the mathematical targets below.

### Theorem A — Lorentzian one-step exchange certificate implies Poincaré inequality

Let `M` be a finite matroid of rank `r ≥ 1` on ground set `α`, and let `μ` be the uniform measure on bases. Let `P` be the basis exchange walk operator on functions `f : Basis M → ℝ`, and let `𝓔(f,f)` denote its Dirichlet form. Define a new notion of **Lorentzian exchange certificate constant** `κ(M) > 0` extracted from the Hessian-signature witness of the basis-generating polynomial.

**Precise mathematical target:**
For every `f` orthogonal to constants,
\[
\mathrm{Var}_\mu(f) \le \frac{1}{\kappa(M)} \, \mathcal E(f,f),
\]
and hence the spectral gap satisfies
\[
\lambda_{\mathrm{gap}}(P) \ge \kappa(M).
\]

This is the first theorem that turns the Lorentzian signature into a bona fide spectral-gap certificate.

### Suggested Lean 4 shape
```lean
theorem variance_le_dirichlet_of_lorentzian_certificate
  {α : Type*} [Fintype α] [DecidableEq α]
  (M : Matroid α)
  (hSR : StrongRayleighBasisGen M)
  (hcert : HasLorentzianExchangeCertificate M)
  {f : BasisState M → ℝ}
  (hmean : IsOrthogonalToConstants (basisUniform M) f) :
  variance (basisUniform M) f
    ≤ (lorentzianCertificateConst M)⁻¹ * dirichletForm (basisExchangeKernel M) f f := by
  sorry
```

and the gap corollary:
```lean
theorem spectralGap_lowerBound_of_lorentzian_certificate
  {α : Type*} [Fintype α] [DecidableEq α]
  (M : Matroid α)
  (hSR : StrongRayleighBasisGen M)
  (hcert : HasLorentzianExchangeCertificate M) :
  lorentzianCertificateConst M ≤ spectralGap (basisExchangeKernel M) := by
  sorry
```

---

### Theorem B — Rank-scale lower bound: `Ω(1/r)` from a normalized Lorentzian certificate

Define a normalized certificate notion strong enough to force a rank-sensitive bound. Then prove:

\[
\lambda_{\mathrm{gap}}(P_M) \ge \frac{C}{r(M)}
\]
for some explicit universal constant `C > 0`, under a formally stated normalization hypothesis on the Hessian certificate.

This theorem is the true conceptual breakthrough: it says the exchange walk mixes at a universal rank scale because the Lorentzian geometry constrains the allowed negative directions.

### Suggested Lean 4 shape
```lean
theorem spectralGap_lowerBound_rank
  {α : Type*} [Fintype α] [DecidableEq α]
  (M : Matroid α)
  (hR : 0 < M.rank)
  (hSR : StrongRayleighBasisGen M)
  (hnorm : NormalizedLorentzianCertificate M) :
  (spectralGap (basisExchangeKernel M)) ≥
    universalGapConstant / (M.rank : ℝ) := by
  sorry
```

If direct formalization of full matroid rank is too heavy, it is acceptable to first prove the theorem for a restricted class such as:
- partition matroids,
- graphic matroids,
- or a finite abstract exchange system already encoded in the catalog.

But the theorem must still be conceptually nontrivial and must exhibit the `1/r` scale.

---

### Theorem C — Truncated certificate depth gives quantitative approximation to the gap

Define a new structure expressing a **depth-`k` truncated Lorentzian certificate**. Then prove an approximation theorem of the form:

If the certificate is iterated/refined to depth
\[
k \ge C r \log(1/\varepsilon),
\]
then the computed lower bound `κ_k(M)` satisfies
\[
\lambda_{\mathrm{gap}}(P_M) - \kappa_k(M) \le \varepsilon.
\]

This is the algorithmic heart of the project. It converts structural geometry into a certified approximation procedure.

### Suggested Lean 4 shape
```lean
theorem truncatedCertificate_approximates_spectralGap
  {α : Type*} [Fintype α] [DecidableEq α]
  (M : Matroid α)
  (hSR : StrongRayleighBasisGen M)
  (hconv : HasContractiveCertificateRefinement M)
  {ε : ℝ} (hε : 0 < ε) :
  ∃ k : ℕ,
    k ≤ Nat.ceil (certificateDepthConstant * M.rank * Real.log (1 / ε)) ∧
    spectralGap (basisExchangeKernel M) - truncatedGapLowerBound M k ≤ ε := by
  sorry
```

This theorem should not be fake asymptotics. Introduce the exact recursive quantity being approximated and prove a genuine error decay inequality.

---

## New Definitions You Must Introduce

At least one genuinely new definition is mandatory; in fact, this project wants several. Suggested definitions:

### 1. `HasLorentzianExchangeCertificate`
A structure packaging the data that transforms Hessian signature information into a one-step exchange inequality.

```lean
structure HasLorentzianExchangeCertificate
  {α : Type*} [Fintype α] [DecidableEq α] (M : Matroid α) : Prop where
  certConst : ℝ
  certConst_pos : 0 < certConst
  hessianWitness : LorentzianHessianWitness M
  exchangeBound :
    ∀ f : BasisState M → ℝ,
      variance (basisUniform M) f ≤ certConst⁻¹ * dirichletForm (basisExchangeKernel M) f f
```

### 2. `NormalizedLorentzianCertificate`
A normalization ensuring the certificate scales correctly with rank.

```lean
structure NormalizedLorentzianCertificate
  {α : Type*} [Fintype α] [DecidableEq α] (M : Matroid α) : Prop where
  baseCert : HasLorentzianExchangeCertificate M
  rankScaled :
    universalGapConstant / (M.rank : ℝ) ≤ baseCert.certConst
```

### 3. `TruncatedCertificate`
A recursively computable finite-depth certificate.

```lean
structure TruncatedCertificate
  {α : Type*} [Fintype α] [DecidableEq α] (M : Matroid α) where
  depth : ℕ
  lowerBound : ℝ
  admissible : Prop
  monotone_refine :
    ∀ {d1 d2 : ℕ}, d1 ≤ d2 →
      truncatedGapLowerBoundAt M d1 ≤ truncatedGapLowerBoundAt M d2
```

### 4. Cross-domain definition: `CurvatureControlledKernel`
Abstract the phenomenon away from matroids, so one theorem can speak simultaneously to probability and geometry.

```lean
structure CurvatureControlledKernel
  (Ω : Type*) [Fintype Ω] where
  μ : FinPMF Ω
  P : Ω → Ω → ℝ
  curvatureConst : ℝ
  curvatureConst_pos : 0 < curvatureConst
  poincare_from_curvature :
    ∀ f : Ω → ℝ,
      IsOrthogonalToConstants μ f →
      variance μ f ≤ curvatureConst⁻¹ * dirichletFormFromKernel μ P f f
```

This abstraction is important: it opens the door to simplicial walks, high-dimensional expanders, determinantal processes, and even quantum-inspired sampling kernels.

---

## Cross-Domain Theorem Requirement

You must include at least one theorem connecting this project to a different domain.

### Theorem D — Curvature-controlled kernels as a bridge to high-dimensional expanders or quantum sampling

A good target is:

> Any reversible finite kernel equipped with a Lorentzian-type curvature certificate satisfies a Poincaré inequality, and hence rapid mixing. In particular, the matroid basis exchange walk is an instance of a general curvature-controlled stochastic process.

### Suggested Lean 4 shape
```lean
theorem spectralGap_lowerBound_of_curvatureControlled
  {Ω : Type*} [Fintype Ω] [DecidableEq Ω]
  (K : CurvatureControlledKernel Ω) :
  K.curvatureConst ≤ spectralGapFromKernel K.μ K.P := by
  sorry
```

Then instantiate this theorem for basis exchange:
```lean
theorem basisExchange_is_curvatureControlled
  {α : Type*} [Fintype α] [DecidableEq α]
  (M : Matroid α)
  (hcert : HasLorentzianExchangeCertificate M) :
  CurvatureControlledKernel (BasisState M) := by
  sorry
```

This is where the project stops being “just matroids.” It becomes a prototype for a **curvature-to-mixing dictionary**.

Possible cross-domain interpretations:
- **Probability / Markov chains:** Poincaré and log-Sobolev inequalities.
- **Algebraic geometry:** Lorentzian/Hodge-Riemann signatures.
- **Quantum computing:** rapidly mixing samplers for negative dependence distributions.
- **Statistical physics:** exchange dynamics under strong repulsion / exclusion constraints.
- **Information theory:** curvature as a certificate of entropy decay.

---

## Conjecture with Falsifiable Computational Prediction

State and test at least one precise conjecture.

### Conjecture E — Exact rank law for partition matroids
For every partition matroid `M` of rank `r`, the basis exchange walk has
\[
\lambda_{\mathrm{gap}}(P_M) = \frac{1}{r}.
\]

### Lean-facing statement
```lean
conjecture partitionMatroid_exact_spectralGap
  {α : Type*} [Fintype α] [DecidableEq α]
  (M : Matroid α) :
  IsPartitionMatroid M →
  spectralGap (basisExchangeKernel M) = 1 / (M.rank : ℝ)
```

### Computational test
- Enumerate small partition matroids.
- Construct the exchange transition matrix explicitly.
- Compute the second-largest eigenvalue numerically.
- Compare `1 - λ₂` against `1/r`.

This conjecture is falsifiable: a single small counterexample destroys it.

A second, more ambitious conjecture:

### Conjecture F — Graphic matroid universal constant
There exists `C > 0` such that for every connected graph `G`,
\[
\lambda_{\mathrm{gap}}(P_{M(G)}) \ge \frac{C}{\mathrm{rank}(M(G))}.
\]

Test on:
- complete graphs,
- cycles with chords,
- Erdős–Rényi random graphs,
- sparse expanders.

---

## Proof Strategy Architecture

Do not give one proof sketch. Build at least 2–3 viable routes and decide which is most promising.

### Strategy 1 — Dirichlet-form extraction from reversed Cauchy–Schwarz
**Most promising.**

1. Use the reversed Cauchy–Schwarz / Hodge-Riemann inequality already formalized in the Lorentzian catalog to control the quadratic form induced by the Hessian on mean-zero perturbations.
2. Identify the exchange Dirichlet form as the combinatorial shadow of this quadratic form, likely by expressing one-step basis exchanges as tangent directions in the basis polytope or as second-derivative directions of the generating polynomial.
3. Convert the quadratic-form domination into a Poincaré inequality, then deduce the spectral-gap bound via the variational characterization.

Why this is strongest:
- It directly realizes the project’s philosophical claim: **negative curvature controls mixing**.
- It uses catalog machinery in a structurally meaningful way.
- It naturally produces explicit constants.

Deep proof tactics likely needed:
- `rcases` to unpack certificate structures and Hessian witnesses,
- multi-step `calc` chains to compare quadratic forms,
- `by_contra` in the variational step if proving optimality/minimality of the gap bound.

---

### Strategy 2 — Induction on rank via deletion–contraction or links
1. Prove a one-step decomposition of variance or Dirichlet form along deletion/contraction minors, or along conditioning on an element.
2. Use strong Rayleigh stability to show the inductive hypotheses persist to the minors/restrictions.
3. Accumulate the lower bound recursively to obtain a `C/r` estimate.

Why it matters:
- This approach mirrors the recursive nature of negative dependence and may be better suited for the truncated certificate theorem.
- It could produce an actual algorithm for refining certificates by descending to minors.

This strategy should involve:
- induction on rank,
- `rcases` on whether an element belongs to a basis state,
- careful algebraic estimates via `field_simp` and `calc`.

---

### Strategy 3 — Canonical-path / comparison method certified by Lorentzian geometry
1. Define a comparison chain with known spectral gap (for example, a product-type chain in the partition matroid case).
2. Use the exchange certificate to bound congestion or energy inflation when embedding the basis walk into the comparison chain.
3. Transfer the gap lower bound by a comparison theorem.

Why it is less direct but valuable:
- It may be easier to formalize first for partition or graphic matroids.
- It gives algorithmic intuition and may produce stronger demo code.
- It connects to theoretical computer science and approximate sampling.

This strategy is especially useful if direct Hessian-to-Dirichlet translation becomes too abstract in Lean.

---

## Building Blocks from the Catalog

You explicitly need to identify and reuse the strongest existing lemmas from:

- `Catalog/Pythagorean/LorentzianRecognitionComplete.lean`
  - Use the Hessian-signature theorem: the “at most one positive eigenvalue” condition should become the geometric source of your curvature constant.
  - Any certified recognition or witness extraction result should be promoted into a reusable witness object for your new structures.

- `Catalog/Pythagorean/LorentzianExchangeCertificates.lean`
  - Use the exchange-from-log-concavity theorem as the first combinatorial inequality.
  - Strengthen it from a local exchange estimate to a global Poincaré inequality.
  - If there is already a one-step lower bound, wrap it into `HasLorentzianExchangeCertificate` rather than reproving it ad hoc.

You should write helper lemmas that isolate:
1. mean-zero reduction,
2. quadratic-form comparison,
3. spectral-gap variational principle,
4. monotone improvement of truncated certificates.

---

## Formalization Scope Guidance

If full generality over all matroids is too heavy for one cycle, do **not** retreat to toy theorems. Instead, choose a strategically rich special case:

### Preferred fallback hierarchy
1. **Partition matroids** with exact gap theorem.
2. **Graphic matroids** with certified lower bound.
3. **Abstract reversible exchange systems** parameterized by an exchange axiom and a Lorentzian certificate.

Any of these still satisfies the scientific ambition if the theorem is deep and the certificate framework is genuinely new.

---

## Required Theorem Count and Proof Depth

Your Lean development must contain **at least 3 nontrivial theorems** proved with substantial reasoning. Suitable candidates:

1. `variance_le_dirichlet_of_lorentzian_certificate`
2. `spectralGap_lowerBound_rank`
3. `truncatedCertificate_approximates_spectralGap`
4. `spectralGap_lowerBound_of_curvatureControlled`
5. exact partition matroid gap theorem, if feasible

The proofs must use techniques like:
- induction,
- `rcases`,
- `by_contra`,
- `field_simp`,
- multi-step `calc`.

No trivial theorem padding. No theorem whose only meaningful proof is computation by reflection.

---

## Verified Algorithm / Computational Method

You must produce a **verified algorithm**, not just theorem statements.

### Algorithm target
Implement a certified procedure that, given:
- a finite exchange system / matroid instance,
- a depth parameter `k`,
- and possibly a Hessian witness,

returns a lower bound `κ_k` on the spectral gap together with a proof that
\[
κ_k \le \lambda_{\mathrm{gap}}.
\]

Possible Lean-facing interface:
```lean
def computeTruncatedGapCertificate
  {α : Type*} [Fintype α] [DecidableEq α]
  (M : Matroid α) (k : ℕ) : ℝ := ...

theorem computeTruncatedGapCertificate_sound
  {α : Type*} [Fintype α] [DecidableEq α]
  (M : Matroid α) (k : ℕ) :
  computeTruncatedGapCertificate M k ≤ spectralGap (basisExchangeKernel M) := by
  sorry
```

If exact general computation is difficult, specialize to partition or graphic matroids, but make the certificate theorem rigorous.

---

## `demo.py` Requirements

Create `demo.py` that:
1. constructs small partition matroids and graphic matroids;
2. builds the basis exchange transition matrix;
3. numerically estimates the spectral gap;
4. computes the truncated certificate lower bound;
5. plots or prints comparison tables for:
   - rank `r`,
   - numerical gap,
   - predicted `1/r`,
   - certified lower bound.

Include at least:
- complete graphs `K_n` for small `n`,
- random graphs on small vertex sets,
- several partition matroids with varying block sizes.

The demo should visibly test the conjectures and highlight whether the certified lower bound tracks the true gap.

---

## Standalone Scientific Writing Deliverables

You must produce **all** of the following:

### 1. `FUTURE_DIRECTIONS.md`
Include **3–5 original research directions**, each with:
- a title,
- a paragraph of original prose,
- the sentence **“The key insight is...”**
- the sentence **“Why now?”**

At least one direction must bridge to a different domain, such as:
- quantum sampling / Boson-like negative dependence,
- high-dimensional expanders,
- entropy decay and information theory,
- statistical physics of exclusion processes.

### 2. `RESEARCH_PAPER.md`
A standalone scientific paper that someone can read **without access to the code**. It must explain:
- the problem,
- the new definitions,
- the main theorems,
- why Lorentzian curvature should control exchange mixing,
- what was actually proved,
- numerical/computational evidence,
- limitations,
- next questions.

This must read like a real paper, not project notes.

### 3. `ARTICLE.md`
Write this in a **Scientific American** style.
Do **not** focus on formal verification machinery.
Focus on the mathematics and why it matters:
- how geometry can predict randomness,
- why “negative curvature” in an algebraic polynomial influences a random walk,
- why this matters for sampling, optimization, and quantum-inspired algorithms.

---

## Application Keywords

Include and emphasize these application keywords in the paper, article, and future directions:

- **strongly Rayleigh distributions**
- **Lorentzian polynomials**
- **spectral gap**
- **Poincaré inequality**
- **rapid mixing**
- **matroid basis exchange**
- **negative dependence**
- **Hodge theory**
- **high-dimensional expanders**
- **approximate sampling**
- **quantum computing**
- **determinantal processes**
- **entropy decay**
- **combinatorial curvature**
- **Markov chain Monte Carlo**

---

## Scientific Significance

Why this matters, in one sentence: if you can prove that a **Hessian-signature certificate implies a spectral-gap lower bound**, then you have created a new language in which **algebraic geometry certifies stochastic convergence**.

That is a field-opening perspective:
- It reframes rapid mixing as a curvature theorem.
- It suggests new certified samplers for negatively dependent distributions.
- It connects Lorentzian/Hodge theory to algorithm design.
- It could seed a general theory of curvature-controlled Markov processes beyond matroids.

Do not aim for a polite result. Aim for a theorem that makes people say:  
**“I did not know the Hessian of a basis-generating polynomial could certify the mixing time of a Markov chain.”**

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
