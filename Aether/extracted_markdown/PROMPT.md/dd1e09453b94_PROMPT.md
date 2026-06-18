## Assignment: Tropical Origami: Min-Plus Fold Structures and Rigid Origami Classification

Mode: **prove**

You are not being asked for a decorative analogy between origami and tropical geometry. You are being asked to create the first rigorous Lean 4 foundation for a new subject: **tropical rigidity theory for origami crease systems**. The goal is to isolate a formally tractable core of rigid foldability and prove theorems strong enough that later work can connect combinatorial origami, tropical geometry, rigidity theory, and idempotent optimization.

The original vision is too broad to formalize in one leap unless the objects are chosen with surgical precision. Your task is therefore to define the correct finite-dimensional min-plus model of crease patterns and then prove a sequence of nontrivial theorems culminating in a tropical classification principle and a uniqueness theorem for a Miura-type pattern.

## Core Formalization Program

Work with a finite set of creases indexed by `Fin n`. A crease pattern is encoded by a real matrix
`C : Matrix (Fin m) (Fin n) ℝ`
whose rows represent local vertex constraints and whose columns represent creases. A folding state is a weight vector
`w : Fin n → ℝ`.
Interpret `C i j + w j` as the tropical contribution of crease `j` to constraint `i`.

Define the tropical evaluation of row `i` at state `w` by
`rowEval C w i = Finset.univ.inf' ... (fun j => C i j + w j)`
or, if easier in Lean, work first with `sup` in max-plus and translate by negation. A row is **balanced** if the minimum is attained at least twice. This is the standard tropical hyperplane condition and is the right finite proxy for “locally valid fold compatibility.”

Define:
- `IsTropicallyValid C w` := every row is balanced,
- `TropicalStressEquilibrium C σ` := for each crease/column, the min over incident rows of `C i j + σ i` is attained at least twice,
- `RigidlyFoldable C` := there exists `w` with `IsTropicallyValid C w`,
- `TropicalEnergy C w` := sum over rows of the gap between the smallest and second-smallest values among `C i j + w j`.

This gives a precise finite-dimensional theorem package with genuine content.

## Primary Breakthrough Theorems

You should target the following theorem cluster. If one statement is too ambitious in full generality, prove it first under explicit hypotheses such as finite support, nondegeneracy, or a Monge/Miura condition on the crease matrix. But keep the destination theorem visible and state the strongest clean version you can.

### Theorem A: Valid fold states form a tropical prevariety / hyperplane arrangement locus

For each row of `C`, define the tropical hyperplane consisting of weights where the row minimum is attained at least twice. Then the valid fold space is the intersection of these hyperplanes.

A precise theorem statement:

```lean
def RowBalanced {m n : ℕ} (C : Matrix (Fin m) (Fin n) ℝ) (w : Fin n → ℝ) (i : Fin m) : Prop :=
  ∃ j₁ j₂ : Fin n, j₁ ≠ j₂ ∧
    C i j₁ + w j₁ = C i j₂ + w j₂ ∧
    ∀ j : Fin n, C i j₁ + w j₁ ≤ C i j + w j

def IsTropicallyValid {m n : ℕ} (C : Matrix (Fin m) (Fin n) ℝ) (w : Fin n → ℝ) : Prop :=
  ∀ i : Fin m, RowBalanced C w i

theorem validFoldSpace_eq_iInter_rowHyperplanes
    {m n : ℕ} (C : Matrix (Fin m) (Fin n) ℝ) :
    {w : (Fin n → ℝ) | IsTropicallyValid C w}
      =
    {w : (Fin n → ℝ) | ∀ i : Fin m, RowBalanced C w i} := by
  rfl
```

This equality is definitional, so it is not the breakthrough. The real theorem is the **structural theorem**:

```lean
theorem validFoldSpace_is_tropical_prevariety
    {m n : ℕ} (C : Matrix (Fin m) (Fin n) ℝ) :
    ∃ S : Finset ((Fin n → ℝ) → Prop),
      {w : (Fin n → ℝ) | IsTropicallyValid C w} =
      {w : (Fin n → ℝ) | ∀ P ∈ S, P w} := by
  ...
```

Better still, if you define row hyperplanes explicitly:

```lean
def RowHyperplane {m n : ℕ} (C : Matrix (Fin m) (Fin n) ℝ) (i : Fin m) :
    Set (Fin n → ℝ) :=
  {w | RowBalanced C w i}

theorem validFoldSpace_eq_iInter
    {m n : ℕ} (C : Matrix (Fin m) (Fin n) ℝ) :
    {w | IsTropicallyValid C w} = ⋂ i : Fin m, RowHyperplane C i := by
  ext w; simp [IsTropicallyValid, RowHyperplane]
```

The significance is not the set-theoretic identity itself, but that you will have created a certified tropical-geometric model of origami feasibility. This is the first portal.

### Theorem B: Tropical rigid foldability implies existence of tropical stress equilibrium, and conversely under a finite nondegeneracy hypothesis

This is the crucial rigidity bridge. You want a tropical analog of Maxwell-Cremona / self-stress duality.

Proposed formal target:

```lean
def TropicalStressEquilibrium {m n : ℕ}
    (C : Matrix (Fin m) (Fin n) ℝ) (σ : Fin m → ℝ) : Prop :=
  ∀ j : Fin n,
    ∃ i₁ i₂ : Fin m, i₁ ≠ i₂ ∧
      C i₁ j + σ i₁ = C i₂ j + σ i₂ ∧
      ∀ i : Fin m, C i₁ j + σ i₁ ≤ C i j + σ i

theorem rigidFoldable_implies_tropical_stress
    {m n : ℕ} (C : Matrix (Fin m) (Fin n) ℝ)
    (hfold : ∃ w : Fin n → ℝ, IsTropicallyValid C w) :
    ∃ σ : Fin m → ℝ, TropicalStressEquilibrium Cᵀ σ := by
  ...
```

If the transpose formulation is awkward, define stress equilibrium directly on columns of `C`. The real point is duality between balancing on rows and balancing on columns.

A stronger converse, likely needing assumptions:

```lean
def TropicallyNondegenerate {m n : ℕ} (C : Matrix (Fin m) (Fin n) ℝ) : Prop := ...

theorem tropical_stress_implies_rigidFoldable
    {m n : ℕ} (C : Matrix (Fin m) (Fin n) ℝ)
    (hnd : TropicallyNondegenerate C)
    (hstress : ∃ σ : Fin m → ℝ, TropicalStressEquilibrium Cᵀ σ) :
    ∃ w : Fin n → ℝ, IsTropicallyValid C w := by
  ...
```

Even a one-way theorem with a sharp converse under explicit hypotheses would be a major result. This is where the new subject begins.

### Theorem C: Classification by tropical linear feasibility / optimization

You need a theorem saying that rigid origami bases are exactly those crease matrices admitting a feasible tropical system, and that equivalence classes are determined by tropical row span / tropical covector data.

A tractable first version:

```lean
def SameRigidBasisClass {m n : ℕ} (C D : Matrix (Fin m) (Fin n) ℝ) : Prop :=
  ∀ w : Fin n → ℝ, IsTropicallyValid C w ↔ IsTropicallyValid D w

def TropicalRowShiftEquivalent {m n : ℕ} (C D : Matrix (Fin m) (Fin n) ℝ) : Prop :=
  ∃ a : Fin m → ℝ, ∃ b : Fin n → ℝ,
    ∀ i j, D i j = C i j + a i + b j
```

Then prove invariance:

```lean
theorem rowShiftEquivalent_sameRigidBasisClass
    {m n : ℕ} {C D : Matrix (Fin m) (Fin n) ℝ}
    (h : TropicalRowShiftEquivalent C D) :
    SameRigidBasisClass C D := by
  ...
```

This theorem is subtle enough to matter and realistic enough to formalize. It says the rigid foldability class depends only on the tropical projective class of the crease matrix. That is a genuine classification theorem.

A more ambitious theorem, if you can make the definitions work:

```lean
theorem rigidFoldable_iff_tropical_feasible
    {m n : ℕ} (C : Matrix (Fin m) (Fin n) ℝ) :
    (∃ w, IsTropicallyValid C w) ↔ TropicalFeasible C := by
  ...
```

where `TropicalFeasible` is encoded by an explicit min-plus LP-style condition.

### Theorem D: Miura-ori is the unique tropical minimizer of fold energy in a Monge class

Do not try to prove “the Miura-ori fold is globally unique among all origami” with no hypotheses. That is mathematically empty unless a precise class is fixed. Instead define a **Miura-type matrix class** by a Monge or rank-one-plus-alternating condition and prove uniqueness there.

Suggested formal setup:

```lean
def TropicalEnergy {m n : ℕ} (C : Matrix (Fin m) (Fin n) ℝ) (w : Fin n → ℝ) : ℝ := ...

def IsMiuraMatrix {m n : ℕ} (C : Matrix (Fin m) (Fin n) ℝ) : Prop :=
  ∀ i₁ i₂ j₁ j₂,
    i₁.1 < i₂.1 → j₁.1 < j₂.1 →
    C i₁ j₁ + C i₂ j₂ = C i₁ j₂ + C i₂ j₁

def IsMiuraState {n : ℕ} (w : Fin n → ℝ) : Prop := ...
```

Then target:

```lean
theorem miura_unique_tropical_energy_minimizer
    {m n : ℕ} (C : Matrix (Fin m) (Fin n) ℝ)
    (hM : IsMiuraMatrix C) :
    ∃! w : Fin n → ℝ, IsMiuraState w ∧
      ∀ v : Fin n → ℝ, TropicalEnergy C w ≤ TropicalEnergy C v := by
  ...
```

If uniqueness of the vector `w` is too strict because of additive gauge symmetry, quotient by constant shifts:

```lean
def GaugeEquivalent {n : ℕ} (w v : Fin n → ℝ) : Prop := ∃ c : ℝ, ∀ j, v j = w j + c
```

and prove uniqueness modulo gauge.

This would be a true theorem, not a slogan.

## Why This Is Revolutionary

If you succeed, you will have formalized the first certified bridge between:

- tropical geometry: balancing loci, hyperplanes, prevarieties,
- rigidity theory: stress equilibria and duality,
- origami mathematics: rigid foldability and crease classification,
- optimization: min-plus linear programming and energy minimization.

This opens an entirely new field: **tropical origami mechanics**. It gives a language in which foldability is not a transcendental geometric constraint but a combinatorial-idempotent feasibility condition. Once that exists in Lean, downstream work becomes possible:
- algorithmic certification of rigid foldability,
- tropical moduli of crease patterns,
- origami-inspired metamaterial design via min-plus optimization,
- duality with phylogenetic and information-theoretic tropical structures,
- connections to discrete gravity and tropical quantum constraints.

## Lean 4 Type-Level Guidance

Prefer finite index types:
- `Fin m`, `Fin n`
- `Matrix (Fin m) (Fin n) ℝ`
- `Finset.univ`
- predicates over `Fin n → ℝ`

Avoid premature generalization to arbitrary finite types unless it helps. You need theorems, not elegance.

Use small helper definitions:
- minimum attained at least twice on a finite family,
- smallest value,
- second-smallest gap,
- row and column balancing,
- gauge equivalence.

Likely useful auxiliary lemma:

```lean
def MinAttainedTwice {α : Type} [Fintype α] (f : α → ℝ) : Prop :=
  ∃ a b : α, a ≠ b ∧ f a = f b ∧ ∀ c, f a ≤ f c
```

Then rows and columns become instances of `MinAttainedTwice`.

## Proof Strategy Architecture

### Strategy 1: Direct finite tropical geometry
Most promising for Theorems A and C.

1. Define `MinAttainedTwice` on finite families and prove basic invariance under additive shifts:
   - adding a constant to all coordinates preserves balancing,
   - row shifts and column shifts preserve validity.
2. Express each row validity condition as a tropical hyperplane predicate.
3. Prove the valid fold space is exactly the finite intersection of row hyperplanes.
4. Show tropical row/column gauge transformations preserve this space, yielding classification invariance.

Why this is promising: it is fully discrete, finite, and Lean-friendly. It requires almost no heavy imported geometry.

### Strategy 2: Duality via matrix transposition and tropical Farkas-style reasoning
Most promising for Theorem B.

1. Define row balancing and column balancing symmetrically.
2. Seek a dual witness construction: from a fold state `w`, define a stress `σ` by taking row minima or slack values.
3. Prove balancing on one side induces balancing on the transpose under nondegeneracy or tightness assumptions.
4. If full equivalence is hard, prove a weaker but still new theorem:
   - existence of a valid state implies existence of a nontrivial column support set satisfying tropical equilibrium,
   - converse under a Hall-type incidence condition.

Why this is promising: it captures the rigidity-theoretic heart. Even a partial duality theorem would be a major conceptual advance.

### Strategy 3: Monge/Miura uniqueness through discrete convexity
Most promising for Theorem D.

1. Define a Monge-type class for crease matrices.
2. Show `TropicalEnergy` is tropically convex / L-convex on this class.
3. Prove any minimizer must satisfy a local exchange condition characterizing Miura states.
4. Use strict Monge inequality or a normalization condition to force uniqueness modulo gauge.

Why this is promising: Miura-ori is naturally tied to rank-one/Monge structure, and discrete convexity is the right language for uniqueness.

## How to Use Existing Catalog Theorems

The injected catalog is not directly about origami, but there are useful conceptual bridges.

- `maslov_tropical_error_bound` from `Physics/TropicalQuantum/Foundations.lean`:
  use this as a model for stability lemmas. If you define a softened fold-energy via log-sum-exp or Maslov dequantization, this theorem may help prove that the tropical energy is the small-parameter limit of a classical smooth energy. That would be a deep bridge to mechanics.

- `tropical_holevo_dominant_bound` from `Physics/TropicalQuantum/Advanced.lean`:
  use as inspiration for dominance estimates. If a row has a unique strict minimum, the gap to the next candidate controls instability of the fold. This is analogous to dominant-state bounds in tropical quantum settings.

- `tropical_horizon_exists_unique` from `Physics/TropicalGravity/Core.lean`:
  use as a blueprint for uniqueness proofs in min-plus landscapes. The structural style of proving existence plus uniqueness under positivity/nonnegativity hypotheses may transfer to the Miura minimizer theorem.

- `tropical_and_bound`:
  trivial as stated, but useful in many local min inequalities while assembling row-min arguments.

Do not force these theorems into the proof if they do not genuinely help. But do explicitly mention in comments or documentation how your origami energy/stress framework is structurally parallel to tropical quantum dominance and tropical gravity horizons.

## Cross-Domain Connections You Must Exploit

At least one of these should be made mathematically explicit in the development.

1. **Rigidity theory / Maxwell-Cremona**
   Tropical stress equilibrium is the idempotent shadow of self-stress in bar-and-joint frameworks. Formalizing this creates a new tropical rigidity dictionary.

2. **Discrete convex analysis**
   The Miura uniqueness theorem should be framed as a tropical/discrete-convex minimization result. This connects origami to Murota-style L-convexity.

3. **Tropical quantum / dequantization**
   A smooth fold-energy regularized by log-sum-exp should converge to the tropical energy as temperature tends to zero. This makes origami a mechanical dequantization problem.

4. **Phylogenetics / hyperplane arrangements**
   Tropical balancing conditions define polyhedral complexes already familiar in tree space. Origami crease spaces may become a new class of tropical moduli spaces.

5. **Metamaterials / optimization**
   Once rigid foldability is tropical feasibility, one can algorithmically search for deployable structures using min-plus LP.

## Concrete Deliverables

1. A Lean file defining:
   - tropical crease matrices,
   - row-balanced constraints,
   - valid fold space,
   - tropical stress equilibrium,
   - tropical energy,
   - Miura/Monge class.

2. At least one fully proved nontrivial theorem from each cluster:
   - hyperplane/prevariety characterization,
   - classification invariance under tropical row/column shifts,
   - a duality/stress theorem in some precise form,
   - a Miura uniqueness theorem under explicit hypotheses.

3. Minimize `sorry`. If one major theorem remains incomplete, isolate it behind many completed lemmas so the obstruction is mathematically meaningful rather than infrastructural.

4. Produce `FUTURE_DIRECTIONS.md` with **3–5 concrete breakthrough next steps**, for example:
   - tropical Kawasaki-Maekawa theorem for flat-foldability,
   - tropical Maxwell-Cremona correspondence for origami frameworks,
   - algorithmic rigid-foldability certification via min-plus simplex,
   - dequantized elastic energy and asymptotic convergence theorem,
   - tropical moduli space of quadrilateral crease tessellations.

## Suggested Lean Theorem List

These are realistic and substantial targets.

```lean
def MinAttainedTwice {α : Type} [Fintype α] (f : α → ℝ) : Prop := ...
def RowBalanced {m n : ℕ} (C : Matrix (Fin m) (Fin n) ℝ) (w : Fin n → ℝ) (i : Fin m) : Prop := ...
def IsTropicallyValid {m n : ℕ} (C : Matrix (Fin m) (Fin n) ℝ) (w : Fin n → ℝ) : Prop := ...
def TropicalRowShiftEquivalent {m n : ℕ} (C D : Matrix (Fin m) (Fin n) ℝ) : Prop := ...
def SameRigidBasisClass {m n : ℕ} (C D : Matrix (Fin m) (Fin n) ℝ) : Prop := ...
def TropicalStressEquilibrium {m n : ℕ} (C : Matrix (Fin m) (Fin n) ℝ) (σ : Fin m → ℝ) : Prop := ...
def TropicalEnergy {m n : ℕ} (C : Matrix (Fin m) (Fin n) ℝ) (w : Fin n → ℝ) : ℝ := ...
def GaugeEquivalent {n : ℕ} (w v : Fin n → ℝ) : Prop := ...
def IsMiuraMatrix {m n : ℕ} (C : Matrix (Fin m) (Fin n) ℝ) : Prop := ...

theorem rowBalanced_add_const
    {n : ℕ} {f : Fin n → ℝ} (c : ℝ) :
    MinAttainedTwice f → MinAttainedTwice (fun i => f i + c) := by
  ...

theorem rowShiftEquivalent_sameRigidBasisClass
    {m n : ℕ} {C D : Matrix (Fin m) (Fin n) ℝ}
    (h : TropicalRowShiftEquivalent C D) :
    SameRigidBasisClass C D := by
  ...

theorem validFoldSpace_eq_iInter
    {m n : ℕ} (C : Matrix (Fin m) (Fin n) ℝ) :
    {w | IsTropicallyValid C w} = ⋂ i : Fin m, {w | RowBalanced C w i} := by
  ...

theorem rigidFoldable_implies_nonempty_validFoldSpace
    {m n : ℕ} (C : Matrix (Fin m) (Fin n) ℝ) :
    (∃ w, IsTropicallyValid C w) ↔ Set.Nonempty {w | IsTropicallyValid C w} := by
  ...

theorem rigidFoldable_implies_tropical_stress
    {m n : ℕ} (C : Matrix (Fin m) (Fin n) ℝ) :
    (∃ w, IsTropicallyValid C w) →
    ∃ σ, TropicalStressEquilibrium Cᵀ σ := by
  ...

theorem miura_unique_tropical_energy_minimizer_mod_gauge
    {m n : ℕ} (C : Matrix (Fin m) (Fin n) ℝ)
    (hM : IsMiuraMatrix C) :
    ∃ w, (∀ v, TropicalEnergy C w ≤ TropicalEnergy C v) ∧
      ∀ v, (∀ u, TropicalEnergy C v ≤ TropicalEnergy C u) → GaugeEquivalent v w := by
  ...
```

## Application Keywords

tropical geometry, rigid origami, min-plus algebra, tropical hyperplane arrangement, rigidity theory, Maxwell-Cremona duality, discrete convex analysis, Monge arrays, Miura-ori, tropical linear programming, idempotent optimization, metamaterials, dequantization, tropical mechanics, formalized mathematics, Lean 4, Mathlib

## Final Directive

Be bold, but do not be vague. If the grand theorem is too large, carve out the exact finite theorem that makes the field real. Build definitions that will survive future generalization. Prove the invariance and duality lemmas first; they are the load-bearing beams. Then attack the Miura uniqueness theorem inside the right Monge class. And when you finish, write `FUTURE_DIRECTIONS.md` with 3–5 specific next breakthroughs this foundation makes possible.

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
