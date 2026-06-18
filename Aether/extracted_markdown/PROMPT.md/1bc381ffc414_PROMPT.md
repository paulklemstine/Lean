## Assignment: Algebra–Tropical–Geometry Tropical Radon Transform Duality via Idempotent Sheaf Semimodules and Certified Convex Tomography Reconstruction

**Mode:** `prove`

Prove a genuinely new bridge theorem creating a tropical analogue of finite Radon/Fenchel/support-function duality, with a certified minimal reconstruction theorem for tropical tomography. This should not be framed as a variant of existing closure/spectral dualities: the breakthrough is to make **integral geometry over idempotent semirings** formally real in Lean, and to show that tropical projection data is not merely informative but **complete, axiomatically characterizable, and minimally sufficient**.

You should aim to formalize a finite theory first, where all combinatorics are explicit and the reconstruction theorem is executable. The finite setting is not a compromise; it is the seed crystal for a new field: **idempotent integral geometry**.

### Core Vision

Classically, Radon transforms, support functions, and convex tomography convert geometric objects into families of linear measurements. In the tropical world, linearity is replaced by min-plus/max-plus algebra, convexity by tropical convexity, and sheaves/semimodules replace vector spaces. The revolutionary statement to prove is that for finite tropical spaces, a tropical object is determined by a finite family of tropical hyperplane projections, and the entire image of the transform admits an intrinsic axiomatization.

This would open:
- tropical tomography,
- idempotent inverse problems,
- tropical signal reconstruction,
- semiring-valued sheaf measurement theory,
- certified geometric inference algorithms.

It also creates a bridge between:
- tropical convexity,
- Radon/integral geometry,
- residuation theory,
- finite Helly/Carathéodory phenomena,
- sheaf-theoretic data fusion,
- certified reconstruction in formal mathematics.

---

## Precise Theorem Targets

Work in a finite setting first.

Let:
- `X` be a finite type,
- `α` be the tropical scalar type (use `ℤ`, `ℚ`, or a linearly ordered canonically ordered commutative additive monoid as needed for tractability),
- `H : Finset (X → α)` be a finite family of admissible tropical affine functionals,
- `f : X → α` a finitely supported tropical signal/measure; on a finite type this is just a function.

Define the tropical Radon transform in min-plus convention by
\[
\mathrm{Rad}_H(f)(h) := \inf_{x \in X} (f(x) + h(x)).
\]
In finite Lean form this will be a `Finset.inf'` or, more conveniently for available algebra, use the max-plus dual convention
\[
\mathrm{Rad}^\vee_H(f)(h) := \sup_{x \in X} (f(x) + h(x)),
\]
which is often easier to formalize via `Finset.sup'`. If the library support is asymmetric, choose the convention that minimizes proof friction, but state the dual theorem clearly.

### Theorem A: Separation/Injectivity via Tropical Point Separation

Assume `H` tropically separates points of `X` in the following strong finite sense:
\[
\forall x \neq y,\ \exists h \in H,\ \forall z,\ h(x) - h(z) \neq h(y) - h(z)
\]
or a more Lean-friendly sufficient hypothesis such as:
\[
\forall x \neq y,\ \exists h \in H,\ h(x) \neq h(y),
\]
together with a function class on which these evaluations suffice to distinguish lower envelopes / support loci.

Then prove injectivity of the tropical Radon transform on a suitable tropically convex class `C`:
\[
\forall f,g \in C,\ (\forall h \in H,\ \mathrm{Rad}_H(f)(h)=\mathrm{Rad}_H(g)(h)) \to f=g.
\]

A Lean-target version could be:

```lean
theorem tropicalRadon_injective_of_separates
  {X α : Type*} [Fintype X] [DecidableEq X]
  [LinearOrder α] [OrderBot α] [CanonicallyOrderedAddMonoid α]
  (H : Finset (X → α))
  (separates : ∀ ⦃x y : X⦄, x ≠ y → ∃ h ∈ H, h x ≠ h y) :
  Function.Injective
    (fun f : X → α =>
      fun h : {h // h ∈ H} =>
        sInf ((Set.range fun x : X => f x + h.1 x) : Set α)) := by
  sorry
```

This exact type signature may need adjustment because `sInf` over finite images often requires condition management; if `sup` is easier, use:

```lean
theorem tropicalRadonSup_injective_of_separates
  {X α : Type*} [Fintype X] [DecidableEq X]
  [LinearOrder α] [OrderBot α] [OrderedAddCommMonoid α]
  (H : Finset (X → α))
  (separates : ∀ ⦃x y : X⦄, x ≠ y → ∃ h ∈ H, h x ≠ h y) :
  Function.Injective
    (fun f : X → α =>
      fun h : {h // h ∈ H} =>
        Finset.sup' Finset.univ Finset.univ_nonempty (fun x : X => f x + h.1 x)) := by
  sorry
```

If full injectivity on all functions is too strong under weak separation, define the canonical class of **tropically convex normal forms**:
\[
f(x)=\sup_{h\in H}(c_h-h(x))
\]
and prove injectivity there. That is already a major theorem: tropical support-function data determines the represented object.

---

### Theorem B: Image Characterization as Tropical Support Data

Define a compatibility predicate `IsTropicalSupportData H F` on functions `F : H → α`, expressing the finite support-function/valuation inequalities forced by representation as a tropical lower envelope or upper hull.

Target theorem:
\[
F \in \operatorname{Im}(\mathrm{Rad}_H)
\iff
F \text{ satisfies finite tropical support axioms.}
\]

In concrete finite form, if one defines the reconstruction operator
\[
\mathcal{R}(F)(x)=\sup_{h\in H}(F(h)-h(x))
\]
(max-plus convention), then prove:
1. `Radon (reconstruct F) = F` iff `F` satisfies the support axioms,
2. `reconstruct (Radon f)` is the canonical tropical convex regularization of `f`,
3. equality holds for `f` already in normal form.

Suggested Lean target:

```lean
def tropicalReconstruct
  {X α : Type*} [Fintype X] [DecidableEq X]
  [LinearOrder α] [OrderBot α] [OrderedAddCommMonoid α]
  (H : Finset (X → α)) (F : {h // h ∈ H} → α) : X → α :=
  fun x =>
    Finset.sup' H H.nonempty (fun h => F ⟨h, by simpa using Finset.mem_coe.2 ?_⟩ - h x)
```

Then prove a Galois/residuation-style theorem:

```lean
theorem tropicalRadon_reconstruct_gc
  {X α : Type*} [Fintype X] [DecidableEq X]
  [LinearOrder α] [OrderBot α] [OrderedAddCommGroup α]
  (H : Finset (X → α)) :
  ∀ f F,
    (∀ h : {h // h ∈ H},
      Finset.sup' Finset.univ Finset.univ_nonempty (fun x : X => f x + h.1 x) ≤ F h)
    ↔
    (∀ x : X, f x ≤ tropicalReconstruct H F x) := by
  sorry
```

This is the finite idempotent analogue of Legendre–Fenchel/Galois duality and is likely the conceptual heart of the project.

Then define `IsTropicalSupportData` from the fixed-point condition:
```lean
def IsTropicalSupportData (...) (F : {h // h ∈ H} → α) : Prop :=
  tropicalRadonSup H (tropicalReconstruct H F) = F
```
and prove exact image characterization:
```lean
theorem mem_range_tropicalRadonSup_iff_supportData
  ... :
  (∃ f, tropicalRadonSup H f = F) ↔ IsTropicalSupportData H F := by
  sorry
```

This is a breakthrough theorem, not just a technicality: it says tropical projection data has an intrinsic geometry independent of the original object.

---

### Theorem C: Canonical Minimal Measurement Basis

Prove that under finite redundancy elimination, there exists a canonical subfamily `B ⊆ H` such that:
1. `Radon_H(f)` is determined by `Radon_B(f)`,
2. no proper subfamily of `B` has this property,
3. `B` can be extracted by a tropical extremality / irredundancy criterion.

Precise theorem form:
\[
\exists B \subseteq H,\ \forall f,g \in C,\ 
\bigl(\forall h\in B,\ \mathrm{Rad}_B(f)(h)=\mathrm{Rad}_B(g)(h)\bigr)\to f=g,
\]
and `B` is inclusion-minimal.

Lean target sketch:

```lean
theorem exists_minimal_separating_subfamily
  {X α : Type*} [Fintype X] [DecidableEq X]
  [LinearOrder α] [OrderBot α] [OrderedAddCommMonoid α]
  (H : Finset (X → α))
  (hsep : -- suitable separating hypothesis on H
  ) :
  ∃ B : Finset (X → α),
    B ⊆ H ∧
    Function.Injective (tropicalRadonSup B) ∧
    ∀ B' : Finset (X → α), B' ⊆ B →
      Function.Injective (tropicalRadonSup B') → B ⊆ B' := by
  sorry
```

If strict minimality is technically awkward, prove existence of a **canonical irredundant basis** defined by extremal generators in the image semimodule, and then prove determination of all measurements from it. This would still be highly significant.

This theorem is where tomography becomes certified and economical rather than merely possible.

---

### Theorem D: Certified Reconstruction

Define a computable reconstruction operator `reconstruct`. Prove:
\[
\mathrm{Rad}_H(\mathrm{reconstruct}(F)) = F
\]
for admissible data, and
\[
\mathrm{reconstruct}(\mathrm{Rad}_H(f)) = f
\]
for `f` in the representable tropically convex class.

Then prove a finite certification theorem: if `B` is the canonical basis and `F_B` is the measured data on `B`, the reconstruction from `F_B` equals the original object.

Lean target sketch:

```lean
theorem certified_tropical_tomography_reconstruction
  {X α : Type*} [Fintype X] [DecidableEq X]
  [LinearOrder α] [OrderBot α] [OrderedAddCommGroup α]
  (H B : Finset (X → α))
  (hB : B ⊆ H)
  (hmin : Function.Injective (tropicalRadonSup B))
  (f : X → α)
  (hnormal : IsTropicalNormalForm B f) :
  reconstructFromSubfamily B (tropicalRadonSup B f) = f := by
  sorry
```

This theorem should be explicitly framed as a **certified convex tomography pipeline**.

---

## How to Build on Existing Verified Theorems

Use the catalog results as structural precedents, not merely citations.

1. **`certified_finite_tropical_decomposition`**
   - This is the closest algebraic ancestor.
   - Use it to justify or formalize that relevant functions admit finite tropical decompositions into extremal generators/support terms.
   - If it gives a decomposition into tropical atoms, reinterpret those atoms as tropical hyperplane functionals or as generators of the representable image semimodule.
   - This is likely the key input for proving normal-form reconstruction and finite image characterization.

2. **`certified_reconstruction_from_closure_capacity`**
   - Abstract the pattern: a global object reconstructed from a family of lower-dimensional observables satisfying compatibility.
   - The analogy is strong: closure capacities there, projection capacities here.
   - Borrow the proof architecture: define observables, prove soundness, prove completeness via canonical reconstruction.

3. **`certified_minimal_tanner_reconstruction`**
   - Use this as the template for the minimal measurement theorem.
   - Translate “minimal Tanner observations reconstruct the codeword” into “minimal tropical directions reconstruct the signal.”
   - Especially valuable for proving existence/uniqueness of a minimal sufficient observable family.

4. **`certified_gibbs_reconstruction_from_boundary_partition`**
   - This is the statistical-mechanical analogue of recovering a global state from boundary data.
   - Use it conceptually to frame tropical Radon data as a boundary measurement/sheaf gluing problem.
   - This is your bridge to idempotent sheaf semantics: local projection data glues to a unique global section.

---

## Proof Strategy Paths

### Strategy A: Galois/Residuation Duality Route
**Most promising.**

1. Define the transform `Radon` and reconstruction `Reconstruct` as an adjoint pair:
   \[
   \mathrm{Radon}(f)\le F \iff f \le \mathrm{Reconstruct}(F).
   \]
2. Use this Galois correspondence to prove:
   - monotonicity,
   - closure/idempotence,
   - fixed-point characterization of admissible projection data,
   - exactness on normal-form functions.
3. Deduce injectivity on the fixed-point/tropically convex class and image characterization from general adjunction machinery.

**Why most promising:** this turns the entire theory into order algebra. Lean likes monotone maps, closures, and pointwise inequalities. It also naturally yields the image characterization and reconstruction theorem in one framework.

---

### Strategy B: Finite Tropical Convexity / Support Function Route

1. Define the representable class as tropical convex hulls of shifted admissible hyperplanes:
   \[
   f(x)=\sup_{h\in H}(c_h-h(x)).
   \]
2. Show that Radon data recovers the coefficients `c_h` up to the support axioms.
3. Prove that extremal/nonredundant hyperplanes form a minimal basis of measurements.
4. Use finite Helly/Carathéodory-style elimination to certify reconstruction from this basis.

**Why valuable:** this gives the geometric interpretation and directly ties to tropical polyhedra and tomography. It may be more intuitive for the minimal-basis theorem than the pure adjunction route.

---

### Strategy C: Sheaf-Semimodule Gluing Route

1. Regard measurement data on subfamilies/subcomplexes as local sections of a presheaf of idempotent semimodules.
2. Prove compatibility on overlaps corresponds exactly to tropical support-data axioms.
3. Show the reconstruction theorem is a sheaf gluing theorem on a finite measurement cover.
4. Derive global uniqueness from separation and local convexity.

**Why this matters:** it is the most conceptually revolutionary route and opens the door to non-finite and stratified tropical spaces. It may be heavier for the first Lean implementation, so use it as the interpretation layer unless the existing sheaf infrastructure is already strong.

---

## Recommended Execution Order

1. Formalize finite `tropicalRadonSup` and `tropicalReconstruct`.
2. Prove the adjunction/residuation theorem.
3. Define `IsTropicalNormalForm` and prove reconstruction exactness on that class.
4. Derive image characterization as a fixed-point theorem.
5. Prove injectivity under separation on the normal-form class.
6. Prove existence of an irredundant/minimal determining subfamily.
7. Package everything into a certified tomography theorem.

---

## Cross-Domain Connections You Should Make Explicit in the file/module docstring

This project is powerful because it is simultaneously:

- **Integral geometry:** tropical analogue of Radon/support transforms.
- **Convex geometry:** support-function duality for tropical convex bodies.
- **Order theory:** Galois connections and residuation.
- **Sheaf theory:** local measurement consistency and gluing of semimodule-valued data.
- **Inverse problems:** certified reconstruction from partial observations.
- **Algorithms:** finite elimination and basis extraction.
- **Mathematical physics:** idempotent dequantization of tomography, analogous to semiclassical limits where linear superposition becomes max-plus optimization.
- **Information theory:** minimal sufficient measurement families resemble compressed sensing, but over semirings rather than fields.
- **Computer vision / imaging:** convex tomography over tropical semirings suggests new discrete reconstruction paradigms.
- **Optimization:** transform/reconstruct duality is a semiring version of Fenchel duality and morphological transforms.

Push at least one of these unexpected bridges hard:
- tropical tomography as **idempotent compressed sensing**,
- tropical support data as **semiring-valued sufficient statistics**,
- reconstruction as **sheaf-theoretic gluing of inverse problem data**,
- Radon duality as a **dequantized Legendre transform**.

---

## Suggested Lean 4 Definitions

A practical route is to use the `sup` convention first.

```lean
def tropicalRadonSup
  {X α : Type*} [Fintype X] [DecidableEq X]
  [LinearOrder α] [OrderBot α] [OrderedAddCommMonoid α]
  (H : Finset (X → α)) (f : X → α) :
  {h // h ∈ H} → α :=
  fun h =>
    Finset.sup' Finset.univ Finset.univ_nonempty (fun x : X => f x + h.1 x)
```

```lean
def tropicalReconstructSup
  {X α : Type*} [Fintype X] [DecidableEq X]
  [LinearOrder α] [OrderBot α] [OrderedAddCommGroup α]
  (H : Finset (X → α)) (F : {h // h ∈ H} → α) :
  X → α :=
  fun x =>
    Finset.inf' H H.nonempty (fun h => F ⟨h, by assumption⟩ - h x)
```

or the dualized all-`sup` version if subtraction is awkward:
```lean
def tropicalNormalForm
  ...
  (c : {h // h ∈ H} → α) : X → α :=
  fun x => Finset.sup' H H.nonempty (fun h => c ⟨h, by assumption⟩ + dualize (h x))
```

You may need to specialize `α = ℤ` or `α = ℚ` if generic ordered additive groups become cumbersome. That is acceptable if it gets the theory over the line.

---

## What Would Make This a Breakthrough

Do not stop at “the transform is injective.” The true breakthrough package is:

1. **Transform defined** on finite tropical spaces.
2. **Injective on a geometrically meaningful class.**
3. **Exact intrinsic characterization of the image.**
4. **Canonical minimal determining family.**
5. **Certified executable reconstruction.**

That combination creates a new formal field, not a theorem fragment.

The key mathematical slogan should become:

> In finite tropical geometry, admissible projection data is exactly tropical support data, and a finite canonical basis of tropical directions suffices for certified reconstruction.

If you can formalize that slogan cleanly, this module becomes a foundational citation target for future work on tropical inverse problems.

---

## Application Keywords

tropical Radon transform, idempotent integral geometry, tropical convexity, support-function duality, residuation, Galois connection, finite tomography, certified reconstruction, tropical compressed sensing, semiring sheaves, idempotent inverse problems, dequantized Legendre duality, finite Helly theorem, tropical polyhedra, semimodule-valued measurement theory

---

## Deliverables

Create:

`Bridges/AlgebraTropicalGeometry/TropicalRadonDuality.lean`

with:
- precise definitions,
- at least one major fully proved theorem from Theorem A/B/D,
- as few `sorry` as possible,
- theorem statements for the rest even if some auxiliary lemmas remain.

Also produce:

`FUTURE_DIRECTIONS.md`

with **3–5 concrete breakthrough next steps**, for example:
1. extend from finite sets to finite polyhedral complexes/sheaf covers;
2. prove a tropical Helly-Carathéodory theorem tailored to measurement minimality;
3. define stability/noise bounds for approximate tropical Radon data;
4. connect tropical tomography to morphological image operators;
5. develop a semiring-valued sheaf cohomology obstruction theory for inconsistent projection data.

Be specific. The future directions should be the next research program, not generic aspirations.

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
