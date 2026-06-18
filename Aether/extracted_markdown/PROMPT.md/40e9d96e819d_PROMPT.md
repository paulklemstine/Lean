## Assignment: Tropical Scaling Exponents for Computation DAGs — from invariant to universality principle

Prove new, non-trivial theorems that elevate the existing tropical scaling-exponent framework from a descriptive invariant to a structural classification theory for symbolic computation graphs. Build explicitly on the catalog’s established definitions and lemmas about tropical equivalence, admissible computation DAGs, and scaling exponent extraction. Minimize `sorry` by targeting statements that factor through already certified graph invariants and order-theoretic lemmas.

### Mode
**prove**

---

# Research Direction
# Breakthrough Program: Tropical Universality Theorems for Computation DAGs

## Vision

The existing framework gives a first formally verified invariant for neural scaling laws. That is already notable. But the transformative next step is much bolder:

**show that tropical structure is not merely correlated with scaling exponents, but mathematically forces them under broad compositional conditions.**

If this succeeds, it opens a new field: **tropical complexity theory for learning systems**, where asymptotic trainability is controlled by max-plus geometry of computation graphs. This would connect formalized asymptotics, neural scaling laws, DAG complexity, renormalization ideas from statistical physics, and tropical geometry into one theorem-producing language.

The goal is not another variant of an existing robustness theorem. The goal is a **classification theorem**.

---

## Primary Target Theorem A: Tropical Invariance of the Leading Scaling Exponent

### Informal statement

Let `G` and `H` be admissible symbolic computation DAGs. Assume they are tropically equivalent, and assume the loss/compute surrogate extracted from each graph is eventually trapped between positive constant multiples of the same tropical polynomial profile. Then the leading scaling exponent of `G` and `H` is identical.

This would formalize the central scientific claim behind Hypothesis 1 in a purely mathematical way, independent of any particular training experiment.

### Precise mathematical statement

Let `ScaleFn := ℕ → ℝ≥0∞` or `ℕ → ℝ` depending on the catalog’s current asymptotic setup. Suppose there is already a notion:

- `Admissible : Dag → Prop`
- `TropEquiv : Dag → Dag → Prop`
- `scalingProfile : Dag → ℕ → ℝ`
- `scalingExponent : Dag → ℝ`
  or alternatively an extracted exponent from asymptotic sandwich bounds.

Then target a theorem of the following shape:

```lean
theorem scalingExponent_of_tropEquiv
    {G H : Dag}
    (hG : Admissible G)
    (hH : Admissible H)
    (hEq : TropEquiv G H)
    (hSandwich :
      ∃ c1 c2 N0 : ℝ, 0 < c1 ∧ 0 < c2 ∧
        ∀ n : ℕ, N0 ≤ n →
          c1 * scalingProfile G n ≤ scalingProfile H n ∧
          scalingProfile H n ≤ c2 * scalingProfile G n) :
    scalingExponent G = scalingExponent H
```

If the library currently defines exponents via asymptotic notation rather than a function `scalingExponent`, then formulate the theorem as equality of extracted `α` values:

```lean
theorem tropEquiv_preserves_asymptotic_power
    {f g : ℕ → ℝ}
    {α β : ℝ}
    (hf : HasScalingPower f α)
    (hg : HasScalingPower g β)
    (hfg : AsymptoticallyEquivalentUpToConst f g) :
    α = β
```

and then derive the DAG theorem as a corollary.

### Why this is a breakthrough

This would be the first formal theorem showing that a **combinatorial/tropical equivalence relation on architectures determines an asymptotic learning-law observable**. That is a genuine bridge between symbolic graph structure and empirical scaling science.

---

## Secondary Target Theorem B: Stability of Log-Correction Degree under Tropical Equivalence

### Informal statement

If two admissible DAGs are tropically equivalent and each has asymptotic form
\[
f(n) = \Theta(n^{-\alpha}(\log n)^\beta),
\]
then the leading power exponent `α` is identical, and the admissible interval of possible logarithmic exponents `β` is preserved up to a bounded class determined by the tropical profile.

This theorem is more ambitious. If the full interval statement is too strong for the current library, prove the first nontrivial version:

> tropical equivalence preserves the leading power exponent and preserves whether a logarithmic correction is necessary at all.

### Lean-style theorem target

```lean
theorem tropEquiv_preserves_log_correction_presence
    {G H : Dag}
    (hG : Admissible G)
    (hH : Admissible H)
    (hEq : TropEquiv G H)
    (hGasy :
      ∃ α β c N0, 0 < c ∧
        ∀ n : ℕ, N0 ≤ n →
          scalingProfile G n ≤ c * (n : ℝ)^(-α) * (Real.log (n+2))^β ∧
          (c⁻¹) * (n : ℝ)^(-α) * (Real.log (n+2))^β ≤ scalingProfile G n)
    (hHasy :
      ∃ α' β' c' N0', 0 < c' ∧
        ∀ n : ℕ, N0' ≤ n →
          scalingProfile H n ≤ c' * (n : ℝ)^(-α') * (Real.log (n+2))^β' ∧
          (c'⁻¹) * (n : ℝ)^(-α') * (Real.log (n+2))^β' ≤ scalingProfile H n) :
    ∃ α, leadingPowerExponent G α ∧ leadingPowerExponent H α
```

A stronger theorem, if feasible, is:

```lean
theorem tropEquiv_binds_log_degree
    {G H : Dag} :
    TropEquiv G H →
    LogCorrectionClass G = LogCorrectionClass H
```

where `LogCorrectionClass` is a finite interval/set extracted from tropical multiplicity or tie structure.

### Why this matters

This is the first step toward a **second-order tropical asymptotics** theory. The leading exponent is the headline; the logarithmic correction is where universality classes live. This is the point where the theory starts to resemble renormalization rather than curve-fitting.

---

## Tertiary Target Theorem C: Composition Law for Tropical Exponents

### Informal statement

For admissible DAGs combined by serial composition, parallel composition, or skip-add composition, the tropical scaling exponent is determined by a max/min-plus algebraic law.

A compelling target is:

- serial composition corresponds to exponent addition,
- parallel competition corresponds to exponent minimum,
- residual/skip structures correspond to tropical maximum of dominant paths.

### Precise theorem pattern

Assume operations:
- `serial : Dag → Dag → Dag`
- `parallel : Dag → Dag → Dag`

Then prove statements of the form:

```lean
theorem scalingExponent_serial
    {G H : Dag}
    (hG : Admissible G)
    (hH : Admissible H) :
    scalingExponent (serial G H) = scalingExponent G + scalingExponent H
```

```lean
theorem scalingExponent_parallel
    {G H : Dag}
    (hG : Admissible G)
    (hH : Admissible H) :
    scalingExponent (parallel G H) = min (scalingExponent G) (scalingExponent H)
```

or if the sign convention makes larger exponents better/worse, replace `min` with `max` accordingly.

### Why this is revolutionary

This upgrades the framework from an invariant to a **calculus**. Once there is a composition law, architecture design becomes symbolic asymptotic engineering. That would make the formal system predictive, not merely descriptive.

---

## Proof Strategy Architecture

## Strategy A: Asymptotic sandwich via eventual inequalities
**Most promising for Target A.**

1. Reduce tropical equivalence of DAGs to eventual multiplicative comparability of their extracted scaling profiles:
   \[
   c_1 f(n) \le g(n) \le c_2 f(n)
   \]
   for all large `n`.

2. Use the catalog’s asymptotic power-law uniqueness theorem, or prove one if missing:
   if `f = Θ(n^{-α})` and `g = Θ(n^{-β})` and `f,g` are mutually bounded by constants, then `α = β`.

3. Lift this scalar theorem back to DAGs through the certified extraction map from graph to scaling profile.

This route is attractive because it minimizes graph-specific reasoning: once the extraction theorem is in place, the hard part becomes a clean asymptotic uniqueness lemma.

---

## Strategy B: Tropical normal form and dominant-path decomposition
**Most promising for Targets B and C.**

1. Put each admissible DAG into a tropical normal form: represent its asymptotic profile as the max/min over finitely many weighted path monomials.

2. Show tropical equivalence implies equality of the dominant face of the Newton polytope / path polytope.

3. Read off the leading exponent from that face, and identify log-corrections with multiplicity/tie data among dominant monomials.

This is more conceptually powerful. It connects directly to tropical geometry and Newton polytope combinatorics. If successful, it yields not just invariance but an explicit structural explanation.

---

## Strategy C: Order-theoretic fixed-point / semiring semantics
**Most visionary; likely harder, but field-opening.**

1. Interpret computation DAGs in an idempotent semiring semantics where composition becomes semiring multiplication and parallelism becomes semiring addition.

2. Define the scaling exponent as a valuation from the semiring of DAG semantics to an ordered group / tropical semifield.

3. Prove the valuation is invariant under tropical equivalence and functorial under graph composition.

This approach could produce the cleanest theorem statements and best future extensibility. It is the route toward a genuine **category of scaling laws**. It may be too ambitious for one cycle, but even partial progress would be extraordinary.

---

## Recommended execution order

1. **First prove the scalar asymptotic uniqueness lemma** for powers and power-log forms.
2. **Then prove Target A** as the first architecture theorem.
3. **Then prove a restricted Target C** for one composition operator already formalized in the catalog.
4. **Then, if time permits, define a preliminary `LogCorrectionClass`** and prove a weak Target B.

This sequence minimizes `sorry` because each step modularizes the next.

---

## Catalog building blocks to exploit

You must explicitly search the catalog for and build on:

- existing definitions of admissible computation DAGs,
- any theorem equating tropical equivalence with equality of tropical profiles,
- asymptotic notation lemmas (`IsBigO`, `IsTheta`, eventual domination, `Filter.Eventually`),
- positivity and monotonicity lemmas for `Real.log`, powers, and eventually-positive sequences,
- any graph composition constructors already certified,
- any theorem extracting dominant monomials / path weights / tropical polynomial semantics.

If there is already a theorem resembling “tropical equivalence implies same profile up to constants,” use it as the central bridge. If there is already a uniqueness theorem for asymptotic exponents, compose rather than reproving.

---

## Cross-domain mathematical connections to exploit

### 1. Tropical geometry ↔ Newton polytope theory
The leading exponent should correspond to a dominant face or valuation. This is the geometric heart of the classification theorem.

### 2. Computational complexity ↔ circuit depth/size tradeoffs
A computation DAG is a circuit. Tropical exponents may become asymptotic complexity invariants for learning systems, analogous to depth measures in circuit complexity.

### 3. Statistical physics ↔ renormalization universality
Power exponents and logarithmic corrections are exactly the language of critical phenomena. Tropical equivalence classes may function like universality classes.

### 4. Idempotent analysis ↔ dynamic programming / shortest-path algebra
Max-plus and min-plus semantics naturally encode path competition in DAGs. This gives a principled explanation for why dominant computational pathways control asymptotics.

### 5. Formal methods ↔ scientific ML
A theorem here would be rare: a machine-checked structural statement about neural scaling behavior. That is a new standard for the field.

---

## Concrete sublemmas worth proving

These are excellent low-level targets that can likely be completed with minimal `sorry`:

```lean
theorem power_exponent_unique
    {α β : ℝ} {f : ℕ → ℝ}
    (hα : HasScalingPower f α)
    (hβ : HasScalingPower f β) :
    α = β
```

```lean
theorem theta_power_compare_forces_eq
    {α β : ℝ}
    (h : (fun n : ℕ => (n : ℝ)^α) =Θ[Filter.atTop] (fun n => (n : ℝ)^β)) :
    α = β
```

```lean
theorem theta_power_log_compare_forces_power_eq
    {α β γ δ : ℝ}
    (h :
      (fun n : ℕ => (n : ℝ)^α * (Real.log (n+2))^γ)
        =Θ[Filter.atTop]
      (fun n : ℕ => (n : ℝ)^β * (Real.log (n+2))^δ)) :
    α = β
```

```lean
theorem tropEquiv_implies_theta_profile
    {G H : Dag}
    (hEq : TropEquiv G H) :
    scalingProfile G =Θ[Filter.atTop] scalingProfile H
```

```lean
theorem serial_profile_multiplies
    {G H : Dag} :
    scalingProfile (serial G H) =ᶠ[Filter.atTop]
      (fun n => scalingProfile G n * scalingProfile H n)
```

These sublemmas together would already constitute a substantial advance.

---

## What would make this paradigm-shifting

If you prove even Target A plus one composition law, the consequence is dramatic:

- tropical equivalence becomes a **certified predictor** of asymptotic behavior,
- architecture search can be quotient-ed by formal equivalence classes,
- empirical scaling studies gain a rigorous symbolic backbone,
- future work can classify transformers, MLPs, and attention variants by tropical universality class rather than by ad hoc benchmark tables.

This would not be a small extension. It would be the beginning of a mathematical language for scaling laws.

---

## Deliverables

1. One main Lean file proving **Target A** or the strongest achievable restricted version.
2. Supporting lemmas for asymptotic uniqueness and eventual comparability.
3. If possible, one composition theorem (**Target C**) for an already formalized constructor.
4. A concise note in comments identifying exactly which catalog theorems were used as bridges.

---

## Required FUTURE_DIRECTIONS.md

Produce a structured `FUTURE_DIRECTIONS.md` with **3–5 falsifiable scientific hypotheses**, each containing:
- a precise conjecture,
- a formal or experimental test,
- a refutation criterion.

These must be concrete, testable, and downstream of the theorems you prove. Good examples include:

1. **Universality-class hypothesis**: two transformer variants with formally certified tropical equivalence have asymptotically identical empirical scaling exponents.
2. **Multiplicity-log hypothesis**: the number of dominant tropical monomials predicts the degree/sign of logarithmic correction.
3. **Residual dominance hypothesis**: residual architectures exhibit exponent equal to the tropical max of backbone and skip branches.
4. **Architecture quotient hypothesis**: searching over tropical equivalence classes yields the same best-scaling architecture as searching over the full model family, with exponentially fewer candidates.
5. **Phase-transition hypothesis**: changes in dominant tropical face correspond to observed scaling-law regime changes during architecture or data-distribution shifts.

Each hypothesis should be falsifiable, not aspirational.

---

## Application keywords

tropical geometry, scaling laws, computation DAGs, neural networks, asymptotic analysis, idempotent semirings, Newton polytopes, universality classes, renormalization, circuit complexity, formal verification, scientific machine learning, power-law exponents, logarithmic corrections, architecture equivalence, max-plus algebra

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

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 5 — FUTURE_DIRECTIONS.md  (MANDATORY — drives next cycle)
────────────────────────────────────────────────────────────────────────────
The MOST IMPORTANT deliverable. Every research cycle MUST produce a
FUTURE_DIRECTIONS.md that identifies 3-5 specific, testable scientific
hypotheses. Each direction must be a falsifiable claim or conjecture that
can be proved, disproved, or tested — not a vague "we could explore X."
Format: "Conjecture: [precise statement]. Test: [what would confirm or
refute it]. Impact: [what this would enable if true]." Every hypothesis
should be daring enough to matter and specific enough to fail.

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

Research domain: Speculative
Research mode: prove
