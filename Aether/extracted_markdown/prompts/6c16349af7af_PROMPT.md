# Soli Deo Gloria

## Mode: prove

## Assignment: Tropical Dreams, Reforged — A Formal Bridge Between \(\mathbb F_1\)-Combinatorics and Tropical Convexity

Do **not** try to formalize the full slogan “tropical schemes are equivalent to \(\mathbb F_1\)-schemes” at once. In Lean 4 + Mathlib, the breakthrough move is to isolate a **rigorous, finitely generated affine skeleton** where the philosophy becomes a theorem: finite tropical convex objects carry an \(\mathbb F_1\)-style combinatorial shadow, and base change from this shadow recovers toric/combinatorial invariants.

Your task is to create a new Lean development that proves a cluster of precise theorems showing that:

1. finite tropical generating data determine a canonical combinatorial \(\mathbb F_1\)-object,
2. the extremal tropical points correspond to irreducible generators in the \(\mathbb F_1\)-shadow,
3. the counting invariants of this shadow coincide with polyhedral/toric invariants after “base change” to classical combinatorics.

This is not a watered-down version of the grand conjecture. It is the **first nontrivial affine theorem-schema** that makes the phrase “\(\mathbb F_1\) is tropical” mathematically operational in a proof assistant.

---

## Core Vision

The original prompt is too metaphysical unless you pin down a finite, formalizable model. The right object is not an undefined scheme category, but a **finite idempotent commutative monoid equipped with a tropical convex hull operator**. This gives a concrete “\(\mathbb F_1\)-shadow” whose atoms/extreme points behave like \(\mathbb F_1\)-points, and whose additive envelope/base extension recovers a classical combinatorial semimodule or toric counting invariant.

The breakthrough theorem you should target is:

> **Finite tropical polytopes admit a canonical \(\mathbb F_1\)-skeleton, and the vertices of the tropical polytope are exactly the indecomposable generators of that skeleton. Moreover, the Euler-type counting invariant of the associated face poset is determined by these generators and matches the expected toric combinatorics in basic families.**

This opens a path to:
- tropical toric geometry inside Lean,
- combinatorial models of \(\mathbb F_1\)-geometry,
- tropical counting as \(q \to 1\) shadow of arithmetic geometry,
- algorithmic extraction of “\(\mathbb F_1\)-points” from tropical data.

---

## Precise Formalization Target

You should define a new structure capturing the finite affine situation.

### New definition 1: tropical convex generator system
A finite family \(S \subseteq \mathbb R^n\) determines its tropical convex hull under min-plus affine combinations. Since full tropical convexity over \(\mathbb R\) is heavy, work first in a discrete model such as \(\mathbb Z^n\) or \(\mathbb N^n\) with coordinatewise operations and a finite closure notion.

A practical Lean-friendly definition:

```lean
structure TropF1Skeleton (α : Type*) [LinearOrder α] [OrderBot α] where
  carrier : Finset α
  combine : α → α → α
  idem : ∀ x ∈ carrier, combine x x = x
  comm : ∀ x ∈ carrier, ∀ y ∈ carrier, combine x y = combine y x
  closed : ∀ x ∈ carrier, ∀ y ∈ carrier, combine x y ∈ carrier
  bot_mem : ⊥ ∈ carrier
```

But this is only the algebraic shell. You should strengthen it to a **finite idempotent commutative monoid** or semilattice packaged as a finite object, preferably by reusing existing order/typeclass infrastructure instead of inventing ad hoc axioms.

### New definition 2: extreme generator / \(\mathbb F_1\)-point
Define an element \(v\) of a finite idempotent commutative structure to be **extreme** if it cannot be expressed as the tropical combination of two strictly smaller distinct elements.

Prototype:

```lean
def IsExtreme {α : Type*} [Preorder α] (op : α → α → α) (v : α) : Prop :=
  ∀ a b, op a b = v → a = v ∨ b = v
```

In semilattice language, this is join-/meet-irreducibility depending on convention. You should connect your new notion to existing Mathlib notions of irreducible elements in finite lattices whenever possible.

### New definition 3: \(\mathbb F_1\)-cardinality
For a finite tropical skeleton \(X\), define its \(\mathbb F_1\)-cardinality as the number of extreme generators:

```lean
def F1Cardinality {α : Type*} [Fintype α] [DecidableEq α]
    [Preorder α] (op : α → α → α) : Nat :=
  Fintype.card {x : α // IsExtreme op x}
```

This is the correct formal substitute for “number of \(\mathbb F_1\)-points” in your finite affine model.

---

## Main Theorem Cluster

You must prove at least **3 substantial theorems**. They should not collapse to computation. Use induction on finite sets, decomposition arguments, `rcases`, contradiction, and multistep `calc`.

### Theorem 1: Extreme-point characterization via irreducibility
In a finite distributive idempotent commutative monoid/semilattice, your tropical extreme points are exactly the join-/meet-irreducible elements.

#### Mathematical statement
Let \(L\) be a finite distributive lattice. Then for \(v \in L\),
\[
\mathrm{IsExtreme}(v) \iff \mathrm{JoinIrreducible}(v)
\]
or the dual meet version, depending on whether your tropical operation is formalized as `sup` or `inf`.

#### Lean 4 type signature candidate
```lean
theorem isExtreme_iff_joinIrreducible
    {α : Type*} [DistribLattice α] [Fintype α]
    (v : α) :
    IsExtreme sup v ↔ JoinIrreducible v
```

If `JoinIrreducible` is unavailable in the exact form you need, define your own and prove equivalence to Mathlib’s lattice notion.

#### Why this is a breakthrough
This theorem says the “\(\mathbb F_1\)-points” of a tropical affine object are not poetic rhetoric: they are exactly the canonical irreducible combinatorial generators. It turns a vague philosophy into a theorem inside finite tropical algebra.

---

### Theorem 2: Finite generation by extreme points
Every element of a finite distributive tropical skeleton is generated by its extreme points.

#### Mathematical statement
If \(L\) is a finite distributive lattice, then every \(x \in L\) is the tropical combination of extreme points below it:
\[
x = \bigvee \{ e \mid e \le x,\ e \text{ extreme} \}.
\]
This is a tropical/\(\mathbb F_1\) analogue of generation by atoms, but in the correct irreducible sense.

#### Lean 4 type signature candidate
```lean
theorem sup_extremes_eq
    {α : Type*} [DistribLattice α] [Fintype α] [DecidableEq α]
    (x : α) :
    sSup {e : α | e ≤ x ∧ IsExtreme sup e} = x
```

If `sSup` over arbitrary finite sets is awkward, formulate with `Finset.sup'`:

```lean
theorem finset_sup_extremes_eq
    {α : Type*} [DistribLattice α] [Fintype α] [DecidableEq α]
    (x : α) :
    ((Finset.univ.filter fun e => e ≤ x ∧ IsExtreme sup e).sup id) = x
```

Adjust to available `Finset.sup` assumptions.

#### Why this is a breakthrough
This is your formal “base generation” theorem: the whole tropical object is reconstructed from its \(\mathbb F_1\)-points. In geometry language, the finite tropical space is controlled by its extremal combinatorial skeleton.

---

### Theorem 3: Birkhoff-style representation as an \(\mathbb F_1\)-shadow
Every finite distributive tropical skeleton is canonically isomorphic to the lattice of lower sets of its extreme-point poset.

#### Mathematical statement
Let \(L\) be a finite distributive lattice, and let \(J(L)\) be the poset of join-irreducibles. Then:
\[
L \cong \operatorname{LowerSet}(J(L)).
\]
Your contribution is to interpret \(J(L)\) as the \(\mathbb F_1\)-shadow of \(L\), and formalize the correspondence in the tropical language.

#### Lean 4 type signature candidate
A full order isomorphism may be ambitious, but aim high:

```lean
def extremePoset (α : Type*) [DistribLattice α] [Fintype α] := 
  {x : α // IsExtreme sup x}

theorem tropF1Skeleton_representation
    {α : Type*} [DistribLattice α] [Fintype α] [DecidableEq α] :
    Nonempty (α ≃o OrderIdeal (extremePoset α))
```

If `OrderIdeal` is not the exact Mathlib object, use finite sets of extreme points satisfying downward closure and prove a bijection instead:

```lean
theorem exists_extreme_downset_equiv
    {α : Type*} [DistribLattice α] [Fintype α] [DecidableEq α] :
    ∃ f : α → Finset (extremePoset α), Bijective f ∧ ...
```

#### Why this is a breakthrough
This is the first rigorous version of “tropical geometry over \(\mathbb F_1\)” that can actually be proved now: every finite distributive tropical object is recovered from a pure combinatorial incidence geometry of extremal generators. That is exactly what \(\mathbb F_1\)-geometry is supposed to do.

---

## Cross-Domain Theorem: Tropical Geometry × Euler Characteristic / Möbius Theory

You are required to bridge domains. The best bridge here is **algebraic combinatorics / topological invariants**.

### Theorem 4: Euler-type invariant from extreme generators in Boolean/toric model cases
For the face lattice of a simplex or hypercube-type finite tropical object, the alternating face count equals the \(\mathbb F_1\)-cardinality of the extreme generator model in the simplex case, and gives a computable discrepancy in the cube case.

Start with simplex-type objects, where the theorem is clean.

#### Mathematical statement
Let \(B_n\) be the Boolean lattice of subsets of an \(n\)-element set. Its extreme points under union are exactly the singletons, so
\[
\#\mathbb F_1(B_n) = n.
\]
Moreover, the order complex of proper nonempty faces of the simplex has Euler characteristic determined by this generating set.

#### Lean 4 type signature candidate
```lean
theorem boolean_isExtreme_iff_singleton
    {α : Type*} [Fintype α] [DecidableEq α]
    (s : Finset α) :
    IsExtreme sup s ↔ ∃ a : α, s = {a}

theorem F1Cardinality_boolean_eq_card
    {α : Type*} [Fintype α] [DecidableEq α] :
    F1Cardinality (α := Finset α) sup = Fintype.card α
```

You can then connect this to simplex combinatorics:
- vertices of simplex = singleton generators,
- tropical/\(\mathbb F_1\)-cardinality = number of vertices.

#### Why this matters
This gives a precise toy model for the slogan “\(\mathbb F_1\)-points are vertices.” It is not merely analogy: it becomes a theorem in the foundational family underlying toric varieties.

---

## Stronger Ambition: A Base-Change Surrogate Theorem

Do not claim literal tensoring with \(\mathbb Z\) unless you define it. Instead define a **free commutative monoid / semimodule envelope** as the classical shadow of the tropical/\(\mathbb F_1\)-skeleton.

### Theorem 5: Base-change preserves generators
Construct a free additive envelope on the extreme generators and prove that the canonical map from the tropical skeleton into this envelope is initial among maps into additive commutative monoids generated by those extreme points.

#### Lean 4 type signature candidate
This will depend on what free object infrastructure is available, but the theorem should look conceptually like:

```lean
theorem baseChange_initial
    {α β : Type*} [DistribLattice α] [Fintype α] [DecidableEq α]
    [AddCommMonoid β] :
    ∀ (f : extremePoset α → β),
    ∃! g : α → β, PreservesFiniteSup g ∧
      ∀ e : extremePoset α, g e = f e
```

If this exact categorical packaging is too heavy, prove a finite explicit formula:
every sup-preserving map is uniquely determined by values on extreme points.

#### Why this is a breakthrough
This is the finite affine content of “base change from \(\mathbb F_1\) to \(\mathbb Z\).” It says classical additive geometry is reconstructed from the tropical/\(\mathbb F_1\)-skeleton by freely extending the extremal generators.

---

## Proof Strategy Architecture

You must include **2–3 proof strategy routes**, not one.

### Strategy A: Finite distributive lattice route — most promising
This is the strongest path because Mathlib already has substantial order/lattice infrastructure.

1. Formalize `IsExtreme` in terms of `sup` or `inf`.
2. Prove `IsExtreme ↔ JoinIrreducible` by unpacking definitions and using distributive lattice identities.
3. Use the finite distributive lattice representation theorem pattern:
   every element is the supremum of join-irreducibles below it.
4. Build the \(\mathbb F_1\)-shadow as the poset of extreme elements and derive the representation/isomorphism.

**Why this is most promising:** it converts a visionary geometric slogan into order-theoretic theorems with excellent formalization leverage and nontrivial proofs.

### Strategy B: Explicit Boolean / finite set model first
Start with `Finset α` under union/intersection as a complete testbed.

1. Define `IsExtreme` for `Finset α` with `sup = union`.
2. Prove extremes are exactly singletons.
3. Prove every finite set is the union of its singleton extreme points.
4. Generalize from Boolean lattices to arbitrary finite distributive lattices by analogy and abstraction.

**Why this helps:** it gives concrete examples, computational tests, and a verified demo before attacking the abstract theorem.

### Strategy C: Polyhedral shadow route
Model a finite tropical polytope only through its vertex/face incidence poset.

1. Define a finite face poset structure.
2. Show vertices are extreme generators.
3. Prove face generation from vertices in simplex/permutohedron/hypercube families.
4. Extract \(\mathbb F_1\)-cardinality from incidence data.

**Why this is useful:** it connects directly to toric applications and gives a pathway toward future geometric generalization.

---

## Catalog-Building Guidance

You were instructed to build on catalog theorems. Use existing Mathlib results on:
- finite distributive lattices,
- irreducibles in order theory,
- finite set lattices (`Finset`, `SetLike`, lattice instances),
- Möbius inversion / locally finite orders if available,
- order isomorphisms and ideals/downsets.

Do **not** invent low-level algebraic infrastructure if Mathlib already contains it. Instead:
- wrap existing notions in tropical language,
- prove equivalence lemmas,
- then derive the new theorems.

The key architectural principle is:
> **translate tropical/\(\mathbb F_1\) rhetoric into distributive lattice semantics, then push the semantics hard.**

---

## Conjecture With Testable Prediction

You must state at least one falsifiable conjecture and provide a computational test.

### Conjecture: tropical \(\mathbb F_1\)-Euler principle for simple polytopes
For every finite simple polytope \(P\) represented by its face lattice \(L(P)\), the \(\mathbb F_1\)-cardinality defined as the number of extreme generators of the associated tropical skeleton equals the number of vertices of \(P\), and the Möbius invariant of the proper face lattice determines the same value up to a dimension-dependent sign normalization.

Prototype statement:
\[
\mathrm{F1Card}(L(P)) = f_0(P),
\qquad
|\mu_{\widehat{L(P)}}(\hat 0,\hat 1)| \stackrel{?}{=} \mathrm{F1Card}(L(P))
\]
for selected toric families (simplex, cube, cross-polytope, permutohedron) after the correct normalization.

This is **falsifiable**:
- compute extreme generators from the lattice,
- compute vertex counts and Möbius invariants,
- compare.

A counterexample is scientifically valuable; it tells you which toric families really behave as \(\mathbb F_1\)-tropical objects.

---

## Verified Computational Method

You must provide a verified algorithm, not just theorems.

### Algorithm target: extract extreme generators of a finite tropical skeleton
Implement:

```lean
def extremeElements
    {α : Type*} [Fintype α] [DecidableEq α] [Preorder α]
    (op : α → α → α) : Finset α := ...
```

Then prove correctness:

```lean
theorem mem_extremeElements_iff
    {α : Type*} [Fintype α] [DecidableEq α] [Preorder α]
    (op : α → α → α) (x : α) :
    x ∈ extremeElements op ↔ IsExtreme op x
```

Then specialize to:
- `Finset α` with union,
- small finite distributive lattices,
- face-poset-inspired examples.

This algorithm is the computational heart of the project: it turns philosophical geometry into something one can actually run and inspect.

---

## Demo Requirements

Your `demo.py` should:
1. build Boolean lattice examples for \(n=1,\dots,6\),
2. compute extreme generators,
3. display \(\mathbb F_1\)-cardinality,
4. compare against simplex vertex counts,
5. test the conjecture on cube- and simplex-type face lattices,
6. print any discrepancies as potential counterexamples.

The demo should feel like an experimental mathematics notebook, not a toy script.

---

## Deliverables (ALL mandatory)

You must produce all of the following:

1. **Lean file(s)** with at least 3 nontrivial theorems and at least one novel definition.
2. **A verified algorithm or computational method** for extracting extreme/\(\mathbb F_1\)-points.
3. **`demo.py`** demonstrating the result interactively on explicit finite examples.
4. **`RESEARCH_PAPER.md`** as a standalone scientific paper:
   - define the tropical/\(\mathbb F_1\) skeleton,
   - state the main theorems,
   - explain why finite distributive lattices are the right affine model,
   - discuss what “base change” means in this finite setting,
   - include limitations and the next conjectural leap toward toric varieties.
5. **`ARTICLE.md`** in Scientific American style:
   - explain the idea that geometry may survive when arithmetic collapses to combinatorics,
   - describe extreme points as the “atoms” of shape,
   - discuss why this hints that tropical geometry and \(\mathbb F_1\)-geometry may be two views of one structure,
   - do **not** focus on proof assistants or verification machinery.
6. **`FUTURE_DIRECTIONS.md`** with 3–5 original research directions.
   Each direction must include:
   - a sentence beginning **“The key insight is...”**
   - a sentence beginning **“Why now?”**
   At least one direction must bridge to another domain such as:
   - statistical physics,
   - information theory,
   - arithmetic geometry,
   - combinatorial optimization,
   - mirror symmetry.

---

## Application Keywords

tropical geometry, field with one element, \(\mathbb F_1\)-geometry, finite distributive lattices, idempotent algebra, toric combinatorics, extreme points, join-irreducibles, Birkhoff representation, Möbius inversion, Euler characteristic, polyhedral geometry, combinatorial base change, tropical convexity, order theory, arithmetic shadow, toric varieties, simplex vertices, face lattices, combinatorial geometry

---

## Nonnegotiable Standard

Do not settle for “here is a definition and a toy lemma.” The standard is:

- one new formal object,
- three deep theorems,
- one cross-domain bridge,
- one falsifiable conjecture,
- one verified algorithm,
- one compelling computational demo,
- one paper,
- one article,
- one future directions document.

The goal is to make a mathematician say:

> “I thought \(\mathbb F_1\) and tropical geometry were just parallel metaphors. This shows they already coincide on a real, formalizable affine frontier.”

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

Research domain: Speculative
Research mode: prove
