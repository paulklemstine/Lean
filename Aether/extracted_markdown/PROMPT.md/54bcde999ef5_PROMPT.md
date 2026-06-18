## Assignment: 2. Categorical Theory of Compression Closures as Idempotent Monads

**Mode**: prove

Build a new categorical foundation for closure/compression duality that is strong enough to interact with Mathlib category theory, order theory, and tropical geometry. Do not merely package existing closure operators as a monad; prove a structural equivalence theorem that turns “compression” into a universal categorical machine. The goal is a field-opening bridge between MDL, idempotent monads, reflective subcategories, and tropical normalization.

Minimize sorry. If some category-theoretic infrastructure is missing, build the smallest reusable layer necessary and keep the main theorems fully formalized.

---

## Vision

The breakthrough is to show that “compression” is not just an optimization heuristic or a closure operator on descriptions, but an **idempotent monadic reflection**. This reframes MDL as a categorical energy functional, closure-fixed points as reflective objects, and tropical normalization as a universal compression principle. If formalized cleanly, this opens a new program: **categorical information compression**, where coding, normalization, tropicalization, and closure all become instances of one theorem schema.

This is not an incremental extension. The key leap is:

- from pointwise inequalities to **monadic universality**,
- from ad hoc fixed-point arguments to **equivalences of categories**,
- from tropical normalization as a trick to **an initial object in a category of translation-invariant compression monads**.

If this works, it enables a future theory of:
- categorical MDL,
- reflective semantics of lossy/lossless compression,
- tropical information geometry,
- idempotent coding semantics,
- compression-aware program transformations.

---

## Existing verified theorems to exploit

You already have certified footholds:

1. `closure_mdl_bound_via_fixed_point`
   - file: `Computation/ClosureKolmogorovDuality.lean`
   - use this as the prototype linking closure fixed points to MDL bounds.
   - The categorical lift should recover this theorem as a special case when the monad is induced by a closure operator on a preorder/category of descriptions.

2. `tropical_compression_bound`
   - file: `Tropical/Core/TropicalDeepResearch.lean`
   - use this to justify that tropical normalization genuinely behaves like compression and carries quantitative bounds.

3. `tropical_and_bound`
   - file: `Tropical/Oracles/OracleApplicationsFrontier.lean`

4. `berggren_tropical_duality_error`
   - file: `Tropical/BerggrenTropicalBridge.lean`

5. `bool_and_as_tropical_max`
   - file: `Tropical/Core/HashInversion.lean`

The tropical theorems suggest that min/max-plus normalization is already acting like an idempotent reduction. Your job is to capture that categorically and prove its universal property.

---

## Primary formalization target

Work in a new file such as:

- `Computation/CompressionMonad.lean`
or, if tropical initiality becomes substantial,
- `Computation/CompressionMonad.lean`
- `Tropical/Core/TropicalCompressionMonad.lean`

Use Mathlib’s category theory stack wherever possible. If the fully general theorem becomes too infrastructure-heavy, first prove a polished version for **thin categories / preorders**, then lift to categories with chosen fixed-object subcategory. But the final statements should still clearly express the general theorem.

---

## Core definitions to introduce

### 1. Compression monad
Define an idempotent monad equipped with an MDL/length monotonicity principle.

A practical Lean-facing version is:

```lean
import Mathlib.CategoryTheory.Monad.Basic
import Mathlib.CategoryTheory.Monad.Kleisli
import Mathlib.CategoryTheory.Reflective
import Mathlib.Order.Basic

open CategoryTheory

universe u v

class HasLength (C : Type u) where
  length : C → ℝ

class CompressionMonad (T : Type u → Type u) extends Monad T where
  idempotent : ∀ α, ∀ x : T (T α), join x = map pure x
```

But this raw `Type u → Type u` version may be too computational and too weak categorically. The more mathematically correct version is category-theoretic:

```lean
open CategoryTheory

universe u v

variable (C : Type u) [Category.{v} C]

structure CompressionMonad where
  toMonad : Monad C
  idempotent' :
    ∀ X : C, IsIso ((toMonad.μ.app X))
```

Then separately define a length functional on objects or elements, depending on the chosen category. If you work in a concrete category, introduce:

```lean
class ObjectLength (C : Type u) [Category.{v} C] where
  lengthObj : C → ℝ
```

If you instead work with a thin category from a preorder on descriptions, the length functional can live directly on objects and monotonicity can be stated cleanly.

### 2. Fixed objects / incompressible data
For an idempotent monad `T`, define the subcategory of `T`-fixed objects:

```lean
structure IsFixedBy (T : Monad C) (X : C) : Prop where
  unit_isIso : IsIso (T.η.app X)
```

This is the standard reflective-subcategory characterization for idempotent monads.

### 3. MDL functional as a natural transformation / comparison functional
If `C` is concrete enough, define MDL by comparison between an object and its compressed image:

```lean
def mdl {C} [Category C] [ObjectLength C] (T : Monad C) (X : C) : ℝ :=
  ObjectLength.lengthObj X - ObjectLength.lengthObj (T.obj X)
```

If elementwise semantics are easier in `Type`, use
```lean
def mdlElem (T : Type u → Type u) [CompressionMonad T] [HasLength α] (x : α) : ℝ := ...
```

But the object-level version is more naturally categorical and easier to make functorial.

### 4. Translation-invariant compression monads on tropical spaces
For `ℝⁿ`, you may model vectors as `Fin n → ℝ`. Define tropical normalization by quotienting out additive constants or selecting a canonical representative such as subtracting the coordinate minimum:

```lean
def tropNormalize {n : ℕ} (x : Fin n → ℝ) : Fin n → ℝ :=
  fun i => x i - ⨅ j, x j
```

or with finite minimum if easier to formalize:

```lean
def tropNormalizeMin {n : ℕ} (x : Fin n → ℝ) : Fin n → ℝ :=
  let m := Finset.univ.inf' Finset.univ_nonempty x
  fun i => x i - m
```

Then prove:
- idempotence,
- translation invariance,
- universal factorization among translation-invariant idempotent compression operators.

This can first be done in a preorder/category of vectors ordered by “same tropical class and no longer than canonical representative”, or simply as an algebraic universal property of endofunctions before categorifying.

---

## Precise theorem targets

## Theorem A: Idempotent compression monads yield reflective fixed-object subcategories

### Mathematical statement
Let `C` be a category and `T : Monad C` an idempotent monad, meaning each multiplication component `μ_X : T(TX) ⟶ TX` is an isomorphism. Then the full subcategory of `T`-fixed objects is reflective, and the reflector is induced by `T`.

### Lean target signature
A realistic first target:

```lean
open CategoryTheory

universe u v
variable {C : Type u} [Category.{v} C]

def FixedBy (T : Monad C) := FullSubcategory (fun X => IsIso (T.η.app X))

theorem compressionMonad_fixed_reflective
    (T : Monad C)
    (hidem : ∀ X : C, IsIso (T.μ.app X)) :
    Reflective (FixedBy T)
```

If `Reflective` is too heavy to instantiate directly, prove the concrete data:
- inclusion functor,
- reflector functor,
- unit,
- triangle/adjunction identities.

### Why this matters
This identifies incompressible objects not as a heuristic subset, but as the **reflective core** of the ambient world. Compression becomes the universal approximation into the incompressible realm.

---

## Theorem B: The Kleisli category of an idempotent compression monad is equivalent to the category of fixed objects

### Mathematical statement
If `T` is an idempotent monad on `C`, then `Kleisli T` is equivalent to the full subcategory of `T`-fixed objects.

This is the categorical heart of the project. It says computations “up to compression” are exactly morphisms into incompressible representatives.

### Lean target signature
```lean
open CategoryTheory

universe u v
variable {C : Type u} [Category.{v} C]

def FixedBy (T : Monad C) := FullSubcategory (fun X => IsIso (T.η.app X))

theorem kleisli_equiv_fixedOfIdempotent
    (T : Monad C)
    (hidem : ∀ X : C, IsIso (T.μ.app X)) :
    Kleisli T ≌ FixedBy T
```

If the full equivalence is difficult, prove a staged version:
1. every object `T.obj X` is fixed;
2. every fixed object is isomorphic to one of the form `T.obj X`;
3. define the comparison functor `Kleisli T ⥤ FixedBy T`;
4. prove fully faithful + essentially surjective.

### Why this is revolutionary
This is the theorem that turns compression into semantics. Kleisli morphisms are “compression-aware programs”; fixed objects are canonical compressed states. Their equivalence means canonical compression is not merely an operation — it is an **entire category of computation**.

---

## Theorem C: Monad morphisms induce MDL inequalities

### Mathematical statement
Suppose `T₁, T₂` are compression monads on a category with length functional, and `φ : T₁ ⟶ T₂` is a monad morphism expressing that `T₂` compresses at least as aggressively/canonically as `T₁`. Then
\[
\mathrm{mdl}_{T₂}(X) \le \mathrm{mdl}_{T₁}(X)
\]
or, depending on sign convention,
\[
\mathrm{length}(T₂ X) \le \mathrm{length}(T₁ X).
\]

You must choose a sign convention and keep it consistent. The cleanest is:
```lean
mdl T X = lengthObj X - lengthObj (T.obj X)
```
Then “more compression” means larger MDL gain, so the inequality should be:
```lean
mdl T₁ X ≤ mdl T₂ X
```
If you insist on the user’s direction `mdl_M₂(x) ≤ mdl_M₁(x)`, then define MDL as residual description length rather than savings:
```lean
mdl T X = lengthObj (T.obj X)
```
This is probably the better formal choice.

### Recommended formal choice
Define MDL as compressed length:
```lean
def mdlObj {C} [Category C] [ObjectLength C] (T : Monad C) (X : C) : ℝ :=
  ObjectLength.lengthObj (T.obj X)
```
Then the requested inequality becomes natural:
```lean
mdlObj T₂ X ≤ mdlObj T₁ X
```

### Lean target signature
```lean
open CategoryTheory

universe u v
variable {C : Type u} [Category.{v} C]
variable [ObjectLength C]

def mdlObj (T : Monad C) (X : C) : ℝ := ObjectLength.lengthObj (T.obj X)

structure CompressionMonadWithLength where
  toMonad : Monad C
  idempotent' : ∀ X : C, IsIso (toMonad.μ.app X)
  length_monotone :
    ∀ {X Y : C}, (X ⟶ Y) → mdlObj toMonad Y ≤ mdlObj toMonad X

theorem monadHom_mdl_inequality
    (T₁ T₂ : Monad C)
    (φ : T₁ ⟶ T₂)
    (hcompress :
      ∀ X : C, ObjectLength.lengthObj (T₂.obj X) ≤ ObjectLength.lengthObj (T₁.obj X)) :
    ∀ X : C, mdlObj T₂ X ≤ mdlObj T₁ X
```

A more conceptual theorem is better:
if monad morphisms in your compression category are required to satisfy objectwise length decrease, then the inequality is immediate and reusable. Define the category so that this theorem is structural, not ad hoc.

### Connection to existing theorem
Use `closure_mdl_bound_via_fixed_point` as the preorder/closure-instance shadow of this theorem. Show that fixed-point closure bounds are exactly MDL monotonicity for the monad induced by the closure operator.

---

## Theorem D: Tropical normalization is an initial translation-invariant compression monad on `ℝⁿ`

### Mathematical statement
Let `V_n = Fin n → ℝ`. Define tropical normalization
\[
N(x)_i = x_i - \min_j x_j.
\]
Then:
1. `N` is idempotent;
2. `N(x + c·1) = N(x)` for every scalar `c`;
3. for any translation-invariant idempotent compression operator `T : V_n → V_n` satisfying the canonical zero-min condition
   \[
   \min_i T(x)_i = 0,
   \]
   one has `T = N`;
4. hence the associated tropical compression monad is initial in the category of translation-invariant compression monads with normalization target.

This theorem is strongest if you formulate the category so objects are idempotent endofunctors/operators on `V_n` satisfying translation invariance and a normalization axiom, with morphisms the unique comparison maps. Then initiality is equivalent to uniqueness.

### Lean target signature
A tractable version:

```lean
def TropVec (n : ℕ) := Fin n → ℝ

def tropNormalize {n : ℕ} (x : TropVec n) : TropVec n := ...

theorem tropNormalize_idempotent {n : ℕ} :
    Function.Idempotent (@tropNormalize n)

theorem tropNormalize_translation_invariant {n : ℕ} (x : TropVec n) (c : ℝ) :
    tropNormalize (fun i => x i + c) = tropNormalize x

structure TranslationInvariantCompression (n : ℕ) where
  toFun : TropVec n → TropVec n
  idempotent' : Function.Idempotent toFun
  translation_invariant' :
    ∀ (x : TropVec n) (c : ℝ), toFun (fun i => x i + c) = toFun x
  min_zero' :
    ∀ x, ∃ i, toFun x i = 0
  nonneg' :
    ∀ x i, 0 ≤ toFun x i

theorem tropNormalize_initial
    {n : ℕ} (hn : 0 < n) :
    ∀ T : TranslationInvariantCompression n, T.toFun = tropNormalize
```

This is an excellent first universal theorem. Once proved, package it categorically:

```lean
theorem tropical_normalization_initial_obj
    {n : ℕ} (hn : 0 < n) :
    IsInitial (⟨tropNormalizeStructure n, ...⟩ : TranslationInvariantCompression n)
```

if you build the category.

### Why this is a breakthrough
This says tropical normalization is not one normalization among many: it is the **forced canonical compression** under symmetry and idempotence. That is a universal property, the correct language of deep mathematics.

### Build on catalog tropical results
Use:
- `tropical_compression_bound` to motivate and perhaps derive quantitative compression control,
- `bool_and_as_tropical_max` and `tropical_and_bound` to connect tropical normalization with logical aggregation and semiring semantics,
- `berggren_tropical_duality_error` as evidence that tropicalization preserves arithmetic structure up to controlled error, reinforcing the interpretation of tropical normalization as a compression reflector.

---

## Suggested proof strategies

## Strategy A: Reflective-subcategory route via standard idempotent monad theory
**Most promising for Theorems A and B.**

1. Prove that if `μ_X` is an isomorphism, then `η_(T X)` is an isomorphism using monad identities.
2. Show every `T.obj X` is fixed, hence `T` lands in the full subcategory of fixed objects.
3. Construct the reflector `L : C ⥤ FixedBy T` by `X ↦ T.obj X`.
4. Show the inclusion `i : FixedBy T ⥤ C` admits `L ⊣ i`.
5. Define the comparison functor `Kleisli T ⥤ FixedBy T` and prove it is an equivalence by explicit inverse-on-objects and hom-set bijection.

Why this is best:
- Mathlib already knows about monads, Kleisli categories, adjunctions, reflective subcategories.
- Idempotent monads classically correspond to reflective subcategories, so you are formalizing a deep theorem with strong reuse value.

## Strategy B: Thin-category / preorder bootstrap
**Most promising for a first fully complete formalization if general category theory becomes sticky.**

1. Model descriptions as a preorder with `x ≤ y` meaning “x is no more complex than y”.
2. A closure/compression operator is a monotone idempotent extensive/reductive map, depending on convention.
3. Show fixed points form a reflective sub-preorder.
4. Interpret the induced monad on the thin category and recover the general shape of Theorems A–C.
5. Then lift selected lemmas to general categories.

Why this helps:
- It connects directly to `closure_mdl_bound_via_fixed_point`.
- It minimizes infrastructure risk and gives you a clean path to a polished theorem even if some categorical APIs are awkward.

## Strategy C: Universal algebra route for tropical initiality
**Best for Theorem D.**

1. Define `tropNormalize` explicitly using finite minima on `Fin n → ℝ`.
2. Prove idempotence and translation invariance by direct algebra.
3. Show any idempotent translation-invariant normalization with min-zero and nonnegativity must equal `tropNormalize` pointwise:
   - by translation invariance reduce to the case `min x = 0`,
   - then use min-zero/nonnegativity to force the canonical representative.
4. Package uniqueness as initiality in a category of normalization operators.

Why this is best:
- The theorem is really a rigidity statement.
- Direct pointwise proof is likely simpler than constructing a sophisticated category first.
- Once uniqueness is formalized, categorification is almost free.

---

## Recommended theorem order

1. **Define fixed objects and prove basic lemmas for idempotent monads.**
2. **Prove every idempotent monad induces a reflector onto fixed objects.**
3. **Prove `Kleisli T ≌ FixedBy T`.**
4. **Define MDL object functional and prove monotonicity under compression morphisms.**
5. **Formalize tropical normalization and prove its uniqueness/initiality.**
6. **Bridge back to closure theory by deriving a categorical corollary of `closure_mdl_bound_via_fixed_point`.**

This order gives you one deep categorical theorem early, then quantitative consequences, then the tropical universal property.

---

## Lean design guidance

### For idempotent monads
Prefer the standard categorical formulation:
```lean
∀ X, IsIso (T.μ.app X)
```
rather than an elementwise `join = map pure`, unless you are working in `Type`. The categorical form is cleaner and aligns with reflective subcategories.

### For fixed objects
Use the unit map:
```lean
IsIso (T.η.app X)
```
as the fixedness predicate. For idempotent monads, this is equivalent to the usual algebraic fixed-point condition.

### For tropical normalization
On `Fin n → ℝ`, finite minima can be annoying. Use the existing `Finset` API:
```lean
let m := Finset.inf' Finset.univ ?hne x
```
You will need `n > 0` for nonempty `Finset.univ`.

### For MDL
Choose one convention and state it clearly:
- compressed length, or
- compression gain.

Given the target inequality, compressed length is cleaner.

---

## Cross-domain connections to emphasize in the development

1. **Category theory × information theory**
   - MDL becomes a natural or lax-natural complexity observable on a reflective localization.
   - Compression is a categorical coarse-graining.

2. **Category theory × tropical geometry**
   - Tropical normalization is a reflector onto canonical representatives of projective tropical classes.
   - This is a tropical analogue of gauge fixing.

3. **Programming semantics × compression**
   - Kleisli morphisms for compression monads model computations modulo canonical reduction.
   - This suggests compiler normalization, abstract interpretation, and semantics-preserving compression.

4. **Order theory × Kolmogorov/closure duality**
   - `closure_mdl_bound_via_fixed_point` should emerge as the thin-category shadow of the monadic theorem.
   - This is the right conceptual unification.

5. **Physics analogy**
   - Idempotent monads act like renormalization/coarse-graining operators.
   - Fixed objects are renormalized phases; MDL is an effective action / free energy proxy.
   - Tropical normalization resembles gauge fixing under additive symmetries.

These are not rhetorical flourishes: they point to future theorem families.

---

## Application keywords

categorical information theory, MDL, idempotent monad, reflective subcategory, Kleisli equivalence, tropical normalization, tropical projective space, canonical representatives, compression semantics, closure operators, Kolmogorov duality, coarse-graining, renormalization, gauge fixing, semiring semantics, abstract interpretation, program compression, universal property, translation invariance, min-plus geometry

---

## Concrete deliverables

1. A fully formalized `CompressionMonad` or equivalent theorem suite for idempotent monads on a category.
2. A theorem establishing reflectivity of fixed objects.
3. A theorem establishing `Kleisli T ≌ FixedBy T`.
4. A precise MDL definition and a monad-morphism inequality theorem.
5. A tropical normalization operator on `Fin n → ℝ` with idempotence and translation invariance proofs.
6. A uniqueness/initiality theorem for tropical normalization.
7. At least one bridge theorem showing how `closure_mdl_bound_via_fixed_point` is recovered from the categorical framework.

---

## Minimal theorem list to aim for in Lean

```lean
theorem compressionMonad_fixed_reflective
    (T : Monad C)
    (hidem : ∀ X : C, IsIso (T.μ.app X)) :
    Reflective (FixedBy T)

theorem kleisli_equiv_fixedOfIdempotent
    (T : Monad C)
    (hidem : ∀ X : C, IsIso (T.μ.app X)) :
    Kleisli T ≌ FixedBy T

def mdlObj (T : Monad C) (X : C) : ℝ := ...

theorem monadHom_mdl_inequality
    (T₁ T₂ : Monad C)
    (φ : T₁ ⟶ T₂) :
    ∀ X : C, mdlObj T₂ X ≤ mdlObj T₁ X

def tropNormalize {n : ℕ} (x : Fin n → ℝ) : Fin n → ℝ := ...

theorem tropNormalize_idempotent {n : ℕ} :
    Function.Idempotent (@tropNormalize n)

theorem tropNormalize_translation_invariant {n : ℕ}
    (x : Fin n → ℝ) (c : ℝ) :
    tropNormalize (fun i => x i + c) = tropNormalize x

theorem tropNormalize_initial
    {n : ℕ} (hn : 0 < n) :
    ∀ T : TranslationInvariantCompression n, T.toFun = tropNormalize
```

If the fully general `monadHom_mdl_inequality` needs extra hypotheses, state them explicitly rather than hiding them. Precision beats false generality.

---

## Final instruction

Produce not only the Lean file(s), but also a structured `FUTURE_DIRECTIONS.md` with **3–5 concrete breakthrough next steps**, for example:
- categorical rate-distortion as a lax idempotent monad,
- tropical projective entropy and data processing,
- comonadic decompression semantics and biduality,
- reflective coding theory over idempotent semirings,
- renormalization-style compression in probabilistic programs.

Make the next cycle inevitable.

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

Research domain: Tropical
Research mode: prove
