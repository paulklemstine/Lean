Soli Deo Gloria

## Assignment: Direction 2: Néron Component Groups via Tropical Jacobians

**Mode:** prove

Build a formal bridge from weighted graph Laplacians and tropical Jacobians to arithmetic component groups of Jacobians of semistable curves. The goal is not to restate Raynaud’s theorem abstractly, but to extract a **computable, explicit, graph-theoretic model** for the Néron component group and its invariant factors, using canonical kernel data already present in the catalog.

This direction is potentially field-opening because it turns a notoriously subtle arithmetic invariant — the component group `Φ_J` of the Néron model of a Jacobian — into an object accessible by **integer linear algebra on the dual graph**. If successful, this gives a verified computational pipeline from semistable reduction data to arithmetic invariants, with consequences for rational points, Chabauty-style methods, and explicit BSD computations.

## Grand Challenge Theorem

Let `X/K` be a proper smooth geometrically connected curve over a discretely valued field with semistable reduction, and let `Γ` be the weighted dual graph of the special fiber of a semistable model. Let `L : ℤ^V → ℤ^V` be the weighted graph Laplacian, and `L_red` any reduced Laplacian. Let `JacTrop(Γ)` denote the tropical Jacobian / graph Jacobian / critical group of `Γ`.

The breakthrough target is to formalize a theorem of the following shape:

> **Theorem (Graph-theoretic computation of the Néron component group).**  
> For a semistable curve `X/K` with dual graph `Γ`, there is a canonical isomorphism
> \[
> \Phi_J \;\cong\; \operatorname{coker}(L_{\mathrm{red}} : \mathbb{Z}^{V-1}\to\mathbb{Z}^{V-1})
> \;\cong\; \operatorname{JacTrop}(\Gamma),
> \]
> and hence
> \[
> |\Phi_J| = \det(L_{\mathrm{red}}),
> \]
> while the invariant factors of `Φ_J` are exactly the Smith normal form invariants of `L_red`.

This is the precise arithmetic payload behind the slogan “the tropical Jacobian computes the Néron component group.”

## Formalization Target

You will likely need to separate the project into a **purely combinatorial core theorem** and an **axiomatized arithmetic interface theorem**.

### New definitions you should introduce

At least one genuinely new structure is required. The following is a strong candidate:

```lean
structure SemistableDualGraphData where
  V : Type
  [fintype_V : Fintype V]
  [decEq_V : DecidableEq V]
  laplacian : Matrix V V ℤ
  connected : Prop
  symmetric : laplacianᵀ = laplacian
  rowSumZero : ∀ v, ∑ w, laplacian v w = 0
  offDiag_nonpos : ∀ v w, v ≠ w → laplacian v w ≤ 0
```

Then define the arithmetic shadow object:

```lean
def tropicalComponentGroup (G : SemistableDualGraphData) : Type := 
  Quotient (AddCommGroup.leftRel ((LinearMap.toAddMonoidHom
    (Matrix.toLinearMap G.laplacian)) : _))
```

Or, more concretely and likely more compatible with Mathlib:

```lean
def reducedLaplacianCokernel
  {V : Type} [Fintype V] [DecidableEq V]
  (L : Matrix V V ℤ) (v0 : V) : AddCommGroupCat := ...
```

And a structure encoding the arithmetic comparison map:

```lean
structure SpecializationComponentBridge (G : SemistableDualGraphData) where
  Phi : Type
  [phiAddCommGroup : AddCommGroup Phi]
  toTrop : Phi →+ tropicalComponentGroup G
  surjective_toTrop : Function.Surjective toTrop
  injective_toTrop : Function.Injective toTrop
```

This lets you prove the combinatorial classification fully in Lean, while isolating the arithmetic theorem into a clean formal interface that can later be instantiated from Raynaud/Baker input.

## Precise theorem statements with Lean 4 type signatures

You should aim for at least the following theorem statements, possibly in slightly adapted forms to match Mathlib APIs.

### Theorem 1: Reduced Laplacian cokernel is independent of the deleted vertex
This is mathematically nontrivial and foundational.

```lean
theorem reducedLaplacianCokernel_nonempty_iso
  {V : Type} [Fintype V] [DecidableEq V] [Nonempty V]
  (G : SemistableDualGraphData)
  (v₁ v₂ : V) :
  Nonempty (reducedLaplacianCokernel G.laplacian v₁ ≅
            reducedLaplacianCokernel G.laplacian v₂) := by
  ...
```

Interpretation: the critical group / tropical Jacobian is canonically well-defined, independent of base vertex.

### Theorem 2: Cardinality of the tropical component group equals determinant of reduced Laplacian
This is the exact graph-theoretic computation of the order.

```lean
theorem card_reducedLaplacianCokernel_eq_natAbs_det
  {V : Type} [Fintype V] [DecidableEq V] [Nonempty V]
  (G : SemistableDualGraphData)
  (v0 : V)
  [Finite (reducedLaplacianCokernel G.laplacian v0)] :
  Fintype.card (reducedLaplacianCokernel G.laplacian v0) =
    Int.natAbs (Matrix.det (reducedLaplacian G.laplacian v0)) := by
  ...
```

This is the algebraic heart of `|Φ_J| = det(L_red)` once the arithmetic identification is made.

### Theorem 3: Smith normal form invariant factors classify the tropical component group
This is the structural theorem, not just the order formula.

```lean
theorem reducedLaplacianCokernel_equiv_snf
  {n : Type} [Fintype n] [DecidableEq n]
  (A : Matrix n n ℤ) :
  ∃ (ι : Type) (_ : Fintype ι) (_ : DecidableEq ι) (d : ι → ℤ),
    Nonempty (
      reducedLaplacianCokernel_fromMatrix A ≅
      Additive (∀ i : ι, ZMod (Int.natAbs (d i)))
    ) := by
  ...
```

If the exact SNF API is awkward, prove a weaker but still deep theorem asserting existence of invariant factors and compatibility of their product with `det`.

### Theorem 4: Arithmetic comparison principle
This theorem may need to be stated axiomatically if full Néron-model formalization is out of scope for one cycle, but the statement must be exact.

```lean
theorem componentGroup_equiv_tropicalJacobian
  (G : SemistableDualGraphData)
  (B : SpecializationComponentBridge G) :
  Nonempty (B.Phi ≅ tropicalComponentGroup G) := by
  exact ⟨AddMonoidHom.toAddEquiv_of_bijective B.toTrop
    ⟨B.injective_toTrop, B.surjective_toTrop⟩⟩
```

This theorem is “easy” once the bridge is assumed, but the point is to create a precise formal interface into which future arithmetic formalization can plug.

### Theorem 5: Cross-domain theorem — effective resistance controls arithmetic component growth
This is the kind of unexpected bridge that makes the project visionary.

Let `τ(Γ)` denote the weighted spanning tree count or a resistance-based energy quantity. Prove a theorem relating spectral/arithmetic complexity:

```lean
theorem componentGroup_order_eq_weightedSpanningTreeCount
  {V : Type} [Fintype V] [DecidableEq V] [Nonempty V]
  (G : SemistableDualGraphData) (v0 : V) :
  Fintype.card (reducedLaplacianCokernel G.laplacian v0) =
    weightedSpanningTreeCount G := by
  ...
```

This connects arithmetic geometry to spectral graph theory and statistical mechanics via the matrix-tree theorem. It is not a decorative corollary: it says the Néron component group order is a partition-function-like graph invariant.

## 2–3 proof strategy paths

### Strategy A: Integer-linear algebra route via cokernels and Smith normal form
**Most promising for Lean.**

1. Define the reduced Laplacian as an integer matrix obtained by deleting one row and column.
2. Show the cokernel `ℤ^(V-1) / im(L_red)` is finite when the graph is connected.
3. Use Smith normal form over `ℤ` to classify the cokernel and derive:
   - invariant factors,
   - cardinality as product of diagonal SNF entries,
   - equality with `natAbs det`.
4. Prove independence of the deleted vertex by comparing reduced Laplacians through unimodular row/column operations.

Why this is promising: it isolates the hard arithmetic into a later interface and leverages existing catalog Laplacian infrastructure plus Mathlib’s linear algebra over PID/UFD-style tools. It produces a genuinely computational algorithm.

### Strategy B: Chip-firing / divisor-theoretic route
1. Define degree-zero divisors on vertices and principal divisors as the image of the Laplacian.
2. Show the graph Jacobian is `Div⁰(Γ)/Prin(Γ)`.
3. Prove equivalence with the reduced Laplacian cokernel by choosing a base vertex and identifying degree-zero divisors with `ℤ^(V-1)`.
4. Transport canonical kernel generators from the catalog into divisor classes and prove they generate the Jacobian.

Why this matters: it aligns directly with Baker–Norine specialization language and may make the arithmetic bridge conceptually cleaner.

### Strategy C: Spectral / matrix-tree route
1. Use the weighted matrix-tree theorem to identify `det(L_red)` with the weighted spanning tree count.
2. Prove independently that the tropical Jacobian order equals the number of spanning trees using a finite-group argument.
3. Deduce determinant/cardinality formulas and connect to effective resistance or energy pairings.

Why this is exciting: it creates the strongest cross-domain bridge — arithmetic geometry ↔ spectral graph theory ↔ statistical mechanics — but it is likely secondary to Strategy A for the main formalization.

**Recommendation:** Use **Strategy A** as the core proof architecture, with Strategy B for conceptual definitions and Strategy C for the headline cross-domain theorem.

## How to build on catalog theorems

Use the catalog results not as citations but as infrastructure.

- From `Catalog/Pythagorean/TropicalBridge/MetricKernel/Theorems.lean`:
  leverage weighted Laplacian positivity / PSD structure to show finiteness and nondegeneracy on the degree-zero subspace. The key use is to control the kernel: constants are the only kernel directions in the connected case, so after reduction the determinant is nonzero.

- From `Catalog/Bridges/Catalog/Pythagorean/TropicalBridge/CanonicalKernelDefs.lean`:
  use `RestrictedLaplacianImage` as the formal model for principal divisors / Laplacian image lattice. This should become the algebraic source of the quotient defining the tropical Jacobian/component group.

The crucial conceptual step is:
- **Canonical kernel lattice generators** in the catalog should be promoted to **explicit generators for the cokernel lattice**, and then compared with the arithmetic period lattice predicted by Raynaud specialization.

## Required deep theorems

Your Lean development must include at least 3 substantial proofs using multi-step tactics. Suggested targets:

1. `reducedLaplacianCokernel_nonempty_iso`
   - likely uses `rcases`, explicit basis manipulations, and `calc`.
2. `card_reducedLaplacianCokernel_eq_natAbs_det`
   - likely uses SNF, determinant factorization, and algebraic cardinality arguments.
3. `componentGroup_order_eq_weightedSpanningTreeCount`
   - likely uses `by_contra`, matrix-tree machinery, and a nontrivial chain of equalities.

Avoid trivial closure tactics except for sublemmas. The main theorems must be mathematically meaningful.

## Cross-domain connections you must explicitly develop

1. **Arithmetic geometry ↔ Tropical geometry**  
   The central bridge: `Φ_J` versus tropical Jacobian of the dual graph.

2. **Arithmetic geometry ↔ Spectral graph theory**  
   `|Φ_J| = det(L_red)` identifies arithmetic complexity with a Laplacian determinant.

3. **Arithmetic geometry ↔ Statistical mechanics / electrical networks**  
   Through matrix-tree counts, effective resistance, and energy pairings, the component group becomes interpretable via network flow and partition-function language.

4. **Arithmetic geometry ↔ Algorithmic number theory**  
   Smith normal form of an integer matrix becomes a practical engine for computing Néron component groups of semistable Jacobians.

## Verified algorithm / computational method

You must implement a verified algorithm, not just theorem statements.

### Target algorithm
Given a finite weighted connected graph `Γ`:
1. construct `L`,
2. choose a vertex `v0`,
3. form `L_red`,
4. compute its Smith normal form,
5. output:
   - invariant factors of the tropical component group,
   - its order `det(L_red)`,
   - a list of canonical generators/classes.

This should culminate in a theorem of the form:

```lean
theorem snf_algorithm_correct
  {V : Type} [Fintype V] [DecidableEq V] [Nonempty V]
  (G : SemistableDualGraphData) (v0 : V) :
  algorithmInvariantFactors G v0 = trueInvariantFactors (tropicalComponentGroup G) := by
  ...
```

If exact equality to a canonical list is cumbersome, prove soundness/completeness statements for the produced decomposition.

## Conjecture with testable prediction

State and computationally probe a falsifiable conjecture such as:

> **Conjecture (genus-2 semistable hyperelliptic match).**  
> For every genus-2 hyperelliptic curve over a discretely valued field with semistable reduction and dual graph `Γ`, the invariant factors of the Néron component group `Φ_J` agree with the Smith normal form invariant factors of the weighted reduced Laplacian of `Γ`.

**Testable prediction:** For each tabulated genus-2 semistable reduction type in the literature, the SNF computed from the dual graph matches the published component group structure. A single mismatch falsifies the conjecture or reveals an error in the dual graph extraction/specialization model.

You should encode at least a graph-level computational version in Lean/Python:
- build representative dual graphs for standard genus-2 reduction types,
- compute SNF invariants,
- compare against expected group structures.

## Why this would be a breakthrough

If formalized cleanly, this work would create a **verified arithmetic-tropical computation pipeline**:
semistable model → dual graph → Laplacian → SNF → component group.

That would open:
- explicit computation of local arithmetic invariants,
- new experiments for BSD local factors,
- graph-theoretic heuristics for Jacobian degeneration,
- tropical approximations to p-adic arithmetic invariants,
- possible extensions to metrized complexes, higher-dimensional skeleta, and non-Archimedean period maps.

This is not an incremental extension of chip-firing theory. It is a proposal to make a central invariant of arithmetic geometry computable through tropical linear algebra in a way precise enough to support theorem discovery.

## Application keywords

Néron model, component group, tropical Jacobian, graph Jacobian, critical group, semistable reduction, dual graph, Smith normal form, reduced Laplacian, matrix-tree theorem, Baker specialization, Raynaud theorem, weighted spanning trees, effective resistance, arithmetic geometry, tropical geometry, p-adic analysis, algorithmic number theory, spectral graph theory, electrical networks, BSD local factors

## Deliverables (MANDATORY)

You must produce all of the following:

1. **Lean file(s)** with:
   - at least 3 deep theorems,
   - at least 1 novel definition,
   - at least 1 cross-domain theorem,
   - minimized sorry usage.

2. **FUTURE_DIRECTIONS.md**
   - 3–5 original research directions,
   - each direction must include the exact sentences:
     - “The key insight is...”
     - “Why now?”
   - at least one direction must bridge to a different domain.

3. **RESEARCH_PAPER.md**
   - standalone scientific document,
   - must explain the problem, theorem statements, proof architecture, computational method, significance, and next questions,
   - readable without access to the code.

4. **ARTICLE.md**
   - Scientific American style,
   - engaging and broadly accessible,
   - explain the ideas and why they matter,
   - do **not** focus on formal verification machinery.

5. **A verified algorithm or computational method**
   - SNF-based computation of tropical/component-group invariants.

6. **demo.py**
   - interactive demonstration,
   - input a weighted dual graph,
   - compute reduced Laplacian, determinant, SNF invariant factors, spanning-tree count,
   - showcase genus-2 example graphs and compare predicted component groups.

## Execution advice

Organize the work in two layers:

- **Layer 1: fully formal combinatorial engine**
  - reduced Laplacian,
  - cokernel,
  - SNF classification,
  - determinant/order theorem,
  - matrix-tree theorem connection.

- **Layer 2: arithmetic interface**
  - a precise abstraction of the specialization map and component-group comparison,
  - theorem stating that once the bridge assumptions are verified, the graph computation yields `Φ_J`.

This layered architecture makes the project both honest and visionary: the combinatorial theorem is fully formal and already powerful, while the arithmetic bridge is stated sharply enough to guide future formalization of Raynaud/Baker theory.

Aim for the moment where a number theorist can say: “You mean the component group of a Jacobian can be read off from a Smith normal form of the dual graph — with proofs and experiments?” That is the standard.

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

Research domain: Pythagorean
Research mode: prove
