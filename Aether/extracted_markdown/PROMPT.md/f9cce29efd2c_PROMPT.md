## Soli Deo Gloria

## Assignment: Tropical Helly's Theorem — From Convexity to Optimization Duality

Prove new, non-trivial theorems at the frontier of tropical geometry, convex analysis, and optimization. Build on catalog theorems. Minimize sorry. Open a field.

## Depth Requirements (MANDATORY)

Your output must satisfy ALL of these:

1. **NO trivial proofs**: Do NOT prove statements by `native_decide`, `decide`, `norm_num`, or `rfl` unless the statement itself is genuinely important.
2. **At least 3 theorems with deep proof tactics**: Your file must contain at least 3 theorems proven using induction, rcases, by_contra, field_simp, or multi-step calc reasoning.
3. **Novel definitions**: Define at least one new mathematical structure or concept that does not already exist in the Catalog.
4. **Cross-domain connections**: Include at least one theorem that connects your domain to a different mathematical domain.
5. **Conjecture with testable prediction**: State at least one falsifiable conjecture with a clear computational test that could disprove it.

---

## The Vision

Classical Helly's theorem is a cornerstone of convex geometry: if every (n+1)-subfamily of convex sets in ℝⁿ has nonempty intersection, then the whole family intersects. This single result underpins Carathéodory's theorem, the Farkas lemma, LP duality, and the entire theory of Helly-type theorems in combinatorial geometry.

**The tropical world has no Helly theorem — yet.** Tropical convex sets (closed under max-plus combinations) govern tropical linear programming, phylogenetic tree spaces, compiler scheduling, and the decision boundaries of ReLU neural networks. Without a tropical Helly theorem, these fields lack the unifying duality framework that makes classical convex optimization coherent.

Proving the tropical Helly theorem doesn't just fill a gap — it creates a bridge between tropical geometry and combinatorial optimization that has never been formally crossed. It enables tropical LP duality, tropical Farkas lemmas, and certified robustness for tropical neural networks via intersection guarantees.

---

## Precise Theorem Targets

### Target 1: Tropical Convexity and Convex Hull (Foundation)

```lean
/-- Tropical convexity in the max-plus semiring.
    A set S ⊆ ℝⁿ is tropically convex if for all x, y ∈ S and
    all λ, μ with max(λ, μ) = 0, the point i ↦ max(λ + xᵢ, μ + yᵢ) lies in S.
    This is the max-plus analogue of classical convex combinations. -/
def IsTropConvex {n : ℕ} (S : Set (Fin n → ℝ)) : Prop :=
  ∀ ⦃x y : Fin n → ℝ⦄, x ∈ S → y ∈ S →
    ∀ λ μ : ℝ, max λ μ = 0 → (fun i => max (λ + x i) (μ + y i)) ∈ S

/-- The tropical convex hull: intersection of all tropically convex supersets. -/
def tropConvexHull {n : ℕ} (T : Set (Fin n → ℝ)) : Set (Fin n → ℝ) :=
  sInf {S : Set (Fin n → ℝ) | IsTropConvex S ∧ T ⊆ S}

/-- The tropical convex hull is exactly the set of finite tropical convex combinations.
    This is the tropical Carathéodory-generating theorem. -/
theorem tropConvexHull_eq_tropCombination {n : ℕ} (T : Set (Fin n → ℝ)) :
    tropConvexHull T =
      {p : Fin n → ℝ | ∃ (k : ℕ) (x : Fin k → (Fin n → ℝ)) (w : Fin k → ℝ),
        (∀ i, x i ∈ T) ∧ (∀ i, w i ≤ 0) ∧ (∃ i, w i = 0) ∧
        p = fun j => ⨂ i, max (w i + x i j)} := by
  sorry
```

### Target 2: Tropical Helly's Theorem (The Main Result)

```lean
/-- **Tropical Helly's Theorem**: For a finite family of tropically convex
    sets in ℝⁿ, if every subfamily of size n+1 has nonempty intersection,
    then the entire family has nonempty intersection.

    This is the max-plus analogue of the classical Helly theorem.
    The Helly number n+1 matches the classical dimension+1. -/
theorem tropical_helly {n : ℕ} {F : Finset (Set (Fin n → ℝ))}
    (hConv : ∀ C ∈ F, IsTropConvex C)
    (hInter : ∀ G ⊆ F, G.card ≤ n + 1 →
      (⋂₀ (↑G : Set (Set (Fin n → ℝ)))) ≠ ∅) :
    (⋂₀ (↑F : Set (Set (Fin n → ℝ)))) ≠ ∅ := by
  sorry
```

### Target 3: Tropical Carathéodory's Theorem

```lean
/-- **Tropical Carathéodory**: If p lies in the tropical convex hull of S ⊆ ℝⁿ,
    then p lies in the tropical convex hull of at most n points of S.
    The tropical Carathéodory number equals the ambient dimension n. -/
theorem tropical_caratheodory {n : ℕ} {S : Set (Fin n → ℝ)} {p : Fin n → ℝ}
    (hp : p ∈ tropConvexHull S) (hS : (S : Set (Fin n → ℝ)).Finite) :
    ∃ T : Finset (Fin n → ℝ), T.card ≤ n ∧ ↑T ⊆ S ∧ p ∈ tropConvexHull ↑T := by
  sorry
```

### Target 4: Tropical Farkas Lemma (Cross-Domain: Optimization ↔ Tropical Geometry)

```lean
/-- A tropical halfspace: {x | max(a 0 + x 0, max(a 1 + x 1, ...)) ≥ b}
    in the max-plus semiring. This is the tropical analogue of a linear inequality. -/
def TropHalfspace {n : ℕ} (a : Fin n → ℝ) (b : ℝ) : Set (Fin n → ℝ) :=
  {x | (⨂ i, max (a i + x i)) ≥ b}  -- ⨂ denotes finset max here

/-- **Tropical Farkas Lemma**: A tropical linear inequality is a consequence
    of a system of tropical linear inequalities if and only if the target
    coefficient vector lies in the tropical convex hull of the system's rows.

    This connects tropical Helly to tropical LP duality: Helly for halfspaces
    is equivalent to the Farkas lemma, just as in the classical case. -/
theorem tropical_farkas {n m : ℕ} {A : Fin m → (Fin n → ℝ)} {b : Fin m → ℝ}
    {c : Fin n → ℝ} {d : ℝ}
    (hA : ∀ j, TropHalfspace (A j) (b j) ≠ ∅) :
    (∀ x : Fin n → ℝ, (∀ j, x ∈ TropHalfspace (A j) (b j)) → x ∈ TropHalfspace c d) ↔
    (∃ (λ : Fin m → ℝ), (∀ j, λ j ≤ 0) ∧ (∃ j, λ j = 0) ∧
      c ∈ tropConvexHull {fun i => A j i + λ j | j} ∧ d ≤ ⨂ j, max (b j + λ j)) := by
  sorry
```

### Target 5: Tropical Nerve Theorem (Cross-Domain: Topological Data Analysis)

```lean
/-- The tropical nerve: a simplicial complex whose k-faces correspond to
    (k+1)-fold nonempty intersections of tropical convex sets.
    This is the tropical analogue of the Čech nerve. -/
structure TropicalNerve (n : ℕ) where
  sets : Finset (Set (Fin n → ℝ))
  hConv : ∀ C ∈ sets, IsTropConvex C
  /-- k-simplices are (k+1)-subfamilies with nonempty intersection -/
  simplices : Set (Finset (Set (Fin n → ℝ)))
  simplices_eq : simplices = {σ | σ ⊆ sets ∧ (⋂₀ ↑σ : Set (Fin n → ℝ)) ≠ ∅}

/-- **Tropical Nerve Lemma**: The tropical nerve of a family of tropical convex
    sets has the same homotopy type as the union, when the family satisfies
    a tropical convexity nerve condition (analogous to the classical nerve theorem
    for convex sets). -/
theorem tropical_nerve_homotopy {n : ℕ} {F : Finset (Set (Fin n → ℝ))}
    (hConv : ∀ C ∈ F, IsTropConvex C) :
    -- The nerve captures the topology of the union
    True := by  -- placeholder for the actual statement involving homotopy
  sorry
```

---

## Proof Strategies

### Strategy A: Reduction to Classical Helly via Lifting (Most Promising)

**Key insight**: Every tropical convex set in ℝⁿ lifts to a classical convex cone in ℝ²ⁿ via the "signed decomposition" x ↦ (max(xᵢ, 0), max(-xᵢ, 0)). Classical Helly in ℝ²ⁿ (with the cone structure) then implies tropical Helly in ℝⁿ.

**Steps**:
1. Define the lifting map `tropLift : (Fin n → ℝ) → (Fin n → ℝ) × (Fin n → ℝ)` sending `x ↦ (fun i => max (x i) 0, fun i => max (-x i) 0)`.
2. Prove that `S` is tropically convex iff `tropLift '' S` is classically convex (as a cone).
3. Apply classical Helly's theorem (from Mathlib) to the lifted family.
4. Project back down: nonempty intersection of lifted cones ↔ nonempty intersection of original tropical convex sets.
5. The Helly number doubles in the lifting, so carefully track dimensions to recover n+1.

**Why most promising**: This reduces to an existing theorem in Mathlib and avoids reinventing the combinatorics. The lifting is explicit and constructive.

### Strategy B: Direct Combinatorial Proof via Tropical Halfspaces

**Key insight**: Every tropical convex set is an intersection of tropical halfspaces (tropical separation theorem). Reduce Helly for general tropical convex sets to Helly for tropical halfspaces. Then use the explicit combinatorial structure of tropical halfspace intersections.

**Steps**:
1. Prove the tropical separation theorem: if `p ∉ S` with `S` tropically convex, there exists a tropical halfspace containing `S` but not `p`.
2. Prove Helly for tropical halfspaces directly: a family of tropical halfspaces in ℝⁿ has nonempty intersection iff every (n+1)-subfamily does. This reduces to checking the tropical circuit condition on the coefficient vectors.
3. Lift from halfspaces to general convex sets via the separation theorem.

**Why this works**: The combinatorial structure of tropical halfspaces is much simpler than general tropical convex sets — their boundaries are tropical hypersurfaces with explicit fan structures.

### Strategy C: Induction on Helly Number via Tropical Projections

**Key insight**: Project ℝⁿ → ℝⁿ⁻¹ by forgetting the last coordinate. Use the inductive hypothesis for the projected family, then reconstruct the intersection point in ℝⁿ by solving a 1-dimensional tropical intersection problem.

**Steps**:
1. Base case n=1: Helly for tropical convex sets in ℝ is trivial (they are classical intervals with tropical structure).
2. Inductive step: given the result for n-1, project each tropical convex set to ℝⁿ⁻¹.
3. The projected sets are tropically convex. Apply induction to find a point in the projected intersection.
4. Lift: the fiber over this point is a family of tropical convex sets in ℝ (1-dimensional), apply base case.

**Why this might fail**: Tropical projections of tropical convex sets are tropical convex, but the Helly number might not decrease correctly. The fiber argument requires careful handling of the tropical structure.

**Recommendation**: Use Strategy A as the primary approach, with Strategy B as a fallback for the halfspace case (which is needed for the Farkas lemma anyway). Strategy C is useful for intuition but risky for formalization.

---

## Building on Catalog Theorems

1. **`tropical_fundamental_theorem`** (from `Surjectivity_of_the_Tropical_Satake_Transform_for_GL₃.lean`): The tropical Satake transform establishes that tropical polynomial maps are surjective onto their image cones. Use this to show that the lifting map in Strategy A is surjective onto the correct classical cone, ensuring the dimension count is tight.

2. **`tropical_and_bound`** (from `OracleApplicationsFrontier.lean`): The bound `(1 ⊗ c₁) ⊗ (1 ⊗ c₂) ≥ 1 ⊗ (c₁ ⊗ c₂)` in the tropical semiring. Use this as a lemma when bounding tropical convex combinations in the Carathéodory proof — it controls how tropical coefficients compose.

3. **`tropical_mirror_theorem`** (`max a a = a`): This idempotence property is the foundation of tropical convexity. Use it pervasively: it's why tropical convex hulls are well-defined (the tropical semiring has no cancellation, but idempotence compensates).

---

## Revolutionary Significance

**What this opens**: Tropical Helly is not just a theorem — it's a duality framework. With it, we get:
- **Tropical LP duality**: The Farkas lemma for tropical linear programs, enabling certified tropical optimization.
- **Tropical robustness certificates**: If decision regions of a tropical neural network are tropical convex sets, Helly gives conditions for certified robustness of ensemble classifiers.
- **Phylogenetic consensus**: Tree space (Billera-Holmes-Vogtmann) is tropically convex. Helly gives conditions for the existence of consensus trees from partial phylogenetic data.
- **Compiler scheduling**: Loop nest scheduling constraints are tropical linear inequalities. Helly gives conditions for the existence of feasible parallel schedules.
- **Topological data analysis**: The tropical nerve connects tropical convexity to persistent homology, enabling new TDA methods for tropical data.

---

## Falsifiable Conjecture

**Conjecture (Tropical Fractional Helly)**: There exists a constant β > 0 (depending only on n) such that for any family F of m tropically convex sets in ℝⁿ, if at least β · (m choose n+1) of the (n+1)-subfamilies have nonempty intersection, then some point lies in at least β · m members of F.

**Computational test**: Generate m random tropical halfspaces in ℝ³. For β = 0.1, 0.2, ..., 0.9, count the fraction of 4-subfamilies with nonempty intersection. If the fraction exceeds β, check whether any point lies in ≥ β·m sets (sample on a grid). Report the threshold β* where the implication first fails. If no failure occurs for β ∈ (0,1), the conjecture gains support. A single counterexample at any β refutes the conjecture for that β.

---

## Mandatory Deliverables

(a) **FUTURE_DIRECTIONS.md** with 3-5 research directions. Each must include "The key insight is..." and "Why now?" At least one must bridge to a different domain (suggestion: tropical Helly ↔ mean field games in optimal transport, or tropical Helly ↔ phylogenetic tree spaces).

(b) **RESEARCH_PAPER.md** — standalone scientific document. Someone reading ONLY this paper must understand: what the tropical Helly theorem says, why classical Helly doesn't trivially transfer, how the proof works via the lifting strategy, what the Farkas duality implies for tropical optimization, and what open problems remain.

(c) **ARTICLE.md** — Scientific American style. Engaging, accessible. Explain tropical convexity through analogy (imagine scheduling tasks where you can only take the slowest bottleneck — that's tropical addition). Explain Helly through a real-world scenario (when can you guarantee that everyone's available time slots have a common slot?). TABOO: Do NOT focus on formal verification or machine verification — write about the ideas.

(d) **Verified algorithm**: A certified tropical Helly checker — given a list of tropical convex sets (represented as tropical halfspace intersections), verify the (n+1)-wise intersection condition and produce a point in the full intersection. This is not just a theorem statement; it is a constructive extraction.

(e) **demo.py**: Interactive demonstration. Generate random tropical convex sets in ℝ³. Visualize their intersections. Show Helly in action: color the (n+1)-subfamilies green if they intersect, red if they don't. When all are green, display the common intersection point. Show counterexamples where one red subfamily breaks the intersection.

---

## Mode: `prove`

This is a `prove` task — the theorems are precisely stated above. Your job is to make them real in Lean 4, with full proofs, building on Mathlib and catalog theorems. The tropical Helly theorem has never been formally verified in any proof assistant. You are the first.

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

Research domain: Tropical
Research mode: prove
