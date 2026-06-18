Soli Deo Gloria

## Assignment: Direction 5: Certified Finite Element Assembly Pipeline

**Mode:** prove

Build a mathematically serious, formally verified bridge between symbolic tensor rewrite normalization and finite element assembly. Do not merely restate bilinearity for sums. The target is a genuine assembly theorem: normalization must preserve the physically meaningful decomposition of strain energy into local element energies and interaction terms, and this decomposition must be algorithmically extractable.

You should treat the existing catalog results in `Pythagorean/TensorSortedRewrite.lean` — especially `energy_add`, `energy_invariant_of_rewrites`, and the `tensorRewrites_sound_*` family — as the certified local engine. Your task is to lift these from pairwise algebra to a full finite-element assembly calculus.

---

## Core Vision

Finite element assembly is usually trusted because everyone believes the algebra is routine. That is precisely the vulnerability. In safety-critical simulation, the pipeline from local element tensors to global energy evaluation is a long chain of symbolic and numerical transformations, and almost none of it is mathematically certified end-to-end.

The breakthrough target is:

> a formally verified theorem that **symbolic normalization of assembled quadratic energy expressions preserves the canonical decomposition into element-wise and coupling contributions**, together with an executable extraction algorithm that exposes those contributions for real meshes.

This is not just “FEM formalization.” It is the seed of a new certified science of **symbolic-numeric mechanics**, where rewrite systems are not cosmetic simplifiers but physically meaningful preprocessing operators.

---

## Precise Theorem Targets

You must prove at least **3 substantial theorems**, with nontrivial proofs using induction, `rcases`, `by_contra`, `field_simp`, and/or multi-step `calc`. Avoid toy lemmas.

### New definitions required

Introduce at least one genuinely new concept not already in the catalog. Suggested definitions:

1. **Assembled energy decomposition**
   - A structure encoding:
     - diagonal element contributions,
     - off-diagonal coupling contributions,
     - a proof that their sum equals the total assembled energy.

2. **Normalization-stable assembly expression**
   - A predicate saying a symbolic expression is in a normal form where each quadratic contribution is tagged by its support (element index or pair of indices).

3. **Element support graph**
   - Vertices are elements; an edge `(i,j)` exists when the normalized coupling term between `Kᵢ` and `Kⱼ` is nonzero.
   - This is the key bridge to graph theory / sparse linear algebra.

A possible Lean-style skeleton:

```lean
structure EnergyDecomposition (ι : Type _) [Fintype ι] (V : Type _) [AddCommMonoid V]
    (R : Type _) [LinearOrderedRing R] where
  selfTerm : ι → R
  couplingTerm : ι → ι → R
  total_eq :
    ∑ i, selfTerm i + ∑ i, ∑ j, couplingTerm i j = 0 -- replace by actual energy identity
```

You will likely need a better typed version over an inner product space or a bilinear form. Make it mathematically correct, not merely syntactic.

---

## Main theorem statement: finite assembled energy expansion

Let `ι` be a finite index type of elements, `V` a finite-dimensional real inner product space (or a module equipped with a symmetric bilinear form), `K : ι → V →ₗ[ℝ] V`, and `u : ι → V`. Define the assembled operator and displacement

\[
K_{\mathrm{tot}} = \sum_{i : ι} K_i, \qquad
u_{\mathrm{tot}} = \sum_{i : ι} u_i.
\]

Define strain energy by

\[
E(K,u) := \langle u, K u \rangle.
\]

Assume symmetry of each `K_i` if needed to identify pairwise couplings cleanly.

### Mathematical statement

Prove that

\[
E\!\left(\sum_i K_i, \sum_j u_j\right)
=
\sum_{i,j,k} \langle u_i, K_k u_j \rangle.
\]

Under the specialization `u_tot = u` fixed and `K_tot = ∑ i K_i`, prove

\[
E\!\left(\sum_i K_i, u\right) = \sum_i E(K_i,u).
\]

Under the full decomposition with symmetric operators, prove the canonical split

\[
E\!\left(\sum_i K_i, \sum_j u_j\right)
=
\sum_i \langle u_i, K_i u_i \rangle
+ \sum_{i \neq j} \langle u_i, K_i u_j \rangle
+ \sum_{i \neq k} \langle u_i, K_k u_i \rangle
+ \sum_{\substack{i,j,k \\ \text{not all equal}}} \langle u_i, K_k u_j \rangle,
\]

or, preferably, a cleaner partition into:
- pure element terms,
- two-body coupling terms,
- higher-overlap interaction terms induced by shared DOFs.

The exact partition should reflect the assembly semantics you formalize. The important thing is not the notation, but that the decomposition is **canonical, finite, and rewrite-stable**.

### Lean 4 target signature

A plausible target, adapted to available Mathlib structures, is:

```lean
theorem energy_sum_sum_expand
    {ι : Type _} [Fintype ι] [DecidableEq ι]
    {V : Type _} [NormedAddCommGroup V] [InnerProductSpace ℝ V]
    (K : ι → V →L[ℝ] V) (u : ι → V) :
    inner (∑ i, u i) ((∑ i, K i) (∑ j, u j))
      = ∑ i, ∑ j, ∑ k, inner (u i) (K k (u j))
```

If continuous linear maps are too heavy relative to the catalog, use a bilinear energy form:

```lean
def Energy (A : V →ₗ[ℝ] V) (u : V) : ℝ := inner u (A u)

theorem energy_assembled_expansion
    {ι : Type _} [Fintype ι] [DecidableEq ι]
    {V : Type _} [NormedAddCommGroup V] [InnerProductSpace ℝ V]
    (K : ι → V →L[ℝ] V) (u : ι → V) :
    Energy (∑ i, K i) (∑ j, u j)
      = ∑ i, ∑ j, ∑ k, inner (u i) (K k (u j))
```

### Rewrite-invariance theorem

This is the real certification theorem. If `normalize` is your certified tensor-sorted rewrite normalization procedure and `exprEnergy` interprets a symbolic expression as a real energy value, prove:

```lean
theorem assembled_energy_invariant_under_normalize
    (e : EnergyExpr) :
    exprEnergy (normalize e) = exprEnergy e
```

Then strengthen it to decomposition preservation:

```lean
theorem normalize_preserves_decomposition
    (e : EnergyExpr)
    (h : HasAssemblyDecomposition e) :
    HasAssemblyDecomposition (normalize e)
```

And, ideally, uniqueness/canonicity:

```lean
theorem normalized_decomposition_unique
    (e₁ e₂ : EnergyExpr)
    (h₁ : IsNormalized e₁) (h₂ : IsNormalized e₂)
    (hs : exprEnergy e₁ = exprEnergy e₂) :
    decompositionOf e₁ = decompositionOf e₂
```

This last theorem would be a major conceptual advance: normalization would not just preserve energy, but recover a canonical physically interpretable assembly structure.

---

## Cross-domain theorem target

You must include at least one theorem connecting FEM assembly to a different domain.

### Recommended bridge: graph theory / sparse mechanics

Define the **interaction graph** of a normalized energy decomposition:
- vertices: element indices,
- edge `i ~ j` iff the normalized coupling contribution between elements `i` and `j` is nonzero.

Then prove a theorem of the form:

\[
\text{If the interaction graph is disconnected, the total energy decomposes as a sum over connected components.}
\]

This is a deep and useful theorem because it identifies symbolic decoupling with topological separation in the mesh/connectivity graph.

Possible Lean target:

```lean
theorem energy_splits_over_connected_components
    {ι : Type _} [Fintype ι] [DecidableEq ι]
    (G : SimpleGraph ι)
    (dec : EnergyDecomposition ι V ℝ)
    (hG : dec.supportGraph = G)
    (hdisc : ¬ G.Connected) :
    ∃ (C₁ C₂ : Finset ι),
      Disjoint C₁ C₂ ∧
      C₁ ∪ C₂ = Finset.univ ∧
      totalEnergy dec
        = componentEnergy dec C₁ + componentEnergy dec C₂
```

This opens a route from symbolic mechanics to:
- sparse matrix factorization,
- domain decomposition,
- parallel FEM,
- graph partitioning,
- certified preconditioners.

Alternative cross-domain bridges:
1. **Spectral graph theory:** coupling graph sparsity bounds symbolic normalization complexity.
2. **Convex optimization:** positive semidefinite local energies imply global nonnegativity.
3. **Physics:** Noether-style invariance of normalized energy under rigid-body modes.

---

## Conjecture with falsifiable computational prediction

State at least one explicit conjecture with a test that could fail.

### Strong recommended conjecture

**Conjecture (locality of normalized coupling graph).**  
For conforming simplicial meshes with first-order Lagrange basis, the support graph extracted from the normalized assembled energy coincides with the element adjacency graph induced by shared degrees of freedom.

More precisely: if two elements share no global DOF, then the normalized decomposition contains no coupling term between them; if they do share a DOF and both local stiffness matrices are nondegenerate, then a coupling term appears generically.

This is falsifiable by computation on random meshes and random positive semidefinite local stiffness matrices.

A Lean-facing conjectural statement can be documented as:

```lean
-- Conjecture:
-- For first-order simplicial FEM assembly, supportGraph (normalize e)
-- equals the mesh adjacency graph.
```

### Testable prediction
Implement a 2D triangular mesh FEM with 100 elements and then up to 1000 elements:
1. Construct local stiffness matrices `K₁, …, Kₘ`.
2. Assemble symbolic energy `⟪u, K u⟫` with `K = ∑ i, Kᵢ`.
3. Normalize symbolically.
4. Extract support graph from normalized expression.
5. Compare to mesh adjacency graph.

Refutation conditions:
- numerical energy mismatch beyond `1e-10`,
- support graph differs from adjacency graph on generic test cases,
- symbolic normalization scales worse than practical threshold (e.g. >10× direct numerical evaluation up to 1000 elements).

---

## Proof strategy architecture

You must provide and pursue at least 2–3 proof avenues, not one.

### Strategy A: induction on finite sums via catalog bilinearity
Most direct and likely most robust.

1. Start from catalog theorem `energy_add`, which handles two-term expansion.
2. Lift to finite sums by induction on `Finset`.
3. Use repeated rewriting to obtain the triple-sum expansion.
4. Invoke `energy_invariant_of_rewrites` and `tensorRewrites_sound_*` to transport the algebraic identity from raw assembled expression to normalized form.

Why promising:
- It directly exploits vetted catalog lemmas.
- It matches the algebraic structure of FEM assembly.
- It should minimize new low-level infrastructure.

### Strategy B: abstract quadratic-form route
Conceptually cleaner and may produce stronger theorems.

1. Define `Energy A u := inner u (A u)` or a symmetric bilinear form `B u v`.
2. First prove multilinear expansion at the level of bilinear forms:
   \[
   B(\sum_i u_i, \sum_j v_j) = \sum_{i,j} B(u_i,v_j).
   \]
3. Specialize `B(u,v) = ⟪u, Kv⟫`, then linearize in `K` as well.
4. Derive decomposition and graph-support theorems from vanishing of indexed coefficients.

Why promising:
- Produces a reusable library for quadratic energies far beyond FEM.
- Gives cleaner statements for symmetry/PSD/coercivity.
- Better for cross-domain links to optimization and physics.

### Strategy C: support-aware normalization and canonical forms
Harder, but potentially revolutionary.

1. Define a symbolic syntax where each term carries support metadata.
2. Show rewrite rules preserve semantics and refine support metadata.
3. Prove normalized expressions are support-canonical.
4. Derive uniqueness of decomposition and support-graph extraction correctness.

Why promising:
- This is the route to certified symbolic preprocessing software.
- It upgrades “invariance” to “interpretable normal form.”
- It opens a field of semantics-aware rewriting for mechanics.

**Recommendation:** Begin with Strategy A for a fast correctness backbone, then build Strategy B to obtain reusable mathematical structure, and pursue Strategy C if time allows for the canonical-form breakthrough.

---

## Required theorem menu

At minimum, prove 3 substantial theorems from the following list.

### Theorem 1: finite assembled energy expansion
As above: expansion of `Energy (∑ Kᵢ) (∑ uⱼ)` into a triple sum.

### Theorem 2: normalization invariance for assembled energies
Use catalog rewrite soundness to prove assembled energy is preserved under normalization.

### Theorem 3: decomposition preservation
If an energy expression has an assembly decomposition before normalization, it still has one after normalization, with equal total energy.

### Theorem 4: graph-disconnected energy splitting
If the support graph is disconnected, total energy splits as a sum over connected components.

### Theorem 5: positivity transfer
If each local stiffness operator is positive semidefinite, then assembled energy is nonnegative:
\[
(\forall i, \forall v, \langle v, K_i v\rangle \ge 0)
\implies
\forall u, \langle u, (\sum_i K_i)u\rangle \ge 0.
\]

Lean target:

```lean
theorem energy_nonneg_of_psd_sum
    {ι : Type _} [Fintype ι]
    {V : Type _} [NormedAddCommGroup V] [InnerProductSpace ℝ V]
    (K : ι → V →L[ℝ] V)
    (hpsd : ∀ i v, 0 ≤ inner v (K i v)) :
    ∀ v, 0 ≤ inner v ((∑ i, K i) v)
```

This theorem is mathematically meaningful and physically central.

### Theorem 6: rigid-mode invariance / mechanics connection
If `r` lies in the common kernel of all local stiffness operators, then the assembled energy of `r` vanishes:
\[
(\forall i, K_i r = 0) \implies E(\sum_i K_i, r)=0.
\]
This connects directly to rigid-body modes in elasticity.

---

## Catalog build plan

Use the catalog aggressively and explicitly.

- `energy_add`:
  Use this as the induction seed and local bilinear expansion lemma.
- `energy_invariant_of_rewrites`:
  Use this to transfer mathematical identities to normalized symbolic expressions.
- `tensorRewrites_sound_*`:
  Use these to certify each normalization step, especially associativity/commutativity/tensor sorting transformations.

Do not cite these vaguely. In `RESEARCH_PAPER.md`, explain exactly how pairwise soundness is bootstrapped to finite assembled systems.

---

## Lean engineering expectations

You are working in Lean 4 with Mathlib. Prefer mathematically natural abstractions:
- `Finset` induction for finite assembly,
- `ContinuousLinearMap` or `LinearMap` depending on compatibility,
- `InnerProductSpace ℝ V` if available and convenient,
- otherwise a custom symmetric bilinear form abstraction.

Expect to use:
- `Finset.induction`,
- `simp` with finite sum lemmas,
- `rw` with `map_add`,
- multi-step `calc`,
- `rcases` to unpack decomposition structures,
- `by_contra` for uniqueness/canonicity arguments,
- `field_simp` only if ratios or weighted energies arise.

Avoid proofs that collapse to automation. The mathematical content must be visible.

---

## Verified algorithm / computational method

You must produce a verified algorithm, not just theorems.

### Required algorithm
Implement a normalization-and-extraction pipeline:

1. Build symbolic assembled energy expressions from local stiffness matrices and local displacement vectors.
2. Normalize via tensor-sorted rewrites.
3. Extract:
   - self-energy terms,
   - coupling terms,
   - support graph.
4. Numerically evaluate both:
   - original assembled energy,
   - normalized decomposition.
5. Prove semantic equality of the two evaluations.

This should be accompanied by a theorem of the form:

```lean
theorem eval_extract_normalize_correct
    (e : EnergyExpr) :
    evalDecomposition (extractDecomposition (normalize e)) = exprEnergy e
```

This is the theorem that turns algebra into software.

---

## demo.py requirements

Provide `demo.py` that:
- generates a triangular mesh,
- builds local stiffness matrices,
- assembles a global symbolic energy,
- runs normalization,
- prints extracted element and coupling energies,
- compares direct numeric energy vs normalized-evaluated energy,
- visualizes the support graph,
- benchmarks scaling up to 1000 elements.

The demo should make failure visible, not hide it.

---

## Revolutionary significance

If successful, this project opens a new direction:

- **Certified computational mechanics:** local-to-global assembly becomes a theorem, not folklore.
- **Semantics-aware symbolic preprocessing:** rewrite normalization is interpreted physically, not merely syntactically.
- **Sparse verified science:** graph extraction from normalized energies creates a bridge to domain decomposition, sparse solvers, and parallel numerical analysis.
- **Mechanics + formal algebra + graph theory:** a genuinely cross-domain architecture that could later extend to elasticity, mixed FEM, discontinuous Galerkin methods, and even quantum lattice systems.

This is the kind of result that can seed an entirely new subfield: **formal symbolic mechanics for scientific computing**.

---

## Application keywords

Certified finite element method; strain energy decomposition; symbolic-numeric mechanics; tensor rewrite systems; stiffness matrix assembly; sparse linear algebra; graph-based coupling extraction; domain decomposition; positive semidefinite assembly; structural verification; computational elasticity; safety-critical simulation; canonical normalization; quadratic forms; interaction graphs.

---

## Mandatory deliverables

You must produce **all** of the following:

1. **Lean file(s)** with the new definitions, at least 3 deep theorems, and minimal sorry usage.
2. **A verified algorithm or computational method** for normalization + decomposition extraction + evaluation correctness.
3. **`demo.py`** demonstrating the result interactively on meshes up to 1000 elements.
4. **`RESEARCH_PAPER.md`** as a standalone scientific paper:
   - problem,
   - theorem statements,
   - proof ideas,
   - computational experiment,
   - why it matters,
   - what to do next.
5. **`ARTICLE.md`** in Scientific American style:
   - engaging,
   - idea-driven,
   - broad audience,
   - no focus on formal verification machinery.
6. **`FUTURE_DIRECTIONS.md`** with 3–5 original research directions.
   - Each direction must include the exact sentences:
     - **“The key insight is…”**
     - **“Why now?”**
   - At least one direction must bridge to a different domain, such as graph partitioning, optimization, or continuum physics.

Be bold: do not formalize a bookkeeping identity. Formalize the theorem that turns finite element assembly into an interpretable, canonical, and certifiably correct symbolic-numeric process.

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
