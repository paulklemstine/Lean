## Assignment: Langlands Correspondence: GL(1) Case — but make it mathematically real

**Mode:** `formalize` + `prove`

Do not merely sketch class field theory folklore. Carve out a formally verified **proto-Langlands machine for GL(1)** in Lean 4 that captures the structural heart of global class field theory in a way that is both mathematically meaningful and computationally testable.

The target is not “all of class field theory” in one step — that would collapse into placeholders. The target is a **precise, nontrivial, extensible formal core**: construct the algebraic interfaces for adèles/idèles, prove the reciprocity-compatible universal properties that characterize the GL(1) correspondence, and verify at least one genuine correspondence theorem in a tractable setting.

You must produce **new, non-trivial theorems** and **new definitions**. Minimize sorry. Avoid vacuous wrappers around existing Mathlib APIs.

---

## Central Vision

The breakthrough is to formalize **Langlands for tori in rank one**, beginning with GL(1), not as a bag of classical definitions but as a **universal comparison theorem** between:

1. arithmetic data: valuations, local completions, restricted products, norm-compatible principal embeddings;
2. representation-theoretic data: continuous 1-dimensional characters;
3. Galois data: abelianized Galois action encoded through reciprocity;
4. harmonic-analysis data: Hecke characters as multiplicative automorphic objects on idèles.

This is revolutionary because once the GL(1) bridge is formalized correctly, it becomes the canonical template for:
- higher-dimensional automorphic formalization,
- explicit reciprocity algorithms,
- computational experiments on characters and conductors,
- and eventually a formal Lean interface between arithmetic geometry and automorphic representation theory.

Application keywords: **global class field theory, adèles, idèles, Artin reciprocity, Hecke characters, Pontryagin duality, restricted products, local-global principles, automorphic forms, abelian Galois representations, computational number theory**

---

## Precise Formalization Target

You should not attempt the full theorem over arbitrary global fields immediately. Instead, formalize a **layered theorem stack**:

### Layer 1: Restricted product and principal embedding
Define a general restricted product structure for families of commutative groups/rings with distinguished compact-open subgroups (or simply designated subgroups in the first abstraction layer). Then instantiate it for a prototype “idele-like” object.

### Layer 2: Idèle class group interface
Define the quotient by principal elements and prove the induced universal property for characters trivial on principal elements.

### Layer 3: GL(1) Langlands in a tractable arithmetic model
Prove an actual correspondence theorem in a setting where the arithmetic is formalizable now:
- either a **finite set of places model**,
- or a **toy global field interface** with axioms,
- or the **rational field prototype** where you formalize finite-support valuation data and principal diagonals.

The key is: prove a theorem whose content is genuinely Langlands/reciprocity-shaped, not just a definition.

---

## Required New Definitions

You must define at least one genuinely new structure not already present in the catalog. Preferably define all three:

```lean
/-- A family of local multiplicative groups together with designated integral subgroups,
used to model restricted products such as idèles. -/
structure RestrictedProductData (ι : Type*) where
  Local    : ι → Type*
  instCommGroup : ∀ v, CommGroup (Local v)
  Integral : ∀ v, Subgroup (Local v)
attribute [instance] RestrictedProductData.instCommGroup
```

```lean
/-- Finite-support restricted product: elements are families which lie outside the
designated integral subgroup at only finitely many places. -/
def IsRestrictedFamily {ι : Type*} (D : RestrictedProductData ι)
    (x : ∀ v, D.Local v) : Prop :=
  {v | x v ∉ D.Integral v}.Finite
```

```lean
/-- Characters on a restricted product that kill principal elements; this is the
formal proxy for Hecke characters at the first stage of development. -/
structure HeckeCharacterLike
    {K A : Type*} [CommGroup K] [CommGroup A] where
  toMonoidHom : K →* A
  trivial_on_principal : ∀ x, x ∈ principalSubgroup K → toMonoidHom x = 1
```

You may refine these types to fit Lean/Mathlib better, but the mathematical content must remain.

---

## Precise Theorem Statements to Target

At least **3 substantial theorems** must be proved. Here is the recommended theorem suite.

### Theorem 1: Principal embedding lands in the restricted product
This is the formal local-global compatibility theorem.

**Mathematical statement:**  
For a global-field-like object with normalized valuations \(v\), every principal element has only finitely many non-integral components in the diagonal embedding into the idèle restricted product.

**Lean 4 target signature (prototype form):**
```lean
theorem principal_family_is_restricted
    {K : Type*} [Field K]
    {Places : Type*}
    (v : Places → K → ℤ)
    (hv_mul : ∀ p x y, v p (x * y) = v p x + v p y)
    (hv_one : ∀ p, v p 1 = 0)
    (finite_support : ∀ x : Kˣ, {p | v p x.1 ≠ 0}.Finite) :
    ∀ x : Kˣ, IsRestrictedFamily (ideleData v) (principalFamily v x)
```

**Why it matters:**  
This is the exact formal hinge from “field element” to “idèle.” Without it, the principal diagonal is meaningless. With it, you have the first honest bridge from arithmetic to automorphic objects.

---

### Theorem 2: Universal descent of characters to the idèle class quotient
This is the formal representation-theoretic core of GL(1): characters trivial on principal idèles descend uniquely to the idèle class group.

**Lean 4 target signature:**
```lean
theorem character_descends_to_idele_class_group
    {G A : Type*} [CommGroup G] [CommGroup A]
    (P : Subgroup G)
    (χ : G →* A)
    (hχ : ∀ p : P, χ p.1 = 1) :
    ∃! χbar : G ⧸ P →* A, χ = χbar.comp (QuotientGroup.mk' P)
```

This likely already follows from quotient universal properties in Mathlib, but your proof must be explicit, multi-step, and integrated into the idèle-class formalism. The theorem becomes nontrivial when instantiated with your principal subgroup.

**Why it matters:**  
This is the exact algebraic skeleton of the statement “Hecke characters are characters of the idèle class group.”

---

### Theorem 3: Correspondence between principal-trivial idèle characters and quotient characters
This is the first genuine correspondence theorem.

**Mathematical statement:**  
Characters of the restricted product trivial on the principal subgroup are in canonical bijection with characters of the idèle class group.

**Lean 4 target signature:**
```lean
def IdeleClassCharacter
    (G : Type*) [CommGroup G] (P : Subgroup G) (A : Type*) [CommGroup A] :=
  (G ⧸ P) →* A

def PrincipalTrivialCharacter
    (G : Type*) [CommGroup G] (P : Subgroup G) (A : Type*) [CommGroup A] :=
  {χ : G →* A // ∀ p : P, χ p.1 = 1}

theorem principal_trivial_character_equiv_quotient_character
    (G : Type*) [CommGroup G] (P : Subgroup G)
    (A : Type*) [CommGroup A] :
    PrincipalTrivialCharacter G P A ≃ IdeleClassCharacter G P A
```

**Why it matters:**  
This is the clean categorical statement behind the GL(1) Langlands slogan. It is not yet Artin reciprocity, but it is the exact formal mechanism through which reciprocity can act.

---

## Strongly Recommended Fourth Theorem: Reciprocity as uniqueness from local data

To move beyond abstract quotient theory, prove a theorem of the following shape.

**Mathematical statement:**  
If two idèle class characters agree on local uniformizers and on the integral subgroups at every place, then they are equal.

This is a uniqueness theorem showing that global characters are controlled by local data — the conceptual core of reciprocity.

**Lean 4 target signature (schematic):**
```lean
theorem idele_class_character_ext_of_local_data
    {ι : Type*} [DecidableEq ι]
    (D : RestrictedProductData ι)
    (χ ψ : RestrictedProduct D →* A)
    (hprincipalχ : ∀ x, x ∈ principalSubgroup _ → χ x = 1)
    (hprincipalψ : ∀ x, x ∈ principalSubgroup _ → ψ x = 1)
    (hunits : ∀ v u, u ∈ D.Integral v → χ (single v u) = ψ (single v u))
    (huniformizer : ∀ v π, IsUniformizer v π → χ (single v π) = ψ (single v π)) :
    χ = ψ
```

This may require a finite-support decomposition theorem for restricted families. That decomposition itself is an excellent deep theorem.

---

## Most Promising Route to a Genuine “Artin Reciprocity” Theorem

Do **not** overclaim the full classical Artin reciprocity theorem unless you can support the topology, continuity, and Galois formalization. Instead prove a **proto-Artin reciprocity theorem** with exact algebraic content:

### Recommended formal theorem
Assume a map from idèles to an abstract abelian Galois group satisfies:
- triviality on principal idèles,
- multiplicativity,
- local compatibility with specified Frobenius generators away from ramification.

Then it descends uniquely to the idèle class group.

**Lean signature:**
```lean
theorem proto_artin_reciprocity_descends
    {G Γ : Type*} [CommGroup G] [CommGroup Γ]
    (P : Subgroup G)
    (Art : G →* Γ)
    (hP : ∀ p : P, Art p.1 = 1) :
    ∃! Artbar : G ⧸ P →* Γ, Art = Artbar.comp (QuotientGroup.mk' P)
```

Then instantiate this with a “Frobenius-specified” quotient presentation if feasible.

This is the mathematically honest way to formalize Artin reciprocity in stages.

---

## 2–3 Proof Strategy Paths

### Strategy A: Quotient-universal-property first, arithmetic later
**Best first path.**
1. Build the abstract algebra of restricted products and principal subgroups.
2. Prove the descent/bijection theorems for characters using quotient groups and extensionality.
3. Only then instantiate arithmetic models of principal embeddings and finite-support valuations.

**Why promising:**  
Mathlib is strongest here. You will get substantial theorems with low risk of getting trapped in topological/completion infrastructure too early.

---

### Strategy B: Finite-set-of-places model as a rigorous prototype
1. Replace all places by a finite index set \(S\).
2. Define the “idele group” as a finite product and the “principal subgroup” diagonally.
3. Prove the exact quotient-character correspondence and local-data extensionality theorem.
4. Generalize to restricted products by replacing finite support with `Set.Finite`.

**Why promising:**  
This yields a concrete verified theorem with nontrivial proof structure and a clean computational demo. It is the fastest path to a formally solid GL(1)-prototype.

---

### Strategy C: Valuation-theoretic rational prototype
1. Model principal idèles of `ℚˣ` by \(p\)-adic valuation exponents with finite support.
2. Prove the product-formula-style finite-support theorem for rationals.
3. Define multiplicative characters from exponent sums modulo relations.
4. Show they factor through the principal quotient.

**Why ambitious and exciting:**  
This starts touching actual arithmetic. It also connects directly to computational tests. But it may require more groundwork on rationals, prime factorizations, and valuations than is realistic in one cycle.

**Recommendation:** Use Strategy A as the backbone, and either B or C as the concrete arithmetic instantiation.

---

## Cross-Domain Connections You Must Exploit

You are required to include at least one theorem connecting GL(1) Langlands to a different domain. Here are the best options.

### Connection 1: Harmonic analysis / Pontryagin duality
The GL(1) correspondence is fundamentally a statement about characters. Formalize a theorem showing that quotient characters correspond to annihilators of the principal subgroup. Even if full Pontryagin duality is out of reach, prove the algebraic dual statement.

Possible theorem:
```lean
theorem principal_subgroup_annihilator_characterization
    (G : Type*) [CommGroup G] (P : Subgroup G)
    (A : Type*) [CommGroup A] :
    {χ : G →* A // ∀ p : P, χ p.1 = 1}
      ≃ ((G ⧸ P) →* A)
```

This is simultaneously algebra, representation theory, and harmonic analysis.

---

### Connection 2: Category theory
Show functoriality of quotient-character descent under morphisms preserving principal subgroups.

Possible theorem:
```lean
theorem character_descent_natural
    {G H A : Type*} [CommGroup G] [CommGroup H] [CommGroup A]
    (P : Subgroup G) (Q : Subgroup H)
    (f : G →* H)
    (hf : P ≤ Subgroup.comap f Q) :
    ...
```

This opens a categorical formulation of abelian Langlands.

---

### Connection 3: Information/compression viewpoint
A Hecke character trivial on principal idèles is a “global observable” depending only on quotient data. Formalize a theorem that the quotient is the **minimal sufficient invariant** for such characters.

This is mathematically just the universal property of quotienting, but conceptually it links class field theory to information theory and invariance principles. If done carefully in `RESEARCH_PAPER.md`, this is a striking cross-domain narrative.

---

## Concrete Deep Theorem Candidates Beyond the Core 3

If you want stronger results, prove one or more of:

### A. Restricted product subgroup theorem
```lean
theorem restricted_families_form_subgroup
    (D : RestrictedProductData ι) :
    Subgroup (∀ v, D.Local v)
```
with carrier `IsRestrictedFamily D`.  
This requires proving finite support is stable under multiplication and inverse using subgroup closure and finite unions.

### B. Principal embedding is a monoid hom
```lean
def principalEmbedding :
    Kˣ →* RestrictedProduct D
```
followed by proof of multiplicativity.

### C. Character extensionality by generators
If your restricted product is generated by local integral elements and uniformizers together with principal elements, prove character equality from generator agreement.

### D. Conductor-like support finiteness
Formalize a “ramification support” of a character as the set of places where it is nontrivial on the integral subgroup, and prove finiteness under suitable hypotheses in a finite-place or finitely generated model.

This would be a very strong bridge toward genuine Hecke theory.

---

## Suggested Lean 4 Scaffolding

You should aim for theorem statements of roughly the following flavor:

```lean
structure RestrictedProduct (D : RestrictedProductData ι) where
  toFun : ∀ v, D.Local v
  restricted' : IsRestrictedFamily D toFun
```

```lean
def principalSubgroup (G : Type*) [CommGroup G] : Subgroup G := ...
```

```lean
def principalTrivialCharacters
    (G : Type*) [CommGroup G] (P : Subgroup G) (A : Type*) [CommGroup A] :=
  {χ : G →* A // ∀ p : P, χ p.1 = 1}
```

```lean
theorem quotient_character_lift_unique
    {G A : Type*} [CommGroup G] [CommGroup A]
    (P : Subgroup G) :
    principalTrivialCharacters G P A ≃ ((G ⧸ P) →* A)
```

```lean
theorem diagonal_mem_principalSubgroup
    ...
```

```lean
theorem restricted_support_mul_subset
    ...
```

Use `rcases`, subgroup extensionality, quotient induction, `by_contra`, finite set manipulations, and multi-step `calc` blocks. Avoid short-circuit proofs.

---

## Existing Verified Theorems: How to Build on Them

The listed catalog theorems are not directly about Langlands, but they still indicate useful styles and interfaces.

1. `galois_connection_theory_variety`  
   file: `Algebra/ProofSpectra/Core.lean`  
   Use this as inspiration for **duality-shaped interfaces**: your character/quotient equivalence should be presented as a genuine correspondence, not an ad hoc existence lemma.

2. `quadratic_reciprocity_law`  
   file: `FINAL/Algebra/TimelineGravityCycles.lean`  
   This is a reminder that arithmetic reciprocity laws are already accepted as catalog-level objects. Your brief should frame proto-Artin reciprocity as the **structural umbrella** under which quadratic reciprocity sits. In the paper, explicitly explain that GL(1) Langlands globalizes reciprocity laws.

3. `pell_group_law_unif` and `circle_group_law`  
   files: `FINAL/Algebra/UnifyingTheory.lean`, `FINAL/Algebra/MoonshotExplorations.lean`  
   These show that **nontrivial group laws on arithmetic varieties** are already in the ecosystem. Leverage this style: define your idèle-like objects as genuine algebraic structures with laws, not just sets with predicates.

Do not force these theorems into the proof if they are irrelevant. Build on them conceptually: the catalog already tolerates bold algebraic structures and reciprocity-flavored statements.

---

## Falsifiable Conjecture with Computational Test

You must state at least one conjecture with a clear disproof protocol.

### Recommended conjecture
For a finite-place prototype of the idèle class group over `ℚ`, every character trivial on the diagonal principal subgroup is determined by its values on:
- local uniformizers at the finitely many places in the model, and
- one archimedean sign parameter.

**Conjecture draft:**
```lean
/-- Conjecture: in the finite-place rational prototype, a principal-trivial character
is uniquely determined by its values on chosen local uniformizers together with the
archimedean sign character. -/
conjecture finite_place_GL1_character_determined_by_uniformizers : Prop
```

**Computational test:**  
For a chosen finite set of primes `S`, enumerate candidate character assignments on local generators subject to the principal relation, then search for two distinct induced characters agreeing on all generator values. Any such pair disproves the conjecture.

Alternative stronger conjecture:
- the group of principal-trivial characters in the finite `S`-idele model is isomorphic to a product of finite cyclic groups determined by valuation relations.

This can be tested by explicit matrix-relation computation.

---

## Demo / Algorithm Requirement

You must provide a **verified algorithm or computational method**, not only theorems.

### Recommended algorithm
Implement a procedure that, in a finite-place idèle prototype:
1. takes local character data on a finite set of places,
2. checks whether it is trivial on the principal diagonal relations,
3. constructs the induced quotient character if valid.

This is the computational avatar of Artin reciprocity descent.

Possible Python demo features for `demo.py`:
- choose a finite set of primes `S = {2,3,5}`;
- define local characters by roots of unity / modular exponent data;
- verify principal-triviality constraints;
- build the induced idèle class character;
- compare two local datasets and determine whether they define the same global character.

This turns the formal theorem into an executable experiment.

---

## Mandatory Deliverables

You must produce **all** of the following:

1. **Lean file(s)** with at least **3 deep theorems** proven using multi-step reasoning (`induction`, `rcases`, `by_contra`, `field_simp`, `calc`, quotient induction, finite-support arguments, subgroup extensionality).
2. **A structured `FUTURE_DIRECTIONS.md`** containing **3–5 testable scientific hypotheses**, each falsifiable with a clear computational or formal test.
3. **A standalone `RESEARCH_PAPER.md`** explaining:
   - what was formalized,
   - the exact theorem statements,
   - why GL(1) is the seed of Langlands,
   - what remains before full Artin reciprocity over global fields,
   - and how this opens the door to higher-rank formalization.
4. **An `ARTICLE.md` in Scientific American style** explaining adèles, idèles, and reciprocity as a “hidden communication protocol” between primes and symmetry.
5. **A verified algorithm or computational method** for descending local character data to quotient characters.
6. **A `demo.py`** that interactively demonstrates the finite-place GL(1) correspondence.

---

## Final Standard

A successful result will make a mathematician say:

> “This is not yet the whole Langlands correspondence, but it is the first genuinely formal bridge between arithmetic reciprocity and automorphic characters in Lean — and it is built in a way that can scale.”

That is the bar.

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
