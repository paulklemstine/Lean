## Assignment: Algebra–EML–Cryptography Closure Secret-Sharing Duality via Idempotent Dependency Semimodules and Certified Access-Structure Reconstruction

**Mode:** prove

Build a new bridge theorem, not a variant: a genuine duality/classification result connecting finite closure theory, idempotent semimodule dependence, and monotone secret-sharing semantics. The objective is to make “authorization” a closure-theoretic notion with a certified algebraic normal form and executable reconstruction algorithms.

File target:
`Bridges/AlgebraEMLCryptography/ClosureSecretSharingDuality.lean`

You should minimize `sorry` aggressively and design the development so the main equivalence theorem factors through reusable lemmas about finite closure systems, ideals/up-sets on `Finset`/`Set`, and witness-extraction from finite generating data.

---

## Breakthrough Objective

Prove that a finite monotone secret-sharing access structure is not merely representable by closure data, but is *equivalent* to a pointed idempotent dependency geometry: authorization is exactly “the secret lies in the span of the chosen participants,” and unauthorized sets are exactly the flats avoiding the secret.

This is not just another representation theorem. If formalized cleanly, it opens a new field-level interface:

- **cryptography ↔ closure geometry:** access structures become closure-exact geometries;
- **cryptography ↔ idempotent algebra:** secret reconstruction becomes span membership;
- **EML ↔ certified algorithms:** minimal authorized sets and witness reconstruction become extracted finite certificates;
- **duality theory ↔ security semantics:** unauthorized flats play the role of algebraic obstructions, analogous to congruence classes in Myhill–Nerode or clopens in Stone duality.

The real breakthrough is the **canonical compressed presentation theorem**: every closure-exact finite access structure admits a certified minimal dependency presentation preserving authorization. That gives a mathematically canonical normal form for a family of secret-sharing schemes.

Application keywords: `secret sharing`, `access structures`, `closure systems`, `idempotent semimodules`, `dependency geometry`, `finite duality`, `hypergraph circuits`, `minimal authorized sets`, `reconstruction witnesses`, `canonical compression`, `certified cryptography`, `algorithm extraction`.

---

## Core Mathematical Setup

Let `X` be a finite participant type and let `t` be a distinguished secret generator in an extension `Option X` or a disjoint sum `X ⊕ Unit`. Let
- `cl : Set (Option X) → Set (Option X)` be a closure operator,
- participants correspond to `some x`,
- the secret corresponds to `none`.

For `S : Set X`, define its lifted participant set
`lift S : Set (Option X) := {y | ∃ x ∈ S, y = some x}`.

Define:

- unauthorized sets:
  `U_cl := {S : Set X | none ∉ cl (lift S)}`
- authorized sets:
  `A_cl := {S : Set X | none ∈ cl (lift S)}`

The target is to classify access structures of this form and then identify them with pointed finitely generated idempotent dependency semimodules `(M, s, g)` where:
- `M` is an idempotent semimodule / dependency object,
- `g : X → M` assigns participant generators,
- `s : M` is the secret,
- authorization is exactly `s ∈ span (g '' S)`.

You may need to introduce a lightweight abstract structure if Mathlib lacks the exact semimodule notion you want. If full semimodule formalization is too heavy for the first pass, define a finite “dependency span system” axiomatizing:
- monotonicity of span,
- idempotence of span,
- finite generation,
- witness extraction for finite spans.

Then prove the duality first at that abstraction level, and instantiate semimodule semantics afterward.

---

## Precise Theorem Targets

### 1. Access structure induced by closure is monotone and ideal

Prove that authorization induced by secret-in-closure is upward closed.

Suggested Lean-facing definitions:
```lean
def AuthorizedFromClosure {X : Type} (cl : Set (Option X) → Set (Option X)) (S : Set X) : Prop :=
  none ∈ cl {y : Option X | ∃ x ∈ S, y = some x}

def UnauthorizedFromClosure {X : Type} (cl : Set (Option X) → Set (Option X)) (S : Set X) : Prop :=
  none ∉ cl {y : Option X | ∃ x ∈ S, y = some x}
```

Precise theorem:
```lean
theorem authorizedFromClosure_mono
  {X : Type} [Finite X]
  (cl : Set (Option X) → Set (Option X))
  (h_ext : ∀ A, A ⊆ cl A)
  (h_mono : ∀ ⦃A B⦄, A ⊆ B → cl A ⊆ cl B)
  (h_idem : ∀ A, cl (cl A) = cl A) :
  Monotone (AuthorizedFromClosure cl)
```

Also prove the complement relation:
```lean
theorem unauthorizedFromClosure_compl_authorizedFromClosure
  {X : Type} (cl : Set (Option X) → Set (Option X)) :
  ∀ S, UnauthorizedFromClosure cl S ↔ ¬ AuthorizedFromClosure cl S
```

Why this matters: it certifies that closure semantics genuinely define monotone access structures, the foundational cryptographic axiom.

---

### 2. Minimal authorized sets are exactly secret-circuits / pointed dependency hyperedges

Define a minimal authorized set:
```lean
def IsMinimalAuthorized {X : Type}
  (A : Set X → Prop) (S : Set X) : Prop :=
  A S ∧ ∀ T, T ⊂ S → ¬ A T
```

Define a pointed circuit relative to secret `none`:
```lean
def IsSecretCircuit {X : Type}
  (cl : Set (Option X) → Set (Option X)) (S : Set X) : Prop :=
  none ∈ cl {y : Option X | ∃ x ∈ S, y = some x} ∧
  ∀ x ∈ S, none ∉ cl {y : Option X | ∃ z ∈ (S \ {x}), y = some z}
```

Then prove:
```lean
theorem minimalAuthorized_iff_secretCircuit
  {X : Type} [Finite X]
  (cl : Set (Option X) → Set (Option X))
  (h_ext : ∀ A, A ⊆ cl A)
  (h_mono : ∀ ⦃A B⦄, A ⊆ B → cl A ⊆ cl B)
  (h_idem : ∀ A, cl (cl A) = cl A) :
  ∀ S, IsMinimalAuthorized (AuthorizedFromClosure cl) S ↔ IsSecretCircuit cl S
```

This is the first major structural theorem: minimal authorized sets are not arbitrary; they are the circuit hyperedges of a pointed closure geometry.

---

### 3. Reconstruction theorem from closure-exact access structures

You need a closure-exactness axiom on an ideal access structure `A : Set X → Prop`. The right formulation should ensure that unauthorized sets are exactly the closed sets of a closure operator on `Option X` omitting the secret.

A promising definition:
- `A` is monotone,
- define candidate unauthorized flats
  `F := {S | ¬ A S}`,
- require `F` to be closed under arbitrary intersections (finite suffices on finite `X`),
- define closure by intersection of all unauthorized supersets:
  `cl_A(B) := ⋂₀ {F | B ⊆ F ∧ ¬ A (unlift F)}` with secret-aware adjustment,
- exactness axiom: `A S ↔ none ∈ cl_A (lift S)`.

You may instead package this as a theorem with assumptions that directly encode Moore-family behavior.

Precise theorem schema:
```lean
theorem exists_closure_of_accessStructure
  {X : Type} [Finite X]
  (A : Set X → Prop)
  (h_mono : Monotone A)
  (h_exact :
    ∃ cl : Set (Option X) → Set (Option X),
      (∀ B, B ⊆ cl B) ∧
      (∀ ⦃B C⦄, B ⊆ C → cl B ⊆ cl C) ∧
      (∀ B, cl (cl B) = cl B) ∧
      (∀ S : Set X, A S ↔ none ∈ cl {y : Option X | ∃ x ∈ S, y = some x})) :
  ∃ cl : Set (Option X) → Set (Option X),
    (∀ B, B ⊆ cl B) ∧
    (∀ ⦃B C⦄, B ⊆ C → cl B ⊆ cl C) ∧
    (∀ B, cl (cl B) = cl B) ∧
    (∀ S : Set X, A S ↔ AuthorizedFromClosure cl S)
```

But do not stop there. Strengthen it to **canonical reconstruction** if possible: define `canonicalClosureOfAccess A` and prove uniqueness among closure operators inducing `A` and satisfying exactness/minimality of closed unauthorized flats.

Ideal target:
```lean
theorem canonicalClosureOfAccess_spec
  {X : Type} [Fintype X] [DecidableEq X]
  (A : Set X → Prop)
  (h_mono : Monotone A)
  (h_moore : IsMooreFamily {S : Set X | ¬ A S})
  (h_top_unauth : ¬ A (∅ : Set X) := by ...)
  :
  let cl := canonicalClosureOfAccess A
  (∀ B, B ⊆ cl B) ∧
  (∀ ⦃B C⦄, B ⊆ C → cl B ⊆ cl C) ∧
  (∀ B, cl (cl B) = cl B) ∧
  (∀ S : Set X, A S ↔ AuthorizedFromClosure cl S)
```

This is the classification theorem in closure language.

---

### 4. Semimodule/dependency representation theorem

Formalize a pointed finite dependency system:
```lean
structure PointedDependencySystem (X : Type) where
  Carrier : Type
  span : Set Carrier → Set Carrier
  gen : X → Carrier
  secret : Carrier
  span_extensive : ∀ A, A ⊆ span A
  span_mono : ∀ ⦃A B⦄, A ⊆ B → span A ⊆ span B
  span_idem : ∀ A, span (span A) = span A
  span_finite_witness :
    ∀ {A z}, z ∈ span A → ∃ T : Finset Carrier, (↑T : Set Carrier) ⊆ A ∧ z ∈ span (↑T : Set Carrier)
```

Define:
```lean
def AuthorizedFromDependency {X : Type} (D : PointedDependencySystem X) (S : Set X) : Prop :=
  D.secret ∈ D.span (D.gen '' S)
```

Then prove equivalence with closure semantics by taking closure on `Option X` induced by generator span:
```lean
theorem dependency_authorization_equiv_closure_authorization
  {X : Type} [Finite X]
  (D : PointedDependencySystem X) :
  ∃ cl : Set (Option X) → Set (Option X),
    (∀ S : Set X, AuthorizedFromDependency D S ↔ AuthorizedFromClosure cl S)
```

The stronger theorem, and the one you should aim for, is a finite dual equivalence between:
1. closure-exact access structures,
2. pointed finite dependency systems modulo authorization-preserving isomorphism.

Even if category-level equivalence is too much for one cycle, prove:
- every pointed dependency system induces a closure-exact access structure;
- every closure-exact access structure admits a canonical dependency realization;
- the two constructions are inverse up to extensional equality on authorized families.

Suggested theorem:
```lean
theorem closure_dependency_duality_finite
  {X : Type} [Fintype X] [DecidableEq X] :
  ∀ A : Set X → Prop,
    ClosureExactAccessStructure A →
    ∃ D : PointedDependencySystem X,
      ∀ S : Set X, A S ↔ AuthorizedFromDependency D S
```

and conversely:
```lean
theorem dependency_induces_closureExactAccessStructure
  {X : Type} [Fintype X] [DecidableEq X]
  (D : PointedDependencySystem X) :
  ClosureExactAccessStructure (AuthorizedFromDependency D)
```

This is the theorem that turns the whole story from “encoding trick” into a real duality program.

---

### 5. Certified minimization / canonical compressed presentation

Define redundancy of a generator/participant in a dependency presentation and prove existence of a compressed presentation preserving authorization.

Suggested statement:
```lean
theorem exists_irredundant_dependency_presentation
  {X : Type} [Fintype X] [DecidableEq X]
  (D : PointedDependencySystem X) :
  ∃ D' : PointedDependencySystem X,
    (∀ S : Set X, AuthorizedFromDependency D S ↔ AuthorizedFromDependency D' S) ∧
    IrredundantPresentation D' ∧
    PresentationSize D' ≤ PresentationSize D
```

Stronger canonicality target:
```lean
theorem exists_canonical_compressed_presentation
  {X : Type} [Fintype X] [DecidableEq X]
  (A : Set X → Prop)
  (hA : ClosureExactAccessStructure A) :
  ∃! D : PointedDependencySystem X,
    CanonicallyCompressed D ∧
    ∀ S : Set X, A S ↔ AuthorizedFromDependency D S
```

If uniqueness is too ambitious, prove uniqueness of the set of minimal authorized sets / secret-circuits, and derive canonicity of the compressed hypergraph presentation.

This is cryptographically meaningful: it produces a normalized “scheme skeleton” stripped of algebraic redundancy.

---

### 6. Algorithmic extraction theorem

On finite `X`, compute:
- all minimal authorized sets,
- a reconstruction witness for each authorized set,
- a compressed presentation.

At minimum, prove existence and correctness of finite enumeration.

Suggested Lean target:
```lean
def minimalAuthorizedSets [Fintype X] [DecidableEq X]
  (A : Set X → Prop) : Finset (Finset X) := ...

theorem mem_minimalAuthorizedSets_iff
  {X : Type} [Fintype X] [DecidableEq X]
  (cl : Set (Option X) → Set (Option X))
  (hcl : IsClosureOperator cl)
  (S : Finset X) :
  S ∈ minimalAuthorizedSets (AuthorizedFromClosure cl) ↔
    IsMinimalAuthorized (AuthorizedFromClosure cl) (S : Set X)
```

And for witnesses:
```lean
def reconstructionWitness [Fintype X] [DecidableEq X]
  (D : PointedDependencySystem X) (S : Finset X) :
  Option (FiniteSpanWitness D S)

theorem reconstructionWitness_correct
  {X : Type} [Fintype X] [DecidableEq X]
  (D : PointedDependencySystem X) (S : Finset X) :
  AuthorizedFromDependency D (S : Set X) →
  ∃ w, reconstructionWitness D S = some w
```

This algorithmic layer is essential: the theorem should not merely classify structures abstractly, but extract cryptographic certificates.

---

## Suggested Lean 4 Type Signatures

You do not need to use these exact names, but the development should expose theorem statements of roughly this precision:

```lean
structure IsClosureOperator {α : Type} (cl : Set α → Set α) : Prop where
  extensive : ∀ A, A ⊆ cl A
  monotone : ∀ ⦃A B⦄, A ⊆ B → cl A ⊆ cl B
  idempotent : ∀ A, cl (cl A) = cl A

def liftParticipants {X : Type} (S : Set X) : Set (Option X) :=
  {y | ∃ x ∈ S, y = some x}

def AuthorizedFromClosure {X : Type}
  (cl : Set (Option X) → Set (Option X)) (S : Set X) : Prop :=
  none ∈ cl (liftParticipants S)

def IsMinimalAuthorized {X : Type}
  (A : Set X → Prop) (S : Set X) : Prop :=
  A S ∧ ∀ T, T ⊂ S → ¬ A T

structure PointedDependencySystem (X : Type) where
  Carrier : Type
  span : Set Carrier → Set Carrier
  gen : X → Carrier
  secret : Carrier
  span_closure : IsClosureOperator span
  finite_witness :
    ∀ {A z}, z ∈ span A → ∃ T : Finset Carrier, (↑T : Set Carrier) ⊆ A ∧ z ∈ span (↑T : Set Carrier)

def AuthorizedFromDependency {X : Type}
  (D : PointedDependencySystem X) (S : Set X) : Prop :=
  D.secret ∈ D.span (D.gen '' S)

theorem authorizedFromClosure_mono ...
theorem minimalAuthorized_iff_secretCircuit ...
theorem dependency_induces_closureExactAccessStructure ...
theorem closureExact_access_has_dependency_representation ...
theorem exists_irredundant_dependency_presentation ...
theorem minimalAuthorizedSets_correct ...
```

If Mathlib support for `Set`-based closure operators is inconvenient, use `Finset X → Finset X` for the finite executable layer and separately prove extensional equivalence with `Set` formulations.

---

## Proof Strategy Architecture

### Strategy A: Closure-first, then dependency realization
Most promising.

1. **Build the closure-theoretic side cleanly.**
   - Define `AuthorizedFromClosure`.
   - Prove monotonicity, ideality, minimal-authorized/circuit equivalence.
   - Define closure-exact access structures as those whose unauthorized family is a Moore family of flats avoiding `none`.

2. **Construct canonical dependency systems from closure.**
   - Take carrier to be closed sets / flats / principal generators of closure.
   - Define span by closure of unions of generators.
   - Realize secret as the distinguished element `none`.
   - Show `AuthorizedFromDependency` agrees extensionally with `AuthorizedFromClosure`.

3. **Prove compression via circuit hypergraph minimization.**
   - Minimal authorized sets form the irredundant hyperedge basis.
   - Every authorized set contains one.
   - Compression is obtained by retaining only these circuits/hyperedges.

Why this is strongest: it leverages native closure infrastructure and avoids premature commitment to heavy semiring APIs. It also naturally supports canonicality.

---

### Strategy B: Hypergraph secret-sharing first, then identify closure as transversal hull
Very viable, especially for algorithmics.

1. Represent an access structure by its finite set of minimal authorized sets.
2. Define closure via “all minimal hyperedges forced by a set,” adjoining the secret when one hyperedge is contained.
3. Show this closure is extensive, monotone, idempotent, and reconstructs the original access structure.
4. Package the hypergraph as an idempotent dependency system where span is generated by hyperedge forcing.

Why useful: minimal authorized sets are the natural cryptographic object. This route gives executable enumeration and compression almost for free. It may be the easiest way to get the certified algorithm theorem.

---

### Strategy C: Semimodule-first via free idempotent algebra
Most ambitious.

1. Build a free idempotent dependency semimodule on participants plus secret.
2. Quotient by the relations expressing authorized reconstructions.
3. Define span as closure under idempotent linear generation.
4. Prove exactness and canonicality via universal properties.

Why powerful: this is the deepest algebraic statement and gives a true representation theorem. But it may be too expensive if Mathlib lacks the exact idempotent semimodule machinery you need. Best used after Strategy A secures the core duality.

---

## Recommended Order of Attack

1. `IsClosureOperator`, `liftParticipants`, `AuthorizedFromClosure`
2. monotonicity/ideality lemmas
3. minimal authorized = secret-circuit
4. finite enumeration of minimal authorized sets
5. hypergraph/circuit compressed presentation
6. abstract `PointedDependencySystem`
7. representation from closure to dependency and back
8. uniqueness/canonicality refinements

This staging ensures you land substantial theorems even if the full semimodule packaging takes longer.

---

## How to Build on Existing Catalog Theorems

Use
`post_quantum_closure_hash_stable_under_idempotent_round`
as a signal that the existing catalog already contains closure/idempotence stability patterns worth abstracting. Even if the theorem is from a different domain, mine its proof architecture:
- identify reusable lemmas about idempotent iteration or closure stability,
- extract generic closure-under-round/iteration principles,
- repurpose them to prove idempotence and fixed-point stability for your reconstructed closure operators or compression maps.

The point is not thematic similarity but proof reuse: if the catalog already certifies that a closure-like transformation stabilizes under idempotent rounds, use the same abstraction pattern to show your canonical compression or reconstructed closure is a fixed point after one pass.

---

## Cross-Domain Connections You Should Explicitly Exploit

1. **Matroid/antimatroid/circuit theory**
   - Minimal authorized sets behave like circuits through a distinguished point.
   - Unauthorized flats are the analog of flats avoiding the secret.
   - If anti-exchange fails or is unnecessary, make that explicit: this is broader than matroids and closer to general dependency geometries.

2. **Automata/Myhill–Nerode**
   - Access structures classify subsets by their reconstruction power.
   - Canonical compressed presentation is analogous to minimizing a DFA: remove redundant generators while preserving the accepted language of authorized sets.

3. **Stone/Priestley duality**
   - Unauthorized families as Moore families suggest a lattice-theoretic dual semantics.
   - Closed unauthorized sets are algebraic obstructions; authorized sets are their complement as semantic possibility regions.

4. **Tropical/idempotent algebra**
   - Span in idempotent semimodules reframes reconstruction as a tropical linear dependence phenomenon.
   - This could eventually connect linear secret sharing with min-plus/max-plus convexity and tropical rank.

5. **Formal cryptography**
   - Minimal authorized sets are threshold witnesses / reconstruction certificates.
   - Canonical compression gives a certified normal form for policy representation, relevant to attribute-based access, monotone span programs, and policy minimization.

This is exactly the sort of cross-pollination that can open a new program, not just prove a theorem.

---

## Deliverables

In `Bridges/AlgebraEMLCryptography/ClosureSecretSharingDuality.lean`, aim to include:

- precise definitions for closure-induced authorization;
- monotonicity and complement lemmas;
- minimal authorized sets = secret-circuits;
- finite enumeration/correctness theorem for minimal authorized sets;
- closure-exact reconstruction theorem;
- abstract pointed dependency-system representation theorem;
- certified irredundant/compressed presentation theorem.

If a full semimodule formalization is too costly in one cycle, still complete the closure/hypergraph duality and leave the dependency structure abstract but theorem-ready.

---

## FUTURE_DIRECTIONS Requirement

Produce `FUTURE_DIRECTIONS.md` with 3–5 concrete next steps at breakthrough level, not incremental variants. Include items of the following flavor:

1. a monotone span-program equivalence theorem from your dependency presentations;
2. an information-theoretic invariant of closure-exact access structures;
3. a categorical duality between finite closure-exact access structures and a class of pointed idempotent algebras;
4. a tropical linear secret-sharing semantics theorem;
5. complexity classification of canonical compression/minimal authorization extraction.

Be specific: each direction should name a target theorem, the new objects involved, and why it would open a field rather than extend one.

Make this development feel inevitable in retrospect and surprising in prospect.

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
