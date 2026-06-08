Soli Deo Gloria

## Assignment: Kakeya Conjecture as a Formal Research Program

**Mode:** discover + formalize + prove

Do not aim for a cosmetic restatement of the classical Kakeya conjecture. Aim instead to build a **Lean-native Kakeya architecture** that isolates a formally tractable core of the conjecture and pushes through genuinely new verified theorems linking:

- geometric measure theory,
- incidence/additive combinatorics,
- Fourier/restriction heuristics,
- and computable finite-field models.

The breakthrough is not merely “formalize known definitions.” The breakthrough is to create a **machine-checkable bridge** from Euclidean Kakeya heuristics to **finite-field Kakeya growth laws and incidence-energy inequalities**, with enough structure that future cycles can attack maximal-function and dimension statements systematically.

## Primary Vision

The full Euclidean Kakeya conjecture in `ℝⁿ` is likely beyond one cycle if approached head-on through Hausdorff dimension. So your mission is to formalize a **theorem package that makes the conjecture attackable**:

1. a precise Besicovitch/Kakeya object in Lean,
2. a finite-field Kakeya model with verified lower bounds,
3. an incidence-energy formalism connecting line-rich sets to additive growth,
4. a restriction-style inequality in a discrete surrogate model,
5. and a falsifiable conjectural bridge back to Euclidean dimension.

This is not incremental. It would open a verified program for **formal harmonic analysis via combinatorial avatars**.

---

## Core Mathematical Target

### New definition package (mandatory novelty)

Define at least one genuinely new structure, for example:

- `FiniteFieldKakeyaSet`
- `DirectionRichSet`
- `LineIncidenceEnergy`
- `DiscreteBesicovitchModel`

A particularly promising Lean structure is:

```lean
structure FiniteFieldKakeyaSet (𝔽 : Type*) [Field 𝔽] [Fintype 𝔽]
    (n : ℕ) where
  carrier : Set ((Fin n) → 𝔽)
  contains_line_in_every_direction :
    ∀ v : (Fin n) → 𝔽, v ≠ 0 →
      ∃ x : (Fin n) → 𝔽,
        Set.range (fun t : 𝔽 => fun i => x i + t * v i) ⊆ carrier
```

This is mathematically meaningful and Lean-natural. It gives a formal object on which you can prove true lower bounds.

---

## Precise theorem targets

You must prove at least **3 substantial theorems**. The following package is the most promising.

### Theorem 1: Direction-line cardinality lower bound
A Kakeya set over a finite field must contain at least as many points as the cardinality of a line.

**Mathematical statement**
For every finite field `𝔽`, every `n ≥ 1`, and every Kakeya set `K ⊆ 𝔽ⁿ`, one has
`|K| ≥ |𝔽|`.

This is not the endpoint, but it is a nontrivial structural sanity theorem and establishes the formal framework.

**Lean 4 type signature**
```lean
theorem FiniteFieldKakeyaSet.card_ge_field
    (𝔽 : Type*) [Field 𝔽] [Fintype 𝔽]
    {n : ℕ} (hn : 1 ≤ n)
    (K : FiniteFieldKakeyaSet 𝔽 n) :
    Fintype.card 𝔽 ≤ Nat.card K.carrier := by
  sorry
```

If `Nat.card` on a set subtype becomes awkward, switch to a finite-set encoding:
```lean
structure FiniteFieldKakeyaFinset (𝔽 : Type*) [Field 𝔽] [Fintype 𝔽] (n : ℕ) where
  carrier : Finset ((Fin n) → 𝔽)
  contains_line_in_every_direction :
    ∀ v : (Fin n) → 𝔽, v ≠ 0 →
      ∃ x : (Fin n) → 𝔽,
        ∀ t : 𝔽, (fun i => x i + t * v i) ∈ carrier
```

Then:
```lean
theorem FiniteFieldKakeyaFinset.card_ge_field
    (𝔽 : Type*) [Field 𝔽] [Fintype 𝔽]
    {n : ℕ} (hn : 1 ≤ n)
    (K : FiniteFieldKakeyaFinset 𝔽 n) :
    Fintype.card 𝔽 ≤ K.carrier.card := by
  sorry
```

**Why it matters**
This is the first verified theorem certifying that the formalized notion is not vacuous and that every Kakeya object is geometrically large in a provable sense.

---

### Theorem 2: Distinct-parameter injectivity along a nonzero direction
For a nonzero direction vector in `𝔽ⁿ`, the parameterization of a line is injective.

**Mathematical statement**
If `v ≠ 0`, then the map `t ↦ x + t v` is injective.

This is a key engine theorem for all later cardinality bounds, incidence counting, and energy estimates.

**Lean 4 type signature**
```lean
theorem lineMap_injective_of_direction_ne_zero
    (𝔽 : Type*) [Field 𝔽]
    {n : ℕ} {x v : (Fin n) → 𝔽}
    (hv : v ≠ 0) :
    Function.Injective (fun t : 𝔽 => fun i => x i + t * v i) := by
  sorry
```

**Why it matters**
This is the combinatorial-geometric atom behind Kakeya over finite fields. It will require actual reasoning: choose a coordinate where `v i ≠ 0`, compare coordinates, cancel, and conclude `t₁ = t₂`.

---

### Theorem 3: Incidence-energy lower bound for direction-rich sets
Define an incidence count between a set and the family of lines it contains, then prove a lower bound via Kakeya richness.

**New definition**
```lean
def lineIncidenceCount
    (𝔽 : Type*) [Field 𝔽] [Fintype 𝔽]
    {n : ℕ}
    (S : Finset ((Fin n) → 𝔽))
    (L : Finset (((Fin n) → 𝔽) × ((Fin n) → 𝔽))) : ℕ :=
  ((L.σ fun ld => 
      let x := ld.1
      let v := ld.2
      (Finset.univ.filter fun t : 𝔽 =>
        (fun i => x i + t * v i) ∈ S))).card
```

You may want to refactor to a more tractable sum-of-cards definition.

**Mathematical statement**
If `S` contains a full line in each direction from a finite family `D` of pairwise distinct nonzero directions, then the incidence count is at least `|D| * |𝔽|`.

**Lean 4 type signature**
```lean
theorem incidence_lower_bound_of_direction_rich
    (𝔽 : Type*) [Field 𝔽] [Fintype 𝔽]
    {n : ℕ}
    (S : Finset ((Fin n) → 𝔽))
    (D : Finset ((Fin n) → 𝔽))
    (hD0 : ∀ v ∈ D, v ≠ 0)
    (hlines : ∀ v ∈ D, ∃ x : (Fin n) → 𝔽, ∀ t : 𝔽, (fun i => x i + t * v i) ∈ S) :
    D.card * Fintype.card 𝔽 ≤
      ∑ v in D, ((Finset.univ.filter fun t : 𝔽 =>
        (fun i => Classical.choose (hlines v ‹v ∈ D›) i + t * v i) ∈ S).card) := by
  sorry
```

You may simplify the RHS to exactly `D.card * Fintype.card 𝔽` by proving each summand equals `|𝔽|`.

**Why it matters**
This is the first formal bridge from Kakeya geometry to **incidence combinatorics**. It is the verified seed of the polynomial method and restriction heuristics.

---

### Theorem 4: A discrete restriction-style second-moment inequality
Introduce a finite-field/discrete Fourier surrogate and prove a second-moment identity or inequality for line-supported sums. Even a modest Plancherel-type statement in the Kakeya setting would be revolutionary as infrastructure.

A tractable version:
define, for `f : (Fin n → 𝔽) → ℂ`, the line average
`A_{x,v}(f) = ∑ t, f(x + tv)` and prove a Cauchy–Schwarz bound over a family of directions.

**Lean 4 type signature**
```lean
def lineAverage
    (𝔽 : Type*) [Field 𝔽] [Fintype 𝔽]
    {n : ℕ} (f : ((Fin n) → 𝔽) → ℂ)
    (x v : (Fin n) → 𝔽) : ℂ :=
  ∑ t : 𝔽, f (fun i => x i + t * v i)

theorem sq_norm_lineAverage_le_field_mul_support
    (𝔽 : Type*) [Field 𝔽] [Fintype 𝔽]
    {n : ℕ} (f : ((Fin n) → 𝔽) → ℂ)
    (x v : (Fin n) → 𝔽) :
    ‖lineAverage 𝔽 f x v‖^2 ≤
      (Fintype.card 𝔽 : ℝ) *
      ∑ t : 𝔽, ‖f (fun i => x i + t * v i)‖^2 := by
  sorry
```

This is fundamentally Cauchy–Schwarz, but in context it becomes a formal restriction surrogate.

**Why it matters**
This opens a route toward verified **maximal-function inequalities** and harmonic-analytic formulations of Kakeya.

---

## Strategic theorem connecting to a different domain

You are required to include a genuine cross-domain connection. The strongest option here is:

### Cross-domain theorem: geometric incidence implies additive-energy control
Define additive energy for a finite subset of `𝔽ⁿ` and prove that a direction-rich line configuration produces many additive coincidences.

For example, if `S` contains many parallel translates of lines, prove a lower bound on the number of solutions to
`a + d = b + c`
inside a line-generated subset.

Even a special case for one line already matters:

```lean
def additiveEnergy
    (𝔽 : Type*) [Field 𝔽] [Fintype 𝔽]
    {n : ℕ} (A : Finset ((Fin n) → 𝔽)) : ℕ :=
  (((A.product A).product (A.product A)).filter
    (fun z =>
      let a := z.1.1
      let b := z.1.2
      let c := z.2.1
      let d := z.2.2
      a + d = b + c)).card
```

Then prove a lower bound for the image of a line:
```lean
theorem additiveEnergy_lineImage_lower_bound
    (𝔽 : Type*) [Field 𝔽] [Fintype 𝔽]
    {n : ℕ} {x v : (Fin n) → 𝔽}
    (hv : v ≠ 0)
    (A : Finset ((Fin n) → 𝔽))
    (hA : A = Finset.univ.image (fun t : 𝔽 => fun i => x i + t * v i)) :
    (Fintype.card 𝔽)^3 ≤ additiveEnergy 𝔽 A := by
  sorry
```

**Cross-domain significance**
This connects Kakeya geometry to **additive combinatorics** through energy, which is one of the central modern languages for sum-product phenomena, restriction, and incidence theory.

Application keywords:
**Kakeya, Besicovitch sets, finite fields, incidence geometry, additive energy, restriction theory, polynomial method, harmonic analysis, combinatorics, discrete tomography**

---

## Euclidean bridge theorem using catalog results

Build on:
- `null_sphere_has_measure_zero`
  from `FINAL/Geometry/GapMatterResearch.lean`

Use it to formalize a theorem that the set of directions excluded by a coordinate degeneracy or spherical exceptional set is measure zero. This gives a verified “generic direction” lemma needed in Euclidean Kakeya arguments.

A plausible theorem:

```lean
theorem almost_every_direction_has_nonzero_coordinate
    {n : ℕ} (hn : 1 ≤ n) :
    MeasureTheory.volume
      {v : EuclideanSpace ℝ (Fin n) |
        v ∈ Metric.sphere (0 : EuclideanSpace ℝ (Fin n)) 1 ∧
        ∀ i : Fin n, v i = 0} = 0 := by
  sorry
```

Or better: prove that any codimension-1 spherical exceptional locus has measure zero by reducing to `null_sphere_has_measure_zero` or a related sphere-nullity statement.

**Why it matters**
This gives a formal Euclidean “generic direction” principle that harmonizes with the finite-field direction-rich formalism.

---

## Conjecture with a testable prediction

State at least one falsifiable conjecture with an explicit computational test.

### Conjecture: finite-field incidence-energy Kakeya growth
For each fixed `n ≥ 2`, there exists `C_n > 0` such that every finite-field Kakeya set `K ⊆ 𝔽_q^n` satisfies
`|K| ≥ C_n q^n`.

This is weaker than Dvir’s sharp theorem if you cannot yet formalize the polynomial method fully, but strong enough to guide experiments.

**Testable prediction**
For small fields `𝔽_q` and dimensions `n = 2,3`, brute-force or randomized search over direction-rich sets should show that the minimum observed density of Kakeya sets is bounded away from zero, and line-incidence energy sharply increases as cardinality approaches extremality.

Require `demo.py` to:
- generate finite-field vector spaces for small `q`,
- sample candidate direction-rich sets,
- compute size, incidence count, and additive energy,
- test the conjectural lower bound numerically,
- visualize size versus energy.

You may also state a stronger falsifiable conjecture:

### Conjecture: discrete restriction-energy principle
If `S ⊆ 𝔽_q^n` contains a line in every direction, then its normalized line-average operator has operator norm bounded below by a dimension-dependent constant, uniformly in `q`.

This is computationally testable by matrix construction for small fields.

---

## Proof strategy architecture

You must not give one vague hint. Pursue at least 2–3 possible proof paths and choose the most promising.

### Strategy A: coordinate extraction + injectivity + counting
Best first route.

1. Prove `lineMap_injective_of_direction_ne_zero` by:
   - using `hv : v ≠ 0` to obtain `∃ i, v i ≠ 0`,
   - evaluating equality of line points at coordinate `i`,
   - subtracting and dividing by `v i`.
2. Deduce that each nonzero direction generates a line with exactly `|𝔽|` points.
3. Use subset inclusion into the Kakeya carrier to get cardinality lower bounds.

Why this is most promising:
- Lean handles coordinatewise vector arguments very well.
- It avoids heavy polynomial or dimension machinery.
- It yields reusable lemmas for every later incidence theorem.

### Strategy B: finite-set incidence summation
Use this for Theorem 3 and additive-energy results.

1. Encode lines as finite images of injective maps `𝔽 → 𝔽ⁿ`.
2. Rewrite incidence counts as finite sums over directions and parameters.
3. Use lower bounds on each summand and then combine via `Finset.sum_le_sum` / `calc`.

Why it matters:
- This creates a robust combinatorial API.
- It naturally interfaces with additive combinatorics and experimental code.

### Strategy C: analytic surrogate via Cauchy–Schwarz / Plancherel-style inequalities
Use for the restriction-style theorem.

1. Define line averages over finite fields.
2. Apply `‖∑ z_i‖^2 ≤ N * ∑ ‖z_i‖^2`.
3. Specialize to indicator functions of Kakeya sets.

Why it is valuable:
- It imports harmonic-analytic intuition without needing full Fourier analysis at once.
- It creates a future path to maximal-function estimates.

If you have time, begin a fourth path:

### Strategy D: polynomial-method scaffolding
Not necessarily finish Dvir’s theorem this cycle, but build ingredients:
- vanishing polynomial on a finite set,
- degree counting,
- line restriction of polynomials.

Even one verified lemma here would be a field-opener.

---

## Lean-specific formalization guidance

Use finite-field and finite-type encodings whenever possible. For tractability:

- represent `𝔽ⁿ` as `(Fin n) → 𝔽`,
- use `Finset` rather than arbitrary `Set` whenever cardinality is central,
- define line maps explicitly as `fun t => fun i => x i + t * v i`,
- prove injectivity before proving cardinality,
- isolate coordinate-choice lemmas.

A key helper lemma you will likely need:

```lean
lemma exists_nonzero_coordinate_of_ne_zero
    (𝔽 : Type*) [Field 𝔽]
    {n : ℕ} {v : (Fin n) → 𝔽}
    (hv : v ≠ 0) :
    ∃ i : Fin n, v i ≠ 0 := by
  sorry
```

This should require nontrivial reasoning, probably by contradiction using function extensionality.

Another likely helper:
```lean
lemma line_point_eq_iff
    (𝔽 : Type*) [Field 𝔽]
    {n : ℕ} {x v : (Fin n) → 𝔽}
    {t₁ t₂ : 𝔽} (hv : v ≠ 0) :
    (fun i => x i + t₁ * v i) = (fun i => x i + t₂ * v i) ↔ t₁ = t₂ := by
  sorry
```

These are not trivial; they are core infrastructure.

---

## Required use of deep proof tactics

Your file must contain at least 3 theorems whose proofs genuinely use:
- `induction`, or
- `rcases`, or
- `by_contra`, or
- `field_simp`, or
- multi-step `calc`.

Suggested allocation:
- `exists_nonzero_coordinate_of_ne_zero`: use `by_contra` + extensionality.
- `lineMap_injective_of_direction_ne_zero`: use `rcases` and `field_simp`/cancellation.
- incidence lower bound theorem: use multi-step `calc`.
- if formalizing a recursive dimension lemma, use `induction` on `n`.

---

## Building on existing verified theorems

You were given:
- `null_sphere_has_measure_zero`
  from `FINAL/Geometry/GapMatterResearch.lean`

Use it concretely, not decoratively:
- derive a Euclidean generic-direction lemma,
- identify exceptional directional sets as null sets,
- formalize “almost every direction avoids a degenerate configuration.”

This is the right Euclidean foothold because Kakeya arguments repeatedly separate generic directions from exceptional ones.

The other listed theorems are less directly relevant, so do not force them. The null-sphere theorem is the genuine bridge.

---

## What would count as a breakthrough here?

A true breakthrough in this cycle would be to leave behind a verified theorem stack of the form:

1. **Finite-field Kakeya object exists in Lean**
2. **Line parameterizations are injective in nonzero directions**
3. **Every finite-field Kakeya set satisfies nontrivial size/incidence lower bounds**
4. **Direction-rich geometry forces additive-energy growth**
5. **A discrete restriction-style inequality is verified**
6. **A Euclidean generic-direction lemma is linked to measure-zero spherical exceptions**

This would establish the first coherent formal pathway from **Besicovitch geometry to additive combinatorics and harmonic analysis** in this environment.

That is field-opening because it enables:
- future formalizations of Dvir’s polynomial method,
- maximal Kakeya operator inequalities,
- sum-product and incidence applications,
- discrete tomography,
- coding-theoretic interpretations of direction-rich sets,
- and eventually restriction/Bochner-Riesz style formal programs.

---

## Deliverables you must produce

You must produce **all** of the following:

1. **Lean file(s)** with the new definitions and at least 3 substantial theorems, minimizing `sorry`.
2. **A verified algorithm or computational method**:
   - algorithm to generate/test finite-field Kakeya candidates,
   - compute line incidences and additive energy,
   - and verify the proven lower bounds on examples.
3. **`demo.py`**:
   - interactive exploration for small `q, n`,
   - displays candidate sets, line coverage, cardinalities, energies,
   - tests the conjecture numerically.
4. **`RESEARCH_PAPER.md`**:
   - standalone scientific paper,
   - explain the new definitions, theorems, proofs, significance, and next steps,
   - understandable without reading code.
5. **`ARTICLE.md`**:
   - Scientific American style,
   - focus on Kakeya geometry, line directions, and why combinatorics and harmonic analysis unexpectedly meet here,
   - do **not** focus on formal verification machinery.
6. **`FUTURE_DIRECTIONS.md`** with 3–5 original research directions.
   Each direction must include:
   - “The key insight is ...”
   - “Why now?”
   At least one direction must bridge to a different domain, such as:
   - coding theory,
   - compressed sensing,
   - statistical physics,
   - or arithmetic combinatorics.

---

## Suggested future directions to seed in your own thinking

Do not merely copy these; improve them.

- Formalize Dvir’s polynomial method in `𝔽_q^n`.
- Build a finite-field Fourier transform API for restriction/Kakeya problems.
- Connect line-incidence energy to expander/coding constructions.
- Create a discrete-to-Euclidean transfer principle for Kakeya-type dimension bounds.
- Explore whether random direction-rich sets exhibit phase transitions reminiscent of statistical mechanics.

---

## Application keywords

Kakeya conjecture, Besicovitch set, Hausdorff dimension, finite-field Kakeya, incidence geometry, additive combinatorics, additive energy, restriction estimates, maximal functions, polynomial method, harmonic analysis, geometric measure theory, discrete tomography, coding theory, compressed sensing, statistical mechanics

## Nonnegotiable standard

Do not submit a toy file with only definitions and easy lemmas. Submit a genuine research artifact: a new Lean formalization layer for Kakeya theory with substantive counting, incidence, and analytic theorems, plus computational experiments that could actually falsify your conjecture or sharpen it.

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
    "visualizations": [ { "name": "...", "code": "# matplotlib or plotly script, self-contained", "description": "What this visualizes" } ],
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

Research domain: Geometry
Research mode: prove
