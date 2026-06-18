## Assignment: Thermodynamic Computation via Tropical Landauer's Principle

Mode: **prove**

Aristotle, do not treat this as an analogy exercise. Turn “thermodynamics of computation” into a formally certified theorem schema in Lean 4, with a sharp bridge between **information erasure**, **idempotent/tropical entropy**, and **circuit depth as free energy**. The goal is to create a new formal language in which computational irreversibility is literally an energy lower bound, and tropical circuit complexity becomes a thermodynamic invariant.

This is potentially field-opening because it would give a mathematically precise, machine-verified framework where:
- **Landauer lower bounds** are proved in an idempotent algebraic setting,
- **free energy** is recast as a min-plus optimization functional,
- **circuit depth** is certified as a thermodynamic cost,
- and complexity theory, tropical geometry, and statistical physics become interoperable inside Lean.

Do not aim for a metaphor. Aim for a theorem package.

---

## Core Breakthrough Targets

You should formalize a minimal but nontrivial tropical thermodynamics framework and prove at least one theorem of each of the following two types:

1. **Erasure costs nonzero tropical entropy/free energy**
2. **Min-plus free energy lower bounds, and in a canonical model equals, circuit depth**

The strongest version is an equality theorem for a carefully chosen canonical circuit semantics, with lower-bound theorems in greater generality.

---

## Precise Mathematical Program

### 1. Tropical Landauer lower bound for erasure

Introduce a finite-state computational model where an “erasure operation” sends at least two distinguishable inputs to one output. On a finite state space, define tropical entropy by support cardinality:
- for a finite set `S`, define `Hₜ(S) = log (|S| : ℝ)`,
- and define erased entropy of a map `f : α → β` on a finite domain by the maximal support collapse
  `Δₜ(f) = Hₜ(univ) - Hₜ(range f)`.

Then prove that any genuinely non-injective operation has strictly positive tropical entropy cost, and binary erasure costs at least `log 2`. The physically normalized form multiplies by `k*T`.

A precise Lean-friendly theorem target is:

```lean
theorem tropical_landauer_binary
  {α β : Type*} [Fintype α] [Fintype β] [DecidableEq α] [DecidableEq β]
  (f : α → β)
  (h_noninj : ¬ Function.Injective f) :
  Real.log 2 ≤ Real.log (Fintype.card α : ℝ) - Real.log (Fintype.card (Set.range f) : ℝ)
```

This statement may need a cardinal lower-bound hypothesis if noninjective alone is too weak for arbitrary finite domains. A more robust theorem is:

```lean
theorem tropical_landauer_fiber
  {α β : Type*} [Fintype α] [Fintype β] [DecidableEq α] [DecidableEq β]
  (f : α → β) (m : ℕ)
  (hm : 2 ≤ m)
  (hfiber : ∃ y : β, m ≤ Fintype.card {x : α // f x = y}) :
  Real.log m ≤ Real.log (Fintype.card α : ℝ) - Real.log (Fintype.card (Set.range f) : ℝ)
```

This is the right theorem mathematically: if one output class has multiplicity at least `m`, then the support loss is at least `log m`. The binary Landauer principle is the `m = 2` corollary.

Then define a physical cost functional:

```lean
def landauerCost (k T : ℝ) {α β : Type*} [Fintype α] [Fintype β]
    [DecidableEq α] [DecidableEq β] (f : α → β) : ℝ :=
  k * T * (Real.log (Fintype.card α : ℝ) - Real.log (Fintype.card (Set.range f) : ℝ))
```

and prove:

```lean
theorem landauer_cost_lower_bound
  {α β : Type*} [Fintype α] [Fintype β] [DecidableEq α] [DecidableEq β]
  (k T : ℝ) (hk : 0 ≤ k) (hT : 0 ≤ T)
  (f : α → β)
  (h_noninj : ¬ Function.Injective f) :
  k * T * Real.log 2 ≤ landauerCost k T f
```

You may need a strengthened hypothesis such as `2 ≤ Fintype.card α` and a proof that noninjective on a finite domain implies `card (range f) ≤ card α - 1`, hence
`card α / card (range f) ≥ 2 / 1` in the two-point collapse model, or else prove the fiber version first and derive the binary case only when an actual two-to-one collapse exists. The fiber theorem is the cleanest foundation.

### 2. Tropical free energy as circuit depth

You already have a crucial catalog theorem:

- `erasure_depth_lower_bound` in `Physics/TropicalThermodynamics/Circuit.lean`

This should become the anchor of a more conceptual theorem: define a min-plus free energy of a circuit by assigning a local nonnegative cost to each layer/gate and taking tropical composition as additive accumulation. Then prove that, for the canonical unit-cost layered semantics, free energy is exactly depth.

A concrete formal target:

```lean
structure TropicalCircuit where
  depth : ℕ
  -- add whatever existing fields the catalog file already provides

def tropicalFreeEnergy (C : TropicalCircuit) : ℝ :=
  C.depth
```

This tautological definition is not acceptable as the endpoint. Instead, define free energy compositionally from gates/layers and prove equality with `depth`.

For example, if circuits are built from layers:
```lean
inductive TropicalGateCost
| erase | copy | minGate | addGate

def gateCost : TropicalGateCost → ℝ
| .erase => 1
| .copy => 0
| .minGate => 1
| .addGate => 1
```

and if a circuit is represented as a list of layers:
```lean
def layerCost (L : List TropicalGateCost) : ℝ :=
  if L = [] then 0 else 1

def tropicalFreeEnergy : List (List TropicalGateCost) → ℝ
| [] => 0
| L :: Cs => layerCost L + tropicalFreeEnergy Cs
```

then prove:

```lean
theorem tropical_free_energy_eq_depth
  (C : List (List TropicalGateCost)) :
  tropicalFreeEnergy C = C.length
```

for nonempty-layer normalization, or a variant counting only active layers. Then connect this to the existing circuit object and prove a transfer theorem:

```lean
theorem circuit_free_energy_eq_depth
  (C : TropicalCircuit) :
  tropicalFreeEnergyModel C = C.depth
```

where `tropicalFreeEnergyModel` is your compositional definition.

The lower-bound form, which is more general and likely easier to align with the catalog theorem, is:

```lean
theorem tropical_free_energy_depth_lower_bound
  (C : TropicalCircuit) :
  (C.depth : ℝ) ≤ tropicalFreeEnergyModel C
```

and then seek hypotheses under which equality holds.

---

## Why This Would Be a Breakthrough

If you certify these theorems, you create the first Lean-native bridge among:

- **Landauer thermodynamics**: irreversible logical operations cost entropy/energy,
- **tropical/idempotent analysis**: entropy becomes support-compression in min-plus form,
- **circuit complexity**: depth is recast as a thermodynamic free-energy budget,
- **quantum-information-style lower bounds**: imported structurally via entropy/depth tradeoffs.

This opens a new area: **formal tropical statistical mechanics of computation**. Once the primitives exist, one can study:
- reversible vs irreversible complexity classes,
- energy-aware circuit lower bounds,
- tropical analogues of mutual information and data processing,
- certified complexity-energy tradeoffs for classical and quantum-inspired circuits.

This is exactly the kind of unexpected bridge that can generate a new line of mechanized mathematics.

---

## Lean 4 Type Signature Targets

You asked for precise theorem statements with Lean signatures. Here are the main targets to implement or adapt.

### A. Support-collapse entropy theorem

```lean
def tropicalEntropy (n : ℕ) : ℝ := Real.log n

theorem tropical_entropy_monotone
  {a b : ℕ} (h : a ≤ b) :
  tropicalEntropy a ≤ tropicalEntropy b
```

Likely via monotonicity of `Real.log` on nonnegative reals after coercion.

### B. Fiber-counting Landauer theorem

```lean
theorem card_range_le_card_domain_div_fiber
  {α β : Type*} [Fintype α] [Fintype β] [DecidableEq α] [DecidableEq β]
  (f : α → β) (m : ℕ)
  (hm : 1 ≤ m)
  (hfiber : ∀ y ∈ Set.range f, m ≤ Fintype.card {x : α // f x = y}) :
  Fintype.card (Set.range f) * m ≤ Fintype.card α
```

This is a counting lemma. A weaker existential-fiber version is easier but gives weaker conclusions. A uniform-fiber version yields a clean quotient estimate.

From it derive:

```lean
theorem tropical_landauer_uniform_fiber
  {α β : Type*} [Fintype α] [Fintype β] [DecidableEq α] [DecidableEq β]
  (f : α → β) (m : ℕ)
  (hm : 2 ≤ m)
  (hfiber : ∀ y ∈ Set.range f, m ≤ Fintype.card {x : α // f x = y}) :
  Real.log m ≤ Real.log (Fintype.card α : ℝ) - Real.log (Fintype.card (Set.range f) : ℝ)
```

This theorem is mathematically elegant and likely easiest to prove cleanly.

### C. Binary erasure corollary

```lean
theorem tropical_landauer_binary_uniform
  {α β : Type*} [Fintype α] [Fintype β] [DecidableEq α] [DecidableEq β]
  (f : α → β)
  (hfiber2 : ∀ y ∈ Set.range f, 2 ≤ Fintype.card {x : α // f x = y}) :
  Real.log 2 ≤ Real.log (Fintype.card α : ℝ) - Real.log (Fintype.card (Set.range f) : ℝ)
```

### D. Thermodynamic normalization

```lean
def thermalLandauerCost (k T : ℝ) (n r : ℕ) : ℝ :=
  k * T * (Real.log (n : ℝ) - Real.log (r : ℝ))

theorem thermal_landauer_cost_nonneg
  (k T : ℝ) (hk : 0 ≤ k) (hT : 0 ≤ T) {r n : ℕ} (h : r ≤ n) :
  0 ≤ thermalLandauerCost k T n r
```

### E. Free energy/depth theorem

For a canonical layered model:

```lean
def layerFreeEnergy {α : Type*} (L : List α) : ℝ :=
  if L = [] then 0 else 1

def computationFreeEnergy {α : Type*} : List (List α) → ℝ
| [] => 0
| L :: Cs => layerFreeEnergy L + computationFreeEnergy Cs

theorem computationFreeEnergy_eq_activeDepth
  {α : Type*} (C : List (List α))
  (hactive : ∀ L ∈ C, L ≠ []) :
  computationFreeEnergy C = C.length
```

Then instantiate with your tropical gate alphabet and connect to `TropicalCircuit`.

---

## Proof Strategy Architecture

You asked for 2–3 proof strategy steps. Here are three distinct routes.

### Strategy A: Finite counting + logarithmic monotonicity
This is the most promising for the Landauer theorem.

1. Prove a counting inequality:
   if every fiber over the range has size at least `m`, then
   `card(range f) * m ≤ card(α)`.
2. Convert this multiplicative inequality to a logarithmic one:
   `log m + log card(range f) ≤ log card(α)`.
3. Rearrange to obtain
   `log m ≤ log card(α) - log card(range f)`.

Why this is best:
- It uses only finite combinatorics and standard real inequalities.
- It is robust in Lean.
- It gives a precise theorem stronger than “noninjective implies cost.”

Key Lean ingredients:
- `Fintype.card`
- `Set.range`
- finite fiber subtypes `{x : α // f x = y}`
- monotonicity of `Real.log`
- positivity side conditions for logs

### Strategy B: Partition-theoretic entropy proof
This is conceptually deeper and useful for future generalization.

1. View `f` as inducing a partition of the finite domain into fibers.
2. Define tropical entropy of a partition by support count of blocks.
3. Show erasure corresponds to coarsening the partition, hence reducing support entropy.
4. Quantify the drop by the minimal block size, recovering the `log m` lower bound.

Why pursue it:
- This is the right abstraction for future tropical mutual information and data processing.
- It will scale to compositions of erasures and to categorical semantics.

Why it is secondary:
- More definitions, more infrastructure.
- Harder to get to a first theorem than Strategy A.

### Strategy C: Compositional circuit semantics for free energy
This is the right route for the depth/free-energy theorem.

1. Define a layered circuit semantics where each active layer contributes unit min-plus energy.
2. Prove by induction on the layer list that free energy equals active depth.
3. Transfer this theorem to the existing `TropicalCircuit` structure by exhibiting a semantics-preserving encoding or by proving compatibility with `erasure_depth_lower_bound`.

Why this is best for the second theorem:
- It turns equality into a structural induction statement.
- It gives a reusable compositional model.
- It sets up later generalizations to weighted gates and complexity tradeoffs.

---

## How to Build on the Catalog Theorems

You were explicitly given several verified theorems. Use them strategically, not decoratively.

### 1. `erasure_depth_lower_bound`
File: `Physics/TropicalThermodynamics/Circuit.lean`

This is the most important seed. Your task is to reinterpret it as a thermodynamic lower bound. If it already states that erasure forces depth, prove a corollary of the form:

```lean
theorem erasure_free_energy_lower_bound
  (C : TropicalCircuit) :
  (erasureCostOfCircuit C : ℝ) ≤ tropicalFreeEnergyModel C
```

and combine with the catalog theorem to show:
- erasure implies positive depth,
- positive depth implies positive free energy,
- hence erasure has nonzero thermodynamic cost.

This is the bridge theorem that converts an existing complexity lower bound into a thermodynamic law.

### 2. `depth_complexity_tradeoff_bounded`
File: `Physics/Quantum/CircuitHopfAlgebra.lean`

Use this as cross-domain evidence that depth is already functioning as a conserved or constrained resource. The key move is not to import quantum details, but to prove an abstract transfer principle:
if a circuit invariant is lower bounded by depth, and tropical free energy equals or lower bounds depth, then complexity is lower bounded by free energy.

A theorem template:

```lean
theorem complexity_bounded_by_free_energy
  (f : BoundedCircuitCharacter) (n : ℕ) :
  someComplexityMeasure f n ≤ tropicalizedFreeEnergyOfCharacter f n
```

Even if you cannot fully instantiate it this cycle, formulate the interface.

### 3. `entanglement_entropy_bound`
File: `Physics/PauliClosureFoundations.lean`

This suggests a cross-pollination with entropy inequalities. The insight: tropical entropy here is not Shannon/von Neumann entropy, but a support/log-cardinality entropy. Prove comparison lemmas on finite uniform states:
for uniform distributions on finite supports, Shannon entropy equals log-cardinality entropy. This gives a formal bridge between your tropical entropy and standard information-theoretic entropy.

Possible theorem:

```lean
theorem uniform_shannon_eq_log_card
  (n : ℕ) :
  shannonEntropyOfUniform n = Real.log n
```

Then your Landauer theorem becomes a tropical-shadow version of the classical statement.

### 4. `depth_log_bound`
File: `Physics/Quantum/MoonshotQuantum.lean`

This is a strong signal that logarithms already control depth in another domain. Use it to motivate a theorem comparing support compression and depth scaling. Even a formal remark/lemma showing both are governed by `Real.log` creates a genuine cross-domain architecture.

### 5. `cech_complexity_bound`
File: `Physics/Quantum/CohomologicalContextuality.lean`

This opens a topological route: support collapse can be reinterpreted as loss of distinguishable regions/nerve complexity. Even if not fully proved now, define a future interface where erasure reduces combinatorial topology, and depth/free energy bounds Čech complexity. This is not fluff: it sets up a tropical-topological thermodynamics program.

---

## Cross-Domain Connections You Must Explicitly Develop

At least one of these should appear as a theorem, definition, or formal remark.

### A. Information theory
Classical Landauer is information-theoretic. Your tropical entropy `log |support|` is exactly Shannon entropy on uniform finite supports. This gives a rigorous bridge:
- tropical entropy = max-entropy / uniform Shannon entropy,
- support compression = information erasure,
- Landauer cost = entropy loss lower bound.

Application keywords:
`information erasure`, `support entropy`, `Shannon entropy`, `max-entropy`, `data processing`

### B. Complexity theory
Depth as free energy says irreversible computation consumes a thermodynamic resource measured by sequentiality. This can become a lower-bound technology:
- any function requiring depth requires free energy,
- reversible computations minimize dissipation,
- thermodynamic semantics may distinguish complexity classes.

Application keywords:
`circuit depth`, `lower bounds`, `irreversibility`, `reversible computation`, `complexity-energy tradeoff`

### C. Tropical geometry / idempotent analysis
Min-plus free energy is naturally a tropical potential. Circuits become tropical morphisms; composition is additive; optimization is min-plus linearization. This suggests a tropical statistical mechanics.

Application keywords:
`tropical semiring`, `idempotent analysis`, `min-plus algebra`, `free energy`, `optimization semantics`

### D. Quantum analogy
Use the catalog’s entropy/depth results to position tropical thermodynamics as a classical shadow of quantum resource theories:
- entanglement entropy bounds resemble support entropy bounds,
- depth/resource tradeoffs have a shared formal skeleton.

Application keywords:
`resource theory`, `entropy bounds`, `quantum circuits`, `thermodynamic computation`, `categorical semantics`

---

## Recommended File Architecture

You were not given a fixed file, so create a clean new module stack, for example:

- `Physics/TropicalThermodynamics/Landauer.lean`
- `Physics/TropicalThermodynamics/FreeEnergy.lean`
- `Physics/TropicalThermodynamics/Bridge.lean`

Suggested responsibilities:

### `Landauer.lean`
- define tropical entropy on finite supports/cardinalities
- prove counting lemmas for fibers and ranges
- prove `tropical_landauer_uniform_fiber`
- prove `thermal_landauer_cost_nonneg`
- derive binary corollaries

### `FreeEnergy.lean`
- define a canonical layered tropical computation model
- define compositional free energy
- prove free energy equals/lower bounds active depth

### `Bridge.lean`
- import `Circuit.lean`
- connect `erasure_depth_lower_bound` to free energy
- state and prove the thermodynamic lower bound for erasing circuits
- add comparison remarks with quantum depth/entropy theorems

---

## Minimal Nontrivial Deliverables

At minimum, produce all of the following:

1. A clean formal definition of tropical entropy on finite supports or finite state spaces.
2. A proved Landauer-style theorem of the form:
   support collapse by factor `m` implies entropy loss at least `log m`.
3. A compositional definition of min-plus free energy for a canonical circuit model.
4. A proof that in that model free energy equals or lower bounds depth.
5. A bridge theorem using `erasure_depth_lower_bound`.

If equality with the existing `TropicalCircuit` object is too difficult, prove:
- equality in your canonical model,
- lower-bound transfer to the catalog model.

That is already a serious result.

---

## Anti-Triviality Requirements

Avoid these failure modes:

- Defining free energy to be depth by fiat and calling the equality theorem proved.
- Stating “noninjective implies log 2 cost” without sufficient hypotheses.
- Using `Real.log` without proving positivity side conditions.
- Producing only toy theorems on `Nat` with no bridge to actual circuit semantics.

The theorem must have genuine mathematical content: a counting argument, an entropy inequality, or a structural induction over computation.

---

## Concrete First Attack Plan

1. Prove finite counting lemmas for fibers and ranges.
2. Derive a logarithmic support-collapse theorem.
3. Package it as tropical Landauer cost.
4. Define a layered free-energy semantics.
5. Prove free energy-depth equality by induction.
6. Connect to `erasure_depth_lower_bound`.
7. Add one cross-domain theorem or formal remark relating tropical entropy to uniform Shannon entropy or complexity tradeoffs.

---

## Application Keywords

thermodynamic computation, Landauer principle, tropical entropy, min-plus free energy, idempotent analysis, support compression, irreversible computation, circuit depth lower bounds, information erasure, complexity-energy tradeoff, tropical statistical mechanics, formalized physics, Lean 4, Mathlib, resource theory

---

## Required Final Artifacts

You must produce:

- Lean 4 code with minimized sorry usage
- a structured `FUTURE_DIRECTIONS.md`

The `FUTURE_DIRECTIONS.md` must contain **3–5 concrete breakthrough next steps**, such as:
1. tropical mutual information and a formal data processing inequality,
2. reversible computation as zero-dissipation tropical dynamics,
3. weighted gate energies and lower bounds for Boolean function classes,
4. categorical semantics of thermodynamic circuits,
5. comparison theorems between tropical entropy and von Neumann/Shannon entropy on finite models.

Be specific. The next cycle depends on it.

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

Research domain: Physics
Research mode: prove
