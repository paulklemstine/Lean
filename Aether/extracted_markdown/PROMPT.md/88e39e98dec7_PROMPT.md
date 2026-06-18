# Soli Deo Gloria

## Assignment: Direction 2 — Hypergraph Transversals as Tropical Convex Optimization

**Mode:** `prove`

Aristotle, this direction has the potential to turn a classical approximation-theoretic trick into a new geometric principle: **threshold rounding for hypergraph transversals is not merely combinatorial, but tropical-geometric**. If you can isolate the correct formal notion of tropical feasibility and prove that thresholding is a tropical projection or retraction onto integral transversals, you will have built a bridge between:

- hypergraph covering and LP duality,
- tropical convexity in the sense of Develin–Sturmfels,
- discrete convex analysis in the sense of Murota,
- and algorithmic rounding phenomena in approximation theory.

This is not an incremental sharpening of a known bound. The breakthrough would be a **structural explanation** for why threshold rounding works, phrased in a geometry where “extreme points” are tropical rather than Euclidean. That opens a new field: **tropical approximation algorithms**.

Use the catalog aggressively:

- `Catalog/Pythagorean/WeightedHypergraphTransversal.lean`
  - `threshold_set`
  - `weighted_threshold_cost_bound`
- `Catalog/Pythagorean/HypergraphTransversal.lean`
  - `integrality_gap_upper`

Your job is to define the right tropical objects, prove nontrivial theorems about them, and extract a verified computational method.

---

## Core mathematical vision

Let `H = (V, E)` be a finite hypergraph, with vertex weights `w : V → ℝ≥0` or `ℚ≥0`, and let the fractional transversal polytope be

\[
\mathsf{FracTrans}(H)
=
\left\{x \in \mathbb{R}_{\ge 0}^V :
\forall e \in E,\ \sum_{v\in e} x_v \ge 1
\right\}.
\]

The classical threshold rounding map at level `τ` sends a fractional point `x` to the set

\[
T_\tau(x) := \{v \in V : x_v \ge \tau\}.
\]

For rank-`d` hypergraphs, thresholding at `τ = 1/d` yields a transversal. The catalog already captures the combinatorial and weighted inequalities. What is missing is the **geometric explanation**.

The bold conjectural picture is:

1. after a suitable tropicalization of the covering constraints,
2. the feasible region acquires a natural tropical convex structure,
3. basic feasible solutions behave like tropical extremal points,
4. and threshold rounding is a tropical nearest-point/projection/retraction phenomenon.

Your formalization should not overclaim the full conjecture if the exact Develin–Sturmfels statement is too ambitious for one cycle. Instead, prove a **foundational trilogy** of theorems that make the conjecture mathematically inevitable.

---

## Precise formalization target

You should introduce at least one genuinely new definition, likely along the following lines.

### New definitions to create

1. **Tropical threshold profile** of a fractional transversal:
   - a map recording, for each edge, the minimum vertex deficit or threshold witness.
   - this should encode covering feasibility in min-plus language.

2. **Tropically stable threshold map**:
   - a map from fractional weightings to integral transversals satisfying a min-plus monotonicity property.

3. **Tropical extremality predicate** for fractional transversals:
   - not full-blown tropical polytope theory if too heavy,
   - but a mathematically meaningful extremality notion detectable from active constraints / support witnesses.

A good design would be to work first over `ℚ` or `ℝ≥0` with finite vertex type `[Fintype V] [DecidableEq V]`.

---

## Theorem targets

You must prove at least **3 deep theorems**, not trivial lemmas. Below are the recommended targets.

---

### Theorem 1: Tropical feasibility implies threshold transversal

This is the foundational bridge from tropicalized feasibility to combinatorial transversals.

#### Mathematical statement
Let `H` be a finite hypergraph of rank at most `d`. If a fractional assignment `x` satisfies all covering constraints, then thresholding at `1/d` produces an integral transversal.

Formally:

\[
(\forall e\in E,\ \sum_{v\in e} x_v \ge 1)
\land
(\forall e\in E,\ |e| \le d)
\implies
\forall e\in E,\ e \cap T_{1/d}(x) \neq \varnothing.
\]

This is the combinatorial theorem, but your proof should be reorganized to emphasize the **tropical witness principle**:
if no coordinate in `e` crosses the threshold, then every coordinate is `< 1/d`, forcing the total sum on `e` to be `< 1`, contradiction.

#### Suggested Lean 4 type signature
```lean
theorem threshold_one_div_rank_is_transversal
  {V E : Type*} [Fintype V] [DecidableEq V] [DecidableEq E]
  (H : Finset E)
  (edgeVerts : E → Finset V)
  (x : V → ℚ)
  (d : ℕ)
  (hd : 0 < d)
  (h_nonneg : ∀ v, 0 ≤ x v)
  (h_rank : ∀ e, e ∈ H → (edgeVerts e).card ≤ d)
  (h_cover : ∀ e, e ∈ H → 1 ≤ ∑ v in edgeVerts e, x v) :
  ∀ e, e ∈ H →
    ∃ v ∈ edgeVerts e, (1 : ℚ) / d ≤ x v
```

If the catalog already packages hypergraphs differently, adapt the statement to the existing structure rather than forcing this exact encoding.

#### Why this matters
This theorem should be presented not as “yet another threshold lemma” but as the first rigorous manifestation of a tropical Helly-type principle for covering constraints.

---

### Theorem 2: Tropical monotonicity / retraction property of thresholding

You need a theorem that makes threshold rounding behave like a tropical projection operator.

#### Mathematical statement
If `x ≤ y` coordinatewise, then threshold supports are monotone:
\[
x \le y \implies T_\tau(x) \subseteq T_\tau(y).
\]

This is easy by itself, so do **not** stop there. Strengthen it into an idempotent/retraction theorem on integral points:

If `χ_S` is the indicator weighting of a set `S`, and `τ ∈ (0,1]`, then
\[
T_\tau(\chi_S) = S.
\]
Hence thresholding is a retraction from suitable fractional feasible points onto integral transversals.

Even better, prove a compatibility theorem:
if `S` is already obtained by thresholding, then thresholding the indicator of `S` returns `S`, and if `x` is feasible then `T_{1/d}(x)` is feasible as an integral transversal.

#### Suggested Lean 4 type signature
```lean
def thresholdSet {V : Type*} [DecidableEq V] (τ : ℚ) (x : V → ℚ) : Finset V :=
  Finset.univ.filter (fun v => τ ≤ x v)

def indicatorWeight {V : Type*} [DecidableEq V] (S : Finset V) : V → ℚ :=
  fun v => if v ∈ S then 1 else 0

theorem threshold_monotone
  {V : Type*} [Fintype V] [DecidableEq V]
  {τ : ℚ} {x y : V → ℚ}
  (hxy : ∀ v, x v ≤ y v) :
  thresholdSet τ x ⊆ thresholdSet τ y

theorem threshold_indicator_retract
  {V : Type*} [Fintype V] [DecidableEq V]
  {τ : ℚ} (hτ0 : 0 < τ) (hτ1 : τ ≤ 1) (S : Finset V) :
  thresholdSet τ (indicatorWeight S) = S
```

#### Stronger geometric version
Define a notion such as:

```lean
def IsTropicalRetraction
  (R : (V → ℚ) → Finset V) : Prop := ...
```

and prove that `thresholdSet (1/d)` satisfies it on the subspace of feasible fractional transversals of rank `d`.

#### Why this matters
This is the first real geometric theorem: thresholding is not merely an existence argument but a **canonical map** from fractional to integral objects, preserving order and fixing integral points. That is the algebraic shadow of a tropical projection.

---

### Theorem 3: Active-edge witness theorem for tropical extremality

This should be the deepest theorem in the file. You do not need full tropical polytope machinery to prove something important. Instead, prove a **certificate theorem** characterizing when a fractional transversal is forced by a family of active edges.

#### Mathematical statement
Let `x` be a feasible fractional transversal. Suppose that for every vertex `v` in the support of `x`, there exists an edge `e_v` such that:

1. `v ∈ e_v`,
2. the covering constraint on `e_v` is active at `x`,
   \[
   \sum_{u\in e_v} x_u = 1,
   \]
3. and the family of these active constraints separates support directions strongly enough
   (e.g. uniqueness of witness patterns, or linear independence of incidence rows over `ℚ`).

Then `x` is a basic feasible solution of the covering LP.

This is a genuine bridge theorem: tropical witness data imply LP extremality.

#### Suggested Lean 4 type signature
A direct BFS statement may be too heavy if you avoid matrix formalization. You can instead prove a combinatorial surrogate:

```lean
def IsActiveOn
  {V E : Type*} [Fintype V] [DecidableEq V]
  (edgeVerts : E → Finset V) (x : V → ℚ) (e : E) : Prop :=
  ∑ v in edgeVerts e, x v = 1

def Support
  {V : Type*} [Fintype V] [DecidableEq V] (x : V → ℚ) : Finset V :=
  Finset.univ.filter (fun v => x v ≠ 0)

def HasUniqueActiveWitness
  {V E : Type*} [Fintype V] [DecidableEq V] [DecidableEq E]
  (edgeVerts : E → Finset V) (x : V → ℚ) : Prop :=
  ∀ v ∈ Support x, ∃ e, v ∈ edgeVerts e ∧ IsActiveOn edgeVerts x e
    ∧ ∀ u ∈ Support x, u ≠ v → u ∉ edgeVerts e
```

Then prove:

```lean
theorem unique_active_witness_forces_integral_threshold_vertex
  {V E : Type*} [Fintype V] [DecidableEq V] [DecidableEq E]
  (edgeVerts : E → Finset V)
  (x : V → ℚ)
  (h_nonneg : ∀ v, 0 ≤ x v)
  (h_feas : ∀ e, 1 ≤ ∑ v in edgeVerts e, x v)
  (h_wit : HasUniqueActiveWitness edgeVerts x) :
  ∀ v ∈ Support x, x v = 1
```

This is strong and nontrivial: if each support vertex has an active edge isolating it within the support, then feasibility + activeness force that coordinate to equal `1`, so the point is integral on its support. This is a tropical/extremal certificate theorem.

A slightly weaker but more robust variant is acceptable:
prove that such witness structure forces support-minimality, or that the threshold set is the unique minimal transversal extracted from `x`.

#### Why this matters
This theorem transforms “extreme point” from a linear programming abstraction into a combinatorial witness pattern. That is exactly the kind of theorem that can seed a new interaction between tropical geometry and approximation algorithms.

---

## Cross-domain theorem requirement

You must include at least one theorem explicitly bridging to another domain.

### Recommended bridge: discrete convex analysis / antimatroid-style closure

Threshold sets of feasible fractional transversals define a monotone family. Prove a closure property or accessibility statement resembling a convex geometry / antichain structure.

For example:

#### Mathematical statement
For fixed hypergraph rank bound `d`, the family
\[
\mathcal{T}_d = \{ T_{1/d}(x) : x \in \mathsf{FracTrans}(H)\}
\]
is upward closed under inclusion.

This follows from the fact that if `S = T_{1/d}(x)` and `S ⊆ S'`, then `S' = T_{1/d}(y)` for a suitable `y` obtained by raising coordinates on `S' \ S`.

#### Suggested Lean 4 type signature
```lean
theorem threshold_family_upward_closed
  {V E : Type*} [Fintype V] [DecidableEq V] [DecidableEq E]
  (edgeVerts : E → Finset V)
  (d : ℕ) (hd : 0 < d) :
  ∀ ⦃S S' : Finset V⦄,
    (∃ x : V → ℚ, S = thresholdSet ((1 : ℚ) / d) x) →
    S ⊆ S' →
    ∃ y : V → ℚ, S' = thresholdSet ((1 : ℚ) / d) y
```

#### Cross-domain significance
This connects hypergraph optimization to:
- **discrete convex analysis** via closure systems and convex families,
- **phylogenetics** via tropical tree-space threshold regions,
- **algebraic statistics** via support stratifications of feasible weight vectors.

If the upward-closure theorem is too easy, strengthen it by imposing feasibility preservation:
if `S` arises from a feasible fractional transversal and `S ⊆ S'`, then `S'` also arises from a feasible fractional transversal. This is no longer vacuous and links covering feasibility with monotone tropical support geometry.

---

## Conjecture with testable prediction

State and computationally probe the following.

### Conjecture: Tropical extremality of threshold-rounded BFS
For every finite hypergraph `H` of rank `d`, every basic feasible solution `x` of the fractional covering LP has the property that `T_{1/d}(x)` is a tropically extremal integral transversal in the threshold image family.

A falsifiable finite test:
1. enumerate all BFS points for hypergraphs on `n ≤ 8`,
2. threshold each at `1/d`,
3. compute whether the resulting integral transversal is minimal or uniquely witness-supported,
4. search for a counterexample.

A more formal Lean-side conjecture can be written as a `def` + comment theorem stub:

```lean
/--
Conjecture: thresholding a basic feasible fractional transversal at `1/d`
produces a tropically extremal integral transversal.
This is intended to be tested computationally for small hypergraphs.
-/
conjecture threshold_of_bfs_is_tropically_extremal
  {V E : Type*} [Fintype V] [DecidableEq V] [DecidableEq E]
  (edgeVerts : E → Finset V)
  (d : ℕ) :
  ...
```

You may replace `conjecture` by a documented `axiom`-free comment block if needed; Lean 4 does not support a native `conjecture` keyword. But the file must contain a precise statement and a computational test plan in comments and `demo.py`.

---

## Proof strategy architecture

You must not present only one route. Build at least 2–3 pathways and choose the most promising.

### Strategy A: Direct combinatorial contradiction via active-edge witnesses
1. Formalize thresholding and support.
2. Use `by_contra` to show failure of threshold transversality contradicts the covering inequality plus edge cardinality bound.
3. Prove witness theorems by isolating support vertices on active edges and using `calc` with finite sums to force equalities.

**Why promising:** This integrates best with the existing catalog and avoids overengineering tropical algebra too early.

---

### Strategy B: Min-plus shadow formalization
1. Define a tropical slack profile
   \[
   \sigma_x(e) := \min_{v\in e}(d x_v - 1)
   \]
   or an equivalent min-plus certificate.
2. Show that feasibility implies nonnegative tropical edge witness after thresholding.
3. Prove that thresholding preserves tropical order and is idempotent on indicator points.

**Why promising:** This is the cleanest conceptual path to the “projection” language. Even if full tropical convex hull formalization is too heavy, the min-plus slack object already gives a new structure.

---

### Strategy C: LP-extremality surrogate through incidence combinatorics
1. Encode active constraints using edge incidence rows.
2. Avoid full simplex formalization; instead prove combinatorial uniqueness from witness-separating edge families.
3. Derive integrality or support-minimality of threshold images.

**Why promising:** This is the best route to the “vertices correspond to BFS” philosophy without requiring a full matrix-polyhedron development.

**Recommended order:** A → B → C.  
Get the threshold/transversal theorem first, then the retraction theorem, then the active-witness extremality theorem.

---

## Lean tactics and proof texture requirements

You are required to produce proofs that genuinely use mathematical structure. Across the file, ensure theorems use some of:

- `induction`
- `rcases`
- `by_contra`
- `field_simp`
- multi-step `calc`
- finite sum manipulations over `Finset`
- contradiction from strict inequalities after cardinality bounds

Do **not** let the file devolve into decidable brute force.

For example, in Theorem 1:
- assume no thresholded vertex lies in edge `e`,
- derive `x v < 1/d` for all `v ∈ e`,
- sum to get `∑ x v < card(e) * (1/d)`,
- use `card(e) ≤ d` and `d > 0`,
- conclude `∑ x v < 1`, contradiction with feasibility.

This will naturally require nontrivial `calc`, cardinality estimates, and rational arithmetic.

---

## Suggested new definitions

These are only suggestions; refine them as needed.

```lean
def thresholdSet {V : Type*} [Fintype V] [DecidableEq V]
    (τ : ℚ) (x : V → ℚ) : Finset V :=
  Finset.univ.filter (fun v => τ ≤ x v)

def support {V : Type*} [Fintype V] [DecidableEq V]
    (x : V → ℚ) : Finset V :=
  Finset.univ.filter (fun v => x v ≠ 0)

def edgeSlack
    {V E : Type*} [Fintype V] [DecidableEq V]
    (edgeVerts : E → Finset V) (x : V → ℚ) (e : E) : ℚ :=
  (∑ v in edgeVerts e, x v) - 1

def tropicalEdgePotential
    {V E : Type*} [Fintype V] [DecidableEq V]
    (d : ℚ) (edgeVerts : E → Finset V) (x : V → ℚ) (e : E) : ℚ :=
  (edgeVerts e).inf' (by
    -- prove nonemptiness if your hypergraph convention requires it
  ) (fun v => d * x v - 1)

def isThresholdFeasible
    {V E : Type*} [Fintype V] [DecidableEq V]
    (edgeVerts : E → Finset V) (τ : ℚ) (x : V → ℚ) : Prop :=
  ∀ e, ∃ v ∈ edgeVerts e, τ ≤ x v

def hasUniqueActiveWitness
    {V E : Type*} [Fintype V] [DecidableEq V] [DecidableEq E]
    (edgeVerts : E → Finset V) (x : V → ℚ) : Prop := ...
```

A particularly elegant new concept would be:

```lean
def TropicallyExtremalThreshold
    {V E : Type*} [Fintype V] [DecidableEq V] [DecidableEq E]
    (edgeVerts : E → Finset V) (d : ℕ) (S : Finset V) : Prop := ...
```

defined via minimality, unique active witnesses, or irreducibility under threshold-family decomposition.

---

## Computational deliverable

You must produce a **verified algorithm or computational method**, not just theorems.

### Required algorithm
Implement a procedure that, for small finite hypergraphs:
1. enumerates candidate fractional assignments on a rational grid,
2. checks covering feasibility,
3. applies threshold rounding,
4. detects minimality / witness-extremality of the rounded transversal,
5. compares against catalog bounds such as `weighted_threshold_cost_bound` and `integrality_gap_upper`.

If exact BFS enumeration is too large for the current Lean environment, the Lean side may verify the correctness of:
- threshold feasibility checking,
- witness-extremality certification,
- minimal transversal checking.

Then `demo.py` can perform exhaustive search externally and use the verified predicates conceptually.

---

## `demo.py` requirements

Your `demo.py` must:
- generate all hypergraphs on `n ≤ 6` or sample on `n ≤ 8`,
- compute rank `d`,
- enumerate feasible fractional points on a small rational grid such as `{0, 1/d, 2/d, …, 1}`,
- apply thresholding,
- test whether the output is a transversal,
- test minimality / unique witness property,
- print candidate counterexamples to the conjecture.

It should visibly demonstrate the new theory, not just parse a theorem statement.

---

## Research significance

If successful, this project opens several new programs:

1. **Tropical approximation algorithms**  
   Rounding schemes can be studied as geometric projection operators in idempotent semirings.

2. **Discrete convexity for covering problems**  
   Hypergraph transversals may admit Murota-style convexity principles when seen through threshold images and active-edge witnesses.

3. **Phylogenetic and algebraic-statistical interpretations**  
   Tropical convex sets already govern tree spaces and statistical models; hypergraph covering could become a new combinatorial testbed for these geometries.

4. **Certified search for extremal rounding phenomena**  
   One can computationally discover hypergraph families where tropical extremality predicts better-than-worst-case integrality gaps.

This is the kind of result that changes the language of a subject.

---

## Application keywords

`tropical geometry`, `hypergraph transversals`, `covering LP`, `threshold rounding`, `min-plus algebra`, `discrete convex analysis`, `LP extremality`, `approximation algorithms`, `phylogenetics`, `algebraic statistics`, `active constraints`, `basic feasible solutions`, `support minimality`, `tropical convexity`

---

## Mandatory deliverables

You must produce **all** of the following:

1. **Lean file(s)** with:
   - at least 3 substantial theorems,
   - at least 1 genuinely new definition,
   - at least 1 cross-domain theorem,
   - minimized `sorry`.

2. **`FUTURE_DIRECTIONS.md`** with 3–5 original research directions.  
   Each direction must include:
   - a sentence beginning **“The key insight is...”**
   - a sentence beginning **“Why now?”**
   - at least one direction must bridge to a different domain.

3. **`RESEARCH_PAPER.md`** as a standalone scientific paper.  
   Someone reading only this document must understand:
   - the definitions,
   - the main theorems,
   - why they matter,
   - what conjectures remain,
   - and what experiments were run.

4. **`ARTICLE.md`** in Scientific American style.  
   Explain the mathematical ideas and why they matter to a broad audience.  
   **Taboo:** do not focus on formal verification machinery.

5. **A verified algorithm or computational method** tied to the mathematics.

6. **`demo.py`** demonstrating the result interactively and testing the conjecture on small hypergraphs.

---

## Final charge

Do not merely formalize a known threshold lemma. Build the **first rigorous tropical skeleton of hypergraph rounding theory**. The target is a suite of theorems showing that threshold rounding is monotone, retractive, witness-driven, and geometrically inevitable. If you choose the definitions well, even partial success here will create a new vocabulary for approximation theory.

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

Research domain: Pythagorean
Research mode: prove
