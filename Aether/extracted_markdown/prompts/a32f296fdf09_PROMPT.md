## Assignment: Categorical Foundations Beyond the Textbook — Yoneda as a Reconstruction Principle, Adjunctions as Algorithmic Engines

Work in **mode: prove + formalize + discover**.

This project must not merely restate standard category theory. The breakthrough target is to turn Yoneda and adjunctions into a **reconstruction-and-computation framework** inside Lean 4: objects recovered from observable functors, adjunctions extracted from universal data, and free constructions realized as verified algorithms. The goal is to make category theory function not as abstract decoration, but as a **machine for certifying equivalence, synthesis, and universality**.

You should formalize classical cores only insofar as they are needed to prove **new, nontrivial theorems with computational consequences**.

---

## Central Vision

The ordinary Yoneda lemma says that an object is determined by how maps into or out of it behave. That is already profound. But the field-opening step is this:

> **Treat representable functors as complete observational signatures of mathematical systems, and adjunctions as compilers turning syntax into semantics.**

This viewpoint connects:
- **logic/model theory**: definability via hom-observables,
- **program semantics/type theory**: free-forgetful adjunctions as certified compilation,
- **algebraic combinatorics**: reconstruction from action on test objects,
- **physics/information**: observables determine states; universal constructions encode constrained optimization.

If formalized correctly, this opens a pathway to:
- machine-verifiable reconstruction theorems,
- automated detection of representability,
- certified synthesis of free objects,
- a library of “universal algorithms” derived from adjunctions.

Application keywords: **category theory, Yoneda lemma, adjunctions, representability, reconstruction, universal algebra, certified synthesis, semantics, type theory, algebraic logic, program verification, symbolic computation**.

---

## Core Theorem Targets

You must prove at least **3 substantial theorems** beyond boilerplate library wrapping. At least one should introduce a **new definition** and at least one should make a **cross-domain connection**.

Below are the primary targets. Refine names as needed to match Mathlib namespace conventions, but preserve the mathematical content.

---

### Theorem 1: Representables determine objects up to unique isomorphism

For any locally small category `C`, if the covariant hom-functors represented by `X` and `Y` are naturally isomorphic, then `X ≅ Y`.

This is standard mathematically, but in Lean it becomes powerful when exposed as a reusable reconstruction theorem.

#### Precise statement
For a category `C`,
\[
(\mathrm{yoneda.obj}\, X \cong \mathrm{yoneda.obj}\, Y) \to (X \cong Y).
\]

#### Lean 4 target signature
```lean
theorem iso_of_yoneda_obj_iso
  {C : Type u} [Category.{v} C]
  {X Y : C}
  (h : yoneda.obj X ≅ yoneda.obj Y) :
  X ≅ Y
```

Also prove the contravariant/co-Yoneda analogue if available in Mathlib:
```lean
theorem iso_of_coyoneda_obj_iso
  {C : Type u} [Category.{v} C]
  {X Y : C}
  (h : coyoneda.obj (Opposite.op X) ≅ coyoneda.obj (Opposite.op Y)) :
  X ≅ Y
```
or the correct dualized variant matching existing definitions.

#### Why this is a breakthrough
This theorem upgrades Yoneda from a lemma into a **reconstruction principle**. It says that if two systems present identical observables against every test object, they are the same up to canonical equivalence. In formal mathematics and verified science, this is the theorem that justifies identifying hidden structure from interface behavior.

---

### Theorem 2: Faithfulness of the Yoneda embedding as an extensionality engine

Prove that equality of morphisms can be recovered from equality of all induced natural transformations under Yoneda.

#### Precise statement
For morphisms `f g : X ⟶ Y`, if the induced natural transformations under `yoneda.map` are equal, then `f = g`.

#### Lean 4 target signature
```lean
theorem yoneda_map_injective
  {C : Type u} [Category.{v} C]
  {X Y : C} :
  Function.Injective (fun (f : X ⟶ Y) => yoneda.map f)
```

A stronger extensionality form is even better:
```lean
theorem hom_ext_of_yoneda
  {C : Type u} [Category.{v} C]
  {X Y : C} {f g : X ⟶ Y}
  (h : yoneda.map f = yoneda.map g) :
  f = g
```

#### Why this matters
This theorem is the formal “observational indistinguishability implies equality” principle. It is the category-theoretic analogue of:
- extensional equality in programming languages,
- indistinguishable states in physics,
- equivalence of black-box systems in semantics.

This should become a reusable tactic pattern: prove equality of maps by comparing all probes.

---

### Theorem 3: A new structure — finite probe representability

Introduce a genuinely new notion not already in the catalog:

A functor is **finitely probe-reconstructible** if there exists a finite family of probe objects whose induced action determines all natural transformations into the functor. This is not the full Yoneda principle; it is a controlled, computational approximation to representability.

#### New definition target
You should define something of the following shape, adapted to what is practical in Lean:

```lean
structure FiniteProbeFamily (C : Type u) [Category.{v} C] where
  ι : Type w
  [fintype_ι : Fintype ι]
  probe : ι → C
```

and then define a notion such as:
```lean
def Functor.IsDetectedBy
  {C : Type u} [Category.{v} C]
  {D : Type u'} [Category.{v'} D]
  (P : FiniteProbeFamily C)
  (F G : C ⥤ D) : Prop := ...
```

or a more directly usable notion:
```lean
def Presheaf.FinitelyProbeReconstructible
  {C : Type u} [Category.{v} C]
  (F : Cᵒᵖ ⥤ Type w) : Prop := ...
```

You may formulate this in terms of injectivity of restriction-to-probes on natural transformations, or uniqueness of representing data from finitely many test objects.

#### Deep theorem target
Show that in a category with a separator / generating family, probe detection implies global equality on a class of morphisms or natural transformations.

A possible theorem:
```lean
theorem natTrans_ext_of_finite_probes
  {C : Type u} [Category.{v} C]
  {D : Type u'} [Category.{v'} D]
  (P : FiniteProbeFamily C)
  {F G : C ⥤ D}
  (hsep : ... ) :
  Function.Injective (fun (α : F ⟶ G) => fun i => α.app (P.probe i))
```

If finite probes are too ambitious globally, prove it for a concrete category such as `Type`, `Module R`, or a small finite category.

#### Why this is revolutionary
This is where the project stops being a textbook formalization and starts becoming research. Yoneda uses **all probes**. Science and computation use **finite observations**. A finite-probe theorem would be a category-theoretic foundation for:
- system identification,
- property testing,
- compressed semantics,
- certified black-box verification.

This is the cross-over point between pure category theory and computational learning/verification.

---

### Theorem 4: Adjunction induces monad structure with explicit computational content

Do not just instantiate existing library machinery. Prove at least one theorem showing how unit/counit identities generate an algorithmically meaningful normal form.

#### Lean 4 target signature
At minimum:
```lean
theorem left_triangle_components
  {C : Type u} {D : Type u'}
  [Category.{v} C] [Category.{v'} D]
  (F : C ⥤ D) (G : D ⥤ C) (h : F ⊣ G) :
  ∀ X : C, F.map ((Adjunction.unit h).app X) ≫ (Adjunction.counit h).app (F.obj X) = 𝟙 (F.obj X)
```

and dually:
```lean
theorem right_triangle_components
  {C : Type u} {D : Type u'}
  [Category.{v} C] [Category.{v'} D]
  (F : C ⥤ D) (G : D ⥤ C) (h : F ⊣ G) :
  ∀ Y : D, (Adjunction.unit h).app (G.obj Y) ≫ G.map ((Adjunction.counit h).app Y) = 𝟙 (G.obj Y)
```

Then push further: prove that the induced monad multiplication is associative by explicit componentwise reasoning, or prove a normalization theorem for free-forgetful adjunctions in a concrete algebraic category.

Possible signature:
```lean
theorem adjunction_monad_assoc
  {C : Type u} {D : Type u'}
  [Category.{v} C] [Category.{v'} D]
  (F : C ⥤ D) (G : D ⥤ C) (h : F ⊣ G) :
  -- explicit associativity statement for the monad induced by h
  ...
```

#### Why this matters
Adjunctions are not just existence statements; they are **program transformations**. The unit inserts generators, the counit evaluates syntax, and the triangle identities are correctness theorems for round-trip compilation.

---

### Theorem 5: Free-forgetful adjunction as certified synthesis in a concrete category

Choose one concrete free-forgetful adjunction already well-supported in Mathlib or realistically formalizable:
- free monoid / forgetful,
- free group / forgetful,
- free module / forgetful,
- product–diagonal adjunction in `Type`,
- maybe lattice-theoretic free construction if available.

Then prove a theorem that is not just “there exists an adjunction”, but a **universal synthesis principle**.

Example target in `Type` using product/diagonal:
```lean
theorem diagonal_right_adjoint_hom_equiv
  {C : Type u} [Category.{v} C]
  [HasBinaryProducts C]
  (X : C) (Y Z : C) :
  ((Discrete.functor (fun _ : Fin 2 => X)) ⟶ ... ) ≃ ...
```
But more realistically, if working in algebra:
```lean
theorem free_hom_ext
  {α : Type u} {M : MonCat}
  (f g : FreeMonoid α ⟶ M)
  (h : ∀ a : α, ... ) :
  f = g
```
or the analogous theorem for free modules.

#### Strong preferred form
A theorem saying that maps out of a free object are determined by generator data, with an explicit algorithm extracting the universal morphism.

#### Why this matters
This is the bridge from category theory to automated construction. Free objects are symbolic languages; universal arrows are interpreters. Formalizing this properly turns adjunction into **verified code generation**.

---

## Stretch Goal: A Lean-friendly adjoint functor theorem fragment

The full general adjoint functor theorem in maximal generality is likely too heavy for one cycle unless Mathlib already has substantial infrastructure. Do **not** sink the project into inaccessible set-theoretic bureaucracy.

Instead, prove a **sharp, usable fragment**:

> If a functor has a specified universal arrow from every object, then one can construct a left adjoint.

This is mathematically central and much more Lean-realistic.

#### Lean 4 target signature
Something like:
```lean
theorem left_adjoint_of_universal_arrows
  {C : Type u} {D : Type u'}
  [Category.{v} C] [Category.{v'} D]
  (G : D ⥤ C)
  (h : ∀ X : C, ∃ (Y : D) (η : X ⟶ G.obj Y),
      ∀ Z : D, IsUniversalArrow G X Y η Z) :
  ∃ F : C ⥤ D, F ⊣ G
```

You will likely need to define a suitable `IsUniversalArrow` if Mathlib lacks the exact form:
```lean
structure IsUniversalArrow
  {C : Type u} {D : Type u'}
  [Category.{v} C] [Category.{v'} D]
  (G : D ⥤ C) (X : C) (Y : D) (η : X ⟶ G.obj Y) : Prop where
  lift : ∀ {Z : D}, (X ⟶ G.obj Z) → (Y ⟶ Z)
  fac : ...
  uniq : ...
```

This new definition satisfies the novelty requirement and has major future value.

#### Why this is the right abstraction
This is the constructive heart of adjoint existence. It replaces inaccessible “there exists an adjoint” statements with a buildable object-by-object synthesis recipe.

---

## Proof Strategy Architecture

You must not provide only one proof path. Use at least 2–3 strategies and select the best one for each theorem.

### Strategy A: Direct Yoneda reduction via evaluation at identity
Best for Theorems 1 and 2.

1. Start from a natural isomorphism `h : yoneda.obj X ≅ yoneda.obj Y`.
2. Evaluate `h.hom.app (op X)` at `𝟙 X` to obtain a morphism `X ⟶ Y`.
3. Evaluate `h.inv.app (op Y)` at `𝟙 Y` to obtain a morphism `Y ⟶ X`.
4. Use naturality and `Category.assoc`/`FunctorToTypes.naturality` to prove these are inverses.

Why promising: this mirrors the conceptual proof and keeps the formal object-level content explicit. It also yields reusable helper lemmas.

### Strategy B: Use full faithfulness of Yoneda if already in Mathlib
Best if Mathlib already exposes `yonedaFullyFaithful` or equivalent.

1. Identify an existing `Full`/`Faithful` instance for `yoneda`.
2. Pull back the natural isomorphism along the fully faithful embedding.
3. Recover `X ≅ Y` via `Functor.mapIso` reflection or preimage of morphisms.

Why promising: shorter, library-aligned, robust against low-level naturality pain.  
Why risky: depends on exact library API and may obscure the mathematics if overused.

### Strategy C: Componentwise extensionality for adjunctions
Best for triangle identities, monad laws, and free-object uniqueness.

1. Expand definitions of unit/counit / hom-equivalence.
2. Use `ext`, `simp`, `rw`, and multi-step `calc` chains.
3. For uniqueness, apply `by_contra` and transport equality through the hom-set equivalence.
4. Use explicit component formulas to extract computational meaning.

Why promising: this is the right way to produce deep Lean proofs rather than mere theorem invocation.

---

## Cross-Domain Connection Requirement

You must include at least one theorem connecting category theory to another domain.

### Preferred connection: semantics / computation
Formalize the principle:

> Morphisms from a free object correspond to programs defined by generator assignments.

This ties adjunctions to **program synthesis** and **compiler correctness**.

A theorem of the form:
```lean
theorem free_object_semantics_determined_by_generators
  ...
```
should explicitly interpret the universal property as a semantics assignment.

### Alternative connection: logic / observational equivalence
Use Yoneda faithfulness to formalize:

> Two states/processes are equal if every observable test yields the same response.

This connects category theory to **physics**, **systems theory**, and **model checking**.  
If you define a small category of experiments/probes, then a finite-probe detection theorem becomes a formal statement about experimental indistinguishability.

### Ambitious connection: algebra + information
Interpret representable functors as measurement channels and prove a finite-probe injectivity statement in a finite category. This would be a categorical analogue of compressed sensing or identifiability.

---

## Concrete Lean Tactics and Techniques You Must Use

Your file must contain at least 3 theorem proofs with substantial reasoning using several of:
- `intro`
- `rcases`
- `refine`
- `ext`
- `by_contra`
- `calc`
- `simpa`
- `aesop_cat?` only as a minor helper, not the whole proof
- explicit rewriting with naturality lemmas
- induction if you choose a free construction on syntax/words
- `field_simp` only if a concrete algebraic example truly needs it

Avoid proofs that collapse to library automation with no mathematical content.

---

## Suggested Build Order

1. **Reconstruction lemmas from Yoneda**
   - identity evaluation helper,
   - extraction of morphism from natural transformation,
   - proof of inverse identities.

2. **Faithfulness/extensionality theorem**
   - show equality of Yoneda images implies equality of morphisms.

3. **New definition**
   - `IsUniversalArrow` or `FiniteProbeFamily` or both.

4. **Adjunction from universal arrows**
   - object choice,
   - map construction,
   - functor laws,
   - hom-equivalence,
   - triangle identities.

5. **Concrete free-forgetful application**
   - instantiate abstract theorem in a tractable category,
   - derive an explicit algorithm.

6. **Cross-domain theorem**
   - semantics/programming interpretation or observational equivalence statement.

---

## Building on Existing Catalog Theorems

The listed catalog theorems are not directly categorical, but one should still leverage the **meta-pattern** they embody: a theorem named `master_theorem` or `grand_unification_theorem` indicates the repository values structurally central statements that unify many instances. Your Yoneda reconstruction theorem and universal-arrow-to-adjunction theorem should be written in that same spirit: not as isolated lemmas, but as **organizing principles** for future formalization.

In particular, create theorem names and docstrings that make these results obvious future dependencies, e.g.
- `yoneda_reconstruction_theorem`
- `universal_arrow_adjunction_theorem`
- `free_object_semantics_theorem`

These should function as “master theorems” for category-theoretic developments in the codebase.

---

## Conjecture with Testable Prediction

You must include at least one falsifiable conjecture with a computational disproof criterion.

### Recommended conjecture
For finite categories, every presheaf that is finitely probe-reconstructible with respect to a separating probe family is a quotient of a finite coproduct of representables.

Possible statement in prose:
> **Conjecture (finite probe representability).**  
> Let `C` be a finite category. Any presheaf `F : Cᵒᵖ ⥤ Type` that is detected by a finite separating family of probes admits a surjective natural transformation from a finite coproduct of representable presheaves.

### Computational test
Write code that, for small finite categories:
1. enumerates presheaves up to bounded cardinality,
2. checks detection by a candidate probe family,
3. searches for a surjective map from a finite sum of representables.

A single counterexample disproves the conjecture.

Alternative conjecture:
> In a finite skeletal category, if `yoneda.obj X` and `yoneda.obj Y` agree on a separating finite subcategory of probes, then `X ≅ Y`.

This is highly testable by brute force on finite categories.

---

## Verified Algorithm / Computational Deliverable

You must produce a verified algorithm, not just theorems.

### Required algorithmic target
Implement one of:

1. **Yoneda reconstruction algorithm**  
   Input: a natural isomorphism `yoneda.obj X ≅ yoneda.obj Y`.  
   Output: an explicit isomorphism `X ≅ Y`, extracted by evaluation at identities.

2. **Universal-arrow-to-left-adjoint constructor**  
   Input: for each `X`, chosen universal arrow data into `G`.  
   Output: a functor `F` and certified adjunction `F ⊣ G`.

3. **Free semantics synthesizer**  
   Input: assignments on generators.  
   Output: the unique morphism from the free object extending that assignment, together with a proof of uniqueness.

This algorithm must be exercised in `demo.py`.

---

## Deliverables — ALL MANDATORY

You must produce all of the following:

1. **Lean file(s)** with at least 3 substantial theorems, one new definition, one cross-domain theorem, and minimized `sorry`.
2. **FUTURE_DIRECTIONS.md** with 3–5 falsifiable scientific hypotheses. Each must include:
   - a precise conjecture,
   - why it might be true,
   - a concrete computational or formal test that could refute it.
3. **RESEARCH_PAPER.md** as a standalone scientific paper:
   - problem statement,
   - theorem statements,
   - proof ideas,
   - why the results matter,
   - future experiments and open problems.
4. **ARTICLE.md** in Scientific American style:
   - accessible narrative,
   - intuitive explanation of Yoneda/adjunctions,
   - why reconstruction from observables matters.
5. **A verified algorithm or computational method** implementing one of the targets above.
6. **demo.py** that interactively demonstrates:
   - reconstructing an isomorphism from a Yoneda isomorphism, or
   - constructing a left adjoint from universal-arrow data, or
   - synthesizing a map from a free object from generator assignments.

---

## Minimal Theorem List You Should Aim to Include

A strong file would contain results close to:

```lean
theorem hom_ext_of_yoneda
  {C : Type u} [Category.{v} C]
  {X Y : C} {f g : X ⟶ Y}
  (h : yoneda.map f = yoneda.map g) :
  f = g
```

```lean
theorem iso_of_yoneda_obj_iso
  {C : Type u} [Category.{v} C]
  {X Y : C}
  (h : yoneda.obj X ≅ yoneda.obj Y) :
  X ≅ Y
```

```lean
structure IsUniversalArrow
  {C : Type u} {D : Type u'}
  [Category.{v} C] [Category.{v'} D]
  (G : D ⥤ C) (X : C) (Y : D) (η : X ⟶ G.obj Y) : Prop where
  lift : ∀ {Z : D}, (X ⟶ G.obj Z) → (Y ⟶ Z)
  fac : ∀ {Z : D} (f : X ⟶ G.obj Z), η ≫ G.map (lift f) = f
  uniq : ∀ {Z : D} (f : X ⟶ G.obj Z) (g : Y ⟶ Z),
    η ≫ G.map g = f → g = lift f
```

```lean
theorem left_adjoint_of_universal_arrows
  {C : Type u} {D : Type u'}
  [Category.{v} C] [Category.{v'} D]
  (G : D ⥤ C)
  (h : ∀ X : C, ∃ Y : D, ∃ η : X ⟶ G.obj Y, IsUniversalArrow G X Y η) :
  ∃ F : C ⥤ D, F ⊣ G
```

```lean
theorem left_triangle_components
  {C : Type u} {D : Type u'}
  [Category.{v} C] [Category.{v'} D]
  (F : C ⥤ D) (G : D ⥤ C) (h : F ⊣ G) :
  ∀ X : C, F.map ((Adjunction.unit h).app X) ≫ (Adjunction.counit h).app (F.obj X) = 𝟙 (F.obj X)
```

```lean
theorem free_object_semantics_determined_by_generators
  ...
```

If one of these is already in Mathlib, do not simply restate it: derive a stronger corollary, a computational extraction theorem, or a new extensionality principle from it.

---

## Final Call to Arms

Do not submit a polite formalization of well-known lemmas. Build a **categorical observability theory** in Lean:
- Yoneda as reconstruction from probes,
- adjunction as certified synthesis,
- free objects as executable syntax,
- finite probes as the first step toward computational category theory.

The right outcome is that a future researcher can use your file not merely to quote Yoneda, but to **recover hidden structure from behavior**, **construct adjoints from universal data**, and **compile generators into semantics with proof of correctness**.

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

Research domain: Algebra
Research mode: prove
