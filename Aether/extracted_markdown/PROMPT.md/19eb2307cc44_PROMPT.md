Soli Deo Gloria

## Assignment: Direction 1: Harmonic-Sector Factorization and the Tropical Partition Function

**Mode:** `prove`

Prove genuinely new, non-trivial theorems formalizing a **sector decomposition of the periodic Gaussian free field on a connected metric graph** and identifying its harmonic factor with the **tropical Jacobian covolume**. This is not just a refinement of graph Laplacian folklore: it is a blueprint for turning tropical Jacobians into **physically measurable partition-function invariants**.

Your target is to make precise — and prove in Lean 4 using Mathlib and the cited catalog — the principle that a periodic bosonic field on a metric graph splits into:

1. a **massive/pinned fluctuation sector** controlled by the reduced Laplacian determinant, and  
2. a **harmonic winding sector** controlled by the covolume of the canonical kernel lattice.

If completed cleanly, this opens a new bridge between **tropical geometry, statistical mechanics, spectral graph theory, and arithmetic lattice invariants**.

---

## Central Breakthrough Theorem

Let `Γ` be a connected weighted graph modeling a metric graph, with vertex set `V`, weighted Laplacian `L`, reduced Laplacian `L_red`, first Betti number `g`, and canonical harmonic/kernel lattice `Λ_Γ`. Define the periodic partition function by integrating the Gaussian energy over the torus obtained by quotienting by the appropriate periodicity lattice.

### Precise mathematical target

Prove a theorem of the following shape:

\[
\forall \Gamma,\ \mathrm{Connected}(\Gamma) \to
Z_{\mathrm{periodic}}(\Gamma)
=
Z_{\mathrm{pin}}(\Gamma)\cdot Z_{\mathrm{harm}}(\Lambda_\Gamma),
\]
with
\[
Z_{\mathrm{pin}}(\Gamma)=\frac{(2\pi)^{(n-1)/2}}{\sqrt{\det L_{\mathrm{red}}}},
\qquad
Z_{\mathrm{harm}}(\Lambda_\Gamma)=\operatorname{covol}(\Lambda_\Gamma).
\]

The mathematical novelty is not the Gaussian integral alone. The breakthrough is the identification of the **global topological sector** of the field theory with the **tropical Jacobian torus**, thereby making a tropical moduli invariant appear as an exact thermodynamic factor.

---

## Lean 4 formalization target

You should introduce a new structure encoding the sector factorization data. For example:

```lean
structure HarmonicSectorData (V : Type _) [Fintype V] [DecidableEq V] where
  L        : Matrix V V ℝ
  connected : Prop
  row_sum_zero : ∀ i, ∑ j, L i j = 0
  psd      : 0 ≤ quadraticFormOfMatrix L
  kernelLattice : Submodule ℤ (V → ℝ)
  genus    : ℕ
```

Then define the pinned and harmonic factors abstractly:

```lean
noncomputable def ZPin
    {V : Type _} [Fintype V] [DecidableEq V]
    (Γ : HarmonicSectorData V) : ℝ := ...

noncomputable def ZHarm
    {V : Type _} [Fintype V] [DecidableEq V]
    (Γ : HarmonicSectorData V) : ℝ := ...

noncomputable def ZPeriodic
    {V : Type _} [Fintype V] [DecidableEq V]
    (Γ : HarmonicSectorData V) : ℝ := ...
```

### Main theorem signature to aim for

```lean
theorem periodic_partition_factorization
    {V : Type _} [Fintype V] [DecidableEq V]
    (Γ : HarmonicSectorData V) :
    ZPeriodic Γ = ZPin Γ * ZHarm Γ := by
  ...
```

If full measure-theoretic Gaussian integration is too heavy in one cycle, prove a mathematically sharp finite-dimensional surrogate theorem that still captures the factorization:

```lean
theorem periodic_partition_factorization_finite_dimensional
    {V : Type _} [Fintype V] [DecidableEq V]
    (Γ : HarmonicSectorData V) :
    gaussianFundamentalDomainIntegral Γ.L
      =
    pinnedGaussianPrefactor Γ.L * latticeCovolume Γ.kernelLattice := by
  ...
```

A second core theorem should isolate invariance under subdivision / model change:

```lean
theorem harmonic_factor_invariant_under_subdivision
    {V W : Type _} [Fintype V] [DecidableEq V] [Fintype W] [DecidableEq W]
    (Γ₁ : HarmonicSectorData V) (Γ₂ : HarmonicSectorData W)
    (hmodel : MetricGraphEquivalent Γ₁ Γ₂) :
    ZHarm Γ₁ = ZHarm Γ₂ := by
  ...
```

And a third theorem should connect to a different domain — physics or arithmetic:

```lean
theorem free_energy_splits_into_complexity_plus_topology
    {V : Type _} [Fintype V] [DecidableEq V]
    (Γ : HarmonicSectorData V) :
    Real.log (ZPeriodic Γ)
      = Real.log (ZPin Γ) + Real.log (ZHarm Γ) := by
  ...
```

under positivity hypotheses. This is conceptually important: **free energy = combinatorial complexity term + topological/harmonic term**.

---

## Why this would be a breakthrough

This would establish the first exact formal bridge between:

- **Gaussian free fields on graphs**  
- **matrix-tree / reduced Laplacian determinants**  
- **harmonic cycle spaces and tropical Jacobians**  
- **thermodynamic free energies of topological sectors**

The point is not merely that the partition function “can be computed.” The point is that the computation **factorizes canonically into geometry and combinatorics**. That creates a new research program: tropical geometry becomes a language for exact sector decomposition in statistical mechanics.

This could seed follow-on work in:

- tropical quantum field theory,
- topological phases on discrete networks,
- graph-based bosonic path integrals,
- arithmetic of Jacobians via partition functions,
- inverse problems: recover tropical moduli from thermodynamic observables.

---

## Required new definitions

You must define at least one genuinely new concept absent from the catalog. Suggested options:

### 1. Harmonic-sector factorization witness
A structure asserting that a Laplacian-compatible periodic Gaussian model decomposes orthogonally into pinned and harmonic sectors with multiplicative partition function.

```lean
structure HasHarmonicSectorFactorization
    {V : Type _} [Fintype V] [DecidableEq V]
    (L : Matrix V V ℝ) where
  pinnedSubspace   : Submodule ℝ (V → ℝ)
  harmonicSubspace : Submodule ℝ (V → ℝ)
  direct_sum       : ...
  orthogonal       : ...
  lattice          : Submodule ℤ (V → ℝ)
  factorization    : ...
```

### 2. Tropical partition factor
A scalar extracted from the kernel lattice, intended to coincide with tropical Jacobian covolume.

```lean
noncomputable def tropicalPartitionFactor (...) : ℝ := ...
```

### 3. Subdivision invariance relation
A notion of equivalence between weighted graph models representing the same metric graph.

Any of these would satisfy the novelty requirement if implemented seriously.

---

## Build explicitly on catalog theorems

Use the following as certified entry points, and explain in code comments how each is used:

1. `Catalog/Pythagorean/TropicalBridge/MetricKernel/Theorems.lean`
   - `weightedLaplacian_psd`
     - Use this to justify positivity/nonnegativity of the quadratic form on the fluctuation sector.
   - `weightedLaplacian_row_sum_zero`
     - Use this to identify constant functions as lying in the kernel and to start the decomposition into kernel vs orthogonal complement.

2. `Catalog/Pythagorean/TropicalBridge/GaussianFreeField.lean`
   - `pinnedGFF_partition_prefactor_pos`
     - Use this as the positivity input needed for logarithms, multiplicative splitting, and any normalization theorem.
   - `graphGFFEnergy_add_const`
     - Use this to prove gauge invariance / constant-shift invariance of the energy, which is the mechanism forcing a harmonic or zero-mode sector.

3. `Catalog/Bridges/Catalog/Pythagorean/TropicalBridge/CanonicalKernelTheorems.lean`
   - `harmonicKernel`
     - Use this to connect the kernel/harmonic sector to the canonical tropical object rather than treating it as a bare linear algebra artifact.

Do not merely cite these. Build a theorem dependency chain from them.

---

## Three theorem targets minimum

Your file must contain at least 3 substantial theorems. Here is a recommended trio.

### Theorem A: constant-shift invariance induces kernel reduction
Prove that the GFF energy descends to the quotient by constants and therefore depends only on the pinned sector.

Possible signature:
```lean
theorem energy_descends_to_pinned_quotient
    {V : Type _} [Fintype V] [DecidableEq V]
    (Γ : HarmonicSectorData V) (φ c : V → ℝ) :
    gffEnergy Γ.L (φ + fun _ => c default) = gffEnergy Γ.L φ := by
  ...
```

This theorem should use `graphGFFEnergy_add_const` and nontrivial quotient/decomposition reasoning.

### Theorem B: factorization of periodic partition function
The central theorem above.

### Theorem C: invariance of harmonic factor under metric-graph model equivalence
Formalize that the harmonic contribution depends only on the metric graph / tropical Jacobian, not on arbitrary vertex subdivision.

This is the theorem that makes the result geometric rather than presentation-dependent.

### Optional Theorem D: free-energy decomposition
\[
-\log Z_{\mathrm{periodic}}
=
-\log Z_{\mathrm{pin}} - \log Z_{\mathrm{harm}}.
\]
This connects directly to statistical mechanics.

---

## Proof strategy architecture

You must pursue at least 2–3 proof routes in comments or notes, even if one becomes primary.

### Strategy A: Orthogonal decomposition + Gaussian integral factorization
**Most promising.**

1. Use `weightedLaplacian_row_sum_zero` and connectivity to identify the constant/kernel direction.
2. Decompose the ambient field space into
   \[
   (\ker L)^\perp \oplus \ker L.
   \]
3. Show the quadratic form is strictly positive on the pinned sector using `weightedLaplacian_psd` plus a kernel characterization.
4. Factor the Gaussian integral over a product fundamental domain:
   pinned Gaussian integral × harmonic lattice covolume.

Why this is most promising: it mirrors the analytic physics argument while staying close to linear algebra and finite-dimensional integration, which is formalization-friendly.

### Strategy B: Quotient-first approach via gauge reduction
1. Define the field theory directly on the quotient space of configurations modulo constants.
2. Prove the induced quadratic form is positive definite.
3. Identify the quotient lattice with the harmonic/kernel lattice using `harmonicKernel`.
4. Compute the partition function on the quotient and lift back.

Why useful: avoids carrying an explicit zero mode and may produce cleaner Lean statements about reduced Laplacians.

### Strategy C: Determinantal / lattice comparison approach
1. Express both sides in terms of Gram determinants of complementary lattices.
2. Prove a determinant-covolume identity comparing reduced Laplacian determinant with harmonic lattice covolume.
3. Deduce factorization from a purely algebraic identity.

Why interesting: this route could reveal an arithmetic interpretation and may generalize to discrete Hodge theory or higher-dimensional cell complexes.

---

## Cross-domain connections you must explicitly develop

At least one theorem and the surrounding narrative must connect this project to another domain.

### Connection 1: Statistical mechanics
Interpret
\[
F(\Gamma) = -\log Z_{\mathrm{periodic}}(\Gamma)
\]
as free energy, with additive decomposition into fluctuation entropy and topological sector entropy.

### Connection 2: Tropical geometry
Interpret `ZHarm` as the volume/covolume of the tropical Jacobian torus. This turns a tropical moduli invariant into a thermodynamic observable.

### Connection 3: Arithmetic / complexity
Using the matrix-tree flavor of `det L_red`, connect the pinned sector to weighted spanning-tree complexity. Then the total partition function simultaneously measures:
- combinatorial complexity (`det L_red`),
- topological geometry (`covol Λ_Γ`).

This is a rare exact bridge between **enumerative combinatorics** and **Abelian/tropical geometry**.

### Connection 4: Physics of zero modes
The kernel direction is a discrete analog of gauge/zero-mode sectors in quantum field theory. Make this analogy explicit in `RESEARCH_PAPER.md` and `ARTICLE.md`.

---

## Conjecture with testable prediction

State and formalize a falsifiable conjecture along these lines:

### Conjecture: subdivision-rigidity of the harmonic ratio
For any two weighted graph models of the same metric graph,
\[
\frac{Z_{\mathrm{periodic}}(\Gamma)}{Z_{\mathrm{pin}}(\Gamma)}
\]
is invariant and equals the tropical Jacobian covolume.

Possible Lean declaration:
```lean
conjecture subdivision_rigidity_of_periodic_pin_ratio
    {V W : Type _} [Fintype V] [DecidableEq V] [Fintype W] [DecidableEq W]
    (Γ₁ : HarmonicSectorData V) (Γ₂ : HarmonicSectorData W)
    (hmodel : MetricGraphEquivalent Γ₁ Γ₂) :
    ZPeriodic Γ₁ / ZPin Γ₁ = ZPeriodic Γ₂ / ZPin Γ₂
```

### Computational test
Implement explicit computations for theta graphs `Θ(a,b,c)` and for subdivided versions of the same metric graph. The conjecture is **disproved** if the ratio changes under subdivision preserving the underlying metric graph.

This is a real scientific prediction, not decorative speculation.

---

## Concrete family to test: theta graphs

You should define a parameterized family of weighted theta graphs `ThetaGraph a b c` with three parallel paths/edges of lengths `a,b,c`. Then compute or estimate:

- `ZPin (ThetaGraph a b c)`
- `ZHarm (ThetaGraph a b c)`
- `ZPeriodic (ThetaGraph a b c)`
- the ratio `ZPeriodic / ZPin`

Then test:
1. symmetry under permutation of `a,b,c`,
2. invariance under subdivision of one branch into two edges summing to the same length,
3. dependence only on the harmonic lattice covolume.

This family is rich enough to expose failures and simple enough to compute.

---

## Deep-proof requirements

You are required to ensure at least 3 theorems use genuinely nontrivial proof tactics. Aim to include:

- induction over finite support / graph decomposition,
- `rcases` on connectivity or kernel decomposition witnesses,
- `by_contra` to prove strict positivity on the pinned subspace,
- `field_simp` in determinant/covolume manipulations,
- multi-step `calc` blocks for factorization and logarithmic splitting.

Do not allow the file to devolve into definitional rewrites.

---

## Suggested file architecture

Create a new Lean file along the lines of:

```text
Catalog/Bridges/Pythagorean/TropicalBridge/HarmonicSectorFactorization.lean
```

Inside it:

1. define `HarmonicSectorData` or equivalent,
2. define `ZPin`, `ZHarm`, `ZPeriodic`,
3. prove kernel/quotient lemmas,
4. prove the main factorization theorem,
5. prove at least one invariance theorem,
6. state the computational conjecture.

If necessary, split computational lemmas for theta graphs into a companion file.

---

## Deliverables — all mandatory

You must produce **all** of the following:

### 1. `FUTURE_DIRECTIONS.md`
Include 3–5 original research directions. Each direction must contain the exact sentences:
- **“The key insight is...”**
- **“Why now?”**

At least one direction must bridge to a different domain, such as:
- tropical QFT,
- discrete gauge theory,
- arithmetic geometry,
- inverse problems on networks.

### 2. `RESEARCH_PAPER.md`
A standalone scientific paper explaining:
- the theorem,
- the definitions,
- why factorization is surprising,
- how tropical Jacobians become physically computable,
- computational experiments on theta graphs,
- conjectures and next steps.

A reader with no code access must fully understand the discovery.

### 3. `ARTICLE.md`
Write this in a **Scientific American** style.
Explain the ideas accessibly and vividly.
**Taboo:** do not focus on formal verification or proof assistants. Focus on the mathematics and why it matters.

### 4. Verified algorithm / computational method
Provide a verified method for computing, approximating, or certifying:
- reduced Laplacian determinant,
- harmonic lattice covolume,
- and/or the factorized partition function.

This must be an algorithm, not merely a theorem statement.

### 5. `demo.py`
An interactive script that:
- constructs theta graphs `Θ(a,b,c)`,
- computes `ZPin`, `ZHarm`, and their product,
- compares subdivided models,
- numerically tests the conjecture,
- visualizes the ratio across parameter families.

---

## Application keywords

tropical Jacobian, Gaussian free field, partition function, metric graph, reduced Laplacian, matrix-tree theorem, harmonic lattice, covolume, free energy, zero modes, sector decomposition, statistical mechanics, spectral graph theory, tropical geometry, discrete Hodge theory, Abelian networks, lattice Gaussian, topological entropy, graph moduli, theta graph

---

## Standard of ambition

Do not settle for “the energy is invariant under constants.” That is only the doorway. The goal is to make a mathematically precise statement that a **thermodynamic quantity factors through the tropical Jacobian**.

This is the kind of result that can found a new subject: **tropical statistical mechanics**, where partition functions detect tropical moduli and harmonic geometry.

Minimize `sorry`. Use the catalog aggressively. Prove something that a research mathematician would not have expected to see formalized this early.

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
