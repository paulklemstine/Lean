Soli Deo Gloria

## Assignment: Direction 2: Quantum Entanglement Entropy via DPP-Lorentzian Structure

**Mode**: prove

Prove genuinely new, non-trivial theorems that turn the DPP–Lorentzian bridge into a quantitative theory of free-fermion entanglement. The objective is not to restate known spectral facts, but to extract **entropy inequalities from Lorentzian coefficient geometry** and thereby open a new interface:

> **quantum information ↔ Lorentzian/Hodge theory ↔ determinantal probability ↔ spectral majorization**

Build explicitly on:

- `Pythagorean/LorentzianRecognitionComplete.lean`
- `Pythagorean/DPPLorentzian.lean`

especially the spectral bridge identifying DPP generating polynomials from correlation kernels and the certified Lorentzian criteria already formalized there.

The breakthrough target is this:  
for a free fermion state with correlation kernel `K`, the polynomial
\[
g_A(z) = \det(I - K_A + Z K_A), \qquad Z = \mathrm{diag}(z_1,\dots,z_m)
\]
encodes the subsystem entanglement spectrum through the eigenvalues of `K_A`, while its homogeneous coefficients are constrained by Lorentzian inequalities. You should prove that these coefficient constraints force **nontrivial entropy bounds**. If successful, this creates a new geometric method for bounding entanglement.

---

## Core Mathematical Vision

Let `A` be a subsystem of size `m`. If the restricted kernel `K_A` has eigenvalues
\[
\lambda_1,\dots,\lambda_m \in [0,1],
\]
then the free-fermion entanglement entropy is
\[
S(K_A) = \sum_{i=1}^m h(\lambda_i), \qquad
h(x) = -x\log x - (1-x)\log(1-x).
\]

At the same time, the DPP/subsystem generating polynomial has coefficient sequence
\[
e_k(\lambda_1,\dots,\lambda_m)
\]
up to the standard normalization induced by
\[
\det(I - K_A + t K_A) = \sum_{k=0}^m e_k(\lambda)\, t^k (1-t)^{m-k}
\]
or, equivalently,
\[
\det(I + x K_A) = \sum_{k=0}^m e_k(\lambda) x^k.
\]

The Lorentzian property imposes ultra-log-concavity / Alexandrov–Fenchel type inequalities on the sequence `(e_k)`. The research task is to convert those inequalities into rigorous bounds on spectral dispersion and hence on entropy.

This is not incremental. If you can show that Lorentzian geometry controls entanglement, you have produced a new language for quantum many-body structure.

---

## Precise Theorem Targets

You must formalize at least one new structure and prove at least 3 substantial theorems. The following theorem package is the recommended target.

### New definitions to introduce

Define a subsystem entropy package for finite spectra:

```lean
def binaryEntropy (x : ℝ) : ℝ :=
  -x * Real.log x - (1 - x) * Real.log (1 - x)

def fermionEntropy (s : Finset ι) (λ : ι → ℝ) : ℝ :=
  ∑ i in s, binaryEntropy (λ i)

def esymmProfile (m : ℕ) (λ : Fin m → ℝ) : ℕ → ℝ :=
  fun k => (Finset.univ.powersetCard k).sum (fun T => ∏ i in T, λ i)

def lorentzianGapRatio (m : ℕ) (a : ℕ → ℝ) (k : ℕ) : ℝ :=
  (a k)^2 / (a (k-1) * a (k+1))
```

If `esymmProfile` already exists in some usable form, define instead a genuinely new structure tying entropy to Lorentzian data, for example:

```lean
structure EntanglementLorentzianWitness (m : ℕ) where
  coeff : ℕ → ℝ
  ultraLogConcave' :
    ∀ ⦃k⦄, 1 ≤ k → k+1 ≤ m → coeff k ^ 2 ≥ coeff (k-1) * coeff (k+1)
  normalization :
    coeff 0 = 1
```

and then define a map from PSD contractions `K_A` to such witnesses.

---

## Theorem 1: Lorentzian coefficient log-concavity for subsystem spectra

### Mathematical statement
For any subsystem kernel `K_A` whose eigenvalues lie in `[0,1]`, the elementary symmetric profile of the eigenvalues is ultra-log-concave:
\[
e_k(\lambda)^2 \ge e_{k-1}(\lambda)e_{k+1}(\lambda)
\qquad (1 \le k \le m-1).
\]
This should be obtained by invoking the Lorentzian structure of the associated DPP polynomial, not merely by citing a classical standalone Newton inequality if the catalog bridge lets you derive it from Lorentzianity.

### Lean-style target
```lean
theorem subsystem_esymm_ultraLogConcave
  {m : ℕ} (λ : Fin m → ℝ)
  (h01 : ∀ i, 0 ≤ λ i ∧ λ i ≤ 1)
  (hLor : IsLorentzian (dppGeneratingPolynomial λ)) :
  ∀ ⦃k : ℕ⦄, 1 ≤ k → k + 1 ≤ m →
    (esymmProfile m λ k)^2 ≥
      esymmProfile m λ (k - 1) * esymmProfile m λ (k + 1)
```

### Why this matters
This is the portal theorem: it converts Hodge-theoretic positivity into spectral inequalities on the entanglement spectrum.

---

## Theorem 2: Entropy upper bound from quadratic spectral moment

Use the standard concavity inequality
\[
h(x) \le (\log 2)\, 4x(1-x)
\qquad (x\in[0,1]),
\]
or a formally convenient weaker bound if needed, to derive
\[
S(K_A) \le 4\log 2 \cdot \sum_i \lambda_i(1-\lambda_i)
= 4\log 2 \cdot \bigl(\operatorname{tr}(K_A)-\operatorname{tr}(K_A^2)\bigr).
\]

Then connect
\[
\sum_i \lambda_i(1-\lambda_i)
\]
to the first two elementary symmetric sums:
\[
e_1^2 - 2e_2 = \sum_i \lambda_i^2,
\qquad
\sum_i \lambda_i(1-\lambda_i)=e_1 - (e_1^2-2e_2).
\]
This expresses the entropy bound entirely in terms of Lorentzian-controlled coefficients.

### Lean-style target
```lean
theorem fermionEntropy_le_coeff_bound
  {m : ℕ} (λ : Fin m → ℝ)
  (h01 : ∀ i, 0 ≤ λ i ∧ λ i ≤ 1) :
  fermionEntropy Finset.univ λ ≤
    4 * Real.log 2 *
      (esymmProfile m λ 1
        - ((esymmProfile m λ 1)^2 - 2 * esymmProfile m λ 2))
```

A matrix-form version is also desirable:

```lean
theorem entropy_le_trace_gap
  {m : ℕ} (K : Matrix (Fin m) (Fin m) ℝ)
  (hPSD : PosSemidef K)
  (hSelf : K.IsSymm)
  (hSpec : ∀ μ ∈ Matrix.eigenvalues K, 0 ≤ μ ∧ μ ≤ 1) :
  subsystemEntropy K ≤ 4 * Real.log 2 * (Matrix.trace K - Matrix.trace (K ⬝ K))
```

### Why this matters
This is the first genuinely quantum-information statement: entropy is bounded by a coefficient expression that is visible to Lorentzian geometry. It gives a route from combinatorial inequalities to entanglement control.

---

## Theorem 3: A Lorentzian-ratio entropy surrogate bound

Define a coefficient-ratio surrogate from the first two nontrivial coefficients:
\[
R = \frac{e_1^2}{e_2}
\]
when `e_2 > 0`. Show that stronger pair-correlation concentration (larger/smaller ratio depending on normalization) forces entropy control. A concrete theorem that should be reachable is:

If `λ_i ∈ [0,1]`, then
\[
\sum_i \lambda_i^2 = e_1^2 - 2e_2,
\]
hence
\[
S(K_A) \le 4\log 2 \cdot \left(e_1 - e_1^2 + 2e_2\right).
\]
Using Lorentzian inequalities to bound `e_2` in terms of `e_1` and higher coefficients yields a hierarchy of entropy bounds. Prove at least the first nontrivial step in this hierarchy.

### Lean-style target
```lean
theorem entropy_le_firstSecondCoeff
  {m : ℕ} (λ : Fin m → ℝ)
  (h01 : ∀ i, 0 ≤ λ i ∧ λ i ≤ 1) :
  fermionEntropy Finset.univ λ ≤
    4 * Real.log 2 *
      ((esymmProfile m λ 1) - (esymmProfile m λ 1)^2 + 2 * esymmProfile m λ 2)
```

Then strengthen with a Lorentzian substitution theorem, for example:

```lean
theorem entropy_le_lorentzian_surrogate
  {m : ℕ} (λ : Fin m → ℝ)
  (h01 : ∀ i, 0 ≤ λ i ∧ λ i ≤ 1)
  (hLor : IsLorentzian (dppGeneratingPolynomial λ))
  {k : ℕ} (hk1 : 1 ≤ k) (hk2 : k + 1 ≤ m) :
  fermionEntropy Finset.univ λ ≤
    entropySurrogateFromCoeffRatios (esymmProfile m λ) k
```

You may define `entropySurrogateFromCoeffRatios` yourself. The key is that it must be **computable** from coefficient data and **provably bounded** using Lorentzian inequalities.

### Why this matters
This theorem creates a new practical algorithm: estimate entanglement without diagonalizing `K_A`, using only coefficient data of a generating polynomial.

---

## Theorem 4 (cross-domain theorem): Entropy bound from variance / number fluctuations

For free fermions, particle-number fluctuations in subsystem `A` satisfy
\[
\mathrm{Var}(N_A)=\operatorname{tr}(K_A - K_A^2)=\sum_i \lambda_i(1-\lambda_i).
\]
Prove a theorem linking entropy to fluctuations:
\[
S_A \le 4\log 2 \,\mathrm{Var}(N_A).
\]
Then interpret the variance as a second derivative / susceptibility of the subsystem partition function. This bridges:

- **quantum information**: entanglement entropy
- **statistical mechanics**: fluctuation susceptibility
- **algebraic combinatorics**: coefficient geometry of the DPP polynomial

### Lean-style target
```lean
theorem entropy_le_numberVariance
  {m : ℕ} (λ : Fin m → ℝ)
  (h01 : ∀ i, 0 ≤ λ i ∧ λ i ≤ 1) :
  fermionEntropy Finset.univ λ ≤
    4 * Real.log 2 * (∑ i, λ i * (1 - λ i))
```

and, if feasible,

```lean
theorem numberVariance_eq_coeff_expression
  {m : ℕ} (λ : Fin m → ℝ) :
  (∑ i, λ i * (1 - λ i)) =
    esymmProfile m λ 1 - (esymmProfile m λ 1)^2 + 2 * esymmProfile m λ 2
```

### Why this matters
This is the decisive domain bridge. It says entanglement is bounded by a thermodynamic fluctuation quantity that is itself encoded by Lorentzian polynomial structure.

---

## Most promising proof strategies

### Strategy A: Spectral-to-coefficient reduction via the catalog DPP bridge
1. Use the spectral bridge in `Pythagorean/DPPLorentzian.lean` to identify subsystem DPP coefficients with elementary symmetric polynomials in the eigenvalues of `K_A`.
2. Invoke Lorentzianity to obtain coefficient log-concavity / Alexandrov–Fenchel inequalities.
3. Convert coefficient identities into entropy bounds using elementary inequalities for binary entropy and algebraic identities involving `e₁, e₂`.

**Why promising:** This is the cleanest route because it uses the catalog’s strongest existing theorem exactly as intended: from PSD contraction kernels to Lorentzian generating polynomials.

### Strategy B: Direct spectral majorization + Newton inequalities
1. Diagonalize `K_A` (or work abstractly with eigenvalue multisets).
2. Prove Newton inequalities for the elementary symmetric profile.
3. Use Schur-concavity of entropy and moment bounds derived from `e₁, e₂`.

**Why promising:** More classical and robust if the exact Lorentzian API in the catalog is inconvenient. It still produces the target theorems, though the final narrative must explain how Lorentzianity recovers and strengthens this route.

### Strategy C: Partition-function differentiation and susceptibility
1. Define the one-parameter generating function
   \[
   Z_A(t)=\det(I-K_A+tK_A)=\prod_i (1-\lambda_i+t\lambda_i).
   \]
2. Express `e₁`, `e₂`, and variance through derivatives of `log Z_A`.
3. Use Lorentzian concavity of coefficient data to bound derivative growth, then compare with entropy.

**Why promising:** Best for the cross-domain story. It connects entanglement to thermodynamic response and may lead to future Rényi-entropy results.

**Recommended order:** Start with A for the core theorem package, use B as backup for formal proof robustness, and use C to shape the conceptual interpretation and future work.

---

## Required deep proof tactics

Your file must contain at least 3 theorems with nontrivial proofs using combinations of:

- `induction`
- `rcases`
- `by_contra`
- `field_simp`
- multi-step `calc`
- inequality chains with explicit side-condition management

Do **not** allow the development to collapse into trivial decidable computations.

Good candidates:
- proving `numberVariance_eq_coeff_expression`
- proving the entropy upper bound from `h(x) ≤ 4 log 2 * x(1-x)`
- proving coefficient ultra-log-concavity from Lorentzian hypotheses and unpacking catalog structures

---

## Suggested Lean 4 formalization targets

You should aim for a file organized around the following theorem signatures or close analogues:

```lean
def binaryEntropy (x : ℝ) : ℝ := -x * Real.log x - (1 - x) * Real.log (1 - x)

def fermionEntropy {m : ℕ} (λ : Fin m → ℝ) : ℝ :=
  ∑ i, binaryEntropy (λ i)

def subsystemVariance {m : ℕ} (λ : Fin m → ℝ) : ℝ :=
  ∑ i, λ i * (1 - λ i)

theorem binaryEntropy_le_quad
  {x : ℝ} (hx0 : 0 ≤ x) (hx1 : x ≤ 1) :
  binaryEntropy x ≤ 4 * Real.log 2 * x * (1 - x)

theorem sq_sum_eq_e1_sq_sub_two_e2
  {m : ℕ} (λ : Fin m → ℝ) :
  (∑ i, (λ i)^2) =
    (esymmProfile m λ 1)^2 - 2 * esymmProfile m λ 2

theorem subsystemVariance_eq_e1_e2
  {m : ℕ} (λ : Fin m → ℝ) :
  subsystemVariance λ =
    esymmProfile m λ 1 - (esymmProfile m λ 1)^2 + 2 * esymmProfile m λ 2

theorem entropy_le_variance
  {m : ℕ} (λ : Fin m → ℝ)
  (h01 : ∀ i, 0 ≤ λ i ∧ λ i ≤ 1) :
  fermionEntropy λ ≤ 4 * Real.log 2 * subsystemVariance λ

theorem subsystem_esymm_ultraLogConcave
  {m : ℕ} (λ : Fin m → ℝ)
  (h01 : ∀ i, 0 ≤ λ i ∧ λ i ≤ 1)
  (hLor : IsLorentzian (dppGeneratingPolynomial λ)) :
  ∀ ⦃k : ℕ⦄, 1 ≤ k → k + 1 ≤ m →
    (esymmProfile m λ k)^2 ≥
      esymmProfile m λ (k - 1) * esymmProfile m λ (k + 1)

theorem entropy_le_firstSecondCoeff
  {m : ℕ} (λ : Fin m → ℝ)
  (h01 : ∀ i, 0 ≤ λ i ∧ λ i ≤ 1) :
  fermionEntropy λ ≤
    4 * Real.log 2 *
      (esymmProfile m λ 1 - (esymmProfile m λ 1)^2 + 2 * esymmProfile m λ 2)
```

If matrix spectral machinery is mature enough in Mathlib, add matrix versions. If not, keep the spectral side abstract as functions `Fin m → ℝ` and clearly explain in the paper how they represent the eigenvalue list of `K_A`.

---

## Conjecture with testable prediction

State and investigate the following falsifiable conjecture.

### Conjecture: Lorentzian coefficient hierarchy controls entropy sharply
For every `m` and every spectrum `λ : Fin m → ℝ` with `0 ≤ λ_i ≤ 1`,
there exists a universal monotone function `Φ_m` of the normalized Lorentzian ratios
\[
\rho_k = \frac{e_k^2}{e_{k-1}e_{k+1}}
\]
such that
\[
S(\lambda) \le \Phi_m(\rho_1,\dots,\rho_{m-1}),
\]
with equality asymptotically on flat spectra `λ_i ≈ 1/2`.

### Computational test
For random PSD contractions `K` and subsystems `A` with `|A| ≤ 8`:
1. compute eigenvalues of `K_A`
2. compute `S_A`
3. compute `e_k` and ratio profile `ρ_k`
4. test candidate monotone surrogates `Φ_m`
5. search systematically for counterexamples

A single explicit family where `ρ` predicts low entropy but actual entropy is high would refute the conjecture.

You must include at least one concrete candidate formula for `Φ_m` in the experimental section of `RESEARCH_PAPER.md` and test it in `demo.py`.

---

## Cross-domain connections to emphasize

1. **Quantum information**  
   Entanglement entropy and entanglement spectrum of Gaussian/free-fermion states.

2. **Algebraic combinatorics / Hodge theory**  
   Lorentzian polynomials, ultra-log-concavity, Alexandrov–Fenchel inequalities.

3. **Determinantal probability**  
   DPP generating functions encode subsystem occupancy statistics.

4. **Statistical mechanics**  
   Number fluctuations, susceptibilities, partition functions, free-energy curvature.

5. **Matrix analysis / spectral theory**  
   PSD contractions, eigenvalue majorization, Schur-concavity.

This project becomes truly field-opening if you show that the same coefficient inequalities that govern matroids and DPPs also govern quantum entanglement constraints.

---

## Application keywords

free fermions, entanglement entropy, determinantal point processes, Lorentzian polynomials, ultra-log-concavity, Newton inequalities, particle-number fluctuations, Gaussian states, spectral majorization, Hodge-theoretic positivity, area-law heuristics, many-body quantum systems, partition functions, susceptibility bounds, combinatorial quantum information

---

## Deliverables (ALL mandatory)

You must produce all of the following:

### 1. `FUTURE_DIRECTIONS.md`
Include 3–5 original research directions. Each direction must contain:
- a sentence beginning with **“The key insight is...”**
- a sentence beginning with **“Why now?”**

At least one direction must bridge to a different domain, such as:
- interacting fermions / approximate Gaussianity
- bosonic analogues and stability obstructions
- tropical or information-geometric entropy surrogates
- holography / tensor networks / many-body complexity

### 2. `RESEARCH_PAPER.md`
A standalone scientific document. Someone reading only this paper must understand:
- the problem
- the main definitions
- the theorem statements
- the proof ideas
- why the result is new
- what experiments were run
- what to investigate next

Do not assume access to the Lean code.

### 3. `ARTICLE.md`
Write in Scientific American style.  
Explain the mathematics and significance to a broad audience.  
**Taboo:** do not focus on formal verification or theorem proving machinery. Focus on the ideas: entanglement, hidden geometric constraints, and why this connection is surprising.

### 4. Verified algorithm / computational method
Not just theorem statements. Implement a verified method that:
- computes coefficient-based entropy surrogates from a spectrum or subsystem kernel
- proves the surrogate upper bound under the formal assumptions you encode
- compares exact entropy vs. surrogate bound

### 5. `demo.py`
Interactive demonstration that:
- samples random PSD contractions with eigenvalues in `[0,1]`
- forms subsystems `A`
- computes exact free-fermion entropy
- computes `e₁`, `e₂`, and any higher Lorentzian ratio surrogates
- visualizes the bound quality
- attempts to falsify the conjecture numerically

---

## Standard of ambition

Do not be satisfied with “entropy is bounded by something spectral.” That is classical in spirit. The real target is:

> **entropy is bounded by quantities naturally extracted from Lorentzian coefficient geometry of DPP partition functions.**

If you can make that statement precise and verified, you will have created a new bridge between Hodge-theoretic combinatorics and quantum information theory. That is exactly the kind of result that changes what mathematicians think these objects are for.

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
