## Assignment: Hilbert 12 Beyond Kronecker–Weber — A Formal Blueprint for Explicit Abelian Generation

**Mode:** prove / formalize / discover

Prove genuinely new, non-trivial theorems that transform the slogan “Kronecker–Weber for arbitrary fields” into a precise Lean 4 research program. Do **not** attempt the full classical Hilbert 12 conjecture in one leap; instead, isolate formally tractable, structurally decisive theorems that together build a machine for **explicit abelian extension generation**, beginning with Hilbert class fields and moving toward a proto-Langlands reciprocity interface.

Your target is to create a new formal framework in Lean 4 for **explicit class-field generators via ideal-class actions**, with at least one theorem linking number theory to a second domain such as representation theory, dynamical systems, or idempotent algebra.

---

## Core Vision

Kronecker–Weber says every finite abelian extension of `ℚ` sits inside a cyclotomic field. The true breakthrough is not merely reproving this spirit in a special case, but formalizing a **universal architecture** for explicit abelian generation over general number fields:

- define a formal object encoding “candidate explicit generators” for abelian extensions,
- prove that ideal-class symmetries act through this object,
- show unramifiedness / class-number bounds / principality criteria in a formally checkable way,
- extract a verified algorithm that computes finite approximations to class-group-controlled extension data,
- connect this action to a representation-theoretic or tropical/idempotent shadow.

This is how to make Hilbert 12 formalization scientifically real: not by handwaving about special values, but by proving exact intermediary theorems that certify the architecture of explicit class field generation.

---

## Precise Formal Targets

You must introduce at least one **new definition** not present in the catalog. A suggested centerpiece:

```lean
/-- A proto-explicit class field datum over a Dedekind domain:
a finite quotient of fractional ideals together with a class invariant map
that is constant on principal ideals satisfying a positivity/congruence condition. -/
structure ExplicitClassFieldDatum (R : Type*) [CommRing R] :=
  (Cl : Type*)
  [instFintypeCl : Fintype Cl]
  [instDecidableEqCl : DecidableEq Cl]
  (classMap : Ideal R → Cl)
  (principal_trivial : ∀ I : Ideal R, IsPrincipal I → classMap I = classMap ⊥)
  (surjective_classMap : Function.Surjective classMap)
```

If ideals are too coarse for the available Mathlib layer, replace with a quotient of a finitely generated commutative monoid modeling ideal classes. The point is conceptual novelty with formal traction.

You should also define a **proto-Hilbert class field witness**:

```lean
/-- A finite extension candidate equipped with a class action intended
to model the Hilbert class field of `K`. -/
structure HilbertClassFieldWitness (K L : Type*) [Field K] [Field L] [Algebra K L] :=
  (classGroup : Type*)
  [instFintypeClassGroup : Fintype classGroup]
  [instDecidableEqClassGroup : DecidableEq classGroup]
  (act : classGroup →* MulAut L)
  (fixed_base : ∀ x : L, (∀ c, act c x = x) → ∃ y : K, algebraMap K L y = x)
```

The exact implementation may vary, but it must encode a finite class symmetry acting on an extension candidate.

---

## Theorem Program

You must prove **at least 3 deep theorems** with substantial proof structure. Here are the recommended targets.

### Theorem 1: Principality kills the class action
Formalize the foundational fact that if the class group is trivial, then any proto-Hilbert class field witness is formally forced to collapse to the base field.

**Lean-style statement:**
```lean
theorem fixedField_eq_base_of_subsingleton_classGroup
  {K L : Type*} [Field K] [Field L] [Algebra K L]
  (H : HilbertClassFieldWitness K L)
  [Subsingleton H.classGroup] :
  ∀ x : L, ∃ y : K, algebraMap K L y = x
```

This is the formal skeleton of “class number one implies trivial Hilbert class field.”

**Why this matters:** It captures the first genuinely structural bridge between arithmetic and explicit generation. This theorem is the algebraic fixed-point shadow of the class number one phenomenon, and once formalized it becomes a reusable endpoint for every future explicit class field construction.

**Proof strategy options:**
1. **Direct fixed-action collapse**
   - Use `Subsingleton H.classGroup` to show `act c = 1` for all `c`.
   - Deduce every `x : L` is fixed by the action.
   - Apply `fixed_base`.
   - Most promising because it requires only finite-group and action infrastructure.
2. **By contradiction via nontrivial orbit**
   - Assume `x` not in image of `K`.
   - Then `fixed_base` implies existence of `c` with `act c x ≠ x`.
   - Contradict subsingletonity.
3. **Orbit-stabilizer shadow**
   - Define the orbit of `x`.
   - Show every orbit is singleton since the group is trivial.
   - Conclude fixedness and descend to `K`.

Use multi-step `calc`, `rcases`, and `by_contra`.

---

### Theorem 2: Finite class data induces a finite symmetry representation
Show that any finite explicit class datum canonically yields a finite permutation representation, which is the first formal bridge from class field theory to Langlands-style representation data.

**Lean-style statement:**
```lean
theorem explicitClassFieldDatum_perm_rep
  {R : Type*} [CommRing R]
  (D : ExplicitClassFieldDatum R) :
  ∃ ρ : D.Cl →* Equiv.Perm D.Cl, True
```

A stronger version, preferable if convenient:

```lean
theorem explicitClassFieldDatum_regular_rep_faithful
  {R : Type*} [CommRing R]
  (D : ExplicitClassFieldDatum R)
  [Group D.Cl] :
  ∃ ρ : D.Cl →* Equiv.Perm D.Cl, Function.Injective ρ
```

**Why this matters:** Class field theory becomes revolutionary when reinterpreted as a source of Galois representations. Even a formally modest theorem showing that class data canonically produces a faithful finite permutation representation creates the first certified “toy Langlands” interface in Lean.

**Proof strategy options:**
1. **Regular representation**
   - Define `ρ c` by left multiplication on `D.Cl`.
   - Verify homomorphism laws.
   - Prove injectivity by evaluating at `1`.
   - Most promising because it is entirely algebraic and already representation-theoretic.
2. **Action on fibers of the class map**
   - Let `D.Cl` act on ideals modulo the kernel relation.
   - Descend the action to the quotient.
   - More arithmetic flavor, but heavier quotient machinery.
3. **Cayley embedding**
   - Invoke the standard embedding of a finite group into permutations.
   - Then reinterpret as “finite class symmetry gives finite automorphic shadow.”

Use `ext`, `funext`, `rcases`, and explicit homomorphism verification.

---

### Theorem 3: A class-number bound yields extension-degree bound
Create a theorem stating that any proto-Hilbert class field witness has extension complexity bounded by the size of its class symmetry. Even if full field-degree formalization is unavailable, prove a finite-orbit or finite-generator bound.

**Lean-style statement:**
```lean
theorem orbit_card_le_classGroup_card
  {K L : Type*} [Field K] [Field L] [Algebra K L]
  (H : HilbertClassFieldWitness K L) :
  ∀ x : L, Fintype.card (MulAction.orbit H.act.toMonoidHom x) ≤ Fintype.card H.classGroup
```

If `MulAction.orbit` is inconvenient, define your own finite orbit set.

A more arithmetic reformulation, if finite-dimensionality infrastructure is accessible:

```lean
theorem finrank_le_card_classGroup
  {K L : Type*} [Field K] [Field L] [Algebra K L] [FiniteDimensional K L]
  (H : HilbertClassFieldWitness K L) :
  Module.finrank K L ≤ Fintype.card H.classGroup
```

Only pursue the stronger statement if you can prove it honestly.

**Why this matters:** This is the formal arithmetic content of “the Hilbert class field is controlled by the class group.” It turns qualitative reciprocity into a quantitative theorem suitable for algorithms.

**Proof strategy options:**
1. **Orbit injection into class group**
   - Map each orbit point to a witnessing group element.
   - Prove well-defined cardinal bound by surjection from class group to orbit.
   - Most promising.
2. **Span by orbit**
   - Show the `K`-subspace generated by the orbit contains the relevant element.
   - Bound generator count by orbit cardinal.
   - Then bound orbit cardinal by class group size.
3. **Burnside-style averaging**
   - Count fixed points and derive orbit-size constraints.
   - More conceptual, especially for the representation-theory connection.

Use finite-set cardinality lemmas, `rcases`, and induction over finite generating subsets if needed.

---

## Cross-Domain Theorem Requirement

Include at least one theorem connecting this arithmetic framework to a distinct domain.

### Recommended connection: class groups → representation theory / proto-Langlands
Prove that finite class symmetry yields a character-theoretic observable.

**Lean-style statement:**
```lean
theorem abelian_class_symmetry_has_commuting_permutations
  {R : Type*} [CommRing R]
  (D : ExplicitClassFieldDatum R)
  [CommGroup D.Cl] :
  ∀ a b : D.Cl,
    explicitClassFieldDatum_perm_rep D |>.choose a *
      explicitClassFieldDatum_perm_rep D |>.choose b
    =
    explicitClassFieldDatum_perm_rep D |>.choose b *
      explicitClassFieldDatum_perm_rep D |>.choose a
```

Interpretation: the permutation operators commute because the class symmetry is abelian. This is a finite, formal shadow of the fact that abelian reciprocity should land in 1-dimensional automorphic data.

### Alternative cross-domain connection: class data → idempotent algebra
Use `idempotent_hilbert_basis_theorem` as inspiration, not as decoration. Define a semiring-valued complexity measure on class data and prove finite generation / stabilization of a class-invariant semimodule.

Example target:
```lean
theorem class_invariant_semimodule_fg
  {R S : Type*} [CommRing R] [Semiring S]
  (D : ExplicitClassFieldDatum R) :
  ∃ M : Submodule S (D.Cl → S), M.FG
```

This is more speculative, but if done well it creates a startling bridge:
**class field theory + idempotent finite generation**.

**Application keywords:** class field theory, Hilbert class field, finite Galois representations, proto-Langlands, permutation representations, arithmetic symmetry, algorithmic reciprocity, idempotent algebra.

---

## How to Build on Existing Verified Theorems

Do not cite the catalog passively; use it structurally.

1. **`idempotent_hilbert_basis_theorem`**
   - Use this as a conceptual template for proving finite generation/stabilization phenomena attached to your new class-invariant objects.
   - If you define a semiring or semimodule of class invariants, imitate the noetherian/finitely generated pattern.
   - This is especially powerful for the cross-domain theorem.

2. **`prime_cong_zero_class_prime_theory`**
   - Use it as a bridge between congruence/ideal-theoretic conditions and “class-like” quotient structures.
   - It may help formalize when a congruence relation on ideals or ideal representatives behaves like a prime-sensitive arithmetic quotient.

3. **`fundamental_theorem_algebraic_light'`**
   - Use this as a lightweight algebraicity engine when you need to certify that explicitly constructed elements satisfy polynomial constraints.
   - This is useful if your witness structure includes “generated by algebraic class invariants.”

4. **`master_theorem`**
   - If it provides a general oracle/fixed-point architecture, repurpose it to package the passage from arithmetic data to extension action.
   - Even if the semantics are abstract, this can help organize a canonical construction pipeline.

Do not force these theorems into the proof if they do not fit. But at least one theorem should genuinely leverage one of them as a reusable pattern.

---

## Proof Architecture

For each major theorem, include 2–3 proof steps in comments before the Lean proof. Example style:

```lean
/-
Strategy:
1. Show every class-group element acts trivially by subsingleton elimination.
2. Deduce every x : L is fixed by the action.
3. Apply fixed_base to descend x to K.
-/
```

At least 3 theorems must use deep proof tactics such as:
- `induction`
- `rcases`
- `by_contra`
- `field_simp`
- nontrivial `calc`
- quotient reasoning
- orbit/cardinality arguments

Avoid toy statements whose proof is one line.

---

## Conjecture with Testable Prediction

You must state at least one falsifiable conjecture and provide a computational test.

### Recommended conjecture
```lean
/-- Conjecture: for every finite explicit class field datum arising from a
Dedekind domain with trivial class group, the associated permutation
representation is trivial. -/
conjecture trivial_class_data_gives_trivial_representation
  {R : Type*} [CommRing R]
  (D : ExplicitClassFieldDatum R)
  [Subsingleton D.Cl] :
  ∀ c : D.Cl, explicitClassFieldDatum_perm_rep D |>.choose c = 1
```

**Computational test:** enumerate finite examples of quotient monoids/groups modeling class data; for each with singleton class set, compute the regular representation and verify every permutation is identity. A counterexample disproves the conjecture immediately.

### More ambitious conjecture
For finite abelian class data `D`, the cycle decomposition statistics of the regular action determine `Fintype.card D.Cl` uniquely and are compatible with the decomposition of abelian reciprocity into 1-dimensional characters.

**Computational test:** generate all small finite abelian groups up to order `N`, compute regular-action cycle types, and search for collisions violating uniqueness claims.

---

## Suggested File-Level Deliverables

Your Lean file should contain:

1. **A new definition** such as `ExplicitClassFieldDatum` or `HilbertClassFieldWitness`.
2. **At least 3 substantial theorems** from the list above.
3. **One cross-domain theorem** linking arithmetic class data to representation theory or idempotent algebra.
4. **One verified algorithmic construction**:
   - build the regular permutation representation,
   - compute orbits,
   - enumerate fixed points,
   - or compute class-action collapse in the trivial-group case.
5. **A small executable demonstration** of the construction on finite toy class groups.

---

## Verified Algorithm / Computational Method

You must provide a verified algorithm, not just theorem statements.

### Recommended algorithm
Implement a function constructing the regular permutation representation of finite class data:

```lean
def regularClassAction
  {R : Type*} [CommRing R]
  (D : ExplicitClassFieldDatum R) [Group D.Cl] :
  D.Cl →* Equiv.Perm D.Cl := ...
```

Then prove:
```lean
theorem regularClassAction_injective
  {R : Type*} [CommRing R]
  (D : ExplicitClassFieldDatum R) [Group D.Cl] :
  Function.Injective (regularClassAction D)
```

And an orbit-computation theorem:
```lean
theorem mem_orbit_regularClassAction_iff
  {R : Type*} [CommRing R]
  (D : ExplicitClassFieldDatum R) [Group D.Cl]
  (x y : D.Cl) :
  y ∈ MulAction.orbit (regularClassAction D).toMonoidHom x ↔ ∃ g : D.Cl, g * x = y
```

This is mathematically meaningful, executable, and representation-theoretically rich.

---

## Demo Requirements

Produce `demo.py` that:
- constructs several small finite abelian groups (`C1`, `C2`, `C2 × C2`, `C4`, etc.),
- computes their regular permutation actions,
- displays orbit sizes and cycle decompositions,
- tests the trivial-class-group collapse theorem computationally,
- optionally visualizes commuting permutation matrices.

This is not cosmetic: it gives empirical scaffolding for future Hilbert 12 conjectures.

---

## Mandatory Scientific Deliverables

You must produce **all** of the following:

1. **`FUTURE_DIRECTIONS.md`**
   - 3–5 falsifiable scientific hypotheses.
   - Each must have a clear disproof test.
   - At least one must concern extension from finite class actions to ray class data.
   - At least one must concern representation-theoretic shadows of abelian reciprocity.

2. **`RESEARCH_PAPER.md`**
   - Standalone scientific paper.
   - Must explain:
     - the new definitions,
     - exact theorem statements,
     - proof ideas,
     - why this is a genuine step toward Hilbert 12,
     - what has been mechanized versus conjectural,
     - what algorithm was verified.

3. **`ARTICLE.md`**
   - Scientific American style.
   - Explain how symmetry of ideal classes can generate hidden number systems.
   - Emphasize why formal proof matters for ambitious theories like Langlands.

4. **Verified algorithm**
   - The regular permutation representation / orbit engine / fixed-field collapse checker.

5. **`demo.py`**
   - Interactive or script-based demonstration of examples and conjecture tests.

---

## Standards

- Minimize `sorry`.
- No trivial theorem padding.
- No one-line decidable/enumerative “proofs” unless the theorem itself is deep.
- Every theorem should move the architecture toward explicit abelian generation.
- Prefer structural lemmas over brittle example-only results.
- If a conjectured full theorem is too strong, prove a rigorous finite-model shadow and state the stronger conjecture clearly.

---

## Ultimate Goal

You are not merely formalizing a corner of algebraic number theory. You are building the first certified **arithmetical symmetry compiler**: from ideal-class data to explicit finite symmetry actions, from symmetry actions to extension constraints, and from those constraints to the first mechanized shadows of Hilbert 12 and abelian Langlands reciprocity.

If successful, this opens a new field:
**formal explicit class field theory** — where number-theoretic generation principles, representation theory, and verified computation coexist in one machine-checkable framework.

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
hypotheses. Each direction must be a falsifiable claim or conjecture that
can be proved, disproved, or tested — not a vague "we could explore X."
Format: "Conjecture: [precise statement]. Test: [what would confirm or
refute it]. Impact: [what this would enable if true]." Every hypothesis
should be daring enough to matter and specific enough to fail.

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
