## Assignment: Prove transversality

Mode: **prove**

Prove a genuinely new theorem package formalizing a finite-dimensional, piecewise-linear transversality principle for tropical/max-affine functions: for generic bias parameters, the corner locus is stratified by smooth affine submanifolds of the expected codimension, and the restriction of a generic linear objective to each stratum has isolated critical points.

This should not be treated as a vague “genericity” slogan. The target is a precise Lean-formal theorem family for finite max-affine models on `EuclideanSpace ℝ (Fin n)`.

---

## Research Direction

Take a finite family of affine functions
\[
\ell_i(x)=\langle w_i,x\rangle + b_i,\qquad i\in \alpha
\]
with finite index type `α`, and define the tropical / max-affine potential
\[
f(x)=\max_{i\in \alpha}\ell_i(x).
\]
Its corner locus is the set of points where at least two affine pieces tie for the maximum.

Your goal is to prove that, under explicit nondegeneracy hypotheses on the weight family `w : α → EuclideanSpace ℝ (Fin n)` and for generic biases `b : α → ℝ`, each `k`-fold tie stratum is either empty or an affine submanifold of codimension `k-1`, and that after adding a generic probing linear functional `c`, the critical points of `c` restricted to each stratum are isolated (indeed at most one per connected affine component in the strongest finite-dimensional formulation).

This is the correct formal shadow of “transversality of tropical corners” in a setting Lean can certify now.

---

## Mathematical Framing

The deep point is that for finite max-affine geometry, “generic biases” should force all active-equality constraints
\[
\ell_{i_1}(x)=\ell_{i_2}(x)=\cdots=\ell_{i_k}(x)
\]
to cut with the expected rank. Since these are linear equations in `x`, the theorem is not differential-topological in the smooth Sard sense; it is a **combinatorial-linear transversality theorem**. But once formalized, it becomes a reusable engine for:

- tropical hypersurface stratifications,
- polyhedral Morse theory,
- certified nonsmooth optimization,
- generic identifiability of active regions in neural tropicalizations,
- and eventually tropical sheaf / stratified critical point theories.

The right breakthrough is to formalize the generic geometry of corner loci once and for all, rather than proving isolated ad hoc facts about individual examples.

---

## Precise Theorem Targets

Work with:
- `n : ℕ`
- `α : Type` with `[Fintype α] [DecidableEq α]`
- `E := EuclideanSpace ℝ (Fin n)`
- weights `w : α → E`
- biases `b : α → ℝ`

Define
\[
\ell_i(x)=\mathrm{inner}(w_i,x)+b_i.
\]

For a finite set `s : Finset α`, define the tie set
\[
T_s(b)=\{x : E \mid \forall i,j\in s,\ \ell_i(x)=\ell_j(x)\}.
\]
For a chosen pivot `i₀ ∈ s`, this is equivalently the solution set to
\[
\ell_i(x)-\ell_{i₀}(x)=0 \quad (i\in s\setminus\{i₀\}).
\]

### Primary theorem: expected codimension of tie strata

A strong formal target is:

```lean
theorem tie_stratum_affine_codim
  {n : ℕ} {α : Type*} [Fintype α] [DecidableEq α]
  (w : α → EuclideanSpace ℝ (Fin n))
  (s : Finset α) (hs : s.Nonempty)
  (i0 : α) (hi0 : i0 ∈ s)
  (h_ind :
    LinearIndependent ℝ
      (fun i : {i // i ∈ s.erase i0} =>
        w i.1 - w i0)) :
  ∃ S : AffineSubspace ℝ (EuclideanSpace ℝ (Fin n)),
    (∀ x,
      x ∈ S ↔
      ∀ i ∈ s.erase i0,
        inner ℝ (x) (w i - w i0) = (0 : ℝ)) ∧
    FiniteDimensional.finrank ℝ S.direction = n - (s.card - 1)
```

This exact signature may need adaptation because `AffineSubspace` APIs often express membership via translated subspaces and because the constants from the biases should appear on the right-hand side. A more realistic version includes `b`:

```lean
theorem tie_stratum_affine_finrank
  {n : ℕ} {α : Type*} [Fintype α] [DecidableEq α]
  (w : α → EuclideanSpace ℝ (Fin n))
  (b : α → ℝ)
  (s : Finset α) (hs : s.Nonempty)
  (i0 : α) (hi0 : i0 ∈ s)
  (h_ind :
    LinearIndependent ℝ
      (fun i : {i // i ∈ s.erase i0} =>
        w i.1 - w i0)) :
  ∃ S : AffineSubspace ℝ (EuclideanSpace ℝ (Fin n)),
    (∀ x, x ∈ S ↔
      ∀ i ∈ s.erase i0,
        inner ℝ (w i - w i0) x = b i0 - b i) ∧
    FiniteDimensional.finrank ℝ S.direction = n - (s.card - 1)
```

This theorem says the `s`-fold tie locus is an affine subspace with the expected codimension `s.card - 1` whenever the difference normals are linearly independent.

### Secondary theorem: corner locus as finite union of affine strata

Define the corner locus of `f(x)=max_i ℓ_i(x)` as points where at least two indices attain the maximum. Then prove a decomposition theorem:

```lean
def IsActiveMax
  {n : ℕ} {α : Type*} [Fintype α]
  (w : α → EuclideanSpace ℝ (Fin n)) (b : α → ℝ)
  (i : α) (x : EuclideanSpace ℝ (Fin n)) : Prop :=
  ∀ j, inner ℝ (w j) x + b j ≤ inner ℝ (w i) x + b i

def CornerLocus
  {n : ℕ} {α : Type*} [Fintype α]
  (w : α → EuclideanSpace ℝ (Fin n)) (b : α → ℝ) :
  Set (EuclideanSpace ℝ (Fin n)) :=
  {x | ∃ i ≠ j, IsActiveMax w b i x ∧ IsActiveMax w b j x}
```

Then target:

```lean
theorem corner_locus_eq_union_tie_strata
  {n : ℕ} {α : Type*} [Fintype α] [DecidableEq α]
  (w : α → EuclideanSpace ℝ (Fin n)) (b : α → ℝ) :
  CornerLocus w b =
    ⋃₀ {S | ∃ s : Finset α, 2 ≤ s.card ∧ S = activeTieStratum w b s}
```

where `activeTieStratum` means the set of points where exactly the indices in `s` are active maxima, or at least all in `s` are active and tied. If “exactly” is too difficult initially, use “at least” and obtain a finite union statement.

### Generic-bias nonemptiness / exclusion theorem

A truly useful genericity statement is that for distinct index sets, the associated affine constraints do not accidentally collapse. One formalizable finite version is:

```lean
theorem generic_biases_prevent_extra_ties
  {n : ℕ} {α : Type*} [Fintype α] [DecidableEq α]
  (w : α → EuclideanSpace ℝ (Fin n)) :
  ∃ bad : Set (α → ℝ),
    IsEmptyInterior bad ∧
    ∀ b ∉ bad,
      ∀ s : Finset α, ∀ i0 ∈ s,
        LinearIndependent ℝ
          (fun i : {i // i ∈ s.erase i0} => w i.1 - w i0) →
        -- no unexpected enlargement of active set on the corresponding stratum
        expectedStratumBehavior w b s
```

If `IsEmptyInterior` is too heavy to deploy quickly, replace it by an explicit finite union of affine hyperplanes in parameter space:
- define `bad` concretely,
- prove `bad` is a finite union of proper affine subspaces,
- conclude `∃ b, b ∉ bad`.

This is often better in Lean than invoking a broad Baire-category framework.

### Critical-point isolation theorem on strata

Since affine strata have no intrinsic nonlinear criticality for constant tangent spaces, the right statement needs a probing objective. Let `c : E`. Restrict the linear functional `x ↦ inner ℝ c x` to an active tie stratum. Then critical points occur exactly when `c` is orthogonal to the stratum direction. Generically this does **not** happen; if additional active-max inequalities cut out a bounded polytope inside the tie stratum, then a generic `c` has isolated optimizer(s), typically unique on each face.

A Lean-target theorem:

```lean
theorem linear_objective_not_constant_on_tie_stratum
  {n : ℕ} {α : Type*} [Fintype α] [DecidableEq α]
  (w : α → EuclideanSpace ℝ (Fin n))
  (b : α → ℝ)
  (s : Finset α) (hs : s.Nonempty)
  (i0 : α) (hi0 : i0 ∈ s)
  (c : EuclideanSpace ℝ (Fin n))
  (h_ind :
    LinearIndependent ℝ
      (fun i : {i // i ∈ s.erase i0} =>
        w i.1 - w i0))
  (hcg :
    ¬ c ∈
      (tieDirection w s i0 hi0 h_ind).orthogonal) :
  ∀ x ∈ tieStratum w b s, ∃ y ∈ tieStratum w b s, inner ℝ c y ≠ inner ℝ c x
```

Then strengthen to a polyhedral active region version:

```lean
theorem generic_linear_functional_has_isolated_optimizers_on_active_stratum
  {n : ℕ} {α : Type*} [Fintype α] [DecidableEq α]
  (w : α → EuclideanSpace ℝ (Fin n))
  (b : α → ℝ) (c : EuclideanSpace ℝ (Fin n))
  (s : Finset α) :
  c ∉ badDirections w s →
  IsLocalFinite (criticalPointsOnActiveStratum w b c s)
```

If `IsLocalFinite` is awkward, prove a finite-set version under boundedness of the active cell:
```lean
Set.Finite (argmaxOnActiveStratum w b c s)
```

This is already nontrivial and valuable.

---

## Why this would be a breakthrough

This would create a formal bridge between:
- **tropical geometry**: corner loci of max-affine functions,
- **polyhedral geometry**: affine arrangements and face stratifications,
- **nonsmooth analysis**: active sets and criticality,
- **optimization theory**: generic uniqueness/isolation under linear perturbations,
- **neural network theory**: ReLU/max-affine region boundaries,
- **stratified Morse theory** in a finite polyhedral setting.

The conceptual leap is to formalize **generic transversality without smooth manifolds**, using only finite-dimensional linear algebra and affine geometry. This opens a new direction: machine-verified tropical differential topology.

---

## Lean 4 Type Signature Guidance

Use concrete and survivable Mathlib types:
- `EuclideanSpace ℝ (Fin n)` for ambient space,
- `Finset α` for active index sets,
- `AffineSubspace ℝ E` for strata,
- `Submodule ℝ E` for directions,
- `FiniteDimensional.finrank ℝ _` for dimensions.

Suggested definitions:

```lean
open scoped BigOperators
open FiniteDimensional

abbrev E (n : ℕ) := EuclideanSpace ℝ (Fin n)

def affineFun {n : ℕ} {α : Type*}
    (w : α → E n) (b : α → ℝ) (i : α) (x : E n) : ℝ :=
  inner ℝ (w i) x + b i

def tieSet {n : ℕ} {α : Type*} [DecidableEq α]
    (w : α → E n) (b : α → ℝ) (s : Finset α) : Set (E n) :=
  {x | ∀ i ∈ s, ∀ j ∈ s, affineFun w b i x = affineFun w b j x}

def cornerLocus {n : ℕ} {α : Type*} [Fintype α]
    (w : α → E n) (b : α → ℝ) : Set (E n) :=
  {x | ∃ i j, i ≠ j ∧
      (∀ k, affineFun w b k x ≤ affineFun w b i x) ∧
      (∀ k, affineFun w b k x ≤ affineFun w b j x)}
```

For expected codimension, define the direction as the intersection of kernels of the difference functionals:
```lean
def tieDirection {n : ℕ} {α : Type*} [DecidableEq α]
    (w : α → E n) (s : Finset α) (i0 : α) : Submodule ℝ (E n) :=
  ⨅ i : {i // i ∈ s.erase i0},
    LinearMap.ker
      ((innerSL ℝ (w i.1 - w i0)))
```
You may need the correct inner-product linear map constructor from Mathlib; if unavailable, define the linear maps manually.

---

## Proof Architecture

### Strategy A: Linear-equation realization of tie strata
Most promising.

1. **Reduce tie conditions to independent linear equations.**
   Fix `i0 ∈ s`. Show:
   \[
   x\in T_s(b) \iff \forall i\in s\setminus\{i0\},\ 
   \langle w_i-w_{i0},x\rangle = b_{i0}-b_i.
   \]
   This eliminates redundancy among pairwise equalities.

2. **Construct the affine subspace as a translated kernel intersection.**
   Let `A` be the linear map whose coordinates are the difference functionals.
   Then the tie set is either empty or `x₀ + ker A`.
   Under linear independence of normals, show `rank A = s.card - 1`, hence
   \[
   \dim \ker A = n-(s.card-1).
   \]

3. **Use finite-dimensional rank-nullity.**
   The codimension statement becomes a direct consequence of:
   - linear independence of the rows/functionals,
   - `finrank_range_add_finrank_ker`,
   - identification of the range dimension with `s.card - 1`.

Why most promising: everything is finite-dimensional and algebraic; no measure/category machinery is needed for the core theorem.

### Strategy B: Hyperplane-arrangement stratification of the corner locus
Good second theorem once Strategy A lands.

1. For each pair `(i,j)`, define the tie hyperplane
   \[
   H_{ij}(b)=\{x : \ell_i(x)=\ell_j(x)\}.
   \]
2. Show the corner locus is contained in the finite union of these hyperplanes, and refine by active-max inequalities.
3. Package each active pattern as intersection of:
   - equalities for active indices,
   - weak inequalities against inactive indices.
   This yields polyhedral strata, each with affine hull equal to a tie set from Strategy A.

This connects the theorem to polyhedral complexes and gives a decomposition useful for future tropical Morse results.

### Strategy C: Genericity via explicit bad parameter hyperplanes
Most visionary extension.

1. For each combinatorial pattern where rank drops or extra ties occur, derive an explicit affine linear relation in the bias vector `b`.
2. Define `bad : Set (α → ℝ)` as the finite union of these exceptional affine subspaces.
3. Prove:
   - each component is proper under your weight nondegeneracy assumptions,
   - therefore `bad ≠ Set.univ`,
   - hence there exist biases with expected stratification behavior.

This is preferable to abstract “almost everywhere” because it produces a certifiable exceptional set in Lean.

---

## Cross-Domain Connections

You must connect this to at least one other domain in a mathematically substantive way.

### 1. Tropical geometry
The corner locus of a max-affine function is the tropical hypersurface of a tropical polynomial with linear forms as monomials. Your theorem is a formal tropical smoothness criterion in the finite affine setting.

### 2. ReLU / maxout neural networks
Decision boundaries of maxout layers and region changes in ReLU networks are unions of such corner strata. Generic-bias transversality implies stable combinatorics of activation boundaries and isolated optimization witnesses under probing objectives.

### 3. Polyhedral Morse theory
A generic linear functional on a polyhedral complex should have isolated facewise optima. Your critical-point isolation theorem is the first Lean-formal brick toward discrete/stratified Morse theory for tropical spaces.

### 4. Oriented matroids / combinatorial geometry
The nondegeneracy condition on difference vectors is an oriented-matroid simplicity condition. Formalizing this creates a bridge from Lean linear algebra to combinatorial types of tropical arrangements.

### 5. Nonsmooth optimization
Corner loci encode Clarke subdifferential multiplicity. Isolated critical witnesses on strata are a polyhedral analogue of nondegenerate critical points, relevant for certifiable optimization and robustness.

---

## How to build on the catalog theorems

The currently listed catalog theorems are not directly in this domain. Do not force artificial dependence. Instead:
- mention them only if a structural analogy is useful,
- prioritize creating foundational definitions and lemmas that future catalog entries in tropical / polyhedral geometry can reuse.

This is a cold start, so the real contribution is infrastructure plus one strong theorem, not superficial reuse of irrelevant prior results.

---

## Minimal theorem package to complete

If the full generic-bias theorem becomes too large, complete at least the following coherent package:

1. `tieSet_eq_pivot_equations`
2. `tieSet_is_affineSubspace`
3. `finrank_tie_direction_eq_ambient_sub_rank`
4. `tie_stratum_affine_finrank`
5. `corner_locus_subset_union_pairwise_hyperplanes`
6. `active_stratum_is_polyhedral`
7. `generic_linear_functional_has_finite_optimizers_on_bounded_active_stratum`

That package is already publication-grade as a formal tropical transversality core.

---

## Suggested implementation order

1. Define affine functions, tie sets, active maxima, corner locus.
2. Prove pivot reduction for tie equations.
3. Define the linear map of difference constraints.
4. Prove the tie set is a translate of the kernel, hence affine.
5. Compute finrank using rank-nullity under linear independence hypotheses.
6. Decompose corner locus into finite union of active tie strata.
7. Add generic probing objective results on bounded strata.
8. If time permits, define explicit bad bias set and prove existence of good biases.

---

## Application keywords

`tropical geometry`, `polyhedral transversality`, `max-affine functions`, `corner locus`, `hyperplane arrangements`, `stratified Morse theory`, `nonsmooth analysis`, `ReLU networks`, `maxout networks`, `oriented matroids`, `genericity`, `affine subspaces`, `formalized mathematics`, `Lean 4`, `Mathlib`

---

## Deliverables

Required:
- Lean 4 code with minimized `sorry`
- precise theorem statements and definitions in a new file appropriate to the topic
- `FUTURE_DIRECTIONS.md`

Optional but encouraged:
- `ARTICLE.md` explaining the mathematics and formalization design
- `RESEARCH_PAPER.md` with theorem statements, proof sketches, and future conjectures
- a small visualization script for 2D/3D examples of corner strata

---

## FUTURE_DIRECTIONS.md requirements

You must produce `FUTURE_DIRECTIONS.md` with 3–5 concrete next steps, each including:
1. an exact theorem statement,
2. a Lean-oriented proof strategy,
3. a cross-domain connection.

Strong candidate next steps:
- tropical Sard theorem for finite polyhedral maps,
- polyhedral Morse inequalities on bounded tropical complexes,
- generic uniqueness of tropical projections,
- combinatorial classification of active-set stratifications via oriented matroids,
- certified robustness theorems for max-affine neural architectures derived from transversality.

Be bold: the aim is not just to prove one theorem, but to found a reusable Lean framework for **generic tropical stratified geometry**.

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

Research domain: Geometry
Research mode: prove
