Soli Deo Gloria

## Assignment: Direction 4: Robust Log-Concavity for Quantum Many-Body Ground States

**Mode:** prove

Prove genuinely new theorems at the interface of **quantum many-body spectral theory, Lorentzian/strongly log-concave polynomials, and classical Markov-chain expansion**. Build explicitly on catalog perturbation tools, especially:

- `Catalog/Pythagorean/RobustLorentzianSampling.lean`
- theorem `gibbs_pointwise_ratio_bound`

The goal is not to repackage known free-fermion facts. The goal is to create a **formal bridge theorem** showing that robust Lorentzian structure of computational-basis measurement distributions encodes quantitative information about **quantum spectral gaps** and hence about **classical sampling/mixing behavior**.

This is a field-opening direction: if successful, it reframes parts of quantum many-body theory in the language of Lorentzian geometry and robust combinatorial Hodge theory.

---

## Core Vision

Let `ψ : Fin n → ℂ` be a normalized pure state in the computational basis, and let
`μ x = ‖ψ x‖^2` be its measurement distribution on bitstrings/configurations. Define the multiaffine generating polynomial
\[
P_\mu(z_1,\dots,z_n)=\sum_{S \subseteq [n]} \mu(S)\prod_{i\in S} z_i,
\]
or more generally over a finite configuration space encoded by support indicators.

For free-fermionic and determinantal states, `P_μ` is Lorentzian / strongly log-concave. The breakthrough target is to show that **robust Lorentzian curvature bounds** on `P_μ` force **classical expansion** of the measurement distribution, and that this expansion can be quantitatively inherited from a **quantum parent Hamiltonian gap** under perturbative hypotheses.

You should isolate a formally provable theorem that captures a clean version of:

> **Quantum gap ⇒ robust Lorentzian gap of measurement polynomial ⇒ classical modified log-Sobolev / Poincaré expansion ⇒ efficient certified sampling of measurement outcomes.**

Even partial versions, if sharp and formalized cleanly, would be highly significant.

---

## Precise Theorem Targets

You must formalize at least **3 substantial theorems**. At least one should be a true bridge theorem between quantum and classical structures.

### New definitions you should introduce

Define at least one genuinely new structure, for example:

```lean
structure QuantumMeasurementModel (α : Type _) [Fintype α] where
  amp        : α → ℂ
  norm_one   : ∑ x, ‖amp x‖^2 = 1
```

Define its induced probability mass function:

```lean
noncomputable def QuantumMeasurementModel.prob
    {α : Type _} [Fintype α] (M : QuantumMeasurementModel α) : α → ℝ :=
  fun x => ‖M.amp x‖^2
```

Define a robust Lorentzian certificate abstractly, since full Lorentzian machinery may be too heavy initially:

```lean
structure RobustLorentzianCertificate
    (α : Type _) [Fintype α] (μ : α → ℝ) where
  nonneg            : ∀ x, 0 ≤ μ x
  sum_one           : ∑ x, μ x = 1
  pointwise_lower   : ℝ
  pointwise_upper   : ℝ
  lower_spec        : ∀ x, pointwise_lower ≤ μ x
  upper_spec        : ∀ x, μ x ≤ pointwise_upper
  pair_log_concave  : ∀ x y, μ x * μ y ≤ pointwise_upper^2
```

You may also define a comparison object for Hamiltonians abstractly through the induced measurement law and a “gap witness”:

```lean
structure GappedMeasurementLift
    (α : Type _) [Fintype α] where
  μ                    : α → ℝ
  quantumGap           : ℝ
  lorentzianGap        : ℝ
  classicalGap         : ℝ
  quantumGap_nonneg    : 0 ≤ quantumGap
  lorentzianGap_nonneg : 0 ≤ lorentzianGap
  classicalGap_nonneg  : 0 ≤ classicalGap
  q_to_l               : quantumGap ≤ lorentzianGap
  l_to_c               : lorentzianGap ≤ classicalGap
```

This abstraction is acceptable if it enables nontrivial proved theorems and a later refinement to concrete Hamiltonians.

---

## Theorem 1: Perturbative transfer of pointwise control to measurement distributions

Build directly on `gibbs_pointwise_ratio_bound`. The theorem should say that if a measurement distribution `μ` is pointwise multiplicatively close to a Lorentzian reference distribution `ν`, then all one-site and event probabilities are comparably controlled, with constants explicit.

A Lean-style target:

```lean
theorem event_prob_ratio_bound
    {α : Type _} [Fintype α] [DecidableEq α]
    (μ ν : α → ℝ)
    (hμ : ∀ x, 0 ≤ μ x)
    (hν : ∀ x, 0 ≤ ν x)
    (hνsum : ∑ x, ν x = 1)
    (hμsum : ∑ x, μ x = 1)
    (ε : ℝ) (hε : 0 ≤ ε)
    (hratio : ∀ x, Real.exp (-ε) * ν x ≤ μ x ∧ μ x ≤ Real.exp ε * ν x)
    (s : Finset α) :
    Real.exp (-ε) * ∑ x in s, ν x ≤ ∑ x in s, μ x
      ∧ ∑ x in s, μ x ≤ Real.exp ε * ∑ x in s, ν x
```

This is not the final breakthrough, but it is the perturbative engine. Prove it with genuine summation inequalities and `calc` chains, not automation.

**Why it matters:** This theorem upgrades catalog pointwise ratio control into **observable control** for measurement events, which is the minimum interface needed to connect quantum observables to classical Lorentzian sampling statements.

---

## Theorem 2: Robust lower bound transferring a reference “Lorentzian gap” through perturbation

Define a simple abstract gap functional on finite distributions — for example, the minimum pairwise ratio, minimum singleton mass, or a certificate compatible with future Lorentzian Hessian bounds. Then prove that multiplicative perturbation preserves a polynomially degraded lower bound.

Example theorem:

```lean
noncomputable def minMass
    {α : Type _} [Fintype α] [DecidableEq α] (μ : α → ℝ) : ℝ :=
  Finset.inf' Finset.univ Finset.univ_nonempty μ

theorem minMass_perturbation_lower_bound
    {α : Type _} [Fintype α] [DecidableEq α]
    (μ ν : α → ℝ)
    (ε : ℝ) (hε : 0 ≤ ε)
    (hratio : ∀ x, Real.exp (-ε) * ν x ≤ μ x ∧ μ x ≤ Real.exp ε * ν x) :
    Real.exp (-ε) * minMass ν ≤ minMass μ
```

If `Finset.inf'` is awkward, define the gap on `Fin n` and use finite minimization more concretely.

Then strengthen this to a theorem for a new notion such as:

```lean
def pairMassGap {α : Type _} [Fintype α] [DecidableEq α] (μ : α → ℝ) : ℝ :=
  ⨅ x, ⨅ y, μ x + μ y
```

or another explicitly formalizable quantity that captures “robust anti-concentration.”

**Why it matters:** This gives a rigorous perturbative notion of a **Lorentzian gap surrogate**, suitable for current Mathlib and extensible later to actual Hessian-based Lorentzian gap definitions.

---

## Theorem 3: Cross-domain bridge theorem — quantum measurement expansion from gap-comparison hypotheses

This theorem must explicitly connect **quantum many-body data** to **classical probability / Markov / combinatorial geometry**.

A target abstraction:

```lean
theorem quantum_to_classical_gap_bridge
    {α : Type _} [Fintype α]
    (M : GappedMeasurementLift α) :
    M.quantumGap ≤ M.classicalGap
```

This alone is too trivial if proved by transitivity. So you must enrich it with content: derive a **nontrivial observable consequence**. For example:

```lean
theorem quantum_gap_controls_event_anticoncentration
    {α : Type _} [Fintype α] [DecidableEq α]
    (M : GappedMeasurementLift α)
    (s : Finset α) :
    M.quantumGap ≤ M.classicalGap ∧
    M.quantumGap ≤ (∑ x in s, M.μ x) + (∑ x in sᶜ, M.μ x)
```

Better: define a classical expansion constant of a distribution by
\[
\Phi(\mu) = \inf_{0<\mu(A)<1} \frac{\mu(\partial A)}{\mu(A)(1-\mu(A))}
\]
in a finite graph model on the configuration space, and prove a lower bound from a robust certificate plus perturbation assumptions.

A more substantive Lean target would be:

```lean
structure FiniteSpinSystem (α : Type _) [Fintype α] [DecidableEq α] where
  μ            : α → ℝ
  edge         : α → α → Prop
  symm         : Symmetric edge
  μ_nonneg     : ∀ x, 0 ≤ μ x
  μ_sum_one    : ∑ x, μ x = 1

noncomputable def boundaryMass
    {α : Type _} [Fintype α] [DecidableEq α]
    (S : FiniteSpinSystem α) (A : Finset α) : ℝ :=
  ∑ x in A, if ∃ y, S.edge x y ∧ y ∉ A then S.μ x else 0

theorem perturbative_boundaryMass_lower_bound
    {α : Type _} [Fintype α] [DecidableEq α]
    (S T : FiniteSpinSystem α)
    (ε : ℝ) (hε : 0 ≤ ε)
    (hratio : ∀ x, Real.exp (-ε) * T.μ x ≤ S.μ x ∧ S.μ x ≤ Real.exp ε * T.μ x)
    (A : Finset α) :
    Real.exp (-ε) * boundaryMass T A ≤ boundaryMass S A
```

This is a real cross-domain theorem:
- **quantum side:** `S.μ` is a measurement law of a ground state,
- **classical side:** `boundaryMass` is a graph-expansion quantity for Glauber/local moves,
- **geometric side:** the reference `T.μ` can come from a Lorentzian/determinantal model.

This theorem is a legitimate first formal bridge.

---

## Ambitious Main Conjectural Theorem

You should state, motivate, and partially formalize the following falsifiable conjecture.

### Mathematical statement
Let `H(λ)` be a finite spin Hamiltonian with unique ground state `ψ_λ`, and let `μ_λ` be the computational-basis measurement distribution of `ψ_λ`. Assume there exists a free-fermionic reference point `λ₀` with Lorentzian generating polynomial `P_{μ_{λ₀}}`, and for `|λ-λ₀| ≤ δ` one has multiplicative closeness
\[
e^{-C\delta n}\mu_{\lambda_0}(x) \le \mu_\lambda(x) \le e^{C\delta n}\mu_{\lambda_0}(x).
\]
Then there exist polynomials `p,q` such that
\[
\operatorname{LorGap}(P_{\mu_\lambda}) \ge \frac{\Delta(H(\lambda))}{p(n)}
\quad\text{and}\quad
\operatorname{Gap}_{\mathrm{Glauber}}(\mu_\lambda) \ge \frac{\Delta(H(\lambda))}{q(n)}.
\]

### Lean-facing conjectural shell
```lean
conjecture robust_lorentzian_gap_from_quantum_gap
    (n : ℕ) :
    ∃ p q : Polynomial ℝ,
      ∀ (M : GappedMeasurementLift (Fin n)),
        M.quantumGap / (p.eval n) ≤ M.lorentzianGap ∧
        M.quantumGap / (q.eval n) ≤ M.classicalGap
```

You may need to replace `Polynomial.eval n` with coercions arranged correctly; adjust as needed. The point is to state a **falsifiable quantitative conjecture**, not vague prose.

### Computational test
Use the 1D transverse-field Ising model on small `n`:
- compute exact ground state via diagonalization,
- form `μ_λ`,
- estimate a surrogate Lorentzian gap from pairwise Hessian/log-concavity inequalities or anti-concentration constants,
- compare numerically to the exact spectral gap.

A failed scaling law would refute the conjecture. This is exactly the right kind of scientific pressure.

---

## Lean 4 Type Signature Suggestions

Use concrete finite types like `Fin (2^n)` or bitstrings encoded as `Fin n → Bool` when possible.

Useful theorem signatures to target:

```lean
theorem measurement_prob_nonneg
    {α : Type _} [Fintype α]
    (M : QuantumMeasurementModel α) :
    ∀ x, 0 ≤ M.prob x
```

```lean
theorem measurement_prob_sum_one
    {α : Type _} [Fintype α]
    (M : QuantumMeasurementModel α) :
    ∑ x, M.prob x = 1
```

```lean
theorem event_prob_ratio_bound
    {α : Type _} [Fintype α] [DecidableEq α]
    (μ ν : α → ℝ)
    ...
    (s : Finset α) :
    Real.exp (-ε) * ∑ x in s, ν x ≤ ∑ x in s, μ x ∧
    ∑ x in s, μ x ≤ Real.exp ε * ∑ x in s, ν x
```

```lean
theorem boundaryMass_mono_under_pointwise_lower
    {α : Type _} [Fintype α] [DecidableEq α]
    (S T : FiniteSpinSystem α)
    (hcomp : ∀ x, T.μ x ≤ S.μ x)
    (A : Finset α) :
    boundaryMass T A ≤ boundaryMass S A
```

```lean
theorem perturbative_boundaryMass_lower_bound
    {α : Type _} [Fintype α] [DecidableEq α]
    (S T : FiniteSpinSystem α)
    (ε : ℝ) (hε : 0 ≤ ε)
    (hratio : ∀ x, Real.exp (-ε) * T.μ x ≤ S.μ x ∧ S.μ x ≤ Real.exp ε * T.μ x)
    (A : Finset α) :
    Real.exp (-ε) * boundaryMass T A ≤ boundaryMass S A
```

```lean
theorem minMass_perturbation_lower_bound
    {α : Type _} [Fintype α] [DecidableEq α]
    (μ ν : α → ℝ)
    (ε : ℝ) (hε : 0 ≤ ε)
    (hratio : ∀ x, Real.exp (-ε) * ν x ≤ μ x ∧ μ x ≤ Real.exp ε * ν x) :
    Real.exp (-ε) * minMass ν ≤ minMass μ
```

If you can formalize an actual generating polynomial over finite subsets, even better. For example, define support-indexed multiaffine polynomials in `MvPolynomial` and prove coefficient nonnegativity / normalization / perturbative coefficient comparison.

---

## Proof Strategy Architecture

You must not rely on trivial tactics. At least 3 theorems must use deep tactics such as `induction`, `rcases`, `by_contra`, `field_simp`, or multi-step `calc`.

### Strategy A: Perturbative transport via catalog inequalities
1. Import `gibbs_pointwise_ratio_bound` and specialize it from Gibbs weights to finite measurement laws.
2. Sum pointwise inequalities over events / boundaries / local observables.
3. Use `calc` chains and positivity lemmas to transfer lower bounds on gap surrogates from a Lorentzian reference model to a perturbed quantum measurement law.

**Why promising:** This is the fastest path to rigorous new theorems with explicit constants, and it directly exploits vetted catalog infrastructure.

### Strategy B: Build an abstract expansion theory for finite measurement distributions
1. Define `FiniteSpinSystem`, `boundaryMass`, and one or two expansion/gap surrogates.
2. Prove monotonicity and perturbation-stability theorems for these surrogates.
3. Package the bridge as “if the reference distribution is Lorentzian and has expansion certificate `c`, then any multiplicatively close quantum measurement law inherits expansion `e^{-ε} c`.”

**Why promising:** This creates reusable formal architecture. Even if full Lorentzian Hessian theory is premature, the expansion layer is mathematically meaningful and extendable.

### Strategy C: Multiaffine generating polynomial route
1. Define the generating polynomial of a finite measurement law using `MvPolynomial`.
2. Prove coefficientwise perturbation bounds from multiplicative closeness of distributions.
3. Derive surrogate Lorentzian inequalities for low-order derivatives or coefficient ratios.

**Why promising but harder:** This is closest to the ultimate conjecture, but may require more algebraic infrastructure. It is ideal if you can get at least one nontrivial Hessian/coefficient theorem.

**Recommended path:** Start with A + B to secure substantial theorems, then add a C-style theorem if time permits. The combination gives both rigor and conceptual reach.

---

## Cross-Domain Connections You Must Make Explicit

At least one theorem and the paper narrative must emphasize these bridges:

1. **Quantum many-body physics ↔ Lorentzian/strongly log-concave polynomials**  
   Measurement amplitudes of ground states induce classical distributions whose generating polynomials may encode curvature/exchange properties.

2. **Spectral graph theory / Markov chains ↔ quantum spectral gaps**  
   The parent Hamiltonian gap should be treated as a source of lower bounds for classical expansion or anti-concentration after measurement.

3. **Combinatorial Hodge theory ↔ classical simulation of quantum systems**  
   Lorentzian structure suggests negative dependence, entropy decay, and efficient approximate sampling.

4. **Free-fermion integrability ↔ perturbative many-body robustness**  
   Determinantal reference points give exact solvable anchors; the real science is proving what survives away from integrability.

5. **Statistical mechanics ↔ computational complexity**  
   If measurement distributions near integrable points retain expansion, this may delineate a tractable regime for classical simulation.

---

## Application Keywords

Include these explicitly in your deliverables:

- quantum many-body systems
- transverse-field Ising model
- free fermions
- matchgate circuits
- Lorentzian polynomials
- strong log-concavity
- spectral gap
- Glauber dynamics
- anti-concentration
- negative dependence
- perturbation stability
- classical simulation
- combinatorial Hodge theory
- determinantal processes
- quantum-to-classical correspondence

---

## Concrete Deliverables

You must produce **all** of the following.

### 1. Lean file with substantial proofs
Requirements:
- At least **3 nontrivial theorems**
- At least **1 new definition/structure**
- At least **1 cross-domain theorem**
- Minimal `sorry`
- No fake depth via `native_decide`, `decide`, `norm_num`, or `rfl` unless mathematically justified

### 2. Verified algorithm / computational method
Implement a verified or semi-verified computational method that computes a **surrogate Lorentzian gap** or **event/boundary anti-concentration certificate** from a finite distribution.

Examples:
- compute minimum singleton/event mass under perturbation bounds,
- compute boundary mass for local-move graphs,
- estimate a finite-difference log-concavity certificate for a measurement law.

The algorithm must be tied to a theorem proving its correctness or lower-bound guarantee.

### 3. `demo.py`
Create an interactive script that:
- constructs small transverse-field Ising instances,
- diagonalizes the Hamiltonian numerically,
- extracts ground-state measurement probabilities,
- computes your surrogate Lorentzian / expansion certificate,
- plots certificate vs. quantum spectral gap as field strength varies.

This demo should visibly test the conjectural scaling law.

### 4. `RESEARCH_PAPER.md`
A standalone scientific document explaining:
- the mathematical problem,
- the formal definitions,
- the main theorems,
- why the connection is new,
- what the computational evidence suggests,
- what stronger future theorem should be pursued next.

It must be readable with **no access to the code**.

### 5. `ARTICLE.md`
Write this in **Scientific American style**:
- vivid and accessible,
- explain why “the shape of a quantum wavefunction, viewed through measurement probabilities, may secretly obey a geometry that controls simulation and stability,”
- do **not** focus on theorem proving infrastructure or formal verification machinery.

### 6. `FUTURE_DIRECTIONS.md`
Include **3–5 original research directions**, each with:
- **“The key insight is…”**
- **“Why now?”**

At least one must bridge to a different domain, such as:
- quantum LDPC codes,
- tensor networks,
- tropical geometry,
- non-Hermitian physics,
- complexity theory,
- optimal transport on configuration spaces.

Possible examples:
- Lorentzian geometry of tensor-network boundary states
- Entropic area laws from strong log-concavity
- Negative dependence as a classical shadow of quantum frustration-freeness
- Tropical approximations to many-body generating polynomials
- Complexity thresholds for classical simulation near integrable manifolds

---

## Revolutionary Significance

If you can prove even a robust surrogate of the target bridge, you will have created a new language for discussing quantum many-body structure:

- **Physics:** a new invariant of ground states via measurement polynomial geometry.
- **Probability:** a new source of strongly log-concave measures arising from quantum systems.
- **Algorithms:** a route to certified classical simulation near free-fermionic points.
- **Mathematics:** a concrete bridge from Lorentzian polynomials and combinatorial Hodge theory to spectral questions in quantum Hamiltonians.

This is not an incremental extension. It is the opening move of a new subject: **Lorentzian quantum statistical geometry**.

Be bold, but make every theorem precise, finite, and Lean-realizable.

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
