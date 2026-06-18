Soli Deo Gloria

## Assignment: Direction 3: Renormalization Group for Subgroup Ensembles

**Mode:** `prove`

Aristotle, do not treat this as an incremental extension of subgroup pressure. Treat it as the birth of a new mathematical object: a **renormalization dynamics on finite-group subgroup ensembles**. The target is not merely to repackage extensivity results, but to identify a genuine algebraic analogue of Wilsonian flow, with fixed points, contraction/expansion rates, and a first rigorous notion of universality class for finite generation statistics.

Build explicitly on:

- `Pythagorean/SubgroupUniversality.lean`
- `Catalog/old/Pythagorean/SubgroupPressure.lean`

especially any theorem analogous to `freeEnergy_directPower` or product-factorization statements. Those are not the destination; they are the first shadow of a deeper dynamical law.

---

## Central Vision

Define a coarse-graining operator on subgroup ensembles and prove that subgroup pressure is not just extensive under products, but behaves as a **renormalization observable** under scale change. The breakthrough is to show that finite algebra admits:

1. **scale maps** on ensembles,
2. **fixed-point subgroup statistics**,
3. **linear response near fixed points**, and
4. **critical exponents from the derivative of the RG map**.

This would open a new field: **algebraic statistical mechanics of finite groups**.

Application keywords: **renormalization group, subgroup growth, pressure, universality classes, symmetric groups, block systems, transfer operators, spectral radius, critical exponents, dynamical systems, algebraic statistical mechanics, coarse-graining, generation complexity**.

---

## Precise Formal Target

You must introduce at least one genuinely new concept not already in the catalog, for example a structure like:

- `SubgroupEnsemble`
- `CoarseGraining`
- `RGFixedPoint`
- `LinearizedRG`
- `UniversalityClass`

A promising design is to package an ensemble as a finite weighted family of subgroups with a pressure functional.

### Suggested new definitions

Define a weighted subgroup ensemble over a finite group `G`:

```lean
structure SubgroupEnsemble (G : Type*) [Group G] where
  carriers : Finset (Subgroup G)
  weight : Subgroup G → ℝ
  support_weight_nonneg : ∀ H ∈ carriers, 0 ≤ weight H
```

Define partition function / pressure:

```lean
noncomputable def ensemblePartition
    (β : ℝ) {G : Type*} [Finite G] [Group G]
    (E : SubgroupEnsemble G) : ℝ :=
  ∑ H in E.carriers, Real.exp (-β * subgroupComplexity H) * E.weight H

noncomputable def ensemblePressure
    (β : ℝ) {G : Type*} [Finite G] [Group G]
    (E : SubgroupEnsemble G) : ℝ :=
  Real.log (ensemblePartition β E)
```

Here `subgroupComplexity` should be a mathematically meaningful statistic already present in the pressure framework, or a new one such as `log |G:H|`, generator count, or codimension-like quantity.

Define coarse-graining from a homomorphism `φ : G →* Q` or a block-system map:

```lean
def coarseGrainAlong
    {G Q : Type*} [Group G] [Group Q]
    (φ : G →* Q) (E : SubgroupEnsemble G) : SubgroupEnsemble Q := ...
```

For direct powers, define a scale-reduction operator:

```lean
def directPowerRG
    {G : Type*} [Group G] (E : SubgroupEnsemble G) :
    ℕ → SubgroupEnsemble (G ^ ·) := ...
```

or more concretely, if the existing library already encodes direct products suitably, define an operator reducing from scale `n+1` to `n`.

---

## Theorem Program

You must prove at least 3 substantial theorems. The following are the right targets.

### Theorem 1: Exact pressure scaling under product coarse-graining

This should formalize the first true RG law: when the ensemble is compatible with direct-product factorization, coarse-graining by deleting one factor rescales pressure by an affine law.

#### Mathematical statement
Let `G` be a finite group and let `E₁` be a subgroup ensemble on `G`. Construct product ensembles `E_n` on `G^n` by multiplicative weights and additive complexity. If `ℛ` maps `E_{n+1}` to `E_n` by projection onto the first `n` factors, then for all `β`,
\[
\Pi_{n+1}(β) = \Pi_n(β) + \Pi_1(β),
\]
hence the intensive pressure
\[
\pi_n(β) := \frac{1}{n}\Pi_n(β)
\]
is an exact fixed point of coarse-graining:
\[
\pi_{n+1}(β) \to \Pi_1(β).
\]

#### Lean 4 type signature sketch
```lean
theorem ensemblePressure_directProduct_add
    {G : Type*} [Finite G] [Group G]
    (β : ℝ) (E : SubgroupEnsemble G) :
    ∀ n : ℕ,
      ensemblePressure β (directProductEnsemble E (n + 1))
        = ensemblePressure β (directProductEnsemble E n)
        + ensemblePressure β E
```

A normalized corollary:
```lean
theorem intensivePressure_directProduct_fixedPoint
    {G : Type*} [Finite G] [Group G]
    (β : ℝ) (E : SubgroupEnsemble G) :
    Filter.Tendsto
      (fun n : ℕ =>
        ensemblePressure β (directProductEnsemble E n) / n)
      Filter.atTop
      (nhds (ensemblePressure β E))
```

#### Why this matters
This upgrades extensivity into a bona fide renormalization law. Instead of “pressure adds under products,” we get “coarse-graining has a fixed intensive observable.” That is the algebraic analogue of free-energy density in statistical mechanics.

---

### Theorem 2: Fixed points of coarse-graining correspond to scale-invariant ensembles

You need a theorem that identifies RG fixed points abstractly, not just for products.

#### Mathematical statement
Let `ℛ` be a coarse-graining operator on subgroup ensembles preserving normalized pressure. If an ensemble `E` satisfies
\[
\mathcal{R}(E) = E,
\]
then its pressure is scale-invariant under iteration:
\[
\Pi(\mathcal{R}^n(E)) = \Pi(E)
\quad \forall n.
\]
Conversely, under a separation hypothesis on the pressure observable (e.g. injectivity on a restricted family of ensembles), pressure invariance for all iterates implies fixed-point behavior.

#### Lean 4 type signature sketch
```lean
structure CoarseGraining (G : Type*) [Group G] where
  map : SubgroupEnsemble G → SubgroupEnsemble G
  pressure_scale : ℝ → ℝ
  pressure_map :
    ∀ (β : ℝ) (E : SubgroupEnsemble G),
      ensemblePressure β (map E) = pressure_scale β * ensemblePressure β E
```

```lean
def IsRGFixedPoint
    {G : Type*} [Group G]
    (R : CoarseGraining G) (E : SubgroupEnsemble G) : Prop :=
  R.map E = E
```

```lean
theorem pressure_iterate_of_fixedPoint
    {G : Type*} [Finite G] [Group G]
    (R : CoarseGraining G) (E : SubgroupEnsemble G)
    (hfix : IsRGFixedPoint R E) :
    ∀ n : ℕ,
      ensemblePressure β ((R.map^[n]) E)
        = (R.pressure_scale β)^n * ensemblePressure β E
```

And in the true fixed-point case:
```lean
theorem pressure_invariant_at_fixedPoint
    {G : Type*} [Finite G] [Group G]
    (R : CoarseGraining G) (E : SubgroupEnsemble G)
    (hfix : IsRGFixedPoint R E)
    (hscale : R.pressure_scale β = 1) :
    ∀ n : ℕ,
      ensemblePressure β ((R.map^[n]) E) = ensemblePressure β E
```

#### Why this matters
This is where “universality class” becomes mathematically meaningful: not a metaphor, but an equivalence class of ensembles with the same asymptotic coarse-grained pressure law.

---

### Theorem 3: Linearization near a fixed point controls critical exponents

This is the ambitious theorem. Even if full Fréchet differentiation is too heavy in current Mathlib, you can prove a finite-dimensional surrogate by restricting to a parameterized family of ensembles.

#### Mathematical statement
Let `E_t` be a one-parameter family of ensembles with `E_0 = E*`, where `E*` is a fixed point of `ℛ`. Suppose
\[
\Pi(E_t) = \Pi(E_0) + a t^\alpha + o(t^\alpha),
\]
and the renormalization map satisfies
\[
\mathcal{R}(E_t) = E_{\mu t + o(t)}.
\]
Then the critical exponent transforms according to the unstable eigenvalue `μ`; in the simplest logarithmic scaling regime, the exponent is determined by
\[
\alpha = \frac{\log \lambda}{\log \mu},
\]
where `λ` is the pressure scaling factor.

#### Lean 4 type signature sketch
A practical formal surrogate:
```lean
theorem criticalExponent_from_linearized_scaling
    (λ μ α : ℝ)
    (hλ : 0 < λ) (hμ : 1 < μ)
    (hα : λ = μ ^ α) :
    α = Real.log λ / Real.log μ
```

This is elementary analytically but conceptually central: it is the exact algebraic identity linking scaling eigenvalues to exponents.

A stronger parameterized version:
```lean
theorem pressure_scaling_exponent_formula
    {ι : Type*}
    (Π : ℝ → ℝ)
    (λ μ α : ℝ)
    (hλ : 0 < λ) (hμ : 1 < μ)
    (hscale : ∀ t, Π (μ * t) = λ * Π t)
    (hmodel : ∀ t, Π t = t ^ α) :
    α = Real.log λ / Real.log μ
```

#### Why this matters
This is the first bridge from finite-group combinatorics to the language of critical phenomena. Once you have this, “critical exponents for subgroup generation” stops being science fiction.

---

## Symmetric-Group Testbed Theorem

Your conjectural test case is excellent, but sharpen it into a formal theorem with a restricted but provable version.

### Theorem 4: Block-restriction monotonicity for `S_(2^k)`

Define a coarse-graining map from subgroup ensembles on `SymmetricGroup (Fin (2^(k+1)))` to those on `SymmetricGroup (Fin (2^k))` by restricting to a distinguished block of size `2^k`.

#### Mathematical statement
For a suitable ensemble of maximal or block-compatible subgroups,
\[
\Pi_{k+1}(β) \ge \Pi_k(β)
\]
or a normalized monotonicity
\[
\frac{\Pi_{k+1}(β)}{2^{k+1}} \le \frac{\Pi_k(β)}{2^k} + \varepsilon_k,
\]
with `ε_k → 0` in an ideal asymptotic formulation.

#### Lean 4 type signature sketch
```lean
theorem symmetric_block_RG_monotone
    (β : ℝ) :
    ∀ k : ℕ,
      ensemblePressure β (symmetricBlockEnsemble (k+1))
        ≥ ensemblePressure β (blockRestrictedEnsemble k)
```

Even a weaker theorem proving monotonicity or subadditivity would be significant if it is genuinely nontrivial and uses actual subgroup/block-system structure rather than enumeration.

#### Why this matters
This gives a concrete Wilsonian “lattice halving” analogue inside finite algebra, and it creates a computational laboratory for universality.

---

## Proof Strategy Architecture

You must present and execute 2–3 proof pathways, not just one.

### Strategy A: Product-factorization to exact RG law
Most promising for the first theorem.

1. Use the catalog’s product-factorization theorem from `SubgroupPressure.lean` as the algebraic core.
2. Lift it from plain pressure/free energy to your new `SubgroupEnsemble` abstraction.
3. Prove additivity of `log`-partition functions under multiplicative partition-function factorization.
4. Normalize by scale and derive fixed-point convergence using `calc`, induction on `n`, and real-analysis lemmas.

Why promising: the infrastructure already exists, and it gives an exact, not asymptotic, RG identity.

### Strategy B: Iterated-map dynamics on ensembles
Best for fixed points and universality classes.

1. Define `CoarseGraining.map` and its iterates.
2. Prove pressure transformation under iteration by induction:
   \[
   \Pi(\mathcal R^n(E)) = \lambda^n \Pi(E).
   \]
3. Characterize fixed points as exactly the ensembles whose orbit is stationary.
4. Introduce a restricted equivalence relation:
   \[
   E \sim F \iff \lim_{n\to\infty} d(\mathcal R^n E,\mathcal R^n F)=0
   \]
   or a pressure-based surrogate if a metric is too heavy.

Why promising: this creates a reusable formal language for universality classes, even before the deepest spectral theorems are available.

### Strategy C: Finite-dimensional linearization and logarithmic exponent extraction
Best for the critical-exponent theorem.

1. Restrict to a one-parameter family of ensembles `E_t`.
2. Encode scaling as a functional equation on pressure.
3. Derive the exponent formula using `Real.log`, positivity hypotheses, and `field_simp`.
4. Interpret `μ` as the unstable eigenvalue of the linearized RG map in the restricted family.

Why promising: avoids heavy differential calculus while still proving the exact scaling law physicists care about.

---

## Required Cross-Domain Connections

You must include at least one theorem explicitly bridging to another domain.

### Bridge 1: Dynamical systems
Treat coarse-graining as a discrete dynamical system on ensemble space. Prove orbit identities, fixed-point criteria, or contraction-like statements.

Possible theorem:
```lean
theorem iterate_pressure_geometric
    {G : Type*} [Finite G] [Group G]
    (R : CoarseGraining G) (E : SubgroupEnsemble G) :
    ∀ n : ℕ,
      ensemblePressure β ((R.map^[n]) E)
        = (R.pressure_scale β)^n * ensemblePressure β E
```

This is literally a transfer-operator style law.

### Bridge 2: Statistical mechanics / physics
Interpret pressure as free energy, intensive pressure as thermodynamic limit, and fixed points as universality classes. Prove at least one theorem where the algebraic statement is recognizably a thermodynamic one.

### Bridge 3: Spectral theory
If you define a finite-dimensional linear operator on parameter vectors of ensembles, prove a theorem relating repeated RG iteration to powers of a matrix or scalar eigenvalue growth.

Possible theorem:
```lean
theorem scalar_linearization_iter
    (μ : ℝ) :
    ∀ n : ℕ, ((fun t : ℝ => μ * t)^[n]) = fun t => μ^n * t
```

Then connect this to exponent extraction.

---

## Concrete Lean Tactics Expectations

Your three core theorems must require real proof structure. Use:

- induction on `n` for iterates and direct powers,
- `rcases` for decomposition of ensemble hypotheses,
- `by_contra` for uniqueness/nondegeneracy claims,
- `field_simp` in logarithmic/exponent manipulations,
- multi-step `calc` chains for pressure identities.

Do not hide everything behind automation. The mathematics must be visible.

---

## Conjecture With Testable Prediction

State and formalize at least one falsifiable conjecture.

### Recommended conjecture
For the block-restriction RG flow on maximal-subgroup ensembles of `S_(2^k)`, the normalized pressure converges:
\[
\lim_{k\to\infty} \frac{\Pi_k(β)}{2^k} = \pi_\infty(β),
\]
and the limit is independent of the initial ensemble within a universality class.

### Computational test
Implement `demo.py` to:

1. construct subgroup statistics for small `S_{2^k}` (`k = 1,2,3,4` as feasible),
2. apply block restriction,
3. compute empirical partition functions / pressures,
4. visualize normalized pressure across scales,
5. estimate whether convergence and fixed-point collapse occur.

A disproof would be visible as:
- divergence,
- oscillation,
- dependence on initial ensemble after many RG steps.

This is a good conjecture because it can fail in explicit finite data.

---

## Deliverables You Must Produce

You must produce **all** of the following.

### 1. Lean development
A new Lean file proving at least 3 substantial theorems and introducing at least one novel definition. Minimize `sorry`.

### 2. Verified algorithm / computational method
Not just theorem statements: formalize an actual coarse-graining or pressure-computation procedure, and prove a correctness theorem about it.

Examples:
- algorithm computing coarse-grained ensemble pressure for direct-product ensembles,
- algorithm iterating RG and proving the resulting pressure sequence matches the closed form.

### 3. `demo.py`
An interactive demonstration that:
- computes subgroup pressure at multiple scales,
- applies your RG map,
- plots scaling behavior,
- tests the conjecture on small examples.

### 4. `RESEARCH_PAPER.md`
A standalone scientific paper. Someone reading only this document must understand:
- the new definitions,
- the main theorems,
- why this is a renormalization theory for finite algebra,
- what experiments support the conjecture,
- what future mathematics it unlocks.

### 5. `ARTICLE.md`
Write this in Scientific American style. Make it vivid and conceptual. Explain how ideas from phase transitions and universality enter finite group theory. **Do not focus on formal verification machinery.** Focus on the mathematics and why it is surprising.

### 6. `FUTURE_DIRECTIONS.md`
Include 3–5 original research directions. Each direction must contain both sentences:
- “The key insight is ...”
- “Why now? ...”

At least one direction must bridge to a different domain, such as:
- quantum field theory,
- ergodic theory,
- complexity theory,
- spectral graph theory,
- arithmetic statistics.

Do not write templates; write genuine mathematical prose.

---

## What Would Make This Paradigm-Shifting

A successful outcome is not “we generalized freeEnergy_directPower.” It is:

- a new formal notion of **RG flow on subgroup ensembles**,
- the first exact fixed-point theorem in this setting,
- a rigorous link between **pressure scaling** and **critical exponents**,
- a concrete `S_{2^k}` experimental program suggesting universality classes in finite algebra.

If you can make this work, you will have imported one of the deepest ideas in physics into finite group theory in a mathematically precise way. That is not an extension. That is a new continent.

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
