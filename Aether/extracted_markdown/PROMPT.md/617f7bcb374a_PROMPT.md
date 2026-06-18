## Assignment: Algebra–Tropical–RepresentationTheory Tropical Hecke Realization Duality via Idempotent Convolution Semimodules and Certified Spherical Function Reconstruction

**Mode:** prove

Prove a genuinely new finite tropical Satake/Hecke reconstruction theorem in Lean 4, with an explicit algorithmic extraction layer. This should not be a metaphorical analogy: make the reconstruction theorem mathematically exact on a finite separated class of idempotent convolution semimodules, and prove that evaluation data against tropical spherical functionals determines the algebraic object up to canonical equivalence.

Target file:

`Bridges/TropicalHeckeRealizationDuality.lean`

You should also produce:

`Bridges/TropicalHeckeRealizationDuality/FUTURE_DIRECTIONS.md`

with **3–5 concrete breakthrough next steps** that extend this finite theorem toward tropical Satake, tropical Tannakian reconstruction, and polyhedral representation theory.

---

## Core Vision

Build the first **formal finite tropical Hecke realization theorem**:

> finitely generated idempotent convolution semimodules with a Hecke-type generating family are equivalent, on a separated/nondegenerate subcategory, to finite tropical spherical data encoded by evaluation matrices against extremal spherical functionals.

This is revolutionary because it turns vague tropical representation-theoretic intuition into a certifiable finite theorem:
- **representation theory** becomes recoverable from **evaluation geometry**,
- **convolution structure constants** become recoverable from **tropical spherical data**,
- **polyhedral/coweight data** becomes a complete invariant for a separated finite class.

This opens a concrete route toward:
- tropical Satake transforms,
- finite tropical harmonic analysis,
- certified reconstruction of idempotent convolution algebras,
- algorithmic tropical Langlands toy models,
- polyhedral semantics for representation-theoretic data.

Application keywords: **tropical Hecke algebra, idempotent semiring, semimodule duality, spherical functions, Satake reconstruction, polyhedral representation theory, certified algebra recovery, residuation, extremal functionals, tropical harmonic analysis**.

---

## Mathematical Target

Let `S` be an idempotent semiring and `M` a finitely generated `S`-semimodule equipped with an associative `S`-bilinear product `star : M → M → M`. Let `K = {k_i | i ∈ ι}` be a finite generating family such that each `k_i ⋆ k_j` lies in the `S`-span of `K`. Define the **Hecke envelope** `H(K)` to be the smallest `star`-stable subsemimodule containing `K`.

Define a **tropical spherical functional** to be a semimodule morphism `φ : M →ₛₗ[S] S` satisfying multiplicative/eigenfunction behavior on the Hecke basis in the tropical sense: for each basis element `k_i`, there exists a scalar `λ_{φ,i}` such that
`φ (k_i ⋆ x) = λ_{φ,i} ⊗ φ x`
for all `x` in the Hecke envelope, where `⊗` is semiring multiplication and additive structure is idempotent.

You should formalize a finite version that is actually Lean-manageable: if full semimodule infrastructure over general idempotent semirings is too heavy, specialize first to a finite free semimodule model such as tropical coefficient vectors `ι → S` with finite `ι`, and convolution encoded by structure constants.

---

## Precise Theorem Statement

### Theorem A: Finite Tropical Hecke Reconstruction

Work in a finite free model. Let `ι` be a finite type indexing a Hecke basis. Let structure constants be a family
`c : ι → ι → ι → S`
defining convolution by
`(e i) ⋆ (e j) = ⨆ k, c i j k • e k`
and extending bilinearly/idempotently.

Assume:
1. **Associativity:** the structure constants satisfy the tropical associativity relations.
2. **Finite generation:** `ι` is finite and the basis spans the Hecke envelope.
3. **Separation by spherical functionals:** there exists a finite type `Ω` and functionals `φ_ω : M →ₛₗ[S] S` such that basis vectors are separated by their evaluation tuples.
4. **Residuated nondegeneracy/extremality:** the evaluation matrix has enough extremal rows/columns to identify basis elements uniquely up to tropical scaling/permutation.

Then prove:

- there exists a **canonical spherical basis** `B : ι ≃ ι'` extracted from extremal evaluation profiles, unique up to permutation and tropical scaling;
- the full structure constants `c i j k` are determined by the evaluation matrix
  `E ω i = φ_ω (e i)`;
- from finite evaluation data one can reconstruct:
  1. a minimal Hecke generating set,
  2. the multiplication table,
  3. witnesses certifying minimality and correctness.

### Lean-facing theorem shape

You may need to define a bundled finite structure for a tropical Hecke datum. A plausible signature is:

```lean
structure FiniteTropicalHeckeData (S : Type _) [Semiring S] [OrderBot S] :=
  (ι : Type _)
  [fintype_ι : Fintype ι]
  [decEq_ι : DecidableEq ι]
  (c : ι → ι → ι → S)

structure FiniteSphericalData (S : Type _) [Semiring S] [OrderBot S] :=
  (ι : Type _)
  [fintype_ι : Fintype ι]
  [decEq_ι : DecidableEq ι]
  (Ω : Type _)
  [fintype_Ω : Fintype Ω]
  [decEq_Ω : DecidableEq Ω]
  (eval : Ω → ι → S)
```

Then target a theorem of the following form:

```lean
theorem finite_tropical_hecke_reconstruction
  {S : Type _} [Semiring S] [OrderBot S]
  [Fintype S] -- if needed for algorithmic finite search in the first version
  (H : FiniteTropicalHeckeData S)
  (h_assoc : TropicalAssociative H.c)
  (h_sep : SeparatedBySphericalFunctionals H)
  (h_nondeg : ResiduatedNondegenerate H) :
  ∃ SD : FiniteSphericalData S,
    SphericalRealizes H SD ∧
    ReconstructionRecovers SD H.c ∧
    CanonicalBasisUniqueUpToScalingPerm H SD
```

If the generality above is too ambitious, prove a concrete theorem first for `S = ℝ∞max` or a finite linearly ordered idempotent semiring abstraction already available in Mathlib-compatible form.

---

## Second Theorem: Polyhedral/Coweight Realization Functor

Construct a functorial passage from finite Hecke data to finite weighted polyhedral data, where each basis element is sent to its evaluation vector over extremal spherical functionals.

### Statement

For separated/nondegenerate finite tropical Hecke data, the map
`i ↦ (ω ↦ φ_ω(e_i))`
embeds the canonical basis into tropical affine space, and the image together with induced tropical addition/convolution determines a finite weighted polyhedral object. Conversely, any such finite polyhedral spherical datum satisfying the tropical associativity compatibility relations reconstructs a unique Hecke datum up to canonical isomorphism.

### Lean-facing theorem shape

```lean
theorem finite_tropical_satake_realization
  {S : Type _} [Semiring S] [OrderBot S]
  (H : FiniteTropicalHeckeData S)
  (h_assoc : TropicalAssociative H.c)
  (h_sep : SeparatedBySphericalFunctionals H)
  (h_nondeg : ResiduatedNondegenerate H) :
  ∃ P : FiniteWeightedPolyhedralData S,
    PolyhedralRealizationOf H P ∧
    ∃ inv : FiniteWeightedPolyhedralData S → FiniteTropicalHeckeData S,
      inv P ≃ₜ H
```

If categorical equivalence is too large for one cycle, prove first:
- faithful realization,
- reconstruction on objects,
- uniqueness up to isomorphism.

That is already a field-opening theorem.

---

## Definitions to Make Precise

You will likely need Lean-friendly finite definitions.

### 1. Tropical associativity on structure constants
Define a predicate expressing:
```lean
def TropicalAssociative (c : ι → ι → ι → S) : Prop := ...
```
using the equality of coefficients in
`(e i ⋆ e j) ⋆ e k = e i ⋆ (e j ⋆ e k)`.

In an idempotent finite setting this should become a finite supremum identity:
```lean
∀ i j k m, (⨆ n, c i j n * c n k m) = (⨆ n, c j k n * c i n m)
```

### 2. Spherical evaluation compatibility
Define a finite spherical datum by an evaluation matrix `E : Ω → ι → S` satisfying:
```lean
∀ ω i j, E ω i * E ω j = ⨆ k, c i j k * E ω k
```
or the min-plus/max-plus variant appropriate to your semiring conventions.

This is the tropical analogue of a simultaneous eigencharacter relation.

### 3. Separation/nondegeneracy
Define a practical finite predicate such as:
```lean
def Separates (E : Ω → ι → S) : Prop :=
  Function.Injective (fun i => fun ω => E ω i)
```
and strengthen with a normalization/extremality condition if needed for uniqueness up to scaling.

### 4. Certified reconstruction
Define an algorithmic reconstruction procedure:
```lean
def reconstructConstants (E : Ω → ι → S) : ι → ι → ι → S := ...
```
Then prove:
```lean
theorem reconstructConstants_correct ... :
  reconstructConstants E = c
```
under the spherical compatibility and separation hypotheses.

This theorem is the algorithmic heart of the project.

---

## Suggested Lean 4 Type Signatures

Use these as targets or refine them if Mathlib constraints demand a better packaging.

```lean
def TropicalAssociative
  {ι S : Type _} [Fintype ι] [DecidableEq ι] [Semiring S] [OrderBot S]
  (c : ι → ι → ι → S) : Prop :=
  ∀ i j k m, (iSup fun n => c i j n * c n k m) = (iSup fun n => c j k n * c i n m)

def SphericalCompatibility
  {ι Ω S : Type _} [Fintype ι] [DecidableEq ι] [Fintype Ω] [Semiring S] [OrderBot S]
  (c : ι → ι → ι → S) (E : Ω → ι → S) : Prop :=
  ∀ ω i j, E ω i * E ω j = iSup (fun k => c i j k * E ω k)

def Separates
  {ι Ω S : Type _} (E : Ω → ι → S) : Prop :=
  Function.Injective (fun i => fun ω => E ω i)

theorem evaluation_matrix_determines_constants
  {ι Ω S : Type _}
  [Fintype ι] [DecidableEq ι] [Fintype Ω] [DecidableEq Ω]
  [Semiring S] [OrderBot S]
  (c c' : ι → ι → ι → S)
  (E : Ω → ι → S)
  (hcomp : SphericalCompatibility c E)
  (hcomp' : SphericalCompatibility c' E)
  (hsep : Separates E)
  (h_nondeg : EvaluationNondegenerate E) :
  c = c' := by
  ...
```

and then the bundled reconstruction theorem:

```lean
theorem finite_tropical_hecke_realization_duality
  {ι Ω S : Type _}
  [Fintype ι] [DecidableEq ι] [Fintype Ω] [DecidableEq Ω]
  [Semiring S] [OrderBot S]
  (c : ι → ι → ι → S)
  (E : Ω → ι → S)
  (h_assoc : TropicalAssociative c)
  (hcomp : SphericalCompatibility c E)
  (hsep : Separates E)
  (h_nondeg : EvaluationNondegenerate E) :
  ∃! c' : ι → ι → ι → S,
    TropicalAssociative c' ∧
    SphericalCompatibility c' E := by
  ...
```

A stronger form can assert explicit equality `c' = c`, but the `∃!` version may be easier and conceptually cleaner.

---

## Proof Architecture: 3 Viable Strategies

### Strategy A: Evaluation-matrix rigidity via finite duality
This is likely the most promising first route.

1. **Encode each basis element by its evaluation profile**
   `v_i : Ω → S`, `v_i(ω) = E ω i`.
   Use `Separates E` to identify basis elements with distinct tropical characters.

2. **Show convolution is determined pointwise by spherical compatibility**
   Since
   `E ω i * E ω j = ⨆ k, c i j k * E ω k`,
   the coefficient family `c i j -` is the unique tropical linear combination representing the pointwise product profile `v_i ⊙ v_j` in the separated family `{v_k}`.

3. **Use finite duality/nondegeneracy to upgrade pointwise determination to coefficient equality**
   This is where you should leverage ideas from
   `finite_duality_theorem`
   in `Bridges/UltrametricProofAutomatonDuality.lean`.
   Even if the statement differs, use it as a certified pattern:
   finite separating observables determine algebraic structure uniquely.

**Why this is promising:** it aligns perfectly with the desired theorem: observables determine structure. It also gives a clean algorithmic extraction.

---

### Strategy B: Canonical basis via extremal tropical convexity
This is conceptually deeper and excellent for the second theorem.

1. **Interpret columns of the evaluation matrix as points in tropical affine space**.
2. **Show basis vectors correspond to extremal generators** of the tropical convex hull of evaluation profiles under nondegeneracy hypotheses.
3. **Prove uniqueness of the canonical basis** from extremality, then recover multiplication by solving tropical linear representation problems.

This connects directly to polyhedral realization and gives the “Satake” flavor: basis ↔ coweight/polyhedral data.

**Why it matters:** this makes the reconstruction geometric rather than merely algebraic, opening the door to tropical buildings/coweight combinatorics.

---

### Strategy C: Residuation/Galois reconstruction
This is the most abstract route and may be powerful if residuation lemmas are easy to formalize.

1. Define a residual coefficient extractor:
   `c i j k` is the largest scalar `a` such that
   `a * E ω k ≤ E ω i * E ω j` for all `ω`.
2. Prove this residual formula reconstructs the unique compatible multiplication table.
3. Verify associativity transfers from the evaluation-side product law.

This gives an explicit reconstruction algorithm and a certified witness of minimality.

**Why it is powerful:** residuation is the native language of idempotent algebra. If formalized cleanly, it will generalize far beyond the first theorem.

---

## Recommended Build Order

1. **Finite matrix-level version first**
   Avoid full semimodule abstractions until the theorem is stable.
2. Define:
   - `TropicalAssociative`
   - `SphericalCompatibility`
   - `Separates`
   - `EvaluationNondegenerate`
3. Prove:
   - uniqueness of coefficients from evaluation data,
   - uniqueness of the compatible convolution law,
   - correctness of a reconstruction function.
4. Then add:
   - canonical basis extraction,
   - minimal generator theorem,
   - polyhedral realization theorem.

Do not get trapped building enormous category-theoretic scaffolding too early.

---

## Specific Building Blocks from the Catalog

Use the existing verified theorems explicitly, not decoratively.

### 1. `finite_duality_theorem`
File: `Bridges/UltrametricProofAutomatonDuality.lean`

Use it as a structural template: finite observable data can determine hidden algebraic structure. Extract the proof pattern:
- finite state/object,
- separating family of observables,
- reconstruction uniqueness.

Even if the ambient objects differ, the theorem should guide the organization of the uniqueness proof for convolution constants from evaluation matrices.

### 2. `tropical_max_idempotent`
File: `Bridges/AlgebraEML/TropicalChoquetClo...`

Use it in simplification chains wherever idempotent addition collapses duplicate contributions. This is especially relevant when proving:
- extremality/minimality of basis generators,
- uniqueness of canonical representatives,
- simplification of tropical linear combinations.

You should build small helper lemmas around idempotent addition so the main proof does not drown in rewrites.

---

## Cross-Domain Connections You Should Explicitly Exploit

### Tropical geometry × representation theory
The evaluation vectors of basis elements should be treated as tropical coweights/weights. This is the finite shadow of Satake-style harmonic analysis.

### Idempotent functional analysis × semiring algebra
Spherical functionals are the idempotent analogue of characters/eigenfunctions. Reconstruction from them is a tropical Gelfand-style philosophy in finite form.

### Automata/duality × Hecke reconstruction
The duality pattern from observable behavior reconstructing hidden transition structure is directly analogous to reconstructing convolution from spherical evaluations.

### Polyhedral combinatorics × canonical bases
Extremal evaluation profiles behave like vertices/rays of a tropical polytope. This is the geometric source of canonical basis uniqueness.

### Certified algorithms × representation-theoretic data
The reconstruction theorem should not merely assert existence. It should produce a verified procedure recoverable from finite samples. This is what makes the theorem computationally transformative.

---

## Concrete Intermediate Lemmas Worth Proving

1. **Pointwise equality from separated evaluations**
```lean
theorem basis_eq_of_eval_eq
  (E : Ω → ι → S)
  (hsep : Separates E)
  {i j : ι}
  (h : ∀ ω, E ω i = E ω j) :
  i = j := ...
```

2. **Coefficient uniqueness under nondegeneracy**
```lean
theorem coefficients_unique_of_eval_representation
  (E : Ω → ι → S)
  (h_nondeg : EvaluationNondegenerate E)
  {a b : ι → S}
  (h : ∀ ω, iSup (fun k => a k * E ω k) = iSup (fun k => b k * E ω k)) :
  a = b := ...
```

3. **Structure constants determined by evaluation matrix**
```lean
theorem constants_determined_by_eval
  (hcomp : SphericalCompatibility c E)
  (hcomp' : SphericalCompatibility c' E)
  (h_nondeg : EvaluationNondegenerate E) :
  c = c' := ...
```

4. **Reconstruction correctness**
```lean
theorem reconstruct_correct
  (hcomp : SphericalCompatibility c E)
  (hsep : Separates E)
  (h_nondeg : EvaluationNondegenerate E) :
  reconstructConstants E = c := ...
```

5. **Canonical basis uniqueness**
```lean
theorem canonical_basis_unique
  ... :
  CanonicalBasis E B₁ → CanonicalBasis E B₂ →
  EquivalentUpToScalingPerm B₁ B₂ := ...
```

---

## Minimality/Certified Witness Layer

Do not stop at abstract reconstruction. Prove a theorem of the following flavor:

```lean
theorem reconstruct_generators_minimal
  (E : Ω → ι → S)
  (hsep : Separates E)
  (h_ext : ExtremalColumns E) :
  MinimalGeneratingFamily (reconstructGenerators E)
```

This matters because “minimal Hecke generators” are the finite analogue of canonical double-coset generators. It upgrades the work from uniqueness to certified synthesis.

---

## Formalization Advice

- If general `iSup` over arbitrary semirings becomes difficult, restrict to finite suprema over `Finset.univ.sup`.
- If `OrderBot`/`canonicallyOrdered` typeclass interactions become painful, define a custom finite tropical structure class for the first version.
- If general semimodules are too heavy, model everything on finite coefficient vectors `ι → S`.
- Prefer proving **matrix-level theorems** first; semimodule equivalence can then be a corollary.
- Keep theorems constructive where possible so the reconstruction algorithm is extracted directly from proofs.

---

## Breakthrough Significance

If you prove this cleanly, you will have formalized a new bridge:
- **finite tropical spherical data** as a complete invariant of a class of idempotent convolution semimodules;
- a first precise **tropical Hecke realization duality**;
- a verified toy model for **tropical Satake reconstruction**;
- a template for future work on buildings, coweights, and tropical automorphic structures.

This is not just another theorem about tropical algebra. It is a blueprint for a new field: **certified tropical representation theory**.

---

## Deliverables

1. `Bridges/TropicalHeckeRealizationDuality.lean`
   with the main definitions, theorem statements, and as many fully proved lemmas as possible.
2. Minimize sorry aggressively; if unavoidable, isolate only the deepest technical gap.
3. Include docstrings explaining the representation-theoretic meaning of the main definitions.
4. Produce `Bridges/TropicalHeckeRealizationDuality/FUTURE_DIRECTIONS.md` with **3–5 specific breakthrough next steps**, for example:
   - tropical Satake transform for finite Weyl-type semirings,
   - tropical Tannakian reconstruction from idempotent fiber functors,
   - Bruhat/polyhedral stratifications in tropical Hecke data,
   - certified reconstruction of tropical spherical varieties,
   - finite tropical Plancherel/Gelfand theory.

Be bold: the theorem should read like the first rigorous finite shadow of tropical Langlands machinery.

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

Research domain: Bridges
Research mode: prove
