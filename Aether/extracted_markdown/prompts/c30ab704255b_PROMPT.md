## Assignment: 4. Tropical Entropy from Compact Energy Landscapes via `sInf`

**Mode:** `prove`

Prove a genuinely new compact-space tropical thermodynamics package in Lean 4, replacing finite minima (`Finset.inf'`) by order-theoretic infima (`sInf`) and showing that the entire finite tropical entropy formalism survives on compact topological state spaces with lower semicontinuous energies. This is not a routine generalization: it is the passage from combinatorial tropical statistics to topological tropical statistical mechanics.

The breakthrough is to show that **tropical free energy is fundamentally an extreme-value/topological invariant**, not a finite-set artifact. If formalized cleanly, this opens a new interface between tropical geometry, idempotent analysis, compact optimization, and information theory.

---

## Core objects to define

Work in a new file such as:

`Tropical/Topology/TropicalEntropyCompact.lean`

Define the compact tropical partition function as the minimum energy selected by topology:

```lean
def tropicalPartitionCompact
    (X : Type*)
    [TopologicalSpace X] [CompactSpace X]
    (E : X → ℝ) : ℝ :=
  sInf (Set.range E)
```

However, for theorems about attainment, you should likely strengthen hypotheses to `[Nonempty X]` and `LowerSemicontinuous E`.

A more theorem-friendly variant may be:

```lean
def tropicalPartitionCompact
    (X : Type*)
    [TopologicalSpace X] [CompactSpace X]
    (E : X → ℝ) : ℝ :=
  sInf (Set.range E)
```

with theorem assumptions carrying the analytic content.

---

## Precise theorem targets

You should aim to prove the following theorems, with statements as close as possible to these Lean signatures.

### 1. Existence of a minimizer on a compact space

This is the foundational theorem. It converts `sInf (Set.range E)` from an abstract order object into an achieved tropical energy level.

```lean
theorem tropicalPartitionCompact_attained
    (X : Type*)
    [TopologicalSpace X] [CompactSpace X] [Nonempty X]
    (E : X → ℝ)
    (hE : LowerSemicontinuous E) :
    ∃ x₀ : X, E x₀ = tropicalPartitionCompact X E
```

A stronger and often more usable equivalent form is:

```lean
theorem exists_isMinOn_tropicalPartitionCompact
    (X : Type*)
    [TopologicalSpace X] [CompactSpace X] [Nonempty X]
    (E : X → ℝ)
    (hE : LowerSemicontinuous E) :
    ∃ x₀ : X, ∀ x : X, E x₀ ≤ E x
```

Then derive attainment of `sInf` from this minimizer.

This theorem is the compact tropical analogue of finite `Finset.inf'_mem`.

---

### 2. Characterization as an actual minimum

```lean
theorem tropicalPartitionCompact_eq_iInf
    (X : Type*)
    [TopologicalSpace X] [CompactSpace X] [Nonempty X]
    (E : X → ℝ)
    (hE : LowerSemicontinuous E) :
    tropicalPartitionCompact X E = sInf (Set.range E)
```

This is definitional if you keep the above definition, so the real theorem should instead be the order characterization:

```lean
theorem tropicalPartitionCompact_le_iff
    (X : Type*)
    [TopologicalSpace X] [CompactSpace X] [Nonempty X]
    (E : X → ℝ)
    (hE : LowerSemicontinuous E)
    (a : ℝ) :
    tropicalPartitionCompact X E ≤ a ↔ ∃ x : X, E x ≤ a
```

or at least the one-sided consequences:

```lean
theorem tropicalPartitionCompact_le
    (X : Type*)
    [TopologicalSpace X] [CompactSpace X] [Nonempty X]
    (E : X → ℝ) (x : X) :
    tropicalPartitionCompact X E ≤ E x
```

and

```lean
theorem le_tropicalPartitionCompact_of_forall_le
    (X : Type*)
    [TopologicalSpace X] [CompactSpace X] [Nonempty X]
    (E : X → ℝ) {a : ℝ}
    (ha : ∀ x : X, a ≤ E x) :
    a ≤ tropicalPartitionCompact X E
```

These become the universal API for later entropy inequalities.

---

### 3. Translation invariance

This is the compact analogue of finite tropical free-energy shift symmetry.

```lean
theorem tropicalPartitionCompact_add_const
    (X : Type*)
    [TopologicalSpace X] [CompactSpace X] [Nonempty X]
    (E : X → ℝ) (c : ℝ) :
    tropicalPartitionCompact X (fun x => E x + c)
      = tropicalPartitionCompact X E + c
```

Also prove the left-add version if more convenient:

```lean
theorem tropicalPartitionCompact_const_add
    (X : Type*)
    [TopologicalSpace X] [CompactSpace X] [Nonempty X]
    (E : X → ℝ) (c : ℝ) :
    tropicalPartitionCompact X (fun x => c + E x)
      = c + tropicalPartitionCompact X E
```

This theorem says tropical entropy depends only on relative energy.

---

### 4. Duplication / pullback invariance under surjective maps

Finite duplication invariance says duplicating states without changing energies does not alter the tropical partition function. The correct compact-space version is surjective pullback invariance.

```lean
theorem tropicalPartitionCompact_pullback_surjective
    (X Y : Type*)
    [TopologicalSpace X] [CompactSpace X] [Nonempty X]
    [TopologicalSpace Y] [CompactSpace Y] [Nonempty Y]
    (f : Y → X)
    (hf : Function.Surjective f)
    (E : X → ℝ) :
    tropicalPartitionCompact Y (fun y => E (f y))
      = tropicalPartitionCompact X E
```

This is a profound structural theorem: tropical free energy is invariant under state-space refinements that do not create new energy values.

A stronger variant under `Set.range (fun y => E (f y)) = Set.range E` may be easiest.

---

### 5. Monotonicity under pointwise comparison

```lean
theorem tropicalPartitionCompact_mono
    (X : Type*)
    [TopologicalSpace X] [CompactSpace X] [Nonempty X]
    (E F : X → ℝ)
    (hEF : ∀ x, E x ≤ F x) :
    tropicalPartitionCompact X E ≤ tropicalPartitionCompact X F
```

This is the order-theoretic engine behind all information-processing inequalities.

---

### 6. Data-processing inequality for tropical channels

You need a mathematically clean notion of tropical channel. The right abstraction is a continuous map pushing latent states to observed states, with observed energy obtained by minimizing over fibers.

For a continuous map `f : X → Y`, define the pushed tropical energy:

```lean
def tropicalPushforwardEnergy
    (X Y : Type*)
    [TopologicalSpace X] [CompactSpace X]
    [TopologicalSpace Y]
    (f : X → Y) (E : X → ℝ) : Y → ℝ :=
  fun y => sInf (Set.range (fun x : {x // f x = y} => E x.1))
```

This dependent-fiber definition may be technically heavy. A more Lean-tractable alternative is to assume an energy `F : Y → ℝ` satisfying

```lean
hF : ∀ y : Y, F y = sInf (Set.range (fun x : {x // f x = y} => E x.1))
```

or at minimum

```lean
hF : ∀ x : X, F (f x) ≤ E x
```

Then prove the data-processing inequality:

```lean
theorem tropical_data_processing
    (X Y : Type*)
    [TopologicalSpace X] [CompactSpace X] [Nonempty X]
    [TopologicalSpace Y] [CompactSpace Y] [Nonempty Y]
    (f : X → Y)
    (E : X → ℝ)
    (F : Y → ℝ)
    (hF : ∀ x : X, F (f x) ≤ E x) :
    tropicalPartitionCompact Y F ≤ tropicalPartitionCompact X E
```

This is the correct compact tropical analogue of classical data processing: coarse-graining cannot increase minimum achievable energy.

A sharper theorem, if you can manage the fiber-minimization definition, is:

```lean
theorem tropical_data_processing_eq
    (X Y : Type*)
    [TopologicalSpace X] [CompactSpace X] [Nonempty X]
    [TopologicalSpace Y] [CompactSpace Y] [Nonempty Y]
    (f : X → Y)
    (hfcont : Continuous f)
    (E : X → ℝ)
    (hE : LowerSemicontinuous E)
    (F : Y → ℝ)
    (hF : ∀ y : Y, F y = sInf (Set.range (fun x : {x // f x = y} => E x.1))) :
    tropicalPartitionCompact Y F = tropicalPartitionCompact X E
```

But inequality first; equality later if fiber compactness and nonemptiness become manageable.

---

## Recommended theorem dependency graph

Build in this order:

1. `tropicalPartitionCompact_le`
2. `exists_isMinOn_tropicalPartitionCompact` or `tropicalPartitionCompact_attained`
3. `tropicalPartitionCompact_add_const`
4. `tropicalPartitionCompact_mono`
5. `tropicalPartitionCompact_pullback_surjective`
6. `tropical_data_processing`

This order minimizes technical debt.

---

## Proof strategy architecture

### Strategy A: Extreme value theorem first, then derive all order laws
This is likely the most promising path.

**Step 1.** Prove a compact lower-semicontinuous minimization theorem:
- Use Mathlib’s extreme value theorem infrastructure for compact sets and lower semicontinuous real-valued functions.
- If there is no exact theorem already in the catalog, derive it from compactness of sublevel sets or by converting lower semicontinuity of `E` into upper semicontinuity of `-E` where appropriate.

**Step 2.** Package the minimizer:
- Obtain `x₀` with `∀ x, E x₀ ≤ E x`.
- Show `E x₀ ∈ Set.range E`.
- Prove `E x₀ = sInf (Set.range E)` using `csInf_le` and `le_csInf`.

**Step 3.** Use this minimizer characterization to prove the structural laws:
- Translation invariance follows by comparing minimizers of `E` and `E + c`.
- Monotonicity is immediate from pointwise comparison.
- Data processing follows from `F (f x) ≤ E x`, then minimizing both sides.

**Why this is best:** it produces a robust API centered on actual minimizers, not just order-theoretic infima. That API will be reusable in tropical geometry and optimization.

---

### Strategy B: Pure order-theoretic `sInf` manipulation
This may yield shorter proofs for algebraic laws, though not for attainment.

**Step 1.** Work directly with `Set.range E` and lemmas about `sInf`.
- For translation invariance, show:
  `Set.range (fun x => E x + c) = (fun t => t + c) '' Set.range E`
  and use an `sInf_image` lemma if available, or prove the two inequalities manually.

**Step 2.** For pullback invariance under surjections:
- Show equality of ranges:
  `Set.range (fun y => E (f y)) = Set.range E`
  by surjectivity.
- Conclude equality of `sInf`s.

**Step 3.** For monotonicity:
- Use `∀ x, E x ≤ F x` to show every lower bound of `Set.range E` is a lower bound candidate for `Set.range F`, or derive directly from `sInf_le`.

**Why it is useful:** elegant and independent of topology for some results.  
**Why it is less complete:** it does not by itself prove attainment or the deepest topological statement.

---

### Strategy C: Compact-set minimization on `Set.univ`
This is a middle road if typeclass-based `CompactSpace` lemmas are awkward.

**Step 1.** Rephrase compactness as compactness of `Set.univ : Set X`.

**Step 2.** Use `IsCompact.exists_forall_le`-style lemmas if available in Mathlib for lower semicontinuous functions restricted to compact sets.

**Step 3.** Push all tropical theorems through the minimizer-on-`Set.univ` formulation.

**Why it may help:** many Mathlib topological optimization lemmas are stated on compact subsets rather than `CompactSpace` directly.

---

## Building on existing verified theorems

The catalog theorem most conceptually relevant is:

- `gibbs_inequality_finite` in `Tropical/NeuralNetworks/TropicalNNFrontier.lean`

Even if it is phrased probabilistically, use it as evidence that the project’s entropy layer already contains inequality technology. Your compact tropical data-processing theorem should be framed as the **zero-temperature/topological limit** of finite Gibbs inequalities. The conceptual bridge is:

- finite Gibbs entropy uses sums and convexity,
- tropical entropy uses minima and lower semicontinuity,
- compactness replaces finiteness,
- extreme-value attainment replaces finite argmin existence.

If there are finite-state tropical partition/entropy lemmas elsewhere in the codebase, explicitly mirror their names and statements with a `Compact` suffix. This will create a reusable parallel API.

The theorem
- `tropical_mirror_theorem : max a a = a`
is elementary, but philosophically it reminds us that idempotent algebra collapses multiplicity. Your pullback-surjective invariance theorem is the topological analogue of idempotence: duplicating states changes multiplicity, not minima.

---

## Cross-domain mathematical significance

This project opens several unexpected bridges:

### 1. Tropical geometry
On a compact tropical variety, any lower semicontinuous energy function defines a tropical partition value by global minimization. This turns tropical varieties into thermodynamic state spaces. The next step is to study whether piecewise-linear energies induce stratified minimizer loci and whether those loci behave functorially under tropical morphisms.

### 2. Idempotent analysis / Maslov dequantization
Your theorem package formalizes the slogan:
**“Compact tropical thermodynamics is just lower-semicontinuous optimization in the min-plus world.”**
This is exactly the kind of bridge that could let Mathlib host a serious fragment of idempotent measure theory.

### 3. Information theory
The data-processing inequality here is not probabilistic but order-theoretic. It suggests a new theory of **tropical mutual information** on compact spaces, where information loss is measured by deterioration of attainable minima under coarse-graining.

### 4. Optimization and control
Compact lower-semicontinuous energies are the native language of deterministic optimal control, viability theory, and robust optimization. This formalization could become a backbone for tropical Bellman principles on compact state spaces.

### 5. Mathematical physics
This is the zero-temperature limit of statistical mechanics on compact configuration spaces. If developed further, it could connect tropical free energy to ground-state selection and phase transitions in non-Archimedean or piecewise-linear settings.

---

## Lean-specific guidance

You should search Mathlib for theorems around:

- `LowerSemicontinuous`
- `UpperSemicontinuous`
- `IsCompact`
- `CompactSpace`
- `sInf`
- `csInf`
- existence of minima/maxima for semicontinuous functions on compact sets

Useful patterns may involve:
- proving `BddBelow (Set.range E)` using compactness plus attainment,
- or deriving attainment first and then avoiding delicate `csInf` side conditions,
- or using `OrderIso`/image lemmas for translation invariance.

If `sInf` over `ℝ` requires nonemptiness/bounded-below hypotheses in theorem statements, isolate those into helper lemmas rather than polluting all public theorems.

A very useful helper lemma would be:

```lean
lemma range_nonempty
    (X : Type*) [Nonempty X] (E : X → ℝ) :
    (Set.range E).Nonempty
```

and another:

```lean
lemma tropicalPartitionCompact_is_lower_bound
    (X : Type*)
    [TopologicalSpace X] [CompactSpace X] [Nonempty X]
    (E : X → ℝ)
    (x : X) :
    tropicalPartitionCompact X E ≤ E x
```

These will remove repeated boilerplate around `sInf`.

---

## Concrete minimal milestone

If the full channel formalism becomes technically heavy, at minimum complete this theorem package:

```lean
def tropicalPartitionCompact
    (X : Type*)
    [TopologicalSpace X] [CompactSpace X]
    (E : X → ℝ) : ℝ := sInf (Set.range E)

theorem tropicalPartitionCompact_attained
    (X : Type*)
    [TopologicalSpace X] [CompactSpace X] [Nonempty X]
    (E : X → ℝ)
    (hE : LowerSemicontinuous E) :
    ∃ x₀ : X, E x₀ = tropicalPartitionCompact X E

theorem tropicalPartitionCompact_add_const
    (X : Type*)
    [TopologicalSpace X] [CompactSpace X] [Nonempty X]
    (E : X → ℝ) (c : ℝ) :
    tropicalPartitionCompact X (fun x => E x + c)
      = tropicalPartitionCompact X E + c

theorem tropicalPartitionCompact_mono
    (X : Type*)
    [TopologicalSpace X] [CompactSpace X] [Nonempty X]
    (E F : X → ℝ)
    (hEF : ∀ x, E x ≤ F x) :
    tropicalPartitionCompact X E ≤ tropicalPartitionCompact X F

theorem tropicalPartitionCompact_pullback_surjective
    (X Y : Type*)
    [TopologicalSpace X] [CompactSpace X] [Nonempty X]
    [TopologicalSpace Y] [CompactSpace Y] [Nonempty Y]
    (f : Y → X) (hf : Function.Surjective f) (E : X → ℝ) :
    tropicalPartitionCompact Y (fun y => E (f y))
      = tropicalPartitionCompact X E

theorem tropical_data_processing
    (X Y : Type*)
    [TopologicalSpace X] [CompactSpace X] [Nonempty X]
    [TopologicalSpace Y] [CompactSpace Y] [Nonempty Y]
    (f : X → Y)
    (E : X → ℝ) (F : Y → ℝ)
    (hF : ∀ x : X, F (f x) ≤ E x) :
    tropicalPartitionCompact Y F ≤ tropicalPartitionCompact X E
```

If you finish these, you will have created the first topological tropical information theory layer in this codebase.

---

## What makes this revolutionary

The finite tropical entropy story says minima matter.  
This project proves that **topology controls how minima persist under observation, coarse-graining, and geometric realization**.

That is a field-opening statement. It means:
- tropical entropy can be defined on compact moduli spaces,
- tropical channels become geometric morphisms,
- data processing becomes a theorem of compact lower-semicontinuous optimization,
- tropical geometry acquires a rigorous thermodynamic semantics.

This is the seed of a new subject: **compact tropical information theory**.

---

## Application keywords

`tropical entropy`, `compact topological spaces`, `lower semicontinuity`, `extreme value theorem`, `idempotent analysis`, `Maslov dequantization`, `tropical geometry`, `data-processing inequality`, `coarse-graining`, `zero-temperature statistical mechanics`, `optimization on compact spaces`, `min-plus thermodynamics`, `topological channels`, `ground-state selection`

---

## Deliverables

1. Implement the definitions and theorem package in Lean 4 with minimal sorry usage.
2. Reuse or extend catalog theorems where natural, especially inequality infrastructure inspired by `gibbs_inequality_finite`.
3. Add module documentation explaining the finite-to-compact transition.
4. Produce a structured `FUTURE_DIRECTIONS.md` with **3–5 concrete breakthrough-level next steps**, for example:
   - tropical mutual information on compact spaces,
   - tropical entropy on compact tropical varieties,
   - fiberwise minimization and exact channel equalities,
   - idempotent measures and tropical large deviations,
   - compact tropical Bellman operators and control.

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

Research domain: Tropical
Research mode: prove
