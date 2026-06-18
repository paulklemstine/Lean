Soli Deo Gloria

## Assignment: Direction 1: Non-Separated Extensions via Overlapping Support Theory

**Mode:** `prove`

Prove genuinely new theorems that extend the catalog’s separated-support tropical/Laplacian correspondence to **arbitrary nonempty vertex subsets**. The goal is not a cosmetic generalization: it is to identify the exact algebraic object that replaces independence of supports, and to show that overlapping harmonic generators are governed by a computable interaction matrix whose Smith normal form recovers the same canonical quotient data as the restricted Laplacian.

This is the point where the theory stops being a theorem about a nice combinatorial regime and becomes a theorem about the **entire graph Jacobian seen through tropical overlap coordinates**.

---

## Core Vision

The catalog already establishes a clean bridge for separated sets:
- `Catalog/Pythagorean/TropicalBridge/SNFCorrespondence.lean`
- `Catalog/Pythagorean/TropicalBridge/TropicalKernelRigidity.lean`
- `Catalog/Pythagorean/TropicalBridge/Defs.lean`

Those results suggest that separation is not the true invariant — it is only the regime where interaction terms vanish. The breakthrough is to show that for arbitrary `S`, the obstruction to separation is itself **linear and classifiable**, and that after passing to the right quotient, these interaction terms are exactly diagonalized by Smith normal form.

If this works, the tropical-critical correspondence becomes a **complete structure theorem** for arbitrary supports, not merely a partial theorem for disjoint ones.

---

## New Mathematical Object to Introduce

Define a new structure capturing overlap interactions.

### Proposed definition
For a finite graph `G` and nonempty finite vertex subset `S`, define the **overlap interaction matrix**
\[
\Omega_S := L_S - \operatorname{diag}(L_S),
\]
or more conceptually, define an abstract quotient built from canonical generators modulo overlap relations.

A stronger and more novel formal object is:

```lean
structure OverlapSupportData (V : Type _) [Fintype V] [DecidableEq V] where
  S : Finset V
  nonempty : S.Nonempty
  interaction : Matrix (Fin S.card) (Fin S.card) ℤ
  symmetric : interactionᵀ = interaction
  zero_diag : ∀ i, interaction i i = 0
```

But the truly useful concept is the quotient:

```lean
def OverlapKernelQuotient
  {V : Type _} [Fintype V] [DecidableEq V]
  (G : SimpleGraph V) (S : Finset V) : AddCommGroupCat :=
  AddCommGrp.of <| (FreeAbelianGroup S) ⧸
    AddCommGroup.closure (overlapRelations G S)
```

where `overlapRelations G S` is a new definition encoding pairwise interference among canonical tropical generators. Even if the exact category-level packaging changes in Lean, you should introduce **at least one new concept** whose mathematical content is: *the quotient of canonical generator data by overlap relations*.

This is the right replacement for the separated-set regime.

---

## Precise Theorem Targets

You should aim for at least the following three substantial theorems.

### Theorem 1: Interaction presentation theorem
For any connected finite graph and any nonempty subset `S`, the canonical overlap quotient admits a presentation by the restricted Laplacian.

#### Mathematical statement
Let `G` be a finite connected graph, and let `S ⊆ V(G)` be nonempty. Let `L_S` denote the restricted Laplacian on `S`. Then the overlap kernel quotient is canonically isomorphic to
\[
\mathbb{Z}^{|S|}/\operatorname{Im}(L_S).
\]

This is the central theorem: it says that overlap relations are not mysterious nonlinear tropical artifacts; they are exactly the image relations imposed by the restricted Laplacian.

#### Lean-style target signature
Adapt names to the actual catalog definitions, but the target should look approximately like:

```lean
theorem overlapKernelQuotient_equiv_laplacianCokernel
  {V : Type _} [Fintype V] [DecidableEq V]
  (G : SimpleGraph V) [Fintype V]
  (hconn : G.Connected)
  (S : Finset V) (hS : S.Nonempty) :
  Nonempty (
    OverlapKernelQuotient G S ≃+
      LaplacianCokernel (restrictedLapMat G S)
  )
```

If `LaplacianCokernel` is already defined as a quotient by the span/image of the matrix, use that exact target. If a canonical equivalence is too difficult at first, prove a weaker but still meaningful theorem giving an explicit surjective homomorphism with kernel equal to the overlap relations, then upgrade to an equivalence.

---

### Theorem 2: Recovery of separated theory as the zero-interaction case
Show that your new theory strictly extends the old one.

#### Mathematical statement
If `S` is separated in the catalog sense, then the overlap interaction relations vanish, the overlap quotient reduces to the separated canonical quotient, and the presentation theorem specializes to the existing SNF correspondence.

Equivalently: separation is exactly the regime in which off-diagonal interaction terms disappear.

#### Lean-style target signature
```lean
theorem overlapRelations_eq_bot_of_separated
  {V : Type _} [Fintype V] [DecidableEq V]
  (G : SimpleGraph V) (S : Finset V)
  (hsep : SeparatedSet G S) :
  overlapRelations G S = ⊥
```

and then

```lean
theorem overlapKernelQuotient_of_separated
  {V : Type _} [Fintype V] [DecidableEq V]
  (G : SimpleGraph V) (S : Finset V)
  (hS : S.Nonempty) (hsep : SeparatedSet G S) :
  Nonempty (
    OverlapKernelQuotient G S ≃+
      LaplacianCokernel (restrictedLapMat G S)
  )
```

This theorem is conceptually crucial: it proves your construction is not ad hoc, but the correct extension.

---

### Theorem 3: SNF diagonalizes overlap interactions
Prove that the overlap quotient decomposes according to the invariant factors of the restricted Laplacian, and interpret the basis change as diagonalizing interaction among overlapping generators.

#### Mathematical statement
Let `U L_S V = D` be a Smith normal form decomposition of `L_S`. Then the overlap quotient is isomorphic to the direct sum of cyclic groups determined by the nonzero diagonal entries of `D`. Moreover, the change-of-basis matrices `U,V` transport the canonical overlap generators to a basis in which interaction relations decouple.

This theorem converts “overlap” from a combinatorial nuisance into explicit arithmetic structure.

#### Lean-style target signature
A plausible target:

```lean
theorem overlapQuotient_snf_decomposition
  {V : Type _} [Fintype V] [DecidableEq V]
  (G : SimpleGraph V) (S : Finset V) (hS : S.Nonempty) :
  ∃ (P Q D : Matrix (Fin S.card) (Fin S.card) ℤ),
    IsSmithNormalForm P (restrictedLapMat G S) Q D ∧
    Nonempty (
      OverlapKernelQuotient G S ≃+
      smithNormalFormCokernel D
    )
```

If `IsSmithNormalForm` / `smithNormalFormCokernel` are named differently in Mathlib or the catalog, adapt accordingly. The point is to prove a theorem with explicit existential witnesses and a meaningful quotient decomposition, not just “SNF exists”.

---

## Optional but High-Value Fourth Theorem: Cross-domain spectral bridge

This is where the project becomes field-opening.

### Theorem 4: Overlap interactions control a spectral or energy quantity
Connect the overlap interaction matrix to discrete potential theory or network physics.

#### Mathematical statement
For `x ∈ ℤ^S`, the quadratic form
\[
x^\top L_S x
\]
equals the total interaction energy of the corresponding overlapping generator combination. In particular, zero energy classes correspond exactly to classes killed in the quotient.

This creates a bridge from tropical/Jacobian structure to **electrical network theory** and discrete Dirichlet energy.

#### Lean-style target signature
```lean
theorem restrictedLap_quadratic_form_eq_overlap_energy
  {V : Type _} [Fintype V] [DecidableEq V]
  (G : SimpleGraph V) (S : Finset V) :
  ∀ x : Fin S.card → ℤ,
    quadraticForm (restrictedLapMat G S) x =
      overlapEnergy G S x
```

Even a weaker theorem — e.g. nonnegativity under suitable coercions, or a decomposition into diagonal minus adjacency terms — would be valuable.

This is your required **cross-domain connection**: graph Jacobians + tropical support theory + electrical network energy / discrete physics.

---

## Why This Would Be a Breakthrough

The current catalog suggests that tropical generators behave cleanly when supports do not interfere. But real mathematics begins when interference is unavoidable.

If you prove that arbitrary overlap is still classifiable by the restricted Laplacian and fully diagonalizable by SNF, then:

- the separated theory becomes the rank-one shadow of a much richer general theory;
- the graph Jacobian is recovered from tropical support data for **all** subsets, not merely separated ones;
- the “interaction terms” become computable, canonical invariants rather than proof obstacles;
- this opens a path to tropical harmonic representation theory on graphs, where support overlap behaves like coupling between modes.

This is not an incremental extension. It would turn a local correspondence into a **global algebraic dictionary**.

---

## Building Explicitly on Catalog Results

Use the catalog aggressively and explicitly.

### From `SNFCorrespondence.lean`
- `SeparatedSet`
- `restrictedLapMat`
- `LaplacianCokernel`

Use these as the baseline presentation objects. Your theorem should literally explain how the old separated proof is recovered when overlap relations vanish.

### From `TropicalKernelRigidity.lean`
- `TropProjEquiv`
- `disjoint_support_unique_up_to_tropProjEquiv`

This is the conceptual clue: rigidity under disjointness should be replaced by a weaker statement saying that non-disjoint generators are rigid only **modulo overlap relations**. In other words, where the old theory gave uniqueness up to tropical projective equivalence, the new theory should give uniqueness up to projective equivalence plus a Laplacian-generated interaction submodule.

### From `Defs.lean`
- `graphLaplacian`
- `firingIndependentOn`

These are the raw materials. In particular, `firingIndependentOn` likely captures the old “noninteracting” regime. Your job is to identify the exact quotient when this hypothesis fails.

---

## Proof Strategy Architecture

You must include at least 2–3 multi-step proof pathways in the development. Here are the most promising ones.

### Strategy A: Presentation-by-relations route (most promising)
1. **Define overlap relations explicitly** as the subgroup generated by pairwise interaction identities among canonical generators supported on `S`.
2. **Construct a homomorphism**
   \[
   \phi : \mathbb{Z}^{|S|} \to \text{canonical quotient object}
   \]
   sending basis vectors to canonical generators.
3. **Show** `ker φ = Im(L_S)` by two inclusions:
   - every Laplacian row relation is a valid overlap relation;
   - every overlap relation can be reduced, via firing identities and support bookkeeping, to an integral combination of Laplacian rows.
4. Conclude by first isomorphism theorem.

Why this is most promising: it aligns directly with the algebraic quotient definitions already present in the catalog, and it gives a theorem strong enough to feed directly into SNF.

Expected tactics: `ext`, `constructor`, `rcases`, subgroup/image manipulations, quotient arguments, `by_contra`, nontrivial `calc`.

---

### Strategy B: Decompose `L_S = D + N` and eliminate interactions iteratively
1. Write the restricted Laplacian as diagonal degree part plus internal adjacency interaction part.
2. Interpret off-diagonal entries as pairwise overlap couplings.
3. Perform row/column operations corresponding to legal basis changes in the free abelian group on generators.
4. Show that each elimination step preserves the quotient isomorphism class and eventually yields SNF.

Why it is powerful: this gives not just existence of the quotient but an explicit computational mechanism, ideal for the required verified algorithm and `demo.py`.

Expected tactics: induction on `|S|` or on number of internal edges, `field_simp` where rational intermediate expressions appear in determinant/SNF lemmas, matrix `calc`, repeated `rcases` on adjacency cases.

---

### Strategy C: Energy/potential-theoretic route
1. Associate each formal generator combination on `S` with a discrete potential or divisor.
2. Show that overlap relations are exactly zero-energy gauge transformations modulo restricted firing.
3. Use positivity / semidefinite properties of the Laplacian quadratic form to characterize the kernel and quotient.
4. Recover the presentation theorem by identifying energy-null moves with image of `L_S`.

Why it matters: this creates the cross-domain bridge and could produce the deepest conceptual paper, even if it is technically harder.

Expected tactics: induction on support size, `by_contra` using positivity, careful decomposition of sums over edges.

---

## Most Promising Route

**Start with Strategy A**, then use Strategy B for the SNF theorem and Strategy C for the cross-domain theorem.

- Strategy A gives the cleanest path to the core isomorphism.
- Strategy B turns the core theorem into a computable decomposition.
- Strategy C explains why the theorem is natural and not merely algebraic bookkeeping.

This layered architecture is exactly what can produce a result that feels inevitable in hindsight.

---

## Required Deep Proof Tactics

Your file must contain at least 3 theorems with genuinely nontrivial proofs. Concretely, target proofs that use combinations of:

- `induction` on `S.card`, number of internal edges, or relation length;
- `rcases` for decomposition of graph adjacency or subgroup membership;
- `by_contra` to rule out spurious kernel elements;
- `field_simp` if rationalized matrix formulas arise in determinant/SNF auxiliary lemmas;
- multi-step `calc` chains for matrix identities and quotient equivalences.

Avoid any theorem whose content collapses to `native_decide`, `decide`, `norm_num`, or `rfl`.

---

## Conjecture with Testable Prediction

### Main falsifiable conjecture
For every connected finite graph `G` and every nonempty subset `S ⊆ V(G)`, the canonical overlap kernel quotient is isomorphic to `LaplacianCokernel (restrictedLapMat G S)`, and the SNF transition matrices can be chosen to satisfy a tracking predicate extending `TracksCanonicalGens`.

#### Lean-style conjecture skeleton
```lean
conjecture tracksCanonicalGens_of_overlap_snf
  {V : Type _} [Fintype V] [DecidableEq V]
  (G : SimpleGraph V) [Fintype V]
  (hconn : G.Connected)
  (S : Finset V) (hS : S.Nonempty) :
  ∃ P Q D,
    IsSmithNormalForm P (restrictedLapMat G S) Q D ∧
    TracksCanonicalGensOverlap G S P Q
```

A single explicit graph/subset counterexample for `n ≤ 7` refutes this. That makes it scientifically meaningful.

---

## Verified Computational Method

You must produce a verified algorithm, not only theorem statements.

### Required algorithm
Implement a procedure that:
1. enumerates all nonempty subsets `S` of a finite graph’s vertex set,
2. computes `restrictedLapMat G S`,
3. computes or certifies its SNF/invariant factors,
4. constructs the predicted overlap quotient invariants,
5. checks whether they agree,
6. optionally checks a `TracksCanonicalGensOverlap` predicate.

Even if full SNF extraction is difficult in Lean, you can:
- verify correctness of invariant-factor computations for small matrices,
- prove that your reduction steps preserve cokernel type,
- export data for `demo.py`.

The algorithm itself is part of the theorem ecosystem: it turns the conjecture into an experimental research program.

---

## Demo Requirements

Create `demo.py` that:
- enumerates connected graphs with `n ≤ 7`,
- loops over all nonempty `S`,
- displays `restrictedLapMat G S`,
- computes SNF via Python/Sage/SymPy,
- reports invariant factors,
- compares with the overlap quotient prediction,
- highlights any failure,
- provides at least one visual example where a separated set and a non-separated set on the same graph have visibly different off-diagonal interaction structure but the same theorem framework explains both.

The demo should make the theorem feel tangible.

---

## Cross-Domain Connections to Emphasize

You must include at least one theorem or substantial discussion connecting this work to another domain.

### Strong options
1. **Electrical networks / discrete physics**  
   The restricted Laplacian quadratic form measures interaction energy of overlapping generators.
2. **Algebraic number theory / finite abelian groups**  
   SNF identifies arithmetic invariants of overlap quotients, making the graph-Jacobian side look like explicit class-group decomposition.
3. **Tropical geometry**  
   Overlapping support theory is a combinatorial model of interacting tropical divisors; separation corresponds to vanishing tropical interference.
4. **Spectral graph theory**  
   Off-diagonal interaction terms encode internal coupling on `S`; their elimination by SNF is a discrete analogue of mode diagonalization.

At least one of these should be made formal in theorem form, not merely discussed.

---

## Application Keywords

Use and foreground these:
**graph Jacobian, Smith normal form, Laplacian cokernel, tropical geometry, chip-firing, finite abelian groups, discrete potential theory, electrical networks, spectral graph theory, interaction matrix, canonical generators, quotient presentation, invariant factors**

---

## Deliverables (ALL mandatory)

You must produce all of the following.

### 1. Lean development
A new Lean file proving at least 3 substantial theorems, introducing at least 1 novel definition, and minimizing sorrys.

### 2. `FUTURE_DIRECTIONS.md`
Include 3–5 original research directions. Each direction must contain:
- a sentence beginning **“The key insight is...”**
- a sentence beginning **“Why now?”**

At least one direction must bridge to a different domain, such as electrical network theory, tropical geometry, or arithmetic statistics.

### 3. `RESEARCH_PAPER.md`
A standalone scientific paper explaining:
- the problem,
- the new definitions,
- the main theorems,
- proof ideas,
- computational evidence,
- why this changes the landscape,
- what should happen next.

A reader with no access to the code must still understand the discovery.

### 4. `ARTICLE.md`
Write in Scientific American style:
- engaging,
- broad audience,
- idea-centered,
- significance-focused.

Do **not** focus on formal verification machinery. Focus on the mathematics and why overlap unexpectedly becomes classifiable.

### 5. Verified algorithm / computational method
As described above.

### 6. `demo.py`
Interactive or script-based demonstration of the conjecture and theorem behavior on small graphs.

---

## Concrete Success Criteria

You succeed if you can show, in a mathematically serious way, that:

1. the separated-set correspondence was only the zero-interaction boundary case;
2. arbitrary overlap is encoded by a linear interaction object;
3. the restricted Laplacian still presents the canonical quotient;
4. Smith normal form diagonalizes overlap interactions;
5. the resulting structure is computable and experimentally testable.

That is a theorem worth having. That is a new chapter, not a footnote.

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
