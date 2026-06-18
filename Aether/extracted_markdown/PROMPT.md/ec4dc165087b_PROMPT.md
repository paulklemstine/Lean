## Assignment: Fixed Point Theorems Beyond the Classical Frontier — Brouwer, Banach, Schauder, and Their Algorithmic/Physical Echoes

You are not being asked to transcribe textbook mathematics into Lean. You are being asked to create a formal fixed-point architecture that turns three classical existence theorems into a reusable engine for analysis, dynamics, computation, and scientific modeling.

The opportunity is larger than “formalize Brouwer/Banach/Schauder.” The real breakthrough is to build a Lean 4 bridge from **combinatorial topology** (Sperner) to **metric iteration** (Banach) to **compact functional analysis** (Schauder), and then to push that bridge into **verified existence theorems for ODEs and integral equations**, with a computational witness extraction pipeline.

Your mission is to prove new, non-trivial theorems, not merely restate known ones. The file should become a seed crystal for a future formal library of nonlinear existence theory.

---

## Mode: `prove`

## Core Vision

Construct a Lean 4 development in which:

1. **Brouwer fixed point** is derived from a finite/combinatorial engine modeled on Sperner-type labeling.
2. **Banach contraction principle** is proved with explicit quantitative convergence estimates for Picard iteration.
3. **Schauder fixed point** is obtained by finite-dimensional approximation plus compactness.
4. These theorems are then used to prove **existence of solutions** to:
   - a Picard–Lindelöf style ODE integral operator,
   - a Hammerstein/Volterra-type integral equation.
5. You introduce at least one **new mathematical structure** capturing “effective compact approximation” or “certified contraction data,” and use it in nontrivial theorems.
6. You connect fixed-point theory to another domain in a way that is mathematically meaningful and testable: e.g. thermodynamic closure, tropical dynamics, entropy, operator approximation, or verified numerics.

This is not a library exercise. It is the beginning of a formal theory of **constructive nonlinear science**.

---

## Exact Theorem Targets

You should aim for at least the following three flagship theorems, with supporting lemmas and quantitative refinements.

### Theorem A: Quantitative Banach Fixed Point Theorem

A precise formal target in Lean style:

```lean
theorem exists_unique_fixedPoint_of_contraction
    {α : Type*} [MetricSpace α] [CompleteSpace α]
    (f : α → α) (K : ℝ)
    (hK0 : 0 ≤ K) (hK1 : K < 1)
    (hcontract : ∀ x y, dist (f x) (f y) ≤ K * dist x y) :
    ∃! x : α, f x = x
```

Strengthen it with an iteration estimate:

```lean
theorem tendsto_iterate_to_fixedPoint_geometric
    {α : Type*} [MetricSpace α] [CompleteSpace α]
    (f : α → α) (K : ℝ) (hK0 : 0 ≤ K) (hK1 : K < 1)
    (hcontract : ∀ x y, dist (f x) (f y) ≤ K * dist x y)
    (x₀ x⋆ : α) (hx⋆ : f x⋆ = x⋆) :
    ∀ n : ℕ, dist ((f^[n]) x₀) x⋆ ≤ K^n * dist x₀ x⋆
```

And ideally a Cauchy estimate between iterates:

```lean
theorem cauchySeq_of_contraction_iterates
    {α : Type*} [MetricSpace α] [CompleteSpace α]
    (f : α → α) (K : ℝ) (hK0 : 0 ≤ K) (hK1 : K < 1)
    (hcontract : ∀ x y, dist (f x) (f y) ≤ K * dist x y)
    (x₀ : α) :
    CauchySeq (fun n => (f^[n]) x₀)
```

**Why this matters:** The standard Banach theorem is only the beginning. The geometric error estimate is the gateway to verified numerics, iterative solvers, and computational science.

---

### Theorem B: Brouwer Fixed Point on a Finite-Dimensional Convex Compact Set

Mathlib may already contain topological fixed-point infrastructure in some form, but your task is to formalize a **proof architecture** that exhibits the combinatorial heart via finite approximation/Sperner. If full simplicial machinery is too heavy, target a mathematically precise intermediate theorem that still captures the mechanism.

A concrete theorem target:

```lean
theorem brouwer_fixedPoint_cube
    (n : ℕ) :
    ∀ f : (Fin n → ℝ) → (Fin n → ℝ),
      Continuous f →
      (∀ x, (∀ i, 0 ≤ x i ∧ x i ≤ 1) → ∀ i, 0 ≤ f x i ∧ f x i ≤ 1) →
      ∃ x, (∀ i, 0 ≤ x i ∧ x i ≤ 1) ∧ f x = x
```

If equality of functions is awkward, use subtype formulation:

```lean
def unitCube (n : ℕ) := {x : Fin n → ℝ // ∀ i, 0 ≤ x i ∧ x i ≤ 1}

theorem brouwer_fixedPoint_unitCube
    (n : ℕ) (f : unitCube n → unitCube n)
    (hf : Continuous f) :
    ∃ x : unitCube n, f x = x
```

If full Brouwer is too ambitious in one cycle, prove a **dimension-1 and dimension-2 certified approximation theorem** plus a general finite-labeled simplex existence theorem sufficient to state the route to Brouwer. But do not stop at a trivial compactness argument unless it is genuinely nontrivial and compositional.

**Why this matters:** Brouwer is the canonical bridge from combinatorics to topology. Formalizing it through a discrete approximation engine is foundational for future Nash equilibria, nonlinear PDE discretization, and topological data analysis.

---

### Theorem C: Schauder Fixed Point via Compact Approximation

Introduce a new structure expressing that a self-map on a convex compact set is approximable by finite-dimensional maps or has precompact range.

Suggested new definition:

```lean
structure CompactApproxSelfMap (E : Type*) [NormedAddCommGroup E] [NormedSpace ℝ E] where
  carrier : Set E
  nonempty_carrier : carrier.Nonempty
  convex_carrier : Convex ℝ carrier
  closed_carrier : IsClosed carrier
  compact_image : ∀ f : E → E, True -- replace with your actual approximation datum
```

Better: define a structure tailored to the proof, e.g. finite-rank approximation data.

```lean
structure FiniteDimApproximationData
    (E : Type*) [NormedAddCommGroup E] [NormedSpace ℝ E] where
  P : ℕ → (E →L[ℝ] E)
  fd_range : ∀ n, FiniteDimensional ℝ (Set.range (P n))
  approx : ∀ x, Tendsto (fun n => P n x) atTop (𝓝 x)
```

Then prove a Schauder-style theorem for maps preserving a convex compact subset:

```lean
theorem schauder_fixedPoint_of_compact_convex
    {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]
    [CompleteSpace E]
    (K : Set E)
    (hK_nonempty : K.Nonempty)
    (hK_convex : Convex ℝ K)
    (hK_compact : IsCompact K)
    (f : K → K)
    (hf_cont : Continuous f) :
    ∃ x : K, f x = x
```

If this exact theorem already exists in Mathlib, do not merely invoke it. Instead, prove a **derived theorem** with new content, for example:

```lean
theorem schauder_fixedPoint_of_precompact_range
    {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]
    [CompleteSpace E]
    (C : Set E)
    (hC_nonempty : C.Nonempty)
    (hC_convex : Convex ℝ C)
    (hC_closed : IsClosed C)
    (f : C → C)
    (hf_cont : Continuous f)
    (h_precompact : IsCompact (Set.range f)) :
    ∃ x : C, f x = x
```

This is a genuinely useful strengthening pattern: closed convex domain, compact image.

**Why this matters:** Schauder is the entry point to infinite-dimensional nonlinear analysis. Once formalized, it opens the door to elliptic PDE weak solutions, nonlinear integral equations, and compact operator methods.

---

## Required Application Theorems

You must include at least one theorem in each of the following directions.

### Application 1: ODE / Picard Operator

Define a Picard operator on a suitable function space and prove existence of a fixed point under a contraction condition.

A Lean-style target:

```lean
def picardOp
    (T : ℝ) (f : ℝ → ℝ → ℝ) (x₀ : ℝ) :
    C(ℝ, ℝ) → C(ℝ, ℝ) := ...

theorem exists_fixedPoint_picardOp_of_lipschitz
    (T L : ℝ) (hT : 0 < T) (hL : 0 ≤ L) (hLT : L * T < 1)
    (f : ℝ → ℝ → ℝ)
    (hf_cont : Continuous fun p : ℝ × ℝ => f p.1 p.2)
    (hf_lip : ∀ t x y, |f t x - f t y| ≤ L * |x - y|) :
    ∃! φ, picardOp T f x₀ φ = φ
```

This can be phrased on `ContinuousMap` over a compact interval if needed. The key is not the exact ambient type but the genuine fixed-point reduction.

### Application 2: Integral Equation / Compact Operator

For example, a Hammerstein or Volterra operator on continuous functions:

```lean
def volterraOp (K : ℝ → ℝ → ℝ) (g : ℝ → ℝ) : C(Icc a b, ℝ) → C(Icc a b, ℝ) := ...

theorem exists_fixedPoint_volterra_of_compact
    ...
    : ∃ u, volterraOp K g u = u
```

You may need a finite-dimensional approximation or Arzelà–Ascoli style compactness argument; if full generality is too large, prove a one-dimensional compact-image version on a closed bounded equicontinuous family.

**Breakthrough angle:** this is where the formalized theorem stops being “about fixed points” and becomes a tool for nonlinear scientific models.

---

## New Definition Requirement

You must define at least one novel concept not already present in the catalog. Suggested options:

1. **CertifiedContractionData**
   ```lean
   structure CertifiedContractionData (α : Type*) [MetricSpace α] where
     f : α → α
     K : ℝ
     hK0 : 0 ≤ K
     hK1 : K < 1
     contract : ∀ x y, dist (f x) (f y) ≤ K * dist x y
   ```
   Then prove theorem(s) extracting uniqueness, convergence rate, and algorithmic iteration bounds.

2. **FiniteDimApproximationData**
   for Schauder via finite-rank approximations.

3. **ApproximateFixedPointProfile**
   encoding ε-fixed points and their stability under approximation:
   ```lean
   def IsApproxFixedPoint {α} [MetricSpace α] (f : α → α) (ε : ℝ) (x : α) : Prop :=
     dist (f x) x ≤ ε
   ```

   Then prove a compactness theorem upgrading approximate fixed points to exact fixed points under suitable hypotheses.

This last option is especially powerful because it unifies Sperner/Brouwer approximation with compactness/Schauder.

---

## Strong Cross-Domain Connection Requirement

Do not leave fixed-point theory isolated. Prove at least one theorem that connects it to another verified domain in the catalog.

### Recommended connection: entropy / thermodynamic closure

You already have:
- `fixed_point_entropy_upper_bound`
  from `Speculative/AutoResearch/ThermodynamicClosureCore.lean`

A possible theorem direction:

```lean
theorem contraction_fixedPoint_entropy_control
    {α : Type*} [MetricSpace α] [CompleteSpace α]
    (data : CertifiedContractionData α)
    (E : α → ℝ)
    (hmono : ∀ x, E (data.f x) ≤ E x)
    {x⋆ : α} (hx⋆ : data.f x⋆ = x⋆) :
    ∀ x, E x⋆ ≤ E x
```

Or, if the catalog theorem is specialized, use it as a black box to derive a new statement:
- fixed points obtained by contraction inherit entropy upper bounds,
- iterative convergence is compatible with a Lyapunov/energy monotonicity principle.

### Alternative connection: tropical / quantum tropical dynamics

You already have:
- `exists_normalized_qtrop_fixed_point`

A provocative theorem would compare a classical contraction fixed point with a tropical/quantum-tropical normalized fixed point under a shared normalization operator. Even a clean abstract comparison theorem would be valuable.

### Alternative connection: dynamical systems / spectral criterion

Using:
- `no_nonzero_fixed_point_of_contracting`

Derive a theorem separating **strict contractions** from **compact self-maps**:
- Banach gives uniqueness under metric compression,
- Schauder gives existence under compactness without uniqueness,
- prove a theorem showing these mechanisms are formally orthogonal in a precise class of operators.

This cross-domain theorem is where the project becomes conceptually new rather than expository.

**Application keywords:** nonlinear analysis, verified numerics, dynamical systems, thermodynamic closure, entropy methods, operator theory, computational topology, scientific machine learning, compactness, Picard iteration.

---

## Proof Strategy Architecture

You must include at least 2–3 substantial proof strategy tracks in the code comments or paper.

### Strategy A: Metric Iteration → Banach → ODE Existence
1. Define a contraction datum structure with explicit constant `K`.
2. Prove by induction on `n` the geometric estimate
   `dist ((f^[n]) x₀) ((f^[n]) y₀) ≤ K^n * dist x₀ y₀`.
3. Use a telescoping/calc argument to show iterates are Cauchy.
4. Pass to the limit using completeness and continuity-like consequences of contraction.
5. Prove uniqueness by contradiction from
   `dist x y ≤ K * dist x y` with `K < 1`.

**Most promising for immediate success.** This route is technically tractable in Lean and yields algorithmic content immediately.

### Strategy B: Approximate Fixed Points → Compactness Upgrade → Schauder
1. Introduce `IsApproxFixedPoint f ε x := dist (f x) x ≤ ε`.
2. Construct ε-fixed points on finite-dimensional approximants using Brouwer.
3. Use compactness/precompactness to extract a convergent subsequence.
4. Use continuity to pass from εₙ → 0 approximate fixed points to an exact fixed point.

This is the deepest and most reusable strategy. It avoids overcommitting to one exact textbook proof of Schauder and instead creates a formal compactness-upgrade principle useful in many later domains.

### Strategy C: Combinatorial Labeling → Sperner Engine → Brouwer
1. Formalize a finite labeling principle on subdivided simplices/cubes.
2. Show that absence of fixed points induces a boundary-respecting labeling.
3. Apply Sperner to obtain a fully labeled simplex.
4. Convert fully labeled simplices of vanishing mesh into an approximate fixed-point sequence.
5. Upgrade via compactness/continuity to an exact fixed point.

This is the most visionary route. Even a partial implementation—enough to prove a certified approximate Brouwer theorem—would be a major asset.

---

## Specific Deep Lemmas to Target

These are excellent “engine room” theorems and satisfy the depth requirement.

```lean
theorem iterate_dist_le_geometric
    {α : Type*} [MetricSpace α]
    (f : α → α) (K : ℝ)
    (hK0 : 0 ≤ K)
    (hcontract : ∀ x y, dist (f x) (f y) ≤ K * dist x y) :
    ∀ n x y, dist ((f^[n]) x) ((f^[n]) y) ≤ K^n * dist x y
```

```lean
theorem eq_of_fixedPoints_of_contraction
    {α : Type*} [MetricSpace α]
    (f : α → α) (K : ℝ) (hK0 : 0 ≤ K) (hK1 : K < 1)
    (hcontract : ∀ x y, dist (f x) (f y) ≤ K * dist x y)
    {x y : α} (hx : f x = x) (hy : f y = y) :
    x = y
```

```lean
theorem exists_fixedPoint_of_approx_fixedPoint_compactness
    {α : Type*} [MetricSpace α] [CompleteSpace α]
    (K : Set α) (hK_compact : IsCompact K)
    (f : α → α) (hf_cont : Continuous f)
    (h_maps : MapsTo f K K)
    (happrox : ∀ ε > 0, ∃ x ∈ K, dist (f x) x ≤ ε) :
    ∃ x ∈ K, f x = x
```

This last theorem is particularly important: it is a compactness-upgrade principle that can serve as the formal hinge from Brouwer/Sperner to Schauder.

---

## How to Build on Catalog Theorems

Use the existing verified theorems not as decorations but as leverage points.

1. **`fixed_point_iterate'`**
   - Use it to normalize iteration identities once a fixed point is found.
   - It can simplify proofs that all iterates of a fixed point remain fixed and help with uniqueness/comparison lemmas.

2. **`no_nonzero_fixed_point_of_contracting`**
   - Use this as a conceptual comparison theorem: strict contractivity prohibits nontrivial fixed directions in certain spectral settings.
   - Build a theorem contrasting operator contraction and compactness-based existence.

3. **`fixed_point_entropy_upper_bound`**
   - Use it to derive a Lyapunov-style corollary for contraction-generated fixed points.
   - This gives a nontrivial cross-domain bridge: fixed points as entropy-controlled equilibria.

4. **`exists_normalized_qtrop_fixed_point`**
   - Use it to formulate a comparison theorem between classical normalized fixed points and tropical/quantum-tropical ones.
   - Even a weak theorem about existence under shared normalization constraints would be scientifically fresh.

5. **`fixed_point_self_equiv`**
   - Potentially useful for transporting fixed-point statements across equivalences/conjugacies.

Do not simply restate these results. Derive new theorems from them.

---

## Conjecture With Testable Prediction

You must state at least one falsifiable conjecture with a clear computational disproof criterion.

### Conjecture 1: Fast stabilization of approximate Brouwer witnesses
For a continuous self-map of the unit cube represented by a piecewise affine rational map with Lipschitz constant `L`, the barycentric subdivision/Sperner approximate fixed points converge at a rate polynomial in the inverse mesh size, and in the contraction regime agree asymptotically with Banach iterates.

**Computational test:** implement random piecewise affine self-maps of `[0,1]^2`; compare:
- Sperner approximate fixed points,
- Banach iterates when `L < 1`,
- residual `‖f(x)-x‖`.
A counterexample is any family where the Sperner witnesses fail to approach Banach witnesses in the contraction regime.

### Conjecture 2: Entropy-minimizing fixed point selection
For maps admitting multiple Schauder fixed points and an entropy functional satisfying the catalog upper-bound assumptions, the compactness-upgraded fixed point extracted by a monotone approximation scheme minimizes entropy among fixed points in the tested class.

**Computational test:** discretize compact integral operators on `C([0,1])`, approximate fixed points numerically, evaluate entropy-like energies. A counterexample is a map where the algorithm converges to a non-minimizing fixed point.

---

## Deliverables (ALL mandatory)

You must produce ALL of the following:

1. **Lean file(s)** containing:
   - at least 3 deep theorems,
   - at least 1 novel definition,
   - at least 1 cross-domain theorem,
   - no trivialized enumeration proofs,
   - minimized `sorry`.

2. **`FUTURE_DIRECTIONS.md`**
   with 3–5 testable scientific hypotheses.
   Each must be a falsifiable conjecture with:
   - precise statement,
   - why it might be true,
   - what computation or formal experiment could refute it.

3. **`RESEARCH_PAPER.md`**
   a standalone scientific paper explaining:
   - theorem statements,
   - proof architecture,
   - why this opens a new formal nonlinear-analysis program,
   - algorithmic implications,
   - future work.
   Someone reading only this paper must understand the discovery.

4. **`ARTICLE.md`**
   in Scientific American style:
   - explain fixed points as the mathematics of self-consistency,
   - describe the leap from triangles and contractions to ODEs and integral equations,
   - make clear why formal verification matters for science.

5. **A verified algorithm or computational method**
   such as:
   - certified contraction iteration with explicit error bounds,
   - approximate fixed-point search with compactness upgrade,
   - Sperner-style witness extraction on a grid.

6. **`demo.py`**
   demonstrating interactively:
   - Banach iteration and geometric convergence,
   - an approximate Brouwer witness on a 2D square map,
   - a compact integral operator example,
   - residual/error plots.

---

## Minimal Theorem Inventory You Should Exceed

At minimum, your development should contain:

- one theorem proving geometric decay of iterate distances,
- one theorem proving existence and uniqueness of contraction fixed points,
- one theorem upgrading approximate fixed points to exact ones on a compact set,
- one Brouwer/Sperner-style finite-dimensional fixed-point theorem or certified approximation theorem,
- one Schauder-style fixed-point theorem,
- one ODE or integral-equation application,
- one cross-domain theorem involving entropy/tropical/spectral ideas.

---

## Final Scientific Aim

If executed well, this project does not merely formalize classical fixed-point theorems. It creates a **verified existence pipeline**:

**discrete combinatorics → finite approximation → compactness → exact fixed point → nonlinear scientific model**

That pipeline is the real theorem. Once formalized, it becomes a reusable machine for proving existence in dynamical systems, operator equations, equilibrium theory, and scientific machine learning. This is how a classical subject becomes a frontier subject again.

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
