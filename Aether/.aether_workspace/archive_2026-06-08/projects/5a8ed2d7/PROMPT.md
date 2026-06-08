Soli Deo Gloria

## Assignment: Tropical Convexity, Helly Phenomena, and Optimization Duality

**Mode:** `prove`

Do not give me an incremental tropical convexity warm-up. I want a field-opening formalization that turns tropical convexity into a certified engine for intersection theory and optimization. The target is a genuine **tropical Helly theory** with algorithmic consequences, not just definitions and toy lemmas.

You should build a Lean 4 development that isolates a mathematically robust notion of tropical convex set over `ℝ` (or `Fin n → ℝ`) and proves a Helly-type intersection principle strong enough to act as a combinatorial certificate for tropical feasibility. The real breakthrough is not merely “there exists a tropical analogue,” but that the analogue is formalized in a way that **interfaces with optimization, polyhedral combinatorics, and idempotent algebra**.

## Core Vision

Classical Helly’s theorem says that for convex subsets of `ℝ^d`, global intersection is controlled by subfamilies of size `d+1`. In tropical mathematics, convexity is fundamentally different: tropical line segments are min-plus or max-plus geodesics, and tropical polyhedra encode shortest-path style constraints, scheduling constraints, mean-payoff phenomena, and idempotent linear systems. A verified Helly theorem here would create a **finite local certificate for tropical feasibility**.

That is the conceptual leap:  
**local tropical consistency ⇒ global tropical feasibility**, with explicit finite witnesses.

This opens a route to:
- certified tropical linear feasibility,
- tropical separation and duality,
- combinatorial optimization over idempotent semirings,
- bridges to discrete event systems and shortest-path dynamics,
- and eventually tropical versions of LP-type algorithms.

## Precise Formalization Target

You should work in finite dimension, preferably on `Fin n → ℝ`, where tropical convexity is tractable and compatible with Mathlib’s finite-dimensional linear infrastructure.

### New definitions you should introduce

At least one of these must be genuinely new relative to the catalog:

1. `IsTropicallyConvex (S : Set (Fin n → ℝ)) : Prop`  
   expressing closure under tropical convex combinations:
   for `x y ∈ S` and scalars `a b : ℝ` with `min a b = 0`, the point
   `fun i => min (a + x i) (b + y i)` belongs to `S`.

2. `tropicalSegment (x y : Fin n → ℝ) : Set (Fin n → ℝ)`  
   the set of all tropical convex combinations of `x` and `y`.

3. `tropicalHalfspace` or `TropicalHalfspace`  
   defined by inequalities of the form
   `min_i (a i + x i) ≤ min_j (b j + x j)` or a finite-support variant.
   These are the right test objects for a Helly theorem with algorithmic content.

4. `TropicalPolyhedron`  
   as finite intersections of tropical halfspaces.

5. `HellyNumberTropical (n : ℕ)`  
   if you want to package the dimension-dependent Helly constant abstractly.

The minimum acceptable novelty is a clean, reusable tropical convexity API, not ad hoc predicates embedded in theorem statements.

---

## Main theorem target

You should aim for a finite-dimensional tropical Helly theorem for tropical polyhedra or finitely generated tropically convex closed sets.

A realistic and mathematically meaningful theorem is:

### Theorem A: Tropical Helly for tropical halfspaces/polyhedra
For `n : ℕ`, let `F : Fin m → Set (Fin n → ℝ)` be a finite family of tropical convex sets, each representable as a tropical polyhedron (or tropical halfspace intersection), and assume each `F i` is tropically convex and tropically closed. If every subfamily of cardinality at most `n + 1` has nonempty intersection, then the whole family has nonempty intersection.

A Lean-oriented shape:

```lean
theorem tropical_helly_fin
    {n m : ℕ}
    (F : Fin m → Set (Fin n → ℝ))
    (hconv : ∀ i, IsTropicallyConvex (F i))
    (hpoly : ∀ i, IsTropicalPolyhedron (F i))
    (hsmall :
      ∀ s : Finset (Fin m),
        s.card ≤ n + 1 →
        (∃ x : Fin n → ℝ, x ∈ ⋂ i ∈ s, F i)) :
    ∃ x : Fin n → ℝ, ∀ i, x ∈ F i
```

If the exact `⋂ i ∈ s, F i` encoding is awkward, use a set of points satisfying all constraints indexed by `s`.

This is the headline result.

---

## Supporting theorem targets

You must prove at least 3 substantial theorems. Here is a coherent package:

### Theorem B: Tropical convex hull membership via normalized tropical combinations
Prove that membership in the tropical convex hull of a finite set can be reduced to normalized coefficient data.

Informally: every point in the tropical convex hull of finitely many points can be written as a tropical combination with minimum coefficient `0`.

Lean-style target:
```lean
theorem mem_tropicalConvHull_iff_normalized
    {n k : ℕ} (V : Fin k → (Fin n → ℝ)) (x : Fin n → ℝ) :
    x ∈ tropicalConvHull (Set.range V) ↔
      ∃ c : Fin k → ℝ,
        (∀ i, c i ≥ 0) ∧
        (∃ i, c i = 0) ∧
        x = fun j => Finset.univ.inf' Finset.univ_nonempty (fun i => c i + V i j)
```

You may need to adapt the normalization condition; the key point is to prove a nontrivial representation theorem.

### Theorem C: Tropical Radon-type lemma
Any family of `n+2` points in tropical `n`-space admits a partition whose tropical convex hulls intersect.

Lean-style aspirational signature:
```lean
theorem tropical_radon_fin
    {n : ℕ}
    (V : Fin (n + 2) → (Fin n → ℝ)) :
    ∃ (I J : Finset (Fin (n + 2))),
      I.Nonempty ∧ J.Nonempty ∧ Disjoint I J ∧
      I ∪ J = Finset.univ ∧
      (tropicalConvHull (V '' ↑I : Set (Fin n → ℝ)) ∩
       tropicalConvHull (V '' ↑J : Set (Fin n → ℝ))).Nonempty
```

If full Radon is too ambitious, prove a restricted version for tropical polytopes generated by finite sets. This theorem is valuable because **Radon ⇒ Helly** is one of the deepest structural pathways.

### Theorem D: Optimization certificate theorem
Connect tropical intersection to feasibility of a min-plus constraint system. For a finite family of tropical halfspaces, prove that nonempty intersection is equivalent to feasibility of a system of tropical inequalities, and derive a verified witness extraction procedure.

Lean-style target:
```lean
theorem tropical_polyhedron_nonempty_iff_feasible
    {n m : ℕ}
    (A B : Fin m → Fin n → ℝ) :
    (∃ x : Fin n → ℝ, ∀ i, tropicalHalfspace A i B i x) ↔
    TropicalFeasible A B
```

where `TropicalFeasible A B` is your new computational predicate/data structure, designed so that a witness can actually be extracted.

This is the theorem that ties the geometry to optimization.

---

## Most promising proof architectures

You must not just “try induction.” Choose a strategy and drive it.

### Strategy 1: Radon ⇒ Helly via finite combinatorics
**Best conceptual route.**
1. Define tropical convex hulls and prove finite-generation lemmas.
2. Prove a tropical Radon theorem for `Fin n → ℝ`.
3. Adapt the classical finite combinatorial derivation of Helly from Radon, carefully replacing Euclidean convexity by your `IsTropicallyConvex`.

Why this is promising: once Radon is formalized, Helly becomes part of a reusable convexity meta-theory. This is the route most likely to generate a **new library architecture** rather than a one-off theorem.

### Strategy 2: Reduction to tropical polyhedra and minimal infeasible subfamilies
**Best algorithmic route.**
1. Restrict to tropical halfspaces / tropical polyhedra.
2. Show that if the whole family is infeasible, there exists a minimal infeasible subfamily.
3. Bound the size of a minimal infeasible subfamily by `n+1` using a rank/dimension argument on active constraints or a tropical Carathéodory-style support reduction.

Why this is promising: this produces an actual **certificate extraction algorithm** and directly supports `demo.py`. It is also closer to optimization applications.

### Strategy 3: Tropical separation and compactness-normalization
1. Normalize points modulo additive constants to work in tropical projective space.
2. Prove a separation theorem for disjoint tropical convex sets or a nearest-point style witness lemma.
3. Use compactness of normalized bounded slices plus finite obstruction arguments to derive Helly.

Why this is promising: if successful, it opens the door to tropical Hahn–Banach analogues and duality. Harder than the other two, but potentially the most revolutionary.

**Recommendation:** pursue Strategy 2 first for a theorem that can be completed robustly in Lean, while structuring definitions so that Strategy 1 becomes possible afterward.

---

## How to build on existing verified theorems

The current catalog excerpts are sparse and not directly about tropical convexity, but they still matter. In particular:

- `FINAL/Tropical/Surjectivity_of_the_Tropical_Satake_Transform_for_GL₃.lean`
  and its `tropical_fundamental_theorem` indicate the repository already contains serious tropical infrastructure and notation discipline. Reuse the established conventions for tropical operations, naming, and semiring viewpoint where possible.

- `FINAL/Tropical/OracleApplicationsFrontier.lean` with results such as `tropical_and_bound`
  suggests there are already verified inequalities in tropical-style min/max algebra. Mine these for inequality manipulation patterns and proof style, especially where min-plus expressions are bounded or compared.

- `TropicalFactoring.lean` and the verified arithmetic theorem suggest the project already embraces “fundamental theorem” style tropical statements. Your job is to add a geometric pillar: **tropical convexity as a finite-certification theory**.

Even if these theorems are not direct dependencies, your paper and code should explain that this work expands the catalog from tropical algebra and representation-theoretic phenomena into **tropical convex and optimization geometry**.

---

## Cross-domain connection requirement

You must include at least one theorem connecting tropical convexity to another domain. Here are two strong options.

### Cross-domain theorem option 1: shortest-path / optimization connection
Interpret tropical halfspace feasibility as a system of difference constraints or min-plus linear inequalities. Prove that if a tropical polyhedron is defined by constraints of the form
`x j ≤ a i j + x k` or their min-plus analogues, then feasibility implies existence of a potential function satisfying a graph-theoretic consistency condition.

Possible Lean target:
```lean
theorem tropical_feasible_of_no_negative_cycle
    {V : Type} [Fintype V] [DecidableEq V]
    (w : V → V → ℝ)
    (hcycle : NoNegativeTropicalCycle w) :
    ∃ p : V → ℝ, ∀ u v, p v ≤ p u + w u v
```

This is a bridge from tropical convexity to **graph optimization / Bellman-Ford duality**.

### Cross-domain theorem option 2: game theory / idempotent dynamics
Show that a tropical convex invariant set for a min-plus operator yields a fixed-point or subeigenvector certificate, connecting tropical geometry with deterministic control or mean-payoff systems.

Application keywords:
`shortest paths`, `difference constraints`, `mean-payoff games`, `discrete event systems`, `idempotent analysis`, `optimization certificates`.

I strongly recommend option 1 because it is formalizable and algorithmically demonstrable.

---

## Conjecture with testable prediction

You must state at least one falsifiable conjecture and supply a computational test in `demo.py`.

A good conjecture:

### Conjecture: tropical Helly number for tropical halfspaces is exactly `n+1`
For tropical halfspaces in `(Fin n → ℝ)`, the Helly number equals `n+1`.

Informally:
- upper bound: should follow from your main theorem,
- exactness: exhibit for each `n` a family of `n+1` tropical halfspaces whose total intersection is empty, but every `n` of them intersect.

Lean declaration stub:
```lean
conjecture tropical_helly_number_exact :
  ∀ n : ℕ, HellyNumberTropicalHalfspaces n = n + 1
```

**Testable prediction:** for small `n = 1,2,3`, brute-force generated families of tropical halfspaces over small integer coefficients should exhibit extremal examples achieving the bound.

A second conjecture, if you want something bolder:

### Conjecture: tropical Carathéodory with support bound `n+1`
Every point in the tropical convex hull of a set in `Fin n → ℝ` lies in the tropical convex hull of at most `n+1` points of that set.

This is computationally testable by finite search over small integer point configurations.

---

## Lean 4 implementation guidance

### Suggested core type signatures

```lean
def TropPoint (n : ℕ) := Fin n → ℝ

def TropicalCombo {n : ℕ} (a b : ℝ) (x y : TropPoint n) : TropPoint n :=
  fun i => min (a + x i) (b + y i)

def IsTropicallyConvex {n : ℕ} (S : Set (TropPoint n)) : Prop :=
  ∀ ⦃x y : TropPoint n⦄, x ∈ S → y ∈ S →
    ∀ ⦃a b : ℝ⦄, min a b = 0 → TropicalCombo a b x y ∈ S

def tropicalSegment {n : ℕ} (x y : TropPoint n) : Set (TropPoint n) :=
  {z | ∃ a b : ℝ, min a b = 0 ∧ z = TropicalCombo a b x y}

def IsTropicalHalfspace {n : ℕ} (H : Set (TropPoint n)) : Prop := ...
def IsTropicalPolyhedron {n : ℕ} (S : Set (TropPoint n)) : Prop := ...
```

You may prefer `max`-plus conventions; that is fine, but be consistent and explicit. If Mathlib lemmas are friendlier for `max`, choose `max` and note the duality in the paper.

### Substantial theorem signatures to aim for

```lean
theorem tropicalSegment_subset
    {n : ℕ} {S : Set (TropPoint n)} (hS : IsTropicallyConvex S)
    {x y : TropPoint n} (hx : x ∈ S) (hy : y ∈ S) :
    tropicalSegment x y ⊆ S
```

```lean
theorem inter_isTropicallyConvex
    {n : ℕ} {ι : Type} (F : ι → Set (TropPoint n))
    (hF : ∀ i, IsTropicallyConvex (F i)) :
    IsTropicallyConvex (⋂ i, F i)
```

```lean
theorem tropical_helly_fin
    {n m : ℕ}
    (F : Fin m → Set (TropPoint n))
    (hpoly : ∀ i, IsTropicalPolyhedron (F i))
    (hsmall :
      ∀ s : Finset (Fin m),
        s.card ≤ n + 1 →
        ∃ x : TropPoint n, ∀ i ∈ s, x ∈ F i) :
    (∃ x : TropPoint n, ∀ i, x ∈ F i)
```

```lean
theorem tropical_feasible_of_subfamily_feasible
    {n m : ℕ}
    (F : Fin m → Set (TropPoint n))
    (hpoly : ∀ i, IsTropicalPolyhedron (F i))
    (hsmall :
      ∀ s : Finset (Fin m),
        s.card ≤ n + 1 →
        ∃ x : TropPoint n, ∀ i ∈ s, x ∈ F i) :
    ∃ x : TropPoint n, ∀ i, x ∈ F i
```

```lean
theorem tropical_feasible_of_no_negative_cycle
    {V : Type} [Fintype V] [DecidableEq V]
    (w : V → V → ℝ)
    (hcycle : NoNegativeTropicalCycle w) :
    ∃ p : V → ℝ, ∀ u v, p v ≤ p u + w u v
```

The last theorem may require introducing a graph-theoretic predicate. Good — that satisfies the novelty requirement and the cross-domain bridge.

---

## Proof tactics requirements

At least 3 theorems must involve genuinely multi-step proofs using tactics such as:
- `induction` on finite families or cardinality,
- `rcases` to unpack tropical combination witnesses,
- `by_contra` for minimal infeasible subfamily arguments,
- `field_simp` if you normalize affine/tropical parameters through real inequalities,
- nontrivial `calc` chains comparing `min`, `inf`, and translated coordinates.

Do not let the file devolve into definitional unfolding. The point is to build a durable theory.

A plausible distribution:
1. `inter_isTropicallyConvex` — structured `intro`/`rcases`/set membership proof.
2. normalized hull membership theorem — induction on finite generating set, multi-step `calc`.
3. Helly theorem — `by_contra` plus minimal counterexample on `Finset.card`.
4. graph/optimization theorem — induction on path length or constructive potential extraction.

---

## Algorithmic deliverable

You must produce a **verified algorithm or computational method**, not just existence theorems.

Best option:
- a function that, given a finite family of tropical halfspaces in low dimension,
  checks all subfamilies of size `n+1`,
- if they are all feasible, constructs or searches for a global witness,
- if not, returns a violating subfamily.

This should be justified by your Helly theorem: the search over small subfamilies is complete.

A possible API:
```lean
def checkTropicalHellyCertificate
    {n m : ℕ}
    (F : Fin m → TropicalHalfspaceData n) :
    Sum (Finset (Fin m)) (TropPoint n)
```

Interpretation:
- `Sum.inl s`: a subfamily `s` of size at most `n+1` with empty intersection,
- `Sum.inr x`: a global witness satisfying all constraints.

Even if the constructive extraction inside Lean is partial or bounded, the theorem should certify the soundness of the returned result.

---

## demo.py requirements

`demo.py` must be interactive and scientific, not decorative. It should:
1. generate random tropical halfspace families in dimensions `2` and `3`,
2. test all subfamilies of size `n+1`,
3. predict global feasibility from the Helly theorem,
4. attempt witness construction,
5. visualize low-dimensional feasible regions or witness points when possible.

At least one demo should probe your conjecture about exact Helly number by searching for extremal families.

---

## Deliverables you must produce

You must produce **all** of the following:

### 1. `FUTURE_DIRECTIONS.md`
3–5 original research directions.  
Each direction must include:
- a sentence beginning exactly with **“The key insight is...”**
- a sentence beginning exactly with **“Why now?”**
At least one direction must bridge tropical convexity to a genuinely different domain, such as control theory, combinatorial optimization, statistical physics, or representation theory.

### 2. `RESEARCH_PAPER.md`
A standalone scientific paper. A reader with no access to the code must understand:
- the definitions,
- the main theorem(s),
- why tropical Helly theory matters,
- the optimization interpretation,
- what conjectures remain open.

Do not write this as code commentary. Write it as an actual paper.

### 3. `ARTICLE.md`
Scientific American style. Broad audience, idea-driven, vivid, mathematically honest.  
**Taboo:** do not focus on formal verification machinery. Focus on the mathematics, the geometric surprise, and the applications.

### 4. Verified algorithm or computational method
As described above: a certificate procedure for tropical feasibility / Helly witness search.

### 5. `demo.py`
Interactive demonstration with at least one computational experiment testing the conjecture.

---

## Application keywords

Include these explicitly in your paper and article metadata/summary:

`tropical convexity`, `Helly theorem`, `min-plus algebra`, `idempotent geometry`, `tropical polyhedra`, `feasibility certificates`, `combinatorial optimization`, `shortest-path duality`, `difference constraints`, `discrete event systems`

---

## Final challenge

Do not settle for “we defined tropical convexity and proved intersections preserve it.” That is groundwork, not discovery.

I want a Lean development whose main message is:

> **Tropical convexity admits finite local certificates of global feasibility, and those certificates power verified optimization methods.**

If you can make Radon, Helly, and feasibility certificates coexist in one formal ecosystem, you will have created a new mathematical platform — not just solved an exercise.

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

Research domain: Tropical
Research mode: prove
