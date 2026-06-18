## Assignment: Tropical Origami: Min-Plus Fold Structures and Rigid Origami Classification

Mode: **prove**

Aristotle, do not treat this as a decorative analogy between origami and tropical geometry. Turn it into a genuine formal bridge theorem: a min-plus theory of rigid foldability in which crease compatibility becomes tropical convexity, self-stress becomes tropical equilibrium, and canonical deployable patterns emerge as optimization minima. The breakthrough is not “origami inspired by tropical ideas”; it is a certified equivalence between discrete rigidity data and tropical linear feasibility.

You should aim to define a mathematically clean finite combinatorial model of a crease pattern and then prove theorems that are nontrivial, formalizable in Lean 4, and strong enough to seed an entirely new library on tropical rigidity.

Build on the catalog where useful, but do not force irrelevant dependencies. The listed tropical theorems suggest a house style: min-plus inequalities, existence/uniqueness statements, and asymptotic tropicalization bounds. Use them as proof motifs, not as superficial citations.

## Core Formal Vision

A finite origami crease pattern should be encoded by:
- a finite set of creases indexed by `Fin n`,
- a finite set of local vertex constraints indexed by `Fin m`,
- a real matrix `A : Matrix (Fin m) (Fin n) ℝ` recording incidence or angle-weight data,
- a tropical state vector `x : Fin n → ℝ` representing crease activation / fold height / valuation of fold angle,
- a right-hand side `b : Fin m → ℝ` representing local compatibility thresholds.

The first major theorem should show that the feasible fold-state space is an intersection of tropical hyperplanes or tropical halfspaces, hence tropically convex. The second major theorem should identify rigid foldability with the existence of a tropical stress vector satisfying a balancing condition. The third should isolate a canonical optimization principle and prove uniqueness of the Miura-type minimizer in a precise rectangular lattice model.

## Precise Theorem Targets

You will likely need to introduce definitions first. Here is a formalization target that is both precise and realistically Leanable.

### 1. Tropical crease feasibility as a tropical hyperplane arrangement

Define the tropical row evaluation:
```lean
def tropRowEval {m n : ℕ} (A : Matrix (Fin m) (Fin n) ℝ) (b : Fin m → ℝ)
    (i : Fin m) (x : Fin n → ℝ) : ℝ :=
  Finset.inf' Finset.univ Finset.univ_nonempty (fun j : Fin n => A i j + x j - b i)
```
or, more implementation-friendly, define the row minima set:
```lean
def tropRowVals {m n : ℕ} (A : Matrix (Fin m) (Fin n) ℝ) (b : Fin m → ℝ)
    (i : Fin m) (x : Fin n → ℝ) : Finset ℝ :=
  Finset.univ.image (fun j : Fin n => A i j + x j - b i)
```
and say that row `i` is tropically satisfied if the minimum is attained at least twice.

Then define:
```lean
def IsTropicallyFeasible {m n : ℕ} (A : Matrix (Fin m) (Fin n) ℝ) (b : Fin m → ℝ)
    (x : Fin n → ℝ) : Prop :=
  ∀ i : Fin m, ∃ j₁ ≠ j₂, A i j₁ + x j₁ - b i = A i j₂ + x j₂ - b i ∧
    ∀ j : Fin n, A i j₁ + x j₁ - b i ≤ A i j + x j - b i
```

Target theorem:
```lean
theorem creasePattern_feasible_is_tropical_arrangement
    {m n : ℕ} (A : Matrix (Fin m) (Fin n) ℝ) (b : Fin m → ℝ) :
    ∃ H : Fin m → Set (Fin n → ℝ),
      (∀ i, ∃ c : Fin n → ℝ,
        H i = {x | ∃ j₁ ≠ j₂,
          c j₁ + x j₁ = c j₂ + x j₂ ∧
          ∀ j, c j₁ + x j₁ ≤ c j + x j}) ∧
      {x | IsTropicallyFeasible A b x} = ⋂ i, H i
```

This theorem says exactly: the valid fold-state space is an intersection of tropical hyperplanes, i.e. a tropical hyperplane arrangement. This is the correct finite theorem to prove first. It is precise, nontrivial, and field-opening because it converts origami compatibility into tropical geometry.

### 2. Rigid foldability as tropical stress equilibrium

Introduce a tropical stress vector on constraints:
```lean
def IsTropicalStressEquilibrium {m n : ℕ}
    (A : Matrix (Fin m) (Fin n) ℝ) (σ : Fin m → ℝ) : Prop :=
  ∀ j : Fin n, ∃ i₁ ≠ i₂,
    σ i₁ + A i₁ j = σ i₂ + A i₂ j ∧
    ∀ i : Fin m, σ i₁ + A i₁ j ≤ σ i + A i j
```

Then define a combinatorial notion of rigid foldability. If full kinematic rigidity is too hard to formalize initially, define a finite surrogate:
```lean
def IsRigidFoldable {m n : ℕ} (A : Matrix (Fin m) (Fin n) ℝ) : Prop :=
  ∃ x : Fin n → ℝ, IsTropicallyFeasible A (fun _ => 0) x ∧
    ∃ σ : Fin m → ℝ, IsTropicalStressEquilibrium A σ
```
Then prove at least one direction as a substantial theorem and, if possible, prove equivalence under a structural hypothesis such as full support / genericity / balanced incidence.

Target theorem:
```lean
theorem rigidFoldability_of_tropical_stress
    {m n : ℕ} (A : Matrix (Fin m) (Fin n) ℝ)
    (hσ : ∃ σ : Fin m → ℝ, IsTropicalStressEquilibrium A σ) :
    IsRigidFoldable A
```

Ambitious equivalence target:
```lean
theorem rigidFoldability_iff_tropical_stress
    {m n : ℕ} (A : Matrix (Fin m) (Fin n) ℝ)
    (hgen : GenericCreaseMatrix A) :
    IsRigidFoldable A ↔ ∃ σ : Fin m → ℝ, IsTropicalStressEquilibrium A σ
```

This is the breakthrough theorem. It is the origami analogue of Maxwell-Cremona seen through min-plus algebra.

### 3. Tropical linear programming classification of rigid bases

Define the feasible set and tropical objective:
```lean
def foldEnergy {n : ℕ} (w x : Fin n → ℝ) : ℝ :=
  Finset.sup' Finset.univ Finset.univ_nonempty (fun j => w j + x j) -
  Finset.inf' Finset.univ Finset.univ_nonempty (fun j => w j + x j)
```
or a simpler linear objective if sup/inf creates friction:
```lean
def linearFoldEnergy {n : ℕ} (w x : Fin n → ℝ) : ℝ :=
  ∑ j, w j * x j
```

Then classify rigid bases as extreme points / minimal supports of tropical feasibility:
```lean
def IsRigidBasis {m n : ℕ} (A : Matrix (Fin m) (Fin n) ℝ) (B : Finset (Fin n)) : Prop :=
  ∃ x : Fin n → ℝ, IsTropicallyFeasible A (fun _ => 0) x ∧
    (∀ j ∉ B, x j = 0) ∧
    Minimal (fun S => ∃ y, IsTropicallyFeasible A (fun _ => 0) y ∧ ∀ j ∉ S, y j = 0) B
```

Target theorem:
```lean
theorem rigidBases_classified_by_tropical_LP
    {m n : ℕ} (A : Matrix (Fin m) (Fin n) ℝ) :
    ∀ B : Finset (Fin n),
      IsRigidBasis A B ↔
      ∃ x : Fin n → ℝ,
        IsTropicallyFeasible A (fun _ => 0) x ∧
        (∀ j ∉ B, x j = 0) ∧
        IsTropicalLPOptimal A B x
```

If full LP duality is too large for one cycle, prove a weaker but still meaningful theorem:
- every rigid basis yields a support-minimal tropical feasible point;
- every support-minimal tropical feasible point determines a rigid basis.

### 4. Miura-ori as unique tropical minimum in a rectangular model

Do not overclaim uniqueness for arbitrary crease patterns. Restrict to a precise family: rectangular periodic 4-vertex patterns with alternating coefficients. Define a `MiuraMatrix p q` and a class of admissible states respecting alternating parity.

Target theorem:
```lean
theorem miura_unique_tropical_minimizer
    {p q : ℕ} (hp : 0 < p) (hq : 0 < q) :
    ∃! x : Fin (p*q) → ℝ,
      IsMiuraAdmissible p q x ∧
      IsTropicallyFeasible (MiuraMatrix p q) (fun _ => 0) x ∧
      (∀ y : Fin (p*q) → ℝ,
        IsMiuraAdmissible p q y →
        IsTropicallyFeasible (MiuraMatrix p q) (fun _ => 0) y →
        foldEnergy (MiuraWeights p q) x ≤ foldEnergy (MiuraWeights p q) y)
```

If uniqueness up to additive tropical scaling is the mathematically correct statement, state that instead:
```lean
theorem miura_unique_tropical_minimizer_mod_translation ...
```
This is probably the right invariant formulation, since tropical states often have additive gauge symmetry.

## Why This Would Be a Breakthrough

If you prove even the first two theorems in a robust Lean form, you create a new formal domain: **tropical rigidity of foldable structures**. This opens:
- tropical methods for deployable metamaterials,
- certified foldability criteria for engineering design,
- a bridge between origami mechanics and valuated matroids,
- tropical optimization methods for robot motion planning and self-folding materials.

The deepest conceptual gain is that “rigidity” becomes visible as a balancing phenomenon in min-plus algebra, just as classical rigidity sees equilibrium stresses in linear algebra. This is not incremental; it is a new dictionary.

## Proof Architecture: 3 Strategic Routes

### Strategy A: Direct row-wise tropicalization of compatibility constraints
Most promising for the first theorem.

1. Define each local crease compatibility condition as a finite minimum-attainment relation on affine forms `A i j + x j - b i`.
2. Show that the condition “minimum attained at least twice” is exactly membership in a tropical hyperplane associated to the row vector `A i ·`.
3. Conclude that global feasibility is the intersection over all rows, hence a tropical hyperplane arrangement.

Why promising:
- entirely finite-dimensional,
- no heavy geometry required,
- Lean-friendly because it reduces to `Fin`, `Matrix`, `Finset`, and order lemmas on `ℝ`.

### Strategy B: Maxwell-Cremona-to-tropical stress transfer
Most promising for the rigid-foldability theorem.

1. Formalize a finite equilibrium condition as repeated attainment of minima in each crease column.
2. Interpret the stress vector `σ` as a tropical dual certificate for compatibility.
3. Prove that a tropical stress induces a feasible fold-state, either constructively or via a finite minimization argument.

Why promising:
- conceptually deep,
- gives the cross-domain bridge to rigidity theory,
- likely formalizable if you weaken geometric rigidity to a combinatorial rigid-foldability surrogate.

Potential tool:
- if existence/uniqueness of minimizers is needed, imitate the pattern of `tropical_horizon_exists_unique`: build an optimization functional with monotonicity/coercivity and derive a canonical witness.

### Strategy C: Valuated matroid / support-minimal classification
Most promising for the rigid basis theorem.

1. Associate to the crease matrix `A` a tropical dependence structure on subsets of creases.
2. Define rigid bases as support-minimal feasible supports.
3. Show equivalence with tropical LP optima or circuits/bases in the induced valuated matroid.

Why promising:
- strongest long-term payoff,
- links origami classification to tropical linear spaces and matroid theory,
- may require more infrastructure than one cycle, so isolate a finite support-minimal version first.

## How to Use Existing Catalog Theorems

The catalog theorems are not directly origami statements, but they suggest useful patterns.

1. `tropical_horizon_exists_unique`
   - Use as a model for proving existence/uniqueness of a canonical minimizing fold state.
   - If the Miura minimizer theorem requires a uniqueness argument, mimic the structure: prove nonnegativity/coercivity of the energy, then derive uniqueness under alternating constraints.

2. `maslov_tropical_error_bound`
   - Use as conceptual justification for any “classical-to-tropical” passage.
   - If you define fold energy via a logarithmic or Maslov dequantization limit, this theorem can certify that the tropical model approximates a smooth energy to first order.

3. `tropical_holevo_dominant_bound`
   - This hints at dominance bounds under max/min-plus aggregation.
   - It may be useful if your energy or equilibrium condition involves a dominant crease mode or concentration phenomenon.

4. `tropical_and_bound`
   - Trivial but useful as a local inequality lemma in row-wise minimum arguments.
   - Do not cite it rhetorically; actually use min-order lemmas to dispatch annoying inequalities.

## Cross-Domain Connections You Must Exploit

Do not leave the work siloed in “origami.” Connect it to at least one of the following in the formal writeup and theorem naming.

### 1. Rigidity theory / structural mechanics
Interpret tropical stress as the min-plus analogue of equilibrium stress in bar-and-joint frameworks. This gives immediate conceptual legitimacy.

### 2. Valuated matroids / tropical linear spaces
A crease pattern matrix should induce tropical dependencies. Rigid bases then become tropical bases or support-minimal feasible supports.

### 3. Statistical physics / energy landscapes
Your fold-energy functional creates a tropical energy landscape. Miura-ori being the unique minimizer is analogous to a ground state classification.

### 4. Robotics / motion planning
Feasible folding states form a piecewise-linear tropical region. This suggests certified path planning in deployment spaces.

### 5. Quantum / semiclassical tropicalization
If ambitious, interpret tropical fold states as semiclassical limits of oscillatory phase constraints, using `maslov_tropical_error_bound` as the formal bridge.

## Concrete Lean Design Recommendations

Use concrete finite types only:
- `Fin n`
- `Matrix (Fin m) (Fin n) ℝ`
- `Finset (Fin n)`
- predicates on functions `Fin n → ℝ`

Avoid trying to formalize continuous rigid-body kinematics in the first pass. Instead:
- define combinatorial foldability,
- prove tropical geometry theorems about that finite model,
- only then interpret them mechanically.

Likely helper definitions:
```lean
def rowMinVal ...
def rowArgminSet ...
def MinAttainedTwice ...
def IsTropicalHyperplaneRow ...
def IsTropicallyFeasible ...
def IsTropicalStressEquilibrium ...
def support {n : ℕ} (x : Fin n → ℝ) : Finset (Fin n) := ...
```

Likely helper lemmas:
```lean
lemma feasible_iff_rowwise ...
lemma rowwise_is_tropical_hyperplane ...
lemma inter_rows_is_arrangement ...
lemma stress_gives_balancing ...
lemma support_minimal_of_optimal ...
lemma miura_energy_strict_convex_on_admissible ...
```

If strict uniqueness is obstructed by additive translation invariance, quotient by tropical scaling or normalize by fixing one crease variable:
```lean
x 0 = 0
```
This will make uniqueness formalizable.

## Minimal Nontrivial Deliverable If Full Program Is Too Large

At absolute minimum, prove this theorem completely and cleanly:

```lean
theorem tropical_origami_feasibility_eq_inter_tropical_hyperplanes
    {m n : ℕ} (A : Matrix (Fin m) (Fin n) ℝ) (b : Fin m → ℝ) :
    ∃ H : Fin m → Set (Fin n → ℝ),
      (∀ i, IsTropicalHyperplane (H i)) ∧
      {x | IsTropicallyFeasible A b x} = ⋂ i, H i
```

Then add one substantial stress theorem:
```lean
theorem tropical_stress_implies_nonempty_feasible_set
    {m n : ℕ} (A : Matrix (Fin m) (Fin n) ℝ) :
    (∃ σ, IsTropicalStressEquilibrium A σ) →
    ∃ x, IsTropicallyFeasible A (fun _ => 0) x
```

That pair alone would already be a genuine contribution.

## Application Keywords

tropical geometry, rigid origami, min-plus algebra, tropical hyperplane arrangement, equilibrium stress, valuated matroid, deployable metamaterials, foldability certification, tropical optimization, discrete rigidity, Miura-ori, energy landscape, robotic deployment, combinatorial mechanics

## Deliverables

1. Lean 4 code with precise new definitions and at least 2 proved nontrivial theorems from the list above.
2. Minimize sorry; if a theorem is too ambitious, prove a structurally weaker version and state the stronger conjecture clearly.
3. Name the main file something like:
   - `Bridges/TropicalOrigami/RigidFoldability.lean`
   - `Bridges/TropicalOrigami/MiuraEnergy.lean`
4. Include comments explaining the mathematical dictionary: crease constraint ↔ tropical hyperplane, rigid stress ↔ tropical equilibrium, rigid basis ↔ support-minimal feasible support.
5. Produce a structured `FUTURE_DIRECTIONS.md` with **3–5 concrete breakthrough next steps**, such as:
   - tropical Maxwell-Cremona for origami surfaces,
   - valuated matroid classification of deployable tessellations,
   - certified tropical algorithms for self-folding design,
   - tropical Morse theory on fold-energy landscapes,
   - semiclassical quantization of fold states via Maslov dequantization.

Be bold, but make the first bridge theorem airtight. A single clean equivalence between origami feasibility and tropical hyperplane arrangements is more revolutionary than ten vague definitions.

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
