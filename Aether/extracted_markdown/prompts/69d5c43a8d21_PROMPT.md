## Mode: prove

## Assignment: Conway’s Game of Life on Tropical Semirings: Emergent Complexity from Min-Plus

Aristotle, do not treat this as a playful reformulation of a cellular automaton. Treat it as the birth of a new interface between tropical algebra, symbolic dynamics, circuit complexity, and formal verification. The breakthrough is not “Life, but with min-plus notation.” The breakthrough is to identify a **tropical dynamical substrate** where local min-plus threshold rules support certified persistence, transport, memory, and universal computation — all inside Lean 4, with explicit witnesses.

Your mission is to define a mathematically coherent tropical cellular automaton inspired by Conway’s Life, prove its first structural theorems, and push far enough that the resulting library becomes a launchpad for tropical computation theory.

## Core Formalization Target

Work on finite rectangular tori first, e.g. grids `Fin m × Fin n`, so periodic boundary conditions eliminate edge pathology and make gliders definable as translation-equivariant periodic orbits.

A promising state space is binary occupancy `ℕ` or `Fin 2`, but the update rule should be *expressed through tropical primitives* (`min`, tropical addition, neighborhood aggregation). The key move is to encode “neighbor count” and thresholding through tropical formulas or tropicalized score functions rather than classical Boolean case splits.

### Suggested base definitions

Let:
- `Cell := Fin m × Fin n`
- `Config m n := Cell → ℕ`

Define the Moore neighborhood `N(x)` of size 8 on the torus.

Define a tropical neighborhood score such as
- a local energy `E : Config m n → Cell → ℕ`
- or a tropical support indicator after clipping to `{0,1}`.

One robust route is to restrict attention to `{0,1}`-valued configurations and define:
- tropical sum of active neighbors by ordinary `Nat` addition, but use min-plus formulas to express threshold comparison;
- or define a weighted min-plus local potential and update by argmin/threshold.

The point is not dogmatic purity. The point is a genuinely tropical rule whose behavior supports fixed points, propagating patterns, and gate simulation.

## Precise Theorem Targets

You should aim to formalize at least the following theorem cluster.

### 1. Tropical still lifes = fixed points

Define a tropical update operator
```lean
def tropicalLifeStep {m n : ℕ} (hₘ : 0 < m) (hₙ : 0 < n) :
    Config m n → Config m n
```

and a predicate
```lean
def IsStillLife {m n : ℕ} (hₘ : 0 < m) (hₙ : 0 < n) (c : Config m n) : Prop :=
  tropicalLifeStep hₘ hₙ c = c
```

Then prove a nontrivial classification/existence theorem, for example:

```lean
theorem tropical_block_still_life
    {m n : ℕ} (hₘ : 2 < m) (hₙ : 2 < n) :
    ∃ c : Config m n, IsStillLife (Nat.succ_pos _) (Nat.succ_pos _) c ∧
      ¬ Function.IsConstant c
```

Stronger and better:
```lean
theorem tropical_still_life_iff_local_fixed
    {m n : ℕ} (hₘ : 0 < m) (hₙ : 0 < n) (c : Config m n) :
    IsStillLife hₘ hₙ c ↔
      ∀ x, tropicalLocalRule c x = c x
```

This is foundational because it converts global dynamics into local tropical constraints and opens the door to SAT-style or optimization-style search inside Lean.

### 2. Existence of tropical gliders

Define torus translation:
```lean
def shiftConfig {m n : ℕ} : Fin m → Fin n → Config m n → Config m n
```

Define a glider as a non-fixed periodic orbit up to translation:
```lean
def IsGlider {m n : ℕ} (hₘ : 0 < m) (hₙ : 0 < n)
    (c : Config m n) : Prop :=
  ∃ k : ℕ, 0 < k ∧ ∃ dx : Fin m, ∃ dy : Fin n,
    (tropicalLifeStep hₘ hₙ)^[k] c = shiftConfig dx dy c ∧
    ¬ IsStillLife hₘ hₙ c
```

Then prove:

```lean
theorem exists_tropical_glider
    {m n : ℕ} (hₘ : 6 ≤ m) (hₙ : 6 ≤ n) :
    ∃ c : Config m n, IsGlider (Nat.succ_pos _) (Nat.succ_pos _) c
```

This is a breakthrough theorem because it certifies **transport of structured information** in a tropical local rule. In symbolic dynamics language, this is the first evidence that the tropical automaton supports nontrivial mobile defects rather than mere relaxation.

### 3. Lower bounds on pattern diversity

Define the orbit set up to time `T`:
```lean
def orbitPrefix {m n : ℕ} (hₘ : 0 < m) (hₙ : 0 < n)
    (T : ℕ) (c : Config m n) : Finset (Config m n)
```

Or more concretely, define the number of distinct iterates:
```lean
def orbitDiversity {m n : ℕ} (hₘ : 0 < m) (hₙ : 0 < n)
    (T : ℕ) (c : Config m n) : ℕ
```

Target theorem:
```lean
theorem orbitDiversity_lower_bound
    {m n : ℕ} (hₘ : 8 ≤ m) (hₙ : 8 ≤ n) :
    ∃ c : Config m n, ∃ T : ℕ, T > 0 ∧
      T ≤ orbitDiversity (Nat.succ_pos _) (Nat.succ_pos _) T c
```

Even better, prove a linear lower bound from a glider:
```lean
theorem glider_gives_linear_diversity
    {m n : ℕ} (hₘ : 6 ≤ m) (hₙ : 6 ≤ n) :
    ∃ c : Config m n, ∃ a b : ℕ,
      0 < a ∧
      ∀ T : ℕ, a * T ≤ orbitDiversity (Nat.succ_pos _) (Nat.succ_pos _) T c + b
```

This theorem is the first rigorous complexity statement: tropical local dynamics generate indefinitely many distinguishable macrostates.

### 4. Constructive circuit embedding / Turing completeness precursor

Full Turing completeness may be too large for one cycle unless you sharply modularize. The right first theorem is **uniform Boolean circuit simulation**.

Define a finite type of tropical gadgets:
```lean
inductive GateType | and | or | not
```

Define circuit semantics and an encoding into bounded patterns:
```lean
def encodesCircuit
    {m n : ℕ} (C : BooleanCircuit) (c : Config m n) : Prop
```

Then prove a bounded-time simulation theorem:
```lean
theorem tropicalLife_simulates_circuit
    (C : BooleanCircuit) :
    ∃ m n : ℕ, ∃ c : Config m n, ∃ t : ℕ,
      tropicalReadsOutput ((tropicalLifeStep (Nat.succ_pos _) (Nat.succ_pos _))^[t] c)
        = C.eval
```

If this is too ambitious in one shot, prove the compositional gate basis first:
```lean
theorem exists_tropical_and_gadget : ...
theorem exists_tropical_not_gadget : ...
theorem tropical_gadgets_compose : ...
```

Then state the corollary:
```lean
theorem tropicalLife_P_complete_by_circuit_value : ...
```

The revolutionary significance is immense: it places tropical algebraic dynamics into direct conversation with intrinsic universality, monotone circuit complexity, and physically inspired computation.

## Lean 4 Type Signature Suggestions

Use concrete finite grids:
```lean
abbrev Cell (m n : ℕ) := Fin m × Fin n
abbrev Config (m n : ℕ) := Cell m n → ℕ
```

Useful support predicates:
```lean
def binaryValued {m n : ℕ} (c : Config m n) : Prop :=
  ∀ x, c x = 0 ∨ c x = 1

def support {m n : ℕ} (c : Config m n) : Finset (Cell m n) := ...
```

Translation:
```lean
def shiftConfig {m n : ℕ} (dx : Fin m) (dy : Fin n) (c : Config m n) : Config m n := ...
```

Iterates:
```lean
open Function

#check Function.iterate
```

Diversity:
```lean
def orbitDiversity {m n : ℕ} (hₘ : 0 < m) (hₙ : 0 < n)
    (T : ℕ) (c : Config m n) : ℕ :=
  ((Finset.range (T + 1)).image (fun t => (tropicalLifeStep hₘ hₙ)^[t] c)).card
```

## How to Build on Catalog Theorems

Do not cite the catalog mechanically; absorb it into the architecture.

1. `tropical_plus_distributes_over_min`  
   Use this to normalize local update expressions when the neighborhood score is defined by a min-plus polynomial. This is especially useful if you define birth/survival via a tropical energy comparison:
   - expand weighted neighborhood potentials,
   - push tropical addition through minima,
   - derive local rule simplifications needed for fixed-point proofs.

2. `tropical_min_associative`  
   Essential for canonical reassociation of neighborhood minima over 8 neighbors. Use it to prove that your local energy is independent of the order in which the neighborhood is aggregated, so the rule is well-defined and proof automation can rewrite consistently.

3. `tropical_and_bound`  
   This is your bridge to logic. If your gate gadgets are encoded by tropical constraints, use this theorem to control conjunction-like gadget composition and prove that signal integrity survives local interactions.

4. `closure_mdl_bound_via_fixed_point` and `closure_compression_factorizes_through_fixed_points`  
   These are unexpectedly powerful here. Once still lifes are identified as fixed points, you can derive **description-length or closure bounds** for stable tropical patterns. This gives a second layer of significance: not only do still lifes exist, they are compression-theoretic attractors. Use this to formulate a theorem that fixed tropical patterns admit bounded closure complexity.

A speculative but exciting theorem:
```lean
theorem tropical_still_life_has_bounded_closure_description
    {m n : ℕ} (hₘ : 0 < m) (hₙ : 0 < n) (c : Config m n)
    (hc : IsStillLife hₘ hₙ c) :
    ∃ K, closureDescriptionLength c ≤ K
```
if the closure machinery in the catalog can be instantiated on finite configurations.

## Proof Strategy Paths

### Strategy A: Finite explicit witness + local verification
Most promising for the first cycle.

1. Define a specific tropical rule on binary configurations with local min-plus score.
2. Construct explicit witness patterns:
   - a `2 × 2` block for still life,
   - a small translating motif for glider,
   - elementary wire/gate gadgets for circuit simulation.
3. Prove behavior by exhaustive local neighborhood analysis, reduced to finitely many cases.

Why this is promising:
- Lean loves finite explicit witnesses.
- Torus grids eliminate infinite-set headaches.
- It yields immediately formalizable, nontrivial existence theorems.

### Strategy B: Symbolic dynamics via translation-equivariant local maps
Best for deeper general theorems after witnesses exist.

1. Prove `tropicalLifeStep` commutes with shifts:
   ```lean
   theorem tropicalLifeStep_commutes_shift ...
   ```
2. Characterize gliders as periodic points modulo the translation action.
3. Deduce orbit-diversity lower bounds from nontrivial translation periods and injectivity of shifted supports.

Why this matters:
- It turns ad hoc glider proofs into structural dynamical theory.
- It opens a route to entropy-like invariants and formal symbolic dynamics in Lean.

### Strategy C: Circuit simulation through tropical gadget semantics
Most ambitious; use after A establishes expressive patterns.

1. Define signal-carrying trajectories as periodic mobile motifs.
2. Build collision gadgets implementing `AND`, `OR`, `NOT` using tropical local score inequalities.
3. Prove compositional correctness by induction on circuit structure.

Why this is revolutionary:
- It upgrades “interesting automaton” into “universal computational medium.”
- It creates a bridge from tropical algebra to complexity-theoretic universality.

## Cross-Domain Connections You Must Exploit

### Tropical geometry ↔ cellular automata
The local rule should be viewed as a tropical polynomial or tropical threshold map. This reframes automaton evolution as iteration of piecewise-linear algebraic operators.

### Symbolic dynamics ↔ computational complexity
Gliders are not just patterns; they are carriers of symbolic information. Once you prove transport and collision semantics, you are doing formal complexity theory inside a tropical dynamical system.

### Fixed-point theory ↔ compression / MDL
Still lifes are fixed points. The catalog’s closure/fixed-point theorems suggest a compression-theoretic interpretation: stable structures are low-description attractors. This is an unexpected and powerful narrative.

### Semiring computation ↔ unconventional physics
Min-plus dynamics model shortest paths, action principles, and zero-temperature limits. A tropical Game of Life could become a toy model for emergent structures in variational discrete physics.

### Formal methods ↔ universality
A Lean-certified proof of gliders and circuit simulation would be a landmark example of machine-checked universality in an algebraically nonclassical medium.

## Application Keywords

tropical cellular automata; min-plus dynamics; symbolic dynamics; glider existence; fixed points; circuit simulation; Turing completeness; Boolean gadget embedding; orbit diversity; entropy lower bounds; semiring computation; tropical logic; formal verification; Lean 4; Mathlib; unconventional computation; complexity from local rules; compression via fixed points; MDL dynamics

## Concrete Milestones

1. Define `Cell`, `Config`, neighborhood, translation, and `tropicalLifeStep`.
2. Prove locality and shift-equivariance.
3. Construct one nonconstant still life and prove fixed-point correctness.
4. Construct one glider and prove periodicity up to translation.
5. Define orbit diversity and derive a lower bound from the glider.
6. Formalize at least one logic gadget (`AND` or `NOT`) and prove correctness.
7. If full universality is too large, prove **uniform circuit embeddability for a gate basis fragment**.

## Nontriviality Constraints

Do not “prove” complexity by choosing a rule designed to hardcode arbitrary time dependence. The rule must be:
- local,
- translation-invariant,
- time-homogeneous,
- genuinely expressible through min-plus/tropical operations.

Do not settle for existential tautologies over tiny grids unless the witness exhibits real structure.
Do not stop at fixed points: mobile patterns are essential.
Do not state Turing completeness without a compositional simulation theorem.

## Deliverables

Produce:
- Lean definitions for the tropical automaton and its dynamics,
- at least 2 machine-checked nontrivial theorems from the cluster above,
- one theorem explicitly using a catalog theorem as a proof ingredient,
- comments explaining the intended universality architecture,
- and a structured `FUTURE_DIRECTIONS.md` containing 3–5 concrete breakthrough next steps.

## Required FUTURE_DIRECTIONS.md

You must include 3–5 specific next directions such as:
1. a tropical Garden-of-Eden theorem or surjectivity/injectivity dichotomy,
2. entropy or growth-rate invariants for tropical automata,
3. reversible tropical automata and conserved min-plus quantities,
4. universality on infinite grids via finite-support embeddings,
5. categorical semantics of tropical local rules as semiring transducers.

Build something that feels impossible until it is formalized.

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

Research domain: Computation
Research mode: prove
