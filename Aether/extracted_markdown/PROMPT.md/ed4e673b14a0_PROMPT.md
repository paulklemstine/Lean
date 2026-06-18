## Assignment: Characterize

Prove a genuinely new theorem that turns the informal “thermodynamics of stopping times” into a rigorous Lean 4 framework, with a sharp phase-transition statement for a partition function built from truncated stopping-time observables. This should not be a metaphorical analogy: the goal is a certified theorem identifying convexity, differentiability, and singularity structure of a finite-volume free energy, and then isolating a mechanism by which non-smoothness arises from arithmetic coexistence of two stopping-time regimes.

Minimize sorry. Build on catalog theorems where they give coercive lower/upper bounds or multiplicative control.

## Mode
prove

## Research Direction
Create a formal thermodynamic theory for arithmetic stopping-time systems. The central object is a partition function
\[
Z_N(\theta) := \sum_{n=1}^N e^{-\theta \,\tau(n)},
\]
where \(\tau(n)\) is a stopping-time-type observable on integers, or more generally
\[
Z_N(\theta) := \sum_{n=1}^N w(n)\, e^{-\theta \,\tau(n)}
\]
with nonnegative arithmetic weights \(w(n)\).

The breakthrough target is to prove that finite-volume free energies are always convex and admit one-sided derivative formulas, and then to isolate a precise sufficient criterion under which a limiting free energy develops a first-order singularity from phase coexistence. This creates a formal bridge between:
- arithmetic dynamics of Syracuse/Collatz-type maps,
- statistical mechanics of free energy and phase transitions,
- large deviations / moderate deviations,
- Yang–Lee style complex zero heuristics.

This would open an entirely new field: arithmetic thermodynamics of discrete dynamical observables.

## Precise Theorem Target

Work first in a general finite-volume setting where the theorem is unconditional and fully formalizable.

Let \(α\) be a finite index type, \(τ : α \to \mathbb{R}\), \(w : α \to \mathbb{R}_{\ge 0}\), and define
\[
Z(\theta) := \sum_{a \in α} w(a)\, e^{-\theta τ(a)}.
\]
Assume \(Z(\theta) > 0\) for all \(\theta\). Define free energy
\[
F(\theta) := \log Z(\theta).
\]

### Main theorem
Prove that:
1. \(F\) is convex on \(\mathbb{R}\).
2. \(F\) is \(C^\infty\) in finite volume.
3. Its first derivative is the negative Gibbs expectation of \(τ\):
   \[
   F'(\theta)= - \frac{\sum_a w(a)\,τ(a)e^{-\theta τ(a)}}{Z(\theta)}.
   \]
4. Its second derivative is the Gibbs variance of \(τ\):
   \[
   F''(\theta)=
   \frac{\sum_a w(a)\,τ(a)^2e^{-\theta τ(a)}}{Z(\theta)}
   -
   \left(
   \frac{\sum_a w(a)\,τ(a)e^{-\theta τ(a)}}{Z(\theta)}
   \right)^2
   \ge 0.
   \]
5. If the support of \(w\) contains at least two points with distinct \(τ\)-values, then \(F''(\theta) > 0\) for some \(\theta\), hence strict convexity is nontrivial.

This is already a strong theorem: it certifies that “specific heat” in the arithmetic model is literally a variance observable.

### Lean 4 type signature target
A realistic Mathlib-facing statement is:

```lean
theorem logSumExp_convex_and_second_derivative_eq_variance
    {ι : Type*} [Fintype ι] [DecidableEq ι]
    (w : ι → ℝ≥0)
    (τ : ι → ℝ) :
    let Z : ℝ → ℝ := fun θ =>
      ∑ i, ((w i : ℝ) * Real.exp (-θ * τ i))
    let F : ℝ → ℝ := fun θ => Real.log (Z θ)
    (∀ θ : ℝ, 0 < Z θ) →
    ConvexOn ℝ (Set.univ) F ∧
    (∀ θ : ℝ,
      HasDerivAt F
        (-(∑ i, ((w i : ℝ) * τ i * Real.exp (-θ * τ i))) / (Z θ)) θ) ∧
    (∀ θ : ℝ,
      deriv (deriv F) θ =
        ((∑ i, ((w i : ℝ) * (τ i)^2 * Real.exp (-θ * τ i))) / (Z θ))
        - (((∑ i, ((w i : ℝ) * τ i * Real.exp (-θ * τ i))) / (Z θ))^2)) ∧
    (∀ θ : ℝ, 0 ≤ deriv (deriv F) θ)
```

You may want to split this into 3–5 lemmas:
- positivity of `Z`,
- derivative of `Z`,
- derivative of `Real.log ∘ Z`,
- second derivative formula,
- convexity from nonnegative second derivative.

## Breakthrough Extension Theorem
Once the finite-volume theorem is complete, prove a phase-coexistence criterion for a limit of two competing exponential sectors.

Suppose sequences \(A_N(\theta), B_N(\theta) > 0\) satisfy
\[
Z_N(\theta)=A_N(\theta)+B_N(\theta),
\]
and there exist continuous functions \(a,b : I \to \mathbb{R}\) on an interval \(I\) such that
\[
\frac1N \log A_N(\theta)\to a(\theta), \qquad
\frac1N \log B_N(\theta)\to b(\theta)
\]
locally uniformly on \(I\). Then
\[
\frac1N \log Z_N(\theta)\to \max(a(\theta),b(\theta))
\]
locally uniformly on \(I\). In particular, if \(a(\theta_*)=b(\theta_*)\) but \(a'(\theta_*)\neq b'(\theta_*)\), then the limit free energy is not differentiable at \(\theta_*\): a first-order phase transition.

This theorem is mathematically clean, highly reusable, and exactly captures “coexistence of two phases of stopping-time behavior.”

### Lean 4 type signature target
A plausible formal target:

```lean
theorem logsum_two_phase_limit
    {I : Set ℝ}
    (hI : IsOpen I)
    (A B : ℕ → ℝ → ℝ)
    (a b : ℝ → ℝ)
    (hposA : ∀ N θ, θ ∈ I → 0 < A N θ)
    (hposB : ∀ N θ, θ ∈ I → 0 < B N θ)
    (ha :
      TendstoLocallyUniformlyOn
        (fun N θ => (1 / (N : ℝ)) * Real.log (A N θ)) a atTop I)
    (hb :
      TendstoLocallyUniformlyOn
        (fun N θ => (1 / (N : ℝ)) * Real.log (B N θ)) b atTop I) :
    TendstoLocallyUniformlyOn
      (fun N θ => (1 / (N : ℝ)) * Real.log (A N θ + B N θ))
      (fun θ => max (a θ) (b θ)) atTop I
```

If `TendstoLocallyUniformlyOn` is too heavy, formalize a compact-set version first.

## Arithmetic Specialization
After the abstract theorem, instantiate it for a truncated stopping-time partition function
\[
Z_N(\theta)=\sum_{n=1}^N e^{-\theta \tau_N(n)},
\]
where `τ_N` is any bounded truncation of an arithmetic stopping-time observable. This avoids dependence on unproved Collatz facts while still creating the formal infrastructure needed for future arithmetic thermodynamics.

A strong specialization is:
- define a finite set of integers `Fin N`,
- define any observable `τ : Fin N → ℝ`,
- show the free-energy identities above;
- then identify two subsets \(S_N^{(1)}, S_N^{(2)}\) whose contributions dominate in different \(\theta\)-ranges.

This gives a theorem schema for later Syracuse instantiation.

## Proof Strategy A: Finite-volume calculus via log-sum-exp
Most promising for a complete Lean theorem.

1. Define
   \[
   Z(\theta)=\sum_i w_i e^{-\theta τ_i}.
   \]
   Prove positivity using `Finset.sum_pos` from any nonzero support hypothesis or assume positivity directly.
2. Differentiate termwise using standard derivative lemmas for `Real.exp` and finite sums:
   \[
   Z'(\theta)= -\sum_i w_i τ_i e^{-\theta τ_i}.
   \]
3. Apply derivative of `Real.log`:
   \[
   F' = Z'/Z.
   \]
   Differentiate once more and simplify to the variance formula. Conclude convexity from `F'' ≥ 0`.

Why this is best: it is local, finite, exact, and uses standard Mathlib analysis rather than asymptotic machinery.

## Proof Strategy B: Hölder/Jensen route to convexity
Elegant and conceptually thermodynamic.

1. For \(\theta_1,\theta_2\in\mathbb R\) and \(t\in[0,1]\), write
   \[
   Z(t\theta_1+(1-t)\theta_2)
   = \sum_i w_i \big(e^{-\theta_1\tau_i}\big)^t \big(e^{-\theta_2\tau_i}\big)^{1-t}.
   \]
2. Apply Hölder or weighted AM-GM to obtain
   \[
   Z(t\theta_1+(1-t)\theta_2)\le Z(\theta_1)^t Z(\theta_2)^{1-t}.
   \]
3. Take logs to get convexity of \(F=\log Z\).

Why useful: this avoids second derivatives for the convexity portion and gives a structural theorem recognizable as the discrete Laplace-transform convexity principle.

## Proof Strategy C: Asymptotic two-phase principle
Best for the breakthrough phase-transition theorem.

1. Write
   \[
   \frac1N\log(A_N+B_N)
   = \max\!\left(\frac1N\log A_N,\frac1N\log B_N\right)
     + \frac1N\log\!\left(1+e^{-N|\Delta_N|}\right),
   \]
   where \(\Delta_N=(1/N)\log A_N-(1/N)\log B_N\).
2. Bound the correction term uniformly:
   \[
   0 \le \frac1N\log(1+e^{-N|\Delta_N|}) \le \frac{\log 2}{N}.
   \]
3. Pass to the limit and identify the singularity of `max a b` when slopes disagree at a crossing.

Why powerful: this is the exact arithmetic analogue of finite-volume phase coexistence in statistical mechanics.

## How to Build on Existing Verified Theorems
Use the catalog theorems as scaffolding, even if they are from neighboring domains.

1. `partition_function_bound`  
   Use this as a model for proving positivity/coercive estimates for your arithmetic partition sums. Even if the theorem lives in a different namespace, mirror its proof architecture for finite partition-function control.

2. `canonicalCode_partition_lower_bound`  
   This is conceptually important: it already treats partition functions tied to arithmetic/combinatorial structure. Reuse its lower-bound style to ensure `Real.log` is legal and to establish non-vanishing sectors in two-phase decompositions.

3. `diagonal_phase_transition_incompleteness_weak`  
   Even if its semantics differ, it is a signal that the codebase already tolerates “phase transition” formal objects. Build a cleaner theorem that upgrades heuristic phase-transition language into a precise non-differentiability statement of a limiting free energy.

4. `complex_norm_sq_multiplicative`  
   This becomes relevant if you push toward Yang–Lee zeros: it supplies a certified multiplicative identity in `ℂ`, useful when controlling norms of products or polynomial partition functions after analytic continuation.

5. `lattice_key_bound`  
   Potentially useful as a template for arithmetic-growth bounds if you need to control weighted sums by exponential envelopes.

## Cross-Domain Connections
This project should explicitly connect at least four areas.

### 1. Statistical mechanics
The identities
\[
F'(\theta) = -\mathbb E_\theta[\tau], \qquad
F''(\theta)=\mathrm{Var}_\theta(\tau)
\]
make \(\theta\) a true inverse-temperature parameter and \(\tau\) an energy observable. First-order transitions become slope jumps; second-order transitions become divergence or anomalous growth of variance/susceptibility.

### 2. Large deviations and moderate deviations
If later one proves
\[
\frac1N \log Z_N(\theta) \to \Lambda(\theta),
\]
then \(\Lambda\) is a cumulant-generating/free-energy function. Differentiability controls law-of-large-numbers behavior; quadratic expansion near a regular point gives CLT/moderate deviation corrections.

### 3. Arithmetic dynamics
For Syracuse-like maps, parity branching creates natural competing sectors. The theorem gives a rigorous vocabulary for saying that two orbit-statistics populations coexist and exchange dominance as \(\theta\) varies.

### 4. Yang–Lee theory
Once \(Z_N(\theta)\) is formalized over `ℂ`,
\[
Z_N(z)=\sum_{n=1}^N e^{-z\tau(n)},
\]
zeros in the complex \(z\)-plane become an arithmetic partition-zero set. Accumulation of zeros near the real axis would be the arithmetic analogue of Yang–Lee edge singularities.

## Concrete Lean decomposition
A high-probability implementation plan:

1. `arith_partition_function_pos`
2. `arith_partition_function_hasDerivAt`
3. `arith_free_energy_hasDerivAt`
4. `arith_free_energy_second_deriv_eq_variance`
5. `arith_free_energy_convex`
6. `two_phase_logsum_limit_max`
7. `two_phase_nondifferentiable_at_crossing`

If time permits, add:
8. `complex_arith_partition_entire` for finite sums over `ℂ`.

## Stronger Optional Theorem: analytic continuation and zero symmetry
For finite sums with bounded real `τ`, prove that
\[
z \mapsto \sum_i w_i e^{-z\tau_i}
\]
is entire. Then study the zero set for simple two-level models:
\[
Z(z)=a e^{-α z}+b e^{-β z}.
\]
Its zeros are explicit:
\[
z_k = \frac{\log(-b/a)+2\pi i k}{α-β}.
\]
This is a toy Yang–Lee arithmetic theorem and could become the first formally verified statement about partition zeros in an arithmetic thermodynamic model.

A Lean target could be modest:
```lean
theorem two_level_partition_zero_classification
    {a b α β : ℂ}
    (hab : a ≠ 0 ∧ b ≠ 0)
    (hαβ : α ≠ β) :
    {z : ℂ | a * Complex.exp (-α * z) + b * Complex.exp (-β * z) = 0}
    = {z : ℂ | Complex.exp ((β - α) * z) = -b / a}
```
This is already a meaningful bridge theorem.

## Why this is revolutionary
This would formalize a new dictionary:
- arithmetic stopping times ↔ energies,
- truncated orbit ensembles ↔ Gibbs ensembles,
- free-energy singularities ↔ arithmetic phase transitions,
- variance blowup ↔ critical slowing down,
- complex partition zeros ↔ arithmetic Yang–Lee theory.

It opens a field where one can ask, in Lean-certified form:
- Do Syracuse statistics admit a genuine thermodynamic limit?
- Is there a rigorously defined arithmetic susceptibility?
- Can one prove a large-deviation principle for orbit observables?
- Do arithmetic partition zeros approach the real axis?

That is not an incremental extension. It is a new research program.

## Application keywords
arithmetic thermodynamics, free energy, phase transition, stopping time, Syracuse dynamics, Collatz-type maps, Gibbs measure, convexity, variance identity, susceptibility, large deviations, moderate deviations, central limit correction, Yang–Lee zeros, analytic continuation, partition function, arithmetic dynamics, statistical mechanics, complex zeros, formalized mathematics, Lean 4, Mathlib

## Deliverables
1. Formal Lean theorem(s) for finite-volume free energy convexity and derivative/variance identities.
2. A formal two-phase asymptotic theorem showing convergence to `max`.
3. A corollary giving non-differentiability at a crossing with unequal slopes.
4. If feasible, a finite complex-analytic partition-zero theorem.

## Mandatory final step
Produce `FUTURE_DIRECTIONS.md` with 3–5 concrete breakthrough next steps. These must be specific and ambitious, for example:
- a thermodynamic limit theorem for a Syracuse-derived observable under explicit probabilistic hypotheses;
- a Gärtner–Ellis style large deviation theorem for arithmetic stopping-time ensembles;
- a Yang–Lee zero accumulation theorem for two-scale arithmetic partition functions;
- a second-order transition theorem where normalized variance diverges;
- a formal Legendre-duality framework connecting arithmetic entropy and free energy.

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
DELIVERABLE 4 — Python Code: Demos, Visualizations, Algorithms
────────────────────────────────────────────────────────────────────────────
- **demo.py** — Working Python code demonstrating the theorems with
  concrete numerical examples. Make the math tangible.
- **visualizations** — matplotlib / plotly charts showing key mathematical
  structures, convergence behavior, phase diagrams, etc.
  Save figures as PNG/SVG files for inclusion in the HTML package.
- **algorithms.py** — Implement any algorithms from the research paper.
  Include docstrings, type hints, and example usage.
- **applications.py** — Code showing real-world applications of the results.
  If the math applies to ML, crypto, physics — show it working.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 5 — FUTURE_DIRECTIONS.md  (MANDATORY — drives next cycle)
────────────────────────────────────────────────────────────────────────────
The MOST IMPORTANT deliverable. Structured roadmap of breakthrough
research opportunities opened by this work. See detailed spec below.

**Team Directive**: Create a team to conduct research, brainstorm hypotheses,
run experiments, validate data, update knowledge base and iterate forever.
Each future direction should be specific enough for a team to pick up and
pursue with clear hypotheses, proof strategies, and cross-domain connections.

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
    "visualizations": [ { "name": "...", "data": "base64 encoded URI or inline SVG string" } ],
    "lean_proofs": "Raw lean code..."
  }
• **String Encoding**: Ensure all Markdown and code is properly JSON-escaped (e.g. `
` for newlines).
• **Embedded images**: ALL images (charts, diagrams, visualizations) MUST be
  embedded directly in the JSON. If you generate matplotlib/plotly figures, convert them to base64
  data URIs (e.g., `data:image/png;base64,...`). For SVG diagrams, put the raw `<svg>...</svg>`
  string into the `data` field. NEVER reference external image files.
• **Complete**: Include ALL content from the article, research paper, and code. This JSON file
  is the sole data source for the frontend web application.

────────────────────────────────────────────────────────────────────────────

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real, useful, and
beautiful. Every deliverable should be something you'd be proud to show.

Research domain: EML
Research mode: prove
